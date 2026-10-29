*** Settings ***
Documentation
...  CNI140003 Testcases

Library    taf.sw.wtssim  # wts_manager -> taf_sw_wtssim_wrapper dependency

Library    ../../python/perf_keywords.py
Library    ../../python/wts_manager.py
Library    ../../python/wts_wrapper.py
Library    ./cni140003_kw.py

Resource   ../../performance_btslog.robot
Resource   ../../performance_keywords.robot
Resource   ../../performance_log_collection.robot
Resource   ../../performance_egate.robot
Resource   ../../performance_commissioning.robot
Resource   ../../performance_ttitrace.robot
Resource   ../../performance_test_setup.robot

Suite Setup       performance_test_setup.Suite Setup For Performance Test
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Variable ***
${TESTCASE_SETUP}    ${False}


*** Test Cases ***
CNI140003_TC1_A_ACT_CNI_Activation
    [Setup]    Test Case Setup For CNI140003 TC02
    Log to console    No test
    performance_snapshot.Collect Snapshot From Gnb And Save To Turandot
    [Teardown]    Test Case Teardown For CNI140003    ${TESTCASE_ARGS}


CNI140003_TC02_A_B1_PDSCH_skipping_on_special_slot_due_to_UL_overload_Basic_Scenario
    [Documentation]
    ...    Author: noli.valdez@nokia.com
    ...    Contact/s: stefan.bohl@nokia.com, mokhtar.derkaoui@nokia.com
    ...    Topology: CLOUD_5G_O_E_AP_2LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO
    ...    Summary: register X UE on cell 1 + UL traffic non-gbr
    ...    .        register X UE on cell 1 + UL/DL traffic gbr/non-gbr
    ...    .        register X UE on cell 3 + DL non-gbr
    [Setup]    Test Case Setup For CNI140003 TC02

    ${postargs_py}    cni140003_kw.Run CNI140003 TC2   ${TESTCASE_ARGS}

    [Teardown]    Test Case Teardown For CNI140003    ${postargs_py}


CNI140003_TC03_A_B1_PDSCH_skipping_on_special_slot_due_to_UL_overload_Alternative_Scenario_1
    [Documentation]
    ...    Author: noli.valdez@nokia.com, doreen.dellosa@nokia.com
    ...    Contact/s: stefan.bohl@nokia.com, mokhtar.derkaoui@nokia.com
    ...    Topology:
    ...             ASOE: CLOUD_5G_O_E_AP_2LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO
    ...             ABIP: CLOUD_5G_I_MP_AP_LOOO / SANSA_FS_ECPRI_CMWV_TDD_12CELL_CNI140003_TC03
    ...    Summary: tddFrameStructure_lteToNrFrameShift 3ms
    ...    .        register X UE on cell A + UL traffic non-gbr
    ...    .        register X UE on cell A + UL/DL traffic gbr/non-gbr
    ...    .        register X UE on cell B + DL non-gbr
    [Setup]    Test Case Setup For CNI140003 TC03

    Set To Dictionary    ${TESTCASE_ARGS}    enable_ttitrace    ${TTI_TRACE_PHYCELL}

    ${postargs_py}    cni140003_kw.Run CNI140003 TC2   ${TESTCASE_ARGS}

    [Teardown]    Test Case Teardown For CNI140003    ${postargs_py}


CNI140003_TC04_A_B1_PDSCH_skipping_on_special_slot_due_to_UL_overload_Alternative_Scenario_2_no_traffic
    [Documentation]
    ...    Author: doreen.dellosa@nokia.com
    ...    Contact/s: stefan.bohl@nokia.com, mokhtar.derkaoui@nokia.com
    ...    Topology:
    ...             ASOE: CLOUD_5G_O_E_AP_2LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO
    ...             ABIP: CLOUD_5G_I_MP_AP_LOOO / SANSA_FS_ECPRI_CMWV_TDD_12CELL_CNI140003_TC04
    ...    Summary: cell B: actAperCsi true
    ...    .        cell B: increasePUSCHPrepTimeULCA true
    ...    .        ~~cell B: actCellCsiRsImTddNonBf true~~
    ...    .        ~~cell B: actBeamforming false~~
    ...    .        register X UE on cell A
    ...    .        register X UE on cell A
    ...    .        register X UE on cell B
    [Setup]    Test Case Setup For CNI140003 TC02
    ...    SCF_SET_VAR_NRCELL_i4_actAperCsi=true
    ...    SCF_SET_VAR_NRCELL_i4_increasePUSCHPrepTimeULCA=true

    Set To Dictionary    ${TESTCASE_ARGS}    enable_ttitrace    ${TTI_TRACE_PHYCELL}

    ${postargs_py}    cni140003_kw.Run CNI140003 TC2    ${TESTCASE_ARGS}    json_file=cni140003_tc2_no_traffic.json

    [Teardown]    Test Case Teardown For CNI140003    ${postargs_py}


CNI140003_TC04_A_B1_PDSCH_skipping_on_special_slot_due_to_UL_overload_Alternative_Scenario_2
    [Documentation]
    ...    Author: noli.valdez@nokia.com, doreen.dellosa@nokia.com
    ...    Contact/s: stefan.bohl@nokia.com, mokhtar.derkaoui@nokia.com
    ...    Topology:
    ...             ASOE: CLOUD_5G_O_E_AP_2LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO
    ...             ABIP: CLOUD_5G_I_MP_AP_LOOO / SANSA_FS_ECPRI_CMWV_TDD_12CELL_CNI140003_TC04
    ...    Summary: cell B: actAperCsi true
    ...    .        cell B: increasePUSCHPrepTimeULCA true
    ...    .        ~~cell B: actCellCsiRsImTddNonBf true~~
    ...    .        ~~cell B: actBeamforming false~~
    ...    .        register X UE on cell A + UL/DL traffic non-gbr
    ...    .        register X UE on cell A + UL/DL traffic gbr/non-gbr
    ...    .        register X UE on cell B + DL non-gbr
    [Setup]    Test Case Setup For CNI140003 TC02
    ...    SCF_SET_VAR_NRCELL_i4_actAperCsi=true
    ...    SCF_SET_VAR_NRCELL_i4_increasePUSCHPrepTimeULCA=true

    Set To Dictionary    ${TESTCASE_ARGS}    enable_ttitrace    ${TTI_TRACE_PHYCELL}

    ${postargs_py}    cni140003_kw.Run CNI140003 TC2   ${TESTCASE_ARGS}    json_file=cni140003_tc04.json

    [Teardown]    Test Case Teardown For CNI140003    ${postargs_py}


