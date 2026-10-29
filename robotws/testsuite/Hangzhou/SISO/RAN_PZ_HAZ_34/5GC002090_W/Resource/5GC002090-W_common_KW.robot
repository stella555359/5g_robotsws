*** Settings ***
Documentation     author: shasha liu
...               Group: HGZ_SG5
...               contact: shasha.liu@nokia-sbell.com

Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002118/Resource/5GC002118_common_KW.robot

*** Variables ***
${Param_abbr}       srb3SupportEnabled
${Param_filter}     SRB3 Support Enabled

*** Keywords ***
"${Step}" Change Parameter via webUI
    log to console    \n"${Step}": Change Parameter via webUI
    ${Orig_val}    Get Parameter via webUI
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...    filter_param=${Param_filter}
    ...    p_name=${Param_abbr}
    set test variable    ${Orig_val}
    Run Keyword If    '${Orig_val}'=='false'
    ...    set test variable    ${toBeModify_val}    true
    ...    ELSE
    ...    set test variable    ${toBeModify_val}    false
    ${afterModify_val}    ${errors}    Change Parameter via webUI
    ...    expected_val=${toBeModify_val}
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...    filter_param=${Param_filter}
    ...    p_name=${Param_abbr}
