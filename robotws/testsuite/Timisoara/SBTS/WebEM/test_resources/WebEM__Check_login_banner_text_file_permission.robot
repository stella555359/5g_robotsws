*** Settings ***
Documentation
    ...  This test case is created to perform changes on banner file permission.
    ...  Connecting to SBTS via SSH.
    ...  Verify if banner file permission is -rw-r--r--.
    ...  Change banner file permission in -rwxrwxrwx.
    ...  Disconnecting from SBTS via SSH.
    ...  Reboot SBTS.
    ...  Connecting to SBTS via SSH.
    ...  Check if file permission is set to non-executable.
    ...  Disconnecting from SBTS via SSH.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1200  # Timeout for SBTS to recover


*** Keywords ***
TC__WebEM__Check_login_banner_text_file_permission
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22350
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  - 16.12.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22350 - Initial TAT creation
    ...  - 11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24106 - Adding global variable and specific library to KWs
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags  CA-WebEM  OWNER-george.gheban@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS21

    Step1: Change The Banner File Permission As Executable
    Step2: Change The Banner File Permission As Non-executable


Step1: Change The Banner File Permission As Executable
    Log  Step1: Change the banner file permission as executable  console=true
    Log  Connecting on SBTS via SSH will be performed!  console=true
    ${connection}  Run Keyword And Return Status
    ...  ssh.Connect To  192.168.255.129  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]  alias=sbts
    Run Keyword If  ${connection}
    ...  Log  Connection to SBTS via SSH was successfully performed!  console=true
    ${banner_permission_output}  ssh.Execute  ls -la /etc/ssh/ | grep banner  connection=sbts
    ${status}  Run Keyword And Return Status
    ...  Should Contain  ${banner_permission_output}  -rw-r--r--
    Run Keyword If  ${status}
    ...  Log  Banner file permission is: -rw-r--r-- [OK]  console=true
    ...  ELSE
    ...  Fail  Banner file permission is not -rw-r--r--![NOK]
    ssh.Execute  chmod 777 /etc/ssh/banner  connection=sbts
    ${banner_permission_output}  ssh.Execute  ls -la /etc/ssh/ | grep banner  connection=sbts
    ${status}  Run Keyword And Return Status
    ...  Should Contain  ${banner_permission_output}  -rwxrwxrwx
    Run Keyword If  ${status}
    ...  Log  Banner file permission is changed in: -rwxrwxrwx![OK]  console=true
    ...  ELSE
    ...  Fail  Banner file permission is not changed in -rwxrwxrwx![NOK]
    Log  Disconnecting from SBTS via SSH will be performed!  console=true
    ssh.Disconnect  connection=sbts


Step2: Change The Banner File Permission As Non-executable
    Log  Step2: Change the banner file permission as non-executable  console=true
    Log  Site reset will be performed!  console=true
    coam.Reset_site
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  5
    ...  coam.Connect_to  bts_host=192.168.255.129  bts_port=443  username=Nemuadmin  password=nemuuser
    ${connection}  Run Keyword And Return Status
    ...  ssh.Connect To  192.168.255.129  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]  alias=sbts
    Run Keyword If  ${connection}
    ...  Log  Connection to SBTS via SSH was successfully performed!  console=true
    ${banner_permission_output}  ssh.Execute  ls -la /etc/ssh/ | grep banner  connection=sbts
    ${status}  Run Keyword And Return Status
    ...  Should Contain  ${banner_permission_output}  -rw-r--r--
    Run Keyword If  ${status}
    ...  Log  Banner file permission is changed in: -rw-r--r-- [OK]  console=true
    ...  ELSE
    ...  Fail  Banner file permission is not changed in -rw-r--r--![NOK]
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Log  All cells are Enabled!  console=true
    ssh.Execute  chmod 622 /etc/ssh/banner  connection=sbts
    Log  Disconnecting from SBTS via SSH will be performed!  console=true
    ssh.Disconnect  connection=sbts


TC Setup
    Common Test Setup  tc_name=WebEM__Check_login_banner_text_file_permission
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
