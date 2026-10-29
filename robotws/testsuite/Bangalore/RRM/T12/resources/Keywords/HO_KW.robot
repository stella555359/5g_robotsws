*** Settings ***
Documentation    This File consist of Keywords for the Hand over.
Library         Collections
Library         OperatingSystem
Library         String
Library         ${CURDIR}/../PythonLib/getEventId.py


*** Variables ***
${ENB_ID}           1
${RANSIM_GNBID}     3
${MEASUREMENT_ID}   NR MEASUREMENT IDENTITIES
${XN_HO_PATTERN_CHECK}      PATH_SWITCH_REQUEST_ACK Received
${NG_HO_PATTERN_CHECK}      OnReceiveHandoverNotify
${IRAT_HO_PATTERN_CHECK}    IRAT Handover from NR to EUTRA completed
${NSA_HO_IAFR_PATTERN_CHECK}    Sending SgNB Modification Confirm
${NSA_HO_IEFR_A3_CHECK}     rrcConnectionReconfigurationComplete
${X2_LINK_PATTERN_RANSIM}   X2AP Link with GNB-3
${XN_CANCEL}       UE CONTEXT RELEASE COMPLETE
${HO_FAIL}         Unexpected timeout in UE CONTEXT RELEASE
${UE_MEAS_ID_PATTERN}         DETAILED INFO ABOUT NR REPORT CONFIGURATIONS


*** Keywords ***
Setup Xn Link To Simulated Gnb
    [Documentation]     This KW is to bring up Xn interface between real and simulated gNB of RANSIM
    wtsrunner.Gnb Xn Link Up       gnb=${RANSIM_GNBID}     target=2
    Sleep   30s
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=XnAP Link with GNB-2*      timeout=10
    Log To Console    ${output} XnAP successfully established

Setup X2 With RANSIM GNB
    [Documentation]    This keyword is used to Create a X2 connection with Simulated RANSIM gNB
    ...                And checks if the X2AP link with the gNB is UP in the output file.
    wtsrunner.Enb X2 Link Up    enb=${ENB_ID}    target=${RANSIM_GNBID}
    Read Wts Output For Pattern And Print Matching Lines    ${X2_LINK_PATTERN_RANSIM}    ${Timeout_NSA}
    Log    x2_is_ok

Get Configured Measurements Of UE
    [Documentation]    Used for Getting Configured Measurements Of UE
    [Arguments]     ${ue_id}
    BuiltIn.Log    Get configured Measurements...    console=${True}
    wtsrunner.Ue Meas Cfg Disp    id=${ue_id}    meas_obj_type=nr
    ${output}   Read WTS Output Until Pattern Matches     ${MEASUREMENT_ID}:   timeout=20
    ${output}   Get Lines Matching Regexp    ${output}    UE${ue_id} NR MEASUREMENT IDENTITIES:   partial_match=${TRUE}
    Print Matching Lines From Output File       ${output}   ${MEASUREMENT_ID}

Trigger A3 Measurement
    [Documentation]    Trigger A3 Measurement Handover
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.Ue Measurement Send NR    id=${ue_id}    meas_id=${meas_id}    event=A3
    ...       srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}    nrsrp_nr=60    nrsrq_nr=60
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log To Console    ${output}

Trigger A3 Measurement For NSA
    [Documentation]    Trigger A3 Measurement For NSA
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.Ue Measurement Send NR    id=${ue_id}     meas_id=${meas_id}    event=A3    srsrp_nr=1
    ...       srsrq_nr=1    phycell_id=${phycell_id}    nrsrp_nr=60    nrsrq_nr=60
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${NSA_HO_IAFR_PATTERN_CHECK}   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    SgNB Modification Confirm   partial_match=${TRUE}
    Log To Console    ${output}

Trigger A3 Measurement For NSA HO From Real To RANSIM
    [Documentation]    Trigger A3 Measurement For NSA HO From Real To RANSIM
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.Ue Measurement Send NR    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1
    ...        srsrq_nr=1    phycell_id=${phycell_id}       nrsrp_nr=60    nrsrq_nr=60
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${NSA_HO_IEFR_A3_CHECK}   timeout=30
    ${output}         Get Lines Matching Regexp    ${output}    rrcreconfiguration   partial_match=${TRUE}
    Log To Console    ${output}

Trigger Ho From Real To Sim With A3
    [Documentation]    Trigger Ho From Real To Sim With A3
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.Ue Measurement Send NR    id=${ue_id}    meas_id=${meas_id}    event=A3
    ...       srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}    nrsrp_nr=60    nrsrq_nr=60
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${Xn_HOPattern_Check}   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    HO successful   partial_match=${TRUE}
    Log To Console    ${output}

Trigger HO From Real To Sim With TXnRELOCoverall Timer
    [Documentation]    Trigger HO From Real To Sim With TXnRELOCoverall Timer
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.Ue Measurement Send NR    id=${ue_id}    meas_id=${meas_id}    event=A3
    ...       srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}    nrsrp_nr=60    nrsrq_nr=60
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${XN_CANCEL}   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    HO successful   partial_match=${TRUE}
    Log To Console    ${output}

Trigger Ng Ho From Real To Ransim With A3
    [Documentation]    Trigger Ng Ho From Real To Ransim With A3
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.Ue Measurement Send NR    id=${ue_id}    meas_id=${meas_id}    event=A3
    ...       srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}    nrsrp_nr=60    nrsrq_nr=60
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${NG_HO_PATTERN_CHECK}   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    Inter-eNB   partial_match=${TRUE}
    Log To Console    ${output}

Trigger A2 Measurement
    [Documentation]    Trigger A2 Measurement
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.Ue Measurement Send NR    id=${ue_id}    meas_id=${meas_id}    event=A2
    ...       srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}    nrsrp_nr=60    nrsrq_nr=60
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log To Console    ${output}

Trigger A2 For IRAT HO
    [Documentation]    Trigger A2 For IRAT HO
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.Ue Measurement Send NR    id=${ue_id}    meas_id=${meas_id}    event=A2    srsrp_nr=11
    ...    srsrq_nr=11    phycell_id=${phycell_id}     nrsrp_nr=30    nrsrq_nr=30
    ...    srs_result=0:11:11:0    nrs_result=30:30:0      rs_type=ssb     index=0
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log To Console    ${output}

Trigger B2 Measurement
    [Documentation]    Trigger B2 Measurement
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id_remote}
    wtsrunner.Ue Measurement Send NR    id=${ue_id}    meas_id=${meas_id}    event=B2    srsrp_nr=11    srsrq_nr=11
    ...    phycell_id=${phycell_id_remote}     nrsrp_nr=30    nrsrq_nr=30    srs_result=0:11:11:0
    ...    nrs_result=30:30:0      rs_type=ssb     index=0
#     ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${IRAT_HO_Pattern_Check}   timeout=15
#     ${output}         Get Lines Matching Regexp    ${output}    HO successful   partial_match=${TRUE}
#     Log To Console    ${output}

Create Interface For Xn HO
    [Documentation]    Create Interface For Xn HO
    Run    sudo ip addr add 10.0.1.139/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3

Delete Interface Created By Xn HO
    [Documentation]    Create Interface For Xn HO
    Run    sudo ip addr del 10.0.1.139/24 dev eth3
    Run    sudo ip addr del 10.0.1.138/24 dev eth3

UE History Update
    [Documentation]     This KW can be used when we want to carry out HO from RANSIM to Real gNB
    [Arguments]      ${ue_id}      ${gNB_id_RANSIM}
    wtsrunner.Ue History Information List Add Ngran     id=${ue_id}     gnb_id=${gNB_id_RANSIM}     cell_type=medium
    ...         nrcgi=311:489|0x05    time_ue_stayed_in_cell=100
    wtsrunner.Ue History Information List       id=${ue_id}     action=commit
    wtsrunner.UE Enb Param     id=${ue_id}     ue_history_list=1

UE HO From RANSIM To Real GNB
    [Documentation]    UE HO From RANSIM To Real GNB
    [Arguments]    ${ue_id}    ${meas_id}    ${phycell_id_realgNB}
    wtsrunner.Ue Measurement Send NR    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=11    srsrq_nr=11
    ...   phycell_id=${phycell_id_realgNB}     nrsrp_nr=60    nrsrq_nr=60
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=rrcReconfigurationComplete     timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    HO successful   partial_match=${TRUE}
    Log To Console    ${output}

NSA Inter Frequency Intra GNB HO
    [Documentation]    NSA Inter Frequency Intra GNB HO
    [Arguments]     ${ue_id}    ${meas_id}
    wtsrunner.Ue Enb Param      id=${ue_id}     drx_config=off      measurement_gap=gp0:0
    ...    gap_trigger=gnb_triggered   mgta=ms0    gap_purpose=perUE
    wtsrunner.Ue Measurement Send NR    event=A2    id=${ue_id}     meas_id=${meas_id}    rs_type=ssb    srsrp_nr=30
    Sleep   20s
    wtsrunner.Ue Enb Param    id=${ue_id}    drx_config=off    measurement_gap=off     mgta=ms0    gap_purpose=perUE
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${NSA_HO_IAFR_PATTERN_CHECK}   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    SgNB Modification Confirm   partial_match=${TRUE}
    Log To Console    ${output}

NSA Inter Frequency A3 Measurement
    [Documentation]    NSA Inter Frequency A3 Measurement
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.Ue Measurement Send NR    id=${ue_id}    meas_id=${meas_id}    event=A3
    ...       srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}    nrsrp_nr=60    nrsrq_nr=60
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${NSA_HO_IAFR_PATTERN_CHECK}   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    SgNB Modification Confirm   partial_match=${TRUE}
    Log To Console    ${output}

Trigger Ho Failure From Sim To Real With Txnreloctimer Expiry
    [Documentation]    Trigger Ho Failure From Sim To Real With Txnreloctimer Expiry
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.UE Measurement Send NR    id=${ue_id}    meas_id=${meas_id}    event=A3
    ...       srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}    nrsrp_nr=60    nrsrq_nr=60
#    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${HO_FAIL}   timeout=15
#    ${output}         Get Lines Matching Regexp    ${output}    HO successful   partial_match=${TRUE}
#    Log To Console    ${output}

Trigger A5 Measurement
    [Documentation]    Trigger A5 Measurement
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.UE Measurement Send NR    id=${ue_id}    meas_id=${meas_id}    event=A5    srsrp_nr=15
    ...       srsrq_nr=15    phycell_id=${phycell_id}    nrsrp_nr=90    nrsrq_nr=90
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log To Console    ${output}

Trigger Enb Initiated Inter-Rat Handover To 5G
    [Documentation]    Trigger Enb Initiated Inter-Rat Handover To 5G
    [Arguments]    ${ue_id}    ${target_gnb}    ${target_cell}    ${plmn}=311:489
    wtsrunner.Gnb Trigger Inter Rat Handover To 5G     ue=${ue_id}     target_gnb=${target_gnb}
    ...     target_cell=${target_cell}      plmn=${plmn}

Get UE Summary
    [Documentation]     this is used to get summary of the current UE it does not require.
    wtsrunner.UE Summary

Display Measurement Configuration For UE
    [Documentation]    This Keyword is to display and return Measurment configuration for UE and
    ...                 return the measurmentid for given Event
    ...                 [Arguments]    UE_Id    :   UE id (int) for which measurment configurations required
    ...                                event    :   Event name for which measurment id required.deffault is A1
    ...                 [Return]       measId   :   It returns the measurment id corresponding to the passed even.
    ...                 [usage]        Display Measurement Configuration for UE        1       A3
    ...                                Display Measurement Configuration for UE        ue_id=1     event=A3
    [Arguments]             ${ue_id}            ${event}
    wtsrunner.Ue Meas Cfg Disp                  id=${ue_id}
    Log To Console                              ${event}
    ${output}           Read WTS Output Until Pattern Matches          ${UE_MEAS_ID_PATTERN}       ${Timeout_SA}
    ${measId}           Get Event Id            ${event}                ${output}
    [Return]            ${measId}
