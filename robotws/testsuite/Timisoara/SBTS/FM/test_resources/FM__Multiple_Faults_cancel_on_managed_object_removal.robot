*** Settings ***
Documentation
    ...  Test case will verify the reporting and clearing of fault 7107 in case of managed object removal.
    ...  Functionality is updated by change note CNI-143198 Add missing fault cancel for faults raised using DFM Interface on Managed Object removal.
    ...  Test case will verify the reporting and clearing of fault 7324 when enhX2linkSupervision feature is activated.
    ...  Functionality is introduced by the feature CB Enhanced X2 Link Supervision.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  600  # [in seconds] Timeout for alarm to appear in WebEM.
${NETACT_TIMEOUT}  120  # [in seconds] Timeout for alarm to appear in Netact.


*** Keywords ***
FM__Multiple_Faults_cancel_on_managed_object_removal
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30238
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  26.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30238 - Initial TAT creation
    ...  ******************

    Set Tags  CA-FM  OWNER-ioan.marta@nokia.com  AUTHOR-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS26  FEATURE-CB005956  FEATURE-CB006758  CNI-143198

    Step0: Set Testcase Variables
    Step1: Check Interaction With EnhX2linkSupervision
    Step2: Set X2LinkSupervisionTmr Value To 6 Minutes
    Step3: Change Status For X2 Links
    Step4: Check Fault 7107 On NSA Or NSA+SA Cells
    Step5: Remove A NRCELL With Fault 7107
    Step6: Check One Less Fault 7107 On NSA Or NSA+SA Cells
    Step7: Check Fault 7300
    Step8: Remove A NRCELL With Fault 7107
    Step9: Check One Less Fault 7107 On NSA Or NSA+SA Cells
    Step10: Change Status For X2 Links
    Step11: Return EnhX2linkSupervision Parameters To Original Values
    Step12: Performed Commissioning With Backup SCF


Step0: Set Testcase Variables
    Log  \nStep0: Set testcase variables.  console=true

    Log  Collect current SCF for backup purpose.  console=true
    Get Current Scf File  local_dir_path=${BTS_FILES}  file_name=backup_scf.xml  timeout=60  export_type=configurationAndRuntimeObjects
    ...  parameters_save_variant=actualValues
    ${all_cells}  Get Cells Info
    ${combined_nsa_cells}  Create List
    ${unaffected_cells}  Get All Cells On Bts
    FOR  ${cell}  IN  @{all_cells}
         ${nsa_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${cell}[cellDepType]  NSA
         ${sa_nsa_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${cell}[cellDepType]  SA+NSA
         IF  ${nsa_status} or ${sa_nsa_status}
             ${cell_info_dict}  Create Dictionary
             Set To Dictionary  ${cell_info_dict}  configuration  ${cell}[id][configuration]
             Set To Dictionary  ${cell_info_dict}  internal  ${cell}[id][internal]
             Set To Dictionary  ${cell_info_dict}  cellDepType  ${cell}[cellDepType]
             Set To Dictionary  ${cell_info_dict}  globalCellId  ${cell}[globalCellId]
             Append To List  ${combined_nsa_cells}  ${cell_info_dict}
             Remove Values From List  ${unaffected_cells}  ${cell}[id][internal]
         END
    END
    ${nr_of_nsa_cells}  Get Length  ${combined_nsa_cells}
    IF  '${nr_of_nsa_cells}'=='0'  Fail  No NSA or SA+NSA cells configured.
    ${lteenb_links}  coam.Get Managed Objects  LTEENB_A
    ${nr_of_lteenb_links}  Get Length  ${lteenb_links}
    IF  '${nr_of_lteenb_links}'=='0'  Fail  No LTEENB X2 links configured.
    ${nrbts_id}  Admin Get NRBTS ID
    Set Test Variable  ${NRBTS_ID}
    Set Test Variable  ${LTEENB_LINKS}
    Set Test Variable  ${COMBINED_NSA_CELLS}
    Set Test Variable  ${UNAFFECTED_CELLS}


Step1: Check Interaction With EnhX2linkSupervision
    Log  \nStep1: Check interaction with enhX2linkSupervision.  console=true

    ${parameters_list}  Create List  maxNumX2Links  actEnhancedX2LinkSupervision
    ${enhx2linksupervision_values}  Get Parameter By Distname  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}  ${parameters_list}
    Set Test Variable  ${MAX_NUM_X2_LINKS_INI}  ${enhx2linksupervision_values}[0][parameters][maxNumX2Links]
    Set Test Variable  ${ACT_ENHANCED_X2_LINK_SUPERVISION_INI}  ${enhx2linksupervision_values}[0][parameters][actEnhancedX2LinkSupervision]
    Set Parameter To New Value  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}  maxNumX2Links  2
    Set Parameter To New Value  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}  actEnhancedX2LinkSupervision  true
    ${fault_7324_params}  Get String With Alarm Parameters  ${FAULT_7324}
    ${alarm_parameters}  Catenate  ${fault_7324_params},  alarmingResource=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}
    Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${alarm_parameters} is active in WebEM.  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  15
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_7324}  object_id=PLMN-PLMN/MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}
    Log  Fault ${FAULT_7324} active in Netact.  console=true
    ${cells_status}  Run Keyword And Return Status  Check All Cells
    IF  ${cells_status}
       Log  All cells in configuration are : OnAirDone Enabled Active [OK].  console=true
    ELSE
        Fail  Cells status is incorect [NOK].
    END


