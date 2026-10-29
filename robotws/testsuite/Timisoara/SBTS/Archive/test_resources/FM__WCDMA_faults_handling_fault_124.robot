*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${TestedFault}  124     # [MANDATORY] Fault which is tested/ added only for further use


*** Keywords ***
TC__FM__WCDMA_faults_handling_fault_124
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-6476
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  In thise TC fault 124 Not enough DSP capacity to set up a cell is being tested.
    ...  It's being triggerd in OMS via CellRange parameter change for specific number of cells
    ...  The tested configuration must be specific, because there are specific preconditions to have possibility to trigger tested fault
    ...  Card which is hosting WCDMA have some RACH Elements capacity (different DSP modes), it must be exceeded for fault 124 to be triggered
    ...  RachHandlerElemet consumed by a single cell is calculated in following way:
    ...  RachHandlerElemet = RoundUP(r/5km) * 5 * RACHSig * RxAmount
    ...  WCDMA BB Calculator may be useful here: wcdmacalc.swat-ci.dynamic.nsn-net.net
    ...  FSMF hint: While WCDMA and GSM are deployed on the internal FSP, to generate fault 124, it is recomended to create 2 LCGs for WCDMA.
    ...  1st LCG with 6 full HSPA cells, 2nd LCG with 6 R99 cells.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.05.2017 - https://jira3.int.net.nokia.com/browse/TAT-6576 - Initial TAT creation
    ...  - 04.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7540 - Correced wrong alarm verification in Step5
    ...  - 04.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7557 - Changed that snapshot is collected always in teardown
    ...  - 19.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7983 - Cell range changed to default values if affected cell state is wrong
    ...  - 27.04.2018 - https://jira3.int.net.nokia.com/browse/TAT-8956 - Unnecessary global variables hidden
    ...  - 11.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15037 - Replacement of depracated KW "check_if_target_is_available"
    ...  - 18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  - 14.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16601 - FOR loop syntax updated
    ...  - 20.08.2019 - https://jira3.int.net.nokia.com/browse/TAT-17024 - Add Wait until keyword succeeds at check wcdma states
    ...  - 29.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17799 - Resolved hardoced variables regarding RNC_id and OMS_ip
    ...  - 29.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18904 - Add RNC_user and RNC_password as parameters for Nwi3 set oms connection
    ...  - 13.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19471 - Aligment with taf.rnc.oms.nwi3 library for FM test cases that use nwi3
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  *******************

    Set Tags    CA-FM    OWNER-laura.craciunel@nokia.com    AUTHOR-rafal.ozga@nokia.com    MAINTAINER-laura.craciunel@nokia.com
    ...    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS17A    FEATURE-RP001534

    step1: Specific Preconditions
    step2: Trigger FaultID: 124 and verify alarms
    step3: States verification after fault is triggered
    step4: Cancel Fault
    step5: Verify Alarms and States after fault is cancelled


step1: Specific Preconditions
    [Documentation]  In this step specific preconditions will be checked. WCDMA deployment needed, WCDMA cells checked under specific pattern

    Log  step1: Checking specific preconditions  console=true


    ${WcdmaCells}=  Convert to String  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/WNBTS_M-1/CELL_M-*
    set test variable  ${WcdmaCells}
    ${IdsOfRNCandWBTS}=  Convert to String  /MRBTS-1/RAT-1/WTS-1/RNC_L-*
    set test variable  ${IdsOfRNCandWBTS}
    ${OmsRncAddresses}=  create dictionary  252=10.92.249.149
    set test variable  ${OmsRncAddresses}

    Checking if fault 124 is choosen as input  ${TestedFault}

    Querring infomodel for current technology deployment and check if WCDMA is commissioned

    Check WCDMA cells status

    Checking RNCid and WBTSid from IM

    Find OMS IP ADDRESS  ${OmsRncAddresses}  ${rncID}


step2: Trigger FaultID: 124 and verify alarms
    [Documentation]  In this step connection to OMS will be established and fault 124 will be triggered


    Log  step2: Triggering fault 124 and alarms verification  console=true

    Checking availability of target OMS  ${rncID}  ${OmsRncAddresses}

    Get all WCELLS IDs

    Connecting to OMS and triggering fault 124


step3: States verification after fault is triggered
    [Documentation]  In this step affected WCDMA cell status and reasoning status under WTS is changed

    Log  step3: States verification is started  console=true

    Check WCDMA cells status with fault 124 visible  ${cellAmount}  operationalState=disabled  availabilityStatus=failed

    Check reasoningStatus


