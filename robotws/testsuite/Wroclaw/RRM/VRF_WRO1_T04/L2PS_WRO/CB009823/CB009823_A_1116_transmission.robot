*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Library      CB009823_verify.py
Resource     CB009823_keywords.robot

*** Variables ***
${input_file1_1116}=             ${OUTPUT_DIR}/BIP_L1L2.pcap
${input_file2_1116}=             ${OUTPUT_DIR}/BIP_L1L2_second.pcap

${dir_path1_1116}=               ${OUTPUT_DIR}/BIP_log_1.pdml
${dir_path2_1116}=               ${OUTPUT_DIR}/BIP_log_2.pdml

${filter_1_1116}=                "DlData_RimRsSendReq_t.nscID == 1"
${filter_2_1116}=                "DlData_RimRsSendReq_t.nscID == 3"

${alias_1116}=                   L1L2_BIP_Logs

*** Keywords ***
CB009823-A1_Start_RIMRS_transmission_and_RS1_detection_depending_on_RI_enabled_5GC001116_4GP_0ms_shift
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In DL and UL   ue_id=1    pdu=1    tput_ul=1     tput_dl=1
    Generate RI For 1116 FS
    Wait For Fault To Be Up     fault_id=7525   timeout=1800
    Start Gathering BIP Logs And Wait 200s
    Stop gnbMirroring And Gather L1L2 Bip Logs  ${alias_1116}    ${input_file1_1116}
    Convert pcap file to pdml    ${input_file1_1116}    ${filter_1_1116}    ${dir_path1_1116}
    Verify If RS1 Is Properly Transmitted
    Generate RIMRS
    Wait For Fault To Be Up     fault_id=7527   timeout=2000
    Start Gathering BIP Logs And Wait 200s
    Stop gnbMirroring And Gather L1L2 Bip Logs  ${alias_1116}    ${input_file2_1116}
    Convert pcap file to pdml    ${input_file2_1116}    ${filter_2_1116}    ${dir_path2_1116}
    Verify If RS2 Is Properly Transmitted
    Verify PM Counters For RIMRS
    Stop Generate RI
    Wait For Fault To Be Down     fault_id=7525   timeout=600
    Wait For Next Pm Interval
    Verify If Pm Counters Are Not Incremented
