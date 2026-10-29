*** Settings ***
Documentation   QC Tags operation due to multi-cases map to one case name
...  author: He Jingmin
...  contact: jingmin.he@nokia-sbell.com

Resource   ./taf_coam.robot
Resource   ./taf_env.robot
Library    ../libraries/utils/csv_operation.py
Resource   ./gnb.robot
Library    String

*** Keywords ***
Check SMOD and Change QC Set
    [Arguments]   ${location}=${CURDIR}
    ${smod_type}   Get SMOD Product Name
    Run Keyword If   $smod_type=='ASOE'   Change ASOE Parallel QC Path   folder_path=${location}

Get Common Tags Info By SMOD and Release
    [Arguments]   ${file_path}
    ${smod_type}   Get SMOD Product Name
    ${release}   Get gnb release
    ${qc_def}   get_csv_dedicated_line   file_path=${file_path}   key_start=${smod_type}_${release}
    [Return]   ${qc_def}

Set Case Common Tags By Test Aggregate
    [Arguments]   ${qc_def}
    run keyword if  not ${qc_def}   Return From Keyword
    ${case_aggregate}   Get Regexp Matches    ${TEST_NAME}   5GC00\\d+(_\[AB\])?_0\\d+
    run keyword if  not '${qc_def['${case_aggregate[0]}']}'==''   Set Tags   QC_${qc_def['${case_aggregate[0]}']}
