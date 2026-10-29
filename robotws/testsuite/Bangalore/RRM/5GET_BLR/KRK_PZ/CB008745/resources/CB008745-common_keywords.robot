*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Paulina Jedras <paulina.jedras@nokia.com>
...       - Maciej Madej <maciej.madej@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../../resources/KRK/Robot/common_settings.robot
Resource    CB008745_setups_and_teardowns.robot
Library     ../../../resources/KRK/Python/mock_stop_egate.py
Library     taf.sbts.oam.coam.admin      WITH NAME    coam
Library     taf.ul.generic_tshark_json_parser
Library     taf.ul.ue.sim.env_setup
Library     ta_emss
Library     ta_logcollector
Library     ta_uexgate
Library     ute_wtssim
Library     ta_messaging
Library	    OperatingSystem
Library     taf.sw.scout    WITH NAME    scout
Library     BuiltIn
Library     Collections
Library     DateTime
Library     FtpLibrary
Library     OperatingSystem
Library     Process
Library     String



*** Variables ***
&{5QI_TO_EGATE_QOS_FLOW_ID}=  1=1  2=2  3=3  4=4  71=5  72=6  76=7  128=8  212=9  254=10  5=11  6=12  7=13  8=14  9=15  170=16
@{yaml_paths_to_configure}=     ${disable_ciphering_yaml_path}  ${GBR_5QI_yaml_path}
${ADMIN_CONNECTION}=  admin_connection
${icom_prefix}=  itf_l2_ps_cell_PowerSavingLoadMeasurementInd_t
*** Keywords ***
Run Setup
    [Arguments]    ${ute_ca}=${False}
    Log To Console    Setup started
    ${run_update}    get variable value      ${configure}    "True"     # do not ever change that line!
    Run Keyword if  ${ute_ca} != ${False} and ${run_update} != ${False}
    ...    Prepare TL with config files
    Reliable emss setup         bts_id=1
    Setup connection to admin  ${ADMIN_CONNECTION}
    Run Keyword if  ${run_update} != ${False}
    ...    Reach onAir state
    Setup egate  egate_port=20000  alias=default
    Setup devices aliases

Prepare TL with config files
     Log To Console    Configure ENV with SCFC/AP.xml/LUA
     Add gNB configuration    scfc=${SCF}
     Add simulator    sim_type=airphone    config=${AP_XML}
     Configure environment    rmod_detection_timeout=420s
     Log To Console    After Configure ENV

Reach onAir state
    Add 5GC    config=${LUA_CFG}    edaemon_ports=10000
    Configure environment    rmod_detection_timeout=420s
    Log To Console    After Reach OnAir
    Do not stop egate and daemon
    Configure       ${yaml_paths_to_configure}
    ${GBR_5QIs_related_parameters}  catenate    {'MOC': 'NRCELL', 'actVoNR': 'true', 'actNonVoNRGbrService': 'true'},
    ...                                         {'MOC': 'NRDRB', 'maxDataRateGbrDl': '30000', 'maxDataRateGbrUl': '30000'}
    Configure  [${GBR_5QIs_related_parameters}]
    Activate RTPM counters
    Activate CP-RT debug logs

Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create ENB device with alias 'eNB1' identified by ip=10.0.1.21
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1
    Enable internal mirroring for alias    gNB2

Activate RTPM counters
    RTPM activate
    Configure  [{'MOC': 'NRPMRNL', 'ID': '1', 'nrRTPMMeasurementsList': '[55601 NR Cell Availability]'}]

Activate CP-RT debug logs
    coam.set_rad_debug_parameters  domain=5GCPRT  persistency=Persistent  name=LoggingLevel  value=1  connection=${ADMIN_CONNECTION}

Run teardown
    Run Keyword If Any Tests Failed
    ...    coam.Collect snapshot    target_file_name=${OUTPUT_DIR}/snapshot.zip   connection=${ADMIN_CONNECTION}
    Teardown connection to admin  ${ADMIN_CONNECTION}

