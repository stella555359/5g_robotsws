*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections

*** Variables ***
${LOOPING_KW}                 ${False}
${ADDITIONAL_ALARM_INFO}      RU connection was lost in runtime.RU power loss
# for radio:
&{state_dict_unlock}          administrativeState=Unlocked  operationalState=enabled
&{state_dict_lock}            administrativeState=Locked  operationalState=disabled
&{state_dict_lock_enabled}    administrativeState=Locked  operationalState=enabled
&{state_dict_disabled}        administrativeState=Unlocked  operationalState=disabled
# for cells
&{state_dict_cell_enabled}    operationalState=enabled
&{state_dict_cell_disabled}   operationalState=disabled
${WAIT_AFTER_SITE_RESET}      900
${WAIT_ALARM_IN_STARTUP}      1200
@{ALL_TEST_TYPES}
...    Hot Remove Insert
...    Hot Remove Insert With Reset
...    Hot Remove Insert With Lock
...    Hot Remove During Startup


*** Keywords ***
Hot Remove Insert
    [Documentation]    Switch power of radio module off, check that units and cells have expected states and expected alarms are raised,
    ...                switch power of radio module on and check that radio and cells have expected states and no unexpected alarms.
    [Arguments]    ${RMOD_TO_TEST}  ${WAIT_BEFORE_ALARM_CHECK}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}
    ...            ${UNALLOWED_SYSLOGS}

    Run Keyword If              '${LOOPING_KW}' == '${False}'  Run Keyword And Continue On Failure
      ...                       Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${0}
    Print Step Text             ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure  Common Preconditions
    ${rmod_obj}=                         Get RMOD Object From User Given Values  ${RMOD_TO_TEST}
    Print Text To Eventlog               Target unit: ${rmod_obj.name}
    ${cells_of_rmod}=                    Get Cells Of Radio  ${rmod_obj.name}
    ${LTE441A_ACTIVE}=                   Check If Lte441a Feature Is Active  ${rmod_obj.name}
    Set Suite Variable                   ${LTE441A_ACTIVE}
    ${CNI_110539}=                       Get Branch And Check If Same Or Newer Than Given  SBTS24R3
    Run Keyword If    '${CNI_110539}' == '${True}'  Run Keyword And Continue On Failure  Add 10 Fault As Expected To Radios
        ...                              ${rmod_obj.name}  cells_of_radio=${cells_of_rmod}
        ...                              get_and_add_to_chain_radios=${True}  lte441a_active=${LTE441A_ACTIVE}
        ...                              suppl_alarm_info=RU connection was lost in runtime / RU was disconnected / ${ADDITIONAL_ALARM_INFO}
    Run Keyword If    '${CNI_110539}' == '${False}'  Run Keyword And Continue On Failure  Add 10 Fault As Expected To Radios
        ...                              ${rmod_obj.name}  cells_of_radio=${cells_of_rmod}
        ...                              get_and_add_to_chain_radios=${True}  lte441a_active=${LTE441A_ACTIVE}
    Run Keyword And Continue On Failure  Add Expected Alarm To Allowed
    ${chained_rmods}=                    Get Chained RMODs  ${rmod_obj.name}
    ${cells_of_rmods_in_chain}=          Get Cells Of Radio  ${chained_rmods}
    ${chained_rmod_names}=               Get Values From Object  ${chained_rmods}  name

    Setup Power Breaker Controller       rmod
    @{ports}=                            Find Ports For Chosen Units  ${rmod_obj.name}
# now if rmod in chain it's cells will be also disabled
    ${FAULTY_CELL}=                      add_list_to_list  ${cells_of_rmod}  ${cells_of_rmods_in_chain}
# This is needed if Nokia nahka radio and there are cells on the radio
    Run Keyword And Continue On Failure  Check If Fault 1815 Should Be Allowed  ${rmod_obj.name}  ${cells_of_rmod}  ${rmod_obj.hw_path}
# This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure  Check If Fault 4590 Should Be Allowed
    Run Keyword And Continue On Failure  Check If Fault 4589 Should Be Allowed
    Run Keyword And Continue On Failure  Check If Fault 4003 Should Be Allowed  ${rmod_obj.name}  lte441a_active=${LTE441A_ACTIVE}
# hot remove
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Switch Power Off And Checks
    ...                                  ${RMOD_TO_TEST}  ${ports}  ${rmod_obj}  ${STEP}  ${WAIT_BEFORE_ALARM_CHECK}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Check If Radios Disabled  ${STEP}.1  ${rmod_obj.name}  ${chained_rmod_names}

    ${bts_state}=                        Get Expected BTS State  ${FAULTY_CELL}  lte441a_active=${LTE441A_ACTIVE}
    Run Keyword And Continue On Failure  Check BTS State  ${bts_state}
    &{cell_state_dict}                   Create Dictionary
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword If  '${LTE441A_ACTIVE}' == '${False}'  Run Keyword And Continue On Failure
    ...                                  Check If Cells Of Radios Disabled  ${STEP}  ${cell_state_dict}  ${FAULTY_CELL}
    Run Keyword If  '${LTE441A_ACTIVE}' == '${True}'  Run Keyword And Continue On Failure
    ...                                  Check If Cells Of Radios Enabled  ${STEP}  ${cell_state_dict}  ${FAULTY_CELL}
# hot insert
    Run Keyword And Continue On Failure  Check If Fault 1972 Should Be Allowed  ${rmod_obj}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Switch Power On And Checks  ${RMOD_TO_TEST}  ${ports}  ${rmod_obj}  ${STEP}
    ...                                  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}
# all unit states are checked in post conditions -> not really needed here...
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Check If Radios Enabled  ${STEP}  ${rmod_obj.name}  ${chained_rmods}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Check If Cells Of Radios Enabled  ${STEP}  ${cell_state_dict}  ${FAULTY_CELL}
    ${bts_state}=                        Get Expected BTS State
    Run Keyword And Continue On Failure  Check BTS State  ${bts_state}
    Run Keyword And Continue On Failure  Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword If  '${LOOPING_KW}' == '${False}'  Run Keyword And Continue On Failure  Stop Background Syslog Print Search
# IMS history checks
#    Run Keyword And Continue On Failure  IMS History Checks  ${cells_of_rmod}  ${cells_of_rmods_in_chain}
#    ...                                  ${rmod_obj}  ${chained_rmods}
    Run Keyword And Continue On Failure  Reset Alarms

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Hot Remove Insert With Reset
    [Documentation]    Switch power of radio module off, check that units and cells have expected states and expected alarms are raised,
    ...                reset site and check that units and cells have expected states and expected alarms are raised, switch power of
    ...                radio module on and check that radio and cells have expected states and no unexpected alarms.
    [Arguments]    ${RMOD_TO_TEST}  ${WAIT_BEFORE_ALARM_CHECK}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}
    ...            ${UNALLOWED_SYSLOGS}  ${WAIT_AFTER_BTS_RESET}

    Run Keyword If      '${LOOPING_KW}' == '${False}'  Run Keyword And Continue On Failure
      ...                                Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${0}
    Print Step Text             ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure  Common Preconditions
    ${rmod_obj}=                         Get RMOD Object From User Given Values  ${RMOD_TO_TEST}
    Print Text To Eventlog               Target unit: ${rmod_obj.name}
    ${cells_of_rmod}=                    Get Cells Of Radio  ${rmod_obj.name}
    ${LTE441A_ACTIVE}=                   Check If Lte441a Feature Is Active  ${rmod_obj.name}
    Set Suite Variable                   ${LTE441A_ACTIVE}
    ${CNI_110539}=                       Get Branch And Check If Same Or Newer Than Given  SBTS24R3
    Run Keyword If  '${CNI_110539}' == '${True}'  Run Keyword And Continue On Failure  Add 10 Fault As Expected To Radios
        ...                              ${rmod_obj.name}  cells_of_radio=${cells_of_rmod}
        ...                              get_and_add_to_chain_radios=${True}  lte441a_active=${LTE441A_ACTIVE}
        ...                              suppl_alarm_info=RU connection was lost in runtime / RU was disconnected / ${ADDITIONAL_ALARM_INFO}
    Run Keyword If    '${CNI_110539}' == '${False}'  Run Keyword And Continue On Failure  Add 10 Fault As Expected To Radios
        ...                              ${rmod_obj.name}  cells_of_radio=${cells_of_rmod}
        ...                              get_and_add_to_chain_radios=${True}  lte441a_active=${LTE441A_ACTIVE}
    Run Keyword And Continue On Failure  Add Expected Alarm To Allowed
    ${chained_rmods}=                    Get Chained RMODs  ${rmod_obj.name}
    ${cells_of_rmods_in_chain}=          Get Cells Of Radio  ${chained_rmods}
    ${chained_rmod_names}=               Get Values From Object  ${chained_rmods}  name
    Setup Power Breaker Controller       rmod
    @{ports}=                            Find Ports For Chosen Units  ${rmod_obj.name}
# now if rmod in chain it's cells will be also disabled
    ${FAULTY_CELL}=                      add_list_to_list  ${cells_of_rmod}  ${cells_of_rmods_in_chain}
# This is needed if Nokia nahka radio and there are cells on the radio
    Run Keyword And Continue On Failure  Check If Fault 1815 Should Be Allowed  ${rmod_obj.name}  ${cells_of_rmod}  ${rmod_obj.hw_path}
# This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure  Check If Fault 4590 Should Be Allowed
    Run Keyword And Continue On Failure  Check If Fault 4589 Should Be Allowed
    Run Keyword And Continue On Failure  Check If Fault 4003 Should Be Allowed  ${rmod_obj.name}  lte441a_active=${LTE441A_ACTIVE}
# hot remove
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Switch Power Off And Checks
    ...                                  ${RMOD_TO_TEST}  ${ports}  ${rmod_obj}  ${STEP}  ${WAIT_BEFORE_ALARM_CHECK}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Check If Radios Disabled  ${STEP}  ${rmod_obj.name}  ${chained_rmod_names}
    ${bts_state}=                        Get Expected BTS State  ${FAULTY_CELL}  lte441a_active=${LTE441A_ACTIVE}
    Run Keyword And Continue On Failure  Check BTS State  ${bts_state}
    &{cell_state_dict}                   Create Dictionary
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword If  '${LTE441A_ACTIVE}' == '${False}'  Run Keyword And Continue On Failure
    ...                                  Check If Cells Of Radios Disabled  ${STEP}  ${cell_state_dict}  ${FAULTY_CELL}
    Run Keyword If  '${LTE441A_ACTIVE}' == '${True}'  Run Keyword And Continue On Failure
    ...                                  Check If Cells Of Radios Enabled  ${STEP}  ${cell_state_dict}  ${FAULTY_CELL}
# reset site
# 2002 fault may be raised when reset  -> add it as allowed
    Print Text To Eventlog       Fault 2002 may be raised when radio is hot removed and BTS reset is made -> Add it to allowed alarm
    Run Keyword And Continue On Failure  ALARMS.Add Allowed Alarm  fault_id=2002  fault_name=Failure in optical interface
# Check if lte441a and/or CNI-110539 is active
    Run Keyword And Continue On Failure  Check if Changes Needed After Site Reset
    ...                                  ${LTE441A_ACTIVE}  ${rmod_obj}  ${cells_of_rmod}   ${CNI_110539}
# Check If LTE441a is active add 10 fault as allowed if it is
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text             ${STEP}  Check if LTE441A is active and should 10 fault as allowed for chosen RMOD
    Run Keyword if  '${LTE441A_ACTIVE}' == '${False}'  Run Keyword And Continue On Failure
    ...                            Print Text To Eventlog  LTE441-a is not active so no need to add 10 fault as allowed
    Run Keyword if  '${LTE441A_ACTIVE}' == '${True}'  Run Keyword And Continue On Failure
    ...                                  Print Text To Eventlog  LTE441-a is active so add 10 fault as allowed
    Run Keyword if  '${LTE441A_ACTIVE}' == '${True}'  Run Keyword And Continue On Failure
    ...   ALARMS.Add Allowed Alarm  alarm_id=7116  fault_id=10  fault_name=No connection to unit
    Run Keyword if  '${LTE441A_ACTIVE}' == '${True}'  Run Keyword And Continue On Failure
    ...                                  Print Text To Eventlog         Fault 10 for chosen RMOD added as allowed
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Reset Site And Checks  ${STEP}  ${WAIT_AFTER_BTS_RESET}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Check If Radios Disabled  ${STEP}  ${rmod_obj.name}  ${chained_rmod_names}
    ${bts_state}=                        Get Expected BTS State  ${FAULTY_CELL}  lte441a_active=${False}
    Run Keyword And Continue On Failure  Check BTS State  ${bts_state}
    &{cell_state_dict}                   Create Dictionary
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
# after reset cells will be disabled
    Run Keyword And Continue On Failure  Check If Cells Of Radios Disabled  ${STEP}  ${cell_state_dict}  ${FAULTY_CELL}
# hot insert
    Run Keyword And Continue On Failure  Check If Fault 1972 Should Be Allowed  ${rmod_obj}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Switch Power On And Checks  ${RMOD_TO_TEST}  ${ports}  ${rmod_obj}  ${STEP}
     ...                                 ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}
#If LTE441-a is active remove allowed fault 10
    Run Keyword If  '${LTE441A_ACTIVE}' == '${True}'  Run Keyword And Continue On Failure
    ...    ALARMS.Remove Allowed Alarm  alarm_id=7116  fault_id=10  fault_name=No connection to unit
    Run Keyword if  '${LTE441A_ACTIVE}' == '${True}'  Run Keyword And Continue On Failure
    ...                                  Print Text To Eventlog  LTE441-a is active so 10 fault removed from allowed
# smod, rmod and cell states are checked in post conditions -> not really needed here
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Check If Radios Enabled  ${STEP}  ${rmod_obj.name}  ${chained_rmods}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Check If Cells Of Radios Enabled  ${STEP}  ${cell_state_dict}  ${FAULTY_CELL}
    ${bts_state}=                        Get Expected BTS State
    Run Keyword And Continue On Failure  Check BTS State  ${bts_state}
    Run Keyword And Continue On Failure  Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword If  '${LOOPING_KW}' == '${False}'  Run Keyword And Continue On Failure  Stop Background Syslog Print Search
# IMS history checks
#    Run Keyword And Continue On Failure  IMS History Checks
#    ...                                  ${cells_of_rmod}  ${cells_of_rmods_in_chain}  ${rmod_obj}  ${chained_rmods}
    Run Keyword And Continue On Failure  Reset Alarms

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Hot Remove Insert With Lock
    [Documentation]    Lock radio module, check that units and cells have expected states, switch power of radio module off,
    ...                check that units and cells have expected states and expected alarms are raised, switch power of radio module on
    ...                 and check that radio and cells have expected states and no unexpected alarms, unlock radio module and check that
    ...                radio and cells have expected states.
    [Arguments]    ${RMOD_TO_TEST}  ${WAIT_BEFORE_ALARM_CHECK}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}
    ...            ${UNALLOWED_SYSLOGS}

    Run Keyword If  '${LOOPING_KW}' == '${False}'  Run Keyword And Continue On Failure
      ...                       Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${0}
    Print Step Text             ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure  Common Preconditions
    ${rmod_obj}=                         Get RMOD Object From User Given Values  ${RMOD_TO_TEST}
# This is needed for lock/unlock
    Print Text To Eventlog               Target unit: ${rmod_obj.name}
    ${cells_of_rmod}=                    Get Cells Of Radio  ${rmod_obj.name}
    ${LTE441A_ACTIVE}=                   Check If Lte441a Feature Is Active  ${rmod_obj.name}
    Set Suite Variable                   ${LTE441A_ACTIVE}
#  This below is needed if there are rmods in chain after the selected rmod
#    @{change_values}=                    Create List  unit_path  hw_path
    ${chained_rmods}=                    Get Chained RMODs  ${rmod_obj.name}
    ${cells_of_rmods_in_chain}=          Get Cells Of Radio  ${chained_rmods}
    ${chained_rmod_names}=               Get Values From Object  ${chained_rmods}  name
    Setup Power Breaker Controller       rmod
    @{ports}=                            Find Ports For Chosen Units  ${rmod_obj.name}
# create cell state dict and get dist names of cells mapped to rmod
    &{cell_state_dict}                   Create Dictionary  All_cells=${state_dict_cell_enabled}
    ${FAULTY_CELL}=                      If Parameter Not List Add It To List  ${cells_of_rmod}
# lock rmod
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Lock RMOD And Checks  ${STEP}  ${rmod_obj}
    ...                                  ${cell_state_dict}  ${WAIT_CHECKS}  ${FAULTY_CELL}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Check If Selected Radio Locked  ${STEP}  ${rmod_obj.name}
    ${bts_state}=                        Get Expected BTS State  ${FAULTY_CELL}  lte441a_active=${LTE441A_ACTIVE}
    Run Keyword And Continue On Failure  Check BTS State  ${bts_state}
    &{cell_state_dict}                   Create Dictionary
# 10 alarm is not expected when rmod is locked so add it to expected after lock
    Run Keyword And Continue On Failure  Add 10 Fault As Expected To Radios
        ...                              ${rmod_obj.name}  cells_of_radio=${cells_of_rmod}
        ...                              get_and_add_to_chain_radios=${True}  lte441a_active=${LTE441A_ACTIVE}
    Run Keyword And Continue On Failure  Add Expected Alarm To Allowed
# This is needed if Nokia nahka radio and there are cells on the radio
    Run Keyword And Continue On Failure  Check If Fault 1815 Should Be Allowed  ${rmod_obj.name}  ${cells_of_rmod}  ${rmod_obj.hw_path}
# This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure  Check If Fault 4590 Should Be Allowed
    Run Keyword And Continue On Failure  Check If Fault 4589 Should Be Allowed
    Run Keyword And Continue On Failure  Check If Fault 4003 Should Be Allowed  ${rmod_obj.name}  lte441a_active=${LTE441A_ACTIVE}
# hot remove
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Switch Power Off And Checks
    ...                                  ${RMOD_TO_TEST}  ${ports}  ${rmod_obj}  ${STEP}  ${WAIT_BEFORE_ALARM_CHECK}
# now if rmod in chain it's cells will be also disabled
    ${FAULTY_CELL}=             add_list_to_list  ${cells_of_rmod}  ${cells_of_rmods_in_chain}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword If  '${LTE441A_ACTIVE}' == '${False}'  Run Keyword And Continue On Failure
    ...                                  Check If Cells Of Radios Disabled  ${STEP}  ${cell_state_dict}  ${FAULTY_CELL}
    Run Keyword If  '${LTE441A_ACTIVE}' == '${True}'  Run Keyword And Continue On Failure
    ...                                  Check If Cells Of Radios Enabled  ${STEP}  ${cell_state_dict}  ${FAULTY_CELL}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Check If Radios Locked And Disabled  ${STEP}  ${rmod_obj.name}  ${chained_rmod_names}
# hot insert
# NOTE Switch Power On And Checks KW cannot be used here because RMOD is still locked and cells disabled
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Hot insert chosen RMOD ${RMOD_TO_TEST} (port:${ports})
    Run Keyword And Continue On Failure  Turn Power On To Chosen Units  ${rmod_obj.name}
    Run Keyword And Continue On Failure  Remove Expected Alarms
    Wait Time And Reason                 ${WAIT_CHECKS}  after hot insert
# 10 fault is cleared cells are still offline
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Check active alarms
    Run Keyword And Continue On Failure  ALARMS.Check Active Alarms
# After hot insert cell on mother RMOD remains disabled but cell of RMOD in chain will be enabled
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword If  '${LTE441A_ACTIVE}' == '${False}'  Run Keyword And Continue On Failure
    ...                                  Check If Cells Of Radios Disabled  ${STEP}  ${cell_state_dict}  ${cells_of_rmod}
    Run Keyword If  '${LTE441A_ACTIVE}' == '${True}'  Run Keyword And Continue On Failure
    ...                                  Check If Cells Of Radios Enabled  ${STEP}  ${cell_state_dict}  ${FAULTY_CELL}
# unlock RMOD
    Run Keyword And Continue On Failure  Check If Fault 1972 Should Be Allowed  ${rmod_obj}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Unlock RMOD And Checks  ${STEP}  ${rmod_obj}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}
# SMOD, RMOD and cell states are checked in post conditions -> not really needed here
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Check If Radios Enabled  ${STEP}  ${rmod_obj.name}  ${chained_rmods}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Check If Cells Of Radios Enabled  ${STEP}  ${cell_state_dict}  ${FAULTY_CELL}
    ${bts_state}=             Get Expected BTS State
    Run Keyword And Continue On Failure  Check BTS State  ${bts_state}
    Run Keyword And Continue On Failure  Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword If    '${LOOPING_KW}' == '${False}'  Run Keyword And Continue On Failure  Stop Background Syslog Print Search
# IMS history checks
#    Run Keyword And Continue On Failure  IMS History Checks
#    ...                                  ${cells_of_rmod}  ${cells_of_rmods_in_chain}  ${rmod_obj}  ${chained_rmods}
    Run Keyword And Continue On Failure  Reset Alarms

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Hot Remove During Startup
    [Documentation]    Switch power of radio module off, check that units and cells have expected states and expected alarms are raised,
    ...                reset site and check that units and cells have expected states and expected alarms are raised, switch power of
    ...                radio module on and check that radio and cells have expected states and no unexpected alarms.
    [Arguments]    ${RMOD_TO_TEST}  ${WAIT_BEFORE_ALARM_CHECK}  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}
    ...            ${UNALLOWED_SYSLOGS}

    Run Keyword If  '${LOOPING_KW}' == '${False}'  Run Keyword And Continue On Failure
      ...                                Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${0}
    Print Text To Eventlog               Check Preconditions
    Run Keyword And Continue On Failure  Common Preconditions
    ${rmod_obj}=                         Get RMOD Object From User Given Values  ${RMOD_TO_TEST}
    Print Text To Eventlog               Target unit: ${rmod_obj.name}
    ${cells_of_rmod}=                    Get Cells Of Radio  ${rmod_obj.name}
    ${LTE441A_ACTIVE}=                   Check If Lte441a Feature Is Active  ${rmod_obj.name}
    Set Suite Variable                   ${LTE441A_ACTIVE}
    ${CNI_110539}=                       Get Branch And Check If Same Or Newer Than Given  SBTS24R3
    Run Keyword If    '${CNI_110539}' == '${True}'  Run Keyword And Continue On Failure  Add 10 Fault As Expected To Radios
        ...                              ${rmod_obj.name}  cells_of_radio=${cells_of_rmod}
        ...                              get_and_add_to_chain_radios=${True}  lte441a_active=${LTE441A_ACTIVE}
        ...                              suppl_alarm_info=RU connection was lost in runtime / RU was disconnected / ${ADDITIONAL_ALARM_INFO}
    Run Keyword If  '${CNI_110539}' == '${False}'  Run Keyword And Continue On Failure  Add 10 Fault As Expected To Radios
        ...                              ${rmod_obj.name}  cells_of_radio=${cells_of_rmod}
        ...                              get_and_add_to_chain_radios=${True}  lte441a_active=${LTE441A_ACTIVE}
    Run Keyword And Continue On Failure  Add Expected Alarm To Allowed
    ${chained_rmods}=                    Get Chained RMODs  ${rmod_obj.name}
    ${cells_of_rmods_in_chain}=          Get Cells Of Radio  ${chained_rmods}
    ${chained_rmod_names}=               Get Values From Object  ${chained_rmods}  name
    Setup Power Breaker Controller       rmod
    @{ports}=                            Find Ports For Chosen Units  ${rmod_obj.name}
# now if rmod in chain it's cells will be also disabled
    ${FAULTY_CELL}=                      add_list_to_list  ${cells_of_rmod}  ${cells_of_rmods_in_chain}
# This is needed if Nokia nahka radio and there are cells on the radio
    Run Keyword And Continue On Failure  Check If Fault 1815 Should Be Allowed  ${rmod_obj.name}  ${cells_of_rmod}  ${rmod_obj.hw_path}
# This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure  Check If Fault 4590 Should Be Allowed
    Run Keyword And Continue On Failure  Check If Fault 4589 Should Be Allowed
    Run Keyword And Continue On Failure  Check If Fault 4003 Should Be Allowed  ${rmod_obj.name}  lte441a_active=${LTE441A_ACTIVE}
# step 1
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text             ${STEP}  BTS is start-up and is in runtime. Hot remove RMOD.
# hot remove
    Run Keyword And Continue On Failure  Switch Power Off And Checks
    ...                                  ${RMOD_TO_TEST}  ${ports}  ${rmod_obj}  ${STEP}.1  ${WAIT_BEFORE_ALARM_CHECK}
    Run Keyword And Continue On Failure  Check If Radios Disabled  ${STEP}.3  ${rmod_obj.name}  ${chained_rmod_names}
    ${bts_state}=                        Get Expected BTS State  ${FAULTY_CELL}  lte441a_active=${LTE441A_ACTIVE}
    Run Keyword And Continue On Failure  Check BTS State  ${bts_state}
    &{cell_state_dict}                   Create Dictionary
    Run Keyword If  '${LTE441A_ACTIVE}' == '${False}'  Run Keyword And Continue On Failure
    ...                                  Check If Cells Of Radios Disabled  ${STEP}.4  ${cell_state_dict}  ${FAULTY_CELL}
    Run Keyword If  '${LTE441A_ACTIVE}' == '${True}'  Run Keyword And Continue On Failure
    ...                                  Check If Cells Of Radios Enabled  ${STEP}.4  ${cell_state_dict}  ${FAULTY_CELL}
