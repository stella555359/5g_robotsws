*** Settings ***
Documentation    :copyright: Nokia

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Resource     CNI_103138_keywords.robot
Library      rimrs_periodicity_verify.py
Resource     ../resources/configuration_id.robot

Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_2AEQE.xml
    ...                        swconfig_flags_list=@{L2PS_RI_DEBUG}
    ...        AND             Start Default Logging
    ...        AND             Configure PCMD in Wireshark
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CNI_103138_19_bit.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/RIMRS_from_gNB_basic_setup2cell.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${port_trace}               49151
${ip_trace}                 10.0.1.10

${pdml_file}             ${OUTPUT_DIR}/BIP_log_1.pdml

@{L2PS_RI_DEBUG}=           0x58057A = 4
...                         0x580582 = 3
...                         0x58057f = 8
...                         0x58057b = 8
...                         0x3F007C = 800
...                         0x5901C9 = 1 #CB8941 L3_rdUlUpFragmentationEnable
...                         0x5901CA = 1 #CB8941 L3_rdDlUpFragmentationEnable

${NOISE_POWER_RI}=       SEPARATOR=
...                       -55,-60,-65,-70,-75,-80,-85,-90,-95,-100,-105,-110,-115,-115,-115,-115,-115,
...                       -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115

${RIMRS_SET_IDS}=      nsetapx.rimRsSetId == 22222
${folder_path}=     /home/ute/test_logs/

*** Test Cases ***
CNI-103138_support_19bits_length_setIDs_on_top_of_CB006991
    [Setup]    Run Keywords   Start Netcat for tracing
    ...    AND     Setup X2 Link
    ...    AND     Start Tcp Pcap
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In DL and UL   ue_id=1    pdu=1    tput_ul=25     tput_dl=25
    Generate Remote Interferences
    Wait For Fault To Be Up     fault_id=7525   timeout=800
    Trigger RIMRS
    Wait For Fault To Be Up     fault_id=7527   timeout=1500
    Start Gathering BIP Logs And Wait 200s
    Stop gnbMirroring And Gather L1L2 Bip Logs
    Convert Pcap File To Pdml
    Verify Rimrs Periodicity   ${OUTPUT_DIR}/BIP_log_1.pdml    dldata_rimrssendreq    ${41.0}    ${1.0}
    Stop Netcat for tracing
    Verify If Received RsSetID Is Correct        packet_filter=${RIMRS_SET_IDS}
    [Teardown]    Run Keywords     Stop Tcp Pcap
    ...      AND     Stop And Teardown PCMD
    ...      AND     Stop All Data Transfers And Detach UE
    ...    AND    Send Configuration ID To Scout

