*** Settings ***
Documentation
    ...  Step 1: Turn on files enrichment
    ...  Step 2: Changing BTS name and Cell name
    ...  Step 3: Wait Until New PM Is Available on BTS and check it
    ...  Step 4: Turn off files enrichment
    ...  Step 5: Wait Until New PM Is Available on BTS and check it
    ...  Step 6: Turn on files enrichment
    ...  Step 7: Wait Until New PM Is Available on BTS and check it

Resource  ../../common_resources/ca_PM_general.robot
Resource  ../../common_resources/ca_ONAP_general.robot


*** Keywords ***
TC__ONAP__5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable
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
    Step 2: Changing BTS Name And Cell Name
    Step 3: Wait Until New PM Is Available On BTS And Check It
    Step 4: Turn Off Files Enrichment
    Step 5: Wait Until New PM Is Available On BTS And Check It
    Step 6: Turn On Files Enrichment
    Step 7: Wait Until New PM Is Available On BTS And Check It


Step 1: Turn On Files Enrichment
    [Documentation]
    ...  In this step test turning on files enrichment.

    Log  \nTC_5GC001556_3GPP_XML_measurement_file_enrichment_disable_enable started  console=true
    Log  \nStep 1: Turn on files enrichment  console=true
    Turn On Files Enrichment  true


Step 2: Changing BTS Name And Cell Name
    [Documentation]
    ...  In this step test changing BTS name and Cell name.

    Log  \nStep 2: Changing BTS name and Cell name  console=true
    Change BTS Name
    Change Cell Name


Step 3: Wait Until New PM Is Available On BTS And Check It
    [Documentation]
    ...  In this step test is waiting until new PM is available on BTS, downloading, extracting and checking PM for custom bts name and cell name.

    Log  \nStep 3: Wait Until New PM Is Available on BTS and check it  console=true
    Wait Until Keyword Succeeds  6min  1min
    ...  Wait Until New PM Is Available On BTS
    Log  \nSet Latest PM from BTS  console=true
    Set Latest PM From BTS
    Log  \nSFTP download PM, extract ${LATEST_PM_ON_BTS}.gz and check it  console=true
    SFTP Download PM And Extract  ${LATEST_PM_ON_BTS}.gz
    Check PM For Custom Bts Name  ${LATEST_PM_ON_BTS}
    Check PM For Custom Cell Name  ${LATEST_PM_ON_BTS}


Step 4: Turn Off Files Enrichment
    [Documentation]
    ...  In this step test turning OFF files enrichment.

    Log  \nStep 4: Turn off files enrichment console=true
    Turn On Files Enrichment  false


Step 5: Wait Until New PM Is Available On BTS And Check It
    [Documentation]
    ...  In this step test is waiting until new PM is available on BTS, downloading, extracting and checking PM for custom bts name and cell name.

    Log  \nStep 5: Wait Until New PM Is Available on BTS and check it  console=true
    Wait Until New PM Is Available On BTS
    Log  \nSet Latest PM from BTS  console=true
    Set Latest PM From BTS
    Log  \nSFTP download PM, extract ${LATEST_PM_ON_BTS}.gz and check it  console=true
    SFTP Download PM And Extract  ${LATEST_PM_ON_BTS}.gz
    Run Keyword And Expect Error  *
    ...  Check PM For Custom Bts Name  ${LATEST_PM_ON_BTS}
    Run Keyword And Expect Error  *
    ...  Check PM For Custom Cell Name  ${LATEST_PM_ON_BTS}


Step 6: Turn On Files Enrichment
    [Documentation]
    ...  In this step test turning on files enrichment.

    Log  \nStep 6: Turn on files enrichment  console=true
    Turn On Files Enrichment  true


Step 7: Wait Until New PM Is Available On BTS And Check It
    [Documentation]
    ...  In this step test is waiting until new PM is available on BTS, downloading, extracting and checking PM for custom bts name and cell name.

    Log  \nStep 7: Wait Until New PM Is Available on BTS and check it  console=true
    Wait Until New PM Is Available On BTS
    Log  \nSet Latest PM from BTS  console=true
    Set Latest PM From BTS
    Log  \nSFTP download PM, extract ${LATEST_PM_ON_BTS}.gz and check it  console=true
    SFTP Download PM And Extract  ${LATEST_PM_ON_BTS}.gz
    Check PM For Custom Bts Name  ${LATEST_PM_ON_BTS}
    Check PM For Custom Cell Name  ${LATEST_PM_ON_BTS}


TC Setup
    Common Test Setup  tc_name=ONAP__3GPP_XML_measurement_file_enrich_disable_enable
    ONAP 5GC001556 Test Setup


TC Teardown
    ONAP 5GC001556 Test Teardown
    Common Test Teardown
