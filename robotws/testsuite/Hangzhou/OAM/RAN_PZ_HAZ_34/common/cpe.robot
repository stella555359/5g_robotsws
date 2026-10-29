*** Settings ***
Documentation    Inseego Call Temp solution, han ruiyu added askey L3 CALL
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot

*** Variables ***
${ue_index}   0
${ue_required}   ${false}
${ue_0_required}   ${false}
${ue_1_required}   ${false}

*** Keywords ***
UE precondition CPE
    [Documentation]   Require UE precondition, and avoid the duplicated require_ue actions same UE
    [Arguments]    ${ue_index}    ${ue_type}    ${method}=normal    ${ue_reboot}=${False}
    LOG  method='${method}'
#    ${reboot_flag}    set Variable    true
#    _Prepare Variables    ue_index=${ue_index}
#    Run Keyword If   '${method}'=='PEAK'    Reboot UE control PC ASEKY
#    wait until keyword succeeds    5 min    20 sec   csn.Connect to   hostname=${cpc_ip}  username=${cpc_username}
#    ...   password=${cpc_password}    alias=cpc_${ue_index}
    run keyword if  ${ue_type.count('mtk')}>0    run keyword if  not ${ue_${ue_index}_required}
    ...   run keyword and ignore error   Kill ELT process on ue control pc if exists
    #Wait Until Keyword Succeeds    3x    5s    CPE Restart UE PROXY RUNNER    ue_index=${ue_index}
    #run keyword if  not ${ue_${ue_index}_required}
    #...   Wait Until Keyword Succeeds   2 min   10 s     power_ue.Prepare UE   ue_type=${ue_type}   ue_index=${ue_index}
    Wait Until Keyword Succeeds   2 min   10 s     power_ue.Prepare UE   ue_type=${ue_type}   ue_index=${ue_index}
    sleep  20s
    Run keyword if   ${ue_reboot}     UTE Reboot UE    ue_index=${ue_index}
#    ADB Reboot CPE    ue_index=${ue_index}
    ${status}   run keyword and return status    power_ue.UE Detach   ue_type=${ue_type}   ue_index=${ue_index}
    ${location_level}   Run Keyword and Return Status   Log   ${TEST_NAME}
    Run Keyword If   ${location_level}   Set Test Variable   ${ue_${ue_index}_required}   ${status}
    ...   ELSE   Set Suite Variable   ${ue_${ue_index}_required}   ${status}
    Run Keyword If   ${location_level}   Set Test Variable   ${ue_${ue_index}_nrCellId}   None
    ...   ELSE   Set Suite Variable   ${ue_${ue_index}_nrCellId}   None

UTE Reboot UE
    [Arguments]   ${ue_index}
    ute_ue.reboot    UE_${ue_index}
    sleep  20s

ADB Reboot CPE
    [Documentation]  Use adb command to reboot the android ue device
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced   cpc_ip=${tl.ues[${ue_index}].ue_pc_address}
    ...   cpc_usrname=nokia5G    cpc_passwd=noki@123
    csn.execute    command=adb -s ${serial_number} reboot   connection=cpc_${ue_index}
    sleep    20s
    [Teardown]  csn.disconnect   connection=cpc_${ue_index}

_Start_Peak_Traffic_Testing_CPE
    [Documentation]   Use this keyword if drx open
    [Arguments]   ${ue_type}   ${dl_throughput}   ${ul_throughput}   ${cell_list}   ${ue_index}=${0}
    ...   ${dl_expect}=${dl_throughput}   ${ul_expect}=${ul_throughput}    ${duration}=600   ${process_num}=5
    ...   ${dl_deviation}=0.95   ${ul_deviation}=0.95     ${actCarrierAggregation}=${False}    ${traffic_stop}=${True}
    ...    ${Technology}=NR   ${min_percent}=0.85
    ${duration_output}    run keyword if  ${duration.count('s')}>0    Fetch From Left    ${duration}    s
    ...   ELSE    set variable   ${duration}
    ${check_source}    set variable if   ${Technology.count('NR')}>0    Aasyslog   iperf
    ${duration_traffic}   evaluate   ${duration_output}+${120}
    ${duration_traffic}    set variable   ${duration_traffic}s
    ${dl_tput}   Evaluate   int(${dl_throughput}*1.1)
    ${ul_tput}   Evaluate   int(${ul_throughput}*1.5)
    Start traffic CPE    ue_index=${ue_index}    ue_type=${ue_${ue_index}_type}    Send_Tput=${dl_tput}M
    ...    duration=${duration_traffic}    direction=dl
    Run Keyword and Continue on Failure   Start traffic CPE   ue_index=${ue_index}    ue_type=${ue_${ue_index}_type}
    ...    Send_Tput=${ul_tput}M   duration=${duration_traffic}   direction=ul    process_num=${process_num}
    ${duration}    set variable if  ${traffic_stop}   ${duration}    30s
    ${tput_log}   power_ue.Collect Tput   ue_index=${ue_index}   ue_type=${ue_type}    duration=${duration}
    ...   ignore_time=30s   check_source=${check_source}
    run keyword if  ${check_source.count('syslog')}>0
    ...   power_ue.Check Bi Tput   ue_index=${ue_index}   ue_type=${ue_type}   log=${tput_log}   cells=${cell_list}
    ...   dltarget_throughput=${dl_expect}   ultarget_throughput=${ul_expect}
    ...   target_avg_percent=${dl_deviation}     actCarrierAggregation=${actCarrierAggregation}
    ...   min_percent=${min_percent}
    ...   ELSE IF  ${check_source.count('iperf')}>0   run keywords
    ...   Stop DL traffic CPE    ue_index=${ue_index}    ue_type=${ue_${ue_index}_type}
    ...   AND    Stop UL traffic CPE    ue_index=${ue_index}    ue_type=${ue_${ue_index}_type}
    ...   AND    Check Tput l3call CPE    ue_index=${ue_index}  ue_type=${ue_${ue_index}_type}   direction=dl    log=${tput_log}
    ...   expect=${dl_expect}   cells=${cell_list}   ue_index=${ue_index}    actCarrierAggregation=${actCarrierAggregation}
    ...   target_avg_percent=${dl_deviation}    min_percent=${min_percent}
    ...   AND    Check Tput l3call CPE    ue_index=${ue_index}  ue_type=${ue_${ue_index}_type}   direction=ul    log=${tput_log}
    ...   expect=${ul_expect}   cells=${cell_list}   ue_index=${ue_index}    actCarrierAggregation=${actCarrierAggregation}
    ...   target_avg_percent=${ul_deviation}    min_percent=${min_percent}
    [Teardown]   run keyword if  ${traffic_stop}    Run Keywords   Run Keyword and Ignore Error
    ...   Stop DL traffic CPE    ue_index=${ue_index}    ue_type=${ue_${ue_index}_type}
    ...   AND   Run Keyword and Ignore Error    Stop UL traffic CPE    ue_index=${ue_index}    ue_type=${ue_${ue_index}_type}

Start traffic CPE
    [Arguments]    ${ue_index}=${0}    ${ue_type}=nokia_fastmile    ${Send_Tput}=200M    ${duration}=90
    ...   ${direction}=dl    ${ul_length}=1400    ${process_num}=1
    LOG  ul_length='${ul_length}'
    LOG TO CONSOLE    ....START TRAFFIC Start!
    ${duration_output}    run keyword if  ${duration.count('s')}>0    Fetch From Left    ${duration}    s
    ...   ELSE    set variable   ${duration}
    ${process_num}    set variable if  '${direction.lower()}'=='dl'    1    5
    ${Send_Tput}   Fetch from left    ${Send_Tput}   M
    ${throughput}    evaluate    float(float(${Send_Tput})/float(${process_num}))
    power_ue.Start traffic   ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}
    ...    throughput=${throughput}M   duration=${duration_output}    process_num=${process_num}
    ...   dt_name=${direction}_${ue_index}
#    LOG TO CONSOLE    ....START TRAFFIC FINISHED!

_start_traffic_with_tp_check_CPE
    [Arguments]   ${cell_list}    ${ue_index}=${ue_index}    ${traffic_stop}=${true}    ${duration}=90
    ...    ${ue_type}=nokia_fastmile    ${Send_Tput}=200M     ${Expect_Tput}=50
    ...    ${peak_ul}=120   ${ul_expect}=${peak_ul}    ${method}=normal    ${Technology}=NR
    ...   ${direction}=DL     ${actCarrierAggregation}=${False}   ${process_num}=1
    ...   ${dl_deviation}=0.95   ${ul_deviation}=0.95
