*** Settings ***
Documentation
...    author: Xing Jing
...    contact: jing.1.xing@nokia-sbell.com
...    squad group: SG_03


Force Tags    CA_5G_RRM
...    PY36

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007564/Resources/common_keywords.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007564/Resources/Variables_ming.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup
...                            AND    Common Suite Setup for COAM
...                            AND    Get sagnb version for selenium
...                            AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
...                            AND    capture syslog during commission scf
...                            AND    prepare pa value
...                            AND    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564}
...                                   skip_parameter_relation_errors=False
...                            AND    Huawei UE setup    ue_type=${ue_type}
...                            AND    Wait Until Keyword Succeeds    3x    10s    set apn dxdata2
...                            AND    get_release_check_result

Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
...           AND    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564_recover}    skip_parameter_relation_errors=False
...           AND    Run Keyword If Any Tests Failed    Run Keyword And Ignore Error    Common Suite Teardown for COAM


*** Variables ***
#${tl_scf_file_name_gnb}    Configuration_scf_CB007564_C.xml
${tl_scf_file_name_gnb}    gNB1_Golden_SCF.xml
@{att_ports}    ${att_port_1}    ${att_port_2}    ${att_port_3}    ${att_port_4}    ${att_port_5}    ${att_port_6}    ${att_port_7}
...    ${att_port_8}    ${att_port_9}    ${att_port_10}    ${att_port_11}    ${att_port_12}    ${att_port_13}    ${att_port_14}
...    ${att_port_15}    ${att_port_16}
@{values}    ${120}    ${120}    ${120}    ${120}    ${120}    ${120}    ${0}    ${0}    ${5}    ${5}    ${120}    ${120}
...        ${120}    ${120}    ${120}    ${120}

@{update_ports}    ${att_port_5}    ${att_port_6}
@{update_ports_values}    ${0}    ${0}

@{step_att_ports}    ${att_port_9}    ${att_port_10}
${origin_value}    ${20}
#${target_value}    ${28}
${target_value}    ${40}

${Case_001_Log}    7564_001.pcap
${Case_003_Log}    7564_003.pcap
${Case_005_Log}    7564_005.pcap
${counter_end}    5
${counter_end_1}    10
${4G_check}    True
${case001_expected_value}    1
${case003_expected_value}    1
${case005_expected_value}    1
${BIP_log}    Case001_BIP
${tshark_path}      /usr/bin/tshark
${luashark_path}    /opt/workspace/CRT/Master/luashark/generated_luashark/luashark.lua
${command_template_bip}       {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y  \"uldata_prachreceiveind\" -T pdml

#${ue_type}    samsung
${dxdata2_apn}    95 943
#${dxdata2_apn_348}    150 943
${dxdata2_apn_348}    95 1030
${click_access_point}    380 1060

${enb_instance}     ${tl.enbs[0].instance_id}
@{enb_id}    38321    34821    358    342
@{cell_id_348}    0    1    2    3    4    5    6

${model}                     ${tl.attenuator[0].model}

${dxdata2}    ${tl.ues[0].pdn[0]}
${mdrb_apn_name}    ${tl.ues[0].pdn[1]}
${mdrb1_apn_name}    ${tl.ues[0].pdn[2]}

${X75_dxdata2_location}    959 940
${X75_mdrb_location}    959 1152
${X75_mdrb1_location}    959 1350

${ue_type}                  ${tl.ues[0].capabilities[0]}

@{cell_id}    0    1    2    3    4    5
@{multi_gnb_PA}    ${5}    ${15}    ${40}    ${0}    ${35}    ${127}    ${26}    ${30}    ${25}    ${10}    ${20}    ${40}    ${45}    ${30}
...    ${50}    ${60}
${att_ipaddr}    ${tl.attenuator[0].ip_addr}
${att_api_port}    ${tl.attenuator[0].port}
${att_api_model}    ${tl.attenuator[0].model}
${vendor}                    HBTE
${max_attenuation_value}     ${127}

# TL348
${5Gcell1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5Gcell1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5Gcell1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${5Gcell1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${5Gcell2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5Gcell2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${5Gcell2_ANT3}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${5Gcell2_ANT4}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}
${5Gcell3_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${5Gcell3_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${5Gcell3_ANT3}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}
${5Gcell3_ANT4}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}
${5Gcell4_ANT1}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[0].port_no}
${5Gcell4_ANT2}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[1].port_no}
${5Gcell4_ANT3}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[2].port_no}
${5Gcell4_ANT4}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[3].port_no}
${5Gcell5_ANT1}    ${tl.gnbs[0].dus[0].rus[4].attenuation_ports[0].port_no}
${5Gcell5_ANT2}    ${tl.gnbs[0].dus[0].rus[4].attenuation_ports[1].port_no}
${5Gcell5_ANT3}    ${tl.gnbs[0].dus[0].rus[4].attenuation_ports[2].port_no}
${5Gcell5_ANT4}    ${tl.gnbs[0].dus[0].rus[4].attenuation_ports[3].port_no}
${5Gcell6_ANT1}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${5Gcell6_ANT2}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
${5Gcell6_ANT3}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[2].port_no}
${5Gcell6_ANT4}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[3].port_no}

${4Gcell1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${4Gcell1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${4Gcell1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${4Gcell1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${4Gcell2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${4Gcell2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${4Gcell2_ANT3}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${4Gcell2_ANT4}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}
${4Gcell3_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${4Gcell3_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${4Gcell3_ANT3}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}
${4Gcell3_ANT4}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}
${4Gcell4_ANT1}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[0].port_no}
${4Gcell4_ANT2}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[1].port_no}
${4Gcell4_ANT3}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[2].port_no}
${4Gcell4_ANT4}    ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[3].port_no}

# TL383
${5Gcells1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5Gcells1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5Gcells1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${5Gcells1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${5Gcells2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5Gcells2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${5Gcells2_ANT3}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${5Gcells2_ANT4}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}
${5Gcells3_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${5Gcells3_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${5Gcells3_ANT3}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}
${5Gcells3_ANT4}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}
${5Gcells4_ANT1}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}    #gnb2 cell1
${5Gcells4_ANT2}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}    #gnb2 cell1
${4Gcells1_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${4Gcells1_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${4Gcells1_ANT3}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}
${4Gcells1_ANT4}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}

${sys_logs_path}    /tmp/btslog2/
${UTE_logs_path}    /home/ute/ERR_WRN_logs/
${testline_name}          null
${base_file}    None
@{filter_list}    None

${Test_PC_IP}          ${tl.test_pc.default_ssh_connection_details.addr}
${Test_PC_username}    ${tl.test_pc.default_ssh_connection_details.username}
${Test_PC_password}    ${tl.test_pc.default_ssh_connection_details.password}

${MRBTS_ID}    ${tl.gnbs[0].instance_id}

*** Test Cases ***
#[1]CB007564_5G-C_001_CFRA_for_initial_access_sent_preambles
#    [Documentation]    The User scenario to count the Number of times dedicated preambles are sent to Ue for initial.
#    [Tags]    CRT_TRUNK    CRT_22R2    CB007564    CRT_22R3    CRT_22R4    CRT_23R1
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564_C_001}
#    Start capture gNB log on master    filename=${Case_001_Log}
##    Capture multi-RAT Bip File    log_name=${BIP_log}
##    Attach and check power UE   ue_type=${ue_type}    4G_check=${4G_check}
##    ${bip_log_list}=    Download multi-RAT Bip File    log_name=${BIP_log}
#    Collect Interface Mirroring Bip Collector for 7564001
#     ...    gnb_index=${0}    target_dir=${epc_log_path}    times=1s
#     ${bip_log_list}=    Get Bip Log Via Interface Mirroring Collector To UTE    target_dir=${epc_log_path}
#    Stop and download Logs on gNB on master    filename=${Case_001_Log}
#    Wait until keyword succeeds    6min    20s    Check counter for 001
#    Check the case001 wireshark log    log_name=${Case_001_Log}
#    Check the BIP log    biplog=${bip_log_list[0]}
#    [Teardown]    Run Keywords    robot_common_operations.Common Suite Teardown    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${Case_001_Log}    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564_C_001_recover}    AND
#    ...    run keyword and ignore error    Test recover

[1]CB007564_5G-C_003_CFRA_for_initial_access_success
    [Documentation]    The User scenario to count the number of time a dedicated preamble assigned to Ue by the gNB is used by Ue during
    ...    Mesg1 for Initial Ue access
    [Tags]    CIT_TRUNK    CRT_22R2    CB007564    CRT_22R3    CIT_22R4    CIT_23R1
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291,7107
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    AlarmWatchdog.add_allow_alarms    fault_id=7107
    Get sagnb release
    Check UE device status with adb recover    ue_index=${0}
#    Check UE device status with adb recover    ue_index=${1}
    IF    ${enb_instance} == ${enb_id}[1]    #TL348
        Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564_C_003_348}    skip_parameter_relation_errors=False
    ELSE IF    ${enb_instance} == ${enb_id}[0]    #TL383
        Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564_C_003_348}    skip_parameter_relation_errors=False
    END
    Start capture gNB log on master    filename=${Case_003_Log}
    make WA with Samsung S21
    Attach and check power UE    ue_type=${ue_type}    4G_check=${4G_check}
    sleep    2s
#    Triger the CeLL1 HO to Cell3      ### PA port5,6 =0， PA port 9,10 update 20 to 30 via very step +2 ###
    IF    ${enb_instance} == ${enb_id}[1]    #TL348
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[3]    ip_addr=${att_ipaddr_1}
        Sleep    5s
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[2]
    ELSE IF    ${enb_instance} == ${enb_id}[0]    #TL383
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[3]    ip_addr=${att_ipaddr_1}
        Sleep    5s
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[2]
    END
    sleep    2s
    Stop and download Logs on gNB on master    filename=${Case_003_Log}
    IF    ${enb_instance} == ${enb_id}[1]
        Wait until keyword succeeds    6min    20s    Check counter for 003
    ELSE IF    ${enb_instance} == ${enb_id}[0]
        Wait until keyword succeeds    6min    20s    Check counter for 003
    END
    Check HO process for intragNB    log_name=${Case_003_Log}
    Check the case003 wireshark log    log_name=${Case_003_Log}
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    ...    AND    AlarmWatchdog.remove_allow_alarms    fault_id=7107
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${Case_003_Log}
    ...    AND    recover parameters for C003
    ...    AND    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute
    ...    AND    run keyword and ignore error    Test recover
#    ...    AND    get and analysis syslog

#[1]CB007564_5G-C_005_CBRA_for_initial_access_success
#    [Documentation]    The User scenario count the Number of time RA setup is sucessful and the contention is resolved by UL grant
#    ...    addressed to its CRNTI
#    [Tags]    CRT_TRUNK    CRT_23R1    CB007564    CRT_22R4
#    [Setup]
#    robot_common_operations.Common Case Setup
##    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564_05_1}
#    Start capture gNB log on master   filename=${Case_005_Log}
#    make WA with Samsung S21
#    Attach and check power UE    ue_type=${ue_type}    4G_check=${4G_check}
#    sleep    5s
#    Stop and download Logs on gNB on master    filename=${Case_005_Log}
#    Wait until keyword succeeds    6min    20s    Check counter for 005
#    Check the case005 wireshark log    log_name=${Case_005_Log}
#    [Teardown]    Run Keywords    robot_common_operations.Common Suite Teardown    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${Case_005_Log}    AND
#    ...    run keyword and ignore error    Test recover


*** Keywords ***
capture syslog during commission scf
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
    Prepare the gNB cells onair status    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
#    [Teardown]    Stop capture syslog via btslog on ute

get and analysis syslog
    Check ERR Or WRN From Syslog
    ...    sys_logs_path=${sys_logs_path}      Expected_ERR_WRN_deviation=0.2
    ...    Expected_ERR_WRN_diff_number=0
    ...    UTE_logs_path=${UTE_logs_path}      testline=${testline_name}
    ...    base_file=None     Fail_Case=False       Clear_log=False     remove_ERR_WRN_excel=True
    ...    filter_list=None      ignore_list=None      Delete_old_ERR_WRN=20
    ...    FilesSystem=/dev/vda2      Max_used_space_ratio=0.9      check_diff=True
    ...    timeout=30 minutes      Expected_ERR_WRN_number=0
#    ...    Check_RF_Log=True

Start capture syslog via btslog on ute
    Start BTSlogs Collection In Log Server
    ...    Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...    Test_PC_password=${Test_PC_password}
    ...    btslog_path=/tmp/btslog2    btslog_launcher=/opt/btslog/btslog_launcher
    ...    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=False

Stop capture syslog via btslog on ute
    Stop BTSlogs Collection And Download Logs To Log Server
    ...    UTE_syslogs_path=/home/ute/BTS_logs    btslog_path=/tmp/btslog2
    ...    btslog_launcher=/opt/btslog/btslog_launcher    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=${False}



Switch QCOM APN to muti DRB
    [Arguments]    ${apn_name}    ${ue_index}=${0}    ${ue_type}=${ue_type}
    Get all X70 pointer variable
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    #ui_version=${ui_version}
    UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Switch APN to muti DRB
    [Arguments]    ${apn_name}    ${ui_version}    ${ue_index}=${0}    ${ue_type}=${ue_type}
    Run Keyword And Ignore Error    Attach and check power UE   ue_type=${ue_type}
    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    ui_version=${ui_version}
    run keyword and ignore error    UE.UE Detach    ue_type=${ue_type}

Android UE SwitchApn
    [Documentation]
    ...    Note: Use the keyword must be ensure that UE UI Menu is English language
    ...    str ui_version: mobile ui version.
    ...        e.g Magic UI 3.1.1, have tested on honor CDY-AN90 1080x2400,
    ...            EMUI 10.1.0, have tested on huawei mate30 LIO-AN00 1176x2400.
    ...            Qualcomm qti lahaina for arm64 ue do not have UI, so this field equal to '' or ${None}
    ...           if mobile is mtk peturs, pass 'petrus' as ui_version.
    [Arguments]       ${ue_index}=${0}    ${host}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}     ${ui_version}=${None}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${apn_name}=mdrb    ${ue_alias}=UE_${ue_index}
    android_mobile.setup
    ...               ui_version=${ui_version}    host=${host}    username=${username}
    ...               password=${password}    port=22     serial_number=${serial_number}    alias=${UE_alias}
    run keyword and ignore error    android_mobile.switch_apn       apn_name=${apn_name}   mobile=${UE_alias}
    android_mobile.teardown       mobile=${UE_alias}

