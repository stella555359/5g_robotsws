*** Settings ***
Library             taf.config.scf                     WITH NAME      scf

Documentation      Verify RU Lock and Unlock

*** Keywords ***
Perform RU Lock and Unlock
    [Documentation]    Performs RU Lock and Unlock
    [Arguments]    ${gnb_id}=0    ${port}=3600    ${alias}=cOAM
    ${NUMBER_OF_RUs}    Get number of RUs
    Set Test Variable    ${NUMBER_OF_RUs}
    Log To Console    Number of RUs:${NUMBER_OF_RUs}
    Log To Console    RU lock started
    Lock_RU    ${gnb_id}    ${port}    ${alias}
    Log To Console    RU Locked
    Log To Console    sleep for 10sss
    Sleep    10s
    Log To Console    RU Unlock started
    Unlock_RU    ${gnb_id}    ${port}    ${alias}
    Sleep    180s
    Log To Console    RU unlocked

Lock_RU
    [Arguments]         ${gnb_id}      ${port}      ${alias}
    admin.connect to   bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...               bts_port=${port}  name=${alias}
    ${scf_content}=    admin.get_current_scf_content    connection=${alias}    timeout=${30}
    FOR    ${RU_dist}    IN    @{RU_List}
        admin.Perform Parameter Recommissioning        dist_name=${RU_dist}    connection=${alias}
        ...          parameter=administrativeState
        ...          operation=update
        ...          value=Locked
        ...          skip_parameter_relation_errors=True
        ...          timeout=100
        ...          should_activate=True
        Log To Console    ${RU_dist} locked
    END
    admin.teardown          connection=${alias}

Unlock_RU
    [Arguments]         ${gnb_id}      ${port}      ${alias}
    admin.connect to   bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...               bts_port=${port}  name=${alias}
    FOR    ${RU_dist}    IN    @{RU_List}
        admin.Perform Parameter Recommissioning        dist_name=${RU_dist}    connection=${alias}
        ...          parameter=administrativeState
        ...          operation=update
        ...          value=Unlocked
        ...          skip_parameter_relation_errors=True
        ...          timeout=100
        ...          should_activate=True
        Log To Console     ${RU_dist} unlocked
    END
    admin.teardown          connection=${alias}

Get number of RUs
    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_new.xml
    scf.load_scf  file_path=${testlog_path}/SCF_new.xml
    ${RU_List}    scf.get_all_dist_names_of_specific_class   com.nokia.srbts.eqm:RMOD
    Set Test Variable    ${RU_List}
    ${RU_count}=    Get length    ${RU_List}
    [return]    ${RU_count}

Revert Gnb configuration if test fails
    [Arguments]    ${gnb_id}=0    ${port}=3600    ${alias}=cOAM
    Return From Keyword If    '${TEST_STATUS}' == 'PASS'
    Wait Until Keyword Succeeds     2min     30sec     Check if gNB is reachable    ${GNB_IP}
    Unlock_RU    ${gnb_id}    ${port}    ${alias}
