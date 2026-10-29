*** Settings ***
Documentation
...   squad group: 5GSC_MMW_SC_PZ_HZ_05

Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library   String

*** Variables ***
@{desk_windows}   com.andriod.systemui   com.andriod.settings

*** Keywords ***
UE precondition
    [Documentation]   Require UE precondition, and avoid the duplicated require_ue actions same UE
    [Arguments]   ${ue_index}
#    ${ue_type_res}   Run Keyword And Ignore Error   Get power UE type
    ${ue_type_res}   Run Keyword And Ignore Error   Get power UE type   ${ue_index}
    ${ue_type}   Run Keyword If   '${ue_type_res[0]}'=='FAIL'   Set Variable   ${tl.ues[${ue_index}].capabilities[1]}
    ...  ELSE   Set Variable   ${ue_type_res[1]}
    Run Keyword If   '${ue_type.lower()}'=='huawei'   Set data center Mode for Huawei   ue_index=${ue_index}
    ...   ELSE    Run Keyword And Ignore Error  UE Reboot with adb command   ue_index=${ue_index}
#    ...   ELSE   UE Reboot with adb command   ue_index=${ue_index}
    Set Suite Variable   ${ue_${ue_index}_type}   ${ue_type}
    Wait Until Keyword Succeeds   1m   10s   Check UE device exist   ue_index=${ue_index}
    power_ue.Prepare UE   ue_type=${ue_type}   ue_index=${ue_index}   is_need_to_kill_vysor=${false}
    ${location_level}   Run Keyword and Return Status   Log   ${TEST_NAME}
    Run Keyword If   ${location_level}   Set Test Variable   ${ue_${ue_index}_required}   ${true}
    ...   ELSE   Set Suite Variable   ${ue_${ue_index}_required}   ${true}
    Run Keyword If   ${location_level}   Set Test Variable   ${ue_${ue_index}_nrCellId}   None
    ...   ELSE   Set Suite Variable   ${ue_${ue_index}_nrCellId}   None

Get power UE type
    [Arguments]   ${ue_index}
    [Documentation]   Add this keyword to avoid the `get_ue_type` timeout
    [Timeout]   180s
    ${ue_type}   ue.get_ue_type   ${tl.ues[${ue_index}]}
    [Return]   ${ue_type}

Attach and Retry if Failed
    [Documentation]   This keyword attach UE and verify the result of attaching
    [Arguments]   ${ue_type}=huawei   ${ue_index}=${0}   ${abil_index}=${1}   ${4G_check}=${false}
    wait until keyword succeeds   2x   30s   Attach UE and verify   ue_type=${ue_type}   ue_index=${ue_index}   abil_index=${abil_index}

Attach UE and verify
    [Documentation]   Similar code part to one new keyword
    [Arguments]   ${ue_type}=huawei   ${ue_index}=${0}   ${abil_index}=${1}
#    Close Desktop Windows   ue_index=${ue_index}
    ${mode_status}   Get UE Airmode status   ue_index=${ue_index}
    run keyword if  not '${mode_status}'=='1'   power_ue.UE Detach   ue_type=${ue_type}   ue_index=${ue_index}
#    Close Desktop Windows   ue_index=${ue_index}
    ${before}   power_ue.UE Attach   ue_type=${ue_type}   ue_index=${ue_index}   abil_index=${abil_index}
#    Close Desktop Windows   ue_index=${ue_index}
    ${enb_connect}   Run Keyword and Return Status   Get UE info   UE_${ue_index}   ENB_ID
    power_ue.Verify attach   ue_type=${ue_type}   ue_index=${ue_index}
    ...   abil_index=${abil_index}   5Grach_ed=${before}   4G_check=${enb_connect}
#    Run Keyword If   '${ue_${ue_index}_nrCellId}'=='None'   Get NSA nrCellId

