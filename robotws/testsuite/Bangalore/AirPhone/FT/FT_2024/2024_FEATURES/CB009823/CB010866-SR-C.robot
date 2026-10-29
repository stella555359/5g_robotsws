*** Settings ***
Documentation  CB009823
Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP    CRT    SBTS00    RAN_5G    RAN_5G_FDD
...   PY36

Resource     ./resources/Keywords/5G_SW_Keywords.robot
Resource     ./resources/Keywords/CB009823_keywords.robot
Resource     ../../resources/Keywords/generic_kw.robot
Library      ./resources/Python/CB009823_PCMD_verify.py

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/CB009823_E_iphy.xml
    ...                        swconfig_flags_list=@{L2PS_RI_DEBUG}
    ...        AND             Start Default Logging
    ...        AND             Configure PCMD in Wireshark
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=CB009823_E_gnb_scf_2cell__40_80_mhz_semistatic_fw1.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/CB009823_E_2CELL_40M_80M.cfg
#    ...        AND             Start SOS with BIP    "/opt/iphy/latest/sosReport_ASIL"

#Suite Teardown   Stop and collect with BIP SOS    "/opt/iphy/latest/sosReport_ASIL"  "/home/ute/logs/
#Suite Teardown   Run Keywords    Print Active Alarms
#Suite Teardown   Run Keywords    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${port_trace}                         49151
${ip_trace}                           10.0.1.10

@{L2PS_RI_DEBUG}=           0x58057A = 4
...                         0x580582 = 3
...                         0x58057b = 8
...                         0x58012d=2 # k1min=4
...                         0x5800f4=2 # k2min=4

${NOISE_POWER_FOR_RI}=     SEPARATOR=
...                        -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-104,
...                        -105,-99,-95,-90,-85,-80,-75,-71,-67,-64,-60,-55,-50,-47

${NOISE_POWER_RI}=       SEPARATOR=
...                       -55,-60,-65,-70,-75,-80,-85,-90,-95,-100,-105,-110,-115,-115,-115,-115,-115,
...                       -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115

${RIM_RS1_MEASUREMENTS}=      SEPARATOR=
...      (((nsetapx.rimRsSetId == 33333) && (nsetapx.rimRsType == 0)) &&
...      (nsetapx.enoughIndicator == 0)) && (nsetapx.rimRsNearFarIndicator == 0)

${RIM_RS2_MEASUREMENTS}=      SEPARATOR=
...      ((nsetapx.rimRsType == 1) && (nsetapx.rimRsSetId == 44334)) && (nsetapx.rimRsNearFarIndicator == 0)

${folder_path}=   /home/ute/test_logs/

*** Test Cases ***
CB010866_C_Verify_FW1_leap_seconds_auto_on_off_manual_standAlone_Mode_RIM_RS1_RS2_detection_at_gNB
    [Documentation]         Verifies CB010866-C Airphone specific below leap_secodns
    ...                     1. FW1 : leap_secodns_auto = on ; leap_seconds_manual = any values
    ...                     2. FW1 : leap_seconds_auto = off; leap_seconds_manual = 27
    ...                     3. FW1 : leap_seconds_auto = off; leap_seconds_manual = other 27
    ...                     Verification : 1. 7525 RI , 7527 RIMRS alarm detection - done
    ...                                    2. rsSetId validation via alarm text -script commented-waiting for code
    ...                                    3. PCMD validation - Not done as above (2) is ok
    Log to console     NOTE : Default leap_seconds is 27seconds. Future this case may fail if changed at gNB side.
    ${list_alarm}    Get Coam Active Alarms
    Log to console     ${list_alarm}
    [Setup]    Run Keywords   Start Netcat for tracing
    ...    AND     Setup X2 Link
    ...    AND     Start First Tcp Pcap
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In UL   ue_id=1    pdu=1    tput_ul=175
    Activate RI
    Wait For Fault To Be Up     fault_id=7525   timeout=1900
#   1. FW1 : leap_secodns_auto = on ; leap_seconds_manual = any values
#   Correct rsSetid with 7527 RIMRS alarm up
    Activate RIMRS FW1 9823-E with leap_seconds     leap_seconds_auto=on     leap_seconds_manual=55
#    Wait For Fault To Be Up     fault_id=7527   timeout=1900
    ${alarm_text_info}    Get 7527 alarm setid
    Log to console     ${alarm_text_info}
    Sleep    20

#    rssetid validation for rs1 , rs2
    ${alarm_text_info}    Get 7527 alarm setid
     Log to console     ${alarm_text_info}
#    /** rsSetId validation in Alarm text - enabled after customer PR : 03851885 merged in trunk **/
#   Should Contain    ${alarm_text_info}     11111        ignore_case=True
#    Should Contain    ${alarm_text_info}     22222        ignore_case=True
    Should Contain    ${alarm_text_info}     RS1        ignore_case=True
    Should Contain    ${alarm_text_info}     RS2        ignore_case=True
    Sleep    15s
#    Verify PCMD Trace Records for RIM-RS      packet_filter=${RIM_RS1_MEASUREMENTS}
#    Verify PCMD Trace Records for RIM-RS      packet_filter=${RIM_RS2_MEASUREMENTS}
    Stop Netact for tracing
    Stop Tcp Pcap
    ${file_path}=     Find Latest Pcapng File  ${folder_path}
    Convert pcap file to pdml     ${file_path}
    Deactivate RIMRS FW1
    Sleep   100s
    Log to console     Waiting for 7527 RIMRS alarm to be down
    Wait For Fault To Be Down     fault_id=7527   timeout=600
    Sleep   10s

#   2. FW1 : leap_seconds_auto = off; leap_seconds_manual = 27
#   Correct rsSetid with 7527 RIMRS alarm up
    Activate RIMRS FW1 9823-E with leap_seconds     leap_seconds_auto=off     leap_seconds_manual=27
    Wait For Fault To Be Up     fault_id=7527   timeout=1900
    ${alarm_text_info}    Get 7527 alarm setid
    Log to console     ${alarm_text_info}
   Sleep    10

    Deactivate RIMRS FW1
    Sleep   100s
    Log to console     Waiting for 7527 RIMRS alarm to be down
    Wait For Fault To Be Down     fault_id=7527   timeout=600

#   3. FW1 : leap_seconds_auto = off; leap_seconds_manual = other 27
#   wrong rsSetid with 7527 RIMRS alarm up or NO 7527 RIMRS alarm
    Activate RIMRS FW1 9823-E with leap_seconds     leap_seconds_auto=off     leap_seconds_manual=-75
#    Run Keyword And Expect Error       Wait For Fault To Be Up        fault_id=7527   timeout=1900
    Log to console      Expected 7527 fault not to be up and continue
    ${keyword_status}     Run Keyword And Ignore Error       Wait For Fault To Be Up        fault_id=7527   timeout=1900
    Log to console     ${keyword_status}
    ${alarm_text_info}    Get 7527 alarm setid
    Log to console     ${alarm_text_info}
    Sleep    10

    Deactivate RI
    Sleep   100s
    Log to console     Waiting for 7525 Remote Interference alarm to be down
    Wait For Fault To Be Down     fault_id=7525   timeout=700
    [Teardown]    Stop All Data Transfers And Detach UE
