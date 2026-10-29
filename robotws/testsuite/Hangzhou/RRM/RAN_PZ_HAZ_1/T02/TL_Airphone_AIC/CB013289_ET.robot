*** Settings ***
Documentation
...    Author: mengli yang
...    Contact: mengli.yang@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot





*** Test Cases ***
CB013289-PMO#1_T26_Counter_update_for_the_successful_Inter-RAT_handover_with_direct_data_forwarding
    [Tags]    CRT    TC26
    [Documentation]
    ...    Author: mengli.yang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Start Counter For CB013289_T26
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Start Traffic In AP
    Send AP Command    cmd=ue_measurement_send_nr id=24 meas_id=3 event=A3 srsrp_nr=11 phycell_id=51 nrsrp_nr=85
    ...                pass_regexp=${None}
    ...                timeout=100s
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Check Wireshark Log   input_file=${local_file_path}
    Collect And Check Counter    product_type=vdu    bts_index=${0}    cudu_index=0
    [Teardown]    Case Postcondition

CB013289-A_US#B2_TC29_PCMD_Monitoring_of_QoS_Flow_forwarding_status_during_IRAT_HO_to_LTE_at_gNB-CU-UP
    [Tags]    CRT    TC29
    [Documentation]
    ...    Author: mengli.yang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Open DCAP
    Download Wireshark Plugin Nsetapx
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Start Traffic In AP
    Send AP Command    cmd=ue_measurement_send_nr id=24 meas_id=3 event=A3 srsrp_nr=11 phycell_id=51 nrsrp_nr=85
    ...                pass_regexp=${None}
    ...                timeout=100s
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Check Wireshark Log   input_file=${local_file_path}
    [Teardown]    Case Postcondition


*** Keywords ***
Case Precondition
    Case Precondition For AP    tag=SA_HO    product_type=vdu    operation=env_setup_sa

Case Postcondition
    Case Postcondition For AP

Start Traffic In AP
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=1    bearer_id=2    dir=dlul
    ...                                     pdu_id=1    time_len=5s    trf_id=1    mbps_ul=5m    mbps_dl=135m
    ...                                     qfi_id=1    time=999    type=l3    profile_id=1
    ...                                     gnb_id=0    cell_id=1    protocol=udp
    AP Traffic    operation=start_traffic    traffic_info_dic=${traffic_info_dic}

Stop Traffic In AP
    ${traffic_info_dic}    Create Dictionary    ue_id=1    bearer_id=2    dir=dl    trf_id=1
    AP Traffic    operation=stop_traffic    traffic_info_dic=${traffic_info_dic}

Check Wireshark Log
    [Arguments]    ${input_file}=${wireshark_local_file_path_vCU}
    ${filter_list} =    Create list    f1ap.service_state == 0
    ${expect_message}=    Create list    UEContextReleaseCommand
    ${filter_length}    get length    ${filter_list}
    FOR    ${index}    IN RANGE    ${filter_length}
        ${result} =    Analysis Wireshark Log    input_file=${input_file}
        ...                                      filter_expression=${filter_list[${index}]}
        should contain    ${result}    ${expect_message[${index}]}
    END

Start Counter For CB013289_T26
    ${counter1_list}    Create List
    FOR    ${index}    IN RANGE    ${20}
        Append To List   ${counter_list}   M55337C0000${index}
    END
    FOR    ${counter1_id}    IN RANGE    ${counter1_list}
       ${rule1}    Catenate
        ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
        ...         Counter: ${counter1_id};
        ...         Counter rule: max(${counter1_id})>0;
        ${rule_list}    Create List    ${rule1}
        Start Counter    rule_list=${rule_list}    product_type=vdu    bts_index=0
    END
    ${rule}    Catenate
        ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
        ...         Counter: M55125C02001    M55125C02002    M55125C00048    M55125C00049    M55352C00007    M55352C00008
        ...         Counter rule: max(M55125C02001)>0;max(M55125C02002)>0;max(M55125C00048)>0;max(M55125C00049)>0;
        ...         max(M55352C00007)>0;max(M55352C00008)>0;
    ${rule_list}    Create List    ${rule}
    Start Counter    rule_list=${rule_list}    product_type=vdu    bts_index=0

Open DCAP
    OperatingSystem.Run    DCAP_Basic_controller start