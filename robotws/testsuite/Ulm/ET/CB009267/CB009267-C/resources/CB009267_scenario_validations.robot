*** Settings ***
Documentation    Scenario Validation keywords for CB009267-C subfeature

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    String
Library    ../../../../resources/Common/python/tti_analyzer_framework/tti_dataframe.py            WITH NAME  tti_dataframe
Library    ../libraries/CB009267_validation.py                                                    WITH NAME  CB009267

Resource   ../../../../resources/Common/ttitrace.robot


*** Keywords ***

Verify CB009267_5G_PM_1772_FR1
    Prepare Variables for Validation    scenario_PM_1772
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      1:3:dl:600:ul:200    dlAndUl
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      4:2:dl:500:ul:100    dlAndUl
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1772_FR1    cells:1:3
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1772_FR1    cells:4:2
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl


Verify CB009267_5G_PM_1777_FR1
    Prepare Variables for Validation    scenario_PM_1777
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      1:3:dl:500:ul:200    dlOnly
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      4:2:dl:200:ul:200    dlOnly
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1777_FR1    cells:1:3
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1777_FR1    cells:4:2
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl


Verify CB009267_5G_PM_1772_FR2
    Prepare Variables for Validation    scenario_PM_1772
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      1:2:dl:30:ul:50    dlAndUl    minimal
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      1:3:dl:30:ul:50    dlAndUl    minimal
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      1:4:dl:30:ul:50    dlAndUl    minimal
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1772_FR2    cells:1:2
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl


Verify CB009267_5G_PM_1777_FR2
    Prepare Variables for Validation    scenario_PM_1777
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      1:2:dl:30:ul:50    dlAndUl    minimal
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      1:3:dl:30:ul:50    dlAndUl    minimal
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      1:4:dl:30:ul:50    dlAndUl    minimal
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1777_FR2    cells:1:2
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl


Verify CB009267_5G_PM_1744_FR1
    Prepare Variables for Validation    scenario_PM_1744_overheating
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      1:3:dl:500:ul:80     dlAndUl
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      4:2:dl:200:ul:100    dlAndUl
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1744_FR1_tdd_pcell    cells:1:3
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1744_FR1_fdd_pcell    cells:4:2
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        ul


Verify CB009267_5G_PM_1816_and_1815_FR1
    ${scenario}=    Set Variable If    'PM_1816' in '${TEST NAME}'    scenario_PM_1816_UL_NACK_flooding    scenario_PM_1815_UL_NACK_flooding
    ${PM_counter}=    Set Variable If    'PM_1816' in '${TEST NAME}'    PM_1816    PM_1815

    Prepare Variables for Validation    ${scenario}
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      1:3:dl:180:ul:80    dlAndUl    # number of UEs in a cell x 1UE tput
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      4:2:dl:180:ul:80    dlAndUl    # number of UEs in a cell x 1UE tput
    Run Keyword And Continue On Failure    CB009267.Verify PMC              ${PM_counter}    cells:1:3
    Run Keyword And Continue On Failure    CB009267.Verify PMC              ${PM_counter}    cells:4:2
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        ul
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        dl


Verify CB009267_5G_PM_1077_FR1
    Prepare Variables for Validation    scenario_PM_1077
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      4:2:dl:20:ul:10     dlAndUl    minimal
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1077    cells:4:2
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl


Verify CB009267_5G_PM_1823_FR2
    Prepare Variables for Validation    scenario_PM_1744_1823_overheat_and_recover
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 4cells      1:2:3:4:dl:275:ul:200    dlAndUl
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1823_FR2    cells:1:2:3:4
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        ul


Verify CB009267_5G_PM_1744_FR2
    Prepare Variables for Validation    scenario_PM_1744_1823_overheat_and_recover
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 4cells      1:2:3:4:dl:275:ul:200    dlAndUl
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1744_FR2    cells:1:2:3:4
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        ul


Verify CB009267_5G_PM_1746_FR1
    Prepare Variables for Validation    scenario_PM_1746_overheating
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      1:3:dl:700:ul:100    dlOnly
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      4:2:dl:400:ul:90    dlOnly
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1746_FR1_tdd_pcell    cells:1:3
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1746_FR1_fdd_pcell    cells:4:2
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        ul


Verify CB009267_5G_PM_1743_FR1
    Prepare Variables for Validation    scenario_PM_1743
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 4cells      1:2:3:4:dl:400:ul:200    dlAndUl
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1823_FR2    cells:1:2:3:4
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        ul


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Verify CB009267_5G_PM_1825_FR2
    Prepare Variables for Validation    scenario_PM_1746_1825_overheat_and_recover
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      1:2:dl:10:ul:10    dlAndUl    minimal
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1825_FR2    cells:1:2:3:4
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        ul


Verify CB009267_5G_PM_1826_FR2
    Prepare Variables for Validation    scenario_PM_1826_SCELL_deact_after_susp
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1826_FR2    cells:1:2:3:4
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        ul


Verify CB009267_5G_PM_1746_FR2
    Prepare Variables for Validation    scenario_PM_1746_1825_overheat_and_recover
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      1:2:dl:10:ul:10    dlAndUl    minimal
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1746_FR2    cells:1:2:3:4
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        ul


Verify CB009267_5G_PM_1755_FR1
    Prepare Variables for Validation    scenario_PM_1755_ue_overheating_scell_deact
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      1:3:dl:500:ul:80    dlAndUl    minimal
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      4:2:dl:175:ul:80    dlAndUl    minimal
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1755_FR1_tdd_pcell    cells:1:3
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1755_FR1_fdd_pcell    cells:4:2
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        dl    PM_1755_FR1
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        ul


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Verify CB009267_5G_PM_1760_FR1
    Prepare Variables for Validation    scenario_PM_1760_overheating
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells   1:3:dl:400:ul:200    dlAndUl
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells   4:2:dl:200:ul:100    dlAndUl
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1760_FR1_tdd_pcell    cells:1:3
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1760_FR1_fdd_pcell    cells:4:2
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        ul


Verify CB009267_5G_PM_1851_FR1
    Prepare Variables for Validation    scenario_PM_1851_scell_overheating_scell_deact
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      1:3:dl:500:ul:80    dlAndUl    minimal
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      4:2:dl:175:ul:80    dlAndUl    minimal
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1851_FR1_tdd_pcell    cells:1:3
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1851_FR1_fdd_pcell    cells:4:2
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        dl    PM_1851_FR1
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        ul


Verify CB009267_5G_PM_1851_FR2
    Prepare Variables for Validation    scenario_PM_1851_overheating_fr2
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 4cells      1:2:3:4:dl:400:ul:200    dlAndUl
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1851_FR2    cells:1:2:3:4
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        ul


Verify CB009267_5G_PM_1853_FR1
    Prepare Variables for Validation    scenario_PM_1853_overheating_fr1
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      1:3:dl:400:ul:200    dlAndUl
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 2cells      4:2:dl:200:ul:100    dlAndUl
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1853_FR1_tdd_pcell    cells:1:3
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1853_FR1_fdd_pcell    cells:4:2


Verify CB009267_5G_PM_1853_FR2
    Prepare Variables for Validation    scenario_PM_1853_overheating_fr2
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 4cells      1:2:3:4:dl:400:ul:200    dlAndUl
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1853_FR2    cells:1:2:3:4


Verify CB009267_5G_PM_1754_FR2
    Prepare Variables for Validation    scenario_PM_1754
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        ul
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        dl
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 4cells   1:2:3:4:dl:350:ul:150    dlAndUl    minimal
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1754_FR2    cells:1:2:3:4:5:6

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Verify CB009267_5G_PM_1813_FR1
    Prepare Variables for Validation    scenario_PM_1813_low_split_pwr
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1813    cells:1:3
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1813    cells:4:2


Verify CB009267_5G_PM_1855_FR1
    Prepare Variables for Validation    scenario_PM_1855_low_buffer
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1855    cells:4:2
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl


Verify CB009267_5G_PM_1857_FR1
    Prepare Variables for Validation    scenario_PM_1857_low_buffer
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1857    cells:1:3
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl


Verify CB009267_5G_PM_1824_FR2
    Prepare Variables for Validation    scenario_PM_1824_SCELL_deact_after_susp
    Run Keyword And Continue On Failure    CB009267.Verify SCF Parameters
    Run Keyword And Continue On Failure    CB009267.Log Tput CA 4cells      1:2:3:4:dl:350:ul:160    dlAndUl    minimal
    Run Keyword And Continue On Failure    CB009267.Verify PMC              PM_1824_FR2    cells:1:2:3:4:5:6
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   ul
    Run Keyword And Continue On Failure    CB009267.Verify DTX Statistics   dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        dl
    Run Keyword And Continue On Failure    CB009267.Verify TTITraces        ul

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Prepare Variables For Validation
    [Arguments]  ${scenario}
    ${collector_name}=  template.Get Collector Name  scenario_name=${scenario}
    ${path_to_ttitrace_dl_pkl}=   Set Variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_dl.pkl
    ${path_to_ttitrace_ul_pkl}=   Set Variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_ul.pkl
    ${path_to_scf_xml}=        Set Variable  ${configuration_directory}/scf_${scenario}.xml
    ${path_to_syslog_tgz}=     Set Variable  ${ts_log_dir}/btslog_${collector_name}/btslog_gnb0/syslog_files.tgz
    ${pm_counters_dir}=        Set Variable  ${ts_log_dir}/PMC/gnb_pm_counters/
    ${PMC_INDEX}=  tools.Get Pmc Index  scenario=${scenario}  pmc_scenario_dict=${PMC_SCENARIO_DICT}  ts_log_dir=${TS_LOG_DIR}
    ${nrbts_str}=  gnb.Get DistNames From GNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${attached_ues}=  template.Get UE Ids Configured For Scenario  scenario_name=${scenario}
    Set Test Variable  ${path_to_ttitrace_dl_pkl}
    Set Test Variable  ${path_to_ttitrace_ul_pkl}
    Set Test Variable  ${path_to_scf_xml}
    Set Test Variable  ${path_to_syslog_tgz}
    Set Test Variable  ${pm_counters_dir}
    Set Test Variable  ${PMC_INDEX}
    Set Test Variable  ${nrbts_str}
    Set Test Variable  ${attached_ues}
    Set Test Variable  ${scenario}


Extract TTI Trace And Convert To JSON
     [Arguments]  @{varargs}
     RETURN


Extract TTI Trace And Convert To Pickle
    [Arguments]  ${path_to_tti_trace_pcap}
    ${events_required}=  Create List
    ...                             dlHarqRxDataArray                dlFdSchedData
    ...                             dlLaDeltaCqiArray                dlSCellActivationData
    ...                             dlFdSchedAdditionalData          dlRemoteSCellOHDeactivationData
    # write to pickle needs to be set to false, as we need to write for this TC the df to pickle with a different filename
    ${df}=    ttitrace.Convert TTI Trace From PCAP To Data Frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                           events_list=${events_required}
    ...                                                           write_to_pickle=${False}
    ${target_path_pkl}=    String.Replace String    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ttitrace_streaming_dl.pkl
    tti_dataframe.Write DF To Pickle    df=${df}    target_path=${target_path_pkl}
    ${target_path}=    String.Replace String    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ${EMPTY}
    ttitrace.Convert TTI Trace From Data Frame To CSV    ${df}
    ...                                                  ${target_path}
    ...                                                  tti_trace_filename=ttitrace_streaming_dl.csv

    ${events_required}=  Create List
    ...                             ulHarqRxData                ulFdSchedData
    ...                             ulLaDeltaSinr               ulSCellActivationData
    ...                             ulFdSchedAdditionalData
    # write to pickle needs to be set to false, as we need to write for this TC the df to pickle with a different filename
    ${df}=    ttitrace.Convert TTI Trace From PCAP To Data Frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                           events_list=${events_required}
    ...                                                           write_to_pickle=${False}
    ${target_path_pkl}=    String.Replace String    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ttitrace_streaming_ul.pkl
    tti_dataframe.Write DF To Pickle    df=${df}    target_path=${target_path_pkl}
    ttitrace.Convert TTI Trace From Data Frame To CSV    ${df}
    ...                                                  ${target_path}
    ...                                                  tti_trace_filename=ttitrace_streaming_ul.csv
