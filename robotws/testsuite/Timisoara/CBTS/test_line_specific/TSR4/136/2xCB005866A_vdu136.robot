*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_5GC_dRNIC_vDU136_O_AEQP  STATE_COMMISSIONED
Documentation  This suite contains CloudBTS TC

Resource    ../../../WebEM/test_resources/WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell.robot
Resource    ../../../WebEM/test_resources/WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell_group.robot

*** Test Cases ***
[1]WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell
    [Setup]    Run keywords    WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell.TC Teardown
    TC__WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell

[1]WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell_group
    [Setup]    Run keywords    WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell_group.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell_group.TC Teardown
    TC__WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell_group
