*** Settings ***
Documentation  Script for CB009823_LEGACY
Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP    CRT    SBTS00    RAN_5G    RAN_5G_FDD
...   PY36

Resource     ./resources/Keywords/5G_SW_Keywords.robot
Resource     ./resources/Keywords/CB009823_keywords.robot
Library      ./resources/Python/CB009823_PCMD_verify.py

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/CB009823_A_B_L_iphy.xml
    ...                        swconfig_flags_list=@{L2PS_RI_DEBUG}
    ...        AND             Start Default Logging
    ...        AND             Configure PCMD in Wireshark
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB009823_A_B_L_LEGACY_GNB_SCF.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/CB009823_A_B_L_1CELL.cfg

#Suite Teardown   Run Keywords    Print Active Alarms
#    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

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

${RI_SLOPE_MEASUREMENTS}=    SEPARATOR=
...      ((((nsetapx.riSlopeMeasRecord == 0) && (nsetapx.recordCollectionDuration == 10000)) &&
...      (nsetapx.slotNumber == 7)) && (nsetapx.symbolNumber == 12) && (nsetapx.numOfDropHeightSamples))
${RIM_RS_MEASUREMENTS}=      SEPARATOR=
...      (((nsetapx.rimRsMonitoringRecord == 1) && (nsetapx.rimRsSetId == 12346)) &&
...      (nsetapx.propagationDelayInSymbol)) && (nsetapx.repetitionIndex == 1)
${RIM_RS_MEASUREMENTS_RECONF}=      SEPARATOR=
...      ((nsetapx.rimRsMonitoringRecord == 1) && (nsetapx.propagationDelayInSymbol)) &&
...      (nsetapx.repetitionIndex == 2)

${NO_CONNTENT_FOR_PCMDREPORTING}=      (nsetapx.dlRbRlcMeasRecord  == 0) && (nsetapx.ulRbRlcMeasRecord == 0)
${folder_path}=   /home/ute/test_logs/

*** Test Cases ***
VERIFY_LEGACY_A_B_L_RIM_FRAMEWORK_0_RI_RS1_RS2_ACT_DEACT
    [Documentation]         Verify the test case TC_01_CB009823_E_Verify_AP_legacy_Rim_RS_Type1_RIM_RS_Type2
    ...                     Transmission_And_Detection_at_gNB
    ...                     Verification : 1. 7525 RI , 7527 RIMRS alarm detection - done
    ...                                    2. rsSetId validation via alarm text -script commented-waiting for code
    ...                                    3. PCMD validation - Not done as above (2) is ok

    [Setup]    Run Keywords   Start Netcat for tracing
    ...    AND     Setup X2 Link
    ...    AND     Start First Tcp Pcap
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In UL   ue_id=1    pdu=1    tput_ul=175
    Activate RI
    Log to console     Waiting for 7525 Remote Interference Alarm
    Wait For Fault To Be Up     fault_id=7525   timeout=800
    Activate RIMRS
    Log to console     Waiting for 7527 RIM RS alarm
#    Verify PCMD Trace Records for RI    packet_filter=${RI_SLOPE_MEASUREMENTS}
    Wait For Fault To Be Up     fault_id=7527   timeout=1500
    ${bts_alarms}    Get Coam Active Alarms
    Log to console     ${bts_alarms}
    Sleep    15s
#    Verify PCMD Trace Records for RIM-RS      packet_filter=${RIM_RS_MEASUREMENTS}
    Stop Netact for tracing
    Stop Tcp Pcap
#    ${file_path}=     Find Latest Pcapng File  ${folder_path}
#    Convert pcap file to pdml     ${file_path}
#    Verify If All PCMD Records For RI and RIMRS Exist
    Perform Cell Reconfiguration By Delta Commissioning
    Change RIMRS profile
    Start Netcat for tracing
    Start Second Tcp Pcap
    Log to console     Waiting for 7527 RIM RS alarm
    Wait For Fault To Be Up     fault_id=7527   timeout=2000
    Sleep     15s
#    Verify PCMD Trace Records for RIM-RS After Cell Reconfiguration     packet_filter=${RIM_RS_MEASUREMENTS_RECONF}
    Stop Netact for tracing
    Stop Second Tcp Pcap
    Deactivate RI
    Sleep   100s
    Start Netcat for tracing
    Start Tcp Pcap for RI Deactivate
    Log to console     Waiting for Alarm clear 7525 Remote Interference
    Wait For Fault To Be Down     fault_id=7525   timeout=600
    Stop Netact for tracing
#    Start Tcp Pcap For RI Deactivate
#    Perform Delta Commisioning To Disable ActNRrim
#    Start Netcat for tracing
#    Start Third Tcp Pcap
#    Wait For Another PCMD Records
#    Verify If PCMD Records For RI Are Not Sent      packet_filter=${RIM_RS_MEASUREMENTS}
#    Verify IF PCMD Records For RIMRS Are Not Sent      packet_filter=${RIM_RS_MEASUREMENTS_RECONF}
#    Stop Netact for tracing
#    Stop Third Tcp Pcap
    [Teardown]    Stop All Data Transfers And Detach UE


