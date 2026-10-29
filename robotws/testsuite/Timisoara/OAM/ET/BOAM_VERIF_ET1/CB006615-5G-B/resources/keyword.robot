*** Settings ***

Documentation
...     14.01.2025 - updated :FOR function and solved RF5.0 issues

Library    OperatingSystem
Library    Collections
Library    String
Library    taf.transport.ssh
Library    taf.gnb.oam.coam.admin
Library    taf.ul.oam.selenium_coam

Resource    ../../resources/admin.robot
Resource    ../../resources/fault_trigger.robot
Resource    ../../resources/selenium.robot


*** Variables ***
# ${SMOD_SW_Update_directory_planned}    /ffs/stb/planned/
# ${SMOD_SW_Update_file_SWDLreport}    /tmp/SWDLreport.txt
${SMOD_com_reboot}    ddal -s ddal_reboot_graceful

${triger_sc_test}    /opt/ute/python3/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d
...    results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB006615-5G-B/general_SC.robot
${bts-cert_package}     home/userbtsoam/share1btsoam/ET_VERIF4/BTS_cert
#${bts-cert_location}     home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB006615-5G-B/resources
${bts-cert_location}     ${CURDIR}

*** Keywords ***

Precondition for DW software
#    Run  rm -f /home/ute/SBTS00_ENB_9999_*
#    Run  rm -f /home/ute/SBTS00_ENB_0000_*
    Download SW


Download SW
#    Set Suite Variable  ${OUT_ACTIVE_SW}  5G20B_GNB_0000_000800_001758
    Set Suite Variable    ${active_software}    ${OUT_ACTIVE_SW}
    ${active_software_split}=    Split String
    ...                          string=${active_software}
    ...                          separator=_
    ...                          max_split=4
    ${BRANCH}=   Get from list         ${active_software_split}    2
    Run Keyword If  '${BRANCH}'=='9999'   Download SW for SBTS00
    ...   ELSE IF   '${BRANCH}'=='0000'   Download SW for SBTS00
    ...   ELSE IF   '${BRANCH}'=='0011'   Download SW for branch 5G

Download SW for SBTS00
    Set Suite Variable    ${active_software}    ${OUT_ACTIVE_SW}
    ${split_build}=    Split string       ${active_software}    separator=\_
    ${trunk_flag}=     Get from list       ${split_build}     2
    ${version_flag}=   Get from list       ${split_build}     0
    Log     ${TRUNK_VERSION}
    Log     ${version_flag}

    ${download_build}=    Run keyword if    '${trunk_flag}'=='0000'    Set Variable   ${active_software}
    ...   ELSE IF   '${version_flag}'=='${TRUNK_VERSION}'    Replace String    ${active_software}    ${TRUNK_VERSION}    SBTS00
    ...   ELSE IF   '${version_flag}'=='SBTS22R4'    Replace String    ${active_software}    ${version_flag}    SBTS00
#     ${tc_name}=    Replace String    string=${TEST NAME}    search_for=${SPACE}    replace_with=_
	...   ELSE   	Set Variable   ${active_software}
#    ${download_build}=  Set Variable    SBTS00_ENB_9999_210622_000005

    Set Suite Variable    ${main_package}    ${download_build}_release_BTSSM_downloadable.zip
    Set Suite Variable    ${T1_package}    ${download_build}_release_BTSSM_downloadable_testpackage_T1.zip
    Set Suite Variable    ${T2_package}    ${download_build}_release_BTSSM_downloadable_testpackage_T2.zip
    Log    \nDownload SW packages    console=yes
#    Run    wget ${jenkins_url}${download_build}/${main_package} -P ${SW_DESTINATION}
#    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${main_package}
    Run    wget ${jenkins_url}${download_build}/${T2_package} -P ${SW_DESTINATION}
    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${T2_package}
#    Run    wget ${jenkins_url}${download_build}/${T2_package} -P ${SW_DESTINATION}
#    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${T2_package}
    Log    Download completed    console=yes

