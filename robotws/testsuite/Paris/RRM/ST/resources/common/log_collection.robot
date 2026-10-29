*** Settings ***

Documentation     Keywords related to log collection
...               author: Vasileios Papoutsis
...               email: vasileios.papoutsis@nokia.com

Library    Collections
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.config.testline.info    WITH NAME    info

Resource    ./connect.robot
Resource    ./gnb.robot
Resource    ./enb.robot

*** Variables ***
${P_console}         ${False}

*** Keywords ***

Save configs from all eNBs
    [Documentation]    Author: Vasileios Papoutsis
    ...             Get Config files from all eNBs and save them in ${resultConfigsDir}
    ...
    ...             Collect:
    ...             - scf
    ...
    ...             :param resultConfigsDir: Folder for config files (default Testsuite config directory)
    [Arguments]    ${resultConfigsDir}=None
    ${resultConfigsDir}=    Run Keyword If    '${resultConfigsDir}'=='None'    testline.Get test suite config directory
    ...    ELSE    Set Variable    ${resultConfigsDir}
    ${enb_num}=     Get length   ${tl.enbs}
    FOR    ${enb_id}    IN RANGE    ${enb_num}
        Save configs from eNB    enb_id=${enb_id}    resultConfigsDir=${resultConfigsDir}
    END

Save configs from eNB
    [Documentation]    Author: Vasileios Papoutsis
    ...             Get Config files from specific eNB and save them in ${resultConfigsDir}
    ...
    ...             Collect:
    ...             - scf
    ...
    ...             :param resultConfigsDir: Folder for config files (default Testsuite config directory)
    [Arguments]    ${enb_id}=${0}    ${resultConfigsDir}=None
    ${resultConfigsDir}=    Run Keyword If    '${resultConfigsDir}'=='None'    testline.Get test suite config directory
    ...    ELSE    Set Variable    ${resultConfigsDir}
    BuiltIn.Log    Save Configs from eNB${enb_id}    console=${P_console}
    enb.Get SCF from eNB    enb_id=${enb_id}    resultDir=${resultConfigsDir}
    BuiltIn.Log    Configs from eNB${enb_id} are saved!    console=${P_console}


Save CU logs from all gNBs
    [Documentation]    Author: Vasileios Papoutsis
    ...
    ...             :param resultLogsDir: Directory for logs (default Test Suite Log Dir)
    [Arguments]    ${resultLogsDir}=None
    ${resultLogsDir}=    Run Keyword If    '${resultLogsDir}'=='None'    testline.Get test suite log directory
    ...    ELSE    Set Variable    ${resultLogsDir}
    ${gnb_num}=     Get length   ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnb_num}
        Save CU logs from gNB    gnb_id=${gnb_id}    resultLogsDir=${resultLogsDir}
    END

Save CU logs from gNB
    [Documentation]    Author: Vasileios Papoutsis
    ...
    ...             :param resultLogsDir: Directory for logs (default Test Suite Log Dir)
    [Arguments]    ${gnb_id}=${0}    ${resultLogsDir}=None
    ${resultLogsDir}=    Run Keyword If    '${resultLogsDir}'=='None'    testline.Get test suite log directory
    ...    ELSE    Set Variable    ${resultLogsDir}
    ${gnb_type}=    testline.Get gNB type   gnb_id=${gnb_id}
    ${oam_type}=    testline.Get OAM type   gnb_id=${gnb_id}
    Run keyword if    '${gnb_type}'=='cloud'
    ...    Run keyword if    '${oam_type}'=='megazone'    Save CU logs from cloud gNB    gnb_id=${gnb_id}
    ...    resultLogsDir=${resultLogsDir}
    Run keyword if    '${gnb_type}'=='classical'
    ...    Save CU logs from classical gNB    gnb_id=${gnb_id}    resultLogsDir=${resultLogsDir}


Save CU configs from all gNBs
    [Documentation]    Author: Vasileios Papoutsis
    ...             Get Config files from all gNBs and save them in ${resultConfigsDir}
    ...
    ...             :param resultConfigsDir: Folder for config files (default Testsuite config directory)
    [Arguments]    ${resultConfigsDir}=None
    ${resultConfigsDir}=    Run Keyword If    '${resultConfigsDir}'=='None'    testline.Get test suite config directory
    ...    ELSE    Set Variable    ${resultConfigsDir}
    ${gnb_num}=     Get length   ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnb_num}
        Save CU configs from gNB    gnb_id=${gnb_id}    resultConfigsDir=${resultConfigsDir}
    END

Save CU configs from gNB
    [Documentation]    Author: Vasileios Papoutsis
    ...             Get Config files from specified gNB and save them in ${resultConfigsDir}
    ...
    ...             :param resultConfigsDir: Folder for config files (default Testsuite config directory)
    [Arguments]    ${gnb_id}=${0}    ${resultConfigsDir}=None
    ${resultConfigsDir}=    Run Keyword If    '${resultConfigsDir}'=='None'    testline.Get test suite config directory
    ...    ELSE    Set Variable    ${resultConfigsDir}
    ${gnb_type}=    testline.Get gNB type   gnb_id=${gnb_id}
    ${oam_type}=    testline.Get OAM type   gnb_id=${gnb_id}
    Run keyword if    '${gnb_type}'=='cloud'
    ...    Run keyword if    '${oam_type}'=='megazone'    Save CU configs from cloud gNB    gnb_id=${gnb_id}
    ...    resultConfigsDir=${resultConfigsDir}
    Run keyword if    '${gnb_type}'=='classical'
    ...    Save CU configs from classical gNB    gnb_id=${gnb_id}    resultConfigsDir=${resultConfigsDir}
    gnb.Get SCF from gNB    gnb_id=${gnb_id}    target_dir=${resultConfigsDir}


Save CU logs from cloud gNB
    [Documentation]    Author: Vasileios Papoutsis
    [Arguments]    ${gnb_id}    ${resultLogsDir}
    BuiltIn.Log    Save CU Logs from cloud gNB${gnb_id}     console=${P_console}
    Wait for Connect to OAM    ${gnb_id}    oam_alias=gNB${gnb_id}_OAM
    ${cmdStr}=    Catenate
    ...    rm -f /tmp/startup_RACOAM_gNB${gnb_id}_OAM.tar.gz && cd /opt/nokia/SS_MzOam/cloud-racoam/logs &&
    ...    tar -cvzf /tmp/startup_RACOAM_gNB$${gnb_id}_OAM.tar.gz startup_RACOAM.log
    ssh.execute    command=${cmdStr}    connection=gNB${gnb_id}_OAM
    Run keyword and ignore error    ssh.download file    remote_path=startup_RACOAM_gNB${gnb_id}_OAM.tar.gz
    ...    local_path=${resultLogsDir}/startup_RACOAM_gNB${gnb_id}_OAM.tar.gz
    ...    connection=gNB${gnb_id}_OAM
    ${cmdStr}=    Catenate
    ...    rm -f /tmp/startup_DEFAULT_gNB${gnb_id}_OAM.tar.gz && cd /tmp &&
    ...    tar -cvzf /tmp/startup_DEFAULT_gNB${gnb_id}_OAM.tar.gz startup_DEFAULT.log
    ssh.execute    command=${cmdStr}    connection=gNB${gnb_id}_OAM
    Run keyword and ignore error    ssh.download file    remote_path=startup_DEFAULT_gNB${gnb_id}_OAM.tar.gz
    ...    local_path=${resultLogsDir}/startup_DEFAULT_gNB${gnb_id}_OAM.tar.gz
    ...    connection=gNB${gnb_id}_OAM
    ${cmdStr}=    Catenate
    ...    rm -f /tmp/startup_PMJS_gNB${gnb_id}_OAM.tar.gz && cd /opt/nokia/SS_MzOam/cloud-racoam/logs &&
    ...    tar -cvzf /tmp/startup_PMJS_gNB${gnb_id}_OAM.tar.gz startup_PMJS.log
    ssh.execute    command=${cmdStr}    connection=gNB${gnb_id}_OAM
    Run keyword and ignore error    ssh.download file
    ...    remote_path=/tmp/startup_PMJS_gNB${gnb_id}_OAM.tar.gz
    ...    local_path=${resultLogsDir}/startup_PMJS_gNB${gnb_id}_OAM.tar.gz    connection=gNB${gnb_id}_OAM
    ${cmdStr}=    Catenate
    ...    rm -f /tmp/journal_gNB${gnb_id}_OAM.* && sudo journalctl -b -o short-precise > /tmp/journal_gNB${gnb_id}_OAM.log &&
    ...    tar -cvzf /tmp/journal_gNB${gnb_id}_OAM.tar.gz -C /tmp journal_gNB${gnb_id}_OAM.log
    ssh.execute    command=${cmdStr}    connection=gNB${gnb_id}_OAM
    ssh.download file    remote_path=/tmp/journal_gNB${gnb_id}_OAM.tar.gz
    ...    local_path=${resultLogsDir}/journal_gNB${gnb_id}_OAM.tar.gz
    ...    connection=gNB${gnb_id}_OAM
    Save CU logs from VMs    ${gnb_id}    ${resultLogsDir}
    BuiltIn.Log    CU Logs from cloud gNB${gnb_id} are saved!   console=${P_console}
    Disconnect from OAM    ${gnb_id}    oam_alias=gNB${gnb_id}_OAM


Save CU logs from classical gNB
    [Arguments]    ${gnb_id}    ${resultLogsDir}
    Wait for Connect to OAM    gnb_id=${gnb_id}    oam_alias=gNB${gnb_id}_OAM
    @{containers}=    Get containers on asik    connection=gNB${gnb_id}_OAM
    BuiltIn.Log    Save CU Logs from classical gNB${gnb_id}     console=${P_console}
    FOR    ${container}    IN    @{containers}
        ssh.send_command    command=cd /tmp/node_${container}/tmp/; ls *.log    connection=gNB${gnb_id}_OAM
        ${output}=    ssh.read_output    connection=gNB${gnb_id}_OAM
        ${length}=    Get Length    ${output}
        Continue for loop if    ${length}==${0}
        @{log_files}=    Split String	   ${output}    separator=\n
        Remove values from list    ${log_files}    ${EMPTY}
        Save container logs    log_files=${log_files}    container=${container}
        ...    gnb_id=${gnb_id}    connection=gNB${gnb_id}_OAM    resultLogsDir=${resultLogsDir}
    END
    Disconnect from OAM    ${gnb_id}    oam_alias=gNB${gnb_id}_OAM
    BuiltIn.Log    CU Logs from classical gNB${gnb_id} are saved!   console=${P_console}


Save container logs
    [Documentation]    Author: Vasileios Papoutsis
    [Arguments]    ${log_files}    ${container}    ${gnb_id}    ${connection}    ${resultLogsDir}
    FOR    ${log}    IN    @{log_files}
        ${log_prefix}    ${log_postfix}=    Split String    ${log}    separator=.    max_split=1
        ${cmdStr}=    Catenate
        ...    cd /tmp/node_${container}/tmp/; rm -f *tar.gz;
        ...    tar -cvzf ${log_prefix}_gNB${gnb_id}_${container}.tar.gz ${log}
        ssh.execute    command=${cmdStr}    connection=${connection}
        ${remote_path}=    Set variable    /tmp/node_${container}/tmp/${log_prefix}_gNB${gnb_id}_${container}.tar.gz
        ${local_path}=    Set variable    ${resultLogsDir}/${log_prefix}_gNB${gnb_id}_${container}.tar.gz
        ssh.download_file    remote_path=${remote_path}
        ...    local_path=${local_path}
        ...    connection=${connection}
    END

Save CU logs from VMs
    [Documentation]    Author: Vasileios Papoutsis
    [Arguments]    ${gnb_id}    ${resultLogsDir}
    @{vmList}    create list    cpcl    cpif    cpnb    cpue    upue
    FOR    ${vmName}    IN    @{vmList}
        Run keyword and ignore error    Collect VM journal log    ${gnb_id}    ${resultLogsDir}    ${vmName}
        Run keyword and ignore error    Collect VM startup log    ${gnb_id}    ${resultLogsDir}    ${vmName}
    END

Collect VM journal log
    [Documentation]    Author: Vasileios Papoutsis
    [Arguments]    ${gnb_id}    ${resultLogsDir}    ${vmName}
    [Timeout]    3 minutes
    Wait until keyword succeeds    5 min    5 sec
    ...    connect.Connect to gNB VM    vm_name=${vmName}    gnb_id=${gnb_id}    alias=${vmName}
    ${cmdStr}=    Catenate
    ...    rm -f /tmp/journal_gNB${gnb_id}_${vmName}.* && sudo journalctl -b -o short-precise > /tmp/journal_gNB${gnb_id}_${vmName}.log &&
    ...    tar -cvzf /tmp/journal_gNB${gnb_id}_${vmName}.tar.gz -C /tmp journal_gNB${gnb_id}_${vmName}.log
    ssh.execute    command=${cmdStr}    connection=${vmName}
    ssh.download file    remote_path=/tmp/journal_gNB${gnb_id}_${vmName}.tar.gz
    ...    local_path=${resultLogsDir}/journal_gNB${gnb_id}_${vmName}.tar.gz
    ...    connection=${vmName}
    ssh.disconnect    connection=${vmName}


Collect VM startup log
    [Documentation]    Author: Vasileios Papoutsis
    [Arguments]    ${gnb_id}    ${resultLogsDir}    ${vmName}
    [Timeout]    3 minutes
    Wait until keyword succeeds    5 min    5 sec
    ...    connect.Connect to gNB VM    vm_name=${vmName}    gnb_id=${gnb_id}    alias=${vmName}
    ${cmdStr}=    Catenate
    ...    cd /tmp ; sudo rm -f gNB${gnb_id}_${vmName}_LINUX_startup.* &&
    ...    cd /tmp ; sudo cp LINUX_startup.log gNB${gnb_id}_${vmName}_LINUX_startup.log
    ...    && cd /tmp ; sudo tar -cvzf gNB${gnb_id}_${vmName}_LINUX_startup.tar.gz gNB${gnb_id}_${vmName}_LINUX_startup.log
    ssh.execute    command=${cmdStr}    connection=${vmName}
    ssh.download file    remote_path=/tmp/gNB${gnb_id}_${vmName}_LINUX_startup.tar.gz
    ...    local_path=${resultLogsDir}/gNB${gnb_id}_${vmName}_LINUX_startup.tar.gz
    ...    connection=${vmName}
    ${cmdStr}=    Catenate
    ...    cd /tmp ; sudo rm -f gNB${gnb_id}_${vmName}_startup_DEFAULT.* &&
    ...    cd /tmp ; sudo cp startup_DEFAULT.log gNB${gnb_id}_${vmName}_startup_DEFAULT.log &&
    ...    cd /tmp ; sudo tar -cvzf gNB${gnb_id}_${vmName}_startup_DEFAULT.tar.gz gNB${gnb_id}_${vmName}_startup_DEFAULT.log
    ssh.execute    command=${cmdStr}    connection=${vmName}
    ssh.download file    remote_path=/tmp/gNB${gnb_id}_${vmName}_startup_DEFAULT.tar.gz
    ...    local_path=${resultLogsDir}/gNB${gnb_id}_${vmName}_startup_DEFAULT.tar.gz
    ...    connection=${vmName}
    ssh.disconnect    connection=${vmName}


Save CU Configs from cloud gNB
    [Documentation]    Author: Vasileios Papoutsis
    [Arguments]    ${gnb_id}    ${resultConfigsDir}
    BuiltIn.Log    Save CU Configs from gNB${gnb_id}    console=${P_console}
    Wait for Connect to OAM    ${gnb_id}    oam_alias=gNB${gnb_id}_OAM
    BuiltIn.Log    Under construction!!!    console=${P_console}
    Disconnect from OAM    ${gnb_id}    oam_alias=gNB${gnb_id}_OAM
    BuiltIn.Log    CU Configs from gNB${gnb_id} are saved!  console=${P_console


Save CU Configs from classical gNB
    [Documentation]    Author: Vasileios Papoutsis
    [Arguments]    ${gnb_id}    ${resultConfigsDir}
    BuiltIn.Log    Save CU Configs from gNB${gnb_id}    console=${P_console}
    Wait for Connect to OAM    ${gnb_id}    oam_alias=gNB${gnb_id}_OAM
    BuiltIn.Log    ToDO
    Disconnect from OAM    ${gnb_id}    oam_alias=gNB${gnb_id}_OAM
    BuiltIn.Log    CU Configs from gNB${gnb_id} are saved!      console=${P_console}


Save DU logs from all gNBs
    [Documentation]    Author: Vasileios Papoutsis
    ...
    ...             :param resultLogsDir: Directory for logs (default Test Suite Log Dir)
    [Arguments]    ${resultLogsDir}=None
    ${resultLogsDir}=    Run Keyword If    '${resultLogsDir}'=='None'    testline.Get test suite log directory
    ...    ELSE    Set Variable    ${resultLogsDir}
    ${gnb_num}=     Get length   ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnb_num}
        Save DU logs from gNB    gnb_id=${gnb_id}    resultLogsDir=${resultLogsDir}
    END

Save DU logs from gNB
    [Documentation]    Author: Vasileios Papoutsis
    [Arguments]    ${gnb_id}    ${resultLogsDir}=None
    ${resultLogsDir}=    Run Keyword If    '${resultLogsDir}'=='None'    testline.Get test suite log directory
    ...    ELSE    Set Variable    ${resultLogsDir}
    ${du_num}=     Get length    ${tl.gnbs[${gnb_id}].dus}
    BuiltIn.Log    Save DU Logs from gNB${gnb_id}   console=${P_console}
    FOR    ${du_id}    IN RANGE    ${du_num}
        Save common unit logs    gnb_id=${gnb_id}    du_id=${du_id}    resultLogsDir=${resultLogsDir}
    END
    BuiltIn.Log    DU Logs from gNB${gnb_id} are saved!     console=${P_console}


Save common unit logs
    [Documentation]    Author: Vasileios Papoutsis
    [Arguments]    ${gnb_id}    ${du_id}    ${resultLogsDir}
    ${common_units_num}=     Get length    ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units}
    FOR    ${comu_id}    IN RANGE    ${common_units_num}
        connect.Connect to gNB Common Unit    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
        ...    alias=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
        ssh.send_command    command=cd /tmp/; ls *.log    connection=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
        ${output}=    ssh.read_output    connection=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
        ${length}=    Get Length    ${output}
        Run keyword if    ${length}!=${0}    Get logs from common unit    logs=${output}    gnb_id=${gnb_id}    du_id=${du_id}
        ...    comu_id=${comu_id}    connection=ssh-gnb-${gnb_id}-${du_id}-${comu_id}    resultLogsDir=${resultLogsDir}
        ssh.disconnect    connection=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
        Save capacity unit logs    gnb_id=${gnb_id}    du_id=${du_id}
        ...    comu_id=${comu_id}    resultLogsDir=${resultLogsDir}
    END

Get logs from common unit
    [Documentation]    Author: Vasileios Papoutsis
    [Arguments]    ${logs}    ${gnb_id}    ${du_id}    ${comu_id}    ${connection}    ${resultLogsDir}
    @{log_files}=    Split String	   ${logs}    separator=\n
    Remove values from list    ${log_files}    ${EMPTY}
    FOR    ${log}    IN    @{log_files}
        ${log_prefix}    ${log_postfix}=    Split String    ${log}    separator=.    max_split=1
        ${cmdStr}=    Catenate
        ...    cd /tmp/; rm -f *tar.gz;
        ...    tar -cvzf ${log_prefix}_gNB${gnb_id}_DU${du_id}_ComU${comu_id}.tar.gz ${log}
        ssh.execute    command=${cmdStr}    connection=${connection}
        ${remote_path}=    Set variable    /tmp/${log_prefix}_gNB${gnb_id}_DU${du_id}_ComU${comu_id}.tar.gz
        ${local_path}=    Set variable    ${resultLogsDir}/${log_prefix}_gNB${gnb_id}_DU${du_id}_ComU${comu_id}.tar.gz
        ssh.download_file    remote_path=${remote_path}
        ...    local_path=${local_path}
        ...    connection=${connection}
    END

Save capacity unit logs
    [Documentation]    Author: Vasileios Papoutsis
    [Arguments]    ${gnb_id}    ${du_id}    ${comu_id}    ${resultLogsDir}
    ${capacity_units_num}=     Get length    ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].capacity_units}
    FOR    ${capu_id}    IN RANGE    ${capacity_units_num}
        Save logs from each slave of capacity unit    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
        ...    capu_id=${capu_id}    resultLogsDir=${resultLogsDir}
    END

Save logs from each slave of capacity unit
    [Documentation]    Author: Vasileios Papoutsis
    [Arguments]    ${gnb_id}    ${du_id}    ${comu_id}    ${capu_id}    ${resultLogsDir}
    @{slaves}=    Create list    a    b    loner
    FOR    ${slave}    IN    @{slaves}
        connect.Connect to gNB Capacity Unit    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
        ...    capu_id=${capu_id}    slave=${slave}    alias=ssh-gnb-${gnb_id}-${du_id}-${comu_id}-${capu_id}-${slave}
        ssh.send_command    command=cd /tmp/; ls *.log    connection=ssh-gnb-${gnb_id}-${du_id}-${comu_id}-${capu_id}-${slave}
        ${output}=    ssh.read_output    connection=ssh-gnb-${gnb_id}-${du_id}-${comu_id}-${capu_id}-${slave}
        ${length}=    Get Length    ${output}
        Run keyword if    ${length}!=${0}    Get logs from capacity unit    logs=${output}    gnb_id=${gnb_id}    du_id=${du_id}    slave=${slave}
        ...    comu_id=${comu_id}    capu_id=${capu_id}    connection=ssh-gnb-${gnb_id}-${du_id}-${comu_id}-${capu_id}-${slave}
        ...    resultLogsDir=${resultLogsDir}
        ssh.disconnect    connection=ssh-gnb-${gnb_id}-${du_id}-${comu_id}-${capu_id}-${slave}
    END

Get logs from capacity unit
    [Documentation]    Author: Vasileios Papoutsis
    [Arguments]    ${logs}    ${gnb_id}    ${du_id}    ${comu_id}    ${capu_id}    ${slave}    ${connection}    ${resultLogsDir}
    @{log_files}=    Split String	   ${logs}    separator=\n
    Remove values from list    ${log_files}    ${EMPTY}
    FOR    ${log}    IN    @{log_files}
        ${log_prefix}    ${log_postfix}=    Split String    ${log}    separator=.    max_split=1
        ${cmdStr}=    Catenate
        ...    cd /tmp/; rm -f *tar.gz;
        ...    tar -cvzf ${log_prefix}_gNB${gnb_id}_DU${du_id}_ComU${comu_id}_CapU${comu_id}_Slave-${slave}.tar.gz ${log}
        ssh.execute    command=${cmdStr}    connection=${connection}
        ${remote_path}=    Set variable    /tmp/${log_prefix}_gNB${gnb_id}_DU${du_id}_ComU${comu_id}_CapU${comu_id}_Slave-${slave}.tar.gz
        ${local_path}=    Set variable    ${resultLogsDir}/${log_prefix}_gNB${gnb_id}_DU${du_id}_ComU${comu_id}_CapU${comu_id}_Slave-${slave}.tar.gz
        ssh.download_file    remote_path=${remote_path}
        ...    local_path=${local_path}
        ...    connection=${connection}
    END

