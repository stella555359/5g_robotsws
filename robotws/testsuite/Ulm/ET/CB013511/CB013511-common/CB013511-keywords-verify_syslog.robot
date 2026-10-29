*** Settings ***
Documentation   This is a keyword file for CB013511 verify syslogs
...             Team: 'MI MN RAN RD VRF ULM 4'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Library           OperatingSystem
Library           String

*** Keywords ***

Unpack Syslog File
    [Documentation]    [PRIVATE]    Unpack Syslog File
    ...       :Author: Sylvia Schneider
    [Arguments]     ${path_syslog_file}
    OperatingSystem.Run    gunzip -k ${path_syslog_file}/btslog_gnb0/*.tgz
    ${rc}    ${tar_file}    OperatingSystem.Run And Return Rc And Output    ls ${path_syslog_file}/btslog_gnb0/*.tar
    IF    ${rc} != 0
        Fail    command "ls ${path_syslog_file}/btslog_gnb0/*.tar" ends with error code "${rc}"
    END
    OperatingSystem.Run      tar -xf ${tar_file} -C ${path_syslog_file}
    ${rc}    ${syslog_file}    OperatingSystem.Run And Return Rc And Output    ls ${path_syslog_file}/*.LOG
    IF    ${rc} != 0
        Fail    command "ls ${path_syslog_file}/*.LOG" ends with error code "${rc}"
    END
    Set Test Variable   ${syslog_file}


Search For 1 Entry
    [Documentation]    [PRIVATE]    Search For 1 Entry
    ...       :Author: Sylvia Schneider
    [Arguments]   ${search}
    Log To Console   search for "${search}"
    ${item_found}  OperatingSystem.Grep File   ${syslog_file}   ${search}
    Run Keyword And Continue On Failure   Should Not Be Empty    ${item_found}
    ${line_item_found}   String.Get Regexp Matches    ${item_found}    ^[0-9]+
    ${int_item_found}    Convert To Integer   ${line_item_found}[0]
    Log To Console   --found in line ${int_item_found}
    RETURN   ${int_item_found}


Verify Syslogs A_SE_TC02_B2_ALT1
    [Documentation]    [PRIVATE]    Verify Syslogs A_SE_TC02_B2_ALT1
    ...       :Author: Sylvia Schneider
    Unpack Syslog File   ${resultDir}

    ${check1}  Set Variable   Ca Capability criteria matching with UE supported frequency band for ClassID: 1
    ${check2}  Set Variable   Selected measurement profile mapping ID (nrMeasPrMaNsaId) 1 for band 41, cell: 16385
    ${check3}  Set Variable   Ca Capability criteria matching with UE supported frequency band for ClassID: 3
    ${check4}  Set Variable   Selected measurement profile mapping ID (nrMeasPrMaNsaId) 3 for band 41, cell: 16390

    ${classid1}    Search For 1 Entry   ${check1}
    ${cell1}       Search For 1 Entry   ${check2}
    ${classid3}    Search For 1 Entry   ${check3}
    ${cell3}       Search For 1 Entry   ${check4}

    Log To Console   \nVerify ${check1} (line ${classid1})
    Log To Console   - before
    Log To Console   - ${check2} (line ${cell1})
    Run Keyword And Continue On Failure    Should Be True   ${classid1} < ${cell1}

    Log To Console   \nVerify ${check2} (line ${cell1})
    Log To Console   - before
    Log To Console   - ${check3} (line ${classid3})
    Run Keyword And Continue On Failure    Should Be True   ${cell1} < ${classid3}

    Log To Console   \nVerify ${check3} (line ${classid3})
    Log To Console   - before
    Log To Console   - ${check4} (line ${cell3})
    Run Keyword And Continue On Failure    Should Be True   ${classid3} < ${cell3}

