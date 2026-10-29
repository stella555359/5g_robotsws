*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.03_ALD_Additional_data_for_ALDs
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check if additional data are properly sent to ALD device.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  7.7.2017 https://jira3.int.net.nokia.com/browse/TAT-7076
...  15.05.2018 - Test creation
...  21.06.2018 - Test review
...  16.11.2018 - https://jira3.int.net.nokia.com/browse/TAT-13182
...  12.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14560
...  03.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-15283
...  13.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16525
...  27.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16719
...  12.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17352
...  07.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17802
...  28.07.2021 - https://jira3.int.net.nokia.com/browse/TAT-21670
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  07.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-77 - Adaptation to CNI-64298
...  09.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-102 - Increase timeouts and add BTS state checks
...  05.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-143 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  24.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-309 - Remove Comba RET antModel from Additional Data
...  12.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-438 - Add exception for IMF in Additional data for ALDs
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
ALD.03_ALD_Additional_data_for_ALDs

	ALD.03_ALD_Additional_data_for_ALDs.Test_Step.0 Check If ALDs Are In Configuration
    ALD.03_ALD_Additional_data_for_ALDs.Test_Step.1 Change Additional Data For RET And Compare Data Before And After BTS Reset
    ALD.03_ALD_Additional_data_for_ALDs.Test_Step.2 Change Additional Data For MHA And Compare Data Before And After BTS Reset

ALD.03_ALD_Additional_data_for_ALDs.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${num_of_MHAs}
    Set Test Variable  ${num_of_RETs}
    Set Test Variable  ${ALD_R_RETs}
    Set Test Variable  ${ALD_R_MHAs}
    IF  ${num_of_MHAs}==${0} and ${num_of_RETs}==${0}  Fail  msg=There is no at least one ALD in configuration
    Log  You have ${num_of_MHAs} MHAs and ${num_of_RETs} RETs in configuration  console=${True}

ALD.03_ALD_Additional_data_for_ALDs.Test_Step.1 Change Additional Data For ${type} And Compare Data Before And After BTS Reset
    [Documentation]  Test step which changing Additional Data for ${type} device.
    Log to console    \n========================================
    Log  Step: 1 Change Additional Data For ${type} And Compare Data Before And After BTS Reset  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
	Log  Changing Additional Data for ${type} device  console=${True}
	IF  ${num_of_RETs} != ${0}
	    ${ALD_R_dn}  ${ald_item}  Delta With Additional Data Parameters  ${type}
	ELSE
	    Log  There is no ${type} in configuration  console=${True}
	END
	IF  ${num_of_RETs} != ${0}
	    Sleep  20s
	    Wait Until Keyword Succeeds  80s  20s  Compare Additional Data  ${type}  ${ALD_R_dn}  ${ald_item}
	    Log  BTS Reset site...  console=${true}
	    admin.reset site  timeout=700
	    Check SMODs State  ${SMOD_expected_states}
	    Check RMODs State  ${RMOD_expected_states}
	    Check ALDs State  ${ALD_expected_states}
	    common.Check BTS State  ${BTS_expected_states}
	    Check If NLWG Cells Are OnAir
	    Check If Unexpected Alarms Are Raised  ${skip_fault}
	    Wait Until Keyword Succeeds  1min  20s  Compare Additional Data  ${type}  ${ALD_R_dn}  ${ald_item}
	END
	Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB

ALD.03_ALD_Additional_data_for_ALDs.Test_Step.2 Change Additional Data For ${type} And Compare Data Before And After BTS Reset
    [Documentation]  Test step which changing Additional Data for ${type} device.
    Log to console    \n========================================
    Log  Step: 2 Change Additional Data For ${type} And Compare Data Before And After BTS Reset  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
	Log  Changing Additional Data for ${type} device  console=${True}
	IF  ${num_of_MHAs} != ${0}
	    ${ALD_R_dn}  ${ald_item}  Delta With Additional Data Parameters  ${type}
	ELSE
	    Log  There is no ${type} in configuration  console=${True}
	END
    IF  ${num_of_MHAs} != ${0}
	    Sleep  20s
	    Wait Until Keyword Succeeds  80s  20s  Compare Additional Data  ${type}  ${ALD_R_dn}  ${ald_item}
	    Log  BTS Reset site...  console=${true}
	    admin.reset site  timeout=700
	    Check SMODs State  ${SMOD_expected_states}
	    Check RMODs State  ${RMOD_expected_states}
	    Check ALDs State  ${ALD_expected_states}
	    common.Check BTS State  ${BTS_expected_states}
	    Check If NLWG Cells Are OnAir
	    Check If Unexpected Alarms Are Raised  ${skip_fault}
	    Wait Until Keyword Succeeds  1min  20s  Compare Additional Data  ${type}  ${ALD_R_dn}  ${ald_item}
	END
	Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
	Check If Unexpected Alarms Are Raised  ${skip_fault}

Delta With Additional Data Parameters
    [Documentation]  This keyword create delta commissioning which change additional data for RET and MHA.
    [Arguments]  ${type}
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Log  Reset counter before applying delta: ${pre_action_reset_number}  console=${True}
    IF  '${type}'=='RET'
        ${selected_ald}  Select Random RET  ${ALD_R_RETs}
    ELSE
        ${selected_ald}  Select Random MHA  ${ALD_R_MHAs}
    END
    ${ALD_R_to_ALD_A}=  Mapping ALD_R To ALD_A
    ${ALD_A}=  Get From Dictionary  ${ALD_R_to_ALD_A}  ${selected_ald}
    ${ALD_A_id}=  Evaluate  re.search(r'ALD_A-(\\d+)','''${ALD_A}''').group(1)  re
    ${mha_parameters_a}=  admin.get managed objects  ALD_A
    ${mha_type}=    Create List
    FOR  ${mha}  IN  @{mha_parameters_a}
         IF  '${mha['distName']}'=='${ALD_A}'  Append To List   ${mha_type}    ${mha['parameters']['mhaType']}
    END
    IF  '${type}'=='MHA' and '${mha_type[0]}'!='IMF'
        ${item_id}  Select Random LNA
    ELSE
        ${item_id}  Set Variable  ${1}
    END
    ${ald_item}=  Set Variable If  '${type}'=='RET'  RETU-${item_id}  LNA-${item_id}
    Log  Randomly selected ${type}: ALD-${ALD_A_id}/${ald_item}  console=${true}
    Log  ------ Generating Additional Data ------  console=${True}
    ${antModel}=  Generate Random String  15  [LETTERS][NUMBERS][]~`!%^*()-=+\|;:',.<>/
    ${antSerial}=  Generate Random String  17  [LETTERS][NUMBERS][]~`!%^*()-=+\|;:',.<>/
    ${baseStationID}=  Generate Random String  32  [LETTERS][NUMBERS][]~`!%^*()-=+\|;:',.<>/
    ${installDate}=  Generate Random String  6  [LETTERS][NUMBERS][]~`!%^*()-=+\|;:',.<>/
    ${installerID}=  Generate Random String  5  [LETTERS][NUMBERS][]~`!%^*()-=+\|;:',.<>/
    ${sectorID}=  Generate Random String  32  [LETTERS][NUMBERS][]~`!%^*()-=+\|;:',.<>/
    ${additional_data}=  Create Dictionary
    ${RETs_ProductCode_list}  IF  '${type}'=='RET'  Mapping RET ALD_A To ProductCode
    ${Chosen_RET_ProductCode}  IF  '${type}'=='RET'  Get From Dictionary  ${RETs_ProductCode_list}  ${ALD_A}
    IF  '${type}'=='RET' and '${Chosen_RET_ProductCode}'!='RCU-003(IV)' or '${type}'=='MHA'  Set To Dictionary  ${additional_data}  antModel
    ...  ${antModel}
    Set To Dictionary  ${additional_data}  antSerial  ${antSerial}  baseStationID  ${baseStationID}
    Set To Dictionary  ${additional_data}  installDate  ${installDate}  installerID  ${installerID}  sectorID  ${sectorID}
    ${delta_id}=  Set Variable  delta_for_${type}
    admin.create delta  ${delta_id}
    ${ALD_DN}=  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ALD-${ALD_A_id}/${ald_item}
    FOR  ${key}  IN  @{additional_data.keys()}
        Log  -------------------- ${key} : ${additional_data["${key}"]}  console=${True}
        admin.append parameter update to delta  ${ALD_DN}  ${key}  ${additional_data["${key}"]}  ${delta_id}
    END
    admin.get delta  ${delta_id}
    ${json_path}=  Set Variable  ${RESULTS}/delta_add_data_${type}.json
    admin.save delta  ${json_path}  ${delta_id}
    admin.perform delta recommissioning  ${json_path}  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Log  Reset counter after applying delta: ${post_action_reset_number}  console=${True}
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    IF  ${counter_diff}!=${0}  Fail  msg=Detected unexpected BTS reset
    Set Test Variable  &{additional_data}
    ${full_dn}=  Set Variable  ${ALD_A}/${ald_item}
    RETURN  ${selected_ald}  ${ald_item}

Compare Additional Data
    [Arguments]  ${type}  ${ALD_R_dn}  ${ald_item}
    ${item}  ${id}=  Split String From Right  ${ald_item}  separator=-  max_split=1
    ${ALD_R_to_ALD_A}=  Mapping ALD_R To ALD_A
    ${ALD_A_dn}=  Get From Dictionary  ${ALD_R_to_ALD_A}  ${ALD_R_dn}
    Log  ------ Comparing ${type} Additional Data from runtime and SCF ------  console=${True}
    ${ald_a}=  admin.get managed objects  ${item}_A
    ${ald_r}=  admin.get managed objects  ${item}_R
    ${ALD_R_params}=  Create List
    FOR  ${ald}  IN  @{ald_r}
        IF  '${ald['distName']}'=='${ALD_R_dn}/${item}_R-${id}'  Append To List  ${ALD_R_params}  ${ald['parameters']['antModel']}
        IF  '${ald['distName']}'=='${ALD_R_dn}/${item}_R-${id}'  Append To List  ${ALD_R_params}  ${ald['parameters']['antSerial']}
        IF  '${ald['distName']}'=='${ALD_R_dn}/${item}_R-${id}'  Append To List  ${ALD_R_params}  ${ald['parameters']['baseStationID']}
        IF  '${ald['distName']}'=='${ALD_R_dn}/${item}_R-${id}'  Append To List  ${ALD_R_params}  ${ald['parameters']['installDate']}
        IF  '${ald['distName']}'=='${ALD_R_dn}/${item}_R-${id}'  Append To List  ${ALD_R_params}  ${ald['parameters']['installerID']}
        IF  '${ald['distName']}'=='${ALD_R_dn}/${item}_R-${id}'  Append To List  ${ALD_R_params}  ${ald['parameters']['sectorID']}
    END
    ${ALD_A_params}=  Create List
    FOR  ${ald}  IN  @{ald_a}
        IF  '${ald['distName']}'=='${ALD_A_dn}/${item}_A-${id}'  Append To List  ${ALD_A_params}  ${ald['parameters']['antModel']}
        IF  '${ald['distName']}'=='${ALD_A_dn}/${item}_A-${id}'  Append To List  ${ALD_A_params}  ${ald['parameters']['antSerial']}
        IF  '${ald['distName']}'=='${ALD_A_dn}/${item}_A-${id}'  Append To List  ${ALD_A_params}  ${ald['parameters']['baseStationID']}
        IF  '${ald['distName']}'=='${ALD_A_dn}/${item}_A-${id}'  Append To List  ${ALD_A_params}  ${ald['parameters']['installDate']}
        IF  '${ald['distName']}'=='${ALD_A_dn}/${item}_A-${id}'  Append To List  ${ALD_A_params}  ${ald['parameters']['installerID']}
        IF  '${ald['distName']}'=='${ALD_A_dn}/${item}_A-${id}'  Append To List  ${ALD_A_params}  ${ald['parameters']['sectorID']}
    END
    Lists Should Be Equal  ${ALD_R_params}  ${ALD_A_params}

ALD.03_ALD_Additional_data_for_ALDs.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
