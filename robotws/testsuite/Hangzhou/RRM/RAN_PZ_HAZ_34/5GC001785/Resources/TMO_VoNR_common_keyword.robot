*** Settings ***
Documentation
...    author: Ming Shi
...    contact:ming.shi@nokia-sbell.com
...    squad group: 5G_PZ_HZ_3_SG
...    feature : TMO_VoNR

Library     DateTime
Library     taf.analyzer.pcap    WITH NAME    cap
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library     taf.hw.rf_attenuator    WITH NAME    atten
Library     taf.config.testline    WITH NAME    testline
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Library     taf.pdu  WITH NAME   pdu
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/HBTE_PA_setting_voice.py
Library      testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/TMO_common_keywords.py
Library      testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/control_para.py
Library      testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.5GC001785.Resources.xcal_scpi.XcalCommon    WITH NAME    xcalcommon
Library      testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.5GC001785.Resources.xcal_scpi.XcalClient    WITH NAME    xcalclient


*** Variables ***
${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/golden_SCF/
${tl_scf_file_name1}    Configuration_scf_GNB1_TMO_VoNR.xml
${tl_scf_file_name2}    Configuration_scf_GNB2_TMO_VoNR.xml
${control_file_path}    /opt/workspace/SCF/TA_para_control.txt
${ute_ip}    ${tl.test_pc.default_ssh_connection_details.addr}
${ute_username}    ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}    ${tl.test_pc.default_ssh_connection_details.password}
@{ue_action}    attach    detach
${SCF_path}    /opt/workspace/SCF/
${file_path}    /home/ute/
@{hanging_resource_file}    hanging_check_4G_5G.py    hanging_check_4G_5G_gnb2.py



*** Keywords ***
Setup for Env cell on-air for 2 gnb
    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=True
    ...    scf_path=${tl_scf_dir_path}    golden_scf_name=${tl_scf_file_name1}    golden_scf_name_gnb2=${tl_scf_file_name2}

Online add parmeters
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM add several parameters via rest api    parameters_to_add_via_api=${parameters_to_update}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Get counters and write in excel
    [Arguments]    ${filename}    ${counter_info}    ${file_path}=${epc_log_path}${filename}.xlsx    ${timeout}=60
    create_excel_and_write_date_list    start_date=${start_date}    end_date=${end_date}
    ...                         filepath=${file_path}
    ...                         filesheet=${filename}
    FOR  ${pm_counter}  IN   @{counter_info}
        ${counter_value}    get the Counter dict from COAM    gnb_id=${pm_counter['gnb_id']}
        ...                                counter_id=${pm_counter['counter_id']}
        ...                                dic_path=${pm_counter['dic_path']}
        ...                                timeout=${timeout}
        write_counter_to_excel    counter_value=${counter_value}    counter_prop=${pm_counter}
        ...                       filepath=${epc_log_path}${filename}.xlsx
        ...                       filesheet=${filename}
    END

get the Counter dict from COAM
    [Arguments]    ${counter_id}    ${gnb_id}=1    ${dic_path}=full    ${date}=all    ${min_len}=1    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_dict    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}    timeout=${timeout}
    [Teardown]    COAM Teardown gnb connections
    [Return]    ${counter_value}

Prepare with PM counter time caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    360-${utc0}%300
    sleep    ${left_timer}

Calculate KPI to check
    [Arguments]    ${filename}    ${sheetname}    ${kpi_id}
    ${result}    calculate_kpis    kpi_id=${kpi_id}    filename=${epc_log_path}${filename}.xlsx    sheetname=${sheetname}
    [Return]      ${result}
#    Should Be Equal    @{result}[${index}]    @{kpi_value}[${index}]

Lock cell online via coam
    [Arguments]    ${gnb_index}=${0}    ${cell_index}=${1}    ${node_type}=gnb    ${connection}=GNB_OAM    ${enb_index}=${0}
    Run Keyword If    '${node_type}' == 'gnb'
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ...    ELSE IF    '${node_type}' == 'enb'
    ...    coam.connect_to    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    name=${connection}
    Run Keyword If    '${node_type}' == 'gnb'
    ...    coam.lock
    ...    dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRCELL-${cell_index}
    ...    connection=${connection}    timeout=60
    ...    ELSE IF    '${node_type}' == 'enb'
    ...    coam.lock
    ...    dist_name=MRBTS-${tl.enbs[${enb_index}].instance_id}/LNBTS-${tl.enbs[${enb_index}].instance_id}/LNCEL-${cell_index}
    ...    connection=${connection}    timeout=60
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Unlock cell online via coam
    [Arguments]    ${gnb_index}=${0}    ${cell_index}=${1}    ${node_type}=gnb    ${connection}=GNB_OAM    ${enb_index}=${0}
    Run Keyword If    '${node_type}' == 'gnb'
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ...    ELSE IF    '${node_type}' == 'enb'
    ...    coam.connect_to    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    name=${connection}
    Run Keyword If    '${node_type}' == 'gnb'
    ...    coam.unlock
    ...    dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRCELL-${cell_index}
    ...    connection=${connection}    timeout=60
    ...    ELSE IF    '${node_type}' == 'enb'
    ...    coam.unlock
    ...    dist_name=MRBTS-${tl.enbs[${enb_index}].instance_id}/LNBTS-${tl.enbs[${enb_index}].instance_id}/LNCEL-${cell_index}
    ...    connection=${connection}    timeout=60
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections



PA preparation
    [Arguments]    ${cell_type}=SA
    FOR  ${index}    ${pa_name}  IN ENUMERATE   @{all_cell_pa_name}
        Set SFE attenuation value    att_ipaddr=${pa_name}[pa_ip]    att_ports=${pa_name}[pa_ports]    values=${all_cell_pa_initial_values}[${index}]
        Run Keyword If    '${cell_type}'=='NSA'    Set SFE attenuation value    att_ipaddr=${_enb1_cell221_pa_info}[pa_ip]
        ...    att_ports=${enb1_cell221_pa_info}[pa_ports]    values=${enb1_cell221_pa_value}[min]
    END

PA recover
    FOR  ${index}    ${pa_name}  IN ENUMERATE   @{all_cell_pa_name}
        Set SFE attenuation value    att_ipaddr=${pa_name}[pa_ip]    att_ports=${pa_name}[pa_ports]    values=${all_cell_pa_max_values}[${index}]
    END

set PA port on one cell
    [Arguments]    ${pa_name}=${gnb1_cell1_pa_info}    ${value}=${gnb1_cell1_pa_value}[setup][0]
    Set SFE attenuation value    att_ipaddr=${pa_name}[pa_ip]    att_ports=${pa_name}[pa_ports]    values=${value}

set all PA ports and one cell set designated value
    [Arguments]    ${pa_name}=${gnb1_cell1_pa_info}    ${value}=${gnb1_cell1_pa_value}[setup][0]
    Set SFE attenuation value    att_ipaddr=${pa_name}[pa_ip]    att_ports=${pa_name}[pa_ports]    values=${value}
    FOR  ${index}    ${pa_names}  IN ENUMERATE   @{all_cell_pa_name}
        Run Keyword If    ${pa_names}!=${pa_name}    Set SFE attenuation value
        ...    att_ipaddr=${pa_names}[pa_ip]    att_ports=${pa_names}[pa_ports]    values=${all_cell_pa_max_values}[${index}]
    END

Set SFE attenuation value
    [Arguments]    ${att_ports}    ${values}    ${att_connection_port}=${att_connection_port}    ${att_ipaddr}=${att_ipaddr}
    ...    ${max_attenuation_value}=${127}
    [Documentation]    This keyword is to set the test environment PA values, HBTE and topyoung.
    ...    ${att_port}:List all the attenuator ports as int list
    ...    ${value}:List the value of attenuator ports  int list
    ...    ${att_connection_port}:if PA is HBTE, the port is any one port.
    ...                           if PA is topyoung, the port is a List all the attenuator ports as int list
    ${Num_att_port}=    get length    ${att_ports}
    FOR    ${Num}    IN RANGE    ${0}    ${Num_att_port}
        att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
        ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
        att.set_attenuation     port=${att_ports[${Num}]}    value=${values[${Num}]}
#        sleep    1s
        ${value_port}    att.read_attenuation    port=${att_ports[${Num}]}
        ${value_port}=    Convert To Integer    ${value_port}
        should be equal    ${value_port}    ${values[${Num}]}
    END

Adjust_HBTE_PA with all port loop
    [Arguments]    ${pa_name}    ${s_value}    ${e_value}    ${step}    ${ho_times}
    [Timeout]    10 hour
    ${length_s_value}=    get length    ${s_value}
    ${s_value}    Evaluate    float(${s_value}[0])
    ${e_value}    Evaluate    float(${e_value}[0])
    ${step}    Evaluate    float(${step})
    ${ho_times}    Evaluate    float(${ho_times}/2)
    ${step_value}    Evaluate    float((${e_value}-${s_value})/${step})
    ${sleep}    Evaluate    round((${interval}-${step}*${pa_settime})/${step},1)
    FOR  ${times}    IN RANGE    ${ho_times}
       loop for PA set all port value    pa_name=${pa_name}    s_value=${s_value}    step=${step}
       ...    step_value=${step_value}    sleep=${sleep}    port_num=${length_s_value}
    END

loop for PA set all port value
    [Arguments]    ${pa_name}    ${s_value}    ${step}     ${step_value}     ${sleep}    ${port_num}
    FOR  ${index}    IN RANGE    -${step}    ${step}    1
         ${index} =    evaluate    abs(${index})
         ${pa_value} =    evaluate    int(${s_value}+${step_value}*${index})
         ${pa_value}    Create List    ${pa_value}
         ${pa_value} =    evaluate    ${pa_value}*${port_num}
         ${pa_status}    run keyword and return status    set PA port on one cell     pa_name=${pa_name}    value=${pa_value}
         run keyword if  '${pa_status}'=='False'    PA error counter set
         sleep    ${sleep}s
    END

PA error counter set
    ${paerror_counter} =    Evaluate    ${paerror_counter}+1


Adjust_HBTE_PA with loop
    [Arguments]    ${pa_name}    ${s_value}    ${e_value}    ${step}    ${ho_times}
    ${length_s_value}=    get length    ${s_value}
    ${initial_s_value}=    Copy List    ${s_value}
    Set Test Variable    ${initial_s_value}
    ${unequal_port}    Create List
    FOR    ${port}    IN RANGE    ${length_s_value}
        Run Keyword If    ${s_value}[${port}] != ${e_value}[${port}]    Append To List    ${unequal_port}    ${port}
    END
    Set Test Variable    ${need_change_port_index}    ${unequal_port}[0]
    ${step}    Evaluate    float(${step})
    ${ho_times}    Evaluate    float(${ho_times}/2)
    ${step_value}    Evaluate    float((${e_value}[${need_change_port_index}]-${s_value}[${need_change_port_index}])/${step})
    ${s_value}    Evaluate    float(${s_value}[${need_change_port_index}])
    ${e_value}    Evaluate    float(${e_value}[${need_change_port_index}])
    ${sleep}    Evaluate    round((${interval}-${step}*${pa_settime})/${step},1)
    FOR  ${times}    IN RANGE    ${ho_times}
       loop for PA set value    pa_name=${pa_name}    s_value=${s_value}    step=${step}
       ...    step_value=${step_value}    sleep=${sleep}    port_num=${length_s_value}    initial_s_value=${initial_s_value}
       ...    unequal_port=${unequal_port}
    END

loop for PA set value
    [Arguments]    ${pa_name}    ${s_value}    ${step}     ${step_value}     ${sleep}    ${port_num}    ${initial_s_value}
    ...    ${unequal_port}
    FOR  ${index}    IN RANGE    -${step}    ${step}    1
         ${index} =    evaluate    abs(${index})
         ${pa_value} =    evaluate    int(${s_value}+${step_value}*${index})
         change initial s value    unequal_port=${unequal_port}    pa_value=${pa_value}
#         ${pa_value}    Create List    ${pa_value}
#         ${pa_value} =    evaluate    ${pa_value}*${port_num}
         ${pa_status}    run keyword and return status    set PA port on one cell     pa_name=${pa_name}    value=${initial_s_value}
         run keyword if  '${pa_status}'=='False'    PA error counter set
         sleep    ${sleep}s
    END

change initial s value
    [Arguments]    ${unequal_port}    ${pa_value}
    FOR    ${p}    IN    @{unequal_port}
         Set List Value    ${initial_s_value}    ${p}    ${pa_value}
    END



multi UEs attach
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${4G_check}=False    ${gnb_index}=${0}
    Check UE device exist    ue_index=${ue_index}
    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}    gnb_index=${gnb_index}

UEs attach loop
    [Arguments]    ${UE_index_num}    ${4G_check}=False    ${gnb_index}=${0}
    FOR    ${index}    IN    @{UE_index_num}
        multi UEs attach    ue_type=${tl.ues[${index}].capabilities[0]}    ue_index=${index}    4G_check=${4G_check}
        ...    gnb_index=${gnb_index}
    END

multi UEs Detach
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

UEs detach loop
    [Arguments]    ${UE_index_num}
    FOR    ${index}    IN    @{UE_index_num}
        multi UEs Detach    ue_type=${tl.ues[${index}].capabilities[0]}    ue_index=${index}
    END

make voice call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=+6688
    Wait Until Keyword Succeeds    6x    5s    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   2s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

answer voice call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Wait Until Keyword Succeeds    6x    5s    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${answer_VoNR_button}    connection=cygwin${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe_answer_VoNR_button}    connection=cygwin${ue_index}
    sleep    5s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

make and answer voice call
    [Arguments]    ${make_ue_index}=${0}    ${make_serial_number}=${tl.ues[${make_ue_index}].serial_number}    ${phone_number}=+6688
    ...    ${answer_ue_index}=${0}    ${answer_serial_number}=${tl.ues[${answer_ue_index}].serial_number}
    Get VoNR and ViNR pointer variable    make_ue_index=${make_ue_index}    answer_ue_index=${answer_ue_index}
    make voice call    ue_index=${make_ue_index}    serial_number=${make_serial_number}    phone_number=${phone_number}
    answer voice call   ue_index=${answer_ue_index}    serial_number=${answer_serial_number}

check voice call status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=${2}
    Wait Until Keyword Succeeds    6x    5s    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   2s
    ##### check voice call enable  #####
    ##### 0: the phone is in standby state. 1: the call is not answered. 2: the phone is busy  #####
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep mCallState
    ...    connection=cpc_${ue_index}
    sleep   2s
    ${result} =    csn.read output    connection=cpc_${ue_index}
    sleep    1s
    should contain    ${result}    mCallState=${status}
    [Teardown]    csn.disconnect      connection=cpc_${ue_index}

check video call status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=${3}
    Wait Until Keyword Succeeds    6x    5s    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   2s
    ##### check video call enable  #####
    ##### 0: no video call. 3: video call.  #####
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep mDataActivity
    ...    connection=cpc_${ue_index}
    sleep   2s
    ${result} =    csn.read output    connection=cpc_${ue_index}
    sleep    1s
    should contain    ${result}    mDataActivity=${status}
    [Teardown]    csn.disconnect      connection=cpc_${ue_index}

check incallui status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${is_incallui}=${True}
    Wait Until Keyword Succeeds    6x    5s    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   2s
    ##### check video call enable  #####
    ##### 0: no video call. 3: video call.  #####
    csn.send_command    command=adb -s ${serial_number} shell dumpsys activity | grep mResumedActivity
    ...    connection=cpc_${ue_index}
    sleep   2s
    ${result} =    csn.read output    connection=cpc_${ue_index}
    sleep    1s
    Run Keyword If    ${is_incallui} == ${True}
    ...    Should Contain    ${result}    android.incallui
    ...    ELSE IF    ${is_incallui} == ${False}
    ...    Should Not Contain    ${result}    android.incallui
    [Teardown]    csn.disconnect      connection=cpc_${ue_index}

make multi ues voice loop
    [Arguments]    ${UE_phone_numbers}    ${phone_number}=+6688    ${status}=${2}
    FOR    ${index}    ${phone_no}    IN ENUMERATE    @{UE_phone_numbers}
        make voice call    ue_index=${index}+2    phone_number=${phone_no}
        Wait Until Keyword Succeeds    10x    2s    check voice call status    ue_index=${index}+2    status=${status}
    END

hang up voice call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Wait Until Keyword Succeeds    6x    5s    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}    look_for_keys=False
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

hang up multi ues voice loop
    [Arguments]    ${UE_index_num}    ${status}=${0}
    FOR    ${index}    IN    @{UE_index_num}
        hang up voice call    ue_index=${index}
        Wait Until Keyword Succeeds    10x    2s    check voice call status    ue_index=${index}    status=${status}
    END


