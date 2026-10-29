*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_5GC_dRNIC_vDU134_O_AEQP  STATE_COMMISSIONED
Documentation  This suite contains CloudBTS TC

Resource    ../../../WebEM/test_resources/WebEM__vCU__Common_Time_Format_On_WebEM_UI.robot
Resource    ../../../WebEM/test_resources/WebEM__vDU__Cloud_Plan_Objects_Parameters_in_Parameter_Editor.robot
Resource    ../../../WebEM/test_resources/WebEM__vDU__Compare_Managed_Objects_for_vDU.robot

*** Test Cases ***
[1]WebEM__vCU__Common_Time_Format_On_WebEM_UI
    [Setup]    Run keywords    WebEM__vCU__Common_Time_Format_On_WebEM_UI.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vCU__Common_Time_Format_On_WebEM_UI.TC Teardown
    TC__WebEM__vCU__Common_Time_Format_On_WebEM_UI

[1]WebEM__vDU__Cloud_Plan_Objects_Parameters_in_Parameter_Editor
    [Setup]    Run keywords    WebEM__vDU__Cloud_Plan_Objects_Parameters_in_Parameter_Editor.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vDU__Cloud_Plan_Objects_Parameters_in_Parameter_Editor.TC Teardown
    TC__WebEM__vDU__Cloud_Plan_Objects_Parameters_in_Parameter_Editor

[1]WebEM__vDU__Compare_Managed_Objects_for_vDU
    [Setup]    Run keywords    WebEM__vDU__Compare_Managed_Objects_for_vDU.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vDU__Compare_Managed_Objects_for_vDU.TC Teardown
    TC__WebEM__vDU__Compare_Managed_Objects_for_vDU

