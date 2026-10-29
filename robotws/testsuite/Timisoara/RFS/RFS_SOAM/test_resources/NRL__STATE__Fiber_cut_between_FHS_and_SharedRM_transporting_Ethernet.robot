*** Settings ***
Documentation    TC__NRL__STATE__Fiber_cut_between_FHS_and_SharedRM_transporting_Ethernet
Variables    tc_variables/nrl__state__fiber_cut_between_fhs_and_sharedrm_transporting_ethernet_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3                    # Number of Cutting the Fiber between FHS and the Ethernet transporting RMOD , default value 3
${RMOD1_SN}                             # Serial Number of the first RMOD
${RMOD1_FHS_Calient_Crossconnection}    # Crossconnection between FHS and RMOD1; example: 1.2.1-5.6.1
${RMOD2_SN}                             # Serial Number of the second RMOD
${RMOD2_FHS_Calient_Crossconnection}    # Crossconnection between FHS and RMOD2; example: 1.2.1-5.6.1
${RMOD3_SN}                             # Serial Number of the third RMOD
${RMOD3_FHS_Calient_Crossconnection}    # Crossconnection between FHS and RMOD3; example: 1.2.1-5.6.1
${RMOD4_SN}                             # Serial Number of the forth RMOD
${RMOD4_FHS_Calient_Crossconnection}    # Crossconnection between FHS and RMOD4; example: 1.2.1-5.6.1
${RMOD5_SN}                             # Serial Number of the fifth RMOD
${RMOD5_FHS_Calient_Crossconnection}    # Crossconnection between FHS and RMOD5; example: 1.2.1-5.6.1
${RMOD6_SN}                             # Serial Number of the sixth RMOD
${RMOD6_FHS_Calient_Crossconnection}    # Crossconnection between FHS and RMOD6; example: 1.2.1-5.6.1

*** Keywords ***
TC__NRL__STATE__Fiber_cut_between_FHS_and_SharedRM_transporting_Ethernet
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21332
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for Fiber cut between NR Dedicated FHS and RMOD transporting Ethernet, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - perform Fiber cut between FHS and Ethernet transporting RMOD
    ...  - check that Ethernet has moved to other RMOD connected to FHS
    ...  - perform Fiber restore between FHS and RMOD
    ...  - check final state and alarms for both both BTS
    ...  Pass criteria: Fiber cut operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 18.08.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21332 -
    ...  [5G][MT][Obsai] New NRL scenario NRL_RFS_OBSAI_link between FHS to shared RF transporting Ethernet fails in NR-LTE OBSAI RF sharing
    ...  - 03.09.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21804 - [5G] Refactoring due to stateInfo changes: NRL
    ...  - 06.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-21775 - [5G][Legacy][RFSplit] Test NRL Common Part (hran_ta)
    ...  - 14.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22637
    ...  - [5G] NRL__STATE__Fiber_cut_between_FHS_and_SharedRM_transporting_Ethernet fails during Assert
    ...  - 14.02.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-22640 - [Cloud] [RFSplit] [Legacy] Particular teardown refactoring - NRL part
    ...  - 27.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23184
    ...  - [5G][Calient] Remove extra parameters from connection details so will use Calient defauls
    ...  - 02.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23886 - [5G][TC review][NRL] Remove Cells "AdministrativeState" check in all
    ...  NRL robots
    ...  - 04.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24008 - [5G][TC review][NRL] Please display expected alarm in console
    ...  - 15.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23185
    ...  - [5G][Calient] Create cross-connect with saved options not with default ones or hardcoded values
    ...  - 22.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25369 - [5G] [Refactoring Tracker] Update rfs_optical_switch resources with
    ...  connection_ID instead of connection_name
    ...  - 17.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26162 -
    ...  [5G] LTE_Site_Reset_from_WEBEM_SharedFHS_mixed_OBSAI_CPRI - update for FID10
    ...  - 15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26595 - [5G] Add check for BTS state in TCs with Power on / unlock / unblock /
    ...  commissioning in Particular Teardown
    ...  - 22.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27537 - Test adaptation following common test setup variable removal
    ...  - 02.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27823 - [CNI-127210] [Part 2] DSS LTE EXPECTED alarms check removal NR_* TCs
    ...  - after DSS discussion is concluded
    ...  - 11.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-27835 -
    ...  Remove infomodel use for NRL__STATE__Fiber_cut_between_FHS_and_SharedRM_transporting_Ethernet.robot
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-21332_NRL__STATE__Fiber_cut_between_FHS_and_SharedRM_transporting_Ethernet.png

    Set Tags    CA-STATE    OWNER-bogdan.vinereanu@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT    SW-SBTS21B

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get NR FHS List
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Cut and Restore Fiber between FHS and Shared RM transporting Ethernet
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True
    ${wait_for_alarm_clear}=  Set Variable If  '${when}' == 'final'  15 min  5 min
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}  wait_for_alarm_clear=${wait_for_alarm_clear}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get NR FHS list
    [Documentation]
    ...  NR FHS list is get from Admin

    [Timeout]  5 min
    Log  Step ${index}: Get NR FHS list  console=True
    ${NR_FHS_list}=  Admin Get FHS Ids  alias=Master
    ${NR_FHS_count}=  Get Length  ${NR_FHS_list}
    Run Keyword If  ${NR_FHS_count} > 0
    ...  Log  NR FHS found: ${NR_FHS_list}  console=True
    ...  ELSE
    ...  Fail  No NR FHS are present in runtime view configuration!
    Set Test Variable  ${NR_FHS_list}
    Set Test Variable  ${NR_FHS_count}

    Optical Switch Setup  switch_ip=${OPTICAL_SWITCH['IP']}
    ...  switch_username=${OPTICAL_SWITCH['USERNAME']}  switch_password=${OPTICAL_SWITCH['PASSWORD']}  port=${OPTICAL_SWITCH['PORT']}
    Log  Optical Switch Setup successfull  console=True

    ${SharedRM_SN_CrossConnect_dict}=  Create Dictionary
    FOR  ${i}  IN RANGE  1  7
        Run Keyword If  '${RMOD${i}_SN}'!=''  Set To Dictionary  ${SharedRM_SN_CrossConnect_dict}  ${RMOD${i}_SN}
        ...  ${RMOD${i}_FHS_Calient_Crossconnection}
        ...  ELSE  Continue For Loop
        ${connection_status}=  Get Cross Connection Status by Id  ${RMOD${i}_FHS_Calient_Crossconnection}
        Run Keyword If  '${connection_status}' == False  Fail  Given Cross Connection:${connection_status} does not exist
    END
    Set Test Variable  ${SharedRM_SN_CrossConnect_dict}

    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get Shared And Dedicated RM List for Master and Slave  Master  Slave
    Get RM SN list  Master
    Get RM SN list  Slave
    Set Test Variable  ${Master_shared_RMOD_list}
    Set Test Variable  ${Slave_shared_RMOD_list}

    ${NR_RMOD_list}=  Get Ids For All  RMOD  alias=Master
    Sort List  ${NR_RMOD_list}
    Set Test Variable  ${NR_RMOD_list}
    ${LTE_RMOD_list}=  Get Ids For All  RMOD  alias=Slave
    Sort List  ${LTE_RMOD_list}
    Set Test Variable  ${LTE_RMOD_list}

    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=Master
    Set Test Variable  ${NR_CELL_list}
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=Slave
    Set Test Variable  ${LTE_CELL_list}

    Get RM SN dict  NR  Master
    Get RM SN dict  LTE  Slave

Get RM SN dict
    [Arguments]  ${tech}  ${alias}
    ${RM_SN_dict}=  Create Dictionary
    FOR  ${item}  IN  @{${tech}_RMOD_list}
        ${RM_PARAM_list}=  Get Parameters For  RMOD  ${item}  alias=${alias}
        Run Keyword If  '${tech}' == 'NR'
        ...  Set To Dictionary  ${RM_SN_dict}  ${RM_PARAM_list['id']}  ${RM_PARAM_list['serialNumber']}
        ...  ELSE IF  '${tech}' == 'LTE'
        ...  Set To Dictionary  ${RM_SN_dict}  ${RM_PARAM_list['serialNumber']}  ${RM_PARAM_list['id']}
    END
    Set Test Variable  ${${tech}_RM_SN_dict}  ${RM_SN_dict}

Step ${index}: Cut and Restore Fiber between FHS and Shared RM transporting Ethernet
    [Documentation]
    ...  Cut Fiber between FHS and Shared RM transporting Ethernet

    Log  Step ${index}: Cut and Restore Fiber between FHS and Shared RM transporting Ethernet  console=True
    FOR  ${item}  IN  @{NR_FHS_list}
        Cut and Restore Fiber between FHS and Shared RM trasporting Ethernet  ${item}
    END

Cut and Restore Fiber between FHS and Shared RM trasporting Ethernet
    [Arguments]  ${FHS_id}
    ${RMOD_state_disabled_check}=  Set Variable
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RMOD_state_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, administrativeState=${Unlocked_}
    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}

    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    FOR  ${RMOD_id}  IN  @{NR_RMOD_list}
        ${ethernetEnabled_status}=  Get ethernetEnabled from CABLINK  ${RMOD_id}  Master
        Run Keyword If  not ${ethernetEnabled_status}  Continue For Loop
        ${RM_SN}=  Get From Dictionary  ${NR_RM_SN_dict}  ${RMOD_id}
        ${cross_connect}=  Get From Dictionary  ${SharedRM_SN_CrossConnect_dict}  ${RM_SN}
        Save cross connection details  ${cross_connect}
        Remove Cross Connection By Id  ${cross_connect}
        ${status_cross_connect}=  Get Cross Connection Status by Id  ${cross_connect}
        Run Keyword If  '${status_cross_connect}' == 'False'
        ...  Log  Cross connection: ${cross_connect} has been removed between FHS:${FHS_id} and RMOD: ${RMOD_id}  console=True
        ...  ELSE  Fail  Removing Cross Connection: ${cross_connect} failed
        Exit For Loop
    END
    Set Test Variable  ${cross_connect}

    Get LTE RM based on SN  ${RM_SN}
    ${NR_CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${RMOD_id}  alias=Master
    ${LTE_CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${LTE_RM_id}  alias=Slave

    Log  Check NR states and alarms after Fiber Cut  console=True
    Assert  RMOD  ${RMOD_id}  ${RMOD_state_disabled_check}  timeout=60  alias=Master
    Check BTS Item State  NR  NRCEL  ${NR_CELL_RM_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  60  Master
    Get and Check Alarms SOAM  alias=Master  expected_alarms=@{NR_EXPECTED_ALARMS}  ignored_alarms=${NR_IGNORED_ALARMS}
    ...  critical_alarms=${NR_CRITICAL_ALARMS}
    FOR  ${item}  IN  @{NR_RMOD_list}
        ${ethernetEnabled_status}=  Get ethernetEnabled from CABLINK  ${item}  Master
        Run Keyword If  ${ethernetEnabled_status}  Log  Ethernet trasporting has moved to RMOD: ${item}  console=True
    END
    Log  Check LTE states and alarms after Fiber Cut  console=True
    Assert  RMOD  ${LTE_RM_id}  ${RMOD_state_degraded_check}  timeout=60  alias=Slave
    Check BTS Item State  LTE  LNCEL  ${LTE_CELL_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  60  Slave
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=@{EMPTY}  ignored_alarms=${LTE_IGNORED_ALARMS}
    ...  critical_alarms=${LTE_CRITICAL_ALARMS}

    Create Cross Connection with Options by Id  new_connection=${cross_connect}  group=${options['group']}  conn=${options['connid']}
    ...  dir=${options['dir'].lower()}  band=${options['band'][0]}  nolight=${options['nolight']}  deadreckon=${options['deadreckon']}
    ${status_cross_connect}=  Get Cross Connection Status by Id  ${cross_connect}
    Run Keyword If  ${status_cross_connect}  Log  Cross Connection: ${cross_connect} successfully recreated  console=True
    ...  ELSE  Fail  Cross Connection: ${cross_connect} coudn't be established

    Log  Check NR states and alarms after Fiber Restore  console=True
    Check BTS Item State  NR  RMOD  ${NR_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  60  Master
    Check BTS Item State  NR  NRCEL  ${NR_CELL_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  60  Master
    Get and Check Alarms SOAM  alias=Master  expected_alarms=@{EMPTY}  ignored_alarms=${NR_IGNORED_ALARMS}  critical_alarms=${NR_CRITICAL_ALARMS}
    Log  Check LTE states and alarms after Fiber Restore  console=True
    Check BTS Item State  LTE  RMOD  ${LTE_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  60  Slave
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=@{EMPTY}  ignored_alarms=${LTE_IGNORED_ALARMS}  critical_alarms=${LTE_CRITICAL_ALARMS}

Check BTS Item State
    [Arguments]   ${tech}  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${BTS_item_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_item_list}
        Assert  ${BTS_item_class}  ${item}  ${BTS_item_state_check}  timeout=${timeout}  alias=${alias}
        Log  ${tech} ${BTS_item_class} ${item} status:\n - ${BTS_item_state}  console=True
    END

Get LTE RM based on SN
    [Arguments]  ${RM_SN}
    FOR  ${item}  IN  @{Slave_RM_SN_list}
        Run Keyword If   '${item[0]}' == '${RM_SN}'  Run Keywords
        ...     Set Test Variable  ${LTE_RM_id}  ${item[2]}
        ...     AND  Exit For Loop
    END

Get RM SN list
    [Arguments]  ${alias}
    ${RM_SN_list}=  Create List  @{EMPTY}
    ${RMOD_param}=  Get Parameters For All  RMOD  alias=${alias}
    FOR  ${item}  IN  @{RMOD_param}
        ${Rmod_label}=  Fetch From Right  ${item.id}  /
        @{temp}=  Create List
        ...  ${item.serialNumber}
        ...  ${Rmod_label}
        ...  ${item.id}
        ...  ${item.productName}
        Append To List  ${RM_SN_list}  ${temp}
    END
    Sort List  ${RM_SN_list}
    Set Test Variable  ${${alias.upper()}_RM_SN_list}  ${RM_SN_list}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Save cross connection details
    [Arguments]  ${cross_connect}
    ${options}=  Get Cross Connection details  ${cross_connect}
    Set Test Variable  ${options}

Particular Teardown
    ${cross_connect_status}=  Get Cross Connection Status by Id  ${cross_connect}
    Run Keyword If  '${cross_connect_status}'=='False'  Create Cross Connection with Options by Id  ${cross_connect}  group=${options['group']}
    ...  conn=${options['connid']}  dir=${options['dir'].lower()}  band=${options['band'][0]}  nolight=${options['nolight']}
    ...  deadreckon=${options['deadreckon']}
    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
