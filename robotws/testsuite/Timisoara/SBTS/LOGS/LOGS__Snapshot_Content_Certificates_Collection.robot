*** Settings ***
Library     OperatingSystem
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    ../resources/verdicts.robot
Resource    ../resources/BTS_log_level.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${CERTIFICATE_FILE_PATH}            /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/certificate/caCert.pem
# Certificate file location. Default value: /home/ute/btsauto/hran_ta/config/TL_LOCATION/TL_NAME/caCert.pem
${SNAPSHOT_COLLECTION_TIMEOUT}      1200
# Timeout for snapshot collection. Default value: 1200 (seconds)


*** Keywords ***
TC__LOGS__Snapshot_Content_Certificates_Collection
    [Documentation]
    ...  [CASE LINK] https://jira3.int.net.nokia.com/browse/TAT-14662
    ...
    ...  *****************
    ...  The purpose of this test case is to check if previously loaded certificates are saved in snapshot.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  19.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-14662 - initial creation
    ...  02.06.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21421
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-07-19 - TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...  - 2023-04-24 - TAT-25131 - hran_snapshot analysis refactoring to taf.ul.verify_snapshot UL usage
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Snapshot_Content_Certificates_Collection.robot.png#


    Set Tags    CA-LOGS    OWNER-lukasz.targonski@nokia.com    AUTHOR-lukasz.targonski@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS18    SW-SBTS19
    ...    FEATURE-RP000933

   Test_Step.1 Upload Certificate File
   Test_Step.2 Check If Collected Snapshot Includes Certificate File


Test_Step.1 Upload Certificate File
    [Documentation]     In this test certificate file is uploaded to BTS.

    Log  \n Test_Step.1 Upload Certificate File.  console=${True}
    BTS_log_level.WebEM Login
    BTS_log_level.Upload Certificate File  ${CERTIFICATE_FILE_PATH}
    Log  Certificate file successfully uploaded.  console=${True}

    [Teardown]  Close Browser

Test_Step.2 Check If Collected Snapshot Includes Certificate File
    [Documentation]     In this test it is checked if certificate file uploaded in Test_Step.1 is included in collected snapshot file

    Log  \nTest_Step.2 Check If Collected Snapshot Includes Certificate File.  console=${True}
    ${timestamp}=  Get time
    ${timestamp}=  Replace string using regexp  ${timestamp}  (${SPACE}|:|-)  _
    ${path_to_snapshot}=  Set Variable  ${BTS_Files}/snapshot_${timestamp}
    ${file_name}=  Create List  .*root_cert_0f8c_ebca1f6d*
    ${mandatory_file}=  Create Dictionary  mandatory_file  ${file_name}  not_mandatory_file  ${EMPTY}
    Log  Snapshot will be collected.  console=${True}
    coam.Collect Snapshot  ${path_to_snapshot}  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}

    ${found_file_dict}  snapshot.Get Data From Snapshot  ${path_to_snapshot}
    snapshot.Validate Snapshot Using Custom Data  ${found_file_dict}  ${mandatory_file}
    Log  Certificate file found in snapshot.  console=${True}

Remove Certificate
    Log  Previously uploaded certificate will be removed  console=${True}
    BTS_log_level.WebEM Login
    ${cert_status}   Run Keyword And Return Status   BTS_log_level.Remove Certificate File
    Run Keyword If   ${cert_status}
    ...   Log  Certificate removed.  console=${True}
    ...   ELSE
    ...   verdicts.Set Test Failed  Please, remove BTS certificate manually if upload succeeded, because automatic cert removal failed.  ${TRUE}
    [Teardown]  Close Browser


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    Remove Certificate
    ...    AND    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
