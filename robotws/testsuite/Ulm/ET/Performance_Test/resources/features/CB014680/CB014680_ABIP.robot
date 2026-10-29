*** Settings ***
Documentation
...  CB014680 Testcases

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
CB014680_4UE_with_1mbps_in_DL_UL
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...    RDCFG_0x580122=0 # rdAllocateMaxSchShareOnMixedSlot CB014680_D_package_4_activation 0_false 1_true
    ...    RDCFG_0x580308=3 # rdActCb014680OlcImprovement CB014680_B_package_2_activation 0_false 3_true
    ...    RDCFG_0x58026F=1 # rdEnableStatelessSchedLoadBalancer CB014680_A 0_false 1_true
    ...    ENABLE_ACT_BSR=auto

    ${args_str}    Catenate
    ...    {
    ...        "start_cell": 1,
    ...        "end_cell": 21,
    ...        "egate_script_delay_per_vm": "1s",
    ...        "egate_files_dir": "${EGATE_FILES_DIR}",
    ...        "cfg_sim_files": [
    ...           [1, "sansa_tdd_ap1.lua", "run_configuration()"],
    ...           [2, "sansa_fdd_ap2.lua", "run_configuration()"],
    ...           [3, "sansa_fdd_ap3.lua", "run_configuration()"]
    ...        ],
    ...        "script_files": [
    ...           [1, "commands_tdd_ap1.lua", "PET_1208FF_nonBF_4UE_DLUL"],
    ...           [2, "commands_fdd_ap2.lua", "pet_seql2_start_4UE_DLUL"],
    ...           [3, "commands_fdd_ap3.lua", "pet_seql2_start_4UE_DLUL"]
    ...        ]
    ...    }
    &{args_json}    Evaluate    json.loads('''${args_str}''')    modules=json
    &{args}    performance_keywords.Prepare WTS Manager Args    &{args_json}

    performance_multivm.Run MultiVM PET Testcase    ${args}

    Run Keyword And Continue On Failure     performance_multivm.Wait Until Expected UE Count Reached    ${args}
    Run Keyword And Continue On Failure     performance_multivm.Collect Traffic Logs    ${args}


CB014680_100UE_with_full_buffer_DL_UL
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...    RDCFG_0x580122=0 # rdAllocateMaxSchShareOnMixedSlot CB014680_D_package_4_activation 0_false 1_true
    ...    RDCFG_0x580308=3 # rdActCb014680OlcImprovement CB014680_B_package_2_activation 0_false 3_true
    ...    RDCFG_0x58026F=1 # rdEnableStatelessSchedLoadBalancer CB014680_A 0_false 1_true
    ...    ENABLE_ACT_BSR=auto

    ${args_str}    Catenate
    ...    {
    ...        "start_cell": 1,
    ...        "end_cell": 21,
    ...        "egate_script_delay_per_vm": "1s",
    ...        "egate_files_dir": "${EGATE_FILES_DIR}",
    ...        "cfg_sim_files": [
    ...           [1, "sansa_tdd_ap1.lua", "run_configuration()"],
    ...           [2, "sansa_fdd_ap2.lua", "run_configuration()"],
    ...           [3, "sansa_fdd_ap3.lua", "run_configuration()"]
    ...        ],
    ...        "script_files": [
    ...           [1, "commands_tdd_ap1.lua", "PET_1208FF_nonBF_100UE_DLUL"],
    ...           [2, "commands_fdd_ap2.lua", "pet_seql2_start_100UE_DLUL"],
    ...           [3, "commands_fdd_ap3.lua", "pet_seql2_start_100UE_DLUL"]
    ...        ]
    ...    }
    &{args_json}    Evaluate    json.loads('''${args_str}''')    modules=json
    &{args}    performance_keywords.Prepare WTS Manager Args    &{args_json}

    performance_multivm.Run MultiVM PET Testcase    ${args}

    Run Keyword And Continue On Failure     performance_multivm.Wait Until Expected UE Count Reached   ${args}
    Run Keyword And Continue On Failure     performance_multivm.Collect Traffic Logs    ${args}


