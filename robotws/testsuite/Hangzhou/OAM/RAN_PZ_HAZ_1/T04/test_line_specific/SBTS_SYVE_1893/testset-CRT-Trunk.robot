*** Settings ***
Documentation       Test suite for SBTS1893
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout    24h
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource    ../../test_resources/SyVe/SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct.robot
Resource    ../../test_resources/SyVe/SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion.robot

Resource    ../../test_resources/SyVe/SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB013998_001_Modify_Parameter_With_RAT_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB013998_004_007_Modify_Parameter_With_RU_Reset.robot

Resource    ../../test_resources/CM/CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Fullrack_Uncommissioned_Secondary_Core.robot
Resource    ../../test_resources/CM/CM__Commissioning__Planned_Commissioning.robot
Resource    ../../test_resources/CM/CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Repeat_RF_BB_Module_Lock_And_Reset_Parallel_By_HWRESET_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Repeat_Reset_LTE_OR_NR_RAT_Via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__CB009175_003_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_WebEM.robot

Resource    ../../test_resources/SyVe/SyVe_CM_CB009175_006_Configure_New_Internal_Antenna_MAA_NRCELL_with_Illegal_Configuration_from_MantaRay.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param.robot
Resource    ../../test_resources/SyVe/SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter.robot



