*** Settings ***
Documentation     [Procedure] "CB008154-SR-A-A7_Verification_of_Alarms_for_Expiry_of_Operator_Entity_and_Intermediate_CA_Certificates"
...               [Date] "Date of creation 10-05-2022"
...               [Author] "Nupur K"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB008154"
...               [Funtion_Hash_Tags] "CMP"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] SBTS-3293-ASIA
...               [Validation Date] 16-05-2022

variables         ta_e2e_bts_trs_fw
Resource          taf/rfrl/trs_e2e_fw/setup/framework.robot
Library           Collections
Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Admin_Common_Library.robot
Resource           ${CURDIR}/resources/CB008154_Common_Keywords.robot
Library		      SSHLibrary



Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***
[1]CB008154-Verification_of_Alarms_for_Expiry_of_Operator_Entity_and_Intermediate_CA_Certificates
	Restore all Certificate
	Perform Commissioning       scf_file=${Configuration_CB008154_Expiry}     verify_bts_status=True     timeout=600     alias=default
    Sleep  180
    Schedule NE Certificate Update Time for Expiry and Verify Mismatch Alarm
    Verify Alarm and Valid KUR for NE Cert Expiry
	Get Day Difference from Installed CA and Root CA Certificates
	Schedule CA Certificate Update Time and Verify Expiry Alarm

	Perform Recommissioning	     type=delta		 delta_file=${Delta_Cert_Config}		 timeout=120

	Sleep    30
	Certificate Configure     operation=install_cmp_certificate       timeout=120
        Sleep    15
	Perform Recommissioning        type=param           param_path=CMP-1:serverPort     operation=update     value=8082    timeout=60
	Sleep   15
   Schedule NE Certificate Update Time for Expiry and Verify Mismatch Alarm
	Verify failed KUR Operation
	Verify Alarm	faultid=61618	should_exist=${True}	occurrences=1


	Change CMP Configuration for Manual Installation
	Manually Install Certificates in BTS
    Schedule NE Certificate Update Time for Expiry and Verify Mismatch Alarm
    Verify Alarm for Manually Installed NE Certificate
	Get Day Difference from Installed CA and Root CA Certificates
	Schedule CA Certificate Update Time and Verify Expiry Alarm
