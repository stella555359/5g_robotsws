*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB008698_EDA Common Keywords

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/ping_pang_common_keywords.robot

Library     taf.analyzer.pcap    WITH NAME    cap

Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008698/Resources/CB008698_EDA_variables.py

*** Keywords ***
Common Suite Setup For CB008698 EDA
    Common Suite Setup for COAM
    Get sagnb version for selenium
    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
    Common Case TestLine Setup    is_commission=${True}    scf_path=${tl_scf_dir_path}    golden_scf_name=${tl_gnb1_scf_${sw_version}}

Common Suite Teardown For CB008698 EDA
    Common Suite Teardown for COAM    gnb_list=${gnb_list}

Common Case Setup For CB008698 EDA
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291
    AlarmWatchdog.add_allow_alarms    fault_id=4291
#    Start capture syslog via btslog on ute

Common Case Teardown For CB008698 EDA
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=4291
#    Stop capture syslog via btslog on ute
#    ${name}=    Evaluate    '${TEST NAME}'.replace(" ", "_")
#    Set Test Variable    ${name}
#    syslog analysis via regex file
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

PA set required cell to needed value and set other cells to max value
    [Arguments]    ${index}    ${values}
    FOR    ${i}    ${pa_info}    IN ENUMERATE    @{RU_PA_info}
        IF    ${i} != ${index}
            ${max_values}=    Evaluate    [${127}] * len(${pa_info}[ports])
            Set the attenuation value of ports simultaneously
            ...    att_ports=${pa_info}[ports]
            ...    values=${max_values}
            ...    att_ipaddr=${pa_info}[att_ipaddr]
        ELSE
            Set the attenuation value of ports simultaneously
            ...    att_ports=${pa_info}[ports]
            ...    values=${values}
            ...    att_ipaddr=${pa_info}[att_ipaddr]
        END
    END

set apn to default dxdata2
    Set Suite Variable    ${close_task}    538 1874
    set apn with special method    usedapn=${DXDATA2_APN}    location_apn=${CLICK_ACCESS_POINT}

UE attach with wireshark captured
    [Arguments]    ${filename}    ${ue_type}    ${ue_index}    ${is_new_prepare_ue}=${False}    ${4G_check}=False
    IF     ${is_new_prepare_ue}==${False}
        Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ELSE
        Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${tl.ues[${ue_index}].capabilities[2]}    ue_index=${ue_index}
    END
    Start capture gNB log on master    filename=${filename}
    Run Keyword If    '${ue_type}' != 'qct_dx50'    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
    Set Suite Variable    ${iperf_button}    722 366
    IF    '${ue_type}' == 'samsung'
        UE click once for airplane disable    ue_index=${ue_index}
    ELSE
        power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${0}
    END
    Log    ${4G_check}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}
    [Teardown]    Stop and download Logs on gNB on master    filename=${filename}

UE attach with wireshark captured without verify
    [Arguments]    ${filename}    ${ue_type}    ${ue_index}    ${is_new_prepare_ue}=${False}
    IF     ${is_new_prepare_ue}==${False}
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ELSE
        power_ue.Prepare UE    ue_type=${tl.ues[${ue_index}].capabilities[2]}    ue_index=${ue_index}
    END
    Start capture gNB log on master    filename=${filename}
    Run Keyword If    '${ue_type}' != 'qct_dx50'    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
    Set Suite Variable    ${iperf_button}    722 366
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    [Teardown]    Stop and download Logs on gNB on master    filename=${filename}

UE click once for airplane disable
    [Arguments]    ${Home_button}=${Home_button}    ${swipe}=${swipe}    ${airplane}=${airplane}    ${close_task}=${close_task}
    ...   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   2s
    #####Press the Home button to open the screen#####
    Run Keyword and Ignore Error   Awake UE if Sleepy   ue_index=${ue_index}   serial_number=${serial_number}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   4s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   4s
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS    connection=cygwin
    sleep   4s
    csn.send_command    command=adb -s ${serial_number} shell dumpsys window | grep FocusedWindow    connection=cygwin
    sleep   2s
    ${output}   csn.read_output    connection=cygwin
    #####Tap the airplane mode switch to enable airplane mode#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=cygwin
    sleep   8s
    #####Click the task button#####
    run keyword if    '${brand}'=='Xiaomi'   Run Keyword and Ignore Error
    ...   csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   4s
    run keyword if    '${brand}'=='lge'   Run Keyword and Ignore Error
    ...   Close Airmode confirm window for lg_v50   old_output=${output}    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    sleep   4s
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=cygwin
    [Teardown]    csn.disconnect      connection=cygwin

per UE detach
    [Arguments]    ${ue_type}    ${ue_index}    ${is_new_prepare_ue}=${False}
    IF     ${is_new_prepare_ue}==${False}
        Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ELSE
        Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${tl.ues[${ue_index}].capabilities[2]}    ue_index=${ue_index}
    END
    UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

UEs detach case_1
    FOR    ${ue_index}    IN    @{EDA_05272546_ue_index_CASE_1}
        per UE detach
        ...    ue_type=${UES_TYPE}[${ue_index}]
        ...    ue_index=${ue_index}
        ...    is_new_prepare_ue=${is_new_Qcom_ue_type}[${ue_index}]
    END

UEs detach case_2
    FOR    ${ue_index}    IN    @{EDA_05272546_ue_index_CASE_2}
        per UE detach
        ...    ue_type=${UES_TYPE}[${ue_index}]
        ...    ue_index=${ue_index}
        ...    is_new_prepare_ue=${is_new_Qcom_ue_type}[${ue_index}]
    END

Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Check required counters as expected_values
    [Arguments]    ${counter_ids}    ${dic_paths}    ${expected_values}    ${gnb_id}=${1}    ${timeout}=300
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    FOR    ${index}    ${counter_id}    IN ENUMERATE    @{counter_ids}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
        ...    dic_path=${dic_paths}[${index}]    timeout=${timeout}
        Should Be True    ${counter_value[0]} >= ${expected_values}[${index}]
    END
    [Teardown]    COAM Teardown gnb connections
