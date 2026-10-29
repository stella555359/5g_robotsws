*** Settings ***
Documentation
...    Author:          Bartlomiej Lebda | Jakub Klein
...    Maintainer:      Bartlomiej Lebda | Jakub Klein
...    Contact:         bartlomiej.lebda@nokia.com jakub.klein@nokia.com
...    Team in charge:  I_EXT_PZ_1_WRO_6_GMS
...    Description:     The following keywords are responsible for performing basic WebEM operation via CLI

Library     DateTime
Library     taf.sbts.oam.coam.admin    WITH NAME    admin_cli
Library     taf.transport.ssh          WITH NAME    ssh
Resource    ../Component_states/Component_states_resources/component_states_checker.robot
Resource    ../Connections/Connectivity_keywords.robot
Resource    ../Component_states/BasicKeywords.robot

*** Variables ***
${gNB_IP_MPLANE_LOCAL}    192.168.255.129
${gNB_MPLANE_IF_PORT}     443
${save_snapshot_path}     ${OUTPUT DIR}/Snapshot.zip
${mrbtsid}                ${tl.gnbs[0].global_bts_id}

*** Keywords ***
ADMIN CLI connection
    [Documentation]
    ...     -----------------------------------------------------------------------------------------
    ...     Common keyword to established connection with ADMIN API of tested gNB.
    ...     As arguments it takes:
    ...                            - bts_host - by default is 192.168.255.129
    ...                            - bts_port - by default is 443
    ...                            - username - by default is Nemuadmin
    ...                            - password - by default is nemuuser
    ...                            - connection - by default alias is 'default'
    ...     -----------------------------------------------------------------------------------------
    [Arguments]    ${bts_host}=${gNB_IP_MPLANE_LOCAL}    ${bts_port}=${gNB_MPLANE_IF_PORT}
    ...            ${username}=Nemuadmin  ${password}=nemuuser  ${connection}=default
    ${actual_build}=    Check build version
    admin_cli.connect_to    bts_host=${bts_host}    bts_port=${bts_port}    username=${username}
    ...                     password=${password}     name=${connection}    release=${actual_build}

ADMIN CLI disconnection
    [Documentation]
    ...     -----------------------------------------------------------------------------------------
    ...     Disconnects connection to gNB ADMIN
    ...     As argument it takes:
    ...                           - list of indicated connections to be closed. If the list is empty,
    ...                             KW closes all existing connections.
    ...     -----------------------------------------------------------------------------------------
    [Arguments]    @{connection}
    Run Keyword If    ${connection}==[]    admin_cli.Teardown_all_aliases_for_admin
    ...               ELSE                 Close Indicated Connection    ${connection}

Check OnAir after update
    [Documentation]
    ...    -----------------------------------------------------------------------------------------
    ...    Checking if BTS has reached OnAir state after sw update. Additionally KW reacts to the
    ...    occurrence of fault 23.
    ...    As arguments it takes:
    ...                           - path to sw package
    ...                           - connection - by default alias is 'default'.
    ...    -----------------------------------------------------------------------------------------
    [Arguments]    ${sw_path}        ${connection}=default
    ${alarms_list}    admin_cli.get_active_alarms      connection=${connection}
    ${alarms_list}    convert to string    ${alarms_list}
    ${is_23_active}   run keyword and return status    should contain    ${alarms_list}
    ...               Incompatible SW version detected
    run keyword if    '${is_23_active}'=='True'    Run keywords    admin_cli.update_software
    ...               sw_package=${sw_path}
    ...               should_activate=True
    ...               timeout=1200
    ...               connection=${connection}    AND
    ...               wait until keyword succeeds    900   15   Check if BTS is OnAir state   connection=${connection}
    ...    ELSE       Check if BTS is OnAir state   connection=${connection}

