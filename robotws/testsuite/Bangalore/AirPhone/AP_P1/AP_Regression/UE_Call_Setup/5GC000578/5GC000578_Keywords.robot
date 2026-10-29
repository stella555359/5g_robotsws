*** Settings ***
Documentation    This file contains 5GC000578 keywords

Library         Collections
Library         ../../../Resources/Python/DeltaStore.py    WITH NAME    delta_store
Library         ../../../Resources/Python/AdminHelper.py    WITH NAME    admin_helper
Library     	../../../Resources/Python/ScfHelper.py    WITH NAME    scf_helper
Library         ../../../Resources/Python/LogStore.py    WITH NAME   log_store

Resource        ../../../Resources/Variables/Common_Variables.robot
Resource        ../../../Resources/robot/gnb.robot
Resource        ../../../Resources/robot/ute_setup.robot
Resource        ../../../Resources/robot/wts.robot
Resource        ../../../Resources/robot/log.robot
Resource        ../../../Resources/robot/suite_common_keywords.robot
Resource        ../../../Resources/robot/tshark.robot

*** Variables ***
${WTS_CFG_PATH}         ${CURDIR}/cfg
${filter_tcA01}         ${CURDIR}/resources/TC_A01_exp_file.txt
${filter_tcA10}         ${CURDIR}/resources/TC_A10_exp_file.txt
${filter_tcE03}         ${CURDIR}/resources/TC_E03_exp_file.txt
${filter_tcG17}         ${CURDIR}/resources/TC_G17_exp_file.txt
${filter_tcF04}         ${CURDIR}/resources/TC_F04_exp_file.txt
${ue_srb3_enabled}      1
${ue_srb3_disabled}     2
${ue_a3_srb3_enabled}   3
${pcap_timer}           5
${rrc_timer}            2
${inactivity_timer}     5
${offset}               2

*** Keywords ***
Suite Setup for SRB3
    Suite Common Keywords    feature_folder=5GC000578
    Prepare Environment Based On Run Type     cfg_type=custom
    Wait for gNB To Be Ready
    Backup gNB parameters
    Enable SRB3 on gNB

Suite Teardown for SRB3
    Common Suite Teardown Keywords
    Revert gNB parameters

Test Setup for SRB3
    WTS Setup
    Create Test Case Folder
    Start pcap collection in gNB and WTS

Test Teardown for SRB3
    Run Keyword And Ignore Error	UE Detach    ue_id=${UE_ID}
    Common Test Teardown

WTS Setup
    Start and configure WTS
    Establish X2 link And Wait For Cell Setup

WTS Teardown
    Stop Sim
    Teardown All Aliases For Wts

Test Setup for Multiple UE
    WTS Setup
    Create Test Case Folder

Test Teardown for Multiple UE
    Run Keyword And Ignore Error    UE Detach    ue_id=${ue_srb3_enabled}
    Run Keyword And Ignore Error    UE Detach    ue_id=${ue_srb3_disabled}
    Common Test Teardown

Initialise UE ID
    [Arguments]    ${ue_id_value}
    Set Test Variable    ${UE_ID}     ${ue_id_value}

Apply Wireshark Filter And Check Output
    [Arguments]    ${wireshark_filter}=None
    ${pcap_file}=   log_store.get_gnb_pcap
    PCAP File Should have Messages Defined in Filter File    pcap_file=${pcap_file}    wireshark_filter_file=${wireshark_filter}

Apply Wireshark Filter And Check SRB3 is not used
    ${pcap_file}=   log_store.get_gnb_pcap
    Msg Should Not Be Present in PCAP    pcap_file=${pcap_file}    filter=nr-rrc.logicalChannelIdentity == 3

Perform UE Attach
    UE Attach    ue_id=${UE_ID}    profile_id=${PROFILE_ID}

Perform SGNB Addition for Bearer
    SGNB Addition For Bearer    ue_id=${UE_ID}    target_gnb=${GNB_ID}    target_cells=${CELL_ID}    bearer=${BEARER_ID}

Start Data Transfer
    Start Traffic Uplink And Downlink    ue_id=${UE_ID}    bearer=${BEARER_ID}

Stop Data Transfer
    Stop All Data Transfer    ${UE_ID}    ${BEARER_ID}

Perform UE Detach
    UE Detach    ue_id=${UE_ID}

Perform MN initiated UE Detach
    Release ENDC Bearer    ue_id=${UE_ID}    bearer=${BEARER_ID}    cause=RN_switch_off_ongoing
    UE Detach    ue_id=${UE_ID}

Trigger RRCMessage Transfer
    Trigger Cell HO Measurement Report   id=${UE_ID}
    Wait For RRCMessageTransfer To be Sent

Trigger Cell HO Measurement Report
    [Arguments]    ${id}=${UE_ID}    ${meas_id}=1    ${index}=0    ${nrs_result}=40:0:0    ${event}=A3    ${srsrp_nr}=30
    ...    ${phycell_id}=10    ${nrsrp_nr}=40
    ${args_part1}    Set Variable    id\=${id} meas_id\=${meas_id} index\=${index} nrs_result\=${nrs_result}
    ${args_part2}    Set Variable    event\=${event} srsrp_nr\=${srsrp_nr} phycell_id\=${phycell_id} nrsrp_nr\=${nrsrp_nr}
    Execute Egate Command    ue_measurement_send_nr ${args_part1} ${args_part2}

Perform Attach Detach and Collect PCAP
   Start pcap collection in gNB and WTS
    Perform UE Attach
    Perform SGNB Addition for Bearer
    Perform UE Detach
    Wait for PCAP Collection
    Stop pcap collection in gNB and WTS

Wait for PCAP Collection
    Sleep    ${pcap_timer}s

Wait For RRCMessageTransfer To be Sent
    Sleep    ${rrc_timer}s

Wait for NSA Inactivity timer
    ${wait_time}    Evaluate    ${inactivity_timer} + ${offset}
    Sleep    ${wait_time}s

Backup gNB parameters
    ${nrbts_param_list}    Create List    srb3SupportEnabled    actIntraFreqInterGnbMobilityNSA3x
    ...    actIntraFreqIntraGnbMobilityNSA    actDlDataForwardingX2    actInactDetNSAUe    nsaInactivityTimer
    ${nrcell_param_list}	Create List    a3MeasEnabled    actCDrx
    ${scf_path}    admin_helper.download current scf file
    ${nrbts_param_dict}    scf_helper.get_feature_paramters_from_scf    ${scf_path}    ${nrbts_param_list}    ${NRBTS_DISTNAME}
    ${nrcell_param_dict}    scf_helper.get_feature_paramters_from_scf    ${scf_path}    ${nrcell_param_list}    ${NRCELL_DISTNAME}
    Set Suite Variable    ${nrbts_param_dict}
    Set Suite Variable    ${nrcell_param_dict}

Revert gNB parameters
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{nrbts_param_dict}
    delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}    &{nrcell_param_dict}
    ${delta_store}    Collect Delta Store
    Recommission With Delta From Admin    delta_json=${delta_store}    should_activate=${True}
    Wait for gNB To Be Ready

Enable SRB3 on gNB
    Delete Delta If Alread Present    name=default
    Initialise delta store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    srb3SupportEnabled=true
    ...    actDlDataForwardingX2=false
    ${delta_store}    Collect Delta Store
    Recommission With Delta From Admin    delta_json=${delta_store}    should_activate=${True}
    Wait for gNB To Be Ready

Disable SRB3 on gNB
    Delete Delta If Alread Present    name=default
    Initialise delta store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    srb3SupportEnabled=false
    ${delta_store}    Collect Delta Store
    Recommission With Delta From Admin    delta_json=${delta_store}    should_activate=${True}
    Wait for gNB To Be Ready

Enable InactivityDetection on gNB
    Delete Delta If Alread Present    name=default
    Initialise delta store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    actInactDetNSAUe=true
    ...    nsaInactivityTimer=${inactivity_timer}
    ${delta_store}    Collect Delta Store
    Recommission With Delta From Admin    delta_json=${delta_store}    should_activate=${True}
    Wait for gNB To Be Ready

Disable InactivityDetection on gNB
    Delete Delta If Alread Present    name=default
    Initialise delta store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    actInactDetNSAUe=false
    ${delta_store}    Collect Delta Store
    Recommission With Delta From Admin    delta_json=${delta_store}    should_activate=${True}
    Wait for gNB To Be Ready

Enable A3 measurements and DRX on gNB
    Delete Delta If Alread Present    name=default
    Initialise delta store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    actIntraFreqInterGnbMobilityNSA3x=true
    ...    actIntraFreqIntraGnbMobilityNSA=true
    delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}   actCDrx=true    a3MeasEnabled=rsrp
    delta_store.add_list_parameters_to_delta    dist_name=${NRCELL_DISTNAME}    list_name=a3MeasSsbRsrp
    ...    a3HysteresisSsbRsrp=0    a3OffsetSsbRsrp=0    a3TimeToTriggerSsbRsrp=ms0
    ${delta_store}    Collect Delta Store
    Recommission With Delta From Admin    delta_json=${delta_store}    should_activate=${True}
    Wait for gNB To Be Ready

Disable A3 measurements and DRX on gNB
    Delete Delta If Alread Present    name=default
    Initialise delta store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    actIntraFreqInterGnbMobilityNSA3x=false
    ...    actIntraFreqIntraGnbMobilityNSA=false
    delta_store.update managed object and parameter to delta    dist_name=${NRCELL_DISTNAME}   actCDrx=false    a3MeasEnabled=none
    ${delta_store}    Collect Delta Store
    Recommission With Delta From Admin    delta_json=${delta_store}    should_activate=${True}
    Wait for gNB To Be Ready