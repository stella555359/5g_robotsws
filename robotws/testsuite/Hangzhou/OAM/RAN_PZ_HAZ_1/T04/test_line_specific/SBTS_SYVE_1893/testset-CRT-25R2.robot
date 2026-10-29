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
Resource    ../../test_resources/SyVe/SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion.robot
Resource    ../../test_resources/CM/CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor.robot
#
Resource    ../../test_resources/SyVe/SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009451-F_001_Configure_Optimize_Recalculate_Feature_With_Multi_BTSs_In_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009451-G_001_Audit_Recommended_Feature_Configuration_Using_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay.robot
Resource    ../../test_resources/SyVe/SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM.robot

Resource    ../../test_resources/CM/CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI.robot
Resource    ../../test_resources/CM/CM__Fullrack_Uncommissioned_Secondary_Core.robot
Resource    ../../test_resources/CM/CM__Commissioning__Planned_Commissioning.robot
Resource    ../../test_resources/CM/CM__CB012098_001_PDL_Validation_Run_For_Prepared_Target_Configuration_via_WebEM.robot

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

*** Test Cases ***
SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146309    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/LTE_Cell_Locking/CM_LTE_Cell_Locking_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    LTE_CELL_LOCK
    ...    AND    Set Test Variable    ${test_run}    [1.0] CM__SyVe_SBTS_Configuration_changes_from_NetAct_with_cell_lock_and_unlock
    ...    AND    Set Test Variable    ${qc_instance_id}    146309
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_LTE_RAT_STATUS}    True
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G
    ...    AND    Set Library Search Order    SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G
    TC__SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G
    [Teardown]    Run Keywords    SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146315    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${TEST_DATA_FILE}
    ...    ${BASE_DATA_PATH}/testdata/PremeterModifyTriggerAction/SiteReset/CM_SiteReset_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    SBTS_SITE_RESET
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset
    ...    AND    Set Test Variable    ${qc_instance_id}    146315
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset
    ...    AND    Set Library Search Order    SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset
    TC__SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset
    [Teardown]    Run Keywords    SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146301    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords
    ...    Set Test Variable    ${test_run}    [1.0] SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification
    ...    AND    Set Test Variable    ${qc_instance_id}    146301
	...    AND    Set Test Variable    ${NEED_TO_CHECK_5G_RAT_STATUS}    False
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification
    ...    AND    Set Library Search Order    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification
    TC__SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification
    [Teardown]    Run Keywords    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146313    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRRat_Reset/CM_NRRat_Reset_para.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    NR_RAT_RESET
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_LTE_RAT_STATUS}    False
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_007_5G_RAT_Reset_After_Recommission_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    146313
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146303   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${TEST_DATA_FILE}
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRObject_Locking/CM_NR_Locking_para.yaml
    ...    AND    Set Test Variable     @{SELECTED_TYPE}    NR_CELL_LOCK
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_011_5G_Cell_Locking_After_Recommission_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    QC_146303
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct
    SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146312    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords
    ...    Set Test Variable    ${test_run}    [1.0] SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    ...    AND    Set Test Variable    ${TEST_DATA_FILE}
    ...    ${BASE_DATA_PATH}/testdata/PremeterModifyTriggerAction/Multi/test_data.yaml
    ...    AND    Set Test Variable    @{SELECTED_TYPE}    LTE_CELL_LOCK    NR_CELL_LOCK
    ...    AND    Set Test Variable    ${qc_instance_id}    146312
    ...    AND    Set Library Search Order    XML
    ...    AND    SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking.TC Setup
    ...    AND    Modify Resource Search Order    SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    ...    AND    Set Library Search Order    SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    TC__SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking
    [Teardown]    Run Keywords    SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146302    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords
    ...    Set Test Variable    ${test_run}    [1.0] ST_OAM_Combine cell impacts parameters updating with cell addition deletion
    ...    AND    Set Test Variable    ${qc_instance_id}    146302
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion
    ...    AND    Set Library Search Order    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion
    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion
    [Teardown]    Run Keywords    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146302    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords
    ...    Set Test Variable    ${test_run}    [1.0] ST_OAM_Combine cell impacts parameters updating with cell addition deletion
    ...    AND    Set Test Variable    ${qc_instance_id}    146302
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion
    ...    AND    Set Library Search Order    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion
    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion
    [Teardown]    Run Keywords    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146316    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords
    ...    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Verify_HWRESETREQ_With_RMOD_Reset_LTE3296
    ...    AND    Set Test Variable    ${qc_instance_id}    146316
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    ...    AND    Set Library Search Order    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    [Teardown]    Run Keywords    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146305    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${plan_info}    PLAN_TAT-19721
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_LTE_RAT_STATUS}    False
    ...    AND    Set Test Variable    ${NEED_TO_CHECK_5G_RAT_STATUS}    False
    ...    AND    Set Test Variable    ${test_run}    [1.0] SyVe_CM_Verify_SWRESETREQ_With_RAT_Reset_LTE3296_SR001610
    ...    AND    Set Test Variable    ${qc_instance_id}    146305
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset
    ...    AND    Set Library Search Order    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset
    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset
    [Teardown]    Run Keywords    SyVe_CM_LTE3296_SR001610_Verify_SWRESETREQ_With_RAT_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146317    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${plan_id}    PLAN_TAT-20727
    ...    AND    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_026_Verify_Reset_for_5G_HW_Objects_via_HWRESET
    ...    AND    Set Test Variable    ${qc_instance_id}    146317
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146317    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_026_Verify_Reset_for_5G_HW_Objects_via_HWRESET
    ...    AND    Set Test Variable    ${qc_instance_id}    146317
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    [Teardown]    Run Keywords    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146308    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords
    ...    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_033_Verify_Radio_lock_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    146308
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct
    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_Verify_Radio_Lock_Via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146318    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_039_Verify_BBMOD_lock_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    146318
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct
    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146304    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${qc_instance_id}    146304
    ...    AND    Set Test Variable    ${test_run}
    ...    [1]RAN_ST_CB009175_001_CM_Configure new internal antenna MAA NRCELL Channel Groups and Channels using Simplified method from MantaRay
    ...    AND    SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay
    ...    AND    Set Library Search Order    SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay
    SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay
    [Teardown]    Run Keywords    SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_161369   CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Library Search Order    XML
    ...    AND    Set Test Variable    ${qc_instance_id}    161369
    ...    AND    Set Test Variable    ${test_run}
    ...    [1]RAN_ST_CB011058_001_CM_SR_Static HW properties pre-validation for BBMOD in MantaRay NM
    ...    AND    SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM
    ...    AND    Set Library Search Order    SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM
    SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM
    [Teardown]    Run Keywords    SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM.TC Teardown
    ...    AND    Restore Resource Search Order


CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146311    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CM_Repeat_BB_Module_Lock_Unlock_via_WebEM
    ...    AND    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Test Variable    ${qc_instance_id}    146311
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI.SetUp
    ...    AND    Modify Resource Search Order    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI
    [Timeout]    2h
    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI
    [Teardown]    Run Keywords    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI.CaseTearDown
    ...    AND    Restore Resource Search Order

CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146310   CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CM_Repeat_RF_Module_Lock_Unlock_via_WebEM
    ...    AND    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Test Variable    ${qc_instance_id}    146310
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI.SetUp
    ...    AND    Modify Resource Search Order    CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI
    CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI
    [Teardown]    Run Keywords    CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI.CaseTearDown
    ...    AND    Restore Resource Search Order

CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146306    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CM_Repeat_5G_Cell_Lock_Unlock_via_WebEM
    ...    AND    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Test Variable    ${qc_instance_id}    146306
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI.SetUp
    ...    AND    Modify Resource Search Order    CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI
    [Timeout]    2h
    CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI
    [Teardown]    Run Keywords    CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI.CaseTearDown
    ...    AND    Restore Resource Search Order

CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146320    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CM_Repeat_5G_RAT_Lock_Unlock_via_WebEM
    ...    AND    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Test Variable    ${qc_instance_id}    146320
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI.SetUp
    ...    AND    Modify Resource Search Order    CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI
    [Timeout]    2h
    CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI
    [Teardown]    Run Keywords    CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI.CaseTearDown
    ...    AND    Restore Resource Search Order

CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146314   CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_017_5G_Cell_Deletion_Addition_via_WebEM
    ...    AND    Set Test Variable    ${qc_instance_id}    146314
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor.SetUp
    ...    AND    Modify Resource Search Order    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    ...    AND    Set Library Search Order    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Teardown]    Run Keywords    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor.TearDown
    ...    AND    Restore Resource Search Order

CM__CB012098_001_PDL_Validation_Run_For_Prepared_Target_Configuration_via_WebEM
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146307
    ...   CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [1.0] RAN_ET_CB012098_001_CM_PDL validation run for prepared target configuration via WebEM
    ...    AND    Set Test Variable    ${qc_instance_id}    146307
    ...    AND    Set Library Search Order    XML
    ...    AND    Modify Resource Search Order   CM__CB012098_001_PDL_Validation_Run_For_Prepared_Target_Configuration_via_WebEM
    ...    AND    Set Library Search Order    CM__CB012098_001_PDL_Validation_Run_For_Prepared_Target_Configuration_via_WebEM
    ...    AND    CM__CB012098_001_PDL_Validation_Run_For_Prepared_Target_Configuration_via_WebEM.SetUp
    [Timeout]      2h
    CM__CB012098_001_PDL_Validation_Run_For_Prepared_Target_Configuration_via_WebEM
    [Teardown]    Run Keywords    CaseTearDown
    ...    AND    Restore Resource Search Order

CM__Fullrack_Uncommissioned_Secondary_Core
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146319    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Setup]    Run Keywords    Modify Resource Search Order    ca_HZ_SBTS_AdminAPI_CM
    ...    AND    Set Test Variable    ${test_run}    [1.0] Automated__CM__Fullrack_Uncommissioned_Secondary_Core
    ...    AND    Set Test Variable    ${qc_instance_id}    146319
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
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_146321    CLOUD_SRAN_NLG_1893_2ASIL_1ABIA_4ABI0_3AHFIG_3AHLOA_1AEHC_2AEHB
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [2.0] Automated__CM__Commissioning__Planned_Commissioning
    ...    AND    Set Test Variable    ${qc_instance_id}    146321
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__Commissioning__Planned_Commissioning.CaseSetUp
    ...    AND    Modify Resource Search Order   CM__Commissioning__Planned_Commissioning
    ...    AND    Set Library Search Order    CM__Commissioning__Planned_Commissioning
    [Timeout]      2h
    CM__Commissioning__Planned_Commissioning
    [Teardown]    Run Keywords    CM__Commissioning__Planned_Commissioning.CaseTearDown
    ...    AND    Restore Resource Search Order
