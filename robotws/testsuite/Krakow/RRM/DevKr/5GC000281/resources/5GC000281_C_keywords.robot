*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS ==
...      - Mateusz Matusik <mateusz.matusik@nokia.com>
...      - Michał Szymakowski <michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      - Mateusz Matusik <mateusz.matusik@nokia.com>
...      - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../../resources/Robot/common_settings.robot
Library     ./CplaneOverloadSetter.py
Library     ./SgNBModification_verifiers.py
Library     ./tce_verify.py
Library     ../../resources/python/mock_stop_egate.py
Resource    ../../resources/yaml_config_paths.robot
Library     taf.ul.ue.sim.env_setup

*** Variables ***
${delta_configuration}=   delta_281c_emergency_sa.json
${pm_counters_five_minutes_interval}=  ${CURDIR}/../config/SBTS21B/delta_set_collecting_counters_to_five_minutes.json

${delta_281c_ovlSaRrcRej_disabled}=  ${CURDIR}/../config/yaml/delta_281c_ovlSaRrcRej_disabled.yaml
${delta_281c_TCE_a3}=                ${CURDIR}/../config/yaml/delta_281c_TCE_a3.yaml
${delta_281c_tce_enable}=            ${CURDIR}/../config/yaml/delta_281c_tce_enable.yaml
${delta_281c_ovlSaPduRej_enabled}=   ${CURDIR}/../config/yaml/delta_281c_ovlSaPduRej_enabled.yaml
${delta_281c_ovlSaHoRej_enabled}=    ${CURDIR}/../config/yaml/delta_281c_ovlSaHoRej_enabled.yaml
${delta_281c_a3_disable}=            ${CURDIR}/../config/yaml/delta_281c_a3_disable.yaml
${delta_281c_ovlall_enabled}=        ${CURDIR}/../config/yaml/delta_281c_ovlall_enabled.yaml

${delta_281c_tce_disable}=          ${CURDIR}/../config/yaml/delta_281c_tce_disable.yaml
${delta_281c_actCuOvlProt_true}=    ${CURDIR}/../config/yaml/delta_281c_actCuOvlProt_true.yaml

${delta_281c_actCuOvlProt_false}=   ${CURDIR}/../config/yaml/delta_281c_actCuOvlProt_false.yaml
${delta_281c_ovlSaRrcRej_enabled}=  ${CURDIR}/../config/yaml/delta_281c_ovlSaRrcRej_enabled.yaml

${delta_281c_gnbOvlProtMode_classical}=    ${CURDIR}/../config/yaml/delta_281c_gnbOvlProtMode_classical.yaml
${delta_281c_gnbOvlProtMode_disabled}=   ${CURDIR}/../config/yaml/delta_281c_gnbOvlProtMode_disabled.yaml

${lo_ap_lo_ho_fix}=                 ${CURDIR}/../config/yaml/LO_AP_LO_HO_fix.yaml

*** Keywords ***
Prepare test suite
    [Arguments]    ${ute_ca}=${False}

    Run Keyword if  ${ute_ca} != ${False}
    ...    Prepare TL with config files

    Configure   ${yaml_paths_to_configure}
    Add 5GC    config=${LUA_CFG}    edaemon_ports=10000
    Configure environment    rmod_detection_timeout=420s
    Setup egate  egate_port=20000  alias=default
    Setup devices aliases
    Reliable emss setup         bts_id=1
    Enable internal mirroring for alias  gNB2

Prepare TL with config files
     Log To Console    Configure ENV with SCFC/AP.xml/LUA
     Add gNB configuration    scfc=${SCFC}
     Add simulator    sim_type=airphone    config=${AP_XML}
     Configure environment    rmod_detection_timeout=420s
     Log To Console    After Configure ENV

Add to UE${ue_id} second PDU session
    Sleep  30s
    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceSetupRequest as PDU_Req
    ...     AMF1:NGAP_PDUSessionResourceSetupResponse as PDU_Resp
    ...     alias=UE${ue_id}_PDU_Session_Add
    ...     overall_timeout=30

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_Reconfiguration
    ...     overall_timeout=30

    Execute egate command
    ...   cmd=ue_pdu_session_setup pdu=2 ue=${ue_id} gw=2 nwslice=1
    ...   pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session

AMF sends NGAP: PDU Session Resource Modify Request with QoS flow ${action:addition|deletion} in second PDU session for UE1
    Flow occurred as expected   alias=UE1_PDU_modify

AMF sends NGAP: PDU Session Resource Setup Request with emergency ARP priority equal to 5
    Flow occurred as expected    alias=UE4_adding_5qi1
    Verify that message has field set to value
    ...   flow_alias=UE4_adding_5qi1
    ...   message_alias=5qi1_Req
    ...   field_name=priorityLevelARP
    ...   value=5

AMF sends NGAP: PDU Session Resource Setup Request with new PDU session for UE1
    Flow occurred as expected   alias=UE1_PDU_Session_Add

AMF sends NGAP: PDU Session Resource Setup Request with new PDU session for UE1 during active OVL
    Flow occurred as expected   alias=UE1_PDU_Session_Fail

Attach UE${ue_id:\d+} to gNB with A3 measurement
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=2 cell=1

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCSetupRequest as RRCSetup
    ...     UE_${ue_id}:NR-RRC_RRCSetup
    ...     alias=UE${ue_id}_RRC_attach
    ...     overall_timeout=15

    Expect Message Flow
    ...     AMF1:NGAP_InitialUEMessage as InitalMessage
    ...     AMF1:NGAP_InitialContextSetupRequest
    ...     AMF1:NGAP_InitialContextSetupResponse
    ...     alias=UE${ue_id}_NGAP_attach
    ...     overall_timeout=15

    Attach UE   ue_id=${ue_id}
    Execute egate command   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1

Cleanup after test C1
    Perform CPLANE OVL deactivation via R&D mechanism
    Execute egate command   cmd=deregister_ue id=1-3 by=amf

Cleanup after test C2
    Configure    ${delta_281c_tce_disable}
    Teardown PCMD
    Execute egate command   cmd=deregister_ue id=1-2 by=amf
    Perform CPLANE OVL deactivation via R&D mechanism

Cleanup after test C3
    Teardown PCMD
    Configure    ${delta_281c_tce_disable}
    Perform CPLANE OVL deactivation via R&D mechanism
    Execute egate command   cmd=deregister_ue id=1 by=amf

Cleanup after test C4
    Configure    ${delta_281c_gnbOvlProtMode_classical}
#    Configure    ${delta_281c_actCuOvlProt_true}
    Perform CPLANE OVL deactivation via R&D mechanism
    Execute egate command   cmd=kill_ue id=1

Cleanup after test C5
    Perform CPLANE OVL deactivation via R&D mechanism
    Execute egate command   cmd=deregister_ue id=1-5 by=amf
    Execute egate command   cmd=ue_nr_rrc_setup_param id=2 establishment_cause=mo-Signalling
    Execute egate command   cmd=ue_nr_rrc_setup_param id=4 establishment_cause=mo-Signalling
    Execute egate command   cmd=ue_nr_rrc_setup_param id=5 establishment_cause=mo-Signalling
    Execute egate command   cmd=qosflow_modify qos_flow=1 priority=15
    Execute egate command   cmd=qosflow_modify qos_flow=2 priority=15

Collect PM file
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Set suite variable  ${PM_COUNTERS}  ${PM_COUNTERS}

Emergency UE${ue_id:\d+} attach to gNB2
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCSetupRequest as RRCSetup
    ...     UE_${ue_id}:NR-RRC_RRCSetup
    ...     UE_${ue_id}:NR-RRC_RRCSetupComplete
    ...     alias=UE${ue_id}_RRC_attach
    ...     overall_timeout=30

    Expect Message Flow
    ...     AMF1:NGAP_InitialUEMessage as InitalMessage
    ...     AMF1:NGAP_InitialContextSetupRequest
    ...     AMF1:NGAP_InitialContextSetupResponse
    ...     alias=UE${ue_id}_NGAP_attach
    ...     overall_timeout=30

    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceModifyRequest as 5qi1_Req
    ...     AMF1:NGAP_PDUSessionResourceModifyResponse as 5qi1_Res
    ...     alias=UE${ue_id}_adding_5qi1
    ...     overall_timeout=30

    Set up emergency ICS for UE${ue_id}
    Attach UE
    ...   ue_id=${ue_id}
    ...   establishment_cause=emergency
    Sleep  2s
    Execute egate command
    ...   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1 request_type=initial-emergency-request
    ...   pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session
    Sleep  2s
    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf

Emergency UE${ue_id} attach to gNB3
    Set up HO for UE${ue_id}
    Set up emergency ICS for UE${ue_id}
    Attach UE
    ...   ue_id=${ue_id}
    ...   establishment_cause=emergency
    ...   pass_regexp=Received REGISTRATION COMPLETE
    Execute egate command
    ...   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1 request_type=initial-emergency-request
    ...   pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session

    Sleep  2s
    Execute egate command   cmd=meas_cfg_ue_disp id=${ue_id}
    Execute egate command
    ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A5 srsrp_nr=19 srsrq_nr=10 phycell_id=52 nrsrp_nr=85 nrsrq_nr=31
    ...   pass_regexp=UE${ue_id}: Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed

Emergency UE${ue_id} triggers handover to gNB2
    Expect Message Flow
    ...     gNB3_XN:XNAP_HandoverRequest as HO_Req
    ...     gNB3_XN:XNAP_HandoverRequestAcknowledge as HO_Req_Ack
    ...     alias=UE${ue_id}_Handover
    ...     overall_timeout=30

    Execute egate command
    ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=5 event=A5 srsrp_nr=19 srsrq_nr=10 phycell_id=50 nrsrp_nr=85 nrsrq_nr=31
    ...   pass_regexp=UE${ue_id}: Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed

Fix UE after test
    [Arguments]   ${ue_id}=1
    Execute egate command   cmd=deregister_ue id=${ue_id} by=amf
    Sleep  2s
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=2 cell=1
    Execute egate command   cmd=register_ue id=${ue_id}
    Sleep  2s
    Execute egate command   cmd=deregister_ue id=${ue_id} by=amf

Modify UE${ue_id} second PDU session
    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceModifyRequest as PDU_Req
    ...     AMF1:NGAP_PDUSessionResourceModifyResponse as PDU_Resp
    ...     alias=UE${ue_id}_PDU_modify
    ...     overall_timeout=30

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_Reconfiguration
    ...     overall_timeout=30

    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=2 by=amf

Perform CPLANE OVL activation via R&D mechanism
    Set Overload High Threshold to 0
    Sleep  10

Perform CPLANE OVL deactivation via R&D mechanism
    Set Overload High Threshold to 40
    Sleep  10

Prepare test environment C1
    Configure    ${delta_281c_ovlSaRrcRej_disabled}
    Wait For Next Full Pm Interval

Prepare test environment C2
    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${delta_281c_TCE_a3}
    append to list      ${yaml_paths_to_configure}      ${delta_281c_tce_enable}
    Configure    ${yaml_paths_to_configure}

Prepare test environment C3
    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${delta_281c_tce_enable}
    append to list      ${yaml_paths_to_configure}      ${delta_281c_ovlSaPduRej_enabled}
    Configure    ${yaml_paths_to_configure}

Prepare test environment C4
    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${delta_281c_ovlSaHoRej_enabled}
    append to list      ${yaml_paths_to_configure}      ${delta_281c_a3_disable}
    Configure    ${yaml_paths_to_configure}

Prepare test environment C5
    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${delta_281c_ovlall_enabled}
    append to list      ${yaml_paths_to_configure}      ${delta_281c_a3_disable}
    Configure    ${yaml_paths_to_configure}
    Execute egate command   cmd=qosflow_modify qos_flow=1 priority=5
    Execute egate command   cmd=qosflow_modify qos_flow=2 priority=5
    Wait For Next Full Pm Interval

Prepare test environment ABIN
    Execute egate command   cmd=qosflow_modify qos_flow=1 priority=5
    Execute egate command   cmd=qosflow_modify qos_flow=2 priority=5

Run CRT setup
    Log To Console    Setup started
    Trigger site reset
    Check radios availability
    Sleep  1
    Reach Onair    lua_cfg=${LUA_CFG}
    Set Counter Collecting Interval To Five Minutes
    Setup devices aliases
    Enable internal mirroring for alias  gNB2

Run ABIN suite setup
    Log To Console    Setup started
    Trigger site reset
    Check radios availability
    Sleep  1
    Reach Onair    lua_cfg=${LUA_CFG}
    Setup egate if needed
    Setup devices aliases
    Enable internal mirroring for alias  gNB2

Run yaml setup
    Log To Console    Setup started
    Teardown emss   bts_id=1
    Setup emss      bts_id=1

    ${run_update}    get variable value      ${configure}    "True"     # do not ever change that line!
    Run Keyword if  ${run_update} == "True"
    ...    Reach onAir state
    Run Keyword if  ${run_update} != "True"
    ...    Setup egate  egate_port=20000  alias=default
    Setup devices aliases
    Enable internal mirroring for alias  gNB2

Reach onAir state
    Configure   ${yaml_paths_to_configure}
    Log To Console    Before Reach OnAir
    Reach OnAir    lua_cfg=${LUA_CFG}
    Log To Console    After Reach OnAir
    Do not stop egate and daemon

Run local setup
    Run Keywords   Log To Console    Setup started
    ...    AND     Send Delta Commissioning    input_filepath=${CURDIR}/../config/SBTS22R2/${delta_configuration}
    ...    AND     Reach Onair    lua_cfg=${LUA_CFG}
    ...    AND     Set Counter Collecting Interval To Five Minutes
    ...    AND     Setup devices aliases
    ...    AND     Enable internal mirroring for alias  gNB2

Setup egate if needed
    ${run_update}    get variable value      ${configure}    "True"
    Run Keyword if  ${run_update} != "True"
    ...           Setup egate    egate_port=20000

Set Counter Collecting Interval To Five Minutes
    Send Delta Commissioning  input_filepath=${pm_counters_five_minutes_interval}

Set gNB2 parameter actCuOvlProt to FALSE
    Configure    ${delta_281c_actCuOvlProt_false}

Set gNB2 parameter gnbOvlProtMode to DISABLED
    Configure    ${delta_281c_gnbOvlProtMode_disabled}

Set gNB2 parameter OVLSaRrcRej to TRUE
    Configure    ${delta_281c_ovlSaRrcRej_enabled}

Set up emergency ICS for UE${ue_id}
    Execute egate command   cmd=ue_param id=${ue_id} nr_usage_setting=voice_centric
    Execute egate command   cmd=ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency

Set up HO for UE${ue_id}
    ${list_id}=   Set variable   ${ue_id}
    Execute egate command
    ...   cmd=ue_history_information_list_add_ngran id=${list_id} gnb_id=3 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command
    ...   cmd=ue_history_information_list_add_ngran id=${list_id} gnb_id=2 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command   cmd=ue_history_information_list id=${list_id} action=commit
    Execute egate command   cmd=ue_enb_param id=${ue_id} ue_history_list=${list_id}

Setup devices aliases
    Create ues alias
    ...   alias=UE
    ...   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.30
    Create GNB device with alias 'gNB3_XN' identified by ip=10.0.1.31
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Setup PCMD
    Configure PCMD  technology=5G  asn1per_decoding=True
    Sleep  2
    Start collecting PCMD reports
    Sleep  2

Start TCE interface monitoring via Wireshark
    Setup PCMD

Teardown PCMD
    Stop collecting PCMD reports
    Sleep  2
    Deconfigure PCMD
    Sleep  2

Wait ${time} to collect all PCMD reports
    Sleep   ${time}

Try to add to UE${ue_id:\d+} second PDU session during active OVL
    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceSetupRequest as PDU_Req
    ...     AMF1:NGAP_PDUSessionResourceSetupResponse as PDU_Resp
    ...     alias=UE${ue_id}_PDU_Session_Fail
    ...     overall_timeout=30

    Expect message will not occur
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration
    ...     alias=UE${ue_id}_RRC_Reconfiguration
    ...     overall_timeout=10

    Execute egate command
    ...   cmd=ue_pdu_session_setup pdu=15 ue=${ue_id} gw=15 nwslice=1
    ...   pass_regexp=PDU Session ID 15 was unsuccessful due to misc control processing overload

