*** Settings ***
Documentation
...   Resource files for regression testing of feature 5GC002033
...   author: Dominik Baran
...   contact: dominik.baran@nokia.com

Library     BuiltIn
Library     taf.gnb.oam.coam.admin                 WITH NAME    coam
Library     taf.config.scf                         WITH NAME    scf
Library     taf.rfrl.bts.devices.du.commissioning.EnbCommissioning    WITH NAME      enbscf

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables   ../resources/5GC002033_deltas.py
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${runs_success_rate}            ${10}
${runs_time_duration}           ${10}
${current_config}               0EXT
${capabilities}    REAL_UE
${deviation}     25%
${size_packet_dl}    1400B
${size_packet_ul}    1320B
${tput_dl}    500 MBits/sec
${tput_ul}    60 MBits/sec
${parallel_streams_ul}    2
${parallel_streams_dl}    2
${buffer_client_dl_udp}    8M
${buffer_server_dl_udp}    8M
${buffer_client_ul_udp}    2M
${buffer_server_ul_udp}    2M
${interval}    1
${reboot_ue}    True
${timeout_reboot_ue}    100
${tput_dl_without_cell}    500 MBits/sec
${tput_ul_without_cell}    60 MBits/sec
${protocol}    udp
${require_ue}    True
${duration}    1min
${COLLECT_LOGS_DURING_DATA_TRANSFER}    False
${SITE_RESET_ITERATIONS}    10
${TARGETS}   560

*** Keywords ***
Common suite setup with UE preparation
    Common Suite Setup With OnAir Test Line Preparation
    Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${True}

Activate configuration successful with 4CC 2DL 2UL 4CC 0DL 0UL
    Perform Delta Commissioning On gNB    ${delta_2CC_UL}  skip_parameter_relation_errors=${True}
    Wait until keyword succeeds  10min  1min  Verify gNB is onAir

Activate configuration successful with 4CC 2DL 2UL 4CC 2DL 0UL
    Perform Delta Commissioning On gNB    ${delta_4CC_UL}  skip_parameter_relation_errors=${True}
    Wait until keyword succeeds  10min  1min  Verify gNB is onAir

Change NR cell for ENDC on eNB
    [Arguments]    ${lncell_id}    ${desired_5g_cell_pci}
    enbscf.perform_configuration_parameter_recommissioning    operation=update    bts_id=0    du_id=${0}
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].global_bts_id}/LNCEL-${lncell_id}
    ...    parameter=defaultLnRelGnbCellId    value=${desired_5g_cell_pci}
    ...    skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}

Perform attach and verify throughput
    Verify L3 Call Data Transfer DL&UL    duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    ...    protocol=${protocol}    deviation_dl=${deviation}    deviation_ul=${deviation}
    ...    parallel_streams_dl=${parallel_streams_dl}    parallel_streams_ul=${parallel_streams_ul}
    ...    size_packet_dl=${size_packet_dl}    size_packet_ul=${size_packet_ul}    buffer_client_dl=${buffer_client_dl_udp}
    ...    buffer_server_dl=${buffer_server_dl_udp}    buffer_client_ul=${buffer_client_ul_udp}    buffer_server_ul=${buffer_server_ul_udp}
    ...    interval=${interval}

Perform attach and verify throughput on every 2DL2UL NR cell
    FOR  ${nr_cell_id}  IN RANGE  0  4
        Change NR cell for ENDC on eNB    1    ${nr_cell_id}
        Perform attach and verify throughput
    END

Allow alarms on BTS during test
    gnb_alarm.Allow Alarm         No connection to unit

Disallow alarms on BTS after test
    gnb_alarm.Disallow Alarm      No connection to unit

Common Preconditions With Commissioning and watching alarms for config with ${ext_num} units
     Common Preconditions With Commissioning and watching alarms    ${ext_num}
