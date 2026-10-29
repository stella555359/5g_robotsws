*** Settings ***
Documentation    TC__NR_SBTS__STATE__SBTS_RAT_Block_Unblock_from_WEBEM
Variables    ./tc_variables/nr_sbts__state__sbts_rat_block_unblock_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${RAT_TECH}  # Technology for SBTS RAT block/unblock operations, possible values: empty, LTE, WCDMA or GSM
             # default value: empty (block/unblock all existing RAT)
${REPEAT_COUNTER}  3  # Number of SBTS RAT block/unblock operations, default value 3

*** Keywords ***
TC__NR_SBTS__STATE__SBTS_RAT_Block_Unblock_from_WEBEM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21129
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-SBTS test case for SBTS RAT block/unblock operations, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both NR and SBTS technologies
    ...  - get initial RESET info from IMS files for NR and SBTS
    ...  - perform SBTS RAT block/unblock operations as follows:
    ...    - if ${RAT_TECH} is empty (default value), block/unblock all existing SBTS RAT
    ...    - if ${RAT_TECH} is set to a specific technology (LTE, WCDMA or GSM), block/unblock specific technology SBTS RAT
    ...  - check reset behavior on NR and SBTS based on initial and final RESET info as follows:
    ...    - NR site: reset number is 0
    ...    - SBTS site: reset number is 0
    ...  - check final state and alarms for both NR and SBTS technologies
    ...  Pass criteria: SBTS RAT block/unblock works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 11.06.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21129 -
    ...  [5G][SBTS] NR_SBTS__STATE__SBTS_RAT_Block_Unblock_from_WEBEM test should be created
    ...  - 14.09.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21804 - [5G] Refactoring due to stateInfo changes: NR_SBTS
    ...  - 13.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22475 -
    ...  [5G] [Refactoring] Use common procedure for DSS alarms in NR_SBTS scenarios (use Get NR LTE DSS info dict)
    ...  - 14.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-21776 - [5G][Legacy][RFSplit] Test NRSBTS Common Part (hran_ta)
    ...  - 22.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22646 - [Cloud] [RFSplit] [Legacy] Particular teardown refactoring - NR-SBTS part
    ...  - 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23926 - [5G][CNI-82119] Implement new RAT check in RAT Block Unblock tests
    ...  - 14.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24197 - [5G][Reset Number ims2] Update NR-SBTS STATE
    ...  scenarios to take reset number from ims2 - P2
    ...  - 04.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25836 - [5G] Use new DSS mechanism in existing TCs - NR_SBTS RAT actions
    ...  - 24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26296 - [5G] In NR_SBTS__STATE__NR_Cell_BlockUnblock_from_WEBEM info about DSS
    ...  should not be get from ${BTS_DSS_LTE_NR_CELL_runtime_dict}, if DSS isn't configure
    ...  - 24.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29823 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NR_SBTS
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-21129_NR_SBTS__STATE__SBTS_RAT_Block_Unblock_from_WEBEM.png

    Set Tags    CA-STATE    OWNER-marius.roman@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS21B

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 3: Block Unblock SBTS RAT
        Step 4: Check final all BTS state
        Step 5: Check final all BTS alarms
        Step 6: Check NR and SBTS reset behavior based on IMS info
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
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Block Unblock SBTS RAT
    [Documentation]
    ...  Block Unblock RAT procedure is triggered on SBTS Slave.

    Log  Step ${index}: Block Unblock SBTS RAT  console=True

    Run Keyword If  '${RAT_TECH}' in ['LTE',''] and ${SBTS_LTE_cell_ids}  Block Unblock SBTS RAT  LTE
    Run Keyword If  '${RAT_TECH}' in ['WCDMA',''] and ${SBTS_WCDMA_cell_ids}  Block Unblock SBTS RAT  WCDMA
    Run Keyword If  '${RAT_TECH}' in ['GSM',''] and ${SBTS_GSM_cell_ids}  Block Unblock SBTS RAT  GSM

Step ${index}: Check NR and SBTS reset behavior based on IMS info
    [Documentation]
    ...  Final RESET info are compared with initial RESET info for both NR and SBTS based on IMS. Reset behavior as expected if:
    ...  - NR site: reset number is 0
    ...  - SBTS site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check NR and SBTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Master  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Slave  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Block Unblock SBTS RAT
    [Arguments]  ${techno}
    ${RAT_class_name}=  Set Variable If  '${techno}' == 'LTE'  LNBTS  '${techno}' == 'WCDMA'  WNBTS  '${techno}' == 'GSM'  GNBTS
    ${CELL_class_name}=  Set Variable If  '${techno}' == 'LTE'  LNCEL  '${techno}' == 'WCDMA'  WNCEL  '${techno}' == 'GSM'  GNCEL
    Set Test Variable  ${techno}
    Set Test Variable  ${RAT_class_name}
    Set Test Variable  ${CELL_class_name}
    ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${BTS_DSS_NR_LTE_CELL_scf_dict}
    ...  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${BTS_DSS_LTE_NR_CELL_runtime_dict}=  Get all BTS DSS feature info
    ${LNBTS_actLteNrDss}=  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  Slave
    ${DSS_LTE_NR_CELL_dict}=  Run Keyword If  ${LNBTS_actLteNrDss}  Get From Dictionary  ${BTS_DSS_LTE_NR_CELL_runtime_dict}  Slave
    ...  ELSE  Create Dictionary
    Set Test Variable  ${DSS_LTE_NR_CELL_dict}
    Set Test Variable  ${LNBTS_actLteNrDss}

    Block SBTS RAT  ${techno}
    Unblock SBTS RAT  ${techno}

Block SBTS RAT
    [Arguments]  ${techno}
    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Offline_}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}
    ${CELL_state_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=Offline
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled
    ${CELL_state_degraded}=  Set Variable  operationalState=Enabled, availabilityStatus=Degraded

    Run Keyword If  ${LNBTS_actLteNrDss} and '${techno}' == 'LTE'  Get NR DSS alarms

    ${RAT_Id}=  Get Id For Current  class_name=${RAT_class_name}  connection=Slave
    ${RAT_Id}=  Set Variable If  '${techno}' in ['LTE','WCDMA']  ${RAT_Id}  ${RAT_Id}/GNBCF_R-1
    Set Test Variable  ${RAT_Id}
    Get Current Date UTC info  start

    Log  Perform "${techno} Block" operation on SBTS ${techno} RAT from Admin  console=True
    Block Rat  rat=${techno}  timeout=180  connection=Slave
    Sleep  10s

    Log  Check SBTS state and alarm after block SBTS ${techno} RAT  console=True
    Check RAT Status  Slave  ${techno}
    Assert Every  class_name=${CELL_class_name}  parameters=${CELL_state_disabled_check}  timeout=180  connection=Slave
    Log  All SBTS ${techno} cell(s) status:\n - ${CELL_state_disabled}  console=True
    Log  SBTS "RAT blocked (4614)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=${SLAVE_EXPECTED_ALARMS}  ignored_alarms=${SLAVE_IGNORED_ALARMS}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    Log  SBTS "RAT blocked (4614)" alarm, found number: 1, as expected!  console=True
    Log  SBTS site - expected, ignored and critical alarms checked  console=True

    Log  Check NR state and alarm after block SBTS ${techno} RAT  console=True
    Run Keyword If  '${techno}' in ['WCDMA','GSM'] or ('${techno}' == 'LTE' and '${LNBTS_actLteNrDss}' == 'False')  Run Keywords
    ...  Assert Every  class_name=NRCEL  parameters=${CELL_state_enabled_check}  timeout=5  connection=Master
    ...  AND  Log  All NR cells status:\n - ${CELL_state_enabled}  console=True
    ...  AND  Get and Check Alarms SOAM  alias=Master  expected_alarms=@{EMPTY}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    ...  AND  Log  NR site - expected, ignored and critical alarms checked  console=True
    ...  AND  Return From Keyword

    ${NR_CELL_DSS_list}=  Get Dictionary Values  ${DSS_LTE_NR_CELL_dict}
    FOR  ${item}  IN  @{NR_CELL_DSS_list}
        Assert  class_name=NRCEL  id=${item}  parameters=${CELL_state_degraded_check}  timeout=60  connection=Master
    END
    Log  All NR cell(s) impacted by DSS status:\n - ${CELL_state_degraded}  console=True
    Log Long String  NR "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)" alarm,
    ...  expected number: ${NR_alarm_count}  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=${MASTER_EXPECTED_ALARMS_DSS_full}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log Long String  NR "EN DSS De-activated on partner side (7513)" alarm or "EN DSS Keep Alive Procedure Time out (7511)",
    ...  found number: ${NR_alarm_count}, as expected!  console=True
    Log  NR site - expected, ignored and critical alarms checked  console=True

Unblock SBTS RAT
    [Arguments]  ${techno}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled
    Log  Perform "${techno} Unblock" operation on SBTS ${techno} RAT from Admin  console=True
    Unblock Rat  rat=${techno}  timeout=180  connection=Slave
    Sleep  10s

    Log  Check SBTS state and alarm after unblock SBTS ${techno} RAT  console=True
    Check RAT Status  Slave  ${techno}
    Log  SBTS ${techno} RAT status:\n - blockingState=Unblocked  console=True
    Assert Every  class_name=${CELL_class_name}  parameters=${CELL_state_enabled_check}  timeout=180  connection=Slave
    Log  All SBTS ${techno} cell(s) status:\n - ${CELL_state_enabled}  console=True
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=@{EMPTY}  ignored_alarms=${SLAVE_IGNORED_ALARMS}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    Log  SBTS site - expected, ignored and critical alarms checked  console=True

    Log  Check NR state and alarm after unblock SBTS ${techno} RAT  console=True
    Assert Every  class_name=NRCEL  parameters=${CELL_state_enabled_check}  timeout=60  connection=Master
    Log  All NR cell(s) status:\n - ${CELL_state_enabled}  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=@{EMPTY}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log  NR site - expected, ignored and critical alarms checked  console=True

    Get Current Date UTC info  end

Check RAT Status
    [Arguments]  ${alias}  ${techno}
    ${status}=  Get Admin Parameter  dist_name=${RAT_Id}  parameter=blockingState  alias=${alias}
    Run Keyword If  '${status}' in '${Blocked_}'
        ...  Log  SBTS ${techno} RAT status:\n - blockingState=Blocked  console=True
        ...  ELSE IF  '${status}' in '${Unblocked_}'
        ...  Log  SBTS ${techno} RAT status:\n - blockingState=Unblocked  console=True

Get NR DSS alarms
    ${LTE_NR_CELL_DSS_count}=  Get Length  ${DSS_LTE_NR_CELL_dict}
    Set Test Variable  ${NR_alarm_count}  ${LTE_NR_CELL_DSS_count}
    ${MASTER_EXPECTED_ALARMS_DSS_full}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_DSS}  ${NR_alarm_count}
    Set Test Variable  ${MASTER_EXPECTED_ALARMS_DSS_full}

Particular Teardown
    Run Keyword And Continue On Failure  Check if RAT is unblocked  Slave

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