Get VoNR and ViNR pointer variable
    [Arguments]    ${make_ue_index}=${0}    ${answer_ue_index}=${0}
    Run Keyword If    '${tl.ues[${make_ue_index}].capabilities[0]}'=='samsung'
    ...    Get make UE VoNR and ViNR pointer variable with samsung S21
    Run Keyword If    '${tl.ues[${answer_ue_index}].capabilities[0]}'=='samsung'
    ...    Get answer UE VoNR and ViNR pointer variable with samsung S21

Get make UE VoNR and ViNR pointer variable with samsung S21
    Set Suite Variable    ${trigger_video_button_on_VoNR}    531 1313
    Set Suite Variable    ${make_VoNR_ViNR_together_button}    222 1959
    Set Suite Variable    ${video_button}    210 2048

Get answer UE VoNR and ViNR pointer variable with samsung S21
    Set Suite Variable    ${answer_VoNR_button}    216 450
    Set Suite Variable    ${swipe_answer_VoNR_button}    225 1990 225 1428
    Set Suite Variable    ${answer_ViNR_button}    219 2054
    Set Suite Variable    ${answer_VoNR_ViNR_together_button}    229 1879 225 1428

trigger video call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}   #${phone_number}=18001006149
    Wait Until Keyword Succeeds    6x    5s    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${trigger_video_button_on_VoNR}    connection=cygwin${ue_index}
    sleep    5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${video_button}    connection=cygwin${ue_index}
    sleep    5s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

make voice video call together
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=18001006149
    Wait Until Keyword Succeeds    6x    5s    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   2s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR and ViNR call together#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.DIAL tel:+86${phone_number}
    ...    connection=cygwin${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${make_VoNR_ViNR_together_button}    connection=cygwin${ue_index}
#    sleep    5s
#    csn.send_command    command=adb -s ${serial_number} shell input tap ${video_button}    connection=cygwin${ue_index}
    sleep    5s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

answer video call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Wait Until Keyword Succeeds    6x    5s    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${answer_ViNR_button}    connection=cygwin${ue_index}
    sleep    5s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

answer voice video call together
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Wait Until Keyword Succeeds    6x    5s    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input swipe ${answer_VoNR_ViNR_together_button}    connection=cygwin${ue_index}
    sleep    5s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

Make VoNR and ViNR call together
    [Arguments]    ${phone_number}=18001006306    ${ue_index}=${0}    ${answer_ue_index}=${1}
    Get VoNR and ViNR pointer variable    make_ue_index=${ue_index}    answer_ue_index=${answer_ue_index}
    make voice video call together    ue_index=${ue_index}    phone_number=${phone_number}
    answer voice video call together   ue_index=${answer_ue_index}

make multi ues VoNR and ViNR call together loop
    [Arguments]    ${UE_index_num}    ${status}=${3}
    FOR    ${index}    IN    @{UE_index_num}
        Make VoNR and ViNR call together    phone_number=${tl.ues[${index}+1].sec_key}    ue_index=${index}    answer_ue_index=${index}+1
        Wait Until Keyword Succeeds    10x    2s    check video call status    ue_index=${index}    status=${status}
    END

Make video call
    [Arguments]    ${phone_number}=18001006306    ${ue_index}=${0}    ${answer_ue_index}=${1}
    Get VoNR and ViNR pointer variable    make_ue_index=${ue_index}    answer_ue_index=${answer_ue_index}
    make voice call    ue_index=${ue_index}    phone_number=${phone_number}
    answer voice call   ue_index=${answer_ue_index}
    trigger video call    ue_index=${ue_index}
    answer video call    ue_index=${answer_ue_index}

make multi ues video loop
    [Arguments]    ${UE_index_num}    ${status}=${3}
    FOR    ${index}    IN    @{UE_index_num}
        Make video call    phone_number=${tl.ues[${index}+1].sec_key}    ue_index=${index}    answer_ue_index=${index}+1
        Wait Until Keyword Succeeds    10x    2s    check video call status    ue_index=${index}    status=${status}
    END

hang up video call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Wait Until Keyword Succeeds    6x    5s    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}    look_for_keys=False
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

hang up multi ues video loop
    [Arguments]    ${UE_index_num}    ${status}=${0}
    FOR    ${index}    IN    @{UE_index_num}
        hang up video call    ue_index=${index}
        Wait Until Keyword Succeeds    10x    2s    check video call status    ue_index=${index}    status=${status}
    END

Make EMC call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    Wait Until Keyword Succeeds    6x    5s    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cpc_${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:${phone_number}
    ...    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
    ...    connection=cpc_${ue_index}
    [Teardown]    csn.disconnect      connection=cpc_${ue_index}

make multi ues EMC loop
    [Arguments]    ${UE_index_num}    ${phone_number}=911    ${is_incallui}=${True}
    FOR    ${index}    IN    @{UE_index_num}
        Make EMC call    ue_index=${index}    phone_number=${phone_number}
        Wait Until Keyword Succeeds    10x    2s    check incallui status    ue_index=${index}    is_incallui=${is_incallui}
    END

hang up EMC call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Wait Until Keyword Succeeds    6x    5s    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 485 37    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
    ...    connection=cpc_${ue_index}
    sleep    5s
    [Teardown]    csn.disconnect      connection=cpc_${ue_index}

hang up multi ues EMC loop
    [Arguments]    ${UE_index_num}    ${is_incallui}=${False}
    FOR    ${index}    IN    @{UE_index_num}
        hang up EMC call    ue_index=${index}
        Wait Until Keyword Succeeds    10x    2s    check incallui status    ue_index=${index}    is_incallui=${is_incallui}
    END

Setup UE data status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=enable
    Wait Until Keyword Succeeds    6x    5s    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell svc data ${status}    connection=cygwin${ue_index}
    sleep   2s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

Setup UE mobile data loop
    [Arguments]    ${UE_index_num}    ${status}=enable
    FOR    ${index}    IN    @{UE_index_num}
        Setup UE data status    ue_index=${index}    status=${status}
    END

make multi ues network with single pc
    [Arguments]    ${action_index}=${0}    ${control_pc_ip}=${tl.ues[0].ssh_connection_details.addr}
    ...    ${pc_username}=${tl.ues[0].ssh_connection_details.username}
    ...    ${pc_password}=${tl.ues[0].ssh_connection_details.password}    ${count_num}=${4}    ${path}=${file_path}
    multi_ues_operation_exe_with_threading    action=${ue_action}[${action_index}]    pc_ip=${control_pc_ip}
    ...    pc_username=${pc_username}    pc_password=${pc_password}    count_num=${count_num}    path=${path}

multi_ues_operation_exe_with_threading
    [Arguments]    ${action}    ${pc_ip}=${tl.ues[0].ssh_connection_details.addr}
    ...    ${pc_username}=${tl.ues[0].ssh_connection_details.username}
    ...    ${pc_password}=${tl.ues[0].ssh_connection_details.password}    ${count_num}=${4}    ${path}=${file_path}
    Wait Until Keyword Succeeds    6x    5s    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=ute
    sleep    2s
    Wait Until Keyword Succeeds    2min    10s    csn.send command
    ...    command=chmod +x ${SCF_path}multi_ue_attach_threading.exe; chmod +x ${SCF_path}multi_ue_detach_threading.exe
    ...    connection=ute
    sleep    1s
    Run Keyword If    '${action}'=='attach'    Run Keywords
    ...    csn.send command
    ...    command=wine ${SCF_path}multi_ue_attach_threading.exe ${pc_ip} ${pc_username} ${pc_password}
    ...    connection=ute
    ...    AND    sleep    20s
    ...    AND    Wait Until Keyword Succeeds    5min    10s    get_count_of_voice    path=${path}
    ...    count_num=${count_num}    file_name=attach
    ...    ELSE IF    '${action}'=='detach'    Run Keywords
    ...    csn.send command
    ...    command=wine ${SCF_path}multi_ue_detach_threading.exe ${pc_ip} ${pc_username} ${pc_password}
    ...    connection=ute
    ...    AND    sleep    20s
    ...    AND    Wait Until Keyword Succeeds    5min    10s    get_count_of_voice    path=${path}
    ...    count_num=${count_num}    file_name=detach
    [Teardown]    csn.disconnect     connection=ute

multi_ues_operations_voice_call_exe_with_threading
    [Arguments]    ${num}    ${operation}    ${pc_ip}=${tl.ues[0].ssh_connection_details.addr}
    ...    ${pc_username}=${tl.ues[0].ssh_connection_details.username}
    ...    ${pc_password}=${tl.ues[0].ssh_connection_details.password}    ${count_num}=${4}    ${path}=${file_path}
    Wait Until Keyword Succeeds    6x    5s    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=ute
    sleep    2s
    Wait Until Keyword Succeeds    2min    10s    csn.send command
    ...    command=chmod +x ${SCF_path}multi_ue_operations_threading.exe
    ...    connection=ute
    sleep    1s
    csn.send command
    ...    command=wine ${SCF_path}multi_ue_operations_threading.exe ${pc_ip} ${pc_username} ${pc_password} "${num}" ${operation}
    ...    connection=ute
    sleep    20s
    Wait Until Keyword Succeeds    5min    10s    get_count_of_voice    path=${path}    count_num=${count_num}    file_name=${operation}
    [Teardown]    csn.disconnect     connection=ute

get_count_of_voice
    [Arguments]    ${path}=${file_path}    ${count_num}=${4}    ${file_name}=${voice_call_action}[0]
    ${count}=    get_result_with_voice_operation    path=${path}    file_name=${file_name}
    Should Be Equal    ${count}    ${count_num}



get CIENV folder name
    ${ci_env_name}=    get_ci_env_name    ute_ip=${ute_ip}    username=${ute_username}    password=${ute_password}
    Set Suite Variable    ${tl_ci_name}    ${ci_env_name}

check hanging resource
    get CIENV folder name
    start_hanging_resource_file    ip=${ute_ip}    username=${ute_username}    password=${ute_password}
    ...    tl_cienv_name=${tl_ci_name}    file_name=${hanging_resource_file}[0]
    start_hanging_resource_file    ip=${ute_ip}    username=${ute_username}    password=${ute_password}
    ...    tl_cienv_name=${tl_ci_name}    file_name=${hanging_resource_file}[1]






Start traffic of all required UE
    [Arguments]    ${UE_index_num}    ${traffic_direction}=DL
    Run Keyword If    '${traffic_direction}' == 'DL'    Start all required UE DL data transfer    UE_index_num=${UE_index_num}
    ...    ELSE IF    '${traffic_direction}' == 'UL'    Start all required UE UL data transfer    UE_index_num=${UE_index_num}
    ...    ELSE IF    '${traffic_direction}' == 'ALL'    Start all required UE data transfer    UE_index_num=${UE_index_num}

Start all required UE data transfer
    [Arguments]    ${UE_index_num}    ${source_port}=${tl.appserver.iperf_details.port}
    Stop all required UE data transfer    UE_index_num=@{UE_index_num}
    sleep    3s
    FOR  ${ue_index}    IN    @{UE_index_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${dl_port} =    evaluate    ${source_port} + ${ue_index}
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_dl_iperf.sh ${tl.ues[${ue_index}].serial_number} ${dl_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END
    sleep    3s
    FOR  ${ue_index}    IN    @{UE_index_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${ul_port} =    evaluate    ${source_port} - (${ue_index} + ${1})
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_ul_iperf.sh ${tl.ues[${ue_index}].serial_number} ${ul_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END

Start all required UE DL data transfer
    [Arguments]    ${UE_index_num}    ${source_port}=${tl.appserver.iperf_details.port}
    Stop all required UE data transfer    UE_index_num=@{UE_index_num}
    sleep    3s
    FOR  ${ue_index}    IN    @{UE_index_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${dl_port} =    evaluate    ${source_port} + ${ue_index}
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_dl_iperf.sh ${tl.ues[${ue_index}].serial_number} ${dl_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END

Start all required UE UL data transfer
    [Arguments]    ${UE_index_num}    ${source_port}=${tl.appserver.iperf_details.port}
    Stop all required UE data transfer    UE_index_num=@{UE_index_num}
    sleep    3s
    FOR  ${ue_index}    IN    @{UE_index_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${ul_port} =    evaluate    ${source_port} - (${ue_index} + ${1})
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_ul_iperf.sh ${tl.ues[${ue_index}].serial_number} ${ul_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END

Stop all required UE data transfer
    [Arguments]    ${UE_index_num}
    FOR  ${ue_index}    IN    @{UE_index_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        csn.send command
#        ...    command=ps -ef | grep "adb" | grep -v grep | awk '{print $2}' | xargs kill -s 9
        ...    command=ps -ef |grep iperf3 |awk '{print $2}'|xargs kill -9
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    3s
    END


Connect to control pc for XCAL
    [Arguments]
    ...    ${pc_ip}=${tl.ues[0].ssh_connection_details.addr}
    ...    ${pc_username}=${tl.ues[0].ssh_connection_details.username}
    ...    ${pc_password}=${tl.ues[0].ssh_connection_details.password}    ${connection}=pc_XCAL
    Wait Until Keyword Succeeds    2m    20s
    ...    csn.Connect to    hostname=${pc_ip}    username=${pc_username}    password=${pc_password}    alias=${connection}

close control pc for XCAL
    [Arguments]    ${connection}=pc_XCAL
    csn.disconnect     connection=${connection}

startup xcal app
    [Arguments]
    sleep    5s
#    xcalclient.startapp

close xcal app
    [Arguments]
    sleep    0.5s
#    xcalclient.close_app

UE attach via XCAL
    Connect to control pc for XCAL
    UE attach via XCAL script
    [Teardown]    close control pc for XCAL

UE detach via XCAL
    Connect to control pc for XCAL
    UE detach via XCAL script
    [Teardown]    close control pc for XCAL

UE attach via XCAL script
    [Arguments]    ${action}=attach    ${need_during_time}=10     ${connection}=pc_XCAL
    csn.send command
    ...    command=/cygdrive/c/XCAL/xcal_scpi.exe ${action} ${need_during_time}
    ...    connection=${connection}
#    sleep    60s
    ${output}    csn.read output    connection=${connection}
    Should Contain    ${output}    attach successful

UE detach via XCAL script
    [Arguments]    ${action}=detach    ${need_during_time}=10     ${connection}=pc_XCAL
    csn.send command
    ...    command=/cygdrive/c/XCAL/xcal_scpi.exe ${action} ${need_during_time}
    ...    connection=${connection}

start autocall via xcal script
    [Arguments]    ${action}=start_autocall    ${need_during_time}=60    ${connection}=pc_XCAL
    csn.send command
    ...    command=/cygdrive/c/XCAL/xcal_scpi.exe ${action} ${need_during_time}
    ...    connection=${connection}
    sleep    ${need_during_time}s

start autocall via xcal
    Connect to control pc for XCAL
    start autocall via xcal script
    [Teardown]    close control pc for XCAL

stop autocall via xcal script
    [Arguments]    ${action}=stop_autocall    ${need_during_time}=10    ${connection}=pc_XCAL
    csn.send command
    ...    command=/cygdrive/c/XCAL/xcal_scpi.exe ${action} ${need_during_time}
    ...    connection=${connection}

stop autocall via xcal
    Connect to control pc for XCAL
    stop autocall via xcal script
    [Teardown]    close control pc for XCAL

start stop autocall and check mos value via xcal script
    [Arguments]    ${action}=start_stop_autocall_check_mos    ${need_during_time}=600    ${connection}=pc_XCAL
    csn.send command
    ...    command=/cygdrive/c/XCAL/xcal_scpi.exe ${action} ${need_during_time}
    ...    connection=${connection}
    sleep    ${need_during_time}s
    ${output}    csn.read output    connection=${connection}
    [Return]    ${output}

start stop autocall and check mos value via xcal
    [Arguments]
    Connect to control pc for XCAL
    ${output}    start stop autocall and check mos value via xcal script
    ${all_mos_result}    xcalcommon.get_mos_value    output=${output}
    Should Be True    ${all_mos_result}[0] > 4
    Should Be True    ${all_mos_result}[1] > 4
    [Teardown]    close control pc for XCAL

check mos value via xcal script
    [Arguments]    ${action}=check_mos_value    ${need_during_time}=10    ${connection}=pc_XCAL
    csn.send command
    ...    command=/cygdrive/c/XCAL/xcal_scpi.exe ${action} ${need_during_time}
    ...    connection=${connection}
    sleep    ${need_during_time}s
    ${output}    csn.read output    connection=${connection}
    [Return]    ${output}

check mos value via xcal
    [Arguments]
    Connect to control pc for XCAL
    ${output}    check mos value via xcal script
    ${all_mos_result}    xcalcommon.get_mos_value    output=${output}
    Should Be True    ${all_mos_result}[0] >= 3.5
    Should Be True    ${all_mos_result}[1] >= 3.5
    [Teardown]    close control pc for XCAL
