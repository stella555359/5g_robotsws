*** Settings ***
Documentation
    ...  Step 1: Turn on files enrichment
    ...  Step 2: Change BTS and cell name
    ...  Step 3: Waiting Until New PM Is Available on BTS and Getting Latest PM from BTS
    ...  Step 4: Check PM for custom bts and cell name
    ...  Step 5: Removing cell name
    ...  Step 6: Waiting Until New PM Is Available on BTS and Getting Latest PM from BTS
    ...  Step 7: Check PM for custom bts name and no cell name

Resource  ../../common_resources/ca_PM_general.robot
Resource  ../../common_resources/ca_ONAP_general.robot


*** Keywords ***
TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_no_cell_name
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroclaw

    Set Tags  CA-ONAP  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-marcin.berkowski@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-5GC001556

    Step 1: Turn On Files Enrichment
    Step 2: Change BTS And Cell Name
    Step 3: Waiting Until New PM Is Available On BTS And Getting Latest PM From BTS
    Step 4: Check PM For Custom Bts And Cell Name
    Step 5: Removing Cell Name
    Step 6: Waiting Until New PM Is Available On BTS And Getting Latest PM From BTS
    Step 7: Check PM For Custom Bts Name And No Cell Name


Step 1: Turn On Files Enrichment
    [Documentation]
    ...  In this step test prepare turn on files enrichment.

    Log  \nStep 1: Turn on files enrichment  console=true
    Turn On Files Enrichment  true


Step 2: Change BTS And Cell Name
    [Documentation]
    ...  In this step test change BTS and cell name.

    Log  Step 2: Change BTS and cell name  console=true
    Log  Changing BTS name  console=true
    Change BTS Name
    Log  Changing Cell name  console=true
    Change Cell Name


Step 3: Waiting Until New PM Is Available On BTS And Getting Latest PM From BTS
    [Documentation]
    ...  In this step test is waiting until new PM is available on BTS and getting latest PM from BTS.

    Log  Step 3: Waiting Until New PM Is Available on BTS and Getting Latest PM from BTS  console=true
    Log  Waiting Until New PM Is Available on BTS  console=true
    Wait Until Keyword Succeeds  6min  1min
    ...  Wait Until New PM Is Available On BTS
    Log  Getting Latest PM from BTS  console=true
    Set Latest PM From BTS
    Log  Downloading PM file ${LATEST_PM_ON_BTS}.gz  console=true
    SFTP Download PM And Extract  ${LATEST_PM_ON_BTS}.gz


Step 4: Check PM For Custom Bts And Cell Name
    [Documentation]
    ...  In this step test change BTS and cell name.

    Log  Step 4: Check PM for custom bts and cell name  console=true
    Check PM For Custom Bts Name  ${LATEST_PM_ON_BTS}
    Check PM For Custom Cell Name  ${LATEST_PM_ON_BTS}


Step 5: Removing Cell Name
    [Documentation]
    ...  In this step test removing cell name.

    Log  Step 5: Removing cell name  console=true
    Log  Removing cell name  console=true
    Remove Cell Name


Step 6: Waiting Until New PM Is Available On BTS And Getting Latest PM From BTS
    [Documentation]
    ...  In this step test is waiting until new PM is available on BTS and getting latest PM from BTS.

    Log  Step 6: Waiting Until New PM Is Available on BTS and Getting Latest PM from BTS  console=true
    Log  Waiting Until New PM Is Available on BTS  console=true
    Wait Until Keyword Succeeds  6min  1min
    ...  Wait Until New PM Is Available On BTS
    Log  Getting Latest PM from BTS  console=true
    Set Latest PM From BTS
    Log  Downloading PM file ${LATEST_PM_ON_BTS}.gz  console=true
    SFTP Download PM And Extract  ${LATEST_PM_ON_BTS}.gz


Step 7: Check PM For Custom Bts Name And No Cell Name
    [Documentation]
    ...  In this step test check PM for custom bts name and no cell name.

    Log  Step 7: Check PM for custom bts name and no cell name  console=true
    Check PM For Custom Bts Name  ${LATEST_PM_ON_BTS}
    Run Keyword And Expect Error  *
    ...  Check PM For Custom Cell Name  ${LATEST_PM_ON_BTS}


TC Setup
    Common Test Setup  tc_name=ONAP__3GPP_XML_measurement_file_enrichment_no_cell_name
    ONAP 5GC001556 Test Setup


TC Teardown
    ONAP 5GC001556 Test Teardown
    Common Test Teardown
