*** Settings ***
Documentation  *AUTHOR*: andreea.burtic@nokia.com
...  This resource is used for WebEM TCs with mobile view that contain common KWs, both from old GUI and from the new GUI.

Library  SeleniumLibrary  run_on_failure=Nothing
Resource  ca_SBTS_general.robot
Resource  ca_WebEM_${GUI_VERSION}_GUI_mobile.robot


*** Variables ***
${MOBILE_BROWSER}  Chrome  # This variable is set as default on Chrome which means opening the Chrome browser. It can also be set as Firefox.
${GUI_VERSION}  new  # GUI version can be old or new. The new GUI is for software releases newer or equal to SBTS25R1.
${VIRTUAL_DISPLAY}  True  #Activate with True or deactivate with False headless running.


*** Keywords ***
WebEM Teardown Via Mobile
    [Documentation]  This keyword is used to set WebEM teardown via mobile.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Run Keyword If Test Failed
    ...  Capture Page Screenshot  Snapshot_after_test_failed.png
    Run Keyword And Ignore Error
    ...  Download Application Logs Via Mobile
    Close Browser


WebEM Setup Via Mobile
    [Documentation]  This keyword is used to set WebEM setup via mobile.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Set Screenshot Directory  ${BTS_FILES}/selenium_screenshot_${TEST_NAME}
    Open WebEM Via Mobile
    Get Xpath For All Cells Via Mobile
    Get Xpaths For BBMODs Via Mobile
    Get Xpaths For RMODs Via Mobile


Open WebEM Via Mobile
    [Documentation]  This keyword is used to open WebEM via mobile.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Start Web Element Manager On Mobile
    Login SBTS Via Mobile
    Legal Notice Via Mobile


Start Web Element Manager On Mobile
    [Documentation]  This keyword starts Web Element Manager on Mobile view depending on the chosen browser.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Set Selenium Implicit Wait  15
    Run Keyword If  '${MOBILE_BROWSER}'=='Chrome'
    ...  Specifying A Known Mobile Device With Chrome
    ...  ELSE
    ...  Specifying A Known Mobile Device With Firefox


Specifying A Known Mobile Device With Firefox
    [Documentation]  This keyword open the browser in mobile view with Firefox.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${user_agent}  Catenate  SEPARATOR=  "Mozilla/5.0 (Linux; Android 4.2.1; en-us; Nexus 5 Build/JOP40D)" \ "AppleWebKit/535.19 (KHT
    ...  ML, like Gecko) Chrome/18.0.1025.166 Mobile Safari/535.19"
    ${firefox_options}  Evaluate  sys.modules['selenium.webdriver'].FirefoxOptions()  sys, selenium.webdriver
    Call Method  ${firefox_options}  set_preference  general.useragent.override  ${user_agent}
    Call Method  ${firefox_options}  add_argument  --ignore-ssl-errors
    Call Method  ${firefox_options}  add_argument  --ignore-certificate-errors
    Call Method  ${firefox_options}  add_argument  --disable-popup-blocking
    IF  ${VIRTUAL_DISPLAY}  Call Method  ${firefox_options}  add_argument  --headless
    Create Webdriver  Firefox  options=${firefox_options}
    Set Window Size  900  700
    Go To  https://${OAM_BTS_IP}


Specifying A Known Mobile Device With Chrome
    [Documentation]  This keyword open the browser in mobile view with Chrome.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${user_agent}  Catenate  SEPARATOR=  "Mozilla/5.0 (Linux; Android 4.2.1; en-us; Nexus 5 Build/JOP40D)" \ "AppleWebKit/535.19 (KHT
    ...  ML, like Gecko) Chrome/18.0.1025.166 Mobile Safari/535.19"
    ${visual}  Create Dictionary  width=${1920}  height=${1100}  pixelRatio=${4.0}
    ${mobile_emulation}  Create Dictionary  userAgent=${user_agent}  deviceMetrics=${visual}
    ${prefs}  Create Dictionary  download.default_directory=${DOWNLOADS_PATH}  plugins.plugins_disabled=${DISABLED}
    ${chrome_options}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    Call Method  ${chrome_options}  add_experimental_option  mobileEmulation  ${mobile_emulation}
    Call Method  ${chrome_options}  add_experimental_option  prefs  ${prefs}
    Call Method  ${chrome_options}  add_argument  --ignore-ssl-errors
    Call Method  ${chrome_options}  add_argument  --ignore-certificate-errors
    Call Method  ${chrome_options}  add_argument  --disable-popup-blocking
    IF  ${VIRTUAL_DISPLAY}  Call Method  ${chrome_options}  add_argument  --headless
    Create Webdriver  Chrome  options=${chrome_options}
    Go To  https://${OAM_BTS_IP}
    Maximize Browser Window


Get Xpath For All Cells Via Mobile
    [Documentation]  This keyword is used to get xpath for all cells via Mobile.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Get Xpath List For Cells Via Mobile  NR
    Get Xpath List For Cells Via Mobile  LTE
    Get Xpath List For Cells Via Mobile  WCDMA
    Get Xpath List For Cells Via Mobile  GSM


