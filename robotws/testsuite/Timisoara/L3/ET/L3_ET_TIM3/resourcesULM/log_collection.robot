*** Settings ***

Documentation     Keywords related to log collection

Library    Collections
Library    taf.transport.ssh           WITH NAME    ssh
Library    taf.config.testline.info    WITH NAME    info
Library    python/gnb.py               WITH NAME    gnb_internal
Library    python/testline_information.py

Resource   connect.robot
Resource   gnb.robot

*** Variables ***
${P_console}         ${False}

*** Keywords ***
Save CU logs from all gNBs
    [Documentation]
    ...     Fetch CU logs from all defined gNBs and store it in ``resultLogsDir``.
    ...
    ...     *Note*  Only classical supported yet!
    ...
    ...     | resultLogsDir | Directory for logs (default Test Suite Log Dir) |
    ...
    [Arguments]    ${resultLogsDir}=${None}
    ${resultLogsDir}=    Run Keyword If    '${resultLogsDir}'=='${None}'    testline.Get test suite log directory
    ...    ELSE    Set Variable    ${resultLogsDir}
    ${gnb_num}=     Get length   ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnb_num}
        Save CU logs from gNB    gnb_id=${gnb_id}    resultLogsDir=${resultLogsDir}
    END


Save CU logs from gNB
    [Documentation]
    ...     Fetch CU logs from given ``gnb_id`` and store it in ``resultLogsDir``.
    ...
    ...     *Note*  Only classical supported yet!
    ...
    ...     | resultLogsDir | Directory for logs (default Test Suite Log Dir) |
    ...
    [Arguments]    ${gnb_id}=${0}    ${resultLogsDir}=${None}
    ${resultLogsDir}=    Run Keyword If    '${resultLogsDir}'=='${None}'    testline.Get test suite log directory
    ...    ELSE    Set Variable    ${resultLogsDir}
    Run Keyword If    '${tl_info.deployment_type(${gnb_id})}' == 'classical'
    ...    Save CU logs from classical gNB    gnb_id=${gnb_id}    resultLogsDir=${resultLogsDir}


Save CU configs from all gNBs
    [Documentation]
    ...     Get Config files from all gNBs and save them in `resultConfigsDir`.
    ...     If `resultConfigsDir` is not defined test suite config directory will be used.
    ...
    ...     *Note*  Only classical supported yet!
    ...
    ...     | resultConfigsDir | Folder for config files |
    ...
    [Arguments]    ${resultConfigsDir}=${None}
    ${resultConfigsDir}=    Run Keyword If    '${resultConfigsDir}'=='${None}'    testline.Get test suite config directory
    ...    ELSE    Set Variable    ${resultConfigsDir}
    ${gnb_num}=     Get length   ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnb_num}
        Save CU configs from gNB    gnb_id=${gnb_id}    resultConfigsDir=${resultConfigsDir}
    END


Save CU configs from gNB
    [Documentation]
    ...     Get Config files from specified gNB and save them in `resultConfigsDir`.
    ...     If `resultConfigsDir` is not defined test suite config directory will be used.
    ...
    ...     | resultConfigsDir | Folder for config files |
    ...
    [Arguments]    ${gnb_id}=${0}    ${resultConfigsDir}=${None}
    ${resultConfigsDir}=    Run Keyword If    '${resultConfigsDir}'=='${None}'    testline.Get test suite config directory
    ...    ELSE    Set Variable    ${resultConfigsDir}
    Run Keyword If    '${tl_info.deployment_type(${gnb_id})}' == 'classical'
    ...    Save CU configs from classical gNB    gnb_id=${gnb_id}    resultConfigsDir=${resultConfigsDir}
    gnb.Get SCF from gNB    gnb_id=${gnb_id}    target_dir=${resultConfigsDir}


Save CU logs from classical gNB
    [Documentation]
    ...
    ...     | gnb_id | Id/Number of gNB |
    ...     | resultLogsDir | location to store the config files |
    ...
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
    [Documentation]
    ...     This KW fetches the logs matching the given file pattern by ``log_files`` from
    ...     the ``container`` of the given ``gnb_id``. Prefer the useage of the wrapper
    ...     KW `Save CU logs from classical gNB`!
    ...
    ...     *Scope* Internal
    ...
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


Save CU Configs from classical gNB
    [Documentation]
    ...     This KW doesn't provide any functionality yet and shouldn't be used!
    ...
    ...     *Scope* Unknow
    ...
    ...     | gnb_id | Id/Number of gNB |
    ...     | resultConfigsDir | location to store the config files |
    ...
    [Arguments]    ${gnb_id}    ${resultConfigsDir}
    BuiltIn.Log    Save CU Configs from gNB${gnb_id}    console=${P_console}
    Wait for Connect to OAM    ${gnb_id}    oam_alias=gNB${gnb_id}_OAM
    BuiltIn.Log    ToDO
    Disconnect from OAM    ${gnb_id}    oam_alias=gNB${gnb_id}_OAM
    BuiltIn.Log    CU Configs from gNB${gnb_id} are saved!      console=${P_console}


Save DU logs from all gNBs
    [Documentation]
    ...     Get log files from all gNBs and save them in ``resultConfigsDir``.
    ...     If ``resultLogsDir`` is not defined the test suite log directory is used.
    ...
    ...     | resultLogsDir | directory to store the logs |
    ...
    [Arguments]    ${resultLogsDir}=${None}
    ${resultLogsDir}=    Run Keyword If    '${resultLogsDir}'=='${None}'    testline.Get test suite log directory
    ...    ELSE    Set Variable    ${resultLogsDir}
    ${gnb_num}=     Get length   ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnb_num}
        Save DU logs from gNB    gnb_id=${gnb_id}    resultLogsDir=${resultLogsDir}
    END


Save DU logs from gNB
    [Documentation]
    ...     This KW downloads and stores the log files for the given ``gnb_id``.
    ...     If ``resultLogsDir`` is not defined the test suite log directory is used.
    ...
    ...     | gnb_id        | Id/Number of gNB |
    ...     | resultLogsDir | location to store the log files |
    ...
    [Arguments]    ${gnb_id}    ${resultLogsDir}=${None}
    ${resultLogsDir}=    Run Keyword If    '${resultLogsDir}'=='${None}'    testline.Get test suite log directory
    ...    ELSE    Set Variable    ${resultLogsDir}
    ${du_num}=     Get length    ${tl.gnbs[${gnb_id}].dus}
    BuiltIn.Log    Save DU Logs from gNB${gnb_id}   console=${P_console}
    FOR    ${du_id}    IN RANGE    ${du_num}
        Save common unit logs    gnb_id=${gnb_id}    du_id=${du_id}    resultLogsDir=${resultLogsDir}
    END
    BuiltIn.Log    DU Logs from gNB${gnb_id} are saved!     console=${P_console}


Save common unit logs
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    [Arguments]    ${gnb_id}    ${du_id}    ${resultLogsDir}
    ${common_units_num}=     Get length    ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units}
    FOR    ${comu_id}    IN RANGE    ${common_units_num}
        connect.Connect to Node Common Unit    node_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
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
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
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
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    [Arguments]    ${gnb_id}    ${du_id}    ${comu_id}    ${resultLogsDir}
    ${capacity_units_num}=     Get length    ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].capacity_units}
    FOR    ${capu_id}    IN RANGE    ${capacity_units_num}
        Save logs from each slave of capacity unit    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
        ...    capu_id=${capu_id}    resultLogsDir=${resultLogsDir}
    END


