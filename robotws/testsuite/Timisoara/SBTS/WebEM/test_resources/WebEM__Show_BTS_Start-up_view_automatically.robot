*** Settings ***
Documentation
    ...  This TC is created to check the appearance of BTS Start-up view after Site Reset and Commissioning of SBTS.
    ...  After Site Reset, the procedural state of SBTS should be different than Initializing/NotCommissioned.
    ...  Cells should be Offline and BTS Start-Up view should appear.
    ...  After Decommissioning, modules are checked and should be Online.
    ...  After Commissioning, the procedural state of SBTS should be different than Initializing/NotCommissioned.
    ...  BTS Start-up view should appear and all cells should be Online.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  300s  # Timeout for SBTS to recover after startup!
${RECOVERY_MODULE_TIMEOUT}  600s  # Timeout for modules to be enabled after decommissioning!
${AFTER_COMMISSIONING_TIMEOUT}  600s  # Timeout for cells to be onAir after commissioning!
${BTS_RESCUE_CONSOLE_TIMEOUT}  500s  # Timeout for BTS Rescue Console to appear!
${CONFIG_RESET_OPTION}  6  # Number of configuration reset option from BTS Rescue Console


*** Keywords ***
TC__WebEM__Show_BTS_Start-up_view_automatically
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21625
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.09.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21625 - Initial TAT creation
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22067 - Adapt WebEM TCs for CNI-61110
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22254 - Duplicate KWs in ca_WebEM_general resource and in test
    ...  - 19.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23935 - Remove KWs changed in resource
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 05.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25087 - Configuration reset KW changed for CB007500
    ...  - 25.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25781 - Close BTS Start-up View only if it's needed
    ...  - 23.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26925 - Fix configuration reset method
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags  CA-WebEM  OWNER-emina.stefanovici@nokia.com  AUTHOR-cosmina.rebenciuc@nokia.com  MAINTAINER-cosmina.rebenciuc@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS21B  FEATURE-RP002394

    Step1: Checking The Appearance Of BTS Start-up View After Reset Site
    Step2: Checking The Appearance Of BTS Start-up View After Decommissioning


Step1: Checking The Appearance Of BTS Start-up View After Reset Site
    Log  Step1: Checking the appearance of BTS Start-up view after Reset Site  console=true
    Check All Cells From WebEM
    Log  Performing a Reset Site  console=true
    Reset SBTS From Admin
    Checking Procedural State Of SBTS
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  30s
    ...  Verify Cells Status To Be Offline
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  30s
    ...  Check All Cells On SBTS  Online|-  Enabled|enabled
    Log  SBTS is on air.  console=true


Step2: Checking The Appearance Of BTS Start-up View After Decommissioning
    Log  Step2: Checking the appearance of BTS Start-up view after Decommissioning  console=true
    Log  Parameter initial bts_id: ${BTS_ID}  console=true
    Performing Configuration Reset And Verify SBTS To Be Not Commissioned  ${BTS_RESCUE_CONSOLE_TIMEOUT}  ${CONFIG_RESET_OPTION}
    Log  Checking modules after Configuration Reset  console=true
    Sleep  300s  Time for all modules to be visible!
    Check SMODs To Be Online And Enabled  ${RECOVERY_MODULE_TIMEOUT}
    Check BBMODs To Be Online And Enabled  ${RECOVERY_MODULE_TIMEOUT}
    Check RMODs To Be Online And Enabled  ${RECOVERY_MODULE_TIMEOUT}
    Admin Get Bts_id And Perform Commissioning  ${COMMISSIONING_PATH}
    Close Startup View If Visible
    Wait Until Keyword Succeeds  ${AFTER_COMMISSIONING_TIMEOUT}  30s
    ...  Check All Cells On SBTS  Online|-  Enabled|enabled


Check All Cells On SBTS
    [Documentation]  Verify if cells are online and enabled.
    ...  *AUTHOR*:andreea.burtic@nokia.com
    ...  *MAINTAINER*: cosmina.rebenciuc@nokia.com
    [Arguments]  ${availability}  ${operational}

    ${rat_list}  Create List  GSM  LTE  WCDMA  NR
    FOR  ${rat}  IN  @{rat_list}
        ${cells_status}  Get States For Cells In RAT  ${rat}
        Check RAT  ${cells_status}  ${availability}  ${operational}
    END


Check RAT
    [Documentation]
    ...  *AUTHOR*: cosmina.rebenciuc@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com
    [Arguments]  ${cells_status}  ${availability}  ${operational}

    FOR  ${cell}  IN  @{cells_status.keys()}
        ${availability_status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${cells_status}[${cell}][Availability status]  ${availability}
        ${operational_status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${cells_status}[${cell}][Operational state]  ${operational}
        Run Keyword If  ${availability_status}==${FALSE} and ${operational_status}==${FALSE}
        ...  Fail  msg=Cell ${cell} not in expected status.
    END


Checking Procedural State Of SBTS
    ${mrbts}  coam.Get Parameters For All  BTS
    Run Keyword If  '${mrbts}[0][proceduralState]'=='Initializing'
    ...  Fail  msg=BTS is not in the correct state: ${mrbts}[0][proceduralState]
    ...  ELSE IF  '${mrbts}[0][proceduralState]'=='NotCommissioned'
    ...  Fail  msg=BTS is not in the correct state: ${mrbts}[0][proceduralState]
    ...  ELSE
    ...  Log  BTS is in the correct state: ${mrbts}[0][proceduralState]  console=true


Verify Cells Status To Be Offline
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  coam.Assert Every  WNCEL  availabilityStatus=${OFFLINE}  timeout=60
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  coam.Assert Every  LNCEL  availabilityStatus=${OFFLINE}  timeout=60
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  coam.Assert Every  GNCEL  availabilityStatus=${OFFLINE}  timeout=60
    Run Keyword If  ${SCF_COUNT_NR}
    ...  coam.Assert Every  NRCEL  availabilityStatus=${OFFLINE}  timeout=60


Checking If Recommissioning SBTS Is Needed
    Log  Checking if recommissioning SBTS is needed. console=true
    ${bts_id_after_decommissioning}  Admin Get BTS Id
    Log  Parameter bts_id after decommissioning: ${bts_id_after_decommissioning}  console=true
    ${status}  Run Keyword And Return Status
    ...  Should Be Equal  ${bts_id_after_decommissioning}  ${BTS_ID}
    Run Keyword If  ${status}==${FALSE}
    ...  Recommissioning SBTS


Recommissioning SBTS
    Log  Recommissioning SBTS is performed.  console=true
    Admin Get Bts_id And Perform Commissioning  ${COMMISSIONING_PATH}
    Close BTS Start-up View
    Checking Procedural State Of SBTS
    Wait Until Keyword Succeeds  ${AFTER_COMMISSIONING_TIMEOUT}  30s
    ...  Check All Cells On SBTS  Online|-  Enabled|enabled


TC Setup
    Common Test Setup  tc_name=WebEM__Show_BTS_Startup_view_automatically
    WebEM Setup


TC Teardown
    Run Keyword If Test Failed
    ...  Checking If Recommissioning SBTS Is Needed
    WebEM Teardown
    Common Test Teardown
