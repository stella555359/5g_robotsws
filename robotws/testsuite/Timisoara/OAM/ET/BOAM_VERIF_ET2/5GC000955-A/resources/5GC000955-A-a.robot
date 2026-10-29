*** Settings ***
Documentation
...    Author: Alin Necula (alin.necula@nokia.com)
...    Maintainer: Alin Necula (alin.necula@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC000955-A
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC000955-A/resources/5GC000955-A_QSFP.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        BuiltIn


Resource    ../../resources/admin_infomodel.robot
Resource    ../../resources/admin.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/AirPhone/resources/ute/coam.robot


*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${CONFIRM_BUTTON}=                      //ui-button[@a-text="Confirm"]
${CUSTOMER_LOGIN}=                      Nemuadmin
${CUSTOMER_PASSWORD}=                   nemuuser
${WebEM IP}                             https://192.168.255.1:3600
${INPUT_NAME_FIELD}=                    userName
${INPUT_PASSWORD_FIELD}=                password
${LOGIN_BUTTON}=                        //ui-button[@a-text="Login"]

${path_actCli_feature}=         /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-*/MRBTS_A-*/MNL_A-1/MNLENT_A-1/FEATCADM_A-1
${path_LANE_left}=          /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-1/LANE_R-1
${path_LANE_right}=         /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-18/LANE_R-1
${path_LANE_ABIO}=          /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-1/LANE_R-1

${delta_QSFP_object_create}=            ${CURDIR}/Delta_QSFP_object_create.json
${delta_QSFP_object_delete}=            ${CURDIR}/Delta_QSFP_object_delete.json
${delta_SFP_object_create}=             ${CURDIR}/Delta_SFP_object_create.json
${delta_SFP_object_delete}=             ${CURDIR}/Delta_SFP_object_delete.json
${delta_activate_actCli}=               ${CURDIR}/Delta_Activate_ActCli.json
${delta_deactivate_actCli}=             ${CURDIR}/Delta_Deactivate_ActCli.json
${Delta_lockLane}=                      ${CURDIR}/Delta_lockLane.json
${Delta_unlockLane}=                    ${CURDIR}/Delta_unlockLane.json
${delta_sfpMonitoring_5min}=            ${CURDIR}/Delta_sfpMonitoring_5min.json


${ADMIN_CLI_scripts_path}=              ${CURDIR}/../scripts

${SW_DESTINATION}     /home/ute
${lterel_disc}=   http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
${URL_5G}=    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release


@{sfpMonitoring_tableHeader}=     Link ports	 Link speed   TX supply voltage		TX bias current
...     TX optical power(dBm)	TX optical power(uW)	RX optical power(dBm)	RX optical power(uW)
... 	LCV		BER		Temperature
@{sfpMonitoring_detailsContainer}=    Source: RMOD-1(AEQA)/Q_OPT_IF1     Destination: CABINET-1/BBMOD-1(ABIL)/Q_RF2
...     Hardware parameters     Connection status   Static parameters   Thresholds    Max Transmission Distance
@{sfpMonitoring_hardwareParameters}=   Physical port	Connector type	 Compliance code	Serial number	Product code
... 	Transceiver identifier	Transceiver compliance code	 Vendor	 Vendor part number	 Vendor revision
...     Nokia part number
@{sfpMonitoring_connectionStatus}=  Link type	Bits received (60s interval)	Bit Error Rate (24hr interval)
@{sfpMonitoring_staticParameters}=  SFP wavelength	SFP transmission mode	SFP nominal transmission rate
... 	Manufacturing Date	Diagnostic Monitoring Type
@{sfpMonitoring_staticParameters_trunk}=  SFP wavelength	SFP nominal transmission rate
... 	Manufacturing Date	Diagnostic Monitoring Type
@{sfpMonitoring_thresholds}=    Tx Power High Alarm Threshold	Tx Power High Warning Threshold
...     Tx Power Low Alarm Threshold	Tx Power Low Warning Threshold	 Rx Power High Alarm Threshold
... 	Rx Power High Warning Threshold	 Rx Power Low Alarm Threshold 	Rx Power Low Warning Threshold
... 	Temperature High Alarm Threshold	Temperature Low Alarm Threshold
@{sfpMonitoring_maxTransmissionDistance}=   Max Link Length Type	Length (SMF,km)	Length (SMF)	Length (50um)
... 	Length (62.5um)	 Length (OM4 or copper cable)	Length (OM3)



*** Keywords ***
WebEM User Access Control Permissions for QSFP control and monitor - BTS System Administrator
    #TC is running on CLOUD_5G_KL_AP_NSA_FS_CMWV platform
    Log To Console  +++ Start [TC_02]: QSFP Control and Monitor - BTS System Administrator +++
    Login To Web Element Manager
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=//div[@aria-label="Concentrator Q_RF2"]
    ...    timeout=60
    SELENIUM Mouse Over Visible Element
    ...     locator=//div[@class="details-panel-container"]
    Scroll Element Into View
    ...     locator=//div[@class="lane-info-section section"]
    Element Should Be Enabled
    ...    locator=//button[@class='btn btn-small btn-defaultBlue']
    Log To Console  Lock LANE Button is ENABLED
    SELENIUM Go To SFP Monitoring
    Check QSFP Monitoring Table Header
    SELENIUM Click Visible Element
    ...     locator=//table[@class='sfp-monitoring-table sfp-monitoring-inner-table']
    SELENIUM Mouse Over Visible Element
    ...     locator=//div[@class="details-panel-container"]
    Check QSFP Monitoring Details Container
    Check QSFP Monitoring Hardware Parameters
    Check QSFP Monitoring Connection Status
    Check QSFP Monitoring Static Parameters
    Check QSFP Monitoring Thresholds
    Check QSFP Monitoring Max Transmission Distance
    Close All Connections


QSFP Monitoring
    #TC is running on CLOUD_5G_KL_AP_NSA_FS_CMWV platform
    Log To Console  +++ Start [TC_01]: QSFP Monitoring +++
    ADMIN Perform Delta Recommissioning         ${delta_sfpMonitoring_5min}
    ...                                         skip_parameter_relation_errors=True
    Sleep   300s
    Login To Web Element Manager
    SELENIUM Go To SFP Monitoring
    Check QSFP Monitoring Table Header
    SELENIUM Click Visible Element
    ...     locator=//table[@class='sfp-monitoring-table sfp-monitoring-inner-table']
    SELENIUM Mouse Over Visible Element
    ...     locator=//div[@class="details-panel-container"]
    Check QSFP Monitoring Details Container
    Check QSFP Monitoring Hardware Parameters
    Check QSFP Monitoring Connection Status
    pretest_posttest.Get Software Release
    Run keyword if    '${sw_release}' == 'SBTS00'
    ...      Check QSFP Monitoring Static Parameters 2
    ...      ELSE     Check QSFP Monitoring Static Parameters
    Check QSFP Monitoring Thresholds
    Check QSFP Monitoring Max Transmission Distance
    Check QSFP Monitoring Values
    Close All Connections


Check QSFP Monitoring Table Header
    FOR    ${i}    IN      @{sfpMonitoring_tableHeader}
       Table Header Should Contain    locator=//div[@class='sfp-monitoring-table-container']   expected=${i}
       Log    "${i}" is visible in SFP Monitoring Table Header    console=yes
    END
    Sleep  2s

Check QSFP Monitoring Details Container
    FOR    ${i}    IN      @{sfpMonitoring_detailsContainer}
       Element Should Contain    locator=//div[@class='sfp-details-container']   expected=${i}
       Log    "${i}" is visible in SFP Monitoring Details section    console=yes
    END
    Sleep  2s

Check QSFP Monitoring Hardware Parameters
    FOR    ${i}    IN      @{sfpMonitoring_hardwareParameters}
       Element Should Contain    locator=//div[@class='sfp-details-container']   expected=${i}
       Log    "${i}" is visible in SFP Monitoring Hardware Parameters Table    console=yes
    END
    Sleep  2s

Check QSFP Monitoring Connection Status
    FOR    ${i}    IN      @{sfpMonitoring_connectionStatus}
       Element Should Contain    locator=//div[@class='sfp-details-container']   expected=${i}
       Log    "${i}" is visible in SFP Monitoring Connection Status Table    console=yes
    END
    Sleep  2s

Check QSFP Monitoring Static Parameters
    FOR    ${i}    IN      @{sfpMonitoring_staticParameters}
       Element Should Contain    locator=//div[@class='sfp-details-container']   expected=${i}
       Log    "${i}" is visible in SFP Monitoring Static Parameters Table    console=yes
    END
    Sleep  2s

Check QSFP Monitoring Static Parameters 2
    FOR    ${i}    IN      @{sfpMonitoring_staticParameters_trunk}
       Element Should Contain    locator=//div[@class='sfp-details-container']   expected=${i}
       Log    "${i}" is visible in SFP Monitoring Static Parameters Table    console=yes
    END
    Sleep  2s

Check QSFP Monitoring Thresholds
    FOR    ${i}    IN      @{sfpMonitoring_thresholds}
       Element Should Contain    locator=//div[@class='sfp-details-container']   expected=${i}
       Log    "${i}" is visible in SFP Monitoring Thresholds Table    console=yes
    END
    Sleep  2s

Check QSFP Monitoring Max Transmission Distance
    FOR    ${i}    IN      @{sfpMonitoring_maxTransmissionDistance}
       Element Should Contain    locator=//div[@class='sfp-details-container']   expected=${i}
       Log    "${i}" is visible in SFP Monitoring Max Transmission Distance Table    console=yes
    END
    Sleep  2s

Check QSFP Monitoring Values
    ${sfpMonitoring_value1}=    Get Table Cell
    ...     locator=//table[@class='sfp-monitoring-table sfp-monitoring-inner-table']
    ...     row=5
    ...     column=2
    Log to Console      ${sfpMonitoring_value1}
    Sleep   70s
    ${sfpMonitoring_value2}=    Get Table Cell
    ...     locator=//table[@class='sfp-monitoring-table sfp-monitoring-inner-table']
    ...     row=5
    ...     column=2
    Log to Console      ${sfpMonitoring_value2}
    Run keyword And Ignore Error  Should Not Be Equal     ${sfpMonitoring_value2}     ${sfpMonitoring_value1}



QSFP LANE lock and unlock
    #TC is running on CLOUD_5G_KL_AP_NSA_FS_CMWV platform
    log to console  +++ Start [TC_03]: QSFP LANE lock and unlock +++
    Run Keyword If  '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...    ADMIN INFOMODEL Check Parameter Value
    ...    dist_name=${path_LANE_left}
    ...    dict_param=operationalState
    ...    value=enabled
    Run Keyword If  '${OUT_ADMIN_SMOD_POSITION}' == 'right'
    ...    ADMIN INFOMODEL Check Parameter Value
    ...    dist_name=${path_LANE_right}
    ...    dict_param=operationalState
    ...    value=enabled
    ADMIN Perform Delta Recommissioning         ${Delta_lockLane}
    ...                                         skip_parameter_relation_errors=True
    Run Keyword If  '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...    ADMIN INFOMODEL Check Parameter Value
    ...    dist_name=${path_LANE_left}
    ...    dict_param=operationalState
    ...    value=disabled
    Run Keyword If  '${OUT_ADMIN_SMOD_POSITION}' == 'right'
    ...    ADMIN INFOMODEL Check Parameter Value
    ...    dist_name=${path_LANE_right}
    ...    dict_param=operationalState
    ...    value=disabled
    ADMIN Perform Delta Recommissioning         ${delta_unlockLane}
    ...                                         skip_parameter_relation_errors=True
    Run Keyword If  '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...    ADMIN INFOMODEL Check Parameter Value
    ...    dist_name=${path_LANE_left}
    ...    dict_param=operationalState
    ...    value=enabled
    Run Keyword If  '${OUT_ADMIN_SMOD_POSITION}' == 'right'
    ...    ADMIN INFOMODEL Check Parameter Value
    ...    dist_name=${path_LANE_right}
    ...    dict_param=operationalState
    ...    value=enabled


WebEM shall allow SFP-LANE lock and unlock from capacity plug-in unit in Detailed Site View
    #TC is running on CLOUD_5G_BO_AP_NSA_L1B_ECPRI_CMWV platform
    log to console  +++ Start [TC_03]: Lock/Unlock SFP-LANE from Detailed Site View +++
    Login To Web Element Manager
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=//div[@aria-label="Connector RF1"]
    ...    timeout=60
    Lock SFP-LANE
    ADMIN INFOMODEL Check Parameter Value
    ...    dist_name=${path_LANE_ABIO}
    ...    dict_param=operationalState
    ...    value=disabled
    Unlock SFP-LANE
    ADMIN INFOMODEL Check Parameter Value
    ...    dist_name=${path_LANE_ABIO}
    ...    dict_param=operationalState
    ...    value=enabled
    Close All Connections


Lock SFP-LANE
    SELENIUM Mouse Over Visible Element
    ...     locator=//div[@class="details-panel-container"]
    Scroll Element Into View
    ...     locator=//div[@class="lane-info-section section"]
    SELENIUM Click Visible Element
    ...    locator=//button[@class='btn btn-small btn-defaultBlue']
    ...    timeout=60
    SELENIUM Pop Confirm Lock
    Wait Until Element Is Enabled
    ...    locator=//button[@class='btn btn-small btn-defaultBlue']
    ...    timeout=60


Unlock SFP-LANE
    SELENIUM Click Visible Element
    ...    locator=//button[@class='btn btn-small btn-defaultBlue']
    ...    timeout=60
    SELENIUM Pop Confirm Unlock
    Wait Until Element Is Enabled
    ...    locator=//button[@class='btn btn-small btn-defaultBlue']
    ...    timeout=60


Lock LANE by CLI is performed successfully
    #TC is running on CLOUD_5G_BO_AP_NSA_L1B_ECPRI_CMWV platform
    Log to Console  +++ Start [TC_1]: Lock SFP-LANE via ADMIN_CLI +++
    Activate CLI feature
    Log to Console  Run lockLane_successfully.sh and check error code 0
    ${result}=  Run  ${SW_DESTINATION}/ADMIN_CLI/lockLane_successfully.sh
    Should contain  ${result}   "errorCode": 0
    Log to Console  ... SFP-LANE Locked
    Deactivate CLI feature


Unlock LANE by CLI is performed successfully
    #TC is running on CLOUD_5G_BO_AP_NSA_L1B_ECPRI_CMWV platform
    Log to Console  +++ Start [TC_2]: Unlock SFP-LANE via ADMIN_CLI +++
    Activate CLI feature
    Log to Console  Run unlockLane_successfully.sh and check error code 0
    ${result}=  Run  ${SW_DESTINATION}/ADMIN_CLI/unlockLane_successfully.sh
    Should contain  ${result}   "errorCode": 0
    Log to Console  ... SFP-LANE Unlocked
    Deactivate CLI feature



Create QSFP-LANE Objects
    ADMIN Perform Delta Recommissioning         ${delta_QSFP_object_create}
    ...                                         skip_parameter_relation_errors=True
Delete QSFP-LANE Objects
    ADMIN Perform Delta Recommissioning         ${delta_QSFP_object_delete}
    ...                                         skip_parameter_relation_errors=True

Create SFP-LANE Objects
    ADMIN Perform Delta Recommissioning         ${delta_SFP_object_create}
    ...                                         skip_parameter_relation_errors=True

Delete SFP-LANE Objects
    ADMIN Perform Delta Recommissioning         ${delta_SFP_object_delete}
    ...                                         skip_parameter_relation_errors=True

#========ADMIN_CLI KEYWORDS========#
ADMIN_CLI Suite Setup
    Download ADMIN_CLI Package
    Transfer ADMIN_CLI scripts

Transfer ADMIN_CLI scripts
    Run  cp ${ADMIN_CLI_scripts_path}/* ${SW_DESTINATION}/ADMIN_CLI/
    Run  chmod 777 ${SW_DESTINATION}/ADMIN_CLI/*

Download ADMIN_CLI Package
    [Documentation]    Kw download Common Trunk AdminCLI from disc e.g.:
    ...    https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_9999_210505_000001_ADMIN_CLI.zip
    ${SW_Version}     ADMIN Get Sw Version
    ${is_TrunkBuild}=     Run Keyword and Return Status    Should Contain      ${SW_Version}      _9999_
    ${build_ver}=     Run keyword if
    ...           ${is_Trunk_Build}==True        Replace String Using Regexp    ${SW_Version}    ^SBTS[A-Za-z0-9]+_    SBTS00_
    ...  ELSE     Set variable   ${SW_Version}
    ${release}        Fetch from left   ${build_ver}  _ENB_
    ${fileExists}      Run Keyword and Return Status  OperatingSystem.File Should Exist   ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip
    Run Keyword If     ${fileExists} is False   Run  wget ${lterel_disc}/${release}/${build_ver}_ADMIN_CLI.zip -nv -P ${SW_DESTINATION}
    ${fileExists}      Run Keyword and Return Status  OperatingSystem.File Should Exist   ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip
    Should Be Equal As Strings  ${fileExists}  True
    Run  unzip -o ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip -d ${SW_DESTINATION}/ADMIN_CLI
    Log to Console     Download completed
    [Return]           ${build_ver}_ADMIN_CLI.zip

#Download ADMIN CLI Trunk Load
#    Run       mkdir ${SW_DESTINATION}
#	Set suite variable  ${download_url}  ${URL_5G}/0.800.${CLI_version}/5G_0.800.${CLI_version}_ADMIN_CLI.zip
#    run  wget ${download_url} -P ${SW_DESTINATION}/
#    OperatingSystem.File should exist   path=${SW_DESTINATION}/5G_0.800.${CLI_version}_ADMIN_CLI.zip
#    Run  unzip -o ${SW_DESTINATION}/5G_0.800.${CLI_version}_ADMIN_CLI.zip -d ${SW_DESTINATION}/ADMIN_CLI
#    #Ex:  https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/0.836.1516/5G_0.836.1516_ADMIN_CLI.zip
#    Log to console  Download completed


Activate CLI feature
    ADMIN Perform Delta Recommissioning                 ${delta_activate_actCli}
    ...                                                 skip_parameter_relation_errors=True

Deactivate CLI feature
    ADMIN Perform Delta Recommissioning                 ${delta_deactivate_actCli}
    ...                                                 skip_parameter_relation_errors=True


#=====Selenium WebEM Keywords=====#
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
    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    https://192.168.255.129



Login Credentials SBTS
    [Arguments]    ${webem_username}=${USERNAME}
    ...            ${webem_password}=${PASSWORD}
    Input Text        id=login-username    ${webem_username}
    Input Password    id=login-password    ${webem_password}
    Run Keyword If  '${branch}' == 'SBTS22R2'
    ...     Click Button      locator=//button[@class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"]
    ...     ELSE
    ...     Click Button      locator=//button[@class="p-ripple p-element p-button p-component"]

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


Update Selenium Library
    ${rc}=  Run And Return RC   pip install --upgrade robotframework-seleniumlibrary==3.2.0
    Should Be Equal As Integers     ${rc}   0

