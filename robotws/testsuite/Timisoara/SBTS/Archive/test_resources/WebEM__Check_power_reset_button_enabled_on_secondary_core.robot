*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${JAR_FILE_NAME}      selenium-server-4.8.0
${RESTORE_TIMEOUT}    600


*** Keywords ***
TC__WebEM__Check_power_reset_button_enabled_on_secondary_core
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24947
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC is turning off/on SMOD secondary core and check the SBTS behavior to be as expected.
    ...  When secondary core is off, cells mapped on this SMOD should be Failed.
    ...  After turning on secondary core, SBTS must be onAir.
    ...  In the end, TC will check through Selenium library that Power Reset button is Enabled on secondary
    ...  core WebEM. To be able to open chrome browser on VM secondary, TC is connecting to VM secondary
    ...  and starts ${JAR_FILE_NAME}.jar package which opens a Selenium session.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24947 - Initial TAT creation
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags    CA-WebEM    OWNER-oana.badea@nokia.com    AUTHOR-andrada-lavinia.baleti@nokia.com
    ...    MAINTAINER-andrada-lavinia.baleti@nokia.com    GROUP_IN_CHARGE-TIM_1_Vrf    PHASE-CRT    SW-SBTS23

    Step0: TC variables
    Step1: Turn Off Secondary Core And Check Cells To Be Disabled
    Step2: Turn On Secondary Core And Check SBTS To Be OnAir
    Step3: Connect To WebEM On Secondary Core And Check Power Reset Button To Be Enabled


Step0: TC variables
    ${secondary_core_object}  Get Secondary Core Parameters
    Set Test Variable  ${SECONDARY_CORE_SN}  ${secondary_core_object}[serialNumber]
    ${CELLS_ON_SECONDARY_CORE}  Get Cell Mapping By Module Id  ${secondary_core_object}[id][internal]
    Set Test Variable  ${CELLS_ON_SECONDARY_CORE}

Get Secondary Core Parameters
    ${smods}  Get Fsm Info
    FOR  ${smod}  IN  @{smods}
        Run Keyword If  '${smod}[activeRole]'=='Secondary'
        ...  Return From Keyword  ${smod}
    END

Step1: Turn Off Secondary Core And Check Cells To Be Disabled
    Log  \nStep1: Turn Off Secondary Core And Check Cells To Be Disabled  console=true
    Pdu BTS Interface Off  SMOD_${SECONDARY_CORE_SN}
    Wait Until Keyword Succeeds  180  10
    ...  Check Parameters Status For Cells  ${CELLS_ON_SECONDARY_CORE}
    ...                                     operationalState=${Disabled_}, availabilityStatus=${Failed_}

Step2: Turn On Secondary Core And Check SBTS To Be OnAir
    Log  \nStep2: Turn On Secondary Core And Check SBTS To Be OnAir  console=true
    Pdu BTS Interface On  SMOD_${SECONDARY_CORE_SN}
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10  Admin Check All Required State

Step3: Connect To WebEM On Secondary Core And Check Power Reset Button To Be Enabled
    Log  \nStep3: Step3: Connect To WebEM On Secondary Core And Check Power Reset Button To Be Enabled  console=true
    Start Server
    Open Remote WebEM
    Wait Until Keyword Succeeds  60s  10s  Click Element  locator=//span[@ui-tooltip='Procedures']
    Click Element  locator=//span[text()='BTS Power Reset']
    Element Should Be Enabled  locator=//span[text()='Execute']

Start Server
    ssh.Connect To  ${PC_IP2}  ute
    ${status_jar_file}  Run Keyword And Return Status  OperatingSystem.File Should Not Exist  /home/ute/${JAR_FILE_NAME}.jar
    Run Keyword If  ${status_jar_file}
    ...  ssh.Execute  cp /media/BuildShareTimi01/SBTS/jar_files/${JAR_FILE_NAME}.jar /home/ute
    ssh.Execute  nohup java -jar /home/ute/${JAR_FILE_NAME}.jar standalone --port 10020 & sleep 5

Stop Server
    ${output}  ssh.Execute  ps -ef | grep ${JAR_FILE_NAME}
    ${output_splitted}  Split String  ${output}
    ssh.Execute  kill -9 ${output_splitted}[1]
    Disconnect


TC Setup
    Common Test Setup  tc_name=WebEM__Check_power_reset_button_enabled_on_secondary

TC Teardown
    WebEM Teardown
    Stop Server
    Common Test Teardown
