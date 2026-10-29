*** Settings ***
Documentation
...    Author: Zaharia Andreea-Oana (andreea-oana.zaharia@nokia.com)
...    Maintainer: Zaharia Andreea-Oana (andreea-oana.zaharia@nokia.com)
...    Group in charge: BTS_OAM_VERIF
...    References: doors
...    Feature Description: CB007257
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB007257/general.robot

Library         String
Library         Telnet
Library         OperatingSystem
Library         Process
Library         SSHLibrary
Library         ute_async
Library         collections
Library         XML  lxml=True
Library         ute_admin_infomodel

Resource    ../../resources/admin.robot
Resource    ../../resources/admin_infomodel.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot

Resource    ../../resources/fault_trigger.robot
Resource    ../../resources/AirPhone/resources/ute/coam.robot
Resource    ../../resources/AirPhone/resources/ute/ute_wts_runner.robot


*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

*** Variables ***
${dist_name}=                MRBTS-1/NRBTS-1/NRCELL-1
${activate_kpi_alarms}=      MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1

${Delta_error_syntax_NR_CELL_PLAN_UNAVAIL_CHNG_TO}=      ${CURDIR}/error_syntax_CELL_PLAN_UNAVAIL_CHNG_TO.json
${Delta_error_syntax_F1_DU_CU_CNF_UPD_FL_OTH0}=          ${CURDIR}/error_syntax_F1_DU_CU_CNF_UPD_FL_OTH0.json
${Delta_timeToTrigger0_4570fault}=                       ${CURDIR}/timeToTrigger0_4570fault.json
${Delta_default}=                                        ${CURDIR}/default.json

*** Keywords ***
Classical_Robustness Check syntax error for validation of KPI formula by using misspelt NetAct Name of supported counter
    log to console     start TC1
    run keyword and expect error  *Syntax error in triggeringFormula: $NR_CELL_PLAN_UNAVAIL_CHNG_TO*  ADMIN Perform Delta Recommissioning
    ...             delta_file=${Delta_error_syntax_NR_CELL_PLAN_UNAVAIL_CHNG_TO}
    ...             skip_parameter_relation_errors=True
    Wait Until Keyword Succeeds   600    10    ADMIN INFOMODEL Check If BTS Is Configured

Classical_Check_syntax_error_for_validation_of_KPI_formula_by_using_LNCEL_or_LNBTS_unsupported_counters_for_Cloud_BTS
    log to console     start TC2
    run keyword and expect error  *Unsupported counters in triggeringFormula: F1_DU_CU_CNF_UPD_FL_OTH == 0*  ADMIN Perform Delta Recommissioning
    ...             delta_file=${Delta_error_syntax_F1_DU_CU_CNF_UPD_FL_OTH0}
    ...             skip_parameter_relation_errors=True
    Wait Until Keyword Succeeds   600    10    ADMIN INFOMODEL Check If BTS Is Configured

Classical_Check_that_KPI_triggered_alarm_is_raised_on_NRBTS_MO
    log to console     start TC3
    ADMIN Perform Delta Recommissioning
    ...             delta_file=${Delta_timeToTrigger0_4570fault}
    ...             skip_parameter_relation_errors=True
    ADMIN Lock Cell   ${dist_name}
    sleep  15
    ADMIN Check If Alarm Is Active With Timeout  fault_id=49  timeout=15
    ADMIN Check If Alarm Is Active With Timeout  fault_id=4570  timeout=100
    sleep  80
    ADMIN Unlock Cell   ${dist_name}
    ADMIN Check If Alarm Is Not Active With Timeout  fault_id=49  timeout=15
    ADMIN Check If Alarm Is Not Active With Timeout  fault_id=4570  timeout=15
    Wait Until Keyword Succeeds   600    10    ADMIN INFOMODEL Check If BTS Is Configured
    ADMIN Perform Delta Recommissioning
    ...             delta_file=${Delta_default}
    ...             skip_parameter_relation_errors=True