#    ${duration_output}    run keyword if  ${duration.count('s')}>0    Fetch From Left    ${duration}    s
#    ...   ELSE    set variable   ${duration}
#    ${duration_traffic}   evaluate   ${duration_output}+${30}
#    ${duration_traffic}    set variable   ${duration_traffic}s
    LOG  ue_type='${ue_type}' ul_expect='${ul_expect}' method='${method}'
    ${check_source}    set variable if   ${Technology.count('NR')}>0    Aasyslog   iperf
    Run Keyword If   '${direction}'=='DL'
    ...   Wait Until Keyword Succeeds   10m   60s   _start_dl_traffic_with_tp_check_CPE
    ...   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}  cell_list=${cell_list}   target_avg_percent=${dl_deviation}
    ...   Send_Tput_DL=${Send_Tput}   Expect_Tput_DL=${Expect_Tput}    traffic_stop=${traffic_stop}    duration=${duration}
    ...   actCarrierAggregation=${actCarrierAggregation}    process_num=${process_num}    check_source=${check_source}
    ...   ELSE IF   '${direction}'=='UL'
    ...   Wait Until Keyword Succeeds   10m   60s   _start_ul_traffic_with_tp_check_CPE
    ...   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}  cell_list=${cell_list}    target_avg_percent=${ul_deviation}
    ...   ul_tput=${Send_Tput}   Expect_Tput_UL=${Expect_Tput}    traffic_stop=${traffic_stop}    duration=${duration}
    ...   actCarrierAggregation=${actCarrierAggregation}    process_num=${process_num}    check_source=${check_source}

_start_dl_traffic_with_tp_check_CPE
    [Arguments]    ${traffic_stop}=${true}    ${duration}=90    ${ue_index}=${0}
    ...    ${ue_type}=nokia_fastmile    ${Send_Tput_DL}=200M     ${Expect_Tput_DL}=50M    ${method}=normal    ${cell_list}=${EMPTY}
    ...    ${actCarrierAggregation}=${False}   ${process_num}=1    ${check_source}=Aasyslog    ${target_avg_percent}=0.95
    LOG  method='${method}'
    ${duration_output}    run keyword if  ${duration.count('s')}>0    Fetch From Left    ${duration}    s
    ...   ELSE    set variable   ${duration}
    ${duration_traffic}   evaluate   ${duration_output}+${30}
    ${duration_traffic}    set variable   ${duration_traffic}s
    Start traffic CPE    ue_index=${ue_index}   ue_type=${ue_${ue_index}_type}    Send_Tput=${Send_Tput_DL}M
    ...   duration=${duration_traffic}    direction=dl    process_num=${process_num}
   ${tput_log}   power_ue.Collect Tput   ue_type=${ue_${ue_index}_type}    duration=${duration}    ignore_time=0s
   ...   check_source=${check_source}
#   Stop DL traffic CPE    ue_type=${ue_${ue_index}_type}
#   Check Tput l3call CPE    ue_index=${ue_index}  ue_type=${ue_${ue_index}_type}   direction=dl    log=${tput_log}
#    ...   expect=${Expect_Tput_DL}   cells=${cell_list}   ue_index=${ue_index}    actCarrierAggregation=${actCarrierAggregation}
#    power_ue.Check Bi Tput   ue_index=${ue_index}   ue_type=${ue_type}   log=${tput_log}   cells=${cell_list}
#    ...   dltarget_throughput=${Expect_Tput_DL}   ultarget_throughput=${0}
#    ...   target_avg_percent=${target_avg_percent}     actCarrierAggregation=${actCarrierAggregation}
    run keyword if  ${check_source.count('syslog')}>0
    ...   power_ue.Check Bi Tput   ue_index=${ue_index}   ue_type=${ue_type}   log=${tput_log}   cells=${cell_list}
    ...   dltarget_throughput=${Expect_Tput_DL}   ultarget_throughput=${0}
    ...   target_avg_percent=${target_avg_percent}     actCarrierAggregation=${actCarrierAggregation}
    ...   ELSE IF  ${check_source.count('iperf')}>0   run keywords
    ...   power_ue.Stop Traffic
    ...   ue_type=${ue_type}   ue_index=${ue_index}   direction=dl   dt_name=dl_${ue_index}
    ...   AND    Check Tput l3call CPE    ue_index=${ue_index}  ue_type=${ue_${ue_index}_type}   direction=dl    log=${tput_log}
    ...   expect=${Expect_Tput_DL}   cells=${cell_list}   ue_index=${ue_index}    actCarrierAggregation=${actCarrierAggregation}
    [Teardown]    run keyword if  ${traffic_stop}  run keyword and ignore error
    ...   Stop DL traffic CPE    ue_index=${ue_index}   ue_type=${ue_${ue_index}_type}

