*** Settings ***
Documentation
...  author:  Marcin Flis, Monika Mysliwiec
...  contact: marcin.1.flis@nokia.com, monika.banas@nokia.com
...  description: Test Cases for testline with ABIP and FR2

Resource    ./resources/suite_specific_keywords.robot

*** Test Cases ***
[1][2.0] Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    CRT
    [Setup]   Common Test Setup for different configs
    ...                                                         scfc_file=config_2a.xml
    Log Action To Console                                       Waiting for BTS after commissiong
    Sleep                                                       250s
    Require UE                                                  QC_SDX75    REAL_ANDROID_UE
    Log Action To Console                                       ---------Verify L3 call for 4x4CC---------
    Verify L3 call TCP DL                                       ue_type_1=QC_SDX75
    ...                                                         dl_tput=2100 Mbits/sec
    Sleep                                                       10s
    Verify L3 call TCP UL                                       ue_type_1=QC_SDX75
    ...                                                         ul_tput=245 Mbits/sec
    Repeat Keyword                                              10 times
    ...                                                         Manual SiSo SM BTS Site Reset
    Sleep                                                       250s
    Log Action To Console                                       ---------Verify L3 call for 4x4CC---------
    Verify L3 call TCP DL                                        ue_type_1=QC_SDX75
    ...                                                         dl_tput=2100 Mbits/sec
    Sleep                                                       10s
    Verify L3 call TCP UL                                       ue_type_1=QC_SDX75
    ...                                                         ul_tput=245 Mbits/sec
    [Teardown]    Common Postconditions

[1][2.0] Manual_SiSo_CM_Recommissioning
    [Tags]    CRT
    [Setup]   Common Test Setup for different configs
    ...                                                         scfc_file=config_3c.xml
    Require UE                                                  QC_SDX75    REAL_ANDROID_UE
    Require UE                                                  S21         SAMSUNG_S21
    Log Action To Console                                       ---------Verify L3 call for 1x8CC and 2x4CC---------
    Verify L3 call                                              ue_type_1=QC_SDX75
    ...                                                         ue_type_2=S21
    ...                                                         ul_throughput_1=550 Mbits/sec
    ...                                                         ul_throughput_2=250 Mbits/sec
    ...                                                         dl_throughput_1=4.10 Gbits/sec
    ...                                                         dl_throughput_2=2.10 Gbits/sec
    ...                                                         ul_throughput_for_verify_1=550 Mbits/sec
    ...                                                         ul_throughput_for_verify_2=240 Mbits/sec
    ...                                                         dl_throughput_for_verify_1=4.10 Gbits/sec
    ...                                                         dl_throughput_for_verify_2=2.10 Gbits/sec
    ...                                                         max_allowed_data_loss=5%
    Log Action To Console                                       Perform configuration parameter recommissioning on gNB for actPaging
    Perform configuration parameter recommissioning on gNB      MRBTS-77059/NRBTS-77059
    ...                                                         actPaging
    ...                                                         true
    Wait Until Keyword Succeeds                                 180 seconds  15 seconds  gnbru.Verify All Radio Units Are Online
    Wait Until Keyword Succeeds                                 180 seconds  15 seconds  gnbcell.Verify All Cells are OnAir
    Log Action To Console                                       Perform configuration parameter recommissioning on gNB for miNrPaging
    Perform configuration parameter recommissioning on gNB      MRBTS-77059/NRBTS-77059/NRPMRNL-1
    ...                                                         miNrPaging
    ...                                                         5min
    Wait Until Keyword Succeeds                                 180 seconds  15 seconds  gnbru.Verify All Radio Units Are Online
    Wait Until Keyword Succeeds                                 180 seconds  15 seconds  gnbcell.Verify All Cells are OnAir
    Log Action To Console                                       Perform configuration parameter recommissioning on gNB for prachConfigurationIndex
    Perform configuration parameter recommissioning on gNB      MRBTS-77059/NRBTS-77059/NRCELL-51
    ...                                                         prachConfigurationIndex
    ...                                                         175
    Wait Until Keyword Succeeds                                 180 seconds  15 seconds  gnbru.Verify All Radio Units Are Online
    Wait Until Keyword Succeeds                                 180 seconds  15 seconds  gnbcell.Verify All Cells are OnAir
    Log Action To Console                                       Perform configuration parameter recommissioning on gNB for manualFrameTimingAdjustment
    Perform configuration parameter recommissioning on gNB      MRBTS-77059/NRBTS-77059/NRPMRNL-1
    ...                                                         miNrPaging
    ...                                                         15min
    Wait Until Keyword Succeeds                                 180 seconds  15 seconds  gnbru.Verify All Radio Units Are Online
    Wait Until Keyword Succeeds                                 180 seconds  15 seconds  gnbcell.Verify All Cells are OnAir
    Log Action To Console                                       Perform configuration parameter recommissioning on gNB for wrong parameters
    Try change parameter to wrong value                         MRBTS-77059/NRBTS-77059/NRCELL-51
    ...                                                         prachConfigurationIndex
    ...                                                         17500
    ...                                                         AdminApiProcedureFailureException
    Wait Until Keyword Succeeds                                 180 seconds  15 seconds  gnbru.Verify All Radio Units Are Online
    Wait Until Keyword Succeeds                                 180 seconds  15 seconds  gnbcell.Verify All Cells are OnAir
    Log Action To Console                                       ---------Verify L3 call for 1x8CC and 2x4CC---------
    Verify L3 call                                              ue_type_1=QC_SDX75
    ...                                                         ue_type_2=S21
    ...                                                         ul_throughput_1=550 Mbits/sec
    ...                                                         ul_throughput_2=250 Mbits/sec
    ...                                                         dl_throughput_1=4.10 Gbits/sec
    ...                                                         dl_throughput_2=2.10 Gbits/sec
    ...                                                         ul_throughput_for_verify_1=550 Mbits/sec
    ...                                                         ul_throughput_for_verify_2=240 Mbits/sec
    ...                                                         dl_throughput_for_verify_1=4.10 Gbits/sec
    ...                                                         dl_throughput_for_verify_2=2.10 Gbits/sec
    ...                                                         max_allowed_data_loss=5%
    [Teardown]    Common Postconditions

