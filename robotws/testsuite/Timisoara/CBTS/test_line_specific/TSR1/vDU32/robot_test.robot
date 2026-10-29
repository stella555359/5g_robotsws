*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_5GC_dRNIC_vDU32_O_AEQP  STATE_COMMISSIONED
Documentation  This suite contains CloudBTS TC

Resource    ../../../WebEM/test_resources/WebEM__vDU__Rad_debug_parameters_M2M_interface.robot
Resource    ../../../WebEM/test_resources/WebEM__vCU__Rad_debug_parameters_M2M_interface.robot

*** Test Cases ***
[1]WebEM__vDU__Rad_debug_parameters_M2M_interface
    [Setup]    Run keywords    WebEM__vDU__Rad_debug_parameters_M2M_interface.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vDU__Rad_debug_parameters_M2M_interface.TC Teardown
    TC__WebEM__vDU__Rad_debug_parameters_M2M_interface

[1]WebEM__vCU__Rad_debug_parameters_M2M_interface
    [Setup]    Run keywords    WebEM__vCU__Rad_debug_parameters_M2M_interface.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vCU__Rad_debug_parameters_M2M_interface.TC Teardown
    TC__WebEM__vCU__Rad_debug_parameters_M2M_interface
