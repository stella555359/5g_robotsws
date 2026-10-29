*** Settings ***
Force Tags    PY36
Documentation     author: Nora zhu
...                 contact: nora.zhu@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB005876

#Resource     ../CB006112/Resources/CB006112_common_keywords.robot
Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB006112/Resources/CB006112_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB005876/Resources/CB005876_variables.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup
...           AND    Run Keyword And Ignore Error    Common Suite Setup for COAM
...           AND    Prepare env with cell on air
...           AND    get_release_check_result
...           AND    get counter path for per tl

Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
    ...           AND    Common Suite Teardown for COAM
    ...           AND    Run Keyword And Ignore Error    teardown for case

*** Variables ***
${SCF_path}    /opt/workspace/CRT/Master/SCF_file/
#${SCF_file_name_1}       5876case1_gnb1.xml
${SCF_file_name_1}       gNB1_Golden_SCF.xml
${nglogname1}    5876case001.pcap
${enblog}    enb.pcap
${gnb_slave_path}    /ffs/run/config/toor4nsn/
${phone_number_UE1}    ${tl.ues[0].sec_key}
#${gnb_filter1}    ngap.NGAP_PDU == 1 and ngap.HandoverType == 1 and ngap.pDUSessionID == 1
${gnb_filter1}    ngap.NGAP_PDU == 1 and ngap.HandoverType == 1
${gnb_filter2}    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and f1ap.id == 9
${enb_filter1}    s1ap.procedureCode == 2
${enb_filter2}    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 18
${enb_interface}    any
${enb_path}    /tmp/
#${epc_log_path}    /tmp/
${dl_port}    ${tl.ues[0].iperf_details.port}
${dl_throughput}    1
${ul_throughput}    1
${dl_length}    1024
${ul_port}    ${tl.appserver.iperf_details.port}
${duration}    150
${dl_expect_throughput}    5
@{counter_id}    M55337C00007    M55337C01007    M55337C02007    M55337C03007    M55337C04007    M55337C05007
@{counter_id2}    M55337C00006    M55337C01006    M55337C02006    M55337C03006    M55337C04006    M55337C05006
${org_value}    0
#${att_connection_port}           ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
#${max_attenuation_value}         ${127}
#${vendor}    ${tl.attenuators[0].vendor}
#${path_NNGCC_IRATHO}    BTS/BTS/NRBTS-${tl.gnbs[0].instance_id}/NRPFW
#${path_NNGCC_IRATHO}    BTS/BTS/NRBTS-383/NRPFW
${wap2apn}    97 740
${wuxuapn}    97 1140    #mdrb.nokia.com
#${wuxuapn_348}    150 1140    #mdrb.nokia.com
${wuxuapn_348}    95 1230
${dxdata2_apn}    95 943
#${dxdata2_apn_348}    150 943
${dxdata2_apn_348}    95 1030
${click_access_point}    380 1060
${interface}    fp0
${NG-U_log}    nguplanlog.pcap
${gnb1_ru1_0}     ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${gnb1_ru1_1}     ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${gnb1_ru2_0}     ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${gnb1_ru2_1}     ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${gnb1_ru3_0}     ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${gnb1_ru3_1}     ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${gnb2_ru1_0}     ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${gnb2_ru1_1}     ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
${gnb2_ru2_0}     ${tl.gnbs[1].dus[0].rus[1].attenuation_ports[0].port_no}
${gnb2_ru2_1}     ${tl.gnbs[1].dus[0].rus[1].attenuation_ports[1].port_no}
${enb_0}     ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}
${enb_1}     ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}
${attach_log}    gnb_attach.pcap
${attach_filter1}    ngap.fiveQI == 6
@{specail_port_list}    53238    53238    53238
${tshark_path}    /usr/bin/tshark
${end_maker}    ip.proto == 17
${not_end_maker2}    ip.proto == 17 and !(ip.addr == 10.57.233.146) and !(ip.addr == 10.57.152.130) and !(ip.addr == 10.57.131.99)
${command_template_Z}      {tshark_path} -r {pcap_file} -Y  \"gtp.message == 0xff\"  -T pdml
${command_template_X}       {tshark_path} -r {pcap_file} -Y  \"gtp.message == 0xfe\"  -T pdml
${asik_addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asik_password}     ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
#${ue_type}    samsung
@{enb_ids}    358    34821    38321    342
${enb_instance}     ${tl.enbs[0].instance_id}

${5GRU_ANT1}     ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}    #gnb1 cell 1
${5GRU_ANT2}     ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}    #gnb1 cell 1
${5GRU_ANT3}     ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}    #gnb1 cell 2
${5GRU_ANT4}     ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}    #gnb1 cell 2
${5GRU_ANT5}     ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}    #gnb1 cell 3
${5GRU_ANT6}     ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}    #gnb1 cell 3
${4GRU_ANT7}     ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}    #enb
${4GRU_ANT8}     ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}    #enb
${5GRU_ANT9}     ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}    #gnb2 cell 1
${5GRU_ANT10}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}    #gnb2 cell 1
${5GRU_ANT11}    ${tl.gnbs[1].dus[0].rus[1].attenuation_ports[0].port_no}    #gnb2 cell 2
${5GRU_ANT12}    ${tl.gnbs[1].dus[0].rus[1].attenuation_ports[1].port_no}    #gnb2 cell 2
##PA
@{PA_value}    ${25}    ${50}    ${30}    ${0}    ${120}    #int list
#${att_ipaddr}               ${tl.attenuator[0].ip_addr}
#${att_api_port}             ${tl.attenuator[0].port}
@{att_connection_port}      ${5GRU_ANT1}    ${5GRU_ANT2}    ${5GRU_ANT3}    ${5GRU_ANT4}    ${5GRU_ANT5}    ${5GRU_ANT6}
...         ${4GRU_ANT7}    ${4GRU_ANT8}    ${5GRU_ANT9}    ${5GRU_ANT10}    ${5GRU_ANT11}     ${5GRU_ANT12}
${HBTE_max_value}           ${127}
${vendor}                    ${tl.attenuator[0].vendor}
${model}                     ${tl.attenuator[0].model}

${dxdata2}    ${tl.ues[0].pdn[0]}
${mdrb_apn_name}    ${tl.ues[0].pdn[1]}
${mdrb1_apn_name}    ${tl.ues[0].pdn[2]}

${X75_dxdata2_location}    959 940
${X75_mdrb_location}    959 1152
${X75_mdrb1_location}    959 1350

${ue_type}                  ${tl.ues[0].capabilities[0]}

@{cell_id}    0    1    2    3    4    5
@{cell_id_348}    0    1    2    3    4    5    6
@{multi_gnb_PA}    ${5}    ${15}    ${40}    ${0}    ${35}    ${127}    ${26}    ${30}    ${25}    ${10}    ${20}    ${40}    ${45}    ${30}
...    ${50}    ${2}
${att_ipaddr}    ${tl.attenuator[0].ip_addr}
${att_api_port}    ${tl.attenuator[0].port}
${att_api_model}    ${tl.attenuator[0].model}
#${vendor}                    HBTE
${max_attenuation_value}     ${127}

##gnb1 cell1 p9p10
#${5Gcell1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
#${5Gcell1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
#${5Gcell2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
#${5Gcell2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
#${5Gcell3_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
#${5Gcell3_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
#${5Gcell3_ANT3}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}
#${5Gcell3_ANT4}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}
#${5Gcell4_ANT1}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}    #gnb2 cell1
#${5Gcell4_ANT2}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}    #gnb2 cell1
#${4Gcell1_ANT1}    ${tl.gnbs[1].dus[0].rus[1].attenuation_ports[0].port_no}
#${4Gcell1_ANT2}    ${tl.gnbs[1].dus[0].rus[1].attenuation_ports[1].port_no}

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

${gnb_path}    /tmp/



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
[1]CB005876_001_Successful_Inter-Rat_handover_based_on_B2_measure_with_data_forwarding
    [Documentation]    Test case description the gNB behavior when the UE sends a B2 measurement report and the gNB triggers
    ...                a handover to a only LTE Neighbour Cell which has been configured
    [Tags]    CRT_21B   0.800    CRT_22R2   CB005876    CRT_22R3    CRT_TRUNK    CRT_22R4    CRT_23R1
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    AlarmWatchdog.add_allow_alarms    fault_id=7311
    Check UE device status with adb recover    ue_index=${0}
#    Check UE device status with adb recover    ue_index=${1}
    IF    ${enb_instance} == ${enb_ids}[1]    #Tl348
        Online modify parmeters
        ...    parameters_to_update=${PARAMS_TO_MODIFY_CB005876_001_gnb1}    gnb_index=${0}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[3]
    ELSE IF    ${enb_instance} == ${enb_ids}[2]    #Tl383
        Online modify parmeters
        ...    parameters_to_update=${PARAMS_TO_MODIFY_CB005876_001_gnb1}    gnb_index=${0}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[3]
    END
    Check UE device exist
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=default
    Wait Until Keyword Succeeds    3x    10s    Run Keywords
    ...    set apn mdrb
    ...    AND    make WA with Samsung S21
    checking type of system board on gnb1
    UE attach and check
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}M    duration=${duration}    ue_index=${0}
    ...    iperf_port=${dl_port}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}M    duration=${duration}    ue_index=${0}
    ...    iperf_port=${specail_port}
    AlarmWatchdog.add_allow_alarms    fault_id=61641
    midify PA trriger HO to enb
#    Stop capture syslog via btslog on ute
    AlarmWatchdog.remove_allow_alarms    fault_id=61641
    Check pdusession in HO command     logname=${nglogname1}    message_filter=${gnb_filter1}
    Check HO require in enb     logname=${nglogname1}    message_filter=${enb_filter1}
    Check NO release in enb    logname=${nglogname1}    message_filter=${enb_filter2}
    Check counter in source gnb
    Check counter in source gnb about multi-DRB
    Check endmaker in log    logname=${epc_log_path}${NG-U_log}    message_filter=${end_maker}    message_filter1=${not_end_maker2}
    [Teardown]    Run Keywords
    ...           robot_common_operations.Common Case Teardown
    ...           AND    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    ...           AND    AlarmWatchdog.remove_allow_alarms    fault_id=6327
    ...           AND    AlarmWatchdog.remove_allow_alarms    fault_id=7311
    ...           AND    Run Keyword And Ignore Error    coam.teardown    connection=Local gnb1
    ...           AND    Teardown for unlock cell
#    ...           AND    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute
    ...           AND    change pa value to recover
    ...           AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#    ...           AND    get and analysis syslog

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
    ...    Check_RF_Log=True

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



UE attach and check
    Start capture gNB log on master    filename=${attach_log}
    UE attach successfully
    Run Keyword If    ${enb_instance} == ${enb_ids}[0]  # TL358
    ...    Set Test Variable    ${specail_port}    ${specail_port_list}[0]
    ...    ELSE IF    ${enb_instance} == ${enb_ids}[1]  # TL348
    ...    Set Test Variable    ${specail_port}    ${specail_port_list}[1]
    ...    ELSE IF    ${enb_instance} == ${enb_ids}[2]  # TL383
    ...    Set Test Variable    ${specail_port}    ${specail_port_list}[2]
    [Teardown]    Stop and download Logs on gNB on master    filename=${attach_log}


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
    RUN KEYWORD IF    ${enb_instance} != ${enb_ids}[0]
    ...    run keywords    Set Suite Variable    ${close_task}    538 1874
    ...    AND    set apn with special method    usedapn=${dxdata2_apn_348}    location_apn=${click_access_point}
    ...    ELSE    set apn to wap2    usedapn=${dxdata2_apn}

set apn mdrb
    RUN KEYWORD IF    ${enb_instance} != ${enb_ids}[0]
    ...    run keywords    Set Suite Variable    ${close_task}    538 1874
    ...    AND    set apn with special method    usedapn=${wuxuapn_348}    location_apn=${click_access_point}
    ...    ELSE    set apn to wap2    usedapn=${wuxuapn}

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

Teardown for unlock cell
    IF    ${enb_instance} == ${enb_ids}[1]
        Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB005876_001_gnb1_recover}    gnb_index=${0}
    ELSE IF    ${enb_instance} == ${enb_ids}[2]
        Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB005876_001_gnb1_recover}    gnb_index=${0}
    END

Set default PA value for gnb1 MultiRat cases
    [Arguments]      ${value_1}=${value_1}    ${value_2}=${value_2}    ${value_3}=${value_3}    ${value_4}=${value_4}
    ...    ${value_5}=${value_5}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                gnb1 cell2 to 0db,  cell1 120db,cell3 120db
    ...                value_1:cell2 P3P4 value_2:cell1 P1P2 value_3:cell3 P5P6 value_4:enb P7P8
     Adjust the attenuation value for gnb1 Multi HBTE
     ...    value_1=${value_1}     value_2=${value_2}    value_3=${value_3}    value_4=${value_4}    value_5=${value_5}

Adjust the attenuation value for gnb1 Multi HBTE
    [Arguments]      ${value_1}=${value_1}    ${value_2}=${value_2}    ${value_3}=${value_3}    ${value_4}=${value_4}
    ...    ${value_5}=${value_5}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
    ...                if connect on local plz disconnect firstly
    ...                value_1:cell2 P3P4 value_2:cell1 P1P2 value_3:cell3 P5P6 value_4:enb P7P8
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    ...    model=${model}
    att.set_attenuation     port=${5GRU_ANT1}    value=${value_2}
    att.set_attenuation     port=${5GRU_ANT2}    value=${value_2}
    att.set_attenuation     port=${5GRU_ANT3}    value=${value_1}
    att.set_attenuation     port=${5GRU_ANT4}    value=${value_1}
    att.set_attenuation     port=${5GRU_ANT5}    value=${value_3}
    att.set_attenuation     port=${5GRU_ANT6}    value=${value_3}
    att.set_attenuation     port=${5GRU_ANT9}    value=${value_5}
    att.set_attenuation     port=${5GRU_ANT10}    value=${value_5}
    att.set_attenuation     port=${4GRU_ANT7}    value=${value_4}
    att.set_attenuation     port=${4GRU_ANT8}    value=${value_4}
    ${value_port1}    att.read_attenuation    port=${5GRU_ANT1}
    should be equal    ${value_port1}    ${value_2}
    ${value_port2}    att.read_attenuation    port=${5GRU_ANT2}
    should be equal    ${value_port2}    ${value_2}
    ${value_port3}    att.read_attenuation    port=${5GRU_ANT3}
    should be equal    ${value_port3}    ${value_1}
    ${value_port4}    att.read_attenuation    port=${5GRU_ANT4}
    should be equal    ${value_port4}    ${value_1}
    ${value_port5}    att.read_attenuation    port=${5GRU_ANT5}
    should be equal    ${value_port5}    ${value_3}
    ${value_port6}    att.read_attenuation    port=${5GRU_ANT6}
    should be equal    ${value_port6}    ${value_3}
    ${value_port7}    att.read_attenuation    port=${4GRU_ANT7}
    should be equal    ${value_port7}    ${value_4}
    ${value_port8}    att.read_attenuation    port=${4GRU_ANT8}
    should be equal    ${value_port8}    ${value_4}
    ${value_port9}    att.read_attenuation    port=${5GRU_ANT9}
    should be equal    ${value_port9}    ${value_5}
    ${value_port10}    att.read_attenuation    port=${5GRU_ANT10}
    should be equal    ${value_port10}    ${value_5}

get counter path for per tl
    Run Keyword If    '${check_result}' != 'True'
    ...    Set Suite Variable    ${path_NNGCC_IRATHO}    BTS/BTS/NRBTS-${tl.gnbs[0].instance_id}/NRPFW
    ...    ELSE    Set Suite Variable    ${path_NNGCC_IRATHO}
    ...    BTS/MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}/NRPFW

teardown for case
    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${nglogname1}
    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${attach_log}
    Run Keyword And Ignore Error    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl     iperf_port=${dl_port}
    Run Keyword And Ignore Error     power_ue.Stop traffic     ue_type=${ue_type}     direction=dl     iperf_port=${specail_port}
    Wait Until Keyword Succeeds    3x    10s   set apn dxdata2
    power_ue.UE Detach    ue_type=${ue_type}

Check pdusession in HO command
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${ngap_qosflow}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.qosFlowIdentifier
    should not be empty    ${ngap_qosflow[0]}
    ${ngap_GTPtunnel}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.gTP_TEID
    should not be empty    ${ngap_GTPtunnel[0]}

