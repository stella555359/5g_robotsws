*** Settings ***
Documentation
...     author: Wojciech Szczesniak
...     maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...     testline: CLOUD_5G_I_LO_AP_LO
...     release: 25R2

Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Resource    ../resources/configuration_id.robot
Resource     CB010437_keywords.robot
Library      CB010437_PCMD_verify.py

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_2AEQE.xml
    ...                        swconfig_flags_list=@{L2PS_RI_DEBUG}
    ...        AND             Start Default Logging
    ...        AND             Configure PCMD in Wireshark
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB010437_2_cells_ABIP_1116_3.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/RIMRS_from_gNB_basic_setup2cell.cfg

#Suite Teardown   Run Keywords    Print Active Alarms
#    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{L2PS_RI_DEBUG}=           0x58057A = 4
...                         0x580582 = 3
...                         0x58057b = 8
${port_trace}                         49151
${ip_trace}                           10.0.1.10
${NOISE_POWER_FOR_RI}=     SEPARATOR=
...                        -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-104,
...                        -105,-99,-95,-90,-85,-80,-75,-71,-67,-64,-60,-55,-50,-47

${RI_SLOPE_MEASUREMENTS}=    SEPARATOR=
...      ((((((((nsetapx.riSlopeMeasRecord) && (nsetapx.recordCollectionDuration == 5000))) &&
...      (nsetapx.ulDropHeightDataList)) && (nsetapx.slotNumber)) && (nsetapx.minDropHeight)) &&
...      (nsetapx.maxDropHeight)) && (nsetapx.numOfDropHeightSamples)) && (nsetapx.sumOfDropHeight)


${RIM_RS_MEASUREMENTS}=      SEPARATOR=
...      (((nsetapx.rimRsMonitoringRecord == 1) && (nsetapx.rimRsSetId == 12346)) &&
...      (nsetapx.propagationDelayInSymbol)) && (nsetapx.repetitionIndex == 1)

${RIM_RS_MEASUREMENTS_RECONF}=      SEPARATOR=
...      ((nsetapx.rimRsMonitoringRecord == 1) && (nsetapx.propagationDelayInSymbol)) &&
...      (nsetapx.repetitionIndex == 2)

${NO_CONTENT_FOR_PCMDREPORTING}=      (nsetapx.dlRbRlcMeasRecord  == 0) && (nsetapx.ulRbRlcMeasRecord == 0)
${folder_path}=   /home/ute/test_logs/

*** Test Cases ***
CB010437-A_US1_US3_Activation_PCMD_trace_content_and_deactivation_via_actPCMDReport_flag_RI_slope_and_RIM-RS_records_2cells_SA
    [Setup]    Run Keywords   Start Netcat for tracing
    ...    AND     Setup X2 Link
    ...    AND     Start First Tcp Pcap
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In UL   ue_id=1    pdu=1    tput_ul=175
    Generate RI For 1116 FS
    Wait For Fault To Be Up     fault_id=7525   timeout=1500
    Generate RIMRS
    Wait For Fault To Be Up     fault_id=7527   timeout=2500
    Sleep    15s
    Verify PCMD Trace Records for RI    packet_filter=${RI_SLOPE_MEASUREMENTS}
    Verify PCMD Trace Records for RIM-RS      packet_filter=${RIM_RS_MEASUREMENTS}
    Verify If PCMD Content Related to actPCMDReporting Flag Is Not Sent To TCE      packet_filter=${NO_CONTENT_FOR_PCMDREPORTING}
    Stop Netact for tracing
    Stop Tcp Pcap
    ${file_path}=     Find Latest Pcapng File  ${folder_path}
    Convert pcap file to pdml     ${file_path}
    Verify If All PCMD Records For RI and RIMRS Exist
    [Teardown]    Run Keywords     Stop All Data Transfers And Detach UE
    ...    AND    Send Configuration ID To Scout