Try to attach UE${ue_id:\d+} to gNB2 during active OVL
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCSetupRequest as RRCSetup
    ...     UE_${ue_id}:NR-RRC_RRCReject
    ...     alias=UE${ue_id}_attach_fail
    ...     overall_timeout=30

    Execute egate command
    ...   cmd=register_ue id=${ue_id}
    ...   pass_regexp=UEC-1: UE${ue_id}: RRC Reject was received

Try to handover UE1 to gNB2 during active OVL
    Expect Message Flow
    ...     gNB3_XN:XNAP_HandoverRequest as HO_Req
    ...     gNB3_XN:XNAP_HandoverPreparationFailure as HO_Failure
    ...     alias=UE1_Handover
    ...     overall_timeout=30

    Execute egate command   cmd=ue_measurement_send_nr id=1 meas_id=5 event=A5 srsrp_nr=19 srsrq_nr=10 phycell_id=50 nrsrp_nr=85 nrsrq_nr=31

Try to Modify UE${ue_id:\d+} second PDU session
   Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceModifyRequest as PDU_Req
    ...     AMF1:NGAP_PDUSessionResourceModifyResponse as PDU_Resp
    ...     alias=UE${ue_id}_PDU_modify
    ...     overall_timeout=30

   Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_del=2 by=amf

UE${ue_id:\d+} attach to gNB2
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCSetupRequest as RRCSetup
    ...     UE_${ue_id}:NR-RRC_RRCSetup
    ...     UE_${ue_id}:NR-RRC_RRCSetupComplete
    ...     alias=UE${ue_id}_RRC_attach
    ...     overall_timeout=30

    Expect Message Flow
    ...     AMF1:NGAP_InitialUEMessage as InitalMessage
    ...     AMF1:NGAP_InitialContextSetupRequest
    ...     AMF1:NGAP_InitialContextSetupResponse
    ...     alias=UE${ue_id}_NGAP_attach
    ...     overall_timeout=30

    Execute egate command   cmd=ue_change_location id=${ue_id} enb=2 cell=1
    Attach UE   ue_id=${ue_id}
    Execute egate command
    ...   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1
    ...   pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session

UE${ue_id:\d+} attach to gNB3
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=2 cell=1
    Set up HO for UE${ue_id}
    Attach UE   ue_id=${ue_id}
    Execute egate command
    ...   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1
    ...   pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session

    Sleep  2s
    Execute egate command   cmd=meas_cfg_ue_disp id=${ue_id}
    Execute egate command
    ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A5 srsrp_nr=19 srsrq_nr=10 phycell_id=54 nrsrp_nr=85 nrsrq_nr=31
    ...   pass_regexp=UE${ue_id}: Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed

UE${ue_id:\d+} sends A3 measResult for nr_cell_1 from gNB_tgt with value above offset defined for PSCell
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_MeasurementReport
    ...     alias=UE${ue_id}_meas_report
    ...     overall_timeout=15

    Expect Message Flow
    ...     gNB3_XN:XNAP_HandoverRequest as HO_Req
    ...     gNB3_XN:XNAP_HandoverRequestAcknowledge as HO_Req_Ack
    ...     gNB3_XN:XNAP_UEContextRelease
    ...     alias=UE${ue_id}_Handover
    ...     overall_timeout=20

    Execute egate command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=19 srsrq_nr=10 phycell_id=54 nrsrp_nr=85 nrsrq_nr=31

UE${ue_id:\d+} sends A3 measResult from gNB_tgt with value above offset defined for PSCell
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_MeasurementReport
    ...     alias=UE${ue_id}_meas_report_OVL
    ...     overall_timeout=10

    Expect message will not occur
    ...     gNB3_XN:XNAP_HandoverRequest
    ...     alias=UE${ue_id}_no_ho
    ...     overall_timeout=10

    Expect message will not occur
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration
    ...     alias=UE${ue_id}_RRC
    ...     overall_timeout=10

    Expect message will not occur
    ...     UE_${ue_id}:NR-RRC_RRCRelease
    ...     alias=UE${ue_id}_RRCRel
    ...     overall_timeout=10

    Execute egate command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=19 srsrq_nr=10 phycell_id=54 nrsrp_nr=85 nrsrq_nr=31
    Flow occurred as expected    alias=UE${ue_id}_meas_report_OVL

