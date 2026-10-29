*** Settings ***
Documentation    TC__STBS__CM__PLMN_change_with_alarm_check_CB013048
Variables    tc_variables/stbs__cm__plmn_change_with_alarm_check_cb013048_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${NEW_MCC}           123    # New MCC value to be set (user input)
${NEW_MNC}           45     # New MNC value to be set (user input)
${REPEAT_COUNTER}    3      # Number of SBTS Recommissioning operations, default value 3


*** Keywords ***
TC__STBS__CM__PLMN_change_with_alarm_check_CB013048
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/CB013048
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for PLMN change with FID4795 alarm check.
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both NR and LTE technologies
    ...  - change MCC and MNC parameters via Plan
    ...  - check for FID4795 (Suspicious unit detection) alarm after reset
    ...  - restore initial PLMN values
    ...  - verify alarm is cleared and cells are back On Air
    ...
    ...  Pass criteria: PLMN change triggers expected alarm; restoration clears alarm and restores normal operation
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 01.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29736 - [CB013048] New commission TC in order
    ...  to change PLMN (MCC and MNC) and check alarm
    ...

    Set Tags    CA-CM    OWNER-robert.vesa@nokia.com    AUTHOR-alexandru.stamp@nokia.com    PHASE-QT    SW-SBTS26R1

    Step 1: Check initial BTS state
    Step 2: Check initial BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 3: Perform PLMN Commisioning CB013048
        Step 4: Check Expected Alarms after PLMN Commissioning
        Step 5: Restore PLMN Values CB013048
        Step 5: Check final number and state of Cells and RMs
        Step 6: Check final BTS state
        Step 7: Check final BTS alarms
    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=TRUE  infomodelSetup=${FALSE}
    Set Test Variable  ${PLMN_CHANGED}  ${FALSE}

TC Teardown
    Run Keyword If  ${PLMN_CHANGED}  Run Keywords
    ...  Log  PLMN values were changed, restoring original values  console=True
    ...  AND  PLMN Commisioning  ${initial_mcc}  ${initial_mnc}
    ...  AND  Sleep  160s
    Common Test Teardown

Step ${index}: Check ${when} BTS state
    [Documentation]
    ...  BTS state is checked according to Admin

    Log  Step ${index}: Check ${when} BTS state  console=True
    Admin Check BTS RAT Procedural State  alias=${alias_local}  timeout=600
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${alias_local}
    Log  BTS site - proceduralState: OnAir, blockingState: Unblocked  console=True

Step ${index}: Check ${when} BTS alarms
    [Documentation]
    ...  BTS alarms are compared with values from expected, ignored and critical alarms lists.
    ...  BTS alarms are get from Admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} BTS alarms  console=True
    Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=@{EMPTY}  ignored_alarms=${SBTS_IGNORED_ALARMS}
    ...  critical_alarms=${SBTS_CRITICAL_ALARMS}
    Log  BTS site - expected, ignored and critical alarms checked  console=True

Step ${index}: Perform PLMN Commisioning CB013048
    Log  Step ${index}: Perform PLMN Commisioning CB013048  console=True
    Get Initial MCC And MNC Values  alias=${alias_local}
    PLMN Commisioning  ${NEW_MCC}  ${NEW_MNC}
    Set Test Variable  ${PLMN_CHANGED}  ${TRUE}
    Sleep  160s

Step ${index}: Restore PLMN Values CB013048
    Log  Step ${index}: Restore PLMN Values CB013048  console=True
    PLMN Commisioning  ${initial_mcc}  ${initial_mnc}
    Set Test Variable  ${PLMN_CHANGED}  ${FALSE}
    Sleep  160s

Step ${index}: Check Expected Alarms after PLMN Commissioning
    Log  Step ${index}: Check Expected Alarms after PLMN Commissioning  console=True
    Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=${SBTS_MASTER_EXPECTED_ALARMS_4795}  ignored_alarms=${SBTS_MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${SBTS_MASTER_CRITICAL_ALARMS}

PLMN Commisioning
    [Arguments]  ${mcc_value}  ${mnc_value}
    ${year}  ${month}  ${day}  ${hour}  ${min}  ${sec}=  Get Time  format=year,month,day,hour,min,sec
    ${timestamp}=  Set Variable  ${year}_${month}_${day}_${hour}_${min}_${sec}
    ${delta_id}=  Set Variable  plan_${timestamp}
    Create Delta  delta_id=${delta_id}
    Log  Delta Recommissioning JSON file ${delta_id} created  console=True

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias_local}

    ${nrbts_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/NRBTS-[\\d]+  scf_path=${scf_path}  alias=${alias_local}
    ${lnbts_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/LNBTS-[\\d]+  scf_path=${scf_path}  alias=${alias_local}

    Run Keyword If  ${nrbts_dn_list}  Run Keywords
    ...  Set Test Variable  ${nrbts_dn}  ${nrbts_dn_list}[0]
    ...  AND  Append Parameter Update To Delta  dist_name=${nrbts_dn}  parameter=mcc
    ...  value=${mcc_value}  delta_id=${delta_id}
    ...  AND  Append Parameter Update To Delta  dist_name=${nrbts_dn}  parameter=mnc
    ...  value=${mnc_value}  delta_id=${delta_id}

    Run Keyword If  ${lnbts_dn_list}  Run Keywords
    ...  Set Test Variable  ${lnbts_dn}  ${lnbts_dn_list}[0]
    ...  AND  Append Parameter Update To Delta  dist_name=${lnbts_dn}  parameter=mcc
    ...  value=${mcc_value}  delta_id=${delta_id}
    ...  AND  Append Parameter Update To Delta  dist_name=${lnbts_dn}  parameter=mnc
    ...  value=${mnc_value}  delta_id=${delta_id}

    Log  Appended parameter update to Delta  console=True
    ${delta_file}=  coam.Get Delta  delta_id=${delta_id}
    Log  Perform Delta Recommissioning JSON file ${delta_id}  console=True
    coam.Perform Delta Recommissioning  alias=${alias_local}  delta_file=${delta_file}  skip_parameter_relation_errors=True
    ...  should_activate=True

Get BTS Information
    [Arguments]  ${alias}

    ${NR_CELL_id_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${nr_cells_present}=  Set Variable If  ${NR_CELL_id_list}  ${TRUE}  ${FALSE}
    Set Test Variable  ${nr_cells_present}

    ${LTE_CELL_id_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${lte_cells_present}=  Set Variable If  ${LTE_CELL_id_list}  ${TRUE}  ${FALSE}
    Set Test Variable  ${lte_cells_present}

    ${BTS_info}=  Get Bts Info  connection=${alias}
    ${MRBTS_id}=  Get From Dictionary  ${BTS_info}  mrbtsID
    ${NRBTS_id}=  Get From Dictionary  ${BTS_info}  nrBtsId
    ${LNBTS_id}=  Get From Dictionary  ${BTS_info}  lnBtsId

    Set Test Variable  ${MRBTS_id}
    Set Test Variable  ${NRBTS_id}
    Set Test Variable  ${LNBTS_id}

Step ${index}: Check ${when} number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check ${when} number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get Initial MCC And MNC Values
    [Arguments]    ${alias}
    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${nrbts_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/NRBTS-[\\d]+  scf_path=${scf_path}  alias=${alias}
    ${nrbts_dn}=  Get From List  ${nrbts_dn_list}  0
    ${output_values}=  coam.Get Parameters  connection=${alias}  item=${nrbts_dn}
    Set Test Variable  ${initial_mcc}  ${output_values['mcc']}
    Set Test Variable  ${initial_mnc}  ${output_values['mnc']}