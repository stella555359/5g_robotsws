*** Settings ***
Documentation     Keywords related to BTSlog analysis
...               author: Sandra Schöffel
...

Library    OperatingSystem
Library    String
Library    taf.sbts.oam.coam.admin    WITH NAME    admin


*** Keywords ***
filter logs for all gNBs
    [Arguments]    ${btslogpath}  ${node_type}=gnb
    ${node_count}  Get Length  ${tl.${node_type}s}
    Log To Console  check bts log for err/fatal/critical/..
    FOR    ${node}    IN RANGE    ${node_count}
       filter bts log for reason  btslogpath=${btslogpath}/btslog_gnb${node}
    END


filter bts log
    [Documentation]
    ...         Filter BTS log files for certain keywords
    ...
    ...        :param  btslogpath    path where btslogs are stored
    ...        :param  filter        filterstring to look for
    ...        :param  result_file   output file, default filename: btslog_filtered.txt
    ...
    ...        :note:  result file is always stored in btslogpath directory
    [Arguments]    ${btslogpath}  ${filter}  ${result_file}=btslog_filtered.txt
    ${filtered_file}  join path  ${btslogpath}  ${result_file}
    ${result}  run  zgrep -hai "${filter}" ${btslogpath}/* | grep -v "Message send failed (recipient has not been registered)"
    ${result_length}  Get length  ${result}
    IF  ${result_length} > 0
        ${result}  Catenate  SEPARATOR=\n  ***${filter}***  ${result}\n
        OperatingSystem.Append To File  ${filtered_file}  ${result}
    END
    RETURN   ${filtered_file}


filter bts log for reason
    [Arguments]    ${btslogpath}
    filter bts log      btslogpath=${btslogpath}  filter=contact the owner of
    filter bts log      btslogpath=${btslogpath}  filter=fatal
    filter bts log      btslogpath=${btslogpath}  filter=critical
    filter bts log      btslogpath=${btslogpath}  filter=err/
    filter bts log      btslogpath=${btslogpath}  filter=crashdumps
    filter bts log      btslogpath=${btslogpath}  filter=collecting logs for: crash.tgz
    filter bts log      btslogpath=${btslogpath}  filter=/crash.tgz", destFilePath
    filter bts log      btslogpath=${btslogpath}  filter=AdetTimeoutWithoutUnitInfo


print filtered btslog in log file
    [Arguments]    ${node_type}=gnb  ${output}=owner
    ${node_count}  Get Length  ${tl.${node_type}s}
    ${suiteBaseDirectory}=  testline . Get test suite result base directory
    FOR    ${node}    IN RANGE    ${node_count}
        ${file_exists}  Run Keyword and Return Status  File should exist  ${suiteBaseDirectory}/btslog_gnb${node}/btslog_filtered.txt
        IF  ${file_exists}
          ${btslog_filtered}=  OperatingSystem.Get file  ${suiteBaseDirectory}/btslog_gnb${node}/btslog_filtered.txt
          Run Keyword And Warn On Failure  Should Not Contain  ${btslog_filtered}  ${output}
        END
    END
