*** Settings ***
Documentation
...   Testsuite for regression testing of feature CB013351
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Resource          testsuite/Krakow/SISO/regression/RAN_PZ_KRK2/CB013351/CB013351_keywords.robot
Library           testsuite/Krakow/resources/random_oam_procedure_runner.py

Suite Setup       Common suite setup with onAir Test Line preparation
...               prefix_tag=CB013351
Suite Teardown    Common suite teardown

*** Variables ***
${TOTAL_TIMEOUT}                          ${10800}
${EMAIL_NOTIFICATION_WHEN_FAIL}           ${True}
${L3_CALL}                                ${False}

*** Test Cases ***
[1][1.0] CB013351_Config1a_SiSo_Initial_Exploratory_CB013351
    [Setup]    Common preconditions    collect_syslog=${False}
    [Timeout]    96h
    Run random OAM operations
    ...    timeout=${TOTAL_TIMEOUT}
    ...    email_notification=${EMAIL_NOTIFICATION_WHEN_FAIL}
    ...    l3_call=${L3_CALL}
    [Teardown]    Common postconditions    collect_syslog=${False}
