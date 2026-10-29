*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Keywords ***
TC__FM__Alarm_From_Blocked_Cell_Not_Reported_To_NetAct
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21647
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC performs actions on 2 LTE cells. Both of them are randomly chosen.
    ...  First cell is blocked. Fault 49 must be present in WebEM and Netact. Fault 6117 is triggered for
    ...  this cell and this fault must be active only in WebEM.
    ...  Second cell is locked. Fault 6117 is triggered this time for second cell. In this case, fault 6117
    ...  must be active in WebEM and NetAct.
    ...
    ...  In the end, recovery actions are performed. First cell is unblocked and fault 6117 is deactivated
    ...  by sending this fault with 0 value for parameter state(which is fault state) of send_lom_fault_ind_msg
    ...  keyword, instead of 1 value which activate the fault.
    ...  Second cell is unlocked and fault 6117 is also deactivated for this cell in the same way as earlier for
    ...  first cell.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 23.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21647 - Initial TAT creation
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 01.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22577 - ta_netact_* libary replacement with taf.nms.netact
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 25.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25417 - Use Admin Get LNBTS ID from sbts_admin
    ...  ******************

    Set Tags    CA-FM    OWNER-laura.craciunel@nokia.com    AUTHOR-andrada-lavinia.baleti@nokia.com
    ...    MAINTAINER-andrada-lavinia.baleti@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS21

    Step0: Set dist names for LTE cells
    Step1: Block LTE Cell 1 And Trigger Fault 6117
    Step2: Lock LTE Cell 2 And Trigger Fault 6117
    Step3: Final recovery and check SBTS onAir

Set value for state info
    ${Obj_info}=  Query infomodel  get object //MRBTS_R-*
    ${Obj_stateInfo}=  Run Keyword And Return Status  Variable Should Exist  ${Obj_info['stateInfo']}
    ${STATE_INFO_OBJ_R}  Run Keyword If  ${Obj_stateInfo}
    ...  Set variable  stateInfo.
    ...  ELSE
    ...  Set variable  ${EMPTY}
    Set test variable  ${STATE_INFO_OBJ_R}

Step0: Set dist names for LTE cells
    Run keyword unless  ${SCF_COUNT_LTE}
    ...  Fail  SBTS does not have LTE RAT and TC can not be executed.
    ${LTE_CELLS_DN}  Get dist names for LTE cells
    ${length}  Get length  ${LTE_CELLS_DN}
    Run keyword if  ${length}<2
    ...  Fail  SBTS has less than 2 LTE cells.
    Set test variable  ${LTE_CELLS_DN}
    Set value for state info

Step1: Block LTE Cell 1 And Trigger Fault 6117
    Log  \nStep1: Block LTE Cell 1 And Trigger Fault 6117  console=true
    ${lte_cell_dn}  Get random LTE cell dist name  ${LTE_CELLS_DN}
    Set test variable  ${FIRST_LTE_CELL_DN}  ${lte_cell_dn}
    ${lte_cell_id}  Fetch from right  ${lte_cell_dn}  -
    Set test variable  ${FIRST_LTE_CELL_ID}  ${lte_cell_id}
    Log  LNCEL-${lte_cell_id} block is performing.  console=true
    coam.block_cell  dist_name=${lte_cell_dn}  timeout=300
    Check fault in WebEM  fault_status=active  cell_id=${lte_cell_id}  fault_id=49
    ...  alarm_id=7102  fault_name=Cell blocked  timeout=120
    Send fault  6117  ${lte_cell_id}
    Check fault in WebEM  fault_status=active  cell_id=${lte_cell_id}  fault_id=6117
    ...  alarm_id=7114  fault_name=High interference to UL subframe  timeout=120
    Run keyword if  ${NE3SADAPT}  Run keywords
    ...  Check fault in NetAct  fault_status=active  cell_id=${lte_cell_id}  fault_id=49  fault_name=Cell blocked
    ...  alarm_id=7102  timeout=120
    ...  AND
    ...  Check fault in NetAct  fault_status=inactive  cell_id=${lte_cell_id}  fault_id=6117  fault_name=High interference to UL subframe
    ...  alarm_id=7114  timeout=120

Step2: Lock LTE Cell 2 And Trigger Fault 6117
    Log  \nStep2: Lock LTE Cell 2 And Trigger Fault 6117  console=true
    ${random_lte_cell_dn}  Get random LTE cell dist name  ${LTE_CELLS_DN}
    ${lte_cell_id}  Fetch from right  ${random_lte_cell_dn}  -
    Set test variable  ${SECOND_LTE_CELL_ID}  ${lte_cell_id}
    Log  LNCEL-${lte_cell_id} lock is performing.  console=rue
    Perform delta recommissioning for LTE cell  locked  ${lte_cell_id}
    Send fault  6117  ${lte_cell_id}
    Check fault in WebEM
    ...  fault_status=active  cell_id=${lte_cell_id}  fault_id=6117  fault_name=High interference to UL subframe
    ...  alarm_id=7114  timeout=120
    Run keyword if  ${NE3SADAPT}  Check fault in NetAct
    ...  fault_status=active  cell_id=${lte_cell_id}  fault_id=6117  fault_name=High interference to UL subframe
    ...  alarm_id=7114  timeout=120

Step3: Final recovery and check SBTS onAir
    Log  \nStep3: Final recovery and check SBTS onAir  console=true
    Recovery actions
    ${status}  Run keyword and return status  Wait until keyword succeeds  600  10  Check required states
    Run keyword if  ${status}
    ...  Log  SBTS is on Air. [OK]  console=true
    ...  ELSE
    ...  Set test restriction  SBTS is not on Air. [NOK]
    Check if unexpected alarms are present

Perform delta recommissioning for LTE cell
    [Arguments]  ${cell_operation}  ${cell_id}
    ${bts_id}   Admin Get BTS ID
    ${lnbts_id}  Admin Get LNBTS ID
    ${delta_id}  Set variable  1
    Create delta  ${delta_id}
    Append managed object to delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/LNCEL-${cell_id}  update  ${delta_id}
    Append parameter update to delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/LNCEL-${cell_id}  administrativeState  ${cell_operation}  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS Files}/delta.json  delta_id=${delta_id}
    coam.Perform Delta Recommissioning  ${BTS Files}/delta.json  skip_parameter_relation_errors=True
    Remove delta  ${delta_id}

Send fault
    [Arguments]  ${fault_id}  ${cell_id}
    ${bts_side}  Get BTS side
    Run keyword if  '${bts_side}'=='1'
    ...  Send lom fault ind msg    ${0x10110240}  ${0x10111202}  ${${fault_id}}  ${1}  ${2}  ${1}  ${${cell_id}}
    ...  ELSE
    ...  Send lom fault ind msg    ${0x20110240}  ${0x20111202}  ${${fault_id}}  ${1}  ${2}  ${1}  ${${cell_id}}

Cancel fault
    [Arguments]  ${fault_id}  ${cell_id}
    ${bts_side}  Get BTS side
    Run keyword if  '${bts_side}'=='1'
    ...  Send lom fault ind msg    ${0x10110240}  ${0x10111202}  ${${fault_id}}  ${0}  ${2}  ${1}  ${${cell_id}}
    ...  ELSE
    ...  Send lom fault ind msg    ${0x20110240}  ${0x20111202}  ${${fault_id}}  ${0}  ${2}  ${1}  ${${cell_id}}

Get dist names for LTE cells
    ${LTE_CELLS_DN}  Create list
    ${lte_objects}  Query infomodel  get list //LNCEL_R-*
    FOR  ${lte_obj}  IN  @{lte_objects}
        Append to list  ${LTE_CELLS_DN}  ${lte_obj}[dist_name]
    END
    [Return]  ${LTE_CELLS_DN}

Get random LTE cell dist name
    [Arguments]  ${dn_list}
    ${length}  Get length  ${dn_list}
    ${random_cell}  Evaluate  random.randint(0, ${length}-1)  modules=random
    ${random_lte_cell_dn}  Remove from list  ${dn_list}  ${random_cell}
    [Return]  ${random_lte_cell_dn}

Get BTS side
    ${status}  Query infomodel  check /MRBTS-1/RAT-1/BTS_L-* is [storedRole=Active]  allow_negative_result=True
    ${hwapi_domain}  Run keyword if  ${status}
    ...  Query infomodel  get object /MRBTS-1/RAT-1/BTS_L-* is [storedRole=Active]
    ...  ELSE
    ...  Query infomodel  get object /MRBTS-1/RAT-1/BTS_L-*
    [Return]  ${hwapi_domain.hwapiDomainId}

Check fault in WebEM
    [Arguments]  ${fault_status}  ${cell_id}  ${fault_id}  ${fault_name}  ${alarm_id}  ${timeout}
    ${status}  Run keyword and return status  Wait Until Keyword Succeeds  ${timeout}  10
    ...  Check fault ${fault_status} in WebEM
    ...  cell_id=${cell_id}  fault_id=${fault_id}  fault_name=${fault_name}  alarm_id=${alarm_id}
    Run keyword if  ${status}
    ...  Log  Fault ${fault_id}: ${fault_name} is ${fault_status} in WebEM for LNCEL-${cell_id}. [OK]  console=true
    ...  ELSE
    ...  Set test restriction  Fault ${fault_id}: ${fault_name} is not ${fault_status} in WebEM LNCEL-${cell_id}. [NOK]

Check fault active in WebEM
    [Arguments]  ${cell_id}  ${fault_id}  ${fault_name}  ${alarm_id}
    Check if fault is present in WebEM for given cell
    ...  ${cell_id}  ${fault_id}  ${fault_name}  ${alarm_id}

Check fault inactive in WebEM
    [Arguments]  ${cell_id}  ${fault_id}  ${fault_name}  ${alarm_id}
    ${netact_fault_status}  Run keyword and return status
    ...  Check if fault is present in WebEM for given cell
    ...  ${cell_id}  ${fault_id}  ${fault_name}  ${alarm_id}
    Should be equal  ${netact_fault_status}  ${FALSE}

Check fault in NetAct
    [Arguments]     ${fault_status}  ${cell_id}  ${fault_id}  ${fault_name}  ${alarm_id}  ${timeout}
    ${netact_fault_status}  Run keyword and return status  Wait Until Keyword Succeeds  ${timeout}  10
    ...  Check fault ${fault_status} in Netact  ${cell_id}  ${fault_id}  ${fault_name}  ${alarm_id}
    Run keyword if  ${netact_fault_status}
    ...  Log  Fault ${fault_id} is ${fault_status} in NetAct for LNCEL-${cell_id}. [OK]  console=true
    ...  ELSE
    ...  Set test restriction  Fault ${fault_id} is not ${fault_status} in NetAct for LNCEL-${cell_id}. [NOK]

Check fault active in NetAct
    [Arguments]    ${cell_id}  ${fault_id}  ${fault_name}  ${alarm_id}
    Check if fault is present in NetAct for given cell
    ...  ${cell_id}  ${fault_id}  ${fault_name}  ${alarm_id}

Check fault inactive in Netact
    [Arguments]     ${cell_id}  ${fault_id}  ${fault_name}  ${alarm_id}
    ${netact_fault_status}  Run keyword and return status
    ...  Check if fault is present in NetAct for given cell
    ...  ${cell_id}  ${fault_id}  ${fault_name}  ${alarm_id}
    Should be equal  ${netact_fault_status}  ${FALSE}

Check if fault is present in WebEM for given cell
    [Arguments]  ${cell_id}  ${fault_id}  ${fault_name}  ${alarm_id}
    ${active_alarms}  coam.Get active alarms
    FOR  ${alarm}  IN  @{active_alarms}
        ${cell_id_status}  Run keyword and return status  Should contain  ${alarm}[configObjectName]  LNCEL-${cell_id}
        ${fault_id_status}  Run keyword and return status  Should be equal as strings  ${alarm}[faultId]  ${fault_id}
        ${fault_name_status}  Run keyword and return status  Should be equal as strings  ${alarm}[faultName]  ${fault_name}
        ${alarm_id_status}  Run keyword and return status  Should be equal as strings  ${alarm}[alarmId]  ${alarm_id}
        ${match}  Set variable if  ${cell_id_status} and ${fault_id_status} and ${fault_name_status} and ${alarm_id_status}
        ...  True  False
        Exit for loop if  ${match}==True
    END
    Should Be Equal As Strings  ${match}  True

Check if fault is present in NetAct for given cell
    [Arguments]  ${cell_id}  ${fault_id}  ${fault_name}  ${alarm_id}
    ${netact_alarms}  netact.get_alarms  dist_name=${MRBTS_DN}
    FOR  ${na_alarm}  IN  @{netact_alarms}
         ${additional_text3}     Get From Dictionary    ${na_alarm}    additionalText3
         ${check_cell_id}   Run Keyword And Return Status    Should Contain   ${additional_text3}    LNCEL-${cell_id}
         ${check_fault_id}   Run Keyword And Return Status    Should Contain   ${additional_text3}    ${fault_id}
         ${additional_text1}     Get From Dictionary    ${na_alarm}    additionalText1
         ${check_fault_name}   Run Keyword And Return Status    Should Be Equal As Strings   ${additional_text1}    ${fault_name}
         ${specific_problem}     Get From Dictionary    ${na_alarm}    specificProblem
         ${check_alarm_id}   Run Keyword And Return Status    Should Be Equal As Strings   ${specific_problem}    ${alarm_id}
         ${match}=  Set Variable If  ${check_fault_id} and ${check_cell_id} and ${check_fault_name} and ${check_alarm_id}
         ...  True  False
         Exit For Loop If    ${match} == True
    END
    Should Be Equal As Strings    ${match}    True

