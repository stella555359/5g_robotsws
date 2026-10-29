*** Settings ***
Library  String
Library  taf.sbts.oam.coam.admin
Library  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/webem_operations.py
Library  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/counter_helpers.py
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/logs_collection.robot


*** Variables ***
${scf_file_gnb}     testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB009324/resources/MRBTS_50069
${scf_file_enb}     testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB009324/resources/LNBTS_40069.xml
${scf_file_gnb_tdd}  tba
${scf_file_enb_tdd}  tba
${enb_mplane}       ${tl.enbs[0].m.v4}
${enb_bts_id}       ${tl.enbs[0].instance_id}
${nr_bts_id}        ${tl.gnbs[0].instance_id}
${counters_interval}  5m
${tdd_cell_id}  4
${onair_timer}  20m

# COUNTERS
${f1_qos_counter}  M55323C01009
${x2_qos_counter}  M55313C08009
${drop_counter}    M55313C04009

*** Keywords ***
Is Trunk
    [Arguments]  ${sw}
    ${res}  run keyword and return status  should contain  ${sw}  9999
    [Return]  ${res}

Perform commissioning CB009324 gnb
    Connect to  name=get_sw_name
    ${release_name}  Get Sw Release Name  connection=get_sw_name
    ${scf_path}  set variable  ${scf_file_gnb}_${release_name}.xml

    activate_scf_commissioning  ${scf_path}
    wait until keyword succeeds  ${onair_timer}  10s  verify_nr_cells_are_on_air

    [Teardown]  taf.sbts.oam.coam.admin.Teardown  connection=get_sw_name


Perform commissioning CB009324 enb
    activate_scf_commissioning  ${scf_file_enb}  enb_host=${enb_mplane}
    wait until keyword succeeds  ${onair_timer}  10s  verify_enb_cells_are_on_air  enb_host=${enb_mplane}


Perform commissioning CB009324 gnb tdd
    activate_scf_commissioning  ${scf_file_gnb_tdd}
    wait until keyword succeeds  ${onair_timer}  10s  verify_nr_cells_are_on_air


Perform commissioning CB009324 etdd
    activate_scf_commissioning  ${scf_file_enb_tdd}  enb_host=${enb_mplane}
    wait until keyword succeeds  ${onair_timer}  10s  verify_enb_cells_are_on_air  enb_host=${enb_mplane}


Prepare TL for CB009234
    log to console  Preparing gNB...
    Perform commissioning CB009324 gnb
    log to console  Preparing eNB...
    Perform commissioning CB009324 enb

Activate feature
    create delta

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}
    ...  actL2TrafficShapingXx
    ...  true

    ${delta}  get delta

    activate_delta_recommissioning  ${delta}
    wait until keyword succeeds  ${onair_timer}  10s  verify_nr_cells_are_on_air

Deactivate feature
    create delta

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}
    ...  actL2TrafficShapingXx
    ...  false

    ${delta}  get delta

    activate_delta_recommissioning  ${delta}
    wait until keyword succeeds  ${onair_timer}  10s  verify_nr_cells_are_on_air


Deactivate LTE CA
    create delta

    append parameter update to delta
    ...  MRBTS-${enb_bts_id}/LNBTS-${enb_bts_id}
    ...  actCAggrLteNrDualConnectivity
    ...  disabled

    ${delta}  get delta

    activate_delta_recommissioning  ${delta}  enb_host=${enb_mplane}
    wait until keyword succeeds  ${onair_timer}  10s  verify_enb_cells_are_on_air  enb_host=${enb_mplane}


Activate LTE CA
    create delta

    append parameter update to delta
    ...  MRBTS-${enb_bts_id}/LNBTS-${enb_bts_id}
    ...  actCAggrLteNrDualConnectivity
    ...  blind_CA_LTE_NR

    ${delta}  get delta

    activate_delta_recommissioning  ${delta}  enb_host=${enb_mplane}
    wait until keyword succeeds  ${onair_timer}  10s  verify_enb_cells_are_on_air  enb_host=${enb_mplane}


Wait for counters interval
    log to console  Waiting ${counters_interval} for counters.
    sleep  ${counters_interval}


Get M55323C01009 counter
    log to console  Getting ${f1_qos_counter}...
    ${res}  get counter values  ${f1_qos_counter}
    ${last}  get_last_counters_values
    ...  ${res['BTS']['MRBTS-${nr_bts_id}']['NRBTS-${nr_bts_id}']['NF1UB']}

    [Return]  ${last}


Get M55313C08009 counter
    log to console  Getting ${x2_qos_counter}...
    ${res}  get counter values  ${x2_qos_counter}
    ${last}  get_last_counters_values
    ...  ${res['BTS']['MRBTS-${nr_bts_id}']['NRBTS-${nr_bts_id}']['NX2UB']}

    [Return]  ${last}


Get M55313C04009 counter
    log to console  Getting ${drop_counter}...
    ${res}  get counter values  ${drop_counter}
    ${last}  get_last_counters_values
    ...  ${res['BTS']['MRBTS-${nr_bts_id}']['NRBTS-${nr_bts_id}']['NX2UB']}

    [Return]  ${last}


Activate retransimission
    log to console  Activating retransmission
    create delta

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRDRB-2
    ...  actLostPduFastRetx
    ...  true

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRDRB-2
    ...  reTxPrioritizationType
    ...  retxPrioSameLink


    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRDRB-2
    ...  dlFlowControlAlgo
    ...  3gppFlowControl

    ${delta}  get delta
    activate_delta_recommissioning  ${delta}
    wait until keyword succeeds  ${onair_timer}  10s  verify_nr_cells_are_on_air


Lock FDD cells
    log to console  Locking FDD cells...
    lock_all_cells_except  ${tdd_cell_id}


Unlock FDD cells
    log to console  Unlocking FDD cells...
    unlock_all_cells_except  ${tdd_cell_id}

Compare Tput Values
    [Arguments]    ${t1}    ${t2}    ${dev}=0.85
    ${comp}    evaluate    ${t2} * ${dev}
    should be true    ${t1} >= ${comp}    Tput ${t1} is much lower than ${t2}