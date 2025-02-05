package org.orcid.scheduler.loader.source.fundref;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

import javax.annotation.Resource;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.apache.commons.lang.StringUtils;
import org.orcid.core.manager.OrgDisambiguatedManager;
import org.orcid.core.orgs.OrgDisambiguatedSourceType;
import org.orcid.core.orgs.grouping.OrgGrouping;
import org.orcid.jaxb.model.message.Iso3166Country;
import org.orcid.persistence.constants.OrganizationStatus;
import org.orcid.persistence.dao.OrgDisambiguatedDao;
import org.orcid.persistence.jpa.entities.IndexingStatus;
import org.orcid.persistence.jpa.entities.OrgDisambiguatedEntity;
import org.orcid.pojo.ajaxForm.PojoUtil;
import org.orcid.scheduler.loader.io.FileRotator;
import org.orcid.scheduler.loader.io.OrgDataClient;
import org.orcid.scheduler.loader.source.LoadSourceDisabledException;
import org.orcid.scheduler.loader.source.OrgLoadSource;
import org.orcid.utils.jersey.JerseyClientHelper;
import org.orcid.utils.jersey.JerseyClientResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Component
public class FundrefOrgLoadSource implements OrgLoadSource {

    private static final Logger LOGGER = LoggerFactory.getLogger(FundrefOrgLoadSource.class);

    private static final String CONCEPTS_EXPRESSION = "/RDF/ConceptScheme/hasTopConcept";
    private static final String ITEM_EXPRESSION = "/RDF/Concept[@about='%s']";
    private static final String ORG_NAME_EXPRESSION = "prefLabel/Label/literalForm";
    private static final String ORG_COUNTRY_EXPRESSION = "country";
    private static final String ORG_STATE_EXPRESSION = "state";
    private static final String ORG_TYPE_EXPRESSION = "fundingBodyType";
    private static final String ORG_SUBTYPE_EXPRESSION = "fundingBodySubType";
    private static final String STATUS_EXPRESSION = "status";
    private static final String IS_REPLACED_BY_EXPRESSION = "isReplacedBy";
    private static final String STATE_NAME = "STATE";
    private static final String STATE_ABBREVIATION = "abbr";
    private static final String DEPRECATED_INDICATOR = "http://data.crossref.org/fundingdata/vocabulary/Deprecated";

    @Resource(name = "fundrefOrgDataClient")
    private OrgDataClient orgDataClient;

    @Value("${org.orcid.core.orgs.fundref.latestReleaseUrl:url}")
    private String fundrefDataUrl;

    @Value("${org.orcid.core.orgs.fundref.localFilePath:/tmp/ringgold/fundref.rdf}")
    private String localFilePath;

    @Value("${org.orcid.core.orgs.clients.userAgent}")
    private String userAgent;

    @Resource
    private FileRotator fileRotator;

    @Value("${org.orcid.core.orgs.fundref.enabled:true}")
    private boolean enabled;

    @Resource(name = "geonamesApiUrl")
    private String geonamesApiUrl;

    @Resource
    private OrgDisambiguatedDao orgDisambiguatedDao;

    @Resource
    private OrgDisambiguatedManager orgDisambiguatedManager;

    @Resource(name = "geonamesUser")
    private String apiUser;
    
    @Resource
    private JerseyClientHelper jerseyClientHelper;
    
    private XPath xPath = XPathFactory.newInstance().newXPath();
    
    @Override
    public String getSourceName() {
        return "FUNDREF";
    }

    @Override
    public boolean loadOrgData() {
        if (!enabled) {
            throw new LoadSourceDisabledException(getSourceName());
        }

        return importData();
    }

    private boolean importData() {
        Map<String, String> cache = new HashMap<String, String>();
        InputStream stream = null;
        try {
            long start = System.currentTimeMillis();
            stream = new FileInputStream(localFilePath);
            DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = builderFactory.newDocumentBuilder();
            Document xmlDocument = builder.parse(stream);

            NodeList nodeList = (NodeList) xPath.compile(CONCEPTS_EXPRESSION).evaluate(xmlDocument, XPathConstants.NODESET);
            for (int i = 0; i < nodeList.getLength(); i++) {
                RDFOrganization rdfOrganization = getOrganization(xmlDocument, nodeList.item(i).getAttributes(), cache);
                LOGGER.info("Processing organization from RDF, doi:{}", new String[] { rdfOrganization.doi });

                OrgDisambiguatedEntity existingEntity = findById(rdfOrganization);
                if (existingEntity != null) {
                    if (entityChanged(rdfOrganization, existingEntity)) {
                        existingEntity.setCity(rdfOrganization.city);
                        Iso3166Country country = StringUtils.isNotBlank(rdfOrganization.country) ? Iso3166Country.fromValue(rdfOrganization.country) : null;
                        existingEntity.setCountry(country == null ? null : country.name());
                        existingEntity.setName(rdfOrganization.name);
                        String orgType = getOrgType(rdfOrganization);
                        existingEntity.setOrgType(orgType);
                        existingEntity.setRegion(rdfOrganization.stateCode);
                        existingEntity.setSourceId(rdfOrganization.doi);
                        existingEntity.setSourceType(OrgDisambiguatedSourceType.FUNDREF.name());
                        existingEntity.setSourceUrl(rdfOrganization.doi);
                        existingEntity.setIndexingStatus(IndexingStatus.PENDING);
                        if(!StringUtils.equals(existingEntity.getStatus(),OrganizationStatus.PART_OF_GROUP.name())){
                            existingEntity.setStatus(rdfOrganization.status);
                        }
                        try {
                            // mark group for indexing
                            new OrgGrouping(existingEntity, orgDisambiguatedManager).markGroupForIndexing(orgDisambiguatedDao);

                        } catch (Exception ex) {
                            LOGGER.error("Error when grouping by ROR and marking group orgs for reindexing, eating the exception", ex);
                        }
                        orgDisambiguatedManager.updateOrgDisambiguated(existingEntity);
                    } else if (statusChanged(rdfOrganization, existingEntity)) {
                        existingEntity.setStatus(rdfOrganization.status);
                        existingEntity.setIndexingStatus(IndexingStatus.PENDING);
                        try {
                            // mark group for indexing
                            new OrgGrouping(existingEntity, orgDisambiguatedManager).markGroupForIndexing(orgDisambiguatedDao);

                        } catch (Exception ex) {
                            LOGGER.error("Error when grouping by ROR and marking group orgs for reindexing, eating the exception", ex);
                        }
                        orgDisambiguatedManager.updateOrgDisambiguated(existingEntity);
                    } else {
                        if (StringUtils.isNotBlank(rdfOrganization.isReplacedBy)) {
                            if (!rdfOrganization.isReplacedBy.equals(existingEntity.getSourceParentId())) {
                                existingEntity.setSourceParentId(rdfOrganization.isReplacedBy);
                                existingEntity.setStatus(OrganizationStatus.DEPRECATED.name());
                                existingEntity.setIndexingStatus(IndexingStatus.PENDING);
                                try {
                                    // mark group for indexing
                                    new OrgGrouping(existingEntity, orgDisambiguatedManager).markGroupForIndexing(orgDisambiguatedDao);

                                } catch (Exception ex) {
                                    LOGGER.error("Error when grouping by ROR and marking group orgs for reindexing, eating the exception", ex);
                                }
                                orgDisambiguatedManager.updateOrgDisambiguated(existingEntity);
                            }
                        }
                    }
                } else {
                    OrgDisambiguatedEntity newEntity = createDisambiguatedOrg(rdfOrganization);
                    try {
                        try {
                            // mark group for indexing
                            new OrgGrouping(newEntity, orgDisambiguatedManager).markGroupForIndexing(orgDisambiguatedDao);

                        } catch (Exception ex) {
                            LOGGER.error("Error when grouping by ROR and marking group orgs for reindexing, eating the exception", ex);
                        }
                    } catch (Exception ex) {
                        LOGGER.error("Error when grouping by ROR and removing related orgs solr index, eating the exception", ex);
                    }
                }
            }
            long end = System.currentTimeMillis();
            LOGGER.info("Time taken to process the files: {}", (end - start));
            return true;
        } catch (FileNotFoundException fne) {
            LOGGER.error("Unable to read file {}", localFilePath);
            return false;
        } catch (ParserConfigurationException pce) {
            LOGGER.error("Unable to initialize the DocumentBuilder");
            return false;
        } catch (IOException ioe) {
            LOGGER.error("Unable to parse document {}", localFilePath);
            return false;
        } catch (SAXException se) {
            LOGGER.error("Unable to parse document {}", localFilePath);
            return false;
        } catch (XPathExpressionException xpe) {
            LOGGER.error("XPathExpressionException {}", xpe.getMessage());
            return false;
        } finally {
            try {
                stream.close();
            } catch (IOException e) {
                LOGGER.error("Error closing stream", e);
                throw new RuntimeException(e);
            }
        }
    }

