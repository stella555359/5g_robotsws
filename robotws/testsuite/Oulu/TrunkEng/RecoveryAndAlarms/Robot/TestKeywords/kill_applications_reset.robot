*** Settings ***
Documentation
...   Author:   Mirka Kyllonen
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/Resources/reco_commissioning_kws.robot
Library     testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface
Library     testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FMRecoCommon


*** Variables ***
&{cell_enabled}      operationalState=enabled
&{cell_disabled}     operationalState=disabled
${SNAPSHOT_D}        ${True}
${LOOPING_KW}        ${False}
${SELECT_ALWAYS_SAME_SW_NODE}    ${False}

*** Keywords ***
Application kill rat reset
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${WAIT_FOR_ALARM}
    ...            ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${STEP_NBR}
#    ${STEP_NBR}=   Check If Step Smaller Or Same As Saved If Is Increase   ${STEP_NBR}
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword                            Common Preconditions
    Run Keyword And Continue On Failure    List All Applications
    Run Keyword And Continue On Failure    Make SSH Log
    Run Keyword And Continue On Failure    Make BTS SSH Connection
    Run Keyword And Continue On Failure    Add Expected Alarm  severity=Warning  alarm_id=${ALARM_NBR_RAT_RESET}
                        ...                fault_id=${FAULT_NBR_RAT_RESET}
                        ...                fault_name=${FAULT_NAME_RAT_RESET}
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
# This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure    Check If Fault 4590 Should Be Allowed
    ${VIRTUAL_NODE_PIDS}=    Get Virtual Pids    CentralCPlane
    Print Step Text    ${STEP_NBR}.1  Get pid of ${APPLICATION}
    ${pid}=   Get Virtual Pid Of Application    ${APPLICATION}    ${VIRTUAL_NODE_PIDS}
    Print Step Text    ${STEP_NBR}.2  Kill ${APPLICATION} -application and expect RAT autonomous reset
    ${radio_uptimes}=                      Check Rmod Uptimes
    Run Keyword And Continue On Failure    Kill Application      ${pid}    ${APPLICATION}
    Run Keyword And Continue On Failure    Close BTS SSH Connection
    Print Step Text    ${STEP_NBR}.3  Check RAT autonomous reset alarm after fault generation
    Run Keyword And Continue On Failure    Check Expected Alarms  wait_active_timeout=300
    Run Keyword And Continue On Failure    Check Processes After Application Kill  application=${APPLICATION}
    Wait Time and Reason                   15  Wait before checking cells
    Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    Wait Time And Reason                   ${WAIT_FOR_ALARM}  Wait before checking alarm history
    Run Keyword And Continue On Failure    Check Alarm History  reset_alarms=${True}
    Run Keyword And Continue On Failure    Reset Alarms
    Run Keyword And Continue On Failure    Common Postconditions
    Run Keyword And Continue On Failure    Check If Rmods Were Reset  ${radio_uptimes}  rat_reset=${True}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Application kill site reset
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SYSLOG_PRINT}
    ...            ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}  ${STEP_NBR}
    ${STEP_NBR}=   Check If Step Smaller Or Same As Saved If Is Increase   ${STEP_NBR}
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword                            Common Preconditions
    Run Keyword And Continue On Failure    List All Applications
#    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword And Continue On Failure    Make SSH Log
    Run Keyword And Continue On Failure    Make BTS SSH Connection
    Run Keyword And Continue On Failure    Add Expected Alarm  severity=Warning  alarm_id=${ALARM_NBR_SITE_RESET}
                        ...                fault_id=${FAULT_NBR_SITE_RESET}
                        ...                fault_name=${FAULT_NAME_SITE_RESET}
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
# This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure    Check If Fault 4590 Should Be Allowed
    ${PRE_COUNTER}=    Get Restart Counter
    ${VIRTUAL_NODE_PIDS}=    Get Virtual Pids    CentralCPlane
    Print Step Text    ${STEP_NBR}.1  Get pid of ${APPLICATION}
    ${pid}=   Get Virtual Pid Of Application    ${APPLICATION}    ${VIRTUAL_NODE_PIDS}
    ${radio_uptimes}=                      Check Rmod Uptimes
    Print Step Text    ${STEP_NBR}.2  Kill ${APPLICATION} -application and expect Site autonomous reset
    Run Keyword And Continue On Failure    Kill Application      ${pid}    ${APPLICATION}
    Run Keyword And Continue On Failure    Close BTS SSH Connection
#   Check Site disconnection & reconnection after fault generation
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection  disconnection=${True}
    ...                                    time_to_wait=${300}  level_in_error=warning
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection
    ...                                    time_to_wait=${600}  level_in_error=warning
    Run Keyword And Continue On Failure    Check If Admin Connection Available    360
    Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure    Check Processes After Application Kill  application=${APPLICATION}
    ${POST_COUNTER}=    Get Restart Counter
    Run Keyword And Continue On Failure    Compare Counter Values    ${PRE_COUNTER}    ${POST_COUNTER}
    Print Step Text    ${STEP_NBR}.4  Check syslog prints
    Run Keyword And Continue On Failure    Check If Syslog Print Is Found  ${SYSLOG_PRINT}
#    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    Run Keyword And Continue On Failure    Common Postconditions
    Run Keyword And Continue On Failure    Check If Rmods Were Reset  ${radio_uptimes}
# Reset alarms after common post conditions check
    Run Keyword And Continue On Failure    Reset Alarms
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Application kill internal reset
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}
    ...            ${FAULT_NAME_INTERNAL_RESET}  ${ALARM_NBR_INTERNAL_RESET}  ${FAULT_NBR_INTERNAL_RESET}  ${STEP_NBR}
    ${STEP_NBR}=   Check If Step Smaller Or Same As Saved If Is Increase   ${STEP_NBR}
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword                            Common Preconditions
    Run Keyword And Continue On Failure    List All Applications
#    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword And Continue On Failure    Make SSH Log
    Run Keyword And Continue On Failure    Make BTS SSH Connection
    Run Keyword And Continue On Failure    Add Expected Alarm  severity=Warning  alarm_id=${ALARM_NBR_INTERNAL_RESET}
                        ...                fault_id=${FAULT_NBR_INTERNAL_RESET}
                        ...                fault_name=${FAULT_NAME_INTERNAL_RESET}
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
# This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure    Check If Fault 4590 Should Be Allowed
    Print Step Text    ${STEP_NBR}.1  Get pid of ${APPLICATION}
    ${VIRTUAL_NODE_PIDS}=    Get Virtual Pids    DistributedCPlane    ${UNIT}    selected_sw_node=${SW_NODE}
    ${pid}=   Get Virtual Pid Of Application    ${APPLICATION}    ${VIRTUAL_NODE_PIDS}
    Run Keyword And Continue On Failure    Check Rmod Uptimes
    Print Step Text    ${STEP_NBR}.2  Kill ${APPLICATION} -application and expect BTS internal autonomous reset
    Run Keyword And Continue On Failure    Kill Application    ${pid}    ${APPLICATION}
    Run Keyword And Continue On Failure    Close BTS SSH Connection
    Print Step Text    ${STEP_NBR}.3  Check BTS internal autonomous reset alarm after fault generation
    Run Keyword And Continue On Failure    Check Expected Alarms  wait_active_timeout=300
    Run Keyword And Continue On Failure    Check Processes After Application Kill  application=${APPLICATION}
    Wait Time and Reason                   15  Wait before checking cells
    Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure    Check Rmod Uptimes
#    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    Run Keyword And Continue On Failure    Common Postconditions
# reset alarms after common post conditions check
    Run Keyword And Continue On Failure    Reset Alarms
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Kill DistributedCPlane application from bbmod internal autonomous reset
    [Arguments]     ${WAIT_FOR_CELLS_UP}   ${WAIT_FOR_ALARM}  ${APPLICATION}  ${BBMOD}  ${SYSLOG_LIST}
    ...             ${UNALLOWED_SYSLOGS}  ${WAIT_FOR_RECO_COUNTER_CLEAR}
    ${bbmod_obj}=        Get Bbmod Object From User Given Values    ${BBMOD}
    ${bbmod_name}=       Get Values From Object                     ${bbmod_obj}    name
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword If              '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure
      ...                       Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text      ${0}   Common Preconditions    automatic=${True}
    Run Keyword                 Common Preconditions
    Run Keyword And Continue On Failure    List All Applications
    Run Keyword And Continue On Failure    Make SSH Log
    Run Keyword And Continue On Failure    Make BTS SSH Connection
    Run Keyword And Continue On Failure    Add Expected Alarm  severity=Warning  alarm_id=7101    fault_id=4383
                        ...                fault_name=Internal BTS processes autonomous reset as recovery action
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
# This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure    Check If Fault 4590 Should Be Allowed
    Run Keyword And Continue On Failure    Check Rmod Uptimes
    Print Step Text     ${1}  Get pid of ${APPLICATION} on DistributedCPlane of ${bbmod_name}    automatic=${True}
    IF   ${SELECT_ALWAYS_SAME_SW_NODE}
        ${S_N}=  Get Virtual Sw Node  DistributedCPlane  ${bbmod_name}
        Set Suite Variable   ${SW_NODE}   ${S_N}
        ${VIRTUAL_NODE_PIDS}=    Get Virtual Pids    DistributedCPlane    unit=${bbmod_obj}   selected_sw_node=${SW_NODE}
    ELSE
        ${VIRTUAL_NODE_PIDS}=    Get Virtual Pids    DistributedCPlane    unit=${bbmod_obj}
    END
    ${pid}=   Get Virtual Pid Of Application    ${APPLICATION}    ${VIRTUAL_NODE_PIDS}
    Print Step Text     ${2}  Kill ${APPLICATION} -application and expect BTS internal autonomous reset    automatic=${True}
    Run Keyword And Continue On Failure    Kill Application    ${pid}    ${APPLICATION}    chosen_unit
    Run Keyword And Continue On Failure    Close BTS SSH Connection
    Print Step Text     ${3}  Check BTS internal autonomous reset alarm after fault generation    automatic=${True}
    Run Keyword And Continue On Failure    Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARM}
    Run Keyword And Continue On Failure    Check Processes After Application Kill  application=${APPLICATION}
    Wait Time and Reason                   15  Wait before checking cells
    Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure    Check Rmod Uptimes
    Run Keyword If      '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword If      '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    Print Step Text     ${4}  Common Postconditions    automatic=${True}
    Run Keyword And Continue On Failure    Common Postconditions
    # Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
    Run Keyword If      '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure    Site reset cleaner
    ...                 ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${5}
    Run Keyword And Continue On Failure    Reset Alarms
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Virtual Application kill RAT reset
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}
    ...            ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${STEP_NBR}
    ${STEP_NBR}=   Check If Step Smaller Or Same As Saved If Is Increase   ${STEP_NBR}
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword                            Common Preconditions
    Run Keyword And Continue On Failure    List All Applications
#    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword And Continue On Failure    Make SSH Log
    Run Keyword And Continue On Failure    Make BTS SSH Connection
    Run Keyword And Continue On Failure    Add Expected Alarm  severity=Warning  alarm_id=${ALARM_NBR_RAT_RESET}
                        ...                fault_id=${FAULT_NBR_RAT_RESET}
                        ...                fault_name=${FAULT_NAME_RAT_RESET}
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
# This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure    Check If Fault 4590 Should Be Allowed
    Run Keyword And Continue On Failure    Check Rmod Uptimes
    Print Step Text    ${STEP_NBR}.1  Get pid of ${APPLICATION}
    ${VIRTUAL_NODE_PIDS}=    Get Virtual Pids    DistributedCPlane    ${UNIT}    selected_sw_node=${SW_NODE}
    ${pid}=   Get Virtual Pid Of Application    ${APPLICATION}    ${VIRTUAL_NODE_PIDS}
    Print Step Text    ${STEP_NBR}.2  Kill ${APPLICATION} -application and expect RAT autonomous reset as recovery action
    IF  'BBMOD' in '${UNIT}' or 'SMOD2' in '${UNIT}'
        Run Keyword And Continue On Failure    Kill Application      ${pid}    ${APPLICATION}   alias=chosen_unit
    ELSE
        Run Keyword And Continue On Failure    Kill Application      ${pid}    ${APPLICATION}
    END
    Run Keyword And Continue On Failure    Close BTS SSH Connection
    Print Step Text    ${STEP_NBR}.3  Check RAT autonomous reset as recovery action alarm after fault generation
    Run Keyword And Continue On Failure    Check Expected Alarms  wait_active_timeout=300
    Run Keyword And Continue On Failure    Check Processes After Application Kill  application=${APPLICATION}
    Wait Time and Reason                   15  Wait before checking cells
    Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure    Check Rmod Uptimes
#    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    Run Keyword And Continue On Failure    Common Postconditions
# reset alarms after common post conditions check
    Run Keyword And Continue On Failure    Reset Alarms
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Virtual Application kill site reset
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}
    ...            ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}  ${STEP_NBR}
    ${STEP_NBR}=   Check If Step Smaller Or Same As Saved If Is Increase   ${STEP_NBR}
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword                            Common Preconditions
    Run Keyword And Continue On Failure    List All Applications
#    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword And Continue On Failure    Make SSH Log
    Run Keyword And Continue On Failure    Make BTS SSH Connection
    Run Keyword And Continue On Failure    Add Expected Alarm  severity=Warning  alarm_id=${ALARM_NBR_SITE_RESET}
                        ...                fault_id=${FAULT_NBR_SITE_RESET}
                        ...                fault_name=${FAULT_NAME_SITE_RESET}
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
# This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure    Check If Fault 4590 Should Be Allowed
    ${PRE_COUNTER}=    Get Restart Counter
    Run Keyword And Continue On Failure    Check Rmod Uptimes
    Print Step Text    ${STEP_NBR}.1  Get pid of ${APPLICATION}
    ${VIRTUAL_NODE_PIDS}=    Get Virtual Pids    DistributedCPlane    ${UNIT}    selected_sw_node=${SW_NODE}
    ${pid}=   Get Virtual Pid Of Application    ${APPLICATION}    ${VIRTUAL_NODE_PIDS}
    Print Step Text    ${STEP_NBR}.2  Kill ${APPLICATION} -application and expect Site autonomous reset alarm
    Run Keyword And Continue On Failure    Kill Application    ${pid}    ${APPLICATION}
    Run Keyword And Continue On Failure    Close BTS SSH Connection
    Print Step Text    ${STEP_NBR}.3  Check Site autonomous reset alarm after fault generation
#   Check Site disconnection & reconnection after fault generation
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection  disconnection=${True}
    ...                                    time_to_wait=${300}  level_in_error=warning
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection
    ...                                    time_to_wait=${600}  level_in_error=warning
    Run Keyword And Continue On Failure    Check If Admin Connection Available    360
    #Wait Time And Reason                   ${WAIT_FOR_ALARM}  Wait before checking alarm history
    #Run Keyword And Continue On Failure    Check Alarm History  reset_alarms=True
    Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure    Check Processes After Application Kill  application=${APPLICATION}
    Run Keyword And Continue On Failure    Check Rmod Uptimes
    ${POST_COUNTER}=    Get Restart Counter
    Run Keyword And Continue On Failure    Compare Counter Values    ${PRE_COUNTER}    ${POST_COUNTER}
#    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    Run Keyword And Continue On Failure    Common Postconditions
# reset alarms after postconditions check
    Run Keyword And Continue On Failure    Reset Alarms
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Application kill TRS site reset
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SYSLOG_PRINT}
    ...            ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}  ${STEP_NBR}
    ${STEP_NBR}=   Check If Step Smaller Or Same As Saved If Is Increase   ${STEP_NBR}
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword                            Common Preconditions
    Run Keyword And Continue On Failure    List All Applications
#    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword And Continue On Failure    Make SSH Log
    Run Keyword And Continue On Failure    Make BTS SSH Connection
    Run Keyword And Continue On Failure    Add Expected Alarm  severity=Warning  alarm_id=${ALARM_NBR_SITE_RESET}
                        ...                fault_id=${FAULT_NBR_SITE_RESET}
                        ...                fault_name=${FAULT_NAME_SITE_RESET}
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
# This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure    Check If Fault 4590 Should Be Allowed
    ${PRE_COUNTER}=    Get Restart Counter
    ${rmod_uptimes}=   Check Rmod Uptimes
    Print Step Text    2  Get pid of ${APPLICATION}
    ${pid}=   Find Real Application Pid    ${APPLICATION}
    Print Step Text    ${STEP_NBR}.2  Kill ${APPLICATION} -application and expect Site autonomous reset
    Run Keyword And Continue On Failure    Kill Application      ${pid}    ${APPLICATION}
    Print Step Text    ${STEP_NBR}.3  Check Site autonomous reset alarm after fault generation
#   Check Site disconnection & reconnection after fault generation
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection  disconnection=${True}
    ...                                    time_to_wait=${300}  level_in_error=warning
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection
    ...                                    time_to_wait=${600}  level_in_error=warning
    Run Keyword And Continue On Failure    Check If Admin Connection Available    360
    #Wait Time And Reason                   ${WAIT_FOR_ALARM}  Wait before checking alarm history
    #Run Keyword And Continue On Failure    Check Alarm History  reset_alarms=True
    Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure    Close BTS SSH Connection
    Run Keyword And Continue On Failure    Check Processes After Application Kill  application=${APPLICATION}
    Run Keyword And Continue On Failure    Check If Rmods Were Reset  ${rmod_uptimes}
    ${POST_COUNTER}=    Get Restart Counter
    Run Keyword And Continue On Failure    Compare Counter Values    ${PRE_COUNTER}    ${POST_COUNTER}
    Print Step Text    ${STEP_NBR}.4  Check syslog prints
    Run Keyword And Continue On Failure    Check If Syslog Print Is Found  ${SYSLOG_PRINT}
#    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    Run Keyword And Continue On Failure    Common Postconditions
# reset alarms after postconditions check
    Run Keyword And Continue On Failure    Reset Alarms
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Application kill alarm active
    [Arguments]    ${APPLICATION}  ${WAIT_FOR_ALARM}
    ...            ${FAULT_NAME_END}  ${ALARM_NBR_END}  ${FAULT_NBR_END}  ${STEP_NBR}
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword                            Common Preconditions
    Run Keyword And Continue On Failure    List All Applications
#    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword And Continue On Failure    Make SSH Log
    Run Keyword And Continue On Failure    Make BTS SSH Connection
    Run Keyword And Continue On Failure    Add Expected Alarm  severity=Critical  alarm_id=${ALARM_NBR_END}  fault_id=${FAULT_NBR_END}
                        ...                fault_name=${FAULT_NAME_END}
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
# This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure    Check If Fault 4590 Should Be Allowed
    Run Keyword And Continue On Failure    Check Rmod Uptimes
    ${VIRTUAL_NODE_PIDS}=    Get Virtual Pids    CentralCPlane
    Print Step Text    ${STEP_NBR}.1  Get pid of ${APPLICATION}
    ${pid}=   Get Virtual Pid Of Application    ${APPLICATION}    ${VIRTUAL_NODE_PIDS}
    Print Step Text    ${STEP_NBR}.2  Kill ${APPLICATION} -application and NO autonomous reset alarm active
    Run Keyword And Continue On Failure    Kill Application      ${pid}    ${APPLICATION}
    Run Keyword And Continue On Failure    Close BTS SSH Connection
    Print Step Text    ${STEP_NBR}.3  Check alarms after fault generation
    Run Keyword And Continue On Failure    Check Expected Alarms  wait_active_timeout=360
    Run Keyword And Continue On Failure    Check Processes After Application Kill  application=${APPLICATION}
    Print Step Text    ${STEP_NBR}.4  Check if there are disabled cells
    Run Keyword And Continue On Failure    Get Faulty Cells
    Wait Time And Reason                   ${WAIT_FOR_ALARM}  Wait before checking alarm history
    Run Keyword And Continue On Failure    Check Rmod Uptimes
    Run Keyword And Continue On Failure    Check Alarm History  reset_alarms=True
    Run Keyword And Continue On Failure    Reset Alarms
#    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Application kill virtual alarm active
    [Arguments]    ${APPLICATION}  ${SW_NODE}  ${UNIT}    ${WAIT_FOR_ALARM}
    ...            ${FAULT_NAME_END}  ${FAULT_NBR_END}  ${STEP_NBR}  ${CHOSEN_UNIT}
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword                            Common Preconditions
    Run Keyword And Continue On Failure    List All Applications
#    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword And Continue On Failure    Make SSH Log
    Run Keyword And Continue On Failure    Make BTS SSH Connection

    Print Step Text                        ${STEP_NBR}.1  Get pid of ${APPLICATION}
    ${VIRTUAL_NODE_PIDS}=                  Get Virtual Pids  DistributedCPlane    ${UNIT}    selected_sw_node=${SW_NODE}
    ${pid}=                                Get Virtual Pid Of Application    ${APPLICATION}    ${VIRTUAL_NODE_PIDS}
    ${alarm_id}=                           Get Alarm ID Based On SW Node  ${SW_NODE}
    ${faulty_cells}=                       Get Cell IDs Of Virtual Node       ${SW_NODE}
    Run Keyword And Continue On Failure    Check Rmod Uptimes
    Run Keyword And Continue On Failure    Add Expected Alarm  severity=Critical  alarm_id=${alarm_id}
                        ...                fault_id=${FAULT_NBR_END}  fault_name=${FAULT_NAME_END}
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
# This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure    Check If Fault 4590 Should Be Allowed
    Print Step Text                        ${STEP_NBR}.2  Kill ${APPLICATION} -application and NO autonomous reset, alarm active
    IF  ${CHOSEN_UNIT}
        Run Keyword And Continue On Failure    Kill Application      ${pid}    ${APPLICATION}  chosen_unit
    ELSE
        Run Keyword And Continue On Failure    Kill Application      ${pid}    ${APPLICATION}
    END
    Run Keyword And Continue On Failure    Close BTS SSH Connection
    Print Step Text                        ${STEP_NBR}.3  Check alarms after fault generation
    Run Keyword And Continue On Failure    Check Expected Alarms  wait_active_timeout=360
    Run Keyword And Continue On Failure    Check Processes After Application Kill  application=${APPLICATION}
    Print Step Text                        ${STEP_NBR}.4  Check if there are disabled cells
    # Using wait for cells faulty instead of checking the cell states only once due to
    # There being a 5 second delay between BTS data and AdminCLI
    Run Keyword And Continue On Failure    Wait For Cells Faulty  time_limit=30  cells_to_be_faulty=${faulty_cells}
    Run Keyword And Continue On Failure    Check Rmod Uptimes
    Wait Time And Reason                   ${WAIT_FOR_ALARM}  Wait before checking alarm history
    Run Keyword And Continue On Failure    Check Alarm History  reset_alarms=True
    Run Keyword And Continue On Failure    Reset Alarms
#    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Application kill TRS alarm active
    [Arguments]    ${APPLICATION}    ${WAIT_FOR_ALARM}
    ...            ${FAULT_NAME_END}  ${ALARM_NBR_END}  ${FAULT_NBR_END}  ${STEP_NBR}
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword                            Common Preconditions
    Run Keyword And Continue On Failure    List All Applications
#    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword And Continue On Failure    Make SSH Log
    Run Keyword And Continue On Failure    Make BTS SSH Connection
    Run Keyword And Continue On Failure    Add Expected Alarm  severity=Critical  alarm_id=${ALARM_NBR_END}  fault_id=${FAULT_NBR_END}
                        ...                fault_name=${FAULT_NAME_END}
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
    Print Step Text    2  Get pid of ${APPLICATION}
    ${pid}=   Find Real Application Pid    ${APPLICATION}
    Print Step Text    ${STEP_NBR}.2  Kill ${APPLICATION} -application and NO autonomous reset alarm active
    Run Keyword And Continue On Failure    Kill Application      ${pid}    ${APPLICATION}
    Run Keyword And Continue On Failure    Close BTS SSH Connection
    Print Step Text    ${STEP_NBR}.3  Check alarms after fault generation
    Run Keyword And Continue On Failure    Check Expected Alarms  wait_active_timeout=360
    Run Keyword And Continue On Failure    Check Processes After Application Kill  application=${APPLICATION}
    Print Step Text    ${STEP_NBR}.4  Check if there are disabled cells
    Run Keyword And Continue On Failure    Get Faulty Cells
    Wait Time And Reason                   ${WAIT_FOR_ALARM}  Wait before checking alarm history
    Run Keyword And Continue On Failure    Check Alarm History  reset_alarms=True
    Run Keyword And Continue On Failure    Reset Alarms
#    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

# Test scenario ending
Site reset cleaner
    [Arguments]   ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${STEP_NBR}
    Print Text To Eventlog               Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure  Check If Fault 61675 Should Be Allowed
    Run Keyword And Continue On Failure  Run Keyword If  '${KW_SUCCESS}' == '${False}'  Get Snapshot And Ims Log
    ...                                  extra_name=after_failure
    Print Step Text  ${STEP_NBR}.1  Do site reset as a cleaning step and after that wait ${WAIT_FOR_RECO_COUNTER_CLEAR} seconds
    ${keyword_success}=    Run Keyword and Return Status  Reset Site  timeout=${600}  detailed_output=True
    #   Check Site disconnection & reconnection reset, Reset site wait for reconnection if not asked otherwise
#    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection  disconnection=${True}
#    ...                                    time_to_wait=${300}  level_in_error=warning
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection
    ...                                    time_to_wait=${600}  level_in_error=warning
    Run Keyword And Continue On Failure    Check If Admin Connection Available    360
    ${keyword_success2}=   Run Keyword and Return Status  Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    ${KW_S}=               boolean_and_operation  ${keyword_success}    ${keyword_success2}
    Wait Time And Reason   ${WAIT_FOR_RECO_COUNTER_CLEAR}  before doing another test for reset counter to be cleared
    Print Step Text        ${STEP_NBR}.2  Check Common post conditions
    ${keyword_success}=    Run Keyword and Return Status   Common Postconditions
    ${KW_S}=               boolean_and_operation  ${KW_S}  ${keyword_success}
    Run Keyword If         '${KW_S}' == '${False}'  Set Suite Variable  ${KW_SUCCESS}    ${False}
    # In failing tests collecting of logs will be done so this is needed only if the test is pass.
    # This snapshot collection and deletion can be prevented with setting variable ${SNAPSHOT_D} to False
    Run Keyword If  '${KW_SUCCESS}' == '${True}' and '${SNAPSHOT_D}' == '${True}'  Get Snapshot And Delete It
    Run Keyword If  '${KW_SUCCESS}' == '${False}'  Fail  Site reset cleaner step failed
    [Teardown]       Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

RAT autonomous reset x3 and site reset x1
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${WAIT_FOR_ALARM}
        ...    ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${STEP}
        ...    ${SYSLOG_PRINT}  ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
    ${END_STEP}=    Addition  ${STEP}  3
# 3x RAT autonomous reset
    FOR    ${index}    IN RANGE    ${STEP}    ${END_STEP}

        Run Keyword If  '${KW_SUCCESS}' == '${True}'   Application kill rat reset  ${WAIT_FOR_CELLS_UP}  ${APPLICATION}
        ...  ${WAIT_FOR_ALARM}  ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${STEP}
        ${STEP}=    Addition  ${STEP}  1
    END
# 1x Site autonomous reset
#    ${STEP}=    Addition  ${STEP}  1     # this is already increased in previous for loop
    Run Keyword If  '${KW_SUCCESS}' == '${True}'   Application kill site reset    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}
    ...  ${SYSLOG_PRINT}  ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}  ${END_STEP}

Internal BTS process autonomous reset x3 and RAT autonomous reset x3
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}    ${STEP}
    ...            ${FAULT_NAME_INTERNAL_RESET}  ${ALARM_NBR_INTERNAL_RESET}  ${FAULT_NBR_INTERNAL_RESET}
    ...            ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}
# Internal BTS process autonomous reset x3
    ${END_STEP}=    Addition  ${STEP}  3
    FOR    ${index}    IN RANGE    ${STEP}    ${END_STEP}
        Run Keyword If  '${KW_SUCCESS}' == '${True}'   Application kill internal reset  ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}
    ...            ${FAULT_NAME_INTERNAL_RESET}  ${ALARM_NBR_INTERNAL_RESET}  ${FAULT_NBR_INTERNAL_RESET}  ${index}
    END
    ${END_STEP2}=   Addition  ${END_STEP}  3
# Virtual RAT autonomous reset x3
    FOR    ${index2}    IN RANGE    ${END_STEP}    ${END_STEP2}
        Run Keyword If  '${KW_SUCCESS}' == '${True}'   Virtual Application kill RAT reset  ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}
    ...            ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${index2}
    END

Internal BTS process autonomous reset x3 RAT autonomous reset x3 and site reset x1
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}    ${STEP}
    ...            ${FAULT_NAME_INTERNAL_RESET}  ${ALARM_NBR_INTERNAL_RESET}  ${FAULT_NBR_INTERNAL_RESET}
    ...            ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}
    ...            ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword If  '${KW_SUCCESS}' == '${True}'   Internal BTS process autonomous reset x3 and RAT autonomous reset x3
    ...    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}    ${STEP}
    ...    ${FAULT_NAME_INTERNAL_RESET}  ${ALARM_NBR_INTERNAL_RESET}  ${FAULT_NBR_INTERNAL_RESET}
    ...    ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}
    ${STEP}=    Addition  ${STEP}  6
# Virtual Site autonomous reset x 1
    Run Keyword If  '${KW_SUCCESS}' == '${True}'   Virtual Application kill site reset    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}
    ...  ${SW_NODE}  ${UNIT}  ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}  ${STEP}

Kill application from CentralCPlane rat and site resets
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...        ${WAIT_FOR_ALARM}   ${SYSLOG_PRINT}  ${UNALLOWED_SYSLOGS}
        ...        ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}
        ...        ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
        ...        ${FAULT_NAME_END}  ${ALARM_NBR_END}  ${FAULT_NBR_END}
    Set Suite Variable    ${WARN_FROM_COUNTER}   ${False}
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword And Continue On Failure    Common Preconditions
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
# start br0 ssh commands, if given in test suite
    Run Keyword And Continue On Failure    Start Logs And Journals By Ssh
