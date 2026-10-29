*** Settings ***
Documentation   PM Verification for feature CB014009 Buffer-based step-wise NR FR1 SCell addition \n
...             Team: I_MN_RAN_RD_VRF_ULM_VT2 \n
...             Author: Antje Jooss
...             Email: i_mn_ran_rd_vrf_ulm_vt2@internal.nsn.com \n
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    OperatingSystem

Resource    ../../resources/Common/pmcounters.robot


*** Keywords ***

Fetch And Rename PM Counter Dirs
    [Documentation]     Fetch and Verify all new CB014009 and legacy PM counters
    [Arguments]    ${gnb_id}    ${PM_Part}

#    Log To Console    PMcounters: Wait next Measurement Period Stops.
#    pmcounters.Wait until the current Measurement Period stops    gnb_id=${gnb_id}
    Log To Console  Stop PM Counter collection
    ${PMCounters_dir_Part}=    Fetch All PM Counter Values  gnb_id=${gnb_id}  PM_Part=${PM_Part}
    RETURN    ${PMCounters_dir_Part}

Verify PM Counters CB014009_TC01
    Log To Console    \nVerify the CB014009_TC01 PM Counters:

    ${status_PM_Counter_Part1}=    Run Keyword And Return Status    CB014009_PMverification.Verify PM Counters CB014009_TC01_Part1
    ...    PMCounters_dir=${PMCOUNTERS_DIR_PART1}
    ${status_PM_Counter_Part2}=    Run Keyword And Return Status    CB014009_PMverification.Verify PM Counters CB014009_TC01_Part2
    ...    PMCounters_dir=${PMCOUNTERS_DIR_PART2}
    ${status_PM_Counter_Part3}=    Run Keyword And Return Status    CB014009_PMverification.Verify PM Counters CB014009_TC01_Part3
    ...    PMCounters_dir=${PMCOUNTERS_DIR_PART3}

    Log To Console    \nStatus PM Counter Verification Part 1: ${status_PM_Counter_Part1}
    Log To Console    \nStatus PM Counter Verification Part 2: ${status_PM_Counter_Part2}
    Log To Console    \nStatus PM Counter Verification Part 3: ${status_PM_Counter_Part3}

    IF    ${status_PM_Counter_Part1} and ${status_PM_Counter_Part2} and ${status_PM_Counter_Part3}
        Set Test Variable    ${status_PM_Counters}    ${True}
    ELSE
        Set Test Variable    ${status_PM_Counters}    ${False}
    END

    Log To Console    \nStatus Verification PM Counters: ${status_PM_Counters}


Verify PM Counters CB014009_TC01_Part1
    [Arguments]    ${PMCounters_dir}

    ${reference_table}    Create List
    ...      (NRCELL-1)M55118C00032  ==  8      Number of SCells added via A1
    ...      (NRCELL-1)M55118C11106  ==  3      Stepwise SCell addition attempts DL
    ...      (NRCELL-1)M55118C11107  ==  3      Successful Stepwise SCell additions DL
    ...      (NRCELL-1)M55118C11108  ==  0      UL stepwise attempt
    ...      (NRCELL-1)M55118C11109  ==  0      UL stepwise success
    ...      (TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3)M51322C0  >  0       UL Throughput Counter IN
    ...      (TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3)M51322C2  >  0       UL Throughput Counter OUT

    pmcounters.Verify PM Counter Reference Table   reference_table=${reference_table}  pm_dir=${PMCounters_dir}


Verify PM Counters CB014009_TC01_Part2
    [Arguments]    ${PMCounters_dir}

    ${reference_table}    Create List
    ...      (NRCELL-1)M55118C00032  ==  7      Number of SCells added via A1
    ...      (NRCELL-1)M55118C11106  ==  3      Stepwise SCell addition attempts DL
    ...      (NRCELL-1)M55118C11107  ==  3      Successful Stepwise SCell additions DL
    ...      (NRCELL-1)M55118C11108  ==  0      UL stepwise attempt
    ...      (NRCELL-1)M55118C11109  ==  0      UL stepwise success
    ...      (TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3)M51322C0  >  0       UL Throughput Counter IN
    ...      (TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3)M51322C2  >  0       UL Throughput Counter OUT

    pmcounters.Verify PM Counter Reference Table   reference_table=${reference_table}  pm_dir=${PMCounters_dir}


Verify PM Counters CB014009_TC01_Part3
    [Arguments]    ${PMCounters_dir}

    ${reference_table}    Create List
    ...      (NRCELL-1)M55118C00032  ==  6      Number of SCells added via A1
    ...      (NRCELL-1)M55118C11106  ==  3      Stepwise SCell addition attempts DL
    ...      (NRCELL-1)M55118C11107  ==  3      Successful Stepwise SCell additions DL
    ...      (NRCELL-1)M55118C11108  ==  1      UL stepwise attempt
    ...      (NRCELL-1)M55118C11109  ==  1      UL stepwise success
    ...      (TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3)M51322C0  >  0        UL Throughput Counter IN
    ...      (TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3)M51322C2  >  0        UL Throughput Counter OUT

    pmcounters.Verify PM Counter Reference Table   reference_table=${reference_table}  pm_dir=${PMCounters_dir}

######################################################################################################################################################

Verify PM Counters CB014009_TC02
    Log To Console    \nVerify the CB014009_TC02 PM Counters:

    ${status_PM_Counter_Part1}=    Run Keyword And Return Status    CB014009_PMverification.Verify PM Counters CB014009_TC02_Part1
    ...    PMCounters_dir=${PMCOUNTERS_DIR_PART1}
    ${status_PM_Counter_Part2}=    Run Keyword And Return Status    CB014009_PMverification.Verify PM Counters CB014009_TC02_Part2
    ...    PMCounters_dir=${PMCOUNTERS_DIR_PART2}
    ${status_PM_Counter_Part3}=    Run Keyword And Return Status    CB014009_PMverification.Verify PM Counters CB014009_TC02_Part3
    ...    PMCounters_dir=${PMCOUNTERS_DIR_PART3}

    Log To Console    \nStatus PM Counter Verification Part 1: ${status_PM_Counter_Part1}
    Log To Console    \nStatus PM Counter Verification Part 2: ${status_PM_Counter_Part2}
    Log To Console    \nStatus PM Counter Verification Part 3: ${status_PM_Counter_Part3}

    IF    ${status_PM_Counter_Part1} and ${status_PM_Counter_Part2} and ${status_PM_Counter_Part3}
        Set Test Variable    ${status_PM_Counters}    ${True}
    ELSE
        Set Test Variable    ${status_PM_Counters}    ${False}
    END

    Log To Console    \nStatus Verification PM Counters: ${status_PM_Counters}


Verify PM Counters CB014009_TC02_Part1
    [Arguments]    ${PMCounters_dir}

    ${reference_table}    Create List
    ...      (NRCELL-4)M55118C11106  >  0      Stepwise SCell addition attempts DL
    ...      (NRCELL-4)M55118C11107  >  0      Successful Stepwise SCell additions DL
    ...      (NRCELL-4)M55118C11108  ==  0      Stepwise SCell addition attempts UL
    ...      (NRCELL-4)M55118C11109  ==  0      Successful Stepwise SCell additions UL
    ...      (TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3)M51322C0  >  0       UL Throughput Counter IN
    ...      (TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3)M51322C2  >  0       UL Throughput Counter OUT

    pmcounters.Verify PM Counter Reference Table   reference_table=${reference_table}  pm_dir=${PMCounters_dir}


Verify PM Counters CB014009_TC02_Part2
    [Arguments]    ${PMCounters_dir}

    ${reference_table}    Create List
    ...      (NRCELL-4)M55118C11106  >  0      Stepwise SCell addition attempts DL
    ...      (NRCELL-4)M55118C11107  >  0      Successful Stepwise SCell additions DL
    ...      (NRCELL-4)M55118C11108  ==  0      Stepwise SCell addition attempts UL
    ...      (NRCELL-4)M55118C11109  ==  0      Successful Stepwise SCell additions UL
    ...      (TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3)M51322C0  >  0       UL Throughput Counter IN
    ...      (TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3)M51322C2  >  0       UL Throughput Counter OUT

    pmcounters.Verify PM Counter Reference Table   reference_table=${reference_table}  pm_dir=${PMCounters_dir}

Verify PM Counters CB014009_TC02_Part3
    [Arguments]    ${PMCounters_dir}

    ${reference_table}    Create List
    ...      (NRCELL-4)M55118C11106  >  0      Stepwise SCell addition attempts DL
    ...      (NRCELL-4)M55118C11107  >  0      Successful Stepwise SCell additions DL
    ...      (NRCELL-4)M55118C11108  >  0      Stepwise SCell addition attempts UL
    ...      (NRCELL-4)M55118C11109  >  0      Successful Stepwise SCell additions UL
    ...      (TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3)M51322C0  >  0        UL Throughput Counter IN
    ...      (TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3)M51322C2  >  0        UL Throughput Counter OUT

    pmcounters.Verify PM Counter Reference Table   reference_table=${reference_table}  pm_dir=${PMCounters_dir}


Fetch All PM Counter Values
    [Documentation]     This KW collects all PM counters and returns the directory, where they are stored.
    [Arguments]  ${gnb_id}  ${PM_Part}
    Log To Console    \n"PMcounters: Wait next Measurement Period Stops."
    pmcounters.Wait Until The Current Measurement Period Stops    gnb_id=${gnb_id}
    ${PMCounters_dir}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id}
    OperatingSystem.Move Directory    ${PMCounters_dir}  ${PMCounters_dir}_${PM_Part}
    RETURN    ${PMCounters_dir}_${PM_Part}

######################################################################################################################################################

Verify PM Counters CB014009_TC03
    Run Keyword And Warn On Failure  CB014009_PMverification.Verify PM Counters CB014009_TC03_Part_2  PMCounters_dir=${PMCounters_dir_Part2}
    Run Keyword And Warn On Failure  CB014009_PMverification.Verify PM Counters CB014009_TC03_Part_3  PMCounters_dir=${PMCounters_dir_Part3}
    Run Keyword And Warn On Failure  CB014009_PMverification.Verify PM Counters CB014009_TC03_Part_4  PMCounters_dir=${PMCounters_dir_Part4}


Verify PM Counters CB014009_TC03_Part_2
    [Arguments]    ${PMCounters_dir}
    Log To Console    \nVerify the CB014009_TC03_Part2 PM Counters:

    ${reference_table}    Create List
    ...      (NRCELL-2)M55118C11106  ==  1        DL_RRC_STEP_SCELL_ADD_ATT_SA
    ...      (NRCELL-2)M55118C11107  ==  1        DL_RRC_STEP_SCELL_ADD_SUCC_SA
    ...      (NRCELL-2)M55118C11108  ==  0        UL_RRC_STEP_SCELL_ADD_ATT_SA
    ...      (NRCELL-2)M55118C11109  ==  0        UL_RRC_STEP_SCELL_ADD_SUCC_SA

    ...      (NRCELL-2)M55138C03510  ==  1        GNB_DL_SCELL_1_ADMI_REQ
    ...      (NRCELL-2)M55138C03511  ==  0        GNB_DL_SCELL_2_ADMI_REQ
    ...      (NRCELL-2)M55138C03512  ==  1        GNB_DL_SCELL_3_ADMI_REQ
    ...      (NRCELL-2)M55138C03517  ==  1        GNB_DL_SCELL_1_ADMI_SUCC
    ...      (NRCELL-2)M55138C03518  ==  0        GNB_DL_SCELL_2_ADMI_SUCC
    ...      (NRCELL-2)M55138C03519  ==  1        GNB_DL_SCELL_3_ADMI_SUCC
    ...      (NRCELL-2)M55118C00033  ==  4        BLIND_SCELL_ADDED_SA
    ...      (NRCELL-2)M55139C05502  ==  1        GNB_DU_DL_SCELL_1_ADMI_REQ_SA
    ...      (NRCELL-2)M55139C05509  ==  1        GNB_DU_DL_SCELL_1_ADMI_SUCC_SA
    ...      (NRCELL-2)M55139C05503  ==  0        GNB_DU_DL_SCELL_2_ADMI_REQ_SA
    ...      (NRCELL-2)M55139C05510  ==  0        GNB_DU_DL_SCELL_2_ADMI_SUCC_SA
    ...      (NRCELL-2)M55139C05504  ==  1        GNB_DU_DL_SCELL_3_ADMI_REQ_SA
    ...      (NRCELL-2)M55139C05511  ==  1        GNB_DU_DL_SCELL_3_ADMI_SUCC_SA
    ...      (NRCELL-2)M55139C05505  ==  1        RRC_RECONF_ADD1DLSCELL_ATT_SA
    ...      (NRCELL-2)M55139C05506  ==  1        RRC_RECONF_ADD1DLSCELL_SUCC_SA
    ...      (NRCELL-2)M55118C07004  ==  0        RRC_RECONF_ADD2DLSCELL_ATT_SA
    ...      (NRCELL-2)M55118C07003  ==  0        RRC_RECONF_ADD2DLSCELL_SUCC_SA
    ...      (NRCELL-2)M55118C09503  ==  1        RRC_RECONF_ADD3DLSCELL_ATT_SA
    ...      (NRCELL-2)M55118C09502  ==  1        RRC_RECONF_ADD3DLSCELL_SUCC_SA

    pmcounters.Verify PM Counter Reference Table   reference_table=${reference_table}  pm_dir=${PMCounters_dir}


Verify PM Counters CB014009_TC03_Part_3
    [Arguments]    ${PMCounters_dir}
    Log To Console    \nVerify the CB014009_TC03_Part3 PM Counters:

    ${reference_table}    Create List
    ...      (NRCELL-2)M55118C11106  ==  2        DL_RRC_STEP_SCELL_ADD_ATT_SA
    ...      (NRCELL-2)M55118C11107  ==  2        DL_RRC_STEP_SCELL_ADD_SUCC_SA
    ...      (NRCELL-2)M55118C11108  ==  0        UL_RRC_STEP_SCELL_ADD_ATT_SA
    ...      (NRCELL-2)M55118C11109  ==  0        UL_RRC_STEP_SCELL_ADD_SUCC_SA

    ...      (NRCELL-2)M55138C03510  ==  2        GNB_DL_SCELL_1_ADMI_REQ
    ...      (NRCELL-2)M55138C03511  ==  0        GNB_DL_SCELL_2_ADMI_REQ
    ...      (NRCELL-2)M55138C03512  ==  0        GNB_DL_SCELL_3_ADMI_REQ
    ...      (NRCELL-2)M55138C03517  ==  2        GNB_DL_SCELL_1_ADMI_SUCC
    ...      (NRCELL-2)M55138C03518  ==  0        GNB_DL_SCELL_2_ADMI_SUCC
    ...      (NRCELL-2)M55138C03519  ==  0        GNB_DL_SCELL_3_ADMI_SUCC
    ...      (NRCELL-2)M55118C00033  ==  2        BLIND_SCELL_ADDED_SA
    ...      (NRCELL-2)M55139C05502  ==  2        GNB_DU_DL_SCELL_1_ADMI_REQ_SA
    ...      (NRCELL-2)M55139C05509  ==  2        GNB_DU_DL_SCELL_1_ADMI_SUCC_SA
    ...      (NRCELL-2)M55139C05503  ==  0        GNB_DU_DL_SCELL_2_ADMI_REQ_SA
    ...      (NRCELL-2)M55139C05510  ==  0        GNB_DU_DL_SCELL_2_ADMI_SUCC_SA
    ...      (NRCELL-2)M55139C05504  ==  0        GNB_DU_DL_SCELL_3_ADMI_REQ_SA
    ...      (NRCELL-2)M55139C05511  ==  0        GNB_DU_DL_SCELL_3_ADMI_SUCC_SA
    ...      (NRCELL-2)M55139C05505  ==  2        RRC_RECONF_ADD1DLSCELL_ATT_SA
    ...      (NRCELL-2)M55139C05506  ==  2        RRC_RECONF_ADD1DLSCELL_SUCC_SA
    ...      (NRCELL-2)M55118C07004  ==  0        RRC_RECONF_ADD2DLSCELL_ATT_SA
    ...      (NRCELL-2)M55118C07003  ==  0        RRC_RECONF_ADD2DLSCELL_SUCC_SA
    ...      (NRCELL-2)M55118C09503  ==  0        RRC_RECONF_ADD3DLSCELL_ATT_SA
    ...      (NRCELL-2)M55118C09502  ==  0        RRC_RECONF_ADD3DLSCELL_SUCC_SA

    pmcounters.Verify PM Counter Reference Table   reference_table=${reference_table}  pm_dir=${PMCounters_dir}


Verify PM Counters CB014009_TC03_Part_4
    [Arguments]    ${PMCounters_dir}
    Log To Console    \nVerify the CB014009_TC03_Part4 PM Counters:

    ${reference_table}    Create List
    ...      (NRCELL-2)M55118C11106  ==  0        DL_RRC_STEP_SCELL_ADD_ATT_SA
    ...      (NRCELL-2)M55118C11107  ==  0        DL_RRC_STEP_SCELL_ADD_SUCC_SA
    ...      (NRCELL-2)M55118C11108  ==  0        UL_RRC_STEP_SCELL_ADD_ATT_SA
    ...      (NRCELL-2)M55118C11109  ==  0        UL_RRC_STEP_SCELL_ADD_SUCC_SA

    ...      (NRCELL-2)M55138C03510  ==  0        GNB_DL_SCELL_1_ADMI_REQ
    ...      (NRCELL-2)M55138C03511  ==  0        GNB_DL_SCELL_2_ADMI_REQ
    ...      (NRCELL-2)M55138C03512  ==  1        GNB_DL_SCELL_3_ADMI_REQ
    ...      (NRCELL-2)M55138C03517  ==  0        GNB_DL_SCELL_1_ADMI_SUCC
    ...      (NRCELL-2)M55138C03518  ==  0        GNB_DL_SCELL_2_ADMI_SUCC
    ...      (NRCELL-2)M55138C03519  ==  1        GNB_DL_SCELL_3_ADMI_SUCC
    ...      (NRCELL-2)M55118C00033  ==  3        BLIND_SCELL_ADDED_SA
    ...      (NRCELL-2)M55139C05502  ==  0        GNB_DU_DL_SCELL_1_ADMI_REQ_SA
    ...      (NRCELL-2)M55139C05509  ==  0        GNB_DU_DL_SCELL_1_ADMI_SUCC_SA
    ...      (NRCELL-2)M55139C05503  ==  0        GNB_DU_DL_SCELL_2_ADMI_REQ_SA
    ...      (NRCELL-2)M55139C05510  ==  0        GNB_DU_DL_SCELL_2_ADMI_SUCC_SA
    ...      (NRCELL-2)M55139C05504  ==  1        GNB_DU_DL_SCELL_3_ADMI_REQ_SA
    ...      (NRCELL-2)M55139C05511  ==  1        GNB_DU_DL_SCELL_3_ADMI_SUCC_SA
    ...      (NRCELL-2)M55139C05505  ==  0        RRC_RECONF_ADD1DLSCELL_ATT_SA
    ...      (NRCELL-2)M55139C05506  ==  0        RRC_RECONF_ADD1DLSCELL_SUCC_SA
    ...      (NRCELL-2)M55118C07004  ==  0        RRC_RECONF_ADD2DLSCELL_ATT_SA
    ...      (NRCELL-2)M55118C07003  ==  0        RRC_RECONF_ADD2DLSCELL_SUCC_SA
    ...      (NRCELL-2)M55118C09503  ==  1        RRC_RECONF_ADD3DLSCELL_ATT_SA
    ...      (NRCELL-2)M55118C09502  ==  1        RRC_RECONF_ADD3DLSCELL_SUCC_SA

    pmcounters.Verify PM Counter Reference Table   reference_table=${reference_table}  pm_dir=${PMCounters_dir}