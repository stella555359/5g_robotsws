*** Settings ***

Documentation    Author: arunkumar.a@nokia.com 
...    Only contain basic linux machine operation. like kill the proceess. etc..

Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    csn
Resource    variables/Rjio_variables.robot

*** Keywords ***
clear vm pid before run case
    BuiltIn.Log To Console  clear vm pid before run case
    csn.Connect To   hostname=${vm_addr}  username=${vm_username}    password=${vm_password}     alias=test_pc
    Sleep    2s
    csn.Send Command  command=sudo ps -ef|grep firefox|grep -v grep|awk '{print "kill -9 " $2}' |sh    connection=test_pc
    Sleep    2s
    csn.Send Command  command=sudo ps -ef|grep firefox|grep -v grep|awk '{print "kill -9 " $3}' |sh   connection=test_pc
    Sleep    2s
    csn.Send Command  command=sudo ps -ef|grep btslog|grep -v grep|awk '{print "kill -9 " $2}' |sh  connection=test_pc
    Sleep    2s
    csn.Disconnect  connection=test_pc

Remove Folder File In VM
    [Documentation]    Author: arunkumar.a@nokia.com
    ...    KW helps to remove files and folders in vm..    
    [Arguments]    ${folder_name}=${None}    ${file_name}=${None}    ${delete_all_file}=${True}
    TRY
        ${files}    List Files In Directory    ${folder_name}        
        IF    '${folder_name}' != '${None}'
            OperatingSystem.Remove Directory    path=${folder_name}    recursive=True
            BuiltIn.Sleep  2s
            BuiltIn.Log To Console     [ INFO ]: ${folder_name} Folder is recursively deleted
        ELSE IF     '${file_name}' != '${None}'
            OperatingSystem.Remove File	path=${file_name}
            BuiltIn.Sleep  2s
            BuiltIn.Log To Console     [ INFO ]: ${file_name} File is deleted
            BuiltIn.Log To Console     [ INFO ]: Deleted : ${folder_name}/${files}
        ELSE
            BuiltIn.Log To Console    [ DEEBUG ]: NO FOLDER or FILE PROVIEDED. 
        END
    EXCEPT
        BuiltIn.Log To Console    [ ERROR ]: No files found in ${folder_name} folder.
    END

Create Folder In VM
    [Documentation]    Author: arunkumar.a@nokia.com
    ...    KW helps to create folder in vm..    
    [Arguments]    ${folder_name}=${None}
    TRY
        IF    '${folder_name}' != '${None}'
            OperatingSystem.Create Directory    path=${folder_name}
            BuiltIn.Sleep  2s
            BuiltIn.Log To Console     [ INFO ]: ${folder_name} Folder is created
        ELSE
            BuiltIn.Log To Console    [ DEEBUG ]: NO FOLDER NAME PROVIEDED. 
        END
    EXCEPT
        BuiltIn.Log To Console    [ ERROR ]: Unable to create folder ${folder_name}.
    END
