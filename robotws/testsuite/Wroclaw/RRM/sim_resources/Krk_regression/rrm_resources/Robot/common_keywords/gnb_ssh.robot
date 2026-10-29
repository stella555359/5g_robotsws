*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library    ute_fsmaccess

*** Variables ***

*** Keywords ***
Get gNB SW release
    ute_fsmaccess.Setup Enb Fsm Access   alias=test5G
    ${SW_VERSION}    ute_fsmaccess.Get Enb Sw Version   alias=test5G
    ute_fsmaccess.Teardown Enb Fsm Access  alias=test5G
    @{SW_VERSION}    Split To List    ${SW_VERSION}    separator=_
    ${SW_RELEASE}    Set Variable    ${SW_VERSION[0]}
    [Return]  ${SW_RELEASE}



Teardown emss if setup failed
    Teardown emss   bts_id=1


Setup emss in loop
    Wait until keyword succeeds         3x    10s
    ...         Run keywords
    ...         Log to console      Setup emssim attempt
    ...         AND     Teardown emss   bts_id=1
    ...         AND     Setup emss      bts_id=1      timeout=60     bts_timeout=65
    ...         AND     Log to console      Setup emssim success


Reliable emss setup
    [Arguments]     ${bts_id}=1
    Run And Teardown On Failed
    ...         Teardown emss if setup failed
    ...         Setup emss in loop