CNI140003_TC05_A_B2_No_PDSCH_skipping_on_special_slot_due_to_UL_overload_exit
    [Documentation]
    ...    Author: noli.valdez@nokia.com
    ...    Contact/s: stefan.bohl@nokia.com, mokhtar.derkaoui@nokia.com
    ...    Topology: CLOUD_5G_O_E_AP_2LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO
    ...    Summary: register X UE on cell 1 + UL traffic non-gbr
    ...    .        register X UE on cell 1 + UL/DL traffic gbr/non-gbr
    ...    .        register X UE on cell 3 + DL non-gbr
    ...    .        deregister X UE on cell 3
    [Setup]    Test Case Setup For CNI140003 TC02

    ${postargs_py}    cni140003_kw.Run CNI140003 TC5   ${TESTCASE_ARGS}

    [Teardown]    Test Case Teardown For CNI140003    ${postargs_py}


CNI140003_TC06_A_B3_No_PDSCH_skipping_on_special_slot_due_to_UL_overload_when_UL_overload_cell_K2_eq_3
    [Documentation]
    ...    Author: noli.valdez@nokia.com
    ...    Contact/s: stefan.bohl@nokia.com, mokhtar.derkaoui@nokia.com
    ...    Topology: CLOUD_5G_O_E_AP_2LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO
    ...    Summary: cell 1: increasePUSCHPrepTimeULCA true
    ...    .        UE UL CA capabilities
    ...    .        register X UE on cell 1 + UL traffic non-gbr
    ...    .        register X UE on cell 1 + UL/DL traffic gbr/non-gbr
    ...    .        register X UE on cell 3 + DL non-gbr
    [Setup]    Test Case Setup For CNI140003 TC02
    ...    SCF_SET_VAR_NRCELL_i1_increasePUSCHPrepTimeULCA=true

    ${postargs_py}    cni140003_kw.Run CNI140003 TC2   ${TESTCASE_ARGS}

    [Teardown]    Test Case Teardown For CNI140003    ${postargs_py}


CNI140003_TC7_A_B4_SIB1_Paging_Msg2_Msg4_are_transmitted_on_special_slot_during_PDSCH_skipping_on_special_slot_due_to_UL_overload_paging
    [Documentation]
    ...    Author: noli.valdez@nokia.com
    ...    Contact/s: stefan.bohl@nokia.com, mokhtar.derkaoui@nokia.com
    ...    Topology: CLOUD_5G_O_E_AP_2LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO
    ...    Summary: register X UE on cell 1 + UL traffic non-gbr
    ...    .        register X UE on cell 1 + UL/DL traffic gbr/non-gbr
    ...    .        register X UE on cell 3 + DL non-gbr
    [Setup]    Test Case Setup For CNI140003 TC02

    ${postargs_py}    cni140003_kw.Run CNI140003 TC2   ${TESTCASE_ARGS}    json_file=cni140003_tc07.json

    [Teardown]    Test Case Teardown For CNI140003    ${postargs_py}


CNI140003_TC7_A_B4_SIB1_Paging_Msg2_Msg4_are_transmitted_on_special_slot_during_PDSCH_skipping_on_special_slot_due_to_UL_overload_msg2msg4
    [Documentation]
    ...    Author: noli.valdez@nokia.com
    ...    Contact/s: stefan.bohl@nokia.com, mokhtar.derkaoui@nokia.com
    ...    Topology: CLOUD_5G_O_E_AP_2LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO
    ...    Summary: register X UE on cell 1 + UL traffic non-gbr
    ...    .        register X UE on cell 1 + UL/DL traffic gbr/non-gbr
    ...    .        register X UE on cell 3 + DL non-gbr
    [Setup]    Test Case Setup For CNI140003 TC02

    ${postargs_py}    cni140003_kw.Run CNI140003 TC2   ${TESTCASE_ARGS}    json_file=cni140003_tc07.json

    [Teardown]    Test Case Teardown For CNI140003    ${postargs_py}


CNI140003_TC8_A_IWK1_No_PDSCH_skipping_on_special_slot_due_to_UL_overload_when_UL_overload_cell_K2_is_changed_to_3_by_RIM_PDCCH_muting
    [Documentation]
    ...    Author: noli.valdez@nokia.com
    ...    Contact/s: stefan.bohl@nokia.com, mokhtar.derkaoui@nokia.com
    ...    Topology: CLOUD_5G_O_E_AP_2LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO
    ...    Summary: Variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_cni140003_testcase_8_active
    ...    .        register X UE on cell 1 + UL traffic non-gbr
    ...    .        register X UE on cell 1 + UL/DL traffic gbr/non-gbr
    ...    .        register X UE on cell 3 + DL non-gbr
    ...    .        get snapshot
    ...    .        act rim cell A
    ...    .        collect measurement
    ...    .        get snapshot
    ...    .        deact rim cell A
    ...    .        collect measurement
    ...    .        get snapshot
    [Tags]    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_cni140003_testcase_8_active
    [Setup]    Test Case Setup For CNI140003 TC08
    ...    RDCFG_0x58057A=4
    ...    RDCFG_0x58057f=262209
    ...    RDCFG_0x5808B9=15 # rdPdschSkipInSpecialSlotDueUlOverloadThresholdLow
    ...    RDCFG_0x5808BA=18 # rdPdschSkipInSpecialSlotDueUlOverloadThresholdHigh

    ${postargs_py}    cni140003_kw.Run CNI140003 TC2   ${TESTCASE_ARGS}
    performance_snapshot.Collect Snapshot From Gnb And Save To Turandot    subfolder=before_act_rim

    ${cust_actrim}    Run Keyword and return status    Variable Should Exist    ${CUSTOM_TC8_ACT_RIM}
    ${cust_deactrim}    Run Keyword and return status    Variable Should Exist    ${CUSTOM_TC8_DEACT_RIM}
    ${act_rim_json}    Set Variable if    ${cust_actrim}     ${CUSTOM_TC8_ACT_RIM}    ${CURDIR}/cni140003_tc8_act_rim.json
    ${deact_rim_json}    Set Variable if    ${cust_deactrim}     ${CUSTOM_TC8_DEACT_RIM}    ${CURDIR}/cni140003_tc8_deact_rim.json

    RIM Test    ${act_rim_json}   ${deact_rim_json}

    [Teardown]    Test Case Teardown For CNI140003    ${postargs_py}


