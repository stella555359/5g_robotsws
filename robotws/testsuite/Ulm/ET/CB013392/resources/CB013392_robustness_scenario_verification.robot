*** Settings ***
Documentation    CB013392 subfeature robustness scenario verification keywords

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    ../../L2/libraries/template_functions.py             WITH NAME  template
Library    ../libraries/CB013392_robustness_verification.py     WITH NAME  rob_verification

Resource    ../../../resources/Common/ttitrace.robot
Resource   CB013392_robustness_scenario_modifications.robot


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
*** Keywords ***

Verify CB013392_B_B2_TC01_IntragNB_A1_SCell_addition_DL_CA
    Prepare Variables For Verification     robustness_scenario
    Run Keyword And Continue On Failure    rob_verification.Verify SCF Parameters   cell=3
    Run Keyword And Continue On Failure    rob_verification.Verify Meas Profile Of CA UEs


Verify CB013392_B_B7_TC01_IntragNB_A2_SCell_release_DL_CA
    Prepare Variables For Verification     robustness_scenario
    Run Keyword And Continue On Failure    rob_verification.Verify SCF Parameters   cell=3
    Run Keyword And Continue On Failure    rob_verification.Verify Meas Profile Of CA UEs


Verify CB013392_C_B2_TC01_NSA_PScell_change_with_MeNB_power_coordination
    Prepare Variables For Verification     robustness_scenario
    Run Keyword And Continue On Failure    rob_verification.Verify SCF Parameters   cell=4
    Run Keyword And Continue On Failure    rob_verification.Verify Meas Profile Of NSA HO UEs


Prepare Variables For Verification
    [Arguments]  ${scenario}
    ${collector_name}=  template.Get Collector Name  scenario_name=${scenario}
    ${PATH_TO_SCF_XML}=     Set Variable  ${configuration_directory}/scf_${scenario}.xml
    Set Test Variable  ${PATH_TO_SCF_XML}
    ${NRBTS_STR}=           Get DistNames From GNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    Set Test Variable  ${NRBTS_STR}
    Set Test Variable  ${SYSLOG_DIR}    ${TS_LOG_DIR}/btslog_${collector_name}/btslog_gnb0

    CB013392_robustness_scenario_modifications.Prepare Variables For Results ${scenario}


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
    ...                               ulFdSchedAdditionalData
    ttitrace.Convert TTI Trace From PCAP To Data Frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                 events_list=${events_required}
    ...                                                 write_to_pickle=${TRUE}
