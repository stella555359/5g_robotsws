*** Settings ***
Documentation
    ...  Step 1: Turn on files enrichment
    ...  Step 2: Change BTS name
    ...  Step 3: Waiting Until New PM Is Available on BTS and Getting Latest PM from BTS
    ...  Step 4: Check PM for custom bts name

Resource  ../../common_resources/ca_PM_general.robot
Resource  ../../common_resources/ca_ONAP_general.robot


*** Keywords ***
TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_name_change
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroclaw
    ...  - 01.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29008 - Set reporting interval to 5 min

    Set Tags  CA-ONAP  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-marcin.berkowski@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-5GC001556

    Step 1: Turn On Files Enrichment
    Step 2: Change BTS Name
    Step 3: Waiting Until New PM Is Available On BTS And Getting Latest PM From BTS
    Step 4: Check PM For Custom Bts Name


Step 1: Turn On Files Enrichment
    [Documentation]
    ...  In this step test prepare turn on files enrichment.

    Log  \nStep 1: Turn on files enrichment  console=true
    Set Parameter To New Value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  reportingIntervalPm  5min
    Turn On Files Enrichment  true


Step 2: Change BTS Name
    [Documentation]
    ...  In this step test change BTS name.

    Log  \nStep 2: Change BTS name  console=true
    Change BTS Name


Step 3: Waiting Until New PM Is Available On BTS And Getting Latest PM From BTS
    [Documentation]
    ...  In this step test is waiting until new PM is available on BTS and geting latest PM from BTS.

    Log  Step 3: Waiting Until New PM Is Available on BTS and Getting Latest PM from BTS  console=true
    Wait Until Keyword Succeeds  6min  1min
    ...  Wait Until New PM Is Available On BTS
    Set Latest PM From BTS
    Log  Downloading PM file ${LATEST_PM_ON_BTS}.gz  console=true
    SFTP Download PM And Extract  ${LATEST_PM_ON_BTS}.gz


Step 4: Check PM For Custom Bts Name
    [Documentation]
    ...  In this step test check PM for custom bts name.

    Log  Step 4: Check PM for custom bts name  console=true
    Check PM For Custom Bts Name  ${LATEST_PM_ON_BTS}


TC Setup
    Common Test Setup  tc_name=ONAP__3GPP_XML_measurement_file_enrichment_name_change
    ONAP 5GC001556 Test Setup


TC Teardown
    ONAP 5GC001556 Test Teardown
    Common Test Teardown
