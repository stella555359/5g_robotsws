*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***


*** Keywords ***
TC__FM__link_break_s1_long
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-8373
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
    ...  - 20.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8373 - Initial TAT creation
    ...  - 23.04.2017 - https://jira3.int.net.nokia.com/browse/TAT-9832 - Get all [TECHNOLOGY] Tx Power from all RMs needs to be adjusted to work
    ...  with 3+3
    ...  - 11.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15037 - Replacement of depracated KW "check_if_target_is_available"
    ...  - 14.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15267 - Removed additional space
    ...  - 18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  - 6.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16476 - Timeout for S1 link status check added. Timeout for fault 6202 presence
    ...  check increased
    ...  - 04.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17385  -  Nokia 7210 Switch commands syntax addition
    ...  - 28.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-19428  -  Automated__FM__link_break_S1_long
    ...  - 19.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19746 - Move keywords to resource file
    ...  - 14.09.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20163 - Include custom restore link connection as failling action in all checks
    ...  throughout the test based on switch type in cofiguration
    ...  - 20.01.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20724 - Change switch_type name in link breaks scenariors
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 02.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25302 - Test fail with LTE VLAN has not been found in IM
    ...  - 11.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26019 - Testcase checks uncommissioned technologies
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 05.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26773 - Add new steps to FM__link_break_SBTS_long
    ...  *******************

    Set Tags    CA-FM    OWNER-laura.craciunel@nokia.com    AUTHOR-rafal.ozga@nokia.com    MAINTAINER-laura.craciunel@nokia.com
    ...    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS17A    FEATURE-RP001534    FEATURE-RP001145_RP000920
    ...    FEATURE-RP001486_RP000920

    step1: Check All Required States

    step2: Perform Long s1 Link Break

    step3: Check Alarms presence and LTE related states after s1 Link Break

    step4: Restore s1 link connection

    step5: Check links state after links were restored and all cells state


step1: Check All Required States
    [Documentation]  In this step user input and specific states of links will be checked.

    Log  \nStep1: Check All Required States.    console=yes

    ${allRMODsPowerBeforeLinkBreak}=  create dictionary
    set test variable  ${allRMODsPowerBeforeLinkBreak}
    ${allRMODsPowerAftereLinkBreak}=  create dictionary
    set test variable  ${allRMODsPowerAftereLinkBreak}
    ${allRMODsWCDMAPowerAfterLinkBreak}=  create list
    set test variable  ${allRMODsWCDMAPowerAfterLinkBreak}

    Get s1InducedCellDeactDelayTime from SCF


    ${TOP}=  Check syncInputType
    set test variable  ${TOP}
    Log  TOP status at the beggining of TC is: ${TOP}  console=true

    Check commissioned technologies  LTE

    Check links status  Available


Check syncInputType
    [Documentation]  Checking if TOP status is Available and returing bool value true or false. If it's false other syncInputType is used

    ${TOP}=  Query Infomodel  get list //CLOCK-*
    ${topReferenceList}=  create list
    ${topStateDict}=  create dictionary

    FOR  ${item}  IN  @{TOP}
       append to list  ${topReferenceList}  ${item.referenceSourceList}
    END

    ${getfromlist}=  Get From List  ${topReferenceList}  0

    ${status}=  run keyword and return status  Get From List  ${topReferenceList}  1

    FOR  ${item}  IN  @{getfromlist}
       run keyword if  '${item["source"]}' == 'TOP'
       ...  set to dictionary  ${topStateDict}  ${item["source"]}  ${item["availabilityStatus"]}
    END

    run keyword if  '${topStateDict["TOP"]}' == 'Unavailable' and ${status}
    ...  Second clock check  ${topReferenceList}  ${topStateDict}

    [Return]  ${topStateDict["TOP"]}

Second clock check
    [Arguments]   ${topReferenceList}  ${topStateDict}

    ${getfromlist}=  Get From List   ${topReferenceList}  1

    FOR  ${item}  IN  @{getfromlist}
       run keyword if  '${item["source"]}' == 'TOP'
       ...  set to dictionary  ${topStateDict}  ${item["source"]}  ${item["availabilityStatus"]}
    END


Get s1InducedCellDeactDelayTime from SCF
    [Documentation]  To obtain the value of s1InducedCellDeactDelayTime from commmissioning file.
    ...  It will be further used to sleep after S1 link break and before LTE cells check

    Log  Trying to obtain s1InducedCellDeactDelayTime from commissioning file  console=true
    ${scf_parser}=  hran_file_operations.Setup SCFC Parser  ${COMMISSIONING_PATH}  parser_technology=SBTS  alias="usedForS1"
    ${s1Induced}=  hran_file_operations.Get Managed Objects  LNBTS    alias="usedForS1"
    FOR  ${object}  IN   @{s1Induced}
       Log  ${object.keys()}  console=true    #for testing purpose
       Iteration of object keys obtained from SCF  ${object}
    END


Iteration of object keys obtained from SCF
    [Tags]  helper
    [Arguments]  ${object}

    ${s1InducedCellDeactDelayTime}=  create list
    FOR    ${key}  IN  @{object.keys()}
       run keyword if  '${key}' == 's1InducedCellDeactDelayTime'
       ...   run keywords  append to list  ${s1InducedCellDeactDelayTime}  ${object["${key}"]}  AND
       ...  Log  Value of s1InducedCellDeactDelayTime is: ${s1InducedCellDeactDelayTime[0]}  console=true
    END

    set test variable  ${s1InducedCellDeactDelayTime}


step2: Perform Long s1 Link Break
    [Documentation]  In this step s1 Link Break will be performed.

    Log  \nStep2: Perform Long s1 Link Break.    console=yes

    Get used VLANs

    ${status}=  run keyword and return status  list should contain value  ${VLANids}  ${LTEVlan}

    run keyword if  ${status}
    ...  Log  LTE VLAN which is set in configuration file has been also found in IM, test will continue [OK]  console=true
    ...  ELSE
    ...  Fail  msg=LTE VLAN which is set in configuration file has not been found in IM, test will be set to failed

    Get all Tx Power from all RMs  ${allRMODsPowerBeforeLinkBreak}

    Run Keyword If  '${Switch_type}'=='Nokia_7210' or '${Switch_type}'=='Nokia_Nuage'
    ...  Wait until keyword succeeds  5min  1min  Connect to Nokia serving switch and perform action
    ...  ${Switch_IP}  ${Switch_USER}  ${Switch_PASSWORD}  ${LTEVlan}  ${INTERFACE_ID}  shutdown
    ...  ELSE
    ...  Fail  msg=Serving switch is not supported, test will be set as failed.


step3: Check Alarms presence and LTE related states after s1 Link Break
    [Documentation]  In this step alarms and link state related to LTE after s1 link break will be checked.

    Log  \nStep3: Check Alarms presence and LTE related states after s1 Link Break.    console=true

    ${topStatus}=  Check syncInputType
    set test variable  ${topStatus}

    Sleep  600s

    ${alarm_parameters}  Get string with alarm parameters  ${FAULT_6202_Critical}
    Assert Alarm Active  parameters=${alarm_parameters}
    ...                  timeout=240
    Log  Fault ${FAULT_6202_Critical}[fault_id] has been triggered.  console=true

    ${S1linkStatus}=  Run Keyword And Return Status  Assert Every  LNMME  s1LinkStatus=unavailable  timeout=60

    run keyword if  ${S1linkStatus}
    ...  Log  S1 link status is correctly set after link break [OK}  console=TRUE
    ...  ELSE
    ...  Fail  msg= S1 link status is not correctly set after link break

    ${s1InducedCellDeactDelayTime}=  convert to string  ${s1InducedCellDeactDelayTime[0]}
    Log  TC will sleep now for: ${s1InducedCellDeactDelayTime} seconds (Value of s1InducedCellDeactDelayTime parameter)  console=true
    Sleep  ${s1InducedCellDeactDelayTime}

    Get all LTE Tx Power from all RMs  ${allRMODsWCDMAPowerAfterLinkBreak}

    ${cellStatus}=  run keyword and return status  Assert Every    LNCEL    operationalState=${Disabled_}  timeout=60

    run keyword if  ${cellStatus}
    ...  Log  All LTE Cells state are set correctly after s1 link break [OK}  console=TRUE
    ...  ELSE
    ...  Fail  msg= LTE Cells state are wrong after s1 link break. Link will be restored

    Check not affected resources status


