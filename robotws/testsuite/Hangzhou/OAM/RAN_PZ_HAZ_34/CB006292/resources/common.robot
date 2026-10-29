*** Settings ***
Documentation
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/symptom_collectors_hangzhou.robot
Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB006292/resources/CB006292_vars.py
Library           taf.transport.ssh    WITH NAME    csn
Library    taf.collectors.btslog        WITH NAME    btslog
Library    taf.collectors.core          WITH NAME    core


*** Keywords ***
Get Unique ID
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}   ${precise}=HIGH
    [Documentation]   Get Unique ID
    ...    | Input Parameters | Man. | Description |
    ...    | prefix       | no | prefix, default is ${EMTPY} |
    ...    | suffix       | no | suffix, default is ${EMTPY} |
    ...    | precise      | no | precise, HIGH or LOW, default is HIGH |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...  | ${tmp_id} | Get Unique ID |
    ...  | ${tmp_id} | Get Unique ID | prefix=myprefix |
    ...  | ${tmp_id} | Get Unique ID | prefix=myprefix | precise=HIGH |
    ...  | ${tmp_id} | Get Unique ID | precise=HIGH |
    ...  | ${tmp_id} | Get Unique ID | precise=LOW |
    ${precise}  Set Variable  ${precise.upper()}
    ${rtn}  Run Keyword If  "${precise}"=="HIGH"  _Get Unique ID High Precise  prefix=${prefix}   suffix=${suffix}
    ...   ELSE   _Get Unique ID LOW Precise   prefix=${prefix}   suffix=${suffix}
    [Return]    ${rtn}

_Get Unique ID High Precise
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id}    Evaluate    str(uuid.uuid4())    modules=uuid
    ${unique_id}    String.Replace String    ${unique_id}    -    ${EMPTY}
    [Return]    ${prefix}${unique_id}${suffix}

_Get Unique ID LOW Precise
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id}    Evaluate    str(time.time())    modules=time
    ${unique_id}    String.Replace String    ${unique_id}    .    ${EMPTY}
    [Return]    ${prefix}${unique_id}${suffix}

Check the CM upload staus from BTSlog
    ${btslog_info}    CB006292_vars.get_gnb_control_pc_info
    FOR   ${value}   IN   @{btslog_info}
        ${connection_asik}=  csn.connect_to    hostname=${value['ctrl_addr']}    username=${value['ctrl_username']}
        ...    password=${value['ctrl_password']}    alias=taf
        ${CM_plan_status}  csn.Execute    command=cat /tmp/btslog2/SYSLOG*.LOG |grep 'task::UploadTask'   timeout=60   connection=taf
        Should Contain    ${CM_plan_status}    CM upload was completed successfully
    END
    sleep   3s
    [Teardown]  csn.disconnect    connection=taf

Start BTS LOG Collection On Gnb
    ${btslog_info}    CB006292_vars.get_gnb_control_pc_info
    log to console    Start BTS LOG Collection On Gnb And Rus
    FOR   ${value}   IN   @{btslog_info}
       ${status}   run keyword and return status   Create Btslog log collection on UTE   name=${value['btslog_name']}
    ...   btslog_path=/opt/btslog/btslog    btslog_launcher_path=/opt/btslog/btslog_launcher    log_dir=/tmp/
    ...   host=${value['ctrl_addr']}    user=${value['ctrl_username']}    password=${value['ctrl_password']}
       run keyword if  not ${status}   Log   start btslog collection failed on ${value['ctrl_addr']}   WARN
    END

Create Btslog log collection on UTE
    [Arguments]    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog
    ...             ${btslog_launcher_path}=/opt/btslog/btslog_launcher          ${log_dir}=/tmp/
    ...             ${host}=${tl.test_pc.default_ssh_connection_details.addr}
    ...             ${user}=${tl.test_pc.default_ssh_connection_details.username}
    ...             ${password}=${tl.test_pc.default_ssh_connection_details.password}
    [Documentation]    create btslog log collector on testvm.
    ...                name: name of the collector. Ex: btslog
    ...                btslog_path: (optional) path of the ‘btslog’ executable default value:”/opt/btslog/btslog”
    ...                btslog_launcher_path: (optional) path of ‘btslog_launcher’
    ...                executable default value:”/opt/btslog/btslog_launcher”
    ...                log_dir: path from where to get btslog files default value: “/tmp/btslog2”
    run keyword and ignore error   Clean BTSlog on UTE   host=${host}   user=${user}   password=${password}
    &{executor}=    create dictionary    host=${host}
    ...                                  user=${user}
    ...                                  password=${password}
    btslog.create_btslog_collector       name=${name}          btslog_path=${btslog_path}
    ...                                  btslog_launcher_path=${btslog_launcher_path}
    ...                                  executor=${executor}    log_dir=${log_dir}
    btslog.Set Suite Alias               ${name}
    core.setup_collectors                names=${name}
    core.start_collectors                names=${name}

Clean BTSlog on UTE
    [Arguments]  ${host}   ${user}   ${password}
    csn.Connect to   hostname=${host}   username=${user}   password=${password}  alias=testpc
    csn.Execute   command=pkill -9 -f -x '/opt/btslog/btslog -NOGUI'   timeout=60   connection=testpc
    csn.Execute   command=rm -rf /tmp/BTSLogCommandsLocalServer   timeout=60    connection=testpc
    [Teardown]   csn.Disconnect   connection=testpc

Stop BTS LOG Collection On Gnb
    [Arguments]    ${dir}
    log to console    Stop BTS LOG Collection On Gnb
    ${btslog_info}    CB006292_vars.get_gnb_control_pc_info
    FOR   ${value}   IN   @{btslog_info}
       ${collect_status}   run keyword and return status   Collect_logs    names=${value['btslog_name']}
       run keyword if  not ${collect_status}   Log   Collect logs failed on ${value['ctrl_addr']}   WARN
    END

Download And Remove GNB BTS LOG Collection
    [Arguments]    ${dir}
    log to console    Download And Remove GNB BTS LOG Collection
    ${btslog_info}    CB006292_vars.get_gnb_control_pc_info
    FOR   ${value}   IN   @{btslog_info}
       ${download_status}   run keyword and return status   Download Btslog    dir=${dir}    UTE_ADDR=${value['ctrl_addr']}
    ...   UTE_USERNAME=${value['ctrl_username']}    UTE_PASSWORD=${value['ctrl_password']}
       run keyword if  not ${download_status}   Log   Download logs failed on on ${value['ctrl_addr']}   WARN
       ${remove_status}   run keyword and return status   Remove Btslog    UTE_ADDR=${value['ctrl_addr']}
    ...   UTE_USERNAME=${value['ctrl_username']}    UTE_PASSWORD=${value['ctrl_password']}
       run keyword if  not ${remove_status}   Log   Remove logs failed on ${value['ctrl_addr']}   WARN
    END

Download Btslog
    [Arguments]   ${dir}   ${UTE_ADDR}   ${UTE_USERNAME}    ${UTE_PASSWORD}
    ${connection_asik}=  csn.connect_to    hostname=${UTE_ADDR}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=taf
    csn.Execute    command=cd /tmp/btslog2;tar -cvf btslog_${UTE_ADDR}.tar SYSLOG*   timeout=60   connection=taf
    csn.Download File    remote_path=/tmp/btslog2/btslog_${UTE_ADDR}.tar
    ...    local_path=${OUTPUT_DIR}/btslog_${UTE_ADDR}.tar   connection=taf
    sleep   3s
    csn.disconnect    connection=taf

Remove Btslog
    [Arguments]   ${UTE_ADDR}   ${UTE_USERNAME}    ${UTE_PASSWORD}
    ${connection_asik}=  csn.connect_to    hostname=${UTE_ADDR}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=taf
    csn.Execute    command=rm -rf /tmp/btslog2/btslog_${UTE_ADDR}.tar   timeout=60   connection=taf
    csn.Execute    command=ll /tmp/btslog2/;rm -rf /tmp/btslog2/SYSLOG*   timeout=60   connection=taf
    csn.Execute    command=rm -rf /tmp/btslog2/BTSLOG_TRACE*   timeout=60   connection=taf
    csn.disconnect    connection=taf
