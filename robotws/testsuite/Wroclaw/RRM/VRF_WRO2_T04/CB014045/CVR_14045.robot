*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Library    ute_ue
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords.robot
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB014045/resources/keywords_14045.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/TOL_TMO_DALLAS/resources/test_specific_keywords.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB014045/resources/tti_tput.py

*** Variables ***
${PCELL_301}    301
${NUM_OF_RETRY}    1

${POOR_CONDITION}      50
${MIDDLE_CONDITION}    30
${GOOD_CONDITION}      15
${TEST_UE}    UE_3

*** Keywords ***
CB014045_Interworking_with_UL_2cc_CA
    Set Attach Cell DN   MRBTS-55269/NRBTS-55269/NRCELL-1
    Initialise Attenuator
    Set Ports Attenuation    ${AEHC_1_PORTS}    ${MIDDLE_CONDITION}    ${tl.attenuators}
    ${ue3_pcap}    Attach UE To Pcell And Scell    UE_3    num_of_scells=1    alias=UE_3    scells_id=301
    ${ue5_pcap}    Attach UE To Pcell And Scell    UE_5    num_of_scells=1    alias=UE_5    scells_id=301
    Start DL Traffic For Ue    UE_3    dl_tput=1000Mbits/sec    duration=60s    protocol=tcp    wait=${FALSE}
    Start DL Traffic For Ue    UE_5    dl_tput=1000Mbits/sec    duration=60s    protocol=tcp    wait=${FALSE}

    Start UL Traffic For Ue    UE_3    ul_tput=300Mbits/sec    duration=60s    protocol=tcp    wait=${FALSE}
    Start UL Traffic For Ue    UE_5    ul_tput=300Mbits/sec    duration=60s    protocol=tcp    wait=${FALSE}
    BuiltIn.Sleep    60
    ${ue_3_avg_tput_dl}    Get Average Tput    DT_UE_3_default    omit=20
    ${ue_5_avg_tput_ul}    Get Average Tput    DT_UE_5_default    omit=20

    ${ue_3_avg_tput_ul}    Get Average Tput    DT_UE_3_defaultul    omit=20
    ${ue_5_avg_tput_ul}    Get Average Tput    DT_UE_5_defaultul    omit=20

    [Teardown]   Run Keywords
    ...    Stop Data Transfer    DT_UE_3_defaultul    AND
    ...    Stop Data Transfer    DT_UE_5_defaultul    AND
    ...   Detach Ue    UE_3    AND
    ...   Detach Ue    UE_5


