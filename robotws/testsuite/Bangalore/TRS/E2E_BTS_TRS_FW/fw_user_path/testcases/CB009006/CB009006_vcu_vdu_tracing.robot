*** Settings ***
Documentation     [Procedure] "CB009006-CR_Verification_of_Cplane_and_Uplane_DSCP_tagging_vCU_and_vDU"
...               [Date] "Date of creation 01-05-2024"
...               [Author] "Pranitha"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB009006-C"
...               [Funtion_Hash_Tags] "Cloud RAN Troubleshooting"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] VCU/VDU

Resource          ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB009006_common_keywords.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops     dut=cbts     alias=vdu
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops     dut=cbts     alias=vdu

*** Variables ***
${Profile}		airphone_DualStack_sansa

*** Test Cases ***
[1]CB009006-CR_Verification_of_Cplane_and_Uplane_DSCP_tagging_vDU
	Configure remote syslog server and verify	vDU
	modify uplane tracing and verify dscp		vDU
	modify cplane tracing and verify dscp		vDU


[1]CB009006-CR_Verification_of_Cplane_and_Uplane_DSCP_tagging_vCU
	Configure remote syslog server and verify	vCU
	modify uplane tracing and verify dscp		vCU
	modify cplane tracing and verify dscp		vCU