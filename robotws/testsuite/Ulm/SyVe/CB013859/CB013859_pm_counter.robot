*** Settings ***
Documentation   PM Verification for feature CB013859 Buffer-based step-wise NR FR1 SCell addition
...             Team: I_MN_RAN_RD_VRF_ULM_VT2
...             Email: i_mn_ran_rd_vrf_ulm_vt2@internal.nsn.com
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    ../../resources/Common/pmcounters.robot


*** Keywords ***

Check Performance Counter
    [Arguments]       ${test_name}
    [Documentation]   Check PM counter

    Run Keyword  Check PM Counter For ${test_name}

Check Performance Counter Part
   Run Keyword  Verify PM Counters CB013859_A03_Part${Part}

Check Performance Counter CB013859_A_RE_TC04
   Run Keyword  Verify PM Counters CB013859_A04

Check Performance Counter CB013859_B_RE_TC07
   Run Keyword  Verify PM Counters CB013859_B07

Check PM Counter For CB013859_A_RE_TC03_B3_UE_connection_setup_single_slice
    [Documentation]   Check PM counter

    pmcounters.Wait Until The Current Measurement Period Stops   gnb_id=${gnb_id_0}

    Check Performance Counter Part

Check PM Counter For CB013859_A_RE_TC04_B5_UE_conn_setup_PDU_with_multiple_slices_some_not_supp_scells
    [Documentation]   Check PM counter

    pmcounters.Wait Until The Current Measurement Period Stops   gnb_id=${gnb_id_0}

    Check Performance Counter CB013859_A_RE_TC04

Check PM Counter For CB013859_B_RE_TC07_IWK_6_interworking_inter_gNB_CA
    [Documentation]   Check PM counter

    pmcounters.Wait Until The Current Measurement Period Stops   gnb_id=${gnb_id_0}

    Check Performance Counter CB013859_B_RE_TC07


Verify PM Counters CB013859_A03_Part1
    pmcounters.Wait Until The Current Measurement Period Stops   gnb_id=${gnb_id_0}
    ${PM_dir_gnb}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id_0}    collector_alias=pm_counters_gnb0_part1

    ${pm_counter_reference_table_1}=   Create List
    ...   M55118C00110  ==  3  Number of partially compliant SCell configurations based on slice ID (iNrCACu)
    ...   M55118C00111  ==  0  Number of DRB assignments to partially compliant SCell in unsupported slice (iNrCaCu)

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_1}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}

Verify PM Counters CB013859_A03_Part2
    pmcounters.Wait Until The Current Measurement Period Stops   gnb_id=${gnb_id_0}
    ${PM_dir_gnb}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id_0}    collector_alias=pm_counters_gnb0_part2

    ${pm_counter_reference_table_2}=   Create List
    ...   M55118C00110  ==  2  Number of partially compliant SCell configurations based on slice ID (iNrCACu)
    ...   M55118C00111  ==  0  Number of DRB assignments to partially compliant SCell in unsupported slice (iNrCaCu)

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_2}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}

Verify PM Counters CB013859_A04
    pmcounters.Wait Until The Current Measurement Period Stops   gnb_id=${gnb_id_0}
    ${PM_dir_gnb}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id_0}    collector_alias=pm_counters_gnb0_part1

    ${pm_counter_reference_table_1}=   Create List
    ...   M55118C00110  ==  3  Number of partially compliant SCell configurations based on slice ID (iNrCACu)
    ...   M55118C00111  ==  0  Number of DRB assignments to partially compliant SCell in unsupported slice (iNrCaCu)

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_1}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}

Check PM Counter For CB013859_B_RE_TC06_IWK_5_interworking_A6_based_SCell_swap_F_to_F
    [Arguments]        ${gnb_id}=${0}
    pmcounters.Wait Until The Current Measurement Period Stops   gnb_id=${gnb_id}
    ${PM_dir_gnb}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id}    collector_alias=pm_counters_gnb0_part1

    ${pm_counter_reference_table_1}=   Create List
    ...   M55118C00110  ==  5  Number of partially compliant SCell configurations based on slice ID (iNrCACu)
#    ...   M55118C00111  ==  1  Number of DRB assignments to partially compliant SCell in unsupported slice (iNrCaCu)

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_1}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}

Verify PM Counters CB013859_B07
    pmcounters.Wait Until The Current Measurement Period Stops   gnb_id=${gnb_id_0}
    ${PM_dir_gnb}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id_0}    collector_alias=pm_counters_gnb0_part1

    ${pm_counter_reference_table_1}=   Create List
    ...   M55118C00110  ==  0  Number of partially compliant SCell configurations based on slice ID (iNrCACu)
    ...   M55118C00111  ==  0  Number of DRB assignments to partially compliant SCell in unsupported slice (iNrCaCu)

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_1}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}
