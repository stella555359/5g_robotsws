*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_5GC_dRNIC_vDU131_O_AEQP  STATE_COMMISSIONED
Documentation  This suite contains CloudBTS TC

Resource    ../../../FM/test_resources/FM__vDU_Triggering_fault_1907.robot

*** Test Cases ***
[1]FM__vDU_Triggering_fault_1907
	[Timeout]    3600
    [Setup]    Run keywords    FM__vDU_Triggering_fault_1907.TC Setup
    ...  AND  Set Test Variable  ${RMOD_TYPE}  AHFII
    ...  AND  Set Test Variable  ${DC}  ${FALSE}
    [Teardown]    Run keywords    FM__vDU_Triggering_fault_1907.TC Teardown
    TC__FM__vDU_Triggering_fault_1907