Save DU configs from all gNBs
    [Documentation]    Author: Vasileios Papoutsis
    ...             Get Config files from all gNBs and save them in ${resultConfigsDir}
    ...
    ...             :param resultConfigsDir: Folder for config files (default Testsuite config directory)
    [Arguments]    ${resultConfigsDir}=None
    ${resultConfigsDir}=    Run Keyword If    '${resultConfigsDir}'=='None'    testline.Get test suite config directory
    ...    ELSE    Set Variable    ${resultConfigsDir}
    ${gnb_num}=     Get length   ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnb_num}
        Save DU configs from gNB    gnb_id=${gnb_id}    resultConfigsDir=${resultConfigsDir}
    END

Save DU configs from gNB
    [Documentation]    Author: Vasileios Papoutsis
    [Arguments]    ${gnb_id}    ${resultConfigsDir}=None
    ${resultConfigsDir}=    Run Keyword If    '${resultConfigsDir}'=='None'    testline.Get test suite config directory
    ...    ELSE    Set Variable    ${resultConfigsDir}
    ${du_num}=     Get length    ${tl.gnbs[${gnb_id}].dus}
    BuiltIn.Log    Save DU Configs from gNB${gnb_id}    console=${P_console}
    FOR    ${du_id}    IN RANGE    ${du_num}
        Save common unit configs    gnb_id=${gnb_id}    du_id=${du_id}    resultConfigsDir=${resultConfigsDir}
    END
    BuiltIn.Log    DU Configs from gNB${gnb_id} are saved!  console=${P_console}


Save common unit configs
    [Documentation]    Author: Vasileios Papoutsis
    [Arguments]    ${gnb_id}    ${du_id}    ${resultConfigsDir}
    ${common_units_num}=     Get length    ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units}
    FOR    ${comu_id}    IN RANGE    ${common_units_num}
        connect.Connect to gNB Common Unit    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
        ...    alias=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
        ssh.download_file    remote_path=/ffs/run/swconfig.txt
        ...    local_path=${resultConfigsDir}/gNB${gnb_id}_DU${du_id}_ComU${comu_id}_swconfig.txt
        ...    connection=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
        ssh.disconnect    connection=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
    END

Wait for Connect to OAM
    [Documentation]    Author: Vasileios Papoutsis
    [Arguments]    ${gnb_id}    ${oam_alias}=gNB${gnb_id}_OAM
    Wait until keyword succeeds    5 min    5 sec    connect.Connect to OAM
    ...    gnb_id=${gnb_id}    alias=${oam_alias}


Disconnect from OAM
    [Documentation]    Author: Vasileios Papoutsis
    [Arguments]    ${gnb_id}    ${oam_alias}=gNB${gnb_id}_OAM
    Run keyword and ignore error    ssh.disconnect    connection=${oam_alias}


Get containers on asik
    [Documentation]    Author: Vasileios Papoutsis
    ...
    ...    This keyword is used to get the current containers on ASIK's master or slave XEON
    ...
    [Arguments]    ${connection}
    ssh.send_command    command=lxc-ls --active    connection=${connection}
    ${output}=    ssh.read_output    connection=${connection}
    @{containers}=    Split String    ${output}    separator=\n
    Remove values from list    ${containers}    ${EMPTY}
    [Return]    @{containers}
