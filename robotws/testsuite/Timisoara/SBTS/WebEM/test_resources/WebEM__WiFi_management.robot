*** Settings ***
Documentation
    ...  The scope of this TC is to check Configured SSD Wifi information on WebEM
    ...  Users can manage their connected WiFi clients by viewing client information and performing disconnect operations on selected clients.
    ...  Step1: Set parameters from 'Factory Set Users Table'. Open SSD Wi-Fi Configuration and set default users label.
    ...  Step2: Add WLAN object from parameter editor. Create WLAN object with BSSID objects.
    ...  Step3: Change actWifiLmp parameter to be enabled.
    ...  Step4: Configured user in SSD Wi-Fi Configuration. Add user to 'Configured User' table.
    ...  Step5: Add user label to BSSID from parameter editor.
    ...  Step6: Connect Wi-Fi Client and verify if is connected.Connection is successful and WiFi Management-Connected WiFi Clients tabs are present.
    ...  Step7: Terminate connection of selected WiFi client. Connection of the selected WiFi client is terminated and a confirmation dialog
    ...  is presented to ensure the action is intentional.

Resource    ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1800s  # Timeout for SBTS to recover
${SCF_WLAN_NA}  ${EMPTY}  # Mandatory! The name of SCF without WLAN object. Should exist in testline_configuration.
${SERVER_IP}  10.255.20.11  # Ip address for device to connect to Wi-Fi.
${SERVER_USERNAME}  ute
${SERVER_PASSWORD}  UTE.debian12
${WIFI_USER_LABEL}  usertest  # Name for Wi-Fi user.
${WIFI_USER_PASSWORD}  1234567890qwertyuiop  # Password for Wi-Fi user.


*** Keywords ***
TC__WebEM__WiFi_management
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26874
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  12.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26874 - Initial TAT creation
    ...  25.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30573 - User label was deleted and the XPath for the disconnect button was changed

    Set Tags  CA-WebEM  OWNER-nicolae-marcel.caragel@nokia.com  AUTHOR-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS26
    ...  FEATURE-CB009233

    Step0: Set Preconditions
    Step1: Set Parameters From Factory Set Users Table
    Step2: Add WLAN Object From Parameter Editor
    Step3: Change ActWifiLmp Parameter To Be Enabled
    Step4: Configured User In SSD Wi-Fi Configuration
    Step5: Add User Label To BSSID From Parameter Editor
    Step6: Connect Wi-Fi Client And Verify If Is Connected
    Step7: Terminate Connection Of Selected WiFi Client


Step0: Set Preconditions
    Log  \nStep0: Set Preconditions  console=true
    Should Not Be Empty  ${SCF_WLAN_NA}  SCF name without WLAN object must be specified, please provide it and retest.
    Load A Specific SCF  ${SCF_WLAN_NA}  ${RECOVERY_TIMEOUT}
    Close Startup View If Visible


Step1: Set Parameters From Factory Set Users Table
    Log  \nStep1: Set Parameters From Factory Set Users Table  console=true
    Open SSD Wi-Fi Configuration
    Wait Until Element Is Clicked  //*[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'Read SSD')]
    Wait Until Element Is Visible  //span[contains(text(),'Success')]  30
    ${USERS_DICTIONARY}  Create Dictionary
    Set Test Variable  ${USERS_DICTIONARY}
    ${number_of_rows}  SeleniumLibrary.Get Element Count
    ...  xpath=//blocks-factory-set-users/cem-block-panel/div/div[2]/div[1]/p-table/div/div[1]/table/tbody/tr
    FOR  ${row}  IN RANGE  1  ${number_of_rows}+1
        ${xpath_user_lable}  Catenate  SEPARATOR=  //blocks-factory-set-users/cem-block-panel/div/div[2]/div[1]/
        ...  p-table/div/div[1]/table/tbody/tr[${row}]/td[1]
        ${xpath_authentication_type}  Catenate  SEPARATOR=  //blocks-factory-set-users/cem-block-panel/div/div[2]/div[1]/
        ...  p-table/div/div[1]/table/tbody/tr[${row}]/td[2]
        ${user_lable}  Get Text  ${xpath_user_lable}
        ${authentication_type}  Get Text  ${xpath_authentication_type}
        Set To Dictionary  ${USERS_DICTIONARY}  ${user_lable}=${authentication_type}
    END