Download SW for branch 5G
    Set Suite Variable    ${active_software}    ${OUT_ACTIVE_SW}
    ${active_software_split}=    Split String
    ...                          string=${active_software}
    ...                          separator=_
    ...                          max_split=4
    ${BRANCH}=   Get from list         ${active_software_split}    2
    ${version}=  Run Keyword If  '${BRANCH}'=='0011'  Convert To String  11.800
    Set Suite Variable    ${active_software_number}    ${active_software_split[4]}
    ${active_software_number}=    Convert To Integer    ${active_software_number[:6]}
    Set Suite Variable    ${main_package}    AirScale-${version}.${active_software_number}.zip
    Set Suite Variable    ${T1_package}    AirScale-${version}.${active_software_number}T1.zip
    Set Suite Variable    ${T2_package}    AirScale-${version}.${active_software_number}T2.zip
    Log    \nDownload SW packages    console=yes
    Run    wget ${DOWNLOAD_HOST}/${version}.${active_software_number}/${main_package} -P ${SW_DESTINATION}
    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${main_package}
    Run    wget ${DOWNLOAD_HOST}/${version}.${active_software_number}/${T1_package} -P ${SW_DESTINATION}
    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${T1_package}
    Run    wget ${DOWNLOAD_HOST}/${version}.${active_software_number}/${T2_package} -P ${SW_DESTINATION}
    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${T2_package}
    Log    Download completed    console=yes

Verify SW Version
    Set Suite Variable    ${active_software}    ${OUT_ACTIVE_SW}
    ${active_software_split}=    Split String
    ...                          string=${active_software}
    ...                          separator=_
    ...                          max_split=4
    ${BRANCH}=   Get from list         ${active_software_split}    2
    ${version}=  Run Keyword If  '${BRANCH}'=='9999'  ADMIN Check If Alarm Is Active   fault_id=1936
	...                    ELSE IF   '${BRANCH}'=='0010'  ADMIN Check If Alarm Is Not Active   fault_id=1936

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
    [Teardown]    ADMIN Teardown    admin_alias=${admin_alias}

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

#IM SW activation Get swActivationType - Slave
#    [Documentation]    Slave - use existing connection.
#    [Arguments]        ${admin_alias}=ADMIN_IM
#    Log To Console            IM SW activation Get swActivationType - Slave
#    Log To Console      BTS side is: ${OUT_ADMIN_SMOD_POSITION}
#    ${OUT_ADMIN_SMOD_POSITION}=   Set variable   ${Primary_Position}
#    Log To Console      after BTS side is: ${OUT_ADMIN_SMOD_POSITION}
#    ${dict_SWM}    Run Keyword If      '${OUT_ADMIN_SMOD_POSITION}' == 'left'
#    ...   taf.gnb.oam.coam.admin.get_parameters   ${soft_activation}  swActivationType  connection=${admin_alias}
#    ...   ELSE IF    '${OUT_ADMIN_SMOD_POSITION}' == 'right'
#    ...   taf.gnb.oam.coam.admin.get_parameters   ${soft_activation_right}  swActivationType  connection=${admin_alias}
#    ...   ELSE
#    ...   Fail       msg=Unknown BTS side.
#    Log To Console            \${dict_SWM}=${dict_SWM}
#    ${SW_act_req}               collections.Get From Dictionary          ${dict_SWM}               swActivationType
#    Log To Console            \${SW_act_req}=${SW_act_req}
#    [Return]    ${SW_act_req}

IM SW activation Get swActivationType - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${admin_alias}=ADMIN_IM
    Log To Console            IM SW activation Get swActivationType - Slave
    Log To Console      BTS side is: ${OUT_ADMIN_SMOD_POSITION}
    ${OUT_ADMIN_SMOD_POSITION}=   Set variable   ${Primary_Position}
    Log To Console      after BTS side is: ${OUT_ADMIN_SMOD_POSITION}
    ${dict_SWM}    Run Keyword If      '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...   taf.gnb.oam.coam.admin.get_parameters   ${soft_activation}  swActivationType  connection=${admin_alias}
    ...   ELSE IF    '${OUT_ADMIN_SMOD_POSITION}' == 'right'
    ...   taf.gnb.oam.coam.admin.get_parameters   ${soft_activation_right}  swActivationType  connection=${admin_alias}
    ...   ELSE
    ...   Fail       msg=Unknown BTS side.
    Log To Console            \${dict_SWM}=${dict_SWM}
    ${SW_act_req}               collections.Get From Dictionary          ${dict_SWM}               swActivationType
    Log To Console            \${SW_act_req}=${SW_act_req}
    [Return]    ${SW_act_req}