Step2: Set X2LinkSupervisionTmr Value To 6 Minutes
    Log  \nStep2: Set X2LinkSupervisionTmr value to 6 minutes.  console=true

    Set Parameter To New Value  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}  x2LinkSupervisionTmr  6


Step${index}: Change Status For X2 Links
    Log  \nStep${index}: Change status for X2 links.  console=true

    ${operation}  Set Variable If  ${index}==3  locked  unlocked
    Log  X2LinkLock will be changed to ${operation} for all X2 links.  console=true
    Change X2LinkLock Parameter On All X2 Links  ${LTEENB_LINKS}  ${operation}  ${BTS_ID}  ${NRBTS_ID}
    IF  ${index}==10  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check Modules And Cells


Step4: Check Fault 7107 On NSA Or NSA+SA Cells
    Log  \nStep4: Check fault 7107 on NSA or NSA+SA cells.  console=true

    Log  Waiting for fault 7107 to be active in WebEM.  console=true
    Check Fault 7107 Active On NR Cells And Cells Status  ${COMBINED_NSA_CELLS}
    ${unaffected_cells_status}  Run Keyword And Return Status  Check Parameters Status For Cells  ${UNAFFECTED_CELLS}  operationalState=${ENABLED}
    IF  ${unaffected_cells_status}
        Log  Unaffected cells are enabled. [OK]  console=true
    ELSE
        Fail  Unaffected cells are not enabled. [NOK]
    END


Step${index}: Remove A NRCELL With Fault 7107
    Log  \nStep${index}: Remove a NRCELL with fault 7107.  console=true

    ${nrresourcedu}  coam.Get Managed Objects  NRRESOURCEDU_A
    ${nrcell_id_power_saving}  Fetch From Right  ${nrresourcedu}[0][parameters][resourceDN]  NRCELL_A-
    FOR  ${cell}  IN  @{COMBINED_NSA_CELLS}
        IF  '${cell}[globalCellId]'=='${nrcell_id_power_saving}'  Remove Values From List  ${COMBINED_NSA_CELLS}  ${cell}
    END
    ${chosen_cell}  Evaluate  random.choice(${COMBINED_NSA_CELLS})
    Log  Chosen cell for removal:\n${chosen_cell}[configuration].  console=true
    Remove NR Cell From Configuration  ${chosen_cell}[globalCellId]  ${BTS_ID}  ${NRBTS_ID}
    Remove Values From List  ${COMBINED_NSA_CELLS}  ${chosen_cell}
    ${removed_nsa_cells}  Create List
    Append To List  ${removed_nsa_cells}  ${chosen_cell}
    Set Test Variable  ${REMOVED_NSA_CELLS}


