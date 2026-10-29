*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Konrad Bem <konrad.bem@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../../resources/Robot/common_settings.robot

Library     ta5g_cell_operations
Library     ../../resources/python/mock_stop_egate.py
Library     taf.sbts.oam.coam.admin      WITH NAME    coam
Library     taf.ul.ue.sim.env_setup

*** Variables ***
${ADMIN_CONNECTION}=  admin_connection

*** Keywords ***
Prepare TL with config files
    ${scfc_filepath}       Get Variable Value    ${SCFC}
    ${ap_xml_filepath}     Get Variable Value    ${AP_XML}
    ${lua_filepath}        Get Variable Value    ${LUA_CFG}

    Run keyword if    '${scfc_filepath}'!='None'
    ...                Add gNB configuration    scfc=${scfc_filepath}
    Run keyword if    '${ap_xml_filepath}'!='None'
    ...                Add simulator    sim_type=airphone    config=${ap_xml_filepath}
    Run keyword if    '${lua_filepath}'!='None'
    ...                Add 5GC    config=${lua_filepath}    edaemon_ports=10000
    ${run_update}    get variable value      ${configure}    "True"     # do not ever change that line!
    Run Keyword if  ${run_update} != ${False}
    ...    Configure environment    rmod_detection_timeout=420s
    Setup egate  egate_port=20000  alias=default     save_egate=${True}


Run Setup
    Prepare TL with config files
    Reliable emss setup         bts_id=1
    Setup connection to admin  ${ADMIN_CONNECTION}
    Run Keyword if  ${rtpm} != ${False}
    ...     Activate RTPM counters
    Setup devices aliases


Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create ENB device with alias 'eNB1' identified by ip=10.0.1.21
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.30
    Create GNB device with alias 'gNB3_XN' identified by ip=10.0.1.31
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Activate RTPM counters
    RTPM activate
    Configure  [{'MOC': 'NRPMRNL', 'ID': '1', 'nrRTPMMeasurementsList': '[55601 NR Cell Availability]'}]

Run Suite Teardown
    Teardown connection to admin

Wait for ${time}s ${rest_of_kw_name}
    sleep  ${time}

Start UE${ue_id} emergency call in NRCELL-${cell_id}
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCSetupRequest
    EXPECT FLOW: AMF1 NGAP initialUEMessage with cause emergency
    EXPECT FLOW: AMF1 NGAP initialContextSetup optimized version with 1 PDU Sessions
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow GFBR modification

    Execute egate command   cmd=qosflow_modify qos_flow=1 priority=1
    Execute egate command   cmd=qosflow_modify qos_flow=2 priority=1
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute egate command   cmd=ue_param id=${ue_id} nr_usage_setting=voice_centric
    Execute egate command   cmd=ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Execute egate command   cmd=ue_register id=${ue_id} registration_type=EmergencyRegistration
    Sleep  5
    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1 request_type=initial-emergency-request
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session
    Sleep  2
    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf

    PASS FLOW: UE_${ue_id} NR-RRC RRCSetupRequest
    PASS FLOW: AMF1 NGAP initialUEMessage with cause emergency
    PASS FLOW: AMF1 NGAP initialContextSetup optimized version with 1 PDU Sessions
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW: AMF1 NGAP pDUSessionResourceModify with QoS Flow GFBR modification

    Execute egate command   cmd=qosflow_modify qos_flow=1 priority=15
    Execute egate command   cmd=qosflow_modify qos_flow=2 priority=15

Stop UE${ue_id} emergency call in NRCELL-${cell_id}
    Deregister UE${ue_id} and kill if failed

${action:Activate|Deactivate} CB008392 feature flag
    Run keyword if   '${action}' == 'Activate'
    ...     Change eNB parameter value  NRBTS-1.actNrLBRTXPowerSaving  True  bts_id=1
    Run keyword if   '${action}' == 'Deactivate'
    ...     Change eNB parameter value  NRBTS-1.actNrLBRTXPowerSaving  False  bts_id=1

${action:Activate|Deactivate} 5GC000431 feature flag
    Run keyword if   '${action}' == 'Activate'
    ...     Change eNB parameter value  NRBTS-1.actNrLBPowerSaving  True  bts_id=1
    Run keyword if   '${action}' == 'Deactivate'
    ...     Change eNB parameter value  NRBTS-1.actNrLBPowerSaving  False  bts_id=1

Block NRCELL-${cell_id:\d+}
    coam.block_cell   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=${100}  connection=${ADMIN_CONNECTION}
    sleep   3

Unblock NRCELL-${cell_id:\d+}
    coam.unblock_cell   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=${100}  connection=${ADMIN_CONNECTION}
    sleep   3

Lock NRCELL-${cell_id:\d+}
    coam.lock   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=${100}  connection=${ADMIN_CONNECTION}

Unlock NRCELL-${cell_id:\d+}
    coam.unlock   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=${100}  connection=${ADMIN_CONNECTION}

Reset NRCELL-${cell_id:\d+}
    coam.reset_cell    cell_id=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=${100}  connection=${ADMIN_CONNECTION}

Reset RMOD-${rmod_id:\d+}
    coam.reset_unit    dist_name=MRBTS-1/EQM-1/APEQM-1/RMOD-${rmod_id}    force_radio_reset=${True}
    ...    timeout=${300}    connection=${ADMIN_CONNECTION}

Reset RAT-${rat_type:NR|LTE|WCDMA|GSM}
    coam.rat_reset    rat_type=${rat_type}  timeout=${300}  connection=${ADMIN_CONNECTION}

Reset gNb
    coam.reset_site    timeout=${300}  connection=${ADMIN_CONNECTION}

Activate CB008392 and 5GC000431 feature flags
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'actNrLBRTXPowerSaving': 'True', 'actNrLBPowerSaving': 'True'}

Run ${traffic_rate:\d+}Mbps ${direction:(UL|DL)} traffic on UEs[${ue_ids}] PDU${pdu_id:\d+} QFI${qfi_id:\d+} and wait ${seconds:\d+} seconds
    @{ue_list}=   Split To List   ${ue_ids}
    FOR   ${ue}   IN   @{ue_list}
        Run ${traffic_rate}Mbps ${direction} traffic on UE${ue} PDU${pdu_id} QFI${qfi_id} and wait 0 seconds
    END
    Sleep  ${seconds}

Stop ${traffic_rate:\d+}Mbps ${direction:(UL|DL)} traffic on UEs[${ue_ids}] PDU${pdu_id:\d+} QFI${qfi_id:\d+}
    @{ue_list}=   Split To List   ${ue_ids}
    FOR   ${ue}   IN   @{ue_list}
        Stop ${traffic_rate}Mbps ${direction} traffic on UE${ue} PDU${pdu_id} QFI${qfi_id}
    END

Wait ${timeout}s for cells [${cells_ids}] ${cellState} change to ${expected_states}
    [Documentation]
    ...  Possible cellState values to check in file:
    ...  testsuite/Krakow/RRM/resources/Python/admin_cli.py
    ...  For example: energySavingState | availabilityStatus | operationalState | administrativeState

    Wait Until Keyword Succeeds  ${timeout}s  5s
    ...  Check for cells [${cells_ids}] if ${cellState} equals ${expected_states}

Set lbpsCellSOOrder in NRPGRP-${nrpgrp_id} to [${value}] for cells [${cell_ids}]
    @{cell_list}=   Split To List       ${cell_ids}
    @{value}=       Split To List       ${value}
    ${length_of_cell_list}=  Get length    ${cell_list}

    Create new plan
    FOR  ${i}  IN RANGE  ${length_of_cell_list}
        Edit Planned Object Attributes   NRPGRP-${nrpgrp_id}  lbpsCellList.lbpsCellSOOrder[${i}]=@{value}[${i}]
    END
    Apply planned changes

Reset X2 link between gNB${gnb_id:\d+} and simulated eNB${enb_id:\d+}
    Execute egate command   cmd=link_x2_reset from=${enb_id} to=${gnb_id}
    sleep  3

Setup X2 link between gNB${gnb_id:\d+} and simulated eNB${enb_id:\d+}
    Execute egate command
    ...   cmd=enb_x2_link_up enb=${enb_id} target=${gnb_id}
    ...   pass_regexp=ENB-${enb_id}: X2AP Link with GNB-${gnb_id} .* is up
    sleep  3
