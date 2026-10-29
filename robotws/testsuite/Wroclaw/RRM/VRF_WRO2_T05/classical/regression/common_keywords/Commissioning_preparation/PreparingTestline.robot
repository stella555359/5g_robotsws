*** Settings ***
Documentation
...     Author: Bartlomiej Lebda    |    Contact: bartlomiej.lebda@nokia.com
...     These keywords are designed to prepare TLs commissioning before testing and to check TLs health after testing.
...     The target platform for these keywords is no commissioning TLs, only with uploaded software.
...     Preparation of preconditions is related to carrying out the correct commissioning and its validation,
...     checking unexpected alarms and bringing to OnAir state without using the Custom commissioning mechanism.
...     Postconditions preparation involves checking the TLs status after performing the tests
...     and performing simple corrective actions in the event of potential errors after testing.

Resource   ../ConnectivityKeywords.robot
Resource   ../admin/BasicKeywords.robot
Resource   ../admin/component_states_verification/OnAirCheckers/CheckOnAir.robot
Resource   ../common_keywords.robot
Library    OperatingSystem
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.collectors.core   WITH NAME   core
Library    taf.sbts.oam.coam.admin     WITH NAME     admin_cli
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.hw.pdu    WITH NAME    pdu
Library    ../tl_configuration.py    WITH NAME    tl_conf
Library    PreparingTestline.py    WITH NAME    pt
#Library    resources.py
Variables   variables.py

*** Variables ***
${MRBTS_ID}=    ${tl.gnbs[0].instance_id}
${comm_timer}=    15 min
${token}      cmVmdGtuOjAxOjE4Mzc0MjkyOTM6cUM1R0w2aGhwN3VpZTFnZnFSWFk2cXRjeEpB

*** Keywords ***
Prepare and check TL
    [Tags]      WIP
    Add btslog flag
    PreparingTestline.Start Btslog
    ADMIN CLI connection
    Log libraries
    wait until keyword succeeds  10 min    20 sec   Check SMOD and BBMOD
    ${TLstate}=    run keyword and return status    gNB in onAir state
    run keyword if   ${TLstate} == ${False}     Perform correct commissioning
    Check unwanted alarms list
    Stop and fix when critical fid
    Check cells_status
    [Teardown]    Run keywords
    ...           Remove temp sw dir  AND
    ...           Collect suite snapshot     AND
    ...           ADMIN CLI disconnection  AND
    ...           PreparingTestline.Stop Btslog

Prepare and check neightbour TL
    [Arguments]    ${tl_name}  ${scf_resource_path}  ${folder_name}  ${scf_name}
    [Tags]      WIP
    Log to console  Prepare and check ${tl_name}
    # Add btslog flag
    ${remote_config}=  tl_conf.import_selected_testline_configuration_file  ${tl_name}
    ${remote_host}=  Set variable  ${remote_config.test_pc.default_ssh_connection_details.addr}
    ${remote_mplane}=  Set variable  ${remote_config.gnbs[0].cu.backhaul_site_oam_ip.v4}
    PreparingTestline.Start Remote Btslog  ${remote_config}  ${tl_name}
    ADMIN CLI remote connection  remote_host=${remote_host}
    wait until keyword succeeds  10 min    20 sec   Check SMOD and BBMOD  remote_admin1
    Set suite variable    ${gNB_IP_MPLANE_LOCAL}    192.168.255.129
    ${local_sw_stream}  ${local_sw_version}=  Get local SW info
    ${sw_stream}    admin_cli.Get sw release name  connection=remote_admin1
    ${sw_version}    admin_cli.Get sw version  connection=remote_admin1

    ${should_downgrade}=  Set Variable If  '${local_sw_stream}' < '${sw_stream}'  ${True}  ${False}
    Log to console  Should downgrade - ${should_downgrade} Local branch: ${local_sw_stream}, ${tl_name}: ${sw_stream}
    run keyword if   ${should_downgrade}
    ...    Prepare TL with downgrade
    ...    ${tl_name}  ${local_sw_version}  ${sw_version}  ${remote_mplane}  ${remote_host}
    ...    ${scf_resource_path}  ${folder_name}  ${scf_name}  connection=remote_admin1
    ...    ELSE
    ...    Prepare TL  ${tl_name}  ${local_sw_version}  ${sw_version}  ${remote_host}
    ...    ${scf_resource_path}  ${folder_name}  ${scf_name}  connection=remote_admin1

    Check unwanted alarms list  connection=remote_admin1
    # Stop and fix when critical fid neightbour
    Check cells_status  connection=remote_admin1

    [Teardown]    Run keywords
    ...           pt.delete_local_sw_dir  AND
    # ...           Collect neightbour suite snapshot  tl_name=${tl_name}  connection=remote_admin  AND
    ...           ADMIN CLI disconnection  connection=remote_admin1  AND
    ...           PreparingTestline.Stop Remote Btslog  ${tl_name}

Prepare TL with downgrade
    [Arguments]  ${tl_name}  ${local_sw_version}  ${sw_version}  ${remote_mplane}  ${remote_host}
    ...    ${scf_resource_path}  ${folder_name}  ${scf_name}  ${connection}=default
    Log to console  Delete config and reset site
    pt.delete_config  ${remote_mplane}
    gNB Site Reset  connection=${connection}
    wait until keyword succeeds  10 min    20 sec   Check SMOD and BBMOD  ${connection}
    Load correct sw  ${tl_name}  ${local_sw_version}  ${sw_version}  connection=${connection}
    wait until keyword succeeds  10 min    10 sec  Reconnect ADMIN CLI remote connection  remote_host=${remote_host}    connection=${connection}
    wait until keyword succeeds  30 min    20 sec   Check SMOD and BBMOD  ${connection}
    Load scf for neightbour NR  ${scf_resource_path}  ${folder_name}  ${scf_name}  ${connection}
    wait until keyword succeeds  30 min    20 sec   Check SMOD and BBMOD  ${connection}
    Verify neightbour gNB onAir  ${local_sw_version}  connection=${connection}

Prepare TL
    [Arguments]  ${tl_name}  ${local_sw_version}  ${sw_version}  ${remote_host}
    ...    ${scf_resource_path}  ${folder_name}  ${scf_name}  ${connection}=default
    Load correct sw  ${tl_name}  ${local_sw_version}  ${sw_version}  connection=${connection}
    wait until keyword succeeds  10 min    10 sec  Reconnect ADMIN CLI remote connection  remote_host=${remote_host}    connection=${connection}
    wait until keyword succeeds  30 min    20 sec   Check SMOD and BBMOD   ${connection}
    Verify neightbour gNB onAir  ${sw_version}  connection=${connection}
    Check cells_status  connection=${connection}
    Load scf for neightbour NR  ${scf_resource_path}  ${folder_name}  ${scf_name}  ${connection}
    wait until keyword succeeds  30 min    20 sec   Check SMOD and BBMOD  ${connection}
    Verify neightbour gNB onAir  ${local_sw_version}  connection=${connection}

Verify neightbour gNB onAir
    [Arguments]  ${sw_version}  ${connection}=default
    ${more_time_needed}=    run keyword and return status    variable should exist    ${AZQL}
    run keyword if    '${more_time_needed}'=='True'    set suite variable    ${comm_timer}    30 min
    ${OnAir_State_Reached}=    run keyword and return status    wait until keyword succeeds  ${comm_timer}    20 sec
    ...    Check neightbour gNB status  ${sw_version}  connection=${connection}
    run keyword if    '${OnAir_State_Reached}'=='False'    Reset site if OnAir cannot be reached  connection=${connection}
    run keyword if    '${OnAir_State_Reached}'=='False'    FAIL    OnAir status cannot be achieved

Load correct sw
    [Arguments]  ${tl_name}  ${local_sw_version}  ${sw_version}  ${connection}=default
    ${is_newer_sw}=  Set Variable If  '${local_sw_version}' != '${sw_version}'  ${True}  ${False}
    Log to console  Should load SW - ${is_newer_sw} Local SW: ${local_sw_version}, ${tl_name}: ${sw_version}
    run keyword if   ${is_newer_sw}     Upgrade to correct sw  sw_version=${local_sw_version}  connection=${connection}

Upgrade to correct sw from burak
    [Arguments]  ${sw_version}  ${connection}=default
    Log to console  Trying load correct sw
    pt.mount_sw_dir
    ${sw_path}=  pt.download_package  ${sw_version}
    admin.update_software  sw_package=${sw_path}  timeout=3600  connection=${connection}

Upgrade to correct sw
    [Arguments]  ${sw_version}  ${connection}=default
    Log to console  Trying load correct sw
    pt.create_local_sw_dir
    ${sw_path}=  pt.download_package  ${sw_version}  burak=${False}
    admin.update_software  sw_package=${sw_path}  timeout=3600  connection=${connection}

Get local SW info
    ADMIN CLI connection
    ${sw_stream}    admin_cli.Get sw release name
    ${sw_version}    admin_cli.Get sw version
    [Return]  ${sw_stream}  ${sw_version}
    [Teardown]    Run keyword
    ...           ADMIN CLI disconnection

Log libraries
    ${output}    Run     pip freeze
    Log  ${output}

Prepare and check TL multirat
    [Tags]      WIP
    Add btslog flag
    PreparingTestline.Start Btslog
    ADMIN CLI connection
    Log libraries
    wait until keyword succeeds  10 min    20 sec   Check SMOD and BBMOD
    ${TLstate}=    run keyword and return status    gNB in onAir state
    run keyword if   ${TLstate} == 'False'     Perform correct commissioning
    Check unwanted alarms list
    Stop and fix when critical fid
    Check cells_status multirat
    [Teardown]    Run keywords
    ...           Collect suite snapshot     AND
    ...           ADMIN CLI disconnection    AND
    ...           PreparingTestline.Stop Btslog

Check unwanted alarms
    [Tags]      WIP
    [Arguments]  ${connection}=default
    ${active_alarms}    admin_cli.get_active_alarms    timeout=60  connection=${connection}
    ${alarm_id_list}    Create List
    ${len}    get length    ${active_alarms}
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    log    ${alarm_id_list}
    [Return]     ${alarm_id_list}

Get branch SCF file path
    [Arguments]    ${sw_stream}  ${tl_name}
    ${testline_configuration_tl_name}=  Replace String  ${tl_name}  -  _
    ${robotws_branch_path}=    Set Variable    commissionings/RRM/WRO_5/${tl_name}_${sw_stream}/${tl_name}_${sw_stream}.xml
    ${testline_configuration_branch_path}=    Set Variable
    ...    /home/ute/testline_configuration/${testline_configuration_tl_name}/SCFs/${tl_name}_${sw_stream}/${tl_name}_${sw_stream}.xml
    ${file_exists}=  Run Keyword And Return Status  OperatingSystem.File Should Exist    ${robotws_branch_path}
    ${scf_file_path}=    Run Keyword If    '${file_exists}' == 'True'    Set Variable    ${robotws_branch_path}
    ...    ELSE
    ...    Set Variable    ${testline_configuration_branch_path}
    [Return]  ${scf_file_path}

Get trunk SCF file path
    [Arguments]    ${tl_name}
    ${testline_configuration_tl_name}=  Replace String  ${tl_name}  -  _
    ${robotws_trunk_path}=    Set Variable    commissionings/RRM/WRO_5/${tl_name}_trunk/${tl_name}_trunk.xml
    ${testline_configuration_trunk_path}=    Set Variable
    ...    /home/ute/testline_configuration/${testline_configuration_tl_name}/SCFs/${tl_name}_trunk/${tl_name}_trunk.xml
    ${file_exists}=  Run Keyword And Return Status  OperatingSystem.File Should Exist    ${robotws_trunk_path}
    ${scf_file_path}=    Run Keyword If    '${file_exists}' == 'True'    Set Variable    ${robotws_trunk_path}
    ...    ELSE
    ...    Set Variable    ${testline_configuration_trunk_path}
    [Return]  ${scf_file_path}

Get correct SCF file path
    ${sw_stream}    admin_cli.Get sw release name
    ${tl_name}      Get TL hostname
    ${branches}=    Create List  SBTS24R3  SBTS25R1  SBTS25R2  SBTS25R3  SBTS26R1  SBTS26R2
    ${scf_path}=  Run Keyword If  '${sw_stream}' in ${branches}
    ...    Get branch SCF file path  ${sw_stream}  ${tl_name}
    ...    ELSE
    ...    Get trunk SCF file path  ${tl_name}
    [Return]     ${scf_path}

Perform correct commissioning
    [Tags]      WIP
    ${scf_path}=  Get correct SCF file path
    Commission with scf file    ${scf_path}    is_pdl_checking_needed=${True}
    set suite variable    ${bts_is_ready}    False
    ${more_time_needed}=    run keyword and return status    variable should exist    ${AZQL}
    run keyword if    '${more_time_needed}'=='True'    set suite variable    ${comm_timer}    30 min
    ${OnAir_State_Reached}=    run keyword and return status    wait until keyword succeeds  ${comm_timer}    1 sec    Check gNB status after Commm
    run keyword if    '${OnAir_State_Reached}'=='False'    Reset site if OnAir cannot be reached
    run keyword if    '${OnAir_State_Reached}'=='False'    FAIL    OnAir status cannot be achieved

Check SMOD and BBMOD
    [Arguments]    ${connection}=default
    Check SMOD  connection=${connection}
    Check BBMOD  connection=${connection}

Check SMOD
    [Arguments]    ${connection}=default
    ${bts_info}=  admin_cli.get_fsm_info  connection=${connection}
    ${sw_stream}    admin_cli.Get sw release name  connection=${connection}
    Log  ${sw_stream}
    set suite variable    ${SMOD_status}    valid
    FOR    ${SMOD}    IN    @{bts_info}
        set suite variable    ${operationalState}    ${SMOD["status"]["operationalState"]}
        set suite variable    ${availabilityStatus}    None
        Run keyword if  '${operationalState}'!='enabled'   set suite variable    ${SMOD_status}    invalid
    END
    should be equal as strings  ${SMOD_status}    valid

Check BBMOD
    [Arguments]    ${connection}=default
    ${bts_info}=  admin_cli.get_fbb_info  connection=${connection}
    ${sw_stream}    admin_cli.Get sw release name  connection=${connection}
    Log  ${sw_stream}
    set suite variable    ${BBMOD_status}    valid
    FOR    ${BBMOD}    IN    @{bts_info}
        set suite variable    ${operationalState}    ${BBMOD["status"]["operationalState"]}
        set suite variable    ${availabilityStatus}    None
        Run keyword if  '${operationalState}'!='enabled'   set suite variable    ${BBMOD_status}    invalid
    END
    should be equal as strings  ${BBMOD_status}    valid

Check gNB status after Commm
    [Arguments]    ${connection}=default
    [Documentation]    This keywords will check: OnAir state, error 23 and 10.
    ${onAir_state}=    run keyword and return status    gNB in onAir state  connection=${connection}
    run keyword if    '${onAir_state}'=='True'    return from keyword
    ${alarm_list_actual}=    Check unwanted alarms   connection=${connection}
    ${is_23_active}=    run keyword and return status    Check if alarm exist    ${alarm_list_actual}    23
    run keyword if    '${is_23_active}'=='True'    Perform_update   connection=${connection}
    Stop and fix when critical fid
    # ${is_10_active}=    run keyword and return status    Check if alarm exist    ${alarm_list_actual}    10
    # run keyword if    '${is_10_active}'=='True'    Check PDU and set RU power reset
    ${onAir_state_after_check}=    run keyword and return status    gNB in onAir state  connection=${connection}
    run keyword if    '${onAir_state_after_check}'=='True'    return from keyword
    FAIL    No onAir state

Check neightbour gNB status
    [Arguments]    ${sw_version}  ${connection}=default
    ${onAir_state}=    run keyword and return status    gNB in onAir state  connection=${connection}
    run keyword if    '${onAir_state}'=='True'    return from keyword
    ${alarm_list_actual}=    Check unwanted alarms  connection=${connection}
    ${rdmod_info}=  admin_cli.get_frm  connection=${connection}
    Log  ${rdmod_info}
    ${is_23_active}=    run keyword and return status    Check if alarm exist    ${alarm_list_actual}    23
    run keyword if    '${is_23_active}'=='True'    wait until keyword succeeds  10 min    20 sec  Wait for RMODs when FID23  connection=${connection}
    run keyword if    '${is_23_active}'=='True'    Upgrade to correct sw  ${sw_version}  connection=${connection}
    Stop and fix when critical fid neightbour
    # ${is_10_active}=    run keyword and return status    Check if alarm exist    ${alarm_list_actual}    10
    # run keyword if    '${is_10_active}'=='True'    Check PDU and set RU power reset
    ${onAir_state_after_check}=    run keyword and return status    gNB in onAir state  connection=${connection}
    run keyword if    '${onAir_state_after_check}'=='True'    return from keyword
    FAIL    No onAir state

Wait for RMODs when FID23
    [Arguments]  ${connection}=default
    ${RU_info}=  admin_cli.get_frm  connection=${connection}
    ${list_of_disabled_RUs}=    Create list
    FOR     ${RU}    IN    @{RU_info}
        set suite variable    ${is_rmod_available}    ${False}
        set suite variable    ${RU_number}    ${RU["id"]["configuration"]}
        ${RU_number}=    Fetch from right    ${RU_number}    /
        set suite variable    ${proceduralStatus}    ${RU["status"]["proceduralStatus"]}
        run keyword if    '${proceduralStatus}'=='configured' or '${proceduralStatus}'=='initializing'
        ...    set suite variable    ${is_rmod_available}    ${True}
        run keyword if    '${is_rmod_available}'=='${False}'    append to list    ${list_of_disabled_RUs}    ${RU_number}
    END
    should be empty    ${list_of_disabled_RUs}

Check if alarm exist
    [Arguments]    ${alarm_list}    ${alarm_id}
    set suite variable    ${is_alarm_visible}    False
    FOR    ${element}    IN    @{alarm_list}
        run keyword if    '${element}'=='${alarm_id}'    set suite variable   ${is_alarm_visible}     True
    END
    run keyword if     '${is_alarm_visible}'=='False'    FAIL

Perform_update
    [Arguments]    ${connection}=default    ${on_air_check}=True    ${dir}=${OUTPUT_DIR}/temp_sw_dir
    Log to console    Beginning update process
    ${SW_Version}=      admin_cli.get_sw_version    connection=${connection}
    # ${SMOD_version}=    Get SMOD version
    ${actual_SW}=       Get Current Soft version    connection=${connection}
    ${is_Common}=    Run keyword and return status    Should Contain    ${actual_SW}    SBTS
    ${is_Trunk}=     Run keyword and return status    Should Contain    ${actual_SW}    9999
    ${is_24R3}=      Run keyword and return status    Should Contain    ${actual_SW}    SBTS24R3
    ${is_25R1}=      Run keyword and return status    Should Contain    ${actual_SW}    SBTS25R1
    ${is_25R2}=      Run keyword and return status    Should Contain    ${actual_SW}    SBTS25R2
    ${is_25R3}=      Run keyword and return status    Should Contain    ${actual_SW}    SBTS25R3
    ${is_26R1}=      Run keyword and return status    Should Contain    ${actual_SW}    SBTS26R1
    ${is_26R2}=      Run keyword and return status    Should Contain    ${actual_SW}    SBTS26R2
    ${Downloaded_SW}=   Run keyword if
    ...    ${is_Common}==True and ${is_Trunk}==True
    ...    Download Software  SBTS00  ${SW_Version}    dir=${dir}
    ...    ELSE IF  ${is_Common}==True and ${is_24R3}==True
    ...    Download Software  SBTS24R3  ${SW_Version}    dir=${dir}
    ...    ELSE IF  ${is_Common}==True and ${is_25R1}==True
    ...    Download Software  SBTS25R1  ${SW_Version}    dir=${dir}
    ...    ELSE IF  ${is_Common}==True and ${is_25R2}==True
    ...    Download Software  SBTS25R2  ${SW_Version}    dir=${dir}
    ...    ELSE IF  ${is_Common}==True and ${is_25R3}==True
    ...    Download Software  SBTS25R3  ${SW_Version}    dir=${dir}
    ...    ELSE IF  ${is_Common}==True and ${is_26R1}==True
    ...    Download Software  SBTS26R1  ${SW_Version}    dir=${dir}
    ...    ELSE IF  ${is_Common}==True and ${is_26R2}==True
    ...    Download Software  SBTS26R2  ${SW_Version}    dir=${dir}
    ...    ELSE     Download Soft           ${actual_SW}    dir=${dir}
    wait until keyword succeeds   30min   2min  Perform Soft Update   ${Downloaded_SW}  connection=${connection}  dir=${dir}
    run keyword if    '${comm_timer}'=='30 min'    set suite variable    ${timer_after_update}    35 min
    ...    ELSE     set suite variable    ${timer_after_update}    30 min
    IF    ${on_air_check} == True
        wait until keyword succeeds  ${timer_after_update}    1 min    gNB in onAir state    connection=${connection}
    END


Perform update with burak
    Log to console    Beginning update process with Burak sw
    ${sw_version}=      admin_cli.get_sw_version
    Log to console    Sw selected for update: ${sw_version}
    wait until keyword succeeds   30 min    2 min  Upgrade to correct sw from burak     ${sw_version}
    wait until keyword succeeds    30 min   1 min    gNB in onAir state

Get Current Soft version
    [Arguments]    ${connection}=default
    ${SW}=              admin_cli.get_sw_version    connection=${connection}
    ${SW1}=             Replace String      ${SW}       _00000    .
    ${SW2}=             Replace String      ${SW1}      _0000    .
    ${SW3}=             Replace String      ${SW2}      _000     .
    ${SW4}=             Replace String      ${SW3}      _00     .
    ${SW5}=             Replace String      ${SW4}      _0     .
    ${SW6}=             Replace String      ${SW5}      _     .
    ${is_trunk}         run keyword and return status    Should Contain      ${SW6}      ..800
    ${SW7}=             Fetch From Right    ${SW6}      GNB.
    ${SW_trunk}=        run keyword if    ${is_trunk}==True    Replace String      ${SW7}      .800.    0.800.
    run keyword if    ${is_trunk}==True    set suite variable    ${SW7}    ${SW_trunk}
    [Return]            ${SW7}

Get SMOD version
    ${SMOD_name}=    admin_cli.get_fsm_info
    ${SMOD_name}=    set variable    ${SMOD_name[0]["productName"]}
    ${SMOD_name}=    fetch from left    ${SMOD_name}    ${SPACE}
    ${SMOD_name}=    catenate    SEPARATOR=    _    ${SMOD_name}    _ABIL.zip
    [Return]    ${SMOD_name}

