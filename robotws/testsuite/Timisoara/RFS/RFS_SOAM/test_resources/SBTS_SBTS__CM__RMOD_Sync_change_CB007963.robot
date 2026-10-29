*** Settings ***
Documentation    TC__SBTS_SBTS__CM__RMOD_Sync_change_CB007963
Variables    tc_variables/sbts_sbts__cm__rmod_sync_change_CB007963_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${RECOMMISSIONING_BTS1}  NONE  # Absolute SCF file path with commissioning for BTS1 (i.e. /home/ute/btsauto/SCF_01_SBTS19.xml).
                                 # If NONE, TC failed
${RECOMMISSIONING_BTS2}  NONE  # Absolute SCF file path with commissioning for BTS2 (i.e. /home/ute/btsauto/SCF_01_SBTS19.xml).
                                 # If NONE, TC failed
${RMOD_WITH_SyncResiliency}  # SN of RMOD with sync resiliency (e.g. YK203400063); empty = TC failed.
${REPEAT_COUNTER}  3  # Number of sync changes (LANE lock/unlock operations), default value 3

*** Keywords ***
TC__SBTS_SBTS__CM__RMOD_Sync_change_CB007963
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26989
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26989 -
    ...  [5G][eCPRI][CB007963] New scenario: sync_change_ToP_phase_Sync_resiliancy_eCPRI_RMOD
    ...  - 15.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29194 -
    ...  [5G]Enhance SBTS_SBTS__CM__RMOD_Sync_change_CB007963 to work using new KW behaviour
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  https://confluence.ext.net.nokia.com/display/SRANRFSP/Test+Cases+Documentation+-+DRAFT
    ...  SBTS_SBTS__CM__RMOD_Sync_change_CB007963.xlsx

    Set Tags    CA-CM    OWNER-ariel.ciucurita@nokia.com    AUTHOR-ariel.ciucurita@nokia.com    PHASE-CRT    SW-SBTS23    CABLING-RFS_01_UE

    TC Parameters check
    Step 1: Check initial state on both BTS
    Step 2: Check initial alarms on both BTS
    Step 3: Perform Recommissioning on all BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Perform Sync Change
    END

    [Teardown]  Particular Teardown


TC Parameters check
    [Documentation]
    ...  Detect needed BTS SCF
    ...  If RF SN or SCF is not specified Fail TC
    ...  Get initial SCFs for restoring initial config at the end of the test

    Run Keyword If  '${RMOD_WITH_SyncResiliency}' == ''
    ...  Fail  No value set for test argument \${RMOD_WITH_SyncResiliency}

    FOR  ${alias}  IN  @{alias_list}
        ${BTS_label}=  Set Variable If  '${alias}' == 'Master'  BTS1  BTS2
        ${scf_path_tmp}=  Run Keyword If  '${RECOMMISSIONING_${BTS_label}}' == 'NONE'
        ...  Fail  No ${alias} SCF provided
        ...  ELSE  Set Variable  ${RECOMMISSIONING_${BTS_label}}

        OperatingSystem.File Should Exist  ${scf_path_tmp}
        ${bts_info_tmp}=  Admin Get BTS state info  alias=${alias}
        Set Test Variable  ${${BTS_label}_commissioning_scf_path}  ${scf_path_tmp}
        Set Test Variable  ${${BTS_label}_info}  ${bts_info_tmp}
        ${BTS_scf_initial}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}  export_type=configuration
        Set Test Variable  ${${alias}_BTS_scf_initial}  ${BTS_scf_initial}
        Sleep  1s
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

Step ${index}: Perform Recommissioning on all BTS
    Log  Step ${index}: Perform Recommissioning on all BTS
    FOR  ${alias}  IN  @{alias_list}
        ${BTS_label}=  Set Variable If  '${alias}' == 'Master'  BTS1  BTS2
        Set Test Variable  ${alias}
        Set Test Variable  ${BTS_label}
        Planned BTS Recommissioning
        Step 4: Check final state on both BTS
        Step 5: Check final alarms on both BTS
    END

Planned BTS Recommissioning
    [Documentation]
    ...  Planned BTS recommissioning with SCF file is triggered. The new SCF file is loaded on BTS, reboot should be triggered after.

    Log  BTS Recommissioning with eCPRI RMOD sync resiliencyon ${BTS_label}  console=True
    Log  Commissioning via ADMIN will be performed using ${${BTS_label}_commissioning_scf_path}  console=True

    Get Current Time  bts_initial
    coam.Perform Commissioning  bts_id=${${BTS_label}_info[0]}  scf_file=${${BTS_label}_commissioning_scf_path}
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=600  connection=${alias}
    Log  ${BTS_label} commissioning has been performed  console=True

