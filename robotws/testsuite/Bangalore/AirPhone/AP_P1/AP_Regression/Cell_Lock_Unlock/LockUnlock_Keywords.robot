*** Settings ***
Documentation    Contains Lock and Unlock related keywords

*** Keywords ***
Perform Cell Lock and Unlock
    [Arguments]    ${NUMBER_OF_CELLS}    ${gnb_id}=0    ${port}=3600    ${alias}=cOAM
    Log To Console    Cell lock started
    Cell Lock using parameter    ${gnb_id}    ${port}    ${alias}    ${NUMBER_OF_CELLS}
    Log To Console    Cell Locked
    Log To Console    sleep for 10s
    Sleep    10s
    Log To Console    Cell Unlock started
    Cell unlock using parameter    ${gnb_id}    ${port}    ${alias}    ${NUMBER_OF_CELLS}
    Log To Console    Cell unlocked

Cell Lock using parameter
    [Arguments]         ${gnb_id}      ${port}      ${alias}      ${NUMBER_OF_CELLS}
    admin.connect to    bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...               bts_port=${port}  name=${alias}
    ${scf_content}=     admin.get_current_scf_content    connection=${alias}    timeout=${30}
    Log To Console     CellCountToLock:${NUMBER_OF_CELLS}
    FOR    ${Cell}    IN RANGE    ${NUMBER_OF_CELLS}
        admin.Perform Parameter Recommissioning        dist_name=MRBTS-1/NRBTS-1/NRCELL-${Cell+1}    connection=${alias}
        ...          parameter=administrativeState
        ...          operation=update
        ...          value=Locked
        ...          skip_parameter_relation_errors=True
        ...          timeout=100
        ...          should_activate=True
        Log To Console     Cell ${Cell+1} locked
    END
    [Teardown]    admin.teardown    connection=${alias}

Cell unlock using parameter
    [Arguments]         ${gnb_id}      ${port}      ${alias}      ${NUMBER_OF_CELLS}
    admin.connect to    bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...               bts_port=${port}  name=${alias}
    ${scf_content}=     admin.get_current_scf_content    connection=${alias}    timeout=${30}
    Log To Console      CellCountToUnlock:${NUMBER_OF_CELLS}
    FOR    ${Cell}    IN RANGE    ${NUMBER_OF_CELLS}
        admin.Perform Parameter Recommissioning        dist_name=MRBTS-1/NRBTS-1/NRCELL-${Cell+1}    connection=${alias}
        ...          parameter=administrativeState
        ...          operation=update
        ...          value=Unlocked
        ...          skip_parameter_relation_errors=True
        ...          timeout=100
        ...          should_activate=True
        Log To Console     Cell ${Cell+1} unlocked
    END
    [Teardown]    admin.teardown    connection=${alias}
