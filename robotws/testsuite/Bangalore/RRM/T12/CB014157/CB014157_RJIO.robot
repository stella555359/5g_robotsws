*** Settings ***
Force Tags    CLOUD_5G_O_E_AP_LOOO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation       :copyright:   Nokia
...                 :author   :   Kanna Rakesh
...                 :contact  :   kanna.rakesh@nokia.com
...                 :Feature  :   The purpose of the test is to verify RI pilot processing during DL mitigation
...                  by RI detection, mixed RI and RS detection. gNB1 enables RI pilot processing by enabling actRiPilotDlMute
...                  with configured RiPilotPeriod and RiPilotWindow values
...                 :Verification   :   gNb1 unmutes DL transmission and monitors RI in each pilot window
...                 If RI sloping is detected in RI pilot window, gnb1 decides to mute DL in next RIPilotPeriod
...                 If RI sloping is not detected in RiPilotWindow, gnb1 suspends muting in next RIPilotPeriod

Resource          resources/Keywords/CB014157_keywords.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Run Keywords      RAT Block Unblock
                  ...    AND        Common Suite Teardown


*** Variables ***
${TOPOLOGY}             CLOUD_5G_O_E_AP_LOOO
${SA_UE_ID1}            1
${DL_RT}                30
${UL_RT}                30
${TYPE}                 pdsch,pusch
${TIMEOUT}              20 min
${RETRY_TIME}           30s
${SA_UE_ID2}            2
${SA_UE_ID3}            3
${SA_UE_ID4}            4
${SA_UE_ID5}            41
${SA_UE_ID6}            42
${SA_UE_ID7}            43
${SA_UE_ID8}            44
${SA_UE_ID9}            81
${SA_UE_ID10}           82
${SA_UE_ID11}           83
${SA_UE_ID12}           84
${path}         ${AP_CONFIG_BASIC}


*** Test Cases ***
[1][1.0] CB014157_RJIO_CVR_02
    [Tags]    QC_277206   QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]    The purpose of the test is to verify RI pilot processing
    ...      during RIM DL mitigation by RI detection, mixed RI and RS detection.
    [Setup]    Prepare For CB014157 RJIO
    UE Register Should Be Successful For SA     ${SA_UE_ID1}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID1}
    UE Register Should Be Successful For SA     ${SA_UE_ID2}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID2}
    UE Register Should Be Successful For SA     ${SA_UE_ID3}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID3}
    UE Register Should Be Successful For SA     ${SA_UE_ID4}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID4}
    UE Register Should Be Successful For SA     ${SA_UE_ID5}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID5}
    UE Register Should Be Successful For SA     ${SA_UE_ID6}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID6}
    UE Register Should Be Successful For SA     ${SA_UE_ID7}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID7}
    UE Register Should Be Successful For SA     ${SA_UE_ID8}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID8}
    UE Register Should Be Successful For SA     ${SA_UE_ID9}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID9}
    UE Register Should Be Successful For SA     ${SA_UE_ID10}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID10}
    UE Register Should Be Successful For SA     ${SA_UE_ID11}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID11}
    UE Register Should Be Successful For SA     ${SA_UE_ID12}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID12}
    Log To Console      Traffinc UL/DL Started
    Sleep   5s
    Set UE Stats NR Type    ${SA_UE_ID1}    ${TYPE}
    slog.Start Syslog       ${Log_Path}     Pre_sys_log.LOG
    Remotely Interferance In TestMode       Prof_Id=9
    Set NR Cell Testmode	2	1	remote_interference 	9   activate    60s
    Set NR Cell Testmode    2   2   remote_interference     9   activate    60s
    Set NR Cell Testmode    2   3   remote_interference     9   activate    90s
    Get Alarm By Details
    Sim Log Set
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...     Check Fault Exist In Current Alarm      7525      True
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...     Check Fault Exist In Current Alarm      7535      True
    slog.Stop Syslog
    slog.Start Syslog     ${Log_Path}       14157_sys_log.LOG
    Update Feature Flag For CB014157        14157_Feature_Enable.json
    Wait For Next Full Pm Interval
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...     Verifying The PM Counter For CB014157    300     1      >0
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...    Verifying The PM Counter For CB014157     300     2      >0
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...    Verifying The PM Counter For CB014157     300     3      >0
    Wait For Next Full Pm Interval
    Set NR Cell Testmode    2   all   remote_interference     9   deactivate      60s
    Wait For Next Full Pm Interval
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...     Verifying The PM Counter For CB014157    0     1    0
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...    Verifying The PM Counter For CB014157     0     2    0
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...    Verifying The PM Counter For CB014157     0     3    0
    slog.Stop Syslog
    UE Deregister Should Be Successful For SA             ${SA_UE_ID1}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID2}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID3}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID4}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID5}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID6}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID7}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID8}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID9}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID10}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID11}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID12}
    [Teardown]    Run Keyword And Ignore Error            Common Tear Down For CB014157

