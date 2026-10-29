*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    RAN_5G    RAN_5G_TDD

Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Library     ../resources/common_keywords.py
Library     ../resources/pm_counters_validator.py
Library     ta5g_pm_counters
Library     keywords_CB009823.py
Resource    keywords_CB009823.robot

Documentation
...    author: Marek Niescioruk (marek.niescioruk@nokia.com}
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 24R3

Suite Setup     Run Keywords    Enable Syslog Info Level Prints
    ...       AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    ...       AND    Configure VM interfaces For Second Gnb
    ...       AND    Set Tdd Frame_1208
    ...       AND    Choose Lue File Based On Detected Configuration And Reach Onair
    ...              lua_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              lua_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
    ...       AND    Configure Rimrs Framework-1_1208
    ...       AND    Set Internal Traffic Type To UEs
    ...       AND    Prepare Rimrs Testmode For 1208 FS
    ...       AND    Wait For Next Full Pm Interval

Test Teardown    Run Keywords    Check For An Unexpected Alarm
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
CB009823-B5_Stop_Unconditional_DL_mitigation_enabled_5GC001208
    Register Ue With Default Pdu Session
    Start Data Traffic In DL and UL   ue_id=1    pdu=1    tput_ul=10     tput_dl=15
    Activate RI
    Wait For Fault To Be Up     fault_id=7525   timeout=850
    Activate RIMRS
    Wait For Fault To Be Up     fault_id=7527   timeout=1800
    Wait For RS2 To Be Detected
    Cellect BIPlogs    BIP_L1L2_01.pcap    ${pdml_file_1}
    Verify If Mitigation Started And Transsmission PDSCH Is Not Visible In Muting Slots    ${pdml_file_1}    @{slots_to_check}
    Verify PM Counters For RIMRS    ul_symbols=16    average_RSSI=${-62.99}
    Deactivate RIMRS
    Wait For Fault To Be Down     fault_id=7527   timeout=2000
    Deactivate RI
    Wait For Fault To Be Down     fault_id=7525   timeout=850
    Cellect BIPlogs    BIP_L1L2_02.pcap    ${pdml_file_2}
    Verify If Mitigation Stopped And Transsmission PDSCH Is Visible In Muting Slots    ${pdml_file_2}    @{slots_to_check}
    Verify If Pm Counters Are Not Incremented
    Deregister Ue    ue_id=1
