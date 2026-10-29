*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Resource    ../Resources/Setup/setup_and_teardown.robot
Resource    ../Resources/Robot/PDU.robot
Resource  ./common_setup.robot
Resource  ./site_operations.robot
Resource  ./site_verifications.robot
Resource  ./variables.robot
Resource  ./sw_mngt.robot

Library  BuiltIn
Library  Collections
Library  String
Library  robot.libraries.DateTime
Library  taf.sbts.oam.coam.admin    WITH NAME    admin
Library  ute_admin_infomodel    WITH NAME    admin_im
Library  ./factory_sw_download.py


*** Variables ***
${UTE_UE_CONFIG}  ${EMPTY}
${FDSW_FR_DIR}  /home/ute/FDSW_FR/


*** Keywords ***
Incompatible Software Detection and Update
  [Documentation]
  ...  Purpose of this test is checking
  ...
  ...  Parameters:
  ...  Name  |  Mandatory  |  Default value  |  Description
  ...  software_type  |  factory, regular  |  regular  |  type of software used to trigger alarm 23
  ...  RF=LBALLU-YD162106DA8
  Common Test Setup
  ${tested_rf}=    Set Variable    ${CUSTOM_RADIO_UNIT_LIST}[0]
  ${node_id}=  Set Variable  ${cfg.RF_INFO['${tested_rf}']['scf_btsid_primary']}
  ${rf_dist_name}=  Set Variable  ${cfg.RF_INFO['${tested_rf}']['scf_dist_name_primary']}
  ${variant}=  Set Variable  ${cfg.RF_INFO['${tested_rf}']['scf_variant']}
  ${sw_status}=  Run Keyword And Return Status  Variable Should Exist  ${FACTORYSW}
  ${software_type}=  Set Variable If    ${sw_status}  factory  regular
  Set Test Variable  ${NODE_ID}  ${node_id}
  Prepare Incompatible Software
  ...  ${node_id}
  ...  ${software_type}
  ...  ${variant}
  ...  ${rf_dist_name}
  PDU Switch On Device Lists  ${CUSTOM_RADIO_UNIT_LIST}
  Verify RMOD With incompatible Software  ${node_id}  ${variant}
  Update RMOD Software  ${node_id}
  Check Node FRs status  ${node_id}
  Verify Multi BTS State
  Verify FID 4589  ${node_id}
  Verify Alarms  alias=${node_id}
  [Teardown]    Common Test Teardown

Prepare Incompatible Software
  [Arguments]  ${node_id}  ${software_type}  ${variant}  ${rf_dist_name}

  ${diff_sw_package}=  Run Keyword If  '${software_type}' == 'factory'
  ...  Define Software Version Packages  ${node_id}  ${variant}
  ${catalyst_sw_status}  ${catalyst_sw_package}=  Run Keyword If
  ...  '${software_type}' == 'factory'
  ...  Run Keyword And Ignore Error
  ...  Define Software Version Packages
  ...  ${node_id}
  ...  ${variant}_C
  ${catalyst_sw_status}=  Set Variable If    '${software_type}' != 'factory'
  ...  FAIL
  ...  ${catalyst_sw_status}
  Perform SW Update - First Phase  ${node_id}
  Refresh SW active state
  Run Keyword If
  ...  "${catalyst_sw_status}"=="PASS"
  ...  Perform SW Update - Catalyst Package
  ...  ${node_id}
  ...  ${catalyst_sw_package}
  Perform SW Update - Incompatible Phase  ${node_id}  ${software_type}  ${diff_sw_package}  ${catalyst_sw_status}
  Run Keyword If  '${software_type}' != 'factory'  Refresh SW active state
  PDU Switch Off Device Lists  ${CUSTOM_RADIO_UNIT_LIST}
  Run Keyword If  '${software_type}' != 'factory'  Refresh SW active state
  Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  20min  20sec
  ...  Assert Specific Amount Of FIDs  ${node_id}  ${23}  ${LENGTH_OF_UNNECESSARY_RMs}
  Run Keyword And Continue On Failure  Assert Alarm Active
  ...  parameters=faultId=10, alarmingObjectIds[0].configuration=${rf_dist_name}
  ...  timeout=900  connection=${node_id}
  Sleep  120  Stabilize between updates to avoid "BTS is busy"
  Perform SW Upgrade  ${node_id}
  Sleep  120
  Wait Until Keyword Succeeds  2000 sec  20 sec  admin.Reset Admin  connection=${node_id}
  Refresh SW active state
  admin.Add Allowed Alarm  faultId=23  connection=${node_id}
  [Teardown]  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'
  ...  PDU Switch On Device Lists  ${CUSTOM_RADIO_UNIT_LIST}

