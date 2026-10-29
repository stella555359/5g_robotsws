*** Settings ***
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/bts_states.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  coam

*** Variables ***
${FAULT_ID}    49



*** Keywords ***
TC__LOGS__LTE2237_Recommissioning_Configuration

    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24207
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Purpose of this test case is check fault trigger type change
    ...  ******************
    ...  History of changes
    ...  ******************

    ...  - 01.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24207 - Test rewritten based on BOAM ET test -
    ...  [1][1.0] OAM_LTE2237_Recommissioning_Configuration
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 17.05.2023 - Iuliia Taupeka: TAT-25384 - list_name= param added to KW AppendComplexItemToDelta

    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/LOGS__LTE2237_Recommissioning_Configuration.png
    ...

    Set Tags      CA-LOGS  OWNER-iuliia.taupeka@nokia.com  AUTHOR-chunjian.pan@nokia.com  MAINTAINER-jakub.kokoszka@nokia.com
    ...           GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT  SW-SBTS23R1  FEATURE-LTE2237  LTE3332-S-b  LTE3332-T-b  RP002771-C-a

    Step 0: Preconditions
    Step 1: Fault trigger type change and check



Step 0: Preconditions
    [Documentation]
    ...  In this step test prepare two deltas with different faultSnapshotTriggers type and save it test files

    Log  \nStep 0: Preconditions  console=${True}
    ${bts_connection}=  coam.connect_to
    Set Test Variable  ${BTS_CONNECTION}  ${bts_connection}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}

    ${delta_id}  Set Variable  parameters_change
    coam.Create Delta  ${delta_id}
    Set Test Variable    ${DELTA_ID}  ${delta_id}
    ${fault_snapshot_triggers_dict}  Create Dictionary  faultNumber=${FAULT_ID}  triggerType=onFaultDetection
    coam.Append Complex Item To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1  list_name=faultSnapshotTriggers  &{fault_snapshot_triggers_dict}
    ...  delta_id=${delta_id}
    coam.Get Delta  ${DELTA_ID}
    coam.Save Delta  ${BTS Files}/delta_onFaultDetection.json  ${DELTA_ID}

    ${delta_id2}  Set Variable  parameters_change2
    coam.Create Delta  ${delta_id2}
    Set Test Variable    ${DELTA_ID2}  ${delta_id2}
    ${fault_snapshot_triggers_dict}  Create Dictionary  faultNumber=${FAULT_ID}  triggerType=onFaultCancellation
    coam.Append Complex Item To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1  list_name=faultSnapshotTriggers  &{fault_snapshot_triggers_dict}
    ...  delta_id=${DELTA_ID2}
    coam.Get Delta  ${DELTA_ID2}
    coam.Save Delta  ${BTS Files}/delta_onFaultCancellation.json  ${DELTA_ID2}



Step 1: Fault trigger type change and check
    [Documentation]
    ...  In this step test recommission deltas and check faultNumber and trigger type

    Log  \nStep 1: Fault trigger type change and check  console=${True}
    Log  Adding parameter faultSnapshotTriggers = onFaultDetection and faultNumber=${FAULT_ID}  console=${True}
    coam.Perform Delta Recommissioning    delta_file=${BTS Files}/delta_onFaultDetection.json    skip_parameter_relation_errors=${True}
    Check if FAULT_SNAPSHOT_TRIGGER '${FAULT_ID}' is 'onFaultDetection'

    Log  Adding parameter faultSnapshotTriggers = onFaultCancellation and faultNumber=${FAULT_ID}  console=${True}
    coam.Perform Delta Recommissioning    delta_file=${BTS Files}/delta_onFaultCancellation.json    skip_parameter_relation_errors=${True}
    Check if FAULT_SNAPSHOT_TRIGGER '${FAULT_ID}' is 'onFaultCancellation'



Check if FAULT_SNAPSHOT_TRIGGER '${faultNumber}' is '${triggerType}'
    [Documentation]
    ...  This KW check faultNumber and trigger type in infomodel after change

    ${FAULT_SNAPSHOT_TRIGGER_path}  Set Variable  /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-1/MRBTS_A-*/MNL_A-1/MNLENT_A-1/TRBLCADM_A-1
    Log  checking if faultNumber = ${faultNumber} and triggerType = ${triggerType}    console=${True}
	ute_admin_infomodel.Query infomodel  query=${FAULT_SNAPSHOT_TRIGGER_path} is [faultSnapshotTriggers[0].faultNumber=${faultNumber}]  timeout=50
	ute_admin_infomodel.Query infomodel  query=${FAULT_SNAPSHOT_TRIGGER_path} is [faultSnapshotTriggers[0].triggerType=${triggerType}]  timeout=50



Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}
    ${delta_id3}  Set Variable  teardown
    coam.Create Delta  ${delta_id3}
    Run Keywords
    ...  Log  Removing faultSnapshotTrigger object from configuration  console=${True}
    ...  AND  coam.Append Parameter Delete To Delta    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1    faultSnapshotTriggers    ${delta_id3}
    ...  AND  coam.Get Delta  ${delta_id3}
    ...  AND  coam.Save Delta  ${BTS Files}/delta_teardown.json  ${delta_id3}
    ...  AND  coam.Perform Delta Recommissioning    delta_file=${BTS Files}/delta_teardown.json    skip_parameter_relation_errors=${True}
    coam.Remove All Delta Id



TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
