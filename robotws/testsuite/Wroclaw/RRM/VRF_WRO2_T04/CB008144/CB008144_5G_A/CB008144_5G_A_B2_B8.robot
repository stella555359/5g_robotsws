*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED    5G_RAN_TDD    5G_RAN
...           SBTS00    RAN_5G    RAN_5G_TDD    CRT    SBTS23R2    PY310
...           NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Ewa Wrzesinska
...              :contact: ewa.wrzesinska@nokia.com
...              :testsuite description: Feature CB008144 introduces sleeping cell detection methods and recovery
...              actions to 5G. Detection and recovery actions are based on newly introduced counters.

Resource        ../CB008144_Keywords_And_Variables.robot

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
    ...         AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sansa_gscn_7880.lua
    ...         AND             Set Counter Collecting Interval To Five Minutes
    ...         AND             Perform Parameter Commissioning    parameter=miNrCCD   dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1
    ...                                                            value=5min
    ...         AND             Wait For Next Full Pm Interval
    ...         AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown     Run Keywords    Perform Parameter Commissioning    parameter=miNrCCD    dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1
    ...                                                               value=disabled
    ...            AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***

CB008144_5G_A_B2_3_Intra_gNB_DU_RRC_Connection_Reestablishment_Other_Failure
    [Documentation]    Test case checks counters which should be incremented after UE RRC Reestablishment procedure
    ...                due to undefined failure. Parameter "rrcReestabTypeSA" - "RRC reestablishment type in SA"
    ...                value equals "sameGNB". Counter M55166C00501 indicates the number of successful admissions for
    ...                initial SgNB addition procedures in CU-CP. Counter M55166C00504 indicates the total number of
    ...                RRC Reestablishment successes regardless of the cause for SA per cell at DU side.
    ...                Requirement ID: 5G_RAN_USR_RRM_15284.

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Attach UE    ue_id=2
    Establish PDU Session     ue_id=2    pdu_id=2    gw_id=2
    Initiate UE RRC Reestablishment    ue_id=2    cause=otherFailure
    Verify Tcpdump Log    packet_filter=${RRC_REESTABLISHMENT_REQUEST_OTHER_FAILURE}  number_of_messages=0  relation_symbol= >
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55166C00501   +1    NRD_RRC_REESTABREQ_PER_CELL
    ...    M55166C00504   +1    NRD_RRC_REESTREQ_PER_CELL_SUCC
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    [Teardown]     Run Keywords     Add Scout External Execution ID To Reporting Portal
    ...            AND              Deregister Ue Without Confirmation    ue_id=2
    ...            AND              Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008144_5G_A_B8_Initial_Context_Setup
    [Documentation]    Purpose of the test case is to check the correctness of NG Interface Communication recovery.
    ...                After UE Attach and PDU Session setup, keyword "Release UE Ctx" triggers AMF-initiated
    ...                UE NG Context Release procedure. When the UE is no longer in idle mode, the counter M55125C11001
    ...                should be updated second time. This counter indicates the number of NGAP: INITIAL UE MESSAGE which
    ...                resulted in successful establishment of UE-associated logical NG connection.
    ...                Requirement ID: 5G_RAN_USR_RRM_15285; 5G_RAN_USR_RRM_15106.
    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Attach UE    ue_id=8
    ...        AND             Establish PDU Session     ue_id=8   pdu_id=8   gw_id=8

    Release Ue Ctx    ue_id=8     timeout=80
    Exit Idle Mode    ue_id=8     timeout=10    pass_regexp=UE8: UE performed IM exit
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55125C11001   +2    NNGCC_UE_LOGICAL_CONN_ESTAB
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    [Teardown]     Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...            AND             Deregister Ue Without Confirmation    ue_id=8
    ...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
