*** Settings ***
Documentation
...    author: Zhang Yayun
...    contact: yayun.zhang@nokia-sbell.com
...    squal group: SG03
...    feature: CB008246-M

Force Tags  CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...             robot_common_operations.Common Suite Setup
...             AND    Get gnb release info    
...             AND    Run Keyword If    '${release_info}' == 'SBTS25R1_ENB_9999'
...             Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}_specious}
...             ELSE    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${specious_scf}
...             AND    Common Suite Setup for COAM
...             AND    Common UE parameter setup

Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_common_keywords.robot

*** Variables ***
${log_name_M_005_1}    log_name_M_005_1.pcap
${log_name_M_005_2}    log_name_M_005_2.pcap
${expected_tput_dl}    300
${Send_Tput_DL}        600M
${Send_Tput_DL_5QI3}        30M
${expected_tput_ul}    1
${expected_tput_ul_5QI3}    1
${Send_Tput_UL}        200M
${Send_Tput_UL_5QI3}        10M
${M005_expected_tput_dl}    150
${M005_expected_tput_dl_5QI3}    15
${Send_Tput_IMS_DL}    10M

${zzmdrb2_apn_name}    ${tl.ues[0].pdn[5]}
${wap2_apn_name}    ${tl.ues[0].pdn[0]}
${ui_version}    emui 10.1.0

${specious_scf}    Configuration_scf_GNB1_CB008246_Q.xml
${tl_scf_SBTS25R1_ENB_9999_specious}    25R1_Configuration_scf_GNB1_CB008246_specious.xml

*** Test Cases ***
[1]CB008246-M_005_HRDRB_BRDRB_setup_via_ICS_when_UE_not_support_DLUL_64QAM_MSC_TableAlt
    [Documentation]    CB008246-M
    [Tags]    CB008246-M   CRT_TRUNK
    [Timeout]    2 hour
    [Setup]
    robot_common_operations.Common Case Setup
    Modify Parameters for Cases    gnb_index=${0}    Modify_Para_Online=${PARAM_8246_gnb1_M_005}
    ...    Delete_Para_Online=${PARAM_8246_delete_gnb1_M_005}
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    Comment    change APN to mdrb2.nokia.com
    power_ue.Prepare UE    ue_type=${ue_type1}    ue_index=${0}
    Switch APN to muti DRB    ue_index=${0}    ue_type=${ue_type1}    apn_name=${zzmdrb2_apn_name}    ui_version=${ui_version}
    Comment    UE1 attach on gnb1 cell2
    Start capture gNB log on master    filename=${log_name_M_005_1}
    Power_ue.Prepare UE    ue_type=${ue_type1}    ue_index=${0}
    Attach and check power UE    ue_type=${ue_type1}    ue_index=${0}    gnb_index=${0}
    Sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_M_005_1}
    Check wireshark log for 8246_M005_1
    Comment    Check mdrb2 5QI7 HR-BR-HR
    Check mdrb2 5QI7 HR-BR-HR
    sleep    5s
    Comment    Check mdrb2 5QI3 HR-BR-HR
    Check mdrb2 5QI3 HR-BR-HR
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    
    ...    AND    Switch APN to muti DRB    ue_index=${0}    ue_type=${ue_type1}    apn_name=${wap2_apn_name}    ui_version=${ui_version}
    ...    AND    UE.UE Detach     ue_type=${ue_type1}     ue_index=${0}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_M_005_1}
    ...    AND    Modify Parameters for Cases    gnb_index=${0}    Modify_Para_Online=${PARAM_8246_recover_gnb1_M_005}
    ...    Delete_Para_Online=${PARAM_8246_recover_delete_gnb1_M_005}
    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    ...    AND    Adjust HBTE gNB_eNB_RU Attenuation
    ...    AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}
    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown


*** Keywords ***
Check mdrb2 5QI7 HR-BR-HR
    Comment    5QI7 DL+UL trafic
    Start only DL traffic and check tput    ue_index=${0}    cellid=2    ue_type=${ue_type1}    gnb_index=${0}
    ...                                tput_dl_cell=${M005_expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=7200
    ...                                dl_port=${tl.ues[0].iperf_details.port}
    sleep    10s
    Comment    5QI 7 HR analysis
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_5QI7_DL_1     nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI7_DL_1    nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI7_DL_1    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI7_DL_1    nr_phy_cell_ids=60
    Analysis tti for M005_1    names=l2stream3_ttitrace_5QI7_DL_1

    Comment    BR analysis:Increase attenuation slowly to trigger UE below MCS2,L2PS shall switch from HR to BR
    Comment     gnb1 cell2 PA to 57db to trigger HR to BR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${57}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
    sleep    15s
    Comment     gnb1 cell2 PA to 57db to trigger HR to BR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust Signal HBTE gNB_eNB_RU Attenuation
    ...                                                                gnb1_cell2_p3_value=${57}    gnb1_cell2_p4_value=${127}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${60}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
    sleep    15s
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_5QI7_DL_2     nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI7_DL_2    nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI7_DL_2    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI7_DL_2    nr_phy_cell_ids=60
    Analysis tti for M005_3    names=l2stream3_ttitrace_5QI7_DL_2

    Comment     HR analysis:Continue to decrease attenuation slowly to trigger UE above MCS10,L2PS shall switch from BR to HR
    Comment     gnb1 cell2 PA to 0db to trigger BR to HR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    sleep    30s
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_5QI7_DL_3    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI7_DL_3    nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI7_DL_3    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI7_DL_3    nr_phy_cell_ids=60
    Analysis tti for M005_4    names=l2stream3_ttitrace_5QI7_DL_3


    Start only UL traffic and check tput    ue_index=${0}    cellid=${2}    ue_type=${ue_type1}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
    ...                                ul_port=${tl.ues[0].iperf_details.port}    iperf_type=via_app
    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type1}    direction=DL    iperf_port=${tl.ues[0].iperf_details.port}
    sleep    10s
    Comment    5QI 7 HR analysis
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_5QI7_UL_1    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI7_UL_1    nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI7_UL_1    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI7_UL_1    nr_phy_cell_ids=60
    Analysis tti for M005_1_UL    names=l2stream3_ttitrace_5QI7_UL_1

    Comment    BR analysis:Increase attenuation slowly to trigger UE below MCS2,L2PS shall switch from HR to BR
    Comment     gnb1 cell2 PA to 57db to trigger HR to BR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${50}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${50}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${50}
    sleep    15s
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_5QI7_UL_2    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI7_UL_2    nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI7_UL_2    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI7_UL_2    nr_phy_cell_ids=60
    Analysis tti for M005_3_UL    names=l2stream3_ttitrace_5QI7_UL_2

    Comment     HR analysis:Continue to decrease attenuation slowly to trigger UE above MCS10,L2PS shall switch from BR to HR
    Comment     gnb1 cell2 PA to 0db to trigger BR to HR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    sleep    30s
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_5QI7_UL_3    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI7_UL_3    nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI7_UL_3    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI7_UL_3    nr_phy_cell_ids=60
    Analysis tti for M005_4_UL    names=l2stream3_ttitrace_5QI7_UL_3

    [Teardown]     Run Keywords
    ...    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type1}    direction=DL    iperf_port=${tl.ues[0].iperf_details.port}    AND
    ...    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type1}    direction=UL    iperf_port=${tl.ues[0].iperf_details.port}

