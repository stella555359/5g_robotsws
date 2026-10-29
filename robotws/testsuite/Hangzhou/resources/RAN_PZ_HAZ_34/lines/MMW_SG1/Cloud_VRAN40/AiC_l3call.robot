*** Settings ***
Documentation    Suite description
Resource    ./AiC_log_Collect.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/l3call.robot
Resource    ./vDU.robot
Resource    ./vCU.robot

*** Keywords ***
_Main Functions for search
    Cloud UE Attach and Verify Attach
    Cloud Do UE Attach Action
    Cloud Verify Attach
    Cloud Standard Capturing Kubectl Throughput

################################## STEP1: Do UE ATTACH and Verify  ##################################
Cloud UE Attach and Verify Attach
    [Documentation]    Author: Dandan Fang
    ...      du_master_conn: alias use to build ssh connection with vdu ocp master
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${gnb_index}=${0}    ${vdu_index}=0   ${4G_check}=${True}
    ...     ${attach_log_name}=l2RT_5Grach.txt
    ...     ${du_master_conn}=gnb${gnb_index}_du${vdu_index}_master
     # start k8 logs before do ue attach
    ${attach_log_path_on_vdu}      Start to collect log from logservice pod on VDU
    ...      log_name=${attach_log_name}
    ...      gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ...      conn_alias=${du_master_conn}   logs_filter=L2Lo
    ${5Grach_ed}    Cloud Do UE Attach Action    ue_index=${ue_index}
    ...     remote_log_check=${attach_log_path_on_vdu}    du_master_conn=${du_master_conn}

    ${attach_status}    run keyword and return status    Cloud Verify Attach    5Grach_ed=${5Grach_ed}
    ...    4G_check=${4G_check}    ue_index=${ue_index}
    ...    remote_log_check=${attach_log_path_on_vdu}    du_master_conn=${du_master_conn}

    ${ue_ip_status}    run keyword and return status
    ...    Run keyword if    '${ue_type}'=='qct_dx50'    wait until keyword succeeds  2 min    5 sec
    ...        android_common_keyword.Get the UE Ip address    ue_index=${ue_index}
    [Return]    ${attach_status}   ${ue_ip_status}
    [Teardown]      Run Keyword And Ignore Error
    ...    Stop log collection from logservice pod on VDU and download log to local    log_path_on_vdu=${attach_log_path_on_vdu}
    ...        gnb_index=${gnb_index}    vdu_index=${vdu_index}    conn_alias=${du_master_conn}

Cloud Do UE Attach Action
    [Documentation]    Author: Dandan Fang
    ...  Attach UE for L3 call test.
    ...  With kubelog catch vDU L2RT logs
    ...  remote_log_check: which log in remote will be used to check.
    ...  du_master_conn: alias use to build ssh connection with vdu ocp master
    [Arguments]    ${ue_index}    ${remote_log_check}    ${du_master_conn}=vdu_master
    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    Get 5GRACH success times on vDU side
    ...     ${remote_log_check}   du_master_conn=${du_master_conn}

    ${attach_status}    run keyword and return status  Ue attach with index    ue_index=${ue_index}
    run keyword and continue on failure    ute_ue.turn mobile data on    alias=UE_${ue_index}
    run keyword if     '${attach_status}'=='False'    run keywords    Ue reattach with index    ue_index=${ue_index}    AND
    ...    run keyword and continue on failure    ute_ue.turn mobile data on    alias=UE_${ue_index}
    [Return]    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}

Cloud Verify Attach
    [Documentation]      Author: Dandan Fang
    ...  Verify attach result when plugin self verify not suffient
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for verify attach
    ...  :param  5Grach_ed: the return value from ue attach, contain the RACH count and time and check location
    ...  :param  remote_log_check: remote log to get attach status
    ...  :param  4G_check: 4G ue attach need check or not
    ...  :param  5Gstatus: The expected 5G attach result, contain special sce need attach fail check
    [Arguments]    ${ue_index}   ${5Grach_ed}   ${remote_log_check}   ${du_master_conn}
    ...            ${4G_check}=True   ${5Gstatus}=PASS
    ${4G_attach_status}    run keyword and return status    run keyword if    '${4G_check}' == 'True'
    ...    wait until keyword succeeds    1 min    10s    Verify 4G Attach by ADB Command    ue_index=${ue_index}
    run keyword and continue on failure    should be true    ${4G_attach_status}==${True}
    log to console   Cloud 5G attach time info: ${5Grach_ed}
    ${status_l2lo}    run keyword and return status   wait until keyword succeeds    1 min    10s    Check 5G Rach Status on vDU side
    ...    before=${5Grach_ed[0]}    before_time=${5Grach_ed[1]}
    ...    5Gstatus=${5Gstatus}
    ...    remote_log_check=${remote_log_check}   du_master_conn=${du_master_conn}
    ${5G_attach_status}    set variable if    ${status_l2lo}==${True}    ${True}    ${False}
    ${attach_status}    Create Dictionary    4G_attach_status=${4G_attach_status}    5G_attach_status=${5G_attach_status}
    should be true    ${5G_attach_status}==${True}
    [Return]    ${attach_status}

Get 5GRACH success times on vDU side
    [Documentation]      Author: Dandan Fang
    ...   This keyword help to check the 5G RACH status in gnb side
    ...
    ...    |    Input Parameters     | Man. | Description |
    ...    |   remote_log_check  | Yes  | which log to check, give full path  ... |
    [Arguments]     ${remote_log_check}   ${du_master_conn}=vdu_master
    ${output}=    csn.Execute
    ...     cat ${remote_log_check} | grep -aE "flow control starts|Start flow control successfull" | grep -av grep
    ...     connection=${du_master_conn}

    @{list}    split string    ${output}    \n
    Remove Values From List    ${list}   ${empty}
    ${len}    Get Length    ${list}
    ${last_line}    Run keyword if    ${len}>0    Get From List    ${list}    -1

    ${last_rach_time}=    Run keyword if    ${len}>0    Get Regexp Matches    ${last_line}    \\d{2}\\:\\d{2}\\:\\d{2}\\.[\\d|\\w]*
    ...     ELSE   Create List
    # kubectl log have two timestamp, first is core real time, second is gnb time
    # ['11:55:26.765589', '03:55:26.726500Z']
    ${time_Length}    Get Length    ${last_rach_time}
    ${last_rach_time}    Run keyword if  ${time_Length}==${0}   Set Variable  ${None}
    ...      ELSE IF  ${time_Length}==${2}     Set Variable     ${last_rach_time}[1]
    ...      ELSE IF  ${time_Length}==${1}     Set Variable     ${last_rach_time}
    [Return]    ${len}    ${last_rach_time}

Check 5G Rach Status on vDU side
    [Documentation]  This keyword is used to stop collecting k8s logs on specific container
    ...
    ...  *AUTHOR*dandan.fang@nokia-sbell.com
    ...
    ...    |    Input Parameters     | Man. | Description |
    ...    |   before  | Yes  | successful attach times before this attach ... |
    ...    |   before_time  | Yes  | time which before this attach ... |
    ...    |   remote_log_check  | Yes  | which log to check, give full path  ... |
    ...    |   5Gstatus  | No  | check 5G status, Pass defualt ... |
    [Arguments]    ${before}     ${before_time}     ${remote_log_check}    ${du_master_conn}   ${5Gstatus}=PASS
    ${5Grach_ing}    ${5Grach_time_ing}    Get 5GRACH success times on vDU side
    ...             remote_log_check=${remote_log_check}    du_master_conn=${du_master_conn}

    run keyword if     '${5Gstatus}'=='PASS'    verify 5G rach success    before=${before}     after=${5Grach_ing}
    ...                                         before_time=${before_time}    after_time=${5Grach_time_ing}
    run keyword if     '${5Gstatus}'=='FAIL'    verify 5G rach not success    before=${before}     after=${5Grach_ing}
    ...                                         before_time=${before_time}    after_time=${5Grach_time_ing}

################################## Throughput Capture keyword ##################################
Cloud Standard Capturing Kubectl Throughput
    [Documentation]    Author: Dandan Fang
    ...    Keep capturing Aasyslog for given duration.
    ...                As the moment traffic just started, throughput will be unstable (Acceptable and should be ignored)
    ...                Add Ignore time before and after throughput capturing.
    ...                Author: Dandan Fang
    ...                Contact: dandan.fang@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param vdu_index: the du index mean the left or right board in AMIA
    ...                :param duration: duration of log capturing. E.G 10min / 1hour
    ...                :param ignore_time: how long will be ignored before capturing. E.G 10min / 1hour
    ...  Refer: testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/Power_ue_supports/power_ue_throughput.robot
    ...         __Standard Capturing Aasyslog Throughput
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${conn_alias}=gnb${gnb_index}_du${gnb_index}_master    ${duration}=1min
    ...            ${check_tput_ignore_time}=1min    ${log_name}=L2RT_tput.txt
    ...            ${upload_duration}=${True}
    sleep    ${check_tput_ignore_time}
    ${start_timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    log to console     Kubectl Throughput Start + ${start_timestamp}

    ${tput_log_path_on_vdu}    Start to collect log from logservice pod on VDU    log_name=${log_name}    gnb_index=${gnb_index}
    ...    vdu_index=${vdu_index}    logs_filter=SentDataMeasurementCounting\\|UlCounterUpdate    conn_alias=${conn_alias}
    Sleep    ${duration}    msg=Waiting to capture throughput logs
    ${tput_log_path_in_local}    Stop log collection from logservice pod on VDU and download log to local
    ...    log_path_on_vdu=${tput_log_path_on_vdu}    gnb_index=${gnb_index}     vdu_index=${vdu_index}    conn_alias=${conn_alias}
    ${end_timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    log to console     Kubectl Throughput end + ${end_timestamp}
    run keyword if    '${upload_duration}'=='${True}'    run keyword and ignore error
    ...               RobotCaseInfo.add_throughput_duration     duration=${duration}
    ...                                                         ignore_time=${check_tput_ignore_time}
    [Return]    ${tput_log_path_in_local}
