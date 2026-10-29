*** Settings ***
Documentation
...     [Procedure]    			 	"modify_security_algorithms_supported_by_ENode_B"
...     [Author]        	 		"jyotsna"
...     [Maintenance]   	 		"TRS I & V Tools Bangalore Team"
...     [QC_Path]       	 		"QC_Path in Test Plan"
...     [QC_ID]         	 		""
...     [Feature_ID]    	 		""
...     [Funtion_Hash_Tags]  		"p12 Certification installed on webem"
...     [Validated_TestLine]    	"2202"
...     [Config]    				""
...     [Runtime param]   			"bts_id is provided at run time."

Force Tags       CLOUD_R4P  CA_E2ET_BTSTRSPZ        SBTS00        [SBTS23R1]     RAN_4G    RAN_4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
Suite Teardown     Run Keywords        Suite Teardown Postconditions
...        AND     Teardown Oamops


*** Variables ***
${juniper_certificate}        /home/ute/Downloads/test.p12
${btsTrustChain}              BtsTrustChain
${p12}                        P12
${pswd}                       nokia

 

*** Test Cases  ***
[1][1.0] modify security algorithms supported by E-Node-B
    check the p12 certificate

 

*** Keywords ***
check the p12 certificate    
    Certificate Configure     key_pool_type=RSA    operation=install_certificate    cert_file=${juniper_certificate}
    ...    cert_type=${btsTrustChain}    cert_format=${p12}     password=${pswd}