Check mdrb2 5QI3 HR-BR-HR
    Comment    5QI3 DL+UL trafic
    Start only DL traffic and check tput    ue_index=${0}    cellid=2    ue_type=${ue_type1}    gnb_index=${0}
    ...                                tput_dl_cell=${M005_expected_tput_dl_5QI3}    dl_throughput=${Send_Tput_DL_5QI3}    duration=7200
    ...                                dl_port=${tl.ues[0].iperf_details.ssh_connection_details.port}
    sleep    10s
    Comment    5QI 3 HR  analysis
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_5QI3_DL_1    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI3_DL_1    nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI3_DL_1    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI3_DL_1    nr_phy_cell_ids=60
    Analysis tti for M005_1    names=l2stream3_ttitrace_5QI3_DL_1
    Comment    BR analysis:Increase attenuation slowly to trigger UE below MCS2,L2PS shall switch from HR to BR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${56}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${57}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${51}
    sleep    15s
    Comment     gnb1 cell2 gnb1_cell2_p3 to 51db to trigger HR to BR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${60}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${60}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${60}
    sleep    15s
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'
#    ...                                          Adjust Signal HBTE gNB_eNB_RU Attenuation    gnb1_cell2_p3_value=${51}    gnb1_cell2_p4_value=${127}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'
#    ...                                          Adjust Signal HBTE gNB_eNB_RU Attenuation    gnb1_cell2_p3_value=${48}    gnb1_cell2_p4_value=${127}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'
#    ...                                          Adjust Signal HBTE gNB_eNB_RU Attenuation    gnb1_cell2_p3_value=${51}    gnb1_cell2_p4_value=${127}
#    sleep    120s
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_5QI3_DL_2    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI3_DL_2    nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI3_DL_2    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI3_DL_2    nr_phy_cell_ids=60
    Analysis tti for M005_3    names=l2stream3_ttitrace_5QI3_DL_2
    Comment     HR analysis:Continue to decrease attenuation slowly to trigger UE above MCS10,L2PS shall switch from BR to HR
    Comment     gnb1 cell2 PA to 0db to trigger BR to HR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    sleep    30s
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_5QI3_DL_3    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI3_DL_3    nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI3_DL_3    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI3_DL_3    nr_phy_cell_ids=60

    Analysis tti for M005_4    names=l2stream3_ttitrace_5QI3_DL_3



    Start only UL traffic and check tput    ue_index=${0}    cellid=${2}    ue_type=${tl.ues[0].capabilities[2]}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul_5QI3}    ul_throughput=${Send_Tput_UL_5QI3}    duration=${7200}
    ...                                ul_port=${tl.ues[0].iperf_details.ssh_connection_details.port}    iperf_type=via_app
    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type1}    direction=DL    iperf_port=${tl.ues[0].iperf_details.ssh_connection_details.port}
    sleep    10s
    Comment    5QI 3 HR  analysis
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_5QI3_UL_1    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI3_UL_1    nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI3_UL_1    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI3_UL_1    nr_phy_cell_ids=60

    Analysis tti for M005_1_UL    names=l2stream3_ttitrace_5QI3_UL_1
    Comment    BR analysis:Increase attenuation slowly to trigger UE below MCS2,L2PS shall switch from HR to BR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${49}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${50}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${51}
    sleep    15s
