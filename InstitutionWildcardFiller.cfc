<!---
InstitutionWildcardFiller.cfc
iOffice 3.0 | Copyright (c) 2013 Indiana University and Jason Baumgartner

Description: This component can modify a message string for an outgoing email or
form letter in order to replace wildcards such as %name% with the appropriate value
for the specified idnumber.  This component receives the message text before the
standard WildcardFiller.cfc, and so can both add in new logic to replace new
institution-specific replacment wildcards as well as potentially override the
standard logic by pre-emptively replacing standard wildcards.

The component implements a single public function:

1)	public String getContent(String value, Numeric idnumber, Boolean isIStart)
	This a message string institution-specific wildcards replaced.
	String value provides the original message text.
	Numeric idnumber provides the idnumber of the message recipient.
	Boolean isIStart indicates whether the message text is for display in
	iStart, in which case sensitive values such as the Limited Access PIN
	or university ID number may be masked.
--->

<cfcomponent extends="AbstractInstitutionWildcardFiller">

	<!--- This method performs a check of an values in the email object text that are %name%, %universityid%, %sevisid%, etc.
	and this is a public method so that can be returned to other processes as well --->
	
	<cffunction name="getContent" access="public" returntype="string">
	<cfargument name="content" type="string" required="true">
	<cfargument name="idnumber" type="numeric" required="true">
	<cfargument name="sensitize" type="boolean" required="false" default="false">
		
	<cfquery name="outOfCountryQuery">
		SELECT COALESCE (CONVERT( NVARCHAR(10), endDate , 101 ), 'There is no end date on file') AS UM_J1_OOC_endDate
			FROM sevisDS2019OutOfCountry A
			WHERE (A.endDate = (SELECT MAX(B.endDate) FROM sevisDS2019OutOfCountry B where A.idnumber = B.idnumber))
			AND idnumber = <cfqueryparam cfsqltype="cf_sql_integer" value="#idnumber#">
	</cfquery>
	
	<cfquery name="subjectTo212eQuery">
		SELECT CASE 
				WHEN customField1 = '0' THEN 'you are NOT SUBJECT to 212(e)'
				WHEN customField1 = '1' THEN 'you are SUBJECT to 212(e)'
				WHEN customField1 = '2' THEN 'your subjectivity to 212(e) is noted as NOT APPLICABLE'
				ELSE 'you have NOT REPORTED whether or not you are subject to 212(e)'
				END AS UM_subject_212e
			FROM jbCustomFields3 A
			WHERE (A.datestamp = (SELECT MAX(B.datestamp) FROM jbCustomFields3 B where A.idnumber = B.idnumber))
			AND idnumber = <cfqueryparam cfsqltype="cf_sql_integer" value="#idnumber#">
	</cfquery>
	
	<cfscript>
			var contentValue = content;
	</cfscript>
	
	<cfif content contains 'UM_J1_OOC_endDate'>
		<cfscript>
			var contentValue = replaceWildcard(contentValue, "%UM_J1_OOC_endDate%", outOfCountryQuery.UM_J1_OOC_endDate);
		</cfscript>
	</cfif>
	<cfif content contains 'UM_subject_212e'>
		<cfscript>
			var contentValue = replaceWildcard(contentValue, "%UM_subject_212e%", subjectTo212eQuery.UM_subject_212e);
		</cfscript>
	</cfif>
	
	<cfreturn contentValue>
	
	</cffunction>

</cfcomponent>
