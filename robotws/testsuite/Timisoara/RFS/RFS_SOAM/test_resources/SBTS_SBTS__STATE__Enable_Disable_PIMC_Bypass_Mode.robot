*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
Variables    tc_variables/sbts_sbts__state__enable_disable_pimc_bypass_mode_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}              3     # Number of enable/disable PIMC Bypass Mode cycles; default value 3
${ALLOWED_RMOD_SN_LIST}     ALL      # RMOD sn list allowed for Enable/Disable PIMC Bypass mode operations. Possible values (by default ALL):
                                     # - ALL: action will be performed on all found RMOD
                                     # - list of allowed BBMOD SN for reset separated by comma (ex. L1223402974, L1223402975)
${DELTA_POWER_THR}   30              # Delta Power Threshold for each RMOD; Default value: 30.
                                     # - in case ALLOWED_RMOD_SN_LIST=ALL, a single value will be used
                                     # - if ALLOWED_RMOD_SN_LIST is a list, DELTA_POWER_THR should also be a list with elements separated by comma,
                                     # and matching in position its corresponding RMOD SN from ALLOWED_RMOD_SN_LIST (ex. 30, 32)

*** Keywords ***
TC__SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29004
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for Enable/Disable PIMC Bypass Mode, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get and check CB012619 settings on both BTS
    ...  - perform Enable/Disable PIMC Bypass Mode, measure RMOD power and save info to file
    ...  - compare power values between the two cases
    ...  - check reset behavior on all BTS based on IMS info: no BTS reset expected
    ...  Pass criteria: Enable/Disable PIMC Bypass Mode works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 01.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29004 - SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode TC Delivery
    ...  - 27.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29458 - PIMC tests corrections
    ...  - 27.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29533 - Compatibility to single SBTS
    ...  - 27.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29573 - Changing timeout for RMOD checking after feature activation
    ...  - 22.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30412 - Issue with SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    ...  - 05.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30577 -
    ...  PIM cancellation robot fails with "Variable '${EXPECTED_ALARMS_full}' not found"
    ...

    Set Tags    CA-STATE    OWNER-anelore.tasala@nokia.com@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-QT    SW-SBTS25R3

    TC Parameter Check
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    Step 4: Get initial CB012619 feature settings
    Step 5: Disable PIMC Bypass Mode and Save Results
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER} + 1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 6: Perform Enable Disable PIMC Bypass Mode for iteration
        Step 7: Check final all BTS state
        Step 8: Check final all BTS alarms
        Step 9: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Parameter Check

    ${ALLOWED_RMOD_SN_LIST_strip}=  Replace String  ${ALLOWED_RMOD_SN_LIST}  ${SPACE}  ${EMPTY}
    ${DELTA_POWER_THR_strip}=  Replace String  ${DELTA_POWER_THR}  ${SPACE}  ${EMPTY}
    ${ALLOWED_RMOD_SN_lst}=  Split String  ${ALLOWED_RMOD_SN_LIST_strip}  ,
    ${DELTA_POWER_THR_lst}=  Split String  ${DELTA_POWER_THR_strip}  ,
    ${ALLOWED_RMOD_SN_lst_len}=  Get Length  ${ALLOWED_RMOD_SN_lst}
    ${DELTA_POWER_THR_lst_len}=  Get Length  ${DELTA_POWER_THR_lst}

    Run Keyword If  "${ALLOWED_RMOD_SN_lst_len}"!="${DELTA_POWER_THR_lst_len}"  Run Keywords
    ...  Log  TC Parameter Check failed! ALLOWED_RMOD_SN_LIST and DELTA_POWER_THR should have the same number of elements!  console=True
    ...  AND  Fail  TC Parameter Check failed! ALLOWED_RMOD_SN_LIST and DELTA_POWER_THR should have the same number of elements!

    Return From Keyword If  "${ALLOWED_RMOD_SN_LIST}"=="ALL"

    ${RMOD_SN_delta_power_thr_mapping}=  Create Dictionary

    FOR  ${index}  IN RANGE  0  ${ALLOWED_RMOD_SN_lst_len}
        ${RMOD_SN}=  Get From List  ${ALLOWED_RMOD_SN_lst}  ${index}
        ${DELTA_POWER_THR_RMOD_SN}=  Get From List  ${DELTA_POWER_THR_lst}  ${index}
        Set To Dictionary  ${RMOD_SN_delta_power_thr_mapping}  ${RMOD_SN}=${DELTA_POWER_THR_RMOD_SN}
    END

    Set Test Variable  ${RMOD_SN_delta_power_thr_mapping}

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

Step ${index}: Get all BTS info for configured items
    [Documentation]
    ...  Get all BTS info about following items:
    ...  - list of shared RM serial number configured on BTS primary controller (per BTS alias)
    ...  - list of shared RM serial number configured on BTS secondary controller (per BTS alias)
    ...  - list of RAT cells (per BTS alias)

    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RMOD_sn_list}
    Set Test Variable  ${dedicated_RMOD_sn_list}
    ${RMOD_all_sn_list}=  Get Dictionary Keys  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${RMOD_all_sn_list}

    Run Keyword If  '${ALLOWED_RMOD_SN_LIST}' != 'ALL'  Check RMOD serial number list

    Log  ========================================================  console=True
    Log  RMOD serial number list selected for Enable Disable PIMC Bypass action: ${RMOD_all_sn_list}  console=True
    Log  ========================================================  console=True

    ${all_BTS_RMOD_id_CELL_ids_info}=  Get all BTS Cells mapped on RMOD info
    Set Test Variable  ${all_BTS_RMOD_id_CELL_ids_info}

    ${all_BTS_controller_role_RMOD_sn_list}=  Get all BTS controller role for configured RMOD from SCF
    Set Test Variable  ${all_BTS_controller_role_RMOD_sn_list}

    Set Test Variable  ${RMOD_state_disabled_check}
    ...   operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}

    FOR  ${alias}  IN  @{alias_list}
        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH
        Run Keyword If  '${alias_tech}' in ['NR', 'LTE', 'SBTS']
        ...  Get SBTS Cell info  ${alias}
    END

    Get all BTS Modules SN ID mapping

Step ${index}: Get initial CB012619 feature settings
    [Documentation]
    ...  Check CB012619 feature settings on BTS

    Log  Step ${index}: Check CB012619 feature settings  console=True

    FOR  ${alias}  IN  @{alias_list}

        ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
        ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${scf_path}  alias=${alias}
        ${BTS_SCF_dn}=  Get From List  ${dn_list}  0
        ${BTS_CB012619_feature_dict}=  Get CB012619 feature settings on BTS  ${alias}
        ${actPowerMeter}  ${mtBtsEnergyMonitoring}  ${mtSBTSRfmEnergyMonitoring}  ${mtSBTSSmEnergyMonitoring}=  Get feature CB006831 info  ${alias}
        Set Test Variable  ${actPowerMeter_initial_${alias}}  ${actPowerMeter}
        ${actPowerMeter_param_value_dict}=  Create Dictionary  actPowerMeter=${actPowerMeter_initial_${alias}}
        Set To Dictionary  ${BTS_CB012619_feature_dict}  ${BTS_SCF_dn}=${actPowerMeter_param_value_dict}
        Set Test Variable  ${${alias}_BTS_CB012619_feature_dict_initial}  ${BTS_CB012619_feature_dict}

    END

Step ${index}: Disable PIMC Bypass Mode and Save Results
    [Documentation]
    ...  Disable PIMC Bypass Mode and Save Results

    Log  Step ${index}: Disable PIMC Bypass Mode and Save Results  console=True

    Set Test Variable  ${RMOD_power_RTM_output_file}  ${Test Results Dir}/Real_Time_Measurements/RMOD_power_RTM_Info.txt
    ${RMOD_measurements_dict}=  Create Dictionary
    Set Test Variable  ${RMOD_measurements_dict}
    ${alias_list_len}=  Get Length  ${alias_list}

    FOR  ${alias}  IN  @{alias_list}
        Log  Disabling PIMC Bypass on BTS ${alias}  console=True
        ${BTS_RMOD_sn_reset_list}  ${BTS_RMOD_sn_not_reset_list}=  Determine which RMODs should reset  ${alias}
        Set Test Variable  ${BTS_RMOD_sn_reset_list}
        Set PIMC Bypass Mode on BTS  ${alias}  false
        Run Keyword If  ${BTS_RMOD_sn_reset_list}  Check RMOD reset behavior on BTS  ${BTS_RMOD_sn_reset_list}  ${alias}  True
        Run Keyword If  ${BTS_RMOD_sn_not_reset_list}  Check RMOD reset behavior on BTS  ${BTS_RMOD_sn_not_reset_list}  ${alias}  False
        ${index}=  Get Index From List  ${alias_list}  ${alias}
        Run Keyword If  ${index}==0 and ${alias_list_len}>1  Check Configuration mismatch between peer BTSs alarm  ${alias}  ${BTS_RMOD_sn_reset_list}
    END

    Log  Check no alarms present after all BTS in line feature-wise  console=True

    FOR  ${alias}  IN  @{alias_list}
        Log  Check BTS alarms on BTS ${alias}  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    END

    Read Real Time Measurements on BTS

    ${year}  ${month}  ${day}  ${hour}  ${min}=  Get Time  format=year,month,day,hour,min
    ${timestamp}=  Set Variable  ${year}_${month}_${day}_${hour}_${min}

    FOR  ${alias}  IN  @{alias_list}
        Check And Print Power Values for selected RMODs  ${alias}  ${timestamp}  false  False
    END

