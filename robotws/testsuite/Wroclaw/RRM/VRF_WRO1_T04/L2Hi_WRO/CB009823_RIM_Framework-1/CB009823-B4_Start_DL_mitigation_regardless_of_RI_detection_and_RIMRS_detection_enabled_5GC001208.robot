*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ../resources/pm_counters_validator.py
Library     ta5g_pm_counters
Library     keywords_CB009823.py
Resource    keywords_CB009823.robot

Documentation
...    author: Michał Brychcy (michal.brychcy@nokia.com}
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 24R3

Suite Setup     Run Keywords    Enable Syslog Info Level Prints
    ...       AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    ...       AND    Configure VM interfaces For Second Gnb
    ...       AND    Enable actDisableEcpriUlScalingEnh
    ...       AND    Enable actRinCmFmReport
    ...       AND    Set Tdd Frame_1208
    ...       AND    Choose Lue File Based On Detected Configuration And Reach Onair
    ...              lua_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              lua_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
    ...       AND    Configure Rimrs Framework-1_1208
    ...       AND    Set Internal Traffic Type To UEs
    ...       AND    Wait For Next Full Pm Interval

Test Teardown    Run Keywords    Check For An Unexpected Alarm
    ...       AND    Send Configuration ID To Scout
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs

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
@{slots_to_check}=    3    7    8    12    13    17    18
${RIMRS_SET_ID}=    (nsetapx.rimRsSetId == 22222)

*** Test Cases ***
CB009823-B4_Start_DL_mitigation_regardless_of_RI_detection_and_RIMRS_detection_enabled_5GC001208
    Prepare Rimrs Testmode For 1208 FS
    Register Ue With Default Pdu Session
    Start Data Traffic In DL and UL   ue_id=1    pdu=1    tput_ul=10     tput_dl=10
    Activate RI
    Check If Alarm Is Active    fault_id=7525    timeout=1800
    Activate RIMRS
    Check If Alarm Is Active    fault_id=7527    timeout=2400
    Check If Rs1 And Rs2 Are Detected    timeout=3000
    Cellect BIPlogs    BIP_L1L2_01.pcap    ${pdml_file_1}
    Verify If Mitigation Started And Transsmission PDSCH Is Not Visible In Muting Slots    ${pdml_file_1}    @{slots_to_check}
    Verify PM Counters For RIMRS    ul_symbols=14    average_RSSI=${-91}
    Deregister Ue    ue_id=1
