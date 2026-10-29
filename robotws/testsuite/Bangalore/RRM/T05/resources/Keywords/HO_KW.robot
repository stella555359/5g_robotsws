*** Settings ***
Library         String
Library         Collections
Library         taf.sw.wtssim
Library         OperatingSystem
Library         ../PythonLib/getEventId.py

Documentation   kw related to HO
*** Variables ***
${eNB_ID}       1
${ransim_gnbID}     3
${Measurement_id}   NR MEASUREMENT IDENTITIES
${Xn_HO_Pattern_Check}   PATH_SWITCH_REQUEST_ACK Received
${NG_HO_Pattern_Check}    OnReceiveHandoverNotify
${IRAT_HO_Pattern_Check}    IRAT Handover from NR to EUTRA completed
${NSA_HO_IAFR_Pattern_Check}    Sending SgNB Modification Confirm
${NSA_HO_IEFR_A3_Check}     rrcConnectionReconfigurationComplete
${X2_link_pattern_RANSIM}   X2AP Link with GNB-3
${Xn_cancel}   UE CONTEXT RELEASE COMPLETE
${ho_fail}  Unexpected timeout in UE CONTEXT RELEASE
${UE_meas_id_pattern}               DETAILED INFO ABOUT NR REPORT CONFIGURATIONS

*** Keywords ***
Setup Xn link to simulated gNB
    [Documentation]     This KW is to bring up Xn interface between real and simulated gNB of RANSIM
    wtsrunner.gnb_xn_link_up       gnb=${ransim_gnbID}     target=2
    Sleep   30s
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=XnAP Link with GNB-2*      timeout=10
    Log to Console    ${output} XnAP successfully established

Setup X2 with RANSIM GNB
    [Documentation]    This keyword is used to Create a X2 connection with Simulated RANSIM gNB
    ...                And checks if the X2AP link with the gNB is UP in the output file.
    wtsrunner.enb_x2_link_up    enb=${eNB_ID}    target=${ransim_gnbID}
    Read WTS Output For Pattern And Print matching Lines    ${X2_link_pattern_RANSIM}    ${Timeout_NSA}
    Log    x2_is_ok


Get Configured Measurements of UE
    [Arguments]     ${ue_id}
    BuiltIn.Log    Get configured Measurements...    console=${True}
    wtsrunner.ue_meas_cfg_disp    id=${ue_id}    meas_obj_type=nr
    ${output}   Read WTS Output Until Pattern Matches     ${Measurement_id}:   timeout=20
    ${output}         Get Lines Matching Regexp    ${output}    UE${ue_id} NR MEASUREMENT IDENTITIES:   partial_match=${TRUE}
    Print Matching Lines from Output File       ${output}   ${Measurement_id}

Trigger A3 Measurement
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=60    nrsrq_nr=60
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}

Trigger A3 Measurement for NSA
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=60    nrsrq_nr=60
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=${NSA_HO_IAFR_Pattern_Check}   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    SgNB Modification Confirm   partial_match=${TRUE}
    Log to Console    ${output}

Trigger A3 Measurement for NSA HO from Real to RANSIM
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=60    nrsrq_nr=60
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=${NSA_HO_IEFR_A3_Check}   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcreconfiguration   partial_match=${TRUE}
    Log to Console    ${output}

Trigger HO from Real to Sim with A3
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=60    nrsrq_nr=60
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=${Xn_HOPattern_Check}   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    HO successful   partial_match=${TRUE}
    Log to Console    ${output}

Trigger HO from Real to Sim with TXnRELOCoverall timer
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=60    nrsrq_nr=60
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=${Xn_cancel}   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    HO successful   partial_match=${TRUE}
    Log to Console    ${output}

Trigger NG HO from Real to RANSIM with A3
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=60    nrsrq_nr=60
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=${NG_HO_Pattern_Check}   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    Inter-eNB   partial_match=${TRUE}
    Log to Console    ${output}

Trigger A2 Measurement
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
     wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A2    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=60    nrsrq_nr=60
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}

Trigger A2 for IRAT HO
     [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
     wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A2    srsrp_nr=11    srsrq_nr=11    phycell_id=${phycell_id}
    ...   nrsrp_nr=30    nrsrq_nr=30    srs_result=0:11:11:0    nrs_result=30:30:0      rs_type=ssb     index=0
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}

Trigger B2 measurement
     [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id_remote}
     wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=B2    srsrp_nr=11    srsrq_nr=11
     ...    phycell_id=${phycell_id_remote}     nrsrp_nr=30    nrsrq_nr=30    srs_result=0:11:11:0    nrs_result=30:30:0      rs_type=ssb     index=0