Save logs from each slave of capacity unit
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    [Arguments]    ${gnb_id}    ${du_id}    ${comu_id}    ${capu_id}    ${resultLogsDir}
    @{slaves}=    Create list    a    b    loner

    # check if slave unit is ready !!
    ${comu_alias}=  connect.Connect to Node Common Unit   node_id=${gnb_id}   du_id=${du_id}  comu_id=${comu_id}
    ${chk_adet_output}=   ssh.execute   command=chk adet    connection=${comu_alias}   timeout=30s
    ${adet_slave_status}=      gnb_internal.Parse Slave CPU Ready    chk_adet_output=${chk_adet_output}

    # Attention: Naming of ['a', 'b', 'loner'] is only valid for ABIL!!
    FOR   ${slave_index}   ${slave}    IN ENUMERATE   @{slaves}
        ${slave_status}=    Get From Dictionary    ${adet_slave_status}   ${slave_index}
        Continue For Loop If     '${slave_status}'!='ready'

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
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
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
    [Documentation]
    ...     Get config files from all gNBs and save them in ``resultConfigsDir``.
    ...     If ``resultConfigsDir`` is not defined the test suite config directory is used.
    ...
    ...     | resultConfigsDir | Folder for config files |
    ...
    [Arguments]    ${resultConfigsDir}=${None}
    ${resultConfigsDir}=    Run Keyword If    '${resultConfigsDir}'=='${None}'    testline.Get test suite config directory
    ...    ELSE    Set Variable    ${resultConfigsDir}
    ${gnb_num}=     Get length   ${tl.gnbs}
    FOR    ${gnb_id}    IN RANGE    ${gnb_num}
        Save DU configs from gNB    gnb_id=${gnb_id}    resultConfigsDir=${resultConfigsDir}
    END


Save DU configs from gNB
    [Documentation]
    ...     This KW downloads and stores the swconfig.txt for the given ``gnb_id``.
    ...     If ``resultConfigsDir`` is not defined the test suite config directory is used.
    ...
    ...     | gnb_id | Id/Number of gNB |
    ...     | resultConfigsDir | location to store the config files |
    ...
    [Arguments]    ${gnb_id}    ${resultConfigsDir}=${None}
    ${resultConfigsDir}=    Run Keyword If    '${resultConfigsDir}'=='${None}'   testline.Get test suite config directory
    ...    ELSE    Set Variable    ${resultConfigsDir}
    ${du_num}=     Get length    ${tl.gnbs[${gnb_id}].dus}
    BuiltIn.Log    Save DU Configs from gNB${gnb_id}    console=${P_console}
    FOR    ${du_id}    IN RANGE    ${du_num}
        Save common unit configs    gnb_id=${gnb_id}    du_id=${du_id}    resultConfigsDir=${resultConfigsDir}
    END
    BuiltIn.Log    DU Configs from gNB${gnb_id} are saved!  console=${P_console}


Save common unit configs
    [Documentation]
    ...     This KW downloads and stores the swconfig.txt for the given ``gnb_id``.
    ...     It is done for all connected system modules for the given ``du_id``.
    ...     Use wrapper KW `Save DU configs from gNB` instead.
    ...
    ...     *Scope*
    ...
    ...     | gnb_id | Id/Number of gNB |
    ...     | du_id  | Id/Number of gNB |
    ...     | resultConfigsDir | location to store the coonfig files |
    ...     
    [Arguments]    ${gnb_id}    ${du_id}    ${resultConfigsDir}
    ${common_units_num}=     Get length    ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units}
    FOR    ${comu_id}    IN RANGE    ${common_units_num}
        connect.Connect to Node Common Unit    node_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
        ...    alias=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
        ssh.download_file    remote_path=/ffs/run/swconfig.txt
        ...    local_path=${resultConfigsDir}/gNB${gnb_id}_DU${du_id}_ComU${comu_id}_swconfig.txt
        ...    connection=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
        ssh.disconnect    connection=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
    END


Wait for Connect to OAM
    [Documentation]
    ...     The KW tries to establish an ssh connection for the given ``gnb_id``.
    ...     If the attempt fails it will be repeated all 5s until timeout of 5min.
    ...
    ...     | gnb_id    | Id/Number of gNB |
    ...     | oam_alias | alias used for ssh connection |
    ...
    [Arguments]    ${gnb_id}    ${oam_alias}=gNB${gnb_id}_OAM
    Wait until keyword succeeds    5 min    5 sec    connect.Connect to OAM
    ...    gnb_id=${gnb_id}    alias=${oam_alias}


