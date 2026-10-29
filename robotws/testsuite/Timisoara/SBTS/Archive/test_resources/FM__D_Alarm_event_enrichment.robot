*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${ONAP_IP}               100.70.230.210                             # ip to connect to ONAP
${ONAP_USERNAME}         root                                       # user name for ONAP connection (usually ubuntu)
${ONAP_PASSWORD}         arthur                                     # pasword for ONAP connection
${EXPECTED_FAULT_ID}     49                                         # Tested fault id that will be checked by test.
${EXPECTED_FAULT_NAME}   Cell blocked                               # Tested fault name that will be checked by test.
${EXPECTED_ALARM_ID}     7102                                       # Tested alarm id that will be checked by test.
${EXPECTED_ALARM_NAME}   BASE STATION RESOURCE BLOCKED BY USER      # Tested alarm name that will be checked by test.
${SEVERITY}              Critical                                   # Tested severity that will be checked by test.
${TIMEOUT}               240                                        # Timeout that will be checked by test

*** Keywords ***
TC__FM__D_Alarm_event_enrichment
    [Documentation]
    ...
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24379
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC is created to check the alarm event enrichment functionality.
    ...  The connection to ONAP is established, and for checking the present events, a NRCELL cell type is randomly chosen.
    ...  The blocking of the NRCELL cell is generated, it is checked if the event appears in ONAP.
    ...  Change the name of the blocked cell and check if a new event occurs in ONAP.
    ...  The blocked cell is unblocked, and it is checked if the event is present in ONAP.
    ...  The cell name returns to the initial one and is checked if a new event does not appear in ONAP.
    ...  Again the cell blocks and check the new event appeared in ONAP.
    ...  Unblock the cell and check the events in the ONAP.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 13.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24379 - Initial TAT creation
    ...  ******************

    Set Tags    CA-FM    OWNER-lucian.ciurel@nokia.com    AUTHOR-ana.adam@nokia.com    MAINTAINER-ana.adam@nokia.com
    ...    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS23

    Step0: Open conection to ONAP and set variables
    Step1: Generate fault 49
    Step2: Check if FM event is visible in ONAP
    Step3: Operator updates value for cellName
    Step4: Check new events don't appear in ONAP
    Step5: Cancel fault 49
    Step6: Check if FM event is visible in ONAP
    Step7: Operator updates value for cellName
    Step8: Check new events don't appear in ONAP
    Step9: Generate fault 49
    Step10: Check if FM event is visible in ONAP
    Step11: Cancel fault 49
    Step12: Check if FM event is visible in ONAP

Step0: Open conection to ONAP and set variables
    Log  \nStep0: Open conection to ONAP and set variables  console=true
    Connect to ONAP  ${ONAP_IP}  ${ONAP_USERNAME}  ${ONAP_PASSWORD}
    ${BTS_ID}  Admin Get BTS ID
    Set test variable  ${BTS_ID}
    Set date and time from ONAP
    Verify and change act3gppFmEnrichment value  true
    ${CELL_DN}  Get random NRCELL
    Set test variable  ${CELL_DN}
    ${cell_parameters}  Get parameters for  NRCEL  ${cell_dn}
    Set test variable  ${INITIAL_CELL_NAME}  ${cell_parameters}[cellName]
    ${NR_CELL_ID}  Fetch from right  ${CELL_DN}  -
    Set test variable  ${NR_CELL_ID}
    ONAP parameter change  activateSendingFmEvents  true

Step${index}: Generate fault 49
    Log  \nStep${index}: Generate fault 49  console=true
    Set date and time from ONAP
    coam.Block cell  ${CELL_DN}
    Log  \nCell is blocked  console=true
    Check alarm status in WebEM
    ...  active  ${EXPECTED_FAULT_ID}  ${EXPECTED_FAULT_NAME}  ${EXPECTED_ALARM_ID}  ${EXPECTED_ALARM_NAME}   ${SEVERITY}  ${TIMEOUT}

Step${index}: Check if FM event is visible in ONAP
    Log  \nStep${index}: Check FM event is visible in ONAP  console=true
    Run keyword if  ${index}==2 or ${index}==10
    ...  Wait until keyword succeeds  120  10  Check FM event VES  notifyNewAlarm
    ...  ELSE IF  ${index}==6 or ${index}==12
    ...  Wait until keyword succeeds  130  10s  Check FM event VES  notifyClearedAlarm

Step${index}: Operator updates value for cellName
    Log  \nStep${index}: Operator updates value for cellName  console=true
    Set date and time from ONAP
    ${before_active_alarms}  coam.Get active alarms
    Run Keyword If  ${index}==3  Run keywords
    ...  Perform delta recommissioning for NR cell  ${INITIAL_CELL_NAME}_update  ${NR_CELL_ID}
    ...  AND  Check if alarm don't appear in WebEM  ${before_active_alarms}
    ...  ELSE IF  ${index}==7  Run keywords
    ...  Perform delta recommissioning for NR cell  ${INITIAL_CELL_NAME}  ${NR_CELL_ID}
    ...  AND  Check if alarm don't appear in WebEM  ${before_active_alarms}

