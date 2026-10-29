*** Settings ***
Documentation
...    Author: Radu Turcu (radu.turcu@nokia.com)
...    Maintainer: Radu Turcu (radu.turcu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC000766-A
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_VERIF_ET1/5GC000766-A/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        BuiltIn
#Library        Selenium2Library
Library        DateTime
Library        OperatingSystem
Library        SSHLibrary
Library        taf.transport.ssh    WITH NAME    ssh

Library     XML    use_lxml=True

Resource    ../../resources/admin.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/fault_trigger.robot

Resource    ./keywords.robot


*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${CONFIRM_BUTTON}=                      //ui-button[@a-text="Confirm"]
${CUSTOMER_LOGIN}=                      developer
${CUSTOMER_PASSWORD}=                   $developer#
${WebEM IP}                             https://192.168.255.1:3600
${INPUT_NAME_FIELD}=                    userName
${INPUT_PASSWORD_FIELD}=                password


${TIMEOUT_STATUS_MESSAGES}       10
${TIMEOUT_COLLECTION_COMPLETED}  1000
${DIR_RESULTS}                   /home/ute/results
${BTS_PART_DIRS}                 BTS*part*
${keyword}=                      5G
${dist_name}=                    MRBTS-1/NRBTS-35213/NRCELL-44529

${Scf_Initial_Configuration_Branch}=          ${CURDIR}/Initial_22R3_Configuration_scf_MRBTS_AAFB_AAIB_n25_n66_BW5.xml
${Scf_Initial_Configuration_Trunk}=          ${CURDIR}/Initial_22R4_Configuration_scf_MRBTS_AAFB_AAIB_n25_n66_BW5.xml
${delta_file}=                         ${CURDIR}/Delta_Configuration_CellN25_DualSectorBFProfPlus30.json
${delta_file_n22_plus30degree}         ${CURDIR}/Delta_Configuration_Cells_n22_30degree.json
${delta_file_n22_minus30degree}        ${CURDIR}/Delta_Configuration_Cells_n22_minus30degree.json
${delta_file_n66_plus30degree}         ${CURDIR}/Delta_Configuration_Cells_n66_30degree.json
${delta_file_n66_minus30degree}               ${CURDIR}/Delta_Configuration_Cells_n66_minus30degree.json
${delta_file_n66_plus30degree_20MHz}          ${CURDIR}/Delta_Configuration_Cells_n66_plus_30degree_20MHz.json
${delta_file_n66_minus30degree_20MHz}         ${CURDIR}/Delta_Configuration_Cells_n66_minus30degree_20MHz.json
${delta_file_n22_plus_minus_30degree}         ${CURDIR}/Delta_Configuration_Cells_n22_plus_minus_30degree.json
${delta_file_n66_plus_minus_30degree}         ${CURDIR}/Delta_Configuration_Cells_n66_plus_minus_30degree.json
${delta_file_n66_plus_minus_30degree_20MHz}   ${CURDIR}/Delta_Configuration_Cells_n66_plus_minus_30degree_20MHz.json
${delta_file_n22_minus30degreeTest4}          ${CURDIR}/Delta_Config_Cell1_Test4.json

*** Keywords ***

Test1 - Cells_n25_set_DualSectorBFProf_plus_minus_30degree_5MHz
    log to console  set DualSectorBFProf parameter +30 degree on n22 cells
     Wait Until Keyword Succeeds  360  20    ADMIN Check BTS onair
     ADMIN Perform Delta Recommissioning     ${delta_file_n22_plus30degree}     True    timeout=600
     Wait Until Keyword Succeeds  360  20    ADMIN Check BTS onair
     log to console  set DualSectorBFProf parameter -30 degree cell 1 and 30 degree cell 2  on n22 cells
     ADMIN Perform Delta Recommissioning     ${delta_file_n22_plus_minus_30degree}    True  timeout=600
     Wait Until Keyword Succeeds  360  20    ADMIN Check BTS onair
     log to console  set DualSectorBFProf parameter -30 degree on n22 cells
     ADMIN Perform Delta Recommissioning     ${delta_file_n22_minus30degree}    True    timeout=600
     Wait Until Keyword Succeeds  240  20    ADMIN Check BTS onair

Test2 - Cells_n66_set_DualSectorBFProf_plus_minus_30degree_5MHz

     Wait Until Keyword Succeeds  240  20    ADMIN Check BTS onair
     ADMIN Perform Delta Recommissioning     ${delta_file_n66_plus30degree}     True    timeout=600
     Wait Until Keyword Succeeds  360  20    ADMIN Check BTS onair
     log to console  set DualSectorBFProf parameter -30 degree cell 1 and 30 degree cell 2  on n66 cells
     ADMIN Perform Delta Recommissioning     ${delta_file_n66_plus_minus_30degree}    True  timeout=600
     Wait Until Keyword Succeeds  360  20    ADMIN Check BTS onair
     log to console  set DualSectorBFProf parameter -30 degree on n66 cells
     ADMIN Perform Delta Recommissioning     ${delta_file_n66_minus30degree}    True    timeout=600
     Wait Until Keyword Succeeds  240  20    ADMIN Check BTS onair

Test3 - Cells_n66_set_DualSectorBFProf_plus_minus_30degree_20MHz

     Wait Until Keyword Succeeds  240  20    ADMIN Check BTS onair
     ADMIN Perform Delta Recommissioning     ${delta_file_n66_plus30degree_20MHz}     True      timeout=600
     Wait Until Keyword Succeeds  360  20    ADMIN Check BTS onair
     log to console  set DualSectorBFProf parameter -30 degree cell 1 and 30 degree cell 2  on n66 cells
     ADMIN Perform Delta Recommissioning     ${delta_file_n66_plus_minus_30degree_20MHz}    True    timeout=600
     Wait Until Keyword Succeeds  360  20    ADMIN Check BTS onair
     log to console  set DualSectorBFProf parameter -30 degree on n66 cells
     ADMIN Perform Delta Recommissioning     ${delta_file_n66_minus30degree_20MHz}    True      timeout=600
     Wait Until Keyword Succeeds  360  20    ADMIN Check BTS onair

     Get Software Release

     ${Scf_Initial_Configuration}    Set Variable If    '${sw_release} == 'SBTS22R3'     ${Scf_Initial_Configuration_Branch}
    ...                                                  ${Scf_Initial_Configuration_Trunk}

     ADMIN Perform Commissioning
     ...     scf_file=${Scf_Initial_Configuration}
     ...     skip_parameter_relation_errors=False
     Wait Until Keyword Succeeds  360  20    ADMIN Check BTS onair


Test4 - WebEM shall display the most important cell parameters in separate Details panel for cell selected on the BTS Runtime View

    ${outputDetailsStr}        Set Variable    ${EMPTY}
    ${ParamStr}                Set Variable    ${EMPTY}
    ${detailsList}             create list     ${EMPTY}

     Wait Until Keyword Succeeds  240  20    ADMIN Check BTS onair
     ADMIN Perform Delta Recommissioning     ${delta_file_n22_minus30degreeTest4}     True      timeout=600
     Wait Until Keyword Succeeds  360  20    ADMIN Check BTS onair

    SELENIUM Setup
#    # Go to cell1 details parameters
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element  locator=@{DETAILED_VIEW_CELL_OBJECT}[0]
    ${nrcell_1}=    Get WebElements  locator=//div[@class="details-info-body"]

     FOR  ${element}  IN  @{nrcell_1}
         ${outputDetailsStr}   Catenate    ${element.text}
     END

##    Extract elements from Cell_1 details table, the first 19 elements, until Massive MIMO profile
     ${WebEM_Cell1_Data}    Create Dictionary
     ${detailsList}=     Split String     ${outputDetailsStr}    ${\n}
     ${lenght_details}=  Get Length  ${detailsList}
     ${Data Provider}    Create Dictionary
     FOR   ${j}     IN RANGE      19
        ${ParamStr}=        Split String       ${detailsList}[${j}]     :
        set to dictionary   ${WebEM_Cell1_Data}     ${ParamStr}[0]      ${ParamStr}[1]
     END

     ${GlobalCellID}=       get from dictionary    ${WebEM_Cell1_Data}     key=Global cell ID
     ${CellName}=           get from dictionary    ${WebEM_Cell1_Data}     key=Cell name
     ${PhisicalCellID}=     get from dictionary    ${WebEM_Cell1_Data}     key=Physical layer cell ID
     ${NrCellID}=           get from dictionary    ${WebEM_Cell1_Data}     key=NR cell ID
     ${CellGroup}=          get from dictionary    ${WebEM_Cell1_Data}     key=Cell group
     ${MimoProfile}=        get from dictionary    ${WebEM_Cell1_Data}     key=Massive MIMO profile

##      Compare values read in WEbEM with internal BTS values:

##      Physical layer cell ID
    ${cell_param}=      Get Cell Parameter      NRCELL-1      physCellId
    ${cell_param}=      Evaluate   str(${cell_param})
    Should Contain      ${PhisicalCellID}        ${cell_param}       strip_spaces=True

##      Cell name =    NRCELL-1
    ${cell_param}=      Get Cell Parameter      NRCELL-1      cellName
#    ${cell_param}=      Evaluate   str(${cell_param})
    Should Contain      ${CellName}        ${cell_param}       strip_spaces=True

##      NR cell ID
    ${cell_param}=      Get Cell Parameter      NRCELL-1      nrCellIdentity
    ${cell_param}=      Evaluate   str(${cell_param})
    Should Contain      ${NrCellID}        ${cell_param}       strip_spaces=True

##      Global cell ID
    ${cell_param}=      Get Cell Parameter      NRCELL-1      configurationId
    ${cell_param}=      Evaluate   str(${cell_param})
    Should Contain      ${GlobalCellID}        ${cell_param}       strip_spaces=True

##      Massive MIMO profile = DualSectorBFProf(-30 degree), value taken from json file
    Should Contain      ${MimoProfile}        DualSectorBFProf(-30 degree)       strip_spaces=True

##      Cell group = NRCELLGRP-1
    Should Contain      ${CellGroup}        NRCELLGRP-1       strip_spaces=True

    Logout And Close Browser









