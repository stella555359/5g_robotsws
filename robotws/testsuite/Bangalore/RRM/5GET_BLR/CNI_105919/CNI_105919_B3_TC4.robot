** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G    5G_RAN     SBTS00    CONFIGURED   

Variables    ta5g_global_var

Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../resources/robot/TTI_Traces.robot
Resource         ../resources/NPS/SWENG/robot/PacketSearch_mcshark.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../resources/robot/BBpooling_MuMIMO.robot
Library          ../resources/python/avg_dl_data.py
Library          ta5g_commissioning
Library          ta5g_pm_counters
Library          String


Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with ${delta_file_1}
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep   60s

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Log   snapshot    sosreport

Documentation
...
...             author:           Manasa
...             maintainer:       manasa.shankarappa@nokia.com
...
...             INTRODUCTION:     This user scenario describes the behaviour of Nokia gNB in SA mode for 
...                               the successful setup and user plane traffic with RoHC enabled with VoNR 
...                               traffic using supported Narrow/Wide Band codecs to RRC_IDLE triggered 
...                               by 5G-L2-HI-CU after detecting HFN desynchronisation.
...                               This user scenario describes the behaviour of Nokia gNB in SA mode for 
...                               the successful setup and operation of ciphering/deciphering of nonGBR 
...                               user plane traffic flow to RRC_IDLE triggered by gNB-CU-UP after 
...                               detecting HFN desynchronisation
...             TEST SET NAME:    CNI-105919
...             TESTING SPLIT:    Refer CNI-105919 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CNI-105919 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_24233 5G_RAN_USR_RRM_24195



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_vonr.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      1
${sa_ue_id2}      2
${sa_ue_id3}      3
${sa_ue_id4}      4
${sa_ue_id5}      5
${sa_ue_id6}      6
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${Pdu_session_ID2}      2
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC1
${CELL_ID}    1

${delta_file_1}    Enable_actPdcpHfnDesyncDetectAlgo.json
${delta_file_2}    Enable_VONR_ROHC.json
${HFN_DecipheredPackets_pattern}   "HFNDESYNCDETECTED due to 20 consecutiveDecipheredPacketsValidationFailures"
${HFN_DecompressedPackets_pattern}    "HFNDESYNCDETECTED due to 20 consecutiveDecompressedPacketsValidationFailures"

*** Test Cases ***
[1]CNI-105919#B3_TC4_UE_Release_on_PDCP_PDU_discards_due_to_the_RoHC_decompression_failures_with_Multiple_Ues_multiple_DRB
    [Tags]     QC_355048
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    Set HFN Desyn on AP    ${sa_ue_id1}   ${9} 
    Set HFN Desyn on AP    ${sa_ue_id2}   ${9}
    Set HFN Desyn on AP    ${sa_ue_id3}   ${9}
    Wait until the next Measurement Period starts
    log to console   "UE attach trigerring now"
#Step 1. Attach multiple SA UE-1 cell-1 and Start UL Data Traffic
    Start Log    cprt
    MultiUE Register should be Successful   ${sa_ue_id1}    ${sa_ue_id6}
    MultiUE PDU Modfication should be Successful    ${sa_ue_id1}    ${sa_ue_id6}   pdu_id=1   qosflows_to_add=4
    MultiUE PDU Modfication should be Successful    ${sa_ue_id1}    ${sa_ue_id6}   pdu_id=1   qosflows_to_add=5
    MultiUE PDU Addition should be Successful    ${sa_ue_id1}    ${sa_ue_id6}   pdu_id=2   nw_id=1
    MultiUE PDU Modfication should be Successful    ${sa_ue_id1}    ${sa_ue_id6}   pdu_id=2   qosflows_to_add=4
    MultiUE PDU Modfication should be Successful    ${sa_ue_id1}    ${sa_ue_id6}   pdu_id=2   qosflows_to_add=5
    ${path1}    Stop Log    cprt   test_scenario=ue_register
    Start Log    cprt   btslog
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=1  qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=1  qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=1  qfi_id=3
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=2  qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=2  qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=2  qfi_id=3
    sleep   60s
    wtsrunner.ue_summary
    wtsrunner.ue_summary
    ${path2}    Stop Log    cprt   btslog   test_scenario=ue_release
    Run Keyword and continue on Failure   Check UE release in egate    ${sa_ue_id1}
    Run Keyword and continue on Failure   Check UE release in egate    ${sa_ue_id2}
    Run Keyword and continue on Failure   Check UE release in egate    ${sa_ue_id3} 
    Run Keyword and continue on Failure   Check HFN release in syslog  3   ${HFN_DecipheredPackets_pattern}   ${path2}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id6}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter_HFN_DESYNC
    Verify Any Counters In File
    ...  M55350C00032  3  HFN_SN_DESYNC_DETECT_DRB
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    sleep  60s 
#Perform delta commissioning with VONR and ROHC enabled 
    Perform SCF Delta Commissioning with ${delta_file_2}
    Set HFN Desyn on AP    ${sa_ue_id1}   ${6}
    Set HFN Desyn on AP    ${sa_ue_id2}   ${6}
    Set HFN Desyn on AP    ${sa_ue_id3}   ${6}
