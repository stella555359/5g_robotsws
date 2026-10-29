*** Settings ***
Force Tags    PY39    RF50
Documentation    QT Classical Test
Library      BuiltIn
Library      taf.transport.ssh         WITH NAME    ssh
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      ${CURDIR}/../resources/python/TestCaseRequirement.py
Library      ${CURDIR}/../resources/python/QTListener.py

Resource     ${CURDIR}/../resources/robot/connections.robot
Resource     ${CURDIR}/../resources/robot/common.robot
Resource     ${CURDIR}/../resources/robot/common_l3call.robot
Resource     ${CURDIR}/../resources/robot/common_variables.robot
Resource     ${CURDIR}/../resources/robot/classical_keywords.robot
Resource     ${CURDIR}/../resources/robot/states.robot
Resource     ${CURDIR}/../resources/robot/additional_check.robot
Resource     ${CURDIR}/../resources/robot/allowed_alarms.robot
Resource     ${CURDIR}/../resources/robot/log_collector.robot
Resource     ${CURDIR}/../resources/robot/AIC_common_keywords.robot

Suite Setup        Run Keywords    QT Setup
...     AND                        Run Keyword and ignore error    Check Alarms In Ims File Common TS    name=_before_TEST_
...                                                                ims_log_dir=Additional_Execution_Logs/
Suite Teardown     Run Keywords    Stop Marvin
...        AND                     Run Keyword And Ignore Error    QT Teardown

*** Variables ***
${is_common_ts}    True

*** Test Cases ***
Install RF8 Package And Verify Cell Setup
    [Tags]  RF_SW_DEPL
    Pass Execution If    '${RF_VERSIONS_MAP['AXEGHA']}'=='not_set'    Skip RF sw installation as oran_rf_nk_version was not given!!!
    ${all_versions_matched}    ${rf_versions}    Check If RF Versions Matched   RF_name=AXEGHA    target_version=${RF_VERSIONS_MAP['AXEGHA']}
    Pass Execution If    ${all_versions_matched}
    ...        Skip RF sw installation as RF sw version on site:${rf_versions}[0] is same with the target version:${RF_VERSIONS_MAP['AXEGHA']}.
    ${is_rf_not_detected}    Run Keyword And Return Status    Should Be Empty    ${rf_versions}
    IF    ${is_rf_not_detected}
        ${msg}    Catenate    RF detection issue detected, target version:${RF_VERSIONS_MAP['AXEGHA']} will be installed
    ELSE
        ${msg}    Catenate     RF sw version on site:${rf_versions}[0] does not match the
        ...    target version:${RF_VERSIONS_MAP['AXEGHA']},RF sw installation will be performed
    END
    Log To Console    \n${msg}
    TRY
        Install RF Package    RF_name=AXEGHA    target_version=${RF_VERSIONS_MAP['AXEGHA']}
        Wait Until Keyword Succeeds    10min    30s    Verify Cells Setup
    FINALLY
        Check Unexpected Active Alarms    connection=coam_admin    skip_coam_connection_setup=True
    END

Install Package
    [Tags]    T0    ONAIR    swUpgrade    SW_DEPL    ONAIR_CALL_5G    ONAIR_CALL_4G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...       ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...       ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords    Requires TC    Install RF8 Package And Verify Cell Setup
    ...                 AND    Create Test Case And Start Marvin    Install_Package
    Install package on cOAM
    [Teardown]    Run Keywords    Check Errors In Syslog
    ...                           WRN/swm  ERR/LGC  cannot open directory /ffs/stb/planned/swpool/OAM/migtools/
    ...                    AND    Stop Test Case Marvin

Check Active Software Version
    [Tags]    T0    ONAIR    swUpgrade    SW_DEPL    sw_version    ONAIR_CALL_5G    ONAIR_CALL_4G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...       ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...       ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    Pass Execution If    '${AF_PATH}'=='null'   Skip sw version check as AF_PATH is not given!!!
    Check active SW version on cOAM
    [Teardown]    Permissions And Additional Check

Check Access To WebEm
    [Tags]    webem
    [Setup]    Requires TC         Check Active Software Version
    Check Access To WebEm

Verify BTS Startup
    [Tags]     T0    ONAIR    STARTUP    SW_DEPL   ONAIR_CALL_5G    ONAIR_CALL_4G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...        ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    Verify BTS Startup

Verify F1 Link Interface
    [Tags]     T0    ONAIR    F1    ONAIR_CALL_5G    ONAIR_CALL_CM    ONAIR_CALL_MRAT    5G
    ...        ONAIR_CALL_5G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_5G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords        Requires TC    Install Package
    ...        AND                 Requires TC    Check Active Software Version
    ...        AND                 Requires TC    Verify BTS Startup
    Wait Until Keyword Succeeds    5min    30s    Check F1 Link

Verify E1 Link Interface
    [Tags]     T0    ONAIR    E1    ONAIR_CALL_5G    ONAIR_CALL_CM    ONAIR_CALL_MRAT    5G
    ...        ONAIR_CALL_5G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_5G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Requires TC         Verify F1 Link Interface
    Wait Until Keyword Succeeds    5min  30s    Check E1 link

Verify S1 Connection
    [Tags]     T0    S1    ONAIR    ONAIR_CALL_4G    4G
    ...        ONAIR_CALL_4G_T1       ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_4G_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords    Requires TC    Install Package
    ...        AND             Requires TC    Check Active Software Version
    ...        AND             Requires TC    Verify BTS Startup
    Run Keyword If    'cus' in @{UEs}      Run Keywords
    ...               Reach OnAir With WTS
    ...        AND    Check If WTS Is Active
    ...       ELSE    Wait Until Keyword Succeeds    8min  30s    Check S1 link

Verify X2 Connection
    [Tags]     T0    ONAIR    X2    NSA    ONAIR_CALL_5G    ONAIR_CALL_CM    ONAIR_CALL_MRAT    5G
    ...        ONAIR_CALL_5G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_5G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Requires TC    Verify E1 Link Interface
    Wait Until Keyword Succeeds    8min  30s    Check X2 link

Verify NG Connection
    [Tags]     T0    ONAIR    NG    SA    ONAIR_CALL_5G    ONAIR_CALL_5G_T1    ONAIR_CALL_5G_T1_T2    5G
    [Setup]    Requires TC          Verify E1 Link Interface
    Wait Until Keyword Succeeds     5min  30s    Check NG link
    [Teardown]    ssh.reset_cache

Verify Cell Setup
    [Tags]     T0    ONAIR    CELL_SETUP    ONAIR_CALL_5G    ONAIR_CALL_4G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...        ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords    Requires TC    Verify NG Connection
    ...        AND             Requires TC    Verify S1 Connection
    ...        AND             Requires TC    Verify X2 Connection
    ...        AND             Requires TC    Install RF8 Package And Verify Cell Setup
    ${status}     Run Keyword And Return Status    Wait Until Keyword Succeeds    5min    30s    Verify Cells Setup
    Log Cells Status And Set Dir    status=${status}    log_name=installation package
    [Teardown]    Run Keywords    Run Keyword If Test Failed    Set Suite Variable    ${ims_log_name}    _after_installation_gNB_package_
    ...                    AND    Run Keyword If Test Failed    Set Suite Variable    ${ims_dir_name}    SW_Download_With_Activation/
    ...                    AND    Run Keyword If Test Passed
    ...                    Run Keyword And Ignore Error    Report KPI    target_dir=${OUTPUT_DIR}/SW_Download_With_Activation

Snapshot Collection
    [Tags]    snapshot
    [Setup]    Requires TC    Check Active Software Version
    ${sw_d}    Get Variable Value    ${sw_d}    ${loadBuild}
    ${snapshot_status}    Save Snapshot For Classical    sw_d=${sw_d}    snapshot_test=${True}
    IF    ${snapshot_status}
        Log To Console    \t\t- - - Collecting Snapshot file [DONE] - - -
        Check Error in Snapshot    ${snapshot_path}
    ELSE
        FAIL    Snapshot collection failed
    END

Check Alarms In IMS File After Installation gNB Package
    [Tags]    T0    ONAIR    ONAIR_CALL_5G    ONAIR_CALL_4G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...       ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...       ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    ...       CELL_SETUP     SW_DEPL     swUpgrade    snapshot_alarm
    [Setup]    Create Test Case And Start Marvin
    ...        Check_Alarms_In_IMS_File_After_Installation_gNB_Package
    Check Alarms In Ims File Common TS    name=_after_installation_gNB_package_    ims_log_dir=SW_Download_With_Activation/
    [Teardown]    Run Keywords    Run Keyword If Test Failed    Run Keyword If    ${are_logs_checked}==${False}
    ...                           Run Keyword And Ignore Error    Additional check in TC Common TS
    ...                    AND    Stop Test Case Marvin

Perform Commissioning
    [Tags]     ONAIR    scf    COMMISSIONING    ONAIR_CALL_5G    ONAIR_CALL_4G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...        ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords        Requires TC    Verify Cell Setup
    ...        AND                 Requires TC    Check Alarms In IMS File After Installation gNB Package
    Perform Commissioning With NIDD Check For Classical

Verify BTS Startup After Commissioning
    [Tags]     ONAIR    COMMISSIONING    ONAIR_CALL_5G    ONAIR_CALL_4G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...        ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    ...        COMMISSIONING
    [Setup]    Run Keywords    Requires TC    Check Alarms In IMS File After Installation gNB Package
    ...        AND             Requires TC    Verify Cell Setup
    Verify BTS Startup

Verify F1 Link Interface After Commissioning
    [Tags]     ONAIR    COMMISSIONING    ONAIR_CALL_5G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...        ONAIR_CALL_5G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_5G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2    5G
    [Setup]    Run Keywords        Requires TC    Perform Commissioning
    ...        AND                 Requires TC    Verify BTS Startup After Commissioning
    Wait Until Keyword Succeeds    5min    30s    Check F1 Link

Verify E1 Link Interface After Commissioning
    [Tags]     ONAIR    COMMISSIONING    ONAIR_CALL_5G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...        ONAIR_CALL_5G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_5G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2    5G
    [Setup]    Requires TC         Verify F1 Link Interface After Commissioning
    Wait Until Keyword Succeeds    5min  30s    Check E1 link

Verify S1 Connection After Commissioning
    [Tags]     ONAIR_CALL_4G          4G    COMMISSIONING
    ...        ONAIR_CALL_4G_T1       ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_4G_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords        Requires TC    Perform Commissioning
    ...        AND                 Requires TC    Verify BTS Startup After Commissioning
    Run Keyword If    'cus' in @{UEs}      Run Keywords
    ...               Reach OnAir With WTS
    ...        AND    Check If WTS Is Active
    ...       ELSE    Wait Until Keyword Succeeds    8min  30s    Check S1 link

Verify X2 Connection After Commissioning
    [Tags]     ONAIR    NSA    COMMISSIONING    ONAIR_CALL_5G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...        ONAIR_CALL_5G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_5G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2    5G
    [Setup]    Run Keywords    Requires TC    Verify E1 Link Interface After Commissioning
    ...        AND             Requires TC    Perform Commissioning
    ...        AND             Requires TC    Verify BTS Startup After Commissioning
    Wait Until Keyword Succeeds    8min  30s    Check X2 link

Verify NG Connection After Commissioning
    [Tags]     ONAIR    SA    COMMISSIONING    ONAIR_CALL_5G    ONAIR_CALL_5G_T1    ONAIR_CALL_5G_T1_T2    5G
    [Setup]    Requires TC          Verify E1 Link Interface After Commissioning
    Wait Until Keyword Succeeds     5min  30s    Check NG link
    [Teardown]    ssh.reset_cache

Verify Cell Setup After Commissioning
    [Tags]     ONAIR    ONAIR_CALL_5G    ONAIR_CALL_4G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...        ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    ...        COMMISSIONING
    [Setup]    Run Keyword If    '${deployment}' == 'SA'     Requires TC    Verify NG Connection After Commissioning
    ...        ELSE IF           '${gnb_or_enb}' == 'enb'    Requires TC    Verify S1 Connection After Commissioning
    ...        ELSE               Requires TC    Verify X2 Connection After Commissioning
    ${status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    3min  30s    Verify Cells Setup
    Log Cells Status And Set Dir    status=${status}    log_name=commissioning    dir_name=Full_Commissioning/
    [Teardown]    Run Keyword If Test Passed
    ...           Run Keyword And Ignore Error    Report KPI    kpi_name=kpi12_scf
    ...                                                         target_dir=${OUTPUT_DIR}/Full_Commissioning    kpi_list=kpi12

Check Alarms In IMS File After Commissioning
    [Tags]     ONAIR    ONAIR_CALL_5G    ONAIR_CALL_4G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...        ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    ...        COMMISSIONING
    [Setup]    Run Keywords    Requires TC    Verify Cell Setup
    ...                 AND    Requires TC    Check Alarms In IMS File After Installation gNB Package
    ...                 AND    Create Test Case And Start Marvin
    ...                        Check_Alarms_In_IMS_File_After_Commissioning
    Check Alarms In Ims File Common TS    name=_after_commissioning_    ims_log_dir=Full_Commissioning/
    [Teardown]    Run Keywords    Run Keyword If Test Failed    Run Keyword If    ${are_logs_checked}==${False}
    ...                           Run Keyword And Ignore Error    Additional check in TC Common TS
    ...                    AND    Stop Test Case Marvin

L3 Call 2G
    [Tags]       CALL_2G    CALL_MRAT    ONAIR_CALL_MRAT    ONAIR_CALL_MRAT_T1    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords    Requires TC    Verify Cell Setup After Commissioning
    ...                 AND    Requires TC    Check Alarms In IMS File After Commissioning
    ...                 AND    Requires TC    Verify Cell Setup
    ...                 AND    Requires TC    Check Alarms In IMS File After Installation gNB Package
    ...                 AND    Create Test Case And Start Marvin    L3_Call_2G
    [Timeout]    10 min
    L3 call      classical    _2G
    [Teardown]   Run Keywords    Teardown After L3Call
    ...                    AND    Stop Test Case Marvin

L3 Call 3G
    [Tags]       CALL_3G    CALL_MRAT    ONAIR_CALL_MRAT    ONAIR_CALL_MRAT_T1    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords    Requires TC    Verify Cell Setup After Commissioning
    ...                 AND    Requires TC    Check Alarms In IMS File After Commissioning
    ...                 AND    Requires TC    Verify Cell Setup
    ...                 AND    Requires TC    Check Alarms In IMS File After Installation gNB Package
    ...                 AND    Create Test Case And Start Marvin    L3_Call_3G
    [Timeout]    10 min
    L3 call      classical    _3G
    [Teardown]    Run Keywords    Teardown After L3Call
    ...                    AND    Stop Test Case Marvin

L3 Call 4G
    [Tags]       CALL_4G    CALL_MRAT    CALL_CM    ONAIR_CALL_4G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...          ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...          ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords    Requires TC    Verify Cell Setup After Commissioning
    ...                 AND    Requires TC    Check Alarms In IMS File After Commissioning
    ...                 AND    Requires TC    Verify Cell Setup
    ...                 AND    Requires TC    Check Alarms In IMS File After Installation gNB Package
    ...                 AND    Create Test Case And Start Marvin    L3_Call_4G
    [Timeout]    20 min
    L3 call      classical    _4G
    [Teardown]    Run Keywords    Teardown After L3Call
    ...                    AND    Stop Test Case Marvin

L3 Call 5G
    [Tags]       CALL_5G    CALL_MRAT    CALL_CM    ONAIR_CALL_5G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...          ONAIR_CALL_5G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...          ONAIR_CALL_5G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2    5G
    [Setup]    Run Keywords    Requires TC    Verify Cell Setup After Commissioning
    ...                 AND    Requires TC    Check Alarms In IMS File After Commissioning
    ...                 AND    Requires TC    Verify Cell Setup
    ...                 AND    Requires TC    Check Alarms In IMS File After Installation gNB Package
    ...                 AND    Create Test Case And Start Marvin    L3_Call_5G
    [Timeout]    40 min
    L3 call      classical    _5G
    [Teardown]    Run Keywords    Teardown After L3Call
    ...                    AND    Stop Test Case Marvin

Check Alarms In IMS File After L3Call
    [Tags]       CALL_5G    CALL_MRAT    CALL_CM    ONAIR_CALL_5G    ONAIR_CALL_4G
    ...          ONAIR_CALL_CM    ONAIR_CALL_MRAT    ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...          ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords    Requires TC    Verify Cell Setup After Commissioning
    ...                 AND    Requires TC    Check Alarms In IMS File After Commissioning
    ...                 AND    Create Test Case And Start Marvin    Check_Alarms_In_IMS_File_After_L3Call
    Check Alarms In Ims File Common TS    name=_after_l3call_    ims_log_dir=L3_Call/
    [Teardown]    Run Keywords    Run Keyword If Test Passed    Run Keyword And Ignore Error    Save Snapshot Only
    ...                    AND    Run Keyword If Test Failed    Run Keyword If    ${are_logs_checked}==${False}
    ...                           Run Keyword And Ignore Error    Additional check in TC Common TS
    ...                    AND    Stop Test Case Marvin

Install Package T1
    [Tags]          T1    swUpgradeT1    ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...             ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords    Requires TC    Verify Cell Setup After Commissioning
    ...                 AND    Requires TC    Check Alarms In IMS File After L3Call
    ...                 AND    Requires TC    Verify Cell Setup
    ...                 AND    Requires TC    Check Alarms In IMS File After Installation gNB Package
    ...                 AND    Create Test Case And Start Marvin    Install_Package_T1
    ${sw_package}   Replace String   ${AF_PATH}   downloadable   downloadable_testpackage_T1
    Install package on cOAM   T1orT2=T1    sw_package=${sw_package}
    [Teardown]    Run Keywords    Check Errors In Syslog    WRN/swm    cannot open directory /ffs/stb/planned/swpool/OAM/migtools/
    ...                    AND    Stop Test Case Marvin

Check Active T1 Software Version
    [Tags]          T1    swUpgradeT1     ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...             ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]         Requires TC    Check Alarms In IMS File After L3Call
    Check active SW version on cOAM    T1orT2=T1
    [Teardown]    Permissions And Additional Check

Verify BTS Startup T1
    [Tags]    T1    ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...       ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]   Requires TC    Check Alarms In IMS File After L3Call
    Verify BTS Startup

Verify F1 Link Interface T1
    [Tags]     T1    ONAIR_CALL_5G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_5G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2    5G
    [Setup]    Run Keywords    Requires TC    Install Package T1
    ...        AND             Requires TC    Check Active T1 Software Version
    ...        AND             Requires TC    Verify BTS Startup T1
    Wait Until Keyword Succeeds    5min    30s    Check F1 Link

Verify E1 Link Interface T1
    [Tags]     T1    ONAIR_CALL_5G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_5G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2    5G
    [Setup]    Requires TC    Verify F1 Link Interface T1
    Wait Until Keyword Succeeds    5min  30s    Check E1 link

Verify S1 Connection T1
    [Tags]     T1    4G    ONAIR_CALL_4G_T1       ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_4G_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords    Requires TC    Install Package T1
    ...        AND             Requires TC    Check Active T1 Software Version
    ...        AND             Requires TC    Verify BTS Startup T1
    Run Keyword If    'cus' in @{UEs}      Run Keywords
    ...               Reach OnAir With WTS
    ...        AND    Check If WTS Is Active
    ...       ELSE    Wait Until Keyword Succeeds    8min  30s    Check S1 link

Verify X2 Connection T1
    [Tags]     T1    NSA    ONAIR_CALL_5G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_5G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2    5G
    [Setup]    Requires TC    Verify E1 Link Interface T1
    Wait Until Keyword Succeeds    8min  30s    Check X2 link

Verify NG Connection T1
    [Tags]     T1    SA    ONAIR_CALL_5G_T1    ONAIR_CALL_5G_T1_T2    5G
    [Setup]    Requires TC    Verify E1 Link Interface T1
    Wait Until Keyword Succeeds     5min  30s    Check NG link
    [Teardown]    ssh.reset_cache

Verify Cell Setup T1
    [Tags]     T1    ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords    Requires TC     Verify NG Connection T1
    ...        AND             Requires TC    Verify S1 Connection T1
    ...        AND            Requires TC    Verify X2 Connection T1
    ${status}     Run Keyword And Return Status    Wait Until Keyword Succeeds    3min  30s    Verify Cells Setup
    Log Cells Status And Set Dir    status=${status}    log_name=T1    dir_name=Upgradability_T1/
    [Teardown]    Run Keyword If Test Passed
    ...           Run Keyword And Ignore Error    Report KPI    kpi_name=kpi4_T1    target_dir=${OUTPUT_DIR}/Upgradability_T1

Check Alarms In IMS File After Installation T1 Package
    [Tags]     T1    ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords    Requires TC    Verify Cell Setup After Commissioning
    ...                 AND    Requires TC    Check Alarms In IMS File After L3Call
    ...                 AND    Create Test Case And Start Marvin    Check_Alarms_In_IMS_File_After_Installation_T1_Package
    Check Alarms In Ims File Common TS    name=_after_T1_    ims_log_dir=Upgradability_T1/
    [Teardown]    Run Keywords    Run Keyword If Test Failed    Run Keyword If    ${are_logs_checked}==${False}
    ...                           Run Keyword And Ignore Error    Additional check in TC Common TS
    ...                    AND    Stop Test Case Marvin

Install Package T2
    [Tags]     T2    swUpgradeT2    ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords        Requires TC    Verify Cell Setup T1
    ...        AND                 Requires TC    Check Alarms In IMS File After Installation T1 Package
    ...        AND                 Requires TC    Verify Cell Setup
    ...        AND                 Requires TC    Check Alarms In IMS File After Installation gNB Package
    ${sw_package}   Replace String   ${AF_PATH}   downloadable   downloadable_testpackage_T2
    Install package on cOAM   T1orT2=T2    sw_package=${sw_package}
    [Teardown]        Check Errors In Syslog    WRN/swm

Check Active T2 Software Version
    [Tags]     T2    swUpgradeT2    ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords        Requires TC    Verify Cell Setup T1
    ...        AND                 Requires TC    Check Alarms In IMS File After Installation T1 Package
    Check active SW version on cOAM    T1orT2=T2
    [Teardown]    Permissions And Additional Check

Verify BTS Startup T2
    [Tags]     T2    ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords    Requires TC    Verify Cell Setup T1
    ...        AND             Requires TC    Check Alarms In IMS File After Installation T1 Package
    Verify BTS Startup

Verify F1 Link Interface T2
    [Tags]     T2    ONAIR_CALL_5G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2    5G
    [Setup]    Run Keywords    Requires TC    Install Package T2
    ...        AND             Requires TC    Check Active T2 Software Version
    ...        AND             Requires TC    Verify BTS Startup T2
    Wait Until Keyword Succeeds    5min    30s    Check F1 Link

Verify E1 Link Interface T2
    [Tags]     T2    ONAIR_CALL_5G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2    5G
    [Setup]    Requires TC    Verify F1 Link Interface T2
    Wait Until Keyword Succeeds    5min  30s    Check E1 link

Verify S1 Connection T2
    [Tags]     T2    4G    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords    Requires TC    Install Package T2
    ...        AND             Requires TC    Check Active T2 Software Version
    ...        AND             Requires TC    Verify BTS Startup T2
    Run Keyword If    'cus' in @{UEs}      Run Keywords
    ...               Reach OnAir With WTS
    ...        AND    Check If WTS Is Active
    ...       ELSE    Wait Until Keyword Succeeds    8min  30s    Check S1 link

Verify X2 Connection T2
    [Tags]     T2    NSA    ONAIR_CALL_5G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2    5G
    [Setup]    Requires TC    Verify E1 Link Interface T2
    Wait Until Keyword Succeeds    8min  30s    Check X2 link

Verify NG Connection T2
    [Tags]     T2    SA   ONAIR_CALL_5G_T1_T2    5G
    [Setup]    Requires TC    Verify E1 Link Interface T2
    Wait Until Keyword Succeeds     5min  30s    Check NG link
    [Teardown]    ssh.reset_cache

Verify Cell Setup T2
    [Tags]     T2    ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords    Requires TC     Verify NG Connection T2
    ...        AND             Requires TC    Verify S1 Connection T2
    ...        AND             Requires TC    Verify X2 Connection T2
    ${status}     Run Keyword And Return Status    Wait Until Keyword Succeeds    3min  30s    Verify Cells Setup
    Log Cells Status And Set Dir    status=${status}    log_name=T2
    [Teardown]    Run Keyword If Test Passed
    ...           Run Keyword And Ignore Error    Report KPI    kpi_name=kpi4_T2    target_dir=${OUTPUT_DIR}/Upgradability_T2

Check Alarms In IMS File After Installation T2 Package
    [Tags]     T2    ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords        Requires TC    Verify Cell Setup T1
    ...        AND                 Requires TC    Check Alarms In IMS File After Installation T1 Package
    Check Alarms In Ims File Common TS    name=_after_T2_    ims_log_dir=Upgradability_T2/
    [Teardown]    Run Keyword If Test Failed    Run Keyword If    ${are_logs_checked}==${False}
    ...           Run Keyword And Ignore Error    Additional check in TC Common TS

Install Package Basebuild
    [Tags]     BACK_COMPATIBILITY
    [Setup]    Run Keywords        Requires TC    Verify Cell Setup T2
    ...        AND                 Requires TC    Check Alarms In IMS File After Installation T2 Package
    ...        AND                 Requires TC    Verify Cell Setup T1
    ...        AND                 Requires TC    Check Alarms In IMS File After Installation T1 Package
    ...        AND                 Requires TC    Verify Cell Setup
    ...        AND                 Requires TC    Check Alarms In IMS File After Installation gNB Package
    Install package on cOAM   sw_package=${BASEBUILD_PATH}
    [Teardown]    Check Errors In Syslog    WRN/swm    cannot open directory /ffs/stb/planned/swpool/OAM/migtools/

Check Active Basebuild Software Version
    [Tags]     BACK_COMPATIBILITY
    [Setup]    Requires TC    Install Package Basebuild
    Check active SW version on cOAM    AF_PATH=${BASEBUILD_PATH}
    [Teardown]    Permissions And Additional Check

Verify BTS Startup Basebuild
    [Tags]    BACK_COMPATIBILITY
    [Setup]   Requires TC    Check Alarms In IMS File After L3Call
    Verify BTS Startup

Verify F1 Link Interface Basebuild
    [Tags]     BACK_COMPATIBILITY    5G
    [Setup]    Run Keywords    Requires TC    Install Package Basebuild
    ...        AND             Requires TC    Check Active Basebuild Software Version
    ...        AND             Requires TC    Verify BTS Startup Basebuild
    Wait Until Keyword Succeeds    5min    30s    Check F1 Link

Verify E1 Link Interface Basebuild
    [Tags]     BACK_COMPATIBILITY    5G
    [Setup]    Requires TC    Verify F1 Link Interface Basebuild
    Wait Until Keyword Succeeds    5min  30s    Check E1 link

Verify S1 Connection Basebuild
    [Tags]     BACK_COMPATIBILITY    4G
    [Setup]    Run Keywords    Requires TC    Install Package Basebuild
    ...        AND             Requires TC    Check Active Basebuild Software Version
    ...        AND             Requires TC    Verify BTS Startup Basebuild
    Run Keyword If    'cus' in @{UEs}      Run Keywords
    ...               Reach OnAir With WTS
    ...        AND    Check If WTS Is Active
    ...       ELSE    Wait Until Keyword Succeeds    8min  30s    Check S1 link

Verify X2 Connection Basebuild
    [Tags]     BACK_COMPATIBILITY    NSA    5G
    [Setup]    Requires TC    Verify E1 Link Interface T1
    Wait Until Keyword Succeeds    8min  30s    Check X2 link

Verify NG Connection Basebuild
    [Tags]     BACK_COMPATIBILITY    SA    5G
    [Setup]    Requires TC    Verify E1 Link Interface T1
    Wait Until Keyword Succeeds     5min  30s    Check NG link
    [Teardown]    ssh.reset_cache

Verify Cell Setup Basebuild
    [Tags]     BACK_COMPATIBILITY
    [Setup]    Run Keywords    Requires TC    Verify NG Connection Basebuild
    ...        AND             Requires TC    Verify S1 Connection Basebuild
    ...        AND             Requires TC    Verify X2 Connection Basebuild
    ${status}     Run Keyword And Return Status    Wait Until Keyword Succeeds    3min  30s    Verify Cells Setup
    Log Cells Status And Set Dir    status=${status}    log_name=Basebuild    dir_name=Upgradability_Basebuild/
    [Teardown]    Run Keyword If Test Passed
    ...           Run Keyword And Ignore Error    Report KPI    kpi_name=kpi4_Basebuild
    ...                                                         target_dir=${OUTPUT_DIR}/Upgradability_Basebuild

Check Alarms In IMS File After Installation Basebuild Package
    [Tags]     BACK_COMPATIBILITY
    [Setup]    Run Keywords    Requires TC    Verify Cell Setup T2
    ...        AND             Requires TC    Check Alarms In IMS File After Installation T2 Package
    Check Alarms In Ims File Common TS    name=_after_Basebuild_    ims_log_dir=Upgradability_Basebuild/
    [Teardown]    Run Keyword If Test Failed    Run Keyword If    ${are_logs_checked}==${False}
    ...           Run Keyword And Ignore Error    Additional check in TC Common TS

Install Package T0
    [Tags]     BACK_COMPATIBILITY
    [Setup]    Run Keywords        Requires TC    Verify Cell Setup Basebuild
    ...        AND                 Requires TC    Check Alarms In IMS File After Installation Basebuild Package
    ...        AND                 Requires TC    Verify Cell Setup T2
    ...        AND                 Requires TC    Check Alarms In IMS File After Installation T2 Package
    ...        AND                 Requires TC    Verify Cell Setup T1
    ...        AND                 Requires TC    Check Alarms In IMS File After Installation T1 Package
    ...        AND                 Requires TC    Verify Cell Setup
    ...        AND                 Requires TC    Check Alarms In IMS File After Installation gNB Package
    Install package on cOAM
    [Teardown]    Check Errors In Syslog    WRN/swm    cannot open directory /ffs/stb/planned/swpool/OAM/migtools/

Check Active T0 Software Version
    [Tags]     BACK_COMPATIBILITY
    [Setup]    Requires TC    Install Package T0
    Check active SW version on cOAM
    [Teardown]    Permissions And Additional Check

Verify BTS Startup T0
    [Tags]    BACK_COMPATIBILITY
    [Setup]   Requires TC    Check Alarms In IMS File After L3Call
    Verify BTS Startup

Verify F1 Link Interface T0
    [Tags]     BACK_COMPATIBILITY    5G
    [Setup]    Run Keywords    Requires TC    Install Package T0
    ...        AND             Requires TC    Check Active T0 Software Version
    ...        AND             Requires TC    Verify BTS Startup T0
    Wait Until Keyword Succeeds    5min    30s    Check F1 Link

Verify E1 Link Interface T0
    [Tags]     BACK_COMPATIBILITY    5G
    [Setup]    Requires TC    Verify F1 Link Interface T0
    Wait Until Keyword Succeeds    5min  30s    Check E1 link

Verify S1 Connection T0
    [Tags]     BACK_COMPATIBILITY    4G
    [Setup]    Run Keywords    Requires TC    Install Package T0
    ...        AND             Requires TC    Check Active T0 Software Version
    ...        AND             Requires TC    Verify BTS Startup T0
    Run Keyword If    'cus' in @{UEs}      Run Keywords
    ...               Reach OnAir With WTS
    ...        AND    Check If WTS Is Active
    ...       ELSE    Wait Until Keyword Succeeds    8min  30s    Check S1 link

Verify X2 Connection T0
    [Tags]     BACK_COMPATIBILITY    NSA    5G
    [Setup]    Requires TC    Verify E1 Link Interface T1
    Wait Until Keyword Succeeds    8min  30s    Check X2 link

Verify NG Connection T0
    [Tags]     BACK_COMPATIBILITY    SA    5G
    [Setup]    Requires TC    Verify E1 Link Interface T1
    Wait Until Keyword Succeeds     5min  30s    Check NG link
    [Teardown]    ssh.reset_cache

Verify Cell Setup T0
    [Tags]     BACK_COMPATIBILITY
    [Setup]    Run Keywords    Requires TC    Verify NG Connection T0
    ...        AND             Requires TC    Verify S1 Connection T0
    ...        AND             Requires TC    Verify X2 Connection T0
    ${status}     Run Keyword And Return Status    Wait Until Keyword Succeeds    3min  30s    Verify Cells Setup
    Log Cells Status And Set Dir    status=${status}    log_name=T0    dir_name=Upgradability_T0/
    [Teardown]    Run Keyword If Test Passed
    ...           Run Keyword And Ignore Error    Report KPI    kpi_name=kpi4_Basebuild
    ...                                                         target_dir=${OUTPUT_DIR}/Upgradability_T0

Check Alarms In IMS File After Installation T0 Package
    [Tags]     BACK_COMPATIBILITY
    [Setup]    Requires TC    Verify Cell Setup Basebuild
    Check Alarms In Ims File Common TS    name=_after_Basebuild_    ims_log_dir=Upgradability_T0/
    [Teardown]    Run Keyword If Test Failed    Run Keyword If    ${are_logs_checked}==${False}
    ...           Run Keyword And Ignore Error    Additional check in TC Common TS

Check Alarms In IMS File
    [Tags]    ALARMS
    Check Alarms In Ims File Common TS
    [Teardown]    Run Keyword If Test Failed    Run Keyword And Ignore Error    Additional check in TC Common TS

Check Crash Info In Log
    [Tags]     CRASH_INFO    ONAIR    ONAIR_CALL_5G    ONAIR_CALL_4G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...        ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...        ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    Crash Info Check In Syslog
