*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.31_CB008219_IMF_Bypass_Mode
...  AUTHORS:       grzegorz.huchla@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check if MHA and IMF devices
...  work properly in bypass and non-bypass mode, introduced in CB008219
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  09.03.2023 - https://jiradc.ext.net.nokia.com/projects/TAW/issues/TAW-334 - Test creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
ALD.31_CB008219_IMF_Bypass_Mode

	ALD.31_CB008219_IMF_Bypass_Mode.Test_Step.0 Check If IMFs Are In Configuration
    ALD.31_CB008219_IMF_Bypass_Mode.Test_Step.1 Calculate FEG
    ALD.31_CB008219_IMF_Bypass_Mode.Test_Step.2 Switch IMFs To Bypass Mode
    ALD.31_CB008219_IMF_Bypass_Mode.Test_Step.3 Calculate FEG
    ALD.31_CB008219_IMF_Bypass_Mode.Test_Step.4 Switch Bypass Mode Off
    ALD.31_CB008219_IMF_Bypass_Mode.Test_Step.5 Calculate FEG


ALD.31_CB008219_IMF_Bypass_Mode.Test_Step.0 Check If IMFs Are In Configuration
    [Documentation]  Test step which checking if IMFs are in configuration.
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
    ${ALD_R_ALL}=  admin.get ids for all  ALD
    ${ald_parameters}=  admin.get managed objects  ALD_R
    ${ALD_R_IMFs}=  Create List
	${dn_prefix}=  Catenate  SEPARATOR=  MRBTS-${MRBTS_ID}/  EQM-1/  APEQM/
    FOR  ${ald_id}  ${ald_parameter}  IN ZIP  ${ALD_R_ALL}  ${ald_parameters}
        IF  '${ald_parameter['parameters']['productCode']}'=='E14V00P57'  Append To List  ${ALD_R_IMFs}  ${ald_id}
    END
    ${num_of_IMFs}=  Get Length  ${ALD_R_IMFs}
    Set Test Variable  ${num_of_IMFs}
    Set Test Variable  ${ALD_R_IMFs}
    IF  ${num_of_IMFs}==${0}  Fail  There is no at least one MHA of IMF in configuration
    Log  You have ${num_of_IMFs} IMFs in configuration  console=${True}


ALD.31_CB008219_IMF_Bypass_Mode.Test_Step.1 Calculate FEG
    [Documentation]  Test step which calculates FEG before changing bypass mode.
    Log to console    \n========================================
    Log  Step: 1 FEG calculation before activating bypass mode console=${True}
    Log to console    ========================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.31_CB008219_IMF_Bypass_Mode.Test_Step.2 Switch IMFs To Bypass Mode
    [Documentation]  Test step which switches MHAs and IMFs to bypass mode.
    Log to console    \n========================================
    Log  Step: 2 Switching bypass mode on  console=${True}
    Log to console    ========================================
    ${delta_bypass_on}  Set Variable  bypass_on
    admin.create delta  ${delta_bypass_on}
    ${ALD_R_to_ALD_A}=  Mapping ALD_R To ALD_A
    ${dn_prefix}=  Catenate  SEPARATOR=  MRBTS-${MRBTS_ID}/  EQM-1/  APEQM-1/  ALD-
    FOR  ${ALD}  IN  @{ALD_R_IMFs}
        Log  ----- Bypass mode true on ${ALD}   console=${True}
        ${item}=  Get From Dictionary  ${ALD_R_to_ALD_A}  ${ALD}
        ${ignore}  ${ALD_A}=  Split String From Right  ${item}  separator=APEQM_A-1/
    	${ALD_A_id}=  Evaluate  re.search(r'ALD_A-(\\d+)','''${ALD_A}''').group(1)  re
    	${lna_DN}=  Catenate  SEPARATOR=  ${dn_prefix}  ${ALD_A_id}/  LNA-1
        admin.append parameter update to delta  ${lna_DN}  mode  true  ${delta_bypass_on}
    END
    admin.get delta  ${delta_bypass_on}
    ${json_path}=  Set Variable  ${RESULTS}/delta_bypass_on.json
    admin.save delta  ${json_path}  ${delta_bypass_on}
    admin.perform delta recommissioning  ${json_path}  ${skip_parameter_relation_errors}  ${should_activate}
    Log  ----- Waiting 240 seconds for IMF to apply changes  console=${True}
    Sleep  240s

ALD.31_CB008219_IMF_Bypass_Mode.Test_Step.3 Calculate FEG
    [Documentation]  Test step checking FEG after switching bypass mode on.
    Log to console    \n========================================
    Log  Step: 3 FEG calculation after activating bypass mode  console=${True}
    Log to console    ========================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.31_CB008219_IMF_Bypass_Mode.Test_Step.4 Switch Bypass Mode Off
    [Documentation]  Test step which switches bypass mode off.
    Log to console    \n========================================
    Log  Step: 4 Switch bypass mode off  console=${True}
    Log to console    ========================================
    ${delta_bypass_off}  Set Variable  bypass_off
    admin.create delta  ${delta_bypass_off}
    ${ALD_R_to_ALD_A}=  Mapping ALD_R To ALD_A
    ${dn_prefix}=  Catenate  SEPARATOR=  MRBTS-${MRBTS_ID}/  EQM-1/  APEQM-1/  ALD-
    FOR  ${ALD}  IN  @{ALD_R_IMFs}
        Log  ----- Bypass mode false on ${ALD}   console=${True}
        ${item}=  Get From Dictionary  ${ALD_R_to_ALD_A}  ${ALD}
        ${ignore}  ${ALD_A}=  Split String From Right  ${item}  separator=APEQM_A-1/
    	  ${ALD_A_id}=  Evaluate  re.search(r'ALD_A-(\\d+)','''${ALD_A}''').group(1)  re
    	  ${lna_DN}=  Catenate  SEPARATOR=  ${dn_prefix}  ${ALD_A_id}/  LNA-1
        admin.append parameter update to delta  ${lna_DN}  mode  false  ${delta_bypass_off}
    END
    admin.get delta  ${delta_bypass_off}
    ${json_path}=  Set Variable  ${RESULTS}/delta_bypass_ff.json
    admin.save delta  ${json_path}  ${delta_bypass_off}
    admin.perform delta recommissioning  ${json_path}  ${skip_parameter_relation_errors}  ${should_activate}
    Log  ----- Waiting 240 seconds for IMF to apply changes  console=${True}
    Sleep  240s

ALD.31_CB008219_IMF_Bypass_Mode.Test_Step.5 Calculate FEG
    [Documentation]  Test step which checks FEG after switching bypass mode off.
    Log to console    \n========================================
    Log  Step: 5 Calculate FEG after deactivating bypass mode  console=${True}
    Log to console    ========================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA


ALD.31_CB008219_IMF_Bypass_Mode.Test Specific Teardown
    [Documentation]  Test teardown which restores original configuration settings.
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}


ALD.31_CB008219_IMF_Bypass_Mode.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keywords
    ...  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    ...  AND  ALD.31_CB008219_IMF_Bypass_Mode.Test Specific Teardown
