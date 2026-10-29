*** Settings ***
Library  ../../resources/python_resources/rmod_ssh.py  WITH NAME  rmod_ssh
Documentation    TC__SBTS_SBTS__STATE__Access_to_BTS_via_Shared_RMOD_CB013910
Variables    tc_variables/sbts_sbts__state__access_to_bts_via_shared_rmod_cb013910_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}      3    # Number of BTS Access to RMOD operations( BTSx-RMOD-BTSy sequencies), default value 3
${BTS_LIST}            ALL  # BTS list on which BTS Access to RMOD operations will be performed. Possible values (by default ALL):
                            # - ALL: action will be performed on all BTS (reset each BTS until last BTS from TL)
                            # - list of selected BTS separated by comma labelized as BTSx (x is test_pc number in init.py) (ex. BTS1, BTS2)
${RM_SERIAL_NUMBER_LIST}   ALL   # RM serial number list on which reset operation will be performed.
                                 # Possible values: ALL (operation will be performed on all shared and dedicated RMs) or list of selected
                                 # shared or dedicated RM serial number separated by comma. By default ALL
${BTS1_EIF_down}                 # EIF user for down command(script) for BTS1. Parameter is Mandatory for test execution.
${BTS1_EIF_pass_down}            # EIF password for down command(script) for BTS1. Parameter is Mandatory for test execution.
${BTS1_EIF_up}                   # EIF user for up command(script) for BTS1. Parameter is Mandatory for test execution.
${BTS1_EIF_pass_up}              # EIF password for up command(script) for BTS1. Parameter is Mandatory for test execution.
${BTS1_EIF_Switch_IpAddress}     # EIF switch IP address for BTS1. Parameter is Mandatory for test execution.
${BTS2_EIF_down}                 # EIF user for down command(script) for BTS2. Parameter is Mandatory for test execution.
${BTS2_EIF_pass_down}            # EIF password for down command(script) for BTS2. Parameter is Mandatory for test execution.
${BTS2_EIF_up}                   # EIF user for up command(script) for BTS2. Parameter is Mandatory for test execution.
${BTS2_EIF_pass_up}              # EIF password for up command(script) for BTS2. Parameter is Mandatory for test execution.
${BTS2_EIF_Switch_IpAddress}     # EIF switch IP address for BTS2. Parameter is Mandatory for test execution.
${ERROR_CASE_BTS_LIST}           # List of BTS labels for which connection from BTS to RMOD and peer BTS is expected to fail.
                                 # MANDATORY for SW Releases where CB013910 is not implemented (actFronthaulSshAccess will be set to False).
                                 # Possible values: list of BTS labels separated by comma (ex. BTS1,BTS2) or empty
                                 # if no connection failure is expected. Default value is empty.

*** Keywords ***
TC__SBTS_SBTS__STATE__Access_to_BTS_via_Shared_RMOD_CB013910
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30097
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for BTS access via Shared RMOD, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info
    ...  - check and set CB013910 feature
    ...  - Perform EIF down operation on all BTS
    ...  - perform BTS BTSx-RM-BTSy connect opaerations for each CPRI or eCPRI shared RM
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: Connections from BTSx to RMOD to BTSy are successful for each shared RMOD and
    ...  state and alarms for all BTS are as expected.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 23.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30097 - [CB013910] -
    ...  SBTS_SBTS__STATE__Access_to_BTS_via_Shared_RU_Fronthaul_Network - CB013910  - start 2526->2603
    ...  - 06.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30547 - SBTS_SBTS__STATE__Access_to_BTS_via_Shared_RMOD_CB013910
    ...  crashing when trying to connect to AHFIB (BL2135V0JUA)
    ...  - 17.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30643 - Update test sbts_sbts__state__access_to_bts_via_shared_rmod_cb013910
    ...  for error case DoD_<endfb2607>_
    ...

    Set Tags    CA-STATE    OWNER-adrian.beta@nokia.com   AUTHOR-adelina.branc@nokia.com    PHASE-QT    SW-SBTS26R2

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS shared RMOD lists connected in primary and secondary core
    Step 4: Check and set CB013910 feature
    FOR  ${CYCLE}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${CYCLE} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Perform EIF down operation on all BTS
        Step 6: Perform BTS-RM-BTS connection for iteration ${CYCLE}
        Step 7: Perform EIF up operation on all BTS

        Step 8: Check final all BTS state
        Step 9: Check final all BTS alarms
        Step 10: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    ${BTS_error_case_alias_list}=  Create List
    ${BTS_error_case_label_list}=  Create List
    Set Test Variable  ${BTS_error_case_alias_list}
    Set Test Variable  ${BTS_error_case_label_list}

    Run Keyword If  '${BTS_LIST}' != 'ALL'  Check BTS list
    Log  ====================================================  console=True
    Log  BTS label list selected for operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for operation: ${BTS_alias_list}  console=True
    Log  ====================================================  console=True

    Run Keyword If  '${ERROR_CASE_BTS_LIST}' != ''  Check BTS Error Case list
    Log  ====================================================  console=True
    Log  BTS label list selected for error case operation: ${BTS_error_case_label_list}  console=True
    Log  BTS alias list selected for error case operation: ${BTS_error_case_alias_list}  console=True
    Log  ====================================================  console=True

    ${BTS_alias_RM_sn_dict}  ${RM_sn_BTS_alias_dict}  ${shared_RM_sn_list}  ${dedicated_RM_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RM_sn_dict}
    Set Test Variable  ${RM_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RM_sn_list}
    Set Test Variable  ${dedicated_RM_sn_list}

    Run Keyword If  '${RM_SERIAL_NUMBER_LIST}' != 'ALL'  Check RM serial number list

    Log  =====================================================================  console=True
    Log  RM serial number list selected for action: ${shared_RM_sn_list}  console=True

    ${EIF_params}=  Create List
    ...  ${BTS1_EIF_down}  ${BTS1_EIF_pass_down}  ${BTS1_EIF_up}  ${BTS1_EIF_pass_up}  ${BTS1_EIF_Switch_IpAddress}
    ...  ${BTS2_EIF_down}  ${BTS2_EIF_pass_down}  ${BTS2_EIF_up}  ${BTS2_EIF_pass_up}  ${BTS2_EIF_Switch_IpAddress}

    FOR  ${param}  IN  @{EIF_params}
        Run Keyword If  '${param}' == '${EMPTY}'
        ...  Fail  Please configure all EIF parameters for each BTS in order to perform EIF operations!  level=ERROR
    END

Check BTS list
    ${BTS_LIST_strip}=  Replace String  ${BTS_LIST}  ${SPACE}  ${EMPTY}
    ${BTS_LIST}=  Split String  ${BTS_LIST_strip}  ,
    ${BTS_check}=  Set Variable  True
    ${BTS_invalid_label_list}=  Create List
    ${BTS_request_label_list}=  Create List
    ${BTS_request_alias_list}=  Create List

    FOR  ${item}  IN  @{BTS_LIST}
        ${BTS_check}=  Set Variable If  '${item}' not in ${BTS_label_list}  False  ${BTS_check}
        Run Keyword If  '${item}' not in ${BTS_label_list}
        ...  Append To List  ${BTS_invalid_label_list}  ${item}
        ...  ELSE
        ...  Append To List  ${BTS_request_label_list}  ${item}
    END

    Run Keyword If  '${BTS_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected BTS are not valid: ${BTS_invalid_label_list}. Please select values for test argument \${BTS_LIST} from
    ...  configured BTS: ${BTS_label_list} or let default value: ALL  console=True  level=ERROR
    ...  AND  Fail  Improper value for argument!

    FOR  ${item}  IN  @{BTS_request_label_list}
        ${BTS_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_request_alias_list}  ${BTS_request_alias}
    END

    Set Test Variable  ${BTS_label_list}  ${BTS_request_label_list}
    Set Test Variable  ${BTS_alias_list}  ${BTS_request_alias_list}

Check BTS Error Case list
    ${BTS_Error_Case_list_strip}=  Replace String  ${ERROR_CASE_BTS_LIST}  ${SPACE}  ${EMPTY}
    ${BTS_Error_Case_list}=  Split String  ${BTS_Error_Case_list_strip}  ,
    ${BTS_error_case_check}=  Set Variable  True
    ${BTS_error_case_invalid_label_list}=  Create List
    ${BTS_error_case_request_label_list}=  Create List
    ${BTS_error_case_request_alias_list}=  Create List

    FOR  ${item}  IN  @{BTS_Error_Case_list}
        ${BTS_error_case_check}=  Set Variable If  '${item}' not in ${BTS_label_list}  False  ${BTS_error_case_check}
        Run Keyword If  '${item}' not in ${BTS_label_list}
        ...  Append To List  ${BTS_error_case_invalid_label_list}  ${item}
        ...  ELSE
        ...  Append To List  ${BTS_error_case_request_label_list}  ${item}
    END

    Run Keyword If  '${BTS_error_case_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected BTS are not valid: ${BTS_error_case_invalid_label_list}.
    ...  Please select values for test argument \${ERROR_CASE_BTS_LIST} from
    ...  configured BTS: ${BTS_label_list} or let default value: ALL  console=True  level=ERROR
    ...  AND  Fail  Improper value for argument!

    FOR  ${item}  IN  @{BTS_error_case_request_label_list}
        ${BTS_error_case_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_error_case_request_alias_list}  ${BTS_error_case_request_alias}
    END

    Set Test Variable  ${BTS_error_case_label_list}  ${BTS_error_case_request_label_list}
    Set Test Variable  ${BTS_error_case_alias_list}  ${BTS_error_case_request_alias_list}

Check RM serial number list
    ${RM_SERIAL_NUMBER_LIST_strip}=  Replace String  ${RM_SERIAL_NUMBER_LIST}  ${SPACE}  ${EMPTY}
    ${RM_SERIAL_NUMBER_LIST}=  Split String  ${RM_SERIAL_NUMBER_LIST_strip}  ,
    ${RM_sn_check}=  Set Variable  True
    ${RM_SN_invalide_list}=  Create List

    FOR  ${item}  IN  @{RM_SERIAL_NUMBER_LIST}

        ${RM_sn_check}=  Set Variable If  '${item}' not in ${shared_RM_sn_list}  False  ${RM_sn_check}
        Run Keyword If  '${item}' not in ${shared_RM_sn_list}  Append To List  ${RM_sn_invalide_list}  ${item}

    END

    Run Keyword If  '${RM_sn_check}' == 'False'  Run Keywords
    ...  Log  Following selected RM serial number values are not valid: ${RM_sn_invalide_list}.  console=True
    ...  AND  Log  Please select values for test argument \${RM_SERIAL_NUMBER_LIST} from configured RM: ${shared_RM_sn_list}
    ...  console=True  level=ERROR
    ...  AND  Fail  Improper value for argument!
    Set Test Variable  ${shared_RM_sn_list}  ${RM_SERIAL_NUMBER_LIST}

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

    ${wait_for_alarm_clear}=  Set Variable If  '${when}' == 'final'  15 min  5 min
    Log  Step ${index}: Check ${when} all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Check and set CB013910 feature
    [Documentation]
    ...  Check CB013910 feature settings on BTS

    Log  Step ${index}: Check CB013910 feature settings  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  Check CB013910 feature settings on BTS ${alias} and set them accordingly if needed  console=True

        ${BTS_CB013910_feature_dict}=  Get BTS CB013910 feature parameter  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}

        Set Test Variable  ${${alias}_BTS_CB013910_feature_dict}  ${BTS_CB013910_feature_dict}

        IF  '${alias}' in ${BTS_error_case_alias_list}
            Set classical BTS CB013910 feature parameter  actFronthaulSshAccess  false  dist_name  ${alias}
        ELSE
            Set classical BTS CB013910 feature parameter  actFronthaulSshAccess  true  dist_name  ${alias}
        END
    END