_start_ul_traffic_with_tp_check_CPE
    [Arguments]    ${traffic_stop}=${true}    ${duration}=90    ${ue_index}=${0}
    ...    ${ue_type}=nokia_fastmile    ${ul_tput}=120M     ${Expect_Tput_UL}=30M    ${method}=normal    ${cell_list}=${EMPTY}
    ...    ${actCarrierAggregation}=${False}   ${process_num}=1    ${check_source}=Aasyslog    ${target_avg_percent}=0.95
    LOG  method='${method}'
    ${duration_output}    run keyword if  ${duration.count('s')}>0    Fetch From Left    ${duration}    s
    ...   ELSE    set variable   ${duration}
    ${duration_traffic}   evaluate   ${duration_output}+${30}
    ${duration_traffic}    set variable   ${duration_traffic}s
    Start traffic CPE    ue_index=${ue_index}     ue_type=${ue_${ue_index}_type}    Send_Tput=${ul_tput}M    duration=${duration_traffic}
    ...   direction=ul    process_num=${process_num}
    ${tput_log}   power_ue.Collect Tput    ue_index=${ue_index}   ue_type=${ue_${ue_index}_type}    duration=${duration}    ignore_time=0s
    ...   check_source=${check_source}
#    Check Tput l3call CPE    ue_index=${ue_index}   ue_type=${ue_${ue_index}_type}   direction=ul    log=${tput_log}
#    ...   expect=${Expect_Tput_UL}   cells=${cell_list}   ue_index=${ue_index}    actCarrierAggregation=${actCarrierAggregation}
    run keyword if  ${check_source.count('syslog')}>0
    ...   power_ue.Check Bi Tput   ue_index=${ue_index}   ue_type=${ue_type}   log=${tput_log}   cells=${cell_list}
    ...   dltarget_throughput=${0}   ultarget_throughput=${Expect_Tput_UL}
    ...   target_avg_percent=${target_avg_percent}     actCarrierAggregation=${actCarrierAggregation}
    ...   ELSE IF  ${check_source.count('iperf')}>0   run keywords
    ...   Stop UL traffic CPE    ue_index=${ue_index}    ue_type=${ue_${ue_index}_type}
    ...   AND    Check Tput l3call CPE    ue_index=${ue_index}  ue_type=${ue_${ue_index}_type}   direction=ul    log=${tput_log}
    ...   expect=${Expect_Tput_UL}   cells=${cell_list}   ue_index=${ue_index}    actCarrierAggregation=${actCarrierAggregation}
    [Teardown]    run keyword if  ${traffic_stop}    run keyword and ignore error
    ...   Stop UL traffic CPE    ue_index=${ue_index}    ue_type=${ue_${ue_index}_type}

Check Bi Tput l3call CPE
    [Arguments]   ${ue_type}    ${cells}   ${ue_index}=${0}   ${duration}=30s   ${check_source}=Aasyslog
    ...   ${gnb_index}=${0}   ${actImgGeneration}=${True}     ${actCarrierAggregation}=${False}
    ...   ${Expect_Tput_DL}=${5}    ${Expect_Tput_UL}=${5}    ${target_avg_percent}=0.95
    ...   ${min_percent}=0.85
    LOG  gnb_index='${gnb_index}' actImgGeneration='${actImgGeneration}'
    ${tput_log}   power_ue.Collect Tput    ue_index=${ue_index}   ue_type=${ue_${ue_index}_type}    duration=${duration}    ignore_time=0s
        ...   check_source=${check_source}
    power_ue.Check Bi Tput   ue_index=${ue_index}   ue_type=${ue_type}   log=${tput_log}   cells=${cells}
    ...   dltarget_throughput=${Expect_Tput_DL}   ultarget_throughput=${Expect_Tput_UL}
    ...   target_avg_percent=${target_avg_percent}     actCarrierAggregation=${actCarrierAggregation}
    ...   min_percent=${min_percent}


