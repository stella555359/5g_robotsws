*** Settings ***
Documentation
...   author: liting.cao@nokia-sbell.com
...   contact: liting.cao@nokia-sbell.com
...   vdu_oam_pm.robot



*** Variables ***



*** Keywords ***
vDU Get PM Counter Latest Values
    [Arguments]   ${counter_id}   ${dimension_dist_name}  ${vdu_index}=0
    [Documentation]    Get latest counter value from webUI via rest API.
    ...    firstly, using restapi to get the counter whole info, then get the latest value
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:   <27-Oct-2020>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id | Yes | PM counter ID |
    ...    | dimension_dist_name | Yes | the dimension dist name that the counter belongs to, like MRBTS-5323/NRBTS-5323/NRCELL-1 |
    ...    | vdu_index | No |  vdu index to indicate which vdu will be used, 0 in default  |
    ...
    ...    *RETURN VALUE*
    ...    Latest counter value
    vDU Rest Login    vdu_index=${vdu_index}
    ${res}=  vdu.get_counter_values    ${counter_id}   ${dimension_dist_name}
    ${latest_counter}=  set variable    max(${res[-5]['value']}, ${res[-4]['value']}, ${res[-3]['value']}, ${res[-2]['value']}, ${res[-1]['value']})
    [return]    ${latest_counter}
    [Teardown]   vDU Rest Logout   vdu_index=${vdu_index}


VDU Sync To PM Timer Clock
    [Arguments]   ${PM_collecting_interval}=5   ${estimated_traffic_generating_duration}=4
    [Teardown]  Run Keyword And Ignore Error   disconnect interactive connection  alias=${alias}
    [Documentation]  VDU Sync To PM Timer Clock
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    *Change History*
    ...    | Date | Who | What and How |
    ...    | 2022-1-26| r3li@nokia-sbell.com | because there are occasional failures to get vm_minutes, so add times of get it |
    ...    | 2022-2-12| chris.l.cao@nokia-sbell.com | to fix ssh command unstable issue |
    ...
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | estimated_traffic_generating_duration | No | estimated_traffic_generating_duration, unit is minute, default value is 7 |
    ...    | PM_collecting_interval                | No  | PM_collecting_interval, unit is minute, default value is 5 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | VDU Sync To PM Timer Clock | PM_collecting_interval=5  | estimated_traffic_generating_duration=2 |
    ...
    Log To Console  Begin: VDU Sync To PM Timer Clock
    ${alias}    Get Unique ID
    Connect To VDU Container Interactively   ctr_abbr=oamagent   alias=${alias}

    ${ret}    issh.execute   command=date +"%Y-%m-%d %H:%M:%S"   alias=${alias}
    ${ret}  Strip Prompt  ${ret}
    ${matches}    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:(\\d{2}):\\d{2}  1
    ${vm_minutes}  Set Variable   ${matches[0]}
    Log To Console  Current OAM system time:${ret},minutes:${vm_minutes}

    ${estimated_traffic_generating_duration}  Evaluate   int('${estimated_traffic_generating_duration}')
    ${PM_collecting_interval}  Evaluate  int('${PM_collecting_interval}')
    ${vm_minutes}  Evaluate  int('${vm_minutes}')

    Run Keyword If
      ...   ${PM_collecting_interval}!=5 and ${PM_collecting_interval}!=15 and ${PM_collecting_interval}!=30 and ${PM_collecting_interval}!=60
      ...    Fail   PM_collecting_interval should be 5, 15, 30 or 60 minutes.
    _Wait Some Time For Next Round PM Collecting    collecting_interval=${PM_collecting_interval}
     ...   estimated_traffic_generating_duration=${estimated_traffic_generating_duration}   vm_minutes=${vm_minutes}

    ${ret}    issh.execute   command=date +"%Y-%m-%d %H:%M:%S"   alias=${alias}

    ${vm_time}    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}
    Log To Console   Current OAM system time:${vm_time[0]}
    Log To Console  End: VDU Sync To PM Timer Clock