Check HO require in enb
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${s1ap_tac}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//s1ap.tAC
    should not be empty    ${s1ap_tac}

Check NO release in enb
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${UEContext_Release_Value}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//s1ap.procedureCode
    should be empty    ${UEContext_Release_Value}

Check removed A2 and configured A1/B2 in the RRC message
    [Arguments]    ${log_name}    ${message_filter}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${event_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${A2_Event}=     cap.get_field_value_by_xpath    pdml_list=${event_packets}    xpath=.//nr-rrc.measId
    should not contain    ${A2_Event}    1
    ${A1_Event}=     cap.get_field_value_by_xpath    pdml_list=${event_packets}    xpath=.//nr-rrc.eventId
    should contain    ${A1_Event}    0
    ${B2_Event}=     cap.get_field_value_by_xpath    pdml_list=${event_packets}    xpath=.//nr-rrc.eventId
    should contain    ${A1_Event}    1
    ${Hysteresis}=     cap.get_field_value_by_xpath    pdml_list=${event_packets}    xpath=.//nr-rrc.hysteresis
    should be equal    ${Hysteresis[1]}    0
    ${TimeToTrigger}=     cap.get_field_value_by_xpath    pdml_list=${event_packets}    xpath=.//nr-rrc.timeToTrigger
    should be equal    ${TimeToTrigger[1]}    9

Check counter in source gnb
    [Arguments]    ${gnb_index}=${0}
    CB006112_common_keywords.Record the counter action timer
    Check PM counter Result    counter_id=${counter_id}[2]     dic_path=${path_NNGCC_IRATHO}    gnb_index=${gnb_index}   counter_increase=false
    Check PM counter Result    counter_id=${counter_id}[3]     dic_path=${path_NNGCC_IRATHO}    gnb_index=${gnb_index}    counter_increase=false
    Check PM counter Result    counter_id=${counter_id}[4]     dic_path=${path_NNGCC_IRATHO}    gnb_index=${gnb_index}    counter_increase=false
    Check PM counter Result    counter_id=${counter_id}[5]     dic_path=${path_NNGCC_IRATHO}    gnb_index=${gnb_index}    counter_increase=false
#    Run Keyword If    ${enb_instance} != @{enb_ids}[2]    Run Keywords
#    ...    Check PM counter Result    counter_id=@{counter_id}[0]     dic_path=${path_NNGCC_IRATHO}    gnb_index=${gnb_index}
#    ...    AND    Check PM counter Result    counter_id=@{counter_id}[1]    dic_path=${path_NNGCC_IRATHO}    gnb_index=${gnb_index}
#    ...    ELSE    Run Keywords
#    ...    Check PM counter Result    counter_id=@{counter_id}[0]     dic_path=${path_NNGCC_IRATHO}    gnb_index=${gnb_index}
#    ...    counter_increase=false
#    ...    AND    Check PM counter Result    counter_id=@{counter_id}[1]    dic_path=${path_NNGCC_IRATHO}    gnb_index=${gnb_index}
#    ...    counter_increase=false
    Run Keywords
    ...    Check PM counter Result    counter_id=${counter_id}[0]     dic_path=${path_NNGCC_IRATHO}    gnb_index=${gnb_index}
    ...    AND    Check PM counter Result    counter_id=${counter_id}[1]    dic_path=${path_NNGCC_IRATHO}    gnb_index=${gnb_index}

Check counter in source gnb about multi-DRB
    [Arguments]    ${gnb_index}=${0}
    CB006112_common_keywords.Record the counter action timer
    Check PM counter Result    counter_id=${counter_id2}[2]     dic_path=${path_NNGCC_IRATHO}    gnb_index=${gnb_index}   counter_increase=false
    Check PM counter Result    counter_id=${counter_id2}[3]     dic_path=${path_NNGCC_IRATHO}    gnb_index=${gnb_index}    counter_increase=false
    Check PM counter Result    counter_id=${counter_id2}[4]     dic_path=${path_NNGCC_IRATHO}    gnb_index=${gnb_index}    counter_increase=false
    Check PM counter Result    counter_id=${counter_id2}[5]     dic_path=${path_NNGCC_IRATHO}    gnb_index=${gnb_index}    counter_increase=false
    Run Keywords
    ...    Check PM counter Result    counter_id=${counter_id2}[0]     dic_path=${path_NNGCC_IRATHO}
    ...    gnb_index=${gnb_index}    counter_increase=false
    ...    AND    Check PM counter Result    counter_id=${counter_id2}[1]    dic_path=${path_NNGCC_IRATHO}
    ...    gnb_index=${gnb_index}    counter_increase=false

Prepare env with cell on air
    ${sw_version}=    Get sagnb version for selenium
    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
    Perform full commission for COAM SA gnb    scf=${SCF_path}${tl_gnb1_scf_${sw_version}}    gnb_ip=${asik_addr}
#    Perform full commission for COAM SA gnb    scf=${SCF_path}${SCF_file_name_1}    gnb_ip=${asik_addr}
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    connection=gnb1
    Wait until keyword succeeds    30 min    60 sec   verify all cells should be onair    connection=gnb1
    [Teardown]    COAM Teardown gnb connections    connection=gnb1
#    Run Keyword And Ignore Error    Set gnb2 ru pa value    value_1=${120}    value_2=${120}    value_3=${120}    value_4=${120}
#    recovery PA for origin on gnb1    value_3=${120}    value_4=${120}

set apn to wap2
    [Arguments]    ${usedapn}=${wap2apn}    ${ue_index}=${0}
    Set Suite Variable    ${apnset1}    ${usedapn}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb shell input swipe ${swipe}    connection=cygwin
    sleep   4s
    csn.send_command    command=adb shell am start -a android.settings.APN_SETTINGS     connection=cygwin
    sleep   2s
    csn.send_command    command=adb shell input tap ${apnset1}    connection=cygwin
    sleep   8s
    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
    ...    close_task=${close_task}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=cygwin

midify PA trriger HO to enb
    [Arguments]   ${target_file_name}=${epc_log_path}${NG-U_log}
#    Start Capture Wireshark Logs on gNB    nglogname=${nglogname1}    interface=${gnb1_interface_name}
    Start capture gNB log on master    filename=${nglogname1}
    sleep    15s
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    connection=gnb1
    coam.start ip capture file
    ...                             measurement_point=NE_Terminated
    ...                             uplane_capturing=true
    ...                             password=${EMPTY}
    ...                             timeout=120
    ...                             connection=gnb1
    #    # gnb1 cell3 to 0db,cell1 120db,cell2 120db, enb cell 0db
#    Set default PA value for gnb1 MultiRat cases    value_1=@{PA_value}[4]    value_2=@{PA_value}[4]
#    ...    value_3=@{PA_value}[3]    value_4=@{PA_value}[3]    value_5=@{PA_value}[4]
    IF    ${enb_instance} == ${enb_ids}[1]    #Tl348
        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[3]    value=${multi_gnb_PA}[3]
    #    recovery PA for origin on gnb1
        Sleep    5s
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[2]    ip_addr=${att_ipaddr_1}
    ELSE IF    ${enb_instance} == ${enb_ids}[2]    #Tl383
        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[3]    value=${multi_gnb_PA}[3]
    #    recovery PA for origin on gnb1
        Sleep    5s
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[2]    ip_addr=${att_ipaddr_1}
    END
#    sleep    2s
#    Run Keyword If    ${enb_instance} == @{enb_ids}[1]    # TL348 target value 35
#    ...    add attenuation for 5db     port1=${gnb1_ru3_0}    port2=${gnb1_ru3_1}    origin_value=${0}    target_value=${35}
#    ...    ELSE    add attenuation for 5db     port1=${gnb1_ru3_0}    port2=${gnb1_ru3_1}    origin_value=${0}    target_value=${50}
#    # TL383 target value 50
    sleep    3s
    [Teardown]    Run Keywords
    ...    coam.stop ip capture file        connection=gnb1
    ...    AND    coam.generate ip capture file    connection=gnb1
    ...    AND    coam.download ip capture file    target_file_name=${target_file_name}    timeout=240    connection=gnb1
#    ...    AND    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname1}
    ...    AND    Stop and download Logs on gNB on master    filename=${nglogname1}
    ...    AND    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl     iperf_port=${dl_port}
    ...    AND    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl     iperf_port=${specail_port}
    ...    AND    sleep    5
    ...    AND    coam.teardown    connection=gnb1

add attenuation for 5db
    [Arguments]    ${port1}    ${port2}    ${origin_value}    ${target_value}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${port1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    att.set_attenuation     port=${port1}    value=${origin_value}
    att.set_attenuation     port=${port2}    value=${origin_value}
    ${origin}    Set Variable    ${0}
    ${times}    Evaluate    ${target_value}/${5}
    FOR  ${value}  IN RANGE   ${times}
       ${origin}    evaluate     ${origin}+${5}
       att.set_attenuation     port=${port1}    value=${origin}
       att.set_attenuation     port=${port2}    value=${origin}
       sleep    1s
    END


Set gnb2 ru pa value
    [Arguments]    ${value_1}=${0}    ${value_2}=${0}    ${value_3}=${0}    ${value_4}=${0}
    adjust HBTE attenuation    value_1=${value_1}    value_2=${value_2}    value_3=${value_3}    value_4=${value_4}
    ...     att_port1=${gnb2_ru1_0}    att_port2=${gnb2_ru1_1}    att_port3=${gnb2_ru2_0}    att_port4=${gnb2_ru2_1}
    adjust HBTE attenuation    value_1=${value_1}    value_2=${value_2}    value_3=${value_3}    value_4=${value_4}
    ...     att_port1=${gnb1_ru1_0}    att_port2=${gnb1_ru1_1}    att_port3=${gnb1_ru2_0}    att_port4=${gnb1_ru2_1}

recovery PA for origin on gnb1
    [Arguments]     ${value_1}=${0}    ${value_2}=${0}    ${value_3}=${0}    ${value_4}=${0}
    adjust HBTE attenuation    value_1=${value_1}    value_2=${value_2}    value_3=${value_3}    value_4=${value_4}
    ...     att_port1=${gnb1_ru3_0}    att_port2=${gnb1_ru3_1}    att_port3=${enb_0}    att_port4=${enb_1}

Check phone attach successfully on SA env two times
     ${UE_status}    run keyword and return status    Check phone attach successfully on SA env
     run keyword if     '${UE_status}'=='False'    Check phone attach successfully on SA env

Check endmaker in log
    [Arguments]    ${logname}    ${message_filter}    ${message_filter1}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_X}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    @{end_frame_time}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//frame.number
#    ${end_frame_time}=    convert_to_number    ${end_frame_time[-1]}
    ${end_frame_times}=    convert_to_number    ${end_frame_time}[-1]
    ${all_packets}=    cap.load_pcap_file    pcap_file=${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_Z}
    ${filter_expression1}=     Catenate    ${message_filter1}
    ${filtered_packets1}=    cap.filter_packets_by_expression    filter_expression=${filter_expression1}
    @{udp_frame_time}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets1}
    ...                                                xpath=.//frame.number
#    ${udp_frame_time}=    convert_to_number    ${udp_frame_time[-1]}
    ${udp_frame_times}=    convert_to_number    ${udp_frame_time}[-1]
#    Should Be True     ${end_frame_times} > ${udp_frame_times}

Check IE in attach log
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    @{fiveQI}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.fiveQI
     Should Contain     ${fiveQI}    6

Common Suite Setup for COAM
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}

#Common Suite Teardown for COAM
#    [Arguments]    ${gnb_index}=${0}
#    Connect to gnb coam via ssl    connection=gnb${gnb_index}    bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
#    COAM Save snapshot via rest api    connection=gnb${gnb_index}    timeout=900
#    coam.teardown    connection=gnb${gnb_index}

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

Set the Attenuation Value
    [Arguments]    ${ports}    ${value}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${ports}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${att_api_model}
    att.set_attenuation     port=${ports}    value=${value}

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

change pa value to recover
    IF    ${enb_instance} == ${enb_ids}[1]    #Tl348
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[5]    ip_addr=${att_ipaddr_1}
        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[5]
    ELSE IF    ${enb_instance} == ${enb_ids}[2]    #Tl383
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[5]    ip_addr=${att_ipaddr_1}
        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[5]
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
