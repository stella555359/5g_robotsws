*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${NUMBER_OF_LOOPS}=         3       #Number of multiple IuB short link break and restoration. Default value is 3.


*** Keywords ***
TC__FM__link_break_S1_short
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-8374
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case was created to imitate whole link break scenario.
    ...  Test will be done by deleting VLANs via CLI on physical switch.
    ...  VLANs are being loaded from IM, there is no need to point them as parameter.
    ...  Switch IP and other parameters are being loaded from robot file.
    ...  Scenario is fitted to commissioned technologies (eg. GSM alarms won't be checked if configuration is LTE-WCDMA only).
    ...  In robot file variables should be added as global parameters (for example):
    ...  @{GSMVlan}            ${261}  ${262}
    ...  ${WCDMAVlan}          ${464}
    ...  ${LTEVlan}            ${461}
    ...  ${Switch_IP}          10.255.6.18
    ...  ${Switch_type}        Nokia_Nuage
    ...  ${INTERFACE_TYPE}     GigabitEthernet
    ...  ${INTERFACE_ID}       5
    ...  ${Switch_USER}        AutoUser
    ...  ${Switch_PASSWORD}    AutoPass123$
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8374 - Initial TAT creation
    ...  - 23.04.2018 - https://jira3.int.net.nokia.com/browse/TAT-9832 - Get all [TECHNOLOGY] Tx Power from all RMs needs to be adjusted to work
    ...  with 3+3
    ...  - 12.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14595 - Invalid log level in [NOK] case
    ...  - 18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  - 04.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17385  -  Nokia 7210 Switch commands syntax addition
    ...  - 14.09.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20163 - Include custom restore link connection as failling action in all checks
    ...  throughout the test based on switch type in cofiguration
    ...  - 20.01.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20724 - Change switch_type name in link breaks scenariors
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 05.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26773 - Add new steps to FM__link_break_SBTS_long
    ...  *******************

    Set Tags    CA-FM    OWNER-laura.craciunel@nokia.com    AUTHOR-rafal.ozga@nokia.com    MAINTAINER-laura.craciunel@nokia.com
    ...    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS17A    FEATURE-RP001534    FEATURE-RP001145_RP000920
    ...    FEATURE-RP001486_RP000920

    step1: Check All Required States

    step2: Perform Short Link Break

    step3: Check links state after links were restored and all cells state


step1: Check All Required States
    [Documentation]  In this step user input and specific states of links will be checked.

    Log  \nStep1: Check All Required States.    console=yes

    ${allRMODsPowerBeforeLinkBreak}=  create dictionary
    set test variable  ${allRMODsPowerBeforeLinkBreak}
    ${allRMODsPowerAftereLinkBreak}=  create dictionary
    set test variable  ${allRMODsPowerAftereLinkBreak}
    ${allRMODsLTEPowerAfterLinkBreak}=  create list
    set test variable  ${allRMODsLTEPowerAfterLinkBreak}

    Check commissioned technologies  LTE

    Check links status  Available


step2: Perform Short Link Break
    [Documentation]  In this step Link Break will be performed.

    Log  \nStep2: Perform Short Link Break.    console=yes

    Get used VLANs

    ${status}=  run keyword and return status  list should contain value  ${VLANids}  ${LTEVlan}

    run keyword if  ${status}
    ...  Log  LTE VLAN which is set in configuration file is also found in IM, test will continue [OK]  console=true
    ...  ELSE
    ...  Fail  msg=LTE VLAN which is set in configuration file was not found in IM, test will be set to failed

    Get all Tx Power from all RMs  ${allRMODsPowerBeforeLinkBreak}

    Run Keyword If  '${Switch_type}'=='Nokia_7210' or '${Switch_type}'=='Nokia_Nuage'
    ...  Wait until keyword succeeds  5min  1min  Connect to Nokia serving switch and perform short interuption
    ...  ${Switch_IP}  ${Switch_USER}  ${Switch_PASSWORD}  ${LTEVlan}  ${INTERFACE_ID}
    ...  ELSE
    ...  Fail  msg=Serving switch is not supported, test will be set as failed.

Wait Random Time
    [Tags]  helper
    [Documentation]  Use to wait random time after link break
    ${random int}=    Evaluate    random.randint(1, 10)    modules=random
    Sleep    ${random int}

step3: Check links state after links were restored and all cells state
    [Documentation]  In this step links state and cells state will be checked after link has been restored.

    Log  \nStep3: Check links state and cells state after Link has been restored.    console=yes

    Sleep  300s

    Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}

    Check links status  Available

    Get all Tx Power from all RMs  ${allRMODsPowerAftereLinkBreak}

    ${dictionarykeys}=  get dictionary keys  ${allRMODsPowerAftereLinkBreak}

    FOR  ${element}  IN  @{dictionarykeys}
       Log  ${element}  console=true
       ${firstList}=  create list
       ${secondList}=  create list
       ${firstList}=  Get from Dictionary  ${allRMODsPowerBeforeLinkBreak}  ${element}
       ${secondList}=  Get from Dictionary  ${allRMODsPowerAftereLinkBreak}  ${element}
       ${as_required}=  Compare Tx Power  ${firstList}  ${secondList}  10.0
       ${firstListLenght}=  get length  ${firstList}
       ${secondListLenght}=  get length  ${secondList}
       ${lengthStatus}=  run keyword and return status  should be equal as numbers  ${firstListLenght}  ${secondListLenght}
       Run Keyword Unless  ${as_required}  Set Test Restriction  TxPowers are different with given dBm tolerance [NOK]
       Run Keyword Unless  ${lengthStatus}  Log  Amount of TxPowers are different, investigation should be started [NOK]  console=true
       Run Keyword If  ${as_required}  Log  TxPowers are not different with given dBm tolerance [OK]  console=true
       Run Keyword If  ${lengthStatus}  Log  Amount of TXs is the same [OK]  console=true
    END

    Admin Check Active Alarms TAF

TC Setup
    Common test setup

TC Teardown
    Run Keyword If Test Failed  Restore link  ${LTEVlan}
    Common test teardown