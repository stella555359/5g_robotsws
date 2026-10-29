*** Settings ***
Documentation       Test suite for SBTS1893
...                 Author: Yu xing
...                 Contact: yuxing.zhai@nokia.com
Suite Setup    CI_interface.Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Timeout    24h
Variables     My_VariablesTL921.py
Variables     ../Variables/NetActs.py
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct.robot
Resource    ../../test_resources/SyVe/SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking.robot
Resource    ../../test_resources/SyVe/SyVe_CM_921_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion.robot
Resource    ../../test_resources/SyVe/SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB013998_921_Modify_Parameter_With_RAT_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB013998_004_Modify_Parameter_With_RU_Reset.robot
Resource    ../../test_resources/CM/CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Fullrack_Uncommissioned_Secondary_Core.robot
Resource    ../../test_resources/CM/CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Repeat_RF_BB_Module_Lock_And_Reset_Parallel_By_HWRESET_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Repeat_Reset_LTE_OR_NR_RAT_Via_AdminAPI.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param.robot

*** Variables ***
${SRNCLAB}      NetAct2Chen    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${SRNCLAB_9451}      NetAct2Chen
${NETACT_CB009451}    &{${SRNCLAB_9451}}
${SCF_ID}         01
${SKIP_PARAM_RELATION_ERRORS}    ${True}    # Should relation errors be skipped (True, False)
${COMMISSIONING_TIMEOUT}    600    # Timeout for SCF commision via ADMIN API in seconds
${COMMISSIONING_PATH}    /home/ute/MN/UTE/robotws/commissionings/HGZ/${TESTLINE_NAME}/SCF_SBTS26R2.xml
${VALIDATION_TIMEOUT}    70    # Timeout for SCF validation via ADMIN API in seconds
${TIMEOUT}        1000    # Timeout for Admin Get bts_id and perform commissioning keyword in seconds
${SEND_REP_PYTHON_CODE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/resources/python/UploadTCDataToRep_CRT.py
${BASE_DATA_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}
${CB006530_006_name1}    [1][1.0] SRAN_SyVe_CB006530_006__Removal_of_an_element_in_restriction_list_and_modification_of_that
${CB006530_006_name2}    _parameter_in_the_same_delta_plan_via_WebEM_with_“Nemuadmin”_role_and_NetAct
${REPEAT_TIME}    1
${TESTLINE_ID}    7_5_UTE5G402T921

*** Test Cases ***
SyVe_CM_CB013998_004_Modify_Parameter_With_RU_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_306665   CA_RAN_PZ_HAZ_1
    ...    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABIOB1_ABIPB2_AVHQA
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [1.0] RAN_ST_CB013998_004_CM_SR_Modify in SBTS some parameter(s) with “Conditional RU reset” modification type
    ...    AND    Set Test Variable    ${qc_instance_id}    306665
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB013998_004_Modify_Parameter_With_RU_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB013998_004_Modify_Parameter_With_RU_Reset
    ...    AND    Set Library Search Order    SyVe_CM_CB013998_004_Modify_Parameter_With_RU_Reset
    SyVe_CM_CB013998_004_Modify_Parameter_With_RU_Reset
    [Teardown]    Run Keywords    SyVe_CM_CB013998_004_Modify_Parameter_With_RU_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_306667   CA_RAN_PZ_HAZ_1
    ...    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABIOB1_ABIPB2_AVHQA
    [Timeout]    72h
    [Setup]    Run Keywords      Set Test Variable    ${test_run}
    ...    [1][1.0] RAN_SyVe_CB005891_005_CM_Action provision request message verify from wireshark
    ...    AND    Set Test Variable    ${qc_instance_id}    306667
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark
    ...    AND    Set Library Search Order    SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark
    SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark
    [Teardown]    Run Keywords    SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_306666    CA_RAN_PZ_HAZ_1    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABIOB1_ABIPB2_AVHQA
    [Timeout]    72h
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${test_run}    [1][1.0] RAN_SyVe_CB005891_007_CM_Incorrect input verify when provision actions from NMS
    ...    AND    Set Test Variable    ${qc_instance_id}    306666
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS
    ...    AND    Set Library Search Order    SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS
    SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS
    [Teardown]    Run Keywords    SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_306664
    ...    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABIOB1_ABIPB2_AVHQA
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/restriction_parameters.yaml
    ...    AND    Set Test Variable    ${origin_scf_path}
    ...    /home/ute/MN/UTE/robotws/commissionings/HGZ/${TESTLINE_NAME}/SCF_SBTS26R2.xml
    ...    AND    Set Test Variable    ${test_run}
    ...    [1.0] SRAN_SyVe_CB006530_005__Creation_of_restriction_rules_in_a_delta_plan_via_WebEM_with_Nemuadmin_role_and_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    306664
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct
    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct
    [Teardown]    Run Keywords    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_306663
    ...    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABIOB1_ABIPB2_AVHQA
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/restriction_parameters.yaml
    ...    AND    Set Test Variable    ${origin_scf_path}
    ...    /home/ute/MN/UTE/robotws/commissionings/HGZ/${TESTLINE_NAME}/SCF_SBTS26R2.xml
    ...    AND    Set Test Variable    ${test_run}
    ...    ${CB006530_006_name1}${CB006530_006_name2}
    ...    AND    Set Test Variable    ${qc_instance_id}    306663
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param
    ...    AND    Set Library Search Order    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param
    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param
    [Teardown]    Run Keywords    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_921_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_306662    CA_RAN_PZ_HAZ_1
    ...    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABIOB1_ABIPB2_AVHQA
    [Timeout]    2h
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Test Variable    ${test_run}    [1.0] ST_OAM_Combine cell impacts parameters updating with NR cell addition deletion
    ...    AND    Set Test Variable    ${qc_instance_id}    306662
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_RAT
    ...    AND    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRRat_Reset/CM_NRRat_Reset_para.yaml
    ...    AND    SyVe_CM_921_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_921_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion
    ...    AND    Set Library Search Order    SyVe_CM_921_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion
    SyVe_CM_921_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion
    [Teardown]    Run Keywords    SyVe_CM_921_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion.TC Teardown
    ...    AND    Restore Resource Search Order

CM__Fullrack_Uncommissioned_Secondary_Core
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_306661    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABIOB1_ABIPB2_AVHQA
    [Setup]    Run Keywords    Modify Resource Search Order    ca_HZ_SBTS_AdminAPI_CM
    ...    AND    Set Test Variable    ${test_run}    [1.0] Automated__CM__Fullrack_Uncommissioned_Secondary_Core
    ...    AND    Set Test Variable    ${qc_instance_id}    306661
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Library Search Order    XML
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    ...    AND    Modify Resource Search Order    CM__Repeat_Reset_LTE_OR_NR_RAT_Via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_Reset_LTE_OR_NR_RAT_Via_AdminAPI
    CM__Repeat_Reset_LTE_OR_NR_RAT_Via_AdminAPI
    [Teardown]    Run Keywords    Common Test Teardown SBTS
    ...    AND    Restore Resource Search Order