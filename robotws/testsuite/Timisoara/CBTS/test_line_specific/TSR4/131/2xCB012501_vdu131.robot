*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_5GC_dRNIC_vDU131_O_AEQP  STATE_COMMISSIONED
Documentation  This suite contains CloudBTS TC

Resource    ../../../WebEM/test_resources/WebEM__vDU__Clone_NR_Cell_Group_configuration.robot
Resource    ../../../WebEM/test_resources/WebEM__vDU__Cloud_Clone_Radio_Configuration.robot

*** Test Cases ***
[1]WebEM__vDU__Clone_NR_Cell_Group_configuration
    [Setup]    Run keywords    WebEM__vDU__Clone_NR_Cell_Group_configuration.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vDU__Clone_NR_Cell_Group_configuration.TC Teardown
    TC__WebEM__vDU__Clone_NR_Cell_Group_configuration

[1]WebEM__vDU__Cloud_Clone_Radio_Configuration
    [Setup]    Run keywords    WebEM__vDU__Cloud_Clone_Radio_Configuration.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vDU__Cloud_Clone_Radio_Configuration.TC Teardown
    TC__WebEM__vDU__Cloud_Clone_Radio_Configuration
