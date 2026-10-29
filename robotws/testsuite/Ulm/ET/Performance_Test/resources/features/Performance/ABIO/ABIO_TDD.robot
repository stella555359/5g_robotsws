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
tdd_1Cell_100Ues_ABIO_pooling
    [Documentation]    Performance Test for TDD ABIO configuration with 100 UEs attached to 1 Cell and running UL+DL traffic simultaneously
    ...                Topology: CLOUD_5G_I_LO_AP_[LOOO][LOOO][LOOO]
    ...                Variant: SANSA_FS_ECPRI_CMWV_TDD_6CELLS_FULL_GMC
    ...                Cells 1-3 <--> AP1
    ...                Cells 4-6 <--> AP3
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    SCF_ENABLE_BB_POOLING=true
    ...                                                SCF_ENABLE_BEAMFORMING=true
    ...                                                SCF_CONFIGURE_SRS=true
    ...                                                SCF_SET_VAR_NRCELL_actUlSrsBm=true
    ...                                                SCF_SET_VAR_NRCELL_actDlSrsBm=true

    Set Test Variable    ${QC_TEST_NAME}    [1]L2PS_performance_indicator_check_tdd_1Cell_100UEs_ULDL_pooling
    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/ABIO_performance.qc

    ${args_str}    Catenate
    ...    {
    ...        "start_cell": 1,
    ...        "end_cell": 6,
    ...        "ue_per_cell": 100,
    ...        "expect_ue_count": "100,0,0,0,0,0",
    ...        "active_cells": "1",
    ...        "trf_direction": "both",
    ...        "ul_datarate": 2300,
    ...        "dl_datarate": 16300,
    ...        "rate": "kbps",
    ...        "egate_script_delay_per_vm": "1s",
    ...        "egate_files_dir": "${EGATE_FILES_DIR}",
    ...        "cfg_sim_files": [
    ...           [1, "sansa_tdd_ap1.lua", "run_configuration()"],
    ...           [2, "no_operations", "no_operations"],
    ...           [3, "sansa_tdd_ap3.lua", "run_configuration()"]
    ...        ],
    ...        "script_files": [
    ...           [1, "commands_tdd_ap1.lua", "PET_1208FF_nonBF_100UE_DLUL"],
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


tdd_6cells_1200Ues_8DL8UL_MUMIMO_ABIO_pooling
    [Documentation]    Performance Test for TDD ABIO configuration with 1200 UEs distributed to 6 Cell and running UL+DL traffic simultaneously
    ...                Topology: CLOUD_5G_I_LO_AP_[LOOO][LOOO][LOOO]
    ...                Variant: SANSA_FS_ECPRI_CMWV_TDD_6CELLS_FULL_8x4MIMO_8DL8UL_GMC
    ...                Cells 1-3 <--> AP1
    ...                Cells 4-6 <--> AP3
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                                                              ENABLE_ACT_BSR=auto

    Set Test Variable    ${QC_TEST_NAME}    [1]TDD_Fr1_MuMIMO_8DL8UL_pooling_ABIO
    Set Test Variable    ${QC_PATH}    testsuite/Ulm/ET/Performance_Test/resources/qc/ABIO_performance.qc

    ${args_str}    Catenate
    ...    {
    ...        "start_cell": 1,
    ...        "end_cell": 6,
    ...        "ue_per_cell": 200,
    ...        "expect_ue_count": "200,200,200,200,200,200",
    ...        "trf_direction": "both",
    ...        "ul_datarate": 1100,
    ...        "dl_datarate": 4750,
    ...        "rate": "kbps",
    ...        "tolerance": 0.2,
    ...        "egate_script_delay_per_vm": "4mins",
    ...        "egate_files_dir": "${EGATE_FILES_DIR}",
    ...        "cfg_sim_files": [
    ...           [1, "sansa_tdd_6cells_mumimo_ap1.lua", "run_configuration()"],
    ...           [2, "no_operations", "no_operations"],
    ...           [3, "sansa_tdd_6cells_mumimo_ap3.lua", "run_configuration()"]
    ...        ],
    ...        "script_files": [
    ...           [1, "commands_tdd_ap1.lua", "PET_1070FF_MUMIMO_SRSBF_1200UE_DLUL"],
    ...           [2, "no_operations", "no_operations"],
    ...           [3, "commands_tdd_ap3.lua", "PET_1070FF_MUMIMO_SRSBF_1200UE_DLUL"]
    ...        ]
    ...    }
    &{args_json}    Evaluate    json.loads('''${args_str}''')    modules=json
    &{args}    performance_keywords.Prepare WTS Manager Args    &{args_json}

    performance_multivm.Run MultiVM PET Testcase    ${args}

    ${total_ue_count}    performance_keywords.Get Total Expected UE Count    ${args}
    Run Keyword And Continue On Failure     performance_multivm.Wait Until Expected UE Count Reached
    ...    ${args}
    ...    timeout=10 min
    ...    expected_ue_count_per_cell=${args.expect_ue_count}
    Run Keyword And Continue On Failure     performance_multivm.Collect Traffic Logs    ${args}


TDD_FR2_2S_8CC_53UEsPerSector
    [Documentation]    Performance Test for ABIO TDD FR2 2S 8CC configuration with 53 UEs per sector and running UL+DL traffic simultaneously
    ...                Topology: CLOUD_5G_I_LO_AP_[LOOO][LOOO][LOOO]
    ...                Variant: SANSA_FS_ECPRI_FR2_TDD_2S_8CC_53UesPerSector
    ...                Cells 1-8  <--> AP1
    ...                Cells 9-16 <--> AP3
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ${args_str}    Catenate
    ...    {
    ...        "start_cell": 1,
    ...        "end_cell": 16,
    ...        "ue_per_cell": 53,
    ...        "expect_ue_count": "53,0,0,0,0,0,0,0,53,0,0,0,0,0,0,0",
    ...        "active_cells": "1,9",
    ...        "trf_direction": "both",
    ...        "ul_datarate": 10789,
    ...        "dl_datarate": 32603,
    ...        "rate": "kbps",
    ...        "egate_script_delay_per_vm": "1m",
    ...        "egate_files_dir": "${EGATE_FILES_DIR}",
    ...        "cfg_sim_files": [
    ...           [1, "sansa_tdd_fr2_2s_8cc_ap1.lua", "run_configuration(8600)"],
    ...           [2, "no_operations", "no_operations"],
    ...           [3, "sansa_tdd_fr2_2s_8cc_ap3.lua", "run_configuration(8600)"]
    ...        ],
    ...        "script_files": [
    ...           [1, "commands_tdd_ap1.lua", "TDD_FR2_2S_8CC_53UEsPerSector"],
    ...           [2, "no_operations", "no_operations"],
    ...           [3, "commands_tdd_ap3.lua", "TDD_FR2_2S_8CC_53UEsPerSector"]
    ...        ]
    ...    }
    &{args_json}    Evaluate    json.loads('''${args_str}''')    modules=json
    &{args}    performance_keywords.Prepare WTS Manager Args    &{args_json}

    performance_multivm.Run MultiVM PET Testcase    ${args}

    ${total_ue_count}    performance_keywords.Get Total Expected UE Count    ${args}
    Run Keyword And Continue On Failure     performance_multivm.Wait Until Expected UE Count Reached
    ...    ${args}
    ...    ${total_ue_count}
    ...    timeout=5 min
    ...    expected_ue_count_per_cell=${args.expect_ue_count}
    Run Keyword And Continue On Failure     performance_multivm.Collect Traffic Logs    ${args}


TDD_FR2_1S_8CC_106UEsPerSector
    [Documentation]    Performance Test for ABIO TDD FR2 1S 8CC configuration with 106 UEs per sector and running UL+DL traffic simultaneously
    ...                Topology: CLOUD_5G_I_LO_AP_[LOOO][LOOO][LOOO]
    ...                Variant: SANSA_FS_ECPRI_FR2_TDD_1S_8CC_106UesPerSector
    ...                Cells 1-8  <--> AP1
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ${args_str}    Catenate
    ...    {
    ...        "start_cell": 1,
    ...        "end_cell": 8,
    ...        "ue_per_cell": 106,
    ...        "expect_ue_count": "106,0,0,0,0,0,0,0",
    ...        "active_cells": "1",
    ...        "trf_direction": "both",
    ...        "ul_datarate": 4000,
    ...        "dl_datarate": 16000,
    ...        "rate": "kbps",
    ...        "egate_script_delay_per_vm": "1s",
    ...        "egate_files_dir": "${EGATE_FILES_DIR}",
    ...        "cfg_sim_files": [
    ...           [1, "sansa_tdd_fr2_1s_8cc_ap1.lua", "run_configuration()"],
    ...           [2, "no_operations", "no_operations"],
    ...           [3, "no_operations", "no_operations"]
    ...        ],
    ...        "script_files": [
    ...           [1, "commands_tdd_ap1.lua", "TDD_FR2_1S_8CC_106UEsPerSector"],
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
    ...    ${total_ue_count}
    ...    timeout=5 min
    ...    expected_ue_count_per_cell=${args.expect_ue_count}
    Run Keyword And Continue On Failure     performance_multivm.Collect Traffic Logs    ${args}