#    Comment     gnb1 cell2 gnb1_cell2_p3 to 51db to trigger HR to BR
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'
#    ...                                          Adjust Signal HBTE gNB_eNB_RU Attenuation    gnb1_cell2_p3_value=${51}    gnb1_cell2_p4_value=${127}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'
#    ...                                          Adjust Signal HBTE gNB_eNB_RU Attenuation    gnb1_cell2_p3_value=${48}    gnb1_cell2_p4_value=${127}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'
#    ...                                          Adjust Signal HBTE gNB_eNB_RU Attenuation    gnb1_cell2_p3_value=${51}    gnb1_cell2_p4_value=${127}
#    sleep    120s
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_5QI3_UL_2    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI3_UL_2     nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI3_UL_2     nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI3_UL_2     nr_phy_cell_ids=60
    Analysis tti for M005_3_UL    names=l2stream3_ttitrace_5QI3_UL_2
    Comment     HR analysis:Continue to decrease attenuation slowly to trigger UE above MCS10,L2PS shall switch from BR to HR
    Comment     gnb1 cell2 PA to 0db to trigger BR to HR
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
    sleep    30s
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_5QI3_UL_3    nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI3_UL_3     nr_phy_cell_ids=56
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI3_UL_3     nr_phy_cell_ids=53
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Capture Ttitrace tti from WEBUI    names=l2stream3_ttitrace_5QI3_UL_3     nr_phy_cell_ids=60
    Analysis tti for M005_4_UL    names=l2stream3_ttitrace_5QI3_UL_3

    [Teardown]     Run Keywords
    ...    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type1}    direction=DL
    ...    iperf_port=${tl.ues[0].iperf_details.ssh_connection_details.port}    AND
    ...    Stop DL or UL traffic    ue_index=${0}    ue_type=${tl.ues[0].capabilities[2]}    direction=UL
    ...    iperf_port=${tl.ues[0].iperf_details.ssh_connection_details.port}

#Check mdrb2 5QI7 HR-BR-HR
#    Comment    5QI7 DL+UL trafic
#    Start only DL traffic and check tput    ue_index=${0}    cellid=2    ue_type=${ue_type1}    gnb_index=${0}
#    ...                                tput_dl_cell=${M005_expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=7200
#    ...                                dl_port=${tl.ues[0].iperf_details.port}
#    Start only UL traffic and check tput    ue_index=${0}    cellid=${2}    ue_type=${ue_type1}    gnb_index=${0}
#    ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}
#    ...                                ul_port=${tl.ues[0].iperf_details.port}    iperf_type=via_app
#    sleep    10s
#    Comment    5QI 7 HR analysis
#    Capture Ttitrace With Admin Mode and Convert format    nr_phy_cell_ids=53
#    Analysis tti for M005_1    names=l2stream3_ttitrace
#    Analysis tti for M005_1_UL    names=l2stream3_ttitrace
#
#    Comment    BR analysis:Increase attenuation slowly to trigger UE below MCS2,L2PS shall switch from HR to BR
#    Comment     gnb1 cell2 PA to 57db to trigger HR to BR
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${57}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
#    sleep    15s
#    Comment     gnb1 cell2 PA to 57db to trigger HR to BR
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${60}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${55}
#    sleep    60s
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_3    nr_phy_cell_ids=53
#    Analysis tti for M005_3    names=l2stream3_ttitrace_3
#    Analysis tti for M005_3_UL    names=l2stream3_ttitrace_3
#
#    Comment     HR analysis:Continue to decrease attenuation slowly to trigger UE above MCS10,L2PS shall switch from BR to HR
#    Comment     gnb1 cell2 PA to 0db to trigger BR to HR
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
#    sleep    60s
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_4    nr_phy_cell_ids=53
#    Analysis tti for M005_4    names=l2stream3_ttitrace_4
#    Analysis tti for M005_4_UL    names=l2stream3_ttitrace_4
#    [Teardown]     Run Keywords
#    ...    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type1}    direction=DL    iperf_port=${tl.ues[0].iperf_details.port}    AND
#    ...    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type1}    direction=UL    iperf_port=${tl.ues[0].iperf_details.port}
#
#Check mdrb2 5QI3 HR-BR-HR
#    Comment    5QI3 DL+UL trafic
#    Start only DL traffic and check tput    ue_index=${0}    cellid=2    ue_type=${ue_type1}    gnb_index=${0}
#    ...                                tput_dl_cell=${M005_expected_tput_dl_5QI3}    dl_throughput=${Send_Tput_DL_5QI3}    duration=7200
#    ...                                dl_port=${tl.ues[0].iperf_details.ssh_connection_details.port}
#    Start only UL traffic and check tput    ue_index=${0}    cellid=${2}    ue_type=${tl.ues[0].capabilities[2]}    gnb_index=${0}
#    ...                                tput_ul_cell=${expected_tput_ul_5QI3}    ul_throughput=${Send_Tput_UL_5QI3}    duration=${7200}
#    ...                                ul_port=${tl.ues[0].iperf_details.ssh_connection_details.port}    iperf_type=via_app
#    Comment    5QI 3 HR  analysis
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_5    nr_phy_cell_ids=53
#    Analysis tti for M005_1    names=l2stream3_ttitrace_5
#    Analysis tti for M005_1_UL    names=l2stream3_ttitrace_5
#    Comment    BR analysis:Increase attenuation slowly to trigger UE below MCS2,L2PS shall switch from HR to BR
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${51}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${51}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${51}
#    sleep    15s
#    Comment     gnb1 cell2 gnb1_cell2_p3 to 51db to trigger HR to BR
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'
#    ...                                          Adjust Signal HBTE gNB_eNB_RU Attenuation    gnb1_cell2_p3_value=${51}    gnb1_cell2_p4_value=${127}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'
#    ...                                          Adjust Signal HBTE gNB_eNB_RU Attenuation    gnb1_cell2_p3_value=${51}    gnb1_cell2_p4_value=${127}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'
#    ...                                          Adjust Signal HBTE gNB_eNB_RU Attenuation    gnb1_cell2_p3_value=${51}    gnb1_cell2_p4_value=${127}
#    sleep    60s
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_6    nr_phy_cell_ids=53
#    Analysis tti for M005_3    names=l2stream3_ttitrace_6
#    Analysis tti for M005_3_UL    names=l2stream3_ttitrace_6
#    Comment     HR analysis:Continue to decrease attenuation slowly to trigger UE above MCS10,L2PS shall switch from BR to HR
#    Comment     gnb1 cell2 PA to 0db to trigger BR to HR
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
#    ...    ELSE IF    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell2_value=${0}
#    sleep    60s
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_7    nr_phy_cell_ids=53
#    Analysis tti for M005_4    names=l2stream3_ttitrace_7
#    Analysis tti for M005_4_UL    names=l2stream3_ttitrace_7
#    [Teardown]     Run Keywords
#    ...    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type1}    direction=DL
#    ...    iperf_port=${tl.ues[0].iperf_details.ssh_connection_details.port}    AND
#    ...    Stop DL or UL traffic    ue_index=${0}    ue_type=${tl.ues[0].capabilities[2]}    direction=UL
#    ...    iperf_port=${tl.ues[0].iperf_details.ssh_connection_details.port}

