*** Settings ***
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/common.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/alarms.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/ald.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.16_ALD_Software_upgrade_for_ALDs
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check if ALD Software Update procedure works correctly according to operator request.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  20.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21616 - migration from ute_admin to taf.sbts.oam.coam.admin
...  22.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-20 - Adaptation to CNI-61110
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  19.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-149 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${ALD_SW_PATH}  /media/IAV_WCDMA/09_Users/tmar/~RET/ALD_SW

*** Keywords ***
ALD.16_ALD_Software_upgrade_for_ALDs

	ALD.16_ALD_Software_upgrade_for_ALDs.Test_Step.0 Check If ALDs Are In Configuration
    ALD.16_ALD_Software_upgrade_for_ALDs.Test_Step.1 ALD Software update
    ALD.16_ALD_Software_upgrade_for_ALDs.Test_Step.2 Checking ALD State

ALD.16_ALD_Software_upgrade_for_ALDs.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    ${RET_vendor}  ${RET_SW}=  Mapping RET To Vendor And RET To SW Version  ${ALD_R_RETs}
    Count Expected RETs In Configuration  ${RET_vendor}
    Run Keyword If  ${num_of_86010148}==${0} and ${num_of_ATM3}==${0} and ${num_of_CB_RCU003}==${0}
    ...  Fail  At least one RET: Kathrein 86010148 or Andrew ATM3 or Comba RCU-003(IV) is needed
    Log  Detected RET(s): \n
    Log  ${num_of_86010148}x Kathrein with product code: 86010148, \n  console=${True}
    Log  ${num_of_ATM3}x Andrew with product code: ATM3, \n  console=${True}
    Log  ${num_of_CB_RCU003}x Comba with product code: RCU-003(IV)   console=${True}
    Get Current RET SW Version
    Set Feature On Expected Value  parameter=actAldSwUpdate  value=true
    Sleep  10s

ALD.16_ALD_Software_upgrade_for_ALDs.Test_Step.1 ALD Software update
    [Documentation]  This keyword triggers ALD software update using file with software dedicated to RET.
    Log to console    \n========================================
    Log  Step: 1 ALD Software update  console=${True}
    Log to console    ========================================
    #Kathrein
    Run Keyword If  ${num_of_86010148}!=0 and '${KA_swVersion}'=='FW_V02.03.01'  Run Keywords
    ...  Log    ALD software update path on Kathrein: ${KA_swVersion} -> FW_V02.03.02   console=${True}
    ...  AND    SW Update KA 02.03.02
    ...  ELSE IF  ${num_of_86010148}!=0 and '${KA_swVersion}'=='FW_V02.03.02'  Run Keywords
    ...  Log    ALD software update path on Kathrein: ${KA_swVersion} -> FW_V02.03.01   console=${True}
    ...  AND    SW Update KA 02.03.01
    ...  ELSE   Log   There is no expected Kathrein RET on testline   console=${True}
    #Andrew
    Run Keyword If  ${num_of_ATM3}!=0 and '${AN_swVersion}'=='2.0.20'  Run Keywords
    ...  Log    ALD software update path on Andrew: ${AN_swVersion} -> 2.0.22   console=${True}
    ...  AND    SW Update AN 2.0.22
    ...  ELSE IF  ${num_of_ATM3}!=0 and '${AN_swVersion}'=='2.0.22'  Run Keywords
    ...  Log    ALD software update path on Andrew: ${AN_swVersion} -> 2.0.20   console=${True}
    ...  AND    SW Update AN 2.0.20
    ...  ELSE   Log  There is no expected Andrew RET on testline   console=${True}
    #Comba
    Run Keyword If  ${num_of_CB_RCU003}!=0 and '${CB_swVersion}'=='V5.3'  Run Keywords
    ...  Log    ALD software update path on Comba: ${CB_swVersion} -> V5.3T   console=${True}
    ...  AND    SW Update CB V5.3T
    ...  ELSE IF  ${num_of_CB_RCU003}!=0 and '${CB_swVersion}'=='V5.3T'  Run Keywords
    ...  Log    ALD software update path on Comba: ${CB_swVersion} -> V5.3   console=${True}
    ...  AND    SW Update CB V5.3
    ...  ELSE   Log  There is no expected Comba RET on testline   console=${True}

SW Update KA 02.03.01
    ${status}  admin.update software  ${ALD_SW_PATH}/mixed/KA_86010148_02.03.01_forced.zip  ${SHOULD_ACTIVATE}  timeout=700
    Run Keyword If  '${status}'=='Software update has been completed'
    ...  Log  ${status}  console=${True}
    ...  ELSE  Fail  Ald software update has been failed

SW Update KA 02.03.02
    ${status}  admin.update software  ${ALD_SW_PATH}/mixed/KA_86010148_02.03.02_forced.zip  ${SHOULD_ACTIVATE}  timeout=700
    Run Keyword If  '${status}'=='Software update has been completed'
    ...  Log  ${status}  console=${True}
    ...  ELSE  Fail  Ald software update has been failed

SW Update AN 2.0.20
    ${status}  admin.update software  ${ALD_SW_PATH}/mixed/AN_ATM3_2.0.20_forced.zip  ${SHOULD_ACTIVATE}  timeout=700
    Run Keyword If  '${status}'=='Software update has been completed'
    ...  Log  ${status}  console=${True}
    ...  ELSE  Fail  Ald software update has been failed

SW Update AN 2.0.22
    ${status}  admin.update software  ${ALD_SW_PATH}/mixed/AN_ATM3_2.0.22_forced.zip  ${SHOULD_ACTIVATE}  timeout=700
    Run Keyword If  '${status}'=='Software update has been completed'
    ...  Log  ${status}  console=${True}
    ...  ELSE  Fail  Ald software update has been failed

SW Update CB V5.3T
    ${status}  admin.update software  ${ALD_SW_PATH}/mixed/CB_RCU-003_5.3T_forced.zip  ${SHOULD_ACTIVATE}  timeout=700
    Run Keyword If  '${status}'=='Software update has been completed'
    ...  Log  ${status}  console=${True}
    ...  ELSE  Fail  Ald software update has been failed

SW Update CB V5.3
    ${status}  admin.update software  ${ALD_SW_PATH}/mixed/CB_RCU-003_5.3_forced.zip  ${SHOULD_ACTIVATE}  timeout=700
    Run Keyword If  '${status}'=='Software update has been completed'
    ...  Log  ${status}  console=${True}
    ...  ELSE  Fail  Ald software update has been failed

ALD.16_ALD_Software_upgrade_for_ALDs.Test_Step.2 Checking ALD State
    [Documentation]  Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    Log to console    \n========================================
    Log  Step: 2 Checking ALD State  console=${True}
    Log to console    ========================================
	Check ALDs State  ${ALD_expected_states}
    Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.16_ALD_Software_upgrade_for_ALDs.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