    /**
     * FUNDREF FUNCTIONS
     */

    /**
     * Get an RDF organization from the given RDF file
     */
    private RDFOrganization getOrganization(Document xmlDocument, NamedNodeMap attrs, Map<String, String> cache) {
        RDFOrganization organization = new RDFOrganization();
        try {
            Node node = attrs.getNamedItem("rdf:resource");
            String itemDoi = node.getNodeValue();
            // Get item node
            Node organizationNode = (Node) xPath.compile(ITEM_EXPRESSION.replace("%s", itemDoi)).evaluate(xmlDocument, XPathConstants.NODE);
            organizationNode.getParentNode().removeChild(organizationNode);

            // Get organization name
            String orgName = (String) xPath.compile(ORG_NAME_EXPRESSION).evaluate(organizationNode, XPathConstants.STRING);

            // Get status indicator
            Node statusNode = (Node) xPath.compile(STATUS_EXPRESSION).evaluate(organizationNode, XPathConstants.NODE);
            String status = null;
            if (statusNode != null) {
                NamedNodeMap statusAttrs = statusNode.getAttributes();
                if (statusAttrs != null) {
                    String statusAttribute = statusAttrs.getNamedItem("rdf:resource").getNodeValue();
                    if (isDeprecatedStatus(statusAttribute)) {
                        status = OrganizationStatus.DEPRECATED.name();
                    }
                }
            }

            // Get country code
            Node countryNode = (Node) xPath.compile(ORG_COUNTRY_EXPRESSION).evaluate(organizationNode, XPathConstants.NODE);
            NamedNodeMap countryAttrs = countryNode.getAttributes();
            String countryGeonameUrl = countryAttrs.getNamedItem("rdf:resource").getNodeValue();
            String countryCode = fetchFromGeoNames(countryGeonameUrl, "countryCode", cache);

            // Get state name
            Node stateNode = (Node) xPath.compile(ORG_STATE_EXPRESSION).evaluate(organizationNode, XPathConstants.NODE);
            String stateCode = null;
            if (stateNode != null) {
                NamedNodeMap stateAttrs = stateNode.getAttributes();
                String stateGeoNameCode = stateAttrs.getNamedItem("rdf:resource").getNodeValue();
                stateCode = fetchFromGeoNames(stateGeoNameCode, STATE_NAME, cache);
            }

            String orgType = (String) xPath.compile(ORG_TYPE_EXPRESSION).evaluate(organizationNode, XPathConstants.STRING);
            String orgSubType = (String) xPath.compile(ORG_SUBTYPE_EXPRESSION).evaluate(organizationNode, XPathConstants.STRING);
            Node isReplacedByNode = (Node) xPath.compile(IS_REPLACED_BY_EXPRESSION).evaluate(organizationNode, XPathConstants.NODE);
            String isReplacedBy = null;
            if (isReplacedByNode != null) {
                isReplacedBy = isReplacedByNode.getAttributes().getNamedItem("rdf:resource").getNodeValue();
            }

            organization.doi = itemDoi;
            organization.name = orgName;
            organization.country = countryCode;
            organization.stateCode = stateCode;
            organization.city = stateCode;
            organization.type = orgType;
            organization.subtype = orgSubType;
            organization.status = status;
            organization.isReplacedBy = isReplacedBy;
        } catch (XPathExpressionException xpe) {
            LOGGER.error("XPathExpressionException {}", xpe.getMessage());
        }

        return organization;
    }

    /**
     * Indicates if an organization has been marked as deprecated
     */
    private boolean isDeprecatedStatus(String statusAttribute) {
        return DEPRECATED_INDICATOR.equalsIgnoreCase(statusAttribute);
    }

