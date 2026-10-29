*** Settings ***
Documentation
...    Author: meiya.cheng
...    Contact: meiya.cheng@nokia-sbell.com
...    squad group: HAZ3_SG2
...    E2E Rjio



Suite Setup    robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown


Library    SSHLibrary    WITH NAME    ssh_lib
Library    ute_reporting_portal
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/kpi_reporter.py
Library    kpi_reporter.KpiReporter    WITH NAME    KpiReporter
Library    taf.hw.rf_attenuator    WITH NAME    atten
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot

Force Tags    PY36


*** Variables ***
#${X2_link_shutdown_time}    ${30}
#@{gci_list}    3    21
#${du_web_addr}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
#${du_web_usr}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
#${du_web_pwd}    ${tl.gnbs[0].cu.oam_http_connection_details.password}

${ue_type}    ${tl.ues[0].capabilities[2]}
#${du_ip}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
#${du_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
#${du_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#${maxMIMO_Layers_filter1}    nr-rrc.maxMIMO_Layers == 1 and nr-rrc.c1 == 0
#${maxMIMO_Layers_filter2}    nr-rrc.maxMIMO_Layers == 2 and nr-rrc.c1 == 0
#${xpath}    .//nr-rrc.uplinkConfig_element/nr-rrc.pusch_ServingCellConfig/nr-rrc.setup_element/nr-rrc.maxMIMO_Layers
#${rank_port1}    ${tl.attenuator.attenuator_ports[13].port_no}
#${rank_port2}    ${tl.attenuator.attenuator_ports[14].port_no}
#${attenuator_port}    ${tl.attenuator.port}


*** Test Cases ***
#[1]Rjio_AQQJ_4_Parallel_Operation_Cell_Barred_Unbarred_and_L3call
    #[Documentation]    Rjio_AQQJ_4_Parallel_Operation_Cell_Barred_Unbarred_and_L3call
    #[Tags]
    #[Timeout]    2h
    #Parallel_Operation_Cell_Barred_Unbarred

[1]Rjio_E2E_25_Data_Call_–_Dl_Ul_Throughput_Check
    [Documentation]    Rjio_E2E_25_Data_Call_Dl_Ul_Throughput_Check
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	Step1:Prepare UE
    Step2:UE Attach
    Start Traffic and Check TP
    [Teardown]     Case Teardown


#[1]Rjio_E2E_26_CA_Call
    #[Documentation]    Rjio_E2E_26_CA_Call
    #[Tags]
    #[Timeout]    1h
    #Set_PA_Value    value=${20}    attenuator_index=${2}
    #Prepare_UE_Only
    #L3call_Traffic_CA_CELL_21_3

#[1]Rjio_E2E_36_SRS-Based_SU-MIMO
    #[Documentation]    Rjio_E2E_36_SRS-Based_SU-MIMO
    #[Tags]
    #[Timeout]    1h
    #Set_PA_Value    value=${120}    attenuator_index=${2}
   # Prepare_UE_Only
    #L3call_Traffic_CELL_3

#[1]Rjio_E2E_37_Code_Book_Based_Ul_SU-Mimo_2_Layers
    #[Documentation]    Rjio_E2E_37_Code_Book_Based_Ul_SU-Mimo_2_Layers
    #[Tags]
    #[Timeout]    1h
    #Set_PA_Value    value=${120}    attenuator_index=${2}
    #Prepare_UE_Only
    #L3call_Traffic_CELL_3

#[1]Rjio_E2E_24_Site_Reset_With_L3_Call
    #[Documentation]    Rjio_E2E_24_Site_Reset_With_L3_Call
    #[Tags]
    #[Timeout]    1h
    #Selenium Login And Disable Screen Lock
    #Perform BTS Site Reset On WebUI
    #sleep    60s
    #Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    #Set_PA_Value    value=${20}    attenuator_index=${2}
    #Prepare_UE_Only
    #L3call_Traffic_CA_CELL_21_3
    #[Teardown]    run keywords    selenium logout and close browser    AND    SISO Coam Test Teardown

#[1]Rjio_AQQJ_3_Parallel_Operation_Cell_Lock_Unlock_and_L3call
    #[Documentation]    Rjio_AQQJ_3_Parallel_Operation_Cell_Lock_Unlock_and_L3call
    #[Tags]
    #[Timeout]    2h
    #Parallel_Operation_Cell_Lock_Unlock_and_L3call



#[1]Rjio_AQQJ_5_Parallel_Operation_RAT_Block_Unblock_and_L3call
    #[Documentation]    Rjio_AQQJ_5_Parallel_Operation_RAT_Block_Unblock_and_L3call
    #[Tags]
    #[Timeout]    2h
    #Parallel_Operation_RAT_Block_Unblock_and_L3call