Analysis tti for M005_1
    [Arguments]    ${names}
    log to console    analysis HR DL tti file from Case_Logs file...
    ${dlFdSchedData_rrmDlUsedMcs}    get_dlFdSchedData_rrmDlUsedMcs_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=rnti     filter_name2=dlFdSchedData.rrmDlUsedMcs    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{dlFdSchedData_rrmDlUsedMcs}
        should be true      ${${i}}<=${${28.0}}
    END
#    ${col_data_targetBLER}    get_dlFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_dl.csv    filter_name=dlFdSchedData.targetBLER
#    FOR  ${i}    IN    @{col_data_targetBLER}
#        should be equal      ${${i}}    ${${0.01}}
#    END
    ${hr_dlFdSchedData_targetBLER}    get_dlFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=rnti     filter_name2=dlFdSchedData.targetBLER    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{hr_dlFdSchedData_targetBLER}
        should be equal      ${${i}}    ${${0.01}}
    END
#    ${col_data_mcsTable}    get_dlFdSchedData_mcsTable_value    csv_file=${epc_log_path}/${names}_dl.csv     filter_name=dlFdSchedData.mcsTable
    ${dlFdSchedData_mcsTable}    get_dlFdSchedData_mcsTable_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=rnti     filter_name2=dlFdSchedData.mcsTable    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{dlFdSchedData_mcsTable}
        should be equal      ${i}    QAM64
    END
