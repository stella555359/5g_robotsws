*** Settings ***
Force Tags    PY36
Documentation     author: Wu Xu
...                 contact: xu.wu@nokia-sbell.com
...                 squad group: SG_03
...                 feature : 5GC002056_AGAT

Resource    ./../5GC000710/Resources/5GC000710_common_keyword.robot
Variables    ./Resources/786_Case_Commission_Classical/__init__.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002056_AGAT/Resources/5GC002056_AGAT_variables.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup
...            AND    Get release info
...            AND    Get sagnb version for selenium
...            AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
...            AND    Set Suite Variable    ${tl_gnb2_scf_${sw_version}}    ${sw_version}_gNB2_Golden_SCF.xml
...            AND    Precondition for cell on air    gnb_index=${0}    tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
...            AND    Precondition for cell on air    gnb_index=${1}    tl_scf_file_name=${tl_gnb2_scf_${sw_version}}

Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
...               AND    Run Keyword If Any Tests Failed    Run Keyword And Ignore Error
...               Common Suite Teardown for COAM    gnb_index=${0}

*** Variables ***
${epc_log_path}    /opt/workspace/CIT/Master/Case_Logs/
${SCF_path}    /opt/workspace/CRT/Master/SCF_file/
#${SCF_file_name}    2056_786_D_03_gNB1.xml
${SCF_file_name}    gNB1_Golden_SCF.xml
#${SCF_file_name_2}       2056_786_D_03_gNB2.xml
${SCF_file_name_2}       gNB2_Golden_SCF.xml
${interface}    any
#@{diffTL_enb}       3412    5294    911    5395
${enb_instance}    ${tl.enbs[0].instance_id}