CVR_CB014045_Interworking_with_Nominal_Bit_Rate
    Set Attach Cell DN   MRBTS-55269/NRBTS-55269/NRCELL-301
    Initialise Attenuator
    Set Ports Attenuation    ${AEHC_1_PORTS}    ${MIDDLE_CONDITION}    ${tl.attenuators}
    counters.Wait For Pm Counters Interval    offset=0
    ${ue3_pcap}    Attach UE To Pcell And Scell    UE_3    num_of_scells=0    alias=UE_3
    ${ue5_pcap}    Attach UE To Pcell And Scell    UE_5    num_of_scells=0    alias=UE_5
    Start UL Traffic For Ue    UE_3    ul_tput=120Mbits/sec    duration=700s    protocol=tcp    wait=${FALSE}
    Start UL Traffic For Ue    UE_5    ul_tput=120Mbits/sec    duration=700s    protocol=tcp    wait=${FALSE}
    BuiltIn.Sleep    20
    Start TTI Trace   ${tl.test_pc}   ${tl.gnbs[0]}    TTI_feature_off
    BuiltIn.Sleep    10
    Stop TTI Trace   ${OUTPUT_DIR}    TTI_feature_off
    sweep_attenuation_several_times    n_times=1    t_interval=1    attenuators=${tl.attenuators}
    ...    att_start=${MIDDLE_CONDITION}    att_end=50
    BuiltIn.Sleep    300
    ${PRB_PMQAP9_before}    Get Counter Value For Cell    M55363C00004    cell_id=301    wait_for_interval=${TRUE}
    ...    additional_key=NRPMQAP-9
    ${PRB_USED_before}    Get Counter Value For Cell    M55308C10002    wait_for_interval=${FALSE}

    ${PRB_MAX_PER_SLOT_before}    Get Counter Value For Cell    M55308C36002    cell_id=301    wait_for_interval=${FALSE}
    Stop Data Transfer    DT_UE_3_defaultul
    Stop Data Transfer    DT_UE_5_defaultul
    Detach Ue    UE_3
    Detach Ue    UE_5
    ${UE_3_RNTI}    Get Ue Rnti    ${ue3_pcap}
    Show Text on Console    UE_3 RNTI: ${UE_3_RNTI}    colour=${GREEN}  show_timestamp=no
    ${UE_5_RNTI}    Get Ue Rnti    ${ue5_pcap}
    Show Text on Console    UE_5 RNTI: ${UE_5_RNTI}    colour=${GREEN}  show_timestamp=no
    ${decoded_tti}    Convert Pcap Tti To Json    ${OUTPUT_DIR}/TTI_feature_off/tcpdump_tti/tcpdump_tti.pcap
    ...    ${OUTPUT_DIR}/TTI_feature_off/tcpdump_tti/decoded
    ${UE_3_TPUT}    Calculate TTI Tput    ${UE_3_RNTI}    ${decoded_tti}
    ${UE_5_TPUT}    Calculate TTI Tput    ${UE_5_RNTI}    ${decoded_tti}
    ${ue_3_avg_tput_ul}    Get Average Tput    DT_UE_3_defaultul    omit=20
    ${ue_5_avg_tput_ul}    Get Average Tput    DT_UE_5_defaultul    omit=20
    Show Text on Console    UE_3 UL: ${ue_3_avg_tput_ul}    colour=${GREEN}  show_timestamp=no
    Show Text on Console    UE_5 UL: ${ue_5_avg_tput_ul}    colour=${GREEN}  show_timestamp=no

    Activate La Enhancements Feature    cell_id=${PCELL_301}    value=UL
    counters.Wait For Pm Counters Interval    offset=0
    ${ue3_pcap}    Attach UE To Pcell And Scell    UE_3    num_of_scells=0    alias=UE_3
    ${ue5_pcap}    Attach UE To Pcell And Scell    UE_5    num_of_scells=0    alias=UE_5
    Start UL Traffic For Ue    UE_3    ul_tput=120Mbits/sec    duration=700s    protocol=tcp    wait=${FALSE}
    Start UL Traffic For Ue    UE_5    ul_tput=120Mbits/sec    duration=700s    protocol=tcp    wait=${FALSE}
    BuiltIn.Sleep    20
    Start TTI Trace   ${tl.test_pc}   ${tl.gnbs[0]}    TTI_feature_on
    BuiltIn.Sleep    10
    Stop TTI Trace   ${OUTPUT_DIR}    TTI_feature_on
    sweep_attenuation_several_times    n_times=1    t_interval=1    attenuators=${tl.attenuators}
    ...    att_start=${MIDDLE_CONDITION}    att_end=50
    BuiltIn.Sleep    300
    ${PRB_PMQAP9_after}    Get Counter Value For Cell    M55363C00004    cell_id=301    wait_for_interval=${TRUE}
    ...    additional_key=NRPMQAP-9
    ${PRB_USED_after}    Get Counter Value For Cell    M55308C10002    wait_for_interval=${FALSE}
    ${PRB_MAX_PER_SLOT_after}    Get Counter Value For Cell    M55308C36002    cell_id=301    wait_for_interval=${FALSE}
    ${UE_3_RNTI}    Get Ue Rnti    ${ue3_pcap}
    Show Text on Console    UE_3 RNTI: ${UE_3_RNTI}    colour=${GREEN}  show_timestamp=no
    ${UE_5_RNTI}    Get Ue Rnti    ${ue5_pcap}
    Show Text on Console    UE_5 RNTI: ${UE_5_RNTI}    colour=${GREEN}  show_timestamp=no
    ${decoded_tti}    Convert Pcap Tti To Json    ${OUTPUT_DIR}/TTI_feature_on/tcpdump_tti/tcpdump_tti.pcap
    ...    ${OUTPUT_DIR}/TTI_feature_on/tcpdump_tti/decoded
    ${UE_3_TPUT}    Calculate TTI Tput    ${UE_3_RNTI}    ${decoded_tti}
    ${UE_5_TPUT}    Calculate TTI Tput    ${UE_5_RNTI}    ${decoded_tti}
    ${ue_3_avg_tput_ul}    Get Average Tput    DT_UE_3_defaultul    omit=20
    ${ue_5_avg_tput_ul}    Get Average Tput    DT_UE_5_defaultul    omit=20
    Show Text on Console    UE_3 UL: ${ue_3_avg_tput_ul}    colour=${GREEN}  show_timestamp=no
    Show Text on Console    UE_5 UL: ${ue_5_avg_tput_ul}    colour=${GREEN}  show_timestamp=no

    Show Text on Console    Counter M55363C00004 before: ${PRB_PMQAP9_before}    colour=${GREEN}  show_timestamp=no
    Show Text on Console    Counter M55363C00004 after: ${PRB_PMQAP9_after}   colour=${GREEN}  show_timestamp=no
    Show Text on Console    Counter M55308C36002 before: ${PRB_MAX_PER_SLOT_before}    colour=${GREEN}  show_timestamp=no
    Show Text on Console    Counter M55308C36002 after: ${PRB_MAX_PER_SLOT_after}   colour=${GREEN}  show_timestamp=no
    Show Text on Console    Counter M55308C10002 before: ${PRB_USED_before}   colour=${GREEN}  show_timestamp=no
    Show Text on Console    Counter M55308C10002 after: ${PRB_USED_after}   colour=${GREEN}  show_timestamp=no

    [Teardown]    Run Keywords
    ...    Stop Data Transfer    DT_UE_3_defaultul    AND
    ...    Stop Data Transfer    DT_UE_5_defaultul    AND
    ...    Detach Ue    UE_3    AND
    ...    Detach Ue    UE_5    AND
    ...    Deactivate La Enhancements feature    cell_id=${PCELL_301}

CB014045_Interworking_with_UL_Service_Aware_Scheduler
    Set Attach Cell DN   MRBTS-55269/NRBTS-55269/NRCELL-301
    Initialise Attenuator
    Activate La Enhancements Feature    cell_id=${PCELL_301}    value=UL
    counters.Wait For Pm Counters Interval    offset=0
    Set Ports Attenuation    ${AEHC_1_PORTS}    ${MIDDLE_CONDITION}    ${tl.attenuators}
    ${ue3_pcap}    Attach UE To Pcell And Scell    UE_3    num_of_scells=0    alias=UE_3
    ${ue4_pcap}    Attach UE To Pcell And Scell    UE_4    num_of_scells=0    alias=UE_4
    Show Text on Console    Attaching UE to Default slice    colour=${GREEN}  show_timestamp=no
    Start UL Traffic For Ue    UE_3    ul_tput=120Mbits/sec    duration=700s    protocol=tcp    wait=${FALSE}
    Show Text on Console    Attaching UE to TMO-1000 slice    colour=${GREEN}  show_timestamp=no
    Start UL Traffic For Ue    UE_4    ul_tput=120Mbits/sec    duration=700s    protocol=tcp    wait=${FALSE}
    BuiltIn.Sleep    20
    Start TTI Trace   ${tl.test_pc}   ${tl.gnbs[0]}    TTI_feature_on
    BuiltIn.Sleep    10
    Stop TTI Trace   ${OUTPUT_DIR}    TTI_feature_on
    sweep_attenuation_several_times    n_times=4    t_interval=1    attenuators=${tl.attenuators}
    ...    att_start=${MIDDLE_CONDITION}    att_end=50

    ${PRB_RG_1_VALUE}    Get Counter Value For Cell    M55910C00003    cell_id=301    wait_for_interval=${TRUE}
    ...    additional_key=NRRESOURCEGROUP-1
    ${PRB_RG_2_VALUE}    Get Counter Value For Cell    M55910C00003    cell_id=301    wait_for_interval=${FALSE}
    ...    additional_key=NRRESOURCEGROUP-2

    ${decoded_tti}    Convert Pcap Tti To Json    ${OUTPUT_DIR}/TTI_feature_on/tcpdump_tti/tcpdump_tti.pcap
    ...    ${OUTPUT_DIR}/TTI_feature_on/tcpdump_tti/decoded

    ${UE_3_RNTI}    Get Ue Rnti    ${ue3_pcap}
    Show Text on Console    UE_3 RNTI: ${UE_3_RNTI}    colour=${GREEN}  show_timestamp=no
    ${UE_4_RNTI}    Get Ue Rnti    ${ue4_pcap}
    Show Text on Console    UE_4 RNTI: ${UE_4_RNTI}    colour=${GREEN}  show_timestamp=no
    ${UE_3_TPUT}    Calculate TTI Tput    ${UE_3_RNTI}    ${decoded_tti}
    ${UE_4_TPUT}    Calculate TTI Tput    ${UE_4_RNTI}    ${decoded_tti}
    ${rg1_percentage}    Evaluate    ${PRB_RG_1_VALUE}/(${PRB_RG_1_VALUE}+${PRB_RG_2_VALUE})*100
    Log To Console    RG1 percentage: ${rg1_percentage}
    [Teardown]    Run Keywords
    ...    Detach Ue    UE_3    AND
    ...    Detach Ue    UE_4    AND
    ...    Deactivate La Enhancements feature    cell_id=${PCELL_301}
