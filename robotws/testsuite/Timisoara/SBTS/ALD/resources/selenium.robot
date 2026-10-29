*** Settings ***
Library  Selenium2Library
Library  taf.sbts.oam.coam.admin  WITH NAME  coam

Documentation
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Internal WRO1 resource library repetitive keywords in multiple tests.
...  ******************
...  History of changes
...  ******************
...  17.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-274 - hotfix in KW "ALD Reset Via WebEM"
...  23.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-387 - Fix of hard/soft reset operations for multiple ALDs
...  24.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-432 - Adap test ALD.30 and ALD.35 to new GUI displayed text
...  24.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-437 - Change logics and extend timeouts in selenium KWs
...  30.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-409 - Change logic in test ALD35. and ALD.34_CB006856_ALD_Read_RAE_sensor
...  04.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-446 - ASOF adaptation for Selenium keywords
...  12.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-472 - Fix for Read_RAE_sensor_telemetry_on_demand_with_radio_reset
...  17.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-473 - Wait for element to be visible after Read sensor data
...  17.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-474 - Change variable TRS to SMOD in selenium.robot
...  21.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-547 - Extend timeout for Read_RAE_sensor_telemetry_on_demand
...  xx.xx.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - xxx
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Variables ***
${webEM_LOGIN}  Nemuadmin
${webEM_PASS}  nemuuser
${SMOD_BBMOD}  SMODs/BBMODs
${ENTER}  \\13
${CW}  Commissioning Wizard
${ALD_SHARING_CONFIG}  ALD Sharing Configuration
${CENTRALIZED_RAE_CONFIG}  Centralized RAE Management
@{DD_LIST_1}  2  7  12
@{DD_LIST_2}  65
@{DD_LIST_3}  1880-1920  2010-2025  2575-2635
${SMOD}  SMOD-1 / SMOD_R
#toggle dropdown button
${CALIBRATE}  //button[@title='Calibrate']
${RESET}  //button[@title='Reset']
${SET_ANGLES}  //button[@title='Set Angles']

#POPUP window
${POPUP_WARN_WINDOW}  //div[@class='modal-dialog n-dialog-warning']
${POPUP_CONF_WINDOW}  //div[@class='modal-dialog n-dialog-confirm']

#POPUP button
${CALIBRATE_BUTTON}  //div[@class="ui-modal"]//button[contains(text(), "Calibrate")]
${SOFTWARE_RESET_BUTTON}  //div[@class="ui-modal"]//button[contains(text(), "Software Reset")]
${HARDWARE_RESET_BUTTON}  //div[@class="ui-modal"]//button[contains(text(), "Hardware Reset")]
${SAVE_BUTTON}  //div[@class="ui-modal"]//button[contains(text(), "Save")]

#tabs
${DETAILED_SITE_VIEW}  //a[.='Detailed Site View']
${SITE_VIEW}  //a[.='Site View']

#detailed site view objects
${ALD_COLUMN}  //div[@class='site-horizontal-lg ALD-column site-column']
${DROPDOWN}  //i[@class='toggle-dropdown-button-icon fa fa-ellipsis-v']
${CONTAINER_HEADER}  //div[@class='bold-header first-line']
${CONTAINER_RETU}  //div[@aria-label='Remote Electrical Tilt Unit 1']
${CONTAINER_LNA1}  //div[@aria-label='Low-noise Amplifier 1']
${CONTAINER_LNA2}  //div[@aria-label='Low-noise Amplifier 2']

#RET Unit Angles Configuration (popup window)
${ANGLE_CONTAINER}  //div[@class='inputs-container']/div[1]/set-angles-parameter-input[1]//input[1]
${MECH_ANGLE_CONTAINER}  //div[@class='inputs-container']/div[2]/set-angles-parameter-input[1]//input[1]
${MIN_ANGLE_CONTAINER}  //div[@class='inputs-container']/div[3]/set-angles-parameter-input[1]//input[1]
${MAX_ANGLE_CONTAINER}  //div[@class='inputs-container']/div[4]/set-angles-parameter-input[1]//input[1]

#ALD Sharing Configuration
${ALD_LIST}  //div[@class='scanned-ald-list-table']
${ALD_ALLOW_LIST}  //div[@class='ald-allowed-list-table']
${HDLC_LIST}  //div[@class='p-datatable p-component p-datatable-responsive-stack']
${GO_TO_CW}  //span[contains(text(),'Go to Commissioning Wizard')]
${ADD_ALD}  //span[contains(text(),'Add')]
${REMOVE_ALD}  //span[contains(text(),'Remove')]
${BUTTON_ENABLED}  //button[@class="p-ripple p-element p-button-neutral p-button-sm p-button p-component"]
${SAVE_CONFIGURATION}  //span[contains(text(),'Save Configuration')]
${GREEN_CHECKBOX}  //i[@class='mdi mdi-checkbox-marked-circle']

#Cetralized RAE Management
${1D_DOWNLOADED}  1D weight factor data downloaded
${GET_BEAMWIDTHS}  //button[contains(text(),"Get Beamwidths")]
${GET_ANGLES}  //button[contains(text(),'Get Angles')]
${ELECTRICAL_TILT_LIST}  //table[@class="rae-one-d-weight-table"]/tbody/tr[1]/td[1]/ui-select/div/wf-dropdown/div/button
${BROADCAST_BEAM_WIDTH}  //table[@class="rae-one-d-weight-table"]/tbody/tr[2]/td[1]/ui-select/div/wf-dropdown/div/button
${FREQUENCY_BAND_1D}  //table[@class="rae-one-d-weight-table"]/tbody/tr[3]/td[1]/ui-select/div/wf-dropdown/div/button
#[@aria-expanded="false"]
${ELECTRICAL_TILT_VALUE}  //span[contains(text(),'12')]
${GET_2D_WEIGHT_FACTORS}  //table[@class="rae-dropdown-table"]//button[contains(text(),'Get Weight Factors')]
${GET_1D_WEIGHT_FACTORS}  //table[@class="rae-one-d-weight-table"]//button[contains(text(),'Get Weight Factors')]
${WEIGHT_DOWNLOADED}  //span[contains(text(),'2D weight factor data downloaded')]
${WEIGHT_FACTORS}  //label[contains(text(),"Weight factors")]
${WEIGHT_FACTORS_TABLE}  //table[@class="ng-scope"]
${1D_WEIGHT_FACTORS_TABLE}  //table[@class="rae-one-d-weight-reasult-table ng-scope"]
${WEIGHT_FACTORS_GROUP}  //span[contains(text(),'group 1')]
${WF_FILE}  //td[contains(text(),'Weight factor file')]
${NO_FILE}  //td[contains(text(),'<No file>')]
${TEST}  //span[@class="ng-item ng-binding"]
${READ_POPUP_BUTTON}  //modal-footer[@class="ng-scope"]/ui-button/button[contains(text(),' Read')]
${RAE_DETAILS_PANEL}  //div[@class="details-panel-container"]/ui-button/button/i[@class="fa fa-list-ul"]
${RAE_properties_table}  //table[@class="details-info-table"]
${READ_SENSOR_DATA}    //button[contains(text(),' Read Sensor Data')]
${READ_SENSOR_DATA_COMPLETE}  //span[contains(text(),'Reading sensor data complete.')]

#top menu bar
${CONFIG}  //span[@ui-tooltip='Configuration']
${ALD_SHARING}  //span[contains(text(),'ALD Sharing Configuration')]
${CENTRALIZED_RAE}  //span[contains(text(),'Centralized RAE Management')]
${PROCEDURES}  //span[contains(text(),'Procedures')]
${POWER_RESET}  //span[contains(text(),'Power Reset')]


*** Keywords ***
####################
### ALD SELENIUM ###
####################
Open Chrome Browser
    [Documentation]  Create instantiate the Chrome browser.
    ...  **Author:** tomasz.marchewka@nokia.com

    ${chrome_options}=  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    ${prefs}  Create Dictionary  download.default_directory=${RESULTS}
    Call Method  ${chrome_options}  add_argument  --no-sandbox
    Call Method  ${chrome_options}  add_argument  --headless
    Call Method  ${chrome_options}  add_argument  --disable-extensions
    Call Method  ${chrome_options}  add_argument  --disable-gpu
    Call Method  ${chrome_options}  add_argument  --ignore-certificate-errors
    Call Method  ${chrome_options}  add_argument  --window-size\=1900,1200
    Call Method  ${chrome_options}  add_experimental_option  prefs  ${prefs}
    Selenium2Library.Create Webdriver  Chrome  chrome_options=${chrome_options}


Login To WebEM
    [Documentation]
    ...  This keyword opens browser session to WebEM.
    ...  **Author:** tomasz.marchewka@nokia.com
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  17.06.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21476

    Selenium2Library.Go To  https://192.168.255.129/#/login
    Wait Until Keyword Succeeds  1m  5s  Selenium2Library.Location Should Be  https://192.168.255.129/#/login
    Selenium2Library.Input Text  login-username  ${webEM_LOGIN}
    Selenium2Library.Input Text  login-password  ${webEM_PASS}
    Selenium2Library.Click Button  Login
    Wait Until Keyword Succeeds  1m  5s  Selenium2Library.Location Should Be  https://192.168.255.129/#/bts-status/site-view
    ${enb_release}  coam.get sw release name
    Log  sw release :${enb_release}  console=True
    ${sw}  coam.Get Sw Version
    Log  active sw :${sw}  console=True
    ${sw_fsm_status}  Run Keyword And Return Status  Should Not Contain  ${sw}  FSM
    IF  ${sw_fsm_status} and '${enb_release}' >= 'SBTS25R1'
      Wait Until Keyword Succeeds  60  5  Selenium2Library.Click Element  //*[contains(text(), 'Accept')]
    ELSE
      Wait Until Keyword Succeeds  60  5  Selenium2Library.Click Element  //*[contains(text(), 'Confirm')]
    END


Check And Resolve Google Chrome And Webdriver Version Compatibility
    [Documentation]
    ...  *AUTHOR* iuliia.taupeka@nokia.com
    ...  This keyword is created as temporary workaround for incompatibility of Google Chome and webdriver version
    ...  Chrome driver installed (older version) to match to the currently installed version of Google Chrome
    ...  23.02.2021 - Iuliia Taupeka. Changes due to TAT-20341 and to resolve issue of incompatibility
    ...  between Google Chrome and webdriver versions.

    ${googlechrome_version}  Run  google-chrome --version
    Log  ${googlechrome_version}
    ${googlechrome_version}  Evaluate  re.search(r'(\\d+)..*', '${googlechrome_version}' ).group(1)  re
    ${googlechrome_version}  Convert To Integer  ${googlechrome_version}
    ${driver_version}  Run  chromedriver --version
    Log  ${driver_version}
    ${driver_version}  Evaluate  re.search(r'(\\d+)..*', '${driver_version}' ).group(1)  re
    ${driver_version}  Convert To Integer  ${driver_version}
    ${install_cmd}  Set Variable  sudo apt install -y --allow-downgrades ute-chromedriver=${googlechrome_version}
    IF  ${googlechrome_version}!=${driver_version}
        Log  Chrome and webdriver versions not compatible, installing webdriver ${googlechrome_version} !
        Run  ${install_cmd}
        Sleep  3s
    ELSE
        Log  Versions are compatible.
        RETURN
    END
    ${driver_version}  Run  chromedriver --version
    ${driver_version}  Evaluate  re.search(r'(\\d+)..*', '${driver_version}' ).group(1)  re
    ${driver_version}  Convert To Integer  ${driver_version}
    IF  ${driver_version}==${googlechrome_version}
        Log  Installation Webriver for chrome ${googlechrome_version} successful!${\n}
    ELSE
        Log  Installation Webriver for chrome ${googlechrome_version} failed!${\n}
        Set Test NoRun  Installation Webriver for chrome ${googlechrome_version} did not succeed!${\n}
    END


ALD Software Reset Via WebEM
    [Documentation]  ALD Software reset procedure for all units via WebEM.
    ...  **Author:** tomasz.marchewka@nokia.com
    [Arguments]  ${ALD_R_RETs}  ${ALD_expected_state_nok}

    Selenium2Library.Wait Until Page Contains  ${SMOD_BBMOD}  timeout=60s
    Selenium2Library.Click Element  xpath=${DETAILED_SITE_VIEW}
    Selenium2Library.Wait Until Page Contains  ${SMOD}  timeout=60s
    Log  \n  console=${true}
    FOR  ${ALD}  IN  @{ALD_R_RETs}
        ${ID}=  Evaluate  re.search(r'ALD_R-(\\d+)','''${ALD}''').group(1)  re
        Log  ALD software reset for ALD_R-${ID}...  console=${true}
        ${ALD_DROPDOWN_BUTTON}  Catenate  SEPARATOR=  //div[@aria-label='Antenna Line Device ${ID}']  ${CONTAINER_HEADER}  ${DROPDOWN}
        Selenium2Library.Mouse Over  xpath=${ALD_DROPDOWN_BUTTON}
        Selenium2Library.Wait Until Element Is Visible  xpath=${ALD_DROPDOWN_BUTTON}  timeout=5s
        Selenium2Library.Click Element  xpath=${ALD_DROPDOWN_BUTTON}
        Selenium2Library.Click Element  xpath=${RESET}
        Selenium2Library.Wait Until Element Is Visible  xpath=${SOFTWARE_RESET_BUTTON}  timeout=60s
        Selenium2Library.Click Button  xpath=${SOFTWARE_RESET_BUTTON}
        Log  Check if ALD achieve state: usageStatus=busy  console=${true}
        Check Dedicated ALD State  ${ALD}  ${ALD_expected_state_nok}
        Log  Check if ALD achieve state: administrativeState=unlocked, operationalState=enabled  console=${true}
        Check Dedicated ALD State  ${ALD}  ${ALD_expected_states}
    END


ALD Hardware Reset Via WebEM
    [Documentation]  ALD Hardware reset procedure for all units via WebEM.
    ...  **Author:** tomasz.marchewka@nokia.com
    [Arguments]  ${ALD_R_RETs}  ${ALD_expected_state_nok}

    Selenium2Library.Wait Until Page Contains  ${SMOD_BBMOD}  timeout=60s
    Selenium2Library.Click Element  xpath=${DETAILED_SITE_VIEW}
    Selenium2Library.Wait Until Page Contains  ${SMOD}  timeout=60s
    Log  \n  console=${true}
    FOR  ${ALD}  IN  @{ALD_R_RETs}
        ${ID}=  Evaluate  re.search(r'ALD_R-(\\d+)','''${ALD}''').group(1)  re
        Log  ALD hardware reset for ALD_R-${ID}...  console=${true}
        ${ALD_DROPDOWN_BUTTON}  Catenate  SEPARATOR=  //div[@aria-label='Antenna Line Device ${ID}']  ${CONTAINER_HEADER}  ${DROPDOWN}
        Selenium2Library.Mouse Over  xpath=${ALD_DROPDOWN_BUTTON}
        Selenium2Library.Wait Until Element Is Visible  xpath=${ALD_DROPDOWN_BUTTON}  timeout=5s
        Selenium2Library.Click Element  xpath=${ALD_DROPDOWN_BUTTON}
        Selenium2Library.Click Element  xpath=${RESET}
        Selenium2Library.Wait Until Element Is Visible  xpath=${HARDWARE_RESET_BUTTON}  timeout=60s
        Selenium2Library.Click Button  xpath=${HARDWARE_RESET_BUTTON}
        Log  Check if ALD achieve state: availabilityStatus=off line, operationalState=disabled  console=${true}
        Check Dedicated ALD State  ${ALD}  ${ALD_expected_state_nok}
        Log  Check if ALD achieve state: administrativeState=unlocked, operationalState=enabled  console=${true}
        Check Dedicated ALD State  ${ALD}  ${ALD_expected_states}
    END


Change RET Angle Via Runtime View
    [Documentation]  Setting new angle value for all RET units via WebEM.
    ...  **Author:** tomasz.marchewka@nokia.com
    [Arguments]  ${ALD_R_RETs}

    Selenium2Library.Wait Until Page Contains  ${SMOD_BBMOD}  timeout=60s
    Selenium2Library.Click Element  xpath=${DETAILED_SITE_VIEW}
    Selenium2Library.Wait Until Page Contains  ${SMOD}  timeout=60s
    ${ret_count}=  Selenium2Library.Get Element Count  xpath=${CONTAINER_RETU}
    Log  \n---------- RET Angle ----------  console=${true}
    FOR  ${ALD}  IN  @{ALD_R_RETs}
        ${ID}=  Evaluate  re.search(r'ALD_R-(\\d+)','''${ALD}''').group(1)  re
        ${RETU_DROPDOWN_BUTTON}  Catenate  SEPARATOR=  //div[@aria-label='Antenna Line Device ${ID}']  //div[@title='RETU-1']  ${DROPDOWN}
        Selenium2Library.Click Element  xpath=${RETU_DROPDOWN_BUTTON}
        Selenium2Library.Click Element  xpath=${SET_ANGLES}
        Selenium2Library.Click Element  xpath=${MIN_ANGLE_CONTAINER}
        ${min_angle}=  Selenium2Library.Get Value  xpath=${MIN_ANGLE_CONTAINER}
	    Selenium2Library.Click Element  xpath=${MAX_ANGLE_CONTAINER}
	    ${max_angle}=  Selenium2Library.Get Value  xpath=${MAX_ANGLE_CONTAINER}
	    ${mech_angle}=  Selenium2Library.Get Value  xpath=${MECH_ANGLE_CONTAINER}
	    ${angle}=  Selenium2Library.Get Value  xpath=${ANGLE_CONTAINER}
        ${new_angle}=  Wait Until Keyword Succeeds  5x  2s  Generate Random RET Angle Value  ${angle}  ${max_angle}  ${min_angle}
	    Selenium2Library.Clear Element Text  xpath=${ANGLE_CONTAINER}
	    Selenium2Library.Input Text  xpath=${ANGLE_CONTAINER}  len(${new_angle})
	    Log  Change for ALD_R-${ID}/RETU_R-1 angle: ${new_angle}°  console=${True}
	    Selenium2Library.Wait Until Element Is Visible  xpath=${SAVE_BUTTON}  timeout=60s
	    Selenium2Library.Click Button  xpath=${SAVE_BUTTON}
        Sleep  80s
        ${ret_param}=  Get RETU Parameters  ${ALD}
        ${read_ret_angle}  ${read_ret_maxAngle}  ${read_ret_minAngle}  ${read_ret_mechanicalAngle}  Get RETU Angles  ${ret_param}
	    IF  ${new_angle}!=${read_ret_angle}
	        Fail  msg=Angle value was not changed correctly on ALD_R-${ID}
	    ELSE
	        Log  Angle value is correctly changed for ALD_R-${ID}/RETU_R-1  console=${True}
	    END
    END


Change RET Mechanical Angle Via Runtime View
    [Documentation]  Setting new mechanical angle value for all RET units via WebEM.
    ...  **Author:** tomasz.marchewka@nokia.com
    [Arguments]  ${ALD_R_RETs}

    Selenium2Library.Wait Until Page Contains  ${SMOD_BBMOD}  timeout=60s
    Selenium2Library.Click Element  xpath=${DETAILED_SITE_VIEW}
    Selenium2Library.Wait Until Page Contains  ${SMOD}  timeout=60s
    Log  \n---------- RET Mechanical Angle ----------  console=${true}
    FOR  ${ALD}  IN  @{ALD_R_RETs}
        ${ID}=  Evaluate  re.search(r'ALD_R-(\\d+)','''${ALD}''').group(1)  re
        ${RETU_DROPDOWN_BUTTON}  Catenate  SEPARATOR=  //div[@aria-label='Antenna Line Device ${ID}']  //div[@title='RETU-1']  ${DROPDOWN}
        Selenium2Library.Click Element  xpath=${RETU_DROPDOWN_BUTTON}
        Selenium2Library.Click Element  xpath=${SET_ANGLES}
        Selenium2Library.Wait Until Element Is Visible  xpath=${POPUP_CONF_WINDOW}  timeout=20s  #"RET Unit Angles Configuration" popup window
        ${mech_angle}=  Selenium2Library.Get Value  xpath=${MECH_ANGLE_CONTAINER}
        ${new_mech_angle}=  Wait Until Keyword Succeeds  5x  2s  Generate Random RET MechanicalAngle Value  ${mech_angle}
        Selenium2Library.Clear Element Text  xpath=${MECH_ANGLE_CONTAINER}
        Selenium2Library.Input Text  xpath=${MECH_ANGLE_CONTAINER}  len(${new_mech_angle})
        Log  Change for ALD_R-${ID}/RETU_R-1 mechanical angle: ${new_mech_angle}°  console=${True}
        Selenium2Library.Wait Until Element Is Visible  xpath=${SAVE_BUTTON}  timeout=60s
        Selenium2Library.Click Button  xpath=${SAVE_BUTTON}
        Sleep  30s
        ${ret_param}=  Get RETU Parameters  ${ALD}
        ${read_ret_angle}  ${read_ret_maxAngle}  ${read_ret_minAngle}  ${read_ret_mechanicalAngle}  Get RETU Angles  ${ret_param}
	    IF  ${new_mech_angle}!=${read_ret_mechanicalAngle}
	        Fail  msg=Mechanical angle value was not changed correctly on ALD_R-${ID}
	    ELSE
	        Log  Mechanical angle value is correctly changed for ALD_R-${ID}/RETU_R-1  console=${True}
	    END
    END


