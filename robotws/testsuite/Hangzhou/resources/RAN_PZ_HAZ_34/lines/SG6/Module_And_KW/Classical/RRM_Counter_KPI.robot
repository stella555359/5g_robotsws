*** Settings ***
Documentation
...    author: mengli yang
...    contact: mengli.yang@nokia-sbell.com
...    Common KWs related to PM counter and KPI.

Resource    RRM_Common_Resource.robot



*** Keywords ***
#-------------------PM---------------------------------------------------------------------------------
PM_counters_collector
    [Arguments]    ${gnb_id}=0    ${name}=gnb_pm_counters    ${port}=443
    [Documentation]    This kw is used for Collects the pm counters files to the default path.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_id | No | gnb_id default value:0 |
    ...    | name | No | name of the collector. Ex: gnb_pm_counters |
    ...    | port | No | port of the collector |
    ...
    ...    | Return Value | Description |
    ...    | ${PM_counter_path} | return path of PM counter |
    ...
    ...    Example
    ...    | PM_counters_collector | gnb_id=${0} | name=${0} | port=443 |
    ...
    &{webservice}=    create dictionary    host=${tl.gnbs[${gnb_id}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                                    user=${http_USERNAME}
    ...                                    password=${http_PASSWORD}
    ...                                    port=${port}
    COAM_Admin.Login    bts_host=${tl.gnbs[${gnb_id}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    username=${http_USERNAME}
    ...    password=${http_PASSWORD}
    ...    bts_port=${port}
    ...    alias=pmcounter_collector_bts${gnb_id}
    coam.collect_pm_files    target_file_name=${TEST_LOG_DIRECTORY}/${name}_zip_file
    ...    connection=pmcounter_collector_bts${gnb_id}
    OperatingSystem.run    mkdir -p ${TEST_LOG_DIRECTORY}/${name}
    OperatingSystem.run    unzip ${TEST_LOG_DIRECTORY}/${name}_zip_file -d ${TEST_LOG_DIRECTORY}/${name}
    ${gz_file}    OperatingSystem.run    find ${TEST_LOG_DIRECTORY}/${name}/PERFMON_FILES/ -name "*.gz"
    ${gz_file_list}    Split String    ${gz_file}
    FOR    ${one_gz_file}    IN    @{gz_file_list}
        OperatingSystem.run    gunzip ${one_gz_file}
    END
    OperatingSystem.run    mv ${TEST_LOG_DIRECTORY}/${name}/PERFMON_FILES/*.xml ${TEST_LOG_DIRECTORY}/${name}/
    OperatingSystem.run    rm -rf ${TEST_LOG_DIRECTORY}/${name}/PERFMON_FILES
    Directory Should Not Be Empty    ${TEST_LOG_DIRECTORY}/${name}
    ${PM_counter_path}=    set variable    ${TEST_LOG_DIRECTORY}/${name}
    set suite variable    ${PM_counter_path}
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout    alias=pmcounter_collector_bts${gnb_id}
    [Return]    ${PM_counter_path}

Get_PM_counters_values
    [Arguments]    ${pi_list}=0    ${PM_counter_path}=${PM_counter_path}    ${oam_type}=coam
    ...    ${bts_index}=${0}
    [Documentation]    Get PI values at managed objects per measurement period for a given list of PI IDs.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pi_list | No | define pi list |
    ...    | PM_counter_path | No | define path of PM counter |
    ...    | oam_type | No | define oam type |
    ...
    ...    | Return Value | Description |
    ...    | ${pi_value_list} | return list of Pi value |
    ...
    ...    Example
    ...    | Get_PM_counters_values | pi_list=0 | PM_counter_path=${PM_counter_path} | oam_type=coam |
    ...
    ${mrbtsid}    Set Variable    ${tl.gnbs[${bts_index}].instance_id}
    ${cmd}=    set variable if    '${oam_type}'=='mzoam'    cd "${PM_counter_path}";ls -dr1 *PM_*_SRAN |head -1
    ...    cd "${PM_counter_path}";ls -dr1 *PM.BTS-${mrbtsid}*.xml |head -1
    ${pm_filename}    Run    ${cmd}
    ${pi_value_list}    get_pi_value    pi_list=${pi_list}    pi_dir=${PM_counter_path}    pi_file_pattern=${pm_filename}
    Set Suite Variable    ${pi_value_list}
    [Return]    ${pi_value_list}

Get_PM_counters_values_For_Period
    [Arguments]    ${start_time}    ${end_time}    ${pi_list}=0    ${PM_counter_path}=${PM_counter_path}    ${oam_type}=coam
    ...    ${bts_index}=${0}
    [Documentation]    Get PI values at managed objects per measurement period for a given list of PI IDs.
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pi_list | No | define pi list |
    ...    | PM_counter_path | No | define path of PM counter |
    ...    | oam_type | No | define oam type |
    ...
    ...    | Return Value | Description |
    ...    | ${pi_value_list} | return list of Pi value |
    ...
    ...    Example
    ...    | Get_PM_counters_values | pi_list=0 | PM_counter_path=${PM_counter_path} | oam_type=coam |
    ...
    ${mrbtsid}    Set Variable    ${tl.gnbs[${bts_index}].instance_id}
    ${mrbtsid}    Run Keyword If    '${mrbtsid}'=='${None}'
    ...    _Get BTS Information From btsinfo    info_key=mrbtsID    bts_index=${bts_index}
    ...    ELSE    Set Variable    ${mrbtsid}
    ${cmd}=    set variable if    '${oam_type}'=='mzoam'    cd "${PM_counter_path}";ls -dr1 *PM_*_SRAN |head -1
    ...    cd "${PM_counter_path}";ls -dr1 *PM.BTS-${mrbtsid}*.xml
    ${cmd_2}=    set variable if    '${oam_type}'=='mzoam'    cd "${PM_counter_path}";ls -dr1 *PM_*_SRAN |head -1
    ...    cd "${PM_counter_path}";ls -dr1 *PM.BTS-1.*.xml
    ${pm_filename}    Run    ${cmd}
    ${has_error}    Run Keyword And Return Status    Should Contain    ${pm_filename}    No such file or directory
    ${pm_filename}    Run Keyword If    ${has_error}
    ...    Run    ${cmd_2}
    ...    ELSE    Set Variable    ${pm_filename}
    ${pm_filenames}    Split String    ${pm_filename}
    ${pi_value_list}    Create List
    FOR    ${pm_name}    IN    @{pm_filenames}
        ${matches}    Get Regexp Matches    ${pm_name}    20[0-9]{6}.[0-9]{6}
        ${pmfile_timestring}    Replace String    ${matches}[0]    .    ${SPACE}
        ${pm_time}    Convert Date    ${pmfile_timestring}
        ${in_period}    Evaluate    '${pm_time}'>='${start_time}' and '${pm_time}'<='${end_time}'
        ${pi_values}    Run Keyword If    '${in_period}'=='${TRUE}'
        ...    get_pi_value    pi_list=${pi_list}    pi_dir=${PM_counter_path}    pi_file_pattern=${pm_name}
        ${pi_value_list}    Run Keyword If    '${in_period}'=='${TRUE}'
        ...    Combine Lists    ${pi_value_list}    ${pi_values}
        ...    ELSE
        ...    Set Variable    ${pi_value_list}
    END
    [Return]    ${pi_value_list}

Check counter value greater than expect value
    [Arguments]    ${pi_value_list}    ${expect_value}=1
    [Documentation]     Check PI values at managed objects per measurement period for a given list of PI IDs.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pi_value_list | No | define pi value list |
    ...    | expect_value | No | define expect value |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Check counter value greater than expect value | pi_value_list | expect_value=1 |
    ...
    @{counter_value_list}    Create List
    FOR    ${item}    IN    @{pi_value_list}
        ${pi_value_item}    Get Dictionary Values    ${pi_value_list[0]}
        ${pi_value_path}    Get Dictionary Values    ${pi_value_item[0]}
        ${counter_value}    Get Dictionary Values    ${pi_value_path[0]}
        Append To List    @{counter_value_list}    ${counter_value}
    END
    should be true    ${counter_value_list[0]} > ${expect_value} or ${counter_value_list[1]} > ${expect_value}

Check counter value equal to expect value
    [Arguments]    ${pi_value_list}    ${expect_value}=1
    [Documentation]     This kw is used to check counter value equal to expect value
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pi_value_list | No | define pi value list |
    ...    | expect_value | No | define expect value |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Check counter value equal to expect value | pi_value_list | expect_value=1 |
    ...
    @{counter_value_list}    Create List
    FOR    ${item}    IN    @{pi_value_list}
        ${pi_value_item}    Get Dictionary Values    ${pi_value_list[0]}
        ${pi_value_path}    Get Dictionary Values    ${pi_value_item[0]}
        ${counter_value}    Get Dictionary Values    ${pi_value_path[0]}
        Append To List    @{counter_value_list}    ${counter_value}
    END
    should be true    ${counter_value_list[0]} == ${expect_value} or ${counter_value_list[1]} == ${expect_value}

Check counter list value
    [Arguments]    ${pi_list}    ${PM_counter_path}=${PM_counter_path}
    [Documentation]     This kw is used to Check counter list value
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pi_list | No | define pi list |
    ...    | PM_counter_path | No | define the path of PM counter |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Check counter list value | ${pi_list} | PM_counter_path=${PM_counter_path} |
    ...
    ${cmd}=    set variable    cd "${PM_counter_path}";ls -dr1 *PM*.xml |head -1
    ${pm_filename}    Run    ${cmd}
    @{pi_value_list}    create list
    @{counter_ids_list}    create list
    FOR    ${counter_ID}    IN    @{pi_list}
        ${counter_info}    Run    cat ${PM_counter_path}/${pm_filename} | grep ${counter_ID}
        ${counter_id_list_and_value}    get regexp matches    ${counter_info}    <${counter_ID}>(\\d+)</${counter_ID}>    0
        append to list    ${counter_ids_list}    ${counter_id_list_and_value[0]}
    END
    #Set Suite Variable    ${counter_ids_list}
    @{counter_values_list}    Create List
    FOR    ${counter_id_item}    IN    @{counter_ids_list}
        ${counter_id_list}    split string    ${counter_id_item}    <
        ${counter_value_item}    get from list    ${counter_id_list}    1
        ${counter_value_list}    split string    ${counter_value_item}    >
        ${counter_value}    get from list    ${counter_value_list}    1
        Append To List    ${counter_values_list}    ${counter_value}
    END
    [Return]    ${counter_values_list}

Check counter value
    [Arguments]    ${counter_ID}    ${expect_value}
    [Documentation]      this kw is used to check counter value
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | counter_ID | No | define counter id |
    ...    | expect_value | No | define expect value |
    ...
    ...    | Return Value | Description |
    ...    | ${counter_id_value_list} | return value list of counter |
    ...
    ...    Example
    ...    | Check counter value | counter_ID=M55145C00220 | expect_value=1 |
    ...
    Wait Until Keyword Succeeds    5m    1m    Connect to First_ASIB
    ssh.execute    gunzip /tmp/PM.BTS*.xml.gz    connection=First_ASIB
    ${counter_info}    ssh.execute    cat /tmp/PM.BTS*.xml | grep ${counter_ID}    connection=First_ASIB
    ${counter_ids_list}    get regexp matches    ${counter_info}    <${counter_ID}>(\\d+)</${counter_ID}>    0
    Set Suite Variable    ${counter_ids_list}
    @{counter_values_list}    Create List
    FOR    ${counter_id_item}    IN    @{counter_ids_list}
        ${counter_id_list}    split string  ${counter_id_item}    <
        ${counter_value_item}    get from list    ${counter_id_list}    1
        ${counter_value_list}    split string    ${counter_value_item}    >
        ${counter_value}    get from list    ${counter_value_list}    1
        Append To List    ${counter_values_list}    ${counter_value}
    END
    @{counter_id_value_list}    Create List
    ${number_of_counter}    get length    ${counter_values_list}
    FOR    ${index}    IN RANGE    ${number_of_counter}
        ${counter_id_value}    Convert to number    ${counter_values_list[${index}]}
        Set suite variable    ${counter_id_value}
        ${status}    run keyword and return status    Compare counter    counter_id_value=${counter_id_value}
        ...                                                              expect_value=${expect_value}
        Append To List    ${counter_id_value_list}    ${counter_id_value}
        exit for loop if    ${status}==True
    END
    Set suite variable    ${status}
    run keyword if    "${status}"=="False"    fail    msg=check counter is fail
    [Return]    ${counter_id_value_list}
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=First_ASIB

Check counter value without Judge
    [Arguments]    ${counter_ID}
    [Documentation]      this kw is used to check counter value without Judge
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | counter_ID | No | define counter id |
    ...
    ...    | Return Value | Description |
    ...    | ${counter_id_value_list} | return value list of counter |
    ...
    ...    Example
    ...    | Check counter value without Judge | counter_ID=M55145C00220 |
    ...
    Wait Until Keyword Succeeds    5m    1m    Connect to First_ASIB
    ssh.execute    gunzip /tmp/PM.BTS*.xml.gz    connection=First_ASIB
    ${counter_info}    ssh.execute    cat /tmp/PM.BTS*.xml | grep ${counter_ID}    connection=First_ASIB
    ${counter_ids_list}    get regexp matches    ${counter_info}    <${counter_ID}>(\\d+)</${counter_ID}>    0
    Set Suite Variable    ${counter_ids_list}
    @{counter_values_list}    Create List
    FOR    ${counter_id_item}    IN    @{counter_ids_list}
        ${counter_id_list}    split string    ${counter_id_item}    <
        ${counter_value_item}    get from list    ${counter_id_list}    1
        ${counter_value_list}    split string    ${counter_value_item}    >
        ${counter_value}    get from list    ${counter_value_list}    1
        Append To List    ${counter_values_list}    ${counter_value}
    END
    [Return]    ${counter_values_list}
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=First_ASIB

Compare counter
    [Arguments]    ${counter_id_value}    ${expect_value}
    [Documentation]      this kw is used to compare counter
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id_value | No | define the value of counter id |
    ...    | expect_value | No | define expect value |
    ...
    ...    | Return Value | Description |
    ...    | ${status} | return the status |
    ...
    ...    Example
    ...    | Compare counter | counter_id_value=1 | expect_value=1 |
    ...
    ${status}    should be true    ${counter_id_value} > ${expect_value}
    [Return]    ${status}

Compare counter equal expect value
    [Arguments]    ${counter_id_value}    ${expect_value}
    [Documentation]      this kw is used to compare counter equal expect value
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id_value | No | define the value of counter id |
    ...    | expect_value | No | define expect value |
    ...
    ...    | Return Value | Description |
    ...    | ${status} | return the status |
    ...
    ...    Example
    ...    | Compare counter equal expect value | counter_id_value=1 | expect_value=1 |
    ...
    ${status}    should be true    ${counter_id_value} == ${expect_value}
    [Return]    ${status}

Check counter value by PLMN id
    [Arguments]    ${cell_id}    ${PLMN}    ${counter_ID}    ${expect_value}    ${cell_or_gnb}=cell
    [Documentation]      this kw is used to Check counter value by PLMN id
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | cell_id | No | define cell id |
    ...    | PLMN | No | define the  PLMN, such as: 26203 |
    ...    | counter_ID | No | define the counter id |
    ...    | expect_value | No | define expect value |
    ...    | cell_or_gnb | No | define the counter is include in cell or gnb level |
    ...
    ...    | Return Value | Description |
    ...    | ${counter_id_value_list} | return the value list of counter id  |
    ...
    ...    Example
    ...    | Check counter value by PLMN id | cell_id=2 | PLMN=26203 | counter_ID=${pi} |
    ...    | ...                            | expect_value=${expect_value} | cell_or_gnb=${cell_or_gnb} |
    ...
    ${MCC}    Get Substring    ${PLMN}    0    3
    ${MNC}    Get Substring    ${PLMN}    3    5
    Wait Until Keyword Succeeds    5m    1m    Connect to First_ASIB
    ssh.execute    gunzip /tmp/PM.BTS*.xml.gz    connection=First_ASIB
    Set test variable    ${PLMN_Path}    PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}</DN></MO><MO
    Set test variable    ${PLMN_cell_Path}    PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}</DN></MO><MO
    ${counter_info}    ssh.execute    cat /tmp/PM.BTS*.xml    connection=First_ASIB
    ${counter_ids_list_grep}    run keyword if    '${cell_or_gnb}' == 'cell'    get regexp matches    ${counter_info}
    ...    ${PLMN_cell_Path} dimension="MCCMNC"><DN>PLMN-PLMN/MCC-${MCC}/MNC-${MNC}.*?<${counter_ID}>(\\d+)</${counter_ID}>    0
    ...    ELSE    get regexp matches    ${counter_info}
    ...    ${PLMN_Path} dimension="MCCMNC"><DN>PLMN-PLMN/MCC-${MCC}/MNC-${MNC}.*?<${counter_ID}>(\\d+)</${counter_ID}>    0
    ${counter_ids_str_grep}    get from list    ${counter_ids_list_grep}    0
    ${counter_ids_list}    get regexp matches    ${counter_ids_str_grep}    <${counter_ID}>(\\d+)</${counter_ID}>    0
    Set Suite Variable    ${counter_ids_list}
    @{counter_values_list}    Create List
    FOR    ${counter_id_item}    IN    @{counter_ids_list}
        ${counter_id_list}    split string    ${counter_id_item}    <
        ${counter_value_item}    get from list    ${counter_id_list}    1
        ${counter_value_list}    split string    ${counter_value_item}    >
        ${counter_value}    get from list    ${counter_value_list}    1
        Append To List    ${counter_values_list}    ${counter_value}
    END
    @{counter_id_value_list}    Create List
    ${number_of_counter}    get length    ${counter_values_list}
    FOR    ${index}    IN RANGE    ${number_of_counter}
        ${counter_id_value}    Convert to number    ${counter_values_list[${index}]}
        Set suite variable    ${counter_id_value}
        ${status}    run keyword and return status    Compare counter    counter_id_value=${counter_id_value}
        ...                                                              expect_value=${expect_value}
        Append To List    ${counter_id_value_list}    ${counter_id_value}
        exit for loop if    ${status}==True
    END
    Set suite variable    ${status}
    run keyword if    "${status}"=="False"    fail    msg=check counter is fail
    [Return]    ${counter_id_value_list}
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=First_ASIB

Check Counter Value By PLMN Id Without Judge
    [Arguments]    ${cell_id}=1    ${PLMN}=46002    ${counter_ID}=M55145C00220    ${cell_or_gnb}=cell
    [Documentation]      this kw is used to Check Counter Value By PLMN Id Without Judge
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | cell_id | No | define cell id |
    ...    | PLMN | No | define the  PLMN, such as: 26203 |
    ...    | counter_ID | No | define the counter id |
    ...    | cell_or_gnb | No | define the counter is include in cell or gnb level |
    ...
    ...    | Return Value | Description |
    ...    | ${counter_values_list} | return the value list of counter |
    ...
    ...    Example
    ...    | Check Counter Value By PLMN Id Without Judge | cell_id=2 | PLMN=26203 | counter_ID=${pi} |
    ...    | ...                                          | cell_or_gnb=${cell_or_gnb} |
    ...
    ${MCC}    Get Substring    ${PLMN}    0    3
    ${MNC}    Get Substring    ${PLMN}    3    5
    Wait Until Keyword Succeeds    5m    1m    Connect to First_ASIB
    ssh.execute    gunzip /tmp/PM.BTS*.xml.gz    connection=First_ASIB
    Set test variable    ${PLMN_Path}    PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}</DN></MO><MO
    Set test variable    ${PLMN_cell_Path}    PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}</DN></MO><MO
    ${counter_info}    ssh.execute    cat /tmp/PM.BTS*.xml    connection=First_ASIB
    ${counter_ids_list_grep}    run keyword if    '${cell_or_gnb}' == 'cell'    get regexp matches    ${counter_info}
    ...    ${PLMN_cell_Path} dimension="MCCMNC"><DN>PLMN-PLMN/MCC-${MCC}/MNC-${MNC}.*?<${counter_ID}>(\\d+)</${counter_ID}>    0
    ...    ELSE    get regexp matches    ${counter_info}
    ...    ${PLMN_Path} dimension="MCCMNC"><DN>PLMN-PLMN/MCC-${MCC}/MNC-${MNC}.*?<${counter_ID}>(\\d+)</${counter_ID}>    0
    ${counter_ids_str_grep}    get from list    ${counter_ids_list_grep}    0
    ${counter_ids_list}    get regexp matches    ${counter_ids_str_grep}    <${counter_ID}>(\\d+)</${counter_ID}>    0
    Set Suite Variable    ${counter_ids_list}
    @{counter_values_list}    Create List
    FOR    ${counter_id_item}    IN    @{counter_ids_list}
        ${counter_id_list}    split string    ${counter_id_item}    <
        ${counter_value_item}    get from list    ${counter_id_list}    1
        ${counter_value_list}    split string    ${counter_value_item}    >
        ${counter_value}    get from list    ${counter_value_list}    1
        Append To List    ${counter_values_list}    ${counter_value}
    END
    [Return]    ${counter_values_list}
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=First_ASIB

Check counter value equal expect value by PLMN id
    [Arguments]    ${cell_id}=1    ${PLMN}=46002    ${counter_ID}=M55145C00223
    ...            ${expect_value}=1    ${cell_or_gnb}=cell
    [Documentation]      this kw is used to check counter value equal expect value by PLMN id
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | cell_id | No | define cell id |
    ...    | PLMN | No | define the  PLMN, such as: 26203 |
    ...    | counter_ID | No | define the counter id |
    ...    | expect_value | No | define expect value |
    ...    | cell_or_gnb | No | define the counter is include in cell or gnb level |
    ...
    ...    | Return Value | Description |
    ...    | ${counter_values_list} | return the value list of counter  |
    ...
    ...    Example
    ...    | Check counter value equal expect value by PLMN id | cell_id=2 | PLMN=26203 | counter_ID=${pi} |
    ...    | ...                                               | expect_value=${expect_value} |
    ...    | ...                                               | cell_or_gnb=${cell_or_gnb} |
    ...
    ${MCC}    Get Substring    ${PLMN}    0    3
    ${MNC}    Get Substring    ${PLMN}    3    5
    Wait Until Keyword Succeeds    5m    1m    Connect to First_ASIB
    ssh.execute    gunzip /tmp/PM.BTS*.xml.gz    connection=First_ASIB
    ${counter_info}    ssh.execute    cat /tmp/PM.BTS*.xml    connection=First_ASIB
    Set test variable    ${PLMN_Path}    PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}</DN></MO><MO
    Set test variable    ${PLMN_cell_Path}    PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}</DN></MO><MO
    ${counter_ids_list_grep}    run keyword if    '${cell_or_gnb}' == 'cell'    get regexp matches    ${counter_info}
    ...    ${PLMN_cell_Path} dimension="MCCMNC"><DN>PLMN-PLMN/MCC-${MCC}/MNC-${MNC}.*?<${counter_ID}>(\\d+)</${counter_ID}>    0
    ...    ELSE    get regexp matches    ${counter_info}
    ...    ${PLMN_Path} dimension="MCCMNC"><DN>PLMN-PLMN/MCC-${MCC}/MNC-${MNC}.*?<${counter_ID}>(\\d+)</${counter_ID}>    0
    ${counter_ids_str_grep}    get from list    ${counter_ids_list_grep}    0
    ${counter_ids_list}    get regexp matches    ${counter_ids_str_grep}    <${counter_ID}>(\\d+)</${counter_ID}>    0
    Set Suite Variable    ${counter_ids_list}
    @{counter_values_list}    Create List
    FOR    ${counter_id_item}    IN    @{counter_ids_list}
        ${counter_id_list}    split string  ${counter_id_item}    <
        ${counter_value_item}    get from list    ${counter_id_list}    1
        ${counter_value_list}    split string    ${counter_value_item}    >
        ${counter_value}    get from list    ${counter_value_list}    1
        Append To List    ${counter_values_list}    ${counter_value}
    END
    ${index}    set variable    ${0}
    ${number_of_counter}    get length    ${counter_values_list}
    should be true    ${number_of_counter} > 0
    FOR    ${value}    IN    @{counter_values_list}
        Exit For Loop If    ${value} == ${expect_value}
        ${index}    Evaluate    ${index} + ${1}
        run keyword if    ${index} == ${number_of_counter}    fail    check counter is failed
        Continue For Loop If    ${value} != ${expect_value}
    END
    [Return]    ${counter_values_list}

Check counter value equal expect value1
    [Arguments]    ${counter_ID}=M55145C00223    ${expect_value}=1
    [Documentation]    This kw is used to check counter value equal expect value1
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | counter_ID | No | define the counter id |
    ...    | expect_value | No | define expect value |
    ...
    ...    | Return Value | Description |
    ...    | ${counter_id_value_list} | return the value list of counter id  |
    ...
    ...    Example
    ...    | Check counter value equal expect value1 | counter_ID=${pi} | expect_value=${expect_value} |
    ...
    Wait Until Keyword Succeeds    5m    1m    Connect to First_ASIB
    ssh.execute    gunzip /tmp/PM.BTS*.xml.gz    connection=First_ASIB
    ${counter_info}    ssh.execute    cat /tmp/PM.BTS*.xml | grep ${counter_ID}    connection=First_ASIB
    ${counter_ids_list}    get regexp matches    ${counter_info}    <${counter_ID}>(\\d+)</${counter_ID}>    0
    Set Suite Variable    ${counter_ids_list}
    @{counter_values_list}    Create List
    FOR    ${counter_id_item}    IN    @{counter_ids_list}
        ${counter_id_list}    split string    ${counter_id_item}    <
        ${counter_value_item}    get from list    ${counter_id_list}    1
        ${counter_value_list}    split string    ${counter_value_item}    >
        ${counter_value}    get from list    ${counter_value_list}    1
        Append To List    ${counter_values_list}    ${counter_value}
    END
    @{counter_id_value_list}    Create List
    ${number_of_counter}    get length    ${counter_values_list}
    FOR    ${index}    IN RANGE    ${number_of_counter}
        ${counter_id_value}    Convert to number    ${counter_values_list[${index}]}
        Set suite variable    ${counter_id_value}
        ${status}    run keyword and return status    Compare counter equal expect value    counter_id_value=${counter_id_value}
        ...                                                                                 expect_value=${expect_value}
        Append To List    ${counter_id_value_list}    ${counter_id_value}
        exit for loop if    ${status}==True
    END
    Set suite variable    ${status}
    run keyword if    "${status}"=="False"    fail    msg=check counter is fail
    [Return]    ${counter_id_value_list}
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=First_ASIB

Check counter value equal expect value
    [Arguments]    ${counter_ID}    ${expect_value}
    [Timeout]    6 min
    [Documentation]    This kw is used to check counter value equal expect value
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | counter_ID | No | define the counter id |
    ...    | expect_value | No | define expect value |
    ...
    ...    | Return Value | Description |
    ...    | ${counter_values_list} | return the value list of counter  |
    ...
    ...    Example
    ...    | Check counter value equal expect value | counter_ID=${pi} | expect_value=${expect_value} |
    ...
    Wait Until Keyword Succeeds    5m    1m    Connect to First_ASIB
    ssh.execute    gunzip /tmp/PM.BTS*.xml.gz    connection=First_ASIB
    ${counter_info}    ssh.execute    cat /tmp/PM.BTS*.xml | grep ${counter_ID}    connection=First_ASIB
    ${counter_ids_list}    get regexp matches    ${counter_info}    <${counter_ID}>(\\d+)</${counter_ID}>    0
    Set Suite Variable    ${counter_ids_list}
    @{counter_values_list}    Create List
    FOR    ${counter_id_item}    IN    @{counter_ids_list}
        ${counter_id_list}    split string    ${counter_id_item}    <
        ${counter_value_item}    get from list    ${counter_id_list}    1
        ${counter_value_list}    split string    ${counter_value_item}    >
        ${counter_value}    get from list    ${counter_value_list}    1
        Append To List    ${counter_values_list}    ${counter_value}
    END
    ${index}    set variable    ${0}
    ${number_of_counter}    get length    ${counter_values_list}
    should be true    ${number_of_counter} > 0
    FOR    ${value}    IN    @{counter_values_list}
        Exit For Loop If    ${value} == ${expect_value}
        ${index}    Evaluate    ${index} + ${1}
        run keyword if    ${index} == ${number_of_counter}    fail    check counter is failed
        Continue For Loop If    ${value} != ${expect_value}
    END
    [Return]    ${counter_values_list}

Check counter value include zero
    [Arguments]    ${counter_ID}
    [Documentation]    This kw is used to check counter value include zero
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | counter_ID | No | define the counter id |
    ...
    ...    | Return Value | Description |
    ...    | ${counter_id_value_list} | return the value list of counter id |
    ...
    ...    Example
    ...    | Check counter value include zero | counter_ID=${pi} |
    ...
    Wait Until Keyword Succeeds    5m    1m    Connect to First_ASIB
    ssh.execute    gunzip /tmp/PM.BTS*.xml.gz    connection=First_ASIB
    ${counter_info}    ssh.execute    cat /tmp/PM.BTS*.xml | grep ${counter_ID}    connection=First_ASIB
    ${counter_ids_list}    get regexp matches    ${counter_info}    <${counter_ID}>(\\d+)</${counter_ID}>    0
    Set Suite Variable    ${counter_ids_list}
    @{counter_values_list}    Create List
    FOR    ${counter_id_item}    IN    @{counter_ids_list}
        ${counter_id_list}    split string    ${counter_id_item}    <
        ${counter_value_item}    get from list    ${counter_id_list}    1
        ${counter_value_list}    split string    ${counter_value_item}    >
        ${counter_value}    get from list    ${counter_value_list}    1
        Append To List    ${counter_values_list}    ${counter_value}
    END
    @{counter_id_value_list}    Create List
    ${number_of_counter}    get length    ${counter_values_list}
    FOR    ${index}    IN RANGE    ${number_of_counter}
        ${counter_id_value}    Convert to number    ${counter_values_list[${index}]}
        Set suite variable    ${counter_id_value}
        ${status}    run keyword and return status    Compare counter1    counter_id_value=${counter_id_value}
        Append To List    ${counter_id_value_list}    ${counter_id_value}
        exit for loop if    ${status}==True
    END
    run keyword if    "${status}"=="False"    fail    msg=check counter is fail
    [Return]    ${counter_id_value_list}
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=First_ASIB

Compare counter1
    [Arguments]    ${counter_id_value}
    [Documentation]    This kw is used to Compare counter1
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id_value | No | define the value of counter id |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Compare counter1 | counter_id_value=${1} |
    ...
    should be true    ${counter_id_value} >= 0

Wait For New Measurement Period
    [Documentation]    This kw is used for wait for new measurement period
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | No | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Wait For New Measurement Period |
    ...
    Log    Waiting For Measurement Period    console=${TRUE}
    Wait Until Keyword Succeeds    5m    1m    Time To Start Calls

Time To Start Calls
    [Documentation]    This kw is used for wait for start make call in new measurement period
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | No | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | start make call in new measurement period |
    ...
    ${timenow} =    Get Current Date
    ${minutes_now} =    Convert Date    ${timenow}    result_format=%M
    ${minutes_now} =    Convert To Number    ${minutes_now}
    ${time}    Evaluate    ${minutes_now} % 5
    Should Be True    ${time} == 0

Wait To Start reset site
    [Documentation]    This kw is used for wait for Wait To Start reset site
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | No | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Wait To Start reset site |
    ...
    ${timenow} =    Get Current Date
    ${minutes_now} =    Convert Date    ${timenow}    result_format=%M
    ${minutes_now} =    Convert To Number    ${minutes_now}
    ${time}    Evaluate    ${minutes_now} % 45
    Should Be True    ${time} == 0

Delete before PM counter file
    [Documentation]    This kw is used for Delete before PM counter file
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | No | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Delete before PM counter file |
    ...
    Connect to First_ASIB
    ssh.execute    rm -rf /tmp/PM*    connection=First_ASIB
    ssh.execute    rm -rf /tmp/RD*    connection=First_ASIB

Calculate totals in counter list
    [Arguments]    ${counter_list}
    [Documentation]    This kw is used for Calculate totals in counter list
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_list} | No | define the list of counter |
    ...
    ...    | Return Value | Description |
    ...    | ${sum} | return sum of counter |
    ...
    ...    Example
    ...    | Calculate totals in counter list | counter_list=${counter_list} |
    ...
    ${sum}    Set Variable    0
    FOR    ${item}    IN    @{counter_list}
        Convert To Integer    ${item}
        ${sum}    Evaluate    ${item} + ${sum}
    END
    [Return]    ${sum}

Get Counter context
    [Arguments]    ${dist_name}=PLMN-PLMN/MCC-262/MNC-03    ${timeout}=120
    [Documentation]    This kw is used for get counter info by webui
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ${dist_name} | No | define dist name, such as:PLMN-PLMN/MCC-262/MNC-03 |
    ...    | ${timeout} | No | define timeout of kw |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get Counter context | dist_name=PLMN-PLMN/MCC-262/MNC-03 | timeout=120 |
    ...
    coam.get_counters_info    dist_name=${dist_name}    timeout=${timeout}    connection=COAM

#-------------------nidd---------------------------------------------------------------------------------
Get NIDD Information
    [Arguments]    ${directory}=PM    ${log_path}=${TEST_LOG_DIRECTORY}
    ...            ${file_name}=nidd_counters
    [Documentation]    This kw is used for get NIDD information to log path
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | directory | Yes | counter directory |
    ...    | log_path | Yes |  counter  path that is Stored |
    ...    | file_name | Yes | counter file name |
    ...
    ...    | Return Value | Description |
    ...    | ${nidd_counter_ids} | return counter id of nidd |
    ...
    ...    Example
    ...    | ${nidd_counter_ids} | Get NIDD Information | directory=PM | log_path=${TEST_LOG_DIRECTORY} |
    ...    | ...                 | file_name=nidd_counters |
    ...
    ${nidd_counters_dir}=    get a directory    ${log_path}    ${directory}
    set test variable    ${nidd_counters_dir}
    ${nidd_dir}    set variable    /home/ute/testline_configuration/10_5_UTESRAN001T${MRBTS_ID}/
    ${nidd_file_name}   OperatingSystem.Join Path    ${nidd_dir}    ${file_name}.xlsx
    set test variable    ${nidd_file_name}
    OperatingSystem.File Should Exist    ${nidd_file_name}
    ${cmd}=    set variable    scp ${nidd_file_name} ${nidd_counters_dir}
    OperatingSystem.Run    ${cmd}
    ${nidd_counter_ids}    get_Column_Values    filepath=${nidd_file_name}
    ...                                         sheet=counters
    ...                                         column=${1}
    ${nidd_counter_ids}=    evaluate    list(sorted(set(${nidd_counter_ids})))
    ${nidd_counter_count}=    get length    ${nidd_counter_ids}
    log to console    There are ${nidd_counter_count} counters in NIDD.
    set test variable    ${nidd_counter_ids}
    [Return]    ${nidd_counter_ids}

Get Counters From Sbts
    [Documentation]    This kw is used for get Counters From Sbts
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | No | NA |
    ...
    ...    | Return Value | Description |
    ...    | ${counter_ids_list} | return the list of counter id |
    ...
    ...    Example
    ...    | ${counter_ids_list} | Get Counters From Sbts |
    ...
    log to console    Get Measurements And Counters
    Delete before PM counter file
    sleep    400s    reason=wait for generate counters
    Wait Until Keyword Succeeds    5m    1m    Connect to First_ASIB
    ssh.execute    gunzip /tmp/PM.BTS*.xml.gz    connection=First_ASIB
    ${counter_info}    ssh.execute    cat /tmp/PM.BTS*.xml    connection=First_ASIB
    ${counter_ids_list}    get regexp matches    ${counter_info}    M55[0-9]{0,3}C[0-9]{0,5}    0
    ${counter_ids_list}    Remove Duplicates    ${counter_ids_list}
    Set Test Variable    ${counter_ids_list}
    [Return]    ${counter_ids_list}
    [Teardown]    ssh.Disconnect    connection=First_ASIB

Counters Should Be Consistent With NIDD
    [Arguments]    ${current_counter_name}=current_all_counter_ids
    ...            ${diff_counter_name}=different_counter_ids
    [Documentation]    This kw is used for counters Should Be Consistent With NIDD
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | current_counter_name | Yes. | file name is to store the counter currently |
    ...    | diff_counter_name | Yes. |  file name is to store the different counter between nidd and sbts |
    ...
    ...    | Return Value | Description |
    ...    | ${diff} | return the diff between nidd and sbts |
    ...
    ...    Example
    ...    | ${diff} | Counters Should Be Consistent With NIDD | current_counter_name=current_all_counter_ids |
    ...    | ...     | diff_counter_name=different_counter_ids |
    ...
    Log To Console    Counters Should Be Consistent With NIDD
    ${current_counter_count}=    get length    ${counter_ids_list}
    ${current_all_counters_file}=    get a file    ${nidd_counters_dir}    ${current_counter_name}.xlsx
    write_counters_to_excel    ${current_all_counters_file}    ${counter_ids_list}
    ${nidd_counter_count}=    get length    ${nidd_counter_ids}
    ${diff}=    evaluate    list(sorted(set(${counter_ids_list})-set(${nidd_counter_ids})))
    Set Test Variable    ${diff}
    Run keyword and ignore error    lists_should_be_equal    ${counter_ids_list}    ${nidd_counter_ids}
    ...    There should be ${current_counter_count} counters, but ${diff} is not found in nidd counters list!
    ${different_counters_file}=    get a file    ${nidd_counters_dir}    ${diff_counter_name}.xlsx
    write_counters_to_excel    ${different_counters_file}    ${diff}
    Run Keyword If    '${diff}'!='[]'    FAIL    counters is not found in nidd counters list!
    [Return]    ${diff}

Get Pm Counters Of Period
    [Arguments]    ${counters}    ${start_time}    ${end_time}
    ...    ${connection}=COAM
    ...    ${timeout}=${60}
    ...    ${cell_id}=LNCEL-1
    [Documentation]    This kw is used for counters Should Be Consistent With NIDD
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | counters | Yes. | counters need to get from BTS |
    ...    | start_time | Yes. |  the bts you need to get counter value |
    ...    | end_time | Yes. | counters need to get from BTS |
    ...    | connection | Yes. |  the bts you need to get counter value |
    ...    | cell_id | Yes. | counters need to get from BTS |
    ...    | timeout | No. |  the bts you need to get counter value |
    ...    | Return Value | Description |
    ...    | ${counter dict} | {counter id : {time : value}}} |
    ...
    ...    Example
    ...    | ${counters} | Create List  |  M55110C00003 |
    ...    | ${end_time} | Get Current Date  | time_zone=UTC |
    ...    | ${start_time} |   Subtract Time From Date  |  ${end_time}  |  20 minutes |
    ...    | ${counter_value}  |  Get Pm Counters Of Period  |  counters=${counters} |
    ...    | ...  |  start_time=${start_time} |
    ...    | ...  |  end_time=${end_time} |
    ...    | ...  |  nr_btsid=11359 |
    ${convert_counters}    Catenate    SEPARATOR=,    @{counters}
    ${counter_value}    coam.get_pm_counters    counter_ids=${convert_counters}
    ...    connection=${connection}
    ...    timeout=${timeout}
    &{choosed_counter_value}    Create Dictionary
    FOR    ${counter}    IN     @{counters}
        ${cell_counter_values}    get_all_values_by_key    input=${counter_value}
        ...    key=${cell_id}
        ${values}    get_all_values_by_key    input=${cell_counter_values}[0]    key=${counter}
        Continue For Loop If    "${values}"=="${None}"
        ${choosed_value}    _Get Values Of Period    dict=${values}[0]
        ...    start_time=${start_time}    end_time=${end_time}
        Set To Dictionary    ${choosed_counter_value}
        ...    ${counter}=${choosed_value}
    END
    [Return]    ${choosed_counter_value}

_Get Counter From Value
    [Arguments]    ${dict}    ${counter}
    ${keys}    Get Dictionary Keys    ${dict}
    FOR    ${key}    IN    @{keys}
        ${has_counter}    Run Keyword And Return Status    Set Variable
        ...    ${dict}[${key}][${counter}]
        Return From Keyword If    ${has_counter}    ${dict}[${key}][${counter}]
    END
    [Return]    ${None}

_Get Values Of Period
    [Arguments]    ${dict}    ${start_time}=${None}    ${end_time}=${None}
    &{choosed_value}    Create Dictionary
    ${keys}    Get Dictionary Keys    ${dict}
    FOR    ${timestamp}    IN    @{keys}
        ${time}    Convert To Integer    ${timestamp}
        ${time}    Convert Date    ${time}
        Run Keyword If    "${time}">="${start_time}" and "${time}"<="${end_time}"
        ...    Set To Dictionary    ${choosed_value}
        ...    ${time}=${dict}[${timestamp}]
    END
    [Return]    ${choosed_value}

_Get Values Of Key By Recursion Dict
    [Arguments]    ${dict}    ${key}    ${max_deep}=${5}    ${current_deep}=${0}
    ${re_values}    Create Dictionary
    ${current_deep}    Set Variable    ${current_deep+${1}}
    ${has_key}    Run Keyword And Return Status    Set Variable
    ...    ${dict}[${key}]
    Return From Keyword If    ${has_key}    ${dict}[${key}]
    Run Keyword If    ${current_deep}>=${max_deep}
    ...    Fail    msg=can't get the ${key} when max_deep is ${max_deep}
    ${values}    Get Dictionary Values    ${dict}
    FOR    ${v}    IN    @{values}
        ${ret}    _Get Values Of Key By Recursion Dict    dict=${v}    key=${key}
        ...    current_deep=${current_deep}    max_deep=${max_deep}
        ${re_values}    _Update Dictionary   ${re_values}    ${ret}
    END
    [Return]    ${re_values}

_Update Dictionary
    [Arguments]    ${dict1}    ${dict2}
    ${keys}    Get Dictionary keys    ${dict2}
    FOR    ${key}    IN    @{keys}
        Set To Dictionary    ${dict1}    ${key}=${dict2}[${key}]
    END
    [Return]    ${dict1}