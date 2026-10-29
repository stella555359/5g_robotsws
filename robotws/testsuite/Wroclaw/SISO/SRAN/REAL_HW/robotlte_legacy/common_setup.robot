# robocop: off
*** Settings ***
Documentation  Suite description
...  Author:  piotr.korczynski@nokia.com
...  Maintainer:  Author

Library  Collections
Library  OperatingSystem
Library  Process
Library  SSHLibrary
Library  String
Library  taf.sbts.oam.coam.admin  WITH NAME  admin
Library  ute_admin_infomodel    WITH NAME    admin_im
Library  taf.fdsw.rc  WITH NAME  rc
Library  taf.ul.oam_kpi_calculations  WITH NAME  kpi
Resource  ./variables.robot
#Resource  ./sw_mngt.robot
#Resource  ./site_operations.robot
#Resource  ./site_verifications.robot
#Resource  ./sw_upgrade_path.robot
#Resource  ./pmax.robot
#Resource  ./rtwp.robot
#Resource  ./lte_rat_reset.robot
#Resource  ./nr_rat_reset.robot
#Resource  ./sfp_monitoring.robot
#Resource  ./check_ret_status.robot
#Resource  ./ALD_cs.robot
#Resource  ./factory_sw.robot
#Resource  ./delta_commissioning.robot
#Resource  ./radio_operations.robot
#Resource  ./bbpool_allocation.robot
#Resource  ./recovery_counter.robot
#Resource  ./startup_with_RF_delayed_startup.robot
#Resource  ./24H_Stability_without_reset.robot
#Resource  ./memory_consumption.robot
#Resource  ./SiSo_L3_Call.robot
#Resource  ./Test_Cases/EAC_cs.robot
#Resource  ./Test_Cases/PIMC_cs.robot
#Resource  ./Test_Cases/RFV_cs.robot
#Resource  ./Test_Cases/slim_carrier.robot
#Resource  ./Test_Cases/Parameter_Commissioning.robot
#Resource  ./Test_Cases/Optical_Hot_remove/lg_hr_infomodel.robot
#Resource  ./Test_Cases/Optical_Hot_remove/lg_hr_keywords_new.robot
#Resource  ./Test_Cases/Optical_Hot_remove/lg_hr_switch.robot
#
#Resource  ./Test_Cases/check_linkSpeed_FHS.robot
Library  ./factory_sw_download.py
Library  ./rf_alarms_operations.py

Variables    ./legacy_variables.py

*** Variables ***
${GLO_REFERENCE_SW_CONFIG_FILE}  ${EXEC_DIR}/testsuite/WMP/GVe/Wroclaw/AiFSiteS/resources/swconfig
${FORCE_RESET_CONFIGURATION}  False
${UUF_REPORT}  False
${ACTIVE_STARTUP_VERDICT}=   False

*** Keywords ***
Return Paths To SW Packages
  [Arguments]  ${enb_active_sw}  ${sw_file_path}
  ${sw_name_split}=  Split String  ${enb_active_sw}  _  1
  ${sw_release}=  Set Variable  ${sw_name_split[0]}
  ${sw_technology}=  Replace String Using Regexp  ${sw_release}  \\d+[A-Z]*  ${EMPTY}
  ${num_part_of_enb_build}=  Remove String  ${sw_name_split[1]}  T1  T2
  ${s1}  ${sw_build_main}=  Run Keyword And Ignore Error  Find File In Path Matching Regex  ${sw_file_path}
  ...  regexp=(${sw_release}|${sw_technology}00)_${num_part_of_enb_build}((?!T1|T2).)*$
  ${s2}  ${sw_build_t1}=  Run Keyword And Ignore Error  Find File In Path Matching Regex  ${sw_file_path}
  ...  regexp=(${sw_release}|${sw_technology}00)_${num_part_of_enb_build}\.*T1\.*.zip
  ${s3}  ${sw_build_t2}=  Run Keyword And Ignore Error  Find File In Path Matching Regex  ${sw_file_path}
  ...  regexp=(${sw_release}|${sw_technology}00)_${num_part_of_enb_build}\.*T2\.*.zip
  [Teardown]  Log  Base package presence: ${s1} ${\n}T1 package presence: ${s2} ${\n}T2 package presence: ${s3}
  [Return]  ${sw_build_main}  ${sw_build_t1}  ${sw_build_t2}

Find File In Path Matching Regex
  [Arguments]  ${dir_path}  ${regex}
  ${file_list}=  OperatingSystem.List Files In Directory  ${dir_path}
  ${filtered_file_list}=  Get Matches  ${file_list}  ${regex}
  ${file_path}=  OperatingSystem.Join Path  ${dir_path}  ${filtered_file_list[0]}
  [Return]  ${file_path}

#TC Repetition Loop Start
#  [Arguments]  ${repetition}  ${ITERATION}
#  Set Test Variable  ${ITERATION}  ${ITERATION}
#  Run Keyword If  ${repetition}  Log  \n||========================================================  console=True
#  Run Keyword If  ${repetition}  Log  \n${TEST NAME} repetition no: ${ITERATION} started  console=True
#  ${loop_log_path}=  Set Variable If  ${REPETITION}  ${TEST_LOGS_PATH}/${ITERATION}  ${TEST_LOGS_PATH}
#  [Return]  ${loop_log_path}
#
#TC Repetition Loop Stop
#  [Arguments]  ${repetition}  ${ITERATION}  ${TC_STATUS}=PASS
#  Run Keyword If
#  ...  ${repetition}
#  ...  Log
#  ...  \n${TEST NAME} repetition no: ${ITERATION} finished. Result = ${TC_STATUS}
#  ...  console=True
#  Run Keyword If  ${repetition}  Log  \n|||====================================================|||  console=True

Create Alarm List

  ${additional_alarm_exist}=  Run Keyword And Return Status  Should Not Be Empty  ${ADDITIONAL_ADMIN_ALLOWED_ALARMS}
  ${combined_alarm_list_1}=  Run Keyword If  ${additional_alarm_exist}
  ...  Combine Lists  ${GLO_ADMIN_ALLOWED_ALARMS}  ${ADDITIONAL_ADMIN_ALLOWED_ALARMS}
  Run Keyword If  ${additional_alarm_exist}  Set Suite Variable  ${GLO_ADMIN_ALLOWED_ALARMS}  ${combined_alarm_list_1}
  Remove Duplicates  ${GLO_ADMIN_ALLOWED_ALARMS}

Remove HWF File
  Set Test Variable  &{GLO_ADDITIONAL_RD_FLAGS}  0x190030=0  0x4F0214=0  description=remove HWF
  FOR  ${node_id}  IN  @{cfg.active_bts_list}
    ${bts_sm}=  Get From Dictionary  ${cfg.NODES['${node_id}']}  primary_sm
    ${bts_type}=  Get From Dictionary  ${cfg.NODES['${node_id}']}  bts_alias_type
    BTS Prepare Mandatory Flags  ${node_id}  ${bts_type}
  END

Modify Startup Site Reset Time
    ${extended_site_reset}=  Evaluate  ${CONFIGURATION_STARTUP_TIMEOUT}+150
    Set Variable    ${CONFIGURATION_STARTUP_TIMEOUT}  ${extended_site_reset}

Verify RU Product Code
  FOR  ${fr_id}  IN  @{cfg.RF_INFO}
    ${fr_id_bts_id}  ${ru_product_code}=  Get RU Node Product Code  ${fr_id}
  ${tl_status}=  Run Keyword And Return Status    Variable Should Exist    ${TL}
  ${object}=  Run Keyword If    ${tl_status}  Find Init Object Using Attribute Value  ${TL}  ${fr_id}
    Run Keyword If  "${object.product_code}" == "None"  Run Keywords
    ...  Log  !!! There is no reference value in testline configuration file. Modify it.  console=True  level=WARN
    ...  AND  Continue For Loop
    Run Keyword And Continue On Failure  Should Be Equal As Strings
    ...  ${object.product_code}
    ...  ${ru_product_code}
    ...  Product Code for ${fr_id} is wrong!
    ...  values=True
  END

Verify HW Node state
  [Arguments]  ${cfg}  ${bts_id}  ${timeout}=${HARDWARE_DETECTION_TIME}
  ${sm_status}=  Run Keyword And Continue On Failure  Admin HW Check
  ...  class_name=SMOD
  ...  hw_list=${cfg.NODES['${bts_id}']['scf_hw_sm_list']}
  ...  parameters1=operationalState=regex"[Ee]nabled"
  ...  parameters2=availabilityStatus=regex"[Dd]egraded"
  ...  timeout=${timeout}
  ...  alias=${bts_id}
  ${bbmod_status}=  Run Keyword And Continue On Failure  Admin HW Check
  ...  class_name=BBMOD
  ...  hw_list=${cfg.NODES['${bts_id}']['scf_hw_bbmod_list']}
  ...  parameters1=operationalState=regex"[Ee]nabled"
  ...  parameters2=availabilityStatus=regex"[Dd]egraded"
  ...  timeout=${timeout}
  ...  alias=${bts_id}
  ${fhs_status}=  Run Keyword And Return Status
  ...  Check FHS List Status
  ...  ${cfg.NODES['${bts_id}']['scf_hw_fhs_list']}
  ...  ${timeout}
  ...  ${bts_id}
  ${rmod_status}=  Run Keyword And Continue On Failure  Admin HW Check
  ...  class_name=RMOD
  ...  hw_list=${cfg.NODES['${bts_id}']['scf_hw_fr_list']}
  ...  parameters1=operationalState=regex"[Ee]nabled|[Dd]isabled", buildVersion!=empty
  ...  parameters2=availabilityStatus=regex"[Dd]egraded"
  ...  timeout=${timeout}
  ...  alias=${bts_id}
  ${hw_status}=  Set Variable If  ${sm_status} and ${bbmod_status} and ${rmod_status} and ${fhs_status}  True  False
  ${node_hw_state}=  Set Variable If  "False" in "${hw_status}"  False  True
  [Return]  ${hw_status}

Perform Multinode Template File Commissioning
  [Arguments]  ${ignore_errors}=False  ${path}=regular
  ${active_bts_list}=  Get Dictionary Keys  ${cfg.NODES}
  FOR  ${bts_id}  IN  @{active_bts_list}
    Perform Template File Commissioning  ${bts_id}  ${ignore_errors}  ${path}
  END

Perform Template File Commissioning
  [Arguments]  ${bts_id}  ${ignore_errors}=False  ${path}=regular
  Log  \nBTS template commissioning procedure on bts_id node=${bts_id} started  console=True
  Log
  ...  \nSource File = ${cfg.NODES['${bts_id}']['scf_file_path']}.\nProcedure Parameters: Ignore Errors = ${ignore_errors}, Branch Path = ${path}
  ...  console=True
  Run Keyword And Ignore Error  Wait Sw Update Possible
  ...  bts_ready=True
  ...  readiness_timeout=900
  ...  timeout=1000
  ...  connection=${bts_id}
  ${result}=  Run Keyword And Continue On Failure  admin.Perform Commissioning  ${bts_id}  ${cfg.NODES['${bts_id}']['scf_file_path']}
  ...  skip_parameter_relation_errors=${ignore_errors}
  ...  should_activate=True
  ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
  ...  alias=${bts_id}
  Run Keyword And Ignore Error  admin.Wait Sw Update Possible
  ...  bts_ready=True
  ...  readiness_timeout=150
  ...  timeout=200
  ...  connection=${bts_id}
  ${asirmod_id_list}=  admin.Get Ids For All  ASIRMOD  connection=${bts_id}
  ${asirmod_exist}=  Run Keyword And Return Status  Should Not Be Empty  ${asirmod_id_list}
  Run Keyword If  ${asirmod_exist}  CM Perform ASIRMOD Recommissioning  ${bts_id}  ${cfg.NODES['${bts_id}']['scf_file_path']}
  [Teardown]    Logging With Timestamp
  ...  BTS template commissioning procedure on bts_id node=${bts_id} finished.
  [Return]  ${result}

#Perform ASIRMOD Recommissioning
#  [Documentation]
#  ...  Perform full commissioning of ASIR hub
#  ...  scf name ${cfg.NODES['${bts_id}']['scf_file_path']}_ASIR.xml
#  ...  *AUTHOR*
#  ...  przemyslaw.kempa@nokia.com
#  [Arguments]  ${bts_id}  ${recommissioning_scf_file_path}
#  ${rf_sn_list}=  Get From Dictionary  ${cfg}  RF_INFO
#  ${all_sn_asirmod}=  Create List
#  FOR  ${serial_number}  IN  @{rf_sn_list}
#    ${asirmod_status}=  Run Keyword And Return Status
#    ...  Should Match Regexp
#    ...  ${cfg['RF_INFO']['${serial_number}']['scf_dist_name_primary']}
#    ...  /ASIRMOD-
#    Run Keyword If  ${asirmod_status}  Append To List  ${all_sn_asirmod}  ${serial_number}
#  END
#  PDU Switch On Device Lists  ${all_sn_asirmod}
#  Wait Until Keyword Succeeds
#  ...  7min
#  ...  1
#  ...  admin.Assert No
#  ...  ASIRMOD
#  ...  availabilityStatus=regex"(?i)not\\s?installed"
#  ...  timeout=60
#  ...  connection=${bts_id}
#  ${asirmod_status}=  Run Keyword And Return Status
#  ...  admin.Assert Every
#  ...  ASIRMOD
#  ...  availabilityStatus=regex"(?i)Off\\s?line"
#  ...  timeout=60
#  ...  connection=${bts_id}
#  Run Keyword Unless
#  ...  ${asirmod_status}
#  ...  admin.Assert Every
#  ...  ASIRMOD
#  ...  operationalState=regex"(?i)enabled"
#  ...  timeout=60
#  ...  connection=${bts_id}
#  Run Keyword And Ignore Error  Asir Reset Configuration  alias=${bts_id}
#  Run Keyword And Ignore Error
#  ...  admin.Assert Every
#  ...  ASIRMOD
#  ...  availabilityStatus=regex"(?i)Not.?Installed"
#  ...  timeout=60s
#  ...  connection=${bts_id}
#  Wait Until Keyword Succeeds
#  ...  4min
#  ...  1
#  ...  admin.Assert No
#  ...  ASIRMOD
#  ...  availabilityStatus=regex"(?i)not\\s?installed"
#  ...  connection=${bts_id}
#  ${asir_scf_file_path}=  Replace String  ${recommissioning_scf_file_path}  .xml  _ASIR.xml
#  Asir Perform Commissioning  ${asir_scf_file_path}  alias=${bts_id}
#  admin.Reset Admin  connection=${bts_id}

Reset Node Configuration
  [Arguments]  ${bts_id}  ${fdsw_debug_logs}=${False}
    ${fdsw_debug_logs_level}=  Set Variable If  ${fdsw_debug_logs}
  ...  DEBUG
  ...  INFO
    Logging With Timestamp
  ...  BTS Configuration Reset procedure on bts_id node=${bts_id} started.
  ${secondary_sm}=  Get Variable Value  ${CFG.NODES['${bts_id}']['secondary_sm']}  ${False}
  ${slave_sm_ip}=  Run Keyword If  '${secondary_sm}'!='None'
  ...  Get From Dictionary  ${CFG.NODES['${bts_id}']}  secondary_sm_vm_ip_LMP_address
  ${slave_sm_ip}=  Set Variable If  '${secondary_sm}'!='None'  ${slave_sm_ip}  ${None}
  ${reset_configuration_status}=  Run Keyword And Continue On Failure   rfrl_reset_conf.Reset Bts Configuration
  ...  connection=${bts_id}
  ...  secondary_remote_host=${slave_sm_ip}
  ...  fdsw_log_level=${fdsw_debug_logs_level}
  ...  fdsw_log_dir_path=${TEST_LOGS_PATH}BTSFiles/${bts_id}/
  ...  reset_admin_connection=True
  ...  wait_for_admin_connection=True
  ...  wait_for_admin_connection_timeout=${RESET_CONFIGURATION_STARTUP_TIMEOUT}
  ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds  ${RESET_CONFIGURATION_STARTUP_TIMEOUT} sec  25 sec
    ...  admin.Reset Admin  connection=${bts_id}
    Logging With Timestamp
  ...  BTS Configuration Reset procedure on bts_id node=${bts_id} finished.
    Logging With Timestamp
  ...  Wait for BTS reset
  ${reset_state}=  Run Keyword And Continue On Failure  BTS Is Resetting  ${bts_id}  timeout=240 sec
    Logging With Timestamp
  ...  BTS reset finished
  [Teardown]  Run Keywords
  ...  Run Keyword And Ignore Error  rc.Teardown  connection=FDSW_PRIMARY_CONNECTION
  ...  AND  Run Keyword And Ignore Error  rc.Teardown  connection=FDSW_SECONDARY_CONNECTION

# BTS Unavailable
#  [Arguments]  ${node}  ${timeout}=120
#  wait until keyword succeeds  ${timeout}  1
#  ...  Run keyword and expect error  *
#  ...  BTS Address Is Pingable  192.168.255.1
#
BTS Is Resetting
  [Arguments]  ${node}  ${timeout}=120
  Run Keyword And Continue On Failure  admin.Assert No
  ...  BTS
  ...  proceduralState=OnAir
  ...  alias=${node}
  ...  timeout=${timeout}

# CM.CM BTS Admin Not Available
#  [Arguments]  ${node}  ${timeout}=120
#  BTS Is Resetting  ${node}
#  Wait Until Keyword Succeeds  120  5  Run Keyword And Return Status  Assert No  BTS  alias=${node}

# BTS Available
#  [Arguments]  ${node}  ${timeout}=${CONFIGURATION_SWUPDATE_TIMEOUT}
#  wait until keyword succeeds  ${timeout}  10  Verify Mrbts State  ${node}  OnAir

Check Node FRs status
  [Arguments]  ${bts_id}  ${timeout}=600
  Log  \nChecking FR availability\n  console=True
  FOR  ${fr}  IN  @{cfg.NODES['${bts_id}']['scf_hw_fr_list']}
    ${rmod_status}=  Run Keyword And Return Status  admin.Assert Any
    ...  class_name=RMOD
    ...  parameters=serialNumber=${fr}
    ...  timeout=60
    ...  alias=${bts_id}
    ${class}=  Set Variable If  ${rmod_status}  RMOD  ASIRMOD
    Run Keyword And Continue On Failure  Run Keywords
    ...  admin.Assert Any
    ...  class_name=${class}
    ...  parameters=operationalState=regex"(?i)enabled", administrativeState=regex"(?i)unlocked", serialNumber=${fr}
    ...  timeout=${HARDWARE_DETECTION_TIME}
    ...  alias=${bts_id}
    ...  AND
    ...  Run Keyword And Return Status
    ...  admin.Assert No
    ...  class_name=${class}
    ...  parameters=availabilityStatus=regex"\[Dd\]egraded"
    ...  timeout=${HARDWARE_DETECTION_TIME}
    ...  alias=${bts_id}
  END
  [Teardown]  Log  FR status = ${KEYWORD STATUS}

Admin HW Check
  [Arguments]  ${class_name}  ${hw_list}
  ...  ${parameters1}=operationalState=regex"\[Ee\]nabled", administrativeState=regex"\[Uu\]nlocked"
  ...  ${parameters2}=availabilityStatus=regex"\[Oo\]nline"
  ...  ${timeout}=5s  ${alias}=default
  ${detected_list}=  Create List
  ${not_detected_list}=  Create List
  FOR  ${sm_id}  IN  @{hw_list}
    ${assert_parameters1}=  Set Variable  ${parameters1}, serialNumber=${sm_id}
    ${assert_parameters2}=  Set Variable  ${parameters2}, serialNumber=${sm_id}
    ${class_name_temp}=  Set Variable  ${class_name}
    ${ASIR}=  Run Keyword If  "${class_name}"=="RMOD"  Get From Dictionary  ${cfg['RF_INFO']['${sm_id}']}  scf_dist_name_primary
    ${ASIRMOD_status}=  Run Keyword And Return Status  Should Match Regexp  ${ASIR}  /ASIRMOD-
    ${class_name}=  Set Variable If  ${ASIRMOD_status}  ASIRMOD  ${class_name_temp}
    ${status}=  Run Keyword And Return Status  Run Keywords
    ...  admin.Assert Any
    ...  class_name=${class_name}
    ...  parameters=${assert_parameters1}
    ...  timeout=${timeout}
    ...  alias=${alias}  AND
    ...  Run Keyword And Return Status  admin.Assert No
    ...  class_name=${class_name}
    ...  parameters=${assert_parameters2}
    ...  timeout=${timeout}
    ...  alias=${alias}
    Run Keyword If  ${status}  Append To List  ${detected_list}  ${sm_id}
    ...  ELSE  Append To List  ${not_detected_list}  ${sm_id}
    Run Keyword And Continue On Failure  Should Be True  ${status}
    ${class_name}=  Set Variable  ${class_name_temp}
  END
  Run Keyword If  ${not_detected_list}  Log  Not Detected ${class_name} list: ${not_detected_list}.  console=True
  Run Keyword If  ${detected_list}  Log  Detected ${class_name} list: ${detected_list}.  console=True


Execute Recommissioning On Every Node
    [Arguments]      ${test_logs_path}
  FOR  ${node}  IN  @{cfg.active_bts_list}
    Perform Template File Commissioning  ${node}  False  previous
    Verify BTS State  ${node}  ${CONFIGURATION_STARTUP_TIMEOUT}
    Verify Unexpected And Historical Alarms  alias=${node}
  END

Execute Recommissioning With Configuration Reset On Every Node
  Set Tags     AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynski@nokia.com
  Common Test Setup
  Logging With Timestamp
  ...  message=Execute Recommissioning On Every Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  FOR  ${bts}  IN  @{CFG.active_bts_list}
    Reset Node Configuration  ${bts}  ${CUSTOM_FDSW_DEBUG_LOGS}
    Perform Template File Commissioning  ${bts}  False  regular
    Verify BTS State  ${bts}  ${CONFIGURATION_STARTUP_TIMEOUT}
    Verify Unexpected And Historical Alarms  alias=${bts}
  END
  [Teardown]    Common Test Teardown


Execute Site Reset On Every Node
  Set Tags     AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynski@nokia.com
  Common Test Setup
  Logging With Timestamp
  ...  message=Execute Site Reset On Every Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  FOR  ${bts}  IN  @{cfg.active_bts_list}
    Execute Reset On Node  ${bts}
    CM BTS Admin Not Available
    ...  node=${bts}
    ...  timeout=120
    Verify BTS State  ${bts}  ${CONFIGURATION_STARTUP_TIMEOUT}
    Verify Startup Parameters  ${test_logs_path}  ${bts}
    Verify Unexpected And Historical Alarms  alias=${bts}
  END
  [Teardown]    Common Test Teardown

Execute Parallel Site Reset On Every Node
  Set Tags     AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynski@nokia.com
  Common Test Setup
  Logging With Timestamp
  ...  message=Execute Parallel Site Reset On Every Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  FOR  ${bts}  IN  @{cfg.active_bts_list}
    Execute Reset On Node  ${bts}
    CM BTS Admin Not Available
    ...  node=${bts}
    ...  timeout=120
  END
  FOR  ${bts}  IN  @{cfg.active_bts_list}
    Verify BTS State  ${bts}  ${CONFIGURATION_STARTUP_TIMEOUT}
  END
  FOR  ${bts}  IN  @{cfg.active_bts_list}
    Verify Startup Parameters  ${test_logs_path}  ${bts}
  END
  FOR  ${bts}  IN  @{cfg.active_bts_list}
    Verify Unexpected And Historical Alarms  alias=${bts}
  END
  [Teardown]    Common Test Teardown



Execute Block BTS On Every Node
  Set Tags     AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynski@nokia.com
  Common Test Setup
  Logging With Timestamp
  ...  message=Execute Recommissioning On Every Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  FOR  ${bts}  IN  @{cfg.active_bts_list}
    Execute Block BTS On Node  ${bts}
    Check MRBTS Blocking State  ${bts}  Blocked
    Verify SBTS Mrbts State Not OnAir  ${bts}  200
    Verify Whether FID50 Present  ${bts}
    Sleep  6s  msg=Waiting. User cannot click Unblock in WebEM for 6 seconds.
    Execute Unblock BTS On Node  ${bts}
    Check MRBTS Blocking State  ${bts}  Unblocked
    Verify BTS State  ${bts}  ${CONFIGURATION_STARTUP_TIMEOUT}
    Verify Unexpected And Historical Alarms  alias=${bts}
  END
  [Teardown]    Common Test Teardown


Execute Reset On Node
  [Arguments]  ${node}
  Log  \nSite Reset on bts_id node=${node} started  console=True
  admin.reset_site  alias=${node}
  Log  Site Reset on bts_id node=${node} finished  console=True

Execute Block BTS On Node
  [Arguments]  ${node}
  Log  \nBlock BTS on bts_id node=${node} started  console=True
  ${bts_id}=  admin.Get Id For Current  BTS  alias=${node}
  admin.block  alias=${node}  timeout=240
  Log  Block BTS on bts_id node=${node} finished  console=True

Execute Unblock BTS On Node
  [Arguments]  ${node}
  Log  \nUnblock BTS on bts_id node=${node} started  console=True
  ${bts_id}=  admin.Get Id For Current  BTS  alias=${node}
  admin.unblock  alias=${node}  timeout=600
  Log  Unblock BTS on bts_id node=${node} finished  console=True

Force Recommissioning With Current Branch On Every Node
  FOR  ${node}  IN  @{cfg.active_bts_list}
    Perform Template File Commissioning  ${node}  True
    Verify BTS State  bts=${node}  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
    Verify Alarms  alias=${node}
  END