Get all X70 pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    953 1385
    Set Suite Variable    ${close_task}    523 272
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    720 312
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${brand}    qti

choice required APN on QCOM UE
    [Arguments]    ${usedapn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Get all X70 pointer variable
    set Qcom apn to wap2    usedapn=${usedapn}    ue_index=${ue_index}
    make airplane mode to enable    ue_index=${ue_index}
    Connect to control pc via cygwin    ue_index=${ue_index}
    #### KEYCODE_APP_SWITCH,recent APP application
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    #### clear all KEYCODE_APP_SWITCH,recent APP application
    FOR  ${i}    IN RANGE    ${9}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
        sleep    1s
    END
    sleep    2s
    FOR  ${i}    IN RANGE    ${2}
        csn.send_command    command=adb -s ${serial_number} shell input tap 241 1076    connection=cygwin
        sleep   1s
    END
    csn.disconnect    connection=cygwin

set Qcom apn to wap2
    [Arguments]    ${usedapn}=${wap2apn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Set Suite Variable    ${apnset1}    ${usedapn}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=cygwin
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    #### KEYCODE_APP_SWITCH,recent APP application
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    #### clear all KEYCODE_APP_SWITCH,recent APP application
    FOR  ${i}    IN RANGE    ${9}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
        sleep    1s
    END
    sleep    2s
    FOR  ${i}    IN RANGE    ${2}
        csn.send_command    command=adb -s ${serial_number} shell input tap 241 1076    connection=cygwin
        sleep   1s
    END
    sleep   2s
    ####1.APN setting
    ####1.1 setting
    csn.send_command    command=adb -s ${serial_number} shell am start com.android.settings/com.android.settings.Settings$ApnSettingsActivity
    ...    connection=cygwin
    ####1.2 Network&internet
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 447 938    connection=cygwin
    sleep   2s
    ####1.3 SIMs
    csn.send_command    command=adb -s ${serial_number} shell input tap 323 1205    connection=cygwin
    sleep   2s
    ####1.4 T-Mobile
    csn.send_command    command=adb -s ${serial_number} shell input tap 337 736    connection=cygwin
    sleep   2s
    ####1.5 swipe Access Point Names
    FOR  ${i}    IN RANGE    ${4}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin
        sleep    1s
    END
    ####1.6 click Access Point Names
    csn.send_command    command=adb -s ${serial_number} shell input tap 486 1604    connection=cygwin
    sleep   2s
    ####1.6 switch Access Point Names
    csn.send_command    command=adb -s ${serial_number} shell input tap ${apnset1}    connection=cygwin
    sleep   2s
    [Teardown]    csn.disconnect    connection=cygwin

set apn dxdata2
    RUN KEYWORD IF    ${enb_instance} != ${enb_id}[2]
    ...    run keywords    Set Suite Variable    ${close_task}    538 1874
    ...    AND    set apn with special method    usedapn=${dxdata2_apn_348}    location_apn=${click_access_point}
    ...    ELSE    set apn to wap2    usedapn=${dxdata2_apn}

Test recover
    run keyword and ignore error    UE.UE Detach    ue_type=${ue_type}
    IF    ${enb_instance} == ${enb_id}[1]    #Tl348
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[5]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[5]    ip_addr=${att_ipaddr_1}
        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[3]    value=${multi_gnb_PA}[5]
    ELSE IF    ${enb_instance} == ${enb_id}[0]    #Tl383
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[5]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[5]    ip_addr=${att_ipaddr_1}
        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[3]    value=${multi_gnb_PA}[5]
    END
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    Common Case Teardown for COAM

Triger the CeLL1 HO to Cell3
    Set the attenuation value    att_ports=${update_ports}    values=${update_ports_values}
    Adjust attenuation value via steps    att_ports=${step_att_ports}    origin_value=${origin_value}
    ...    target_value=${target_value}

Check the case001 wireshark log
    [Arguments]    ${log_name}
     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}
    ${CFRA}=    Catenate    x2ap.procedureCode == 27 and nr-rrc.ra_PreambleIndex == 48
    ${CFRA_packets}=    parser.filter_packets_by_expression    filter_expression=${CFRA}
    ${CFRA_value}=    parser.get_field_value_by_xpath    xpath=.//nr-rrc.ra_PreambleIndex
    should be equal   ${CFRA_value[0]}    48

Check the case003 wireshark log
    [Arguments]    ${log_name}
     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}
    ${CFRA}=    Catenate    x2ap.procedureCode == 27 and nr-rrc.ra_PreambleIndex == 48
    ${CFRA_packets}=    parser.filter_packets_by_expression    filter_expression=${CFRA}
    ${CFRA_value}=    parser.get_field_value_by_xpath    xpath=.//nr-rrc.ra_PreambleIndex
    should be equal    ${CFRA_value[0]}    48

