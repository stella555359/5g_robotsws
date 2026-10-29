*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_log_startuplog.robot


#*** Variables ***



*** Keywords ***
Collect VDU Start Up Log
    [Documentation]   Collect VDU Start Up Log
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Collect VDU Start Up Log |
    ...
    log to console  Collect VDU Start Up Log
    ${count_of_gnbs}   get length  ${tl.gnbs}
    FOR  ${gnb_index}  IN RANGE  ${count_of_gnbs}
        Collect VDU Start Up Log For Specified GNB    ${gnb_index}
    END


Collect VDU Start Up Log For Specified GNB
    [Arguments]  ${gnb_index}=0
    [Documentation]   Collect VDU Start Up Log For Specified GNB
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Collect VDU Start Up Log For Specified GNB |
    ...
    ${count_of_vdu}  get length  ${tl.gnbs[${gnb_index}].dus}
    FOR  ${vdu_index}  IN RANGE  ${count_of_vdu}
        Collect VDU Start Up Log For Specified GNB For Specified VDU     gnb_index=${gnb_index}   vdu_index=${vdu_index}
    END


Collect VDU Start Up Log For Specified GNB For Specified VDU
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Collect VDU Start Up Log For Specified GNB
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    23.11.2021,chris.l.cao@nokia-sbell.com, add change history, optimize to shorten dryrun time
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Collect VDU Start Up Log For Specified GNB For Specified VDU |
    ...
    log to console  Collect VDU Start Up Log For Specified GNB For Specified VDU(gnb_index:${gnb_index},vdu_index:${vdu_index})
    FOR  ${pod_abbr}  IN  oamasm  oamcm  oamconfig  oamctp  oamext  oamfh  oamfm  oampm   cprt   up
        Collect VDU Start Up Log For Specified GNB For Specified VDU For One Pod
       ...   pod_abbr=${pod_abbr}   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    END


Collect VDU Start Up Log For Specified GNB For Specified VDU For One Pod
    [Arguments]   ${pod_abbr}   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]   Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Collect VDU Start Up Log For Specified GNB
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr | yes | pod_abbr, oam, cprt or up |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Collect VDU Start Up Log For Specified GNB For Specified VDU For One Pod | pod_abbr=oam |
    ...
    ${ns}  get vdu namespace from testline
    ${container_list}   Run Keyword If   "${pod_abbr}"=="oamasm"    create list   oamasm
    ...   ELSE IF   "${pod_abbr}"=="oamcm"     create list    oamcm
    ...   ELSE IF   "${pod_abbr}"=="oamconfig"   create list  oamconfig
    ...   ELSE IF   "${pod_abbr}"=="oamctp"    create list    oamctp
    ...   ELSE IF   "${pod_abbr}"=="oamext"    create list    oamagent
    ...   ELSE IF   "${pod_abbr}"=="oamfh"     create list    oamfh
    ...   ELSE IF   "${pod_abbr}"=="oamfm"     create list    oamfm
    ...   ELSE IF   "${pod_abbr}"=="oampm"     create list    oampm
    ...   ELSE IF   "${pod_abbr}"=="cprt"      create list    cprt
    ...   ELSE IF   "${pod_abbr}"=="up"        create list    l2hi   l1hi   l2rt
    ...   ELSE    Fail  Unknown pod abbreviation:${pod_abbr}!
    ${startup_log_path}  set variable  tmp
    ${alias}   Get Unique Id
    Connect To vDU Node Interactively   pod_abbr=${pod_abbr}   alias=${alias}
    ${partial_file_name}   Set Variable If  "${pod_abbr}"=="up"    LINUX_startup.   startup_DEFAULT.
    ${startup_log_file}  Get Container File Name   container=${container_list[0]}  folder=/tmp  partial_file_name=${partial_file_name}
     ...   alias=${alias}
    ${tmp_folder_level_0}   get a remote directory   startup_log_${pod_abbr}   alias=${alias}
    ${full_pod_name}   get full pod name by pod abbreviation interactively   pod_abbr=${pod_abbr}   vdu_index=${vdu_index}   alias=${alias}
    FOR   ${container_abbr}   IN  @{container_list}
       ${tmp_log_file}   get a remote file   ${tmp_folder_level_0}  ${pod_abbr}   ${container_abbr}   ${startup_log_file}   alias=${alias}
       ${full_container_name}  get full container name by container abbreviation   ctr_abbr=${container_abbr}  vdu_index=${vdu_index}
       ${out}   issh.Execute
       ...   command=kubectl cp -n ${ns} ${full_pod_name}:${startup_log_path}/${startup_log_file} ${tmp_log_file} -c ${full_container_name}
       ...   alias=${alias}

      ${out}  issh.Execute   command=cd ${tmp_folder_level_0}   alias=${alias}
      ${remote_file}   set variable  startup_log_${pod_abbr}_${container_abbr}.tgz

      ${out}  issh.Execute   command=ls -l   alias=${alias}
      ${out}  issh.Execute   command=tar -czf ${remote_file} *   alias=${alias}
      ${out}  issh.Execute   command=chmod 777 ${remote_file}   alias=${alias}
      ${remote_path}  OperatingSystem.Join Path  ${tmp_folder_level_0}   ${remote_file}
      #${local_file}   get a file     starup_log_${pod_abbr}   startup_log_${pod_abbr}_${gnb_index}_${vdu_index}.tgz
      ${local_file}   get a file     starup_log_${pod_abbr}   startup_log_${pod_abbr}_${container_abbr}_${gnb_index}_${vdu_index}.tgz
      ${out}   issh.download_file   remote_path=${remote_path}    local_path=${local_file}     alias=${alias}
    END

Get Startup Log From VDU Container
    [Documentation]  Get Start UP Log From Container
    ...    author: hongyuan.sun@nokia-sbell.com
    ...    modified by:        <03-Sep-2021>, <hongysun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  pod_dic    | No |  pod_dic. default is empty, example: a dict:_Set Pod Dictionary Default  |
    ...    |  vdu_index  | No |  pod_dic. default is 0     |
    ...    *RETURN VALUE*
    ...    download Startup log to local,Startup log in the generated directory
    ...    Example
    ...    |  Get Startup Log From VDU Container |
    [Arguments]  ${pod_dic}=${EMPTY}   #${vdu_index}=0
    ${pod_container_map}=   run keyword if   '${pod_dic}'=='${EMPTY}'   _Set Pod Dictionary Default
    ...     ELSE   set variable    ${pod_dic}
    ${find_path}    set variable   tmp
    ${match_pattern}    set variable     \\S*startup[_A-Za-z.]+
    ${podlist}    Get Dictionary Keys   ${pod_container_map}
    FOR  ${pod}  IN  @{podlist}
        @{containerList}    Get From Dictionary    ${pod_container_map}    ${pod}
        ${output}=  _Get Startup Log From VDU Container In Specific IP   containerList=${containerList}   find_path=${find_path}
    ...   match_pattern=${match_pattern}   pod_abbr=${pod}
    END

_Set Pod Dictionary Default
    @{oam_list}   create list   oam   oamfh
    @{cprt_list}   create list   cprt
    @{up_list}   create list   l2hi   l1hi   l2rt
    &{pod_dic}   Create dictionary
    ...    oam=${oam_list}
    ...    cprt=${cprt_list}
    ...    up=${up_list}
    [Return]    ${pod_dic}

_Get Startup Log From VDU Container In Specific IP
    [Arguments]  ${containerList}   ${find_path}   ${match_pattern}
    ...          ${pod_abbr}=None   ${alias}=default   #${check_result}=${True}   ${vdu_index}=0
    @{all_file_path}   create list  @{empty}
    ${alias}   Get Unique Id
    Connect To K8s Master Interactively    alias=${alias}
    FOR  ${container}  IN  @{containerList}
        ${file_path}=   Get File Name In VDU Container   pod_abbr=${pod_abbr}   container=${container}
    ...   find_path=${find_path}   match_pattern=${match_pattern}   alias=${alias}
        #${all_file_path}=  combine lists   ${all_file_path}   ${file_path}
    END
    log    ${all_file_path}
    FOR  ${file}  IN  @{all_file_path}
       ${log_local_stored_path}   get a directory  start_up/${file}[0]/
       Download File From VDU Container_New   container=${file}[0]   file_source_path=${file}[1]
    ...    log_local_stored_path=${log_local_stored_path}   alias=${alias}
    END

Get File Name In VDU Container
    [Documentation]  Get Start UP Log name From Container
    ...    author: hongyuan.sun@nokia-sbell.com
    ...    modified by:        <03-Sep-2021>, <hongysun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  pod_abbr  | yes |   pod name   |
    ...    |  containner | yes |  container name |
    ...    |  find_path  | yes |  ca default value: tmp ,  cache path |
    ...    |  match_pattern | yes |  will check log name |
    ...    |  alias | yes |  Unique Id |
    ...    |  check_result | No |  check_result,default value True |
    ...    |  vdu_index | No |  vdu_index,default value 0|
    ...    *RETURN VALUE*
    ...    a list incluede container name and Startup log cache path,
    ...     eg:
    ...         [['cprt','tmp/cprt log file],['oam','tmp/oam log file],...]
    ...    Example
    ...    |  ${file_path} | Get File Name In VDU Container | ${container}='cprt' | ${find_path}=tmp |
    ...    ${match_pattern}= \\S*startup[_A-Za-z.]+  | ${pod_abbr}=None|
    [Arguments]  ${pod_abbr}   ${container}   ${find_path}   ${match_pattern}   ${alias}=${alias}   ${check_result}=${True}   ${vdu_index}=0
    @{file_path}   create list  @{empty}
    ${ns}   Get vDU Namespace From TestLine
    ${container_name}   Get Full Container Name By Container Abbreviation   ctr_abbr=${container}   vdu_index=${vdu_index}
    ${pod_name}  Get Full Pod Name By Pod Abbreviation Interactively  pod_abbr=${pod_abbr}   alias=${alias}  vdu_index=${vdu_index}
    ${sudo_outer}  Get VCU Sudo For Current User   alias=${alias}
    ${kubectl_cmd}   Set Variable   ${sudo_outer} kubectl exec -it ${pod_name} -c ${container_name} -n ${ns} -- ls ${find_path}
    ${out}   issh.Execute    command=${kubectl_cmd}   check_result=${check_result}   alias=${alias}
    @{file_list}=   get regexp matches   ${out}   ${match_pattern}
    FOR  ${var}  IN  @{file_list}
       log    ${var}
        ${container_and_file_path}  create list  ${container}  ${find_path}/${var}
        Append To List   ${file_path}   ${container_and_file_path}
    END
    [Return]    ${file_path}


Download File From VDU Container_New
    [Documentation]  Download File From VDU Container
    ...    author: hongyuan.sun@nokia-sbell.com
    ...    modified by:        <03-Sep-2021>, <hongysun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  container  | yes |  container name |
    ...    |  file_source_path  | yes |  save log cache path |
    ...    |  log_local_stored_path  | yes |  save log local path |
    ...    |  alias  | yes |  Unique Id |
    ...    |  check_result  | No |  check_result,default value True |
    ...    |  vdu_index  | No | vdu_index,default value 0  |
    ...    |  pod_abbr  | No | pod_abbr,default value None  |
    ...    *RETURN VALUE*
    ...    download startup log in the vdu container to local
    ...    Example
    ...    | Download File From VDU Container_New| ${container}='sprt'| ${file_source_path}='tmp/startup_DEFAULT.log.xz' |
    ...   ${log_local_stored_path}='/home/ute/logs/TESTCASE__[1][1.0]_5GC002130_Cloud_vDU_Pod_Container_CellOnAir_check/
    ...   2021_09_03_13_57_13/start_up/cprt/ |
    [Arguments]  ${container}   ${file_source_path}   ${log_local_stored_path}   ${alias}=default
    ...          ${check_result}=${True}   ${pod_abbr}=None   #${vdu_index}=0
    ${pod_abbr}=    run keyword if  '${pod_abbr}'=='None'    Get Pod Abbreviation By Container Abbreviation   container_abbr=${container}
    ...   ELSE    set variable    ${pod_abbr}
    ${platform}=   Get Platform Name

    run keyword if  "${platform}"=="NCS" or "${platform}"=="OCP"  _Download File From VDU Container NCS And OCP
    ...    pod_abbr=${pod_abbr}   container=${container}   file_source_path=${file_source_path}
    ...    log_local_stored_path=${log_local_stored_path}    alias=${alias}   check_result=${check_result}

_Download File From VDU Container NCS And OCP
    [Arguments]  ${pod_abbr}   ${container}   ${file_source_path}   ${log_local_stored_path}   ${alias}=default
    ...          ${check_result}=${True}   ${vdu_index}=0   #${gnb_index}=0
    ${ns}   Get vDU Namespace From TestLine
    ${container_name}  Get Full Container Name By Container Abbreviation  ctr_abbr=${container}   vdu_index=${vdu_index}
    ${pod_name}  Get Full Pod Name By Pod Abbreviation Interactively  pod_abbr=${pod_abbr}   alias=${alias}  vdu_index=${vdu_index}
    ${temp_path}  set variable   ${file_source_path}
    ${sudo_outer}  Get VCU Sudo For Current User   alias=${alias}
    ${kubectl_cmd}   Set Variable   ${sudo_outer} kubectl cp ${pod_name}:${file_source_path} -c ${container_name} tmp/${file_source_path} -n ${ns}
    ${out}   issh.Execute    command=${kubectl_cmd}   check_result=${check_result}   alias=${alias}
    ${out}    issh.Execute     command=ls   alias=${alias}
    issh.Download File   remote_path=/home/cbis-admin/tmp/${file_source_path}   local_path=${log_local_stored_path}    alias=${alias}
    ${out}  issh.Execute  command=sudo rm -rf /home/cbis-admin/tmp/${file_source_path}     alias=${alias}
