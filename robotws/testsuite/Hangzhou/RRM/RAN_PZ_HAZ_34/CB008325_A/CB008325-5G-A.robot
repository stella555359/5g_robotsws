*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com
...   RRM

Suite Setup       Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

Resource    ./resources/comm_8325A.robot
Resource    ../../../resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Test Cases ***
[1]CB008325_001_SA_intra-frequency_inter-gNB_pingpong_HO_with_CFRA_ and_interaction_With_RANSharing
    [Documentation]
    ...    This user scenario describes Feature 5GC000704 activation, Successful intra freq inter gNB change in SA mode(option 2).
    ...    -13.09.2022,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CB008325
    [Setup]    case1_setup
    comm_8325A.Wait for counter to be gathered after guard peroid
    ${gNB1_counters_value_list1}    Get gNB1 Counter List
    ${gNB2_counters_value_list1}    Get gNB2 Counter List
    UE Attach And Check Attach Message
    Start Traffic And Check Throughput    tp_ul=50M    tp_dl=100M    target_tp_ul=20    target_tp_dl=50
    ...    nrcell_id=181825    duration=1200
    Adjust Attenuation And Check Measurement Report
    Stop Traffic And UE Detach
    Check Counter Subtracted Value    pre_gNB1_lsit=${gNB1_counters_value_list1}    pre_gNB2_list=${gNB2_counters_value_list1}
    [Teardown]    case4_teardown

[1]CB008325_002_SA_intra-frequency_intra-gNB_inter_baseband_card_pingpong_HO_CBRA
    [Documentation]
    ...    This user scenario describes Feature 5GC000704 activation, Successful intra freq intra gNB inter baseband card
    ...    change in SA mode(option 2).
    ...    -20.09.2022,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CB008325
    [Setup]    case2_setup
    UE Attach And Check Attach Message
    Start Traffic And Check Throughput    tp_ul=50M    tp_dl=100M    target_tp_ul=20    target_tp_dl=50
    ...    nrcell_id=181825    duration=1200
    Adjust Attenuation And Check Flow Message
    Stop Traffic And UE Detach
    [Teardown]    case4_teardown

[1]CB008325_004_SA_VONR_call_keep_during_intra-frequency_inter-gNB_HO
    [Documentation]
    ...    This user scenario describes Feature 5GC000704 activation, SA VONR call should keep during intra freq inter gNB
    ...    change in SA mode(option 2).
    ...    -13.09.2022,zheyuan.chen@nokia-sbell.com,case draft
    [Tags]    CB008325
    [Setup]    case1_setup
    UE Attach And Check Attach Message
    Start Traffic And Check Throughput    tp_ul=50M    tp_dl=100M    target_tp_ul=20    target_tp_dl=50
    ...    nrcell_id=181825    duration=1200
    VNOR call
    Adjust Attenuation And Check Measurement Report
    Stop Traffic And UE Detach
    [Teardown]    case4_teardown

*** Keywords ***
case1_setup
    robot_common_operations.Common case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=7311
    Modify Parameter CBRA    ip_address=${DU_OAM_IP}    Actual_value=n48    BTS_ID=${BTS_ID}    NRBTS_ID=${NRBTS_ID}
    Modify Parameter CBRA    ip_address=${DU2_OAM_IP}    Actual_value=n48    BTS_ID=${BTS2_ID}    NRBTS_ID=${NRBTS2_ID}
    Adjust HBTE Attenuation    port_value1=${0}    port_value2=${127}    port_value3=${30}
    sleep    10s

case2_setup
    robot_common_operations.Common case Setup
    Modify Parameter CBRA    ip_address=${DU_OAM_IP}    Actual_value=n64    BTS_ID=${BTS_ID}    NRBTS_ID=${NRBTS_ID}
    Adjust HBTE Attenuation    port_value1=${0}    port_value2=${30}    port_value3=${127}
    sleep    10s

UE Attach And Check Attach Message
    [Arguments]    ${pcap_name}=gNB1_attach.pcap    ${text_name}=gNB1_attach.txt    ${attached_pci}=${attached_pci_86}
    Start Catch Trace Log    DU_OAM_IP=${DU_OAM_IP}    connection=gNB1    filename=${pcap_name}
    Single UE Attach
    sleep    3s
    Stop And Copy Log To UTE    DU_OAM_IP=${DU_OAM_IP}    connection=gNB1    filename=${pcap_name}
    ${filter}=    CATENATE    f1ap
    comm_8325A.Convert pcap to text    source=${LOG_PATH}/${pcap_name}    target=${LOG_PATH}/${text_name}   filter="${filter}"
    Check Attach PCI    text_name=${text_name}    attached_pci=${attached_pci}
    [Teardown]  Run Keyword And Ignore Error    Stop And Copy Log To UTE    DU_OAM_IP=${DU_OAM_IP}
    ...    connection=gNB1    filename=${pcap_name}

Adjust Attenuation And Check Measurement Report
    [Arguments]    ${gNB1_file_name1}=gNB1_att1    ${gNB2_file_name1}=gNB2_att1    ${gNB1_file_name2}=gNB1_att2
    ...    ${gNB2_file_name2}=gNB2_att2
    Log To Console    Adjust Attenuation And Check Measurement Report
    FOR    ${item}    IN RANGE    ${2}
        Start Catch Trace Log    DU_OAM_IP=${DU_OAM_IP}    connection=gNB1    filename=${gNB1_file_name1}_${item}.pcap
        Start Catch Trace Log    DU_OAM_IP=${DU2_OAM_IP}    connection=gNB2    filename=${gNB2_file_name1}_${item}.pcap
        Adjust HBTE Attenuation Multile Times    step=${5}    start_value1=${5}    end_value1=${30}    start_value2=${25}
        sleep    20s
        Stop And Copy Log To UTE    DU_OAM_IP=${DU_OAM_IP}    connection=gNB1    filename=${gNB1_file_name1}_${item}.pcap
        Stop And Copy Log To UTE    DU_OAM_IP=${DU2_OAM_IP}    connection=gNB2    filename=${gNB2_file_name1}_${item}.pcap
        Check Target PCI And Flow Message    pcap_name=${gNB1_file_name1}_${item}.pcap    text_name=${gNB1_file_name1}_${item}.txt
        ...    attached_pci=${switched_pci_88}    message_dict=${gnb_source_message_flow}
        Check Target PCI And Flow Message    pcap_name=${gNB2_file_name1}_${item}.pcap    text_name=${gNB2_file_name1}_${item}.txt
        ...    attached_pci=${attached_pci_88}    message_dict=${gnb_target_message_flow}
        Just Check Throughput    target_tp_ul=20    target_tp_dl=50    nrcell_id=181841    gnb_index=${1}
        Start Catch Trace Log    DU_OAM_IP=${DU_OAM_IP}    connection=gNB1    filename=${gNB1_file_name2}_${item}.pcap
        Start Catch Trace Log    DU_OAM_IP=${DU2_OAM_IP}    connection=gNB2    filename=${gNB2_file_name2}_${item}.pcap
        Adjust HBTE Attenuation Multile Times    step=${-5}    start_value1=${25}    end_value1=${0}    start_value2=${5}
        sleep   20s
        Stop And Copy Log To UTE    DU_OAM_IP=${DU_OAM_IP}    connection=gNB1    filename=${gNB1_file_name2}_${item}.pcap
        Stop And Copy Log To UTE    DU_OAM_IP=${DU2_OAM_IP}    connection=gNB2    filename=${gNB2_file_name2}_${item}.pcap
        Check Target PCI And Flow Message    pcap_name=${gNB1_file_name2}_${item}.pcap    text_name=${gNB1_file_name2}_${item}.txt
        ...    attached_pci=${attached_pci_86}    message_dict=${gnb_target_message_flow}
        Check Target PCI And Flow Message    pcap_name=${gNB2_file_name2}_${item}.pcap    text_name=${gNB2_file_name2}_${item}.txt
        ...    attached_pci=${switched_pci_86}    message_dict=${gnb_source_message_flow}
        Just Check Throughput    target_tp_ul=20    target_tp_dl=50    nrcell_id=181825
    END

