*** Settings ***
Documentation
...   Common keywords for regression testing of feature CB013351
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Resource    testsuite/Krakow/SISO/resources/RAN_PZ_KRK2/CB011050/keywords.robot
Library     testsuite.Krakow.resources.RAN_PZ_KRK2.SMAWave.SMAWaveTput    WITH NAME    SMAWave

*** Keywords ***
CB013351 Suite setup
    Common suite setup with onAir Test Line preparation
    ...    prefix_tag=CB013351
    Set suite variable    ${C2A_DELTA_TEST_FAILED}    ${False}

CB013351 Common test setup
    [Arguments]    ${tc_cell_operation_list}
    Set test variable    ${L3_CALL_STATUS}    ${True}
    Common preconditions with watching alarms
    gnb_alarm.Allow alarm    Cell blocked
    Perform cell block unblock operations from list    cell_operation_list=${tc_cell_operation_list}
    Verify gNB is onAir
    gnb_alarm.Disallow alarm    Cell blocked

CB013351 C2A test teardown
    Common postconditions with watching alarms
    Run keyword if test failed    Set suite variable
    ...                           ${C2A_DELTA_TEST_FAILED}
    ...                           ${True}

CB013351 C2A test setup
    [Arguments]    ${tc_cell_operation_list}
    Run keyword if    ${C2A_DELTA_TEST_FAILED}==${True}
    ...               Run keywords
    ...               Perform full commissioning on gNB
    ...               scf_file=testsuite/Krakow/SISO/regression/RAN_PZ_KRK2/CB013351/scfs/c2a_scf.xml
    ...               AND
    ...               Wait until keyword succeeds
    ...               360 sec
    ...               10 sec
    ...               gnbcell.Verify all cells are OnAir
    CB013351 Common test setup    tc_cell_operation_list=${tc_cell_operation_list}

Perform cell block unblock operations from list
    [Arguments]    ${cell_operation_list}
    FOR    ${operation}    IN     @{cell_operation_list}
        Run keyword if    "${operation["name"]}"=="block"
        ...    Block cell and wait for blocked    cell_id=${operation["cell_id"]}
        ...    ELSE
        ...    Unblock cell and wait for onAir    cell_id=${operation["cell_id"]}
    END

Unblock cell and wait for onAir
    [Arguments]    ${cell_id}
    gnbcell.Unblock cell    cell_id=${cell_id}
    gnbcell.Wait for cell to be onAir    cell_id=${cell_id}
    gnbcell.Verify cell is unblocked    cell_id=${cell_id}

Block cell and wait for blocked
    [Arguments]    ${cell_id}
    gnbcell.Block cell    cell_id=${cell_id}
    Wait until keyword succeeds    60 sec    10 sec    gnbcell.Verify cell is blocked    cell_id=${cell_id}

Perform Android UE L3 call on LTE cell using qrxlevmin
    [Arguments]    ${cells_for_l3_call}    ${ue}    ${bts_id}    ${prepare_ue}=${True}
    Run keyword if    ${prepare_ue} == ${True}
    ...    Prepare UE for L3 call    capabilities=${ue}    alias=${ue}
    ${cell_ids}    Get dictionary keys    ${cells_for_l3_call}
    FOR    ${cell_id}    IN     @{cell_ids}
        Perform Android UE L3 call on selected LTE cell using qrxlevmin
        ...    cell_id=${cell_id}
        ...    tput_dl=${cells_for_l3_call["${cell_id}"]["tput_dl"]}
        ...    tput_ul=${cells_for_l3_call["${cell_id}"]["tput_ul"]}
        ...    deviation=5%
        ...    parallel_streams_dl=4
        ...    parallel_streams_ul=12
        ...    bts_id=${bts_id}
        ...    ue=${ue}
    END
    Run keyword if    ${L3_CALL_STATUS}==${False}    Fail    Tput not as expected

Perform Android UE L3 call on selected LTE cell using qrxlevmin
    [Arguments]    ${cell_id}    ${tput_dl}    ${tput_ul}    ${deviation}    ${bts_id}    ${ue}
    ...            ${parallel_streams_dl}=4    ${parallel_streams_ul}=2
    Set qRxLevMin on LTE cell    bts_id=${bts_id}
    ...                          cell_id=${cell_id}
    ...                          value=-90
    Log to console    Run tput on cell ${cell_id}
    ${status}    Run keyword and ignore error
    ...    Verify L3 call data transfer DL&UL
    ...    duration=60s
    ...    tput_dl=${tput_dl}
    ...    tput_ul=${tput_ul}
    ...    protocol=tcp
    ...    deviation=${deviation}
    ...    parallel_streams_dl=${parallel_streams_dl}
    ...    parallel_streams_ul=${parallel_streams_ul}
    ...    size_packet=1400B
    ...    alias=${ue}
    Analyse L3 call status
    ...    l3_call_status=${status}
    ...    cell_id=${cell_id}
    Set qRxLevMin on LTE cell    bts_id=${bts_id}
    ...                          cell_id=${cell_id}
    ...                          value=-46

Perform Smawave UE L3 call on all cells using qrxlevmin
    [Arguments]    ${cells_for_l3_call}    ${bts_id}    ${uepc_ip}    ${smawave_password}
    ${cell_ids}    Get dictionary keys    ${cells_for_l3_call}
    FOR    ${cell_id}    IN     @{cell_ids}
        Perform Smawave UE L3 call on selected cell using qrxlevmin
        ...    cell_id=${cell_id}
        ...    tput_dl=${cells_for_l3_call["${cell_id}"]["tput_dl"]}
        ...    tput_ul=${cells_for_l3_call["${cell_id}"]["tput_ul"]}
        ...    deviation=20%
        ...    bts_id=${bts_id}
        ...    uepc_ip=${uepc_ip}
        ...    smawave_password=${smawave_password}
    END
    Run keyword if    ${L3_CALL_STATUS}==${False}    Fail    Tput not as expected

Perform Smawave UE L3 call on selected cell using qrxlevmin
    [Arguments]    ${cell_id}    ${tput_dl}    ${tput_ul}    ${deviation}    ${bts_id}    ${uepc_ip}
    ...            ${smawave_password}
    Set qRxLevMin on NR cell    bts_id=${bts_id}
    ...                         cell_id=${cell_id}
    ...                         value=-45
    Log to console    Run DL tput on cell ${cell_id}
    ${status}    Run keyword and ignore error
    ...    smawave.Run downlink traffic
    ...    uepc_ip=${uepc_ip}
    ...    smawave_ip=192.168.1.1
    ...    smawave_password=${smawave_password}
    ...    tput_command=1400
    ...    appserver_ip=10.84.168.70
    ...    duration_time=60
    ...    tput_expected=${tput_dl}
    ...    deviation=${deviation}
    ...    key_algorithm=-p 22 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa
    ...    parallel_streams=4
    ...    tcp_iperf_version=2
    ...    ssh_method=ssh
    Analyse L3 call status
    ...    l3_call_status=${status}
    ...    cell_id=${cell_id}
    Log to console    Run UL tput on cell ${cell_id}
    ${status}    Run keyword and ignore error
    ...    smawave.Run uplink traffic multistream
    ...    uepc_ip=${uepc_ip}
    ...    smawave_ip=192.168.1.1
    ...    smawave_password=${smawave_password}
    ...    tput_command=1400
    ...    appserver_ip=10.84.168.70
    ...    appserver_traffic_ip=10.84.169.54
    ...    duration_time=60
    ...    tput_expected=${tput_ul}
    ...    deviation=${deviation}
    ...    key_algorithm=-p 22 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa
    ...    parallel_streams=8
    ...    tcp_iperf_version=2
    ...    ssh_method=ssh
    ...    perform_reboot=${False}
    Analyse L3 call status
    ...    l3_call_status=${status}
    ...    cell_id=${cell_id}
    Set qRxLevMin on NR cell    bts_id=${bts_id}
    ...                         cell_id=${cell_id}
    ...                         value=-22

Perform Android UE L3 call on all cells using qrxlevmin
    [Arguments]    ${cells_for_l3_call}    ${ue}    ${bts_id}    ${prepare_ue}=${True}
    Run keyword if    ${prepare_ue} == ${True}
    ...    Prepare UE for L3 call    capabilities=${ue}    alias=${ue}
    ${cell_ids}    Get dictionary keys    ${cells_for_l3_call}
    FOR    ${cell_id}    IN     @{cell_ids}
        Perform Android UE L3 call on selected cell using qrxlevmin
        ...    cell_id=${cell_id}
        ...    tput_dl=${cells_for_l3_call["${cell_id}"]["tput_dl"]}
        ...    tput_ul=${cells_for_l3_call["${cell_id}"]["tput_ul"]}
        ...    deviation=10%
        ...    parallel_streams_dl=4
        ...    parallel_streams_ul=12
        ...    bts_id=${bts_id}
        ...    ue=${ue}
    END
    Run keyword if    ${L3_CALL_STATUS}==${False}    Fail    Tput not as expected

Perform Android UE L3 call on selected cell using qrxlevmin
    [Arguments]    ${cell_id}    ${tput_dl}    ${tput_ul}    ${deviation}    ${bts_id}    ${ue}
    ...            ${parallel_streams_dl}=4    ${parallel_streams_ul}=2
    Set qRxLevMin on NR cell    bts_id=${bts_id}
    ...                         cell_id=${cell_id}
    ...                         value=-45
    Log to console    Run DL tput on cell ${cell_id}
    ${status}    Run keyword and ignore error
    ...    Verify L3 call one way data transfer
    ...    direction=dl
    ...    duration=60s
    ...    tput=${tput_dl}
    ...    protocol=tcp
    ...    deviation=${deviation}
    ...    parallel_streams=${parallel_streams_dl}
    ...    size_packet=1400B
    ...    alias=${ue}
    Analyse L3 call status
    ...    l3_call_status=${status}
    ...    cell_id=${cell_id}
    Log to console    Run UL tput on cell ${cell_id}
    ${status}    Run keyword and ignore error
    ...    Verify L3 call one way data transfer
    ...    direction=ul
    ...    duration=60s
    ...    tput=${tput_ul}
    ...    protocol=tcp
    ...    deviation=${deviation}
    ...    parallel_streams=${parallel_streams_ul}
    ...    size_packet=1400B
    ...    alias=${ue}
    Analyse L3 call status
    ...    l3_call_status=${status}
    ...    cell_id=${cell_id}
    Set qRxLevMin on NR cell    bts_id=${bts_id}
    ...                         cell_id=${cell_id}
    ...                         value=-22

Set qRxLevMin on NR cell
    [Arguments]    ${bts_id}    ${cell_id}    ${value}
    Perform configuration parameter recommissioning on gNB
    ...    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
    ...    param_name=qRxLevMin
    ...    param_value=${value}
    ...    timeout=300

Set qrxlevmin on LTE cell
    [Arguments]    ${bts_id}    ${cell_id}    ${value}
    Perform configuration parameter recommissioning on gNB
    ...    dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}/LNCEL-${cell_id}/SIB-0
    ...    param_name=qrxlevmin
    ...    param_value=${value}
    ...    timeout=300