Check RFSW version
    [Documentation]
    ...    ----------------------------------------------------------------------------------------
    ...    Checking current RFSW version on indicated RU.
    ...    As arguments it takes:
    ...                           - RU ID - by default alias is 1.
    ...                           - connection - by default alias is 'default'.
    ...    This Kw returns RFSW version in string format.
    ...    ----------------------------------------------------------------------------------------
    [Arguments]    ${ru_id}=1    ${connection}=default
    ${position}    Set correct SMOD position in Subrack    ${connection}
    ${rmod_info}   admin_cli.get_parameters
    ...    /MRBTS-1/RAT-1/RUNTIME_VIEW-${position}/MRBTS_R-${position}/EQM_R-${position}/APEQM_R-1/RMOD_R-${ru_id}
    ...    connection=${connection}
    ${rfsw_ver}    Get From Dictionary    ${rmod_info}    activeSwVersion
    ${date}        Get Current Date
    log to console    \n---RFSW version on RMOD-${ru_id}: ${rfsw_ver} | Time: ${date}
    ${rfsw_ver}    convert to string    ${rfsw_ver}
    [Return]    ${rfsw_ver}

Close Indicated Connection
    [Documentation]
    ...     -----------------------------------------------------------------------------------------
    ...     Disconnects connection indicated by user as argument of keyword ADMIN CLI disconnection
    ...     As argument it takes:
    ...                           - Alias of the connection which to be closed.
    ...    ------------------------------------------------------------------------------------------
    [Arguments]    ${connection}
    FOR    ${connection_name}    IN    @{connection}
        admin_cli.teardown_admin    connection=${connection_name}
    END

Compare RFSW version
    [Documentation]
    ...    ----------------------------------------------------------------------------------------
    ...    Comparing actual rfsw version with indicated rfsw version.
    ...    As arguments it takes:
    ...                           - Expected result of comparing operation.
    ...                             It is possible to specify one of the two strings options 'equal' or 'not equal'
    ...                           - Rfsw version for comparing - by default is output directory.
    ...                           - RU ID - by default alias is 1.
    ...                           - Connection - by default alias is 'default'.
    ...    ----------------------------------------------------------------------------------------
    [Arguments]    ${result}    ${comp_version}    ${ru_id}=1    ${connection}=default
    ${curr_version}    Check RFSW version    ${ru_id}    ${connection}
    Run keyword if    '${result}'=='equal'        should be equal as strings        ${curr_version}    ${comp_version}
    ...    ELSE IF    '${result}'=='not equal'    should not be equal as strings    ${curr_version}    ${comp_version}
    ...    ELSE        FAIL    Wrong operation

Connection Is Available
    [Documentation]
    ...    -----------------------------------------------------------------------------------------
    ...    Keyword checks whether connection to 192.168.255.1 is available
    ...    As argument it takes:
    ...                          - connection_name - as default it takes alias from created in kw "Reboot LTE" connection to LTE VM
    ...    -----------------------------------------------------------------------------------------
    [Arguments]    ${connection_name}=vm
    ${output_message}=    ssh.Execute    ping -c 1 192.168.255.1    connection=${connection_name}
    ${output_message}=    Get Line    ${output_message}    -2
    Should Be Equal As Strings    ${output_message}    1 packets transmitted, 1 received, 0% packet loss, time 0ms

Get number of Radio Units
    [Documentation]
    ...    -----------------------------------------------------------------------------------------
    ...    Checks and return the number of available radio modules.
    ...    As argument it takes:
    ...                          - connection - by default alias is 'default'.
    ...    -----------------------------------------------------------------------------------------
    [Arguments]        ${connection}=default
    ${bts_info}        admin_cli.get_bts_info    connection=${connection}
    ${number_of_ru}    Get Length   ${bts_info["radioModules"]["rmod"]}
    [Return]           ${number_of_ru}

Get RU IP from Info Model
    [Documentation]
    ...     -----------------------------------------------------------------------------------------
    ...     Getting RMOD IP address from the RMOD_L object in info_model view.
    ...     As arguments it takes:
    ...                            - ru_id - RU ID from info_model view(object _L). By default is '1'
    ...                            - connection - by default alias is 'default'
    ...     This KW returns:
    ...                            - RU IP Address.
    ...     -----------------------------------------------------------------------------------------
    [Arguments]    ${ru_id}=1    ${connection}=default
    ${position}         Set correct SMOD position in Subrack    ${connection}
    ${ru_path}          set variable    /MRBTS-1/RAT-1/BTS_L-${position}/EQM_L-1/RMOD_L-${ru_id}
    ${ru_parameters}    admin_cli.get_parameters    ${ru_path}    connection=${connection}
    ${ru_ip}            get from dictionary         ${ru_parameters}    ipAddress
    should not be equal as strings    ${ru_ip}    0.0.0.0
    [Return]    ${ru_ip}

