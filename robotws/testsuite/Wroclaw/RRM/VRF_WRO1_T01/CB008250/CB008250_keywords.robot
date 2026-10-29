*** Settings ***
Resource    ../resources/common_variables.robot
Library     ta5g_pm_counters

Documentation
...    This file contains general keywords used for testing Feature CB008250.

*** Keywords ***
Change Tdd Cells To 50 Mhz
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/Delta_LO_AP_LO_AEQE_GMC_Change_TDD_Cels_From_100Mhz_tp_50MHz.json
    Sleep    90s

Enable Plmn Aware Scheduler
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_enable_actPlmnAwareScheduler.json

Enable Slice Aware Scheduler
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_enable_actSliceAwareScheduler_and_actSliceAwareSchedulerUlAndEnh_4_Cells.json

Enable Plmn Spid And Resource Groups
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_enable_Plmn_Spid_and_resource_groups_for_8250.json
    Sleep    60s

Enable Plmn Spid And Resource Groups And Set Shares To 40 40 10 10
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_enable_Plmn_Spid_and_resource_groups_for_8250_shares_40_40_10_10.json
    Sleep    60s

Enable Actslicenumext
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_enable_actSliceNumExt.json

Disable Actrat1alloc
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_set_actRat1Alloc_to_false.json

Set Minrcellutilperplmn And Nrg To 5min
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_set_miNrCellUtilPerPLMN_and_Nrg_to_5min.json

Swap Nrplmndns
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_swap_nrPlmnDN_paths.json

Enable Allow Plmn To Share Resources
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_enable_allowPlmnToShareResources.json

Enable Fdd Tdd Ca
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_enable_fdd_tdd_CA.json

Set Subframe Tdd Lte Frame Structure 0ms
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_subframe_TDD_LTE_frame_structure_0ms.json
    Sleep    60s

Set 5qis And Their Discard Timers
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_set_5qis.json

Disable ActarpbBasedac And Enable Actulcgtype2
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_disable_actARPBasedAC_and_enable_actUlCgType2.json

Enable Minrccd
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_enable_miNrCCD.json

Set Admission Conrol
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_set_congestion_basic.json

Enable Actdcgbrservice And Set Admission Conrol
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_set_congestion.json
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_set_actDcGbrService.json

Set Nbr Settings And Admission Conrol
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_set_actNbrForNonGbrBearers_and_admission_control.json
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_set_NRDRB_MAC_for_NBR.json

Set Calibrate Settings For Grand Type 2
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/delta_calibration_For_GT2.json

Wait Enough Time So Next Checked Packet Will Have Whole Interval After Enable Allow Plmn To Share Resources
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval

Check If Resource Group Pm Counters Have Incremented Values
    [Arguments]    ${resource_group_id}=${1}    ${localmoid}=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_UL_PRB_USED_DATA_NRG}
    ...    value=0    local_moid=${localmoid}
    ...    pmqap=PLMN-PLMN/NRRESOURCEGROUP-${resource_group_id}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_UL_PRB_UTIL_SLOT_MAX_NRG}
    ...    value=0    local_moid=${localmoid}
    ...    pmqap=PLMN-PLMN/NRRESOURCEGROUP-${resource_group_id}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_UL_PRB_UTIL_RATIO_DNOM}
    ...    value=0    local_moid=${localmoid}
    ...    pmqap=PLMN-PLMN/NRRESOURCEGROUP-${resource_group_id}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_PRB_USED_DATA_NRG}
    ...    value=0    local_moid=${localmoid}
    ...    pmqap=PLMN-PLMN/NRRESOURCEGROUP-${resource_group_id}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_PRB_UTIL_SLOT_MAX_NRG}
    ...    value=0    local_moid=${localmoid}
    ...    pmqap=PLMN-PLMN/NRRESOURCEGROUP-${resource_group_id}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_PRB_UTIL_RATIO_DNOM}
    ...    value=0    local_moid=${localmoid}
    ...    pmqap=PLMN-PLMN/NRRESOURCEGROUP-${resource_group_id}    filepath=${PM_COUNTERS}

Check If Resource Group Pm Counters Have Not Incremented Values
    [Arguments]    ${resource_group_id}=${1}    ${localmoid}=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_UL_PRB_USED_DATA_NRG}
    ...    value=0    local_moid=${localmoid}
    ...    pmqap=PLMN-PLMN/NRRESOURCEGROUP-${resource_group_id}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_UL_PRB_UTIL_SLOT_MAX_NRG}
    ...    value=0    local_moid=${localmoid}
    ...    pmqap=PLMN-PLMN/NRRESOURCEGROUP-${resource_group_id}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_DL_PRB_USED_DATA_NRG}
    ...    value=0    local_moid=${localmoid}
    ...    pmqap=PLMN-PLMN/NRRESOURCEGROUP-${resource_group_id}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_DL_PRB_UTIL_SLOT_MAX_NRG}
    ...    value=0    local_moid=${localmoid}
    ...    pmqap=PLMN-PLMN/NRRESOURCEGROUP-${resource_group_id}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_UL_PRB_UTIL_RATIO_DNOM}
    ...    value=0    local_moid=${localmoid}
    ...    pmqap=PLMN-PLMN/NRRESOURCEGROUP-${resource_group_id}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_PRB_UTIL_RATIO_DNOM}
    ...    value=0    local_moid=${localmoid}
    ...    pmqap=PLMN-PLMN/NRRESOURCEGROUP-${resource_group_id}    filepath=${PM_COUNTERS}

Check If Plmn Pm Counters Have Incremented Values
    [Arguments]    ${MCC}=${311}    ${MNC}=${489}    ${localmoid}=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_PRB_USED_PUSCH_PLMN}
    ...    value=0    local_moid=${localmoid}    pmqap=PLMN-PLMN/MCC-${MCC}/MNC-${MNC}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_UL_PRB_UTIL_RATIO_DNOM_PLMN}
    ...    value=0    local_moid=${localmoid}    pmqap=PLMN-PLMN/MCC-${MCC}/MNC-${MNC}   filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_UL_PRB_UTIL_SLOT_MAX_PLMN}
    ...    value=0    local_moid=${localmoid}    pmqap=PLMN-PLMN/MCC-${MCC}/MNC-${MNC}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_PRB_USED_PDSCH_PLMN}
    ...    value=0    local_moid=${localmoid}    pmqap=PLMN-PLMN/MCC-${MCC}/MNC-${MNC}   filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_PRB_UTIL_RATIO_DNOM_PLMN}
    ...    value=0    local_moid=${localmoid}    pmqap=PLMN-PLMN/MCC-${MCC}/MNC-${MNC}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_PRB_UTIL_SLOT_MAX_PLMN}
    ...    value=0    local_moid=${localmoid}    pmqap=PLMN-PLMN/MCC-${MCC}/MNC-${MNC}    filepath=${PM_COUNTERS}

Check If Plmn Pm Counters Have Not Incremented Values
    [Arguments]    ${MCC}=${311}    ${MNC}=${489}
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_PRB_USED_PUSCH_PLMN}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    pmqap=PLMN-PLMN/MCC-${MCC}/MNC-${MNC}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_UL_PRB_UTIL_SLOT_MAX_PLMN}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    pmqap=PLMN-PLMN/MCC-${MCC}/MNC-${MNC}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_PRB_USED_PDSCH_PLMN}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    pmqap=PLMN-PLMN/MCC-${MCC}/MNC-${MNC}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_DL_PRB_UTIL_SLOT_MAX_PLMN}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    pmqap=PLMN-PLMN/MCC-${MCC}/MNC-${MNC}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_UL_PRB_UTIL_RATIO_DNOM_PLMN}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    pmqap=PLMN-PLMN/MCC-${MCC}/MNC-${MNC}   filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_PRB_UTIL_RATIO_DNOM_PLMN}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    pmqap=PLMN-PLMN/MCC-${MCC}/MNC-${MNC}   filepath=${PM_COUNTERS}

Check If Resource Groups Have Incremented Pm Counters
    [Arguments]    ${localmoid}=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    Check If Resource Group Pm Counters Have Incremented Values    resource_group_id=1    localmoid=${localmoid}
    Check If Resource Group Pm Counters Have Incremented Values    resource_group_id=2    localmoid=${localmoid}
    Check If Resource Group Pm Counters Have Incremented Values    resource_group_id=3    localmoid=${localmoid}
    Check If Resource Group Pm Counters Have Incremented Values    resource_group_id=4    localmoid=${localmoid}

