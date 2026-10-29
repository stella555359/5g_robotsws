*** Settings ***
Documentation   Resources file for feature 'CB012656'
...             Team: 'MN 5G&SC PZ ULM 2 SqdGp62'
...             Email: 'I_MN_5GSC_PZ_ULM_SQD_62@nokia.com'
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    ../../resources/Common/pmcounters.robot


*** Keywords ***

Check Performance counter
    [Arguments]       ${test_name}
    [Documentation]   Check PM counter
    ...               new counter: M55124C09009 -
    ...                            Number of RRC release with cell reselection priorities and NR primary target configured with UL CA weight
    ...                            miNrRRCC (OAM parameter )
    ...               legacy counter (CB007516): M55124C05501 -
    ...                                          Number of RRC RELEASE messages with dedicated cell reselection priorities and NR primary target
    ...                                          miNrRRCC (OAM parameter )
    ...                                          M55124C05502 -
    ...                                          Number of RRC RELEASE messages with dedicated cell reselection priorities and LTE primary target
    ...                                          miNrRRCC (OAM parameter )

   run keyword  Check Performance counter for ${test_name}

Check Performance counter for CB012656-A-004_NR_UL_CA_aware_Idle_mode_mobility_steering_WRR_Prim_Sec_gNBinitiatedRRCRelease
    [Documentation]   Check PM counter

    pmcounters.Wait until the current Measurement Period stops   gnb_id=${gnb_id}
    ${PM_dir_gnb}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id}    collector_alias=pm_counters_gnb0
    ${cell_pm}  convert to string  ${cell}

   ${pm_counter_reference_table}=   Create List
    ...   M55124C09009  >=  ${repeat_rrc_release}  RRC release with cell reselection priorities and NR primary target configured with UL CA weight
    ...   M55124C05501  ==  0  Number of RRC RELEASE messages with dedicated cell reselection priorities and NR primary target
    ...   M55124C05502  ==  0  Number of RRC RELEASE messages with dedicated cell reselection priorities and LTE primary target

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${cell_pm}

Check Performance counter for CB012656-A-026_NR_UL_CA_aware_Idle_mode_mobility_steering_Weight_based_gNBinitiatedRRCRelease
    [Documentation]   Check PM counter on source and target gNB
    pmcounters.Wait until the current Measurement Period stops   gnb_id=${gnb_id}
    ${PM_dir_gnb}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id}    collector_alias=pm_counters_gnb0

   ${pm_counter_reference_table}=   Create List
    ...   M55124C09009  >=  ${repeat_rrc_release}  RRC release with cell reselection priorities and NR primary target configured with UL CA weight
    ...   M55124C05501  ==  0  Number of RRC RELEASE messages with dedicated cell reselection priorities and NR primary target (miNrRRCC)
    ...   M55124C05502  ==  0  Number of RRC RELEASE messages with dedicated cell reselection priorities and LTE primary target (miNrRRCC)

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${cell}

Check Performance counter for CB012656-B-006_NR_UL_CA_aware_Idle_mode_mobility_steering_WRR_Prim_Sec_RRC_Inactive_with_MobProfile
    [Documentation]   Check PM counter

    pmcounters.Wait until the current Measurement Period stops   gnb_id=${gnb_id}
    ${PM_dir_gnb}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id}    collector_alias=pm_counters_gnb0

   ${pm_counter_reference_table}=   Create List
    ...   M55124C09009  >=  ${repeat_rrc_release}  RRC release with cell reselection priorities and NR primary target configured with UL CA weight
    ...   M55124C05501  ==  0  Number of RRC RELEASE messages with dedicated cell reselection priorities and NR primary target
    ...   M55124C05502  ==  0  Number of RRC RELEASE messages with dedicated cell reselection priorities and LTE primary target

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${cell}

Check Performance counter for CB012656-D-006_NR_DL_CA_aware_Idle_mode_mobility_steering_WRR_Prim_Sec_RRC_Inactive_CB012656_enabled_withMob_Profile
    [Documentation]   Check PM counter on source and target gNB
    pmcounters.Wait until the current Measurement Period stops   gnb_id=${gnb_id}
    ${PM_dir_gnb}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id}    collector_alias=pm_counters_gnb0

   ${pm_counter_reference_table}=   Create List
    ...   M55124C09009  >=  ${repeat_rrc_release}  RRC release with cell reselection priorities and NR primary target configured with UL CA weight
    ...   M55124C05501  ==  0  Number of RRC RELEASE messages with dedicated cell reselection priorities and NR primary target
    ...   M55124C05502  ==  0  Number of RRC RELEASE messages with dedicated cell reselection priorities and LTE primary target

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${cell}