Lock Cell
    [Documentation]
    ...    -----------------------------------------------------------------------------------------
    ...    Locks the indicated cell and verify if after operation, cell status is correct.
    ...    As arguments it takes:
    ...                           - cell id from info_model view.
    ...                           - timeout - by default is 60s
    ...                           - connection - by default alias is 'default'.
    ...    -----------------------------------------------------------------------------------------
    [Arguments]    ${cell_nr}    ${timeout}=60    ${connection}=default
    ${num}          Set correct SMOD position in Subrack    ${connection}
    ${cell_path}    set variable
    ...             /MRBTS-1/RAT-1/RUNTIME_VIEW-${num}/MRBTS_R-${num}/NRBTS_R-${mrbtsid}/NRCELL_R-${cell_nr}
    log to console         \n---START Locking NRCELL_R-${cell_nr}
    admin_cli.lock    dist_name=${cell_path}    timeout=${timeout}    connection=${connection}
    ${lock_status}    Create dictionary         administrativeState=Locked
    wait until keyword succeeds    20s    1s    Check specific status on selected component
    ...                                         NRCELL_R-${cell_nr}     ${lock_status}    connection=${connection}
    log to console         \n---NRCELL_R-${cell_nr} is Locked

Lock RU
    [Documentation]
    ...    -----------------------------------------------------------------------------------------
    ...    Locks the indicated radio module and verify if after operation, RMOD status is correct.
    ...    As arguments it takes:
    ...                           - RMOD id from info_model view.
    ...                           - Timeout - by default is 60s
    ...                           - Connection - by default alias is 'default'.
    ...    -----------------------------------------------------------------------------------------
    [Arguments]    ${ru_nr}    ${timeout}=60    ${connection}=default
    ${num}          Set correct SMOD position in Subrack    ${connection}
    ${ru_path}      set variable
    ...             /MRBTS-1/RAT-1/RUNTIME_VIEW-${num}/MRBTS_R-${num}/EQM_R-${num}/APEQM_R-1/RMOD_R-${ru_nr}
    log to console         \n---START Locking RMOD_R-${ru_nr}
    admin_cli.lock      dist_name=${ru_path}    timeout=${timeout}    connection=${connection}
    ${lock_status}      Create dictionary       administrativeState=Locked
    wait until keyword succeeds    20s    1s    Check specific status on selected component
    ...                                         RMOD_R-${ru_nr}     ${lock_status}    connection=${connection}
    log to console         \n---RMOD_R-${ru_nr} is Locked

Perform sw update and wait for OnAir
    [Documentation]
    ...    -----------------------------------------------------------------------------------------
    ...    Performing sw update and waiting for OnAir state on new software version.
    ...    As arguments it takes:
    ...                           - Path to sw package
    ...                           - Timeout for update in sec - by default is 1200 sec
    ...                           - gNB ip address to verify connection after update - by default is 192.168.255.1
    ...                           - Connection - by default alias is 'default'.
    ...    -----------------------------------------------------------------------------------------
    [Arguments]    ${sw_path}    ${timeout}=1200    ${smod_ip}=192.168.255.1    ${connection}=default
    ${sw_before_update}    admin_cli.get_sw_version    connection=${connection}
    log to console    \n---START sw update with package: ${sw_path}
    admin_cli.update_software     sw_package=${sw_path}     should_activate=True
    ...                           timeout=${timeout}     connection=${connection}
    log to console    \n---Update DONE. START checking env after update
    Wait Until Keyword Succeeds    100    5     Check if eNB is not pingable    ${smod_ip}
    Wait Until Keyword Succeeds    500    10    Check if eNB is pingable        ${smod_ip}
    wait until keyword succeeds    600    5     Check If proceduralState Of gNB Is Configured Or OnAir    ${connection}
    ${sw_after_update}    admin_cli.get_sw_version    connection=${connection}
    should not be equal as strings    ${sw_before_update}    ${sw_after_update}
    wait until keyword succeeds    600    15    Check OnAir after update    ${sw_path}    ${smod_ip}    ${connection}
    log to console     \n---Checking after update DONE. Current sw: ${sw_after_update}

Prepare T1 SW version for update
    [Documentation]
    ...    ----------------------------------------------------------------------------------------
    ...    Preparing and downloading standard sw_package and T1 sw_package for current sw version.
    ...    As arguments it takes:
    ...                           - path to save new packages - by default is output directory.
    ...                           - connection - by default alias is 'default'.
    ...    This KW returns two paths to software packages: standard version and T1 version, in .zip format.
    ...    ----------------------------------------------------------------------------------------
    [Arguments]    ${dest_path}=${OUTPUT_DIR}        ${connection}=default
    log to console    \n---START preparing T1 sw version
    ${curr_ver}    admin_cli.get_sw_version    connection=${connection}
    ${sw_rel}      Get Regexp Matches    ${curr_ver}    [^_]*
    ${is_trunk}    Run keyword and return status    Should Contain  ${curr_ver}    9999
    ${sw_rel}      Run Keyword if   '${is_trunk}' == 'True'   Set Variable    SBTS00_ENB
    ...            ELSE   Set Variable   ${sw_rel[0]}
    ${curr_ver}    Run Keyword if   '${is_trunk}' == 'True'
    ...            Replace String Using Regexp  ${curr_ver}  ^.*?_  SBTS00_
    ...            ELSE  Set Variable  ${curr_ver}
    ${path_completion}    set variable    _release_BTSSM_downloadable
    Run    sudo wget ${rdnet_link}${curr_ver}/${curr_ver}${path_completion}_testpackage_T1.zip -nv -P ${dest_path}
    Run    sudo wget ${rdnet_link}${curr_ver}/${curr_ver}${path_completion}.zip -nv -P ${dest_path}
    ${curr_sw}    set variable    ${dest_path}/${curr_ver}${path_completion}.zip
    ${t1_sw}      set variable    ${dest_path}/${curr_ver}${path_completion}_testpackage_T1.zip
    log to console    \n---Preparing sw version DONE. T1 SW version location: ${t1_sw}
    [Return]    ${curr_sw}    ${t1_sw}

Reboot LTE
    [Documentation]
    ...    -----------------------------------------------------------------------------------------
    ...    Keyword creates conection to LTE, perform reboot and wait 3 mins until connection to 192.168.255.1 is available.
    ...    As argument it takes:
    ...                          - LTE_vm_ip - ip of LTE VM
    ...    -----------------------------------------------------------------------------------------
    [Arguments]    ${LTE_vm_ip}
    ssh.Connect To    hostname=${LTE_vm_ip}    username=ute    alias=vm
    ssh.Connect To    hostname=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    proxy=vm    alias=bts
    ssh.Execute    command=reboot    connection=bts
    Sleep    10s
    Wait Until Keyword Succeeds    3m    5    Connection Is Available

Reset RU and check OnAir
    [Documentation]
    ...    -----------------------------------------------------------------------------------------
    ...    Resets the indicated radio module and verify if after operation, all BTS statuses are correct.
    ...    As arguments it takes:
    ...                           - RU id from info_model view.
    ...                           - Reset type - It is possible to specify one of the three strings options
    ...                             'Soft', 'Hard' or 'Warm'. By default type is 'Soft'.
    ...                           - Force reset - It is possible to specify one of the two boolean options
    ...                             True or False. By default is True
    ...                           - Timeout - by default is 300s
    ...                           - Connection - by default alias is 'default'.
    ...    -----------------------------------------------------------------------------------------
    [Arguments]    ${ru_id}    ${reset_type}=Soft    ${force}=${TRUE}    ${timeout}=300    ${connection}=default
    ${num}    Set correct SMOD position in Subrack    ${connection}
    ${ru_path}     set variable
    ...            /MRBTS-1/RAT-1/RUNTIME_VIEW-${num}/MRBTS_R-${num}/EQM_R-${num}/APEQM_R-1/RMOD_R-${ru_id}
    admin_cli.reset_unit        dist_name=${ru_path}
    ...                         reset_type=${reset_type}
    ...                         force_radio_reset=${force}
    ...                         timeout=${timeout}
    ...                         connection=${connection}
    wait until keyword succeeds  15 min    10 s   Check if BTS is OnAir state    connection=${connection}

Set correct SMOD position in Subrack
    [Documentation]
    ...    -----------------------------------------------------------------------------------------
    ...    Check current SMOD position in subrack. Depending on the position side,
    ...    KW returns the value 1 for the left side, and the value 4 for the right side.
    ...    As argument it takes:
    ...                          - Connection - by default alias is 'default'.
    ...    -----------------------------------------------------------------------------------------
    [Arguments]    ${connection}=default
    ${smodPosition}    admin_cli.get_smod_position    connection=${connection}
    ${positionNumber}=    set variable if
    ...    'left' == '${smodPosition}'    1
    ...    'right' == '${smodPosition}'    4
    [Return]    ${positionNumber}

Unlock Cell
    [Documentation]
    ...    -----------------------------------------------------------------------------------------
    ...    Unlocks the indicated cell and verify if after operation, cell status is correct.
    ...    As arguments it takes:
    ...                           - Cell id from info_model view.
    ...                           - Timeout - by default is 60s
    ...                           - Connection - by default alias is 'default'.
    ...    -----------------------------------------------------------------------------------------
    [Arguments]    ${cell_nr}    ${timeout}=60    ${connection}=default
    ${num}          Set correct SMOD position in Subrack    ${connection}
    ${cell_path}    set variable
    ...             /MRBTS-1/RAT-1/RUNTIME_VIEW-${num}/MRBTS_R-${num}/NRBTS_R-${mrbtsid}/NRCELL_R-${cell_nr}
    log to console         \n---START Unlocking NRCELL_R-${cell_nr}
    admin_cli.unlock    dist_name=${cell_path}    timeout=${timeout}    connection=${connection}
    ${unlock_status}    Create dictionary         administrativeState=Unlocked
    wait until keyword succeeds    20s    1s    Check specific status on selected component
    ...                                         NRCELL_R-${cell_nr}     ${unlock_status}    connection=${connection}
    log to console         \n---NRCELL_R-${cell_nr} is Unlocked

Unlock RU
    [Documentation]
    ...    -----------------------------------------------------------------------------------------
    ...    Unlocks the indicated radio module and verify if after operation, RMOD status is correct.
    ...    As arguments it takes:
    ...                           - RMOD id from info_model view.
    ...                           - Timeout - by default is 60s
    ...                           - Connection - by default alias is 'default'.
    ...    -----------------------------------------------------------------------------------------
    [Arguments]    ${ru_nr}    ${timeout}=60    ${connection}=default
    ${num}          Set correct SMOD position in Subrack    ${connection}
    ${ru_path}      set variable
    ...             /MRBTS-1/RAT-1/RUNTIME_VIEW-${num}/MRBTS_R-${num}/EQM_R-${num}/APEQM_R-1/RMOD_R-${ru_nr}
    log to console         \n---START Unlocking RMOD_R-${ru_nr}
    admin_cli.unlock      dist_name=${ru_path}    timeout=${timeout}    connection=${connection}
    ${unlock_status}      Create dictionary       administrativeState=Unlocked
    wait until keyword succeeds    20s    1s    Check specific status on selected component
    ...                                         RMOD_R-${ru_nr}     ${unlock_status}    connection=${connection}
    log to console         \n---RMOD_R-${ru_nr} is Unlocked

Check build version
    Connect Ssh To Asix
    ${hash_build}=    ssh.execute    ls /ffs/run | grep HashContainerSignature.*.p7   connection=asik
    ${hash_build}=    remove string    ${hash_build}    HashContainerSignature_
    ${hash_build}=    fetch from left    ${hash_build}    _
    [Teardown]    Disconnect Ssh From Asix
    [Return]    ${hash_build}