CB014680_100UE_in_1cell_with_full_buffer_and_4UE_in_other_cells
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...    RDCFG_0x580122=0 # rdAllocateMaxSchShareOnMixedSlot CB014680_D_package_4_activation 0_false 1_true
    ...    RDCFG_0x580308=3 # rdActCb014680OlcImprovement CB014680_B_package_2_activation 0_false 3_true
    ...    RDCFG_0x58026F=1 # rdEnableStatelessSchedLoadBalancer CB014680_A 0_false 1_true
    ...    ENABLE_ACT_BSR=auto

    ${args_str}    Catenate
    ...    {
    ...        "start_cell": 1,
    ...        "end_cell": 21,
    ...        "egate_script_delay_per_vm": "1s",
    ...        "egate_files_dir": "${EGATE_FILES_DIR}",
    ...        "cfg_sim_files": [
    ...           [1, "sansa_tdd_ap1.lua", "run_configuration()"],
    ...           [2, "sansa_fdd_ap2.lua", "run_configuration()"],
    ...           [3, "sansa_fdd_ap3.lua", "run_configuration()"]
    ...        ],
    ...        "script_files": [
    ...           [1, "commands_tdd_ap1.lua", "PET_1208FF_nonBF_100UEinCell1_4UEinOtherCell_DLUL"],
    ...           [2, "commands_fdd_ap2.lua", "pet_seql2_start_100UEinCell1_4UEinOtherCell_DLUL"],
    ...           [3, "commands_fdd_ap3.lua", "pet_seql2_start_100UEinCell1_4UEinOtherCell_DLUL"]
    ...        ]
    ...    }
    &{args_json}    Evaluate    json.loads('''${args_str}''')    modules=json
    &{args}    performance_keywords.Prepare WTS Manager Args    &{args_json}

    performance_multivm.Run MultiVM PET Testcase    ${args}

    Run Keyword And Continue On Failure     performance_multivm.Wait Until Expected UE Count Reached   ${args}
    Run Keyword And Continue On Failure     performance_multivm.Collect Traffic Logs    ${args}


FDD_ABIP_15Cells_5CellsPerL2SP_3CC_CA
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...    ENABLE_ACT_BSR=auto
    ...    ENABLE_ONLINE_REPORTING=true
    ...    ENABLE_L2PERF=true
    ${QC_TEST_NAME}    Catenate     SEPARATOR=    [1]CB014680_A_TC02_B1_ALT1_Verification_of_the_performance_of_the_new_
    ...                                                              FR1_load_balancer_in_extremely_low_load_with_FDD_FR1
    Set Test Variable    ${QC_TEST_NAME}
    Set Test Variable    ${QC_PATH}         testsuite/Ulm/ET/Performance_Test/resources/qc/CB014680.qc

    ${args_str}    Catenate
    ...    {
    ...        "start_cell": 1,
    ...        "end_cell": 21,
    ...        "ue_per_cell": 90,
    ...        "expect_ue_count": "0,0,0,0,0,0,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90",
    ...        "egate_script_delay_per_vm": "1s",
    ...        "egate_files_dir": "${EGATE_FILES_DIR}",
    ...        "cfg_sim_files": [
    ...           [1, "sansa_tdd_ap1.lua", "run_configuration()"],
    ...           [2, "sansa_fdd_ap2_CA_AHFIB.lua", "run_configuration()"],
    ...           [3, "sansa_fdd_ap3.lua", "run_configuration()"]
    ...        ],
    ...        "script_files": [
    ...           [1, "no_operations", "no_operations"],
    ...           [2, "commands_fdd_ap2_FDD_CA.lua", "pet_seql2_start_100UE_DLUL"],
    ...           [3, "commands_fdd_ap3.lua", "pet_seql2_start_100UE_DLUL"]
    ...        ]
    ...    }
    &{args_json}    Evaluate    json.loads('''${args_str}''')    modules=json
    &{args}    performance_keywords.Prepare WTS Manager Args    &{args_json}

    performance_multivm.Run MultiVM PET Testcase    ${args}

    Run Keyword And Continue On Failure     performance_multivm.Wait Until Expected UE Count Reached    ${args}
    ...                                                             expected_ue_count_per_cell=${args.expect_ue_count}
    Run Keyword And Continue On Failure     performance_multivm.Collect Traffic Logs    ${args}

