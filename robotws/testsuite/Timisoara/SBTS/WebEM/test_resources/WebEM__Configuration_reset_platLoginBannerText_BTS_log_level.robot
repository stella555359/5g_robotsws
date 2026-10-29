*** Settings ***
Documentation
    ...  This test case is created to perform configuration reset.
    ...  Open Configuration -> Configuration Reset menu.
    ...  Select checkboxes available.
    ...  Execute configuration reset.
    ...  The test will sleep for 300s, time for all HW to appear.
    ...  All SMODs, BBMODs and RMODs available on BTS are check to be Online and Enabled.
    ...  Initial SCF will be upload.
    ...  Check all cells to be Online.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1200s  # Time for SBTS to recovery.
${BTS_RESCUE_CONSOLE_TIMEOUT}  500s  # Timeout for BTS Rescue Console to appear!
${RECOVERY_MODULE_TIMEOUT}  600s  # Timeout for modules to be enabled after decommissioning!
${RESTORE_TIMEOUT}  900s  # Time for SBTS to reach onAir state after scf recommissioning.
${CONFIG_RESET_OPTION}  6  # Number of configuration reset option from BTS Rescue Console


*** Keywords ***
TC__WebEM__Configuration_reset_platLoginBannerText_BTS_log_level
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25110
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 05.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25110 - Initial TAT creation
    ...  - 25.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25781 - Close BTS Start-up View only if it's needed
    ...  - 23.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26925 - Fix configuration reset method
    ...  - 01.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27026 - Restore defaults button was changed

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Check BTS Log Level Before Configuration Reset
    Step2: Change PlatLoginBannerText Parameter
    Step3: Perform Configuration Reset
    Step4: Check PlatLoginBannerText Parameter After Configuration Reset
    Step5: Check BTS Log Level After Configuration Reset
    Step6: Perform BTS Recommissioning And Verify Cells To Be OnAir


Step1: Check BTS Log Level Before Configuration Reset
    Log  \nStep1: Check BTS Log Level before configuration reset  console=true
    Check GET_RAD_PARAMS_IND Events
    Check If BTS Log Level Is Read Successfully From BTS
    Change Flags In Swconfig File
    Wait Until Keyword Succeeds  120  5
    ...  Go To Site View
    Reset SBTS From Admin
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells


Step2: Change PlatLoginBannerText Parameter
    Log  Step2: Change platLoginBannerText parameter  console=true
    ${status}  Run Keyword And Return Status
    ...  Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...  parameter=platLoginBannerText
    ...  value=test
    ...  operation=update
    ...  skip_parameter_relation_errors=true
    ...  timeout=600
    Run Keyword If  ${status}
    ...  Log  platLoginBannerText parameter value is changed![OK]  console=true
    ...  ELSE
    ...  Fail  platLoginBannerText parameter value is not change![NOK]


Step3: Perform Configuration Reset
    Log  Step3: Perform configuration reset  console=true
    Performing Configuration Reset And Verify SBTS To Be Not Commissioned  ${BTS_RESCUE_CONSOLE_TIMEOUT}  ${CONFIG_RESET_OPTION}
    Log  Checking modules after Configuration Reset  console=true
    Sleep  300s  Time for all modules to be visible!
    Wait Until Keyword Succeeds  120  5
    ...  Go To Site View
    Check SMODs To Be Online And Enabled  ${RECOVERY_MODULE_TIMEOUT}
    Check BBMODs To Be Online And Enabled  ${RECOVERY_MODULE_TIMEOUT}
    Check RMODs To Be Online And Enabled  ${RECOVERY_MODULE_TIMEOUT}


Step4: Check PlatLoginBannerText Parameter After Configuration Reset
    Log  Step4: Check platLoginBannerText parameter after configuration reset  console=true
    Log  Trying to connect on VM via SSH!  console=true
    ssh.Connect To  ${PC_IP1}  ute  ute  alias=vm
    ${default_plat_banner_text}  Catenate  SEPARATOR=  \r\nYou are about to access a private system. This system is for t
    ...  he use\r\nof authorized users only. All connections are logged to the extent and\r\nby means acceptable by t
    ...  he local legislation. Any unauthorized access\r\nor access attempts may be punished to the fullest extent po
    ...  ssible\r\nunder the applicable local legislation.\r\n
    ${login_output}  ssh.Execute  sshpass -p ${SMOD1}[PASSWORD] ssh 192.168.255.129 -l ${SMOD1}[USERNAME] & sleep 5 ; exit  connection=vm
    ...  timeout=30s
    Should Contain  ${login_output}  ${default_plat_banner_text}
    ssh.Disconnect  connection=vm


Step5: Check BTS Log Level After Configuration Reset
    Log  Step5: Check BTS Log Level after configuration reset  console=true
    Open BTS Log Level
    Run Keyword If  '${ENB_BRANCH}' < 'SBTS24R2'
    ...  Wait Until Element Is Visible  //*[contains(text(),'BTS is not in required state (Configured, Integrated, On Air, Test Dedicated)')]  300
    ...  ELSE
    ...  Wait Until Element Is Visible  //*[contains(text(),'BTS is not in the required state (Configured, Integrated, On Air, Test Dedicated)')]
    ...  300


Step6: Perform BTS Recommissioning And Verify Cells To Be OnAir
    Log  Step6: Perform BTS Recommissioning and verify cells to be onAir  console=true
    coam.Perform Commissioning  scf_file=${COMMISSIONING_PATH}  bts_id=${BTS_ID}  skip_parameter_relation_errors=${TRUE}
    Close Startup View If Visible
    ${status}  Run Keyword And Return Status
    ...  Check If Bts Is Disconnected
    Run Keyword If  ${status}
    ...  Connect BTS
    Log  TC is waiting for SBTS to reach onAir state...  console=true
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10
    ...  Admin Check All Required State
    Check If BTS Log Level Is Read Successfully From BTS
    Restore Defaults
    Wait Until Keyword Succeeds  120  5
    ...  Go To Site View


Check GET_RAD_PARAMS_IND Events
    Log  Check GET_RAD_PARAMS_IND events in infomodel.  console=true
    Setup Infomodel  address=192.168.255.129  port=443  timeout=90  admin_api_log_dir=${BTS_FILES}/  alias=get_log_level
    Connect Infomodel  timeout=90  alias=get_log_level
    Open BTS Log Level
    Wait Until Element Is Visible  locator=//span[contains(text(),'Reading log data level completed')]  timeout=60
    Save Infomodel Log  filename=${BTS_FILES}/IM/get_log_level_ims.ims2  timeout=300  alias=get_log_level
    Sleep  60s
    Initialize Ims2 Validator  filename=${BTS_FILES}/IM/get_log_level_ims.ims2  alias=get_log_level
    Add Expected Ims2 Event  event=create /MRBTS-1/RAT-1/URI-*/SESSION-*/GET_RAD_PARAMS_IND-*/GET_RAD_PARAMS_RESULT-* [result=Succeeded]
    ...  alias=get_log_level
    Add Expected Ims2 Event  event=create /MRBTS-1/RAT-1/URI-*/SESSION-*/GET_RAD_PARAMS_IND-*/ACK-*  alias=get_log_level
    Validate Ims2  alias=get_log_level

    [Teardown]  Teardown Infomodel  alias=get_log_level


Check If BTS Log Level Is Read Successfully From BTS
    Select Log Level  log_level=Full
    ${status}  Run Keyword And Return Status
    ...  Check If BTS Log Level Is Selected
    Run Keyword If  ${status}
    ...  Send Log Data Level
    Setup Infomodel  address=192.168.255.129  port=443  timeout=90  admin_api_log_dir=${BTS_FILES}/  alias=set_log_level
    Connect Infomodel  timeout=90  alias=set_log_level
    Select Log Level  log_level=Full
    Check If BTS Log Level Is Selected  is_selected=yes
    Select Log Level  log_level=Minimum
    Check If BTS Log Level Is Selected  is_selected=no
    Send Log Data Level
    Check If BTS Log Level Is Selected  is_selected=yes
    Select Log Level  log_level=Normal
    Check If BTS Log Level Is Selected  is_selected=no
    Send Log Data Level
    Check If BTS Log Level Is Selected  is_selected=yes
    Select Log Level  log_level=Full
    Check If BTS Log Level Is Selected  is_selected=no
    Send Log Data Level
    Check If BTS Log Level Is Selected  is_selected=yes
    Check BTS Log Level Changes In Ims
    [Teardown]  Teardown Infomodel  alias=set_log_level