_Wait Some Time For Next Round PM Collecting
    [Arguments]   ${collecting_interval}  ${estimated_traffic_generating_duration}   ${vm_minutes}
    Should Be True  ${estimated_traffic_generating_duration}<=${collecting_interval}

    ${vm_minutes_mod}    Evaluate    int(math.fmod(${vm_minutes},int(${collecting_interval})))    modules=math

    Log To Console  vm_minutes_mod result:${vm_minutes_mod}
    Run Keyword If   ${vm_minutes_mod}==0  Log To Console   it's the time of N*${collecting_interval} minutes, so need not wait
    Return From Keyword If  ${vm_minutes_mod}==0

    ${wait_time}    Evaluate    int(${collecting_interval})-${vm_minutes_mod}

    ${msg}   Run Keyword If  ${wait_time}>${estimated_traffic_generating_duration}   Set Variable
    ...    There is no next collecting point during estimated_traffic_generating_duration
    ${msg}   Run Keyword If  ${wait_time}>${estimated_traffic_generating_duration}   Set Variable
    ...    ${msg}(${estimated_traffic_generating_duration} minutes), so need not wait to synced to next round collecting point.

    Run Keyword If   ${wait_time}>${estimated_traffic_generating_duration}
    ...  Log To Console   ${msg}
    Return From Keyword If   ${wait_time}>${estimated_traffic_generating_duration}

    ${msg}  Set Variable   There is next collecting point during estimated_traffic_generating_duration
    ${msg}  Set Variable  ${msg}(${estimated_traffic_generating_duration} minutes), so need wait to sync to next round collecting point.
    Log To Console  ${msg}

#    ${wait_time_sec}   Evaluate   ${wait_time}*60+31
    ${wait_time_sec}   Evaluate   ${wait_time}*60+5
    Log To Console   wait time: ${wait_time} minutes
    Sleep   ${wait_time_sec}


Get PM Related Files From pmcore Container To Local TestPC
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Arguments]  ${file_absolute_path}  ${vdu_index}=0  ${gnb_index}=0
    [Documentation]  get file from pmcore container to local UTE. The file will be stored under UTE
    ...  ${OUTPUT_DIR}/${TEST_NAME}/${START_TIME}/pm_related directory.
    ...    *AUTHOR* mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | file_absolute_path | Yes | the file path in pmcore container,
    ...                                 like /var/opt/nokia/performancemanagement/storage/results/resultMapping.json |

    ...    *RETURN VALUE*
    ...    the file path under UTE,
    ...    like /home/ute/robotws5g/testsuite/AIC/TESTCASE__Test_PM/2021_01_14_04_17_04/pm_related/resultMapping.json
    ${platform}   Get Platform Name
    ${local_file}   runkeyword if   "${platform}"=="NCIR" or "${platform}"=="NCS"
    ...   Get PM Related Files From pmcore Container To Local TestPC For NCIR Or NCS    file_absolute_path=${file_absolute_path}
    ...                                                                                 vdu_index=${vdu_index}
    ...                                                                                 gnb_index=${gnb_index}
    ...   ELSE    Get PM Related Files From pmcore Container To Local TestPC For OCP    file_absolute_path=${file_absolute_path}
    ...                                                                                 vdu_index=${vdu_index}
    ...                                                                                 gnb_index=${gnb_index}
    [Return]    ${local_file}


_Get Process ID From Result
    [Arguments]   ${out}
    ${id_list}   Create List
    ${lines}   Split To Lines   ${out}
    ${empty_list}  Create List
    FOR  ${line}  IN  @{lines}
       ${id}   Get Regexp Matches	 ${line}    \\d{3,}
        Run Keyword If  ${id}!=${empty_list}   Append to list   ${id_list}    ${id}[0]
    END
    [Return]   ${id_list}


Kill PCMD Process
    [Arguments]   ${container_aashell_port}   ${pod_abbr}=up   ${container_abbr}=l2rt
    ...    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]   Kill PCMD Process
    ...   *AUTHOR* rui.3.li@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | container_aashell_port | yes | action_id |
    ...   | pod_abbr               | No  | pod abbr name |
    ...   | container_abbr         | No  | container abbr name |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | Kill PCMD Process | 15007 | up | l2rt | 0 | 0 |
    ...
    ${alias}   Get Unique Id
    ${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}  gnb_index=${gnb_index}
    Connect To K8s Master Interactively    alias=${alias}
    ${full_pod_name}    Get Full Pod Name By Pod Abbreviation Interactively   ${pod_abbr}   alias=${alias}
    ${full_container_name}    Get Full Container Name By Container Abbreviation    ${container_abbr}
    ${basic_cmd}   set variable   kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- bash -c
    ${cmd}   set variable   ${basic_cmd} "ps -ef| grep ${container_aashell_port}|grep -v grep|awk '{print \\$2}'"
    ${out}   issh.execute   command=${cmd}   alias=${alias}
    ${out}   Strip Prompt  ${out}  remove_first_line=True
    ${id_list}    _Get Process ID From Result    ${out}
    FOR   ${id}   IN   @{id_list}
        issh.execute    command=${basic_cmd} "kill ${id}"   alias=${alias}
    END
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias}


Set L2 PCMD On VDU
    [Arguments]   ${container_aashell_port}   ${feature_id_list}   ${pod_abbr}=up   ${container_abbr}=l2rt
    ...    ${active_status}=1   ${vdu_index}=0    ${gnb_index}=0
    [Documentation]   Active L2 PCMD on VDU L2RT
    ...   *AUTHOR* rui.3.li@nokia-sbell.com
    ...   *MODIFY* huilin.xu@nokia-sbell.com  nc 127.0.0.1
    ...   | Input Parameters    | Man. | Description |
    ...   | container_aashell_port | yes | action_id |
    ...   | feature_id_list        | yes | feature id list |
    ...   | active_status          | No  | active status, default is 1 means active, 0 means de_active |
    ...   | pod_abbr               | No  | pod abbr name |
    ...   | container_abbr         | No  | container abbr name |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | Active L2 PCMD on VDU L2RT | 15007 | [0x580466, 0x570022] | up | l2rt | 1 | 0 | 0 |
    ...  | Active L2 PCMD on VDU L2RT | 15007 | [0x580466, 0x570022] | up | l2rt | 0 | 0 | 0 |
    ...
    kill pcmd process   ${container_aashell_port}    ${pod_abbr}   ${container_abbr}   ${vdu_index}   ${gnb_index}
    sleep  3
    ${alias}   Get Unique Id
    ${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}  gnb_index=${gnb_index}
    Connect To K8s Master Interactively    alias=${alias}
    ${full_pod_name}    Get Full Pod Name By Pod Abbreviation Interactively   ${pod_abbr}   alias=${alias}
    ${full_container_name}    Get Full Container Name By Container Abbreviation    ${container_abbr}
    ${cmd}   set variable   kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- bash
    ${old_prompt}   issh.get_prompt    alias=${alias}
    issh.set_prompt   \\S+\\$    alias=${alias}
    issh.execute    command=${cmd}   alias=${alias}   check_result=${False}
    sleep  3
    issh.set_prompt   AaShell>   alias=${alias}
    issh.execute    command=nc 127.0.0.1 ${container_aashell_port}    alias=${alias}   check_result=${False}
    FOR   ${feature_id}   IN   @{feature_id_list}
        ${out}   issh.execute    command=rad -mw ${feature_id} ${active_status}  alias=${alias}   check_result=${False}
        Should Be True   'succesfully' in """${out}"""
    END
    [Teardown]  run keywords  disconnect interactive connection   alias=${alias}
    ...         AND   kill pcmd process   ${container_aashell_port}    ${pod_abbr}   ${container_abbr}   ${vdu_index}   ${gnb_index}