Step2: Add WLAN Object From Parameter Editor
    Log  \nStep2: Add WLAN Object From Parameter Editor  console=true
    Wait Until Element Is Clicked  ${PARAMETER_EDITOR}
    ${FILTER_XPATH}  Catenate  SEPARATOR=  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/div/blocks-navigation/ot-side-sheet/div/div[1]
    ...  /div/div[2]/p-tree/div/div/input
    Set Test Variable  ${FILTER_XPATH}
    Input Text  ${filter_xpath}  TNL-1
    Wait Until Element Is Clicked  //span[contains(@class, 'ot-highlight-text') and contains(text(), 'TNL-1')]
    Wait Until Element is Visible  //*[contains(@class, "mdi mdi-plus p-button-icon ng-star-inserted")]  20
    Wait Until Element Is Clicked  //*[contains(@class, "mdi mdi-plus p-button-icon ng-star-inserted")]
    Wait Until Element Is Clicked  //*[@id="className"]/div/span[1]
    Wait Until Element is Visible  //*[@id="className"]/div/div[3]/div[1]/div/input  20
    Input Text  //*[@id="className"]/div/div[3]/div[1]/div/input  WLAN
    Wait Until Element Is Clicked  //li[contains(@aria-label, "WLAN")]
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div[2]/p-button[1]/button/span
    Sleep  5s  Time for page to be updated
    Input Text  ${FILTER_XPATH}  WLAN-1
    Wait Until Element Is Clicked  //*[@class="cdk-virtual-scroll-content-wrapper"]/ul/p-treenode[4]/li/div/button/span
    ${status_wlan_object}  Run Keyword And Return Status  Wait Until Element is Visible
    ...  //div[contains(@class, 'p-element ot-text-ellipsis') and contains(text(), 'WLAN-1')]  20
    ${status_bssid_object}  Run Keyword And Return Status  Wait Until Element is Visible
    ...  //div[contains(@class, 'p-element ot-text-ellipsis') and contains(text(), 'BSSID-1')]  20
    IF  ${status_wlan_object} and ${status_bssid_object}  Log  Wlan object is created! It must be configured!  console=true
    Configuring BSSID objects


Step3: Change ActWifiLmp Parameter To Be Enabled
    Log  \nStep3: Change ActWifiLmp Parameter To Be Enabled  console=true
    ${status}  Run Keyword And Return Status  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  actWifiLmp  update
    ...  Enable  skip_parameter_relation_errors=True
    IF  ${status}
        Log  Parameter actWifiLmp is set to Enalbe![OK]  console=true
    ELSE
        Fail  Parameter actWifiLmp is not set to Enable![NOK]
    END
    Close Startup View If Visible  120s


Step4: Configured User In SSD Wi-Fi Configuration
    Log  \nStep4: Configured User In SSD Wi-Fi Configuration  console=true
    Open SSD Wi-Fi Configuration
    Wait Until Element Is Clicked  //*[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'Read SSD')]
    Wait Until Element Is Visible  //span[contains(text(),'Success')]  30
    Wait Until Element Is Clicked  //*[@id="configured-user-table"]/div/div[1]/table/tfoot/tr/td[7]/p-button/button/span[1]
    ${number_of_rows}  Get Element Count  //*[@id="configured-user-table"]/div/div[1]/table/tbody/tr
    FOR  ${row}  IN RANGE  1  ${number_of_rows}+1
        ${status_row}  Run Keyword And Return Status  Wait Until Element is Visible
        ...  //*[@id="configured-user-table"]/div/div[1]/table/tbody/tr[${row}]/td[1]/i  20
        IF  ${status_row}
            Input Text  //*[@id="configured-user-table"]/div/div[1]/table/tbody/tr[${row}]/td[2]/div/input  ${WIFI_USER_LABEL}
            Click Element  //*[@id="configured-user-table"]/div/div[1]/table/tbody/tr[${row}]/td[4]/p-dropdown
            Wait Until Element Is Clicked  //li[contains(@aria-label, "WPA2-PSK")]
            Input Text  //*[@id="configured-user-table"]/div/div[1]/table/tbody/tr[${row}]/td[6]/div/input  ${WIFI_USER_PASSWORD}
            Wait Until Element Is Clicked  //*[contains(text(),'Update')]
            Wait Until Element Is Visible  //*[contains(text(),'Update successfully')]  30
            Log  User is configured in 'User label'![OK]  console=true
        END
    END


Step5: Add User Label To BSSID From Parameter Editor
    Log  \nStep5: Add User Label To BSSID From Parameter Editor  console=true
    Wait Until Element Is Clicked  ${PARAMETER_EDITOR}
    Input Text  ${FILTER_XPATH}  BSSID-2
    Wait Until Element Is Clicked  //span[contains(@class, 'ot-highlight-text') and contains(text(), 'BSSID-2')]
    Input Text  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/thead/tr[2]/th[2]/div/input  Wi-Fi user list allowed
    Wait Until Element Is Clicked  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[1]/td[6]/p-button[1]/button/span[1]
    ${number_of_rows}  SeleniumLibrary.Get Element Count  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr
    FOR  ${row}  IN RANGE  1  ${number_of_rows}+1
        ${status_row}  Run Keyword And Return Status  Element Should Be Visible
        ...  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[${row}]/td[4]/cem-parameter-input/cem-string-input/ot-field/div/span/i
        IF  ${status_row}
            Input Text
            ...  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[${row}]/td[4]/cem-parameter-input/cem-string-input/ot-field/div/input
            ...  ${WIFI_USER_LABEL}
        END
    END
    Validate And Activate Plan


