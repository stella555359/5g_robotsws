*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_5GC_dRNIC_vDU136_O_AEQP  STATE_COMMISSIONED
Documentation  This suite contains CloudBTS TC

Resource    ../../../WebEM/test_resources/WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell.robot
Resource    ../../../WebEM/test_resources/WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell_group.robot
Resource    ../../../WebEM/test_resources/WebEM__vDU__Clone_NR_Cell_Group_configuration.robot
Resource    ../../../WebEM/test_resources/WebEM__vDU__Cloud_Clone_Radio_Configuration.robot

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

[1]WebEM__vDU__Clone_NR_Cell_Group_configuration
    [Tags]    QC_175074
	[Setup]    Run keywords    WebEM__vDU__Clone_NR_Cell_Group_configuration.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vDU__Clone_NR_Cell_Group_configuration.TC Teardown
    TC__WebEM__vDU__Clone_NR_Cell_Group_configuration

[1]WebEM__vDU__Cloud_Clone_Radio_Configuration
    [Tags]    QC_175073
	[Setup]    Run keywords    WebEM__vDU__Cloud_Clone_Radio_Configuration.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vDU__Cloud_Clone_Radio_Configuration.TC Teardown
    TC__WebEM__vDU__Cloud_Clone_Radio_Configuration