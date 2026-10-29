*** Settings ***
Documentation    Scenario Validation keywords for CB008127 subfeature

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    ./../libraries/CB013392_verification.py                    WITH NAME  CB013392_verification_c
Library    ./../../libraries/CB013392_verif_tools.py                  WITH NAME  CB013392_verification
Library    Collections



#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
*** Keywords ***
Verify CB013392_C_B01_TC01_NSA_IAF_activation_during_SgNB_addition_with_MeNB_power_coordination
    Prepare Variables For Verification     scenario_C_B01_TC01
    Run Keyword And Continue On Failure    CB013392_verification_c.Verify SCF Parameters    B1    11
    Run Keyword And Continue On Failure    CB013392_verification_c.Verify Meas Profile B1
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput    11:dl:200:ul:50
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl

Verify CB013392_C_B2_TC01_NSA_IAF_activation_during_SgNB_initiated_IntraSgNB_A2_A3_triggered_PScell_change_with_MeNB_power_coordination
    Prepare Variables For Verification     scenario_C_B2_TC01
    Run Keyword And Continue On Failure    CB013392_verification_c.Verify SCF Parameters    B2    11
    Run Keyword And Continue On Failure    CB013392_verification_c.Verify Meas Profile B1    # same as B1
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput    11:dl:200:ul:50
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl


Verify CB013392_C_B4_TC01_NSA_IAF_activation_during_MeNB_initiated_IntraSgNB_PScell_change_with_MeNB_power_coordination
    Prepare Variables For Verification     scenario_C_B4_TC01
    Run Keyword And Continue On Failure    CB013392_verification_c.Verify SCF Parameters    B4    4
    Run Keyword And Continue On Failure    CB013392_verification_c.Verify Meas Profile B4
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput    12:dl:200:ul:50
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl

Verify CB013392_C_B7_TC01_NSA_IAF_activation_during_InterMeNB_HO_initiated_IntraSgNB_addition_by_target_MeNB_with_MeNB_power_coordination
    Prepare Variables For Verification     scenario_C_B7_TC01
    Run Keyword And Continue On Failure    CB013392_verification_c.Verify SCF Parameters    B7    4
    Run Keyword And Continue On Failure    CB013392_verification_c.Verify Meas Profile B7    # same as in B4
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput    12:dl:200:ul:50
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl

Verify CB013392_C_B8_TC01_NSA_IAF_activation_after_A1_with_MeNB_power_coordination
    Prepare Variables For Verification     scenario_C_B8_TC01
    Run Keyword And Continue On Failure    CB013392_verification_c.Verify SCF Parameters    B8_TC01    cell=1
    Run Keyword And Continue On Failure    CB013392_verification_c.Verify Meas Profile B8
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl

Verify CB013392_C_B10_TC01_NSA_A4_IEF_activation_upon_a4RetryTimer_with_MeNB_power_coordination
    Prepare Variables For Verification     scenario_C_B10_TC01
    Run Keyword And Continue On Failure    CB013392_verification_c.Verify SCF Parameters    B10_TC01    4
    Run Keyword And Continue On Failure    CB013392_verification_c.Verify Meas Profile B10
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput    11:dl:200:ul:50
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl

Verify CB013392_C_B10_TC02_ALT3_NSA_A4_IEF_activation_upon_A1_mobility_to_preferred_NR_layer_meas_report_with_MeNB_power_coordination
    Prepare Variables For Verification     scenario_C_B10_TC02
    Run Keyword And Continue On Failure    CB013392_verification_c.Verify SCF Parameters    B10_TC02    4
    Run Keyword And Continue On Failure    CB013392_verification_c.Verify Meas Profile B10
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput    11:dl:200:ul:50
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl


Prepare Variables For Verification
    [Arguments]  ${scenario}
    ${collector_name}=  template.Get Collector Name  scenario_name=${scenario}
    ${PATH_TO_SCF_XML}=        Set Variable  ${configuration_directory}/scf_${scenario}.xml
    Set Test Variable  ${PATH_TO_SCF_XML}
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # ${path_to_ttitrace_pkl}=   Set Test Variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming.pkl
    # ${pm_counters_dir}=        Set Test Variable  ${ts_log_dir}/PMC/gnb_pm_counters/
    # ${PMC_INDEX}=  tools.Get_Pmc_Index  scenario=${scenario}  pmc_scenario_dict=${PMC_SCENARIO_DICT}  ts_log_dir=${TS_LOG_DIR}
    # Set Test Variable  ${pmc_index}
    ${NRBTS_STR}=  gnb.Get DistNames From GNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    Set Test Variable  ${NRBTS_STR}
    Set Test Variable  ${scenario}


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
    ttitrace.Convert TTI Trace From PCAP To Data Frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                 events_list=${events_required}
    ...                                                 write_to_pickle=${TRUE}
