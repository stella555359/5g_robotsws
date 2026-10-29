*** Settings ***
Documentation  LOGS__Snapshot_collection_from_decommissioned_SBTS

Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library     taf/rfrl/common_resources/python/reset_bts_configuration.py
Resource    ../resources/verdicts.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_TIMEOUT}      600                      #timeout for collect snapshot via Admin (in sec)

*** Keywords ***
TC__LOGS__Snapshot_collection_from_decommissioned_SBTS
    [Documentation]
    ...  [CASE LINK]:
    ...  https://jiradc.ext.net.nokia.com/browse/TAT-22566
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case created to check content of snapshot package collected from decomissioned BTS
    ...
    ...  Review note: Snapshot content must be updated in xml file for mandatory logs
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 02.02.2022 - TAT-22566 Initial TC creation
    ...  - 22.11.2022 - TAT-22566 Steps and KW documentation added, TC setup and teardown added
    ...  - 01.12.2022 - TAT-22566 BBMODs availability status check added, corrected after review
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...  - 20.04.2023 - TAT-25131 - hran_snapshot analysis refactoring to taf.ul.verify_snapshot UL usage
    ...  - 02.08.2023 - TAT-25866 - change reset bts configuration mechanism
    ...  - 29.12.2023 - TAT-26674 - add necessary params to Reset BTS Configuration and add Custom Teardown for BTS recovery
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/LOGS__Snapshot_collection_from_decommissioned_SBTS.png
    ...  *******************

    Set Tags    CA-LOGS
    ...   AUTHOR-karol.kuriata@nokia.com    MAINTAINER-iuliia.taupeka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf
    ...   PHASE-CRT   PHASE-CRT SW-SBTS23R1

    Step 1: BTS Decommissioning
    Step 2: Collect Snapshot
    Step 3: Check Content Of Package
    Step 4: Commission BTS From Backup File


Step 1: BTS Decommissioning
    [Documentation]
    ...    In this step BTS decommissioning is performed via ADMIN API
    Log    \n----- Step 1: BTS decommissioning via Admin API -----    console=${True}
    Log    Saving current configuration as SCF.xml in BTS files    console=${True}
    coam.Get Current SCF File
    ...    ${BTS Files}  SCF.xml  timeout=120   export_type=configuration  parameters_save_variant=actualValues
    ${num_of_BBMODs_online}=  Query Infomodel  get count //BTS_L-1/EQM_L-1/CABINET_L-1/BBMOD_L-* is [stateInfo.availabilityStatus=Online]
    Log    Performing BTS decommissioning via ADMIN    console=${True}
    ${is_it_dualcore}=  Run Keyword And Return Status  Variable Should Exist  ${SMOD2}
    ${secondary_remote_host}=  Set Variable If  ${is_it_dualcore}  ${PC_IP2}  ${None}
    ${VM_MSM_PASSWORD}  ${VM_ESM_PASSWORD}  ssh_utils.Get VM passwords
#    ${m-plane}=  bts_states.Get BTS Mplane
    Reset_bts_configuration.Reset Bts Configuration  timeout=900  fdsw_ip=192.168.255.129  reset_type=Configuration
    ...  secondary_remote_host=${secondary_remote_host}  secondary_remote_host_password=${VM_ESM_PASSWORD}  reset_admin_connection=True
    ${infomodel_reset_status}  Run Keyword And Return Status
    ...  ute_admin_infomodel.Reset Infomodel  filename=${BTS_FILES}/IM/InfoModel_untilReset.ims2
    Log  Will now verify that proceduralState of the BTS equals NotCommissioned  console=${TRUE}
    Wait Until Keyword Succeeds  1 min  30 sec  Check if BTS proceduralState is NotCommissioned
    Wait Until Keyword Succeeds  7m  30s    Check All BBMODs Are Back Online  ${num_of_BBMODs_online}
    Log  Configuration reset has passed.  console=${TRUE}

Check All BBMODs Are Back Online
    [Arguments]  ${num_BBMODS_expected}
    ${num_of_BBMODs_decommissioned}=  Query Infomodel  get count //BTS_L-1/EQM_L-1/CABINET_L-1/BBMOD_L-* is [stateInfo.availabilityStatus=Online]
    Log  Checking if Online BBMODs num (${num_of_BBMODs_decommissioned}) is = to expected ${num_of_BBMODs_decommissioned}  console=${True}
    Should Be Equal    ${num_BBMODS_expected}  ${num_of_BBMODs_decommissioned}


Step 2: Collect Snapshot
    [Documentation]
    ...    In this step Snapshot is collected via ADMIN API
    Log    \n----- Step2: Collect Snapshot-----    console=${True}
    @{time}=    Get Time    year month day hour min
    ${snapshot_status}    Run Keyword And Return Status
    ...    coam.Get Snapshot
    ...    ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If    ${snapshot_status}
    ...    Collecting Snapshot Succeeded  ${time}
    ...    ELSE
    ...    verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.  ${TRUE}


Step 3: Check Content Of Package
    [Documentation]
    ...    In this step Snapshot content is validated- if all most important files from SMOD/BBMOD are present.
    Log    \n----- Step3: Check content of package-----    console=${True}
    ${Found_file_dict}    snapshot.Get Data From Snapshot    ${PATH_TO_SNAPSHOT}
    ${path_to_xml_spec_file}  join path  ${CURDIR}  tc_variables  snapshot_decommissioned_spec.xml
    snapshot.Validate Snapshot    ${Found_file_dict}    ${path_to_xml_spec_file}


Step 4: Commission BTS From Backup File
    [Documentation]
    ...    In this step commissioning is performed from SCF backup file.
    Log    \n----- Step4: Commission BTS From Backup File-----    console=${True}
    coam.Perform Commissioning   scf_file=${BTS Files}/SCF.xml    skip_parameter_relation_errors=True    timeout=900
    Wait Until Keyword Succeeds  15m  20s  pm_logs_general.Check All Modules And All Cells Working States
    Log  All modules reached working state  console=${True}

Collecting Snapshot Succeeded
    [Arguments]    ${time}
    Log    Collecting snapshot via admin succeeded    console=${True}
    Set Test Variable    ${PATH_TO_SNAPSHOT}    ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip

Check if BTS proceduralState is NotCommissioned
    ${BTS state}  coam.Get Mrbts State  timeout=600
    Log  BTS proceduralState is: ${BTS state}  console=${TRUE}
    Should be equal  ${BTS state}  NotCommissioned

Custom Test Teardown
    Log  Custom Test Teardown - Waiting for SMOD and BBMOD to come online  console=${TRUE}
    Wait Until Keyword Succeeds  7m  30s    Check All BBMODs Are Back Online  ${num_of_BBMODs_online}
    ${BTS state}  coam.Get Mrbts State  timeout=600
    Log    BTS state: ${BTS state}    console=${TRUE}
    Run Keyword If  '${BTS state}' != 'OnAir'  Run Keywords
    ...  Log  Commissioning from backup SCF  console=${TRUE}
    ...  AND  coam.Perform Commissioning  scf_file=${BTS Files}/SCF.xml  skip_parameter_relation_errors=True  timeout=900
    ...  AND  Wait Until Keyword Succeeds  15m  20s  pm_logs_general.Check All Modules And All Cells Working States
    ...  AND  Log  All modules reached working state  console=${TRUE}
    ...  ELSE  Log  BTS is OnAir, skipping Custom Test Teardown  console=${TRUE}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Run Keyword If Test Failed  Custom Test Teardown
    ...    AND    Common Test Teardown
