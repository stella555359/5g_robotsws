*** Settings ***
Documentation   Test suite for
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

*** Variables ***
${SRNCLAB}      SRNCLAB1014    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
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
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33060    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1811_2ASIL_1ABIN_1ABIA_1ABIQ_1ABIL_1ABIO_1ABIP_1FRGT_1AHDA_1AHLOA_1AZHA_1AKNB_1FRGU
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
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33056    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1811_2ASIL_1ABIN_1ABIA_1ABIQ_1ABIL_1ABIO_1ABIP_1FRGT_1AHDA_1AHLOA_1AZHA_1AKNB_1FRGU
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
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33058    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1811_2ASIL_1ABIN_1ABIA_1ABIQ_1ABIL_1ABIO_1ABIP_1FRGT_1AHDA_1AHLOA_1AZHA_1AKNB_1FRGU
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
    ...    CLOUD_SRAN_NLWG_1811_2ASIL_1ABIN_1ABIA_1ABIQ_1ABIL_1ABIO_1ABIP_1FRGT_1AHDA_1AHLOA_1AZHA_1AKNB_1FRGU
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
    ...    CLOUD_SRAN_NLWG_1811_2ASIL_1ABIN_1ABIA_1ABIQ_1ABIL_1ABIO_1ABIP_1FRGT_1AHDA_1AHLOA_1AZHA_1AKNB_1FRGU
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
    ...    CLOUD_SRAN_NLWG_1811_2ASIL_1ABIN_1ABIA_1ABIQ_1ABIL_1ABIO_1ABIP_1FRGT_1AHDA_1AHLOA_1AZHA_1AKNB_1FRGU
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

SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33063    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1811_2ASIL_1ABIN_1ABIA_1ABIQ_1ABIL_1ABIO_1ABIP_1FRGT_1AHDA_1AHLOA_1AZHA_1AKNB_1FRGU
    [Timeout]    2h
    [Setup]    Run Keywords
    ...    Set Test Variable    ${test_run}    [1.0] ST_OAM_Combine cell impacts parameters updating with cell addition deletion
    ...    AND    Set Test Variable    ${qc_instance_id}    33063
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion
    ...    AND    Set Library Search Order    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion
    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion
    [Teardown]    Run Keywords    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33063    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1811_2ASIL_1ABIN_1ABIA_1ABIQ_1ABIL_1ABIO_1ABIP_1FRGT_1AHDA_1AHLOA_1AZHA_1AKNB_1FRGU
    [Timeout]    2h
    [Setup]    Run Keywords
    ...    Set Test Variable    ${test_run}    [1.0] ST_OAM_Combine cell impacts parameters updating with cell addition deletion
    ...    AND    Set Test Variable    ${qc_instance_id}    33063
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion
    ...    AND    Set Library Search Order    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion
    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion
    [Teardown]    Run Keywords    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion.TC Teardown
    ...    AND    Restore Resource Search Order

CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33055    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1811_2ASIL_1ABIN_1ABIA_1ABIQ_1ABIL_1ABIO_1ABIP_1FRGT_1AHDA_1AHLOA_1AZHA_1AKNB_1FRGU
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CM_Repeat_BB_Module_Lock_Unlock_via_WebEM
    ...    AND    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Test Variable    ${qc_instance_id}    33055
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI.SetUp
    ...    AND    Modify Resource Search Order    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI
    [Timeout]    2h
    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI
    [Teardown]    Run Keywords    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI.CaseTearDown
    ...    AND    Restore Resource Search Order

CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33054   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1811_2ASIL_1ABIN_1ABIA_1ABIQ_1ABIL_1ABIO_1ABIP_1FRGT_1AHDA_1AHLOA_1AZHA_1AKNB_1FRGU
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CM_Repeat_RF_Module_Lock_Unlock_via_WebEM
	...    AND    Set Test Variable    ${REPEAT_TIME}    10
    ...    AND    Set Test Variable    ${qc_instance_id}    33054
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI.SetUp
    ...    AND    Modify Resource Search Order    CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI
    CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI
    [Teardown]    Run Keywords    CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI.CaseTearDown
    ...    AND    Restore Resource Search Order

CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33062   CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1811_2ASIL_1ABIN_1ABIA_1ABIQ_1ABIL_1ABIO_1ABIP_1FRGT_1AHDA_1AHLOA_1AZHA_1AKNB_1FRGU
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_017_5G_Cell_Deletion_Addition_via_WebEM
    ...    AND    Set Test Variable    ${qc_instance_id}    33062
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor.SetUp
    ...    AND    Modify Resource Search Order    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    ...    AND    Set Library Search Order    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Teardown]    Run Keywords    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor.TearDown
    ...    AND    Restore Resource Search Order