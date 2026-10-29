*** Settings ***
Documentation
...             author: Damian Zak
...             maintainer: Damian Zak, Matuesz Iwankiewicz
...             contact: damian.zak@nokia.com, mateusz.iwankiewicz@nokia.com
...             description: Common resources for OAM KPI KRK8

Library         taf.sw.reporting_portal
Library         taf.rfrl.bts.commissioning                                          WITH NAME    commissioning
Library         taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner
Library         taf.rfrl.common_resources.oam_kpi.report_oam_kpi
Library         ./common_resources.py    WITH NAME    lr
Library         taf.rfrl.bts.devices.ru.ru_serial_logs_collector.GnbRuSerialLogsCollector
...             WITH NAME    gnb_ru_lmi
Resource        taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource        taf/rfrl/bts/robot/common/gnb_log.robot
Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource        taf/rfrl/uuf4all/uuf4all_keywords.robot
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
@{CUSTOM_ALLOWED_ALARMS}    Fault signature for crash or failure
...                         BTS Reset Cause
...                         No X2 link available
...                         No X2 link available for a specific LTEENB


*** Keywords ***
OAM KPI Suite Setup
    commissioning.Upload Swconfig On Classical Gnb
    ...    sw_config_path=commissionings/Krakow/7_7_UTE5GCLOUDT1SK043/swconfig.txt
    ...    reboot_after_upload=${True}
    Wait until keyword succeeds    1200 sec    30 sec     Verify BBMOD Online Status
    Log to console   \n---- SWconfig has been uploaded ----\n
    Collect Snapshot From gNB    log_dir=${OUTPUT_DIR}/${SUITE_NAME}
    Log to console   \n---- Snapshot has been collected ----\n
    Common Suite Setup With OnAir Test Line Preparation
    ...    prefix_tag=OAM_KPI_mmW
    ...    increase_time_for_checking_bbmod=600
    ...    increase_timeout_for_update_sw=1800
    ...    increase_time_for_checking_radios=2100
    ...    increase_time_for_checking_cells=700
    ...    list_of_additional_allowed_alarms=@{CUSTOM_ALLOWED_ALARMS}
    gnb_ru_lmi.Setup Hosts For All RU Console Collection
    Set HW Release Target KPI

OAM KPI Test Teardown
    Report Reference Configuration ID
    Common Postconditions
    gnb_ru_lmi.Collect Snapshot From all Setup RUs
    gnb_ru_lmi.Collect Console Log From all Setup RUs
    gnb_ru_lmi.Teardown Serial Console Connection for All Setup RUs
    Set Suite Variable    ${${TEST NAME}_TEST_STATUS}    ${TEST_STATUS}

OAM KPI Test Setup
    Common Preconditions
    gnb_ru_lmi.Setup Serial Console Connection for All RUs
    ...    raise_exception=${True}

OAM KPI Suite Teardown
    Common Suite Teardown
    Run Keyword and Ignore Error    gnb_ru_lmi.Teardown Hosts For All RU Console Collection

Map SW Build From UTE
    ${5G_SOURCE_SW}=    run keyword if  '${5G_SOURCE_SW}'=='${None}'  Get Source SW
    ...   ELSE  set variable  ${5G_SOURCE_SW}
    ${5G_TARGET_SW}=    run keyword if  '${5G_TARGET_SW}'=='${None}'  Get Target SW
    ...   ELSE  set variable  ${5G_TARGET_SW}
