*** Settings ***
Documentation    TC__CBTS_SBTS_CM_CBTS_Commissioning_RF_Sharing_from_Standalone_from_WebUI
Variables    tc_variables/cbts_sbts__cm__cbts_commissioning_rf_sharing_from_standalone_from_webui_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}     3    # Number of cycles to perform RF Sharing commissioning from Standalone, default value 3.
${VDU_SCF_PATH}            # SCF path to VDU standalone SCF, mandatory parameter
${BTS_MAX_WAIT_TIME}  900  # Maximum time to wait for BTS OnAir after reset (by default 900)

*** Keywords ***
TC__CBTS_SBTS__CM__CBTS_Commissioning_RF_Sharing_from_Standalone_from_WebUI
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29705
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  CBTS_SBTS test case for Commissioning RF Sharing from Standalone via Commissioning Wizard from WebUI, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - Check initial all BTS states and alarms
    ...  - Get all BTS info for configured items
    ...  - Check classical BTS power unit info
    ...  - Perform classical BTS Power Off
    ...  - Perform VDU Commissioning to Standalone Configuration by SCF
    ...  - Perform VDU Commissioning to RF Sharing Configuration via Commissioning Wizard
    ...  - Perform classical BTS Power On
    ...  - Check all BTS states and alarms after Commissioning to RF Sharing Configuration
    ...  - Check VDU shared RMOD parameters on Site View page
    ...  - Check final all BTS states and alarms
    ...  - Collect snapshot on demand on VDU
    ...  ***************************
    ...  History of changes
    ...  ***************************
    ...  - 01.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29705 - [CBTS]CB12501-CR-A Comissioning Wizzard RF_sharing configuration on Cloud
    ...  - 21.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29969 - [CB015051] rename TCs to shorten scripts and alarm files names
    ...  - 19.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30180 - [5G]Enhancement for CBTS_SBTS__CM__CBTS_Commissioning_RF_Sharing_from_
    ...  Standalone_from_WebUI
    ...  - 19.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30655 - CBTS_SBTS__CM__CBTS__Commissioning_RF_Sharing_from_Standalone_from_WebUI
    ...  fails with with locator not found

    Set Tags    CA-CM    OWNER-cosmin.florea@nokia.com@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-CRT    SW-SBTS26R1

    TC Preconditions
    Step 1: Check initial all BTS states
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    Step 4: Check classical BTS power unit info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Perform classical BTS Power Off
        Step 6: Perform VDU Commissioning to Standalone Configuration by SCF
        Step 7: Perform VDU Commissioning to RF Sharing Configuration via Commissioning Wizard
        Step 8: Perform classical BTS Power On
        Step 9: Check all BTS states and alarms after Commissioning to RF Sharing Configuration
        Step 10: Check VDU shared RMOD parameters on Site View page
        Step 11: Check final all BTS states
        Step 12: Check final all BTS alarms
        Step 13: Check final number and state of Cells and RMs
     END
    Step 14: Collect snapshot on demand on VDU

    [Teardown]  Particular Teardown

