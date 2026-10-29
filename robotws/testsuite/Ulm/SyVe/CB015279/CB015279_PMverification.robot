*** Settings ***
Documentation   PM Verification for feature CB015279_A_CA_capability_dedicated_mobility_parameters_NSA \n
...             Team: I_MN_RAN_RD_VRF_ULM_VT2 \n
...             Author: Antje Jooss
...             Email: i_mn_ran_rd_vrf_ulm_vt2@internal.nsn.com \n
# ----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    OperatingSystem

Resource    ../../resources/Common/pmcounters.robot


*** Keywords ***

Fetch And Rename PM Counter Dirs
    [Documentation]     Fetch and Verify all new CB015279 and legacy PM counters
    [Arguments]    ${gnb_id}    ${PM_Part}

    Log To Console  Stop PM Counter collection
    ${PMCounters_dir_Part}=    Fetch All PM Counter Values  gnb_id=${gnb_id}  PM_Part=${PM_Part}
    RETURN    ${PMCounters_dir_Part}


Verify PM Counters CB015279_A_TC03
    [Arguments]    ${PMCounters_dir}
    Log To Console    \nVerify the CB015279_A_TC03 PM Counters:

    ${reference_table}    Create List
    ...      (NRCELL-1)M55316C15032  ==  0        PCELL_UE_2_ACT_SCELL_DL_SA
    ...      (NRCELL-1)M55316C15033  !=  0        PCELL_UE_3_ACT_SCELL_DL_SA
    ...      (NRCELL-1)M55316C15034  !=  0        PCELL_UE_4_ACT_SCELL_DL_SA

    pmcounters.Verify PM Counter Reference Table   reference_table=${reference_table}  pm_dir=${PMCounters_dir}


Verify PM Counters CB015279_A_TC05
    [Arguments]    ${PMCounters_dir}
    Log To Console    \nVerify the CB015279_A_TC05 PM Counters:

    ${reference_table}    Create List
    ...      (NRCELL-1)M55316C15032  ==  0        PCELL_UE_2_ACT_SCELL_DL_SA
    ...      (NRCELL-1)M55316C15033  !=  0        PCELL_UE_3_ACT_SCELL_DL_SA
    ...      (NRCELL-1)M55316C15034  !=  0        PCELL_UE_4_ACT_SCELL_DL_SA

    pmcounters.Verify PM Counter Reference Table   reference_table=${reference_table}  pm_dir=${PMCounters_dir}


Verify PM Counters CB015279_A_TC07
    [Arguments]    ${PMCounters_dir}
    Log To Console    \nVerify the CB015279_A_TC07 PM Counters:

    ${reference_table}    Create List
    ...      (NRCELL-1)M55316C15032  ==  0        PCELL_UE_2_ACT_SCELL_DL_SA
    ...      (NRCELL-1)M55316C15033  !=  0        PCELL_UE_3_ACT_SCELL_DL_SA
    ...      (NRCELL-1)M55316C15034  !=  0        PCELL_UE_4_ACT_SCELL_DL_SA

    pmcounters.Verify PM Counter Reference Table   reference_table=${reference_table}  pm_dir=${PMCounters_dir}


Fetch All PM Counter Values
    [Documentation]     This KW collects all PM counters and returns the directory, where they are stored.
    [Arguments]  ${gnb_id}  ${PM_Part}
    Log To Console    \n"PMcounters: Wait next Measurement Period Stops."
    pmcounters.Wait Until The Current Measurement Period Stops    gnb_id=${gnb_id}
    ${PMCounters_dir}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id}
    OperatingSystem.Move Directory    ${PMCounters_dir}  ${PMCounters_dir}_${PM_Part}
    RETURN    ${PMCounters_dir}_${PM_Part}
