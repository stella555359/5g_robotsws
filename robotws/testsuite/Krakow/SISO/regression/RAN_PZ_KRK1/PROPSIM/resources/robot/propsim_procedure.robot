*** Settings ***
Documentation
...   Keywords for basic Propsim procedure.
...   author: Tomasz Krol
...   contact: tomasz.krol@nokia.com


Library     taf.collectors.tcpdump                            WITH NAME   tcpdump
Library     taf.rfrl.ue.logs.qxdm_logs.QxdmLogsCollector      WITH NAME  QxdmLogsCollector
Library     taf.rfrl.ue.logs.qxdm_logs.LicenseKeeperKeywords  WITH NAME  LicenseKeeperKeywords
Library     ../python/propsim_keywords.py
Library     propsim_keywords.CustomPropsimKeywords            WITH NAME  CPK
Library     ../python/general.py
Library     testsuite/Krakow/resources/qxdm_collection.py
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***
${PROPSIM_PROFILE_DIR}      ${None}
# TODO Get automatically cell ID
${USED_PHYSICAL_CELL_ID}    ${None}

${capabilities}         REAL_UE
${duration}             ${None}     # Please set in Suite file
${direction}            UL
${protocol}             UDP
${size_packet}          1400B
${tput}                 ${None}     # Please set in Suite file
${parallel_streams}     1
${buffer_client}        200M
${buffer_server}        200M
${interval}             1
${qci}                  ${None}
${reboot_ue}            ${False}
${timeout_reboot_ue}    100
${scf_prefix_tag}       ${None}


${propsim_ip}              10.83.177.66
${dl_start_gain}           0
${dl_end_gain}             -55
${ul_start_gain}           0
${ul_end_gain}             -55
${step}                    -2


${RFP_LOGS}             ${OUTPUT DIR}/rfp_logs
${QXDM_PYTHON_PATH}     C:/Python39/python.exe
${lkc_path}             /cygdrive/c/QPM_LK1.5.1
${lkc_login}            ${None}
${lkc_password}         ${None}

*** Keywords ***
Suite Setup
#   TODO - Prepare Test Line
#       Perform Full Commissioning on Classical gNB    prefix_tag=${scf_prefix_tag}
    Common Suite Setup
    Set Used Physical Cell ID
    Kill All QXDM processes
    Upload QxdmLogCatch Script
    Setup Keysight Propsim  ip=${propsim_ip}
    Setup Sherpa Tcpdump Collector
    Start Sherpa Trace

Suite Teardown
    Release QXDM and QCAT Licence
    Stop Sherpa Trace
    Teardown Sherpa Tcpdump Collector
    Teardown Keysight Propsim
    Common Suite Teardown

Propsim Procedure
    [Arguments]   ${capabilities}  ${duration}  ${tput}  ${protocol}  ${parallel_streams}  ${size_packet}
    ...           ${buffer_client}  ${buffer_server}  ${interval}  ${qci}  ${reboot_ue}  ${timeout_reboot_ue}
    ...           ${propsim_emu_file}  ${run_drop_ue_observer}=${False}
    Set Test Variable    ${Exit_Loop}    ${False}
    Prepare RFP logs Directory
    Prepare Ue for L3 Call  capabilities=${capabilities}  reboot_ue=${reboot_ue}  timeout_reboot_ue=${timeout_reboot_ue}
    general.Start Propsim Emulation  ${propsim_emu_file}
    general.Perform Attach and Verify UE Properly Attached  log_dir=${RFP_LOGS}/attach  python_path=${QXDM_PYTHON_PATH}
    Run Keyword If    ${run_drop_ue_observer}    Start UE Drop Observer
    ${steps}  ${number_of_steps}  Generate Steps  ${dl_start_gain}  ${dl_end_gain}  ${ul_start_gain}  ${ul_end_gain}  ${step}
    ${index}  set variable  0
    FOR   ${step}   IN  @{steps}
         ${index}  EVALUATE  ${index} + ${1}
         Extend QXDM and QCAT license
         general.Log Info to Console  msg=Run iteration [${index}/${number_of_steps}]    log_hierarchy=${1}
         general.Change Propsim Output Gain  downlink_gain=${step[0]}  uplink_gain=${step[1]}
         ${status}  ${ret}  Run Keyword And Ignore Error
     ...                        Run Data Transfer and Collect Logs
     ...                                                                ${index}
     ...                                                                ${direction}
     ...                                                                ${protocol}
     ...                                                                ${duration}
     ...                                                                ${tput}
     ...                                                                ${protocol}
     ...                                                                ${parallel_streams}
     ...                                                                ${size_packet}
     ...                                                                ${buffer_client}
     ...                                                                ${buffer_server}
     ...                                                                ${interval}
     ...                                                                ${qci}
         Exit For Loop IF    "${status}" == "FAIL" or ${Exit_Loop}
    END
    [Teardown]  Propsim Procedure Teardown

Propsim Procedure Teardown
    general.Detach UE
    general.Stop Propsim Emulation
    Run Postprocessing logs

Run Data Transfer and Collect Logs
    [Arguments]   ${index}  ${direction}  ${protocol}  ${duration}  ${tput}  ${protocol}  ${parallel_streams}
    ...           ${size_packet}  ${buffer_client}  ${buffer_server}  ${interval}  ${qci}

    ${log_dir}    Make Directory for Iteration  log_dir=${RFP_LOGS}  iteration=${index}
    general.Start Data Transfer on Real UE
    ...                                     direction=${direction}
    ...                                     protocol=${protocol}
    ...                                     duration=${duration}
    ...                                     tput=${tput}
    ...                                     parallel_streams=${parallel_streams}
    ...                                     size_packet=${size_packet}
    ...                                     buffer_client=${buffer_client}
    ...                                     buffer_server=${buffer_server}
    ...                                     interval=${interval}
    ...                                     qci=${qci}
    general.Wait for Tput Stabilization
    Collect logs during data transfer       log_dir=${log_dir}
    general.Wait for Tput Finished          ${direction}
    Convert Collected logs
    Download Collected logs                 log_dir=${log_dir}
    Collect Iperf Results                   log_dir=${log_dir}  direction=${direction}
    # TODO Start processing in the background ???(Sherpa + QXDM)


Collect logs during data transfer
    [Arguments]   ${log_dir}
    general.Log Info to Console             msg=Start Collecting logs    log_hierarchy=${2}
    Collect Propsim Results                 log_dir=${log_dir}
    Start Collecting Sherpa logs            log_dir=${log_dir}
    general.Start Collecting QXDM logs      python_path=${QXDM_PYTHON_PATH}
    Sleep  5
    general.Log Info to Console             msg=Stop Collecting logs    log_hierarchy=${2}
    Stop Collecting Sherpa logs             log_dir=${log_dir}


Convert Collected logs
    general.Log Info to Console             msg=Convert Collected logs    log_hierarchy=${2}
    general.Convert QXDM log to txt
    Convert Sherpa log to CSV

Download Collected logs
    [Arguments]   ${log_dir}
    general.Log Info to Console             msg=Download Collected logs    log_hierarchy=${2}
    general.Download QXDM logs              log_dir=${log_dir}

Run Postprocessing logs
    general.Log Info to Console             msg=Postprocessing logs    log_hierarchy=${1}
    ${csv_summary_path}    Create Summary CSV Report
    Create Summary Excel Report    csv_summary_path=${csv_summary_path}
