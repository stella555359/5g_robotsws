*** Settings ***
Documentation
    ...  TC for SW download and activation of the uncommissioned BTS

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${TARGET_SW_NAME}  ${None}  # SW package name.If not given,
# TC will choose newest package in a directory.
${TARGET_SW_DIR}  /home/ute/btsauto/TARGET_SW  # Directory in which TC should look for sw package.
# If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${SW_UPDATE_TIMEOUT}  900  # Given in seconds; That is a timeout
# for SW download and activation (without reset)
${PING_LOSS_TIMEOUT}  240  # Timeout for ping loss during reset
${PING_REGAIN_TIMEOUT}  600  # Timeout for ping regain during reset
${DISABLE_RMODS}  ${False}  # Should RMODS be disabled during SW update
${RM_DETECTION_TIMEOUT}  20  # Timeout for all connected RMs detection (in minutes)
${TEST_TIMEOUT}  60  # Test timeout (in minutes)


*** Keywords ***
TC__SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned
    [Documentation]
    ...
    ...  *********************
    ...  3. History of changes
    ...  *********************
    ...
    ...  - 01.06.2017 - initial creation
    ...  - 02.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8071 - add verify BTS proceduralState in Common Test Setup, delete step1
    ...  - 10.07.2018 - https://jira3.int.net.nokia.com/browse/TAT-10834 - add Step 5 Check active alarms
    ...  - 14.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14473 - Added checking if all RMs detected
    ...  - 15.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15166 - Added variable Test_Timeout
    ...  - 27.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15077 - Added DISABLE_RMODS option
    ...  - 28.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15189 - Added support for dual core configurations
    ...  - 30.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-16252 - New group in charge and maintainer for TC
    ...  - 05.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16765 - change RMOD detection method after update (!=NotInstalled)
    ...  - 05.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17398 - TC OWNER changed
    ...  - 17.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17659 - Add 'Check if all radio modules are available' as Precondition
    ...  - 24.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17943 - Moves KW:'Check if all radio modules are available' to ca_swm_general.robot
    ...  - 30.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-19468 - Skips RMOD connected to port 6 of FSMF
    ...  - 05.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19503 - Adds checkong if all RMODs are disabled after disabling all RMODs in step 3
    ...  - 20.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22244 - Changes due to CNI-61110
    ...
    ...  **********************
    ...  4. Test case flowchart
    ...  **********************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/SW_update_uncommissioned_SBTS17.png#
    [Timeout]  ${TEST_TIMEOUT} minutes

    Set Tags  CA-SWM  PHASE-CIT  OWNER-dominik.tredota@nokia.com  AUTHOR-sebastian.burniak@nokia.com  MAINTAINER-wojciech.sikora@nokia.com
    ...  GROUP_IN_CHARGE-WRO_7_Vrf  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923  FEATURE-RP001486_RP000923
    ...  FEATURE-RP001307_RP000923  FEATURE-RP0001145_RP000923

    Preconditions
    Step1: Find Path To SW Package
    Step2: Check SW Versions
    Step3: SW Update
    Step4: Check SW Versions
    Step5: Check Active Alarms
    Step6: Wait For Detection All RMODs


Preconditions
    Log In Frame  Preconditions
    Log Important Message  ... Waiting ${RM_DETECTION_TIMEOUT}min for all RMODs availabilityStatus!=NotInstalled ...
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RM_DETECTION_TIMEOUT} min  20 sec
    ...  Check If All Needed Radio Modules Are Available
    Run Keyword If  ${status}==${FALSE}
    ...  Set Test Blocked  Not all radio modules are available


Step${number_step}: Check SW Versions
    Log Step Header  step${number_step}: Check SW versions
    Check SW Version  ${number_step}
    Run Keyword If  ${SMOD2_EXISTS} and '${number_step}'=='2'
    ...  Validate SW Version Before Update On ESM
    Run Keyword If  ${SMOD2_EXISTS} and '${number_step}'=='4'
    ...  Validate SW Version After Update On ESM


Step1: Find Path To SW Package
    Log Step Header  step1: Find path to SW package
    Find Path To SW Package


Step3: SW Update
    Log Step Header  step3: SW update
    Run Keyword If  ${DISABLE_RMODS}
    ...  Disable All RMODs
    Sleep  120s
    Log  Will now perform software update  console=true
    ${esm_updater}  Run Keyword If  ${SMOD2_EXISTS}
    ...  Run Keyword In Background  Update Software  ${TARGET_SW_PATH}  True  ${SW_UPDATE_TIMEOUT}  alias=esm
    ${sw_update_result}  ${sw_update_msg}  Run Keyword And Ignore Error
    ...  Update Software  ${TARGET_SW_PATH}  True  ${SW_UPDATE_TIMEOUT}
    Run Keyword If  '${sw_update_result}'=='FAIL'
    ...  Set Test Failed  Software update failed: ${sw_update_msg}
    Log  Update procedure ended${\n}Waiting for ping loss  console=true
    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${PING_LOSS_TIMEOUT}
    Run Keyword If  ${ping_loss_status}==${False}
    ...  Set Test Failed  Ping has not been lost within timeout
    Log  Waiting for ping regain  console=true
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${PING_REGAIN_TIMEOUT}
    Run Keyword If  ${ping_regain_status}==${False}
    ...  Set Test Failed  Ping has not been regained within timeout
    Run Keyword If  ${SMOD2_EXISTS}
    ...  Validate ESM Update  ${esm_updater}
    Log  Checking if BTS is stable after update  console=true
    ${bts_stability_check}  Run Keyword And Return Status
    ...  Check If Target Is Stable  ip=${SMOD1['TRS_IP']}
    ${admin_working_state}  sbts_admin.Reset Admin And Infomodel Connection If Broken TAF
    Run Keyword If  ${admin_working_state}
    ...  Log  Admin and infomodel are stable after reset.
    ...  ELSE
    ...  Fail  Admin and/or infomodel failure after reset. Interface reset did not help.  console=true


Step5: Check Active Alarms
    Log Step Header  step5: Check active alarms
    ${critical_alarms1}  Create Dictionary  severity=Major
    ${critical_alarms2}  Create Dictionary  severity=Critical
    ${critical_patterns}  Create List  ${critical_alarms1}  ${critical_alarms2}
    ${alarms_status}  ${alarms_return}  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  critical_patterns=${critical_patterns}
    Run Keyword If  '${alarms_status}'=='FAIL'
    ...  Fail  Major/Critical alarm found.
    Run Keyword If  ${alarms_return}
    ...  Set Test Restriction  Minor alarm found.


Step6: Wait For Detection All RMODs
    Log Step Header  step6: Wait for detection all RMODs
    Log  Will now verify that all expected RMODs were detected  console=true
    RMODs Online Verification


Custom Setup
    Common Test Setup  modules_check=${False}  cells_check=${False}  alarms_check=${True}  expected_bts_status=(?i)NotCommissioned
    ...  tc_name=SWM__SW_download_and_activation__SBTS_to_SBTS_uncomm
    Run Keyword If  ${SMOD2_EXISTS}
    ...  Setup ESM Admin Connections
    Set Test Variable  ${RMODS_TURNED_OFF}  ${False}


Custom Teardown
    Common Test Teardown
    Run Keyword If  ${SMOD2_EXISTS}
    ...  Teardown ESM Admin Connections
    Run Keyword If  ${RMODS_TURNED_OFF}
    ...  _Enable RMODs


Disable All RMODs
    Disable RMODS
    Set Test Variable  ${RMODS_TURNED_OFF}  ${True}
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  3 min  20 sec
    ...  Check If All Needed Radio Modules Are Not Available
    Run Keyword If  ${status}==${FALSE}
    ...  Fail  Not all RMODs are disabled


