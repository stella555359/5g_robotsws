*** Settings ***
Documentation
...    Author:Quanqingjun
...    Contact:qingjun.quan@nokia-sbell.com
...    Group: HGZ_SG6
...    Feature: CB010315

Suite Setup          run keywords    SISO Coam Suite Setup
...    AND    Setup aggressor connection
Suite Teardown       run keywords    SISO Coam Suite Teardown
...    AND    Run Keyword And Ignore Error    Lock aggressor cell via COAM    connection=${connection_aggressor}
...    AND    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection_aggressor}

Test Setup           SISO Coam Test Setup    allowed_faults_ids=7525,7527,7535,7532
Test Teardown        SISO Coam Test Teardown    allowed_faults_ids=7525,7527,7535,7532

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    Resources/CB010315_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot

*** Variables ***
${ri_effect_distance_value}    ${13}
${ri_effect_distance}    distance: 13
${check_rim_cellid}    171905
${ri_detected_state}    RI status:DETECTED
${rs1_detected_state}    RS status:TYPE1
${rs1_rs2_detected_state}    RS status:TYPE1ANDTYPE2

*** Test Cases ***
[1]CB006991_framework0_check
    AlarmWatchdog.add_allow_alarms    fault_id=7525
    AlarmWatchdog.add_allow_alarms    fault_id=7527
    AlarmWatchdog.add_allow_alarms    fault_id=7535
    Commissioning SCF And Check BTS On Air    scf_name=1116_0ms_4gp_6991_aggressor    connection=${connection_aggressor}
    Commissioning SCF And Check BTS On Air    scf_name=1116_0ms_4gp_6991_victim
    CB006991_framework0_check

[1]CB009823_framework1_check
    AlarmWatchdog.add_allow_alarms    fault_id=7525
    AlarmWatchdog.add_allow_alarms    fault_id=7527
    AlarmWatchdog.add_allow_alarms    fault_id=7535
    AlarmWatchdog.add_allow_alarms    fault_id=7532
    Commissioning SCF And Check BTS On Air    scf_name=1116_0ms_4gp_9823_aggressor    connection=${connection_aggressor}
    Commissioning SCF And Check BTS On Air    scf_name=1116_0ms_4gp_9823_victim
    CB009823_framework1_check

[1]CB014133_framework1_check
    AlarmWatchdog.add_allow_alarms    fault_id=7525
    AlarmWatchdog.add_allow_alarms    fault_id=7527
    AlarmWatchdog.add_allow_alarms    fault_id=7535
    AlarmWatchdog.add_allow_alarms    fault_id=7532
    Commissioning SCF And Check BTS On Air    scf_name=1116_0ms_4gp_14133_aggressor    connection=${connection_aggressor}
    Commissioning SCF And Check BTS On Air    scf_name=1116_0ms_4gp_14133_victim
    CB014133_framework1_check