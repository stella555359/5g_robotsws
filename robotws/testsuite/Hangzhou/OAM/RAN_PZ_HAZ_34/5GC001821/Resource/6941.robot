*** Settings ***
Documentation
...  author: zhe.1.lin@nokia-sbell.com
Library   taf.sbts.oam.coam.admin   WITH NAME   coam_client
Resource   ../../common/taf_coam.robot
Resource   .${/}702.robot
Resource   ../../common/gnb.robot
Resource   coam.robot
Library   OperatingSystem
Library   String

*** Variables ***


*** Keywords ***
Connect to RU
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    ${version_active_sw}    Coam Get Active SW Version
    ${release}    Coam Get program version based on gNB active version    version_active_sw=${version_active_sw}
    Run keyword if    '${release}'=='22R1'
    ...    Connect to RU With Allocated IP
    ...    ELSE    Connect to RU With Allocated IP   ru_username=rfsw    ru_password=HfBKgqIOogKY3BlGtiniuCI9bs76C8jYsAY6vw8f/Tw=

Disconnect to RU
    Run Keyword And Ignore Error   COAM Teardown GNB Connections
    Run Keyword And Ignore Error   csn.Disconnect   connection=RU
    Run Keyword And Ignore Error   csn.Disconnect   connection=ASIK Master

Collect SOAP and Check
    [Arguments]    ${distName_value}    ${expected_value}
    Enable capture soap msg flag on RU
    Sleep   10s
    ${soap_log_path}   Download soap msg from RU Reg    soap_log=UnitOAM_SOAP_Log.xml
    Verify SOAP Supported Feature    distName_value=${distName_value}    expected_value=${expected_value}
    ...    log_path=${soap_log_path}

6941 Suite Setup
    robot_common_operations.Common Suite Setup
    Case Setup
    Suite Setup Steps

6941 Suite Teardown
    Run Keyword And Ignore Error    Case Teardown
    Run Keyword And Ignore Error    Suite Teardown Steps

Trigger and Check ABIL Fault4606
    ${actForce_Value}    COAM Get Parameter Value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    ...    parameter=actForceUnitAutoReset
    run keyword if    '${actForce_Value}'=='false'    COAM Update Parameter
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1    parameter=actForceUnitAutoReset    value=true
    ${version_active_sw}    Coam Get Active SW Version   connection=COAM
    ${release}    Coam Get program version based on gNB active version    version_active_sw=${version_active_sw}
    run keyword if    '${release}'=='22R1'
    ...    Run Keywords
    ...        COAM Update Parameter    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1   parameter=cableLenghtRangeMin   value=30
    ...        AND   sleep    30s
    ...        AND   COAM Update Parameter    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1   parameter=cableLenghtRangeMin   value=1
    ...    ELSE    Run Keywords
    ...        COAM Update Parameter    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1   parameter=t12Min   value=30
    ...        AND    sleep    30s
    ...        AND    COAM Update Parameter    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1   parameter=t12Min   value=0
#    ${check_fault4606}    Check Alarm Exist in RawAlarmHistory    alarm_filter=4606


Trigger and Check ABIO Fault4606
    ${actForce_Value}    COAM Get Parameter Value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    ...    parameter=actForceUnitAutoReset
    run keyword if    '${actForce_Value}'=='true'    COAM Update Parameter
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1    parameter=actForceUnitAutoReset    value=false
    ${version_active_sw}    Coam Get Active SW Version   connection=COAM
    ${release}    Coam Get program version based on gNB active version    version_active_sw=${version_active_sw}
    run keyword if    '${release}'=='22R1'
    ...    Run Keywords
    ...        COAM Update Parameter    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1   parameter=cableLenghtRangeMin   value=30
    ...        AND    sleep    10s
    ...        AND    COAM Update Parameter    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2   parameter=cableLenghtRangeMin   value=30
    ...        AND    sleep    10s
    ...        AND    COAM Update Parameter    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3   parameter=cableLenghtRangeMin   value=30
    ...        AND    sleep    10s
    ...        AND    COAM Reset Site   wait_for_reconnection=${true}
    ...        AND    wait until keyword succeeds   20m   30s   COAM Check All Cells Onair
    ...        AND    COAM Update Parameter    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2   parameter=cableLenghtRangeMin   value=0
    ...    ELSE   Run Keywords
    ...        COAM Update Parameter    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2   parameter=t12Min   value=30
    ...        AND    sleep    10s
    ...        AND    COAM Update Parameter    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2   parameter=t12Min   value=0
#    sleep    10s
#    run keyword and continue on failure   Wait Until Keyword Succeeds   3x   5min    check active fault 4606
#    Wait For Expect Fault Present   timeout=600   faultId=4606   connection=COAM
    COAM WEBUI Whether Close Start Up View Window
#    wait until keyword succeeds    10min    1min  selenium_coam.reset_abil


check active fault 4606
    ${active_alarms}   taf_coam.COAM Get Active Alarms
    ${supplAlarmInfo}   Set Variable   NONE
    FOR   ${active_alarm}   IN   @{active_alarms}
       ${supplAlarmInfo}   Set Variable If
       ...   '${active_alarm['faultId']}'=='4606'   ${active_alarm['supplAlarmInfo']}
       ...   '${active_alarm['faultId']}'!='4606'   ${supplAlarmInfo}
       Exit For Loop If   '${active_alarm['faultId']}'=='4606'
    END
    Should Not Be Equal As Strings   ${supplAlarmInfo}   NONE