Perform SW Update - First Phase
  [Arguments]  ${node_id}
  ${status}=  Run Keyword And Return Status  Perform SW Upgrade  ${node_id}
  Wait Until Keyword Succeeds  ${CONFIGURATION_STARTUP_TIMEOUT}  20 sec  admin.Reset Admin  connection=${node_id}
  ${first_phase_status}=  Set Variable If  ${status}  PASS  FAIL
  Set Suite Variable  ${FIRST_PHASE_STATUS}  ${first_phase_status}
  sleep  60 sec
  [Return]  ${status}

Perform SW Update - Catalyst Package
  [Arguments]  ${node_id}  ${diff_sw_package}
  Turn Off Unnecessary RMs Considering Chain  ${CUSTOM_RADIO_UNIT_LIST}  ${node_id}
  Perform SW Upgrade For Specific Package  ${node_id}  ${diff_sw_package}
  Wait Until Keyword Succeeds  2000 sec  20 sec  admin.Reset Admin  connection=${node_id}

Perform SW Update - Incompatible Phase
  [Arguments]  ${node_id}  ${software_type}  ${diff_sw_package}  ${catalyst_sw_status}
  Run Keyword If  "${catalyst_sw_status}"=="FAIL"  Turn Off Unnecessary RMs Considering Chain  ${CUSTOM_RADIO_UNIT_LIST}  ${node_id}
  ...  ELSE  Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  20min  20sec
  ...  Assert Specific Amount Of FIDs  ${node_id}  number_of_expected_alarms=${LENGTH_OF_UNNECESSARY_RMs}
  Run Keyword If  '${software_type}' == 'factory'
  ...  Perform SW Upgrade For Specific Package  ${node_id}  ${diff_sw_package}
  ...  ELSE  Run Keyword And Continue On Failure  Perform SW Upgrade  ${node_id}
  PDU Switch On Device Lists  ${cfg.scf_hw_all_fr_list}
  Wait Until Keyword Succeeds  2000 sec  20 sec  admin.Reset Admin  connection=${node_id}

Verify RMOD With incompatible Software
  [Arguments]  ${node_id}  ${variant}
  ${conn_type}=  Get From Dictionary  ${CFG.NODES['${node_id}']}  bts_alias_type
  Run Keyword If  "${conn_type}" == "localhost"  SSH Get File From System Module
  ...  source_path=/ffs/run/TargetBD_${CFG['NODES']['${node_id}']['software_active']}.xml
  ...  destination_path=${TEST_LOGS_PATH}/BTSFiles/${node_id}/TargetBD_${node_id}_${CFG['NODES']['${node_id}']['software_active']}.xml
  ...  ELSE IF  "${CFG['configuration_setup_type']}"=="mplane"  SSH Get File From System Module
  ...  source_path=/ffs/run/TargetBD_${CFG['NODES']['${node_id}']['software_active']}.xml
  ...  destination_path=${TEST_LOGS_PATH}/BTSFiles/${node_id}/TargetBD_${node_id}_${CFG['NODES']['${node_id}']['software_active']}.xml
  ...  target_ip=${CFG.NODES['${node_id}']['bts_ip_address']}
  ...  ELSE  SSH Get File From System Module
  ...  source_path=/ffs/run/TargetBD_${CFG['NODES']['${node_id}']['software_active']}.xml
  ...  destination_path=${TEST_LOGS_PATH}/BTSFiles/${node_id}/TargetBD_${node_id}_${CFG['NODES']['${node_id}']['software_active']}.xml
  ...  via_ip=${CFG.NODES['${node_id}']['bts_ip_address']}
  ${rf_sw_status}=  SWM Check HW List SW Version Is Compatible With BTS SW
  ...  class=RMOD
  ...  serial_number_list=${CFG.NODES['${node_id}']['scf_hw_fr_list']}
  ...  targetbd_path=${TEST_LOGS_PATH}/BTSFiles/${node_id}/TargetBD_${node_id}_${CFG['NODES']['${node_id}']['software_active']}.xml
  ...  alias=${node_id}
  ...  timeout=360
  Run Keyword And Continue On Failure
  ...  admin.Assert Alarm Active  faultId=23, alarmAttribute[?].attributeValue=${variant}
  ...  timeout=360
  ...  alias=${node_id}

