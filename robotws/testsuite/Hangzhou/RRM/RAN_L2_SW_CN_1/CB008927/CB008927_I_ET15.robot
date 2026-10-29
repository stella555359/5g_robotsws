*** Settings ***
Documentation    ...
Suite Teardown    Common Suite Teardown 2
Test Teardown     Common Test Teardown 2
Force Tags        CLOUD_5G_I_LO_AP_LO
...               SBTS00    SBTS24R3    Pz4_12    CB008927   RAN_5G    RAN_5G_TDD    #CRT
Resource          ./Resources/CB008927_resource.robot

*** Variables ***
${SCF_PATH}          ${CURDIR}/Config
${FULL_SCF_15}       CB008927_15_ST_scfc.xml
${WTS_LOCAL}         ${CURDIR}/Config
${IPHY_FILE_15}      ${WTS_LOCAL}/iphy_2T_2F_CA04.xml
${WTS_CFG_15}        CB008927_15_ST_AP.cfg
${RD}                0x580839=1;0x580345=1;0x58090b=1;0x580954=1
${ttiPath1}          ttitrace1
${ttiPath2}          ttitrace2
${ttiPath3}          ttitrace3
${bip_csv}           bip_gnb.csv
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB008927_15_TDD_with_CSI-RS_refine_beam_NSA
    [Setup]    Prepare TL w gNB_xml '${FULL_SCF_15}' AP_xml '${IPHY_FILE_15}' AP_cfg'${WTS_CFG_15}'
#    [Setup]    Run Keywords    Start UTE WTS with cfg file '${WTS_CFG_15}'    AND    Common Test Setup
#    Peak : 1.1G, 1070 tdd framStructure, dl 256QAM
    Set egate rrc log 'on'
    Setup X2 Connection    1    2
    ${bip}    Capture BIP for'1s' to logDir'BIP_GNB'and convert to csv'${bip_csv}' with filter'${filter}' and'${column_name}'
    UE '101'-'101' Attach to LTE Cell
    UE '101'-'101' Attach to NR Cell '1'
    Get Egate log and check 'RESOURCEALLOCATIONTYPE1'
    Start dl Trafficon on UE '101'-'101' BearerID '2'with '1200'mbps
    Start ul Trafficon on UE '101'-'101' BearerID '2'with '170'mbps
    Run Keyword And Continue On Failure    Wait 'dl' TPut get Target of '1000'mbps on UE '101' of Bearer ID '2'
    Capture Ttitrace for duration '1s' to log dir '${ttiPath1}'
    Verify ttitrace bler should not high than '0.01' in path '${ttiPath1}'
    UE '102'-'102' Attach to LTE Cell
    UE '102'-'102' Attach to NR Cell '1'
    Start dl Trafficon on UE '102'-'102' BearerID '2'with '100'mbps
    Start ul Trafficon on UE '102'-'102' BearerID '2'with '10'mbps
    Run Keyword And Continue On Failure    Wait 'dl' TPut get Target of '50'mbps on UE '102' of Bearer ID '2'
    ${tti}    Capture Ttitrace for duration '1s' to log dir '${ttiPath2}'
    Verify ttitrace bler should not high than '0.01' in path '${ttiPath2}'
    UE '103'-'103' Attach to LTE Cell
    UE '103'-'103' Attach to NR Cell '1'
    Execute ping to UE '4.7.254.103'
    ${Tp_UE101}    Get NSA UE '101' 'dl' TPut on Bearer ID '2'
    ${Tp_UE102}    Get NSA UE '102' 'dl' TPut on Bearer ID '2'
    Capture Ttitrace for duration '1s' to log dir '${ttiPath3}'
    Verify ttitrace bler should not high than '0.01' in path '${ttiPath3}'
    Verify PRB schedule as expected in log bip '${bip}' and ttitrace '${tti}'

*** Keywords ***
Verify PRB schedule as expected in log bip '${bip}' and ttitrace '${tti}'
    ${Data}    Generate Data From Bip'${bip}' TTitrace'${tti}' FrameType'1070' physCellId'50' when ignoreNotFullBufferSlot'Y'
    Check PrbNum'==253' Should not Lower Percentage'0.4' on SlotType'D' in Data'${Data}'
    Check PrbNum'==253' Should not Lower Percentage'0.8' on SlotType'S' in Data'${Data}'