Check If Resource Group Pm Counters Have Incremented Values Besides Empty One
    [Arguments]    ${localmoid}=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    Check If Resource Group Pm Counters Have Incremented Values    resource_group_id=1    localmoid=${localmoid}
    Check If Resource Group Pm Counters Have Incremented Values    resource_group_id=2    localmoid=${localmoid}
    Check If Resource Group Pm Counters Have Incremented Values    resource_group_id=3    localmoid=${localmoid}
    Check If Resource Group Pm Counters Have Not Incremented Values    resource_group_id=4    localmoid=${localmoid}

Check If All Plmns Have Incremented Pm Counters
    [Arguments]    ${localmoid}=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    Check If Plmn Pm Counters Have Incremented Values    MCC=311    MNC=489    localmoid=${localmoid}
    Check If Plmn Pm Counters Have Incremented Values    MCC=555    MNC=10    localmoid=${localmoid}
    Check If Plmn Pm Counters Have Incremented Values    MCC=450    MNC=06    localmoid=${localmoid}
    Check If Plmn Pm Counters Have Incremented Values    MCC=450    MNC=05    localmoid=${localmoid}

Register 4 Ues Per Plmn
    Attach Multiple Ues    last_ue_id=16

Register 4 Ues With Gbr Per Plmn
    Attach Multiple Ues With Gbr    last_ue_id=15

Register 4 Ues With Dc Gbr Per Plmn
    Attach Multiple Ues With Dc Gbr    last_ue_id=15

Register Ues For Every Rg Except One
    Attach Multiple Ues    last_ue_id=3
    Attach Multiple Ues    first_ue_id=5    last_ue_id=16

Register 4 Ues Per Plmn Except Plmn3
    Attach Multiple Ues    last_ue_id=8
    Attach Multiple Ues    first_ue_id=13    last_ue_id=16

Start High Dl And Ul Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl trf_id=1 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul trf_id=1 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 dir=dl trf_id=2 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 dir=ul trf_id=2 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl trf_id=3 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=ul trf_id=3 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=1 dir=dl trf_id=4 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=1 dir=ul trf_id=4 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=1 dir=dl trf_id=5 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=1 dir=ul trf_id=5 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=1 dir=dl trf_id=6 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=1 dir=ul trf_id=6 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=1 dir=dl trf_id=7 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=1 dir=ul trf_id=7 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=1 dir=dl trf_id=8 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=1 dir=ul trf_id=8 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=9 pdu=1 qfi=1 dir=dl trf_id=9 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=9 pdu=1 qfi=1 dir=ul trf_id=9 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=10 pdu=1 qfi=1 dir=dl trf_id=10 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=10 pdu=1 qfi=1 dir=ul trf_id=10 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=11 pdu=1 qfi=1 dir=dl trf_id=11 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=11 pdu=1 qfi=1 dir=ul trf_id=11 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=12 pdu=1 qfi=1 dir=dl trf_id=12 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=12 pdu=1 qfi=1 dir=ul trf_id=12 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=1 dir=dl trf_id=13 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=1 dir=ul trf_id=13 mbps=3
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=1 dir=dl trf_id=14 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=1 dir=ul trf_id=14 mbps=3
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=1 dir=dl trf_id=15 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=1 dir=ul trf_id=15 mbps=3
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=1 dir=dl trf_id=16 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=1 dir=ul trf_id=16 mbps=3

Start Dl And Ul Data Traffic For Every Rg Exept One
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl trf_id=1 mbps=134
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul trf_id=1 mbps=25
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 dir=dl trf_id=2 mbps=134
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 dir=ul trf_id=2 mbps=25
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl trf_id=3 mbps=134
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=ul trf_id=3 mbps=25
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=1 dir=dl trf_id=5 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=1 dir=ul trf_id=5 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=1 dir=dl trf_id=6 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=1 dir=ul trf_id=6 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=1 dir=dl trf_id=7 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=1 dir=ul trf_id=7 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=1 dir=dl trf_id=8 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=1 dir=ul trf_id=8 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=9 pdu=1 qfi=1 dir=dl trf_id=9 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=9 pdu=1 qfi=1 dir=ul trf_id=9 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=10 pdu=1 qfi=1 dir=dl trf_id=10 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=10 pdu=1 qfi=1 dir=ul trf_id=10 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=11 pdu=1 qfi=1 dir=dl trf_id=11 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=11 pdu=1 qfi=1 dir=ul trf_id=11 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=12 pdu=1 qfi=1 dir=dl trf_id=12 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=12 pdu=1 qfi=1 dir=ul trf_id=12 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=1 dir=dl trf_id=13 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=1 dir=ul trf_id=13 mbps=3
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=1 dir=dl trf_id=14 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=1 dir=ul trf_id=14 mbps=3
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=1 dir=dl trf_id=15 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=1 dir=ul trf_id=15 mbps=3
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=1 dir=dl trf_id=16 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=1 dir=ul trf_id=16 mbps=3

Start High Dl And Ul Data Traffic For 3 PLMN
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl trf_id=1 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul trf_id=1 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 dir=dl trf_id=2 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 dir=ul trf_id=2 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl trf_id=3 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=ul trf_id=3 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=1 dir=dl trf_id=4 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=1 dir=ul trf_id=4 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=1 dir=dl trf_id=5 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=1 dir=ul trf_id=5 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=1 dir=dl trf_id=6 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=1 dir=ul trf_id=6 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=1 dir=dl trf_id=7 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=1 dir=ul trf_id=7 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=1 dir=dl trf_id=8 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=1 dir=ul trf_id=8 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=1 dir=dl trf_id=10 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=1 dir=ul trf_id=10 mbps=3
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=1 dir=dl trf_id=11 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=1 dir=ul trf_id=11 mbps=3
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=1 dir=dl trf_id=12 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=1 dir=ul trf_id=12 mbps=3
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=1 dir=dl trf_id=12 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=1 dir=ul trf_id=12 mbps=3

Start High Dl And Ul Data Traffic For Ca
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl trf_id=1 mbps=160
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul trf_id=17 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 dir=dl trf_id=2 mbps=160
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 dir=ul trf_id=18 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl trf_id=3 mbps=160
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=ul trf_id=19 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=1 dir=dl trf_id=4 mbps=160
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=1 dir=ul trf_id=20 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=1 dir=dl trf_id=5 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=1 dir=ul trf_id=5 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=1 dir=dl trf_id=6 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=1 dir=ul trf_id=6 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=1 dir=dl trf_id=7 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=1 dir=ul trf_id=7 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=1 dir=dl trf_id=8 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=1 dir=ul trf_id=8 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=9 pdu=1 qfi=1 dir=dl trf_id=9 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=9 pdu=1 qfi=1 dir=ul trf_id=9 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=10 pdu=1 qfi=1 dir=dl trf_id=10 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=10 pdu=1 qfi=1 dir=ul trf_id=10 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=11 pdu=1 qfi=1 dir=dl trf_id=11 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=11 pdu=1 qfi=1 dir=ul trf_id=11 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=12 pdu=1 qfi=1 dir=dl trf_id=12 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=12 pdu=1 qfi=1 dir=ul trf_id=12 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=1 dir=dl trf_id=13 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=1 dir=ul trf_id=13 mbps=3
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=1 dir=dl trf_id=14 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=1 dir=ul trf_id=14 mbps=3
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=1 dir=dl trf_id=15 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=1 dir=ul trf_id=15 mbps=3
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=1 dir=dl trf_id=16 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=1 dir=ul trf_id=16 mbps=3

Start High Gbr Dl And Ul Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl trf_id=1 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=ul trf_id=1 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=3 dir=dl trf_id=2 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=3 dir=ul trf_id=2 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=3 dir=dl trf_id=3 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=3 dir=ul trf_id=3 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=3 dir=dl trf_id=4 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=3 dir=ul trf_id=4 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=3 dir=dl trf_id=5 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=3 dir=ul trf_id=5 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=3 dir=dl trf_id=6 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=3 dir=ul trf_id=6 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=3 dir=dl trf_id=7 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=3 dir=ul trf_id=7 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=3 dir=dl trf_id=8 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=3 dir=ul trf_id=8 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=9 pdu=1 qfi=3 dir=dl trf_id=9 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=9 pdu=1 qfi=3 dir=ul trf_id=9 mbps=5
    Execute Egate Command    cmd=trf_data_start ue=10 pdu=1 qfi=3 dir=dl trf_id=10 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=10 pdu=1 qfi=3 dir=ul trf_id=10 mbps=5
    Execute Egate Command    cmd=trf_data_start ue=11 pdu=1 qfi=3 dir=dl trf_id=11 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=11 pdu=1 qfi=3 dir=ul trf_id=11 mbps=5
    Execute Egate Command    cmd=trf_data_start ue=12 pdu=1 qfi=3 dir=dl trf_id=12 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=12 pdu=1 qfi=3 dir=ul trf_id=12 mbps=5
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=3 dir=dl trf_id=13 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=3 dir=ul trf_id=13 mbps=1
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=3 dir=dl trf_id=14 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=3 dir=ul trf_id=14 mbps=1
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=3 dir=dl trf_id=15 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=3 dir=ul trf_id=15 mbps=1
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=3 dir=dl trf_id=16 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=3 dir=ul trf_id=16 mbps=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl trf_id=17 mbps=90
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul trf_id=17 mbps=15
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 dir=dl trf_id=18 mbps=90
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 dir=ul trf_id=18 mbps=15
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl trf_id=19 mbps=90
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=ul trf_id=19 mbps=15
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=1 dir=dl trf_id=20 mbps=90
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=1 dir=ul trf_id=20 mbps=15
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=1 dir=dl trf_id=21 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=1 dir=ul trf_id=21 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=1 dir=dl trf_id=22 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=1 dir=ul trf_id=22 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=1 dir=dl trf_id=23 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=1 dir=ul trf_id=23 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=1 dir=dl trf_id=24 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=1 dir=ul trf_id=24 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=9 pdu=1 qfi=1 dir=dl trf_id=25 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=9 pdu=1 qfi=1 dir=ul trf_id=25 mbps=5
    Execute Egate Command    cmd=trf_data_start ue=10 pdu=1 qfi=1 dir=dl trf_id=26 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=10 pdu=1 qfi=1 dir=ul trf_id=26 mbps=5
    Execute Egate Command    cmd=trf_data_start ue=11 pdu=1 qfi=1 dir=dl trf_id=27 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=11 pdu=1 qfi=1 dir=ul trf_id=27 mbps=5
    Execute Egate Command    cmd=trf_data_start ue=12 pdu=1 qfi=1 dir=dl trf_id=28 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=12 pdu=1 qfi=1 dir=ul trf_id=28 mbps=5
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=1 dir=dl trf_id=29 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=1 dir=ul trf_id=29 mbps=1
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=1 dir=dl trf_id=30 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=1 dir=ul trf_id=30 mbps=1
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=1 dir=dl trf_id=31 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=1 dir=ul trf_id=31 mbps=1
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=1 dir=dl trf_id=32 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=1 dir=ul trf_id=32 mbps=1

