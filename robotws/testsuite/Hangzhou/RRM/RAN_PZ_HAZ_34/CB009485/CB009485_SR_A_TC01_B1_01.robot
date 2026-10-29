*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup BTS env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R3    tl-7_5_UTE5G402T2477
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ST.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/ST_robot/L3_call/DevHZ5_huawei_ue.robot

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

*** Test Cases ***
CB009485_SR_A_TC01_B1_01 Verify Successful SA gNB-DU reports Bearer Trace Record for PDU Session Modification Success
    [Documentation]  case name:
    ...    CB009485_SR_A_TC01_B1_01 Verify Successful SA gNB-DU reports Bearer Trace Record for PDU Session Modification
    ...    Success - Add one or more GBR or non-GBR 5QI QoS Flows to multi-PDU sessions
    adjust_pa_all_ports_max_value
    adjust_pa_for_cell    cell_id=1    value=50
    Prepare UEs    ue_ids=1

    log to console    step1: attach UE and establish two PDU sessions, one with 5QI6&7, the other with 5QI5
    start to capture wireshark log    1_attach
    attach UE
#    Start UL And DL traffic
    ${bearerrecord}    create list    bearerRecord/data-r2/trigger=ctxSetup,ctxModification
    ...                               bearerRecord/data-r2/setupBearers=1 item,2 items
    ...                               setupBearers/DuBearerDataSetupItem/drb-Id=4,5,6
    ...                               setupBearers/DuBearerDataSetupItem/qosInformation=nr-Qos,nr-Qos,nr-Qos
    ...                               drbLevelQos/fiveQi=5,7,6
    ...                               drbLevelQos/arp/priorityLevel=5,7,8
    ...                               drbLevelQos/arp/preemptionCapability=mayTriggerPreemption,mayTriggerPreemption,shallNotTriggerPreemption
    ...                               drbLevelQos/arp/preemptionVulnerability=notPreemptable,notPreemptable,notPreemptable
    ...                               drbLevelQos/pduSessionId=[RE].*,[RE].*,[RE].*
    ...                               snssai/sst=01,01,01
    ...                               snssai/sd=d143a5,d143a5,d143a5
    ...                               qosFlowsMappedToBearer/qfi=[RE].*,[RE].*,[RE].*
    ...                               qosFlowsMappedToBearer/qosParameters/fiveQi=5,7,6
    ...                               qosFlowsMappedToBearer/qosParameters/arp/priorityLevel=5,7,8
    ...                               qosFlowsMappedToBearer/preemptionCapability=mayTriggerPreemption,mayTriggerPreemption,shallNotTriggerPreemption
    ...                               qosFlowsMappedToBearer/qosParameters/arp/preemptionVulnerability=notPreemptable,notPreemptable,notPreemptable
    ...                               qosFlowsMappedToBearer/qosParameters/pduSessionId=[RE].*,[RE].*,[RE].*
    download and check wireshark fields    tag=1_attach
    ...                                    filter=${DU_BEARER_RECORD_F}
    ...                                    check_fields=${bearerrecord}

    log to console    step2: add 5qi9
    start to capture wireshark log    2_add_5qi9
    Add 5QI Bearer    5qi=9
    ${bearerrecord}    create list    bearerRecord/data-r2/trigger=ctxModification
    ...                               setupBearers/DuBearerDataSetupItem/drb-Id=7
    ...                               setupBearers/DuBearerDataSetupItem/qosInformation=nr-Qos
    ...                               drbLevelQos/fiveQi=9
    ...                               drbLevelQos/arp/priorityLevel=9
    ...                               drbLevelQos/arp/preemptionCapability=shallNotTriggerPreemption
    ...                               drbLevelQos/arp/preemptionVulnerability=notPreemptable
    ...                               drbLevelQos/pduSessionId=existing
    ...                               snssai/sst=01
    ...                               snssai/sd=d143a5
    ...                               qosFlowsMappedToBearer/qfi=[RE].*
    ...                               qosFlowsMappedToBearer/qosParameters/fiveQi=9
    ...                               qosFlowsMappedToBearer/qosParameters/arp/priorityLevel=9
    ...                               qosFlowsMappedToBearer/qosParameters/arp/preemptionCapability=shallNotTriggerPreemption
    ...                               qosFlowsMappedToBearer/qosParameters/arp/preemptionVulnerability=notPreemptable
    ...                               qosFlowsMappedToBearer/qosParameters/pduSessionId=existing
    download and check wireshark fields    tag=2_add_5qi9
    ...                                    filter=${DU_BEARER_RECORD_F}
    ...                                    check_fields=${bearerrecord}

    log to console    step3: release 5qi9
    start to capture wireshark log    3_del_5qi9
    Del 5QI Bearer    5qi=9
    ${bearerrecord}    create list    bearerRecord/data-r2/trigger=ctxModification
    ...                               bearerRecord/data-r2/releasedBearers/drb-Id=7
    download and check wireshark fields    tag=3_del_5qi9
    ...                                    filter=${DU_BEARER_RECORD_F}
    ...                                    check_fields=${bearerrecord}
    [Teardown]    Run Keywords    Detach UE
    ...                           Common Test Teardown And Stop Capture Logs

*** Keywords ***
download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${filter}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}
    ...                       packet_num=all

