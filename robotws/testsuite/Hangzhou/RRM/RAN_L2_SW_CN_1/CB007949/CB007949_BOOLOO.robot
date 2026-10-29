*** Settings ***
Documentation    ...
#Resource    ./CB007949_resource.robot
#Resource    ../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Common Suite Setup
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    CN1_SQ
#...               RAN_5G    RAN_5G_TDD
#
#*** Variables ***
#${SCF_DIR}                     ${CURDIR}/config/SCF
#${SCF_1208_1208_1116_B05}        ${SCF_DIR}/SCF_3T3F_1208_1208_1116_B05.xml
#${IPHY_1208_1208_1116_B05}       iphy_3T3F_1208_1208_1116_B05.xml
#${WTS_CFG_1208_1208_1116_B05}    wts_cfg_ASIB_ABIO_3T3F_1208_1208_1116_B05.cfg
#${SCF_1070_1116_0_B08}         ${SCF_DIR}/SCF_2T1F_1070_1116_0_B08.xml
#${IPHY_1070_1116_0_B08}        iphy_2T1F_1070_1116_0_B08.xml
#${WTS_CFG_1070_1116_0_B08}     wts_cfg_ASIB_ABIO_2T1F_1070_1116_0_B08.cfg
#${SCF_1116_0_1070_FDD_FDD_A11}        ${SCF_DIR}/SCF_2T2F_1116_0_1070_FDD_FDD_A11.xml
#${IPHY_1116_0_1070_FDD_FDD_A11}        iphy_2T2F_1116_0_1070_FDD_FDD_A11.xml
#${WTS_CFG_1116_0_1070_FDD_FDD_A11}        wts_cfg_ASIB_ABIO_2T2F_1116_0_1070_FDD_FDD_A11.cfg
#${IPHY_1116_0_1208_FDD_FDD_A21}        iphy_2T2F_1116_0_1208_FDD_FDD_A21.xml
#${WTS_CFG_1116_0_1208_FDD_FDD_A21}        wts_cfg_ASIB_ABIO_2T2F_1116_0_1208_FDD_FDD_A21.cfg
#${SCF_1116_0_1208_FDD_FDD_A21}        ${SCF_DIR}/SCF_2T2F_1116_0_1208_FDD_FDD_A21.xml
#${SCF_1116_0_1070_1208_B04}        ${SCF_DIR}/SCF_1116_1070_1208_B04.xml
#${IPHY_1116_0_1070_1208_B04}       iphy_1116_1070_1208_B04.xml
#${WTS_CFG_1116_0_1070_1208_B04}    wts_cfg_ASIB_ABIO_1116_1070_1208_B04.cfg
#${Egatelog_path}    ${CURDIR}
#
#*** Test Cases ***
#CB007949-ET-A011 2T2F4CC CA with pcell 5GC001116 and scell 5GC001070 frame structure
#    [Tags]     Owner_yalsun    case_A11
#    [Setup]    Setup TL For Each Case    ${SCF_1116_0_1070_FDD_FDD_A11}    ${IPHY_1116_0_1070_FDD_FDD_A11}
#        ...    ${WTS_CFG_1116_0_1070_FDD_FDD_A11}    ${WTS_XML}
#    SA 5G Attach    1
#    SA 5G PDU Session Setup    1
#    sleep    10s    reason=Wait for Scell Addition ...
#    Verify maxPayloadSize    16
#    CB007949_resource.SA Start UL Traffic    300    3600
#    CB007949_resource.SA Start DL TrafficWithPort    2000    3600    7070
#    Sleep    60s    reason=Wait for traffic stable
#    Capture TTItrace
#    Sleep    5s
#    Verfiy Scells Are Activation    4    1
#    Get And Check Cells TP For DL after Scell Addition    dl    4
#    SA Check Average Traffic Bigger Than Target    ul    5
#    Start small dl traffic and check deactivation
#    Start big dl traffic and chek activate again
#    Kill All Iperf Process
#    Log To Console    \nstart convert ttitrace to csv...\n
#    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
#    Check DTXNACK Rate
#
#CB007949-ET-A021 2T2F4CC CA with pcell 5GC001116 and interference
#    [Tags]     Owner_haiyliu    case_A21
#    [Setup]    Setup TL For Each Case    ${SCF_1116_0_1208_FDD_FDD_A21}   ${IPHY_1116_0_1208_FDD_FDD_A21}
#        ...    ${WTS_CFG_1116_0_1208_FDD_FDD_A21}    ${WTS_XML}
#    SA 5G Attach    1
#    SA 5G PDU Session Setup    1
#    CB007949_resource.SA Start UL Traffic    10    3600
#    CB007949_resource.SA Start DL TrafficWithPort    1000    3600    7070
#    sleep    10s    #for traffic stable
#    #Capture TTItrace
#    Verfiy Scells Are Activation     3    1
#    Get And Check Cells TP For DL after Scell Addition    dl    3
#    Kill All Iperf Process
#    #Log To Console    \nstart convert ttitrace to csv...\n
#    #Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
#    #Check DTXNACK Rate
#    #Check mute cells for Pcell    A21
#    #Check mute cells for Scell    A21
#
#CB007949-ET-B05 Different frame structure TDD 3CCs CA conigured Pcell 1208 and scell with 1208 and 1116
#    [Tags]     Owner_dguan    case_B05    CRT
#    [Setup]    Setup TL For Each Case For B04    ${SCF_1208_1208_1116_B05}    ${IPHY_1208_1208_1116_B05}
#        ...    ${WTS_CFG_1208_1208_1116_B05}    ${WTS_XML}
#    SA 5G Attach    1
#    SA Set Traffic Type To Internal    ue_id=1    pdu_id=1
#    SA 5G PDU Session Setup    1
#    Log To Console    \nAdd 2 scells,1T+2T...\n
#    Scell Addition Triggered By A1 Event    1    1    75
#    Verify TDD Scells Addition    53    55
#    SA Start Traffic Internal    ue_id=1    pdu_id=1    mbps=150
#    Verfiy Scells Are Activation    3    1
#    Get And Check Cells TP For DL after Scell Addition    dl    3
#    Capture And Decode TTItrace    file_name=output_dl_afterscelladdition.csv
#    Check DTXNACK Rate
#    Log To Console    \nscellchange to 1T+3F...\n
#    Scell Change Triggered By A1 Event    1    4    85
#    sleep    5s    reason=Wait for Scell Change ...
#    Verify FDD Scells Addition
#    Verfiy FDD Scells Are Activation    4    1
#    Get And Check Cells TP For DL after Scell Change    dl    4    3
#    Capture And Decode TTItrace    file_name=output_dl_afterscellchange.csv
#    Check DTXNACK Rate
#
#CB007949-ET-B08 2T1F 3cc with two TDD 1070 pcell and 1116 scell
#    [Tags]     Owner_qianwu    case_B08    CRT
#    [Setup]    Setup TL For Each Case    ${SCF_1070_1116_0_B08}    ${IPHY_1070_1116_0_B08}    ${WTS_CFG_1070_1116_0_B08}    ${WTS_XML}
#    Start Gnb BIP Log
#    SA 5G Attach    1
#    SA 5G PDU Session Setup    1
#    Scell Addition Triggered By A1 Event    1    1    90
#    CB007949_resource.SA Start UL Traffic    800    3600
#    CB007949_resource.SA Start DL TrafficWithPort    800    3600    7070
#    sleep    6s    #for traffic stable
#    Stop Gnb BIP Log    ${OUTPUT_DIR}/
#    sleep    10s
#    Capture TTItrace
#    Sleep    5s
#    Verfiy Scells Are Activation    3    1
#    Get And Check Cells TP For DL after Scell Addition    dl    3
#    SA Check Average Traffic Bigger Than Target    ul    5
#    Start small dl traffic and check deactivation
#    Kill All Iperf Process
#    Log To Console    \nstart convert ttitrace to csv...\n
#    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/
#    Check DTXNACK Rate
#
#CB007949-ET-B04 Different frame structure TDD 3CCs CA conigured Pcell 1116 and scell with 1070 and 1208
#    [Tags]     Owner_lading    case_B04    CIT    CDRT
#    [Setup]    Setup TL For Each Case For B04    ${SCF_1116_0_1070_1208_B04}    ${IPHY_1116_0_1070_1208_B04}
#    ...    ${WTS_CFG_1116_0_1070_1208_B04}    ${WTS_XML}
#    SA 5G Attach    1
#    SA Set Traffic Type To Internal    ue_id=1    pdu_id=1
#    SA 5G PDU Session Setup    1
#    Scell Addition Triggered By A1 Event    1    1    75
#    Verify TDD Scells Addition    53    55
#    #Verify FDD Scells Addition
#    SA Start Traffic Internal    ue_id=1    pdu_id=1    mbps=80
#    sleep    10s    reason=Wait for traffic stable
#    Verfiy Scells Are Activation    3    1
#    #Check TP for B04 Before Scell change
#    #Capture And Decode TTItrace    file_name=output_dl_afterscelladdition.csv
#    #Check DTXNACK Rate
#    #${measIdA1}    Get MeasID A1    1
#    #Scell Change Triggered By A1 Event    1    ${measIdA1}    85
#    #sleep    10s    reason=Wait for Scell Change ...
#    #Verfiy Scells Are Activation    6    1    4
#    Get And Check Cells TP For DL after Scell Addition    dl    3
#    Capture And Decode TTItrace    file_name=output_dl_afterscellchange.csv
#    Check DTXNACK Rate
#    Kill All Iperf Process
#
#*** Keywords ***