Update RMOD Software
  [Arguments]  ${bts_id}
  Refresh SW active state
  ${software_package_path}=  Check Main Software Package Availability
  ...  ${cfg.NODES['${bts_id}']['software_active']}
  ...  ${bts_id}
  Run Keyword And Ignore Error  admin.Wait Sw Update Possible
  ...  bts_ready=True
  ...  readiness_timeout=500
  ...  timeout=600
  ...  connection=${bts_id}
  log  ${\n}Software update to package: ${software_package_path} is being made. Please wait...  console=True
  Update Software  sw_package=${software_package_path}  should_activate=True  timeout=8000  alias=${bts_id}

Define Software Version Packages
  [Arguments]  ${node_id}  ${variant}
  ${release}=    Get From Dictionary    ${cfg.NODES['${node_id}']}    active_release
  Create Directory  ${FDSW_FR_DIR}
  ${diff_sw_package}=  download_knife_from_artifactory  ${release}  ${variant}  ${FDSW_FR_DIR}
  [Return]  ${diff_sw_package}

Check Software Package Availabilty
  OperatingSystem.File Should Exist  ${FDSW_FR_DIR}/${fr_file_name}

SW Upgrade From Older Branch For SM And Factory For RM
  Common Test Setup
  Logging With Timestamp
  ...  message=SW Upgrade From Older Branch For SM And Factory For RM
  ...  style=ONGOING

  ${all_rf}=  Get Dictionary Keys  ${cfg.RF_INFO}
  ${not_tested_rf}=  Copy List  ${all_rf}
  Remove Values From List  ${not_tested_rf}  ${CUSTOM_RADIO_UNIT_LIST}
  ${nodes_list}=  Get Dictionary Keys  ${cfg.NODES}

  Log To Console  Downloading and updating all nodes SW (clearing passive partition)
  FOR  ${node}  IN  @{nodes_list}
    Perform SW Upgrade  ${node}
    Wait Until Keyword Succeeds  2000 sec  20 sec  admin.Reset Admin  connection=${node_id}
    Log To Console  Node ${node} updated
  END

  Log To Console  Turning off not tested FR: ${not_tested_rf}
  PDU Switch On Device Lists  ${not_tested_rf}
  Update To Factory SW For RF In List  ${CUSTOM_RADIO_UNIT_LIST}

  PDU Switch Off Device Lists  ${CUSTOM_RADIO_UNIT_LIST}
  Log To Console  Turning off tested FR: ${CUSTOM_RADIO_UNIT_LIST}
  PDU Switch On Device Lists  ${not_tested_rf}
  Log To Console  Turning on not tested FR: ${not_tested_rf}
  FOR  ${node}  IN  @{nodes_list}
    ${older_branch}=  Get From Dictionary  ${SW_UPGRADE_PATH}  ${RELEASE}
    ${alternative_build}=  Get From Dictionary  ${BRANCH_UPGRADE_BUILD}  ${RELEASE}
    ${package_path}=  Try To Download Latest Build From Branch Or Download Alternative SW
    ...  branch=${older_branch}  alternative_build=${alternative_build}
    Run Keyword And Ignore Error  BTS Is Resetting  ${node}  timeout=600 sec
    Run Keyword And Ignore Error
    ...  admin.Wait Sw Update Possible
    ...  bts_ready=True
    ...  readiness_timeout=900
    ...  timeout=960
    ...  connection=${node}
    Log To Console  Downgrading SW to branch-1...
    Perform SW Upgrade For Specific Package  ${node}  ${package_path}
    Wait Until Keyword Succeeds  2000 sec  20 sec  admin.Reset Admin  connection=${node_id}
  END

  PDU Switch OFF Device Lists  ${not_tested_rf}
  FOR  ${node}  IN  @{cfg.active_bts_list}
    Reset Node Configuration  ${node}
    Perform Template File Commissioning  ${node}  True  previous
  END
  PDU Switch On Device Lists  ${not_tested_rf}

  PDU Switch On Device Lists  ${CUSTOM_RADIO_UNIT_LIST}
  Log To Console  Turning on tested FR: ${CUSTOM_RADIO_UNIT_LIST} \n All RF should be turned on on this point!
  Log To Console  \nTL is now prepared to test. Updating to selected SW release will be proceeded\n
  Sleep  60s

  FOR  ${node}  IN  @{nodes_list}
    ${first_sw}=  Get From Dictionary  ${CFG.NODES["${node}"]}  active_release
    ${first_sw}  ${sw_component}=  Create Software Package Name  ${first_sw}
    ${first_sw}=  Trunk Detector  ${first_sw}  ${RELEASE}
    SWM.SWM Get Software For Testing  /home/ute/Downloads  ${first_sw}  suffix_2=A54  sw_index=T0  timeout=60m
    Run Keyword And Ignore Error  BTS Is Resetting  ${node}  timeout=600 sec
    Run Keyword And Ignore Error
    ...  admin.Wait Sw Update Possible
    ...  bts_ready=True
    ...  readiness_timeout=900
    ...  timeout=960
    ...  connection=${node}
    Log To Console  \nUpdating node ${node} to SW ${first_sw}\n
    Perform SW Upgrade For Specific Package
    ...  ${node}
    ...  /home/ute/Downloads/${first_sw}_release_BTSSM_downloadable_A54.zip
    Wait Until Keyword Succeeds  2000 sec  20 sec  admin.Reset Admin  connection=${node_id}
    Run Keyword And Ignore Error  BTS Is Resetting  ${node}  timeout=600 sec
    Run Keyword And Ignore Error
    ...  admin.Wait Sw Update Possible
    ...  bts_ready=True
    ...  readiness_timeout=900
    ...  timeout=960
    ...  connection=${node}
    Log To Console  Node ${node} updated to initial SW
  END

  Log To Console  \nTC execution has finished. BTS state and alarms will be validated...\n

  Verify Alarms On All Nodes
  Verify Multi BTS State
  [Teardown]    Common Test Teardown

