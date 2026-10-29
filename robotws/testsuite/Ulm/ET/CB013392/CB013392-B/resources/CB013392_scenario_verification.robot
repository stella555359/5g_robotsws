*** Settings ***
Documentation    Scenario Validation keywords for CB013392 subfeature

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    Collections
Library    ./../libraries/CB013392_verification.py                    WITH NAME  CB013392_verification


*** Keywords ***

Verify CB013392_B_B1_TC01_IntragNB_blind_SCell_addition_DL_CA_incoming_HO
    Prepare Variables For Verification     scenario_B_B1_TC01
    Run Keyword And Continue On Failure    CB013392_verification.Verify SCF Parameters    B1    cell=4
    Run Keyword And Continue On Failure    CB013392_verification.Verify Meas Profile B1
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput CA 2cells    11:2:dl:700:ul:50    dlonly
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul    11
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl    11:2


Verify CB013392_B_B2_TC01_IntragNB_A1_SCell_addition_DL_CA
    Prepare Variables For Verification     scenario_SUE_B_B2_TC01
    Run Keyword And Continue On Failure    CB013392_verification.Verify Meas Profile B2
    Run Keyword And Continue On Failure    CB013392_verification.Verify SCF Parameters    B2
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput CA 2cells    11:2:dl:350:ul:50    dlonly
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl


Verify CB013392_B_B3_TC01_IntragNB_A1_DL_SCell_change_to_DL_SCell_CA
    Prepare Variables For Verification     scenario_SUE_B_B3_TC01
    Run Keyword And Continue On Failure    CB013392_verification.Verify Meas Profile B3
    Run Keyword And Continue On Failure    CB013392_verification.Verify SCF Parameters    B3    cell=3
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput CA 2cells    11:12:dl:350:ul:50    dlonly
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl


Verify CB013392_B_B5_TC01_IntergNB_A1_SCell_addition_DL_CA
    Prepare Variables For Verification     scenario_B_B5_TC01
    Run Keyword And Continue On Failure    CB013392_verification.Verify SCF Parameters    B1
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput              11:dl:300:ul:50


Verify CB013392_B_B6_TC01_IntergNB_A2_SCell_release_DL_CA
    Prepare Variables For Verification     scenario_B_B6_TC01
    Run Keyword And Continue On Failure    CB013392_verification.Verify SCF Parameters    B1
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput              11:dl:300:ul:50


Verify CB013392_B_B7_TC01_IntragNB_A2_SCell_release_DL_CA
    Prepare Variables For Verification     scenario_SUE_B_B7_TC01
    Run Keyword And Continue On Failure    CB013392_verification.Verify Meas Profile B7
    Run Keyword And Continue On Failure    CB013392_verification.Verify SCF Parameters    B7    cell=11
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput              11:dl:300:ul:50
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl


Verify CB013392_B_B8_TC01_IntragNB_A1_partial_SCell_release_3CC_DL_CA
    Prepare Variables For Verification     scenario_SUE_B_B8_TC01
    Run Keyword And Continue On Failure    CB013392_verification.Verify Meas Profile B8
    Run Keyword And Continue On Failure    CB013392_verification.Verify SCF Parameters    B8    cell=3
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput CA 2cells    11:12:dl:350:ul:50    dlonly
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl


Verify CB013392_B_B9_TC01_IntragNB_A1_UL_SCell_change_to_DL_SCell_CA
    Prepare Variables For Verification     scenario_SUE_B_B9_TC01
    Run Keyword And Continue On Failure    CB013392_verification.Verify Meas Profile B3    #same as B3
    Run Keyword And Continue On Failure    CB013392_verification.Verify SCF Parameters    B9    cell=3
    # following lines will be uncommented, when TTI trace and PMCs are working with TMO TL
    # Run Keyword And Continue On Failure    CB013392_verification.Verify Tput CA 2cells    11:12:dl:350:ul:50    dlonly
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    ul
    # Run Keyword And Continue On Failure    CB013392_verification.Verify DTX Statistics    dl


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Prepare Variables For Verification
    [Arguments]  ${scenario}
    ${collector_name}=  template.Get Collector Name  scenario_name=${scenario}
    ${PATH_TO_SCF_XML}=        Set Variable  ${configuration_directory}/scf_${scenario}.xml
    ${NRBTS_STR}=  gnb.Get DistNames From GNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    Set Test Variable  ${PATH_TO_SCF_XML}
    Set Test Variable  ${NRBTS_STR}

    # FEATURE SPECIFIC VARIABLES
    ${PATH_TO_REG_MP}=   Set Variable  ${ts_log_dir}/registration_meas_profile.txt
    Set Test Variable  ${PATH_TO_REG_MP}
    ${PATH_TO_A1_FDD_SCELL_ADD_MP}=   Set Variable  ${ts_log_dir}/a1_fdd_scell_addition_meas_profile.txt
    Set Test Variable  ${PATH_TO_A1_FDD_SCELL_ADD_MP}
    ${PATH_TO_A2_FDD_SCELL_REL_MP}=   Set Variable  ${ts_log_dir}/a2_fdd_scell_release_meas_profile.txt
    Set Test Variable  ${PATH_TO_A2_FDD_SCELL_REL_MP}
    ${PATH_TO_A1_TDD_SCELL_ADD_MP}=    Set Variable  ${ts_log_dir}/a1_tdd_scell_addition_meas_profile.txt
    Set Test Variable  ${PATH_TO_A1_TDD_SCELL_ADD_MP}


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
    ${df}=  ttitrace.Convert TTI Trace From PCAP To Data Frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                        events_list=${events_required}
    ...                                        write_to_pickle=${TRUE}
    ${target_path}=    String.Replace String    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ${EMPTY}
    ttitrace.Convert TTI Trace From Data Frame To CSV    ${df}
    ...                                                  ${target_path}
    ...                                                  tti_trace_filename=ttitrace_streaming_ul_dl.csv
