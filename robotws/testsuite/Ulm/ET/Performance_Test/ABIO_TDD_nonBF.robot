*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 1 Cell 100 UEs Performance Test

Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_test_setup.robot

Force Tags    CLOUD_5G_I_LO_AP_LOOO

Suite Setup       performance_test_setup.Suite Setup For Performance Test
...                                                   SCF_ENABLE_BEAMFORMING=true    # convert this to BF testcase when enabled
...                                                   SCF_CONFIGURE_SRS=true
...                                                   ENABLE_SRS_INFO=true
...                                                   SCF_SET_VAR_NRCELL_actUlSrsBm=true
...                                                   SCF_SET_VAR_NRCELL_actDlSrsBm=true
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
tdd_1Cell_100Ues_DL_ABIO_static_8246
    [Documentation]
    ...    Same as tdd_1Cell_100Ues_DL_ABIO but with 8246 Enabled with Static PDCCH configuration
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                   SCF_ENABLE_CB008246=true
    ...            SCF_ENABLE_CB008246_STATIC=true

    performance_keywords.Run Common Test                start_cell=1
    ...                              end_cell=1
    ...                           ue_per_cell=100
    ...                           ul_datarate=0
    ...                           dl_datarate=22200
    ...                                  rate=kbps
    ...                         trf_direction=dl
    ...                             tolerance=0.6959459459459459
    ...                                   lua=sansa_tdd_1cell.lua
    ...                             ue_nr_cap=UE_CAP_8246
    ...                       entry_auto_args=false
    ...                                 entry=PET_1208FF_nonBF_100UE_DL


tdd_1Cell_100Ues_UL_ABIO_static_8246
    [Documentation]
    ...    Same as tdd_1Cell_100Ues_UL_ABIO but with 8246 Enabled with Static PDCCH configuration
    [Setup]    performance_test_setup.Test Case Setup For Performance Test
    ...                   SCF_ENABLE_CB008246=true
    ...            SCF_ENABLE_CB008246_STATIC=true

    performance_keywords.Run Common Test                start_cell=1
    ...                              end_cell=1
    ...                           ue_per_cell=100
    ...                           ul_datarate=3000
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                             tolerance=0.55
    ...                                   lua=sansa_tdd_1cell.lua
    ...                             ue_nr_cap=UE_CAP_8246
    ...                       entry_auto_args=false
    ...                                 entry=PET_1208FF_nonBF_100UE_UL


tdd_1Cell_100Ues_DL_ABIO_dynamic_8246
    [Documentation]
    ...    Same as tdd_1Cell_100Ues_DL_ABIO but with 8246 Enabled with Dynamic PDCCH configuration
    [Tags]    DL
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    SCF_ENABLE_CB008246=true

    performance_keywords.Run Common Test                start_cell=1
    ...                              end_cell=1
    ...                           ue_per_cell=100
    ...                           ul_datarate=0
    ...                           dl_datarate=22200
    ...                                  rate=kbps
    ...                         trf_direction=dl
    ...                             tolerance=0.6959459459459459
    ...                                   lua=sansa_tdd_1cell.lua
    ...                             ue_nr_cap=UE_CAP_8246
    ...                       entry_auto_args=false
    ...                                 entry=PET_1208FF_nonBF_100UE_DL


tdd_1Cell_100Ues_UL_ABIO_dynamic_8246
    [Documentation]
    ...    Same as tdd_1Cell_100Ues_UL_ABIO but with 8246 Enabled with Dynamic PDCCH configuration
    [Tags]    UL
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    SCF_ENABLE_CB008246=true

    performance_keywords.Run Common Test                start_cell=1
    ...                              end_cell=1
    ...                           ue_per_cell=100
    ...                           ul_datarate=3000
    ...                           dl_datarate=0
    ...                                  rate=kbps
    ...                         trf_direction=ul
    ...                             tolerance=0.55
    ...                                   lua=sansa_tdd_1cell.lua
    ...                             ue_nr_cap=UE_CAP_8246
    ...                       entry_auto_args=false
    ...                                 entry=PET_1208FF_nonBF_100UE_UL
