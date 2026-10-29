*** Settings ***
Documentation    TC__SBTS_SBTS__CM__Planned_Recommissioning_CB008502
Variables    tc_variables/sbts_sbts__cm__planned_recommmissioning_CB008502_alarms_definitions.py
Resource     ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${RECOMMISSIONING_BTS1}   NONE   # Absolute SCF file path with commissioning for BTS1 (i.e. /home/ute/btsauto/SCF_01_SBTS19.xml).
                                 # If NONE, current SCF will be used
${RECOMMISSIONING_BTS2}   NONE   # Absolute SCF file path with commissioning for BTS2 (i.e. /home/ute/btsauto/SCF_01_SBTS19.xml).
                                 # If NONE, current SCF will be used
${REPEAT_COUNTER}         3      # Number of BTS Recommissioning operations, default value: 3
${BTS_SCF_VALIDATION}     True   # Validate BTS SCF; can be True or False
${BTS_MAX_WAIT_TIME}      900    # Maximum Wait time for BTS to be OnAir after recommissioning
${RESET_CONFIGURATION}    False  # Flag to Reset BTS configuration before recommissioning, can be True or False, default False

*** Keywords ***
TC__SBTS_SBTS__CM__Planned_Recommissioning_CB008502
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26462
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for Planned_Recommissioning_template, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get ECPRI RMODs initial radioProtocolType and linkSpeed values for each CABLINK
    ...  - BTS Reset configuration
    ...  - Planned BTS recommissioning with SCF file
    ...  - check ECPRI RMODs radioProtocolType and linkSpeed values for each CABLINK after recommissioning
    ...  - check reset behavior on BTS based on IMS info as follows:
    ...    - BTS site: reset number is 1
    ...    - Peer BTS site: reset number is 0
    ...  - check final state and alarms for both BTS
    ...  Pass criteria: Planned Recommissioning operation works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 30.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26462 - [5G][CB008502]
    ...  SBTS_SBTS__CM__BTS1_BTS2_Planned_Recommissioning_with_configure_reset_for_CB008502
    ...  - 21.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26946 - [5G][CB008502] Provide small NR_NR robot for
    ...  SBTS_SBTS__CM__BTS1_BTS2_Planned_Recommissioning_with_configure_reset_for_CB008502
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-26462_SBTS_SBTS__CM__Planned_Recommissioning_CB008502.png

    Set Tags    CA-STATE    OWNER-constantin.diaconu@nokia.com    AUTHOR-andreea.szentannai@nokia.com    PHASE-QT    SW-SBTS24R2

    TC Parameters check
    Step 1: Check initial state on both BTS
    Step 2: Check initial alarms on both BTS
    Step 3: Get RMOD info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Perform Recommissioning on all BTS
    END

    [Teardown]  Particular Teardown

TC Parameters check
    [Documentation]
    ...  Detect needed BTS SCF
    ...  If SCF is not specified in RECOMMISSIONING_BTS, will download the current SCF and use it

    FOR  ${alias}  IN  @{alias_list}
        ${BTS_label}=  Set Variable If  '${alias}' == 'Master'  BTS1  BTS2
        ${scf_path_tmp}=  Run Keyword If  '${RECOMMISSIONING_${BTS_label}}' == 'NONE'
        ...  Admin Collect scf.xml with timestamp TAF  alias=${alias}  folder_path=${BTSFiles}/${alias}  export_type=configurationAndRuntimeObjects
        ...  ELSE  Set Variable  ${RECOMMISSIONING_${BTS_label}}

        OperatingSystem.File Should Exist  ${scf_path_tmp}
        ${bts_info_tmp}=  Admin Get BTS state info  alias=${alias}
        Set Test Variable  ${${BTS_label}_commissioning_scf_path}  ${scf_path_tmp}
        Set Test Variable  ${${BTS_label}_info}  ${bts_info_tmp}
    END

Step ${index}: Check ${when} state on both BTS
    [Documentation]
    ...  BTS state is checked according to Admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} state on both BTS  console=True
    FOR  ${alias}  IN  @{alias_list}
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} alarms on both BTS
    [Documentation]
    ...  BTS alarms are compared with values from expected, ignored and critical alarms lists. BTS alarms are get
    ...  from Admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} alarms on both BTS  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get RMOD info
    [Documentation]
    ...  RMODs are checked for parameters radioProtocolType and linkSpeed on each CABLINK

    Log  Step ${index}: Get RMOD info  console=True
    FOR  ${alias}  IN  @{alias_list}
        ${BTS_label}=  Set Variable If  '${alias}' == 'Master'  BTS1  BTS2
        ${BTS_scf_initial}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}  export_type=configurationAndRuntimeObjects
        ${ECPRI_RMOD_param_initial_dict}=  Get RMOD CABLINK radioProtocolType and linkSpeed  ${alias}  scf_path=${BTS_scf_initial}
        ${ECPRI_RMOD_impacted}=  Get Dictionary Keys  ${ECPRI_RMOD_param_initial_dict}

        Set Test Variable  ${${alias}_ECPRI_RMOD_param_initial}  ${ECPRI_RMOD_param_initial_dict}
        Set Test Variable  ${${alias}_ECPRI_RMOD_impacted}  ${ECPRI_RMOD_impacted}
        Set Test Variable  ${${alias}_BTS_scf_initial}  ${BTS_scf_initial}

        Run Keyword If  ${${alias}_ECPRI_RMOD_impacted}
        ...  Log  ECPRI RMODs found: ${${alias}_ECPRI_RMOD_impacted} on ${BTS_label}  console=True
        ...  ELSE  Run Keywords
        ...  Log  No ECPRI RMODs were found on ${BTS_label}  console=True
        ...  AND  Fail  No ECPRI RMODs with radioProtocolType = eCPRI were found on ${BTS_label}
    END

Perform Recommissioning on all BTS

     ${scf_recommissioning_dict}=  Create Dictionary
     Set Test Variable  ${scf_recommissioning_dict}

     FOR  ${alias}  IN  @{alias_list}
         ${BTS_label}=  Set Variable If  '${alias}' == 'Master'  BTS1  BTS2
         Set Test Variable  ${alias}
         Set Test Variable  ${BTS_label}
         Step 4: Validate SCF before Recommissioning
         Run Keyword If  '${RESET_CONFIGURATION}' == 'True'  Run Keywords
         ...  Step 5: BTS Reset Configuration
         ...  ELSE  Log  Step 5: BTS Reset Configuration will be skipped for ${BTS_label}  console=True
         Get Current Date UTC info  start
         Step 6: Planned BTS Recommissioning
         Step 7: Check final state on both BTS
         Step 8: Check final alarms on both BTS
         Step 9: Check final number and state of Cells and RMs
         Step 10: Check BTS reset behavior based on IMS info
     END

Step ${index}: Validate SCF before Recommissioning
    Log  Step ${index}: Validate SCF before Recommissioning  console=True
    Run Keyword If  ${BTS_SCF_VALIDATION}  Run Keywords
    ...  Log  Validate SCF:${${BTS_label}_commissioning_scf_path} before ${BTS_label} Recommissioning  console=True
    ...  AND  Admin Validate SCF TAF  scf_path_file=${${BTS_label}_commissioning_scf_path}  alias=${alias}
    ...  AND  Admin Validate SCF With Detected Hardware  scf_path_file=${${BTS_label}_commissioning_scf_path}  alias=${alias}
    ...  ELSE  Log  SCF Validation was skipped due to BTS_SCF_VALIDATION flag set to False  console=True

Step ${index}: BTS Reset Configuration
    [Documentation]
    ...  BTS Reset Configuration

    Log  Step ${index}: BTS Reset Configuration on ${BTS_label}  console=True

    ${BTS_TECH_IP_address}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]

    Reset BTS Configuration TAF  connection=${alias}  wait_for_admin_connection=False  remove_operator_certificates=False
    ...  remove_user_account_credentials=True  repair_center_reset=True

    Wait For Target To Be Reachable TAF  hostname=${BTS_TECH_IP_address}  timeout=250  remote_host=${remote_host_ip}

    Log  BTS SM (${BTS_TECH_IP_address} from localhost) has been reachable within 250 seconds  console=True
    Wait Until Keyword Succeeds  10 min  1 min  Uncommission module status BTS SOAM
    Log  ${BTS_label} Reset Configuration completed!  console=True

Step ${index}: Planned BTS Recommissioning
    [Documentation]
    ...  Planned BTS recommissioning with SCF file is triggered. The new SCF file is loaded on BTS SM and a reboot should be triggered after.

    Log  Step ${index}: Planned BTS Recommissioning on ${BTS_label}  console=True
    Log  Commissioning via ADMIN will be performed using ${${BTS_label}_commissioning_scf_path}  console=True

    Get Current Time  bts_initial
    coam.Perform Commissioning  bts_id=${${BTS_label}_info[0]}  scf_file=${${BTS_label}_commissioning_scf_path}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=${BTS_MAX_WAIT_TIME}  connection=${alias}
    Log  ${BTS_label} commissioning has been performed  console=True

    Run Keyword If  ${BTS_SCF_VALIDATION}  Run Keywords
    ...  Log  Validate BTS SCF after Recommissioning  console=True
    ...  AND  Admin Validate SCF TAF  alias=${alias}
    ...  AND  Admin Validate SCF With Detected Hardware  alias=${alias}

    Check SW configuration did not change

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_initial}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS RAT Procedural State  alias=${alias}  timeout=${remained_MAX_WAIT_TIME}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_initial}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${alias}

    Check radioProtocolType and linkSpeed values after recommissioning

Check radioProtocolType and linkSpeed values after recommissioning
    [Documentation]
    ...  RadioProtocolType and linkSpeed values are checked after recommissioning

    ${RMOD_param_scf_values}=  Get RMOD CABLINK radioProtocolType and linkSpeed  ${alias}  scf_path=${${BTS_label}_commissioning_scf_path}
    ${RMOD_param_current_values}=  Get RMOD CABLINK radioProtocolType and linkSpeed  ${alias}

    ${parameters_check}=  Run Keyword And Return Status  Dictionaries Should Be Equal  ${RMOD_param_scf_values}  ${RMOD_param_current_values}

    Run Keyword If  ${parameters_check}
        ...  Log Long String  Recommissioning operation successfully performed with requested values for radioProtocolType and
        ...  linkSpeed on ${BTS_label}  console=True
        ...  ELSE  Run Keywords
        ...  Log  Recommissioning operation failed on ${BTS_label}  level=ERROR
        ...  AND  Fail  Recommissioning operation failed

Step ${index}: Check BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - BTS site: reset number is 1
    ...  - PEER BTS site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Get Current Date UTC info  end
    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master

    Log  Step ${index}: Check both BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${alias}  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${peer_alias}  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    Set To Dictionary  ${scf_recommissioning_dict}  ${alias}  ${${BTS_label}_commissioning_scf_path}
    RFS Test Case Final Checks  entity_scf_dict=${scf_recommissioning_dict}

Check SW configuration did not change
    [Documentation]
    ...  Extract BTS active and passive SWs using Admin and compare to initial values. Fail if something changed

    ${current_active_SW}  ${current_passive_SW}=  Wait Until Keyword Succeeds  5m  20s  Admin Get BTS SW Version  ${alias}
    ${initial_SW_list}=  Create List  ${${alias} active SW}  ${${alias} passive SW}
    ${current_SW_list}=  Create List  ${current_active_SW}  ${current_passive_SW}
    ${no_sw_change}=  Run Keyword And Return Status  Should Be Equal  ${initial_SW_list}  ${current_SW_list}
    Run Keyword If  not ${no_sw_change}  Run Keywords
    ...  Log  SW configuration changed! ${BTS_label} SW active/passive: ${current_active_SW}/${current_passive_SW}  console=True
    ...  AND  Fail  SW configuration changed!

Uncommission module status BTS SOAM
    [Documentation]
    ...  Checks procedural state of BTS SOAM

    ${BTS state}=  coam.Get Mrbts State  timeout=600  alias=${alias}
    Log  ${BTS_label} proceduralState is: ${BTS state}  console=True
    Should Contain  ${NotCommissioned_}  ${BTS state}

Get RMOD CABLINK radioProtocolType and linkSpeed
    [Documentation]
    ...  Extract radioProtocolType and linkSpeed CABLINK values for RMODs either from Scf or from Admin
    [Arguments]  ${alias}  ${scf_path}=${EMPTY}

    ${RMOD_id_list}=  Get Ids For All  RMOD  connection=${alias}
    Sort List  ${RMOD_id_list}
    ${ECPRI_RMODs_param_dict}=  Create Dictionary

    FOR  ${RMOD_id}  IN  @{RMOD_id_list}
        ${RMOD_CABLINK_dict}=  Get CABLINK parameters  ${RMOD_id}  ${alias}  ${scf_path}
        Run Keyword If  ${RMOD_CABLINK_dict}
        ...  Set To Dictionary  ${ECPRI_RMODs_param_dict}  ${RMOD_id}  ${RMOD_CABLINK_dict}
    END

    [Return]  ${ECPRI_RMODs_param_dict}

Get CABLINK parameters
    [Arguments]  ${RMOD_id}  ${alias}  ${scf_path}

    ${CABLINK_R_info}=  coam.Get Managed Objects  class_name=CABLINK_R  connection=${alias}
    ${RMOD_CABLINK_dict}=  Create Dictionary
    FOR  ${item}  IN  @{CABLINK_R_info}
        ${CABLINK_param}=  Get From Dictionary  ${item}  parameters
        ${CABLINK_dn}=  Get CABLINK SCF distinguished name  ${item['distName']}  ${alias}
        ${CABLINK_check}=  Set Variable If  '${CABLINK_param['secondEndpointDN']}' == '${RMOD_id}' and '${CABLINK_dn}' != 'None'  ${TRUE}  ${FALSE}
        Continue For Loop If  not ${CABLINK_check}

        ${radioProtocolType}  ${linkSpeed}=  Run Keyword if  '${scf_path}' == '${EMPTY}'
        ...  Get radioProtocolType and linkSpeed parameters from Admin  ${CABLINK_param}  ${alias}
        ...  ELSE  Get radioProtocolType and linkSpeed parameters from SCF  ${CABLINK_dn}  ${scf_path}

        ${check_radioProtocolType}=  Set Variable If  '${radioProtocolType}' in ['eCPRI', '10eCpri', '25eCpri', '50eCpri']
        ...  ${TRUE}  ${FALSE}
        Continue For Loop If  not ${check_radioProtocolType}

        ${parameter_dict}=   Create Dictionary
        ...  radioProtocolType=${radioProtocolType}
        ...  linkSpeed=${linkSpeed}

        Set To Dictionary  ${RMOD_CABLINK_dict}  ${CABLINK_dn}  ${parameter_dict}
    END

    [Return]  ${RMOD_CABLINK_dict}

Get radioProtocolType and linkSpeed parameters from SCF
    [Arguments]  ${CABLINK_dn}  ${scf_path}

    ${linkSpeed}=  Check Parameter value from SCF  item_dist_name=${CABLINK_dn}  parameter_to_check=linkSpeed
    ...  scf_path=${scf_path}
    ${radioProtocolType}=  Check Parameter value from SCF  item_dist_name=${CABLINK_dn}
    ...  parameter_to_check=radioProtocolType  scf_path=${scf_path}

    [Return]  ${radioProtocolType}  ${link_speed}

Get radioProtocolType and linkSpeed parameters from Admin
    [Arguments]  ${CABLINK_param}  ${alias}

    ${radioProtocolType}=  Get Admin Parameter  dist_name=${CABLINK_param['configDN']}  parameter=radioProtocolType  alias=${alias}

    [Return]  ${radioProtocolType}  ${CABLINK_param['linkSpeed']}

Recover initial radioProtocolType and linkSpeed values
    [Documentation]
    ...  Recover radioProtocolType and linkSpeed values

    [Arguments]  ${alias}
    ${BTS_label}=  Set Variable If  '${alias}' == 'Master'  BTS1  BTS2
    ${ECPRI_RMOD_param_final_values}=  Get RMOD CABLINK radioProtocolType and linkSpeed  ${alias}

    Log  Recover radioProtocolType and linkSpeed values on ${BTS_label}  console=True
    ${parameters_check}=  Run Keyword And Return Status  Dictionaries Should Be Equal
    ...  ${${alias}_ECPRI_RMOD_param_initial}  ${ECPRI_RMOD_param_final_values}

    Run Keyword If  ${parameters_check}
    ...  Log  Final radioProtocolType and linkSpeed values corespond to the initial values for all RMODs on ${BTS_label}, no recover action needed
    ...  console=True
    ...  ELSE  Run Keywords
    ...  coam.Perform Commissioning  bts_id=${${BTS_label}_info[0]}  scf_file=${${alias}_BTS_scf_initial}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=400  connection=${alias}
    ...  AND  Log  ${BTS_label} commissioning has been performed to recover initial radioProtocolType and linkSpeed values  console=True

Particular Teardown
    FOR  ${alias}  IN  @{alias_list}
        Recover initial radioProtocolType and linkSpeed values  ${alias}
        Check all BTS cells availability status online
    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown