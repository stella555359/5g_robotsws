*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot

*** Variables ***
${RESTORE_TIMEOUT}    900    #Time for SBTS to reach onAir state after scf recommissioning.

*** Keywords ***
TC__WebEM__BTS_log_level
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24463
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is transferred from BOAM_ET to ST_OAM_WebEM.
    ...  This test case checks BTS Log Level before and after performing Configuration reset operation.
    ...  Step1:
    ...    - open BTS Log Level page
    ...    - check GET_RAD_PARAMS_IND in infomodel
    ...      (must be 2 events when the BTS Log Level page is accessed and 'Reading log data level completed' text appears)
    ...    - check SET_RAD_PARAMS_IND events in infomodel
    ...      (must be 5 events: 3 updates and 2 removes because BTS log level is changed for 3 times)
    ...  Step2:
    ...    - set default values for flags in swconfig file
    ...    - perform configuration reset
    ...  Step3:
    ...    - open BTS Log Level page after SBTS is pingable
    ...    - check SET_RAD_PARAMS_IND events in infomodel
    ...      (must be 5 events as in step1)
    ...    - wait until SBTS is reaching onAir state.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 11.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24463 - Initial TAT creation

    Set Tags    CA-WebEM    OWNER-cristina.antoci@nokia.com    AUTHOR-andrada-lavinia.baleti@nokia.com
    ...    MAINTAINER-andrada-lavinia.baleti@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS23
    ...    FEATURE-LTE5113

    Step1: Check BTS Log Level Before BTS Reset Configuration
    Step2: Perform BTS Reset Configuration
    Step3: Check BTS Log Level After Reset Configuration


Step1: Check BTS Log Level Before BTS Reset Configuration
    Log  \nStep1: Check BTS Log Level Before BTS Reset Configuration  console=true
    Check GET_RAD_PARAMS_IND Events
    Check If BTS Log Level Is Read Successfully From BTS

Step2: Perform BTS Reset Configuration
    Log  \nStep2: Perform BTS Reset Configuration  console=true
    Change Flags In Swconfig File
    Open Simplified Site View
    Wait until keyword succeeds  300  10  Click Element  //button[@ui-tooltip="Reset Site"]
    Click Element  locator=//button[contains(text(),'Reset') and not(contains(text(),'Reset Site'))]
    Wait Until Element Is Visible    locator=//cells-status//div[contains(text(),'---')]
    ...                              timeout=300
    Wait Until Element Is Visible    locator=//button[contains(text(),'Close')]
    ...                              timeout=300
    Wait Until Element Is Visible    locator=//div[contains(text(),'Configured')]
    ...                              timeout=800
    Close Startup View If Visible
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  locator=//button[contains(text()," Confirm")]
    ...                                 timeout=50
    Run Keyword If  ${status}=='True'  Close Startup View If Visible
    Perform Reset Configuration

Step3: Check BTS Log Level After Reset Configuration
    Log  \nStep3: Check BTS Log Level After Reset Configuration  console=true
    Wait until keyword succeeds  500  10  Click Element  //button[contains(text()," Cancel")]
    Wait until keyword succeeds  30  5  Click Element  //span[@ui-tooltip='Procedures']
    Wait until keyword succeeds  30  5  Click Element  //span[contains(text(),'BTS Log Level')]
    Wait Until Element Is Visible  locator=//span[contains(text(),'BTS is not in required state (Configured, Integrated, On Air, Test Dedicated)')]
    ...                            timeout=1500
    Perform Scf Recommissioning And Wait Until SBTS Is Configured
    Check If BTS Log Level Is Read Successfully From BTS
    Restore Defaults
    Log  TC is waiting for SBTS to reach onAir state...  console=true
    Wait until keyword succeeds  ${RESTORE_TIMEOUT}  10  Admin Check All Required State

Check GET_RAD_PARAMS_IND Events
    Log  Check GET_RAD_PARAMS_IND events in infomodel.  console=true
    Setup Infomodel    address=192.168.255.129
    ...                port=443
    ...                timeout=90
    ...                admin_api_log_dir=${BTS Files}/
    ...                alias=get_log_level
    Connect Infomodel  timeout=90  alias=get_log_level

    Click Element  locator=//span[@ui-tooltip='Procedures']
    Click Element  locator=//span[contains(text(), 'BTS Log Level')]
    Log  The BTS log level page is accessed.  console=true
    Wait Until Element Is Visible    locator=//span[contains(text(),'Reading log data level completed')]
    ...                              timeout=60

    Save Infomodel Log  filename=${BTS Files}/IM/get_log_level_ims.ims2  timeout=300  alias=get_log_level
    Initialize Ims2 Validator  filename=${BTS Files}/IM/get_log_level_ims.ims2  alias=get_log_level
    Add Expected Ims2 Event    event=create /MRBTS-1/RAT-1/URI-*/SESSION-*/GET_RAD_PARAMS_IND-*/GET_RAD_PARAMS_RESULT-* [result=Succeeded]
    ...                        alias=get_log_level
    Add Expected Ims2 Event    event=create /MRBTS-1/RAT-1/URI-*/SESSION-*/GET_RAD_PARAMS_IND-*/ACK-*
    ...                        alias=get_log_level
    Validate Ims2  alias=get_log_level
    [Teardown]  Teardown Infomodel  alias=get_log_level

Check If BTS Log Level Is Read Successfully From BTS
    Select Log Level  log_level=Full
    ${status}  Run Keyword And Return Status  Check If BTS Log Level Is Selected
    Run Keyword If  ${status}==True  Send Log Data Level

    Setup Infomodel    address=192.168.255.129
    ...                port=443
    ...                timeout=90
    ...                admin_api_log_dir=${BTS Files}/
    ...                alias=set_log_level
    Connect Infomodel  timeout=90
    ...                alias=set_log_level

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
    Wait Until Element Is Visible    locator=//span[contains(text(),'Sending log data level completed')]
    ...                              timeout=60

Check BTS Log Level Changes In Ims
    Log  Check SET_RAD_PARAMS_IND events in infomodel.  console=true
    Save Infomodel Log  filename=${BTS Files}/IM/set_log_level_ims.ims2  timeout=300  alias=set_log_level
    Initialize Ims2 Validator  filename=${BTS Files}/IM/set_log_level_ims.ims2  alias=set_log_level
    Add Expected Ims2 Event Sequence    event1=update /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/ACK-*
    ...                                 event2=remove /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/ACK-*
    ...                                 event3=update /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/ACK-*
    ...                                 event4=remove /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/ACK-*
    ...                                 event5=update /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/ACK-*
    ...                                 alias=set_log_level
    Add Expected Ims2 Event Sequence    event1=update /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/SET_RAD_PARAMS_RESULT-*
    ...                                 event2=remove /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/SET_RAD_PARAMS_RESULT-*
    ...                                 event3=update /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/SET_RAD_PARAMS_RESULT-*
    ...                                 event4=remove /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/SET_RAD_PARAMS_RESULT-*
    ...                                 event5=update /MRBTS-1/RAT-1/URI-*/SESSION-*/SET_RAD_PARAMS_IND-*/SET_RAD_PARAMS_RESULT-*
    ...                                 alias=set_log_level
    Validate Ims2  alias=set_log_level

Perform Reset Configuration
    Click Element  locator=//*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[2]/div/nav-menu-link/span
    Click Element  locator=//*[contains(text(), 'Configuration Reset')]
    Click Element  locator=//button[contains(text(),'Execute Reset')]
    Click Element  locator=//button[contains(text(),'Execute') and not(contains(text(),'Execute Reset'))]
    Wait Until Element Is Visible  locator=//cells-status//div[contains(text(),'---')]
    ...                            timeout=300
    Wait Until Element Is Visible  locator=//cells-status//div[contains(text(),'Not commissioned')]
    ...                            timeout=800

Change Flags In Swconfig File
    Open Alias ssh_enb Connection To SBTS
    Set Flag In Swconfig File    flag=0x480008
    ...                          value=1
    Set Flag In Swconfig File    flag=0x1A0020
    ...                          value=1
    Set Flag In Swconfig File    flag=0x19000A
    ...                          value=1
    Set Flag In Swconfig File    flag=0x4F0031
    ...                          value=0
    Set Flag In Swconfig File    flag=0x30000F
    ...                          value=1
    Close Alias ssh_enb Connection To SBTS

Open Alias ssh_enb Connection To SBTS
    SSHLibrary.Open Connection    host=${SMOD1["IP"]}
    ...                           port=22
    ...                           timeout=60
    ...                           alias=ssh_enb
    SSHLibrary.Login    username=${SMOD1["USERNAME"]}
    ...                 password=${SMOD1["PASSWORD"]}
    ...                 delay=1s
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Write   echo "connection established"

Set Flag In Swconfig File
    [Arguments]    ${flag}    ${value}
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Execute Command    echo -e "\n${flag}=${value}\n" >> /ffs/run/swconfig.txt

Close Alias ssh_enb Connection To SBTS
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Close Connection

Open Simplified Site View
    Click Element  locator=//div[@aria-describedby="admin.navigationBar.btsStatus.TITLE"]
    Click Element  locator=//span[contains(text(),'Site Runtime View')]
    Click Element  locator=//li[@heading="Site View"]

Perform Scf Recommissioning And Wait Until SBTS Is Configured
    Log  Perform SCF recommissioning and wait until SBTS is configured.  console=true
    Perform scf commissioning
    Close Startup View If Visible
    ${status}  Run Keyword And Return Status  Check If Bts Is Disconnected
    Run Keyword If  ${status}==True
    ...  Click Connect button
    Wait Until Element Is Visible  locator=//cells-status//div[contains(text(),'Configured')]
    ...                            timeout=900

Perform scf commissioning
    ${bts_id}  ADMIN Get BTS ID
    coam.Perform Commissioning  scf_file=${COMMISSIONING_PATH}
    ...                         bts_id=${bts_id}
    ...                         skip_parameter_relation_errors=${True}

Check If Bts Is Disconnected
    Click Element  locator=//div[contains(@class, "status-bar-menu")]
    Element Should Be Visible  locator=//a[@aria-label="Connect Button" and contains(text(),"Connect")]

Click Connect button
    Click Element  locator=//i[@class="fa fa-ellipsis-v"]
    ${connect}  Run Keyword And Return Status  Element Should Be Visible  locator=//a[contains(text(),' Connect')]
    Run Keyword If  ${connect}==True
    ...  Click Element  locator=//a[contains(text(),' Connect')]

Restore Defaults
    Click Element  locator=//button[contains(text(),'Restore Defaults')]
    Select Log Level  log_level=Normal
    Check If BTS Log Level Is Selected  is_selected=yes


TC Setup
    Common test setup
    WebEM Setup

TC Teardown
    Run keyword if test failed  Run keywords
    ...  Perform scf commissioning
    ...  AND  Wait until keyword succeeds  ${RESTORE_TIMEOUT}  10  Admin Check All Required State
    WebEM Teardown
    Common test teardown