*** Variables ***
${SRNCLAB}      SRNCLAB1014    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${SRNCLAB_9451}      SRNCLAB2002
${NETACT_CB009451}    &{${SRNCLAB_9451}}
${SCF_ID}         01
${SKIP_PARAM_RELATION_ERRORS}    ${True}    # Should relation errors be skipped (True, False)
${COMMISSIONING_TIMEOUT}    600    # Timeout for SCF commision via ADMIN API in seconds
${COMMISSIONING_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
${VALIDATION_TIMEOUT}    70    # Timeout for SCF validation via ADMIN API in seconds
${TIMEOUT}        1000    # Timeout for Admin Get bts_id and perform commissioning keyword in seconds
${SEND_REP_PYTHON_CODE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/resources/python/UploadTCDataToRep_CRT.py
${BASE_DATA_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}
${CB006530_006_name1}    [1][1.0] SRAN_SyVe_CB006530_006__Removal_of_an_element_in_restriction_list_and_modification_of_that
${CB006530_006_name2}    _parameter_in_the_same_delta_plan_via_WebEM_with_“Nemuadmin”_role_and_NetAct
${REPEAT_TIME}    1

*** Test Cases ***
SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33060    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/LTE_Cell_Locking/CM_LTE_Cell_Locking_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    LTE_CELL_LOCK
    ...    AND    Set Test Variable    ${test_run}    [1.0] CM__SyVe_SBTS_Configuration_changes_from_NetAct_with_cell_lock_and_unlock
    ...    AND    Set Test Variable    ${qc_instance_id}    33060
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_LTE_RAT_STATUS}    True
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G
    ...    AND    Set Library Search Order    SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G
    TC__SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G
    [Teardown]    Run Keywords    SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33056    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${TEST_DATA_FILE}
    ...    ${BASE_DATA_PATH}/testdata/PremeterModifyTriggerAction/SiteReset/CM_SiteReset_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    SBTS_SITE_RESET
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset
    ...    AND    Set Test Variable    ${qc_instance_id}    33056
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset
    ...    AND    Set Library Search Order    SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset
    TC__SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset
    [Teardown]    Run Keywords    SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33058    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords
    ...    Set Test Variable    ${test_run}    [1.0] SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification
    ...    AND    Set Test Variable    ${qc_instance_id}    33058
	...    AND    Set Test Variable    ${NEED_TO_CHECK_5G_RAT_STATUS}    False
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification
    ...    AND    Set Library Search Order    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification
    TC__SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification
    [Teardown]    Run Keywords    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33059    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRRat_Reset/CM_NRRat_Reset_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_RAT_RESET
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_LTE_RAT_STATUS}    False
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_007_5G_RAT_Reset_After_Recommission_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    33059
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33057   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRObject_Locking/CM_NR_Locking_para.yaml
    ...    AND    Set Test Variable     @{SELECTED_TYPE}    NR_CELL_LOCK
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_011_5G_Cell_Locking_After_Recommission_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    33057
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct
    SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33061    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords
    ...    Set Test Variable    ${test_run}    [1.0] SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    ...    AND    Set Test Variable    ${TEST_DATA_FILE}
    ...    ${BASE_DATA_PATH}/testdata/PremeterModifyTriggerAction/Multi/test_data.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    LTE_CELL_LOCK    NR_CELL_LOCK
    ...    AND    Set Test Variable    ${qc_instance_id}    33061
    ...    AND    Set Library Search Order    XML
    ...    AND    SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking.TC Setup
    ...    AND    Modify Resource Search Order    SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    ...    AND    Set Library Search Order    SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    TC__SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    [Teardown]    Run Keywords    SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_131656    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords
    ...    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Verify_HWRESETREQ_With_RMOD_Reset_LTE3296
    ...    AND    Set Test Variable    ${qc_instance_id}    131656
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    ...    AND    Set Library Search Order    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    [Teardown]    Run Keywords    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_131657    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${plan_info}    PLAN_TAT-19721
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_LTE_RAT_STATUS}    False
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_5G_RAT_STATUS}    False
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Verify_SWRESETREQ_With_RAT_Reset_LTE3296_SR001610
    ...    AND    Set Test Variable    ${qc_instance_id}    131657
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset
    ...    AND    Set Library Search Order    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset
    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset
    [Teardown]    Run Keywords    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_131659    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${plan_id}    PLAN_TAT-20727
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_026_Verify_Reset_for_5G_HW_Objects_via_HWRESET
    ...    AND    Set Test Variable    ${qc_instance_id}    131659
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_131659    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_026_Verify_Reset_for_5G_HW_Objects_via_HWRESET
    ...    AND    Set Test Variable    ${qc_instance_id}    131659
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    [Teardown]    Run Keywords    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_131658    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords
    ...    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_033_Verify_Radio_lock_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    131658
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct
    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_131660    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_039_Verify_BBMOD_lock_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    131660
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct
    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_161037   CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${qc_instance_id}    161037
    ...    AND    Set Test Variable    ${test_run}
    ...    [1]RAN_ST_CB011058_001_CM_SR_Static HW properties pre-validation for BBMOD in MantaRay NM
    ...    AND    SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM
    ...    AND    Set Library Search Order    SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM
    SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM
    [Teardown]    Run Keywords    SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB013998_001_Modify_Parameter_With_RAT_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_191568   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [1.0] RAN_ST_CB013998_001_CM_SR_Modify in SBTS some parameter(s) with “Conditional RAT reset” modification type
    ...    AND    Set Test Variable    ${qc_instance_id}    191568
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB013998_001_Modify_Parameter_With_RAT_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB013998_001_Modify_Parameter_With_RAT_Reset
    ...    AND    Set Library Search Order    SyVe_CM_CB013998_001_Modify_Parameter_With_RAT_Reset
    SyVe_CM_CB013998_001_Modify_Parameter_With_RAT_Reset
    [Teardown]    Run Keywords    SyVe_CM_CB013998_001_Modify_Parameter_With_RAT_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB013998_004_007_Modify_Parameter_With_RU_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_191569   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [1.0] RAN_ST_CB013998_004_CM_SR_Modify in SBTS some parameter(s) with “Conditional RU reset” modification type
    ...    AND    Set Test Variable    ${qc_instance_id}    191569
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB013998_004_007_Modify_Parameter_With_RU_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB013998_004_007_Modify_Parameter_With_RU_Reset
    ...    AND    Set Library Search Order    SyVe_CM_CB013998_004_007_Modify_Parameter_With_RU_Reset
    SyVe_CM_CB013998_004_007_Modify_Parameter_With_RU_Reset
    [Teardown]    Run Keywords    SyVe_CM_CB013998_004_007_Modify_Parameter_With_RU_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB009175_006_Configure_New_Internal_Antenna_MAA_NRCELL_with_Illegal_Configuration_from_MantaRay
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_263438    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Setup]    Run Keywords    Set Test Variable    ${qc_instance_id}    263438
    ...    AND    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${test_run}
    ...    [1][1.0] RAN_ST_CB009175_006_CM_Configure new internal antenna MAA NRCELL with illegal configuration from MantaRay
    ...    AND    SyVe_CM_CB009175_006_Configure_New_Internal_Antenna_MAA_NRCELL_with_Illegal_Configuration_from_MantaRay.TC Setup
    ...    AND    Modify Resource Search Order
    ...    SyVe_CM_CB009175_006_Configure_New_Internal_Antenna_MAA_NRCELL_with_Illegal_Configuration_from_MantaRay
    ...    AND    Set Library Search Order
    ...    SyVe_CM_CB009175_006_Configure_New_Internal_Antenna_MAA_NRCELL_with_Illegal_Configuration_from_MantaRay
    [Timeout]    72h
    SyVe_CM_CB009175_006_Configure_New_Internal_Antenna_MAA_NRCELL_with_Illegal_Configuration_from_MantaRay
    [Teardown]    Run Keywords    SyVe_CM_CB009175_006_Configure_New_Internal_Antenna_MAA_NRCELL_with_Illegal_Configuration_from_MantaRay.TC TearDown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_263073   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    72h
    [Setup]    Run Keywords      Set Test Variable    ${test_run}
    ...    [1][1.0] RAN_SyVe_CB005891_005_CM_Action provision request message verify from wireshark
    ...    AND    Set Test Variable    ${qc_instance_id}    263073
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark
    ...    AND    Set Library Search Order    SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark
    SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark
    [Teardown]    Run Keywords    SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_263072    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    72h
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${test_run}    [1][1.0] RAN_SyVe_CB005891_007_CM_Incorrect input verify when provision actions from NMS
    ...    AND    Set Test Variable    ${qc_instance_id}    263072
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS
    ...    AND    Set Library Search Order    SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS
    SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS
    [Teardown]    Run Keywords    SyVe_CM_CB005891_007_CM_Incorrect_Input_Verify_When_Provision_Actions_From_NMS.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_263070
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/restriction_parameters.yaml
    ...    AND    Set Test Variable    ${origin_scf_path}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    ...    AND    Set Test Variable    ${test_run}
    ...    [1.0] SRAN_SyVe_CB006530_005__Creation_of_restriction_rules_in_a_delta_plan_via_WebEM_with_Nemuadmin_role_and_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    263070
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct
    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct
    [Teardown]    Run Keywords    SyVe_CM_CB006530_Delta_Plan_Restriction_Rules_Creation_From_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_263071
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    72h
    [Setup]    Run Keywords     Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/restriction_parameters.yaml
    ...    AND    Set Test Variable    ${origin_scf_path}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    ...    AND    Set Test Variable    ${test_run}
    ...    ${CB006530_006_name1}${CB006530_006_name2}
    ...    AND    Set Test Variable    ${qc_instance_id}    263071
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param
    ...    AND    Set Library Search Order    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param
    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param
    [Teardown]    Run Keywords    SyVe_CM_CB006530_Delta_Plan_Remove_Rule_With_Modified_Restricted_Param.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262826    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}
    ...    [2.0] LTE4934-A_ST_05_17_CM provision to trigger CCN upload by modify create and delete parameter
    ...    AND    Set Test Variable    ${qc_instance_id}    262826
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    ...    AND    Set Library Search Order    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    TC__SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    [Teardown]    Run Keywords    SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262791    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Test Variable    ${test_run}    [1.0] ST_OAM_Combine cell impacts parameters updating with NR cell addition deletion
    ...    AND    Set Test Variable    ${qc_instance_id}    262791
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_RAT_RESET
    ...    AND    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRRat_Reset/CM_NRRat_Reset_para.yaml
    ...    AND    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion
    ...    AND    Set Library Search Order    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion
    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion
    [Teardown]    Run Keywords    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion.TC Teardown
    ...    AND    Restore Resource Search Order

CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_131662    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CM_Repeat_5G_Cell_Lock_Unlock_via_WebEM
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Test Variable    ${qc_instance_id}    131662
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI.SetUp
    ...    AND    Modify Resource Search Order    CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI
    [Timeout]    2h
    CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI
    [Teardown]    Run Keywords    CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI.CaseTearDown
    ...    AND    Restore Resource Search Order

CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_131664    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CM_Repeat_5G_RAT_Lock_Unlock_via_WebEM
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Test Variable    ${qc_instance_id}    131664
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI.SetUp
    ...    AND    Modify Resource Search Order    CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI
    [Timeout]    2h
    CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI
    [Teardown]    Run Keywords    CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI.CaseTearDown
    ...    AND    Restore Resource Search Order

CM__Fullrack_Uncommissioned_Secondary_Core
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_131663    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Setup]    Run Keywords    Modify Resource Search Order    ca_HZ_SBTS_AdminAPI_CM
    ...    AND    Set Test Variable    ${test_run}    [1.0] Automated__CM__Fullrack_Uncommissioned_Secondary_Core
    ...    AND    Set Test Variable    ${qc_instance_id}    131663
    ...    AND    Common Test Setup SBTS
    ...    AND    Modify Resource Search Order    CM__Fullrack_Uncommissioned_Secondary_Core
    ...    AND    Set Library Search Order    CM__Fullrack_Uncommissioned_Secondary_Core
    [Timeout]      2h
    Set Test Variable    ${COMMISSIONING_PATH}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${False}
    Set Test Variable    ${NEED_RECOVER}    ${False}
    CM__Fullrack_Uncommissioned_Secondary_Core
    [Teardown]    Run Keywords    Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__Commissioning__Planned_Commissioning
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_131665    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [2.0] Automated__CM__Commissioning__Planned_Commissioning
    ...    AND    Set Test Variable    ${qc_instance_id}    131665
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__Commissioning__Planned_Commissioning.CaseSetUp
    ...    AND    Modify Resource Search Order   CM__Commissioning__Planned_Commissioning
    ...    AND    Set Library Search Order    CM__Commissioning__Planned_Commissioning
    [Timeout]      2h
    CM__Commissioning__Planned_Commissioning
    [Teardown]    Run Keywords    CM__Commissioning__Planned_Commissioning.CaseTearDown
    ...    AND    Restore Resource Search Order

CM__CB009175_003_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_WebEM
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_263437    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Setup]    Run Keywords    Set Test Variable    ${qc_instance_id}    263437
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

CM__Repeat_RF_BB_Module_Lock_And_Reset_Parallel_By_HWRESET_via_AdminAPI
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262792    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
	...    [1][1.0] CM__Repeat_RF_BB_Module_Lock_And_Reset_Parallel_By_HWRESET_via_AdminAPI
    ...    AND    Set Test Variable    ${qc_instance_id}    262792
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Test Variable    ${tl_name}    SRAN_Hangzhou_UTESRAN1910
    ...    AND    Modify Resource Search Order    CM__Repeat_RF_BB_Module_Lock_And_Reset_Parallel_By_HWRESET_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_RF_BB_Module_Lock_And_Reset_Parallel_By_HWRESET_via_AdminAPI
    ...    AND    CM__Repeat_RF_BB_Module_Lock_And_Reset_Parallel_By_HWRESET_via_AdminAPI.SetUp
    [Timeout]    72h
    CM__Repeat_RF_BB_Module_Lock_And_Reset_Parallel_By_HWRESET_via_AdminAPI
    [Teardown]    Run Keywords    CM__Repeat_RF_BB_Module_Lock_And_Reset_Parallel_By_HWRESET_via_AdminAPI.CaseTearDown
    ...    AND    Restore Resource Search Order


CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_4G_Cell_Locking
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262797    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/LTE_Cell_Locking/CM_LTE_Cell_Locking_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    LTE_CELL_LOCK
    ...    AND    Set Test Variable    ${test_run}    [1][1.0] CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_4G_Cell_Locking
    ...    AND    Set Test Variable    ${qc_instance_id}    262797
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Library Search Order    XML
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    ...    AND    Modify Resource Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    [Teardown]    Run Keywords    Common Test Teardown SBTS
    ...    AND    Restore Resource Search Order

CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_5G_RAT_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262798    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRRat_Reset/CM_NRRat_Reset_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_RAT_RESET
    ...    AND    Set Test Variable    ${test_run}    [1][1.0] CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI_5G_RAT_Reset
    ...    AND    Set Test Variable    ${qc_instance_id}    262798
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Library Search Order    XML
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    ...    AND    Modify Resource Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    [Teardown]    Run Keywords    Common Test Teardown SBTS
    ...    AND    Restore Resource Search Order

CM__Repeat_Reset_LTE_OR_NR_RAT_Via_AdminAPI_LTE_5G_RAT_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_262799    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    72h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    AND    Set Test Variable    ${test_run}    CM__Repeat_Reset_LTE_OR_NR_RAT_Via_AdminAPI_LTE_5G_RAT_Reset
    ...    AND    Set Test Variable    ${qc_instance_id}    262799
    ...    AND    Set Test Variable    ${REPEAT_TIME}    ${REPEAT_TIME}
    ...    AND    Set Library Search Order    XML
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    ...    AND    Modify Resource Search Order    CM__Repeat_Reset_LTE_OR_NR_RAT_Via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_Reset_LTE_OR_NR_RAT_Via_AdminAPI
    CM__Repeat_Reset_LTE_OR_NR_RAT_Via_AdminAPI
    [Teardown]    Run Keywords    Common Test Teardown SBTS
    ...    AND    Restore Resource Search Order