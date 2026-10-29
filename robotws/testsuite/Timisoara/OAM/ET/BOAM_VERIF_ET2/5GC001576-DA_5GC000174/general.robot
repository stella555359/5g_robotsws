*** Settings ***
Documentation
...    Author: Monika Szlovak
...    Maintainer: Monika Szlovak
...    Test Description: Software management
...    Execution: pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d results/ /home/ute/
...     robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC001576-DA_5GC00174/general.robot
...    Execution: pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d results/ testsuite/WMP/
...     SOAM3/5G/5GC001576-DA/general.robot
...    Dryrun: pybot -t "[TC_01]Activation_for_pre-downloaded_SW" --dryrun --log NONE --report NONE
...     --output NONE -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE testsuite/WMP/SOAM3/5G/
...     5GC001576-DA/general.robot
...    Dryrun: pybot -t "[TC_02]Configuration_backup" --dryrun --log NONE --report NONE --output NONE
...     -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE testsuite/WMP/SOAM3/5G/5GC001576-DA/general.robot
...    Dryrun: pybot -t "[TC_03]Software_download_reject" --dryrun --log NONE --report NONE --output NONE
...     -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE testsuite/WMP/SOAM3/5G/5GC001576-DA/general.robot
...    Dryrun: pybot -t "[TC_04]Stop_software_download" --dryrun --log NONE --report NONE --output NONE
...     -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE testsuite/WMP/SOAM3/5G/5GC001576-DA/general.robot
...    Dryrun: pybot -t "[TC_05]Save_SW_history_report" --dryrun --log NONE --report NONE --output NONE
...     -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE testsuite/WMP/SOAM3/5G/5GC001576-DA/general.robot
...    Dryrun: pybot -t "[TC_06]Save_SW_update_report" --dryrun --log NONE --report NONE --output NONE
...     -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE testsuite/WMP/SOAM3/5G/5GC001576-DA/general.robot
...    Dryrun: pybot -t "[TC_07]Software_rollback" --dryrun --log NONE --report NONE --output NONE -v
...     CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE testsuite/WMP/SOAM3/5G/5GC001576-DA/general.robot
...    AC/REQ: LTE_OPR_AC_3427 / LTE_OPR_REQ_8880;LTE_OPR_REQ_8946;LTE_OPR_REQ_9548
...    AC/REQ: LTE_OPR_AC_3424 / LTE_OPR_REQ_8894
...    AC/REQ: LTE_OPR_AC_3426 / LTE_OPR_REQ_8992
...    AC/REQ: LTE_OPR_AC_3425 / LTE_OPR_REQ_8936
...    AC/REQ: LTE_OPR_AC_3422 / LTE_OPR_REQ_8880
...    AC/REQ: LTE_OPR_AC_3423 / LTE_OPR_REQ_8887
...    AC/REQ: LTE_OPR_AC_3619 / LTE_OPR_REQ_8880;LTE_OPR_REQ_8962


Resource    ./resources/5GC001576-DA_5GC000174.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN     #20Bb1_classicalbts   #master_classicalbts_all
...    CLOUD_5G_I_KL_AP_KL_NSA_FS_CPRI_CMWV_TDD   CLOUD_5G_KL_AP_NSA_FS_CMWV
...    CA_BTS_OAM_FMRECOV    #QCP_BTS_OAM    QCD_MN_BTS_OAM


Suite Setup       run keywords  Suite Preconditions
...               AND           Download SW
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True


*** Test Cases ***
[1.0] Activation_for_pre-downloaded_SW
    [Tags]    CIT
    [Documentation]
    ...
    5GC001576-DA_Activation_for_pre-downloaded_SW


[1.0] Configuration_backup
    [Tags]    CRT
    [Documentation]
    ...
    5GC001576-DA_Configuration_backup


[1.0] Software_download_reject
    [Tags]    CRT
    [Documentation]
    ...
    5GC001576-DA_Software_download_reject


[1.0] Stop_software_download
    [Tags]    CRT
    [Documentation]
    ...
    5GC001576-DA_Stop_software_download


[1.0] Save_SW_history_report
    [Tags]    CRT
    [Documentation]
    ...
    5GC001576-DA_Save_SW_history_report


[1.0] Save_SW_update_report
    [Tags]    CRT
    [Documentation]
    ...
    5GC001576-DA_Save_SW_update_report

[1.0] Software_rollback
    [Tags]    CRT
    [Documentation]
    ...
    5GC001576-DA_Software_rollback

