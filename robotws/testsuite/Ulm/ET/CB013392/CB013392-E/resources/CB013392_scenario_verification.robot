*** Settings ***
Documentation    Scenario Verification keywords for CB013392 subfeature

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    ./../libraries/CB013392_verification.py                    WITH NAME  CB013392_verification
Library    ./../../CB013392-A/libraries/CB013392_verification.py      WITH NAME  CB013392_verification_A
Library    Collections


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
*** Keywords ***

Verify CB013392_E_B1_TC01_IntragNB_A2_A3_HO
    Prepare Variables for Verification     scenario_MUE_E_B1_TC01
    Run Keyword And Continue On Failure    CB013392_verification . verify_SCF_Parameters    B1
    Run Keyword And Continue On Failure    CB013392_verification . verify_Tput_CA_2cells    11:2:dl:300:ul:60    dlonly
    Run Keyword And Continue On Failure    CB013392_verification_A . verify_meas_profile_e_b1_multiple_ue


Prepare Variables for Verification
    [Arguments]  ${scenario}
    ${collector_name}=  template.get_collector_name  scenario_name=${scenario}
    ${path_to_ttitrace_json}=  set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming.json
    ${path_to_ttitrace_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming.pkl
    ${path_to_syscom_pdml}=    set variable  ${ts_log_dir}/cell_setup_trace_initial/l2_lm_tcpdump.pdml
    ${path_to_scf_xml}=        set variable  ${configuration_directory}/scf_${scenario}.xml
    ${path_to_syslog_tgz}=     set variable  ${ts_log_dir}/btslog_${collector_name}/btslog_gnb0/syslog_files.tgz
    ${pm_counters_dir}=        set variable  ${ts_log_dir}/PMC/gnb_pm_counters/
    ${PMC_INDEX}=  tools.Get_Pmc_Index  scenario=${scenario}  pmc_scenario_dict=${PMC_SCENARIO_DICT}  ts_log_dir=${TS_LOG_DIR}
    ${nrbts_str}=  Get distNames from gNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${attached_ues}=  Get UE Ids configured for scenario  scenario_name=${scenario}
    set test variable  ${path_to_ttitrace_json}
    set test variable  ${path_to_ttitrace_pkl}
    set test variable  ${path_to_syscom_pdml}
    set test variable  ${path_to_scf_xml}
    set test variable  ${path_to_syslog_tgz}
    set test variable  ${pm_counters_dir}
    set test variable  ${pmc_index}
    set test variable  ${nrbts_str}
    set test variable  ${attached_ues}
    set test variable  ${scenario}
    Set SW Duplex Variable according to cellTechnology
    Set SW Wavelength Variable according to nrarfcn


Extract TTI Trace and Convert to JSON
    [Arguments]  @{varargs}
    RETURN


Extract TTI Trace and Convert to Pickle
    [Arguments]  ${path_to_tti_trace_pcap}
    ${events_required}=  create list  utcTimeStampData     ulTdSchedSubcellData
    ...                               ulHarqRxData         dlHarqRxDataArray
    ...                               dlFdSchedData        ulFdSchedData
    ...                               dlLaDeltaCqiArray    ulLaDeltaSinr
    ...                               laIniDelta           csiSrReportData
    ...                               dlFdSchedAdditionalData
    Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                        events_list=${events_required}
    ...                                        write_to_pickle=${TRUE}
