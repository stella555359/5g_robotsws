*** Settings ***
Documentation
...  ABIO Performance Testcases

Resource   ../../../performance_keywords.robot
Resource   ../../../performance_multivm.robot
Resource   ../../../performance_test_setup.robot

Suite Setup       performance_test_setup.Suite Setup for Performance Test
Suite Teardown    performance_test_setup.Suite Teardown for Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Variables ***
${EGATE_FILES_DIR}    ${PERF_RESOURCES_DIR}/features/Performance/ABIO/


*** Test Cases ***
fdd_1Cell_100Ues_ABIO
    [Documentation]    Performance Test for FDD ABIO configuration with 100 UEs attached to 1 Cell and running UL+DL traffic simultaneously
    ...                Topology: CLOUD_5G_I_LO_AP_[LOOO][LOOO][LOOO]
    ...                Variant: SANSA_FS_CPRI_CMWV_FDD_12CELLS_FULL_TMO_GMC
    ...                Cells 1-3  <--> GNB RF1-RF3 <--> AP1
    ...                Cells 4-6  <--> GNB RF4-RF6 <--> AP2
    ...                Cells 7-12 <--> GNB RF7-RF9 <--> AP3
    [Setup]    performance_test_setup.Test Case Setup For Performance Test

    Set Test Variable    ${QC_TEST_NAME}    [1]L2PS_performance_indicator_check_fdd_1Cell_100UEs_ULDL
    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/ABIO_performance.qc

    &{args}    performance_keywords.Prepare WTS Manager Args             start_cell=1
    ...                                                                    end_cell=12
    ...                                                                 ue_per_cell=100
    ...                                                             expect_ue_count=100,0,0,0,0,0,0,0,0,0,0,0
    ...                                                                active_cells=1
    ...                                                               trf_direction=both
    ...                                                                        rate=kbps
    ...                                                                 ul_datarate=2400
    ...                                                                 dl_datarate=4100
    ...                                                             egate_files_dir=${EGATE_FILES_DIR}
    ...    cfg_sim_file_1=cfg_sim file=sansa_fdd_ap1.lua entry=run_configuration()
    ...    cfg_sim_file_2=cfg_sim file=sansa_fdd_ap2.lua entry=run_configuration()
    ...    cfg_sim_file_3=cfg_sim file=sansa_fdd_ap3.lua entry=run_configuration()
    ...    script_file_1=script file=commands_fdd_ap1.lua entry=pet_seql2_start_100UE_ULDL
    ...    script_file_2=no_operations
    ...    script_file_3=no_operations

    ${args_str}    Catenate
    ...    {
    ...        "start_cell": 1,
    ...        "end_cell": 12,
    ...        "ue_per_cell": 100,
    ...        "expect_ue_count": "100,0,0,0,0,0,0,0,0,0,0,0",
    ...        "active_cells": "1",
    ...        "trf_direction": "both",
    ...        "ul_datarate": 2400,
    ...        "dl_datarate": 4100,
    ...        "rate": "kbps",
    ...        "egate_script_delay_per_vm": "1s",
    ...        "egate_files_dir": "${EGATE_FILES_DIR}",
    ...        "cfg_sim_files": [
    ...           [1, "sansa_fdd_ap1.lua", "run_configuration()"],
    ...           [2, "sansa_fdd_ap2.lua", "run_configuration()"],
    ...           [3, "sansa_fdd_ap3.lua", "run_configuration()"]
    ...        ],
    ...        "script_files": [
    ...           [1, "commands_fdd_ap1.lua", "pet_seql2_start_100UE_ULDL"],
    ...           [2, "no_operations", "no_operations"],
    ...           [3, "no_operations", "no_operations"]
    ...        ]
    ...    }
    &{args_json}    Evaluate    json.loads('''${args_str}''')    modules=json
    &{args}    performance_keywords.Prepare WTS Manager Args    &{args_json}

    performance_multivm.Run MultiVM PET Testcase    ${args}

    ${total_ue_count}    performance_keywords.Get Total Expected UE Count    ${args}
    Run Keyword And Continue On Failure     performance_multivm.Wait Until Expected UE Count Reached
    ...    ${args}
    ...    timeout=5 min
    ...    expected_ue_count_per_cell=${args.expect_ue_count}
    Run Keyword And Continue On Failure     performance_multivm.Collect Traffic Logs    ${args}
