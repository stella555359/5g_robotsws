*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/power_saving.robot


Documentation

    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 10.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28173 - Initial creation


*** Variables ***
${RESTORE_TIMEOUT}  10        # Time need to restor BTS after reset, default value 10 min
${ALD_EXPECTED_STATES}  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"

*** Keywords ***
ALD.36_ALD_Site_Reset

    Step 1: SBTS Site Reset
    Step 2: SBTS Is Restored


Step 1: SBTS Site Reset
    Log  \nStep 1: SBTS Site reset  console=true
    Log  BTS is reset now.  console=true
    admin.Reset Site  600


Step 2: SBTS Is Restored
    Log  Step 2: SBTS is restored\nCheck BTS and Cells states after reset\nWait ${RESTORE_TIMEOUT} mins for the states to be as expected  console=true
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT} min  15 s
    ...  Check ALDs State  ${ALD_EXPECTED_STATES}


ALD.36_ALD_Site_Reset.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
