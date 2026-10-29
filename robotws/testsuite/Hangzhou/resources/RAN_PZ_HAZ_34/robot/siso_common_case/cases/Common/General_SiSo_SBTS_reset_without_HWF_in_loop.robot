*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/csn.robot


*** Variables ***

*** Keywords ***
General_SiSo_SBTS_reset_without_HWF_in_loop
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Target of this test is to check SBTS can start up successfully without HWF file on file system
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 05.06.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Change swconfig with corresponding flag    operate=add
    FOR    ${i}    IN RANGE    1    4
        Log to console    \nrun: ${i}/3
        Perform BTS Site Reset On WebUI
        sleep  60
        Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    cell_type=${cell_type}
    END
    Change swconfig with corresponding flag    operate=del