Start High Dc Gbr Dl And Ul Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl trf_id=1 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=ul trf_id=1 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=2 dir=dl trf_id=2 mbps=90
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=2 dir=ul trf_id=2 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=dl trf_id=3 mbps=90
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=2 dir=ul trf_id=3 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=2 dir=dl trf_id=4 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=2 dir=ul trf_id=4 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=2 dir=dl trf_id=5 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=2 dir=ul trf_id=5 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=2 dir=dl trf_id=6 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=2 dir=ul trf_id=6 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=2 dir=dl trf_id=7 mbps=90
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=2 dir=ul trf_id=7 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=2 dir=dl trf_id=8 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=2 dir=ul trf_id=8 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=9 pdu=1 qfi=2 dir=dl trf_id=9 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=9 pdu=1 qfi=2 dir=ul trf_id=9 mbps=5
    Execute Egate Command    cmd=trf_data_start ue=10 pdu=1 qfi=2 dir=dl trf_id=10 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=10 pdu=1 qfi=2 dir=ul trf_id=10 mbps=5
    Execute Egate Command    cmd=trf_data_start ue=11 pdu=1 qfi=2 dir=dl trf_id=11 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=11 pdu=1 qfi=2 dir=ul trf_id=11 mbps=5
    Execute Egate Command    cmd=trf_data_start ue=12 pdu=1 qfi=2 dir=dl trf_id=12 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=12 pdu=1 qfi=2 dir=ul trf_id=12 mbps=5
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=2 dir=dl trf_id=13 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=2 dir=ul trf_id=13 mbps=1
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=2 dir=dl trf_id=14 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=2 dir=ul trf_id=14 mbps=1
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=2 dir=dl trf_id=15 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=2 dir=ul trf_id=15 mbps=1
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=2 dir=dl trf_id=16 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=2 dir=ul trf_id=16 mbps=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl trf_id=17 mbps=90
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul trf_id=17 mbps=15
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 dir=dl trf_id=18 mbps=90
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 dir=ul trf_id=18 mbps=15
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl trf_id=19 mbps=90
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=ul trf_id=19 mbps=15
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=1 dir=dl trf_id=20 mbps=90
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=1 dir=ul trf_id=20 mbps=15
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=1 dir=dl trf_id=21 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=1 dir=ul trf_id=21 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=1 dir=dl trf_id=22 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=1 dir=ul trf_id=22 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=1 dir=dl trf_id=23 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=1 dir=ul trf_id=23 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=1 dir=dl trf_id=24 mbps=50
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=1 dir=ul trf_id=24 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=9 pdu=1 qfi=1 dir=dl trf_id=25 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=9 pdu=1 qfi=1 dir=ul trf_id=25 mbps=5
    Execute Egate Command    cmd=trf_data_start ue=10 pdu=1 qfi=1 dir=dl trf_id=26 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=10 pdu=1 qfi=1 dir=ul trf_id=26 mbps=5
    Execute Egate Command    cmd=trf_data_start ue=11 pdu=1 qfi=1 dir=dl trf_id=27 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=11 pdu=1 qfi=1 dir=ul trf_id=27 mbps=5
    Execute Egate Command    cmd=trf_data_start ue=12 pdu=1 qfi=1 dir=dl trf_id=28 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=12 pdu=1 qfi=1 dir=ul trf_id=28 mbps=5
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=1 dir=dl trf_id=29 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=1 dir=ul trf_id=29 mbps=1
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=1 dir=dl trf_id=30 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=1 dir=ul trf_id=30 mbps=1
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=1 dir=dl trf_id=31 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=1 dir=ul trf_id=31 mbps=1
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=1 dir=dl trf_id=32 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=1 dir=ul trf_id=32 mbps=1

Start High Dl And Ul Data Traffic For Nbr And Part For Non Gbr
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl trf_id=1 mbps=70
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul trf_id=1 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl trf_id=1 mbps=70
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=ul trf_id=1 mbps=9
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=2 dir=dl trf_id=2 mbps=140
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=2 dir=ul trf_id=2 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=dl trf_id=3 mbps=140
    Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 dir=ul trf_id=3 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=1 dir=dl trf_id=4 mbps=140
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=1 qfi=1 dir=ul trf_id=4 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=1 dir=dl trf_id=5 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=5 pdu=1 qfi=1 dir=ul trf_id=5 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=1 dir=dl trf_id=6 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=6 pdu=1 qfi=1 dir=ul trf_id=6 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=1 dir=dl trf_id=7 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=7 pdu=1 qfi=1 dir=ul trf_id=7 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=1 dir=dl trf_id=8 mbps=100
    Execute Egate Command    cmd=trf_data_start ue=8 pdu=1 qfi=1 dir=ul trf_id=8 mbps=18
    Execute Egate Command    cmd=trf_data_start ue=9 pdu=1 qfi=1 dir=dl trf_id=9 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=9 pdu=1 qfi=1 dir=ul trf_id=9 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=10 pdu=1 qfi=1 dir=dl trf_id=10 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=10 pdu=1 qfi=1 dir=ul trf_id=10 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=11 pdu=1 qfi=1 dir=dl trf_id=11 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=11 pdu=1 qfi=1 dir=ul trf_id=11 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=12 pdu=1 qfi=1 dir=dl trf_id=12 mbps=40
    Execute Egate Command    cmd=trf_data_start ue=12 pdu=1 qfi=1 dir=ul trf_id=12 mbps=10
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=1 dir=dl trf_id=13 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=13 pdu=1 qfi=1 dir=ul trf_id=13 mbps=3
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=1 dir=dl trf_id=14 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=14 pdu=1 qfi=1 dir=ul trf_id=14 mbps=3
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=1 dir=dl trf_id=15 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=15 pdu=1 qfi=1 dir=ul trf_id=15 mbps=3
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=1 dir=dl trf_id=16 mbps=20
    Execute Egate Command    cmd=trf_data_start ue=16 pdu=1 qfi=1 dir=ul trf_id=16 mbps=3

