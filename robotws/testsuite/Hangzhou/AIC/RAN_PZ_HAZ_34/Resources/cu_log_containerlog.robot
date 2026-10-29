*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_log_containerlog.robot



*** Variables ***



*** Keywords ***
Get Current Host Time By Linux Cmd VCUC
    [Arguments]  ${pod_full_name}  ${container_full_name}  ${alias}=default
    [Documentation]    Get Current Host Time By Linux Cmd
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    No input parameter.
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Current Host Time By Linux Cmd |
    ${ns}  get cu namespace from testline
#    ${out}  issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- date +%s
#            ...  check_result=False   alias=${alias}

    ${out}  issh.Execute  command=date +%s   check_result=${False}   alias=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{5,20}
    [Return]   ${lines}


Get Modified Time By Linux Cmd VCUC
    [Arguments]    ${filename}   ${pod_full_name}   ${container_full_name}  ${alias}=default
    [Documentation]     Get Modified Time By Linux Cmd inside VCU Container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    | container_id  | yes | container_id |
    ...    | alias    | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Modified Time By Linux Cmd VCUC | filename=/root/a.txt | container_id=${conainer_id} |
#    ${ns}  get cu namespace from testline
#    ${out}  issh.Execute
#            ...  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- stat --format=%Y ${filename}
#            ...  check_result=False   alias=${alias}

    ${out}  issh.Execute   command=stat --format=%Y ${filename}   check_result=${False}   alias=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{8,20}
    [Return]   ${lines}


Check File Existed In VCUC
    [Arguments]  ${filename}  ${pod_full_name}  ${container_full_name}   ${alias}=default
    [Documentation]   Check File Exist or not inside VCU container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename      | yes | file name |
    ...    | container_id | yes | container_id |
    ...    | alias        | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    return 1 if file exists, otherwise return 0
    ...
    ...    Example
    ...    | ${bExit} | Check File Existed In VDUC |  filename=/root/a.txt | container_id=123adadf23 | alias=default |
    ...
    ${ns}   get cu namespace from testline
#    ${out}  issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls ${filename}
#            ...  check_result=False   alias=${alias}
    ${out}  issh.Execute  command=ls ${filename}   check_result=${False}   alias=${alias}

    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    Return From Keyword If  ${bExist}==0   0
    ${bExist}   Set Variable If     """syntax error near unexpected token""" in """${out}"""     0     1
    [Return]   ${bExist}


_Remove All Temp File If Needed In VCUC Master Node
    [Arguments]  ${FolderName}    ${alias}=default
    ${out}   issh.Execute  command=ls -F -1 ${FolderName}   alias=${alias}
    ${out}   strip prompt  ${out}
    ${curr_time}    Get Current Host Time By Linux Cmd Interactively  alias=${alias}
    ${lines}   split to lines   ${out}

    #delete Files 2 Hours Ago
    ${threshold}   Set Variable   7200

    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        #${bExist}   Check File Existed    ${fullname}   alias=${alias}
        ${bExist}     Check File Existed In Linux Server Via Interactive SSH   ${fullname}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed VCUC Master Node    foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}   alias=${alias}
    END


_Remove All Temp File If Needed From VCUC
    [Arguments]  ${FolderName}   ${pod_full_name}   ${container_full_name}  ${ns}  ${alias}
    #${out}  issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls -F -1 ${FolderName}
     #       ...  check_result=False   alias=${alias}

    ${out}  issh.Execute  command=ls ${FolderName}   check_result=${False}   alias=${alias}
    ${out}  strip prompt   ${out}
    ${curr_time}    Get Current Host Time By Linux Cmd VCUC   pod_full_name=${pod_full_name}   container_full_name=${container_full_name}
      ...   alias=${alias}
#    ${lines}   split to lines   ${out}
    ${lines}   Split String   ${out}
    #${lines}   Split String  ${out}

    #delete Files 60 min ago(3600)
    ${threshold}   Set Variable   3600

    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed In VCUC   ${fullname}
            ...  pod_full_name=${pod_full_name}   container_full_name=${container_full_name}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed VCUC   foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}
        ...   pod_full_name=${pod_full_name}   container_full_name=${container_full_name}    alias=${alias}
    END

#
#_Remove All Temp File If Needed From VCUC
#    [Arguments]  ${FolderName}   ${pod_full_name}   ${container_full_name}  ${ns}  ${alias}
#    #${out}  issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls -F -1 ${FolderName}
#     #       ...  check_result=False   alias=${alias}
#
#    ${out}  issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls ${FolderName}
#            ...  check_result=False   alias=${alias}
#    ${out}  strip prompt   ${out}
#    ${curr_time}    Get Current Host Time By Linux Cmd VCUC   pod_full_name=${pod_full_name}   container_full_name=${container_full_name}
#      ...   alias=${alias}
##    ${lines}   split to lines   ${out}
#    ${lines}   Split String   ${out}
#    #${lines}   Split String  ${out}
#
#    #delete Files 60 min ago(3600)
#    ${threshold}   Set Variable   3600
#
#    :FOR   ${file}    IN    @{lines}
#    \    Continue For Loop If   '${file}'==''
#    \    ${fullname}   Join Path   ${FolderName}   ${file}
#    \    ${bExist}   Check File Existed In VCUC   ${fullname}
#            ...  pod_full_name=${pod_full_name}   container_full_name=${container_full_name}   alias=${alias}
#    \    Continue For Loop If   ${bExist}==0
#    \    _Remove One Temp File If Needed VCUC   foldername=${FolderName}   filename=${file}
#        ...   curr_time=${curr_time}     thrashold=${threshold}
#        ...   pod_full_name=${pod_full_name}   container_full_name=${container_full_name}    alias=${alias}
#
#
_Remove One Temp File If Needed VCUC Master Node
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}   ${alias}=default
    # ${foldername}:  /tmp/tmp_wireshark
    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}    Get Modified Time By Linux Cmd Interactively  filename=${fullname}   alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    #${sudo}   Get Sudo   alias=${alias}
    Run Keyword If   ${bDeleteIt}==1   issh.Execute   command=rm -rf ${fullname}    alias=${alias}


_Remove One Temp File If Needed VCUC
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}  ${pod_full_name}   ${container_full_name}  ${alias}
    # ${foldername}:  /tmp/tmp_wireshark
    ${ns}  get cu namespace from testline

    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}    Get Modified Time By Linux Cmd VCUC   filename=${fullname}  pod_full_name=${pod_full_name}
     ...   container_full_name=${container_full_name}  alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    ${out}  Run Keyword If   ${bDeleteIt}==1
      ...   issh.Execute  command=rm -rf ${fullname}
      ...  check_result=${False}   alias=${alias}


Get Current Host Time By Linux Cmd VDUC Interactively
    [Arguments]  ${pod_full_name}  ${container_full_name}  ${alias}=default
    [Documentation]    Get Current Host Time By Linux Cmd
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    No input parameter.
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Current Host Time By Linux Cmd |
    ${out}  issh.Execute  command=date +%s   check_result=${False}   alias=${alias}

    ${lines}  Get Lines Matching Regexp   ${out}   \\d{5,20}
    [Return]   ${lines}