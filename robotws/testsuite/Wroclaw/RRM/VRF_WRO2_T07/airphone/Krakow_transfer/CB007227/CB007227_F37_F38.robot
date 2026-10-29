*** Settings ***
Force Tags    RAN_5G    RAN_5G_FDD    PY310    CONFIGURED    CLOUD_5G_I_MP_AP_LO
...           SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    SBTS00    SBTS23R4    NoResUsage    RF50

Documentation
...            title:        CB007227-F PCMD measurements for U-Plane throughput exploratory scenario
...            author:       Bartosz Szlezak, bartosz.szlezak@nokia.com,
...                          Marcin Duplaga, marcin.duplaga@nokia.com,
...                          Piotr Bartkowski, piotr.bartkowski@nokia.com
...            maintainer:   Piotr Bartkowski, piotr.bartkowski@nokia.com


Resource    CB007227_Keywords.robot


Suite Setup      Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...              AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...              AND             Start Multiple Vm Ethernet Interfaces With Different Ips
...                              if_name_with_ip_list=[eth3:gNB3_NG, 10.0.1.30/24], [eth3:gNB3_XN, 10.44.76.28/24],
...              AND             Find Scfc And Send Delta Commissioning    scfc_filename=Delta_PCMD_NRMTRACECUUP_tracing.json
...              AND             Find Scfc And Send Delta Commissioning    scfc_filename=Delta_U_Plane_measurements_throughput.json
...              AND             Check Radios Availability
...              AND             Reach Onair    lua_cfg=${CURDIR}/configs/egate_2c_tdd_sansa.lua
...              AND             Start Server Interface
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords   Roll Delta Back
    ...                          initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                          delta_scf_filename=Delta_PCMD_NRMTRACECUUP_tracing.json
    ...           AND            Roll Delta Back
    ...                          initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                          delta_scf_filename=Delta_U_Plane_measurements_throughput.json
    ...           AND            Stop Default Processes And Gather Logs And Compress Logs

Test Setup      Run Keywords     Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...         AND              Setup PCMD

Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...          AND             Deregister UE    ue_id=${first_ue_id}
    ...          AND             Deregister UE    ue_id=${second_ue_id}
    ...          AND             Teardown PCMD
    ...          AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    check_errors_or_warnings=both

*** Variables ***
${first_ue_id}     1
${second_ue_id}    2

*** Test Cases ***
[1]CB007227-5G-F_37_US10_PCMD_measurements_for_U-Plane_throughput_exploratory_scenario
    Wait For Next Full Pm Interval
    Clear Already Collected PCMD Reports
    Register and Start Traffic And Save Alias For UE    the_ue_id=${first_ue_id}    ue_alias=1
    Register and Start Traffic And Save Alias For UE    the_ue_id=${second_ue_id}    ue_alias=2
    Sleep    20s    reason=Wait until at least 5 reports (4096 ms each) are sent to TCE
    Verify Both Traffic For UE    the_ue_id=${first_ue_id}
    Verify Both Traffic For UE    the_ue_id=${second_ue_id}
    Stop Internal SA Traffic     ue_id=1     pdu_id=1
    Stop Internal SA Traffic     ue_id=2     pdu_id=2
    ${pm_counter_path}    Get Next Unpacked Full Pm Counters File
    ...    output_dirpath=${OUTPUT_DIR}/PM_COUNTERS
    Perform PCMD Record Verification    ue_alias=1    PM_counters=${pm_counter_path}    ran_ue_id=${first_ran_ue_id}
    Perform PCMD Record Verification    ue_alias=2    PM_counters=${pm_counter_path}    ran_ue_id=${second_ran_ue_id}

    Clear Already Collected PCMD Reports
    Start Data Traffic                    ues=${first_ue_id}     pdu=${first_ue_id}     direction=both     throughput=10mbps
    Start Data Traffic                    ues=${second_ue_id}     pdu=${second_ue_id}     direction=both     throughput=10mbps
    Sleep    20s    reason=Wait until at least 5 reports (4096 ms each) are sent to TCE
    Verify Both Traffic For UE    the_ue_id=${first_ue_id}
    Verify Both Traffic For UE    the_ue_id=${second_ue_id}
    Stop Internal SA Traffic     ue_id=1     pdu_id=1
    Stop Internal SA Traffic     ue_id=2     pdu_id=2
    ${pm_counter_path}    Get Next Unpacked Full Pm Counters File
    ...    output_dirpath=${OUTPUT_DIR}/PM_COUNTERS
    Perform PCMD Record Verification    ue_alias=1    PM_counters=${pm_counter_path}    ran_ue_id=${first_ran_ue_id}
    Perform PCMD Record Verification    ue_alias=2    PM_counters=${pm_counter_path}    ran_ue_id=${second_ran_ue_id}

    Clear Already Collected PCMD Reports
    Start Data Traffic                    ues=${first_ue_id}     pdu=${first_ue_id}     direction=both     throughput=10mbps
    Start Data Traffic                    ues=${second_ue_id}     pdu=${second_ue_id}     direction=both     throughput=10mbps
    Sleep    20s    reason=Wait until at least 5 reports (4096 ms each) are sent to TCE
    Verify Both Traffic For UE    the_ue_id=${first_ue_id}
    Verify Both Traffic For UE    the_ue_id=${second_ue_id}
    Stop Internal SA Traffic     ue_id=1     pdu_id=1
    Stop Internal SA Traffic     ue_id=2     pdu_id=2
    ${pm_counter_path}    Get Next Unpacked Full Pm Counters File
    ...    output_dirpath=${OUTPUT_DIR}/PM_COUNTERS
    Perform PCMD Record Verification    ue_alias=1    PM_counters=${pm_counter_path}    ran_ue_id=${first_ran_ue_id}
    Perform PCMD Record Verification    ue_alias=2    PM_counters=${pm_counter_path}    ran_ue_id=${second_ran_ue_id}
