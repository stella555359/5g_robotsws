*** Settings ***
Library     ta5g_pm_counters
Library     keywords_CB009823.py
Resource    keywords_CB009823.robot

Documentation
...    author: Marek Niescioruk (marek.niescioruk@nokia.com}
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_MP_AP_LO
...    release: 24R3

*** Variables ***
@{L2PS_RI_DEBUG}=           0x58057A = 4
...                         0x580582 = 3
...                         0x58057b = 8
...                         0x58057f= 72
...                         0x3F007C = 1000

${NOISE_POWER_RI}=       SEPARATOR=
...                       -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-105,
...                       -110,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115

${pdml_file_1}=    ${OUTPUT_DIR}/BIP_log_01.pdml
${pdml_file_2}=    ${OUTPUT_DIR}/BIP_log_02.pdml
@{slots_to_check}=    2    3   12    13
${RIMRS_SET_ID}=    (nsetapx.rimRsSetId == 22222)

*** Keywords ***
CB009823-B1_Start_Rimrs_Detection_Enabled_5GC001116_4gp_0ms_Shift
    Prepare Rimrs Testmode For 1116 FS
    Register Ue With Default Pdu Session
    Start Data Traffic In DL and UL   ue_id=1    pdu=1    tput_ul=10     tput_dl=10
    Activate RI
    Check If Alarm Is Active    fault_id=7525    timeout=1800
    Activate RIMRS
    Check If Alarm Is Active    fault_id=7527    timeout=2400
    Check If Rs1 And Rs2 Are Detected    timeout=3000
    Cellect BIPlogs    BIP_L1L2_01.pcap    ${pdml_file_1}
    Verify If Mitigation Started And Transsmission PDSCH Is Not Visible In Muting Slots    ${pdml_file_1}    @{slots_to_check}
    Wait For Next Full Pm Interval
    Verify PM Counters For RIMRS    ul_symbols=16    average_RSSI=${-63}
    Deregister Ue    ue_id=1
