*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Marcin Kotula
...              :contact: marcin.kotula@nokia.com

Resource     resources/CB009843_keywords.robot
Resource     ../CB007813/connect.robot


*** Variables ***
${IPHY_CB009843_AVHA}          ${CURDIR}/config/iphy_6xAVHA_50mhz.xml
${SCF_CB009843_AVHA}           ${CURDIR}/config/SBTS00/full_CB008701.xml
${CFG_CB009843_AVHA}           ${CURDIR}/config/basic_setup_mumimo.cfg
@{SWCONFIG_FLAGS}              0x8000A6=0
${LOCAL_MOID-1}                PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${LOCAL_MOID-2}                PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
${LOCAL_MOID-3}                PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
${LOCAL_MOID-4}                PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
${LOCAL_MOID-5}                PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
${LOCAL_MOID-6}                PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-6
${PRB_DL_MU_MIMO_4PAIR_UE}     M55308C34015
${PRB_DL_MU_MIMO_3PAIR_UE}     M55308C34014
${PRB_DL_MU_MIMO_2PAIR_UE}     M55308C34013
${PRB_DL_MU_MIMO_8LAYER}       M55308C34011
${PRB_DL_MU_MIMO_6LAYER}       M55308C34009
${PRB_DL_MU_MIMO_4LAYER}       M55308C34007


*** Keywords ***
CB008701-A_15_Verify_PMCounter_For_MUMIMO_24_UE
    Set Beams 24 UE
    Attach UEs    num_ue=24
    Start Dl and UL Data Traffic For All UEs    num_ue=24    dl_mbps=175    ul_mbps=10
    Verify 4 UEs Pairing Counters Layer 8
    Change Parameter dlMuMaxNumLayerPerMuRbg Value To 6
    Verify 3 UEs Pairing Counters Layer 8 And 6
    Change Parameter dlMuMaxNumLayerPerMuRbg Value To 4
    Verify 2 UEs Pairing Counters Layer 6 And 4


Change Parameter dlMuMaxNumLayerPerMuRbg Value To 4
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1
    ...     parameter=dlMuMaxNumLayerPerMuRbg    value=4
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-2/NRDLMUMIMO-1
    ...     parameter=dlMuMaxNumLayerPerMuRbg    value=4
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-3/NRDLMUMIMO-1
    ...     parameter=dlMuMaxNumLayerPerMuRbg    value=4
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-4/NRDLMUMIMO-1
    ...     parameter=dlMuMaxNumLayerPerMuRbg    value=4
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-5/NRDLMUMIMO-1
    ...     parameter=dlMuMaxNumLayerPerMuRbg    value=4
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-6/NRDLMUMIMO-1
    ...     parameter=dlMuMaxNumLayerPerMuRbg    value=4

Change Parameter dlMuMaxNumLayerPerMuRbg Value To 6
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1
    ...     parameter=dlMuMaxNumLayerPerMuRbg    value=6
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-2/NRDLMUMIMO-1
    ...     parameter=dlMuMaxNumLayerPerMuRbg    value=6
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-3/NRDLMUMIMO-1
    ...     parameter=dlMuMaxNumLayerPerMuRbg    value=6
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-4/NRDLMUMIMO-1
    ...     parameter=dlMuMaxNumLayerPerMuRbg    value=6
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-5/NRDLMUMIMO-1
    ...     parameter=dlMuMaxNumLayerPerMuRbg    value=6
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-6/NRDLMUMIMO-1
    ...     parameter=dlMuMaxNumLayerPerMuRbg    value=6

