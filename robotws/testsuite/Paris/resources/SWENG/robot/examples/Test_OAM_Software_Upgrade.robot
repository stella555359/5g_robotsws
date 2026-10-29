*** Settings ***
Documentation    Suite description

Resource                ../Setup.robot
Resource                ../Oam.robot
Resource                ../Tools.robot


Suite Setup             Suite Setup from scratch    listBackupFiles=${FD_ALL}
...                                                 keepAllUeDataInCfgFile=${True}

Suite Teardown          Suite Teardown

Test Teardown           My Test Teardown


*** Variables ***
${BSR_file}             /home/ute/CrtRoot/BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip


*** Test Cases ***
CB008830_Will_Use_OAM_Software_Update
    [Tags]    DEBUG

    Dated Log New Line      APPLY BSR FILE...
    ${status}=              OAM Software Update     sw_package=${BSR_file}
    Dated Log New Line      ====> OAM Software Update Result is: ${status}


*** Keywords ***
My Test Teardown
    [Documentation]        Perform needed actions at the end of a test case
    Test Teardown
    Restore Files          listFileDesc=${FD_ALL}
    OAM Restore Files
