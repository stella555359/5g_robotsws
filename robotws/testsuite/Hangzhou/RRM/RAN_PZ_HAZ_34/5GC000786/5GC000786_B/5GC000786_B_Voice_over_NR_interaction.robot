*** Settings ***
Force Tags    PY36
Documentation     author: shuiqin.chu
...                 contact: shuiqin.chu@nokia-sbell.com
...                 squad group: SG_03
...                 feature : 5GC000786-B

Resource    ./../../5GC000749/Resources/5GC000749_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Variables   ../Resources/5GC000786_variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot

Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup    AND
...            Common Suite Setup for COAM    AND
...            Prepare env with UE    AND
...            Get gnb release info    AND
...            Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}   AND
#...            Setup for SA Env cell on-air    AND
#...            checking type of system board on gnb1    AND
...            Online modify parmeters    parameters_to_update=${PARAM_gNB1_786_B_018}    AND
...    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Online add parmeters    parameters_to_update=${PARAM_gNB1_786_B_018_PLMN_TL367}
...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Online add parmeters    parameters_to_update=${PARAM_gNB1_786_B_018_PLMN_TL382}
...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Online add parmeters    parameters_to_update=${PARAM_gNB1_786_B_018_PLMN_TL343}    AND
...            check EPS fallback and VoNR parameter is enabled    AND
...            Run Keyword And Ignore Error    Lock_gnb2_Cell_without_TL351    AND
...            Run Keyword And Ignore Error    lock gnb1 cell2    AND
...            Unlock the phone

Suite Teardown    Run Keywords
...            robot_common_operations.Common Suite Teardown    AND
...            Run Keyword And Ignore Error    unLock_gnb2_Cell_without_TL351    AND
...            Run Keyword And Ignore Error    unlock gnb1 cell2    AND
...            Run Keyword And Ignore Error    COAM Teardown gnb connections


*** Variables ***
${nglogname2}    786B02.pcap
${nglogname4}    786B04.pcap
${nglogname9}    786B09.pcap
${nglogname12}    786B12.pcap
${nglogname16}    786B16.pcap
${nglogname18}    786B18.pcap
${enblogname18}    786B18_enb.pcap
${enblogname12}    786B12_enb.pcap
${gnb_instance}    ${tl.gnbs[0].instance_id}
${enb_instance}     ${tl.enbs[0].instance_id}
${epc_log_path}    /tmp/
${TS_LOG_PATH_BASE}      ${OUTPUT DIR}/Case_Logs
#${SCF_path}    /opt/workspace/CRT/Master/SCF_file/golden SCF/
#${SCF_file_name}    Configuration_scf_GNB1_CB008698.xml

${scf_path}    /opt/workspace/CRT/Master/SCF_file/golden SCF/
${tl_scf_SBTS24R3_ENB_9999}    24R1_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS25R1_ENB_9999}    Trunk_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS24R2_ENB_0000}    24R1_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS24R2_ENB_9999}    24R1_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS24R1_ENB_0000}    24R1_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS23R4_ENB_0000}    Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS23R3_ENB_0000}    Configuration_scf_GNB1_CB008698.xml

${enb_path}    /tmp
${ue_type}    huawei
${ue_mode}    5G_SA
${dl_port}    53399
${dl_throughput}    100
${ul_throughput}    500
${dl_length}    1024
${ul_port}    53499
${duration}    150
${dl_expect_throughput}    20
${ul_expect_throughput}    10
${ngap_filter}    ngap
${s1ap_filter}    s1ap
@{full_path}    CELLS/NRCELL-1/NRRCC/NR_RRC_RELEASE_REDIR_VFB_LTE
${gnb_path}           /tmp/
#${epc_log_path}       /home/ute/projects/xnlog/
${gnb1_interface_name}    fp0
#${enb_instance}    ${tl.enbs[0].instance_id}
${Null_ciphering}    Null ciphering algorithm
${SNOW_3G-based}    SNOW 3G-based algorithm
${AES-based}    AES-based algorithm
${ZUC-based}    ZUC-based algorithm
${nullFallback_accepted}    Null ciphering algorithm fallback accepted
#@{redirFreqEutra_value}    2300    41480
@{redirFreqEutra_value}    1350    41480
${E1AP}    E1AP_
${gnb_trunk}    38211

## filter command for coverting PDML
${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"ngap or e1ap or f1ap or xnap\"  -T pdml

@{diffTL_enb_ID}    36721    38221    911
@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}


${att_port_1_HBTE}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_2_HBTE}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_3_HBTE}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${att_port_4_HBTE}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${att_port_5_HBTE}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_6_HBTE}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_7_HBTE}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${att_port_8_HBTE}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${att_ipaddr_HBTE}    ${tl.attenuator[0].ip_addr}
*** Test Cases ***
[1]5GC000786-B_018_TDD_VoNR_call_while_EPS_FB_is_enabled_while_diff_PLMN_exist
    [Documentation]    This user scenario describes the gNB behaviour for the successful setup of Voice over NR call
    ...    with FDD. 5QI5 Qos flow setup request is received as part of PDU Session Resource Setup procedure.
    ...    5QI1 QoS flow setup request is received as part of PDU Session Resource Modify procedure while Voice
    ...    Fallback to LTE is enabled and different PLMN configured in one cell
    [Tags]            5GC000786-B    CRT_22R4    CRT_TRUNK    CRT_22R3
    [Setup]    robot_common_operations.Common Case Setup
#    ${release_info}    Get gnb release
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    set suite variable    ${release_info}
    locked LTE cell
    Check UE exist
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname18}    interface=${gnb1_interface_name}
    Enb start capture wireshark log    filename=${enblogname18}
    786 UEs attach
    unlocked LTE cell
    make two UE VoNR with multi PLMN
    hang up VoNR call
    hang up VoNR call    ue_index=${1}
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname18}
    Enb stop and Save classical Logs    filename=${enblogname18}
    Analysis wireshark log for case 786B18    gnblog=${nglogname18}
#    Analysis wireshark log on enb for case 786B18    enblog=${enblogname18}
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
    ...    sleep    30s    AND    786 UEs detach    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${2}    AND
    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    AND
    ...    unlocked LTE cell    AND
    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname18}

*** Keywords ***
Adjust HBTE gNB_eNB_RU Attenuation
    [Arguments]    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}    ${enb_cell1_value}=${127}
#    Run Keyword If     '${enb_instance}'=='@{diffTL_enb_ID}[0]'
    Adjust the tl HBTE attenuation value    #tl=@{diffTL_enb_ID}[0]
    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
    ...    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}
#    ...    ELSE    sleep    1s

Adjust the tl HBTE attenuation value
    [Arguments]     ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ...    ${enb_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_HBTE}     ${att_port_2_HBTE}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_3_HBTE}     ${att_port_4_HBTE}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_5_HBTE}     ${att_port_6_HBTE}
    @{att_ports_enb_cell1}     Create List    ${att_port_7_HBTE}     ${att_port_8_HBTE}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_enb_cell1}     Create List    ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_enb_cell1}     values=${values_enb_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}

Start DL and UL data transfer
    [Arguments]    ${dl_throughput}    ${ul_throughput}    ${ue_index}=${0}
    log to console    \n *** Start DL & UL transmission
    Start DL date transfer    dl_throughput=${dl_throughput}    ue_index=${ue_index}
    Start UL data transfer    ul_throughput=${ul_throughput}    ue_index=${ue_index}

Start UL data transfer
    [Arguments]    ${ul_throughput}    ${ue_index}=${0}    ${iperf_port}=default
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul   throughput=${ul_throughput}
    ...    duration=${duration}    ue_index=${ue_index}    iperf_port=${iperf_port}

