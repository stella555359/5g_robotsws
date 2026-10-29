*** Settings ***
Documentation     This contains common keywords which are needed to run P1 L3 Calls.
...               :author Shilpa V Swamy
...               : Modified as per need for FT Amitha Kadambi

Library    BuiltIn
Library    String
Library    Collections
Library    OperatingSystem
Library    taf.wts.runner    WITH NAME    wtsrunner
Library    ../TestCasePreChecks.py

Resource    ../../resources/ute/ute_wts_runner.robot
Resource    ../../resources/ute/sosReport.robot
Resource    ../../resources/ute/Traffic.robot
Resource    ../../resources/ute/AP_L1_log_collection.robot
Resource    ../../resources/Variables/common_variables.robot

*** Keywords ***
Common Suite Setup
    [Documentation]    This keyword is used to start the UTE SCTP timeout and WTS related process at the start of suite
    ...                The sos report logs collection will be started
    ...                Modified Date: 22-Dec-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Get Component Carrier Variables
    Check and Override Multicell RU Type From File
    Wait Coam Site to be Ready
    ute_wts_runner.Check for 6765-D feature enabled and Verify DCI
    ute_wts_runner.Modify UTE SCTP Timeout
#    ute_wts_runner.Start UTE WTS
    ${start_time}   Run Keyword And Ignore Error    Get Current DateTime
    Set Suite Variable    ${start_time}

Common Optimized Suite Setup
    [Documentation]    This keyword is used load test suite varaibles dynamically based on TOPOLOGY value
    ...                This keyword need to be removed once individual test suite are removed in repo:
    ...                Modified Date: 31-May-2021
    ...                Last Modified by: praveen.t_k@nokia.com
#    ${WTS_VM_Statistics}=    Get Variable Value    ${Collect_WTS_Stats}    False
#    Set Suite Variable    ${WTS_VM_Statistics}
#    Run Keyword If    '${WTS_VM_Statistics}' == 'True'    Run Keyword and Ignore Error   Start Collecting WTS VM Statistics
    Get AP Suite Configuration Variables
    Common Suite Setup

Start Collecting WTS VM Statistics
    Start WTS Top Output Capture
    List All WTS Process    Before Start of Test Execution    ${wts_vm_process_suitesetup}

Stop Collecting WTS VM Statistics
    Sleep   2s
    Stop WTS Top Output Capture
    List All WTS Process    After Completion of Test Execution    ${wts_vm_process_suiteteardown}
    Collect WTS VM System Info
    Collect WTS VM Statistics Logs

List All WTS Process
    [Arguments]    ${message}    ${output_file}
    Run    echo "*** Get All process list ${message} ***\n" > ${output_file}
    Run    echo "*** ps -aux command output ***\n" >> ${output_file}
    Run    ps -aux >> ${output_file}

    Run    echo "*** Get All zombie process list if any ***\n" >> ${output_file}
    Run    echo "*** top -b1 -n1 | grep Z command output ***\n" >> ${output_file}
    Run    top -b1 -n1 | grep Z >> ${output_file}
    Run    echo "*** ps -aux | grep 'Z|defunct' ***\n" >> ${output_file}
    Run    ps -aux | grep "Z|defunct" >> ${output_file}

Collect WTS VM System Info
    Run    echo "*** Output of process lists ***\n" > ${wts_vm_system_info}
    Run    echo "\n*** /proc/cpuinfo command output ***\n" >> ${wts_vm_system_info}
    Run    cat /proc/cpuinfo >> ${wts_vm_system_info}
    Run    echo "\n*** free -h command output ***\n" >> ${wts_vm_system_info}
    Run    free -h >> ${wts_vm_system_info}

Start WTS Top Output Capture
    Run    rm -f ${EXECDIR}/${wts_vm_top_results}
    Start Process    top -d 0.1 -b >> wts_vm_top_results.txt    shell=yes

Stop WTS Top Output Capture
    Run    pkill -f top

Collect WTS VM Statistics Logs
    Run    mkdir WTS_VM_Statistics
    Run    mv ${wts_vm_process_suitesetup} WTS_VM_Statistics
    Run    mv ${wts_vm_process_suiteteardown} WTS_VM_Statistics
    Run    mv ${wts_vm_system_info} WTS_VM_Statistics
    Run    mv ${wts_vm_top_results} WTS_VM_Statistics
    Run    tar -cf WTS_VM_Statistics.tar WTS_VM_Statistics
    Run    mv WTS_VM_Statistics.tar ${EXECDIR}/logs

Remove old gNB and AP BIP Logs
    SSH.Connect To    ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
#    SSH.Execute       rm -rf ${sosReportMainDir}/*.pcap* ${sosReportStbDir}/*.pcap*    ${AP_ASIK}[Connection]
#    SSH.Execute       rm -rf ${pcapRunDir}/*.pcap* ${pcapStbDir}/*.pcap*    ${AP_ASIK}[Connection]
#    SSH.Execute       bsh 0:0 rm -rf ${sosReportLogDir}/*.pcap*    ${GNB_ASIK}[Connection]
    SSH.Execute       ls -lh ${sosReportLogDir}    ${GNB_ASIK}[Connection]
    SSH.Disconnect    ${GNB_ASIK.Connection}

Common Suite Teardown
    [Documentation]    This keyword is used to stop the Log collection at the end of the Suite
    ...                Teardowns the Edaemon and Egate process at the end of suite
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
#    Collect Logs For Run
#    Run Keyword If    (('${gnb_sm_hardware}' == 'ASIK') and ('${ap_sm_hardware}' == 'ASIK')) or ('${ap_sm_hardware}' == 'ASIL')
#    ...    Run Keyword and Ignore Error    Set WTS Default Log Level to Error Level
    Run Keyword and Ignore Error    ute_wts_runner.Teardown Edaemon and Egate process
#    Run Keyword and Ignore Error    Stop WTS Tcpdump
#    ${WTS_VM_Statistics}=    Get Variable Value    ${Collect_WTS_Stats}    False
#    Run Keyword If    '${WTS_VM_Statistics}' == 'True'    Run Keyword and Ignore Error    Stop Collecting WTS VM Statistics
    ${gNB_status}    Run Keyword And Return Status    Wait Coam Site to be Ready
    Run Keyword Unless    ${gNB_status}    Collect Logs when gNB Status Is not As Expected
    Run Keyword and Ignore Error    Check NIDD and make update on testconfigs repo

Collect Logs when gNB Status Is not As Expected
    [Documentation]    This keyword is used to collect the log if gNB is not in expected state.
    ...                Modified Date: 24-May-2022
    ...                Last Modified by: hemanth.kumar_s_n@nokia.com
    Run Keyword And Continue on Failure    Fail    gNB was not in the expected state
    Collect Logs For Run

X2 Connection Test Setup
    [Documentation]    This keyword is used to start the sosReport for the cell setup at the TestCase Level for X2 Connection
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Stop Tcpdump For Init
    Start sosReport Tcpdump    cell_setup

UE Register Test Setup
    [Documentation]    This keyword is used to start the sosReport for the cell setup at the TestCase Level for UE Register
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Stop Tcpdump For Init
    Start sosReport Tcpdump    cell_setup

UE Deregister Test Teardown for SANSA
    [Documentation]    This keyword is used at the Testcase level to stop attach and data traffic
    ...                and collects the UTE sos report for the UE Deregister for SANSA Variants
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Stop Attach and Data Traffic TCPDUMP
    Run Keyword If    '${CONDITIONAL_LOGGING}' == 'False' or '${TEST STATUS}' == 'FAIL'
    ...    ute_wts_runner.Collect UTE SosReport

UE Register Test Setup for SANSA
    [Arguments]    ${prefix}=attach_traffic
    [Documentation]    This keyword is used at the Testcase level to stop sos report TCPDUMP
    ...                and start attach and data traffic TCPDUMP for UE Register for SANSA variants
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Run Keyword If    '${4G5G_Combo}'=='0'   Requires Tc    X2 Connection
    ${exclude_pcap}=   Set Variable If   '${CONDITIONAL_LOGGING}' == 'True'   1   0
    Stop sosReport Tcpdump    init    ${exclude_pcap}
    Start Attach and Data Traffic TCPDUMP    ${prefix}

Stop Tcpdump For Init
    [Documentation]    This keyword is used to stop the sosReport Tcpdump for Init at the TestCase Level for NSA Variants
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${exclude_pcap}=   Set Variable If   '${CONDITIONAL_LOGGING}' == 'True'   1   0
    Run Keyword And Ignore Error   Stop sosReport Tcpdump    init   ${exclude_pcap}

Stop Tcpdump For CellSetup
    [Documentation]    This keyword is used to stop the sosReport Tcpdump for cell setup at the TestCase Level for NSA Variants
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${exclude_pcap}=   Check If PCAP Is To Be Excluded
    Run Keyword And Ignore Error   Stop sosReport Tcpdump    cell_setup   ${exclude_pcap}

Stop Tcpdump for Attach and Dta Traffic
   [Documentation]    This keyword is used to stop the sosReport Tcpdump for Traffic at the TestCase Level for NSA Variants
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
   ${exclude_pcap}=   Check If PCAP Is To Be Excluded
   Run Keyword and Ignore Error    Stop sosReport Tcpdump    attach_traffic   ${exclude_pcap}
   Run Keyword and Ignore Error    Delete PCAPs from gNB and AP

UE Re-register Test Setup
    [Documentation]    This keyword is used at the start of UE Re-Register where the sosReport is stopped for the cell setup
    ...                And starts the TCPDUMP for Attach and Data Traffic
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Requires Tc   UE Deregister
    Stop sosReport Tcpdump    cell_setup
    Start Attach and Data Traffic TCPDUMP

NG Link Should be UP
    [Documentation]    This keyword checks if the NG link is up for the SA variant in egate_console.log file
    ...                Modified Date: 10-Jun-2021
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}
    ...    NG link check using AMF Link Status    ${AMF_ID}    ${TARGET_GNB}
    Run Keyword If    '${4G5G_Combo}'=='1'
    ...    S1 link check for eNB
    Log                ng_link_status_is_ok

Address Distribution should be Successful
    [Documentation]    This keyword checks if the Address Distribution is completed for the SA variant in egate_console.log file
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Check Pattern in APL3 Log    ${Address_distribution_pattern}
    Log                address_distribution_is_ok

AP Cell Setup should be Successful
    [Documentation]    This keyword checks if the Cell Setup completed in egate_console.log file
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    FOR   ${cell_id}   IN RANGE   ${component_carrier}
        ${validation_string}=    Set Variable    ${EMPTY}
        ${validation_string}=    Catenate    ${Cell_setup_complete_pattern}     for \\[CELL_ID:${cell_id + 1}\\]
        Check Pattern in APL3 Log    ${validation_string}
    END
    Run Keyword If    '${4G5G_Combo}'=='1'
    ...    Check Pattern in Egate Console Log    cell ${enb_cell_id}: ${UE_SIB_decoding_pattern_eNB}
    sleep              5s
    Log                cell_setup_is_ok

UE SIB Decoding should be Successful
    [Documentation]    This keyword checks if the UE sib decoding is completed for the SA variant in egate_console.log file
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    FOR   ${cell_id}   IN RANGE   ${component_carrier}
        ${validation_string}=    Set Variable    ${EMPTY}
        ${validation_string}=    Catenate    cell ${cell_id + 1}:     ${UE_SIB_decoding_pattern}
        ${status}    Run Keyword And Return Status    Check Pattern in Egate Console Log    ${validation_string}
        Run Keyword If    '${4G5G_Combo}'=='1'
        ...    UE SIB Decoding should be Successful for TRS    ${cell_id}
        Log                ue_sib_decoding_is_ok
    END

UE SIB Decoding should be Successful for TRS
    [Arguments]    ${cell_id}
    [Documentation]    This keyword checks if the UE sib decoding is completed for the SA variant in egate_console.log file
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: anil.1.pachauri@nokia.com
    ${validation_string}=    Set Variable    eNB 2 cell ${cell_id + 1}: ${UE_SIB_decoding_pattern}
    ${status}    Run Keyword And Return Status    wtsrunner.read_wtsemu_output_until_re
    ...          expected=${validation_string}     timeout=300
    Run Keyword If    '${status}' == 'False'
    ...    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}
    ...    Check SIB Decoding for TRS    ${validation_string}

Check SIB Decoding for TRS
    [Arguments]    ${pattern}    ${file}=${run_script_log_set}
    [Documentation]    This keyword checks if the ${pattern} is present in the egate_console.log file for TRS
    ...                Modified Date: 16-Dec-2021
    ...                Last Modified by: anil.1.pachauri@nokia.com
    wtsrunner.script    file=${file}    entry=sim_log_set_flush()
    Search pattern should Exists In EGATE    ${WTS_DIR}/egate_console.log     ${pattern}

Check Pattern in Egate Console Log
    [Arguments]    ${pattern}    ${file}=${run_script_log_set}
    [Documentation]    This keyword checks if the ${pattern} is present in the egate_console.log file for the SA variant
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Run Keyword If    '${variant_name}' != '4G5G_COMBO_MultiUE'
    ...    wtsrunner.script    file=${file}    entry=sim_log_set_flush()
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Search pattern should Exists In EGATE
    ...                            ${WTS_DIR}/egate_console.log     ${pattern}

Check Pattern in APL3 Log
    [Arguments]    ${pattern}
    [Documentation]    This keyword checks if the ${pattern} is present in the APL3.log file
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Search grep pattern should Exists
    ...    /tmp/startup_l3.log    ${pattern}

UE Register should be Successful
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.ue_register   id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}    ue=${UE_ID}    nwslice=${nwslice_ID}    gw=${gw_ID}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    Log                first_ue_register_is_ok

UE Register should be Successful for SA
    [Arguments]    ${UE_ID}=${UE_ID}    ${gw_ID}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SANSA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.ue_register   id=${UE_ID}

    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param   ue=${UE_ID}    pdu=${Pdu_session_ID}    trf_type=${Trf_type}
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}    ue=${UE_ID}   nwslice=${nwslice_ID}   gw=${gw_ID}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}

UE Register should be Successful for SA_11123
    [Arguments]    ${UE_ID}=${UE_ID}    ${gw_ID}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SANSA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.ue_register   id=${UE_ID}

    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param   ue=${UE_ID}    pdu=${Pdu_session_ID}    trf_type=${Trf_type}
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}    ue=${UE_ID}   nwslice=${nwslice_ID}   gw=${gw_ID}
    Read WTS Output For Pattern And Print matching Lines    ${11123_nomwithgrant}    ${Timeout_SA}
    Read WTS Output For Pattern And Print matching Lines    ${11123_nominal}    ${Timeout_SA}


UE Register should be Successful for SA_7103B
    [Arguments]    ${UE_ID}=${UE_ID}    ${gw_ID}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SANSA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.ue_register   id=${UE_ID}

    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param   ue=${UE_ID}    pdu=${Pdu_session_ID}    trf_type=${Trf_type}
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}    ue=${UE_ID}   nwslice=${nwslice_ID}   gw=${gw_ID}
    Read WTS Output For Pattern And Print matching Lines    ${pucchr16_7103}    ${Timeout_SA}

UE Register should be Successful for SA_7103A
    [Arguments]    ${UE_ID}=${UE_ID}    ${gw_ID}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SANSA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.ue_register   id=${UE_ID}

    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param   ue=${UE_ID}    pdu=${Pdu_session_ID}    trf_type=${Trf_type}
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}    ue=${UE_ID}   nwslice=${nwslice_ID}   gw=${gw_ID}
    Read WTS Output For Pattern And Print matching Lines    ${pusch16_7103}    ${Timeout_SA}

UE Register should be Successful for 12544B
    [Arguments]    ${UE_ID}=${UE_ID}    ${gw_ID}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SANSA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.ue_register   id=${UE_ID}

    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param   ue=${UE_ID}    pdu=${Pdu_session_ID}    trf_type=${Trf_type}
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}    ue=${UE_ID}   nwslice=${nwslice_ID}   gw=${gw_ID}
    Read WTS Output For Pattern And Print matching Lines    ${r17_12544}    ${Timeout_SA}


UE Register should be Successful for SA_CB010887_TC3
    [Arguments]    ${UE_ID}=${UE_ID}    ${gw_ID}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SANSA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.ue_register   id=${UE_ID}

    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param   ue=${UE_ID}    pdu=${Pdu_session_ID}    trf_type=${Trf_type}
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}    ue=${UE_ID}   nwslice=${nwslice_ID}   gw=${gw_ID}
    Read WTS Output For Pattern And Print matching Lines    ${CB010887TC3_codebook}    ${Timeout_SA}

UE pathloss_7103
    [Arguments]    ${profile_id}=${profile_id}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SANSA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.ul_sinr_testmode_nr   profile_id=${profile_id}    pathloss=130

#    ${output}         String.Get Lines Matching Regexp         ${output}, ${pucchprecoding_7103}, partial_match=${TRUE}
    ${output}    Read WTS Output Until Pattern Matches    ${pucchprecoding_7103}    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${pucchprecoding_7103}
    Log to Console      ${pucchprecoding_7103}

UE Register should be Successful for SA Ng HO FDD
    [Arguments]    ${UE_ID}=${UE_ID}    ${gw_ID}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SANSA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.ue_register   id=${UE_ID}

    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param   ue=${UE_ID}    pdu=${Pdu_session_ID}    trf_type=${Trf_type}
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}    ue=${UE_ID}   nwslice=${nwslice_ID}   gw=${gw_ID}
    Read WTS Output For Pattern And Print matching Lines    ${reestablishment_pattern}     ${Timeout_SA}

UE Register should be Successful for SANSA
    [Documentation]    This keyword checks the message for the completion of UE Registration in the output file for the SANSA variant
    ...                Modified Date: 25-Jun-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    FOR   ${ueid}    ${gwid}   IN ZIP   ${sa_ueids}    ${gw_ids}
        UE Register should be Successful for SA    ${ueid}    ${gwid}
    END
    Log    ue_register_is_ok

UE Reregister should be Successful for SANSA
    [Documentation]    This keyword checks the message for the completion of UE Reregistration in the output file for the SANSA variant
    ...                Modified Date: 25-Jun-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Sleep    ${UE_Reregister_sleep}
    FOR   ${ueid}    ${gwid}   IN ZIP   ${sa_ueids}    ${gw_ids}
        UE Register should be Successful for SA    ${ueid}    ${gwid}
    END
    Log    ue_re-register_is_ok

UE Reregister should be Successful
    [Documentation]    This keyword checks the message for the completion of UE re-registration in the output file for the SA variant
    ...                Modified Date: 01-June-2021
    ...                Last Modified by: praveen.t_k @nokia.com
    wtsrunner.ue_register   id=${UE_ID}
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${Register_complete_pattern}    ${Timeout_SA}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param   ue=${UE_ID}   pdu=${Pdu_session_ID}   trf_type=${Trf_type}
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}   ue=${UE_ID}   nwslice=${nwslice_ID}   gw=${gw_ID}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    Log                second_ue_register_is_ok

Initial Success Message for UE Register and Reregister
    [Arguments]    ${output}
    [Documentation]    This keyword checks the Initial status message for the completion of UE Registration
    ...                And UE Re-registration in the output file for the SA variant
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Should Contain    ${output}    ${Initial_UE_message_pattern}    ignore_case=True
    Print Matching Lines from Output File    ${output}    ${Initial_UE_success_pattern}

UE Deregister should be Successful for SA
    [Arguments]    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.ue_deregister    id=${UE_ID}    ue_deregister_type=switch_off
    Read WTS Output For Pattern And Print matching Lines    ${UE_deregister_pattern}    ${Timeout_SA}
    Log                ue_deregister_is_ok

UE Deregister should be Successful
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    ...                Modified Date: 25-Jun-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    FOR   ${ueid}   IN   @{sa_ueids}
        UE Deregister should be Successful for SA    ${ueid}
    END

Traffic for SA should be Successful
    [Arguments]    ${traffic_dl_rate}=${Traffic_dl_rate}    ${traffic_ul_rate}=${Traffic_ul_rate_SA}
    [Documentation]    This keyword starts and Validates the Traffic for the SA variant
    ...                Modified Date: 08-Aug-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Run Keyword If    (('${gnb_sm_hardware}' == 'ASIK') and ('${ap_sm_hardware}' == 'ASIK')) or ('${ap_sm_hardware}' == 'ASIL')
    ...    Run Keyword And Ignore Error    Set WTS Default Log Level to Error Level
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${duration}
    ${dataloss_validate_list}=    Create List
    ${tput_validate_list}=    Create List
    FOR   ${ueid}   IN   @{sa_ueids}
        Start Traffic For SA   ${ueid}    ${traffic_dl_rate}    ${traffic_ul_rate}    ${duration}
    END

    Sleep    ${duration}

    FOR   ${ueid}   IN   @{sa_ueids}
        ${trf_sa_status}    Run Keyword And Ignore Error    Validate Traffic Throughput Average Rate for SA
        ...    ${traffic_dl_rate}    ${traffic_ul_rate}    ${ueid}
        Stop Traffic For SA    ${ueid}
        ${status}    Run Keyword And Ignore Error    Should Be True    '${trf_sa_status[0]}' == 'PASS'
        ...    msg=Traffic failed, see error above!
        Append To List    ${tput_validate_list}    ${status[0]}
        ${trf_dataloss_status}    Run Keyword And Ignore Error    Validate Traffic Data Loss For SA    ${traffic_dl_rate}
        ...    ${traffic_ul_rate}    ${ueid}
        ${dataloss_status}    Run Keyword And Ignore Error    Should Be True    '${trf_dataloss_status[0]}' == 'PASS'
        ...    msg=Traffic failed, see error above!
        Append To List    ${dataloss_validate_list}    ${dataloss_status[0]}
    END
    List Should Not Contain Value    ${tput_validate_list}    FAIL    msg=Traffic failed in Throughput, see error above!
    List Should Not Contain Value    ${dataloss_validate_list}    FAIL    msg=Traffic failed in Data Loss, see error above!

    Run Keyword If    (('${gnb_sm_hardware}' == 'ASIK') and ('${ap_sm_hardware}' == 'ASIK')) or ('${ap_sm_hardware}' == 'ASIL')
    ...    Run Keyword And Ignore Error    Set WTS Default Log Level to Debug

Traffic should be successful for SA
    [Arguments]    ${traffic_dl_rate}=${Traffic_dl_rate}    ${traffic_ul_rate}=${Traffic_ul_rate_SA}    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword starts and Validates the Traffic for the SA variant
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    ute_wts_runner.Start and Validate Traffic For SA    dl_rate=${traffic_dl_rate}    ul_rate=${traffic_ul_rate}    UE_ID=${UE_ID}
    Log    traffic_is_ok

X2AP Link Should be UP
    [Documentation]    This keyword is used to Create a X2 connection with gNB
    ...                And checks if the X2AP link with the gNB is UP in the output file.
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    wtsrunner.enb_x2_link_up    enb=${eNB_ID}    target=${eNB_target}
    Read WTS Output For Pattern And Print matching Lines    ${X2_link_pattern}    ${Timeout_NSA}
    Log    x2_is_ok

LTE Attach should be Successful for NSA
    [Arguments]    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    wtsrunner.ue_attach    id=${UE_ID}
    Read WTS Output For Pattern And Print matching Lines    ${LTE_attach_pattern}    ${Timeout_NSA}
    Log    lte_attach_is_ok

LTE Attach should be Successful
    [Arguments]    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ...                Modified Date: 25-Jun-2021
    ...                Last Modified by: praveen.t_k@nokia.com
#    FOR   ${ueid}   IN   @{nsa_ueids}
     LTE Attach should be Successful for NSA    ${UE_ID}
#    END

UE Attach should be Successful with eNB
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ...                Modified Date: 30-July-2021
    ...                Last Modified by: kokila.b@nokia.com
    FOR   ${ueid}   IN   @{lte_ueids}
        LTE Attach should be Successful for NSA    ${ueid}
    END

UE Attach should be Successful for 4G5GComboNSA
    [Arguments]    ${UE_ID}=${UE_ID}    ${nrsrp}=${nrsrp}   ${4G5G_phycellid}=${4G5G_phycellid}     ${nrsrp}=${nrsrp}
    ...    ${nr_cgi_plmn_ident_info_id}=${nr_cgi_plmn_ident_info_id}   ${nr_cgi_cell_ident}=${nr_cgi_cell_ident}
    ...    ${nr_cgi_plmns_ident}=${nr_cgi_plmns_ident}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    ...                Modified Date: 30-July-2021
    ...                Last Modified by: kokila.b@nokia.com
    wtsrunner.ue_measurement_send    id=${UE_ID}    phycell_id=${4G5G_phycellid}
    ...    nr_cgi_plmn_ident_info_id=${nr_cgi_plmn_ident_info_id}    nr_cgi_cell_ident=${nr_cgi_cell_ident}
    ...    nr_cgi_plmns_ident=${nr_cgi_plmns_ident}    nrsrp=${nrsrp}    event=${event}
    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
    Log    ue_attach_is_ok

UE Attach should be Successful for NSA
    [Arguments]    ${UE_ID}=${UE_ID}    ${Target_Cells}=${Target_Cells}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Target_Cells}    ue=${UE_ID}
    ...                         bearer=${Bearer_ID}    type=split_scg
    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
    [Return]    ${match_str}

UE Attach should be Successful
    [Arguments]    ${UE_ID}    ${targetcell}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    ...                Modified Date: 25-Jun-2021
    ...                Last Modified by: praveen.t_k@nokia.com
#    FOR   ${ueid}    ${targetcell}   IN ZIP   ${nsa_ueids}    ${targetcell_ids}
     UE Attach should be Successful for NSA    ${UE_ID}    ${targetcell}
#    END

UE Attach should be Successful for 4G5GCombo
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    ...                Modified Date: 30-July-2021
    ...                Last Modified by: kokila.b@nokia.com
    FOR   ${ueid}   IN   @{nsa_ueids}
        UE Attach should be Successful for 4G5GComboNSA    ${ueid}
    END

Traffic should be Successful for NSA
    [Arguments]    ${ue_id}=${UE_ID}    ${traffic_dl_rate}=${Traffic_dl_rate}
    ...    ${traffic_ul_rate}=${Traffic_ul_rate_${duplexing}}
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD variants
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    ute_wts_runner.Start Traffic    UE_ID=${ue_id}    dl_rate=${traffic_dl_rate}    ul_rate=${traffic_ul_rate}
    Log    traffic_is_ok

Traffic for NSA should be Successful
    [Arguments]    ${ue_id}=${UE_ID}    ${traffic_dl_rate}=${Traffic_dl_rate}    ${traffic_ul_rate}=${Traffic_ul_rate_${duplexing}}
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD/TDD variants
    ...                Modified Date: 08-Aug-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Run Keyword If    (('${gnb_sm_hardware}' == 'ASIK') and ('${ap_sm_hardware}' == 'ASIK')) or ('${ap_sm_hardware}' == 'ASIL')
    ...    Run Keyword And Ignore Error    Set WTS Default Log Level to Error Level
    ${duration}    Get Variable Value    ${TRF_DURATION}    ${duration}
    ${dataloss_validate_list}=    Create List
    ${tput_validate_list}=    Create List
    FOR   ${ueid}   IN   @{nsa_ueids}
        Start Traffic For NSA   ${ueid}    ${traffic_dl_rate}    ${traffic_ul_rate}    ${duration}
    END

    Sleep    ${duration}

    FOR   ${ueid}   IN   @{nsa_ueids}
        ${trf_nsa_status}    Run Keyword And Ignore Error    Validate Traffic Throughput Average Rate for NSA
        ...    ${traffic_dl_rate}    ${traffic_ul_rate}    ${ueid}
        Stop Traffic For NSA    ${ueid}
        ${status}    Run Keyword And Ignore Error    Should Be True    '${trf_nsa_status[0]}' == 'PASS'
        ...    msg=Traffic failed, see error above!
        Append To List    ${tput_validate_list}    ${status[0]}
        ${trf_dataloss_status}    Run Keyword And Ignore Error    Validate Traffic Data Loss For NSA    ${traffic_dl_rate}
        ...    ${traffic_ul_rate}    ${ueid}
        ${dataloss_status}    Run Keyword And Ignore Error    Should Be True    '${trf_dataloss_status[0]}' == 'PASS'
        ...    msg=Traffic failed, see error above!
        Append To List    ${dataloss_validate_list}    ${dataloss_status[0]}
    List Should Not Contain Value    ${tput_validate_list}    FAIL    msg=Traffic failed in Throughput, see error above!
    List Should Not Contain Value    ${dataloss_validate_list}    FAIL    msg=Traffic failed in Data Loss, see error above!
    END

    Run Keyword If    (('${gnb_sm_hardware}' == 'ASIK') and ('${ap_sm_hardware}' == 'ASIK')) or ('${ap_sm_hardware}' == 'ASIL')
    ...    Run Keyword And Ignore Error    Set WTS Default Log Level to Debug
    Log                traffic_is_ok

LTE Traffic should be Successful
    [Arguments]    ${ue_id}=${UE_ID}    ${traffic_dl_rate}=${Traffic_dl_rate}
    ...     ${traffic_ul_rate}=${Traffic_ul_rate_${duplexing}}
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD/TDD variants
    ...                Modified Date: 30-July-2021
    ...                Last Modified by: kokila.b@nokia.com

    FOR   ${ueid}   IN   @{lte_ueids}
        LTE Traffic    ${ueid}    ${traffic_dl_rate}    ${traffic_ul_rate}
    END

LTE Traffic
    [Arguments]    ${ue_id}=${UE_ID}    ${traffic_dl_rate}=${Traffic_dl_rate}
    ...    ${traffic_ul_rate}=${Traffic_ul_rate_${duplexing}}
    [Documentation]    This keyword starts and Validates the Traffic for the NSA FDD variants
    ...                Modified Date: 08-Aug-2021
    ...                Last Modified by: kokila.b@nokia.com
    ute_wts_runner.Start LTE Traffic    UE_ID=${ue_id}    dl_rate=${traffic_dl_rate}    ul_rate=${traffic_ul_rate}
    Log    traffic_is_ok

UE 5GDetach should be Successful for NSA
    [Arguments]    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword is used to Detach the UE from 5G connection with gNB and checks the completion message in output file.
    ...                Enhance the keyword to detach SANSA UE as well.
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    wtsrunner.enb_ue_dc_release    ue=${UE_ID}    bearer=${Bearer_ID}    by=enb    cause=off
    Read WTS Output For Pattern And Print matching Lines    ${UE_5GDetach_pattern}    ${Timeout_NSA}
    Log          5gdetach_is_ok

UE 5GDetach should be Successful
    [Arguments]    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword is used to Detach the UE from 5G connection with gNB and checks the completion message in output file.
    ...                Enhance the keyword to detach SANSA UE as well.
    ...                Modified Date: 25-Jun-2021
    ...                Last Modified by: praveen.t_k@nokia.com
#    FOR   ${ueid}   IN   @{nsa_ueids}
     UE 5GDetach should be Successful for NSA    ${UE_ID}
#    END

UE Detach should be Successful with eNB
    [Documentation]    This keyword is used to Detach the UE with gNB and checks the completion message in output file.
    ...                Modified Date: 30-July-2021
    ...                Last Modified by: kokila.b@nokia.com
    FOR   ${ueid}   IN   @{lte_ueids}
        UE Detach should be Successful for NSA    ${ueid}
    END

UE Detach should be Successful for NSA
    [Arguments]    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword is used to Detach the UE with gNB and checks the completion message in output file.
    ...                Modified Date: 31-March-2021
    ...                Last Modified by: anil.1.pachauri@nokia.com
    wtsrunner.ue_detach    id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_detach_pattern}    ${Timeout_NSA}
    Print Matching Lines from Output File    ${output}    ${UE_detach_pattern}
    Log    detach_is_ok
    Log to Console     \nDetach ----  ${match_str}
    ${value_ms}     mscalc      ${match_str}
    [Return]        ${value_ms}

UE Detach should be Successful
    [Arguments]    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword is used to Detach the UE with gNB and checks the completion message in output file.
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
#    FOR   ${ueid}   IN   @{nsa_ueids}
     ${value_ms}    UE Detach should be Successful for NSA    ${UE_ID}
#    END
     [Return]       ${value_ms}

UE Reattach should be Successful for NSA
    [Arguments]    ${UE_ID}=${UE_ID}    ${Target_Cells}=${Target_Cells}     ${4G5G_Combo}=${4G5G_Combo}
    [Documentation]    This keyword is used to Reattach the UE with gNB and checks the completion message in the output file.
    ...                Modified Date: 30-June-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Sleep    ${UE_Reattach_sleep}
    LTE Attach should be Successful for NSA    ${UE_ID}
    Run Keyword If    '${4G5G_Combo}'=='0'
    ...    UE Attach should be Successful for NSA    ${UE_ID}    ${Target_Cells}    ELSE
    ...    UE Attach should be Successful for 4G5GComboNSA    ${UE_ID}
    Log    attach2_is_ok
    Log    ue_reattach_is_ok

UE Reattach should be Successful with eNB
    [Documentation]    This keyword is used to Reattach the UE with gNB and checks the completion message in the output file.
    ...                Modified Date: 30-July-2021
    ...                Last Modified by: kokila.b@nokia.com
    Sleep    ${UE_Reattach_sleep}
    FOR    ${ueid}    IN    @{lte_ueids}
        LTE Attach should be Successful for NSA    ${ueid}
        Log    ue_reattach_is_ok
    END

UE Reattach should be Successful
    [Documentation]    This keyword is used to Reattach the UE with gNB and checks the completion message in the output file.
    ...                Modified Date: 25-Jun-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    FOR   ${ueid}    ${targetcell}   IN ZIP   ${nsa_ueids}    ${targetcell_ids}
        UE Reattach should be Successful for NSA   ${ueid}   ${targetcell}
    END

Read WTS Output For Pattern And Print matching Lines
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks if the ${pattern} is present in the output file and prints the line matching the pattern.
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${output}    Read WTS Output Until Pattern Matches   ${pattern}    ${timeout}
    Print Matching Lines from Output File    ${output}    ${pattern}
    [Return]    ${output}

Read WTS Output Until Pattern Matches
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks the output file until the ${pattern} matches in the file.
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=${pattern}
    ...    timeout=${timeout}
    [Return]    ${output}

Print Matching Lines from Output File
    [Arguments]    ${output}    ${pattern}
    [Documentation]    This keyword Prints the lines which contains the ${pattern} from the output file ${output}
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${output}        Get Lines Matching Regexp    ${output}    ${pattern}
    ...               partial_match=${TRUE}
    set suite variable      ${match_str}   ${output}
    Log to Console    \n ${output}

Check if AP L1 Log needs to be Collected
    [Arguments]    ${status}
    [Documentation]    This keyword is used to check if AP L1 log needs to be collected based on flags
    ...                Modified Date: 17-May-2021
    ...                Last Modified by: ramya.2.k@nokia.com
    Return From Keyword If    '${CONDITIONAL_LOGGING}' == 'True' and '${status}' == 'PASS'
    ${l1_log}=    Set Variable If    '${AP_L1_Log}' == 'True' or '${status}' == 'FAIL'    1    0
    [Return]   ${l1_log}

Collect AP L1 Log
    [Arguments]    ${folder}    ${status}
    [Documentation]    This keyword is used to collect ring buffer dump and register dump.
    ...                Modified Date: 17-May-2021
    ...                Last Modified by: ramya.2.k@nokia.com
    ${l1_log}    Check if AP L1 Log needs to be Collected    ${status}
    Run Keyword If    '${l1_log}' == '1' and '${l1}' == 'FS'
    ...    Run Keyword And Ignore Error    Airphone L1 Log Collection    ${folder}

Get AP Suite Configuration Variables
    [Documentation]    This keyword will identify the variables related to ap_configurations
    ...                Modified Date: 14-April-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    ${var}=    Get Variable Value    ${TOPOLOGY}
    ${var_exists}=      Set Variable If    "${var}" != 'None'    ${True}    ${False}
    Run Keyword If    '${var_exists}' == 'False'
    ...   Get AP Suite Configuration From File   ELSE
    ...   Set AP Suite Configuration Variables   ${TOPOLOGY}

Get Component Carrier Variables
    ${var}=    Get Variable Value    ${COMPONENT_CARRIER}
    ${var_exists}=      Set Variable If    "${var}" != 'None'    ${True}    ${False}
    Run Keyword If    '${var_exists}' == 'False'
    ...   Get Component Carrier Value From File   ELSE
    ...   Set Component Carrier Variables    ${COMPONENT_CARRIER}

Check and Override Multicell RU Type From File
    ${var}=    Get Variable Value    ${TOPOLOGY}
    ${var_exists}=      Set Variable If    "${var}" != 'None'    ${True}    ${False}
    Return From Keyword If    '${var_exists}' == 'False'
    Run Keyword If    '${TOPOLOGY}'=='CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD' and '${component_carrier}'=='1'
    ...    Set RU Type From File

Set RU Type From File
    ${value}=    Get Param Value From File   ${test_property_file}    RMOD=(\\w+)
    Set Suite Variable    ${RU_type}    ${value}

Get Secondary Test PC Data
    ${hostname}=    Get Hostname Details
    ${init_file}=   Get Init File Details     ${testline_results_path}    configs/${hostname}/__init__.py
    ${cloned_init_file}=    Run Keyword If    '${init_file}' == 'FAIL'
    ...   Clone Testline Configuration Repo    ${hostname}
    Run Keyword If    '${init_file}' != 'FAIL'    Set Secondary Test PC Credentials    ${init_file}
    ...   ELSE    Set Secondary Test PC Credentials    ${cloned_init_file}
    Log    ${test_pc2}

Update GNB IP For 4G5GCombo Setup
    Run Keyword If    '${4G5G_Combo}'=='1'    Update 4G5GCombo Dictionary for GNB IP

Update 4G5GCombo Dictionary for GNB IP
    Set To Dictionary     ${GNB_ASIK}    Ip    ${4G5G_Combo_GNB_IP}
    Set To Dictionary     ${GNB_BTS}     Ip    ${4G5G_Combo_GNB_IP}
    Set Suite Variable    &{GNB_BTS}     &{GNB_BTS}
    Set Suite Variable    &{GNB_ASIK}    &{GNB_ASIK}
    LogMany    &{GNB_ASIK}
    LogMany    &{GNB_BTS}

Update the gNB Mirroring config file for ASIB Variants
    [Arguments]    ${initial_number}    ${modify_number}
    [Documentation]    This keyword is used to update the Number of files present in the gNBMirroringConfig.sh file
    ...                for ASIB Variants.
    ...                Modified Date: 29-Sept-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${command}    Catenate    sed -i -z "s/NUMBER_OF_FILES=${initial_number}/NUMBER_OF_FILES=${modify_number}/g"
    ...                   ${scriptPath}/${gnbMirroringConfig}
    SSH.Execute       ${command}    ${GNB_ASIK}[Connection]

Update the BBSlot value in gNB Mirroring script for FDD ASIB ABIO
    [Documentation]    This keyword is used to update the BB Slot values present in the gNBMirroringConfig.sh file
    ...                for FDD ASIB ABIO Variants.
    ...                Modified Date: 22-Dec-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${command}    Catenate    sed -i -e "s/BB_SLOT_1=true/BB_SLOT_1=false/g" -e "s/BB_SLOT_5=false/BB_SLOT_5=true/g"
    ...                   ${scriptPath}/${gnbMirroringConfig}
    SSH.Execute       ${command}    ${GNB_ASIK}[Connection]
