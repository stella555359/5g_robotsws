*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   common_log.robot



*** Variables ***



*** Keywords ***
_Get Temp File Name
    [Arguments]  ${host_type}=${EMPTY}   ${fhgw_or_vdu_index}=0   ${pod_abbr}=${EMPTY}  ${container_id}=${EMPTY}
    #way I:
    #${var_exist}=    Run Keyword And Ignore Error    Variable Should Exist    ${LOCAL_IP}
    #${ip}=    Run Keyword If    "${var_exist[0]}"=="FAIL"    Get Local IP
    #...    ELSE    Set Variable    ${LOCAL_IP}
    #${ts}    Get Time    epoch
    #${rand}   Evaluate   random.randint(1,99999)    modules=random
    #${filename}   Set Variable    ${LOCAL_IP}_${ts}_${rand}

    #way II:
    #${filename}    Evaluate    str(uuid.uuid4())    modules=uuid
    #${filename}    String.Replace String    ${filename}    -    ${EMPTY}

    #way III:
    ${unique_id}  Get Unique ID
    ${host_type}   Set Variable If   "${host_type}"=="${EMPTY}"   z   ${host_type}
    ${pod_abbr}   Set Variable If   "${pod_abbr}"=="${EMPTY}"   z   ${pod_abbr}
    ${container_id}   Set Variable If   "${container_id}"=="${EMPTY}"   z   ${container_id}
    ${file_name}   Set Variable   ${host_type}_${fhgw_or_vdu_index}_${pod_abbr}_${container_id}_${unique_id}
    [Return]  ${file_name}


_Get Temp File Name HIGH_WITH_FORMAT_DATETIME_EPOCH
    [Arguments]  ${host_type}=${EMPTY}   ${fhgw_or_vdu_index}=0   ${pod_abbr}=${EMPTY}  ${container_id}=${EMPTY}  ${gnb_index}=0
    #way I:
    #${var_exist}=    Run Keyword And Ignore Error    Variable Should Exist    ${LOCAL_IP}
    #${ip}=    Run Keyword If    "${var_exist[0]}"=="FAIL"    Get Local IP
    #...    ELSE    Set Variable    ${LOCAL_IP}
    #${ts}    Get Time    epoch
    #${rand}   Evaluate   random.randint(1,99999)    modules=random
    #${filename}   Set Variable    ${LOCAL_IP}_${ts}_${rand}

    #way II:
    #${filename}    Evaluate    str(uuid.uuid4())    modules=uuid
    #${filename}    String.Replace String    ${filename}    -    ${EMPTY}

    #way III:
    ${unique_id}  Get Unique ID   precise=HIGH_WITH_FORMAT_DATETIME_EPOCH
    ${host_type}   Set Variable If   "${host_type}"=="${EMPTY}"   z   ${host_type}
    ${pod_abbr}   Set Variable If   "${pod_abbr}"=="${EMPTY}"   z   ${pod_abbr}
    ${container_id}   Set Variable If   "${container_id}"=="${EMPTY}"   z   ${container_id}
    ${file_name}   Set Variable   ${host_type}_${fhgw_or_vdu_index}_${pod_abbr}_${container_id}_${unique_id}_gnb_${gnb_index}
    [Return]  ${file_name}


Get Timestamp
    [Arguments]  ${format}=epoch
    ${ts}    Get Time     ${format}
    [Return]  ${ts}


_Get FHGW Ip
    [Arguments]  ${alias}
    ${out}    issh.Execute    command=ip add show dev eth0    alias=${alias}
    ${matches}  Get Regexp Matches     ${out}     inet (.+)/\\d{1,2} scope global.+   1
    ${ip}     Set Variable If    ${matches}    ${matches[0]}    ${EMPTY}
    [Return]   ${ip}


Get Current Host Time By Linux Cmd Interactively
    [Arguments]  ${alias}=default
    [Documentation]    Get Current Host Time By Linux Cmd
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | alias, default value is default |
    ...    No input parameter.
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Current Host Time By Linux Cmd Interactively |
    ${out}    issh.Execute    command=date +%s    alias=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{5,20}
    [Return]   ${lines}


Get Modified Time By Linux Cmd Interactively
    [Arguments]    ${filename}   ${alias}=default
    [Documentation]     Get Modified Time By Linux Cmd Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    | alias    | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Modified Time By Linux Cmd Interactively | filename=/root/a.txt |
    ${out}    issh.Execute  command=stat --format=%Y ${filename}   alias=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{8,20}
    [Return]   ${lines}


