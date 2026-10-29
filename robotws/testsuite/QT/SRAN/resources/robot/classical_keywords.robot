*** Settings ***
Documentation  File containing keywords used for gnb startup test
Library      taf.transport.ssh            WITH NAME    ssh
Library      taf.sbts.oam.coam.admin       WITH NAME    coam
Library      ute_admin_infomodel
Library      ${CURDIR}/../python/perform_sw_update_on_slave_board.py
Library      ${CURDIR}/../python/classical_keywords.py
Library      ${CURDIR}/../python/common.py
Library      ${CURDIR}/../python/str.py
Library      ${CURDIR}/../python/fw_downgrade.py

Resource     taf/rfrl/common_resources/robot/connection_alias_store.robot

*** Keywords ***
Install package on cOAM
    [Arguments]    ${T1orT2}=None    ${sw_package}=${AF_PATH}
    Run Keyword and ignore error    Get BTS SW Version
    BuiltIn.Set Global Variable    ${check_sw_package}    ${sw_package}
    Check BTS Connection Status
    IF   ${dualcore} and '${T1orT2}''=None'
        ${board_conf_before_sw_update}    Check Board Configuration
        Set Suite Variable    ${board_conf_before_sw_update}
    END
    Log to console          Installing SW package from path: ${sw_package}
    coam.update_software    sw_package=${sw_package}    timeout=5400    connection=coam_admin
    Allow To Connect To BTS After NIDD Downgrade
    Wait For BTS To Be Available    T1orT2=${T1orT2}    AF_PATH=${sw_package}
    [Teardown]    Run Keyword and ignore error    Get BTS SW Version    time=3min    coam_connection=${True}

Allow To Connect To BTS After NIDD Downgrade
    [Arguments]        ${recovery}=False
    TRY
        Run Keyword If    '${nidd_basebuild}'!='${None}' or ${recovery}    Run Keywords
        ...                Wait Until Keyword Succeeds    5min  20s    coam.Connect To
        ...                bts_host=${LMP_IP}   update_interval=1000   name=ethernet_ssh
        ...        AND     coam.Enable SSH Access                           timeout=300    connection=ethernet_ssh
        ...        AND     Run Keyword and ignore error    coam.teardown    connection=ethernet_ssh
    EXCEPT  AS  ${error}
        Log To Console  \n -->Allow to connect To BTS After NIDD Downgrade failed with error: ${error}
        Fail
    END

Check BTS Connection Status
    ${connection_status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min  20s
    ...                     coam.connect to    bts_host=${LMP_IP}   update_interval=1000   name=coam_admin
    Should Be True          ${connection_status}

Install eNB package on cOAM
    [Arguments]        ${bts_host}=${tl.enbs[0].system_module.common_units[0].lmp_connection.addr}
    Log To Console    \n --> Performing eNB SW upgrade ... ...
    wait until keyword succeeds  5 min  30 sec
    ...     coam.connect to   bts_host=${bts_host}    update_interval=1000
	...		name=coam_admin
    coam.update_software    sw_package=${AF_PATH}    timeout=2400    connection=coam_admin
    Log To Console    \n --> Activating new eNB SW ... ...
    BuiltIn.Sleep              2min

Verify time synchronization (GPS+TOPP)
    [Arguments]        ${topp_check_need}=${True}
    Wait Until Keyword Succeeds    45s  10s    coam.connect to
    ...                bts_host=192.168.255.129   update_interval=1000   name=coam_admin
    ${sync_sources}    ${sync_sources_details}    get_bts_sync_sources
    log    Configured sync sources are ${sync_sources}
    ${gps_check}    check_gps_sync_status
    ${topp_check}    check_topp_sync_status    ${sync_sources_details}
    Run Keyword And Continue On Failure    Should Be True    ${gps_check}[0]    ${gps_check}[1]
    Run Keyword If    ${topp_check_need}    Should Be True    ${topp_check}[0]    ${topp_check}[1]

Stop RF Calibraton
    [Documentation]     Stop RF calibraton
    [Timeout]           1min
    ${RU_pass}          Get Variable Value    ${tl.${gnb_or_enb}s[0].dus[0].rus[0].default_ssh_connection_details.password}    umniedziala
    Connect To Common Unit    alias=BB1
    ${out_put}          ssh.execute           command=cat /ffs/run/config/FRIps.txt
    ...                                       connection=BB1
    ...                                       timeout=60s
    ${pattern}          Set Variable          \(\(\\d\)\{1,3\}\\.\)\{3\}\(\\d\)\{1,3\}
    ${match_output}     Get Regexp Matches    ${out_put}        ${pattern}
    ${rf_ip}            Set Variable          ${match_output[0]}
    stop_rf_calibraton_feat_1834              rf_ip=${rf_ip}    alias=BB1    password=${RU_pass}

Verify BTS Setup
    [Arguments]            ${connection}=coam_admin
    ${bts_info}            coam.get_bts_statuses    timeout=30    connection=${connection}
    Log Many               ${bts_info}
    Dictionary Should Contain Item    ${bts_info}    operationalState    Enabled
    ${proceduralState}            Get From Dictionary    ${bts_info}    proceduralState
    @{allowedProceduralStates}    Create List    OnAir
    List Should Contain Value     ${allowedProceduralStates}    ${proceduralState}

Verify Cells Setup
    [Documentation]    Check cell on air for all 2/3/4/5G cells
    [Arguments]        ${connection}=coam_admin    ${log}=False
    FOR    ${key}     IN     @{class_name_dict.keys()}
        ${cell_list}    Get Parameters For All    class_name=${class_name_dict["${key}"]}    timeout=30    connection=${connection}
        ${cell_list_exists}      Run Keyword And Return Status     Should Not Be Empty    ${cell_list}
        ${result}       Run Keyword If     ${cell_list_exists} and '${log}'=='False'      Run Keyword And Return Status
        ...             Check Cell On Air    ${key}    @{cell_list}
        ...             ELSE     Set Variable    ${True}
        Run Keyword And Continue On Failure    Run Keyword If    ${result}!=${True}    Fail      ${key} cell not on air!
        Run Keyword If    ${cell_list_exists} and '${log}'=='True'     Log Cells Status    ${key}    @{cell_list}
    END

Check Cell On Air
    [Documentation]    Check cell On-Air for given cell list
    [Arguments]        ${technology}   @{cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Log Many    ${cell}
        Check Cell Status By Keys    ${technology}    cell=${cell}
    END

Check Cell Status By Keys
    [Documentation]    Create status dictionary for all cells
    [Arguments]        ${technology}    ${cell}    ${log}=False
    Run Keyword If    '${log}'=='True'    Get Cell ID From Parameters    cell=${cell}
    FOR    ${key}     IN     @{cell_check_keys.keys()}
        ${cell_list_exists}    Run Keyword And Return Status    Dictionary Should Contain Key    ${cell}    ${key}
        Run Keyword If    ${cell_list_exists} and '${log}'=='False'
        ...    Should Be Equal As Strings    ${cell['${key}']}    ${cell_check_keys["${key}"]}    ignore_case=True
        ...    ELSE IF    ${cell_list_exists} and '${log}'=='True'
        ...    Print Parameters For Each Cell    ${technology}    ${key}    ${cell['${key}']}    ${cell_check_keys["${key}"]}
    END

Print Parameters For Each Cell
    [Documentation]    Print cell parameters with proper colour - green if ok, red if nok.
    [Arguments]        ${technology}    ${parameter}    ${current_value}    ${expected_value}
    ${value_status}    Run Keyword And Return Status    Should Be Equal As Strings    ${current_value}    ${expected_value}    ignore_case=True
    Run Keyword If     ${value_status}    Log To Console    \t\t\t ${parameter} is ${green}${current_value}${rm_color}
    ...       ELSE     Log To Console     \t\t\t ${parameter} is ${red}${current_value}${rm_color}
    ${technology_status}    Get Variable Value   ${technology_status}   ${EMPTY}
    ${technology_status}    Set Variable If     ${value_status}==${False} and '${technology}' not in '${technology_status}'
    ...                     ${technology_status}${technology}${SPACE}    ${technology_status}
    Set Test Variable       ${technology_status}

Get Cell ID From Parameters
    [Documentation]    Get Cell ID and log to console
    [Arguments]        ${cell}
    ${id}    Fetch From Right    ${cell['id']}    /
    Log To Console    \t\t Cell ID: ${id}

Log Cells Status
    [Documentation]    Log to console cell status for given cells
    [Arguments]    ${technology}    @{cell_list}
    Log To Console    \n\t RAT Technology: ${technology}
    FOR    ${cell}     IN     @{cell_list}
        Check cell status by keys    ${technology}     cell=${cell}    log=True
    END

Log Cells Status And Set Dir
    [Documentation]    Log to console cell status and set IMS log dir name
    [Arguments]    ${status}    ${log_name}    ${dir_name}=None
    Verify Cells Setup    log=True
    Run Keyword If    ${status}==${False} and '${dir_name}'!='None'    Run Keywords
    ...               Set Suite Variable    ${ims_log_name}    _after_${log_name}_
    ...        AND    Set Suite Variable    ${ims_dir_name}    ${dir_name}
    Run Keyword If    ${status}==${False}     Fail    ${technology_status}cell setup failed!!!

Get Object Information
    [Arguments]          ${object}
    TRY
        ${get_object}        coam.get_managed_objects    class_name=${object}    connection=coam_admin
    EXCEPT    AS    ${error}
        Log    Failed to get object information, due to ${error}!, second attempt...     WARN
        WA for coam connect
        ${get_object}    coam.get_managed_objects    class_name=${object}    connection=coam_admin
    END
    ${object_length}     Get Length    ${get_object}
    ${object_status}     Set Variable    False
    RETURN    ${object_status}    ${get_object}    ${object_length}

Get Object Parameters
    [Arguments]          ${dist_name}    ${pattern}    ${output}=Available
    TRY
        ${object_status}     coam.get_parameters    dist_name=${dist_name}    pattern=${pattern}    connection=coam_admin
    EXCEPT    AS    ${error}
        Log    Failed to get object parameters, due to ${error}!, second attempt...     WARN
        WA for coam connect
        ${object_status}     coam.get_parameters    dist_name=${dist_name}    pattern=${pattern}    connection=coam_admin
    END
    ${object_status}     Run Keyword And Return Status    Should Be Equal    ${object_status['${pattern}']}    ${output}    ignore_case=true
    RETURN             ${object_status}

Check E1 link
    ${E1_status}    ${NRBTS_L}    ${length}    Get Object Information    NRBTS_L
    FOR    ${id}    IN RANGE   ${length}
        ${E1_status}        Get Object Parameters    dist_name=${NRBTS_L[${id}]['distName']}    pattern=e1CLinkStatusCuCp
        Exit For Loop If    ${E1_status}
    END
    Run Keyword If   '${E1_status}'=='False'    Fail   E1 link check failed on Webui!

Check F1 Link
    ${F1_status}    ${NRDU_L}    ${length}    Get Object Information    NRDU_L
    FOR    ${id}    IN RANGE   ${length}
        ${F1_status}        Get Object Parameters    dist_name=${NRDU_L[${id}]['distName']}    pattern=f1CLinkStatusCU
        Exit For Loop If    ${F1_status}
    END
    Run Keyword If    '${F1_status}' == 'False'    Fail    F1 link check failed on Webui!

Check X2 link
    [Documentation]    Check if x2 link is up
    ${X2_status}    ${LTEENB_L}    ${length}    Get Object Information    LTEENB_L
    FOR    ${id}    IN RANGE   ${length}
        ${X2_status}        Get Object Parameters    dist_name=${LTEENB_L[${id}]['distName']}    pattern=x2LinkStatus
        Exit For Loop If    ${X2_status}
    END
    Run Keyword If    '${X2_status}' == 'False'    Fail    X2 link check failed!

Check S1 link
    [Documentation]    Check if s1 link is up
    ${S1_status}    ${LNMME_A}    ${length}    Get Object Information    LNMME_A
    FOR    ${id}    IN RANGE   ${length}
        ${S1_status}        Get Object Parameters    dist_name=${LNMME_A[${id}]['distName']}    pattern=s1LinkStatus
        Exit For Loop If    ${S1_status}
    END
    Run Keyword If    '${S1_status}' == 'False'    Fail    S1 link check failed!

Check NG link
    [Documentation]    Check if NG link is up
    ${NG_status}    ${SERVEDAMF_L}    ${length}    Get Object Information    SERVEDAMF_L
    FOR    ${id}    IN RANGE   ${length}
        ${NG_status}        Get Object Parameters    dist_name=${SERVEDAMF_L[${id}]['distName']}    pattern=ngLinkStatus    output=Active
        Exit For Loop If    ${NG_status}
    END
    Run Keyword If    '${NG_status}' == 'False'    Fail    NG link check failed!

Check NG connection
    [Documentation]    Check NG link setup in cp if logs
    Run Keyword If     '${smod_type}' == 'ASIK' and ${is_Master}
    ...                connection_alias_store.Connect to fctlb    du_index=${0}    alias=NgLink
    ...    ELSE IF     '${smod_type}' == 'ASIK' and ${SBTS}
    ...                connection_alias_store.Connect to fctlb    du_index=${0}    alias=NgLink
    ...     ELSE IF    '${smod_type}' == 'ASIK' and '${STREAM_PREFIX}'=='21a'  Run Keyword
    ...                connection_alias_store.Connect to fctlb    du_index=${0}    alias=NgLink
    ...     ELSE       Connect To Common Unit    du_index=${0}    alias=NgLink
    ${NG_status1}      ssh.execute    grep 'Received data on NG-C link' /tmp/node_CPIF00/tmp/startup_cp_if.log
    ...                               connection=NgLink
    ...                               timeout=60s
    ${NG_status2}      ssh.execute    xzcat /tmp/node_CPIF00/tmp/startup_cp_if.log.xz | grep 'Received data on NG-C link'
    ...                               connection=NgLink
    ...                               timeout=60s
    ${NG_status}       Catenate       ${NG_status1}    ${NG_status2}
    Should Contain     container=${NG_status}    item=Received data on NG-C link
    [Teardown]         ssh.disconnect    connection=NgLink

Setup Wtsemu for X2 connection
    ssh.connect_to     hostname=${tl.core.default_ssh_connection_details.addr}
    ...                username=${tl.core.default_ssh_connection_details.username}
    ...                password=${tl.core.default_ssh_connection_details.password}    alias=x2_conn
    wts_runner.configure_wtsemu_edaemon    edaemon_ssh_alias=x2_conn
    ...                                    directory_path=${tl.core.dir_path}    port=${tl.custom['edaemon_port']}
    wts_runner.configure_wtsemu_egate   egate_ssh_alias=x2_conn   directory_path=${tl.core.dir_path}   port=${tl.custom['egate_port']}
    wts_runner.start_wtsemu    egate_console_ip=${tl.core.default_ssh_connection_details.addr}   egate_port=${tl.custom['egate_port']}

Start and check X2 connection
    ssh.connect_to     hostname=${tl.core.default_ssh_connection_details.addr}
    ...                username=${tl.core.default_ssh_connection_details.username}
    ...                password=${tl.core.default_ssh_connection_details.password}    alias=x2_conn
    wts_runner.configure   file=${tl.core.dir_path}${/}${tl.core.cfg_filename}
    wts_runner.read_wtsemu_output_until    expected=CHANGE STATE: ACTIVE - SimMode is ready now    timeout=10
    wts_runner.enb_x2_link_up    enb_id=${tl.custom['enb_id']}    target_id=${tl.custom['target_id']}
    BuiltIn.Sleep              30
    wts_runner.read_wtsemu_output_until_re   expected=ENB-1: X2AP Link with .NB-2 .* is up    timeout=360

Get BTS SW Version
    [Arguments]          ${time}=1min    ${log}=installation    ${bts_host}=${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}
    ...                  ${coam_connection}=${False}    ${check_times}=10    ${alias}=coam_admin
    Run Keyword If       ${coam_connection}    WA for coam connect    bts_host=${bts_host}    time=${time}
    ${BTS_SW_Info}       Wait Until Keyword Succeeds    ${check_times}x    20s    Get software info    alias=${alias}
    ${active_SW}         Get from dictionary  ${BTS_SW_Info}    Active SW version
    ${passive_SW}        Get from dictionary  ${BTS_SW_Info}    Passive SW version
    IF    '${log}'!='${False}'
        ${console_log_list}    Create List
        IF    '${time}'=='1min'
            Append To List    ${console_log_list}    \nBefore SW ${log} we have on the BTS:
        ELSE
            Append To List    ${console_log_list}    \nAfter SW ${log} we have on the BTS:
        END
        Append To List    ${console_log_list}    Active partition SW: ${active_SW}
        Append To List    ${console_log_list}    Passive partition SW: ${passive_SW}\n
        FOR    ${line}    IN    @{console_log_list}
            Log To Console    ${line}
        END
    END
    Set Test Variable    ${active_SW}
    Set Test Variable    ${passive_SW}

Check LMP And M-Plane Connection
    ${LMP_status}    Run Keyword And Return Status    ssh.connect to    hostname=192.168.255.129
    ...               username=toor4nsn
    ...               password=oZPS0POrRieRtu
    ...               alias=LMP
    Run Keyword And Ignore Error    ssh.disconnect            connection=LMP
    ${MPlane_status}    Run Keyword And Return Status    Connect to Common Unit    alias=MPlane
    Run Keyword And Ignore Error    ssh.disconnect            connection=MPlane
    Run Keyword If    '${LMP_status}'=='False' and '${MPlane_status}'=='False'    Fail    gnb is not accessialble

Stop And Fix Check
    Stop And Fix Steps
    Create File        ${OUTPUT_DIR}/data_after_test.txt    ${EMPTY}
    Run Keyword If     '${stop_message}'=='PASS'    Append To File    ${OUTPUT_DIR}/data_after_test.txt    stop_and_fix=false\n
    ...    ELSE
    ...    Append To File    ${OUTPUT_DIR}/data_after_test.txt    stop_and_fix=true\nstop_and_fix_reason=${stop_reason}\n

Stop And Fix Steps
    ${conn_status}       Run Keyword And Return Status        Check LMP And M-Plane Connection
    Run Keyword If       ${conn_status}!=${True}              Log    Stop & Fix: Check LMP And M-Plane Connection Failed \n    WARN
    ${coam_status}       Run Keyword And Return Status
    ...                  Run Keyword If    ${conn_status}     WA for coam connect    bts_host=192.168.255.129
    Run Keyword If       ${coam_status}!=${True}              Log    Stop & Fix: WA for coam connect Failed \n    WARN
    ${alarm_status}      Run Keyword And Return Status
    ...                  Run Keyword If    ${coam_status}     Check Active Alarms For Stop And Fix
    Run Keyword If       ${alarm_status}==${False}             Log    Stop & Fix: Alarm is visible: ${alarms_stop_and_fix} \n    WARN
    ${stop_message}      Set Variable If
    ...    ${conn_status} and ${coam_status} and ${alarm_status}
    ...    PASS
    ...    FAIL
    Set Suite Variable   ${stop_message}
    ${stop_reason}    Run Keyword If     '${conn_status}'=='False' or '${coam_status}'=='False'
    ...    Set Variable    gnb is not accessialble
    ...    ELSE IF    '${coam_status}'=='True' and '${alarm_status}'=='False'
    ...    Set Variable    RF detection failed with FID 10 alarm active
    Set Suite Variable   ${stop_reason}

Verify BTS Startup
    [Documentation]    Author: Emilia Sadowska
    ...                Description: Verify smod, bbmod, rf and containers detection.
    Log To Console          \n ------------------------------------------------------------------------------
    Verify Smod Detection
    Verify BBmod Detection
    Verify RF Detection
    Verify Containers
    Should Be True          ${smod_status} and ${bbmod_status} and ${rf_status} and ${containers_status}    Verify BTS Startup Failed!!!
    [Teardown]    Log To Console    ------------------------------------------------------------------------------

Verify Smod Detection
    ${smod_status}          Run Keyword And Return Status    Run Keywords
    ...                     Log To Console                   \t Verify Smod Detection
    ...        AND          Wait Until Keyword Succeeds      10min  30s    Check Smod State
    Run Keyword And Ignore Error     Log HW Status    hw=SMOD
    Print Console Log With Status    ${smod_status}
    Set Test Variable                ${smod_status}

Verify BBmod Detection
    [Arguments]    ${bbmod_detection_time}=10
    ${bbmod_check_condition}    Catenate    'ASO' not in '${smod_type}' and ${smod_status} and 'FSMF / IPHY-FSMF' not in '${hw_config}'
    ${bbmod_status}         Run Keyword And Return Status    Run Keyword If    ${bbmod_check_condition}    Run Keywords
    ...                     Log To Console                   ------------------------------------------------------------------------------
    ...        AND          Log To Console                   \t Verify BBmod Detection
    ...        AND          Wait Until Keyword Succeeds      ${bbmod_detection_time}min  30s    Check BBmod State
    Run Keyword If          ${bbmod_check_condition}         Run Keyword And Ignore Error    Log HW Status    hw=BBMOD
    Run Keyword If          ${bbmod_check_condition}         Run Keywords     Print Console Log With Status    ${bbmod_status}
    ...        AND          Set Test Variable       ${bbmod_status}
    ...       ELSE    Set Test Variable       ${bbmod_status}    ${True}

Verify RF Detection
    ${log_versions_status}    Run Keyword And Return Status    Variable Should exist    ${RF_VERSIONS_MAP}
    ${ue_type}              Get Variable Value    ${tl.ues[0].ue_type}    default
    ${rf_check_duration}    Set Variable     10min
    IF    ${smod_status} and ${bbmod_status}
        Log To Console                   ------------------------------------------------------------------------------
        Log To Console                   \t Verify RF Detection
        TRY
            Check GPS Receiver Alarm
            ...    skip_coam_connection_setup=${True}
            ...    check_times=10
            ...    gps_status_check_after_firmware_upgrade=${False}
        EXCEPT    AS    ${error}
            Log    GPS Receiver Alarm check failed due to ${error}    WARN
        END
        ${rf_detection_status}    Run Keyword And Return Status
        ...    Wait Until Keyword Succeeds      ${rf_check_duration}  30s    Check RF Status    logs=${True}
        IF    ${rf_detection_status} and ${log_versions_status}
            ${rf_version_check_status}    Verify RF Version On Webem
        ELSE
            ${rf_version_check_status}    Set Variable    SKIPPED
        END
        ${rf_status}    Evaluate
        ...    '${rf_detection_status}'=='True' and ('${rf_version_check_status}'!='False')
        IF    '${rf_version_check_status}'!='SKIPPED' and ${log_versions_status}
            ${rf_versions}     get_rf_versions
            Run Keyword And Ignore Error    Log HW Status    hw=RF    active_rf_sw_version=${rf_versions}
            ...    log_rf_versions_status=${log_versions_status}
        ELSE
            Run Keyword And Ignore Error    Log HW Status    hw=RF
        END
    ELSE
        ${rf_status}    Set Variable    SKIPPED
    END
    Print Console Log With Status    ${rf_status}
    Set Test Variable                ${rf_status}

Verify RF Version On Webem
    [Arguments]    ${connection}=coam_admin
    FOR   ${elem}   IN    @{output_RF}
        IF    '${RF_VERSIONS_MAP['${elem['productName']}']}'!='not_set'
            IF    '${elem['productName']}' in ${oran_rf_list}
                CONTINUE
            END
            ${version_matched}    ${rf_versions}    Check If RF Versions Matched    RF_name=${elem['productName']}
            ...    target_version=${RF_VERSIONS_MAP['${elem['productName']}']}
            ...    connection=${connection}
            IF    not ${version_matched}    RETURN    ${False}
        END
    END
    ${all_versions_matched}    Get Variable Value    ${version_matched}    SKIPPED
    RETURN    ${all_versions_matched}

Verify Containers
    ${containers_status}    Run Keyword And Return Status    Run Keyword If   'FSMF' not in '${smod_type}'    Run Keywords
    ...                     Log To Console                   ------------------------------------------------------------------------------
    ...        AND          Log To Console                   \t Verify Containers Start Up
    ...        AND          Wait Until Keyword Succeeds    1min    20sec     Verify Containers Start Up
    ${container_status_details}    Get Variable Value   ${container_status_details}    ${EMPTY}
    IF    'FSMF' not in '${smod_type}'
        IF    ${containers_status}
            Log To Console      \t |${green} PASS ${rm_color}|
        ELSE
            Log To Console    \t |${red} FAIL ${rm_color}| \n ${container_status_details}
        END
    END
    Set Test Variable       ${containers_status}

Print Console Log With Status
    [Documentation]    Description: Print pass or fail for smod, bbmod and rf detection.
    [Arguments]     ${status}
    ${status}         Convert To String    ${status}
    Run Keyword If    '${status}'=='True'       Log To Console    \t |${green} PASS ${rm_color}|
    ...    ELSE IF    '${status}'=='SKIPPED'    Log To Console    ${byellow} RF check is skipped!!!${rm_color}
    ...       ELSE                              Log To Console    \t |${red} FAIL ${rm_color}|

Verify Containers Start Up
    [Documentation]    Author: Emilia Sadowska
    ...                Description: Verify Containers Start Up
    ${chk_command_output}=    Execute CHK Command    grep_cmd=grep -i state
    ${container_status_details}    Set Variable If    ${CHK_status}    ${chk_command_output}    ${EMPTY}
    Set Test Variable             ${container_status_details}
    Run Keyword if     ${CHK_status}    Check Container State With CHK    output=${chk_command_output}
    ...    ELSE        Check Container State With SupervisorS

Check Container State With SupervisorS
    [Documentation]    Author: Emilia Sadowska
    ...                Description: Check container state with supervisorS if chk command is not available.
    ${list_status}    Run Keyword And Return Status    Variable Should Exist    @{nodes}
    Run Keyword If    ${list_status}!=${True}    Create List With All Nodes
    Wait Until Keyword Succeeds    10s    5s    Check Containers Status With Supervisors

Create List With All Nodes
    [Documentation]    Author: Emilia Sadowska
    ...                Description: Create list with containers base on vertical and horizontal position on BTS and list for every configuration.
    @{nodes}    Create List
    Set Test Variable    @{nodes}
    Get Nodes
    Run Keyword If    'ASO' not in '${smod_type}'    Get Nodes    module=basebandModules
    Should Not Be Empty    ${nodes}

Get Horizontal And Vertical Position
    [Documentation]    Author: Emilia Sadowska
    ...                Description: Get horizontal and vertical position.
    [Arguments]    ${module}=systemModules
    TRY
        ${bts_info}    coam.Get Bts Info    connection=coam_admin
    EXCEPT    AS    ${error}
        Log    Failed to get BTS info, due to ${error}!, second attempt...     WARN
        WA for coam connect
        ${bts_info}    coam.Get Bts Info    connection=coam_admin
    END
    ${length}                      Get Length           ${bts_info['${module}']}
    Set Suite Variable             ${${module}_number}  ${length}
    FOR    ${index}    IN RANGE    0    ${length}
        ${distname}      Set Variable             ${bts_info['${module}'][${index}]['id']['internal']}
        ${horizontal}    coam.get_parameters      connection=coam_admin
        ...              dist_name=${distname}    pattern=horizontalPosition
        ${vertical}      coam.get_parameters      connection=coam_admin
        ...              dist_name=${distname}    pattern=verticalPosition
        ${productName}   coam.get_parameters      connection=coam_admin
        ...              dist_name=${distname}    pattern=productName
        Run Keyword If    'FSMF' not in '${productName}[productName]' and 'FBBA' not in '${productName}[productName]'
        ...    Set Suite Variable    ${${module}_${index}_horizontal}    ${horizontal}[horizontalPosition]
        Run Keyword If    'FSMF' not in '${productName}[productName]' and 'FBBA' not in '${productName}[productName]'
        ...    Set Suite Variable    ${${module}_${index}_vertical}      ${vertical}[verticalPosition]
        Run Keyword If        'ASO' in '${smod_type}'             Set Suite Variable    ${${module}_${index}_horizontal}    1
        Run Keyword If        'ASO' in '${smod_type}'             Set Suite Variable    ${${module}_${index}_vertical}      1
    END

Get Nodes
    [Documentation]    Author: Emilia Sadowska
    ...                Description: Create List With All Nodes.
    [Arguments]    ${module}=systemModules
    Get Horizontal And Vertical Position    module=${module}
    Connect to Common Unit    alias=smod
    ${board}                  Set Variable If    '${module}'=='systemModules'    master    slave
    FOR    ${index}    IN RANGE    0    ${${module}_number}
        ${productName}    get_board_name     board=${board}    connection=smod    hw_config=${hw_config}    index=${index}
        ${module_verdict}    Get Variable Value    ${${module}_${index}_vertical}    None
        ${vertical}       Set Variable If    '${module_verdict}'=='1'    0
        ...    '${module_verdict}'!='None'    ${module_verdict}
        Run Keyword If    '${module_verdict}'!='None'    Run Keywords
        ...    Add Node Based On Configuration      horizontal=${${module}_${index}_horizontal}    vertical=${vertical}    name=${productName}
        ...    AND    Set Test Variable                    ${${module}_${index}}    ${productName}
    END
    [Teardown]    ssh.disconnect    connection=smod

Add Node Based On Configuration
    [Documentation]    Author: Emilia Sadowska
    ...                Description: Add Node Based On Configuration.
    [Arguments]    ${horizontal}    ${vertical}    ${name}
    Log To Console    \n -->Adding nodes for ${name} configuration
    FOR    ${node}    IN    @{${name}_node}
        Append To List    ${nodes}    0x${horizontal}${vertical}${node}
    END

Check Containers Status With Supervisors
    [Documentation]    Author: Emilia Sadowska
    ...                Description: Check containers state using supervisors.
    Connect to Common Unit    alias=smod
    FOR    ${node}    IN    @{nodes}
        ${node_state}    ${msg}    check_container_state_via_supervisors    node=${node}   alias=smod
        Run Keyword If   not ${node_state}    Fail    ${msg}
    END
    [Teardown]    ssh.disconnect    connection=smod

Execute CHK Command
    [Arguments]     ${grep_cmd}
    [Documentation]    Description: Execute CHK Command
    Connect to Common Unit    alias=smod
    ${output}                 ssh.Execute    command=chk container | ${grep_cmd}    connection=smod    timeout=60s
    ${CHK_status}             Run Keyword And Return Status    Should Not Contain    ${output}    command not found
    Set Test Variable         ${CHK_status}
    RETURN      ${output}
    [Teardown]    ssh.disconnect    connection=smod

Check Container State With CHK
    [Documentation]    Author: Emilia Sadowska
    ...                Description: Check container state using command chk container
    [Arguments]         ${output}
    @{contaiers_list}    Split String    ${output}    \n
    Remove From List     ${contaiers_list}    -1
    FOR    ${container}    IN    @{contaiers_list}
        Run Keyword And Continue On Failure    Should Contain    ${container}    State:3    msg=Container Failed: ${container}
    END
    ${output}=         Execute CHK Command    grep_cmd=grep -i failed
    Should Contain    ${output}    failed : 0    msg=Container failed, please check!

Cleanup Configuration On Bts And Sw Installation From Admin
    [Documentation]    Author: Min Zheng
    ...                This keyword is used to remove files under /ffs/run/config and then perform SW installation from admin
    Log To Console    Reset configuration failed, cleanup files under /ffs/run/config to be performed \n
    Wait Until Keyword Succeeds    1min    20s    ssh.connect_to
    ...                                           hostname=192.168.255.129
    ...                                           username=toor4nsn
    ...                                           password=oZPS0POrRieRtu
    ...                                           alias=gnb
    ssh.execute    command=cd /ffs/run/config && rm -rf * && reboot    connection=gnb    timeout=60s
    ${connect_status}=    Run Keyword And Return Status
    ...                   Wait Until Keyword Succeeds    8min    15s    coam.connect to
    ...                                                                 bts_host=${LMP_IP}
    ...                                                                 name=coam_admin
    Run Keyword If    '${connect_status}'=='True'    Log To Console    Connection to admin on BTS - PASSED
    ...       ELSE    Fail    \n Connection to admin on BTS - FAILED \n
    Log To Console    \n========================== Configuration Reset done - Start SW installation... ===========================\n
    FOR    ${_}    IN RANGE    0    5
        coam.connect to    bts_host=${LMP_IP}    name=coam_admin
        ${res_bool}=    Run Keyword And Return Status    coam.update_software
        ...                                              sw_package=${basebuild_path}
        ...                                              timeout=5400
        ...                                              connection=coam_admin
        Run Keyword And Ignore Error    coam.Teardown admin    connection=coam_admin
        Exit For Loop If    '${res_bool}'=='True'
    END
    Run Keyword If    '${res_bool}' == 'False'    Fail    \n SW Installation Failed \n
    [Teardown]   Run Keyword And Ignore Error    coam.Teardown admin    connection=coam_admin

Install Software Using YAFT
    [Documentation]    Author: Min Zheng
    ...                This keyword is used to perform YAFT for software installation and to verify admin connection after YAFT
    ${board_testpc_index_map}    Set Variable If    ${airscale_fsmf} or ${dualcore}      ${AIRSCALE_FSMF_DUALCORE_testpc_index_map}
    ...                                                                   ${single_board_testpc_index_map}
    Download Yaft
    Perform Yaft    ${board_testpc_index_map}
    Allow To Connect To BTS After NIDD Downgrade
    ${connected_to_admin}    Run Keyword And Return Status    Wait Until Keyword Succeeds
    ...                      10min    20s    coam.Setup Admin    bts_host=${LMP_IP}    name=coam_admin
    Run Keyword If    not ${connected_to_admin}
    ...       Fail    \n !!!Failed to setup admin session via 192.168.255.129 after SW Installation!!! \n

Perform Configuration Reset On Admin
    Log To Console        \n========================== NIDD Difference detected - Start Configuration Reset... ===========================\n
    ${fdsw_reset_bool}    Run Keyword And Return Status    coam.Reset Configuration
    ...                                                    reset_type=ConfigurationWithDiagnosticAndRecoverySw
    ...                                                    timeout=15
    ...                                                    connection=coam_admin
    Run Keyword And Ignore Error    coam.Teardown admin    connection=coam_admin
    IF    not ${fdsw_reset_bool}
        Perform Yaft    ${single_board_testpc_index_map}
    ELSE
        SW Installation From FDSW
    END

Perform Yaft
    [Documentation]  Author: Min Zheng
    ...              This Keyword is used to perform yaft
    [Arguments]    ${board_testpc_index_map}    ${netboot_enabled}=False    ${yaft_build_path}=${basebuild_path}
    ${remove_crasign_cmd}    Catenate   umount /etc/keys.d/bcerts; umount /etc/keys.d/board; rm -rf /flash/etc/keys.d;
    ...                  rm /ffs/run/addons/cra*
    FOR    ${master_slave}    ${pc_index}    IN   &{board_testpc_index_map}
        IF    ${netboot_enabled}
            ${yaft_ip}    Set Variable    192.168.255.1
        ELSE
            ${yaft_ip}    Set Variable If    '${master_slave}'=='slave'    192.168.255.119    192.168.255.129
        END
        ${vm_addr}    Set Variable If    "${master_slave}"=="master"
        ...    127.0.0.1    ${tl.test_pcs[${pc_index}].default_ssh_connection_details.addr}
        ${hostname}    Set Variable    ${vm_addr}
        ${username}    Set Variable    ${tl.test_pcs[${pc_index}].default_ssh_connection_details.username}
        ${password}    Set Variable    ${tl.test_pcs[${pc_index}].default_ssh_connection_details.password}
        Wait Until Keyword Succeeds    2min   30s    Connect to host    hostname=${hostname}
        ...                                                             username=${username}
        ...                                                             password=${password}
        ...                                                             alias=${master_slave}
        Wait Until Keyword Succeeds    2min   30s    ssh.connect_to
        ...                                          hostname=${yaft_ip}
        ...                                          username=toor4nsn
        ...                                          password=oZPS0POrRieRtu
        ...                                          proxy=${master_slave}
        ...                                          alias=gnb_${master_slave}
        Log To Console    \nStart to perform yaft on ${master_slave} for ${cellConfiguration} configuration...\n
        ${yaft_swconfig_path}     Set Variable    /home/ute/yaft/libyaft/swconfig.txt
        Log    Check flag 0x1A0020=1 in ${yaft_swconfig_path}
        ${flag_check}    ssh.execute    command=grep -i 0x1A0020 ${yaft_swconfig_path}
        ...                             connection=${master_slave}
        IF    "${flag_check.strip()}" == ""
            ssh.execute    command=echo '0x1A0020=1' >> ${yaft_swconfig_path}
            ...    connection=${master_slave}
        ELSE
            ssh.execute    command=sed -i 's/0x1A0020[[:space:]]*=[[:space:]]*0/0x1A0020=1/' ${yaft_swconfig_path}
            ...    connection=${master_slave}
        END
        ${yaft_res}     ${check_log}    Install Package By Yaft   yaft_build_path=${yaft_build_path}    alias=${master_slave}    ip=${yaft_ip}
        IF   not ${yaft_res}
            ${fct_connection_issue}    Get Regexp Matches
            ...    ${check_log}    ERROR Can't connect to|ERROR Cannot establish SSH session with FCT
            ${soc_update_error}    Get Regexp Matches    ${check_log}    ERROR 'soc-update-info' returned error code
            IF    "ERROR crasign returned error" in '''${check_log}'''
                Log To Console    \nCrasign error is detected, will try YAFT again after removing crasign files
                ${remove_crasign}    ssh.execute    command=${remove_crasign_cmd};reboot    connection=gnb_${master_slave}
                ...                                 timeout=60s
                Wait Until Keyword Succeeds    4min    10s    Check If BTS Is Pingable     ip=${yaft_ip}
                ...                          Pingable_or_NotPingable=NotPingable    alias=${master_slave}
                Wait Until Keyword Succeeds    8min    10s    Check If BTS Is Pingable    ip=${yaft_ip}    alias=${master_slave}
            ELSE IF   ${fct_connection_issue}
                Log To Console    \n${master_slave} board connection issue is detected, will try YAFT again on ${master_slave} after power cycle
                ${smod_num}    Get Length     ${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units}
                Set Test Variable    ${smod_num}
                smart_recovery.Power Reset SMOD
                Run Keyword And Ignore Error    coam.teardown_admin    connection=coam_admin
                ${fct_conn_status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    5min   30s    ssh.connect_to
                ...                                                    hostname=${yaft_ip}
                ...                                                    username=toor4nsn
                ...                                                    password=oZPS0POrRieRtu
                ...                                                    proxy=${master_slave}
                ...                                                    alias=gnb_${master_slave}
                IF    ${fct_conn_status}
                    ${admin_connection}    Run Keyword And Return Status    Wait Until Keyword Succeeds    5min    15s    coam.setup_admin
                    ...                                                      bts_host=${yaft_ip}
                    ...                                                      update_interval=1000
                    ...                                                      remote_host=${hostname}
                    ...                                                      remote_host_username=${username}
                    ...                                                      remote_host_password=${password}
                    ...                                                      name=coam_admin
                    IF    ${admin_connection}
                        ${BTS_SW_Info}       Wait Until Keyword Succeeds    1min    20s    Get software info    alias=coam_admin
                        ${active_SW}         Get from dictionary    ${BTS_SW_Info}    Active SW version
                        IF    '${active_SW}'=='${yaft_build_path.split('/')[3]}'
                            Log To Console    * * * * * * * * * * * Yaft Done * * * * * * * * * * *\n
                            Log To Console    ------------------------------------------------------------------------------
                            CONTINUE
                        END
                    END
                ELSE
                    Fail    \nYAFT failed due to ${yaft_ip} cannot be connected on ${master_slave}, manually check needed!
                END
            ELSE IF    ${soc_update_error}
                Log To Console    \nthe FSP is abnormal and didn't handshake with FCT well when new build loaded,
                ...    will try YAFT again after removing soc-update-info file.
                ${remove_soc_update_file}    ssh.execute    command=rm -f /usr/bin/soc-update-info  connection=gnb_${master_slave}
                ...                                 timeout=60s
            ELSE IF    ${netboot_enabled}
                Fail    Yaft failed on ${master_slave} in netboot mode, please check the yaft output log
            END
            Log To Console   \nYAFT failed on the first attempt, will try YAFT again
            ${yaft_res}     ${check_log}    Install Package By Yaft   yaft_build_path=${yaft_build_path}
            ...    alias=${master_slave}    ip=${yaft_ip}    yaft_cmd_on_console=False
            Should Be True    ${yaft_res}
        END
        IF    not ${netboot_enabled}
            Wait Until Keyword Succeeds    5x    3min
            ...    Check SW Version After Yaft
            ...    checked_version=${nidd_basebuild}
            ...    master_slave=${master_slave}
            ...    yaft_ip=${yaft_ip}
            TRY
                Wait Until Keyword Succeeds    5x    1min
                ...    Copy swconfig from stb to active partition    master_slave=${master_slave}    yaft_ip=${yaft_ip}
            EXCEPT    AS    ${error}
                Log    \n !!!Warning!!! Update swconfig.txt failed due to ${error}    WARN
            END
        END
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    coam.teardown_admin    connection=coam_admin
    ...                   AND     Run Keyword And Ignore Error    ssh.disconnect    connection=gnb_${master_slave}

Install Package By Yaft
    [Arguments]  ${alias}    ${ip}    ${yaft_build_path}=${basebuild_path}    ${yaft_loop_check}=15    ${yaft_cmd_on_console}=True
    ${clean_param}    Set Variable If    '${alias}'=='master'    --clean_to_default${SPACE}    ${EMPTY}    # This parameter was added due to PR835275
    ${skip_dsp_link}    Set Variable If   ${airscale_fsmf} or ${fsmf_cus}    -L${SPACE}    ${EMPTY}   # This parameter was added due to PR801452
    @{yaft_grep_param}    Create List    FAILED    Permission denied    ERROR    can't open file \'/home/ute/yaft.py\'
    ${yaft_failure_pattern}    Evaluate    "|".join(${yaft_grep_param})
    ${exclude_pattern}    Set Variable    ERROR.*timed out after
    ${yaft_script}      Catenate     bash -lc ". /home/ute/taf_venv/bin/activate&& cd /home/ute/yaft/; echo oZPS0POrRieRtu | python3 yaft.py
    ...                 -i ${ip} -z ${yaft_build_path} -K ${skip_dsp_link}--NO_fpga_update
    ...                 ${clean_param}--ask_for_password" > /tmp/yaft_output_${alias}.log 2>&1
    TRY
        ssh.send_command    command=rm -rf /home/ute/yaft/log   connection=${alias}
        ssh.send_command    command=${yaft_script}    connection=${alias}
        IF    ${yaft_cmd_on_console}
            Log To Console    yaft command on ${alias} is: ${green}${yaft_script}${rm_color}
        END
        FOR    ${index}    IN RANGE    ${yaft_loop_check}
            BuiltIn.Sleep           3min
            ${console_output}=    ssh.execute    command=tail /tmp/yaft_output_${alias}.log    connection=${alias}    timeout=60s
            Log To Console    \n * * * * * * * * * * * Yaft Ongoing * * * * * * * * * * * \n\n${console_output}
            ${check_log}    ssh.execute    command=cat /tmp/yaft_output_${alias}.log | grep -a -v '${exclude_pattern}'
            ...    connection=${alias}    timeout=60s
            ${match_str}    Get Regexp Matches
            ...    ${check_log}     ${yaft_failure_pattern}
            IF     ${match_str}
                ${failed_reason}     ssh.execute
                ...    command=grep -a -B 10 -E "${yaft_failure_pattern}" /tmp/yaft_output_${alias}.log | sed 's/\x1b\[[0-9;]*m//g'
                ...    connection=${alias}    timeout=60s
                Fail    ${failed_reason}
            ELSE IF    'Flashing done' in '''${check_log}'''
                Log To Console    \n* * * * * * * * * * * Yaft Done * * * * * * * * * * *
                RETURN    True    ${check_log}
            ELSE IF    ${index}==${${yaft_loop_check}-1}
                Fail     YAFT doesn't succeed in time, please check!
            ELSE
                CONTINUE
            END
        END
    EXCEPT    AS    ${error}
        Log To Console    YAFT failed due to ${error}
        RETURN    False    ${check_log}
    END
    [Teardown]    Run Keywords    Get And Download Files    source_path=/home/ute/yaft/log/* /tmp/yaft_output*.log
    ...                                                     dest_path=${OUTPUT DIR}/Additional_Execution_Logs
    ...                                                     connection=${alias}
    ...           AND             ssh.send_command    command=rm -rf /home/ute/yaft/YAFT_IMAGE/   connection=${alias}

Get And Download Files
    [Arguments]    ${source_path}    ${dest_path}    ${connection}=None
    TRY
        FOR    ${path}    IN    @{source_path.split()}
            ${files_output}      ssh.execute    command=ls ${path}    connection=${connection}
            FOR    ${file}    IN    @{files_output.split()}
                ssh.download_file    remote_path=${file}
                ...                  local_path=${dest_path}/${file.split('/')[-1]}
                ...                  connection=${connection}
            END
        END
    EXCEPT    AS    ${error}
        Log To Console   \n -> !!!Warning!!! Download files failed due to ${error}
    END


Check SW Version After Yaft
    [Arguments]    ${checked_version}    ${master_slave}    ${yaft_ip}
    ${connected_to_bts}    Run Keyword And Return Status    Wait Until Keyword Succeeds    3min   30s    ssh.connect_to
    ...                                                     hostname=${yaft_ip}
    ...                                                     username=toor4nsn
    ...                                                     password=oZPS0POrRieRtu
    ...                                                     proxy=${master_slave}
    ...                                                     alias=gnb_${master_slave}
    IF    ${connected_to_bts}
        ${output}    ssh.execute    command=ls -l /ffs/run/ | grep 'TargetBD' | head -n 1 | awk '{print $9}'| awk -F '.' '{print $1}'
        ...                         connection=gnb_${master_slave}    timeout=30s
        @{sw_version}    Set Variable    ${output.strip('\r\n').split('_')}
        ${tmp1}    Evaluate    '_'.join(${output.split('_')[2:]}).strip()
        ${stream}    set variable if     "${sw_version[3]}" != "0000"    SBTS00    ${sw_version[1]}
        ${active_version}    Set Variable    ${stream}_${tmp1}
        IF    '${active_version}'=='${checked_version}'
            Log To Console    SW Installation Finished \n
            RETURN
        ELSE
            ${msg}  Catenate    the sw version checked under /ffs/run on ${master_slave}: ${active_version}
            ...    does not match the nidd basebuild: ${checked_version}
            Fail    ${msg}
        END
    ELSE
        Fail
        ...    msg=\n !!!Failed to connect to ${master_slave}: ${yaft_ip} after SW Installation!!! \n
    END
    [Teardown]    ssh.disconnect    connection=gnb_${master_slave}

Copy swconfig from stb to active partition
    [Documentation]    Upload swconfig file from stb to active partition
    [Arguments]    ${master_slave}    ${yaft_ip}
    Wait Until Keyword Succeeds    1min   30s    ssh.connect_to
    ...                                          hostname=${yaft_ip}
    ...                                          username=toor4nsn
    ...                                          password=oZPS0POrRieRtu
    ...                                          proxy=${master_slave}
    ...                                          alias=gnb_${master_slave}
    ${cp_swconfig}    ssh.execute    command=cp /ffs/stb/swconfig.txt /ffs/run/ && crasign /ffs/run/swconfig.txt && sleep 2
    ...                              connection=gnb_${master_slave}    timeout=60s
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=gnb_${master_slave}

SW Installation From FDSW
    [Documentation]    Author: Min Zheng
    ...                This keyword is used to perform SW installation from FDSW
    Log To Console
    ...               \n============================ Configuration Reset done - Start SW installation... =============================\n
    Run Keyword If      ${dualcore}     Perform SW Update To The Basebuild On Slave Board
    ${connected_to_fdsw_bts}    Run Keyword And Return Status    Wait Until Keyword Succeeds    8min    20s
    ...                         taf_fdsw.Connect To    ip_address=${LMP_IP}    port=443    username=Nemuadmin    password=nemuuser
    ...                         secure=True    auto_discover=True    name=fdsw
    IF    '${connected_to_fdsw_bts}'=='True'
        Log To Console    Connection to FDSW on BTS - PASSED
    ELSE
        Log    \n Connection to FDSW on BTS - FAILED \n    WARN
        Perform Yaft    ${single_board_testpc_index_map}
        RETURN
    END
    Run Keyword If    ${dualcore} or ${airscale_fsmf}
    ...               Log To Console    \n================ Perform SW update to the basebuild on master: ${nidd_basebuild} ================\n
    ...       ELSE    Log To Console    \n================ Perform SW update to the basebuild: ${nidd_basebuild} ================\n
    FOR    ${_}    IN RANGE    0    3
        ${res_bool}=    Run Keyword And Return Status    taf_fdsw.software_update    sw_slot_id=none
        ...             sw_pkg_path=${basebuild_path}    timeout=3600    activate=True    connection=fdsw    log_level=DEBUG
        Exit For Loop If    '${res_bool}'=='True'
    END
    Run Keyword If    '${res_bool}' == 'False'    Fail    \n SW Installation Failed \n
    [Teardown]    Run Keyword And Ignore Error    taf_fdsw.teardown    connection=fdsw

Perform SW Update To The Basebuild On Slave Board
    ${hostname}    Set Variable    ${tl.test_pcs[0].default_ssh_connection_details.addr}
    ${username}    Set Variable    ${tl.test_pcs[0].default_ssh_connection_details.username}
    ${password}    Set Variable    ${tl.test_pcs[0].default_ssh_connection_details.password}
    Log To Console    \n============== Perform SW update on slave board to the basebuild: ${nidd_basebuild} ==============\n
    ssh.connect to    hostname=${hostname}    username=${username}    password=${password}    alias=slave
    Wait Until Keyword Succeeds   10min  20s    Check If BTS Is Pingable    times=10    alias=slave
    ${python_cmd}     Catenate    python /home/ute/robotws/testsuite/QT/SRAN/resources/python/perform_sw_update_on_slave_board.py
    ...                           perform_sw_update_on_slave_board '${hostname}' '${username}' '${password}' '${basebuild_path}'
    Log To console    Executes command: ${python_cmd}
    FOR    ${_}    IN RANGE    0    3
        ${rc}	${sw_update_status}	   Run and Return RC and Output    ${python_cmd}
        Set Suite Variable     ${sw_update_status}
        IF    ${rc}==0
            Log To Console    \n SW Update on slave board succeeded\n
            RETURN
        END
    END
    Fail    \n SW Update on slave board failed: \n ${sw_update_status} \n

Verify SMOD And BBMOD Detection
    [Documentation]    Author: Mateusz Porzucek
    ...                Description: Verify Smod And BBmod detection.
    [Arguments]    ${bbmod_detection_time}=10
    Log To Console          \n ------------------------------------------------------------------------------
    Verify Smod Detection
    Verify BBmod Detection    bbmod_detection_time=${bbmod_detection_time}
    Should Be True          ${smod_status} and ${bbmod_status}    Verify BTS Startup Failed!!!
    [Teardown]    Log To Console    ------------------------------------------------------------------------------

Perform Commissioning For NIDD Downgrade
    [Arguments]    ${loop_check}=2
    WA for coam connect    bts_host=${LMP_IP}
    FOR    ${index}    IN RANGE    ${loop_check}
        ${commissioning}   Run Keyword And Return Status    Perform Commissioning With NIDD Check For Classical    skip_change_sync_type=True
        IF    not ${commissioning}
            ${output}    coam.get_bts_info    connection=coam_admin
            ${bts_status}    Set Variable    ${output['status']['proceduralState']}
            IF    '${bts_status}'=='Commissioned'
                Log To Console    Commissioning Finished \n
                BREAK
            ELSE IF    '${bts_status}'=='NotCommissioned'
                IF    ${index}!= ${${loop_check}-1}
                    Log To Console    BTS status is NotCommissioned, recommission will be executed \n
                    CONTINUE
                ELSE
                    Fail    \n Recommissioning still failed, BTS status is ${bts_status}, please manually check! \n
                END
            ELSE
                Fail    \n BTS status is ${bts_status}, please manually check why SCF commission failed! \n
            END
        ELSE
            Log To Console    Commissioning Finished \n
            BREAK
        END
    END

Verify RF Detection And Reach OnAir
    [Documentation]    Author: Mateusz Porzucek
    ...                Description: Check RF status, perform SW update on RU, if FID23 is visible and reach OnAir state.
    [Arguments]    ${loop_check}=4
    Log To Console     \n\tCheck RF Status...
    ${rf_loop_check}    Set Variable If    'cus' in @{UEs}    20    10
    FOR    ${index}    IN RANGE    ${loop_check}
        FOR    ${rf_check_index}    IN RANGE    ${${rf_loop_check}+1}
            ${rf_status}    Run Keyword And Return Status
            ...             Check RF Status
            IF    not ${rf_status}
                ${fault_23_status}    Check If FID23 Is Visible On RU
                IF    ${fault_23_status}
                    BREAK
                ELSE IF    ${rf_check_index} != ${rf_loop_check}
                    ${left_retries}    Evaluate    ${rf_loop_check} - ${rf_check_index}
                    Log To Console    --> RF detection failed without 23 alarm visible, will retry in 1 minute, ${left_retries} retries left...
                    BuiltIn.sleep    1min
                END
            ELSE
                BREAK
            END
        END
        ${fault_23_status}    Check If FID23 Is Visible On RU
        IF    ${fault_23_status}
            IF    ${index}!=${${loop_check}-1}
                Log To Console    \n --> FID23 (Incompatible SW version) is visible in ${${index}+1} attempt, SW Update on RU ongoing
                Retry SBTS Package Installation If BTS is Busy    sw_package=${basebuild_path}
                Verify SMOD And BBMOD Detection
            ELSE
                Fail    FID23 (Incompatible SW version) is still visible after ${index} attempts, please check manually!
            END
        ELSE
            BREAK
        END
    END
    IF    not ${rf_status}
        Run Keyword And Continue On Failure    Check RF Status    logs=${True}
        Run Keyword And Continue On Failure    Log HW Status    hw=RF
        Run Keyword And Continue On Failure    Check Unexpected Active Alarms    host=192.168.255.129
        ...                             connection=coam_admin    skip_coam_connection_setup=${True}
        Fail    RF detection failed, please check it manually!!!
    ELSE
        ${onair_res}    Run Keyword And Return Status    Check If Cell On Air
        IF    ${onair_res}
            Log To Console      \tOnAir Reached!
            Check active SW version on cOAM    AF_PATH=${basebuild_path}
        ELSE
            Run Keyword And Continue On Failure    Check Unexpected Active Alarms    host=192.168.255.129
            ...                             connection=coam_admin    skip_coam_connection_setup=${True}
            Fail    BTS does not reach OnAir!
        END
    END

Check If Cell On Air
    Log To Console     \tWait For Onair...
    Run Keyword If    'cus' in @{UEs}    Run Keywords
    ...                Reach OnAir With WTS
    ...        AND     Check If WTS Is Active
    Wait Until Keyword Succeeds    10min   30s    Verify Cells Setup

Check Errors In Syslog
    [Documentation]    Description: Teardown after 'Install Package'
    [Arguments]        @{err_patterns}
    FOR    ${pattern}    IN    @{err_patterns}
        Run Keyword If Test Failed    Run Keyword And Ignore Error    Check error message in syslog    pattern=${pattern}
    END

Permissions And Additional Check
    [Documentation]    Description: Teardown after 'Check Active Software Version'
    Check permissions for files
    Run Keyword If Test Failed    Run Keyword If    ${are_logs_checked}==${False}    Run Keyword And Ignore Error    Additional check in TC Common TS

Check VM Disc Usage
    [Documentation]     Check if the available disk space under /home on the VM is sufficient for downgrade operations.
    ...    test will be failed if the free space is less than 10G
    ${output}    RUN    timeout 30s df -h | awk '$6=="/home"{print $4}'
    IF    '${output}'!=''
        ${space_in_vm}    Evaluate    float('${output.strip("G")}') if 'G' in '${output}' else float('${output.strip("M")}') / 1024
        IF   ${space_in_vm}<10
            Fail    Free space is less than 10G under /home and yaft cannot be performed, please manually remove not used files
        END
    ELSE
        Log    The "df -h" command is stuck, so vm disc usage checking will be skipped.    WARN
    END

Check Access To WebEm
    [Arguments]  ${url}=https://192.168.255.129
    ...          ${username}=Nemuadmin
    ...          ${password}=nemuuser
    ${loop_check}    Set Variable    5
    Wait Until Keyword Succeeds    20x    30s    Check sw_version not empty
    ${version}    Fetch From Left    ${sw_version}    _
    ${selenium_lib}    Set Variable If    'FSM3' in '${sw_version}'   sbts_fsm3    sbts
    FOR    ${index}    IN RANGE    ${loop_check}
        TRY
            Log To Console    \nWebEm access attempt ${${index}+1}/${loop_check}...
            Wait Until Keyword Succeeds    3x    10s
            ...    Run Keyword    ${selenium_lib}.enable_virtual_display
            ${login}    Wait Until Keyword Succeeds    3x    20s
            ...    Run Keyword    ${selenium_lib}.login    ${url}    ${username}    ${password}
            ...    version=${version}    browser=Firefox
            Wait Until Keyword Succeeds    3x    10s
            ...    Run Keyword    ${selenium_lib}.Disable Message Box
            Wait Until Keyword Succeeds    3x    10s
            ...    Run Keyword    ${selenium_lib}.Disable Screen Lock
            BuiltIn.Sleep    15s
            ${check_if_startup_view_exist}    Wait Until Keyword Succeeds    3x    10s
            ...    Run Keyword    ${selenium_lib}.start_up_view_window_exists
            IF    ${check_if_startup_view_exist}
                Wait Until Keyword Succeeds    3x    10s
                ...    Run Keyword    ${selenium_lib}.close_start_up_view_window
            END
            ${check_software_version}    Wait Until Keyword Succeeds    3x    15s
            ...    Run Keyword    ${selenium_lib}.check_current_software_version    key=Active
            Should Be Equal    ${sw_version}    ${check_software_version}
            Log To Console    Check Access To WebEm Passed
            BREAK
        EXCEPT    AS    ${error}
            Log To Console    \nWebEm access attempt ${${index}+1} failed: ${error}
            IF    ${index}==${${loop_check}-1}
                Save Classical WebEM Screenshot    selenium_lib=${selenium_lib}
                FAIL    Failed to check access to WebEm after ${loop_check} attempts in 10 minutes,
                ...    due to ${error}! Please check it manually.
            ELSE
                Run Keyword And Ignore Error    Run Keyword    ${selenium_lib}.close_browser
                Run Keyword And Ignore Error    Run Keyword    ${selenium_lib}.disable_virtual_display
                Log To Console    \nWaiting 30 seconds before next attempt...
                BuiltIn.Sleep    30s
            END
        END
    END
    Save Classical WebEM Screenshot
    ...    log_screenshot_path_to_console=False    selenium_lib=${selenium_lib}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Run Keyword    ${selenium_lib}.close_browser
    ...                    AND    Run Keyword And Ignore Error    Run Keyword    ${selenium_lib}.disable_virtual_display

Install RF Package
    [Documentation]    Install RF software package for the specified RF name.
    ...                Calls "Install And Verify RF Software On WebUI" to perform installation and version check.
    ...                If installation or version check fails, the keyword fails with an error.
    ...                After installation, always checks RF status (with longer wait if successful) and logs hardware status.
    ...                Fails if RF status check does not pass.
    [Arguments]    ${RF_name}    ${target_version}    ${connection}=coam_admin
    TRY
        ${res_bool}    Run Keyword And Return Status    Install And Verify RF Software On WebUI
        ...                                             RF_name=${RF_name}    target_version=${target_version}    connection=${connection}
        IF    not ${res_bool}
            Fail    RF installation failed!!!
        END
    FINALLY
        ${number}    Set Variable If    ${res_bool}    10    1
        ${rf_status}    Run Keyword And Return Status    Wait Until Keyword Succeeds      ${number}x  30s    Check RF Status
        ...                                              logs=${True}
        ${rf_versions}     get_rf_versions    rf_name=${RF_name}
        Run Keyword And Ignore Error    Log HW Status    hw=RF    active_rf_sw_version=${rf_versions}
        ...    log_rf_versions_status=True
        Should Be True    ${rf_status}    Check RF status failed!!!
    END

Install And Verify RF Software On WebUI
    [Documentation]    Installs the RF software package on the site and verifies the installation result.
    ...                The keyword uploads and activates the RF software package using coam.update_software.
    ...                After installation, it checks the RF version up to ${loop_check} times, waiting 2 minutes between each check.
    ...                If all RF versions match the target version (${RF_VERSIONS_MAP}), the installation is considered successful.
    ...                If the versions do not match after all retries, the keyword fails.
    ...                This ensures the RF software is correctly installed and activated.
    [Arguments]    ${RF_name}    ${target_version}    ${loop_check}=5    ${connection}=coam_admin
    ${oran_rf_sw_package}    Set Variable    /media/builds/RF8_builds/${RF_VERSIONS_MAP['${RF_name}']}.zip
    Log To Console    \nInstalling RF SW package from path:${oran_rf_sw_package}
    coam.update_software    sw_package=${oran_rf_sw_package}    timeout=1800    connection=${connection}    should_reset_radios=True
    FOR    ${index}    IN RANGE    ${loop_check}
        BuiltIn.Sleep    2min
        ${all_versions_matched}    ${rf_versions}    Check If RF Versions Matched    ${RF_name}    ${target_version}
        ...    connection=${connection}
        IF    ${all_versions_matched}
            Log To Console    RF installation finished.
            BREAK
        ELSE IF    ${index}==${${loop_check}-1}
            Fail    RF version check failed on webem!!!
        END
    END

Check If RF Versions Matched
    [Documentation]    Checks whether RF software versions on the site match the target version retrieved from (${RF_VERSIONS_MAP}).
    ...                Retrieves RF versions for the given RF name using get_rf_versions.
    ...                Returns True if RF versions are the same as the target version; otherwise, returns False.
    ...                If no RF version is found, returns False.
    [Arguments]  ${RF_name}    ${target_version}    ${connection}=coam_admin
    ${output}    get_rf_versions    rf_name=${RF_name}    conn=${connection}
    ${rf_versions}    Evaluate    list(${output}.values())
    IF    ${{len($output)}}==0
        RETURN    False    ${EMPTY}
    END
    FOR    ${version}    IN    @{rf_versions}
        ${activate_rf_version}    Skip RF version T1 T2 Suffix Check
        ...    activate_version=${version}
        ...    target_version=${target_version}
        ${version_match}    Run Keyword And Return Status
        ...    Should Contain    ${target_version}    ${activate_rf_version.strip()}
        RETURN    ${version_match}    ${rf_versions}
    END
    RETURN    True    ${rf_versions}

Skip RF version T1 T2 Suffix Check
    [Documentation]  Skip the T1 or T2 suffix in '${activate_version}' if the length of '${activate_version}' and '${target_version}'
    ...    are not equal, otherwise use '${activate_version}' as the return value. Since there is underscore in
    ...    RF8(AXEGHA):NK.RF.SRM7.trunk_20250828.012, then replace all underscores with dots in the variable ${activate_version}
    [Arguments]    ${activate_version}    ${target_version}
    ${activate_version_length}    Get Length    ${activate_version.strip()}
    ${target_version_length}    Get Length    ${target_version.strip()}
    ${rf_sw_version_without_T1T2}    Replace String Using Regexp    ${activate_version.strip()}    T1$|T2$    ${EMPTY}
    ${activate_rf_version}    Set Variable If    ${activate_version_length}!=${target_version_length}
    ...    ${rf_sw_version_without_T1T2}    ${activate_version.strip()}
    RETURN    ${activate_rf_version.replace('_', '.')}

Save Classical WebEM Screenshot
    [Documentation]    Save screenshot from WebEm
    [Arguments]    ${screenshot_name}=${sw_version}_webem_screenshot
    ...            ${screenshot_path}=${OUTPUT_DIR}/Additional_Execution_Logs
    ...            ${log_screenshot_path_to_console}=True
    ...            ${selenium_lib}=sbts
   TRY
        Run Keyword    ${selenium_lib}.save_screenshot
        ...            ${screenshot_name}
        ...            ${screenshot_path}
        IF     ${log_screenshot_path_to_console}
            Log
            ...    Please check screenshot under ${screenshot_path} for webem functionality verification failure!!!!
            ...    WARN
        END
    EXCEPT    AS    ${error}
        Log    Failed to save webem screenshot, due to ${error}!!!    WARN
    END

Check Board Configuration
    [Arguments]    ${alias}=default
    ${dist_name}    Set Variable    /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/SMOD_L-1/BOARD_L-1/BOARD_CONFIGURATION-1
    TRY
        ${board_conf}    Wait Until Keyword Succeeds    2x    10s    coam.Get Parameters
        ...                                             ${dist_name}    timeout=120     connection=coam_admin
    EXCEPT    AS    ${error}
        ${expected_msg}    Set Variable    Provided alias (${alias}) doesn't exist
        ${alias_missing}    Run Keyword And Return Status    Should Contain    ${error}    ${expected_msg}
        IF    ${alias_missing}
            Run Keyword And Ignore Error    Check BTS Connection Status
        ${board_conf}    Wait Until Keyword Succeeds    2x    10s    coam.Get Parameters
        ...                                             ${dist_name}    timeout=120     connection=coam_admin
        ELSE
            Fail    ${error}
        END
    END
    RETURN    ${board_conf['boardConfig']}

Compare Firmware Version And Perform Downgrade If Needed
    Log To Console    \nCheck if Firmware Downgrade is necessary\n
    ${exit_code}    ${output}    ${error}    Run Fw Downgrade Script With Args    -v
    Log To Console    ${output}
    IF    'FW downgraded successfully' in '''${output}''' and ${exit_code}==0
        Log To Console   FW Downgraded successfully, no update needed\n
    ELSE IF     'mismatch between SW' in '''${output}'''
        Log To Console    Mismatch between SW, Perform FW Downgrade:\n
        ${exit_code}    ${output}    ${error}    Run Fw Downgrade Script With Args    -u
        Log To Console    ${output}
        IF    ('Perform reset for SW activation' in '''${output}''' or 'need reset' in '''${output}''') and ${exit_code}==0
            Log To Console    Perform gNB reset and check SMOD and BBMOD state:\n
            coam.Reset Site    connection=coam_admin    timeout=600
            Allow To Connect To BTS After NIDD Downgrade
            ${smod_status}     Run Keyword And Return Status    Wait Until Keyword Succeeds    10min  30s    Check Smod State
            IF    ${smod_status}
                Log To Console    Smod proceduralStatus: configured
            END
            ${bbmod_status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    10min  30s    Check BBmod State
            IF    ${bbmod_status}
                Log To Console    BBmod proceduralStatus: configured
            END
            ${exit_code}    ${output}    ${error}    Run Fw Downgrade Script With Args    -v
            Log To Console    ${output}
            IF    'FW downgraded successfully' in '''${output}''' and ${exit_code}==0
                Log To Console    Script completed successfully\n
            ELSE IF    ${exit_code}==1
                Fail    No 'FW downgraded successfully' message found, execution error: ${error}
            END
        ELSE IF    ${exit_code}==1
            Fail    Execution error: ${error}
        END
    ELSE IF    """${output}""" == ""
        Fail    Firmware Downgrade script execution error, please check logs.
    END

Perform Firmware Downgrade
    Upload FW Downgrade Scripts On Bts
    Compare Firmware Version And Perform Downgrade If Needed
