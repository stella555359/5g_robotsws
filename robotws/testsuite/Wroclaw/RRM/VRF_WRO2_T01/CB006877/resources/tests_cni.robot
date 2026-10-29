*** Settings ***
Documentation
...  Author: Pawel Wisniewski, Tomasz Brzazgacz(manual tester)
...  Contact: pawel.1.wisniewski@nokia.com
...  Maintainer: pawel.1.wisniewski@nokia.com
...  Description: Test Case implementation for CNI-133487.

Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB006877/resources/keywords.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/multi_ue.robot

*** Variables ***
@{ues}  ue1
${tput_time}  230s

*** Keywords ***
CNI-133487_A1_TC_01_SA_Dynamic_UL_resource_allocation_counters_FT_ON_vs_FT_OFF_15MHz
    # PREP
    Prepare Test Line for CNI-133487

    Wait for M55308C10004 M55308C10002 counters
    ${prb_avail_pusch_off}  Get M55308C10004 counter  target_cell=${TEST_CELL_CNI}

    # Step 1
    Require Ue     ue_alias=ue1  capabilities=IPHONE
    Detach ues from cell  ${ues}
    Attach ues to cell  ${ues}
    Start ULDL for UEs  ${ues}  duration=${tput_time}  protocol=tcp

    # Step 2
    Wait for M55308C10004 M55308C10002 counters
    Stop all datatransfers

    # Step 3
    ${prb_used_pusch_off}  Get M55308C10002 counter  target_cell=${TEST_CELL_CNI}

    # Step  4
    Feature CB006877 activation  target_cell=${TEST_CELL_CNI}

    Wait for M55308C10004 M55308C10002 counters
    ${prb_avail_pusch_on}  Get M55308C10004 counter  target_cell=${TEST_CELL_CNI}

    Detach ues from cell  ${ues}
    Attach ues to cell  ${ues}
    Start ULDL for UEs  ${ues}  duration=${tput_time}  protocol=tcp

    Wait for M55308C10004 M55308C10002 counters
    Stop all datatransfers

    ${prb_avail_pusch_on}  Get M55308C10004 counter  target_cell=${TEST_CELL_CNI}
    ${prb_used_pusch_on}  Get M55308C10002 counter  target_cell=${TEST_CELL_CNI}

    # Postconditions
    Should be true  ${prb_avail_pusch_on['M55308C10004']} > ${prb_avail_pusch_off['M55308C10004']}
    ...  msg=PRB available should be higher after feature activation

    Should be true  (${prb_used_pusch_on['M55308C10002']} / ${prb_avail_pusch_on['M55308C10004']}) <= 1
    ...  msg=The ratio of PRB used to PRB available shall not be above 1 when actDynUlResAlloc is enabled
