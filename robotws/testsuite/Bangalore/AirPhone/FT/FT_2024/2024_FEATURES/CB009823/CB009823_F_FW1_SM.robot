*** Settings ***
Documentation  Script for CB009823
Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP    CRT    SBTS00    RAN_5G    RAN_5G_FDD
...   PY36

Resource     ./resources/Keywords/5G_SW_Keywords.robot
Resource     ./resources/Keywords/CB009823_keywords.robot
Resource     ../../resources/Keywords/generic_kw.robot
Library      ./resources/Python/CB009823_PCMD_verify.py


Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/CB009823_A_B_L_iphy.xml
    ...                        swconfig_flags_list=@{L2PS_RI_DEBUG}
    ...        AND             Start Default Logging
    ...        AND             Configure PCMD in Wireshark
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB009823_A_B_L_LEGACY_GNB_SCF.xml
    ...        AND             Check Radios Availability
#    ...        AND             Start SOS with BIP    "/opt/iphy/latest/sosReport_ASIL"

#Suite Teardown   Stop and collect with BIP SOS    "/opt/iphy/latest/sosReport_ASIL"  "/home/ute/logs/"

#Suite Teardown   Run Keywords    Print Active Alarms
##Suite Teardown   Run Keywords    Stop Default Processes And Gather Logs And Compress Logs

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
...      ((nsetapx.rimRsType == 0) && (nsetapx.rimRsSetId == 11111)) && (nsetapx.rimRsNearFarIndicator == 0)
${RIM_RS2_MEASUREMENTS}=      SEPARATOR=((nsetapx.rimRsType == 1) && (nsetapx.rimRsSetId == 22222)) &&
...      (nsetapx.rimRsNearFarIndicator == 0)
${folder_path}=   /home/ute/test_logs/

*** Test Cases
VERIFY_CB009823_F_RIM_FRAMEWORK_1_RI_RS1_RS2_ACT_DEACT
    [Documentation]         Verify the test case CB009823_F_TC_11_Verify_RIMRS_RS1_RS2_transmission
    ...                     b_by_AP_Detection_by_gNB_in_Mixed_band_scenario_with_different_globalF0ForRs
    ...                     Verification : 1. 7525 RI , 7527 RIMRS alarm detection - done
    ...                                    2. rsSetId validation via alarm text
    ...                                    3. PCMD validation - Not done as above (2) is ok
    ${list_alarm}    Get Coam Active Alarms
    Log to console     ${list_alarm}
    [Setup]    Run Keywords   Start Netcat for tracing
#    ...    AND     Setup X2 Link
    ...    AND     Start First Tcp Pcap
    Perform Cell Reconfiguration By Delta Commissioning for FW1
    Reach Onair    lua_cfg=${CURDIR}/config/CB009823_A_B_L_1CELL.cfg
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In UL   ue_id=1    pdu=1    tput_ul=175
    Generate RI For 1116 FS
    Wait For Fault To Be Up     fault_id=7525   timeout=900
    Activate RIMRS FW1
#    Verify PCMD Trace Records for RI    packet_filter=${RI_SLOPE_MEASUREMENTS}
    Wait For Fault To Be Up     fault_id=7527   timeout=1900
    ${alarm_text_info}    Get 7527 alarm setid
    Log to console     ${alarm_text_info}
    Sleep    300
#    rssetid validation for rs1 , rs2
    ${alarm_text_info}    Get 7527 alarm setid
     Log to console     ${alarm_text_info}
#    /** rsSetId validation in Alarm text - enabled after customer PR : 03851885 merged in trunk **/
    Should Contain    "${alarm_text_info}"     detected RIM RS1 setIDs list is 11111        ignore_case=True
    Should Contain    "${alarm_text_info}"     detected RIM RS2 setIDs list is 22222        ignore_case=True
#   Below PCMD check commented as above text can valdate rssetid
##    Verify PCMD Trace Records for RIM-RS      packet_filter=${RIM_RS1_MEASUREMENTS}
##    Verify PCMD Trace Records for RIM-RS      packet_filter=${RIM_RS2_MEASUREMENTS}
##    ${file_path}=     Find Latest Pcapng File  ${folder_path}
##    Convert pcap file to pdml     ${file_path}
#    Verify If All PCMD Records For RI and RIMRS Exist
    Stop Netact for tracing
    Stop Tcp Pcap
    Deactivate RIMRS FW1
    Sleep   100s
    Log to console     Waiting for 7527 RIMRS alarm to be down
    Wait For Fault To Be Down     fault_id=7527   timeout=600
#   commented till tag5g support to detect alarm in specific cell id
#    Deactivate RI
#    Sleep   100s
#    Log to console     Waiting for 7525 Remote Interference alarm to be down
#    Wait For Fault To Be Down     fault_id=7525   timeout=600
##    [Teardown]    Stop All Data Transfers And Detach UE
