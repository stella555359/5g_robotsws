*** Settings ***
Documentation
...		[Author]     		        "Pranitha"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "09:05:2022"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB005999"
...     [Validated_TestLine]        "KVM58-TRSIV-TL3297"
...		[Procedure]   		        "CB005999_Verification of Additional intermediate CA and TA Certificates"
...     [Precondition]              "ASIB + ASIB hardware is required"
...     [Config]    	            "CRLH-1 param should be configured in SCF"
...     [Function_Hash_Tags]        "ECDSA, RSA, Certificates, CMP Configuration"

#Force Tags           CA_E2ET_BTSTRSPZ       [SBTS00]     4G_FDD      QCD_MN_RAN     QCP_RAN_ET        CRT


variables       ta_e2e_bts_trs_fw
Resource         taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource    	${CURDIR}/../resources/Admin_Common_Library.robot


Suite Setup       Run Keywords    Suite Setup Preconditions
        ...     AND         Setup Oamops
Suite Teardown    Run Keywords    Suite Teardown Postconditions
        ...     AND         Teardown Oamops

*** Test Cases ***
[1]CB005999_Verification of Additional intermediate CA and P12 Certificates Manually
    Restore all Certificate
	TA/PEM Certificate Installation
	P12 ecdsa certificate install  ${ECDSA_Cert}  ${ECDSA_Cert_Password}
	Instal Additional certificates
	Install already installed certificate
	Install expired certificate
	Delete installed certificate

*** Keywords ***
TA/PEM Certificate Installation
	Certificate Configure	  key_pool_type=ECDSA 		operation=install_certificate
	...		cert_file=${CMPECDSA_TA}		cert_type=AdditionalCa		cert_format=PEM
    Sleep   60
    ${certificate_Detail_TA}=		certificate configure 		operation=get_certificate_details
	...		source=Operator	    Subject=CMPECDSA_TA	    type=TrustAnchor
    log     ${certificate_Detail_TA}

P12 ecdsa certificate install
	[Arguments]   ${ECDSA_Cert}  ${ECDSA_Cert_Password}
    Run Keyword and Expect Error   *Wrong p12 file password*    Certificate Configure     key_pool_type=RSA    operation=install_certificate
	...    cert_file=${ECDSA_Cert}  cert_type=BtsTrustChain    cert_format=P12     password=${ECDSA_Password}
	Certificate Configure     key_pool_type=RSA    operation=install_certificate    cert_file=${ECDSA_Cert}  cert_type=BtsTrustChain
	...    cert_format=P12     password=${ECDSA_Cert_Password}
	Sleep   15

Instal Additional certificates
	Certificate Configure	  key_pool_type=ECDSA 		operation=install_certificate		cert_file=${ECDSATest1}
	...		cert_type=AdditionalCa		cert_format=PEM
    Sleep   60
	Certificate Configure	  key_pool_type=ECDSA 		operation=install_certificate		cert_file=${ta1}
	...		cert_type=AdditionalCa		cert_format=PEM
    Sleep   60
    ${certificate_Detail_TA}=       certificate configure       operation=get_certificate_details       source=Operator
	...     Subject=lte_3065_ded_man_enbta1     type=TrustAnchor
    ${certificate_Detail_TA}=       certificate configure       operation=get_certificate_details       source=Operator
	...     Subject=ECDSATest1     type=TrustAnchor

Install already installed certificate
	Run Keyword and Expect Error 	*Failed: Duplicate certificate found/error*	  Certificate Configure	   		operation=install_certificate
	...		cert_file=${CMPECDSA_TA}		cert_type=AdditionalCa		cert_format=PEM
    Sleep   60

Install expired certificate
	Run Keyword and Expect Error 	*Failed: Certificate validation - Certificate expired*	    Certificate Configure	  key_pool_type=ECDSA
	... 		operation=install_certificate		cert_file=${ECDSATest1_exprired}		cert_type=AdditionalCa		cert_format=PEM
    Sleep   60

Check invalid keylength
	Run Keyword and Expect Error	*Failed: Certificate validation*   	Certificate Configure	key_pool_type=ECDSA   operation=install_certificate
	...		cert_file=${certecdsa112}		cert_type=AdditionalCa		cert_format=PEM
	Sleep   60

Install empty certificate
	Run Keyword and Expect Error 	*Wrong Certificate data/format/invalid PKCS12/PEM*		Certificate Configure	  key_pool_type=ECDSA
	... 		operation=install_certificate		cert_file=${ECDSATest1_empty}		cert_type=AdditionalCa		cert_format=PEM
    Sleep   60

Check maxlength
	Run Keyword and Expect Error 	*Failed: Certificate exceeding maximum size*	Certificate Configure	  key_pool_type=ECDSA
	... 		operation=install_certificate		cert_file=${ECDSA_maxlengh}		cert_type=AdditionalCa		cert_format=PEM
    Sleep   60

Delete installed certificate
    certificate configure    operation=delete_cert  	source=Operator		subject=lte_3065_ded_man_enbta1		type=TrustAnchor
    Sleep   20
    certificate configure    operation=delete_cert      source=Operator     subject=CMPECDSA_TA     type=TrustAnchor
    Sleep   20
    certificate configure    operation=delete_cert      source=Operator     subject=ECDSATest1     type=TrustAnchor
    Sleep   20

Restore all Certificate
	certificate configure          operation=restore_vendor_certificate
	Sleep   10
	certificate configure          operation=delete_cert        all_certs=${True}
	Sleep   10