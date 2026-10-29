*** Settings ***
Documentation    author: helen.chen
...              Group: HGZ_SG7
...              contact: helen.1.chen@nokia-sbell.com
...              Description
Library          taf.transport.ssh    WITH NAME    csn
Library          taf.selenium.gnb.oam.coam.classical    WITH NAME    selenium_coam
Library    taf.analyzer.pcap    WITH NAME    pcap
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
#Resource    ../../../../../../../resources/common/DEPRECATED/wireshark_parsing.robot
Resource    taf/rfrl/common_resources/robot/connections.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/asod.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot

*** Variables ***
${cpif_log_path}    /home/robot/
${local_path}    /home/ute/
${ue_type}    ${tl.ues[0].capabilities[1]}
${f1ap_filter}    f1ap
${service_state_filter}    f1ap.service_state==0
${mrbts_id}    MRBTS-122
*** Keywords ***
Case Setup
    Cloud DU connect to gnb coam via ssl    connection=GNB_OAM    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}

Case Teardown
    COAM Teardown gnb connections    connection=GNB_OAM

Commission DU
    [Arguments]    ${scf_file_path}
    run keyword and ignore error    COAM Commission with scf file    ${scf_file_path}    timeout=500
    ...       is_pdl_checking_needed=${False}

Catch F1ap Package in CPIF
    [Arguments]    ${file_name}
    Connect to OAM
    Connect to CPIF
    ${cmd}    Set Variable    sudo tcpdump -i fronthaul -w ${file_name} &
    csn.send command    command=${cmd}   connection=CPIF

Wait cell on Air
    Wait Until Keyword Succeeds    10min    30s    Verify all cells should be onair

Lock RU and Unlock RU
    Log To Console    lock RU
    Du login page via webUI
    selenium_coam.lock_ru
    sleep    30s
    ${RU_lock}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Administrative state    abbr=administrativeState    timeout=60
    set suite variable    ${RU_lock}
    should be equal     ${RU_lock}    Locked
    Log To Console    unlock RU
    selenium_coam.unlock_ru
    sleep    30s
    ${RU_unlock}    selenium_coam.get_parameter_value    dist_name=${mrbts_id}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Administrative state    abbr=administrativeState    timeout=60
    set suite variable    ${RU_unlock}
    should be equal     ${RU_unlock}    Unlocked
    #COAM selenium logout

Stop Catching F1ap Package
    Connect to OAM
    Connect to CPIF
    csn.send command        command=sudo killall tcpdump     connection=CPIF
    
Check Cell Service Status in Package
    [Arguments]    ${file_name}    ${expect_service_state}    ${filter}=${None}
    Download Pcap Log to Test PC    ${file_name}
    cap.Read Cap    cap_file=${local_path}/${file_name}    display_filter=${filter}
    cap.Check Expression    condition_expression=f1ap.service_state == 0
    ${service_state}    Get value in pcap log    pcap_file=${local_path}/${file_name}    filter=${f1ap_filter}
    ...    field_name=f1ap.service_state
    should contain    ${service_state}    ${expect_service_state}
    ${transaction_id}    Get value in pcap log    pcap_file=${local_path}/${file_name}    filter=${service_state_filter}
    ...    field_name=f1ap.TransactionID
    cap.Check Expression    condition_expression=f1ap.F1AP_PDU == 1 && f1ap.TransactionID ==${transaction_id[0]}

Download Pcap Log to Test PC
    [Arguments]    ${file_name}
    Connect to OAM
    Connect to CPIF
    csn.download_file   ${cpif_log_path}${file_name}   ${local_path}${file_name}   connection=CPIF

Get value in pcap log
    [Documentation]    Author: chen yanfen
    ...                Description: Check TransactionID value in pcap log
    [Arguments]    ${pcap_file}    ${filter}    ${field_name}
    ${filtered_packets}=    Load pcap with filter    pcap_file=${pcap_file}    filter_expression=${filter}
    ${value}=    Get field value    packets=${filtered_packets}    field_name=${field_name}
    [Return]    ${value}

Lock Cell and Unlock Cell
    [Arguments]    ${timeout}=60
    Du login page via webUI
    selenium_coam.lock_cell
    Wait Until Keyword Succeeds    20min    5s    Check Cell Status
    ...    operational_state=Disabled    administrative_state=Locked
    selenium_coam.unlock_cell
    Wait Until Keyword Succeeds    20min    5s    Check Cell Status
    ...    operational_state=Enabled    administrative_state=Unlocked

Check Cell Status
    [Arguments]    ${operational_state}=Disabled
    ...            ${administrative_state}=Locked
    ...            ${cell}=1
    Run Keyword And Ignore Error  selenium_coam.close_start_up_view_window  timeout=${5}
    ${output}=    selenium_coam.get_cell_info    cell_idx=${cell}
    Log Many      ${output}
    should be equal      ${output['Status']['Operational state']}    ${operational_state}
    should be equal      ${output['Status']['Administrative state']}    ${administrative_state}

Reset Ru
    ${ru_list}    Connect to all rus with allocated IP    connection=GNB_OAM    du_index=0
    run keyword and return status    csn.execute    /sbin/reboot    connection=${ru_list[0]}
    sleep    30s

