*** Settings ***

Library     DateTime
Library     OperatingSystem
Library     Process
Library     OperatingSystem
Library     taf.rfrl.bts.commissioning
Resource    Bi-Directional_Throughput_1-DRB_OTA.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Library     taf.rfrl.utilities.tl_config

Library     kw_UUF.py


*** Variables ***
@{allowed_alarms}=    SSH enabled
...                   R&D Service Port enabled
...                   LMP access via port 443
...                   Diagnostic Files collected
...                   Radio Diagnostic Files collected
...                   Service account root access is enabled
...                   Ethernet port security is disabled
...                   Sanity Check Error

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
New Software Upgrade
    Software Upgrade Preparation
    ${sw_request}     get_short_software_name     ${ENB_BUILD}

    Update gNB Software     sw_package_dir=${sw_package_path}     timeout=900
    Control Cells OnAir and gNB      ${sw_request}


UUF Software Upgrade
    Software Upgrade Preparation
    ${sw_request}     get_short_software_name     ${ENB_BUILD}
    ${sw_initial}     get_short_software_name     ${initial_software}

    # Soft update
    Log to console   /nUpdate sofware to ${ENB_BUILD}
    Update gNB Software     sw_package_dir=${sw_package_path}     timeout=1200
    Control Cells OnAir and gNB      ${sw_request}

    # Rollback
    Log to console    /nRollback to ${initial_software}
    software_rollback
    Control Cells OnAir and gNB           ${sw_initial}


UUF Software Upgrade in loop
    [Arguments]       ${loop_nb}=5

    Software Upgrade Preparation
    ${sw_request}     get_short_software_name     ${ENB_BUILD}
    ${sw_initial}     get_short_software_name     ${initial_software}

    FOR   ${loop_id}    IN RANGE    ${loop_nb}
        # Soft update
        Log to console   /nUpdate sofware to ${ENB_BUILD}
        Update gNB Software     sw_package_dir=${sw_package_path}     timeout=1200
        Control Cells OnAir and gNB      ${sw_request}

        # Rollback
        Log to console    /nRollback to ${initial_software}
        software_rollback
        Control Cells OnAir and gNB           ${sw_initial}
    END


# Keywords used in procedure
Software Upgrade Preparation
    PreConditions Software Upgrade
    ${curent_sw}                 get_software_version
    log       ${curent_sw}     console=True    html=True
    Set Suite Variable           ${initial_software}      ${curent_sw['Active']}

    scf_backup     ${OUTPUT DIR}    scf_backup.xml

    ${initalOnAirCellsLsist}     get_cells_on_air_list
    Should Not Be Empty          ${initalOnAirCellsLsist}      No Cell OnAir before test
    Set Suite Variable           ${initalOnAirCellsLsist}

    ${sw_package_path}  Download SW Package   sw_version=${ENB_BUILD}
    Set Suite Variable           ${sw_package_path}


Control Cells OnAir and gNB
    [Arguments]       ${request_sw_version}
    Log to console    wait gNB response
    ${curent_sw}=     Wait Until Keyword Succeeds   20 min    1 min     get_software_version
    log       ${curent_sw}     console=True    html=True
    ${short_active_sw}     get_short_software_name     ${curent_sw['Active']}
    Should Be Equal      ${short_active_sw}     ${request_sw_version}
    ...                      Error: bad software version, request: ${request_sw_version}, active: ${curent_sw['Active']}

    Log to console    wait Cells OnAir
    Wait Until Keyword Succeeds   20 min    1 min     test_initial_cells_on_air_list      ${initalOnAirCellsLsist}

    # Log to console    other gNB control
    # Additional gNB Verification       run_tpt=${False}


Setup Go to resquested sw
    ${curent_sw}=     get_software_version
    log       ${curent_sw}     console=True    html=True
    ${sw_request}     get_short_software_name     ${ENB_BUILD}
    ${sw_active}      get_short_software_name     ${curent_sw['Active']}
    ${sw_passive}     get_short_software_name     ${curent_sw['Passive']}
    Run Keyword If                 ${sw_request}==${sw_passive}     force rollback
    ...    ELSE    Run Keyword If  ${sw_request}!=${sw_active}      force resquest sw    ${ENB_BUILD}


force resquest sw
    [Arguments]       ${request_sw_version}
    scf_backup     ${OUTPUT DIR}/scf_backup.xml
    ${initalOnAirCellsLsist}     get_cells_on_air_list
    Should Not Be Empty          ${initalOnAirCellsLsist}      No Cell OnAir before test
    ${sw_package_path}  Download SW Package   sw_version=${ENB_BUILD}
    Update gNB Software     sw_package_dir=${sw_package_path}     timeout=1200
    Log to console    wait Cells OnAir
    Wait Until Keyword Succeeds   30 min    1 min     test_initial_cells_on_air_list      ${initalOnAirCellsLsist}


force rollback
    scf_backup     ${OUTPUT DIR}/scf_backup.xml
    ${initalOnAirCellsLsist}     get_cells_on_air_list
    Should Not Be Empty          ${initalOnAirCellsLsist}      No Cell OnAir before test
    software_rollback
    Log to console    wait Cells OnAir
    Wait Until Keyword Succeeds   30 min    1 min     test_initial_cells_on_air_list      ${initalOnAirCellsLsist}


sw update setup
    ${curent_sw}=            get_software_version


sw update setup test case
    ${curent_sw}=            get_software_version
    Should Not Be Equal      ${curent_sw['Active']}     ${ENB_BUILD}


sw update teardown
    ${curent_sw}=     get_software_version
    log       ${curent_sw}     console=True    html=True
    ${sw_initial}     get_short_software_name     ${initial_software}
    ${sw_current}     get_short_software_name     ${curent_sw['Active']}
    Run Keyword If       '${sw_current}' != '${sw_initial}'    Rollback in sw update teardown


Rollback in sw update teardown
    Log to console    Bad current software version => Rollback
    software_rollback
    ${curent_sw}=     Wait Until Keyword Succeeds   20 min    1 min     get_software_version
    log       ${curent_sw}     console=True    html=True


PreConditions Software Upgrade
    ${Is_Cloud} =    taf.rfrl.utilities.tl_config.Is Testline of Cloud Type
    Set Suite Variable  ${Is_Cloud}  ${Is_Cloud}


Perform Full Commissioning
    Run Keyword If    ${Is_Cloud}    Perform Full Commissioning on Cloud gNB
    ...                ELSE  Perform Full Commissioning on Classical gNB
    Wait For Site To Be Onair


Additional gNB Verification
    [Arguments]     ${run_tpt}=${True}
    Verify All Radio Module Status
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


# Upgrade gNb Software to previous build candidate
#     [Arguments]     ${tl_state}    ${agent_log_path}    ${output_path}
#     Run Keyword If      ${Is_Cloud}     Set Suite Variable  ${release}      ${releases[1]}
#     ...                 ELSE            Set Suite Variable  ${release}      ${releases[0]}
#     ${sw_a}   Check Yesterday Candidate Build     release=${release}
#     ${agent_init_cmd}   Prepare Agent Command   sw_build=${sw_a}    tl_state=${tl_state}    log_path=${agent_log_path}  output_path=${output_path}
#     Perform Agent Init  ${agent_init_cmd}
#     Perform Full Commissioning
#     [Teardown]  Remove File     ${output_path}/build/${sw_a}*.zip


# Update gNB Software To Current Build Candidate
#     # When dealing with cloud, set flag by_nominal to True
#     ${sw_package_path}  Download SW Package   sw_version=${ENB_BUILD}
#     Update gNB Software     sw_package_dir=${sw_package_path}
#     Perform Full


# Update gNB Software To Current Build Candidate
#     # When dealing with cloud, set flag by_nominal to True
#     ${sw_package_path}  Download SW Package   sw_version=${ENB_BUILD}
#     Update gNB Software     sw_package_dir=${sw_package_path}     timeout=900
