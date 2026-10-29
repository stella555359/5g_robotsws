*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB008698-A    CB008698-B    CB008698-C    CB008698-F

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup
...            AND    Common Suite Setup for COAM
...            AND    Get gnb release info
...            AND    Get sagnb version for selenium
...            AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
#...            AND    Set Suite Variable    ${tl_gnb2_scf_${sw_version}}    ${sw_version}_gNB2_Golden_SCF.xml
#...            AND    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=True    scf_path=${scf_path}
#...                                          golden_scf_name=${tl_gnb1_scf_${sw_version}}    golden_scf_name_gnb2=${tl_gnb2_scf_${sw_version}}
...            AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_gnb1_scf_${sw_version}}
...            AND    Lock x2link on ENB side for SA
...            AND    Common UE parameter setup

Suite Teardown     Run Keywords
...            Unlock x2link on ENB side
...            AND    Common Suite Teardown for COAM    gnb_list=${gnb_list}


Resource     Resources/CB008698_common_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot


*** Variables ***
${log_name_A_004_0}    log_name_A_004_0.pcap
${log_name_A_004_1}    log_name_A_004_1.pcap
${log_name_A_004_2}    log_name_A_004_2.pcap
${log_name_A_004_3}    log_name_A_004_3.pcap
${log_name_A_004_4}    log_name_A_004_4.pcap
${log_name_A_004_5}    log_name_A_004_5.pcap
${log_name_A_004_6}    log_name_A_004_6.pcap
${log_name_A_004_7}    log_name_A_004_7.pcap
${enb_log_name_A_004_1}    enb_log_name_A_004_1.pcap
${enb_log_name_A_004_2}    enb_log_name_A_004_2.pcap
${log_name_A_006_00}    log_name_A_006_00.pcap
${log_name_A_006_01}    log_name_A_006_01.pcap
${log_name_A_006_1}    log_name_A_006_1.pcap
${log_name_A_006_2}    log_name_A_006_2.pcap
${log_name_A_006_3}    log_name_A_006_3.pcap
${log_name_B_005_1}    log_name_B_005_1.pcap
${log_name_B_005_2}    log_name_B_005_2.pcap
${log_name_B_005_3}    log_name_B_005_3.pcap
${log_name_B_005_4}    log_name_B_005_4.pcap
${log_name_B_005_5}    log_name_B_005_5.pcap
${log_name_B_005_eNB}    log_name_B_005_eNB.pcap
${log_name_B_012_1}    log_name_B_012_1.pcap
${log_name_B_012_2}    log_name_B_012_2.pcap
${log_name_B_012_3}    log_name_B_012_3.pcap
${log_name_B_012_4}    log_name_B_012_4.pcap
${log_name_B_012_5}    log_name_B_012_5.pcap
${log_name_B_012_6}    log_name_B_012_6.pcap
${log_name_C_003_00}    log_name_C_003_00.pcap
${log_name_C_003_1}    log_name_C_003_1.pcap
${log_name_C_003_01}    log_name_C_003_01.pcap
${log_name_C_003_02}    log_name_C_003_02.pcap
${log_name_C_003_2}    log_name_C_003_2.pcap
${log_name_C_003_3}    log_name_C_003_3.pcap
${log_name_C_003_4}    log_name_C_003_4.pcap
${log_name_C_003_5}    log_name_C_003_5.pcap
${log_name_C_005_1}    log_name_C_005_1.pcap
${log_name_C_005_2}    log_name_C_005_2.pcap
${log_name_C_005_3}    log_name_C_005_3.pcap
${log_name_C_005_4}    log_name_C_005_4.pcap
${log_name_F_006_1}    log_name_F_006_1.pcap
${log_name_F_006_2}    log_name_F_006_2.pcap
${log_name_F_006_3}    log_name_F_006_3.pcap
${log_name_F_006_4}    log_name_F_006_4.pcap
${log_name_F_006_5}    log_name_F_006_5.pcap
${enb_log_name_F_006_1}    enb_log_name_F_006_1.pcap
${log_name_D_001_attach01}     log_name_D_001_attach01.pcap
${log_name_D_001_attach02}     log_name_D_001_attach02.pcap
${log_name_D_001_1}    log_name_D_001_1.pcap
${log_name_D_001_11}    log_name_D_001_11.pcap
${log_name_D_001_2}    log_name_D_001_2.pcap
${log_name_D_001_3}    log_name_D_001_3.pcap
${log_name_D_001_4}    log_name_D_001_4.pcap
${log_name_D_001_5}    log_name_D_001_5.pcap
${log_name_D_001_6}    log_name_D_001_6.pcap
${log_name_D_001_7}    log_name_D_001_7.pcap
${log_name_D_010_1}    log_name_D_010_1.pcap
${log_name_D_010_11}    log_name_D_010_11.pcap
${log_name_D_010_2}    log_name_D_010_2.pcap
${log_name_D_010_3}    log_name_D_010_3.pcap
${log_name_D_010_4}    log_name_D_010_4.pcap

@{ue_type}    huawei    samsung

@{ARP_priorityLevel}    1    2    3
@{apn_location}    168 681    168 873    146 717    140 513    93 941    93 743    142 912    168 1073

#${att_ipaddr_36721}    ${tl.attenuator[0].ip_addr}
#${att_ipaddr_911}      ${tl.attenuator[0].ip_addr}
#${att_ipaddr_38221}    ${tl.attenuator[0].ip_addr}
#${att_port_1_36721}     ${tl.attenuator[0].attenuator_ports[1]}
#${att_port_2_36721}     ${tl.attenuator[0].attenuator_ports[2]}
#${att_port_3_36721}     ${tl.attenuator[0].attenuator_ports[3]}
#${att_port_4_36721}     ${tl.attenuator[0].attenuator_ports[4]}
#${att_port_5_36721}     ${tl.attenuator[0].attenuator_ports[5]}
#${att_port_6_36721}     ${tl.attenuator[0].attenuator_ports[6]}
#${att_port_7_36721}     ${tl.attenuator[0].attenuator_ports[7]}
#${att_port_8_36721}     ${tl.attenuator[0].attenuator_ports[8]}

${att_port_1_HBTE}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_2_HBTE}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_3_HBTE}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${att_port_4_HBTE}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${att_port_5_HBTE}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_6_HBTE}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_7_HBTE}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${att_port_8_HBTE}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${att_ipaddr_HBTE}    ${tl.attenuator[0].ip_addr}

@{diffTL_enb_ID}    36721    38221    911
@{ngap_priorityLevelARP_value}    6    7    8    9
@{PA_list}    ${0}    ${127}    ${40}    ${25}    ${30}    ${50}    ${10}

@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${wap2_apn_name}    ${tl.ues[0].pdn[0]}
${mdrb_apn_name}    ${tl.ues[0].pdn[1]}
${zwap1.nokia.com}    ${tl.ues[0].pdn[2]}
${zzmdrbxj.nokia.com}    ${tl.ues[0].pdn[3]}
${zzzmdrb1}    ${tl.ues[0].pdn[4]}
${ue_type3}    ${tl.ues[2].capabilities[2]}


${sys_logs_path}    /tmp/btslog2/
${UTE_logs_path}    /home/ute/ERR_WRN_logs/
${testline_name}          null
${base_file}    None
@{filter_list}    None

${Test_PC_IP}          ${tl.test_pc.default_ssh_connection_details.addr}
${Test_PC_username}    ${tl.test_pc.default_ssh_connection_details.username}
${Test_PC_password}    ${tl.test_pc.default_ssh_connection_details.password}

@{allow_fault_list}    2923    2922    7523    62001    7107

${MRBTS_ID}    ${tl.gnbs[0].instance_id}

*** Test Cases ***
[1]CB008698-D_010_Intra-gNB_handover_based_on_nonEC_DRB_preemption_SA_numOfRadioResReservForTempUse_fully_used
    [Documentation]    This user scenario describes Initial Context Setup procedure where AMF requests
    ...    for PDU sessions(no NSA user present in the cell, so instead, an SA UE context is selected for preemption)
    [Tags]    CB008698-d    CDRT_TRUNK    CIT_22R4
    [Timeout]    1 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7107
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    ${release_info}    Get sagnb release
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    Online modify parmeters     parameters_to_update=${PARAM_8698_gnb1_D_010}
    check Redirect status
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    Comment    UE2 attach on gnb1 cell1
    Huawei UE setup    ue_type=${ue_type}[0]    ue_index=${1}
    Wait Until Keyword Succeeds    3x    10s    make UE attach successful 1 times with D010
    Comment    UE2 make VoNR
    Start capture gNB log on master    filename=${log_name_D_010_11}
    Step2: UE setup VoNR call    ue_index=${1}
    sleep    20s
    check voice call status    ue_index=${1}    status=${2}
    Stop and download Logs on gNB on master    filename=${log_name_D_010_11}
    Comment    set gnb1 cell2 PA to 0
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...                                                        Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${5}    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...                                                        Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${10}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...                                                        Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    Start capture gNB log on master    filename=${log_name_D_010_2}
    Comment    UE1 attach on gnb2 cell1
    Step1: UE attach    ue_type=${ue_type}[0]    ue_index=${0}
    Comment    UE1 make VoNR
    Step2: UE setup VoNR call    ue_index=${0}
    sleep    20s
    check voice call status    ue_index=${0}    status=${2}
    Stop and download Logs on gNB on master    filename=${log_name_D_010_2}
    Prepare with PM counter time to caculate    period=start
    Sleep    1m    reason=need to wait 1 min to trigger counter so that counter will be into next counter loop
    Start capture gNB log on master    filename=${log_name_D_010_3}
    Comment    set gnb1 cell2 PA to 25 HO to gnb1 cell1
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation
    ...    gnb1_cell1_value=${0}    gnb1_cell2_value=${30}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation
    ...    gnb1_cell1_value=${0}    gnb1_cell2_value=${33}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation
    ...    gnb1_cell1_value=${0}    gnb1_cell2_value=${25}
    sleep    20s
    Stop and download Logs on gNB on master    filename=${log_name_D_010_3}
    Start capture gNB log on master    filename=${log_name_D_010_4}
    sleep  5s
    Step3: UE hang up VoNR call    ue_index=${0}
    sleep  20s
    Step3: UE hang up VoNR call    ue_index=${1}
    sleep  20s
    Stop and download Logs on gNB on master    filename=${log_name_D_010_4}
    Prepare with PM counter time to caculate    period=end
    Check wireshark log for D010_1
    Check wireshark log for D010_2
    Check wireshark log for D010_4
    Check intragNB interFre HO process on gNB    logname=${log_name_D_010_3}
    Run Keyword If    '${release_info}' == '${branch}[0]'    Check counter for D010
    ...    ELSE IF    '${release_info}' == '${branch}[1]'    Check counter for D010
    ...    ELSE IF    '${release_info}' == '${branch}[2]'    Check counter for D010
    ...    ELSE    Check trunk counter for D010
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    AlarmWatchdog.remove_allow_alarms    fault_id=${allow_fault_list}    AND
    ...    Step3: UE hang up VoNR call    ue_index=${0}    AND
    ...    check voice call status    ue_index=${0}    status=${0}    AND
    ...    Step4: Detach UE    ue_index=${0}    ue_type=${ue_type}[0]    AND
    ...    Step3: UE hang up VoNR call    ue_index=${1}    AND
    ...    check voice call status    ue_index=${1}    status=${0}    AND
    ...    Step4: Detach UE    ue_index=${1}    ue_type=${ue_type}[0]    AND
    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_010_1}    AND
    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_010_11}    AND
    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_010_2}    AND
    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_010_3}    AND
    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_010_4}    AND
    ...    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot    AND
    ...    Adjust HBTE gNB_eNB_RU Attenuation    AND
    ...    Online modify parmeters    parameters_to_update=${PARAM_8698_recover_gnb1_D_010}    AND
    ...    Stop capture syslog via btslog on ute    AND
    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown    AND
    ...    get and analysis syslog

#[1]CB008698-D_001_Inter-gNB_handover_based_on_GBRandNonGBR_DRB_preemption_SA
#    [Documentation]    This user scenario describes Initial Context Setup procedure where AMF requests
#    ...    for PDU sessions(no NSA user present in the cell, so instead, an SA UE context is selected for preemption)
#    [Tags]    CB008698-d    CRT_TRUNK    CRT_22R4
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=7107
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
##    ${release_info}    Get sagnb release
#    Comment    20230515 A004 merger D001,gnb1 target modify maxNumOfRrcSA and maxNumOfUsersNRCell =1
##    Comment    20230609 from NIDD:2.05.2023 [WSO - 61467682] CB008717-5G-DA: Status changed from Proposal to Not Used since this parameter
##    ...    is replaced by NRCELL.maxNumOfUsersPerNRCell [SPCId=66616],
##    ...   link:http://esnidd055.emea.nsn-net.net/NIDD/CM/Parameter/ViewEdit/2022215?vId=414&pId=70301&crntPkgId=70301#/back
#    Comment    from 2023/11/24 run 23R4/24R1/TRUNK all NIDD is the same,but run 23R3 need create a new branch to modify NIDD
#    Set Suite Variable    ${release_flag}    ${release_info.split('_')[2]}
#    IF    '${release_flag}' == '0000'
#        Online modify parmeters    parameters_to_update=${PARAM_8698_Targetgnb1_D_001_maxNumOfUsersNRCell}
#    ELSE
#        IF    '${enb_instance}'=='${diffTL_enb_ID}[0]'    #TL367
#            Online modify parmeters     parameters_to_update=${PARAM_8698_Targetgnb1_D_001_maxNumOfUsersPerNRCell}
#        ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    #TL382
#            Online modify parmeters     parameters_to_update=${PARAM_8698_Targetgnb1_D_001_maxNumOfUsersPerNRCell_382}
#        END
#    END
#    Online modify parmeters    gnb_index=${1}    parameters_to_update=${PARAM_8698_Sourcegnb2_D_001}
##    ${gnb2_amf_ip}=    Get value of parameter from SCF file    golden_scf_name=${tl_scf2_${release_info}}
##    ...    dist_name=MRBTS-${tl.gnbs[1].instance_id}/NRBTS-${tl.gnbs[1].instance_id}/SERVEDAMF-1
##    ...    p_name=amfIPAddress
##    ...    scf_path=${scf_path}
##    &{gnb1_amf_para}=    Create Dictionary
##    ...    value=${gnb2_amf_ip}
##    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/SERVEDAMF-1
##    ...    parameter=amfIPAddress
##    ${gnb1_amf_para_list}=    Create List
##    Append To List    list_=${gnb1_amf_para_list}    value=${gnb1_amf_para}
##    Online modify parmeters    gnb_index=${0}    parameters_to_update=${gnb1_amf_para_list}
#    check Redirect status
#    Comment    prepare set gnb2 cell PA to 0 and SDX65 or S21 attach gnb2 cell
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb2_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb2_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb2_cell1_value=${0}
#    Comment    UE3 attach on gnb2 cell1
#    Start capture gNB log on master    filename=${log_name_D_001_attach01}
#    Step1: UE attach    ue_type=${ue_type3}    ue_index=${2}    gnb_index=${1}
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'    make WA with Samsung S21    ue_index=${2}
#    ...    ELSE    Sleep    1s
#    Comment    prepare end and UE3 detach
#    UE.UE Detach     ue_type=${ue_type3}     ue_index=${2}
#    Stop and download Logs on gNB on master    filename=${log_name_D_001_attach01}
#    Sleep    5S
#    Comment    set gnb1 cell2 PA to 0
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${15}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
#    Comment    UE2 attach on gnb1 cell2
#    Start capture gNB log on master    filename=${log_name_D_001_attach02}
#    Huawei UE setup    ue_type=${ue_type}[0]    ue_index=${1}
#    Wait Until Keyword Succeeds    3x    10s    make UE attach successful 1 times with D001
#    Stop and download Logs on gNB on master    filename=${log_name_D_001_attach02}
#    Comment    UE2 make VoNR
#    Start capture gNB log on master    filename=${log_name_D_001_11}
#    Step2: UE setup VoNR call    ue_index=${1}
#    sleep    20s
#    check voice call status    ue_index=${1}    status=${2}
#    Stop and download Logs on gNB on master    filename=${log_name_D_001_11}
#    Comment    set gnb1 cell2 PA to X and gnb2 cell1 PA to 0
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...                                                                gnb1_cell2_value=${20}    gnb2_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...                                                                gnb1_cell2_value=${15}    gnb2_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...                                                                gnb1_cell2_value=${12}    gnb2_cell1_value=${0}
#    Start capture gNB log on master    filename=${log_name_D_001_2}    gNB_index=${1}
#    Comment    merge A004 case,UE1 change to UE3 and make 911 call on gnb2 cell
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
#    ...    S21 UE attach     ue_type=${ue_type3}    ue_index=${2}    gnb_index=${1}
#    ...    ELSE    Attach and check power UE    ue_type=${ue_type3}    ue_index=${2}    gnb_index=${1}
#    Comment    UE3 make EMC
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Step2: UE setup EMC call    ue_index=${2}
#    ...    ELSE    Step2: QCM UE setup EMC call    ue_index=${2}
#    sleep    20s
#    check voice call status    ue_index=${2}    status=${2}
#    Stop and download Logs on gNB on master    filename=${log_name_D_001_2}   gNB_index=${1}
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on master    filename=${log_name_D_001_3}
#    Start capture gNB log on master    filename=${log_name_D_001_4}    gNB_index=${1}
#    check voice call status    ue_index=${2}    status=${2}
#    Comment    set gnb2 cell1 PA to 40 HO to gnb1 cell2
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    gnb1_cell2_value=${20}    gnb2_cell1_value=${15}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    gnb1_cell2_value=${15}    gnb2_cell1_value=${10}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    gnb1_cell2_value=${0}    gnb2_cell1_value=${10}
#    sleep    20s
#    Stop and download Logs on gNB on master    filename=${log_name_D_001_3}
#    Stop and download Logs on gNB on master    filename=${log_name_D_001_4}    gNB_index=${1}
#    Comment    preempt UE keep and normal release on target gnb1 cell2
#    Start capture gNB log on master    filename=${log_name_D_001_5}
#    sleep  5s
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Step3: UE hang up EMC call    ue_index=${2}
#    ...    ELSE    Step3: QCM UE hang up EMC call    ue_index=${2}
#    sleep  20s
#    Stop and download Logs on gNB on master    filename=${log_name_D_001_5}
#    Comment    preempted UE keep and normal release on source gnb2 cell
#    Start capture gNB log on master    filename=${log_name_D_001_6}    gNB_index=${1}
#    sleep  5s
#    Step3: UE hang up VoNR call    ue_index=${1}
#    sleep  20s
#    Stop and download Logs on gNB on master    filename=${log_name_D_001_6}    gNB_index=${1}
#    Prepare with PM counter time to caculate    period=end
#    Check wireshark log for D001_1
#    Check wireshark log for D001_3
#    Check wireshark log for D001_5
#    Check wireshark log for D001_6
#    Check intergNB HO process on source gNB    logname=${log_name_D_001_4}
#    Check intergNB HO process on target gNB    logname=${log_name_D_001_3}
#    Run Keyword If    '${release_info}' == '${branch}[0]'     Check counter for D001
#    ...    ELSE IF    '${release_info}' == '${branch}[1]'     Check counter for D001
#    ...    ELSE IF    '${release_info}' == '${branch}[2]'     Check counter for D001
#    ...    ELSE    Check trunk counter for D001
#    Comment    EDA for 01695254 and 20230515 merger A004 to D001,changer VONR to EMC
#    Step4: Detach UE    ue_index=${1}    ue_type=${ue_type}[0]
#    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
#    Start capture gNB log on master    filename=${log_name_D_001_7}
#    sleep  3s
#    Comment    UE3 make VoNR
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Step2: UE setup EMC call    ue_index=${2}
#    ...    ELSE    Step2: QCM UE setup EMC call    ue_index=${2}
#    sleep    10s
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Step3: UE hang up EMC call    ue_index=${2}
#    ...    ELSE    Step3: QCM UE hang up EMC call    ue_index=${2}
#    sleep  3s
#    Stop and download Logs on gNB on master    filename=${log_name_D_001_7}
#    Check wireshark log for D001_7
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    AlarmWatchdog.remove_allow_alarms    fault_id=${allow_fault_list}    AND
#    ...    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Step3: UE hang up EMC call    ue_index=${2}
#    ...    ELSE    Step3: QCM UE hang up EMC call    ue_index=${2}    AND
#    ...    check voice call status    ue_index=${2}    status=${0}    AND
#    ...    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'    make WA with Samsung S21    ue_index=${2}
#    ...    ELSE    Sleep    1s    AND
#    ...    UE.UE Detach     ue_type=${ue_type3}     ue_index=${2}    AND
#    ...    Step3: UE hang up VoNR call    ue_index=${1}    AND
#    ...    check voice call status    ue_index=${1}    status=${0}    AND
#    ...    Step4: Detach UE    ue_index=${1}    ue_type=${ue_type}[0]    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_001_1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_001_11}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_001_2}    gNB_index=${1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_001_3}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_001_4}    gNB_index=${1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_001_5}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_001_6}    gNB_index=${1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_001_7}    AND
#    ...    Adjust HBTE gNB_eNB_RU Attenuation    AND
#    ...    8698_D01_recover_parameters    AND
##    ...    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Online modify parmeters
##    ...                                        parameters_to_update=${PARAM_8698_recover_Targetgnb1_D_001_maxNumOfUsersNRCell}
##    ...    ELSE    Online modify parmeters     parameters_to_update=${PARAM_8698_recover_Targetgnb1_D_001_maxNumOfUsersPerNRCell}    AND
##    ...    Online modify parmeters     parameters_to_update=${PARAM_8698_recover_Targetgnb1_D_001_maxNumOfUsersPerNRCell}    AND
#    ...    Online modify parmeters    gnb_index=${1}    parameters_to_update=${PARAM_8698_recover_Sourcegnb2_D_001}    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    AND
#    ...    Stop capture syslog via btslog on ute    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown    AND
#    ...    get and analysis syslog

#[1]CB008698-F_006_Intra_gNB_HO_with_partial_admission_Non_GBR_DRB_preemption_SA_in_fully_exhausted_temp_reserve_pool
#    [Documentation]    This user scenario describes intra-gNB intra-DU HO where UE is having one or more
#    ...    PDU sessions with multiple Qos flows and needed count of DRBs is not available in the target cell.
#    [Tags]    CB008698-F    CRT_TRUNK    CRT_22R4
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
##    ${release_info}    Get sagnb release
#    Online add parmeters    parameters_to_update=${PARAM_ADD_8698_F_006}    gnb_index=${0}
#    Online modify parmeters    parameters_to_update=${PARAM_8698_F_006}    gnb_index=${0}
#    check Redirect status
#    Comment    set gnb1 cell1 PA to 0
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    Comment    UE2 attach on gnb1 cell1
#    Huawei UE setup    ue_type=${ue_type}[0]    ue_index=${1}
#    Wait Until Keyword Succeeds    3x    10s    make UE attach successful 1 times with F006
#   Comment    set gnb1 cell2 PA to 0
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    gnb1_cell2_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    gnb1_cell2_value=${10}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    gnb1_cell2_value=${0}
#    Comment    change APN of UE1 to mdrb.nokia.com
#    choice required APN on UE    usedapn=${apn_location}[7]    ue_type=${ue_type}[0]    ue_index=${0}
#    Comment    UE1 attach on gnb1 cell2
#    Wait Until Keyword Succeeds    3x    10s    make UE attach successful 1 times with F006_2
#    Comment    20230808 modify gnb1 cell2 modiffy maxNumOfRrcSA=0 to UE1 release,no need to attach any cell
#    Online modify parmeters    parameters_to_update=${PARAM_8698_F_006_2}    gnb_index=${0}
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on master    filename=${log_name_F_006_2}
#    Start to collect the log on eNB    log_name=${enb_log_name_F_006_1}    interface=br1
#    Comment    set gnb1 cell2 PA from 0 to 30
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    gnb1_cell2_value=${27}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    gnb1_cell2_value=${33}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
#    ...    gnb1_cell2_value=${20}
#    sleep    20s
#    Stop and download Logs on gNB on master    filename=${log_name_F_006_2}
#    Stop and download Logs on eNB    log_name=${enb_log_name_F_006_1}
#    Prepare with PM counter time to caculate    period=end
#    Run Keyword If    '${release_info}' == '${branch}[0]'    Check counter for F006_1
#    ...    ELSE IF    '${release_info}' == '${branch}[1]'    Check counter for F006_1
#    ...    ELSE IF    '${release_info}' == '${branch}[2]'    Check counter for F006_1
##    ...    ELSE    Check trunk counter for F006_1
#    ...    ELSE    Run Keywords
#    ...    Sleep    40s    reason=wait for pm file generated
#    ...    AND    check cell1 counter KPI from pm file    KPI_file=CB008698-F_counters.txt    para_index=${1}
#    ...    AND    check cell2 counter KPI from pm file    KPI_file=CB008698-F_counters.txt    para_index=${2}
#    Check wireshark log for F006_1
#    Check wireshark log for F006_2
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    choice required APN on UE    usedapn=${apn_location}[1]    ue_type=${ue_type}[0]    ue_index=${0}    AND
#    ...    Step4: Detach UE    ue_index=${0}    ue_type=${ue_type}[0]    AND
#    ...    Step4: Detach UE    ue_type=${ue_type}[0]    ue_index=${1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_F_006_1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_F_006_2}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on eNB    log_name=${enb_log_name_F_006_1}    AND
#    ...    Adjust HBTE gNB_eNB_RU Attenuation    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_8698_recover_F_006}    gnb_index=${0}    AND
#    ...    Online delete parmeters    parameters_to_update=${PARAM_DELETE_8698_F_006}    gnb_index=${0}    AND
##    ...    CB008698_common_keywords.check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${2}    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#[1]CB008698_B_012_NG_handover_SA_NSA_non_cell_UE_preemption_with_allowEmergencyReservForTempUse_enable_due_to_maxNumOfRrcCGRPSA_limit
#    [Documentation]    This user scenario describes Initial Context Setup procedure where AMF requests
#    ...    for PDU sessions(no NSA user present in the cell, so instead, an SA UE context is selected for preemption)
#    [Tags]    CB008698-B    CRT_TRUNK    CRT_22R4
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Online modify parmeters     parameters_to_update=${PARAM_8698_Targetgnb1_B_012}
#    Online modify parmeters    gnb_index=${1}    parameters_to_update=${PARAM_8698_Sourcegnb2_B_012}
#    check Redirect status
#    Comment    set UE2 APN to MDRB
#    choice required APN on UE    usedapn=@{apn_location}[2]    ue_type=@{ue_type}[0]    ue_index=${1}
#    Comment    set UE1 APN to MDRB
#    choice required APN on UE    usedapn=@{apn_location}[7]    ue_type=@{ue_type}[0]    ue_index=${0}
#    Comment    set gnb2 cell1 PA to 120 and set gnb1 cell2 PA to 0
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    gnb1_cell2_value=${0}    gnb2_cell1_value=${120}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    gnb1_cell2_value=${0}    gnb2_cell1_value=${120}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    gnb1_cell2_value=${0}    gnb2_cell1_value=${120}
#    Comment    UE2 attach on gnb1 cell2
#    Huawei UE setup    ue_type=@{ue_type}[0]    ue_index=${1}
#    Wait Until Keyword Succeeds    3x    10s    make UE attach successful 1 times with B012
#    Comment    set gnb2 cell1 PA to 10
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    gnb1_cell2_value=${10}    gnb2_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    gnb1_cell2_value=${10}    gnb2_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    gnb1_cell2_value=${12}    gnb2_cell1_value=${0}
#    Start capture gNB log on master    filename=${log_name_B_012_2}    gNB_index=${1}
#    Comment    UE1 attach on gnb2 cell1
#    Step1: UE attach    ue_type=@{ue_type}[0]    ue_index=${0}    gnb_index=${1}
#    Comment    UE1 make VoNR
#    Step2: UE setup VoNR call    ue_index=${0}
#    sleep    20s
#    check voice call status    ue_index=${0}    status=${2}
#    Stop and download Logs on gNB on master    filename=${log_name_B_012_2}   gNB_index=${1}
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on master    filename=${log_name_B_012_3}
#    Start capture gNB log on master    filename=${log_name_B_012_4}    gNB_index=${1}
#    check voice call status    ue_index=${0}    status=${2}
#    Comment    set gnb2 cell1 PA to 45 HO to gnb1 cell2
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    gnb1_cell2_value=${0}    gnb2_cell1_value=${6}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    gnb1_cell2_value=${0}    gnb2_cell1_value=${10}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    gnb1_cell2_value=${0}    gnb2_cell1_value=${25}
#    sleep    20s
#    Stop and download Logs on gNB on master    filename=${log_name_B_012_3}
#    Stop and download Logs on gNB on master    filename=${log_name_B_012_4}    gNB_index=${1}
#    Comment    preempt UE keep and normal release on target gnb1 cell2
#    Start capture gNB log on master    filename=${log_name_B_012_5}
#    sleep  5s
#    Step3: UE hang up VoNR call    ue_index=${0}
#    sleep  20s
#    Stop and download Logs on gNB on master    filename=${log_name_B_012_5}
#    Prepare with PM counter time to caculate    period=end
#    Check wireshark log for 012_1
#    Check wireshark log for 012_3
#    Check wireshark log for 012_5
#    Check intergNB_NGAP HO process on source gNB    logname=${log_name_B_012_4}
#    Check intergNB_NGAP HO process on target gNB   logname=${log_name_B_012_3}
#    Check counter for 012
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    Step3: UE hang up VoNR call    ue_index=${0}    AND
#    ...    check voice call status    ue_index=${0}    status=${0}    AND
#    ...    choice required APN on UE    usedapn=@{apn_location}[3]    ue_type=@{ue_type}[0]    ue_index=${1}    AND
#    ...    choice required APN on UE    usedapn=@{apn_location}[1]    ue_type=@{ue_type}[0]    ue_index=${0}    AND
#    ...    Step4: Detach UE    ue_index=${1}    ue_type=@{ue_type}[0]    AND
#    ...    Step4: Detach UE    ue_index=${0}    ue_type=@{ue_type}[0]    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_012_1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_012_2}    gNB_index=${1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_012_3}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_012_4}    gNB_index=${1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_012_5}    AND
#    ...    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}    enb_cell1_value=${0}    AND
#    ...    Online modify parmeters    gnb_index=${1}    parameters_to_update=${PARAM_8698_recover_Sourcegnb2_B_012}    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_8698_recover_Targetgnb1_B_012}    AND
##    ...    CB008698_common_keywords.check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${2}    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#[1]CB008698-A_004_ICS_when_no_NSA_UE_gNB_operates_in_SA+NSA_mode_preferNsaPreemptio_enable_with_EMC_successfully_due_to_redirect_normal_call_UE
#    [Documentation]    This user scenario describes Initial Context Setup procedure where AMF requests
#    ...    for PDU sessions(no NSA user present in the cell, so instead, an SA UE context is selected for preemption)
#    [Tags]    CB008698-A    CRT_TRUNK    CRT_22R4
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Online add parmeters    parameters_to_update=${PARAM_ADD_8698_A_004_for_precondition}    gnb_index=${0}
#    Online modify parmeters    parameters_to_update=${PARAM_8698_A_004}    gnb_index=${0}
#    Online delete parmeters    parameters_to_update=${PARAM_DELETE_8698_A_004}    gnb_index=${0}
#    Online modify parmeters    parameters_to_update=${PARAM_8698_A_004_2}    gnb_index=${1}
#    check Redirect status
##    Comment    lock enb cell
##    set enb cell for A004    value=@{enb_value}[1]
##    Comment    lock gnb1 cell1
##    Lock cell online coam    gnb_index=${0}    cell_index=${1}
#    Comment    set gnb1 cell2 PA to 120 and set gnb2 cell1 PA to 0
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[1]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[1]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[1]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[1]
#    Comment    change APN of UE3 to mdrb.nokia.com
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Switch APN to muti DRB    ue_index=${2}
#    ...                apn_name=${mdrb_apn_name}    gnb_index=${1}
#    ...    ELSE       S21 switch APN    usedapn=@{apn_location}[4]   ue_index=${2}
#    Comment    UE3 attach on gnb2 cell1
#    Start capture gNB log on master    filename=${log_name_A_004_0}    gNB_index=${1}
#    sleep    2s
#    Attach and check power UE    ue_type=${ue_type3}    ue_index=${2}    gnb_index=${1}
#    sleep    5s
#    Stop and download Logs on gNB on master    filename=${log_name_A_004_0}    gNB_index=${1}
#    sleep    5s
#    Comment    set gnb1 cell2 PA to 0 and set gnb2 cell1 30/40db
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[2]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[4]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[2]    enb_cell1_value=@{PA_list}[1]
#    Comment    UE2 attach on gnb1 cell2
#    Huawei UE setup    ue_type=@{ue_type}[0]    ue_index=${1}
#    Wait Until Keyword Succeeds    3x    10s    make UE attach successful 1 times with A004
#    Comment    set gnb2 cell1 PA to 0
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[1]
#    Start capture gNB log on master    filename=${log_name_A_004_4}
#    Start capture gNB log on master    filename=${log_name_A_004_5}    gNB_index=${1}
#    Comment    UE2 make VoNR
#    Step2: UE setup VoNR call    ue_index=${1}
#    sleep    20s
#    check voice call status    ue_index=${1}    status=${2}
#    Comment    UE3 make EMC
#    Step2: QCM UE setup EMC call    ue_index=${2}
#    sleep    20s
#    check voice call status    ue_index=${2}    status=${2}
#    Stop and download Logs on gNB on master    filename=${log_name_A_004_4}
#    Stop and download Logs on gNB on master    filename=${log_name_A_004_5}    gNB_index=${1}
#    set enb cell for A004
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on master    filename=${log_name_A_004_2}
#    Start capture gNB log on master    filename=${log_name_A_004_3}    gNB_index=${1}
#    Start to collect the log on eNB    log_name=${enb_log_name_A_004_1}    interface=br1
#    check voice call status    ue_index=${2}    status=${2}
#    Comment    set gnb2 cell1 PA to 120
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[1]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[1]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[1]    enb_cell1_value=@{PA_list}[1]
#    sleep    20s
#    Stop and download Logs on gNB on master    filename=${log_name_A_004_2}
#    Stop and download Logs on gNB on master    filename=${log_name_A_004_3}    gNB_index=${1}
#    Stop and download Logs on eNB    log_name=${enb_log_name_A_004_1}
#    Prepare with PM counter time to caculate    period=end
#    Check wireshark log for A004_1
#    Check wireshark log for A004_2
#    Check counter for A004_1
#    check voice call status    ue_index=${2}    status=${2}
#    Start capture gNB log on master    filename=${log_name_A_004_6}
#    Step3: QCM UE hang up EMC call    ue_index=${2}
#    check voice call status    ue_index=${2}    status=${0}
#    Stop and download Logs on gNB on master    filename=${log_name_A_004_6}
#    Check wireshark log for A004_3
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Step3: UE hang up VoNR call    ue_index=${1}    AND
#    ...    check voice call status    ue_index=${1}    status=${0}    AND
#    ...    choice required APN on UE    usedapn=@{apn_location}[3]    ue_type=@{ue_type}[0]    ue_index=${1}    AND
#    ...    Step4: Detach UE    ue_index=${1}    ue_type=@{ue_type}[0]    AND
#    ...    Step3: QCM UE hang up EMC call    ue_index=${2}    AND
#    ...    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Recover Switch APN to muti DRB    ue_index=${2}    apn_name=${wap2_apn_name}
#    ...    ELSE       S21 switch APN    usedapn=@{apn_location}[5]    ue_index=${2}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_A_004_0}    gNB_index=${1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_A_004_1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_A_004_2}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master
#    ...    filename=${log_name_A_004_3}    gNB_index=${1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_A_004_4}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master
#    ...    filename=${log_name_A_004_5}    gNB_index=${1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_A_004_6}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on eNB    log_name=${enb_log_name_A_004_1}    AND
#    ...    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    gnb1_cell1_value=@{PA_list}[0]    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[0]    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_8698_recover_A_004_2}    gnb_index=${1}    AND
#    ...    Online add parmeters    parameters_to_update=${PARAM_ADD_8698_A_004}    gnb_index=${0}    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_8698_recover_A_004}    gnb_index=${0}    AND
#    ...    Online delete parmeters    parameters_to_update=${PARAM_DELETE_8698_A_004_for_postconditions}    gnb_index=${0}    AND
##    ...    Unlock cell online coam    gnb_index=${0}    cell_index=${1}    AND    set enb cell for A004    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#
#[1]CB008698-A_006_ICS_when_in_SA+NSA_preferNsaPreemptio_enable_with_lower_priority_success_due_to_release_higher_priority_NSA_UE
#    [Documentation]    This user scenario describes Initial Context Setup procedure where AMF requests
#    ...    for PDU sessions(preferNsaPreemption = true, lowest priority NSA users present in the cell has priority
#    ...    lower than priority of incoming request, but higher than some other SA UE context.
#    ...    The higest ARP NSA UE context is selected for preemption.)
#    [Tags]    CB008698-A    CRT_TRUNK    CRT_22R4
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Online modify parmeters    parameters_to_update=${PARAM_8698_A_006}    gnb_index=${0}
#    Wait Until Keyword Succeeds    10x    30s    Online modify parmeters    parameters_to_update=${PARAM_8698_A_006_2}    gnb_index=${1}
#    set enb cell for A006    value=@{enb_value}[1]
#    Lock cell online coam    gnb_index=${0}    cell_index=${1}
#    Comment    set gnb1 cell2 PA to 120 and set gnb2 cell1 PA to 0
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[1]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[1]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[1]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[1]
#    Comment    change APN of UE3 to mdrb.nokia.com
#    choice required APN on UE    usedapn=@{apn_location}[4]    ue_type=@{ue_type}[1]    ue_index=${2}
#    make WA with Samsung S21    ue_index=${2}
#    Comment    UE3 attach on gnb2 cell1
#    Start capture gNB log on master    filename=${log_name_A_006_00}    gNB_index=${1}
#    Step1: UE attach    ue_type=@{ue_type}[1]    ue_index=${2}    gnb_index=${1}
#    Stop and download Logs on gNB on master    filename=${log_name_A_006_00}    gNB_index=${1}
#    Comment    set gnb1 cell2 PA to 0 and set gnb2 cell1 PA to 30
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[2]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[4]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[2]    enb_cell1_value=@{PA_list}[1]
#    Comment    set UE2 APN to MDRB
#    choice required APN on UE    usedapn=@{apn_location}[2]    ue_type=@{ue_type}[0]    ue_index=${1}
#    Comment    UE2 attach on gnb1 cell2
#    Start capture gNB log on master    filename=${log_name_A_006_01}
#    Step1: UE attach    ue_type=@{ue_type}[0]    ue_index=${1}
#    Stop and download Logs on gNB on master    filename=${log_name_A_006_01}
#    Comment    UE1 switch to NSA mode
#    change UE 5G mode    ue_type=@{ue_type}[0]    ue_index=${0}    mode_selection=NSA
#    set enb cell for A006
#    comment    set enb cell1 PA to 0
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[2]    enb_cell1_value=@{PA_list}[0]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[4]    enb_cell1_value=@{PA_list}[0]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[2]    enb_cell1_value=@{PA_list}[0]
#    Huawei UE setup    ue_type=@{ue_type}[0]    ue_index=${0}
#    make airplane mode to enable    ue_index=${0}
#    Start capture gNB log on master    filename=${log_name_A_006_1}
#    Comment    UE1 attach on gnb1 cell2 NSA
#    Step1: UE attach    ue_type=@{ue_type}[0]    4G_check=True
#    Stop and download Logs on gNB on master    filename=${log_name_A_006_1}
#    Comment    set gnb2 cell1 PA to 10
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[0]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[6]    enb_cell1_value=@{PA_list}[0]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[0]
#    Step2: UE setup VoNR call    ue_index=${2}
#    sleep    20s
#    check voice call status    ue_index=${2}    status=${2}
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on master    filename=${log_name_A_006_2}
#    Start capture gNB log on master    filename=${log_name_A_006_3}    gNB_index=${1}
#    check voice call status    ue_index=${2}    status=${2}
#    Comment    set gnb2 cell1 PA to 120
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[1]    enb_cell1_value=@{PA_list}[0]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[1]    enb_cell1_value=@{PA_list}[0]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[1]    enb_cell1_value=@{PA_list}[0]
#    sleep    20s
#    Stop and download Logs on gNB on master    filename=${log_name_A_006_2}
#    Stop and download Logs on gNB on master    filename=${log_name_A_006_3}    gNB_index=${1}
#    Prepare with PM counter time to caculate    period=end
#    Check wireshark log for A006_1
#    Check wireshark log for A006_2
#    Check counter for 006_1
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    Step3: UE hang up VoNR call    ue_index=${2}    AND
#    ...    check voice call status    ue_index=${2}    status=${0}    AND
#    ...    choice required APN on UE    usedapn=@{apn_location}[1]    ue_type=@{ue_type}[0]    ue_index=${0}    AND
#    ...    Run Keyword And Ignore Error    change UE 5G mode    ue_type=@{ue_type}[0]    ue_index=${0}    mode_selection=SA    AND
#    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb2_cell1_value=${0}    AND
#    ...    Wait Until Keyword Succeeds    3x    60s    Step1: UE attach    ue_type=@{ue_type}[0]    ue_index=${0}    gnb_index=${1}    AND
#    ...    Step4: Detach UE    ue_type=@{ue_type}[0]    AND
#    ...    choice required APN on UE    usedapn=@{apn_location}[3]    ue_type=@{ue_type}[0]    ue_index=${1}    AND
#    ...    Step4: Detach UE    ue_type=@{ue_type}[0]    ue_index=${1}    AND
#    ...    choice required APN on UE    usedapn=@{apn_location}[5]    ue_type=@{ue_type}[1]    ue_index=${2}    AND
#    ...    make WA with Samsung S21    ue_index=${2}    AND
#    ...    Step4: Detach UE    ue_type=@{ue_type}[1]    ue_index=${2}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_A_006_00}    gNB_index=${1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_A_006_01}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_A_006_1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_A_006_2}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master
#    ...    filename=${log_name_A_006_3}    gNB_index=${1}    AND
#    ...    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[0]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[0]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[0]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[0]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[0]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[0]    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_8698_recover_A_006_2}    gnb_index=${1}    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_8698_recover_A_006}    gnb_index=${0}    AND
#    ...    Unlock cell online coam    gnb_index=${0}    cell_index=${1}    AND    set enb cell for A006    AND
#    ...    CB008698_common_keywords.check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${2}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#[1]CB008698_B_005_inter_gnb_handover_SA_NSA_mode_preferNsaPreemption_enable_lower_priority_NSA_UE_Context_preemption
#    [Documentation]    This user scenario describes Initial Context Setup procedure where AMF requests
#    ...    for PDU sessions(no NSA user present in the cell, so instead, an SA UE context is selected for preemption)
#    [Tags]    CB008698-B    CRT_TRUNK    CRT_22R4
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Online modify parmeters     parameters_to_update=${PARAM_8698_Targetgnb1_B_005}
#    Online modify parmeters    gnb_index=${1}    parameters_to_update=${PARAM_8698_Sourcegnb2_B_005}
#    check Redirect status
#    Comment    lock enb cell
#    set enb cell    value=@{enb_value}[1]
#    Comment    lock gnb1 cell1
#    Lock cell online coam    gnb_index=${0}    cell_index=${1}
#    Comment    set gnb1 cell2 PA to 0 and set gnb2 cell1 PA to 120
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...                gnb1_cell2_value=${0}    gnb2_cell1_value=${120}    enb_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...                gnb1_cell2_value=${0}    gnb2_cell1_value=${120}    enb_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...                gnb1_cell2_value=${0}    gnb2_cell1_value=${120}    enb_cell1_value=${0}
#    Comment    set UE2 APN to MDRB
#    choice required APN on UE    usedapn=@{apn_location}[2]    ue_type=@{ue_type}[0]    ue_index=${1}
#    Comment    set UE3 APN to MDRB
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Switch APN to muti DRB    ue_index=${2}    apn_name=${mdrb_apn_name}
#    ...    ELSE       S21 switch APN    usedapn=@{apn_location}[4]   ue_index=${2}
##    Multi UE switch APN    usedapn=@{apn_location}[4]   ue_index=${2}
##    choice required APN on UE    usedapn=@{apn_location}[4]    ue_type=@{ue_type}[1]    ue_index=${2}
##    make WA with Samsung S21    ue_index=${2}
#    Start capture gNB log on master    filename=${log_name_B_005_1}
#    Comment    UE3 attach on gnb1 cell2
##    Multi UE Type Attach    ue_index=${2}
##    Step1: UE attach    ue_type=@{ue_type}[1]    ue_index=${2}
#    Attach and check power UE    ue_type=${ue_type3}    ue_index=${2}
#    Stop and download Logs on gNB on master    filename=${log_name_B_005_1}
#    Comment    UE1 switch to NSA mode
#    change UE 5G mode    ue_type=@{ue_type}[0]    ue_index=${0}    mode_selection=NSA
#    set enb cell for A006
#    Start to collect the log on eNB    log_name=${log_name_B_005_eNB}
#    Start capture gNB log on master    filename=${log_name_B_005_3}
#    Step1: UE attach    ue_type=@{ue_type}[0]    4G_check=True
#    Stop and download Logs on eNB       log_name=${log_name_B_005_eNB}
#    Stop and download Logs on gNB on master    filename=${log_name_B_005_3}
#    Comment    set gnb2 cell1 PA to 10
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...                gnb1_cell2_value=${20}    gnb2_cell1_value=${0}    enb_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...                gnb1_cell2_value=${20}    gnb2_cell1_value=${0}    enb_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...                gnb1_cell2_value=${20}    gnb2_cell1_value=${0}    enb_cell1_value=${0}
#    Start capture gNB log on master    filename=${log_name_B_005_2}    gNB_index=${1}
#    Comment    UE2 attach on gnb2 cell1
#    Step1: UE attach    ue_type=@{ue_type}[0]    ue_index=${1}    gnb_index=${1}
#    Stop and download Logs on gNB on master    filename=${log_name_B_005_2}   gNB_index=${1}
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on master    filename=${log_name_B_005_4}
#    Start capture gNB log on master    filename=${log_name_B_005_5}    gNB_index=${1}
#    Comment    set gnb2 cell1 PA to 35 HO to gnb1 cell2
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...                gnb1_cell2_value=${0}    gnb2_cell1_value=${40}    enb_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...                gnb1_cell2_value=${0}    gnb2_cell1_value=${20}    enb_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...                gnb1_cell2_value=${0}    gnb2_cell1_value=${40}    enb_cell1_value=${0}
#    sleep    20s
#    Stop and download Logs on gNB on master    filename=${log_name_B_005_4}
#    Stop and download Logs on gNB on master    filename=${log_name_B_005_5}    gNB_index=${1}
#    Prepare with PM counter time to caculate    period=end
#    Check wireshark log for 005_3
#    Check wireshark log for 005_4
#    Check L3 Call intergNB HO process on source gNB    logname=${log_name_B_005_5}
#    Check L3 Call intergNB HO process on target gNB    logname=${log_name_B_005_4}
#    Check counter for 005
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    choice required APN on UE    usedapn=@{apn_location}[3]    ue_type=@{ue_type}[0]    ue_index=${1}    AND
#    ...    Step4: Detach UE    ue_index=${1}    ue_type=@{ue_type}[0]    AND
#    ...    Run Keyword And Ignore Error    change UE 5G mode    ue_type=@{ue_type}[0]    ue_index=${0}    mode_selection=SA    AND
#    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb2_cell1_value=${0}    AND
#    ...    Wait Until Keyword Succeeds    3x    60s    Step1: UE attach    ue_type=@{ue_type}[0]    ue_index=${0}    gnb_index=${1}    AND
#    ...    Step4: Detach UE    ue_type=@{ue_type}[0]    AND
##    ...    Multi UE switch APN    usedapn=@{apn_location}[5]    ue_index=${2}    AND
##    ...    choice required APN on UE    usedapn=@{apn_location}[5]    ue_type=@{ue_type}[1]    ue_index=${2}    AND
##    ...    make WA with Samsung S21    ue_index=${2}    AND
##    ...    Multi UE Type Detach    ue_index=${2}    AND
##    ...    Step4: Detach UE    ue_index=${2}    ue_type=@{ue_type}[1]    AND
#    ...    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Recover Switch APN to muti DRB    ue_index=${2}    apn_name=${wap2_apn_name}
#    ...    ELSE       S21 switch APN    usedapn=@{apn_location}[5]    ue_index=${2}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_005_1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_005_2}    gNB_index=${1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_005_3}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on eNB       log_name=${log_name_B_005_eNB}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_005_4}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_005_5}    gNB_index=${1}    AND
#    ...    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}    enb_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}    enb_cell1_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation
#    ...    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}    enb_cell1_value=${0}    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_8698_recover_Targetgnb1_B_005}    AND
#    ...    Online modify parmeters    gnb_index=${1}    parameters_to_update=${PARAM_8698_recover_Sourcegnb2_B_005}    AND
#    ...    Unlock cell online coam    gnb_index=${0}    cell_index=${1}    AND    set enb cell    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB008698-C_003_ICSR_with_PDU_session_based_on_EC_DRB_no preemption candidates
#    [Documentation]    This user scenario describes Initial Context Setup procedure where AMF requests
#    ...    for PDU sessions(no NSA user present in the cell, so instead, an SA UE context is selected for preemption)
#    [Tags]    CB008698-C    CRT_TRUNK    CRT_22R4
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Online add and modify parameters with C003
#    check Redirect status
#    Comment    lock enb cell
#    set enb cell for C003    value=@{enb_value}[1]
#    Comment    lock gnb1 cell1
#    Lock cell online coam    gnb_index=${0}    cell_index=${1}
#    Comment    set gnb1 cell2 PA to 120
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[1]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[1]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[1]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[1]
#    Comment    change APN of UE3 to mdrb.nokia.com
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Switch APN to muti DRB    ue_index=${2}
#    ...                apn_name=${mdrb_apn_name}    gnb_index=${1}
#    ...    ELSE       S21 switch APN    usedapn=@{apn_location}[4]   ue_index=${2}
#    Comment    UE3 attach on gnb2 cell1
#    Start capture gNB log on master    filename=${log_name_C_003_00}    gNB_index=${1}
#    Attach and check power UE    ue_type=${ue_type3}    ue_index=${2}    gnb_index=${1}
#    Stop and download Logs on gNB on master    filename=${log_name_C_003_00}    gNB_index=${1}
#    Comment    set gnb1 cell2 PA to 0
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[2]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[4]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[2]    enb_cell1_value=@{PA_list}[1]
#    Comment    set APN of UE2 to wap1
#    choice required APN on UE    usedapn=@{apn_location}[6]    ue_type=@{ue_type}[0]    ue_index=${1}
#    Comment    UE2 attach on gnb1 cell2
#    Huawei UE setup    ue_type=@{ue_type}[0]    ue_index=${1}
#    Wait Until Keyword Succeeds    3x    10s    make UE attach successful 1 times with C003
#    Comment    set gnb2 cell1 PA to 10
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[6]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[1]
#    Comment    UE2 make VoNR
#    Start capture gNB log on master    filename=${log_name_C_003_01}
#    Step2: UE setup VoNR call    ue_index=${1}
#    sleep    20s
#    Stop and download Logs on gNB on master    filename=${log_name_C_003_01}
#    check voice call status    ue_index=${1}    status=${2}
#    Comment    UE3 make EMC
#    Start capture gNB log on master    filename=${log_name_C_003_02}    gNB_index=${1}
#    Step2: QCM UE setup EMC call    ue_index=${2}
##    Step2: UE setup EMC call    ue_index=${2}
#    sleep    20s
#    Stop and download Logs on gNB on master    filename=${log_name_C_003_02}    gNB_index=${1}
#    check voice call status    ue_index=${2}    status=${2}
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on master    filename=${log_name_C_003_2}
#    Start capture gNB log on master    filename=${log_name_C_003_3}    gNB_index=${1}
#    check voice call status    ue_index=${2}    status=${2}
#    Comment    set gnb2 cell1 PA to 120
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[1]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[1]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[1]    enb_cell1_value=@{PA_list}[1]
#    sleep    20s
#    Stop and download Logs on gNB on master    filename=${log_name_C_003_2}
#    Stop and download Logs on gNB on master    filename=${log_name_C_003_3}    gNB_index=${1}
#    Prepare with PM counter time to caculate    period=end
#    Check wireshark log for C003_1
#    Check wireshark log for C003_2
#    Check counter for C003_1
#    check voice call status    ue_index=${1}    status=${2}
#    check voice call status    ue_index=${2}    status=${2}
#    Start capture gNB log on master    filename=${log_name_C_003_4}
#    Step3: UE hang up VoNR call    ue_index=${1}
#    check voice call status    ue_index=${1}    status=${0}
#    Stop and download Logs on gNB on master    filename=${log_name_C_003_4}
#    Start capture gNB log on master    filename=${log_name_C_003_5}
#    Step3: QCM UE hang up EMC call    ue_index=${2}
##    Step3: UE hang up EMC call    ue_index=${2}
#    check voice call status    ue_index=${2}    status=${0}
#    Stop and download Logs on gNB on master    filename=${log_name_C_003_5}
#    Check wireshark log for C003_3
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    Step3: UE hang up VoNR call    ue_index=${1}    AND
#    ...    check voice call status    ue_index=${1}    status=${0}    AND
#    ...    Wait Until Keyword Succeeds    3x    10s    choice required APN on UE
#    ...                                                usedapn=@{apn_location}[3]    ue_type=@{ue_type}[0]    ue_index=${1}    AND
#    ...    Step4: Detach UE    ue_index=${1}    ue_type=@{ue_type}[0]    AND
#    ...    Step3: QCM UE hang up EMC call    ue_index=${2}    AND
#    ...    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Recover Switch APN to muti DRB    ue_index=${2}    apn_name=${wap2_apn_name}
#    ...    ELSE       S21 switch APN    usedapn=@{apn_location}[5]    ue_index=${2}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_C_003_00}    gNB_index=${1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_C_003_1}     AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_C_003_01}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_C_003_02}    gNB_index=${1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_C_003_2}     AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master
#    ...    filename=${log_name_C_003_3}    gNB_index=${1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_C_003_4}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_C_003_5}    AND
#    ...    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[0]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[0]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[0]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[0]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[0]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[0]    AND
#    ...    Online delete and modify parameters with C003    AND
#    ...    Unlock cell online coam    gnb_index=${0}    cell_index=${1}    AND    set enb cell for C003    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#
#[1]CB008698-C_005_ICSR_with_PDU_session_based_on_non-cell_level_nonGBR_DRB_preemption_SA
#    [Documentation]    This user scenario describes Initial Context Setup procedure where AMF requests
#    ...    for PDU sessions(preferNsaPreemption = true, lowest priority NSA users present in the cell has priority
#    ...    lower than priority of incoming request, but higher than some other SA UE context.
#    ...    The higest ARP NSA UE context is selected for preemption.)
#    [Tags]    CB008698-C    CRT_TRUNK    CRT_22R4
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Online add parmeters    parameters_to_update=${PARAM_ADD_8698_C_005}    gnb_index=${0}
#    Online modify parmeters    parameters_to_update=${PARAM_8698_C_005}    gnb_index=${0}
#    Online modify parmeters    parameters_to_update=${PARAM_8698_C_005_GNB2}    gnb_index=${1}
#    check Redirect status
#    set enb cell for C005    value=@{enb_value}[1]
#    Lock cell online coam    gnb_index=${0}    cell_index=${1}
#    Comment    set gnb1 cell2 PA to 120
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[1]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[1]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[1]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[1]
#    Comment    change APN of UE3 to mdrb.nokia.com
#    Multi UE switch APN    usedapn=@{apn_location}[4]   ue_index=${2}
#    make WA with Samsung S21    ue_index=${2}
#    Comment    UE3 attach on gnb2 cell1
#    Multi UE Type Attach    ue_index=${2}    gnb_index=${1}
#    Comment    set gnb1 cell2 PA to 0 and set gnb2 cell1 PA to 30
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[2]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[4]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[2]    enb_cell1_value=@{PA_list}[1]
#    Comment    set UE2 APN to MDRB
#    choice required APN on UE    usedapn=@{apn_location}[2]    ue_type=@{ue_type}[0]    ue_index=${1}
#    Comment    UE2 attach on gnb1 cell2
#    Huawei UE setup    ue_type=@{ue_type}[0]    ue_index=${1}
#    Wait Until Keyword Succeeds    3x    10s    make UE attach successful 1 times with C005
#    Comment    set gnb2 cell1 PA to 10
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[6]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[3]    gnb2_cell1_value=@{PA_list}[6]    enb_cell1_value=@{PA_list}[1]
#    Comment    UE3 make EMC
#    Step2: UE setup EMC call    ue_index=${2}
#    sleep    20s
#    check voice call status    ue_index=${2}    status=${2}
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on master    filename=${log_name_C_005_2}
#    Start capture gNB log on master    filename=${log_name_C_005_3}    gNB_index=${1}
#    check voice call status    ue_index=${2}    status=${2}
#    Comment    set gnb2 cell1 PA to 120
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[1]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[1]    enb_cell1_value=@{PA_list}[1]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[1]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[1]    enb_cell1_value=@{PA_list}[1]
#    sleep    20s
#    Stop and download Logs on gNB on master    filename=${log_name_C_005_2}
#    Stop and download Logs on gNB on master    filename=${log_name_C_005_3}    gNB_index=${1}
#    Prepare with PM counter time to caculate    period=end
#    Check wireshark log for C005_1
#    Check wireshark log for C005_2
#    Check counter for C005_1
#    Start capture gNB log on master    filename=${log_name_C_005_4}
#    Step3: UE hang up EMC call    ue_index=${2}
#    check voice call status    ue_index=${2}    status=${0}
#    Stop and download Logs on gNB on master    filename=${log_name_C_005_4}
#    Check wireshark log for C005_3
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    Step3: UE hang up EMC call    ue_index=${2}    AND
#    ...    check voice call status    ue_index=${2}    status=${0}    AND
#    ...    choice required APN on UE    usedapn=@{apn_location}[3]    ue_type=@{ue_type}[0]    ue_index=${1}    AND
#    ...    Step4: Detach UE    ue_type=@{ue_type}[0]    ue_index=${1}    AND
#    ...    Multi UE switch APN    usedapn=@{apn_location}[5]    ue_index=${2}    AND
#    ...    make WA with Samsung S21    ue_index=${2}    AND
#    ...    Multi UE Type Detach    ue_index=${2}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_C_005_1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_C_005_2}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master
#    ...    filename=${log_name_C_005_3}    gNB_index=${1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_C_005_4}    AND
#    ...    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[0]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[0]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[0]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[0]
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[0]
#    ...    gnb1_cell2_value=@{PA_list}[0]    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[0]    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_8698_recover_C_005_GNB2}    gnb_index=${1}    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_8698_recover_C_005}    gnb_index=${0}    AND
#    ...    Online delete parmeters    parameters_to_update=${PARAM_DELETE_8698_C_005}    gnb_index=${0}    AND
#    ...    Unlock cell online coam    gnb_index=${0}    cell_index=${1}    AND    set enb cell for C005    AND
#    ...    CB008698_common_keywords.check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${2}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

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

COAM Save snapshot
    get gnb snapshot    gnb_index=${0}
#    get gnb snapshot    gnb_index=${1}

get gnb snapshot
    [Arguments]     ${gnb_index}=${0}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
#    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

Recover Adjust D001 temopary topyoung gNB_eNB_RU Attenuation
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell2_ANT}    cell=5Gcell2    value=${0}    ip_addr=${tl.attenuator[1].ip_addr}
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell3_ANT}    cell=5Gcell3    value=${10}    ip_addr=${tl.attenuator[0].ip_addr}

Adjust D001 temopary topyoung gNB_eNB_RU Attenuation
    Comment    set gnb1 cell2 PA to 0
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell2_ANT}    cell=5Gcell2    value=${0}    ip_addr=${tl.attenuator[1].ip_addr}
    Comment    set gnb2 cell1 PA to 120
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell3_ANT}    cell=5Gcell3    value=${120}    ip_addr=${tl.attenuator[0].ip_addr}

Adjust B005 temopary topyoung gNB_eNB_RU Attenuation
    Comment    set gnb1 cell2 PA to 0
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell2_ANT}    cell=5Gcell2    value=${0}    ip_addr=${tl.attenuator[1].ip_addr}
    Comment    set gnb2 cell1 PA to 120
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell3_ANT}    cell=5Gcell3    value=${120}    ip_addr=${tl.attenuator[0].ip_addr}