Check HO process for intragNB
    [Arguments]    ${log_name}    ${RadioNetwork}=0
    Get gnb Cells ID
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${measurement_filter}    Catenate      x2ap.procedureCode == 35 and nr-rrc.physCellId == ${cell1_physCellId}
    ...               and nr-rrc.physCellId == ${cell3_physCellId}
    ${measurement_packets}    parser.filter_packets_by_expression    filter_expression=${measurement_filter}
    ${target_cell}=     parser.get_field_value_by_xpath    pdml_list=${measurement_packets}
    ...                                                xpath=.//nr-rrc.physCellId
    should not be empty    ${target_cell}
    ${UeModify_req_filter}    Catenate    x2ap.procedureCode == 30 and  nr-rrc.physCellId == ${cell3_physCellId}
    ${UeModify_req_packets}    parser.filter_packets_by_expression    filter_expression=${UeModify_req_filter}
    ${radioNetworks}=    parser.get_field_value_by_xpath    pdml_list=${UeModify_req_packets}
    ...                                                xpath=.//x2ap.radioNetwork
#    should be equal    ${radioNetworks}    ${RadioNetwork}
    Should Be Equal As Strings    ${radioNetworks}[0]    ${RadioNetwork}
    ${UeModify_res_filter}    Catenate    x2ap.protocolIEs == 3 and x2ap.procedureCode == 30
    ${UeModify_res_packets}    parser.filter_packets_by_expression    filter_expression=${UeModify_res_filter}
    ${UeModify_res}    parser.get_field_value_by_xpath    pdml_list=${UeModify_res_packets}
    ...                                                xpath=.//x2ap.procedureCode
    should be equal    ${UeModify_res[0]}    30

Get gnb Cells ID
#    ${cell1_physCellId}    get physCellId    cellid=${1}    nrbtsid=${tl.gnbs[${gnb_index}].instance_id}    gnb_index=${gnb_index}
#    ${cell3_physCellId}    get physCellId    cellid=${3}    nrbtsid=${tl.gnbs[${gnb_index}].instance_id}    gnb_index=${gnb_index}
    IF    ${enb_instance} == ${enb_id}[1]
        ${cell1_physCellId}    Get physCellId from SCF for 7564
        ...    golden_scf_name=${tl_gnb1_scf_${sw_version}}    cell_index=${400}    scf_path=${tl_scf_dir_path}
        ${cell3_physCellId}    Get physCellId from SCF for 7564
        ...    golden_scf_name=${tl_gnb1_scf_${sw_version}}    cell_index=${700}    scf_path=${tl_scf_dir_path}
    ELSE IF    ${enb_instance} == ${enb_id}[0]
        ${cell1_physCellId}    Get physCellId from SCF for 7564
        ...    golden_scf_name=${tl_gnb1_scf_${sw_version}}    cell_index=${400}    scf_path=${tl_scf_dir_path}
        ${cell3_physCellId}    Get physCellId from SCF for 7564
        ...    golden_scf_name=${tl_gnb1_scf_${sw_version}}    cell_index=${700}    scf_path=${tl_scf_dir_path}
    END
    set suite variable     ${cell1_physCellId}
    set suite variable     ${cell3_physCellId}

get physCellId
    [Arguments]    ${cellid}     ${nrbtsid}=1     ${gnb_index}=${gnb_index}
    ${value}=    Get parameter value    dis_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${nrbtsid}/NRCELL-${cellid}
    ...    filter_name=Physical cell identifier
    [Return]    ${value}

Get parameter value
    [Arguments]    ${dis_name}    ${filter_name}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    ${value}=    selenium_coam.get_parameter_value    dist_name=${dis_name}
    ...    filter_param=${filter_name}
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    [return]    ${value}


Check the case005 wireshark log
    [Arguments]    ${log_name}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}
    ${CFRA}=    Catenate    x2ap.procedureCode == 27 and nr-rrc.ra_PreambleIndex == 48
    ${CFRA_packets}=    parser.filter_packets_by_expression    filter_expression=${CFRA}
    ${CFRA_value}=    parser.get_field_value_by_xpath    xpath=.//nr-rrc.ra_PreambleIndex
    should be empty    ${CFRA_value}


Check counter for 001
    Check gnb counter as expected_value
    ...    counter_id=${DED_PREAMBL_SENT_CFRA_INIT['counter_id']}
    ...    dic_path=${DED_PREAMBL_SENT_CFRA_INIT['dic_path']}
    ...    expected_value=${case001_expected_value}
    ...    gnb_id=${DED_PREAMBL_SENT_CFRA_INIT['gnb_id']}
    ...    counter_end=${counter_end_1}
    Check gnb counter as expected_value
    ...    counter_id=${INIT_MSG2_ACK_CFRA['counter_id']}
    ...    dic_path=${INIT_MSG2_ACK_CFRA['dic_path']}
    ...    expected_value=${case001_expected_value}
    ...    gnb_id=${INIT_MSG2_ACK_CFRA['gnb_id']}
    ...    counter_end=${counter_end_1}
    Check gnb counter as expected_value
    ...    counter_id=${DED_PREAMBL_USED_CFRA_INIT['counter_id']}
    ...    dic_path=${DED_PREAMBL_USED_CFRA_INIT['dic_path']}
    ...    expected_value=${case001_expected_value}
    ...    gnb_id=${DED_PREAMBL_USED_CFRA_INIT['gnb_id']}
    ...    counter_end=${counter_end_1}

