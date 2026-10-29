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
CB014045-A_B3_One_cell_one_UE_TDD_FR1_CP-OFDM_MCS_256QAM_Table_without_MPR_aware_UL_LA
    Set Preferred Cell     ${PCELL_301}
    Set Attach Cell DN   MRBTS-55269/NRBTS-55269/NRCELL-301
    Initialise Attenuator
    Disable UlDftSOfdm    nrcell_id=301

    ${ul_avg_poor_off}  ${dl_avg_poor_off}  ${ul_avg_poor_off_tti}
    ...    Start Tput Test    ${TEST_UE}    ${POOR_CONDITION}  alias=poor    feature=off
    ${POOR_RSRP}    Set Variable    ${${TEST_UE}_RSRP}

    ${ul_avg_middle_off}  ${dl_avg_middle_off}    ${ul_avg_middle_off_tti}
    ...    Start Tput Test    ${TEST_UE}    ${MIDDLE_CONDITION}  alias=middle    feature=off
    ${MIDDLE_RSRP}    Set Variable    ${${TEST_UE}_RSRP}

    ${ul_avg_good_off}  ${dl_avg_good_off}    ${ul_avg_good_off_tti}
    ...    Start Tput Test    ${TEST_UE}    ${GOOD_CONDITION}  alias=good    feature=off
    ${GOOD_RSRP}    Set Variable    ${${TEST_UE}_RSRP}

    Activate La Enhancements Feature    cell_id=${PCELL_301}    value=UL
    BuiltIn.Sleep    20
    AdminUtils.Wait For All Cells On Air State

    ${ul_avg_poor_on}  ${dl_avg_poor_on}  ${ul_avg_poor_on_tti}
    ...    Start Tput Test    ${TEST_UE}    ${POOR_CONDITION}  alias=poor    feature=on
    ${ul_avg_middle_on}  ${dl_avg_middle_on}  ${ul_avg_middle_on_tti}
    ...    Start Tput Test    ${TEST_UE}    ${MIDDLE_CONDITION}  alias=middle    feature=on
    ${ul_avg_good_on}  ${dl_avg_good_on}  ${ul_avg_good_on_tti}
    ...    Start Tput Test    ${TEST_UE}    ${GOOD_CONDITION}    alias=good    feature=on

    Log To Console    FEATURE_OFF vs FEATURE_ON
    Log To Console    -= POOR CONDITION =-
    Log To Console    RSRP: ${POOR_RSRP}
    Log To Console    UL (NAA): ${ul_avg_poor_off} vs ${ul_avg_poor_on}
    Log To Console    DL (NAA): ${dl_avg_poor_off} vs ${dl_avg_poor_on}
    Log To Console    UL (TTI): ${ul_avg_poor_off_tti} vs ${ul_avg_poor_on_tti}
    Run Keyword And Continue On Failure    Should Be True    ${ul_avg_poor_off} < ${ul_avg_poor_on}
    Run Keyword And Continue On Failure    Should Be True    ${ul_avg_poor_off_tti} <= ${ul_avg_poor_on_tti}
#    Run Keyword And Continue On Failure    Should Be True    ${dl_avg_poor_off} <= ${dl_avg_poor_on}

    Log To Console    -= MIDDLE CONDITION =-
    Log To Console    RSRP: ${MIDDLE_RSRP}
    Log To Console    UL (NAA): ${ul_avg_middle_off} vs ${ul_avg_middle_on}
    Log To Console    DL (NAA): ${dl_avg_middle_off} vs ${dl_avg_middle_on}
    Log To Console    UL (TTI): ${ul_avg_middle_off_tti} vs ${ul_avg_middle_on_tti}
    Run Keyword And Continue On Failure    Should Be True    ${ul_avg_middle_off} < ${ul_avg_middle_on}
    Run Keyword And Continue On Failure    Should Be True    ${ul_avg_middle_off_tti} <= ${ul_avg_middle_on_tti}
#    Run Keyword And Continue On Failure    Should Be True    ${dl_avg_middle_off} <= ${dl_avg_middle_on}

    Log To Console    -= GOOD CONDITION =-
    Log To Console    RSRP: ${GOOD_RSRP}
    Log To Console    UL (NAA): ${ul_avg_good_off} vs ${ul_avg_good_on}
    Log To Console    DL (NAA): ${dl_avg_good_off} vs ${dl_avg_good_on}
    Log To Console    UL (TTI): ${ul_avg_good_off_tti} vs ${ul_avg_good_on_tti}

    Run Keyword And Continue On Failure    Should Be True    ${ul_avg_good_off} < ${ul_avg_good_on}
    Run Keyword And Continue On Failure    Should Be True    ${ul_avg_good_off_tti} <= ${ul_avg_good_on_tti}
