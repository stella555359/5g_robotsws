*** Settings ***
Library           taf.transport.ssh    WITH NAME    csn

*** Keywords ***
Get File Size
    [Arguments]   ${file_path}   ${connection}
    ${file_info}   csn.Execute   command=ls -la ${file_path}   connection=${connection}
    [Return]   ${file_info.split()[4]}

Check if remote file size not increased
    [Arguments]   ${file_path}   ${connection}   ${timeout}=30s
    Wait Until Keyword Succeeds   ${timeout}   5s   csn.File Exists
    ...   remote_path=${file_path}   connection=${connection}   timeout=5
    ${prev_size}   Get File Size   file_path=${file_path}   connection=${connection}
    Sleep   1s
    ${final_size}   Get File Size   file_path=${file_path}   connection=${connection}
    Should Be Equal   ${prev_size}    ${final_size}
