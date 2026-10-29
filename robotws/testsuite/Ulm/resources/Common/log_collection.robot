*** Settings ***

Documentation     Keywords related to log collection

Library    taf.transport.ssh                WITH NAME    ssh
Library    taf.config.testline.info         WITH NAME    info
Library    python/gnb.py                    WITH NAME    gnb_internal
Library    python/testline_information.py

Resource   connect.robot
Resource   gnb.robot

*** Variables ***
${P_console}         ${False}

*** Keywords ***
Save DU Logs From All GNBs
    [Documentation]
    ...     Get log files from all gNBs and save them in ``resultConfigsDir``.
    ...     If ``resultLogsDir`` is not defined the test suite log directory is used.
    ...
    ...     | resultLogsDir | directory to store the logs |
    ...
    [Arguments]    ${resultLogsDir}=${None}
    IF   '${resultLogsDir}'=='${None}'
        ${resultLogsDir}   testline.Get Test Suite Log Directory
    END

    FOR   ${gnb_id}   ${_}   IN ENUMERATE   @{tl.gnbs}
       Save DU Logs From GNB     gnb_id=${gnb_id}   resultLogsDir=${resultLogsDir}
    END


Save DU Logs From GNB
    [Documentation]
    ...     This KW downloads and stores the log files for the given ``gnb_id``.
    ...     If ``resultLogsDir`` is not defined the test suite log directory is used.
    ...
    ...     | gnb_id        | Id/Number of gNB |
    ...     | resultLogsDir | location to store the log files |
    ...
    [Arguments]    ${gnb_id}    ${resultLogsDir}=${None}
    IF   '${resultLogsDir}'=='${None}'
        ${resultLogsDir}   testline.Get Test Suite Log Directory
    END

    Log   Save DU Logs From gNB${gnb_id}   console=${P_console}
    FOR   ${du_id}   ${_}   IN ENUMERATE   @{tl.gnbs[${gnb_id}].dus}
       Save Common Unit Logs    gnb_id=${gnb_id}   du_id=${du_id}   resultLogsDir=${resultLogsDir}
    END
    Log   DU Logs from gNB${gnb_id} are saved!   console=${P_console}


Save Common Unit Logs
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    [Arguments]    ${gnb_id}    ${du_id}    ${resultLogsDir}
    FOR    ${comu_id}    ${_}   IN ENUMERATE   @{tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units}

        ${archive_name}   Set Variable   gNB${gnb_id}_DU${du_id}_ComU${comu_id}_common_unit_logs.tar.gz
        ${remote_path}    Set Variable   /tmp/${archive_name}
        ${ssh_alias}      Set Variable   ssh-gnb-${gnb_id}-${du_id}-${comu_id}

        connect.Connect To Node Common Unit    node_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
        ...    alias=${ssh_alias}

        Create Log Archive And Download Created File To Test PC
        ...   ssh_alias=${ssh_alias}
        ...   search_path=/ram
        ...   remote_path=${remote_path}
        ...   local_path=${resultLogsDir}/${archive_name}

        ssh.Disconnect   connection=${ssh_alias}

        # robot 3.1.2 doesn't support nested FOR loops, that's why we save capu logs here within that loops
        # with later versions with nested loops it should be moved to KW 'Save DU Logs From gNB'
        Save Capacity Unit Logs    gnb_id=${gnb_id}    du_id=${du_id}
        ...    comu_id=${comu_id}    resultLogsDir=${resultLogsDir}
    END


Save Capacity Unit Logs
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    [Arguments]    ${gnb_id}    ${du_id}    ${comu_id}    ${resultLogsDir}
    FOR    ${capu_id}    ${_}   IN ENUMERATE   @{tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].capacity_units}
        Save Logs From Each Slave Of Capacity Unit    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
        ...    capu_id=${capu_id}    resultLogsDir=${resultLogsDir}
    END


Save Logs From Each Slave Of Capacity Unit
    [Documentation]
    ...
    ...     *Scope* Internal
    ...
    [Arguments]    ${gnb_id}    ${du_id}    ${comu_id}    ${capu_id}    ${resultLogsDir}

    Log   Take logs only from slaves which are ready!
    ${comu_alias}   connect.Connect To Node Common Unit   node_id=${gnb_id}
    ...   du_id=${du_id}  comu_id=${comu_id}   force=${True}

    ${chk_adet_output}     gnb_internal.Get Airscale Board And Cpu Status    connection=${comu_alias}
    ${adet_slave_status}   gnb_internal.Get Cpu Status For   unit_type=FSP${capu_id+1}   chk_adet_output=${chk_adet_output}

    ssh.Disconnect   connection=${comu_alias}

    FOR   ${slave_index}   ${slave_status}   IN ENUMERATE   @{adet_slave_status}

        IF   '${slave_status[1]}'!='ready'
            CONTINUE
        ELSE
            Log   Get logs from capacity board slave ${slave_status[0]}
        END

        ${archive_name}   Set Variable   gNB${gnb_id}_DU${du_id}_ComU${comu_id}_CapU${capu_id}_Slave-${slave_status[0]}_capacity_unit_logs.tar.gz
        ${remote_path}    Set Variable   /tmp/${archive_name}
        ${ssh_alias}      Set Variable   ssh-gnb-${gnb_id}-${du_id}-${comu_id}-${capu_id}-${slave_index}

        connect.Connect To GNB Capacity Unit   gnb_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
        ...   capu_id=${capu_id}   slave=${slave_index}   alias=${ssh_alias}

        Create Log Archive And Download Created File To Test PC
        ...   ssh_alias=${ssh_alias}
        ...   search_path=/tmp
        ...   remote_path=${remote_path}
        ...   local_path=${resultLogsDir}/${archive_name}

        ssh.Disconnect   connection=${ssh_alias}
    END


Save DU Configs From All GNBs
    [Documentation]
    ...     Get config files from all gNBs and save them in ``resultConfigsDir``.
    ...     If ``resultConfigsDir`` is not defined the test suite config directory is used.
    ...
    ...     | resultConfigsDir | Folder for config files |
    ...
    [Arguments]    ${resultConfigsDir}=${None}

    IF   '${resultConfigsDir}'=='${None}'
        ${resultConfigsDir}   testline.Get Test Suite Config Directory
    END

    FOR   ${gnb_id}   ${_}   IN ENUMERATE   @{tl.gnbs}
       Save DU Configs From GNB   gnb_id=${gnb_id}   resultConfigsDir=${resultConfigsDir}
    END


Save DU Configs From GNB
    [Documentation]
    ...     This KW downloads and stores the swconfig.txt for the given ``gnb_id``.
    ...     If ``resultConfigsDir`` is not defined the test suite config directory is used.
    ...
    ...     | gnb_id | Id/Number of gNB |
    ...     | resultConfigsDir | location to store the config files |
    ...
    [Arguments]    ${gnb_id}    ${resultConfigsDir}=${None}
    IF   '${resultConfigsDir}'=='${None}'
        ${resultConfigsDir}   testline.Get Test Suite Config Directory
    END
    gnb.Get SCF From GNB   gnb_id=${gnb_id}   target_dir=${resultConfigsDir}

    FOR   ${du_id}   ${_}   IN ENUMERATE   @{tl.gnbs[${gnb_id}].dus}
       Save Common Unit Configs   gnb_id=${gnb_id}   du_id=${du_id}   resultConfigsDir=${resultConfigsDir}
    END
    Log   DU Configs from gNB${gnb_id} are saved!   console=${P_console}


Save Common Unit Configs
    [Documentation]
    ...     This KW downloads and stores the swconfig.txt for the given ``gnb_id``.
    ...     It is done for all connected system modules for the given ``du_id``.
    ...     Use wrapper KW `Save DU Configs From gNB` instead.
    ...
    ...     *Scope* Internal
    ...
    ...     | gnb_id | Id/Number of gNB |
    ...     | du_id  | Id/Number of gNB |
    ...     | resultConfigsDir | location to store the coonfig files |
    ...
    [Arguments]    ${gnb_id}    ${du_id}    ${resultConfigsDir}

    FOR   ${comu_id}   ${_}   IN ENUMERATE   @{tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units}
       connect.Connect To Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
       ...   alias=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
       ssh.Download File   remote_path=/ffs/run/swconfig.txt
       ...   local_path=${resultConfigsDir}/swconfig_gNB${gnb_id}_DU${du_id}_ComU${comu_id}.txt
       ...   connection=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
       ssh.Disconnect   connection=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
    END


Create Log Archive And Download Created File To Test PC
    [Documentation]
    ...     Searches in ``search_path`` and to store logs in a single archive ``remote_path``.
    ...     Download the created file to the local Test VM ``local_path``.
    ...
    ...     *Scope* Internal
    ...
    ...     | ssh_alias    | ssh connection alias to reach the board |
    ...     | search_path  | path where to start the file search |
    ...     | remote_path  | log archive file path |
    ...     | local_path   | path where to store the archive file on Test PC |
    ...
    [Arguments]    ${ssh_alias}   ${search_path}   ${remote_path}   ${local_path}

    ${command}   Catenate   SEPARATOR=|
    ...   find -L ${search_path} -type f \\( -name "*.log" -o -name "*.log.xz" \\) -exec readlink -f {} \\;
    ...   sort -u
    ...   tar -czvf ${remote_path} --ignore-failed-read -T - ; echo done

    ssh.Send Command
    ...   command=${command}
    ...   connection=${ssh_alias}

    ssh.Await Execution End   connection=${ssh_alias}

    ssh.Read Output           connection=${ssh_alias}

    ${archive exist}   ssh.File Exists   connection=${ssh_alias}
    ...   remote_path=${remote_path}

    IF   ${archive_exist}    ssh.Download File
    ...   remote_path=${remote_path}
    ...   local_path=${local_path}
    ...   connection=${ssh_alias}

    ssh.Send Command
    ...   command=rm ${remote_path}
    ...   connection=${ssh_alias}
