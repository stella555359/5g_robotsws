*** Settings ***
Library     DateTime
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library     taf.ul.verify_snapshot   WITH NAME  snapshot

*** Variables ***
${SNAPSHOT_TIMEOUT}             1200                      #timeout for collect snapshot via Admin (in sec)


*** Keywords ***
TC__LOGS__LTE2866-A-n_Technical_log_collection_Snapshot_canceled_in_dual_core
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24297
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  This use case is to verify if snapshot could be canceled
    ...  This covers an EDA action involving checking whether the snapshot will download correctly
    ...  after a snapshot that was canceled
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 09.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24297 - Test rewritten based on BOAM ET test
    ...    OAM_LTE2866-A-n_Technical log collection_Snapshot canceled in dual core
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 13.07.2023 - TAT-25751 - refactor to keep coding and naming convention
    ...  - 18.12.2023 - TAT-26613 - refactor TC and add action for EDA - PR738341
    ...

    Set Tags    CA-LOGS    AUTHOR-marta.falandys@nokia.com    MAINTAINER-jakub.kokoszka@nokia.com
    ...    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS23R1    FEATURE-LTE2866


    Step 1: Collect Snapshot and canceled after triggered
    Step 2: Collect Snapshot and canceled after triggered
    Step 3: Collect Snapshot and check content and file size



Step ${n}: Collect Snapshot and canceled after triggered
    [Documentation]
    ...  In this test step, snapshot will be canceled after it has started

    Log  Step ${n}: Get Snapshot and canceled after triggered  console=${True}

    ${second_connection}  coam.Connect To  name=${n}_second_connection
    coam.Run Keyword In Background  Collect Snapshot  ${BTS Files}/${n}_CanceledLocalSnapshot.zip  connection=${n}_second_connection
    ${local_snapshot_status}  Query Infomodel  check /MRBTS-*/RAT-*/ASM-*/TECHREP_L-*/SNAPSHOT-* is [originator=ADMIN,stateInfo.usageState=Active]
    ...  timeout=60  allow_negative_result=True

    Run Keyword If  ${local_snapshot_status}
    ...  Log  Local Snapshot was triggered.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered.  ${TRUE}

    Log  Initiate cancellation of the snapshot    console=${True}
    ${cancelled}    coam.Snapshot Cancel
    Run Keyword If    '${cancelled}' == 'Collection canceled'
    ...  Log  Local Snapshot was canceled.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not canceled.  ${TRUE}

Step 3: Collect Snapshot and check content and file size
    [Documentation]
    ...  In this test step, snapshot will be collected
    ...  content and filesize will be checked
    ...  This step covers an EDA action involving checking whether the snapshot will download correctly
    ...  after a snapshot that was canceled

    Log  Step 3: Collect Snapshot and check content and file size  console=${True}

    ${snapshot_status}    Run Keyword And Return Status
    ...    coam.Collect Snapshot    ${BTS Files}/LocalFullSnapshot.zip    Full    timeout=${SNAPSHOT_TIMEOUT}
    Set Test Variable  ${path_to_snapshot}  ${BTS Files}/LocalFullSnapshot.zip

    Run Keyword If    ${snapshot_status}
    ...    Log    Collecting Snapshot Succeeded  console=${True}
    ...    ELSE
    ...    verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.  ${TRUE}

    Log    Check content of package  console=${True}
    ${Found_file_dict}    snapshot.Get Data From Snapshot    ${path_to_snapshot}
    ${path_to_xml_spec_file}  join path  ${CURDIR}  tc_variables  snapshot_spec.xml
    snapshot.Validate Snapshot    ${Found_file_dict}    ${path_to_xml_spec_file}
    Log    Content of package correct    console=${True}

    Log    Check Snapshot Filesize  console=${True}
    ${size}=     Get File Size    ${path_to_snapshot}
    Log  Snapshot filesize= ${size} (should be more than 8700000)  console=${True}
    Run Keyword If    ${size}>8700000    Log  \n${size} bytes is between right full Snapshot size range  console=${True}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
