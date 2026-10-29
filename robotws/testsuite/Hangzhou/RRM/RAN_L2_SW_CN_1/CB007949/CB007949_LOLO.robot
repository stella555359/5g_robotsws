*** Settings ***
Documentation    ...
#Resource    ./CB007949_resource.robot
#Resource    ../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Common Suite Setup
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    SBTS22R4     CN1_SQ
#...               RAN_5G    RAN_5G_TDD    CRT
#
#*** Variables ***
#${SCF_DIR}                     ${CURDIR}/config/SCF
#${SCF_1208_1208_1208_A03}      ${SCF_DIR}/SCF_3T_1208_1208_1208_A03.xml
#${SCF_1208_1116_0_A07}         ${SCF_DIR}/SCF_2T_1208_1116_0_A07.xml
#${SCF_1070_1208_A10}           ${SCF_DIR}/SCF_2T_1070_1208_A10.xml
#${SCF_1208_1116_1070_B03}         ${SCF_DIR}/SCF_3T_1208_1116_1070_B03.xml
#${SCF_1208_1070_1116_0_E01}         ${SCF_DIR}/SCF_3T_1208_1070_1116_0_E01.xml
#${SCF_1116_0_1208_1208_F03}         ${SCF_DIR}/SCF_3T_1116_0_1208_1208_F03.xml
#${SCF_1116_0_1070_A05}         ${SCF_DIR}/SCF_2T_1116_0_1070_A05.xml
#${SCF_1208_1208_1208_A19}      ${SCF_DIR}/SCF_3T_1208_1208_1208_A19.xml
#${SCF_1116_1116_1116_D04}         ${SCF_DIR}/SCF_3T_1116_1116_1116_D04.xml
#${SCF_1070_1208_1116_0_D06}         ${SCF_DIR}/SCF_3T_1070_1208_1116_0_D06.xml
#
#${IPHY_1116_0_1208_1208_F03}       iphy_3T_1116_0_1208_1208_F03.xml
#${IPHY_1208_1208_1208_A03}     iphy_3T_1208_1208_1208_A03.xml
#${IPHY_1070_1208_A10}          iphy_2T_1070_1208_A10.xml
#${IPHY_1208_1116_1070_B03}        iphy_3T_1208_1116_1070_B03.xml
#${IPHY_1116_1116_1116_D04}        iphy_3T_1116_1116_1116_D04.xml
#
#${WTS_CFG_1208_1208_1208_A03}    wts_cfg_ASIB_ABIO_3T_1208_1208_1208_A03.cfg
#${WTS_CFG__1070_1208_A10}        wts_cfg_ASIB_ABIO_2T_1070_1208_A10.cfg
#${WTS_CFG_1208_1116_1070_B03}     wts_cfg_ASIB_ABIO_3T_1208_1116_1070_B03.cfg
#${WTS_CFG_1208_1070_1116_0_E01}     wts_cfg_ASIB_ABIO_3T_1208_1070_1116_0_E01.cfg
#${WTS_CFG_1116_0_1208_1208_F03}    wts_cfg_ASIB_ABIO_3T_1116_0_1208_1208_F03.cfg
#${WTS_CFG_1116_0_1070_A05}    wts_cfg_ASIB_ABIO_2T_1116_0_1070_A05.cfg
#${WTS_CFG_1070_1208_1116_D04}     wts_cfg_ASIB_ABIO_3T_1116_1116_1116_D04.cfg
#${WTS_CFG_1070_1208_1116_0_D06}     wts_cfg_ASIB_ABIO_3T_1070_1208_1116_0_D06.cfg
#
#${Egatelog_path}    ${CURDIR}
#
#*** Test Cases ***
#CB007949-ET-A03 TDD 3CC CA with 5GC001208 frame structure
#    [Tags]     Owner_lading    case_A03
#    [Setup]    Setup TL For Each Case    ${SCF_1208_1208_1208_A03}    ${IPHY_1208_1208_1208_A03}
#    ...        ${WTS_CFG_1208_1208_1208_A03}    ${WTS_XML}
#    SA 5G Attach    1
#    SA 5G PDU Session Setup    1
#    CB007949_resource.SA Start UL Traffic    20    3600
#    CB007949_resource.SA Start DL TrafficWithPort    400    3600    7070
#    sleep    10s    reason=Wait for traffic stable
#    Capture TTItrace
#    Verfiy Scells Are Activation After Deactive     3    1
#    New Get And Check Cells TP For DL after Scell Addition    dl    3    40    40
#    #Verify maxPayloadSize    16
#    Start small dl traffic and check deactivation for A03
#    Start big dl traffic and chek activate again for A03
#    Kill All Iperf Process
#    Log To Console    \nstart convert ttitrace to csv...\n
#    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
#    Check Rate    dlFdSchedData.ackNack    ["ACK", "NACK","DTX"]    ["NACK","DTX"]
#    Check Rate    dlFdSchedData.speculativeDtxAckDtx    ["ACK", "NACK","DTX"]    ["NACK","DTX"]
#    Check Rate    dlHarqRxDataArray.dtx    ["NON_DTX","DTX"]    ["DTX"]
#
#CB007949-ET-A05 TDD 2CCs with different frame structure as Pcell 5GC001116 shift 0ms
#    [Tags]     Owner_yalsun    case_A05
#    [Setup]    Setup TL For Each Case    ${SCF_1116_0_1070_A05}    ${IPHY_1208_1116_1070_B03}
#    ...    ${WTS_CFG_1116_0_1070_A05}    ${WTS_XML}
#    SA 5G Attach    1
#    SA 5G PDU Session Setup    1
#    sleep    10s    reason=Wait for Scell Addition ...
#    Verify maxPayloadSize    12
#    CB007949_resource.SA Start UL Traffic    200    3600
#    CB007949_resource.SA Start DL TrafficWithPort    1500    3600    7070
#    Sleep    60s    reason=Wait for traffic stable
#    Capture TTItrace
#    Sleep    5s
#    Get And Check Cells TP For DL after Scell Addition    dl    2
#    Kill All Iperf Process
#    Log To Console    \nstart convert ttitrace to csv...\n
#    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
#    Check DTXNACK Rate
#
#CB007949-ET-A07 TDD 2CCs with Pcell 5GC001208 and scell 5GC001116 shift 0ms frame structure
#    [Tags]     Owner_qianwu    case_A07
#    [Setup]    Setup TL For Each Case    ${SCF_1208_1116_0_A07}    ${IPHY_1070_1208_A10}
#    ...    ${WTS_CFG__1070_1208_A10}    ${WTS_XML}
#    SA 5G Attach    1
#    SA 5G PDU Session Setup    1
#    sleep    10s    reason=Wait for Scell Addition ...
#    Verify maxPayloadSize    12
#    CB007949_resource.SA Start UL Traffic    800    3600
#    CB007949_resource.SA Start DL TrafficWithPort    800    3600    7070
#    Sleep    60s    reason=Wait for traffic stable
#    Capture TTItrace
#    Sleep    5s
#    Verfiy Scells Are Activation    2    1
#    Get And Check Cells TP For DL after Scell Addition    dl    2
#    Kill All Iperf Process
#    Log To Console    \nstart convert ttitrace to csv...\n
#    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
#    Check DTXNACK Rate
#
#CB007949-ET-A010 TDD 2CCs with Pcell 5GC001070 and scell 5GC001208 frame structure
#    [Tags]     Owner_lading    case_A10
#    [Setup]    Setup TL For Each Case    ${SCF_1070_1208_A10}    ${IPHY_1070_1208_A10}
#    ...        ${WTS_CFG__1070_1208_A10}    ${WTS_XML}
#    Start Gnb Wireshark Log    duration=10s
#    Attach SA CA UE and Get Throughput for A10    1    1000    300    300    60
#    Sleep    10s
#    ${gnb_wireshark}=    Collect Gnb Wireshark Log    log_dir=${SUITE_LOG_DIRECTORY}
#    Sleep    10s
#    Verify SCell Configured For UE    ${gnb_wireshark}
#    Verify maxPayloadSize Configured For UE    ${gnb_wireshark}
#    Log To Console    \nstart convert ttitrace to csv...\n
#    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
#    Check Rate    dlFdSchedData.ackNack    ["ACK", "NACK","DTX"]    ["NACK","DTX"]
#    Check Rate    dlFdSchedData.speculativeDtxAckDtx    ["ACK", "NACK","DTX"]    ["NACK","DTX"]
#    Check Rate    dlHarqRxDataArray.dtx    ["NON_DTX","DTX"]    ["DTX"]
#
#CB007949-ET-A019 TDD 3CC CA using 5GC001208 frame structure Pcell with interference
#    [Tags]     Owner_yalsun    case_A19
#    [Setup]    Setup TL For Each Case    ${SCF_1208_1208_1208_A19}    ${IPHY_1208_1208_1208_A03}    ${WTS_CFG_1208_1208_1208_A03}    ${WTS_XML}
#    SA 5G Attach    1
#    SA Set Traffic Type To Internal    1    1
#    SA 5G PDU Session Setup    1
#    Start SA UE Big DL Traffic Internal    1    mbps=650
#    Start SA UE Big UL Traffic Internal    1    mbps=200
#    Sleep    5s    reason=Wait for traffic stable
#    Get And Check Cells TP For DL after Scell Addition    dl    3
#    SA UE Check Throughput    1    100    10
#    Capture TTItrace
#    Verfiy Scells Are Activation     3    1
#    Kill All Iperf Process
#    Log To Console    \nstart convert ttitrace to csv...\n
#    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
#    Check DTXNACK Rate
#    Check mute cells    A19
#
#CB007949-ET-B03 Different frame structure TDD 3CCs CA conigured Pcell 1208 and scell with 1116 and 1070
#    [Tags]     Owner_haiyliu    case_B03    CRT
#    [Setup]    Setup TL For Each Case    ${SCF_1208_1116_1070_B03}    ${IPHY_1208_1116_1070_B03}    ${WTS_CFG_1208_1116_1070_B03}    ${WTS_XML}
#    SA 5G Attach    1
#    SA 5G PDU Session Setup    1
#    Scell Addition Triggered By A1 Event    1    1    110
#    Sleep    10s    reason=Wait for scelladd
#    Verify TDD Scells Addition
#    CB007949_resource.SA Start UL Traffic    10    3600
#    CB007949_resource.SA Start DL TrafficWithPort   1    3600    7070
#    sleep    3s    reason=Wait for traffic stable
#    CB007949_resource.SA Start DL TrafficWithPort   1000    3600    7072
#    Sleep    3s    reason=Wait for traffic stable
#    Capture TTItrace
#    sleep    10s    reason=Wait for log
#    Verfiy Scells Are Activation    3    1
#    Get And Check Cells TP For DL after Scell Addition    dl    3
#    SA Check Average Traffic Bigger Than Target    ul    5
#    Kill All Iperf Process
#    Log To Console    \nstart convert ttitrace to csv...\n
#    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
#    Check DTXNACK Rate
#
#CB007949-ET-D04 A-CSI will trigger after Scell release
#    [Tags]     Owner_dguan   case_D04
#    [Setup]    Setup TL For Each Case    ${SCF_1116_1116_1116_D04}    ${IPHY_1116_1116_1116_D04}    ${WTS_CFG_1070_1208_1116_D04}    ${WTS_XML}
#    [Timeout]    90min
#    SA 5G Attach    1
#    SA Set Traffic Type To Internal    ue_id=1    pdu_id=1
#    SA 5G PDU Session Setup    1
#    Log To Console    \nAdd 2 scells,1T+2T...\n
#    Scell Addition Triggered By A1 Event    1    2    101
#    Verify TDD Scells Addition    50    51
#    Verfiy CSIRS Number    13
#    Start SA UE Big DL Traffic Internal    1    600
#    Sleep    10s    reason=Wait for traffic stable
#    Verfiy Scells Are Activation    3    1
#    Get And Check Cells TP For DL after Scell Addition    dl    3
#    Capture And Decode TTItrace    file_name=output_dl_aftercelladdition
#    Check DTXNACK Rate
#    Check NO ACSI from TTI
#    Log To Console    \nRelease 1 scell...\n
#    Trigger A2 Release    UE_ID=1    meas_id=3    SCellIndex=1
#    Check A2 Release
#    Capture And Decode TTItrace    file_name=output_dl_afterscellrelease
#    Check DTXNACK Rate
#    Log To Console    \nStop DL Data,Check ACSI...\n
#    SA Stop DL Data Traffic Internal    1    1
#    Start SA UE Big UL Traffic Internal    1    100
#    Sleep    5s    reason=Wait for traffic stable
#    Capture And Decode TTItrace    file_name=output_dl_afterstopdl
#    Check ACSI from TTI
#    Kill All Iperf Process
#
#CB007949-ET-D06 TDD3CC CA with CSI-RS in PCell is 2 and scell is 1
#    [Tags]     Owner_qianwu    case_D06
#    [Setup]    Setup TL For Each Case    ${SCF_1070_1208_1116_0_D06}    ${IPHY_1208_1116_1070_B03}    ${WTS_CFG_1070_1208_1116_0_D06}    ${WTS_XML}
#    [Timeout]    90min
#    SA 5G Attach    1
#    SA 5G PDU Session Setup    1
#    sleep    10s    reason=Wait for Scell Addition ...
#    Verify TDD 2Scells Addition    52    53
#    CB007949_resource.SA Start UL Traffic    200    3600
#    CB007949_resource.SA Start DL TrafficWithPort    1000    3600    7070
#    Sleep    10s    reason=Wait for traffic stable
#    Capture TTItrace
#    Sleep    5s
#    Verfiy Scells Are Activation    3    1
#    Get And Check Cells TP For DL after Scell Addition    dl    3
#    Check ACSI Not Configed
#    Kill All Iperf Process
#    Log To Console    \nstart convert ttitrace to csv...\n
#    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
#    Check DTXNACK Rate
#    Verfiy CSIRS Number    13
#
#CB007949-ET-E01 TDD 3CC CA with pCSI bundling enable
#    [Tags]     Owner_qianwu    case_E01
#    [Setup]    Setup TL For Each Case    ${SCF_1208_1070_1116_0_E01}    ${IPHY_1208_1116_1070_B03}    ${WTS_CFG_1208_1116_1070_B03}    ${WTS_XML}
#    UE Beamforming Profile And Association
#    SA 5G Attach    1
#    SA 5G PDU Session Setup    1
#    Log To Console    \nAdd 2 scells...\n
#    Scell Addition Triggered By A1 Event    1    1    101
#    Verify TDD Scells Addition
#    CB007949_resource.SA Start UL Traffic    20    3600
#    CB007949_resource.SA Start DL TrafficWithPort    1000    3600    7070
#    Sleep    10s    reason=Wait for traffic stable
#    Verfiy Scells Are Activation    3    1
#    Get And Check Cells TP For DL after Scell Addition    dl    3
#    Capture And Decode TTItrace    file_name=output_dl_aftercelladdition
#    Check DTXNACK Rate
#    Check DL Rank
#    Check PatternID From Wirshark    1
#    UE Beamforming Switch    2    0
#    Check PatternID From Wirshark    2
#    Log To Console    \nRelease 1 scell...\n
#    Trigger A2 Release    UE_ID=1    meas_id=2    SCellIndex=1
#    Check A2 Release
#    UE Beamforming Switch    1    0
#    Check PatternID From Wirshark    1
#
#CB007949-ET-F03 3T CA interwroking with handover
#    [Tags]     Owner_haiyliu    case_F03
#    [Setup]    Setup TL For CaseF03    ${SCF_1116_0_1208_1208_F03}    ${IPHY_1116_0_1208_1208_F03}    ${WTS_CFG_1116_0_1208_1208_F03}    ${WTS_XML}
#    Configure UE History Info For HO    2    52    3    49
#    Attach SA UE   UE_ID=1
#    Verify TDD Scells Addition
#    SA Start UL Traffic Internal    ue_id=1    pdu_id=1     mbps=175
#    Start SA UE More small DL Traffic Internal    ue_id=1    mbps=550   mbpsPtrf=120
#    #Verfiy Scells Are Activation For F03    3    1
#    SA Stop Traffic Internal To Trigger Scell Deactivated     ue_id=1    mbps=300
#    #Verfiy Any Scell Is Deactivation
#    Trigger A2 Event And Check MeasGap Setup    meas_id=1
#    Trigger A1 Event And Check MeasGap Release      meas_id=2
#    Check DL Slot On Pcell And DTXNACK Rate    dl    1
#    Start SA UE More small DL Traffic Internal    ue_id=1    mbps=750   mbpsPtrf=120
#    #Verfiy Scells Are Activation After Deactive    3    2
#    Trigger A2 Event And Check MeasGap Setup    meas_id=4
#    Trigger A1 Event And Check MeasGap Release      meas_id=5
#    Check DL Slot On Pcell And DTXNACK Rate    dl    3
#    Trigger A2 Event And Check MeasGap Setup    meas_id=7
#    Inter-frequency HO To Sim GNB       meas_id=9
#    Inter-frequency HO To Real GNB      meas_id=2
#    Check DL Slot On Pcell And DTXNACK Rate    dl    3
#
#*** Keywords ***
