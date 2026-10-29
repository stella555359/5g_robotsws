*** Settings ***
Documentation
...              test automation author: Konrad Krymowski
...              contact: konrad.krymowski@nokia.com

...              Suite created for the needs of EDA, according to the bug described in the client PR 02339193

Resource        ../Resources/CB007442-Keywords.robot

*** Keywords ***
Site_Reset_During_Baseband_Card_Reset
    [Documentation]    This test is here because of its nature.
    ...                It is used in CRT_nonfunctional_[SMOD]_BTS_reset_loop.robot suites,
    ...                because 1HB works on TL380, which does not have BBMOD.
    Set Test Variable    ${ALLOWED_FAULTS_TEMP}    ${ALLOWED_FAULTS_COMMON}
    Setup Syslog Collector
    Connect to ADMIN                       alias=historical_alarms
    Log    \nStep 1 ---> Check if BTS status is Configured or OnAir...    console=True
    Wait Until Keyword Succeeds  20x  30s  Check If BTS Status Is Configured Or OnAir
    Log    \nStep 2 ---> Reset all BBMOD(s)...    console=True
    @{BBMOD_LIST}=    Get Infomodel Path To Object    BBMOD
    ${BBMOD_nr}=    Set Variable    1
    FOR    ${BBMOD}    IN    @{BBMOD_LIST}
         Log    ----------------------- RESET BBMOD ${BBMOD_nr} -----------------------    console=True
         Log  Reseted BBMOD: ${BBMOD}    console=True
         Reset BBMOD In Background Process    ${BBMOD}    ${BBMOD_nr}
         ${BBMOD_nr}=    Evaluate    ${BBMOD_nr} + 1
    END
    Log    \nStep 3 ---> Wait random time before Reset Site...    console=True
    ${random_num}=    Evaluate    random.randint(10, 75)    random
    Log    \nTime since last BBMOD Reset to Site Reset: ${random_num} [sec]    console=True
    Sleep    ${random_num}    reason=Random time wait after BBMOD Reset and before Site Reset
    Log    \nStep 4 ---> Reset site...    console=True
    Reset Site And Reconnect
    Log    \nStep 5 ---> Check if BTS status is Configured or OnAir...    console=True
    Wait Until Keyword Succeeds  20x  30s  Check If BTS Status Is Configured Or OnAir
    Stop And Collect Syslog      ${OUTPUT DIR}/${TEST_NAME}
    Check Syslog                 ${OUTPUT DIR}/${TEST_NAME}
    [Teardown]    Run Keywords             Check Historical Alarms    AND
    ...           Disconnect from ADMIN    connection=historical_alarms
