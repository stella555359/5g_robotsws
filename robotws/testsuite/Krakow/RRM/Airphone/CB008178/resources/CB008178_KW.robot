*** Settings ***
Documentation
...    Common keywords file

Library     ta_emss
Library     ute_wtssim
Library     ta_messaging
Library     String
Library     ute_fsmaccess
Library     ta5g_pm_counters

*** Variables ***
${logcollector}=   True

*** Keywords ***
Register UE and establish PDU session
    [Arguments]  ${UE_ID}  ${CELL_ID}  ${PDU_ID}=${UE_ID}  ${SLICE_ID}=1  ${GW_ID}=${UE_ID}
    Log to console  Register NR-UE${UE_ID}
    Execute egate command
    ...    cmd=ue_change_location id=${UE_ID} cell=${CELL_ID} enb=2
    Sleep  2s
    Execute egate command
    ...    cmd=ue_register id=${UE_ID}
    Sleep  1s
    Log to console  ESTABLISH NR-UE${UE_ID}
    Execute egate command
    ...    cmd=ue_pdu_session_setup pdu=${PDU_ID} ue=${UE_ID} nwslice=${SLICE_ID} gw=${GW_ID}
    Sleep  1s

Release PDU session and deregister UE
    [Arguments]  ${UE_ID}  ${PDU_ID}=${UE_ID}
    Execute egate command
    ...    cmd=ue_pdu_session_release ue=${UE_ID} pdu=${PDU_ID}
    sleep  1s
    Execute egate command
    ...    cmd=ue_deregister id=${UE_ID} ue_deregister_type=switch_off

Set beam control testmode
    Execute egate command
    ...    cmd=beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5,6,7 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    sleep  2s
    Execute egate command
    ...    cmd=beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=3,0,1,2,4,5,6,7 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120
    sleep  2s
    Execute egate command
    ...    cmd=beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=7,0,1,2,3,4,5,6 ssbeam_bestbeam=7 ssbeam_rsrp_best=-48 ssbeam_rsrp_avg=-100
    sleep  2s

    Execute egate command
    ...    cmd=ue_testmode_set_nr id=1 testmode=beam_control action=activate profile_id=1 beamaction=attach
    sleep  2s
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=2 testmode=beam_control action=activate profile_id=2 beamaction=attach
    sleep  2s
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=3 testmode=beam_control action=activate profile_id=3 beamaction=attach
     sleep  2s

Activate NR SSB Level Measurement
    Configure    {'MOC': 'NRPMRNL', 'ID': '1', 'miNrSSBPM': '15min'}
    Configure    {'MOC': 'NRPMRNL', 'ID': '1', 'miNrUlSignalQuality2': '15min'}
    Configure    {'MOC': 'PMCADM', 'ID': '1', 'reportingIntervalPm': '15min'}
    Configure    {'MOC': 'NRBTS', 'ID': '1', 'srbInactivityTimerSA': '60s'}

Confirm that the average counters are updated with PDSCH_INIRE_VOL_SSB
    ${pm_counters}=   Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55202C00006    <0          AVG_RX_PREAMBLE_PWR_SSB
    ...    M55340C00062    >0            RX_PREAMBLE_PWR_PRACH_LEVEL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
        Verify Any Counters In File
    ...    M55202C00007    >0            PDSCH_INIRE_VOL_SSB
    ...    M55202C00008    >0            PDSCH_INIRE_VOL_SSB
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    ...    pmqap=PLMN-PLMN/SSBPM-0
    Verify Any Counters In File
    ...    M55202C00007    >0            PDSCH_INIRE_VOL_SSB
    ...    M55202C00008    >0            PDSCH_INIRE_VOL_SSB
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    ...    pmqap=PLMN-PLMN/SSBPM-3
    Verify Any Counters In File
    ...    M55202C00007    >0            PDSCH_INIRE_VOL_SSB
    ...    M55202C00008    >0            PDSCH_INIRE_VOL_SSB
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    ...    pmqap=PLMN-PLMN/SSBPM-7

Confirm that the average counters are updated
    ${pm_counters}=   Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55202C00006    <0            AVG_RX_PREAMBLE_PWR_SSB
    ...    M55340C00062    >0            RX_PREAMBLE_PWR_PRACH_LEVEL
    ...    M55202C00007    >0            PDSCH_INIRE_VOL_SSB
    ...    M55202C00008    >0            PDSCH_INIRE_VOL_SSB
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Verify Any Counters In File
    ...    M55202C00006    <0            AVG_RX_PREAMBLE_PWR_SSB
    ...    M55340C00062    >0            RX_PREAMBLE_PWR_PRACH_LEVEL
    ...    M55202C00007    >0            PDSCH_INIRE_VOL_SSB
    ...    M55202C00008    >0            PDSCH_INIRE_VOL_SSB
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counters}

    Verify Any Counters In File
    ...    M55202C00006    <0            AVG_RX_PREAMBLE_PWR_SSB
    ...    M55340C00062    >0            RX_PREAMBLE_PWR_PRACH_LEVEL
    ...    M55202C00007    >0            PDSCH_INIRE_VOL_SSB
    ...    M55202C00008    >0            PDSCH_INIRE_VOL_SSB
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters}