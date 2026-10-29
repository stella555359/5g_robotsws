*** Settings ***
Documentation
    ...  The purpose of this test case is to check if snapshot file can be downloaded from BTS via ADMIN CLI
    ...  and checks snapshot with desired content properly generated and "BinaryTracing_FRI_AlarmHistory_*.bro.xz" existing in Snapshot.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28211
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 01.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28211 - Initial TAT creation
    ...  - 18.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28561 - Change path for Snapshot file

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CNI-107641

    Step1: Change ActCli Parameter To Be true
    Step2: Get Snapshot Via ADMIN CLI
    Step3: Check Output Of Snapshot
    Step4: Change ActCli Parameter To Be false


Step${id}: Change ActCli Parameter To Be ${value}
    Log  \nStep${id}: Change actCli parameter to be ${value}  console=true
    Change ActCli Parameter  ${value}


Step2: Get Snapshot Via ADMIN CLI
    [Documentation]  In this step it is checked if Snapshot can be collected via ADMIN CLI

    Log  \nStep2: Get Snapshot Via ADMIN CLI  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"requestType":"procedure","parameters":{"name":"snapshot","parameters":
    ...  {"coverage":"HealthCheck","force":"Yes"}}}
    Log  Sending command via Admin CLI for collect snapshot...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}  output_file=${BTS_FILES}/snapshot_minor.zip
    Run Keyword If  '${request_status}' == 'completed'
    ...  Log  Command sent with status: ${request_status}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}
    Log  Snapshot result 'snapshot_minor' saved in BTSFiles!  console=true


Step3: Check Output Of Snapshot
    Log  \nStep3: Check Output Of Snapshot  console=true
    Unzip  ${BTS_FILES}/snapshot_minor.zip  ${BTS_FILES}/snapshot_minor_dir/
    ${snapshot_file_list}  OperatingSystem.Get file  ${BTS_FILES}/snapshot_minor_dir/snapshot_file_list.txt
    ${matches}  Get Regexp Matches  ${snapshot_file_list}  BTS.*BinaryTracing_FRI_AlarmHistory_[0-9a-z]+.bro.xz
    Run Keyword If  ${matches}
    ...  Log  \nExist files with name BinaryTracing_FRI_AlarmHistory_ in snapshot  console=true
    ...  ELSE
    ...  Fail  Files with name BinaryTracing_FRI_AlarmHistory_ not exist in snapshot.[NOK]
    ${list_of_directories}  OperatingSystem.List Directory  ${BTS_FILES}/snapshot_minor_dir/  pattern=BTS*.zip
    FOR  ${file}  IN  @{matches}
        ${parent_file}  Get Name Of Parent Directory For File  ${list_of_directories}  ${file}
        Run Keyword If  '${parent_file}'!='${None}'
        ...  Log  \n${file} found in ${parent_file}  console=true
        ...  ELSE
        ...  Fail  File ${file} not found in snapshot.[NOK]
    END
    Remove Directory  ${BTS_FILES}/snapshot_minor_dir  true


Get Name Of Parent Directory For File
    [Arguments]  ${list_of_directories}  ${file}

    FOR  ${directory}  IN  @{list_of_directories}
        ${directory_name}  Fetch From Left  ${directory}  .zip
        Unzip  ${BTS_FILES}/snapshot_minor_dir/${directory}  ${BTS_FILES}/snapshot_minor_dir/${directory_name}_dir
        ${directory_content}  OperatingSystem.List Directory  ${BTS_FILES}/snapshot_minor_dir/${directory_name}_dir
        Remove Directory  ${BTS_FILES}/snapshot_minor_dir/${directory_name}_dir  true
        ${status}  Run Keyword And Return Status
        ...  List Should Contain Value  ${directory_content}  ${file}
        Run Keyword If  ${status}
        ...  Return From Keyword  ${directory_name}
    END


TC Setup
    Common Test Setup  tc_name=WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI


TC Teardown
    Run Keyword If Test Failed
    ...  Step4: Change ActCli Parameter To Be false
    Common Test Teardown