step4: Cancel Fault
    [Documentation]  In this step changed cells are being restored to default values

    Log  step4: Canceling fault 124  console=true

    Canceling fault 124  ${cells}  ${rncID}  ${wbtsID}  ${cellAmount}

step5: Verify Alarms and States after fault is cancelled
    [Documentation]  To vefify alarams on objects all WCDMA cells and WTS

    Log  step5: Veryfing alarms and states after fault cancellation  console=true

    Verify alarams after fault cancelation

    Wait until keyword succeeds  60  10  Check WCDMA cells status

    Check reasoningStatus after fault cancelation

    Log  Test case execution ended, fault 124 was triggered and cancelled succesfuly  console=true


########################################################################################################################

Checking if fault 124 is choosen as input
    [Arguments]  ${TestedFault}
    [Documentation]  To check if fault 124 is selected as input (written in case of further development

    run keyword if  ${TestedFault}==124
    ...   log to console   TestedFault is 124: Not enough DSP capacity to set up a cell
    ...   ELSE
    ...   Fail  msg=Tested Fault is different than expected (!=124). Breaking execution.

Querring infomodel for current technology deployment and check if WCDMA is commissioned
    [Documentation]  To check if WCDMA is deployed on SBTS

	${deploymentLIST}  create list
    ${deployment}=  query infomodel  get list /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/LAYOUT_MAP-1/LAYOUT_ENTITY-*
    set global variable  ${deployment}
    log   ${\n}Current deployment under LAYOUT_ENTITY-* is:  console=true
    FOR  ${entity}  IN  @{deployment}
       Log  ${entity.deployment} deployed on: ${entity.bbuDN}  console=true
    END
    Log  ${\n}  console=true
    FOR  ${entity}  IN  @{deployment}
       Check if WCDMA commissioned  ${entity.deployment}
       run keyword if  ${wcdmaSTAT}
       ...  append to list  ${deploymentLIST}  ${entity.deployment}
    END


    ${status}=  get length  ${deploymentLIST}
    run keyword if  ${status} > 0
    ...   log to console   WCDMA is deployed test will be continued
    ...   ELSE
    ...   Fail  msg=WCDMA is not deployed, fault 124 cannot be triggerd. Breaking execution.

Check if WCDMA commissioned
   [Arguments]  ${deployment}
   [Documentation]  To check if WCMDA is available in given deployment list

   Log  Checking if WCDMA is deployed under ${deployment}  level=INFO  console=true
   ${converted}  Convert to string  ${deployment}
   ${wcdmaSTAT}=  run keyword and return status  should contain   ${converted}  WCDMA
   set global variable  ${wcdmaSTAT}
   Log  ${wcdmaSTAT}  console=true

Check WCDMA cells status
    [Documentation]  To check if WCDMA cells before and after fault triggering have suitable states

	${wcdmaCells}=  convert to string  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/WNBTS_R-1/WNCEL_R-*
    ${wcdmaCellStatus}=  query infomodel  get list ${WcdmaCells}  timeout=30

    FOR  ${cell}  IN  @{wcdmaCellStatus}
    #\  Should be equal    ${cell.routingState}  Routable  msg=Wrong routingState in ${cell.dist_name}
    #\  Should be equal    ${cell.stateInfo['proceduralState']}  OnAirDone  msg=Wrong proceduralState in ${cell.dist_name}
       Should be equal    ${cell.operationalState}  enabled  msg=Wrong operationalState in ${cell.dist_name}
    END
    Log  All cells have proper states.  console=true
    Log  WCDMA cells status checked, test will continue...  console=true
    set global variable  ${wcdmaCellStatus}

Print dictionary
    [Arguments]  ${OmsRncAddresses}

    log    Dictionary will be printed  console=true
    FOR    ${key}  IN  @{OmsRncAddresses.keys()}
       Log  ${OmsRncAddresses["${key}"]}  console=true
    END

Find OMS IP ADDRESS
    [Arguments]  ${OmsRncAddresses}  ${rncID}
    [Documentation]  To read adequate OMS IP ADDRESS from defined dictionary OmsRncAddresses

    log  Checking if OMS dictionary has suitable IP address for RNC: ${rncID}  console=true
    ${converted}=  convert to string  ${rncID}
    ${status}=  run keyword and return status  should contain  ${OmsRncAddresses.keys()}  ${converted}
    run keyword if  ${status}
    ...  Log  OMS IP addres is ${OmsRncAddresses["${rncID}"]}  console=true
    ...  ELSE
    ...  Fail  There is no corresponding IP address for ${rncID}, fault 124 cannot be triggerd. Breaking execution.  console=true

Checking availability of target OMS
    [Arguments]  ${rncID}  ${OmsRncAddresses}
    [Documentation]  Checking availability of OMS

    ${status}=  check_if_target_is_stable  ${OmsRncAddresses["${rncID}"]}  30  30  90
    run keyword if  ${status}
    ...  Log  OMS IP address ${OmsRncAddresses["${rncID}"]} is reachable, test will be continued  console=true
    ...  ELSE
    ...  Fail  msg=OMS IP address ${OmsRncAddresses["${rncID}"]} is not reachable, test will be set as failed


Get all WCELLS IDs
    [Documentation]  To get all WCDMA IDs which will be used to create a OMS querry

    ${cells}=  Infomodel Get All WCELL IDs
    set global variable  ${cells}
    Log  List of WCELL IDs fetched from Infomodel to be tested: ${cells}  console=True

    [Return]  ${cells}

Connecting to OMS and triggering fault 124
    [Documentation]  Used to connect OMS and iteratively change CellRanges to cause fault 124, number of cells changed is  saved

    ${faultStatus}=  Set Variable  ${FALSE}
    ${cellAmount}=  Set Variable  0
    ${oms_params_status}=  Run keyword and return status
    ...  Setup NWI3  ${rncID}  ${OmsRncAddresses["${rncID}"]}  ${RNC["RNC_USER"]}  ${RNC["RNC_PASSWORD"]}
    Run keyword unless  ${oms_params_status}  Fail  msg= Error during OMS parameters setting
    ${EXPECTED_ALARM}=     Create Dictionary  faultId=124  severity=Critical  number=7114
    ${EXPECTED}=  create list  ${EXPECTED_ALARM}
    Log  ${EXPECTED}  console=true
    FOR  ${cell}  IN  @{cells}
       Change WCELL CellRange value from OMS  ${cell}  ${rncID}  ${wbtsID}
       Sleep  10
#    \  log  Number of cells before incrementation ${cellAmount}  console=true
       ${cellAmount}=  evaluate  ${cellAmount}+1
#    \  log  Numhber of cells after incrementation ${cellAmount}  console=true
       ${faultStatus}=  Run Keyword And Return Status  Admin Check Active Alarms TAF  expected_patterns=${EXPECTED}  print_alarms=${False}
       Run Keyword If  '${faultStatus}' == 'True'  run keywords  Log     FAULT 124 IS PRESENT   console=${TRUE}  AND  exit for loop
    END

    run keyword if  '${faultStatus}' == 'False'  run keywords
    ...  restore WCELLs CellRange to default value from OMS  ${cells}  ${rncID}  ${wbtsID}  ${cellAmount}  AND
    ...  Fail  Fault 124 is not visible after all cells have CellRange changed. After case execution cells are restored to default values.
    set global variable  ${cellAmount}
    set global variable  ${faultStatus}
    set global variable  ${cell}

    [Return]  ${cellAmount}  ${faultStatus}


Change WCELL CellRange value from OMS
    [Documentation]  To change CellRange value in OMS for specified cell
    [Arguments]  ${wcell}  ${rncID}  ${wbtsID}

    ${cellRange}=  evaluate  100000
    ${wcell}=  convert to string  ${wcell}
    ${rncID}=  convert to string  ${rncID}
    ${wbtsID}=  convert to string  ${wbtsID}
    ${path}=  convert to string  RNC-${rncID}/WBTS-${wbtsID}/WCEL-${wcell}
    Log  Reading current value of CellRange for: ${path}  console=true
    ${cellRange2}=  Get WCEL Parameter  ${wbtsID}  ${wcell}  CellRange
    Log  Read value of CellRange is: ${cellRange2}  console=true
    ${isEqual}=  run keyword and return status  should not be equal  ${cellRange2}  100000
    run keyword unless  ${isEqual}
    ...  Change CellRange Value  ${cellRange}
    ${cellRange}=  convert to string  ${cellRange}
    Log  Change OMS CellRange of WCELL-${wcell} to ${cellRange}m value  console=true
    ${oms_data}=    Create Dictionary
    Set To Dictionary    ${oms_data}    CellRange    ${cellRange}
    Log  ${oms_data}
    ${status}=   Run keyword and return status  Set WCEL Parameters  ${wbtsID}  ${wcell}  &{oms_data}
    Run keyword unless  ${status}  Fail  msg= Error during OMS parameters change


Change CellRange Value
    [Arguments]  ${cellRange}
    ${cellRange}=  evaluate  ${cellRange}-100
    set test variable  ${cellRange}

Restore WCELLs CellRange to default value from OMS
    [Documentation]  To change CellRange to default value in OMS for specified cell
    [Arguments]  ${wcell_ids}  ${rncID}  ${wbtsID}  ${amounfOfCellsChanged}

    FOR  ${wcell}  IN  @{wcell_ids}
        ${path}=  convert to string  RNC-${rncID}/WBTS-${wbtsID}/WCEL-${wcell}
        Log  Change OMS CellRange of WCELL-${wcell} to initial value  console=true
        ${oms_data}=    Create Dictionary
        Set To Dictionary    ${oms_data}    CellRange    2000
        Log  ${oms_data}
        ${status}=   Run keyword and return status  Set WCEL Parameters  ${wbtsID}  ${wcell}  &{oms_data}
        Run keyword unless  ${status}  Fail  msg= Error during OMS parameters change
        ${amounfOfCellsChanged}=   evaluate  ${amounfOfCellsChanged}-1
        Run keyword if  ${amounfOfCellsChanged} == 0  exit for loop
    END


Check WCDMA cells status with fault 124 visible
    [Documentation]  To check if WCDMA cell states are correct when fault 124 is active
    [Arguments]  ${lastCellChanged}  ${scope}=${EMPTY}  &{parametersStates}

    ${distName}=  convert to string  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/WNBTS_R-1/WNCEL_R-${cell}

    ${cellParams}=  Get Infomodel Object  ${distName}
    ${as_required} =  Run Keyword And Return Status  Dictionary Should Contain Key  ${cellParams${scope}}  ${parametersStates}
    Run Keyword Unless  ${as_required}  run keywords
    ...  restore WCELLs CellRange to default value from OMS  ${cells}  ${rncID}  ${wbtsID}  ${lastCellChanged}  AND
    ...  Fail  Cell status with fault 124 is wrong. After case execution cells are restored to default values.
    Run Keyword If  ${as_required}
    ...  Log  All states of affected cell are correctly set ${parametersStates}  console=true

    Log  wcellid of last changed cell is ${cell}  console=true

Check reasoningStatus
    [Documentation]  To check if reasoning status under WTS is correct

    ${distName}=  convert to string  /MRBTS-1/RAT-1/WTS-1/WBTS_L-1/WNCEL_L-${cell}
    ${wtsParams}=  query infomodel  get list ${distName}
    FOR  ${element}  IN  @{wtsParams}
       run keyword unless  '${element.stateInfo.reasoningStatus[0]}' == 'NotEnoughBasebandCapacityToSetUpCell'  run keywords
       ...    Restore WCELLs CellRange to default value from OMS  ${cells}  ${rncID}  ${wbtsID}  ${cellAmount}  AND  FAIL
    END

    Log  Reasoning status of affected cell is correctly set to NotEnoughBasebandCapacityToSetUpCell  console=true

Canceling fault 124
    [Documentation]  To cancel fault 124 by changing WCELLs CellRange to default value in OMS
    [Arguments]  ${cells}  ${rncID}  ${wbtsID}  ${cellAmount}

    run keyword if  '${faultStatus}' == 'True'  run keywords
    ...  restore WCELLs CellRange to default value from OMS  ${cells}  ${rncID}  ${wbtsID}  ${cellAmount}  AND
    ...  Log  Fault 124 was triggerd. After case execution cells are restored to default values.  console=true


Verify alarams after fault cancelation
    [Documentation]  To check the presence of fault 124 after it was cancelled

    ${CRITICAL_ALARM}=      Create Dictionary    faultId=124  severity=Critical  number=7114
    ${CRITICAL}=    Create List  ${CRITICAL_ALARM}
    ${faultStatus}=  Run Keyword And Return Status  Admin Check Active Alarms TAF  critical_patterns=${CRITICAL}
    Run Keyword IF  '${faultStatus}' == 'Fail'  Set Test Failed     FAULT 124 IS PRESENT AFTER CANCELATION

Check reasoningStatus after fault cancelation
    [Documentation]  To check if reasoning status under WTS is empty

    ${distName}=  convert to string  /MRBTS-1/RAT-1/WTS-1/WBTS_L-1/WNCEL_L-${cell}
    ${wtsParams}=  query infomodel  get list ${distName}
    FOR  ${element}  IN  @{wtsParams}
       should be equal  '${element.stateInfo.reasoningStatus}'  '[]'  msg=Wrong reasoningStatus in ${element.dist_name}
    END

    Log  Reasoning status of affected cell is correctly after cancelling fault 124  console=true


TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown


