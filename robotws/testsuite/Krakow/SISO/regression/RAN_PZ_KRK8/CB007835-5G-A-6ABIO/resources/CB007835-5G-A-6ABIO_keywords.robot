*** Settings ***
Documentation
...   Keywords for test suite for regression testing of feature CB007835-A
...   author: Mateusz Iwankiewicz
...   contact: mateusz.iwankiewicz@nokia.com

Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.rfrl.bts.devices.ru.ru_serial_logs_collector.GnbRuSerialLogsCollector
...          WITH NAME    gnb_ru_lmi
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    variables.py

*** Variables ***
############### OAM and UUF #########################
@{CUSTOMERS_LIST}              TMO US
${QC_DOMAIN}                   MN_RAN
${QC_PROJECT}                  RAN_VRF
${TOPOLOGY}                    CLOUD_7_7_T8SK111
${SCOUT_NAME}                  7_7_UTE5GCLOUDT8SK111
${runs_of_uuf_reset}           ${30}
${runs_of_activation_reset}    ${20}
${runs_of_uuf_upgrade}         ${5}
${runs_of_ru_reset}            ${20}
${runs_of_bb_reset}            ${10}
${test_iteration}              ${5}
${SOURCE_SW}                   ${None}
${TARGET_SW}                   ${None}
@{CUSTOM_ALARMS}               7308  7319  4125  4405  4153  4452  1898  4123  4298
@{CRITICAL_ALARMS}             0010  0016  1806  1868  4341  4352  4383
@{IGNORED_PRINTS}              is not defined in SysinfoQuota.xml. Please contact the owner
${SHOULD_BE_REPORTED}          ${True}

&{NODE1}                       testline_object=${tl.gnbs[0]}
...                            secondary_vm=10.84.129.61
...                            source_sw=${SOURCE_SW}
...                            target_sw=${TARGET_SW}
...                            custom_allowed_alarms=@{CUSTOM_ALARMS}
...                            testline_scout_name=${SCOUT_NAME}
...                            critical_alarms=@{CRITICAL_ALARMS}
...                            syslog_ignored_prints=${IGNORED_PRINTS}

@{NODES}                       ${NODE1}

${RP_CA}                       VRF_RRM
${RP_ORGANIZATION}             VRF_KRK_T08
${RP_LOCATION}                 VRF_KRK

*** Keywords ***
Test Suite Setup
    Log to console   \n********************************************
    Log to console   \n---- Start Suite Setup ----\n
    Log to console   \n---- Perform Commissioning on gNB and Wait for onAir ----\n
    Common Suite Setup With OnAir Test Line Preparation    prefix_tag=8CC
    ...              incompatible_error_timer=900
    ...              increase_timeout_for_update_sw=900
    ...              increase_time_for_checking_cells=600
    ...              swconfig_from_path=commissionings/Krakow/7_7_UTE5GCLOUDT8SK111/swconfig.txt
    gnb_ru_lmi.Setup Hosts For All RU Console Collection
    Log to console   \n---- Wait for cells to be onair... ----\n
    Log to console   \n---- Suite Setup Finished! ----\n
    Log to console   \n********************************************

Test Suite Teardown
    Log to console   \n********************************************
    Log to console   \n--Start Suite Teardown--\n
    Common Suite Teardown
    Run Keyword and Ignore Error    gnb_ru_lmi.Teardown Hosts For All RU Console Collection
    Log to console   \n--Suite Teardown DONE--\n
    Log to console   \n********************************************

Test Setup
    Log to console   \n-- Start Test Setup --\n
    Common Preconditions With Watching Alarms
    Wait until keyword succeeds      600 sec    15 sec     Verify Setup Of All Cells
    gnb_ru_lmi.Setup Serial Console Connection for All RUs
    ...    raise_exception=${True}
    Log to console   \n-- Test Setup Finished! --\n

Test Teardown
    Log to console     \n--Start Test Teardown--\n
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    gnb_ru_lmi.Collect Snapshot From all Setup RUs
    gnb_ru_lmi.Collect Console Log From all Setup RUs
    gnb_ru_lmi.Teardown Serial Console Connection for All Setup RUs
    Log to console     \n--Test Teardown DONE--\n