UE${ue_id:\d+} sends RRC Setup Request
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCSetupRequest as RRCSetup
    ...     UE_${ue_id}:NR-RRC_RRCSetup
    ...     UE_${ue_id}:NR-RRC_RRCSetupComplete
    ...     alias=UE${ue_id}_RRC_attach
    ...     overall_timeout=30

    Expect Message Flow
    ...     AMF1:NGAP_InitialUEMessage as InitalMessage
    ...     AMF1:NGAP_InitialContextSetupRequest
    ...     AMF1:NGAP_InitialContextSetupResponse
    ...     alias=UE${ue_id}_NGAP_attach
    ...     overall_timeout=30

    Attach UE   ue_id=${ue_id}
    Execute egate command
    ...   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1
    ...   pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session

UE${ue_id:\d+} tries to send RRC Setup Request
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCSetupRequest as RRCSetup
    ...     UE_${ue_id}:NR-RRC_RRCReject
    ...     alias=UE${ue_id}_attach_fail
    ...     overall_timeout=30

    Expect Message Flow
    ...     gNB2:F1AP_UEContextReleaseCommand as CtxRel
    ...     alias=UE${ue_id}_f1ap_msg
    ...     overall_timeout=30

    Execute egate command
    ...   cmd=register_ue id=${ue_id}
    ...   pass_regexp=UEC-1: UE${ue_id}: RRC Reject was received

UE${ue_id:\d+} triggers handover to gNB2
    Expect Message Flow
    ...     gNB3_XN:XNAP_HandoverRequest as HO_Req
    ...     gNB3_XN:XNAP_HandoverRequestAcknowledge as HO_Req_Ack
    ...     alias=UE${ue_id}_Handover
    ...     overall_timeout=30

    Execute egate command
    ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=5 event=A5 srsrp_nr=19 srsrq_nr=10 phycell_id=50 nrsrp_nr=85 nrsrq_nr=31
    ...   pass_regexp=UE${ue_id}: Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed

Verify that ${counter_id} ${counter_name} counter is equal ${value} in NRCELL-${cell_id} cell in gNB2
    Verify Last Counters In File
    ...    ${counter_id}
    ...    ${value}
    ...    ${counter_name}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    ...    file_path=${PM_COUNTERS}

Verify that emergency UE${ue_id} is successfully handovered to gNB2 in cpln OVL state
    Flow occurred as expected    alias=UE${ue_id}_Handover

Verify that Establishment Cause IE not set to emergency
    Flow occurred as expected    alias=UE3_attach_fail
    Verify that message field is not equal to value
    ...   flow_alias=UE3_attach_fail
    ...   message_alias=RRCSetup
    ...   field_name=establishmentCause
    ...   value=emergency

Verify that Establishment Cause IE not set to emergency for UE${ue_id}
    Verify that message field is not equal to value
    ...   flow_alias=UE${ue_id}_NGAP_attach
    ...   message_alias=InitalMessage
    ...   field_name=RRCEstablishmentCause
    ...   value=emergency
    Verify that message field is not equal to value
    ...   flow_alias=UE${ue_id}_RRC_attach
    ...   message_alias=RRCSetup
    ...   field_name=establishmentCause
    ...   value=emergency

Verify that Establishment Cause IE set to emergency for UE${ue_id}
    Verify that message has field set to value
    ...   flow_alias=UE${ue_id}_NGAP_attach
    ...   message_alias=InitalMessage
    ...   field_name=RRCEstablishmentCause
    ...   value=emergency
    Verify that message has field set to value
    ...   flow_alias=UE${ue_id}_RRC_attach
    ...   message_alias=RRCSetup
    ...   field_name=establishmentCause
    ...   value=emergency

Verify that Establishment Cause is not set to emergency for UE${ue_id}
    Verify that message field is not equal to value
    ...   flow_alias=UE${ue_id}_attach_fail
    ...   message_alias=RRCSetup
    ...   field_name=establishmentCause
    ...   value=emergency

Verify that gNB ignores Meas Report and does NOT send RRC Reconfiguration or RRC Release for UE${ue_id}
    Flow Not Occurred For Message    alias=UE${ue_id}_RRC
    Flow Not Occurred For Message    alias=UE${ue_id}_RRCRel

Verify that gNB ignores Meas Report and does NOT send XNAP: Handover Request for UE${ue_id}
    Flow Not Occurred For Message    alias=UE${ue_id}_no_ho

Verify that gNB sends NGAP:PDU Session Resource Modify Response with cause: miscellaneous cause: control processing overload
    Verify that message has field set to value
    ...   flow_alias=UE1_PDU_modify
    ...   message_alias=PDU_Resp
    ...   field_name=misc
    ...   value=control-processing-overload

Verify that gNB sends NGAP:PDU Session Resource Modify Response with PDUSessionResourceFailedToModifyListModRes
    Verify that message has fields
    ...   PDUSessionResourceFailedToModifyListModRes is present
    ...   flow_alias=UE1_PDU_modify
    ...   message_alias=PDU_Resp

Verify that gNB sends NGAP:PDU Session Resource Modify Response with PDUSessionResourceModifyListModRes
    Verify that message has fields
    ...   PDUSessionResourceModifyListModRes is present
    ...   flow_alias=UE1_PDU_modify
    ...   message_alias=PDU_Resp

Verify that gNB sends NGAP:PDU Session Resource Setup Response with cause: miscellaneous cause: control processing overload
    Verify that message has field set to value
    ...   flow_alias=UE1_PDU_Session_Fail
    ...   message_alias=PDU_Resp
    ...   field_name=misc
    ...   value=control-processing-overload

Verify that gNB sends NGAP:PDU Session Resource Setup Response with PDUSessionResourceFailedToSetupListSURes
    Verify that message has fields
    ...   PDUSessionResourceFailedToSetupListSURes is present
    ...   flow_alias=UE1_PDU_Session_Fail
    ...   message_alias=PDU_Resp

Verify that gNB sends NGAP:PDU Session Resource Setup Response with PDUSessionResourceSetupItemSURes
    Verify that message has fields
    ...   PDUSessionResourceSetupListSURes is present
    ...   flow_alias=UE1_PDU_Session_Add
    ...   message_alias=PDU_Resp

Verify that gNB sends RRC Reconfiguration
    Flow occurred as expected    alias=UE1_RRC_Reconfiguration

Verify that gNBCU send F1AP:UE Context Release Command with cause: miscellaneous cause: control processing overload
    Flow occurred as expected    alias=UE3_f1ap_msg
    Verify that message has field set to value
    ...   flow_alias=UE3_f1ap_msg
    ...   message_alias=CtxRel
    ...   field_name=misc
    ...   value=control-processing-overload

Verify that gNB2 sends RRC Reject to UE3
    Flow occurred as expected    alias=UE3_attach_fail

Verify that gNB2 sends XNAP: Handover Preparation Failure with cause: miscellaneous cause: control processing overload
    Verify that message has field set to value
    ...   flow_alias=UE1_Handover
    ...   message_alias=HO_Failure
    ...   field_name=misc
    ...   value=control-processing-overload

Verify that gNB${source_id} sends XNAP: ${message:Handover Request Acknowledge|Handover Request} to gNB${target_id} for UE${ue_id}
    Flow occurred as expected    alias=UE${ue_id}_Handover

Verify that ignored measurement report is traced with TCE
    Verify if meas report is traced   measurementReport

Verify that inter-gNB intra-frequency handover execution for UE${ue_id} succeed
    Flow occurred as expected    alias=UE${ue_id}_Handover

Verify that NGAP: PDU Session Resource Setup Request is traced with TCE
    Sleep  5s
    Verify if ngap message is traced   PDUSessionResourceSetupRequest

Verify that NGAP: PDU Session Resource Setup Response is traced with TCE
    Verify if ngap message is traced   PDUSessionResourceSetupResponse

Verify that UE${ue_id} does not recieve RRC Reconfiguration message from gNB
    Flow not occurred for message   alias=UE${ue_id}_RRC_Reconfiguration

Verify that UE${ue_id} is attached to gNB2
    Flow occurred as expected    alias=UE${ue_id}_RRC_attach
    Flow occurred as expected    alias=UE${ue_id}_NGAP_attach

Verify that UE1 sends RRC Reconfiguration Complete
    Flow occurred as expected    alias=UE1_RRC_Reconfiguration