Check Tput l3call CPE
    [Arguments]   ${ue_type}   ${direction}   ${log}   ${cells}   ${expect}  ${ue_index}=${0}   ${duration}=30s
    ...   ${gnb_index}=${0}   ${actImgGeneration}=${True}     ${actCarrierAggregation}=${False}    ${target_avg_percent}=0.95
    ...   ${min_percent}=0.85
     LOG  gnb_index='${gnb_index}' actImgGeneration='${actImgGeneration}' duration='${duration}'
    power_ue.Check Tput    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}   log=${log}
    ...   cells=${cells}   target_throughput=${expect}   actImgGeneration=${actImgGeneration}
    ...   actCarrierAggregation=${actCarrierAggregation}    target_avg_percent=${target_avg_percent}
    ...   min_percent=${min_percent}

Stop DL traffic CPE
    [Arguments]  ${ue_index}=${0}   ${ue_type}=nokia_fastmile
    power_ue.Stop traffic    ue_index=${ue_index}        ue_type=${ue_type}    direction=dl   dt_name=dl_${ue_index}

Stop UL traffic CPE
    [Arguments]  ${ue_index}=${0}   ${ue_type}=nokia_fastmile
    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}    direction=ul   dt_name=ul_${ue_index}

Lock Network Technology from CPE
    [Arguments]    ${ue_index}    ${band}
    ${network_mode}    Set Variable if  ${band.count('B')}>0 or ${band.count('b')}>0   LTE   NR5GSA
    ute_ue.set_access_technology    UE_${ue_index}   technology=${network_mode}


Lock band from CPE
    [Arguments]    ${band}    ${ue_index}
    ${mobile_network_system}    Set Variable if  ${band.count('B')}>0 or ${band.count('b')}>0   LTE   NR
    ute_ue.lock_band    UE_${ue_index}   network_technology=${mobile_network_system}    band=${band}

Lock PCI and Arfcn from CPE
    [Arguments]    ${band}    ${ue_index}   ${pci}=0   ${arfcn}=${0}
    ${mobile_network_system}    Set Variable if  ${band.count('B')}>0 or ${band.count('b')}>0   LTE   NR
    ute_ue.lock_cell    UE_${ue_index}    network_technology=${mobile_network_system}    pci=${pci}    arfcn=${arfcn}


Unlock band and PCI from CPE
    [Arguments]      ${ue_index}    ${band}
    ${mobile_network_system}    Set Variable if  ${band.count('B')}>0 or ${band.count('b')}>0   LTE   NR
    run keyword and ignore error    ute_ue.unlock_band    UE_${ue_index}   network_technology=${mobile_network_system}
    run keyword and ignore error    ute_ue.unlock_cell    UE_${ue_index}    network_technology=${mobile_network_system}

CPE Lock Opration
    [Arguments]    ${band}    ${arfcn}    ${ue_index}=${ue_index}    ${pci}=0
    Lock Network Technology from CPE    ue_index=${ue_index}     band=${band}
    Lock band from CPE    ue_index=${ue_index}     band=${band}
    Lock PCI and Arfcn from CPE   ue_index=${ue_index}      pci=${pci}    arfcn=${arfcn}   band=${band}
    run keyword and ignore error    power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

CPE Restart UE PROXY RUNNER
    [Arguments]    ${ue_index}=${0}
    FOR    ${pc}    IN    @{tl.test_pcs}
        Run keyword if   '${tl.ues[${ue_index}].ue_pc_address}'=='${pc.default_ssh_connection_details.addr}'
        ...   _CPE Restart UE PROXY RUNNER with Control PC    pc_addr=${tl.ues[${ue_index}].ue_pc_address}
        ...   pc_usrname=${pc.default_ssh_connection_details.username}   pc_passwd=${pc.default_ssh_connection_details.password}
    END

_CPE Restart UE PROXY RUNNER with Control PC
    [Arguments]    ${pc_addr}    ${pc_usrname}    ${pc_passwd}
    csn.Connect to   hostname=${pc_addr}  username=${pc_usrname}  password=${pc_passwd}    alias=pc
    Log To Console    stop UE PROXY RUNNER...
    ${output}   csn.execute    command=net stop "UE PROXY RUNNER"   connection=pc
    should contain    ${output}    success
    Sleep    5s
    log to console    start UE PROXY RUNNER...
    ${output}   csn.execute    command=net start "UE PROXY RUNNER"   connection=pc
    should contain    ${output}    success
    Sleep    5s
    [Teardown]    csn.disconnect   connection=pc