Start DL date transfer
    [Arguments]    ${dl_throughput}    ${ue_index}=${0}    ${iperf_port}=default
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl   throughput=${dl_throughput}
    ...    duration=${duration}    ue_index=${ue_index}    iperf_port=${iperf_port}

Setup for SA Env cell on-air B18
    Prepare SA classical COAM BTS cell onair B18
    RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare SA classical COAM BTS cell onair B18
    should be equal    ${cell_status}    PASS

Prepare SA classical COAM BTS cell onair B18
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare SA COMA classical BTS cell onair B18
    set global variable    ${cell_status}

Prepare SA COMA classical BTS cell onair B18
    Perform full commission for COAM SA gnb    scf=${SCF_path}${B18_SCF_file_name}
    Check gnb COAM classical normally
    Check the gnb cell status onair    cell_no=1

lock SNSSAI
    set and check value of parameter administrativeState on MO SNSSAI    value=Locked    new_value=Locked

unlock gnb1 cell2
    unLock_gnb2_Cell    url=${WEBUI_COAM}    cell_id=2    bts_host=${asik_addr}

Lock_gnb2_Cell_without_TL351
    run keyword if    '${gnb_instance}'!='1144'    Lock_gnb2_Cell

unLock_gnb2_Cell_without_TL351
    run keyword if    '${gnb_instance}'!='1144'    unLock_gnb2_Cell

Analysis wireshark log for case 786B18
    [Arguments]    ${gnblog}
    analysis wireshark log for VoNR success    gnblog=${gnblog}
    analysis wireshark log for VoNR unsuccess    gnblog=${gnblog}

Analysis wireshark log for case 786B16
    [Arguments]    ${gnblog}
    analysis wireshark log for VoNR start from idle status    logname=${gnblog}
    analysis wireshark log for VoNR success    gnblog=${gnblog}

Analysis wireshark log for case 786B02
    [Arguments]    ${gnblog}
    analysis wireshark log for VoNR success    gnblog=${gnblog}
    Run keyword if    '${gnb_instance}'=='${gnb_trunk}'    Check EIAP log name    logname=${gnblog}
    Analysis wireshark log for ciphering should be NULL_ciphering    logname=${gnblog}

Analysis wireshark log for case 786B04
    [Arguments]    ${gnblog}
    analysis wireshark log for VoNR success    gnblog=${gnblog}
    Run keyword if    '${gnb_instance}'=='${gnb_trunk}'    Check EIAP log name    logname=${gnblog}
    Analysis wireshark log for ciphering should be AES_ciphering    logname=${gnblog}

Analysis wireshark log for case 786B09
    [Arguments]    ${gnblog}
    analysis wireshark log for VoNR unsuccess    gnblog=${gnblog}

Analysis wireshark log for case 786B12
    [Arguments]    ${gnblog}
    analysis wireshark log for VoNR unsuccess    gnblog=${gnblog}

Analysis wireshark log on enb for case 786B12
    [Arguments]    ${enblog}
    Analysis wireshark log on enb for EPSFB    logname=${enblog}

Analysis wireshark log on enb for case 786B18
    [Arguments]    ${enblog}
    Analysis wireshark log on enb for EPSFB    logname=${enblog}

Analysis wireshark log on enb for case 786B09
    [Arguments]    ${enblog}
    Analysis wireshark log on enb for EPSFB    logname=${enblog}

Lock_gnb_Cell2
    [Arguments]         ${url}=${WEBUI_COAM}    ${bts_host}=${asik_addr}    ${port}=443      ${alias}=OAM_admin
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-2
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    coam.connect to   bts_host=${bts_host}
    ...               bts_port=${port}    name=${alias}
    coam.lock_cell    dist_name=/${administrativeState_distname}
    ...               connection=${alias}
    coam.teardown          connection=${alias}

unlocked LTE cell
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

unlocked LTE cell on TL343
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-0
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

locked LTE cell
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

locked LTE cell on TL343
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-0
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

Unlock the phone
    Set automatic rotation
    Set automatic rotation    ue_index=${1}

make two UE VoNR with multi PLMN
    Make a VoNR call
    Make a VoNR call    ue_index=${1}

Make a VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=cygwin${ue_index}
    sleep    10s

hang up VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}

Start Capture Wireshark Logs on gNB
    [Arguments]     ${nglogname}    ${interface}
    RUN KEYWORD AND IGNORE ERROR    gNB connections
    csn.send command    command=tcpdump -i any sctp -w ${gnb_path}/${nglogname}   connection=${connection}
    sleep    3s
    run keyword if    '${gnb_instance}'=='${gnb_trunk}'
    ...    csn.send command    command=bsh 0:1 tcpdump -i any sctp -w /tmp/${E1AP}${nglogname}   connection=${connection}
    sleep    3s

Stop Capture Wireshark Logs on gNB
    [Arguments]    ${nglogname}
    gNB connections
    sleep    5
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}/${nglogname}   local_path=${epc_log_path}${nglogname}   connection=${connection}
    sleep    3
    csn.send command    command=bsh 1:0 killall tcpdump     connection=${connection}
    sleep    3
    run keyword if    '${gnb_instance}'=='${gnb_trunk}'
    ...    csn.download_file   remote_path=/tmp/${nglogname}   local_path=${epc_log_path}${E1AP}${nglogname}   connection=${connection}
    sleep    3

Enb start capture wireshark log
    [Arguments]    ${filename}     ${interface}=br1    ${connection}=enb
    RUN KEYWORD AND IGNORE ERROR    enb connection
    csn.send command    command=tcpdump -i ${interface} sctp -w ${enb_path}${filename}   connection=${connection}
    sleep    3s

check EPS fallback and VoNR parameter is enabled
    check value of parameter actRedirect
    check value of parameter actNormVCfallback
    check value of parameter voiceFBmode
    check value of parameter redirRat
#    run keyword if    '${enb_instance}'=='36721'    check value of parameter redirFreqEutra    value=@{redirFreqEutra_value}[1]
#    ...    ELSE    check value of parameter redirFreqEutra    value=@{redirFreqEutra_value}[0]
    check value of parameter redirFreqEutra    value=${redirFreqEutra_value}[0]
    check value of parameter actVoNR

pre-check paramater for 786B02
    check value of parameter algorithm

pre-check paramater for 786B04
    check value of parameter algorithm    value1=0    value3=9

set new value for gnb idle
    set value of parameter drbInactivityTimerSA    new_value=10seconds    despite_errors=True
    set value of parameter srbInactivityTimerSA    new_value=10seconds    despite_errors=True

Wait for UE in idle status
    ${timer}=    check SA inactive timer
    sleep    ${timer}