Remove NRPGRPs and deactivate Power Saving feature
    Create new plan
    Plan object deletion  NRPGRP-1
    Run Keyword And Ignore Error
    ...  Plan object deletion  NRPGRP-2
    Run Keyword And Ignore Error
    ...  Edit planned object attributes    NRBTS-1    actNrLBPowerSaving=False
    Run Keyword And Ignore Error
    ...  Edit planned object attributes    NRBTS-1    actNrLBRTXPowerSaving=False
    Run Keyword And Ignore Error
    ...  Edit planned object attributes    NRBTS-1    actLbpsCtrlLogicEnh=False
    Apply planned changes

${action:Activate|Deactivate} CB008745 feature flag
    Run keyword if   '${action}' == 'Activate'
    ...     Change eNB parameter value  NRBTS-1.actLbpsCtrlLogicEnh  True  bts_id=1
    Run keyword if   '${action}' == 'Deactivate'
    ...     Change eNB parameter value  NRBTS-1.actLbpsCtrlLogicEnh  False  bts_id=1

${action:Activate|Deactivate} 5GC000431 feature flag
    Run keyword if   '${action}' == 'Activate'
    ...     Change eNB parameter value  NRBTS-1.actNrLBPowerSaving  True  bts_id=1
    Run keyword if   '${action}' == 'Deactivate'
    ...     Change eNB parameter value  NRBTS-1.actNrLBPowerSaving  False  bts_id=1

Activate CB008745 and CB008392 feature flagss
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'actLbpsCtrlLogicEnh': 'True', 'actNrLBRTXPowerSaving': 'True'}

Activate 5GC000431 and CB008745 feature flags
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'actLbpsCtrlLogicEnh': 'True', 'actNrLBPowerSaving': 'True'}

Activate 5GC000431 and CB008392 feature flags
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'actNrLBPowerSaving': 'True', 'actNrLBRTXPowerSaving': 'True'}

Activate 5GC000431, CB008745 and CB008392 feature flags
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'actLbpsCtrlLogicEnh': 'True', 'actNrLBPowerSaving': 'True', 'actNrLBRTXPowerSaving': 'True'}

Wait ${timeout}s for cells [${cells_ids}] energySavingState change to ${expected_states}
    Wait Until Keyword Succeeds  ${timeout}s  5s
    ...  Check for cells [${cells_ids}] if energySavingState equals ${expected_states}

Attach UE${ue_id:\d+} to gNB${gnb_id:\d+} cell${cell_id:\d+} with 1 non-GBR and 1 GBR 5QI${5qi_id:\d+} bearer
    EXPECT FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    EXPECT FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry

    Attach UE${ue_id} without ICS to gNB${gnb_id} cell${cell_id}
    Add to UE${ue_id} initial PDU session with ICS including 1 nonGBR and 1 GBR 5QI${5qi_id} QoS flow

    PASS FLOW[timeout=10]: AMF1 NGAP initialContextSetup
    PASS FLOW[timeout=10]: AMF1 NGAP uERadioCapabilityInfoIndication
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UECapabilityEnquiry

Add to UE${ue_id:\d+} ${session_type:(initial|second|third)} PDU session with ICS including 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} QoS flow
    ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi_id}
    Execute egate command  cmd=smf_param id=1 additional_qosflows_to_activate=${QoS_FLOW_ID}
    Add to UE${ue_id} ${session_type} PDU session with ICS
    Execute egate command  cmd=smf_param id=1 reset

Attach UEs[${ue_ids}] to gNB${gnb_id:\d+} cell${cell_id:\d+} with 1 non-GBR and 1 GBR 5QI${5qi_id:\d+} bearer
    @{ue_list}=   Split To List   ${ue_ids}
    FOR   ${ue_id}   IN   @{ue_list}
        Attach UE${ue_id} to gNB${gnb_id} cell${cell_id} with 1 non-GBR and 1 GBR 5QI${5qi_id} bearer
    END

Attach UE${ue_id:\d+} to gNB${gnb_id:\d+} cell${cell_id:\d+} with 1 non-GBR bearer
    Attach UE${ue_id} to gNB${gnb_id} cell${cell_id} with ICS during PDU session setup

Attach UEs[${ue_ids}] to gNB${gnb_id:\d+} cell${cell_id:\d+} with 1 non-GBR bearer
    @{ue_list}=   Split To List   ${ue_ids}
    FOR   ${ue_id}   IN   @{ue_list}
        Attach UE${ue_id} to gNB${gnb_id} cell${cell_id} with 1 non-GBR bearer
    END