Check not affected resources status
    [Documentation]  To check if not affected technologies are available GSM + WCDMA

    Log  Checking not affected resources having TOP availability in mind  console=true

    Log  TOP status at the beggining of TC is: ${TOP}  console=true
    Log  TOP status after link break is: ${topStatus}  console=true

    Log  Checking other commissioned cells state. TOP availability is incudled in check.  console=true

    Run Keyword If  ${SCF_COUNT_GSM}
    ...  run keywords  Check GSM cells with TOP  AND  Check Abis link s1 link break

    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  run keywords  Check WCDMA cells with TOP  AND  Check CNBAP and DNBAP link s1 link break

Check Abis link s1 link break
    ${statusAbis}=  run keyword and return status  Abis link status  Available
    run keyword unless  ${statusAbis}
    ...  Fail  msg= Abis link status is not correctly set after link break

Check CNBAP and DNBAP link s1 link break
    ${statusCNBAP}=  run keyword and return status  CNBAP link status  Available
    run keyword unless  ${statusCNBAP}
    ...  Fail  msg= CNBAP link status is not correctly set after link break

    ${statusDNBAP}=  run keyword and return status  DNBAP link status  Available
    run keyword unless  ${statusDNBAP}
    ...  Fail  msg= DNBAP link status is not correctly set after link break

Check GSM cells with TOP
    [Documentation]  To check state of GSM cells after s1 link break including TOP availability

    run keyword if  '${TOP}' == 'Available' and '${topStatus}' == 'Available'
    ...  Check GSM cells  ${Active_}  ${Enabled_}
    ...  ELSE IF  '${TOP}' != 'Available' and '${topStatus}' != 'Available'
    ...  Check GSM cells  ${Active_}  ${Enabled_}
    ...  ELSE
    ...  Check GSM cells  ${Active_}  ${Enabled_}  ${Degraded_}

Check WCDMA cells with TOP
    [Documentation]  To check state of WCDMA cells after s1 link break including TOP availability

    run keyword if  '${TOP}' == 'Available' and '${topStatus}' == 'Available'
    ...  Check WCDMA cells  ${Active_}  ${Enabled_}
    ...  ELSE IF  '${TOP}' != 'Available' and '${topStatus}' != 'Available'
    ...  Check WCDMA cells  ${Active_}  ${Enabled_}
    ...  ELSE
    ...  Check WCDMA cells  ${Active_}  ${Enabled_}  ${Degraded_}


step4: Restore s1 link connection
    [Documentation]  In this step s1 link connection will be restored.

    Log  \nStep4: Restore s1 link connection.    console=yes

    Run Keyword If  '${Switch_type}'=='Nokia_7210' or '${Switch_type}'=='Nokia_Nuage'
    ...  Wait until keyword succeeds  5min  1min  Connect to Nokia serving switch and perform action
    ...  ${Switch_IP}  ${Switch_USER}  ${Switch_PASSWORD}  ${LTEVlan}  ${INTERFACE_ID}  no shutdown

    Sleep  300s


step5: Check links state after links were restored and all cells state
    [Documentation]  In this step links state and cells state will be checked after link has been restored.

    Log  \nStep5: Check links state and cells state after Link has been restored.    console=yes

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
       Run Keyword Unless  ${lengthStatus}  Log  Amount of TxPowers are different, investigation should be started [NOK]
       Run Keyword If  ${as_required}  Log  TxPowers are not different with given dBm tolerance [OK]  console=true
       Run Keyword If  ${lengthStatus}  Log  Amount of TXs is the same [OK]  console=true
    END

    Admin Check Active Alarms TAF


TC Setup
    Common test setup  tc_name=FM__link_break_s1_long

TC Teardown
    Run Keyword If Test Failed  Restore link  ${LTEVlan}
    Common test teardown