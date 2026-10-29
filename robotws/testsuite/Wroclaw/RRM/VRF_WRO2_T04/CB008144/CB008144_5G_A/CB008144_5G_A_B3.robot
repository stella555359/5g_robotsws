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
    ...         AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...         AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_a_b3_activation.json
    ...         AND             Set Counter Collecting Interval To Five Minutes
    ...         AND             Wait For Next Full Pm Interval
    ...         AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown     Run Keywords     Roll Delta Back   initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                                               delta_scf_filename=delta_a_b3_activation.json
    ...            AND              Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***

CB008144_5G_A_B3_2_UE_Release_CP_Initiated_RRC_Reject
    [Documentation]    Test case checks correct incrementation of two counters in case of F1AP:UE CONTEXT RELEASE COMMAND.
    ...                M55113C03001 indicates the number of RRC Connection rejections per cell, and is updated for
    ...                ongoing RRC Setup procedure. Counter M55113C03002 indicates the number of RRC Reestablishment
    ...                rejections per cell, and is updated for ongoing RRC Reestablishment procedure.
    ...                Parameter "maxNumOfRrcSA - Maximum number of RRC connected users in a New Radio cell for SA"
    ...                is set to 1 for NRCELL-1 and set to 0 for NRCELL-2. After attempting to attach two UEs, one of them
    ...                has to be released and counter M55113C03001 is incremented. Counter M55113C03002 is not incremented
    ...                due to lack of RRC reestablishment. Requirement ID: 5G_RAN_USR_RRM_15324.

    [Setup]            Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Attach UE    ue_id=1
    Attach UE Without Confirmation    ue_id=2
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMMAND}   number_of_messages=0   relation_symbol= >
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}   number_of_messages=0   relation_symbol= >
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55113C03001   +1    NRD_RRC_STPREQ_PER_CELL_REJ_CU
    ...    M55113C03002   +0    NRD_RRC_REESTREQ_CELL_REJ_CU
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    [Teardown]    Run Keywords        Add Scout External Execution ID To Reporting Portal
    ...           AND                 Deregister Ue Without Confirmation    ue_id=1-2
    ...           AND                 Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB008144_5G_A_B3_3_UE_Release_CP_Initiated_RRC_Reestablishment_Reject
    [Documentation]    Test case checks correct incrementation of counter M55113C03002. Parameter "rrcReestabTypeSA
    ...                - RRC reestablishment type in SA" is set to "sameGNB" to avoid RRC Reestablishment to another gNB.
    ...                After UE RRC reestablishment procedure counter M55113C03002 should be updated.
    ...                Requirement ID: 5G_RAN_USR_RRM_15324.

    [Setup]        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Attach UE     ue_id=3
    Initiate UE RRC Reestablishment    ue_id=3    pass_regexp=RRC Reestablishment failed. Releasing RRC connection.
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMMAND}   number_of_messages=0   relation_symbol= >
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55113C03001   +0    NRD_RRC_STPREQ_PER_CELL_REJ_CU
    ...    M55113C03002   +1    NRD_RRC_REESTREQ_CELL_REJ_CU
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    [Teardown]     Run Keywords     Add Scout External Execution ID To Reporting Portal
    ...            AND              Deregister Ue Without Confirmation    ue_id=1-4
    ...            AND              Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
