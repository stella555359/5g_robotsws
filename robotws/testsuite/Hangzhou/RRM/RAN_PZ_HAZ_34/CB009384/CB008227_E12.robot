*** Settings ***
Force Tags    PY36
Documentation     author: qingqing.zhang
...                 contact: qingqing.zhang@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB008227-E

Resource    ./Resources/CB009384_common_keywords.robot
Variables    ./Resources/CB009384_variables.py
Library    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008227/Resources/CB008227_traffic.py



Suite Setup    Common Suite Setup for COAM

Suite Teardown    Run Keywords
...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections


*** Variables ***
${gnb_path}    /tmp
${scf_path}    /opt/workspace/CRT/Master/SCF_file/
${golden_scf_name}    golden_TDD
#${tl_scf_SBTS24R3_ENB_9999}    golden_TDD_SBTS24R3_ENB_9.xml
#${tl_scf_SBTS24R2_ENB_0000}    golden_TDD_SBTS24R2_ENB_0.xml
${interface1}    any
${expected_tput_ul}    76
${expected_tput_dl}   190
${expected_tput_ul_grant}    40
${expected_tput_dl_grant}   55
@{2drbs}    8   9
${ue_index}    ${2}
${ue_index_APPserver}    ${0}
${dl_port_5QI9}    ${56009}
${dl_port_5QI8}    ${53344}
@{dl_ports}    ${dl_port_5QI9}    ${dl_port_5QI8}
${file_name_E12}    8227_E12
${logname_3drbs}    E_3drbs.pcap
${iperf_path}     /usr/bin/
@{branch}    SBTS24R2_ENB_0
*** Test Cases ***
[1]CB008227_E_12_B5_NBR_UE_resource_allocation_limit_interworking_with_multiple_dedicated_BWPs
    [Documentation]
    ...    This case checks RedCap UE setup 16 drbs.(up to 8drbs due to M60 UE limitation)
    [Tags]    classical    CRT_TRUNK    CRT_23R3
    [Setup]    robot_common_operations.Common Case Setup
    ${release_info}    Get sagnb release title
    Run keyword if    '${release_info}' == '${branch}[0]'
    ...    Common Case TestLine Setup   ModifySCF_Beforecommission=True
    ...    golden_scf_name=${scf_path}${golden_scf_name}_${release_info}.xml   ParamterToModify=${PARAMETERS_TO_MO_GNB1_E12_24R2}
    ...    ListToAdd=${LIST_TO_ADD_GNB1_A_7225}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB1_A_BWP}
    ...    ELSE    Common Case TestLine Setup   ModifySCF_Beforecommission=True
    ...    golden_scf_name=${scf_path}${golden_scf_name}_${release_info}.xml    ParamterToModify=${PARAMETERS_TO_MO_GNB1_E12}
    ...    ListToAdd=${LIST_TO_ADD_GNB1_A_7225}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB1_A_BWP}
    Adjust gNB_RU Attenuation    gnb1_cell3_value=${40}
    MTK prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Start capture gNB log on master    filename=${logname_3drbs}    gNB_index=${0}
    MTK UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    MTK UE Act Additional PDN    ue_index=${ue_index}    pdn=mdrb.nokia.com
    Stop and download the Logs    filename=${logname_3drbs}   gNB_index=${0}
    Check wireshark log for multi-drbs    logname=${logname_3drbs}
    ...    multi_apn=mdrb.nokia.com    drb_length=${2}    multi_drbs=@{2drbs}
    Run keyword If    '${gnb_instance0}'== '${gnb_id}[0]'    Check NBR take effect
    ...    ELSE    Check NBR take effect    PA_min=${75}    PA_max=${85}
    [Teardown]    run keywords
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${2}    AND
    ...    Run Keyword And Ignore Error    Case Teardown



*** Keywords ***
Check NBR take effect
    [Arguments]    ${PA_min}=${60}    ${PA_max}=${70}
    FOR    ${index}    IN RANGE    ${PA_min}    ${PA_max}
        Adjust gNB_RU Attenuation    gnb1_cell3_value=${index}
        Start Traffic And Download the listened traffic file
        ${status_1}    Run keyword and return status    Check beare value should be true
        ...    file_name=${file_name_E12}_${dl_port_5QI8}.txt    value_min=${0}    value_max=${38}
        ${status_2}    Run keyword and return status    Check beare value should be true
        ...    file_name=${file_name_E12}_${dl_port_5QI9}.txt    value_min=${45}    value_max=${55}
        Exit For Loop If    '${status_1}'=='True' and '${status_2}'=='True'
    END
    Should be equal    ${status_1}    ${True}
    Should be equal    ${status_2}    ${True}


Start Traffic And Download the listened traffic file
    ${UE_IP}    Get UE IP from wirehsark    logname=${logname_3drbs}
    @{serial_numbers}    Create List    ${tl.ues[${ue_index}].serial_number}    ${tl.ues[${ue_index}].serial_number}
    @{UE_IPs}    Create List    ${UE_IP}    ${UE_IP}
    Stop All port traffic    port_list=${dl_ports}
    Prepare M60 for DL listening    UE_IP=${UE_IP}
    operate_all_bearer_of_tput_listen_threading_via_cpc    filename=${file_name_E12}    iperf_path=${iperf_path}
    ...    dl_ports=${dl_ports}    serial_numbers=${serial_numbers}   ue_index=${ue_index}
    operate_all_bearer_of_tput_traffic_threading_via_appserver
    ...    ue_ips=${UE_IPS}    dl_ports=${dl_ports}    traffic=${Send_Tput_DL}    ue_index=${ue_index_APPserver}
    Sleep    30s
    FOR    ${port}    IN    @{dl_ports}
        Download DL Traffic File    file_name=${file_name_E12}_${port}.txt    ue_index=${ue_index}
    END
    [Teardown]    Stop All port traffic    port_list=${dl_ports}

Check beare value should be true
    [Arguments]    ${file_name}    ${value_min}    ${value_max}
    ${value_list}    ${average}    check beare value    file_name=${epc_log_path}${file_name}
    ${value_length}    Get Length    ${value_list}
    should be true    ${value_length}>${0}
    FOR    ${index}    IN RANGE    ${5}    ${value_length}
        Should Be True    ${value_min}<=${value_list[${index}]}<=${value_max}
    END
    [Return]    ${average}

Get UE IP from wirehsark
    [Arguments]    ${logname}
    ...    ${message_filter}=ngap.procedureCode == 29 and nas-5gs.sm.5qi == 8
    ...    ${xpath}=.//nas-5gs.sm.pdu_addr_inf_ipv4
    Log    Get UE IP from wirehsark
    ${UE_IP}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    [Return]    ${UE_IP}[-1]

Prepare M60 for DL listening
    [Arguments]    ${UE_IP}    ${ue_index}=${2}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    Sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell ip addr add ${UE_IP}/24 dev wwan1   connection=cygwin
    Sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell ifconfig wwan1 up    connection=cygwin
    Sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell ip route add default dev wwan1   connection=cygwin
    sleep   5s
    [Teardown]    csn.disconnect      connection=cygwin


Stop All port traffic
    [Arguments]    ${port_list}    ${direction}=dl
    ${port_length}    Get Length    ${port_list}
    FOR    ${index}    IN RANGE    ${port_length}
        power_ue.Stop traffic    ue_type=${tl.ues[0].capabilities[0]}    direction=${direction}    ue_index=${ue_index_APPserver}
        ...    iperf_port=${port_list[${index}]}    iperf_type=via_command
    END
