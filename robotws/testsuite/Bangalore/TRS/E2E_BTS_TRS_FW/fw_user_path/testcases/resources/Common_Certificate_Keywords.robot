*** Settings ***
Documentation
...            [Author]     "Savithri"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"

Library        OperatingSystem
Library		   Collections
Library    	   String
Library        XML     use_LXML=true
Resource       ${CURDIR}/Admin_Common_Library.robot

*** Variables ***
${Configure_CMP}			${CURDIR}/Configure_CMP.xml


*** Keywords ***
Add Additional cert in Admin
	[Arguments]		${cert_file}		${type}		${format}		${password}=None
	Setup Admin		bts_host=192.168.255.129	bts_port=443	use_ssl=True
	Install Certificate		${cert_file}	${type}		${format}		${password}
	[Teardown]		Teardown Admin

Initialize CMP Certificate
	Setup Admin		bts_host=192.168.255.129	bts_port=443	use_ssl=True
	Cmp Initialize Certificate
	[Teardown]		Teardown Admin

Restore Vendor Certificate Using Admin
	Setup admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True
	Restore Vendor Certificate
	[Teardown]    Teardown Admin

Update Certificate Revocation List Using Admin
	Setup admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True
	Update Certificate Revocation List
	[Teardown]    Teardown Admin

Configure Primary CMP
	[Arguments]			${SubjectName}=CN=ute_auto_ldap_ca1.3		${CMP_IP}=10.62.65.164		${PortNumber}=8081
	Run     sudo sed -i 's/{{CMP_IP}}/${CMP_IP}/g' ${Configure_CMP}
	Run     sudo sed -i 's/{{SubjectName}}/${SubjectName}/g' ${Configure_CMP}
	Run     sudo sed -i 's/{{PortNumber}}/${PortNumber}/g' ${Configure_CMP}
	Perform ENB Recommissioning without reset	${Configure_CMP}

Configure Secondary CMP
	[Arguments]			${secondarySubjectName}		${secondaryCMP_IP}		 ${secondaryPortNumber}=8081
	Perform Parameter commissioning without reset			MRBTS-1/MNL-1/CERTH-1/CMP-1:secondaryCaSubjectName:update:${secondarySubjectName}
	Perform Parameter commissioning without reset			MRBTS-1/MNL-1/CERTH-1/CMP-1:secondaryServerHost:update:${secondaryCMP_IP}
	Perform Parameter commissioning without reset			MRBTS-1/MNL-1/CERTH-1/CMP-1:secondaryServerPort:update:${secondaryPortNumber}


Install Certificate Using Admin
	[Arguments]				${Cert_File_Path}		${Cert_type}		${Cert_Format}			${Password}=None
	Setup admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True
	Install Certificate			${Cert_File_Path}			${Cert_type}		${Cert_Format}			${Password}
	[Teardown]    Teardown Admin

Initialize CMP Certificate Using Admin
	Setup admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True
	Install Cmp Certificate
	[Teardown]    Teardown Admin

CMP Key Update Using Admin
	Setup admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True
	Cmp Update Key		timeout=350
	[Teardown]    Teardown Admin

Get Certificate List Using Admin
	[Arguments]			${Certificate_type}=BTS			${timeout}=60
	Setup admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True
	@{Certificate_Detail_List}=		Get Certificate List			${Certificate_type}				${timeout}
	RETURN		${Certificate_Detail_List}
	[Teardown]    Teardown Admin

Enable Automatic Certificate Management
	[Arguments]			${referenceNumber}			${preSharedKey}			${timeout}=60
	Setup admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True
	Set Certificate Automatic Managment			${referenceNumber}			${preSharedKey}			${timeout}
	[Teardown]    Teardown Admin

Get Certificate Revocation List Using Admin
	Setup admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True
	${stdout}=			Get Certificate Revocation List
	Set Suite Variable    ${stdout}
	[Teardown]    Teardown Admin

Verify If CMP is State in Admin WEBUI
	[Arguments]			${expected_cmp_state}
	Download BTS_TRS File from eNB
	${cmp_state}=		Get Element Text   /tmp/192.168.255.129_scf.xml
	...               .//managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/CERTHENT-1/CMP_R-1"]/p[@name="state"]
	Should Contain		'${cmp_state}'		'${expected_cmp_state}'
