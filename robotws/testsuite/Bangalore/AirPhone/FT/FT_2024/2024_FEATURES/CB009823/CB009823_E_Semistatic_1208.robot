*** Settings ***
Documentation  Script for CB009823
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

#Suite Teardown   Stop and collect with BIP SOS    "/opt/iphy/latest/sosReport_ASIL"  "/home/ute/logs/"
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
${RIM_RS_E_VALIDATION_RS1}=        SEPARATOR=
...      ((nsetapx.rimRsType == 0) && (nsetapx.rimRsSetId == 33333)) && (nsetapx.enoughIndicator == 0)

${RIM_RS_E_VALIDATION_RS2}=        SEPARATOR=
...      ((nsetapx.rimRsSetId == 44334) && (nsetapx.rimRsNearFarIndicator == 0)) && (nsetapx.rimRsType == 1)


#${RIM_RS_E_VALIDATION_RS1}=        SEPARATOR=
#...      ((nsetapx.enoughVerdict == 0) && (nsetapx.rimRsSetId == 33333)) && (nsetapx.DuVendorExtensionRecordDataType == 19)

${NO_CONNTENT_FOR_PCMDREPORTING}=      (nsetapx.dlRbRlcMeasRecord  == 0) && (nsetapx.ulRbRlcMeasRecord == 0)
${folder_path}=   /home/ute/test_logs/

*** Test Cases ***
VERIFY_CB009823_E_Semistatic_1208__RI_RS1_RS2_ACT_DEACT
    [Documentation]         Verify the test case CB009823_F_TC_11_Verify_RIMRS_RS1_RS2_transmission
    ...                     b_by_AP_Detection_by_gNB_in_Mixed_band_scenario_with_different_globalF0ForRs
    ...                     Verification : 1. 7525 RI , 7527 RIMRS alarm detection - done
    ...                                    2. rsSetId validation via alarm text -script commented-waiting for code
    ...                                    3. PCMD validation - Not done as above (2) is ok
    ${list_alarm}    Get Coam Active Alarms
    Log to console     ${list_alarm}
    [Setup]    Run Keywords   Start Netcat for tracing
    ...    AND     Setup X2 Link
    ...    AND     Start First Tcp Pcap
#    Perform Cell Reconfiguration By Delta Commissioning for FW1
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In UL   ue_id=1    pdu=1    tput_ul=175
    Activate RI
#    Generate RI For 1116 FS
    Wait For Fault To Be Up     fault_id=7525   timeout=1900
    Activate RIMRS FW1 9823-E
#    Verify PCMD Trace Records for RI    packet_filter=${RI_SLOPE_MEASUREMENTS}
    Wait For Fault To Be Up     fault_id=7527   timeout=1900
    ${alarm_text_info}    Get 7527 alarm setid
    Log to console     ${alarm_text_info}
    Sleep    120
#    rssetid validation for rs1 , rs2
    ${alarm_text_info}    Get 7527 alarm setid
     Log to console     ${alarm_text_info}
    Should Contain    ${alarm_text_info}     33333        ignore_case=True
    Should Contain    ${alarm_text_info}     44334        ignore_case=True
    Should Contain    ${alarm_text_info}     RS1        ignore_case=True
    Should Contain    ${alarm_text_info}     RS2        ignore_case=True
    Sleep    15s
#    Verify PCMD Trace Records for RIM-RS      packet_filter=${RIM_RS_E_VALIDATION_RS1}
#    Verify PCMD Trace Records for RIM-RS      packet_filter=${RIM_RS_E_VALIDATION_RS2}
     Stop Netact for tracing
     Stop Tcp Pcap
    ${file_path}=     Find Latest Pcapng File  ${folder_path}
    Convert pcap file to pdml     ${file_path}
#    Verify If All PCMD Records For RI and RIMRS Exist
    Deactivate RIMRS FW1
    Sleep   100s
    Log to console     Waiting for 7527 RIMRS alarm to be down
    Wait For Fault To Be Down     fault_id=7527   timeout=600
#    Till alarm check for down specific to cellid supported in taf5g below commented
#
    Deactivate RI
    Sleep   100s
    Log to console     Waiting for 7525 Remote Interference alarm to be down
    Wait For Fault To Be Down     fault_id=7525   timeout=700
    [Teardown]    Stop All Data Transfers And Detach UE
