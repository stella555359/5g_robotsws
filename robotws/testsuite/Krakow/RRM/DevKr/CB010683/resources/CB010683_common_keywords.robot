*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Paulina Jedras <paulina.jedras@nokia.com>
...       - Malgorzata Konior <malgorzata.konior@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../../resources/Robot/common_settings.robot
Resource    CB010683_setups_and_teardowns.robot
Resource    testsuite/Krakow/RRM/DevKr/resources/ssh.robot
Library     ../../resources/python/mock_stop_egate.py
Library     taf.sbts.oam.coam.admin      WITH NAME    coam
Library     taf.ul.ue.sim.env_setup
Library     ./NRPGRP_lists_generator.py
Library     ./CB010683_counters.py

*** Variables ***
@{yaml_paths_to_configure}=  ${disable_ciphering_yaml_path}
${rdLowLoadSwitchOffDelay}=  6
${rdHighLoadSwitchOnDelay}=  6
${ENABLE_CP_RT_DEBUG_LOGS}   0x590072=1
${CELL_SWITCH_ON_DELAY}      0x5900A9=${rdHighLoadSwitchOnDelay} # cell switch on delay due to energy saving, set to 60s
${CELL_SWITCH_OFF_DELAY}     0x5900AA=${rdLowLoadSwitchOffDelay} # cell switch off delay due to energy saving, set to 60s
@{RAD_PARAMS}=               ${ENABLE_CP_RT_DEBUG_LOGS}  ${CELL_SWITCH_ON_DELAY}  ${CELL_SWITCH_OFF_DELAY}
${ADMIN_CONNECTION}=  admin_connection

*** Keywords ***
Run Setup
    ${run_update}    get variable value      ${configure}    "True"     # do not ever change that line!
    Run Keyword if  ${run_update} != ${False}
    ...    Prepare TL with config files
    Setup egate  egate_port=20000  alias=default    save_egate=True
    Reliable emss setup         bts_id=1
    Setup devices aliases
    Setup connection to admin  ${ADMIN_CONNECTION}

Prepare TL with config files
    Add gNB configuration    scfc=${SCFC}    rad_params=${RAD_PARAMS}
    Add simulator    sim_type=airphone    config=${AP_XML}
    Add 5GC    config=${LUA_CFG}    edaemon_ports=10000
    Configure environment    rmod_detection_timeout=420s
    Configure       ${yaml_paths_to_configure}
    Activate RTPM counters

Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create ENB device with alias 'eNB1' identified by ip=10.0.1.21
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Activate RTPM counters
    RTPM activate
    Configure  [{'MOC': 'NRPMRNL', 'ID': '1', 'nrRTPMMeasurementsList': '[55601 NR Cell Availability]'}]

Run Teardown
    Run Keyword If Any Tests Failed
    ...    coam.Collect snapshot    target_file_name=${OUTPUT_DIR}/snapshot.zip   connection=${ADMIN_CONNECTION}
    Teardown connection to admin  ${ADMIN_CONNECTION}

${action:Activate|Deactivate} CB010683-A feature flag
    Run keyword if   '${action}' == 'Activate'
    ...     Change eNB parameter value  NRBTS-1.actNrExtCellSOMethod  True  bts_id=1
    Run keyword if   '${action}' == 'Deactivate'
    ...     Change eNB parameter value  NRBTS-1.actNrExtCellSOMethod  False  bts_id=1

${action:Activate|Deactivate} CB010683-B feature flag
    Run keyword if   '${action}' == 'Activate'
    ...     Change eNB parameter value  NRBTS-1.actNrMixedSOMethod  True  bts_id=1
    Run keyword if   '${action}' == 'Deactivate'
    ...     Change eNB parameter value  NRBTS-1.actNrMixedSOMethod  False  bts_id=1

${action:Block|Unblock} NRCELL-${cell_id}
    Run keyword if   '${action}' == 'Block'
    ...     coam.block cell   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=100  connection=${ADMIN_CONNECTION}
    Run keyword if   '${action}' == 'Unblock'
    ...     coam.unblock cell   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=100  connection=${ADMIN_CONNECTION}

Wait ${timeout:\d+}s for cells [${cells_ids}] ${cellState} change to ${expected_states}
    Wait Until Keyword Succeeds  ${timeout}s  10s
    ...  Check for cells [${cells_ids}] if ${cellState} equals ${expected_states}

Wait ${x:\d+}x${timer_name} for cells [${cells_ids}] ${cellState} change to ${expected_states}
    ${wait_time}=  Evaluate waiting time for ${x}x${timer_name}
    Wait Until Keyword Succeeds  ${wait_time}s  10s
    ...  Check for cells [${cells_ids}] if ${cellState} equals ${expected_states}

Wait time equal to ${x:\d}x${timer}
    ${wait_time}=  Evaluate waiting time for ${x}x${timer}
    Sleep  ${wait_time}

Evaluate waiting time for ${x:\d}x${timer_name}
    ${shutdownWindow}=    get enb parameter value    NRBTS-1    shutdownWindow
    ${CellOff}=        Evaluate    ${rdLowLoadSwitchOffDelay} * ${10}
    ${CellOff+SW}=     Evaluate    ${CellOff} + ${shutdownWindow}
    ${CellOn}=         Evaluate    ${rdHighLoadSwitchOnDelay} * ${10}
    ${lbpsRTXSOffTime}=     get variable value      ${NRPGRP-1.lbpsRTXSOffTime}  ${NRPGRP_def['lbpsRTXSOffTime']}
    ${lbpsRTXSOnTime}=      get variable value      ${NRPGRP-1.lbpsRTXSOnTime}   ${NRPGRP_def['lbpsRTXSOnTime']}
    ${time}=        Set Variable If
    ...             '${timer_name}'=='(CellOff+SW)'   ${CellOff+SW}
    ...             '${timer_name}'=='CellOn'         ${CellOn}
    ...             '${timer_name}'=='CellOff'        ${CellOff}
    ...             '${timer_name}'=='TXOff'          ${lbpsRTXSOffTime}
    ...             '${timer_name}'=='TXOn'           ${lbpsRTXSOnTime}
    ...             '${timer_name}'=='SW'             ${shutdownWindow}

    ${time}=    Evaluate    ${time} + ${10}   #In CPlane decision always takes time equal to NIDD/R&D timer + 10s
    ${time}=    Evaluate    ${x} * ${time} + ${20}  #20s is added in case of toggling, to long response from OAM
    [Return]  ${time}

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

#B_9
Reconfigure NRPGRP-1.lbpsSoMethod to 'mixed switch off' and NRPGRP-2.lbpsSoMethod to 'cell switch off'
    Create new plan
    Edit planned object attributes    NRPGRP-1   lbpsSoMethod=mixed switch off
    Edit planned object attributes    NRPGRP-2   lbpsSoMethod=cell switch off
    Apply planned changes

#A_2 plan#1
Enable 5GC000431 and CB010683-A feature flags, add extended configuration for cell1 with 'cell switch off' lbpsCellSOMethod
    &{lCPL_1}=    Create Dictionary  cells=1  period_duration=1440   gap_before_period=0  method=${CELL_SO}
    Set test Variable    @{NRPGRP-1.lbpsCellPeriodList}       ${lCPL_1}
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2  so_order=1,2  use_ext_config=1,0
    Set test Variable    ${NRPGRP-1.lbpsPeriodList}           ${None}
    Set test Variable    &{EnergySaving_FF}                   CB008392=1  5GC000431=1  CB010683-A=1
    Configure gNB with NRPGRPs[1] and Energy Saving features flags

#A_2 plan#2
Disable 5GC000431 and CB010683-A feature flags, stop using extended configuration for cell1
    Create new plan
    Edit planned object attributes    NRBTS-1    actNrLBPowerSaving=False
    Edit planned object attributes    NRBTS-1    actNrExtCellSOMethod=False
    Edit planned object attributes    NRPGRP-1   lbpsCellList.lbpsUseExtConfig[0]=False
    Apply planned changes

Set Power Group level period ${time:inside|outside} current time
    ${gap}=        Set Variable If
    ...             '${time}'=='inside'   0
    ...             '${time}'=='outside'  1440

    Set test Variable    &{NRPGRP-1.lbpsPeriodList}    period_duration=1440  gap_before_period=${gap}  suspended=0
    Create yaml for NRPGRP structured parameters
    ...  yaml_path=${NRPGRP-1_structured_params}
    ...  nrpgrp_id=1
    ...  lbpsperiodlist=${NRPGRP-1.lbpsPeriodList}
    Configure  ${NRPGRP-1_structured_params}


#A_6_B_6 plan#1
Modify lbpsCellSoMethod for cell1 to '${method_1}', cell2 to '${method_2}'
    Create new plan
    Edit planned object attributes    NRPGRP-1   lbpsCellPeriodList.lbpsCellSoMethod[0]=${method_1}
    Edit planned object attributes    NRPGRP-1   lbpsCellPeriodList.lbpsCellSoMethod[1]=${method_2}
    Apply planned changes

#A_6_B_6 plan#2
Remove extended configuration for cell1, cell2
    Create new plan
    Plan attribute deletion           NRPGRP-1   lbpsCellPeriodList
    Apply planned changes

#A_6_B_6 plan#3
Stop using extended configuration for cell1, cell2
    Create new plan
    Edit planned object attributes    NRPGRP-1   lbpsCellList.lbpsUseExtConfig[0]=False
    Edit planned object attributes    NRPGRP-1   lbpsCellList.lbpsUseExtConfig[1]=False
    Apply planned changes