Adjust HBTE Attenuation Multile Times
    [Arguments]  ${step}    ${start_value1}    ${end_value1}    ${start_value2}
    ${diff}    evaluate   abs(${end_value1}-${start_value1})
    ${times}    evaluate    int(${diff}/abs(${step}))+1
    FOR    ${item}    IN RANGE    ${times}
        Adjust HBTE Attenuation    port_value1=${start_value1}    port_value2=${127}    port_value3=${start_value2}
        ${start_value1}    evaluate    ${start_value1} + ${step}
        ${start_value2}    evaluate    ${start_value2} - ${step}
        sleep    1s
    END

Check Target PCI And Flow Message
    [Arguments]    ${pcap_name}    ${text_name}    ${attached_pci}    ${message_dict}
    ${filter}=    CATENATE    f1ap || ngap
    comm_8325A.Convert pcap to text    source=${LOG_PATH}/${pcap_name}    target=${LOG_PATH}/${text_name}   filter="${filter}"
    Check Attach PCI    text_name=${text_name}    attached_pci=${attached_pci}
    Check Flow Message    text_name=${text_name}    message_dict=${message_dict}

Check Counter Subtracted Value
    [Arguments]    ${pre_gNB1_lsit}    ${pre_gNB2_list}
    ${status}    run keyword and return status    _check_gnb1_counter    pre_gNB1_lsit=${pre_gNB1_lsit}
    Log To Console    judge counter result
    run keyword if    '${status}' == 'False'    sleep    5min
    Log To Console    check gNB1 counter
    ${gNB1_counters_value_list2}    Get gNB1 Counter List
    FOR    ${item}    IN RANGE    ${4}
        ${value1}    evaluate    ${gNB1_counters_value_list2}[${item}] - ${pre_gNB1_lsit}[${item}]
        should be equal    ${value1}    ${2}
    END
    Log To Console    check gNB2 counter
    ${gNB2_counters_value_list2}    Get gNB2 Counter List
    FOR    ${item}    IN RANGE    ${4}
        ${value2}    evaluate    ${gNB2_counters_value_list2}[${item}] - ${pre_gNB2_list}[${item}]
        should be equal    ${value2}    ${2}
    END

_check_gnb1_counter
    [Arguments]    ${pre_gNB1_lsit}
    Log To Console    check gNB1 counter
    ${gNB1_counters_value_list2}    Get gNB1 Counter List
    FOR    ${item}    IN RANGE    ${4}
        ${value1}    evaluate    ${gNB1_counters_value_list2}[${item}] - ${pre_gNB1_lsit}[${item}]
        should be equal    ${value1}    ${2}
    END

