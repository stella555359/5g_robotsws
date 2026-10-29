*** Settings ***
Documentation
...   Keywords for CB013034 and UUF
...   author: Przemyslaw Herian
...   contact: przemyslaw.herian@nokia.com


Resource        taf/rfrl/ue/robot/REAL_UE.robot

*** Variables ***
${duration}             120s
${tput_dl}              300 Mbits/sec
${tput_ul}              160 Mbits/sec

*** Keywords ***
Perform L3 Call on single UE
    [Arguments]    ${95_percent_tput_required}=True
    ${status}=    Run Keyword And Return Status     L3 call DL UL    95_percent_tput_required=${95_percent_tput_required}
    ue.Detach Ue    UE
    Run Keyword If    '${status}'=='False'    L3 call DL UL    95_percent_tput_required=${95_percent_tput_required}
    ...    ELSE    Log To Console    \n...TPUT Passed...\n

L3 call DL UL
    [Arguments]    ${95_percent_tput_required}=False
    Log To Console      \n--Attach UE--\n
    Wait Until Keyword Succeeds    60s    30s    ue.Require Ue    UE      capabilities=REAL_ANDROID_UE
    Wait until keyword succeeds      60 sec    120 sec    ue.Attach Ue      UE
    Log To Console    \n--Starting TPUT test--\n
    IF    ${95_percent_tput_required}
        Start Data Transfer DL&UL and Verify Troughput    ${duration}     ${tput_dl}    ${tput_ul}    deviation_dl=5%    deviation_ul=5%
    ELSE
        Start Data Transfer DL&UL and Verify Troughput    ${duration}     ${tput_dl}    ${tput_ul}    deviation_dl=80%    deviation_ul=80%
    END
    Log To Console      \n--Checking if X2 alarms are visible--\n
    log to console    \n--Detaching UE after tput--\n
    ue.Detach Ue    UE