[1][3.0] General_SiSo_Cell_block_and_unblock
    [Tags]    CRT
    [Setup]   Common Test Setup for different configs
    ...                                                         scfc_file=config_2a.xml
    Require UE                                                  QC_SDX75    REAL_ANDROID_UE
    Require UE                                                  S21         SAMSUNG_S21
    Log Action To Console                                       ---------Verify L3 call for 4x4CC---------
    Verify L3 call                                              ue_type_1=QC_SDX75
    ...                                                         ue_type_2=S21
    ...                                                         ul_throughput_1=250 Mbits/sec
    ...                                                         ul_throughput_2=250 Mbits/sec
    ...                                                         dl_throughput_1=2.10 Gbits/sec
    ...                                                         dl_throughput_2=2.10 Gbits/sec
    ...                                                         ul_throughput_for_verify_1=240 Mbits/sec
    ...                                                         ul_throughput_for_verify_2=240 Mbits/sec
    ...                                                         dl_throughput_for_verify_1=2.10 Gbits/sec
    ...                                                         dl_throughput_for_verify_2=2.10 Gbits/sec
    ...                                                         max_allowed_data_loss=5%
    Log Action To Console                                       ---------Cell block and unblock--------
    Repeat Keyword                                              10 times
    ...                                                         General SiSo Cell block and unblock
    Log Action To Console                                       ---------Verify L3 call for 4x4CC---------
    Verify L3 call                                              ue_type_1=QC_SDX75
    ...                                                         ue_type_2=S21
    ...                                                         ul_throughput_1=250 Mbits/sec
    ...                                                         ul_throughput_2=250 Mbits/sec
    ...                                                         dl_throughput_1=2.10 Gbits/sec
    ...                                                         dl_throughput_2=2.10 Gbits/sec
    ...                                                         ul_throughput_for_verify_1=240 Mbits/sec
    ...                                                         ul_throughput_for_verify_2=240 Mbits/sec
    ...                                                         dl_throughput_for_verify_1=2.10 Gbits/sec
    ...                                                         dl_throughput_for_verify_2=2.10 Gbits/sec
    ...                                                         max_allowed_data_loss=5%
    [Teardown]    Common Postconditions