# reset site
# 2002 fault may be raised when reset  -> add it as allowed
    Print Text To Eventlog       Fault 2002 may be raised when radio is hot removed and BTS reset is made -> Add it to allowed alarm
    Run Keyword And Continue On Failure  ALARMS.Add Allowed Alarm  fault_id=2002  fault_name=Failure in optical interface
# step 2
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Site reset and RMOD (${RMOD_TO_TEST}) is hot insert during start-up
    Run Keyword And Continue On Failure  Reset Site And Wait For Bts To Reply Ping
    Print Text To Eventlog               Hot insert chosen RMOD ${RMOD_TO_TEST} (port:${ports})
    Run Keyword And Continue On Failure  Turn Power On To Chosen Units  ${rmod_obj.name}
    Run Keyword And Continue On Failure  Remove Expected Alarms
    Wait Time And Reason                 ${WAIT_AFTER_SITE_RESET}  before checking alarms and states
    Run Keyword And Continue On Failure  Check alarms and states  Site reset and RMOD is hot insert during start-up
    Run Keyword And Continue On Failure  Remove Allowed Alarm  fault_id=10  fault_name=Failure in optical interface
# step 3
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text                      ${STEP}  Site reset and RMOD reset during start-up after 192.168.255.129 response to ping
    Run Keyword And Continue On Failure  Reset Site And Wait For BTS To Reply Ping
    Run Keyword And Continue On Failure  Ping Ip From SMOD  ${rmod_obj.ip}  lxc_attach=${True}  only_warning=${True}
    Run Keyword And Continue On Failure  RMOD LTX Spontaneous Reset  ${rmod_obj}
    Wait Time And Reason                 ${WAIT_AFTER_SITE_RESET}  before checking alarms and states
    Run Keyword And Continue On Failure  Check alarms and states  Site reset and RMOD reset during start-up after 192.168.255.129 response to ping
# step 4
    Run Keyword If    '${CNI_110539}' == '${True}'  Run Keyword And Continue On Failure  Add 10 Fault As Expected To Radios
        ...                              ${rmod_obj.name}  cells_of_radio=${cells_of_rmod}
        ...                              get_and_add_to_chain_radios=${True}  lte441a_active=${LTE441A_ACTIVE}
        ...                              suppl_alarm_info=RU not detected after BTS startup
    Run Keyword If    '${CNI_110539}' == '${False}'  Run Keyword And Continue On Failure  Add 10 Fault As Expected To Radios
        ...                              ${rmod_obj.name}  cells_of_radio=${cells_of_rmod}
        ...                              get_and_add_to_chain_radios=${True}  lte441a_active=${LTE441A_ACTIVE}
    Run Keyword And Continue On Failure  Add Expected Alarm To Allowed
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text             ${STEP}  Site reset and RMOD hot remove during start-up
    Run Keyword And Continue On Failure  Reset Site And Wait For Bts To Reply Ping
    Run Keyword And Continue On Failure  Switch Power Off And Checks
    ...                                  ${RMOD_TO_TEST}  ${ports}  ${rmod_obj}  ${STEP}.1  ${WAIT_ALARM_IN_STARTUP}
    Run Keyword And Continue On Failure  Check If Radios Disabled  ${STEP}.3  ${rmod_obj.name}  ${chained_rmod_names}
    ${bts_state}=                        Get Expected BTS State  ${FAULTY_CELL}  lte441a_active=${LTE441A_ACTIVE}
    Run Keyword And Continue On Failure  Check BTS State  ${bts_state}
    &{cell_state_dict}        Create Dictionary
    Run Keyword If  '${LTE441A_ACTIVE}' == '${False}'  Run Keyword And Continue On Failure
    ...                                  Check If Cells Of Radios Disabled  ${STEP}.4  ${cell_state_dict}  ${FAULTY_CELL}
    Run Keyword If  '${LTE441A_ACTIVE}' == '${True}'  Run Keyword And Continue On Failure
    ...                                  Check If Cells Of Radios Enabled  ${STEP}.4  ${cell_state_dict}  ${FAULTY_CELL}
# step 5
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text             ${STEP}  RMOD hot insert
    Run Keyword And Continue On Failure  Turn Power On To Chosen Units  ${rmod_obj.name}
    Run Keyword And Continue On Failure  Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure  Remove Expected Alarms
    Wait Time And Reason                 ${WAIT_AFTER_SITE_RESET}  before checking alarms and states
    Run Keyword And Continue On Failure  Check alarms and states  RMOD hot insert
    Run Keyword And Continue On Failure  Remove Allowed Alarm  fault_id=10  fault_name=Failure in optical interface
# step 6
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text             ${STEP}  RMOD reset via WebEM and Site reset
    Print Text To Eventlog               Request warm reset to ${rmod_obj.dist_name} (${rmod_obj.name}) (${rmod_obj.serial_number})
#    Run Keyword And Continue On Failure  ADMIN.Reset Unit  dist_name=${rmod_obj.dist_name}  reset_type=Warm  timeout=600
#        ...                                 detailed_output=True
    Run Keyword And Continue On Failure  Reset Unit With Error Handling  ${rmod_obj.dist_name}  reset_type=Warm
        ...                              timeout=5  detailed_output=${True}  allow_error=${True}
    Print Text To Eventlog               Wait 30s and then give Site reset
    Sleep                                30 seconds
    Run Keyword And Continue On Failure  ADMIN.Reset Site  detailed_output=True
    Wait Time And Reason                 ${WAIT_AFTER_SITE_RESET}  before checking alarms and states
    Run Keyword And Continue On Failure  Check alarms and states  RMOD reset via WebEM and Site reset
# step 7
    Run Keyword If  '${CNI_110539}' == '${True}'  Run Keyword And Continue On Failure  Add 10 Fault As Expected To Radios
        ...                              ${rmod_obj.name}  cells_of_radio=${cells_of_rmod}
        ...                              get_and_add_to_chain_radios=${True}  lte441a_active=${LTE441A_ACTIVE}
        ...                              suppl_alarm_info=RU not detected after reset / RU connection was lost in runtime
    Run Keyword If    '${CNI_110539}' == '${False}'  Run Keyword And Continue On Failure  Add 10 Fault As Expected To Radios
        ...                              ${rmod_obj.name}  cells_of_radio=${cells_of_rmod}
        ...                              get_and_add_to_chain_radios=${True}  lte441a_active=${LTE441A_ACTIVE}
    Run Keyword And Continue On Failure  Add Expected Alarm To Allowed
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text             ${STEP}  RMOD reset, wait 30s and then RMOD is hot remove (power off)
    Print Text To Eventlog               Request warm reset to ${rmod_obj.dist_name} (${rmod_obj.name}) (${rmod_obj.serial_number})
#    ${keyword_success}=                   Run Keyword and Return Status  ADMIN.Reset Unit  dist_name=${rmod_obj.dist_name}
#    ...                                   reset_type=Warm  timeout=600  detailed_output=True
    Run Keyword And Continue On Failure  Reset Unit With Error Handling  ${rmod_obj.dist_name}  reset_type=Warm
        ...                              timeout=5  detailed_output=${True}  allow_error=${True}
    Print Text To Eventlog               Wait 30s and then RMOD is hot remove (power off)
    Sleep                                30 seconds
    Run Keyword And Continue On Failure  Switch Power Off And Checks
    ...                                  ${RMOD_TO_TEST}  ${ports}  ${rmod_obj}  ${STEP}.1  ${WAIT_BEFORE_ALARM_CHECK}
    Run Keyword And Continue On Failure  Check If Radios Disabled  ${STEP}.3  ${rmod_obj.name}  ${chained_rmod_names}
    ${bts_state}=                        Get Expected BTS State  ${FAULTY_CELL}  lte441a_active=${LTE441A_ACTIVE}
    Run Keyword And Continue On Failure  Check BTS State  ${bts_state}
    &{cell_state_dict}                   Create Dictionary
    Run Keyword If  '${LTE441A_ACTIVE}' == '${False}'  Run Keyword And Continue On Failure  Check If Cells Of Radios Disabled
    ...                                  ${STEP}.4  ${cell_state_dict}  ${FAULTY_CELL}
    Run Keyword If  '${LTE441A_ACTIVE}' == '${True}'  Run Keyword And Continue On Failure  Check If Cells Of Radios Enabled
    ...                                  ${STEP}.4  ${cell_state_dict}  ${FAULTY_CELL}
# step 8
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text             ${STEP}  RMOD hot insert
    Run Keyword And Continue On Failure  Turn Power On To Chosen Units  ${rmod_obj.name}
    Run Keyword And Continue On Failure  Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure  Remove Expected Alarms
    Wait Time And Reason                 ${WAIT_AFTER_SITE_RESET}  before checking alarms and states
    Run Keyword And Continue On Failure  Check alarms and states  RMOD reset, wait 30s and then RMOD is hot remove and RMOD hot insert
    Run Keyword And Continue On Failure  Remove Allowed Alarm  fault_id=10  fault_name=Failure in optical interface
# step 9
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text             ${STEP}  Site reset is performed
    Print Text To Eventlog               Request site reset
    Run Keyword And Continue On Failure  ADMIN.Reset Site  detailed_output=True
    Wait Time And Reason                 ${WAIT_AFTER_SITE_RESET}  before checking alarms and states
    Run Keyword And Continue On Failure  Check alarms and states  Site reset is performed
    Run Keyword And Continue On Failure  Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Do Test To All Radios One By One
    [Documentation]  This KW runs the given test type to all radio modules that are found from environment one by one.
    ...              Test type can be for example: Hot Remove Insert, Hot Remove Insert With Reset, Hot Remove Insert With Lock
    ...              or Hot Remove During Startup.
    [Arguments]    ${WAIT_BEFORE_ALARM_CHECK}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    ...            ${WAIT_AFTER_BTS_RESET}  ${TEST_TYPE}

    Set Suite Variable  ${LOOPING_KW}  ${True}
    ${RMOD_LIST}=       Get All Radios
    IF    $TEST_TYPE in $ALL_TEST_TYPES
        Print Text To Eventlog    Do '${TEST_TYPE}' to all radios in environment one by one: ${RMOD_LIST}
    ELSE
        Set Suite Variable  ${KW_SUCCESS}  ${False}
        Fail    Invalid TEST_TYPE: '${TEST_TYPE}'. Allowed: ${ALL_TEST_TYPES}
    END
    FOR    ${radio}  IN  @{RMOD_LIST}
        Print Text To Eventlog  Check SMOD, BBMOD, RMOD and cells states. If fails, tests for remaining radios are skipped.
        Run Keyword    Check BTS Status
        IF       '${TEST_TYPE}' == 'Hot Remove Insert'
            Run Keyword And Continue On Failure   Hot Remove Insert  ${radio}  ${WAIT_BEFORE_ALARM_CHECK}  ${WAIT_CHECKS}
            ...                                   ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ELSE IF  '${TEST_TYPE}' == 'Hot Remove Insert With Reset'
            Run Keyword And Continue On Failure   Hot Remove Insert With Reset  ${radio}  ${WAIT_BEFORE_ALARM_CHECK}  ${WAIT_CHECKS}
            ...                                   ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_AFTER_BTS_RESET}
        ELSE IF  '${TEST_TYPE}' == 'Hot Remove Insert With Lock'
            Run Keyword And Continue On Failure   Hot Remove Insert With Lock  ${radio}  ${WAIT_BEFORE_ALARM_CHECK}  ${WAIT_CHECKS}
            ...                                   ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ELSE IF  '${TEST_TYPE}' == 'Hot Remove During Startup'
            Run Keyword And Continue On Failure   Hot Remove During Startup  ${radio}  ${WAIT_BEFORE_ALARM_CHECK}
        ...                                       ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        END
    END
    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Switch Power Off And Checks
    [Arguments]    ${RMOD_TO_TEST}  ${ports}  ${rmod_obj}  ${STEP}  ${WAIT_BEFORE_ALARM_CHECK}

    Run Keyword and continue on Failure  Check If Fault 1972 Should Be Allowed  ${rmod_obj}
    Print Step Text             ${STEP}  Hot remove chosen RMOD ${RMOD_TO_TEST} (port:${ports})
    Run Keyword And Continue On Failure  Turn Power Off From Chosen Units  ${rmod_obj.name}
    Run Keyword And Continue On Failure  Check If Fault Is Active  fault_id=1972
    Wait Time And Reason                 ${WAIT_BEFORE_ALARM_CHECK}  before checking alarms
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text             ${STEP}  Check alarms
    Run Keyword And Continue On Failure  Check Expected Alarms  wait_active_timeout=300
    Run Keyword And Continue On Failure  ALARMS.Remove Allowed Alarm  alarm_id=7652  fault_id=1972  fault_name=RRU power loss

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Switch Power On And Checks
    [Arguments]    ${RMOD_TO_TEST}  ${ports}  ${rmod_obj}  ${STEP}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}

    Print Step Text             ${STEP}  Hot insert chosen RMOD ${RMOD_TO_TEST} (port:${ports})
    Run Keyword And Continue On Failure  Turn Power On To Chosen Units  ${rmod_obj.name}
    Run Keyword And Continue On Failure  Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}
    Wait Time And Reason                 ${WAIT_CHECKS}  before checking post conditions
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text             ${STEP}  Check Postconditions
    Run Keyword And Continue On Failure  Common Postconditions

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

IMS History Checks
    [Arguments]  ${cells_of_rmod}  ${cells_of_rmods_in_chain}  ${rmod_obj}  ${chained_rmods}

    ${affected_cells}=                   add_list_to_list  ${cells_of_rmod}  ${cells_of_rmods_in_chain}
    @{serial_number_list}=               Create List  ${rmod_obj.serial_number}
    ${chain_serial_number_list}=         Get Values From Object  ${chained_rmods}  serial_number
    ${rmod_serial_number_list}=          add_list_to_list  ${serial_number_list}  ${chain_serial_number_list}
    Run Keyword And Continue On Failure  Check If Selected RMODs Disabled And Enabled  ${rmod_serial_number_list}
    Run Keyword And Continue On Failure  Check If Selected Cells Were Disabled And Enabled  ${affected_cells}

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Reset Site And Checks
    [Arguments]  ${STEP}  ${WAIT_AFTER_BTS_RESET}

    Print Step Text             ${STEP}  Make site reset
    Print Text To Eventlog               Request site reset
    Run Keyword And Continue On Failure  ADMIN.Reset Site  detailed_output=True
    Wait Time And Reason                 ${WAIT_AFTER_BTS_RESET}  before checking alarms after site reset
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text             ${STEP}  Check alarms
    Run Keyword And Continue On Failure  Check Expected Alarms  wait_active_timeout=120

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Lock RMOD And Checks
    [Arguments]  ${STEP}  ${rmod_obj}  ${cell_state_dict}  ${WAIT_CHECKS}  ${FAULTY_CELL}

    Print Step Text             ${STEP}  Check cell states
    Run Keyword And Continue On Failure  Check Cell States  ${cell_state_dict}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text             ${STEP}  Lock radio ${rmod_obj.scf_dist_name} (${rmod_obj.name})
    Run Keyword And Continue On Failure  ADMIN.Lock  dist_name=${rmod_obj.scf_dist_name}  timeout=600  detailed_output=True
    Run Keyword And Continue On Failure  Wait For Cells Faulty  600  ${FAULTY_CELL}   degraded_cells_stops_wait=${True}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text             ${STEP}  Check alarms
    Run Keyword And Continue On Failure  Check Expected Alarms  wait_active_timeout=300
    Wait Time And Reason                 ${WAIT_CHECKS}  before checking cell states
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword If  '${LTE441A_ACTIVE}' == '${False}'  Run Keyword And Continue On Failure
    ...                                  Check If Cells Of Radios Disabled  ${STEP}  ${cell_state_dict}  ${FAULTY_CELL}
    Run Keyword If  '${LTE441A_ACTIVE}' == '${True}'  Run Keyword And Continue On Failure
    ...                                  Check If Cells Of Radios Enabled  ${STEP}  ${cell_state_dict}  ${FAULTY_CELL}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Unlock RMOD And Checks
    [Arguments]  ${STEP}  ${rmod_obj}   ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}

    Print Step Text             ${STEP}  Unlock radio ${rmod_obj.scf_dist_name} (${rmod_obj.name})
    Run Keyword And Continue On Failure  ADMIN.Unlock  dist_name=${rmod_obj.scf_dist_name}  timeout=600  detailed_output=True
    Run Keyword And Continue On Failure  Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Wait Time And Reason                 ${WAIT_CHECKS}  before checking alarm history
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text             ${STEP}  Check Postconditions
    Run Keyword And Continue On Failure  Common Postconditions

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Lock BBMOD And Checks
    [Arguments]  ${STEP}  ${bbmod_configuration_id}  ${bbmod_name}  ${cell_state_dict}  ${WAIT_CHECKS}  ${FAULTY_CELL}

    Print Step Text             ${STEP}  Check cell states
    Run Keyword And Continue On Failure  Check Cell States  ${cell_state_dict}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text             ${STEP}  Lock BBMOD ${bbmod_configuration_id} (${bbmod_name})
    Run Keyword And Continue On Failure  ADMIN.Lock  dist_name=${bbmod_configuration_id}  timeout=300  detailed_output=True
    Run Keyword And Continue On Failure  Wait For Cells Faulty  600  ${FAULTY_CELL}
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text             ${STEP}  Check alarms
    Run Keyword And Continue On Failure  Check Expected Alarms  wait_active_timeout=300
    Wait Time And Reason                 ${WAIT_CHECKS}  before checking cell states
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Run Keyword And Continue On Failure  Check If Cells Of Radios Disabled  ${STEP}  ${cell_state_dict}  ${FAULTY_CELL}

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Unlock BBMOD And Checks
    [Arguments]  ${STEP}  ${bbmod_configuration_id}  ${bbmod_name}  ${WAIT_CHECKS}
    ...          ${WAIT_FOR_CELLS_UP}

    Print Step Text             ${STEP}  Unlock BBMOD ${bbmod_configuration_id} (${bbmod_name})
    Run Keyword And Continue On Failure  ADMIN.Unlock  dist_name=${bbmod_configuration_id}  timeout=300  detailed_output=True
    Run Keyword And Continue On Failure  Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Wait Time And Reason                 ${WAIT_CHECKS}  before checking alarm history
    ${STEP}=                             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
    Print Step Text             ${STEP}  Check Postconditions
    Run Keyword And Continue On Failure  Common Postconditions

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Check If Cells Of Radios Disabled
    [Arguments]  ${STEP}  ${cell_state_dict}  ${FAULTY_CELL}

    Print Step Text             ${STEP}  Check cell states
    Remove From Dictionary               ${cell_state_dict}  All_cells
    FOR    ${faulty}  IN  @{FAULTY_CELL}
        Set To Dictionary                ${cell_state_dict}  ${faulty}  ${state_dict_cell_disabled}
    END
    Run Keyword And Continue On Failure  Check Cell States  ${cell_state_dict}  states_of_other_cells=${state_dict_cell_enabled}

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Check If Cells Of Radios Enabled
    [Arguments]  ${STEP}  ${cell_state_dict}  ${FAULTY_CELL}

    Print Step Text             ${STEP}  Check cell states
    FOR    ${enabled}  IN  @{FAULTY_CELL}
        Set To Dictionary                ${cell_state_dict}  ${enabled}  ${state_dict_cell_enabled}
    END
    Run Keyword And Continue On Failure  Check Cell States  ${cell_state_dict}  states_of_other_cells=${state_dict_cell_enabled}

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Check If Selected Radio Locked
    [Arguments]  ${STEP}  ${radio}

    Print Step Text             ${STEP}  Check radio states
    &{state_dict}  Create Dictionary     ${radio}=${state_dict_lock_enabled}
    Run Keyword And Continue On Failure  Check Radio States  ${state_dict}  states_of_other_rmods=${state_dict_unlock}
    ...                                  print_ok_states=${True}

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Check If Selected BBMOD Locked
    [Arguments]  ${STEP}  ${bbmod}

    Print Step Text             ${STEP}  Check BBMOD states
    &{state_dict}                        Create Dictionary  ${bbmod}=${state_dict_lock_enabled}
    Run Keyword And Continue On Failure  Check BBMOD States  ${state_dict}  print_ok_states=${True}

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Check If Radios Disabled
    [Arguments]  ${STEP}  ${radio}  ${chained_rmod_names}

    Print Step Text             ${STEP}  Check radio states
    &{state_dict}                        Create Dictionary  ${radio}=${state_dict_disabled}
    ${r_state_dict}=                     add_list_to_dict_if_it_exist  ${state_dict}  ${chained_rmod_names}  ${state_dict_disabled}
    Run Keyword And Continue On Failure  Check Radio States  ${r_state_dict}  states_of_other_rmods=${state_dict_unlock}
    ...                                  print_ok_states=${True}

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Check If Radios Enabled
    [Arguments]  ${STEP}  ${radio}  ${chained_rmod_names}

    Print Step Text             ${STEP}  Check radio states
    &{state_dict}                        Create Dictionary  ${radio}=${state_dict_unlock}
    ${rmod_state_dict}=                  add_list_to_dict_if_it_exist  ${state_dict}  ${chained_rmod_names}  ${state_dict_unlock}
    Run Keyword And Continue On Failure  Check Radio States  ${rmod_state_dict}  states_of_other_rmods=${state_dict_unlock}
    ...                                  print_ok_states=${True}

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Check If BBMODs Enabled
    [Arguments]  ${STEP}  ${bbmod}

    Print Step Text             ${STEP}  Check bbmod states
    &{state_dict}                        Create Dictionary  ${bbmod}=${state_dict_unlock}
    Run Keyword And Continue On Failure  Check BBMOD States  ${state_dict}  print_ok_states=${True}

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Check If Radios Locked And Disabled
    [Arguments]  ${STEP}  ${radio}  ${chained_rmod_names}

    Print Step Text             ${STEP}  Check radio states
    &{state_dict}         Create Dictionary  ${radio}=${state_dict_lock}
    ${radio_state_dict}=        add_list_to_dict_if_it_exist  ${state_dict}  ${chained_rmod_names}  ${state_dict_disabled}
#    FOR    ${chain}  IN    @{chained_rmod_names}
#        Set To Dictionary                     ${state_dict}  ${chain}  ${state_dict_disabled}
#    END
    Run Keyword And Continue On Failure  Check Radio States  ${radio_state_dict}  states_of_other_rmods=${state_dict_unlock}
    ...                                                      print_ok_states=${True}

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Check if Changes Needed After Site Reset
    [Documentation]    This keyword is for checking possible changes for radio module fault after site reset depending if
    ...                lte441a is active or not and if CNI-110539 is active or not.
    [Arguments]    ${LTE441A_ACTIVE}   ${rmod_obj}  ${cells_of_rmod}  ${CNI_110539}

    Run Keyword If  '${LTE441A_ACTIVE}' == '${True}' or '${CNI_110539}' == '${True}'
    ...             Run Keyword And Continue On Failure  Remove Expected Alarms
# if lte441a is active, CNI_110539 is not active: after reset cells and radios will be faulty before hot insert
    Run Keyword If  '${LTE441A_ACTIVE}' == '${True}' and '${CNI_110539}' == '${False}'
        ...         Run Keyword And Continue On Failure  Add 10 Fault As Expected To Radios
        ...         ${rmod_obj.name}  cells_of_radio=${cells_of_rmod}
        ...         get_and_add_to_chain_radios=${True}  lte441a_active=${False}
# if lte441a is active and CNI_110539 active: after reset cells and radios will be faulty before hot insert
    Run Keyword If  '${LTE441A_ACTIVE}' == '${True}' and '${CNI_110539}' == '${True}'  Run Keywords
        ...         Run Keyword And Continue On Failure  Add 10 Fault As Expected To Radios
        ...         ${rmod_obj.name}  cells_of_radio=${cells_of_rmod}
        ...         get_and_add_to_chain_radios=${True}  lte441a_active=${False}
        ...         suppl_alarm_info=RU not detected after BTS startup / RU not detected after reset
        ...         AND
        ...         Run Keyword And Continue On Failure  Add 10 Fault As Expected To Radios
        ...         ${rmod_obj.name}  cells_of_radio=${cells_of_rmod}
        ...         get_and_add_to_chain_radios=${True}  lte441a_active=${False}
        ...         suppl_alarm_info=RU connection was lost in runtime / RU was disconnected / ${ADDITIONAL_ALARM_INFO}
        ...         add_just_to_allowed=${True}
# If CNI_110539 is true, but lte441a is not active, just reason for 10 fault is changed after site reset
    Run Keyword If  '${LTE441A_ACTIVE}' == '${False}' and '${CNI_110539}' == '${True}'
        ...         Run Keyword And Continue On Failure  Add 10 Fault As Expected To Radios
        ...         ${rmod_obj.name}  cells_of_radio=${cells_of_rmod}
        ...         get_and_add_to_chain_radios=${True}  lte441a_active=${LTE441A_ACTIVE}
        ...         suppl_alarm_info=RU not detected after BTS startup / RU not detected after reset
    Run Keyword If  '${LTE441A_ACTIVE}' == '${True}' or '${CNI_110539}' == '${True}'
        ...         Run Keyword And Continue On Failure  Add Expected Alarm To Allowed

    [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Check alarms and states
    [Documentation]  This keyword is for checking active alarms and unit and cell states after site reset. Everything is expected to be ok.
    [Arguments]  ${STEP_TEXT}

    Print Text To Eventlog               Check alarms and states
    Run Keyword And Continue On Failure  Check Active Alarms  test_step_txt=${STEP_TEXT}
    Run Keyword And Continue On Failure  Check BTS Status
    Run Keyword And Continue On Failure  Check Value Of Restart Counter  info_text=${STEP_TEXT}
    Run Keyword And Continue On Failure  Reset Active Alarms During Test