Trigger HUAWEI UE IDLE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[0].ssh_connection_details.addr}
    ...    username=${tl.ues[0].ssh_connection_details.username}
    ...    password=${tl.ues[0].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell svc data disable    connection=cygwin${ue_index}
    sleep    10s

Trigger HUAWEI UE connect
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[0].ssh_connection_details.addr}
    ...    username=${tl.ues[0].ssh_connection_details.username}
    ...    password=${tl.ues[0].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell svc data enable    connection=cygwin${ue_index}
    sleep    10s

check SA inactive timer
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${timer_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    ${timer}=    selenium_coam.get_parameter_value    dist_name=${timer_distname}
    ...    filter_param=Stand alone UE DRB inactivity timer    abbr=drbInactivityTimerSA
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    [return]    ${timer}

Set VoNR function on gnb
    [Arguments]    ${actVoNR}=true
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-1
    ...    abbr=actVoNR
    ...    filter_param=Activate voice over NR call support in the NR cell.
    ...    new_value=${actVoNR}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=true
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

get ciphering value from wireshark
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${Code26_0} =    Catenate    f1ap.procedureCode ==12 && nr-rrc.cipheringAlgorithm
    Log To Console    check security mode command ciphering value
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_0}
    ${ciphering_value}=    get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cipheringAlgorithm
    [return]    ${ciphering_value[0]}

Analysis wireshark log for ciphering should be NULL_ciphering
    [Arguments]    ${logname}
    ${ciphering_value}=    get ciphering value from wireshark    logname=${logname}
    Should Be Equal    ${ciphering_value}    0

Analysis wireshark log for ciphering should be AES_ciphering
    [Arguments]    ${logname}
    ${ciphering_value}=    get ciphering value from wireshark    logname=${logname}
    Should Be Equal    ${ciphering_value}    2

analysis wireshark log for VoNR start from idle status
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${idle} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 42 and ngap.radioNetwork==20
    Log To Console    check UEContextReleaseRequest
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${idle}
    ${radioNetwork}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.radioNetwork
    Should Be Equal    ${radioNetwork[0]}    20

    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 15 and ngap.RRCEstablishmentCause==5
    Log To Console    check servicerequest due to VoNR call
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_0}
    ${RRCEstablishmentCause}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.RRCEstablishmentCause
    Should Be Equal    ${RRCEstablishmentCause[0]}    5

    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 14 and ngap.id==71
    Log To Console    check service accept from AMF
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_0}
    ${ID}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.fiveQI
    Should Contain    ${ID}    5

Analysis wireshark log for PDUSessionResourceModifyRequest ok
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26 and ngap.fiveQI==1
    Log To Console    check PDUSessionResourceModifyRequest
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${Code26_0}    pcap_parser=test6
    ${5qi}=    get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    Should Be Equal    ${5qi[0]}    1

Analysis wireshark log for PDUSessionResourceModifyResponse ok
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
    ${Code26_1} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    ${criticality} =    get_field_value_by_xpath    xpath=.//ngap.criticality    pcap_parser=test6
    Should Be Equal    ${criticality[0]}    0

    Run keyword if    '${gnb_instance}'=='${gnb_trunk}'    Check EIAP log name    logname=${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check RRCreconfigurecomplete
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${ULRRCMessageTransfer}
    ${criticality} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.criticality
    Should Be Equal    ${criticality[0]}    1

Analysis wireshark log for PDUSessionResourceModifyResponse not ok
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
    ${Code26_1} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    36

    ${Code42} =    Catenate    ngap.procedureCode == 42 and ngap.radioNetwork==41
    Log To Console    check UEContextReleaseRequest
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code42}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath     xpath=.//ngap.radioNetwork      pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    41

    ${Code41} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 41 and ngap.radioNetwork == 41
    Log To Console    check UEContextReleaseCommand
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code41}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    41

    ${Code41} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 41
    Log To Console    check UEContextReleaseComplete
    ${Code41_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code41}
    should be equal    ${Code41_status}    ${True}

Check EIAP log name
    [Arguments]  ${logname}
    ${logname}=    Catenate    ${E1AP}    ${logname}
    [return]    ${logname}

