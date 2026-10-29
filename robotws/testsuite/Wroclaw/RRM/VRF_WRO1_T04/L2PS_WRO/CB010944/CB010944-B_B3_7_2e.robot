*** Settings ***
Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_MP_AP_LO
...    release: 25R3

Resource    CB010944_keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    ../resources/common_keywords.robot

Library     CB010944_keywords.py
Library     ../resources/Python/webem_alarms.py
Library     ute_admin_infomodel
Library     taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library     taf.collectors.l2stream3     WITH NAME  tcl
Library     taf.converters.eventdecoder  WITH NAME  tce
Library     taf.collectors.core    WITH NAME    core


*** Variables ***
${iphy_CB010944}               ${CURDIR}/config/10708C_iphy_TDD_eCPRI_7_2e.xml
${scf_CB010944}                ${CURDIR}/config/SBTS00/7_2_e.xml
${cfg_CB010944}                ${CURDIR}/config/basic_setup_7_2e.cfg
@{L2PS_BIP_SIZE}               0x3F007C=50     0x8000A6=0
${PROFILE_UE1}                 ul_ue_beam_pos_nr profile_id=1 num_beam_paths=2 azimuth=-70,-70 zenith=0,0 power=-300,-300
${PROFILE_UE2}                 ul_ue_beam_pos_nr profile_id=2 num_beam_paths=2 azimuth=-70,-70 zenith=0,0 power=-300,-300

${SET_PROFILE_UE1}             ue_testmode_set_nr id=1 testmode=ue_ul_beam_position profile_id=1 action=activate
${SET_PROFILE_UE2}             ue_testmode_set_nr id=2 testmode=ue_ul_beam_position profile_id=2 action=activate

${LOCAL_MOID_CELL-1}           PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${DL_SLOTS_ARTIFICIAL_LOAD}    M55308C00044

${tshark_filter}               (nr_l1dl_l2ps_dldata_pdschsendreql1sw_t) && (DlData_PdschGrantL1sw.patternId_item) && (DlData_PdschGrantL1sw.numOfPrb)

*** Keywords ***
CB010944_B_B3_Load_generation_IWK_with_CB008247_SRS_based_DL_BF
    Verify Target Beam Candidates
    Check Selected Beam Candidates    NRBEAM_EMF-1
    Set Internal Traffic Type To MUE
    Set Ue Position
    Attach SA UE And Verify msg2TPC     ue_id=1      msg2TPC_value=3
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Attach SA UE And Verify msg2TPC     ue_id=4      msg2TPC_value=3
    Establish Pdu Session    ue_id=4    pdu_id=4    gw_id=1
    Airphone override to rank2
    Start and Verify Tput
    Check Dl Slots Artificial Load Counter
    Collect TTI Traces And Check DL MU-MIMO And DL SRS-based BF   duration=2   directory_name=CB010944-B B3  ini_path=tti_dl_features_enabled.ini
    Start Gathering BIP Logs And Wait 5s
    Stop gnbMirroring And Gather L1L2 Bip Logs
    Verify Max PRB for TargetLoad
    Deactive Emf Test Mode
    Verify Target Beam Candidates Not Exist


Check Dl Slots Artificial Load Counter
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Raw Pm Counters File

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${DL_SLOTS_ARTIFICIAL_LOAD}
    ...    value=150000
    ...    local_moid=${LOCAL_MOID_CELL-1}
    ...    filepath=${PM_COUNTERS_FILE}

Set Ue Position
      Execute Egate Command    cmd=${PROFILE_UE1}
      Execute Egate Command    cmd=${PROFILE_UE2}
      Sleep    1s
      Execute Egate Command    cmd=${SET_PROFILE_UE1}
      Execute Egate Command    cmd=${SET_PROFILE_UE2}