*** Keywords ***
Case Teardown
    Run Keyword And Ignore Error    SigSpark_UE detach
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

Step1:Prepare UE
    log to console      step3: Prepare UE
    power_ue.Prepare UE    ue_index=${1}    ue_type=${ue_type}    power_reset=True

Step2:UE Attach
    log to console      Step4: UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${1}    ue_type=${ue_type}    log_type=Aasyslog    power_reset=True
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False

Start Traffic and Check TP
    ${list_of_cell_ids}    Create List    2572289
    #power_ue.Start traffic    ue_type=${ue_type}    ue_index=${1}    direction=dl    apn_address=dxdata1
	power_ue.Start traffic    ue_type=${ue_type}    ue_index=${1}    direction=dl    apn_address=wap1nokiacom
    ...    throughput=1600MKbits/sec    duration=600
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${1}    direction=ul     apn_address=wap1nokiacom
    ...    throughput=120MKbits/sec    duration=600
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1min    ue_index=${1}
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
    ...    ultarget_throughput=100    dltarget_throughput=1480    target_avg_percent=0.5    min_percent=0.5   ue_index=${1}

SigSpark_UE detach
    [Arguments]    ${ue_index}=${1}    ${power_reset}=True
    Run Keyword And Ignore Error  power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
    Run Keyword And Ignore Error  power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}

TopYong Attenuation Initial Value set
    attenuator.setup_attenuator    attenuator=${tl.attenuator}
    atten.set_attenuation    ${rank_port1}    ${10}
    atten.set_attenuation    ${rank_port2}    ${10}
    sleep    3s

TopYong Attenuation Value Change
    attenuator.setup_attenuator    attenuator=${tl.attenuator}
    atten.set_attenuation    ${rank_port1}    ${50}
    atten.set_attenuation    ${rank_port2}    ${50}
    sleep    3s
    atten.set_attenuation    ${rank_port1}    ${10}
    atten.set_attenuation    ${rank_port2}    ${10}

Get TcpdumpLogs from Remote machine with local capture
    ${executor_du}=  Create Dictionary
    ...  host=${du_ip}
    ...  user=${du_username}
    ...  password=${du_password}
    tcpdump.create_tcpdump_collector
    ...     name=tcpdump
    ...     options=-i any
    ...     executor=${executor_du}
    ...     capture_locally=yes
    core.setup_collectors    names=tcpdump
    core.start_collectors    names=tcpdump
    TopYong Attenuation Value Change
    sleep    3s
    TopYong Attenuation Initial Value set
    sleep    3s
    TopYong Attenuation Value Change
    sleep    3s
    core.stop_collectors    names=tcpdump
    core.collect_collectors    names=tcpdump    target_dir=${logPath}
    core.teardown_collectors    names=tcpdump

Check Rank Value
    [Arguments]    ${pcap_file}=${logPath}/tcpdump/tcpdump.pcap    ${filter_expression}=${maxMIMO_Layers_filter2}
    ${filtered_packets}    container_log_capturing.Load pcap with filter    pcap_file=${pcap_file}    filter_expression=${filter_expression}
    ${maxMIMO_Layers}    cap.Get Field Value By Xpath     pdml_list=${filtered_packets}    xpath=${xpath}    attribute_name=value
    #${maxMIMO_Layers}    Evaluate    map(lambda x: int(x, 16), ${maxMIMO_Layers})
    should not be empty    ${maxMIMO_Layers}

Check Rank Value Disable
    [Arguments]    ${pcap_file}=${logPath}/tcpdump/tcpdump.pcap    ${filter_expression}=${maxMIMO_Layers_filter2}
    ${filtered_packets}    container_log_capturing.Load pcap with filter    pcap_file=${pcap_file}    filter_expression=${filter_expression}
    ${maxMIMO_Layers}    cap.Get Field Value By Xpath     pdml_list=${filtered_packets}    xpath=${xpath}    attribute_name=value
    #${maxMIMO_Layers}    Evaluate    map(lambda x: int(x, 16), ${maxMIMO_Layers})
    should be empty    ${maxMIMO_Layers}

Login via Web
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${du_web_addr}
    ...               username=${du_web_usr}
    ...               password=${du_web_pwd}
    selenium_coam.disable_message_box

Logout via Web
    selenium_coam.logout
    selenium_coam.Disable Virtual Display













Parallel_Operation_RAT_Block_Unblock_and_L3call
    Log to console    \n***RAT Block and UnBlock***\n
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    sleep    5s
    selenium_coam.block_rat    NR
    Wait For Expect Fault Present    faultId=4614    timeout=180
    Prepare_UE_Only
    ${passed21}    Run Keyword And Return Status    L3call_Traffic_CA_CELL_21_3
    Should Not Be True    ${passed21}
    selenium_coam.unblock_rat    NR
    Wait For Expect Fault To Disappear  faultId=4614    timeout=180
    Wait Until Keyword Succeeds    10min    20s    Verify all cells should be onair
    L3call_Traffic_CA_CELL_21_3
    [Teardown]    Run Keywords
    ...    run keyword and ignore error    selenium_coam.unblock_rat    NR
    ...    AND  run keyword and ignore error    Selenium Logout And Close Browser

Parallel_Operation_Cell_Lock_Unlock_and_L3call
    Set_PA_Value    value=${20}    attenuator_index=${2}
    log to console    \n***L3call_Traffic_CA_CELL_21_3***\n
    Prepare_UE_Only
    L3call_Traffic_CA_CELL_21_3
    Get X2 link shutdown waiting time
    Lock cells or groups and check status
    ...    lock_list=${gci_list}
    ...    is_group=${False}
    ...    check_alarm=${True}
    ...    gnb_type='${gNb_CuType}'
    ...    connection=OAM_ssl
    sleep    2s
    ${passed21}    Run Keyword And Return Status    L3call_Traffic_CA_CELL_21_3
    Should Not Be True    ${passed21}
    Unlock cells or groups and check status
    ...    lock_list=${gci_list}
    ...    is_group=${False}
    ...    check_alarm=${True}
    ...    gnb_type='${gNb_CuType}'
    ...    connection=OAM_ssl
    sleep    10s
    L3call_Traffic_CA_CELL_21_3
    [Teardown]    run keyword and ignore error    Unlock cells or groups and check status
    ...    lock_list=${gci_list}
    ...    is_group=${False}
    ...    check_alarm=${True}
    ...    gnb_type='${gNb_CuType}'
    ...    connection=OAM_ssl

Parallel_Operation_Cell_Barred_Unbarred
    ${CELL21_Barred}    set variable    ${False}
    ${CELL3_Barred}    set variable    ${False}
    log to console    \n***Set PA to ensure CA cells CELL21 and CELL3 are both L3call ok***\n
    Set_PA_Value    value=${20}    attenuator_index=${2}
    Prepare_UE_Only
    L3call_Traffic_CELL_21
    ${CELL21_Barred}    Modify_CELL21_cellBarred_to_barred_Parameters_via_WebEM
    sleep    60s
    log to console    \n***cell21 should not be attached as pCell.***\n
    ${passed21}    Run Keyword And Return Status    L3call_Traffic_CELL_21
    Should Not Be True    ${passed21}
    log to console    \n***cell3 should be attached as pCell.***\n
    L3call_Traffic_CELL_3
    ${CELL3_Barred}    Modify_CELL3_cellBarred_to_barred_Parameters_via_WebEM
    sleep    60s
    log to console    \n***cell21 and cell3 should not be attached as pCell.***\n
    ${passed3}    Run Keyword And Return Status    L3call_Traffic_CELL_3
    Should Not Be True    ${passed3}
    ${CELL3_Barred}    Modify_CELL3_cellBarred_to_notBarred_Parameters_via_WebEM
    sleep    60s
    log to console    \n***cell3 should be attached as pCell.***\n
    L3call_Traffic_CELL_3
    ${CELL21_Barred}    Modify_CELL21_cellBarred_to_notBarred_Parameters_via_WebEM
    sleep    60s
    log to console    \n***cell21 should be attached as pCell.***\n
    L3call_Traffic_CA_CELL_21_3
    [Teardown]    Run Keywords
    ...    Run keyword if    ${CELL3_Barred}    Modify_CELL3_cellBarred_to_notBarred_Parameters_via_WebEM
    ...    AND  Run keyword if    ${CELL21_Barred}    Modify_CELL21_cellBarred_to_notBarred_Parameters_via_WebEM

Modify_CELL${GCI}_cellBarred_to_${value}_Parameters_via_WebEM
    [Documentation]
    ...    ********************************
    ...    GCI: Global cell ID
    ...    value:e.g.:barred,notBarred;
    ...    barred cell can't be used as pCell.
    log to console  \n***Modify_CELL${GCI}_cellBarred_to_${value}_Parameters_via_WebEM***\n
    ${CELL_Barred}    set variable    ${False}
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    Check and Modify Single Parameter on WebUI
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${GCI}
    ...    filter_param=Cell Barred
    ...    abbr=cellBarred
    ...    new_value=${value}
    ${CELL_Barred}    Run keyword if    '${value}'=='barred'    set variable    ${True}
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser
    [Return]    ${CELL_Barred}