Update To Factory SW For RF In List
  [Arguments]  ${tested_rf}  ${download_path}=${FDSW_FR_DIR}
  Should Not Be Empty  ${tested_rf}  msg=At least one RF SN should be provided!
  ${dict_exists}=  Run Keyword And Return Status  Directory Should Exist  ${download_path}
  Run Keyword If  not ${dict_exists}  Create Directory  ${download_path}

  FOR  ${rf_sn}  IN  @{tested_rf}
    ${rf_dist_name}=  Set Variable  ${cfg.RF_INFO['${rf_sn}']['scf_dist_name_primary']}
    ${variant}=  Set Variable  ${cfg.RF_INFO['${rf_sn}']['scf_variant']}
    ${node_id}=  Set Variable  ${cfg.RF_INFO['${rf_sn}']['scf_btsid_primary']}
    ${release}=    Get From Dictionary    ${cfg.NODES['${node_id}']}    active_release
    Log To Console  Downloading Factory SW for FR ${variant} ${rf_sn}...
    ${factory_sw_path}=  Define Software Version Packages  ${node_id}  ${variant}
    ${catalyst_sw_status}  ${catalyst_sw_package}=  Run Keyword And Ignore Error
    ...  Define Software Version Packages  ${node_id}  ${variant}_C
#  ${factory_sw_path}=  Download Knife From Artifactory  ${release}  ${variant}  ${download_path}
    Run Keyword If  "${catalyst_sw_status}"=="PASS"  Run Keywords
    ...  Log To Console  Installing Factory SW for FR ${variant}_C ${rf_sn}...
    ...  AND  Perform SW Update - Catalyst Package  ${node_id}  ${catalyst_sw_package}
    ...  AND  Wait Until Keyword Succeeds  20min  20sec
    ...  Assert Specific Amount Of FIDs  ${node_id}  number_of_expected_alarms=${LENGTH_OF_UNNECESSARY_RMs}
    ...  AND  Sleep  120s  Stabilize between updates to avoid "BTS is busy"
    Log To Console  Installing Factory SW for FR ${variant} ${rf_sn}...
    Run Keyword And Ignore Error
    ...  admin.Wait Sw Update Possible
    ...  bts_ready=True
    ...  readiness_timeout=900
    ...  timeout=960
    ...  connection=${node_id}
    Perform SW Upgrade For Specific Package  ${node_id}  ${factory_sw_path}
    Wait Until Keyword Succeeds  2000 sec  20 sec  admin.Reset Admin  connection=${node_id}
    Run Keyword And Ignore Error  Remove File  ${factory_sw_path}
    Log To Console  Successfully updated ${variant} ${rf_sn} to Factory SW. File has been removed to save some space.
  END

Try To Download Latest Build From Branch Or Download Alternative SW
  [Arguments]  ${branch}=SBTS00  ${alternative_build}=${None}
  ${package_states}=  Create List  released
  ${build_name}=  Run Keyword And Return Status  Get Latest Promoted_Build_For Branch  ${branch}
  Log to Console  Found latest build for branch ${branch}: ${build_name} - downloading...
  ${download_status}=  Run Keyword And Return Status
  ...  SWM.SWM Get Software For Testing  /home/ute/Downloads  ${build_name}  suffix_2=A54  sw_index=T0  timeout=60m
  Return From Keyword If  ${download_status}  /home/ute/Downloads/${build_name}_release_BTSSM_downloadable_A54.zip
  Log To Console  Unable to download ${build_name}! Trying to download ${alternative_build}...  level=warn
  ${download_status}=  Run Keyword And Return Status
  ...  SWM.SWM Get Software For Testing  /home/ute/Downloads  ${alternative_build}  suffix_2=A54  sw_index=T0  timeout=60m
  Run Keyword If  not ${download_status}
  ...  Fail
  ...  Neither ${build_name} nor ${alternative_build} could have been dowloaded!
  Return From Keyword  /home/ute/Downloads/${alternative_build}_release_BTSSM_downloadable_A54.zip

Trunk Detector
  [Arguments]  ${sw}  ${sw_release}
  ${is_trunk}=  Run Keyword And Return Status  Should Match Regexp  ${sw}  .*_999[0-9].*
  Run Keyword If  not ${is_trunk}  Return From Keyword  ${sw}
  ${sw}=  Replace String  ${sw}  ${sw_release}  SBTS00
  ${sw_release}=  Set Variable  SBTS00
  [Return]  ${sw}

Turn Off Unnecessary RMs Considering Chain
  [Arguments]  ${RF_list}=${CUSTOM_RADIO_UNIT_LIST}  ${node}=${node}
  ${list_of_node_RMs}=  Set Variable  ${CFG.NODES["${node}"]["scf_hw_fr_list"]}
  ${list_of_unnecessary_RMs}=  Copy List  ${list_of_node_RMs}
  FOR  ${rm_sn}  IN  @{RF_list}
    ${list_of_necessary_RMs}=  Create List  ${rm_sn}  @{CFG.RF_INFO["${rm_sn}"]["scf_chain_fr_affected_list"]}
    Remove Values From List  ${list_of_unnecessary_RMs}  @{list_of_necessary_RMs}
  END
  PDU Switch OFF Device Lists  ${list_of_unnecessary_RMs}
  Log  \nTurned off unnecessary RMs for node ${node}: @{list_of_unnecessary_RMs}  console=yes
  ${length_of_unnecessary_RMs}=  Get Length  ${list_of_unnecessary_RMs}
  Set Test Variable  ${LENGTH_OF_UNNECESSARY_RMs}  ${length_of_unnecessary_RMs}
#  Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  35min  20sec
#  ...  Assert Specific Amount Of FIDs  ${node}  number_of_expected_alarms=${length_of_unnecessary_RMs}

Assert Specific Amount Of FIDs
  [Documentation]  Argument "fault_id" must be passed as intiger ex. ${10} or ${23}
  [Arguments]  ${node}  ${fault_id}=${10}  ${number_of_expected_alarms}=1
  ${active_alarms}=  admin.Get Alarms  alias=${node}
  ${fid_count}=  Evaluate  len([alarm["faultId"] for alarm in ${active_alarms} if alarm["faultId"] == ${fault_id}])
  Should Be Equal As Integers
  ...  ${number_of_expected_alarms}
  ...  ${fid_count}
  ...  msg=Number of expected alarms ${fault_id} (${number_of_expected_alarms}) is not equal actual value (${fid_count})
