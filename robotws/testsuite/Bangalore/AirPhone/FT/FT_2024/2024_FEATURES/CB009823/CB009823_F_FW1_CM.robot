*** Settings ***
Documentation  Script for CB009823
Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP    CRT    SBTS00    RAN_5G    RAN_5G_FDD
...   PY36

Resource     ./resources/Keywords/5G_SW_Keywords.robot
Resource     ./resources/Keywords/CB009823_keywords.robot
Resource     ../../resources/Keywords/generic_kw.robot
Library      ./resources/Python/CB009823_PCMD_verify.py


Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/CB009823_F_2CELL_40M_40M_iphy.xml
    ...                        swconfig_flags_list=@{L2PS_RI_DEBUG}
    ...        AND             Start Default Logging
    ...        AND             Configure PCMD in Wireshark
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=CB009823_F_2CELL_40m_40M_FW1_CM_GNB_SCF.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/CB009823_F_CM_2CELL_40M_40M.cfg
#    ...        AND             Start SOS with BIP    "/opt/iphy/latest/sosReport_ASIL"

#Suite Teardown   Stop and collect with BIP SOS    "/opt/iphy/latest/sosReport_ASIL"  "/home/ute/logs/"
#Suite Teardown   Run Keywords    Print Active Alarms
Suite Teardown   Run Keywords    Stop Default Processes And Gather Logs And Compress Logs

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

${RIM_RS_MEASUREMENTS_C1}=      SEPARATOR=
...      ((nsetapx.rimRsSetId == 33332) && (nsetapx.rimRsType == 1)) &&
...      (nsetapx.rimRsNearFarIndicator == 0)

${RIM_RS_MEASUREMENTS_C2}=      SEPARATOR=
...      ((nsetapx.rimRsSetId == 21343) && (nsetapx.rimRsType == 0)) &&
...      (nsetapx.rimRsNearFarIndicator == 0)

${folder_path}=   /home/ute/test_logs/

*** Test Cases ***
RIM_FRAMEWORK_1_RI_RS1_RS2_ACT_DEACT
    [Documentation]         Verify the test case CB009823_F_TC_11_Verify_RIMRS_RS1_RS2_transmission
    ...                     b_by_AP_Detection_by_gNB_in_Mixed_band_scenario_with_different_globalF0ForRs
    ...                     Verification : 1. 7525 RI detection on CELL 1 , CELL 2, 7527 RIMRS alarm detection - done
    ...                                    TBD : Checking alarm w.r.t cell is yet to be supported by TAF. conveyed.
    ...                                          waiting for the updated keyword
    ...                                    2. rsSetId validation via alarm text -script commented-waiting for code
    ...                                    3. PCMD validation - Not done as above (2) is ok; still logs are captured.
    ${list_alarm}    Get Coam Active Alarms
    Log to console     ${list_alarm}
    [Setup]    Run Keywords   Start Netcat for tracing
    ...    AND     Setup X2 Link
    ...    AND     Start First Tcp Pcap
#    Perform Cell Reconfiguration By Delta Commissioning for FW1
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In UL   ue_id=1    pdu=1    tput_ul=50
    Start Data Traffic In DL   ue_id=1    pdu=1    tput_dl=5
    Activate RI

    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=2    pdu_id=1    gw_id=1
    Start Data Traffic In UL   ue_id=2    pdu=1    tput_ul=50
    Start Data Traffic In DL   ue_id=2    pdu=1    tput_dl=5
    Activate RI for cell2

#    Wait For Fault To Be Up     fault_id=7525   cell_id=1    timeout=1900
#    Wait For Fault To Be Up     fault_id=7525   cell_id=2    timeout=1900
#TBD    wait for cell fault to be up      fault_id=7525   cell_id=1    timeout=1900
#TBD    wait for cell fault to be up     fault_id=7525   cell_id=2    timeout=1900


    Activate RIMRS FW1 9823-E coordinated Mode for cell1 cell2
    Check Ue Status Nr     ue_id=1      type=pusch
#TBD    Wait For Fault To Be Up     fault_id=7527   cell_id=1   timeout=1900

    ${alarm_text_info}    Get 7527 alarm setid
    Log to console     ${alarm_text_info}
    Sleep    120

    Check Ue Status Nr     ue_id=2      type=pusch
#    Wait For Fault To Be Up     fault_id=7527   cell_id=2    timeout=1900
#     wait for cell fault to be up     fault_id=7527   cell_id=2    timeout=1900
#    rssetid validation for rs1 , rs2
    ${alarm_text_info}    Get 7527 alarm setid
     Log to console     ${alarm_text_info}
#    /** rsSetId validation in Alarm text - enabled after customer PR : 03851885 merged in trunk **/
#    Should Contain    ${alarm_text_info}     11111        ignore_case=True
#    Should Contain    ${alarm_text_info}     22222        ignore_case=True
#    Should Contain    ${alarm_text_info}     RS1        ignore_case=True
#    Should Contain    ${alarm_text_info}     RS2        ignore_case=True
    Sleep    15s
#   Verify RS1 , RS2 content from PCMD logs
##    Verify PCMD Trace Records for RIM-RS      packet_filter=${RIM_RS_MEASUREMENTS_C1}
##    Verify PCMD Trace Records for RIM-RS      packet_filter=${RIM_RS_MEASUREMENTS_C2}
    Stop Netact for tracing
    Stop Tcp Pcap
    ${file_path}=     Find Latest Pcapng File  ${folder_path}
    Convert pcap file to pdml     ${file_path}
    Check Ue Status Nr     ue_id=1      type=pusch
    Deactivate RIMRS FW1
    Log to console     Waiting for 7527 RIMRS alarm to be down
    Wait For Fault To Be Down     fault_id=7527   timeout=600

    Log to console     Waiting for 7525 Remote Interference alarm to be down
#   Till taf5g support to check alarm down specific to cell id below is commented.
#    Deactivate RI
#    Sleep    100s
#    Wait For Fault To Be Down     fault_id=7525   timeout=900
    [Teardown]    Stop All Data Transfers And Detach UE