Check File Existed In Linux Server Via Interactive SSH
    [Arguments]  ${filename}    ${alias}=default
    [Documentation]     Check File Existed In Linux Server Via Interactive SSH
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    | alias    | no | alias name |
    ...    No input parameter.
    ...
    ...    *RETURN VALUE*
    ...    return 1 if file exists, otherwise return 0
    ...
    ...    Example
    ...    | ${bExit} | Check File Existed In Linux Server Via Interactive SSH |  filename=/root/a.txt | alias=default |
    ...
    ${out}    issh.Execute  command=ls ${filename}   alias=${alias}   check_result=${False}
    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    Return From Keyword If  ${bExist}==0   0
    ${bExist}   Set Variable If     """syntax error near unexpected token""" in """${out}"""     0     1
    [Return]   ${bExist}


_Remove All Temp File If Needed From General Linux Server
    [Arguments]  ${FolderName}    ${alias}
    ${res}   issh.Execute  command=ls -l ${FolderName}   alias=${alias}
    Log To Console  ${res}

    ${out}     issh.Execute    command=ls -F -1 ${FolderName}   alias=${alias}
    ${curr_time}    Get Current Host Time By Linux Cmd Interactively  alias=${alias}
    ${lines}   Strip Prompt    content=${out}    return_list=True

    #delete Files 960 seconds Ago
    ${threshold}   Set Variable   960

    FOR   ${file}    IN    @{lines}
        #${file}  evaluate  ''.join(i for i in """${file}""" if ord(i)<128)
        ${matches}  Get Regexp Matches   ${file}   .*(ws_[a-zA-Z0-9_]+\.pcap).*   1
        ${file}  Set Variable If  ${matches}   ${matches[0]}   ${EMPTY}
        Log To Console  ${file}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed In Linux Server Via Interactive SSH   filename=${fullname}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed Interactively   foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}   alias=${alias}
    END


_Remove One Temp File If Needed Interactively
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}   ${alias}
    # ${foldername}:  /tmp/tmp_wireshark
    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}    Get Modified Time By Linux Cmd Interactively   filename=${fullname}   alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    ${sudo}  Run Keyword If   ${bDeleteIt}==1   Get Sudo Via Interactive SSH   alias=${alias}
    Run Keyword If   ${bDeleteIt}==1   issh.Execute  command=${sudo} rm -rf ${fullname}   check_result=${False}  alias=${alias}


_Get EPOCH Time From String
    [Arguments]  ${full_path_file_name}
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${full_path_file_name}
    ${tmp}   Split String  ${pcap_file}  _
    ${vdu_index}  Set Variable  ${tmp[2]}
    ${pod_abbr}  Set Variable  ${tmp[3]}
    ${container}   Set Variable  ${tmp[4]}

    ${file_date}   Set Variable  ${tmp[6]}   #20010909
    ${file_time}   Set Variable  ${tmp[7]}   #044640

    #2001-09-09 04:46:40
    ${file_date_new}  set variable   ${file_date[0:4]}-${file_date[4:6]}-${file_date[6:8]}
    ${file_time_new}  set variable   ${file_time[0:2]}:${file_time[2:4]}:${file_time[4:6]}
    ${date_time_string}   set variable   ${file_date_new} ${file_time_new}
    #${date}  	Convert Date 	2014-06-12 13:27:59.279 	epoch
    ${date}  	Convert Date 	${date_time_string}  	epoch
    ${date}    Evaluate   str(int(${date}))
    [Return]  ${date}


Get Sudo Via Interactive SSH
    [Arguments]  ${alias}=default
    [Documentation]   if sudo is supported, return sudo, otherwise return ${EMPTY}
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via tafssh library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | alias name, default value is 'default' |
    ...
    ...    *RETURN VALUE*
    ...    sudo or ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get Sudo Via Interactive SSH |
    ...
    ${out}  issh.Execute    command=which sudo ; echo $?     alias=${alias}

    #${out}   tafssh.Read Output    connection=${alias}
    ${out}   Strip Prompt  ${out}
    ${lines}   Split To Lines   ${out}
    ${exit_code}   Set Variable  ${lines[-1]}
    ${exit_code}   Set Variable  ${exit_code.strip()}
    ${rtn}   Set Variable If  "${exit_code}"=="0"   sudo   ${EMPTY}
    [Return]  ${rtn}


