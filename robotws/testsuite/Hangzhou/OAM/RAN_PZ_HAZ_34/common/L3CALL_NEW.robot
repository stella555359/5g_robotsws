*** Settings ***
Documentation
...  author: Han Ruiyu
...  contact: ruiyu.han@nokia-sbell.com  jingmin.he@nokia-sbell.com
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot


*** Variables ***


*** Keywords ***
Common L3CALL with Power UE
    [Timeout]   100min
    [Documentation]   Common L3Call Keyword for UE reserve, UE attach and DL traffic.
    [Arguments]   ${cells}=${1}   ${ue_index}=${ue_index}   ${duration}=180    ${direction}=DL
    ...   ${dl_tp}=100   ${dl_tp_ratio}=1   ${ul_tp}=100   ${ul_tp_ratio}=${tput}
    ...   ${attach_only}=${False}    ${traffic_stop}=${true}
    ...   ${actImgGeneration}=${True}    ${target_avg_percent}=0.95
    ...   ${pci}=0   ${arfcn}=${0}   ${band}=N2   ${network_mode}=NR5GSA
    ${ue_type}     translate power ue type from testline    ${ue_index}
    Set Suite Variable   ${ue_${ue_index}_type}    ${ue_type}
    UE precondition with Power UE     ue_type=${ue_type}   ue_index=${ue_index}
    Wait Until Keyword Succeeds   3x   5s    Lock Operation from UE
    ...    band=${band}   pci=${pci}    arfcn=${arfcn}   ue_index=${ue_index}    network_mode=${network_mode}
    Wait Until Keyword Succeeds   3x   5s   Attach and Verify with Power UE   ue_index=${ue_index}  pci=${pci}   log_type=aasyslog
    run keyword if  not ${attach_only}    Traffic and Check with Power UE
    ...     cells=${cells}
    ...     ue_index=${ue_index}
    ...     duration=${duration}
    ...     direction=${direction}
    ...     ue_type=${ue_${ue_index}_type}
    ...     dl_throughput=${dl_tp}
    ...     ul_throughput=${ul_tp}
    ...     dl_tp_ratio=${dl_tp_ratio}
    ...     ul_tp_ratio=${ul_tp_ratio}
    ...     target_avg_percent=${target_avg_percent}
    ...     actImgGeneration=${actImgGeneration}
    Wait Until Keyword Succeeds   3x   5s    Unlock band and PCI from UE    ue_index=${ue_index}    band=${band}
    [Teardown]   Run Keyword If   ${traffic_stop}   power_ue.UE Detach   ue_index=${ue_index}   ue_type=${ue_${ue_index}_type}

UE precondition with Power UE
    [Arguments]    ${ue_index}    ${ue_type}
    run keyword if  not ${ue_${ue_index}_required}    power_ue.Prepare UE    ue_type=${ue_type}   ue_index=${ue_index}
    Set Test Variable   ${ue_${ue_index}_required}   ${true}

Lock Network Technology from UE
    [Arguments]    ${ue_index}    ${band}   ${network_mode}=NR5GSA
    ${network_mode}    Set Variable if  ${band.count('B')}>0 or ${band.count('b')}>0   LTE   ${network_mode}
    ute_ue.set_access_technology    UE_${ue_index}   technology=${network_mode}


Lock band from UE
    [Arguments]    ${band}    ${ue_index}
    ${mobile_network_system}    Set Variable if  ${band.count('B')}>0 or ${band.count('b')}>0   LTE   NR
    ute_ue.lock_band    UE_${ue_index}   network_technology=${mobile_network_system}    band=${band}

Lock PCI and Arfcn from UE
    [Arguments]    ${band}    ${ue_index}   ${pci}=0   ${arfcn}=${0}
    ${mobile_network_system}    Set Variable if  ${band.count('B')}>0 or ${band.count('b')}>0   LTE   NR
    ute_ue.lock_cell    UE_${ue_index}    network_technology=${mobile_network_system}    pci=${pci}    arfcn=${arfcn}


Unlock band and PCI from UE
    [Arguments]      ${ue_index}    ${band}
    ${mobile_network_system}    Set Variable if  ${band.count('B')}>0 or ${band.count('b')}>0   LTE   NR
    ute_ue.unlock_band    UE_${ue_index}   network_technology=${mobile_network_system}
    ute_ue.unlock_cell    UE_${ue_index}    network_technology=${mobile_network_system}