#    ${col_data_laMode}    get_dlFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_dl.csv     filter_name=dlFdSchedData.laMode
    ${dlFdSchedData_laMode}    get_dlFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=rnti     filter_name2=dlFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{dlFdSchedData_laMode}
        should be equal      ${i}    HIGHRELIABILITY
    END
#    ${col_data_aggregationLevel}    get_dlFdSchedData_aggregationLevel_value    csv_file=${epc_log_path}/${names}_dl.csv
    ${dlFdSchedData_aggregationLevel}    get_dlFdSchedData_aggregationLevel_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=rnti     filter_name2=dlFdSchedData.aggregationLevel    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{dlFdSchedData_aggregationLevel}
        should be equal      ${i}    4.0
    END

Analysis tti for M005_3
    [Arguments]    ${names}
    log to console    analysis BR DL tti file from Case_Logs file...
#    ${col_data_targetBLER}    get_dlFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_dl.csv    filter_name=dlFdSchedData.targetBLER
#    FOR  ${i}    IN    @{col_data_targetBLER}
#        should be equal      ${${i}}    ${${0.1}}
    ${hr_dlFdSchedData_targetBLER}    get_dlFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=rnti     filter_name2=dlFdSchedData.targetBLER    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{hr_dlFdSchedData_targetBLER}
        should be equal      ${${i}}    ${${0.1}}
    END
#    ${col_data_laMode}    get_dlFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_dl.csv     filter_name=dlFdSchedData.laMode
    ${dlFdSchedData_laMode}    get_dlFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=rnti     filter_name2=dlFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{dlFdSchedData_laMode}
        should be equal      ${i}    BASICRELIABILITY
    END

Analysis tti for M005_4
    [Arguments]    ${names}
    log to console    analysis HR DL tti file from Case_Logs file...
#    ${col_data_new}    get_dlFdSchedData_rrmDlUsedMcs_value    csv_file=${epc_log_path}/${names}_dl.csv     filter_name=dlFdSchedData.rrmDlUsedMcs
    ${dlFdSchedData_rrmDlUsedMcs}    get_dlFdSchedData_rrmDlUsedMcs_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=rnti     filter_name2=dlFdSchedData.rrmDlUsedMcs    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{dlFdSchedData_rrmDlUsedMcs}
        should be true      ${${i}}<=${${28.0}}
    END
#    ${col_data_targetBLER}    get_dlFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_dl.csv    filter_name=dlFdSchedData.targetBLER
#    FOR  ${i}    IN    @{col_data_targetBLER}
#        should be equal      ${${i}}    ${${0.01}}
#    END
    ${hr_dlFdSchedData_targetBLER}    get_dlFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=rnti     filter_name2=dlFdSchedData.targetBLER    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{hr_dlFdSchedData_targetBLER}
        should be equal      ${${i}}    ${${0.01}}
    END
#    ${col_data_mcsTable}    get_dlFdSchedData_mcsTable_value    csv_file=${epc_log_path}/${names}_dl.csv     filter_name=dlFdSchedData.mcsTable
    ${dlFdSchedData_mcsTable}    get_dlFdSchedData_mcsTable_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=rnti     filter_name2=dlFdSchedData.mcsTable    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{dlFdSchedData_mcsTable}
        should be equal      ${i}    QAM64
    END
#    ${col_data_laMode}    get_dlFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_dl.csv     filter_name=dlFdSchedData.laMode
    ${dlFdSchedData_laMode}    get_dlFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=rnti     filter_name2=dlFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{dlFdSchedData_laMode}
        should be equal      ${i}    HIGHRELIABILITY
    END
#    ${col_data_aggregationLevel}    get_dlFdSchedData_aggregationLevel_value    csv_file=${epc_log_path}/${names}_dl.csv
    ${dlFdSchedData_aggregationLevel}    get_dlFdSchedData_aggregationLevel_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=rnti     filter_name2=dlFdSchedData.aggregationLevel    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{dlFdSchedData_aggregationLevel}
        should be equal      ${i}    4.0
    END

Analysis tti for M005_1_UL
    [Arguments]    ${names}
    log to console    analysis HR UL tti file from Case_Logs file...
    ${ulFdSchedData_rrmUlUsedMcs}    get_ulFdSchedData_rrmUlUsedMcs_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.rrmUlUsedMcs    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_rrmUlUsedMcs}
        should be true      ${${i}}<=${${28.0}}
    END
#    ${col_data_targetBLER}    get_ulFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_ul.csv    filter_name=ulFdSchedData.targetBLER
#    FOR  ${i}    IN    @{col_data_targetBLER}
#        should be equal      ${${i}}    ${${0.01}}
#    END
    ${hr_ulFdSchedData_targetBLER}    get_ulFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.targetBLER    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{hr_ulFdSchedData_targetBLER}
        should be equal      ${${i}}    ${${0.01}}
    END
    ${ulFdSchedData_mcsTable}    get_ulFdSchedData_mcsTable_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.mcsTable    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_mcsTable}
        should be equal      ${i}    QAM64
    END
    ${ulFdSchedData_laMode}    get_ulFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_laMode}
        should be equal      ${i}    HIGHRELIABILITY
    END
    ${ulFdSchedData_aggregationLevel}    get_ulFdSchedData_aggregationLevel_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.aggregationLevel    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_aggregationLevel}
        should be equal      ${i}    4.0
    END

Analysis tti for M005_3_UL
    [Arguments]    ${names}
    log to console    analysis BR DL tti file from Case_Logs file...
#    ${col_data_targetBLER}    get_ulFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_ul.csv    filter_name=ulFdSchedData.targetBLER
#    FOR  ${i}    IN    @{col_data_targetBLER}
#        should be equal      ${${i}}    ${${0.1}}
#    END
    ${hr_ulFdSchedData_targetBLER}    get_ulFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.targetBLER    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{hr_ulFdSchedData_targetBLER}
        should be equal      ${${i}}    ${${0.1}}
    END
    ${ulFdSchedData_laMode}    get_ulFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_laMode}
        should be equal      ${i}    BASICRELIABILITY
    END

Analysis tti for M005_4_UL
    [Arguments]    ${names}
    log to console    analysis HR UL tti file from Case_Logs file...
    ${ulFdSchedData_rrmUlUsedMcs}    get_ulFdSchedData_rrmUlUsedMcs_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.rrmUlUsedMcs    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_rrmUlUsedMcs}
        should be true      ${${i}}<=${${28.0}}
    END
#    ${col_data_targetBLER}    get_ulFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_ul.csv    filter_name=ulFdSchedData.targetBLER
#    FOR  ${i}    IN    @{col_data_targetBLER}
#        should be equal      ${${i}}    ${${0.01}}
#    END
    ${hr_ulFdSchedData_targetBLER}    get_ulFdSchedData_targetBLER_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.targetBLER    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{hr_ulFdSchedData_targetBLER}
        should be equal      ${${i}}    ${${0.01}}
    END
    ${ulFdSchedData_mcsTable}    get_ulFdSchedData_mcsTable_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.mcsTable    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_mcsTable}
        should be equal      ${i}    QAM64
    END
    ${ulFdSchedData_laMode}    get_ulFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_laMode}
        should be equal      ${i}    HIGHRELIABILITY
    END
    ${ulFdSchedData_aggregationLevel}    get_ulFdSchedData_aggregationLevel_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.aggregationLevel    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_aggregationLevel}
        should be equal      ${i}    4.0
    END

