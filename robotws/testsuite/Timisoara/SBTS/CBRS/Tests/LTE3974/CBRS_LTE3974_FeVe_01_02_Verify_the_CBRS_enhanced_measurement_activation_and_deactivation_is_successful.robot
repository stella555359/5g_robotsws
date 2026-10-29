*** Settings ***
Documentation
...    = Author =
...    michal.moskala@nokia.com
...    = Maintainer =
...    michal.moskala@nokia.com
...    = Reviewer =
...    bartosz.rutkowski@nokia.com
...    aleksandra.dagiel@nokia.com
...    karol.palamarz@nokia.com
...    artur.czainski@nokia.com
...    lukasz.lechowicz@nokia.com
...    = Summary =
...    The purpose of this test case is to check whether the feature could be activated and deactivated successfully
...    by change feature flag LNBTS-actCbrsEnhMeas from 'false' to 'true' and from 'true' to 'false'.

*** Keywords ***
CBRS_LTE3974_FeVe_01_02_Verify_the_CBRS_enhanced_measurement_activation_and_deactivation_is_successful
    [Documentation]    Requirement: LTE3974_#01
    [Timeout]    30min

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}    Set Variable    RAT_1ST
    Kill All SAS Processes
    Wait Until BTS Is Not Busy
    taf.sbts.oam.coam.admin.Reset    alias=RAT_1ST
    Sleep    420s
    Wait Until BTS Is Not Busy
    Disable CBRS Feature On eNB
    Check If Cells Are Disabled    enb_id=${enb_id}
    Start SAS Process    alias=default    port=4433    config=${CURDIR}/Data/SAS_Sim.conf
    Wait Until BTS Is Not Busy
    Enable CBRS Feature On eNB
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection

    ${feature_is_enabled}   Run Keyword And Return Status    Check If CBRS Enhanced Measurement Feature Is Enabled
    IF  ${feature_is_enabled}==${FALSE}  Enable CBRS Enhanced Measurement Feature  enb_id=${enb_id}

    Disable CBRS Enhanced Measurement Feature    enb_id=${enb_id}
    Check If CBRS Enhanced Measurement Feature Is Disabled
    Enable CBRS Enhanced Measurement Feature    enb_id=${enb_id}
    Check If CBRS Enhanced Measurement Feature Is Enabled

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Kill All SAS Processes
