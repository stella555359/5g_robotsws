*** Settings ***
Documentation    This contains basic wts related keywords which are needed to run the Airphone TC.
...              :author Ashok Santhanam
Library    DateTime
Library    OperatingSystem
Library    Collections
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    ../../Resources/Python/DeltaStore.py    WITH NAME    delta_store
Library    ../../Resources/Python/AdminHelper.py    WITH NAME    admin_helper
Library    ../../Resources/Python/ScfHelper.py    WITH NAME    scf_helper
Library    ../../Resources/Python/vendor_file_update.py    WITH NAME    vendor
Library    taf.config.scf       WITH NAME      scf
Library    taf.transport.ssh    WITH NAME    ssh
Resource   ../Variables/Common_Variables.robot

*** Variables ***
&{NRDRB_LIST_PARAMS_DEFAULT}        nsa3xBearerAllowed=true    dlDataSplitMode=dlOverF1U    ulDataPath=ulOverNr
    ...    initialDLTrafficRouting=initDLoverX2U    actPrioritizeX2AfterInactivity=true    dlDataSplitBufferBuildUpThreshold=5
    ...    dlDataSplitBufferBuildUpThresholdPrioritizeX2=5    dlDataSplitGainThreshold=5    inactivityThresholdForPrioritizeX2=300
    ...    inactivityThresholdForRestartPrioritizeX2=100    prioritizeX2Period=500    ulDataSplitThreshold=b102400
    ...    actX2DuplicateTxNSA3x=false
${Lock_status}                   False
@{param_list}                    administrativeState
${Cell_setup_complete_pattern}    Cell Setup completed
${ABIO_CARD}    MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-1

*** Keywords ***
Ensure gNB state is Up
    admin.Setup admin
    ${bts_state}=       admin.Get Mrbts State
    ${current_date}=    Get Current Date
    Log    ${current_date} : BTS STATE : ${bts_state}    WARN
    Should Contain Any      ${bts_state}     Configured   OnAir    IntegratedToRan     ignore_case=${TRUE}
    [Teardown]    admin.Teardown admin

Ensure radio module is online
    admin.Setup admin
    ${bts_hw_info}=             admin.Get Bts Info
    ${operationalState_status}=     Set variable    ${bts_hw_info['radioModules']['rmod'][0]['status']['operationalState']}
    ${current_date}=            Get Current Date
    Log     ${current_date} : RADIO STATE : ${operationalState_status}     WARN
    Should be Equal As Strings      ${operationalState_status}      enabled      ignore_case=${TRUE}
    [Teardown]    admin.Teardown admin

Ensure cell is configured
    admin.Setup admin
    ${cells_info}=           admin.Get cells info
    ${procedural_status}=    Set variable     ${cells_info[0]['status']['proceduralStatus']}
    ${current_date}=         Get Current Date
    Log     ${current_date} : CELL STATE : ${procedural_status}     WARN
    Should be Equal As Strings       ${procedural_status}     configured      ignore_case=${TRUE}
    [Teardown]    admin.Teardown admin

Recommission GNB With Delta
    [Arguments]    ${delta_file}    ${skip_parameter_relation_errors}=${True}    ${should_activate}=${True}   ${timeout}=300
    admin.Setup admin
    admin.Perform Delta Recommissioning    delta_file=${delta_file}    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}   timeout=${timeout}
    [Teardown]    admin.Teardown admin

Check if gNB is reachable
    [Arguments]    ${gnb_ip}
    ${output}    Run    ping -c 20 ${gnb_ip}
    Should contain    ${output}    ttl
    Should not contain    ${output}    Destination Host Unreachable
    Should not contain    ${output}    error

Wait for gNB To Be Ready
    Wait Until Keyword Succeeds     15min     30sec     Ensure gNB state is Up
    Wait Until Keyword Succeeds     15min     30sec     Ensure radio module is online
    Run Keyword If    'MP_AP_LO' not in '${TOPOLOGY}'
    ...    Wait Until Keyword Succeeds     15min     30sec     Ensure cell is configured

Reboot GNB
    [Documentation]    This Keyowrd can be used to reboot gNB
    ssh.Connect to    ${GNB_IP}    ${GNB_USERNAME}    ${NOKIA_PASS}     alias=gnb_coam
    ssh.execute    command=reboot    connection=gnb_coam
    [Teardown]    ssh.disconnect    connection=gnb_coam

Download SCF file
    [Arguments]    ${local_dir_path}=/tmp    ${file_name}=SCF.xml
    ${scf_path}    admin_helper.download current scf file    local_dir_path=${local_dir_path}    file_name=${file_name}
    [Return]    ${scf_path}

Get GNB Version String
    ${gnb_build}    admin_helper.get_gnb_build
    [Return]    ${gnb_build}

Update NRDRB profile
    [Documentation]    This keyword is used to update the NRDRB profile.This keyword will add the parameters to the
    ...                delta store. This keyword needs to be followed with "Recommission GNB With Delta" to commission the gnb.
    ...                 Modified Date: 03-Sept-2020
    ...                 Last Modified by: merin.varghese@nokia.com
     [Arguments]    ${dist_name}    &{kwargs}
     ${nsadrb_list_params}     ${nrdrb_params}    Segregate parameters categorized under list type For NRDRB Profile    &{kwargs}
     Update NRDRB profile non list type parameters    ${dist_name}    ${nrdrb_params}
     Update NRDRB profile list type parameters     ${dist_name}    ${nsadrb_list_params}

Segregate parameters categorized under list type For NRDRB Profile
    [Documentation]    Internal keyword, not to be used outside.
    ...                 Modified Date: 03-Sept-2020
    ...                 Last Modified by: merin.varghese@nokia.com
    [Arguments]    &{kwargs}
    &{nsadrb_list_params}    create dictionary
    &{nrdrb_params}    create dictionary
    FOR    ${key}    IN    @{kwargs.keys()}
        ${status}    run keyword and return status    dictionary should contain key    ${NRDRB_LIST_PARAMS_DEFAULT}    ${key}
        run keyword if    ${status}    set to dictionary    ${nsadrb_list_params}    ${key}    ${kwargs["${key}"]}
        ...    ELSE    set to dictionary    ${nrdrb_params}    ${key}    ${kwargs["${key}"]}
    END
    [Return]    ${nsadrb_list_params}     ${nrdrb_params}

Update NRDRB profile non list type parameters
    [Documentation]    Internal keyword, not to be used outside.
    ...                 Modified Date: 03-Sept-2020
    ...                 Last Modified by: merin.varghese@nokia.com
    [Arguments]    ${dist_name}    ${nrdrb_params}
    delta_store.update managed object and parameter to delta    dist_name=${dist_name}    &{nrdrb_params}

Update NRDRB profile list type parameters
    [Documentation]    Internal keyword, not to be used outside.
    ...                 Modified Date: 03-Sept-2020
    ...                 Last Modified by: merin.varghese@nokia.com
    [Arguments]    ${dist_name}    ${nsadrb_list_params}
    FOR    ${key_in_nsadrb_list_params}    IN    @{nsadrb_list_params.keys()}
        Set To Dictionary    ${NRDRB_LIST_PARAMS_DEFAULT}    ${key_in_nsadrb_list_params}
        ...    ${nsadrb_list_params["${key_in_nsadrb_list_params}"]}
    END
    delta_store.add_list_parameters_to_delta    dist_name=${dist_name}    list_name=nsaDrbParam    &{NRDRB_LIST_PARAMS_DEFAULT}

Confirm If gNB Cell State is OnAir
    admin.Setup admin
    ${bts_state}=       admin.Get Mrbts State
    ${current_date}=    Get Current Date
    Log    ${current_date} : BTS STATE : ${bts_state}    WARN
    ${gNB_state_flag}    Run Keyword And Return Status    Should Be Equal      ${bts_state}   OnAir     ignore_case=${TRUE}
    [Teardown]    admin.Teardown admin
    [Return]    ${gNB_state_flag}

