*** Settings ***
Documentation  Test specific keyword file.

Library  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/webem_operations.py
Library  taf.sbts.oam.coam.admin
Library  ta5g_ue_mobility
Library  ta5g_throughput

*** Variables ***
${NR_BTS_ID}  1
${rank_counter}  M55301C10004
${counter_interval}  5min
${test_cell}  1
${ue_id}      1
${pdu_id}     1
${gw_id}      1
${nwslice}    1
${gnb_id}     1

*** Keywords ***
Perfom commissioning for 5GC002139
    [Documentation]  Set proper counter interval. The best option is to use minimal interval. 5min by default.

    log to console  Perform 5GC002139 commissioning...

    create delta

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRPMRNL-1
    ...  miNrDlSignalQuality
    ...  ${counter_interval}

    ${delta}  get delta
    activate_delta_recommissioning  ${delta}

Wait for counter interval
    log to console  Waiting ${counter_interval} for ${rank_counter}
    sleep  ${counter_interval}

Get M55301C10004 counter
    [Arguments]  ${target_cell}=${test_cell}
    log to console  Getting ${rank_counter}
    ${res}  get counter values  ${rank_counter}
    ${last}  get_last_counters_values
    ...  ${res['BTS']['MRBTS-${NR_BTS_ID}']['NRBTS-${NR_BTS_ID}']['NRCELL-${target_cell}']['NDLSQ']}

    [Return]  ${last}

Attach ue to test cell
    change_ue_location  ${ue_id}  dst_enb=1  dst_cell=${test_cell}
    attach_ue  ${ue_id}

Perform downlink ue tput
    establish pdu session with traffic  ${ue_id}  direction=dl  throughput=116Mbps

Attach ue to cell and perform tput
    Attach UE    ue_id=${ue_id}    cell=${test_cell}    enb=${gnb_id}
    ...    pass_regexp=Received REGISTRATION COMPLETE from UE

    establish pdu session with traffic  ${ue_id}  ${pdu_id}  ${nwslice}  ${gw_id}  throughput=175mbps

Stop tput and detach ue
    run keyword and ignore error  stop_data_traffic  ${ue_id}
    run keyword and ignore error  detach all ues