#Switch APN to muti DRB
#    [Arguments]    ${apn_name}    ${ui_version}    ${ue_index}=${0}    ${ue_type}=${ue_type1}
#    Run Keyword And Ignore Error    Attach and check power UE   ue_type=${ue_type}
#    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    ui_version=${ui_version}
#    run keyword and ignore error    UE.UE Detach    ue_type=${ue_type}
#
#Android UE SwitchApn
#    [Documentation]
#    ...    Note: Use the keyword must be ensure that UE UI Menu is English language
#    ...    str ui_version: mobile ui version.
#    ...        e.g Magic UI 3.1.1, have tested on honor CDY-AN90 1080x2400,
#    ...            EMUI 10.1.0, have tested on huawei mate30 LIO-AN00 1176x2400.
#    ...            Qualcomm qti lahaina for arm64 ue do not have UI, so this field equal to '' or ${None}
#    ...           if mobile is mtk peturs, pass 'petrus' as ui_version.
#    [Arguments]       ${ue_index}=${0}    ${host}=${tl.ues[${ue_index}].ssh_connection_details.addr}
#    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
#    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}     ${ui_version}=${None}
#    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${apn_name}=mdrb    ${ue_alias}=UE_${ue_index}
#    android_mobile.setup
#    ...               ui_version=${ui_version}    host=${host}    username=${username}
#    ...               password=${password}    port=22     serial_number=${serial_number}    alias=${UE_alias}
#    run keyword and ignore error    android_mobile.switch_apn       apn_name=${apn_name}   mobile=${UE_alias}
#    android_mobile.teardown       mobile=${UE_alias}

Setup for Env cell on-air for 2 gnb modify scf first
    [Arguments]      ${ParamterToModify}=${PARAM_8246_gnb1_H_006_01}    ${ListParamterToModify}=${PARAM_list_8246_gnb1_H_006_01}
    Common Case TestLine Setup    ModifySCF_Beforecommission=True    is_commission_for_second_gnb=True
    ...    scf_path=${tl_scf_dir_path}    golden_scf_name=${tl_scf_file_name1}    golden_scf_name_gnb2=${tl_scf_file_name2}
    ...    ParamterToModify=${ParamterToModify}    ListParamterToModify=${ListParamterToModify}

Check wireshark log for 8246_H006_1
    Check UL_UE_MCS_table_Capbility    logname=${log_name_H_006_1}

Check UL_UE_MCS_table_Capbility
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.uplinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[1]}    1

Check wireshark log for 8246_M005_1
    Check DL_UE_No_MCS_table_Capbility    logname=${log_name_M_005_1}
    ${UE_RNTI_ID}=    Get RNTI-ID message    logname=${log_name_M_005_1}
    Set Suite Variable    ${SA_UE_RNTI_ID}    ${UE_RNTI_ID}

Check DL_UE_No_MCS_table_Capbility
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.downlinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Not Contain    ${nr_rrc_mcs_Table}    1

Get RNTI-ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####InitialULRRCMessageTransfer, RRC Setup Request
    ${RRC_Setup_request}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 11 and f1ap.C_RNTI)
    ${RRC_Setup_request_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Setup_request}
    ${UE_RNTI_ID}=     cap.get_field_value_by_xpath    pdml_list=${RRC_Setup_request_packets}
    ...                                                xpath=.//f1ap.C_RNTI
    [Return]    ${UE_RNTI_ID}[-1]

Get UE IP from wirehsark
    [Arguments]    ${logname}
    ...    ${message_filter}=ngap.procedureCode == 14 and nas_5gs.sm.pdu_addr_inf_ipv4
    ...    ${xpath}=.//nas_5gs.sm.pdu_addr_inf_ipv4
    Log    Get UE IP from wirehsark
    ${UE_IP}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    [Return]    ${UE_IP}[0]

Check wireshark log
    [Arguments]    ${logname}    ${message_filter}    ${xpath}    ${attribute_name}=show
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${filtered_result}=     cap.get_field_value_by_xpath    attribute_name=${attribute_name}    xpath=${xpath}    pcap_parser=test6
    [Return]    ${filtered_result}