Start and Verify Tput
    Start Double Data Traffic In DL And Single In UL   ue_id=1    pdu=1   tput_dl=150   tput_ul=50
    Start Double Data Traffic In DL And Single In UL   ue_id=4    pdu=4   tput_dl=150   tput_ul=10
    Verify Tput For UE    ue_id=1   dir=ul    expected_tput=25
    Verify Tput For UE    ue_id=1   dir=dl    expected_tput=270
    Verify Tput For UE    ue_id=4   dir=ul    expected_tput=9
    Verify Tput For UE    ue_id=4   dir=dl    expected_tput=270

Verify Max PRB for TargetLoad
    Convert pcap file to pdml    tshark_filters=${tshark_filter}
    verify_PRB_for_patternId    pdml_path=${OUTPUT_DIR}/BIP_log_1.pdml    patternId=1362
    ...    num_prb=273    bip_mesg=nr_l1dl_l2ps_dldata_pdschsendreql1sw_t

Print Tput
    Execute Egate Command And Wait For Data
    ...    cmd=ue_stats_nr id=1 type=pdsch scell=0-4
    Execute Egate Command And Wait For Data
    ...    cmd=ue_stats_nr id=4 type=pdsch scell=0-4
    Execute Egate Command And Wait For Data
    ...    cmd=ue_stats_nr id=1 type=pusch scell=0-4
    Execute Egate Command And Wait For Data
    ...    cmd=ue_stats_nr id=4 type=pusch scell=0-4

Set SRS Beam Config
    Execute Egate Command   cmd=ue_srs_beam_pos_nr profile_id=1 init_pos=0 srsMode=fixed
    Execute Egate Command   cmd=ue_testmode_set_nr id=1 testmode=ue_srs_beam_pos action=activate profile_id=1
    Execute Egate Command   cmd=ue_srs_beam_pos_nr profile_id=2 init_pos=2 srsMode=fixed
    Execute Egate Command   cmd=ue_testmode_set_nr id=4 testmode=ue_srs_beam_pos action=activate profile_id=2

Verify PowerRampingStep Configuration
    [Arguments]   ${filter}
    Verify Uu Messages    packet_filter=${filter}


Start Double Data Traffic In DL And Single In UL
    [Arguments]   ${ue_id}    ${pdu}    ${tput_ul}    ${tput_dl}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=dl mbps=${tput_dl} trf_id=1
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:${pdu} Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=dl mbps=${tput_dl} trf_id=2
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:${pdu} Qfi:1 TrfId:2
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul mbps=${tput_ul}
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:${ue_id} UpfId:1 Pdu:${pdu} Qfi:1 TrfId:1
    Sleep    60s

Generate RI
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=12 start_symbol_position=0 num_of_symbols=32 noise_power_values=${NOISE_POWER_FOR_RI}
    Sleep   5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=12 action=activate

Cancel RI
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=12 action=deactivate

Stop All Data Transfers And Detach UE SA
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=2 ue_deregister_type=switch_off
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=3 ue_deregister_type=switch_off
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=4 ue_deregister_type=switch_off

Verify Uu Messages
    [Documentation]  Verification of messages captured on UU interface (between GnB and UE, WTS eth4).
    ...              By default keyword validates exact one occurrence of message.
    [Arguments]     ${packet_filter}    ${alias}=${DEFAULT_UU_TSHARK_ALIAS}
    Sleep   5s
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${alias}   packet_filter=${packet_filter}    number_of_messages=1

Airphone override to rank2
    Execute Egate Command    cmd=csi_override_testmode_nr profile_id=1 cqi=15 ri=1
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=1
    Execute Egate Command    cmd=ue_testmode_set_nr id=4 testmode=csi_override action=activate profile_id=1

Check If UL SRS-based BF Is Enabled
    [Arguments]   ${file}=BIP_L1L2.pcap
    verify_if_SRS_is_enabled    pdml_path=${OUTPUT_DIR}/${file}

Check If UL SRS-based BF Is Disabled
    [Arguments]   ${file}=BIP_L1L2.pcap
    verify_if_SRS_is_disabled    pdml_path=${OUTPUT_DIR}/${file}
