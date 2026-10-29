*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Maciej Madej - <maciej.madej@nokia.com>
...      == MAINTAINER ==
...      - Maciej Madej - <maciej.madej@nokia.com>

Resource    ../../resources/former_devkr/ssh.robot
Resource    ../../../resources/Robot/common_settings.robot
Library     ../../../resources/Python/traffic_verify.py
Library     ../../CB008490/resources/syslog_collector.py
Library     ../../CB008490/resources/CB008490_counters.py
Library     ../../CB008490/resources/CB008490_message_verificators.py
Library     taf.ul.ue.sim.env_setup
Library     taf.sbts.oam.coam.admin      WITH NAME    coam
Library     taf.transport.ssh  WITH NAME  ssh

# Verifiers FROM 8717
Resource    ../../CB008490/resources/CB008717-verify_RRC.robot
Resource    ../../CB008490/resources/CB008717-verify_UEContextSetup.robot
Resource    ../../CB008490/resources/CB008717-get_and_verify_occurence_time.robot
Library     ../../CB008490/resources/message_verifiers.py

# Verifiers NEW 8490
Resource    ../../CB008490/resources/CB008490-verify_SNodeAddition.robot
Resource    ../../CB008490/resources/CB008490-verify_BearerContextSetup.robot
Resource    ../../CB008490/resources/CB008490-verify_UEContextSetup.robot
Resource    ../../CB008490/resources/CB008490-verify_XnUAddressIndication.robot
Resource    ../../CB008490/resources/CB008490-verify_SNStatusTransfer.robot
Resource    ../../CB008490/resources/CB008490-verify_RRC.robot
Resource    ../../CB008490/resources/CB008490-verify_SNodeReconfigurationComplete.robot
Resource    ../../CB008490/resources/CB008490-verify_BearerContextModification.robot
Resource    ../../CB008490/resources/CB008490-verify_BearerContextInactivityNotification.robot
Resource    ../../CB008490/resources/CB008490-verify_PDUSessionResourceModifyIndication.robot
Resource    ../../CB008490/resources/CB008490-verify_PDU_and_DRBs.robot
Resource    ../../CB008490/resources/CB008490-verify_BearerContextRelease.robot
Resource    ../../CB008490/resources/CB008490-verify_NGAP_UEContextRelease.robot
Resource    ../../CB008490/resources/CB008490-verify_NGAP_InitialContextSetup.robot
Resource    ../../CB008490/resources/CB008490-verify_SNodeRelease.robot
Resource    ../../CB008490/resources/CB008490-verify_UEContextModification.robot
Resource    ../../CB008490/resources/CB008490-verify_UEContextRelease.robot
Resource    ../../CB008490/resources/CB008490-verify_Reset.robot
Resource    ../../CB008490/resources/CB008490-verify_XnAP_ActivityNotification.robot

Variables   ../../CB008490/resources/gnb_randd_parameters.py

Resource    ./CB012328-verify_RRC.robot

*** Variables ***
${CP_UE_rdDisableSDAPheaderSa}    True
${CP_RT_rdDisableSDAPheaderSa}    0x660008=1 # rdDisableSDAPheaderSa
@{SWCONFIG_FLAGS_LIST}  ${CP_RT_rdDisableSDAPheaderSa}
${encryption}    ${False}
${a4retrytimer_toleration}=    2
${ADMIN_CONNECTION}=  admin_connection
${ADMIN_CONNECTION_2}=     None
${cmd_to_block_sctp_on_f1_link_ipv4}=    iptables -t filter -A OUTPUT -p sctp --dport 38472 -j DROP
${cmd_to_block_sctp_on_f1_link_ipv6}=    ip6tables -t filter -A OUTPUT -p sctp --dport 38472 -j DROP
${cmd_to_unblock_sctp_on_f1_link_ipv4}=  iptables -t filter -D OUTPUT -p sctp --dport 38472 -j DROP
${cmd_to_unblock_sctp_on_f1_link_ipv6}=  ip6tables -t filter -D OUTPUT -p sctp --dport 38472 -j DROP


*** Keywords ***
Run Setup
    [Arguments]        ${f1ap_gNBs}=BOTH    ${sim_gNB}=False    ${LBT28167}=False    ${disable_RRC}=False
    copy_iphy_packet_lua
    Log To Console    Setup started
    Setup emss    node_id=1
    Setup emss    node_id=2
    # Use emss to connect to gnb2 (node_id=1) and gnb3 (node_id=2) to setup parameters using Configure Keyword or yaml files
    ${run_update}    get variable value      ${configure}    "True"    # do not ever change that line!

    Run Keyword if   ${run_update} != ${False}
    ...    Prepare TL with config files    ${sim_gNB}    ${LBT28167}

    Setup egate  egate_port=20000  alias=default
    Setup devices aliases    ${disable_RRC}

    Run Keyword if  '${f1ap_gNBs}' == 'BOTH' or '${f1ap_gNBs}' == 'MN'
    ...    Enable internal mirroring for alias  gNB2
    Run Keyword if  '${f1ap_gNBs}' == 'BOTH' or '${f1ap_gNBs}' == 'SN'
    ...    Enable internal mirroring for alias  gNB3

Prepare TL with config files
     [Arguments]    ${sim_gNB}    ${LBT28167}
     Log To Console    Configure ENV with SCFC/AP.xml/LUA
     Run Keyword if  '${sim_gNB}' == 'False' or '${sim_gNB}' == 'SN'
     ...    Add gnb configuration    host_id=1    scfc=${SCF_gnb2_MN}    rad_params=0x89008e=0
     Run Keyword if  '${sim_gNB}' == 'MN'
     ...    Add gnb configuration    host_id=1    scfc=${SCF_gnb3_SN}
     Run Keyword if  '${sim_gNB}' == 'False' and '${LBT28167}' == 'False'
     ...    Add gnb configuration    host_id=2    scfc=${SCF_gnb3_SN}
     Run Keyword if  '${sim_gNB}' == 'False' and '${LBT28167}' == 'True'
     ...    Add gnb configuration    host_id=2    scfc=${SCF_gnb3_SN}    rad_params=0x5902D8=1
     Add simulator  sim_type=airphone  config=${AP_XML}
     Add 5gc  config=${LUA_CFG}  edaemon_ports=10000
     Configure environment       rmod_detection_timeout=420s    validate_gnb=False
     Log To Console    After Configure ENV

Setup devices aliases
    [Arguments]    ${disable_RRC}
    Run Keyword if  '${disable_RRC}' == 'False'
    ...    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.4
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Wait ${timeout}s for cells [${cells_ids}] ${cellState} change to ${expected_states}
    [Documentation]
    ...  Possible cellState values to check in file:
    ...  testsuite/Krakow/RRM/resources/Python/admin_cli.py
    ...  For example: energySavingState | availabilityStatus | operationalState | administrativeState

    Wait Until Keyword Succeeds  ${timeout}s  5s
    ...  Check for cells [${cells_ids}] if ${cellState} equals ${expected_states}

Set ${MO}-${MO_id}.${parameter} to ${value} on bts-${bts_id}
    Configure  {'MOC': '${MO}', 'ID': '${MO_id}', '${parameter}': '${value}'}    bts_id=${bts_id}

Modify NRHOIF-${nrhoif_id:\d+} ${parameter} to ${value}
    Configure  {'MOC': 'NRHOIF', 'ID': '1-${nrhoif_id}', '${parameter}': '${value}'}

Trigger Radio Link Failure for UE${ue_id:\d+}
    Execute egate command   cmd=rlf_testmode_nr profile_id=1 num_stop_csi_report=2000 num_stop_dlharq_tx=3000
    Execute egate command   cmd=ue_testmode_set_nr id=${ue_id} testmode=rlf action=activate profile_id=1

Lock NG-C link to AMF${amf_id:\d+}
    Log to console     Lock NG-C link for AMF${amf_id}
    Configure   {'MOC': 'SERVEDAMF', 'ID': '${amf_id}', 'administrativestate': 'Locked'}    bts_id=1

Unlock NG-C link to AMF${amf_id:\d+}
    Log to console     Unlock NG-C link for AMF${amf_id}
    Configure   {'MOC': 'SERVEDAMF', 'ID': '${amf_id}', 'administrativestate': 'Unlocked'}    bts_id=1

Trigger UE${ue_id:\d+} to send RRC ULInformationTransfer
    Execute egate command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=6

Set expected message flows for UE${ue_id:\d+} Release due to AMF reselection failure, SN gNB${sn_gnb_id:\d+}
    Set expected message flows for UE${ue_id} Release due to RLF, SN gNB${sn_gnb_id}

Verify expected message flows for UE${ue_id:\d+} Release due to AMF reselection failure, SN gNB${sn_gnb_id:\d+}
    Verify expected message flows for UE${ue_id} Release due to RLF, SN gNB${sn_gnb_id}

Trigger GTP-U Error for UE${ue_id:\d+}, pdu=${pdu_id:\d+}, qfi=${qfi_id:\d+} from gNB${gnb_id:\d+}
    Execute egate command    cmd=gnb_ue_xn_inject_error_ind ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} id=${gnb_id}

Set parameter for AMF${amf_id:\d+} to respond with ERROR INDICATION in UE CONTEXT RELEASE REQUEST for UE${ue_id:\d+}
    Execute egate command    cmd=amf_ue_ctx_release_param id=${amf_id} ue=${ue_id} action=error_indication
    Sleep  2

Configure ue_history for UE${ue_id:\d+} to enable handovers from gNB${gnb_id:\d+}
    ${command_source_gnb}    Catenate    ue_history_information_list_add_ngran id=1 gnb_id=${gnb_id} cell_type=medium
    ...                      nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command
    ...     cmd=${command_source_gnb}
    ${command_target_gnb}    Catenate    ue_history_information_list_add_ngran id=1 gnb_id=2 cell_type=medium
    ...                      nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command
    ...     cmd=${command_target_gnb}
    Execute egate command
    ...    cmd=ue_history_information_list id=1 action=commit
    Execute egate command
    ...    cmd=ue_enb_param id=${ue_id} ue_history_list=1

### UE keywords: -------------------------
Attach UE${ue_id:\d+} without ICS to MN gNB2 NRCELL-${cell_id:\d+}
    Attach UE${ue_id} without ICS to gNB2 cell${cell_id}

UE${ue_id:\d+} has experienced RLF and sends RRC Reestablishment Request
    Execute egate command    cmd=gnb_ue_rrc_reestablish_param ue=${ue_id} gnb_id=2 action=rrcreestablishment
    Sleep  2
    Execute egate command    cmd=ue_rrc_reestablish id=${ue_id}

Attach UE${ue_id:\d+} with QoS flow with higher ARP priority
    Attach UE${ue_id} without ICS to gNB2 cell2
    Execute egate command  cmd=smf_param id=1 additional_qosflows_to_activate=6
    Add to UE${ue_id} initial PDU session with ICS
    Execute egate command  cmd=smf_param id=1 reset

# Same as in file: CB008717-indexToRFSP.robot line: 16
Add to UE${ue_id:\d+} initial PDU session with ICS and indexToRFSP equal ${indexToRSFP}
    EXPECT FLOW[timeout=2]: AMF1 NGAP pDUSessionResourceSetup
    Expect message flow
    ...    AMF1:NGAP_InitialContextSetupRequest as ICSRequest
    ...    alias=ICS
    ...    overall_timeout=10
    Run Keyword if   ${encryption} == ${False}
    ...    Run Keywords
    ...    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    ...    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    Execute egate command  cmd=amf_ue_ics_param id=1 ue=${ue_id} indexToRFSP=${indexToRSFP}

    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Run keyword and continue on failure
    ...     Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=1 ue=${ue_id}
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=1 using PDU Gateway ID

    FAIL FLOW[timeout=2]: AMF1 NGAP pDUSessionResourceSetup
    Flow occurred as expected       alias=ICS
    Run Keyword if   ${encryption} == ${False}
    ...    Run Keywords
    ...    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    ...    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    Verify that AMF1 NGAP InitialContextSetup contains indexToRSFP equal ${indexToRSFP}

Add to UE${ue_id:\d+} initial PDU session on sim gNB with ICS and indexToRFSP equal ${indexToRSFP}
    Execute egate command  cmd=amf_ue_ics_param id=1 ue=${ue_id} indexToRFSP=${indexToRSFP}

    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Run keyword and continue on failure
    ...     Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${current_gw_id} nwslice=1
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=1 using PDU Gateway ID
    ${current_gw_id}     Evaluate  ${current_gw_id} + 1
    Set Test Variable    ${current_gw_id}

# Same as in file: CB008717-common_keywords.robot line: 285
UE${ue_id:\d+} sends A4 measurement with id=${measurement_id} for NR-DC PSCell addition
    Run Keyword if   ${encryption} == ${False}
    ...    EXPECT FLOW[timeout=3]: UE_${ue_id} NR-RRC MeasurementReport

    ${command}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measurement_id} event=A4 srsrp_nr=19 srsrq_nr=10
    ...                       phycell_id=52 nrsrp_nr=85 nrsrq_nr=31 index=0 nrs_result=30:30:0

    Execute egate command
    ...     cmd=${command}

    Run Keyword if   ${encryption} == ${False}
    ...    Run Keywords
    ...    PASS FLOW[timeout=3]: UE_${ue_id} NR-RRC MeasurementReport
    ...    Verify that MeasurementReport contains measurement results of PSCell for UE${ue_id}

UE${ue:\d+} sends A4 measId=${meid:\d+} with CELL-${c1:\d+}: rsrp1=${rp1:\d+} rsrq1=${rq1:\d+} and CELL-${c2:\d+}: rsrp2=${rp2:\d+} rsrq2=${rq2:\d+}
    ${pci1}    Get From Dictionary    ${NRCELL_ID_TO_PHYSCELL_ID}   ${c1}
    ${pci2}    Get From Dictionary    ${NRCELL_ID_TO_PHYSCELL_ID}   ${c2}

    EXPECT FLOW[timeout=10]: UE_${ue} NR-RRC MeasurementReport

    ${command}    Catenate    ue_measurement_send_nr id=${ue} meas_id=${meid} event=A4 srsrp_nr=19 srsrq_nr=10
    ...                       phycell_id=${pci1} nrsrp_nr=${rp1} nrsrq_nr=${rq1}
    ...                       phycell_id=${pci2} nrsrp_nr=${rp2} nrsrq_nr=${rq2}

    Execute egate command
    ...     cmd=${command}

    PASS FLOW[timeout=10]: UE_${ue} NR-RRC MeasurementReport

UE${ue_id:\d+} sends A4 measurement with id=${measurement_id} and PCIs [${PCIs}]
    @{PCI_list}    Split To List    ${PCIs}
    ${nrsrp}       Set Variable     90
    ${nrsrq}       Set Variable     32
    ${command}     Set Variable     ue_measurement_send_nr id=${ue_id} meas_id=${measurement_id} event=A4 srsrp_nr=19 srsrq_nr=10

    FOR    ${PCI}    IN    @{PCI_list}
        ${command}    Catenate    ${command}    phycell_id=${PCI} nrsrp_nr=${nrsrp} nrsrq_nr=${nrsrq}
        ${nrsrp}      Evaluate    ${nrsrp} - 1
        ${nrsrq}      Evaluate    ${nrsrq} - 1
    END

    Run Keyword if   ${encryption} == ${False}
    ...    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport

    Execute egate command
    ...     cmd=${command}

    Run Keyword if   ${encryption} == ${False}
    ...    Run Keywords
    ...    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport
    ...    Verify that MeasurementReport contains measurement results of PSCell with PCIs [${PCIs}] for UE${ue_id}

UE${ue_id:\d+} sends A2 measurement with id=${measurement_id} for redirection
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport

    ${command}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measurement_id} event=A2 srsrp_nr=4 srsrq_nr=4
    ...                       phycell_id=50 nrsrp_nr=34 nrsrq_nr=34

    Execute egate command
    ...     cmd=${command}

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport

UE${ue_id:\d+} sends A4 measurement with target cells [${target_cells}] for NR-DC PSCell addition with sim MN
    Execute Egate Command    cmd=gnb_ue_nrdc_start ue=${ue_id} target_gnb=3 target_cells=${target_cells} target_pdu_id_list=1


# Same as in file: CB008717-indexToRFSP.robot line: 42
Verify that AMF${amf_id:\d+} NGAP InitialContextSetup contains indexToRSFP equal ${indexToRSFP}
    Log  Verify that AMF${amf_id} NGAP InitialContextSetup contains indexToRSFP equal ${indexToRSFP}
    Verify That Message Fulfills Query
    ...     (IndexToRFSP is present)
    ...     message_alias=ICSRequest
    ...     flow_alias=ICS

    Verify That Message Fulfills Query
    ...     (IndexToRFSP eq ${indexToRSFP})
    ...     message_alias=ICSRequest
    ...     flow_alias=ICS

Set indexToRFSP for UE${ue_id:\d+} to ${indexToRSFP:\d+} using DL NAS Transport message
    EXPECT FLOW[timeout=10]: AMF1 NGAP downlinkNASTransport
    Execute egate command  cmd=amf_dl_nas_transport_param id=1 ue=${ue_id} indexToRFSP=${indexToRSFP}
    Execute egate command  cmd=ue_send_dl_nas_transport id=${ue_id}
    PASS FLOW[timeout=10]: AMF1 NGAP downlinkNASTransport

Verify that gNB2 forwards UECapabilities received from UE${ue_id:\d+} to AMF1
    ${flow_alias_capa_info}=     Get flow name
    ...     UECapabilityInformation
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${flow_alias_capa_info_ind}=     Get flow name
    ...     UERadioCapabilityInfoIndication
    ...     device=AMF1
    ...     protocol=NGAP

    compare_field_between_two_messages
    ...    msg1=UECapabilityInformation
    ...    msg1_flow=${flow_alias_capa_info}
    ...    msg2=UERadioCapabilityInfoIndication
    ...    msg2_flow=${flow_alias_capa_info_ind}
    ...    field=ue-CapabilityRAT-Container

Set security indication to ${option:required|preferred|(not needed)} on AMF
    ${option}=    Set variable if    '${option}'=='not needed'    not_needed    ${option}
    Execute egate command    cmd=smf_param id=1 security_indication=pdu_session_setup:${option}:required max_data_rate=1gbps

${option:Activate|Deactivate} UPIP in SN gNB
    Run keyword if    '${option}'=='Deactivate'
    ...    Configure    {'MOC': 'NRBTS', 'ID': '3', 'actUplaneIntegrityProtection': 'deactivated'}  bts_id=2
    Run keyword if    '${option}'=='Activate'
    ...    Configure    {'MOC': 'NRBTS', 'ID': '3', 'actUplaneIntegrityProtection': 'SA'}  bts_id=2
    Wait Until Keyword Succeeds  300s  10s
    ...    Object attributes should be    NRCELL-2    operationalState=enabled    bts_id=2

Change RandD parameters in ${RandDParametersFile}
    [Documentation]     ${RandDParametersFile} param value must be the same as python variable name in
    ...                 testsuite/Krakow/RRM/Airphone/CB008490/resources/gnb_randd_parameters.py

    ${CP_UE_TXZ_FILE} =     Get file name    ${RandDParametersFile}    gNB_CLASSICAL_OAM
    Extract file    ${CP_UE_TXZ_FILE}    ${RandDParametersFile}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdDisableSDAPheaderSa    ${CP_UE_rdDisableSDAPheaderSa}    gNB_CLASSICAL_OAM

    Compress and crasign RandD parameters file   ${CP_UE_TXZ_FILE}    ${RandDParametersFile}    gNB_CLASSICAL_OAM

Change RandD parameters common keyword
    ${results}=      Create List

    @{status_msg}=      Run Keyword And Ignore Error   Change RandD parameters in CPUE_addons_snowfish
    Append to list     ${results}      ${status_msg[0]}
    @{status_msg}=      Run Keyword And Ignore Error   Change RandD parameters in CPUE_addons_xeon
    Append to list     ${results}      ${status_msg[0]}
    @{status_msg}=      Run Keyword And Ignore Error   Change RandD parameters in CPUE_addons_marlin
    Append to list     ${results}      ${status_msg[0]}
    ${pass_results}=        count values in list    ${results}      PASS

    Should Be True  	int(${pass_results})>=int(2)    LO and MP tls should have at least 2 passes

Trigger intra-gNB inter-cell HO to NRCELL-${cell_id:\d+} for UE${ue_id:\d+}
    ${pci} =    Evaluate    ${49} + ${cell_id}

    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    Execute egate command
    ...    cmd=ue_ho_nr ue_id=${ue_id} tgt_phycell_id=${pci} meas_type=A3 tgt_cell_ssb_frequency=633312
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Wait for NRDC A4 activation and get measID for UE${ue_id:\d+} and NRCELL freq=${cell_freq:\d+}
    ${meas_id}=  Wait until keyword succeeds    20s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL freq=${cell_freq} for UE${ue_id}
    [Return]  ${meas_id}

Get measId matching reportConfig and measObjectId with ${event_id} and NRCELL freq=${cell_freq:\d+} for UE${ue_id:\d+}
    get_active_measurements     UE_${ue_id}         enable_logging=${True}
    ${report_id}=    Get reportConfigId field value from reportConfig with (${event_id} is present) for UE_${ue_id}
    ${meas_object_id}=    Get measObjectId field value from measObject with (ssbFrequency eq ${cell_freq}) for UE_${ue_id}
    ${check_conditions}=     Run Keyword and ignore error
    ...     Get measId field value from measId with ((reportConfigId eq ${report_id}) and (measObjectId eq ${meas_object_id})) for UE_${ue_id}
    Run keyword if  'FAIL' in ${check_conditions}
    ...     Run keywords
    ...     wait_for_next_measurement    ue_alias=UE_${ue_id}
    ...     AND   get_active_measurements     UE_${ue_id}         enable_logging=${True}
    ${meas_id}=   Get measId field value from measId with ((reportConfigId eq ${report_id}) and (measObjectId eq ${meas_object_id})) for UE_${ue_id}
    [Return]        ${meas_id}

Prepare NrDc UE${ue_id:\d+} candidate with 1 PDU sessions with 1 non-GBR and 1 signalling QoS Flow on NRCELL-${cell_id:\d+}
    Attach UE1 without ICS to MN gNB2 NRCELL-${cell_id}
    Add to UE${ue_id} initial PDU session with ICS and indexToRFSP equal 1
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [5] and delete QoS flows with 5QI from list []

    Execute egate command
    ...     cmd=amf_param id=1 empty_pdu_session_list=off send_ics_registration=off

    Execute egate command
    ...     cmd=smf_param id=1 reset

    Trigger UE${ue_id} to enter idle mode

    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    Trigger UE${ue_id} idle mode exit
    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetup

    Trigger UE${ue_id} to enter idle mode

Trigger UE${ue_id:\d+} idle mode exit
    Execute egate command
    ...   cmd=ue_im_exit id=${ue_id}

Trigger UE${ue_id:\d+} to enter idle mode
    Execute egate command
    ...   cmd=ue_im_entry id=${ue_id} by=ue
    Sleep  3

Reset QoS Flow settings on SMF
    Execute egate command  cmd=smf_param id=1 reset

Set indexToRFSP to ${indexToRSFP:\d+} for UE${ue_id:\d+}
        Execute egate command  cmd=amf_ue_ics_param id=1 ue=${ue_id} indexToRFSP=${indexToRSFP}

Set MRL with NR restricted as secondary RAT
    ${command}    Catenate    amf_mobility_restriction_list_param id=1 restricted_plmn=311:489 restricted_rat=nr
    ...                       extended_primary_rat=00000000 extended_secondary_rat=01000000

    Execute egate command
    ...     cmd=${command}
    Sleep    1

    Execute egate command
    ...   cmd=amf_ue_ics_param id=1 mobility_restriction_list_id=1
    Sleep    1

${option:Activate|Deactivate} CB008490 FAF on NRCELL-${cell_id}
    Run keyword if    '${option}'=='Deactivate'
    ...    Configure    {'MOC': 'NRCELL', 'ID': '${cell_id}', 'actNrDualConnectivity': 'disabled'}    bts_id=1
    Run keyword if    '${option}'=='Activate'
    ...    Configure    {'MOC': 'NRCELL', 'ID': '${cell_id}', 'actNrDualConnectivity': 'inter-gNB_FR1-FR2'}    bts_id=1

Add QoS flows with 5QI from list [${qos_add}] from NRDC splitted PDU${pdu_id} at UE${ue_id} and expect TakeBack occured
    @{qos_to_add_list}=   Split To List       ${qos_add}
    ${length_of_qos_to_add_list}=  Get length    ${qos_to_add_list}

    ${qos_ids_add}=    Set Variable

    ${mapping}=    get variable value           ${USER_5QI_TO_EGATE_QOS_FLOW_ID}

    FOR  ${5qi}  IN  @{qos_to_add_list}
        ${qos_flow_id}    Get From Dictionary    ${mapping}   ${5qi}
        ${qos_ids_add}=   Add To String    ${qos_ids_add}    ${qos_flow_id}
    END

    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    Run Keyword if   ${encryption} == ${False}
    ...    Run Keywords
    ...    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    ...    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_ids_add} by=ue

    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify

    Run Keyword if   ${encryption} == ${False}
    ...    Run Keywords
    ...    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    ...    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

    Verify in NGAP that QoS flows for 5QIs [${qos_add}] were successfully added to PDU${pdu_id} session

    Run Keyword if   ${encryption} == ${False}
    ...    Verify RRCReconfiguration in takeback    ${ue_id}    ${length_of_qos_to_add_list}

Verify RRCReconfiguration in takeback
    [Arguments]        ${ue_id}    ${length_of_qos_to_add_list}
    ${flow_alias_rrc}=     Get flow name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (mrdc-SecondaryCellGroupConfig contains (release is present))
    ...     message_alias=RRCReconfiguration_1
    ...     flow_alias=${flow_alias_rrc}

    Verify That Message Fulfills Query
    ...     (length(drb-ToAddModList) eq ${length_of_qos_to_add_list})
    ...     message_alias=RRCReconfiguration_2
    ...     flow_alias=${flow_alias_rrc}

Setup Xn link between sim gNB${sim_gnb_id:\d+} and real gNB${real_gnb_id:\d+}
    Execute egate command
    ...   cmd=gnb_xn_link_up gnb=${sim_gnb_id} target=${real_gnb_id}
    ...   pass_regexp=GNB-${sim_gnb_id}: XnAP Link with GNB-${real_gnb_id} .* is up
    sleep  3

Trigger UE${ue_id:\d+} XN HO with RRC Reestablishment from simulated gNB4 cell1 to real gNB2 NRCELL-${cell_id:\d+}
    ${pci} =    Evaluate    ${49} + ${cell_id}

    EXPECT FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 XNAP sNStatusTransfer
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCSetup

    Execute egate command
    ...    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=reestablish gnb=2 cell=${cell_id} cause=handoverFailure
    ...    crnti=source nth=1 num_reestablishment_reqs=1
    Sleep  1
    Execute egate command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=18 phycell_id=${pci} nrsrp_nr=85
    Sleep  1

    PASS FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 XNAP sNStatusTransfer
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCSetup

Trigger UE${ue_id:\d+} XN HO to gNB2 NRCELL-${cell_id:\d+}
    ${pci} =    Evaluate    ${49} + ${cell_id}
    ${tgt_freq} =    get_enb_parameter_value    NRCELL-${cell_id}    nrarfcn    bts_id=1

    EXPECT FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 XNAP sNStatusTransfer
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    Execute egate command
    ...    cmd=ue_ho_nr ue_id=${ue_id} tgt_phycell_id=${pci} meas_type=A3 tgt_cell_ssb_frequency=640032
    Sleep  1

    PASS FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 XNAP sNStatusTransfer
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Trigger UE${ue_id:\d+} XN HO to gNB2 NRCELL-${cell_id:\d+} without A4 installation
    ${pci} =    Evaluate    ${49} + ${cell_id}
    ${tgt_freq} =    get_enb_parameter_value    NRCELL-${cell_id}    nrarfcn    bts_id=1

    EXPECT FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 XNAP sNStatusTransfer
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest
    EXPECT FLOW[timeout=3]: UE_${ue_id} NR-RRC RRCReconfiguration

    Execute egate command
    ...    cmd=ue_ho_nr ue_id=${ue_id} tgt_phycell_id=${pci} meas_type=A3 tgt_cell_ssb_frequency=640032
    Sleep  1

    PASS FLOW[timeout=10]: gNB2 XNAP handoverPreparation
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 XNAP sNStatusTransfer
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest
    FAIL FLOW[timeout=3]: UE_${ue_id} NR-RRC RRCReconfiguration

Trigger reestablishment for UE${ue_id:\d+} to gNB${gnb_id:\d+} NRCELL-${cell_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    EXPECT FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    Execute egate command    cmd=ue_rrc_reestablish id=${ue_id} gnb=${gnb_id} cell=${cell_id}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    PASS FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[TIMEOUT=15]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Attach UE${ue_id:\d+} to sim gNB${gnb_id:\d+} cell${cell_id:\d+} with PDU session and indexToRFSP equal ${indexToRSFP:\d+}
    Execute egate command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute egate command    cmd=amf_ue_ics_param id=1 ue=${ue_id} indexToRFSP=${indexToRSFP}
    Execute egate command    cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Execute egate command    cmd=ue_register id=${ue_id}
    ...  pass_regexp=Received REGISTRATION COMPLETE
    Execute egate command    cmd=ue_pdu_session_setup pdu=1 ue=${ue_id}
    ...    pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=1 using PDU Gateway ID=
    sleep    3

Prepare RRC Reestablishment during XN HO from gNB${gnb_id:\d+} for UE${ue_id:\d+}
    Log    Prepare RRC Reestablishment during XN HO from gNB${gnb_id} for UE${ue_id}
    Execute egate command
    ...    cmd=gnb_param id=${gnb_id} ciphering_algorithm=nea0 integrityprotection_algorithm=nia2 srb1_rlc_sn_field_size=size_12
    ${command}    Catenate    gnb_xn_handover_preparation_param id=${gnb_id} include_security_config=true sec_config_nea=nea0
    ...                      sec_config_nia=nia2 reestab_info=1:valid
    Execute egate command
    ...     cmd=${command}
    Execute egate command
    ...     cmd=gnb_param id=${gnb_id} sa_ho=xn_based
    Sleep    2

Verify that UE${ue_id:\d+} is configured with ${bwp_type} BWP profile after inter-gNB HO to NRCELL-${cell_id}
    Should match regexp  ${bwp_type}  large|second|small
    ${rrc_bwp}=    Get BWP fields in RRC for NRCELL-${cell_id}

    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (
    ...         downlinkBWP-ToAddModList contains (locationAndBandwidth eq ${rrc_bwp}[loc_and_bw_dl_${bwp_type}])
    ...     )
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

    Run keyword if   "${bwp_type}" != "large"
    ...     Verify That Message Fulfills Query
    ...     spCellConfigDedicated contains (
    ...         downlinkChannelBW-PerSCS-List contains (carrierBandwidth eq ${rrc_bwp}[rb_dl_${bwp_type}])
    ...         and
    ...         downlinkChannelBW-PerSCS-List contains (offsetToCarrier eq ${rrc_bwp}[offset_dl_${bwp_type}])
    ...     )
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Connect to ${gnb_type:MN|SN} gNB
    Run Keyword if   '${gnb_type}' == 'MN'
    ...    ssh.connect_to    hostname=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    alias=MN

    Run Keyword if   '${gnb_type}' == 'SN'
    ...    ssh.connect_to    hostname=10.0.1.4    username=toor4nsn    password=oZPS0POrRieRtu    alias=SN

${option:Drop|Restore} F1 SCTP connection on ${gnb_type:SN|MN} gNB
    ${cmd_ipv4}=    Set variable if    '${option}'=='Drop'   ${cmd_to_block_sctp_on_f1_link_ipv4}   ${cmd_to_unblock_sctp_on_f1_link_ipv4}
    ${cmd_ipv6}=    Set variable if    '${option}'=='Drop'   ${cmd_to_block_sctp_on_f1_link_ipv6}   ${cmd_to_unblock_sctp_on_f1_link_ipv6}
    Connect to ${gnb_type} gNB
    Run Keyword if   '${gnb_type}' == 'MN'
    ...    Run Keywords
    ...    ssh.Send Command    command=${cmd_ipv4}    connection=MN    AND
    ...    ssh.Send Command    command=${cmd_ipv6}    connection=MN

    Run Keyword if   '${gnb_type}' == 'SN'
    ...    Run Keywords
    ...    ssh.Send Command    command=${cmd_ipv4}    connection=SN    AND
    ...    ssh.Send Command    command=${cmd_ipv6}    connection=SN

    sleep    1

Send XnAP Reset Request from sim MN to SN gNB${gnb_id} for UE${ue_id}
    execute egate command   cmd=gnb_link_xn_reset from=2 to=${gnb_id} cause=transport_resource_unavailable ue=${ue_id} ue_xnap_id_type=all

Configure inactivity on ${gnb_type:SN|MN} gNB: SRB=${srb}, DRB=${drb}, NotificationLevel=${notif:ue|drb}
    Run Keyword if   '${gnb_type}' == 'MN'
    ...    Run keywords
    ...    set enb parameter value    param_path=NRBTS.id                      value=2           bts_id=1    AND
    ...    set enb parameter value    param_path=activityNotificationLevelSA   value=${notif}    bts_id=1    AND
    ...    set enb parameter value    param_path=srbInactivityTimerSA          value=${srb}      bts_id=1    AND
    ...    set enb parameter value    param_path=drbInactivityTimerSA          value=${drb}      bts_id=1    AND
    ...    Configure   ${yaml_inactivity}    bts_id=1

    Run Keyword if   '${gnb_type}' == 'SN'
    ...    Run keywords
    ...    set enb parameter value    param_path=NRBTS.id                      value=3           bts_id=2    AND
    ...    set enb parameter value    param_path=activityNotificationLevelSA   value=${notif}    bts_id=2    AND
    ...    set enb parameter value    param_path=srbInactivityTimerSA          value=${srb}      bts_id=2    AND
    ...    set enb parameter value    param_path=drbInactivityTimerSA          value=${drb}      bts_id=2    AND
    ...    Configure   ${yaml_inactivity}    bts_id=2

Configure sim SN gNB${gNB_id} to send correct XNAP:SNodeAdditionRequestAcknowledge message
    execute egate command    cmd=gnb_snode_addition_request_ack_param gnb_id=${gNB_id} action=none

Configure sim SN gNB${gNB_id} to send XNAP:SNodeAdditionRequestAcknowledge ${option:with|without} mn-terminated container
    Run keyword if    '${option}'=='with'
    ...    execute egate command    cmd=gnb_snode_addition_request_ack_param gnb_id=${gNB_id} action=override_ie add_mn_terminated_ie=on
    Run keyword if    '${option}'=='without'
    ...    execute egate command    cmd=gnb_snode_addition_request_ack_param gnb_id=${gNB_id} action=override_ie add_mn_terminated_ie=off

Configure sim SN gNB${gNB_id} to send XNAP:SNodeAdditionRequestAcknowledge ${option:with|without} sn-terminated container
    Run keyword if    '${option}'=='with'
    ...    execute egate command    cmd=gnb_snode_addition_request_ack_param gnb_id=${gNB_id} action=override_ie remove_sn_terminated_ie=off
    Run keyword if    '${option}'=='without'
    ...    execute egate command    cmd=gnb_snode_addition_request_ack_param gnb_id=${gNB_id} action=override_ie remove_sn_terminated_ie=on

${action:Setup|Remove} delay before sending RRC:RRCReconfigurationComplete from UE${ue_id}
    Run keyword if    '${action}'=='Setup'
    ...    execute egate command   cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any nth=1 delay=3s
    Run keyword if    '${action}'=='Remove'
    ...    execute egate command   cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any nth=1 action=none

Configure AMF1 to send NGAP:PDUSessionResourceModifyConfirm with PDUSessionResourceFailedToModifyList for UE${ue_id}
    ${command}    Catenate    amf_ue_pdu_modify_indication_param id=1 ue=${ue_id} action=fail_qosflow_modification
    ...                       fail_qosflow_pdu_id=1 fail_qos_flow_id=1 fail_qosflow_cause=NAS_normal_release
    Execute egate command
    ...     cmd=${command}
    sleep   2

Configure AMF1 to send NGAP:PDUSessionResourceModifyConfirm without PDUSessionResourceFailedToModifyList for UE${ue_id}
    Log  Configure AMF1 to send NGAP:PDUSessionResourceModifyConfirm without PDUSessionResourceFailedToModifyList for UE${ue_id}
    Execute egate command    cmd=amf_ue_pdu_modify_indication_param id=1 reset

### SET and EXPECT FLOWS Keywords
Set expected messages flows for PDU session and A4 measurement configuration for UE${ue_id:\d+} and AMF1
    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication

    Run Keyword if   ${encryption} == ${False}
    ...    Run Keywords
    ...    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    ...    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    ...    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    ...    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Set expected messages flows for SNodeAddition for SN gNB${sn_gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparation
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP xnUAddressIndication
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNStatusTransfer
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextInactivityNotification

Set expected messages flows for SNodeAddition for MN gNB${mn_gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNGRANnodeAdditionPreparation
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP 2*uEContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP xnUAddressIndication
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNStatusTransfer
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} NGAP pDUSessionResourceModifyIndication
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextInactivityNotification

Verify expected messages flows for SNodeAddition for MN gNB${mn_gnb_id:\d+}
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNGRANnodeAdditionPreparation
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP 2*uEContextModification
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP xnUAddressIndication
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNStatusTransfer
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} NGAP pDUSessionResourceModifyIndication
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextInactivityNotification

Set expected messages flows for SNodeAddition for UE${ue_id:\d+}, MN gNB${mn_gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP 2*uEContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} NGAP pDUSessionResourceModifyIndication

    Run Keyword if   ${encryption} == ${False}
    ...    Run Keywords
    ...    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    ...    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Set expected not failed messages flows for SNodeAddition for UE${ue_id:\d+}, MN gNB${mn_gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextModificationFailure
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP errorIndication
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextModificationFailure
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP errorIndication
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP errorIndication
    Run Keyword if   ${encryption} == ${False}
    ...    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease

Verify expected not failed messages flows for SNodeAddition for UE${ue_id:\d+}, MN gNB${mn_gnb_id:\d+}
    FAIL FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextModificationFailure
    FAIL FLOW[timeout=10]: gNB${mn_gnb_id} E1AP errorIndication
    FAIL FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextModificationFailure
    FAIL FLOW[timeout=10]: gNB${mn_gnb_id} F1AP errorIndication
    FAIL FLOW[timeout=10]: gNB${mn_gnb_id} XNAP errorIndication
    Run Keyword if   ${encryption} == ${False}
    ...    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease

Set expected not failed messages flows for SNodeAddition for SN gNB${sn_gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparationFailure
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextSetupFailure
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextSetupFailure
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModificationFailure
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP errorIndication
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP errorIndication
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP errorIndication

Verify expected not failed messages flows for SNodeAddition for SN gNB${sn_gnb_id:\d+}
    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparationFailure
    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextSetupFailure
    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextSetupFailure
    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModificationFailure
    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} E1AP errorIndication
    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} F1AP errorIndication
    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} XNAP errorIndication

Set expected messages flows for TakeBack for SN gNB${sn_gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP xnUAddressIndication
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextModification

Set expected messages flows for TakeBack for MN gNB${mn_gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP 2*uEContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease

Verify expected messages flows for TakeBack for SN gNB${sn_gnb_id:\d+}
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP xnUAddressIndication
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextModification

Verify expected messages flows for TakeBack for MN gNB${mn_gnb_id:\d+}
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP 2*uEContextModification
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease

Verify expected messages flows for PDU session and A4 measurement configuration for UE${ue_id:\d+} and AMF1
    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    PASS FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication

    Run Keyword if   ${encryption} == ${False}
    ...    Run Keywords
    ...    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    ...    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    ...    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    ...    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify expected messages flows for SNodeAddition for SN gNB${sn_gnb_id:\d+}
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparation
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP xnUAddressIndication
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNStatusTransfer
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextInactivityNotification

Verify expected messages flows for SNodeAddition for UE${ue_id:\d+}, MN gNB${mn_gnb_id:\d+}
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP 2*uEContextModification
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} NGAP pDUSessionResourceModifyIndication

    Run Keyword if   ${encryption} == ${False}
    ...    Run Keywords
    ...    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    ...    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Set expected message flows for UE${ue_id:\d+} Release due to AMF${amf_id:\d+} Context Release, MN gNB${mn_gnb_id:\d+}
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextRelease
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease

Set expected message flows for UE${ue_id:\d+} Release due to AMF${amf_id:\d+} Context Release, SN gNB${sn_gnb_id:\d+}
    Log  Set expected message flows for UE${ue_id} Release due to AMF${amf_id} Context Release, SN gNB${sn_gnb_id}
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextModification
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextRelease

Verify expected message flows for UE${ue_id:\d+} Release due to AMF${amf_id:\d+} Context Release, MN gNB${mn_gnb_id:\d+}
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextRelease
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease

Verify expected message flows for UE${ue_id:\d+} Release due to AMF${amf_id:\d+} Context Release, SN gNB${sn_gnb_id:\d+}
    Log  Verify expected message flows for UE${ue_id} Release due to AMF${amf_id} Context Release, SN gNB${sn_gnb_id}
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextModification
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextRelease
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextRelease

Set expected message flows for UE${ue_id:\d+} Release due to RLF, MN gNB${mn_gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextModificationRequired
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextRelease
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease

Set expected message flows for UE${ue_id:\d+} Release due to RLF, SN gNB${sn_gnb_id:\d+}
    Log  Set expected message flows for UE${ue_id} Release due to RLF, SN gNB${sn_gnb_id}
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextModification
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextRelease

Verify expected message flows for UE${ue_id:\d+} Release due to RLF, MN gNB${mn_gnb_id:\d+}
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextModificationRequired
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextRelease
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease

Verify expected message flows for UE${ue_id:\d+} Release due to RLF, SN gNB${sn_gnb_id:\d+}
    Log  Verify expected message flows for UE${ue_id} Release due to RLF, SN gNB${sn_gnb_id}
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextModification
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextRelease
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextRelease

Set expected message flows for UE${ue_id:\d+} Release due to AMF reselection failure, MN gNB${mn_gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextRelease
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest
    EXPECT FLOW[timeout=5]: AMF1 NGAP uEContextRelease

Verify expected message flows for UE${ue_id:\d+} Release due to AMF reselection failure, MN gNB${mn_gnb_id:\d+}
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextRelease
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextRelease

Set expected message flows for UE${ue_id:\d+} Context Release due to redirection, MN gNB${mn_gnb_id:\d+} with AMF1
    Log  Set expected message flows for UE${ue_id} Context Release due to redirection, MN gNB${mn_gnb_id} with AMF1
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextRelease

Verify expected message flows for UE${ue_id:\d+} Context Release due to redirection, MN gNB${mn_gnb_id:\d+} with AMF1
    Log  Verify expected message flows for UE${ue_id} Context Release due to redirection, MN gNB${mn_gnb_id} with AMF1
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextRelease
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextReleaseRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease

Set expected message flows for UE${ue_id:\d+} Release due to GTP-U Error, MN real gNB${mn_gnb_id:\d+} and SN sim gNB3
    Set expected message flows for UE${ue_id} Release due to RLF, MN gNB${mn_gnb_id}

Verify expected message flows for UE${ue_id:\d+} Release due to GTP-U Error, MN real gNB${mn_gnb_id:\d+} and SN sim gNB3
    Verify expected message flows for UE${ue_id} Release due to RLF, MN gNB${mn_gnb_id}

Verify expected message flows for UE${ue_id:\d+} Release due to GTP-U Error, MN gNB${mn_gnb_id:\d+}
    PASS FLOW[timeout=30]: gNB${mn_gnb_id} XNAP uEContextRelease
    PASS FLOW[timeout=30]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=30]: gNB${mn_gnb_id} F1AP uEContextRelease
    PASS FLOW[timeout=30]: gNB${mn_gnb_id} E1AP bearerContextRelease
    PASS FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCRelease
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextReleaseRequest
    FAIL FLOW[timeout=5]: AMF1 NGAP uEContextRelease

Set expected message flows for UE${ue_id:\d+} Release due to GTP-U Error, SN gNB${sn_gnb_id:\d+}
    Log  Set expected message flows for UE${ue_id} Release due to GTP-U Error, SN gNB${sn_gnb_id}
    EXPECT FLOW[timeout=30]: gNB${sn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=30]: gNB${sn_gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=30]: gNB${sn_gnb_id} F1AP uEContextModification
    EXPECT FLOW[timeout=30]: gNB${sn_gnb_id} F1AP uEContextRelease
    EXPECT FLOW[timeout=30]: gNB${sn_gnb_id} E1AP bearerContextRelease

Verify expected message flows for UE${ue_id:\d+} Release due to GTP-U Error, SN gNB${sn_gnb_id:\d+}
    Log  Verify expected message flows for UE${ue_id} Release due to GTP-U Error, SN gNB${sn_gnb_id}
    PASS FLOW[timeout=30]: gNB${sn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=30]: gNB${sn_gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=30]: gNB${sn_gnb_id} F1AP uEContextModification
    PASS FLOW[timeout=30]: gNB${sn_gnb_id} F1AP uEContextRelease
    PASS FLOW[timeout=30]: gNB${sn_gnb_id} E1AP bearerContextRelease

Set expected messages flows for A4 measurement release and DRX configuration for UE${ue_id:\d+}, MN gNB${mn_gnb_id:\d+}
    EXPECT FLOW[timeout=15]: gNB${mn_gnb_id} F1AP 4*uEContextModification
    EXPECT FLOW[timeout=15]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=15]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify expected messages flows for A4 measurement release and DRX configuration for UE${ue_id:\d+}, MN gNB${mn_gnb_id:\d+}
    PASS FLOW[timeout=15]: gNB${mn_gnb_id} F1AP 4*uEContextModification
    PASS FLOW[timeout=15]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=15]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

    Verify A4 measurement release for UE${ue_id}
    Verify DRX configuration for UE${ue_id}

Expect that A4 measurements are not configured for UE${ue_id:\d+} connected to alternative band with DRX
    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=15]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=15]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=15]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    EXPECT FLOW[timeout=15]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete

Verify that A4 measurements are not configured for UE${ue_id:\d+} connected to alternative band with DRX
    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=15]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=15]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    FAIL FLOW[timeout=15]: UE_${ue_id} NR-RRC 3*RRCReconfiguration
    FAIL FLOW[timeout=15]: UE_${ue_id} NR-RRC 3*RRCReconfigurationComplete

Set expected messages flows for SNodeAddition failed at DU for SN gNB${sn_gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparationFailure
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextSetupFailure
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextRelease

    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP xnUAddressIndication
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNStatusTransfer

Verify expected messages flows for SNodeAddition failed at DU for SN gNB${sn_gnb_id:\d+}
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparationFailure
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextSetup
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} F1AP uEContextSetupFailure
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} E1AP bearerContextRelease

    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} XNAP xnUAddressIndication
    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    FAIL FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNStatusTransfer

Set expected messages flows for SNodeAddition Reject for SN gNB${sn_gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparationFailure

    EXPECT FLOW[timeout=2]: gNB${sn_gnb_id} F1AP uEContextSetup
    EXPECT FLOW[timeout=2]: gNB${sn_gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=2]: gNB${sn_gnb_id} XNAP xnUAddressIndication
    EXPECT FLOW[timeout=2]: gNB${sn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    EXPECT FLOW[timeout=2]: gNB${sn_gnb_id} XNAP sNStatusTransfer

Verify expected messages flows for SNodeAddition Reject for SN gNB${sn_gnb_id:\d+}
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparationFailure

    FAIL FLOW[timeout=2]: gNB${sn_gnb_id} F1AP uEContextSetup
    FAIL FLOW[timeout=2]: gNB${sn_gnb_id} E1AP bearerContextSetup
    FAIL FLOW[timeout=2]: gNB${sn_gnb_id} XNAP xnUAddressIndication
    FAIL FLOW[timeout=2]: gNB${sn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    FAIL FLOW[timeout=2]: gNB${sn_gnb_id} XNAP sNStatusTransfer

Set expected messages flows to check UECapabilityEnquiry request for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication

Set expected messages flows to check UECapabilityEnquiry request did not occure for UE${ue_id:\d+}
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC UECapabilityInformation
    EXPECT FLOW[timeout=5]: AMF1 NGAP uERadioCapabilityInfoIndication

Verify that expected message flows for UECapabilityEnquiry request occured for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityInformation
    PASS FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication

Verify that expected message flows for UECapabilityEnquiry request did not occure for UE${ue_id:\d+}
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC UECapabilityEnquiry
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC UECapabilityInformation
    FAIL FLOW[timeout=5]: AMF1 NGAP uERadioCapabilityInfoIndication

Set expected messages flows for additional UECapabilityEnquiry request for UE${ue_id:\d+}
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*UECapabilityEnquiry
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*UECapabilityInformation
    EXPECT FLOW[timeout=5]: AMF1 NGAP 2*uERadioCapabilityInfoIndication

Verify expected messages flows for additional UECapabilityEnquiry request for UE${ue_id:\d+}
    PASS FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*UECapabilityEnquiry
    PASS FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*UECapabilityInformation
    PASS FLOW[timeout=5]: AMF1 NGAP 2*uERadioCapabilityInfoIndication

Fail expected messages flows for additional UECapabilityEnquiry request for UE${ue_id:\d+}
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*UECapabilityEnquiry
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*UECapabilityInformation
    FAIL FLOW[timeout=5]: AMF1 NGAP 2*uERadioCapabilityInfoIndication

Set expected messages flows for PDU session setup with A2/A3/A5 measurements and no A4 measurement configuration for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification
    EXPECT FLOW[timeout=5]: gNB2 F1AP 4*uEContextModification
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify expected messages flows for PDU session setup with A2/A3/A5 measurements and no A4 measurement configuration for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification
    FAIL FLOW[timeout=5]: gNB2 F1AP 4*uEContextModification
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Set expected messages flows for PDU session setup after ICS with A2/A3/A5 and no A4 measurement configuration for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification
    EXPECT FLOW[timeout=5]: gNB2 F1AP 4*uEContextModification
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: AMF1 NGAP initialContextSetup

Verify expected messages flows for PDU session setup after ICS with A2/A3/A5 and no A4 measurement configuration for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification
    FAIL FLOW[timeout=5]: gNB2 F1AP 4*uEContextModification
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: AMF1 NGAP initialContextSetup

Set expected messages flows to check A4 activation without DRX after HO for UE${ue_id:\d+}
     EXPECT FLOW[timeout=10]: gNB2 E1AP 3*bearerContextModification
     EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
     EXPECT FLOW[timeout=3]: UE_${ue_id} NR-RRC 3*RRCReconfiguration

Verify expected messages flows to check A4 activation without DRX after HO for UE${ue_id:\d+}
     PASS FLOW[timeout=10]: gNB2 E1AP 3*bearerContextModification
     PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
     FAIL FLOW[timeout=3]: UE_${ue_id} NR-RRC 3*RRCReconfiguration

Set expected messages flows to check A4 activation without DRX after reestablishment for UE${ue_id:\d+}
     EXPECT FLOW[timeout=12]: gNB2 E1AP 3*bearerContextModification
     EXPECT FLOW[timeout=12]: gNB2 F1AP 5*uEContextModification
     EXPECT FLOW[timeout=12]: UE_${ue_id} NR-RRC 2*RRCReconfiguration

Verify expected messages flows to check A4 activation without DRX after reestablishment for UE${ue_id:\d+}
     PASS FLOW[timeout=12]: gNB2 E1AP 3*bearerContextModification
     PASS FLOW[timeout=12]: gNB2 F1AP 5*uEContextModification
     PASS FLOW[timeout=12]: UE_${ue_id} NR-RRC 2*RRCReconfiguration

Set expected messages flows to check non NR-DC eligible PDU Session established for the UE${ue_id:\d+}
    Log  Set expected messages flows to check non NR-DC eligible PDU Session established for the UE${ue_id}
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification

Verify expected messages flows to check non NR-DC eligible PDU Session established for the UE${ue_id:\d+}
    Log  Verify expected messages flows to check non NR-DC eligible PDU Session established for the UE${ue_id}
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification

Set expected messages flows to check that A4 measurements are not installed after ICS with no NR-DC eligible PDU session setup for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify expected messages flows to check that A4 measurements are not installed after ICS with no NR-DC eligible PDU session setup for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Expect that A4 measurements are not configured after retryTimer eq ${retry_timer:\d+} expiry for UE${ue_id:\d+}
    EXPECT FLOW[timeout=${retry_timer}]: gNB2 F1AP uEContextModification
    EXPECT FLOW[timeout=${retry_timer}]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=${retry_timer}]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify that A4 measurements are not configured after retryTimer eq ${retry_timer:\d+} expiry for UE${ue_id:\d+}
    FAIL FLOW[timeout=${retry_timer}]: gNB2 F1AP uEContextModification
    FAIL FLOW[timeout=${retry_timer}]: UE_${ue_id} NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=${retry_timer}]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Expect that A4 measurements are not ${de}configured after ${timer:supervision|retry}Timer expiry for UE${ue_id:\d+}
    Log  Expect that A4 measurements are not ${de}configured after ${timer}Timer expiry for UE${ue_id}
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextModification
    Run Keyword if   ${encryption} == ${False}
    ...    Run Keywords
    ...    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    ...    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify that A4 measurements are not ${de}configured after ${timer:supervision|retry}Timer expiry for UE${ue_id:\d+}
    Log  Verify that A4 measurements are not ${de}configured after ${timer}Timer expiry for UE${ue_id}
    FAIL FLOW[timeout=10]: gNB2 F1AP uEContextModification
    Run Keyword if   ${encryption} == ${False}
    ...    Run Keywords
    ...    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    ...    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Set expected messages flow for A4 measurements ${de}configuration after ${timer:supervision|retry}Timer expiry for UE${ue_id:\d+}
    Log  Set expected messages flow for A4 measurements ${de}configuration after ${timer}Timer expiry for UE${ue_id}
    EXPECT FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification
    Run Keyword if   ${encryption} == ${False}
    ...    Run Keywords
    ...    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    ...    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify expected messages flow for A4 measurements ${de}configuration after ${timer:supervision|retry}Timer expiry for UE${ue_id:\d+}
    Log  Verify expected messages flow for A4 measurements ${de}configuration after ${timer}Timer expiry for UE${ue_id}
    PASS FLOW[timeout=10]: gNB2 F1AP 2*uEContextModification
    Run Keyword if   ${encryption} == ${False}
    ...    Run Keywords
    ...    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    ...    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Expect that A4 measurements are configured after adding eligible PDU session for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Expect that A4 measurements are activated after A4 retryTimer expiry for UE${ue_id}
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify that A4 measurements are activated after A4 retryTimer expiry for UE${ue_id}
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify that A4 measurements are configured after adding eligible PDU session for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Expect that A4 measurements are configured after adding first eligible PDU session for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    EXPECT FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Expect that A4 measurements are not configured after HO for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify that A4 measurements are not configured after HO for UE${ue_id:\d+}
    FAIL FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Expect that A4 measurements are not configured after PDU session setup for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify that A4 measurements are not configured after PDU session setup for UE${ue_id:\d+}
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    FAIL FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify that A4 measurements are configured after adding first eligible PDU session for UE${ue_id:\d+}
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextSetup
    PASS FLOW[timeout=10]: gNB2 F1AP 4*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Set expected messages flows to check that A2,A3,A4,A5 measurements are not installed after ICS with no PDU session setup UE${ue_id:\d+}
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify expected messages flows to check that A2,A3,A4,A5 measurements are not installed after ICS with no PDU session setup UE${ue_id:\d+}
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Expect that A4 measurements are ignored in overload state for UE${ue_id:\d+}
    EXPECT FLOW[timeout=1]: gNB2 XNAP sNGRANnodeAdditionPreparation
    EXPECT FLOW[timeout=1]: gNB2 F1AP uEContextModification
    EXPECT FLOW[timeout=1]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=1]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify that A4 measurements are ignored in overload state for UE${ue_id:\d+}
    FAIL FLOW[timeout=1]: gNB2 XNAP sNGRANnodeAdditionPreparation
    FAIL FLOW[timeout=1]: gNB2 F1AP uEContextModification
    FAIL FLOW[timeout=1]: UE_${ue_id} NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=1]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Deregister UE${ue_id}
    execute egate command    cmd=ue_deregister id=${ue_id} by=amf

Reset Unit ${dist_name} on ADMIN ${ADMIN}
    coam.reset_unit    dist_name=${dist_name}	  reset_type=Warm    connection=${ADMIN}
    ...    timeout=600

Set expected messages flows for MN BBMOD reset for UE1, MN gNB2
    EXPECT FLOW[timeout=10]: gNB2 F1AP gNBDUConfigurationUpdate
    EXPECT FLOW[timeout=10]: gNB2 F1AP reset
    EXPECT FLOW[timeout=10]: gNB2 E1AP reset
    EXPECT FLOW[timeout=10]: gNB2 NGAP nGReset
    EXPECT FLOW[timeout=10]: gNB2 XNAP reset

Set expected messages flows for MN BBMOD reset for gNB3
    EXPECT FLOW[timeout=10]: gNB3 F1AP reset
    EXPECT FLOW[timeout=10]: gNB3 E1AP reset

Verify expected messages flows for MN BBMOD reset for UE1, MN gNB2
    PASS FLOW[timeout=10]: gNB2 F1AP gNBDUConfigurationUpdate
    PASS FLOW[timeout=10]: gNB2 F1AP reset
    PASS FLOW[timeout=10]: gNB2 E1AP reset
    PASS FLOW[timeout=10]: gNB2 NGAP nGReset
    PASS FLOW[timeout=10]: gNB2 XNAP reset

Verify expected messages flows for MN BBMOD reset for gNB3
    PASS FLOW[timeout=10]: gNB3 F1AP reset
    PASS FLOW[timeout=10]: gNB3 E1AP reset

Set expected messages flows for SN BBMOD reset for UE1, MN gNB2
    EXPECT FLOW[timeout=10]: gNB2 F1AP reset
    EXPECT FLOW[timeout=10]: gNB2 E1AP reset
    EXPECT FLOW[timeout=10]: gNB2 NGAP nGReset

Set expected messages flows for SN BBMOD reset for gNB3
    EXPECT FLOW[timeout=10]: gNB3 F1AP reset
    EXPECT FLOW[timeout=10]: gNB3 E1AP reset
    EXPECT FLOW[timeout=10]: gNB3 F1AP gNBDUConfigurationUpdate
    EXPECT FLOW[timeout=10]: gNB3 XNAP reset

Verify expected messages flows for SN BBMOD reset for UE1, MN gNB2
    PASS FLOW[timeout=10]: gNB2 F1AP reset
    PASS FLOW[timeout=10]: gNB2 E1AP reset
    PASS FLOW[timeout=10]: gNB2 NGAP nGReset

Verify expected messages flows for SN BBMOD reset for gNB3
    PASS FLOW[timeout=10]: gNB3 F1AP reset
    PASS FLOW[timeout=10]: gNB3 E1AP reset
    PASS FLOW[timeout=10]: gNB3 F1AP gNBDUConfigurationUpdate
    PASS FLOW[timeout=10]: gNB3 XNAP reset

Set expected messages flows for XN Link drop for gNB3
    EXPECT FLOW[timeout=300]: gNB3 F1AP reset
    EXPECT FLOW[timeout=300]: gNB3 E1AP reset

Set expected messages flows for XN Link drop for UE1, MN gNB2
    EXPECT FLOW[timeout=300]: gNB2 F1AP reset
    EXPECT FLOW[timeout=300]: gNB2 E1AP reset
    EXPECT FLOW[timeout=300]: gNB2 XNAP reset
    EXPECT FLOW[timeout=300]: gNB2 NGAP nGReset

Verify expected messages flows for XN Link drop for gNB3
    PASS FLOW[timeout=300]: gNB3 F1AP reset
    PASS FLOW[timeout=300]: gNB3 E1AP reset

Verify expected messages flows for XN Link drop for UE1, MN gNB2
    PASS FLOW[timeout=300]: gNB2 F1AP reset
    PASS FLOW[timeout=300]: gNB2 E1AP reset
    PASS FLOW[timeout=300]: gNB2 XNAP reset
    PASS FLOW[timeout=300]: gNB2 NGAP nGReset

Trigger UE${ue_id} reestablishment via RRC Setup
    Execute egate command    cmd=ue_rrc_reestablish id=${ue_id}

Set expected messages flows for Reestablishment due to XN Link failure for UE${ue_id}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetupComplete
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Set expected messages for NR-DC takeback after PDU session release for UE${ue_id:\d+}, MN gNB${mn_gnb_id:\d+}
    Log  Set expected messages for NR-DC takeback after PDU session release for UE${ue_id}, MN gNB${mn_gnb_id}
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNStatusTransfer
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP 3*uEContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextModification

Verify expected messages for NR-DC takeback after PDU session release for UE${ue_id:\d+}, MN gNB${mn_gnb_id:\d+}
    Log  Verify expected messages for NR-DC takeback after PDU session release for UE${ue_id}, MN gNB${mn_gnb_id}
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNStatusTransfer
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP 3*uEContextModification
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextModification
    Verify NR-DC takeback in RRCReconfiguration message for UE${ue_id}

Verify expected messages flows for Reestablishment due to XN Link failure for UE${ue_id}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetupComplete
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Set expected messages for NR-DC takeback after RRC:SCGFailureInformation from UE${ue_id:\d+}, MN gNB${mn_gnb_id:\d+}
    Log  Set expected messages for NR-DC takeback after RRC:SCGFailureInformation from UE${ue_id}, MN gNB${mn_gnb_id}
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP xnUAddressIndication
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP 2*uEContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNStatusTransfer
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} NGAP pDUSessionResourceModifyIndication

Verify expected messages for NR-DC takeback after RRC:SCGFailureInformation from UE${ue_id:\d+}, MN gNB${mn_gnb_id:\d+}
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextModification
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP xnUAddressIndication
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP 2*uEContextModification
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNStatusTransfer
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} NGAP pDUSessionResourceModifyIndication
    Verify NR-DC takeback in RRCReconfiguration message for UE${ue_id}

UE${ue_id:\d+} sends RRC:SCGFailureInformation to MN gNB${mn_gnb_id:\d+}
    Log  UE${ue_id} sends RRC:SCGFailureInformation to MN gNB${mn_gnb_id}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC SCGFailureInformation
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    Execute egate command    cmd=ue_dc_rlf ue=${ue_id} failure_type=T310_expiry

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC SCGFailureInformation
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Reset NG link for UE${ue_id} by AMF${amf_id}
    execute egate command
    ...    cmd=ng_link_reset ue=${ue_id} by=amf:${amf_id}
    ...    pass_regexp=Received NG Reset Acknowledge from GNB

Set expected messages for F1 SCTP connection drop
    EXPECT FLOW[timeout=300]: gNB2 NGAP nGReset
    EXPECT FLOW[timeout=300]: gNB2 F1AP reset
    EXPECT FLOW[timeout=300]: gNB3 XNAP reset
    EXPECT FLOW[timeout=300]: gNB4 XNAP reset
    Expect message flow
    ...    gNB2:E1AP_Reset as Reset
    ...    gNB2:E1AP_ResetAcknowledge as ResetAck
    ...    alias=E1_reset_1
    ...    overall_timeout=300

    Expect message flow
    ...    gNB2:E1AP_Reset as Reset
    ...    gNB2:E1AP_ResetAcknowledge as ResetAck
    ...    alias=E1_reset_2
    ...    overall_timeout=300

Verify expected messages for F1 SCTP connection drop
    PASS FLOW[timeout=300]: gNB2 NGAP nGReset
    FAIL FLOW[timeout=300]: gNB2 F1AP reset
    PASS FLOW[timeout=300]: gNB3 XNAP reset
    PASS FLOW[timeout=300]: gNB4 XNAP reset
    flow occurred as expected    alias=E1_reset_1
    flow occurred as expected    alias=E1_reset_2

Set expected messages for UE1 NG link reset
    EXPECT FLOW[timeout=60]: gNB2 NGAP nGReset
    EXPECT FLOW[timeout=60]: gNB2 F1AP reset
    EXPECT FLOW[timeout=60]: gNB2 E1AP reset
    EXPECT FLOW[timeout=60]: gNB3 XNAP reset
    EXPECT FLOW[timeout=60]: gNB4 XNAP reset

Verify expected messages for UE1 NG link reset
    PASS FLOW[timeout=60]: gNB2 NGAP nGReset
    PASS FLOW[timeout=60]: gNB2 F1AP reset
    PASS FLOW[timeout=60]: gNB2 E1AP reset
    PASS FLOW[timeout=60]: gNB3 XNAP reset
    FAIL FLOW[timeout=60]: gNB4 XNAP reset

Set expected message flows for UE${ue_id} reestablishment via RRC Setup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetupComplete
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify expected message flows for UE${ue_id} reestablishment via RRC Setup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetupComplete
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Set expected messages flows for F1 Link drop for gNB${gnb_id}
    EXPECT FLOW[timeout=300]: gNB${gnb_id} E1AP reset
    EXPECT FLOW[timeout=200]: gNB${gnb_id} F1AP reset

Verify expected messages flows for F1 Link drop for gNB${gnb_id}
    PASS FLOW[timeout=300]: gNB${gnb_id} E1AP reset
    FAIL FLOW[timeout=200]: gNB${gnb_id} F1AP reset

Set expected messages flows for F1 Link setup for SN gNB${gnb_id}
    EXPECT FLOW[timeout=300]: gNB${gnb_id} F1AP f1Setup
    EXPECT FLOW[timeout=300]: gNB${gnb_id} XNAP xnSetup

Verify expected messages flows for F1 Link setup for SN gNB${gnb_id}
    PASS FLOW[timeout=300]: gNB${gnb_id} F1AP f1Setup
    PASS FLOW[timeout=300]: gNB${gnb_id} XNAP xnSetup

Set expected messages flows for XN Reset for SN gNB${gnb_id}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP reset
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP reset
    EXPECT FLOW[timeout=10]: gNB${gnb_id} XNAP reset

Verify expected messages flows for XN Reset for SN gNB${gnb_id}
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP reset
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP reset
    PASS FLOW[timeout=10]: gNB${gnb_id} XNAP reset

Set expected messages flows for ${mult}BearerContextInactivityNotification for ${opt:MN|SN} gNB${gnb_id} after ${time:\d+}s
    Log  Set expected messages flows for ${mult}BearerContextInactivityNotification for ${opt} gNB${gnb_id} after ${time}s
    ${timeout} =    Evaluate    ${2} + ${time}
    ${str_timeout}=    Convert To String    ${timeout}
    EXPECT FLOW[timeout=${str_timeout}]: gNB${gnb_id} E1AP ${mult}bearerContextInactivityNotification

Verify expected messages flows for ${mult}BearerContextInactivityNotification for ${opt:MN|SN} gNB${gnb_id} after ${time:\d+}s
    Log  Verify expected messages flows for ${mult}BearerContextInactivityNotification for ${opt} gNB${gnb_id} after ${time}s
    ${timeout} =    Evaluate    ${2} + ${time}
    PASS FLOW[timeout=${timeout}]: gNB${gnb_id} E1AP ${mult}bearerContextInactivityNotification

Verify ${mult}BearerContextInactivityNotification not occurred for ${opt:MN|SN} gNB${gnb_id} after ${time:\d+}s
    Log  Verify ${mult}BearerContextInactivityNotification not occurred for ${opt} gNB${gnb_id} after ${time}s
    ${timeout} =    Evaluate    ${2} + ${time}
    FAIL FLOW[timeout=${timeout}]: gNB${gnb_id} E1AP ${mult}bearerContextInactivityNotification

Set expected message flows for UE1 Context Release without XNAP SNodeReleaseAcknowledge, MN gNB${mn_gnb_id} with AMF1
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextRelease
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextRelease

Verify expected message flows for UE1 Context Release without XNAP SNodeReleaseAcknowledge, MN gNB${mn_gnb_id} with AMF1
    FAIL FLOW[timeout=10]: gNB${mn_gnb_id} XNAP mNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP uEContextRelease
    FAIL FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextModification
    FAIL FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextModification
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP uEContextRelease
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP bearerContextRelease

Set expected messages flows for failed SNodeAddition for SN gNB${gnb_id}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} XNAP sNGRANnodeAdditionPreparationFailure

Verify expected messages flows for failed SNodeAddition for SN gNB${gnb_id}
    PASS FLOW[timeout=10]: gNB${gnb_id} XNAP sNGRANnodeAdditionPreparationFailure

Reset gNb
    coam.reset_site    timeout=${300}  connection=${ADMIN_CONNECTION}

Release UE${ue_id} initiedted by AMF with Cause:${cause}
    Execute egate command    cmd=ue_ng_ctx_release id=${ue_id} by=amf cause=${cause}

Verify A4 meauserment ${de}activation for UE${ue_id} with timeout=${tmo}s
    Set expected messages flows for A4 measurement ${de}activation for UE${ue_id} with timeout=${tmo}s
    Verify expected messages flows for A4 measurement ${de}activation for UE${ue_id} with timeout=${tmo}s
    Run keyword if    '${de}' == 'de'    Verify A4 measurement release for UE${ue_id}
    Run keyword if    '${de}' == ''    Verify A4 measurement setup for UE${ue_id}

Verify that A4 measurerment is not activated for UE${ue_id} during blockTimer running period with timeout=${tmo}s
    Set expected messages flows for A4 measurement activation for UE${ue_id} with timeout=${tmo}s
    Verify expected messages flows not occured for A4 measurement activation for UE${ue_id} with timeout=${tmo}s

Set expected messages flows for A4 measurement ${de}activation for UE${ue_id} with timeout=${tmo}s
    Log  Set expected messages flows for A4 measurement ${de}activation for UE${ue_id} with timeout=${tmo}s
    EXPECT FLOW[timeout=${tmo}]: gNB2 F1AP uEContextModification
    EXPECT FLOW[timeout=${tmo}]: UE_${ue_id} NR-RRC RRCReconfiguration

Verify expected messages flows for A4 measurement ${de}activation for UE${ue_id} with timeout=${tmo}s
    Log  Verify expected messages flows for A4 measurement ${de}activation for UE${ue_id} with timeout=${tmo}s
    PASS FLOW[timeout=${tmo}]: gNB2 F1AP uEContextModification
    PASS FLOW[timeout=${tmo}]: UE_${ue_id} NR-RRC RRCReconfiguration

Verify expected messages flows not occured for A4 measurement ${de}activation for UE${ue_id} with timeout=${tmo}s
    Log  Verify expected messages flows not occured for A4 measurement ${de}activation for UE${ue_id} with timeout=${tmo}s
    FAIL FLOW[timeout=${tmo}]: gNB2 F1AP uEContextModification
    FAIL FLOW[timeout=${tmo}]: UE_${ue_id} NR-RRC RRCReconfiguration

Release from UE${ue_id} PDU session with id=${pdu_id}
    EXPECT FLOW[timeout=2]: AMF1 NGAP pDUSessionResourceRelease
    Execute egate command  cmd=ue_pdu_session_release ue=${ue_id} pdu=${pdu_id}
    PASS FLOW[timeout=2]: AMF1 NGAP pDUSessionResourceRelease

Setup PDU session for UE${ue_id:\d+} with id=${pdu_id}
    EXPECT FLOW[timeout=2]: AMF1 NGAP pDUSessionResourceSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id}
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=1 using PDU Gateway ID

    PASS FLOW[timeout=2]: AMF1 NGAP pDUSessionResourceSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete


Set expected messages flows for Reestablishment for UE${ue_id}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify expected messages flows for Reestablishment for UE${ue_id}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishment
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReestablishmentComplete
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Configure UE${ue_id:\d+} to ${option:send|not send} rrcReconfigurationComplete
    Run keyword if    '${option}'=='not send'
    ...    execute egate command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=mrdc_scg_setup action=drop
    Run keyword if    '${option}'=='send'
    ...    execute egate command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=mrdc_scg_setup action=none
    sleep    1

