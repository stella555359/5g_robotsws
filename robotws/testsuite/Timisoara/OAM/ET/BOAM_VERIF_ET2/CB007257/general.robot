*** Settings ***
Documentation
...    Author: Zaharia Andreea-Oana (andreea-oana.zaharia@nokia.com)
...    Maintainer: Zaharia Andreea-Oana (andreea-oana.zaharia@nokia.com)
...    Group in charge: BTS_OAM_VERIF
...    References: doors
...    Feature Description: CB007257
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB007257/general.robot

Resource    ../resources/pretest_posttest.robot
Resource    ./resources/CB007257.robot
Resource    ./../resources/AirPhone/resources/ute/ute_wts_runner.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all   SBTS00
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    CA_RAN_BOAM_VERIF   CA_BTS_OAM_FMRECOV


Suite Setup       Suite Preconditions
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
Classical_Robustness Check syntax error for validation of KPI formula by using misspelt NetAct Name of supported counter
    [Tags]   CRT
    [Documentation]
    ...
    Classical_Robustness Check syntax error for validation of KPI formula by using misspelt NetAct Name of supported counter


Classical_Check_syntax_error_for_validation_of_KPI_formula_by_using_LNCEL_or_LNBTS_unsupported_counters_for_Cloud_BTS
    [Tags]   CRT
    [Documentation]
    ...
    Classical_Check_syntax_error_for_validation_of_KPI_formula_by_using_LNCEL_or_LNBTS_unsupported_counters_for_Cloud_BTS

Classical_Check_that_KPI_triggered_alarm_is_raised_on_NRBTS_MO
    [Tags]   CRT
    [Documentation]
    ...
    Classical_Check_that_KPI_triggered_alarm_is_raised_on_NRBTS_MO
