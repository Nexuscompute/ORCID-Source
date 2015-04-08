<#--

    =============================================================================

    ORCID (R) Open Source
    http://orcid.org

    Copyright (c) 2012-2014 ORCID, Inc.
    Licensed under an MIT-Style License (MIT)
    http://orcid.org/open-source-license

    This copyright and license information (including a link to the full license)
    shall be included in its entirety in all copies or substantial portion of
    the software.

    =============================================================================

-->
<script type="text/ng-template" id="add-peer-review-modal"> 
	<div class="add-peer-review colorbox-content">
		<fn-form update-fn="">
			<div class="lightbox-container-ie7">		
			<!-- Title -->
			<div class="row">			
				<div class="col-md-9 col-sm-8 col-xs-9">	
					<h1 class="lightbox-title pull-left">						
						<div ng-show="editPeerReview.putCode.value != ''">
							Edit Peer Review
						</div>						 
						<div ng-show="editPeerReview.putCode.value == ''">
							Add Peer Review
						</div>
					</h1>
				</div>			
			</div>
	
			<!-- Main content -->		
			<div class="row">
				<!-- Left Column -->			
				<div class="col-md-6 col-sm-6 col-xs-12">	
					<!-- ROLE -->
					<div class="control-group">
			    		<label class="relative">Role</label>			    		
			    		<div class="relative">
				    		<select id="peerReviewRole" class="input-xlarge" name="peerReviewRole" ng-model="editPeerReview.role.value" ng-change="serverValidate('peer-reviews/roleValidate.json');">
                            	<option value=""><@orcid.msg 'org.orcid.jaxb.model.record.Role.empty' /></option>
                            	<#list peerReviewRoles?keys as key>
                                	<option value="${key}">${peerReviewRoles[key]}</option>
                            	</#list>
                        	</select> 
							<span class="required" ng-class="isValidClass(editPeerReview.role)">*</span>
							<span class="orcid-error" ng-show="editPeerReview.role.errors.length > 0">
								<div ng-repeat='error in editPeerReview.role.errors' ng-bind-html="error"></div>
							</span>
						</div>
					</div>
					<!-- TYPE -->
					<div class="control-group">
			    		<label class="relative">Type</label>			    		
			    		<div class="relative">
				    		<select id="peerReviewType" class="input-xlarge" name="peerReviewType" ng-model="editPeerReview.type.value" ng-change="serverValidate('peer-reviews/typeValidate.json');">
                            	<option value=""><@orcid.msg 'org.orcid.jaxb.model.record.PeerReviewType.empty' /></option>
                            	<#list peerReviewTypes?keys as key>
                                	<option value="${key}">${peerReviewTypes[key]}</option>
                            	</#list>
                        	</select> 
							<span class="required" ng-class="isValidClass(editPeerReview.type)">*</span>
							<span class="orcid-error" ng-show="editPeerReview.type.errors.length > 0">
								<div ng-repeat='error in editPeerReview.type.errors' ng-bind-html="error"></div>
							</span>
						</div>
					</div>




					<!-- ORGANIZATION -->
					<div class="control-group">
	                	<div class="control-group no-margin-bottom">
    	                	<strong>FUNDING AGENCY</strong>
	    	            </div>
    	    	        <div class="control-group" ng-show="editPeerReview.disambiguatedOrganizationSourceId">
        	    	        <label>Institution</label>
            	    	    <span id="remove-disambiguated" class="pull-right">
                	    	    <a ng-click="removeDisambiguatedOrganization()">
                    	    	    <span class="glyphicon glyphicon-remove-sign"></span><@orcid.msg 'common.remove'/>
	                        	</a>
		                    </span>
    		                <div class="relative" style="font-weight: strong;">
        		                <span ng-bind="disambiguatedOrganization.value"></span>
            		        </div>
                		</div>
	                	<div class="control-group">
    	                	<span ng-hide="disambiguatedOrganization">
        	                	   <label>Institution</label>
            	        	</span>
	                	    <span ng-show="disambiguatedOrganization">
    	                    	<label>Display institution</label>
        	            	</span>
            	    	    <div class="relative">
	                	        <input id="organizationName" class="input-xlarge" name="organizationName" type="text" ng-model="editPeerReview.orgName.value" placeholder="Type name. Select from the list to fill other fields" ng-change="serverValidate('peer-reviews/orgNameValidate.json')" ng-model-onblur/>
    		                    <span class="required" ng-class="isValidClass(editPeerReview.orgName)">*</span>
            		            <span class="orcid-error" ng-show="editPeerReview.orgName.errors.length > 0">
                    	        	<div ng-repeat='error in editPeerReview.orgName.errors' ng-bind-html="error"></div>
                        		</span>
	    	                </div>
    	    	        </div>
                		<div class="control-group">
		                    <label ng-hide="disambiguatedOrganization">City</label>
        		            <label ng-show="disambiguatedOrganization">Display city</label>
                		    <div class="relative">
		                        <input name="city" type="text" class="input-xlarge"  ng-model="editPeerReview.city.value" placeholder="Add city" ng-change="serverValidate('peer-reviews/cityValidate.json')" ng-model-onblur/>
        		                <span class="required" ng-class="isValidClass(editPeerReview.city)">*</span>
                		        <span class="orcid-error" ng-show="editPeerReview.city.errors.length > 0">
                        		    <div ng-repeat='error in editPeerReview.city.errors' ng-bind-html="error"></div>
		                        </span>
        		            </div>
		                </div>
        		        <div class="control-group">
                		    <label ng-hide="disambiguatedOrganization">Region</label>
		                    <label ng-show="disambiguatedOrganization">Display region</label>
        		            <div class="relative">
                		        <input name="region" type="text" class="input-xlarge"  ng-model="editPeerReview.region.value" placeholder="Add region" ng-change="serverValidate('peer-reviews/regionValidate.json')" ng-model-onblur/>
		                        <span class="orcid-error" ng-show="editPeerReview.region.errors.length > 0">
        	        	            <div ng-repeat='error in editPeerReview.region.errors' ng-bind-html="error"></div>
            		            </span>
                    		</div>
                		</div>
		                <div class="control-group">
        		            <label ng-hide="disambiguatedOrganization">Country</label>
                		    <label ng-show="disambiguatedOrganization">Display country</label>
		                    <div class="relative">
        		                <select id="country" class="input-xlarge" name="country" ng-model="editPeerReview.country.value" ng-change="serverValidate('peer-reviews/countryValidate.json')">
                		            <option value=""><@orcid.msg 'org.orcid.persistence.jpa.entities.CountryIsoEntity.empty' /></option>
									<#list isoCountries?keys as key>
                                    	<option value="${key}">${isoCountries[key]}</option>
									</#list>
                        		</select>
		                        <span class="required" ng-class="isValidClass(editPeerReview.country)">*</span>
        		                <span class="orcid-error" ng-show="editPeerReview.country.errors.length > 0">
                	        	    <div ng-repeat='error in editPeerReview.country.errors' ng-bind-html="error"></div>
                    		    </span>
                    		</div>
                		</div>
					</div>

































					<!-- DATE -->				
					<span><strong>COMPLETION DATE</strong></span>	
					<div class="control-group">			    		
			    		<div class="relative">					    
							<select id="year" name="month" class="col-md-4">
								<#list years?keys as key>
									<option value="${key}">${years[key]}</option>
								</#list>
				    		</select>				    	
							<select id="month" name="month" class="col-md-3">
								<#list months?keys as key>
									<option value="${key}">${months[key]}</option>
								</#list>
				    		</select>
							<select id="day" name="day"class="col-md-3">
								<#list days?keys as key>
									<option value="${key}">${days[key]}</option>
								</#list>
				    		</select>								    
			    		</div>
					</div>
					
					<!-- External identifiers -->
				    
					<span><strong>EXTERNAL IDENTIFIERS</strong></span>						 
					<div class="control-group">
						<label class="relative">Identifier type</label>
						<div class="relative">
		    				<select id="idType" name="idType" class="input-xlarge">																						 
								<option value=""><@orcid.msg 'org.orcid.jaxb.model.message.WorkExternalIdentifierType.empty' /></option>
								<#list idTypes?keys as key>
									<option value="${idTypes[key]}">${key}</option>
								</#list>
							</select> 
							<a href ng-click="" class="glyphicon glyphicon-trash grey"></a>
							<span class="orcid-error" ng-show="1 == 0">
								<div ng-bind-html="error"></div>
							</span>
						</div>	
					</div>								
						
					<div class="control-group">
						<label class="relative"><@orcid.msg 'manual_work_form_contents.labelID'/></label>
				    	<div class="relative">
							<input name="" type="text" class="input-xlarge"  />
							<span class="orcid-error" ng-show="workExternalIdentifier.workExternalIdentifierId.errors.length > 0">
								<div ng-repeat='error in workExternalIdentifier.workExternalIdentifierId.errors' ng-bind-html="error"></div>
							</span>
						</div>
						<div class="add-item-link">			
							<span><a href ng-click="addExternalIdentifier()"><i class="glyphicon glyphicon-plus-sign"></i> Add external identifier</a></span>
						</div>
					</div>
					
					
					
				</div>
	
				<!-- Right column -->
				<div class="col-md-6 col-sm-6 col-xs-12">
					<!-- URL -->	
					<div class="control-group">
				    	<label class="relative">URL</label>
				    	<div class="relative">
							<!--<input name="url" type="text" class="input-xlarge"  ng-model="something" placeholder="Add URL" ng-change="" ng-model-onblur/>-->
							<input name="url" type="text" class="input-xlarge" placeholder="Add URL"/>							
							<span class="orcid-error" ng-show="">
								<!-- <div ng-repeat='' ng-bind-html="error"></div> -->
							</span>
						</div>
					</div>
					
					
					<!-- Subject -->
					<span><strong>SUBJECT</strong></span>
					 <div class="control-group">
						<span>EXTERNAL IDENTIFIERS</span>						 
						<div class="control-group">
							<label class="relative">Identifier type</label>
							<div class="relative">
			    				<select id="idType" name="idType" class="input-xlarge">																						 
									<option value=""><@orcid.msg 'org.orcid.jaxb.model.message.WorkExternalIdentifierType.empty' /></option>
									<#list idTypes?keys as key>
										<option value="${idTypes[key]}">${key}</option>
									</#list>
								</select> 
								<a href ng-click="" class="glyphicon glyphicon-trash grey"></a>
								<span class="orcid-error" ng-show="1 == 0">
									<div ng-bind-html="error"></div>
								</span>
							</div>	
						</div>								
					</div>	
					<div class="control-group">
						<label class="relative"><@orcid.msg 'manual_work_form_contents.labelID'/></label>
				    	<div class="relative">
							<input name="" type="text" class="input-xlarge"  />
							<span class="orcid-error" ng-show="workExternalIdentifier.workExternalIdentifierId.errors.length > 0">
								<div ng-repeat='error in workExternalIdentifier.workExternalIdentifierId.errors' ng-bind-html="error"></div>
							</span>
						</div>
						<div class="add-item-link">			
							<span><a href ng-click="addExternalIdentifier()"><i class="glyphicon glyphicon-plus-sign"></i> Add external identifier</a></span>
						</div>
					</div>
					
					<div class="control-group">
			    		<label class="relative"><@orcid.msg 'manual_work_form_contents.labelworktype'/></label>
						<select id="workType" name="workType" class="input-xlarge" ng-model="editWork.workType.value" ng-options="type.key as type.value for type in types | orderBy:sortOtherLast" ng-change="clearErrors()">
						   					
						</select>
						<span class="required" ng-class="isValidClass(editWork.workType)">*</span>
						<span class="orcid-error" ng-show="editWork.workType.errors.length > 0">
							<div ng-repeat='error in editWork.workType.errors' ng-bind-html="error"></div>
						</span>
					</div>
					
					<div class="control-group">
					<label><@orcid.msg 'manual_work_form_contents.labeltitle'/></label>
				    <div class="relative">
						<input name="familyNames" type="text" class="input-xlarge"  ng-model="editWork.title.value" placeholder="<@orcid.msg 'manual_work_form_contents.add_title'/>" ng-change="serverValidate('works/work/titleValidate.json')" ng-model-onblur/>						
						<span class="required" ng-class="isValidClass(editWork.title)">*</span>						
						<span class="orcid-error" ng-show="editWork.title.errors.length > 0">
							<div ng-repeat='error in editWork.title.errors' ng-bind-html="error"></div>
						</span>
						<div class="add-item-link">
							<span ng-hide="editTranslatedTitle"><a ng-click="toggleTranslatedTitleModal()"><i class="glyphicon glyphicon-plus-sign"></i> <@orcid.msg 'manual_work_form_contents.labelshowtranslatedtitle'/></a></span>
							<span ng-show="editTranslatedTitle"><a ng-click="toggleTranslatedTitleModal()"><i class="glyphicon glyphicon-minus-sign"></i> <@orcid.msg 'manual_work_form_contents.labelhidetranslatedtitle'/></a></span>
						</div>
					</div>
				</div>

				<div id="translatedTitle">
					<span class="orcid-error" ng-show="editWork.translatedTitle.errors.length > 0">
						<div ng-repeat='error in editWork.translatedTitle.errors' ng-bind-html="error"></div>
					</span>
					<div class="control-group">
						<label><@orcid.msg 'manual_work_form_contents.labeltranslatedtitle'/></label>
						<div class="relative">
							<input name="translatedTitle" type="text" class="input-xlarge" ng-model="editWork.translatedTitle.content" placeholder="<@orcid.msg 'manual_work_form_contents.add_translated_title'/>" ng-change="serverValidate('works/work/translatedTitleValidate.json')" ng-model-onblur/>														
						</div>						
					</div>

					<div class="control-group">
						<label class="relative"><@orcid.msg 'manual_work_form_contents.labeltranslatedtitlelanguage'/></label>
						<div class="relative">						
							<select id="language" name="language" ng-model="editWork.translatedTitle.languageCode" ng-change="serverValidate('works/work/translatedTitleValidate.json')">			
								<#list languages?keys as key>
									<option value="${languages[key]}">${key}</option>
								</#list>
							</select>				
						</div>
					</div>					
				</div>
				
				<div class="control-group">
					<label><@orcid.msg 'manual_work_form_contents.journalTitle'/></label>
				    <div class="relative">
						<input name="journalTitle" type="text" class="input-xlarge"  ng-model="editWork.journalTitle.value" placeholder="<@orcid.msg 'manual_work_form_contents.add_journalTitle'/>"   ng-change="serverValidate('works/work/journalTitleValidate.json')"    ng-model-onblur/>
						<span class="orcid-error" ng-show="editWork.journalTitle.errors.length > 0">
							<div ng-repeat='error in editWork.journalTitle.errors' ng-bind-html="error"></div>
						</span>						
					</div>
				</div>	
				
				<!-- URL -->	
					<div class="control-group">
				    	<label class="relative">URL</label>
				    	<div class="relative">
							<!--<input name="url" type="text" class="input-xlarge"  ng-model="something" placeholder="Add URL" ng-change="" ng-model-onblur/>-->
							<input name="url" type="text" class="input-xlarge" placeholder="Add URL"/>						
							<span class="orcid-error" ng-show="">
								<!-- <div ng-repeat='' ng-bind-html="error"></div> -->
							</span>
						</div>
					</div>

					<div class="control-group">
                    	<button class="btn btn-primary" ng-click="addAffiliation()" ng-disabled="addingAffiliation" ng-class="{disabled:addingAffiliation}">
	                        <!--<span ng-show="" class="">Add to list</span>-->
							<!--<span ng-show="" class="">Save changes</span>-->
                        	<span>Add to list</span>
                    	</button>
                    	<button id="" class="btn close-button" ng-click="closeModal()" type="reset">Cancel</button>
                	</div>
				
				</div>
			</fn-form>			
		</div>		
</script>