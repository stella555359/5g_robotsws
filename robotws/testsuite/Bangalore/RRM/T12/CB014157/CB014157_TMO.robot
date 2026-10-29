*** Settings ***
Force Tags    CLOUD_5G_I_LOO_AP_LOOO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation       :copyright:   Nokia
...                 :author   :   Vikash Kumar
...                 :contact  :   vikash.20.kumar@nokia.com
...                 :Feature  :   The purpose of the test is to verify RI pilot processing during DL mitigation
...                  by RI detection. gNB1 enables RI pilot processing by enabling actRiPilotDlMute
...                  with configured RiPilotPeriod and RiPilotWindow values
...                 :Veriifcation   :   gNb1 unmutes DL transmission and monitors RI in each pilot window
...                 Here cell DL Tput will increase than earlier.
...                 If RI sloping is detected in RI pilot window, gnb1 decides to mute DL in next RIPilotPeriod
...                 If RI sloping is not detected in RiPilotWindow, gnb1 suspends muting in next RIPilotPeriod

Resource          resources/Keywords/CB014157_keywords.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Run Keywords      RAT Block Unblock
                  ...    AND        Common Suite Teardown


*** Variables ***
${SA_UE_ID1}            1
${DL_RT}                30
${UL_RT}                30
${TYPE}                 pdsch,pusch
${TIMEOUT}              20 min
${RETRY_TIME}           30s
${SA_UE_ID2}            2
${SA_UE_ID3}            3
${SA_UE_ID4}            4
${SA_UE_ID5}            5
${SA_UE_ID6}            6
${SA_UE_ID8}            8
${SA_UE_ID10}           10
${SA_UE_ID12}           12
${SA_UE_ID14}           14
${SA_UE_ID16}           16
${SA_UE_ID18}           18
${path}         ${AP_CONFIG_BASIC}


*** Test Cases ***
[1][1.0] CB014157_A_10_Verify_Successful_RI_pilot_processing_with_RI_DL_Mitigation
    [Tags]    QC_273400   QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]    The purpose of the test is to verify RI pilot processing
    ...      during RIM DL mitigation by RI detection
    [Setup]    Prepare For CB014157
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
    UE Register Should Be Successful For SA     ${SA_UE_ID8}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID8}
    UE Register Should Be Successful For SA     ${SA_UE_ID10}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID10}
    UE Register Should Be Successful For SA     ${SA_UE_ID12}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID12}
    UE Register Should Be Successful For SA     ${SA_UE_ID14}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID14}
    UE Register Should Be Successful For SA     ${SA_UE_ID16}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID16}
    UE Register Should Be Successful For SA     ${SA_UE_ID18}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID18}
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
    NR Testmode RIMRS       ProfId=2       aggrCell=1      prop_del=26
    NR Testmode RIMRS       ProfId=3       aggrCell=2      prop_del=26
    NR Testmode RIMRS       ProfId=4       aggrCell=3      prop_del=26
    Set NR Cell Testmode     2    1    rim_rs    2    activate      60s
    Set NR Cell Testmode     2    2    rim_rs    3    activate      60s
    Set NR Cell Testmode     2    3    rim_rs    4    activate      150s
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...     Check Fault Exist In Current Alarm      7525      True
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...     Check Fault Exist In Current Alarm      7535      True
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...     Check Fault Exist In Current Alarm      7527      True
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
    UE Deregister Should Be Successful For SA             ${SA_UE_ID8}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID10}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID12}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID14}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID16}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID18}
    [Teardown]    Run Keyword And Ignore Error            Common Tear Down For CB014157

[1][1.0] CB014157_A_B1_1_Verify_Successful_RI_pilot_processing_during_RIM_DL_mitigation_triggered_by_RIM-RS_detection_only_for_Framework0
    [Tags]    QC_275704   QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]    The purpose of the test is to verify RI pilot processing
    ...      during RIM DL mitigation by RI detection
    [Setup]    Prepare For CB014157
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
    UE Register Should Be Successful For SA     ${SA_UE_ID8}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID8}
    UE Register Should Be Successful For SA     ${SA_UE_ID10}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID10}
    UE Register Should Be Successful For SA     ${SA_UE_ID12}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID12}
    UE Register Should Be Successful For SA     ${SA_UE_ID14}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID14}
    UE Register Should Be Successful For SA     ${SA_UE_ID16}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID16}
    UE Register Should Be Successful For SA     ${SA_UE_ID18}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RT}    traffic_ul_rate=${UL_RT}    UE_ID=${SA_UE_ID18}
    Log To Console      Traffinc UL/DL Started
    Sleep   5s
    Set UE Stats NR Type    ${SA_UE_ID1}    ${TYPE}
    slog.Start Syslog  ${Log_Path}     Pre_sys_log.LOG
    Remotely Interferance In TestMode   Prof_Id=9
    Set NR Cell Testmode    2   1   remote_interference     9   activate    60s
    Set NR Cell Testmode    2   2   remote_interference     9   activate    60s
    Set NR Cell Testmode    2   3   remote_interference     9   activate    90s
    Get Alarm By Details
    Sim Log Set
    NR Testmode RIMRS       ProfId=2       aggrCell=1      prop_del=26
    NR Testmode RIMRS       ProfId=3       aggrCell=2      prop_del=26
    NR Testmode RIMRS       ProfId=4       aggrCell=3      prop_del=26
    Set NR Cell Testmode     2    1    rim_rs    2    activate      60s
    Set NR Cell Testmode     2    2    rim_rs    3    activate      60s
    Set NR Cell Testmode     2    3    rim_rs    4    activate      150s
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...     Check Fault Exist In Current Alarm      7525      True
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...     Check Fault Exist In Current Alarm      7535      True
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...     Check Fault Exist In Current Alarm      7527      True
    slog.Stop Syslog
    slog.Start Syslog    ${Log_Path}        RI_Dis_sys_log.LOG
    Update Feature Flag For CB014157        14157_RI_Disble.json
    Wait For Next Full Pm Interval
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...     Verifying The PM Counter For CB014157    300     1      >0
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...    Verifying The PM Counter For CB014157     300     2      >0
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...    Verifying The PM Counter For CB014157     300     3      >0
    Wait For Next Full Pm Interval
    Set NR Cell Testmode    2   all   remote_interference      9       deactivate       60s
#    Set NR Cell Testmode    2   2   remote_interference      9       deactivate       60s
#    Set NR Cell Testmode    2   3   remote_interference      9       deactivate       90s
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
    UE Deregister Should Be Successful For SA             ${SA_UE_ID8}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID10}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID12}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID14}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID16}
    UE Deregister Should Be Successful For SA             ${SA_UE_ID18}
    [Teardown]    Run Keyword And Ignore Error            Common Tear Down For CB014157

