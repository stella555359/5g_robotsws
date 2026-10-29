*** Settings ***
Documentation
...  Author: Mikolaj Guszpit, Jaroslaw Wojczyszyn
...  Contact: mikolaj.guszpit@nokia.com, jaroslaw.wojczyszyn@nokia.com
...  Maintainer: mikolaj.guszpit@nokia.com, jaroslaw.wojczyszyn@nokia.com
...  Description: Rewrite some code to align to 7_16_UTE5GCLOUDT177 Test Line -> Pawel Wisniewski

Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB006877/resources/keywords.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/multi_ue.robot

*** Variables ***
@{ues}  ue1
${tput_time}  180s

*** Keywords ***
[1]CB006877_A#1_TC_02_Long_PUCCH_for_FDD_Cells_and_CB006877_1_UE_35MHz_CPRI_counter
    # PREP
    detach ues from cell  ${ues}
    Deactivate CB006877 and set counter interval

    # Step1
    Wait for M55308C10004 M55308C10002 counters
    ${m02_ft_off_data_off}  Get M55308C10002 counter
    ${m04_ft_off_data_off}  Get M55308C10004 counter

    #  100 value is hardcoded due to spontaneous second ue attach.
    check_counters_are_less_than_number  ${m02_ft_off_data_off}  500

    # Step 2
    Attach ues to cell  ${ues}
    Start ULDL for UEs  ${ues}  duration=${tput_time}  protocol=tcp

    # Step 3
    Wait for M55308C10004 M55308C10002 counters
    Stop all datatransfers
    Detach ues from cell  ${ues}
    ${m02_ft_off_data_on}  Get M55308C10002 counter
    check counters are greater than zero  ${m02_ft_off_data_on}
    ${m04_ft_off_data_on}  Get M55308C10004 counter
    compare_counters_ratio  ${m04_ft_off_data_off}  ${m04_ft_off_data_on}

    # Step 4
    Wait for M55308C10004 M55308C10002 counters
    Wait for M55308C10004 M55308C10002 counters

    # Step 5
    Feature CB006877 activation
    Wait for M55308C10004 M55308C10002 counters
    ${m02_ft_on_data_off}  Get M55308C10002 counter
    ${m02_ft_on_data_off}  Get M55308C10004 counter

    # Step 6
    attach ues to cell  ${ues}

    # Step 7
    Start ULDL for UEs  ${ues}  duration=${tput_time}  protocol=tcp

    # Step 8
    Wait for M55308C10004 M55308C10002 counters
    Stop all datatransfers
    ${m02_ft_on_data_on}  Get M55308C10002 counter
    check_counters_are_greater_than_zero  ${m02_ft_on_data_on}
    ${m04_ft_on_data_on}  Get M55308C10004 counter
    ${m04_step_8}  extract_value_from_counter  ${m04_ft_on_data_on}
    ${m04_step_1}  extract_value_from_counter  ${m04_ft_off_data_off}
    should be true  ${m04_step_8} > ${m04_step_1}


[1]CB006877_A#7_TC_16_SA_PRBblanking_LowEdgeUL_35MHz
    # PREP
    detach ues from cell  ${ues}
    Deactivate CB006877 and set counter interval
    Feature CB006877 activation

    # Step 2
    Attach ues to cell  ${ues}

    # Step 3
    Start UL for UEs  ${ues}  duration=${tput_time}  protocol=tcp
    ${avg_tput_ft_on}  Await datatransfers finish
    run keyword and ignore error  Stop all datatransfers
    detach ues from cell  ${ues}

    # Step 4
    Feature CB006877 deactivation
    Attach ues to cell  ${ues}
    Start UL for UEs  ${ues}  duration=${tput_time}  protocol=tcp
    ${avg_tput_ft_off}  Await datatransfers finish
    run keyword and ignore error  Stop all datatransfers
    detach ues from cell  ${ues}

    compare_tput_avg  ${avg_tput_ft_off[0]}  ${avg_tput_ft_on[0]}



[1]CB006877_A#9_TC_21_SA_FDD_35MHz_CB006137_UL_2CC_CA_F+T
    # PREP
    detach ues from cell  ${ues}
    Deactivate CB006877 and set counter interval
    Feature CB006877 activation

    # Step 2
    Attach ues to cell  ${ues}

    # Step 3
    Start UL for UEs  ${ues}  duration=${tput_time}  protocol=tcp
    ${avg_tput_ft_on}  Await datatransfers finish
    run keyword and ignore error  Stop all datatransfers
    detach ues from cell  ${ues}

    # Step 4
    Feature CB006877 deactivation
    Attach ues to cell  ${ues}
    Start UL for UEs  ${ues}  duration=${tput_time}  protocol=tcp
    ${avg_tput_ft_off}  Await datatransfers finish
    run keyword and ignore error  Stop all datatransfers
    detach ues from cell  ${ues}

    compare_tput_avg_perc  ${avg_tput_ft_off[0]}  ${avg_tput_ft_on[0]}