Run ${traffic_rate:\d+}Mbps ${direction:(UL|DL)} traffic on UE${ue_id:\d+} ${bearer_type:GBR|non-GBR} bearer and wait ${seconds:\d+}s
    Run keyword if   '${bearer_type}' == 'non-GBR'
    ...   Run ${traffic_rate}Mbps ${direction} traffic on UE${ue_id} PDU1 QFI1 and wait ${seconds} seconds
    Run keyword if   '${bearer_type}' == 'GBR'
    ...   Run ${traffic_rate}Mbps ${direction} traffic on UE${ue_id} PDU1 QFI2 and wait ${seconds} seconds

Run ${traffic_rate:\d+}Mbps ${direction:(UL|DL)} traffic on UEs[${ue_ids}] ${bearer_type:GBR|non-GBR} bearer
    @{ue_list}=   Split To List   ${ue_ids}
    FOR   ${ue_id}   IN   @{ue_list}
        Run ${traffic_rate}Mbps ${direction} traffic on UE${ue_id} ${bearer_type} bearer and wait 0s
    END

Stop ${traffic_rate:\d+}Mbps ${direction:(UL|DL)} traffic on UE${ue_id:\d+} ${bearer_type:GBR|non-GBR} bearer and wait ${seconds:\d+}s
    Run keyword if   '${bearer_type}' == 'non-GBR'
    ...   Stop ${traffic_rate}Mbps ${direction} traffic on UE${ue_id} PDU1 QFI1
    Run keyword if   '${bearer_type}' == 'GBR'
    ...   Stop ${traffic_rate}Mbps ${direction} traffic on UE${ue_id} PDU1 QFI2
    sleep  ${seconds}

Stop ${traffic_rate:\d+}Mbps ${direction:(UL|DL)} traffic on UEs[${ue_ids}] ${bearer_type:GBR|non-GBR} bearer
    @{ue_list}=   Split To List   ${ue_ids}
    FOR   ${ue_id}   IN   @{ue_list}
        Stop ${traffic_rate}Mbps ${direction} traffic on UE${ue_id} ${bearer_type} bearer and wait 0s
    END

Detach UEs[${ue_ids}]
    @{ue_list}=   Split To List   ${ue_ids}
    FOR   ${ue_id}   IN   @{ue_list}
        Deregister UE${ue_id} and kill if failed
    END

Modify NRPGRP-${id:\d+}.lbpsSOnTrRule to ${rule:MinValueMethod|SlidingAverageMethod}
    Configure  [{'MOC': 'NRPGRP', 'ID': '${id}', 'lbpsSOnTrRule': '${rule}'}]

Modify NRPGRP-${id:\d+}.lbpsSOffTrRule/lbpsSOnTrRule to SlidingAverageMethod
    Configure  [{'MOC': 'NRPGRP', 'ID': '${id}', 'lbpsSOffTrRule': 'SlidingAverageMethod', 'lbpsSOnTrRule': 'SlidingAverageMethod'}]

Modify NRPGRP-${id:\d+}.lbpsSOffTrRule/lbpsSOnTrRule to ${rule_off}/${rule_on}
    Should match regexp  ${rule_off}  MaxValueMethod|SlidingAverageMethod
    Should match regexp  ${rule_on}  MinValueMethod|SlidingAverageMethod
    Configure  [{'MOC': 'NRPGRP', 'ID': '${id}', 'lbpsSOffTrRule': '${rule_off}', 'lbpsSOnTrRule': '${rule_on}'}]

Modify NRPGRP-${id:\d+}.lbpsLoadCalcMethod to "${method:Max\(G, C, P\)|Max\(G_N_combined, P\)}"
    Configure  [{'MOC': 'NRPGRP', 'ID': '${id}', 'lbpsLoadCalcMethod': '${method}'}]

Modify NRPGRP-${id:\d+}.lbpsSOMethod to '${method_1}', NRPGRP-2.lbpsSOMethod to '${method_2}'
    Should match regexp  ${method_1}  cell switch off|TX switch off
    Should match regexp  ${method_2}  cell switch off|TX switch off
    Configure  [{'MOC': 'NRPGRP', 'ID': '${id}', 'lbpsSOMethod': '${method_1}'}, {'MOC': 'NRPGRP', 'ID': '2', 'lbpsSOMethod': '${method_2}'}]

Set NRPGRP-${id:\d+}.lbpsPeriodList.lbpsSuspended to ${suspension:suspended|notSuspended} for all periods
    Create new plan
    FOR  ${i}  IN RANGE  0  7
      Edit Planned Object Attributes   NRPGRP-${id}  lbpsPeriodList.lbpsSuspended[${i}]=${suspension}
    END
    Apply planned changes

Remove nrCellId=2 from NRPGRP-${id:\d+}
    Configure  [{'MOC': 'NRPGRP', 'ID': '${id}', 'lbpsCellList': [{'lbpsCellSOOrder': '1', 'nrCellId': '1'}] }]

Restore nrCellId=2 to NRPGRP-${id:\d+}
    ${lbpsCellList}  catenate  {'MOC': 'NRPGRP', 'ID': '${id}', 'lbpsCellList': [{'lbpsCellSOOrder': '1', 'nrCellId': '1'},
    ...                                                                          {'lbpsCellSOOrder': '2', 'nrCellId': '2'}]}
    Configure  [${lbpsCellList}]

Lock nrCellId=${cell_id}
    coam.lock   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=${100}  connection=${ADMIN_CONNECTION}

Unlock nrCellId=${cell_id}
    coam.unlock   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  timeout=${100}  connection=${ADMIN_CONNECTION}

Remove NRPGRP-1
    Configure_delete  NRPGRP-1

Restore NRPGRP-1 with cell1 and cell2
    Configure  ${1_NRPGRP_2_cells}  node_id=1

Create icom_5g json source
    Create json source
    set_tshark_command
    ...    sshpass -p oZPS0POrRieRtu ssh toor4nsn@10.0.1.2 -p 22 "tcpdump -i any sctp -s 0 -U -n -w -"
    ...    | tshark -r - -T json -l -Y "icom_5g and !(sctp.retransmission)"
    set filter as string    ${icom_prefix}.MeasuredGBRNBRCellLoad
    start json source

Verify that in Power Saving load measurement is differentiation between GBR and nonGBR traffic type for cell${cell_id}
    Create icom_5g json source
    ${nrCellGrpId}=     Evaluate    ${cell_id} - ${1}
    ${expected_records}=    Catenate
    ...    (${icom_prefix}.MeasuredGBRNBRCellLoad gt "0") and
    ...    (${icom_prefix}.MeasurednGBRnNBRCellLoad ge "0") and
    ...    (${icom_prefix}.MeasuredCBnGBRCellLoad ge "0") and
    ...    (${icom_prefix}.nrCellGrpId eq "${nrCellGrpId}")

    clear records
    Expect for records
    ...    ${expected_records}
    ...    timeout=10
    ...    expect_alias=PSLoad
    verify_that_records_occurred    expect_alias=PSLoad
    ${flow_records}=   get_records_from_flow  expect_alias=PSLoad
    stop json source

Verify that in Power Saving load measurement is no differentiation between GBR and nonGBR traffic type for cell${cell_id}
    Create icom_5g json source
    ${actLbpsCtrlLogicEnh_value}=    get enb parameter value    NRBTS-1    actLbpsCtrlLogicEnh
    ${condition_for_CBnGBR}=  Set Variable If  ${actLbpsCtrlLogicEnh_value}==${TRUE}  ge  eq

    ${nrCellGrpId}=     Evaluate    ${cell_id} - ${1}
    ${expected_records}=    Catenate
    ...    (${icom_prefix}.MeasuredGBRNBRCellLoad eq "0") and
    ...    (${icom_prefix}.MeasurednGBRnNBRCellLoad gt "0") and
    ...    (${icom_prefix}.MeasuredCBnGBRCellLoad ${condition_for_CBnGBR} "0") and
    ...    (${icom_prefix}.nrCellGrpId eq "${nrCellGrpId}")

    clear records
    Expect for records
    ...    ${expected_records}
    ...    timeout=10
    ...    expect_alias=PSLoad
    verify_that_records_occurred    expect_alias=PSLoad
    ${flow_records}=   get_records_from_flow  expect_alias=PSLoad
    stop json source
