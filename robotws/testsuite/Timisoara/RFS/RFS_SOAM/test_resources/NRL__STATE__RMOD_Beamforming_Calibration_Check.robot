*** Settings ***
Documentation    TC__NRL__STATE__RMOD_Beamforming_Calibration_Check
Variables    tc_variables/nrl__state__rmod_beamforming_calibration_check_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${BEAMFORMING_CALIBRATION_WAIT_TIME}  16  # Wait time for beamforming related alarms to be generated, default value 16 minutes
${REPEAT_COUNTER}  3  # Number of LANE lock/unlock operations, default value 3

*** Keywords ***
TC__NRL__STATE__RMOD_Beamforming_Calibration_Check
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23661
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NRL test case for Beamforming Calibration Check
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get shared RMOD info
    ...  - check feature Beamforming enabled on NR BTS cells
    ...  - perform RMOD sync link change
    ...  - check final state and alarms for both BTS
    ...  - check no Beamforming Calibration alarms present after RMOD calibration retry time (ex: scorpio 15 min)
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 13.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23661 -
    ...  [5G][CA]New NRL scenario NRL__STATE__RMOD_Beamforming_Calibration_Check
    ...  - 11.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25039 - [5G][Refactoring][CNI-84880] NRCELL_R object refactoring
    ...  beamforming parameter
    ...  - 23.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28578 - [5G] Refactor TCs to use value of scf parameters as read from
    ...  scf without transforming inside KW: Check Parameter value from SCF - actSuperCell, actBeamForming
    ...  - 16.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29419 - [5G] Refactor TCs to use value of scf parameters as read from
    ...  scf without transforming inside KW: Check Parameter value from SCF - actSuperCell, actBeamForming
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-23661_NRL__STATE__RMOD_Beamforming_Calibration_Check.png

    Set Tags    CA-CM    OWNER-ariel.ciucurita@nokia.com    AUTHOR-ariel.ciucurita@nokia.com    PHASE-CRT    SW-SBTS23    CABLING-RFS_01_UE

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get shared RMOD info
    Step 4: Check beamforming enabled on NR
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Change RMOD primary link
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check alarms after beamforming calibration RMOD retry time
    END

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

Step ${index}: Get shared RMOD info
    [Documentation]
    ...  BTS info are related to shared RMOD

    Log  Step ${index}: Get shared RMOD info  console=True
    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  RMOD  Master  Slave
    Sort List  ${Master_shared_RMOD_list}
    Set Test Variable  ${Master_shared_RMOD_list}
    Set Test Variable  ${Slave_shared_RMOD_list}
    Get RMOD ID SN dict  Master
    Get RMOD ID SN dict  Slave
    FOR  ${Master_RMOD_id}  IN  @{Master_shared_RMOD_list}
        ${RMOD_sn}=  Get From Dictionary  ${Master_module_ID_SN_dict}  ${Master_RMOD_id}
        ${Slave_RMOD_id}=  Get From Dictionary  ${Slave_module_SN_ID_dict}  ${RMOD_sn}
        Log  Shared RMOD with SN ${RMOD_sn}:  console=True
        Log  - Master RMOD id: ${Master_RMOD_id}  console=True
        Log  - Slave RMOD id: ${Slave_RMOD_id}  console=True
    END

Step ${index}: Check beamforming enabled on NR
    [Documentation]  Check if any shared NR RMODs have cells with beamforming ativated

    Log  Step ${index}: Check beamforming enabled on NR  console=True
    ${RMOD_bfcali}=  Create List
    FOR  ${RMOD}  IN  @{Master_shared_RMOD_list}
        ${Master_shared_RMOD_CELL_list}=  Get Cell Mapping By Module Id  module_id=${RMOD}  alias=Master
        Log  NR cells maped on ${RMOD}:  console=True
        ${actBeamforming}=  Beamforming Check  ${Master_shared_RMOD_CELL_list}
        Run Keyword If  '${actBeamforming}' == 'true'
        ...  Append To List  ${RMOD_bfcali}  ${RMOD}
    END
    ${RMOD_bfcali}=  Remove Duplicates  ${RMOD_bfcali}
    Set Test Variable  ${RMOD_bfcali}
    Run Keyword If  not ${RMOD_bfcali}
    ...  Fail  Beamforming not activated on any NR CELL
    ...  ELSE
    ...  Log  Beamforming active on NR cells maped on ${RMOD_bfcali}

    [Return]  ${RMOD_bfcali}