Download Soft
    [Arguments]         ${SW_Version}    ${dir}=${OUTPUT_DIR}/temp_sw_dir
    # ${version}=         Fetch From Right    ${SW_Version}   .
    # ${fetcher}=         Catenate       .${version}
    # ${branch}=          Remove String     ${SW_Version}    ${fetcher}
    ${pkg}=             Set Variable    .zip
    ${sw_name}=         Catenate    AirScale-${SW_Version}${pkg}
    ${sw_url}=          Catenate    sudo wget --header='Authorization:Bearer ${token}'
    ...                 ${arti}${SW_Version}/${sw_name} -nv -P ${dir}
    ${res}=             Run         ${sw_url}
    Log                 ${res}
    [Return]            ${sw_name}

Download Software
    [Arguments]         ${release}  ${SW_Version}    ${dir}=${OUTPUT_DIR}/temp_sw_dir
    ${sw_name}=         Replace String Using Regexp    ${SW_Version}    ^SBTS[A-Za-z0-9]+_    ${release}_
    Run keyword if      '${release}' == 'SBTS00'
    ...                 Should Contain      ${sw_name}      ${release}_ENB_9999
    ...                 ELSE
    ...                 Should Contain      ${sw_name}      ${release}_ENB_0000
    ${sw_url}=          Catenate    sudo wget --header='Authorization:Bearer ${token}'
    ...                 ${rdnet_disc}${release}/${sw_name}/${sw_name}_release_BTSSM_downloadable_A54.zip
    ...                 -nv -P ${dir}
    ${res}=             Run         ${sw_url}
    Log                 ${res}
    [Return]            ${sw_name}_release_BTSSM_downloadable_A54.zip

Remove temp sw dir
    [Arguments]    ${dir}=${OUTPUT_DIR}/temp_sw_dir
    ${res}=  Run  sudo rm -rf ${dir}
    Log  ${res}

Perform Soft Update
    [Arguments]         ${sw}    ${connection}=default    ${dir}=${OUTPUT_DIR}/temp_sw_dir
    ${sw_name}=             Catenate    ${dir}/${sw}
    Log to console    Software update started. SW: ${sw}
    admin_cli.update_software   sw_package=${sw_name}  should_activate=True  timeout=1200  connection=${connection}

Check PDU model and set RU power reset
    [Arguments]  ${gnb_id}=${0}  ${du_id}=${0}  ${common_unit_id}=${0}  ${capacity_unit_id}=${0}  ${ru_id}=${0}
    ${pdu_model}=       get_pdu_model       ${gnb_id}   ${du_id}    ${common_unit_id}   ${capacity_unit_id}    ${ru_id}
    ${pdu_version}=     get_pdu_version     ${gnb_id}   ${du_id}    ${common_unit_id}   ${capacity_unit_id}    ${ru_id}
    ${pdu_ip}=          get_pdu_ip          ${gnb_id}   ${du_id}    ${common_unit_id}   ${capacity_unit_id}    ${ru_id}
    ${radio_port}=      get_radio_port      ${gnb_id}   ${du_id}    ${common_unit_id}   ${capacity_unit_id}    ${ru_id}
    Log to console    Resetting RU on port ${radio_port} on PDU: ${pdu_model} ver. ${pdu_version} with IP: ${pdu_ip}
    Run keyword if    "Gude"=="${pdu_model}"
    ...    Set Gude PDU power off RU    ${pdu_model}    ${pdu_ip}    ${pdu_version}    ${radio_port}
    ...    ELSE    Set PDU power off RU    ${pdu_model}    ${pdu_ip}    ${port}
    Sleep    10s
    Run keyword if    "Gude"=="${pdu_model}"
    ...    Set Gude PDU power on RU    ${pdu_model}    ${pdu_ip}    ${pdu_version}    ${radio_port}
    ...    ELSE    Set PDU power on RU    ${pdu_model}    ${pdu_ip}    ${radio_port}
    Wait until keyword succeeds    10 min    1 min    Check if RU's is not in disabled state
    Wait until keyword succeeds    ${comm_timer}    30 sec    Check BTS status after RU power reset


Check BTS status after RU power reset
    Check unwanted alarms
    ${onAir_state_after_DU_reset}=    run keyword and return status    gNB in onAir state
    run keyword if     '${onAir_state_after_DU_reset}'=='False'    FAIL


Set Gude PDU power off RU
    [Arguments]    ${model}    ${host}    ${version}   ${port}
    pdu.setup_pdu       model=${model}    host=${host}    version=${version}    alias=pdu
    pdu.power_off    port=${port}    pdu_device=pdu

Set PDU power off RU
    [Arguments]    ${model}    ${host}    ${port}
    pdu.setup_pdu       model=${model}    host=${host}    alias=pdu
    pdu.power_off    port=${port}    pdu_device=pdu

Set Gude PDU power on RU
    [Arguments]    ${model}    ${host}    ${version}   ${port}
    pdu.setup_pdu       model=${model}    host=${host}    version=${version}    alias=pdu
    pdu.power_on    port=${port}    pdu_device=pdu

Set PDU power on RU
    [Arguments]    ${model}    ${host}    ${port}
    pdu.setup_pdu       model=${model}    host=${host}    alias=pdu
    pdu.power_on    port=${port}    pdu_device=pdu

Check if RU's is not in disabled state
    ${bts_info}=  admin_cli.get_frm
    set suite variable    ${RUs_status}    invalid
    FOR    ${RU}    IN    @{bts_info}
        set suite variable    ${operationalState}    ${RU["status"]["operationalState"]}
        set suite variable    ${availabilityStatus}    None
        Run keyword if  '${operationalState}'!='disabled'  set suite variable    ${RUs_status}    valid
    END
    should not be equal as strings  ${RUs_status}    invalid

Reset site if OnAir cannot be reached
    [Documentation]    This keyword will trigger site reset when OnAir state cannot be achieved and faults 10 and 23
    ...    wasn't found
    [Arguments]  ${connection}=default
    gNB Site Reset  connection=${connection}
    ${OnAir_lc}=    run keyword and return status    wait until keyword succeeds    5 min    1 min    gNB in onAir state  connection=${connection}
    run keyword if    '${OnAir_lc}'=='True'    set suite variable    ${OnAir_State_Reached}    True

Check if all RU are enabled
    [Documentation]    This keyword will check status of all RU's. If more than one will have state othe than enabled
    ...   warning log will be created. This keyword will not trigger RMOD reset.
    ${RU_info}=  admin_cli.get_frm
    ${list_of_disabled_RUs}=    Create list
    FOR     ${RU}    IN    @{RU_info}
        set suite variable    ${valid}    True
        set suite variable    ${RU_number}    ${RU["id"]["configuration"]}
        ${RU_number}=    Fetch from right    ${RU_number}    /
        set suite variable    ${operationalState}    ${RU["status"]["operationalState"]}
        set suite variable    ${availabilityStatus}    ${RU["status"]["availabilityStatus"]}
        run keyword if    '${operationalState}'!='Enabled'    set suite variable    ${valid}    False
        run keyword if    '${availabilityStatus}'!='Online'    set suite variable    ${valid}    False
        run keyword if    '${valid}'=='False'    append to list    ${list_of_disabled_RUs}    ${RU_number}
    END
    ${empty_RU_list}=    run keyword and return status    should be empty    ${list_of_disabled_RUs}
    run keyword if    '${empty_RU_list}'=='False'    run keywords    log   Not all RUs were enabled. List of malfunction RUs:
    ...    level=WARN    AND    log list    ${list_of_disabled_RUs}    level=WARN

Check cells_status
    [Arguments]  ${connection}=default
    run keyword and ignore error    wait until keyword succeeds  30 min    20 sec   Check all cells  connection=${connection}
    ${alarm_dict}=    Check unwanted alarms list  connection=${connection}
    log    Active alarm list:    level=WARN
    log list    ${alarm_dict}    level=WARN
    ${get_cell_status}=    admin_cli.get_cells_info  connection=${connection}
    set suite variable    ${cells_enabled}    True
    ${cells_status_list}    create list
    FOR    ${cell}    IN    @{get_cell_status}
        log    ${cell}
        set suite variable    ${cell_status}    valid
        set suite variable    ${cell_number}    ${cell["id"]["configuration"]}
        ${cell_number}=    Fetch from right    ${cell_number}    /
        ${cell_status_dict}    create dictionary    id    ${cell_number}
        set suite variable    ${cell_opState}    ${cell["status"]["operationalState"]}
        run keyword if    '${cell_opState}'!='enabled'    run keywords    set suite variable    ${cell_status}
    ...    invalid    AND    set suite variable    ${cells_enabled}    False
        run keyword if    '${cell_status}'=='invalid'    set to dictionary    ${cell_status_dict}    status    invalid
    ...    ELSE    set to dictionary    ${cell_status_dict}    status    valid
        append to list    ${cells_status_list}    ${cell_status_dict}
    END
    ${not_full_check}=    run keyword and return status    should be equal    ${only_OnAir}    True
    run keyword if    '${not_full_check}'=='False'    run keyword if     '${cells_enabled}'=='True'    Log as success    ${cells_status_list}
    run keyword if    '${not_full_check}'=='False'    run keyword if     '${cells_enabled}'=='False'    run keywords
    ...    Log as failure    ${cells_status_list}    AND    FAIL
    run keyword if    '${not_full_check}'=='True'    Log as unimportant    ${cells_status_list}

Check cells_status multirat
    run keyword and ignore error    wait until keyword succeeds  30 min    20 sec   Check all cells multirat
    ${alarm_dict}=    Check unwanted alarms list
    log    Active alarm list:    level=WARN
    log list    ${alarm_dict}    level=WARN
    ${get_cell_status_nr}=    admin_cli.get_cells_info  cell_type=nr
    ${get_cell_status_lte}=    admin_cli.get_cells_info  cell_type=lte
    ${get_cell_status_wcdma}=    admin_cli.get_cells_info  cell_type=wcdma
    ${get_cell_status_gsm}=    admin_cli.get_cells_info  cell_type=gsm
    set suite variable    ${cells_enabled}    True
    ${cells_status_list}    create list
    FOR    ${cell}    IN    @{get_cell_status_nr}
        log    ${cell}
        set suite variable    ${cell_status_nr}    valid
        set suite variable    ${cell_number}    ${cell["id"]["configuration"]}
        ${cell_number}=    Fetch from right    ${cell_number}    /
        ${cell_status_dict}    create dictionary    id    ${cell_number}
        set suite variable    ${cell_opState_nr}    ${cell["status"]["operationalState"]}
        run keyword if    '${cell_opState_nr}'!='enabled'    run keywords    set suite variable    ${cell_status_nr}
    ...    invalid    AND    set suite variable    ${cells_enabled}    False
        run keyword if    '${cell_status_nr}'=='invalid'    set to dictionary    ${cell_status_dict}    status    invalid
    ...    ELSE    set to dictionary    ${cell_status_dict}    status    valid
        append to list    ${cells_status_list}    ${cell_status_dict}
    END
    FOR    ${cell}    IN    @{get_cell_status_lte}
        log    ${cell}
        set suite variable    ${cell_status_lte}    valid
        set suite variable    ${cell_number}    ${cell["id"]["configuration"]}
        ${cell_number}=    Fetch from right    ${cell_number}    /
        ${cell_status_dict}    create dictionary    id    ${cell_number}
        set suite variable    ${cell_opState_lte}    ${cell["status"]["operationalState"]}
        run keyword if    '${cell_opState_lte}'!='enabled'    run keywords    set suite variable    ${cell_status_lte}
    ...    invalid    AND    set suite variable    ${cells_enabled}    False
        run keyword if    '${cell_status_lte}'=='invalid'    set to dictionary    ${cell_status_dict}    status    invalid
    ...    ELSE    set to dictionary    ${cell_status_dict}    status    valid
        append to list    ${cells_status_list}    ${cell_status_dict}
    END
    FOR    ${cell}    IN    @{get_cell_status_wcdma}
        log    ${cell}
        set suite variable    ${cell_status_wcdma}    valid
        set suite variable    ${cell_number}    ${cell["id"]["configuration"]}
        ${cell_number}=    Fetch from right    ${cell_number}    /
        ${cell_status_dict}    create dictionary    id    ${cell_number}
        set suite variable    ${cell_opState_wcdma}    ${cell["status"]["operationalState"]}
        run keyword if    '${cell_opState_wcdma}'!='enabled'    run keywords    set suite variable    ${cell_status_wcdma}
    ...    invalid    AND    set suite variable    ${cells_enabled}    False
        run keyword if    '${cell_status_wcdma}'=='invalid'    set to dictionary    ${cell_status_dict}    status    invalid
    ...    ELSE    set to dictionary    ${cell_status_dict}    status    valid
        append to list    ${cells_status_list}    ${cell_status_dict}
    END
    FOR    ${cell}    IN    @{get_cell_status_gsm}
        log    ${cell}
        set suite variable    ${cell_status_gsm}    valid
        set suite variable    ${cell_number}    ${cell["id"]["configuration"]}
        ${cell_number}=    Fetch from right    ${cell_number}    /
        ${cell_status_dict}    create dictionary    id    ${cell_number}
        set suite variable    ${cell_opState_gsm}    ${cell["status"]["operationalState"]}
        run keyword if    '${cell_opState_gsm}'!='enabled'    run keywords    set suite variable    ${cell_status_gsm}
    ...    invalid    AND    set suite variable    ${cells_enabled}    False
        run keyword if    '${cell_status_gsm}'=='invalid'    set to dictionary    ${cell_status_dict}    status    invalid
    ...    ELSE    set to dictionary    ${cell_status_dict}    status    valid
        append to list    ${cells_status_list}    ${cell_status_dict}
    END
    ${not_full_check}=    run keyword and return status    should be equal    ${only_OnAir}    True
    run keyword if    '${not_full_check}'=='False'    run keyword if     '${cells_enabled}'=='True'    Log as success    ${cells_status_list}
    run keyword if    '${not_full_check}'=='False'    run keyword if     '${cells_enabled}'=='False'    run keywords
    ...    Log as failure    ${cells_status_list}    AND    FAIL
    run keyword if    '${not_full_check}'=='True'    Log as unimportant    ${cells_status_list}

Cell info for NOT trunk
    run keyword and ignore error    wait until keyword succeeds  30 min    20 sec   Check all cells
    ${alarm_dict}=    Check unwanted alarms list
    log    Active alarm list:    level=WARN
    log list    ${alarm_dict}    level=WARN
    ${get_cell_status}=    admin_cli.get_cells_info
    set suite variable    ${cells_enabled}    True
    ${cells_status_list}    create list
    FOR    ${cell}    IN    @{get_cell_status}
        log    ${cell}
        set suite variable    ${cell_status}    valid
        set suite variable    ${cell_number}    ${cell["id"]["configuration"]}
        ${cell_number}=    Fetch from right    ${cell_number}    /
        ${cell_status_dict}    create dictionary    id    ${cell_number}
        set suite variable    ${cell_opState}    ${cell["status"]["operationalState"]}
        set suite variable    ${cell_avStatus}    ${cell["status"]["availabilityStatus"]}
        run keyword if    '${cell_opState}'!='Enabled'    run keywords    set suite variable    ${cell_status}
    ...    invalid    AND    set suite variable    ${cells_enabled}    False
        run keyword if    '${cell_avStatus}'!='Online'    run keywords    set suite variable    ${cell_status}
    ...    invalid    AND    set suite variable    ${cells_enabled}    False
        run keyword if    '${cell_status}'=='invalid'    set to dictionary    ${cell_status_dict}    status    invalid
    ...    ELSE    set to dictionary    ${cell_status_dict}    status    valid
        append to list    ${cells_status_list}    ${cell_status_dict}
    END
    ${not_full_check}=    run keyword and return status    should be equal    ${only_OnAir}    True
    run keyword if    '${not_full_check}'=='False'    run keyword if     '${cells_enabled}'=='True'    Log as success    ${cells_status_list}
    run keyword if    '${not_full_check}'=='False'    run keyword if     '${cells_enabled}'=='False'    run keywords
    ...    Log as failure    ${cells_status_list}    AND    FAIL
    run keyword if    '${not_full_check}'=='True'    Log as unimportant    ${cells_status_list}

Log as success
    [Arguments]    ${cells_status_list}
    log    All cells are enabled    level=WARN
    log list    ${cells_status_list}    level=WARN

Log as failure
    [Arguments]    ${cells_status_list}
    log    One or more cells are disabled. All tests are canceled.    level=WARN
    log list    ${cells_status_list}    level=WARN

Log as unimportant
    [Arguments]    ${cells_status_list}
    log    Cells status list    level=WARN
    log list    ${cells_status_list}    level=WARN

Check unwanted alarms list
    [Tags]      WIP
    [Arguments]    ${connection}=default
    ${active_alarms}    admin_cli.get_active_alarms    timeout=60  connection=${connection}
    ${alarm_id_list}    Create List
    ${len}    get length    ${active_alarms}
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        ${tmp_alarm}    create dictionary    id    ${tmp_id}
        ${tmp_an}    Get From Dictionary    ${active_alarms[${i}]}    alarmName
        set to dictionary    ${tmp_alarm}    Alarm Name    ${tmp_an}
        ${tmp_fn}    Get From Dictionary    ${active_alarms[${i}]}    faultName
        set to dictionary    ${tmp_alarm}    Fault Name    ${tmp_fn}
        ${tmp_cl}    Get From Dictionary    ${active_alarms[${i}]}    impactedCellsList
        set to dictionary    ${tmp_alarm}    Cell List    ${tmp_cl}
        Append To List    ${alarm_id_list}    ${tmp_alarm}
    END
    log    ${alarm_id_list}
    [Return]     ${alarm_id_list}

Check all cells
    [Arguments]  ${connection}=default
    ${get_cell_status}=    admin_cli.get_cells_info  connection=${connection}
    set suite variable    ${cell_ready}    valid
    FOR    ${cell}    IN    @{get_cell_status}
        log    ${cell}
        set suite variable    ${cell_opState}    ${cell["status"]["operationalState"]}
        set suite variable    ${cell_avStatus}    None
        Run keyword if    '${cell_opState}'!='enabled'
        ...                set suite variable    ${cell_ready}    invalid
    END
    should be equal as strings  ${cell_ready}    valid

Check all cells multirat
    ${get_cell_status_nr}=    admin_cli.get_cells_info  cell_type=nr
    ${get_cell_status_lte}=    admin_cli.get_cells_info  cell_type=lte
    ${get_cell_status_wcdma}=    admin_cli.get_cells_info  cell_type=wcdma
    ${get_cell_status_gsm}=    admin_cli.get_cells_info  cell_type=gsm

    set suite variable    ${cell_ready_nr}    valid
    set suite variable    ${cell_ready_lte}    valid
    set suite variable    ${cell_ready_wcdma}    valid
    set suite variable    ${cell_ready_gsm}    valid
    FOR    ${cell}    IN    @{get_cell_status_nr}
        log    ${cell}
        set suite variable    ${cell_opState_nr}    ${cell["status"]["operationalState"]}
        set suite variable    ${cell_avStatus_nr}    None
        Run keyword if    '${cell_opState_nr}'!='enabled'
        ...                set suite variable    ${cell_ready_nr}    invalid
    END
    FOR    ${cell}    IN    @{get_cell_status_lte}
        log    ${cell}
        set suite variable    ${cell_opState_lte}    ${cell["status"]["operationalState"]}
        set suite variable    ${cell_avStatus_lte}    None
        Run keyword if    '${cell_opState_lte}'!='enabled'
        ...                set suite variable    ${cell_ready_lte}    invalid
    END
    FOR    ${cell}    IN    @{get_cell_status_wcdma}
        log    ${cell}
        set suite variable    ${cell_opState_wcdma}    ${cell["status"]["operationalState"]}
        set suite variable    ${cell_avStatus_wcdma}    None
        Run keyword if    '${cell_opState_wcdma}'!='enabled'
        ...                set suite variable    ${cell_ready_wcdma}    invalid
    END
    FOR    ${cell}    IN    @{get_cell_status_gsm}
        log    ${cell}
        set suite variable    ${cell_opState_gsm}    ${cell["status"]["operationalState"]}
        set suite variable    ${cell_avStatus_gsm}    None
        Run keyword if    '${cell_opState_gsm}'!='enabled'
        ...                set suite variable    ${cell_ready_gsm}    invalid
    END
    should be equal as strings  ${cell_ready_nr}    valid
    should be equal as strings  ${cell_ready_lte}    valid
    should be equal as strings  ${cell_ready_wcdma}    valid
    should be equal as strings  ${cell_ready_gsm}    valid

Start Btslog
    btslog.create_btslog_collector  name=btslog    target_file_name=PrepareTL
    core.setup_collectors       names=btslog
    core.start_collectors       names=btslog
    btslog.set_suite_alias      btslog
    log to console              [DEBUG] Will save logs to ${OUTPUT DIR}/btslog

Start Remote Btslog
    [Arguments]    ${tl}  ${tl_name}
    ${host}=  Set variable  ${tl.test_pc.default_ssh_connection_details.addr}
    ${user}=  Set variable  ${tl.test_pc.default_ssh_connection_details.username}
    ${password}=  Set variable  ${tl.test_pc.default_ssh_connection_details.password}
    ${executor_test_vm}=  Create Dictionary
    ...  host=${host}
    ...  user=${user}
    ...  password=${password}
    btslog.create_btslog_collector
    ...   name=remote_btslog_${tl_name}
    ...   target_file_name=PrepareTLRemote.tgz
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   executor=${executor_test_vm}
    core.setup_collectors       names=remote_btslog_${tl_name}
    core.start_collectors       names=remote_btslog_${tl_name}
    btslog.set_suite_alias      remote_btslog_${tl_name}
    log to console              [DEBUG] Will save logs to ${OUTPUT DIR}/remote_btslog_${tl_name}

Stop BtsLog
    core.stop_collectors        names=btslog
    Builtin.Sleep               10 sec
    core.collect_collectors     names=btslog  target_dir=${OUTPUTDIR}
    log to console              [DEBUG] remote collectors finished
    core.teardown_collectors    names=btslog

Stop Remote BtsLog
    [Arguments]    ${tl_name}
    core.stop_collectors        names=remote_btslog_${tl_name}
    Builtin.Sleep               10 sec
    core.collect_collectors     names=remote_btslog_${tl_name}  target_dir=${OUTPUTDIR}
    log to console              [DEBUG] collectors finished
    core.teardown_collectors    names=remote_btslog_${tl_name}
