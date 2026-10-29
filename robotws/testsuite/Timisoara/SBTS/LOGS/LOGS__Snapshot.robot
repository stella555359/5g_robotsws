*** Settings ***
Documentation  Test for Snapshot collection
#Library    hran_snapshot_analysis
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    ../resources/verdicts.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_TIMEOUT}      600                      #timeout for collect snapshot via Admin (in sec)


*** Keywords ***
TC__LOGS__Snapshot
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-4059
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...
    ...  Step1: Collect Snapshot
    ...  Step 2: Check content of package
    ...  Vaildate content snapshot.zip
    ...  Test case verifies if Snapshot_file_size is in expected range and presence of .*metadata.txt file
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
    ...  - 14.06.2021 - TAT-21468 - change snapshot_spec.json to snapshot_spec.xml and delate ptp_data from file
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 2022-12-16 - https://jiradc.ext.net.nokia.com/browse/TAT-24326 - add checking of Snapshot filesize
    ...                 and metadata.txt file presence (by transfer of OAM_LTE2866-A-n_Technical_Log_Collection_Snapshot_In_Dual_Core TC)
    ...  - 2023-01-19 - https://jiradc.ext.net.nokia.com/browse/TAT-24561 - add checking of unexpected alarms during Snapshot collection.
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-4059.png#
    ...


    Set Tags    CA-LOGS    OWNER-lukasz.targonski@nokia.com    AUTHOR-joanna.bielawska@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CIT    SW-SBTS17    SW-SBTS18
    ...    SW-SBTS19    FEATURE-RP001145_RP000933    FEATURE-RP001486_RP000933

    FOR     ${i}     IN RANGE    1  101
        Step 1: Collect Snapshot    ${i}
        Step 2: Check Content Of Package    ${i}
        Step 3: Check Snapshot Filesize     ${i}
    END


Step 1: Collect Snapshot
    [Arguments]     ${i}
    Log    Step1.${i}: Collect Snapshot    console=${True}
    @{time}=    Get Time    year month day hour min
    ${snapshot_status}    Run Keyword And Return Status
    ...    coam.Collect Snapshot    ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If    ${snapshot_status}
    ...    Collecting Snapshot Succeeded  ${time}
    ...    ELSE
    ...    verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.  ${TRUE}
    Log    Checking if there are no unexpected alarms raised during Snapshot collection.  console=${True}
    pm_logs_general.Check Unexpected Active And Historical Alarms
    Check All Modules And All Cells Working States


Step 2: Check Content Of Package
    [Arguments]     ${i}
    Log    Step 2.${i}: Check content of package  console=${True}
    ${Found_file_dict}    snapshot.Get Data From Snapshot    ${path_to_snapshot}
    ${path_to_xml_spec_file}  join path  ${CURDIR}  tc_variables  snapshot_spec.xml
    snapshot.Validate Snapshot    ${Found_file_dict}    ${path_to_xml_spec_file}


Step 3: Check Snapshot Filesize
    [Arguments]     ${i}
    Log    Step 3.${i}: Check Snapshot Filesize  console=${True}
    ${size}=     Get File Size    ${path_to_snapshot}
    Log  Snapshot filesize= ${size} (should be more than 8700000)  console=${True}
    Run Keyword If    ${size}>8700000    Log  \n${size} bytes is between right full Snapshot size range  console=${True}
    #remove each snapshot due to limited disk memory
    Run  rm -f ${path_to_snapshot}


Collecting Snapshot Succeeded
    [Arguments]    ${time}
    Log    Collecting snapshot via admin succeeded  console=${True}
    Set Test Variable    ${path_to_snapshot}    ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown


