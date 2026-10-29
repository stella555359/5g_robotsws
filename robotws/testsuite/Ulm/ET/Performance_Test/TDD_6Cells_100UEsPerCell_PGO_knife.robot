*** Settings ***
Documentation
...  author:  doreen.dellosa@nokia.com
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 1 Cell 100 UEs Performance Test

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_test_setup.robot

Force Tags    STATE_CONFIGURED    RAN_5G_TDD    RAN_5G    SBTS00    TDD    PGO

Suite Setup       performance_test_setup.Suite Setup For Performance Test    ENABLE_SOS_REPORT=false
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test    db_L2_ET_PGO_KPI


*** Test Cases ***
ABIO_TDD_6Cells_100UEsPerCell_DLOnly_knife
    [Documentation]
    ...    100UE - Performance Test with Profile Guided Optimization for TDD ABIO configuration with 100 UEs attached to all Cells
    ...    running DL only traffic simultaneously
    [Tags]    DL    CLOUD_5G_I_LO_AP_LOOO    PGO    ABIO    TDD
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=100
    ...                           ul_datarate=0
    ...                           dl_datarate=22200
    ...                                  rate=kbps
    ...                         trf_direction=dl
    ...                             tolerance=1  # no tput check
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    performance_keywords.Run Common Test    &{tc}


ABIO_TDD_6Cells_100UEsPerCell_ULOnly_knife
    [Documentation]
    ...    100UE - Performance Test with Profile Guided Optimization for TDD ABIO configuration with 100 UEs attached to all Cells
    ...    running UL only traffic simultaneously
    [Tags]    UL    CLOUD_5G_I_LO_AP_LOOO    PGO    ABIO    TDD
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=100
    ...                           ul_datarate=3000
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                             tolerance=1  # no tput check
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    performance_keywords.Run Common Test    &{tc}


ABIO_TDD_6Cells_100UEsPerCell_UL_DL_knife
    [Documentation]
    ...    100UE - Performance Test with Profile Guided Optimization for TDD ABIO configuration with 100 UEs attached to all Cells
    ...    running UL+DL traffic simultaneously
    [Tags]    ULDL    CLOUD_5G_I_LO_AP_LOOO    PGO    ABIO    TDD

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=100
    ...                           ul_datarate=3000
    ...                           dl_datarate=22200
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=1  # no tput check
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    performance_keywords.Run Common Test    &{tc}


ABIP_TDD_6Cells_72UEsPerCell_DLOnly_knife
    [Documentation]
    ...    Performance Test with Profile Guided Optimization for TDD ABIP configuration with 72 UEs attached to all Cells
    ...    running DL only traffic simultaneously
    [Tags]    DL    CLOUD_5G_I_MP_AP_LOOO    PGO    ABIP    TDD

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=72
    ...                           ul_datarate=0
    ...                           dl_datarate=18000
    ...                                  rate=kbps
    ...                         trf_direction=dl
    ...                             tolerance=1  # no tput check
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    performance_keywords.Run Common Test    &{tc}


ABIP_TDD_6Cells_72UEsPerCell_ULOnly_knife
    [Documentation]
    ...    Performance Test with Profile Guided Optimization for TDD ABIP configuration with 72 UEs attached to all Cells
    ...    running UL only traffic simultaneously
    [Tags]    UL    CLOUD_5G_I_MP_AP_LOOO    PGO    ABIP    TDD

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=72
    ...                           ul_datarate=4000
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                             tolerance=1  # no tput check
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    performance_keywords.Run Common Test    &{tc}


ABIP_TDD_6Cells_72UEsPerCell_UL_DL_knife
    [Documentation]
    ...    Performance Test with Profile Guided Optimization for TDD ABIP configuration with 72 UEs attached to all Cells
    ...    running UL+DL traffic simultaneously
    [Tags]    ULDL    CLOUD_5G_I_MP_AP_LOOO    PGO    ABIP    TDD

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=72
    ...                           ul_datarate=4000
    ...                           dl_datarate=17000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=0.5098039215686274  # Verify TP with Counters    both   187500000    30000000
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    performance_keywords.Run Common Test    &{tc}


ASOE_TDD_6Cells_100UEsPerCell_DLOnly_knife
    [Documentation]
    ...    Performance Test with Profile Guided Optimization for TDD ASOE configuration with 100 UEs attached to all Cells
    ...    running DL only traffic simultaneously
    [Tags]    DL    CLOUD_5G_O_E_AP_LOOO    PGO    ASOE    TDD

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=100
    ...                           ul_datarate=0
    ...                           dl_datarate=11200
    ...                                  rate=kbps
    ...                         trf_direction=dl
    ...                             tolerance=0.8660714285714286  # Verify_TP_with_Counters_TDD_DL=33750000
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    performance_keywords.Run Common Test    &{tc}


ASOE_TDD_6Cells_100UEsPerCell_ULOnly_knife
    [Documentation]
    ...    Performance Test with Profile Guided Optimization for TDD ASOE configuration with 100 UEs attached to all Cells
    ...    running UL only traffic simultaneously
    [Tags]    UL    CLOUD_5G_O_E_AP_LOOO    PGO    ASOE    TDD

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=100
    ...                           ul_datarate=3000
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                             tolerance=0.9  # Verify_TP_with_Counters_TDD_UL=6750000
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    performance_keywords.Run Common Test    &{tc}


ASOE_TDD_6Cells_72UEsPerCell_UL_DL_knife_wo_PGO
    [Documentation]
    ...    Performance Test with Profile Guided Optimization for TDD ASOE configuration with 72 UEs attached to all Cells
    ...    running UL+DL traffic simultaneously
    [Tags]    ULDL    CLOUD_5G_O_E_AP_LOOO    PGO    ASOE    TDD

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=72
    ...                           ul_datarate=3000
    ...                           dl_datarate=12800
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=0.8372395833333334  # Verify_TP_with_Counters_TDD_DL=33750000
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    performance_keywords.Run Common Test    &{tc}


ASOE_TDD_6Cells_72UEsPerCell_UL_DL_knife_with_PGO
    [Documentation]
    ...    Performance Test with Profile Guided Optimization for TDD ASOE configuration with 72 UEs attached to all Cells
    ...    running UL+DL traffic simultaneously
    [Tags]    ULDL    CLOUD_5G_O_E_AP_LOOO    PGO    ASOE    TDD

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=72
    ...                           ul_datarate=3000
    ...                           dl_datarate=12800
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=0.8372395833333334  # Verify_TP_with_Counters_TDD_DL=33750000
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    performance_keywords.Run Common Test    &{tc}


ASOE_TDD_6Cells_72UEsPerCell_UL_DL_knife
    [Documentation]
    ...    Performance Test with Profile Guided Optimization for TDD ASOE configuration with 72 UEs attached to all Cells
    ...    running UL+DL traffic simultaneously
    [Tags]    ULDL    CLOUD_5G_O_E_AP_LOOO    PGO    ASOE    TDD

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=72
    ...                           ul_datarate=3000
    ...                           dl_datarate=12800
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=0.8372395833333334  # Verify_TP_with_Counters_TDD_DL=33750000
    ...                                   lua=sansa_tdd_6cell.lua
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_seq_lua_tdd
    performance_keywords.Run Common Test    &{tc}