Configure sim SN gNB${gnb_id} to ${option:send|not send} XNAP:SNodeAdditionRequestAcknowledge
    Run keyword if    '${option}'=='not send'
    ...    execute egate command    cmd=gnb_snode_addition_request_param id=${gnb_id} action=drop
    Run keyword if    '${option}'=='send'
    ...    execute egate command    cmd=gnb_snode_addition_request_param id=${gnb_id} action=none
    sleep    1

Configure sim MN gNB${gnb_id} to ${option:send|not send} XNAP:XnUAddressIndication
    Run keyword if    '${option}'=='not send'
    ...    execute egate command    cmd=gnb_xnu_address_indication_param id=${gnb_id} action=skip_sending
    Run keyword if    '${option}'=='send'
    ...    execute egate command    cmd=gnb_xnu_address_indication_param id=${gnb_id} reset
    sleep    1

Configure sim MN gNB${gnb_id} to send XNAP:XnUAddressIndication ${option:with|without} mandatory IE
    Run keyword if    '${option}'=='without'
    ...    execute egate command    cmd=gnb_xnu_address_indication_param id=${gnb_id} action=override_ie drop_sn_terminated_ie=on
    Run keyword if    '${option}'=='with'
    ...    execute egate command    cmd=gnb_xnu_address_indication_param id=${gnb_id} action=override_ie drop_sn_terminated_ie=off
    sleep    1

Configure sim MN gNB${gnb_id} to send XNAP:XnUAddressIndication ${option:with|without} additional DRB
    Run keyword if    '${option}'=='without'
    ...    execute egate command    cmd=gnb_xnu_address_indication_param id=${gnb_id} action=override_ie modify_drbs_to_be_setup=DISABLED
    Run keyword if    '${option}'=='with'
    ...    execute egate command    cmd=gnb_xnu_address_indication_param id=${gnb_id} action=override_ie modify_drbs_to_be_setup=ONE_ADDITIONAL_DRB
    sleep    1

Configure sim MN gNB${gnb_id} to send XNAP:SNodeReconfigurationComplete ${option:with|without} Container IE
    Run keyword if    '${option}'=='without'
    ...    execute egate command    cmd=gnb_snode_reconfiguration_complete_param id=${gnb_id} action=override_ie drop_mn_to_sn_container=on
    Run keyword if    '${option}'=='with'
    ...    execute egate command    cmd=gnb_snode_reconfiguration_complete_param id=${gnb_id} reset
    sleep    1

Configure sim MN gNB${gnb_id} to send XNAP:SNStatusTransfer ${option:with|without} abstract syntax error
    Run keyword if    '${option}'=='without'
    ...    execute egate command    cmd=gnb_xn_status_transfer_param id=${gnb_id} reset
    Run keyword if    '${option}'=='with'
    ...    execute egate command    cmd=gnb_xn_status_transfer_param id=${gnb_id} action=abstract_syntax_error
    sleep    1

Configure sim MN gNB${gnb_id} to ${option:send|not send} XNAP:SNStatusTransfer
    Run keyword if    '${option}'=='not send'
    ...    execute egate command    cmd=gnb_xn_status_transfer_param id=${gnb_id} action=do_not_send
    Run keyword if    '${option}'=='send'
    ...    execute egate command    cmd=gnb_xn_status_transfer_param id=${gnb_id} reset
    sleep    1

Set expected messages flows for RLF due to cell shutdown for SN gNB${gnb_id}
    EXPECT FLOW[timeout=240]: gNB${gnb_id} E1AP reset
    EXPECT FLOW[timeout=240]: gNB${gnb_id} F1AP reset
    EXPECT FLOW[timeout=240]: gNB${gnb_id} XNAP reset

Verify expected messages flows for RLF due to cell shutdown for SN gNB${gnb_id}
    PASS FLOW[timeout=240]: gNB${gnb_id} E1AP reset
    PASS FLOW[timeout=240]: gNB${gnb_id} F1AP reset
    PASS FLOW[timeout=240]: gNB${gnb_id} XNAP reset

Check that XNlink is down
    ${link_status} =    get_enb_parameter_value    XNLINK-1    xnLinkStatus    bts_id=2
    should be true    '${link_status}' == 'unavailable'

Check that XNlink is up
    ${link_status} =    get_enb_parameter_value    XNLINK-1    xnLinkStatus    bts_id=2
    should be true    '${link_status}' == 'available'

Check that XNlink is down for ${time}s
    Wait Until Keyword Succeeds  ${time}s  1s
    ...    Check that XNlink is down

Check that XNlink is up for ${time}s
    Wait Until Keyword Succeeds  ${time}s  1s
    ...    Check that XNlink is up

Set expected messages flows for TakeBack after nrDcReevalTimer for MN gNB${mn_gnb_id:\d+} for UE${ue_id}
    EXPECT FLOW[timeout=700]: gNB${mn_gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=700]: gNB${mn_gnb_id} F1AP 2*uEContextModification
    EXPECT FLOW[timeout=700]: gNB${mn_gnb_id} XNAP sNGRANnodeinitiatedSNGRANnodeRelease
    EXPECT FLOW[timeout=700]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=700]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Verify expected messages flows for TakeBack after nrDcReevalTimer for MN gNB${mn_gnb_id:\d+} for UE${ue_id}
    PASS FLOW[timeout=700]: gNB${mn_gnb_id} E1AP 2*bearerContextModification
    PASS FLOW[timeout=700]: gNB${mn_gnb_id} F1AP 2*uEContextModification
    PASS FLOW[timeout=700]: gNB${mn_gnb_id} XNAP sNGRANnodeinitiatedSNGRANnodeRelease
    PASS FLOW[timeout=700]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=700]: UE_${ue_id} NR-RRC 2*RRCReconfigurationComplete

Set expected flows for Scell setup for SN gNB${sn_gnb_id} for UE${ue_id}
    Log    Set expected flows for Scell setup for SN gNB${sn_gnb_id} for UE${ue_id}
    EXPECT FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeinitiatedSNGRANnodeModificationPreparation

Verify expected flows for Scell setup for SN gNB${sn_gnb_id} for UE${ue_id}
    Log    Verify expected flows for Scell setup for SN gNB${sn_gnb_id} for UE${ue_id}
    PASS FLOW[timeout=10]: gNB${sn_gnb_id} XNAP sNGRANnodeinitiatedSNGRANnodeModificationPreparation

Set expected messages for UE${ue_id} redirection to LTE
    EXPECT FLOW[timeout=10]: gNB2 F1AP uEContextModification
    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify expected messages for UE${ue_id} redirection to LTE
    PASS FLOW[timeout=10]: gNB2 F1AP uEContextModification
    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceModify
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Add to UE${ue_id} PDU${pdu_id} session QoS flows with with 5QI-1
    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=3

Set timing advance for SCG leg - UE${ue_id}, distance to cell - ${dist}m
    ${ta}=    calculate timing advance    ${dist}
    Execute egate command  cmd=ue_ta_nr ue_p_delay_initial=${ta} ue_p_delay_min=${ta} ue_p_delay_max=${ta} nb_reps_ta_sim=1 ue_speed=30 profile_id=2
    Execute egate command  cmd=ue_testmode_set_nr action=activate testmode=ta profile_id=2 cell_group=SCG id=${ue_id}

Reset timing advance settings for UE${ue_id} and profile id-${id}
    Execute egate command    cmd=ue_testmode_set_nr id=${ue_id} action=deactivate testmode=ta profile_id=${id}
    Execute egate command    cmd=ue_ta_nr profile_id=${id} delete=on

Activate CB013233    #DRX setup
    Configure   ${yaml_actDRX}    name=actDRX

Deactivate CB013233    #DRX off
    Deconfigure    name=actDRX

Trigger UE${ue_id:\d+} to send UAI with RRC preferred state of ${UAI_session_type}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UEAssistanceInformation
    Execute egate command   cmd=ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=${UAI_session_type}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UEAssistanceInformation


Trigger UE${ue_id} to enter ACTIVE state without A4 configuration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    Execute egate command    cmd=im_exit_ue id=${ue_id}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

Trigger UE${ue_id} to enter ACTIVE state with A4 configuration
    EXPECT FLOW[timeout=12]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    Execute egate command    cmd=im_exit_ue id=${ue_id}
    PASS FLOW[timeout=12]: UE_${ue_id} NR-RRC 2*RRCReconfiguration

Activate UE${ue_id:\d+} on gNBSim-${gnb_id} cell-${cell_id} and setup PDU session
    Set up inter gNB Handover for UE${ue_id}
    Execute egate command  cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Execute egate command  cmd=ue_register id=${ue_id}
    ...  pass_regexp=UE${ue_id}: UE performed Registration type INITIAL_REGISTRATION
    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute egate command  cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    ...  pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=1 using PDU Gateway ID

Reconfigure NRDC_UEPROFILE to not contain UE chipsetID
    Configure    ${disable_chipsetID}    name=profile_2

Set NRDC_UEPROFILE.nrUeProfileDNList to NRUEPROFILE-${profile_id}
    Configure   {'MOC': 'NRDC_UEPROFILE', 'ID': '1', 'nrUeProfileDNList': ['NRUEPROFILE-${profile_id}']}

Detach UE${ue_id}
    Execute egate command    cmd=ue_detach id=${ue_id}

Add to UE${ue_id:\d+} ${session_type:(initial|second|third)} PDU session
    EXPECT FLOW[timeout=3]: AMF1 NGAP pDUSessionResourceSetup - messages not occur due to ICS with PDU session setup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration

    ${pdu_id}    Get From Dictionary    ${session_name_to_pdu}   ${session_type}
    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Run keyword and continue on failure
    ...     Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} gw=${current_gw_id} nwslice=1
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=${pdu_id} using PDU Gateway ID
    ${current_gw_id}     Evaluate  ${current_gw_id} + 1
    Set Test Variable    ${current_gw_id}

    FAIL FLOW[timeout=3]: AMF1 NGAP pDUSessionResourceSetup - messages not occur due to ICS with PDU session setup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC 2*RRCReconfiguration

Include UE Capabilities In ICS Request
    [Arguments]    ${ue_id}    ${ue_capabilities}
    Execute egate command    cmd=amf_ue_ics_param ue=${ue_id} id=1 include_ue_capabilities=on ue_capabilities=${ue_capabilities}

Turn off UE capabilities for UE${ue_id} in ICS Request
    Execute egate command    cmd=amf_ue_ics_param ue=${ue_id} id=1 include_ue_capabilities=off