# Do 3 times: 3x RAT autonomous reset and 1x site reset
    Run Keyword If  '${KW_SUCCESS}' == '${True}'   RAT autonomous reset x3 and site reset x1    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}
        ...    ${WAIT_FOR_ALARM}  ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${1}
        ...    ${SYSLOG_PRINT}  ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
# get bro0 logs after site reset
    Run Keyword And Continue On Failure    Get Logs And Journal By Scp  extra_name=1_site_reset
# start br0 ssh commands, if given in test suite
    Run Keyword And Continue On Failure    Start Logs And Journals By Ssh
    Run Keyword If  '${KW_SUCCESS}' == '${True}'   RAT autonomous reset x3 and site reset x1    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}
        ...    ${WAIT_FOR_ALARM}  ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${5}
        ...    ${SYSLOG_PRINT}  ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
# get bro0 logs after site reset
    Run Keyword And Continue On Failure    Get Logs And Journal By Scp  extra_name=2_site_reset
# start br0 ssh commands, if given in test suite
    Run Keyword And Continue On Failure    Start Logs And Journals By Ssh
    Run Keyword If  '${KW_SUCCESS}' == '${True}'   RAT autonomous reset x3 and site reset x1    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}
        ...    ${WAIT_FOR_ALARM}  ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${9}
        ...    ${SYSLOG_PRINT}  ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
# get bro0 logs after site reset
    Run Keyword And Continue On Failure    Get Logs And Journal By Scp  extra_name=3_site_reset
# start br0 ssh commands, if given in test suite
    Run Keyword And Continue On Failure    Start Logs And Journals By Ssh
# 3x RAT autonomous reset
    FOR    ${index}    IN RANGE    13    16
        Run Keyword If  '${KW_SUCCESS}' == '${True}'    Application kill rat reset  ${WAIT_FOR_CELLS_UP}  ${APPLICATION}
        ...  ${WAIT_FOR_ALARM}  ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${index}
    END
# All autonomous reset are executed -> alarm activated
    Run Keyword If  '${KW_SUCCESS}' == '${True}'  Application kill alarm active  ${APPLICATION}   ${WAIT_FOR_ALARM}
        ...    ${FAULT_NAME_END}    ${ALARM_NBR_END}  ${FAULT_NBR_END}  ${16}
# get bro0 logs alarm activation
    Run Keyword And Continue On Failure    Get Logs And Journal By Scp  extra_name=alarms_activated
# Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
    Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${17}
    Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Kill application from CentralCPlane 4G rat resets
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...        ${WAIT_FOR_ALARM}  ${UNALLOWED_SYSLOGS}
        ...        ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}
        ...        ${FAULT_NAME_END}  ${ALARM_NBR_END}  ${FAULT_NBR_END}
    Set Suite Variable    ${WARN_FROM_COUNTER}   ${False}
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword And Continue On Failure    Common Preconditions
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
# 3x RAT autonomous reset
    FOR    ${index}    IN RANGE    13    16
        Run Keyword If  '${KW_SUCCESS}' == '${True}'    Application kill rat reset  ${WAIT_FOR_CELLS_UP}  ${APPLICATION}
        ...  ${WAIT_FOR_ALARM}  ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${index}
    END
# All autonomous reset are executed -> alarm activated
    Run Keyword If  '${KW_SUCCESS}' == '${True}'  Application kill alarm active  ${APPLICATION}   ${WAIT_FOR_ALARM}
        ...    ${FAULT_NAME_END}    ${ALARM_NBR_END}  ${FAULT_NBR_END}  ${16}
# get bro0 logs alarm activation
    Run Keyword And Continue On Failure    Get Logs And Journal By Scp  extra_name=alarms_activated
# Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
    Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${17}
    Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Kill application from DistributedCPlane internal rat and site resets
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}  ${WAIT_FOR_ALARM}  ${SYSLOG_LIST}
        ...  ${UNALLOWED_SYSLOGS}  ${FAULT_NAME_INTERNAL_RESET}  ${ALARM_NBR_INTERNAL_RESET}  ${FAULT_NBR_INTERNAL_RESET}
        ...  ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}
        ...  ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
        ...  ${FAULT_NAME_END}  ${FAULT_NBR_END}    ${WAIT_FOR_RECO_COUNTER_CLEAR}
    Set Suite Variable    ${WARN_FROM_COUNTER}   ${False}
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword And Continue On Failure    Common Preconditions
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
# Do 3 times: 3x Internal BTS process autonomous reset 3x RAT autonomous reset and 1x site reset
    Run Keyword If  '${KW_SUCCESS}' == '${True}'   Internal BTS process autonomous reset x3 RAT autonomous reset x3 and site reset x1
        ...    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}    ${1}
        ...    ${FAULT_NAME_INTERNAL_RESET}  ${ALARM_NBR_INTERNAL_RESET}  ${FAULT_NBR_INTERNAL_RESET}
        ...    ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}
        ...    ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
    Run Keyword If  '${KW_SUCCESS}' == '${True}'   Internal BTS process autonomous reset x3 RAT autonomous reset x3 and site reset x1
        ...    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}    ${8}
        ...    ${FAULT_NAME_INTERNAL_RESET}  ${ALARM_NBR_INTERNAL_RESET}  ${FAULT_NBR_INTERNAL_RESET}
        ...    ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}
        ...    ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
    Run Keyword If  '${KW_SUCCESS}' == '${True}'   Internal BTS process autonomous reset x3 RAT autonomous reset x3 and site reset x1
        ...    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}    ${15}
        ...    ${FAULT_NAME_INTERNAL_RESET}  ${ALARM_NBR_INTERNAL_RESET}  ${FAULT_NBR_INTERNAL_RESET}
        ...    ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}
        ...    ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
# 3x Internal BTS process autonomous reset and 3x RAT autonomous reset
    Run Keyword If  '${KW_SUCCESS}' == '${True}'   Internal BTS process autonomous reset x3 and RAT autonomous reset x3
    ...    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}    ${22}
    ...    ${FAULT_NAME_INTERNAL_RESET}  ${ALARM_NBR_INTERNAL_RESET}  ${FAULT_NBR_INTERNAL_RESET}
    ...    ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}
# All autonomous reset are executed -> alarm activated
    Run Keyword If  '${KW_SUCCESS}' == '${True}'  Application kill virtual alarm active  ${APPLICATION}  ${SW_NODE}  ${UNIT}
    ...  ${WAIT_FOR_ALARM}  ${FAULT_NAME_END}  ${FAULT_NBR_END}  ${28}  ${False}

# Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
    Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${29}
    Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Kill application from DistributedCPlane internal resets and alarm active
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}  ${WAIT_FOR_ALARM}  ${SYSLOG_LIST}
        ...  ${UNALLOWED_SYSLOGS}  ${FAULT_NAME_INTERNAL_RESET}  ${ALARM_NBR_INTERNAL_RESET}  ${FAULT_NBR_INTERNAL_RESET}
        ...  ${FAULT_NAME_END}  ${FAULT_NBR_END}    ${WAIT_FOR_RECO_COUNTER_CLEAR}
    Set Suite Variable    ${WARN_FROM_COUNTER}   ${False}
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword And Continue On Failure    Common Preconditions
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
# Internal BTS process autonomous reset x3
    FOR    ${index}    IN RANGE    1    4
        Run Keyword If  '${KW_SUCCESS}' == '${True}'   Application kill internal reset  ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}
    ...            ${FAULT_NAME_INTERNAL_RESET}  ${ALARM_NBR_INTERNAL_RESET}  ${FAULT_NBR_INTERNAL_RESET}  ${index}
    END
# All autonomous reset are executed -> alarm activated
    Run Keyword If  '${KW_SUCCESS}' == '${True}'  Application kill virtual alarm active  ${APPLICATION}  ${SW_NODE}  ${UNIT}
    ...  ${WAIT_FOR_ALARM}  ${FAULT_NAME_END}  ${FAULT_NBR_END}  ${4}  ${False}
# Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
    Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${5}
    Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Kill trs application site reset x3 and alarm active
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SYSLOG_PRINT}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...  ${WAIT_FOR_ALARM}  ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
        ...  ${FAULT_NAME_END}  ${ALARM_NBR_END}  ${FAULT_NBR_END}    ${WAIT_FOR_RECO_COUNTER_CLEAR}
    Set Suite Variable    ${WARN_FROM_COUNTER}   ${False}
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword And Continue On Failure    Common Preconditions
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
# Internal BTS process autonomous reset x3
    FOR    ${index}    IN RANGE    1    4
        Run Keyword If  '${KW_SUCCESS}' == '${True}'   Application kill TRS site reset  ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SYSLOG_PRINT}
    ...            ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}  ${index}
    END
# All autonomous reset are executed -> alarm activated
    Run Keyword If  '${KW_SUCCESS}' == '${True}'  Application kill TRS alarm active  ${APPLICATION}    ${WAIT_FOR_ALARM}
    ...            ${FAULT_NAME_END}  ${ALARM_NBR_END}  ${FAULT_NBR_END}  ${4}
# Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
    Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${5}
    Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Kill application from BBMOD DistributedCPlane internal resets and alarm active
    [Arguments]  ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}  ${WAIT_FOR_ALARM}  ${SYSLOG_LIST}
        ...  ${UNALLOWED_SYSLOGS}  ${FAULT_NAME_END}  ${FAULT_NBR_END}    ${WAIT_FOR_RECO_COUNTER_CLEAR}
    ${result}=  BBMOD Checks For Application Kills  ${UNIT}
    IF  ${result}
        Set Suite Variable                     ${LOOPING_KW}    ${True}
        Run Keyword And Continue On Failure    Common Preconditions
        Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
        FOR    ${index}    IN RANGE    1    4
        Run Keyword If  '${KW_SUCCESS}' == '${True}'  Kill DistributedCPlane application from bbmod internal autonomous reset
        ...      ${WAIT_FOR_CELLS_UP}   ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SYSLOG_LIST}
        ...      ${UNALLOWED_SYSLOGS}  ${WAIT_FOR_RECO_COUNTER_CLEAR}
        END
        # All autonomous reset are executed -> alarm activated
        Run Keyword If  '${KW_SUCCESS}' == '${True}'  Application kill virtual alarm active  ${APPLICATION}  ${SW_NODE}  ${UNIT}
        ...  ${WAIT_FOR_ALARM}  ${FAULT_NAME_END}  ${FAULT_NBR_END}  ${4}  ${True}
        # Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
        Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${5}
        Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
        Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Recovery During MW for BBMOD
    [Arguments]  ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}  ${WAIT_FOR_ALARM}  ${SYSLOG_LIST}
        ...  ${UNALLOWED_SYSLOGS}  ${FAULT_NAME_END}  ${FAULT_NBR_END}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${USER_GIVEN_TIME}
        ...  ${WAIT_FOR_MW_ALARM}
    ${result}=  BBMOD Checks For Application Kills  ${UNIT}
    IF  ${result}
        Set Suite Variable                     ${LOOPING_KW}    ${True}
        ${BBMOD_OBJ}=                          Get Bbmod Object From User Given Values  ${UNIT}
        Run Keyword And Continue On Failure    Common Preconditions
        Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
        FOR    ${index}    IN RANGE    1    4
            Run Keyword If  '${KW_SUCCESS}' == '${True}'  Kill DistributedCPlane application from bbmod internal autonomous reset
            ...      ${WAIT_FOR_CELLS_UP}   ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SYSLOG_LIST}
            ...      ${UNALLOWED_SYSLOGS}  ${WAIT_FOR_RECO_COUNTER_CLEAR}
        END
        # All autonomous reset are executed -> alarm activated
        Run Keyword If  '${KW_SUCCESS}' == '${True}'  Application kill virtual alarm active  ${APPLICATION}  ${SW_NODE}  ${UNIT}
        ...  ${WAIT_FOR_ALARM}  ${FAULT_NAME_END}  ${FAULT_NBR_END}  ${4}  ${True}
        Run Keyword And Continue On Failure    Enable Maintenance Window    ${USER_GIVEN_TIME}
        Run Keyword And Continue On Failure    ALARMS.Add Allowed Alarm  fault_name=Baseband card autonomous reset as recovery action
        ...                                                        severity=Warning  alarm_id=7101  unit_path=${BBMOD_OBJ.unit_path}
        ...                                                        hw_path=${BBMOD_OBJ.hw_path}
#        ${CELLS_OF_BBMOD}=   Get Cells Of Bbmod   ${BBMOD_OBJ.name}
#        Run Keyword And Continue On Failure    Print Text To Eventlog
#        ...   Wait ${WAIT_FOR_MW_ALARM}s then wait max 30 minutes (value set to windowDuration) for cells to be up and running
        Run Keyword And Continue On Failure    Wait Time And Reason   sleep_time=${WAIT_FOR_MW_ALARM}   wait_reason=(WAIT_FOR_MW_ALARM)
#        Run Keyword And Continue On Failure    Check Expected Alarms  wait_active_timeout=${WAIT_FOR_MW_ALARM}
        Run Keyword And Continue On Failure    Wait For All Cells Up   1800
        Run Keyword And Continue On Failure    Check If Cell Down And No Active Alarm And Wait For Fault

        ${log_collection}=  Logs Should Be Collected
        IF  '${log_collection}' == '${True}'
            Run Keyword And Continue On Failure  Get Snapshot And Ims Log  info_text=Before site reset cleaner
            ...                                  extra_name=MW
        END

        Run Keyword And Continue On Failure    Disable Maintenance Window

        # Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
        Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${5}
        Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
        Run Keyword And Continue On Failure    Stop Background Syslog Print Search
        Run Keyword And Continue On Failure    Common Postconditions
    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Recovery During MW for BBMOD With Additional Fault
    [Arguments]  ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}  ${WAIT_FOR_ALARM}  ${SYSLOG_LIST}
        ...  ${UNALLOWED_SYSLOGS}  ${FAULT_NAME_END}  ${FAULT_NBR_END}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${USER_GIVEN_TIME}
        ...  ${WAIT_FOR_MW_ALARM}
    ${result}=  BBMOD Checks For Application Kills  ${UNIT}
    IF  ${result}
        Set Suite Variable                     ${LOOPING_KW}    ${True}
        ${BBMOD_OBJ}=                          Get Bbmod Object From User Given Values  ${UNIT}
        Run Keyword And Continue On Failure    Common Preconditions
        Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
        FOR    ${index}    IN RANGE    1    4
            Run Keyword If  '${KW_SUCCESS}' == '${True}'  Kill DistributedCPlane application from bbmod internal autonomous reset
            ...      ${WAIT_FOR_CELLS_UP}   ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SYSLOG_LIST}
            ...      ${UNALLOWED_SYSLOGS}  ${WAIT_FOR_RECO_COUNTER_CLEAR}
        END
        # All autonomous reset are executed -> alarm activated
        Run Keyword If  '${KW_SUCCESS}' == '${True}'  Application kill virtual alarm active  ${APPLICATION}  ${SW_NODE}  ${UNIT}
        ...  ${WAIT_FOR_ALARM}  ${FAULT_NAME_END}  ${FAULT_NBR_END}  ${4}  ${True}
        ${START_TIME}=                         Enable Maintenance Window    ${USER_GIVEN_TIME}
        Run Keyword And Continue On Failure    ALARMS.Add Allowed Alarm  fault_name=Baseband card autonomous reset as recovery action
        ...                                                        severity=Warning  alarm_id=7101  unit_path=${BBMOD_OBJ.unit_path}
        ...                                                        hw_path=${BBMOD_OBJ.hw_path}
        Run Keyword And Continue On Failure    Wait Time And Reason   sleep_time=${WAIT_FOR_MW_ALARM}   wait_reason=(WAIT_FOR_MW_ALARM)
        Run Keyword And Continue On Failure    Wait For All Cells Up   1800
        Run Keyword And Continue On Failure    Check If Cell Down And No Active Alarm And Wait For Fault
        Wait Time and Reason                   600  Wait before causing fault during MW
        Run Keyword If  '${KW_SUCCESS}' == '${True}'  Application kill virtual alarm active  ${APPLICATION}  ${SW_NODE}  ${UNIT}
        ...  ${WAIT_FOR_ALARM}  ${FAULT_NAME_END}  ${FAULT_NBR_END}  ${4}  ${True}
        ${log_collection}=  Logs Should Be Collected
        IF  '${log_collection}' == '${True}'
            Run Keyword And Continue On Failure  Get Snapshot And Ims Log  info_text=Before site reset cleaner
            ...                                  extra_name=MW
        END
        Run Keyword And Continue On Failure    Disable Maintenance Window And Wait  ${USER_GIVEN_TIME}  ${START_TIME}
        # Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
        Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${5}
        Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
        Run Keyword And Continue On Failure    Stop Background Syslog Print Search
        Run Keyword And Continue On Failure    Common Postconditions
    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Kill application from BBMOD DistributedCPlane internal resets RAT resets and alarm active
    [Arguments]  ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}  ${WAIT_FOR_ALARM}  ${SYSLOG_LIST}
        ...  ${UNALLOWED_SYSLOGS}  ${FAULT_NAME_END}  ${FAULT_NBR_END}    ${WAIT_FOR_RECO_COUNTER_CLEAR}
    [Documentation]    Do 3 times this scenario by killing DistributedCPlane application (UEC or CELLC) from BBMOD (kill application 3 times):
    ...                Internal BTS process autonomous reset
    ...                Do 3 times this scenario by killing DistributedCPlane application (UEC or CELLC) from BBMOD (kill application 3 times):
    ...                RAT autonomous reset
    ...                And lastly do this scenario by killing DistributedCPlane application (UEC or CELLC) from BBMOD (kill application 1 time):
    ...                All autonomous reset are executed -> alarm activated
    ${result}=  BBMOD Checks For Application Kills  ${UNIT}
    ${bbmod_obj}=     Get Bbmod Object From User Given Values    ${UNIT}   print_eventlog=${False}
    ${shared_bbmod}=  Bbmod Shares Resources To Different Cell Technologies   ${bbmod_obj.name}
    ${nr_in_env}=  BTS.Check If 5g Environment
    IF  ${nr_in_env}
        Run Keyword And Continue On Failure    ALARMS.Add Allowed Alarm    fault_id=7107
        ...                                    fault_name=Cell problem due to unavailability of associated links
    END
    IF  ${shared_bbmod}
        Run Keyword And Continue On Failure    ALARMS.Add Allowed Alarm    fault_id=7107
        ...                                    fault_name=Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    END
    IF  ${result}
        Set Suite Variable                     ${LOOPING_KW}    ${True}
        Run Keyword And Continue On Failure    Common Preconditions
        Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
        Print Text To Eventlog   Select always PID of same SW_NODE
        Set Suite Variable   ${SELECT_ALWAYS_SAME_SW_NODE}   ${True}
# Do 3 times: Internal BTS process autonomous reset
        FOR    ${index}    IN RANGE    1    4
            Run Keyword If  '${KW_SUCCESS}' == '${True}'   Kill DistributedCPlane application from bbmod internal autonomous reset
            ...      ${WAIT_FOR_CELLS_UP}   ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SYSLOG_LIST}
            ...      ${UNALLOWED_SYSLOGS}  ${WAIT_FOR_RECO_COUNTER_CLEAR}
        END
# Do 3 times: RAT autonomous reset as recovery action
        FOR    ${index2}    IN RANGE    1    4
            ${STEP}=   Get Test Step Value
            Run Keyword If  '${KW_SUCCESS}' == '${True}'   Virtual Application kill RAT reset   ${WAIT_FOR_CELLS_UP}  ${APPLICATION}
            ...   ${SW_NODE}   ${UNIT}   RAT autonomous reset as recovery action  ${7101}  ${4383}  ${STEP}
        END
# All autonomous reset are executed -> alarm activated
        Run Keyword If  '${KW_SUCCESS}' == '${True}'  Application kill virtual alarm active  ${APPLICATION}  ${SW_NODE}  ${UNIT}
        ...  ${WAIT_FOR_ALARM}  ${FAULT_NAME_END}  ${FAULT_NBR_END}  ${4}  ${True}
        # Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
        Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${5}
        Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
        Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Recovery During MW for SMOD
    # NOTE: This is used for DistributedCPlane
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}  ${WAIT_FOR_ALARM}  ${SYSLOG_LIST}
        ...  ${UNALLOWED_SYSLOGS}  ${FAULT_NAME_INTERNAL_RESET}  ${ALARM_NBR_INTERNAL_RESET}  ${FAULT_NBR_INTERNAL_RESET}
        ...  ${FAULT_NAME_END}  ${FAULT_NBR_END}    ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${USER_GIVEN_TIME}  ${WAIT_FOR_MW_ALARM}
    Set Suite Variable    ${WARN_FROM_COUNTER}   ${False}
    ${SMOD_UNIT_PATH}=                           Get Unit Path Of Smod
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword And Continue On Failure    Common Preconditions
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
# Internal BTS process autonomous reset x3
    FOR    ${index}    IN RANGE    1    4
        Run Keyword If  '${KW_SUCCESS}' == '${True}'   Application kill internal reset  ${WAIT_FOR_CELLS_UP}  ${APPLICATION}  ${SW_NODE}  ${UNIT}
    ...            ${FAULT_NAME_INTERNAL_RESET}  ${ALARM_NBR_INTERNAL_RESET}  ${FAULT_NBR_INTERNAL_RESET}  ${index}
    END
# All autonomous reset are executed -> alarm activated
    Run Keyword If  '${KW_SUCCESS}' == '${True}'  Application kill virtual alarm active  ${APPLICATION}  ${SW_NODE}  ${UNIT}
    ...  ${WAIT_FOR_ALARM}  ${FAULT_NAME_END}  ${FAULT_NBR_END}  ${4}  ${False}
    Run Keyword And Continue On Failure    Enable Maintenance Window    ${USER_GIVEN_TIME}
    Run Keyword And Continue On Failure    ALARMS.Add Allowed Alarm  fault_name=BTS site autonomous reset as recovery action
    ...                                                        severity=Warning  alarm_id=7101  unit_path=${SMOD_UNIT_PATH}
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection    disconnection=True  time_to_wait=3000
    Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_MW_ALARM}
    Run Keyword And Continue On Failure    Check Expected Alarms
    ${log_collection}=  Logs Should Be Collected
    IF  '${log_collection}' == '${True}'
        Run Keyword And Continue On Failure  Get Snapshot And Ims Log  info_text=Before site reset cleaner
        ...                                  extra_name=MW
    END

    Run Keyword And Continue On Failure    Disable Maintenance Window
# Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
    Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${5}
    Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Recovery During MW for SMOD CentralCPlane
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...        ${WAIT_FOR_ALARM}   ${SYSLOG_PRINT}  ${UNALLOWED_SYSLOGS}
        ...        ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}
        ...        ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
        ...        ${FAULT_NAME_END}  ${ALARM_NBR_END}  ${FAULT_NBR_END}  ${USER_GIVEN_TIME}  ${WAIT_FOR_MW_ALARM}
    Set Suite Variable    ${WARN_FROM_COUNTER}   ${False}
    ${SMOD_UNIT_PATH}=                           Get Unit Path Of Smod
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword And Continue On Failure    Common Preconditions
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
# Do 3 times: 3x RAT autonomous reset and 1x site reset
    Run Keyword If  '${KW_SUCCESS}' == '${True}'   RAT autonomous reset x3 and site reset x1    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}
        ...    ${WAIT_FOR_ALARM}  ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${1}
        ...    ${SYSLOG_PRINT}  ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
    Run Keyword If  '${KW_SUCCESS}' == '${True}'   RAT autonomous reset x3 and site reset x1    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}
        ...    ${WAIT_FOR_ALARM}  ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${5}
        ...    ${SYSLOG_PRINT}  ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
    Run Keyword If  '${KW_SUCCESS}' == '${True}'   RAT autonomous reset x3 and site reset x1    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}
        ...    ${WAIT_FOR_ALARM}  ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${9}
        ...    ${SYSLOG_PRINT}  ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
# 3x RAT autonomous reset
    FOR    ${index}    IN RANGE    13    16
        Run Keyword If  '${KW_SUCCESS}' == '${True}'    Application kill rat reset  ${WAIT_FOR_CELLS_UP}  ${APPLICATION}
        ...  ${WAIT_FOR_ALARM}  ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${index}
    END
# All autonomous reset are executed -> alarm activated
    Run Keyword If  '${KW_SUCCESS}' == '${True}'  Application kill alarm active  ${APPLICATION}   ${WAIT_FOR_ALARM}
        ...    ${FAULT_NAME_END}    ${ALARM_NBR_END}  ${FAULT_NBR_END}  ${16}

    Run Keyword And Continue On Failure    Enable Maintenance Window    ${USER_GIVEN_TIME}
    Run Keyword And Continue On Failure    ALARMS.Add Allowed Alarm  fault_name=BTS site autonomous reset as recovery action
    ...                                                        severity=Warning  alarm_id=7101  unit_path=${SMOD_UNIT_PATH}
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection    disconnection=True  time_to_wait=3000
    Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_MW_ALARM}
    Run Keyword And Continue On Failure    Check Expected Alarms
    ${log_collection}=  Logs Should Be Collected
    IF  '${log_collection}' == '${True}'
        Run Keyword And Continue On Failure  Get Snapshot And Ims Log  info_text=Before site reset cleaner
        ...                                  extra_name=MW
    END

    Run Keyword And Continue On Failure    Disable Maintenance Window
# Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
    Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${17}
    Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Recovery During MW for SMOD With Additional Fault CentralCPlane
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${APPLICATION}  ${SYSLOG_LIST}
        ...        ${WAIT_FOR_ALARM}   ${SYSLOG_PRINT}  ${UNALLOWED_SYSLOGS}
        ...        ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}
        ...        ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
        ...        ${FAULT_NAME_END}  ${ALARM_NBR_END}  ${FAULT_NBR_END}  ${USER_GIVEN_TIME}  ${WAIT_FOR_MW_ALARM}
    Set Suite Variable    ${WARN_FROM_COUNTER}   ${False}
    ${SMOD_UNIT_PATH}=                           Get Unit Path Of Smod
    Print Text To Eventlog                 Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure    Check If Fault 61675 Should Be Allowed
    Run Keyword And Continue On Failure    Common Preconditions
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
# Do 3 times: 3x RAT autonomous reset and 1x site reset
    Run Keyword If  '${KW_SUCCESS}' == '${True}'   RAT autonomous reset x3 and site reset x1    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}
        ...    ${WAIT_FOR_ALARM}  ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${1}
        ...    ${SYSLOG_PRINT}  ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
    Run Keyword If  '${KW_SUCCESS}' == '${True}'   RAT autonomous reset x3 and site reset x1    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}
        ...    ${WAIT_FOR_ALARM}  ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${5}
        ...    ${SYSLOG_PRINT}  ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
    Run Keyword If  '${KW_SUCCESS}' == '${True}'   RAT autonomous reset x3 and site reset x1    ${WAIT_FOR_CELLS_UP}  ${APPLICATION}
        ...    ${WAIT_FOR_ALARM}  ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${9}
        ...    ${SYSLOG_PRINT}  ${FAULT_NAME_SITE_RESET}  ${ALARM_NBR_SITE_RESET}  ${FAULT_NBR_SITE_RESET}
# 3x RAT autonomous reset
    FOR    ${index}    IN RANGE    13    16
        Run Keyword If  '${KW_SUCCESS}' == '${True}'    Application kill rat reset  ${WAIT_FOR_CELLS_UP}  ${APPLICATION}
        ...  ${WAIT_FOR_ALARM}  ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${index}
    END
# All autonomous reset are executed -> alarm activated
    Run Keyword If  '${KW_SUCCESS}' == '${True}'  Application kill alarm active  ${APPLICATION}   ${WAIT_FOR_ALARM}
        ...    ${FAULT_NAME_END}    ${ALARM_NBR_END}  ${FAULT_NBR_END}  ${16}

    ${START_TIME}=                         Enable Maintenance Window    ${USER_GIVEN_TIME}
    Run Keyword And Continue On Failure    ALARMS.Add Allowed Alarm  fault_name=BTS site autonomous reset as recovery action
    ...                                                        severity=Warning  alarm_id=7101  unit_path=${SMOD_UNIT_PATH}
    Run Keyword And Continue On Failure    Ping Ip Until Disconnection Or Reconnection    disconnection=True  time_to_wait=3000
    Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_MW_ALARM}
    Run Keyword And Continue On Failure    Check Expected Alarms
    Run Keyword and Continue On Failure    ALARMS.Reset Alarms
    # Cause same fault again
    # 3x RAT autonomous reset
        FOR    ${index}    IN RANGE    13    16
            Run Keyword If  '${KW_SUCCESS}' == '${True}'    Application kill rat reset  ${WAIT_FOR_CELLS_UP}  ${APPLICATION}
            ...  ${WAIT_FOR_ALARM}  ${FAULT_NAME_RAT_RESET}  ${ALARM_NBR_RAT_RESET}  ${FAULT_NBR_RAT_RESET}  ${index}
        END
    # All autonomous reset are executed -> alarm activated
    Run Keyword If  '${KW_SUCCESS}' == '${True}'  Application kill alarm active  ${APPLICATION}   ${WAIT_FOR_ALARM}
        ...    ${FAULT_NAME_END}    ${ALARM_NBR_END}  ${FAULT_NBR_END}  ${16}
    Run Keyword And Continue On Failure    Check Expected Alarms
    Run Keyword And Continue On Failure    Wait For Cells Faulty  600
    Run Keyword And Continue On Failure    Disable Maintenance Window And Wait  ${USER_GIVEN_TIME}  ${START_TIME}
    ${log_collection}=  Logs Should Be Collected
    IF  '${log_collection}' == '${True}'
        Run Keyword And Continue On Failure  Get Snapshot And Ims Log  info_text=Before site reset cleaner
        ...                                  extra_name=MW
    END
# Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
    Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${17}
    Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}