Calibrate RET Via Runtime View
    [Documentation]  Calibration procedure for all RET units via WebEM.
    ...  **Author:** tomasz.marchewka@nokia.com
    [Arguments]  ${ALD_R_RETs}

    Selenium2Library.Wait Until Page Contains  ${SMOD_BBMOD}  timeout=60s
    Selenium2Library.Click Element  xpath=${DETAILED_SITE_VIEW}
    Selenium2Library.Wait Until Page Contains  ${SMOD}  timeout=60s
    Log  \n---------- RET Calibration ----------  console=${true}
    FOR  ${ALD}  IN  @{ALD_R_RETs}
        ${ID}=  Evaluate  re.search(r'ALD_R-(\\d+)','''${ALD}''').group(1)  re
        ${RETU_DROPDOWN_BUTTON}  Catenate  SEPARATOR=  //div[@aria-label='Antenna Line Device ${ID}']  //div[@title='RETU-1']  ${DROPDOWN}
        Selenium2Library.Click Element  xpath=${RETU_DROPDOWN_BUTTON}
        Selenium2Library.Wait Until Element Is Visible  xpath=${CALIBRATE}  timeout=240s
        Selenium2Library.Click Button  xpath=${CALIBRATE}
        Selenium2Library.Wait Until Element Is Visible  xpath=${POPUP_WARN_WINDOW}  timeout=20s  #"Calibrate" popup window
        Selenium2Library.Click Button  xpath=${CALIBRATE_BUTTON}
        Log  ALD_R-${ID}/RETU_R-1 calibrating...  console=${true}
        Sleep  10s
        Check ALDs State  ${ALD_expected_states_idle}
    END


Go To Centralized RAE Management View
    [Documentation]  Go to "Centralized RAE Management View".

    Log to Console  \n Enter Centralized RAE Management View
    Selenium2Library.Wait Until Page Contains  ${SMOD_BBMOD}  timeout=60s
    Selenium2Library.Click Element  xpath=${DETAILED_SITE_VIEW}
    Selenium2Library.Wait Until Page Contains  ${SMOD}  timeout=60s
    Selenium2Library.Click Element  xpath=${CONFIG}
    Selenium2Library.Click Element  xpath=${CENTRALIZED_RAE}
    Selenium2Library.Wait Until Page Contains  ${CENTRALIZED_RAE_CONFIG}  timeout=5s
    Sleep    10s


Go To Centralized RAE Management View New GUI
    [Documentation]  Go to "Centralized RAE Management View".

    Log to Console  \n Enter Centralized RAE Management View
    Selenium2Library.Wait Until Page Contains  ${SMOD_BBMOD}  timeout=60s
    Wait Until Keyword Succeeds  30  5  Selenium2Library.Click Element
    ...  //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[1]/ot-compact-drawer/button/span[1]
    Selenium2Library.Click Element  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Configuration')]
    Selenium2Library.Click Element  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'ALD Management')]
    Selenium2Library.Click Element  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Centralized RAE Management')]
    Selenium2Library.Wait Until Page Contains  ${CENTRALIZED_RAE_CONFIG}  timeout=5s
    Sleep    10s


Go To ALD Sharing Configuration View
    [Documentation]  Go to "ALD Sharing Configuration".

    Selenium2Library.Wait Until Page Contains  ${SMOD_BBMOD}  timeout=60s
    Selenium2Library.Click Element  xpath=${DETAILED_SITE_VIEW}
    Selenium2Library.Wait Until Page Contains  ${SMOD}  timeout=60s
    Selenium2Library.Click Element  xpath=${CONFIG}
    Selenium2Library.Click Element  xpath=${ALD_SHARING}
    Selenium2Library.Wait Until Page Contains  ${ALD_SHARING_CONFIG}  timeout=5s


Go To ALD Sharing Configuration View New GUI
    [Documentation]  Go to "ALD Sharing Configuration".

    Selenium2Library.Wait Until Page Contains  ${SMOD_BBMOD}  timeout=60s
    Wait Until Keyword Succeeds  30  5  Selenium2Library.Click Element
    ...  //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[1]/ot-compact-drawer/button/span[1]
    Selenium2Library.Click Element  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Configuration')]
    Selenium2Library.Click Element  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'ALD Management')]
    Selenium2Library.Click Element  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'ALD Sharing Configuration')]
    Selenium2Library.Wait Until Page Contains  ${ALD_SHARING_CONFIG}  timeout=5s


Capture 2D Weight Factors
    [Documentation]  This keyword captures 2D Weight Factors from RAE device and checks Weight Facotrs table content.

    ${button}  Run Keyword And Return Status  Selenium2Library.Wait Until Element Is Enabled  xpath=${GET_BEAMWIDTHS}  timeout=10s
    ${screenshot}  IF  ${button}  Selenium2Library.Capture Page Screenshot
    ${beamwidths_status}  Run Keyword And Return Status  Selenium2Library.Click Element  xpath=${GET_BEAMWIDTHS}
    IF  ${beamwidths_status}
        Selenium2Library.Wait Until Element Is Enabled  xpath=${GET_ANGLES}  timeout=60s
        Log To Console  Beamwidths
    END
    ${angles_status}  Run Keyword And Return Status  Selenium2Library.Click Element  xpath=${GET_ANGLES}
    IF  ${angles_status}
        Selenium2Library.Wait Until Element Is Enabled  xpath=${GET_2D_WEIGHT_FACTORS}  timeout=20s
        Log To Console  Angles captured
    END
    ${2d_factors_status}=  Run Keyword And Return Status  Selenium2Library.Click Element  xpath=${GET_2D_WEIGHT_FACTORS}
    IF  ${2d_factors_status}
        Selenium2Library.Wait Until Element Is Visible  xpath=${WEIGHT_DOWNLOADED}  timeout=20s
        Log To Console  2D Weight Factors captured
    END
    Run Keyword  Selenium2Library.Capture Page Screenshot
    Sleep  5s


Capture 1D Weight Factors
    [Documentation]  This keyword captures 1D Weight Factors from RAE device and checks Weight Factors table content.

    ${ELECTRICAL_TILT_VALUE}  Evaluate  random.choice(@{DD_LIST_1})  random
    ${BROADCAST_BEAM_WIDTH_VALUE}  Evaluate  random.choice(@{DD_LIST_2})  random
    ${FREQUENCY_BAND_1D_VALUE}  Evaluate  random.choice(@{DD_LIST_3})  random
    Log  \n---------- Getting 1D Weight Factors ----------  console=${true}
    Selenium2Library.Click Element  xpath=${ELECTRICAL_TILT_LIST}
    Selenium2Library.Click Element  //li[@title='${ELECTRICAL_TILT_VALUE}']
    Selenium2Library.Click Element  xpath=${BROADCAST_BEAM_WIDTH}
    Selenium2Library.Click Element  //li[@title='${BROADCAST_BEAM_WIDTH_VALUE}']
    Selenium2Library.Click Element  xpath=${FREQUENCY_BAND_1D}
    Selenium2Library.Click Element  //li[@title='${FREQUENCY_BAND_1D_VALUE}']
    Selenium2Library.Wait Until Element Is Enabled  xpath=${GET_1D_WEIGHT_FACTORS}  timeout=5s
    Selenium2Library.Click Element  xpath=${GET_1D_WEIGHT_FACTORS}
    Sleep    5s
    ${1D_status}  Run Keyword And Return Status  Selenium2Library.Wait Until Page Contains  ${1D_DOWNLOADED}  timeout=10s
    IF  ${1D_status}
        Log To Console  \n 1D weight factor data downloaded.
    ELSE
        Fail  msg=Weight Factors Data is not available
    END


Choose RAE Units With Weight Factor File
    [Documentation]  KW chooses RAE unit from Centralized RAE Management
    ...  **Author:** mateusz.gadek@nokia.com
    [Arguments]  ${ALD_R_RAEs}

    Log  \n Choose REA Units with Weight Factor File  console=${true}
    ${RAE_with_WF_file}=  Create List
    FOR  ${ALD}  IN  @{ALD_R_RAEs}
         ${ID}=  Evaluate  re.search(r'ALD_R-(\\d+)','''${ALD}''').group(1)  re
         ${status}=  Run Keyword And Return Status  Selenium2Library.Page Should Contain Element  xpath=${WF_FILE}
         IF  '${status}'=='True'  Append To List  ${RAE_with_WF_file}  ${ALD}
    END
    ${NR_of_RAE_with_WF_file}=  Get Length  ${RAE_with_WF_file}
    Log  \n You have ${NR_of_RAE_with_WF_file} RAE with Weight Factor file  console=${true}

    RETURN  ${RAE_with_WF_file}


Check Weight Factors Table Content
    [Documentation]  This keyword checks 1D or 2D Weight Factors Table Content - CB006856
    ...  **Author:** mateusz.gadek@nokia.com
    ...  **Example of simple usage:**
    ...
    ...  Check Weight Factors Table Content  1D
    ...
    [Arguments]    ${dimension}

    ${number_of_columns}=  Set Variable If  '${dimension}'=='1D'  4  '${dimension}'=='2D'  5
    ${xpath}=  Set Variable If  '${dimension}'=='1D'  xpath=${1D_WEIGHT_FACTORS_TABLE}
    ...  '${dimension}'=='2D'  xpath=${WEIGHT_FACTORS_TABLE}
    Capture Page Screenshot
    ${data_list}=  Create List
    Selenium2Library.Wait Until Element Is Visible  ${xpath}  timeout=20s
    Log To Console  \n ... Printing samples from the table ...
    FOR  ${i}  IN RANGE  1  ${number_of_columns}
        ${header}  Selenium2Library.Get Table Cell  ${xpath}  1  ${i}
        ${table_cell_value}  Selenium2Library.Get Table Cell  ${xpath}  4  ${i}
        Append To List  ${data_list}  ${table_cell_value}
        Log to console  | ${header} | : | ${table_cell_value} |
    END
    ${data_status}=  Run Keyword And Return Status  Should Not Be Empty  ${data_list}
    IF  ${data_status}
        Log To Console  Weight Factors Data is available in the table
    ELSE
        Fail  msg=Weight Factors Data is not available
    END


Check RAE properties
    ${mechanical_angle}=  Selenium2Library.Get Table Cell  ${RAE_properties_table}  3  2
    ${antenna_bearing}=  Selenium2Library.Get Table Cell  ${RAE_properties_table}  4  2
    ${antenna_latitude}=  Selenium2Library.Get Table Cell  ${RAE_properties_table}  5  2
    ${antenna_longitude}=  Selenium2Library.Get Table Cell  ${RAE_properties_table}  6  2
    ${antenna_altitude}=  Selenium2Library.Get Table Cell  ${RAE_properties_table}  7  2
    Log  \n mechanical_angle: ${mechanical_angle}  console=${true}
    Log  antenna_bearing: ${antenna_bearing}  console=${true}
    Log  antenna_latitude: ${antenna_latitude}  console=${true}
    Log  antenna_longitude: ${antenna_latitude}  console=${true}
    Log  antenna_altitude: ${antenna_altitude}  console=${true}
    ${not_empty_params}=  Set Variable  "${mechanical_angle}"!=[] and "${antenna_bearing}"!=[]
    ${lat_lon_alt}=  Set Variable  "${antenna_latitude}"!=" 0° 0' 0''" and "${antenna_longitude}"!=" 0° 0' 0''" and "${antenna_altitude}"!="0 m"
    IF  ${not_empty_params} and ${lat_lon_alt}
        Log  \n All RAE properties are updated correctly.  console=${true}
    ELSE
        Fail  message=At least one RAE property is missing
    END


Check Button In ALD Sharing Configuration
    [Documentation]  Go to "ALD Sharing Configuration" and check if button "Go to Commissionning Wizard" works.

    ${enb_release}  coam.get sw release name
    Log  sw release :${enb_release}  console=True
    ${sw}  coam.Get Sw Version
    Log  active sw :${sw}  console=True
    ${sw_fsm_status}  Run Keyword And Return Status  Should Not Contain  ${sw}  FSM
    IF  ${sw_fsm_status} and '${enb_release}' >= 'SBTS25R1'
      Go To ALD Sharing Configuration View New GUI
    ELSE
      Go To ALD Sharing Configuration View
    END
    ${button}=  Run Keyword And Return Status  Selenium2Library.Wait Until Element Is Visible  xpath=${GO_TO_CW}  timeout=5s
    ${screenshot}  IF  ${button}  Selenium2Library.Capture Page Screenshot
    ${status}=  Run Keyword And Return Status  Selenium2Library.Click Element  xpath=${GO_TO_CW}
    IF  ${status}
        Selenium2Library.Wait Until Element Is Visible  xpath=${POPUP_CONF_WINDOW}  timeout=10s
        Selenium2Library.Wait Until Page Contains  ${CW}  timeout=10s
        Log To Console  Button "Go to Commissionning Wizard" works properly.
    END


Set ALD Sharing For All Devices
    [Documentation]   Setting ALD Sharing for all ALDs - CB008605 ALD Sharing Management.

    ${enb_release}  coam.get sw release name
    Log  sw release :${enb_release}  console=True
    ${sw}  coam.Get Sw Version
    Log  active sw :${sw}  console=True
    ${sw_fsm_status}  Run Keyword And Return Status  Should Not Contain  ${sw}  FSM
    IF  ${sw_fsm_status} and '${enb_release}' >= 'SBTS25R1'
      Go To ALD Sharing Configuration View New GUI
    ELSE
      Go To ALD Sharing Configuration View
    END
    ${ADD_ALD_BTN_ENABLED}  Catenate  SEPARATOR=  ${ALD_LIST}  ${BUTTON_ENABLED}  ${ADD_ALD}
    ${qty}=  Selenium2Library.Get Element Count  xpath=${ADD_ALD_BTN_ENABLED}
    FOR  ${i}  IN RANGE  ${qty}
        Wait Until Keyword Succeeds  5x  1s  Selenium2Library.Click Element  xpath=${ADD_ALD_BTN_ENABLED}
    END
    Sleep  2s
    ${status}=  Run Keyword And Return Status  Selenium2Library.Click Element  xpath=${SAVE_CONFIGURATION}
    IF  ${status}
        Selenium2Library.Wait Until Element Is Visible  xpath=${GREEN_CHECKBOX}  timeout=60s
        Selenium2Library.Wait Until Page Contains  Success  timeout=60s
        Log To Console  Setting ALD Sharing for all ALDs - DONE
    END


Remove ALD Sharing For All Devices
    [Documentation]  Removing ALD Sharing for all ALDs - CB008605 ALD Sharing Management.

    ${enb_release}  coam.get sw release name
    Log  sw release :${enb_release}  console=True
    ${sw}  coam.Get Sw Version
    Log  active sw :${sw}  console=True
    ${sw_fsm_status}  Run Keyword And Return Status  Should Not Contain  ${sw}  FSM
    IF  ${sw_fsm_status} and '${enb_release}' >= 'SBTS25R1'
      Go To ALD Sharing Configuration View New GUI
    ELSE
      Go To ALD Sharing Configuration View
    END
    ${REMOVE_ALD_BTN_ENABLED}  Catenate  SEPARATOR=  ${ALD_ALLOW_LIST}  ${BUTTON_ENABLED}  ${REMOVE_ALD}
    ${qty}=  Selenium2Library.Get Element Count  xpath=${REMOVE_ALD_BTN_ENABLED}
    FOR  ${i}  IN RANGE  ${qty}
        Wait Until Keyword Succeeds  5x  1s  Selenium2Library.Click Element  xpath=${REMOVE_ALD_BTN_ENABLED}
    END
    Sleep  2s
    ${status}=  Run Keyword And Return Status  Selenium2Library.Click Element  xpath=${SAVE_CONFIGURATION}
    IF  ${status}
        Selenium2Library.Wait Until Element Is Visible  xpath=${GREEN_CHECKBOX}  timeout=60s
        Selenium2Library.Wait Until Page Contains  Success  timeout=60s
        Log To Console  Removing ALD Sharing for all ALDs - DONE
    END


Check ALD Allowed List Table
    [Documentation]  Checking ALD Allowed content table - CB008605 ALD Sharing Management.

    Log To Console  Checking ALD Allowed content table:
    FOR  ${ALD_R_DN}  IN  @{ALD_R_ALL}
        ${ignore}  ${ALD_R}  Split String From Right  ${ALD_R_DN}  separator=/  max_split=1
        ${find_ALD_R}  Catenate  SEPARATOR=  ${ALD_ALLOW_LIST}  //td[contains(text(),'${ALD_R}')]
        Selenium2Library.Page Should Contain Element  xpath=${find_ALD_R}
        Log To Console  - ${ALD_R} into allowed ALDs list
    END


Check ALD HDLC List Table
    [Documentation]  Checking HLDC content table - CB008605 ALD Sharing Management.

    Log To Console  Checking HLDC content table:
    FOR  ${ALD_R_DN}  IN  @{ALD_R_ALL}
        ${ignore}  ${ALD_R}  Split String From Right  ${ALD_R_DN}  separator=/  max_split=1
        ${find_ALD_R}  Catenate  SEPARATOR=  ${HDLC_LIST}  //td[contains(text(),'${ALD_R}')]
        Selenium2Library.Page Should Contain Element  xpath=${find_ALD_R}
        Log To Console  - ${ALD_R} into HDLC list
    END


Get RAE Weight Factors
    [Documentation]  Get RAE 1D Weight factors by choosing Electrical Tilt, Broadcast beam width and Frequency
    ...  from Cetralized RAE Management
    [Arguments]    ${dimension}

    ${RAE_With_Factor_File}=  Choose RAE Units With Weight Factor File  ${ALD_R_RAEs}
    FOR  ${RAE}  IN  @{RAE_With_Factor_File}
        Sleep    5s
        ${ID}=  Evaluate  re.search(r'ALD_R-(\\d+)','''${RAE}''').group(1)  re
        Log to console    \n
        Log  \n Checks for ------- RAE_R-${ID} ----  console=${true}
        IF  '${dimension}'=='1D'
            Capture 1D Weight Factors
        ELSE
            Capture 2D Weight Factors
        END
        Check Weight Factors Table Content  ${dimension}
    END


Read Sensor Data
    [Documentation]  KW reads Sensors data from selected RAE unit
    [Arguments]    ${RAE_for_check}

    ${ignore}  ${ald_r}=  Split String From Right  ${RAE_for_check}  separator=APEQM_R-1/
    Log  RAE for check: ${ald_r}    console=${true}
    Sleep    3s
    Log to console    \n
    Log  Open Details Panel in Centralized RAE Management  console=${true}
    Selenium2Library.Click Element  xpath=${RAE_DETAILS_PANEL}
    Log  \n Reading Sensor Data for ------- ${ald_r} ----  console=${true}
    Selenium2Library.Wait Until Element Is Enabled  xpath=${READ_SENSOR_DATA}  timeout=15s
    Selenium2Library.Click Element  xpath=${READ_SENSOR_DATA}
    Selenium2Library.Click Element  xpath=${READ_POPUP_BUTTON}
    Selenium2Library.Wait Until Element Is Visible  xpath=${READ_SENSOR_DATA_COMPLETE}  timeout=60s
    Check RAE properties


Read Sensor Data New GUI
    [Documentation]  KW reads Sensors data from selected RAE unit
    [Arguments]    ${RAE_for_check}

    ${ignore}  ${ald_r}=  Split String From Right  ${RAE_for_check}  separator=APEQM_R-1/
    Log  RAE for check: ${ald_r}    console=${true}
    Sleep    3s
    Log to console    \n
    Log  Open Details Panel in Centralized RAE Management  console=${true}
    Wait Until Keyword Succeeds  30  5  Selenium2Library.Click Element
    ...  //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[1]/ot-compact-drawer/button/span[1]
    Log  \n Reading Sensor Data for ------- ${ald_r} ----  console=${true}
    Wait Until Keyword Succeeds  60  5  Selenium2Library.Click Element  //*[contains(text(), 'Read Sensor Data')]
    Wait Until Keyword Succeeds  60  5  Selenium2Library.Click Element  //*[contains(text(), 'Read')]
    Check RAE properties


Kill All Instances Of Chrome
    [Documentation]  Killing the Google Chrome instances as a cleanup action for testcases with selenium.

    Run  pkill -9 chrome
