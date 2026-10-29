*** Settings ***
Documentation   Resources file for feature 'CB007219 Carrier Aggregation with MFBI NR cells'
...             Team: 'MN 5G&SC PZ ULM 2 SqdGp62'
...             Email: 'I_MN_5GSC_PZ_ULM_SQD_62@nokia.com'
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    ../../resources/Common/pmcounters.robot


*** Keywords ***

Check Performance counter
   [Arguments]   ${test_name}
   run keyword  Check Performance counter for ${test_name}

Check Performance counter for TC25_AA_B14_Interaction_with_A1_measurement_based_PCell_switch
    [Documentation]   Check PM counter on source and target gNB
    pmcounters.Wait until the current Measurement Period stops   gnb_id=${gnb_id}
    ${PM_dir_gnb}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id}    collector_alias=pm_counters_gnb0
    ${cell_id_p}  convert to string  ${p_cell}
    ${scells}  split string  ${s_cell}  ,

   ${pm_counter_reference_table_p}=   Create List
    ...   M55114C00502  ==  0  Number of admitted NSA users where the radio admission is done on the alternative band (miNrRacCu)
    ...   M55114C00501  ==  0  Number of NSA user radio admission requests where the request is on the alternative band (miNrRacCu)
    ...   M55138C00501  ==  0  Number of SA UE radio admission requests with MFBI in CU during RRC access procedures (miNrRSACU)
    ...   M55138C00502  ==  0  Number of SA UE radio admission successes with MFBI in CU during RRC access procedures (miNrRSACU)

   ${pm_counter_reference_table_s}=   Create List
    ...   M55316C00041  ==  0  Number of cell configurations as SA SCell in alternative band (miNrCaCu)
    ...   M55316C00042  ==  0  Number of cell configurations as NSA SCell in alternative band (miNrCaCu)

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_p}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${cell_id_p}

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_s}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${scells[0]}

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table_s}
    ...                                             pm_dir=${PM_dir_gnb}
    ...                                             distname_suffix=NRCELL-${scells[1]}
