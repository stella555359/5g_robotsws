*** Settings ***
Documentation   Resources file for feature 'CB013142'
...             Team: 'MN RAN RD VRF ULM 1'
...             Email: 'ou_mn_ran_rd_vrf_ulm_1_53028392@internal.nsn.com'
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    ../../resources/Common/pmcounters.robot



*** Keywords ***

Check Performance Counter
    [Arguments]       ${test_name}
    [Documentation]   Check PM counter
    ...               new counter: M55187C00003 -
    ...                            Number of CA related UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...                            M55187C00004 -
    ...                            Not used selections for CA related MP due to lack of CA related MP parameters in measConfig
    ...                            (miNrMeasProfileIntraFreq)
    ...                            M55205C00001 -
    ...                            Number of UE configuration attempts for SCell measurement profiles (miNrMeasProfileSCell)
    ...                            M55205C00002 -
    ...                            Not used selections for SCell MP due to lack of SCell MP parameters in measConfig (miNrMeasProfileSCell)
    ...               legacy counter (CB007516): M55187C00001 -
    ...                                          Number of UE configuration attempts for intra-frequency measurement profiles
    ...                                          (miNrMeasProfileIntraFreq)
    ...                                          M55188C00001 -
    ...                                          Number of UE configuration attempts for inter-frequency measurement profiles
    ...                                          (miNrMeasProfileInterFreq)
    ...                                          M55190C00001 -
    ...                                          Number of selections of measurement profile mappings for SA
    ...                                          (miNrMeasProfileMappingSA)
    ...                                          M55191C00001 -
    ...                                          Number of selections of measurement profile mappings for NSA
    ...                                          (miNrMeasProfileMappingNSA)
    ...                                          M55187C00002 -
    ...                                          Not used selections for intra-freq MP due to lack of intra-freq MP parameters in measConfig
    ...                                          (miNrMeasProfileIntraFreq)
    ...                                          M55188C00002 -
    ...                                          Not used selections for inter-freq MP due to lack of inter-freq MP parameters in measConfig
    ...                                          (miNrMeasProfileInterFreq)
    ...                                          M55190C00002 -
    ...                                          Selections of measurement profile mappings for SA when no MP parameters in measConfig are used
    ...                                          (miNrMeasProfileMappingSA)
    ...                                          M55191C00002 -
    ...                                          Selections of measurement profile mappings for NSA when no MP parameters in measConfig are used
    ...                                          (miNrMeasProfileMappingNSA)

    Run Keyword  Check PM Counter For ${test_name}

Check PM Counter For CB013142 A ST TC01 B2 SA A2 Meas Reconfig On PCell For PCell Change Using Meas Profile Based On UE PC Upon SCell Change
    [Documentation]   Check PM counter

    pmcounters.Wait Until The Current Measurement Period Stops   gnb_id=${gnb_id}
    ${PM_dir_gnb}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id}    collector_alias=pm_counters_gnb0

    ${pm_counter_reference_table_1}=   Create List
    ...   M55187C00001  >=  1  Number of UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...   M55187C00002  ==  0  Not used selections for intra-freq MP due to lack of intra-freq MP parameters in measConfig (miNrMeasProfileIntraFreq)
    ...   M55187C00003  ==  1  Number of CA related UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...   M55187C00004  ==  0  Not used selections for CA related MP due to lack of CA related MP parameters in measConfig (miNrMeasProfileIntraFreq)

    ${pm_counter_reference_table_1_1}=   Create List
    ...   M55187C00001  ==  0  Number of UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...   M55187C00002  ==  0  Not used selections for intra-freq MP due to lack of intra-freq MP parameters in measConfig (miNrMeasProfileIntraFreq)
    ...   M55187C00003  ==  0  Number of CA related UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...   M55187C00004  ==  0  Not used selections for CA related MP due to lack of CA related MP parameters in measConfig (miNrMeasProfileIntraFreq)

    ${pm_counter_reference_table_3}=   Create List
    ...   M55190C00001  >=  1  Number of selections of measurement profile mappings for SA (miNrMeasProfileMappingSA)
    ...   M55190C00002  ==  0  Number of selections of measurement profile mappings for NSA (miNrMeasProfileMappingSA)

    ${pm_counter_reference_table_3_1}=   Create List
    ...   M55190C00001  ==  0  Number of selections of measurement profile mappings for SA (miNrMeasProfileMappingSA)
    ...   M55190C00002  ==  0  Number of selections of measurement profile mappings for NSA (miNrMeasProfileMappingSA)

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_1}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMIAF-1

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_3}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMASA-1


    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_1}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMIAF-2

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_3}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMASA-2


    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_1_1}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMIAF-3

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_3_1}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMASA-3


Check PM Counter For CB013142 C ST TC01 B3 NSA Target Cell Radio Quality Evaluation During A2 Based PSCell Change Using Meas Profile
    [Documentation]   Check PM counter on source and target gNB

    pmcounters.Wait Until The Current Measurement Period Stops   gnb_id=${gnb_id}
    ${PM_dir_gnb}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id}    collector_alias=pm_counters_gnb0

    ${pm_counter_reference_table_1}=   Create List
    ...   M55187C00001  >=  1  Number of UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...   M55187C00002  ==  0  Not used selections for intra-freq MP due to lack of intra-freq MP parameters in measConfig (miNrMeasProfileIntraFreq)
    ...   M55187C00003  ==  1  Number of CA related UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...   M55187C00004  ==  0  Not used selections for CA related MP due to lack of CA related MP parameters in measConfig (miNrMeasProfileIntraFreq)

    ${pm_counter_reference_table_1_1}=   Create List
    ...   M55187C00001  ==  0  Number of UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...   M55187C00002  ==  0  Not used selections for intra-freq MP due to lack of intra-freq MP parameters in measConfig (miNrMeasProfileIntraFreq)
    ...   M55187C00003  ==  0  Number of CA related UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...   M55187C00004  ==  0  Not used selections for CA related MP due to lack of CA related MP parameters in measConfig (miNrMeasProfileIntraFreq)

    ${pm_counter_reference_table_1_2}=   Create List
    ...   M55187C00001  ==  1  Number of UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...   M55187C00002  ==  1  Not used selections for intra-freq MP due to lack of intra-freq MP parameters in measConfig (miNrMeasProfileIntraFreq)
    ...   M55187C00003  ==  0  Number of CA related UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...   M55187C00004  ==  0  Not used selections for CA related MP due to lack of CA related MP parameters in measConfig (miNrMeasProfileIntraFreq)

    ${pm_counter_reference_table_3}=   Create List
    ...   M55191C00001  >=  1  Number of selections of measurement profile mappings for NSA (miNrMeasProfileMappingNSA)
    ...   M55191C00002  ==  0  Selections of measurement profile mappings for NSA when no MP param in measConfig are used (miNrMeasProfileMappingNSA)

    ${pm_counter_reference_table_3_1}=   Create List
    ...   M55191C00001  ==  0  Number of selections of measurement profile mappings for NSA (miNrMeasProfileMappingNSA)
    ...   M55191C00002  ==  0  Selections of measurement profile mappings for NSA when no MP param in measConfig are used (miNrMeasProfileMappingNSA)

    ${pm_counter_reference_table_3_2}=   Create List
    ...   M55191C00001  ==  1  Number of selections of measurement profile mappings for NSA (miNrMeasProfileMappingNSA)
    ...   M55191C00002  ==  1  Selections of measurement profile mappings for NSA when no MP param in measConfig are used (miNrMeasProfileMappingNSA)

    ${pm_counter_reference_table_2}=   Create List
    ...   M55205C00001  ==  0  Number of UE configuration attempts for SCell measurement profiles (miNrMeasProfileSCell)
    ...   M55205C00002  ==  0  Not used selections for SCell MP due to lack of SCell MP parameters in measConfig (miNrMeasProfileSCell)

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_1}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMIAF-1

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_3}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMNSA-1

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_1_1}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMIAF-2

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_3_1}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMNSA-2

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_2}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMSCL-1

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_1_2}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${s_cell_1}/PLMN-PLMN/NRMIAF-2

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_3_2}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${s_cell_1}/PLMN-PLMN/NRMNSA-2

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_2}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${s_cell_1}/PLMN-PLMN/NRMSCL-1

Check PM Counter For CB013142 D ST TC03 B4 NSA A1 Meas Config On SCell For PSCell Change Using NRCELL Config When Matching Profile Mapping Not Found
    [Documentation]   Check PM counter

    pmcounters.Wait Until The Current Measurement Period Stops   gnb_id=${gnb_id}
    ${PM_dir_gnb}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id}    collector_alias=pm_counters_gnb0

    ${pm_counter_reference_table_1}=   Create List
    ...   M55187C00001  ==  0  Number of UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...   M55187C00002  ==  0  Not used selections for intra-freq MP due to lack of intra-freq MP parameters in measConfig (miNrMeasProfileIntraFreq)
    ...   M55187C00003  ==  0  Number of CA related UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...   M55187C00004  ==  0  Not used selections for CA related MP due to lack of CA related MP parameters in measConfig (miNrMeasProfileIntraFreq)

    ${pm_counter_reference_table_3}=   Create List
    ...   M55191C00001  >=  1  Number of selections of measurement profile mappings for NSA (miNrMeasProfileMappingNSA)
    ...   M55191C00002  ==  0  Selections of measurement profile mappings for NSA when no MP param in measConfig are used (miNrMeasProfileMappingNSA)

    ${pm_counter_reference_table_2}=   Create List
    ...   M55205C00001  ==  1  Number of UE configuration attempts for SCell measurement profiles (miNrMeasProfileSCell)
    ...   M55205C00002  ==  0  Not used selections for SCell MP due to lack of SCell MP parameters in measConfig (miNrMeasProfileSCell)

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_1}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMIAF-1
    ...                                             interval=15

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_3}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMNSA-1
    ...                                             interval=15

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_2}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMSCL-1
    ...                                             interval=15

Check PM Counter For CB013142 F ST TC01 B1 SA A1 And A4 Config Meas For SCell Addition Using Selected Meas Profile Based On One Or More Criteria
    [Documentation]   Check PM counter

    pmcounters.Wait Until The Current Measurement Period Stops   gnb_id=${gnb_id}
    ${PM_dir_gnb}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id}    collector_alias=pm_counters_gnb0

    ${pm_counter_reference_table_1}=   Create List
    ...   M55187C00001  >=  1  Number of UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...   M55187C00002  ==  0  Not used selections for intra-freq MP due to lack of intra-freq MP parameters in measConfig (miNrMeasProfileIntraFreq)
    ...   M55187C00003  ==  1  Number of CA related UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...   M55187C00004  ==  0  Not used selections for CA related MP due to lack of CA related MP parameters in measConfig (miNrMeasProfileIntraFreq)

    ${pm_counter_reference_table_2}=   Create List
    ...   M55188C00001  >=  1  Number of UE configuration attempts for inter-frequency measurement profiles (miNrMeasProfileInterFreq)
    ...   M55188C00002  ==  0  Not used selections for inter-freq MP due to lack of inter-freq MP parameters in measConfig (miNrMeasProfileInterFreq)

    ${pm_counter_reference_table_3}=   Create List
    ...   M55190C00001  >=  1  Number of selections of measurement profile mappings for SA (miNrMeasProfileMappingSA)
    ...   M55190C00002  ==  0  Number of selections of measurement profile mappings for NSA (miNrMeasProfileMappingSA)

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_1}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMIAF-1

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_2}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMIEF-1

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_3}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMASA-1


Check PM Counter For CB013142 G ST TC01 B2 SA Reconfig Of A1 Meas On PCell For SCell Change Using Meas Profile Upon Setup Of VoNR
    [Documentation]   Check PM counter

    pmcounters.Wait Until The Current Measurement Period Stops   gnb_id=${gnb_id}
    ${PM_dir_gnb}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id}    collector_alias=pm_counters_gnb0

    ${pm_counter_reference_table_1}=   Create List
    ...   M55187C00001  >=  1  Number of UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...   M55187C00002  ==  0  Not used selections for intra-freq MP due to lack of intra-freq MP parameters in measConfig (miNrMeasProfileIntraFreq)
    ...   M55187C00003  ==  1  Number of CA related UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...   M55187C00004  ==  0  Not used selections for CA related MP due to lack of CA related MP parameters in measConfig (miNrMeasProfileIntraFreq)

    ${pm_counter_reference_table_2}=   Create List
    ...   M55188C00001  ==  0  Number of UE configuration attempts for inter-frequency measurement profiles (miNrMeasProfileInterFreq)
    ...   M55188C00002  ==  0  Not used selections for inter-freq MP due to lack of inter-freq MP parameters in measConfig (miNrMeasProfileInterFreq)

    ${pm_counter_reference_table_3}=   Create List
    ...   M55190C00001  >=  1  Number of selections of measurement profile mappings for SA (miNrMeasProfileMappingSA)
    ...   M55190C00002  ==  0  Number of selections of measurement profile mappings for NSA (miNrMeasProfileMappingSA)

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_1}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMIAF-1

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_2}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMIEF-1

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_3}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMASA-1

Check PM Counter For CB013142 I ST TC01 B6 NSA A1 Based SCell Addition Based On Mobility Meas Results During PSCell Change Using Meas Profile
    [Documentation]   Check PM counter

    pmcounters.Wait Until The Current Measurement Period Stops   gnb_id=${gnb_id}
    ${PM_dir_gnb}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id}    collector_alias=pm_counters_gnb0

    ${pm_counter_reference_table_1}=   Create List
    ...   M55187C00001  ==  1  Number of UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...   M55187C00002  ==  1  Not used selections for intra-freq MP due to lack of intra-freq MP parameters in measConfig (miNrMeasProfileIntraFreq)
    ...   M55187C00003  ==  1  Number of CA related UE configuration attempts for intra-frequency measurement profiles (miNrMeasProfileIntraFreq)
    ...   M55187C00004  ==  0  Not used selections for CA related MP due to lack of CA related MP parameters in measConfig (miNrMeasProfileIntraFreq)

    ${pm_counter_reference_table_3}=   Create List
    ...   M55191C00001  ==  1  Number of selections of measurement profile mappings for NSA (miNrMeasProfileMappingNSA)
    ...   M55191C00002  ==  1  Selections of measurement profile mappings for NSA when no MP param in measConfig are used (miNrMeasProfileMappingNSA)

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_1}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMIAF-1

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_3}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${p_cell_1}/PLMN-PLMN/NRMNSA-1