Get Xpath List For Cells Via Mobile
    [Documentation]  This keyword gets the xpath list for the given technology.
    ...  Technology must be given as argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${cell_technology}

    ${technology}  Convert To Lower Case  ${cell_technology}
    ${grid_size}  Get Radio Section Grid Size Via Mobile
    ${grid_block_xpath}  Create List
    FOR  ${elements}  IN RANGE  1  ${grid_size}+1
        ${class_element}  SeleniumLibrary.Get Element Attribute  //*[@id="simplifiedSiteContainer"]/div/div/div/div[3]/div[${elements}]  class
        Run Keyword If  '${class_element}'=='cell-${technology}-grid-element'
        ...  Append To List  ${grid_block_xpath}  //*[@id="simplifiedSiteContainer"]/div/div/div/div[3]/div[${elements}]
    END
    ${cells_xpath}  Create List
    FOR  ${elements}  IN  @{grid_block_xpath}
        ${status}  Run Keyword And Return Status
        ...  SeleniumLibrary.Get Element Attribute  ${elements}/div[2]/div/div/div/div/div[2]/div  title
        ${cell_id}  Run Keyword If  ${status}
        ...  Append To List  ${cells_xpath}  ${elements}/div[2]
    END
    ${xpath_cells}  Create List
    FOR  ${xpath}  IN  @{cells_xpath}
        ${cells_on_block_list}  Check If Multi Cell On Block Via Mobile  ${xpath}
        Append To List  ${xpath_cells}  @{cells_on_block_list}
    END
    Set Test Variable  ${${cell_technology}_cells_xpath}  ${xpath_cells}

    [Return]  ${xpath_cells}


Get Radio Section Grid Size Via Mobile
    [Documentation]  This keyword is used to get radio section grid size via Mobile.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${rmod_header}  SeleniumLibrary.Get Element Count  class:rmod-header
    ${cells_header}  SeleniumLibrary.Get Element Count  class:cell-header
    ${rmod_grid}  SeleniumLibrary.Get Element Count  class:rmod-grid-element
    ${port_grid}  SeleniumLibrary.Get Element Count  class:port-grid-element
    ${lte_cells}  SeleniumLibrary.Get Element Count  class:cell-lte-grid-element
    ${wcdma_cells}  SeleniumLibrary.Get Element Count  class:cell-wcdma-grid-element
    ${gsm_cells}  SeleniumLibrary.Get Element Count  class:cell-gsm-grid-element
    ${nr_cells}  SeleniumLibrary.Get Element Count  class:cell-nr-grid-element
    ${empty_row}  SeleniumLibrary.Get Element Count  class:empty-row
    ${grid}  Evaluate  ${rmod_header}+${cells_header}+${rmod_grid}+${port_grid}+${lte_cells}+${wcdma_cells}+${gsm_cells}+${nr_cells}+${empty_row}

    [Return]  ${grid}


Get Xpaths For RMODs Via Mobile
    [Documentation]  This keyword gets the xpath list for all rmods.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${grid_size}  Get Radio Section Grid Size Via Mobile
    ${rmods_xpath}  Create List
    FOR  ${elements}  IN RANGE  1  ${grid_size}
        ${rmod}  SeleniumLibrary.Get Element Attribute  //*[@id="simplifiedSiteContainer"]/div/div/div/div[3]/div[${elements}]  class
        Run Keyword If  '${rmod}'=='rmod-grid-element'
        ...  Append To List  ${rmods_xpath}  //*[@id="simplifiedSiteContainer"]/div/div/div/div[3]/div[${elements}]
    END
    Set Test Variable  ${RMODS_XPATH}


Get Xpaths For BBMODs Via Mobile
    [Documentation]  This keyword gets the xpath list for all bbmods.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${bbmod_grid_size}  SeleniumLibrary.Get Element Count  class:inside-cabinet-block
    ${bbmods_xpath}  Create List
    FOR  ${elements}  IN RANGE  1  ${bbmod_grid_size}
        ${bbmod}  SeleniumLibrary.Get Element Attribute  //*[@id="simplifiedSiteContainer"]/div/div/div/div[2]/div/div/div[3]/div[${elements}]  class
        Run Keyword If  '${bbmod}'=='subcabinet-block long-press-support default-subcabinet-block inside-cabinet-block'
        ...  Append To List  ${bbmods_xpath}  //*[@id="simplifiedSiteContainer"]/div/div/div/div[2]/div/div/div[3]/div[${elements}]
    END
    Set Test Variable  ${BBMODS_XPATH}


Check If Multi Cell On Block Via Mobile
    [Documentation]  This keyword is used to check if multi cell on block via Mobile.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${multi_cell_xpath}

    ${number_cells}  Create List
    FOR  ${id}  IN RANGE  1  5
        ${path}  Run Keyword If  ${id}==1
        ...  Set Variable  div/div/div/div[3]/div
        ...  ELSE
        ...  Set Variable  div/div/div/div/div
        ${status}  Run Keyword And Return Status
        ...  SeleniumLibrary.Get Element Attribute  ${multi_cell_xpath}/div[${id}]  title
        Run Keyword If  ${status}
        ...  Append To List  ${number_cells}  ${multi_cell_xpath}/div[${id}]
        ...  ELSE IF  ${id}==1 and ${status}==${FALSE}
        ...  Run Keywords
        ...  Append To List  ${number_cells}  ${multi_cell_xpath}
        ...  AND
        ...  Exit For Loop
        ...  ELSE
        ...  Exit For Loop
    END

    [Return]  ${number_cells}


RAT Block Via Mobile
    [Documentation]  This keyword is pressing the block button for the specific technology.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    Sleep  15s  Time for page to be updated
    Log  \n${rat} RAT Block will be performed.  console=true
    Wait Until Element Is Visible  //*[contains(@ng-class,'$ctrl.dropdownButtonClassStr')]  120
    Wait Until Element Is Clicked For Mobile  //*[contains(@ng-class,'$ctrl.dropdownButtonClassStr')]  60
    ${text_button_block}  Get Text  //*[contains(text(), 'Block')][contains(text(), '${rat}')]
    ${status}  Run Keyword And Return Status
    ...  Should Match Regexp  ${text_button_block}  ${rat} Block|Block ${rat}
    Run Keyword If  ${status}
    ...  Log  ${rat} RAT Block/Unblock button is visible as ${text_button_block}![OK]  console=true
    ...  ELSE
    ...  Log  ${text_button_block} button is not ok![NOK] level=ERROR  console=true
    Log  ${rat} RAT Block is ongoing.  console=true
    Click Element  //*[contains(text(), 'Block')][contains(text(), '${rat}')]
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button


RAT Block Confirmation Canceled Via Mobile
    [Documentation]  This keyword is pressing the block button for the specific technology but canceled the confirmation.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    Sleep  15s  Time for page to be updated
    Log  \n${rat} RAT Block will be performed.  console=true
    ${status}  Run Keyword And Return Status
    ...  Element Should Be Visible
    ...  /html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button/button
    Run Keyword If  ${status}
    ...  Wait Until Element Is Clicked For Mobile
    ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button/button
    ...  60
    Wait Until Element Is Visible  //*[contains(@ng-class,'$ctrl.dropdownButtonClassStr')]  120
    Wait Until Element Is Clicked For Mobile  //*[contains(@ng-class,'$ctrl.dropdownButtonClassStr')]  60
    ${text_button_block}  Get Text  //*[contains(text(), 'Block')][contains(text(), '${rat}')]
    ${status}  Run Keyword And Return Status
    ...  Should Match Regexp  ${text_button_block}  ${rat} Block|Block ${rat}
    Run Keyword If  ${status}
    ...  Log  ${rat} RAT Block/Unblock button is visible as ${text_button_block}![OK]  console=true
    ...  ELSE
    ...  Log  ${text_button_block} button is not ok![NOK] level=ERROR  console=true
    Click Element  //*[contains(text(), 'Block')][contains(text(), '${rat}')]
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[2]/button
    Log  Operation is cancelled!  console=true


RAT Unblock Via Mobile
    [Documentation]  This keyword is pressing the unblock button for the specific technology.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    Sleep  15s  Time for page to be updated
    Log  \n${rat} RAT Unblock will be performed.  console=true
    Wait Until Element Is Visible  //*[contains(@ng-class,'$ctrl.dropdownButtonClassStr')]  120
    Wait Until Element Is Clicked For Mobile  //*[contains(@ng-class,'$ctrl.dropdownButtonClassStr')]  60
    ${text_button_unblock}  Get Text  //*[contains(text(), 'Unblock')][contains(text(), '${rat}')]
    ${status}  Run Keyword And Return Status
    ...  Should Match Regexp  ${text_button_unblock}  ${rat} Unblock|Unblock ${rat}
    Run Keyword If  ${status}
    ...  Log  ${rat} RAT Block/Unblock button is visible as ${text_button_unblock}![OK]  console=true
    ...  ELSE
    ...  Log  ${text_button_unblock} button is not ok![NOK] level=ERROR  console=true
    Log  ${rat} RAT Unblock is ongoing.  console=true
    Click Element  //*[contains(text(), 'Unblock')][contains(text(), '${rat}')]
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button


RAT Unblock Confirmation Canceled Via Mobile
    [Documentation]  This keyword is pressing the unblock button for the specific technology but canceled the confirmation.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    Sleep  15s  Time for page to be updated
    Log  \n${rat} RAT Unblock will be performed.  console=true
    Wait Until Element Is Visible  //*[contains(@ng-class,'$ctrl.dropdownButtonClassStr')]  120
    Wait Until Element Is Clicked For Mobile  //*[contains(@ng-class,'$ctrl.dropdownButtonClassStr')]  60
    ${text_button_unblock}  Get Text  //*[contains(text(), 'Unblock')][contains(text(), '${rat}')]
    ${status}  Run Keyword And Return Status
    ...  Should Match Regexp  ${text_button_unblock}  ${rat} Unblock|Unblock ${rat}
    Run Keyword If  ${status}
    ...  Log  ${rat} RAT Block/Unblock button is visible as ${text_button_unblock}![OK]  console=true
    ...  ELSE
    ...  Log  ${text_button_unblock} button is not ok![NOK] level=ERROR  console=true
    Click Element  //*[contains(text(), 'Unblock')][contains(text(), '${rat}')]
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[2]/button
    Log  Operation is cancelled!  console=true


Verify If ${rat} RAT Button Is ${state}
    [Documentation]  This keyword verify if RAT button is in expected state.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  The state must be given as an argument. Example: Block, Unblock.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Sleep  15s  Time for page to be updated
    Wait Until Element Is Visible  //*[contains(@ng-class,'$ctrl.dropdownButtonClassStr')]  120
    Click Element  //*[contains(@ng-class,'$ctrl.dropdownButtonClassStr')]
    ${text_button}  Get Text  //*[contains(text(), '${state}')][contains(text(), '${rat}')]
    ${status}  Run Keyword And Return Status
    ...  Should Match Regexp  ${text_button}  ${rat} ${state}|${state} ${rat}
    Run Keyword If  ${status}
    ...  Log  ${rat} RAT Block/Unblock button is visible now as ${rat} ${state} button![OK]  console=true
    ...  ELSE
    ...  Log  ${rat} RAT Block/Unblock button is not ${rat} ${state}![NOK]  console=true
    Click Element  //*[contains(@ng-class,'$ctrl.dropdownButtonClassStr')]


Reset SBTS From Admin Via Mobile
    [Documentation]  This keyword is pressing the Reset Site button and the reset starts.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Reset Site will be performed.  console=true
    Wait Until Element Is Clicked For Mobile  //*[contains(@a-text, "Reset Site")]  120
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
    Log  Reset site is ongoing!  console=true
    Sleep  30  Time for page to be updated
    Log  Wait until NMS is visible on WebEM  console=true
    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div/div[2]/div[3]/div[2]  600
    Close BTS Start-up View Via Mobile
    Log  Reset site was performed!  console=true


Reset SBTS From Admin Via Mobile Confirmation Canceled
    [Documentation]  This keyword is pressing the Reset Site button but confirmation is canceled.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Reset Site will be performed.  console=true
    Wait Until Element Is Clicked For Mobile  //*[contains(@a-text, "Reset Site")]  120
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[2]/button
    Log  Operation is cancelled!  console=true


Site Block Via Mobile
    [Documentation]  This keyword is pressing the Site Block button and after that is verify if Site Block button is disabled.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked For Mobile  //*[contains(@a-text, "Block Site")]  120
    ${site_status}  Get Text  xpath:/html/body/div[1]/div/div/ui-modal-renderer/site-block-modal/ui-modal/div/div/div[3]/div/ui-footer/ui-button[1]
    ${status}  Run Keyword And Return Status
    ...  Should Match Regexp  ${site_status}  Block Site|Block
    Run Keyword If  ${status}
    ...  Run Keywords
    ...  Log  ${site_status} button is visible and Site Block will be performed![OK]  console=true
    ...  AND
    ...  Click Element  xpath:/html/body/div[1]/div/div/ui-modal-renderer/site-block-modal/ui-modal/div/div/div[3]/div/ui-footer/ui-button[1]/button
    ...  AND
    ...  Sleep  5s  Time for page to be updated
    ...  AND
    ...  Verify If Site Block Button Is Disabled
    ...  ELSE
    ...  Fail  ${site_status} button isn't in expected state![NOK]  console=true


Site Unblock Via Mobile
    [Documentation]  This keyword is pressing the Site Unblock button and after that is verify if Site Unblock button is disabled.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Enabled  //*[contains(@a-text, "Unblock Site")]  300
    Wait Until Element Is Clicked For Mobile  //*[contains(@a-text, "Unblock Site")]  120
    ${site_status}  Get Text  xpath:/html/body/div[1]/div/div/ui-modal-renderer/site-unblock-modal/ui-modal/div/div/div[3]/div/ui-footer/ui-button[1]
    ${status}  Run Keyword And Return Status
    ...  Should Match Regexp  ${site_status}  Unblock Site|Unblock
    ${ui_modal}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/ui-modal-renderer/site-unblock-modal/ui-modal
    ...  /div/div/div[3]/div/ui-footer/ui-button[1]/button
    Run Keyword If  ${status}
    ...  Run Keywords
    ...  Log  ${site_status} button is visible and Site Unblock will be performed![OK]  console=true
    ...  AND
    ...  Click Element  ${ui_modal}
    ...  AND
    ...  Sleep  5s  Time for page to be updated
    ...  AND
    ...  Verify If Site Unblock Button Is Disabled
    ...  AND
    ...  Close BTS Start-up View Via Mobile
    ...  ELSE
    ...  Fail  ${site_status} button isn't in expected state![NOK]  console=true


Verify If Site ${state} Button Is Disabled
    [Documentation]  This keyword verify if Site block/Unblock button is disabled.
    ...  The state must be given as an argument. Example: Block, Unblock.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Verify if Site ${state} button is disabled:  console=true
    ${status}  Run Keyword And Return Status  Element Should Be Disabled  //*[contains(@a-text, "Block Site")]
    Run Keyword If  ${status}
    ...  Log  Site ${state} button is disabled![OK]  console=true
    ...  ELSE
    ...  Log  Site ${state} button is enabled![NOK]  console=true


Block Cells Via Mobile
    [Documentation]  This keyword is pressing the cells block button for the specific technology.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    FOR  ${element}  IN  @{${rat}_CELLS_XPATH}
        Wait Until Element Is Clicked For Mobile  ${element}  180
        Wait Until Element Is Clicked For Mobile  ${element}/div/div/div/div[1]  180
        ${status}  Run Keyword And Return Status
        ...  Element Should Be Visible  ${element}/div/div/div/div[1]/span/div/div[1]/button
        Run Keyword If  not ${status}
        ...  Click Action Points And Check If Button Is Visible  ${element}
        ${text_button_block}  Get Text  ${element}/div/div/div/div[1]/span/div/div[1]/button
        ${status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${text_button_block}  Cell Block|Block Cell
        Run Keyword If  ${status}
        ...  Wait Until Element Is Clicked For Mobile  ${element}/div/div/div/div[1]/span/div/div/button  120
        ...  ELSE
        ...  Wait Until Element Is Clicked For Mobile  ${element}/div/div/div/div[1]/span/div/div[2]/button  120
        Log  ${rat} Cell Block is ongoing.  console=true
        Wait Until Element Is Clicked For Mobile
        ...  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button  180
        Sleep  10s  Wait for notifications to disappear
    END


Block Cells Confirmation Canceled Via Mobile
    [Documentation]  This keyword is pressing the cells block button for the specific technology but canceled the confirmation.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    FOR  ${element}  IN  @{${rat}_CELLS_XPATH}
        Wait Until Element Is Clicked For Mobile  ${element}  120
        Wait Until Element Is Clicked For Mobile  ${element}/div/div/div/div[1]  120
        ${text_button_block}  Get Text  ${element}/div/div/div/div[1]/span/div/div/button
        ${status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${text_button_block}  Cell Block|Block Cell
        Run Keyword If  ${status}
        ...  Wait Until Element Is Clicked For Mobile  ${element}/div/div/div/div[1]/span/div/div/button  120
        ...  ELSE
        ...  Wait Until Element Is Clicked For Mobile  retry_timeout=120  xpath=${element}/div/div/div/div[1]/span/div/div[2]/button
        Log  ${rat} Cell Block is ongoing.  console=true
        Wait Until Element Is Clicked For Mobile
        ...  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[2]/button  120
        Log  Operation is cancelled!  console=true
    END


Unblock Cells Via Mobile
    [Documentation]  This keyword is pressing the cells unblock button for the specific technology.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    FOR  ${element}  IN  @{${rat}_CELLS_XPATH}
        Wait Until Element Is Visible  ${element}  60
        Wait Until Element Is Clicked For Mobile  ${element}  120
        Wait Until Element Is Clicked For Mobile  ${element}/div/div/div/div[1]  120
        Wait Until Element Is Visible  ${element}/div/div/div/div[1]/span/div/div/button  120
        ${text_button_unblock}  Get Text  ${element}/div/div/div/div[1]/span/div/div/button
        ${status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${text_button_unblock}  Cell Unblock|Unblock Cell
        Run Keyword If  ${status}
        ...  Wait Until Element Is Clicked For Mobile  ${element}/div/div/div/div[1]/span/div/div/button  120
        ...  ELSE
        ...  Wait Until Element Is Clicked For Mobile  ${element}/div/div/div/div[1]/span/div/div[2]/button  120
        Log  ${rat} Cell Unblock is ongoing.  console=true
        Wait Until Element Is Clicked For Mobile
        ...  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button  120
        Sleep  10s  Wait for notifications to disappear
    END


Unblock Cells Confirmation Canceled Via Mobile
    [Documentation]  This keyword is pressing the cells block button for the specific technology but canceled the confirmation.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    FOR  ${element}  IN  @{${rat}_CELLS_XPATH}
        Wait Until Element Is Clicked For Mobile  ${element}  120
        Wait Until Element Is Clicked For Mobile  ${element}/div/div/div/div[1]  120
        ${text_button_unblock}  Get Text  ${element}/div/div/div/div[1]/span/div/div/button
        ${status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${text_button_unblock}  Cell Unblock|Unblock Cell
        Run Keyword If  ${status}
        ...  Wait Until Element Is Clicked For Mobile  ${element}/div/div/div/div[1]/span/div/div/button  120
        ...  ELSE
        ...  Wait Until Element Is Clicked For Mobile  ${element}/div/div/div/div[1]/span/div/div[2]/button  120
        Log  ${rat} Cell Unblock is ongoing.  console=true
        Wait Until Element Is Clicked For Mobile
        ...  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[2]/button  120
        Log  Operation is cancelled!  console=true
    END


Verify If ${rat} Cell Button Is ${state}
    [Documentation]  This keyword verify if RAT cell button is in expected state.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  The state must be given as an argument. Example: Block, Unblock.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Sleep  15s  Time for page to be updated
    FOR  ${element}  IN  @{${rat}_CELLS_XPATH}
        Wait Until Element Is Visible  ${element}  60
        Wait Until Element Is Clicked For Mobile  ${element}  120
        Wait Until Element Is Clicked For Mobile  ${element}/div/div/div/div[1]  120
        ${status}  Run Keyword And Return Status
        ...  Element Should Be Visible  ${element}/div/div/div/div[1]/span/div/div[1]/button
        Run Keyword If  ${status}
        ...  Click Action Points And Check If Button Is Visible  ${element}
        ${text_button}  Get Text  ${element}/div/div/div/div[1]/span/div/div[1]/button
        ${status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${text_button}  Cell ${state}|${state} Cell
        Run Keyword If  ${status}
        ...  Run Keywords
        ...  Log  ${rat} Cell Block/Unblock button is visible now as Cell ${state} button![OK]  console=true
        ...  AND
        ...  Wait Until Element Is Clicked For Mobile  ${element}/div/div/div/div[1]  120
        ...  AND
        ...  Return From Keyword
        ${second_text_button}  Get Text  ${element}/div/div/div/div[1]/span/div/div[2]/button
        ${status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${second_text_button}  Cell ${state}|${state} Cell
        Run Keyword If  ${status}
        ...  Log  ${rat} Cell Block/Unblock button is visible now as Cell ${state} button![OK]  console=true
        ...  ELSE
        ...  Log  ${rat} Cell Block/Unblock button is not Cell ${state}![NOK]  console=true
        Wait Until Element Is Clicked For Mobile  ${element}/div/div/div/div[1]  120
    END


Click Action Points And Check If Button Is Visible
    [Documentation]  This keyword is pressing the 3 action points button for the {RAT} cell selected and checks if the Block/Unblock
    ...  cell is visible on the page.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${element}

    Wait Until Element Is Clicked For Mobile  ${element}  180
    Wait Until Element Is Clicked For Mobile  ${element}/div/div/div/div[1]  180
    Wait Until Element Is Visible  ${element}/div/div/div/div[1]/span/div/div[1]/button  120


RMODs Reset Via Mobile
    [Documentation]  This keyword is pressing the Reset button for all rmods and verify rmods state.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    FOR  ${xpath}  IN  @{RMODS_XPATH}
        Click Element  ${xpath}
        ${rmod_name}  Get Text  ${xpath}/div/div[3]/div[2]/div[1]
        ${rmod_number}  Get Text  ${xpath}/div/div[3]/div[2]/div[2]
        Log  \nReset for ${rmod_number}: ${rmod_name} will be performed!  console=true
        Click Element  ${xpath}/div/div[3]/div[1]
        ${text_button_reset}  Get Text  ${xpath}/div/div[3]/div[1]/span/div/div[1]/button
        Run Keyword If  '${text_button_reset}'=='Reset'
        ...  Log  ${rmod_number}: ${rmod_name} Reset button is visible![OK]  console=true
        ...  ELSE
        ...  Log  ${rmod_number}: ${rmod_name} Reset button is not visible![NOK]  console=true
        ${status}  Run Keyword And Return Status
        ...  Element Should Be Disabled  ${xpath}/div/div[3]/div[1]/span/div/div[2]/button
        Run Keyword If  ${status}
        ...  Log  ${rmod_number}: ${rmod_name} Remove button is disabled![OK]  console=true
        ...  ELSE
        ...  Log  ${rmod_number}: ${rmod_name} Remove button is enabled![NOK]  console=true
        Click Element  ${xpath}/div/div[3]/div[1]/span/div/div[1]/button
        Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
        Wait Until Keyword Succeeds  300  10
        ...  Check RMOD State Via Mobile  ${xpath}  Not installed
        Log  ${rmod_number}: ${rmod_name} is Not installed!  console=true
        Wait Until Keyword Succeeds  600  10
        ...  Check RMOD State Via Mobile  ${xpath}  Online|Enabled
        Log  ${rmod_number}: ${rmod_name} is Online!  console=true
        Click Element  ${xpath}/div/div[3]/div[1]
        ${status}  Run Keyword And Return Status
        ...  Element Should Be Enabled  ${xpath}/div/div[3]/div[1]/span/div/div[1]/button
        Run Keyword If  ${status}
        ...  Run Keywords
        ...  Log  ${rmod_number}: ${rmod_name} was successfully reset!  console=true
        ...  AND
        ...  Click Element  ${xpath}/div/div[3]/div[1]
    END


Check RMOD State Via Mobile
    [Documentation]  This keyword is used to check RMOD state via Mobile.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${xpath}  ${state}

    ${title_element}  SeleniumLibrary.Get Element Attribute  ${xpath}/div/div[3]/div[3]/div  title
    Should Match Regexp  ${title_element}  ${state}


RMODs Reset Confirmation Canceled Via Mobile
    [Documentation]  This keyword is pressing the Reset button for all RMODs but canceled the confirmation.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    FOR  ${element}  IN  @{RMODS_XPATH}
        Click Element  ${element}
        ${rmod_name}  Get Text  ${element}/div/div[3]/div[2]/div[1]
        ${rmod_number}  Get Text  ${element}/div/div[3]/div[2]/div[2]
        Log  \nReset for ${rmod_number}: ${rmod_name} will be performed!  console=true
        Click Element  ${element}/div/div[3]/div[1]
        Click Element  ${element}/div/div[3]/div[1]/span/div/div[1]/button
        Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[2]/button
        Log  Operation for ${rmod_number}: ${rmod_name} is cancelled!  console=true
    END


Verify If ${rat} Reset Button Is Disabled
    [Documentation]  This keyword verify if RAT button is disabled.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Verify if ${rat} Reset button is disabled:  console=true
    Wait Until Element Is Visible  //*[contains(@a-title, "Resetting ongoing")]  90
    Log  ${rat} Reset button is disabled![OK]  console=true


BBMODs Reset Via Mobile
    [Documentation]  This keyword is pressing the Reset button for all BBMODs and verify BBMODs state.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${abia_bbmod_with_lte}  Get ABIA BBMOD List With LTE Mapped On It
    FOR  ${xpath}  IN  @{BBMODS_XPATH}
        Click Element  ${xpath}
        ${bbmod_name}  Get Text  ${xpath}/div/div[2]/div[1]
        ${bbmod_number}  Get Text  ${xpath}/div/div[2]/div[2]
        Log  \nReset for ${bbmod_number}: ${bbmod_name} will be performed!  console=true
        Click Element  ${xpath}/div/div[1]
        ${bbmod_id_webem}  Fetch From Right  ${bbmod_number}  -
        ${bbmod_id}  Set Variable  BBMOD_R-${bbmod_id_webem}
        ${status_abia}  Run Keyword And Return Status  List Should Contain Value  ${abia_bbmod_with_lte}  ${bbmod_id}
        IF  '${bbmod_name}'=='ABIA' and '${ENB_BRANCH}'>='SBTS25R2' and ${status_abia}==${FALSE}
            Try To Reset ABIA BBMOD Without LTE Mapped On It Via Mobile  ${xpath}  ${bbmod_number}
            CONTINUE
        END
        ${status_remove}  Run Keyword And Return Status  Element Should Be Disabled  ${xpath}/div/div[1]/span/div/div[2]/button
        IF  ${status_remove}
            Log  ${bbmod_number}: ${bbmod_name} Remove button is visible and disabled![OK]  console=true
        ELSE
            Log  ${bbmod_number}: ${bbmod_name} Remove button is visible and enabled![NOK]  console=true
        END
        ${status_reset}  Run Keyword And Return Status  Element Should Be Enabled  ${xpath}/div/div[1]/span/div/div[1]/button
        IF  ${status_reset}
            Reset BBMOD  ${bbmod_number}  ${bbmod_name}  ${xpath}
        ELSE
            Click Element  ${xpath}/div/div[1]
            Log  ${bbmod_number}: ${bbmod_name} Reset button is disabled because it doesn't support 5G![OK]  console=true
        END
    END


Try To Reset ABIA BBMOD Without LTE Mapped On It Via Mobile
    [Documentation]  This keyword is used to try to reset ABIA BBMOD
    ...  which does not have LTE mapped on it.
    [Arguments]  ${xpath}  ${bbmod_number}

    Log  Try to reset ABIA BBMOD without LTE mapped on it and verify fail message...  console=true
    Click Element  ${xpath}/div/div[1]/span/div/div[1]/button
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
    Wait Until Page Contains  Reset ${bbmod_number} operation failed  timeout=60  error=Fail message didn't appear in WebEM. [NOK]
    Log  Fail operation appeared on page. [OK]  console=true


Reset BBMOD
    [Documentation]  This keyword is used to reset BBMOD.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${bbmod_number}  ${bbmod_name}  ${xpath}

    Log  ${bbmod_number}: ${bbmod_name} Reset button is enabled because it supports 5G![OK]  console=true
    Click Element  ${xpath}/div/div[1]/span/div/div[1]/button
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
    Log  ${bbmod_number}: ${bbmod_name} Reset is ongoing!  console=true
    Wait Until Keyword Succeeds  600  3
    ...  Check BBMOD State Via Mobile  ${xpath}  Offline
    Log  ${bbmod_number}: ${bbmod_name} is Offline!  console=true
    Wait Until Keyword Succeeds  600  3
    ...  Check BBMOD State Via Mobile  ${xpath}  Enabled|Online
    Log  ${bbmod_number}: ${bbmod_name} is Online!  console=true
    Click Element  ${xpath}/div/div[1]
    Sleep  5s  Time for page to be updated
    Wait Until Element Is Enabled  ${xpath}/div/div[1]/span/div/div[1]/button  1200
    Click Element  ${xpath}/div/div[1]
    Log  ${bbmod_number}: ${bbmod_name} was successfully reset!  console=true


Check BBMOD State Via Mobile
    [Documentation]  This keyword is used to check BBMOD state via Mobile.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${xpath}  ${state}

    ${title_element}  SeleniumLibrary.Get Element Attribute  ${xpath}/div/div[3]/div  title
    Run Keyword If  '${title_element}'=='Initializing...'
    ...  Check If BBMOD Is Offline  ${xpath}  ${state}
    ...  ELSE
    ...  Should Match Regexp  ${title_element}  ${state}


Check If BBMOD Is Offline
    [Documentation]  This keyword is used to check if BBMOD is offline.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${xpath}  ${state}

    ${title_element}  SeleniumLibrary.Get Element Attribute  ${xpath}/div/div[3]/div[2]  title
    Should Match Regexp  ${title_element}  ${state}


BBMODs Reset Confirmation Canceled Via Mobile
    [Documentation]  This keyword is pressing the Reset button for all BBMODs but canceled the confirmation.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    FOR  ${xpath}  IN  @{BBMODS_XPATH}
        Click Element  ${xpath}
        ${bbmod_name}  Get Text  ${xpath}/div/div[2]/div[1]
        ${bbmod_number}  Get Text  ${xpath}/div/div[2]/div[2]
        Log  \nReset for ${bbmod_number}: ${bbmod_name} will be performed!  console=true
        Click Element  ${xpath}/div/div[1]
        ${status_reset}  Run Keyword And Return Status
        ...  Element Should Be Enabled  ${xpath}/div/div[1]/span/div/div[1]/button
        Run Keyword If  ${status_reset}
        ...  Run Keywords
        ...  Click Element  ${xpath}/div/div[1]/span/div/div[1]/button
        ...  AND
        ...  Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[2]/button
        ...  AND
        ...  Log  Operation for ${bbmod_number}: ${bbmod_name} is cancelled!  console=true
        ...  ELSE
        ...  Run Keywords
        ...  Click Element  ${xpath}/div/div[1]
        ...  AND
        ...  Log  ${bbmod_number}: ${bbmod_name} Reset button is disabled because it doesn't support 5G![OK]  console=true
    END


Close BTS Start-up View Via Mobile
    [Documentation]  This keyword is used to close BTS start-up view via Mobile.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${start-up_view}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div
    ...  /div[3]/div/ui-footer/div/ui-button/button
    Wait Until Element Is Visible  ${start-up_view}  600
    Click Element  ${start-up_view}


Close Startup View If Visible Via Mobile
    [Documentation]  This keyword is used to close startup view if visible.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${timeout}=25s

    ${close_button}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[3]/div/
    ...  ui-footer/div/ui-button/button
    ${startup_visible}  Run Keyword And Return Status  Wait Until Element Is Visible  ${close_button}  timeout=${timeout}
    IF  ${startup_visible}  Wait Until Element Is Clicked For Mobile  ${close_button}  ${timeout}


SELENIUM Click Visible Element
    [Documentation]  This keyword is used to click visible element.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${locator}  ${timeout}=15s

    Wait Until Element Is Visible  locator=${locator}  timeout=${timeout}
    Click Element  locator=${locator}


ADMIN Get Parameters For All
    [Documentation]  This keyword is used to get parameters forall.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${class_name}  ${timeout}=10

    ${out_list_of_parameters_dict}  Get Parameters For All  class_name=${class_name}  timeout=${timeout}

    [Return]  ${out_list_of_parameters_dict}


Check Alarm To Be Present
    [Documentation]  This keyword check if the alarm is present on specific RAT.
    ...  Fault and name of alarm must be given as an argument. Example: 4614 RAT blocked.
    ...  Technology must be given as argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${fault_and_name}  ${technology}

    ${alarms_xpath}  Get Xpath For Alarm Via Mobile
    FOR  ${alarm_xpath}  IN  @{alarms_xpath}
        Wait Until Element Is Clicked For Mobile  ${alarm_xpath}  120
        ${alarm_status_text}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/
        ...  fault-management-downgrade/alarms-details/div/div[2]/div[2]/div[5]/div
        ${status_alarm}  Get Text  ${alarm_status_text}
        ${status_technology_text}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/
        ...  fault-management-downgrade/alarms-details/div/div[2]/div[4]/div[1]/div
        ${status_technology}  Get Text  ${status_technology_text}
        ${alarm_details}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/
        ...  fault-management-downgrade/alarms-details/div/div[1]/i
        IF  '${status_alarm}'=='${fault_and_name}' and '${status_technology}'=='${technology}'
            Log  Alarm with fault and name: ${fault_and_name} on technology:${technology} appeared!  console=true
            Wait Until Element Is Visible  ${alarm_details}  60
            Click Element  ${alarm_details}
            Go To Site View Via Mobile
            BREAK
        ELSE
            Wait Until Element Is Visible  ${alarm_details}  60
            Click Element  ${alarm_details}
        END
    END


Wait Until Element Is Clicked For Mobile
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  This KW waits for Click Element KW to succeeds.
    [Arguments]  ${xpath}  ${retry_timeout}=30s  ${retry_interval}=5s

    Wait Until Keyword Succeeds  ${retry_timeout}  ${retry_interval}
    ...  Click Element  ${xpath}
