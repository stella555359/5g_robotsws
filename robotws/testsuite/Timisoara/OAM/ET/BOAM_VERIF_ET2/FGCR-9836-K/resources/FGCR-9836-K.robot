*** Settings ***
Documentation
...    Author: Zaharia Andreea (andreea-oana.zaharia@nokia.com)
...    Maintainer: Zaharia Andreea (andreea-oana.zaharia@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: FGCR-9836
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/FGCR-9836/FGCR-9836.robot

Library        String
Library        OperatingSystem
Library        Process
Library        taf.transport.ssh   WITH NAME    taf_ssh
Library        taf.sbts.oam.coam.admin.interface.admin   WITH NAME   taf_admin
Library        taf.selenium.gnb.oam.coam.classical      WITH NAME   taf_selenium
#Library        taf.sw.ping      WITH NAME   taf_ping

Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/fault_trigger.robot
Resource    ../../resources/admin_infomodel.robot
Resource    ../../resources/faults.robot
Resource    ../../resources/selenium.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${DOWNLOAD_HOST}      https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
#${BRANCH}               800
${SW_DESTINATION}     /home/ute/
${jenkins_url}        http://files.ute.nsn-rdnet.net/builds/enb/base/
#${TRUNK_VERSION}      SBTS21B

${WEBEM_IP}=          https://192.168.255.129
${SC_VM_IP}=          10.5.25.140

#Andreea
${soft_activation}      /MRBTS-1/RAT-1/SWM-1/SW_ACTIVATE_REQ-1
${scf_path}             /tmp/
${scf_name}             scf_file.xml
${scf_single_core_location}         /home/ute/Documents/nu_sterge
#Alin
${delta_activate_users_activation}=         ${CURDIR}/Delta_Activate_Users_Accounts.json
${certificate_file}=                        /home/ute/bts-83_cert.p12
${scf_leftside_single_core}=                ${CURDIR}/SCF_LeftSide_Single_Core.xml
${scf_leftside_dual_core}=                  ${CURDIR}/SCF_LeftSide_Dual_Core.xml

&{FAULT_4681}    fault_id=4681
...              alarm_id=7115
...              alarm_severity=Major
...              alarm_description="Sanity Check Error"
...              alarm_resource=MRBTS-10008

@{ALLOWED_ALARMS}    &{FAULT_4681}   @{FAULT_ALLOWED_LIST_COR}

*** Keywords ***
ROBUSTNESS_Rollback_Migration_from_dual-core_to_single-core
    Log to Console  START Test Case 1: ROBUSTNESS Rollback Migration from Dual-core to Single-core
    ADMIN Collect Scf    local_dir_path=${scf_path}    file_name=${scf_name}
    ${commission_file}    set variable    ${scf_path}${scf_name}
    log to console  perform commissioning  on BTS
    FOR    ${0}    IN RANGE    ${5}
       run keyword and expect error
       ...     *Commissioning to Single Core is not allowed. BTS is working in Dual Core mode.*
       ...     ADMIN Perform Commissioning
       ...     scf_file=${scf_leftside_single_core}
       ...     skip_parameter_relation_errors=True
       Sleep  10
       SC Response to Ping as Dual Core
    END

Configuration_Reset_rejected_on_DualCore_SW_or_Plan_Activation
    Log to Console
    ...  START Test Case 2: SW Update in Dual-core mode Configuration Reset rejected on Dual-core SW or Plan Activation
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    should contain  ${output}  	TargetBD_${OUT_PASSIVE_SW}.xml
    ADMIN Update Software Without Activation
    ...    sw_package=${SW_DESTINATION}${T1_package}
    ...    timeout=4000
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    should not contain  ${output}  	TargetBD_${OUT_PASSIVE_SW}.xml
    Should Be Equal As Strings  ${output}  planned\r\n
    Sleep  30
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/planned/
    should contain  ${output}  	TargetBD_${out_active_sw}T1.xml

    ${CLI_INTERFACE}                               Get Library Instance    taf.sbts.oam.coam.admin
    ADMIN Connect To                               admin_alias=ADMIN_SW_Update_in_background
    keyword.IM SWM usageState Should Be Idle - Slave    admin_alias=ADMIN_SW_Update_in_background
    Sleep  5
    ${output_task_abort_in_background}   taf.sbts.oam.coam.admin.run_keyword_in_background
    ...             interface=${CLI_INTERFACE}
    ...             name=update_software
    ...             sw_package=${SW_DESTINATION}${T1_package}
    ...             should_activate=${TRUE}
    ...             connection=ADMIN_SW_Update_in_background
    Sleep  5
    run keyword and ignore error   IM Wait Until SW activation is ongoing    retry=10 min    retry_interval=1 sec
    run keyword and expect error  *    keyword.ADMIN Configuration Reset
    SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    Sleep  360
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/run/
    should contain  ${output}  	TargetBD_${out_active_sw}T1.xml
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    should not contain  ${output}  	planned
    should contain  ${output}  	TargetBD_${out_active_sw}.xml

Preconditions for Configuration_Reset_on_Dual_Core
    ADMIN Perform Delta Recommissioning     ${delta_activate_users_activation}
    taf_ssh.Connect To  hostname=10.5.25.106  username=ute  password=ute  alias=remote
    taf_ssh.Download File  /home/ute/NU_STERGE/bts-83_cert.p12  ${certificate_file}  connection=remote
    taf_ssh.Disconnect   connection=remote
#    taf_ssh.File Exists  ${certificate_file}
#    taf_ssh.Execute  unzip -o ${certificate_file} -d /home/ute/  connection=remote
    taf_admin.Install Certificate   cert_file=/home/ute/bts-83_cert.p12  cert_type=BtsTrustChain
    ...     cert_format=P12     password=123456
    ${certificate_details}=     taf_admin.Get Certificate List   type=BTS  cert_type=BTS
    Should Not Be Empty     ${certificate_details}

Configuration_Reset_on_Dual_Core
    Log To Console      START Test Case 3: Configuration Reset In Dual Core Mode
    SELENIUM Prepare Enviroment
    Login To Web Element Manager
    SELENIUM Go to Configuration Reset
    Remove User Accounts and Certificates
    Execute Configuration Reset
    Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Not Commisioned
    SC Response to Ping as Single Core
    User Accounts and Certificate Check

Remote_Migration_from_single_core_to_dual_core_leftPrimary
    Log To Console      START Test Case 4: Remote Migration from Single Core to Dual Core Left Primary
    log to console   Perform reset configuration
    Preconditions for Configuration_Reset_on_Dual_Core
    Configuration_Reset_on_Dual_Core
    Left Single Core Configuration
    Left Side Primary in Dual Core Configuration
    SC Modules Visible in WebEM
    Get SMODs Role and Position

#...................................................................................................................
Suite Postconditions
    Log
    ...    message=\n+ Started Suite POSTconditions: ${SUITE_NAME}
    ...    console=yes
    ADMIN Collect Snapshot
#    PREPOST Collect Scf File Postsuite
    PREPOST Teardown Admin
    Log Variables
#    ADMIN Teardown Admin
    Log
    ...    message=\n+ Finished Suite POSTconditions: ${SUITE_NAME}
    ...    console=yes

Precondition for DW software
    Run  rm -f /home/ute/SBTS00_ENB_9999_*
    Download SW

IM Wait Until SW activation is ongoing
    [Arguments]    ${retry}=2 min
    ...            ${retry_interval}=10 sec
    ...            ${admin_alias}=ADMIN_IM
    Log To Console    IM Wait Until SW activation is ongoing
    Log To Console    ${SPACE * 4}\${admin_alias}=${admin_alias} \${retry}=${retry} \${retry_interval}=${retry_interval}
    ADMIN Connect To     admin_alias=${admin_alias}
    Wait Until Keyword Succeeds    ${retry}
    ...                            ${retry_interval}
    ...                            IM SW activation is ongoing - Slave
    ...                            admin_alias=${admin_alias}
    run keyword and ignore error   ADMIN Teardown    admin_alias=${admin_alias}

IM SW activation is ongoing - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${admin_alias}=ADMIN_IM
    Log To Console        IM SW activation is ongoing - Slave
    ${SW_act_req}    IM SW activation Get swActivationType    admin_alias=${admin_alias}
    Should Be Equal       ${SW_act_req}       NormalSwUpdate

IM SW activation Get swActivationType
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${admin_alias}=ADMIN_IM
    Log To Console        IM SW activation Get swActivationType
    ADMIN Connect To      admin_alias=${admin_alias}
    ${SW_act_req}    IM SW activation Get swActivationType - Slave
    [Teardown]            ADMIN TEARDOWN    admin_alias=${admin_alias}
    [Return]    ${SW_act_req}

IM SW activation Get swActivationType - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${admin_alias}=ADMIN_IM
    Log To Console            IM SW activation Get swActivationType - Slave
#    ${dict_SWM}    Run Keyword If      '${OUT_ADMIN_SMOD_POSITION}' == 'left'
#    ...   taf.sbts.oam.coam.admin.get_parameters  /MRBTS-1/RAT-1/SWM-1/SW_ACTIVATE_REQ-1  swActivationType  connection=${admin_alias}
#    ...   ELSE IF    '${OUT_ADMIN_SMOD_POSITION}' == 'right'
#    ...   taf.sbts.oam.coam.admin.get_parameters  /MRBTS-1/RAT-1/SWM-4/SW_ACTIVATE_REQ-1  swActivationType  connection=${admin_alias}
#    ...   ELSE
#    ...   Fail       msg=Unknown BTS side.
    ${dict_SWM}               taf.sbts.oam.coam.admin.get_parameters
    ...     /MRBTS-1/RAT-1/SWM-1/SW_ACTIVATE_REQ-1      swActivationType    connection=${admin_alias}
    Log To Console            \${dict_SWM}=${dict_SWM}
    ${SW_act_req}               collections.Get From Dictionary          ${dict_SWM}               swActivationType
    Log To Console            \${SW_act_req}=${SW_act_req}
    [Return]    ${SW_act_req}

User Accounts and Certificate Check
    ${outpup}=      SYSTEM Execute Command On gNB      cat /ffs/run/config/users.json
    ${inactive_lines}=      Get Lines Containing String     ${outpup}      "isActive" : "Inactive",
    ${count_inactive}=      Get Line Count  ${inactive_lines}
    ${count_inactive_2}=    Convert to String   ${count_inactive}
    Should Be Equal  ${count_inactive_2}  3
    ${certificate_details}=     taf_admin.Get Certificate List   type=BTS  cert_type=BTS
    Should Be Empty     ${certificate_details}
    Log to Console  Certificate Removed from Primary Core

SC Response to Ping as Single Core
    taf_ssh.connect to    10.5.25.140    ute    ute    alias=SC
    Sleep  5s
    taf_ssh.send_command    command=ping -c 1 -W 10 192.168.255.129    connection=SC
    ${ping_command}  taf_ssh.read output     connection=SC
    Should contain  ${ping_command}   1 packets transmitted, 1 received  timeout=5
    taf_ssh.disconnect    connection=SC

#Wait No Ping
#    taf_ssh.send_command    command=ping -c 1 -W 10 192.168.255.129
#    ${ping_command}  taf_ssh.read output
#    Should contain  ${ping_command}   1 packets transmitted, 1 received  timeout=5
#    taf_ssh.disconnect    connection=SC

Remove User Accounts and Certificates
    Run Keyword If  '${branch}' == '5G21A'  Run Keyword  Remove User Accounts and Certificates on Branch
    ...    ELSE  Run Keyword  Remove User Accounts and Certificates on Trunk

Remove User Accounts and Certificates on Branch
    @{user_certifaicates_remove_branch}=   Get WebElements      //span[@class="checkbox-value"]
    FOR   ${i}   IN    @{user_certifaicates_remove_branch}
         SELENIUM Click Visible Element   locator=${i}
         Sleep  2
    END

Remove User Accounts and Certificates on Trunk
    @{user_certifaicates_remove_trunk}=   Get WebElements      //span[@class="checkbox-value ng-binding"]
    FOR   ${i}   IN    @{user_certifaicates_remove_trunk}
         SELENIUM Click Visible Element   locator=${i}
         Sleep  2
    END

Execute Configuration Reset
    ${execute_reset_button}=   Get WebElement      //div[@class="execution-bar"]//ui-button[@a-text="Execute Reset"]
    Click Element   locator=${execute_reset_button}
    SELENIUM Click Visible Element   locator=${POP_EXECUTE_BTN}
#    Run Keyword and Continue on Failure    Element Should Be Visible   //div[contains(text(), "Execution succeeded")]
    Sleep  10

Login To Web Element Manager
    #[Arguments]    ${browser_url}=${WEBEM_IP}
    #...            ${webem_username}=${USERNAME}
    #...            ${webem_password}=${PASSWORD}
    #...            ${browser_type}=chrome
    #...            ${browser_alias}=browser
    Set Selenium Implicit Wait    5
    Open Browser
    Run Keyword If  '${branch}' == '5G21A'  Run Keyword  Login Credentials 5G21A
    ...         ELSE  Run Keyword  Login Credentials SBTS
    SELENIUM Pop Confirm
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//ui-button[@a-text="Close"]
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "STARTED")]
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "SUCCEEDED")]

Open Browser
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --window-size\=1900,1200
#    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    https://192.168.255.129

Login Credentials SBTS
    [Arguments]    ${webem_username}=${USERNAME}
    ...            ${webem_password}=${PASSWORD}
    Input Text        id=login-username    ${webem_username}
    Input Password    id=login-password    ${webem_password}
    Click Button      locator=//button[@class="p-ripple p-element p-button p-component"]
#    Run Keyword If  '${branch}' == 'SBTS22R3'
#    ...     Click Button      locator=//button[@class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"]
#    ...     ELSE
#    ...     Click Button      locator=//button[@class="p-ripple p-element p-button p-component"]

Login Credentials 5G21A
    [Arguments]    ${webem_username}=${USERNAME}
    ...            ${webem_password}=${PASSWORD}
    SELENIUM Input Text in Visible Element
    ...    locator=${WELCOME_SCREEN_USERNAME_INPUT}
    ...    text=${webem_username}
    Input Text
    ...    locator=${WELCOME_SCREEN_PASS_INPUT}
    ...    text=${webem_password}
    Click Element
    ...    locator=${WELCOME_SCREEN_LOGIN_BTN}

Branch or Trunk
    @{sw_version}=  Split String  ${out_active_sw}  separator=\_
    ${branch}=  Set Variable  @{sw_version}[0]
    Set Global Variable  ${branch}

Get SMODs Role and Position
    Sleep   180
    ${get_smod_r}     taf_admin.get_managed_objects    SMOD_R    timeout=10
    ${primary}   Run Keyword And Return Status   Should Be Equal    ${get_smod_r[0]["parameters"]["activeRole"]}    Primary
    Run Keyword Unless   ${primary}    Should Be Equal    ${get_smod_r[0]["parameters"]["activeRole"]}    Secondary
    ${1}   Run Keyword And Return Status   Should Be Equal As Integers    ${get_smod_r[0]["parameters"]["horizontalPosition"]}    ${1}
    Run Keyword Unless   ${1}   Should Be Equal As Integers    ${get_smod_r[0]["parameters"]["horizontalPosition"]}    ${2}
    ${secondary}   Run Keyword And Return Status   Should Be Equal    ${get_smod_r[1]["parameters"]["activeRole"]}    Secondary
    Run Keyword Unless   ${secondary}   Should Be Equal    ${get_smod_r[1]["parameters"]["activeRole"]}    Primary
#    ${2}   Run Keyword And Return Status   Should Be Equal As Integers    ${get_smod_r[1]["parameters"]["horizontalPosition"]}    ${2}
#    Run Keyword Unless   ${2}   Should Be Equal As Integers    ${get_smod_r[1]["parameters"]["horizontalPosition"]}    ${1}
#    ${get_smod_a}     taf_admin.get_managed_objects    SMOD_A    timeout=10
#    Should Be Equal    ${get_smod_a[0]["parameters"]["positionInSubrack"]}    LeftSide
#    Should Be Equal    ${get_smod_a[1]["parameters"]["positionInSubrack"]}    RightSide

Left Single Core Configuration
    ADMIN Check BTS Not Commisioned
    ADMIN Perform Commissioning
    ...     scf_file=${scf_leftside_single_core}
    ...     skip_parameter_relation_errors=True
#    taf_ping.Wait For No Ping   192.168.255.129  timeout=60
    ADMIN Wait Until BTS OnAir
#    Wait until keyword succeeds  900  30   ADMIN Check BTS onair
    ADMIN Assert No Unexpected Active Alarms   alowed_alarms_list=@{ALLOWED_ALARMS}
    SC Response to Ping as Single Core

Left Side Primary in Dual Core Configuration
    ADMIN Perform Commissioning
    ...     scf_file=${scf_leftside_dual_core}
    ...     skip_parameter_relation_errors=False
    ADMIN Wait Until BTS OnAir
#    Wait until keyword succeeds  600  30   ADMIN Check BTS onair    timeout=900
    ADMIN Assert No Unexpected Active Alarms
    SC Response to Ping as Dual Core

SC Modules Visible in WebEM
    Login To Web Element Manager via MNGM IP
    SELENIUM Go To Detailed Site View
    Wait Until Element Is Visible
    ...    locator=//div[@aria-label="System Module 1"]
    Wait Until Element Is Visible
    ...    locator=//div[@aria-label="System Module 2"]
    Wait Until Element Is Visible
    ...    locator=//div[@aria-label="Baseband Module 1"]
    Wait Until Element Is Visible
    ...    locator=//div[@aria-label="Baseband Module 2"]
    Wait Until Element Is Visible
    ...    locator=//div[@aria-label="Baseband Module 3"]
    Wait Until Element Is Visible
    ...    locator=//div[@aria-label="Baseband Module 4"]
#    ${smod_webElement}   Get WebElements     //div[@class="site-widget-container SMOD_R"]
#    ${smod_count}   Get Length   ${smod_webElement}
#    Should Be Equal     ${smod_count}  ${2}
#    ${im_bbmod_object}      taf_admin.Get Managed Objects     class_name=BBMOD
#    ${im_bbmod_count}   Get Length   ${im_bbmod_object}
#    ${bbmod_webElement}   Get WebElements     //div[@class="site-widget-container BBMOD_R"]
#    ${bbmod_count}   Get Length   ${bbmod_webElement}
#    Should Be Equal     ${bbmod_count}  ${im_bbmod_count}

SC Response to Ping as Dual Core
    taf_ssh.connect to    10.5.25.140    ute    ute    alias=SC
    Sleep  5s
    taf_ssh.send_command    command=ping -c 1 -W 10 192.168.255.119    connection=SC
    ${ping_command}  taf_ssh.read output     connection=SC
    Should contain  ${ping_command}   1 packets transmitted, 1 received  timeout=5
    taf_ssh.disconnect    connection=SC

Login To Web Element Manager via MNGM IP
    #[Arguments]    ${browser_url}=${WEBEM_IP}
    #...            ${webem_username}=${USERNAME}
    #...            ${webem_password}=${PASSWORD}
    #...            ${browser_type}=chrome
    #...            ${browser_alias}=browser
    Set Selenium Implicit Wait    5
    Open Browser to MNGM IP
    Run Keyword If  '${branch}' == '5G21A'  Run Keyword  Login Credentials 5G21A
    ...         ELSE  Run Keyword  Login Credentials SBTS
    SELENIUM Pop Confirm
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//ui-button[@a-text="Close"]
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "STARTED")]
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "SUCCEEDED")]

Open Browser to MNGM IP
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --window-size\=1900,1200
#    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    https://10.15.232.41

UTE TL Preparation
    [Documentation]  Keyword used for setting up local 5G TLs to onAir state, as UTE reserve it only to sw_upload state
    #TO DO:             Add Check for onAir State. For cases when the Suite is run more than one time
    PREPOST Setup Admin
    ADMIN Change R&D Port Status    status=True
    @{status}   Run Keyword and Ignore Error    ADMIN Check BTS onair
    Run Keyword If  '@{status}[0]' == 'FAIL'   Run Keyword  FGCR-9836-K.Configured_SwDownload_SwUpdate_OnAir
    ...     ELSE    Log To Console  --- BTS already onAir ---
    PREPOST Teardown Admin

Configured_SwDownload_SwUpdate_OnAir
    ADMIN Check BTS Not Commisioned
    Get TL Hostname
    Get Software Release
    ADMIN Perform Commissioning
    ...   scf_file=/home/ute/MN/UTE/robotws/custom-config/Timisoara/${tl_hostname}/${sw_release}/${tl_hostname}_SCF.xml
    ...   skip_parameter_relation_errors=${True}
    ${configured}   Run Keyword and Return Status
    ...    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    Run Keyword If  '${configured}' == 'True'  Sleep  180
    Run Keyword Unless   ${configured}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    ...    AND     Sleep  180
    Log To Console  Fault ID23 Checking...
    ${result}   Run Keyword and Return Status    ADMIN Check If Alarm Is Active  fault_id=23
    BuiltIn.Run Keyword If  '${result}' == 'True'   Run Keywords
    ...    Log To Console  Fault ID23 found. Start RF Software Update
    ...     AND     ADMIN Download And Update Current Software
    ...     ELSE    Log To Console  Fault ID23 not found.
    ${onair}   Run Keyword and Return Status
    ...    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    Run Keyword Unless   ${onair}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir


