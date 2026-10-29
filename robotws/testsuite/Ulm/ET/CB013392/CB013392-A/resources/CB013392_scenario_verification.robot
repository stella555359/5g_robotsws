*** Settings ***
Documentation    Scenario Verification keywords for CB013392 subfeature

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    Collections
Library    ./../libraries/CB013392_verification.py                      WITH NAME  CB013392_verification
Library    ./../../libraries/CB013392_verif_tools.py                    WITH NAME  CB013392_verif_tools


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
*** Keywords ***

Verify CB013392_A_B1_TC01_IntragNB_blind_UL_SCell_addition_power_class
    Prepare Variables For Verification     scenario_SUE_A_B1_TC01
    Run Keyword And Continue On Failure    CB013392_verification.Verify SCF Parameters    B1    cell=3    rel=1
    Run Keyword And Continue On Failure    CB013392_verification.Verify Meas Profile B1
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput CA 2cells    11:2:dl:700:ul:100    dlAndUl
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul    11:2
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl    11:2


Verify CB013392_A_B1_TC02_IntragNB_blind_UL_SCell_addition_power_class_incoming_HO
    Prepare Variables For Verification     scenario_SUE_HO_A_B1_TC02
    Run Keyword And Continue On Failure    CB013392_verification.Verify SCF Parameters    B1    cell=11
    Run Keyword And Continue On Failure    CB013392_verification.Verify Meas Profile B1
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput CA 2cells    11:2:dl:700:ul:100    dlAndUl
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul    11:2
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl    11:2


Verify CB013392_A_B2_TC01_IntragNB_A1_UL_SCell_addition_power_class
    Prepare Variables For Verification     scenario_SUE_A_B2_TC01
    Run Keyword And Continue On Failure    CB013392_verification.Verify Meas Profile B2
    Run Keyword And Continue On Failure    CB013392_verification.Verify SCF Parameters    B2    cell=3    rel=1
    # following lines will be uncommented, when TTI trace and PMCs are working with TMO TL
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput CA 2cells    11:2:dl:700:ul:100    dlAndUl
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl


Verify CB013392_A_B3_TC01_IntragNB_A1_UL_SCell_change_power_class
    Prepare Variables For Verification     scenario_SUE_A_B3_TC01
    Run Keyword And Continue On Failure    CB013392_verification.Verify SCF Parameters    B3    cell=3
    Run Keyword And Continue On Failure    CB013392_verification.Verify Meas Profile B3
    Run Keyword And Continue On Failure    CB013392_verif_tools.Verify A1 Result    5    54    TDD
    Run Keyword And Continue On Failure    CB013392_verif_tools.Verify A1 Result    7    58    FDD
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput CA 2cells    1:12:dl:850:ul:50    dlAndUl
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul    1:12
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl    1:12


Verify CB013392_A_B3_TC01_IntragNB_A1_UL_SCell_change_power_class_Robustness
    Prepare Variables For Verification     scenario_MUE_A_B3_TC02
    Run Keyword And Continue On Failure    CB013392_verification.Verify SCF Parameters    B3    cell=1
    Run Keyword And Continue On Failure    CB013392_verification.Verify Meas Profile B3 Robustness
    Run Keyword And Continue On Failure    CB013392_verif_tools.Verify A1 Result    5    51    FDD
    Run Keyword And Continue On Failure    CB013392_verif_tools.Verify A1 Result    6    61    TDD
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput CA 2cells    1:12:dl:15:ul:3    dlAndUl
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul    1:12
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl    1:12


Verify CB013392_A_B5_TC01_IntragNB_A2_UL_SCell_release_power_class
    Prepare Variables For Verification     scenario_SUE_A_B5_TC01
    Run Keyword And Continue On Failure    CB013392_verification.Verify Meas Profile B5
    Run Keyword And Continue On Failure    CB013392_verification.Verify SCF Parameters    B5    cell=3    rel=1
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput              11:dl:300:ul:50
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl


Verify CB013392_A_B6_TC01_meas_profile_selection_due_to_effective_power_limitation_with_pMaxNROwnCell_without_CA
    Prepare Variables For Verification     scenario_SUE_A_B6_TC01
    Run Keyword And Continue On Failure    CB013392_verification.Verify SCF Parameters    B6    cell=3
    Run Keyword And Continue On Failure    CB013392_verification.Verify Meas Profile B6
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput              11:dl:300:ul:50
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl


Prepare Variables For Verification
    [Arguments]  ${scenario}
    ${collector_name}=  template.Get Collector Name  scenario_name=${scenario}
    ${PATH_TO_SCF_XML}=        Set Variable  ${configuration_directory}/scf_${scenario}.xml
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # ${path_to_ttitrace_pkl}=   Set Variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming.pkl
    # ${pm_counters_dir}=        Set Variable  ${ts_log_dir}/PMC/gnb_pm_counters/
    # ${pmc_index}=  tools.Get Pmc Index
    # ...                                 scenario=${scenario}
    # ...                                 pm_offset_path=${pm_counters_dir}/pm_counter_offsets.json
    ${NRBTS_STR}=  gnb.Get DistNames From GNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    Set Test Variable  ${PATH_TO_SCF_XML}
    # Set Test Variable  ${path_to_ttitrace_pkl}
    # Set Test Variable  ${pm_counters_dir}
    # Set Test Variable  ${pmc_index}
    Set Test Variable  ${NRBTS_STR}
    Set Test Variable  ${scenario}

    # FEATURE SPECIFIC VARIABLES
    ${PATH_TO_REG_MP}=   Set Variable  ${ts_log_dir}/registration_meas_profile.txt
    Set Test Variable  ${PATH_TO_REG_MP}
    ${PATH_TO_A1_FDD_SCELL_ADD_MP}=   Set Variable  ${ts_log_dir}/a1_fdd_scell_addition_meas_profile.txt
    Set Test Variable  ${PATH_TO_A1_FDD_SCELL_ADD_MP}
    ${PATH_TO_A2_FDD_SCELL_REL_MP}=   Set Variable  ${ts_log_dir}/a2_fdd_scell_release_meas_profile.txt
    Set Test Variable  ${PATH_TO_A2_FDD_SCELL_REL_MP}
    ${PATH_TO_A1_TDD_SCELL_ADD_MP}=    Set Variable  ${ts_log_dir}/a1_tdd_scell_addition_meas_profile.txt
    Set Test Variable  ${PATH_TO_A1_TDD_SCELL_ADD_MP}
    ${PATH_TO_A1_FDD_SCELL_ADD_OUTPUT}=   Set Variable  ${ts_log_dir}/a1_fdd_scell_addition_egate_output.txt
    Set Test Variable  ${PATH_TO_A1_FDD_SCELL_ADD_OUTPUT}
    ${PATH_TO_A1_TDD_SCELL_ADD_OUTPUT}=  Set Variable  ${ts_log_dir}/a1_tdd_scell_addition_egate_output.txt
    Set Test Variable  ${PATH_TO_A1_TDD_SCELL_ADD_OUTPUT}


Extract TTI Trace And Convert To JSON
    [Arguments]  @{varargs}
    RETURN


Extract TTI Trace And Convert To Pickle
    [Arguments]  ${path_to_tti_trace_pcap}
    ${events_required}=  Create List  utcTimeStampData     ulTdSchedSubcellData
    ...                               ulHarqRxData         dlHarqRxDataArray
    ...                               dlFdSchedData        ulFdSchedData
    ...                               dlLaDeltaCqiArray    ulLaDeltaSinr
    ...                               laIniDelta           csiSrReportData
    ...                               dlFdSchedAdditionalData
    Convert TTI Trace From PCAP To Data Frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                        events_list=${events_required}
    ...                                        write_to_pickle=${TRUE}
