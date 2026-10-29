*** Settings ***
Documentation    :copyright: Nokia
...              :author: Marcin Kotula
...              :contact: marcin.kotula@nokia.com

Resource    ../CB007813/connect.robot


*** Variables ***
${iphy_CB008701}               ${CURDIR}/config/iphy_1xAVHA.xml
${scf_CB008701}                ${CURDIR}/config/SBTS00/full_CB008701.xml
${cfg_CB008701}                ${CURDIR}/config/basic_setup_mumimo.cfg
@{SWCONFIG_FLAGS}              0x8000A6=0
${LOCAL_MOID_CELL-1}           PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${PRB_DL_MU_MIMO_4PAIR_UE}     M55308C34015
${PRB_DL_MU_MIMO_3PAIR_UE}     M55308C34014
${PRB_DL_MU_MIMO_2PAIR_UE}     M55308C34013
${PRB_DL_MU_MIMO_8LAYER}       M55308C34011
${PRB_DL_MU_MIMO_6LAYER}       M55308C34009
${PRB_DL_MU_MIMO_4LAYER}       M55308C34007


*** Keywords ***
CB008701-A_15_Verify_PMCounter_For_MUMIMO
    Set Beams 4 UEs
    Attach UEs    num_ue=4
    Start Dl and UL Data Traffic For All UEs    num_ue=4
    Verify 4 UEs Pairing Counters
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuMaxNumLayerPerMuRbg    value=6
    Verify 3 UEs Pairing Counters
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuMaxNumLayerPerMuRbg    value=4
    Verify 2 UEs Pairing Counters


Set Beams 4 UEs
    Execute Egate Command   cmd=ul_ue_beam_pos_nr profile_id=1 num_beam_paths=4 azimuth=14,43,-14,-43 zenith=12,2,12,2 power=-250,-250,-250,-250
    Execute Egate Command   cmd=ul_ue_beam_pos_nr profile_id=2 num_beam_paths=4 azimuth=-3,22,-14,18 zenith=-9,-9,-7,-7 power=-250,-250,-250,-250
    Execute Egate Command   cmd=ul_ue_beam_pos_nr profile_id=3 num_beam_paths=4 azimuth=22,22,37,37 zenith=-4,-4,-4,-4 power=-250,-250,-250,-250
    Execute Egate Command   cmd=ul_ue_beam_pos_nr profile_id=4 num_beam_paths=4 azimuth=21,37,50,10 zenith=7,7,7,7 power=-250,-250,-250,-250
    Execute Egate Command   cmd=ue_testmode_set_nr id=1 testmode=ue_ul_beam_position action=activate profile_id=1
    Execute Egate Command   cmd=ue_testmode_set_nr id=2 testmode=ue_ul_beam_position action=activate profile_id=2
    Execute Egate Command   cmd=ue_testmode_set_nr id=3 testmode=ue_ul_beam_position action=activate profile_id=3
    Execute Egate Command   cmd=ue_testmode_set_nr id=4 testmode=ue_ul_beam_position action=activate profile_id=4

Verify 4 UEs Pairing Counters
    Wait For Next Full Pm Interval
    ${pm_counters_filepath}=    Get Latest Unpacked Raw Pm Counters File

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_4PAIR_UE}
    ...    value=100
    ...    local_moid=${LOCAL_MOID_CELL-1}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_8LAYER}
    ...    value=100
    ...    local_moid=${LOCAL_MOID_CELL-1}
    ...    filepath=${pm_counters_filepath}

Verify 3 UEs Pairing Counters
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counters_filepath}=    Get Latest Unpacked Raw Pm Counters File

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_4PAIR_UE}
    ...    value=0
    ...    local_moid=${LOCAL_MOID_CELL-1}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_8LAYER}
    ...    value=0
    ...    local_moid=${LOCAL_MOID_CELL-1}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_3PAIR_UE}
    ...    value=100
    ...    local_moid=${LOCAL_MOID_CELL-1}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_6LAYER}
    ...    value=100
    ...    local_moid=${LOCAL_MOID_CELL-1}
    ...    filepath=${pm_counters_filepath}

Verify 2 UEs Pairing Counters
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counters_filepath}=    Get Latest Unpacked Raw Pm Counters File

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_3PAIR_UE}
    ...    value=0
    ...    local_moid=${LOCAL_MOID_CELL-1}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${PRB_DL_MU_MIMO_6LAYER}
    ...    value=0
    ...    local_moid=${LOCAL_MOID_CELL-1}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_2PAIR_UE}
    ...    value=100
    ...    local_moid=${LOCAL_MOID_CELL-1}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_4LAYER}
    ...    value=100
    ...    local_moid=${LOCAL_MOID_CELL-1}
    ...    filepath=${pm_counters_filepath}
