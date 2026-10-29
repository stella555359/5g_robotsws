*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_5GC_dRNIC_vDU136_O_AEQP  STATE_COMMISSIONED
Documentation  This suite contains CloudBTS TC

Resource    ../../../FM/test_resources/FM__vDU__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset.robot

*** Test Cases ***
[1]FM__vDU__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset
	[Timeout]    3600
    [Setup]    Run keywords    FM__vDU__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset.TC Setup
    ...  AND  Set Test Variable  ${RMOD_TYPE}  AHFII
    ...  AND  Set Test Variable  ${DC}  ${TRUE}
    [Teardown]    Run keywords    FM__vDU__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset.TC Teardown
    TC__FM__vDU__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset
