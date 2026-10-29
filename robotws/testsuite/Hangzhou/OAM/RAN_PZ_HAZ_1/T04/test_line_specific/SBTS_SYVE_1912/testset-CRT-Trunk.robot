*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx
Suite Teardown    Common Suite Teardown
Test Timeout    32h
Variables     My_Variables.py
Variables     ../Variables/NetActs.py
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET.robot
Resource    ../../test_resources/SyVe/SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct.robot
Resource    ../../test_resources/SyVe/SyVe_CM_RP002956_5G_RAT_Deletion_Addition_via_NetAct.robot
Resource    ../../test_resources/CM/CM__Commissioning__Planned_Commissioning.robot
Resource    ../../test_resources/CM/CM__Fullrack_Uncommissioned_Secondary_Core.robot
Resource    ../../test_resources/CM/CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
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

SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_xxx    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1912_2ASIB_2ABIA_1ABIL_1ABIN_1ABIO_1ABIQ_1FXED_1AHFIG_1FXJB_1AHFIB_1AHEGC_1AHDB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RP002086_CM_044_Provision SBTS plan to delete and add LTE cell
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    [Teardown]    Run Keywords    SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_xxx    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1912_2ASIB_2ABIA_1ABIL_1ABIN_1ABIO_1ABIQ_1FXED_1AHFIG_1FXJB_1AHFIB_1AHEGC_1AHDB
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_026_Verify_Reset_for_5G_HW_Objects_via_HWRESET
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_xxx    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1912_2ASIB_2ABIA_1ABIL_1ABIN_1ABIO_1ABIQ_1FXED_1AHFIG_1FXJB_1AHFIB_1AHEGC_1AHDB
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}    [1.0] SyVe_CM_Verify_HWRESETREQ_With_RMOD_Reset_LTE3296
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    ...    AND    Set Library Search Order    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    [Teardown]    Run Keywords    SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_xxx    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1912_2ASIB_2ABIA_1ABIL_1ABIN_1ABIO_1ABIQ_1FXED_1AHFIG_1FXJB_1AHFIB_1AHEGC_1AHDB
    [Timeout]    2h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_026_Verify_Reset_for_5G_HW_Objects_via_HWRESET
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    [Teardown]    Run Keywords    SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_xxx  CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1912_2ASIB_2ABIA_1ABIL_1ABIN_1ABIO_1ABIQ_1FXED_1AHFIG_1FXJB_1AHFIB_1AHEGC_1AHDB
    [Timeout]    2h
    [Setup]    Run Keywords      Set Test Variable    ${test_run}    [1.0] RP002086_CM_047_Provision SBTS plan to delete and add LTE RAT
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_SR002086_4G_RAT_Deletion_Addition_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_RAT_Deletion_Addition_via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_xxx    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1912_2ASIB_2ABIA_1ABIL_1ABIN_1ABIO_1ABIQ_1FXED_1AHFIG_1FXJB_1AHFIB_1AHEGC_1AHDB
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_012_5G_RAT_Deletion_Addition_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_RAT_Deletion_Addition_via_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_RAT_Deletion_Addition_via_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_RAT_Deletion_Addition_via_NetAct
    SyVe_CM_RP002956_5G_RAT_Deletion_Addition_via_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_RAT_Deletion_Addition_via_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_RP002956_5G_Cell_Deletion_Addition_Via_NetAct
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_xxx    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1912_2ASIB_2ABIA_1ABIL_1ABIN_1ABIO_1ABIQ_1FXED_1AHFIG_1FXJB_1AHFIB_1AHEGC_1AHDB
    [Timeout]    2h
    [Setup]    Run Keywords      Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_016_5G_Cell_Deletion_Addition_via_NetAct
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
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
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_xxx    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1912_2ASIB_2ABIA_1ABIL_1ABIN_1ABIO_1ABIQ_1FXED_1AHFIG_1FXJB_1AHFIB_1AHEGC_1AHDB
    [Timeout]    2h
    [Setup]    Run Keywords     Set Test Variable    ${test_run}    [2.0] SRAN_SyVe_RP002956_022_Verify_5G_Cell_Lock_Unlock_via_NetAct CM
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct
    ...    AND    Set Library Search Order    SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct
    SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct
    [Teardown]    Run Keywords    SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

CM__Fullrack_Uncommissioned_Secondary_Core
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_xxx
    ...    CLOUD_SRAN_NLWG_1912_2ASIB_2ABIA_1ABIL_1ABIN_1ABIO_1ABIQ_1FXED_1AHFIG_1FXJB_1AHFIB_1AHEGC_1AHDB
    [Setup]    Run Keywords    Modify Resource Search Order    ca_HZ_SBTS_AdminAPI_CM
    ...    AND    Set Test Variable    ${test_run}    [1.0] Automated__CM__Fullrack_Uncommissioned_Secondary_Core
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
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

CM__Commissioning__Planned_Commissioning
    [Tags]        SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_xxx
    ...    CLOUD_SRAN_NLWG_1912_2ASIB_2ABIA_1ABIL_1ABIN_1ABIO_1ABIQ_1FXED_1AHFIG_1FXJB_1AHFIB_1AHEGC_1AHDB
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] Automated__CM__Commissioning__Planned_Commissioning
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    Set Library Search Order    XML
    ...    AND    Modify Resource Search Order   CM__Commissioning__Planned_Commissioning
    ...    AND    Set Library Search Order    CM__Commissioning__Planned_Commissioning
    ...    AND    CM__Commissioning__Planned_Commissioning.CaseSetUp
    [Timeout]      2h
    CM__Commissioning__Planned_Commissioning
    [Teardown]    Run Keywords    CM__Commissioning__Planned_Commissioning.CaseTearDown
    ...    AND    Restore Resource Search Order

CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_ST    QC_xxx    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NLWG_1912_2ASIB_2ABIA_1ABIL_1ABIN_1ABIO_1ABIQ_1FXED_1AHFIG_1FXJB_1AHFIB_1AHEGC_1AHDB
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CM_Repeat_BB_Module_Lock_Unlock_via_WebEM
    ...    AND    Set Test Variable    ${REPEAT_TIME}    1
    ...    AND    Set Test Variable    ${qc_instance_id}    xxx
    ...    AND    Set Library Search Order    XML
    ...    AND    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI.SetUp
    ...    AND    Modify Resource Search Order    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI
    ...    AND    Set Library Search Order    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI
    [Timeout]    2h
    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI
    [Teardown]    Run Keywords    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI.CaseTearDown
    ...    AND    Restore Resource Search Order