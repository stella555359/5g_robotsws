*** Settings ***
Documentation
    ...  This TC is created to check allowed country codes.
    ...  1. SBTS is integrated to Netact.
    ...  2. Login to dmgr node using omc user of your Netact Lab.
    ...  3. Create/copy the xml file to modify the Country Code to any path or "/root"
    ...  4. Execute the commands to import and activate the country code to SSD.
    ...  5. Checks if country codes modify in WebEM
    ...  6. Check if the 'Wifi Configuration Issue' alarm appears when an invalid country code is selected in WebEM.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1800s  # Timeout for SBTS to recover
${PATH_SCF_WITH_PARAMETERS_CONFIGURATION}  #Mandatory! Path of SCF with parameters configuration. Should be exist in testline_configuration
${PATH_SCF_LIST_COUNTRY_CODES_MODIFICATION}  #Mandatory! Path of SCF with list country codes configuration. Should be exist in testline_configuration


*** Keywords ***
TC__WebEM__Country_Code_Modification_via_Netact
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29013
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 04.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29013 - Initial TAT creation
    ...  - 08.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29529 - Navigation Menu has changed with software larger than 25R3

    Set Tags  CA-WebEM  OWNER-nicolae-marcel.caragel@nokia.com  AUTHOR-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  SW-SBTS25  FEATURE-CNI-119323-C

    Step1: Check SBTS Is Integrated To Netact And Load SCF With Parameters Configuration
    Step2: Change Country Code In WebEM And Check Alarm
    Step3: Login To Dmgr Node Using Omc User Of Your Netact Lab And Copy The Xml File
    Step4: Execute Import And Activate Commands To Modify The Country Code
    Step5: Check Chosen Wifi Country Code In Wifi File And Check Alarm


Step1: Check SBTS Is Integrated To Netact And Load SCF With Parameters Configuration
    Log  \nStep1: Check SBTS Is Integrated To Netact And Load SCF With Parameters Configuration  console=true
    ${nms_status}  Run Keyword And Return Status
    ...  Element Should Be Visible  locator=//div[text()='NMS']
    IF  ${nms_status}
        Log  NMS is visible in Site View![OK]  console=true
    ELSE
        Fail  NMS isn't visible is Site View![NOK]
    END
    Wait Until Element Is Visible  locator=//*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[3]/div[2]/div/div[2]/div[2]  timeout=180
    ${nms_class}  SeleniumLibrary.Get Element Attribute  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[3]/div[2]/div/div[2]/div[2]  class
    ${netact_status}  Run Keyword And Return Status  Should Contain  ${nms_class}  green
    IF  ${netact_status}
        Log  SBTS is integrated to netact  console=true
    ELSE
        Integrate SBTS To NetAct
    END
    Should Not Be Empty  ${PATH_SCF_WITH_PARAMETERS_CONFIGURATION}
    ...  SCF name with parameters configuration must be specified, please provide it and retest.
    Should Not Be Empty  ${PATH_SCF_LIST_COUNTRY_CODES_MODIFICATION}
    ...  SCF name with list country codes configuration must be specified, please provide it and retest.
    Log  Loading SCF ${PATH_SCF_WITH_PARAMETERS_CONFIGURATION} will be performed...  console=true
    Load A Specific SCF  ${PATH_SCF_WITH_PARAMETERS_CONFIGURATION}
    Close Startup View If Visible
    ${initial_allowed_country_codes}  Get Allowed Country Code List
    Set Test Variable  ${INITIAL_ACC}  ${initial_allowed_country_codes}
    Log  At the start test allowed country codes: ${initial_allowed_country_codes}  console=true


Step2: Change Country Code In WebEM And Check Alarm
    Log  \nStep2: Change Country Code In WebEM And Check Alarm  console=true
    Change Country Code In Parameter Editor  NCC
    ${fault_61675_params}  Get String With Alarm Parameters  ${FAULT_61675}
    ${fault_status}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fault_61675_params}  timeout=200
    IF  ${fault_status}
        Log  Alarm with fault id 61675 - "Wifi Configuration Issue" - appeared![OK]  console=true
    ELSE
        Fail  Alarm with fault id 61675 - "Wifi Configuration Issue" - did not appear![NOK]
    END


Step3: Login To Dmgr Node Using Omc User Of Your Netact Lab And Copy The Xml File
    Log  \nStep3: Login To Dmgr Node Using Omc User Of Your Netact Lab And Copy The Xml File  console=true
    ${netact_info}  coam.Get Nms State
    ${manager_id}  Get Manager Id For NetAct  ${netact_info}
    ${WEB_URL}  ${netact_name}  Get Web Url And Netact Name  ${manager_id}
    Set Test Variable  ${WEB_URL}
    ${hostname}  Replace String Using Regexp  ${WEB_URL}  lbwas  node01
    OperatingSystem.Run  sshpass -p ${NETACT_PASSWORD} scp ${PATH_SCF_LIST_COUNTRY_CODES_MODIFICATION} omc@${hostname}:/home/omc


Step4: Execute Import And Activate Commands To Modify The Country Code
    Log  \nStep4: Execute Import And Activate Commands To Modify The Country Code  console=true
    Open Ssh Connection To NetAct  ${WEB_URL}
    ${import_sdd_command}  Catenate  SEPARATOR=${SPACE}  curl -k --data @${PATH_SCF_LIST_COUNTRY_CODES_MODIFICATION}
    ...  -H "Content-Type:application/vnd.nokia-sm-import-request-v1+xml" -X POST -u
    ...  'omc':'Medsql!_1893' https://${WEB_URL}/sm-operations/api/sm/operations/v1/execute/ssd-plan-import?overwrite=true
    ${activate_sdd_command}  Catenate  SEPARATOR=${SPACE}  curl -k -i --data '{"operationAttributes":{"scope":["${MRBTS_DN}"]}}'
    ...  -H "Content-Type:application/vnd.nokia-sm-provision-request-v1+json" -X POST -u
    ...  'omc':'Medsql!_1893' https://${WEB_URL}/sm-operations/api/sm/operations/v1/request/start/ne3s-ssd-ne-provision-raml2
    SSHLibrary.Write  ${import_sdd_command}
    SSHLibrary.Set Client Configuration  prompt=$
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ${activate_sdd_command}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close Connection
    ${string_allowed_country_codes}  Get Allowed Country Code List
    Set Test Variable  ${ALL_COUNTRY_CODES}  ${string_allowed_country_codes}
    IF  '${INITIAL_ACC}'!='${string_allowed_country_codes}'
        Log  All allowed country codes appear in WebEm.[OK]  console=true
    ELSE
        Fail  All allowed country codes not appear in WebEm.[NOK]
    END


Step5: Check Chosen Wifi Country Code In Wifi File And Check Alarm
    Log  \nStep5: Check Chosen Wifi Country Code In Wifi File And Check Alarm  console=true
    ${list_allowed_country_codes}  Split String  ${ALL_COUNTRY_CODES}  ,${SPACE}
    Change Country Code In Parameter Editor  ${list_allowed_country_codes}[-1]
    ${fault_61675_params}  Get String With Alarm Parameters  ${FAULT_61675}
    ${fault_status}  Run Keyword And Return Status  Assert Alarm Inactive  parameters=${fault_61675_params}  timeout=200
    IF  ${fault_status}
        Log  Alarm with fault id 61675, "Wifi Configuration Issue" is inactive![OK]  console=true
    ELSE
        Fail  Alarm with fault id 61675 "Wifi Configuration Issue" is not inactive![NOK]
    END
    ${chosenWifiCountryCode_match}  Get Chosen Wifi Country Code From Wifi File
    ${status}  Run Keyword And Return Status  Should Contain  ${chosenWifiCountryCode_match}  ${list_allowed_country_codes}[-1]
    IF  ${status}
        Log  'Chosen Wifi Country Code' is the same in decrypted_wifi.json file and WebEM![OK]  console=true
    ELSE
        Fail  'Chosen Wifi Country Code' is not the same in decrypted_wifi.json file and WebEM![NOK]
    END


