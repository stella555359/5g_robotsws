*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Paulina Jedras <paulina.jedras@nokia.com>
...       - Maciej Madej <maciej.madej@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../../resources/Robot/common_settings.robot
Resource    CB008392_setups_and_teardowns.robot
Resource    CB008392-verify_counters.robot
Resource    configuration.robot

Library     ta5g_cell_operations
Library     ../../resources/python/mock_stop_egate.py
Library     alarm_verifier.py
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
    [Arguments]        ${rtpm}=${False}
    Prepare TL with config files
    Reliable emss setup         bts_id=1
    Setup connection to admin    ${ADMIN_CONNECTION}
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

Run teardown
   Run Keyword If Any Tests Failed
   ...    coam.Collect snapshot  target_file_name=${OUTPUT_DIR}/snapshot.zip  connection=${ADMIN_CONNECTION}
   Teardown connection to admin  ${ADMIN_CONNECTION}

Wait for ${time}s ${rest_of_kw_name}
    sleep  ${time}

Start CMAS notifications for NRCELL-${cell_id}
    ## Emergency area in SCFC for each cell has the same value as NRCELL.nrCellId
    EXPECT FLOW[timeout=10]: AMF1 NGAP writeReplaceWarning
    Execute egate command
    ...  cmd=cbs_broadcast_start amf=1 type=cmas concurrent=true emergency_area=${cell_id} warning_msg=test repetition=200
    PASS FLOW[timeout=10]: AMF1 NGAP writeReplaceWarning
    Verify that gNB sends WriteReplaceWarningResponse with 1 cell

Stop CMAS notifications for NRCELL-${cell_id}
    EXPECT FLOW[timeout=10]: AMF1 NGAP pWSCancel
    Execute egate command
    ...  cmd=cbs_broadcast_stop amf=1 emergency_area=${cell_id}
    PASS FLOW[timeout=10]: AMF1 NGAP pWSCancel
    Verify that gNB sends PWSCancelResponse with 1 cell

Start ETWS notifications for NRCELL-${cell_id}
    ## Emergency area in SCFC for each cell has the same value as NRCELL.nrCellId
    EXPECT FLOW[timeout=10]: AMF1 NGAP writeReplaceWarning
    ## ETWS is repeated each 0,64s. 140 repetitions = 90s of ETWS broadcasting
    Execute egate command
    ...  cmd=cbs_broadcast_start amf=1 etws_warn_type=1 type=etws_prim_sec emergency_area=${cell_id} warning_msg=test2 repetition=140
    PASS FLOW[timeout=10]: AMF1 NGAP writeReplaceWarning
    Verify that gNB sends WriteReplaceWarningResponse with 1 cell

Wait ${time}s until ETWS notifications for NRCELL-${cell_id} are finished
    sleep  ${time}

Verify that gNB sends WriteReplaceWarningResponse with 1 cell
    ${flow_alias}=  get flow name
    ...     procedure=writeReplaceWarning
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     length(completedCellsInEAI-NR) eq 1
    ...     message_alias=WriteReplaceWarningResponse
    ...     flow_alias=${flow_alias}

Verify that gNB sends PWSCancelResponse with 1 cell
    ${flow_alias}=  get flow name
    ...     procedure=pWSCancel
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     length(cancelledCellsInEAI-NR) eq 1
    ...     message_alias=PWSCancelResponse
    ...     flow_alias=${flow_alias}

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

Set lbpsCellSOOrder to [${value}] for cells [${cell_ids}]
    @{cell_list}=   Split To List       ${cell_ids}
    @{value}=       Split To List       ${value}
    ${length_of_cell_list}=  Get length    ${cell_list}

    Create new plan
    FOR  ${i}  IN RANGE  ${length_of_cell_list}
        Edit Planned Object Attributes   NRPGRP-1  lbpsCellList.lbpsCellSOOrder[${i}]=@{value}[${i}]
    END
    Apply planned changes

Set lbpsLastCellSOEnabled to ${value} in NRPGRP-${nrpgr_id}
    Configure  [{'MOC': 'NRPGRP', 'ID': '${nrpgr_id}', 'lbpsLastCellSOEnabled': '${value}'}]

Remove NRPGRPs and deactivate Power Saving feature
    Create new plan
    Plan object deletion  NRPGRP-1
    Run Keyword And Ignore Error
    ...  Plan object deletion  NRPGRP-2
    Edit planned object attributes    NRBTS-1    actNrLBRTXPowerSaving=False
    Run Keyword And Ignore Error
    ...  Edit planned object attributes    NRBTS-1    actNrLBPowerSaving=False
    Apply planned changes