#    Run Keyword And Continue On Failure    Should Be True    ${dl_avg_good_off} <= ${dl_avg_good_on}

    [Teardown]    Run Keywords
    ...  Detach Ue  ${TEST_UE}  AND
    ...  Enable UlDftSOfdm    nrcell_id=301    AND
    ...  Deactivate La Enhancements feature    cell_id=${PCELL_301}

CB014045_B_B2_online_modification_flag_UL_for_new_users
    Set Preferred Cell     ${PCELL_301}
    Set Attach Cell DN   MRBTS-55269/NRBTS-55269/NRCELL-301
    Initialise Attenuator
    Set Ports Attenuation    ${AEHC_1_PORTS}    ${MIDDLE_CONDITION}    ${tl.attenuators}
    Enable Optpuschprballoc    nrcell_id=301

    counters.Wait For Pm Counters Interval
    ${UE_1_pcap}    Attach UE To Pcell And Scell    UE_1    num_of_scells=0    alias=UE_1
    ${UE_1_RNTI}    Get Ue Rnti    ${UE_1_pcap}
    Show Text on Console    UE_1 RNTI: ${UE_1_RNTI}   colour=${GREEN}  show_timestamp=no
    Start UL Traffic For Ue    UE_1    ul_tput=120Mbits/sec    duration=100s    protocol=tcp
    BuiltIn.Sleep    20
    Start TTI Trace   ${tl.test_pc}   ${tl.gnbs[0]}    TTI_feature_off
    BuiltIn.Sleep    20
    Stop TTI Trace   ${OUTPUT_DIR}    TTI_feature_off
    Await Data Transfer Finish    DT_UE_1_defaultul

    ${decoded_tti_before}    Convert Pcap Tti To Json    ${OUTPUT_DIR}/TTI_feature_off/tcpdump_tti/tcpdump_tti.pcap
    ...    ${OUTPUT_DIR}/TTI_feature_off/tcpdump_tti/decoded
    ${ue1_avg_tput_ul_before}   Get Average Tput    DT_UE_1_defaultul    omit=40    end=60
    ${ue1_avg_tti_tput_ul_before}    Calculate TTI Tput    ${UE_1_RNTI}    ${decoded_tti_before}

    Show Text on Console    UE_1 UL: ${ue1_avg_tput_ul_before}    colour=${GREEN}  show_timestamp=no
    Show Text on Console    UE_1 UL TTI: ${ue1_avg_tti_tput_ul_before}    colour=${GREEN}  show_timestamp=no
    Detach Ue    UE_1

    Run Keyword And Continue On Failure    get_counter_value_for_cell    M55363C00004    cell_id=301    wait_for_interval=${TRUE}
    ...    additional_key=NRPMQAP-5
    Run Keyword And Continue On Failure    get_counter_value_for_cell    M55308C36002    cell_id=301    wait_for_interval=${FALSE}
    Activate La Enhancements Feature    cell_id=${PCELL_301}    value=DL_UL
    AdminUtils.Wait For All Cells On Air State

    counters.Wait For Pm Counters Interval
    ${UE_1_pcap}    Attach UE To Pcell And Scell    UE_1    num_of_scells=0    alias=UE_1
    ${UE_1_RNTI}    Get Ue Rnti    ${UE_1_pcap}
    Show Text on Console    UE_1 RNTI: ${UE_1_RNTI}    colour=${GREEN}  show_timestamp=no
    Start UL Traffic For Ue    UE_1    ul_tput=120Mbits/sec    duration=100s    protocol=tcp
    BuiltIn.Sleep    20
    Start TTI Trace   ${tl.test_pc}   ${tl.gnbs[0]}    TTI_feature_on_dl_ul
    BuiltIn.Sleep    20
    Stop TTI Trace   ${OUTPUT_DIR}    TTI_feature_on_dl_ul
    Await Data Transfer Finish  DT_UE_1_defaultul
    ${decoded_tti_after_dl_ul}     Convert Pcap Tti To Json   ${OUTPUT_DIR}/TTI_feature_on_dl_ul/tcpdump_tti/tcpdump_tti.pcap
    ...    ${OUTPUT_DIR}/TTI_feature_on_dl_ul/tcpdump_tti/decoded

    ${ue1_avg_tput_ul_after_dl_ul}   Get Average Tput    DT_UE_1_defaultul    omit=40    end=60
    ${ue1_avg_tti_tput_ul_after_dl_ul}    calculate_tti_tput    ${UE_1_RNTI}    ${decoded_tti_after_dl_ul}

    Show Text on Console    UE_1 UL: ${ue1_avg_tput_ul_after_dl_ul}    colour=${GREEN}  show_timestamp=no
    Show Text on Console    UE_1 UL TTI: ${ue1_avg_tti_tput_ul_after_dl_ul}    colour=${GREEN}  show_timestamp=no

    Detach Ue    UE_1
    Run Keyword And Continue On Failure    get_counter_value_for_cell    M55363C00004    cell_id=301    wait_for_interval=${TRUE}
    ...    additional_key=NRPMQAP-5
    Run Keyword And Continue On Failure    get_counter_value_for_cell    M55308C36002    cell_id=301    wait_for_interval=${FALSE}

    Activate La Enhancements Feature    cell_id=${PCELL_301}    value=UL
    AdminUtils.Wait For All Cells On Air State

    counters.Wait For Pm Counters Interval
    ${UE_1_pcap}    Attach UE To Pcell And Scell    UE_1    num_of_scells=0    alias=UE_1
    ${UE_1_RNTI}    Get Ue Rnti    ${UE_1_pcap}
    Show Text on Console    UE_1 RNTI: ${UE_1_RNTI}    colour=${GREEN}  show_timestamp=no
    Start UL Traffic For Ue    UE_1    ul_tput=120Mbits/sec    duration=100s    protocol=tcp
    BuiltIn.Sleep    20
    Start TTI Trace   ${tl.test_pc}   ${tl.gnbs[0]}    TTI_feature_on_ul
    BuiltIn.Sleep    20
    Stop TTI Trace   ${OUTPUT_DIR}    TTI_feature_on_ul
    Await Data Transfer Finish  DT_UE_1_defaultul
    ${decoded_tti_after_ul}     Convert Pcap Tti To Json   ${OUTPUT_DIR}/TTI_feature_on_ul/tcpdump_tti/tcpdump_tti.pcap
    ...    ${OUTPUT_DIR}/TTI_feature_on_ul/tcpdump_tti/decoded

    ${ue1_avg_tput_ul_after_ul}   Get Average Tput    DT_UE_1_defaultul    omit=40    end=60
    ${ue1_avg_tti_tput_ul_after_ul}    calculate_tti_tput    ${UE_1_RNTI}    ${decoded_tti_after_ul}
    Show Text on Console    UE_1 UL: ${ue1_avg_tput_ul_after_ul}    colour=${GREEN}  show_timestamp=no
    Show Text on Console    UE_1 UL TTI: ${ue1_avg_tti_tput_ul_after_ul}    colour=${GREEN}  show_timestamp=no
    Detach Ue    UE_1
    Run Keyword And Continue On Failure    get_counter_value_for_cell    M55363C00004    cell_id=301    wait_for_interval=${TRUE}
    ...    additional_key=NRPMQAP-5
    Run Keyword And Continue On Failure    get_counter_value_for_cell    M55308C36002    cell_id=301    wait_for_interval=${FALSE}

    Log To Console    FEATURE_OFF vs FEATURE_ON
    Log To Console    MODE: DL_UL
    Log To Console    UE(UE_1) UL: ${ue1_avg_tput_ul_before} vs ${ue1_avg_tput_ul_after_dl_ul}
    Log To Console    UE(UE_1) UL (TTI): ${ue1_avg_tti_tput_ul_before} vs ${ue1_avg_tti_tput_ul_after_dl_ul}
    Run Keyword And Continue On Failure    Should Be True    ${ue1_avg_tput_ul_before} < ${ue1_avg_tput_ul_after_dl_ul}
    Run Keyword And Continue On Failure    Should Be True    ${ue1_avg_tti_tput_ul_before} < ${ue1_avg_tti_tput_ul_after_dl_ul}

    Log To Console    MODE: UL
    Log To Console    UE(UE_1) UL: ${ue1_avg_tput_ul_before} vs ${ue1_avg_tput_ul_after_ul}
    Log To Console    UE(UE_1) UL (TTI): ${ue1_avg_tti_tput_ul_before} vs ${ue1_avg_tti_tput_ul_after_ul}
    Run Keyword And Continue On Failure    Should Be True    ${ue1_avg_tput_ul_before} < ${ue1_avg_tput_ul_after_ul}
    Run Keyword And Continue On Failure    Should Be True    ${ue1_avg_tti_tput_ul_before} < ${ue1_avg_tti_tput_ul_after_ul}


    [Teardown]    Run Keywords
    ...    Detach Ue    UE_1    AND
    ...    Disable Optpuschprballoc    nrcell_id=301    AND
    ...    Deactivate La Enhancements feature    cell_id=${PCELL_301}