Change Country Code In Parameter Editor
    [Arguments]  ${value}

    Wait Until Keyword Succeeds  90  10
    ...  Click Element  ${PARAMETER_EDITOR}
    ${filter_xpath}  Catenate  SEPARATOR=  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/div/blocks-navigation/ot-side-sheet/div/div[1]
    ...  /div/div[2]/p-tree/div/div/input
    Input Text  ${filter_xpath}  WLAN-1
    Wait Until Keyword Succeeds  20  10  Click Element  //span[contains(@class, 'ot-highlight-text') and contains(text(), 'WLAN-1')]
    Input Text  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/thead/tr[2]/th[2]/div/input  Chosen Wi-Fi country code
    Sleep  5s
    Wait Until Keyword Succeeds  20  10  Click Element
    ...  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr/td[4]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span
    Wait Until Keyword Succeeds  20  5  Click Element  //*[contains(@ng-reflect-text, "${value}")]
    Wait Until Keyword Succeeds  60  5  Click Element  //*[contains(@ng-reflect-text, "Validate Plan")]
    Sleep  15s  Time for validate plan
    Mouse Out  //*[contains(@ng-reflect-text, "Validate Plan")]
    Wait Until Keyword Succeeds  60  5  Click Element  //*[contains(@ng-reflect-text, "Activate Plan")]
    Wait Until Element Is Visible  //*[@id="laf-component"]/p-panel/div/div  300
    Wait Until Keyword Succeeds  120  3
    ...  Click Element  xpath=//*[contains(@ng-reflect-label, 'Execute')]
    Wait Until Element Is Visible
    ...  //*[@id="laf-component"]/div/div/div[2]/blocks-activate-plan-progress-dialog/div[2]/div/ot-instruction/div/span  300
    Wait Until Keyword Succeeds  120  3
    ...  Click Element  xpath=//*[contains(@ng-reflect-label, 'Close')]
    Log  Plan is activated![OK]  console=true
    Log  Country code is changed in ${value}  console=true


Get Allowed Country Code List
    Open/Close Menus Tab
    ${status}  Run Keyword And Return Status
        ...  Wait Until Element Is Visible  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'SSD Wi-Fi Configuration')]  20
    IF  ${status}
        Wait Until Keyword Succeeds  30  5  Click Element  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'SSD Wi-Fi Configuration')]
    ELSE
        Wait Until Keyword Succeeds  30  5  Click Element  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Security')]
        Wait Until Keyword Succeeds  30  5  Click Element  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Wi-Fi Management')]
        Wait Until Keyword Succeeds  30  5  Click Element  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'SSD Wi-Fi Configuration')]
    END
    Log  SSD Wi-Fi Configuration Tab is open!  console=true
    IF  '${ENB_BRANCH}' < 'SBTS25R3'  Open/Close Menus Tab
    Wait Until Keyword Succeeds  30  5
    ...  Click Element  xpath=//*[contains(@ng-reflect-label, 'Read SSD')]
    Wait Until Element Is Visible  //span[contains(text(),'Success')]  30
    ${allowed_country_codes}  Get Text  //*[@class="cem-block-panel-content"]/div[2]/form/ot-field/div/span
    Wait Until Keyword Succeeds  30  10
    ...  Go To Site View

    RETURN  ${allowed_country_codes}


Get Chosen Wifi Country Code From Wifi File
    Open Connection To Primary Core
    SSHLibrary.Set Client Configuration  prompt=>
    SSHLibrary.Write  telnet 0 15007
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  sicftp -p 0x1018 /safe/wifi.json /rom/decrypted_wifi.json
    ${output}  SSHLibrary.Read Until Prompt
    SSHLibrary.Write  quit
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  cat /ffs/run/decrypted_wifi.json
    ${output_file}  SSHLibrary.Read Until Prompt
    SSHLibrary.Close Connection
    ${chosenWifiCountryCode_match}  Get Lines Containing String  ${output_file}  chosenWifiCountryCode

    RETURN  ${chosenWifiCountryCode_match}


TC Setup
    Common Test Setup  tc_name=WebEM__Country_Code_Modification_via_Netact
    Setup NetAct
    WebEM Setup


TC Teardown
    Load A Specific SCF  ${COMMISSIONING_PATH}
    Teardown NetAct
    WebEM Teardown
    Common Test Teardown