CNI140003_TC9_A_IWK2_No_PDSCH_skipping_on_special_slot_due_to_UL_overload_when_buddy_cell_is_in_RIM_DL_muting
    [Documentation]
    ...    Author: noli.valdez@nokia.com
    ...    Contact/s: stefan.bohl@nokia.com, mokhtar.derkaoui@nokia.com
    ...    Topology: CLOUD_5G_O_E_AP_2LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO
    ...    Summary: Variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_cni140003_testcase_8_active
    ...    .        register X UE on cell 1 + UL traffic non-gbr
    ...    .        register X UE on cell 1 + UL/DL traffic gbr/non-gbr
    ...    .        register X UE on cell 3 + DL non-gbr
    ...    .        get snapshot
    ...    .        act rim cell B
    ...    .        collect measurement
    ...    .        get snapshot
    ...    .        deact rim cell B
    ...    .        collect measurement
    ...    .        get snapshot
    [Tags]    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_cni140003_testcase_9_active
    [Setup]    Test Case Setup For CNI140003 TC08
    ...    RDCFG_0x58057A=4
    ...    RDCFG_0x58057f=262209
    ...    RDCFG_0x5808B9=15 # rdPdschSkipInSpecialSlotDueUlOverloadThresholdLow
    ...    RDCFG_0x5808BA=18 # rdPdschSkipInSpecialSlotDueUlOverloadThresholdHigh

    ${postargs_py}    cni140003_kw.Run CNI140003 TC2   ${TESTCASE_ARGS}
    performance_snapshot.Collect Snapshot From Gnb And Save To Turandot    subfolder=before_act_rim

    ${cust_actrim}    Run Keyword and return status    Variable Should Exist    ${CUSTOM_TC9_ACT_RIM}    # -v CUSTOM_TC9_ACT_RIM:/tmp/path/to/file
    ${cust_deactrim}    Run Keyword and return status    Variable Should Exist    ${CUSTOM_TC9_DEACT_RIM}
    ${act_rim_json}    Set Variable if    ${cust_actrim}     ${CUSTOM_TC9_ACT_RIM}    ${CURDIR}/cni140003_tc9_act_rim.json
    ${deact_rim_json}    Set Variable if    ${cust_deactrim}     ${CUSTOM_TC9_DEACT_RIM}    ${CURDIR}/cni140003_tc9_deact_rim.json
    RIM Test    ${act_rim_json}   ${deact_rim_json}

    [Teardown]    Test Case Teardown For CNI140003    ${postargs_py}


CNI140003_TC9_A_IWK2_No_PDSCH_skipping_on_special_slot_due_to_UL_overload_when_buddy_cell_is_in_RIM_DL_muting_with_markerUEs
    [Documentation]
    ...    Author: noli.valdez@nokia.com
    ...    Contact/s: stefan.bohl@nokia.com, mokhtar.derkaoui@nokia.com
    ...    Topology: CLOUD_5G_O_E_AP_2LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO
    ...    Summary: Variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_cni140003_testcase_8_active
    ...    .        register X UE on cell 1 + UL traffic non-gbr
    ...    .        register X UE on cell 1 + UL/DL traffic gbr/non-gbr
    ...    .        register X UE on cell 3 + DL non-gbr
    ...    .        get snapshot
    ...    .        act rim cell B
    ...    .        collect measurement
    ...    .        get snapshot
    ...    .        deact rim cell B
    ...    .        collect measurement
    ...    .        get snapshot
    [Tags]    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_cni140003_testcase_9_active
    [Setup]    Test Case Setup For CNI140003 TC08
    ...    RDCFG_0x58057A=4
    ...    RDCFG_0x58057f=262209
    ...    RDCFG_0x5808B9=15 # rdPdschSkipInSpecialSlotDueUlOverloadThresholdLow
    ...    RDCFG_0x5808BA=18 # rdPdschSkipInSpecialSlotDueUlOverloadThresholdHigh

    Set To Dictionary    ${TESTCASE_ARGS}    enable_ttitrace    ${TTI_TRACE_PHYCELL}
    Set To Dictionary    ${TESTCASE_ARGS}    group0_ue_count    10
    Set To Dictionary    ${TESTCASE_ARGS}    num_cells_online    9
    ${postargs_py}    cni140003_kw.Run CNI140003 TC2   ${TESTCASE_ARGS}  json_file=cni140003_tc2_variant_2.json

    performance_snapshot.Collect Snapshot From Gnb And Save To Turandot    subfolder=before_act_rim

    ${cust_actrim}    Run Keyword and return status    Variable Should Exist    ${CUSTOM_TC9_ACT_RIM}    # -v CUSTOM_TC9_ACT_RIM:/tmp/path/to/file
    ${cust_deactrim}    Run Keyword and return status    Variable Should Exist    ${CUSTOM_TC9_DEACT_RIM}
    ${act_rim_json}    Set Variable if    ${cust_actrim}     ${CUSTOM_TC9_ACT_RIM}    ${CURDIR}/cni140003_tc9_act_rim.json
    ${deact_rim_json}    Set Variable if    ${cust_deactrim}     ${CUSTOM_TC9_DEACT_RIM}    ${CURDIR}/cni140003_tc9_deact_rim.json
    RIM Test    ${act_rim_json}   ${deact_rim_json}

    [Teardown]    Test Case Teardown For CNI140003    ${postargs_py}

CNI140003_TC10_A_IWK3_PDSCH_skipping_on_special_slot_due_to_UL_overload_when_switch_between_0_5ms_and_0_75ms_with_K2_eq_2
    [Documentation]
    ...    Author: doreen.dellosa@nokia.com
    ...    Contact/s: stefan.bohl@nokia.com, john.scanlon@nokia.com
    ...    Topology:
    ...             ASOE: CLOUD_5G_O_E_AP_2LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO
    ...             ABIP: CLOUD_5G_I_MP_AP_LOOO / SANSA_FS_ECPRI_CMWV_TDD_12CELL_CNI140003_TC10
    ...    Summary: register X UE on cell A + UL traffic non-gbr
    ...    .        register X UE on cell B + UL/DL traffic gbr/non-gbr
    ...    .        register X UE on cell B + DL non-gbr
    ...    .        Lock Cell A (cell-1)
    ...    . activate CB013305-BC: NRBTS.actFlexibleBISlotDurationMode=full
    ...                            rdFixBISlotTimings=0 --> (default) dynamic usage of 0.75ms timing pattern
    ...
    [Setup]    Test Case Setup For CNI140003 TC02

    Set To Dictionary    ${TESTCASE_ARGS}    enable_ttitrace    ${TTI_TRACE_PHYCELL}

    ${postargs_py}    cni140003_kw.Run CNI140003 TC2   ${TESTCASE_ARGS}    json_file=cni140003_tc04.json

    [Teardown]    Test Case Teardown For CNI140003    ${postargs_py}