Step${index}: Check new events don't appear in ONAP
    Log  \nStep${index}: Check new events don't appear in ONAP.  console=true
    Set date and time from ONAP
    ${status}  Run keyword and return status  Wait until keyword succeeds  120  10  Check FM event VES  notifyNewAlarm
    Run keyword if  ${status}
    ...  Fail  New event is present in ONAP
    ...  ELSE
    ...  Log  New event is not reported in ONAP.  console=true

Step${index}: Cancel fault 49
    Log  \nStep${index}: Cancel fault 49  console=true
    Set date and time from ONAP
    coam.Unblock cell  ${CELL_DN}
    Check alarm status in WebEM
    ...  inactive  ${EXPECTED_FAULT_ID}  ${EXPECTED_FAULT_NAME}  ${EXPECTED_ALARM_ID}  ${EXPECTED_ALARM_NAME}   ${SEVERITY}  ${TIMEOUT}
    Wait until keyword succeeds  300  10s  Check cell to be enabled

Verify and change act3gppFmEnrichment value
    [Arguments]  ${value}
    ${dist_name_bts_id}=    Set variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    ${get_parameter_value}=   Get act3gppFmEnrichment value from infomodel  act3gppFmEnrichment
    Run Keyword If  '${get_parameter_value}'!='${value}'   Run Keywords
    ...  Perform Parameter Recommissioning    ${dist_name_bts_id}   act3gppFmEnrichment   update   ${value}  skip_parameter_relation_errors=${True}
    ...  timeout=300  AND
    ...  Log  act3gppFmEnrichment will be changed to ${value}  console=yes
    ...  ELSE
    ...  Log  Parameter act3gppFmEnrichment is ${value}, no need to change  console=yes

Get act3gppFmEnrichment value from infomodel
    [Arguments]   ${im_parameter}
    ${parametr_name}=  Convert To String  ${im_parameter}
    ${parameter_object}=  query infomodel
    ...  get object /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-*/SCF-1/MRBTS_A-${BTS_ID}/MNL_A-1/MNLENT_A-1/FMCADM_A-1
    ${parameter_object_value_string}=  Convert To String  ${parameter_object.${parametr_name}}
    ${parameter_object_lower}=  Convert To Lowercase   ${parameter_object_value_string}
    [Return]  ${parameter_object_lower}

Get random NRCELL
    ${cell_list}  Run keyword if  ${SCF_COUNT_NR}
    ...  Get ids for all  NRCEL
    ...  ELSE
    ...  Fail  There are no NRCEL.
    ${cell_dn}  Evaluate  random.choice(${cell_list})   random
    [Return]  ${cell_dn}

Perform delta recommissioning for NR cell
    [Arguments]  ${cell_name}  ${cell_id}
    ${nrbts_id}  Admin Get NRBTS ID
    ${delta_id}  Set variable  1
    Create delta  ${delta_id}
    Append managed object to delta  MRBTS-${BTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id}  update  ${delta_id}
    Append parameter update to delta  MRBTS-${BTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id}  cellName  ${cell_name}  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS Files}/delta.json  delta_id=${delta_id}
    coam.Perform Delta Recommissioning  ${BTS Files}/delta.json  skip_parameter_relation_errors=True
    Remove delta  ${delta_id}

Check cell to be enabled
     ${cell_parameters}  coam.Get parameters  ${CELL_DN}
     ${status}  Run keyword and return status  Should contain  ${Enabled_}  ${cell_parameters}[operationalState]
     Run keyword unless  ${status}
     ...  Fail  Cell still blocked.

Check if alarm don't appear in WebEM
    [Arguments]  ${before_active_alarms}
    ${after_active_alarms}  coam.Get active alarms
    ${length_before}  Get Length  ${before_active_alarms}
    ${length_after}  Get Length  ${after_active_alarms}
    Run keyword if  ${length_before}==${length_after}
    ...  Log  \nDon't appear a new active alarm after updates value for CellName  console==true
    ...  ELSE
    ...  Fail  Appear a new active alarm after updates value for CellName.  console=true

TC Setup
    Common Test Setup

TC Teardown
    Perform delta recommissioning for NR cell  ${INITIAL_CELL_NAME}  ${NR_CELL_ID}
    ${status}  Run keyword and return status  Check cell to be enabled
    Run keyword unless  ${status}
    ...  coam.Unblock cell  ${CELL_DN}
    Common Test Teardown
