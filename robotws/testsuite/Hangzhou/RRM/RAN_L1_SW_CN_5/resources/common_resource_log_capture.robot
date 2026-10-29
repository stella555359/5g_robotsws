*** Settings ***
Documentation    log capture

*** Variables ***
@{ALLOWED_FAULT}
${save_snapshot_path}    ${OUTPUT DIR}/Snapshot.zip

*** Keywords ***
####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~BTS LOG~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~####

Start GNB Syslog
    [Arguments]    ${log_dir}    ${btslog_name}=btslog.log    ${file_limit}=100000000
    [Documentation]    This keyword is to start GNB Syslog
    ...    Examples:
    ...    | Start GNB Syslog | /tmp |
    ute_syslog.Start Syslog    log_dir=${log_dir}    log_name=${btslog_name}    file_limit=${file_limit}    ssh_username=${TEST_PC_USERNAME}
    ...    ssh_password=${TEST_PC_PASSWORD}    alias=enb_testSetup

Stop Collect GNB Syslog
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to stop GNB Syslog
    ...    Examples:
    ...    | Stop Collect GNB Syslog | /tmp |
    ute_syslog.Collect Syslog Results    destination=${log_dir}    alias=enb_testSetup
    #ute_syslog.Teardown All Aliases For Syslog

####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Snapshot~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#####

Save Coam SnapShot
    [Arguments]    ${log_dir}=${TEST_LOG_DIR}
    ${coam_connection}    sbts_admin.Connect To    bts_host=${GNB_ASIB.ip}
    sbts_admin.Get SnapShot    target_file_name=${log_dir}/snapShot.zip    coverage=Full    force=True    connection=${coam_connection}
    [Teardown]    sbts_admin.Teardown    ${coam_connection}

Save Snapshot Via WebUI
    Log To Console    [INFO] Save snapshot ... ...
    ${snapshot}    Set Variable    ${None}
    WebUI connection    snapshot
    ${snapshot}=    selenium_coam.collect_snapshot    sbts=snapshot
    Should Not Be True    '${snapshot}' == 'Collect Snapshot Failed'    [ ERROR ] ${snapshot}
    [Teardown]    WebUI disconnection    snapshot
    [Return]    ${snapshot}

####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Tti Trace~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#####

Start collect ttitrace
    [Arguments]    ${ue_index}    ${cell_id}=ALL    ${prefix_path}=${TEST_LOG_DIR}/ttitrace
    setup enb ttitrace    log_path=${prefix_path}    alias=${ue_index}
    start Enb Ttitrace    node_type=ALL    cell_id=${cell_id}    port=15003    prefix=${prefix_path}/tti    filesize=50    alias=${ue_index}

Stop collect and decode ttitrace
    [Arguments]    ${ue_index}=UE1
    stop and decode enb ttitrace    ext=csv    alias=${ue_index}
    teardown enb ttitrace    alias=${ue_index}

collect and decode ttitrace
    [Arguments]    ${ue_index}    ${prefix_path}=${TEST_LOG_DIR}/ttitrace    ${tti_duration}=10
    setup enb ttitrace    log_path=${prefix_path}    alias=${ue_index}
    start enb ttitrace    node_type=ALL    cell_id=ALL    port=15003    prefix=${prefix_path}/tti    alias=${ue_index}    filesize=50
    ${ue_status}    run keyword and return status    should contain    ${TEST TAGS}    QUALCOMM_UE
    run keyword if    ${ue_status}==True    sleep    ${tti_duration}s
    ...    ELSE IF    ${ue_status}==False and '${ue1_type}'=='GCT_CPE_new'    get_new_cpe_log    file_path=${TEST_LOG_DIR}${/}ue/cpe.log
    ...    host=${ue1_id}    caputertime=${tti_duration}
    ...    ELSE    get_cpe_log    file_path=${TEST_LOG_DIR}${/}ue/cpe.log    host=${ue1_id}    caputertime=${tti_duration}
    @{dat_file}=    stop and decode enb ttitrace    ext=csv    alias=${ue_index}
    teardown enb ttitrace    alias=${ue_index}

Check Ttitrace
    [Arguments]    ${ini_path}    ${prefix_path}=${TEST_LOG_DIR}/ttitrace/
    log    INFO:check log with au2anlysis    console=true
    check_log_with_au2anlysis    ${ini_path}    i    save_log_directory=${prefix_path}

read_csv_single_column
    [Arguments]    ${csv_dir}    ${column_title}
    #arguments example: ${CURDIR}/ttitrace.dat.csv    ETtiTraceDlParCell_dlPwBackoffApplied
    ${value1}=    read_csv_columns    ${csv_dir}    ${column_title}
    [Return]    ${value1}

read_csv_multi_columns
    [Arguments]    ${csv_dir}    ${column_title2}
    ${value1}=    read_csv_columns    ${csv_dir}    ${column_title}    ${column_title2}
    ${value_title1}=    get_from_list    ${value1}    0
    ${value_title2}=    get_from_list    ${value1}    1

read_csv_cell
    [Arguments]    ${csv_dir}    ${column_title}    ${index}
    ${value1}=    read_csv_single_column    ${csv_dir}    ${column_title}
    ${length}=    get_length    ${value1}
    ${value}=    run_keyword_if    ${index}<${length}    get_from_list    ${value1}    ${index}
    ...    ELSE    Fail    index is out of range
    [Return]    ${value}

####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Calibration~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#####

check_calibration
    [Arguments]    ${zipFilename}    ${bandwidthInfo}
    Log to console    \nINFO:Start to check calibration
    ${resultPath}=    Set Variable    ${TEST_LOG_DIR}${/}btslog
    ${checkType}=    Set Variable    mmimo
    ${output1}=    calibrationcheck    ${bandwidthInfo}    ${zipFilename}    ${resultPath}    ${checkType}
    Log to console    ${output1}
    # Should Not Contain    ${output1}    NOk
    ${nok}=    Convert To String    NOk
    ${output2}=    Convert To String    ${output1}
    Should Not Contain    ${output2}    $(nok)


####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~gNB Tool~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#####

gNB Tool Start Capture Log
    [Arguments]    ${log_type}    ${BBMOD_Index}=1    ${log_dire}=${SUITE_LOG_DIRECTORY}
    prepare_gnb_tool
    Log To Console    start to capture ${log_type} ... ....
    Start To Capture Log With Gnb Tool    log_dire=${log_dire}    log_type=${log_type}    add_options=-c ${BBMOD_Index}

gNB Tool Stop Log
    [Arguments]    ${log_type}=${EMPTY}
    Log To Console    stop ${log_type} log ... ...
    ${gnb_log_path}    stop_bip_log_with_gnb_tool
    Log To Console    ${log_type} log saved: ${gnb_log_path}
    [Return]    ${gnb_log_path}

####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~L1-IQ capture~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#####

Configure IQ capture via webUI
    [Arguments]    ${ul_subcell_index_list}=${None}
    ...            ${dl_subcell_index_list}=${None}
    ...            ${lte_ul_cell_ids}=${None}
    ...            ${lte_dl_cell_ids}=${None}
    ...            ${enable_capture_on}=Blind
    ...            ${capture_from}=BBU
    ...            ${profile_prefix}=${None}
    ...            ${buffer_cycle}=16_FRAMES
    ...            ${capture_frame_offset}=22
    ...            ${antenna_list_group}=${None}
    ...            ${start_parallel_l1_l2_mirroring}=${False}
    [Documentation]    To perform L1-IQ capture configuration. Updated after CB009514.
    ...    | Arguments | Mandatory | Default | Description/example | Actual Input |
    ...    | ul_subcell_index_list | Yes | None | such as: ['[BBMOD_R-1(ABIP)] [PCI: 300][7-2e]NRCELL-1: Subcell 0'] | ${ul_subcell_index_list} |
    ...    | dl_subcell_index_list | Yes | None | such as: ['[BBMOD_R-1(ABIP)] [PCI: 300][7-2e]NRCELL-1: Subcell 0'] | ${dl_subcell_index_list} |
    ...    | lte_ul_cell_ids | No | None | such as: [LNCEL-1, LNCEL-2] | ${lte_ul_cell_ids} |
    ...    | lte_dl_cell_ids | No | None | such as: [LNCEL-1, LNCEL-2] | ${lte_dl_cell_ids} |
    ...    | enable_capture_on | Yes | Blind | L1-IQ log type, Blind or Event | ${enable_capture_on} |
    ...    | capture_from | Yes | BBU | L1-IQ log from BBU or 'BBU and RU' | ${capture_from} |
    ...    | profile_prefix | Yes | None | None / UL_PROFILE_1 / UL_PROFILE_2 / UL_PROFILE_3 / DL_PROFILE_1 / UL_DL_PROFILE_1 | ${profile_prefix} |
    ...    | buffer_cycle | No | 16_FRAMES | buffer cycle: it's mandatory when profile = UL_PROFILE_3 | ${buffer_cycle} |
    ...    | capture_frame_offset | No | 22 | capture frame offset: it's mandatory when profile = UL_PROFILE_3 | ${capture_frame_offset} |
    ...    | antenna_list_group | Yes | None | such as: {'Antenna list': 'Group17'} | ${antenna_list_group} |
    ...    | start_parallel_l1_l2_mirroring | No | False | parallel l1 l2 mirroring after apply configuration | ${start_parallel_l1_l2_mirroring} |

    Log To Console    Configure L1-IQ capture from [ ${capture_from} ], with [ ${enable_capture_on} ] mode and profile is [ ${profile_prefix} ] ...

    ${not_none}    _It is Not None    ${profile_prefix}
    ${profile_prefix}    Set Variable If    ${not_none}    ${profile_prefix.upper()}    ${profile_prefix}
    Should Be True    '${enable_capture_on.lower()}' in ('blind','event')   [ERROR]enable_capture_on [${enable_capture_on}] should be [Blind | Event]
    Should Be True    '${capture_from}' in ('BBU','BBU and RU')    [ERROR]enable_capture_on [${capture_from}] should be [BBU | 'BBU and RU']
    Should Be True    '${profile_prefix}' in ('None', 'UL_PROFILE_1', 'UL_PROFILE_2', 'UL_PROFILE_3', 'DL_PROFILE_1', 'UL_DL_PROFILE_1')
    ...    [ERROR] profile_prefix [${profile_prefix}] should be [None | UL_PROFILE_1 | UL_PROFILE_2 | UL_PROFILE_3 | DL_PROFILE_1 | UL_DL_PROFILE_1]
    Run Keyword If    '${capture_from}' in ('BBU and RU',)    Should Be True    ${not_none}
    ...    [ERROR] profile_prefix [${profile_prefix}] should NOT be None if capture_from = 'BBU and RU'.
    Run Keyword If    '${profile_prefix}' not in ('None', 'UL_PROFILE_1', 'UL_PROFILE_2')
    ...    Should Be True    'Antenna list' in '''${antenna_list_group}'''
    ...    [ERROR] antenna_list_group [${antenna_list_group}] should NOT be None when profile=[ 'UL_PROFILE_3', 'DL_PROFILE_1', 'UL_DL_PROFILE_1' ].

    ${profile}    _L1-IQ profile dictionary    ${profile_prefix}
    ${radio_configurations}    _Get radio configurations dictionary    ${ul_subcell_index_list}    ${dl_subcell_index_list}    ${antenna_list_group}

    Close Startup View Window

    ${result}    Run Keyword If    '7-2a' in '${profile}'    selenium_coam.configure_iq_capture
    ...    ul_subcell_index_list=${ul_subcell_index_list}
    ...    dl_subcell_index_list=${dl_subcell_index_list}
    ...    lte_ul_cell_ids=${lte_ul_cell_ids}
    ...    lte_dl_cell_ids=${lte_dl_cell_ids}
    ...    enable_capture_on=${enable_capture_on}
    ...    capture_from=${capture_from}
    ...    profile=${profile}
    ...    radio_configurations=${radio_configurations}
    ...    buffer_cycle=${buffer_cycle}
    ...    capture_frame_offset=${capture_frame_offset}
    ...    sbts=suite
    ...    ELSE IF    '${capture_from.upper()}'=='BBU AND RU'    selenium_coam.configure_iq_capture
    ...    ul_subcell_index_list=${ul_subcell_index_list}
    ...    dl_subcell_index_list=${dl_subcell_index_list}
    ...    lte_ul_cell_ids=${lte_ul_cell_ids}
    ...    lte_dl_cell_ids=${lte_dl_cell_ids}
    ...    enable_capture_on=${enable_capture_on}
    ...    capture_from=${capture_from}
    ...    profile=${profile}
    ...    radio_configurations=${radio_configurations}
    ...    sbts=suite
    ...    ELSE    selenium_coam.configure_iq_capture
    ...    ul_subcell_index_list=${ul_subcell_index_list}
    ...    dl_subcell_index_list=${dl_subcell_index_list}
    ...    lte_ul_cell_ids=${lte_ul_cell_ids}
    ...    lte_dl_cell_ids=${lte_dl_cell_ids}
    ...    enable_capture_on=${enable_capture_on}
    ...    capture_from=${capture_from}
    ...    sbts=suite
    Should Be True    '${result}'=='Configure succeeded'    [ ERROR ] L1-IQ Configure failure due to ${result}.
    Run Keyword If    ${start_parallel_l1_l2_mirroring}    selenium_coam.start_parallel_l1_l2_mirroring    sbts=suite
    sleep    3s