Analysis wireshark log for VoNR success release
     [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
    Log To Console    check release value on PDUSessionResourceModifyRequest message
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26 and ngap.nas==0
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    ${ngap_nas} =    get_field_value_by_xpath    xpath=.//ngap.nas    pcap_parser=test6
    Should Be Equal    ${ngap_nas[0]}    0

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyResponse
    ${filtered_packets}=
    ...    filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyResponse}    pcap_parser=test6
    ${ngap_id} =    get_field_value_by_xpath    xpath=.//ngap.criticality    pcap_parser=test6
    Should Be Equal    ${ngap_id[0]}    0

   ##########add for trunk E1AP and F1AP check #########
    Run keyword if    '${gnb_instance}'=='${gnb_trunk}'    Check EIAP log name    logname=${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
    ${BearerContextModificationRequest} =     Catenate
    ...    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9 and e1ap.DRB_To_Remove_Item_NG_RAN_element
    Log To Console    check release BearerContextModificationRequest message
    ${filtered_packets}=
    ...    filter_packets_by_expression    filter_expression=${BearerContextModificationRequest}    pcap_parser=test6
    ${e1ap_id} =    get_field_value_by_xpath    xpath=.//e1ap.id    pcap_parser=test6
    Should Contain    ${e1ap_id}    18

    ${UEContextModificationRequest} =    Catenate
    ...    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and f1ap.DRBs_ToBeReleased_List
    Log To Console    check value on release UEContextModificationRequest message
    ${filtered_packets}=
    ...    filter_packets_by_expression    filter_expression=${UEContextModificationRequest}    pcap_parser=test6
    ${f1ap_id} =    get_field_value_by_xpath    xpath=.//f1ap.id    pcap_parser=test6
    Should Contain    ${f1ap_id}    32
    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationResponse message
    ${filtered_packets}=
    ...    filter_packets_by_expression    filter_expression=${BearerContextModificationResponse}    pcap_parser=test6
    ${e1ap_id} =    get_field_value_by_xpath    xpath=.//e1ap.id    pcap_parser=test6
    Should Contain    ${e1ap_id}    48

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7 and nr-rrc.rlc_BearerToReleaseList
    Log To Console    check value on release UEContextModificationResponse message
    ${filtered_packets}=
    ...    filter_packets_by_expression    filter_expression=${UEContextModificationResponse}    pcap_parser=test6
    ${f1ap_id} =    get_field_value_by_xpath    xpath=.//f1ap.id    pcap_parser=test6
    Should Contain    ${f1ap_id}    39

analysis wireshark log for VoNR success
    [Arguments]    ${gnblog}
    wait until keyword succeeds    5min    30s    Analysis wireshark log for PDUSessionResourceModifyRequest ok    logname=${gnblog}
    Analysis wireshark log for PDUSessionResourceModifyResponse ok    logname=${gnblog}
    Analysis wireshark log for VoNR success release        logname=${gnblog}

analysis wireshark log for VoNR unsuccess
    [Arguments]    ${gnblog}
    wait until keyword succeeds    5min    30s    Analysis wireshark log for PDUSessionResourceModifyRequest ok    logname=${gnblog}
    Analysis wireshark log for PDUSessionResourceModifyResponse not ok    logname=${gnblog}

Analysis wireshark log on enb for EPSFB
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${Code0_12} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 12
    Log    check InitialUEMessage
    ${Code0_12_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_12}
    should be equal    ${Code0_12_status}    ${True}

    ${Code0_9} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 9
    Log    check InitialContextSetupRequest
    ${Code0_9_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_9}
    should be equal    ${Code0_9_status}    ${True}

    ${Code0_5} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 5 and nas_eps.nas_msg_esm_type == 0xc5
    Log    check E_RABSetupRequest
    ${Code0_5_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_5}
    should be equal    ${Code0_5_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code0_5}
#    ${s1ap_qCI} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//s1ap.qCI
#    Should Be Equal    ${s1ap_qCI[0]}    1

    ${Code0_13_c6} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xc6
    Log    check UplinkNASTransport
    ${Code0_13_c6_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_13_c6}
    should be equal    ${Code0_13_c6_status}    ${True}

    ${Code0_7} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 7
    Log    check E_RABReleaseCommand
    ${Code0_7_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_7}
    should be equal    ${Code0_7_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code0_7}
    ${s1ap_nas} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//s1ap.nas
    Should Be Equal    ${s1ap_nas[0]}    0

    ${Code0_13_ce} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xce
    Log    check UplinkNASTransport
    ${Code0_13_ce_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_13_ce}
    should be equal    ${Code0_13_ce_status}    ${True}

Online add parmeters
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM add several parameters via rest api    parameters_to_add_via_api=${parameters_to_update}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections
