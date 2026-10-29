*** Settings ***
Documentation
...  author:  VRF_RRM_T05
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 6 Cells 8DL8UL MUMIMO in ASOE

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_test_setup.robot


Suite Setup       performance_test_setup.Suite Setup For Performance Test
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
ASOE_TDD_6Cells_8DL8UL_MUMIMO
    [Documentation]    SRS ENABLED
    ...                PET_1070FF_MUMIMO_SRSBF_360UE_DLUL
    ...                Replicate TC [1][1.0] TDD_Fr1_MuMIMO_8DL8UL_pooling_ABIO to ASOE
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    ENABLE_ACT_BSR=auto
    ...                                                                        ENABLE_MARVIN=true

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=200
    ...                           ul_datarate=925
    ...                           dl_datarate=2125
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             ue_nr_cap=UE_CAP_8360
    ...                             tolerance=0.2
    ...                                   lua=sansa_tdd_6cell_same_nrarfcn.lua
    ...                       entry_auto_args=true
    ...                                 entry=PERFORMANCE_COMMON_TDD_MUMIMO_SRSBF
    ...                               timeout=3600
    ...                     registration_type=InitialRegistration

    Run Common Test    &{tc}