    /**
     * GEONAMES FUNCTIONS
     */

    /**
     * Fetch a property from geonames
     */
    private String fetchFromGeoNames(String geoNameUri, String propertyToFetch, Map<String, String> cache) {
        String result = null;
        String geoNameId = geoNameUri.replaceAll("[^\\d]", "");
        if (StringUtils.isNotBlank(geoNameId)) {
            String cacheKey = propertyToFetch + '_' + geoNameId;
            if (cache.containsKey(cacheKey)) {
                result = cache.get(cacheKey);
            } else {
                String jsonResponse = fetchJsonFromGeoNames(geoNameId, cache);
                if (STATE_NAME.equals(propertyToFetch)) {
                    result = fetchStateAbbreviationFromJson(jsonResponse);
                } else {
                    result = fetchValueFromJson(jsonResponse, propertyToFetch);
                }
                cache.put(cacheKey, result);
            }
        }

        return result;
    }

    /**
     * Queries GeoNames API for a given geonameId and return the JSON string
     */
    private String fetchJsonFromGeoNames(String geoNameId, Map<String, String> cache) {
        String result = null;
        if (cache.containsKey("geoname_json_" + geoNameId)) {
            return cache.get("geoname_json_" + geoNameId);
        } else {
            Map<String, String> params = new HashMap<String, String>();
            params.put("geonameId", geoNameId);
            params.put("username", apiUser);
            JerseyClientResponse<String, String> response = jerseyClientHelper.executeGetRequest(geonamesApiUrl, params); 
            int status = response.getStatus();
            if (status == 200) {
                result = response.getEntity();
            } else {
                LOGGER.warn("Got error status from geonames: {}", status);
                try {
                    LOGGER.info("Waiting before retrying geonames...");
                    Thread.sleep(30000);
                } catch (InterruptedException e) {
                    throw new RuntimeException(e);
                }
                JerseyClientResponse<String, String> retryResponse = jerseyClientHelper.executeGetRequest(geonamesApiUrl, params);
                int retryStatus = retryResponse.getStatus();
                if (retryStatus == 200) {
                    result = retryResponse.getEntity();
                } else {
                    String message = "Geonames failed after retry with status: " + retryStatus;
                    LOGGER.error(message);
                    throw new RuntimeException(message);
                }
            }
            cache.put("geoname_json_" + geoNameId, result);
        }
        return result;
    }

    /**
     * It only fetches properties in the first level
     */
    private String fetchValueFromJson(String jsonString, String propetyName) {
        String result = null;
        try {
            ObjectMapper m = new ObjectMapper();
            JsonNode rootNode = m.readTree(jsonString);
            JsonNode nameNode = rootNode.path(propetyName);
            if (nameNode != null)
                result = nameNode.asText();
        } catch (Exception e) {

        }
        return result;
    }

    /**
     * Fetch the state abbreviation from a geonames response
     */
    private String fetchStateAbbreviationFromJson(String jsonString) {
        String result = null;
        try {
            ObjectMapper m = new ObjectMapper();
            JsonNode rootNode = m.readTree(jsonString);
            JsonNode arrayNode = rootNode.get("alternateNames");
            if (arrayNode != null && arrayNode.isArray()) {
                for (final JsonNode altNameNode : arrayNode) {
                    JsonNode langNode = altNameNode.get("lang");
                    if (langNode != null && STATE_ABBREVIATION.equals(langNode.asText())) {
                        JsonNode nameNode = altNameNode.get("name");
                        result = nameNode.asText();
                        break;
                    }
                }
            }
        } catch (Exception e) {

        }
        return result;
    }

    /**
     * DATABASE FUNCTIONS
     */
    private OrgDisambiguatedEntity findById(RDFOrganization org) {
        return orgDisambiguatedDao.findBySourceIdAndSourceType(org.doi, OrgDisambiguatedSourceType.FUNDREF.name());
    }

