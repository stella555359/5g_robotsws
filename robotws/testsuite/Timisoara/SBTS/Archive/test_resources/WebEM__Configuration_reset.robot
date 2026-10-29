*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}            1200   #Time for SBTS to recovery!
${CONFIG_RESET_OPTION}         5      #Option number from BTS Rescue Console for configuration reset!
${BTS_RESCUE_CONSOLE_TIMEOUT}  400s   #Timeout for BTS Rescue Console to appear!
${RECOVERY_MODULE_TIMEOUT}     600s   #Timeout for modules to be enabled after decommissioning!


*** Keywords ***
TC__WebEM__Configuration_reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21618
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is created to perform configuration reset.
    ...  Open Configuration -> Configuration Reset menu.
    ...  Execute configuration reset if ${CONFIG_RESET_OPTION} is 2, 3, 4, 5 or 6.
    ...  If ${CONFIG_RESET_OPTION} is 1, reset site is performed.
    ...  The test will sleep for 300s, time for all HW to appear.
    ...  All SMODs, BBMODs and RMODs available on BTS are check to be Online and Enabled.
    ...  Initial SCF will be upload.
    ...  Check all cells to be Online.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.07.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21618 - Initial TAT creation
    ...  - 19.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23935 - Remove KWs changed in resource
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 08.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25319 - Configuration reset KW changed for CB007500
    ...  - 25.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25781 - Close BTS Start-up View only if it's needed

    Set Tags    CA-WebEM    OWNER-nicolae-marcel.caragel@nokia.com    AUTHOR-andreea.burtic@nokia.com
    ...    MAINTAINER-andreea.burtic@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS22

    Step1: Perform configuration reset
    Step2: Verify BTS after configuration reset
    Step3: Upload SCF on BTS if needed


Step1: Perform configuration reset
    Log  Step1: Perform configuration reset  console=true
    Performing Configuration Reset and verify SBTS to be not commissioned  ${BTS_RESCUE_CONSOLE_TIMEOUT}  ${CONFIG_RESET_OPTION}

Step2: Verify BTS after configuration reset
    Log  Step2: Verify BTS after configuration reset  console=true
    ${RELEASE}  Fetch from left  ${active SW version}  _
    Set Test Variable  ${RELEASE}
    Run keyword if  '${RELEASE}' >= 'SBTS23R3' and ${CONFIG_RESET_OPTION} == 1  run keywords
    ...  Close BTS Start-up View  AND
    ...  Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}  AND
    ...  Log  All cells are onAir![OK]  console=true
    ...  ELSE  run keywords
    ...  Sleep  300s  Time for all HW to appear.  AND
    ...  Check SMODs to be Online and Enabled  ${RECOVERY_MODULE_TIMEOUT}  AND
    ...  Check BBMODs to be Online and Enabled  ${RECOVERY_MODULE_TIMEOUT}  AND
    ...  Check RMODs to be Online and Enabled  ${RECOVERY_MODULE_TIMEOUT}

Step3: Upload SCF on BTS if needed
    Log  Step3: Upload SCF on BTS if needed  console=true
    Run keyword if  '${RELEASE}' >= 'SBTS23R3' and ${CONFIG_RESET_OPTION} == 1
    ...  Return from keyword
    ...  ELSE
    ...  Perform recommissioning on SBTS

Perform recommissioning on SBTS
    ${BTS_ID}  Admin Get BTS Id
    Log  Loading SCF will be performed...  console=true
    ${commissioning_status}  Run Keyword and Return Status  coam.Perform commissioning  bts_id=${BTS_ID}
    ...  scf_file=${COMMISSIONING_PATH}  skip_parameter_relation_errors=${True}  should_activate=${True}  timeout=600
    Run keyword if  ${commissioning_status}
    ...  Log  Loading SCF is performed successfully.[OK]  console=true
    ...  ELSE
    ...  Fail  Loading SCF is failed.[NOK]
    Close Startup View If Visible
    Log  Wait for all cells to be onAir...  console=true
    ${cells_status}  Run keyword and return status  Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Run keyword if  ${cells_status}
    ...  Log  All cells are onAir![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are onAir![NOK]


TC Setup
    Common test setup
    WebEM Setup

TC Teardown
    Run Keyword If Test Failed  Perform recommissioning on SBTS
    WebEM Teardown
    Common test teardown
