*** Settings ***
Library     ../resources/extractor.py
Library     ../resources/finder.py
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/verdicts.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_TIMEOUT}      1800                      #timeout for collect snapshot via Admin (in sec)

*** Keywords ***
TC__LOGS__Snapshot_filelist_check
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24314
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...
    ...  Step 1: Collect Snapshot
    ...  Step 2: Check content of package
    ...  in this steps is verified, that all files listed in snapshot_file_list.txt are present in collected Snapshot
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...
    ...  - 2022-16-12 - https://jiradc.ext.net.nokia.com/browse/TAT-24314 - Test rewritten based on BOAM ET test [TC_03]CB005986_Snapshot
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...  - 2023-04-24 - TAT-25131 - hran_snapshot analysis refactoring to taf.ul.verify_snapshot UL usage
    ...  - 29.05.2023 - TAT-25470 - Changed to new FOR loop syntax
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/TC__LOGS__Snapshot_filelist_check.png
    ...


    Set Tags    CA-LOGS    OWNER-iuliia.taupeka@nokia.com    AUTHOR-iuliia.taupeka@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS23R1
    ...    FEATURE-CB005986

    Step 1: Collect Snapshot
    Step 2: Check Content Of Package


Step 1: Collect Snapshot
    Log    Step1: Collect Snapshot    console=yes
    @{time}=    Get Time    year month day hour min
    ${snapshot_status}    Run Keyword And Return Status
    ...    coam.Collect Snapshot    ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If    ${snapshot_status}
    ...    Collecting Snapshot Succeeded  ${time}
    ...    ELSE
    ...    verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.  ${TRUE}


Step 2: Check Content Of Package
    [Documentation]
    ...  In this step is verified, that all files listed in snapshot_file_list.txt file are present in collected Snapshot.

    Log    Step 2: Check content of package    console=yes
    ${path_to_unzip}=  Set Variable  ${BTS Files}/extracted
    extractor    ${path_to_snapshot}  ${path_to_unzip}
    @{files_list}    Finder    ${path_to_unzip}/snapshot_file_list.txt
    FOR    ${index}    IN     @{files_list}
        OperatingSystem.File Should Exist    ${path_to_unzip}/${index}
        Log    File: ${index} [OK]    console=yes
    END

Collecting Snapshot Succeeded
    [Arguments]    ${time}
    Log    Collecting snapshot via admin succeeded    console=yes
    Set Test Variable    ${path_to_snapshot}    ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    OperatingSystem.Run  rm -rf ${BTS Files}/extracted
    ...    AND    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