Step ${index}: Perform EIF down operation on all BTS
    [Documentation]
    ...  Perform EIF down operation on all BTS

    Log  Step ${index}: Perform EIF down operation on all BTS  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}
        ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Perform EIF operation on BTS  ${label}  ${alias}  down
        ${oam_ip_address}=  Get Variable Value  ${${alias.upper()}}[${alias.upper()}_OAM_IP_ADDRESS]  ${Empty}
        Wait For Target To Be Not Reachable TAF   ${oam_ip_address}  60
        Log  Ping to ${alias} MPlane IP address is not working - as expected.  console=True
    END

Step ${index}: Perform EIF up operation on all BTS
    [Documentation]
    ...  Perform EIF up operation on all BTS

    Log  Step ${index}: Perform EIF up operation on all BTS  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}
        ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Perform EIF operation on BTS  ${label}  ${alias}  up
        ${oam_ip_address}=  Get Variable Value  ${${alias.upper()}}[${alias.upper()}_OAM_IP_ADDRESS]  ${Empty}
        Wait For Target To Be Reachable TAF   ${oam_ip_address}  60
        Log  Ping to ${alias} MPlane IP address is working - as expected.  console=True
    END

Step ${index}: Perform BTS-RM-BTS connection for iteration ${CYCLE}
    [Documentation]
    ...  Perform BTSx-RM-BTSy connection for each shared RMOD for iteration

    Log  Step ${index}: Perform BTS-RM-BTS connection for iteration ${CYCLE}  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}
        ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Determine peer alias and peer label  ${alias}  ${label}
        FOR  ${rmod_sn}  IN  @{shared_RM_sn_list}
            ${rmod_protocol}=  Get From Dictionary  ${${alias}_RMOD_sn_interface_dict}  ${rmod_sn}
            Continue For Loop If  '${rmod_protocol}' == 'RP301_RP1'

            ${rmod_id_alias}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${rmod_sn}
            ${rmod_id_peer_alias}=  Get From Dictionary  ${${peer_alias}_RMOD_sn_id_dict}  ${rmod_sn}

            ${cond1_primary}=  Create Long String
            ...  '${rmod_id_alias}' in ${${alias.upper()}_all_shared_RMOD_connected_in_BBMOD_from_primary_core}
            ${cond2_primary}=  Create Long String
            ...  '${rmod_id_peer_alias}' in ${${peer_alias.upper()}_all_shared_RMOD_connected_in_BBMOD_from_primary_core}
            Run Keyword If  ${cond1_primary} and ${cond2_primary}  Run Keywords
            ...  Log  Test Connection ${label} -> RMOD ${rmod_sn} -> ${peer_label}  console=True
            ...  AND  Test Connection from Source BTS to RMOD and Target BTS  ${rmod_sn}  ${label}  ${alias}  ${peer_label}  ${peer_alias}

            ${cond1_secondary}=  Create Long String
            ...  '${rmod_id_alias}' in ${${alias.upper()}_all_shared_RMOD_connected_in_BBMOD_from_secondary_core}
            ${cond2_secondary}=  Create Long String
            ...  '${rmod_id_peer_alias}' in ${${peer_alias.upper()}_all_shared_RMOD_connected_in_BBMOD_from_secondary_core}

            Run Keyword If  ${cond1_primary} and ${cond2_secondary}  Run Keywords
            ...  Log  Test Connection ${peer_label} -> RMOD ${rmod_sn} -> ${label}  console=True
            ...  AND  Test Connection from Source BTS to RMOD and Target BTS  ${rmod_sn}  ${peer_label}  ${peer_alias}  ${label}  ${alias}
            Run Keyword If  ${cond1_secondary} and ${cond2_secondary}
            ...  Log  RMOD ${rmod_sn} is excluded from connection chain as is connected to secondary core in both ${label} and ${peer_label}
            ...  console=True
        END
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Determine peer alias and peer label
    [Documentation]
    ...  Current and peer alias and label are determined for each pair of BTSs
    [Arguments]  ${current_alias}  ${current_label}

    Set Test Variable  ${BTS_current_alias}  ${current_alias}
    Set Test Variable  ${BTS_current_label}  ${current_label}
    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${current_alias}'
        ${peer_alias}=  Set Variable  ${other_alias}
        ${peer_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${other_alias}
        Set Test Variable  ${peer_alias}
        Set Test Variable  ${peer_label}
    END

Test Connection from Source BTS to RMOD and Target BTS
    [Documentation]
    ...  Connection from BTS->RMOD->BTS is made by the following steps:
    ...  - connect from BTS current to RMOD via SSH
    ...  - connect from RMOD to BTS peer via SSH
    ...  - after connection was successfully made, check if destination BTS is correct
    [Arguments]    ${rmod_sn}  ${source_label}  ${source_alias}  ${dest_label}  ${dest_alias}

    Log  Connect from ${source_label} to RMOD ${rmod_sn}  console=True
    ${ssh_session}=  rmod_ssh.Setup Rmod Ssh Connection  rmod_sn=${rmod_sn}  bts_alias=${source_alias}

    ${target_oam_ip_address}=  Get Variable Value  ${${dest_alias.upper()}}[${dest_alias.upper()}_OAM_IP_ADDRESS]  ${Empty}
    ${target_bts_ip}=  Get Target BTS IP  ${rmod_sn}  ${source_alias}  ${dest_alias}

    ${command_for_smod}=  Set Variable  ip -o addr show| grep ${target_oam_ip_address}
    ${expected_output} =  Set Variable  inet ${target_oam_ip_address}

    IF  '${dest_label}' in ${BTS_error_case_label_list}
        Log  ERROR CASE is tested: connection from ${source_label} via RMOD ${rmod_sn} to ${dest_label} should NOT be successful.  console=True
    END

    Log  Execute command on RMOD ${rmod_sn} to connect to target ${dest_label} and verify connection  console=True
    ${command_status}=  rmod_ssh.Execute Command on Smod via Rmod  rmod_sn=${rmod_sn}  smod_ip=${target_bts_ip}  command_for_smod=${command_for_smod}
    ...  expected_output=${expected_output}

    ${is_error_case}=  Evaluate  '${dest_label}' in ${BTS_error_case_label_list}
    ${is_connection_ok}=  Evaluate  '${command_status}' == 'True'

    IF  ${is_error_case}
        IF  ${is_connection_ok}
            Log  ERROR CASE: Connection from RMOD ${rmod_sn} to ${dest_label} should NOT be successful  console=True  level=ERROR
            Fail  Connection from RMOD ${rmod_sn} to ${dest_label} should NOT be successful
        ELSE
            Log  ERROR CASE: Connection from RMOD ${rmod_sn} to ${dest_label} cannot be established as expected - NORMAL BEHAVIOUR  console=True
        END
    ELSE
        IF  ${is_connection_ok}
            Log  Connection from RMOD ${rmod_sn} to ${dest_label} verified successfully  console=True
        ELSE
            Log  Connection from RMOD ${rmod_sn} to ${dest_label} cannot be established  console=True  level=ERROR
            Fail  Connection from RMOD ${rmod_sn} to ${dest_label} cannot be established
        END
    END

    Log  Close RMOD ${rmod_sn} SSH connection  console=True
    [Teardown]  rmod_ssh.Teardown Rmod Ssh Connection  rmod_sn=${rmod_sn}

Get Target BTS IP
    [Documentation]
    ...  Get Target BTS IP from SMOD_EXT object located on current BTS
    [Arguments]  ${rmod_sn}  ${alias}  ${dest_alias}

    ${target_bts_ip}=  Set Variable  None
    ${smod_ext_info}=   coam.Get Managed Objects  class_name=SMOD_EXT_R  connection=${alias}
    ${rmod_protocol}=  Get From Dictionary  ${${alias}_RMOD_sn_interface_dict}  ${rmod_sn}

    ${pattern}=  Set Variable If  '${rmod_protocol}'=='CPRI_RP1'  (?<!e)CPRI: (\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3})
    ...  eCPRI: (\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3})

    FOR  ${smod_r}  IN  @{smod_ext_info}
        ${serial_number}=  Get From Dictionary  ${smod_r['parameters']}  serialNumber
        Continue For Loop If  '${serial_number}' != '${${dest_alias}_SMOD_serialNumber_primary_core}'

        ${ip_adress_list}=  Get From Dictionary  ${smod_r['parameters']}  ipAddress
        ${match_combined}=  Get Regexp Matches  ${ip_adress_list}  ${pattern}  1
        ${match_simple}=  Get Regexp Matches  ${ip_adress_list}  (\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3})  1

        ${match_combined_status}=  Run Keyword And Return Status  Should Not Be Empty  ${match_combined}
        ${match_simple_status}=  Run Keyword And Return Status  Should Not Be Empty  ${match_simple}
        Continue For Loop If  '${match_combined_status}'=='False' and '${match_simple_status}'=='False'

        ${target_bts_ip}=  Set Variable If  ${match_combined_status}
        ...  ${match_combined[0]}
        ...  ${match_simple[0]}
    END

    [Return]  ${target_bts_ip}

Perform EIF operation on BTS
    [Documentation]
    ...  Perform EIF down or up operation on BTS
    [Arguments]  ${BTS_label}  ${alias}  ${operation}

    Log  ***** Perform EIF ${operation} operation on ${BTS_label} *****  console=True

    ${EIF_info}=  Set Variable If
    ...  '${operation}' == 'down' and '${BTS_label}' == 'BTS1'  ${BTS1_EIF_down}
    ...  '${operation}' == 'up' and '${BTS_label}' == 'BTS1'  ${BTS1_EIF_up}
    ...  '${operation}' == 'down' and '${BTS_label}' == 'BTS2'  ${BTS2_EIF_down}
    ...  '${operation}' == 'up' and '${BTS_label}' == 'BTS2'  ${BTS2_EIF_up}
    ${EIF_pass}=  Set Variable If
    ...  '${operation}' == 'down' and '${BTS_label}' == 'BTS1'  ${BTS1_EIF_pass_down}
    ...  '${operation}' == 'up' and '${BTS_label}' == 'BTS1'  ${BTS1_EIF_pass_up}
    ...  '${operation}' == 'down' and '${BTS_label}' == 'BTS2'  ${BTS2_EIF_pass_down}
    ...  '${operation}' == 'up' and '${BTS_label}' == 'BTS2'  ${BTS2_EIF_pass_up}
    ${EIF_ip}=  Set Variable If
    ...  '${BTS_label}' == 'BTS1'  ${BTS1_EIF_Switch_IpAddress}  ${BTS2_EIF_Switch_IpAddress}

    ${BTS_secondary_core}=  Run Keyword And Return Status
    ...  Dictionary Should Contain Key  ${${alias.upper()}_EXT}  ${alias.upper()}_EXT_PC_IP_ADDRESS
    Set Test Variable  ${${alias}_BTS_secondary_core}  ${BTS_secondary_core}

    Perform operation on BTS  ${BTS_label}  ${operation}  ${EIF_info}  ${EIF_pass}  ${EIF_ip}

    Log  EIF ${operation} operation on ${BTS_label} ended, wait for confirmation  console=True

Perform operation on BTS
    [Arguments]  ${BTS_label}  ${operation}  ${info}  ${pass}  ${ip}

    ${command}=  Set Variable  sudo sshpass -p ${pass} ssh -tt ${info}@${ip}
    Log  Perform EIF ${operation} operation on ${BTS_label} by following command:\n ${command}  console=True
    ${output}=  Run Process  ${command}  stderr=STDOUT  shell=True
    ${status}=  Run Keyword And Return Status  Should Be Equal As Integers  ${output.rc}  0
    ${status1}=  Run Keyword And Return Status  Should Be Equal As Integers  ${output.rc}  255
    Run Keyword If  '${status}' == 'False'
    ...  Run Keyword If  '${status1}' == 'False'  Run Keywords
    ...  Log Long String  EIF ${operation} operation on ${BTS_label} could not be performed! Please verify if
    ...  ${info} command is correct!  lever=ERROR
    ...  AND
    ...  Fail  EIF ${operation} operation on ${BTS_label} could not be performed! Please verify if ${info} command is correct!
    Log  EIF ${operation} operation on ${BTS_label} ended!  console=True

Step ${index}: Get all BTS shared RMOD lists connected in primary and secondary core
    [Documentation]
    ...  Get all BTS shared RMOD lists connected in primary and secondary core

    Log  Step ${index}: Get all BTS shared RMOD lists connected in primary and secondary core  console=True

    FOR  ${alias}  IN  @{alias_list}

        ${all_BBMOD_connected_in_primary_core}=  Create List
        ${all_shared_RMOD_connected_in_BBMOD_from_primary_core}=  Create List
        ${all_BBMOD_connected_in_secondary_core}=  Create List
        ${all_shared_RMOD_connected_in_BBMOD_from_secondary_core}=  Create List

        ${BBMOD_list}=  Get Ids For All  class_name=BBMOD  connection=${alias}
        Sort List  ${BBMOD_list}

        FOR  ${BBMOD_id}  IN  @{BBMOD_list}
            ${RMOD_SMOD_info_dict}=  Create Dictionary

            ${BBMOD_SMOD_info_dict}=  Get BBMOD and SMOD position in subrack  ${BBMOD_id}  ${alias}
            ${BBMOD_verticalPosition}=  Get From Dictionary  ${BBMOD_SMOD_info_dict}  BBMOD_verticalPosition
            ${BBMOD_verticalPosition}=  Evaluate  ${BBMOD_verticalPosition} - 1
            ${SMOD_activeRole}=  Get From Dictionary  ${BBMOD_SMOD_info_dict}  SMOD_activeRole
            ${SMOD_serialNumber}=  Get From Dictionary  ${BBMOD_SMOD_info_dict}  SMOD_serialNumber

            Run Keyword If  '${SMOD_activeRole}' == 'Primary' or '${SMOD_activeRole}' == 'None'  Run Keywords
            ...  Append To List  ${all_BBMOD_connected_in_primary_core}  ${BBMOD_id}
            ...  AND  Set Test Variable  ${SMOD_serialNumber_primary_core}  ${SMOD_serialNumber}
            Run Keyword If  '${SMOD_activeRole}' == 'Secondary'  Run Keywords
            ...  Append To List  ${all_BBMOD_connected_in_secondary_core}  ${BBMOD_id}
            ...  AND  Set Test Variable  ${SMOD_serialNumber_secondary_core}  ${SMOD_serialNumber}

        END

        FOR  ${BBMOD_id}  IN  @{all_BBMOD_connected_in_primary_core}

            ${BBMOD_RMOD_list}=  Get RMOD Mapping By BBMOD Id  ${BBMOD_id}  ${alias}
            ${BBMOD_RMOD_list}=  Remove Duplicates  ${BBMOD_RMOD_list}

            Append To List  ${all_shared_RMOD_connected_in_BBMOD_from_primary_core}  @{BBMOD_RMOD_list}
        END

        FOR  ${BBMOD_id}  IN  @{all_BBMOD_connected_in_secondary_core}

            ${BBMOD_RMOD_list}=  Get RMOD Mapping By BBMOD Id  ${BBMOD_id}  ${alias}
            ${BBMOD_RMOD_list}=  Remove Duplicates  ${BBMOD_RMOD_list}

            Append To List  ${all_shared_RMOD_connected_in_BBMOD_from_secondary_core}  @{BBMOD_RMOD_list}

        END

        ${all_shared_RMOD_connected_in_BBMOD_from_primary_core}=  Remove Duplicates  ${all_shared_RMOD_connected_in_BBMOD_from_primary_core}
        ${all_shared_RMOD_connected_in_BBMOD_from_secondary_core}=  Remove Duplicates  ${all_shared_RMOD_connected_in_BBMOD_from_secondary_core}
        Set Test Variable  ${${alias}_all_shared_RMOD_connected_in_BBMOD_from_primary_core}
        ...  ${all_shared_RMOD_connected_in_BBMOD_from_primary_core}
        Set Test Variable  ${${alias}_all_shared_RMOD_connected_in_BBMOD_from_secondary_core}
        ...  ${all_shared_RMOD_connected_in_BBMOD_from_secondary_core}
        Set Test Variable  ${${alias}_SMOD_serialNumber_primary_core}  ${SMOD_serialNumber_primary_core}
        Set Test Variable  ${${alias}_SMOD_serialNumber_secondary_core}  ${SMOD_serialNumber_secondary_core}

        Log Long String  List of RMs connected in primary core for ${${alias}_SMOD_serialNumber_primary_core}:
        ...  ${${alias}_all_shared_RMOD_connected_in_BBMOD_from_primary_core}  console=True
        Log Long String  List of RMs connected in secondary core for ${${alias}_SMOD_serialNumber_secondary_core}:
        ...  ${${alias}_all_shared_RMOD_connected_in_BBMOD_from_secondary_core}  console=True
    END

Get RMOD Mapping By BBMOD Id
    [Arguments]   ${BBMOD_id}  ${alias}
    ${BBMOD_RMOD_list}=  Create List
    ${CABLINK_list}=  Get Parameters For All  CABLINK  alias=${alias}

    FOR  ${item}  IN  @{CABLINK_list}

        ${secondEndpointDN_RMOD_R}=  Run Keyword And Return Status  Should Contain  ${item.secondEndpointDN}  RMOD_R
        Run Keyword If  '${item.firstEndpointDN}' == '${BBMOD_id}' and ${secondEndpointDN_RMOD_R}
        ...  Append To List  ${BBMOD_RMOD_list}  ${item.secondEndpointDN}

    END
    Sort List  ${BBMOD_RMOD_list}

    [Return]  ${BBMOD_RMOD_list}

Recover initial settings for CB013910 feature
    [Documentation]
    ...  Keyword used to recover initial settings for CB013910 feature

    [Arguments]  ${alias}

    Log  Recover initial settings for CB013910 feature on BTS ${alias}  console=True
    ${actFronthaulSshAccess_initial}=  Get From Dictionary  ${${alias}_BTS_CB013910_feature_dict}  actFronthaulSshAccess
    Set classical BTS CB013910 feature parameter  actFronthaulSshAccess  ${actFronthaulSshAccess_initial}  dist_name  ${alias}

Recover initial EIF up state for all BTS
    [Documentation]
    ...  Keyword used to recover initial EIF up state

    [Arguments]  ${alias}
    Log  Recover initial EIF up state on BTS ${alias}  console=True
    ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}

    Perform EIF operation on BTS  ${label}  ${alias}  up
    ${oam_ip_address}=  Get Variable Value  ${${alias.upper()}}[${alias.upper()}_OAM_IP_ADDRESS]  ${Empty}
    Wait For Target To Be Reachable TAF   ${oam_ip_address}  60
    Log  Ping to ${alias} MPlane IP address is working - as expected.  console=True

Particular Teardown
    FOR  ${alias}  IN  @{alias_list}
        Run Keyword And Continue On Failure  Recover initial settings for CB013910 feature  ${alias}
        Run Keyword And Continue On Failure  Recover initial EIF up state for all BTS  ${alias}
    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown