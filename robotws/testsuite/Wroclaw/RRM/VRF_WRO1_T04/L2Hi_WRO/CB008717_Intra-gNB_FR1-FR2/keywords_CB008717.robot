*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ta_messaging/flow.robot
Library     ta_messaging
Library     ta_messaging/robot_flow_framework/expect_keyword_listener.py
Library     ../5GC000774_ROHC/keywords_ROHC.py
Library     ../resources/common_keywords.py

Documentation
...    This file contains general keywords used for testing Feature CB008717.

*** Variables ***
${A4_param}=    event=A4 srsrp_nr=19 srsrq_nr=10 phycell_id=52 nrsrp_nr=85 nrsrq_nr=31 index=1 nrs_result=30:30:0
${rdActNrDualConnectivity}=   0x890057

*** Keywords ***
Common Test Setup CB008717
    [Arguments]        ${iphy}    ${scf}    ${cfg_filepath}
    Enable Syslog Info Level Prints
    Activate Nr Dual Connectivity
    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    Configure VM interfaces For Second Gnb
    Update Scf And Ap    ${iphy}    ${scf}
    Set k1 and k2 values for airphone
    Setup devices aliases
    Reach Onair    lua_cfg=${cfg_filepath}
    Set Internal Traffic Type To UEs

Update Scf And Ap
    [Arguments]    ${iphy}    ${scf}
    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/${iphy}
    Fix And Send Full Commissioning With Given Scf Filepath    scfc_filepath=${CURDIR}/config/SBTS00/${scf}
    ...    skip_relation_errors=True
    Wait for gNB Configured state

Set RD Flag For Mcs 5
    Change Rad Param With Aashell    param=${rdSupportedDl64QamMcs}    value=0x20

Reset RD Flag For Mcs
    Change Rad Param With Aashell    param=${rdSupportedDl64QamMcs}    value=0x800

Set Ul Over SCG
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/CB008717/delta_NRDRB-11_ul_Over_SCG.json
    ...    skip_relation_errors=True

Activate Nr Dual Connectivity
    Change Rad Param With Aashell    param=${rdActNrDualConnectivity}    value=0

Set Dl Split Mode To DlOverF1UX2U And Initial DL Traffic Routing To initDLoverF1U
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008717/delta_NRDRB-11_initialDLTrafficRoutingNrDc_to_initDLoverF1U.json
    ...    skip_relation_errors=True

Set Dl Split Mode To DlOverF1UX2U And Initial DL Traffic Routing To initDLoverXxU
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008717/delta_NRDRB-11_initialDLTrafficRoutingNrDc_to_initDLoverXxU.json
    ...    skip_relation_errors=True

Set Dl Split Mode To DlOverF1UX2U
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008717/delta_NRDRB-11_dlDataSplitModeNrDc_to_dlOverF1UXxU.json
    ...    skip_relation_errors=True

Set Dl Split Mode To DlOverF1U
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008717/delta_NRDRB-11_dlDataSplitModeNrDc_to_dlOverF1U.json
    ...    skip_relation_errors=True

Set Ul Data Split Primary Path SCG
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/CB008717/delta_NRDRB-11_ul_Data_Split_Primary_Path_SCG.json
    ...    skip_relation_errors=True

Set k1 and k2 values for airphone
    Change Rad Param With Aashell    param=0x5800F4    value=4
    Change Rad Param With Aashell    param=0x58012D    value=4

Register Nrdc Ue With Default Pdu Session With A4
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2
    Register Ue With Default Pdu Session
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2
    Send A4 Measurement

Start Udp Traffic 150Mbps In DL
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=1

Start Udp Traffic 450Mbps In DL
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=3

Increase DL Data Traffic To 450Mbps
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=3

Setup devices aliases
#    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1
    Enable internal mirroring for alias  gNB2

Set expected messages flows for A4 measurement based PSCell addition for UE${ue_id:\d+}, gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=30]: gNB${gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=30]: gNB${gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=30]: gNB${gnb_id} F1AP 2*uEContextModification
#    EXPECT FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCReconfiguration
#    EXPECT FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
#    EXPECT FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCRelease
    Execute Egate Command    cmd=ue_disp id=${ue_id}

Verify expected messages flows for A4 measurement based PSCell addition for UE${ue_id:\d+}, gNB${gnb_id:\d+}
    PASS FLOW[timeout=30]: gNB${gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=30]: gNB${gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=30]: gNB${gnb_id} F1AP 2*uEContextModification
#    PASS FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCReconfiguration
#    PASS FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
#    FAIL FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCRelease
    Execute Egate Command    cmd=ue_disp id=${ue_id}

Set Expected Message Flow For UE Context Release For UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModificationRequired
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Expect message flow
    ...    gNB2:F1AP_UEContextReleaseCommand (radioNetwork eq 'normal-release') as UEContextReleaseCommandMNContext
    ...    alias=F1apUeContextReleaseMNContext
    ...    overall_timeout=10
#    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextRelease
    Execute Egate Command    cmd=ue_disp id=${ue_id}

Verify Expected Message Flow For UE Context Release For UE${ue_id:\d+}
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModificationRequired
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Flow occurred as expected       alias=F1apUeContextReleaseMNContext
#    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextRelease
    Execute Egate Command    cmd=ue_disp id=${ue_id}

Check Dl Data Traffic On Mcg And Scg Leg
    [Arguments]    ${ue_id}=1    ${traffic_duration}=1m    ${expected_throughput}=100
    Sleep    ${traffic_duration}
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=${ue_id} cell_group=MCG type=pdsch
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=${ue_id} cell_group=SCG type=pdsch scell=1
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=${ue_id} pdu=1 qfi=1 dir=dl
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=${ue_id}
    ...    pdu_id=1    qfi_id=1    expected_throughput=${expected_throughput}    unit=mbps    margin=0.2    direction=dl

Check Ul Data Traffic On Mcg And Scg Leg
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${traffic_duration}=1m    ${expected_throughput}=100    ${expected_ul}=100
    ...    ${scell}=0    ${cell_group}=MCG
    Sleep    ${traffic_duration}
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=${ue_id} cell_group=MCG type=pusch scell=0
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=${ue_id} cell_group=SCG type=pusch scell=1
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul scell=1
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=${ue_id}
    ...    pdu_id=${pdu_id}    qfi_id=1    expected_throughput=${expected_throughput}    unit=mbps    margin=0.2    direction=ul
    Run Keyword And Continue On Failure    Check Number Of Total Packets Lost    ue_id=${ue_id}    pdu_id=${pdu_id}
    ...    qfi_id=1    packet_loss=0    margin=0.0    direction=ul
    Run Keyword And Continue On Failure    Verify UL Throughput Leg    ue_id=${ue_id}    cell_group=${cell_group}
    ...    scell=${scell}    expected_ul=${expected_ul}

UE UL Data Distribution
    [Arguments]    ${ue_id}=1    ${percent_value}=0
    Execute Egate Command    cmd=uec_param id=${ue_id} scg_ul_dist_percent=${percent_value}

Verify If Pm Counters Arent Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NUM_DL_PDU_LOST_X2_QOS_GRP_01}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NUM_OPPT_DL_DAT_SPT_QOS_GRP_01}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_UL_PDCP_VOL_RCV_X2_QOS_GRP_01}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_EST_TPUT_X2_BIN_01}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