*** Keywords ***
Start Tput Test
    [Arguments]    ${ue}    ${condition}    ${alias}    ${feature}=off    ${iteration}=${NUM_OF_RETRY}
    ...    ${duration}=60
    set_ports_attenuation    ${AEHC_1_PORTS}    ${condition}    ${tl.attenuators}
    Show Text on Console    Attaching ${ue} to CELL ${PCELL_301}    colour=${GREEN}  show_timestamp=no
    @{tputs_ul}    Create List
    @{tputs_dl}    Create List
    @{tputs_ul_tti}    Create List
    Show Text on Console    FEATURE_${feature}    colour=${GREEN}  show_timestamp=no
    FOR    ${i}    IN RANGE    1    ${iteration}+${1}
        Log To Console    ATTEMPT: ${i}
        ${ue_pcap}    Attach UE To Pcell And Scell    ${ue}    num_of_scells=0    alias=UE_1_${i}
        ${UE_RNTI}    Get Ue Rnti    ${ue_pcap}
        Start DL Traffic For Ue    ${ue}    dl_tput=1000Mbits/sec    duration=${duration}s    protocol=udp
        Start UL Traffic For Ue    ${ue}    ul_tput=120Mbits/sec    duration=${duration}s    protocol=udp
        Start TTI Trace   ${tl.test_pc}   ${tl.gnbs[0]}    TTI_feature_${feature}_${alias}_${iteration}
        BuiltIn.Sleep    20
        Stop TTI Trace   ${OUTPUT_DIR}    TTI_feature_${feature}_${alias}_${iteration}
        Await Data Transfer Finish  DT_${ue}_default
        Await Data Transfer Finish  DT_${ue}_defaultul
        ${avg_tput_ul}    Get Average Tput    DT_${ue}_defaultul    omit=20    end=40
        ${avg_tput_dl}    Get Average Tput    DT_${ue}_default       omit=20    end=40
        ${decoded_tti}     Convert Pcap Tti To Json   ${OUTPUT_DIR}/TTI_feature_${feature}_${alias}_${iteration}/tcpdump_tti/tcpdump_tti.pcap
        ...    ${OUTPUT_DIR}/TTI_feature_${feature}_${alias}_${iteration}/tcpdump_tti/decoded

        Show Text on Console    UL: ${avg_tput_ul}    colour=${GREEN}  show_timestamp=no
        Show Text on Console    DL: ${avg_tput_dl}    colour=${GREEN}  show_timestamp=no
        ${avg_tti_tput_ul}    calculate_tti_tput    ${UE_RNTI}    ${decoded_tti}

        Detach Ue    ${ue}
        Append To List    ${tputs_ul}    ${avg_tput_ul}
        Append To List    ${tputs_dl}    ${avg_tput_dl}
        Append To List    ${tputs_ul_tti}    ${avg_tti_tput_ul}

        ${average_ul}=    calculate_average_tput    ${tputs_ul}
        ${average_dl}=    calculate_average_tput    ${tputs_dl}
        ${averate_ul_tti}=    calculate_average_tput    ${tputs_ul_tti}
    END
    Show Text on Console    AVG UL: ${average_ul}    colour=${GREEN}  show_timestamp=no
    Show Text on Console    AVG DL: ${average_dl}    colour=${GREEN}  show_timestamp=no
    Show Text on Console    AVG UL (TTI): ${avg_tti_tput_ul}    colour=${GREEN}  show_timestamp=no
    [Return]    ${average_ul}  ${average_dl}   ${avg_tti_tput_ul}
    [Teardown]    Wait Until Keyword Succeeds  2x  5s    Detach Ue    ${ue}

Get Average Tput
    [Arguments]    ${dt_name}    ${omit}=0    ${end}=0
    ${avg_tput}    Get Average Throughput    ${dt_name}    omit=${omit}    end=${end}
    ${avg_tput}   Evaluate   ${avg_tput} / 1000
    ${avg_tput}   Evaluate   "%.2f" % ${avg_tput}
    [Return]    ${avg_tput}
