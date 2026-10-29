*** Settings ***
Documentation
    ...  Step 1. Checking Logs in pano.log file for latest PM
    ...  Step 2. Checking files in pano/pm directory for latest PM
    ...  Step 3. Checking validation for files in pano/pm directory for latest PM

Resource  ../../common_resources/ca_PM_general.robot
Resource  ../../common_resources/ca_ONAP_general.robot


*** Keywords ***
TC__PANO__CB007010_G_Check_PM_files
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroclaw

    Set Tags  CA-ONAP  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-marcin.berkowski@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-CB007010

    Step 1. Checking Logs in pano.Log File For Latest PM
    Step 2. Checking Files In Pano/pm Directory For Latest PM
    Step 3. Checking Validation For Files In Pano/pm Directory For Latest PM


Step 1. Checking Logs In Pano.Log File For Latest PM
    Log  \nStep 1. Checking Logs in pano.log file for latest PM  console=true
    Wait Until Keyword Succeeds  6min  1min
    ...  Check pano.Log For Latest PM


Step 2. Checking Files In Pano/pm Directory For Latest PM
    Log  \nStep 2. Checking files in pano/pm directory for latest PM  console=true
    Wait Until Keyword Succeeds  3min  15sec
    ...  Check Files In Pano/pm Directory


Check Files In Pano/pm Directory
    [Documentation]
    ...  Succeeds if the newest PM file (from step 1) from BTS is visible in the pano/pm directory

    SSHLibrary.Open Connection  ${VM_WITH_PANO_IP}
    SSHLibrary.Login  ${VM_WITH_PANO_USR}  ${VM_WITH_PANO_PASSWD}
    Sleep  2s
    ${pano_pm_dir}  SSHLibrary.Execute Command  cd /home/ute/pano/pm; ls -1 /home/ute/pano/pm | grep MRBTS-${BTS_ID}
    SSHLibrary.Close Connection

    Should Contain  ${pano_pm_dir}  ${LATEST_PM_ON_BTS}


Step 3. Checking Validation For Files In Pano/pm Directory For Latest PM
    Log  \nStep 3. Checking validation for files in pano/pm directory for latest PM  console=true
    Wait Until Keyword Succeeds  3min  15sec
    ...  Check Validation For Files In Pano/pm Directory


Check Validation For Files In Pano/pm Directory
    [Documentation]
    ...  Succeeds if the newest PM file (from step 1) is validated

    SSHLibrary.Open Connection  ${VM_WITH_PANO_IP}
    SSHLibrary.Login  ${VM_WITH_PANO_USR}  ${VM_WITH_PANO_PASSWD}
    Sleep  2s
    ${pano_pm_dir}  SSHLibrary.Execute Command  cd /home/ute/pano/pm; ls -1 /home/ute/pano/pm | grep MRBTS-${BTS_ID}
    SSHLibrary.Close Connection

    Should Contain  ${pano_pm_dir}  validate.ok
    Should Not Contain  ${pano_pm_dir}  validate.failed


TC Setup
    Common Test Setup  tc_name=PANO__G_Check_PM_files
    ONAP CB007010 Test Setup


TC Teardown
    ONAP CB007010 Test Teardown
    Common Test Teardown
