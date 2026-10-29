*** Settings ***
Documentation
...    author:     Patryk Tatarek
...    contact:    patryk.tatarek@nokia.com

*** Variables ***
@{days}=    10    20    30    40    50    60    70    80    90    100

*** Keywords ***
Positive stress set
    [Documentation]    Perform parameters related keywords in loop. Meant for System Admin or Security Admin.
    FOR    ${time}    IN    @{days}
        Log       Local user parameters set to ${time} days    console=True
        ${dn}=    Create List    MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
        ${pn}=    Create List    localUserAllowedLifetime    localUserAllowedIdlePeriod
        ${pv}=    Create List    ${time}    ${time}
        Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vDU
        ${localUserLifetime}=    Check Parameter Value    param_name=localUserLifetimeExpDate
        ...                      dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vDU
        ${secAdmIdlePer}=        Check Parameter Value    param_name=secAdmIdlePerExpDate
        ...                      dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vDU
        ${appAdmIdlePer}=        Check Parameter Value    param_name=appAdmIdlePerExpDate
        ...                      dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vDU
        ${readOnlyIdlePer}=      Check Parameter Value    param_name=readOnlyIdlePerExpDate
        ...                      dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vDU
        ${currentDate}=          Get Current Date
        ${time_plus}=            Evaluate                ${time}+1
        ${expectedDate_plus}=    Add Time to Date        date=${currentDate}     time=${time_plus} days
        ${expectedDate}=         Fetch From Left         ${expectedDate_plus}    ${SPACE}
        Run Keyword and Continue on Failure    Should Contain    ${localUserLifetime}    ${expectedDate}
        Run Keyword and Continue on Failure    Should Contain    ${secAdmIdlePer}        ${expectedDate}
        Run Keyword and Continue on Failure    Should Contain    ${appAdmIdlePer}        ${expectedDate}
        Run Keyword and Continue on Failure    Should Contain    ${readOnlyIdlePer}      ${expectedDate}
        ${state_after}=          Get Current BTS State         hw_type=vDU
        ${alarms_after}=         Get Active Alarms From BTS    hw_type=vDU
        ${alarms_list}=          Get from Dictionary    ${alarms_after}    alarms
        @{fault_ids_after}=      Create List
        FOR    ${fault}    IN    @{alarms_list}
            ${fault_id}=         Get From Dictionary    ${fault}    fault_id
            Append to List       ${fault_ids_after}    ${fault_id}
        END
        Should be Equal          ${state_before}     ${state_after}
        Should be Equal          ${fault_ids_before}    ${fault_ids_after}
    END

Negative stress set
    [Documentation]    Perform parameters related keywords in loop. Meant for Application Admin and Read Only user.
    FOR    ${conn}    IN    @{read_conns}
        Run Keyword and Expect Error    *Method Not Allowed*
        ...                             Create Object with Single Parameter on BTS
        ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
        ...                             param_name=primaryCRLDP      param_value=${primary_crldp}
        ...                             hw_type=vDU    pre-connection=${conn}
        Run Keyword and Expect Error    *Method Not Allowed*
        ...                             Create Object with Single Parameter on BTS
        ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
        ...                             param_name=primaryCRLDP      param_value=${primary_crldp}
        ...                             hw_type=vDU    pre-connection=${conn}
        Run Keyword and Expect Error    *Method Not Allowed*
        ...                             Create Object with Single Parameter on BTS
        ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
        ...                             param_name=primaryCRLDP      param_value=${primary_crldp}
        ...                             hw_type=vDU    pre-connection=${conn}
        Run Keyword and Expect Error    *Method Not Allowed*
        ...                             Create Object with Single Parameter on BTS
        ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
        ...                             param_name=primaryCRLDP      param_value=${primary_crldp}
        ...                             hw_type=vDU    pre-connection=${conn}
        ${state_after}=          Get Current BTS State         hw_type=vDU    pre-connection=${conn}
        ${alarms_after}=         Get Active Alarms From BTS    hw_type=vDU    pre-connection=${conn}
        ${alarms_list}=          Get from Dictionary    ${alarms_after}    alarms
        @{fault_ids_after}=      Create List
        FOR    ${fault}    IN    @{alarms_list}
            ${fault_id}=         Get From Dictionary    ${fault}    fault_id
            Append to List       ${fault_ids_after}    ${fault_id}
        END
        Should be Equal          ${state_before}     ${state_after}
        Should be Equal          ${fault_ids_before}    ${fault_ids_after}
    END

Disconnect from all Read Only sessions
    FOR    ${conn}    IN    @{read_conns}
        Disconnect from ADMIN    connection=${conn}     hw_type=vDU
    END

Create LUACREQ via EMSsim on vDU
    [Arguments]    ${emssim_connection}
    execute_command_on_emssim_and_return_output    command=plan_create
    ...                                            connection=${emssim_connection}
    Sleep    3                                     reason=Executing command
    execute_command_on_emssim_and_return_output    command=plan_add MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1 -mandatory
    ...                                            connection=${emssim_connection}
    Sleep    3                                     reason=Executing command
    execute_command_on_emssim_and_return_output    command=plan_send -activate
    ...                                            connection=${emssim_connection}
    Sleep    90                                    reason=Executing command
    [Teardown]    Run Keywords                     Run Keyword and Ignore Error
    ...                                            execute_command_on_emssim
    ...                                            command=plan_destroy
    ...                                            connection=${emssim_connection}
    ...    AND                                     Sleep    3    reason=Executing command