Lock Operation from UE
    [Arguments]    ${band}    ${arfcn}    ${ue_index}=${ue_index}    ${pci}=0   ${network_mode}=NR5GSA
    Lock Network Technology from UE    ue_index=${ue_index}     band=${band}   network_mode=${network_mode}
    Lock band from UE    ue_index=${ue_index}     band=${band}
    Lock PCI and Arfcn from UE   ue_index=${ue_index}      pci=${pci}    arfcn=${arfcn}   band=${band}
    #Wait Until Keyword Succeeds   3x   5s    Get UE PCI and IP Successfully  ue_index=${ue_index}   pci=${pci}
    #[Teardown]    Unlock band and PCI from UE    ue_index=${ue_index}    band=${band}


Attach and Verify with Power UE
    [Arguments]    ${ue_index}=${ue_index}    ${ue_type}=nokia_fastmile    ${pci}=0    ${log_type}=iperf
    ${status}    run keyword and return status    Get UE PCI and IP Successfully  ue_index=${ue_index}   pci=${pci}
    run keyword if  not ${status}    Reboot Power UE    ue_index=${ue_index}
    ${5Grach_ed}   run keyword if  not ${status}    power_ue.UE Attach
    ...   ue_index=${ue_index}     ue_type=${ue_${ue_index}_type}   pci=${pci}    log_type=${log_type}
    power_ue.Verify attach    ue_type=${ue_${ue_index}_type}     5Grach_ed=${5Grach_ed}    4G_check=${False}

Reboot Power UE
    [Arguments]    ${ue_index}=${ue_index}
    log to console    [WARN]| ue attach failed! try to reboot UE...
    ute_ue.reboot_ue    UE_${ue_index}   timeout=180
    sleep    3min
#    ${ue_cap} =    set variable    ${tl.ues[${ue_index}].capabilities[0]}
#    ute_ue.require_ue    ue_alias=UE_${ue_index}    capabilities=${ue_cap}

Traffic and Check with Power UE
    [Arguments]    ${ue_type}   ${dl_throughput}   ${ul_throughput}   ${direction}   ${ue_index}=${0}   ${cells}=${1}
    ...   ${dl_tp_ratio}=1   ${ul_tp_ratio}=1    ${duration}=600   ${target_avg_percent}=0.95
    ...   ${actImgGeneration}=${True}
#    ${direction}    Get L3CALL Traffic Direction    dl_tp=${dl_throughput}     ul_tp=${ul_throughput}
    ${Tput}    ${Expect_Tput_ratio}    run keyword if   '${direction.lower()}'=='dl'
    ...   Set Variable     ${dl_throughput}   ${dl_tp_ratio}
    ...   ELSE IF  '${direction.lower()}'=='ul'   Set Variable     ${ul_throughput}   ${ul_tp_ratio}
    run keyword if   '${direction.lower()}'=='dl' or '${direction.lower()}'=='ul'
    ...     Single Direction Traffic and Check with Power UE
    ...     cells=${cells}
    ...     ue_index=${ue_index}
    ...     duration=${duration}
    ...     direction=${direction}
    ...     ue_type=${ue_type}
    ...     Tput=${Tput}
    ...     Expect_Tput_ratio=${Expect_Tput_ratio}
    ...     actImgGeneration=${actImgGeneration}
    ...     ELSE IF  '${direction.upper()}'=='BOTH'
    ...     Bi Direction Traffic and Check with Power UE
    ...     cells=${cells}
    ...     ue_index=${ue_index}
    ...     duration=${duration}
    ...     ue_type=${ue_type}
    ...     dl_throughput=${dl_throughput}
    ...     ul_throughput=${ul_throughput}
    ...     dl_tp_ratio=${dl_tp_ratio}
    ...     ul_tp_ratio=${ul_tp_ratio}
    ...     target_avg_percent=${target_avg_percent}
    ...     actImgGeneration=${actImgGeneration}


Single Direction Traffic and Check with Power UE
    [Arguments]    ${ue_index}=${0}    ${duration}=90   ${direction}=DL   ${cells}=${1}
    ...    ${ue_type}=nokia_fastmile    ${Tput}=200M     ${Expect_Tput_ratio}=1
    ...   ${actImgGeneration}=${False}
    # Caculate input parameters
    ${duration_output}    run keyword if  ${duration.count('s')}>0    Fetch From Left    ${duration}    s
    ...   ELSE    set variable   ${duration}
    ${duration_traffic}   evaluate   ${duration_output}+${0}
    ${duration_traffic}    set variable   ${duration_traffic}
    ${send_tput}   Evaluate   int(${Tput})
    ${expect_tp}    Evaluate    ${Tput}*${Expect_Tput_ratio}
    #start and check TPUT
    power_ue.Start traffic    ue_index=${ue_index}   ue_type=${ue_type}    direction=${direction}
    ...    throughput=${Send_Tput}   duration=${duration_traffic}
    ${tput_log}    power_ue.Collect Tput     ue_index=${ue_index}   ue_type=${ue_type}    duration=${duration_output}
    ...   check_source=aasyslog
    power_ue.Stop traffic   ue_index=${ue_index}    ue_type=${ue_type}     direction=${direction}
    power_ue.Check Tput   cells=${cells}   ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}
    ...     target_throughput=${expect_tp}   actImgGeneration=${actImgGeneration}    check_source=aasyslog
    [Teardown]    run keyword and ignore error
    ...   power_ue.Stop traffic   ue_index=${ue_index}   ue_type=${ue_type}     direction=${direction}

