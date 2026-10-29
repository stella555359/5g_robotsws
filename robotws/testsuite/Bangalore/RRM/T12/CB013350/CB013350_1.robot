*** Settings ***
Force Tags    CLOUD_5G_I_LOO_AP_LOOO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation       :copyright:   Nokia
...                 :author   :   Vikash Kumar
...                 :contact  :   vikash.20.kumar@nokia.com
...                 :Feature  :   This user scenario aims to verify the activation of the CB013350 feature
...                 in a legacy RI based DL muting combined with RIM-RS based DL muting configuration.
...                 The scenario assumes a cell load below the configured threshold,
...                 fulfilling the CB013350 condition for enabling RIM DL muting.
...                 Upon meeting all other legacy conditions,the scenario expects DL muting to be applied.

Resource          resources/Keywords/CB013350_keywords.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


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


*** Test Cases ***
[1][2.0] CB013350_A_29_Verify DL muting when cell load is changed from High to low
    [Tags]    QC_131813   QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]    Legacy RI based DL muting combined with RIM-RS based DL muting configuration
    ...     the CB013350 condition for enabling RIM DL muting
    [Setup]    Prepare For CB013350
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
    Set NR Cell Testmode	2	1	remote_interference 	9   activate
    Get Alarm By Details
    Sim Log Set
    NR Testmode RIMRS   prop_del=26
    Set NR Cell Testmode     2    1    rim_rs    2    activate
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...     Check Fault Exist In Current Alarm      7525      True
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...     Check Fault Exist In Current Alarm      7535      True
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...     Check Fault Exist In Current Alarm      7527      True
    Verifying The PM Counter For 13350        >0      0
    Check Fault Exist In Current Alarm      7535      True
    Check Fault Exist In Current Alarm      7527      True
    slog.Stop Syslog
    Cell On High Threshold
    Cell On Low Threshold
    Log To Console    Alarm Counter When Feature Flag Disable Flag manually
    Alarm And Counter When Feature Flag Disable
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
    [Teardown]    Run Keyword And Ignore Error            Common Tear Down For CB013350

[1][1.0] CB013350_A_20_Verify RI based DL muting for manually triggered DL muting with low cell load
    [Tags]    QC_120670   QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]    Legacy RI based DL muting combined with RIM-RS based DL muting configuration
    ...     the CB013350 condition for enabling RIM DL muting With Low Cell Load.
    [Setup]    Prepare For CB013350
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
    Set NR Cell Testmode	2	1	remote_interference 	9   activate
    Get Alarm By Details
    Sim Log Set
    NR Testmode RIMRS   prop_del=26
    Set NR Cell Testmode     2    1    rim_rs    2    activate
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...     Check Fault Exist In Current Alarm      7525      True
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...     Check Fault Exist In Current Alarm      7535      True
    Wait Until Keyword Succeeds     ${TIMEOUT}        ${RETRY_TIME}
    ...     Check Fault Exist In Current Alarm      7527      True
    Verifying The PM Counter For 13350        >0      0
    Enable Feature Flag For 13350       false    0   10  true    1
    Check Fault Exist In Current Alarm      7535      True
    Check Fault Exist In Current Alarm      7527      True
    Verifying The PM Counter For 13350        >0      >0
    slog.Stop Syslog
    Cell On Low Threshold
    Log To Console    Alarm Counter When Feature Flag Disable Flag manually
    Alarm And Counter When Feature Flag Disable
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
    [Teardown]    Run Keyword And Ignore Error            Common Tear Down For CB013350
