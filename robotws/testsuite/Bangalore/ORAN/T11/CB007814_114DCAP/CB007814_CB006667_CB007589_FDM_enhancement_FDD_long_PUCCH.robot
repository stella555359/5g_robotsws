*** Settings ***
Documentation
...               Feature ID: CB007814

Suite Setup       Run Keywords    Suite Setup Update GNB
...               AND    Stop suite BTSlog
#Suite Teardown    Run Keywords    Common Suite Teardown    ###   scfc_file=${Default_SCF}
#...               AND    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify BTS Is OnAir
Test Setup        Run Keywords    Common Test Setup
...               AND    CB007623_keywords.Admin Setup
Test Teardown     Run Keywords    Common Test Teardown
...               AND   CB007623_keywords.Admin Teardown
Force Tags        CRT    SBTS24R3    FL00    QCD_MN_RAN    QCP_RAN_VRF
Resource          ../resources/Common_resource.robot
Library           taf.sw.dcap.rd   WITH NAME   rd
Library            taf.file.pack    WITH NAME   interface
Resource          ../../resources/robot/common_setup_teardown.robot
Resource                  ./resources/CB007623_keywords.robot
*** Variables ***
&{CB007814_CB006667_CB007589_FDM_further_enhancement_for_FDD_long_PUCCH_20_Mhz_SA}
...     QC_ID_FL00=QC_31503
@{capabilities}    Legacy_1    Legacy_2
@{throughput_dl}    155    155
@{throughput_ul}    30    30
@{UE_alias}       UE1    UE2
@{direction_dl}    dl    dl
@{direction_ul}    ul    ul
${timeout}        100    100
@{deviation_dl}    40    40
@{deviation_ul}    40    40
@{data_transfer_protocol}   UDP     UDP
@{COLUMN_NAME}    3gpp.sfn    3gpp.slot
@{gnb_custom_filters}       L2Ps_Sherpa      L2Lo_Sherpa    bip_interface_mirroring      # gnb custom filters for DCAP
@{bts_custom_filter}        immediateSnapshot    scf                                     # BTS custom filters for DCAP
${bip_log}                  5GBipL2L1_filtering_off.pcap
${i}                        ${0}                                                    # Initial counter value
@{LTE_cell}     0
@{NR_cell}      3
*** Test Cases ***
CB007814_CB006667_CB007589_FDM_further_enhancement_for_FDD_long_PUCCH_20_Mhz_SA
        Lock cells  ${LTE_cell}
        Lock NR cells  ${NR_cell}
        Run keyword and Continue on failure     Verification of DL MUE with FDM scheduling
        Run keyword and Continue on failure     Verification of UL MUE with FDM scheduling
        Counter value FDM   M55308C17002
        Counter value FDM   M55308C18002
        Unlock cells    ${LTE_cell}
        Unlock NRcells  ${NR_cell}

*** Keywords ***
Verification of DL MUE with FDM scheduling
   Create testcase folder
#   Create dcap session
   Attach ue and run throughput    ${UE_alias}    ${capabilities}    ${direction_dl}    ${throughput_dl}
   ...		${deviation_dl}    ${timeout}
#   ...		start_bip=True    Collect_eGEN=False
   Log to console      \nConvert BIP log to csv and verify
   Set Suite Variable    ${Log_path}        ${OUTPUT_DIR}/DCAP_Logs
   Set Suite Variable    ${source_paths}      ${Log_path}/Extracted/
   create directory         ${source_paths}
    ${files}     OperatingSystem.List Files In Directory    ${Log_path}
    FOR    ${zip}    IN    @{files}
        interface.Extract
                         ...  path=${Log_path}/${zip}
                         ...  output_dir=${source_paths}
                         ...  .=*/*/*_interface-mirroring.zip
                         ...  **/*_interface-mirroring.zip=BTS*_1011_*.zip
                         ...  **/BTS*_1011_*.zip=*.pcap.xz
                         ...  **/BTS*_1011_*.zip/*.pcap.xz=*
    END
    ${result}=    Run Process
    ...    find ${source_paths} -type f \\\( -name "*.pcap" \\\) -exec cp '{}' ${OUTPUT_DIR} \\\;
    ...    shell=True

   BIP analysis    dldata_pdschsendreq     ${COLUMN_NAME}    2

Verification of UL MUE with FDM scheduling
    Create testcase folder
    Attach ue and run throughput    ${UE_alias}    ${capabilities}    ${direction_ul}    ${throughput_ul}
	...		${deviation_ul}    ${timeout}
	...		start_bip=True    Collect_eGEN=False
    Log to console      \nConvert BIP log to csv and verify
    Set Suite Variable    ${Log_path}        ${OUTPUT_DIR}/DCAP_Logs
    Set Suite Variable    ${source_paths}      ${Log_path}/Extracted/
    create directory         ${source_paths}
    ${files}     OperatingSystem.List Files In Directory    ${Log_path}
    FOR    ${zip}    IN    @{files}
        interface.Extract
                         ...  path=${Log_path}/${zip}
                         ...  output_dir=${source_paths}
                         ...  .=*/*/*_interface-mirroring.zip
                         ...  **/*_interface-mirroring.zip=BTS*_1011_*.zip
                         ...  **/BTS*_1011_*.zip=*.pcap.xz
                         ...  **/BTS*_1011_*.zip/*.pcap.xz=*
    END
    ${result}=    Run Process
    ...    find ${source_paths} -type f \\\( -name "*.pcap" \\\) -exec cp '{}' ${OUTPUT_DIR} \\\;
    ...    shell=True

    BIP analysis    uldata_puschreceiveresplo     ${COLUMN_NAME}    2

Attach ue and run throughput
    [Arguments]    ${UE_alias}    ${capabilities}    ${direction}    ${throughput}    ${deviation}    ${timeout}
    ...     ${check_tpt}=True     ${wait_for_transfer}=True
#    Start NAA application
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Log to console      \nExecuting testcase in UE : ${capabilities}
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}
    Log to console    \nStarting ${direction} data transfer
    ta_ultracaller.start_datatransfer    ${UE_alias}    ${data_transfer_protocol}   direction=${direction}
#    Dcap Start Trace SA
    Start DCAP log collection
    Log to console    \nWaiting for data transfer
    Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish
	...		${UE_alias}    ${direction}
    ...     ${timeout}
    ...    AND    Sleep    150
    ...    AND    Log to console    \nData transfer completed
#	Dcap Stop Trace and Get results SA
    Stop DCAP log collection
    Run Keyword If    '${check_tpt}'=='True'    Run keyword and continue on failure
	...		ta_ultracaller.Calculate Thrughtput    ue_alias=${UE_alias}
    ...     direction=${direction}    thrughtput=${throughput}    deviation=${deviation}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
#    [Teardown]      Switch UE

BIP analysis
   [Arguments]     ${FILTER}     ${COLUMN_NAME}   ${Repetation_count}
   Run Process     command=mergecap ${OUTPUT_DIR}/*mirroring* -w ${OUTPUT_DIR}/5GBipL2L1_filtering_off.pcap
   ...	shell=True
    Copy Files      ${OUTPUT_DIR}/5GBipL2L1_filtering_off.pcap  ${OUTPUT_DIR}/BIP
   Get BIP csv file     ${FILTER}
    ${value}    Verify_Biplog_content    ${BIP_CSV_LOG}    ${COLUMN_NAME}   ${Repetation_count}
    Run keyword and continue on failure    Should be True    ${value}

Get BIP csv file
    [Arguments]     ${FILTER}
    Set Suite Variable    ${BIP_CSV_LOG}    ${OUTPUT_DIR}/BIP//bip_log.csv
    OperatingSystem.Run   sudo rm -rf /usr/lib/x86_64-linux-gnu/wireshark/plugins/4.0/epan/mcshark-*buster.so
    Convert BIP To CSV By MCShark    ${OUTPUT_DIR}/BIP/${bip_log}    ${BIP_CSV_LOG}    ${FILTER}    ${COLUMN_NAME}
    ${csv_content}    Get File    ${BIP_CSV_LOG}

Dcap Start Trace SA
    [Documentation]     Start DCAP logs with custom filter
    Log to console      \nStarting DCAP trace
    ${output}       rd.start_trace  duration=${Default_DCAP_duration}     bts=${BTS_INFO}
	...		gnb_custom_profile=@{gnb_custom_filters}
    ...     bts_custom_profile=@{bts_custom_filter}     collection_timing=${collection_timing}
    Sleep       150      reason=Wait for DCAP start
    ${START_TRACE_ID}      Get from Dictionary    ${output}    tracer_id
    Set Suite Variable  ${START_TRACE_ID}
    LOG      DCAP log collection has been started in the gNB

Dcap Stop Trace and Get results SA
    [Documentation]     Stops DCAP and collect logs
    Log to console      \nStopping DCAP trace ID ${START_TRACE_ID} and collecting logs
    rd.stop_trace    ${START_TRACE_ID}
    LOG     DCAP logging stopped
    rd.get_results    result_id=${START_TRACE_ID}    target_dir=${OUTPUT_DIR}/DCAP_Logs
	...		timeout=${dcap_log_timeout}

Get Date
    [Documentation]     Get date to create testcase folder
    ${date}    Get Current Date    result_format=%d_%m_%Y_%H%M%S_%f
    ${date}    Convert to String    ${date}
    Set global variable    ${Folder}    ${date}

Create testcase folder
    [Documentation]     Create testcase folder in testpc
    ${val}    Run Keyword And Return Status    LOG    ${OUTPUT_DIR}/${Folder}/${TEST NAME}
    Run Keyword If    ${val} == False    Get Date
    create directory    ${OUTPUT_DIR}/DCAP_Logs

Counter value FDM
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter   ${counter_name}
    ${result}     Wait Until Keyword Succeeds    ${Retry_count} times    60      COAM.get_pm_counters
    ...     counter_ids=${counter_name}    timeout=60    connection=${connection}
    log    ${result}
    ${values}    Get Dictionary Values
	...		${result['BTS']['MRBTS-1236']['NRBTS-1236']['NRCELL-1']['NCELA']['${counter_name}']}
#    log     ${values[0]}
    Should Contain  "${values}"     2
    ${Total_Count}    Get value of Counter    ${values}
    Should Be True      ${Total_Count} > 2
    [Return]    ${Total_Count}

Get value of Counter
    [Arguments]    ${Counter_value}
    [Documentation]     Get total value from list
    FOR    ${a}    IN    @{Counter_value}
        ${i}    Evaluate    ${i} + ${a}
    END
    [Return]    ${i}

Start DCAP log collection
    rd.connect_to  host=${DCAP_host}   port=443    username=${dcapuser}    password=${dcap_password}
    ...              rd_version=dcapv3  secure=True
     &{bts1_info}   create dictionary  host=${BTS_M_plane_ip}    port=443
    @{enb_custom_profile}=    Create List    condor4gSyslog     scf4g
    ${output}    rd.start_trace     duration=25    bts=${bts1_info}
    ...    gnb_custom_profile=@{gnb_custom_filters}
    LogToConsole    ${output}
    ${output}=    Set Suite Variable    ${output}
    sleep   100

Stop DCAP log collection
    ${trace_id} =   Get From Dictionary   ${output}   tracer_id
    Run Keyword And Continue On Failure    rd.stop_trace    trace_id=${trace_id}
    LogToConsole    ${trace_id}
    ${dcap_dirname}    rd.get_results    result_id=${trace_id}
    ...     target_dir=${OUTPUT_DIR}/DCAP_Logs    timeout=2000
    LogToConsole    ${dcap_dirname}
    ${dcap_dirname}=    Set Suite Variable    ${dcap_dirname}