[2][2.0] Manual_SiSo_SM_RF_Module_lock_unlock
    [Tags]    CRT
    [Setup]   Common Test Setup for different configs
    ...                                                         scfc_file=config_2a.xml
    Require UE                                                  QC_SDX75    REAL_ANDROID_UE
    Require UE                                                  S21         SAMSUNG_S21
    Log Action To Console                                       ---------Verify L3 call for 4x4CC---------
    Verify L3 call                                              ue_type_1=QC_SDX75
    ...                                                         ue_type_2=S21
    ...                                                         ul_throughput_1=230 Mbits/sec
    ...                                                         ul_throughput_2=230 Mbits/sec
    ...                                                         dl_throughput_1=2.10 Gbits/sec
    ...                                                         dl_throughput_2=2.10 Gbits/sec
    ...                                                         ul_throughput_for_verify_1=230 Mbits/sec
    ...                                                         ul_throughput_for_verify_2=230 Mbits/sec
    ...                                                         dl_throughput_for_verify_1=2.10 Gbits/sec
    ...                                                         dl_throughput_for_verify_2=2.10 Gbits/sec
    ...                                                         max_allowed_data_loss=5%
    Repeat Keyword                                              10 times
    ...                                                         Lock Unlock RF Units from GUI
    Log Action To Console                                       ---------Verify L3 call for 4x4CC---------
    Verify L3 call                                              ue_type_1=QC_SDX75
    ...                                                         ue_type_2=S21
    ...                                                         ul_throughput_1=230 Mbits/sec
    ...                                                         ul_throughput_2=230 Mbits/sec
    ...                                                         dl_throughput_1=2.10 Gbits/sec
    ...                                                         dl_throughput_2=2.10 Gbits/sec
    ...                                                         ul_throughput_for_verify_1=230 Mbits/sec
    ...                                                         ul_throughput_for_verify_2=230 Mbits/sec
    ...                                                         dl_throughput_for_verify_1=2.10 Gbits/sec
    ...                                                         dl_throughput_for_verify_2=2.10 Gbits/sec
    ...                                                         max_allowed_data_loss=5%
    [Teardown]    Common Postconditions

[1][1.0] General_SiSo_BB_sub-unit_reset_with_L3_call
    [Tags]     CRT
    [Setup]   Common Test Setup for different configs
    ...                                                         scfc_file=config_1a.xml
    Log Action To Console                                       Waiting for BTS after commisiong KW
    Sleep                                                       250s
    Require UE                                                  QC_SDX75    REAL_ANDROID_UE
    Log Action To Console                                       ---------Verify L3 call for 2x8CC---------
    Verify L3 call TCP DL                                       ue_type_1=QC_SDX75
    ...                                                         dl_tput=4100 Mbits/sec
    Sleep                                                       20s
    Verify L3 call TCP UL                                       ue_type_1=QC_SDX75
    ...                                                         ul_tput=540 Mbits/sec
    Repeat Keyword                                              5 times
    ...                                                         Reset BBMODs and check alarms
    ...                                                         bb_mod_id_1=1
    ...                                                         bb_mod_id_2=2
    Sleep                                                       250s
    Log Action To Console                                       ---------Verify L3 call for 2x8CC---------
    Verify L3 call TCP DL                                       ue_type_1=QC_SDX75
    ...                                                         dl_tput=4100 Mbits/sec
    Sleep                                                       20s
    Verify L3 call TCP UL                                       ue_type_1=QC_SDX75
    ...                                                         ul_tput=540 Mbits/sec
    [Teardown]    Common Postconditions

[1][1.0] Manual_SiSo_SM_NR_cell_lock_unlock_administrative_state_change_from_GUI
    [Tags]    CRT
    [Setup]   Common Test Setup for different configs
    ...                                                         scfc_file=config_1c.xml
    Require UE                                                  QC_SDX75    REAL_ANDROID_UE
    Require UE                                                  S21         SAMSUNG_S21
    Log Action To Console                                       ---------Verify L3 call for 2x8CC---------
    Verify L3 call                                              ue_type_1=QC_SDX75
    ...                                                         ue_type_2=S21
    ...                                                         ul_throughput_1=550 Mbits/sec
    ...                                                         ul_throughput_2=230 Mbits/sec
    ...                                                         dl_throughput_1=4.10 Gbits/sec
    ...                                                         dl_throughput_2=4.10 Gbits/sec
    ...                                                         ul_throughput_for_verify_1=550 Mbits/sec
    ...                                                         ul_throughput_for_verify_2=230 Mbits/sec
    ...                                                         dl_throughput_for_verify_1=4.10 Gbits/sec
    ...                                                         dl_throughput_for_verify_2=4.10 Gbits/sec
    ...                                                         max_allowed_data_loss=5%
    Repeat Keyword                                              5 times
    ...                                                         Lock Unlock All Cells
    Log Action To Console                                       ---------Verify L3 call for 2x8CC---------
    Verify L3 call                                              ue_type_1=QC_SDX75
    ...                                                         ue_type_2=S21
    ...                                                         ul_throughput_1=550 Mbits/sec
    ...                                                         ul_throughput_2=230 Mbits/sec
    ...                                                         dl_throughput_1=4.10 Gbits/sec
    ...                                                         dl_throughput_2=4.10 Gbits/sec
    ...                                                         ul_throughput_for_verify_1=550 Mbits/sec
    ...                                                         ul_throughput_for_verify_2=230 Mbits/sec
    ...                                                         dl_throughput_for_verify_1=4.10 Gbits/sec
    ...                                                         dl_throughput_for_verify_2=4.10 Gbits/sec
    ...                                                         max_allowed_data_loss=5%
    [Teardown]    Common Postconditions