_Enable RMODs
    hran_file_operations.Setup SCFC Parser  ${COMMISSIONING_PATH}  parser_technology=SBTS
    Setup MSM Admin Connections For Teardown
    RMODs Online Verification

    [Teardown]  Run Keywords
    ...  Teardown MSM Admin Connections
    ...  AND
    ...  Teardown Scf Parser


Setup MSM Admin Connections For Teardown
    ${esm_admin}  Run Keyword And Return Status
    ...  coam.Setup Admin  admin_api_log_dir=${BTS_FILES}/rmods_teardown
    ute_admin_infomodel.Setup Infomodel  address=${SMOD1['TRS_IP']}  port=443  use_ssl=True  admin_api_log_dir=${BTS_FILES}/rmods_teardown
    ${esm_admin_infomodel}  Run Keyword And Return Status
    ...  ute_admin_infomodel.Connect Infomodel


Teardown MSM Admin Connections
    ute_admin_infomodel.Teardown Infomodel
    coam.Teardown Admin


Setup ESM Admin Connections
    ${esm_admin}  Run Keyword And Return Status
    ...  coam.Setup Admin  admin_api_log_dir=${BTS_FILES}  remote_host=${PC_IP2}  alias=esm
    Run Keyword If  ${esm_admin}==${FALSE}
    ...  Set Test Blocked  ESM Admin connection did not start
    ute_admin_infomodel.Setup Infomodel  address=${SMOD1['TRS_IP']}  port=443  use_ssl=True  admin_api_log_dir=${BTS_FILES}/  remote_host=${PC_IP2}
    ...  alias=esm
    ${esm_admin_infomodel}  Run Keyword And Return Status
    ...  ute_admin_infomodel.Connect Infomodel  alias=esm
    Run Keyword If  ${esm_admin_infomodel}==${FALSE}
    ...  Set Test Blocked  ESM Admin infomodel connection did not start


Teardown ESM Admin Connections
    Save Infomodel Log  filename=${BTS_FILES}/IM/InfoModel_ESM_log.ims2  timeout=300  alias=esm
    ute_admin_infomodel.Teardown Infomodel  alias=esm
    coam.Teardown Admin  alias=esm
    Run Keyword And Ignore Error
    ...  Run And Return Rc And Output  mv ssh_forwarder_log ${BTS_FILES}/


Validate ESM Update
    [Arguments]  ${update_task}

    Validate Update Procedure On ESM  ${update_task}
    Validate Ping Regain After Update On ESM


Validate Update Procedure On ESM
    [Arguments]  ${update_task}

    Log  Validate Update Procedure On ESM  console=true
    ${esm_sw_update_result}  ${esm_sw_update_msg}  Run Keyword And Ignore Error
    ...  Collect Keyword Result  ${update_task}
    Run Keyword If  '${esm_sw_update_result}'=='FAIL'
    ...  Set Test Failed  Software update failed: ${esm_sw_update_msg}


