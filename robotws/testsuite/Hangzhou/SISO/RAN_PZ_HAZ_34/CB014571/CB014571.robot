# @Time    : 2023/1/13 17:11
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB014571.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB014571
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py

Suite Setup     SISO Coam Suite Setup
Suite Teardown  SISO Coam Suite Teardown
Test Setup          MMW5 Common Case Setup  allowed_faults_ids=4681
Test Teardown       MMW5 Common Case Teardown
Force Tags      CRT_TRUNK    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot

*** Variables ***
${if_commissioning}    True
${SCF_A120}         ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T2001/SCF_SBTS26R1.xml
${ue_type}          qct_dx50
${ue_index}         0
${duration}         300
${global_cell_id}   2
${TS_CASE_LOG_PATH}    ${OUTPUT_DIR}

*** Test Cases ***
[2.0] Manual_SiSo_SM_BTS_Site_Reset
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    1
    Manual_SiSo_SM_BTS_Site_Reset_1.0    range_time=1

[1.0] General_SiSo_RAT_Reset
    [Documentation]    https://rep-portal.ext.net.nokia.com/details/qc-case/3777531/
    [Tags]    2
    General_SiSo_RAT_Reset_1.0

[1.0] Manual_SiSo_REC_Radio_Module_power_reset
    [Tags]    3
    Manual_SiSo_REC_Radio_Module_power_reset_1.0

[1.0] Manual_SiSo_SM_Cell_Block_Unblock
    [Documentation]    https://rep-portal.ext.net.nokia.com/details/qc-case/3994507/
    [Tags]    4
    Manual_SiSo_SM_Cell_Block_Unblock_1.0

[3.0] General_SiSo_RU_module_reset_from_GUI
    [Documentation]    https://rep-portal.ext.net.nokia.com/details/qc-case/4210216/
    [Tags]    5
    General_SiSo_RU_module_reset_from_GUI_3.0

[2.0] Manual_SiSo_SM_RF_Module_lock_unlock
    [Documentation]    https://rep-portal.ext.net.nokia.com/details/qc-case/3655892/
    [Tags]    6
    Manual_SiSo_SM_RF_Module_lock_unlock_2.0_new

[1.0] General_SiSo_Static_HW_Capabilities_Validation
    [Documentation]    https://rep-portal.ext.net.nokia.com/details/qc-case/3656800/
    [Tags]    7
    General_SiSo_Static_HW_Capabilities_Validation_1.0

CB014571_A_120_Peak DLUL throughput with 256QAM 256QAM Modulation with 60Mhz chbw
    [Documentation]    https://rep-portal.ext.net.nokia.com/details/qc-case/4212364/
    ...    Author: bingxi.x.zheng@nokia-sbell.com
    ...    Create: 2025/11/19
    [Tags]    8

    ${theoretical_dl}    ${theoretical_ul}    Get Theoretical Throughput
    ...    scf_path=${SCF_A120}
    ...    cell_id=2
    ...    ue_ul_layer=${1}

    #*********************
    #       UDP Test     *
    #*********************
    UE Attach And Check Throughput Without Detach    global_cell_id=${global_cell_id}
    ...    ul_tp=70M    ul_tp_threshold=${theoretical_ul}
    ...    dl_tp=960M    dl_tp_threshold=${theoretical_dl}
    ...    duration=600    attach_mode=SA
    UE Stop Traffic And Release UE
    Sleep    20s

    [Teardown]    Run Keywords    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}
    ...    AND    MMW5 Common Case Teardown

CB014571_A_120_Peak DLUL throughput with 256QAM 256QAM Modulation with 60Mhz chbw_TCP
    [Documentation]    https://rep-portal.ext.net.nokia.com/details/qc-case/4212364/
    ...    Author: bingxi.x.zheng@nokia-sbell.com
    ...    Create: 2025/11/19
    [Tags]    9

    ${theoretical_dl}    ${theoretical_ul}    Get Theoretical Throughput
    ...    scf_path=${SCF_A120}
    ...    cell_id=2
    ...    ue_ul_layer=${1}

    #*********************
    #       TCP Test     *
    #*********************
    ${nr_cell_identity}    Get NR Cell Identity Via Index "${global_cell_id}"
    UE Attach With Verify Attach    attach_mode=SA    ue_index=0
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}
    ...    nr_cell_identity=${nr_cell_identity}
    UE Start DL TCP Traffic    parallel=4    mss=1400    app_w=2M    iperf_path=/data/iperf3
    UE Start UL TCP Traffic    parallel=4    ue_w=2M    mss=1400    iperf_path=/data/iperf3
    Sleep    10s
    UE Check UL&DL Throughput    global_cell_id=${global_cell_id}
    ...    ultarget_throughput=${theoretical_ul}
    ...    dltarget_throughput=${theoretical_dl}
    ...    min_percent=0.85

    [Teardown]    Run Keywords    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}
    ...    AND    MMW5 Common Case Teardown

*** Keywords ***
Check RF Transmission
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/01 16:45
    [Arguments]
    ...    ${position}=left
    ...    ${asik_alias}=ASIK Master
    ...    ${core_alias}=core_alia
    ...    ${ru_username}=serviceuser
    ...    ${ru_password}=oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=
    ...    ${target_ru_sn}=EB2209R0665
    ...    ${container_host_ip}=192.168.255.254
    ...    ${container_alias}=container_alia
    ...    ${ru_alias}=ru_alia
    ...    ${connection}=GNB_OAM

    Run Keyword If    '${position}'=='left'    Run Keywords
    ...    Set Test Variable    ${core_name}    fct-0a    AND
    ...    Set Test Variable    ${core_host}    0x1018

    Run Keyword If    '${position}'=='right'    Run Keywords
    ...    Set Test Variable    ${core_name}    fct-4a    AND
    ...    Set Test Variable    ${core_host}    0x2018

    # Step 1: ssh to target core (support primary core and secondary core)
    Connect To BTS Csn Via Lmp
    csn.connect_to    hostname=${core_name}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${core_alias}
    ...               proxy=${asik_alias}
    ${connection_service}    csn.get_connection_by_alias    alias=${core_alias}

    ${channel}    Call Method    ${connection_service}    invoke_shell

    #Step 2345: Get RU Ip from admin cli (update on 2025/05/19 10:51)
    ${ru_ip_addr}    Coam Get RU IP via RMOD object    ru_serial_number=${target_ru_sn}    connection=${connection}

    # Step 6: connect to container
    Call Method    ${channel}    send    lxc-attach -n ${core_host}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}

    # Step 8: enable container ssh
    Call Method    ${channel}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
    ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
    ...                                            Sleep    3 sec    AND
    ...                                            Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    close

    # Step 9: ssh to container
    csn.connect_to    hostname=${container_host_ip}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${container_alias}
    ...               proxy=${core_alias}

    # Step 10: ssh to ru
    csn.connect_to    hostname=${ru_ip_addr}
    ...               username=${ru_username}
    ...               password=${ru_password}
    ...               alias=${ru_alias}
    ...               proxy=${container_alias}

    csn.execute    command=sudo su rfsw    connection=${ru_alias}
    ${ret}    ssh.execute    command=dapd-app -sq    connection=${ru_alias}
    log to console    ${ret}
    # Should Contain    ${ret}    -inf


    Run Keyword And Ignore Error    csn.disconnect    connection=${ru_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${container_alias}

    Run Keyword And Ignore Error    csn.disconnect    connection=${core_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}
