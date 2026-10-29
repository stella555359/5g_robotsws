*** Settings ***
Documentation    Generic keywords for test suite variable preparation

*** Variables ***
${SNAPSHOT_TIMEOUT}			                1800
${alarms_list}                              ${EMPTY}
@{ALLOWED_ALARMS}=
...                                         4592
...                                         61524
...                                         61649
...								            61652
...                                         4334
...                                         4340
...                                         4654
...                                         4655
...                                         4681
...                                         61524
# [FID:4592]   EFaultId_BtsResetCauseAl
# [FID:61524]  EFaultId_SshEnabled
# [FID:61649]  EFaultId_LmpAccessViaPort
# [FID:61652]  EFaultId_RndServicePortEnabled
# [FID:4334]   EFaultId_SerialConsoleActivatedAl
#Update
# [FID:4654]   Ethernet port security is disabled
# [FID:4655]   Service account root access is enabled
# [FID:61524]  SSH enabled
# [FID:4340]  SSH enabled
# [FID:4681] Sanity Check


*** Keywords ***
Test Suite Variables Initialisation
  [Documentation]    This keyword will set up the test suite variables
  # Update of KPIs
  ${bts_instance_id}  tl_config.get_bts_instance_id
  Set Suite Variable  ${bts_instance_id}
  ${global_bts_id}  tl_config.get_global_bts_id
  Set Suite Variable  ${global_bts_id}
  ${SBTS_BUILD}   Get SBTS SW Build
  Set Suite Variable  ${SBTS_BUILD}
  ${SBTS_BRANCH}   Get SBTS SW Branch    ${SBTS_BUILD}
  Set Suite Variable  ${SBTS_BRANCH}
  ${BTS_SCOUT_NAME}   scout_utils.get_bts_scout_name
  Set Suite Variable    ${BTS_SCOUT_NAME}
  ${RESTORE_BTS_CONFIGURATION} =  Get Variable Value  ${RESTORE_BTS_CONFIGURATION}  No
  Set Suite Variable  ${RESTORE_BTS_CONFIGURATION}
  ${RMOD_BTSLOG}=  Get Variable Value  ${RMOD_BTSLOG}  No
  Set Suite Variable  ${RMOD_BTSLOG}
  ${GET_SNAPSHOT}=  Get Variable Value  ${GET_SNAPSHOT}  Yes
  Set Suite Variable  ${GET_SNAPSHOT}
  ${WITH_FEATURE_ACTIVATION}=  Get Variable Value  ${WITH_FEATURE_ACTIVATION}  No
  Set Suite Variable  ${WITH_FEATURE_ACTIVATION}
  ${GRACEFUL_CELL_SHUTDOWN_ON}=  Get Variable Value  ${GRACEFUL_CELL_SHUTDOWN_ON}  No
  Set Suite Variable  ${GRACEFUL_CELL_SHUTDOWN_ON}
  ${ALARMS_LIST_TO_SKIP}=  Get Variable Value  ${ALARMS_LIST_TO_SKIP}  ${Empty}
  Set Suite Variable  ${ALARMS_LIST_TO_SKIP}
  Update Allowed Alarms List
  ${Active_Alarms}=    Collect Active Alarms    alarms_path=${PATH_Storage}    alarms_prefix=initial_
  Run Keyword If     ${Active_Alarms}
  ...    Fail  Warning initial BTS Alarm are active, please check the logs.




