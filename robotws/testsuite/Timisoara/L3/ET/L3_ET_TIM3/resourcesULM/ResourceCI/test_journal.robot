*** Settings ***

Library     OperatingSystem

Resource    ../journal.robot
Resource    ../testline.robot

Test Timeout   3min

*** Test Cases ***
Test Start Journal on AP 
    [TAGS]   JOURNAL
    journal.Start Journal on AP
    Sleep   10s

Test Stop Journal on AP 
    [TAGS]   JOURNAL
    journal.Stop Journal on AP
    ${tc_dir}    testline.Get testcase log directory
    Check Journal Files In Default Directory   ${tc_dir}

Test Start Journal on all gNBs
    [TAGS]   JOURNAL
    journal.Start Journal on all gNBs
    Sleep   10s

Test Stop Journal on all gNBs
    [TAGS]   JOURNAL
    journal.Stop Journal on all gNBs
    ${tc_dir}    testline.Get testcase log directory
    Check Journal Files In Default Directory   ${tc_dir}


*** Keywords ***
Check Journal Files In Default Directory
    [Arguments]   ${base_dir}
    @{dirs}    OperatingSystem.List Directories In Directory   ${base_dir}   *-journal   absolute
    FOR   ${dir}   IN   @{dirs}
       @{files}   OperatingSystem.List Files In Directory 	${dir} 	journal.log   absolute
       Check Journal Files Are Not Empty   ${files}
    END

Check Journal Files Are Not Empty
    [Arguments]   ${files}
    FOR   ${file}   IN   @{files}
       OperatingSystem.File Should Not Be Empty   ${file}
    END