#Step 1. Attach multiple SA VONR and Start UL Data Traffic
    Wait until the next Measurement Period starts
    Start Log    cprt
    MultiUE Register should be Successful   ${sa_ue_id1}    ${sa_ue_id6}
    MultiUE PDU Modfication should be Successful    ${sa_ue_id1}    ${sa_ue_id6}   pdu_id=1   qosflows_to_add=2
    MultiUE PDU Modfication should be Successful    ${sa_ue_id1}    ${sa_ue_id6}   pdu_id=1   qosflows_to_add=3
    MultiUE PDU Addition should be Successful    ${sa_ue_id1}    ${sa_ue_id6}   pdu_id=2   nw_id=1
    MultiUE PDU Modfication should be Successful    ${sa_ue_id1}    ${sa_ue_id6}   pdu_id=2   qosflows_to_add=4
    MultiUE PDU Modfication should be Successful    ${sa_ue_id1}    ${sa_ue_id6}   pdu_id=2   qosflows_to_add=5
    ${path3}    Stop Log    cprt   test_scenario=rohc_ue_register
    Start Log    cprt   btslog
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=1  qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=1  qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=2  qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=2  qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=2  qfi_id=3
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id6}   Traffic_rate=mbps   ul_rate=10   pdu_id=1  qfi_id=3
    sleep   60s
    ${path3}    Stop Log    cprt   btslog  test_scenario=rohc_ue_release
    ${sa_ue_id1_AMF}   Evaluate   ${sa_ue_id1}+${9}
    ${sa_ue_id2_AMF}   Evaluate   ${sa_ue_id2}+${9}
    ${sa_ue_id3_AMF}   Evaluate   ${sa_ue_id3}+${9}
    Run Keyword and continue on Failure    Check UE release in egate    ${sa_ue_id1_AMF}
    Run Keyword and continue on Failure    Check UE release in egate    ${sa_ue_id2_AMF}
    Run Keyword and continue on Failure    Check UE release in egate    ${sa_ue_id3_AMF}
    Run Keyword and continue on Failure   Check HFN release in syslog  3   ${HFN_DecompressedPackets_pattern}   ${path3}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id1}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter_HFN_DESYNC
    Verify Any Counters In File
    ...  M55350C00032  3  HFN_SN_DESYNC_DETECT_DRB
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    [Teardown]  Link SCOUT SCF to Configuration ID for Reporting


** Keywords **
Set HFN Desyn on AP 
    [Arguments]     ${ue_id}    ${drb_id}
    wtsrunner.ue_pdcp_hfn_desync_testmode   ue_id=${ue_id}   num_of_normal_pkts=1000   hfn_jump_count=100   sn_jump_count=2000  
    ...  num_of_invalid_pkts=20000   drb_id=${drb_id}

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Check UE release in egate
    [Arguments]     ${ue_id}   ${count}=1
    ${output}   Run    grep -ci "UE CONTEXT RELEASE REQUEST: gNB=2, AMF_UE_NGAP_ID=${ue_id}" /opt/iphy/latest/egate_console.log
    Should contain   ${output}   ${count}

Check HFN release in syslog
    [Arguments]     ${count}   ${pattern}   ${path}
    ${output}   Run    grep -ci ${pattern} ${path}[btslog]/gnb_syslog.log
    Should contain   ${output}   ${count}