Step ${index}: Perform Enable Disable PIMC Bypass Mode for iteration
    Log  Step ${index}: Perform Enable Disable PIMC Bypass Mode for iteration  console=True

    Log  Performing Enable PIMC Bypass Mode on all BTS/RMODs  console=True

    ${alias_list_len}=  Get Length  ${alias_list}
    FOR  ${alias}  IN  @{alias_list}
        Log  Enabling PIMC Bypass on BTS ${alias}  console=True
        ${BTS_controller_role_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${alias}
        ${BTS_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_role_RMOD_sn_list}  BTS_primary_controller_RMOD_sn_list
        ${BTS_RMOD_sn_reset_list}=  Evaluate  list(set(${BTS_primary_controller_RMOD_sn_list}) & set(${RMOD_all_sn_list}))
        ${BTS_RMOD_sn_not_reset_list}=  Evaluate  list(set(${BTS_primary_controller_RMOD_sn_list}) ^ set(${RMOD_all_sn_list}))
        Set Test Variable  ${BTS_RMOD_sn_reset_list}
        Set PIMC Bypass Mode on BTS  ${alias}  true
        ${index}=  Get Index From List  ${alias_list}  ${alias}
        Run Keyword If  ${index}==0 and ${alias_list_len}>1  Check Configuration mismatch between peer BTSs alarm  ${alias}  ${RMOD_all_sn_list}
        Check RMOD reset behavior on BTS  ${BTS_RMOD_sn_reset_list}  ${alias}  True
        Check RMOD reset behavior on BTS  ${BTS_RMOD_sn_not_reset_list}  ${alias}  False
    END

    Log  Check no alarms present after all BTS in line  console=True

    FOR  ${alias}  IN  @{alias_list}
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    END

    Sleep  60s
    Read Real Time Measurements on BTS

    ${year}  ${month}  ${day}  ${hour}  ${min}=  Get Time  format=year,month,day,hour,min
    ${timestamp}=  Set Variable  ${year}_${month}_${day}_${hour}_${min}

    FOR  ${alias}  IN  @{alias_list}
        Check And Print Power Values for selected RMODs  ${alias}  ${timestamp}  true  True
    END

    Sleep  120s

    ${alias_list_len}=  Get Length  ${alias_list}
    Log  Performing Disable PIMC Bypass Mode on all BTS/RMODs  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  Disabling PIMC Bypass on BTS ${alias}  console=True
        ${BTS_controller_role_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${alias}
        ${BTS_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_role_RMOD_sn_list}  BTS_primary_controller_RMOD_sn_list
        ${BTS_RMOD_sn_reset_list}=  Evaluate  list(set(${BTS_primary_controller_RMOD_sn_list}) & set(${RMOD_all_sn_list}))
        Set Test Variable  ${BTS_RMOD_sn_reset_list}
        ${BTS_RMOD_sn_not_reset_list}=  Evaluate  list(set(${BTS_primary_controller_RMOD_sn_list}) ^ set(${RMOD_all_sn_list}))
        Set PIMC Bypass Mode on BTS  ${alias}  false
        ${index}=  Get Index From List  ${alias_list}  ${alias}
        Run Keyword If  ${index}==0 and ${alias_list_len}>1  Check Configuration mismatch between peer BTSs alarm  ${alias}  ${RMOD_all_sn_list}
        Check RMOD reset behavior on BTS  ${BTS_RMOD_sn_reset_list}  ${alias}  True
        Check RMOD reset behavior on BTS  ${BTS_RMOD_sn_not_reset_list}  ${alias}  False
    END

    Log  Check no alarms present after all BTS in line  console=True
    FOR  ${alias}  IN  @{alias_list}
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    END

    Sleep  60s
    Read Real Time Measurements on BTS

    ${year}  ${month}  ${day}  ${hour}  ${min}=  Get Time  format=year,month,day,hour,min
    ${timestamp}=  Set Variable  ${year}_${month}_${day}_${hour}_${min}

    FOR  ${alias}  IN  @{alias_list}
        Check And Print Power Values for selected RMODs  ${alias}  ${timestamp}  false  True
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check RMOD serial number list
    ${RMOD_SERIAL_NUMBER_LIST_strip}=  Replace String  ${ALLOWED_RMOD_SN_LIST}  ${SPACE}  ${EMPTY}
    ${RMOD_SERIAL_NUMBER_LIST}=  Split String  ${RMOD_SERIAL_NUMBER_LIST_strip}  ,
    ${RMOD_sn_check}=  Set Variable  True
    ${RMOD_sn_invalide_list}=  Create List

    FOR  ${item}  IN  @{RMOD_SERIAL_NUMBER_LIST}

        ${RMOD_sn_check}=  Set Variable If  '${item}' not in ${RMOD_all_sn_list}  False  ${RMOD_sn_check}
        Run Keyword If  '${item}' not in ${RMOD_all_sn_list}  Append To List  ${RMOD_sn_invalide_list}  ${item}

    END

    Run Keyword If  '${RMOD_sn_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected RMOD serial number values are not valid: ${RMOD_sn_invalide_list}. Please select values for test
    ...  argument \${ALLOWED_RMOD_SN_LIST} from configured RMOD: ${RMOD_all_sn_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!
    Set Test Variable  ${RMOD_all_sn_list}  ${RMOD_SERIAL_NUMBER_LIST}
    Sort List  ${RMOD_all_sn_list}

Get Current CB012619 feature settings

    FOR  ${alias}  IN  @{alias_list}
        ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
        ${BTS_CB012619_feature_dict}=  Get CB012619 feature settings on BTS  ${alias}  ${BTS_SCF_path_file_info}

        Set Test Variable  ${${alias}_BTS_CB012619_feature_dict_current}  ${BTS_CB012619_feature_dict}

        ${actPowerMeter}  ${mtBtsEnergyMonitoring}  ${mtSBTSRfmEnergyMonitoring}  ${mtSBTSSmEnergyMonitoring}=  Get feature CB006831 info  ${alias}
        Set Test Variable  ${actPowerMeter_current_${alias}}  ${actPowerMeter}
    END

Get CB012619 feature settings on BTS
    [Arguments]  ${alias}  ${BTS_SCF_path_file}=None

    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}
    ${BTS_CB012619_feature_dict}=  Create Dictionary
    ${BTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}

    FOR  ${RMOD_SN}  IN  @{RMOD_all_sn_list}
        Continue For Loop If  '${RMOD_SN}' not in ${BTS_RMOD_sn_list}
        ${RMOD_id}=  Get From Dictionary  ${${alias}_MODULE_sn_id_mapping_dict}  ${RMOD_SN}
        ${RMOD_SCF_DN}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
        ${BTS_CB012619_RMOD_feature_dict}=  Get BTS CB012619 feature parameters  RMOD_id=${RMOD_id}  RMOD_SN=${RMOD_SN}
        ...  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
        Set To Dictionary  ${BTS_CB012619_feature_dict}  ${RMOD_SCF_DN}=${BTS_CB012619_RMOD_feature_dict}
    END
    [Return]  ${BTS_CB012619_feature_dict}

Set PIMC Bypass Mode on BTS
    [Arguments]  ${alias}  ${actPimCancellationBypass_value}=true

    ${Object_dn_parameter_value_dict}=  Create Dictionary
    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0
    ${bts_param_dict}=  Create Dictionary  actPowerMeter=true
    Set To Dictionary  ${Object_dn_parameter_value_dict}  ${BTS_SCF_dn}=${bts_param_dict}

    ${BTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}

    FOR  ${RMOD_SN}  IN  @{RMOD_all_sn_list}
        Continue For Loop If  '${RMOD_SN}' not in ${BTS_RMOD_sn_list}
        ${RMOD_id}=  Get From Dictionary  ${${alias}_MODULE_sn_id_mapping_dict}  ${RMOD_SN}
        ${RMOD_SCF_DN}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
        ${bts_param_dict}=  Create Dictionary  actPimCancellation=false  actPimCancellationBypass=${actPimCancellationBypass_value}
        Set To Dictionary  ${Object_dn_parameter_value_dict}  ${RMOD_SCF_DN}=${bts_param_dict}
    END

    ${BTS_alias_RMOD_sn_Uptime_dict_initial}=  Get all BTS RMOD Uptime info
    Set Test Variable  ${BTS_alias_RMOD_sn_Uptime_dict_initial}

    Perform CB012619 feature Delta Commissioning on BTS  ${Object_dn_parameter_value_dict}  ${alias}

    Check CB012619 Feature Delta Commissioning Succesfully Performed
    ...  exp_actPowerMeter=true  exp_actPimCancellation=false  exp_actPimCancellationBypass=${actPimCancellationBypass_value}  alias=${alias}

    Run Keyword If  ${BTS_RMOD_sn_reset_list}  Assert Any  class_name=RMOD  parameters=${RMOD_state_disabled_check}
    ...  timeout=180  connection=${alias}

    Assert Every  class_name=RMOD  parameters=${RMOD_state_enabled_check}  timeout=420  connection=${alias}

    Sleep  80s

    ${BTS_alias_RMOD_sn_Uptime_dict_final}=  Get all BTS RMOD Uptime info
    Set Test Variable  ${BTS_alias_RMOD_sn_Uptime_dict_final}

Get SBTS Cell info
    [Arguments]  ${alias}

    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Sort List  ${NR_CELL_list}
    Sort List  ${LTE_CELL_list}
    Sort List  ${WCDMA_CELL_list}
    Sort List  ${GSM_CELL_list}
    ${LTE_HOST_CELL_ID_LIST}  ${LTE_IOT_CELL_ID_LIST}  ${LTE_IOT_SA_CELL_ID_LIST}=  Admin Get LTE HOST and IOT Cell(s) Id list
    ...  CELL_list=${LTE_CELL_list}  alias=${alias}
    ${LTE_cell_IOT_mapping_dict}=  Run Keyword If  ${LTE_CELL_list}  Admin Get LTE CELL IOT mapping list  alias=${alias}
    Set Test Variable  ${${alias}_NR_CELL_list}  ${NR_CELL_list}
    Set Test Variable  ${${alias}_LTE_CELL_list}  ${LTE_HOST_CELL_ID_LIST}
    Set Test Variable  ${${alias}_WCDMA_CELL_list}  ${WCDMA_CELL_list}
    Set Test Variable  ${${alias}_GSM_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_cell_IOT_mapping_dict}

Check Configuration mismatch between peer BTSs alarm
    [Arguments]  ${alias}  ${BTS_RMOD_sn_reset_list}

    Return From Keyword If  not ${BTS_RMOD_sn_reset_list}
    ${peer_alias}=  Set Variable If  '${alias}'=='Master'  Slave  Master

    ${BTS_controller_role_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${alias}
    ${peer_BTS_controller_role_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${peer_alias}
    ${BTS_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_role_RMOD_sn_list}  BTS_secondary_controller_RMOD_sn_list
    ${peer_BTS_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${peer_BTS_controller_role_RMOD_sn_list}
    ...  BTS_secondary_controller_RMOD_sn_list

    ${BTS_config_mismatch_alarms_expected}=  Evaluate  list(set(${BTS_secondary_controller_RMOD_sn_list}) & set(${BTS_RMOD_sn_reset_list}))
    ${peer_BTS_config_mismatch_alarms_expected}=  Evaluate  list(set(${peer_BTS_secondary_controller_RMOD_sn_list}) & set(${BTS_RMOD_sn_reset_list}))

    ${expected_alarms_count}=  Get Length  ${BTS_config_mismatch_alarms_expected}
    ${peer_expected_alarms_count}=  Get Length  ${peer_BTS_config_mismatch_alarms_expected}

    ${BTS_EXPECTED_ALARMS_full}=  Run Keyword If  ${expected_alarms_count}>0
    ...  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS}  ${expected_alarms_count}
    ${peer_BTS_EXPECTED_ALARMS_full}=  Run Keyword If  ${peer_expected_alarms_count}>0
    ...  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS}  ${peer_expected_alarms_count}

    Run Keyword If  ${expected_alarms_count}>0  Run Keywords
    ...  Log  Check BTS ${alias} alarms after operation on CB012619 feature on BTS ${alias}  console=True
    ...  AND  Log  BTS ${alias} "Configuration mismatch between peer BTSs (4742)" alarm, expected number: ${expected_alarms_count}  console=True
    ...  AND  Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${BTS_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    ...  AND  Log  BTS ${alias} "Configuration mismatch between peer BTSs (4742)" alarm, found number: ${expected_alarms_count}, as expected!
    ...  console=True

    Run Keyword If  ${peer_expected_alarms_count}>0  Run Keywords
    ...  Log  Check BTS ${peer_alias} alarms after operation on CB012619 feature on BTS ${alias}  console=True
    ...  AND  Log  BTS ${peer_alias} "Configuration mismatch between peer BTSs (4742)" alarm, expected number: ${peer_expected_alarms_count}
    ...  console=True
    ...  AND  Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=${peer_BTS_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${${peer_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}
    ...  AND  Log
    ...  BTS ${peer_alias} "Configuration mismatch between peer BTSs (4742)" alarm, found number: ${peer_expected_alarms_count}, as expected!
    ...  console=True

Get all BTS Modules SN ID mapping

    FOR  ${alias}  IN  @{alias_list}
        ${MODULE_sn_id_mapping_dict}=  Get All Modules SN ID mapping  ${alias}
        Set Test Variable  ${${alias}_MODULE_sn_id_mapping_dict}  ${MODULE_sn_id_mapping_dict}
    END

Read Real Time Measurements on BTS

    ${alias_real_time_meas_RMOD_dict}=  Create Dictionary
    Set Test Variable  ${alias_real_time_meas_RMOD_dict}
    ${real_time_meas_RMOD_dict}=  Create Dictionary
    Set Test Variable  ${real_time_meas_RMOD_dict}

    FOR  ${alias}  IN  @{alias_list}
        ${rtm_output}=  coam.Get Measurements  measurement_type=realTime  connection=${alias}
        Get RMOD power measurements  ${rtm_output}
        Set To Dictionary  ${alias_real_time_meas_RMOD_dict}  ${alias}=${real_time_meas_RMOD_dict}
    END

Get RMOD power measurements
    [Arguments]  ${rtm_output}

    FOR  ${item}  IN  @{rtm_output}
        Idetify RMOD power measurements  ${item}
    END

Idetify RMOD power measurements
    [Arguments]  ${rtm_output_element}

    FOR  ${item}  IN  @{rtm_output_element}
        Continue For Loop If  'ENERGY_EFFICIENCY/RMOD/' not in '${item}'
        ${RMOD_Id}=  Fetch From Right  ${item}  ENERGY_EFFICIENCY/RMOD/
        ${voltage_power_dict}=  Get From Dictionary  ${rtm_output_element}  ${item}
        ${status}  ${resp}=  Run Keyword And Ignore Error  Dictionary Should Contain Key  ${voltage_power_dict}  power
        Continue For Loop If  '${status}'!='PASS'
        ${power}=  Get From Dictionary  ${voltage_power_dict}  power
        Set To Dictionary  ${real_time_meas_RMOD_dict}  ${RMOD_Id}=${power}
    END

Check And Print Power Values for selected RMODs
    [Arguments]  ${alias}  ${timestamp}  ${actPimCancellationBypass}  ${compare_to_previous_value}=True

    Log  Checking and printing real time measurements info for BTS ${alias}  console=True

    Append To File  ${RMOD_power_RTM_output_file}
    ...  \n\n >>> Real Time Measurements RMOD Power at: ${timestamp} for BTS ${alias} (actPimCancellationBypass=${actPimCancellationBypass}) \n\n

    ${BTS_controller_role_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${alias}
    ${BTS_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_role_RMOD_sn_list}  BTS_primary_controller_RMOD_sn_list
    ${BTS_power_RTM_values}=  Get From Dictionary  ${alias_real_time_meas_RMOD_dict}  ${alias}
    ${BTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}

    FOR  ${RMOD_SN}  IN  @{RMOD_all_sn_list}
        Continue For Loop If  '${RMOD_SN}' not in ${BTS_RMOD_sn_list}
        Continue For Loop If  '${RMOD_SN}' not in ${BTS_primary_controller_RMOD_sn_list}
        ${RMOD_id}=  Get From Dictionary  ${${alias}_MODULE_sn_id_mapping_dict}  ${RMOD_SN}
        ${RMOD_R_Id}=  Fetch From Right  ${RMOD_id}  /
        ${status}  ${RMOD_power_value}=  Run Keyword And Ignore Error  Get From Dictionary  ${BTS_power_RTM_values}  ${RMOD_R_Id}
        Run Keyword If  '${status}' == 'FAIL'  Run Keywords
        ...  Log  Couln't find power value for RMOD ${RMOD_SN} with ID ${RMOD_id}  level=WARN
        ...  AND  Set To Dictionary  ${RMOD_measurements_dict}  ${RMOD_SN}=NA
        ...  AND  Continue For Loop

        Append To File  ${RMOD_power_RTM_output_file}  \n RMOD ${RMOD_SN} with ID ${RMOD_id}: ${RMOD_power_value} W \n
        Log  Real Time Measurements appended to file: ${RMOD_power_RTM_output_file}  console=True
        Log  BTS ${alias} Real Time Measurements: RMOD SN ${RMOD_SN}, ID ${RMOD_id}: ${RMOD_power_value} W  console=True

        Run Keyword If  '${compare_to_previous_value}'=='False'  Run Keywords
        ...  Set To Dictionary  ${RMOD_measurements_dict}  ${RMOD_SN}=${RMOD_power_value}
        ...  AND  Continue For Loop

        ${RMOD_previous_power_value}=  Get From Dictionary  ${RMOD_measurements_dict}  ${RMOD_SN}

        Run Keyword If  '${RMOD_previous_power_value}' in ['NA', '-']  Run Keywords
        ...  Log  Cannot compare actual power value to previous value for RMOD ${RMOD_SN} with ID ${RMOD_id}, since previous value could not be read!
        ...  level=WARN
        ...  AND  Set To Dictionary  ${RMOD_measurements_dict}  ${RMOD_SN}=${RMOD_power_value}
        ...  AND  Continue For Loop

        Run Keyword If  '${RMOD_power_value}' in ['NA', '-']  Run Keywords
        ...  Log
        ...  Can't compare actual power value to previous value for RMOD ${RMOD_SN} with ID ${RMOD_id}, since actual value could not be read properly!
        ...  level=WARN
        ...  AND  Set To Dictionary  ${RMOD_measurements_dict}  ${RMOD_SN}=${RMOD_power_value}
        ...  AND  Continue For Loop

        ${RMOD_actual_power_value_float}=  Convert To Number  ${RMOD_power_value}
        ${RMOD_previous_power_value_float}=  Convert To Number  ${RMOD_previous_power_value}

        ${diff}=  Run Keyword If  "${actPimCancellationBypass}"=="true"
        ...  Evaluate  ${RMOD_previous_power_value_float}-${RMOD_actual_power_value_float}
        ...  ELSE  Evaluate  ${RMOD_actual_power_value_float}-${RMOD_previous_power_value_float}

        ${DELTA_POWER_THR}=  Run Keyword If  "${ALLOWED_RMOD_SN_LIST}"!="ALL"  Get From Dictionary  ${RMOD_SN_delta_power_thr_mapping}  ${RMOD_SN}
        ...  ELSE  Set Variable  ${DELTA_POWER_THR}

        Run Keyword If  ${diff}<${DELTA_POWER_THR}
        ...  Log  DELTA_POWER_THR=${DELTA_POWER_THR} condtition not met for RMOD ${RMOD_SN} with ID ${RMOD_id}  level=WARN
        ...  ELSE  Log  DELTA_POWER_THR=${DELTA_POWER_THR} check succeded!  console=True

        Set To Dictionary  ${RMOD_measurements_dict}  ${RMOD_SN}=${RMOD_power_value}
    END

Check RMOD reset behavior on BTS
    [Arguments]  ${RMOD_sn_list}  ${alias}  ${reset_expected}=True

    ${RMOD_sn_Uptime_dict_initial}=  Get From Dictionary  ${BTS_alias_RMOD_sn_Uptime_dict_initial}  ${alias}
    ${RMOD_sn_Uptime_dict_final}=  Get From Dictionary  ${BTS_alias_RMOD_sn_Uptime_dict_final}  ${alias}

    Check all RMODs RESET behavior based on Uptime info on BTS  RMOD_sn_list=${RMOD_sn_list}
    ...  RMOD_sn_Uptime_dict_initial=${RMOD_sn_Uptime_dict_initial}  RMOD_sn_Uptime_dict_final=${RMOD_sn_Uptime_dict_final}  alias=${alias}
    ...  reset_expected=${reset_expected}

Check all RMODs RESET behavior based on Uptime info on BTS
    [Arguments]  ${RMOD_sn_list}  ${RMOD_sn_Uptime_dict_initial}  ${RMOD_sn_Uptime_dict_final}  ${alias}  ${reset_expected}=True

    ${BTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}

    FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}

        Continue For Loop If  '${RMOD_sn}' not in ${BTS_RMOD_sn_list}
        ${RMOD_sn_initial}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${RMOD_sn_Uptime_dict_initial}  ${RMOD_sn}
        ${RMOD_sn_final}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${RMOD_sn_Uptime_dict_final}  ${RMOD_sn}
        Continue For Loop If  (not ${RMOD_sn_initial}) or (not ${RMOD_sn_final})

        ${RMOD_Uptime_initial}=  Get From Dictionary  ${RMOD_sn_Uptime_dict_initial}  ${RMOD_sn}
        ${RMOD_Uptime_final}=  Get From Dictionary  ${RMOD_sn_Uptime_dict_final}  ${RMOD_sn}

        Check single RMOD RESET behavior based on Uptime info on BTS
        ...  ${RMOD_sn}  ${RMOD_Uptime_initial}  ${RMOD_Uptime_final}  ${alias}  ${reset_expected}

    END

Check single RMOD RESET behavior based on Uptime info on BTS
    [Arguments]  ${RMOD_sn}  ${RMOD_Uptime_initial}  ${RMOD_Uptime_final}  ${alias}  ${reset_expected}=True

    Run Keyword If  ${reset_expected}  Log  Expecting RMOD ${RMOD_sn} reset on BTS ${alias}  console=True
    ...  ELSE  Log  Expecting RMOD ${RMOD_sn} didn't reset on BTS ${alias}  console=True

    ${RMOD_Uptime_delta}=  Run Keyword If  ${reset_expected}  Evaluate  ${RMOD_Uptime_initial}-${RMOD_Uptime_final}
    ...  ELSE  Evaluate  ${RMOD_Uptime_final}-${RMOD_Uptime_initial}
    ${Uptime_log}=  Set Variable  (initial/final RMOD Uptime: ${RMOD_Uptime_initial} secs/${RMOD_Uptime_final} secs)

    Run Keyword If  ${RMOD_Uptime_delta} > 0
    ...  Log  BTS ${alias} RMOD_${RMOD_sn} reset behavior as expected ${Uptime_log}!  console=True
    ...  ELSE  Run Keywords
    ...  Log  BTS ${alias} RMOD_${RMOD_sn} reset behavior not as expected ${Uptime_log}!  level=ERROR
    ...  AND  Fail  BTS ${alias} RMOD_${RMOD_sn} reset behavior not as expected  ${Uptime_log}!

Determine which RMODs should reset
    [Arguments]  ${alias}

    ${BTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}
    ${BTS_RMOD_reset_list}=  Create List
    ${BTS_RMOD_not_reset_list}=  Create List
    ${BTS_controller_role_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${alias}
    ${BTS_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_role_RMOD_sn_list}  BTS_primary_controller_RMOD_sn_list

    FOR  ${RMOD_SN}  IN  @{RMOD_all_sn_list}
        Continue For Loop If  '${RMOD_SN}' not in ${BTS_RMOD_sn_list}
        Continue For Loop If  '${RMOD_SN}' not in ${BTS_primary_controller_RMOD_sn_list}
        ${RMOD_id}=  Get From Dictionary  ${${alias}_MODULE_sn_id_mapping_dict}  ${RMOD_SN}
        ${RMOD_SCF_DN}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
        ${param_value_dict}=  Get From Dictionary  ${${alias}_BTS_CB012619_feature_dict_initial}  ${RMOD_SCF_DN}
        ${actPimCancellation_initial_value}=  Get From Dictionary  ${param_value_dict}  actPimCancellation
        ${actPimCancellationBypass_initial_value}=  Get From Dictionary  ${param_value_dict}  actPimCancellationBypass
        Run Keyword If  '${actPimCancellation_initial_value}'!='false' or '${actPimCancellationBypass_initial_value}'!='false'
        ...  Append To List  ${BTS_RMOD_reset_list}  ${RMOD_SN}
        ...  ELSE  Append To List  ${BTS_RMOD_not_reset_list}  ${RMOD_SN}
    END

    [Return]  ${BTS_RMOD_reset_list}  ${BTS_RMOD_not_reset_list}

Perform CB012619 feature Delta Commissioning on BTS
    [Arguments]    ${Object_dn_parameter_value_dict}  ${alias}

    ${year}  ${month}  ${day}  ${hour}  ${min}=  Get Time  format=year,month,day,hour,min
    ${timestamp}=  Set Variable  ${year}_${month}_${day}_${hour}_${min}
    ${delta_id}=  Set Variable  CB012619_feature_delta_${timestamp}

    Create Delta  delta_id=${delta_id}
    Log  Delta Recommissioning JSON file ${delta_id} created  console=True

    FOR  ${obj_dn}  IN  @{Object_dn_parameter_value_dict}
        ${param_value_dict}=  Get From Dictionary  ${Object_dn_parameter_value_dict}  ${obj_dn}
        Append Managed Object Parameters from Dictionary To Delta  ${delta_id}  ${obj_dn}  ${param_value_dict}
    END

    ${delta_file}=  coam.Get Delta  delta_id=${delta_id}
    Log  Perform Delta Recommissioning on BTS ${alias} with JSON file ${delta_id}  console=True
    coam.Perform Delta Recommissioning  alias=${alias}  delta_file=${delta_file}  skip_parameter_relation_errors=True
    ...  should_activate=True
    Log  Delta Recommissioning on BTS with JSON file ${delta_id} successfully peformed console=True

    Remove Delta  delta_id=${delta_id}
    Log  Delta Recommissioning JSON file ${delta_id} removed  console=True

Check CB012619 Feature Delta Commissioning Succesfully Performed
    [Arguments]  ${exp_actPowerMeter}  ${exp_actPimCancellation}  ${exp_actPimCancellationBypass}  ${alias}

    Log  Checking parameters values after delta commissioning  console=True

    ${actPowerMeter}  ${mtBtsEnergyMonitoring}  ${mtSBTSRfmEnergyMonitoring}  ${mtSBTSSmEnergyMonitoring}=  Get feature CB006831 info  ${alias}

    Run Keyword If  "${actPowerMeter}"=="${exp_actPowerMeter}"
    ...  Log  actPowerMeter succesfully verified! Expected value: ${exp_actPowerMeter}/Found value: ${actPowerMeter}  console=True
    ...  ELSE  Run Keywords  Log  actPowerMeter verification failed! Expected value: ${exp_actPowerMeter}/Found value: ${actPowerMeter}  console=True
    ...  AND  Fail  actPowerMeter verification failed! Expected value: ${exp_actPowerMeter}/Found value: ${actPowerMeter}

    ${BTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}

    ${BTS_SCF_path_file}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}

    ${BTS_CB012619_feature_dict}=  Get CB012619 feature settings on BTS  ${alias}  ${BTS_SCF_path_file}

    FOR  ${RMOD_SN}  IN  @{RMOD_all_sn_list}
        Continue For Loop If  '${RMOD_SN}' not in ${BTS_RMOD_sn_list}
        ${RMOD_id}=  Get From Dictionary  ${${alias}_MODULE_sn_id_mapping_dict}  ${RMOD_SN}
        ${RMOD_SCF_DN}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
        ${param_value_dict}=  Get From Dictionary  ${BTS_CB012619_feature_dict}  ${RMOD_SCF_DN}
        Log  On RMOD ${RMOD_SN} with ID ${RMOD_id}:  console=True
        ${actPimCancellation}=  Get From Dictionary  ${param_value_dict}  actPimCancellation
        ${actPimCancellationBypass}=  Get From Dictionary  ${param_value_dict}  actPimCancellationBypass
        Run Keyword If  "${actPimCancellation}"=="${exp_actPimCancellation}"
        ...  Log  actPimCancellation succesfully verified! Expected value: ${exp_actPimCancellation}/Found value: ${actPimCancellation}  console=True
        ...  ELSE  Run Keywords
        ...  Log  actPimCancellation verification failed! Expected value: ${exp_actPimCancellation}/Found value: ${actPimCancellation}  console=True
        ...  AND  Fail  actPimCancellation verification failed! Expected value: ${exp_actPimCancellation}/Found value: ${actPimCancellation}
        Run Keyword If  "${actPimCancellationBypass}"=="${exp_actPimCancellationBypass}"
        ...  Log
        ...  actPimCancellationBypass succesfully verified! Expected value: ${exp_actPimCancellationBypass}/Found value: ${actPimCancellationBypass}
        ...  console=True
        ...  ELSE  Run Keywords
        ...  Log
        ...  actPimCancellationBypass verification failed! Expected value: ${exp_actPimCancellationBypass}/Found value: ${actPimCancellationBypass}
        ...  console=True
        ...  AND
        ...  Fail
        ...  actPimCancellationBypass verification failed! Expected value: ${exp_actPimCancellationBypass}/Found value: ${actPimCancellationBypass}
    END

Append Managed Object Parameters from Dictionary To Delta
    [Arguments]  ${delta_id}  ${obj_dn}  ${param_value_dict}

    FOR  ${param}  IN  @{param_value_dict}
        ${value}=  Get From Dictionary  ${param_value_dict}  ${param}
        Append Parameter Update To Delta  dist_name=${obj_dn}  parameter=${param}
        ...  value=${value}  delta_id=${delta_id}
        Log  Parameter ${param}=${value} appended to file ${delta_id}  console=True
    END

Recover initial settings for CB012619 feature
    [Documentation]
    ...  Keyword used to recover initial settings for CB012619 feature

    Log  Recover initial settings for CB012619 feature on all BTS  console=True

    FOR  ${alias}  IN  @{alias_list}
        Perform CB012619 feature Delta Commissioning on BTS  ${${alias}_BTS_CB012619_feature_dict_initial}  ${alias}
    END

Particular Teardown
    Recover initial settings for CB012619 feature

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