Verify BTS State
  [Arguments]  ${bts}  ${timeout}=${HARDWARE_DETECTION_TIME}
#  Admin Get BTS Info Into Dictionary  ${node}
  Verify HW Node state  ${CFG}  ${bts}  ${timeout}
  Check MRBTS Procedural State  ${bts}  OnAir  ${timeout}
  Wait Until Keyword Succeeds    ${CONFIGURATION_STARTUP_TIMEOUT}  20
  ...  STATE Verify BTS states
  ...  node_id=${bts}
  ...  expected_BTS_status=OnAir
  ...  HW_check=${TRUE}
  ...  cells_check=${TRUE}
  ...  scf_check=${FALSE}
  ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
#  Verify BTS RAT state  ${node}  ${timeout}
#  Verify Admin Every LTE Cell State  ${node}  ${timeout}
#  Verify Admin Every WCDMA Cell State  ${node}  ${timeout}
#  Verify Admin Every GSM Cell State  ${node}  ${timeout}
#  Verify Admin Every NR Cell State  ${node}  ${timeout}
  [Teardown]  Set Test Variable  ${BTS_state}  ${KEYWORD_STATUS}

Verify All Cells OnAir
  [Arguments]  ${node}  ${timeout}=200 sec
  Verify Admin Every LTE Cell State  ${node}  ${timeout}
  Verify Admin Every WCDMA Cell State  ${node}  ${timeout}
  Verify Admin Every GSM Cell State  ${node}  ${timeout}
  Verify Admin Every NR Cell State  ${node}  ${timeout}

Verify BTS RAT state
  [Arguments]  ${node}  ${timeout}=900
  Log  \nRAT state on bts_id node=${node} verification started  console=True
  Run Keyword And Continue On Failure
  ...  Wait Until Keyword Succeeds
  ...  ${timeout}
  ...  5
  ...  Check Every RAT ALL_Enable State
  ...  ${node}
  ...  ${timeout}
  [Teardown]  Log  RAT state on bts_id node=${node} verification finished. Result = ${KEYWORD STATUS}  console=True

Check Every RAT ALL_Enable State
  [Arguments]  ${node}  ${timeout}
  Admin Get BTS Info Into Dictionary  ${node}  ${timeout}
  ${lte_status}  ${lte_state}=  Run Keyword And Ignore Error  Admin Dictionary Verify BTS LTE State  ${node}
  ${wcdma_status}  ${wcdma_state}=  Run Keyword And Ignore Error  Admin Dictionary Verify BTS WCDMA State  ${node}
  ${gsm_status}  ${gsm_state}=  Run Keyword And Ignore Error  Admin Dictionary Verify BTS GSM State  ${node}
  ${nr_status}  ${nr_state}=  Run Keyword And Ignore Error  Admin Dictionary Verify BTS NR State  ${node}
  Should Be True
  ...  '${lte_status}'=='PASS' and '${wcdma_status}'=='PASS' and '${gsm_status}'=='PASS' and '${nr_status}'=='PASS'
  ...  msg= At least one RAT Stats is incorrect:\nLTE: ${lte_state}\nWCDMA: ${wcdma_state}\nGSM: ${gsm_state}\nNR: ${nr_state}

Check MRBTS Procedural State
  [Arguments]  ${node}  ${state}=OnAir  ${timeout}=900
  Log  \nMRBTS Procedural state = ${state} on bts_id node=${node} verification started  console=True
  Run Keyword And Continue On Failure
  ...  Wait Until Keyword Succeeds
  ...  ${timeout}
  ...  5
  ...  Verify Mrbts State
  ...  ${node}
  ...  ${state}
  [Teardown]  Log  MRBTS Procedural state = ${state} on bts_id node=${node} verification finished. Result = ${KEYWORD STATUS}  console=True

Check MRBTS Blocking State
  [Arguments]  ${node}  ${state}=Blocked  ${timeout}=900
  Log  \nMRBTS Blocking state = ${state} on bts_id node=${node} verification started  console=True
  Run Keyword And Continue On Failure  admin.Assert Any
  ...  BTS
  ...  blockingState=${state}
  ...  timeout=${timeout}
  ...  alias=${node}
  [Teardown]  Log  MRBTS Blocking state = ${state} on bts_id node=${node} verification finished. Result = ${KEYWORD STATUS}  console=True

Admin Dictionary Verify BTS LTE State
  [Arguments]  ${node}
  Return From Keyword If  not ${cfg['NODES']['${node}']['scf_lte']}
  ${rat_state}=  Get From Dictionary  ${bts_info['ratState']}  lte
  ${proper_state}=  Generate Proper RAT State For Node  lte  ${node}
  Should Be True  '${rat_state}' == '${proper_state}'
  Log  \n${node} - LTE status = ${rat_state}
  [Return]  ${rat_state}

Admin Dictionary Verify BTS WCDMA State
  [Arguments]  ${node}
  Return From Keyword If  not ${cfg['NODES']['${node}']['scf_wcdma']}
  ${rat_state}=  Get From Dictionary  ${bts_info['ratState']}  wcdma
  ${return_status}=  Should Be True  '${rat_state}' == 'ALL_ENABLED'
  Log  \n${node} - WCDMA status = ${rat_state}
  [Return]  ${rat_state}

Admin Dictionary Verify BTS GSM State
  [Arguments]  ${node}
  Return From Keyword If  not ${cfg['NODES']['${node}']['scf_gsm']}
  ${rat_state}=  Get From Dictionary  ${bts_info['ratState']}  gsm
  ${return_status}=  Should Be True  '${rat_state}' == 'ALL_ENABLED'
  Log  \n${node} - GSM status = ${rat_state}
  [Return]  ${rat_state}

Admin Dictionary Verify BTS NR State
  [Arguments]  ${node}
  Return From Keyword If  not ${cfg['NODES']['${node}']['scf_nr']}
  ${rat_state}=  Get From Dictionary  ${bts_info['ratState']}  nr
  ${proper_state}=  Generate Proper RAT State For Node  nr  ${node}
  Should Be True  '${rat_state}' == '${proper_state}'
  Log  \n${node} - NR status = ${rat_state}
  [Return]  ${rat_state}

Admin Get BTS Info Into Dictionary
  [Arguments]  ${node}  ${timeout}=${HARDWARE_DETECTION_TIME}
  ${mrbts_info}=  Create Dictionary  &{EMPTY}
  ${bts_info}=  admin.Get Bts Info  alias=${node}  timeout=${timeout}
  Set Test Variable  ${BTS_INFO}  ${bts_info}
  [Return]  ${bts_info}

Verify Multi BTS State
  [Arguments]  ${timeout}=600
  FOR  ${bts_id}  IN  @{cfg.active_bts_list}
    Verify BTS State  ${bts_id}  ${timeout}
  END

Verify Mrbts State
  [Arguments]  ${node}  ${state}
  ${mrbts_state}=  admin.Get MRBTS State  alias=${node}
  ${return_status}=  Should Be True  '${mrbts_state}' == '${state}'
  [Teardown]  Log  \nMRBTS state = ${mrbts_state}  console=True

Verify SBTS Mrbts State Not OnAir
  [Arguments]  ${node}  ${timeout}=300
  ${return_status}=  Run Keyword And Continue On Failure
  ...  admin.Assert No  BTS  proceduralState=OnAirDone  timeout=${timeout}  alias=${node}
  [Teardown]  Log  \nMRBTS state = ${return_status}  console=True

Verify Admin Every LTE Cell State
  [Arguments]  ${node}  ${timeout}=30
  Return From Keyword If  not ${cfg['NODES']['${node}']['scf_lte']}
  Log  \nEvery LTE Cell state on bts_id node=${node} verification started  console=True
  FOR  ${cell_id}  IN  @{CFG['NODES']['${node}']['LNCEL'].keys()}
        ${affected_by_rm}=  Check CELL Affected By Any RMs Energy Efficiency Feature  ${cell_id}  lte  ${node}
        Continue For Loop If  ${affected_by_rm}
        ${cell_distname}=    Get Cell Id By Configuration Id    LTE    ${cell_id}    alias=${node}
        ${cell_info}=    Get Cell Specific Info    cell_id=${cell_distname}    timeout=${timeout}    connection=${node}
        ${dict_key_assert}=    Evaluate    $cell_info['energySavingState'].lower()
        ${parameter_key_assert}=    Get From Dictionary    ${LEGACY_CELL_ENERGY_SAVING_STATES_REQUIREMENTS['${dict_key_assert}']}    assert
        ${parameter_key_assert_no}=    Get From Dictionary    ${LEGACY_CELL_ENERGY_SAVING_STATES_REQUIREMENTS['${dict_key_assert}']}   assert_no
#        ${CELL_ENERGY_SAVING_STATES_REQUIREMENTS["${cell_info['energySavingState']}".lower()]["assert"]}
    Run Keyword And Continue On Failure  admin.Assert
    ...  class_name=LNCEL
    ...  id=${cell_distname}
    ...  parameters=${parameter_key_assert}
    ...  timeout=${timeout}
    ...  alias=${node}
    Run Keyword And Continue On Failure
    ...  admin.Assert No
    ...  class_name=LNCEL
    ...  parameters=id=${cell_distname}, ${parameter_key_assert_no}
    ...  timeout=${timeout}
    ...  alias=${node}
  END
  [Teardown]  Run Keyword If  ${cfg['NODES']['${node}']['scf_lte']}
  ...  Log  LTE cell state on bts_id node=${node} verification finished. Result = ${KEYWORD STATUS}  console=True

Verify Admin Every WCDMA Cell State
  [Arguments]  ${node}  ${timeout}=30
  Return From Keyword If  not ${cfg['NODES']['${node}']['scf_wcdma']}
  Log  \nEvery WCDMA Cell state on bts_id node=${node} verification started  console=True
  ${cell_state}=  Run Keyword And Continue On Failure
  ...  admin.Assert Every
  ...  WNCEL
  ...  operationalState=regex"(?i)Enabled", usageState=regex"(?i)Active"
  ...  timeout=${timeout}
  ...  alias=${node}
  ${av_cell_state}=  Run Keyword And Continue On Failure  Run Keyword And Return Status  admin.Assert No
  ...  class_name=WNCEL
  ...  parameters=availabilityStatus=regex"[Dd]egraded"
  ...  timeout=${timeout}
  ...  alias=${node}
  [Teardown]  Run Keyword If  ${cfg['NODES']['${node}']['scf_wcdma']}
  ...  Log  WCDMA cell state = OnAirDone on bts_id node=${node} verification finished. Result = ${KEYWORD STATUS}  console=True

Verify Admin Every GSM Cell State
  [Arguments]  ${node}  ${timeout}=30
  Return From Keyword If  not ${cfg['NODES']['${node}']['scf_gsm']}
  Log  \nEvery GSM Cell state on bts_id node=${node} verification started  console=True
  ${cell_state}=  Run Keyword And Continue On Failure
  ...  admin.Assert Every
  ...  GNCEL
  ...  operationalState=regex"(?i)Enabled", usageState=regex"(?i)Active"
  ...  timeout=${timeout}
  ...  alias=${node}
  ${av_cell_state}=  Run Keyword And Continue On Failure  Run Keyword And Return Status  admin.Assert No
  ...  class_name=GNCEL
  ...  parameters=availabilityStatus=regex"[Dd]egraded"
  ...  timeout=${timeout}
  ...  alias=${node}
  [Teardown]  Run Keyword If  ${cfg['NODES']['${node}']['scf_gsm']}
  ...  Log  GSM cell state = OnAirDone on bts_id node=${node} verification finished. Result = ${KEYWORD STATUS}  console=True

Verify Admin Every NR Cell State
  [Arguments]  ${node}  ${timeout}=30
  Return From Keyword If  not ${cfg['NODES']['${node}']['scf_nr']}
  Log  \nEvery NR Cell state on bts_id node=${node} verification started  console=True
  FOR  ${cell_id}  IN  @{CFG['NODES']['${node}']['NRCEL'].keys()}
    ${affected_by_rm}=  Check CELL Affected By Any RMs Energy Efficiency Feature  ${cell_id}  nr  ${node}
    Continue For Loop If  ${affected_by_rm}
    ${cell_distname}=  admin.Get Cell Id By Configuration Id  NR  ${cell_id}  alias=${node}
    ${cell_info}=  admin.Get Cell Specific Info  cell_id=${cell_distname}  timeout=${timeout}  connection=${node}
    ${dict_key_assert}=    Evaluate    $cell_info['energySavingState'].lower()
    ${parameter_key_assert}=    Get From Dictionary    ${LEGACY_CELL_ENERGY_SAVING_STATES_REQUIREMENTS['${dict_key_assert}']}    assert
    ${parameter_key_assert_no}=    Get From Dictionary    ${LEGACY_CELL_ENERGY_SAVING_STATES_REQUIREMENTS['${dict_key_assert}']}   assert_no
    Run Keyword And Continue On Failure  admin.Assert
    ...  class_name=NRCEL
    ...  id=${cell_distname}
    ...  parameters=${parameter_key_assert}
    ...  timeout=${timeout}
    ...  alias=${node}
    Run Keyword And Continue On Failure
    ...  admin.Assert No
    ...  class_name=NRCEL
    ...  parameters=id=${cell_distname}, ${parameter_key_assert_no}
    ...  timeout=${timeout}
    ...  alias=${node}
  END
  [Teardown]  Run Keyword If  ${cfg['NODES']['${node}']['scf_nr']}
  ...  Log  NR cell state on bts_id node=${node} verification finished. Result = ${KEYWORD STATUS}  console=True

Verify Multi BTS RAT And Cell State
  FOR  ${bts_id}  IN  @{cfg.active_bts_list}
    Verify BTS RAT state  ${bts_id}
    Verify Admin Every LTE Cell State  ${bts_id}
    Verify Admin Every WCDMA Cell State  ${bts_id}
    Verify Admin Every GSM Cell State  ${bts_id}
    Verify Admin Every NR Cell State  ${bts_id}
  END

Gather Startup Time Points
  [Arguments]  ${node}  ${timeout}=360
  Wait Until Keyword Succeeds  360 sec  Run Keywords
  ...  Verify Admin Any GSM Cell State

Verify Admin Any GSM Cell State
  [Arguments]  ${state}  ${node}  ${timeout}=30
  ${gsm_state}=  Run Keyword And Return Status
  ...  admin.Assert Any
  ...  GNCEL
  ...  availabilityStatus=Offline, operationalState=Disabled
  ...  timeout=${timeout}
  ...  alias=${node}

Verify Startup Parameters
  [Arguments]  ${test_logs_path}  ${node}
  ${index}=  Set Variable If  ${REPETITION}  ${ITERATION}  1
  admin.collect_infomodel_log_from_current_session
  ...  target_file_name=${test_logs_path}/infomodel_${node}.ims2
  ...  timeout=120
  ...  connection=${node}
  ...  leave_disconnect_logs=True
#  Save Infomodel Log  filename=${test_logs_path}infomodel_${node}  alias=${node}
  kpi.clear_results
  ${kpi_results}=  kpi.calculate_kpis
  ...  kpi_names=kpi1a kpi1b kpi1c
  ...  ims_file_path=${test_logs_path}/infomodel_${node}.ims2
  ${kpi1a}=  kpi.get_all_deltas  kpi_name=kpi1a
  ${kpi1b}=  kpi.get_all_deltas  kpi_name=kpi1b
  ${kpi1c}=  kpi.get_all_deltas  kpi_name=kpi1c
  ${bts_kpi_first_to_last}=  Run Keyword And Continue On Failure  Set Variable  ${kpi1a[0]}
  ${bts_kpi_last_to_first}=  Run Keyword And Continue On Failure  Set Variable  ${kpi1b[0]}
  ${bts_startup_time}=  Run Keyword And Continue On Failure  Set Variable  ${kpi1c[0]}
  ${test_verdict}=  Set Variable If
  ...  ${bts_startup_time} > ${CONFIGURATION_STARTUP_TIMEOUT}
  ...  Failed
  ...  Passed
  ${test_verdict_log_level}=  Set Variable If  '${test_verdict}' == 'Failed'  WARN  INFO

  Run Keyword And Continue On Failure
  ...  Run Keyword If
  ...  "${test_verdict}" == "Failed" and ${ACTIVE_STARTUP_VERDICT}
  ...  Run Keywords
  ...  Logging With Timestamp
  ...  Specified startup time (${CONFIGURATION_STARTUP_TIMEOUT} second) was exceeded.
  ...  console=yes
  ...  level=${test_verdict_log_level}
  ...  AND
  ...  Fail
  ...  Specified startup time (${CONFIGURATION_STARTUP_TIMEOUT} second) was exceeded.
  Logging With Timestamp  Time From First Cell Down To Last Cell Up (KPI 1a) = ${bts_kpi_first_to_last}.  console=True
  Logging With Timestamp  Time From Last Cell Down To First Cell Up (KPI 1b) = ${bts_kpi_last_to_first}.  console=True
  Logging With Timestamp  Site Reset on bts_id node=${node} executed with startup time (KPI 1c) = ${bts_startup_time}.
  Run Keyword If  ${ACTIVE_STARTUP_VERDICT}
  ...  Logging With Timestamp  \nExpecterd time = ${CONFIGURATION_STARTUP_TIMEOUT}  console=True
  ${tmp_it_dict}=  Create Dictionary  &{EMPTY}
  ${kpi_verdict}=  Set Variable If  "${test_verdict}" == "Failed"  0  1


Calculate Site Reset Test Verdict
  [Arguments]  ${node}
  ${tmp_list}=  Get Dictionary Values  ${VERDICT_DICT}


Verify Alarms On All Nodes
  FOR  ${node}  IN  @{cfg.active_bts_list}
    Verify Alarms  alias=${node}
  END

Verify Alarms
  [Arguments]  ${alias}
#  admin.Clear Allowed Alarms List  alias=${alias}
  FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
    admin.Add Allowed Alarm  ${alarm}  alias=${alias}
  END
#  Legacy TC Add Additional Alarms  ${alias}
  ${alarm_unexpected_status}  ${msg}=  Run Keyword And Ignore Error  admin.Assert No Unexpected Active Alarms  alias=${alias}
  ${__}  ${_}  ${msg}=  Run Keyword If  "${alarm_unexpected_status}" == "FAIL"  Split String  ${msg}  :  2
  Run Keyword If  "${alarm_unexpected_status}" == "FAIL"
  ...  Log  \nList of unexpected alarms detected:${\n}"${msg}"  console=True
  ...  ELSE  Log  \nNo unexpected alarms detected  console=True
  Run Keyword And Continue On Failure  Should Not Be True  "${alarm_unexpected_status}" == "FAIL"
  ${historical_alarm_status}=  Run Keyword And Return Status  admin.Assert No Unexpected Historical Alarms  alias=${alias}
  Run Keyword If  not ${historical_alarm_status}    Logging With Timestamp
  ...  Historical unexpected alarms detected, please make analysis
  ...  level=WARN
  [Teardown]  Set Test Variable  ${ALARM_state}  ${KEYWORD_STATUS}
  [Return]  ${alarm_unexpected_status}  ${msg}

Verify Historical Alarms
  [Arguments]  ${alias}
#  admin.Clear Allowed Alarms List  alias=${alias}
  FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
    admin.Add Allowed Alarm  ${alarm}  alias=${alias}
  END
#  Legacy TC Add Additional Alarms  ${alias}
  ${historical_alarm_status}=  Run Keyword And Continue On Failure
  ...  admin.Assert No Unexpected Historical Alarms
  ...  alias=${alias}
  Run Keyword If  '${historical_alarm_status}'!='None'    Logging With Timestamp
  ...  Historical unexpected alarms detected, please make analysis
  ...  level=WARN
  [Teardown]  Set Test Variable  ${ALARM_state}  ${KEYWORD_STATUS}
  [Return]  ${historical_alarm_status}

Verify Unexpected And Historical Alarms
  [Arguments]  ${alias}
#  admin.Clear Allowed Alarms List  alias=${alias}
  FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
    admin.Add Allowed Alarm  ${alarm}  alias=${alias}
  END
#  Legacy TC Add Additional Alarms  ${alias}
  ${alarm_unexpected_status}  ${msg}=  Run Keyword And Ignore Error  admin.Assert No Unexpected Active Alarms  alias=${alias}
  ${__}  ${_}  ${msg}=  Run Keyword If  "${alarm_unexpected_status}" == "FAIL"  Split String  ${msg}  :  2
  Run Keyword If  "${alarm_unexpected_status}" == "FAIL"
  ...  Log  \nList of unexpected alarms detected:${\n}"${msg}"  console=True
  ...  ELSE  Log  \nNo unexpected alarms detected  console=True
  Run Keyword And Continue On Failure  Should Not Be True  "${alarm_unexpected_status}" == "FAIL"
  ${historical_alarm_status}=  Run Keyword And Continue On Failure
  ...  admin.Assert No Unexpected Historical Alarms
  ...  alias=${alias}
  ${alarm_log_level}=  Set Variable If  '${historical_alarm_status}'=='None'  INFO  WARN
  Run Keyword If  '${historical_alarm_status}'!='None'    Logging With Timestamp
  ...  Historical unexpected alarms detected, please make analysis
  ...  level=${alarm_log_level}
  [Teardown]  Set Test Variable  ${ALARM_state}  ${KEYWORD_STATUS}
  [Return]  ${alarm_unexpected_status}  ${msg}

Verify Reset Site Historical Alarms
  [Arguments]  ${alias}
#  Legacy TC Add Additional Alarms  ${alias}
  ${historical_alarm_status}=  Run Keyword And Continue On Failure
  ...  admin.Assert No Unexpected Historical Alarms
  ...  alias=${alias}
  Run Keyword If  '${historical_alarm_status}'!='None'    Logging With Timestamp
  ...  Historical unexpected alarms detected, please make analysis
  ...  level=WARN
  [Teardown]  Set Test Variable  ${ALARM_state}  ${KEYWORD_STATUS}


#
#Get RMOD LNCEL Cells Info
#  [Arguments]  ${rmod_dist_name}  ${cfg}  ${scfc}
#  ${lte}=  Set Variable  ${LTE}
#  ${lte_info}=  Run keyword if  ${lte}==False  Create Dictionary  lncelid=None  lte_cell_count=0
#  Return From Keyword If  ${lte}==False  ${lte_info}
#  ${fr_lncel_list}=  Get RMOD LTE Cell List  ${rmod_dist_name}  ${cfg}  ${scfc}
#  ${lte_cell_count}=  Get RMOD cell count  ${fr_lncel_list}
#  ${lte_info}=  Create Dictionary  lncelid=${fr_lncel_list}  lte_cell_count=${lte_cell_count}
#  [Return]  ${lte_info}
#
#Get RMOD WNCEL Cells Info
#  [Arguments]  ${rmod_dist_name}  ${cfg}  ${scfc}
#  ${wcdma}=  Set Variable  ${WCDMA}
#  ${wcdma_info}=  Run keyword if  ${wcdma}==False  Create Dictionary  wncelid=None  wcdma_cell_count=0
#  Return From Keyword If  ${wcdma}==False  ${wcdma_info}
#  ${rmod_wncel_list}=  Get RMOD Wcdma Cell List  ${rmod_dist_name}  ${cfg}  ${scfc}
#  ${wcdma_cell_count}=  Get RMOD cell count  ${rmod_wncel_list}
#  ${wcdma_info}=  Create Dictionary  wncelid=${rmod_wncel_list}  wcdma_cell_count=${wcdma_cell_count}
#  [Return]  ${wcdma_info}
#
#Get RMOD GSM Cells Info
#  [Arguments]  ${serial_number}  ${rmod_dist_name}  ${cfg}  ${scfc}
#  ${gsm}=  Set Variable  ${GSM}
#  ${gsm_info}=  Run keyword if  ${gsm}==False  Create Dictionary  gncelid=None  gsm_cell_count=0
#  Return From Keyword If  ${gsm}==False  ${gsm_info}
#  ${rmod_gncel_list}=  Get RMOD Gsm Cell List  ${serial_number}  ${rmod_dist_name}  ${cfg}  ${scfc}
#  ${gsm_cell_count}=  Get RMOD cell count  ${rmod_gncel_list}
#  ${gsm_info}=  Create Dictionary  gncelid=${rmod_gncel_list}  gsm_cell_count=${gsm_cell_count}
#  [Return]  ${gsm_info}
#
#Get RMOD NRCEL Cells Info
#  [Arguments]  ${rmod_dist_name}  ${cfg}  ${scfc}
#  ${5g}=  Set Variable  ${cfg['nr']}
#  ${5g_info}=  Run keyword if  ${5g}==False  Create Dictionary  nrcelid=None  nrcel_cell_count=0
#  Return From Keyword If  ${5g}==False  ${5g_info}
#  ${rmod_nrcel_list}=  Get RMOD NRCEL Cell List  ${rmod_dist_name}  ${cfg}  ${scfc}
#  ${5g_cell_count}=  Get RMOD cell count  ${rmod_nrcel_list}
#  ${5g_info}=  Create Dictionary  nrcelid=${rmod_nrcel_list}  nrcel_cell_count=${5g_cell_count}
#  [Return]  ${5g_info}
#
#Get RMOD cell count
#  [Arguments]  ${rmod_cell_list}
#  Return From Keyword If  ${rmod_cell_list}==None  0
#  ${cell_count}=  get length  ${rmod_cell_list}
#  [Return]  ${cell_count}
#
#Get RMOD LTE Cell List
#  [Arguments]  ${rmod}  ${cfg}  ${scfc}
#  ${lncel_list}=  Get Dictionary Keys  ${cfg.LNCEL}
#  ${_}  ${rmod}=  Split String From Right  ${rmod}  /  1
#  ${rmod_lncel_list}=  Create List
#  :FOR  ${lncel}  IN  @{lncel_list}
#  \  ${lcr_id}=  Get from dictionary  ${cfg.LNCEL['${lncel}']}  lcr_id
#  \  ${status}=  Check RMOD LTE Cell  ${lcr_id}  ${rmod}  ${scfc}
#  \  Run Keyword If  ${status} == True  append to list  ${rmod_lncel_list}  ${lncel}
#  ${rmod_lncel_list}=  Remove Duplicates  ${rmod_lncel_list}
#  ${rmod_lncel_list}=  Set Variable if  not ${rmod_lncel_list}  None  ${rmod_lncel_list}
#  [Return]  ${rmod_lncel_list}
#
#Get RMOD Gsm Cell List
#  [Arguments]  ${serial_number}  ${rmod}  ${cfg}  ${scfc}
#  ${gncel_list}=  Get Dictionary Keys  ${cfg.GNCEL}
#  ${_}  ${rmod}=  Split String From Right  ${rmod}  /  1
#  ${rmod_gncel_list}=  Create List
#  :FOR  ${gncel}  IN  @{gncel_list}
#  \  ${lcelcId}=  Get from dictionary  ${cfg.GNCEL['${gncel}']}  lcelcId_id
#  \
#  ...  ${gsm_cell_rmod}=
#  ...  Evaluate Xpath
#  ...  ${scfc}
#  ...  boolean(.//managedObject[contains(@distName,"RMOD_R")][p[@name="serialNumber"]=
##'${serial_number}']/list[@name="activeGsmCellsList"][p='${lcelcId}'])
#  \  Run Keyword If  ${gsm_cell_rmod} == True  append to list  ${rmod_gncel_list}  ${gncel}
#  ${rmod_gncel_list}=  Remove Duplicates  ${rmod_gncel_list}
#  ${rmod_gncel_list}=  Set Variable if  not ${rmod_gncel_list}  None  ${rmod_gncel_list}
#  [Return]  ${rmod_gncel_list}
#
#Get RMOD Wcdma Cell List
#  [Arguments]  ${rmod}  ${cfg}  ${scfc}
#  ${wncel_list}=  Get Dictionary Keys  ${cfg.WNCEL}
#  ${_}  ${rmod}=  Split String From Right  ${rmod}  /  1
#  ${rmod_wncel_list}=  Create List
#  :FOR  ${wncel}  IN  @{wncel_list}
#  \  ${lcelw}=  Get from dictionary  ${cfg.WNCEL['${wncel}']}  lcelw_id
#  \  ${status}=  Check RMOD WCDMA Cell  ${lcelw}  ${rmod}  ${scfc}
#  \  Run Keyword If  ${status} == True  append to list  ${rmod_wncel_list}  ${wncel}
#  ${rmod_wncel_list}=  Remove Duplicates  ${rmod_wncel_list}
#  ${rmod_wncel_list}=  Set Variable if  not ${rmod_wncel_list}  None  ${rmod_wncel_list}
#  [Return]  ${rmod_wncel_list}
#
#Get RMOD NRCEL Cell List
#  [Arguments]  ${rmod}  ${cfg}  ${scfc}
#  ${nrcel_list}=  Get Dictionary Keys  ${cfg.NRCEL}
#  ${_}  ${rmod}=  Split String From Right  ${rmod}  /  1
#  ${rmod_nrcel_list}=  Create List
#  :FOR  ${nrcel}  IN  @{nrcel_list}
#  \  ${lcr_id}=  Get from dictionary  ${cfg.NRCEL['${nrcel}']}  lcr_id
#  \  ${status}=  Check RMOD NRCEL Cell  ${lcr_id}  ${rmod}  ${scfc}
#  \  Run Keyword If  ${status} == True  append to list  ${rmod_nrcel_list}  ${nrcel}
#  ${rmod_nrcel_list}=  Remove Duplicates  ${rmod_nrcel_list}
#  ${rmod_nrcel_list}=  Set Variable if  not ${rmod_nrcel_list}  None  ${rmod_nrcel_list}
#  [Return]  ${rmod_nrcel_list}
#
#Check RMOD GSM Cell
#  [Arguments]  ${lcelw}  ${rmod}  ${scfc_file_path}
#  ${gsm_cell_rmod}=  Evaluate Xpath  ${scfc_file_path}
#  ...  boolean(.//managedObject[contains(@distName,"RMOD_R") and contains(p[@name="serialNumber"], "/${rmod}/")])
#  [Return]  ${gsm_cell_rmod}
#
#Check RMOD WCDMA Cell
#  [Arguments]  ${lcelw}  ${rmod}  ${scfc_file_path}
#  ${wcdma_cell_rmod}=  Evaluate Xpath  ${scfc_file_path}
#  ...  boolean(.//managedObject[contains(@distName,"LCELW-${lcelw}/") and contains(p[@name="antlDN"], "/${rmod}/")])
#  [Return]  ${wcdma_cell_rmod}
#
#Check RMOD LTE Cell
#  [Arguments]  ${lcr_id}  ${rmod}  ${scfc_file_path}
#  ${lte_cell_rmod}=  Evaluate Xpath
#  ...  ${scfc_file_path}
#  ...  boolean(.//managedObject[contains(@distName,"LCELL-${lcr_id}/") and contains(p[(@name="antlDN" or @name="resourceDN")], "/${rmod}/")])
#  [Return]  ${lte_cell_rmod}
#
#Check RMOD NRCEL Cell
#  [Arguments]  ${nrcel}  ${rmod}  ${scfc_file_path}
#  ${nrcel_cell_rmod}=  Evaluate Xpath
#  ...  ${scfc_file_path}
#  ...  boolean(.//managedObject[contains(@distName,"LCELNR-${nrcel}/") and contains(p[(@name="antlDN" or @name="resourceDN")], "/${rmod}/")])
#  [Return]  ${nrcel_cell_rmod}

Admin Get Rmod Ip Address For Rmod Serial Number
  [Arguments]  ${fr_serial_number}  ${alias}=default
  ${fr_ip}=  Admin Get Rmod Attribute For Rmod Serial Number  ${fr_serial_number}  atribute=ipAddress  alias=${alias}
  [Return]  ${fr_ip}

Admin Get Rmod Distname For Rmod Serial Number
  [Arguments]  ${fr_serial_number}  ${alias}=default
  ${fr_distname}=  Admin Get Rmod Attribute For Rmod Serial Number  ${fr_serial_number}  atribute=id  alias=${alias}
  [Return]  ${fr_distname}

Admin Get Rmod active SW For Rmod Serial Number
  [Arguments]  ${fr_serial_number}  ${alias}
  ${fr_sw}=  Admin Get Rmod Attribute For Rmod Serial Number
  ...  ${fr_serial_number}
  ...  atribute=buildVersion
  ...  alias=${alias}
  [Return]  ${fr_sw}

Admin Get Rmod Variant Type For Rmod Serial Number
  [Arguments]  ${fr_serial_number}  ${alias}=default
  ${variant}=  Admin Get Rmod Attribute For Rmod Serial Number
  ...  ${fr_serial_number}
  ...  atribute=productName
  ...  alias=${alias}
  [Return]  ${variant}

Admin Get Rmod Attribute For Rmod Serial Number
  [Arguments]  ${fr_serial_number}  ${atribute}  ${timeout}=90  ${alias}=default
  ${rmod_status}=  Run Keyword And Return Status
  ...  admin.Assert Any
  ...  RMOD
  ...  parameters=serialNumber=${fr_serial_number}
  ...  timeout=${timeout}
  ...  alias=${alias}
  ${asserted_rmod}=  Run Keyword If  ${rmod_status}
  ...  admin.Assert Any  RMOD  parameters=serialNumber=${fr_serial_number}  timeout=${timeout}  alias=${alias}
  ${asserted_asirmod}=  Run Keyword If   not ${rmod_status}
  ...  admin.Assert Any  ASIRMOD  parameters=serialNumber=${fr_serial_number}  timeout=${timeout}  alias=${alias}
  ${asserted_rmod_asirmod}=  Set Variable If  ${rmod_status}  ${asserted_rmod}  ${asserted_asirmod}
  FOR  ${id}  IN  @{asserted_rmod_asirmod}
    ${key_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${id}  serialNumber
    Continue For Loop If  '${key_status}' != 'True'
    ${fr_attributes_list}=  Set Variable If  '${id['serialNumber']}' == '${fr_serial_number}'  ${id}
    Exit For Loop If  '${id['serialNumber']}' == '${fr_serial_number}'
  END
  [Return]  ${fr_attributes_list['${atribute}']}

Set RMOD Dynamic Values to Dictionary
    [Arguments]     ${serial_numbers}   ${cfg}
    Set RMOD Ip values to Dictionary    ${serial_numbers}    ${cfg}
    Set RMOD Active SW to Dictionary    ${serial_numbers}    ${cfg}

Set RMOD Ip values to Dictionary
    [Arguments]    ${serial_numbers}    ${cfg}
    convert to list    ${serial_numbers}
    FOR  ${serial_number}  IN  @{serial_numbers}
        ${alias_id}=    Set Variable    ${cfg.RF_INFO['${serial_number}']['scf_btsid_primary']}
        ${ip}=          Admin Get Rmod Ip Address For Rmod Serial Number    ${serial_number}    alias=${alias_id}
        Set to Dictionary   ${cfg.RF_INFO['${serial_number}']}    rmod_ip    ${ip}
    END

Set RMOD Active SW to Dictionary
    [Arguments]    ${serial_numbers}    ${cfg}
    convert to list    ${serial_numbers}
    FOR  ${serial_number}  IN  @{serial_numbers}
        ${alias_id}=    Set Variable    ${cfg.RF_INFO['${serial_number}']['scf_btsid_primary']}
        ${fr_active_sw}=     Admin Get Rmod active SW For Rmod Serial Number       ${serial_number}
    ...  alias=${alias_id}
        Set to Dictionary    ${cfg.RF_INFO['${serial_number}']}    rmod_sw    ${fr_active_sw}
    END

#Combine NR NSA cells with thier LTE parents cells
#    [Arguments]    ${cfg}
#    ${nrcels_parents_list}=    Loop By All Nodes And Get LNCELs Childs    ${cfg}
#    Run Keyword And Ignore Error    Loop By All Nodes And Assign Parent LNCEL To NSA NRCEL    ${cfg}    ${nrcels_parents_list}
#    Log    ${cfg}



#
#Analyze Truck Roll On All Nodes
#  [Arguments]  ${truck_roll_alarms}=${TRUCK_ROLL_FID_LIST}  ${truck_roll_recipents}=${TRUCK_ROLL_RECIPIENTS_LIST}
#  ...  ${truck_roll_cm_maintainers}=${TRUCK_ROLL_CM_MAINTAINERS_LIST}
#
#  ${skip_tr_variable}=  Run Keyword And Return Status  Variable Should Exist  ${SKIP_TRUCK_ROLL}
#  ${is_cm_exec_based_on_file}=  Run Keyword And Return Status  File Should Exist  /opt/ute/execution.context.json
#  Run Keyword And Return If  ${skip_tr_variable} and not ${is_cm_exec_based_on_file}
#  ...  Log  Skiping Truck Roll analysis due to flag set by the user  level=warn
#  # Truck Roll checking for all nodes
#  Log To Console  \n------------------------------------------------\nStarting analysis of Truck Roll for all nodes...
#  FOR  ${bts_id}  IN  @{cfg.active_bts_list}
#    Log To Console  Truck Roll analysis for node ${bts_id} begins...
#    ${trigger_lmp_connectivity}  ${mplane_ip}=  Run Keyword And Continue On Failure
#    ...  Analyze Truck Roll LMP Connectivity
#    ...  lmp_addr=${cfg.NODES['${bts_id}']['host_ip']}
#    ...  log_path=${TEST_LOGS_PATH}
#    Run Keyword If
#    ...  ${trigger_lmp_connectivity}
#    ...  Log To Console
#    ...  Truck Roll LMP connectivity check on BTS ${bts_id} passed
#    Run Keyword Unless
#    ...  ${trigger_lmp_connectivity}
#    ...  Log To Console
#    ...  Truck Roll LMP connectivity check on BTS ${bts_id} FAILED!
#    # Truck Roll M-Plane connectivity check
#    ${trigger_mplane_connectivity}=  Run Keyword If  ${trigger_lmp_connectivity}  Run Keyword And Continue On Failure
#    ...  Analyze Truck Roll MPlane Connectivity
#    ...  mplane_addr=${mplane_ip}
#    ...  log_path=${TEST_LOGS_PATH}
#    Run Keyword If
#    ...  ${trigger_mplane_connectivity}
#    ...  Log To Console
#    ...  Truck Roll M-Plane connectivity check on BTS ${bts_id} passed
#    Run Keyword Unless
#    ...  ${trigger_mplane_connectivity}
#    ...  Log To Console
#    ...  Truck Roll M-Plane connectivity check on BTS ${bts_id} FAILED!
#    # Truck Roll HW detection check
#    ${trigger_hw_detection}=  Run Keyword And Continue On Failure  Analyze Truck Roll HW Detection
#    ...  alias=${bts_id}
#    ...  smod_list=${cfg.NODES['${bts_id}']['scf_hw_sm_list']}
#    ...  bbmod_list=${cfg.NODES['${bts_id}']['scf_hw_bbmod_list']}
#    ...  rmod_list=${cfg.NODES['${bts_id}']['scf_hw_fr_list']}
#    Run Keyword If  ${trigger_hw_detection}  Log To Console  Truck Roll HW detection check on BTS ${bts_id} passed
#    Run Keyword If  not ${trigger_hw_detection}  Log To Console  Truck Roll HW detection check on BTS ${bts_id} FAILED!
#    # Truck Roll alarms check
#    ${trigger_alarms}=  Run Keyword And Continue On Failure  Analyze Truck Roll Alarms
#    ...  alias=${bts_id}
#    ...  truck_roll_alarms=${truck_roll_alarms}
#    Run Keyword If  ${trigger_alarms}  Log To Console  Truck Roll alarms check on BTS ${bts_id} passed
#    Run Keyword If  not ${trigger_alarms}  Log To Console  Truck Roll alarms check on BTS ${bts_id} FAILED!
#    # Truck Roll result overall - True if Truck Roll failed, False otherwise
#    ${truck_roll_result}=  Set Variable
#    ...  not ${trigger_alarms} or not ${trigger_hw_detection} or not ${trigger_lmp_connectivity} or not ${trigger_mplane_connectivity}
#    # Reason building for Stop&Fix email notification
#    ${truck_roll_email_reason}=  Evaluate
#    ...  dict(alarms=not ${trigger_alarms},
#    ...  hw=not ${trigger_hw_detection}, lmp=not ${trigger_lmp_connectivity}, mplane=not ${trigger_mplane_connectivity})
#    # Executing Stop&Fix action if Truck Roll any check failed
#    Run Keyword If
#    ...  ${truck_roll_result}
#    ...  Exec Stop And Fix Action
#    ...  recipients_list=${truck_roll_recipents}
#    ...  reply_list=${truck_roll_cm_maintainers}
#    ...  reason_dict=${truck_roll_email_reason}
#    Run Keyword Unless
#    ...  ${truck_roll_result}
#    ...  Log To Console
#    ...  All steps of Truck Roll analysis for node ${bts_id} passed
#  END
#  Log To Console  End of analysis of Truck Roll for all nodes\n-------------------------------------------\n

Generate Proper RAT State For Node
  [Arguments]  ${rat}  ${node}  ${timeout}=30
  Return From Keyword If  not ${cfg['NODES']['${node}']['scf_${rat}']}  None
  Return From Keyword If  '${rat}'!='nr' and '${rat}'!='lte'  ALL_ENABLED
  ${class_name}=  Set Variable If  '${rat}'=='lte'  LNCEL
  ...  '${rat}'=='nr'  NRCEL
  ${affected_by_rm}=  Check NODEs RAT Affected By Any RMs Energy Efficiency Feature  ${rat}  ${node}
  Return From Keyword If
  ...  '${affected_by_rm}' == 'PARTIALLY_DISABLED' or '${affected_by_rm}' == 'ALL_DISABLED'
  ...  ${affected_by_rm}
  ${all_cells_without_ee}=  Run Keyword And Return Status
  ...  admin.Assert Every
  ...  class_name=${class_name}
  ...  parameters=energySavingState=regex"(?i)NotEnergySaving"
  ...  timeout=${timeout}
  ...  alias=${node}
  Return From Keyword If  ${all_cells_without_ee}  ALL_ENABLED
  ${all_cells_with_ee}=  Run Keyword And Return Status
  ...  admin.Assert No
  ...  class_name=${class_name}
  ...  parameters=energySavingState=regex"(?i)NotEnergySaving"
  ...  timeout=${timeout}
  ...  alias=${node}
  Return From Keyword If  ${all_cells_with_ee}  ALL_DISABLED
  [Return]  PARTIALLY_DISABLED

Check NODEs RAT Affected By Any RMs Energy Efficiency Feature
  [Arguments]  ${rat}  ${node}  ${timeout}=30
  # Only NR and LTE are supported!
  Return From Keyword If  '${rat}'!='lte' and '${rat}'!='nr'  ${False}
  # Return if RAT is not configured
  Return From Keyword If  not ${cfg['NODES']['${node}']['scf_${rat}']}  ALL_DISABLED
  # Prepare varaibles
  ${rat_name}=  Set Variable If  '${rat}'=='lte'  LNCEL
  ...  '${rat}'=='nr'  NRCEL
  ${cell_count_name}=  Set Variable If  '${rat}'=='lte'  scf_cell_count_primary
  ...  '${rat}'=='nr'  scf_cell_count_primary
  ${cell_list_name}=  Set Variable If  '${rat}'=='lte'  scf_cellid_primary
  ...  '${rat}'=='nr'  scf_cellid_primary
  # Get number of RAT's cells
  ${number_of_cells}=  Get Length  ${CFG["NODES"]["${node}"]["${rat_name}"]}
  # Get all info about RMs
  ${all_rm_info}=  admin.Get FRM  connection=${node}
  # Add all 'sleeping' RMs to list
  ${sleeping_rms_list}=  Create List
  FOR  ${rm}  IN  @{all_rm_info}
    Run Keyword If  '${rm["status"]["usageState"]}'=='Idle' and '${rm["status"]["powerState"]}'=='SLEEP'
    ...  Append To List  ${sleeping_rms_list}  ${rm["serialNumber"]}
  END
  # Select only 'sleeping' RMs from selected RAT and add its SN RMs and thiers cells to lists
  ${rm_sn_list}=  Create List
  ${affected_cells_list}=  Create List
  FOR  ${rm_sn}  IN  @{CFG["NODES"]["${node}"]["scf_hw_fr_list"]}
    Run Keyword If
    ...  ${CFG["RF_INFO"]["${rm_sn}"]["${rat_name}"]["${cell_count_name}"]} > 0 and '${rm_sn}' in @{sleeping_rms_list}
    ...  Run Keywords
    ...  Append To List
    ...  ${rm_sn_list}
    ...  ${rm_sn}
    ...  AND
    ...  Append To List
    ...  ${affected_cells_list}
    ...  @{CFG["RF_INFO"]["${rm_sn}"]["${rat_name}"]["${cell_list_name}"]}
  END
  # Return proper RAT state
  ${number_of_affected_cells}=  Get Length  ${affected_cells_list}
  Return From Keyword If  ${number_of_affected_cells} == 0  ALL_ENABLED
  Return From Keyword If  ${number_of_affected_cells} < ${number_of_cells}  PARTIALLY_DISABLED
  Return From Keyword If  ${number_of_affected_cells} == ${number_of_cells}  ALL_DISABLED

Check CELL Affected By Any RMs Energy Efficiency Feature
  [Arguments]  ${cell_id}  ${rat}  ${node}  ${timeout}=30
  # Only NR and LTE are supported!
  Return From Keyword If  '${rat}'!='lte' and '${rat}'!='nr'  ${False}
  # Return if RAT is not configured
  Return From Keyword If  not ${cfg['NODES']['${node}']['scf_${rat}']}  ${False}
  # Prepare varaibles
  ${rat_name}=  Set Variable If  '${rat}'=='lte'  LNCEL
  ...  '${rat}'=='nr'  NRCEL
  ${cell_count_name}=  Set Variable If  '${rat}'=='lte'  scf_cell_count_primary
  ...  '${rat}'=='nr'  scf_cell_count_primary
  ${cell_list_name}=  Set Variable If  '${rat}'=='lte'  scf_cellid_primary
  ...  '${rat}'=='nr'  scf_cellid_primary
  # Get list of RMs for cell
  ${cell_on_rms_list}=  Create List
  FOR  ${rm_sn}  IN  @{CFG["RF_INFO"]}
    Continue For Loop If  ${CFG["RF_INFO"]["${rm_sn}"]["${rat_name}"]["${cell_list_name}"]} == ${None}
    Run Keyword If
    ...  '${cell_id}' in ${CFG["RF_INFO"]["${rm_sn}"]["${rat_name}"]["${cell_list_name}"]}
    ...  Append To List
    ...  ${cell_on_rms_list}
    ...  ${rm_sn}
  END
  # Get all info about RMs and check if sleeps
  ${all_rm_info}=  admin.Get FRM  connection=${node}
  FOR  ${rm_info}  IN  @{all_rm_info}
    Continue For Loop If  ${CFG["RF_INFO"]["${rm_sn}"]["${rat_name}"]["${cell_list_name}"]} == ${None}
    ${object_1}=  Set Variable  '${rm_info["serialNumber"]}' in ${cell_on_rms_list} and '${rm_info["status"]["usageState"]}'=='Idle'
    ${object_2}=  Set Variable  '${rm_info["status"]["powerState"]}'=='SLEEP'
    ${sum_object}=  evaluate   ${object_1} and ${object_2}
    Return From Keyword If  ${sum_object}
    ...  ${True}
  END

SCFC Create Unique MHA Serial Number List For FR Serial Number
    [Arguments]    ${scfc_file_path}    ${fr_serial_number}
    ${out_result}=    Evaluate Xpath    ${scfc_file_path}    boolean(.//managedObject[@class="RMOD"])
    ${out_mha_serial_number_list}=    Run Keyword If    ${out_result}
    ...    SCFC Create Unique MHA Serial Number List For FR Serial Number Old    ${scfc_file_path}    ${fr_serial_number}
    ...    ELSE    SCFC Create Unique MHA Serial Number List For FR Serial Number New    ${scfc_file_path}    ${fr_serial_number}
    [Return]    ${out_mha_serial_number_list}

SCFC Create Unique MHA Serial Number List For FR Serial Number Old
    [Arguments]    ${scfc_file_path}    ${fr_serial_number}
    [Documentation]    Creates and returns list of unique MHA serial number(s) for given FR serial number from given SCFC file stored on local

    ${out_fr_rmod_id}=    SCFC Get RmodId For FR Serial Number    ${scfc_file_path}    ${fr_serial_number}
    ${out_fr_antl_list}=    SCFC Create Antl List For RmodId    ${scfc_file_path}    ${out_fr_rmod_id}
    ${out_mha_ser_num_list}=    SCFC Create Unique MHA Serial Number List For Antl List    ${scfc_file_path}    ${out_fr_antl_list}
    [Return]    ${out_mha_ser_num_list}

SCFC Create Unique MHA Serial Number List For FR Serial Number New
  [Arguments]    ${scfc_file_path}    ${fr_serial_number}
  [Documentation]    Creates and returns list of unique MHA serial number(s) for given FR serial number from given SCFC file stored on local
  ...     NOTE: Valid since FL17SP release
  ...    Author:      artur.dobosz@nokia.com
  ...    Maintainer:  Author
  @{out_mha_serial_number_list}=    Create List
  ${out_ald_dist_name_list}=    SCFC Create ALD DistName List For FR Serial Number    ${scfc_file_path}    ${fr_serial_number}
  FOR    ${ald_dist_name}    IN    @{out_ald_dist_name_list}
    ${out_mha_serial_number}=   Evaluate Xpath    ${scfc_file_path}
    ...  string(.//managedObject[@class="com.nokia.srbts.eqm:ALD" and @distName="${ald_dist_name}" and p[@name="mhaType"]]/p[@name="serialNumber"])
    Run Keyword If    "${out_mha_serial_number}" != ""    Append To List    ${out_mha_serial_number_list}    ${out_mha_serial_number}
  END
  [Return]    ${out_mha_serial_number_list}

SCFC Create ALD DistName List For FR Serial Number
    [Arguments]    ${scfc_file_path}    ${fr_serial_number}
    [Documentation]    Creates and returns list of unique ALD distName for given FR serial number from given SCFC file stored on local Robot PC.
    ...     NOTE: Valid since FL17SP release
    ...    Author:      artur.dobosz@nokia.com
    ...    Maintainer:  michal.szajkowski@nokia.com
    ${out_rmod_id}=    SCFC Get RmodId For FR Serial Number    ${scfc_file_path}    ${fr_serial_number}
    @{out_ald_dist_name_list}=    Create List
    ${out_antl_dist_name_list}=    Evaluate Xpath    ${scfc_file_path}
    ...     .//managedObject[@class="com.nokia.srbts.eqm:RETU"]/list[@name="antlDNList"]/p[contains(text(), "/RMOD-${out_rmod_id}/ANTL-")]/text()
    FOR    ${out_antl_dist_name}    IN     @{out_antl_dist_name_list}
      ${object_1}=  Set Variable  .//managedObject[@class="com.nokia.srbts.eqm:LOGLINK" and p[@name="secondEndpointDN"]="${out_antl_dist_name}"]
      ${object_2}=  Set Variable  /p[@name="firstEndpointDN" and not(contains(text(), "/LNA-"))]/text()
      ${sum_object}=  Set Variable  ${object_1}${object_2}
      ${out_first_end_point_dn_list}=     Evaluate Xpath    ${scfc_file_path}
        ...     ${sum_object}
      ${object_1}=  Set Variable  .//managedObject[@class="com.nokia.srbts.eqm:LOGLINK" and p[@name="firstEndpointDN"]="${out_antl_dist_name}"]
      ${object_2}=  Set Variable  /p[@name="secondEndpointDN" and not(contains(text(), "/LNA-"))]/text()
      ${sum_object}=  Set Variable  ${object_1}${object_2}
       ${out_second_end_point_dn_list}=    Evaluate Xpath    ${scfc_file_path}
        ...     ${sum_object}
       Append To List    ${out_ald_dist_name_list}    @{out_first_end_point_dn_list}
       Append To List    ${out_ald_dist_name_list}    @{out_second_end_point_dn_list}
    END
    ${out_ald_dist_name_list}=    Remove Duplicates    ${out_ald_dist_name_list}
    [Return]    ${out_ald_dist_name_list}

Convert Item To Single Element List
    [Arguments]  ${item}
    [Documentation]  If input is a list, keyword will not do anything. If not a list, it returns list with one element.
    ...  Author:      michal.szajkowski@nokia.com
    ...  Maintainer:  michal.szajkowski@nokia.com
    ${input_type}=  Evaluate  type($item).__name__
    ${output}=  Run Keyword If  "${input_type}"!="list"  Create List  ${item}
    ...         ELSE  Set Variable  ${item}
    [Return]  ${output}

Gather Start Time
    ${start_timestamp}=    Get Current Date
    Set Test Variable    ${START_TIMESTAMP}    ${start_timestamp}
    [Return]    ${start_timestamp}

Gather Stop Time
    ${stop_timestamp}=    Get Current Date
    Set Test Variable    ${STOP_TIMESTAMP}    ${stop_timestamp}
    [Return]    ${stop_timestamp}

Verify Whether FID50 Present
    [Arguments]  ${bts}
    ${bts_id}=  Get Id For Current  BTS  alias=${bts}
    ${fid50_status}=  Run Keyword And Return Status
    ...  Assert Alarm Active  faultId=50, severity=regex"(?i)Critical", alarmingObjectIds[0].internal=${bts_id}  connection=${bts}
    Run Keyword If  ${fid50_status}  Log  FID 50 has appeared. Unblocking the site.  console=True
    ...  ELSE  Fail  FID 50 has NOT appeared. Investigate towards pronto.


#LG Hot Remove Precondition
#  [Arguments]    ${alias}=${CFG.primary_node_bts_id}
#    Set Test Variable    ${CONFIGURATION_NAME}   ${CFG.configuration_name}
#    Set Test Variable    ${BTS_ID}    ${CFG.primary_node_bts_id}
#    Set Test Variable    ${scfc_file_path}   ${CFG['NODES']['${BTS_ID}']['scf_file_path']}
#    Set Test Variable    ${SCFC_REFERENCE_FILE_PATH}   ${CFG['NODES']['${BTS_ID}']['scf_file_path']}
#    Set Test Variable    ${OUT_SCFC_REFERENCE_FILE_PATH}   ${CFG['NODES']['${BTS_ID}']['scf_file_path']}
#    ${SW_RELEASE}=  Set Variable If      ${CFG['NODES']['${BTS_ID}']['trunk_status']}    SBTS00    ${CFG['NODES']['${BTS_ID}']['active_release']}
#    Set Test Variable    ${SW_RELEASE}   ${SW_RELEASE}
#    Set Test Variable    ${OUT_SCFC_CURRENT_FILE_PATH}   ${CFG['NODES']['${BTS_ID}']['scf_file_path']}
#    Set Test Variable    ${alias}   ${CFG.primary_node_bts_id}
#    ${act_category_alarms}=    Get From Dictionary    ${cfg.NODES['${BTS_ID}']}    scf_alarms_category
#    Set Test Variable    ${ACT_CATEGORY_ALARMS}    ${act_category_alarms}
#    set test variable    ${FR_SERIAL_NUMBER}     ${cfg.hw_all_fr_list}
#    set test variable    ${CURRENT_SM_SERIAL_NUMBERS}     ${cfg['NODES']['${BTS_ID}']['scf_hw_sm_list']}
#    set test variable    ${OUT_CURRENT_FR_SERIAL_NUMBERS}     ${cfg.scf_hw_all_fr_list}
#    ${ru_bts_id}    ${ru_dist_name}=    Get RU Node Data    ${CFG.scf_rmods_under_test[0]}
#    Set Test Variable    ${RU_DIST_NAME}   ${ru_dist_name}
#    Set Test Variable    ${RU_BTS_ID}   ${ru_bts_id}

Subtract List From List
    [Arguments]  ${list_1}  ${list_2}
    [Documentation]  Deletes values from ${list_1} that can also be found in ${list_2}.
    ...  Author:      michal.szajkowski@nokia.com
    ...  Maintainer:  michal.szajkowski@nokia.com
    ${list}=  Copy List  ${list_1}
    FOR  ${element}  IN  @{list_2}
      Run Keyword And Ignore Error  Remove Values From List  ${list}  ${element}
    END
    [Return]   ${list}



SCFC Create LcrId List For FR Serial Number
  [Arguments]    ${scfc_file_path}    ${fr_serial_number}    ${cell_type}=All    ${return_type}=integer
  [Documentation]    Keyword returns sorted list of LcrId(s) for specific FR serial number from given SCFC file stored on local Robot PC.
  ...    Additional filter can be added to return only LcrId(s) of specified cell type. Supported types are:
  ...    legacy, inband, guardband, standalone, catm
  ...    The argument can be passed with the following scheme:
  ...    ${cell_type}=legacy, standalone
  ...    Choose ${return_type}=string to return list of cellids as strings, and ${return_type}=integer to return integer list.
  ...    NOTE: Valid since FL17SP release.
  ...    Author:      artur.dobosz@nokia.com

  ${out_lcr_id_list}=    Create List
  ${out_rmod_dist_name}=    SCFC Get RMOD DistName For FR Serial Number    ${scfc_file_path}    ${fr_serial_number}
  ${out_dist_name_list}=    Evaluate Xpath    ${scfc_file_path}
  ...  .//managedObject[contains(p[@name="resourceDN"], "${out_rmod_dist_name}/") or contains(p[@name="antlDN"], "${out_rmod_dist_name}/")]/@distName
  FOR    ${out_dist_name}    IN    @{out_dist_name_list}
      ${out_lcr_id}=      Should Match Regexp    ${out_dist_name}    LCELL-(\\d+)
      ${out_lcr_id}=      Run Keyword If    "${return_type}" == "integer"    Convert To Integer     ${out_lcr_id}[1]
       ...    ELSE IF                        "${return_type}" == "string"     Convert To String      ${out_lcr_id}[1]
       ...    ELSE                                                            Set Variable           ${out_lcr_id}[1]
      ${out_cell_type}=   SCFC Get Cell Type     ${scfc_file_path}    ${out_lcr_id}
      Run Keyword If    "${out_cell_type}" in "${cell_type}" or "${cell_type}"=="All"
       ...                 Append To List    ${out_lcr_id_list}    ${out_lcr_id}
  END
  ${out_lcr_id_list}=    Remove Duplicates    ${out_lcr_id_list}
  Sort List    ${out_lcr_id_list}
  [Return]    ${out_lcr_id_list}


SCFC Create Antl List For LcrId List
    [Arguments]    ${scfc_file_path}    ${lcr_id_list}    ${fr_serial_number_list}=${EMPTY}  ${antl_direction}=${EMPTY}
    [Documentation]  Creates and returns Antl Id(s) for given ${lcr_id_list}. Optionally, ${fr_serial_number_list}
    ...    and ${antl_direction} (possible values: TX, RX or TXRX) can be specified to narrow down the Antl Id(s) search.
    ...    A single lcr_id / fr_serial_number can be passed as well.

    ${lcr_id_list}=    Convert Item To Single Element List  ${lcr_id_list}
    ${fr_sn_list}=     Convert Item To Single Element List  ${fr_serial_number_list}
    ${antl_dn_list}=   Create List
    ${antl_dn_list_TX}=  Create List
    ${antl_dn_list_RX}=  Create List
    FOR  ${lcr_id}  IN  @{lcr_id_list}
      ${cell_antl_dn_list}=  Evaluate Xpath  ${scfc_file_path}
    ...  .//managedObject[contains(@class, "CHANNEL")][contains(@distName, "LCELL-${lcr_id}/")][p[contains(text(),"TX")]]/p[@name="antlDN"]/text()
      ${antl_dn_list_TX}=  Combine Lists  ${antl_dn_list_TX}  ${cell_antl_dn_list}
      ${cell_antl_dn_list}=  Evaluate Xpath  ${scfc_file_path}
    ...  .//managedObject[contains(@class, "CHANNEL")][contains(@distName, "LCELL-${lcr_id}/")][p[contains(text(),"RX")]]/p[@name="antlDN"]/text()
      ${antl_dn_list_RX}=  Combine Lists  ${antl_dn_list_RX}  ${cell_antl_dn_list}
    END
    ${antl_dn_list}=  Run Keyword If  "${antl_direction}"=="TXRX"
    ...               Evaluate        list(set($antl_dn_list_TX).intersection($antl_dn_list_RX))
    ...   ELSE IF     "${antl_direction}"=="TX"    Set Variable    ${antl_dn_list_TX}
    ...   ELSE IF     "${antl_direction}"=="RX"    Set Variable    ${antl_dn_list_RX}
    ...   ELSE        Combine Lists   ${antl_dn_list_TX}    ${antl_dn_list_RX}
    ${antl_dn_list}=  Remove Duplicates  ${antl_dn_list}
    ${output_antl_list}=  Copy List  ${antl_dn_list}
    Return From Keyword If    not "${fr_serial_number_list}"    ${output_antl_list}
    ${rmod_id_regex}=    Set Variable  RMOD\-[
    FOR  ${fr_sn}  IN  @{fr_sn_list}
      ${rmod_id}=         SCFC Get RmodId For FR Serial Number  ${scfc_file_path}  ${fr_sn}
      ${rmod_id_regex}=    Catenate  SEPARATOR=  ${rmod_id_regex}  ${rmod_id}|
    END
    ${rmod_id_regex}=    Catenate  SEPARATOR=  ${rmod_id_regex}  ]
    FOR  ${antl}  IN  @{antl_dn_list}
      ${good_rmod}=  Run Keyword And Return Status  Should Match Regexp  ${antl}  ${rmod_id_regex}
      Run Keyword If  not ${good_rmod}  Remove Values From List  ${output_antl_list}  ${antl}
    END
    [Return]  ${output_antl_list}

SCFC Create RET Serial Number List For FR Serial Number
  [Arguments]    ${scfc_file_path}    ${fr_serial_number}
  [Documentation]    Creates and returns list of unique RET serial number(s) for given FR serial number from given SCFC file stored on local


  @{out_ret_serial_number_list}=    Create List
  ${out_ald_dist_name_list}=    SCFC Create ALD DistName List For FR Serial Number    ${scfc_file_path}    ${fr_serial_number}
  FOR    ${out_ald_dist_name}    IN    @{out_ald_dist_name_list}
    ${object_1}=  Set Variable  string(.//managedObject[@class="com.nokia.srbts.eqmr:ALD_R"
    ${object_2}=  Set Variable  p[@name="configDN"]="${out_ald_dist_name}" and p[@name="retDeviceType"]]/p[@name="serialNumber"])
    ${sum_object}=  Set Variable  ${object_1} and ${object_2}
      ${out_ret_serial_number}=   Evaluate Xpath    ${scfc_file_path}  ${sum_object}
     Run Keyword If    "${out_ret_serial_number}" != ""    Append To List    ${out_ret_serial_number_list}    ${out_ret_serial_number}
  END
  [Return]    ${out_ret_serial_number_list}

SCFC Create Antl List For RmodId
    [Arguments]    ${scfc_file_path}    ${rmod_id}
    [Documentation]    Returns list of Antl Id(s) for specific RmodId from given SCFC file stored on local Robot PC.
    ${out_antl_id_list}=    Create List
    ${out_dist_name_part}=    Evaluate Xpath    ${scfc_file_path}
    ...     substring-before(.//managedObject[@class="com.nokia.srbts.eqm:RMOD"]/@distName, RMOD)
    ${out_antl_id_count}=    Evaluate Xpath
    ...    ${scfc_file_path}
    ...    count(.//managedObject[@class="com.nokia.srbts.eqm:ANTL" and contains(@distName, "${out_dist_name_part}RMOD-${rmod_id}/ANTL-")]/@distName)
    FOR    ${out_index}    IN RANGE    1    ${out_antl_id_count+1}
        ${object_1}=  Set Variable  substring-after((.//managedObject[@class="com.nokia.srbts.eqm:ANTL" and
         ${object_2}=  Set Variable  contains(@distName, "${out_dist_name_part}RMOD-${rmod_id}/ANTL-")]/@distName)[${out_index}], "ANTL-")
        ${sum_object}=  Set Variable  ${object_1} ${object_2}
       ${out_antl_id}=    Evaluate Xpath    ${scfc_file_path}  ${sum_object}
       Append To List    ${out_antl_id_list}    ${out_antl_id}
    END
    [Return]    ${out_antl_id_list}


SCFC Create Unique MHA Serial Number List For Antl List
    [Arguments]    ${scfc_file_path}    ${antl_list}
    [Documentation]    Creates and returns list of unique MHA serial number(s) for given ANTL ID list from given SCFC file stored on local Robot PC.
    ...     NOTE: Valid since FL17SP release
    ...    Author:      artur.dobosz@nokia.com
    ...    Maintainer:  Author
    ${out_antl_dist_name_list}=    Create List
    ${out_ald_dist_name_list}=    Create List
    ${out_mha_serial_number_list}=    Create List
    FOR    ${out_antl}    IN    @{antl_list}
       ${object_1}=  Set Variable  .//managedObject[@class="com.nokia.srbts.eqm:ANTL" and contains(@distName, "/ANTL-${out_antl}")
       ${object_2}=  Set Variable  and substring-after(@distName, "/ANTL-${out_antl}")=""]/@distName
       ${sum_object}=  Set Variable  ${object_1}${object_2}
       ${out_antl_dist_name}=    Evaluate Xpath    ${scfc_file_path}  ${sum_object}
       Append To List    ${out_antl_dist_name_list}    @{out_antl_dist_name}
    END
    FOR    ${out_antl_dist_name}    IN     @{out_antl_dist_name_list}
        ${object_1}=  Set Variable  .//managedObject[@class="com.nokia.srbts.eqm:LOGLINK" and p[@name="secondEndpointDN"]
       ${object_2}=  Set Variable  ="${out_antl_dist_name}"]/p[@name="firstEndpointDN" and not(contains(text(), "/LNA-"))]/text()
       ${sum_object}=  Set Variable  ${object_1}${object_2}
       ${out_first_end_point_dn_list}=   Evaluate Xpath  ${scfc_file_path}  ${sum_object}
        ${object_1}=  Set Variable  .//managedObject[@class="com.nokia.srbts.eqm:LOGLINK" and p[@name="firstEndpointDN"]="${out_antl_dist_name}"]
       ${object_2}=  Set Variable  /p[@name="secondEndpointDN" and not(contains(text(), "/LNA-"))]/text()
       ${sum_object}=  Set Variable  ${object_1}${object_2}
       ${out_second_end_point_dn_list}=  Evaluate Xpath  ${scfc_file_path}  ${sum_object}
       Append To List  ${out_ald_dist_name_list}  @{out_first_end_point_dn_list}
       Append To List  ${out_ald_dist_name_list}  @{out_second_end_point_dn_list}
    END
    ${out_ald_dist_name_list}=    Remove Duplicates    ${out_ald_dist_name_list}
    FOR    ${out_ald_dist_name}    IN    @{out_ald_dist_name_list}
            ${object_1}=  Set Variable  string(.//managedObject[@class="com.nokia.srbts.eqm:ALD" and @distName="${out_ald_dist_name}"
       ${object_2}=  Set Variable  p[@name="mhaType"]]/p[@name="serialNumber"])
       ${sum_object}=  Set Variable  ${object_1} and ${object_2}
        ${out_mha_serial_number}=   Evaluate Xpath    ${scfc_file_path}  ${sum_object}
       Run Keyword If    "${out_mha_serial_number}" != ""    Append To List    ${out_mha_serial_number_list}    ${out_mha_serial_number}
    END
    [Return]    ${out_mha_serial_number_list}


SCFC Create FR Serial Number List For LcrId
    [Arguments]    ${scfc_file_path}    ${lcr_id}
    [Documentation]    Keyword returns FR serial number list that handle given ${lcr_id}, based on ${scfc_file_path} SCFC file.

    ${out_serial_number_list}=  Create List
    ${out_antl_list}=  Evaluate Xpath
    ...  ${scfc_file_path}
    ...  .//managedObject[contains(@class, "CHANNEL")][contains(@distName, "LCELL-${lcr_id}/")]/p[@name="antlDN"]/text()
    FOR  ${out_distname}  IN  @{out_antl_list}
       ${out_rmod_id}=   Get Regexp Matches  ${out_distname}  RMOD-\\d+
       ${out_serial_number}=  SCFC Get FR Serial Number For RmodId  ${scfc_file_path}  ${out_rmod_id[0]}
       Append To List  ${out_serial_number_list}  ${out_serial_number}
    END
    ${out_fr_serial_number_list}=  Remove Duplicates  ${out_serial_number_list}
    [Return]   ${out_fr_serial_number_list}

SCFC Get IoT LcrId Related To Given LcrId
    [Arguments]    ${scfc_file_path}    ${lcr_id}
    [Documentation]  Returns IoT cell id created on given legacy cell. If the legacy cell does not contain an IoT cell,
    ...    or the given cell id is not an IoT host cell, it returns ${EMPTY}.
    ...    Author:     michal.szajkowski@nokia.com
    ...    Maintainer: michal.szajkowski@nokia.com
    ${object_1}=  Set Variable  //managedObject[@class='NOKLTE:LNCEL' and (p[@name='lcrId']=${lcr_id})
    ${object_2}=  Set Variable  not (p[@name='cellTechnology']='NB-IoT-FDD')]/p[@name='nbIotLinkedCellId']/text()
    ${sum_object}=  Set Variable  ${object_1} and ${object_2}
    ${output}=    Evaluate Xpath    ${scfc_file_path}  ${sum_object}
    ${iot_lcr_id}=    Set Variable If    ${output}!=@{EMPTY}    ${output[0]}    ${EMPTY}
    ${iot_lcr_id}=    Convert To String  ${iot_lcr_id}
    [Return]  ${iot_lcr_id}


