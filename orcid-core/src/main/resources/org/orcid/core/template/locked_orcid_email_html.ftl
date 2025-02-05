<#import "email_macros.ftl" as emailMacros />
<#escape x as x?html>
<!DOCTYPE html>
<html>
	<head>
	<title>${subject}</title>
	</head>
	<body>
		<div style="padding: 20px; padding-top: 0px;">
			<img src="https://orcid.org/sites/all/themes/orcid/img/orcid-logo.png" alt="ORCID.org"/>
			<hr />
			<span style="font-family: arial, helvetica, sans-serif; font-size: 15px; color: #494A4C; font-weight: bold;">
					<@emailMacros.msg "email.common.dear" /><@emailMacros.space />${emailName}<@emailMacros.msg "email.common.dear.comma" />
				</span>
			<p style="font-family: arial, helvetica, sans-serif; font-size: 15px; color: #494A4C;">
				<#if features["HTTPS_IDS"]?? && features["HTTPS_IDS"]>
					<@emailMacros.msg "email.locked.this_is_an_important_message.1" /><a href="${baseUri}/${orcid}?lang=${locale}">${baseUri}/${orcid}</a><@emailMacros.msg "email.locked.this_is_an_important_message.2" />
				<#else>
					<@emailMacros.msg "email.locked.this_is_an_important_message.1" /><a href="${baseUriHttp}/${orcid}?lang=${locale}">${baseUriHttp}/${orcid}</a><@emailMacros.msg "email.locked.this_is_an_important_message.2" />
				</#if>
			</p>
			<p style="font-family: arial, helvetica, sans-serif; font-size: 15px; color: #494A4C;">
				<@emailMacros.msg "email.locked.the_orcid_registry_provides" />
			</p>
			<p style="font-family: arial, helvetica, sans-serif; font-size: 15px; color: #494A4C;">
				<@emailMacros.msg "email.locked.if_you_believe_html" />
			</p>
			<p style="font-family: arial,  helvetica, sans-serif;font-size: 15px;color: #494A4C; white-space: pre;">
<@emailMacros.msg "email.common.warm_regards" />
<a href='<@emailMacros.msg "email.common.need_help.description.2.href" />' target="orcid.contact_us"><@emailMacros.msg "email.common.need_help.description.2.href" /></a>
			</p>
			<p style="font-family: arial,  helvetica, sans-serif;font-size: 15px;color: #494A4C;">
				<a href="${baseUri}/home?lang=${locale}">${baseUri}/</a>
			</p>
			<p style="font-family: arial,  helvetica, sans-serif;font-size: 15px;color: #494A4C;">
				<@emailMacros.msg "email.common.you_have_received_this_email" />
			</p>
			<p style="font-family: arial,  helvetica, sans-serif;font-size: 15px;color: #494A4C;">
				<small>
					<a href="${baseUri}/account" target="_blank" style="color: #2E7F9F;"><@emailMacros.msg "email.common.email.preferences" /></a>
					| <a href="${baseUri}/privacy-policy" target="_blank" style="color: #2E7F9F;"><@emailMacros.msg "email.common.privacy_policy" /></a>
					| <@emailMacros.msg "email.common.address1" /><@emailMacros.space />|<@emailMacros.space /><@emailMacros.msg "email.common.address2" />
					| <a href="${baseUri}" target="_blank" style="color: #2E7F9F;">ORCID.org</a>
				</small>
			</p>
		</div>
	</body>
</html>
</#escape>