Disconnect from OAM
    [Documentation]
    ...     Disconnects an existing ssh connection for the given ``gnb_id``.
    ...
    ...     | gnb_id    | Id/Number of gNB |
    ...     | oam_alias | alias used for ssh connection |
    ...
    [Arguments]    ${gnb_id}    ${oam_alias}=gNB${gnb_id}_OAM
    Run keyword and ignore error    ssh.disconnect    connection=${oam_alias}


Get containers on asik
    [Documentation]
    ...    This keyword is used to get the current containers on ASIK's master or slave XEON
    ...
    ...     *Scope* Internal
    ...
    ...     | connection | connection object or alias for existing ssh connection to system module |
    ...
    ...     *Returns*   list of active containers on system module
    ...
    [Arguments]    ${connection}
    ssh.send_command    command=lxc-ls --active    connection=${connection}
    ${output}=    ssh.read_output    connection=${connection}
    @{containers}=    Split String    ${output}    separator=\n
    Remove values from list    ${containers}    ${EMPTY}
    [Return]    @{containers}


Save IQ Capture
    [Documentation]
    ...    Copied from HZ common kw, this KW is used to generate IQ capture traces on BTS (Blind OR Suspicious capture)
    ...    Reference: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1104194745
    ...
    ...     | bbmod        | BBMOD e.g BBMOD_R-1(ABIO) |
    ...     | enable_capture_on_event | Set to true if you want to enable suspicious capture instead of blind capture |
    ...     | phy_cell_id  | Physical cell ID |
    ...     | nrcell_id    | NR-CELL ID |
    ...     | subcell_id   | Subcell ID |
    ...     | sfn_value    | SFN value is 0~1023 or 65535. Set 0~1023 means you want to start/stop capture the IQ from this specific SFN. |
    ...     | ..           | Set 65535 means IQ capture will start immediately |
    ...     | slot_value   | Can be 0~79 |
    ...     | target_dir   | Custom directory location where the IQ capture has to be stored. Default - Stored in Test case log directory |
    ...     | capture_mode | Capture Mode, Stop Mode : means IQ capture behavior will be stop at the specific Sfn/Slot (default); |
    ...     | ..           | Start Mode means IQ capture behavior will be started at the specific Sfn/Slot. |
    ...
    [Arguments]    ${bbmod}=BBMOD_R-1(ABIO)    ${enable_capture_on_event}=True    ${phy_cell_id}=${50}
    ...    ${nrcell_id}=${1}    ${subcell_id}=${0}    ${sfn_value}=65535    ${slot_value}=0     ${target_dir}=${None}
    ...    ${capture_mode}=Start a new scheduled capture
    ${target_dir}=    Run Keyword If    $target_dir is None    testline.Get Testcase Log Directory
    Remove Files    /home/ute/Downloads/L1IQData*
    ${ul}=    Create List    [PCI: ${phy_cell_id}]NRCELL_R-${nrcell_id}: Subcell ${subcell_id}
    ${dl}=    Create List    [PCI: ${phy_cell_id}]NRCELL_R-${nrcell_id}: Subcell ${subcell_id}
	Selenium Login With Version
	selenium_coam.configure_iq_capture
	...    bbmod=${bbmod}
	...    enable_capture_on_event=${enable_capture_on_event}
	...    ul_subcell_index_list=${ul}
	...    dl_subcell_index_list=${dl}
	selenium_coam.save_iq_capture
	...    bbmod=${bbmod}
	...    sfn_value=${sfn_value}
	...    slot_value=${slot_value}
	...    capture_mode=${capture_mode}
	Sleep    300s
	Copy Files    /home/ute/Downloads/L1IQData*    ${target_dir}
    [Teardown]  Run keywords    Selenium logout and close browser