CNI140003_TC12_A_IWK4_PDSCH_skipping_on_special_slot_due_to_UL_overload_when_switch_between_0_5ms_and_0_75ms_with_buddy_cell_K2_eq_3
    [Documentation]
    ...    Author: doreen.dellosa@nokia.com
    ...    Contact/s: stefan.bohl@nokia.com, john.scanlon@nokia.com
    ...    Topology:
    ...             ASOE: CLOUD_5G_O_E_AP_2LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO
    ...             ABIP: CLOUD_5G_I_MP_AP_LOOO / SANSA_FS_ECPRI_CMWV_TDD_12CELL_CNI140003_TC12
    ...    Summary: Same procedure as TC10 but with following params modification on Cell B:
    ...             actAperCsi=true
    ...             increasePUSCHPrepTimeULCA=true

    [Setup]    Test Case Setup For CNI140003 TC02

    Set To Dictionary    ${TESTCASE_ARGS}    enable_ttitrace    ${TTI_TRACE_PHYCELL}

    ${postargs_py}    cni140003_kw.Run CNI140003 TC2   ${TESTCASE_ARGS}    json_file=cni140003_tc04.json

    [Teardown]    Test Case Teardown For CNI140003    ${postargs_py}


CNI140003_TC13_A_O1_no_PDSCH_skipping_on_special_slot_due_to_UL_overload_after_UL_overload_is_deleted_from_L2_subpool
    [Documentation]
    ...    Author: noli.valdez@nokia.com
    ...    Contact/s: stefan.bohl@nokia.com, mokhtar.derkaoui@nokia.com
    ...    Topology: CLOUD_5G_O_E_AP_2LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO
    ...    Summary: register X UE on cell 1 + UL traffic non-gbr
    ...    .        register X UE on cell 1 + UL/DL traffic gbr/non-gbr
    ...    .        register X UE on cell 3 + DL non-gbr
    ...    .        Lock Cell A (cell-1)
    [Setup]    Test Case Setup For CNI140003 TC02

    ${postargs_py}    Run Keyword And Continue On Failure
    ...    cni140003_kw.Run CNI140003 TC2   ${TESTCASE_ARGS}

    performance_log_collection.Start SysLog Collection
    performance_ttitrace.Start TTI Trace Collection            nr_phy_cell_ids=${TTI_TRACE_PHYCELL}
    ...                                                        tti_trace_filename=cell1_lock
    Sleep    2s
    performance_commissioning.Admin Command    MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-1    lock
    performance_ttitrace.Stop TTI Trace Collection             tti_trace_filename=cell1_lock
    ...                                                        subfolder=cell1_lock  compression_flags=--rm

    Sleep    5 minutes
    performance_snapshot.Collect Snapshot From Gnb And Save To Turandot    subfolder=cell1_lock
    performance_log_collection.Stop SysLog Collection    subfolder=cell1_lock

    [Teardown]    Run Keywords
    ...    Test Case Teardown For CNI140003    ${postargs_py}
    ...    AND    Run Keyword And Warn On Failure    performance_commissioning.Admin Command    MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-1    unlock


