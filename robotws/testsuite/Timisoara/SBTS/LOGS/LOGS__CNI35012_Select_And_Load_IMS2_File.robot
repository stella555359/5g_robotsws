*** Settings ***
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/BTS_log_level.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    taf/rfrl/common_resources/common_step/interface.robot


*** Keywords ***
TC__LOGS__CNI35012_Select_And_Load_IMS2_File

    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24208
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Purpose of this test case is select and load IMS2 file
    ...  ******************
    ...  History of changes
    ...  ******************

    ...  - 02.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24208 - Test rewritten based on BOAM ET test -
    ...  [1][1.0] Select_And_Load_IMS2_File
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame

    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/LOGS__CNI35012_Select_And_Load_IMS2_File.png
    ...

    Set Tags      CA-LOGS  OWNER-iuliia.taupeka@nokia.com  AUTHOR-robert.ambrosewicz@nokia.com  MAINTAINER-jakub.kokoszka@nokia.com
    ...           GROUP_IN_CHARGE-WRO_6_Vrf  PHASE-CRT  SW-SBTS23R1  FEATURE-CNI35012

    Step 0: Preconditions
    Step 1: Select and load IMS2 file



Step 0: Preconditions
    [Documentation]
    ...  In this step test prepare path variable and create taf.sbts.oam.coam.admin connection

    Log  \nStep 0: Preconditions  console=${True}
    Set Test Variable  ${path}  ${BTS Files}/download_files/
    ${bts_connection}=  coam.connect_to
    Set Test Variable  ${BTS_CONNECTION}  ${bts_connection}



Step 1: Select and load IMS2 file
    [Documentation]
    ...  In this step test download ims and snapshot

    Log  \nStep 1: Select and load IMS2 file  console=${True}
    Log  IMS2 and snapshot save  console=${True}
    IMS2 and snapshot save
    Log  Click Site Runtime View  console=${True}
    Click Site Runtime View
    Log  Load IMS File console=${True}
    Load IMS File
    Log  Check Loaded IMS2 console=${True}
    Check Loaded IMS2


IMS2 and snapshot save
    [Documentation]
    ...  This KW collect ims and snapshot amd save in test files directory
    @{time}=    Get Time    year month day hour min
    coam.get_snapshot           ${path}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip
    ...                          timeout=900s  connection=${BTS_CONNECTION}
    coam.collect_im_snapshot    ${path}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.ims2
    ...                          timeout=900s  connection=${BTS_CONNECTION}


Click Site Runtime View
    [Documentation]
    ...  This KW Click Site Runtime View
    BTS_log_level.WebEM Login
    Sleep  60s
    Wait Until Keyword Succeeds    50x    1s    Element Should Be Visible
    ...               xpath=//*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[3]/a[1]
    Click Element    xpath=//*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[3]/a[1]

Load Ims File
    [Documentation]
    ...  This KW Load Ims File
    ${file}=    Run    ls ${path} | grep .zip
    Wait Until Page Contains Element
    ...  xpath=//*[@id="otx-upload-snapshot"]/div/div/p-fileupload/div/div[1]/span/input
    ...  timeout=30s
    Choose File        xpath=//*[@id="otx-upload-snapshot"]/div/div/p-fileupload/div/div[1]/span/input   ${path}${file}
    Wait Until Keyword Succeeds    20x    1s    Element Should Be Visible
    ...               xpath=//div[@class="modal-footer"]//button[@class="btn btn-defaultBlue btn-small"]
    Click Element     //div[@class="modal-footer"]//button[@class="btn btn-defaultBlue btn-small"]

Check Loaded IMS2
    [Documentation]
    ...  This KW Check Loaded IMS2
    Wait Until Keyword Succeeds    20x    1s    Element Should Be Visible
    ...               xpath=//*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[2]/div[2]/span[2]

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
