*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Library      ta_pcmd
Library      ta_pcmd.tshark_plugin_configurator
Library      CB009823_verify.py
Resource     CB009823_keywords.robot

*** Variables ***
${input_file1_1208}=             ${OUTPUT_DIR}/BIP_L1L2.pcap
${input_file3_1208}=             ${OUTPUT_DIR}/BIP_L1L2_disabled.pcap

${dir_path1_1208}=               ${OUTPUT_DIR}/BIP_logRS1.pdml
${dir_path2_1208}=               ${OUTPUT_DIR}/BIP_logRS2.pdml
${dir_path3_1208}=               ${OUTPUT_DIR}/BIP_log_RIM_disabled.pdml

${filter_1_1208}=                "DlData_RimRsSendReq_t.nscID == 1"
${filter_2_1208}=                "DlData_RimRsSendReq_t.nscID == 9"
${filter_3_1208}=                "dldata_rimrssendreq"

${alias_1208_1}=                 L1L2_BIP_Logs
${alias_1208_2}=                 L1L2_BIP_Logs2

*** Keywords ***
CB009823-A3_Start_and_stop_RIMRS_transmission_regardles_of_RI_detection_enabled_5GC001208
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In DL and UL   ue_id=1    pdu=1    tput_ul=10     tput_dl=10
    Start Gathering BIP Logs And Wait 200s
    Stop gnbMirroring And Gather L1L2 Bip Logs  ${alias_1208_1}    ${input_file1_1208}
    Convert pcap file to pdml    ${input_file1_1208}    ${filter_1_1208}    ${dir_path1_1208}
    Convert pcap file to pdml    ${input_file1_1208}    ${filter_2_1208}    ${dir_path2_1208}
    Verify If RS1 Is Properly Transmitted for FS1208
    Verify If RS2 Is Properly Transmitted for FS1208
    Deactivate RIM-RS transmission by Sending Delta Commisioning
    Start Gathering BIP Logs And Wait 200s
    Stop gnbMirroring And Gather L1L2 Bip Logs  ${alias_1208_2}    ${input_file3_1208}
    Convert pcap file to pdml    ${input_file3_1208}    ${filter_3_1208}    ${dir_path3_1208}
    Check If RimRsSendReq Is Not Longer Generated
