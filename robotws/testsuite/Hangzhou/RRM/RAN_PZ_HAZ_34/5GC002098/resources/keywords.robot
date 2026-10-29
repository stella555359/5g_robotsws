*** Settings ***
Library         testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/DeltaStore.py
Library         testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/AdminHelper.py
Library         testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/counters/Counters.py
Library         taf.transport.ssh  WITH NAME  ssh
Library         taf.sbts.oam.coam.admin  WITH NAME  coam
Library         SSHLibrary
Library         Collections
Library         DateTime
Library         OperatingSystem
#Library         ute_ue
Library          taf.ue
Resource        testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/setup_teardown.robot
Resource        testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/common_kw.robot
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***
${IP_ADDR}        ${tl.gnbs[0].cu.oam_http_connection_details.addr}
&{beamSet_list_params}      basicBeamSet=beamSetAbf_1A    leftEdgeAngle=90    rightEdgeAngle=90

*** Keywords ***
Perform commissioning 5GC002098
    [Arguments]             ${queuingDelayDiscardEnabled}=true
    ...                     ${dlFlowControlAlgo}=3gppFlowControl
    ...                     ${reportingIntervalPm}=15min
    ...                     ${alias}=coam
    ...                     ${chBw}=100MHz
    ...                     ${type0CoresetConfigurationIndex}=0
    ...                     ${actDl256Qam}=false
    ...                     ${actGeneralConnectivitySilver}=true
    ...                     ${queuingDelaySduDiscardThreshold}=50
    ...                     ${numberOfTransmittedSsBlocks}=1 beam
    Log to console          Perform commissioning with given parameters.
    ${cell_ids}    Get cell ids
    Initialise delta store
    ${nrcellgrp_path}       Set variable    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELLGRP-
    ${pmcadm_path}          Set variable    MRBTS-${bts_id}/MNL-1/MNLENT-1/PMCADM-1
    ${nrdrb_path}           Set variable    MRBTS-${bts_id}/NRBTS-${bts_id}/NRDRB-
    ${nrcell_path}          Set variable    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-
    coam.Connect to         bts_host=${IP_ADDR}         name=${alias}
    ${nrcellgrp_objects}    coam.Get managed objects    class_name=NRCELLGRP_A   connection=${alias}
    FOR  ${nrcellgrp}  IN  @{nrcellgrp_objects}
        ${index}            Fetch from right  ${nrcellgrp['distName']}  -
        Add param to delta  ${nrcellgrp_path}${index}    numberOfTransmittedSsBlocks        value=${numberOfTransmittedSsBlocks}
    END
    ${nrdrb_objects}        coam.Get managed objects    class_name=NRDRB_A   connection=${alias}
    FOR  ${nrdrb}  IN  @{nrdrb_objects}
        ${index}            Fetch from right  ${nrdrb['distName']}  -
        Add param to delta  ${nrdrb_path}${index}   queuingDelayDiscardEnabled              value=${queuingDelayDiscardEnabled}
        Add param to delta  ${nrdrb_path}${index}   dlFlowControlAlgo                       value=${dlFlowControlAlgo}
        Add param to delta  ${nrdrb_path}${index}   queuingDelaySduDiscardThreshold         value=${queuingDelaySduDiscardThreshold}
    END
    Add param to delta      ${pmcadm_path}          reportingIntervalPm                     value=${reportingIntervalPm}
    ${nrcell_objects}        coam.Get managed objects    class_name=NRCELL_A   connection=${alias}
    FOR  ${nrcell}  IN  @{nrcell_objects}
       ${index}            Fetch from right  ${nrcell['distName']}  -
       Add param to delta  ${nrcell_path}${index}                  type0CoresetConfigurationIndex      value=${type0CoresetConfigurationIndex}
       Add param to delta  ${nrcell_path}${index}                  actDl256Qam                         value=${actDl256Qam}
       Add param to delta  ${nrcell_path}${index}                  chBw                                value=${chBw}
       Add param to delta  MRBTS-${bts_id}/NRBTS-${bts_id}         actGeneralConnectivitySilver        value=${actGeneralConnectivitySilver}
       Add List Parameters To Delta  ${nrcell_path}${index}        beamSet                             &{beamSet_list_params}
    END
    ${delta}                Collect delta store
    Recommission with delta from admin  ${delta}
    Wait until keyword succeeds    900 sec    60 sec    Verify all cells are onair with admin
    [Teardown]              coam.Teardown     connection=${alias}