CNI140003_TC14_A_O2_PDSCH_skipping_on_special_slot_due_to_UL_overload_controlled_by_activation_flag
    [Documentation]
    ...    Author: noli.valdez@nokia.com, doreen.dellosa@nokia.com
    ...    Contact/s: stefan.bohl@nokia.com
    ...    Topology:
    ...             ASOE: CLOUD_5G_O_E_AP_2LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO
    ...             ABIP: CLOUD_5G_I_MP_AP_LOOO / SANSA_FS_ECPRI_CMWV_TDD_12CELL_CNI140003_TC14
    ...    Summary: register X UE on cell A + UL traffic non-gbr
    ...    .        register X UE on cell A + UL/DL traffic gbr/non-gbr
    ...    .        register X UE on cell B + DL non-gbr
    ...    .        set actPdschSkipInSpSlotDueUlOvl to false
    [Setup]    Test Case Setup For CNI140003 TC02

    Set To Dictionary    ${TESTCASE_ARGS}    enable_ttitrace    ${TTI_TRACE_PHYCELL}

    ${postargs_py}    cni140003_kw.Run CNI140003 TC2   ${TESTCASE_ARGS}

    performance_log_collection.Start SysLog Collection
    Sleep    60 seconds
    performance_ttitrace.Start TTI Trace Collection  nr_phy_cell_ids=53,61  tti_trace_filename=tti_01_actPdschSkipInSpSlotDueUlOvl_false
    Sleep    60 seconds
    performance_commissioning.Realtime Update SCF Parameter    MRBTS-[0-9]+/NRBTS-[0-9]+    actPdschSkipInSpSlotDueUlOvl    false
    Sleep    3 minutes
    performance_ttitrace.Stop TTI Trace Collection  tti_trace_filename=tti_01_actPdschSkipInSpSlotDueUlOvl_false
    ...  subfolder=01_actPdschSkipInSpSlotDueUlOvl_false  compression_flags=--rm
    Sleep    60 seconds
    performance_log_collection.Stop SysLog Collection  subfolder=01_actPdschSkipInSpSlotDueUlOvl_false
    Sleep    1 minute
    performance_snapshot.Collect Snapshot From Gnb And Save To Turandot    subfolder=01_actPdschSkipInSpSlotDueUlOvl_false

    performance_log_collection.Start SysLog Collection
    Sleep    60 seconds
    performance_ttitrace.Start TTI Trace Collection  nr_phy_cell_ids=53,61  tti_trace_filename=tti_02_actPdschSkipInSpSlotDueUlOvl_true
    Sleep    60 seconds
    performance_commissioning.Realtime Update SCF Parameter    MRBTS-[0-9]+/NRBTS-[0-9]+    actPdschSkipInSpSlotDueUlOvl    true
    Sleep    3 minutes
    performance_ttitrace.Stop TTI Trace Collection  tti_trace_filename=tti_02_actPdschSkipInSpSlotDueUlOvl_true
    ...  subfolder=02_actPdschSkipInSpSlotDueUlOvl_true  compression_flags=--rm
    Sleep    60 seconds
    performance_log_collection.Stop SysLog Collection  subfolder=02_actPdschSkipInSpSlotDueUlOvl_true
    Sleep    1 minute
    performance_snapshot.Collect Snapshot From Gnb And Save To Turandot    subfolder=02_actPdschSkipInSpSlotDueUlOvl_true

    performance_log_collection.Start SysLog Collection
    Sleep    60 seconds
    performance_ttitrace.Start TTI Trace Collection  nr_phy_cell_ids=53,61  tti_trace_filename=tti_03_actPdschSkipInSpSlotDueUlOvl_false
    Sleep    60 seconds
    performance_commissioning.Realtime Update SCF Parameter    MRBTS-[0-9]+/NRBTS-[0-9]+    actPdschSkipInSpSlotDueUlOvl    false
    Sleep    3 minutes
    performance_ttitrace.Stop TTI Trace Collection  tti_trace_filename=tti_03_actPdschSkipInSpSlotDueUlOvl_false
    ...  subfolder=03_actPdschSkipInSpSlotDueUlOvl_false  compression_flags=--rm
    Sleep    60 seconds
    performance_log_collection.Stop SysLog Collection  subfolder=03_actPdschSkipInSpSlotDueUlOvl_false
    Sleep    1 minute
    performance_snapshot.Collect Snapshot From Gnb And Save To Turandot    subfolder=03_actPdschSkipInSpSlotDueUlOvl_false

    performance_log_collection.Start SysLog Collection
    Sleep    60 seconds
    performance_ttitrace.Start TTI Trace Collection  nr_phy_cell_ids=53,61  tti_trace_filename=tti_04_actPdschSkipInSpSlotDueUlOvl_true
    Sleep    60 seconds
    performance_commissioning.Realtime Update SCF Parameter    MRBTS-[0-9]+/NRBTS-[0-9]+    actPdschSkipInSpSlotDueUlOvl    true
    Sleep    3 minutes
    performance_ttitrace.Stop TTI Trace Collection  tti_trace_filename=tti_04_actPdschSkipInSpSlotDueUlOvl_true
    ...  subfolder=04_actPdschSkipInSpSlotDueUlOvl_true  compression_flags=--rm
    Sleep    60 seconds
    performance_log_collection.Stop SysLog Collection  subfolder=04_actPdschSkipInSpSlotDueUlOvl_true
    Sleep    1 minute
    performance_snapshot.Collect Snapshot From Gnb And Save To Turandot    subfolder=04_actPdschSkipInSpSlotDueUlOvl_true

    [Teardown]    Test Case Teardown For CNI140003    ${postargs_py}


CNI140003_TC15
    [Documentation]
    ...    Author: noli.valdez@nokia.com
    ...    Contact/s: stefan.bohl@nokia.com, mokhtar.derkaoui@nokia.com
    ...    Topology: CLOUD_5G_O_E_AP_2LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO
    ...    Summary: Traffic non-gbr all
    ...
    ...    Step 1
    ...    Cell A (50) UL Traffic UE group 1,   90
    ...
    ...    Step 2
    ...    Cell B (52) DL traffic UE group 2,   200
    ...    -> Snapshot
    ...
    ...    Step 3
    ...    Cell B (50) UL traffic UE group 3,  90
    ...
    ...    Step 4
    ...    Cell A (50) DL Traffic UE Group 4.   200
    ...    -> Snapshot
    ...
    ...    Step5
    ...    Cell A (50) Decrease DL traffic
    ...    -> Snapshot
    ...
    ...    Step6
    ...    Cell B (52) Decrease DL Traffic
    ...    -> Snapshot
    [Setup]    Test Case Setup For CNI140003 TC02

    Set To Dictionary    ${TESTCASE_ARGS}    enable_ttitrace    ${TTI_TRACE_PHYCELL}

    ${postargs_py}    cni140003_kw.Run CNI140003 TC15   ${TESTCASE_ARGS}
    [Teardown]    Test Case Teardown For CNI140003    ${postargs_py}


CNI140003_TC16_A_B1_2_predictive_Robust_user_scenario
    [Documentation]
    ...    Author: noli.valdez@nokia.com
    ...    Contact/s: stefan.bohl@nokia.com, mokhtar.derkaoui@nokia.com
    ...    Topology:
    ...             ASOE: CLOUD_5G_O_E_AP_2LOOO / SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO
    ...             ABIP: CLOUD_5G_I_MP_AP_LOOO / SANSA_FS_ECPRI_CMWV_TDD_12CELL_CNI140003_TC04
    ...    Summary: actPdschSkipInSpSlotDueUlOvl false
    ...    .        register X UE on cell A + UL traffic non-gbr
    ...    .        register X UE on cell A + UL/DL traffic gbr/non-gbr
    ...    .        register X UE on cell B + DL non-gbr
    [Setup]    Test Case Setup For CNI140003 TC02
    ...    SCF_SET_VAR_NRBTS_actPdschSkipInSpSlotDueUlOvl=false

    Set To Dictionary    ${TESTCASE_ARGS}    enable_ttitrace    ${TTI_TRACE_PHYCELL}

    ${postargs_py}    cni140003_kw.Run CNI140003 TC2   ${TESTCASE_ARGS}
    [Teardown]    Test Case Teardown For CNI140003    ${postargs_py}


*** Keywords ***
Test Case Setup For CNI140003 TC02
    [Arguments]    &{kwargs}
    IF     "${TL_DATA['GNB_CU_TYPE']}" in ["ASOE"]
        Test Case Setup For CNI140003 TC02 ASOE    ENABLE_SYSLOG_PARSER=false    &{kwargs}
        Set Suite Variable    $TTI_TRACE_PHYCELL    50,52
    END
    IF     "${TL_DATA['GNB_CAPU_TYPE']}" in ["ABIP"]
        Test Case Setup For CNI140003 TC02 ABIP    ENABLE_SYSLOG_PARSER=false    &{kwargs}
        Set Suite Variable    $TTI_TRACE_PHYCELL    51,56    # [VRFULMPERF-71] cell a shall be now 2, cell b shall be now 7
    END


Test Case Setup For CNI140003 TC03
    IF     "${TL_DATA['GNB_CU_TYPE']}" in ["ASOE"]
        Test Case Setup For CNI140003 TC02
        ...    SCF_SET_LIST_NRCELL_i1_tddFrameStructure_lteToNrFrameShift=3ms
        ...    SCF_SET_LIST_NRCELL_i2_tddFrameStructure_lteToNrFrameShift=3ms
        ...    SCF_SET_LIST_NRCELL_i3_tddFrameStructure_lteToNrFrameShift=3ms
        ...    SCF_SET_LIST_NRCELL_i4_tddFrameStructure_lteToNrFrameShift=3ms
        ...    SCF_SET_LIST_NRCELL_i5_tddFrameStructure_lteToNrFrameShift=3ms
        ...    SCF_SET_LIST_NRCELL_i6_tddFrameStructure_lteToNrFrameShift=3ms
        Set Suite Variable    $TTI_TRACE_PHYCELL    50,52
    END
    IF     "${TL_DATA['GNB_CAPU_TYPE']}" in ["ABIP"]
        Test Case Setup For CNI140003 TC03 ABIP
        Set Suite Variable    $TTI_TRACE_PHYCELL    53,61
    END


Test Case Setup For CNI140003 TC08
    [Arguments]    &{kwargs}
    &{kwargs2}    Create Dictionary
    ...    SCF_SET_LIST_NRBTS_actRimCmFmReport_asymmetricStateReport=FM off, CM on
    ...    SCF_SET_LIST_NRBTS_actRimCmFmReport_dlMutingStateReport=FM off, CM on
    ...    SCF_SET_LIST_NRBTS_actRimCmFmReport_rimRsStateReport=FM off, CM on
    ...    SCF_SET_LIST_NRBTS_actRimCmFmReport_riStateReport=FM off, CM on
    IF     "${TL_DATA['GNB_CU_TYPE']}" in ["ASOE"]
        Test Case Setup For CNI140003 TC02    &{kwargs}
    END
    IF     "${TL_DATA['GNB_CAPU_TYPE']}" in ["ABIP"]
        Test Case Setup For CNI140003 TC02    &{kwargs}    &{kwargs2}
    END


Test Case Setup For CNI140003 TC02 ASOE
    [Arguments]    &{kwargs}
    performance_test_setup.Test Case Setup For Performance Test
    ...    SCF_SET_VAR_NRBTS_actPdschSkipInSpSlotDueUlOvl=true
    ...    SCF_SET_VAR_NRBTS_actFlexibleBISlotDurationMode=full  # full gnb
    ...    SCF_SET_VAR_NRCELL_i1_actEnhancedPDSCHSchSplSlot=true
    ...    SCF_SET_VAR_NRCELL_i2_actEnhancedPDSCHSchSplSlot=true
    ...    SCF_SET_VAR_NRCELL_i3_actEnhancedPDSCHSchSplSlot=true
    ...    SCF_SET_VAR_NRCELL_i4_actEnhancedPDSCHSchSplSlot=true
    ...    SCF_SET_VAR_NRCELL_i5_actEnhancedPDSCHSchSplSlot=true
    ...    SCF_SET_VAR_NRCELL_i6_actEnhancedPDSCHSchSplSlot=true
    ...    SCF_SET_VAR_NRCELL_i7_actEnhancedPDSCHSchSplSlot=false
    ...    SCF_SET_VAR_NRCELL_i8_actEnhancedPDSCHSchSplSlot=false
    ...    SCF_SET_VAR_NRCELL_i9_actEnhancedPDSCHSchSplSlot=false
    ...    SCF_SET_VAR_NRCELL_i1_actIncUlPdcchCapacity=false
    ...    SCF_SET_VAR_NRCELL_i2_actIncUlPdcchCapacity=false
    ...    SCF_SET_VAR_NRCELL_i3_actIncUlPdcchCapacity=false
    ...    SCF_SET_VAR_NRCELL_i4_actIncUlPdcchCapacity=false
    ...    SCF_SET_VAR_NRCELL_i5_actIncUlPdcchCapacity=false
    ...    SCF_SET_VAR_NRCELL_i6_actIncUlPdcchCapacity=false
    ...    SCF_SET_VAR_NRCELL_i7_actIncUlPdcchCapacity=false
    ...    SCF_SET_VAR_NRCELL_i8_actIncUlPdcchCapacity=false
    ...    SCF_SET_VAR_NRCELL_i9_actIncUlPdcchCapacity=false
    ...    SCF_SET_LIST_NRCELL_i1_tddFrameStructure_lteToNrFrameShift=0ms
    ...    SCF_SET_LIST_NRCELL_i2_tddFrameStructure_lteToNrFrameShift=0ms
    ...    SCF_SET_LIST_NRCELL_i3_tddFrameStructure_lteToNrFrameShift=0ms
    ...    SCF_SET_LIST_NRCELL_i4_tddFrameStructure_lteToNrFrameShift=0ms
    ...    SCF_SET_LIST_NRCELL_i5_tddFrameStructure_lteToNrFrameShift=0ms
    ...    SCF_SET_LIST_NRCELL_i6_tddFrameStructure_lteToNrFrameShift=0ms
    ...    SCF_SET_LIST_NRCELL_i7_tddFrameStructure_lteToNrFrameShift=null  # FDD default: none
    ...    SCF_SET_LIST_NRCELL_i8_tddFrameStructure_lteToNrFrameShift=null  # FDD default: none
    ...    SCF_SET_LIST_NRCELL_i9_tddFrameStructure_lteToNrFrameShift=null  # FDD default: none
    ...    SCF_SET_VAR_NRCELL_i1_prachRootSequenceIndex=450
    ...    SCF_SET_VAR_NRCELL_i2_prachRootSequenceIndex=460
    ...    SCF_SET_VAR_NRCELL_i3_prachRootSequenceIndex=470
    ...    SCF_SET_VAR_NRCELL_i4_prachRootSequenceIndex=480
    ...    SCF_SET_VAR_NRCELL_i5_prachRootSequenceIndex=490
    ...    SCF_SET_VAR_NRCELL_i6_prachRootSequenceIndex=500
    ...    SCF_SET_VAR_NRCELL_i7_prachRootSequenceIndex=450
    ...    SCF_SET_VAR_NRCELL_i8_prachRootSequenceIndex=460
    ...    SCF_SET_VAR_NRCELL_i9_prachRootSequenceIndex=470
    ...    SCF_SET_VAR_NRCELL_i1_prachConfigurationIndex=9
    ...    SCF_SET_VAR_NRCELL_i2_prachConfigurationIndex=9
    ...    SCF_SET_VAR_NRCELL_i3_prachConfigurationIndex=9
    ...    SCF_SET_VAR_NRCELL_i4_prachConfigurationIndex=9
    ...    SCF_SET_VAR_NRCELL_i5_prachConfigurationIndex=9
    ...    SCF_SET_VAR_NRCELL_i6_prachConfigurationIndex=9
    ...    SCF_SET_VAR_NRCELL_i7_prachConfigurationIndex=12
    ...    SCF_SET_VAR_NRCELL_i8_prachConfigurationIndex=13
    ...    SCF_SET_VAR_NRCELL_i9_prachConfigurationIndex=14
    ...    SCF_SET_VAR_NRCELL_i1_actBeamforming=true
    ...    SCF_SET_VAR_NRCELL_i2_actBeamforming=true
    ...    SCF_SET_VAR_NRCELL_i3_actBeamforming=true
    ...    SCF_SET_VAR_NRCELL_i4_actBeamforming=true
    ...    SCF_SET_VAR_NRCELL_i5_actBeamforming=true
    ...    SCF_SET_VAR_NRCELL_i6_actBeamforming=true
    ...    SCF_SET_VAR_NRCELL_i7_actBeamforming=false
    ...    SCF_SET_VAR_NRCELL_i8_actBeamforming=false
    ...    SCF_SET_VAR_NRCELL_i9_actBeamforming=false
    ...    RDCFG_0x5808B9=6 # rdPdschSkipInSpecialSlotDueUlOverloadThresholdLow
    ...    RDCFG_0x5808BA=20 # rdPdschSkipInSpecialSlotDueUlOverloadThresholdHigh
    ...    ASSERT_ONLY_SIB_ON_ACTIVE_CELLS=true
    ...    ASSERT_ONLY_AP_CELL_ON_ACTIVE_CELLS=true
    ...    SCF_SET_reportingIntervalPm=5min
    ...    &{kwargs}
    performance_egate.Copy specific egate Scripts to wts folder    cni140003/tc2/

    &{common_argp}      create dictionary
    ...             start_cell=1
    ...               end_cell=9
    ...            ue_per_cell=0
    ...           active_cells=1,3
    ...                    lua=cni140003_tc2_sansa.lua
    ...                 cell_a=${1}
    ...                 cell_b=${3}
    ...        enable_ttitrace=${None}
    ...    configuration_entry=run_configuration(86400)
    ...    enable_syslog_grep=true
    ${argp2}    perf_keywords.Calculate Values For Common Run Dictionary Py    get_from_cli=${true}    &{common_argp}
    ${argpy}    perf_keywords.Pop Args From Common Args    ${argp2}    perf_keywords.wts_manager_non_supported_params
    &{args}     Set Variable   ${argpy}  # convert to robot style dictionary
    performance_keywords.Set Up On Air Status    ${args}
    Set Test Variable    ${TESTCASE_ARGS}    ${args}
    Set Test Variable    ${TESTCASE_SETUP}    ${True}
    performance_log_collection.Stop SysLog Collection    subfolder=cellsetup


Test Case Setup For CNI140003 TC02 ABIP
    [Arguments]    &{kwargs}
    performance_test_setup.Test Case Setup For Performance Test
    ...    SCF_SET_VAR_NRBTS_actPdschSkipInSpSlotDueUlOvl=true
    ...    SCF_SET_VAR_NRBTS_actFlexibleBISlotDurationMode=full  # full gnb
    ...    SCF_SET_VAR_NRCELL_actEnhancedPDSCHSchSplSlot=true
    ...    SCF_SET_VAR_NRCELL_actIncUlPdcchCapacity=false
    ...    SCF_SET_LIST_NRCELL_tddFrameStructure_lteToNrFrameShift=0ms
    ...    SCF_SET_VAR_NRCELL_i1_prachRootSequenceIndex=450
    ...    SCF_SET_VAR_NRCELL_i2_prachRootSequenceIndex=460
    ...    SCF_SET_VAR_NRCELL_i3_prachRootSequenceIndex=470
    ...    SCF_SET_VAR_NRCELL_i4_prachRootSequenceIndex=480
    ...    SCF_SET_VAR_NRCELL_i5_prachRootSequenceIndex=490
    ...    SCF_SET_VAR_NRCELL_i6_prachRootSequenceIndex=500
    ...    SCF_SET_VAR_NRCELL_i7_prachRootSequenceIndex=450
    ...    SCF_SET_VAR_NRCELL_i8_prachRootSequenceIndex=460
    ...    SCF_SET_VAR_NRCELL_i9_prachRootSequenceIndex=470
    ...    SCF_SET_VAR_NRCELL_i10_prachRootSequenceIndex=480
    ...    SCF_SET_VAR_NRCELL_i11_prachRootSequenceIndex=490
    ...    SCF_SET_VAR_NRCELL_i12_prachRootSequenceIndex=500
    ...    SCF_SET_VAR_NRCELL_prachConfigurationIndex=9
    ...    RDCFG_0x590072=1 #CP-RT (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
    ...    RDCFG_0x5808B9=6 # rdPdschSkipInSpecialSlotDueUlOverloadThresholdLow
    ...    RDCFG_0x5808BA=20 # rdPdschSkipInSpecialSlotDueUlOverloadThresholdHigh
    ...    ASSERT_ONLY_SIB_ON_ACTIVE_CELLS=true
    ...    ASSERT_ONLY_AP_CELL_ON_ACTIVE_CELLS=true
    ...    SCF_SET_reportingIntervalPm=5min
    ...    &{kwargs}
    performance_egate.Copy specific egate Scripts to wts folder    cni140003/tc2/

    &{common_argp}      create dictionary
    ...             start_cell=1
    ...               end_cell=12
    ...            ue_per_cell=0
    ...           active_cells=2,7    # [VRFULMPERF-71] cell a shall be now 2
    ...                    lua=cni140003_tc2_sansa_abip.lua
    ...                 cell_a=${2}    # [VRFULMPERF-71] cell a shall be now 2
    ...                 cell_b=${7}    # [VRFULMPERF-71] cell b shall be now 7
    ...        enable_ttitrace=${None}
    ...    configuration_entry=run_configuration(86400)
    ...    enable_syslog_grep=false
    ${argp2}    perf_keywords.Calculate Values For Common Run Dictionary Py    get_from_cli=${true}    &{common_argp}
    ${argpy}    perf_keywords.Pop Args From Common Args    ${argp2}    perf_keywords.wts_manager_non_supported_params
    &{args}     Set Variable   ${argpy}  # convert to robot style dictionary
    performance_keywords.Set Up On Air Status    ${args}
    performance_snapshot.Collect Snapshot From Gnb And Save To Turandot    subfolder=cellsetup
    Set Test Variable    ${TESTCASE_ARGS}    ${args}
    Set Test Variable    ${TESTCASE_SETUP}    ${True}
    performance_log_collection.Stop SysLog Collection    subfolder=cellsetup


