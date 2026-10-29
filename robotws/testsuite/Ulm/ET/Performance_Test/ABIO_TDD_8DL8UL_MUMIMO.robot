*** Settings ***
Documentation
...  author:  VRF_RRM_T05
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 6 Cells 8DL8UL MUMIMO in ABIO

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_test_setup.robot

Force Tags    CLOUD_5G_I_LO_AP_LOOO

Suite Setup       performance_test_setup.Suite Setup For Performance Test
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
ABIO_TDD_6Cells_8DL8UL_MUMIMO
    [Documentation]    SRS ENABLED
    ...                PET_1070FF_MUMIMO_SRSBF_360UE_DLUL
    ...                To replace Viavi TC [1][1.0] TDD_Fr1_MuMIMO_8DL8UL_pooling_ABIO
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                                                ENABLE_ACT_BSR=auto

    Set Test Variable   ${QC_TEST_NAME}   [1]TDD_Fr1_MuMIMO_8DL8UL_pooling_ABIO
    Set Test Variable    ${QC_PATH}       testsuite/Ulm/ET/Performance_Test/resources/qc/ABIO_performance.qc

    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=200
    ...                           ul_datarate=1500
    ...                           dl_datarate=5000
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             ue_nr_cap=UE_CAP_8360
    ...                             tolerance=0.5
    ...                                   lua=sansa_tdd_6cell_same_nrarfcn.lua
    ...                       entry_auto_args=false
    ...                                 entry=PET_1070FF_MUMIMO_SRSBF_1200UE_DLUL
    ...                               timeout=3600
    ...                     registration_type=InitialRegistration

    performance_keywords.Run Common Test    &{tc}