Validate Ping Regain After Update On ESM
    Log  Validate Ping Regain After Update On ESM  console=true
    ${esm_ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  remote_host=${PC_IP2}  hostname=${SMOD1['TRS_IP']}  timeout=${PING_REGAIN_TIMEOUT}
    Run Keyword If  ${esm_ping_regain_status}==${FALSE}
    ...  Set Test Failed  ESM ping has not been regained within timeout


Validate SW Version ${when} Update On ESM
    Log  Validate SW Version ${when} Update On ESM  console=true
    ${software_info}  _Get SW Version For SMOD  alias=esm
    ${sw_release_name}  hran_file_operations.Get TargetBD Node Attribute Value  softwareReleaseVersion  ${TARGET_SW_PATH}
    ${sw_number}  Should Match Regexp  ${sw_release_name}  [0-9]{4}_[0-9]{6}_[0-9]{6}T?[0-9]?
    Run Keyword If  '${when}'=='Before'
    ...  Should Not Contain  ${software_info}  ${sw_number}
    ...  ELSE IF  '${when}'=='After'
    ...  Should Contain  ${software_info}  ${sw_number}


RMODs Online Verification
    Run Keyword If  ${RMODS_TURNED_OFF}
    ...  Change Power Outlets State  ${RMODS}  ${True}
    Set Test Variable  ${RMODS_TURNED_OFF}  ${False}
    Run Keyword If  ${SMOD2_EXISTS}
    ...  Wait Until Keyword Succeeds  5 min  30 sec
    ...  Synchronize SMODs TAF
    Wait Until Keyword Succeeds  ${RM_DETECTION_TIMEOUT} min  20 sec
    ...  Check If All Needed Radio Modules Are Available


Check If All Needed Radio Modules Are Not Available
    Assert Parameters For Every  RMOD  availabilityStatus=${NOT_INSTALLED}
    ${scf_rmods}  hran_file_operations.Get Radios
    ${scf_count_rmods}  Get Length  ${scf_rmods}
    ${status_rmod_on_rf6}  Check If RMOD Connected To Port 6 On FSMF
    ${rmod_on_rf6}  Set Variable If  ${status_rmod_on_rf6}  1  0
    ${scf_count_rmods}  Evaluate  ${scf_count_rmods}-${rmod_on_rf6}
    ${runtime_rmods}  Get Ids For All  RMOD
    ${final_status}  Evaluate  ${scf_count_rmods}==len(${runtime_rmods})
    Run Keyword If  ${final_status}
    ...  Log  RMODs are not available  console=true
    ...  ELSE
    ...  Fail  Some of RMODs are still online


Check If All Needed Radio Modules Are Available
    Assert Parameters For No  RMOD  availabilityStatus=${NOT_INSTALLED}
    ${scf_rmods}  hran_file_operations.Get Radios
    ${scf_count_rmods}  Get Length  ${scf_rmods}
    ${status_rmod_on_rf6}  Check If RMOD Connected To Port 6 On FSMF
    ${rmod_on_rf6}  Set Variable If  ${status_rmod_on_rf6}  1  0
    ${scf_count_rmods}  Evaluate  ${scf_count_rmods}-${rmod_on_rf6}
    ${runtime_rmods}  Get Ids For All  RMOD
    ${final_status}  Evaluate  ${scf_count_rmods}==len(${runtime_rmods})
    Run Keyword If  ${final_status}
    ...  Log  All radio modules are available!  console=true
    ...  ELSE
    ...  Fail  Not all radio modules are available


Check If RMOD Connected To Port 6 On FSMF
    ${sm_variant}  Get SM Variant
    Return From Keyword If  '${sm_variant[0]}'!='FSMF'  ${FALSE}
    ${scf}  Parse Xml  ${COMMISSIONING_PATH}
    ${cablink_obj}  Get Elements  ${scf}  .//managedObject[@class="com.nokia.srbts.eqm:CABLINK"]
    FOR  ${cablink}  IN  @{cablink_obj}
        ${is_rmod_second_endpoint_dn}  Run Keyword And Return Status
        ...  Element Text Should Match  ${cablink}  *RMOD-*  .//p[@name="secondEndpointDN"]
        ${is_smod_firs_endpoint_dn}  Run Keyword And Return Status
        ...  Element Text Should Match  ${cablink}  *SMOD-*  .//p[@name="firstEndpointDN"]
        ${is_port_6}  Run Keyword If  ${is_rmod_second_endpoint_dn} and ${is_smod_firs_endpoint_dn}
        ...  Run Keyword And Return Status
        ...  Element Text Should Match  ${cablink}  6  .//p[@name="firstEndpointPortId"]
        Return From Keyword If  ${is_port_6}  ${TRUE}
    END

    [Return]  ${FALSE}


TC Setup
    Custom Setup


TC Teardown
    Custom Teardown
