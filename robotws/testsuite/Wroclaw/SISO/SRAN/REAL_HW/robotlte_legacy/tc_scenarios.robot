*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Resource  ../Resources/Setup/setup_and_teardown.robot
Resource  ./site_operations.robot
Resource  ./site_verifications.robot
Resource  ./variables.robot
Resource  ./common_setup.robot

Library  BuiltIn
Library  Collections
Library  String
Library  robot.libraries.DateTime
Library  taf.sbts.oam.coam.admin    WITH NAME    admin
Library  ute_admin_infomodel    WITH NAME    admin_im
Library  taf.fdsw.rc  WITH NAME  rc

Resource  ./sw_mngt.robot
Resource  ./site_operations.robot
Resource  ./site_verifications.robot
Resource  ./variables.robot
Resource  ./sw_upgrade_path.robot
Resource  ./pmax.robot
Resource  ./rtwp.robot
Resource  ./lte_rat_reset.robot
Resource  ./nr_rat_reset.robot
Resource  ./sfp_monitoring.robot
Resource  ./check_ret_status.robot
Resource  ./ALD_cs.robot
Resource  ./factory_sw.robot
Resource  ./delta_commissioning.robot
Resource  ./radio_operations.robot
Resource  ./bbpool_allocation.robot
Resource  ./recovery_counter.robot
Resource  ./startup_with_RF_delayed_startup.robot
Resource  ./24H_Stability_without_reset.robot
Resource  ./memory_consumption.robot
#Resource  ./SiSo_L3_Call.robot
Resource  ../Resources/SiSo_L3_call.robot
Resource  ./Test_Cases/EAC_cs.robot
Resource  ./Test_Cases/PIMC_cs.robot
Resource  ./Test_Cases/RFV_cs.robot
Resource  ./Test_Cases/slim_carrier.robot
Resource  ./Test_Cases/Parameter_Commissioning.robot
Resource  ./Test_Cases/Optical_Hot_remove/lg_hr_infomodel.robot
Resource  ./Test_Cases/Optical_Hot_remove/lg_hr_keywords_new.robot
Resource  ./Test_Cases/Optical_Hot_remove/lg_hr_switch.robot
Resource  ./Test_Cases/check_linkSpeed_FHS.robot

Library  ./Test_Cases/info_model_alarms.py
Library  ./Test_Cases/admin_alarms.py
Library  ./factory_sw_download.py
Resource  ./Test_Cases/RF_Alarms/test_cases.robot
Resource  ./Test_Cases/RF_Alarms/rf_alarms_keywords.robot

Library  ./rf_alarms_operations.py

Variables    ./legacy_variables.py


*** Keywords ***
Startup_Site_Reset Without HWF
  [Documentation]
  ...  NOTE. If test used with OBSAI RUs (dual link), fault 1811 Warning can appear. Please adjust accordingly your TS allowed faults.
  Common Test Setup
  Logging With Timestamp
  ...  message=Execute Site Reset On Every Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  Remove HWF File
  Gather Start Time
  FOR  ${bts}  IN  @{cfg.active_bts_list}
    Execute Reset On Node  ${bts}
    CM BTS Admin Not Available
    ...  node=${bts}
    ...  timeout=120
    Verify BTS State  ${bts}  ${CONFIGURATION_STARTUP_TIMEOUT}
    Verify Startup Parameters  ${test_logs_path}  ${bts}
    Verify Unexpected And Historical Alarms  alias=${bts}
  END
  [Teardown]   Run Keywords
  ...  Gather Stop Time
  ...  AND  Execute UUF Report  ${test_logs_path}  Reset
  ...  AND  Common Test Teardown



