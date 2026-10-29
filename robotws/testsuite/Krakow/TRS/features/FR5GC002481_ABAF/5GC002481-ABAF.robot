*** Settings ***
Documentation
...    author: Jakub Kupiec
...    contact: jakub.kupiec@nokia.com
...    Description: Test Cases 5GC002481-ABAF

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Common Suite Setup With Commissioning
Suite Teardown    Common Suite Teardown
Test Setup        Common Preconditions
Test Teardown     Common Postconditions

*** Variables ***
${default_interval}                   15min
${different_than_default_interval}    30min
${counter_id}                         M55110C00002
${nrbts_id}                           ${tl.gnbs[0].dus[0].instance_id}

*** Test Cases ***
[1][1.0] 5GC002481-ABAF-I&V_5GC000165_Configuration_of_measurement_and_reporting_interval_default
    Verify gNB Cell is onAir     cell_id=2
    Set PM Interval gNB    dist_name=MRBTS-{}/MNL-1/MNLENT-1/PMCADM-1    abbr_group_name=reportingIntervalPm      interval=${default_interval}
    Set PM Interval gNB    dist_name=MRBTS-{}/NRBTS-${nrbts_id}/NRPMRNL-1     abbr_group_name=miNrX2CB      interval=${default_interval}
    gnbcounter.Wait for PM reports generation interval change    expected_interval=${default_interval}    timeout=60min
    gnbcounter.Validate counter interval    counter_id=${counter_id}     expected_interval=${default_interval}    timeout=60min

[1][1.0] 5GC002481-ABAF-I&V_5GC000165_Configuration_of_measurement_and_reporting_interval_different_than_default
    Verify gNB Cell is onAir     cell_id=2
    Set PM Interval gNB    dist_name=MRBTS-{}/MNL-1/MNLENT-1/PMCADM-1    abbr_group_name=reportingIntervalPm
    ...   interval=${different_than_default_interval}
    Set PM Interval gNB    dist_name=MRBTS-{}/NRBTS-${nrbts_id}/NRPMRNL-1     abbr_group_name=miNrX2CB
    ...   interval=${different_than_default_interval}
    gnbcounter.Wait for PM reports generation interval change    expected_interval=${different_than_default_interval}    timeout=90min
    gnbcounter.Validate counter interval    counter_id=${counter_id}     expected_interval=${different_than_default_interval}    timeout=90min
