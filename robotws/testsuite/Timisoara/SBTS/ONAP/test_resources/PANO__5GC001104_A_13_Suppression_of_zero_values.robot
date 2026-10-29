*** Settings ***
Documentation
    ...  Step 1. Turn On Zero Values Suppression
    ...  Step 2. Check if PM XML for DSS counters are NOT present
    ...  Step 3. Turn Off Zero Values Suppression
    ...  Step 4. Check if PM XML for DSS counters are present

Resource  ../../common_resources/ca_PM_general.robot
Resource  ../../common_resources/ca_ONAP_general.robot


*** Keywords ***
TC__PANO__5GC001104_A_13_Suppression_of_zero_values
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroclaw
    ...  - 15.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-29234 - Wait for NR cells to become onAir after turning off DSS

    Set Tags  CA-ONAP  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-marcin.berkowski@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-5GC001104

    Step 1. Turn On Zero Values Suppression
    Step 2. Check If PM XML For DSS Counters Are NOT Present
    Step 3. Turn Off Zero Values Suppression
    Step 4. Check If PM XML For DSS Counters Are Present


Step 1. Turn On Zero Values Suppression
    Log  \nStep 1. Turn On Zero Values Suppression  console=true
    Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  suppressZeroValueCountersReportingIn3GPP  true
    Log  Turn off DSS  console=true
    Set Parameter To New Value  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}  actLteNrDss  false
    Assert Every  NRCEL  operationalState=${ENABLED}  timeout=600
    Log  Set DSS PM interval to 5min  console=true
    Set Parameter To New Value  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1  miNrEnDssPerCell  5min


Step 2. Check If PM XML For DSS Counters Are NOT Present
    Log  \nStep 2. Check if PM XML for DSS counters are NOT present  console=true
    Log  Waiting Until New PM Is Available on BTS  console=true
    Wait Until Keyword Succeeds  6min  1min
    ...  Wait Until New PM Is Available On BTS
    Get PM By SFTP  ${LATEST_PM_ON_BTS}.gz
    UNZIP PM On VM  ${LATEST_PM_ON_BTS}.gz
    Log  Checking PM XML for DSS counters  console=true
    Check If PM XML For DSS Counters Are NOT Present


Step 3. Turn Off Zero Values Suppression
    Log  \nStep 3. Turn Off Zero Values Suppression  console=true
    Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  suppressZeroValueCountersReportingIn3GPP  false


Step 4. Check If PM XML For DSS Counters Are Present
    Log  \nStep 4. Check if PM XML for DSS counters are present  console=true
    Log  Waiting Until New PM Is Available on BTS  console=true
    Wait Until Keyword Succeeds  6min  1min
    ...  Wait Until New PM Is Available On BTS
    Get PM By SFTP  ${LATEST_PM_ON_BTS}.gz
    UNZIP PM On VM  ${LATEST_PM_ON_BTS}.gz
    Check If PM XML For DSS Counters Are Present  ${LATEST_PM_ON_BTS}


Check If PM XML For DSS Counters Are NOT Present
    OperatingSystem.File Should Exist  ${LATEST_PM_ON_BTS}
    ${numb_of_occurance}  Grep File  ${LATEST_PM_ON_BTS}  VS.ENDSS.EN_DSS_KEEP_ALIVE_RESP
    Should Be Empty  ${numb_of_occurance}


Check If PM XML For DSS Counters Are Present
    [Arguments]  ${latest_pm_on_bts}

    OperatingSystem.File Should Exist  ${latest_pm_on_bts}
    ${numb_of_occurance}  Grep File  ${latest_pm_on_bts}  VS.ENDSS.EN_DSS_KEEP_ALIVE_RESP
    Should Not Be Empty  ${numb_of_occurance}


TC Setup
    Common Test Setup  tc_name=PANO__A_13_Suppression_of_zero_values
    ONAP 5GC001104 Test Setup


TC Teardown
    ONAP 5GC001104 Test Teardown
    Common Test Teardown