_L1-IQ profile dictionary
    [Arguments]    ${profile_prefix}
    ${is_none}    _It is None    ${profile_prefix}
    Return From Keyword If    ${is_none}
    ${profile_2_tmp}    Set Variable    except beamforming function of PUSCH/SRS/RIM-RS/RIM-RSSI
    &{profile_dict}    Create Dictionary    UL_PROFILE_1=[UL_PROFILE_1][FD][Event/Blind][7-2e]PUSCH/PUCCH/SRS issues debugging
    ...    UL_PROFILE_2=[UL_PROFILE_2][FD_POSTBF][Event/Blind][7-2e]PUSCH/SRS/RIM-RS/RIM-RSSI issues debugging, ${profile_2_tmp}
    ...    UL_PROFILE_3=[UL_PROFILE_3][TD][Event][7-2a/7-2e]Timing issues debugging
    ...    DL_PROFILE_1=[DL_PROFILE_1][FD_POSTBF][Event/Blind][7-2e]DL BLER or DL Throughput degradation issues debugging
    ...    UL_DL_PROFILE_1=[UL_DL_PROFILE_1][FD_POSTBF][Event][7-2e]Sleeping-Cell issues detected by Msg3 failure
    ${target_profile}    Get From Dictionary    ${profile_dict}    ${profile_prefix.upper()}
    Log To Console    [ INFO ] Selected L1-IQ profile is: ${profile_prefix} --> ${target_profile}
    [Return]    ${target_profile}

_Get radio configurations dictionary
    [Arguments]    ${ul_subcell_index_list}=${None}    ${dl_subcell_index_list}=${None}    ${extended_dict}=${None}
    ${ul_list_none}    _It is None    ${ul_subcell_index_list}
    ${dl_list_none}    _It is None    ${dl_subcell_index_list}
    Return From Keyword If    ${ul_list_none} and ${dl_list_none}    ${None}
    ${ul_id_dict}    _Get PCI and NRCELL ID from subcelll list    ${ul_subcell_index_list}
    ${dl_id_dict}    _Get PCI and NRCELL ID from subcelll list    ${dl_subcell_index_list}
    ${merged_id_dict}    Create Dictionary
    ${ul_not_none}    _It is Not None    ${ul_id_dict}
    ${merged_id_dict}    Run Keyword If    ${ul_not_none}    Evaluate    {**${merged_id_dict}, **${ul_id_dict}}
    ...    ELSE    Set Variable    ${merged_id_dict}
    ${dl_not_none}    _It is Not None    ${dl_id_dict}
    ${merged_id_dict}    Run Keyword If    ${dl_not_none}    Evaluate    {**${merged_id_dict}, **${dl_id_dict}}
    ...    ELSE    Set Variable    ${merged_id_dict}

    ${rmod_id_name_dict}    _Get RMOD id and productName

    ${activity_time}    Create Dictionary    capture_activity_timer=1
    ${radio_configurations_dict}    Create Dictionary
    ${is_none}    _It is None    ${extended_dict}
    ${tmp_extended_dict}    Set Variable If    ${is_none}    {}    ${extended_dict}
    ${tmp_dict}    Evaluate    {**${tmp_extended_dict}, **${activity_time}}

    ${nrcell_id_list}    Get Dictionary Keys    ${merged_id_dict}
    FOR    ${nrcell}    IN    @{nrcell_id_list}
        FOR    ${rmod_key}    ${nrcell_list}    IN    &{rmod_id_name_dict}
            Run Keyword If    '${nrcell}' in ${nrcell_list}    Set To Dictionary    ${radio_configurations_dict}    ${rmod_key}=${tmp_dict}
        END
    END
    [Return]    ${radio_configurations_dict}

_It is None
    [Arguments]    ${value}
    ${is_None}    Run Keyword And Return Status    Should Be Equal    ${value}    ${None}
    [Return]    ${is_None}

_It is Not None
    [Arguments]    ${value}
    ${not_None}    Run Keyword And Return Status    Should Not Be Equal    ${value}    ${None}
    [Return]    ${not_None}

_Get PCI and NRCELL ID from subcelll list
    [Arguments]    ${subcell_index_list}=${None}
    ${is_none}    _It is None    ${subcell_index_list}
    Return From Keyword If    ${is_none}    {}
    &{cell_ids_dict}    Create Dictionary
    FOR    ${subcell}    IN    @{subcell_index_list}
        ${PCI_PATTERN}    Set Variable    PCI:\\s+(\\d+)
        ${NRCELL_PATTERN}     Set Variable    NRCELL-(\\d+)
        ${pci}=    Get Regexp Matches    ${subcell}    ${PCI_PATTERN}
        ${nrcell}=     Get Regexp Matches    ${subcell}    ${NRCELL_PATTERN}
        Set To Dictionary    ${cell_ids_dict}    ${nrcell[0]}=${pci[0].split(':')[-1].strip()}
    END
    [Return]    ${cell_ids_dict}

_Get RMOD id and productName
    ${hw_info}    Get Board Info By Index    RMOD
    ${rmod_id_name_dict}    Create Dictionary
    FOR    ${rmod}    IN    @{hw_info.values()}
        ${isEmpty}    Run Keyword And Return Status    Should Be Empty    ${rmod}[carrierList]
        Continue For Loop If    ${isEmpty}

        ${nrcell_list}    Create List
        ${carrierList_per_rmod}    Set Variable    ${rmod}[carrierList]
        FOR    ${id}    IN    @{carrierList_per_rmod}
            ${cell_configuration}    Set Variable    ${id}[id][configuration]
            ${nrcell}    Set Variable    ${cell_configuration.split('/')[-2]}
            Append To List    ${nrcell_list}    ${nrcell}
        END

        ${rmod_id_configuration}    Set Variable    ${rmod}[id][configuration]
        ${rmod_id_runtime}    Set Variable    ${rmod}[id][runtime]
        ${rmod_productName}    Set Variable    ${rmod}[productName]

        ${rmod_r}    Set Variable    ${rmod_id_runtime.split('/')[-1]}
        ${rmod}    Set Variable    ${rmod_id_configuration.split('/')[-1]}
        ${rmod_key}    Set Variable    ${rmod}/${rmod_r}(${rmod_productName})

        ${nrcell_set}    Remove Duplicates    ${nrcell_list}
        Set To Dictionary    ${rmod_id_name_dict}    ${rmod_key}=${nrcell_set}
    END
    [Return]    ${rmod_id_name_dict}

Disable IQ capture via webUI
    [Arguments]    ${timeout}=60    ${sbts}=suite
    ${timeout}    Convert To Integer    ${timeout}
    selenium_coam.Disable Iq Capture    timeout=${timeout}    sbts=${sbts}

Save IQ capture data via webUI
    [Arguments]    ${sfn}=${65535}    # ${slot}=0
    ...            ${capture_mode}=Schedule synchronous stop of ongoing continuous capture
    selenium_coam.save_iq_capture
    ...    sfn_value=${sfn}
    # ...    slot_value=${slot}
    ...    capture_mode=${capture_mode}
    ...    sbts=suite
    ${isCaptured}    Wait Until Keyword Succeeds    6X    30s    To Get Realpath of file     path=${SUITE_LOG_DIRECTORY}    file_name=L1_IQ_Capture*
    ...    maxdepth=1
    ${blind_iq_log_name}    Set Variable    ${isCaptured.rsplit('/', 1)}[-1]
    Run    mv ${isCaptured} ${TEST_LOG_DIR}/${blind_iq_log_name}
    ${log_size}    Run    du -k ${TEST_LOG_DIR}/${blind_iq_log_name} | cut -f1
    ${log_size}    Convert To Integer    ${log_size}
    Should Be True    ${log_size}>10    [ ERROR ]L1_IQ_Capture log size is less than 10K: ${log_size}K.
    [Return]    ${TEST_LOG_DIR}/${blind_iq_log_name}
    [Teardown]    Disable IQ capture via webUI

To Get Realpath of file
    [Arguments]    ${path}    ${file_name}    ${maxdepth}=1
    ${realpath}    Run    find ${path} -maxdepth ${maxdepth} -name ${file_name}
    Should Not Be True    '${realpath}'==''    [ ERROR ] No such file : ${file_name} in ${path}
    [Return]    ${realpath}

_Get version for IQ capture
    Set Suite Variable    ${version}    ${active_sw.split('_')[0]}

Get Event Trigger Count on BBMOD
    [Arguments]    ${bsh}    ${rat}=NR
    [Documentation]    [Obsoleted] The bsh has been removed due to PR.
    ...    the keyword is used to check the count of event trigger, including LTE Events, NR Events, NR ML Events.
    ...    | Input Parameters | Man. | Description |
    ...    | ${bsh} | Yes | such as 'bsh 1:1', the target loki or thor on bbmod to check the count of event trigger. |
    ...    | ${rat} | Yes | 'LTE' or 'NR', the rat of target cell. Default is NR. |
    ${result}    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 ${bsh} /usr/lib64/python/antenna_snapshot_config.py --query
    Log To Console    \n[INFO]: ${result}
    ${regx}    Set Variable If    '${rat.upper()}'=='LTE'    (\\d+).LTE Events    (\\d+).NR Events
    ${event}    Get Regexp Matches    ${result}    ${regx}
    ${event_count}    Set Variable If    '${rat.upper()}'=='LTE'    ${event[0].strip(' LTE Events')}    ${event[0].strip(' NR Events')}
    ${event_count}    Convert To Integer    ${event_count}
    [Return]    ${event_count}

####~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Troubleshooting Scripts~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#####

Get All Troubleshooting Scripts By Module
    [Documentation]    To get SMOD or RMOD troubleshooting scripts information.
    ...    | Arguments | Default | Mandatory | Description |
    ...    | script_owner_module | RMOD | Y | it should be SMOD or RMOD |
    ...    | detailed_output | False | N | if set to True, detailed information will be got. |
    ...    | connection | default | N | alais name of setup_admin |

    [Arguments]    ${script_owner_module}=RMOD    ${detailed_output}=${False}    ${connection}=default
    Should Be True    '${script_owner_module.upper()}' in ('SMOD', 'RMOD')    [ ERROR ] script_owner_module should be SMOD | RMOD.
    ${output}    sbts_admin.get_all_troubleshooting_scripts    script_owner_module=${script_owner_module}    detailed_output=${detailed_output}
    ...    connection=${connection}
    Log    ${output}


Get Troubleshooting Script By Name
    [Documentation]    To get specific troubleshooting script information by script name.
    ...    | Arguments | Default | Mandatory | Description |
    ...    | script_name | RU_Common_capture_IQ_data | Y | RU_Common_capture_IQ_data or RU_Common_capture_L1low_data or RU_Common_register_dump |
    ...    | detailed_output | False | N | if set to True, detailed information will be got. |
    ...    | connection | default | N | alais name of setup_admin |

    [Arguments]    ${script_name}=RU_Common_capture_IQ_data    ${detailed_output}=${False}    ${connection}=default
    ${output}    sbts_admin.get_troubleshooting_script_by_name    script_name=${script_name}    detailed_output=${detailed_output}
    ...    connection=${connection}
    Log    ${output}


Launch Troubleshooting Script To Capture IQ
    [Documentation]    To get SMOD or RMOD troubleshooting scripts information.
    ...    | Arguments | Default | Mandatory | Description |
    ...    | script_name |  | Y | like as RU_Common_capture_IQ_data or RU_Common_capture_L1low_data or RU_Common_register_dump |
    ...    | output_file |  | Y | iq log path and name. |
    ...    | cell_list | None | Y | the cell(s) list to capture IQ log. like as [ NRCELL-0, NRCELL-1 ]. |
    ...    | rmod_list | None | Y | the RMOD(s) list to capture IQ log. like as [ RMOD-1/RMOD_R-1(AVQC) ]. |
    ...    | bbmod_list | None | N | the BBMOD(s) list to capture IQ log. like as [ BBMOD-1/BBMOD_R-1(ABIP) ]. Now it's not supported. |
    ...    | free_parameters | None | N | free_parameters. |
    ...    | detailed_output | False | N | if set to True, detailed information will be got. |
    ...    | timeout | 60 | N | timeout 60s. |
    ...    | connection | default | N | alais name of setup_admin |

    [Arguments]    ${script_name}    ${output_file}    ${cell_list}=${None}    ${rmod_list}=${None}    ${bbmod_list}=${None}
    ...    ${free_parameters}=${None}    ${detailed_output}=${False}    ${timeout}=60    ${connection}=default
    ${output}    sbts_admin.launch_troubleshooting_script    script_name=${script_name}    output_file_name=${output_file}
    ...    cell_list=${cell_list}    bbmod_list=${bbmod_list}    rmod_list=${rmod_list}    free_parameters=${free_parameters}
    ...    detailed_output=${detailed_output}    timeout=${timeout}    connection=${connection}
    Log To Console    ${output}
    Should Be True    'successfully' in '${output}'    [ ERROR ] Failed to launch troubleshooting script :: ${output}
    ${size}    Get File Size    ${output_file}
    Should Be True    ${size} > 81920    [ ERROR ] File size [ ${size} bytes ] is less than 81920 bytes :: ${output_file}
    [Return]    ${output_file}
