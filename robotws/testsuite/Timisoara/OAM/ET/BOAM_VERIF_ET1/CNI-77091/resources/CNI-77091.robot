*** Settings ***
Documentation
...

Library        String
Library        OperatingSystem
Library        Process
Library        taf.gnb.oam.coam.admin
Library        taf.transport.ssh
Library        taf.gnb.oam.coam.admin.interface.admin   WITH NAME   taf_admin

Resource    ./keywords.robot
Resource    ../../resources/admin.robot
Resource    ../../resources/admin_infomodel.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/fault_trigger.robot
Resource    ../../resources/AirPhone/resources/ute/ute_wts_runner.robot

*** Variables ***

${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True
${SW_DESTINATION}     /home/ute

${dist_name_BBMOD-1}=  /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1

*** Keywords ***

Check_Fault_8102

    log to console   Trigger fault 8102 on ABIL
    SYSTEM Check if fault is not in active raw alarm  8102  EFaultId_L1LekaRxStuckAl
    Trigger fault 8102 in RD models
    sleep  3
    log to console   Check L1LekaRxStuckAl fault 8102 is active
    Wait Until Keyword Succeeds    90  3  ADMIN Check If Alarm Is Active  8102

    log to console    Check ABIL Operational state disabled
    Wait Until Keyword Succeeds    60    5    ADMIN INFOMODEL Check OperationalState Value
    ...      dist_name=${dist_name_BBMOD-1}
    ...      value=disabled

    log to console    Check ABIL Operational state	enabled
    Wait Until Keyword Succeeds    300    10    ADMIN INFOMODEL Check OperationalState Value
    ...      dist_name=${dist_name_BBMOD-1}
    ...      value=enabled

    Wait Until Keyword Succeeds    180    10    SYSTEM Check if fault is not in active raw alarm  8102  EFaultId_L1LekaRxStuckAl

Check_Fault_8103

    log to console   Trigger fault 8103 on ABIL
    SYSTEM Check if fault is not in active raw alarm  8103  EFaultId_L1HarqDdr4CalibrationFailureAl
    Trigger fault 8103 in RD models
    sleep  3
    log to console   Check fault 8103 (EFaultId_L1HarqDdr4CalibrationFailureAl)is active
    Wait Until Keyword Succeeds    90  3  ADMIN Check If Alarm Is Active  8103

    ADMIN Reset Site
    Wait Until Keyword Succeeds   300   10   SYSTEM Check if fault is not in active raw alarm  8103  EFaultId_L1HarqDdr4CalibrationFailureAl

Check_Fault_8104

    log to console   Trigger fault 8104 on ABIL
    SYSTEM Check if fault is not in active raw alarm  8104  EFaultId_L1Rp1ReferenceClockFailureAl
    Trigger fault 8104 in RD models
    sleep  3
    log to console   Check fault 8104 (EFaultId_L1Rp1ReferenceClockFailureAl) is active
    Wait Until Keyword Succeeds    90  3  ADMIN Check If Alarm Is Active  8104

    ADMIN Reset Site
    Wait Until Keyword Succeeds   300   10   SYSTEM Check if fault is not in active raw alarm  8104  EFaultId_L1Rp1ReferenceClockFailureAl

Check_Fault_8105

    log to console   Trigger fault 8105 on ABIL
    SYSTEM Check if fault is not in active raw alarm  8105  EFaultId_L1FpgaInitializationFailureAl
    Trigger fault 8105 in RD models
    sleep  3
    log to console   Check fault 8105 (EFaultId_L1FpgaInitializationFailureAl) is active
    Wait Until Keyword Succeeds    90  3  ADMIN Check If Alarm Is Active  8105

    ADMIN Reset Site
    Wait Until Keyword Succeeds   300   10   SYSTEM Check if fault is not in active raw alarm  8105  EFaultId_L1FpgaInitializationFailureAl
