*** Settings ***
Documentation
    ...  This TC is performing software rollback.
    ...  Step 1: active and passive partitions are verified and they must exist.
    ...  Step 2: Software rollback is performed and after it the user is notified when the texts containing STARTED,
    ...  SUCCEEDED and BTS resseting... appear. Then TC will click the Reload button when it is enabled and will close
    ...  Startup View and Plug and play view if they are visible.
    ...  Active and passive partitions should be exchanged.
    ...  Software rollback is performed to restore the initial software.
    ...  In the end TC will wait until all cells are onAir.
    ...  If the BTS is decommissioned after rollback, SCF commissioning will be performed.

Resource  ../../common_resources/ca_WebEM_mobile.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900  # Time for SBTS to be OnAir
${BTS_RESET_TEXT_TIMEOUT}  300  # Time for BTS Resetting text to appear


*** Keywords ***
TC__WebEM__SW_Rollback
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22510
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  20.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22510 - Initial TAT creation
    ...  16.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23543 - Adding timeout as a global variable
    ...  25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  16.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27277 - Xpath can be accessed
    ...  10.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28494 - Adding a new step for rollback the initial SW
    ...  16.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29558 - Close start-up veiw before page reload

    Set Tags  CA-WebEM  OWNER-george.gheban@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Check Active And Passive Partitions
    Step2: Perform Software Rollback And Check SBTS
    Step3: Perform Software Rollback To Be In Initial Software


Step1: Check Active And Passive Partitions
    Log  \nStep1: Check active and passive partitions  console=true
    Check Active And Passive Software


Step2: Perform Software Rollback And Check SBTS
    Log  \nStep2: Perform software rollback and check SBTS  console=true
    Set ID For BTS
    Perform SW Rollback
    ${reset_status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  //span[contains(text(), "BTS resetting...")]  timeout=${BTS_RESET_TEXT_TIMEOUT}
    Run Keyword If  ${reset_status}
    ...  Log  BTS is resetting after rollback. [OK]  console=true
    ...  ELSE
    ...  Fail  BTS is not resetting after rollback. [NOK]
    Check SBTS After Reset


Step3: Perform Software Rollback To Be In Initial Software
    Log  Step3: Perform Software Rollback To Be In Initial Software  console=true
    Check Active And Passive Software
    Perform SW Rollback
    ${reset_status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  //span[contains(text(), "BTS resetting...")]  timeout=${BTS_RESET_TEXT_TIMEOUT}
    Run Keyword If  ${reset_status}
    ...  Log  BTS is resetting after rollback. [OK]  console=true
    ...  ELSE
    ...  Fail  BTS is not resetting after rollback. [NOK]
    Check SBTS After Reset
    ${active_SW}  coam.Get Sw Version
    Run Keyword If  '${active_SW}' == '${ACTIVE_SW_VERSION}'
    ...  Log  Active software was restored: ${ACTIVE_SW}.  console=true
    ...  ELSE
    ...  Fail  Active software was not restored. [NOK]


Check Active And Passive Software
    Wait Until Element Is Clicked For Mobile  ${MOBILE_MENUS_TAB}  60
    Wait Until Element Is Clicked For Mobile  ${SOFTWARE_MENU_MOBILE}  60
    Wait Until Element Is Visible  //h2[contains(text(), "Current software version")]  timeout=5
    ${active_sw}  Get Text  //label[text()="Active:"]/following-sibling::*
    ${passive_sw}  Get Text  //label[text()="Passive:"]/following-sibling::*
    Set Test Variable  ${ACTIVE_SW}
    Set Test Variable  ${PASSIVE_SW}
    ${active_sw_status}  Run Keyword And Return Status
    ...  Should Not Be Equal As Strings  ${ACTIVE_SW}  ${EMPTY}
    Run Keyword If  ${active_sw_status}
    ...  Log  Active software: ${ACTIVE_SW}.  console=true
    ...  ELSE
    ...  Fail  Active software does not exists. [NOK]
    ${passive_sw_status}  Run Keyword And Return Status
    ...  Should Not Be Equal As Strings  ${PASSIVE_SW}  ${EMPTY}
    Run Keyword If  ${passive_sw_status}
    ...  Log  Passive software: ${PASSIVE_SW}.  console=true
    ...  ELSE
    ...  Fail  Passive software does not exists. [NOK]


Set ID For BTS
    ${bts_info_result}  Get Bts Info
    ${mrbts_id}  Fetch From Left  ${bts_info_result}[systemModules][0][cabinetId][configuration]  /
    ${id_only}  Should Match Regexp  ${mrbts_id}  \\d+
    Set Test Variable  ${BTS_ID}  ${id_only}


Perform SW Rollback
    ${rollback_started}  Set Variable If  '${GUI_VERSION}' == 'new'  operation started  STARTED
    ${rollback_succeeded}  Set Variable If  '${GUI_VERSION}' == 'new'  operation succeeded  SUCCEEDED
    Wait Until Element Is Clicked For Mobile  //button[contains(text(), "Rollback...")]  60
    Wait Until Element Is Visible  //*[contains(text(), "Do you really want to proceed rollback?")]  timeout=10
    Wait Until Element Is Clicked For Mobile  //*[@a-text="Rollback"]  60
    Wait Until Element Is Visible  //*[contains(text(), "Starting rollback")]  timeout=60
    ${failed_passive}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  //*[contains(text(), "passive software is not valid")]  timeout=5
    Run Keyword If  ${failed_passive}
    ...  Fail  Passive SW is invalid - can't perform rollback.
    Wait Until Element Is Visible  //*[contains(text(), "Passive software version checking...")]  timeout=10
    ${rollback_started_status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  //*[contains(text(), "${rollback_started}")]  timeout=60
    Run Keyword If  ${rollback_started_status}
    ...  Log  Software rollback started. [OK]  console=true
    ${rollback_succeeded_status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  //*[contains(text(), "${rollback_succeeded}")]  timeout=120
    Run Keyword If  ${rollback_succeeded_status}
    ...  Log  Software rollback succeeded. [OK]  console=true


Check SBTS After Reset
    ${reload_needed}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  timeout=${RECOVERY_TIMEOUT}  locator=//div[@class="modal-footer"]//ui-button[@a-text="Reload"]
    Close Startup View If Visible Via Mobile
    Run Keyword If  ${reload_needed}
    ...  Click Element  locator=//div[@class="modal-footer"]//ui-button[@a-text="Reload"]
    Close Plug And Play View If Visible
    ${logged_out}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  ${LOGIN_USERNAME_MOBILE}  30
    Run Keyword If  ${logged_out}
    ...  Login To SBTS Again
    Check Software Versions After Rollback
    Go To Site View Via Mobile
    ${status}  Run Keyword And Return Status
    ...  coam.Reset Admin
    Run Keyword If  ${status}==${FALSE}
    ...  Set Test Failed  Admin connection did not reset. [NOK]
    ${current_status}  coam.Get Mrbts State
    Run Keyword If  '${current_status}'=='NotCommissioned'
    ...  Perform SCF Commissioning
    Log  Wait for cells to be onAir...  console=true
    ${cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Run Keyword If  ${cells_status}
    ...  Log  All cells are onAir. [OK]  console=true
    ...  ELSE
    ...  Set Test Failed  Not all cells are onAir. [NOK]


Close Plug And Play View If Visible
    ${plug_and_play_view_visible_switch}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  //*[@class="footer"]//*[@a-text="Switch"]  30
    ${plug_and_play_view_visible_cancel}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  //*[@class="footer"]//*[@a-text="Cancel"]  30
    Run Keyword If  ${plug_and_play_view_visible_switch} and ${plug_and_play_view_visible_cancel}
    ...  Click Element  //*[@class="footer"]//*[@a-text="Cancel"]


Login To SBTS Again
    Login SBTS Via Mobile
    Close Startup View If Visible Via Mobile
    Close Plug And Play View If Visible


Check Software Versions After Rollback
    ${sw_status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  //h2[contains(text(), "Current software version")]  timeout=5
    Run keyword if  ${sw_status}==${FALSE}
    ...  Run keywords
    ...  Wait Until Element Is Clicked For Mobile  ${MOBILE_MENUS_TAB}  60
    ...  AND
    ...  Wait Until Element Is Clicked For Mobile  ${SOFTWARE_MENU_MOBILE}  60
    ...  AND
    ...  Wait Until Element Is Visible  //h2[contains(text(), "Current software version")]  timeout=5
    Wait Until Element Is Visible  //button[contains(text(), "Rollback")]  timeout=10
    ${active_sw_after_rollback}  Get Text  //label[text()="Active:"]/following-sibling::*
    ${passive_sw_after_rollback}  Get Text  //label[text()="Passive:"]/following-sibling::*
    ${active_sw_status}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${active_sw_after_rollback}  ${PASSIVE_SW}
    ${passive_sw_status}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${passive_sw_after_rollback}  ${ACTIVE_SW}
    Run Keyword If  ${active_sw_status} and ${passive_sw_status}
    ...  Log  Active and passive software are exchanged. [OK]  console=true
    ...  ELSE
    ...  Set Test Failed  Software versions did not exchange. [NOK]


Perform SCF Commissioning
    Log  Perform SCF commissioning as recovery action...  console=true
    coam.Perform Commissioning  bts_id=${BTS_ID}  scf_file=${COMMISSIONING_PATH}  skip_parameter_relation_errors=${TRUE}  should_activate=${TRUE}
    ...  timeout=${RECOVERY_TIMEOUT}


Recovery Action
    ${active_SW}  coam.Get Sw Version
    Run Keyword If  '${active_SW}' != '${ACTIVE_SW_VERSION}'
    ...  Run keywords
    ...  Log  Initial software was not restored, rollback the initial sotfware is performing!  console=true
    ...  AND
    ...  coam.Rollback Software  timeout=600
    ${current_status}  coam.Get Mrbts State
    Run Keyword If  '${current_status}'=='NotCommissioned'
    ...  Perform SCF Commissioning
    ${cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Run Keyword If  ${cells_status}
    ...  Log  All cells are onAir. [OK]  console=true
    ...  ELSE
    ...  Set Test Failed  Not all cells are onAir. [NOK]


TC Setup
    Common Test Setup  tc_name=WebEM__SW_Rollback
    WebEM Setup Via Mobile


TC Teardown
    Run Keyword If Test Failed
    ...  Recovery Action
    WebEM Teardown Via Mobile
    Common Test Teardown