Check M55320C09009 counter
    [Arguments]             ${alias}=coam   ${counter_id}=M55320C09007
    Log to console          Check if ${counter_id} counter value is updated
    coam.Connect to         bts_host=${IP_ADDR}         name=${alias}
    ${counter_dist_name}  Set variable  BTS/NRBTS-${bts_id}/PDCP2
    ${counters}  Get counter values  dist_name=${counter_dist_name}  counter_id=${counter_id}  connection=${alias}
    ${dates}                Get dictionary keys    ${counters}
    Sort list               ${dates}
    Reverse list            ${dates}
    ${newest_counter_value}     Get from dictionary    ${counters}    ${dates[0]}
    Should not be equal as integers   ${newest_counter_value}    0    msg=Counter value equal 0    values=${False}
    Log to console          ${counter_id} counter value: ${newest_counter_value} is greater than 0
    [Teardown]              coam.Teardown     connection=${alias}

Require ue and cell
    [Arguments]             ${ue_alias}=AT_BASED_UE_1
    ...                     ${ue_capabilities}=REAL_QUALCOMM_UE
    ...                     ${lncell_alias}=ENB_1_CELL_1
    ...                     ${lnbts_id}=${tl.enbs[0].global_bts_id}
    ...                     ${pcid}=1
    Require ue          ${ue_alias}   ${ue_capabilities}
    Require cell        ${lncell_alias}    ${lnbts_id}   ${pcid}
    Set ue location     ${ue_alias}    ${lncell_alias}

Perform data transfer and detach ue
    [Arguments]             ${dt_alias}
	... 					${ue_alias}
    ...                     ${direction}
    ...                     ${duration}
    ...                     ${throughput}
    ...                     ${protocol}
    Log to console      Perform ${throughput} ${direction} data transfer for ${duration}
    taf.ue.Require Ue          ${ue_alias}   capabilities=REAL_UE
    taf.ue.Start Data Transfer  dt_name=DT_DL_1  ue_alias=AT_BASED_UE_1  direction=dl  duration=${duration}    throughput=${throughput}
    ...                 dt_name=${dt_alias}
    ...                 ue_alias=${ue_alias}
    ...                 direction=${direction}
    ...                 duration=${duration}
    ...                 throughput=${throughput}
    ...                 protocol=${protocol}
    ...                 packet_size=1400
    ...                 buffer=8M
    #...                 max_segment_size=1400
    Sleep               10
    taf.ue.Await Data Transfer Finish  DT_DL_1
    [Teardown]          power_ue.UE Detach    ue_type=samsung

Verify t-put
    [Arguments]             ${dt_alias}
    ...                     ${throughput}
    ...                     ${t-put_deviation}
    ...                     ${datagram_loss_allowed}
    ...                     ${udp_protocol}=${TRUE}
    Log to console      Verify average throughput (${throughput}) with deviation with ${t-put_deviation} deviation
    taf.ue.Verify average throughput with deviation    ${dt_alias}    ${throughput}   ${t-put_deviation}
    Run keyword if      ${udp_protocol}
    ...                 taf.ue.Verify throughput with datagram loss    ${dt_alias}   ${datagram_loss_allowed}

Queuing_Delay_UDP_Case_Steps
    Perform commissioning 5GC002098
    ${5Grach_ed}    power_ue.UE Attach    ue_type=samsung    attach_mode=5G_NSA
    power_ue.Verify attach    ue_type=samsung    5Grach_ed=${5Grach_ed}    4G_check=False
    Perform data transfer and detach ue
    ...     dt_alias=${DT_ALIAS}
    ...     ue_alias=${UE_ALIAS}
    ...     direction=DL
    ...     duration=${TPUT_DURATION}
    ...     throughput=${TPUT_BANDWITH}
    ...     protocol=udp
    Verify t-put
    ...     dt_alias=${DT_ALIAS}
    ...     throughput=${TPUT_BANDWITH}
    ...     t-put_deviation=${TPUT_DEVIATION}
    ...     datagram_loss_allowed=40%
    ...     udp_protocol=${TRUE}
    Wait for counters  1 min
    Check M55320C09009 counter

Queuing_Delay_TCP_Case_Steps
    Perform commissioning 5GC002098
    ${5Grach_ed}    power_ue.UE Attach    ue_type=samsung    attach_mode=5G_NSA
    power_ue.Verify attach    ue_type=samsung    5Grach_ed=${5Grach_ed}    4G_check=False
    Perform data transfer and detach ue
    ...     dt_alias=${DT_ALIAS}
    ...     ue_alias=${UE_ALIAS}
    ...     direction=DL
    ...     duration=${TPUT_DURATION}
    ...     throughput=${TPUT_BANDWITH}
    ...     protocol=tcp
    Verify t-put
    ...     dt_alias=${DT_ALIAS}
    ...     throughput=${TPUT_BANDWITH}
    ...     t-put_deviation=${TPUT_DEVIATION}
    ...     datagram_loss_allowed=40%
    ...     udp_protocol=${FALSE}
    Wait for counters  1 min
    Check M55320C09009 counter