#     ${output}   wtsrunner.read_wtsemu_output_until_re    expected=${IRAT_HO_Pattern_Check}   timeout=15
#     ${output}         Get Lines Matching Regexp    ${output}    HO successful   partial_match=${TRUE}
#     Log to Console    ${output}

Create Interface for Xn HO
    Run    sudo ip addr add 10.0.1.139/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3

Delete Interface Created by Xn HO
    Run    sudo ip addr del 10.0.1.139/24 dev eth3
    Run    sudo ip addr del 10.0.1.138/24 dev eth3

UE History Update
    [Documentation]     This KW can be used when we want to carry out HO from RANSIM to Real gNB
    [Arguments]     ${ue_id}    ${gNB_id_RANSIM}
    wtsrunner.ue_history_information_list_add_ngran     id=${ue_id}     gnb_id=${gNB_id_RANSIM}     cell_type=medium    nrcgi=311:489|0x05
    ...     time_ue_stayed_in_cell=100
    wtsrunner.ue_history_information_list       id=${ue_id}     action=commit
    wtsrunner.ue_enb_param     id=${ue_id}     ue_history_list=1

UE HO from RANSIM to Real gNB
    [Arguments]    ${ue_id}    ${meas_id}    ${phycell_id_realgNB}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=11    srsrq_nr=11
    ...   phycell_id=${phycell_id_realgNB}     nrsrp_nr=60    nrsrq_nr=60
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete     timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    HO successful   partial_match=${TRUE}
    Log to Console    ${output}

NSA Inter Frequency Intra gNB HO
    [Arguments]     ${ue_id}    ${meas_id}
    wtsrunner.ue_enb_param      id=${ue_id}     drx_config=off      measurement_gap=gp0:0   gap_trigger=gnb_triggered   mgta=ms0    gap_purpose=perUE
    wtsrunner.ue_measurement_send_nr    event=A2    id=${ue_id}     meas_id=${meas_id}     rs_type=ssb      srsrp_nr=30
    Sleep   20s
    wtsrunner.ue_enb_param      id=${ue_id}      drx_config=off     measurement_gap=off     mgta=ms0        gap_purpose=perUE
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=${NSA_HO_IAFR_Pattern_Check}   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    SgNB Modification Confirm   partial_match=${TRUE}
    Log to Console    ${output}

NSA Inter Frequency A3 measurement
        [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=60    nrsrq_nr=60
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=${NSA_HO_IAFR_Pattern_Check}   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    SgNB Modification Confirm   partial_match=${TRUE}
    Log to Console    ${output}

Trigger HO failure from sim to real with TXnRELOCtimer expiry
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=60    nrsrq_nr=60
#    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=${ho_fail}   timeout=15
#    ${output}         Get Lines Matching Regexp    ${output}    HO successful   partial_match=${TRUE}
#    Log to Console    ${output}

Trigger A5 Measurement
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A5    srsrp_nr=15    srsrq_nr=15    phycell_id=${phycell_id}
    ...   nrsrp_nr=90    nrsrq_nr=90
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}

Trigger eNB initiated inter-rat handover to 5g
    [Arguments]    ${ue_id}    ${target_gnb}    ${target_cell}    ${plmn}=311:489
    wtsrunner.gnb_trigger_inter_rat_handover_to_5g     ue=${ue_id}     target_gnb=${target_gnb}
    ...     target_cell=${target_cell}      plmn=${plmn}

Get UE Summary
    [Documentation]     this is used to get summary of the current UE it does not require.
    wtsrunner.ue_summary

Display Measurement Configuration for UE
    [Documentation]    This Keyword is to display and return Measurment configuration for UE and return the measurmentid for given Event
    ...                 [Arguments]    UE_Id    :       UE id (int) for which measurment configurations required
    ...                                event    :       Event name for which measurment id required , should A1,A2... or B1,B2...etc deffault is A1
    ...                 [Return]       measId   :       it returns the measurment id corresponding to the passed even.
    ...                 [usage]        Display Measurement Configuration for UE         1       A3
    ...                                Display Measurement Configuration for UE         ue_id=1     event=A3
    [Arguments]             ${ue_id}            ${event}
    wtsrunner.ue_meas_cfg_disp                  id=${ue_id}
    log to console                              ${event}
    ${output}           Read WTS Output Until Pattern Matches          ${UE_meas_id_pattern}       ${Timeout_SA}
    ${measId}           get Event id            ${event}                ${output}
    [return]            ${measId}