Recover Adjust B005 temopary topyoung gNB_eNB_RU Attenuation
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell2_ANT}    cell=5Gcell2    value=${0}    ip_addr=${tl.attenuator[1].ip_addr}
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell3_ANT}    cell=5Gcell3    value=${10}    ip_addr=${tl.attenuator[0].ip_addr}

Adjust B012 temopary topyoung gNB_eNB_RU Attenuation
    Comment    set gnb2 cell1 PA to 120
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell3_ANT}    cell=5Gcell3    value=${120}    ip_addr=${tl.attenuator[0].ip_addr}
    Comment    gnb1 cell2 PA to 0
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell2_ANT}    cell=5Gcell2    value=${0}    ip_addr=${tl.attenuator[1].ip_addr}

Recover Adjust B012 temopary topyoung gNB_eNB_RU Attenuation
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell2_ANT}    cell=5Gcell2    value=${0}    ip_addr=${tl.attenuator[1].ip_addr}
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell3_ANT}    cell=5Gcell3    value=${10}    ip_addr=${tl.attenuator[0].ip_addr}

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

Adjust temopary topyoung gNB_eNB_RU Attenuation
    Comment    set gnb2 cell1 PA to 120
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell3_ANT}    cell=5Gcell3    value=${120}    ip_addr=${tl.attenuator[0].ip_addr}
    Comment    set gnb1 cell1 PA to 0
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell1_ANT}    cell=5Gcell1    value=${0}    ip_addr=${tl.attenuator[2].ip_addr}
    Comment    set gnb1 cell2 PA to 120
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell2_ANT}    cell=5Gcell2    value=${120}    ip_addr=${tl.attenuator[1].ip_addr}

Recover Adjust temopary topyoung gNB_eNB_RU Attenuation
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell3_ANT}    cell=5Gcell3    value=${0}    ip_addr=${tl.attenuator[0].ip_addr}
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell1_ANT}    cell=5Gcell1    value=${0}    ip_addr=${tl.attenuator[2].ip_addr}
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell2_ANT}    cell=5Gcell2    value=${0}    ip_addr=${tl.attenuator[1].ip_addr}

make UE attach successful 1 times with B012
    make airplane mode to enable    ue_index=${1}
    Start capture gNB log on master    filename=${log_name_B_012_1}
    UE attach with new method    ue_index=${1}    gnb_index=${0}    distname_id=${2}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_B_012_1}

make UE attach successful 1 times with D001
    make airplane mode to enable    ue_index=${1}
    Start capture gNB log on master    filename=${log_name_D_001_1}
    UE attach with new method    ue_index=${1}    gnb_index=${0}    distname_id=${2}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_D_001_1}

make UE attach successful 1 times with D010
    make airplane mode to enable    ue_index=${1}
    Start capture gNB log on master    filename=${log_name_D_010_1}
    UE attach with new method    ue_index=${1}    gnb_index=${0}    distname_id=${1}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_D_010_1}

make UE attach successful 1 times with A004
    make airplane mode to enable    ue_index=${1}
    Start capture gNB log on master    filename=${log_name_A_004_1}
    UE attach with new method    ue_index=${1}    gnb_index=${0}    distname_id=${2}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_A_004_1}

make UE attach successful 1 times with C003
    make airplane mode to enable    ue_index=${1}
    Start capture gNB log on master    filename=${log_name_C_003_1}
    UE attach with new method    ue_index=${1}    gnb_index=${0}    distname_id=${2}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_C_003_1}

make UE attach successful 1 times with C005
    make airplane mode to enable    ue_index=${1}
    Start capture gNB log on master    filename=${log_name_C_005_1}
    UE attach with new method    ue_index=${1}    gnb_index=${0}    distname_id=${2}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_C_005_1}

make UE attach successful 1 times with F006
    make airplane mode to enable    ue_index=${1}
    Start capture gNB log on master    filename=${log_name_F_006_1}
    UE attach with new method    ue_index=${1}    gnb_index=${0}    distname_id=${1}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_F_006_1}

make UE attach successful 1 times with F006_2
    make airplane mode to enable    ue_index=${0}
    Start capture gNB log on master    filename=${log_name_F_006_3}
    UE attach with new method    ue_index=${0}    gnb_index=${0}    distname_id=${2}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_F_006_3}

Online add and modify parameters with C003
    Online add parmeters    parameters_to_update=${PARAM_ADD_8698_C_003}    gnb_index=${0}
    Online modify parmeters    parameters_to_update=${PARAM_8698_C_003}    gnb_index=${0}
    Online modify parmeters    parameters_to_update=${PARAM_8698_C_003_2}    gnb_index=${0}
    Online add parmeters    parameters_to_update=${PARAM_ADD_8698_C_003_2}    gnb_index=${0}
    Online modify parmeters    parameters_to_update=${PARAM_8698_C_003_GNB2}    gnb_index=${1}

Online delete and modify parameters with C003
    Online delete parmeters    parameters_to_update=${PARAM_DELETE_8698_C_003_2}    gnb_index=${0}
    Online modify parmeters    parameters_to_update=${PARAM_8698_recover_C_003_2}    gnb_index=${0}
    Online modify parmeters    parameters_to_update=${PARAM_8698_recover_C_003}    gnb_index=${0}
    Online delete parmeters    parameters_to_update=${PARAM_DELETE_8698_C_003}    gnb_index=${0}
    Online modify parmeters    parameters_to_update=${PARAM_8698_C_003_GNB2}    gnb_index=${1}

set enb cell for A004
    [Arguments]    ${dist_name}=${enb_dist_name}[0]    ${parameter}=${enb_para}[0]    ${value}=${enb_value}[0]
    Modify parameter on enb    dist_name=${dist_name}    parameter=${parameter}    value=${value}

set enb cell for A006
    [Arguments]    ${dist_name}=${enb_dist_name}[0]    ${parameter}=${enb_para}[0]    ${value}=${enb_value}[0]
    Modify parameter on enb    dist_name=${dist_name}    parameter=${parameter}    value=${value}

#set enb cell for A006
#    [Arguments]    ${dist_name}=@{enb_dist_name}[0]    ${dist_name1}=@{enb_dist_name2}[0]    ${parameter}=@{enb_para}[0]    ${value}=@{enb_value}[0]
#    Run keyword if    '${enb_instance}'=='${911}'   Modify parameter on enb    dist_name=${dist_name1}    parameter=${parameter}    value=${value}
#    ...    ELSE    Modify parameter on enb    dist_name=${dist_name}    parameter=${parameter}    value=${value}

set enb cell for C003
    [Arguments]    ${dist_name}=${enb_dist_name}[0]    ${parameter}=${enb_para}[0]    ${value}=${enb_value}[0]
    Modify parameter on enb    dist_name=${dist_name}    parameter=${parameter}    value=${value}

set enb cell for C005
    [Arguments]    ${dist_name}=${enb_dist_name}[0]    ${parameter}=${enb_para}[0]    ${value}=${enb_value}[0]
    Modify parameter on enb    dist_name=${dist_name}    parameter=${parameter}    value=${value}

set enb cell for F006
    [Arguments]    ${dist_name}=${enb_dist_name}[0]    ${parameter}=${enb_para}[0]    ${value}=${enb_value}[0]
    Modify parameter on enb    dist_name=${dist_name}    parameter=${parameter}    value=${value}

make WA for Samsung remember issue with attach
    Comment    set gnb1 cell2 PA to 120
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell2_ANT}    cell=5Gcell2    value=${120}    ip_addr=${tl.attenuator[1].ip_addr}
    Comment    set gnb2 cell1 PA to 0
    Set TOPYOUNG Attenuation Value    ports=@{5Gcell3_ANT}    cell=5Gcell3    value=${0}    ip_addr=${tl.attenuator[0].ip_addr}
    Step1: UE attach    ue_type=${ue_type}[1]    ue_index=${2}    gnb_index=${1}
    Step4: Detach UE    ue_type=${ue_type}[1]    ue_index=${2}

###check wireshar log
Check wireshark log for D010_1
    ${UE_NGAP_ID}=    Get RAN-UE-NGAP-ID message    logname=${log_name_D_010_1}
    Set Suite Variable    ${SA_preempted_ue_id}    ${UE_NGAP_ID}

Check wireshark log for D001_1
    ${UE_NGAP_ID}=    Get RAN-UE-NGAP-ID message    logname=${log_name_D_001_1}
    Set Suite Variable    ${SA_preempted_ue_id}    ${UE_NGAP_ID}

Check wireshark log for 012_1
    ${UE_NGAP_ID}=    Get RAN-UE-NGAP-ID message    logname=${log_name_B_012_1}
    Set Suite Variable    ${SA_preempted_ue_id}    ${UE_NGAP_ID}

Check wireshark log for A004_1
    ${UE_NGAP_ID}=    Get RAN-UE-NGAP-ID message    logname=${log_name_A_004_1}
    Set Suite Variable    ${SA_preempted_ue_id}    ${UE_NGAP_ID}

Check wireshark log for A004_2
    ${timerRejectWait_values}=    get BTS parameter value    class_name=NRBTS    Abbreviation=timerRejectWait
    ${UE_NGAP_ID}=    Get RAN-UE-NGAP-ID message    logname=${log_name_A_004_2}
    Set Suite Variable    ${preemption_ue_id}    ${UE_NGAP_ID}
    Set Suite Variable    ${timerRejectWait_value}    ${timerRejectWait_values}
    Check SA preempted success message    logname=${log_name_A_004_2}
    Check preemption success message    logname=${log_name_A_004_2}    check_priorityLevelARP=${ARP_priorityLevel}[0]
#    Check EPSFB mesage on enb    logname=${enb_log_name_A_004_1}

Check wireshark log for A004_3
#    Check VoNR release success message    logname=${log_name_A_004_6}
    Check wireshark log for ECC release    logname=${log_name_A_004_6}

Check wireshark log for A006_1
    ${SgNB_UE_X2AP_ID}=    Get SgNB_UE_X2AP_ID message    logname=${log_name_A_006_1}
    Set Suite Variable    ${NSA_preempted_ue_id}    ${SgNB_UE_X2AP_ID}

Check wireshark log for A006_2
    ${timerRejectWait_value}=    get BTS parameter value    class_name=NRBTS    Abbreviation=timerRejectWait
    ${UE_NGAP_ID}=    Get RAN-UE-NGAP-ID message    logname=${log_name_A_006_2}
    Set Suite Variable    ${preemption_ue_id}    ${UE_NGAP_ID}
    Check NSA preempted success message    logname=${log_name_A_006_2}
    Check preemption success message    logname=${log_name_A_006_2}    check_priorityLevelARP=${ARP_priorityLevel}[1]

Check wireshark log for 005_3
    ${SgNB_UE_X2AP_ID}=    Get SgNB_UE_X2AP_ID message    logname=${log_name_B_005_3}
    Set Suite Variable    ${NSA_preempted_ue_id}    ${SgNB_UE_X2AP_ID}

Check wireshark log for 005_4
    ${timerRejectWait_value}=    get BTS parameter value    class_name=NRBTS    Abbreviation=timerRejectWait
    ${UE_NGAP_ID}=    Get HO-RAN-UE-NGAP-ID message    logname=${log_name_B_005_4}
    Set Suite Variable    ${preemption_ue_id}    ${UE_NGAP_ID}
    Check NSA preempted success message    logname=${log_name_B_005_4}
#    Check HO preemption success message    logname=${log_name_B_005_4}    check_priorityLevelARP=@{ARP_priorityLevel}[0]
#    Check HO preemption success message_add    logname=${log_name_B_005_4}    check_priorityLevelARP=@{ARP_priorityLevel}[0]

Check HO preemption success message_add
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ##########################################preemption ue part##################################################
    ####SgNBReleaseRequired(X2AP)
    ${SgNBReleaseRequired_filter}=     Catenate
    ...    x2ap.procedureCode == 32 and x2ap.radioNetwork == 36 and ngap.RAN_UE_NGAP_ID == ${preemption_ue_id}
    Log To Console    check SgNBReleaseRequired
    ${SgNBReleaseRequired_filter_packets}=    cap.filter_packets_by_expression    filter_expression=${SgNBReleaseRequired_filter}
    ${ngap_radioNetwork}=     cap.get_field_value_by_xpath    pdml_list=${SgNBReleaseRequired_filter_packets}
    ...                                                xpath=.//x2ap.radioNetwork
    Should Be Equal    ${ngap_radioNetwork[0]}    36
    ####SgNBReleaseConfirm(X2AP)
    ${SgNBReleaseConfirm_filter}=     Catenate
    ...    x2ap.procedureCode == 32 and x2ap.X2AP_PDU == 1 and ngap.RAN_UE_NGAP_ID == ${preemption_ue_id}
    Log To Console    check SgNBReleaseConfirm
    ${SgNBReleaseConfirm_filter_packets}=    cap.filter_packets_by_expression    filter_expression=${SgNBReleaseConfirm_filter}
    ${ngap_radioNetwork}=     cap.get_field_value_by_xpath    pdml_list=${SgNBReleaseConfirm_filter_packets}
    ...                                                xpath=.//x2ap.procedureCode
    Should Be Equal    ${ngap_radioNetwork[0]}    32
        ####UEContextRelease(X2AP)
    ${SgNBReleaseConfirm_filter}=     Catenate
    ...        x2ap.procedureCode == 5 and x2ap.X2AP_PDU == 0 and ngap.RAN_UE_NGAP_ID == ${preemption_ue_id}
    Log To Console    check UEContextRelease
    ${UEContextRelease_filter_packets}=    cap.filter_packets_by_expression    filter_expression=${UEContextRelease_filter}
    ${ngap_radioNetwork}=     cap.get_field_value_by_xpath    pdml_list=${UEContextRelease_filter_packets}
    ...                                                xpath=.//x2ap.procedureCode
    Should Be Equal    ${ngap_radioNetwork[0]}    5

Check wireshark log for D001_3
    ${timerRejectWait_values}=    get BTS parameter value    class_name=NRBTS    Abbreviation=timerRejectWait
    ${UE_NGAP_ID}=    Get HO-RAN-UE-NGAP-ID message     logname=${log_name_D_001_3}
    Set Suite Variable    ${preemption_ue_id}    ${UE_NGAP_ID}
    Set Suite Variable    ${timerRejectWait_value}    ${timerRejectWait_values}
    Check SA preempted success message    logname=${log_name_D_001_3}
    Check XN_HO preemption success message    logname=${log_name_D_001_3}    check_priorityLevelARP=${ARP_priorityLevel}[1]
    Check D001_SA preempted success keep VONR on gnb2 cell    logname=${log_name_D_001_4}

Check wireshark log for 012_3
    ${timerRejectWait_values}=    get BTS parameter value    class_name=NRBTS    Abbreviation=timerRejectWait
    ${UE_NGAP_ID}=    Get NGHO-RAN-UE-NGAP-ID message    logname=${log_name_B_012_3}
    Set Suite Variable    ${preemption_ue_id}    ${UE_NGAP_ID}
    Set Suite Variable    ${timerRejectWait_value}    ${timerRejectWait_values}
    Check SA preempted success message    logname=${log_name_B_012_3}
    Check NG_HO preemption success message    logname=${log_name_B_012_3}    check_priorityLevelARP=${ARP_priorityLevel}[1]
    Check B012_SA preempted success keep L3Call on gnb2 cell    logname=${log_name_B_012_4}

Check wireshark log for D001_7
    Check VONR Normal release    logname=${log_name_D_001_7}

Check wireshark log for D001_6
    Check VONR Normal release    logname=${log_name_D_001_6}

Check wireshark log for D001_5
    Check VONR Normal release    logname=${log_name_D_001_5}

Check wireshark log for D010_4
    Check the Two VONR Normal release    logname=${log_name_D_010_4}

Check wireshark log for 012_6
    Check VONR Normal release    logname=${log_name_B_012_6}

Check wireshark log for 012_5
    Check VONR Normal release    logname=${log_name_B_012_5}

Check wireshark log for C003_1
    ${UE_NGAP_ID}=    Get RAN-UE-NGAP-ID message    logname=${log_name_C_003_1}
    Set Suite Variable    ${SA_preempted_ue_id}    ${UE_NGAP_ID}

Check wireshark log for C003_2
    Check preemption not execute message    logname=${log_name_C_003_2}    length_qosflow=${7}

Check wireshark log for C003_3
    Check VoNR release success message    logname=${log_name_C_003_4}
    Check wireshark log for ECC release    logname=${log_name_C_003_5}

Check wireshark log for C005_1
    ${UE_NGAP_ID}=    Get RAN-UE-NGAP-ID message    logname=${log_name_C_005_1}
    Set Suite Variable    ${SA_preempted_ue_id}    ${UE_NGAP_ID}

Check wireshark log for C005_2
    ${timerRejectWait_values}=    get BTS parameter value    class_name=NRBTS    Abbreviation=timerRejectWait
    ${UE_NGAP_ID}=    Get RAN-UE-NGAP-ID message    logname=${log_name_C_005_2}
    Set Suite Variable    ${preemption_ue_id}    ${UE_NGAP_ID}
    Set Suite Variable    ${timerRejectWait_value}    ${timerRejectWait_values}
    Check SA preempted success message    logname=${log_name_C_005_2}
    Check preemption success message    logname=${log_name_C_005_2}    check_priorityLevelARP=${ARP_priorityLevel}[0]
    Check preemption DRB with Reestablishment    logname=${log_name_C_005_2}    length_qosflow=${7}    length_pduid=${3}

Check wireshark log for C005_3
#    Check VoNR release success message    logname=${log_name_C_005_4}
    Check wireshark log for ECC release    logname=${log_name_C_005_4}

Check wireshark log for F006_1
    ${UE_NGAP_ID}=    Get RAN-UE-NGAP-ID message    logname=${log_name_F_006_1}
    Set Suite Variable    ${SA_preempted_ue_id}    ${UE_NGAP_ID}

Check wireshark log for F006_2
    ${timerRejectWait_values}=    get BTS parameter value    class_name=NRBTS    Abbreviation=timerRejectWait
    ${drb_id_list}=    Get drb id with attach    logname=${log_name_F_006_3}
    ${priorityLevelARP_id_list}=    Get priorityLevelARP id with attach    logname=${log_name_F_006_3}
    Set Test Variable    ${drb_id_list}
    Set Test Variable    ${priorityLevelARP_id_list}
    ${length_drb}    Get Length    ${drb_id_list}
    Set Test Variable    ${length_drb}
    Set Suite Variable    ${timerRejectWait_value}    ${timerRejectWait_values}
    Check Partial admission during intra-gNB HO    logname=${log_name_F_006_2}
    Check SA preempted success message    logname=${log_name_F_006_2}

####check counter on WEBUI
Check counter for A004_1
    sleep    40s
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM_REDIR['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM_REDIR['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM_REDIR['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM_REDIR['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM_REDIR['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM_REDIR['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_5QI1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_5QI1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_5QI1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_PMQAP['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_PMQAP['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_PMQAP['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_PMQAP['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['gnb_id']}
    Check gnb counter greater expected_value
    ...    counter_id=${PEAK_NUM_UE_CTX_TEMP_POOL['counter_id']}
    ...    dic_path=${PEAK_NUM_UE_CTX_TEMP_POOL['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${PEAK_NUM_UE_CTX_TEMP_POOL['gnb_id']}

Check counter for 006_1
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NSA_UE_CTX_REL_PREEM['counter_id']}
    ...    dic_path=${NSA_UE_CTX_REL_PREEM['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NSA_UE_CTX_REL_PREEM['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NX2CC_RAB_REL_PREEM_SGNB['counter_id']}
    ...    dic_path=${NX2CC_RAB_REL_PREEM_SGNB['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NX2CC_RAB_REL_PREEM_SGNB['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NX2CC_RAB_REL_PREEM_SGNB_PMQAP['counter_id']}
    ...    dic_path=${NX2CC_RAB_REL_PREEM_SGNB_PMQAP['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NX2CC_RAB_REL_PREEM_SGNB_PMQAP['gnb_id']}
    Check gnb counter greater expected_value
    ...    counter_id=${PEAK_NUM_UE_CTX_TEMP_POOL['counter_id']}
    ...    dic_path=${PEAK_NUM_UE_CTX_TEMP_POOL['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${PEAK_NUM_UE_CTX_TEMP_POOL['gnb_id']}

Check counter for 012
    sleep    40s
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM_REDIR['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM_REDIR['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM_REDIR['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE['dic_path']}
    ...    expected_value=${5}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM['dic_path']}
    ...    expected_value=${5}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_5QI1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_5QI1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['dic_path']}
    ...    expected_value=${5}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_PMQAP['dic_path']}
    ...    expected_value=${5}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NRRCC_RRC_RELEASE_REDIR_NR['counter_id']}
    ...    dic_path=${NRRCC_RRC_RELEASE_REDIR_NR['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NRRCC_RRC_RELEASE_REDIR_NR['gnb_id']}

Check counter for C003_1
    sleep    40s
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM_REDIR['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM_REDIR['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM_REDIR['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM_REDIR['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM_REDIR['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM_REDIR['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_5QI1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_5QI1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_5QI1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_5QI1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_PMQAP['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_PMQAP['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_PMQAP['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_PMQAP['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['gnb_id']}
    Check gnb counter greater expected_value
    ...    counter_id=${PEAK_NUM_UE_CTX_TEMP_POOL['counter_id']}
    ...    dic_path=${PEAK_NUM_UE_CTX_TEMP_POOL['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${PEAK_NUM_UE_CTX_TEMP_POOL['gnb_id']}

Check counter for C005_1
    sleep    40s
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM_REDIR['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM_REDIR['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM_REDIR['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM_REDIR['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM_REDIR['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM_REDIR['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM['dic_path']}
    ...    expected_value=${5}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE['dic_path']}
    ...    expected_value=${5}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_5QI1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_5QI1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_5QI1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_5QI1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_PMQAP['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_PMQAP['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_PMQAP['dic_path']}
    ...    expected_value=${5}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_PMQAP['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['dic_path']}
    ...    expected_value=${5}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['gnb_id']}
    Check gnb counter greater expected_value
    ...    counter_id=${PEAK_NUM_UE_CTX_TEMP_POOL['counter_id']}
    ...    dic_path=${PEAK_NUM_UE_CTX_TEMP_POOL['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${PEAK_NUM_UE_CTX_TEMP_POOL['gnb_id']}

Check counter for 005
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${PEAK_NUM_UE_CTX_TEMP_POOL['counter_id']}
    ...    dic_path=${PEAK_NUM_UE_CTX_TEMP_POOL['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${PEAK_NUM_UE_CTX_TEMP_POOL['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NSA_UE_CTX_REL_PREEM['counter_id']}
    ...    dic_path=${NSA_UE_CTX_REL_PREEM['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NSA_UE_CTX_REL_PREEM['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NX2CC_RAB_REL_PREEM_SGNB['counter_id']}
    ...    dic_path=${NX2CC_RAB_REL_PREEM_SGNB['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NX2CC_RAB_REL_PREEM_SGNB['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NX2CC_RAB_REL_PREEM_SGNB_PMQAP['counter_id']}
    ...    dic_path=${NX2CC_RAB_REL_PREEM_SGNB_PMQAP['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NX2CC_RAB_REL_PREEM_SGNB_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${SGNB_SA_CU_HO_ADMISSION_REQ['counter_id']}
    ...    dic_path=${SGNB_SA_CU_HO_ADMISSION_REQ['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${SGNB_SA_CU_HO_ADMISSION_REQ['gnb_id']}

Check trunk counter for F006_1
    sleep    40s
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${Trunk_SA_UE_CTX_REL_PREEM_1['counter_id']}
    ...    dic_path=${Trunk_SA_UE_CTX_REL_PREEM_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${Trunk_SA_UE_CTX_REL_PREEM_1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${Trunk_SA_UE_CTX_REL_PREEM_1['counter_id']}
    ...    dic_path=${Trunk_SA_UE_CTX_REL_PREEM_1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${Trunk_SA_UE_CTX_REL_PREEM_1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${Trunk_SA_UE_CTX_REL_PREEM_REDIR_1['counter_id']}
    ...    dic_path=${Trunk_SA_UE_CTX_REL_PREEM_REDIR_1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${Trunk_SA_UE_CTX_REL_PREEM_REDIR_1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${Trunk_SA_UE_CTX_REL_PREEM_REDIR_1['counter_id']}
    ...    dic_path=${Trunk_SA_UE_CTX_REL_PREEM_REDIR_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${Trunk_SA_UE_CTX_REL_PREEM_REDIR_1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_GNB_PREEM_1['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_GNB_PREEM_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_PREEM_1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_GNB_PREEM_1['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_GNB_PREEM_1['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_PREEM_1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_1['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_1['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_1['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_GNB_PREEM_5QI1_1['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_GNB_PREEM_5QI1_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_PREEM_5QI1_1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_GNB_PREEM_5QI1_1['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_GNB_PREEM_5QI1_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_PREEM_5QI1_1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_5QI1_1['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_5QI1_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_5QI1_1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_5QI1_1['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_5QI1_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_5QI1_1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_GNB_PREEM_PMQAP_1['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_GNB_PREEM_PMQAP_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_PREEM_PMQAP_1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_GNB_PREEM_PMQAP_1['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_GNB_PREEM_PMQAP_1['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_PREEM_PMQAP_1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_PMQAP_1['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_PMQAP_1['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_PMQAP_1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_PMQAP_1['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_PMQAP_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_PMQAP_1['gnb_id']}
    Check gnb counter greater expected_value
    ...    counter_id=${Trunk_PEAK_NUM_UE_CTX_TEMP_POOL_1['counter_id']}
    ...    dic_path=${Trunk_PEAK_NUM_UE_CTX_TEMP_POOL_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${Trunk_PEAK_NUM_UE_CTX_TEMP_POOL_1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_STP_ATT_INC_HO['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_STP_ATT_INC_HO['dic_path']}
    ...    expected_value=${5}
    ...    gnb_id=${Trunk_NG_FLOW_STP_ATT_INC_HO['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_STP_SUC_INC_HO['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_STP_SUC_INC_HO['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${Trunk_NG_FLOW_STP_SUC_INC_HO['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_IANR_SUC_HO['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_IANR_SUC_HO['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${Trunk_NG_FLOW_REL_IANR_SUC_HO['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_IANR_SUC_HO_5QI1['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_IANR_SUC_HO_5QI1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${Trunk_NG_FLOW_REL_IANR_SUC_HO_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_PART_HO['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_PART_HO['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${Trunk_NG_FLOW_REL_PART_HO['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_IANR_SUC_HO_PMQAP['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_IANR_SUC_HO_PMQAP['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${Trunk_NG_FLOW_REL_IANR_SUC_HO_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_PART_HO_PMQAP['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_PART_HO_PMQAP['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${Trunk_NG_FLOW_REL_PART_HO_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_SA_PART_ADMISSION['counter_id']}
    ...    dic_path=${Trunk_SA_PART_ADMISSION['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${Trunk_SA_PART_ADMISSION['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_STP_ATT_INC_HO_5QI1['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_STP_ATT_INC_HO_5QI1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${Trunk_NG_FLOW_STP_ATT_INC_HO_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_STP_SUC_INC_HO_5QI1['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_STP_SUC_INC_HO_5QI1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${Trunk_NG_FLOW_STP_SUC_INC_HO_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_STP_ATT_INC_HO_PMQAP['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_STP_ATT_INC_HO_PMQAP['dic_path']}
    ...    expected_value=${5}
    ...    gnb_id=${Trunk_NG_FLOW_STP_ATT_INC_HO_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_STP_SUC_INC_HO_PMQAP['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_STP_SUC_INC_HO_PMQAP['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${Trunk_NG_FLOW_STP_SUC_INC_HO_PMQAP['gnb_id']}

Check counter for F006_1
    sleep    40s
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM_1['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM_1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM_1['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM_1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM_1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM_REDIR_1['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM_REDIR_1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM_REDIR_1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM_REDIR_1['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM_REDIR_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM_REDIR_1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_1['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_1['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_5QI1_1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_5QI1_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_5QI1_1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_5QI1_1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_5QI1_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_5QI1_1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1_1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_5QI1_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1_1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1_1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_5QI1_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1_1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_PMQAP_1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_PMQAP_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_PMQAP_1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_PMQAP_1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_PMQAP_1['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_PMQAP_1['gnb_id']}
    Run Keyword If    '${actRedirect_status}' == 'True'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP_1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP_1['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP_1['gnb_id']}
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP_1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP_1['gnb_id']}
    Check gnb counter greater expected_value
    ...    counter_id=${PEAK_NUM_UE_CTX_TEMP_POOL_1['counter_id']}
    ...    dic_path=${PEAK_NUM_UE_CTX_TEMP_POOL_1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${PEAK_NUM_UE_CTX_TEMP_POOL_1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO['dic_path']}
    ...    expected_value=${5}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_IANR_SUC_HO['counter_id']}
    ...    dic_path=${NG_FLOW_REL_IANR_SUC_HO['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_REL_IANR_SUC_HO['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_IANR_SUC_HO_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_IANR_SUC_HO_5QI1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_IANR_SUC_HO_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_PART_HO['counter_id']}
    ...    dic_path=${NG_FLOW_REL_PART_HO['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_REL_PART_HO['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_IANR_SUC_HO_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_IANR_SUC_HO_PMQAP['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_REL_IANR_SUC_HO_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_PART_HO_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_PART_HO_PMQAP['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_REL_PART_HO_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${SA_PART_ADMISSION['counter_id']}
    ...    dic_path=${SA_PART_ADMISSION['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${SA_PART_ADMISSION['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_5QI1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_5QI1['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_PMQAP['dic_path']}
    ...    expected_value=${5}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_PMQAP['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP['gnb_id']}

Check trunk counter for D001
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_SA_UE_CTX_REL_PREEM_REDIR['counter_id']}
    ...    dic_path=${Trunk_SA_UE_CTX_REL_PREEM_REDIR['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${Trunk_SA_UE_CTX_REL_PREEM_REDIR['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_GNB_PREEM_RE['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_5QI1['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_PMQAP['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_PMQAP['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NRRCC_RRC_RELEASE_REDIR_NR['counter_id']}
    ...    dic_path=${Trunk_NRRCC_RRC_RELEASE_REDIR_NR['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${Trunk_NRRCC_RRC_RELEASE_REDIR_NR['gnb_id']}
    Check gnb counter contain expected_value
    ###chat with cindy on 20230202 from Elva email,the counter trigger 710 profile,it can be 1 or 2
    ###20230215 Add Feature ID:5GC000710-C;backlog ID:FCA_5GIV-11291;requirement ID:5G_CP_IF_RRC_1658
    ###20230216 Add Feature ID:CB006112-5G-B;backlog ID:FPB-484207;requirement ID:5G_RAN_USR_RRM_4852,just add
    ...    counter_id=${Trunk_NRMOP_SA_PROFILE_SELECTED_01['counter_id']}
    ...    dic_path=${Trunk_NRMOP_SA_PROFILE_SELECTED_01['dic_path']}
    ...    gnb_id=${Trunk_NRMOP_SA_PROFILE_SELECTED_01['gnb_id']}

Check counter for D001
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM_REDIR['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM_REDIR['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM_REDIR['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NRRCC_RRC_RELEASE_REDIR_NR['counter_id']}
    ...    dic_path=${NRRCC_RRC_RELEASE_REDIR_NR['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NRRCC_RRC_RELEASE_REDIR_NR['gnb_id']}
    Check gnb counter contain expected_value
    ###chat with cindy on 20230202 from Elva email,the counter trigger 710 profile,it can be 1 or 2
    ###20230215 Add Feature ID:5GC000710-C;backlog ID:FCA_5GIV-11291;requirement ID:5G_CP_IF_RRC_1658
    ###20230216 Add Feature ID:CB006112-5G-B;backlog ID:FPB-484207;requirement ID:5G_RAN_USR_RRM_4852,just add
    ...    counter_id=${NRMOP_SA_PROFILE_SELECTED_01['counter_id']}
    ...    dic_path=${NRMOP_SA_PROFILE_SELECTED_01['dic_path']}
    ...    gnb_id=${NRMOP_SA_PROFILE_SELECTED_01['gnb_id']}

Check trunk counter for D010
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_SA_UE_CTX_REL_PREEM_REDIR_D010['counter_id']}
    ...    dic_path=${Trunk_SA_UE_CTX_REL_PREEM_REDIR_D010['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${Trunk_SA_UE_CTX_REL_PREEM_REDIR_D010['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_D010['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_D010['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_D010['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_5QI1_D010['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_5QI1_D010['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_5QI1_D010['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_PMQAP_D010['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_PMQAP_D010['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_PREEM_RE_PMQAP_D010['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NRRCC_RRC_RELEASE_REDIR_NR_D010['counter_id']}
    ...    dic_path=${Trunk_NRRCC_RRC_RELEASE_REDIR_NR_D010['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${Trunk_NRRCC_RRC_RELEASE_REDIR_NR_D010['gnb_id']}

Check counter for D010
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${SA_UE_CTX_REL_PREEM_REDIR_D010['counter_id']}
    ...    dic_path=${SA_UE_CTX_REL_PREEM_REDIR_D010['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${SA_UE_CTX_REL_PREEM_REDIR_D010['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_D010['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_D010['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_D010['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1_D010['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_5QI1_D010['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_5QI1_D010['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP_D010['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP_D010['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_REL_GNB_PREEM_RE_PMQAP_D010['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NRRCC_RRC_RELEASE_REDIR_NR_D010['counter_id']}
    ...    dic_path=${NRRCC_RRC_RELEASE_REDIR_NR_D010['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NRRCC_RRC_RELEASE_REDIR_NR_D010['gnb_id']}

####temporary checkpoint
Check wireshark log for D010_2
    ${timerRejectWait_values}=    get BTS parameter value    class_name=NRBTS    Abbreviation=timerRejectWait
#    ${UE_NGAP_ID}=    Get HO-RAN-UE-NGAP-ID message     logname=${log_name_D_001_3}
#    Set Suite Variable    ${preemption_ue_id}    ${UE_NGAP_ID}
    Set Suite Variable    ${timerRejectWait_value}    ${timerRejectWait_values}
    Check SA preempted success message    logname=${log_name_D_010_3}
#    Check D010_SA preempted success message    logname=${log_name_D_010_3}
    Check D010_SA preempted success keep VONR on gnb1 cell2    logname=${log_name_D_010_3}

Check D010_SA preempted success message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ##########################################preempted ue part##################################################
    ####UE CONTEXT RELEASE REQUEST(NGAP)
    ${UCRR_filter}=     Catenate
    ...    ngap.NGAP_PDU == 0 and ngap.procedureCode == 42 and ngap.RAN_UE_NGAP_ID == ${SA_preempted_ue_id}
    Log To Console    check UE CONTEXT RELEASE REQUEST
    ${UCRR_packets}=    cap.filter_packets_by_expression    filter_expression=${UCRR_filter}
    ${ngap_radioNetwork}=     cap.get_field_value_by_xpath    pdml_list=${UCRR_packets}
    ...                                                xpath=.//ngap.radioNetwork
    Run Keyword If    '${actRedirect_status}' == 'True'    Should Be Equal    ${ngap_radioNetwork}[0]    41
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Should Be Equal    ${ngap_radioNetwork}[0]    46

    ####UE CONTEXT RELEASE COMMAND(NGAP)
    ${UCRC_filter} =    Catenate
    ...    ngap.NGAP_PDU == 0 and ngap.procedureCode == 41 and ngap.RAN_UE_NGAP_ID == ${SA_preempted_ue_id}
    Log To Console    check UE CONTEXT RELEASE COMMAND
    ${UCRC_packets}=    filter_packets_by_expression    filter_expression=${UCRC_filter}
    ${ngap_radioNetwork} =    get_field_value_by_xpath    pdml_list=${UCRC_packets}
    ...                                                xpath=.//ngap.radioNetwork
    Run Keyword If    '${actRedirect_status}' == 'True'    Should Be Equal    ${ngap_radioNetwork}[0]    41
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Should Be Equal    ${ngap_radioNetwork}[0]    46

    ####BEARER CONTEXT RELEASE COMMAND(E1AP)
    ${BCRC_filter} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 11
    Log To Console    check BEARER CONTEXT RELEASE COMMAND
    ${BCRC_packets}=    filter_packets_by_expression    filter_expression=${BCRC_filter}
    ${e1ap_radioNetwork} =    get_field_value_by_xpath    pdml_list=${BCRC_packets}
    ...    xpath=.//e1ap.radioNetwork
    Run Keyword If    '${actRedirect_status}' == 'True'    Should Be Equal    ${e1ap_radioNetwork}[0]    27
    ...    ELSE IF    '${actRedirect_status}' == 'False'    Should Be Equal    ${e1ap_radioNetwork}[0]    27
#    ####RRCRelease(F1AP/NR RRC)
#    ${RRCRelease_filter} =    Run Keyword If    '${actRedirect_status}' == 'True'    Catenate
#    ...    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 6 and f1ap.radioNetwork == 16
#    ...    ELSE IF    '${actRedirect_status}' == 'False'    Catenate
#    ...    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 6 and f1ap.radioNetwork == 16
#    Log To Console    check RRCRelease
#    ${RRCRelease_packets}=    filter_packets_by_expression    filter_expression=${RRCRelease_filter}
#    ${f1ap_radioNetwork} =    get_field_value_by_xpath    pdml_list=${RRCRelease_packets}
#    ...    xpath=.//f1ap.radioNetwork
#    ${nr-rrc_waitTime} =    get_field_value_by_xpath    pdml_list=${RRCRelease_packets}
#    ...    xpath=.//nr-rrc.waitTime
#    Run Keyword If    '${f1ap_radioNetwork}[0]' == '${16}'    Should Be Equal    '${nr-rrc_waitTime}[0]'    '${timerRejectWait_value}'
#    ${nr_rrc_deprioritisationType} =    get_field_value_by_xpath    pdml_list=${RRCRelease_packets}
#    ...    xpath=.//nr-rrc.deprioritisationType
#    Should Be Equal    ${nr_rrc_deprioritisationType}[0]    0
#    ${nr_rrc_deprioritisationTimer} =    get_field_value_by_xpath    pdml_list=${RRCRelease_packets}
#    ...    xpath=.//nr-rrc.deprioritisationTimer
#    Should Be Equal    ${nr_rrc_deprioritisationTimer}[0]    0
    ####UE CONTEXT RELEASE COMPLETE(NGAP)
    ${UCRC_filter}=     Catenate
    ...    ngap.NGAP_PDU == 1 and ngap.procedureCode == 41 and ngap.RAN_UE_NGAP_ID == ${SA_preempted_ue_id}
    Log To Console    check UE CONTEXT RELEASE COMPLETE
    ${UCRC_packets}=    cap.filter_packets_by_expression    filter_expression=${UCRC_filter}
    ${ngap_RAN_UE_NGAP_ID}=     cap.get_field_value_by_xpath    pdml_list=${UCRC_packets}
    ...                                                xpath=.//ngap.RAN_UE_NGAP_ID
    Should Be Equal    ${ngap_RAN_UE_NGAP_ID}[0]    ${SA_preempted_ue_id}

Check D001_SA preempted success keep VONR on gnb2 cell
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ##########################################preempted ue part##################################################
    ####InitialContextSetupResponse(NGAP)
    ${ICSR_Response_filter}=     Catenate     ngap.procedureCode == 14 and ngap.NGAP_PDU == 1
    Log To Console    check InitialContextSetupResponse
    ${ICSR_Response_packets}=    cap.filter_packets_by_expression    filter_expression=${ICSR_Response_filter}
    ${ngap_NGAP_PDU}=     cap.get_field_value_by_xpath    pdml_list=${ICSR_Response_packets}
    ...                                                xpath=.//ngap.NGAP_PDU
    Should Be Equal    ${ngap_NGAP_PDU[0]}    1

Check B012_SA preempted success keep L3Call on gnb2 cell
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ##########################################preempted ue part##################################################
    ####InitialContextSetupRequest,service accept(NGAP/NAS-5GS)-MDRB 6789,preempted UE DRB 8 ARP=8,preemption UE DRB 8 ARP=4,
    ${ICSR_service_accept_filter}=     Catenate    ngap.procedureCode == 14 and ngap.fiveQI == 8 and ngap.priorityLevelARP == 8
    Log To Console    check InitialContextSetupRequest,service accept
    ${ICSR_service_accept_packets}=    cap.filter_packets_by_expression    filter_expression=${ICSR_service_accept_filter}
    ${ngap_priorityLevelARP}=     cap.get_field_value_by_xpath    pdml_list=${ICSR_service_accept_packets}
    ...                                                xpath=.//ngap.priorityLevelARP
    Sort List    ${ngap_priorityLevelARP}
    Lists Should be Equal    ${ngap_priorityLevelARP}    ${ngap_priorityLevelARP_value}
    ####InitialContextSetupResponse(NGAP)
    ${ICSR_Response_filter}=     Catenate     ngap.procedureCode == 14 and ngap.NGAP_PDU == 1
    Log To Console    check InitialContextSetupResponse
    ${ICSR_Response_packets}=    cap.filter_packets_by_expression    filter_expression=${ICSR_Response_filter}
    ${ngap_NGAP_PDU}=     cap.get_field_value_by_xpath    pdml_list=${ICSR_Response_packets}
    ...                                                xpath=.//ngap.NGAP_PDU
    Should Be Equal    ${ngap_NGAP_PDU[0]}    1

Check D010_SA preempted success keep VONR on gnb1 cell2
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ##########################################preempted ue part##################################################
    ####InitialContextSetupResponse(NGAP)
    ${ICSR_Response_filter}=     Catenate     ngap.procedureCode == 14 and ngap.NGAP_PDU == 1
    Log To Console    check InitialContextSetupResponse
    ${ICSR_Response_packets}=    cap.filter_packets_by_expression    filter_expression=${ICSR_Response_filter}
    ${ngap_NGAP_PDU}=     cap.get_field_value_by_xpath    pdml_list=${ICSR_Response_packets}
    ...                                                xpath=.//ngap.NGAP_PDU
    Should Be Equal    ${ngap_NGAP_PDU[0]}    1

Multi UE Type Attach
    [Arguments]    ${ue_index}=${0}    ${gnb_index}=${0}
    Step1: UE attach    ue_type=${tl.ues[${ue_index}].capabilities[2]}   ue_index=${ue_index}    gnb_index=${gnb_index}

Multi UE Type Detach
    [Arguments]    ${ue_index}=${0}
    Step4: Detach UE    ue_type=${tl.ues[${ue_index}].capabilities[2]}     ue_index=${2}

Multi UE switch APN
    [Arguments]    ${usedapn}=${usedapn}    ${ue_index}=${0}
    choice required APN on UE    usedapn=${usedapn}    ue_type=${tl.ues[${ue_index}].capabilities[2]}    ue_index=${ue_index}

Multi UE switch Network Mode
    [Arguments]    ${ue_index}=${0}    ${mode_selection}=SA
    change UE 5G mode    ue_type=${tl.ues[${ue_index}].capabilities[2]}    ue_index=${ue_index}    mode_selection=${mode_selection}

Switch APN to muti DRB
    [Arguments]    ${apn_name}=${wap2.nokia.com}     ${ui_version}=${None}       ${ue_index}=${0}    ${gnb_index}=${0}
    Run Keyword And Ignore Error    Step1: UE attach    ue_type=${tl.ues[${ue_index}].capabilities[2]}   ue_index=${ue_index}
    ...    gnb_index=${gnb_index}
    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    ui_version=${ui_version}
    run keyword and ignore error    UE.UE Detach     ue_type=${tl.ues[${ue_index}].capabilities[2]}     ue_index=${ue_index}

Recover Switch APN to muti DRB
    [Arguments]    ${apn_name}=${wap2.nokia.com}     ${ui_version}=${None}       ${ue_index}=${0}    #${gnb_index}=${0}
    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    ui_version=${ui_version}
    UE.UE Detach     ue_type=${tl.ues[${ue_index}].capabilities[2]}     ue_index=${ue_index}

S21 switch APN
    [Arguments]    ${usedapn}     ${ue_index}=${2}
    Multi UE switch APN    usedapn=${usedapn}    ue_index=${ue_index}
    make WA with Samsung S21    ue_index=${ue_index}

S21 UE attach
    [Arguments]    ${ue_type}     ${ue_index}=${2}    ${gnb_index}=${0}
    Step1: UE attach     ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    sleep    20s
    make WA with Samsung S21    ue_index=${ue_index}

8698_D01_recover_parameters
    IF    '${release_flag}' == '0000'
        Online modify parmeters    parameters_to_update=${PARAM_8698_recover_Targetgnb1_D_001_maxNumOfUsersNRCell}
    ELSE
        IF    '${enb_instance}'=='${diffTL_enb_ID}[0]'    #TL367
            Online modify parmeters     parameters_to_update=${PARAM_8698_recover_Targetgnb1_D_001_maxNumOfUsersPerNRCell}
        ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    #TL382
            Online modify parmeters     parameters_to_update=${PARAM_8698_recover_Targetgnb1_D_001_maxNumOfUsersPerNRCell_382}
        END
    END