TDD_ABIP_6Cells_2CellsPerL2SP
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...    ENABLE_ACT_BSR=auto
    ...    ENABLE_ONLINE_REPORTING=true
    ...    ENABLE_L2PERF=true
    ${QC_TEST_NAME}    Catenate     SEPARATOR=    [1]CB014680_B_TC04_B1_
    ...                                                              ALT3_Verification_of_candidate_set_and_FDM_limit_adaptation_impacts_
    ...                                                              in_scheduler_performance_in_TDD_FR1_with_new_load_balancer_enabled
    Set Test Variable    ${QC_TEST_NAME}
    Set Test Variable    ${QC_PATH}         testsuite/Ulm/ET/Performance_Test/resources/qc/CB014680.qc

    ${args_str}    Catenate
    ...    {
    ...        "start_cell": 1,
    ...        "end_cell": 21,
    ...        "ue_per_cell": 100,
    ...        "expect_ue_count": "100,100,100,100,100,100,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
    ...        "active_cells": "1,2,3,4,5,6",
    ...        "egate_script_delay_per_vm": "1s",
    ...        "egate_files_dir": "${EGATE_FILES_DIR}",
    ...        "cfg_sim_files": [
    ...           [1, "sansa_tdd_ap1.lua", "run_configuration()"],
    ...           [2, "sansa_fdd_ap2_CA_AHFIB.lua", "run_configuration()"],
    ...           [3, "sansa_fdd_ap3.lua", "run_configuration()"]
    ...        ],
    ...        "script_files": [
    ...           [1, "commands_tdd_ap1.lua", "PET_1208FF_nonBF_100UE_DLUL"],
    ...           [2, "no_operations", "no_operations"],
    ...           [3, "no_operations", "no_operations"]
    ...        ]
    ...    }
    &{argd}    Evaluate    ${args_str}
    &{args}    performance_keywords.Prepare WTS Manager Args    &{argd}

    performance_multivm.Run MultiVM PET Testcase    ${args}
    Run Keyword And Continue On Failure     performance_multivm.Wait Until Expected UE Count Reached    ${args}
    Run Keyword And Continue On Failure     performance_multivm.Collect Traffic Logs    ${args}


FDD_ABIP_15Cells_5CellsPerL2SP_3CC_CA_CB014680_disabled
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...    RDCFG_0x580122=0 # rdAllocateMaxSchShareOnMixedSlot CB014680_D_package_4_activation 0_false 1_true
    ...    RDCFG_0x580308=0 # rdActCb014680OlcImprovement CB014680_B_package_2_activation 0_false 3_true
    ...    RDCFG_0x58026F=0 # rdEnableStatelessSchedLoadBalancer CB014680_A 0_false 1_true
    ...    ENABLE_ACT_BSR=auto
    ...    ENABLE_L2PERF=true

    ${args_str}    Catenate
    ...    {
    ...        "start_cell": 1,
    ...        "end_cell": 21,
    ...        "ue_per_cell": 100,
    ...        "expect_ue_count": "0,0,0,0,0,0,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90",
    ...        "egate_script_delay_per_vm": "1s",
    ...        "egate_files_dir": "${EGATE_FILES_DIR}",
    ...        "cfg_sim_files": [
    ...           [1, "sansa_tdd_ap1.lua", "run_configuration()"],
    ...           [2, "sansa_fdd_ap2_CA_AHFIB.lua", "run_configuration()"],
    ...           [3, "sansa_fdd_ap3.lua", "run_configuration()"]
    ...        ],
    ...        "script_files": [
    ...           [1, "no_operations", "no_operations"],
    ...           [2, "commands_fdd_ap2_FDD_CA.lua", "pet_seql2_start_100UE_DLUL"],
    ...           [3, "commands_fdd_ap3.lua", "pet_seql2_start_100UE_DLUL"]
    ...        ]
    ...    }
    &{argd}    Evaluate    ${args_str}
    &{args}    performance_keywords.Prepare WTS Manager Args    &{argd}

    performance_multivm.Run MultiVM PET Testcase    ${args}
    Run Keyword And Continue On Failure     performance_multivm.Wait Until Expected UE Count Reached    ${args}
    Run Keyword And Continue On Failure     performance_multivm.Collect Traffic Logs    ${args}

TDD_ABIP_6Cells_2CellsPerL2SP_CB014680_disabled
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...    RDCFG_0x580122=0 # rdAllocateMaxSchShareOnMixedSlot CB014680_D_package_4_activation 0_false 1_true
    ...    RDCFG_0x580308=0 # rdActCb014680OlcImprovement CB014680_B_package_2_activation 0_false 3_true
    ...    RDCFG_0x58026F=0 # rdEnableStatelessSchedLoadBalancer CB014680_A 0_false 1_true
    ...    ENABLE_ACT_BSR=auto
    ...    ENABLE_L2PERF=true

    ${args_str}    Catenate
    ...    {
    ...        "start_cell": 1,
    ...        "end_cell": 21,
    ...        "ue_per_cell": 100,
    ...        "expect_ue_count": "100,100,100,100,100,100,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
    ...        "active_cells": "1,2,3,4,5,6",
    ...        "egate_script_delay_per_vm": "1s",
    ...        "egate_files_dir": "${EGATE_FILES_DIR}",
    ...        "cfg_sim_files": [
    ...           [1, "sansa_tdd_ap1.lua", "run_configuration()"],
    ...           [2, "sansa_fdd_ap2_CA_AHFIB.lua", "run_configuration()"],
    ...           [3, "sansa_fdd_ap3.lua", "run_configuration()"]
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

    Run Keyword And Continue On Failure     performance_multivm.Wait Until Expected UE Count Reached    ${args}
    ...                                                             expected_ue_count_per_cell=${args.expect_ue_count}
    Run Keyword And Continue On Failure     performance_multivm.Collect Traffic Logs    ${args}


TDD_ABIP_6Cells_2CellsPerL2SP_FDD_ABIP_15Cells_5CellsPerL2SP_3CC_CA
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...    RDCFG_0x580122=0 # rdAllocateMaxSchShareOnMixedSlot CB014680_D_package_4_activation 0_false 1_true
    ...    RDCFG_0x580308=0 # rdActCb014680OlcImprovement CB014680_B_package_2_activation 0_false 3_true
    ...    RDCFG_0x58026F=0 # rdEnableStatelessSchedLoadBalancer CB014680_A 0_false 1_true
    ...    ENABLE_ACT_BSR=auto

    ${args_str}    Catenate
    ...    {
    ...        "start_cell": 1,
    ...        "end_cell": 21,
    ...        "ue_per_cell": 95,
    ...        "expect_ue_count": "90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90",
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
    ...           [3, "commands_fdd_ap3.lua", "pet_seql2_start_100UE_DLUL"],
    ...           [2, "commands_fdd_ap2_FDD_CA.lua", "pet_seql2_start_100UE_DLUL"],
    ...           [1, "commands_tdd_ap1.lua", "PET_1208FF_nonBF_90UE_DLUL"]
    ...        ]
    ...    }
    &{args_json}    Evaluate    json.loads('''${args_str}''')    modules=json
    &{args}    performance_keywords.Prepare WTS Manager Args    &{args_json}

    performance_multivm.Run MultiVM PET Testcase    ${args}

    Run Keyword And Continue On Failure     performance_multivm.Wait Until Expected UE Count Reached    ${args}
    ...                                                             expected_ue_count_per_cell=${args.expect_ue_count}
    Run Keyword And Continue On Failure     performance_multivm.Collect Traffic Logs    ${args}