Check counter for 003
    run keyword if    '${check_result}' != 'True'    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${DED_PREAMBL_USED_CFRA_MSG1['counter_id']}
    ...    dic_path=${DED_PREAMBL_USED_CFRA_MSG1['dic_path']}
    ...    expected_value=${case003_expected_value}
    ...    gnb_id=${DED_PREAMBL_USED_CFRA_MSG1['gnb_id']}
    ...    counter_end=${counter_end}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${MSG2_ACK_CFRA['counter_id']}
    ...    dic_path=${MSG2_ACK_CFRA['dic_path']}
    ...    expected_value=${case003_expected_value}
    ...    gnb_id=${MSG2_ACK_CFRA['gnb_id']}
    ...    counter_end=${counter_end}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${DED_PREAMBL_SENT_CFRA['counter_id']}
    ...    dic_path=${DED_PREAMBL_SENT_CFRA['dic_path']}
    ...    expected_value=${case003_expected_value}
    ...    gnb_id=${DED_PREAMBL_SENT_CFRA['gnb_id']}
    ...    counter_end=${counter_end}
    ...    ELSE    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${DED_PREAMBL_USED_CFRA_MSG1_trunk['counter_id']}
    ...    dic_path=${DED_PREAMBL_USED_CFRA_MSG1_trunk['dic_path']}
    ...    expected_value=${case003_expected_value}
    ...    gnb_id=${DED_PREAMBL_USED_CFRA_MSG1_trunk['gnb_id']}
    ...    counter_end=${counter_end}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${MSG2_ACK_CFRA_trunk['counter_id']}
    ...    dic_path=${MSG2_ACK_CFRA_trunk['dic_path']}
    ...    expected_value=${case003_expected_value}
    ...    gnb_id=${MSG2_ACK_CFRA_trunk['gnb_id']}
    ...    counter_end=${counter_end}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${DED_PREAMBL_SENT_CFRA_trunk['counter_id']}
    ...    dic_path=${DED_PREAMBL_SENT_CFRA_trunk['dic_path']}
    ...    expected_value=${case003_expected_value}
    ...    gnb_id=${DED_PREAMBL_SENT_CFRA_trunk['gnb_id']}
    ...    counter_end=${counter_end}

Check counter for 003 383
    run keyword if    '${check_result}' != 'True'    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${DED_PREAMBL_USED_CFRA_MSG1_383['counter_id']}
    ...    dic_path=${DED_PREAMBL_USED_CFRA_MSG1_383['dic_path']}
    ...    expected_value=${case003_expected_value}
    ...    gnb_id=${DED_PREAMBL_USED_CFRA_MSG1_383['gnb_id']}
    ...    counter_end=${counter_end}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${MSG2_ACK_CFRA_383['counter_id']}
    ...    dic_path=${MSG2_ACK_CFRA_383['dic_path']}
    ...    expected_value=${case003_expected_value}
    ...    gnb_id=${MSG2_ACK_CFRA_383['gnb_id']}
    ...    counter_end=${counter_end}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${DED_PREAMBL_SENT_CFRA_383['counter_id']}
    ...    dic_path=${DED_PREAMBL_SENT_CFRA_383['dic_path']}
    ...    expected_value=${case003_expected_value}
    ...    gnb_id=${DED_PREAMBL_SENT_CFRA_383['gnb_id']}
    ...    counter_end=${counter_end}
    ...    ELSE    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${DED_PREAMBL_USED_CFRA_MSG1_trunk_383['counter_id']}
    ...    dic_path=${DED_PREAMBL_USED_CFRA_MSG1_trunk_383['dic_path']}
    ...    expected_value=${case003_expected_value}
    ...    gnb_id=${DED_PREAMBL_USED_CFRA_MSG1_trunk_383['gnb_id']}
    ...    counter_end=${counter_end}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${MSG2_ACK_CFRA_trunk_383['counter_id']}
    ...    dic_path=${MSG2_ACK_CFRA_trunk_383['dic_path']}
    ...    expected_value=${case003_expected_value}
    ...    gnb_id=${MSG2_ACK_CFRA_trunk_383['gnb_id']}
    ...    counter_end=${counter_end}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${DED_PREAMBL_SENT_CFRA_trunk_383['counter_id']}
    ...    dic_path=${DED_PREAMBL_SENT_CFRA_trunk_383['dic_path']}
    ...    expected_value=${case003_expected_value}
    ...    gnb_id=${DED_PREAMBL_SENT_CFRA_trunk_383['gnb_id']}
    ...    counter_end=${counter_end}

