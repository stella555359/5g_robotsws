*** Settings ***
Documentation
...   author: Tomasz Krol, Rafal Kawa
...   contact: tomasz.krol@nokia.com, rafal.kawa@nokia.com
...   description: CRT test suite for CB007564

Library     taf.rfrl.bts.devices.du.cell_operations.EnbCellOperations    WITH NAME      enbcell
Library      taf.rfrl.bts.devices.du.pm_counters.ComparePmCounters     WITH NAME       cpmc
Library      taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME      gnbscf
Library      taf.rfrl.bts.devices.du.commissioning.EnbCommissioning    WITH NAME      enbscf
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter          WITH NAME      gnbcounter
Library      ../resources/MediaTek.py    WITH NAME    mtk
Library      ../resources/EnbOperations.py    WITH NAME    enb
Library     ../resources/GnbPower.py   WITH NAME    gnb_power
Library      ./resources/CustomKeywords.py    WITH NAME    keywords
Library      ./resources/counter_keywords.py

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables    ./resources/deltas.py
Variables    ./resources/variables.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Run Keywords
...               enb.power_on_enb
...               AND  gnb_power.power_on_gnb  bts_id=${1}
...               AND  Perform Full Commissioning On Classical Enb
...               AND  enbcell.wait_for_all_cells_to_be_onair    timeout=${600}
...               AND  enb.set_nr_dc_carrier_frequency  frequency=2071387
...               AND  Perform Full Commissioning on Classical gNB  bts_id=${1}  # Slave gNB commissioning
...               AND  gnb_cells.wait_for_all_cells_to_be_onair  bts_id=${1}  timeout=${600}
...               AND  gnbbbu.upload_swconfig  sw_config_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               AND  Common Suite Setup With Commissioning  # Master gNB commissioning
...               AND  gnb_cells.wait_for_all_cells_to_be_onair  bts_id=${0}  timeout=${600}

Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords
...               Common Preconditions With Watching Alarms
...               AND  gnb_cells.verify_all_cells_are_onair  bts_id=${0}
...               AND  gnb_cells.verify_all_cells_are_onair  bts_id=${1}
...               AND  mtk.reboot

Test Teardown     Common Postconditions With Watching Alarms

*** Variables ***
${REPEAT_COUNT}            2
${MEASUREMENT_INTERVAL}    5min

*** Test Cases ***
CB007564_C_003_CBRA_counters_for_Ue_initial_access
    enbscf.Perform BTS Delta Commissioning    delta=${CBRA_DELTAS['ENB0']}    bts_id=${0}
    gnbscf.Perform BTS Delta Commissioning    delta=${CBRA_DELTAS['GNB0']}    bts_id=${0}
    ${counters_before_attach}    Get CBRA Counters   bts_id=${0}
    #Attach UE to gNB0
    Repeat Keyword    ${REPEAT_COUNT}x    keywords.attach ue with source cell ru rotation    initial_angle=${-20}
    gnbcounter.Wait for Next PM Period    interval=${MEASUREMENT_INTERVAL}    delay=${60}
    ${counters_after_attach}    Get CBRA Counters   bts_id=${0}
    ${diff_counters}          cpmc.Calculate PM Counter Diff    ${counters_before_attach}     ${counters_after_attach}
    Verify that CBRA Counters are Updated   counter_diff_dict=${diff_counters}
    ...                                     cell_ids_to_check=${GNB0_CELLS_TO_CHECK}
    ...                                     expected_diff=${REPEAT_COUNT}

CB007564_C_002_CFRA_counters_for_Ue_access_due_to_successful_HO
    enbscf.Perform BTS Delta Commissioning    delta=${CFRA_DELTAS['ENB0']}    bts_id=${0}
    gnbscf.Perform BTS Delta Commissioning    delta=${CFRA_DELTAS['GNB0']}    bts_id=${0}
    gnbscf.Perform BTS Delta Commissioning    delta=${CFRA_DELTAS['GNB1']}    bts_id=${1}
    ${gnb1_counters_before_HO}      Get CFRA Counters    bts_id=${1}
    #Trigger HO from gNB0 to gNB1
    Repeat Keyword    ${REPEAT_COUNT}x    keywords.attach ue with source cell ru rotation    initial_angle=${30}
    gnbcounter.Wait for Next PM Period    interval=${MEASUREMENT_INTERVAL}    delay=${60}
    ${gnb1_counters_after_HO}      Get CFRA Counters    bts_id=${1}
    ${gnb1_diff_counters}    cpmc.Calculate PM Counter Diff    ${gnb1_counters_before_HO}  ${gnb1_counters_after_HO}
    Run Keyword And Continue On Failure    Verify that CFRA Counters are Updated
    ...                                                                         counter_diff_dict=${gnb1_diff_counters}
    ...                                                                         cell_ids_to_check=${GNB1_CELLS_TO_CHECK}
    ...                                                                         expected_diff=${REPEAT_COUNT}
    [Teardown]    Run Keywords
    ...           enbscf.Perform BTS Delta Commissioning  delta=${DEFAULT_PARAM_DELTAS['ENB0']}  bts_id=${0}
    ...           AND    Common Postconditions With Watching Alarms
