*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS__CM__Generate_FID4525_by_Recommissioning_CB007588
Variables    tc_variables/sbts_sbts_sbts__cm__generate_fid4525_by_recommissioning_CB007588_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${WAIT_AFTER_RECOMMISSIONING}  1020     # Time to wait after recommissioning before the cell status is checked
${REPEAT_COUNTER}       3               # Number of SBTS1 Recommissioning operations, default value 3
${RECOMMISSIONING_SBTS1_WRONG}          #Absolute path for wrong SCF file commissioning for SBTS1 (i.e. /home/ute/btsauto/SCF_01_SBTS19.xml).
${RECOMMISSIONING_SBTS1_CORRECT}  NONE  #Absolute path for correct SCF file commissioning for SBTS1 (i.e. /home/ute/btsauto/SCF_01_SBTS19.xml).
                                        # If NONE, current SCF will be used
${SBTS_SCF_VALIDATION}   True           # Validate SBTS SCF; can be True or False
${SBTS_EXPECTED_RESET_NUMBER}      1       # The expected reset number of SBTS. If the actual reset number is different, a warning will be raised.
${VERDICT_WRONG_SBTS_RESET_NUMBER}  PASS   # The test verdict in case of wrong SBTS Reset Number. Values: PASS(passed with restriction) or FAIL(Cloud)

*** Keywords ***
TC__SBTS_SBTS_SBTS__CM__Generate_FID4525_by_Recommissioning_CB007588
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23507
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS test case for Recommissiong SBTS1
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for SBTS1, SBTS2, SBTS3
    ...  - get initial RESET info from blackbox files for all BTS
    ...  - perform Recommissioning operation on SBTS1
    ...  - check final SW versions from all BTS partitions
    ...  - get final RESET info from blackbox files for all BTS
    ...  - check reset behavior on all BTS after Recommissioning
    ...  - check state and alarms for all BTS after SW Update operation
    ...  Pass criteria: BTS Recommissioning operation works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23834 - [5G] Common part fails for SBTS_SBTS_SBTS configuration
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-23507_SBTS_SBTS_SBTS__CM__Generate_FID4525_by_Recommissioning_CB007588.png
    ...

    Set Tags    CA-CM    OWNER-adrian.ierulesc@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT    SW-SBTS23R1

    TC Parameters check
    Step 1: Check initial BTS Master state
    Step 2: Check initial BTS Slave state
    Step 3: Check initial BTS Slave1 state
    Step 4: Check initial BTS Master alarms
    Step 5: Check initial BTS Slave alarms
    Step 6: Check initial BTS Slave1 alarms
    Step 7: Get RMOD Info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 8: Recommission SBTS1 with wrong SCF
        Step 9: Check BTS state and alarms after Recommissioning
        Step 10: Recommission SBTS1 with correct SCF
        Step 11: Check final BTS Master state
        Step 12: Check final BTS Slave state
        Step 13: Check final BTS Slave1 state
        Step 14: Check final BTS Master alarms
        Step 15: Check final BTS Slave alarms
        Step 16: Check final BTS Slave1 alarms
        Step 17: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Parameters check
    Run Keyword If  '${RECOMMISSIONING_SBTS1_WRONG}' == ''  Run Keywords
    ...  Log  RECOMMISSIONING_SBTS1_WRONG parameter cannot be empty!  level=ERROR  console=True
    ...  AND  Fail  RECOMMISSIONING_SBTS1_WRONG parameter cannot be empty!
    ${scf_path_tmp}=  Run Keyword If  '${RECOMMISSIONING_SBTS1_CORRECT}' == 'NONE'
    ...  Admin Collect scf.xml with timestamp TAF  alias=Master  folder_path=${BTSFiles}/Master
    ...  ELSE  Set Variable  ${RECOMMISSIONING_SBTS1_CORRECT}
    OperatingSystem.File Should Exist  ${scf_path_tmp}
    ${bts_info_tmp}=  Admin Get BTS state info  alias=Master
    Set Test Variable  ${correct_scf_path}  ${scf_path_tmp}
    Set Test Variable  ${wrong_scf_path}  ${RECOMMISSIONING_SBTS1_WRONG}
    Set Test Variable  ${bts_info}  ${bts_info_tmp}
    Set Test Variable  ${Commissioned_correct}  False
    Set Test Variable  ${Commissioned_wrong}  False
    Set Test Variable  ${After_recommissioning_waited}  False