Send CTRL_C Interactively
    [Arguments]  ${alias}=default
    [Documentation]    it sends CTRL+C key to interrupt current running command
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via issh library.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | how or what |
    ...    *Argument Description*
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes | alias name |
    ...    *RETURN VALUE*
    ...    None
    ...    *Example*
    ...    | Send CTRL_C Interactively | alias=default |
    ${crtl_c}    Evaluate    chr(int(3))
    ${out}   issh.Execute_Bare   command=${crtl_c}     alias=${alias}
    Sleep    2.3s
    [Return]  ${out}


Send ENTER Interactively
    [Arguments]  ${alias}=default
    [Documentation]    it sends ENTER key
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via issh library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes | alias name |
    ...
    ...    *RETURN VALUE*
    ...    No return value.
    ...
    ...    Example
    ...    | Send ENTER Interactively | alias=default |
    ${enter}    Evaluate    chr(int(13))
    ${out}   issh.Execute_Bare   command=${enter}     alias=${alias}
    Sleep    1.3s
    [Return]  ${out}


Send ENTER Interactively VCU CNF
    [Arguments]  ${alias}=default
    [Documentation]    it sends ENTER key
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via issh library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes | alias name |
    ...
    ...    *RETURN VALUE*
    ...    No return value.
    ...
    ...    Example
    ...    | Send ENTER Interactively VCU CNF | alias=default |
    ${enter}    Evaluate    chr(int(13))
    ${out}   issh.Execute_Bare   command=${enter}     alias=${alias}
    Sleep    2s
    [Return]  ${out}


_Wireshark Get Host Type
    [Arguments]  ${alias}=default
    [Documentation]   _Wireshark Get Host Type from host.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | alias name, default value is 'default' |
    ...    *RETURN VALUE*
    ...    host type, e.g, LTE, OTHER
    ...    Example
    ...    | _Wireshark Get Host Type |
    ...
    ${host_type}  Set Variable  OTHER
    #${res}   issh.Execute     command=hostname   alias=${alias}
    #${res}   strip prompt  ${res}
    #${res}   Set Variable    ${res.upper()}
    #${host_type}    Run Keyword If    "FCTJ" in """${res}"""    Set Variable    LTE
    #...    ELSE IF    "FCT-" in """${res}"""    set variable    LTE
    #...    ELSE    set variable    OTHER
    [Return]    ${host_type}


_Wireshark Get Host Type Interactively
    [Arguments]  ${alias}=default     ${gnb_index}=0
    [Documentation]   _Wireshark Get Host Type from host. Please use it after keyword connect to ssh host using taf.hw.fhgw.cli.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | alias name, default value is 'default' |
    ...    *RETURN VALUE*
    ...    host type, e.g, OAM, CPIF, CPUE, etc.
    ...    Example
    ...    | _Wireshark Get Host Type |
    ${res}     issh.Execute     command=hostname   alias=${alias}
    ${res}    Set Variable    ${res.upper()}
    ${host_type}    Run Keyword If    "OAM" in """${res}"""    Set Variable    VCUOAM
    ...    ELSE    set variable    VCUOTHER

    Return From Keyword If   "${host_type}"!="VCUOAM"    ${host_type}
    ${bIsMasterOAM}    current VM Is Master OAM   alias=${alias}  gnb_index=${gnb_index}
    ${host_type}   Set Variable If  ${bIsMasterOAM}==1   VCUOAMMASTER   VCUOAMSLAVE
    [Return]    ${host_type}


Current VM Is Master OAM
    [Arguments]   ${alias}=default     ${gnb_index}=0
    ${res}     issh.Execute     command=hostname   alias=${alias}
    ${current_host_name}   Strip Prompt  ${res}
    ${current_host_name}    Set Variable    ${current_host_name.upper()}

    ${alias_oam_master}  Get Unique Id
    CU SSH To OAM  alias=${alias_oam_master}  gnb_index=${gnb_index}
    ${res}     issh.Execute     command=hostname   alias=${alias_oam_master}
    ${master_host_name}   Strip Prompt  ${res}
    ${master_host_name}    Set Variable    ${master_host_name.upper()}

    Disconnect Interactive Connection  alias=${alias_oam_master}
    ${bRtn}   Set Variable If  "${current_host_name}"=="${master_host_name}"   1   0
    [Return]  ${bRtn}


Extract Zip File List
    [Arguments]  ${zip_file_list}  ${remove_zip_file}  ${alias}=default   ${check_file_exist}=${True}
    FOR   ${file}  IN  @{zip_file_list}
        Extract Zip File  file=${file}  alias=${alias}   check_file_exist=${check_file_exist}
        ...   remove_zip_file=${remove_zip_file}
    END


Extract Zip File
    [Arguments]  ${file}  ${remove_zip_file}   ${alias}=default   ${check_file_exist}=${True}
    [Documentation]    Extract Zip File
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   modified by:        <24-6-2023>, <chris.l.cao>, Initializatoin
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | file            | Yes | zip file name  |
    ...    | remove_zip_file | Yes | True or False, True-It will remove original zip file, False-It will keep original zip file |
    ...    | alias           | No | default is 600 seconds  |
    ...    | check_file_exist | No | True-It will assert zip file exists, False-It will not assert zip file exists, default is ${True} |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | ${local_snapshot_file} |   Extract Zip File | file=/tmp/a.zip | remove_zip_file=False | alias=myalise |
    ...
    ${extract_path}  Set Variable   ${None}
    Run Keyword If  ${check_file_exist}  File Should Exist  ${file}
    ${size}   Get_File_Size   ${file}
    Return From Keyword If  ${size}==0  ${extract_path}
    ${extract_path}  ${dummy_ext}   Split Extension     ${file}
    Run Keyword And Ignore Error   issh.Execute   command=rm -rf ${extract_path}   alias=${alias}
    Return From Keyword If  "${dummy_ext}"!='zip'   ${extract_path}
    ${out}   issh.Execute   command=unzip -n ${file} -d ${extract_path} >/dev/null  check_result=${False}   alias=${alias}
    ${out}  Run Keyword If  "${remove_zip_file}"=="${True}"   issh.Execute   command=rm -f ${file}   alias=${alias}
    [Return]   ${extract_path}


Extract Zip File To The Same Folder
    [Arguments]  ${file}   ${alias}=default
    [Documentation]    Extract Zip File To The Same Folder, the original zip file will not be deleted.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   modified by:        <24-6-2023>, <chris.l.cao>, Initializatoin
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | file            | Yes | zip file name  |
    ...    | alias           | No | default is 600 seconds  |
    ...
    ...    *RETURN VALUE*
    ...   the folder name with full path, where extracted files are placed.
    ...
    ...    Example
    ...    | ${full_extracted_folder} | Extract Zip File To The Same Folder | file=/tmp/a.zip | alias=myalise |
    ...
    File Should Exist  ${file}
    ${size}   Get_File_Size   ${file}
    Return From Keyword If  ${size}==0

    ${r}  ${ext}   Split Extension     ${file}
    Return From Keyword If  "${ext}"!='zip'

    ${current_folder}  ${basename}   Split Path     ${file}
    ${matches}   Get Regexp Matches   ${basename}    Snapshot_\\d{8,8}-\\d{6,6}.zip
    ${current_folder_actual}   Set Variable If  ${matches}   ${current_folder}/snapshot2   ${current_folder}

    ${out}   issh.Execute   command=unzip -o ${file} -d ${current_folder_actual}      alias=${alias}

    ${full_extracted_folder}   Run Keyword If   ${matches}  Set Variable   ${current_folder_actual}
       ...  ELSE   _Get Extracted Folder For LSS Location  file=${file}  alias=${alias}

    [Return]  ${full_extracted_folder}


_Get Extracted Folder For LSS Location
    [Arguments]  ${file}   ${alias}
    ${current_folder}  ${basename}   Split Path     ${file}
    ${out}   issh.Execute   command=ls ${current_folder} |grep -v ".zip"   alias=${alias}
    ${extracted_folder}   Strip Prompt  ${out}
    ${rtn}   OperatingSystem.Join Path   ${current_folder}  ${extracted_folder}
    [Return]  ${rtn}


_VCU Environment WA For OCP
    [Arguments]  ${alias}
#    ${out}   issh.Execute   command=hostname   alias=${alias}
#    ${hostname}   Strip Prompt   ${out}
#    #oc login -u nokiaadmin -p nokiaadmin https://api-int.hztt-25aho6-oe20-1.dyn.nesc.nokia.net:6443
#    ${cmd}   set variable   oc login -u nokiaadmin -p nokiaadmin https://api-int.${hostname}.dyn.nesc.nokia.net:6443

    ${url}  Get OCP Login URL For VCU OR VDU  alias=${alias}
    ${cmd}   set variable
    ...  oc login -u ${OCP_LOGIN_USERNAME} -p ${OCP_LOGIN_PASSWORD} ${url}
    ${old_prompt}  issh.get_prompt   alias=${alias}
    ${new_prompt}  set variable  ${old_prompt}|\\(y/n\\):\\s
    issh.set_prompt    ${new_prompt}    alias=${alias}
    ${out}   issh.Execute  command=${cmd}  check_result=False   alias=${alias}
    ${out2}  Run Keyword If  "(y/n):" in """${out}"""    issh.Execute   command=y   alias=${alias}
    issh.set_prompt  ${old_prompt}   alias=${alias}


Get Capture Log Flag
    [Documentation]   Get Capture Log Flag
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    1 or 0
    ...
    ...    Example
    ...    | ${flag} | Get Capture Log Flag |
    ...
    ${r}  ${out}  run keyword and ignore error   variable should exist  ${AIC_COMMON_TEST_SETUP_EXECUTED_FLAG}
    Return From Keyword If   "${r}"!="PASS"   1
#    ${AIC_COMMON_TEST_SETUP_EXECUTED_FLAG}  set variable if  "${r}"=="PASS"   ${AIC_COMMON_TEST_SETUP_EXECUTED_FLAG}  0
#    run keyword if   "${r}"!="PASS"  set test variable   ${AIC_COMMON_TEST_SETUP_EXECUTED_FLAG}
#    return from keyword if   ${AICLOG}==1 and ${AIC_COMMON_TEST_SETUP_EXECUTED_FLAG}==1  1
    return from keyword if    ${AIC_COMMON_TEST_SETUP_EXECUTED_FLAG}==1  1
    [Return]  0


Get f1uplane Ipv6 Address For vDU
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0   ${uplane_index}=0
    [Documentation]    Get f1uplane Ip Address for vDU
    ...   *AUTHOR* rita.feng@nokia-sbell.com
    ...    modified by:        <05-Mar-2023>, <lingtsun>, <get f1u ip via rest api>
    ...    modified by:        <29-Jul-2021>, <rifeng>, <Initial creation>
    ${f1u_ip_info}   _Get f1uplane Address For vDU  gnb_index=${gnb_index}  vdu_index=${vdu_index}  uplane_index=${uplane_index}
    ${f1u_ip}   set variable  ${f1u_ip_info['ipv6']}
    [return]  ${f1u_ip}


Get f1uplane Ipv4 Address For vDU
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0   ${uplane_index}=0
    [Documentation]    Get f1uplane Ip Address for vDU
    ...   *AUTHOR* rita.feng@nokia-sbell.com
    ...    modified by:        <05-Mar-2023>, <lingtsun>, <get f1u ip via rest api>
    ...    modified by:        <29-Jul-2021>, <rifeng>, <Initial creation>
    ${f1u_ip_info}   _Get f1uplane Address For vDU  gnb_index=${gnb_index}  vdu_index=${vdu_index}  uplane_index=${uplane_index}
    ${f1u_ip}   set variable   ${f1u_ip_info['ipv4']}
    [return]  ${f1u_ip}


_Get f1uplane Address For vDU
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0   ${uplane_index}=0
    [Documentation]    Get f1uplane Ip Address for vDU
    ...   *AUTHOR* rita.feng@nokia-sbell.com
    ...    modified by:        <05-Mar-2023>, <lingtsun>, <get f1u ip via rest api>
    ...    modified by:        <29-Jul-2021>, <rifeng>, <Initial creation>
    vDU Rest Login    gnb_index=${gnb_index}   vdu_index=${vdu_index}   alias=get_vdu_f1u_ip
    ${vdu_state_data}=   vdu.get_vdu_state_data    vdu_connection=get_vdu_f1u_ip
    ${f1u_ip_info}   set variable  ${vdu_state_data['ip_addresses']['f1_u_ip_address'][${uplane_index}]}
    [return]  ${f1u_ip_info}
    [Teardown]  vdu logout   alias=get_vdu_f1u_ip


_VDU Environment WA For OCP
    [Arguments]  ${alias}
    [Documentation]   _VDU Environment WA For OCP
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    20.10.2021, chris.l.cao@nokia-sbell.com, Fix command is stuck problem while executing 'oc login' command
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ${out}   issh.Execute   command=hostname   alias=${alias}
    ${hostname}   Strip Prompt   ${out}

    #oc login -u nokiaadmin -p nokiaadmin https://api-int.hztt-25aho6-oe20-1.dyn.nesc.nokia.net:6443
#    ${cmd}   set variable   oc login -u nokiaadmin -p nokiaadmin https://api-int.${hostname}.dyn.nesc.nokia.net:6443
    ${url}  Get OCP Login URL For VCU OR VDU  alias=${alias}
    ${cmd}   set variable
    ...  oc login -u ${OCP_LOGIN_USERNAME} -p ${OCP_LOGIN_PASSWORD} ${url}
    ${old_prompt}  issh.get_prompt   alias=${alias}
    ${new_prompt}  set variable  ${old_prompt}|\\(y/n\\):\\s
    issh.set_prompt    ${new_prompt}    alias=${alias}
    ${out}   issh.Execute  command=${cmd}  check_result=False   alias=${alias}
    ${out2}  Run Keyword If  "(y/n):" in """${out}"""    issh.Execute   command=y   alias=${alias}
    issh.set_prompt  ${old_prompt}   alias=${alias}


Convert DCAP log to txt
    [Arguments]   ${log_file_path}    ${lua_shark_script_path}     ${convert_file_path}    ${decode_as}=${None}
    ...    ${protocol}=${None}
    [Documentation]  DConvert pcap to txt with cmd tshark -X -d -O
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <22-Jun-2021>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  log_file_path           | Yes   | pcap log path                                    |
    ...    |  lua_shark_script_path   | Yes   | luashark.lua path in ute                         |
    ...    |  convert_file_path       | Yes   | the converted file path                          |
    ...    |  decode_as               | No    | default is ${None}, example: udp.port==55900,swe |
    ...    |  protocol                | No    | default is ${None}, example: swe                 |
    ...    RETURN VALUE
    ...    the path of converted path
    ...    Example
    ...    ${lua_shark_path}    set variable    /home/ute/lua_script/generated_luashark/luashark.lua
    ...    ${log_file_path}    set variable    /home/ute/SLT/test.pcap
    ...    ${decode_as}    set variable    udp.port==55900,swe
    ...    ${convert_file_path}    set variable    /home/ute/SLT/test_slt.txt
    ...    ${convert_file_path_2}    set variable    /home/ute/SLT/test_slt_2.txt
    ...    ${protocol}     set variable    swe
    ...    Convert DCAP log to txt    log_file_path=${log_file_path}    lua_shark_script_path=${lua_shark_path}
    ...    decode_as=${decode_as}    convert_file_path=${convert_file_path}    protocol=${protocol}
    ${convert_cmd}=   Run Keyword If    '${decode_as}'=='${None}' and '${protocol}'=='${None}'
    ...    Catenate    SEPARATOR=    ${TSHARK_PATH} -X lua_script:${lua_shark_script_path} -r
    ...    ${log_file_path} >${convert_file_path}
    ...    ELSE IF    '${decode_as}'!='${None}' and '${protocol}'=='${None}'
    ...    Catenate    SEPARATOR=    ${TSHARK_PATH} -X lua_script:${lua_shark_script_path} -r
    ...    ${log_file_path} -d ${decode_as} >${convert_file_path}
    ...    ELSE IF    '${decode_as}'!='${None}' and '${protocol}'!='${None}'
    ...    Catenate    SEPARATOR=    ${TSHARK_PATH} -X lua_script:${lua_shark_script_path} -r
    ...    ${log_file_path} -d ${decode_as} -O ${protocol} >${convert_file_path}
    #log    ${convert_cmd}
    Run And Expect Command To Pass    command=${convert_cmd}    msg=convert pcap to txt
    [Return]    ${convert_file_path}


Run And Expect Command To Pass
    [Arguments]    ${command}    ${msg}=
    [Documentation]    This keyword is used to run a command and get its output.
    ...                Keyword will fail if the returncode is other than zero(0)
    ${rc}    ${output}    Run and return rc and output    ${command}
    Should Be Equal As Integers   ${rc}    0    msg=${msg} failed execution with error code ${rc} ${output}   values=False
    [Return]    ${output}
