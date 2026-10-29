*** Settings ***
Documentation
...  CB014179 ABIO Testcases

Resource   ../../performance_keywords.robot
Resource   ../../performance_multivm.robot

Suite Setup       performance_test_setup.Suite Setup for Performance Test
Suite Teardown    performance_test_setup.Suite Teardown for Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Variables ***
${EGATE_FILES_DIR}    ${PERF_RESOURCES_DIR}/features/CB014179/egate/abio/


*** Test Cases ***
tdd_3cells_varUEs_UL_ABIO_CB014179_pooling
    [Documentation]    Replaces tdd_3cells_varUEs_UL_ABIO_CB014179_pooling
    ...                Topology: CLOUD_5G_I_LO_AP_[LOOO][LOOO][LOOO]
    ...                Variant: SANSA_FS_ECPRI_CMWV_TDD_6CELLS_FULL_GMC
    ...                Cells 1-3 <--> GNB RF1-RF3 <--> AP1
    ...                Cells 4-6 <--> GNB RF7-RF9 <--> AP3
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                                                SCF_ENABLE_BB_POOLING=true
    ...                                                SCF_SET_NRBTS_actBbPoolExtensionTddFr1=true
    ...                                                SCF_ENABLE_BEAMFORMING=true
    ...                                                SCF_CONFIGURE_SRS=true
    ...                                                SCF_SET_VAR_NRCELL_actUlSrsBm=true
    ...                                                SCF_SET_VAR_NRCELL_actDlSrsBm=true

    ${QC_TEST_NAME_tmp}             Catenate    SEPARATOR=    [1]USCB014179-B#1_Maximum_number_of_
    ...                             PUSCH_UEs_per_slot_per_BB_pool_and_L1_subpool_on_half_ABIO_
    ...                             with_3_FR1_TDD_eCPRI_cells
    Set Test Variable   ${QC_TEST_NAME}    ${QC_TEST_NAME_tmp}
    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/CB014179_B_TC01.qc

    ${args_str}    Catenate
    ...    {
    ...        "start_cell": 1,
    ...        "end_cell": 6,
    ...        "ue_per_cell": 16,
    ...        "expect_ue_count": "16,16,8,0,0,0",
    ...        "cell_max_ue": "16,16,8,0,0,0",
    ...        "active_cells": "1,2,3",
    ...        "trf_direction": "ul",
    ...        "cell_ul_throughput": "15000,15000,30000,0,0,0",
    ...        "rate": "kbps",
    ...        "egate_script_delay_per_vm": "1s",
    ...        "egate_files_dir": "${EGATE_FILES_DIR}",
    ...        "cfg_sim_files": [
    ...           [1, "sansa_tdd_ap1.lua", "run_configuration()"],
    ...           [2, "no_operations", "no_operations"],
    ...           [3, "sansa_tdd_ap3.lua", "run_configuration()"]
    ...        ],
    ...        "script_files": [
    ...           [1, "commands_tdd_ap1.lua", "tdd_3cells_varUEs_UL"],
    ...           [2, "no_operations", "no_operations"],
    ...           [3, "no_operations", "no_operations"]
    ...        ]
    ...    }
    &{args_json}    Evaluate    json.loads('''${args_str}''')    modules=json
    &{args}    performance_keywords.Prepare WTS Manager Args    &{args_json}

    performance_multivm.Run MultiVM PET Testcase    ${args}

    Run Keyword And Continue On Failure     performance_multivm.Wait Until Expected UE Count Reached
    ...    ${args}
    ...    timeout=5 min
    ...    expected_ue_count_per_cell=${args.expect_ue_count}
    Run Keyword And Warn On Failure    performance_ttitrace.Quick TTI Trace Collection
    ...    tti_trace_duration=3
    ...    tti_trace_filename=tti_test_script
    performance_log_collection.Convert TTI Traces QUICK
    Run Keyword And Continue on Failure     performance_multivm.Collect Traffic Logs    ${args}
    performance_ttitrace.Check TTI Trace Total Number of Sched UEs Per L1Pool  count=40
    performance_verification.Verify CB014179-B-TC01 Counters

