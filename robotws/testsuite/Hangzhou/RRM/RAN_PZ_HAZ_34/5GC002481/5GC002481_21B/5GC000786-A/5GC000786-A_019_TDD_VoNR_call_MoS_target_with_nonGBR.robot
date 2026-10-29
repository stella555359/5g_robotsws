*** Settings ***
Force Tags    PY36
Documentation     author: Jack zeng
...                 contact: jack.zeng@nokia-sbell.com
...                 squad group: SG_03
...                 feature : 5GC000786

Variables    ./variables.py
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008140/Resources/CB008140_common_keywords_multiUE.robot

Suite Setup     Run Keywords
...            robot_common_operations.Common Suite Setup
...            AND    Run Keyword And Ignore Error    Common Suite Setup for COAM
...            AND    Get gnb release info
...            AND    Common Case TestLine Setup    is_commission=True    golden_scf_name=SCF_GNB1_${release_info}.xml

Suite Teardown   Run Keywords
...              Run Keyword And Ignore Error    Common Suite Teardown for COAM
...              AND    Adjust gNB_RU Attenuation for 2gnb

*** Variables ***
#${tl_scf_file_gnb1}    golden_FDD.xml
#${tl_scf_file_gnb0}    golden_TDD_23R1.xml
#${gnb_scf}    SCF_GNB1_
#${gnb2_scf_SBTS25R3_ENB_9999}    golden_FDD.xml
#${gnb1_scf_SBTS25R2_ENB_0000}    golden_TDD_SBTS25R1_ENB_9.xml
#${gnb2_scf_SBTS25R2_ENB_0000}    golden_FDD.xml
#${gnb1_scf_SBTS25R1_ENB_0000}    golden_TDD_SBTS25R1_ENB_9.xml
#${gnb2_scf_SBTS25R1_ENB_0000}    golden_FDD.xml
#${gnb1_scf_SBTS24R3_ENB_0000}    golden_TDD.xml
#${gnb2_scf_SBTS24R3_ENB_0000}    golden_FDD.xml
#${gnb1_scf_SBTS24R2_ENB_0000}    golden_TDD.xml
#${gnb2_scf_SBTS24R2_ENB_0000}    golden_FDD.xml
#${gnb1_scf_SBTS24R1_ENB_0000}    golden_TDD_24R1.xml
#${gnb2_scf_SBTS24R1_ENB_0000}    golden_FDD_24R1.xml
##${gnb1_scf_SBTS23R4_ENB_0000}    golden_TDD_23R1.xml
##${gnb2_scf_SBTS23R4_ENB_0000}    golden_FDD_23R1.xml
##${gnb1_scf_SBTS23R3_ENB_0000}    golden_TDD_23R1.xml
##${gnb2_scf_SBTS23R3_ENB_0000}    golden_FDD_23R1.xml
${enb_instance}    ${tl.enbs[0].instance_id}
${gnb_filter}    ngap.procedureCode == 26
${gnb_filter1}    ngap.radioNetwork == 34
${handover_filter}    xnap.XnAP_PDU == 1
${handover_req_filter}    xnap.radioNetwork == 1
${LOG_PATH}    /opt/workspace/CIT/Master/Case_Logs
${ue_type}    pioneer
${ue_mode}    5G_SA
${nglogname1}    786A019.pcap
${nglogname2}    786A019_HO.pcap
@{POLQA MOS SWB}    POLQA MOS SWB
@{RTP}    Voice RTP Packet Loss Count
@{ues1}    UE1
@{ues2}    UE2
${gnb1_PA}    30
${callednum}    +86${tl.ues[11].sec_key}
@{gnb_id}    24211
${gnb_instance0}    ${tl.gnbs[0].instance_id}
#${att_port_1_gnb1_cell1_24211}                ${tl.attenuator[0].attenuator_ports[4]}
#${att_port_2_gnb1_cell1_24211}                ${tl.attenuator[0].attenuator_ports[8]}
#${att_port_1_gnb1_cell2_24211}                ${tl.attenuator[0].attenuator_ports[3]}
#${att_port_2_gnb1_cell2_24211}                ${tl.attenuator[0].attenuator_ports[9]}
#${att_port_1_gnb2_cell1_24211}                ${tl.attenuator[0].attenuator_ports[5]}
#${att_port_2_gnb2_cell1_24211}                ${tl.attenuator[0].attenuator_ports[7]}
#${att_port_1_gnb2_cell2_24211}                ${tl.attenuator[0].attenuator_ports[1]}
#${att_port_2_gnb2_cell2_24211}                ${tl.attenuator[0].attenuator_ports[2]}
#${att_port_1_enb1_cell1_24211}                ${tl.attenuator[0].attenuator_ports[6]}
#${att_port_2_enb1_cell1_24211}                ${tl.attenuator[0].attenuator_ports[6]}
#${att_port_1_enb1_cell2_24211}                ${tl.attenuator[0].attenuator_ports[6]}
#${att_port_2_enb1_cell2_24211}                ${tl.attenuator[0].attenuator_ports[6]}
#${att_ipaddr_gnb1_cell1_24211}                ${tl.attenuator[0].ip_addr}
#${att_ipaddr_gnb1_cell2_24211}                ${tl.attenuator[0].ip_addr}
#${att_ipaddr_gnb2_cell1_24211}                ${tl.attenuator[0].ip_addr}
#${att_ipaddr_gnb2_cell2_24211}                ${tl.attenuator[0].ip_addr}
#${att_ipaddr_enb1_cell1_24211}                ${tl.attenuator[0].ip_addr}
#${att_ipaddr_enb1_cell2_24211}                ${tl.attenuator[0].ip_addr}
${mos_expect_pdf}    90
${imsi1}        ${tl.ues[10].imsi}
${imsi2}        ${tl.ues[11].imsi}
${ue_type1}    huawei
${dl_port}    ${tl.ues[10].iperf_details.port}
${dl_throughput}    500
${ul_throughput}    500
${dl_length}    1024
${ul_port}    ${tl.appserver.iperf_details.port}
${duration1}    2500
${dl_expect_throughput}    40
${ul_expect_throughput}    20
@{allow_fault_list}    7311    7107    7307    62003

*** Test Cases ***
[1]5GC002481_5GC000786_A_019_TDD_VoNR_call_with_voice_quality_MoS_target_with_nonGBR_Peak_TP
    [Documentation]    Test case describes  the successful setup of Voice over NR call with TDD and start traffic mos is reach target
    ...    20250104 add feature CB014474 more MOS value check
    [Tags]     SBTS21B    CRT_21B    5GC002481    CRT_22R3    CRT_22R4
    [Timeout]    2 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,7307,62003
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Check Mos value during handover
    [Teardown]    Run Keywords
    ...    Common Case Teardown for COAM    AND
    ...    Test recover for case19


*** Keywords ***
#Check Mos value and TP
#    #5GC002481_common_keyword.Reboot UE     ue_index=${0}
#    #sleep     30s
#    #Run keyword and ignore error    5GC002481_common_keyword.Check UE1 exist    ue_index=${0}
#    5GC002481_common_keyword.enable svc date
#    5GC002481_common_keyword.enable svc date    ue_index=${1}
#    log to console    start 786 UE attach
#    wait until keyword succeeds    2x   10s   5GC002481_common_keyword.786 UE attach    ue_index=${1}   gnb_index=${1}
#    log to console    start traffic
#    5GC002481_common_keyword.Start Capture Wireshark Logs on gNB    nglogname=${nglogname1}    interface=${interface}    gnb_index=${1}
#    wait until keyword succeeds    2x   10s    power_ue.Start traffic    ue_type=${ue_type}    direction=ul
#    ...    throughput=${ul_throughput}M    duration=${duration}    ue_index=${1}     iperf_port=${ul_port}
#    wait until keyword succeeds    2x   10s    power_ue.Start traffic    ue_type=${ue_type}    direction=dl
#    ...    throughput=${dl_throughput}M    duration=${duration}    ue_index=${1}    iperf_port=${dl_port}
#    sleep    20s
#    power_ue.Check throughput    ue_type=${ue_type}    direction=dl
#    ...    throughput=${dl_expect_throughput}    gnb_index=${1}
#    power_ue.Check throughput    ue_type=${ue_type}    direction=ul
#    ...    throughput=${ul_expect_throughput}    gnb_index=${1}
#    sleep    5s
##    wait until keyword succeeds    3x   10s   5GC002481_common_keyword.786 UE attach    ue_index=${0}    gnb_index=${1}
#    log to console    open pionner
#    5GC002481_common_keyword.open pionner
#    sleep    10s
#    log to console    require_platform
#    5GC002481_common_keyword.Prepare test plan
#    spark.require_platform    ue_alias=UE_0    index=1
#    sleep    10s
#    log to console    Start Log  UE_0
#    Run Keyword And Ignore Error    Power off the UE PDU
#    spark.Start Log     ue_alias=UE_0
#    sleep    20s
#    spark.start test    ue_alias=UE_0
#    sleep    3s
#    spark.start test    ue_alias=UE_0
#    log to console    start test plan
#    sleep    100s
#    Run Keyword And Ignore Error     spark.stop test    ue_alias=UE_0
#    5GC002481_common_keyword.Stop Capture Wireshark Logs on gNB    nglogname=${nglogname1}    gnb_index=${1}
#    Run Keyword And Ignore Error    Power on the UE PDU
#    spark.stop log   logname=${LOG_PATH}    ue_alias=UE_0    filter=${template_file}
#    spark.teardown    ue_alias=UE_0
#    sleep    20s
#    5GC002481_common_keyword.Check MOS from csv
#    5GC002481_common_keyword.Check MOS from csv    csv_num=${2}
#    [Teardown]    Run Keyword And Ignore Error     Test recover for case19

Check Mos value during handover
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${parameters_to_update_GNB1}
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell3_value=${0}
    power_ue.Prepare UE    ue_type=${ue_type1}    ue_index=${10}
    power_ue.Prepare UE    ue_type=${ue_type1}    ue_index=${11}
    log to console    start attach
    open pionner mos version
    log to console    start 786 UES attach
    Attach and check power UE    ue_type=${ue_type1}    ue_index=${10}
    Attach and check power UE    ue_type=${ue_type1}    ue_index=${11}
    log to console    Prepare UE dingli
    Prepare 2UE about dingli    ue_type=${UE_TYPE}    ue_index=${10}
    pioneer.UE Attach    ue_type=${UE_TYPE}    ue_index=${11}    ue_alias=UE1
    sleep    15s
    pioneer.start mos    ue_type=${UE_TYPE}    ue_index=${10}    callednum=${callednum}    ue_alias=UE1    duration=${860}    calledue=${2}
    power_ue.Start traffic    ue_type=${ue_type1}    direction=ul    throughput=${ul_throughput}M    duration=${duration1}    ue_index=${10}
        ...    iperf_port=${ul_port}
    power_ue.Start traffic    ue_type=${ue_type1}    direction=dl    throughput=${dl_throughput}M    duration=${duration1}    ue_index=${10}
        ...    iperf_port=${dl_port}
    Comment    sleep    300s for CB014474 more MOS value check
    sleep    200s
    log to console    start mos
    sleep    10s
    pclient.start_statistics   ues=@{ues1}    service=pioneer
    sleep    10s
    pclient.start_statistics   ues=@{ues2}    service=pioneer
    sleep    120s
    pclient.stop_statistics    ues=@{ues1}    service=pioneer
    sleep    10s
    pclient.stop_statistics    ues=@{ues2}    service=pioneer
    sleep    10s
    Check DL TP    dl_expect_throughput=${dl_expect_throughput}    ul_expect_throughput=${ul_expect_throughput}
    ...    cellid=${3}    gnb_index=${0}
    pioneer.stop mos    ue_type=${UE_TYPE}    ue_index=${10}    ue_alias=UE1
    Check MOS
    Check MOS    UE_num=UE2
    [Teardown]    Run Keyword And Ignore Error     close Pioneer

786 UEs attach
    [Arguments]    ${gnb_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    ue_index=${9}    gnb_index=${gnb_index}
    Run Keyword And Ignore Error    Trigger HUAWEI UE connect    ue_index=${9}
    power_ue.Verify attach    ue_type=huawei    ue_index=${9}    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    ue_index=${10}    gnb_index=${gnb_index}
    Run Keyword And Ignore Error    Trigger HUAWEI UE connect    ue_index=${10}
    power_ue.Verify attach    ue_type=huawei    ue_index=${10}    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False

Check DL TP
    [Arguments]    ${dl_expect_throughput}    ${ul_expect_throughput}
    ...    ${cellid}=3    ${gnb_index}=${0}    ${ue_type}=${UE_TYPE}
    ${nrcellid}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid}    Create list  ${nrcellid}
    ${tput_log}    power_ue.Collect Tput    duration=30s    ignore_time=0s    ue_type=${ue_type}    gnb_index=${gnb_index}
    power_ue.Check Tput    direction=DL    cells=${nrcellid}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${dl_expect_throughput}
    power_ue.Check Tput    direction=UL    cells=${nrcellid}    log=${tput_log}   ue_type=${ue_type}
    ...    target_throughput=${ul_expect_throughput}

Test recover for case19
#    Run Keyword And Ignore Error    Common Case Teardown for COAM
    Run Keyword And Ignore Error    power_ue.Stop traffic     ue_type=${ue_type1}     direction=dl     iperf_port=${dl_port}
    ...    ue_index=${10}
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type1}    direction=ul    iperf_port=${ul_port}
    ...    ue_index=${10}
    power_ue.UE Detach    ue_type=${ue_type1}    ue_index=${10}
    power_ue.UE Detach    ue_type=${ue_type1}    ue_index=${11}


### PA adjust ###
Adjust gNB_RU Attenuation
    [Arguments]     ${tl}=${gnb_instance0}    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}
    ...    ${gnb2_cell1_value}=${127}    ${gnb2_cell2_value}=${127}    ${enb1_cell1_value}=${127}
    ...     ${enb1_cell2_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_gnb1_cell1_${tl}}    ${att_port_2_gnb1_cell1_${tl}}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_1_gnb1_cell2_${tl}}    ${att_port_2_gnb1_cell2_${tl}}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_1_gnb2_cell1_${tl}}    ${att_port_2_gnb2_cell1_${tl}}
    @{att_ports_gnb2_cell2}    Create List    ${att_port_1_gnb2_cell2_${tl}}    ${att_port_2_gnb2_cell2_${tl}}
    @{att_ports_enb1_cell1}    Create List    ${att_port_1_enb1_cell1_${tl}}    ${att_port_2_enb1_cell1_${tl}}
    @{att_ports_enb1_cell2}    Create List    ${att_port_1_enb1_cell2_${tl}}    ${att_port_2_enb1_cell2_${tl}}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_gnb2_cell2}    Create List    ${gnb2_cell2_value}    ${gnb2_cell2_value}
    @{values_enb1_cell1}    Create List    ${enb1_cell1_value}    ${enb1_cell1_value}
    @{values_enb1_cell2}    Create List    ${enb1_cell2_value}    ${enb1_cell2_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_gnb1_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_gnb1_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_gnb2_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell2}    values=${values_gnb2_cell2}
    ...    att_connection_port=${att_port_1_gnb2_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_enb1_cell1}    values=${values_enb1_cell1}
    ...    att_connection_port=${att_port_1_enb1_cell1_${tl}}    att_ipaddr=${att_ipaddr_enb1_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_enb1_cell2}    values=${values_enb1_cell2}
    ...    att_connection_port=${att_port_1_enb1_cell2_${tl}}    att_ipaddr=${att_ipaddr_enb1_cell2_${tl}}

adjust the HBTE attenuation value
    [Arguments]     ${start_value}    ${end_value}    ${att_port_1}=${att_port_1}    ${att_port_2}=${att_port_2}    ${atten_ip}=${atten_ip}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${tl.attenuator[0].model}
    FOR    ${value}    IN RANGE    ${start_value}    ${end_value}+3    2
      attenuator.set_attenuation     port=${att_port_1}    value=${value}
      attenuator.set_attenuation     port=${att_port_2}    value=${value}
      ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
      should be equal    ${value_port_1}    ${value}
      ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
      should be equal    ${value_port_2}    ${value}
      sleep    2s
    END

Check IE wireshark log for handover response
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${xnap_cause}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//xnap.drb_ID
    Should not contain    ${xnap_cause}    6
    should contain    ${xnap_cause}    4    5

Check IE wireshark log for handover request
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${xnap_cause}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//xnap.drb_ID
    should contain    ${xnap_cause}    6

open pionner mos version
    [Arguments]    ${ue_index}=${10}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    csn.send_command    command=schtasks /run /tn dingli
    ...    connection=cygwin
    sleep    85s

close Pioneer
    [Arguments]    ${ue_index}=${10}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    csn.Execute       command=taskkill /F /IM Pioneer.exe       connection=cygwin

