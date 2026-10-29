*** Settings ***
Documentation    ...
#Suite Teardown    Common Suite Teardown    debug
#Test Teardown     Common Test Teardown 2
#Force Tags        CLOUD_5G_I_LO_AP_LO
#...               SBTS00    SBTS24R3    Pz4_12    CB008927   RAN_5G    RAN_5G_TDD    #CRT
#Resource          ./Resources/CB008927_resource.robot
#
#*** Variables ***
#${SCF_PATH}                       ${CURDIR}/Config
#${FULL_SCF}                       CB008927_25_ST_AP.xml
#${WTS_LOCAL}                      ${CURDIR}/Config
#${IPHY_FILE}                      ${WTS_LOCAL}/iphy_2T_2F_CA04.xml
#${WTS_CFG}                        CB008927_25_ST_AP.cfg
#${RD}                             0x580839=1;0x580345=1;0x58090b=1;0x580954=1
#${ttiPath}                        ttitrace
#${bip_csv}                        bip_gnb.csv
#${dlRGData0}                      dlSliceData.dlRGData[0].rrmRGLowInstShare
#${dlRGData1}                      dlSliceData.dlRGData[1].rrmRGLowInstShare
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB008927_25_TDD_RAT1_dynamic_slice-aware_scheduler_TDD_more_PLMN
#    [Setup]    Prepare TL w gNB_xml '${FULL_SCF}' AP_xml '${IPHY_FILE}' AP_cfg'${WTS_CFG}'
##    [Setup]    Run Keywords    Start UTE WTS with cfg file '${WTS_CFG}'    AND    Common Test Setup
##    Peak : 1.1G, 1208 tdd framStructure, dl 64QAM
#    Set egate rrc log 'off'
#    ${bip}    Capture BIP for'1s' to logDir'BIP_GNB'and convert to csv'${bip_csv}' with filter'${filter}' and'${column_name}'
#    UE '1'-'2' Attach to Cell '1' and setup PDU Session '1' with slice '1'
#    UE '3'-'7' Attach to Cell '1' and setup PDU Session '1' with slice '3'
#    UE '8'-'10' Attach to Cell '1' and setup PDU Session '1' with slice '1'
#    Get Egate log and check 'RESOURCEALLOCATIONTYPE1'
#    Start dl Trafficon on UE '1'-'10' PDU ID '1' TRF ID '1' QFI ID '1' with '55'mbps
#    Start ul Trafficon on UE '1'-'10' PDU ID '1' TRF ID '1' QFI ID '1' with '15'mbps
#    Setup 5QI 7 on multiUE '6'-'7' on pdu '2' with nwslice '4'
#    Setup 5QI 7 on multiUE '8'-'10' on pdu '2' with nwslice '2'
#    Start dl Trafficon on UE '6'-'10' PDU ID '2' TRF ID '1' QFI ID '1' with '130'mbps
#    Start ul Trafficon on UE '6'-'10' PDU ID '2' TRF ID '1' QFI ID '1' with '30'mbps
#    Sleep    30s
#    ${Tp_UE1}    Get SA UE'1' 'dl' tput on on PDU '1' QFI '1'
#    ${Tp_UE6}    Get SA UE'6' 'dl' tput on on PDU '2' QFI '1'
#    Run Keyword And Continue On Failure    Wait 'dl' TPut get Target of '40'mbps on UE '1' of PDU ID '1'
#    Run Keyword And Continue On Failure    Wait 'dl' TPut get Target of '100'mbps on UE '6' of PDU ID '2'
#    ${tti}    Capture Ttitrace for duration '1s' to log dir '${ttiPath}'
#    Verify ttitrace bler should not high than '0.01' in path '${ttiPath}'
#    Verify PRB schedule as expected in log bip '${bip}' and ttitrace '${tti}'
##    dlRGData0: 0.46, dlRGData1: 0.54
#    Verify Column '${dlRGData0}' Average Value Should In Range '0.3'-'0.6' in ttiLog '${tti}'
#    Verify Column '${dlRGData1}' Average Value Should In Range '0.4'-'0.7' in ttiLog '${tti}'
#
#*** Keywords ***
#Verify PRB schedule as expected in log bip '${bip}' and ttitrace '${tti}'
#    ${Data}    Generate Data From Bip'${bip}' TTitrace'${tti}' FrameType'1208' physCellId'50' when ignoreNotFullBufferSlot'Y'
#    Check PrbNum'==273' Should not Lower Percentage'0.9' on SlotType'D' in Data'${Data}'
#    Check PrbNum'==273' Should not Lower Percentage'0.9' on SlotType'S' in Data'${Data}'
#    Check PrbNum'==273' Should not Lower Percentage'0.9' on SlotType'SIB/OSI' in Data'${Data}'
#    Check PrbNum'==271' Should not Lower Percentage'0.9' on SlotType'SSB' in Data'${Data}'
#    Check PrbNum'==272' Should not Lower Percentage'0.9' on SlotType'TRS' in Data'${Data}'