Step ${index}: Change RMOD primary link

    [Documentation]  Change primary link for shared RMODs with beamforming NR cells

    Log  Step ${index}: Change RMOD primary link  console=True
    ${Master_Primary_Link_dict}  ${Slave_Primary_Link_dict}=  Get Primary Link status for shared RMOD
    FOR  ${RF}  IN  @{RMOD_bfcali}
       ${link}=  Get From Dictionary  ${Master_Primary_Link_dict}  ${RF}
       Run Keyword If  '${link}' == '[True]'
       ...  Lane lock unlock on master bts  ${RF}
       ...  ELSE
       ...  Run Keywords  Get Slave RF id  ${RF}
       ...  AND  Lane lock unlock on slave bts  ${Slave_RF_id}
    END

Step ${index}: Check alarms after beamforming calibration RMOD retry time
    Log  Step ${index}: Check alarms after beamforming calibration RMOD retry time  console=True
    Log  Sleeping ${BEAMFORMING_CALIBRATION_WAIT_TIME} minutes to allow beamforming calibration to finish  console=True
    Sleep  ${BEAMFORMING_CALIBRATION_WAIT_TIME} min
    Log  NR alarms check  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=@{EMPTY}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log  LTE alarms check  console=True
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=@{EMPTY}  ignored_alarms=${SLAVE_IGNORED_ALARMS}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    Log  Alarms after beamforming calibration RMOD retry time - expected, ignored and critical alarms checked  console=True

Beamforming Check
    [Arguments]  ${Master_shared_RMOD_CELL_list}

    FOR  ${item}  IN  @{Master_shared_RMOD_CELL_list}
        ${actBeamforming}=  Get actBeamforming parameter value  ${item}  Master
        Return From Keyword If  '${actBeamforming}' == 'true'  ${actBeamforming}
    END

    [Return]  false

Get actBeamforming parameter value
    [Documentation]
    ...  Get info related to actBeamforming parameter value from scf.

    [Arguments]  ${CELL_id}  ${alias}
    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}  export_type=configurationAndRuntimeObjects
    ${CELL_dn}=  Get CELL SCF runtime distinguished name  ${CELL_id}  ${alias}

    ${p_value_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${CELL_dn}  p_name=actBeamforming
    ${actBeamforming}=  Get Variable Value  ${p_value_info_dict['actBeamforming']}  ${Empty}

    [Return]  ${actBeamforming}

Lane lock unlock on master bts
    [Arguments]  ${RF_id}
    Get BTS MODULE LANE info dict  RMOD  Master
    Perform LANE operation  ${RF_id}  Lock  Master
    Sleep  120s
    Perform LANE operation  ${RF_id}  Unlock  Master
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=Master
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=Slave

Lane lock unlock on slave bts
    [Arguments]  ${RF_id}
    Get BTS MODULE LANE info dict  RMOD  Slave
    Perform LANE operation  ${RF_id}  Lock  Slave
    Sleep  120s
    Perform LANE operation  ${RF_id}  Unlock  Slave
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=Master
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=Slave

Get Slave RF id
    [Arguments]  ${RF}
    ${RF_sn}=  Get From Dictionary  ${Master_module_ID_SN_dict}  ${RF}
    ${Slave_RF_id}=  Get From Dictionary  ${Slave_module_SN_ID_dict}  ${RF_sn}
    Set Test Variable  ${Slave_RF_id}
    [Return]  ${Slave_RF_id}

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown