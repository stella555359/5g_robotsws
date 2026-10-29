*** Settings ***
Force Tags    PY39    RF50
Documentation    QT Classical Test
Library      BuiltIn
Library      taf.transport.ssh         WITH NAME    ssh
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      ${CURDIR}/../../resources/python/TestCaseRequirement.py
Library      ${CURDIR}/../../resources/python/QTListener.py

Resource     ${CURDIR}/../../resources/robot/connections.robot
Resource     ${CURDIR}/../../resources/robot/common.robot
Resource     ${CURDIR}/../../resources/robot/common_l3call.robot
Resource     ${CURDIR}/../../resources/robot/common_variables.robot
Resource     ${CURDIR}/../../resources/robot/classical_keywords.robot
Resource     ${CURDIR}/../../resources/robot/states.robot
Resource     ${CURDIR}/../../resources/robot/additional_check.robot
Resource     ${CURDIR}/../../resources/robot/allowed_alarms.robot
Resource     ${CURDIR}/../../resources/robot/log_collector.robot
Resource     ${CURDIR}/../../resources/robot/AIC_common_keywords.robot
Resource     ${CURDIR}/../../resources/robot/airphone.robot

Suite Setup       Run Keywords    Get Baseline For Classical
...     AND       QT Setup
...     AND       Run Keyword and ignore error    Check Alarms In Ims File Common TS    name=_before_TEST_
...               ims_log_dir=Additional_Execution_Logs/
Suite Teardown    Run Keyword And Ignore Error    QT Teardown

*** Variables ***
${is_common_ts}
${streamVersion}
${smod_type}
${loadBuild}
${deployment}
${bbmod_type}
${NODE_NAME}
${hw_config}
${cellConfiguration}
${custom_config}
${site}

*** Test Cases ***
Install Package
    [Tags]    T0    ONAIR    swUpgrade    SW_DEPL    ONAIR_CALL_5G    ONAIR_CALL_4G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...       ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...       ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    Install gNB package    sw_version=${SW_VERSION}
    [Teardown]    Check Errors In Syslog    WRN/swm  ERR/LGC  cannot open directory /ffs/stb/planned/swpool/OAM/migtools/

Check Active Software Version
    [Tags]    T0    ONAIR    swUpgrade    SW_DEPL    sw_version    ONAIR_CALL_5G    ONAIR_CALL_4G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...       ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...       ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    Pass Execution If    '${AF_PATH}'=='null'   Skip sw version check as AF_PATH is not given!!!
    ${expected_sw_version}    Fetch From Right    ${SW_VERSION}    _ENB_
    Wait Until Keyword Succeeds    10min    1min    Check if installed package is on active version    ${expected_sw_version}
    [Teardown]    Permissions And Additional Check

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
    ...        AND            Requires TC    Verify X2 Connection
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
    Check Alarms In Ims File Common TS    name=_after_installation_gNB_package_    ims_log_dir=SW_Download_With_Activation/
    [Teardown]    Run Keyword If Test Failed    Run Keyword If    ${are_logs_checked}==${False}
    ...           Run Keyword And Ignore Error    Additional check in TC Common TS

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
    [Setup]    Run Keywords        Requires TC    Verify Cell Setup
    ...        AND                 Requires TC    Check Alarms In IMS File After Installation gNB Package
    Check Alarms In Ims File Common TS    name=_after_commissioning_    ims_log_dir=Full_Commissioning/
    [Teardown]    Run Keyword If Test Failed    Run Keyword If    ${are_logs_checked}==${False}
    ...           Run Keyword And Ignore Error    Additional check in TC Common TS

L3 Call 2G
    [Tags]       CALL_2G    CALL_MRAT    ONAIR_CALL_MRAT    ONAIR_CALL_MRAT_T1    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords        Requires TC    Verify Cell Setup After Commissioning
    ...        AND                 Requires TC    Check Alarms In IMS File After Commissioning
    ...        AND                 Requires TC    Verify Cell Setup
    ...        AND                 Requires TC    Check Alarms In IMS File After Installation gNB Package
    [Timeout]    10 min
    L3 call      classical    _2G
    [Teardown]   Teardown After L3Call


L3 Call 3G
    [Tags]       CALL_3G    CALL_MRAT    ONAIR_CALL_MRAT    ONAIR_CALL_MRAT_T1    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords        Requires TC    Verify Cell Setup After Commissioning
    ...        AND                 Requires TC    Check Alarms In IMS File After Commissioning
    ...        AND                 Requires TC    Verify Cell Setup
    ...        AND                 Requires TC    Check Alarms In IMS File After Installation gNB Package
    [Timeout]    10 min
    L3 call      classical    _3G
    [Teardown]   Teardown After L3Call

L3 Call 4G
    [Tags]       CALL_4G    CALL_MRAT    CALL_CM    ONAIR_CALL_4G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...          ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...          ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords        Requires TC    Verify Cell Setup After Commissioning
    ...        AND                 Requires TC    Check Alarms In IMS File After Commissioning
    ...        AND                 Requires TC    Verify Cell Setup
    ...        AND                 Requires TC    Check Alarms In IMS File After Installation gNB Package
    [Timeout]    20 min
    L3 call      classical    _4G
    [Teardown]   Teardown After L3Call

L3 Call 5G
    [Tags]       CALL_5G    CALL_MRAT    CALL_CM    ONAIR_CALL_5G    ONAIR_CALL_CM    ONAIR_CALL_MRAT
    ...          ONAIR_CALL_5G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...          ONAIR_CALL_5G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2    5G
    [Setup]    Run Keywords        Requires TC    Verify Cell Setup After Commissioning
    ...        AND                 Requires TC    Check Alarms In IMS File After Commissioning
    ...        AND                 Requires TC    Verify Cell Setup
    ...        AND                 Requires TC    Check Alarms In IMS File After Installation gNB Package
    [Timeout]    25 min
    L3 call      classical    _5G
    [Teardown]   Teardown After L3Call

Check Alarms In IMS File After L3Call
    [Tags]       CALL_5G    CALL_MRAT    CALL_CM    ONAIR_CALL_5G    ONAIR_CALL_4G
    ...          ONAIR_CALL_CM    ONAIR_CALL_MRAT    ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...          ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords        Requires TC    Verify Cell Setup After Commissioning
    ...        AND                 Requires TC    Check Alarms In IMS File After Commissioning
    Check Alarms In Ims File Common TS    name=_after_l3call_    ims_log_dir=L3_Call/
    [Teardown]    Run Keywords    Run Keyword If Test Passed    Run Keyword And Ignore Error    Save Snapshot Only
    ...           AND    Run Keyword If Test Failed    Run Keyword If    ${are_logs_checked}==${False}
    ...           Run Keyword And Ignore Error    Additional check in TC Common TS

Install Package T1
    [Tags]          T1    swUpgradeT1    ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...             ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]    Run Keywords        Requires TC    Verify Cell Setup After Commissioning
    ...        AND                 Requires TC    Check Alarms In IMS File After L3Call
    ...        AND                 Requires TC    Verify Cell Setup
    ...        AND                 Requires TC    Check Alarms In IMS File After Installation gNB Package
    ${sw_package}   Replace String   ${AF_PATH}   downloadable   downloadable_testpackage_T1
    Install gNB package    sw_version=${SW_VERSION}    component=T1
    [Teardown]    Check Errors In Syslog    WRN/swm    cannot open directory /ffs/stb/planned/swpool/OAM/migtools/

Check Active T1 Software Version
    [Tags]          T1    swUpgradeT1     ONAIR_CALL_5G_T1    ONAIR_CALL_4G_T1    ONAIR_CALL_CM_T1    ONAIR_CALL_MRAT_T1
    ...             ONAIR_CALL_5G_T1_T2    ONAIR_CALL_4G_T1_T2    ONAIR_CALL_CM_T1_T2    ONAIR_CALL_MRAT_T1_T2
    [Setup]         Requires TC    Check Alarms In IMS File After L3Call
    Wait Until Keyword Succeeds    3min    20s    coam.connect to
    ...                                           bts_host=${bts_host}    update_interval=1000    name=coam_admin
    Wait Until Keyword Succeeds    5min    20s    Check SW version    component=T1
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
    [Setup]    Run Keywords        Requires TC    Verify Cell Setup After Commissioning
    ...        AND                 Requires TC    Check Alarms In IMS File After L3Call
    Check Alarms In Ims File Common TS    name=_after_T1_    ims_log_dir=Upgradability_T1/
    [Teardown]    Run Keyword If Test Failed    Run Keyword If    ${are_logs_checked}==${False}
    ...           Run Keyword And Ignore Error    Additional check in TC Common TS

Check Alarms In IMS File
    [Tags]    ALARMS
    Check Alarms In Ims File Common TS
    [Teardown]    Run Keyword If Test Failed    Run Keyword And Ignore Error    Additional check in TC Common TS
