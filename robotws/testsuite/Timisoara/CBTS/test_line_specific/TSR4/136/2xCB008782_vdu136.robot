*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_5GC_dRNIC_vDU136_O_AEQP  STATE_COMMISSIONED
Documentation  This suite contains CloudBTS TC

Resource    ../../../FM/test_resources/FM__vDU__RMOD_Fault_4590_Fault_Signature.robot
Resource    ../../../FM/test_resources/FM__vDU__RMOD_reset_counter_exceeded_FID_1901.robot

*** Test Cases ***
[1]FM__vDU__RMOD_Fault_4590_Fault_Signature
	[Timeout]    3600
    [Setup]    Run keywords    FM__vDU__RMOD_Fault_4590_Fault_Signature.TC Setup
    ...  AND  Set Test Variable  ${RMOD_TYPE}  AEQP
    ...  AND  Set Test Variable  ${DC}  ${TRUE}
    [Teardown]    Run keywords    FM__vDU__RMOD_Fault_4590_Fault_Signature.TC Teardown
    TC__FM__vDU__RMOD_Fault_4590_Fault_Signature

[1]FM__vDU__RMOD_reset_counter_exceeded_FID_1901
	[Timeout]    3600
    [Setup]    Run keywords    FM__vDU__RMOD_reset_counter_exceeded_FID_1901.TC Setup
    ...  AND  Set Test Variable  ${RMOD_TYPE}  AEQP
    ...  AND  Set Test Variable  ${DC}  ${TRUE}
    [Teardown]    Run keywords    FM__vDU__RMOD_reset_counter_exceeded_FID_1901.TC Teardown
    TC__FM__vDU__RMOD_reset_counter_exceeded_FID_1901