    /**
     * Indicates if an entity changed his name, country, state or city
     * 
     * @param org
     *            The organization with the new values
     * @param entity
     *            The organization we have stored in the database
     * 
     * @return true if the entity has changed.
     */
    private boolean entityChanged(RDFOrganization org, OrgDisambiguatedEntity entity) {
        if (StringUtils.isNotBlank(org.name)) {
            if (!org.name.equalsIgnoreCase(entity.getName()))
                return true;
        } else if (StringUtils.isNotBlank(entity.getName())) {
            return true;
        }

        if (StringUtils.isNotBlank(org.country)) {
            if (entity.getCountry() == null || !org.country.equals(entity.getCountry())) {
                return true;
            }
        } else if (entity.getCountry() != null) {
            return true;
        }

        if (StringUtils.isNotBlank(org.stateCode)) {
            if (entity.getRegion() == null || !org.stateCode.equals(entity.getRegion())) {
                return true;
            }
        } else if (StringUtils.isNotBlank(entity.getRegion())) {
            return true;
        }

        if (StringUtils.isNotBlank(org.city)) {
            if (entity.getCity() == null || !org.city.equals(entity.getCity())) {
                return true;
            }
        } else if (StringUtils.isNotBlank(entity.getCity())) {
            return true;
        }

        String orgType = getOrgType(org);

        if (StringUtils.isNotBlank(org.type)) {
            if (entity.getOrgType() == null || !entity.getOrgType().equals(orgType)) {
                return true;
            }
        }

        return false;
    }

    private String getOrgType(RDFOrganization org) {
        return org.type + (StringUtils.isEmpty(org.subtype) ? "" : '/' + org.subtype);
    }

    /**
     * Indicates if an entity status has changed
     * 
     * @param org
     *            The organization with the new values
     * @param entity
     *            The organization we have stored in the database
     * 
     * @return true if the entity status has changed.
     */
    private boolean statusChanged(RDFOrganization org, OrgDisambiguatedEntity entity) {
        if (!PojoUtil.isEmpty(org.status)) {
            if (!org.status.equalsIgnoreCase(entity.getStatus())) {
                return true;
            }
        } else if (!PojoUtil.isEmpty(entity.getStatus())) {
            // If for some reason, the status of the updated organization is
            // removed, remove it also from our data
            return true;
        }
        return false;
    }

    /**
     * Creates a disambiguated ORG in the org_disambiguated table
     */
    private OrgDisambiguatedEntity createDisambiguatedOrg(RDFOrganization organization) {
        LOGGER.info("Creating disambiguated org {}", organization.name);
        String orgType = getOrgType(organization);
        Iso3166Country country = StringUtils.isNotBlank(organization.country) ? Iso3166Country.fromValue(organization.country) : null;
        OrgDisambiguatedEntity orgDisambiguatedEntity = new OrgDisambiguatedEntity();
        orgDisambiguatedEntity.setName(organization.name);
        orgDisambiguatedEntity.setCountry(country == null ? null : country.name());
        orgDisambiguatedEntity.setCity(organization.city);
        orgDisambiguatedEntity.setRegion(organization.stateCode);
        orgDisambiguatedEntity.setOrgType(orgType);
        orgDisambiguatedEntity.setSourceId(organization.doi);
        orgDisambiguatedEntity.setSourceUrl(organization.doi);

        if (!PojoUtil.isEmpty(organization.status)) {
            orgDisambiguatedEntity.setStatus(OrganizationStatus.DEPRECATED.name());
        }

        if (!PojoUtil.isEmpty(organization.isReplacedBy)) {
            orgDisambiguatedEntity.setSourceParentId(organization.isReplacedBy);
            orgDisambiguatedEntity.setStatus(OrganizationStatus.DEPRECATED.name());
        }

        orgDisambiguatedEntity.setSourceType(OrgDisambiguatedSourceType.FUNDREF.name());
        orgDisambiguatedManager.createOrgDisambiguated(orgDisambiguatedEntity);
        return orgDisambiguatedEntity;
    }

    @Override
    public boolean downloadOrgData() {
        fileRotator.removeFileIfExists(localFilePath);
        return orgDataClient.downloadFile(fundrefDataUrl, userAgent, localFilePath);
    }

    @Override
    public boolean isEnabled() {
        return enabled;
    }

    private class RDFOrganization {
        String doi, name, country, stateCode, city, type, subtype, status, isReplacedBy;
    }

}
