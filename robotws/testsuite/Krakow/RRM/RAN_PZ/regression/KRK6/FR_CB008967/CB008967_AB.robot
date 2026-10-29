*** Settings ***
Force Tags    PY36
Documentation
...  author:  Andrzej Pencak, andrzej.pencak@nokia.com
...  maintainer:  Andrzej Pencak, andrzej.pencak@nokia.com

Library     OperatingSystem
Library     ute_fsmaccess
Library     ta5g_pm_counters
Library     ta5g_syslog
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ./resources/suite_specific_keywords.robot

Suite Setup    Suite Setup AB

*** Test Cases ***

CB008967_AB_01_AWKUC_radio_module_internal_temp_available
    [Documentation]    Test verifies RMODs (RF7.1) internal temperature RD counters
    [Setup]  Run keywords
    ...    Common Preconditions    verify_mandatory_scf_params=${False}
    ...    AND   Set measurement reporting interval    value=5min
    ...    AND   Set thermal state monitoring counter interval    parameter=mtSBTSRMODTemperature    value=5min
    Wait for a next full PM interval
    Check RMOD RaD counters    rmod_no=3
    [Teardown]    Run keywords
    ...    Deconfigure thermal state monitoring counter parameter    parameter=mtSBTSRMODTemperature
    ...    AND    Common Postconditions

*** Keywords ***
Suite Setup AB
    [Documentation]    KW for Suite Setup. Performs full comissioning and common steps
    logger.Log Info To Console    ==== SUITE SETUP START ====
    Run Keyword If    '${skip_commissioning}' != 'true'     Perform Commissioning on BTS without ASIR    GNB0_SCF.xml
    Set MRBTS ID
    logger.Log Info To Console    ==== SUITE SETUP END ====


Set measurement reporting interval
    [Arguments]    ${value}
    [Documentation]     This keyword sets PM counter reporting time interval to 15min
    ...     :param value: reportingIntervalPm interval
    Change Parameter On DU
    ...    name=reportingIntervalPm
    ...    value=${value}
    ...    internal_dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1

Set thermal state monitoring counter interval
    [Arguments]    ${parameter}    ${value}
    [Documentation]     This keyword sets CB008967 counter activation parameters to requested time interval
    ...     :param parameter: one of CB008967 Thermal state monitoring counters' parameter
    ...     :param value: interval for counters' reporting
    Change Parameter On DU
    ...    name=${parameter}
    ...    value=${value}
    ...    internal_dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1

Deconfigure thermal state monitoring counter parameter
    [Arguments]    ${parameter}
    [Documentation]     This keyword deconfigures CB008967 counter activation parameters
    ...     :param parameter: one of CB008967 Thermal state monitoring counters' parameter
    Change Parameter On DU
    ...    name=${parameter}
    ...    internal_dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    value=disabled
    ...    operation=update


