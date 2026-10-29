*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Common Test Setup
Test Teardown     Common Test Teardown


*** Variables ***
${PATH_TO_FILE_IN_BTS}      /ffs/run/config/FRIps.txt
${PATH_TO_FOLDER_IN_BTS}    /var/log


*** Test Cases ***
Get User Given File From BTS
    [Documentation]    Get file ${PATH_TO_FILE_IN_BTS} from BTS to test logs
    Run Keyword and Continue On Failure  COLLECTLOGS.Get File Or Folder From Bts To Test Logs  ${PATH_TO_FILE_IN_BTS}

Get User Given Folder From BTS
    [Documentation]    Get folder ${PATH_TO_FILE_IN_BTS} from BTS to test logs
    Run Keyword and Continue On Failure  COLLECTLOGS.Get File Or Folder From Bts To Test Logs  ${PATH_TO_FOLDER_IN_BTS}