Check If BTS Log Level Is Selected
    [Arguments]  ${is_selected}=no

    Run Keyword If  "${is_selected}"=="yes"
    ...  Element Should Be Visible  locator=//button[@disabled="disabled" and contains(text(),'Send')]
    ...  ELSE
    ...  Element Should Not Be Visible  locator=//button[@disabled="disabled" and contains(text(),'Send')]


Select Log Level
    [Arguments]  ${log_level}

    Click Element  locator=//label[contains(text(),'${log_level}')]


Send Log Data Level
    Click Element  locator=//button[contains(text(),'Send')]
    Wait Until Element Is Visible  locator=//span[contains(text(),'Sending log data level completed')]  timeout=60


Check BTS Log Level Changes In Ims
    Log  Check SET_RAD_PARAMS_IND events in infomodel.  console=true
    Save Infomodel Log  filename=${BTS_FILES}/IM/set_log_level_ims.ims2  timeout=300  alias=set_log_level
    Initialize Ims2 Validator  filename=${BTS_FILES}/IM/set_log_level_ims.ims2  alias=set_log_level
    Add Expected Ims2 Event Sequence  event1=update /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/ACK-*
    ...  event2=remove /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/ACK-*
    ...  event3=update /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/ACK-*
    ...  event4=remove /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/ACK-*
    ...  event5=update /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/ACK-*  alias=set_log_level
    Add Expected Ims2 Event Sequence  event1=update /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/SET_RAD_PARAMS_RESULT-*
    ...  event2=remove /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/SET_RAD_PARAMS_RESULT-*
    ...  event3=update /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/SET_RAD_PARAMS_RESULT-*
    ...  event4=remove /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/SET_RAD_PARAMS_RESULT-*
    ...  event5=update /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/SET_RAD_PARAMS_RESULT-*  alias=set_log_level
    Validate Ims2  alias=set_log_level


Change Flags In Swconfig File
    Open Alias Ssh_enb Connection To SBTS
    Set Flag In Swconfig File  flag=0x480008  value=1
    Set Flag In Swconfig File  flag=0x1A0020  value=1
    Set Flag In Swconfig File  flag=0x19000A  value=1
    Set Flag In Swconfig File  flag=0x4F0031  value=0
    Set Flag In Swconfig File  flag=0x30000F  value=1
    Close Alias Ssh_enb Connection To SBTS


Open Alias Ssh_enb Connection To SBTS
    SSHLibrary.Open Connection  host=${SMOD1["IP"]}  port=22  timeout=60  alias=ssh_enb
    SSHLibrary.Login  username=${SMOD1["USERNAME"]}  password=${SMOD1["PASSWORD"]}  delay=1s
    SSHLibrary.Switch Connection  index_or_alias=ssh_enb
    SSHLibrary.Write  echo "connection established"


Set Flag In Swconfig File
    [Arguments]  ${flag}  ${value}

    SSHLibrary.Switch Connection  index_or_alias=ssh_enb
    SSHLibrary.Execute Command  echo -e "\n${flag}=${value}\n" >> /ffs/run/swconfig.txt


Close Alias Ssh_enb Connection To SBTS
    SSHLibrary.Switch Connection  index_or_alias=ssh_enb
    SSHLibrary.Close Connection


Restore Defaults
    Select Log Level  log_level=Normal (default)
    Send Log Data Level
    Check If BTS Log Level Is Selected  is_selected=yes


Perform Recommissioning And Wait For All Cells To Be OnAir
    coam.Perform Commissioning  scf_file=${COMMISSIONING_PATH}  bts_id=${BTS_ID}  skip_parameter_relation_errors=${TRUE}
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10
    ...  Admin Check All Required State


TC Setup
    Common Test Setup  tc_name=WebEM__Configuration_reset_platLoginBannerText
    WebEM Setup


TC Teardown
    Run Keyword If Test Failed
    ...  Perform Recommissioning And Wait For All Cells To Be OnAir
    WebEM Teardown
    Common Test Teardown