Step ${index}: Check ${when} BTS ${alias} state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    [Timeout]  15 min
    ${BTS}=  Set Variable If  '${alias}' == 'Master'  SBTS1  '${alias}' == 'Slave'  SBTS2  '${alias}' == 'Slave1'  SBTS3
    Log  Step ${index}: Check ${when} ${BTS} state  console=True
    Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
    Log  ${BTS} site - proceduralState: OnAir, blockingState: Unblocked  console=True

Step ${index}: Check ${when} BTS ${alias} alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from admin

    [Timeout]  15 min
    ${BTS}=  Set Variable If  '${alias}' == 'Master'  SBTS1  '${alias}' == 'Slave'  SBTS2  '${alias}' == 'Slave1'  SBTS3
    Log  Step ${index}: Check ${when} ${BTS} alarms  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${SBTS_${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${SBTS_${alias.upper()}_CRITICAL_ALARMS}
    Log  ${BTS} site - expected, ignored and critical alarms checked  console=True

Step ${index}: Recommission SBTS1 with ${type} SCF
    Log  Step ${index}: Recommission SBTS1 with ${type} SCF  console=True

    Log  Commissioning via ADMIN will be performed using ${${type}_scf_path}  console=True
    coam.Perform Commissioning  bts_id=${bts_info[0]}  scf_file=${${type}_scf_path}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=400  alias=Master
    Run Keyword If  '${type}' == 'correct'  Set Test Variable  ${Commissioned_correct}  True
    ...  ELSE IF  '${type}' == 'wrong'  Set Test Variable  ${Commissioned_wrong}  True
    Log  SBTS1 commissioning has been performed using ${type} SCF  console=True

    Run Keyword If  ${SBTS_SCF_VALIDATION}  Run Keywords
    ...  Log  Validate SBTS SCF after Recommissioning  console=True
    ...  AND  Admin Validate SCF TAF  alias=Master
    ...  AND  Admin Validate SCF With Detected Hardware  alias=Master

    Check SW configuration did not change

Step ${index}: Check BTS state and alarms after Recommissioning
    Log  Step ${index}: Check BTS state and alarms after Recommissioning  console=True
    ${alarm_count}=  Get Length  ${OBSAI_RMOD_list}
    ${SBTS_MASTER_EXPECTED_ALARMS_4525_full}=  Prepare Expected Alarms List  ${SBTS_MASTER_EXPECTED_ALARMS_4525}  ${alarm_count}
    Run Keyword If  ${alarm_count} > 0
    ...  Log  SBTS1 "Unsupported radio connection configuration detected (4525)" alarm, expected: ${alarm_count}  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=${SBTS_MASTER_EXPECTED_ALARMS_4525}  ignored_alarms=${SBTS_MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${SBTS_MASTER_CRITICAL_ALARMS}
    Run Keyword If  ${alarm_count} > 0
    ...  Log  SBTS1 "Unsupported radio connection configuration detected (4525)" alarm, found: ${alarm_count}  console=True
    Run Keyword If  ${NR_CELL_CPRI_RMOD_list}
    ...  Check Cells State  NRCEL  ${NR_CELL_CPRI_RMOD_list}  blockingState=${Unblocked_}, operationalState=${Disabled_}  60  Master
    Run Keyword If  ${LTE_CELL_CPRI_RMOD_list}
    ...  Check Cells State  LNCEL  ${LTE_CELL_CPRI_RMOD_list}  blockingState=${Unblocked_}, operationalState=${Disabled_}  60  Master
    Run Keyword If  ${WCDMA_CELL_CPRI_RMOD_list}
    ...  Check Cells State  WNCEL  ${WCDMA_CELL_CPRI_RMOD_list}  blockingState=${Unblocked_}, operationalState=${Disabled_}  60  Master
    Run Keyword If  ${GSM_CELL_CPRI_RMOD_list}
    ...  Check Cells State  GNCEL  ${GSM_CELL_CPRI_RMOD_list}  blockingState=${Unblocked_}, operationalState=${Disabled_}  60  Master

    Run Keyword If  ${NR_CELL_OBSAI_RMOD_list}
    ...  Check Cells State  NRCEL  ${NR_CELL_OBSAI_RMOD_list}  blockingState=${Unblocked_}, operationalState=${Disabled_}  60  Master
    Run Keyword If  ${LTE_CELL_OBSAI_RMOD_list}
    ...  Check Cells State  LNCEL  ${LTE_CELL_OBSAI_RMOD_list}  blockingState=${Unblocked_}, operationalState=${Disabled_}  60  Master
    Run Keyword If  ${WCDMA_CELL_OBSAI_RMOD_list}
    ...  Check Cells State  WNCEL  ${WCDMA_CELL_OBSAI_RMOD_list}  blockingState=${Unblocked_}, operationalState=${Disabled_}  60  Master
    Run Keyword If  ${GSM_CELL_OBSAI_RMOD_list}
    ...  Check Cells State  GNCEL  ${GSM_CELL_OBSAI_RMOD_list}  blockingState=${Unblocked_}, operationalState=${Disabled_}  60  Master
    Log  All SBTS1 cells are as expected!  console=True

    Log  Wait ${WAIT_AFTER_RECOMMISSIONING}s(According to WAIT_AFTER_RECOMMISSIONING parameter) after Recommissioning  console=True
    Sleep  ${WAIT_AFTER_RECOMMISSIONING}s
    Set Test Variable  ${Waited_after_recommissioning}  Trues

    Run Keyword If  ${NR_CELL_CPRI_RMOD_list}
    ...  Check Cells State  NRCEL  ${NR_CELL_CPRI_RMOD_list}  blockingState=${Unblocked_}, operationalState=${Enabled_}  60  Master
    Run Keyword If  ${LTE_CELL_CPRI_RMOD_list}
    ...  Check Cells State  LNCEL  ${LTE_CELL_CPRI_RMOD_list}  blockingState=${Unblocked_}, operationalState=${Enabled_}  60  Master
    Run Keyword If  ${WCDMA_CELL_CPRI_RMOD_list}
    ...  Check Cells State  WNCEL  ${WCDMA_CELL_CPRI_RMOD_list}  blockingState=${Unblocked_}, operationalState=${Enabled_}  60  Master
    Run Keyword If  ${GSM_CELL_CPRI_RMOD_list}
    ...  Check Cells State  GNCEL  ${GSM_CELL_CPRI_RMOD_list}  blockingState=${Unblocked_}, operationalState=${Enabled_}  60  Master

    Run Keyword If  ${NR_CELL_OBSAI_RMOD_list}
    ...  Check Cells State  NRCEL  ${NR_CELL_OBSAI_RMOD_list}  blockingState=${Unblocked_}, operationalState=${Disabled_}  60  Master
    Run Keyword If  ${LTE_CELL_OBSAI_RMOD_list}
    ...  Check Cells State  LNCEL  ${LTE_CELL_OBSAI_RMOD_list}  blockingState=${Unblocked_}, operationalState=${Disabled_}  60  Master
    Run Keyword If  ${WCDMA_CELL_OBSAI_RMOD_list}
    ...  Check Cells State  WNCEL  ${WCDMA_CELL_OBSAI_RMOD_list}  blockingState=${Unblocked_}, operationalState=${Disabled_}  60  Master
    Run Keyword If  ${GSM_CELL_OBSAI_RMOD_list}
    ...  Check Cells State  GNCEL  ${GSM_CELL_OBSAI_RMOD_list}  blockingState=${Unblocked_}, operationalState=${Disabled_}  60  Master

    Log  All SBTS1 cells are as expected!  console=True

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view. Works
    ...  for NR and LTE technologies.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks  wait_timer=18 min


Check SW configuration did not change
    [Documentation]
    ...  Extract Master and Slave active and passive SWs using Admin and compare to initial values. Fail if something changed

    ${current_active_SW_Master}  ${current_passive_SW_Master}=  Wait Until Keyword Succeeds  5m  20s  Admin Get BTS SW Version  Master
    ${current_active_SW_Slave}  ${current_passive_SW_Slave}=  Wait Until Keyword Succeeds  5m  20s  Admin Get BTS SW Version  Slave
    ${current_active_SW_Slave1}  ${current_passive_SW_Slave1}=  Wait Until Keyword Succeeds  5m  20s  Admin Get BTS SW Version  Slave1
    ${initial_SW_list}=  Create List  ${Master active SW}  ${Master passive SW}  ${Slave active SW}  ${Slave passive SW}  ${Slave1 active SW}
    ...  ${Slave1 passive SW}
    ${current_SW_list}=  Create List  ${current_active_SW_Master}  ${current_passive_SW_Master}
    ...  ${current_active_SW_Slave}  ${current_passive_SW_Slave}  ${current_active_SW_Slave1}  ${current_passive_SW_Slave1}
    ${no_sw_change}=  Run Keyword And Return Status  Should Be Equal  ${initial_SW_list}  ${current_SW_list}
    Run Keyword If  not ${no_sw_change}  Run Keywords
    ...  Log Long String  SW configuration changed! Master SW active/passive: ${current_active_SW_Master}/${current_passive_SW_Master};
    ...  Slave SW active/passive: ${current_active_SW_Slave}/${current_passive_SW_Slave};
    ...  Slave1 SW active/passive: ${current_active_SW_Slave1}/${current_passive_SW_Slave1}  console=True
    ...  AND  Fail  SW configuration changed!

Step ${index}: Get RMOD Info
    Log  Step ${index}: Get RMOD Info  console=True
    ${RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  Master
    ${RMOD_list}=  Get Ids For All  RMOD  Master
    Set Test Variable  ${RMOD_list}
    ${CPRI_RMOD_list}=  Create List
    ${ECPRI_RMOD_list}=  Create List
    ${OBSAI_RMOD_list}=  Create List
    ${NR_CELL_CPRI_RMOD_list}=  Create List
    ${LTE_CELL_CPRI_RMOD_list}=  Create List
    ${WCDMA_CELL_CPRI_RMOD_list}=  Create List
    ${GSM_CELL_CPRI_RMOD_list}=  Create List
    ${NR_CELL_ECPRI_RMOD_list}=  Create List
    ${LTE_CELL_ECPRI_RMOD_list}=  Create List
    ${WCDMA_CELL_ECPRI_RMOD_list}=  Create List
    ${GSM_CELL_ECPRI_RMOD_list}=  Create List
    ${NR_CELL_OBSAI_RMOD_list}=  Create List
    ${LTE_CELL_OBSAI_RMOD_list}=  Create List
    ${WCDMA_CELL_OBSAI_RMOD_list}=  Create List
    ${GSM_CELL_OBSAI_RMOD_list}=  Create List
    Get BTS CELL list by RAT  Master
    FOR  ${item}  IN  @{RMOD_list}
        ${SBTS_NR_CELL_RM_list}  ${SBTS_LTE_CELL_RM_list}  ${SBTS_WCDMA_CELL_RM_list}  ${SBTS_GSM_CELL_RM_list}=  Get RMOD cells  ${item}  Master
        ${RMOD_L3Protocol}=  Get From Dictionary  ${RMOD_L3Protocol_dict}  ${item}
        Run Keyword If  '${RMOD_L3Protocol}' == 'CPRI_RP1'  Run Keywords
        ...  Append To List  ${CPRI_RMOD_list}  ${item}
        ...  AND  Append To List  ${NR_CELL_CPRI_RMOD_list}  @{SBTS_NR_CELL_RM_list}
        ...  AND  Append To List  ${LTE_CELL_CPRI_RMOD_list}  @{SBTS_LTE_CELL_RM_list}
        ...  AND  Append To List  ${WCDMA_CELL_CPRI_RMOD_list}  @{SBTS_WCDMA_CELL_RM_list}
        ...  AND  Append To List  ${GSM_CELL_CPRI_RMOD_list}  @{SBTS_GSM_CELL_RM_list}
        ...  ELSE IF  '${RMOD_L3Protocol}' == 'ECPRI_MPLANE'  Run Keywords
        ...  Append To List  ${ECPRI_RMOD_list}  ${item}
        ...  AND  Append To List  ${NR_CELL_ECPRI_RMOD_list}  @{SBTS_NR_CELL_RM_list}
        ...  AND  Append To List  ${LTE_CELL_ECPRI_RMOD_list}  @{SBTS_LTE_CELL_RM_list}
        ...  AND  Append To List  ${WCDMA_CELL_ECPRI_RMOD_list}  @{SBTS_WCDMA_CELL_RM_list}
        ...  AND  Append To List  ${GSM_CELL_ECPRI_RMOD_list}  @{SBTS_GSM_CELL_RM_list}
        ...  ELSE IF  '${RMOD_L3Protocol}' == 'RP301_RP1'  Run Keywords
        ...  Append To List  ${OBSAI_RMOD_list}  ${item}
        ...  AND  Append To List  ${NR_CELL_OBSAI_RMOD_list}  @{SBTS_NR_CELL_RM_list}
        ...  AND  Append To List  ${LTE_CELL_OBSAI_RMOD_list}  @{SBTS_LTE_CELL_RM_list}
        ...  AND  Append To List  ${WCDMA_CELL_OBSAI_RMOD_list}  @{SBTS_WCDMA_CELL_RM_list}
        ...  AND  Append To List  ${GSM_CELL_OBSAI_RMOD_list}  @{SBTS_GSM_CELL_RM_list}
    END
    Set Test Variable  ${CPRI_RMOD_list}
    Set Test Variable  ${ECPRI_RMOD_list}
    Set Test Variable  ${OBSAI_RMOD_list}
    Set Test Variable  ${NR_CELL_CPRI_RMOD_list}
    Set Test Variable  ${LTE_CELL_CPRI_RMOD_list}
    Set Test Variable  ${WCDMA_CELL_CPRI_RMOD_list}
    Set Test Variable  ${GSM_CELL_CPRI_RMOD_list}
    Set Test Variable  ${NR_CELL_ECPRI_RMOD_list}
    Set Test Variable  ${LTE_CELL_ECPRI_RMOD_list}
    Set Test Variable  ${WCDMA_CELL_ECPRI_RMOD_list}
    Set Test Variable  ${GSM_CELL_ECPRI_RMOD_list}
    Set Test Variable  ${NR_CELL_OBSAI_RMOD_list}
    Set Test Variable  ${LTE_CELL_OBSAI_RMOD_list}
    Set Test Variable  ${WCDMA_CELL_OBSAI_RMOD_list}
    Set Test Variable  ${GSM_CELL_OBSAI_RMOD_list}

Get BTS CELL list by RAT
    [Arguments]  ${alias}
    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${CELL_list}=  Combine Lists   ${NR_CELL_list}  ${LTE_CELL_list}  ${WCDMA_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${SBTS_NR_CELL_list}  ${NR_CELL_list}
    Set Test Variable  ${SBTS_LTE_CELL_list}  ${LTE_CELL_list}
    Set Test Variable  ${SBTS_WCDMA_CELL_list}  ${WCDMA_CELL_list}
    Set Test Variable  ${SBTS_GSM_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${SBTS_CELL_list}  ${CELL_list}

Get RMOD cells
    [Arguments]  ${RM_id}  ${alias}
    ${SBTS_CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${RM_id}  alias=${alias}
    ${SBTS_CELL_not_RM_list}=  Copy List  ${SBTS_CELL_list}
    ${SBTS_NR_CELL_not_RM_list}=  Copy List  ${SBTS_NR_CELL_list}
    ${SBTS_LTE_CELL_not_RM_list}=  Copy List  ${SBTS_LTE_CELL_list}
    ${SBTS_WCDMA_CELL_not_RM_list}=  Copy List  ${SBTS_WCDMA_CELL_list}
    ${SBTS_GSM_CELL_not_RM_list}=  Copy List  ${SBTS_GSM_CELL_list}
    ${SBTS_NR_CELL_RM_list}=  Copy List  ${SBTS_NR_CELL_list}
    ${SBTS_LTE_CELL_RM_list}=  Copy List  ${SBTS_LTE_CELL_list}
    ${SBTS_WCDMA_CELL_RM_list}=  Copy List  ${SBTS_WCDMA_CELL_list}
    ${SBTS_GSM_CELL_RM_list}=  Copy List  ${SBTS_GSM_CELL_list}
    FOR  ${item}  IN  @{SBTS_CELL_RM_list}
        Remove Values From List  ${SBTS_CELL_not_RM_list}  ${item}
        Remove Values From List  ${SBTS_NR_CELL_not_RM_list}  ${item}
        Remove Values From List  ${SBTS_LTE_CELL_not_RM_list}  ${item}
        Remove Values From List  ${SBTS_WCDMA_CELL_not_RM_list}  ${item}
        Remove Values From List  ${SBTS_GSM_CELL_not_RM_list}  ${item}
    END
    FOR  ${item}  IN  @{SBTS_CELL_not_RM_list}
        Remove Values From List  ${SBTS_NR_CELL_RM_list}  ${item}
        Remove Values From List  ${SBTS_LTE_CELL_RM_list}  ${item}
        Remove Values From List  ${SBTS_WCDMA_CELL_RM_list}  ${item}
        Remove Values From List  ${SBTS_GSM_CELL_RM_list}  ${item}
    END

    [Return]  ${SBTS_NR_CELL_RM_list}  ${SBTS_LTE_CELL_RM_list}  ${SBTS_WCDMA_CELL_RM_list}  ${SBTS_GSM_CELL_RM_list}

Check Cells State
    [Arguments]  ${CELL_class}  ${CELL_list}  ${states}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{CELL_list}
        Assert  ${CELL_class}  ${item}  ${states}  timeout=${timeout}  alias=${alias}
    END

Particular Teardown
    Run Keyword If
    ...  '${Commissioned_wrong}'=='True' and '${Commissioned_correct}'=='False' and '${Waited_after_recommissioning}'=='False'  Run Keywords
    ...  Log  Wait ${WAIT_AFTER_RECOMMISSIONING}s(According to WAIT_AFTER_RECOMMISSIONING parameter) before putting the correct SCF  console=True
    ...  AND  Sleep  ${WAIT_AFTER_RECOMMISSIONING}s
    Run Keyword If  '${Commissioned_wrong}' == 'True' and '${Commissioned_correct}' == 'False'  Run Keywords
    ...  Log  Commissioning with Correct SCF  console=True
    ...  AND  coam.Perform Commissioning  bts_id=${bts_info[0]}  scf_file=${correct_scf_path}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=400  alias=Master
    ...  AND  Log  Commissioning with Correct SCF was performed  console=True
    ...  AND  Admin Check BTS RAT Procedural State  alias=Master  timeout=600
    ...  AND  Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=Master

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown


