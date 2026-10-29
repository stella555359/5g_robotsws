*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${RECOVERY_TIMEOUT}   900
${PING_TIMEOUT}       180
${ONAP_IP}                       #ip to connect to ONAP
${WORKER_IP}                     #any WORKER IP can be chosen (from ONAP)
${ONAP_USERNAME}                 #user name for ONAP connection (usually root)
${ONAP_PASSWORD}

*** Keywords ***
TC__FM__Report_alarms_triggered_on_SMOD_CELL_to_ONAP
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23485
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC is created to report alarms triggered on SMOD and on a chosen cell in WebEM and ONAP.
    ...  The connection to ONAP is opened, then the ONAP object and VESENDPOINTS are created. The reference to VESENDPOINT-2 is changed.
    ...  The fault 1402 is triggered and it should be visible in WebEM and ONAP.
    ...  The severity of the fault 1402 is changed to critical.
    ...  The fault 1402 is canceled, it should not be visible in WebEM. The event is checked in ONAP to be notifyClearedAlarm.
    ...  The reference to VESENDPOINT-3 is changed.
    ...  The fault 49 is triggered and it should be visible in WebEM and ONAP.
    ...  The fault 49 is canceled, it should not be visible in WebEM. The event is checked in ONAP to be notifyClearedAlarm.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23485 - Initial TAT creation
    ...  - 09.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24443 - Change connection type
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  *******************

    Set Tags    CA-FM    OWNER-vincentiu.nacov@nokia.com    AUTHOR-cosmina.rebenciuc@nokia.com    MAINTAINER-cosmina.rebenciuc@nokia.com
    ...    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS22

    Step0: Open connection and set initial variables
    Step1: Configuration of VESENDPOINTS
    Step2: Trigger EAC fault 1402
    Step3: Check FM event is visible in ONAP
    Step4: Change the alarm severity
    Step5: Check FM event is visible in ONAP
    Step6: Cancel fault 1402
    Step7: Check FM event is visible in ONAP
    Step8: Configure path to VESENDPOINT-3
    Step9: Trigger fault 49
    Step10: Check FM event is visible in ONAP
    Step11: Cancel fault 49
    Step12: Check FM event is visible in ONAP

Step0: Open connection and set initial variables
    Log  Step0: Open conection and set initial variables  console=true
    Connect to ONAP  ${ONAP_IP}  ${ONAP_USERNAME}  ${ONAP_PASSWORD}
    ${BTS_ID}=  Admin Get BTS ID
    Set Test Variable  ${BTS_ID}

Step1: Configuration of VESENDPOINTS
    Log  Step1: Configuration of VESENDPOINTS  console=true
    ${object}=  coam.Get Managed Objects  MPLANEONAP_R
    ${status_object}  Run Keyword And Return Status  Should Be Empty  ${object}
    ${status_parameter}  Run Keyword And Return Status  Should Be Empty  ${object}[0][parameters][sftpServerHostPublicKey]
    Run Keyword If  ${status_object} or ${status_parameter}
    ...  Run keywords  Log  Creating MPLANONAP object  console=true  AND  Create MPLANEONAP object
    ...  ELSE
    ...  Delete and recreate MPLANEONAP object  ${RECOVERY_TIMEOUT}
    Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  30  Check modules and cells
    Log  Adding VESENDPOINTS  console=true
    Add certificates to CMP object
    Add VESENDPOINT-ID  1
    Add VESENDPOINT-ID  2
    Add VESENDPOINT-ID  3
    Log  Change VESENDPOINT reference to 2.  console=true
    VES Endpoint reference change    vesFaultCollectorEndpointDN    2

Step2: Trigger EAC fault 1402
    Log  Step2: Trigger EAC fault 1402  console=true
    Set date and time from ONAP
    ONAP parameter change  activateSendingFmEvents  true
    Trigger fault 1402  ${FAULT_1402}[fault_id]  ${FAULT_1402}[fault_name]  Minor
    ${alarm_parameters}  Get string with alarm parameters  ${FAULT_1402}
    Assert alarm active  parameters=${alarm_parameters}
    ...                  timeout=180
    Log  Alarm with fault Id ${FAULT_1402}[fault_id] is reported in WebEM. console=true

Trigger fault 1402
    [Arguments]  ${fault_ID}  ${fault_name}  ${fault_severity}
    ${port_ID}=  set variable if  "${fault_ID}"=="1400"    1    3
    ${mod}=  set variable if  "${fault_name[4:8]}"=="SMOD"    CABINET_A-1/SMOD_A-1    RMOD_A-1
    ${status}  Run keyword and return status  Query infomodel  check //MRBTS_A-${BTS_ID}/EQM_A-1/APEQM_A-1/${mod}/EAC_IN_A-1
    ${operation}  Run Keyword If  ${status}
    ...  Set variable  update
    ...  ELSE
    ...  Set variable  create
    ${mod}  Replace String Using Regexp  ${mod}  _A  ${EMPTY}
    ${dist_name}=  Set Variable  MRBTS-${BTS_ID}/EQM-1/APEQM-1/${mod}/EAC_IN-1
    ${dict_cancelDelay}=  Create dictionary    parameterName=cancelDelay
    ...                                        operation=update
    ...                                        value=0
    ${dict_descr}=  Create dictionary    parameterName=descr
    ...                                  operation=update
    ...                                  value=${fault_name}
    ${dict_inUse}=  Create dictionary    parameterName=inUse
    ...                                  operation=update
    ...                                  value=true
    ${dict_polarity}=  Create dictionary    parameterName=polarity
    ...                                     operation=update
    ...                                     value=Normally_closed
    ${dict_portId}=  Create dictionary    parameterName=portId
    ...                                   operation=update
    ...                                   value=${port_ID}
    ${dict_severity}=  Create dictionary    parameterName=severity
    ...                                     operation=update
    ...                                     value=${fault_severity}
    ${dict_startDelay}=  Create dictionary    parameterName=startDelay
    ...                                       operation=update
    ...                                       value=0
    @{parameter_list}=  Create list    ${dict_cancelDelay}  ${dict_descr}  ${dict_inUse}  ${dict_polarity}
    ...  ${dict_portId}  ${dict_severity}  ${dict_startDelay}
    Perform Object Recommissioning        dist_name=${dist_name}
    ...                                   operation=${operation}
    ...                                   skip_parameter_relation_errors=${False}
    ...                                   should_activate=${True}
    ...                                   parameter=@{parameter_list}

Step${index}: Check FM event is visible in ONAP
    Log  Step${index}: Check FM event is visible in ONAP  console=true
    Run Keyword If  ${index}==3 or ${index}==5 or ${index}==10
    ...  Check FM event VES  notifyNewAlarm
    ...  ELSE IF  ${index}==7 or ${index}==12
    ...  Check FM event VES  notifyClearedAlarm

Step4: Change the alarm severity
    Log  Step4: Change the alarm severity  console=true
    Change EAC alarm severity  Critical

Change EAC alarm severity
    [Arguments]    ${severity}
    Perform parameter recommissioning
    ...    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1
    ...    parameter=severity
    ...    value=${severity}
    ...    operation=update
    ...    skip_parameter_relation_errors=${True}
    ...    should_activate=${True}
    ...    timeout=180

Step6: Cancel fault 1402
    Log  Step6: Cancel fault 1402  console=true
    Cancel fault 1402  ${FAULT_1402}[fault_id]  ${FAULT_1402}[fault_name]
    ${alarm_parameters}  Get string with alarm parameters  ${FAULT_1402}
    Assert alarm inactive  parameters=${alarm_parameters}
    ...                    timeout=180
    Log  Alarm with fault Id ${FAULT_1402}[fault_id] is reported in WebEM. console=true

Cancel fault 1402
    [Arguments]    ${fault_ID}    ${fault_name}
    ${mod}=    set variable if    "${fault_name[4:8]}"=="SMOD"    CABINET-1/SMOD-1    RMOD-1
    ${dist_name}=  Set Variable  MRBTS-${BTS_ID}/EQM-1/APEQM-1/${mod}/EAC_IN-1
    @{empty_list}   create list
    Perform object recommissioning        dist_name=${dist_name}
    ...                                   operation=delete
    ...                                   skip_parameter_relation_errors=${False}
    ...                                   should_activate=${True}
    ...                                   parameter=${empty_list}

Step8: Configure path to VESENDPOINT-3
    Log  Step8: Configure path to VESENDPOINT-3  console=true
    VES Endpoint reference change    vesFaultCollectorEndpointDN    3

Step9: Trigger fault 49
    Log  Step9: Trigger fault 49  console=true
    Set date and time from ONAP
    ${cells_dn}=  Get Ids for all  LNCEL
    ${chosen_cell}=  Evaluate  random.choice(${cells_dn})  random
    Set test variable  ${CELL}  ${chosen_cell}
    coam.Block Cell  ${cell}
    Log  Fault 49 was sent.  console=true
    ${alarm_parameters}  Get string with alarm parameters  ${FAULT_49}
    Assert alarm active  parameters=${alarm_parameters}
    ...                  timeout=180
    Log  Alarm with fault Id ${FAULT_49}[fault_id] is reported in WebEM. console=true

Step11: Cancel fault 49
    Log  Step11: Cancel fault 49  console=true
    Cancel fault 49
    ${alarm_parameters}  Get string with alarm parameters  ${FAULT_49}
    Assert alarm inactive  parameters=${alarm_parameters}
    ...                    timeout=180
    Log  Alarm with fault Id ${FAULT_49}[fault_id] is reported in WebEM. console=true

Check cell blocking state
    ${cell_parameters}  coam.Get parameters  ${CELL}
    ${status}=  Run Keyword and Return Status  Should contain  ${Blocked_}  ${cell_parameters}[blockingState]
    Run Keyword If  ${status}
    ...  Cancel fault 49
    ...  ELSE
    ...  Log  Fault 49 already canceled.  console=true

Check cell operational state
    ${cell_parameters}  coam.Get parameters  ${CELL}
    ${status}=  Run Keyword and Return Status  Should contain  ${Enabled_}  ${cell_parameters}[operationalState]
    Run Keyword Unless  ${status}
    ...  Fail  Cell is still blocked.

Cancel fault 49
    coam.Unblock Cell  ${CELL}
    ${status}  Run keyword and return status  Wait until keyword succeeds  300  10  Check cell operational state
    Run keyword if  ${status}
    ...  Log  Fault 49 canceled (cell is unblocked).  console=true
    ...  ELSE
    ...  Fail  Didn't manage to cancel fault 49(unblock cell).

Save collector log
    ${containers}  SSHLibrary.Execute Command  kubectl -n onap get pod | grep -i ves
    ${container}   Fetch from left  ${containers}  ${SPACE}
    SSHLibrary.Write  kubectl -n onap exec -it ${container} bash
    SSHLibrary.read until prompt
    SSHLibrary.Write  cat logs/collector.log | grep ${BTS_ID} | grep ${CURRENT_DATE}
    SSHLibrary.Set Client configuration  timeout=40s
    ${events}  SSHLibrary.read until prompt
    ${list_of_events}  Split to lines  ${events}  end=-1
    Create file  ${BTS_FILES}/Report_alarms_triggered_on_SMOD_CELL_to_ONAP/logs/collector.log  ${events}

Restore initial values and save logs
    Save collector log
    ONAP parameter change  activateSendingFmEvents  false
    ${alarm_parameters}  Get string with alarm parameters  ${FAULT_1402}
    ${status}=  Run Keyword and Return Status  Assert alarm active  parameters=${alarm_parameters}
    ...                                                             timeout=180
    Run keyword if  ${status}
    ...  Cancel fault 1402  ${FAULT_1402}[fault_id]  ${FAULT_1402}[fault_name]
    ${status}=  Run Keyword and Return Status  Variable Should Exist  ${CELL}
    Run keyword if  ${status}
    ...  Check cell blocking state
    SSHLibrary.Close Connection

TC Setup
    Common Test Setup  tc_name=FM__Report_alarms_triggered_on_SMOD_CELL_to_ONAP

TC Teardown
    Restore initial values and save logs
    Common Test Teardown