Step${index}: Check One Less Fault 7107 On NSA Or NSA+SA Cells
    Log  \nStep${index}: Check one less fault 7107 on NSA or NSA+SA cells.  console=true

    Check Fault 7107 Active On NR Cells And Cells Status  ${COMBINED_NSA_CELLS}
    Check Fault 7107 Cleared From Removed NR Cells  ${REMOVED_NSA_CELLS}
    ${unaffected_cells_status}  Run Keyword And Return Status  Check Parameters Status For Cells  ${UNAFFECTED_CELLS}  operationalState=${ENABLED}
    IF  ${unaffected_cells_status}
        Log  Unaffected cells are enabled. [OK]  console=true
    ELSE
        Fail  Unaffected cells are not enabled. [NOK]
    END


Step7: Check Fault 7300
    Log  \nStep7: Check Fault 7300.  console=true

    ${fault_major_7300}  Get String With Alarm Parameters  ${FAULT_7300}
    ${alarm_parameters}  Catenate  ${fault_major_7300},  alarmingResource=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}
    Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${alarm_parameters} is active in WebEM.  console=true


Step11: Return EnhX2linkSupervision Parameters To Original Values
    Log  \nStep11: Return enhX2linkSupervision parameters to original values.  console=true

    Set Parameter To New Value  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}  maxNumX2Links  ${MAX_NUM_X2_LINKS_INI}
    Set Parameter To New Value  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}  actEnhancedX2LinkSupervision  ${ACT_ENHANCED_X2_LINK_SUPERVISION_INI}
    ${fault_7324_params}  Get String With Alarm Parameters  ${FAULT_7324}
    ${alarm_parameters}  Catenate  ${fault_7324_params},  alarmingResource=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}
    Assert Alarm Inactive  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${alarm_parameters} is inactive in WebEM.  console=true


Step12: Performed Commissioning With Backup SCF
    Log  \nStep12: Performed commissioning with backup SCF.  console=true

    Performing Commisioning With Backup SCF


Remove NR Cell From Configuration
    [Arguments]   ${cell_id}  ${mrbts_id}  ${nrbts_id}

    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    ${nrcellgrp_list}  coam.Get Managed Objects  NRCELLGRP_A
    FOR  ${nrcellgrp}  IN  @{nrcellgrp_list}
        IF  '${nrcellgrp}[parameters][nrCellList][0]'=='${cell_id}'
            ${nrcellgrp_id}  Fetch From Right  ${nrcellgrp}[distName]  NRCELLGRP_A-
            BREAK
        END
    END
    Append Managed Object To Delta  MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}  delete  ${delta_id}
    Append Managed Object To Delta  MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELLGRP-${nrcellgrp_id}  delete  ${delta_id}
    Append Managed Object To Delta  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${nrcellgrp_id}  delete  ${delta_id}
    ${parameter_list}  Create List  refNrCellGroup
    ${refNrCellGroup_dic}  Get Parameter By Distname  MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRDU-1  ${parameter_list}  ${False}
    ${refNrCellGroup_list}  Set Variable  ${refNrCellGroup_dic[0]['parameters']['refNrCellGroup']}
    Remove Values From List  ${refNrCellGroup_list}  ${nrcellgrp_id}
    Append Parameter Update To Delta  MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRDU-1  refNrCellGroup  ${refNrCellGroup_list}  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_remove_cell.json  delta_id=${delta_id}
    coam.Perform Delta Recommissioning  ${BTS_FILES}/delta_remove_cell.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}


Change X2LinkLock Parameter On All X2 Links
    [Arguments]   ${lteenb_list}  ${operation}  ${mrbts_id}  ${nrbts_id}

    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    FOR  ${lteenb}  IN  @{lteenb_list}
        ${lteenb_id}  Fetch From Right  ${lteenb}[distName]  LTEENB_A-
        Append Parameter Update To Delta  MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/LTEENB-${lteenb_id}  x2LinkLock  ${operation}  ${delta_id}
    END
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_${operation}_x2links.json  delta_id=${delta_id}
    coam.Perform Delta Recommissioning  ${BTS_FILES}/delta_${operation}_x2links.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}


Check Fault 7107 Active On NR Cells And Cells Status
    [Arguments]   ${cells_list}

    FOR  ${cell}  IN  @{cells_list}
        IF  '${cell}[cellDepType]'=='NSA'
            ${fault_critical_7107}  Get String With Alarm Parameters  ${FAULT_7107}
            ${alarm_parameters}  Catenate  ${fault_critical_7107},  alarmingResource=${cell}[configuration]
            ...  supplAlarmInfo="trigger=link-status-change, failureService=NSA"
            Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
            Log  Fault 7107: ${alarm_parameters} is active in WebEM.  console=true
            Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10s
            ...  Check Additional Information For Given Alarm And Fault  &{FAULT_7107}  object_id=PLMN-PLMN/${cell}[configuration]
            ...  additional_fault_id=${FAULT_7107}[fault_id]  suppl_info=trigger=link-status-change, failureService=NSA
            Assert  NRCEL  ${cell}[internal]  operationalState=${DISABLED}, availabilityStatus=${FAILED}
            Log  NR cells is expected state: disabled & failed.  console=true
        ELSE
            ${fault_major_7107}  Get String With Alarm Parameters  ${FAULT_7107_MAJOR}
            ${alarm_parameters}  Catenate  ${fault_major_7107},  alarmingResource=${cell}[configuration]
            ...  supplAlarmInfo="trigger=link-status-change, failureService=NSA"
            Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
            Log  Fault 7107: ${alarm_parameters} is active in WebEM.  console=true
            Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10s
            ...  Check Additional Information For Given Alarm And Fault  &{FAULT_7107_MAJOR}  object_id=PLMN-PLMN/${cell}[configuration]
            ...  additional_fault_id=${FAULT_7107_MAJOR}[fault_id]  suppl_info=trigger=link-status-change, failureService=NSA
            Assert  NRCEL  ${cell}[internal]  operationalState=${ENABLED}, availabilityStatus=${DEGRADED}
            Log  NR cells are in expected state: enabled & degraded.  console=true
        END
    END


Check Fault 7107 Cleared From Removed NR Cells
    [Arguments]   ${cells_list}

    FOR  ${cell}  IN  @{cells_list}
        IF  '${cell}[cellDepType]'=='NSA'
            ${fault_critical_7107}  Get String With Alarm Parameters  ${FAULT_7107}
            ${alarm_parameters}  Catenate  ${fault_critical_7107},  alarmingResource=${cell}[configuration]
            Assert Alarm Inactive  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
            Log  Fault 7107: ${alarm_parameters} is inactive in WebEM.  console=true
        ELSE
            ${fault_major_7107}  Get String With Alarm Parameters  ${FAULT_7107_MAJOR}
            ${alarm_parameters}  Catenate  ${fault_major_7107},  alarmingResource=${cell}[configuration]
            Assert Alarm Inactive  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
            Log  Fault 7107: ${alarm_parameters} is inactive in WebEM.  console=true
        END
    END


TC Setup
    Common Test Setup  tc_name=FM__Multiple_Faults_cancel_on_managed_object_removal
    Setup Netact


TC Teardown
    Run Keyword If Test Failed  Performing Commisioning With Backup SCF
    Teardown Netact
    Common Test Teardown