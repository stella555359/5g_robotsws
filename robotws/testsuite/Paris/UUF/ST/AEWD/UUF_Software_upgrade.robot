*** Settings ***

Library     DateTime
Library     OperatingSystem
Library     Process
Library     OperatingSystem
Library     taf.rfrl.bts.commissioning
Resource    testsuite/Paris/UUF/ST/AEWD/Bi-Directional_Throughput_1-DRB_OTA.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Library     taf.rfrl.utilities.tl_config

*** Variables ***
@{allowed_alarms}=    SSH enabled
...                   R&D Service Port enabled
...                   LMP access via port 443
...                   Diagnostic Files collected
...                   Radio Diagnostic Files collected
...                   Service account root access is enabled
...                   Ethernet port security is disabled

${capabilities}         REAL_UE
${duration}             300s
${protocol}             udp
${deviation}            10%
${tput_dl}              1630 Mbits/sec
${tput_ul}              245 Mbits/sec
${size_packet_dl}       1400B
${size_packet_ul}       1330B
${parallel_streams_dl}  1
${parallel_streams_ul}  1
${buffer_client_dl}     4M
${buffer_server_dl}     4M
${buffer_client_ul}     2M
${buffer_server_ul}     2M
${interval}             1
${reboot_ue}            True
${timeout_reboot_ue}    100
${FILES_BASE}           http://files.ute.nsn-rdnet.net/builds/enb/base/
${REGEX}                [_|0-9|\.]*
${label}                ${tl.tl_cloud_topology}
@{releases}             SBTS00_ENB_9999     5G_0.400
${ENB_BUILD}
${ENB_BRANCH}

#*** Test Cases ***
#[1]5GC001423_SC_50_UUF_SWupgrade_in_loop
#    UUF Software Upgrade

*** Keywords ***
UUF Software Upgrade
    [Arguments]     ${tl_state}=sw_uploaded     ${agent_log_path}=/home/ute/agent_logs      ${output_path}=/home/ute/output
    PreConditions
    Upgrade gNB Software to previous build candidate       tl_state=${tl_state}    agent_log_path=${agent_log_path}     output_path=${output_path}
    Additional gNB Verification     run_tpt=${False}
    Update gNB Software to current build candidate
    Additional gNB Verification

# Keywords used in procedure
PreConditions
    ${Is_Cloud} =    taf.rfrl.utilities.tl_config.Is Testline of Cloud Type
    Set Suite Variable  ${Is_Cloud}  ${Is_Cloud}

Perform Full Commissioning
    Run Keyword If    ${Is_Cloud}    Perform Full Commissioning on Cloud gNB
    ...                ELSE  Perform Full Commissioning on Classical gNB
    Wait For Site To Be Onair

Additional gNB Verification
    [Arguments]     ${run_tpt}=${True}
    #Verify All Radio Module Status
    Verify Setup Of All Cells
    Verify gNB is onAir
    Verify Allowed Alarms on gNB    allowed_alarms=@{allowed_alarms}
    Start watching alarms    allowed_alarms=${allowed_alarms}
    Watch Active Alarms and Collect Logs on Unexpected Alarm

    Run Keyword If      ${run_tpt}
    ...        Bi-Directional_Throughput_1-DRB_OTA
    ...                                     capabilities=${capabilities}
    ...                                     duration=${duration}
    ...                                     protocol=${protocol}
    ...                                     deviation=${deviation}
    ...                                     tput_dl=${tput_dl}
    ...                                     tput_ul=${tput_ul}
    ...                                     size_packet_dl=${size_packet_dl}
    ...                                     size_packet_ul=${size_packet_ul}
    ...                                     parallel_streams_dl=${parallel_streams_dl}
    ...                                     parallel_streams_ul=${parallel_streams_ul}
    ...                                     buffer_client_dl=${buffer_client_dl}
    ...                                     buffer_server_dl=${buffer_server_dl}
    ...                                     buffer_client_ul=${buffer_client_ul}
    ...                                     buffer_server_ul=${buffer_server_ul}
    ...                                     interval=${interval}
    ...                                     reboot_ue=${reboot_ue}
    ...                                     timeout_reboot_ue=${timeout_reboot_ue}

    Stop watching alarms

Check Yesterday Candidate Build
    [Arguments]     ${release}
    ${today}    Get Current Date
    ${yesterday}    Subtract Time From Date     ${today}    1 day   result_format=%d-%b-%Y
    ${build_regex}      Catenate  SEPARATOR=    >   ${release}  ${REGEX}
    Set Test Variable   ${curl_cmd}      curl -R ${FILES_BASE} | grep ${yesterday} | grep -o '${build_regex}' | head -1
    ${result}   Run Process    ${curl_cmd}  shell=True  alias=curl
    [Return]    ${result.stdout[1:]}

Perform Agent Init
    [Arguments]     ${agent_init_cmd}
    [Timeout]   90min
    ${result}   Run Process     ${agent_init_cmd}   shell=True
    Should Be Equal As Integers      ${result.rc}    ${0}

Prepare Agent Command
    # Logic for cloud to be implemented
    [Arguments]     ${sw_build}     ${tl_state}    ${log_path}   ${output_path}
    ${agent_init_cmd}   Catenate
    ...  cd /home/ute;
    ...  export RUNBY=ROBOT;
    ...  . /opt/ute/agent_env/bin/activate &&
    ...  agent_5g_classical init -l ${label} -b ${sw_build} -s ${tl_state} -R ${log_path} -o ${output_path}
    ${agent_init_cmd}   Convert to String   ${agent_init_cmd}
    [Return]    ${agent_init_cmd}

Upgrade gNb Software to previous build candidate
    [Arguments]     ${tl_state}    ${agent_log_path}    ${output_path}
    Run Keyword If      ${Is_Cloud}     Set Suite Variable  ${release}      ${releases[1]}
    ...                 ELSE            Set Suite Variable  ${release}      ${releases[0]}
    ${sw_a}   Check Yesterday Candidate Build     release=${release}
    ${agent_init_cmd}   Prepare Agent Command   sw_build=${sw_a}    tl_state=${tl_state}    log_path=${agent_log_path}  output_path=${output_path}
    Perform Agent Init  ${agent_init_cmd}
    Perform Full Commissioning
    [Teardown]  Remove File     ${output_path}/build/${sw_a}*.zip

Update gNB Software To Current Build Candidate
    # When dealing with cloud, set flag by_nominal to True
    ${sw_package_path}  Download SW Package   sw_version=${ENB_BUILD}
    Update gNB Software     sw_package_dir=${sw_package_path}
    #Perform Full Commissioning
