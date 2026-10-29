*** Settings ***
Documentation
...   Keywords for CB007935
...   author: Przemyslaw Herian
...   contact: przemyslaw.herian@nokia.com

Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Library         keywords.py
Library         taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification        WITH NAME    Alarms
Library         taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter                       WITH NAME    gnbcounter
Library         taf.rfrl.bts.devices.ru.ru_operations.GenericRuOperations              WITH NAME    ru_operations
Library         testsuite/Krakow/resources/UUF/upgrade_and_commission_bts.py

Variables       variables.py
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${downloads_dir}        /home/ute/Downloads
${ASIR_ALLOWED_ALARMS}=    ${EMPTY}
@{additional_allowed_alarms} =  No X2 link available

*** Keywords ***
Suite Setup
    Perform Full Commissioning On Classical gnb    update_timeout=1200
    Run Keyword If    '${ru_type}' == 'asirmod'    Perform Full Commissioning on gNB ASIR hub
    Wait until keyword succeeds      900 sec    15 sec     gnbcell.Verify All Cells Are Onair
    Common Suite Setup

Test Teardown
    Execute Commands On Switch    commands=${synce_restore_commands}
    Execute Commands On Switch    commands=${restore_ptp_sync_commands}
    Execute Commands On Switch    commands=${restore_ssm_commands}
    Common Postconditions

