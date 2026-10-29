*** Settings ***
Documentation     [Procedure] "CB008154-Configuration_for_automated_Root_CA_certificate_parameter_with_SystemAdmin_and_SecurityAdmin_privilege"
...               [Date] "Date of creation 10-05-2022"
...               [Author] "Nupur K"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB008154"
...               [Funtion_Hash_Tags] "CMP"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] SBTS-01-ASIL
...               [Validation Date] 16-05-2022

variables         ta_e2e_bts_trs_fw
Library           Collections
Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Admin_Common_Library.robot
Library		      SSHLibrary
Library           taf.ul.trs_e2e_fw.lib.utils.cloud.cloud_interface
Resource           ${CURDIR}/resources/CB008154_Common_Keywords.robot


Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops



*** Test Cases ***

[1]CB008154-Verification_of_Configuration_for_automated_Root_CA_certificate_parameter_with_SystemAdmin_and_SecurityAdmin_privilege
	Restore all Certificate
	Perform Commissioning       scf_file=${CB008154_Configuration_autoCertDelete}     verify_bts_status=True     timeout=600     alias=default
	Sleep   120
	Create BTS Security Account from BTS Administrator Account
	Configure CMP object using BTS Security Account
	Trigger IR from BTS Security Account and Verify
	Trigger KUR from BTS Security Account and Verify
	[TEARDOWN]   Teardown Oamops           alias=bts_security