Perform Sync Change
    [Documentation]
    ...  BTS info are related to shared RMOD and RMOD_WITH_SyncResiliency
    ...  Sync change with LANE lock/unlock and state/alarms check

    Log  Get shared RMOD info  console=True
    Log  Sync change with LANE lock/unlock and state/alarms check
    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  RMOD  Master  Slave
    Sort List  ${Master_shared_RMOD_list}
    Set Test Variable  ${Master_shared_RMOD_list}
    Set Test Variable  ${Slave_shared_RMOD_list}
    Get RMOD ID SN dict  Master
    Get RMOD ID SN dict  Slave
    ${Master_RMOD_SN_list}=  Get Dictionary Keys  ${Master_module_SN_ID_dict}
    ${Slave_RMOD_SN_list}=  Get Dictionary Keys  ${Slave_module_SN_ID_dict}
    ${Shared_RMOD_SN_list}=  Create List
    FOR  ${item}  IN  @{Master_RMOD_SN_list}
        Run Keyword If  '${item}' in ${Slave_RMOD_SN_list}
        ...  Append To List  ${Shared_RMOD_SN_list}  ${item}
    END
    Run Keyword If  '${RMOD_WITH_SyncResiliency}' not in ${Shared_RMOD_SN_list}  Run Keywords
    ...  Log  Improper value set for test argument \${RMOD_WITH_SyncResiliency}, RF not in shared list ${Shared_RMOD_SN_list}  level=ERROR
    ...  AND  Fail  Improper value set for test argument \${RMOD_WITH_SyncResiliency}

    ${Master_Primary_Link_dict}  ${Slave_Primary_Link_dict}=  Get Primary Link status for shared RMOD
    ${Master_RMOD_id}=  Get From Dictionary  ${Master_module_SN_ID_dict}  ${RMOD_WITH_SyncResiliency}
    ${Slave_RMOD_id}=  Get From Dictionary  ${Slave_module_SN_ID_dict}  ${RMOD_WITH_SyncResiliency}
    ${link}=  Get From Dictionary  ${Master_Primary_Link_dict}  ${Master_RMOD_id}
    Run Keyword If  '${link}' == '[True]'
    ...  Lane lock unlock on master bts  ${Master_RMOD_id}
    ...  ELSE
    ...  Lane lock unlock on slave bts  ${Slave_RMOD_id}

Lane lock unlock on master bts
    [Arguments]  ${RF_id}
    Log  Primary sync on master BTS, LANE lock ${RF_id}  console=True
    Get BTS MODULE LANE info dict  RMOD  Master
    Perform LANE operation  ${RF_id}  Lock  Master
    Sleep  10s

    Get and Check Alarms SOAM  Slave
    ...  time=1 min  poll_interval=3 sec
    ...  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_61631}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

    Log  master BTS LANE unlock ${RF_id}  console=True
    Perform LANE operation  ${RF_id}  Unlock  Master
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=Master
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=Slave

Lane lock unlock on slave bts
    [Arguments]  ${RF_id}
    Log  pimary sync on slave BTS, LANE lock ${RF_id}  console=True
    Get BTS MODULE LANE info dict  RMOD  Slave
    Perform LANE operation  ${RF_id}  Lock  Slave
    Sleep  10s

    Get and Check Alarms SOAM  Master
    ...  time=1 min  poll_interval=3 sec
    ...  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_61631}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

    Log  slave BTS LANE unlock ${RF_id}  console=True
    Perform LANE operation  ${RF_id}  Unlock  Slave
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=Master
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=Slave

Recover initial config
    [Documentation]
    ...  Recover initial sync configs

    [Arguments]  ${alias}
    ${BTS_label}=  Set Variable If  '${alias}' == 'Master'  BTS1  BTS2
    coam.Perform Commissioning  bts_id=${${BTS_label}_info[0]}  scf_file=${${alias}_BTS_scf_initial}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=600  connection=${alias}
    Log  ${BTS_label} commissioning has been performed to recover initial sync conf  console=True

Particular Teardown
    FOR  ${alias}  IN  @{alias_list}
        Recover initial config  ${alias}
        Check all BTS cells availability status online
    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown