*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    ../resources/common_configuration.robot
Resource    CB008250_keywords.robot
Library     ../resources/common_keywords.py
Library     keywords_CB008250.py

Documentation
...    author: Lukasz Filipek (lukasz.filipek@nokia.com)
...    maintainer: Lukasz Filipek
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 26R1

Suite Setup      Run Keywords    Enable Syslog Info Level Prints
    ...       AND    Disable Actrat1alloc
    ...       AND    Set Minrcellutilperplmn And Nrg To 5min
    ...       AND    Enable Slice Aware Scheduler
    ...       AND    Enable Plmn Aware Scheduler
    ...       AND    Enable Actslicenumext
    ...       AND    Enable Plmn Spid And Resource Groups
    ...       AND    Set 5qis And Their Discard Timers
    ...       AND    Enable Dc Gbr Service On Gnb-2 Cell-1
    ...       AND    Activate Xn And A5 Measurement
    ...       AND    Configure SA VM interfaces
    ...       AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    ...       AND    Reach Onair    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

Test Teardown    Send Configuration ID To Scout
Suite Teardown    Run Keywords    Check For An Unexpected Alarm
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${TRAFFIC_DURATION_SEC}=    20s
&{5QI_TO_EGATE_QOS_FLOW_ID}=    2=4    82=7
${radio_resources_not_available_filter1}=    ngap.InitialContextSetupFailure_element && ngap.radioNetwork == 22 && ngap.AMF_UE_NGAP_ID == 2
${radio_resources_not_available_filter2}=    ngap.InitialContextSetupFailure_element && ngap.radioNetwork == 22 && ngap.AMF_UE_NGAP_ID == 5
${xn_radio_resources_not_available}=     xnap.radioNetwork == 4

*** Test Cases ***
CB008250-B-B1_GBR_DRB_admission_with_PLMN_limits_check
    Modify Default Qos Flow For UE13 To GBR 5qi2
    Modify Default Qos Flow For UE14 To GBR 5qi2
    Register UE13 With Pdu Session ID1 And Network Slice ID1
    Start 100Mb dl Data Traffic For UE13 PDU1
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Qfi stats    ue_id=13
    Register UE14 With Pdu ID1 And Nwslice ID2 And Fail Due To Resources Not Available
    Verify Tshark For Single Message    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${radio_resources_not_available_filter1}
    Deregister Multiple Ues    start_ue_id=13   end_ue_id=14

CB008250-B-IWK3_PLMN_aware_GBR_DRB_admission_with_Delay_Critical_GBRs
    Modify Default Qos Flow For UE13 To GBR 5qi82
    Modify Default Qos Flow For UE14 To GBR 5qi82
    Register UE13 With Pdu Session ID1 And Network Slice ID1
    Sleep    5s
    Register UE14 With Pdu ID1 And Nwslice ID2 And Fail Due To Resources Not Available
    Verify Tshark For Single Message    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${radio_resources_not_available_filter2}
    Deregister Multiple Ues    start_ue_id=13   end_ue_id=14

CB008250-B-B2_GBR_admission_for_incoming_HO_with_PLMN_limits_check
    Modify Default Qos Flow For UE1 To GBR 5qi2
    Modify Default Qos Flow For UE2 To GBR 5qi2
    Register UE1 With Pdu Session ID1 And Network Slice ID1
    Register UE2 With Pdu Session ID1 And Network Slice ID1
    Start 5Mb dl Data Traffic For UE1 PDU1
    Start 5Mb dl Data Traffic For UE2 PDU1
    Prepare UE1 For Inter gNB HO
    Sleep    ${TRAFFIC_DURATION_SEC}
    Perform Handover To Sim gNB
    Sleep    ${TRAFFIC_DURATION_SEC}
    Perform Handover To Ext gNB And Fail
    Verify Tshark For Single Message    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${xn_radio_resources_not_available}
    Deregister Multiple Ues    start_ue_id=1   end_ue_id=2

*** Keywords ***
Enable Dc Gbr Service On Gnb-2 Cell-1
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_enable_actDcGbrService_and_maxNumOfDcGbrBearersSA_set_to_10.json
    Wait for gNB Configured state

Activate Xn And A5 Measurement
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_xn_a5_activation.json

Percentage Of Resources For GBR Traffic Ho
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_set_addGbrTrafficHo.json

Modify Default Qos Flow For UE${ue_id:\d+} To GBR 5qi${5qi_id:\d+}
    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi_id}
    Execute egate command   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal default_qos_flow=${QoS_FLOW_ID}

Register UE${ue_id:\d+} With Pdu Session ID${pdu_id:\d+} And Network Slice ID${slice_id:\d+}
    Execute Egate Command And Wait For Data    cmd=ue_register id=${ue_id}
    ...                      pass_regexp=UE${ue_id}: UE performed Registration type INITIAL_REGISTRATION
    ...                      timeout=10
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${slice_id}
    ...                      pass_regexp=UE-${ue_id} PDU SESSION ID-${pdu_id} setup/reestablishment complete
    ...                      timeout=10

Register UE${ue_id:\d+} With Pdu ID${pdu_id:\d+} And Nwslice ID${slice_id:\d+} And Fail Due To Resources Not Available
    Execute Egate Command And Wait For Data    cmd=ue_register id=${ue_id}
    ...                      pass_regexp=UE${ue_id}: UE performed Registration type INITIAL_REGISTRATION
    ...                      timeout=10
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${slice_id}
    ...                      pass_regexp=AMF-1: Received Initial Context Setup Failure from GNB-2 with cause RAN radio resources not available.
    ...                      timeout=10

Start ${trf}Mb ${dir} Data Traffic For UE${ue_id} PDU${pdu_id}
    Execute egate command   cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} dir=${dir} mbps=${trf}

Perform Handover To Sim gNB
    Execute egate command   cmd=ue_measurement_send_nr id=1 meas_id=1 event=A5 srsrp_nr=19 phycell_id=52 nrsrp_nr=80
    ...                     pass_regexp=GNB-3: UE1: XN Handover Successfully completed at Target.
    ...                     timeout=10

Perform Handover To Ext gNB And Fail
    Execute egate command   cmd=ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=19 phycell_id=50 nrsrp_nr=80
    ...                     pass_regexp=GNB-3: UE1: Unsuccessful outcome for XnAP::HandoverPreparation is received. Handover canceled.
    ...                     timeout=10

Prepare UE${ue_id:\d+} For Inter gNB HO
    Execute egate command   cmd=ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command   cmd=ue_history_information_list_add_ngran id=1 gnb_id=2 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command   cmd=ue_history_information_list id=1 action=commit
    Execute egate command   cmd=ue_enb_param id=${ue_id} ue_history_list=1
