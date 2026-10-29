*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode
...  AUTHORS:       grzegorz.huchla@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is check if switching operating mode in
...	 multi-band MHA wokrs properly, introduced in CB008219
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  09.03.2023 - https://jiradc.ext.net.nokia.com/projects/TAW/issues/TAW-341 - Test creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${PATTERN_DUALBAND_MHA}  (CS7299440|474128A|473050A|474721A|472962A|474127A|473051A|474794A
...  |475588A|474140A|473054A|474322A|473055A|473056A|474321A|473057A|473845A|474628A|474935A)
${PATTERN_TRIPLEBAND_MHA}  (474452A|474061A|474375A|474165A)

*** Keywords ***
ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode

    ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode.Test_Step.0 Check If Multi-Band MHAs Are In Configuration
    ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode.Test_Step.1 Calculate FEG
    ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode.Test_Step.2 Switch Multi-Band MHAs to 2XTWO mode
    ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode.Test_Step.3 Calculate FEG
	  ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode.Test_Step.4 Switch Multi-Band MHAs to TWOTWO mode
	  ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode.Test_Step.5 Calculate FEG

ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode.Test_Step.0 Check If Multi-Band MHAs Are In Configuration
    [Documentation]  Test step which checking if MHAs and IMFs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${COMMISSIONING_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml
    ${SCF_exist}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${COMMISSIONING_PATH}
    IF  not ${SCF_exist}  Fail  msg=File /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml not exist
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Log  Activation plan...  console=${true}
    admin.perform commissioning  ${MRBTS_ID}  ${COMMISSIONING_PATH}  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}  timeout=600
	Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
    Check ALDs State  ${ALD_expected_states}
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${ALD_R_MHAs}
    Set Test Variable  ${num_of_MHAs}
    ${ALD_A_to_productcode}=  Mapping MHA ALD_A To ProductCode
    ${dual_band_MHAs}  Detect Dual Band MHA Connected To BTS  ${ALD_A_to_productcode}
    ${triple_band_MHAs}  Detect Triple Band MHA Connected To BTS  ${ALD_A_to_productcode}
    Set Test Variable  ${dual_band_MHAs}
    Set Test Variable  ${triple_band_MHAs}
    ${num_of_dual_band_MHAs}=  Get Length  ${dual_band_MHAs}
	  ${num_of_triple_band_MHAs}=  Get Length  ${triple_band_MHAs}
    ${num_of_multi_band_MHAs}=  Evaluate  ${num_of_dual_band_MHAs}+${num_of_triple_band_MHAs}
	  Set Test Variable  ${num_of_multi_band_MHAs}
    ${multi_band_MHAs}=  Evaluate  ${dual_band_MHAs}+${triple_band_MHAs}
  	Set Test Variable  ${multi_band_MHAs}
  	@{multi_band_MHAs_R}=  Create List
  	${ALD_A_to_ALD_R}=  Mapping ALD_A To ALD_R
  	FOR  ${mha}  IN  @{multi_band_MHAs}
		    ${item}=  Get From Dictionary  ${ALD_A_to_ALD_R}  ${mha}
		    Append To List  ${multi_band_MHAs_R}  ${item}
	  END
	  Set Test Variable  ${multi_band_MHAs_R}
    IF  ${num_of_multi_band_MHAs}==${0}  Fail  msg=There is no at least one Mulit-Band MHA in configuration
    Log  You have ${num_of_multi_band_MHAs} Multi-Band MHAs in configuration  console=${True}

ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode.Test_Step.1 Calculate FEG
    [Documentation]  Test step which calculates FEG before changing operating mode.
    Log to console    \n========================================
    Log  Step: 1 FEG calculation before activating bypass mode  console=${True}
    Log to console    ========================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode.Test_Step.2 Switch Multi-Band MHAs to 2XTWO mode
  	[Documentation]  Test step which calculates FEG before changing operating mode.
  	Log to console    \n========================================
  	Log  Step: 2Setting 2XTWIN mode on multi-band MHAs  console=${True}
  	Log to console    ========================================
  	${pre_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
  	${delta_2xtwo}  Set Variable  2xtwo
  	admin.create delta  ${delta_2xtwo}
  	### check dn prefix
  	${dn_prefix}=  Catenate  SEPARATOR=  MRBTS-${MRBTS_ID}/  EQM-1/  APEQM-1/  ALD-
  	${parameter}=  Set Variable  installDate
  	${ALD_R_to_ALD_A}=  Mapping ALD_R To ALD_A

    FOR  ${mha}  IN  @{multi_band_MHAs}
    	Log  ----- installDate set to 2XTWIN for ${mha}
    	${ignore}  ${ALD_A}=  Split String From Right  ${mha}  separator=APEQM_A-1/
    	${ALD_A_id}=  Evaluate  re.search(r'ALD_A-(\\d+)','''${ALD_A}''').group(1)  re
    	${lna_DN}=  Catenate  SEPARATOR=  ${dn_prefix}  ${ALD_A_id}/  LNA-1
    	admin.append parameter update to delta  ${lna_DN}  ${parameter}  2XTWIN  ${delta_2xtwo}
    END
  	admin.get delta  ${delta_2xtwo}
  	${json_path}=  Set Variable  ${RESULTS}/delta_2xtwo.json
  	admin.save delta  ${json_path}  ${delta_2xtwo}
  	admin.perform delta recommissioning  ${json_path}  ${skip_parameter_relation_errors}  ${should_activate}
  	${post_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Log  Reset counter after applying delta: ${post_action_reset_number}  console=${True}
    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
  	FOR  ${mha}  IN  @{multi_band_MHAs_R}
  		Create Delta Remove For Selected ALD  ${mha}  deviceType=MHA
  	END
  	Set Test Variable  ${COMMISSIONING_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml
    ${SCF_exist}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${COMMISSIONING_PATH}
    IF  not ${SCF_exist}  Fail  msg=File /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml not exist
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Log  Activation plan...  console=${true}
    admin.perform commissioning  ${MRBTS_ID}  ${COMMISSIONING_PATH}  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}  timeout=600
  	Check SMODs State  ${SMOD_expected_states}
  	Check RMODs State  ${RMOD_expected_states}
  	Check ALDs State  ${ALD_expected_states}
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB

ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode.Test_Step.3 Calculate FEG
    [Documentation]  Test step checking FEG after switching bypass mode on.
    Log to console    \n========================================
    Log  Step: 3 FEG calculation after changing operating mode  console=${True}
    Log to console    ========================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode.Test_Step.4 Switch Multi-Band MHAs to TWOTWO mode
    [Documentation]  Test step which calculates FEG before changing operating mode.
    Log to console    \n========================================
    Log  Step: 2Setting TWOTWO mode on multi-band MHAs  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    ${delta_twotwo}  Set Variable  twotwo
    admin.create delta  ${delta_twotwo}
    ${dn_prefix}=  Catenate  SEPARATOR=  MRBTS-${MRBTS_ID}/  EQM-1/  APEQM-1/  ALD-
    ${parameter}=  Set Variable  installDate
    ${ALD_R_to_ALD_A}=  Mapping ALD_R To ALD_A
    FOR  ${mha}  IN  @{multi_band_MHAs}
      Log  ----- installDate set to TWOTWO for ${mha}
      ${ignore}  ${ALD_A}=  Split String From Right  ${mha}  separator=APEQM_A-1/
      ${ALD_A_id}=  Evaluate  re.search(r'ALD_A-(\\d+)','''${ALD_A}''').group(1)  re
      ${lna_DN}=  Catenate  SEPARATOR=  ${dn_prefix}  ${ALD_A_id}/  LNA-1
      admin.append parameter update to delta  ${lna_DN}  ${parameter}  TWOTWO  ${delta_twotwo}
    END
    admin.get delta  ${delta_twotwo}
    ${json_path}=  Set Variable  ${RESULTS}/delta_twotwo.json
    admin.save delta  ${json_path}  ${delta_twotwo}
    admin.perform delta recommissioning  ${json_path}  ${skip_parameter_relation_errors}  ${should_activate}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Log  Reset counter after applying delta: ${post_action_reset_number}  console=${True}
    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
    FOR  ${mha}  IN  @{multi_band_MHAs_R}
      Create Delta Remove For Selected ALD  ${mha}  deviceType=MHA
    END
    Set Test Variable  ${COMMISSIONING_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml
    ${SCF_exist}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${COMMISSIONING_PATH}
    IF  not ${SCF_exist}  Fail  msg=File /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml not exist
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Log  Activation plan...  console=${true}
    admin.perform commissioning  ${MRBTS_ID}  ${COMMISSIONING_PATH}  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}  timeout=600
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check ALDs State  ${ALD_expected_states}
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB

ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode.Test_Step.5 Calculate FEG
    [Documentation]  Test step checking FEG after switching bypass mode on.
    Log to console    \n========================================
    Log  Step: 3 FEG calculation after changing operating mode  console=${True}
    Log to console    ========================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode.Test Specific Teardown
    [Documentation]  Test teardown which restores original configuration settings.
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Log  \nRestoring original configuration settings  console=${True}
    admin.perform commissioning  ${MRBTS_ID}  ${COMMISSIONING_PATH}  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}  timeout=600
	Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check ALDs State  ${ALD_expected_states}
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    admin.teardown admin  alias=${ute_admin_alias}

ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keywords
    ...  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    ...  AND  ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode.Test Specific Teardown