Check if unexpected alarms are present
    ${fault_list}  Create list
    ${active_alarms}  coam.Get active alarms
    FOR  ${alarm}  IN  @{active_alarms}
        ${faultId}  Convert to string  ${alarm}[faultId]
        ${fault_dict}  Create dictionary  faultId=${faultId}  faultName=${alarm}[faultName]
        Append to list  ${fault_list}  ${fault_dict}
    END
    FOR  ${fault}  IN  @{fault_list}
        Check if active fault is present in ignored alarm list  ${GLOBALLY_IGNORED_ALARMS}  ${fault}
    END
    Run keyword if  ${NE3SADAPT}
    ...  Check if alarms from WebEM and NetAct are the same

Check if active fault is present in ignored alarm list
    [Arguments]   ${alarms_list}  ${fault}
    FOR  ${alarm}  IN  @{alarms_list}
        ${fault_id_status}  Run keyword and return status  Should be equal as strings  ${fault}[faultId]  ${alarm}[faultId]
        ${fault_name_status}  Run keyword and return status  Should contain  ${fault}[faultName]  ${alarm}[faultName]
        Run keyword if  ${fault_id_status} and ${fault_name_status}
        ...  Return from keyword
    END
    Set test restriction  Unexpected fault: ${fault}[faultId], ${fault}[faultName].

Check required states
    Run Keyword If    ${SCF_COUNT_NR}
    ...    Assert Every    NRCEL    operationalState=${Enabled_}
    Run Keyword If    ${SCF_COUNT_LTE}
    ...    Assert Every    LNCEL    operationalState=${Enabled_}
    Run Keyword If    ${SCF_COUNT_WCDMA}
    ...    Assert Every    WNCEL    operationalState=${Enabled_}
    Run Keyword If    ${SCF_COUNT_GSM}
    ...    Assert Every    GNCEL    operationalState=${Enabled_}

    Assert Every    RMOD    operationalState=${Enabled_}
    Assert Every    SMOD    operationalState=${Enabled_}

Recovery actions
    ${first_cell_status}  Query infomodel  check //LNCEL_R-${FIRST_LTE_CELL_ID} is [${STATE_INFO_OBJ_R}blockingState=${Blocked_}]
    ...  allow_negative_result=True
    Run keyword if  ${first_cell_status}
    ...  First LTE cell recovery
    ${first_cell_status}  Query infomodel  check //LNCEL_R-${SECOND_LTE_CELL_ID} is [${STATE_INFO_OBJ_R}administrativeState=${Locked_}]
    ...  allow_negative_result=True
    Run keyword if  ${first_cell_status}
    ...  Second LTE cell recovery

First LTE cell recovery
    coam.unblock_cell  dist_name=${FIRST_LTE_CELL_DN}  timeout=300
    Wait until keyword succeeds  60  10  Check fault inactive in WebEM  ${FIRST_LTE_CELL_ID}  49  Cell blocked  7102
    Cancel fault  6117  ${FIRST_LTE_CELL_ID}
    Wait until keyword succeeds  60  10  Check fault inactive in WebEM  ${FIRST_LTE_CELL_ID}  6117  High interference to UL subframe  7114

Second LTE cell recovery
    Perform delta recommissioning for LTE cell  unlocked  ${SECOND_LTE_CELL_ID}
    Cancel fault  6117  ${SECOND_LTE_CELL_ID}
    Wait until keyword succeeds  60  10  Check fault inactive in WebEM  ${SECOND_LTE_CELL_ID}  6117  High interference to UL subframe  7114

TC Setup
    Common Test Setup
    ${NE3SADAPT}  Query infomodel  check //NE3SADAPT-*  allow_negative_result=True
    Set test variable  ${NE3SADAPT}
    Run keyword if  ${NE3SADAPT}
    ...  Setup NetAct

TC Teardown
    Run keyword if test failed  Run keywords
    ...  Log  Recovery actions are performed.  console=true
    ...  AND
    ...  Recovery actions
    Run keyword if  ${NE3SADAPT}
    ...  Teardown NetAct
    Common Test Teardown