Get Attached Cell Indentity
    [Arguments]   ${gnb_index}=${0}    ${attach_file}=/tmp/5Grach.txt
    ${mplan_addr}   Set Variable If   '${tl.gnbs[${gnb_index}].dus[0].f1_m_ip_addr}'=='None'   ${asik_addr}
    ...   ${tl.gnbs[${gnb_index}].dus[0].f1_m_ip_addr}
    csn.Connect To   hostname=${mplan_addr}    username=${asik_username}    password=${asik_password}    alias=L3CALL
    ${attach_info}   csn.Execute   command=cat ${attach_file} | grep -a crnti | grep -a "flow control start"   connection=L3CALL
    ${match_info}   Get Regexp Matches   ${attach_info}   flow control start.*crnti\\s+\\d+.*
    ${cell_id}   Run Keyword If   ${match_info}   _Get Cell Identity FlowControl   attach_info=${match_info[-1]}
    ...   ELSE   _Get Cell Identity L2LO   attach_file=${attach_file}
    [Return]   ${cell_id}
    [Teardown]   csn.Disconnect   connection=L3CALL

_Get Cell Identity FlowControl
    [Arguments]    ${attach_info}
    ${result}   ${nrCellId}   Run Keyword and Ignore Error
    ...   Should Match Regexp   ${attach_info}   CellIdentity:\\s?(\\d+)
    Return From Keyword If   $result=="PASS"   ${nrCellId[1]}
    [Return]   ${nrCellId[1]}

_Get Cell Identity L2LO
    [Arguments]    ${attach_file}=/tmp/5Grach.txt
    ${cell_info}   csn.Execute   command=cat ${attach_file} | grep -a crnti | grep -a nrCellIdentity   connection=L3CALL
    ${match_info}   Get Regexp Matches   ${cell_info}   crnti\\s?[=,:]\\s+\\d+.*nrCellIdentity\\s?[=,:]\\s?\\d+
    Return From Keyword If   len(${match_info})==${0}   ${EMPTY}
    ${match_info}   ${nrCellId}   Run Keyword and Ignore Error
    ...   Should Match Regexp   ${match_info[-1]}   crnti\\s?[=,:]\\s+\\d+.*nrCellIdentity\\s?[=,:]\\s?(\\d+)
    ${nrCellId}   Set Variable If   $match_info=="PASS"   ${nrCellId[1]}   ${EMPTY}
    [Return]   ${nrCellId}

Start ${direction} Traffic with Throughput ${throughput}
    [Documentation]   DEP. This keyword start the traffic and stop the traffic after checking the Throughput
    ${send_tput}   Evaluate   int(${throughput}*1.5)
    power_ue.Start traffic   ue_type=${ue_type}   direction=${direction}   throughput=${send_tput}M   duration=90s
    Wait Until Keyword Succeeds   1m   10s   power_ue.Check throughput   ue_type=${ue_type}   direction=${direction}   throughput=${throughput}
    [Teardown]   power_ue.Stop Traffic   ue_type=${ue_type}   direction=${direction}

Start ${direction} Traffic with PeakThroughput ${throughput}
    [Documentation]   DEP. This keyword start the traffic and stop the traffic after checking the PeakThroughput
    ${send_tput}   Evaluate   int(${throughput}*1.5)
    power_ue.Start traffic   ue_type=${ue_type}   direction=${direction}   throughput=${send_tput}M   duration=600s
    Wait Until Keyword Succeeds   10m   20s   power_ue.Check throughput   ue_type=${ue_type}   direction=${direction}   throughput=${throughput}
    [Teardown]   power_ue.Stop Traffic   ue_type=${ue_type}   direction=${direction}