Test Case Setup For CNI140003 TC03 ABIP
    [Arguments]    &{kwargs}
    performance_test_setup.Test Case Setup For Performance Test
    ...    RDCFG_0x590072=1 #CP-RT (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
    ...    RDCFG_0x5808B9=6 # rdPdschSkipInSpecialSlotDueUlOverloadThresholdLow
    ...    RDCFG_0x5808BA=20 # rdPdschSkipInSpecialSlotDueUlOverloadThresholdHigh
    ...    ASSERT_ONLY_SIB_ON_ACTIVE_CELLS=true
    ...    ASSERT_ONLY_AP_CELL_ON_ACTIVE_CELLS=true
    ...    SCF_SET_reportingIntervalPm=5min
    ...    &{kwargs}
    performance_egate.Copy specific egate Scripts to wts folder    cni140003/tc2/

    &{common_argp}      create dictionary
    ...             start_cell=1
    ...               end_cell=12
    ...            ue_per_cell=0
    ...           active_cells=4,12
    ...                    lua=cni140003_tc2_sansa_abip.lua
    ...                 cell_a=${4}
    ...                 cell_b=${12}
    ...        enable_ttitrace=${None}
    ...    configuration_entry=run_configuration(86400)
    ...    enable_syslog_grep=false
    ${argp2}    perf_keywords.Calculate Values For Common Run Dictionary Py    get_from_cli=${true}    &{common_argp}
    ${argpy}    perf_keywords.Pop Args From Common Args    ${argp2}    perf_keywords.wts_manager_non_supported_params
    &{args}     Set Variable   ${argpy}  # convert to robot style dictionary
    performance_keywords.Set Up On Air Status    ${args}
    Set Test Variable    ${TESTCASE_ARGS}    ${args}
    Set Test Variable    ${TESTCASE_SETUP}    ${True}


Test Case Teardown For CNI140003
    [Arguments]    ${postargs_py}=${TESTCASE_ARGS}
    &{postargs}     Set Variable   ${postargs_py}  # convert to robot style dictionary
    IF    ${TESTCASE_SETUP}
        performance_log_collection.Wait And Collect One Measurement Cycle
        performance_keywords.Common Log Teardown    subfolder=${postargs.subfolder}    label=${postargs.label}
    ...                                             tti_trace_duration=${postargs.tti_trace_duration}
        performance_keywords.Common Log Teardown Verification    ${postargs}
    END
    performance_test_setup.Test Case Teardown For Performance Test


RIM Test
    [Arguments]    ${act_json}    ${deact_json}

    Log to console    act_rim
    performance_log_collection.Start SysLog Collection

    ${rimval}    Get File    ${act_json}
    Log to console    ${rimval}
    wts_manager.Send UE Commands From Json    ${act_json}                                                               # act_rim

    Log to console    sleep 600s                                                                                        # sleep 505s
    Sleep    600s     reason=delay tti
    #performance_log_collection.Wait For Next Measurement Period            label=act_rim
    #performance_log_collection.Wait for Current Measurement                label=act_rim        subfolder=act_rim

    # wait after the command 9 min and then make 2 min streaming of tti trace and also syslog and the grep.
    Log to console    Start TTI
    Run Keyword and Warn On Failure    performance_ttitrace.Quick TTI Trace Collection    tti_trace_duration=240        # tti 240s
    ...                                                              tti_trace_filename=act_rim
    ...                                                              subfolder=act_rim
    performance_snapshot.Collect Snapshot From Gnb And Save To Turandot    subfolder=act_rim                            # snapshot

    ${greps}    Create List    RemoteInterferenceInd    remoteInterferenceDetected    RimRssi
    ...                        FaultId: 7535/1    FaultId: 7525/1
    ...                        PdschMutingUlOverload

    FOR    ${pattern}    IN    @{greps}
        performance_btslog.Print Btslog grep    ${pattern}    bts_log_path=/tmp/btslog2/SYSLOG_*.LOG
    END

    performance_log_collection.Stop SysLog Collection            subfolder=act_rim                                      # stop syslog

    performance_log_collection.Start SysLog Collection                                                                  # start syslog

    Log to console    deact_rim
    ${rimval}    Get File    ${deact_json}
    Log to console    ${rimval}
    wts_manager.Send UE Commands From Json    ${deact_json}

    Log to console    sleep 664s                                                                                       # sleep 664s
    Sleep    664s     reason=delay tti
    #performance_log_collection.Wait For Next Measurement Period            label=deact_rim
    #performance_log_collection.Wait for Current Measurement                label=deact_rim      subfolder=deact_rim


    Log to console    Start TTI
    Run Keyword and Warn On Failure    performance_ttitrace.Quick TTI Trace Collection    tti_trace_duration=260        # tti 260s
    ...                                                              tti_trace_filename=deact_rim
    ...                                                              subfolder=deact_rim
    performance_snapshot.Collect Snapshot From Gnb And Save To Turandot    subfolder=deact_rim                          # snapshot

    FOR    ${pattern}    IN    @{greps}
        performance_btslog.Print Btslog grep    ${pattern}    bts_log_path=/tmp/btslog2/SYSLOG_*.LOG
    END

    performance_log_collection.Stop SysLog Collection            subfolder=deact_rim                                    # stop syslog
    performance_snapshot.Collect Snapshot From Gnb And Save To Turandot    subfolder=end_rim                            # snapshot