TC Preconditions
    Should Not Be Empty  ${VDU_SCF_PATH}
    OperatingSystem.File Should Exist  ${VDU_SCF_PATH}

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RMOD_sn_list}
    Set Test Variable  ${dedicated_RMOD_sn_list}

    Set Test Variable  ${CBTS_VDU_state_onair}  Operational state=OnAir
    Set Test Variable  ${CBTS_VDU_RMOD_state_enabled}  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked
    Set Test Variable  ${CBTS_VDU_CELL_state_enabled}
    ...  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked, Blocking state=Unblocked
    Set Test Variable  ${SBTS_RMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${SBTS_RMOD_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${SBTS_CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${SBTS_CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

Step ${index}: Check ${when} all BTS states
    [Documentation]
    ...  BTS states is checked as follows:
    ...  - CBTS CU - Operational State: Enabled
    ...  - CBTS VDUs - Operational State: OnAir
    ...  - SBTS RAT - Procedural State: OnAir
    ...  - SBTS BTS - Procedural State: OnAir, Blocking State: Unblocked

    Log  Step ${index}: Check ${when} all BTS states  console=True

    FOR  ${alias}  IN  @{alias_list}

        IF  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'
            Log  ***** Check ${when} cloud BTS ${alias} state *****  console=True
            Check CBTS CU VDU Operational State  alias=${alias}  timeout=600
            Log  ${alias} BTS site - CU Operational State: Enabled, VDUs Operational State: OnAir  console=True
        ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']
            Log  ***** Check ${when} classical BTS ${alias} state *****  console=True
            Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
            Admin Check BTS Procedural and Blocking states  exp_pro_state=${OnAir_}  exp_blk_state=${Unblocked_}  timeout=600  alias=${alias}
            Log  ${alias} BTS site - Procedural State: OnAir, Blocking State: Unblocked  console=True
        END
    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  BTS alarms are compared with values from expected, ignored and critical alarms lists.

    Log  Step ${index}: Check ${when} all BTS alarms  console=True

    FOR  ${alias}  IN  @{alias_list}

        IF  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'
            Log  ***** Check ${when} cloud BTS ${alias} alarms *****  console=True
            Get and Check Alarms CBTS  alias=${alias}
        ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']
            Log  ***** Check ${when} classical BTS ${alias} alarms *****  console=True
            Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}
            ...  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
            ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        END

        Log  ${alias} BTS site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Get all BTS info for configured items
    [Documentation]
    ...  Get all BTS info about following items:
    ...  - dictionary containing structure: {'BTS_alias': '<RMOD_serial_number_list>'}
    ...  - dictionary containing structure: {'RMOD_serial_number': '<BTS_alias_list>'}
    ...  - list of shared RMOD serial number
    ...  - list of dedicated RMOD serial number

    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${BTS_all_alias_list}=  Get Dictionary Keys  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${BTS_all_alias_list}

    ${all_BTS_controller_role_RMOD_sn_list}=  Get all BTS controller role for configured RMOD from SCF
    Set Test Variable  ${all_BTS_controller_role_RMOD_sn_list}

    FOR  ${bts_alias}  IN  @{BTS_all_alias_list}

        ${RM_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${bts_alias}
        ${BTS_controller_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${bts_alias}
        ${BTS_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_primary_controller_RMOD_sn_list
        ${BTS_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_secondary_controller_RMOD_sn_list
        ${all_BTS_RMOD_sn_list}=  Combine Lists  ${BTS_primary_controller_RMOD_sn_list}  ${BTS_secondary_controller_RMOD_sn_list}

        Log  BTS ${bts_alias} is primary controller for: ${BTS_primary_controller_RMOD_sn_list}  console=True
        Log  BTS ${bts_alias} is secondary controller for: ${BTS_secondary_controller_RMOD_sn_list}  console=True

        Set Test Variable  ${${bts_alias}_BTS_primary_controller_RMOD_sn_list}  ${BTS_primary_controller_RMOD_sn_list}
        Set Test Variable  ${${bts_alias}_BTS_secondary_controller_RMOD_sn_list}  ${BTS_secondary_controller_RMOD_sn_list}
        Set Test Variable  ${${bts_alias}_all_BTS_RMOD_sn_list}  ${all_BTS_RMOD_sn_list}

    END

    FOR  ${bts_alias}  IN  @{BTS_all_alias_list}

        ${is_vdu_alias}=  Run Keyword And Return Status  Should Contain  ${bts_alias}  VDU
        IF  not ${is_vdu_alias}  CONTINUE

        ${VDU_RMOD_sn_id_dict}  ${VDU_RMOD_id_sn_dict}  ${VDU_RMOD_sn_pn_dict}  ${VDU_RMOD_sn_interface_dict}=  VDU Get RMOD sn id pn interface info
        ...  vdu_connection=${bts_alias}
        ${VDU_CELL_id_config_dn_dict}=  VDU Get Cells id config info  vdu_connection=${bts_alias}

        ${VDU_RMOD_ids_list}=  Get Dictionary Keys  ${VDU_RMOD_id_sn_dict}
        ${VDU_NR_CELL_ids_list}=  Get Dictionary Keys  ${VDU_CELL_id_config_dn_dict}

        Set Test Variable  ${${bts_alias}_VDU_RMOD_sn_id_dict}  ${VDU_RMOD_sn_id_dict}
        Set Test Variable  ${${bts_alias}_VDU_RMOD_sn_pn_dict}  ${VDU_RMOD_sn_pn_dict}
        Set Test Variable  ${${bts_alias}_VDU_RMOD_ids_list}  ${VDU_RMOD_ids_list}
        Set Test Variable  ${${bts_alias}_VDU_NR_CELL_ids_list}  ${VDU_NR_CELL_ids_list}

    END

    Check feature CB007878 status on both BTS for shared RMOD

    FOR  ${RMOD_sn}  IN  @{shared_RMOD_sn_list}

        Get cloud BTS module location for shared RMOD  ${RMOD_sn}

    END

    Download current SW build version for classical BTS

Step ${index}: Check classical BTS power unit info
    [Documentation]
    ...  Keyword used to check if BTS SMs PDU are defined, can be reached and their status is on

    Log  Step ${index}: Check classical BTS power unit info  console=True

    FOR  ${bts_alias}  IN  @{BTS_all_alias_list}

        ${is_vdu_alias}=  Run Keyword And Return Status  Should Contain  ${bts_alias}  VDU
        IF  ${is_vdu_alias}  CONTINUE

        ${BTS_SM_PDU_if_name_list}=  Check BTS SMs PDU info definition  ${bts_alias}
        Set Test Variable  ${${bts_alias}_SM_PDU_if_name_list}  ${BTS_SM_PDU_if_name_list}

        ${status}=  Check BTS SMs PDU port status  ${${bts_alias}_SM_PDU_if_name_list}  on
        IF  ${status}
            Log  BTS ${bts_alias} SMs PDU port status as expected!  console=True
        ELSE
            Log  PDU for BTS ${bts_alias} SMs is either not reachable or not switched on!  level=ERROR
            Fail  PDU for BTS ${bts_alias} SMs is either not reachable or not switched on!
        END

    END

Step ${index}: Perform classical BTS Power ${power}

    Log  Step ${index}: Perform classical BTS Power ${power}  console=True

    FOR  ${bts_alias}  IN  @{BTS_all_alias_list}

        ${is_vdu_alias}=  Run Keyword And Return Status  Should Contain  ${bts_alias}  VDU
        IF  ${is_vdu_alias}  CONTINUE

        Power classical BTS  alias=${bts_alias}  power=${power}

        IF  '${power}' == 'Off'  CONTINUE

        ${fid_23_status}=  Run Keyword And Return Status  Assert Alarm Active  faultId=23  timeout=240  connection=${bts_alias}
        IF  ${fid_23_status}
            Log Long String  Perform SW update on BTS ${bts_alias} using active SW build ${${bts_alias}_BTS_package_name} to clean
            ...  "Incompatible SW version detected (23)" alarm
            coam.Update Software  sw_package=${${bts_alias}_BTS_package_path}  should_activate=True  timeout=${BTS_MAX_WAIT_TIME}
            ...  connection=${bts_alias}
            Log  SW update on BTS ${bts_alias} finished!  console=True
        END

        Sleep  60s  reason=Waiting time after sw update action

    END

Step ${index}: Perform VDU Commissioning to Standalone Configuration by SCF

    Log  Step ${index}: Perform VDU Commissioning to Standalone Configuration by SCF  console=True

    Set Test Variable  ${VDU_RF_SHARING_CONFIG}  False

    FOR  ${bts_alias}  IN  @{BTS_all_alias_list}

        ${is_vdu_alias}=  Run Keyword And Return Status  Should Contain  ${bts_alias}  VDU
        IF  not ${is_vdu_alias}  CONTINUE
        Log  Commissioning will be performed using ${VDU_SCF_PATH}  console=True

        VDU Perform Commissioning  scf_file=${VDU_SCF_PATH}  vdu_connection=${bts_alias}

        Wait For Target To Be Not Reachable TAF  hostname=${${bts_alias.lower()}_vdu_host}  timeout=300

        Sleep  20s  reason=Waiting time after commissioning action

        Log  *** Check BTS ${bts_alias} states and alarms after VDU Commissioning to Standalone Configuration on BTS ${bts_alias} ***  console=True
        Wait For Target To Be Reachable TAF  hostname=${${bts_alias.lower()}_vdu_host}  timeout=300

        Check cloud BTS states and alarms  vdu_alias=${bts_alias}

    END

Step ${index}: Perform VDU Commissioning to RF Sharing Configuration via Commissioning Wizard

    Log  Step ${index}: Perform VDU Commissioning to RF Sharing Configuration via Commissioning Wizard  console=True

    FOR  ${bts_alias}  IN  @{BTS_all_alias_list}

        ${is_vdu_alias}=  Run Keyword And Return Status  Should Contain  ${bts_alias}  VDU
        IF  not ${is_vdu_alias}  CONTINUE

        ${vdu_alias_list}=  Split String  ${bts_alias}  separator=
        ${alias}=  Get From List  ${vdu_alias_list}  0
        ${vdu_alias}=  Get From List  ${vdu_alias_list}  1

        Log  Perform VDU Commissioning to RF Sharing Configuration BTS ${bts_alias}  console=True

        Perform Commissioning to RF Sharing Configuration via Commissioning Wizard  alias=${alias}  vdu_alias=${vdu_alias}

    END

    Set Test Variable  ${VDU_RF_SHARING_CONFIG}  True

Step ${index}: Check all BTS states and alarms after Commissioning to RF Sharing Configuration

    Log  Step ${index}: Check all BTS states and alarms after Commissioning to RF Sharing Configuration  console=True

    FOR  ${bts_alias}  IN  @{BTS_all_alias_list}

        ${is_vdu_alias}=  Run Keyword And Return Status  Should Contain  ${bts_alias}  VDU

        Log  *** Check BTS ${bts_alias} states and alarms after VDU Commissioning to RF Sharing Configuration ***  console=True

        IF  ${is_vdu_alias}
            Check cloud BTS states and alarms  vdu_alias=${bts_alias}
        ELSE
            Check classical BTS states and alarms  alias=${bts_alias}
        END

    END

Step ${index}: Check VDU shared RMOD parameters on Site View page

    Log  Step ${index}: Check VDU shared RMOD parameters on Site View page  console=True

    FOR  ${bts_alias}  IN  @{BTS_all_alias_list}

        ${is_vdu_alias}=  Run Keyword And Return Status  Should Contain  ${bts_alias}  VDU
        IF  not ${is_vdu_alias}  CONTINUE

        ${vdu_alias_list}=  Split String  ${bts_alias}  separator=
        ${alias}=  Get From List  ${vdu_alias_list}  0
        ${vdu_alias}=  Get From List  ${vdu_alias_list}  1

        Log  Check VDU shared RMOD parameters on Site View page BTS ${bts_alias}  console=True
        Check shared RMOD parameters on Site View page  alias=${alias}  vdu_alias=${vdu_alias}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Step ${index}: Collect snapshot on demand on VDU

    Log  Step ${index}: Collect snapshot on demand on VDU  console=True

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${snapshot_and_alarms_dir}=  Set Variable  ${Test Results Dir}/Snapshot__${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}
    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${snapshot_and_alarms_dir}
    IF  not ${status}  Create Directory  ${snapshot_and_alarms_dir}

    FOR  ${alias}  IN  @{alias_list}

        IF  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'
            Collect VDU Snapshot  folder_path=${snapshot_and_alarms_dir}  alias=${alias}
        END

    END

Get cloud BTS shared RMOD active sw version
    [Arguments]  ${RMOD_sn}  ${vdu_alias}

    ${VDU_RMOD_info}=  vdu.Get Rmods Status  vdu_connection=${vdu_alias}

    FOR  ${rmod_info}  IN  @{VDU_RMOD_info}

        ${VDU_RMOD_sn}=  Get From Dictionary  ${rmod_info}  serial_number

        IF  '${VDU_RMOD_sn}' != '${RMOD_sn}'  CONTINUE

        ${VDU_RMOD_active_sw_version}=  Get From Dictionary  ${rmod_info}  active_sw_version
        RETURN  ${VDU_RMOD_active_sw_version}

    END

Check feature CB007878 status on both BTS for shared RMOD

    ${CB007878_shared_RMOD_sn_list}=  Create List
    Set Test Variable  ${CB007878_shared_RMOD_sn_list}

    Log  Check feature CB007878 settings for shared RMOD list: ${shared_RMOD_sn_list}  console=True

    FOR  ${RMOD_sn}  IN  @{shared_RMOD_sn_list}

        ${RMOD_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}
        Check feature CB007878 status  ${RMOD_sn}  ${RMOD_BTS_alias_list}

    END

    ${CB007878_shared_RMOD_sn_list}=  Remove Duplicates  ${CB007878_shared_RMOD_sn_list}
    Set Test Variable  ${CB007878_shared_RMOD_sn_list}

Check feature CB007878 status
    [Arguments]  ${RMOD_sn}  ${RMOD_BTS_alias_list}

    ${RMOD_sn_list}=  Create List  ${RMOD_sn}
    ${CB007878_shared_RMOD_info}=  Create List

    FOR  ${alias}  IN  @{RMOD_BTS_alias_list}

        IF  '${alias}' in ${alias_list}
            ${BTS_feature_CB007878_dict}=  Get feature CB007878 settings on classical BTS  RMOD_sn_list=${RMOD_sn_list}  alias=${alias}
        ELSE
            ${BTS_feature_CB007878_dict}=  Get feature CB007878 settings on cloud BTS  RMOD_sn_list=${RMOD_sn_list}  vdu_alias=${alias}
        END

        ${actSharedRUIndControl_info}=  Get From Dictionary  ${BTS_feature_CB007878_dict}  ${RMOD_sn}

        Log  - BTS ${alias} RMOD_${RMOD_sn} actSharedRUIndControl: ${actSharedRUIndControl_info}  console=True

        Append To List  ${CB007878_shared_RMOD_info}  ${actSharedRUIndControl_info}

    END

    ${CB007878_shared_RMOD_info}=  Remove Duplicates  ${CB007878_shared_RMOD_info}
    ${CB007878_status_shared_RMOD}=  Get Length  ${CB007878_shared_RMOD_info}

    IF  ${CB007878_status_shared_RMOD} == 1 and '${CB007878_shared_RMOD_info[0]}' == 'true'
        Append To List  ${CB007878_shared_RMOD_sn_list}  ${RMOD_sn}
    END

Get cloud BTS module location for shared RMOD
    [Arguments]  ${RMOD_sn}


    ${BTS_alias_RMOD_sn_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}

    FOR  ${bts_alias}  IN  @{BTS_alias_RMOD_sn_list}

        ${is_vdu_alias}=  Run Keyword And Return Status  Should Contain  ${bts_alias}  VDU
        IF  not ${is_vdu_alias}  CONTINUE

        Log  Get moduleLocation parameter value for BTS ${bts_alias} shared RMOD_${RMOD_sn}  console=True

        Get module location for shared RMOD  ${RMOD_sn}  ${bts_alias}

    END

Get module location for shared RMOD
    [Arguments]  ${RMOD_sn}  ${vdu_alias}

    ${VDU_SCF_path_file_info}=  VDU Get Current Plan File  vdu_connection=${vdu_alias}

    ${VDU_RMOD_sn_config_dict}  ${VDU_RMOD_config_sn_dict}  ${VDU_RMOD_sn_runtime_dict}  ${VDU_RMOD_runtime_sn_dict}=
    ...  VDU Get RMOD sn config runtime info  vdu_connection=${vdu_alias}

    ${VDU_SCF_RMOD_list}=  Get All Dist Names By Pattern from SCF  pattern=/RMOD-[\\d]+$  scf_path=${VDU_SCF_path_file_info}
    ...  alias=${vdu_alias}

    FOR  ${RMOD_dn}  IN  @{VDU_SCF_RMOD_list}

        ${vdu_RMOD_sn}=  Get From Dictionary  ${VDU_RMOD_config_sn_dict}  ${RMOD_dn}

        IF  '${vdu_RMOD_sn}' != '${RMOD_sn}'  CONTINUE

        ${scf_xml}=  Parse XML  ${VDU_SCF_path_file_info}

        ${elements}=  Get Elements  ${scf_xml}  .//managedObject[@distName="${RMOD_dn}"]/list[@name="sharingConfig"]/item/p[@name="moduleLocation"]
        IF  ${elements}
            ${moduleLocation_value}=  Get Element Text  ${elements}[0]
            Log  BTS ${vdu_alias} moduleLocation parameter value for RMOD_${RMOD_sn}: ${moduleLocation_value}  console=True
        ELSE
            ${moduleLocation_value}=  Set Variable  L0123456
            Log Long String  BTS ${vdu_alias} moduleLocation parameter value for RMOD_${RMOD_sn} is not set. During commissioning to RF
            ...  Sharing configuration, it will be set to: L0123456
        END

        Set Test Variable  ${${RMOD_sn}_moduleLocation_value}  ${moduleLocation_value}

        IF  '${vdu_RMOD_sn}' == '${RMOD_sn}'  BREAK

    END

Download current SW build version for classical BTS

    FOR  ${bts_alias}  IN  @{BTS_all_alias_list}

        ${is_vdu_alias}=  Run Keyword And Return Status  Should Contain  ${bts_alias}  VDU
        IF  ${is_vdu_alias}    CONTINUE

        Log  Download current SW build version for classical BTS ${bts_alias}  console=True

        Admin Get BTS SW Version  alias=${bts_alias}
        ${RMOD_active_sw_version}=  Get classical BTS shared RMOD active sw version  alias=${bts_alias}

        ${BTS_package_directory}=  Set Variable  /home/ute/Downloads

        IF  'trunk' in '${RMOD_active_sw_version}'
            ${BTS_package_name}=  Replace String Using Regexp  ${${bts_alias} active SW}  SBTS[A-Z0-9]+_(.*)  SBTS00_\\1
        ELSE
            ${BTS_package_name}=  Set Variable  ${${bts_alias} active SW}
        END

        Download And Set Current SW for SWDL  Target_SW_dir=${BTS_package_directory}  preloaded_package=${BTS_package_name}

        Set Test Variable  ${${bts_alias}_BTS_package_name}  ${Target Package Name}
        Set Test Variable  ${${bts_alias}_BTS_package_path}  ${Target SW}

    END

Get classical BTS shared RMOD active sw version
    [Arguments]  ${alias}

    ${BTS_RMOD_info}=  coam.Get Parameters For All  class_name=RMOD  connection=${alias}

    FOR  ${rmod_info}  IN  @{BTS_RMOD_info}

        ${BTS_RMOD_active_sw_version}=  Get From Dictionary  ${rmod_info}  buildVersion
        RETURN  ${BTS_RMOD_active_sw_version}

    END

Power classical BTS
    [Arguments]  ${alias}  ${power}

    Log  Power ${power} BTS ${alias}  console=True

    ${power_lower}=  Convert To Lower Case  ${power}

    ${PDU_port_status}=  Set BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  ${power_lower}
    IF  ${PDU_port_status}
        Log  BTS ${alias} SMs PDU port status ${power}, as expected!  console=True
    ELSE
        Log  Set BTS ${alias} SMs PDU port status ${power} failed!  level=ERROR
        Fail  Set BTS ${alias} SMs PDU port status ${power} failed!
    END

    ${hostname_ip}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    IF  '${power_lower}' == 'off'
        Wait For Target To Be Not Reachable TAF  hostname=${hostname_ip}  timeout=300  remote_host=${remote_host_ip}
    ELSE IF  '${power_lower}' == 'on'
        Wait For Target To Be Reachable TAF  hostname=${hostname_ip}  timeout=300  remote_host=${remote_host_ip}
    END

    Sleep  1 m  reason=Waiting time after power off/on action

Check cloud BTS states and alarms
    [Arguments]  ${vdu_alias}

    Log  Check BTS ${vdu_alias} status:  console=True
    Check CBTS VDU state  ${CBTS_OnAir_}  ${CBTS_VDU_state_onair}  ${BTS_MAX_WAIT_TIME}  ${vdu_alias}

    Log  Check BTS ${vdu_alias} RMODs status:  console=True
    Check CBTS VDU RMOD state  ${${vdu_alias}_VDU_RMOD_ids_list}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}  ${CBTS_VDU_RMOD_state_enabled}
    ...  ${BTS_MAX_WAIT_TIME}  ${vdu_alias}

    Log  Check BTS ${vdu_alias} cells status:  console=True
    Check CBTS VDU cell state  ${${vdu_alias}_VDU_NR_CELL_ids_list}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}  ${CBTS_Unblocked_}
    ...  ${CBTS_VDU_CELL_state_enabled}  ${BTS_MAX_WAIT_TIME}  ${vdu_alias}

    ${vdu_alias_alarm}=  Replace String  ${vdu_alias}  ${SPACE}  _
    Log  Check BTS ${vdu_alias} alarms:  console=True
    Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${test_alarms_list['${vdu_alias_alarm.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${vdu_alias_alarm.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${vdu_alias} site - expected, ignored and critical alarms checked  console=True

Check classical BTS states and alarms
    [Arguments]  ${alias}

    Log  Check BTS ${alias} status:  console=True
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${BTS_MAX_WAIT_TIME}  ${alias}
    Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    Check cells availability status online  ${alias}  ${BTS_MAX_WAIT_TIME}
    Log  All BTS ${alias} cell(s) status:\n - operationalState=Enabled, blockingState=Unblocked  console=True

    Log  Check BTS ${alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check CBTS VDU state
    [Arguments]  ${VDU_operational_state_check}  ${VDU_state_check}  ${timeout}  ${vdu_alias}
    Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check VDU Expected Status  operational_state=${VDU_operational_state_check}
    ...  vdu_connection=${vdu_alias}
    Log  ${vdu_alias} status:\n - ${VDU_state_check}  console=True

Check CBTS VDU RMOD state
    [Arguments]  ${VDU_RMOD_ids}  ${RMOD_operational_state_check}  ${RMOD_availability_status_check}  ${RMOD_administrative_state_check}
    ...  ${RMOD_state}  ${timeout}  ${vdu_alias}

    FOR  ${item}  IN  @{VDU_RMOD_ids}

        Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check RMOD Expected Status  rmod_id=${item}
        ...  operational_state=${RMOD_operational_state_check}  availability_status=${RMOD_availability_status_check}
        ...  administrative_state==${RMOD_administrative_state_check}  vdu_connection=${vdu_alias}

    END
    Log  ${vdu_alias} RMODs status:\n - ${RMOD_state}  console=True

Check CBTS VDU cell state
    [Arguments]  ${VDU_CELL_ids}  ${CELL_operational_state_check}  ${CELL_availability_status_check}  ${CELL_administrative_state_check}
    ...  ${CELL_blocking_state_check}  ${CELL_state}  ${timeout}  ${vdu_alias}

    FOR  ${item}  IN  @{VDU_CELL_ids}

        Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check Cell Expected Status  cell_id=${item}
        ...  operational_state=${CELL_operational_state_check}  availability_status=${CELL_availability_status_check}
        ...  administrative_state==${CELL_administrative_state_check}  blocking_state=${CELL_blocking_state_check}  vdu_connection=${vdu_alias}

    END
    Log  ${vdu_alias} cells status:\n - ${CELL_state}  console=True

Perform Commissioning to RF Sharing Configuration via Commissioning Wizard
    [Arguments]  ${alias}  ${vdu_alias}

    VDU WebEM Setup  alias=${alias}  vdu_alias=${vdu_alias}

    Commission BTS in RF Sharing using Commissioning Wizard  alias=${alias}  vdu_alias=${vdu_alias}
    Commission BTS in RF Sharing using Parameter Editor  alias=${alias}  vdu_alias=${vdu_alias}

    VDU WebEM Perform Validate Plan  alias=${alias}  vdu_alias=${vdu_alias}
    VDU WebEM Perform Activate Plan with VDU reset  alias=${alias}  vdu_alias=${vdu_alias}

    [Teardown]  VDU WebEM Teardown  alias=${alias}  vdu_alias=${vdu_alias}

Commission BTS in RF Sharing using Commissioning Wizard
    [Arguments]  ${alias}  ${vdu_alias}  ${timeout}=30

    VDU WebEM Open Commissioning Wizard Menu  alias=${alias}  vdu_alias=${vdu_alias}

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//li[@aria-label='RF Sharing']

    Configure RF sharing enabled parameter on true  ${alias}  ${vdu_alias}
    Configure RF sharing settings for each shared RMOD  ${alias}  ${vdu_alias}

    VDU WebEM Perform Save Commissioning Wizard Changes  alias=${alias}  vdu_alias=${vdu_alias}

    Delete HDLC communication and DC voltage level for BTS secondary controller shared RMODs  alias=${alias}  vdu_alias=${vdu_alias}

    VDU WebEM Perform Save Commissioning Wizard Changes  alias=${alias}  vdu_alias=${vdu_alias}

Commission BTS in RF Sharing using Parameter Editor
    [Arguments]  ${alias}  ${vdu_alias}

    VDU WebEM Open Parameter Editor Menu  alias=${alias}  vdu_alias=${vdu_alias}

    Delete parameter for BTS secondary controller shared RMODs  alias=${alias}  vdu_alias=${vdu_alias}  parameter_name=administrativeState
    Delete parameter for BTS secondary controller shared RMODs  alias=${alias}  vdu_alias=${vdu_alias}  parameter_name=alVoltHighThreshold
    Delete parameter for BTS secondary controller shared RMODs  alias=${alias}  vdu_alias=${vdu_alias}  parameter_name=alVoltLowThreshold
    Delete parameter for BTS secondary controller shared RMODs  alias=${alias}  vdu_alias=${vdu_alias}  parameter_name=alVoltUnstableThreshold
    Set actTempRadioMaster on true on BTS secondary controller  alias=${alias}  vdu_alias=${vdu_alias}
    IF  ${CB007878_shared_RMOD_sn_list}
        Set actSharedRUIndControl on true on shared RMODs  alias=${alias}  vdu_alias=${vdu_alias}
    END

    Sleep  1s  reason=Waiting time to control execution speed

Delete HDLC communication and DC voltage level for BTS secondary controller shared RMODs
    [Arguments]  ${alias}  ${vdu_alias}  ${timeout}=30

    ${bts_alias}=  Set Variable  ${alias} ${vdu_alias}

    Log  *** Delete HDLC communication and DC voltage level for BTS ${bts_alias} secondary controller shared RMODs if needed ***  console=True

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//li[@aria-label='Radio Module Settings']

    FOR  ${RMOD_sn}  IN  @{${bts_alias}_BTS_secondary_controller_RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${bts_alias}_VDU_RMOD_sn_id_dict}  ${RMOD_sn}
        ${RMOD_pn}=  Get From Dictionary  ${${bts_alias}_VDU_RMOD_sn_pn_dict}  ${RMOD_sn}

        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath=//div[@aria-label='${RMOD_pn} RMOD-${RMOD_id}/RMOD_R-${RMOD_id}']

        ${table_columns}=  SeleniumLibrary.Get Element Count  //p-table[@class='p-element ot-scroll-table']//thead/tr/th

        Delete HDLC communication and DC voltage level if needed  ${RMOD_id}

    END

Delete HDLC communication and DC voltage level if needed
    [Arguments]   ${RMOD_id}

    ${table_columns}=  SeleniumLibrary.Get Element Count  //p-table[@class='p-element ot-scroll-table']//thead/tr/th

    FOR  ${column}  IN RANGE  1  ${table_columns}+1

        ${column_value}=  Get Text  //p-table[@class='p-element ot-scroll-table']//thead/tr/th[${column}]

        IF  '${column_value}' == 'HDLC communication'
            Delete HDLC communication/DC voltage level  ${column}  ${RMOD_id}  HDLC communication
        ELSE IF  '${column_value}' == 'DC voltage level'
            Delete HDLC communication/DC voltage level  ${column}  ${RMOD_id}  DC voltage level
        END
    END

Delete HDLC communication/DC voltage level
    [Arguments]  ${column}  ${RMOD_id}  ${parameter_name}  ${timeout}=30

    ${table_rows}=  SeleniumLibrary.Get Element Count  //p-table[@class='p-element ot-scroll-table']//tbody/tr

    FOR  ${table_row}  IN RANGE   1  ${table_rows}+1

        ${antenna_port}=  Get Text  //p-table[@class='p-element ot-scroll-table']//tbody/tr[${table_row}]/td[1]
        ${parameter_value}=  Get Text  //p-table[@class='p-element ot-scroll-table']//tbody/tr[${table_row}]/td[${column}]

        IF  '${parameter_value}' == '<Select value>' or '${parameter_value}' == ''  CONTINUE
        Log  ${parameter_name} for RMOD-${RMOD_id} ${antenna_port} is set to ${parameter_value}. Value will be deleted.  console=True

        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  //p-table[@class='p-element ot-scroll-table']//tbody/tr[${table_row}]/td[${column}]//span/i[contains(@class, 'mdi-close')]
        ${updated_parameter_value}=  Get Text  //p-table[@class='p-element ot-scroll-table']//tbody/tr[${table_row}]/td[${column}]

        IF  '${updated_parameter_value}' == '<Select value>'
            Log  ${parameter_name} for RMOD-${RMOD_id} ${antenna_port} succesfully deleted!  console=True
        ELSE
            Log  ${parameter_name} for RMOD-${RMOD_id} ${antenna_port} could not be deleted!  level=ERROR
            Fail  ${parameter_name} for RMOD-${RMOD_id} ${antenna_port} could not be deleted!
        END

    END

Configure RF sharing enabled parameter on true
    [Arguments]  ${alias}  ${vdu_alias}

    ${bts_alias}=  Set Variable  ${alias} ${vdu_alias}

    Log  *** Configure RF sharing enabled parameter on true on BTS ${bts_alias} ***  console=True

    ${table_rows}=  SeleniumLibrary.Get Element Count  (//table[@class='ng-star-inserted'])[1]//tbody/tr

    FOR  ${table_row}  IN RANGE  1  ${table_rows}+1

        ${parameter_name}=  Get Text  (//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[1]

        IF  '${parameter_name}' == 'Rf sharing enabled'
            Edit single-select parameter name and planned value table  table_num=1  table_row=${table_row}  parameter_name=Rf sharing enabled
            ...  parameter_value=true
            BREAK
        END

    END

Configure RF sharing settings for each shared RMOD
    [Arguments]  ${alias}  ${vdu_alias}  ${timeout}=30

    ${bts_alias}=  Set Variable  ${alias} ${vdu_alias}

    Log  *** Configure RF sharing settings for each shared RMOD on BTS ${bts_alias} ***  console=True

    FOR  ${RMOD_sn}  IN  @{${bts_alias}_BTS_primary_controller_RMOD_sn_list}

        IF  '${RMOD_sn}' in ${dedicated_RMOD_sn_list}  CONTINUE

        ${RMOD_id}=  Get From Dictionary  ${${bts_alias}_VDU_RMOD_sn_id_dict}  ${RMOD_sn}
        ${RMOD_pn}=  Get From Dictionary  ${${bts_alias}_VDU_RMOD_sn_pn_dict}  ${RMOD_sn}

        Log  Configure RF sharing settings for ${RMOD_pn}_${RMOD_sn} RMOD-${RMOD_id}/RMOD_R-${RMOD_id}  console=True

        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath=//div[@aria-label='${RMOD_pn} RMOD-${RMOD_id}/RMOD_R-${RMOD_id}']

        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath=//span[@class='mdi mdi-plus p-button-icon ng-star-inserted']

        Sleep  1s  reason=Waiting time to control execution speed

        ${table_rows}=  SeleniumLibrary.Get Element Count  (//table[@class='ng-star-inserted'])[2]//tbody/tr
        Configure RF Sharing settings  table_rows=${table_rows}  BTS_role=Primary  RMOD_sn=${RMOD_sn}

    END

    FOR  ${RMOD_sn}  IN  @{${bts_alias}_BTS_secondary_controller_RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${bts_alias}_VDU_RMOD_sn_id_dict}  ${RMOD_sn}
        ${RMOD_pn}=  Get From Dictionary  ${${bts_alias}_VDU_RMOD_sn_pn_dict}  ${RMOD_sn}

        Log  Configure RF sharing settings for ${RMOD_pn}_${RMOD_sn} RMOD-${RMOD_id}/RMOD_R-${RMOD_id}  console=True

        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath=//div[@aria-label='${RMOD_pn} RMOD-${RMOD_id}/RMOD_R-${RMOD_id}']

        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath=//span[@class='mdi mdi-plus p-button-icon ng-star-inserted']

        Sleep  1s  reason=Waiting time to control execution speed

        ${table_rows}=  SeleniumLibrary.Get Element Count  (//table[@class='ng-star-inserted'])[2]//tbody/tr
        Configure RF Sharing settings  table_rows=${table_rows}  BTS_role=Secondary  RMOD_sn=${RMOD_sn}

    END

Configure RF Sharing settings
    [Arguments]  ${table_rows}  ${BTS_role}  ${RMOD_sn}

    FOR  ${table_row}  IN RANGE  1  ${table_rows}+1

        ${parameter_name}=  Get Text  (//table[@class='ng-star-inserted'])[2]//tbody/tr[${table_row}]/td[1]

        IF  '${parameter_name}' == 'Controller role'
            Edit single-select parameter name and planned value table  table_num=2  table_row=${table_row}  parameter_name=Controller role
            ...  parameter_value=${BTS_role}
        ELSE IF  '${parameter_name}' == 'Module location'
            Set Module location  table_row=${table_row}  parameter_name=Module location  parameter_value=${${RMOD_sn}_moduleLocation_value}
        ELSE IF  '${parameter_name}' == 'RAT assigned to peer BTS'
            Edit single-select parameter name and planned value table  table_num=2  table_row=${table_row}  parameter_name=RAT assigned to peer BTS
            ...  parameter_value=sranSupport
        ELSE IF  '${parameter_name}' == 'Module sharing enable'
            Edit single-select parameter name and planned value table  table_num=2  table_row=${table_row}  parameter_name=Module sharing enable
            ...  parameter_value=true
        END

    END

Edit single-select parameter name and planned value table
    [Arguments]  ${table_num}  ${table_row}  ${parameter_name}  ${parameter_value}  ${timeout}=30

    Log  ${parameter_name} will be set to: ${parameter_value}   console=True

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=(//table[@class='ng-star-inserted'])[${table_num}]//tbody/tr[${table_row}]/td[2]
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//li[@aria-label='${parameter_value}']
    ${updated_parameter_value}=  Get Text  xpath=//span[contains(.,'${parameter_value}')]

    Check if parameter was set properly  parameter_name=${parameter_name}  parameter_value=${parameter_value}
    ...  updated_parameter_value=${updated_parameter_value}

    Sleep  1s  reason=Waiting time to control execution speed

Set Module location
    [Arguments]  ${table_row}  ${parameter_name}  ${parameter_value}  ${timeout}=30

    Log  ${parameter_name} will be set to: ${parameter_value}  console=True

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=(//table[@class='ng-star-inserted'])[2]//tbody/tr[${table_row}]/td[2]
    Input Text  xpath=(//table[@class='ng-star-inserted'])[2]//tbody/tr[${table_row}]/td[2]//input[@type='text']  ${parameter_value}
    ${updated_parameter_value}=  Get Value  xpath=(//table[@class='ng-star-inserted'])[2]//tbody/tr[${table_row}]/td[2]//input[@type='text']

    Check if parameter was set properly  parameter_name=${parameter_name}  parameter_value=${parameter_value}
    ...  updated_parameter_value=${updated_parameter_value}

    Sleep  1s  reason=Waiting time to control execution speed

Check if parameter was set properly
    [Arguments]  ${parameter_name}  ${parameter_value}  ${updated_parameter_value}

    ${status}=  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${parameter_value}  ${updated_parameter_value}
    IF  ${status}
        Log  ${parameter_name} succesfully set!  console=True
    ELSE
        Log  ${parameter_name} was not set properly! Expected/found value: ${parameter_value}/${updated_parameter_value}  level=ERROR
        Fail  ${parameter_name} was not set properly! Expected/found value:  ${parameter_value}/${updated_parameter_value}
    END

Delete parameter for BTS secondary controller shared RMODs
    [Arguments]  ${alias}  ${vdu_alias}  ${parameter_name}

    ${bts_alias}=  Set Variable  ${alias} ${vdu_alias}

    Log  *** Delete ${parameter_name} for BTS ${bts_alias} secondary controller shared RMODs ***  console=True

    Wait Until Keyword Succeeds  30  3
    ...  Click Element  xpath=//input[@placeholder='Search with enter']
    Input Text  xpath=//input[@placeholder='Search with enter']  ${parameter_name}
    Press Keys  xpath=//input[@placeholder='Search with enter']  RETURN

    ${table_columns}=  SeleniumLibrary.Get Element Count  //thead[@class='p-treetable-thead']//tr[1]/th

    FOR  ${column}  IN RANGE  1  ${table_columns}+1

        ${column_value}=  Get Text  //thead[@class='p-treetable-thead']//tr[1]/th[${column}]

        IF  '${column_value}' == 'Parameter name'
            Set Test Variable  ${param_object_column}  ${column}
        ELSE IF  '${column_value}' == 'Abbreviation'
            Set Test Variable  ${param_abbreviation_column}  ${column}
        ELSE IF  '${column_value}' == 'Actions'
            Set Test Variable  ${param_action_column}  ${column}
        END

    END

    Zoom Out Page  zoom_level=10  # used when running without headless option
    ${table_rows}=  SeleniumLibrary.Get Element Count  //tbody[@class='p-element p-treetable-tbody']/tr
    Zoom Out Page  zoom_level=100  # used when running without headless option

    FOR  ${RMOD_sn}  IN  @{${bts_alias}_BTS_secondary_controller_RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${bts_alias}_VDU_RMOD_sn_id_dict}  ${RMOD_sn}

        Delete parameter for BTS secondary controller shared RMOD  parameter_name=${parameter_name}  RMOD_id=${RMOD_id}  RMOD_sn=${RMOD_sn}
        ...  table_rows=${table_rows}

    END

    VDU WebEM Perform Save Parameter Editor Changes  ${alias}  ${vdu_alias}

Delete parameter for BTS secondary controller shared RMOD
    [Arguments]  ${parameter_name}  ${RMOD_id}  ${RMOD_sn}  ${table_rows}  ${timeout}=30

    FOR  ${table_row}  IN RANGE   1  ${table_rows}+1

        Wait Until Keyword Succeeds  30  3
        ...  Click Element  xpath=//tbody[@class='p-element p-treetable-tbody']/tr[${table_row}]
        ${param_object_value}=  Get Text  //tbody[@class='p-element p-treetable-tbody']/tr[${table_row}]/td[${param_object_column}]
        ${param_abbreviation_value}=  Get Text  //tbody[@class='p-element p-treetable-tbody']/tr[${table_row}]/td[${param_abbreviation_column}]
        ${param_object_label}=  Fetch From Right  ${param_object_value}  \n
        ${param_object_id}=  Fetch From Right  ${param_object_label}  /

        ${object_status}=  Run Keyword And Return Status  Should Be Equal As Strings  ${param_object_id}  RMOD-${RMOD_id}
        ${abbreviation_status}=  Run Keyword And Return Status  Should Be Equal As Strings  ${param_abbreviation_value}  ${parameter_name}

        ${table_row_data}=  Set Variable  //tbody[@class='p-element p-treetable-tbody']/tr[${table_row}]/td[${param_action_column}]
        ${delete_button}=  Set Variable  ${table_row_data}//span[@class='mdi mdi-delete p-button-icon ng-star-inserted']
        ${restore_button}=  Set Variable  ${table_row_data}//span[@class='mdi mdi-restore p-button-icon ng-star-inserted']

        IF  ${object_status} and ${abbreviation_status}
            Log  Deleting ${parameter_name} parameter for RMOD_${RMOD_sn} by pressing the "delete" button ***  console=True
            Wait Until Keyword Succeeds  ${timeout}  3  Click Element  xpath=${delete_button}
            Log  ${parameter_name} parameter for RMOD_${RMOD_sn} succesfully deleted!  console=True
            BREAK
        END

    END

Zoom Out Page
    [Documentation]  Zoom out the page to see the entire content. Used when running without headless option.
    [Arguments]  ${zoom_level}

    Execute JavaScript  document.body.style.zoom = '${zoom_level}%'
    Sleep  1s  reason=Waiting time to control execution speed

Set actTempRadioMaster on true on BTS secondary controller
    [Arguments]  ${alias}  ${vdu_alias}

    ${bts_alias}=  Set Variable  ${alias} ${vdu_alias}

    Log  *** Set actTempRadioMaster on true on BTS ${bts_alias} secondary controller ***  console=True

    Wait Until Keyword Succeeds  30  3
    ...  Click Element  xpath=//input[@placeholder='Search with enter']
    Input Text  xpath=//input[@placeholder='Search with enter']  actTempRadioMaster
    Press Keys  xpath=//input[@placeholder='Search with enter']  RETURN

    ${table_columns}=  SeleniumLibrary.Get Element Count  //thead[@class='p-treetable-thead']//tr[1]/th

    FOR  ${column}  IN RANGE  1  ${table_columns}+1

        ${column_value}=  Get Text  //thead[@class='p-treetable-thead']//tr[1]/th[${column}]

        IF  '${column_value}' == 'Abbreviation'
            Set actTempRadioMaster on true  ${column}
        END

    END

    VDU WebEM Perform Save Parameter Editor Changes  ${alias}  ${vdu_alias}

Set actTempRadioMaster on true
    [Arguments]  ${parameter_column}  ${timeout}=30

    ${planned_value_column}=  Evaluate  ${parameter_column} + 1
    ${table_rows}=  SeleniumLibrary.Get Element Count  //tbody[@class='p-element p-treetable-tbody']/tr

    FOR  ${table_row}  IN RANGE   1  ${table_rows}+1

        Wait Until Keyword Succeeds  30  3
        ...  Click Element  xpath=//tbody[@class='p-element p-treetable-tbody']/tr[${table_row}]
        ${param_abbreviation_value}=  Get Text  //tbody[@class='p-element p-treetable-tbody']/tr[${table_row}]/td[${parameter_column}]
        ${abbreviation_status}=  Should Be Equal As Strings  ${param_abbreviation_value}  actTempRadioMaster

        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath=//tbody[@class='p-element p-treetable-tbody']/tr[${table_row}]/td[${planned_value_column}]
        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath=//li[@aria-label='true']
        ${updated_parameter_value}=  Get Text  xpath=//span[contains(.,'true')]

        Check if parameter was set properly  parameter_name=actTempRadioMaster  parameter_value=true
        ...  updated_parameter_value=${updated_parameter_value}

        Sleep  1s  reason=Waiting time to control execution speed

    END

Set actSharedRUIndControl on true on shared RMODs
    [Arguments]  ${alias}  ${vdu_alias}

    ${bts_alias}=  Set Variable  ${alias} ${vdu_alias}
    ${BTS_alias_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${bts_alias}

    Log  *** Set actSharedRUIndControl on true on BTS ${bts_alias} shared RMODs ***  console=True

    Wait Until Keyword Succeeds  30  3
    ...  Click Element  xpath=//input[@placeholder='Search with enter']
    Input Text  xpath=//input[@placeholder='Search with enter']  actSharedRUIndControl
    Press Keys  xpath=//input[@placeholder='Search with enter']  RETURN

    ${table_columns}=  SeleniumLibrary.Get Element Count  //thead[@class='p-treetable-thead']//tr[1]/th

    FOR  ${column}  IN RANGE  1  ${table_columns}+1

        ${column_value}=  Get Text  //thead[@class='p-treetable-thead']//tr[1]/th[${column}]

        IF  '${column_value}' == 'Parameter name'
            Set Test Variable  ${param_object_column}  ${column}
        ELSE IF  '${column_value}' == 'Abbreviation'
            Set Test Variable  ${param_abbreviation_column}  ${column}
        ELSE IF  '${column_value}' == 'Planned value'
            Set Test Variable  ${param_planned_value_column}  ${column}
        END

    END

    Zoom Out Page  zoom_level=10  # used when running without headless option
    ${table_rows}=  SeleniumLibrary.Get Element Count  //tbody[@class='p-element p-treetable-tbody']/tr
    Zoom Out Page  zoom_level=100  # used when running without headless option

    FOR  ${RMOD_sn}  IN  @{CB007878_shared_RMOD_sn_list}

        IF  '${RMOD_sn}' not in ${BTS_alias_RMOD_sn_list}  CONTINUE

        ${RMOD_id}=  Get From Dictionary  ${${bts_alias}_VDU_RMOD_sn_id_dict}  ${RMOD_sn}

        Set actSharedRUIndControl on true on shared RMOD  RMOD_id=${RMOD_id}  RMOD_sn=${RMOD_sn}  table_rows=${table_rows}

    END

    VDU WebEM Perform Save Parameter Editor Changes  ${alias}  ${vdu_alias}

Set actSharedRUIndControl on true on shared RMOD
    [Arguments]  ${RMOD_id}  ${RMOD_sn}  ${table_rows}  ${timeout}=30

    FOR  ${table_row}  IN RANGE   1  ${table_rows}+1

        Wait Until Keyword Succeeds  30  3
        ...  Click Element  xpath=//tbody[@class='p-element p-treetable-tbody']/tr[${table_row}]
        ${param_object_value}=  Get Text  //tbody[@class='p-element p-treetable-tbody']/tr[${table_row}]/td[${param_object_column}]
        ${param_abbreviation_value}=  Get Text  //tbody[@class='p-element p-treetable-tbody']/tr[${table_row}]/td[${param_abbreviation_column}]
        ${param_object_label}=  Fetch From Right  ${param_object_value}  \n
        ${param_object_id}=  Fetch From Right  ${param_object_label}  /

        ${object_status}=  Run Keyword And Return Status  Should Be Equal As Strings  ${param_object_id}  RMOD-${RMOD_id}
        ${abbreviation_status}=  Run Keyword And Return Status  Should Be Equal As Strings  ${param_abbreviation_value}  actSharedRUIndControl

        IF  '${object_status}' == 'False' or '${abbreviation_status}' == 'False'  CONTINUE

        Log  Set actSharedRUIndControl on true on shared RMOD_${RMOD_sn}  console=True

        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath=//tbody[@class='p-element p-treetable-tbody']/tr[${table_row}]/td[${param_planned_value_column}]
        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath=//li[@aria-label='true']
        ${updated_parameter_value}=  Get Text  xpath=//span[contains(.,'true')]

        Check if parameter was set properly  parameter_name=actSharedRUIndControl  parameter_value=true
        ...  updated_parameter_value=${updated_parameter_value}

        Sleep  1s  reason=Waiting time to control execution speed

        BREAK

    END

Check shared RMOD parameters on Site View page
    [Arguments]  ${alias}  ${vdu_alias}  ${timeout}=30

    ${bts_alias}=  Set Variable  ${alias} ${vdu_alias}

    VDU WebEM Setup  alias=${alias}  vdu_alias=${vdu_alias}

    VDU WebEM Open Site View Menu  alias=${alias}  vdu_alias=${vdu_alias}

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//span[@class='p-button-icon p-button-icon-left mdi mdi-format-list-bulleted']

    FOR  ${RMOD_sn}  IN  @{${bts_alias}_all_BTS_RMOD_sn_list}

        IF  '${RMOD_sn}' in ${dedicated_RMOD_sn_list}  CONTINUE

        ${RMOD_id}=  Get From Dictionary  ${${bts_alias}_VDU_RMOD_sn_id_dict}  ${RMOD_sn}

        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath=//div[@class='rmod-id']//span[contains(text(),'RMOD-${RMOD_id}')]

        Log  *** Check Radio Module Proprieties parameters for shared RMOD_${RMOD_sn} are not empty ***  console=True

        Check Radio module proprieties  param_name=RMOD ID
        Check Radio module proprieties  param_name=RMOD_R ID
        Check Radio module proprieties  param_name=Product name
        Check Radio module proprieties  param_name=Product code
        Check Radio module proprieties  param_name=Serial number
        Check Radio module proprieties  param_name=Hardware version
        Check Radio module proprieties  param_name=Hardware release
        Check Radio module proprieties  param_name=Software version
        Check Radio module proprieties  param_name=Software build
        Check Radio module proprieties  param_name=Module location
        Check Radio module proprieties  param_name=Is Massive MIMO
        Check Radio module proprieties  param_name=Technology type
        Check Radio module proprieties  param_name=Interface type
        Check Radio module proprieties  param_name=Is shared radio
        Check Radio module proprieties  param_name=Module location of peer BTS

        Log  *** Check Radio module states for shared RMOD_${RMOD_sn} are as expected ***  console=True

        Check Radio module states  param_name=Operational state  param_value=Enabled
        Check Radio module states  param_name=Availability status  param_value=On line
        Check Radio module states  param_name=Administrative state  param_value=Unlocked
        Check Radio module states  param_name=Procedural status  param_value=Configured
        Check Radio module states  param_name=Power state  param_value=AWAKE

        Sleep  1s  reason=Waiting time to control execution speed

    END

    [Teardown]  VDU WebEM Teardown  alias=${alias}  vdu_alias=${vdu_alias}

Check Radio module proprieties
    [Arguments]  ${param_name}

    ${value}=  Get Text  //div[@class="section-row-key" and @title="${param_name}"]/following-sibling::div[@class="section-row-value"]

    Should Not Be Empty  ${value}
    Should Not Be Equal As Strings  ${value}  -
    Log  ${param_name} value: ${value}  console=True

Check Radio module states
    [Arguments]  ${param_name}  ${param_value}

    ${value}=  Get Text  //div[@class="section-row-key" and @title="${param_name}"]/following-sibling::div[@class="section-row-value"]

    Should Be Equal As Strings  ${param_value}  ${value}
    Log  ${param_name} value: ${value}, as expected!  console=True

Restore cloud BTS initial SCF

    FOR  ${bts_alias}  IN  @{BTS_all_alias_list}

        ${is_vdu_alias}=  Run Keyword And Return Status  Should Contain  ${bts_alias}  VDU
        IF  not ${is_vdu_alias}  CONTINUE

        Log  Restore BTS ${bts_alias} initial SCF configuration  console=True

        VDU Perform Commissioning  scf_file=${${bts_alias.lower()}_scf_initial}  vdu_connection=${bts_alias}

        Wait For Target To Be Not Reachable TAF  hostname=${${bts_alias.lower()}_vdu_host}  timeout=300

        Sleep  20s  reason=Waiting time after commissioning action

        Wait For Target To Be Reachable TAF  hostname=${${bts_alias.lower()}_vdu_host}  timeout=300

    END

Recover classical BTS power unit status

    FOR  ${alias}  IN  @{alias_list}

        IF  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'  CONTINUE

        Recover BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  on  ${alias}

    END

Particular Teardown

    IF  '${VDU_RF_SHARING_CONFIG}' == 'False'
        Restore cloud BTS initial SCF
    END
    Recover classical BTS power unit status

TC Setup
    ${tech_preset_list}=  Create List  CBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown
