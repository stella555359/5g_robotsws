*** Settings ***
Documentation
...    Author: Dan Novacescu (dan.novacescu@nokia.com)
...    Maintainer: Dan Novacescu (dan.novacescu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:CB008797-5G
...    Sample execution: robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB007422-5G/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library      taf.transport.ssh   WITH NAME   csn
Library      taf.sbts.oam.coam.admin
Library      taf.selenium.gnb.oam.coam.classical

Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/selenium.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

*** Keywords ***

OAM_Block_Unblock_and_Lock_UnLock_for_NR
    Check ProductVariantPlanned
    Block RAT
    Sleep  60
    Unblock RAT
    Sleep  60
    Block RAT
    Sleep  30
    admin.ADMIN Reset Site
    Check BTS Status is in Configured state after reset
    #Unblock Site
    #Check BTS Status is in Configured state after reset
    Go to step

Check ProductVariantPlanned
    ${COntent_SCF}=    taf.sbts.oam.coam.admin.get_current_scf_content
    Log to console  ${COntent_SCF}
    Should contain  ${COntent_SCF}   <p name="productVariantPlanned">sBTS</p>

Check BTS Status is in Configured state after reset
    Sleep  30
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    wait until keyword succeeds  900s  100s   Check If BTS Configured

Check If BTS Configured
    ${bts_statuses_response}=    taf.sbts.oam.coam.admin.Get Bts Info
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=Configured

Block RAT
    taf.sbts.oam.coam.admin.block  /MRBTS-1/NRBTS-1

Block Site
    taf.sbts.oam.coam.admin.block  /MRBTS-1

Unblock RAT
    taf.sbts.oam.coam.admin.unblock  /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1

Unblock Site
    taf.sbts.oam.coam.admin.unblock  /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4

Go to step
    SELENIUM Prepare Enviroment
    SELENIUM Login To Web Element Manager
    Go To Configuration Tab


Go To Configuration Tab
    Wait Until Element Is Visible
    ...    locator=//div[@aria-describedby="admin.navigationBar.configuration.TITLE"]
    ...    timeout=10
    Run Keyword And Ignore Error
    ...    Wait Until Element Is Not Visible
    ...    locator=//div[@class="notifyjs-corner"]//div
    ...    timeout=60
    Click Element
    ...    locator=//div[@aria-describedby="admin.navigationBar.configuration.TITLE"]
    Wait Until Element Is Visible
    ...    locator=//span[contains(text(),'Configuration Management')]
    ...    timeout=20
    Mouse Over
    ...    locator=//span[contains(text(),'Configuration Management')]
    Wait Until Element Is Visible
    ...    locator=//span[contains(text(),'Commissioning Wizard')]
    ...    timeout=20
    Click Element
    ...    locator=//span[contains(text(),'Commissioning Wizard')]
    Wait Until Element Is Visible
    ...    locator=//a[contains(text(),'Steps')]
    ...    timeout=20
    Click Element
    ...    locator=//a[contains(text(),'Steps')]
    Wait Until Element Is Visible
    ...    locator=//span[contains(text(),'System Module')]
    ...    timeout=20
    Click Element
    ...    locator=//span[contains(text(),'System Module')]
    Wait Until Element Is Visible
    ...    locator=//span[contains(text(),'Transport Configuration')]
    ...    timeout=20
    Click Element
    ...    locator=//span[text()='Transport Configuration']
    Wait Until Page Contains  Ethernet Link OAM Profiles
    Wait Until Page Contains  Ethernet Service OAM
    Click Element
    ...    locator=//span[text()='IP Security']
     Wait Until Page Contains  IKE Profiles


