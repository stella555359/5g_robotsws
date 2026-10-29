*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup BTS env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R3    tl-7_5_UTE5G402T2405
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ST.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/ST_robot/L3_call/DevHZ5_spark_ue.robot

*** Variables ***
@{PARAMS_IN_SWCONFIG}
...    0x5A0609=1    #L2-HI rdDebugPcmdNrt
...    0x5A0610=1    #L2-HI rdDebugPcmdRt
...    0x5B0609=1    #L2-HI rdDebugPcmdNrt
...    0x5B0610=1    #L2-HI rdDebugPcmdRt
...    0x57000E=1    #enable L2-LO NRT PCMD debug logs
...    0x58057a=4    #L2-PS rdFeatureFlagBitmapLevel 4DEBUG
...    0x58057b=8    #L2-PSrdFeatureFlagBitmap0 8PF_METRIC
...    0x580582=3    #L2-PSrdFeatureFlagBitmap7 3RAT1_ALLOC
...    0x58057f=0x10000000     #L2-PSrdFeatureFlagBitmap4
...    0x890004=0
...    0x890003=0
${DU_BEARER_RECORD_F}    nsetapx.DuVendorExtensionRecordDataType == 13
${DU_BEARER_RECORD_mba_F}    (nsetapx.DuVendorExtensionRecordDataType == 13) && (nsetapx.traceActivationType == 0)
${DU_BEARER_RECORD_sba_F}    ((nsetapx.DuVendorExtensionRecordDataType == 13)) && (nsetapx.traceActivationType == 1)

*** Test Cases ***
CB009485_SR_A_TC03_B2_01 Verify Sucessful SA gNB-DU reports Bearer Trace Record for Successful PDU Session Resource Release
    [Documentation]  case name:
    ...    CB009485_SR_A_TC03_B2_01 Verify Sucessful SA gNB-DU reports Bearer Trace Record for Successful PDU Session
    ...    Resource Release for not all PDU sessions for multi-UE - at least one PDU session  in Subscriber Trace Session
    ...    UE1 subscribed trace to amf, UE2 didn't.

    adjust_pa_all_ports_max_value
    adjust_pa_for_cell    cell_id=21
    Prepare UEs    ue_ids=1,2
    clear amf subscribe buffer

    log to console    step1: attach UE1 and establish two PDU sessions, one with 5QI6&7, the other with 5QI5,check mba and sba trace
    start to capture wireshark log    1_attach_ue1
    ${attach_status}    run keyword and return status    attach UE    ue_id=1    attach_way=popo
    IF    not ${attach_status}
          log    attach UE1 failed with popo    level=WARN
          Execute AT Command    AT+CFUN=0   ue_id=1    # power off
          stop capture wireshark log    1_attach_ue1
          start to capture wireshark log    1_attach_ue1
          attach UE    ue_id=1    attach_way=atreboot
    END
    ${bearerrecord}    create list    bearerRecord/data-r2/trigger=ctxSetup,ctxModification
    ...                               bearerRecord/data-r2/setupBearers=1 item,2 items
    ...                               setupBearers/DuBearerDataSetupItem/drb-Id=4,5,6
    ...                               setupBearers/DuBearerDataSetupItem/qosInformation=nr-Qos,nr-Qos,nr-Qos
    ...                               drbLevelQos/fiveQi=5,7,6
    ...                               drbLevelQos/arp/priorityLevel=5,7,8
    ...                               drbLevelQos/arp/preemptionCapability=mayTriggerPreemption,mayTriggerPreemption,shallNotTriggerPreemption
    ...                               drbLevelQos/arp/preemptionVulnerability=notPreemptable,notPreemptable,notPreemptable
    ...                               drbLevelQos/pduSessionId=1,2,2
    ...                               snssai/sst=01,01,01
    ...                               snssai/sd=d143a5,d143a5,d143a5
    ...                               qosFlowsMappedToBearer/qfi=[RE].*,[RE].*,[RE].*
    ...                               qosFlowsMappedToBearer/qosParameters/fiveQi=5,7,6
    ...                               qosFlowsMappedToBearer/qosParameters/arp/priorityLevel=5,7,8
    ...                               qosFlowsMappedToBearer/preemptionCapability=mayTriggerPreemption,mayTriggerPreemption,shallNotTriggerPreemption
    ...                               qosFlowsMappedToBearer/qosParameters/arp/preemptionVulnerability=notPreemptable,notPreemptable,notPreemptable
    ...                               qosFlowsMappedToBearer/qosParameters/pduSessionId=1,2,2
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    1_attach_ue1    ${DU_BEARER_RECORD_F}    times=2
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_mba_F}
    ...                       check_fields=${bearerrecord}
    ...                       packet_num=all
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_sba_F}
    ...                       check_fields=${bearerrecord}
    ...                       packet_num=all

    log to console    step2: attach UE2 and establish two PDU sessions, one with 5QI6&7, the other with 5QI5, check mba trace
    start to capture wireshark log    2_attach_ue2
    ${attach_status}    run keyword and return status    attach UE    ue_id=2    attach_way=popo
    IF    not ${attach_status}
        log    attach UE2 failed with popo    level=WARN
        Execute AT Command    AT+CFUN=0   ue_id=2    # power off
        stop capture wireshark log    2_attach_ue2
        start to capture wireshark log    2_attach_ue2
        attach UE    ue_id=2    attach_way=atreboot
    END
    #    Start UL And DL traffic    ue_id=2
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    2_attach_ue2    ${DU_BEARER_RECORD_F}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_mba_F}
    ...                       check_fields=${bearerrecord}
    ...                       packet_num=all

    log to console    step3: setup pdu session3 for UE1, check mba and sba trace
    start to capture wireshark log    3_setup_pdu3_ue1
    execute at command    AT+CGDCONT=3,"IPV4V6","dxdata2"    ue_id=1
    execute at command    at+cgact=1,3    ue_id=1
    ${bearerrecord}    create list    bearerRecord/data-r2/trigger=ctxModification
    ...                               setupBearers/DuBearerDataSetupItem/drb-Id=7
    ...                               setupBearers/DuBearerDataSetupItem/qosInformation=nr-Qos
    ...                               drbLevelQos/fiveQi=7
    ...                               drbLevelQos/arp/priorityLevel=7
    ...                               drbLevelQos/arp/preemptionCapability=mayTriggerPreemption
    ...                               drbLevelQos/arp/preemptionVulnerability=notPreemptable
    ...                               drbLevelQos/pduSessionId=3
    ...                               snssai/sst=01
    ...                               snssai/sd=d143a5
    ...                               qosFlowsMappedToBearer/qfi=[RE].*
    ...                               qosFlowsMappedToBearer/qosParameters/fiveQi=7
    ...                               qosFlowsMappedToBearer/qosParameters/arp/priorityLevel=7
    ...                               qosFlowsMappedToBearer/qosParameters/arp/preemptionCapability=mayTriggerPreemption
    ...                               qosFlowsMappedToBearer/qosParameters/arp/preemptionVulnerability=notPreemptable
    ...                               qosFlowsMappedToBearer/qosParameters/pduSessionId=3
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    3_setup_pdu3_ue1    ${DU_BEARER_RECORD_F}    times=2
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_mba_F}
    ...                       check_fields=${bearerrecord}
    ...                       packet_num=all
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_sba_F}
    ...                       check_fields=${bearerrecord}
    ...                       packet_num=all

    log to console    step4: setup pdu session3 for UE2, check mba trace
    start to capture wireshark log    4_setup_pdu3_ue2
    execute at command    AT+CGDCONT=3,"IPV4V6","dxdata2"    ue_id=2
    execute at command    at+cgact=1,3    ue_id=2
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    4_setup_pdu3_ue2    ${DU_BEARER_RECORD_F}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_mba_F}
    ...                       check_fields=${bearerrecord}
    ...                       packet_num=all

    log to console    step5: release pdu session3 for UE1, check mba and sba trace
    start to capture wireshark log    5_release_pdu3_ue1
    execute at command    at+cgact=0,3    ue_id=1
    ${bearerrecord}    create list    bearerRecord/data-r2/trigger=ctxModification
    ...                               bearerRecord/data-r2/releasedBearers/drb-Id=7
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    5_release_pdu3_ue1    ${DU_BEARER_RECORD_F}    times=2
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_mba_F}
    ...                       check_fields=${bearerrecord}
    ...                       packet_num=all
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_sba_F}
    ...                       check_fields=${bearerrecord}
    ...                       packet_num=all

    log to console    step6: release pdu session3 for UE2, check mba trace
    start to capture wireshark log    6_release_pdu3_ue2
    execute at command    at+cgact=0,3    ue_id=2
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    6_release_pdu3_ue2    ${DU_BEARER_RECORD_F}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_mba_F}
    ...                       check_fields=${bearerrecord}
    ...                       packet_num=all
    [Teardown]    detach UEs and collect logs

*** Keywords ***
download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${filter}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}

clear amf subscribe buffer
    execute cmd on pc    sshpass -p Nokia@12345 ssh test1@10.110.115.206 cmm subscriber delete --imsi 262033100015422

detach UEs and collect logs
#    Stop UL And DL traffic    ue_id=1
#    Stop UL And DL traffic    ue_id=2
    Detach UE    ue_id=1
    Detach UE    ue_id=2
    Common Test Teardown And Stop Capture Logs