${gNB1_nglogname2}    gNB1_786D03.pcap
${gNB2_nglogname2}    gNB2_786D03.pcap
${target_phone_number}    18001006429
${target_phone_number_1}    17001006254
${xnLinkStatus_dist_name_1}    ${distname_id_1}/XNLINK-1
##filter command for converting PDML
${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"ngap or xnap\"  -T pdml

${dxdata2_apn}    95 943
#${dxdata2_apn_348}    150 943
${dxdata2_apn_348}    95 1030
${click_access_point}    380 1060
@{enb_id}    34821    38321    358

${model}                     ${tl.attenuator[0].model}


${dxdata2}    ${tl.ues[0].pdn[0]}
${mdrb_apn_name}    ${tl.ues[0].pdn[1]}
${mdrb1_apn_name}    ${tl.ues[0].pdn[2]}

${X75_dxdata2_location}    959 940
${X75_mdrb_location}    959 1152
${X75_mdrb1_location}    959 1350

@{cell_id}    0    1    2    3    4    5
@{cell_id_348}    0    1    2    3    4    5    6
@{multi_gnb_PA}    ${5}    ${15}    ${40}    ${0}    ${35}    ${127}    ${26}    ${30}    ${25}    ${10}    ${20}    ${40}    ${45}    ${30}
...    ${50}
${att_ipaddr}    ${tl.attenuator[0].ip_addr}
${att_ipaddr_1}    ${tl.attenuator[1].ip_addr}
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

*** Test Cases ***
[1]5GC002056-AGAT_5GC000786-D_003_Unsuccessful_TDD_IntraFreq_IntergNB_handover_with_5QI1_5QI5_UE_context_setup_failure_by_target_cell_disable_actVoNR
    [Documentation]    Thisuser scenario describes the gNB behaviour, when a UE for which A3/A5 measurements
    ...    have been configured sends a A3/A5 measurement report and gNB performs handover based on the measurement
    ...    report to a cell in a different gNB-DU.
    [Tags]    CRT_22R2    CRT_TRUNK    5GC002056_AGAT    CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    Check UE device status with adb recover    ue_index=${0}
#    Check UE device status with adb recover    ue_index=${1}
    Online delete parmeters    parameters_to_update=${PARAM_DELETE_2056_AGAT_786_D_03}    gnb_index=${1}
    Online modify parmeters    parameters_to_update=${PARAM_2056_AGAT_786_D_03}    gnb_index=${1}
#    Comment    GNB1 CELL1 PA port set 3
#    prepare UE AND PA    value1=${3}    value2=${127}    value3=${127}    value4=${127}    value5=${127}
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Online modify parmeters    parameters_to_update=${PARAM_2056_AGAT_786_D_03_WA_348}
        ###set gnb1 cell1 PA to 5
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        Online modify parmeters    parameters_to_update=${PARAM_2056_AGAT_786_D_03_WA}
        PA one cell 0 on and set other cell value 4 port    cellid=${cell_id}[1]    set_value=${multi_gnb_PA}[0]
    END
    Run Keyword If    '${ue_type}' != 'qct_dx50'    Precondition for power UE    ue_type=${ue_type}
    Wait Until Keyword Succeeds    3x    10s
    ...    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'   Run Keywords
    ...    set apn dxdata2
    ...    AND    make WA with Samsung S21
    ...    ELSE IF    '${ue_type}' == 'qct_dx50'
    ...    choice required APN on QCOM UE    usedapn=${X75_dxdata2_location}   ue_index=${0}
#    ...    Switch QCOM APN to muti DRB    ue_index=${0}    ue_type=${ue_type}    apn_name=${dxdata2}
    Run Keyword If    '${ue_type}' == 'qct_dx50'    Precondition for power UE    ue_type=${ue_type}
    UE.Attach and check power UE    ue_type=${ue_type}
    Start Capture Wireshark Logs on gNB    nglogname=${gNB1_nglogname2}    interface=${interface}
    Start Capture Wireshark Logs on gNB    nglogname=${gNB2_nglogname2}    interface=${interface}    gnb_index=${1}
    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'    Make a call on UE(dial +6688 on UE)
    ...    ELSE IF    '${ue_type}' == 'qct_dx50'    Make a VoNR call(+6688) on SDX70
    sleep    20s    reason=check voice call if is still Continuous after 20s
    check voice call status    status=${2}
#    RUN KEYWORD IF    ${enb_instance} == @{enb_id}[0]     #TL348
#    ...    Run Keywords    Comment    GNB1 CELL1 PA port set 10, GNB2 CELL1 PA port set 2
#    ...    AND    Precondition for attn    value1=${10}    value2=${127}    value3=${127}    value4=${2}    value5=${127}
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[1]     #TL383
#    ...    Run Keywords    Comment    GNB1 CELL1 PA port set 25, GNB2 CELL1 PA port set 10
#    ...    AND    Precondition for attn    value1=${25}    value2=${127}    value3=${127}    value4=${10}    value5=${127}
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[2]     #TL358
#    ...    Run Keywords    Comment    GNB1 CELL1 PA port set 30, GNB2 CELL1 PA port set 20
#    ...    AND    Precondition for attn    value1=${30}    value2=${127}    value3=${127}    value4=${20}    value5=${127}
    Start capture syslog via btslog on ute
    IF    ${enb_instance} == ${enb_id}[1]    #TL383
        ###set gnb2 cell1 PA
        Change Attenuation value    cell=5Gcells${cell_id}[4]    value=${multi_gnb_PA}[3]    #TL383 set to 0
        Sleep    5s    Reason=Wait for PA to take effect
        ###set gnb1 cell1 PA
        Change Attenuation value 4 port    cell=5Gcells${cell_id}[1]    value=${multi_gnb_PA}[11]    #TL383 set to 40
    ELSE IF    ${enb_instance} == ${enb_id}[0]    #TL348
        ###set gnb2 cell1 PA     #TL348 set to 10
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[6]    value=${multi_gnb_PA}[3]    ip_addr=${att_ipaddr_1}
        Sleep    5s    Reason=Wait for PA to take effect
        ###set gnb1 cell1 PA
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[4]    #TL348 set to 10
    END
    sleep    10s    reason=PA may have some delay
    Stop Capture Wireshark Logs on gNB    nglogname=${gNB1_nglogname2}
    Stop Capture Wireshark Logs on gNB    nglogname=${gNB2_nglogname2}    gnb_index=${1}
    Stop capture syslog via btslog on ute
    Check intergNB HO failed    logname=${gNB1_nglogname2}
    [Teardown]    run keywords    End a call on UE
    ...           AND    check voice call status    status=${0}
    ...           AND    recover gnb para
    ...           AND    Online modify parmeters    parameters_to_update=${PARAM_2056_AGAT_786_D_03_recover}    gnb_index=${1}
    ...           AND    Online add parmeters    parameters_to_update=${PARAM_ADD_2056_AGAT_786_D_03_recover}    gnb_index=${1}
    ...           AND    robot_common_operations.Common Case Teardown
    ...           AND    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    ...           AND    Run Keyword And Ignore Error    Tear down wireshark log and detach
    ...           AND    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute
    ...           AND    get and analysis syslog

*** Keywords ***
get and analysis syslog
    Check ERR Or WRN From Syslog
    ...    sys_logs_path=${sys_logs_path}      Expected_ERR_WRN_deviation=0.2
    ...    Expected_ERR_WRN_diff_number=0
    ...    UTE_logs_path=${UTE_logs_path}      testline=${testline_name}
    ...    base_file=None     Fail_Case=False       Clear_log=False     remove_ERR_WRN_excel=True
    ...    filter_list=None      ignore_list=None      Delete_old_ERR_WRN=20
    ...    FilesSystem=/dev/vda2      Max_used_space_ratio=0.9      check_diff=True
    ...    timeout=30 minutes      Expected_ERR_WRN_number=0

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

make WA with Samsung S21
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   4s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin
    sleep    2s
    [Teardown]    csn.disconnect    connection=cygwin

prepare UE AND PA
    [Arguments]    ${value1}    ${value2}    ${value3}    ${value4}    ${value5}
   Precondition for attn    value1=${value1}    value2=${value2}    value3=${value3}    value4=${value4}    value5=${value5}

Precondition for attn
    [Arguments]    ${value1}    ${value2}    ${value3}    ${value4}    ${value5}
    Run Keyword if    '${release}' == 'SBTS22R1_ENB_0000'    Precondition for attn Trunk    value1=${value1}    value2=${value2}
    ...    value3=${value3}    value4=${value4}    value5=${value5}
    ...    ELSE    Precondition for attn Trunk    value1=${value1}    value2=${value2}    value3=${value3}
    ...    value4=${value4}    value5=${value5}

Precondition for attn Trunk
    [Arguments]    ${value1}    ${value2}    ${value3}    ${value4}    ${value5}=${127}
    adjust the HBTE attenuation value    value=${value1}    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
    adjust the HBTE attenuation value    value=${value2}    att_port_1=${att_port_3}    att_port_2=${att_port_4}    atten_ip=${atten_ip}
    adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_5}    att_port_2=${att_port_6}    atten_ip=${atten_ip}
    adjust the HBTE attenuation value    value=${value5}    att_port_1=${att_port_7}    att_port_2=${att_port_8}    atten_ip=${atten_ip}
    adjust the HBTE attenuation value    value=${value4}    att_port_1=${att_port_9}    att_port_2=${att_port_10}    atten_ip=${atten_ip}

Adjust the Attenuation Value local
    [Arguments]      ${ports}    ${value}    ${atten_ip}=${tl.attenuator[0].ip_addr}
    @{att_connection_port}   Create list    ${ports}
    att.setup_attenuator    ip_addr=${atten_ip}   port=${att_api_port_topyoung}
    ...    attenuation_port_numbers=${att_connection_port}      max_attenuation=${max_attenuation_value_topyoung}
    ...    vendor=${vendor_topyoung}
    ...    model=${model}
    att.set_attenuation     port=${ports}    value=${value}
    ${value_port}    att.read_attenuation    port=${ports}
    should be equal    ${value_port}    ${value}

adjust the HBTE attenuation value
    [Arguments]     ${value}    ${att_port_1}=${att_port_1}    ${att_port_2}=${att_port_2}    ${atten_ip}=${atten_ip}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA value default value[0-63db] if not set the max_attenuation value below
    ...                for value plz set in your case level
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    attenuator.set_attenuation     port=${att_port_1}    value=${value}
    attenuator.set_attenuation     port=${att_port_2}    value=${value}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value}
    ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_2}    ${value}
    sleep    5s


Adjust gNB1_TDD_Cell1 HBTE to 0 for TL242
    [Arguments]    ${value}=${5}
    ${atten_ip} =    set variable     ${tl.attenuator[1].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att2_port_5}      att_port_2=${att2_port_6}
    ...     att_port_3=${att2_port_5}     att_port_4=${att2_port_6}    atten_ip=${atten_ip}
    ...        value_1=${value}    value_2=${120}   value_3=${value}    value_4=${120}

Adjust gNB2_FDD_Cells HBTE Attenuation to 120 for TL242
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att1_port_5}      att_port_2=${att1_port_6}
    ...     att_port_3=${att1_port_7}     att_port_4=${att1_port_8}    atten_ip=${atten_ip}
    ...        value_1=${120}    value_2=${120}   value_3=${120}    value_4=${120}

Adjust LTE_Cells HBTE Attenuation to 120 for TL242
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att1_port_13}      att_port_2=${att1_port_14}
    ...     att_port_3=${att1_port_13}     att_port_4=${att1_port_14}    atten_ip=${atten_ip}
    ...        value_1=${120}    value_2=${120}   value_3=${120}    value_4=${120}

Adjust gNB2_FDD_Cells HBTE Attenuation to 0 for TL242
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att1_port_5}      att_port_2=${att1_port_6}
    ...     att_port_3=${att1_port_7}     att_port_4=${att1_port_8}    atten_ip=${atten_ip}
    ...        value_1=${0}    value_2=${0}   value_3=${120}    value_4=${120}

Adjust gNB1_TDD_Cell1 HBTE to Bad for TL242
    [Arguments]    ${value}=${10}
    ${atten_ip} =    set variable     ${tl.attenuator[1].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att2_port_5}      att_port_2=${att2_port_6}
    ...     att_port_3=${att2_port_5}     att_port_4=${att2_port_6}    atten_ip=${atten_ip}
    ...        value_1=${value}    value_2=${120}   value_3=${value}    value_4=${120}
Test recover
    run keyword and ignore error    End a call on UE
    run keyword and ignore error    End a call on UE    ue_index=${1}    serial_number=${tl.ues[1].serial_number}
    run keyword and ignore error    TL UE detach
    run keyword and ignore error    TL UE detach    ue_index=${1}
    run keyword and ignore error    Adjust RU0 Attenuation to 0

Adjust ${RU} Attenuation to ${value}
    Adjust the Attenuation Value local     ports=${5G${RU}_ANT1}    value=${value}
    Adjust the Attenuation Value local    ports=${5G${RU}_ANT2}    value=${value}

Adjust the Attenuations Value
    [Arguments]     ${value}    ${ports}
    @{attenuation_port_numbers}    create list    ${ports}
    att.setup_attenuator    ip_addr=${atten_ip}    port=3000    vendor=TopYoung
    ...    attenuation_port_numbers=@{attenuation_port_numbers}    max_attenuation=${max_attenuation_value}
    ...    model=${model}
    att.set_attenuation     port=${ports}    value=${value}
    ${value_port}    att.read_attenuation    port=${ports}
    should be equal    ${value_port}    ${value}
    sleep    5s

Prepare for case 786_d_003
    run keyword and ignore error    lock gnb1 cell1
    Run Keyword And Ignore Error    unlock gnb1 cell2
    Modify parameters online for cases    parameters_to_update=${PARAMS_TO_MODIFY_786_D03}    WEBUI_COAM=${WEBUI2_COAM}

Modify the COAM parameter with admin API
    [Arguments]    ${parameters}    ${gnb_index}=1
    Cloud DU connect to gnb coam via ssl    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    COAM Teardown gnb connections

Check intergNB HO process on source gNB
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${5QI_1_filter}=     Catenate    ngap.procedureCode == 26 and ngap.fiveQI == 1
    ${5QI_1_packets}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${5QI_1_filter}
    ${PDU_session}=     get_field_value_by_xpath    pdml_list=${5QI_1_packets}
    ...                                                xpath=.//ngap.fiveQI
    should contain    ${PDU_session}    1
    ${5QI_2_filter}=     Catenate    ngap.procedureCode == 26 and ngap.fiveQI == 2
    ${5QI_2_packets}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${5QI_1_filter}
    ${PDU_session}=     get_field_value_by_xpath    pdml_list=${5QI_1_packets}
    ...                                                xpath=.//ngap.fiveQI
    should contain    ${PDU_session}    2
    ${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik2_addr}
    ${HO_req_packets}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${HO_req_filter}
    ${HO_req}=     get_field_value_by_xpath    pdml_list=${HO_req_packets}
    ...                                                xpath=.//xnap.procedureCode
    should contain    ${HO_req}    0
    ${HO_res_filter}=     Catenate    xnap.procedureCode == 0 and ip.dst == ${asik_addr}
    ${HO_res_packets}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${HO_res_filter}
    ${HO_res}=     get_field_value_by_xpath    pdml_list=${HO_res_packets}
    ...                                                xpath=.//xnap.procedureCode
    should contain    ${HO_res}    0
    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
    ${UE_rel_packets}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${UE_rel_filter}
    ${UE_rel}=     get_field_value_by_xpath    pdml_list=${UE_rel_packets}
    ...                                                xpath=.//xnap.procedureCode
    should contain    ${UE_rel}    6

Check intergNB HO process on target gNB
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik_addr}
    ${HO_req_packets}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${HO_req_filter}
    ${HO_req}=     get_field_value_by_xpath    pdml_list=${HO_req_packets}
    ...                                                xpath=.//xnap.procedureCode
    should contain    ${HO_req}    0
    ${HO_res_filter}=     Catenate    xnap.procedureCode == 0 and ip.dst == ${asik_addr}
    ${HO_res_packets}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${HO_res_filter}
    ${HO_res}=     get_field_value_by_xpath    pdml_list=${HO_res_packets}
    ...                                                xpath=.//xnap.procedureCode
    should contain    ${HO_res}    0
    ${PathS_req_filter}=     Catenate    ngap.procedureCode == 25 and ip.src == ${asik2_addr}
    ${PathS_req_packets}=    filter_packets_by_expression    pdml_list=${all_packets}
    ...    filter_expression=${PathS_req_filter}
    ${PathS_req}=     get_field_value_by_xpath    pdml_list=${PathS_req_packets}
    ...                                                xpath=.//ngap.procedureCode
    should contain    ${PathS_req}    25
    ${PathS_ACK_filter}=     Catenate    ngap.procedureCode == 25 and ip.dst == ${asik2_addr}
    ${PathS_ACK_packets}=    filter_packets_by_expression    pdml_list=${all_packets}
    ...    filter_expression=${PathS_ACK_filter}
    ${PathS_ACK}=     get_field_value_by_xpath    pdml_list=${PathS_ACK_packets}
    ...                                                xpath=.//ngap.procedureCode
    should contain    ${PathS_ACK}    25
    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
    ${UE_rel_packets}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${UE_rel_filter}
    ${UE_rel}=     get_field_value_by_xpath    pdml_list=${UE_rel_packets}
    ...                                                xpath=.//xnap.procedureCode
    should contain    ${UE_rel}    6

Check intergNB HO failed
    [Arguments]    ${logname}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}
    ${5QI_1_filter}=     Catenate    ngap.procedureCode == 26 and ngap.fiveQI == 1
    ${5QI_1_packets}=    parser.filter_packets_by_expression    filter_expression=${5QI_1_filter}
    ${PDU_session}=     parser.get_field_value_by_xpath    pdml_list=${5QI_1_packets}
    ...                                                xpath=.//ngap.fiveQI
    should contain    ${PDU_session}    1
    ${HO_filter}=     Catenate    xnap.procedureCode == 0 and xnap.radioNetwork == 21
    ${HO_packets}=    parser.filter_packets_by_expression    filter_expression=${HO_filter}
    ${HO_failed}=     parser.get_field_value_by_xpath    pdml_list=${HO_packets}
    ...                                                xpath=.//xnap.radioNetwork
    should contain    ${HO_failed}    21

Make the VoNR and ViNR call
    ${release_info}    Get gnb release
    Run Keyword If    '${release_info}' == '0000_000800'    Make a VoNR and ViNR call together    phone_number=${target_phone_number_1}
    Run Keyword If    '${release_info}' == '0010_001800'   Make a VoNR and ViNR call together    phone_number=${target_phone_number}

locked LTE cell
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

unlocked LTE cell
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

Check XNLINK status for both gNB on webUI
    [Arguments]    ${xn_status}
    Check parameter should be correct for gNB    value=${xn_status}    url=${WEBUI_COAM_LOCAL}
    ...    dist_name=${xnLinkStatus_dist_name_1}    filter_param=XnC link status

Check parameter should be correct for gNB
    [Arguments]    ${value}    ${url}    ${dist_name}    ${filter_param}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${WEBUI2_NAME}    password=${WEBUI2_PWD}
    #selenium_coam.disable_message_box
    #${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    #Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    sleep    5s
    ${Para_value}=    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}
    selenium_coam.logout
    Should Be Equal    ${Para_value}    ${value}

Make a voice call on UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Make a call on UE(dial +6688 on UE)    ue_index=${ue_index}    serial_number=${serial_number}
    End a call on UE    ue_index=${ue_index}    serial_number=${serial_number}

Make a call on UE(dial +6688 on UE)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=cygwin${ue_index}
    sleep   2s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

Make a VoNR call(+6688) on SDX70
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

End a call on UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   2s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

check voice call status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=${2}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    ##### check voice call enable  #####
    ##### 0: the phone is in standby state. 1: the call is not answered. 2: the phone is busy  #####
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep mCallState
    ...    connection=cpc_${ue_index}
    sleep   2s
    ${result} =    csn.read output    connection=cpc_${ue_index}
    sleep    1s
    should contain    ${result}    mCallState=${status}
    [Teardown]    csn.disconnect      connection=cpc_${ue_index}

Get release info
    ${release_info}    Get sagnb release
    Set Suite Variable    ${release}    ${release_info}

Get sagnb release
    [Arguments]   ${host}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
#    ${release_info}     set variable    ${info.split('_')[1]}
    ${release_info}    set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Tear down wireshark log and detach
    run keywords
    ...    run keyword and ignore error    Teardown Stop Capture Wireshark Logs on gNB    AND
    ...    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${0}

Teardown Stop Capture Wireshark Logs on gNB
    [Arguments]    ${connection}=Local gnb1
    gNB connections to ssh    connection=${connection}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    [Teardown]    csn.disconnect    connection=${connection}

PA one cell 0 on and set other cell value
    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_cell}=${4}
    Change Attenuation value    cell=5Gcell${cellid}    value=${set_value}
    FOR  ${index}  IN RANGE   ${total_cell}
        ${cellnum} =    evaluate    ${index}+1
        run keyword if    '${cellid}'!='${cellnum}'    Change Attenuation value    cell=5Gcell${cellnum}    value=${127}
    END
    Change Attenuation value    cell=4Gcell1    value=${127}

Change Attenuation value
    [Arguments]    ${cell}    ${value}
    Set the Attenuation Value    ports=${${cell}_ANT1}    value=${value}
    Set the Attenuation Value    ports=${${cell}_ANT2}    value=${value}
    Run Keyword If    '${cell}' == '5Gcell3'    Run Keywords
    ...    Set the Attenuation Value    ports=${${cell}_ANT3}    value=${value}
    ...    AND    Set the Attenuation Value    ports=${${cell}_ANT4}    value=${value}

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

Change Attenuation value 4 port
    [Arguments]    ${cell}    ${value}
    Set the Attenuation Value    ports=${${cell}_ANT1}    value=${value}
    Set the Attenuation Value    ports=${${cell}_ANT2}    value=${value}
    Set the Attenuation Value    ports=${${cell}_ANT3}    value=${value}
    Set the Attenuation Value    ports=${${cell}_ANT4}    value=${value}

Set the Attenuation Value
    [Arguments]    ${ports}    ${value}
    attenuator.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${ports}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${att_api_model}
    attenuator.set_attenuation     port=${ports}    value=${value}

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
    attenuator.setup_attenuator    ip_addr=${ip_addr}    port=${att_api_port}
    ...    attenuation_port_numbers=${ports}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    attenuator.set_attenuation     port=${ports}    value=${value}




Get sagnb version for selenium
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${sw_version}     set variable    ${info.split('_')[1]}
    set suite variable    ${sw_version}
    [Return]    ${sw_version}
    [Teardown]   csn.Disconnect   connection=release_info

recover gnb para
    IF    ${enb_instance} == ${enb_id}[0]    #TL348
        Online modify parmeters    parameters_to_update=${PARAM_2056_AGAT_786_D_03_recover_WA_348}
    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
        Online modify parmeters    parameters_to_update=${PARAM_2056_AGAT_786_D_03_recover_WA}
    END
