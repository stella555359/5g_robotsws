*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/apc.robot

Documentation
...  TEST NAME:     SM.48_RU_Power_Reset
...  AUTHORS:       sebastian.suwada@nokia.com
...  MAINTAINER:    VRF_WRO3_T02
...  *****************
...  Basic information
...  *****************
...  This test case is designed to perform a power reset operation on RMOD units and subsequently verify the
...  status of both the RMOD units and the eNB. It was proposed as part of the higher robustness testing initiative,
...  ensuring improved resilience and performance of the system and connection with Radio units after power reset.
...  *****************
...  Pre-conditions
...  *****************
...  PDU informations:IP, outlet(s) in config file, eg.: PDU_IP, PDU_PRIMARY_CORE, if fullrack: PDU_SECONDARY_CORE
...  ******************
...  History of changes
...  ******************
...  27.03.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-11759 - Test creation
...  *******************
...  VRF_WRO3_T02 TEMPLATE

*** Variables ***
${last_selected_rmod}

*** Keywords ***
SM.48_RMOD_power_reset
    SM.48_RMOD_power_reset.Test_Step:0 Test Preparation
    SM.48_RMOD_power_reset.Test_Step:1 Perform Power Reset on RMODs
    SM.48_RMOD_power_reset.Test_Step:2 Check BTS and RMOD status
    SM.48_RMOD_power_reset.Test_Step:3 Final Checkpoint

SM.48_RMOD_power_reset.Test_Step:0 Test Preparation
    Log to console  \n========================================
    Log to console  Test_Step:0 Test Preparation
    Log to console  ========================================
    ${bts_name}  Get BTS Name
    Set Test Variable  ${bts_name}
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Run Keyword If  ${ITERATION_INDEX}==1  RMOD Chain Detection    #sets test variables ${RMOD_TO_CHAIN_INDEX_MAPPING} and ${AVAILABLE_CHAINS_INDEX}
    ${rats}  Detect RATs
    Set Test Variable  ${rats}
    Check If NLWG Cells Are OnAir
    Select RMOD for power reset
    SCF Backup

SM.48_RMOD_power_reset.Test_Step:1 Perform Power Reset on RMODs
    Log to console    \n========================================
    Log to console    Step:1 Perform Power RMOD Reset
    Log to console    ========================================
    Shared Cell procedure check before Reset
    Allow Faults in watchodg before power reset
    Log To Console   Reset RMOD: ${distName}
    REBOOT Radio on APC using SN    ${rmodSerial}
    ${START_TIMESTAMP}    Get Current Date    UTC    #DateTime.Get Current Date  result_format=%Y-%m-%dT%H:%M:%S.%f    exclude_millis=True
    Log To Console    ${START_TIMESTAMP}
    Set Test Variable    ${START_TIMESTAMP}
    Wait For Active Fault    faultID=10    unit_path=[${bts_name}] ${distName}    timeout=180s    #No Connection to the unit
    Wait For Inactive Fault    faultID=10  unit_path=[${bts_name}] ${distName}  timeout=240s    #No Connection to the unit
    Run Keyword And Ignore Error    Wait For Inactive Fault    faultID=4589  unit_path=[${bts_name}] ${distName}  timeout=60s  #Unit power reset

SM.48_RMOD_power_reset.Test_Step:2 Check BTS and RMOD status
    Log to console    \n========================================
    Log to console    Test_Step:2 Check BTS after Power RMOD reset
    Log to console    ========================================
    Disallow Faults in watchodg after power reset
    Shared Cell procedure check after Reset
    Wait Until Keyword Succeeds  30s  5s    Radios states check after power reset
    Log To Console    Reset of the radio: ${distName} was successful!
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${counter_diff}!=${0}  Log  Reset Counter Incremented +${counter_diff}  WARN

SM.48_RMOD_power_reset.Test_Step:3 Final Checkpoint
    Log to console    \n========================================
    Log to console    Test_Step:3 KPI Measurement
    Log to console    ========================================
    Run Keyword And Ignore Error  Calculate KPI54a KPI54b    ${START_TIMESTAMP}    ${ITERATION_INDEX}

SM.48_RMOD_power_reset.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY

Select RMOD for power reset
    ${bts_info}=  admin.get bts info
    ${rmods}=    Create Dictionary
    FOR  ${item}  IN  @{bts_info['radioModules']['rmod']}
        Set To Dictionary  ${rmods}  ${item['id']['configuration']}    ${item['serialNumber']}
    END
    ${selected_rmod}=    Run Keyword If    ${ITERATION_INDEX} != 1    While Loop for selecting RMOD    ${rmods}
    ...    ELSE    Evaluate  random.choice(list(${rmods}.items()))  random
    Set Suite Variable  ${last_selected_rmod}  ${selected_rmod}
    Log To Console  Selected RMOD configuration: ${selected_rmod}
    ${rmodSerial}    Set Variable    ${selected_rmod}[1]
    ${distName}    Set Variable    ${selected_rmod}[0]
    Set Test Variable    ${rmodSerial}
    Set Test Variable    ${distName}

While Loop for selecting RMOD
    [Arguments]    ${rmods}
    ${selected_rmod}=    Set Variable    ${last_selected_rmod}
    WHILE  ${selected_rmod} == ${last_selected_rmod}
        ${selected_rmod}=  Evaluate  random.choice(list(${rmods}.items()))  random
    END
    [Return]    ${selected_rmod}

Radios states check after power reset
    Log To Console  Checking if selected RMOD has reached the expected state: operationalState=Disabled, the rest of the RMODs should remain Enabled
    Run Keyword If  ${AVAILABLE_CHAINS_INDEX}!={}  Run Keywords
    ...             Log To Console  Exception: if RMOD is in chain with RMOD that is being reset, its expected state can be Enabled,  no_newline=true
    ...        AND  Log To Console  ${SPACE}if its position in chain is before, or Disabled, if positioned after RMOD that is being reset.
    ${bts_info}  admin.get bts info
    FOR  ${rmod}  IN  @{bts_info['radioModules']['rmod']}
        ${position_in_chain}  Run Keyword If  '${rmod['id']['configuration']}' in $chain_dict
        ...                                   Get From Dictionary  ${chain_dict}  ${rmod['id']['configuration']}
        ...                             ELSE  Set Variable  0
        ${rmod_states}  Get From Dictionary  ${rmod}  status
        ${operational_state}  Get From Dictionary  ${rmod_states}  operationalState
        ${operational_state_upper}  Evaluate  "${operational_state}".upper()
        Run Keyword If  '${rmod['id']['configuration']}'=='${distName}' and '${operational_state_upper}'!='ENABLED'
        ...             Should Be Equal As Strings  ${operational_state}  disabled  ignore_case=True
        ...    ELSE IF  ${is_in_chain} and ${position_in_chain}>${selected_position_in_chain} and '${operational_state_upper}'!='ENABLED'
        ...             Should Be Equal As Strings  ${operational_state}  disabled  ignore_case=True
        ...       ELSE  Should Be Equal As Strings  ${operational_state}  enabled   ignore_case=True
        ${administrative_state}  Get From Dictionary  ${rmod_states}  administrativeState
        Should Be Equal As Strings  ${administrative_state}  Unlocked  ignore_case=True
        Log To Console  State of ${rmod['id']['configuration']} is correct
    END
    Check If NLWG Cells Are OnAir
    ${if_gsm_exist}  Run Keyword And Return Status  List Should Contain Value  ${rats}  gsm
    Run Keyword If  ${if_gsm_exist}  Wait Until Keyword Succeeds  3min  30s  Check State on GNCELs  availabilityStatus  None

Shared Cell procedure check before Reset
    ${is_in_chain}  Set Variable If  '${distName}' in $RMOD_TO_CHAIN_INDEX_MAPPING  True  False
    ${chain_index}  Run Keyword If  ${is_in_chain}  Get From Dictionary  ${RMOD_TO_CHAIN_INDEX_MAPPING}  ${distName}
    ${chain_dict}   Run Keyword If  ${is_in_chain}  Get From Dictionary  ${AVAILABLE_CHAINS_INDEX}       ${chain_index}
    ...                       ELSE  Create Dictionary
    ${selected_position_in_chain}  Run Keyword If  ${is_in_chain}  Get From Dictionary  ${chain_dict}  ${distName}
    ${shared_cell}  Check If Cells Configured On Other RMOD  ${distName}
    Run Keyword If  ${shared_cell}
    ...  Allow Fault In Watchdog  faultID=4003  #fault_name: Transmission path failure
    Set Test Variable    ${shared_cell}
    Set Test Variable    ${chain_dict}
    Set Test Variable    ${is_in_chain}
    Set Test Variable    ${selected_position_in_chain}

Shared Cell procedure check after Reset
    Run Keyword If  ${shared_cell}  Run Keywords
    ...         Run Keyword And Ignore Error  Wait For Inactive Fault  faultID=4003  timeout=60 sec  #fault_name: Transmission path failure
    ...  AND    Disallow Fault In Watchdog  faultID=4003  #fault_name: Transmission path failure

Allow Faults in watchodg before power reset
    Allow Fault In Watchdog  faultID=4589  #fault_name: Unit power reset
    Allow Fault In Watchdog  faultID=10  #fault_name: No connection to unit
    Allow Fault In Watchdog  faultID=1972  #fault_name: RRU power loss
    Allow Fault In Watchdog  faultID=1815  #fault_name: Not able to synchronize baseband bus

Disallow Faults in watchodg after power reset
    Disallow Fault In Watchdog  faultID=4589  #fault_name: Unit power reset
    Disallow Fault In Watchdog  faultID=10  #fault_name: No connection to unit
    Disallow Fault In Watchdog  faultID=1972  #fault_name: RRU power loss
    Disallow Fault In Watchdog  faultID=1815  #fault_name: Not able to synchronize baseband bus
