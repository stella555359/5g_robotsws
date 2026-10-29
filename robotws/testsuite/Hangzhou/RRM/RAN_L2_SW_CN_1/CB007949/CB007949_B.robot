*** Settings ***
Documentation    ...
#Resource    ./CB007949_resource.robot
#Resource    ../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Common Suite Setup
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    SBTS22R4     CN1_SQ
#...               RAN_5G    RAN_5G_TDD
#
#*** Variables ***
#${SCF_DIR}                     ${CURDIR}/config/SCF
#${SCF_8406_8406_8406_B011}        ${SCF_DIR}/SCF_3T_8406_8406_8406_B011.xml
#${IPHY_8406_8406_8406_B011}       iphy_3T_8406_8406_8406_B011.xml
#${WTS_CFG_8406_8406_8406_B011}    wts_cfg_ASIB_ABIO_3T_8406_8406_8406_B011.cfg
#${SCF_8406_1208_1070_B012}        ${SCF_DIR}/SCF_3T_8406_1208_1070_B012.xml
#${IPHY_8406_1208_1070_B012}       iphy_3T_8406_1208_1070_B012.xml
#${WTS_CFG_8406_1208_1070_B012}    wts_cfg_ASIB_ABIO_3T_8406_1208_1070_B012.cfg
#${SCF_1208_1208_1116_B05}        ${SCF_DIR}/SCF_3T3F_1208_1208_1116_B05.xml
#${IPHY_1208_1208_1116_B05}       iphy_3T3F_1208_1208_1116_B05.xml
#${WTS_CFG_1208_1208_1116_B05}    wts_cfg_ASIB_ABIO_3T3F_1208_1208_1116_B05.cfg
#
#${Egatelog_path}    ${CURDIR}
#
#*** Test Cases ***
#CB007949-ET-B011 TDD 3CCs CA conigured 8406 frame
#    [Tags]     Owner_dguan    case_B011    CRT
#    [Setup]    Setup TL For Each Case    ${SCF_8406_8406_8406_B011}    ${IPHY_8406_8406_8406_B011}    ${WTS_CFG_8406_8406_8406_B011}    ${WTS_XML}
#    SA 5G Attach    1
#    SA 5G PDU Session Setup    1
#    sleep    10s    reason=Wait for Scell Addition ...
#    Verify TDD Scells Addition
#    CB007949_resource.SA Start UL Traffic    10    3600
#    CB007949_resource.SA Start DL TrafficWithPort   1    3600    7070
#    sleep    3s    reason=Wait for traffic stable
#    CB007949_resource.SA Start DL TrafficWithPort   1000    3600    7072
#    Sleep    3s    reason=Wait for traffic stable
#    Verfiy Scells Are Activation    3    1
#    Get And Check Cells TP For DL after Scell Addition    dl    3
#    Capture And Decode TTItrace    file_name=output_dl.csv
#    Kill All Iperf Process
#    Check DTXNACK Rate
#
#CB007949-ET-B012 Different frame structure TDD 3CCs CA conigured Pcell 8406 and scell with 1208 and 1070
#    [Tags]     Owner_dguan    case_B012    CRT
#    [Setup]    Setup TL For Each Case    ${SCF_8406_1208_1070_B012}    ${IPHY_8406_1208_1070_B012}    ${WTS_CFG_8406_1208_1070_B012}    ${WTS_XML}
#    SA 5G Attach    1
#    SA 5G PDU Session Setup    1
#    sleep    10s    reason=Wait for Scell Addition ...
#    Verify TDD Scells Addition
#    CB007949_resource.SA Start UL Traffic    10    3600
#    CB007949_resource.SA Start DL TrafficWithPort   1    3600    7070
#    sleep    3s    reason=Wait for traffic stable
#    CB007949_resource.SA Start DL TrafficWithPort   1000    3600    7072
#    Sleep    3s    reason=Wait for traffic stable
#    Verfiy Scells Are Activation    3    1
#    Get And Check Cells TP For DL after Scell Addition    dl    3
#    Capture And Decode TTItrace    file_name=output_dl.csv
#    Kill All Iperf Process
#    Check DTXNACK Rate
#
#*** Keywords ***