Check counter for 005
    Check gnb counter as expected_value
    ...    counter_id=${RA_CB_INIT_RESOLVED['counter_id']}
    ...    dic_path=${RA_CB_INIT_RESOLVED['dic_path']}
    ...    expected_value=${case005_expected_value}
    ...    gnb_id=${RA_CB_INIT_RESOLVED['gnb_id']}
    ...    counter_end=${counter_end}
    Check gnb counter as expected_value
    ...    counter_id=${RA_MSG3_RECEP_INIT['counter_id']}
    ...    dic_path=${RA_MSG3_RECEP_INIT['dic_path']}
    ...    expected_value=${case005_expected_value}
    ...    gnb_id=${RA_MSG3_RECEP_INIT['gnb_id']}
    ...    counter_end=${counter_end}

Check the BIP log
#    [Arguments]    ${biplog}
#    ${all_packets}=    parser.load_pcap_file    pcap_file=${biplog}    alias=test   #tshark_path=${tshark_path}
#    ...    #luashark_path=${luashark_path}   command_template=${command_template_bip}    alias=test
#    ${filter_expression}=    Catenate
#    ...    uldata_prachreceiveind
#    ${filtered_packets}=    parser.filter_packets_by_expression
#    ...    filter_expression=${filter_expression}    pcap_parser=test
#    ${PreambleIndex}=    parser.get_field_value_by_xpath    #pdml_list=${filtered_packets}
#    ...    xpath=.//uldata_prachreceiveind
#	...    pcap_parser=test
#    should not be empty    ${PreambleIndex}
    [Arguments]    ${biplog}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${biplog}    alias=test
    ${filter_expression}=    Catenate    uldata_prachreceiveind and UlData_detectedPrachPreambles_t.prachPreambleIndex==48
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test
    ${PreambleIndex}=    cap.Get Field Value By Xpath    xpath=.//UlData_detectedPrachPreambles_t.prachPreambleIndex    pcap_parser=test
    Should Be Equal    ${PreambleIndex[0]}    48

Collect Interface Mirroring Bip Collector for 7564001
    [Documentation]
    ...                :param target_file_name: (str) – name of collector
    ...                :param interface: (str) – L1-L2 or L2Hi-L2Lo
    ...                :param destination : (str) – Local or Remote
    ...                :param webservice: (dict) – Configuration of collector/host: base url IP/user: username, defaults to “Nemuadmin”
    ...                                            password: password, defaults to “nemuuser”/port: port, default 443
    ...                :param nr_phy_cell_ids: str) (nr_phy_cell_ids Union(list,) – (Optional) list of physical cell ids.
    ...                          If given ensure cell is on air before running the setup. If not given it will check nr_cell_dns
    ...                          like: 50,51, (Select max 8 cells), if nr_phy_cell_ids set as "None", means collect the logs of all cells.
    [Arguments]    ${target_dir}    ${target_file_name}=l1l2bip_log
    ...            ${nr_phy_cell_ids}=None
    ...            ${gnb_index}=0
    ...            ${timeout}=600
    ...            ${interface}=L1-L2
    ...            ${destination}=Local
    ...            ${host_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...            ${times}=1s
    ${webservice}=  Create Dictionary    host=${host_ip}
    ...                                  user=${username}
    ...                                  password=${password}
    ...                                  port=443
    l1l2bip.create_interface_mirroring_l1l2bip_collector    name=${target_file_name}
    ...                                                     webservice=${webservice}
    ...                                                     interface=${interface}
    ...                                                     destination=${destination}
    ...                                                     nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                                     target_file_name=${target_file_name}
    ...                                                     timeout=${timeout}
    core.setup_collectors    names=${target_file_name}
    core.start_collectors    names=${target_file_name}
    make WA with Samsung S21
    Step1: UE attach   ue_type=${ue_type}    4G_check=${4G_check}
    sleep    ${times}
    core.stop_collectors        names=${target_file_name}
    core.collect_collectors   names=${target_file_name}    target_dir=${target_dir}
    core.teardown_collectors    names=${target_file_name}
    l1l2bip.set_suite_alias    ${target_file_name}

PA one cell 0 on and set other cell value
    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_cell}=${4}
    Change Attenuation value    cell=5Gcell${cellid}    value=${set_value}
    FOR  ${index}  IN RANGE   ${total_cell}
        ${cellnum} =    evaluate    ${index}+1
        run keyword if    '${cellid}'!='${cellnum}'    Change Attenuation value    cell=5Gcell${cellnum}    value=${127}
    END
    Change Attenuation value    cell=4Gcell1    value=${127}

PA one cell 0 on and set other cell value 4 port
    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_cell}=${4}
    IF    ${cellid} == 4
        Change Attenuation value    cell=5Gcells${cellid}    value=${set_value}
    ELSE
        Change Attenuation value 4 port    cell=5Gcells${cellid}    value=${set_value}
    END
    FOR  ${index}    IN RANGE    ${total_cell}
        ${cellnum} =    evaluate    ${index}+1
        IF    '${cellid}'!='${cellnum}'
            IF    ${cellnum} == 4
                Change Attenuation value    cell=5Gcells${cellnum}    value=${127}
            ELSE
                Change Attenuation value 4 port    cell=5Gcells${cellnum}    value=${127}
            END
        END
    END
    Change Attenuation value 4 port    cell=4Gcells1    value=${127}

