*** Settings ***
Documentation
...  CNI-152144 Testcases

Resource   ../../performance_keywords.robot
Resource   ../../performance_multivm.robot
Resource   ../../performance_test_setup.robot

Suite Setup       performance_test_setup.Suite Setup for Performance Test
Suite Teardown    performance_test_setup.Suite Teardown for Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Variables ***
${EGATE_FILES_DIR}    ${PERF_RESOURCES_DIR}/features/CB014680/egate/abip/


*** Test Cases ***

CNI-152144_testcase
    [Documentation]
    ...    Author: noli.valdez@nokia.com
    ...    Contact/s: stefan.bohl@nokia.com
    ...    Topology:
    ...      - ABIP: CLOUD_5G_I_MP_AP_[LOOO][LOOO][LOOO] / SANSA_FS_CPRI_CMWV_FDD_15Cells+ECPRI_CMWV_TDD_6Cells_tdLte1116_0m4s
    ...
    ...    > Based on CB014680_ABIP:TDD_ABIP_6Cells_2CellsPerL2SP_FDD_ABIP_15Cells_5CellsPerL2SP_3CC_CA
    ...    > Modified for https://jiradc.ext.net.nokia.com/browse/VRFULMPERF-85

    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...    ENABLE_ACT_BSR=auto
    ...    RDCFG_0x580179=0xC37D # rdPDSCHSkipSpecialSlotOlcPerCent

    ${args_str}    Catenate
    ...    {
    ...        "start_cell": 1,
    ...        "end_cell": 21,
    ...        "ue_per_cell": 95,
    ...        "expect_ue_count": "90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,0,0,0,0,0,0",
    ...        "active_cells": "all",
    ...        "egate_script_delay_per_vm": "3mins",
    ...        "egate_files_dir": "${EGATE_FILES_DIR}",
    ...        "cfg_sim_files": [
    ...           [1, "sansa_tdd_ap1.lua", "run_configuration()"],
    ...           [2, "sansa_fdd_ap2_CA_AHFIB.lua", "run_configuration()"],
    ...           [3, "sansa_fdd_ap3.lua", "run_configuration()"]
    ...        ],
    #  [VRFULMPERF-67] Process VM3 first then 2, lastly 1
    ...        "script_files": [
    ...           [3, "no_operations", "no_operations"],
    ...           [2, "commands_fdd_ap2_FDD_CA.lua", "pet_seql2_start_100UE_DLUL"],
    ...           [1, "commands_tdd_ap1.lua", "PET_1208FF_nonBF_90UE_DLUL"]
    ...        ]
    ...    }
    &{args_json}    Evaluate    ${args_str}
    &{args}    performance_keywords.Prepare WTS Manager Args    &{args_json}

    performance_multivm.Run MultiVM PET Testcase    ${args}

    Run Keyword And Continue On Failure     performance_multivm.Wait Until Expected UE Count Reached    ${args}
    ...                                                             expected_ue_count_per_cell=${args.expect_ue_count}
    Run Keyword And Continue On Failure     performance_multivm.Collect Traffic Logs    ${args}