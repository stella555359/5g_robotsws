*** Settings ***

Documentation
...   Author:   Lauri Lehtoaho
...   Contact:  lauri.lehtoaho@nokia.com

*** Keywords ***
Data transfer
    [Arguments]    ${SYSLOG_LIST}

    Start Syslog Print Search To Background     ${SYSLOG_LIST}
    Run Keyword And Continue On Failure   Prepare UEs
    Print Step Text                    1  Sleeping cell check
    Run Keyword And Continue On Failure   Make Data Transfer Test
