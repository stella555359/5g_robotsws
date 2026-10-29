*** Settings ***
Documentation
    ...  Step1: Collect Snapshot
    ...  Step 2: Check content of package
    ...  Vaildate content snapshot.zip

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${SNAPSHOT_TIMEOUT}  600  # timeout for collect snapshot via Admin (in sec)


*** Keywords ***
TC__LOGS__Snapshot
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-4059
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 20.10.2016 - https://jira3.int.net.nokia.com/browse/TAT-4059 - Initial creation
    ...  - 13.12.2016 - https://jira3.int.net.nokia.com/browse/TAT-4906 - Added work around collecting snapshot when ADMIN API fail.
    ...  - 06.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-5718 - Corrected path to snapshot
    ...  - 07.04.2017 - https://jira3.int.net.nokia.com/browse/TAT-6201 - Corrected path to snapshot_spec.json after change in workspace
    ...  - 19.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-7040 - Updated documentation
    ...  - 11.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7984 - Snapshot test checks LNBTS in WG configuration
    ...  - 06.06.2018 - https://jira3.int.net.nokia.com/browse/TAT-10398 - Increase Timeout for ute_admin.Collect Snapshot to 600 sec
    ...  - 06.08.2018 - https://jira3.int.net.nokia.com/browse/TAT-11105 - Collect snapshot via SSH is not needed
    ...  - 21.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15389 - Added ${SNAPSHOT_TIMEOUT}
    ...  - 26.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-16002 - Fixed JSON specification file's path after flattening structure
    ...  - 22.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-16256 - Change MAINTAINER and GROUP_IN_CHARGE
    ...  - 14.06.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21468 - change snapshot_spec.json to snapshot_spec.xml and del ptp_data from file
    ...  - 24.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25290 - fix problem for 'str' object has no attribute 'items'
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-4059.png#
    ...

    Set Tags  CA-LOGS  OWNER-lukasz.targonski@nokia.com  AUTHOR-joanna.bielawska@nokia.com  MAINTAINER-iasmin.tomici@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001145_RP000933  FEATURE-RP001486_RP000933

    Step1: Collect Snapshot
    Step 2: Check Content Of Package


Step1: Collect Snapshot
    Log  Step1: Collect Snapshot  console=true
    @{time}  Get Time  year month day hour min
    ${snapshot_status}  Run Keyword And Return Status
    ...  Collect Snapshot  ${BTS_FILES}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If  ${snapshot_status}
    ...  Collecting Snapshot Succeeded  ${time}
    ...  ELSE
    ...  Set Test Failed  TC failed - Collecting snapshot using admin has failed  fail_fast=True


Step 2: Check Content Of Package
    Log  Step 2: Check content of package  console=true
    ${found_file_dict}  Get Data From Snapshot  ${PATH_TO_SNAPSHOT}
    ${path_to_xml_spec_file}  Join Path  ${CURDIR}  tc_variables  snapshot_spec.xml
    Validate_snapshot_using_custom_data  ${found_file_dict}  ${path_to_xml_spec_file}


Collecting Snapshot Succeeded
    [Arguments]  ${time}

    Log  Collecting snapshot via admin succeeded  console=true
    Set Test Variable  ${PATH_TO_SNAPSHOT}  ${BTS_FILES}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip


TC Setup
    Common Test Setup  tc_name=LOGS__Snapshot


TC Teardown
    Common Test Teardown
