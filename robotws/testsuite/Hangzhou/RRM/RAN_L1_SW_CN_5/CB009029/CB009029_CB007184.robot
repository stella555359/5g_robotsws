*** Settings ***
Documentation
...    Author:  Yanqing.li
...    Contact: yanqing.li@nokia-sbell.com
...    Feature: CB009029
...    Release: 23R4
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    10    # No connection to unit
...               4003    # Transmission path failure
...               4589    # Unit power reset
...               1815    # Not able to synchronize baseband bus
${FPFH_IP_ADDRESS}    10.108.241.4
${user}        admin
${password}    Nokia123!

*** Test Cases ***
CB009029_CB007184_TC01_LTE_FDD_CPRI_ABIP_FH_link_failure
    [Tags]    ABIP    SMAwave    Trunk    CB009029    CB009029_US01
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009029${/}CB009029_US01_ABIP_2AHFII_LTEFDD_CPRI_1xLNCEL.xml    5min
    SMAwave attach and data traffic   2796039    60M    50M    10%    4G    66    UE_2
    FPFH Power Operation    1    OFF
    Wait Until Keyword Succeeds    300s    10s    Check If Alarm Appeared    4003
    SMAwave attach and data traffic   2796039    60M    50M    10%    4G    66    UE_2
    FPFH Power Operation    1    ON
    Wait Until Keyword Succeeds    360s    30s    Check If Alarm Disappeared    4003
    SMAwave Stop Data And Detach
    [Teardown]    Run Keywords    FPFH Power Operation    1    ON    AND    common_resource_suite.Common Test Teardown

CB009029_CB007184_TC03_NR_FR1_FDD_CPRI_ABIP_FH_link_failure
    [Tags]    ABIP    SMAwave    Trunk    CB009029    CB009029_US03
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009029${/}CB009029_US03_ABIP_2AHFII_NRFDD_CPRI_1xNRCEL.xml    5min
    SMAwave attach and data traffic   47886338    880M    70M    10%    5G    25    UE_4
    FPFH Power Operation    1    OFF
    Wait Until Keyword Succeeds    300s    10s    Check If Alarm Appeared    4003
    SMAwave Verify throughput for DL and UL    460M    50M    10%    5G
    FPFH Power Operation    1    ON
    Wait Until Keyword Succeeds    360s    30s    Check If Alarm Disappeared    4003
    SMAwave Stop Data And Detach
    [Teardown]    Run Keywords    FPFH Power Operation    1    ON    AND    common_resource_suite.Common Test Teardown


*** Keywords ***
SMAwave attach and data traffic
    [Arguments]    ${cell_id}    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}    ${band}=41    ${specific_UE_index}=${EMPTY}
    ...    ${duration}=600    ${protocol}=udp
    SMAwave UE attach    ${rat}    ${cell_id}    ${band}    ${specific_UE_index}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}
    SMAwave Verify throughput for DL and UL    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}
