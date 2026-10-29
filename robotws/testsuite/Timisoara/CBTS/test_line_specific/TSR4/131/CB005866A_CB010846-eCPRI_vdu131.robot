*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_5GC_dRNIC_vDU131_O_AEQP  STATE_COMMISSIONED
Documentation  This suite contains CloudBTS TC

Resource    ../../../WebEM/test_resources/WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell.robot
Resource    ../../../WebEM/test_resources/WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell_group.robot
Resource    ../../../FM/test_resources/FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case.robot

*** Test Cases ***
[1]WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell
    [Tags]    QC_37575
    [Setup]    Run keywords    WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell.TC Teardown
    TC__WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell

[1]WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell_group
    [Tags]    QC_37574
    [Setup]    Run keywords    WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell_group.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell_group.TC Teardown
    TC__WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell_group

[1]FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case
    [Tags]    QC_138069
    [Setup]    Run keywords    FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case.TC Teardown
    TC__FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case
