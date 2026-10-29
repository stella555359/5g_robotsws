*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_5GC_dRNIC_vDU136_O_AEQP  STATE_COMMISSIONED
Documentation  This suite contains CloudBTS TC

Resource    ../../../FM/test_resources/FM__vDU__RMOD_Fault_4590_Fault_Signature.robot
Resource    ../../../FM/test_resources/FM__vDU__RMOD_reset_counter_exceeded_FID_1901.robot
Resource    ../../../FM/test_resources/FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case.robot
Resource    ../../../FM/test_resources/FM__vDU__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset.robot

*** Test Cases ***
[1]FM__vDU__RMOD_Fault_4590_Fault_Signature
    [Tags]    QC_37569
	[Timeout]    3600
    [Setup]    Run keywords    FM__vDU__RMOD_Fault_4590_Fault_Signature.TC Setup
    ...  AND  Set Test Variable  ${RMOD_TYPE}  AHFII
    ...  AND  Set Test Variable  ${DC}  ${TRUE}
    [Teardown]    Run keywords    FM__vDU__RMOD_Fault_4590_Fault_Signature.TC Teardown
    TC__FM__vDU__RMOD_Fault_4590_Fault_Signature

[1]FM__vDU__RMOD_reset_counter_exceeded_FID_1901
    [Tags]    QC_37568
	[Timeout]    3600
    [Setup]    Run keywords    FM__vDU__RMOD_reset_counter_exceeded_FID_1901.TC Setup
    ...  AND  Set Test Variable  ${RMOD_TYPE}  AHFII
    ...  AND  Set Test Variable  ${DC}  ${TRUE}
    [Teardown]    Run keywords    FM__vDU__RMOD_reset_counter_exceeded_FID_1901.TC Teardown
    TC__FM__vDU__RMOD_reset_counter_exceeded_FID_1901

[1]FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case
    [Tags]    QC_138068
    [Setup]    Run keywords    FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case.TC Teardown
    TC__FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case

[1]FM__vDU__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset
    [Tags]    QC_220824
	[Timeout]    3600
    [Setup]    Run keywords    FM__vDU__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset.TC Setup
    ...  AND  Set Test Variable  ${RMOD_TYPE}  AHFII
    ...  AND  Set Test Variable  ${DC}  ${TRUE}
    [Teardown]    Run keywords    FM__vDU__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset.TC Teardown
    TC__FM__vDU__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset
