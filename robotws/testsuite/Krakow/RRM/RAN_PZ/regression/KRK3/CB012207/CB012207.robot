*** Settings ***
Documentation
...   Test suite for executing cases for CB012207-B.
...   author: Magda Chrostek
...   contact: magda.chrostek@nokia.com

Force Tags    STATE_SW_UPLOADED    CRT    SBTS00

Library       BuiltIn
Library       taf/rfrl/csv4all/CSV4AllTestCases.py      WITH NAME      CSV4ALL
Library       taf.rfrl.bts.devices.du.pm_counters.GenericPmCounter      WITH NAME      pm
Library       taf.rfrl.bts.commissioning      WITH NAME    commission
Library       testsuite/Krakow/RRM/RAN_PZ/regression/KRK3/CB012207/resources/helpers.py
Resource      taf/rfrl/bts/robot/gnb.robot
Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables     testsuite/Krakow/RRM/RAN_PZ/regression/KRK3/CB012207/resources/variables.py

Suite Setup        Run Keywords
...                TL preparation
...                AND      Common Suite Setup
Suite Teardown      Suite Teardown And Ignore UTE CM Fails

Test Setup          Common Preconditions
Test Teardown       Common Postconditions And Ignore UTE CM Fails

*** Variables ***
&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 custom_allowed_alarms=allowed_alarms
@{NODES}                            ${NODE1}
@{CUSTOM_ALARMS}                    7107        7319        7300        7308    7220
${gnb_id_0}    0
${rmod_id_on_gnb0}    2
@{CUSTOMERS_LIST}                   Generic
${SCOUT_HOSTNAME}                   7_7_UTE5GCLOUDT4SK089

*** Test Cases ***
[1][1.0] CB012207-B-Cit
    Lock Radio Unit on gNB    ${gnb_id_0}    ${rmod_id_on_gnb0}
    Sleep      2min
    helpers.aten power on
    Sleep      2min
    ${result}    helpers.run
    Should Be Equal    ${result}    ${False}
    Unlock Radio Unit on gNB    ${gnb_id_0}    ${rmod_id_on_gnb0}
    Sleep      2min
    ${result}    helpers.verify_serving_cell_info
    Should Be Equal    ${result}    ${True}
    [Teardown]    Run Keywords
    ...           helpers.aten power off

[1][3.0] General_SiSo_stability_with_L3Call
    helpers.aten power on
    FOR      ${i}      IN RANGE      1      5
    helpers.run
    Sleep    5min
    Verify gNB is onAir
    END
    [Teardown]    Run Keywords
    ...           helpers.aten power off

[1][1.0] CB012207-B-UFF4ALL_resets
    [Timeout]    8h
    [Documentation]    Performs 30 site resets in a row and checks if executed with no additional faults.
    CSV4ALL.e2e_tl_site_reset_with_oam_kpi
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${30}
    ...                                     report=${False}

CSV4ALL_RU_LOCK_UNLOCK_TEST
    [Timeout]    8h
    CSV4ALL.E2E TL RU LOCK UNLOCK
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${30}
    ...                                     customers_list=${CUSTOMERS_LIST}

CSV4ALL_RU_RESET_TEST
    [Timeout]    8h
    CSV4ALL.E2E TL RU RESET WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${30}
    ...                                     customers_list=${CUSTOMERS_LIST}

CSV4ALL_NR_CELL_LOCK_UNLOCK_TEST
    [Timeout]    8h
    CSV4ALL.E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${30}
    ...                                     customers_list=${CUSTOMERS_LIST}

CSV4ALL_BBMOD_LOCK_UNLOCK_TEST
    [Timeout]    8h
    CSV4ALL.E2E TL CAPACITY MODULE LOCK UNLOCK
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${30}
    ...                                     customers_list=${CUSTOMERS_LIST}

CSV4ALL_BTS_BLOCK_UNBLOCK_TEST
    [Timeout]    8h
    CSV4ALL.E2E TL BTS BLOCK UNBLOCK
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${30}
    ...                                     customers_list=${CUSTOMERS_LIST}

*** Keywords ***
Suite Setup With OnAir Preparation And Ignore UTE CM Fails
    Run Keyword And Continue On Failure      Ignore fail with sHUB during preparation its expected that sHUB will fail

Suite Teardown And Ignore UTE CM Fails
    Run Keyword And Continue On Failure      Avoid fails with suite teardowns as keyword take suite setup status
    Log to console    Ignore fails triggered by SUITE_SETUP_STATUS variable which is set to FAIL as
    ...               sHUB is failing during preparation due to ASiR PoE Negotiation Failure (expected).

Avoid fails with suite teardowns as keyword take suite setup status
    ${result}      RUN KEYWORD WITH FATAL EXCEPTION HANDLING      Common Suite Teardown

Common Postconditions And Ignore UTE CM Fails
    Run Keyword And Continue On Failure      Avoid fails with test suite teardowns as keyword take suite setup status
    Log to console    Ignore fails triggered by SUITE_SETUP_STATUS variable which is set to FAIL as
    ...               sHUB is failing during preparation due to ASiR PoE Negotiation Failure (expected).

Avoid fails with test suite teardowns as keyword take suite setup status
    ${result}      RUN KEYWORD WITH FATAL EXCEPTION HANDLING      Common Postconditions

TL preparation
    Log to console       TL preparation starts
    power_on_all_hw_in_testline
    Wait to avoid timeout error
    ${release_name}      Get gNB Sw Release Name
    Set Suite Variable      ${release_name}
    commission.Upload swconfig on classical gnb      sw_config_path=testsuite/Krakow/RRM/RAN_PZ/regression/KRK3/CB012207/resources/swconfig.txt
    ${sbts_scf}      Set Variable      commissionings/Krakow/7_7_UTE5GCLOUDT4SK089/${release_name}/GNB0_SCF.xml
    Perform Full Commissioning on gNB      ${sbts_scf}
    Wait to avoid timeout error
    Download and update same SW version
    Wait to avoid timeout error
    Verify gNB is onAir
    Log to console    Ready to go.

Wait to avoid timeout error
    Sleep    10min     #for cells, to avoid timeout error
