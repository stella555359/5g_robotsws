*** Settings ***
Documentation    ...
Suite Teardown    Common Suite Teardown 2
Test Teardown     Common Test Teardown 2
Force Tags        CLOUD_5G_I_BOO_AP_LOO
...               SBTS00    SBTS25R3    Pz4_13    CB0  RAN_5G    RAN_5G_TDD    #CRT
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./../CB008927/Resources/CB008927_resource.robot
Resource          ./../CB008236/Resources/CB008236_resource.robot
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./../CUDU_L2/common_log_capture.robot
Resource          ./../5GC001808/AirPhone_common_resource_UTE_CR.robot
Resource          ./../5GC001817/keywords_1817_common_AP.robot
Library           ./../CB008236/Resources/CB008236_resource.py

*** Variables ***
${SCF_PATH}             ${CURDIR}/Config
${CB013709_SCF}          SCF_CB013709.xml
${CB013709_IPHY}         ${WTS_LOCAL}/CB013709_iphy.xml
${CB013709_WTS_CFG}      CB009409_amf_basic_mutitraffic.lua
${WTS_LOCAL}            ${CURDIR}/Config
${RD}                0x58057a=4;0x580580=0x800000;0x5808A6=1;0x5800CB=3003003;0x5808e9=10005;0x4B000F=1;0x5800CA=4004004


*** Test Cases ***
CB013709_B_B5_case013_Interworking_with_Proactive_Uplink_Grant for_TCP_Boost_During_Overload_TDD
   [Setup]    Prepare TL w gNB_xml '${CB013709_SCF}' AP_xml '${CB013709_IPHY}' AP_cfg'${CB013709_WTS_CFG}'
    Set egate rrc log 'on'
    UE '1'-'2' Attach to Cell '1' and setup PDU Session '1' with slice '1'
    Start dl Trafficon on UE '1'-'2' PDU ID '1' TRF ID '1' QFI ID '1' with '5'mbps
    check TP counter update
    UE '3'-'11' Attach to Cell '1' and setup PDU Session '1' with slice '1'
    Start ul Trafficon on UE '1'-'11' PDU ID '1' TRF ID '1' QFI ID '1' with '1'mbps
    sleep    300s
    UE '12'-'13' Attach to Cell '1' and setup PDU Session '1' with slice '1'
    Start dl Trafficon on UE '11'-'13' PDU ID '1' TRF ID '1' QFI ID '1' with '5'mbps
    check TP pug counter does not update

*** Keywords ***
check TP counter update
        Log To Console    \nCheck Artificial Load Counter...
    sleep    300s
    Wait Until PM Counter Update    5min
    ${M55308C00039_value}    Get Max PM Counter Value With Admin    M55308C00039
    ${M55308C00038_value}    Get Max PM Counter Value With Admin    M55308C00038
    ${M55208C00026_value}    Get Max PM Counter Value With Admin    M55208C00026
    Should Be True    ${M55308C00039_value} == 2
    Should Be True    ${M55208C00026_value} == 0
    Should Be True    ${M55308C00038_value} > 0

check TP pug counter does not update
        Log To Console    \nCheck Artificial Load Counter...
    sleep    300s
    Wait Until PM Counter Update    5min
    ${M55308C00039_value}    Get Max PM Counter Value With Admin     M55308C00039
    ${M55208C00026_value}    Get Max PM Counter Value With Admin     M55208C00026
    Should Be True    ${M55308C00039_value} >= 2
    Should Be True    ${M55208C00026_value} > 0