IM SWM usageState Should Be Idle - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${admin_alias}=ADMIN_IM
    Log To Console        IM SWM usageState Should Be Idle
    ${SWM_usage_state}    IM SWM Get usageState - Slave    admin_alias=${admin_alias}
    Should Be Equal       ${SWM_usage_state}               Idle

IM SWM Get usageState - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${admin_alias}=ADMIN_IM
    Log To Console            IM SWM Get usageState - Slave
    ${dict_SWM}               Run Keyword If                           '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...                       taf.gnb.oam.coam.admin.get_parameters    /MRBTS-1/RAT-1/SWM-1      usageState    connection=${admin_alias}
    ...                       ELSE IF                                  '${OUT_ADMIN_SMOD_POSITION}' == 'right'
    ...                       taf.gnb.oam.coam.admin.get_parameters    /MRBTS-1/RAT-1/SWM-4      usageState    connection=${admin_alias}
    ...                       ELSE
    ...                       Fail                                     msg=Unknown BTS side.
    Log To Console            \${dict_SWM}=${dict_SWM}
    ${dict_SWM_state_info}    collections.Get From Dictionary          ${dict_SWM}               stateInfo
    Log To Console            \${dict_SWM_state_info}=${dict_SWM_state_info}
    ${SWM_usage_state}        collections.Get From Dictionary          ${dict_SWM_state_info}    usageState
    Log To Console            \${SWM_usage_state}=${SWM_usage_state}
    [Return]    ${SWM_usage_state}

IM SWM Get usageState
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${admin_alias}=ADMIN_IM
    Log To Console        IM SWM Get usageState
    ADMIN Connect To      admin_alias=${admin_alias}
    ${SWM_usage_state}    IM SWM Get usageState - Slave
    [Teardown]            ADMIN TEARDOWN    admin_alias=${admin_alias}
    [Return]    ${SWM_usage_state}

Preconditions for Configuration_Reset_on_Dual_Core
    Run And Return Rc And Output  sshpass -p 'Aikonbtsoam2@' scp userbtsoam@10.5.25.200:/${bts-cert_package}/* /${bts-cert_location}
    ADMIN Perform Delta Recommissioning     ${delta_activate_users_activation}
    taf_ssh.Connect To  hostname=${SC_VM_IP}  username=ute  password=ute  alias=remote
    taf_ssh.Download File  ${bts_83certificate}  ${certificate_file}  connection=remote
    taf_ssh.Disconnect   connection=remote
#    taf_ssh.File Exists  ${certificate_file}
#    taf_ssh.Execute  unzip -o ${certificate_file} -d /home/ute/  connection=remote
    taf_admin.Install Certificate   cert_file=${certificate_file}  cert_type=BtsTrustChain
    ...     cert_format=P12     password=123456
    ${certificate_details}=     taf_admin.Get Certificate List   type=BTS
    Should Not Be Empty     ${certificate_details}


User Accounts and Certificate Check
    ${outpup}=      SYSTEM Execute Command On gNB      cat /ffs/run/config/users.json
    ${inactive_lines}=      Get Lines Containing String     ${outpup}      "isActive" : "Inactive",
    ${count_inactive}=      Get Line Count  ${inactive_lines}
    ${count_inactive_2}=    Convert to String   ${count_inactive}
    Should Be Equal  ${count_inactive_2}  3
    ${certificate_details}=     taf_admin.Get Certificate List   type=BTS
    Should Be Empty     ${certificate_details}
    Log to Console  Certificate Removed from Primary Core


SC Response to Ping as Single Core
    taf_ssh.connect to    ${SC_VM_IP_SEC}    ute    ute    alias=SC
    Sleep  5s
    taf_ssh.send_command    command=ping -c 1 -W 10 192.168.255.129    connection=SC
    ${ping_command}  taf_ssh.read output     connection=SC
    Should contain  ${ping_command}   1 packets transmitted, 1 received  timeout=5
    taf_ssh.disconnect    connection=SC

Wait No Ping
    taf_ssh.send_command    command=ping -c 1 -W 10 192.168.255.129
    ${ping_command}  taf_ssh.read output
    Should contain  ${ping_command}   1 packets transmitted, 1 received  timeout=5
    taf_ssh.disconnect    connection=SC

Get SMODs Role and Position
    ${get_smod_r}     taf_admin.get_managed_objects    SMOD_R    timeout=10
    ${primary}   Run Keyword And Return Status   Should Be Equal    ${get_smod_r[0]["parameters"]["activeRole"]}    Primary
    Run Keyword Unless   ${primary}    Should Be Equal    ${get_smod_r[0]["parameters"]["activeRole"]}    Secondary
    ${1}   Run Keyword And Return Status   Should Be Equal As Integers    ${get_smod_r[0]["parameters"]["horizontalPosition"]}    ${1}
    Run Keyword Unless   ${1}   Should Be Equal As Integers    ${get_smod_r[0]["parameters"]["horizontalPosition"]}    ${2}
    ${secondary}   Run Keyword And Return Status   Should Be Equal    ${get_smod_r[1]["parameters"]["activeRole"]}    Secondary
    Run Keyword Unless   ${secondary}   Should Be Equal    ${get_smod_r[1]["parameters"]["activeRole"]}    Primary
    ${2}   Run Keyword And Return Status   Should Be Equal As Integers    ${get_smod_r[1]["parameters"]["horizontalPosition"]}    ${2}
    Run Keyword Unless   ${2}   Should Be Equal As Integers    ${get_smod_r[1]["parameters"]["horizontalPosition"]}    ${1}
#    ${get_smod_a}     taf_admin.get_managed_objects    SMOD_A    timeout=10
#    Should Be Equal    ${get_smod_a[0]["parameters"]["positionInSubrack"]}    LeftSide
#    Should Be Equal    ${get_smod_a[1]["parameters"]["positionInSubrack"]}    RightSide


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
#    [Arguments]    ${browser_url}=${WEBEM_IP}
#    ...            ${webem_username}=${USERNAME}
#    ...            ${webem_password}=${PASSWORD}
#    ...            ${browser_type}=chrome
#    ...            ${browser_alias}=browser
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
    Click Button      Login
#

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



Left Single Core Configuration
    ADMIN Check BTS Not Commisioned
    ADMIN Perform Commissioning
    ...     scf_file=${scf_leftside_single_core}
    ...     skip_parameter_relation_errors=True
    taf_ping.Wait For No Ping   192.168.255.129  timeout=60
#    ADMIN Wait Until BTS OnAir
    Wait until keyword succeeds  900  30   ADMIN Check BTS onair
    ADMIN Assert No Unexpected Active Alarms
    SC Response to Ping as Single Core


Left Side Primary in Dual Core Configuration
    Set Suite Variable    ${active_software}    ${OUT_ACTIVE_SW}
    ${active_software_split}=    Split String
    ...                          string=${active_software}
    ...                          separator=_
    ...                          max_split=4
    ${BRANCH}=   Get from list         ${active_software_split}    2
    ${version}=  Run Keyword If  '${BRANCH}'=='9999'  ADMIN Perform Commissioning
    ...     scf_file=${scf_leftside_dual_core}
    ...     skip_parameter_relation_errors=True
    ...     ELSE  Run Keyword  ADMIN Perform Commissioning
    ...     scf_file=${scf_leftside_dual_core_branch}
    ...     skip_parameter_relation_errors=True

#    ADMIN Perform Commissioning
#    ...     scf_file=${scf_leftside_dual_core}
#    ...     skip_parameter_relation_errors=True
    Wait Until Keyword Succeeds
    ...    900
    ...    30
    ...    ADMIN INFOMODEL Check If BTS Is Configured
    Wait until keyword succeeds  1500  30   ADMIN Check BTS onair
#    ADMIN Assert No Unexpected Active Alarms
    SC Response to Ping as Dual Core


SC Modules Visible in WebEM
    Login To Web Element Manager via MNGM IP
    SELENIUM Go To Detailed Site View
    sleep  3
    ${smod_webElement}   Get WebElements     //div[@class="site-widget-container SMOD_R"]
    ${smod_count}   Get Length   ${smod_webElement}
    Should Be Equal     ${smod_count}  ${2}
    ${im_bbmod_object}      taf_admin.Get Managed Objects     class_name=BBMOD
    ${im_bbmod_count}   Get Length   ${im_bbmod_object}
    ${bbmod_webElement}   Get WebElements     //div[@class="site-widget-container BBMOD_R"]
    ${bbmod_count}   Get Length   ${bbmod_webElement}
    Should Be Equal     ${bbmod_count}  ${im_bbmod_count}
#    Close Browser

SC Response to Ping as Dual Core
    taf_ssh.connect to    ${SC_VM_IP_SEC}    ute    ute    alias=SC
    Sleep  5s
    taf_ssh.send_command    command=ping -c 1 -W 10 192.168.255.119    connection=SC
    ${ping_command}  taf_ssh.read output     connection=SC
    Should contain  ${ping_command}   1 packets transmitted, 1 received  timeout=5
    taf_ssh.disconnect    connection=SC


Login To Web Element Manager via MNGM IP
#    [Arguments]    ${browser_url}=${WEBEM_IP}
#    ...            ${webem_username}=${USERNAME}
#    ...            ${webem_password}=${PASSWORD}
#    ...            ${browser_type}=chrome
#    ...            ${browser_alias}=browser
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
    Goto        ${M-PLANE_IP}

Open Browser to MNGM IP SEC
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --window-size\=1900,1200
#    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto        ${M-PLANE_IP_SEC}

Login To Web Element Manager via M-PLANE IP
#    [Arguments]    ${browser_url}=${M-PLANE_IP_SEC}
#    ...            ${webem_username}=${USERNAME}
#    ...            ${webem_password}=${PASSWORD}
#    ...            ${browser_type}=chrome
#    ...            ${browser_alias}=browser
    Set Selenium Implicit Wait    5
    Open Browser to MNGM IP SEC
    Run Keyword If  '${branch}' == '5G21A'  Run Keyword  Login Credentials 5G21A
    ...         ELSE  Run Keyword  Login Credentials SBTS
    SELENIUM Pop Confirm
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//ui-button[@a-text="Close"]
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "STARTED")]
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "SUCCEEDED")]

ADMIN Connect To
    [Arguments]    ${admin_alias}=default
    Log To Console                       ADMIN Connect To \${admin_alias}=${admin_alias}
    taf.gnb.oam.coam.admin.Connect To    name=${admin_alias}

ADMIN Configuration Reset
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${admin_alias}=ADMIN_configuration_reset
    Log To Console      ADMIN Configuration Reset \${admin_alias}=${admin_alias}
    ADMIN Connect To    admin_alias=${admin_alias}
    taf.gnb.oam.coam.admin.Reset Configuration
    ...                 connection=${admin_alias}
    [Teardown]    ADMIN Teardown    admin_alias=${admin_alias}

ADMIN Teardown
    [Arguments]    ${admin_alias}=default
    Log To Console                     Admin Teardown \${admin_alias}=${admin_alias}
    taf.gnb.oam.coam.admin.Teardown    connection=${admin_alias}

Right Side In Single Core
    taf_ssh.connect to    ${SC_VM_IP_SEC}    ute    ute    alias=SC
    Sleep  10s
    taf_ssh.send_command    command=${triger_sc_test}    connection=SC
    ${command_return}  taf_ssh.read output     connection=SC
    log to console  ${command_return}
    Should contain  ${command_return}   1 test total, 1 passed, 0 failed
    taf_ssh.disconnect    connection=SC
    Sleep   10

Left Side In Single Core
    log to console  Perform commissioning  on BTS
    Set Suite Variable    ${active_software}    ${OUT_ACTIVE_SW}
    ${active_software_split}=    Split String
    ...                          string=${active_software}
    ...                          separator=_
    ...                          max_split=4
    ${BRANCH}=   Get from list         ${active_software_split}    2
    ${version}=  Run Keyword If  '${BRANCH}'=='9999'  ADMIN Perform Commissioning
    ...     scf_file=${scf_leftside_single_core}
    ...     skip_parameter_relation_errors=True
    ...     ELSE  Run Keyword  ADMIN Perform Commissioning
    ...     scf_file=${scf_singlecore_branch}
    ...     skip_parameter_relation_errors=True
    Sleep  10
    log to console  Waiting for BTS Configured
    Wait Until Keyword Succeeds    2000    30     ADMIN INFOMODEL Check If BTS Is Configured
    Sleep   15
