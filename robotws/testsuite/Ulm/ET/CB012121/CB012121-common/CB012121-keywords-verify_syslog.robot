*** Settings ***
Documentation   This is a keyword file for CB012121-B verify syslogs
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

unpack syslog file
    [Documentation]    [PRIVATE]    unpack syslog file
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${path_syslog_file}
     Run    gunzip -k ${path_syslog_file}/btslog_gnb0/*.tgz
     ${rc}    ${tar_file}    Run And Return Rc And Output    ls ${path_syslog_file}/btslog_gnb0/*.tar
     Run      tar -xf ${tar_file} -C ${path_syslog_file}
     ${rc}    ${syslog_file}    Run And Return Rc And Output    ls ${path_syslog_file}/*.LOG
     set test variable   ${syslog_file}


search for 1 entry
    [Documentation]    [PRIVATE]    search for 1 entry in syslog
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${search}
    Log To Console   search for "${search}"
    ${item_found}  Grep File   ${syslog_file}   ${search}
    run keyword and continue on failure   should not be empty    ${item_found}
    ${line_item_found}   Get Regexp Matches    ${item_found}    ^[0-9]*
    ${int_item_found}    convert to integer   ${line_item_found}[0]
    Log To Console   --found in line ${int_item_found}
    RETURN   ${int_item_found}


search for 2 entries
    [Documentation]    [PRIVATE]    search for 2 entries in syslog
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${search}
    Log To Console   search for "${search}"
    ${item_found}  Grep File   ${syslog_file}       ${search}
    run keyword and continue on failure    should not be empty   ${item_found}
    ${lines}  split to lines   ${item_found}
    ${line_1}   Get Regexp Matches    ${lines}[0]    ^[0-9]*
    ${int_line_1}   convert to integer   ${line_1}[0]
    ${line_2}   Get Regexp Matches    ${lines}[1]    ^[0-9]*
    ${int_line_2}   convert to integer   ${line_2}[0]
    Log To Console   --found in line ${int_line_1} and ${int_line_2}
    RETURN   ${int_line_1}   ${int_line_2}


search for 1 entry TimeHoTgtSel
    [Documentation]    [PRIVATE]    search for 1 entry TimeHoTgtSel
    ...       :Autor: Sylvia Schneider
    Log To Console   \nget TimeHoTgtSel for counter M55142C00523 and M55142C00525
    ${search_TimeHoTgtSel}  Grep File   ${syslog_file}   TimeHoTgtSel=
    run keyword and continue on failure    should not be empty    ${search_TimeHoTgtSel}   no TimeHoTgtSel found in syslog
    ${lines}  split to lines   ${search_TimeHoTgtSel}
    ${tmp}    Get Regexp Matches    ${lines}[0]    TimeHoTgtSel=([0-9]*)ms     1
    set test variable      ${TimeHoTgtSel_NRCELL-1}    ${tmp}[0]
    Log To Console   TimeHoTgtSel=${TimeHoTgtSel_NRCELL-1} for NRCELL-1


search for 2 entries TimeHoTgtSel
    [Documentation]    [PRIVATE]    search for 2 entries in syslog
    ...       :Autor: Sylvia Schneider
    Log To Console   \nget TimeHoTgtSel for counter M55142C00523 and M55142C00525
    ${search_TimeHoTgtSel}  Grep File   ${syslog_file}   TimeHoTgtSel=
    run keyword and continue on failure    should not be empty    ${search_TimeHoTgtSel}   no TimeHoTgtSel found in syslog
    ${lines}  split to lines   ${search_TimeHoTgtSel}
    ${tmp1}    Get Regexp Matches    ${lines}[0]    TimeHoTgtSel=([0-9]*)ms     1
    set test variable      ${TimeHoTgtSel_NRCELL-2}    ${tmp1}[0]
    Log To Console   TimeHoTgtSel=${TimeHoTgtSel_NRCELL-2} for NRCELL-2
    ${tmp2}    Get Regexp Matches    ${lines}[1]    TimeHoTgtSel=([0-9]*)ms     1
    set test variable      ${TimeHoTgtSel_NRCELL-1}    ${tmp2}[0]
    Log To Console   TimeHoTgtSel=${TimeHoTgtSel_NRCELL-1} for NRCELL-1