Adjust Attenuation And Check Flow Message
    [Arguments]    ${gNB1_pcap_name1}=gNB_att1.pcap    ${gNB1_text_name1}=gNB_att1.txt    ${gNB1_pcap_name2}=gNB_att2.pcap
    ...    ${gNB1_text_name2}=gNB_att2.txt
    Log To Console    Adjust Attenuation And Check Flow Message
    FOR    ${item}    IN RANGE    ${2}
        Start Catch Trace Log    DU_OAM_IP=${DU_OAM_IP}    connection=gNB1    filename=${gNB1_pcap_name1}
        Adjust HBTE Attenuation    port_value1=${5}    port_value2=${25}    port_value3=${127}
        sleep    1s
        Adjust HBTE Attenuation    port_value1=${10}    port_value2=${20}    port_value3=${127}
        sleep    1s
        Adjust HBTE Attenuation    port_value1=${15}    port_value2=${15}    port_value3=${127}
        sleep    1s
        Adjust HBTE Attenuation    port_value1=${20}    port_value2=${10}    port_value3=${127}
        sleep    1s
        Adjust HBTE Attenuation    port_value1=${25}    port_value2=${5}    port_value3=${127}
        sleep    1s
        Adjust HBTE Attenuation    port_value1=${30}    port_value2=${0}    port_value3=${127}
        sleep    20s
        Stop And Copy Log To UTE    DU_OAM_IP=${DU_OAM_IP}    connection=gNB1    filename=${gNB1_pcap_name1}
        Check Target PCI And Flow Message    pcap_name=${gNB1_pcap_name1}    text_name=${gNB1_text_name1}    attached_pci=${attached_pci_87}
        ...    message_dict=${gnb_same_message_flow}
        Just Check Throughput    target_tp_ul=20    target_tp_dl=50    nrcell_id=181826
        Start Catch Trace Log    DU_OAM_IP=${DU_OAM_IP}    connection=gNB1    filename=${gNB1_pcap_name2}
        Adjust HBTE Attenuation    port_value1=${25}    port_value2=${5}    port_value3=${127}
        sleep    1s
        Adjust HBTE Attenuation    port_value1=${20}    port_value2=${10}    port_value3=${127}
        sleep    1s
        Adjust HBTE Attenuation    port_value1=${15}    port_value2=${15}    port_value3=${127}
        sleep    1s
        Adjust HBTE Attenuation    port_value1=${10}    port_value2=${20}    port_value3=${127}
        sleep    1s
        Adjust HBTE Attenuation    port_value1=${5}    port_value2=${25}    port_value3=${127}
        sleep    1s
        Adjust HBTE Attenuation    port_value1=${0}    port_value2=${30}    port_value3=${127}
        sleep    20s
        Stop And Copy Log To UTE    DU_OAM_IP=${DU_OAM_IP}    connection=gNB1    filename=${gNB1_pcap_name2}
        Check Target PCI And Flow Message    pcap_name=${gNB1_pcap_name2}    text_name=${gNB1_text_name2}    attached_pci=${attached_pci_86}
        ...    message_dict=${gnb_same_message_flow}
        Just Check Throughput    target_tp_ul=20    target_tp_dl=50    nrcell_id=181825
    END

case_teardown
    [Arguments]    ${ue_index}=${0}
    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    remove logs
    remove files    ${LOG_PATH}/*.txt    ${LOG_PATH}/*.pcap

case4_teardown
    [Arguments]    ${ue_index}=${0}
    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Save Snapshot    bts_host=${DU_OAM_IP}

Suite Setup
    robot_common_operations.Common Suite Setup
    ${default_scf1}    suite setup to prepare default scf    SBTS_scf_name=SCF_SBTS00_gNB1.xml    bts=gNB1
    ...    DU_OAM_IP=${DU_OAM_IP}
    Commission Default SCF    default_scf=${default_scf1}    DU_OAM_IP=${DU_OAM_IP}
    ${default_scf2}    suite setup to prepare default scf    SBTS_scf_name=SCF_SBTS00_gNB2.xml    bts=gNB2
    ...    DU_OAM_IP=${DU2_OAM_IP}
    Commission Default SCF    default_scf=${default_scf2}    DU_OAM_IP=${DU2_OAM_IP}

VNOR call
    [Arguments]  ${bts_ip}=${DU_OAM_IP}    ${filename}=vnor_att    ${attached_pci}=${vonr_fiveQI_1}    ${message_dict}=${vonr_setup_message_flow}
    Start Catch Trace Log    DU_OAM_IP=${bts_ip}    connection=gNB1    filename=${filename}.pcap
    Make a VoNR call(+6688)    during=10s
    Stop And Copy Log To UTE    DU_OAM_IP=${bts_ip}    connection=gNB1    filename=${filename}.pcap    time=30s
    Check Target PCI And Flow Message    pcap_name=${filename}.pcap    text_name=${filename}.txt    attached_pci=${attached_pci}
    ...    message_dict=${message_dict}
    [Teardown]  Run Keyword And Ignore Error    hang up VoNR call

Save Snapshot
    [Arguments]    ${bts_host}    ${connection}=cOAM    ${timeout}=10min
    log to console    Save Snapshot...
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    ${snapshot_path}    coam.get_snapshot    target_file_name=${output_dir}/${timestamp}_snapshot.zip    connection=${connection}
    ...    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}

