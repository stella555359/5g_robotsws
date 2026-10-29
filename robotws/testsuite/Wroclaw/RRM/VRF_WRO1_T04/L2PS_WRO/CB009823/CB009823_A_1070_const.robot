*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Library      CB009823_verify.py
Resource     CB009823_keywords.robot

*** Variables ***
${input_file1_1070}=             ${OUTPUT_DIR}/BIP_L1L2.pcap
${input_file2_1070}=             ${OUTPUT_DIR}/BIP_L1L2_second.pcap

${dir_path1_1070}=               ${OUTPUT_DIR}/BIP_log_1.pdml
${dir_path2_1070}=               ${OUTPUT_DIR}/BIP_log_2.pdml

${filter_1070}=                  '(dldata_rimrssendreq)'

${alias_1070}=                   L1L2_BIP_Logs

*** Keywords ***
CB009823-A3_Start_RIMRS_transmission_regardles_of_RI_detection_enabled_5GC001070
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In DL and UL   ue_id=1    pdu=1    tput_ul=1     tput_dl=1
    Start Gathering BIP Logs And Wait 200s
    Stop gnbMirroring And Gather L1L2 Bip Logs  ${alias_1070}    ${input_file1_1070}
    Convert pcap file to pdml    ${input_file1_1070}    ${filter_1070}    ${dir_path1_1070}
    Verify If RS1 And RS2 Are Properly Transmitted
    Change RIM-RS Transmission From Constantly Trigger To RI Trigger
    Wait 100s After Delta Recommisioning
    Start Gathering BIP Logs And Wait 200s
    Stop gnbMirroring And Gather L1L2 Bip Logs  ${alias_1070}    ${input_file2_1070}
    Convert pcap file to pdml    ${input_file2_1070}    ${filter_1070}    ${dir_path2_1070}
    Verify If RS1 And RS2 Are Not Transmitted
