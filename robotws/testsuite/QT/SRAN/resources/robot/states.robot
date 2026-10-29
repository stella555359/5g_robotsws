*** Settings ***
Documentation  keywords for automated checking and logging of SMOD, BBMOD, RF hardware states and software version.
Library      BuiltIn
Library      taf.transport.ssh            WITH NAME    ssh
Library      taf.sbts.oam.coam.admin       WITH NAME    coam
Library      ${CURDIR}/../python/common.py
Library      ${CURDIR}/../python/classical_keywords.py

Resource     taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource     ${CURDIR}/connections.robot

*** Keywords ***
Check Smod State
    [Arguments]           ${connection}=coam_admin
    ${output}             coam.get_fsm_info    timeout=30    connection=${connection}
    Log Many              ${output}
    Set Test Variable     ${output_SMOD}    ${output}
    FOR   ${elem}   IN    @{output}
        Should Contain    ${elem['status']['operationalState']}      Enabled       ignore_case=True
        Should contain    ${elem['status']['proceduralStatus']}    configured    ignore_case=True
    END

Check BBmod State
    [Arguments]           ${connection}=coam_admin
    Wait Until Keyword Succeeds    10min  15s    Check If Output About BBmod State Is Not Empty    connection=${connection}
    FOR   ${elem}   IN    @{output_BBMOD}
        Should contain    ${elem['status']['operationalState']}    Enabled       ignore_case=True
        Should contain    ${elem['status']['proceduralStatus']}    configured    ignore_case=True
    END

Check If Output About BBmod State Is Not Empty
    [Arguments]            ${connection}
    ${output}              coam.get_fbb_info    timeout=30    connection=${connection}
    ${empty}               Should Not Be Empty    ${output}
    Set Global Variable    ${output_BBMOD}    ${output}
    Log Many               ${output}

Check RF Status
    [Arguments]           ${connection}=coam_admin    ${logs}=${False}
    ${output}             coam.get_frm    timeout=30    connection=${connection}
    Log Many              ${output}
    Should Not Be Empty   ${output}
    Set Test Variable     ${output_RF}    ${output}
    FOR   ${elem}   IN    @{output}
        Should contain    ${elem['status']['operationalState']}    Enabled       ignore_case=True
        Should contain    ${elem['status']['proceduralStatus']}    configured    ignore_case=True
        ${status}     Run Keyword And Return Status    Should contain    ${elem['productName']}    AEQN
        Run Keyword If    '${status}'=='${True}'    BuiltIn.Set Global Variable    ${rmod}    AEQN
        IF    '${elem['productName']}' == 'FRGU'
            ${gnss_update_before_rf_detection}    Get Variable Value    ${gnss_update_before_rf_detection}    ${False}
            ${FRGU_ID}    Get Variable Value    ${FRGU_ID}    ${EMPTY}
            IF    ${gnss_update_before_rf_detection} and '${FRGU_ID}' == ''
                Set Suite Variable    ${FRGU_ID}    ${elem['id']['internal']}
            END
        END
    END
    ${rf_number}          Get Length     ${output}
    BuiltIn.Set Global Variable    ${rf_number}
    Run Keyword If          '${rmod}'=='AEQN'    Run Keyword And Ignore Error     Stop RF Calibraton
    Run Keyword If          '${tl.tl_cloud_topology}' in ${testlines_with_LMI} and ${logs}
    ...                     Run Keyword And Ignore Error    Collect RU Tcpdump

Log HW Status
    [Documentation]    Keyword prints hw type (eg.SMOD), product name (eg. ASIB AirScale Common), serial number and operational and procedural state.
    ...    PRE: Keyword takes ${hw} variable containing hw type eg. SMOD, BBMOD, RF and add it as postfix to get access to Test Variables
    ...         (eg. ${output_SMOD}) created in:Check Smod State, Check BBmod State, Check RF Status.
    ...    POST: Keyword prints information about checked hw type. If operational state of hw is enabled it is printed green.
    ...          In other case it is printed red. If procedural state is configured it is printed green in other case it is printed red.
    [Arguments]    ${hw}    ${active_rf_sw_version}={}    ${log_rf_versions_status}=False
    FOR   ${elem}   IN    @{output_${hw}}
        ${productName_exist}     Run Keyword And Return Status    Dictionary Should Contain Key    ${elem}    productName
        ${serialNumber_exist}    Run Keyword And Return Status    Dictionary Should Contain Key    ${elem}    serialNumber
        IF    not (${productName_exist} and ${serialNumber_exist})
            Log To Console    \t Product name or serial number of ${hw} is not detected.
            CONTINUE
        END
        ${log_to_console_list}    Create List
        ${operational_txt}
        ...    Color HW Status    ${elem['status']['operationalState']}    enabled    Operational State is
        ${procedural_txt}
        ...    Color HW Status    ${elem['status']['proceduralStatus']}   configured    Procedural Status is
        Append To List
        ...    ${log_to_console_list}
        ...    \t ${hw} ${elem['productName']} ${elem['serialNumber']}
        ...    ${operational_txt}
        ...    ${procedural_txt}
        IF    '${hw}' == 'RF'
            IF    '${elem['productName']}' in ${oran_rf_list}
                ${rf8_test_status}=    get test case status by name    Install RF8 Package And Verify Cell Setup
                ${final_log_rf_versions_status}     Set Variable If    '${rf8_test_status}'!='NA' and ${log_rf_versions_status}
                ...    ${True}    ${False}
            ELSE
                ${final_log_rf_versions_status}     Set Variable     ${log_rf_versions_status}
            END
            ${log_to_console_list}    Log RF versions
            ...    ${log_to_console_list}
            ...    ${elem}
            ...    ${active_rf_sw_version}
            ...    ${final_log_rf_versions_status}
        END
        ${log_to_console}    Evaluate    "\\n\\t\\t ".join(${log_to_console_list})
        Log To Console    ${log_to_console}
    END

Log RF versions
    [Arguments]    ${log_to_console_list}     ${output}    ${active_rf_sw_version}={}
    ...            ${log_rf_versions_status}=False
    ${disable_to_log_version}    Evaluate    ("${output['serialNumber']}" not in ${active_rf_sw_version}) or not ${log_rf_versions_status}
    IF    ${disable_to_log_version}
        RETURN    ${log_to_console_list}
    END
    IF    '${RF_VERSIONS_MAP['${output['productName']}']}'!='not_set'
        ${activate_rf_version}    Skip RF version T1 T2 Suffix Check
        ...    activate_version=${active_rf_sw_version['${output['serialNumber']}']}
        ...    target_version=${RF_VERSIONS_MAP['${output['productName']}']}
        IF    '${activate_rf_version}' in '${RF_VERSIONS_MAP['${output['productName']}']}'
            Append To List   ${log_to_console_list}
            ...    Running sw version is ${green}${active_rf_sw_version['${output['serialNumber']}']}${rm_color}
        ELSE
            Append to List    ${log_to_console_list}
            ...               Running sw version is ${red}${active_rf_sw_version['${output['serialNumber']}']}${rm_color}
            ...               Target sw version is ${red}${RF_VERSIONS_MAP['${output['productName']}']}${rm_color}
        END
    ELSE
        Append to List    ${log_to_console_list}
        ...               Running sw version is ${green}${active_rf_sw_version['${output['serialNumber']}']}${rm_color}
        ...               Target sw version is not set
    END
    RETURN    ${log_to_console_list}

Color HW Status
    [Documentation]    Keyword check if ${actual_state} and ${expected_state} values are equal and depending on comparison results return text
    ...                with ${description} prefix and appropirate state color (green if values are equal and red if not).
    ...                Comparison is case insensitive.
    ...    PRE: Keyword takes as arguments ${actual_state}, ${expected_state} and ${description} prefix string.
    ...    POST: Keyword returns string starting with concatenated ${description} string and colored ${actual_state} preceeded by space sign.
    [Arguments]   ${actual_state}    ${expected_state}    ${description}
    IF    '${actual_state.strip().lower()}'=='${expected_state.strip().lower()}'
        RETURN    ${description}${SPACE}${green}${actual_state}${rm_color}
    ELSE
        RETURN    ${description}${SPACE}${red}${actual_state}${rm_color}
    END

Connect And Verify Smod Is Ready
    Connect To Common Unit    alias=smod
    Check FCT Board Status
    ssh.reset_cache

Check ${hw_num} Board Status
    Connect To Common Unit    alias=smod
    ${result}         Check HW Status    ${hw_num}
    Should Be True    ${result}
    [Teardown]        ssh.disconnect    connection=smod