Start Traffic With Throughput Check
    [Documentation]   Use this keyword instead the previous 2 keywords, because the power_ue require ue_type input
    [Arguments]   ${ue_type}   ${direction}   ${throughput}   ${expect}=${throughput}   ${cell_list}=${EMPTY}
    ...  ${ue_index}=${0}   ${mode}=None    ${traffic_stop}=${true}    ${duration}=90s
    ${duration}   Run Keyword If   '${mode.lower()}'=='peak'   Set Variable   600s
    ...   ELSE   Set Variable   ${duration}
    power_ue.Start traffic   ue_type=${ue_type}   ue_index=${ue_index}   direction=${direction}
    ...   throughput=${throughput}M   duration=${duration}
    Run Keyword If   len(${cell_list})==${0}   Wait Until Keyword Succeeds   ${duration}   10s   power_ue.Check throughput
    ...   ue_type=${ue_type}   ue_index=${ue_index}   direction=${direction}   throughput=${expect}
    ...   ELSE   Wait Until Keyword Succeeds   ${duration}   10s   Check Tput l3call   ue_type=${ue_type}   direction=${direction}
    ...   expect=${expect}   cells=${cell_list}   ue_index=${ue_index}
    [Teardown]   run keyword if  ${traffic_stop}  power_ue.Stop Traffic   ue_type=${ue_type}   ue_index=${ue_index}   direction=${direction}

Check Tput l3call
    [Arguments]   ${ue_type}   ${direction}   ${cells}   ${expect}  ${ue_index}=${0}   ${duration}=20s
    ...   ${gnb_index}=${0}
    ${tput_log}   power_ue.Collect Tput   ue_type=${ue_type}   duration=${duration}   ignore_time=1s   gnb_index=${gnb_index}
    ${tput_result}   Run Keyword and Return Status   power_ue.Check Tput   ue_type=${ue_type}   direction=${direction}
    ...   log=${tput_log}   cells=${cells}   target_throughput=${expect}
    run keyword if  not ${tput_result}   power_ue.Check throughput
    ...   ue_type=${ue_type}   ue_index=${ue_index}   direction=${direction}   throughput=${expect}   gnb_index=${gnb_index}

Check Throughput
    [Documentation]   Use this keyword to check throughput
    [Arguments]   ${ue_type}   ${direction}   ${throughput}   ${expect}=${throughput}   ${ue_index}=${0}
    power_ue.Check throughput   ue_type=${ue_type}   ue_index=${ue_index}   direction=${direction}   throughput=${expect}

Stop Traffic and Detach
    [Documentation]   Use this keyword to stop tranffic and ue detach directly
    [Arguments]   ${ue_type}   ${direction}    ${ue_index}=${0}   ${mode}=None
    power_ue.Stop Traffic   ue_type=${ue_type}   ue_index=${ue_index}   direction=${direction}
    power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

Start Peak Traffic Testing UL DL both
    [Documentation]   Use this keyword if drx open
    [Arguments]   ${ue_type}   ${dl_throughput}   ${ul_throughput}   ${cell_list}   ${ue_index}=${0}
    ...   ${dl_expect}=${dl_throughput}   ${ul_expect}=${ul_throughput}
    ${duration}   Set Variable   900s
    ${dl_tput}   Evaluate   int(${dl_throughput}*1.1)
    ${ul_tput}   Evaluate   int(${ul_throughput}*1.5)
    power_ue.Start traffic   ue_type=${ue_type}   ue_index=${ue_index}   direction=dl   throughput=${dl_tput}M
    ...   duration=${duration}   dt_name=dl_${ue_index}   iperf_port=${${tl.ues[${ue_index}].iperf_details.port}}
    Run Keyword and Continue on Failure   power_ue.Start traffic   ue_type=${ue_type}   ue_index=${ue_index}
    ...   direction=ul   throughput=${ul_tput}M   duration=${duration}   dt_name=ul_${ue_index}
    ...   iperf_port=${tl.appserver.iperf_details.port}   buffer_size=1400
    ${tput_log}   power_ue.Collect Tput   ue_type=${ue_type}
    power_ue.Check Bi Tput   ue_type=${ue_type}   log=${tput_log}   cells=${cell_list}
    ...   dltarget_throughput=${dl_expect}   ultarget_throughput=${ul_expect}
    [Teardown]   Run Keywords   Run Keyword and Ignore Error   power_ue.Stop Traffic
    ...   ue_type=${ue_type}   ue_index=${ue_index}   direction=dl   dt_name=dl_${ue_index}
    ...   AND   Run Keyword and Ignore Error   power_ue.Stop Traffic   ue_type=${ue_type}
    ...   ue_index=${ue_index}   direction=ul   dt_name=ul_${ue_index}
