*** Settings ***
Documentation    Scenario Validation keywords for CB011006 subfeature

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    ../../CB011006/libraries/CB011006_validation.py          WITH NAME  CB011006
Library    ../../CB011006/libraries/CB011006_validation_B15.py      WITH NAME  CB011006_B15
Library    ../../CB011006/libraries/CB011006_validation_B19.py      WITH NAME  CB011006_B19

Resource    ../../../resources/Common/ttitrace.robot


*** Keywords ***

Verify CB011006_A_SUE_NSA_Call
    Prepare Variables for Validation    scenario_SUE
    run keyword and continue on failure    CB011006 . verify_Tput              3:dl:200:ul:200
    run keyword and continue on failure    CB011006 . verify_DTX_Statistics    ul
    run keyword and continue on failure    CB011006 . verify_DTX_Statistics    dl


Verify CB011006_A_SUE_SA_Call
    Prepare Variables for Validation    scenario_SUE
    run keyword and continue on failure    CB011006 . verify_Tput              4:dl:200:ul:200
    run keyword and continue on failure    CB011006 . verify_DTX_Statistics    ul
    run keyword and continue on failure    CB011006 . verify_DTX_Statistics    dl


Verify CB011006_A_MUE_NSA_Call
    Prepare Variables for Validation    scenario_MUE
    run keyword and continue on failure    CB011006 . verify_SCF_Parameters    A    cell=3
    run keyword and continue on failure    CB011006 . verify_Tput              3:dl:200:ul:200
    run keyword and continue on failure    CB011006 . verify_DTX_Statistics    ul
    run keyword and continue on failure    CB011006 . verify_DTX_Statistics    dl


Verify CB011006_A_MUE_SA_Call_on_ABIO
    Prepare Variables for Validation    scenario_MUE
    run keyword and continue on failure    CB011006 . verify_SCF_Parameters    A    cell=2
    run keyword and continue on failure    CB011006 . verify_Tput              2:dl:200:ul:200
    run keyword and continue on failure    CB011006 . verify_DTX_Statistics    ul
    run keyword and continue on failure    CB011006 . verify_DTX_Statistics    dl


Verify CB011006_A_MUE_NSA_Call_on_ABIO
    Prepare Variables for Validation    scenario_MUE
    run keyword and continue on failure    CB011006 . verify_SCF_Parameters    A    cell=1
    run keyword and continue on failure    CB011006 . verify_Tput              1:dl:200:ul:200
    run keyword and continue on failure    CB011006 . verify_DTX_Statistics    ul
    run keyword and continue on failure    CB011006 . verify_DTX_Statistics    dl


Verify CB011006_A_MUE_Calls
    Prepare Variables for Validation    scenario_MUE
    Run Keyword And Continue On Failure    CB011006 . verify_SCF_Parameters    A    cell=1
    Run Keyword And Continue On Failure    CB011006 . verify_SCF_Parameters    A    cell=2
    Run Keyword And Continue On Failure    CB011006 . verify_Tput              1:dl:400:ul:320
    Run Keyword And Continue On Failure    CB011006 . verify_Tput              2:dl:400:ul:320


Verify CB011006_A_MUE_SA_Call
    Prepare Variables for Validation    scenario_MUE
    run keyword and continue on failure    CB011006 . verify_SCF_Parameters    A    cell=4
    run keyword and continue on failure    CB011006 . verify_Tput              4:dl:200:ul:200
    run keyword and continue on failure    CB011006 . verify_DTX_Statistics    ul
    run keyword and continue on failure    CB011006 . verify_DTX_Statistics    dl


Verify CB011006_B11
    Prepare Variables for Validation    scenario_1
    run keyword and continue on failure    CB011006 . verify_Tput_CA_4cells    1:4:5:6:dl:700:ul:20    dlOnly
    run keyword and continue on failure    CB011006 . verify_DTX_Statistics    ul
    run keyword and continue on failure    CB011006 . verify_DTX_Statistics    dl
    run keyword and continue on failure    CB011006 . verify_PMC               4CC    cells:1:4:5:6:ues:2


Verify CB011006-B15
    Prepare Variables for Validation    scenario_2
    run keyword and continue on failure    CB011006_B15.Verify PMC Values
    run keyword and continue on failure    CB011006_B15.Verify Tput Values
    run keyword and continue on failure    CB011006.verify SCF Parameters    B15    cell=3


Verify CB011006-B19
    Prepare Variables for Validation    scenario_1
    run keyword and continue on failure    CB011006 . verify_Tput   3:dl:500:ul:400
    Prepare Variables for Validation    scenario_3
    run keyword and continue on failure    CB011006 . verify_Tput   3:dl:500:ul:400
    Prepare Variables for Validation    scenario_4
    run keyword and continue on failure    CB011006 . verify_Tput   3:dl:500:ul:400

    run keyword and continue on failure    CB011006_B19.Verify PMC Values
    run keyword and continue on failure    CB011006.verify SCF Parameters    B19    cell=3

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


Prepare Variables for Validation
    [Arguments]  ${scenario}
    ${collector_name}=  template.get_collector_name  scenario_name=${scenario}
    ${path_to_ttitrace_json}=  set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming.json
    ${path_to_ttitrace_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming.pkl
    ${path_to_syscom_pdml}=    set variable  ${ts_log_dir}/cell_setup_trace_initial/l2_l3_tcpdump.pdml
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
    ${events_required}=  Create List  utcTimeStampData     ulTdSchedSubcellData
    ...                               ulHarqRxData         dlHarqRxDataArray
    ...                               dlFdSchedData        ulFdSchedData
    ...                               dlLaDeltaCqiArray    ulLaDeltaSinr
    ...                               laIniDelta           csiSrReportData
    ...                               dlFdSchedAdditionalData
    ...                               ulFdSchedAdditionalData
    ttitrace.Convert TTI Trace From PCAP To Data Frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                 events_list=${events_required}
    ...                                                 write_to_pickle=${TRUE}