Modify NRPGRP-1.lbpsSOMethod to '${method_1}', NRPGRP-2.lbpsSOMethod to '${method_2}'
    Configure  [{'MOC': 'NRPGRP', 'ID': '1', 'lbpsSOMethod': '${method_1}'}, {'MOC': 'NRPGRP', 'ID': '2', 'lbpsSOMethod': '${method_2}'}]

Modify NRPGRP-1.lbpsCellList to contain cells [1, 4] NRPGRP-2.lbpsCellList to contain cells [2, 3]
    Create new plan
    Edit Planned Object Attributes   NRPGRP-1  lbpsCellList.nrCellId[1]=4
    Edit Planned Object Attributes   NRPGRP-2  lbpsCellList.nrCellId[1]=2
    Apply planned changes

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

Reset RMOD-${rmod_id:\d+}
    coam.reset_unit    dist_name=MRBTS-1/EQM-1/APEQM-1/RMOD-${rmod_id}    force_radio_reset=${True}
    ...    timeout=${300}    connection=${ADMIN_CONNECTION}

Activate CB008392 and 5GC000431 feature flags
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'actNrLBRTXPowerSaving': 'True', 'actNrLBPowerSaving': 'True'}

Verify that alarm with fault 1900 "RF Module configuring failed" is cleared
    coam.Assert alarm inactive   faultId=1900  connection=${ADMIN_CONNECTION}

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

Set NRPGRP-${id}.lbpsDayOfWeek to the next day
    Set time period with 2000 minutes offset for NRPGRP-${id}

    ${lbpsDuration}    get variable value      ${NRPGRP-${id}.lbpsDuration}  ${lbpsDuration_def}
    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsDuration
    ...  value=${lbpsDuration}
    ...  bts_id=1

    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsDayOfWeek
    ...  value=${NRPGRP-${id}.lbpsDayOfWeek}
    ...  bts_id=1

    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsStartTimeHour
    ...  value=${NRPGRP-${id}.lbpsStartTimeHour}
    ...  bts_id=1

    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsStartTimeMinute
    ...  value=${NRPGRP-${id}.lbpsStartTimeMinute}
    ...  bts_id=1
    Run Keyword if  ${no_of_cells} == 4
    ...    Configure  ${1_NRPGRP_4_cell}  node_id=1
    Run Keyword if  ${no_of_cells} == 2
    ...    Configure  ${2_NRPGRP_2_cell_per_group}  node_id=1

Set NRPGRP-${id}.lbpsDayOfWeek to current day
    Set time period with 0 minutes offset for NRPGRP-${id}

    ${lbpsDuration}    get variable value      ${NRPGRP-${id}.lbpsDuration}  ${lbpsDuration_def}
    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsDuration
    ...  value=${lbpsDuration}
    ...  bts_id=1

    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsDayOfWeek
    ...  value=${NRPGRP-${id}.lbpsDayOfWeek}
    ...  bts_id=1

    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsStartTimeHour
    ...  value=${NRPGRP-${id}.lbpsStartTimeHour}
    ...  bts_id=1

    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsStartTimeMinute
    ...  value=${NRPGRP-${id}.lbpsStartTimeMinute}
    ...  bts_id=1

    Configure  ${1_NRPGRP_4_cell}  node_id=1

Remove cell from NRPGRP-1.lbpsCellList with nrCellId=2
    Configure  ${CURDIR}/../config/yaml_config/1_NRPGRP_del_cell.yaml

Add new cell to NRPGRP-1.lbpsCellList with nrCellId=2 and lbpsCellSOOrder=2
    Configure  ${CURDIR}/../config/yaml_config/1_NRPGRP_add_cell.yaml

Reset X2 link between gNB${gnb_id:\d+} and simulated eNB${enb_id:\d+}
    Execute egate command   cmd=link_x2_reset from=${enb_id} to=${gnb_id}
    sleep  3

Setup X2 link between gNB${gnb_id:\d+} and simulated eNB${enb_id:\d+}
    Execute egate command
    ...   cmd=enb_x2_link_up enb=${enb_id} target=${gnb_id}
    ...   pass_regexp=ENB-${enb_id}: X2AP Link with GNB-${gnb_id} .* is up
    sleep  3

Wait ${timeout}s for cells [${cells_ids}] ${cellState:energySavingState|availabilityStatus} change to ${expected_states}
    Wait Until Keyword Succeeds  ${timeout}s  10s
    ...  Check for cells [${cells_ids}] if ${cellState} equals ${expected_states}

Verify that cells [${cells_ids}] are not degraded
    Check for cells [${cells_ids}] if availabilityStatus equals [-,-,-,-]
