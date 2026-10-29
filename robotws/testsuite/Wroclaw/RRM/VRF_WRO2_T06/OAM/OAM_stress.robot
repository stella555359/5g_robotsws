*** Settings ***
Documentation   :copyright: Nokia
...             :authors: RAN VRF WRO2 T06

Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/keywords.robot
Resource       testsuite/Wroclaw/RRM/WRO_2/keywords/logging.robot
Library        taf/rfrl/csv4all/CSV4AllTestCases.py
Library        testsuite/Wroclaw/RRM/resources/csv4all_helpers.py

Suite Setup        Run Keywords
...                Set VM Ethernet Interfaces for Simulated Core Network
...    AND         Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         With Simulator Configuration    config=${basic_setup}

Test Teardown    Run Keyword and continue on failure    Find Suspicious Prints In Passed Test

*** Variables ***
${basic_setup}=             /opt/wts/latest/basic_setup.cfg

${RP_CA}                    VRF_OAM

${RP_LOCATION}              VRF_WRO2

${RP_ORGANIZATION}          VRF_WRO2_T06

${EMAIL_RECIPIENTS}         edyta.rudnik@nokia.com

# Software versions used in node definitions
${INITIAL_SW}               SBTS00_ENB_9999_250601_000004
${TARGET_SW}                SBTS00_ENB_9999_250603_000005

# Test iteration count used in keyword call
${ITERATIONS}               20

&{airphone_details}=        hostname=10.42.189.13    username=ute    password=ute

&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}
...                         airphone_details=${airphone_details}

@{CUSTOM_ALLOWED}           4655  61649  61652  4654  61524  4681  4592  1936  8150  62001
@{NODES}                    ${NODE1}
${NR_RAT_RESET_DELTA}=      ${CURDIR}/delta_files/delta_nr_rat_reset.json
${NR_RAT_RESET_DELTA_BACK}=      ${CURDIR}/delta_files/delta_nr_rat_reset_back.json

*** Test Cases ***
Setup Links
    Run Keyword And Continue On Failure    Setup X2 Link
    Run Keyword And Continue On Failure    Setup Xn Link

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
        ...      customers_list=TMO US
        ...      stop_test_after_fail=True

E2E_TL_Capacity_Module_Lock_Unlock
    [Timeout]   24h
    E2E TL CAPACITY MODULE LOCK UNLOCK    ${NODES}  ${NODE1}  ${ITERATIONS}
        ...      customers_list=TMO US
        ...      stop_test_after_fail=True

E2E_TL_Delta_Commissioning_With_Nr_Rat_Reset
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET    ${NODES}  ${NODE1}  ${ITERATIONS}
        ...      customers_list=TMO US
        ...      delta=${NR_RAT_RESET_DELTA}
        ...      stop_test_after_fail=True

E2E_TL_Site_Reset_With_OAM_KPI
    [Timeout]   24h
        E2E TL SITE RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
        ...      customers_list=TMO US
        ...      stop_test_after_fail=True