Recommission GNB With Scf
    [Documentation]    This keyword is used to recommission the gnb using the scf file provided.
    ...                 Modified Date: 04-July-2022
    ...                 Last Modified by: merin.varghese@nokia.com
    [Arguments]    ${scf_file}    ${skip_parameter_relation_errors}=${True}    ${should_activate}=${True}   ${timeout}=300
    admin.Setup admin
    admin.Perform commissioning    scf_file=${scf_file}    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}   timeout=${timeout}
    [Teardown]    admin.Teardown admin

Ensure radio module is enabled
    [Arguments]    ${ru}
    ${bts_hw_info}=             admin.Get Bts Info
    ${operationalState_status}=     Set variable    ${bts_hw_info['radioModules']['rmod'][${ru}]['status']['operationalState']}
    ${current_date}=            Get Current Date
    Log     ${current_date} : RADIO STATE : ${operationalState_status}     WARN
    Should be Equal As Strings      ${operationalState_status}      enabled      ignore_case=${TRUE}

Check if RU reset is successful
    [Arguments]    ${reset_output}
    ${reset}    get from list    ${reset_output}    1
    Run keyword if    '${reset['resultNode']['parameters']['status']}'=='Succeeded'
    ...    Log to console    RMOD reset is Done
    ...    ELSE    Fail

RU reset via webgui
    [Arguments]    ${reset_type}=Hard
    ${rmod_count}     Get all RMOD distnames in BTS
    FOR    ${ru}    IN RANGE    ${rmod_count}
        admin.Setup admin
        Log To Console    To check the operational status of the RU's
        Ensure radio module is enabled    ${ru}
        ${distName_RMOD}=    Get From List    ${RU_List}    ${ru}
        ${current_date}=     Get Current Date
        Log    ${current_date} : RADIO DN : ${distName_RMOD}    WARN
        Log To Console    RU reset started
        ${reset_output}=    admin.reset_unit    dist_name=${distName_RMOD}    timeout=300s    reset_type=${reset_type}    force_radio_reset=True
        Wait Until Keyword Succeeds   1min    5sec    Check if RU reset is successful    ${reset_output}
        Wait Until Keyword Succeeds   5min    30sec    Check all RMODs are online    ${rmod_count}
        Wait Until Keyword Succeeds     15min     30sec     Ensure cell is configured
    END

Fetch total no of RMODs in BTS
    admin.Setup admin
    ${bts_hw_info}=             admin.Get Bts Info
    Log To Console    Check the number of RUs
    @{list_RUs}    Set Variable    ${bts_hw_info['radioModules']['rmod']}
    ${total_RUs}    Get Length    ${list_RUs}
    Set Test Variable    ${total_RUs}
    Should Be True    ${total_RUs}>=${1}    msg=Check RU status failed as total RU number is less than 1
    [Return]    ${total_RUs}
    [Teardown]     admin.Teardown admin

Check all RMODs are online
    [Arguments]    ${total_no_of_RUs}=${EMPTY}
    Log to console    check all the RU's online
    FOR    ${ru}    IN RANGE    ${total_no_of_RUs}
        Ensure radio module is enabled    ${ru}
    END

Update vendor profile for ecpri72e
    Log To Console    msg=Going to update the vendor profile and gnb commission
    vendor.modify_upload_vendor_file_in_gnb_and_commission_gnb
    Log To Console    msg=Vendor profile is updated

Check the gNB Logs for 72eFHobject
    ssh.Connect To    ${GNB_IP}    ${GNB_USERNAME}    ${NOKIA_PASS}     alias=gnb_coam
    ${result}         ssh.execute    grep -i "ECpri72eUplaneCarrierCreator" /tmp/startup_BTSOM.log
    ...               connection=gnb_coam
    Should Contain    ${result}    ECpri72eUplaneCarrierCreator    ignore_case=True
    Log to Console    ${result}
    [Teardown]    ssh.disconnect    connection=gnb_coam

Update BSR File
    [Arguments]    ${bsr_file_path}=${EMPTY}    ${status_check_interval}=30s
    admin.setup admin
    FOR    ${i}    IN RANGE    5
        ${status}    admin.Wait Sw Update Possible
        ${is_ready}    Evaluate    '${status}'.strip() in ('completed', 'wait btsReadyForSwUpdate:true succeed')
        Exit For Loop If    ${is_ready}
        Log To Console    msg=Status not ready for SW update (got: ${status}), rechecking after ${status_check_interval}
        Sleep    ${status_check_interval}    msg=Waiting before rechecking status
    END
    Run Keyword If    not ${is_ready}    Log to console    SW update status did not become ready after retries. Last status: ${status}
    ${ret}    admin.Update Software    ${bsr_file_path}
    [Teardown]    admin.teardown admin

Cell Delete and setup via open loop in dlMimoMode
    [Arguments]         ${gnb_id}      ${port}      ${alias}      ${NUMBER_OF_CELLS}
    admin.connect to    bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...               bts_port=${port}  name=${alias}
    ${scf_content}=     admin.get_current_scf_content    connection=${alias}    timeout=${30}
    Log To Console     CellCountToDelete:${NUMBER_OF_CELLS}
    FOR    ${Cell}    IN RANGE    ${NUMBER_OF_CELLS}
        admin.Perform Parameter Recommissioning        dist_name=MRBTS-1/NRBTS-1/NRCELL-${Cell+1}    connection=${alias}
        ...          parameter=dlMimoMode
        ...          operation=update
        ...          value=4x4 or 4x2 Open Loop Spatial Multiplexing
        ...          skip_parameter_relation_errors=True
        ...          timeout=100
        ...          should_activate=True
        Log To Console     Cell ${Cell+1} Deleted and setup via open loop in dlMimoMode
    END
    [Teardown]    admin.teardown    connection=${alias}

Cell Delete and setup via close loop in dlMimoMode
    [Arguments]         ${gnb_id}      ${port}      ${alias}      ${NUMBER_OF_CELLS}
    admin.connect to    bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...               bts_port=${port}  name=${alias}
    ${scf_content}=     admin.get_current_scf_content    connection=${alias}    timeout=${30}
    Log To Console      CellCountToSetup:${NUMBER_OF_CELLS}
    FOR    ${Cell}    IN RANGE    ${NUMBER_OF_CELLS}
        admin.Perform Parameter Recommissioning        dist_name=MRBTS-1/NRBTS-1/NRCELL-${Cell+1}    connection=${alias}
        ...          parameter=dlMimoMode
        ...          operation=update
        ...          value=4x4 or 4x2 Closed Loop Spatial Multiplexing
        ...          skip_parameter_relation_errors=True
        ...          timeout=100
        ...          should_activate=True
        Log To Console     Cell ${Cell+1} Delete and setup via close loop in dlMimoMode
    END
    [Teardown]    admin.teardown    connection=${alias}

Get all cells from BTS
    ${nrcell_distnames}    admin_helper.get_intra_nrcell_distnames
    set test variable    ${nrcell_distnames}

Perform NR Cell Lock and Unlock
    Get all cells from BTS
    FOR    ${each_cell}    IN    @{nrcell_distnames}
        Lock cell and verify the cell state    ${each_cell}
        sleep    30s
        Unlock cell and verify gnb state    ${each_cell}
    END
    [Teardown]    Unlock the cell incase of failure after cell locked successfully    ${each_cell}

Lock cell and verify the cell state
    [Arguments]    ${cell_distname}
    Lock NRCELL    ${cell_distname}
    sleep    10s   msg=Sleeping for 10s
    Verify cell is in expected state    cell_distname=${cell_distname}     expected_adm_state=Locked
    Log to console     ${cell_distname} is locked successfully

Unlock cell and verify gnb state
    [Arguments]    ${cell_distname}
    Unlock NRCELL    ${cell_distname}
    sleep    10s   msg=Sleeping for 10s
    Ensure gnb and radio is up
    Verify cell is in expected state    cell_distname=${cell_distname}     expected_adm_state=Unlocked
    Log to console     ${cell_distname} is unlocked successfully

Verify cell is in expected state
    [Arguments]    ${cell_distname}     ${expected_adm_state}=${EMPTY}
    admin.Connect To
    ${output}    admin.Get Parameter By Distname    dist_name=${cell_distname}    parameter_list=${param_list}
    ${administrative_state}=    Set Variable    ${output[0]['parameters']['administrativeState']}
    Run Keyword If    '${administrative_state}' == '${expected_adm_state}'     Log    Cell ${cell_distname} is ${administrative_state}
    ...    ELSE    Fail    Cell ${cell_distname} is not ${administrative_state}
    Run Keyword If    '${expected_adm_state}' == 'Locked'   Set Test Variable   ${Lock_status}    True
    ...   ELSE    Set Test Variable   ${Lock_status}    False
    [Teardown]    admin.Teardown

Unlock the cell incase of failure after cell locked successfully
    [Arguments]    ${cell_distname}
    Run keyword If    ${Lock_status}    Unlock cell and verify gnb state    ${cell_distname}

Ensure gnb and radio is up
    Wait Until Keyword Succeeds     15min     30sec     Ensure gNB state is Up
    Wait Until Keyword Succeeds     15min     30sec     Ensure radio module is online

Lock NRCELL
    [Arguments]    ${cell_distname}
    admin.Connect To
    admin.lock    dist_name=${cell_distname}    timeout=90
    [Teardown]    admin.Teardown

Unlock NRCELL
    [Arguments]    ${cell_distname}
    admin.Connect To
    admin.unlock    dist_name=${cell_distname}    timeout=90
    [Teardown]    admin.Teardown

Get Active Alarms
    admin.Connect To
    ${alarms}     admin.Get Active Alarms
    [Return]    ${alarms}
    [Teardown]    admin.Teardown

Perform Reset Site and Check BTS Status
    admin.Connect To
    Log to console     \n Site reset starting.. \n
    admin.reset_site    timeout=300    detailed_output=True
    Sleep    5min
    Wait Until Keyword Succeeds    3min    60s     Check BTS is OnAir
    [Teardown]    admin.Teardown

Perform BBMOD Reset and Check BTS Status
    admin.Connect To
    Log to console     \n BBMOD reset starting.. \n
    admin.reset_unit    dist_name=${ABIO_CARD}    reset_type=Warm    detailed_output=True    timeout=300	 connection=default
    Sleep    5min
    Wait Until Keyword Succeeds    5min    30sec     Check BTS is OnAir
    Log To Console    Sleep for 180 seconds
    Sleep    180s
    [Teardown]    admin.Teardown

Check BTS is OnAir
    ${bts_state}    admin.Get Mrbts State
    Should Contain Any    ${bts_state}    onAir    ignore_case=${TRUE}

Perform NR Cell Block and Unblock
    Wait Until Keyword Succeeds    5min    30sec    admin.Connect To
    admin.block_all_cells    rat=NR    detailed_output=True
    sleep    30s
    Check State Of All Cells during block unblock operation    Blocked
    admin.unblock_all_cells    rat=NR    detailed_output=True
    sleep    30s
    Check State Of All Cells during block unblock operation    Unblocked
    [Teardown]    admin.Teardown

Check State Of All Cells during block unblock operation
    [Arguments]    ${cell_status}
    ${cell_info}=    admin.get_cells_info
    ${list_len}=    Get Length    ${cell_info}
    FOR    ${cell_id}   IN RANGE    ${list_len}
        Should Be Equal As Strings    ${cell_info[${cell_id}]['status']['blockingState']}
        ...    ${cell_status}    ignore_case=${TRUE}
    END

Validate Cell Setup Pattern After oam operation
    [Arguments]     ${CELL_BLOCK_UNBLOCK_count}
    admin.Connect To
    ${cell_info}=    admin.get_cells_info
    ${list_len}=    Get Length    ${cell_info}
    FOR    ${cell_id}   IN RANGE    ${list_len}
        ${validation_string}=    Catenate    ${Cell_setup_complete_pattern}     for \\[CELL_ID:${cell_id + 1}\\]
        Execute Egate Command    cmd=sim_log_set flush    timeout=1s
        sleep    5s    # Timer is added to avoid the delay in cell validation during cell BU scenario
        ${count}=    Get Count of String Occurrences    ${validation_string}
        ${expected_count}=    Evaluate    ${CELL_BLOCK_UNBLOCK_count} + 1
        Should Be Equal As Integers    ${count}    ${expected_count}
    END
    [Teardown]    admin.Teardown

Get Count of String Occurrences
    [Arguments]    ${validation_string}
    ${count}=    RUN    grep -o "${validation_string}" /opt/wts/latest/egate_console.log | wc -l
    [Return]    ${count}

Get all AMF distnames in BTS
    ${scf_path}    Download SCF file    local_dir_path=${testlog_path}
    scf.load_scf  file_path=${scf_path}
    ${AMF_list}    scf.get_all_dist_names_of_specific_class   com.nokia.srbts.nrbts:SERVEDAMF
    Set Test Variable    ${AMF_list}
    ${AMF_count}=    Get length    ${AMF_list}
    [return]    ${AMF_count}

Perform AMF lock
    [Arguments]    ${AMF_distname}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${AMF_distname}    administrativeState=Locked
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    log to console     Locked ${AMF_distname} now.....
    sleep    30s
    Wait Until Keyword Succeeds    5min    30sec     Ensure gnb and radio is up

Verify AMF administrative state
    [Arguments]      ${dist_name}    ${expected_admininstrative_state}     ${expected_nglink_status}
    admin.Setup admin
    ${amf_parameters}=             admin.get parameter by distname    dist_name=${dist_name}
    ${administrative_state}=     Set variable    ${amf_parameters[0]['parameters']['administrativeState']}
    ${nglink_status}     Set variable    ${amf_parameters[0]['parameters']['ngLinkStatus']}
    ${current_date}=            Get Current Date
    Log     ${current_date} : AMF ADMINISTRATIVE STATE : ${administrative_state}     WARN
    Should be Equal As Strings      ${administrative_state}      ${expected_admininstrative_state}      ignore_case=${TRUE}
    Run Keyword If    '${expected_admininstrative_state}' == 'Locked'   Set Test Variable   ${Lock_status}    True
    ...   ELSE    Set Test Variable   ${Lock_status}    False
    Log     ${current_date} : NGLINK STATUS : ${nglink_status}     WARN
    Should be Equal As Strings      ${nglink_status}      ${expected_nglink_status}      ignore_case=${TRUE}
    [Teardown]    admin.Teardown admin

Perform AMF Unlock
    [Arguments]    ${AMF_distname}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${AMF_distname}    administrativeState=Unlocked
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    log to console     Unlocked ${AMF_distname} now.....
    sleep    30s
    Wait Until Keyword Succeeds    5min    30sec     Ensure gnb and radio is up

Perform AMF lock Unlock operation
    [Arguments]    ${iteration}=${EMPTY}
    ${amf_count}     Get all AMF distnames in BTS
    FOR    ${amf_distname}    IN    @{AMF_list}
        Perform AMF lock    ${amf_distname}
        sleep    30
        Verify AMF administrative state     dist_name=${AMF_distname}     expected_admininstrative_state=Locked    expected_nglink_status=Inactive
    END
    Log to console     All AMF are locked
    ${expected_count_lock}=    Evaluate    ${iteration} + 1
    run keyword and continue on failure    Wait Until Keyword Succeeds    2min    30sec
    ...    Validate AMF prints after AMF lock or unlock    expected_ng_status=down    expected_count=${expected_count_lock}
    FOR    ${amf_distname}    IN    @{AMF_list}
        Perform AMF Unlock    ${amf_distname}
        sleep    30
        Verify AMF administrative state     dist_name=${AMF_distname}     expected_admininstrative_state=Unlocked    expected_nglink_status=Active
    END
    Log to console     All AMF are unlocked
    ${expected_count_unlock}=    Evaluate    ${iteration} + 2
    run keyword and continue on failure    Wait Until Keyword Succeeds    2min    30sec
    ...    Validate AMF prints after AMF lock or unlock    expected_ng_status=up    expected_count=${expected_count_unlock}
    [Teardown]    Unlock AMF incase of failure after AMF lock

Validate AMF prints after AMF lock or unlock
    [Arguments]     ${expected_ng_status}    ${expected_count}
    ${validation_string}=    Set variable if    '${expected_ng_status}'=='down'    All NG links are down    NG link is Up
    Execute Egate Command    cmd=sim_log_set flush    timeout=1s
    sleep    5s    # Timer is added to avoid the delay in ng link validation
    ${count}=    Get Count of String Occurrences    ${validation_string}
    Should Be Equal As Integers    ${count}    ${expected_count}

Unlock AMF incase of failure after AMF lock
    Return From Keyword If    '${Lock_status}' == 'False'
    FOR    ${amf_distname}    IN    @{AMF_list}
        Perform AMF Unlock    ${amf_distname}
        sleep    20
        Verify AMF administrative state     dist_name=${AMF_distname}     expected_admininstrative_state=Unlocked    expected_nglink_status=Active
    END
    Log to console     All AMF are unlocked

Get all RMOD distnames in BTS
    ${scf_path}    Download SCF file    local_dir_path=${testlog_path}
    scf.load_scf  file_path=${scf_path}
    ${RU_List}    scf.get_all_dist_names_of_specific_class   com.nokia.srbts.eqm:RMOD
    Set Test Variable    ${RU_List}
    ${RU_count}=    Get length    ${RU_List}
    [return]    ${RU_count}

Perform RMOD lock Unlock operation
    ${rmod_count}     Get all RMOD distnames in BTS
    FOR    ${rmod_distname}    IN    @{RU_List}
        Perform RMOD lock    ${rmod_distname}
        sleep    30
        Verify RU administrative_state     rmod_dist_name=${rmod_distname}     expected_admininstrative_state=Locked
    END
    Log to console     All RMOD are locked
    FOR    ${rmod_distname}    IN    @{RU_List}
        Perform RMOD Unlock    ${rmod_distname}
        sleep    30
        Verify RU administrative_state     rmod_dist_name=${rmod_distname}     expected_admininstrative_state=Unlocked
    END
    Log to console     All RMOD are unlocked
    [Teardown]    Unlock RMOD incase of failure after RMOD lock

Perform RMOD lock
    [Arguments]    ${rmod_distname}
    admin.Connect To
    admin.lock    dist_name=${rmod_distname}    timeout=90
    [Teardown]    admin.Teardown

Perform RMOD unlock
    [Arguments]    ${rmod_distname}
    admin.Connect To
    admin.unlock    dist_name=${rmod_distname}    timeout=90
    [Teardown]    admin.Teardown

Verify RU administrative_state
    [Arguments]      ${rmod_dist_name}    ${expected_admininstrative_state}
    admin.Setup admin
    ${rmod_parameters}=             admin.get parameter by distname    dist_name=${rmod_dist_name}
    ${administrative_state}=     Set variable    ${rmod_parameters[0]['parameters']['administrativeState']}
    ${current_date}=            Get Current Date
    Log     ${current_date} : RMOD ADMINISTRATIVE STATE : ${administrative_state}     WARN
    Should be Equal As Strings      ${administrative_state}      ${expected_admininstrative_state}      ignore_case=${TRUE}
    Run Keyword If    '${expected_admininstrative_state}' == 'Locked'   Set Test Variable   ${Lock_status}    True
    ...   ELSE    Set Test Variable   ${Lock_status}    False
    [Teardown]    admin.Teardown admin

Unlock RMOD incase of failure after RMOD lock
    Return From Keyword If    '${Lock_status}' == 'False'
    FOR    ${rmod_distname}    IN    @{RU_List}
        Perform RMOD Unlock    ${rmod_distname}
        sleep    30
        Verify RU administrative_state     rmod_dist_name=${rmod_distname}     expected_admininstrative_state=Unlocked
    END
    Log to console     All RMOD are unlocked

Perform AMF lock Unlock operation without NGlink validation
    ${amf_count}     Get all AMF distnames in BTS
    FOR    ${amf_distname}    IN    @{AMF_list}
        Perform AMF lock    ${amf_distname}
        sleep    30
        Verify AMF administrative state     dist_name=${amf_distname}     expected_admininstrative_state=Locked    expected_nglink_status=Inactive
    END
    Log to console     All AMF are locked
    Sleep    60
    FOR    ${amf_distname}    IN    @{AMF_list}
        Perform AMF Unlock    ${amf_distname}
        sleep    30
        Verify AMF administrative state     dist_name=${amf_distname}     expected_admininstrative_state=Unlocked    expected_nglink_status=Active
    END
    Log to console     All AMF are unlocked
    [Teardown]    Unlock AMF incase of failure after AMF lock

Delete BSR File
    [Arguments]    ${bsr_file_name}=${EMPTY}    ${status_check_interval}=30s
    Return From Keyword If    '${bsr_update}' == 'False'
    admin.setup admin
    FOR    ${i}    IN RANGE    5
        ${status}    admin.Wait Sw Update Possible
        ${is_ready}    Evaluate    '${status}'.strip() in ('completed', 'wait btsReadyForSwUpdate:true succeed')
        Exit For Loop If    ${is_ready}
        Log To Console    msg=Status not ready for SW update (got: ${status}), rechecking after ${status_check_interval}
        Sleep    ${status_check_interval}    msg=Waiting before rechecking status
    END
    Run Keyword If    not ${is_ready}    Log to console    SW update status did not become ready after retries. Last status: ${status}
    ${return_output}    admin.delete bsr file    ${bsr_file_name}
    ${is_completed}    Evaluate    '${return_output}'.strip() in ('completed')
    Run Keyword If    not ${is_completed}    Log to console    Failed to delete BSR file. Output: ${return_output}
    [Teardown]    admin.teardown admin

Perform LANE lock
    [Arguments]    ${lane_distname}=MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1
    admin.Connect To
    Set Test Variable    ${lane_distname}
    admin.lock    dist_name=${lane_distname}    timeout=200
    sleep    5s
    [Teardown]    admin.Teardown

Perform LANE unlock
    [Arguments]    ${lane_distname}
    admin.Connect To
    admin.unlock    dist_name=${lane_distname}    timeout=90
    sleep    5s
    [Teardown]    admin.Teardown

Perform LANE lock Unlock operation
    [Arguments]    ${lane_distname}=${EMPTY}
    Perform LANE lock    ${lane_distname}
    Log To Console    Locking lane ${lane_distname}
    Verify LANE administrative state    dist_name=${lane_distname}     expected_admininstrative_state=Locked
    sleep    180s
    Perform LANE unlock    ${lane_distname}
    Verify LANE administrative state    dist_name=${lane_distname}     expected_admininstrative_state=Unlocked
    Log To Console    unlocking lane ${lane_distname}
    sleep    180s
    Wait Until Keyword Succeeds    5min    30sec     Ensure gnb and radio is up
    [Teardown]    Unlock LANE incase of failure after LANE lock    ${lane_distname}

Verify LANE administrative state
    [Arguments]      ${dist_name}    ${expected_admininstrative_state}
    admin.Setup admin
    ${lane_parameters}=             admin.get parameter by distname    dist_name=${dist_name}
    ${administrative_state}=     Set variable    ${lane_parameters[0]['parameters']['administrativeState']}
    ${current_date}=            Get Current Date
    Log     ${current_date} : LANE ADMINISTRATIVE STATE : ${administrative_state}     WARN
    Should be Equal As Strings      ${administrative_state}      ${expected_admininstrative_state}      ignore_case=${TRUE}
    Run Keyword If    '${expected_admininstrative_state}' == 'Locked'   Set Test Variable   ${Lock_status}    True
    ...   ELSE    Set Test Variable   ${Lock_status}    False
    [Teardown]    admin.Teardown admin

Unlock LANE incase of failure after LANE lock
    [Arguments]    ${lane_distname}=${EMPTY}
    Return From Keyword If    '${Lock_status}' == 'False'
    Perform LANE unlock    ${lane_distname}
    Verify LANE administrative state    dist_name=${lane_distname}     expected_admininstrative_state=Unlocked
    Log To Console    unlocking lane ${lane_distname}
    sleep    180s
