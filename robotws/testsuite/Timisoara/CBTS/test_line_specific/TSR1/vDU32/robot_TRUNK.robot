*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_5GC_dRNIC_vDU32_O_AEQP  STATE_COMMISSIONED
Documentation  This suite contains CloudBTS TC


Resource    ../../../WebEM/test_resources/WebEM__vDU__Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager.robot
Resource    ../../../WebEM/test_resources/WebEM__vDU__Statistics_of_suppressed_alarms_after_DU_reset.robot
Resource    ../../../WebEM/test_resources/WebEM__vDU__Statistics_of_suppressed_minor_warning_alarms_using_M2M_rest_API.robot
Resource    ../../../WebEM/test_resources/WebEM__vDU__Run_Configuration_Validation_from_WebEM_Cloud_M2M_Interface.robot
Resource    ../../../WebEM/test_resources/WebEM__vDU__Run_Configuration_Validation_from_NMS_via_ACTION_interface.robot
Resource    ../../../WebEM/test_resources/WebEM__vDU__CW_Delete_QSFP_and_LANE_of_RANNIC_module_Delete_RANNIC_module_and_Radio_Module.robot
Resource    ../../../WebEM/test_resources/WebEM__vDU__CW_Add_a_RANNIC_module_QSFP_and_LANE.robot
Resource    ../../../WebEM/test_resources/WebEM__vCU__Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager.robot
Resource    ../../../WebEM/test_resources/WebEM__vCU__Statistics_of_suppressed_minor_warning_alarms_using_M2M_rest_API.robot
Resource    ../../../WebEM/test_resources/WebEM__vCU__Statistics_of_suppressed_alarms_after_CU_reset.robot
Resource    ../../../WebEM/test_resources/WebEM__vCU__Run_Configuration_Validation_from_NMS_via_ACTION_interface.robot
Resource    ../../../WebEM/test_resources/WebEM__vCU__Run_Configuration_Validation_from_WebEM_Cloud_M2M_Interface.robot

*** Test Cases ***
[1]WebEM__vDU__Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager
    [Tags]  QC_176972
    [Setup]    Run keywords    WebEM__vDU__Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vDU__Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager.TC Teardown
    TC__WebEM__vDU__Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager


[1]WebEM__vDU__Statistics_of_suppressed_alarms_after_DU_reset
    [Tags]  QC_176974
    [Setup]    Run keywords    WebEM__vDU__Statistics_of_suppressed_alarms_after_DU_reset.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vDU__Statistics_of_suppressed_alarms_after_DU_reset.TC Teardown
    TC__WebEM__vDU__Statistics_of_suppressed_alarms_after_DU_reset


[1]WebEM__vDU__Statistics_of_suppressed_minor_warning_alarms_using_M2M_rest_API
    [Tags]  QC_176973
    [Setup]    Run keywords    WebEM__vDU__Statistics_of_suppressed_minor_warning_alarms_using_M2M_rest_API.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vDU__Statistics_of_suppressed_minor_warning_alarms_using_M2M_rest_API.TC Teardown
    TC__WebEM__vDU__Statistics_of_suppressed_minor_warning_alarms_using_M2M_rest_API


[1]WebEM__vDU__Run_Configuration_Validation_from_WebEM_Cloud_M2M_Interface
    [Tags]  QC_242560
    [Setup]    Run keywords    WebEM__vDU__Run_Configuration_Validation_from_WebEM_Cloud_M2M_Interface.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vDU__Run_Configuration_Validation_from_WebEM_Cloud_M2M_Interface.TC Teardown
    TC__WebEM__vDU__Run_Configuration_Validation_from_WebEM_Cloud_M2M_Interface


[1]WebEM__vDU__Run_Configuration_Validation_from_NMS_via_ACTION_interface
    [Tags]  QC_242558
    [Setup]    Run keywords
    ...  Set Test Variable  ${NETACT_IP}  10.8.103.177
    ...  AND  WebEM__vDU__Run_Configuration_Validation_from_NMS_via_ACTION_interface.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vDU__Run_Configuration_Validation_from_NMS_via_ACTION_interface.TC Teardown
    TC__WebEM__vDU__Run_Configuration_Validation_from_NMS_via_ACTION_interface


[1]WebEM__vDU__CW_Delete_QSFP_and_LANE_of_RANNIC_module_Delete_RANNIC_module_and_Radio_Module
    [Tags]  QC_242570
    [Setup]    Run keywords    WebEM__vDU__CW_Delete_QSFP_and_LANE_of_RANNIC_module_Delete_RANNIC_module_and_Radio_Module.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vDU__CW_Delete_QSFP_and_LANE_of_RANNIC_module_Delete_RANNIC_module_and_Radio_Module.TC Teardown
    TC__WebEM__vDU__CW_Delete_QSFP_and_LANE_of_RANNIC_module_Delete_RANNIC_module_and_Radio_Module


[1]WebEM__vDU__CW_Add_a_RANNIC_module_QSFP_and_LANE
    [Tags]  QC_242573
    [Setup]    Run keywords    WebEM__vDU__CW_Add_a_RANNIC_module_QSFP_and_LANE.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vDU__CW_Add_a_RANNIC_module_QSFP_and_LANE.TC Teardown
    TC__WebEM__vDU__CW_Add_a_RANNIC_module_QSFP_and_LANE


[1]WebEM__vCU__Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager
    [Tags]  QC_176968
    [Setup]    Run keywords    WebEM__vCU__Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vCU__Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager.TC Teardown
    TC__WebEM__vCU__Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager


[1]WebEM__vCU__Statistics_of_suppressed_minor_warning_alarms_using_M2M_rest_API
    [Tags]  QC_176969
    [Setup]    Run keywords    WebEM__vCU__Statistics_of_suppressed_minor_warning_alarms_using_M2M_rest_API.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vCU__Statistics_of_suppressed_minor_warning_alarms_using_M2M_rest_API.TC Teardown
    TC__WebEM__vCU__Statistics_of_suppressed_minor_warning_alarms_using_M2M_rest_API


[1]WebEM__vCU__Statistics_of_suppressed_alarms_after_CU_reset
    [Tags]  QC_176970
    [Setup]    Run keywords    WebEM__vCU__Statistics_of_suppressed_alarms_after_CU_reset.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vCU__Statistics_of_suppressed_alarms_after_CU_reset.TC Teardown
    TC__WebEM__vCU__Statistics_of_suppressed_alarms_after_CU_reset


[1]WebEM__vCU__Run_Configuration_Validation_from_NMS_via_ACTION_interface
    [Tags]  QC_242559
    [Setup]    Run keywords
    ...  Set Test Variable  ${NETACT_IP}  10.8.103.177
    ...  AND  WebEM__vCU__Run_Configuration_Validation_from_NMS_via_ACTION_interface.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vCU__Run_Configuration_Validation_from_NMS_via_ACTION_interface.TC Teardown
    TC__WebEM__vCU__Run_Configuration_Validation_from_NMS_via_ACTION_interface


[1]WebEM__vCU__Run_Configuration_Validation_from_WebEM_Cloud_M2M_Interface
    [Tags]  QC_242562
    [Setup]    Run keywords    WebEM__vCU__Run_Configuration_Validation_from_WebEM_Cloud_M2M_Interface.TC Setup
	[Timeout]    3600
    [Teardown]    Run keywords    WebEM__vCU__Run_Configuration_Validation_from_WebEM_Cloud_M2M_Interface.TC Teardown
    TC__WebEM__vCU__Run_Configuration_Validation_from_WebEM_Cloud_M2M_Interface