*** Settings ***
Library    OperatingSystem
Library    Collections
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/bts_states.robot


*** Keywords ***
TC__LOGS__Default_fault_triggers
    [Documentation]
    ...  [CASE LINK]:
    ...  https://jiradc.ext.net.nokia.com/browse/TAT-25051
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case created to verify if fault snapshot triggers can be configured and validated only with correct coverage level
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 24.03.2023 - Damian Kotula - Test rewritten based on BOAM ET test -
    ...                 CB008626-C-05_manully_configure_fault_2_and_3_RU_default_faults_with_different_coverage_failed
    ...  *******************
    ...  Test case flowchart  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/
    ...                       LOGS__CB008626_Fault_Snapshot_Triggers_With_Unsupported_Coverage_Level_Validation.png
    ...  *******************

    Set Tags    CA-LOGS    AUTHOR-damian.kotula@nokia.com    MAINTAINER-damian.kotula@nokia.com
    ...   GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS23R2    FEATURE-CB008626

    Step 0: Preconditions
    Step 1: Check If Fault Snapshot Triggers Can Be Configured And Validated Only With Correct Coverage Level

Step 0: Preconditions
    [Documentation]
    ...  In this step current scf is saved, it will be recomissioned after test end.
    ...  Configured faultSnapshotTriggers are removed, so it's easier to check if any faultSnapshotTriggers activated.

    Log  \nStep 0: Preconditions  console=${True}
    ${BTS_ID}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}
    Set Test Variable  ${TRBL_MNLENT_DISTNAME}  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    coam.Get Current Scf File  ${BTS Files}  Initial_scf.xml  export_type=configuration
    Remove Configured faultSnapshotTriggers
    Enable actDefaultFaultSnapTriggers

Step 1: Check If Fault Snapshot Triggers Can Be Configured And Validated Only With Correct Coverage Level
    [Documentation]
    ...  In this step it is checked if faultSnapshotTriggers for faults 2/1996/4694/4707 can only be validated and activated with
    ...  supported snapshot coverage levels.

    Log  \nStep 1: Check If Fault Snapshot Triggers Can Be Configured And Validated Only With Correct Coverage Level  console=${True}
    Check Nr of Default Faults    23

    Check Default Faults  2  MinorWithoutRFLogs    onFaultDetection    0
    Check Default Faults  1996  L1Files   onFaultDetection    1
    Check Default Faults  4076  Full   onFaultDetection    2
    Check Default Faults  4546  Full   onFaultDetection    3
    Check Default Faults  4548  Full   onFaultDetection    4
    Check Default Faults  4599  Full   onFaultDetection    5
    Check Default Faults  4600  Full   onFaultDetection    6
    Check Default Faults  4601  Full   onFaultDetection    7
    Check Default Faults  4694  L1Files   onFaultDetection    8
    Check Default Faults  4707  L1Files   onFaultDetection    9
    Check Default Faults  6253  Full   onFaultDetection    10
    Check Default Faults  6257  Full   onFaultDetection    11
    Check Default Faults  1815  Full   onAlarmSend    12
    Check Default Faults  1868  Full   onAlarmSend    13
    Check Default Faults  3030  Full   onAlarmSend    14
    Check Default Faults  4090  Full   onAlarmSend    15
    Check Default Faults  4261  Full   onAlarmSend    16
    Check Default Faults  4463  Full   onAlarmSend    17
    Check Default Faults  4547  Full   onAlarmSend    18
    Check Default Faults  4708  Full   onAlarmSend    19
    Check Default Faults  4709  Full   onAlarmSend    20
    Check Default Faults  10  Full   onAlarmCancellation    21
    Check Default Faults  4352  Full   onAlarmCancellation    22

Check Nr of Default Faults
    [Arguments]  ${n}
    ${trblcadm_conf}  Query Infomodel  query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/MNL_CONF_M-*/MNLENT_CONF_M-*/TRBLCADM_CONF_M-*
    ${count_faultSnapshotTriggers}  Evaluate  len(${trblcadm_conf['faultSnapshotTriggers']})
    Should Be True  ${count_faultSnapshotTriggers}==${n}

Check Default Faults

    [Arguments]  ${faultID}  ${supported_coverage}  ${triggerType_defined}=onFaultDetection    ${i}=0

    ${trblcadm_conf}  Query Infomodel  query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/MNL_CONF_M-*/MNLENT_CONF_M-*/TRBLCADM_CONF_M-*

    ${actual_faultSnapshotTrigger_values}  Create List  ${trblcadm_conf['faultSnapshotTriggers'][${i}]['faultNumber']}
    ...  ${trblcadm_conf['faultSnapshotTriggers'][${i}]['snapshotCoverageLevel']}  ${trblcadm_conf['faultSnapshotTriggers'][${i}]['triggerType']}

    ${check_entry_result}  Run Keyword And Return Status  Should Be Equal As Strings
    ...  ${actual_faultSnapshotTrigger_values}  [${faultID}, '${supported_coverage}', '${triggerType_defined}']

    Run Keyword If  ${check_entry_result}
    ...  Log  \nFault ${faultID} found in default list - OK  console=${True}
    ...  ELSE  verdicts.Set Test Failed    Fault ${faultID} NOT found in default list.    ${TRUE}


Remove Configured faultSnapshotTriggers
    [Documentation]
    ...  In this KW delta which removes all faultSnapshotTriggers is prepared and recomissioned.

    ${delta_id}  Set Variable  delete_triggers
    coam.Create Delta  ${delta_id}
    coam.Append Parameter Delete To Delta  ${TRBL_MNLENT_DISTNAME}  parameter=faultSnapshotTriggers  delta_id=${delta_id}
    coam.Append Parameter Update To Delta    ${TRBL_MNLENT_DISTNAME}    actDefaultFaultSnapTriggers  false  ${delta_id}
    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS Files}/delete_triggers_delta.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS Files}/delete_triggers_delta.json  skip_parameter_relation_errors=${True}

Enable actDefaultFaultSnapTriggers

    Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${TRBL_MNLENT_DISTNAME}  parameter=actDefaultFaultSnapTriggers
    ...  operation=update  value=true  skip_parameter_relation_errors=True
    ...  AND  Log  Parameter actDefaultFaultSnapTriggers changed from false to true  console=${True}

Check Fault Snapshot Triggers Configuration With Specified Coverage
    [Documentation]
    ...  This KW verifies if faultSnapshotTriggers for faults 2/1996/4694/4707 can only be validated and activated with
    ...  supported snapshot coverage levels.
    ...  For fault 2, only MinorWithoutRFLogs coverage level is supported and should activate.
    ...  For faults 1996/4694/4707, only L1Files coverage level is supported and should activate.
    [Arguments]  ${faultID}  ${supported_coverage}  ${triggerType_defined}=onFaultDetection

    Configure faultSnapshotTriggers With 1 Trigger  ${faultID}  ${triggerType_defined}  ${supported_coverage}
    ${trblcadm_conf}  Query Infomodel  query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/MNL_CONF_M-*/MNLENT_CONF_M-*/TRBLCADM_CONF_M-*
    ${count_faultSnapshotTriggers}  Evaluate  len(${trblcadm_conf['faultSnapshotTriggers']})
    Should Be True  ${count_faultSnapshotTriggers}==1
    ${actual_faultSnapshotTrigger_values}  Create List  ${trblcadm_conf['faultSnapshotTriggers'][0]['faultNumber']}
    ...  ${trblcadm_conf['faultSnapshotTriggers'][0]['snapshotCoverageLevel']}  ${trblcadm_conf['faultSnapshotTriggers'][0]['triggerType']}
    ${valid_activation_succeded}  Run Keyword And Return Status  Should Be Equal As Strings
    ...  ${actual_faultSnapshotTrigger_values}  [${faultID}, '${supported_coverage}', '${triggerType_defined}']
    ${not_valid_activation_failed}  Run Keyword And Return Status  Try To Configure Fault With Not Valid Coverage  ${faultID}
    Run Keyword If  ${valid_activation_succeded} and ${not_valid_activation_failed}
    ...  Log  \nFault snapshot trigger for fault ${faultID} validated only with coverage ${supported_coverage} - OK  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Fault snapshot trigger validation failed.  ${TRUE}

Configure faultSnapshotTriggers With 1 Trigger
    [Documentation]
    ...  This KW configures faultSnapshotTriggers with specified fault.
    [Arguments]  ${faultNumber}  ${triggerType}  ${snapshotCoverageLevel}=Full  ${snapshotFilterKeywords}=${EMPTY}  ${operation}=update

    ${dict_fault_values}  Create Dictionary  faultNumber  ${faultNumber}  snapshotCoverageLevel  ${snapshotCoverageLevel}
    ...  triggerType  ${triggerType}  snapshotFilterKeywords  ${snapshotFilterKeywords}
    @{fault_param_list}  Create List  ${dict_fault_values}
    ${dict_fault}  Create Dictionary  parameterName  faultSnapshotTriggers  operation  update  value  ${fault_param_list}
    @{fault_list}  Create List  ${dict_fault}
    coam.Perform Object Recommissioning  ${TRBL_MNLENT_DISTNAME}  ${fault_list}  ${operation}

Try To Configure Fault With Not Valid Coverage
    [Documentation]
    ...  This KW verifies if faultSnapshotTriggers for faults 2/1996/4694/4707 cannot be validated with not supported snapshotCoverageLevel.
    ...  Keyword tries to activate every unsupported coverage level with every trigger type and passes if all attempts fail to validate.
    [Arguments]  ${faultID}

    @{triggerType_list}  Create List  onFaultDetection  onAlarmSend  onFaultCancellation  onAlarmCancellation
    FOR  ${triggerType}  IN  @{triggerType_list}
         ${result}  Run Keyword And Return Status  Configure faultSnapshotTriggers With 1 Trigger  ${faultID}  ${triggerType}  ${EMPTY}
         Should Be True  ${result}==${False}
         ${result}  Run Keyword And Return Status  Configure faultSnapshotTriggers With 1 Trigger  ${faultID}  ${triggerType}  Full
         Should Be True  ${result}==${False}
         ${result}  Run Keyword And Return Status  Configure faultSnapshotTriggers With 1 Trigger  ${faultID}  ${triggerType}  Minor
         Should Be True  ${result}==${False}
         ${result}  Run Keyword And Return Status  Configure faultSnapshotTriggers With 1 Trigger  ${faultID}  ${triggerType}  Healthcheck
         Should Be True  ${result}==${False}
         ${result}  Run Keyword And Return Status  Configure faultSnapshotTriggers With 1 Trigger  ${faultID}  ${triggerType}  FullWithoutRFLogs
         Should Be True  ${result}==${False}
         ${result}  Run Keyword And Return Status  Configure faultSnapshotTriggers With 1 Trigger  ${faultID}  ${triggerType}  SystemModuleHealthcheck
         Should Be True  ${result}==${False}
         ${result}  Run Keyword If  ${faultID}==1996  Run Keyword And Return Status  Configure faultSnapshotTriggers With 1 Trigger
         ...  ${faultID}  ${triggerType}  MinorWithoutRFLogs
         Run Keyword If  ${faultID}==1996  Should Be True  ${result}==${False}
         ${result}  Run Keyword If  ${faultID}==4694  Run Keyword And Return Status  Configure faultSnapshotTriggers With 1 Trigger
         ...  ${faultID}  ${triggerType}  MinorWithoutRFLogs
         Run Keyword If  ${faultID}==4694  Should Be True  ${result}==${False}
         ${result}  Run Keyword If  ${faultID}==4707  Run Keyword And Return Status  Configure faultSnapshotTriggers With 1 Trigger
         ...  ${faultID}  ${triggerType}  MinorWithoutRFLogs
         Run Keyword If  ${faultID}==4707  Should Be True  ${result}==${False}
         ${result}  Run Keyword If  ${faultID}==2  Run Keyword And Return Status  Configure faultSnapshotTriggers With 1 Trigger
         ...  ${faultID}  ${triggerType}  L1Files
         Run Keyword If  ${faultID}==2  Should Be True  ${result}==${False}
    END

Custom Test Teardown
    coam.Perform Commissioning  scf_file=${BTS Files}/Initial_scf.xml  skip_parameter_relation_errors=${True}  should_activate=${True}
    Wait Until Keyword Succeeds  20m  1m  Check All Modules And All Cells Working States

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...  Custom Test Teardown
    ...  AND  interface.Common step trigger
    ...  AND  Setup Scout And Send Configuration
    ...  AND  Common Test Teardown
