*** Settings ***
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/cplane_collector.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.robot

*** Variables ***
${NR_BTS_ID}                ${tl.gnbs[0].instance_id}
${ENB_BTS_ID}               ${tl.enbs[0].instance_id}
${ps3_param_path_nr}        MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}
${ps3_param_path_enb}       MRBTS-${ENB_BTS_ID}/LNBTS-${ENB_BTS_ID}
# Cell which should be in power saving status regarding to feature SCF configuration
${PS_CELL_ID_NR}            53
${PS_CELL_PATH_NR}          ${ps3_param_path_nr}/${PS_CELL_ID_NR}

*** Keywords ***
Perform SCF Commissioning CB011036_CB010137
    Log to console                      __Performing Power Saving Part 3 SCF commissioning
    Connect with runtime release        comm
    coam.perform commissioning          ${MRBTS_5G_ID}  ${SCF_10986}  ${True}  ${True}  600  comm
    Wait until keyword succeeds         20min   30s   Verify all cells are onair with admin
    [Teardown]    coam.teardown  connection=comm


Avtivate DSS Power sainvg
    log to console    __Ativating DSS power saving...
    Initialise delta store

    add param to delta        ${ps3_param_path_nr}          actCoordEnDssPowerSaving       true
    add param to delta        ${ps3_param_path_nr}          actNrLBPowerSaving             true
    add param to delta        ${ps3_param_path_nr}          actCoordinated4g5gPowerSaving  cellDeactAndReact

    ${delta}                             Collect delta store
    Recommission with delta from admin   ${delta}
    Verify all cells are onair with admin


Check power saving status
    Connect with runtime release    cell_status

    ${cell_status}    coam.get cell specific info
    ...    cell_id=${PS_CELL_PATH_NR}
    ...    connection=cell_status

    # Comparision is based on WEBEM info status of a cell.
    should be equal    ${cell_status['energySavingState']}    energySaving

    [Teardown]    coam.teardown    connection=cell_status


Wait for energy cell energy saving satus
    [Documentation]  Max timeout can be calculated by $max_retry * $interval . By default set to 15mins.
    [Arguments]    ${max_retry}=30x    ${interval}=30s

    log to console    __Wait for energy saving status of a cell...
    Wait until keyword succeeds    ${max_retry}    ${interval}    Check power saving status


Convert and check cplane messages
    ${cplane_pcap_path}     set variable    ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/cplane_collector.pcap
    ${cplane_pdml_path}     Convert pcap to pdml    ${cplane_pcap_path}
    ${cplane_pdml}          Convert pcap to pdml    ${cplane_pcap_path}


Check alarms after cell reached power saving
    coam.connect to                                name=alarm_conn
    # lmp access
    coam.add allowed alarm    faultId=61649        connection=alarm_conn
    # sanity check
    coam.add allowed alarm    faultId=4681         connection=alarm_conn
    # service account
    coam.add allowed alarm    faultId=4655         connection=alarm_conn
    # ssh enabled
    coam.add allowed alarm    faultId=61524        connection=alarm_conn
    # eth port security
    coam.add allowed alarm    faultId=4654         connection=alarm_conn
    # A3 / A5 events -  not related with feature
    coam.add allowed alarm    faultId=8150         connection=alarm_conn
    # R&D port enabled
    coam.add allowed alarm    faultId=61652        connection=alarm_conn
    # pps reference missing - due to gps lab problems
    coam.add allowed alarm    faultId=1898        connection=alarm_conn

    coam.assert_no_unexpected_active_alarms        connection=alarm_conn
    [Teardown]    coam.teardown