#A_16 plan#1
Enable 5GC000431 and CB010683-A feature flags, start using extended configuration for cell1 and cell3 with 'cell switch off' method
    &{lCPL_1}=    Create Dictionary  cells=1  period_duration=1440   gap_before_period=0  method=${CELL_SO}
    &{lCPL_2}=    Create Dictionary  cells=3  period_duration=1440   gap_before_period=0  method=${CELL_SO}
    Set test Variable    @{NRPGRP-1.lbpsCellPeriodList}       ${lCPL_1}  &{lCPL_2}
    Set test Variable    &{NRPGRP-1.lbpsCellList}             cells=1,2,3,4  so_order=1,100,2,100  use_ext_config=1,0,1,0
    Set test Variable    ${NRPGRP-1.lbpsPeriodList}           ${None}
    Set test Variable    &{EnergySaving_FF}                   5GC000431=1  CB010683-A=1  CB008133/CB010471=1

    Set NRPGRP-1 structured parameters
    Set Energy Saving feature flags
    ${yaml_for_TC_setup} =	Create List    ${NRPGRP-1_structured_params}  ${NRBTS-1_EnergySaving_FF}
    Configure  ${yaml_for_TC_setup}

#A_16 plan#2
Change lbpsSOMethod to '${method_1}', modify lbpsCellSoMethod for cell1, cell3 to '${method_2}'
    Create new plan
    Edit planned object attributes    NRPGRP-1   lbpsSOMethod=${method_1}
    Edit planned object attributes    NRPGRP-1   lbpsCellPeriodList.lbpsCellSoMethod[0]=${method_2}
    Edit planned object attributes    NRPGRP-1   lbpsCellPeriodList.lbpsCellSoMethod[1]=${method_2}
    Apply planned changes

#A_16 plan#3
Disable 5GC000431 and CB010683-A feature flags, stop using extended configuration for cell1 and cell3, change lbpsSOMethod to 'TX switch off'
    Create new plan
    Edit planned object attributes    NRBTS-1    actNrLBPowerSaving=False
    Edit planned object attributes    NRBTS-1    actNrExtCellSOMethod=False
    Edit planned object attributes    NRPGRP-1   lbpsCellList.lbpsUseExtConfig[0]=False
    Edit planned object attributes    NRPGRP-1   lbpsCellList.lbpsUseExtConfig[2]=False
    Edit planned object attributes    NRPGRP-1   lbpsSOMethod=Tx switch off
    Plan attribute deletion           NRPGRP-1   lbpsCellPeriodList
    Apply planned changes

#B_10 plan#1
Enable 5GC000431 and CB010683-B feature flags and change NRPGRP-1.lbpsSOMethod to 'mixed switch off'
    Create new plan
    Edit planned object attributes    NRBTS-1    actNrLBPowerSaving=True
    Edit planned object attributes    NRBTS-1    actNrMixedSOMethod=True
    Edit planned object attributes    NRPGRP-1   lbpsSOMethod=mixed switch off
    Apply planned changes

#B_10 plan#2
Disable 5GC000431 and CB010683-B feature flags and change lbpsSOMethod for NRPGRP-1 to 'TX switch off'
    Create new plan
    Edit planned object attributes    NRBTS-1    actNrLBPowerSaving=False
    Edit planned object attributes    NRBTS-1    actNrMixedSOMethod=False
    Edit planned object attributes    NRPGRP-1   lbpsSOMethod=Tx switch off
    Apply planned changes

Verify that counter ${counter} (${counter_id}) for NRCELLs [${cells}] has values [${values}]
    check_counter_for_cells  counter_id=${counter_id}  cells=${cells}  values=${values}

Attach UE${ue_id:\d+} to gNB2 cell${cell_id:\d+} with 1 non-GBR and 1 GBR 5QI1 bearer
    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry

    Attach UE${ue_id} without ICS to gNB2 cell${cell_id}
    Add to UE${ue_id} initial PDU session with ICS including 1 nonGBR and 1 GBR 5QI1 QoS flow

    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    PASS FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry

Add to UE${ue_id:\d+} initial PDU session with ICS including 1 nonGBR and 1 GBR 5QI1 QoS flow
    Execute egate command  cmd=smf_param id=1 additional_qosflows_to_activate=2
    Add to UE${ue_id} initial PDU session with ICS
    Execute egate command  cmd=smf_param id=1 reset

Set NRPGRP-${id:\d+}.lbpsPeriodList.lbpsSuspended to ${suspension:suspended|notSuspended} for all periods
    Create new plan
    FOR  ${i}  IN RANGE  0  7
      Edit Planned Object Attributes   NRPGRP-${id}  lbpsPeriodList.lbpsSuspended[${i}]=${suspension}
    END
    Apply planned changes
