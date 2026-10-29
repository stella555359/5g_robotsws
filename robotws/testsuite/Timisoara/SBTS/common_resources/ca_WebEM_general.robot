*** Settings ***
Documentation  *AUTHOR*: andreea.burtic@nokia.com
...  This resource is used for WebEM TCs that contain common KWs, both from old GUI and from the new GUI.

Resource  ca_SBTS_general.robot
Resource  ca_WebEM_${GUI_VERSION}_GUI_general.robot

Library  SeleniumLibrary  run_on_failure=Nothing
Library  taf.fdsw.rc  WITH NAME  rc
Library  hran_radio


*** Variables ***
${GUI_VERSION}  new  # GUI version can be old or new. The new GUI is for software releases newer or equal to SBTS25R1.
${NR_UPLINK_TEST}  //li[@heading="NR Uplink"]  # Generic xpath for nr uplink test header
${VIRTUAL_DISPLAY}  True  #Activate with True or deactivate with False headless running.


*** Keywords ***
WebEM Setup
    [Documentation]  This keyword is used to set the WebEM Setup.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${timeout}=60s

    Set Screenshot Directory  ${BTS_FILES}/selenium_screenshot_${TEST_NAME}
    Open WebEM  timeout=${timeout}
    Get Xpath For All Cells
    ${smods_xpath}  Get Xpaths For SMODs
    Set Test Variable  ${SMODS_XPATH}
    ${bbmods_xpath}  Get Xpaths For BBMODs
    Set Test Variable  ${BBMODS_XPATH}
    ${rmods_xpath}  Get Xpaths For RMODs
    Set Test Variable  ${RMODS_XPATH}


Open WebEM
    [Documentation]  This keyword opens the WebEM in chrome browser and maximizes the window.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${timeout}

    ${chrome_options}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    ${prefs}  Create Dictionary  download.default_directory=${DOWNLOADS_PATH}
    Call Method  ${chrome_options}  add_experimental_option  prefs  ${prefs}
    Call Method  ${chrome_options}  add_argument  --ignore-ssl-errors
    Call Method  ${chrome_options}  add_argument  --ignore-certificate-errors
    Call Method  ${chrome_options}  add_argument  --disable-popup-blocking
    IF  ${VIRTUAL_DISPLAY}  Call Method  ${chrome_options}  add_argument  --headless
    Create Webdriver  Chrome  options=${chrome_options}
    Go To  https://${OAM_BTS_IP}
    Set Window Size  ${1920}  ${1100}
    Check Private Connection
    Login SBTS
    Legal Notice
    Log  Wait until the page is loaded.  console=true
    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  ${timeout}
    ...  WebElement is not fully loaded in ${timeout} seconds.
    Capture Page Screenshot  WebEM_SBTS_initial_state.png


Check Private Connection
    [Documentation]  This keyword is used to check private connection.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  \nCheck private connection  console=true
    ${status}  Run Keyword And Return Status
    ...  Get Text  //*[@id="main-message"]/h1
    Run Keyword If  ${status}
    ...  Run Keywords
    ...  Click Element  //*[@id="details-button"]
    ...  AND
    ...  Click Element  //*[@id="proceed-link"]


Login SBTS
    [Documentation]  This keyword is used to enter user and password into the corresponding fields and login in.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Input Text  //*[@id="login-username"]  ${OAM_BTS_USER}
    Input Password  //*[@id="login-password"]  ${OAM_BTS_PASSWORD}
    Click Element  //*[contains(text(), 'Login')]


Get Xpath For All Cells
    [Documentation]  This keyword is used to get xpath for all cells.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Get Xpath List For Cells  NR
    Get Xpath List For Cells  LTE
    Get Xpath List For Cells  WCDMA
    Get Xpath List For Cells  GSM


Get Xpath List For Cells
    [Documentation]  This keyword gets the xpath list for the given technology.
    ...  Technology must be given as argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${cell_technology}

    ${technology}  Convert To Lower Case  ${cell_technology}
    ${grid_size}  Get Radio Section Grid Size
    ${grid_block_xpath}  Create List
    FOR  ${elements}  IN RANGE  1  ${grid_size}+1
        ${class_element}  SeleniumLibrary.Get Element Attribute  //*[@id="simplifiedSiteContainer"]/div/div/div[3]/div[${elements}]  class
        Run Keyword If  '${class_element}'=='cell-${technology}-grid-element'
        ...  Append To List  ${grid_block_xpath}  //*[@id="simplifiedSiteContainer"]/div/div/div[3]/div[${elements}]
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
        ${cells_on_block_list}  Check If Multi Cell On Block  ${xpath}
        Append To List  ${xpath_cells}  @{cells_on_block_list}
    END
    Set Test Variable  ${${cell_technology}_cells_xpath}  ${xpath_cells}

    [Return]  ${xpath_cells}


Get Radio Section Grid Size
    [Documentation]  This keyword is used to get radio section grid size.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${rmod_header}  SeleniumLibrary.Get Element Count  class:rmod-header
    ${mha_header}  SeleniumLibrary.Get Element Count  class:mha-header
    ${ret_header}  SeleniumLibrary.Get Element Count  class:ret-header
    ${rae_header}  SeleniumLibrary.Get Element Count  class:rae-header
    ${cells_header}  SeleniumLibrary.Get Element Count  class:cell-header
    ${rmod_grid}  SeleniumLibrary.Get Element Count  class:rmod-grid-element
    ${port_grid}  SeleniumLibrary.Get Element Count  class:port-grid-element
    ${mha_grid}  SeleniumLibrary.Get Element Count  class:ald-mha-grid-element
    ${ret_grid}  SeleniumLibrary.Get Element Count  class:ald-ret-grid-element
    ${rae_grid}  SeleniumLibrary.Get Element Count  class:ald-rae-grid-element
    ${lte_cells}  SeleniumLibrary.Get Element Count  class:cell-lte-grid-element
    ${wcdma_cells}  SeleniumLibrary.Get Element Count  class:cell-wcdma-grid-element
    ${gsm_cells}  SeleniumLibrary.Get Element Count  class:cell-gsm-grid-element
    ${nr_cells}  SeleniumLibrary.Get Element Count  class:cell-nr-grid-element
    ${empty_row}  SeleniumLibrary.Get Element Count  class:empty-row
    ${all_grid}  Catenate  SEPARATOR=  ${rmod_header}+${cells_header}+${rmod_grid}+${port_grid}+${lte_cells}+${wcdma_cells}+${gsm_cells}
    ...  +${nr_cells}+${empty_row}+${mha_header}+${ret_header}+${rae_header}+${mha_grid}+${ret_grid}+${rae_grid}
    ${grid}  Evaluate  ${all_grid}

    [Return]  ${grid}


Check If Multi Cell On Block
    [Documentation]  This keyword is used to check if multi cell on block
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


Get Xpaths For SMODs
    [Documentation]  This keyword is used to get xpaths for SMODs.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${smod_grid_size}  SeleniumLibrary.Get Element Count  class:inside-cabinet-block
    ${grid_block_xpath}  Create List
    FOR  ${element}  IN RANGE  1  ${smod_grid_size}+1
        ${smod}  SeleniumLibrary.Get Element Attribute  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div/div/div[3]/div[${element}]  class
        Run Keyword If  '${smod}'=='smod-rel4-block subcabinet-block long-press-support default-smod-rel4-block inside-cabinet-block'
        ...  Append To List  ${grid_block_xpath}  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div/div/div[3]/div[${element}]
    END

    [Return]  ${grid_block_xpath}


Get Xpaths For BBMODs
    [Documentation]  This keyword is used to get xpaths for BBMODs.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${bbmod_grid_size}  SeleniumLibrary.Get Element Count  class:inside-cabinet-block
    ${grid_block_xpath}  Create List
    FOR  ${element}  IN RANGE  1  ${bbmod_grid_size}+1
        ${bbmod}  SeleniumLibrary.Get Element Attribute  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div/div/div[3]/div[${element}]  class
        Run Keyword If  '${bbmod}'=='subcabinet-block long-press-support default-subcabinet-block inside-cabinet-block'
        ...  Append To List  ${grid_block_xpath}  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div/div/div[3]/div[${element}]
    END

    [Return]  ${grid_block_xpath}


Get Xpaths For RMODs
    [Documentation]  This keyword is used to get xpaths for RMODs.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${grid_size}  Get Radio Section Grid Size
    ${grid_block_xpath}  Create List
    FOR  ${elements}  IN RANGE  1  ${grid_size}+1
        ${rmod}  SeleniumLibrary.Get Element Attribute  //*[@id="simplifiedSiteContainer"]/div/div/div[3]/div[${elements}]  class
        Run Keyword If  '${rmod}'=='rmod-grid-element'
        ...  Append To List  ${grid_block_xpath}  //*[@id="simplifiedSiteContainer"]/div/div/div[3]/div[${elements}]
    END

    [Return]  ${grid_block_xpath}


Open Remote WebEM
    [Documentation]  This keyword opens the WebEM in chrome browser remotely on secondary VM and maximizes the window.
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com

    ${chrome_options}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    ${prefs}  Create Dictionary  download.default_directory=${DOWNLOADS_PATH}
    Call Method  ${chrome_options}  add_experimental_option  prefs  ${prefs}
    Call Method  ${chrome_options}  add_argument  --ignore-ssl-errors
    Call Method  ${chrome_options}  add_argument  --ignore-certificate-errors
    Call Method  ${chrome_options}  add_argument  --disable-popup-blocking
    IF  ${VIRTUAL_DISPLAY}  Call Method  ${chrome_options}  add_argument  --headless
    ${options}  Call Method  ${chrome_options}  to_capabilities
    Create Webdriver  Remote  command_executor=http://${PC_IP2}:10020  desired_capabilities=${options}
    Go To  https://${OAM_SC_IP}
    Set Window Size  ${1920}  ${1100}
    Check Private Connection
    Login SBTS
    Legal Notice
    Log  Wait until the page is loaded.  console=true
    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  30s  WebElement is not fully loaded in 30s seconds.
    Capture Page Screenshot  WebEM_SBTS_initial_state.png


WebEM Teardown
    [Documentation]  This keyword is used to set WebEM teardown.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Run Keyword If Test Failed
    ...  Capture Page Screenshot  Snapshot_after_test_failed.png
    Run Keyword And Ignore Error
    ...  Download Application Logs
    Run Keyword And Ignore Error
    ...  Logout From SBTS
    Close Browser


Reset SBTS From Admin Confirmation Canceled
    [Documentation]  This keyword is pressing the Reset Site button but confirmation is canceled.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Reset Site will be performed.  console=true
    Wait Until Element Is Clicked  //*[contains(text(),'Reset Site')]  120
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[2]/button
    Log  Operation is cancelled!  console=true


Reset SBTS From Admin
    [Documentation]  This keyword is pressing the Reset Site button and the reset starts. After, is taking a screenshot of the SBTS.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Reset SBTS  console=true
    Sleep  10  Time for page to be updated
    Wait Until Element Is Clicked  //*[contains(text(),'Reset Site')]
    Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
    Wait Until Keyword Succeeds  120  5
    ...  Close BTS Start-up View
    Capture Page Screenshot  After_SBTS_is_UP.png
    Log  SBTS reseted  console=true


Login On WebEM If Lock Screen Or Logout Performed
    [Documentation]  Logs in to WebEM if the session is locked or the user was logged out (login page visible).

    ${session_locked}  Run Keyword and Return Status  Element Should Be Visible  //*[@class="screen-lock-container"]
    IF  ${session_locked}  Login From Lock Screen
    ${logout}  Run Keyword and Return Status  Element Should Be Visible  //*[@id="login-username"]
    IF  ${logout}==${TRUE} and ${session_locked}==${FALSE}
        Login SBTS
        Legal Notice
        Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  30s
    END


Login From Lock Screen
    [Documentation]  Unlocks the WebEM session by entering the BTS password and clicking Login.

    Input Password  //*[@id="screen-lock-password-input"]  ${OAM_BTS_PASSWORD}
    Click Element  //*[contains(text(), 'Login')]


Close BTS Start-up View
    [Documentation]  This keyword is closing BTS Start-up view.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Waiting for BTS Start-up View to be visible  console=true
    Run Keyword And Ignore Error
    ...  Wait Until Element Is Visible
    ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button/button  1200
    Login On WebEM If Lock Screen Or Logout Performed
    Wait Until Element Is Clicked
    ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button/button  120
    Log  BTS Start-up View closed  console=true


Close Startup View If Visible
    [Documentation]  This keyword is used to close startup view if visible.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${timeout}=25s

    ${close_button}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[3]/div/
    ...  ui-footer/div/ui-button/button
    ${startup_visible}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  ${close_button}  timeout=${timeout}
    Run Keyword If  ${startup_visible}==True
    ...  Wait Until Element Is Clicked  ${close_button}  ${timeout}


Site Block
    [Documentation]  This keyword is pressing the Site Block button.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked  //*[contains(@a-text, "Block Site")]  120
    ${site_status}  Get Text  xpath:/html/body/div[1]/div/div/ui-modal-renderer/site-block-modal/ui-modal/div/div/div[3]/div/ui-footer/ui-button[1]
    ${status}  Run Keyword And Return Status  Should Match Regexp  ${site_status}  Block Site|Block
    Run Keyword If  ${status}
    ...  Run Keywords
    ...  Log  ${site_status} button is visible and Site Block will be performed![OK]  console=true
    ...  AND
    ...  Click Element  xpath:/html/body/div[1]/div/div/ui-modal-renderer/site-block-modal/ui-modal/div/div/div[3]/div/ui-footer/ui-button[1]/button
    ...  ELSE
    ...  Fail  ${site_status} button isn't in expected state![NOK]  console=true


Site Unblock
    [Documentation]  This keyword is pressing the Site Unblock button.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Wait Until Element Is Enabled  //*[contains(@a-text, "Unblock Site")]  600
    Wait Until Element Is Clicked  //*[contains(@a-text, "Unblock Site")]  120
    ${site_status}  Get Text  xpath:/html/body/div[1]/div/div/ui-modal-renderer/site-unblock-modal/ui-modal/div/div/div[3]/div/ui-footer/ui-button[1]
    ${status}  Run Keyword And Return Status  Should Match Regexp  ${site_status}  Unblock Site|Unblock
    ${command_text}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/ui-modal-renderer/site-unblock-modal/ui-modal/div/div/div[3]/
    ...  div/ui-footer/ui-button[1]/button
    Run Keyword If  ${status}
    ...  Run Keywords
    ...  Log  ${site_status} button is visible and Site Unblock will be performed![OK]  console=true
    ...  AND
    ...  Click Element  ${command_text}
    ...  AND
    ...  Close BTS Start-up View
    ...  ELSE
    ...  Fail  ${site_status} button isn't in expected state![NOK]  console=true


RAT Block
    [Documentation]  This keyword is pressing the block button for the specific technology.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    Sleep  15s  Time for page to be updated
    Log  \n${rat} RAT Block will be performed.  console=true
    Wait Until Element Is Visible  //*[contains(text(), 'Block/Unblock')][contains(text(), 'RAT')]  120
    Wait Until Element Is Clicked  //*[contains(text(), 'Block/Unblock')][contains(text(), 'RAT')]  60
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


RAT Block Confirmation Canceled
    [Documentation]  This keyword is pressing the block button for the specific technology but canceled the confirmation.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    Sleep  15s  Time for page to be updated
    Log  \n${rat} RAT Block will be performed.  console=true
    Wait Until Element Is Visible  //*[contains(text(), 'Block/Unblock')][contains(text(), 'RAT')]  120
    Wait Until Element Is Clicked  //*[contains(text(), 'Block/Unblock')][contains(text(), 'RAT')]  60
    ${text_button_block}  Get Text  //*[contains(text(), 'Block')][contains(text(), '${rat}')]
    ${status}  Run Keyword And Return Status  Should Match Regexp  ${text_button_block}  ${rat} Block|Block ${rat}
    Run Keyword If  ${status}
    ...  Log  ${rat} RAT Block/Unblock button is visible as ${text_button_block}![OK]  console=true
    ...  ELSE
    ...  Log  ${text_button_block} button is not ok![NOK] level=ERROR  console=true
    Click Element  //*[contains(text(), 'Block')][contains(text(), '${rat}')]
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[2]/button
    Log  Operation is cancelled!  console=true


RAT Unblock
    [Documentation]  This keyword is pressing the unblock button for the specific technology.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    Sleep  15s  Time for page to be updated
    Log  \n${rat} RAT Unblock will be performed.  console=true
    Wait Until Element Is Visible  //*[contains(text(), 'Block/Unblock')][contains(text(), 'RAT')]  120
    Wait Until Element Is Clicked  //*[contains(text(), 'Block/Unblock')][contains(text(), 'RAT')]  60
    ${text_button_unblock}  Get Text  //*[contains(text(), 'Unblock')][contains(text(), '${rat}')]
    ${status}  Run Keyword And Return Status  Should Match Regexp  ${text_button_unblock}  ${rat} Unblock|Unblock ${rat}
    Run Keyword If  ${status}
    ...  Log  ${rat} RAT Block/Unblock button is visible as ${text_button_unblock}![OK]  console=true
    ...  ELSE
    ...  Log  ${text_button_unblock} button is not ok![NOK] level=ERROR  console=true
    Log  ${rat} RAT Unblock is ongoing.  console=true
    Click Element  //*[contains(text(), 'Unblock')][contains(text(), '${rat}')]
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button


RAT Unblock Confirmation Canceled
    [Documentation]  This keyword is pressing the unblock button for the specific technology but canceled the confirmation.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    Sleep  15s  Time for page to be updated
    Log  \n${rat} RAT Unblock will be performed.  console=true
    Wait Until Element Is Visible  //*[contains(text(), 'Block/Unblock')][contains(text(), 'RAT')]  120
    Wait Until Element Is Clicked  //*[contains(text(), 'Block/Unblock')][contains(text(), 'RAT')]  60
    ${text_button_unblock}  Get Text  //*[contains(text(), 'Unblock')][contains(text(), '${rat}')]
    ${status}  Run Keyword And Return Status  Should Match Regexp  ${text_button_unblock}  ${rat} Unblock|Unblock ${rat}
    Run Keyword If  ${status}
    ...  Log  ${rat} RAT Block/Unblock button is visible as ${text_button_unblock}![OK]  console=true
    ...  ELSE
    ...  Log  ${text_button_unblock} button is not ok![NOK] level=ERROR  console=true
    Click Element  //*[contains(text(), 'Unblock')][contains(text(), '${rat}')]
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[2]/button
    Log  Operation is canceled!  console=true


Check All Cells From WebEM
    [Documentation]  Verify if cells are online and enabled.
    ...  *AUTHOR*:andreea.burtic@nokia.com

    ${rat_list}  Create List  GSM  LTE  WCDMA  NR
    FOR  ${rat}  IN  @{rat_list}
        ${cells_status}  Get States For Cells In RAT  ${rat}
        Check RAT Cells  ${cells_status}  Online|-  Enabled|enabled
    END


Get States For Cells In RAT
    [Documentation]  This keyword is getting a dictionary of all states for every cell for the specific technology.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    ${table_position_mapping}  Create Dictionary  GSM=4  LTE=6  WCDMA=4  NR=4
    ${table_position}  Set Variable  ${table_position_mapping}[${rat}]
    ${table_size}  Create Dictionary  GSM=6  LTE=6  WCDMA=5  NR=6
    ${rat_table_lines}  Set Variable  ${table_size}[${rat}]
    ${final_table}  Create Dictionary
    FOR  ${element}  IN  @{${rat}_CELLS_XPATH}
        Run Keyword And Ignore Error  Mouse Over  ${element}
        Click Element  ${element}
        ${id_cell}  Get Text  ${element}/div/div/div/div[2]/div
        ${final_status}  Status Table  ${table_position}  ${rat_table_lines}
        Set To Dictionary  ${final_table}  ${id_cell}=${final_status}
    END

    [Return]  ${final_table}


Status Table
    [Documentation]  This keyword is used to return status table.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${table_index}  ${rat_table_size}

    Click Element  //*[contains(@index, 'tabsContainer.info.id')]
    ${status_table}  Create Dictionary
    FOR  ${table_line}  IN RANGE  1  ${rat_table_size}
        ${status}  Get Text  //*[contains(@class, 'details-info-body')]/div/div[${table_index}]
        ${status_regex}  Run Keyword And Return Status
        ...  Should Match Regexp  ${status}  ^Status
        Run Keyword If  ${status_regex} == ${FALSE}
        ...  Evaluate Status Table  ${table_index}
        ${state}  Get Text  //*[contains(@class, 'details-info-body')]/div/div[${table_index}]/div/div/div/table/tbody/tr[${table_line}]/td[1]
        ${state_key}  Fetch From Left  ${state}  :
        ${state_value}  Get Text  //*[contains(@class,'details-info-body')]/div/div[${table_index}]/div/div/div/table/tbody/tr[${table_line}]/td[2]
        Set To Dictionary  ${status_table}  ${state_key}=${state_value}
    END

    [Return]  ${status_table}


Evaluate Status Table
    [Documentation]  This keyword evaluate table index in case of Subcell list is visible.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${table_index}

    ${table_index}  Evaluate  ${table_index}+1
    Set Test Variable  ${TABLE_INDEX}


