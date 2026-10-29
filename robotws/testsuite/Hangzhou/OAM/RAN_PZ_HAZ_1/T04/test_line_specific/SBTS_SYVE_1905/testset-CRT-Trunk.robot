*** Settings ***
Documentation       Test suite for 1905
...                 Author: Hong Yuhao
...                 Contact: yuhao.hong@nokia-sbell.com
# Test Timeout    3h
Suite Teardown    Common Suite Teardown
Test Timeout    75h
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_RAT_Deletion_Addition_via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB008660-A_001_Reconfiguration_Of_Existing_Parameter_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB008660-A_002_Adding_New_Distname_Type_Parameter_With_New_Object_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB008660-A_004_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB007010-A_001_Upload_Full_Or_Part_Of_Config_Data_From_SMO_Using_Get_Config.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009451-F_001_Configure_Optimize_Recalculate_Feature_With_Multi_BTSs_In_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009451-G_001_Audit_Recommended_Feature_Configuration_Using_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB007010_B_001_CM_Validate_Configuration_Plan_From_SMO.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB012145_004_Verify_Duration_of_Pre-activate_Delta_Plan_with_Validation_Scope_Setting.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009175_006_Configure_New_Internal_Antenna_MAA_NRCELL_with_Illegal_Configuration_from_MantaRay.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter.robot
Resource    ../../test_resources/CM/CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO.robot
Resource    ../../test_resources/CM/CM__CB009175_003_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_WebEM.robot


*** Variables ***
${SRNCLAB}      SRNCLAB1025    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${SRNCLAB_9451}      SRNCLAB2002
${NETACT_CB009451}    &{${SRNCLAB_9451}}
#${SRNCLAB_5891}      SRNCLAB1057
#${NETACT_CB005891}    &{${SRNCLAB_5891}}
${SCF_ID}    01
${SKIP_PARAM_RELATION_ERRORS}    ${True}    # Should relation errors be skipped (True, False)
${COMMISSIONING_TIMEOUT}    600    # Timeout for SCF commision via ADMIN API in seconds
${COMMISSIONING_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
${VALIDATION_TIMEOUT}    70    # Timeout for SCF validation via ADMIN API in seconds
${TIMEOUT}        1000    # Timeout for Admin Get bts_id and perform commissioning keyword in seconds
${SEND_REP_PYTHON_CODE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/resources/python/UploadTCDataToRep_CRT.py
${BASE_DATA_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}
${long_str1}    [1.0] SRAN_SyVe_CB006530_006__Removal_of_an_element_in_restriction_list_and_modification_of_that_parameter_in_the_same
${long_common}    _delta_plan_via_WebEM_with_"Nemuadmin"_role_and_NetAct

*** Test Cases ***
SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32983    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${plan_id}    PLAN_TAT-20851
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_033_Verify_Radio_lock_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    32983
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct
    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_RAT_Deletion_Addition_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32975    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [2.0] SRAN_SyVe_RP002956_012_5G_RAT_Deletion_Addition_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    32975
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_RAT_Deletion_Addition_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_RAT_Deletion_Addition_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_RAT_Deletion_Addition_via_NetAct
    SyVe_CM_RP002956_5G_RAT_Deletion_Addition_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_RAT_Deletion_Addition_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB008660-A_001_Reconfiguration_Of_Existing_Parameter_From_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32969    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}
    ...    [1.0] RAN_SyVe_CB008660-A_001_CM_Reconfiguration of existing distname-type parameter from NMS
    ...    AND    Set Test Variable    ${qc_instance_id}    32969
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB008660-A_001_Reconfiguration_Of_Existing_Parameter_From_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB008660-A_001_Reconfiguration_Of_Existing_Parameter_From_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_CB008660-A_001_Reconfiguration_Of_Existing_Parameter_From_NetAct
    SyVe_CM_CB008660-A_001_Reconfiguration_Of_Existing_Parameter_From_NetAct
    [Teardown]    Run Keywords    TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB008660-A_002_Adding_New_Distname_Type_Parameter_With_New_Object_From_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32971    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CB008660-A_002_CM_Adding new distname-type parameter from NMS
    ...    AND    Set Test Variable    ${qc_instance_id}    32971
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB008660-A_002_Adding_New_Distname_Type_Parameter_With_New_Object_From_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB008660-A_002_Adding_New_Distname_Type_Parameter_With_New_Object_From_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_CB008660-A_002_Adding_New_Distname_Type_Parameter_With_New_Object_From_NetAct
    SyVe_CM_CB008660-A_002_Adding_New_Distname_Type_Parameter_With_New_Object_From_NetAct
    [Teardown]    Run Keywords    TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB008660-A_004_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32979    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}
    ...    [1.0] RAN_SyVe_CB008660-A_004_CM_Adding an object breaking (or not) existing distname unambiguity to the live NE
    ...    AND    Set Test Variable    ${qc_instance_id}    32979
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB008660-A_004_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB008660-A_004_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity
    ...    AND    Set Library Search Order    SyVe_CM_CB008660-A_004_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity
    SyVe_CM_CB008660-A_004_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity
    [Teardown]    Run Keywords    TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32980
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/restriction_parameters.yaml
    ...    AND    Set Test Variable    ${origin_scf_path}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    ...    AND    Set Test Variable    ${test_run}
    ...    [1.0] SRAN_SyVe_CB006530_005__Creation_of_restriction_rules_in_a_delta_plan_via_WebEM_with_Nemuadmin_role_and_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    32980
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct
    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct
    [Teardown]    Run Keywords    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32981
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/restriction_parameters.yaml
    ...    AND    Set Test Variable    ${origin_scf_path}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    ...    AND    Set Test Variable    ${test_run}    ${long_str1}${long_common}
    ...    AND    Set Test Variable    ${qc_instance_id}    32981
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param
    ...    AND    Set Library Search Order    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param
    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param
    [Teardown]    Run Keywords    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32978   CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [1.0] RAN_SyVe_CB008936_003_CM_Delta plan online validation in Netact with validation scope setting
    ...    AND    Set Test Variable    ${qc_instance_id}    32978
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting
    ...    AND    Set Library Search Order    SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting
    SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting
    [Teardown]    Run Keywords    SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32986   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Timeout]    72h
    [Setup]    Run Keywords      Set Test Variable    ${test_run}    [1.0] CB005809_case2_trigger_alarm_DisabledEthernetPortSecurityAl_with_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    32986
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark
    ...    AND    Set Library Search Order    SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark
    SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark
    [Teardown]    Run Keywords    SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32977    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Timeout]    72h
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${test_run}    [1.0] CB005809_case2_trigger_alarm_DisabledEthernetPortSecurityAl_with_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    32977
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS
    ...    AND    Set Library Search Order    SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS
    SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS
    [Teardown]    Run Keywords    SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB009451-F_001_Configure_Optimize_Recalculate_Feature_With_Multi_BTSs_In_NetAct
   [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32965   CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
   [Timeout]    72h
   [Setup]    Run Keywords    Set Test Variable    &{NETACT}    &{NETACT_CB009451}
   ...    AND    Set Library Search Order    XML
   ...    AND    Set Test Variable    ${test_run}
   ...    [1.0] RAN_ST_CB009451-F_001_CM_Configure optimize recalculate feature with Multi BTSs using NetAct
   ...    AND    Set Test Variable    ${qc_instance_id}    32965
   ...    AND    SyVe_CM_CB009451-F_001_Configure_Optimize_Recalculate_Feature_With_Multi_BTSs_In_NetAct.TC Setup
   ...    AND    Modify Resource Search Order    SyVe_CM_CB009451-F_001_Configure_Optimize_Recalculate_Feature_With_Multi_BTSs_In_NetAct
   ...    AND    Set Library Search Order    SyVe_CM_CB009451-F_001_Configure_Optimize_Recalculate_Feature_With_Multi_BTSs_In_NetAct
   SyVe_CM_CB009451-F_001_Configure_Optimize_Recalculate_Feature_With_Multi_BTSs_In_NetAct
   [Teardown]    Run Keywords    SyVe_CM_CB009451-F_001_Configure_Optimize_Recalculate_Feature_With_Multi_BTSs_In_NetAct.TC Teardown
   ...    AND    Restore Resource Search Order

SyVe_CM_CB009451-G_001_Audit_Recommended_Feature_Configuration_Using_NetAct
   [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32966   CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
   [Timeout]    72h
   [Setup]    Run Keywords    Set Test Variable    &{NETACT}    &{NETACT_CB009451}
   ...    AND    Set Library Search Order    XML
   ...    AND    Set Test Variable    ${test_run}    [1.0] RAN_ST_CB009451-G_001_CM_Audit recommended feature configuration using NetAct
   ...    AND    Set Test Variable    ${qc_instance_id}    32966
   ...    AND    SyVe_CM_CB009451-G_001_Audit_Recommended_Feature_Configuration_Using_NetAct.TC Setup
   ...    AND    Modify Resource Search Order    SyVe_CM_CB009451-G_001_Audit_Recommended_Feature_Configuration_Using_NetAct
   ...    AND    Set Library Search Order    SyVe_CM_CB009451-G_001_Audit_Recommended_Feature_Configuration_Using_NetAct
   SyVe_CM_CB009451-G_001_Audit_Recommended_Feature_Configuration_Using_NetAct
   [Teardown]    Run Keywords    SyVe_CM_CB009451-G_001_Audit_Recommended_Feature_Configuration_Using_NetAct.TC Teardown
   ...    AND    Restore Resource Search Order

SyVe_CM_CB007010-A_001_Upload_Full_Or_Part_Of_Config_Data_From_SMO_Using_Get_Config
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32973    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}
    ...    [1.0] RAN_ST_CB007010-A_001_CM_Upload full or part of Configuration Data from SMO using get-config operation
    ...    AND    Set Test Variable    ${qc_instance_id}    32973
    ...    AND    Set Test Variable    ${ONAP_IGNORE_PARAMS_FILE}    ${BASE_DATA_PATH}/testdata/ONAP/ONAP_IGNORE_PARAMS.yaml
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB007010-A_001_Upload_Full_Or_Part_Of_Config_Data_From_SMO_Using_Get_Config.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB007010-A_001_Upload_Full_Or_Part_Of_Config_Data_From_SMO_Using_Get_Config
    ...    AND    Set Library Search Order    SyVe_CM_CB007010-A_001_Upload_Full_Or_Part_Of_Config_Data_From_SMO_Using_Get_Config
    SyVe_CM_CB007010-A_001_Upload_Full_Or_Part_Of_Config_Data_From_SMO_Using_Get_Config
    [Teardown]    Run Keywords    SyVe_CM_CB007010-A_001_Upload_Full_Or_Part_Of_Config_Data_From_SMO_Using_Get_Config.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32992    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}
    ...    [1.0] RAN_ST_CB007010-E_004_CM_Verify CCN on O-RAN O1 interface after VES notification functionality gets enabled
    ...    AND    Set Test Variable    ${qc_instance_id}    32992
    ...    AND    Set Test Variable    ${ONAP_IGNORE_PARAMS_FILE}    ${BASE_DATA_PATH}/testdata/ONAP/ONAP_IGNORE_PARAMS.yaml
    ...    AND    Set Library Search Order    XML
    ...    AND    Modify Resource Search Order    SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed
    ...    AND    SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed.TC Setup
    ...    AND    Set Library Search Order    SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed
    SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed
    [Teardown]    Run Keywords    SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB007010_B_001_CM_Validate_Configuration_Plan_From_SMO
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32987    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${test_run}    [1.0] TA_RAN_ST_CB007010-B_B1_001_CM_Validate Configuration Plan from SMO
    ...    AND    Set Test Variable    ${qc_instance_id}    32987
    ...    AND    Modify Resource Search Order    SyVe_CM_CB007010_B_001_CM_Validate_Configuration_Plan_From_SMO
    ...    AND    Set Library Search Order    SyVe_CM_CB007010_B_001_CM_Validate_Configuration_Plan_From_SMO
    ...    AND    SyVe_CM_CB007010_B_001_CM_Validate_Configuration_Plan_From_SMO.TC SetUp
    [Timeout]      60 minutes
    TC__SyVe_CM_CB007010_B_001_CM_Validate_Configuration_Plan_From_SMO
    [Teardown]    Run Keywords    SyVe_CM_CB007010_B_001_CM_Validate_Configuration_Plan_From_SMO.TC TearDown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB012145_004_Verify_Duration_of_Pre-activate_Delta_Plan_with_Validation_Scope_Setting
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32968   CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [1.0] RAN_SyVe_CB012145_004_CM_Verify duration of pre-activate delta Plan via NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    32968
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB012145_004_Verify_Duration_of_Pre-activate_Delta_Plan_with_Validation_Scope_Setting.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB012145_004_Verify_Duration_of_Pre-activate_Delta_Plan_with_Validation_Scope_Setting
    ...    AND    Set Library Search Order    SyVe_CM_CB012145_004_Verify_Duration_of_Pre-activate_Delta_Plan_with_Validation_Scope_Setting
    SyVe_CM_CB012145_004_Verify_Duration_of_Pre-activate_Delta_Plan_with_Validation_Scope_Setting
    [Teardown]    Run Keywords    SyVe_CM_CB012145_004_Verify_Duration_of_Pre-activate_Delta_Plan_with_Validation_Scope_Setting.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_53173   CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Timeout]    72h
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${qc_instance_id}    53173
    ...    AND    Set Test Variable    ${test_run}
    ...    [1]RAN_ST_CB009175_001_CM_Configure new internal antenna MAA NRCELL Channel Groups and Channels using Simplified method from MantaRay
    ...    AND    SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay
    ...    AND    Set Library Search Order    SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay
    SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay
    [Teardown]    Run Keywords    SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB009175_006_Configure_New_Internal_Antenna_MAA_NRCELL_with_Illegal_Configuration_from_MantaRay
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_53175    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Setup]    Run Keywords    Set Test Variable    ${qc_instance_id}    53175
    ...    AND    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${test_run}
    ...    [1]RAN_ST_CB009175_006_CM_Configure new internal antenna MAA NRCELL with illegal configuration from MantaRay
    ...    AND    SyVe_CM_CB009175_006_Configure_New_Internal_Antenna_MAA_NRCELL_with_Illegal_Configuration_from_MantaRay.TC Setup
    ...    AND    Modify Resource Search Order
    ...    SyVe_CM_CB009175_006_Configure_New_Internal_Antenna_MAA_NRCELL_with_Illegal_Configuration_from_MantaRay
    ...    AND    Set Library Search Order
    ...    SyVe_CM_CB009175_006_Configure_New_Internal_Antenna_MAA_NRCELL_with_Illegal_Configuration_from_MantaRay
    [Timeout]    72h
    SyVe_CM_CB009175_006_Configure_New_Internal_Antenna_MAA_NRCELL_with_Illegal_Configuration_from_MantaRay
    [Teardown]    Run Keywords    SyVe_CM_CB009175_006_Configure_New_Internal_Antenna_MAA_NRCELL_with_Illegal_Configuration_from_MantaRay.TC TearDown
    ...    AND    Restore Resource Search Order

SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_54614    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}
    ...    [2.0] LTE4934-A_ST_05_17_CM provision to trigger CCN upload by modify create and delete parameter
    ...    AND    Set Test Variable    ${qc_instance_id}    54614
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    ...    AND    Set Library Search Order    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    TC__SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    [Teardown]    Run Keywords    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter.TC Teardown
    ...    AND    Restore Resource Search Order

CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32985    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${test_run}    [1.0] TA_RAN_ST_CB007010-C_B1_001_CM_Lock_Unlock the BTS Running Datastore from SMO
    ...    AND    Set Test Variable    ${RAT_BIT}    00110011
    ...    AND    Set Test Variable    ${qc_instance_id}    32985
    ...    AND    Modify Resource Search Order    CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO
    ...    AND    Set Library Search Order    CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO
    ...    AND    CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO.TC SetUp
    [Timeout]      2h
    TC__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO
    [Teardown]    Run Keywords    CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO.TC TearDown
    ...    AND    Restore Resource Search Order

CM__CB009175_003_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_WebEM
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_53174    CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1AHED_1AEHC_1AEHB_1FXDB_1905
    [Setup]    Run Keywords    Set Test Variable    ${qc_instance_id}    53174
    ...    AND    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${test_run}
    ...    [1][1.0] RAN_ST_CB009175_003_CM_Configure new internal antenna MAA NRCELL Channel Groups and Channels using Simplified method from WebEM
    ...    AND    Set Test Variable    ${RAT_BIT}    00110011
    ...    AND        CM__CB009175_003_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_WebEM.SetUp
    ...    AND    Modify Resource Search Order
    ...    CM__CB009175_003_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_WebEM
    ...    AND    Set Library Search Order
    ...    CM__CB009175_003_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_WebEM
    [Timeout]    72h
    CM__CB009175_003_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_WebEM
    [Teardown]    Run Keywords    CM__CB009175_003_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_WebEM.TearDown
    ...    AND    Restore Resource Search Order