Bi Direction Traffic and Check with Power UE
    [Arguments]   ${ue_type}   ${dl_throughput}   ${ul_throughput}    ${ue_index}=${0}   ${cells}=${1}
    ...   ${dl_tp_ratio}=1   ${ul_tp_ratio}=1    ${duration}=600   ${target_avg_percent}=0.95
    ...   ${actImgGeneration}=${False}
    # Caculate input parameters
    ${duration_output}    run keyword if  ${duration.count('s')}>0    Fetch From Left    ${duration}    s
    ...   ELSE    set variable   ${duration}
    ${duration_traffic}   evaluate   ${duration_output}+${0}
    ${duration_traffic}    set variable   ${duration_traffic}
    ${duration_collect}   evaluate   ${duration_output}/${2}
    ${duration_collect}    set variable   ${duration_collect}
    ${dl_tput}   Evaluate   int(${dl_throughput})
    ${ul_tput}   Evaluate   int(${ul_throughput})
    ${expect_dl_tp}    Evaluate    ${dl_tput}*${dl_tp_ratio}
    ${expect_ul_tp}    Evaluate    ${ul_tput}*${ul_tp_ratio}
    power_ue.Start traffic     ue_index=${ue_index}   ue_type=${ue_type}    direction=DL
    ...    throughput=${dl_tput}   duration=${duration_traffic}
    Run Keyword and Continue on Failure   power_ue.Start traffic    ue_index=${ue_index}   ue_type=${ue_type}    direction=UL
    ...    throughput=${dl_tput}   duration=${duration_traffic}
    ${tput_log}   power_ue.Collect Tput   ue_index=${ue_index}   ue_type=${ue_type}    duration=${duration_collect}
    ...   check_source=aasyslog
    power_ue.Stop traffic   ue_index=${ue_index}   ue_type=${ue_type}     direction=DL
    power_ue.Stop traffic   ue_index=${ue_index}   ue_type=${ue_type}     direction=UL
    power_ue.Check Bi Tput   cells=${cells}   ue_index=${ue_index}    ue_type=${ue_type}   log=${tput_log}
    ...   dltarget_throughput=${expect_dl_tp}   ultarget_throughput=${expect_ul_tp}
    ...   target_avg_percent=${target_avg_percent}
    [Teardown]   Run Keywords   Run Keyword and Ignore Error   power_ue.Stop traffic
    ...   ue_index=${ue_index}   ue_type=${ue_type}     direction=DL
    ...   AND   Run Keyword and Ignore Error   power_ue.Stop traffic
    ...   ue_index=${ue_index}   ue_type=${ue_type}     direction=UL

Get UE Info Once from CPE
    [Arguments]  ${ue_index}=${0}
    ${ue_info}    ute_ue.get_ue_info    UE_${ue_index}
    Set Test variable      ${ue_info}


Get UE PCI and IP Successfully
    [Arguments]  ${ue_index}=${0}    ${pci}=${0}
    ${ue_info}    ute_ue.get_ue_info    UE_${ue_index}
    ${result}    ${attach_pci}    run keyword and ignore error   get from dictionary    ${ue_info}    pci
    return from keyword if    '${result}'=='FAIL'
    log to console    \nue_index ${ue_index} attach pci is ${attach_pci}
    run keyword if    '${pci}'!='${0}'    should be equal as strings    ${attach_pci}    ${pci}
    ${ips}    get dictionary keys    ${ue_info['ips']}
    ${ue_ip}    set variable    127.0.0.1
    FOR    ${ip_info}    IN    @{ips}
        ${status}    run keyword and return status    Should Contain Any    ${ip_info}    data    ccmni    default
        ${ue_ip}    set variable if    ${status}    ${ue_info['ips']['${ip_info}'][0]}    ${ue_ip}
    END
    ${ue_ip}    set variable if    '${ue_ip}'=='None'    127.0.0.1    ${ue_ip}
    log to console    \nue_index ${ue_index} ip is ${ue_ip}
    Should Not Contain      ${ue_ip}      127.0
