<head>
    <meta charset="utf-8" />
    <title>ORCID</title>
    <meta name="description" content="">
    <meta name="author" content="ORCID">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta http-equiv="X-UA-Compatible" content="IE=Edge" />
    
    <#if springMacroRequestContext.requestUri?contains("/reset-password-email") || 
    springMacroRequestContext.requestUri?contains("/unsubscribe") ||
    springMacroRequestContext.requestUri?contains("/reactivation") >
        <meta name="referrer" content="no-referrer">
    </#if>

    <#if (noIndex)??>
        <meta name="googlebot" content="noindex">
        <meta name="robots" content="noindex">
        <meta name="BaiduSpider" content="noindex">
    </#if>
    <#if ogTitle?has_content>
        <meta property="og:title" content="${(ogTitle)!}">
    </#if>

    <#if ogDescription?has_content>
        <meta property="og:description" content="${(ogDescription)!}">
    </#if>
    <meta property="og:image" content="https:${staticCdn}/img/orcid-og-image.png">
    
    <#include "/layout/google_analytics.ftl">
    
    <script type="text/javascript">
        window.resourceBasePath = "${staticCdn}"
        var orcidVar = {};
            
        <#if (workIdsJson)??>
        orcidVar.workIds = JSON.parse("${workIdsJson}");
        </#if>
      
        <#if (affiliationIdsJson)??>
        orcidVar.affiliationIdsJson = JSON.parse("${affiliationIdsJson}");
        </#if>
      
        <#if (fundingIdsJson)??>
        orcidVar.fundingIdsJson = JSON.parse("${fundingIdsJson}");
        </#if>        
        
        orcidVar.orcidId = '${(effectiveUserOrcid)!}';
        orcidVar.lastModified = '${(lastModifiedTime?datetime)!}';
        orcidVar.orcidIdHash = '${(orcidIdHash)!}';
        orcidVar.realOrcidId = '${realUserOrcid!}';
        orcidVar.resetParams = '${(resetParams)!}';
        orcidVar.emailToReactivate = '${(email)!}';        
        orcidVar.isPasswordConfirmationRequired = ${isPasswordConfirmationRequired?c};        
        orcidVar.providerId = '${(providerId)!}';           
        orcidVar.features = JSON.parse("${featuresJson}");
        
        orcidVar.oauthUserId = "${(oauth_userId?js_string)!}";
        orcidVar.firstName = "${(RequestParameters.firstName?js_string)!}";
        orcidVar.lastName = "${(RequestParameters.lastName?js_string)!}"; 
        orcidVar.emailId = "${(RequestParameters.emailId?js_string)!}";
        orcidVar.linkRequest = "${(RequestParameters.linkRequest?js_string)!}";
        
        orcidVar.loginId = "${(request.getParameter('loginId'))!}";
        
        <#if verifiedEmail??>
            orcidVar.loginId = "${verifiedEmail}";
        </#if>
        
        <#if (developerToolsEnabled)??>            
            orcidVar.developerToolsEnabled = ${developerToolsEnabled?c};            
        <#else>
            orcidVar.developerToolsEnabled = false;
        </#if>
    </script>

    <script
            type="text/javascript"
            src="https://cdn.cookielaw.org/consent/5a6d60d3-b085-4e48-8afa-d707c7afc419/OtAutoBlock.js"
    ></script>
    <script
            type="text/javascript"
            src="https://cdn.cookielaw.org/scripttemplates/otSDKStub.js"
            charset="UTF-8"
            data-document-language="true"
            data-domain-script="5a6d60d3-b085-4e48-8afa-d707c7afc419"
    ></script>
    <script type="text/javascript">
        function OptanonWrapper() {}
    </script>

    <#include "/macros/orcid_ga.ftl">

    <link rel="stylesheet" href="${staticCdn}/css/spinner.css"/>  
    <link rel="shortcut icon" href="${staticCdn}/img/favicon.ico"/>
    <link rel="apple-touch-icon" href="${staticCdn}/img/apple-touch-icon.png" />
    
    <style type="text/css">
        /* 
        Allow angular.js to be loaded in body, hiding cloaked elements until 
        templates compile.  The !important is important given that there may be 
        other selectors that are more specific or come later and might alter display.  
         */
        [ng\:cloak], [ng-cloak], .ng-cloak {
            display: none !important;
        }
    </style>
    
    <!-- ***************************************************** -->
    <!-- Ng2 Templates - BEGIN -->
    <#include "/includes/ng2_templates/modal-ng2-template.ftl">
    <#include "/includes/ng2_templates/ext-id-popover-ng2-template.ftl">
    <#if springMacroRequestContext.requestUri?contains("/account") || springMacroRequestContext.requestUri?contains("/developer-tools") || springMacroRequestContext.requestUri?contains("/inbox") || springMacroRequestContext.requestUri?contains("/my-orcid")> 
        <#include "/includes/ng2_templates/privacy-toggle-ng2-template.ftl">
    </#if>

    <!-- Ng2 Templates - END -->
    <!-- ***************************************************** -->
</head>