Enable Counter M51328
    [Arguments]  ${ipFilteringInterval}=5min   ${tnl_id_list}=${EMPTY}
    [Documentation]    Enable Counter M51328
    ...   *AUTHOR* hefeng-cookie.qu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   31.3.2022,hefeng-cookie.qu@nokia-sbell.com, added
    ...   31.10.2022,chris.l.cao@nokia-sbell.com, add icmpResponseEnabled=true
    ...   11.3.2023,chris.l.cao@nokia-sbell.com, 'Append To List  ${para_list}  icmpResponseEnabled', make it more readible
    ...   16.5.2023,chris.l.cao@nokia-sbell.com, set actMplaneFronthaulFirewall to true
    ...   22.5.2023,chris.l.cao@nokia-sbell.com, set reportingIntervalPm to 5min to reduce reboot time.
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | ipFilteringInterval | yes | Disable，5, 15, 30, 60, 360, 720, and 1440 minutes, default value is 5min |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Enable Counter M51328 | ipFilteringInterval=5min |
    ...
    Log To Console     Enable Counter M51328
    ${conf}   Get VDU Conf From SCF
    ${bts_id}  set variable   ${conf["mrbts_id"]}

    ${act_tnl_id_list}   Run Keyword If   "${tnl_id_list}"=="${EMPTY}"  Create List   1  2  3  4
    ...   ELSE  Set Variable   ${tnl_id_list}

    ${para_list}    Create List   ipFilteringInterval
    ${value_list}   Create List   ${ipFilteringInterval}
    ${mo_list}      Create List   MRBTS-${bts_id}/TNLSVC-1/PMTNLINT-1

    Append To List   ${para_list}   actMplaneFronthaulFirewall
    Append To List   ${value_list}  true
    Append To List   ${mo_list}     MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1

    Append To List   ${para_list}   reportingIntervalPm
    Append To List   ${value_list}  5min
    Append To List   ${mo_list}     MRBTS-${bts_id}/MNL-1/MNLENT-1/PMCADM-1

    FOR   ${tnl_id}   IN   @{act_tnl_id_list}
        Append To List   ${para_list}   icmpResponseEnabled
        Append To List   ${value_list}  true
        Append To List   ${mo_list}     MRBTS-${bts_id}/TNLSVC-1/TNL-${tnl_id}/IPNO-1
    END

    Vdu Rest Login
    ${ret_dict}   VDU Online Change Parameters   para_list=${para_list}  value_list=${value_list}  mo_list=${mo_list}
    Wait Until Keyword Succeeds    10min    30     OAM Postcondition Cell Should Be Onair

    [Return]  ${ret_dict}


Check Counters M51328C0
    [Arguments]    ${tnl_id_list}=${EMPTY}   ${previous_timestamp}=${EMPTY}   ${number}=20
    [Documentation]  Check Counters M51328C0
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    *Change History*
    ...    31.10.2022,chris.l.cao@nokia-sbell.com, add tnl_id_list, to support TNL-6
    ...    23.2.2023,chris.l.cao@nokia-sbell.com, change to capture last period's counter exactly
    ...    16.5.2023,chris.l.cao@nokia-sbell.com, change to use 'Vdu Check Counter'
    ...
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | PM_collecting_interval                | No  | PM_collecting_interval, unit is minute, default value is 5 |
    ...    | estimated_traffic_generating_duration | No | estimated_traffic_generating_duration, unit is minute, default value is 5 |
    ...    | tnl_id_list | No | tnl_id_list, unit is minute, default value is ${EMPTY}, means 6,7,8,9 |

    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | # Generate traffic |
    ...   | VDU Sync To PM Timer Clock | PM_collecting_interval=5 | estimated_traffic_generating_duration=5 |
    ...   | ${cur_timestamp} | VDU Get Current Timestamp |
    ...   | ${tnl_id_list} | Create List | 8 | 5 | 6 | 7 |
    ...   | Check Counters M51328C0 | tnl_id_list=${tnl_id_list} | number=200 | previous_timestamp=${cur_timestamp} |
    ...
    ${conf}   Get VDU Conf From SCF
    ${bts_id}  set variable   ${conf["mrbts_id"]}
    Sleep    120
    vDU Rest Login

    FOR    ${i}    IN    @{tnl_id_list}
        Log To Console   TNL id:${i}
        ${mo}    set variable    MRBTS-${bts_id}/TNLSVC-1/TNL-${i}/IPNO-1
        ${cur_timestamp}  Vdu Check Counter   mo=${mo}  counter=M51328C0   previous_timestamp=${previous_timestamp}   number=${number}
    END

    [Return]  ${cur_timestamp}


VDU Get Counter Values
    [Arguments]  ${counter_id}  ${dn}
    [Documentation]  VDU Get Counter Values
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    *Change History*
    ...    26.2.2023,chris.l.cao@nokia-sbell.com, solve it returns empty list sometimes
    ...
    ${value}  Wait Until Keyword Succeeds  20x  8  VDU Get Counter Values Once   counter_id=${counter_id}  dn=${dn}
    [Return]  ${value}


VDU Get Counter Values Once
    [Arguments]  ${counter_id}  ${dn}
    Log To Console  VDU Get Counter Values:${counter_id},${dn}
    ${value}  vdu.get_counter_values  ${counter_id}  ${dn}
    Should Be True   ${value.__len__()>0}
    [Return]  ${value}


Get Value From List
    [Arguments]  ${list_name}   ${index}=-1
    ${real_len}   Get Length    ${list_name}
    ${exp_len}   Evaluate   abs(int(${index}))
    ${value}   Set Variable If   ${exp_len}<=${real_len}    ${list_name[${index}]['value']}   0
    [Return]  ${value}


Vdu Check Counter
    [Arguments]   ${mo}  ${counter}  ${previous_timestamp}  ${number}=100
    [Documentation]  VDU check counter
    ...    *AUTHOR* winnie.su@nokia-sbell.com
    ...    *Change History*
    ...    | Date | Who | What and How |
    ...    | 2023-5-14 | winnie.su@nokia-sbell.com | new |
    ...    | 2023-5-25 | chris.l.cao@nokia-sbell.com | update KW description |
    ...    | 2023-6-7  | chris.l.cao@nokia-sbell.com | update example |
    ...
    ...    *RETURN VALUE*
    ...    The timestamp of matched counter
    ...
    ...    Example
    ...    | VDU Sync To PM Timer Clock | PM_collecting_interval=5 | estimated_traffic_generating_duration=5 |
    ...    | #Send traffic towards target to generate desired PM ounter |
    ...    | ${mrbts_id} | Get MRBTS Id From vDU SCF |
    ...    | ${tnl_mcplane}  | Get vDU Instance TNL ID From SCF By VlanIfName | vlanIfName=mcplane |
    ...    | ${mo_mcplane}   | Set Variable | MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_mcplane}/IPNO-1 |
    ...    | ${cur_timestamp} | VDU Get Current Timestamp |
    ...    | VDU Sync To PM Timer Clock | PM_collecting_interval=5 | estimated_traffic_generating_duration=5 |
    ...    | Sleep  |  60s |
    ...    | VDU Sync To PM Timer Clock | PM_collecting_interval=5 | estimated_traffic_generating_duration=5 |
    ...    | VDU Rest Login |
    ...    | Wait Until Keyword Succeeds  | 7min  | 30s |
    ...    | ...  | Vdu Check Counter | mo=${mo_mcplane} | counter=M51328C12 | previous_timestamp=${cur_timestamp} |
    ...
    ${counters}    VDU Get Counter Values    counter_id=${counter}   dn=${mo}
    ${latest_value}   Get Value From List  list_name=${counters}  index=-1
    Log To Console   latest_value:${latest_value}
    Should be true   ${latest_value} >= ${number}

    ${cur_timestamp}   Set Variable   ${counters[-1]['start_time']}
    Log To Console   previous_timestamp:${previous_timestamp}
    Log To Console   latest_timestamp:${cur_timestamp}
    ${r}   Evaluate  '${cur_timestamp}'>'${previous_timestamp}'
    Should Be True  ${r}
    [Return]  ${cur_timestamp}
