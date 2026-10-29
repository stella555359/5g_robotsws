*** Settings ***
Documentation
...    Author: mateusz.porzucek@nokia.com; piotr.sewerynek@nokia.com
...    Maintainer: margareta.gorczyca@nokia.com
...    Test Description: The scope of this testing activity is to ensure that activation, download and validation of
...    configuration plan works with accordance to the specification
...    Confluence link: link
...    Group in charge: I_MN_RAN_BOAM_PZ_OM_ET_1_GMS <I_MN_RAN_BOAM_PZ_OM_ET_1@internal.nsn.com>
...    References: https://gates.nsn-net.net/view/00021973#o=0
...    QualityCenter: tds://ran_et.mn_ran.qc-prod.ext.net.nokia.com/
...    qcbin/TestLabModule-000000003649890581?EntityType=ITestSet&EntityID=6098
...    Sample execution: pybot --variable CONFIGURATION:Wroclaw.XXX -b debug.log -d /home/ute/results/ /home/ute/Auto5G/
...    testsuite/OAM/ET/BTS_OAM_PDZ/5GC001526-DA/general.robot
...    Review: Marek Lenartowicz
...    AC/REQ: LTE_OPR_REQ_16643; LTE_OPR_REQ_18794; LTE_OPR_REQ_11648
Resource          ../../resources/BOAM_ET/selenium.robot
Resource          ../../resources/hran_frame_taf_oam.robot
Library           String

*** Variables ***
@{SET_BY_SYSTEM}  fUlEarfcn  subfrPShareAllowed  cbsdSerialNumber  addiPdschNarBandNumCatM  grantMaxEirp
...    mbsfnSessionsActive  mpdcchStartSfCssCatM  energySavingState  laaCellKickdownState  mpdcchStartSfUessLev2CatM
...    ulDlConfTD  assignedSrPeriodCatM  autoConHWId  assignedEarfcnUL  supportedNumOfAnrMoi  ulTrmBw  assignedPhichDur
...    assignedRiConfigIndex  puschNarBandNumModeBCatM  autoConSiteId  cbsdCategory  cbsdRegistrationState
...    uMbsfnShareUsed  lastChangeOrigin  eutraCelId  assignedCbsdId  assignedPrachFreqOff  mmeGroupId
...    grantSpectrumFreqLow  adjGnbId  operationalState  assignedNonAnchGuardbandIndexUL  ueActiveTrcSessFlag
...    assignedDeltaPucchShiftCatM  relMmeCap  dayLt  mmeName  sourceOfData  timeStamp  assignedN1PucchAn
...    assignedNCqiRb  cellIndOffNeighDelta  commissioningRequired  puschNarBandNumCatM  reason  longitude
...    pdschNarBandNumCatM  rimStatus  grantSpectrumFreqHigh  dlTrmBw  assignedEarfcnDL  syncAreaInUse
...    assignedN1PucchAnModeBCatM  pMaxLaa  supportedNumOfLnadj  grantId  m3ipAddrSec  ecgiAdjEnbId  cpConfDL  altitude
...    addiMpdcchNarBandNumCatM  mceId  mpdcchStartSfUessLev1CatM  hostingBbPoolId  pagPdschNarBandNumCatM
...    mpdcchStartSfUessCatM  grantChannelType  assignedR10CsiConfIndex2Ri  guGroupIdList
...    assignedNonAnchGuardbandIndexDL  mpdcchNarBandNumModeBCatM  assignedNonAnchInbandPRBIndexDL  assignedNPucchF3Prbs
...    aNBIOTId  ipAddrSec  plmnId  m3LinkStatus  x2ToGnbLinkStatus  grantOperationState  spcSubConfTD  nrStatus
...    pdschNarBandNumModeBCatM  s1LinkStatus  syncSubfrPShareAllowed  assignedDeltaPucchShift  accMmePlmnsList
...    autoConfBlocked  addiPuschNarBandNumCatM  assignedSrOffsetCatM  x2LinkStatus  ltmOff  mpdcchNarBandNumCatM
...    liquidCellCsiRsResInUse    assignedPhichRes  assignedNonAnchInbandPRBIndexUL  autoConfStatus  latitude
...    pagPdschNarBandNumModeBCatM  siNarBandNumCatM  ecgiPlmnId  assignedN1PucchAnCatM  mpdcchStartSfUessLev3CatM
...    adjGnbIdLength  trmBwTD  cpConfUL  mnc  mcc  mncLength

&{SECTION_1}
...    Global cell ID=1
...    Cell name=-
...    Physical layer cell ID=50
...    Cell group=NRCELLGRP-0
...    NR cell ID=16385

&{SECTION_2}
...    Band=n78
...    Cell technology=TDD
...    Expected cell size=5km
...    Maximum output power=26 dBm
...    Downlink MIMO mode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    Energy saving state=notEnergySaving
...    Beamforming enabled=false

&{SECTION_3}
...    Channel bandwidth=100MHz
...    NRARFCN=636666
...    Carrier frequency=3549.990 MHz

&{SECTION_STATUS_4}
...    Operational state=enabled
...    Availability status=-
...    Administrative state=Unlocked
...    Usage state=Active
...    Blocking state=Unblocked
...    Procedural status=configured
...    Barring status=unbarred

&{CHANNEL-2}
...    Channel ID=CHANNEL-2
...    Direction=RX
...    Antenna unit=RMOD-1/PHYANT-1(PHYANT)

&{CHANNEL-3}
...    Channel ID=CHANNEL-3
...    Direction=RX
...    Antenna unit=RMOD-1/PHYANT-1(PHYANT)

&{CHANNEL-6}
...    Channel ID=CHANNEL-6
...    Direction=RX
...    Antenna unit=RMOD-1/PHYANT-1(PHYANT)

&{CHANNEL-8}
...    Channel ID=CHANNEL-8
...    Direction=RX
...    Antenna unit=RMOD-1/PHYANT-1(PHYANT)

&{CHANNEL-1}
...    Channel ID=CHANNEL-1
...    Direction=TX
...    Antenna unit=RMOD-1/PHYANT-1(PHYANT)

&{CHANNEL-4}
...    Channel ID=CHANNEL-4
...    Direction=TX
...    Antenna unit=RMOD-1/PHYANT-1(PHYANT)

&{CHANNEL-5}
...    Channel ID=CHANNEL-5
...    Direction=TX
...    Antenna unit=RMOD-1/PHYANT-1(PHYANT)

&{CHANNEL-7}
...    Channel ID=CHANNEL-7
...    Direction=TX
...    Antenna unit=RMOD-1/PHYANT-1(PHYANT)

${SAVE_BTS_CONFIGURATION_BUTTON}    //button[@ui-tooltip="Save BTS Configuration"]
${SAVE_OPTION_CONF_ONLY}            //label[@for="configuration"]
${SAVE_SCF_BUTTON}                  //ui-button[@a-text="Save"]
${SAVE_SCF_PATH}                    /home/ute/Downloads/Configuration_scf_MRBTS-*

@{PARAMETER_EDITOR_BUTTONS}=           Create Plan    Load SCF...    Fix Errors    Undo Changes    Update Mode
...    Validate Plan    Activate Plan    Save Repor    Save BTS Configuration
@{DEFINITION_ERRORS_BUTTONS}=          Fix Errors    Undo Changes    Update Mode    Validate Plan    Activate Plan
...    Save Report    Save BTS Configuration
@{RELATION_ERRORS_BUTTONS}=            Undo Changes    Update Mode    Validate Plan    Activate Plan    Save Report
...    Save BTS Configuration
@{HARDWARE_ERRORS_BUTTONS}=            Undo Changes    Update Mode    Validate Plan    Activate Plan    Save Report
...    Save BTS Configuration
@{PARAMETERS_TO_DEFINITION_ERRORS}      maxDlHarqTx    maxHarqMsg3Tx
@{MISSING_MANDATORY_PARAM}    actDlDataForwardingX2
@{MISSING_MANDATORY_OBJ}      EQM    APEQM    CABINET
@{SCF_TYPES}              SCF-BTS   FullBTSRuntime    Runtime
@{RUNTIME_SCF_TYPES}      FullBTSRuntime    Runtime
@{DATA_STREAM_OBJECTS}    Cell    Carrier    Radio module    Baseband module    System module
@{LIST_OF_OBJECTS_MANDATORY_PARAM}    EQM-    EQM_R-    HW-    MNL-    NRBTS-    TNLSVC-

${PARAMETER_EDITOR_BUTTON}=             //span[contains(text(),'Parameter Editor')]
${CONFIGURATION_MANAGEMENT_BUTTON}=     //span[contains(text(),'Configuration Management')]
${CONFIGURATION_TAB}=                   //div[@aria-describedby="admin.navigationBar.configuration.TITLE"]
${CURRENT_BTS_CONFIG_BUTTON}=           //ui-expandable-panel-header[contains(text(), 'Current BTS configuration')]
${CURRENT_BTS_CONF}                     //span[contains(text(),"CURRENT_BTS_CONF-1")]
${SEARCH_PARAMETER_EDITOR}=             //div/pe-toolbar/div/ui-text-input/div/input
${PARAMETER_TO_CHANGE_PE_FIELD}=        //tbody/tr[2]/td[4]/parameter-input/div/ui-text-input/div/input
${PARAMETER_TO_CHANGE_PE_FIELD_2}=      //tbody/tr[3]/td[4]/parameter-input/div/ui-text-input/div/input
${PARAMETER_TO_CHANGE_DE_FIELD_1}=
...    //tbody/tr[2]/td[4]/div/definition-errors-correct-value/parameter-input/div/ui-text-input/div/input
${PARAMETER_TO_CHANGE_DE_FIELD_2}=
...    //tbody/tr[3]/td[4]/div/definition-errors-correct-value/parameter-input/div/ui-text-input/div/input
${PARAMETER_TO_CHANGE_DE_FIELD_3}=
...    //tbody/tr[4]/td[4]/div/definition-errors-correct-value/parameter-input/div/ui-text-input/div/input
${PARAMETER_TO_CHANGE_DE_FIELD_4}=
...    //tbody/tr[5]/td[4]/div/definition-errors-correct-value/parameter-input/div/ui-text-input/div/input
${EXCLAMATION_SIGN}=                    //span[@class="fa fa-exclamation-triangle"]
${CHECK_SIGN}=                          //span[@class="fa fa-check"]
${PLANNED_BTS_CONF}=                    //span[starts-with(text(),'CONF-')]
${CLOSE_BUTTON_AFTER_SCF_LOAD}=         //ui-button[@a-text="Close"]
${REMOVE_SCF_ICON}=                     //ui-button[@a-title="Remove object"]
${SUBMIT}=                              //ui-button[@a-text="Submit"]
${LOGIN_OUT_MENU}=                      //i[@class="nav-menu-link-icon ng-scope fa fa-user"]
${LOGIN_OUT_ICON}=                      //ui-button[@a-text="Logout"]
${OPEN_IMS_FILE_BUTTON}=                //div[@class="open-ims2-root"]
${ICON_CLOSE}=                          //i[@class="icon icon-close"]
${DEFINITION_ERROR_IN_PE_BUTTON}=       //div[contains(text(),'Definition Errors')]
${GET_IM_SNAPSHOT}=                     //div[contains(text(), 'Get IM snapshot')]
${CONFIRM_BUTTON}=                      //ui-button[@a-text="Confirm"]
${CUSTOMER_LOGIN}=                      Nemuadmin
${CUSTOMER_PASSWORD}=                   nemuuser
${WebEM IP}                             https://192.168.255.129:3600
${INPUT_NAME_FIELD}=                    login-username
${INPUT_PASSWORD_FIELD}=                login-password
${LOGIN_BUTTON}=                        //span[contains(text(), 'Login')]
${BTS_STATUS_TAB}=                      //div[@aria-describedby="admin.navigationBar.btsStatus.TITLE"]
${SITE_RUTIME_VIEW_BUTTON}=             //span[contains(text(),'Site Runtime View')]
${DETAILED_SITE_VIEW_BUTTON}=           //span[contains(text(),'Detailed Site View')]
${CELLS_BUTTON}=                        //span[contains(text(),'Cells')]
${DATA_STREAMS_BUTTON}=                 //span[contains(text(),'Data Streams')]
${DATA_STREAMS_BY_CELL_BUTTON}=         //span[contains(text(),'Data Streams by Cell')]
${DATA_STREAMS_BY_CARRIER_BUTTON}=      //span[contains(text(),'Data Streams by Carrier')]
${CHANNELS_TABLE}=
...    [@ng-repeat="section in sections | orderBy:'order' track by $index"]//
${ERROR_MESSAGE}=                       Selected configuration plan contains parameter validation errors (5
${FREQ_BAND_INDICATOR}=                 //span[@class="highlight" and contains(text(),'freqBandIndicatorNR')]
${SAVE_BUTTON}=                         //ui-button[@a-text="Save"]
${SAVE_SCF}=                            /home/ute/Downloads/SCF-BTS_Configuration_Only.xml
${PARAMETER_EDITOR_BUTTON_IN_PE}=       //div[contains(text(), 'Parameter Editor')]
${LOAD_SCF_BUTTON}=                     //button[@ui-tooltip="Load site configuration file"]
${LOAD_SCF_INPUT}=                      //div//ui-file-input[@a-text="Load SCF"]//input
#${CLOSE_BUTTON_AFTER_SCF_LOAD}=         //ui-button[@a-text="Close"]
${EXPAND_BUTTON}=                       //i[@ng-if="!isRowALeaf(row)"]
#${PLANNED_BTS_CONF}=                    //span[starts-with(text(),'CONF-')]
#${REMOVE_SCF_ICON}=                     //ui-button[@a-title="Remove object"]
#${SUBMIT}=                              //ui-button[@a-text="Submit"]
${CONNECT_BUTTON}=                      //connection[@class="ng-isolate-scope"]
${SAVE_BTS_CONFIG_MENU}=                //i[@class="fa fa-save"]
#${SAVE_BUTTON}=                         //ui-button[@a-text="Save"]
${FULL_BTS_CONFIG_LABEL}=               //label[@for="configurationAndRuntimeObjects"]
${RUNTIME_LABEL}=                       //label[@for="runtimeObjects"]
${MRBTS_NAVIGATION_PANEL}=
...    //span[@class="gs-row-name"]//highlighter[@class="ng-isolate-scope"]//span[contains(text(),"MRBTS-")]
${EQM_NAVIGATION_PANEL}=                //span[contains(text(),"EQM-")]
${APEQM_NAVIGATION_PANEL}=              //span[contains(text(),"APEQM-")]
${BWP_PROFILE_NAVIGATION_PANEL}=        //span[contains(text(),"BWP_PROFILE-
${NAVIGATION_OBJECT_TREE_PATH}=         //div[starts-with(@class,"ui-expandable-panel-body")]//li
${TRASH_ICON_AFTER_REMOVAL_OBJECT}=     //i[@class="gs-trash-icon ng-scope"]
${REVERT_OBJCT_ICON}=                   //i[@class="fa fa-undo"]
${REMOVE_OBJECT_TRASH_ICON}=            //ui-button[@a-title="Remove object"]
${REMOVE_PARENT}=                       //input[@value="REMOVE_FROM_PARENT"]//following-sibling::label
${REMOVE_WHOLE}=                        //input[@value="REMOVE_ALL_FROM_PLAN"]//following-sibling::label
${PLUS_ADD_OBJECT}=                     //i[@class="fa fa-plus"]
${DROP-DOWN_LIST_ADD_OBJECT}=           //div[contains(text(), 'Object class:')]/following-sibling::div
${OBJECT_ON_LIST_ADD_OBJECT}=           //li[@data-value="MRBTSDESC"]
${NEW_OBJECT_ADDED_ADD_OBJECT}=         //i[@class="gs-modified-icon ng-scope"]
${MRBTSDESC_NAVIGATION_PANEL}=          //span[contains(text(), 'MRBTSDESC-0')]
${COMPARE_OBJECT_BUTTON}                //span[contains(text(),'Compare Objects')]
${CHOOSE_PLAN_COMPARE}
...    //ui-select[@class='select-to-choose-plan ng-isolate-scope']//span[@class='selected-caret']
${CHOOSE_OBJECT_COMPARE}
...    //ui-select[@class='select-to-choose-managed-object ng-isolate-scope']//span[@class='selected-caret']
${MRBTSDESC_EDIT_IN_PE}=
...    //tr[7]/td[4]/instance-id-parameter-input/parameter-input/div/ui-text-input/div/input
${SYSTEM_ENB_LOCAL_IP}=                 192.168.255.129
${SCF_CONF}                             ${PATH}/SCF_CONF.xml
${PATH}                                 ${CURDIR}${/}configurations
#${SCF_CONF}=                            ${PATH}/SCF_CONF.xml
${SCF_DEFINITION_ERRORS_PATH}=          ${PATH}/SCF_DEFINITION_ERRORS_READY.xml
${SCF_SET_BY_SYSTEM_PATH}=              ${PATH}/SCF_SET_BY_SYSTEM.xml
${SCF_MISSING_MANDATORY}=               ${PATH}/SCF_MISSING_MANDATORY.xml
${SCF_RELATION_ERRORS}=                 ${PATH}/SCF_RELATION_ERRORS.xml
${SCF_HIDDEN_PARAM}=                    ${PATH}/SCF_HIDDEN_PARAM.xml
${PREPARED_IMS}=                        ${CURDIR}/Prepared_IMS.ims2
${REL_ERR_IMS}=                         ${CURDIR}/IMS_RELATION_ERRORS.ims2
${INPUT_VALUE}=      0
${FEATCADM_PATH}=
...    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/MNL_CONF_M-1/MNLENT_CONF_M-1/FEATCADM_CONF_M-1

*** Keywords ***
Particular Teardown
    Log    Particular Teardown    console=True
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    CB005752_5GC000235.Particular Teardown

CB005752_5GC000235_Saving_SCF_File_With_Hidden_Parameters_Defined
    Set Library Search Order    SeleniumLibrary
    Login To Web Element Manager
    Go To Parameter Editor
    Saving SCF With Hidden Parameters Defined

Login To Web Element Manager
    [Arguments]    ${login}=${CUSTOMER_LOGIN}
    ...            ${password}=${CUSTOMER_PASSWORD}
    Set Selenium Implicit Wait    5
    Open Browser    ${WebEM IP}
    ...             chrome
    Check Privacy Error
    Proceed Unsafe Connection
    Run Keyword And Ignore Error    Maximize Browser Window
    Input Text    locator=${INPUT_NAME_FIELD}
    ...           text=${login}
    Input Text    locator=${INPUT_PASSWORD_FIELD}
    ...               text=${password}
    Click Element   locator=${LOGIN_BUTTON}
    Wait Until Keyword Succeeds    3x    5 sec    Wait Until Element Is Visible    locator=${CONFIRM_BUTTON}    timeout=40
    Click Element    locator=${CONFIRM_BUTTON}
    ${reload}=    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    locator=//button[contains(text(),'Close')]
    ...    timeout=20
    Run Keyword If    '${reload}' == 'True'    Run Keyword    Click Element
    ...    locator=//button[contains(text(),'Close')]
    ${plug}=    Run Keyword And Return Status    Element Should Be Visible
    ...    locator=//h4[@title="Plug and Play"]
    Run Keyword If    '${plug}' == 'True'    Run Keyword    Click Element
    ...    locator=//button[contains(text(),'Cancel')]

Go To Parameter Editor
    Wait Until Element Is Visible    locator=${CONFIGURATION_TAB}
    ...                              timeout=40
    Click Element   locator=${CONFIGURATION_TAB}
    Wait Until Element Is Visible    locator=${CONFIGURATION_MANAGEMENT_BUTTON}
    ...                              timeout=40
    Mouse Over      locator=${CONFIGURATION_MANAGEMENT_BUTTON}
    Wait Until Element Is Visible    locator=${PARAMETER_EDITOR_BUTTON}
    ...                              timeout=40
    Mouse Over      locator=${PARAMETER_EDITOR_BUTTON}
    Wait Until Element Is Visible    locator=${PARAMETER_EDITOR_BUTTON}
    ...                              timeout=40
    Click Element   locator=${PARAMETER_EDITOR_BUTTON}

Check If Following Buttons Are Availble In Configuration Management Menu Tabs
    FOR    ${BUTTONS}   IN   @{PARAMETER_EDITOR_BUTTONS}
        Wait Until Keyword Succeeds    20
        ...    5
        ...    Element Should Be Visible    locator=//button[contains(text(),' ${BUTTONS}')]
    END
    Click Element    locator=//div[contains(text(),'Definition Errors')]
    FOR    ${BUTTONS}   IN   @{DEFINITION_ERRORS_BUTTONS}
        Element Should Be Visible    locator=//button[contains(text(),' ${BUTTONS}')]
    END
    Click Element    locator=//div[contains(text(),'Relation Errors')]
    FOR    ${BUTTONS}   IN   @{RELATION_ERRORS_BUTTONS}
        Element Should Be Visible    locator=//button[contains(text(),' ${BUTTONS}')]
    END
    Click Element    locator=//div[contains(text(),'Hardware Errors')]
    FOR    ${BUTTONS}   IN   @{HARDWARE_ERRORS_BUTTONS}
        Element Should Be Visible    locator=//button[contains(text(),' ${BUTTONS}')]
    END

Saving SCF With Hidden Parameters Defined
    ${status}    Run Keyword And Return Status    OperatingSystem.Remove File    path=${SAVE_SCF_PATH}
    Click Element    locator=${SAVE_BTS_CONFIGURATION_BUTTON}
    Click Element    locator=${SAVE_OPTION_CONF_ONLY}
    Click Element    locator=${SAVE_SCF_BUTTON}
    OperatingSystem.Wait Until Created    path=${SAVE_SCF_PATH}
    OperatingSystem.File Should Exist    path=${SAVE_SCF_PATH}
    @{HIDDEN_PARAMETERS}=        Create List    frozenOMVersion    frozenOMVersionATT    frozenOMVersionVerizon
    FOR    ${PARAMETERS}   IN   @{HIDDEN_PARAMETERS}
        ${CHECK_PARAMETER_IN_SCF}=    Run    cat ${SAVE_SCF_PATH} | grep -c ${PARAMETERS}
        Run Keyword If    ${CHECK_PARAMETER_IN_SCF} > 0
        ...    FAIL    msg=Parametr ${PARAMETERS} zostal znaleziony
    END

Check Privacy Error
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...                                           xpath=//*[@id="main-message"]/h1
    ...                                           timeout=30
    ${privacy_error}    Run Keyword If    ${status}    Get Text    locator=//*[@id="main-message"]/h1
    ${privacy_error}    Run Keyword And Return Status    Should Contain    ${privacy_error}    is not private
    Run Keyword If    ${privacy_error}    Proceed Unsafe Connection

Proceed Unsafe Connection
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...                                           xpath=//*[@id="details-button"]
    ...                                           timeout=30
    Run Keyword If    ${status}    Click Element  xpath=//*[@id="details-button"]
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...                                           xpath=//*[@id="proceed-link"]
    ...                                           timeout=30
    Run Keyword If    ${status}    Click Element  xpath=//*[@id="proceed-link"]

Perform Reset Configuration
    Go To    url=https://192.168.255.129:3600/#/configuration/configuration-reset
    Click Element    locator=//button[contains(text(),'Execute Reset')]
    Click Element    locator=//button[contains(text(),'Execute') and not(contains(text(),'Execute Reset'))]
    SYSTEM Wait Till Enb Will Not Be Pingable For A Given Period
    ADMIN Assert SMOD Is In Enabled State    timeout=900s
    Login To Web Element Manager
    Wait Until Element Is Visible    locator=//div[contains(text(),'Not commissioned')]
    ...                              timeout=60

ADMIN Assert SMOD Is In Enabled State
    [Arguments]    ${timeout}=600
    Wait Until Keyword Succeeds    ${timeout}    10    ADMIN INFOMODEL Check Parameter Value
    ...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
    ...    dict_param=operationalState
    ...    value=enabled

SYSTEM Wait Till Enb Will Not Be Pingable For A Given Period
    [Arguments]    ${waiting_time}=305
    ...            ${waiting_interval}=5s
    Wait Until Keyword Succeeds    ${waiting_time}    ${waiting_interval}    SYSTEM Check If Enb Is Not Pingable

SYSTEM Check If Enb Is Not Pingable
    SYSTEM Check If Host Is Not Pingable    host_ip_address=${SYSTEM_ENB_LOCAL_IP}

SYSTEM Wait Till Enb Will Be Pingable For A Given Period
    [Arguments]    ${waiting_time}=305
    ...            ${waiting_interval}=5s
    Wait Until Keyword Succeeds    ${waiting_time}    ${waiting_interval}    SYSTEM Check If Enb Is Pingable

SYSTEM Check If Enb Is Pingable
	SYSTEM Check If Host Is Pingable    host_ip_address=${SYSTEM_ENB_LOCAL_IP}

Save Configuration As SCF-BTS Configuration
    ${state}    Run Keyword And Return Status    file should exist     /home/ute/Downloads/Configuration*.xml
    Run Keyword If    ${state}    Run    rm /home/ute/Downloads/Configuration*
    Wait Until Keyword Succeeds    20
    ...    5
    ...    Element Should Be Visible    locator=//button[@ui-tooltip="Save BTS Configuration"]
    Click Element    locator=//button[@ui-tooltip="Save BTS Configuration"]
    Wait Until Element Is Visible    locator=${SAVE_BUTTON}    timeout=30
    Mouse Over    locator=${SAVE_BUTTON}
    Click Element    locator=${SAVE_BUTTON}

Check If Set By System Configuration Are Not Saved In SCF-BTS
    ${scf_path}=    Set Variable    /home/ute/Downloads/Configuration*.xml
    Wait Until Keyword Succeeds    20 sec
    ...                            2 sec
    ...                            OperatingSystem.File Should Exist    ${scf_path}
    Move File    ${scf_path}
    ...          ${SAVE_SCF}
    ${scf}=    XML.PARSE XML    /home/ute/Downloads/SCF-BTS_Configuration_Only.xml
    FOR    ${parameter}    IN    @{SET_BY_SYSTEM}
        ${count}=    XML.Get Element Count    ${scf}    .//p[@name="${parameter}"]
        Set Test Variable    ${count}
        ${status}    Run Keyword And Return Status    Should Be True   "${count}"=="0"
        Run Keyword If    ${status}!=${True}
        ...    Run Keywords    Should Be True    "${parameter}"=="mcc" or "mnc" or "mncLength"    AND
        ...                    Should Be True    "${count}"=="2"
    END

Load Prepared Commissioning Plan
    [Arguments]    ${file_path}=${SAVE_SCF}
    Click Element    locator=${PARAMETER_EDITOR_BUTTON_IN_PE}
    Choose File    locator=${LOAD_SCF_INPUT}
    ...            file_path=${file_path}
    Wait Until Element Is Visible
    ...    locator=//li[@class="ng-scope passed"]//div[contains(text(),'Loading finished')]
    ...    timeout=20
    ${status}     Run Keyword And Return Status    Wait Until Element Is Visible
    ...    locator=${CLOSE_BUTTON_AFTER_SCF_LOAD}
    ...    timeout=20
    Run Keyword If    ${status}==${True}    Click Element    locator=${CLOSE_BUTTON_AFTER_SCF_LOAD}
    Wait Until Element Is Visible   locator=${PLANNED_BTS_CONF}    timeout=20
    Click Element    locator=${PLANNED_BTS_CONF}

Remove Planned SCF After Add Object
    Double Click Element    locator=${PLANNED_BTS_CONF}
    Click Element    locator=${REMOVE_SCF_ICON}
    Click Element    locator=${SUBMIT}

Switch WebEM To Offline Mode
    Click Element    locator=//button[@class="btn minimal-button compact-button dropdown-toggle status-bar-menu-button"]
    Click Element    locator=//a[@class="ng-binding"]

Switch WebEM To Online Mode
    Click Element    locator=//button[@class="btn minimal-button compact-button dropdown-toggle status-bar-menu-button"]
    Click Element    locator=${CONNECT_BUTTON}
    Cancel Plug And Play If Visible
    Wait Until Element Is Visible        locator=//div[@class="connection-status connection-status-online"]
    ...                                  timeout=20
    Close BTS Startup View

Close BTS Startup View
    ${close}=    Run Keyword And Return Status    Element Should Be Visible
    ...    locator=//button[contains(text(),'Close')]
    Run Keyword If    '${close}' == 'True'    Run Keyword    Click Element
    ...    locator=//button[contains(text(),'Close')]

Load Plan Without Activation And With Activation
    Choose File    //configuration-action-buttons//load-action-button//input    ${SCF_CONF}
    Wait Until Element Is Visible
    ...    locator=//i[@class="success-icon"]
    ...    timeout=20s
    Wait Until Element Is Visible
    ...    locator=//li[@class="ng-scope passed"]//div[contains(text(),'Loading finished')]
    ...    timeout=20
    SELENIUM Click Visible Element
    ...    locator=//ui-button[@a-text="Close"]
    Wait Until Keyword Succeeds    20
    ...    5
    ...    SELENIUM Click Visible Element    locator=//ui-button[@a-text="Validate Plan"]
    SELENIUM Click Visible Element
    ...    locator=//ui-button[@a-text="Activate Plan"]
    SELENIUM Click Visible Element
    ...    locator=//span[starts-with(@class,"checkbox-value")]
    SELENIUM Click Visible Element
    ...    locator=//button[text()=' Execute']
    Wait Until Element Is Enabled
    ...    locator=//button[text()=' Close']
    ...    timeout=20s
    Click Element    locator=//button[text()=' Close']
    Wait Until Element Is Visible
    ...    locator=//button[text()=' Activate Plan']
    ...    timeout=20s
    Wait Until Element Is Enabled    locator=//button[text()=' Activate Plan']
    Click Element    locator=//button[text()=' Activate Plan']
    SELENIUM Click Visible Element
    ...    locator=//button[text()=' Execute']

Open Current BTS Configuration In Parameter Editor And Change Parameters
    [Arguments]    ${parameters}=@{PARAMETERS_TO_DEFINITION_ERRORS}
    Close BTS Startup View
    Wait Until Element Is Visible   locator=${CONFIGURATION_TAB}
    Click Element   locator=${CONFIGURATION_TAB}
    Mouse Over  locator=${CONFIGURATION_MANAGEMENT_BUTTON}
    Mouse Over  locator=${PARAMETER_EDITOR_BUTTON}
    Click Element   locator=${PARAMETER_EDITOR_BUTTON}
    Wait Until Keyword Succeeds    20
    ...                            5
    ...                            Element Should Be Visible    locator=${CURRENT_BTS_CONFIG_BUTTON}
    Element Should Be Visible    locator=${CURRENT_BTS_CONF}
    Double Click Element    locator=${CURRENT_BTS_CONF}
    FOR    ${item}    IN    @{parameters}
        Input Text    locator=${SEARCH_PARAMETER_EDITOR}    text=${item}
        Press Keys    ${SEARCH_PARAMETER_EDITOR}    ENTER
        Click Element    locator=${PARAMETER_TO_CHANGE_PE_FIELD}
        Press Keys    ${SEARCH_PARAMETER_EDITOR}    BACKSPACE
        Input Text    locator=${PARAMETER_TO_CHANGE_PE_FIELD}    text=${INPUT_VALUE}
        Click Element    ${PARAMETER_TO_CHANGE_PE_FIELD_2}
        Press Keys    ${PARAMETER_TO_CHANGE_PE_FIELD_2}    BACKSPACE
        Input Text    locator=${PARAMETER_TO_CHANGE_PE_FIELD_2}    text=${INPUT_VALUE}
        Click Element    locator=${ICON_CLOSE}
    END
    Click Element   locator=${DEFINITION_ERROR_IN_PE_BUTTON}

Prepare Definition Errors In Current Configuration
    [Arguments]    @{parameters}
    Set Test Variable    ${INPUT_VALUE}    -1
    Open Current BTS Configuration in Parameter Editor And Change Parameters
    ...    parameters=${parameters}

Fixing Errors In Definition Error Panel
    Page Should Contain Element    locator=${EXCLAMATION_SIGN}
    ...                           limit=4
    Click Element    locator=${PARAMETER_TO_CHANGE_DE_FIELD_1}
    Press Keys    ${PARAMETER_TO_CHANGE_DE_FIELD_1}    BACKSPACE
    Input Text    locator=${PARAMETER_TO_CHANGE_DE_FIELD_1}    text=5
    Click Element    locator=${PARAMETER_TO_CHANGE_DE_FIELD_2}
    Press Keys    ${PARAMETER_TO_CHANGE_DE_FIELD_2}    BACKSPACE
    Input Text    locator=${PARAMETER_TO_CHANGE_DE_FIELD_2}    text=5
    Click Element    locator=${PARAMETER_TO_CHANGE_DE_FIELD_3}
    Press Keys    ${PARAMETER_TO_CHANGE_DE_FIELD_3}    BACKSPACE
    Input Text    locator=${PARAMETER_TO_CHANGE_DE_FIELD_3}    text=5
    Click Element    locator=${PARAMETER_TO_CHANGE_DE_FIELD_4}
    Press Keys    ${PARAMETER_TO_CHANGE_DE_FIELD_4}    BACKSPACE
    Input Text    locator=${PARAMETER_TO_CHANGE_DE_FIELD_4}    text=5
    Page Should Contain Element    locator=${CHECK_SIGN}
    ...                           limit=4

Loading SCF
    [Arguments]    ${SCF_path}
    Loading SCF with Definition Errors    scf_path=${SCF_path}
    Element Should Be Visible    locator=${PLANNED_BTS_CONF}
    Click Element    locator=${PLANNED_BTS_CONF}

Loading SCF With Definition Errors
    [Arguments]   ${scf_path}
    Click Element    locator=${PARAMETER_EDITOR_BUTTON_IN_PE}
    Choose File    locator=//div//ui-file-input[@a-text="Load SCF"]//input
    ...            file_path=${scf_path}
    Wait Until Element Is Visible
    ...    locator=//li[@class="ng-scope passed"]//div[contains(text(),'Loading finished')]
    ...    timeout=20
	Wait Until Element Is Visible    locator=${CLOSE_BUTTON_AFTER_SCF_LOAD}
	...                              timeout=10
	Click Element    locator=${CLOSE_BUTTON_AFTER_SCF_LOAD}

Remove Planned SCF
    Click Element    locator=${REMOVE_SCF_ICON}
    Click Element    locator=${SUBMIT}

Log Off Web Element Manager And Log In
    [Arguments]    ${login}=${CUSTOMER_LOGIN}
    ...            ${password}=${CUSTOMER_PASSWORD}
    Click Element    locator=${LOGIN_OUT_MENU}
    Mouse Over    locator=${LOGIN_OUT_ICON}
    Click Element    locator=${LOGIN_OUT_ICON}
    Clear Element Text    locator=${INPUT_NAME_FIELD}
    Input Text    locator=${INPUT_NAME_FIELD}
    ...           text=${login}
    Input Password    locator=${INPUT_PASSWORD_FIELD}
    ...               password=${password}
    Click Element   locator=${LOGIN_BUTTON}
    Wait Until Element Is Visible    locator=${CONFIRM_BUTTON}    timeout=60
    Click Element    locator=${CONFIRM_BUTTON}

Load Prepared IMS File
    [Arguments]    ${file}=${PREPARED_IMS}
    ...            ${file_name}=Prepared_IMS
    Click Element    locator=//button[@class="btn minimal-button compact-button dropdown-toggle status-bar-menu-button"]
    Wait Until Element Is Visible    locator=${OPEN_IMS_FILE_BUTTON}
    Click Element    locator=${OPEN_IMS_FILE_BUTTON}
    Set Selenium Implicit Wait    10
    Choose File    locator=${OPEN_IMS_FILE_BUTTON}//input
    ...            file_path=${file}
    Wait Until Element Is Visible
    ...    locator=//span[@class="status-bar-small-text ng-binding" and contains(text(), '${file_name}.ims2')]
    ...    timeout=30

Fixing Errors In Definition Error Panel In Offline Mode
    Wait Until Keyword Succeeds
    ...    20
    ...    5
    ...    Element Should Be Visible    locator=${CURRENT_BTS_CONF}
    Double Click Element    locator=${CURRENT_BTS_CONF}
    FOR    ${item}    IN    @{PARAMETERS_TO_DEFINITION_ERRORS}
        Input Text    locator=${SEARCH_PARAMETER_EDITOR}    text=${item}
        Press Keys    ${SEARCH_PARAMETER_EDITOR}    ENTER
        Click Element    locator=${PARAMETER_TO_CHANGE_PE_FIELD}
        Press Keys    ${SEARCH_PARAMETER_EDITOR}    BACKSPACE
        Input Text    locator=${PARAMETER_TO_CHANGE_PE_FIELD}    text=0
        Click Element    ${PARAMETER_TO_CHANGE_PE_FIELD_2}
        Press Keys    ${PARAMETER_TO_CHANGE_PE_FIELD_2}    BACKSPACE
        Input Text    locator=${PARAMETER_TO_CHANGE_PE_FIELD_2}    text=0
        Click Element    locator=${ICON_CLOSE}
    END
    Click Element   locator=${DEFINITION_ERROR_IN_PE_BUTTON}

Check Saved Configuration
    ${state}    Run Keyword And Return Status    OperatingSystem.File Should Exist
    ...    /home/ute/Downloads/*Configuration*.xml
    Run Keyword If    ${state}    Run    rm /home/ute/Downloads/*Configuration*
    FOR    ${type}    IN    @{SCF_TYPES}
        Run Keyword If    '${type}'=='SCF-BTS'    Save Configuration As SCF-BTS Configuration
        ...    ELSE IF    '${type}'=='Runtime'    Save Configuration As Runtime Configuration
        ...    ELSE IF    '${type}'=='FullBTSRuntime'    Save Configuration As FullBTSRuntime Configuration
        Run Keyword If    '${type}' == 'Runtime'    Check If Runtime Configuration Is Collected
        ...               ELSE    Check If ${type} Configuration Is Collected And Parameters Are Changed
    END

Save Configuration As Runtime Configuration
    Click Element    locator=${SAVE_BTS_CONFIG_MENU}
    Mouse Over    locator=${RUNTIME_LABEL}
    Click Element    locator=${RUNTIME_LABEL}
    Mouse Over    locator=${SAVE_BUTTON}
    Click Element    locator=${SAVE_BUTTON}

Save Configuration As FullBTSRuntime Configuration
    Click Element    locator=${SAVE_BTS_CONFIG_MENU}
    Mouse Over    locator=${FULL_BTS_CONFIG_LABEL}
    Click Element    locator=${FULL_BTS_CONFIG_LABEL}
    Mouse Over    locator=${SAVE_BUTTON}
    Click Element    locator=${SAVE_BUTTON}

Check If Runtime Configuration Is Collected
    ${scf_path}=    Set Variable    /home/ute/Downloads/Runtime_Configuration*.xml
    Wait Until Keyword Succeeds    20 sec
    ...                            2 sec
    ...                            OperatingSystem.File Should Exist    ${scf_path}
    Run    rm -rf /home/ute/Downloads/Runtime_Configuration*.xml

Check If FullBTSRuntime Configuration Is Collected And Parameters Are Changed
    ${scf_path}=    Set Variable    /home/ute/Downloads/Full_Configuration*.xml
    Wait Until Keyword Succeeds    20 sec
    ...                            2 sec
    ...                            OperatingSystem.File Should Exist    ${scf_path}
    Run    mv ${scf_path} ${CURDIR}/BTS_Runtime_Configuration.xml
    ${scf}=    XML.PARSE XML    ${CURDIR}/BTS_Runtime_Configuration.xml
    FOR    ${parameter}    IN    @{PARAMETERS_TO_DEFINITION_ERRORS}
        @{first}=    Get Elements Texts    ${scf}    .//p[@name="${parameter}"]
        Should Be Equal    @{first}[0]    0
        Should Be Equal    @{first}[1]    0
    END
    Run    rm -rf ${CURDIR}/BTS_Runtime_Configuration.xml

Check If SCF-BTS Configuration Is Collected And Parameters Are Changed
    ${scf_path}=    Set Variable    /home/ute/Downloads/Configuration*.xml
    Wait Until Keyword Succeeds    20 sec
    ...                            2 sec
    ...                            OperatingSystem.File Should Exist    ${scf_path}
    Run    mv ${scf_path} /home/ute/Downloads/SCF-BTS_Configuration_Only.xml
    ${scf}=    XML.PARSE XML    /home/ute/Downloads/SCF-BTS_Configuration_Only.xml
    FOR    ${parameter}    IN    @{PARAMETERS_TO_DEFINITION_ERRORS}
        ${first}=    Get Elements Texts    ${scf}    .//p[@name="${parameter}"]
        Should Be Equal    ${first[0]}    0
        Should Be Equal    ${first[1]}    0
    END
    Run    rm -rf /home/ute/Downloads/SCF-BTS_Configuration_Only.xml

Collect IMS
    [Arguments]    ${file_name}
    coam.Collect Im Snapshot
    ...    target_file_name=${CURDIR}/${file_name}.ims2
    ...    timeout=30
    ...    alias=admin_1

Configure Test Line To Onair
    ${vlanId}=    Run    cat /home/ute/testline_init_results/configs/*/__init__.py | grep -m1 -o vlan_id=.[0-9]*
    ${vlanId}=    Fetch From Right      ${vlanId}    vlan_id=
    ADMIN Perform Parameter Recommissioning    dist_name=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
    ...    parameter=vlanId
    ...    value=${vlanId}
    ...    operation=update
    Run    chmod 777 ${CURDIR}/onair_setup.sh
    Run    ${CURDIR}/onair_setup.sh
    Wait Until Keyword Succeeds    200
    ...                            5
    ...                            ADMIN INFOMODEL Check If BTS Is OnAir

Add Current MRBTS Object And Check If Object Is Managable In Parameter Editor
    Wait Until Element Is Visible    locator=${MRBTS_NAVIGATION_PANEL}
    Click Element    locator=${MRBTS_NAVIGATION_PANEL}
    Wait Until Element Is Visible    locator=${PLUS_ADD_OBJECT}
    Click Element    locator=${PLUS_ADD_OBJECT}
    Click Element    locator=${DROP-DOWN_LIST_ADD_OBJECT}
    Wait Until Element Is Visible    locator=${OBJECT_ON_LIST_ADD_OBJECT}
    Click Element    locator=${OBJECT_ON_LIST_ADD_OBJECT}
    Click Element    locator=${SUBMIT}
    Element Should Be Visible    locator=${NEW_OBJECT_ADDED_ADD_OBJECT}
    Element Should Be Visible    locator=${MRBTSDESC_NAVIGATION_PANEL}
    Element Should Be Visible    locator=${MRBTSDESC_EDIT_IN_PE}
    Click Element    locator=${MRBTSDESC_EDIT_IN_PE}
    ${old_value}=    Get Value    locator=${MRBTSDESC_EDIT_IN_PE}
    Press Keys    ${MRBTSDESC_EDIT_IN_PE}   BACKSPACE
    Input Text    locator=${MRBTSDESC_EDIT_IN_PE}   text=5
    ${new_value}=    Get Value    locator=${MRBTSDESC_EDIT_IN_PE}
    Should Not Be Equal    ${old_value}    ${new_value}

Add Current MRBTS Object And Check If Object Is Managable In Parameter Editor Offline
    Wait Until Keyword Succeeds
    ...    25
    ...    5
    ...    Element Should Be Visible    locator=${EXPAND_BUTTON}
    Click Element   locator=${EXPAND_BUTTON}
    Add Current MRBTS Object And Check If Object Is Managable In Parameter Editor

Open Current BTS Configuration In Parameter Editor
    Close BTS Startup View
    Check And Cancel Plug And Play Popup
    Wait Until Element Is Visible   locator=${CONFIGURATION_TAB}
    Click Element   locator=${CONFIGURATION_TAB}
    Mouse Over  locator=${CONFIGURATION_MANAGEMENT_BUTTON}
    Mouse Over  locator=${PARAMETER_EDITOR_BUTTON}
    Click Element   locator=${PARAMETER_EDITOR_BUTTON}
    Wait Until Keyword Succeeds    20
        ...    5
        ...    Element Should Be Visible    locator=${CURRENT_BTS_CONFIG_BUTTON}
    Element Should Be Visible    locator=${CURRENT_BTS_CONF}
    Click Element    locator=${EXPAND_BUTTON}

Check And Cancel Plug And Play Popup
    ${status}=    Run Keyword And Return Status
    ...           Element Should Be Visible
    ...           locator=//h4[contains(text(),'Plug and Play')]
    Run Keyword If    '${status}'=='True'
    ...               Cancel Plug And Play If Visible

Cancel Plug And Play If Visible
    [Documentation]    In case of multiple Plug And Play popups appear
    ${popups}=    Get WebElements    //h4[contains(text(),'Plug and Play')]
    FOR    ${index}    IN    @{popups}
        Click Element   locator=//ui-button[@a-text="Cancel"]
    END

Add Planned MRBTS Object And Check If Object Is Managable In Parameter Editor
    Double Click Element    locator=${PLANNED_BTS_CONF}
    Add Planned MRBTS Object

Add Planned MRBTS Object
    Click Element    locator=${MRBTS_NAVIGATION_PANEL}
    Click Element    locator=${PLUS_ADD_OBJECT}
    Click Element    locator=${DROP-DOWN_LIST_ADD_OBJECT}
    Wait Until Element Is Visible    locator=${OBJECT_ON_LIST_ADD_OBJECT}
    Click Element    locator=${OBJECT_ON_LIST_ADD_OBJECT}
    Click Element    locator=${SUBMIT}
    Element Should Be Visible    locator=${NEW_OBJECT_ADDED_ADD_OBJECT}
    Element Should Be Visible    locator=${MRBTSDESC_NAVIGATION_PANEL}
    Click Element    locator=${PARAMETER_EDITOR_BUTTON_IN_PE}
    Element Should Be Visible    locator=${MRBTSDESC_EDIT_IN_PE}
    Click Element    locator=${MRBTSDESC_EDIT_IN_PE}
    ${old_value}=    Get Value    locator=${MRBTSDESC_EDIT_IN_PE}
    Press Keys    ${MRBTSDESC_EDIT_IN_PE}   BACKSPACE
    Input Text    locator=${MRBTSDESC_EDIT_IN_PE}   text=5
    ${new_value}=    Get Value    locator=${MRBTSDESC_EDIT_IN_PE}
    Should Not Be Equal    ${old_value}    ${new_value}

Add Planned MRBTS Object And Check If Object Is Managable In Parameter Editor Offline
    Double Click Element    locator=${PLANNED_BTS_CONF}
    Add Planned MRBTS Object

Try To Remove And Revert Removable Object
    Wait Until Keyword Succeeds    30
    ...                            5
    ...                            Element Should Be Visible    locator=${CURRENT_BTS_CONF}
    Click Element   locator=//i[@ng-if="!isRowALeaf(row)"]
    Wait Until Element Is Visible    locator=${MRBTS_NAVIGATION_PANEL}
    ...    timeout=10
    Click Element    locator=${NAVIGATION_OBJECT_TREE_PATH}\[2]//following::li//i[@ng-if="!isRowALeaf(row)"]
    Wait Until Element Is Visible
    ...    locator=${NAVIGATION_OBJECT_TREE_PATH}\[3]//following::li//i[@ng-if="!isRowALeaf(row)"]
    ...    timeout=20
    Click Element   locator=${NAVIGATION_OBJECT_TREE_PATH}\[3]//following::li//i[@ng-if="!isRowALeaf(row)"]
    Wait Until Element Is Visible    locator=${APEQM_NAVIGATION_PANEL}
    Click Element   locator=${APEQM_NAVIGATION_PANEL}
    Wait Until Element Is Visible    locator=${REMOVE_OBJECT_TRASH_ICON}
    Click Element    locator=${REMOVE_OBJECT_TRASH_ICON}
    Element Should Be Visible    locator=${SUBMIT}
    Click Element    locator=${SUBMIT}
    Click Element    locator=${APEQM_NAVIGATION_PANEL}
    Element Should Be Visible    locator=${TRASH_ICON_AFTER_REMOVAL_OBJECT}
    Click Element    locator=${REVERT_OBJCT_ICON}
    Click Element    locator=${SUBMIT}

Try To Remove Not Removable Object
    Click Element   locator=${EQM_NAVIGATION_PANEL}
    Click Element    locator=${REMOVE_OBJECT_TRASH_ICON}
    Element Should Not Be Visible   locator=${SUBMIT}

Try To Remove Not Removable Object In Offline Mode
    Double Click Element   locator=${PLANNED_BTS_CONF}
    Wait Until Element Is Visible    locator=${MRBTS_NAVIGATION_PANEL}
    ...    timeout=10
    Click Element    locator=${MRBTS_NAVIGATION_PANEL}
    Double Click Element   locator=${MRBTS_NAVIGATION_PANEL}
    Click Element   locator=${EQM_NAVIGATION_PANEL}
    Click Element    locator=${REMOVE_OBJECT_TRASH_ICON}
    Element Should Be Visible   locator=${SUBMIT}
    Click Element    locator=${SUBMIT}
    Element Should Not Be Visible    locator=${EQM_NAVIGATION_PANEL}

Remove All Objects Of Selected Class
    [Arguments]     ${remove_type}
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...                                           locator=${BWP_PROFILE_NAVIGATION_PANEL}1")]
    ...                                           timeout=10
    Run Keyword If    '${status}' == 'False'
    ...    Click Element    locator=${NAVIGATION_OBJECT_TREE_PATH}\[9]//following::li//i[@ng-if="!isRowALeaf(row)"]
    Click Element    locator=${BWP_PROFILE_NAVIGATION_PANEL}1")]
    Click Element    locator=${REMOVE_OBJECT_TRASH_ICON}
    Wait Until Element Is Visible   locator=${REMOVE_TYPE}
    Click Element    locator=${REMOVE_TYPE}
    Click Element    locator=${SUBMIT}
    Click Element    locator=${BWP_PROFILE_NAVIGATION_PANEL}1")]
    Element Should Be Visible    locator=${TRASH_ICON_AFTER_REMOVAL_OBJECT}
    Click Element    locator=${REVERT_OBJCT_ICON}
    Element Should Be Visible    locator=${SUBMIT}
    Click Element    locator=${SUBMIT}
    Click Element    locator=${BWP_PROFILE_NAVIGATION_PANEL}20")]
    Element Should Be Visible    locator=${TRASH_ICON_AFTER_REMOVAL_OBJECT}
    Click Element    locator=${REVERT_OBJCT_ICON}
    Element Should Be Visible    locator=${SUBMIT}
    Click Element    locator=${SUBMIT}

Undo Changes
    Element Should Be Visible    locator=//ui-button[@a-title="Undo Changes"]
    Click Element    locator=//ui-button[@a-title="Undo Changes"]
    ${ok_button}=    Run Keyword And Return Status    Wait Until Element Is Visible    locator=//ui-button[@a-text="Ok"]
    Run Keyword If    '${ok_button}' == 'True'    Run Keyword    Click Element    locator=//ui-button[@a-text="Ok"]

Save Configuration Files
    ${state}    Run Keyword And Return Status    OperatingSystem.File Should Exist
    ...    /home/ute/Downloads/*Configuration*.xml
    Run Keyword If    ${state}    Run    rm /home/ute/Downloads/*Configuration*
    FOR    ${type}    IN    @{RUNTIME_SCF_TYPES}
        Log To Console    ${type}
        Run Keyword If    '${type}'=='Runtime'    Save Configuration As Runtime Configuration
        ...    ELSE IF    '${type}'=='FullBTSRuntime'    Save Configuration As FullBTSRuntime Configuration
        Run Keyword    Check If ${type} Configuration Is Collected And Set By System Parameters Are Saved
    END

Check If Set By System Configuration Are Imported
    Click Element    locator=${PARAMETER_EDITOR_BUTTON_IN_PE}
    Click Element    locator=${LOAD_SCF_BUTTON}
    Choose File    locator=${LOAD_SCF_INPUT}
    ...            file_path=${SCF_SET_BY_SYSTEM_PATH}
    Wait Until Element Is Visible
    ...    locator=//li[@class="ng-scope passed"]//div[contains(text(),'Loading finished')]
    ...    timeout=20
    Element Should Be Visible    locator=//span[contains(text(),'Can be only set by system.')]
    Wait Until Element Is Enabled    locator=${CLOSE_BUTTON_AFTER_SCF_LOAD}    timeout=20s
    Click Element    locator=${CLOSE_BUTTON_AFTER_SCF_LOAD}
    Wait Until Element Is Visible    locator=${PLANNED_BTS_CONF}    timeout=20s
    Click Element    locator=${PLANNED_BTS_CONF}

Check If FullBTSRuntime Configuration Is Collected And Set By System Parameters Are Saved
    ${scf_path}=    Set Variable    /home/ute/Downloads/Full_Configuration*.xml
    Wait Until Keyword Succeeds    20 sec
    ...                            2 sec
    ...                            OperatingSystem.File Should Exist    ${scf_path}
    Run    mv ${scf_path} /home/ute/Downloads/BTS_Runtime_Configuration.xml
    ${scf}=    XML.PARSE XML    /home/ute/Downloads/BTS_Runtime_Configuration.xml
    Check Configuration With Set By System Parameters    scf=${scf}
    Run    rm -rf /home/ute/Downloads/BTS_Runtime_Configuration.xml

Check If Runtime Configuration Is Collected And Set By System Parameters Are Saved
    ${scf_path}=    Set Variable    /home/ute/Downloads/Runtime_Configuration*.xml
    Wait Until Keyword Succeeds    20 sec
    ...                            2 sec
    ...                            OperatingSystem.File Should Exist    ${scf_path}
    Run    mv ${scf_path} /home/ute/Downloads/Runtime_Configuration.xml
    ${scf}=    XML.PARSE XML    /home/ute/Downloads/Runtime_Configuration.xml
    Check Configuration With Set By System Parameters    scf=${scf}
    Run    rm -rf /home/ute/Downloads/Runtime_Configuration*.xml

Check Configuration With Set By System Parameters
    [Arguments]    ${scf}
    @{Active_SBS}    Create List
    @{Rest_SBS}    Create List
    @{all_p}    Get Elements    ${scf}    .//p
    @{all_p_names}    Create List
    FOR    ${elem}    IN    @{all_p}
        ${p_name}    XML.Get Element Attribute    ${elem}    name
        Append To List    ${all_p_names}    ${p_name}
    END
    FOR    ${parameter}    IN    @{SET_BY_SYSTEM}
        ${status}    Run Keyword And Return Status    Should Contain    ${all_p_names}    ${parameter}
        Run Keyword If    '${status}' == 'True'    Run Keyword    Append To List    ${Active_SBS}    ${parameter}
        ...                                     ELSE    Run Keyword    Append To List    ${Rest_SBS}    ${parameter}
    END

Open Simplifed Site View
    Wait Until Element is Visible   locator=${BTS_STATUS_TAB}
    Click Element   locator=${BTS_STATUS_TAB}
    Click Element  locator=${SITE_RUTIME_VIEW_BUTTON}

Select Cell And Check Channel Relation
    Click Element  locator=//div[@class="cell-content"]//div[contains(text(),'1')]
    Element Should Be Visible    locator=//div[@class="relation"]
    Element Should Be Visible    locator=//div[@class="port-label relation-port-label"]//div[contains(text(),'P')]
    Element Should Be Visible    locator=//div[@class="relation-rmod-ports-border rmod-ports-border"]
    Element Should Be Visible
    ...    locator=//div[@class="external-system-block long-press-support relation-system-subcolumn-block"]

Open Cell View
    Wait Until Keyword Succeeds
    ...    25
    ...    5
    ...    Element Should Be Visible   locator=${BTS_STATUS_TAB}
    Click Element   locator=${BTS_STATUS_TAB}
    Mouse Over    locator=${SITE_RUTIME_VIEW_BUTTON}
    Click Element  locator=${CELLS_BUTTON}

Check Cells Tab Under Runtime View
    Click Element    locator=//span[@ui-tooltip="NRCELL-1"]
    Click Element    locator=//a[@class="nav-link ng-binding" and contains(text(),'Parameters')]
    Element Should Be Visible    locator=//span[@ui-tooltip="NRCELL_R-1"]
    Element Should Be Visible    locator=//span[contains(text(),'Configured parameters')]
    Click Element    locator=//a[contains(text(),'Faults')]
    Element Should Be Visible    locator=//span[@ui-tooltip="NRCELL_R-1"]

Open Data Streams
    [Arguments]    ${item}
    Wait Until Element is Visible   locator=${BTS_STATUS_TAB}
    Click Element   locator=${BTS_STATUS_TAB}
    Mouse Over    locator=${DATA_STREAMS_BUTTON}
    Click Element  locator=${DATA_STREAMS_BY_${item}_BUTTON}

Check Data Streams By Cell
    Check Data Streams Table Of Objects
    Count Proper Value Of Elements In The Table    NRCELL=2
    ...                                            TX=8
    ...                                            RX=8
    ...                                            RMOD=2
    ...                                            SMOD=2
    Check If Operational State Is Visible    NRCELL=2
    ...                                      RMOD=2
    ...                                      SMOD=2

Check Data Streams By Carrier
    Check Data Streams Table Of Objects
    Count Proper Value Of Elements In The Table    NRCELL=16
    ...                                            TX=8
    ...                                            RX=8
    ...                                            RMOD=16
    ...                                            SMOD-1 / SMOD_R-1=16
    Check If Operational State Is Visible    NRCELL=16
    ...                                      RMOD-=9
    ...                                      SMOD-1 / SMOD_R-1=9

Select Cell And Check Parameters In Details Panel
    Click Element  locator=//div[@class="cell-content"]//div[contains(text(),'1')]
    Click Element    locator=//ui-button[@a-is-disabled="$ctrl.detailsPanel.isDisabled()"]
    Check If In Section Valid Parameters Are Visible    &{SECTION_1}
    Check If In Section Valid Parameters Are Visible    &{SECTION_2}
    Check If In Section Valid Parameters Are Visible    &{SECTION_3}
    Check If In Section Valid Parameters Are Visible    &{SECTION_STATUS_4}
    Check RX Channels Table
    Check TX Channels Table

Check RX Channels Table
    Set Test Variable    ${index}    6
    Element Should Be Visible
    ...    locator=//div[${index}]${CHANNELS_TABLE}div[contains(text(),'RX Channels')]
    Check Channel Parameters    &{CHANNEL-2}
    Check Channel Parameters    &{CHANNEL-3}
    Check Channel Parameters    &{CHANNEL-6}
    Check Channel Parameters    &{CHANNEL-8}

Check TX Channels Table
    Set Test Variable    ${index}    7
    Element Should Be Visible
    ...    locator=//div[${index}]${CHANNELS_TABLE}div[contains(text(),'TX Channels')]
    Check Channel Parameters    &{CHANNEL-1}
    Check Channel Parameters    &{CHANNEL-4}
    Check Channel Parameters    &{CHANNEL-5}
    Check Channel Parameters    &{CHANNEL-7}

Check Channel Parameters
    [Arguments]    &{channel}
    Set Test Variable    ${td}    1
    FOR    ${item}    IN    @{channel.keys()}
        Element Should Be Visible
        ...    locator=//div[${index}]${CHANNELS_TABLE}td[${td}]//span[contains(text(),'&{channel}[${item}]')]
        ${td}    Evaluate    ${td}+1
    END

Check If In Section Valid Parameters Are Visible
    [Arguments]    &{section}
    Set Test Variable    ${counter}    1
    Run Keyword If    &{section}==&{SECTION_1}    Set Test Variable    ${section_number}    1
    ...    ELSE IF    &{section}==&{SECTION_2}    Set Test Variable    ${section_number}    2
    ...    ELSE IF    &{section}==&{SECTION_3}    Set Test Variable    ${section_number}    3
    ...    ELSE IF    &{section}==&{SECTION_STATUS_4}    Run Keywords
    ...               Set Test Variable    ${section_number}    5    AND
    ...               Element Should Be Visible
    ...               locator=//div[${section_number}]${CHANNELS_TABLE}div[contains(text(),'Status')]
    FOR    ${item}    IN    @{section.keys()}
        ${status}=    Get From Dictionary    dictionary=${section}
        ...                                  key=${item}
        Element Should Be Visible
        ...    locator=//div[${section_number}]${CHANNELS_TABLE}tr[${counter}]//td[1][contains(text(),'${item}')]
        Element Should Be Visible
        ...    locator=//div[${section_number}]${CHANNELS_TABLE}tr[${counter}]//td[2][contains(text(),'${status}')]
        ${counter}    Evaluate    ${counter}+1
    END

Check Data Streams Table Of Objects
    Set Test Variable    ${count}    1
    FOR    ${item}    IN    @{DATA_STREAM_OBJECTS}
        Element Should Be Visible
        ...    locator=//div[${count}][@role="columnheader" and contains(text(),'${item}')]
        ${count}    Evaluate    ${count}+1
        Set Test Variable    ${count}
    END

Count Proper Value Of Elements In The Table
    [Arguments]    &{elements}
    FOR    ${item}    IN    @{elements.keys()}
        ${counter}=    Get From Dictionary    dictionary=${elements}
        ...                                   key=${item}
        Page Should Contain Element    locator=//span[contains(text(),'${item}')]
        ...                            limit=${counter}
    END

Check If Operational State Is Visible
    [Arguments]    &{elements}
    FOR    ${item}    IN    @{elements.keys()}
        ${counter}=    Get From Dictionary    dictionary=${elements}
        ...                                   key=${item}
        Select Element    element=${item}
        ...               count=${counter}
    END

Select Element
    [Arguments]    ${element}
    ...            ${count}
    ${count}    Evaluate    ${count}+1
    Set Test Variable    ${count}
    Set Test Variable    ${counter}    1
    FOR    ${item}    IN RANGE    1    ${count}
        Click Element    locator=//div[${counter}]//span[contains(text(),'${element}')]
        Click Element    locator=//ui-button[@a-is-disabled="$ctrl.detailsPanel.isDisabled()"]
        Element Should Be Visible    locator=//td[contains(text(),'Operational state:')]
        Click Element
        ...    locator=//wf-panel[@panel-name="admin.common.detailsPanel.TITLE"]//ui-button[@a-on-click="hideAction()"]
        ${counter}    Evaluate    ${counter}+1
        Set Test Variable    ${counter}
    END

Missing Mandatory Parameters
    Element Should Be Visible    locator=//li[3]//div[1][contains(text(),'4')]
    Click Element  locator=//div[@class="ui-select"]//button[@ng-class="$ctrl.dropdownButtonClassStr"]
    Click Element  locator=//span[contains(text(),'Definition errors (1)')]
    FOR    ${item}    IN    @{MISSING_MANDATORY_PARAM}
        Element Should Be Visible    locator=//div[contains(text(),'${item}')]
    END
    Click Element    locator=//div[@class="ui-select"]//button[@ng-class="$ctrl.dropdownButtonClassStr"]
    Click Element    locator=//span[contains(text(),'Missing objects errors (3)')]
    FOR    ${item}    IN    @{MISSING_MANDATORY_OBJ}
        Element Should Be Visible    locator=//td[contains(text(),'${item}')]
    END
    Element Should Be Visible    locator=//tr[3]//td[1][contains(text(),'MRBTS-1/EQM-1')]
	Element Should Be Visible    locator=//tr[3]//td[1][contains(text(),'MRBTS-1/EQM-1/APEQM-X')]
	Element Should Be Visible    locator=//tr[4]//td[1][contains(text(),'MRBTS-1/EQM-1/APEQM-X/CABINET-X')]

Perform Or Cancel Create All Missing Mandatory
    [Arguments]    ${action}
    ...            ${item}
    Run Keyword If    '${action}'=='Perform'    Set Test Variable    ${action}    OK
    Click Element    locator=//button[@ui-tooltip="Try to fix invalid parameters"]
    Click Element    locator=//span[contains(text(),'Create all missing mandatory ${item}')]
    Click Element    locator=//button[contains(text(),'${action}')]
    Click Element    locator=//div[contains(text(),'Parameter Editor')]
    Click Element    locator=//div[contains(text(),'Definition Errors')]
    Click Element    locator=//div[@class="ui-select"]//button[@class="btn btn-default dropdown-toggle"]
    Run Keyword If    '${action}'=='OK' and '${item}'=='parameters'
    ...    Element Should Be Visible    locator=//li[@title="Definition errors"]//a[@disabled="disabled"]
    Run Keyword If    '${action}'=='OK' and '${item}'=='objects'
    ...    Element Should Be Visible    locator=//li[@title="Missing objects errors"]//a[@disabled="disabled"]

Check Missing Parameters Or Objects
    [Arguments]    ${errors_visible}
    Element Should Be Visible    locator=//li[3]//div[1][contains(text(),'${errors_visible}')]

Open Parameter Editor
    Wait Until Element is Visible   locator=${CONFIGURATION_TAB}
    Click Element   locator=${CONFIGURATION_TAB}
    Mouse Over  locator=${CONFIGURATION_MANAGEMENT_BUTTON}
    Mouse Over  locator=${PARAMETER_EDITOR_BUTTON}
    Click Element   locator=${PARAMETER_EDITOR_BUTTON}

Prepare Relation Errors In Current Configuration
    Open Current BTS Configuration In Parameter Editor
    Change Parameters Value    totalNumberOfRAPreambles=60
    ...                        maxNumberUesPowerSaving=3
    Change Parameters Value Using Dropdown List    ssbScs=240 KHz
    ...                                            actDlDataForwardingX2=false
    ...                                            actDlDataForwardingX2Limit=true
    ...                                            actcsireportsmuxonpucch=true

Change Parameters Value
    [Arguments]    &{parameters}
    FOR    ${item}    IN    @{parameters.keys()}
        ${value}=    Get From Dictionary    dictionary=${parameters}
        ...                                 key=${item}
        Input Text    locator=${SEARCH_PARAMETER_EDITOR}    text=${item}
        Press Keys    ${SEARCH_PARAMETER_EDITOR}    ENTER
        Click Element    locator=${PARAMETER_TO_CHANGE_PE_FIELD}
        Press Keys    ${SEARCH_PARAMETER_EDITOR}    BACKSPACE
        Input Text    locator=${PARAMETER_TO_CHANGE_PE_FIELD}    text=${value}
        Click Element    locator=${ICON_CLOSE}
    END

Change Parameters Value Using Dropdown List
    [Arguments]    &{parameters}
    FOR    ${item}    IN    @{parameters.keys()}
        ${value}=    Get From Dictionary    dictionary=${parameters}
        ...                                 key=${item}
        Input Text    locator=${SEARCH_PARAMETER_EDITOR}    text=${item}
        Press Keys    ${SEARCH_PARAMETER_EDITOR}    ENTER
        Click Element    locator=//tr[2]//td[4]//button[@ng-class="$ctrl.dropdownButtonClassStr"]
        Click Element    locator=//span[contains(text(),"${value}")]
        Click Element    locator=${ICON_CLOSE}
    END

Click Validate Plan Button And Check Errors
    Click Element    locator=//button[@ui-tooltip="Validate Plan"]
    Check Validation And Relation Errors

Check Validation And Relation Errors
    Wait Until Keyword Succeeds
    ...    60
    ...    10
    ...    Element Should Be Visible    locator=//li[4]//div[contains(text(),"5")]
    Wait Until Keyword Succeeds
    ...    30
    ...    10
    ...    Click Element    locator=//div[contains(text(),"Relation Errors")]
    Element Should Be Visible    locator=//div[contains(text(),"Parameter validation errors")]
    FOR    ${count}    IN RANGE    1    5
        Element Should Be Visible    locator=//tr[${count}]//td[2]//span[contains(text(),"Error")]
    END
    Element Should Not Be Visible    locator=//tr[6]//td[2]//span[contains(text(),"Error")]

Type Free Text Based Filtering Criteria
    Click Element    locator=//div[contains(text(),"Relation Errors")]
    Element Should Be Visible    locator=//tr[1]//th[3][contains(text(),'Object name')]
    Element Should Be Visible    locator=//tr[1]//th[4][contains(text(),'Error description')]
    Input Text    locator=//tr[2]//th[2]//ui-text-input//input
    ...           text=NRCELL-1
    FOR    ${count}    IN RANGE    1    4
        Element Should Be Visible
        ...    locator=//tr[${count}]//td[2]//span[contains(text(),"Error")]
        Element Should Be Visible
        ...    locator=//tr[${count}]//td[3]//span[@class="highlighter-default" and contains(text(),'NRCELL-1')]
    END
    Page Should Contain Element    locator=//span[@class="highlighter-default" and contains(text(),'NRCELL-1')]
    ...                            limit=3
    Input Text    locator=//tr[2]//th[3]//ui-text-input//input
    ...           text=freqBandIndicatorNR
    Element Should Be Visible
    ...    locator=//tr//td[4]//*[@ng-repeat="part in $ctrl.error.parsedFeedback"]${FREQ_BAND_INDICATOR}
    Page Should Contain Element    locator=${FREQ_BAND_INDICATOR}
    ...                            limit=1

Try To Activate Plan And Check Errors
    Mouse Over    locator=//button[@ui-tooltip="Activate Plan"]
    Element Should Be Visible    locator=//button[@ui-tooltip="Activate Plan"]
    Click Element    locator=//button[@ui-tooltip="Activate Plan"]
    Element Should Be Visible    locator=//span[contains(text(),'${ERROR_MESSAGE}')]
    Click Element    locator=//span[contains(text(),'Activate plan despite of validation errors')]
    Click Element    locator=//button[@ui-tooltip="Execute"]
    Set Selenium Implicit Wait    20
    ${bts_reset}     Run Keyword And Return Status    Element Should Be Visible
    ...    locator=//div//span[@class="ng-binding" and contains(text(),'This procedure will cause NR RAT reset')]
    Run Keyword If    '${bts_reset}' == 'True'    Run Keyword    Click Element
    ...    locator=//button[@ui-tooltip="Execute"]
    Wait Until Element Is Visible    locator=//*[contains(text(),'Operation finished successfully')]
    ...                              timeout=120
    Click Element    locator=//ui-button[@a-text="Close"]

Check After Full Commissioning
    Close Browser
    SYSTEM Wait Till Enb Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Enb Will Be Pingable For A Given Period
    ADMIN Assert SMOD Is In Enabled State
    Assert RMODs Are In Enabled State
    Login To Web Element Manager

Assert RMODs Are In Enabled State
    [Arguments]    ${timeout}=500
    ADMIN Assert All Rmods Are In Expected Operational State    enabled    ${timeout}

ADMIN Assert All Rmods Are In Expected Operational State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert All Rmods Are In Expected State    expected_state=${expected_state}
    ...                                             timeout=${timeout}
    ...                                             state_type=operationalState

ADMIN Assert All Rmods Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=RMOD

ADMIN Assert Every
    [Arguments]    ${class_name}
    ...            ${parameters}
    ...            ${timeout}=10
    ...            ${alias}=admin_1
    coam.Assert Every    class_name=${class_name}
    ...                       parameters=${parameters}
    ...                       timeout=${timeout}
    ...                       alias=${alias}

Create Some Relation And Hardware Errors Reverting Parameter Value
    [Arguments]    ${ipMtu_parameter_input}=//tr[2]/td[4]/parameter-input/div/ui-text-input/div/input
    Wait Until Element Is Visible    ${SEARCH_PARAMETER_EDITOR}
    ...    timeout=10
    Input Text      ${SEARCH_PARAMETER_EDITOR}    ipMtu
    Press Keys       ${SEARCH_PARAMETER_EDITOR}    ENTER
    Input Text      ${ipMtu_parameter_input}    2
    Click Button    //div[@class="ui-view-panel-toolbar ng-scope"]//button[@ui-tooltip="Validate Plan"]

Check If Fix Error Table Exist And If It Is Possible To Revert Parameter Value
    Wait Until Element Is Enabled    locator=//div[contains(text(),'Relation Errors')]
    ...             timeout=40
    Wait Until Keyword Succeeds    30
    ...                            5
    ...                            Click Element    locator=//div[contains(text(),'Relation Errors')]
    Click Element    locator=//span[contains(text(),'IPIF-1.ipMtu')]
    Element Should Be Visible    //div[contains(text(),'Errors fixing table')]
    ...             timeout=10
    Element Should Be Visible    locator=//span[@class="fa fa-exclamation-triangle"]
    Click Element
    ...    locator=//ui-button[1]/button[@class="btn minimal-button tiny-button compact-button"]/i[@class="fa fa-undo"]
    Element Should Not Be Visible    locator=//span[@class="fa fa-exclamation-triangle"]
    Click Element
    ...    locator=//ui-button[1]/button[@class="btn minimal-button tiny-button compact-button"]/i[@class="fa fa-trash"]
    Element Should Be Visible    locator=//i[@title="Parameter is planned to be deleted"]

Activate Plan
    [Arguments]    ${operation_finished}=//div[contains(text(),' Operation finished successfully')]
    ...    ${connected_to_bts}=//span[contains(text(),'Connected to BTS')]
    ...    ${validate_plan_button}=//button[contains(text(),' Validate Plan')]
    ...    ${connecting}=//i[@class="fa fa-ellipsis-v"]
    Log    ${connected_to_bts}
    Log    ${validate_plan_button}
    Log    ${connecting}
    Click Element    locator=//button[contains(text(),' Activate Plan')]
    Click Element    locator=//button[contains(text(),' Execute')]
    Wait Until Element Is Visible    locator=${operation_finished}
    ...    timeout=40
    Click Element    locator=//button[contains(text(),'Close')]
    Wait Until Element Is Visible    locator=//div[@class="connection-status connection-status-connecting"]
    ...    timeout=40
    Wait Until Element Is Visible    locator=//div[@class="connection-status connection-status-online"]
    ...    timeout=350
    ADMIN Assert SMOD Is In Enabled State
    Assert RMODs Are In Enabled State

Check If Hidden Parameters Are Not Visible In Parameter Editor
    Close BTS Startup View
    Click Element    locator=//div[contains(text(),'Parameter Editor')]
    Input Text      ${SEARCH_PARAMETER_EDITOR}    e2TnlId
    Press Keys       ${SEARCH_PARAMETER_EDITOR}    ENTER
	Element Should Be Visible    locator=//div[contains(text(),'Parameters not available.')]
    Input Text      ${SEARCH_PARAMETER_EDITOR}    dtxThresholdPUSCH1Tx2RxRB_01
    Press Keys       ${SEARCH_PARAMETER_EDITOR}    ENTER
    Element Should Be Visible    locator=//div[contains(text(),'Parameters not available.')]

Save Commissioning Report And Check Files
    Run Keyword    Run    sudo rm -rf /home/ute/Downloads/commissioning_report*
    Close BTS Startup View
    Click Element    locator=//button[contains(text(), 'Save Report')]
    ${date_table}=                  Get Text    locator=//table/tbody/tr[1]
    ${time_table}=                  Get Text    locator=//table/tbody/tr[2]
    ${user_table}=                  Get Text    locator=//table/tbody/tr[3]
    ${ntp_table}=                   Get Text    locator=//table/tbody/tr[4]
    ${commissioning_type_table}=    Get Text    locator=//table/tbody/tr[5]
    ${bts_state_table}=             Get Text    locator=//table/tbody/tr[6]
    ${bts_name_table}=              Get Text    locator=//table/tbody/tr[7]
    ${file_version_table}=          Get Text    locator=//table[2]/tbody/tr[1]
    ${plan_validation_table}=       Get Text    locator=//table[3]/tbody/tr[1]
    ${plan_activation_table}=       Get Text    locator=//table[4]/tbody/tr[1]
    ${date_table_r}=                  Remove String    ${date_table}    ${space}
    ${time_table_r}=                  Remove String    ${time_table}    ${space}
    ${user_table_r}=                  Remove String    ${user_table}    ${space}
    ${ntp_table_r}=                   Remove String    ${ntp_table}    ${space}
    ${commissioning_type_table_r}=    Remove String    ${commissioning_type_table}    ${space}
    ${bts_state_table_r}=             Remove String    ${bts_state_table}    ${space}
    ${bts_name_table_r}=              Remove String    ${bts_name_table}    ${space}
    ${file_version_table_r}=          Remove String    ${file_version_table}    ${space}
    ${plan_validation_table_r}=       Remove String    ${plan_validation_table}    ${space}
    ${plan_activation_table_r}=       Remove String    ${plan_activation_table}    ${space}
    ${plan_validation_table_l}=       Convert To Lowercase    ${plan_validation_table_r}
    ${plan_activation_table_l}=       Convert To Lowercase    ${plan_activation_table_r}
    Click Element    locator=//button[contains(text(), ' Save report')]
    Click Element    locator=//button[contains(text(), ' Close')]
    Sleep    50
    Run    unzip /home/ute/Downloads/commissioning_report*.zip -d /home/ute/Downloads/commissioning_report
    Run    cd /home/ute/Downloads/commissioning_report
    OperatingSystem.File Should Exist    /home/ute/Downloads/commissioning_report/report-data.txt
    OperatingSystem.File Should Exist    /home/ute/Downloads/commissioning_report/SCF.xml
    ${date}=                  Run    cat /home/ute/Downloads/commissioning_report/report-data.txt | grep 'Date'
    ${time}=                  Run    cat /home/ute/Downloads/commissioning_report/report-data.txt | grep 'Time'
    ${user}=                  Run    cat /home/ute/Downloads/commissioning_report/report-data.txt | grep 'User'
    ${ntp}=                   Run
    ...    cat /home/ute/Downloads/commissioning_report/report-data.txt | grep 'NTP connection'
    ${commissioning_type}=    Run
    ...    cat /home/ute/Downloads/commissioning_report/report-data.txt | grep 'Commissioning type'
    ${bts_state}=             Run    cat /home/ute/Downloads/commissioning_report/report-data.txt | grep 'BTS state'
    ${bts_name}=              Run    cat /home/ute/Downloads/commissioning_report/report-data.txt | grep 'BTS name'
    ${file_version}=          Run    cat /home/ute/Downloads/commissioning_report/report-data.txt | grep 'File version'
    ${plan_validation}=       Run
    ...    cat /home/ute/Downloads/commissioning_report/report-data.txt | grep 'BTS plan validation'
    ${plan_activation}=       Run
    ...    cat /home/ute/Downloads/commissioning_report/report-data.txt | grep 'BTS plan activation'
    ${date_r}=                  Remove String    ${date}    ${space}
    ${time_r}=                  Remove String    ${time}    ${space}
    ${user_r}=                  Remove String    ${user}    ${space}
    ${ntp_r}=                   Remove String    ${ntp}    ${space}
    ${commissioning_type_r}=    Remove String    ${commissioning_type}    ${space}
    ${bts_state_r}=             Remove String    ${bts_state}    ${space}
    ${bts_name_r}=              Remove String    ${bts_name}    ${space}
    ${file_version_r}=          Remove String    ${file_version}    ${space}
    ${plan_validation_r}=       Remove String    ${plan_validation}    ${space}    plan    Plan
    ${plan_activation_r}=       Remove String    ${plan_activation}    ${space}    BTS
    ${plan_validation_l}=       Convert To Lowercase    ${plan_validation_r}
    ${plan_activation_l}=       Convert To Lowercase    ${plan_activation_r}
	Should Be Equal    ${date_table_r}                  ${date_r}
	Should Be Equal    ${time_table_r}                  ${time_r}
	Should Be Equal    ${user_table_r}                  ${user_r}
	Should Be Equal    ${ntp_table_r}                   ${ntp_r}
	Should Be Equal    ${commissioning_type_table_r}    ${commissioning_type_r}
	Should Be Equal    ${bts_state_table_r}             ${bts_state_r}
	Should Be Equal    ${bts_name_table_r}              ${bts_name_r}
	Should Be Equal    ${file_version_table_r}          ${file_version_r}
	Should Be Equal    ${plan_validation_table_l}       ${plan_validation_l}
	Should Be Equal    ${plan_activation_table_l}       ${plan_activation_l}

Check If Undirectional Parameters Can Not Be Modified
    @{list_of_parameters}=    Create List    mrbtsId   availabilityStatus   operationalState   proceduralStatus   eqmRId
    ...    cpriaAldInUse   apeqmRId   cabinetRId   horizontalPosition   verticalPosition   powerGroupId
    ...    sModRId   eacRId   nrOfTXElements   rModRId   sfpRId   hwTopRId   fiberLength
    ...    firstEndpointPortId   linkMaxPhysicalCapacity   secondEndpointPortId   cablinkRId
    ...    antennaPathDelayMeasurementEnablingDate   configDN   productName   activeSwBuild
    ...    activeSwVersion   chassisProductCode   chassisSerialNumber   hwVersion   radioModuleHwReleaseCode
    ...    runningSwBuild   runningSwVersion   complianceCode   connectorType   dateCode   diagMonType
    ...    maxLinkLength   maxLinkLengthType   nokiaPN   physicalPort   rxPowerHighAlarmThreshold
    ...    rxPowerHighWarnThreshold   rxPowerLowAlarmThreshold   rxPowerLowWarnThreshold   temperatureHighAlarmThreshold
    ...    temperatureLowAlarmThreshold   transmissionDistance   transmissionRate    secondEndpointPortId
    ...    txPowerHighAlarmThreshold   txPowerHighWarnThreshold   txPowerLowAlarmThreshold   txPowerLowWarnThreshold
    ...    vendorName   vendorPartNumber   vendorRevision   waveLength   firstEndpointDN   secondEndpointDN   function
    ...    activeRole   direction   lineState   availabilityState   mPlaneLinkStatus   restartCause
    ...    rfmTransmitModeStatus   usageStatus   antennaPathDelayMeasurementEnablingDate  cablinkType
    ...    firstEndpointLabel   secondEndpointLabel   firstEndpointDN    secondEndpointDN   firstEndpointPortId
    Click Element    locator=//i[@class="fa fa-list-ul"]
    FOR    ${PARAMETERS}   IN   @{list_of_parameters}
        Input Text    ${SEARCH_PARAMETER_EDITOR}    ${PARAMETERS}
        Press Keys     ${SEARCH_PARAMETER_EDITOR}    ENTER
        Run Keyword And Continue On Failure    Click Element
        ...    locator=//table/tbody/tr[2]/td[@class="pe-info-cell ng-isolate-scope"]
        Run Keyword And Continue On Failure    Element Should Be Visible
        ...    locator=//td[contains(text(), 'Unmodifiable')]
    END

Choose Any Object From The Object Tree And Chceck Mandatory Parameters
    Wait Until Element Is Visible    locator=${CURRENT_BTS_CONF}
    Click Element   locator=//i[@ng-if="!isRowALeaf(row)"]
    Wait Until Element Is Visible    locator=${MRBTS_NAVIGATION_PANEL}
    ...    timeout=10
    Click Element    locator=${NAVIGATION_OBJECT_TREE_PATH}\[2]//following::li//i[@ng-if="!isRowALeaf(row)"]
    Click Element    //i[@class="fa fa-list-ul"]
    Wait Until Element Is Visible    locator=//span[contains(text(),'EQM-')]
    ...                              timeout=40
    FOR    ${OBJECT}   IN   @{LIST_OF_OBJECTS_MANDATORY_PARAM}
        Click Element    locator=//span[contains(text(),'${OBJECT}')]
        Element Should Be Visible    locator=//td[contains(text(),'Minimum number of instances:')]
        Element Should Be Visible    locator=//td[contains(text(),'Maximum number of instances:')]
	    Element Should Be Visible    locator=//td[contains(text(),'Can be created:')]
	    Element Should Be Visible    locator=//td[contains(text(),'Can be modified:')]
	    Element Should Be Visible    locator=//td[contains(text(),'Can be deleted:')]
    END
    Click Element    locator=//span[contains(text(),'MNL-')]
    Click Element    locator=//button[@class="table-parameter-search"]
    Element Should Be Visible    locator=//label[contains(text(),'All parameters')]
    Element Should Be Visible    locator=//label[contains(text(),'Mandatory parameters')]
    Element Should Be Visible    locator=//label[contains(text(),'Optional parameters')]
    Element Should Be Visible    locator=//label[contains(text(),'Show only modified parameters')]
    Element Should Be Visible    locator=//label[contains(text(),'Show only invalid parameters')]
    Element Should Be Visible    locator=//label[contains(text(),'Show only existing parameters')]
    Element Should Be Visible    locator=//label[contains(text(),'Show only non-existing parameters')]
    Element Should Be Visible    locator=//input[@ng-change="$ctrl.onFullNameSearchChange()"]
    Element Should Be Visible    locator=//input[@ng-change="$ctrl.onAbbreviationSearchChange()"]

Get Value Of ActCli Parameter
    Log    \n+ Checking current status    console=yes
    ${act_cli_state}=    ADMIN INFOMODEL Get Parameter Value
    ...    dist_name=${FEATCADM_PATH}
    ...    dict_param=actCli
    Set Test Variable    ${act_cli_state}
    Log    Is CLI activated: ${act_cli_state}     console=yes

Act Cli Recommissioning
    [Arguments]
    ...    ${new_cli_state}
    Log    \n+ ActCli parameter recommissioning    console=yes
    ADMIN Perform Parameter Recommissioning
    ...    dist_name=MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actCli
    ...    operation=update
    ...    value=${new_cli_state}
    ...    timeout=300

Go To Compare Objects
    Wait Until Keyword Succeeds
    ...    30
    ...    10
    ...    Click Element    locator=${CONFIGURATION_TAB}
    Mouse Over    locator=${CONFIGURATION_MANAGEMENT_BUTTON}
    Mouse Over    locator=${COMPARE_OBJECT_BUTTON}
    Click Element    locator=${COMPARE_OBJECT_BUTTON}

Compare Objects With Unmodifiable Parameter
    Select Plan And Object
    Input Text
    ...    locator=//tr[7]//co-value-cell[@parameter="compareObjectModel.sourceParameter"]//ui-text-input//input
    ...    text=able_to_modify
    Input Text
    ...    locator=//tr[7]//co-value-cell[@parameter="compareObjectModel.destinationParameter"]//ui-text-input//input
    ...    text=able_to_modify
    Run Keyword And Expect Error
    ...    *Element is not currently interactable and may not be manipulated*
    ...    Input Text
    ...    locator=//tr[3]//co-value-cell[@parameter="compareObjectModel.destinationParameter"]//ui-text-input//input
    ...    text=101010

Select Plan And Object
    [Arguments]    ${object}=none
    ${status}    Run Keyword And Return Status    Element Should Be Visible
    ...    locator=//div[2][@ng-if="grouping"]//span[contains(text(),'MRBTS')]
    Run Keyword If    ${status}==${False}    Run Keywords
    ...    Double Click Element
    ...        locator=//span[contains(text(),'CONF-')]    AND
    ...    Click Element
    ...        locator=//span[contains(text(),'MRBTS')]
    Run Keyword If    '${object}'!='none'    Run Keywords
    ...    Double Click Element    locator=//div[2][@ng-if="grouping"]//span[contains(text(),'MRBTS')]    AND
    ...    Click Element    locator=//div[2][@ng-if="grouping"]//span[contains(text(),'${object}')]
    Click Element    locator=${CHOOSE_PLAN_COMPARE}
    Mouse Over    locator=//li[@data-selected='false']//span[@class='ng-item ng-binding']
    Click Element    locator=//li[@data-selected='false']//span[@class='ng-item ng-binding']
    Click Element    locator=${CHOOSE_OBJECT_COMPARE}
    Mouse Over    locator=//ui-select[2]//span[@class="ng-item ng-binding"]
    Click Element    locator=//ui-select[2]//span[@class="ng-item ng-binding"]
    Click Element    locator=//span[contains(text(),'Show differences')]