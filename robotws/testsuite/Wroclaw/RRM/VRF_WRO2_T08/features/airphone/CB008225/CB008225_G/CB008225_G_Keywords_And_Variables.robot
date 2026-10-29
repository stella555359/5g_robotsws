*** Settings ***
Documentation
...  Authors:   Katarzyna Wisniewska, Joachim Otto, Dominik Borkowski
...  Mantainer:  marcin.plawny@nokia.com

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Library    ta5g_testline_management
Library    ta5g_ue_mobility
Library    ta5g_throughput
Library    ta5g_delta
Library    ta5g_iphy
Library    ta5g_enb

*** Variables ***
${NGAP_LOCATION_REPORT_ULI} =    ${NGAP_LOCATION_REPORT} && ${ULI_IE}
${NGAP_LOCATION_REPORTING_CONTROL_DIRECT} =    ${NGAP_LOCATION_REPORTING_CONTROL} && ${DIRECT_IE}
${NGAP_LOCATION_REPORTING_CONTROL_CHANGE_CELL} =    ${NGAP_LOCATION_REPORTING_CONTROL} && ${CHANGE_CELL_IE}
${RRC_RELEASE_WITH_SUSPEND_CONFIG} =    ${RRC_RELEASE} && nr-rrc.suspendConfig_element
${NGAP_LOCATION_REPORTING_FAILURE} =    ngap.LocationReportingFailureIndication_element
${F1AP_PAGING} =    f1ap.Paging_element
${CELL_ID_1} =    (f1ap.nRCellIdentity == 00:00:04:00:10)
${CELL_ID_2} =    (f1ap.nRCellIdentity == 00:00:04:00:20)
${NGAP_LOCATION_REPORT_WITH_TIMESTAMP} =    ${NGAP_LOCATION_REPORT_ULI} && ngap.timeStamp
${RRC_RESUME_REQUEST_1_CAUSE_MT_ACCESS_CELL_1} =    ${RRC_RESUME_REQUEST_1} && nr-rrc.resumeCause == 2 && ${CELL_ID_1}
${RRC_RESUME_REQUEST_1_CAUSE_MT_ACCESS_CELL_2} =    ${RRC_RESUME_REQUEST_1} && nr-rrc.resumeCause == 2 && ${CELL_ID_2}
${AREACODE_1} =    nr-rrc.rrcRelease_element && nr-rrc.ran_AreaConfigList == 1
${LOCAL_REPORT_WITH_NRCELL_1_IDENTITY} =    ${NGAP_LOCATION_REPORT_ULI} && ngap.NRCellIdentity == 0x0000004001
${LOCAL_REPORT_WITH_NRCELL_2_IDENTITY} =    ${NGAP_LOCATION_REPORT_ULI} && ngap.NRCellIdentity == 0x0000004002
${LOCATION_REPORT_WITH_NRCELL1_IN_AOI} =    ${NGAP_LOCATION_REPORT} && ngap.areaOfInterestList == 1 && ngap.NRCellIdentity == 0x0000004001
${LOCATION_REPORT_WITH_NRCELL2_IN_AOI} =    ${NGAP_LOCATION_REPORT} && ngap.areaOfInterestList == 1 && ngap.NRCellIdentity == 0x0000004002
${CORRECT_PLMN_IN_ULI} =    ${NGAP_LOCATION_REPORT_ULI} && ngap.pLMNIdentity == 13:41:98
${CORRECT_PLMN_IN_AOI} =    ${NGAP_LOCATION_REPORT} && ngap.areaOfInterestList == 1 && ngap.pLMNIdentity == 13:41:98
${UE_PRESENCE_IN_LOCATION_REPORT} =    ${NGAP_LOCATION_REPORT} && ngap.uEPresence == 1
${REFERENCE_ID_IN_LOCATION_REPORT} =    ${NGAP_LOCATION_REPORT} && ngap.locationReportingReferenceID == 1
${CHANGE_OF_SERVING_CELL_LOCATION_REPORT} =    ngap.LocationReport_element&&ngap.eventType == 1
${NGAP_CELLIDENTITY_1}=    ngap.NRCellIdentity == 0x0000004001
${NGAP_CELLIDENTITY_2}=    ngap.NRCellIdentity == 0x0000004002
${NGAP_CELLIDENTITY_3}=    ngap.NRCellIdentity == 0x0000004003
${TAC_200}=   ngap.tAC == 200
${PLMN}=    ngap.pLMNIdentity == 13:41:98
${AOI_LIST}=    ngap.areaOfInterestList == 8
${RRC_RESUME_REQUEST_1_RNA_UPDATE_CELL_1} =    ${RRC_RESUME_REQUEST_1} && nr-rrc.resumeCause == 8 && ${CELL_ID_1}
${RRC_RESUME_REQUEST_1_RNA_UPDATE_CELL_2} =    ${RRC_RESUME_REQUEST_1} && nr-rrc.resumeCause == 8 && ${CELL_ID_2}
${AREACODE_2} =    nr-rrc.rrcRelease_element && nr-rrc.RAN_AreaCode == 2
${LOCAL_REPORT_WITH_NRCELL_1_IDENTITY_IN_AREAOFINTERESTLIST} =    ${NGAP_LOCATION_REPORT} && ngap.areaOfInterestList == 2
...    && ngap.NRCellIdentity == 0x000004001
${LOCAL_REPORT_WITH_NRCELL_2_IDENTITY_IN_AREAOFINTERESTLIST} =    ${NGAP_LOCATION_REPORT} && ngap.areaOfInterestList == 2
...    && ngap.NRCellIdentity == 0x000004002
${NGAP_PDU_SESSION_RESOURCE_SETUP_REQUEST} =    ngap.PDUSessionResourceSetupRequest_element
${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE} =    ngap.PDUSessionResourceSetupResponse_element
${LOCATION_REPORT_REFERENCE_ID_AND_NRCELL1_IDENTITY} =    ngap.LocationReport_element && ngap.locationReportingReferenceID == 1
...    && ngap.NRCellIdentity == 0x000004001
${LOCATION_REPORT_REFERENCE_ID_AND_NRCELL2_IDENTITY} =    ngap.LocationReport_element && ngap.locationReportingReferenceID == 2
...    && ngap.NRCellIdentity == 0x000004002
${LOCATION_REPORT_WITH_NRCELL1_IN_AOICL} =    ${NGAP_LOCATION_REPORT} && ngap.areaOfInterestCellList == 1 && ngap.NRCellIdentity == 0x000004001
${LOCATION_REPORT_WITH_NRCELL2_IN_AOICL} =    ${NGAP_LOCATION_REPORT} && ngap.areaOfInterestCellList == 1 && ngap.NRCellIdentity == 0x000004002
${CORRECT_PLMN_IN_AOIL} =    ngap.LocationReport_element && ngap.areaOfInterestList == 2 && ngap.pLMNIdentity == 13:41:98
${UE_PRESENCE_EQUAL_IN_FOR_REFERENCEID1} =    ngap.LocationReport_element && ngap.locationReportingReferenceID == 1 && ngap.uEPresence == 0
${UE_PRESENCE_EQUAL_OUT_FOR_REFERENCEID2} =    ngap.LocationReport_element && ngap.locationReportingReferenceID == 2 && ngap.uEPresence == 1
${UE_PRESENCE_IN_AOI_IE}=    ngap.eventType == 2
${NGAP_LOCATION_REPORTING_CONTROL} =  ngap.LocationReportingControl_element
${NGAP_LOCATION_REPORTING_CONTROL_AOI} =  ${NGAP_LOCATION_REPORTING_CONTROL} && ${UE_PRESENCE_IN_AOI_IE}
${STOP_AOI_IE} =  ngap.eventType == 4
${STOP_IE} =  ngap.eventType == 3
${NGAP_LOCATION_REPORTING_CONTROL_STOP_AOI} =  ${NGAP_LOCATION_REPORTING_CONTROL} && ${STOP_AOI_IE}
${NGAP_LOCATION_REPORTING_CONTROL_STOP_CHANGE_CELL} =  ${NGAP_LOCATION_REPORTING_CONTROL} && ${STOP_IE}



${RRC_PAGING} =    nr-rrc.Paging_element

*** Keywords ***
Configure Max Paging Retries
    [Arguments]    ${max_paging_retries}
    Execute Egate Command    cmd=amf_paging_param id=1 max_paging_retries=${max_paging_retries}

Configure Paging Delay
    [Arguments]    ${ue_id}    ${paging_delay}
    UE NR RRC Setup Param    ue_id=${ue_id} pagingdelay=${paging_delay}

Configure 8 Areas of Interest
    Area Of Interest Configuration    object_id=1    plmn=311:489    nrci=16385
    Area Of Interest Configuration    object_id=2    plmn=311:489    nrci=16386
    Area Of Interest Configuration    object_id=3    plmn=311:489    nrci=16387
    Execute Egate Command
    ...  cmd=area_of_interest_configuration object_id=4 plmn_tai=311:489 taclist=200
    Execute Egate Command
    ...  cmd=area_of_interest_configuration object_id=5 plmn_tai=311:489 taclist=200
    Execute Egate Command
    ...  cmd=area_of_interest_configuration object_id=6 plmn_tai=311:489 taclist=200
    Execute Egate Command
    ...  cmd=area_of_interest_configuration object_id=7 plmn_ran_node_id=311:489 globalrannodeid=1
    Execute Egate Command
    ...  cmd=area_of_interest_configuration object_id=8 plmn_ran_node_id=311:489 globalrannodeid=2

Send 8 Location Reporting Control Objects
    [Arguments]    ${ue_id}
    UE Send Location Reporting Control    ue=${ue_id}    event_type=ue-presence-in-area-of-interest
    ...                                   object_id=1    location_reporting_reference_id=1
    ...                                   object_id=2    location_reporting_reference_id=2
    ...                                   object_id=3    location_reporting_reference_id=3
    ...                                   object_id=4    location_reporting_reference_id=4
    ...                                   object_id=5    location_reporting_reference_id=5
    ...                                   object_id=6    location_reporting_reference_id=6
    ...                                   object_id=7    location_reporting_reference_id=7
    ...                                   object_id=8    location_reporting_reference_id=8

Start UL And DL Traffic
    [Arguments]    ${ue_id}    ${pdu_id}
    Start Data Traffic    ues=${ue_id}    direction=dl    pdu=${pdu_id}    throughput=1mbps
    Start Data Traffic    ues=${ue_id}    direction=ul    pdu=${pdu_id}    throughput=1mbps
    Sleep    5s    reason=Wait for data traffic transfer to start
    Check DL Bearer Stats    ue_id=${ue_id}    pdu_id=${pdu_id}
    Check UL Bearer Stats    ue_id=${ue_id}    pdu_id=${pdu_id}
    Stop Data Traffic    ues=${ue_id}    direction=ul    pdu=${pdu_id}
    Stop Data Traffic    ues=${ue_id}    direction=dl    pdu=${pdu_id}

Start Traffic
    [Arguments]    ${ue_id}    ${pdu_id}
    Start Data Traffic    ues=${ue_id}    direction=dl    pdu=${pdu_id}    throughput=1mbps
    Start Data Traffic    ues=${ue_id}    direction=ul    pdu=${pdu_id}    throughput=1mbps
    Sleep    5s    reason=Wait for data traffic transfer to start

Stop Traffic
    [Arguments]    ${ue_id}    ${pdu_id}
    Check DL Bearer Stats    ue_id=${ue_id}    pdu_id=${pdu_id}
    Check UL Bearer Stats    ue_id=${ue_id}    pdu_id=${pdu_id}
    Stop Data Traffic    ues=${ue_id}    direction=ul    pdu=${pdu_id}
    Stop Data Traffic    ues=${ue_id}    direction=dl    pdu=${pdu_id}

Stop DL
    [Arguments]    ${ue_id}    ${pdu_id}
    Sleep    5s    reason=Wait for data traffic transfer to start
    Check DL Bearer Stats    ue_id=${ue_id}    pdu_id=${pdu_id}
    Stop Data Traffic    ues=${ue_id}    direction=dl    pdu=${pdu_id}

Check DL Bearer Stats
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi_id}=1    ${dir}=dl    ${pass_regexp}=1
    Execute Egate Command    cmd=bearer_stats ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${dir}    pass_regexp=\(${pass_regexp}\.\\d M\)

Check UL Bearer Stats
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi_id}=1    ${dir}=ul    ${pass_regexp}=1
    Execute Egate Command    cmd=bearer_stats ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${dir}    pass_regexp=\(${pass_regexp}\.\\d M\)

Wait For RRC Release Message With Suspend Config
    [Arguments]    ${number_of_messages}=1
    Verify Tcpdump Log    packet_filter=${RRC_RELEASE_WITH_SUSPEND_CONFIG}    number_of_messages=${number_of_messages}    timeout=20

Wait For Location Report Message
    [Arguments]    ${number_of_messages}=1
    Verify Tcpdump Log    packet_filter=${NGAP_LOCATION_REPORT_ULI}    number_of_messages=${number_of_messages}    timeout=20

Wait For Location Report Message AOI With 8 Items Cell1
    [Arguments]    ${number_of_messages}=1
    Verify Tcpdump Log
    ...    packet_filter=${NGAP_LOCATION_REPORT}&&${UE_PRESENCE_IN_AOI_IE}&&${NGAP_CELLIDENTITY_1}&&${PLMN}&&${TAC_200}&&${AOI_LiSt}
    ...    number_of_messages=${number_of_messages}    timeout=20

Wait For Location Report Message AOI With 8 Items Cell2
    [Arguments]    ${number_of_messages}=1
    Verify Tcpdump Log
    ...    packet_filter=${NGAP_LOCATION_REPORT}&&${UE_PRESENCE_IN_AOI_IE}&&${NGAP_CELLIDENTITY_2}&&${PLMN}&&${TAC_200}&&${AOI_LiSt}
    ...    number_of_messages=${number_of_messages}    timeout=20

Wait For Location Report Message AOI With 8 Items Cell3
    [Arguments]    ${number_of_messages}=1
    Verify Tcpdump Log
    ...    packet_filter=${NGAP_LOCATION_REPORT}&&${UE_PRESENCE_IN_AOI_IE}&&${NGAP_CELLIDENTITY_3}&&${PLMN}&&${TAC_200}&&${AOI_LiSt}
    ...    number_of_messages=${number_of_messages}    timeout=20

Trigger RRC Resume
    [Arguments]    ${ue_id}
    Execute Egate Command
    ...    cmd=ue_nr_rrc_resume id=${ue_id}

Trigger UE Assistance
    [Arguments]    ${ue_id}
    Execute Egate Command
    ...    cmd=ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=inactive
    ...    pass_regexp=UE.: Is INACTIVE

Trigger RRCResume Procedure For UE${ue_id} By Running DL Traffic Towards NRCELL-${cell_id} PDU${pdu_id}
    Set Parameters For UE RRC Resume Request    ue_id=${ue_id}    gnb_id=2    cell_nr=${cell_id}    msg=resume_request_1    cause=mt_Access
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=1 trf_id=1    timeout=10
    ...                      pass_regexp=UE${ue_id}: UE performed resume procedure

Establish PDU With Gateway-${gw_id} And Wait For Inactive State For UE${ue_id}
    Set Internal Traffic Type For Ue    ue=${ue_id}    pdu=1
    Establish PDU Session    ue_id=${ue_id}    pdu_id=1    gw_id=${gw_id}
    ...                      pass_regexp=UE${ue_id}: Is INACTIVE

Trigger RRCResume And Wait For Inactive State For UE${ue_id}
    Set Parameters For UE RRC Resume Request    ue_id=${ue_id}    gnb_id=2    cell_nr=2    msg=resume_request_1    cause=mt_Access
    Execute egate command    cmd=ue_nr_rrc_resume id=${ue_id}    timeout=11
    ...                      pass_regexp=UE${ue_id}: Is INACTIVE

Send Location Report For UE${ue_id} And Perfrom Intra-eNB HO Without Display Option
    UE Send Location Reporting Control    ue=${ue_id}    event_type=direct    timeout=4
    ...                      pass_regexp=UE${ue_id}: UE performed resume procedure
    Execute egate command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 phycell_id=50 nrsrp_nr=40 srsrp_nr=30
    ...                      pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
    ...                      timeout=4

Trigger Drop Action In RRC Resume Message For UE${ue_id:\d+}
    Execute egate command    cmd=ue_rrc_resume_param id=${ue_id} if_contains=any action=drop

Verify AreaCodeList Contains Correct AreaCode1
    [Arguments]    ${number_of_messages}=1
    Verify Tcpdump Log    packet_filter=${AREACODE_1}    number_of_messages=${number_of_messages}

Verify AreaCodeList Contains Correct AreaCode2
    [Arguments]    ${number_of_messages}=1
    Verify Tcpdump Log    packet_filter=${AREACODE_2}    number_of_messages=${number_of_messages}

Kill Ue
    [Arguments]    ${id}
    Execute Egate Command    cmd=ue_kill id=${id}

Trigger Location Reporting
    [Arguments]  ${ue_id}  ${event_type}
    Execute Egate Command
    ...  cmd=ue_send_location_reporting_control ue=${ue_id} event_type=${event_type}
    ...  timeout=3