SCFC Create LcrId List For FR Serial Numbers List
    [Arguments]    ${scfc_file_path}    ${fr_serial_number_list}    ${cell_type}=All
    [Documentation]    Keyword returns sorted list of LcrId(s), with possible duplicates, for a list of FR serial numbers

    @{out_lcr_id_list}=    Create List
    FOR    ${out_fr_serial_number}    IN    @{fr_serial_number_list}
        ${out_lcr_id_list_for_fr}=    SCFC Create LcrId List For FR Serial Number
         ...    ${scfc_file_path}    ${out_fr_serial_number}    ${cell_type}
        Append To List    ${out_lcr_id_list}    @{out_lcr_id_list_for_fr}
    END
    Sort List    ${out_lcr_id_list}
    [Return]    ${out_lcr_id_list}


SCFC Create HW Chain List For FR Serial Number
    [Arguments]    ${scfc_file_path}    ${fr_serial_number}    ${hw}=RMOD|FHS
    [Documentation]    Creates and returns list of serial number(s) for single chain of given HW type containing specific FR serial number.
    ...    Elements of returned list are ordered ascendingly from FSM.
    ...    Maintainer:  Author
    ${sn_chain_list}=     Create List
    ${rmod_dist_name}=    SCFC Get RMOD DistName For FR Serial Number    ${scfc_file_path}    ${fr_serial_number}
    ${trash}    ${endpoint}=    Split String From Right   ${rmod_dist_name}    /    1
    FOR    ${i}    IN RANGE    1   99
      ${object_1}=  Set Variable  string(.//managedObject[p[@name="secondEndpointDN" and contains(text(), "${endpoint}")
      ${object_2}=  Set Variable  not(substring-after(text(), "${endpoint}"))]]/p[@name="firstEndpointDN"])
      ${sum_object}=  Set Variable  ${object_1} and ${object_2}
       ${endpoint}=    Evaluate Xpath    ${scfc_file_path}  ${sum_object}
       ${endpoint_match}=   Should Match Regexp    ${endpoint}    (SMOD|SMOD_EXT|BBMOD|RMOD|FHS)(?:_R)?-(\\d+)
       ${good_hw_type}=         Run Keyword And Return Status  Should Match Regexp  ${endpoint_match[1]}  ${hw}
       Exit For Loop If    not ${good_hw_type}
       ${object_1}=  Set Variable  string(.//managedObject[contains(@class, '${endpoint_match[1]}') and (p[@name="configDN"]="${endpoint}"
       ${object_2}=  Set Variable  (contains(@distName, substring-after("${endpoint}", "/")) and not(substring-after(text(), "${endpoint}"))
       ${object_3}=  Set Variable  not(p[@name="configDN"])))]/p[@name="serialNumber"])
       ${sum_object}=  Set Variable  ${object_1} or ${object_2} and ${object_3}
       ${sn}=    Evaluate Xpath    ${scfc_file_path}  ${sum_object}
       Append To List    ${sn_chain_list}    ${sn}
    END
    Reverse List    ${sn_chain_list}
    Append To List  ${sn_chain_list}    ${fr_serial_number}
    [Return]    ${sn_chain_list}

SCFC Get FR Serial Number For RmodId
    [Arguments]    ${scfc_file_path}    ${rmod_id}
    [Documentation]    Keyword returns FR serial number for given ${rmod_id}, based on ${scfc_file_path} SCFC file.
    ...    Maintainer:  Author
    ${out_rmod_id}=  Get Regexp Matches  ${rmod_id}  \\d+
    ${out_fr_serial_number}=   Evaluate Xpath  ${scfc_file_path}
    ...  string(.//managedObject[contains(p[@name='configDN'], 'RMOD-${out_rmod_id[0]}')][contains(@distName, "RMOD_R")]/p[@name='serialNumber'])
    Should Not Be Empty   ${out_fr_serial_number}
    [Return]  ${out_fr_serial_number}

Create LcrId List With Technology Type
    [Arguments]    ${scfc_file_path}    ${lcrid_list}    ${cell_technology}=FDD
    ${out_cell_technology_lcrid_list}=    Create List
    FOR    ${index}    IN    @{lcrid_list}
           ${out_lncell}=    SCFC Get LncelId For LcrId    ${scfc_file_path}   ${index}
           ${out_tmp_cell_technology}=    Get Element Text    ${scfc_file_path}
    ...         xpath=//managedObject[contains (@class,'LNCEL')][p[@name='lcrId']='${index}']/p[@name="cellTechnology"]
                       Run Keyword If    "${out_tmp_cell_technology}" == "${cell_technology}"
    ...         Append To List    ${out_cell_technology_lcrid_list}    ${index}
    END
    [Return]    ${out_cell_technology_lcrid_list}


Ims2 Get All Alarms
    [Arguments]    ${ims2_file_path}    ${act_category_alarms}    ${alias}=default    ${bts_l_id}=*
    [Documentation]    Gets all alarms which are available in provided ims2 file
    ...    Author:      slawomir.jastrzebski@nokia.com
    ...    Maintainer:  slawomir.jastrzebski@nokia.com
    @{out_alarm_list}=    Create List
    @{out_alarm_change_sets}=    Run Keyword If    ${act_category_alarms}
    ...     Get Change Sets    ${ims2_file_path}    //FRI-${bts_l_id}/ALARM-*   alias=${alias}
    ...     ELSE
    ...     Get Change Sets    ${ims2_file_path}    //LTS-${bts_l_id}//ALARM_L-*     alias=${alias}
    FOR    ${out_alarm_change}    IN    @{out_alarm_change_sets}
        Run Keyword If    '${out_alarm_change.action}' == 'Update'    Remove From Dictionary    ${out_alarm_change.object}    lastUpdateTime
        ${out_status}=    Run Keyword If    '${out_alarm_change.action}' == 'Update'
         ...               Run Keyword And Return Status    List Should Not Contain Value    ${out_alarm_list}    ${out_alarm_change.object}
         ...               ELSE    Set Variable    ${FALSE}
        Run Keyword If    ${out_status}    Append To List    ${out_alarm_list}    ${out_alarm_change.object}
    END
    [Return]    ${out_alarm_list}


#Verify HW state
#    [Arguments]    ${cfg}
#    Return From Keyword If    ${RECONFIGURATION_NOT_NEEDED}    Commissioning not needed
#    FOR    ${bts_id}    IN   @{cfg.active_bts_list}
#        Run Keyword If    ${FORCE_RESET_CONFIGURATION}
#        ...  Execute Power Reset On Node    ${cfg.test_logs_path}/setup  ${bts_id}
#        Verify HW Node state      ${cfg}     ${bts_id}    ${CONFIGURATION_STARTUP_TIMEOUT}
#    END
