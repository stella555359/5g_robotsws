*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_5GC_dRNIC_vDU136_O_AEQP  STATE_COMMISSIONED
Documentation  This suite contains CloudBTS TC

Resource    ../../../FM/test_resources/FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case.robot

*** Test Cases ***
[1]FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case
    [Setup]    Run keywords    FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case.TC Teardown
    TC__FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case