Automated_SiSo_STARTUP_BTS_Startup_RF_Delayed_Startup
  [Documentation]
  ...  Purpose of this test is to automate BTS restart with one of RM turned off for time needed to fault
  ...  10 to be visible on RM. After that RM is turned on and all faults and alarms are checked.
  ...  If any alarms were found during whole duration of test it will result in fail at the end of the test.
  ...  User can provide two parameters:
  ...  Delay - time delay after fault 10 is found and power on RM is turned on.
  ...  RF -  Serial number of RF that should be turn on with delay
  ...  If user won't provide those parameters they will default to 0 secound and random RM to be turned off.
  [Arguments]  &{setup_kwargs}
  Common Test Setup
  Logging With Timestamp
  ...  message=Execute Perform BTS Startup With RF Delayed Startup On Every Node : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  Perform BTS Startup With RF Delayed Startup On Every Node  &{setup_kwargs}
  [Teardown]  Common Test Teardown



Automated_SiSo_TEST_Stability_Without_Reset
  [Documentation]
  ...  Purpose of this test is to check stability of BTS over longer period of time i.e. 24 hours or more.
  ...  Test will periodically perform operations that don't require reset: collecting snapshot,
  ...  block/unblock cells, start/stop and gather antenna line monitoring.
  ...  Implemented watchdog feature will check for any unexpected alarms.
  ...  If any alarms were found during whole duration of test it will result in fail at the end of the test.
  ...  User can provide two parameters:
  ...  Interval - time between cycles of operations (in minutes e.g. Interval=20 )
  ...  Total_Time - estimated total time that test should go on (in minutes e.g. Total_Time=60 )
  ...  If user won't provide those parameters they will default to 24 hours of total time with 60 minutes intervals.
  [Arguments]  &{setup_kwargs}
  Common Test Setup  tools_to_setup=syslog_ADMIN
  Logging With Timestamp
  ...  message=Perform BTS Startup With RF Delayed Startup On Every Node: @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  Perform Stability Test Without Reset
  [Teardown]  Common Test Teardown


Delta Recommissioning
  Common Test Setup
  Logging With Timestamp
  ...  message=Perform BTS Startup With RF Delayed Startup On Every Node: @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  Execute Delta Recommissioning On Every Node
  [Teardown]  Run Keywords
  ...  Force Recommissioning With Current Branch On Every Node  AND
  ...  Common Test Teardown

#Site SW upgrade Path
#  [Arguments]  ${test_logs_path}=${cfg.test_logs_path}
#  Precondition SW Upgrade Path TC  ${test_logs_path}
#  Execute Site SW upgrade Path On Every Node  ${test_logs_path}
#  [Teardown]  Postcondition Basic TC  ${test_logs_path}  status=${KEYWORD STATUS}
#
#Site SW upgrade Path_repetition
#  Execute Single Run TC  Site SW upgrade Path
#  Execute Multiple TC Runs  Site SW upgrade Path
#
#Execute Single Run TC
#  [Arguments]  ${tc}
#  Run Keyword If  not ${REPETITION}  ${tc}  ${cfg.test_logs_path}

#Execute Multiple TC Runs
#  [Arguments]  ${tc}
#  Run Keyword If  not ${REPETITION}  Return From Keyword
#  FOR  ${repetition_index}  IN  @{REPETITION_LIST}
#  \  ${loop_log_path}=  TC Repetition Loop Start  ${REPETITION}  ${repetition_index}
#  \  Run Keyword And Continue On Failure  ${tc}  ${loop_log_path}
#  \  TC Repetition Loop Stop  ${REPETITION}  ${repetition_index}


SiSo Basic L3 Call
  Common Test Setup
  Logging With Timestamp
  ...  message=Perform SiSo Basic L3 Call: @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  Set Test Variable  ${LOGS_DIR}  ${TEST_LOGS_PATH}
  SiSo Precondition Basic L3 Call TC
  Run Keyword If  "${REPETITION_COUNT}"=="1"  SiSo Convert Id to Runtime Distname  connection=any
  SiSo L3 Call
  [Teardown]  Common Test Teardown

Perform_Pmax_Verification
  Common Test Setup
  Logging With Timestamp
  ...  message=Perform_Pmax_Verification: @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  Perform Pmax Verification On Every Node
  [Teardown]  Common Test Teardown