Change Attenuation value
    [Arguments]    ${cell}    ${value}
    Set the Attenuation Value    ports=${${cell}_ANT1}    value=${value}
    Set the Attenuation Value    ports=${${cell}_ANT2}    value=${value}
    Run Keyword If    '${cell}' == '5Gcell3'    Run Keywords
    ...    Set the Attenuation Value    ports=${${cell}_ANT3}    value=${value}
    ...    AND    Set the Attenuation Value    ports=${${cell}_ANT4}    value=${value}

Change Attenuation value 4 port
    [Arguments]    ${cell}    ${value}
    Set the Attenuation Value    ports=${${cell}_ANT1}    value=${value}
    Set the Attenuation Value    ports=${${cell}_ANT2}    value=${value}
    Set the Attenuation Value    ports=${${cell}_ANT3}    value=${value}
    Set the Attenuation Value    ports=${${cell}_ANT4}    value=${value}

Set the Attenuation Value
    [Arguments]    ${ports}    ${value}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${ports}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${att_api_model}
    att.set_attenuation     port=${ports}    value=${value}

Change Attenuation value per step
    [Arguments]    &{kwargs}
    ${ports}=    Get Dictionary Keys    ${kwargs}
    ${values}=    Get Dictionary Values    ${kwargs}
    Set the attenuation value per step    ports=${ports}    values=${values}

Set the attenuation value per step
    [Arguments]    ${ports}    ${values}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${ports}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${att_api_model}
    att.set_ports_attenuation     ports=${ports}    values=${values}

prepare pa value
    IF    ${enb_instance} == ${enb_id}[1]    #Tl348
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[3]
        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[3]    value=${multi_gnb_PA}[3]
    ELSE IF    ${enb_instance} == ${enb_id}[0]    #TL383
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[3]
        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[3]    value=${multi_gnb_PA}[3]
    END

PA one cell 0 on and set other cell value 4 port for T348
    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_cell}=${6}
    IF    '${cellid}' == '5' or '${cellid}' == '6'
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellid}    value=${set_value}    ip_addr=${att_ipaddr_1}
    ELSE
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellid}    value=${set_value}    ip_addr=${att_ipaddr}
    END
    FOR  ${index}  IN RANGE   ${total_cell}
        ${cellnum} =    evaluate    ${index}+1
        IF    ('${cellid}' != '${cellnum}') and ('${cellnum}' == '5' or '${cellnum}' == '6')
            Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellnum}    value=${127}    ip_addr=${att_ipaddr_1}
        ELSE IF    ('${cellid}' != '${cellnum}') and ('${cellnum}' != '5' or '${cellnum}' != '6')
            Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellnum}    value=${127}    ip_addr=${att_ipaddr}
        END
    END

Change Attenuation value 4 port for multi PAs
    [Arguments]    ${cell}    ${value}    ${ip_addr}=${att_ipaddr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT1}    value=${value}    ip_addr=${ip_addr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT2}    value=${value}    ip_addr=${ip_addr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT3}    value=${value}    ip_addr=${ip_addr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT4}    value=${value}    ip_addr=${ip_addr}

Set Programmable Attenuation Value for multi PAs
    [Arguments]    ${ports}    ${value}    ${ip_addr}=${att_ipaddr}
    att.setup_attenuator    ip_addr=${ip_addr}    port=${att_api_port}
    ...    attenuation_port_numbers=${ports}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    att.set_attenuation     port=${ports}    value=${value}

recover parameters for C003
    IF    ${enb_instance} == ${enb_id}[1]    #TL348
        Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564_C_003_recover_348}    skip_parameter_relation_errors=False
    ELSE IF    ${enb_instance} == ${enb_id}[0]    #TL383
        Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564_C_003_recover_348}    skip_parameter_relation_errors=False
    END

Get physCellId from SCF for 7564
    [Arguments]       ${golden_scf_name}    ${gnb_index}=${0}    ${cell_index}=${1}    ${scf_path}=${tl_scf_dir_path}
    scf.Load scf    ${scf_path}/${golden_scf_name}
    ${physcellid}=    scf.get_value_from_scf
    ...    dist_name=MRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRCELL-${cell_index}
    ...    p_name=physCellId
    [Return]     ${physcellid}
