*** Settings ***
Documentation       Test suite for SBTS1894
...                 Author: lixkang
...                 Contact: lixin.kang@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout    32h
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell.robot
Resource    ../../test_resources/SyVe/SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Lock_Unlock_NR_RAT_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Fallback_Check.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB008660-A_001_Reconfiguration_Of_Existing_Parameter_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB008660-A_002_Adding_New_Distname_Type_Parameter_With_New_Object_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB008660-A_004_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB007010-E_001_Verify_CCN_On_O-RAN_O1_When_Provision_Delta_Plan_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB007010-A_014_Enable_And_Disable_O_RAN_O1_NetConf_Server_On_NE.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB007010-A_002_Upload_Full_Or_Part_Of_Config_Data_And_States_From_SMO_Using_Get.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB007010-B_003_Provision_Delta_Plan_For_SBTS_From_SMO.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB007010-B_006_STATE_HW_BBMOD_Reset_Request_To_SBTS_Via_HWRESETREQ_From_SMO.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB007010-A_001_Upload_Full_Or_Part_Of_Config_Data_From_SMO_Using_Get_Config.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB008708_001_Verify_NE3S_Feedback_when_Recovery_Reset_is_Executed_via_NMS_Action_Provision.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB013998_002_005_Modify_Parameter_With_Cell_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009451-F_001_Configure_Optimize_Recalculate_Feature_With_Multi_BTSs_In_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009451-G_001_Audit_Recommended_Feature_Configuration_Using_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_Different_Impact_Parameters.robot
Resource    ../../test_resources/CM/CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor.robot
Resource    ../../test_resources/CM/CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Fullrack_Uncommissioned_Secondary_Core.robot
Resource    ../../test_resources/CM/CM__CB012098_001_PDL_Validation_Run_For_Prepared_Target_Configuration_via_WebEM.robot
Resource    ../../test_resources/CM/CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1025    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${SRNCLAB_9451}      SRNCLAB1015
${NETACT_CB009451}    &{${SRNCLAB_9451}}
${SCF_ID}         01
${SKIP_PARAM_RELATION_ERRORS}    ${True}    # Should relation errors be skipped (True, False)
${COMMISSIONING_TIMEOUT}    600    # Timeout for SCF commision via ADMIN API in seconds
${COMMISSIONING_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
${VALIDATION_TIMEOUT}    70    # Timeout for SCF validation via ADMIN API in seconds
${TIMEOUT}        1000    # Timeout for Admin Get bts_id and perform commissioning keyword in seconds
${SEND_REP_PYTHON_CODE_PATH}
...    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/python/UploadTCDataToRep_CRT.py
${BASE_DATA_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}
${ADDPARAM_FILE_PATH_CB009451}
...    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/T04/test_line_specific/SBTS_SYVE_1894/additionalInfo.csv
${REPEAT_TIME}    1

*** Test Cases ***
SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32952    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RP002086_CM_044_Provision SBTS plan to delete and add LTE cell
    ...    AND    Set Test Variable    ${qc_instance_id}    32952
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    [Teardown]    Run Keywords    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_98741    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${plan_info}    PLAN_TAT-19721
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_LTE_RAT_STATUS}    False
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_5G_RAT_STATUS}    False
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Verify_SWRESETREQ_With_RAT_Reset_LTE3296_SR001610
    ...    AND    Set Test Variable    ${qc_instance_id}    98741
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset
    ...    AND    Set Library Search Order    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset
    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset
    [Teardown]    Run Keywords    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF   QC_32949   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    2h
    [Setup]    Run Keywords      Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_016_5G_Cell_Deletion_Addition_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    32949
    ...    AND    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${plan_path}
    ...    ${BASE_DATA_PATH}/commissioning/NR_Cell_Delete_And_Add.xml
    ...    AND    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32955    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_022_Verify_5G_Cell_Lock_Unlock_via_NetAct CM
    ...    AND    Set Test Variable    ${qc_instance_id}    32955
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct
    SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32954    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_039_Verify_BBMOD_lock_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    32954
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct
    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Lock_Unlock_NR_RAT_From_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32948    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_043_Verify_5G_RAT_lock_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    32948
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Lock_Unlock_NR_RAT_From_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Lock_Unlock_NR_RAT_From_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Lock_Unlock_NR_RAT_From_NetAct
    SyVe_CM_RP002956_5G_Lock_Unlock_NR_RAT_From_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Lock_Unlock_NR_RAT_From_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Fallback_Check
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32961   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    2h
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CM_fallback_check
    ...    AND    Set Test Variable    ${qc_instance_id}    32961
    ...    AND    SyVe_CM_Fallback_Check.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Fallback_Check
    ...    AND    Set Library Search Order    SyVe_CM_Fallback_Check
    TC__SyVe_CM_Fallback_Check
    [Teardown]    Run Keywords    SyVe_CM_Fallback_Check.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262746   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [1.0] RAN_SyVe_CB008936_003_CM_Delta plan online validation in Netact with validation scope setting
    ...    AND    Set Test Variable    ${qc_instance_id}    262746
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting
    ...    AND    Set Library Search Order    SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting
    SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting
    [Teardown]    Run Keywords    SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB008660-A_001_Reconfiguration_Of_Existing_Parameter_From_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262745    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}
    ...    [1.0] RAN_SyVe_CB008660-A_001_CM_Reconfiguration of existing distname-type parameter from NMS
    ...    AND    Set Test Variable    ${qc_instance_id}    262745
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB008660-A_001_Reconfiguration_Of_Existing_Parameter_From_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB008660-A_001_Reconfiguration_Of_Existing_Parameter_From_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_CB008660-A_001_Reconfiguration_Of_Existing_Parameter_From_NetAct
    SyVe_CM_CB008660-A_001_Reconfiguration_Of_Existing_Parameter_From_NetAct
    [Teardown]    Run Keywords    TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB008660-A_004_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262747    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}
    ...    [1.0] RAN_SyVe_CB008660-A_004_CM_Adding an object breaking (or not) existing distname unambiguity to the live NE
    ...    AND    Set Test Variable    ${qc_instance_id}    262747
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB008660-A_004_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB008660-A_004_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity
    ...    AND    Set Library Search Order    SyVe_CM_CB008660-A_004_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity
    SyVe_CM_CB008660-A_004_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity
    [Teardown]    Run Keywords    TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262751    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}
    ...    [1.0] RAN_ST_CB007010-E_004_CM_Verify CCN on O-RAN O1 interface after VES notification functionality gets enabled
    ...    AND    Set Test Variable    ${qc_instance_id}    262751
    ...    AND    Set Test Variable    ${ONAP_IGNORE_PARAMS_FILE}    ${BASE_DATA_PATH}/testdata/ONAP/ONAP_IGNORE_PARAMS.yaml
    ...    AND    Set Library Search Order    XML
    ...    AND    Modify Resource Search Order    SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed
    ...    AND    SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed.TC Setup
    ...    AND    Set Library Search Order    SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed
    SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed
    [Teardown]    Run Keywords    SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed.TC Teardown
    ...    AND    Restore Resource Search Order

CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262752    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${test_run}    [1.0] TA_RAN_ST_CB007010-C_B1_001_CM_Lock_Unlock the BTS Running Datastore from SMO
    ...    AND    Set Test Variable    ${RAT_BIT}    00110011
    ...    AND    Set Test Variable    ${qc_instance_id}    262752
    ...    AND    Modify Resource Search Order    CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO
    ...    AND    Set Library Search Order    CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO
    ...    AND    CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO.TC SetUp
    [Timeout]      2h
    TC__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO
    [Teardown]    Run Keywords    CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO.TC TearDown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB007010-A_002_Upload_Full_Or_Part_Of_Config_Data_And_States_From_SMO_Using_Get
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32944    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}
    ...    [1.0] RAN_ST_CB007010-A_001_CM_Upload full or part of Configuration Data from SMO using get-config operation
    ...    AND    Set Test Variable    ${qc_instance_id}    32944
    ...    AND    Set Test Variable    ${ONAP_IGNORE_PARAMS_FILE}    ${BASE_DATA_PATH}/testdata/ONAP/ONAP_IGNORE_PARAMS.yaml
    ...    AND    Set Library Search Order    XML
    ...    AND    Modify Resource Search Order    SyVe_CM_CB007010-A_002_Upload_Full_Or_Part_Of_Config_Data_And_States_From_SMO_Using_Get
    ...    AND    Set Library Search Order    SyVe_CM_CB007010-A_002_Upload_Full_Or_Part_Of_Config_Data_And_States_From_SMO_Using_Get
    ...    AND    SyVe_CM_CB007010-A_002_Upload_Full_Or_Part_Of_Config_Data_And_States_From_SMO_Using_Get.TC Setup
    SyVe_CM_CB007010-A_002_Upload_Full_Or_Part_Of_Config_Data_And_States_From_SMO_Using_Get
    [Teardown]    Run Keywords    SyVe_CM_CB007010-A_002_Upload_Full_Or_Part_Of_Config_Data_And_States_From_SMO_Using_Get.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB009451-G_001_Audit_Recommended_Feature_Configuration_Using_NetAct
   [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262753
   ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
   [Timeout]    72h
   [Setup]    Run Keywords    Set Test Variable    &{NETACT}    &{NETACT_CB009451}
   ...    AND    Set Library Search Order    XML
   ...    AND    Set Test Variable    ${test_run}    [2.0] RAN_ST_CB009451-G_001_CM_Audit recommended feature configuration using NetAct
   ...    AND    Set Test Variable    ${qc_instance_id}    262753
   ...    AND    SyVe_CM_CB009451-G_001_Audit_Recommended_Feature_Configuration_Using_NetAct.TC Setup
   ...    AND    Modify Resource Search Order    SyVe_CM_CB009451-G_001_Audit_Recommended_Feature_Configuration_Using_NetAct
   ...    AND    Set Library Search Order    SyVe_CM_CB009451-G_001_Audit_Recommended_Feature_Configuration_Using_NetAct
   SyVe_CM_CB009451-G_001_Audit_Recommended_Feature_Configuration_Using_NetAct
   [Teardown]    Run Keywords    SyVe_CM_CB009451-G_001_Audit_Recommended_Feature_Configuration_Using_NetAct.TC Teardown
   ...    AND    Restore Resource Search Order

CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262740   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_017_5G_Cell_Deletion_Addition_via_WebEM
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Test Variable    ${qc_instance_id}    262740
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor.SetUp
    ...    AND    Modify Resource Search Order    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    ...    AND    Set Library Search Order    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Teardown]    Run Keywords    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor.TearDown
    ...    AND    Restore Resource Search Order

CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262742   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CM_Repeat_BB_Module_Lock_Unlock_via_WebEM
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Test Variable    ${qc_instance_id}    262742
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI.SetUp
    ...    AND    Modify Resource Search Order    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI
    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI
    [Teardown]    Run Keywords    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI.CaseTearDown
    ...    AND    Restore Resource Search Order

CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_SBTS_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262780    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/SiteReset/CM_SiteReset_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    SBTS_SITE_RESET
    ...    AND    Set Test Variable    ${test_run}    [1.0] CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_SBTS_Reset
    ...    AND    Set Test Variable    ${qc_instance_id}    262780
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Library Search Order    XML
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    ...    AND    Modify Resource Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    [Teardown]    Run Keywords    Common Test Teardown SBTS
    ...    AND    Restore Resource Search Order

CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_5G_Cell_Locking
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262782    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRObject_Locking/CM_NR_Locking_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_CELL_LOCK
    ...    AND    Set Test Variable    ${test_run}    [1.0] CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_5G_Cell_Locking
    ...    AND    Set Test Variable    ${qc_instance_id}    262782
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Library Search Order    XML
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    ...    AND    Modify Resource Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    [Teardown]    Run Keywords    Common Test Teardown SBTS
    ...    AND    Restore Resource Search Order

CM__Fullrack_Uncommissioned_Secondary_Core
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_32953
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Setup]    Run Keywords    Modify Resource Search Order    ca_HZ_SBTS_AdminAPI_CM
    ...    AND    Set Test Variable    ${test_run}    [1.0] Automated__CM__Fullrack_Uncommissioned_Secondary_Core
    ...    AND    Set Test Variable    ${qc_instance_id}    32953
    ...    AND    Common Test Setup SBTS   syslog_launch=${FALSE}
    ...    AND    Modify Resource Search Order    CM__Fullrack_Uncommissioned_Secondary_Core
    ...    AND    Set Library Search Order    CM__Fullrack_Uncommissioned_Secondary_Core
    [Timeout]      2h
    Set Test Variable    ${COMMISSIONING_PATH}
    ...    ${BASE_DATA_PATH}/commissioning/SCF_01_SBTS18.xml
    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${False}
    Set Test Variable    ${NEED_RECOVER}    ${False}
    CM__Fullrack_Uncommissioned_Secondary_Core
    [Teardown]    Run Keywords    Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__CB012098_001_PDL_Validation_Run_For_Prepared_Target_Configuration_via_WebEM
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_58316
    ...   CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [1.0] RAN_ET_CB012098_001_CM_PDL validation run for prepared target configuration via WebEM
    ...    AND    Set Test Variable    ${qc_instance_id}    58316
    ...    AND    Set Library Search Order    XML
    ...    AND    Modify Resource Search Order   CM__CB012098_001_PDL_Validation_Run_For_Prepared_Target_Configuration_via_WebEM
    ...    AND    Set Library Search Order    CM__CB012098_001_PDL_Validation_Run_For_Prepared_Target_Configuration_via_WebEM
    ...    AND    CM__CB012098_001_PDL_Validation_Run_For_Prepared_Target_Configuration_via_WebEM.SetUp
    [Timeout]      2h
    CM__CB012098_001_PDL_Validation_Run_For_Prepared_Target_Configuration_via_WebEM
    [Teardown]    Run Keywords    CaseTearDown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB008708_001_Verify_NE3S_Feedback_when_Recovery_Reset_is_Executed_via_NMS_Action_Provision
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_191058   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIO_1ASIA_2ABIA_1FXED_1FRGS_1AZHA_1FRGU_1AHEGB_1894
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [1.0] RAN_ST_CB008708_001_CM_SR_Verify NE3S feedback when recovery reset is executed via NMS action provision
    ...    AND    Set Test Variable    ${qc_instance_id}    191058
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB008708_001_Verify_NE3S_Feedback_when_Recovery_Reset_is_Executed_via_NMS_Action_Provision.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB008708_001_Verify_NE3S_Feedback_when_Recovery_Reset_is_Executed_via_NMS_Action_Provision
    ...    AND    Set Library Search Order    SyVe_CM_CB008708_001_Verify_NE3S_Feedback_when_Recovery_Reset_is_Executed_via_NMS_Action_Provision
    SyVe_CM_CB008708_001_Verify_NE3S_Feedback_when_Recovery_Reset_is_Executed_via_NMS_Action_Provision
    [Teardown]    Run Keywords    SyVe_CM_CB008708_001_Verify_NE3S_Feedback_when_Recovery_Reset_is_Executed_via_NMS_Action_Provision.TC Teardown
    ...    AND    Restore Resource Search Order