Step6: Connect Wi-Fi Client And Verify If Is Connected
    Log  \nStep6: Connect Wi-Fi Client And Verify If Is Connected  console=true
    ${connection}  Run Keyword And Return Status
    ...  ssh.Connect To  ${SERVER_IP}  ${SERVER_USERNAME}  ${SERVER_PASSWORD}  alias=vm
    IF  ${connection}  Log  Connection to SBTS via SSH was successfully performed!  console=true
    ssh.Execute  sudo nmcli device wifi rescan  connection=vm
    ${output}  ssh.Execute  sudo nmcli device wifi connect wifi2asof${BTS_ID} password "${WIFI_USER_PASSWORD}"  connection=vm  timeout=30s
    Should Contain  ${output}  successfully activated  msg=Command 'sudo nmcli device wifi connect...' wasn't sent with successfully!
    Log  Command 'sudo nmcli device wifi connect...' was sent with successfully!  console=true
    Log  Disconnecting from SBTS via SSH will be performed!  console=true
    ssh.Disconnect  connection=vm
    Open SSD Wi-Fi Configuration
    Wait Until Element Is Clicked  //*[contains(@class, 'p-tabview-title ng-star-inserted') and contains(text(), 'Connected Wi-Fi Clients')]
    Sleep  5s  Time for page to be updated
    Close Startup View If Visible
    ${connect_user_label}  Get Text  //blocks-wifi-clients/div/div/cem-block-panel/div/div[2]/div/p-table/div/div[1]/table/tbody/tr/td[1]
    ${mac_address}  Get Text  //blocks-wifi-clients/div/div/cem-block-panel/div/div[2]/div/p-table/div/div[1]/table/tbody/tr/td[2]
    ${ip_address}  Get Text  //blocks-wifi-clients/div/div/cem-block-panel/div/div[2]/div/p-table/div/div[1]/table/tbody/tr/td[3]
    ${connection_duration}  Get Text  //blocks-wifi-clients/div/div/cem-block-panel/div/div[2]/div/p-table/div/div[1]/table/tbody/tr/td[4]
    ${authentication_type}  Get Text  //blocks-wifi-clients/div/div/cem-block-panel/div/div[2]/div/p-table/div/div[1]/table/tbody/tr/td[5]
    ${message}  Catenate  SEPARATOR=${SPACE}  With following parameters: User Label:${connect_user_label}, MAC Address:${mac_address},
    ...  IP Address:${ip_address}, Connection Duration:${connection_duration}, Authentication Type:${authentication_type}
    IF  '${connect_user_label}'=='${WIFI_USER_LABEL}'
        Log  User label:${WIFI_USER_LABEL} is connect to Bts by Wi-Fi! ${message}  console=true
    ELSE
        Fail  User label:${WIFI_USER_LABEL} is not connect to Bts by Wi-Fi.[NOK]
    END


Step7: Terminate Connection Of Selected WiFi Client
    Log  \nStep7: Terminate Connection Of Selected WiFi Client  console=true
    Wait Until Element Is Clicked  //*[contains(@class, 'p-tabview-title ng-star-inserted') and contains(text(), 'SSD Wi-Fi Configuration')]
    Wait Until Element Is Clicked  //*[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'Read SSD')]
    Wait Until Element Is Visible  //span[contains(text(),'Success')]  30
    ${number_of_rows}  Get Element Count  //*[@id="configured-user-table"]/div/div[1]/table/tbody/tr
    FOR  ${row}  IN RANGE  1  ${number_of_rows}+1
        ${name_user}  Get Text  //*[@id="configured-user-table"]/div/div[1]/table/tbody/tr[${row}]/td[2]/div/input
        IF  '${name_user}'=='${WIFI_USER_LABEL}'
            Wait Until Element Is Clicked  //*[@id="configured-user-table"]/div/div[1]/table/tbody/tr[${row}]/td[7]/div/p-button[2]/button/span[1]
            Wait Until Element Is Clicked  //*[contains(text(),'Update')]
            Wait Until Element Is Visible  //*[contains(text(),'Update successfully')]  30
            Log  User is removed in 'User label'![OK]  console=true
        END
    END
    Wait Until Element Is Clicked  //*[contains(@class, 'p-tabview-title ng-star-inserted') and contains(text(), 'Connected Wi-Fi Clients')]
    ${disconnect_action_xpath}  Catenate  SEPARATOR=  //blocks-wifi-clients/div/div/cem-block-panel/div/div[2]/div/p-table/div/div[1]/table/tbody
    ...  /tr/td[6]/otx-operation-button/div/div/p-button/button/span[1]
    Wait Until Element Is Clicked  ${disconnect_action_xpath}
    Wait Until Element Is Visible  //*[contains(@class, 'ot-dialog-title ng-star-inserted')]  60
    ${text_header_disconnect}  Get Text  //*[contains(@class, 'ot-dialog-title ng-star-inserted')]
    Should Be Equal  '${text_header_disconnect}'  'Do you want to disconnect this Wi-Fi client connection?'
    ...  msg=Text to disconnect header not appeared.
    Log  ${text_header_disconnect} view appeared and will be press disconnect.  console=true
    Wait Until Element Is Clicked
    ...  //blocks-wifi-clients/div/div/cem-block-panel/div/div[2]/ot-dialog/p-dialog/div/div/div[3]/ot-footer/p-button[1]/button/span
    Wait Until Element Is Visible  //*[contains(@class, 'ot-text ng-star-inserted') and contains(text(), 'Success')]  30
    Log  \nConnection of the selected WiFi client is terminated.  console=true


Configuring BSSID objects
    @{users_name}  Get Dictionary Keys  ${USERS_DICTIONARY}
    FOR  ${index}  IN RANGE  1  4
        Wait Until Element Is Clicked  //div[contains(@class, 'p-element ot-text-ellipsis') and contains(text(), 'BSSID-${index}')]
        Input Text  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/thead/tr[2]/th[2]/div/input  Service set identifier name
        Input Text  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr/td[4]/cem-parameter-input/cem-string-input/ot-field/div/input
        ...  wifi${index}asof${BTS_ID}
        Input Text  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/thead/tr[2]/th[2]/div/input  Wi-Fi user list allowed
        Sleep  5s  Time for page to be updated
        ${index_user}  Evaluate  ${index}-1
        Input Text  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[2]/td[4]/cem-parameter-input/cem-string-input/ot-field/div/input
        ...  ${users_name}[${index_user}]
        Sleep  5s  Time for page to be updated
        Input Text  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/thead/tr[2]/th[2]/div/input  Authentication type
        Wait Until Element Is Clicked
        ...  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr/td[4]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
        Wait Until Element Is Clicked  //li[contains(@aria-label, "${USERS_DICTIONARY}[${users_name}[${index_user}]]")]
        Input Text  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/thead/tr[2]/th[2]/div/input  Hide SSID
        Sleep  5s  Time for page to be updated
        Wait Until Element Is Clicked
        ...  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr/td[4]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
        Wait Until Element Is Clicked  //li[contains(@aria-label, "false")]
        Wait Until Element Is Clicked  //*[@class="cdk-virtual-scroll-content-wrapper"]/ul/p-treenode[4]/li/div/span/span/div/div[1]/div/span
        IF  ${index} == 3
            BREAK
        ELSE
            Wait Until Element Is Clicked
            ...  //*[@class="cdk-virtual-scroll-content-wrapper"]/ul/p-treenode[4]/li/div/span/span/div/div[2]/p-button[1]/button/span[1]
        END
        Wait Until Element Is Clicked  //*[@id="className"]/div/span[1]
        Wait Until Element Is Clicked  //li[contains(@aria-label, "BSSID")]
        Wait Until Element Is Clicked  //*[@id="laf-component"]/div[2]/p-button[1]/button/span
    END
    Validate And Activate Plan


Validate And Activate Plan
    Wait Until Element Is Clicked  ${VALIDATE_PLAN_PE}  60
    Sleep  15s  Time for validate plan
    Mouse Over  ${PARAMETER_EDITOR}
    Wait Until Element Is Clicked  ${ACTIVATE_PLAN_PE}  60
    Wait Until Element Is Visible  //*[@id="laf-component"]/p-panel/div/div  300
    Wait Until Element Is Clicked  //span[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'Execute')]  120
    Wait Until Element Is Visible
    ...  //*[@id="laf-component"]/div/div/div[2]/blocks-activate-plan-progress-dialog/div[2]/div/ot-instruction/div/span  90
    Wait Until Element Is Clicked  //span[contains(@class, 'p-button-label ng-star-inserted') and contains(text(), 'Close')]  120
    Log  Plan is activated![OK]  console=true


TC Setup
    Common Test Setup  tc_name=WebEM__WiFi_management
    WebEM Setup


TC Teardown
    Load A Specific SCF  ${COMMISSIONING_PATH}  ${RECOVERY_TIMEOUT}
    WebEM Teardown
    Common Test Teardown