#SW Upgrade UUF Path
#  Precondition Branch Update TC  ${cfg.test_logs_path}
#  Execute SW Upgrade On Every Node  ${cfg.test_logs_path}
#  Refresh SW active state
#  Rollback Software On Every Node  ${cfg.test_logs_path}
#  [Teardown]  Run Keywords
#  ...  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'
#  ...  Force Recommissioning With Current Branch On Every Node
#  ...  AND  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL' or '${rollback_status}' == 'True'
#  ...  Execute SW Upgrade On Every Node  ${cfg.test_logs_path}
#  ...  AND  Postcondition Basic TC  ${cfg.test_logs_path}  status=${KEYWORD STATUS}
#
#SW Upgrade UUF Path With Repetiton
##  ${rollback_status}=  Get Variable Value  ${cfg.ROLLBACK}  False
##  Set Test Variable  ${rollback_status}  ${rollback_status}
#  Precondition Branch Update TC  ${cfg.test_logs_path}
#  Run Keyword If  not ${REPETITION}  Run Keywords
#  ...  Logging Multinode Start  ${cfg.test_logs_path}
#  ...  AND  Gather Start Time
#  ...  AND  Execute SW Upgrade On Every Node  ${cfg.test_logs_path}
#  ...  AND  Refresh SW active state
#  ...  AND  Rollback Software On Every Node  ${cfg.test_logs_path}
#  ...  AND  Gather Stop Time
#  ...  AND  Execute UUF Report  ${cfg.test_logs_path}  Upgrade
#  ...  AND  Log Variables
#  ...  AND  Postcondition Basic TC  ${cfg.test_logs_path}  status=PASS
#  Run Keyword If  not ${REPETITION}  Return From Keyword
#  FOR  ${repetition_index}  IN  @{REPETITION_LIST}
#    TC Repetition Loop Start  ${REPETITION}  ${repetition_index}
#    Logging Multinode Start  ${cfg.test_logs_path}
#    Gather Start Time
#    Execute SW Upgrade On Every Node  ${cfg.test_logs_path}
#    Refresh SW active state
#    Rollback Software On Every Node  ${cfg.test_logs_path}
#    Gather Stop Time
##  TC Repetition Loop Stop  ${REPETITION}  ${repetition_index}  ${KEYWORD STATUS}
#    Execute UUF Report  ${cfg.test_logs_path}  Upgrade
#    Log Variables
#    Postcondition Basic TC  ${cfg.test_logs_path}  status=PASS
#  END
#  [Teardown]  Run Keywords
#  ...  Logging Multinode Start  ${cfg.test_logs_path}
#  ...  AND  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'
#  ...  Execute Recommissioning On Every Node  ${cfg.test_logs_path}
#  ...  AND  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL' or '${rollback_status}' == 'True'
#  ...  Execute SW Upgrade On Every Node  ${cfg.test_logs_path}
#  ...  AND  Postcondition Basic TC  ${cfg.test_logs_path}  status=${KEYWORD STATUS}

#SW Upgrade UUF CSV4ALL
#  Precondition UUF Update TC  ${cfg.test_logs_path}
##  e2e_parallel_sw_upgrade  ${UUF_NODES}  ${UUF_NODES}  ${ITERATIONS}  customers_list=${CUSTOMERS}  report=${UUF_REPORT}
#  e2e_tl_sw_upgrade_rollback_with_oam_kpi
#  ...  ${UUF_NODES}
#  ...  ${UUF_NODES}
#  ...  ${ITERATIONS}
#  ...  customers_list=${CUSTOMERS}
#  ...  report=${UUF_REPORT}
#  [Teardown]  Run Keywords
#  ...  Logging Multinode Start  ${cfg.test_logs_path}
#  ...  AND  Run Keyword If  '${KEYWORD STATUS}' == 'FAIL' or '${rollback_status}' == 'True'
#  ...  Execute SW Upgrade On Every Node  ${cfg.test_logs_path}
#  ...  AND  Postcondition Basic TC  ${cfg.test_logs_path}  status=${KEYWORD STATUS}

Automated__SiSo__RTWP_check
  [Documentation]
  ...  Purpose of this test is checking if RTWP values for LTE and WCDMA cells are properly measeured
  ...
  ...  Parameters:
  ...  Name  |  Mandatory  |  Default value  |  Description
  ...  perform_reset  |  no  |  ${TRUE}  |  if ${FALSE} reset will not be performed
  ...  RTWP_measuring_time |  no  |  600  |  RTWP measuring time in seconds, default
  ...  |  |  |  value used if not provided by 'Test
  ...  |  |  |  Basic Precondition'
  ...  RTWP_min  |  no  |  -110  |  min. RTWP value
  ...  RTWP_max  |  no  |  -70  |  max RTWP value
  ...  test_logs_path  |  no  |  cfg.test_logs_path  |  Path to test logs
  ...  alias  |  no  |  cfg.primary_node_bts_id  |  alias of admin connection
  ...
  ...  Additional parameter:BTS_stability_time  -  can be defined by 'Test Basic Precondition'
  ...  BTS_stability_time  -  waiting time to BTS stability after reset - can be defined by 'Test Basic Precondition'
  ...  as a number (in sec) or string (20s, 10 min)
  ...  if not defined - default value will be used (15 min)
  ...
  Common Test Setup
  Logging With Timestamp
  ...  message=Automated__SiSo__RTWP_check @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  Run keyword if  ${CUSTOM_PERFORM_RESET}
  ...  Step 1: Site reset and wait for onAir
  Step 2: Check RTWP  ${RTWP_measuring_time}
  [Teardown]  Common Test Teardown


# Automated__SiSo__LTE_RAT_reset_from_ADMIN_repetition
#  Run Keyword If  not ${REPETITION}  Perform_LTE_RAT_reset_from_ADMIN  ${cfg.test_logs_path}
#  Run Keyword If  not ${REPETITION}  Return From Keyword
#  :FOR  ${repetition_index}  IN  @{REPETITION_LIST}
#  \  ${loop_log_path}=  TC Repetition Loop Start  ${REPETITION}  ${repetition_index}
#  \  Run Keyword And Continue On Failure  Perform_LTE_RAT_reset_from_ADMIN  test_logs_path=${loop_log_path}
#  \  TC Repetition Loop Stop  ${REPETITION}  ${repetition_index}
#
# Perform_LTE_RAT_reset_from_ADMIN
#  [Arguments]  ${test_logs_path}=${cfg.test_logs_path}
#  Precondition Basic TC  ${test_logs_path}
#  Perform LTE RAT reset from ADMIN On Every Node  ${test_logs_path}
#  [Teardown]  Postcondition Basic TC  ${test_logs_path}  status=${KEYWORD STATUS}

Automated__SiSo__SFP_Monitoring_static_parameters
  [Documentation]
  ...  Purpose of this test is to verify that  SFP Diagnostic objects are  created in right way.
  ...  It is needed to store sfp*.yaml file in <testline_folder>/device
  ...  If there are more than one sfp file - the filneme must be provided as variable
  ...  'sfp_filename' by 'Test Basic Precondition'
  ...  Example:
  ...  Automatic][1.0] Automated__SiSo__BS-FV__SFP_Monitoring_static_parameters
  ...  [Setup]  Testcase Basic Precondition  CN=CONF_5G_AAHF1  sfp_filename=sfp_AAHF1.yaml
  ...  Automated__SiSo__SFP_Monitoring_static_parameters
  ...  [Teardown]  Testcase Basic Postcondition
  Common Test Setup
  Logging With Timestamp
  ...  message=Automated__SiSo__SFP_Monitoring_static_parameters: @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  Step 1: Get config parameters
  Step 2: Check SFP parameters  alias=${RMOD_NODE}
  [Teardown]  Common Test Teardown


Automated__SiSo__FV_Testing_RET_status
  [Documentation]
  ...  Purpose of this test is checking if RET unit is correctly detected
  ...
  ...  Parameters:
  ...  Name  |  Mandatory  |  Default value  |  Description
  ...  test_logs_path  |  no  |  cfg.test_logs_path  |  Path to test logs
  ...  alias  |  no  |  cfg.primary_node_bts_id  |  alias of admin connection
  Common Test Setup
  Logging With Timestamp
  ...  message=Automated__SiSo__FV_Testing_RET_status: @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  Step 1: Check alarms  ${alias}
  Step 2: Check RET status  ${alias}
  Step 3: Check alarms  ${alias}
  [Teardown]  Common Test Teardown


Automated__SiSo__FV_Testing_RET_RF_specific_status
  [Documentation]
  ...  Purpose of this test is checking if RET unit is correctly detected
  ...
  ...  Parameters:
  ...  Name  |  Mandatory  |  Default value  |  Description
  ...  test_logs_path  |  no  |  cfg.test_logs_path  |  Path to test logs
  ...  alias  |  no  |  cfg.primary_node_bts_id  |  alias of admin connection
  ...
  Common Test Setup
  Logging With Timestamp
  ...  message=Automated__SiSo__FV_Testing_RET_RF_specific_status: @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  Check RET RF status
  [Teardown]  Common Test Teardown

Automated__SiSo__FV_Testing_MHA_status
  [Documentation]
  ...  Purpose of this test is checking if MHA unit is correctly detected
  ...
  ...  Parameters:
  ...  Name  |  Mandatory  |  Default value  |  Description
  ...  test_logs_path  |  no  |  cfg.test_logs_path  |  Path to test logs
  ...  alias  |  no  |  cfg.primary_node_bts_id  |  alias of admin connection
  ...
  Common Test Setup
  Logging With Timestamp
  ...  message=Automated__SiSo__FV_Testing_MHA_status: @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  SiSo__FV_Testing_MHA_status
  [Teardown]  Common Test Teardown


Automated__SiSo__FV_Testing_Fiber_length
  [Documentation]
  ...  Purpose of this test is checking if fiber length on each RF cablink unit is correct
  ...  RF=L1154809204|L6141629878
  Common Test Setup
  Logging With Timestamp
  ...  message=Automated__SiSo__FV_Testing_Fiber_length: @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  Check Fiber Length Of FR Cablnks
  [Teardown]  Common Test Teardown


Automated_SiSo_cell_allocation_acording_to_logical_group_L1balance
  Common Test Setup
  Logging With Timestamp
  ...  message=Automated_SiSo_cell_allocation_acording_to_logical_group_L1balance: @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  FOR  ${node}  IN  @{cfg.active_bts_list}
    Execute ABIO L1 Balanced Cell Test On Every Node  ${cfg}  ${node}  ${test_logs_path}
  END
  [Teardown]  Run Keywords
  ...  Force Recommissioning With Current Branch On Every Node  AND
  ...  Common Test Teardown

Recovery Reset Counter Exceeded Cleared
  Common Test Setup
  Logging With Timestamp
  ...  message=Recovery Reset Counter Exceeded Cleared: @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  Radio List Recovery Reset Counter Exceeded Cleared
  [Teardown]  Common Test Teardown


Static Power Saving For ABIO And ASOE
  Common Test Setup
  Logging With Timestamp
  ...  message=Static Power Saving For ABIO And ASOE: @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  Static Power Saving For ABIO And ASOE On Every Node
  [Teardown]  Common Test Teardown

FHS Link Hot Remove Insert
  Common Test Setup
  Logging With Timestamp
  ...  message=FHS Link Hot Remove Insert: @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  Execute FHS Link Hot Remove Insert On Every Node
  Execute Check Link Speed Under FHS On Every Node

  [Teardown]  Common Test Teardown


Allocation of cells to baseband pools using manual mode tc
  Common Test Setup
  Logging With Timestamp
  ...  message=Allocation of cells to baseband pools using manual mode tc: @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  Allocation of cells to baseband pools using manual mode
  [Teardown]  Common Test Teardown