Check RAT Cells
    [Documentation]  This keyword is used to check RAT cells.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${cells_status}  ${availability}  ${operational}

    FOR  ${cell}  IN  @{cells_status.keys()}
        ${availability_status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${cells_status}[${cell}][Availability status]  ${availability}
        ${operational_status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${cells_status}[${cell}][Operational state]  ${operational}
        Run Keyword If  ${availability_status} == ${FALSE} and ${operational_status} == ${FALSE}
        ...  Set Test Restriction  Cell ${cell} not in expected status.
    END


Block Cells
    [Documentation]  This keyword is pressing the block cells for the specific technology
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    FOR  ${element}  IN  @{${rat}_CELLS_XPATH}
        Wait Until Keyword Succeeds  60  3  Mouse Over  ${element}
        Wait Until Element Is Clicked  ${element}  120
        Wait Until Element Is Clicked  //*[contains(text(), 'Block')][contains(text(), 'Cell')]  120
        Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button  120
    END


Block Cells Confirmation Canceled
    [Documentation]  This keyword is pressing the block cells for the specific technology but canceled the confirmation.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    FOR  ${element}  IN  @{${rat}_CELLS_XPATH}
        Wait Until Element Is Clicked  ${element}  120
        Wait Until Element Is Clicked  //*[contains(text(), 'Block')][contains(text(), 'Cell')]  120
        Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[2]/button  120
    END


Unblock Cells
    [Documentation]  This keyword is pressing the unblock cells for the specific technology
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    FOR  ${element}  IN  @{${rat}_CELLS_XPATH}
        Wait Until Keyword Succeeds  60  3  Mouse Over  ${element}
        Wait Until Element Is Clicked  ${element}  120
        Wait Until Element Is Clicked  //*[contains(text(), 'Unblock')][contains(text(), 'Cell')]  120
        Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button  120
    END


Unblock Cells Confirmation Canceled
    [Documentation]  This keyword is pressing the unblock cells for the specific technology but canceled the confirmation.
    ...  The technology must be given as an argument. Example: NR, LTE, WCDMA, GSM.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    FOR  ${element}  IN  @{${rat}_CELLS_XPATH}
        Wait Until Element Is Clicked  ${element}  120
        Wait Until Element Is Clicked  //*[contains(text(), 'Unblock')][contains(text(), 'Cell')]  120
        Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[2]/button
    END


Cells Block And Unblock For All RATs
    [Documentation]  Block and unblock cells for all configured RATs (GSM, WCDMA, LTE, NR).
    ...  For each RAT: Block Cells, verify blocked/offline, Unblock Cells, verify unblocked.
    ...  ${recovery_timeout} and ${disabled_timeout} are passed by the caller (e.g. RECOVERY_TIMEOUT, DISABLED_TIMEOUT).
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${recovery_timeout}  ${disabled_timeout}

    IF  ${SCF_COUNT_GSM}  Block And Unblock Cells For RAT  GSM  GNCEL  ${recovery_timeout}  ${disabled_timeout}
    IF  ${SCF_COUNT_WCDMA}  Block And Unblock Cells For RAT  WCDMA  WNCEL  ${recovery_timeout}  ${disabled_timeout}
    IF  ${SCF_COUNT_LTE}  Block And Unblock Cells For RAT  LTE  LNCEL  ${recovery_timeout}  ${disabled_timeout}
    IF  ${SCF_COUNT_NR}  Block And Unblock Cells For RAT  NR  NRCEL  ${recovery_timeout}  ${disabled_timeout}


Block And Unblock Cells For RAT
    [Documentation]  Block and unblock cells for one RAT. Used by Cells Block And Unblock For All RATs.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}  ${cell}  ${recovery_timeout}  ${disabled_timeout}

    Log  \n${rat} cells will be blocked!  console=true
    Block Cells  ${rat}
    Wait Until Keyword Succeeds  ${disabled_timeout}  10  Check All ${cell} Blocking State To Be Blocked
    Log  ${rat} Cells are Blocked![OK]  console=true
    Wait Until Keyword Succeeds  ${disabled_timeout}  10  Check All ${cell} Availability Status To Be ${OFFLINE}
    Log  ${rat} Cells are Offline![OK]  console=true
    Log  ${rat} cells were successfully blocked!  console=true
    Log  \n${rat} cells will be unblocked!  console=true
    Unblock Cells  ${rat}
    Wait Until Keyword Succeeds  ${recovery_timeout}  10  Check All ${cell} Blocking State To Be Unblocked
    Log  ${rat} Cells are Unblocked![OK]  console=true
    Log  ${rat} cells were successfully unblocked!  console=true


Check All ${technology_cells} Availability Status To Be ${availability_status}
    [Documentation]  Assert all cells of given type have given availability status.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Assert Every  ${technology_cells}  availabilityStatus=${availability_status}  timeout=60


Check All ${technology_cells} Blocking State To Be ${blocking_state}
    [Documentation]  Assert all cells of given type have given blocking state.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Assert Every  ${technology_cells}  blockingState=${blocking_state}  timeout=60


BBMODs Reset
    [Documentation]  This keyword is pressing the Reset button for all BBMODs and verify BBMODs state.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${abia_bbmod_with_lte}  Get ABIA BBMOD List With LTE Mapped On It
    FOR  ${xpath}  IN  @{BBMODS_XPATH}
        Wait Until Element Is Clicked  xpath=${xpath}
        ${bbmod_name}  Get Text  ${xpath}/div/div[2]/div[1]
        ${bbmod_number}  Get Text  ${xpath}/div/div[2]/div[2]
        ${bbmod_r_object}  Get Text  //div[@class='hardware-details-info']/div[2]/div[1]/div[2]/span
        ${bbmod_r_object}  Fetch From Right  ${bbmod_r_object}  :${SPACE}
        Log  \nReset for ${bbmod_number}: ${bbmod_name} will be performed!  console=true
        Wait Until Element Is Clicked  xpath=${xpath}/div/div[1]
        ${status_abia}  Run Keyword And Return Status  List Should Contain Value  ${abia_bbmod_with_lte}  ${bbmod_r_object}
        IF  '${bbmod_name}'=='ABIA' and '${ENB_BRANCH}'>='SBTS25R2' and ${status_abia}==${FALSE}
            Try To Reset ABIA BBMOD Without LTE Mapped On It  ${xpath}  ${bbmod_number}
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
            Reset Operation For BBMOD  ${bbmod_number}  ${bbmod_name}  ${xpath}
        ELSE
            Wait Until Element Is Clicked  xpath=${xpath}/div/div[1]
            Log  ${bbmod_number}: ${bbmod_name} Reset button is disabled because it doesn't support 5G![OK]  console=true
        END
    END


Get BBMODs Name
    [Documentation]  Collects and returns the list of BBMOD names from the WebEM GUI using configured XPaths.

    ${bbmods_name_list}  Create List
    FOR  ${xpath}  IN  @{BBMODS_XPATH}
        Wait Until Element Is Clicked  xpath=${xpath}
        ${bbmod_name}  Get Text  ${xpath}/div/div[2]/div[1]
        Append To List  ${bbmods_name_list}  ${bbmod_name}
    END

    [Return]  ${bbmods_name_list}


Try To Reset ABIA BBMOD Without LTE Mapped On It
    [Documentation]  This keyword is used to try to reset ABIA BBMOD
    ...  which does not have LTE mapped on it.
    [Arguments]  ${xpath}  ${bbmod_number}

    Log  Try to reset ABIA BBMOD and verify fail message...  console=true
    Click Element  ${xpath}/div/div[1]/span/div/div[1]/button
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
    Wait Until Page Contains  Reset ${bbmod_number} operation failed  timeout=60  error=Fail message didn't appear in WebEM. [NOK]
    Log  Fail operation appeared on page. [OK]  console=true


Reset Operation For BBMOD
    [Documentation]  This keyword is used to reset operation for BBMOD.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${bbmod_number}  ${bbmod_name}  ${xpath}

    Log  ${bbmod_number}: ${bbmod_name} Reset button is enabled because it supports 5G![OK]  console=true
    Wait Until Element Is Clicked  xpath=${xpath}/div/div[1]/span/div/div[1]/button
    Wait Until Element Is Clicked
    ...  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
    Log  ${bbmod_number}: ${bbmod_name} Reset is ongoing!  console=true
    Wait Until Keyword Succeeds  600  3  Check BBMOD State  ${xpath}  Offline
    Log  ${bbmod_number}: ${bbmod_name} is Offline!  console=true
    Wait Until Keyword Succeeds  600  3  Check BBMOD State  ${xpath}  Enabled|Online
    Log  ${bbmod_number}: ${bbmod_name} is Online!  console=true
    Wait Until Element Is Clicked  xpath=${xpath}/div/div[1]
    Sleep  5s  Time for page to be updated
    Wait Until Element Is Enabled  ${xpath}/div/div[1]/span/div/div[1]/button  1200
    Wait Until Element Is Clicked  xpath=${xpath}/div/div[1]
    Log  ${bbmod_number}: ${bbmod_name} was successfully reset!  console=true


Check BBMOD State
    [Documentation]  This keyword is used to check BBMOD state.
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


BBMODs Reset Confirmation Canceled
    [Documentation]  This keyword is pressing the Reset button for all BBMODs but canceled the confirmation.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    FOR  ${xpath}  IN  @{BBMODS_XPATH}
        Wait Until Element Is Clicked  ${xpath}  60
        ${bbmod_name}  Get Text  ${xpath}/div/div[2]/div[1]
        ${bbmod_number}  Get Text  ${xpath}/div/div[2]/div[2]
        Log  \nReset for ${bbmod_number}: ${bbmod_name} will be performed!  console=true
        Click Element  ${xpath}/div/div[1]
        ${status_reset}  Run Keyword And Return Status  Element Should Be Enabled  ${xpath}/div/div[1]/span/div/div[1]/button
        Run Keyword If  ${status_reset}
        ...  Run Keywords
        ...  Wait Until Element Is Clicked  xpath=${xpath}/div/div[1]/span/div/div[1]/button
        ...  AND
        ...  Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[2]/button
        ...  AND
        ...  Log  Operation for ${bbmod_number}: ${bbmod_name} is cancelled!  console=true
        ...  ELSE
        ...  Run Keywords
        ...  Wait Until Element Is Clicked  xpath=${xpath}/div/div[1]
        ...  AND
        ...  Log  ${bbmod_number}: ${bbmod_name} Reset button is disabled because it doesn't support 5G![OK]  console=true
    END


RMODs Reset
    [Documentation]  This keyword is pressing the Reset button for all RMODs and verify rmods state.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    FOR  ${xpath}  IN  @{RMODS_XPATH}
        Wait Until Element Is Clicked  xpath=${xpath}
        ${rmod_name}  Get Text  ${xpath}/div/div[3]/div[2]/div[1]
        ${rmod_number}  Get Text  ${xpath}/div/div[3]/div[2]/div[2]
        Log  \nReset for ${rmod_number}: ${rmod_name} will be performed!  console=true
        Wait Until Element Is Clicked  xpath=${xpath}/div/div[3]/div[1]
        ${text_button_reset}  Get Text  ${xpath}/div/div[3]/div[1]/span/div/div[1]/button
        Run Keyword If  '${text_button_reset}'=='Reset'
        ...  Log  ${rmod_number}: ${rmod_name} Reset button is visible![OK]  console=true
        ...  ELSE
        ...  Log  ${rmod_number}: ${rmod_name} Reset button is not visible![NOK]  console=true
        ${status}  Run Keyword And Return Status  Element Should Be Disabled  ${xpath}/div/div[3]/div[1]/span/div/div[2]/button
        Run Keyword If  ${status}
        ...  Log  ${rmod_number}: ${rmod_name} Remove button is disabled![OK]  console=true
        ...  ELSE
        ...  Log  ${rmod_number}: ${rmod_name} Remove button is enabled![NOK]  console=true
        Wait Until Element Is Clicked  xpath=${xpath}/div/div[3]/div[1]/span/div/div[1]/button
        Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
        Wait Until Keyword Succeeds  300  10  Check RMOD State  ${xpath}  Not installed
        Log  ${rmod_number}: ${rmod_name} is Not installed!  console=true
        Wait Until Keyword Succeeds  600  10  Check RMOD State  ${xpath}  Online|Enabled
        Log  ${rmod_number}: ${rmod_name} is Online!  console=true
        Wait Until Element Is Clicked  xpath=${xpath}/div/div[3]/div[1]
        ${status}  Run Keyword And Return Status  Element Should Be Enabled  ${xpath}/div/div[3]/div[1]/span/div/div[1]/button
        Run Keyword If  ${status}
        ...  Run Keywords
        ...  Log  ${rmod_number}: ${rmod_name} was successfully reset!  console=true
        ...  AND
        ...  Wait Until Element Is Clicked  xpath=${xpath}/div/div[3]/div[1]
    END


Check RMOD State
    [Documentation]  This keyword is used to check RMOD state.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${xpath}  ${state}

    ${title_element}  SeleniumLibrary.Get Element Attribute  ${xpath}/div/div[3]/div[3]/div  title
    Should Match Regexp  ${title_element}  ${state}


RMODs Reset Confirmation Canceled
    [Documentation]  This keyword is pressing the Reset button for all RMODs but canceled the confirmation.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    FOR  ${element}  IN  @{RMODS_XPATH}
        Wait Until Element Is Clicked  xpath=${element}
        ${rmod_name}  Get Text  ${element}/div/div[3]/div[2]/div[1]
        ${rmod_number}  Get Text  ${element}/div/div[3]/div[2]/div[2]
        Log  \nReset for ${rmod_number}: ${rmod_name} will be performed!  console=true
        Wait Until Element Is Clicked  xpath=${element}/div/div[3]/div[1]
        Wait Until Element Is Clicked  xpath=${element}/div/div[3]/div[1]/span/div/div[1]/button
        Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[2]/button
        Log  Reset operation for ${rmod_number}: ${rmod_name} is cancelled!  console=true
    END


Verify States For Cells In Unaffected RATs
    [Documentation]  Verify if cells are online and enabled.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rat}

    ${rat_list}  Create List  GSM  LTE  WCDMA  NR
    Remove Values From List  ${rat_list}  ${rat}
    Log  Verify States for Cells in Unafected RATs: ${rat_list}  console=true
    FOR  ${rat}  IN  @{rat_list}
        ${cells_status}  Get States For Cells In RAT  ${rat}
        Check RAT Cells  ${cells_status}  Online|-  Enabled|enabled
    END


Get All RMODs Ids
    [Documentation]  This keyword is used to get all RMODs ids.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${all_rmods}  Create List
    ${rmods_ids}  Get Ids For All  RMOD
    FOR  ${index}  IN  @{rmods_ids}
        ${rmod}  Fetch From Right  ${index}  RMOD_R-
        Append To List  ${all_rmods}  ${rmod}
    END

    [Return]  ${all_rmods}


Lock BBMODs
    [Documentation]  This keyword is pressing the Lock button for all BBMODs.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    FOR  ${bbmod}  IN  @{BBMODS_XPATH}
        Wait Until Keyword Succeeds  120  5  Lock Module  ${bbmod}
        Wait Until Element Is Clicked  ${bbmod}  120
        ${bbmod_title}  Get Text  ${bbmod}/div/div[2]/div[1]
        ${bbmod_name_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
        ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div[1]/span
        ${bbmod_name}  Get Text  ${bbmod_name_text}
        Log  \nLock for ${bbmod_name}: ${bbmod_title} will be performed!  console=true
        ${status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  900  10
        ...  Check All States For BBMOD  ${bbmod}  Online|-  Enabled|enabled  Locked|locked
        Run Keyword If  ${status}
        ...  Log  ${bbmod_name}:${bbmod_title} is Locked.  console=true
        ...  ELSE
        ...  Fail  ${bbmod_name}:${bbmod_title} is not Locked after performing lock operation.
    END


Lock BBMODs Confirmation Canceled
    [Documentation]  This keyword is pressing the Lock button for all BBMODs but canceled the confirmation.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    FOR  ${bbmod}  IN  @{BBMODS_XPATH}
        Wait Until Keyword Succeeds  120  5
        ...  Lock Module Confirmation Canceled  ${bbmod}
        Wait Until Element Is Clicked  ${bbmod}  120
        ${bbmod_title}  Get Text  ${bbmod}/div/div[2]/div[1]
        ${bbmod_name_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
        ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div[1]/span
        ${bbmod_name}  Get Text  ${bbmod_name_text}
        Log  \nLock operation for ${bbmod_name}: ${bbmod_title} is canceled!  console=true
    END


Unlock BBMODs
    [Documentation]  This keyword is pressing the Unlock button for all BBMODs.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    FOR  ${bbmod}  IN  @{BBMODS_XPATH}
        Wait Until Keyword Succeeds  120  5
        ...  Unlock Module  ${bbmod}
        Wait Until Element Is Clicked  ${bbmod}  120
        ${bbmod_title}  Get Text  ${bbmod}/div/div[2]/div[1]
        ${bbmod_name_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
        ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div[1]/span
        ${bbmod_name}  Get Text  ${bbmod_name_text}
        Log  \nUnlock for ${bbmod_name}: ${bbmod_title} will be performed!  console=true
        ${status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  1200  10
        ...  Check All States For BBMOD  ${bbmod}  Online|-  Enabled|enabled  Unlocked|unlocked
        Run Keyword If  ${status}
        ...  Log  ${bbmod_name}:${bbmod_title} is Unlocked.  console=true
        ...  ELSE
        ...  Fail  ${bbmod_name}:${bbmod_title} is not Unlocked after performing unlock operation.
    END


Unlock BBMODs Confirmation Canceled
    [Documentation]  This keyword is pressing the Unlock button for all BBMODs but canceled the confirmation.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    FOR  ${bbmod}  IN  @{BBMODS_XPATH}
        Wait Until Keyword Succeeds  120  5
        ...  Unlock Module Confirmation Canceled  ${bbmod}
        Wait Until Element Is Clicked  ${bbmod}  120
        ${bbmod_title}  Get Text  ${bbmod}/div/div[2]/div[1]
        ${bbmod_name_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
        ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div[1]/span
        ${bbmod_name}  Get Text  ${bbmod_name_text}
        Log  \nUnlock operation for ${bbmod_name}: ${bbmod_title} is canceled!  console=true
    END


Lock RMODs
    [Documentation]  This keyword is pressing the Lock button for all RMODs.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    FOR  ${rmod_xpath}  IN  @{RMODS_XPATH}
        Wait Until Keyword Succeeds  120  5
        ...  Lock Module  ${rmod_xpath}
        Wait Until Element Is Clicked  ${rmod_xpath}  120
        ${rmod_name_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
        ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div[1]/span
        ${rmod_name}  Get Text  ${rmod_name_text}
        Log  \nLock for ${rmod_name} will be performed!  console=true
        ${status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  900  10
        ...  Check RMOD States  ${rmod_xpath}  Online|-  Enabled|enabled  Locked|locked
        Run Keyword If  ${status}
        ...  Log  ${rmod_name} is Locked.  console=true
        ...  ELSE
        ...  Fail  ${rmod_name} is not Locked after performing lock operation.
    END


Lock RMODs Confirmation Canceled
    [Documentation]  This keyword is pressing the Lock button for all RMODs but canceled the confirmation.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    FOR  ${rmod_xpath}  IN  @{RMODS_XPATH}
        Wait Until Keyword Succeeds  120  5
        ...  Lock Module Confirmation Canceled  ${rmod_xpath}
        Wait Until Element Is Clicked  ${rmod_xpath}  120
        ${rmod_name_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
        ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div[1]/span
        ${rmod_name}  Get Text  ${rmod_name_text}
        Log  \nLock operation for ${rmod_name} is canceled!  console=true
    END


Unlock RMODs
    [Documentation]  This keyword is pressing the Unlock button for all RMODs.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    FOR  ${rmod_xpath}  IN  @{RMODS_XPATH}
        Wait Until Keyword Succeeds  120  5
        ...  Unlock Module  ${rmod_xpath}
        Wait Until Element Is Clicked  ${rmod_xpath}  120
        ${rmod_name_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
        ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div[1]/span
        ${rmod_name}  Get Text  ${rmod_name_text}
        Log  \nUnlock for ${rmod_name} will be performed!  console=true
        ${status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  900  10
        ...  Check RMOD States  ${rmod_xpath}  Online|-  Enabled|enabled  Unlocked|unlocked
        Run Keyword If  ${status}
        ...  Log  ${rmod_name} is Unlocked.  console=true
        ...  ELSE
        ...  Fail  ${rmod_name} is not Unlocked after performing unlock operation.
    END


Unlock RMODs Confirmation Canceled
    [Documentation]  This keyword is pressing the Unlock button for all RMODs but canceled the confirmation.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    FOR  ${rmod_xpath}  IN  @{RMODS_XPATH}
        Wait Until Keyword Succeeds  120  5
        ...  Unlock Module Confirmation Canceled  ${rmod_xpath}
        Wait Until Element Is Clicked  ${rmod_xpath}  120
        ${rmod_name_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
        ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div[1]/span
        ${rmod_name}  Get Text  ${rmod_name_text}
        Log  \nUnlock operation for ${rmod_name} is canceled!  console=true
    END


Lock Module
    [Documentation]  This keyword performs lock action for the given module.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${module_xpath}

    Click Element  ${module_xpath}
    ${lock}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div
    ...  /details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[2]/actions-buttons/span[3]/ui-button/button
    Wait Until Element Is Enabled  ${lock}  600
    Click Element  ${lock}
    Click Element  //*[contains(@a-text, "Lock")]/button


Lock Module Confirmation Canceled
    [Documentation]  This keyword performs lock action for the given module but canceled confirmation.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${module_xpath}

    Click Element  ${module_xpath}
    ${lock}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
    ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[2]/actions-buttons/span[3]/ui-button/button
    Wait Until Element Is Enabled  ${lock}  600
    Click Element  ${lock}
    Click Element  //*[contains(@a-text, "Cancel")]/button


Unlock Module
    [Documentation]  This keyword performs unlock action for the given module.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${module_xpath}

    Click Element  ${module_xpath}
    ${unlock}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
    ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[2]/actions-buttons/span[3]/ui-button/button
    Wait Until Element Is Enabled  ${unlock}  600
    Click Element  ${unlock}
    Click Element  //*[contains(@a-text, "Unlock")]/button


Unlock Module Confirmation Canceled
    [Documentation]  This keyword performs unlock action for the given module but canceled confirmation.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${module_xpath}

    Click Element  ${module_xpath}
    ${unlock}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
    ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[2]/actions-buttons/span[3]/ui-button/button
    Wait Until Element Is Enabled  ${unlock}  600
    Click Element  ${unlock}
    Click Element  //*[contains(@a-text, "Cancel")]/button


Check SMODs To Be Online And Enabled
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  This KW check all SMODs to be Online and Enabled.
    ...  ${recovery_smod_timeout} -> Timeout for SMODs to be enabled.
    [Arguments]  ${recovery_smod_timeout}

    Log  Checking SMODs to be Online and Enabled  console=true
    ${unit_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
    ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div/span[2]
    Set Test Variable  ${UNIT_TEXT}
    FOR  ${smod_xpath}  IN  @{SMODS_XPATH}
        Click Element  ${smod_xpath}
        ${smod_name}  Get Text  ${UNIT_TEXT}
        ${status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  ${recovery_smod_timeout}  10
        ...  Check SMOD States  ${smod_xpath}  Online|-  Enabled|enabled
        Run Keyword If  ${status}
        ...  Log  ${smod_name} is in correct state, Online!  console=true
        ...  ELSE
        ...  Fail  ${smod_name} is not in correct state!
    END


Check SMOD States
    [Documentation]  This keyword is used to check SMOD states.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${smod_xpath}  ${availability_status}  ${operational_state}

    Click Element  ${smod_xpath}
    ${av_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
    ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[3]/div/div[6]/div/div/div/table/tbody/tr[2]/td[2]
    ${av_status}  Get Text  ${av_text}
    ${op_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
    ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[3]/div/div[6]/div/div/div/table/tbody/tr[1]/td[2]
    ${op_state}  Get Text  ${op_text}
    Should Match Regexp  ${availability_status}  ${av_status}
    Should Match Regexp  ${operational_state}  ${op_state}


Check BBMODs To Be Online And Enabled
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  This KW check all BBMODs to be Online and Enabled.
    ...  ${recovery_bbmod_timeout} -> Timeout for SMODs to be enabled.
    [Arguments]  ${recovery_bbmod_timeout}

    Log  Checking BBMODs to be Online and Enabled  console=true
    FOR  ${bbmod_xpath}  IN  @{BBMODS_XPATH}
        Click Element  ${bbmod_xpath}
        ${bbmod_name}  Get Text  ${UNIT_TEXT}
        ${status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  ${recovery_bbmod_timeout}  10
        ...  Check All States For BBMOD  ${bbmod_xpath}  Online|-  Enabled|enabled  Unlocked|unlocked
        Run Keyword If  ${status}
        ...  Log  ${bbmod_name} is in correct state!  console=true
        ...  ELSE
        ...  Fail  ${bbmod_name} is not in correct state after performing decommissiong operation!
    END


Check All States For BBMOD
    [Documentation]
    ...  To Check all states for BBMOD
    ...  Input: BBMOD Xpath, couple of options can be check, for example BBMOD is Online or Offline.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${bbmod_xpath}  ${availability_status}  ${operational_state}  ${administrative_state}

    Click Element  ${bbmod_xpath}
    ${av_status_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div
    ...  /details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[3]/div/div[2]/div/div/div/table/tbody/tr[2]/td[2]
    ${av_status}  Get Text  ${av_status_text}
    ${op_state_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
    ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[3]/div/div[2]/div/div/div/table/tbody/tr[1]/td[2]
    ${op_state}  Get Text  ${op_state_text}
    ${ad_state_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
    ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[3]/div/div[2]/div/div/div/table/tbody/tr[3]/td[2]
    ${ad_state}  Get Text  ${ad_state_text}
    Should Match Regexp  ${availability_status}  ${av_status}
    Should Match Regexp  ${operational_state}  ${op_state}
    Should Match Regexp  ${administrative_state}  ${ad_state}


Check RMODs To Be Online And Enabled
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  This KW check all RMODs to be Online and Enabled.
    ...  ${recovery_rmod_timeout} -> Timeout for SMODs to be enabled.
    [Arguments]  ${recovery_rmod_timeout}

    Log  Checking RMODs to be Online and Enabled  console=true
    ${list_rmods_xpath}  Get Xpaths For RMODs
    FOR  ${rmod_xpath}  IN  @{list_rmods_xpath}
        Click Element  ${rmod_xpath}
        ${rmod_name}  Get Text  ${UNIT_TEXT}
        ${status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  ${recovery_rmod_timeout}  10
        ...  Check RMOD States  ${rmod_xpath}  Online|-  Enabled|enabled  Unlocked|unlocked
        Run Keyword If  ${status}
        ...  Log  ${rmod_name} is in correct state, Online!  console=true
        ...  ELSE
        ...  Fail  ${rmod_name} is not in correct state!
    END


Check RMOD States
    [Documentation]
    ...  To check RMOD states
    ...  Input: RMOD Xpath, couple of options can be check, for example Rmod is Online or Offline.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${rmod_xpath}  ${availability_status}  ${operational_state}  ${administrative_state}

    Click Element  ${rmod_xpath}
    ${av_status_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
    ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[3]/div/div[5]/div/div/div/table/tbody/tr[2]/td[2]
    ${av_status}  Get Text  ${av_status_text}
    ${op_state_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
    ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[3]/div/div[5]/div/div/div/table/tbody/tr[1]/td[2]
    ${op_state}  Get Text  ${op_state_text}
    ${ad_state_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
    ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[3]/div/div[5]/div/div/div/table/tbody/tr[3]/td[2]
    ${ad_state}  Get Text  ${ad_state_text}
    Should Match Regexp  ${availability_status}  ${av_status}
    Should Match Regexp  ${operational_state}  ${op_state}
    Should Match Regexp  ${administrative_state}  ${ad_state}


Check A Specific Operation In Operations History
    [Documentation]  Check a specific operation in Operation History tab. Example: Block, Unblock, Reset.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${wanted_operation}

    ${operation}  Get Text  //*[@id="operation.id"]/td[1]
    ${result}  Get Text  //*[@id="operation.id"]/td[6]
    Run Keyword If  '${operation}'=='${wanted_operation}' and '${result}'=='Succeeded'
    ...  Log  ${operation}:${result} appeared in Operations History View![OK]  console=true
    ...  ELSE
    ...  Fail  ${wanted_operation} is not seen correctly in Operations History View![NOK]


Check ABIA Reset In Operations History
    [Documentation]  Check ABIA Reset in Operation History tab.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    ${abia_bbmod_with_lte}  Get ABIA BBMOD List With LTE Mapped On It
    ${operation}  Get Text  //*[@id="operation.id"]/td[1]
    ${details}  Get Text  //*[@id="operation.id"]/td[2]/span
    ${result}  Get Text  //*[@id="operation.id"]/td[6]
    ${bbmod_r_object}  Fetch From Right  ${details}  /
    IF  '${ENB_BRANCH}'>='SBTS26R2'
        ${bbmod_r_object}  Fetch From Left  ${bbmod_r_object}  ;
    END
    ${status_abia}  Run Keyword And Return Status  List Should Contain Value  ${abia_bbmod_with_lte}  ${bbmod_r_object}
    IF  '${ENB_BRANCH}'>='SBTS25R2' and ${status_abia}==${FALSE}
        Should Be Equal  ${operation}  Warm reset
        Should Be Equal  ${result}  Failed
        Log  ${operation}:${result} appeared in Operations History View![OK]  console=true
    ELSE
        Should Be Equal  ${operation}  Warm reset
        Should Be Equal  ${result}  Succeeded
        Log  ${operation}:${result} appeared in Operations History View![OK]  console=true
    END


Activate Internal Trace
    [Documentation]  This keyword is used to activate internal trace.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Activate internal trace will be performed!  console=true
    Click Element  //*[contains(@a-text, 'Activate')]
    Run Keyword If  '${ENB_BRANCH}' > 'SBTS23R4'
    ...  Wait Until Element Is Visible  //*[contains(text(), "Send activate succeeded")]  300
    ...  ELSE
    ...  Wait Until Element Is Visible  //*[contains(text(), "Send succeeded")]  300
    Log  Activating internal trace was send succeeded![OK]  console=true


Performing Configuration Reset And Verify SBTS To Be Not Commissioned
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    ...  This KW execute configuration reset.
    ...  If the release is >= 23R3, configuration reset is performed via BTS Rescue Console.
    ...  If the release is <23R3, configuration reset is performed classical, via WebEM.
    ...  ${bts_rescue_console_timeout} -> timeout for sleep before page to be reloaded and BTS Rescue Console to be visible. (For example: 400s)
    ...  ${config_reset_option} -> option for configuration reset via BTS Rescue Console. (For example: 5)
    ...  The Options are:
    ...  1. Default (warm reset, no configuratio removal)
    ...  2. Delete BTS configuration from active partition.
    ...  3. Delete BTS configuration with installed operator certificates from active partition.
    ...  4. Delete BTS configuration with credentials from active partition.
    ...  5. Delete BTS configuration with installed operator certificates and credentials from active partition.
    ...  6. Delete BTS configuration with all operator provided data including the security credentials from active and passive partition.
    ...  Verify if SBTS is not commissioned.
    [Arguments]  ${bts_rescue_console_timeout}  ${config_reset_option}  ${username}=${OAM_BTS_USER}  ${password}=${OAM_BTS_PASSWORD}

    Log  Performing Configuration Reset and verify SBTS to be not commissioned!  console=true
    ${length_smod_list}  Get Length  ${SMODS_XPATH}
    IF  '${ENB_BRANCH}' >= 'SBTS23R3'
        Performing Configuration Reset Via BTS Rescue Console  ${bts_rescue_console_timeout}  ${config_reset_option}  ${username}  ${password}
    ELSE
        Performing Configuration Reset Via WebEM
    END
    IF  ${length_smod_list} > 1  Start Sync
    Log  Go to Site View!  console=true
    Wait Until Keyword Succeeds  120  5
    ...  Go To Site View
    IF  '${ENB_BRANCH}' >= 'SBTS23R3' and ${config_reset_option} == 1
        RETURN
    ELSE
        Wait Until Keyword Succeeds  120  5  Element Should Be Visible  //*[contains(text(), 'Not commissioned')]
        Log  SBTS is not commissioned!  console=true
    END
    coam.Reset Admin
    Sleep  60s


Login To BTS Rescue Console
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    ...  Login to BTS Rescue Console and wait until the page is fully loaded.
    [Arguments]  ${username}  ${password}

    Wait Until Element Is Visible  xpath:/html/body/div/div/div[1]/div[2]/div/div[1]/form/div[3]/div[1]/input  timeout=180s
    Log  BTS Rescue Console is visible![OK]  console=true
    Input Text  xpath:/html/body/div/div/div[1]/div[2]/div/div[1]/form/div[3]/div[1]/input  ${username}
    Input Password  xpath:/html/body/div/div/div[1]/div[2]/div/div[1]/form/div[3]/div[2]/input  ${password}
    Wait Until Element Is Visible  //*[contains(text(), 'Log In')]  timeout=60
    Click Element  //*[contains(text(), 'Log In')]
    Wait Until Element Is Visible  //*[contains(text(), 'Software')]  timeout=120
    Log  Login was performed successfully![OK]  console=true


Login To New BTS Rescue Console
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    ...  Login to BTS Rescue Console and wait until the page is fully loaded.
    ...  Only if FDSW release is FDSW24D or newer.
    [Arguments]  ${username}  ${password}

    Wait Until Element Is Visible  xpath:/html/body/div/div/div/div[2]/div[1]/form/div[3]/div[1]/input  timeout=180s
    Log  BTS Rescue Console is visible![OK]  console=true
    Input Text  xpath:/html/body/div/div/div/div[2]/div[1]/form/div[3]/div[1]/input  ${username}
    Input Password  xpath:/html/body/div/div/div/div[2]/div[1]/form/div[3]/div[2]/input  ${password}
    Wait Until Element Is Visible  xpath:/html/body/div/div/div/div[2]/div[1]/form/div[5]/button  timeout=60
    Click Element  xpath:/html/body/div/div/div/div[2]/div[1]/form/div[5]/button
    Wait Until Keyword Succeeds  120  5  Page Should Contain  Software
    Log  Login was performed successfully![OK]  console=true


Activate The Specific Option For Configuration Reset
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    ...  This KW activate the specific option for configuration reset from BTS Rescue Console.
    [Arguments]  ${config_reset_option}

    IF  '${FDSW_RELEASE}' < 'FDSW24D'
        ${div}  Set Variable  15
    ELSE IF  '${FDSW_RELEASE}' == 'FDSW24D'
        ${div}  Set Variable  16
    ELSE
        ${div}  Set Variable  17
    END
    Wait Until Element Is Clicked  //*[contains(text(), 'Software')]
    Wait Until Element Is Visible  //span[contains(text(), 'Install SW')]  timeout=120
    FOR  ${software_index}  IN RANGE  1  4
        ${partition_name}  Get Text
        ...  xpath:/html/body/div[${div}]/div[1]/div[2]/div[11]/div/div/div/div[${software_index}]/div/div/div/form[1]/div[1]/div[2]/span
        Run Keyword If  '${partition_name}' == 'Primary'
        ...  Run Keywords
        ...  Activate Configuration Reset For Primary Partition  ${div}  ${software_index}  ${config_reset_option}
        ...  AND
        ...  Exit For Loop
        ...  ELSE
        ...  Continue For Loop
    END


Activate Configuration Reset For Primary Partition
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    ...  This KW activate configuration reset for primary partition from BTS Rescue Console.
    [Arguments]  ${div}  ${software_index}  ${config_reset_option}

    Log  Activate configuration reset for primary partition!  console=true
    ${object}  Set Variable If  '${FDSW_RELEASE}' >= 'FDSW24D'  div/span[2]/button  div[2]/button
    Click Element  xpath:/html/body/div[${div}]/div[1]/div[2]/div[11]/div/div/div/div[${software_index}]/div/header/${object}
    Run Keyword And Ignore Error
    ...  Wait Until Element Is Visible  //span[contains(text(), 'Advanced reset options')]  timeout=30
    Run Keyword And Ignore Error
    ...  Click Element  //span[contains(text(), 'Advanced reset options')]
    Wait Until Element Is Clicked
    ...  xpath:/html/body/div[${div}]/div[1]/div[2]/div[5]/div/div/div/div[2]/div[2]/div/div[2]/div/div/div[1]/div[${config_reset_option}]/label
    ...  120
    Log  Activate configuration reset with option ${config_reset_option}!  console=true
    Click Element  xpath:/html/body/div[${div}]/div[1]/div[2]/div[5]/div/div/div/div[3]/div/button[2]
    Wait Until Element Is Visible  //*[contains(text(), 'Software activation was successful. BTS will be restarted.')]  timeout=300
    Log  Message 'Software activation was successful. BTS will be restarted.' is visible and will be closed![OK]  console=true
    ${ok_button}  Set Variable If  '${FDSW_RELEASE}' >= 'FDSW24D'
    ...  xpath:/html/body/div[6]/div/div/div/div[4]/div/button
    ...  xpath:/html/body/div[6]/div/div/div/div/div[6]/div/button
    Wait Until Element Is Visible  ${ok_button}  timeout=60
    Click Element  ${ok_button}
    Wait Until Element Is Visible  //*[contains(text(), 'Connection with the BTS has been lost')]  timeout=60


Plug And Play Pop-up
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    ...  This KW wait for Plug and Play pop-up to be visible and close it.

    Log  Waiting for Plug and Play Pop-up to be visible and close it!  console=true
    Wait Until Element Is Visible  xpath:/html/body/div[1]/div/div/ui-modal-renderer/plug-and-play-popup-component/ui-modal/div  timeout=900s
    ${button}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/ui-modal-renderer/plug-and-play-popup-component/ui-modal/div/div/div[3]/
    ...  div/ui-footer/div/ui-button[2]/button
    Click Element  ${button}
    Log  Plug and Play Pop-up is closed!  console=true


Start Sync
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  This KW start sync operation and wait until the operation is perform completed.

    Log  Sync will be performed...  console=true
    Wait Until Element Is Visible  //*[contains(@a-text, "Start sync")]/button
    ...  120
    Click Element  //*[contains(@a-text, "Start sync")]/button
    ${sync_status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible
    ...  //*[contains(text(), 'Start sync operation was completed. You could stop sync in Site Runtime View if needed.')]
    ...  300
    Run Keyword If  ${sync_status}
    ...  Log  Synchronization was completed successfully![OK]  console=true
    ...  ELSE
    ...  Fail  Synchronization was not completed successfully![NOK]
    Click Element  //*[contains(@a-text, "Close")]/button


Open Commissioning Wizard Menu
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  This KW Open Commissioning Wizard Menu.

    Log  Open Commissioning Wizard menu will be performed!  console=true
    Wait Until Element Is Visible  ${COMMISIONING_WIZARD}  120
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Clicked  ${COMMISIONING_WIZARD}  120
    Run Keyword If  ${status}
    ...  Log  Commissioning Wizard menu is open!  console=true
    ...  ELSE
    ...  Fail  Commissioning Wizard menu is not open!


Get List Of Specific ALDs Xpath From Site View
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  This KW return the list with specific alds xpath from site view.
    [Arguments]  ${ald_type}

    ${grid_size}  Get Radio Section Grid Size
    ${grid_block_xpath}  Create List
    FOR  ${elements}  IN RANGE  1  ${grid_size}
        ${class_element}  SeleniumLibrary.Get Element Attribute  //*[@id="simplifiedSiteContainer"]/div/div/div[3]/div[${elements}]  class
        Run Keyword If  '${class_element}'=='ald-${ald_type}-grid-element'
        ...  Append To List  ${grid_block_xpath}  //*[@id="simplifiedSiteContainer"]/div/div/div[3]/div[${elements}]
    END
    ${alds_xpath}  Create List
    FOR  ${elements}  IN  @{grid_block_xpath}
        ${status}  Run Keyword And Return Status
        ...  SeleniumLibrary.Get Element Attribute  ${elements}/div[2]/div/div/div[1]/div/div[3]/div  title
        ${cell_id}  Run Keyword If  ${status}
        ...  Append To List  ${alds_xpath}  ${elements}/div[2]/div/div/div[1]/div/div[3]/div
    END

    [Return]  ${alds_xpath}


Verify The Titles From The Specific File
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    [Arguments]  ${file_content}

    ${title_list}  Create List  Severity  Latest appeared  Alarm ID  Alarm name  Fault ID  Fault name  Alarming object
    ...  Current 10s  Last 10s  Current minute  Last minute  Current hour  Last hour  Current day  Last day  All
    FOR  ${title}  IN  @{title_list}
        Should Contain  ${file_content}  ${title}  The file doesn't contain ${title} title![NOK]
        Log  The saved file contains ${title} title![OK]  console=true
    END


Wait Until Element Is Clicked
    [Documentation]
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  This KW waits for Click Element KW to succeeds.
    [Arguments]  ${xpath}  ${retry_timeout}=30s  ${retry_interval}=5s

    Wait Until Keyword Succeeds  ${retry_timeout}  ${retry_interval}
    ...  Click Element  ${xpath}
