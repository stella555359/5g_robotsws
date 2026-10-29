*** Settings ***
Documentation    egate related keywords

Library   Telnet
Library   OperatingSystem
Library   taf.sw.wtssim
Library   ta_uexgate

*** Keywords ***

Connect To Egate Via Telnet
    Telnet.Open Connection  host=0  port=${EGATE_PORT}
    Telnet.Write  /

Check If UE Is Attached
    Connect To Egate Via Telnet
    BuiltIn.Sleep  1
    Wait Until Keyword Succeeds  120  10  RealUE State Check
    [Teardown]  Telnet.Close Connection

Check If WTS Is Active
    Connect To Egate Via Telnet
    BuiltIn.Sleep  1
    Telnet.Write  state
    ${result}=  Telnet.read_until_regexp  \[S\|s\]tate.*ACTIVE
    [Teardown]  Telnet.Close Connection

RealUE State Check
    Telnet.Write  ue_disp
    ${result}=  Telnet.read_until_regexp  state.*\\bACTIVE\\b
    # ${result}=  Telnet.Read
    # Should Contain  ${result}  ATTACH PROCEDURE IS COMPLETED
    Set Suite Variable  ${result}

Trigger Simulator Start With Config
    [Arguments]    ${configuration}
    Start Egate Process  cfg_file=${configuration}  timeout=120
    TRY
        Start Egate Services  timeout=500
    EXCEPT    .*IndexError.*    type=Regexp
        Log  --> !!!Warning!!! Egate service check failed to IndexError, retry!!!    WARN
        Start Egate Services  timeout=500
    EXCEPT  AS  ${error}
        Fail  Keyword Start Egate Services failed due to ${error}
    END

UE Attach CUS
    [Arguments]  ${ue_id}=1  ${cell_id}=1
    Reach OnAir With WTS
    BuiltIn.Sleep   10s
    Run UEx command  wait_for_ovhd  cell=${cell_id}  timeout=10
    Cus Expect Msg Flow
    ...    UE_${ue_id}:RRC_UECapabilityInformation
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    alias=UE_ATTACH   overall_timeout=5
    Run UEx command  ue_attach  id=${ue_id}  cell=${cell_id}
    CUS Flow occurred as expected    alias=UE_ATTACH

UE Detach CUS
    [Arguments]  ${ue_id}=1
    run_uex_command  ue_detach  id=${ue_id}

Perform Traffic CUS
    [Arguments]    ${data_transfer_protocol}    ${time}    ${ue_id}=1
    ...    ${dl_throughput}=${tl.target_traffic_4G}[MAX_DL]    ${ul_throughput}=${tl.target_traffic_4G}[MAX_UL]
    IF    '${data_transfer_protocol}' == 'UDP'
        ${dlresult}    ${dlvalue}    Run Keyword And Ignore Error
        ...  Run UEx Command    trf_data_start    ue=${ue_id}    dir=dl    protocol=udp    Mbps=${dl_throughput}    stats=true    trf_id=1
        ${ulresult}  ${ulvalue}  Run Keyword And Ignore Error
        ...  Run UEx Command    trf_data_start    ue=${ue_id}    dir=ul    protocol=udp    Mbps=${ul_throughput}    stats=true    trf_id=2
    ELSE IF    '${data_transfer_protocol}' == 'TCP'
        ${dlresult}    ${dlvalue}    Run Keyword And Ignore Error
        ...  Run UEx Command    trf_data_start    ue=${ue_id}    dir=dl    protocol=tcp    rate=1000    stats=true    trf_id=1
        ${ulresult}  ${ulvalue}  Run Keyword And Ignore Error
        ...  Run UEx Command    trf_data_start    ue=${ue_id}    dir=ul    protocol=tcp    rate=1000    stats=true    trf_id=2
    ELSE
        Fail    Protocol ${data_transfer_protocol} is not supported, please update case if needed!!!
    END
    ${noegtr}    Run Keyword And Return Status    Should Contain    '${dlvalue}${ulvalue}'    no etgr
    Run Keyword If    ${noegtr}    Trigger Tgr Recovery Action
    Run Keyword If    '${dlresult}' == 'FAIL'    Fail    ${dlvalue}
    Run Keyword If    '${ulresult}' == 'FAIL'    Fail    ${ulvalue}
    Log To Console    Traffic is ongoing ${time}s
    BuiltIn.Sleep  ${time}  Traffic is ongoing

Stop Traffic CUS
    [Arguments]  ${ue_id}=1
    Run UEx Command  trf_data_stop  ue=${ue_id}  trf_id=1
    Run UEx Command  trf_data_stop  ue=${ue_id}  trf_id=2

Verify Traffic CUS
    [Arguments]    ${data_transfer_protocol}
    Log To Console    Verify Traffic CUS
    IF    '${data_transfer_protocol}' != 'UDP' and '${data_transfer_protocol}' != 'TCP'
        Fail    Protocol ${data_transfer_protocol} is not supported, please update case if needed!!!
    END
    ${min_success_rate}    Set Variable If    '${data_transfer_protocol}' == 'UDP'    90    70
    Check CUS Throughput
    ...    ${data_transfer_protocol}
    ...    ${tl.target_traffic_4G}[MAX_DL]
    ...    dir=dl  trf_id=1  ue_id=1    min_success_rate=${min_success_rate}
    Check CUS Throughput
    ...    ${data_transfer_protocol}
    ...    exp_tput=${tl.target_traffic_4G}[MAX_UL]
    ...    dir=ul    trf_id=2    ue_id=1    min_success_rate=${min_success_rate}

Calculate Mbps average tput for UE
    [Arguments]    ${data_transfer_protocol}    ${trf_id}    ${ue_id}    ${dir}    ${exp_tput}
    ${trf_stats}=    Run UEx command    get_trf_data_stats    trf_id=${trf_id}    ue=${ue_id}    unit=Mbps
    ${tputs_ue}=    Get From Dictionary    ${trf_stats}    ${dir}
    ${tput_avg}=    Get From Dictionary    ${tputs_ue}    avg
    ${tput_avg}=    Evaluate    round(${tput_avg}, 2)
    ${tput_success_rate}=    Evaluate    round(${tput_avg}/${exp_tput} * 100, 2)
    IF    '${data_transfer_protocol}' != 'UDP' and '${data_transfer_protocol}' != 'TCP'
        Fail    Protocol ${data_transfer_protocol} is not supported, please update case if needed!!!
    END
    ${percentage_rate}    Set Variable If    '${data_transfer_protocol}' == 'UDP'    ${90}    ${70}
    ${exp_tput_rate}=    Evaluate    round(${exp_tput}/100 * ${percentage_rate}, 2)
    Log To Console    Achieved AVG UE${ue_id} ${dir} tput: ${tput_avg}Mbps (${tput_success_rate}%) / Expected: ${exp_tput_rate}Mbps
    RETURN    ${tput_success_rate}

Check CUS Throughput
    [Arguments]    ${data_transfer_protocol}    ${exp_tput}   ${dir}    ${trf_id}    ${ue_id}    ${min_success_rate}
    Log To Console    Verify if desired ${exp_tput}Mbps ${dir} traffic ${trf_id} on UE${ue_id} reaches ${min_success_rate}%
    ${tput_success_rate}=    Calculate Mbps average tput for UE
    ...    ${data_transfer_protocol}    trf_id=${trf_id}    ue_id=${ue_id}    dir=${dir}    exp_tput=${exp_tput}
    Should Be True  ${tput_success_rate} >= ${min_success_rate}

Trigger Tgr Recovery Action
    Log To Console    start to recreate tgr
    ${cmd}=  catenate  SEPARATOR=  sudo /opt/cus/bin/docker_tgr.py &&
    ...  (echo 'config update' && sleep 5 && echo 'config remote update tgr' &&
    ...  sleep 50) | telnet localhost 1234
    log    ${cmd}
    Run    ${cmd}