*** Settings ***
Documentation
...    Author:  Yanqing.li
...    Contact: yanqing.li@nokia-sbell.com
...    Feature: CB007184
...    Release: 23R2
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}

*** Test Cases ***
CB007184_SR_B_US01_NR_TDD_eCPRI_eAxC_link_failure_4Tx4Rx_cell_degraded_trunk
    [Tags]    ASOE    SMAwave    Trunk    CB007184    QC_435665
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB007184${/}CB007184_B_ASOE_AZHL_NRTDD_1xNRCEL.xml
    Adjust HBTE attenuation values    10.108.241.30
    ...    1:20; 2:20; 5:20; 6:20; 9:127; 10:127; 13:127; 14:127; 3:127; 4:127; 7:127; 8:127; 11:127; 12:127; 15:127; 16:127
    SMAwave L3 call    11    1000M    60M    10%    5G    41
    change_cell_operationalState_via_rmod    172.22.0.158     AZHL    degraded
    common_resource_radio.Admin Reset RMOD    1
    Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
    SMAwave L3 call    11    1000M    60M    10%    5G    41
    Wait Until Keyword Succeeds    900s    30s    Check If Alarm Appeared    4003
    change_cell_operationalState_via_rmod    172.22.0.158     AZHL    enabled
    common_resource_radio.Admin Reset RMOD    1
    Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
    [Teardown]	Wait Until Keyword Succeeds    700s    20s    change_cell_operationalState_via_rmod    172.22.0.158     AZHL    enabled

CB007184_SR_A_US04_LTE_TDD_eCPRI_eAxC_link_failure_4Tx4Rx_TM4_cell_degraded_trunk
    [Tags]    ASOE    SMAwave    Trunk    CB007184    QC_435664
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB007184${/}CB007184_A_ASOE_AZHL_LTETDD_1xLNCEL.xml
    Adjust HBTE attenuation values    10.108.241.30
    ...    1:20; 2:20; 5:20; 6:20; 9:127; 10:127; 13:127; 14:127; 3:127; 4:127; 7:127; 8:127; 11:127; 12:127; 15:127; 16:127
    SMAwave L3 call    11    100M    9M    15%    4G    41
    change_cell_operationalState_via_rmod    172.22.0.2     AZHL    degraded
    common_resource_radio.Admin Reset RMOD    1
    Wait Until Keyword Succeeds     300s    20s    Check If All Cells Are OnAir
    Wait Until Keyword Succeeds    900s    10s    Check If Alarm Appeared    4003
    change_cell_operationalState_via_rmod    172.22.0.2     AZHL    enabled
    common_resource_radio.Admin Reset RMOD    1
    Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
    [Teardown]	Wait Until Keyword Succeeds    700s    20s    change_cell_operationalState_via_rmod    172.22.0.2     AZHL    enabled

CB007184_SR_B_US01_NR_TDD_eCPRI_eAxC_link_failure_4Tx4Rx_cell_degraded_branch
    [Tags]    ASOE    SMAwave    Branch    CB007184    QC_538348
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB007184${/}CB007184_B_ASOE_AZHL_NRTDD_1xNRCEL.xml
    Adjust HBTE attenuation values    10.108.241.30
    ...    1:20; 2:20; 5:20; 6:20; 9:127; 10:127; 13:127; 14:127; 3:127; 4:127; 7:127; 8:127; 11:127; 12:127; 15:127; 16:127
    SMAwave L3 call    11    1000M    60M    10%    5G    41
    change_cell_operationalState_via_rmod    172.22.0.158     AZHL    degraded
    common_resource_radio.Admin Reset RMOD    1
    Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
    SMAwave L3 call    11    1000M    60M    10%    5G    41
    Wait Until Keyword Succeeds    900s    30s    Check If Alarm Appeared    4003
    change_cell_operationalState_via_rmod    172.22.0.158     AZHL    enabled
    common_resource_radio.Admin Reset RMOD    1
    Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
    [Teardown]	Wait Until Keyword Succeeds    700s    20s    change_cell_operationalState_via_rmod    172.22.0.158     AZHL    enabled

CB007184_SR_A_US04_LTE_TDD_eCPRI_eAxC_link_failure_4Tx4Rx_TM4_cell_degraded_branch
    [Tags]    ASOE    SMAwave    Branch    CB007184    QC_538349
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB007184${/}CB007184_A_ASOE_AZHL_LTETDD_1xLNCEL.xml
    Adjust HBTE attenuation values    10.108.241.30
    ...    1:20; 2:20; 5:20; 6:20; 9:127; 10:127; 13:127; 14:127; 3:127; 4:127; 7:127; 8:127; 11:127; 12:127; 15:127; 16:127
    SMAwave L3 call    11    100M    9M    15%    4G    41
    change_cell_operationalState_via_rmod    172.22.0.2     AZHL    degraded
    common_resource_radio.Admin Reset RMOD    1
    Wait Until Keyword Succeeds     300s    20s    Check If All Cells Are OnAir
    Wait Until Keyword Succeeds    900s    10s    Check If Alarm Appeared    4003
    change_cell_operationalState_via_rmod    172.22.0.2     AZHL    enabled
    common_resource_radio.Admin Reset RMOD    1
    Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
    [Teardown]	Wait Until Keyword Succeeds    700s    20s    change_cell_operationalState_via_rmod    172.22.0.2     AZHL    enabled

*** Keywords ***
SMAwave supercell L3 call
    [Arguments]    ${cell_id}    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}    ${band}=41    ${specific_UE_index}=${EMPTY}
    ...    ${duration}=600    ${protocol}=udp
    SMAwave UE attach    ${rat}    ${cell_id}    ${band}    ${specific_UE_index}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}
    SMAwave Verify throughput for DL and UL    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}