Set Beams 24 UE
    Execute Egate Command   cmd=ul_ue_beam_pos_nr profile_id=1 num_beam_paths=4 azimuth=14,43,-14,-43 zenith=12,2,12,2
    ...     power=-250,-250,-250,-250
    Execute Egate Command   cmd=ul_ue_beam_pos_nr profile_id=2 num_beam_paths=4 azimuth=-3,22,-14,18 zenith=-9,-9,-7,-7
    ...     power=-250,-250,-250,-250
    Execute Egate Command   cmd=ul_ue_beam_pos_nr profile_id=3 num_beam_paths=4 azimuth=22,22,37,37 zenith=-4,-4,-4,-4
    ...     power=-250,-250,-250,-250
    Execute Egate Command   cmd=ul_ue_beam_pos_nr profile_id=4 num_beam_paths=4 azimuth=21,37,50,10 zenith=7,7,7,7
    ...     power=-250,-250,-250,-250
    Execute Egate Command   cmd=ue_testmode_set_nr id=1 testmode=ue_ul_beam_position action=activate profile_id=1
    Execute Egate Command   cmd=ue_testmode_set_nr id=2 testmode=ue_ul_beam_position action=activate profile_id=2
    Execute Egate Command   cmd=ue_testmode_set_nr id=3 testmode=ue_ul_beam_position action=activate profile_id=3
    Execute Egate Command   cmd=ue_testmode_set_nr id=4 testmode=ue_ul_beam_position action=activate profile_id=4
    Execute Egate Command   cmd=ue_testmode_set_nr id=5 testmode=ue_ul_beam_position action=activate profile_id=1
    Execute Egate Command   cmd=ue_testmode_set_nr id=6 testmode=ue_ul_beam_position action=activate profile_id=2
    Execute Egate Command   cmd=ue_testmode_set_nr id=7 testmode=ue_ul_beam_position action=activate profile_id=3
    Execute Egate Command   cmd=ue_testmode_set_nr id=8 testmode=ue_ul_beam_position action=activate profile_id=4
    Execute Egate Command   cmd=ue_testmode_set_nr id=9 testmode=ue_ul_beam_position action=activate profile_id=1
    Execute Egate Command   cmd=ue_testmode_set_nr id=10 testmode=ue_ul_beam_position action=activate profile_id=2
    Execute Egate Command   cmd=ue_testmode_set_nr id=11 testmode=ue_ul_beam_position action=activate profile_id=3
    Execute Egate Command   cmd=ue_testmode_set_nr id=12 testmode=ue_ul_beam_position action=activate profile_id=4
    Execute Egate Command   cmd=ue_testmode_set_nr id=13 testmode=ue_ul_beam_position action=activate profile_id=1
    Execute Egate Command   cmd=ue_testmode_set_nr id=14 testmode=ue_ul_beam_position action=activate profile_id=2
    Execute Egate Command   cmd=ue_testmode_set_nr id=15 testmode=ue_ul_beam_position action=activate profile_id=3
    Execute Egate Command   cmd=ue_testmode_set_nr id=16 testmode=ue_ul_beam_position action=activate profile_id=4
    Execute Egate Command   cmd=ue_testmode_set_nr id=17 testmode=ue_ul_beam_position action=activate profile_id=1
    Execute Egate Command   cmd=ue_testmode_set_nr id=18 testmode=ue_ul_beam_position action=activate profile_id=2
    Execute Egate Command   cmd=ue_testmode_set_nr id=19 testmode=ue_ul_beam_position action=activate profile_id=3
    Execute Egate Command   cmd=ue_testmode_set_nr id=20 testmode=ue_ul_beam_position action=activate profile_id=4
    Execute Egate Command   cmd=ue_testmode_set_nr id=21 testmode=ue_ul_beam_position action=activate profile_id=1
    Execute Egate Command   cmd=ue_testmode_set_nr id=22 testmode=ue_ul_beam_position action=activate profile_id=2
    Execute Egate Command   cmd=ue_testmode_set_nr id=23 testmode=ue_ul_beam_position action=activate profile_id=3
    Execute Egate Command   cmd=ue_testmode_set_nr id=24 testmode=ue_ul_beam_position action=activate profile_id=4

Verify 4 UEs Pairing Counters Layer 8
    Wait For Next Full Pm Interval
    ${pm_counters_filepath}=    Get Latest Unpacked Raw Pm Counters File

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_4PAIR_UE}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-1}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_8LAYER}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-1}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_4PAIR_UE}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-2}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_8LAYER}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-2}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_4PAIR_UE}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-3}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_8LAYER}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-3}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_4PAIR_UE}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-4}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_8LAYER}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-4}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_4PAIR_UE}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-5}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_8LAYER}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-5}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_4PAIR_UE}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-6}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_8LAYER}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-6}
    ...    filepath=${pm_counters_filepath}

Verify 3 UEs Pairing Counters Layer 8 And 6
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counters_filepath}=    Get Latest Unpacked Raw Pm Counters File

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_4PAIR_UE}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-1}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_8LAYER}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-1}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_3PAIR_UE}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-1}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_6LAYER}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-1}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_4PAIR_UE}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-2}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_8LAYER}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-2}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_3PAIR_UE}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-2}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_6LAYER}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-2}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_4PAIR_UE}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-3}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_8LAYER}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-3}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_3PAIR_UE}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-3}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_6LAYER}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-3}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_4PAIR_UE}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-4}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_8LAYER}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-4}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_3PAIR_UE}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-4}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_6LAYER}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-4}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_4PAIR_UE}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-5}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_8LAYER}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-5}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_3PAIR_UE}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-5}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_6LAYER}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-5}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_4PAIR_UE}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-6}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_8LAYER}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-6}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_3PAIR_UE}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-6}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_6LAYER}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-6}
    ...    filepath=${pm_counters_filepath}

Verify 2 UEs Pairing Counters Layer 6 And 4
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counters_filepath}=    Get Latest Unpacked Raw Pm Counters File

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_3PAIR_UE}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-1}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_6LAYER}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-1}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_2PAIR_UE}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-1}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_4LAYER}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-1}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_3PAIR_UE}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-2}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_6LAYER}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-2}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_2PAIR_UE}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-2}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_4LAYER}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-2}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_3PAIR_UE}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-3}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_6LAYER}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-3}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_2PAIR_UE}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-3}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_4LAYER}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-3}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_3PAIR_UE}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-4}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_6LAYER}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-4}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_2PAIR_UE}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-4}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_4LAYER}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-4}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_3PAIR_UE}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-5}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_6LAYER}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-5}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_2PAIR_UE}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-5}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_4LAYER}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-5}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_3PAIR_UE}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-6}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_6LAYER}
    ...    value=0
    ...    local_moid=${LOCAL_MOID-6}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_2PAIR_UE}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-6}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_4LAYER}
    ...    value=10
    ...    local_moid=${LOCAL_MOID-6}
    ...    filepath=${pm_counters_filepath}