Prepare 2UE about dingli
    [Arguments]    ${host}=${tl.ues[10].ssh_connection_details.addr}
        ...    ${username}=${tl.ues[10].ssh_connection_details.username}
        ...    ${password}=${tl.ues[10].ssh_connection_details.password}
        ...    ${imsi1}=${imsi1}    ${imsi2}=${imsi2}    ${alias}=pioneer    ${ue_alias1}=UE1    ${ue_alias2}=UE2
        ...    ${port}=30999    &{kwargs}
    [Documentation]    Prepare UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for reserve
    pclient.setup_service
    ...    host=${host}
    ...    port=${port}
    ...    ssh_username=${username}
    ...    ssh_password=${password}
    ...    alias=${alias}
    ...    timeout=300
    Run Keyword And Ignore Error    pclient.prepare_ues    service=${alias}
	sleep    60s
    pclient.remove_remote_files    folder_path=c:/pioneer_logs/    service=${alias}
    pclient.require_ue    service=${alias}     imsi=${imsi1}    ue_alias=${ue_alias1}
    pclient.require_ue    service=${alias}     imsi=${imsi2}    ue_alias=${ue_alias2}
    ${is_kirin}     pclient.is_kirin_chip    ue=${ue_alias1}
    ${is_kirin}     pclient.is_kirin_chip    ue=${ue_alias2}
    sleep    2s

Check ULDL TP
    [Arguments]    ${dl_expect_throughput}=${expect_dl_tput}    ${cellid}=${1}    ${gnb_index}=${1}    ${ul_expect_throughput}=${expect_ul_tput}
    ...    ${duration}=30s
    ${nrcell_id}    get nrCellid    cellid=${cellid}    nrbtsid=${tl.gnbs[${gnb_index}].instance_id}    gnb_index=${gnb_index}
    ${list_of_cell_ids}    Create list    ${nrcell_id}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=${gnb_index}    duration=${duration}
    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${dl_expect_throughput}
	    Power_ue.Check Tput    ue_type=${ue_type}    direction=UL    log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${ul_expect_throughput}

get nrCellid
    [Arguments]    ${cellid}=${1}     ${nrbtsid}=1     ${gnb_index}=${1}
    ${value}=    Get parameter value    dis_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${nrbtsid}/NRCELL-${cellid}
    ...    filter_name=NR Cell Identity
    [Return]    ${value}

Check RTP
    [Arguments]    ${UE_num}=UE1
    ${RTP_value}=    pclient.get_param_statistics_result    ue=${UE_num}    paramname=@{RTP}
#    ${RTP_value_act}    set variable    ${RTP_value}[Param]['Voice Packet Loss Count'][1][Count]
    ${RTP_value_all}    set variable    ${RTP_value}[Param]
    ${RTP_value_RTP}    set variable    ${RTP_value_all}[Voice RTP Packet Loss Count]
    ${RTP_value_rang}    set variable    ${RTP_value_RTP}[3]
    ${RTP_value_count}    set variable    ${RTP_value_rang}[Count]
    should be true    ${RTP_value_count} < 1

Check MOS
    [Arguments]    ${UE_num}=UE1
    ${POLQA MOS value}=    pclient.get_param_statistics_result    ue=${UE_num}    paramname=@{POLQA MOS SWB}
    ${MOS_value_all}    set variable    ${POLQA MOS value}[Param]
    ${MOS_value_MOS}    set variable    ${MOS_value_all}[POLQA MOS SWB]
    ${MOS_value_rang}    set variable    ${MOS_value_MOS}[3]
    ${MOS_value_rang1}    set variable    ${MOS_value_MOS}[2]
    ${MOS_value_PDF}    set variable    ${MOS_value_rang}[PDF]
    ${MOS_value_PDF1}    set variable    ${MOS_value_rang1}[PDF]
    ${MOS_value_count}    set variable    ${MOS_value_rang}[Count]
    Should Be True     ${MOS_value_count} > 0
    ${MOS_value_PDF}    Evaluate    ${MOS_value_PDF.strip("%")}
    ${MOS_value_PDF1}    Evaluate    ${MOS_value_PDF1.strip("%")}
    ${MOS_value}    Evaluate    ${MOS_value_PDF} + ${MOS_value_PDF1}
    Should Be True    ${MOS_value} > ${mos_expect_pdf}

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}