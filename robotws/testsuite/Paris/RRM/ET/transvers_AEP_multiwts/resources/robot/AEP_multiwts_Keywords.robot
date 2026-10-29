*** Settings ***
Documentation
...             :author/s:     francois.tourlonnias@nokia.com
...             :description:  First attempt to start AEP lua scripts

Library                   ../python/MultiWtsEmu.py                WITH NAME    multiwtsemu
Library                   taf.transport.ssh                       WITH NAME    ssh
Library                   ute_wtssim

Resource                  ../../../../../resources/SWENG/robot/Oam.robot
Resource                  ../../../../../resources/SWENG/robot/Restart.robot
Resource                  ../../../resources/robot/KeyWordMarket.robot


*** Variables ***
# Define variables here.
${somelua}                 sansa.lua

*** Keywords ***
# Define custom keywords here.

AEP_multiwtsemu_instance_creation
    [Arguments]            ${nbVMwts}=1
    [Documentation]        Creates necessary instances number of the AEP multiwts emulator.
    ...                    NOT YET USED DUE TO taf.wts.runner limitation
    Dated Log New Line     AEP_multiwtsemu_instance_creation => ${nbVMwts} wts

    # Create the instance of the multiwts emulator
    FOR    ${idx}   IN RANGE    0    ${nbVMwts + 1}
        Dated Log New Line    AEP_multiwtsemu_instance_creation for WTS${idx + 1}

        ${alias}=                       Evaluate    Connect.get_alias_by_index(${idx})    modules=Connect    # alias
        # ${egate_console}=               Connect.get_host    ${alias}    # host
        # ${egate_console}=               Evaluate    Connect.get_alias_by_index(${idx})    modules=Connect    # alias
        ${host}=                        Set Variable    ${tl.test_pcs[${idx}].default_ssh_connection_details.addr}
        ${egate_port}=                  ReadConfig.get_test_pctmp_attribute    ${tl.core[${idx}]}    egate_port
        ${edaemon_port}=                ReadConfig.get_test_pctmp_attribute    ${tl.core[${idx}]}    edaemon_port
        ${ssh_user}=                    Set Variable    ${tl.test_pcs[${idx}].default_ssh_connection_details.username}
        ${ssh_pass}=                    Set Variable    ${tl.test_pcs[${idx}].default_ssh_connection_details.password}

        Dated Log    alias=${alias}
        Dated Log    egate_console=${alias}
        Dated Log    host=${host}
        Dated Log    egate_port=${egate_port}
        Dated Log    edaemon_port=${edaemon_port}
        Dated Log    ssh_user=${ssh_user}

        # ${egate_console}=    Evaluate    tl.core[${idx}]
        egate_console = tl.core[${idx}].egate
        ${egate_console}    ReadConfig.get_test_pctmp_attribute    ${tl.core[${idx}]}    egate_console
        multiwtsemu.create_instance    ${alias}    ${egate_console}
        ...                            host=${host}
        ...                            egate_port=${egate_port}
        ...                            edaemon_port=${edaemon_port}
        ...                            ssh_user=${ssh_user}
        ...                            ssh_pass=${ssh_pass}

        Dated Log                      AEP_multiwtsemu_instance_creation for WTS${inst} done
    END


AEP_multiwtsemu_TL_Restart
    Debug Dated Log        AEP_multiwtsemu_Restart arg none
    Set Suite Variable     ${Verdict_TL_Restart}    NOTDONE
    Restart.Restart TL     #isOAMRebooted=TruAEP_multiwtsemu_OAM
    Set Suite Variable     ${Verdict_TL_Restart}    PASS

AEP_multiwtsemu_OAM
    OAM Reset SIte         ${GNB_DU.oam}
    OAM Wait Available     ${GNB_DU.oam}     400

AEP_multiwtsemu_WTS ConfigFile Dispatching
    [Arguments]            ${VM_luaPath}=${EMPTY}    ${tlcoreX}=${EMPTY}    ${core}=1    ${alias}=${EMPTY}
    [Documentation]        Dispatches the WTS configuration files to the specified wts.
    Dated Log New Line     AEP_multiwtsemu_WTS ConfigFile Dispatching VM_luaPath=${VM_luaPath} tlcoreX=${tlcoreX} alias=${alias}

    ${dir_path}=           ReadConfig.get_test_pctmp_attribute        ${tlcoreX}        dir_path
    ${local_dir}           Set Variable                               ${VM_luaPath}/WTS${core}_1AP
    Debug Dated Log        AEP_multiwtsemu_WTS ConfigFile Dispatching -->local_dir: ${local_dir}
    Debug Dated Log        AEP_multiwtsemu_WTS ConfigFile Dispatching -->dir_path: ${dir_path}

    @{files}=              OperatingSystem.List Files In Directory    ${local_dir}
    FOR                    ${src_file}     IN    @{files}
                           Dated Log        uploading ${src_file} ---> to remote ${dir_path}
                           ssh.Upload File  ${local_dir}/${src_file}    ${dir_path}/${src_file}   connection=${alias}
    END

    # ${content}             ssh.Execute    ls -lrt ${dir_path}/
    # ...                    connection=${alias}              #${tlcoreX.default_ssh_connection_details.addr}
    # ...                    timeout=30
    # Debug Dated Log        content: ${content}

AEP_multiwtsemu_LaunchWTS_Core
    [Arguments]            ${core}=1    ${VM_luaPath}=${EMPTY}    ${luafile}=${VM_luaPath}/WTS1_1AP/WTS1_config_TDD_6CC.lua
    ...                    ${host_object}=${"HOST_EPCSIM"}
    [Documentation]        Launches and configures a WTS core instance with the specified Lua file and host.
    ...                    Uploads configuration files and starts WTS processes for the given core index.
    ...                    Initializes the WTS emulator and applies the configuration using the provided Lua script.
    ...                    Waits for the simulator to reach the ACTIVE state before proceeding.
    ...                    Suitable for multi-instance WTS test setups and automation.
    Debug Dated Log        AEP_multiwtsemu_LaunchWTS_Core core:${core} VM_luaPath=${VM_luaPath} luafile:${luafile} host_object:${host_object}

    ${index}                                          Evaluate    ${core} - 1

    ${core_alias}                                     Connect to Core Vm_mwts  ${host_object.alias}    ${index}
    ${alias}                                          Set Variable    ${core_alias}
    # WTS Clear              #Stop WTSEmu, kill eDaemon and eGate processes, and purge WTS logs  toomuch already done on Restart.Restart TL

    # Get the core object from the tl.core list based on the index to avoid WTS Start processes mwts usage
    Debug Dated Log                                   alias: ${alias} tl_core_addr: ${tl.core[${index}].default_ssh_connection_details.addr}
    AEP_multiwtsemu_WTS ConfigFile Dispatching        VM_luaPath=${VM_luaPath}    tlcoreX=${tl.core[${index}]}    core=${core}    alias=${alias}

    # real wtsemu multi instance begining point adding new arg wtsemuinstance
    ${wtsemuinstance}                                 Set Variable    wtsemu_${core}
    WTS Start processes mwts                          alias=${alias}     tlcoreX=${tl.core[${index}]}    wtsemuinstance=${wtsemuinstance}

    Dated Log                                         AEP cfg file= ${luafile}
    Run Keyword    ${wtsemuinstance}.sim_cfg          file=${luafile}
    ...                                               entry=run_configuration(${howlong})
    Dated Log                                         AEP Waiting CHANGE STATE: ACTIVE - SimMode is ready now
    # Flush Egate Console Buffer mwts                   1    tlcoreX=${tl.core[${index}]}  # Flush the buffer to be sure to have all egate console log
    AEP_multiwtsemu_FlushEgateConsoleBuffer_mwts                 wtsemuinstance=${wtsemuinstance}
    Run Keyword    ${wtsemuinstance}.Read Wtsemu Output Until Re
    ...                                               expected=CHANGE STATE: ACTIVE - SimMode is ready now
    ...                                               timeout=400

    sleep                                             30s

AEP_multiwtsemu_Display_TL_Structure
    [Arguments]            ${nbVMwts}=1    ${alias_list}=${""}
    [Documentation]        Displays a detailed summary of the TL structure: tl.core, tl.test_pc, DicHOSTSwts.
    ...                    Iterates over APs if ${nbVMwts} > 1 to show their details.
    ...                    Lists aliases and objects from the dictionary. Useful for advanced debugging and configuration verification.
    Dated Log New Line     summary of TL ( D E B U G ) ============================

    Debug Dated Log    tl.core => ${tl.core}
    IF      ${nbVMwts} > 1
            FOR    ${idx}      IN RANGE    0      ${nbVMwts}
                 Tools.Dated Log New Line  \n=== tl.test_pcs[${idx}] => ${tl.test_pcs[${idx}]}
                 Debug Dated Log                 \n=== tl.core[${idx}] => ${tl.core[${idx}]}
            END
            Debug Dated Log    \n=== Alias liste ===${alias_list}===========================
    END
    # Ajout pour afficher le contenu de chaque élément de DicHOSTSwts
    FOR    ${key}    IN    @{Connect.DicHOSTSwts.keys()}
           ${value}=          Get From Dictionary    ${Connect.DicHOSTSwts}    ${key}
           Debug Dated Log    DEBUG: DicHOSTSwts[${key}] => ${value}
    END
    Dated Log New Line    End summary of TL ( D E B U G ) ============================

AEP_multiwtsemu_WTS_StartConfig
    [Arguments]            ${VM_luaPath}={EMPTY}    ${nbVMwts}=1    ${Connect.DicHOSTSwts}={EMPTY}
    [Documentation]        Configures the WTS environment based on the number of WTS instances and the provided dictionary of host objects.
    ...                    Sets up the WTS environment for each instance, ensuring proper connections and configurations.
    Dated Log New Line     AEP_multiwtsemu_WTS_StartConfig VM_luaPath=${VM_luaPath} nbVMwts=${nbVMwts} Connect.DicHOSTSwts=${Connect.DicHOSTSwts}

    Set Suite Variable                ${Verdict_WTS_Configuration}    NOTDONE

    FOR    ${idx}    IN RANGE    1    ${nbVMwts + 1}
        Dated Log New Line            AEP_LaunchWTS_4_WTS_${idx}
        # ${Connect.DicHOSTSwts}
        # ([('VMwts_1', <Hosts.Host object at 0x7f04fc997640>),
        #   ('VMwts_2', <Hosts.Host object at 0x7f04fc2dab90>),
        #   ('VMwts_3', <Hosts.Host object at 0x7f04fc2d86a0>)])

        ${alias_vmwts_var}            Evaluate    "VMwts_" + str(${idx})
        ${host_object}=               Evaluate    Connect.get_host("${alias_vmwts_var}")     modules=Connect
        Debug Dated Log               AEP_multiwtsemu_WTS_StartConfig: alias_vmwts_var: ${alias_vmwts_var}
        Debug Dated Log               AEP_multiwtsemu_WTS_StartConfig: host_object: ${host_object}

        # ${luafile}    Set Variable    ${CURDIR}/../script/sansa_WTS${idx}_FTS_2502.lua
        ${index}=                     Evaluate    ${idx} - 1
        ${dir_path}=                  ReadConfig.get_test_pctmp_attribute    ${tl.core[${index}]}    dir_path
        ${luafile}                    Set Variable    ${dir_path}/auto_sansa_WTS${idx}_FTS_2502.lua
        Dated Log                     AEP_multiwtsemu_WTS_StartConfig luafile => ${luafile}
        AEP_multiwtsemu_LaunchWTS_Core
        ...                           core=${idx}    VM_luaPath=${VM_luaPath}
        ...                           luafile=${luafile}    host_object=${host_object}
    END
    Set Suite Variable                ${Verdict_WTS_Configuration}    PASS

AEP_multiwtsemu_Cell_Setup_Check
    [Arguments]            ${nbVMwts}=1
    [Documentation]        Checks the cell setup on all WTS instances.
    ...                    Iterates through each WTS instance, checking the cell setup and ensuring SIBs are correctly configured.
    Dated Log New Line     AEP_multiwtsemu_Cell_Setup_Check nbVMwts=${nbVMwts}

    FOR    ${idx}                       IN RANGE    1    ${nbVMwts + 1}

        ${index}=                       Evaluate    ${idx} - 1
        ${dir_path}=                    ReadConfig.get_test_pctmp_attribute    ${tl.core[${index}]}    dir_path
        ${tlcoreX}=                     Set Variable    ${tl.core[${index}]}
        ${telnet_egate_addr}=           Set Variable    ${tlcoreX.default_ssh_connection_details.addr}
        ${alias}=                       Connect.get_alias_by_index    ${index}
        Debug Dated Log                 Alias is ${alias}
        ${egate_port}=                  ReadConfig.Get Test Pctmp Attribute    ${tlcoreX}    egate_port

        Dated Log                       AEP Waiting MIB-SIB on WTS${idx}

        ${wtsemuinstance}               Set Variable    wtsemu_${idx}
        IF         ${idx} == 1
                                        Dated Log           AEP Waiting Cell Setup Check Script Completion CellSetup(1,6)
                                        Run Keyword         ${wtsemuinstance}.script
                                        ...                 file=${dir_path}/multi_ue_sa_script_new.lua entry=check_CellSetup(1,6)
                                        # robot_extension.Run Keyword And Warn On Failure    Run Keyword    ${wtsemuinstance}.script_status
                                        # robot_extension.Run Keyword And Warn On Failure    Run Keyword    ${wtsemuinstance}.script_stop
                                        # AEP_multiwtsemu_FlushEgateConsoleBuffer_mwts    wtsemuinstance=${wtsemuinstance}

                                        FOR    ${cid}  IN RANGE    1    7
                                             Dated Log      AEP Waiting Cell Setup Check Script Completion CellSetup(${cid})
                                             Run Keyword    ${wtsemuinstance}.Read Wtsemu Output Until Re
                                             ...            expected=Cell Setup for${cid}: Cell Setup Found    timeout=10
                                        END
        ELSE IF    ${idx} == 2
                                        Dated Log           AEP Waiting Cell Setup Check Script Completion CellSetup(7,12)
                                        Run Keyword         ${wtsemuinstance}.script
                                        ...                 file=${dir_path}/multi_ue_sa_script_new.lua entry=check_CellSetup(7,12)
                                        # robot_extension.Run Keyword And Warn On Failure    Run Keyword    ${wtsemuinstance}.script_status
                                        # robot_extension.Run Keyword And Warn On Failure    Run Keyword    ${wtsemuinstance}.script_stop
                                        # AEP_multiwtsemu_FlushEgateConsoleBuffer_mwts    wtsemuinstance=${wtsemuinstance}

                                        FOR    ${cid}  IN RANGE    7    13
                                             Dated Log      AEP Waiting Cell Setup Check Script Completion CellSetup(${cid})
                                             Run Keyword    ${wtsemuinstance}.Read Wtsemu Output Until Re
                                             ...            expected=Cell Setup for${cid}: Cell Setup Found    timeout=10
                                        END
        ELSE IF    ${idx} == 3
                                        Dated Log           AEP Waiting Cell Setup Check Script Completion CellSetup(13,18)
                                        Run Keyword         ${wtsemuinstance}.script
                                        ...                 file=${dir_path}/multi_ue_sa_script_new.lua entry=check_CellSetup(13,18)
                                        # robot_extension.Run Keyword And Warn On Failure    Run Keyword    ${wtsemuinstance}.script_status
                                        # robot_extension.Run Keyword And Warn On Failure    Run Keyword    ${wtsemuinstance}.script_stop
                                        # AEP_multiwtsemu_FlushEgateConsoleBuffer_mwts    wtsemuinstance=${wtsemuinstance}

                                        FOR    ${cid}  IN RANGE    13    19
                                             Dated Log      AEP Waiting Cell Setup Check Script Completion CellSetup(${cid})
                                             Run Keyword    ${wtsemuinstance}.Read Wtsemu Output Until Re
                                             ...            expected=Cell Setup for${cid}: Cell Setup Found    timeout=10
                                        END
        END
        Dated Log                     AEP Cell Setup Check Script Completed for WTS${idx}
    END

AEP_multiwtsemu_L3_Call_6Cells_100UEs_mbps_10_10_NxnbVMwts_Per_WTS
    [Arguments]            ${wtstarget}=1    ${howlong}=3600
    [Documentation]        Initiates L3 calls on 6 cells with 100 UEs, each with a data rate of 10 Mbps.
    ...                    Configures the WTS environment for the specified number of WTS instances.
    Dated Log New Line
    ...      AEP_multiwtsemu_L3_Call_6Cells_100UEs_mbps_10_10_NxnbVMwts_Per_WTS wtstarget=${wtstarget} howlong=${howlong}

    Dated Log                       AEP L3 Call ongoing

        ${idx}                      Set Variable    ${wtstarget}
        Dated Log New Line          AEP_multiwtsemu_L3_Call_6Cells_100UEs_mbps_10_10_NxnbVMwts for WTS${idx}
        ${index}=                   Evaluate        ${idx} - 1
        ${dir_path}=                ReadConfig.get_test_pctmp_attribute    ${tl.core[${index}]}    dir_path
        ${tlcoreX}=                 Set Variable    ${tl.core[${index}]}
        ${telnet_egate_addr}=       Set Variable    ${tlcoreX.default_ssh_connection_details.addr}
        ${egate_port}=              ReadConfig.Get Test Pctmp Attribute    ${tlcoreX}    egate_port
        ${alias}=                   Connect.get_alias_by_index    ${index}

        ${wtsemuinstance}           Set Variable    wtsemu_${idx}
        Run Keyword                 ${wtsemuinstance}.script
        ...                         file=${dir_path}/auto_sansa_WTS${idx}_FTS_2502.lua entry=launch_multi_l3_calls(mbps,10,10,both,${howlong})
        sleep                       60s    # Wait for the script to start
        Run Keyword                 ${wtsemuinstance}.script_status

AEP_multiwtsemu_L3_Call_6Cells_100UEs_mbps_10_10_NxnbVMwts
    [Arguments]            ${nbVMwts}=1    ${howlong}=3600
    [Documentation]        Initiates L3 calls on 6 cells with 100 UEs, each with a data rate of 10 Mbps.
    ...                    Configures the WTS environment for the specified number of WTS instances.
    Dated Log New Line
    ...      AEP_multiwtsemu_L3_Call_6Cells_100UEs_mbps_10_10_NxnbVMwts nbVMwts=${nbVMwts} howlong=${howlong}

    Dated Log                       AEP L3 Call ongoing

    FOR    ${idx}    IN RANGE       1    ${nbVMwts + 1}
        Dated Log New Line          AEP_multiwtsemu_L3_Call_6Cells_100UEs_mbps_10_10_NxnbVMwts for WTS${idx}
        ${index}=                   Evaluate        ${idx} - 1
        ${dir_path}=                ReadConfig.get_test_pctmp_attribute    ${tl.core[${index}]}    dir_path
        ${tlcoreX}=                 Set Variable    ${tl.core[${index}]}
        ${telnet_egate_addr}=       Set Variable    ${tlcoreX.default_ssh_connection_details.addr}
        ${egate_port}=              ReadConfig.Get Test Pctmp Attribute    ${tlcoreX}    egate_port
        ${alias}=                   Connect.get_alias_by_index    ${index}

        ${wtsemuinstance}           Set Variable    wtsemu_${idx}
        Run Keyword                 ${wtsemuinstance}.script
        ...                         file=${dir_path}/auto_sansa_WTS${idx}_FTS_2502.lua entry=launch_multi_l3_calls(mbps,10,10,both,${howlong})
        sleep                       60s    # Wait for the script to start
        Run Keyword                 ${wtsemuinstance}.script_status
    END

AEP_multiwtsemu_L3_Call_6Cells_100UEs_Control_Per_WTS
    [Arguments]            ${wtstarget}=1    ${timeout}=300
    [Documentation]        Checks the progress of L3 calls on 6 cells with 100 UEs per WTS instance.
    ...                    It focus only on WTS instances targeted by arg. It monitors the activation of UEs and traffic.
    ...                    Waits until all UEs are active or the timeout is reached, logging the status at each interval.
    ...                    Arguments:
    ...                    - nbVMwts: Number of WTS instances to check (default: 1)
    ...                    Example:
    ...                    | AEP_multiwtsemu_L3_Call_6Cells_100UEs_Control | nbVMwts=3
    Dated Log New Line     AEP_multiwtsemu_L3_Call_6Cells_100UEs_mbps_10_10_NxnbVMwts nbVMwts=${nbVMwts}

    Dated Log                       AEP L3 Call ongoing C H E C K . CONFIGURED_ACTIVE

        ${idx}                      Set Variable    ${wtstarget}
        Dated Log New Line          AEP_multiwtsemu_L3_Call_6Cells_100UEs_mbps_10_10_NxnbVMwts for WTS${idx}
        ${index}=                   Evaluate        ${idx} - 1
        ${dir_path}=                ReadConfig.get_test_pctmp_attribute    ${tl.core[${index}]}    dir_path
        ${tlcoreX}=                 Set Variable    ${tl.core[${index}]}
        ${telnet_egate_addr}=       Set Variable    ${tlcoreX.default_ssh_connection_details.addr}
        ${alias}=                   Connect.get_alias_by_index    ${index}

        ${egate_port}=              ReadConfig.Get Test Pctmp Attribute    ${tlcoreX}    egate_port

        ${interval}=                Set Variable    30      # Interval between each check in seconds
        ${elapsed}=                 Set Variable    0       # Elapsed time initialized to 0

        Dated Log New Line       AEP Checking 100 L3 Calls + traffic on 6 cells <= ${timeout} seconds using re:${CONFIGURED_ACTIVE_REGEX}
        ${verification_count}    Set Variable    0
        WHILE    ${elapsed} < ${timeout}
            Dated Log New Line          Verification of Configured and Active values (attempt after ${elapsed} seconds)
            Sleep                       ${interval}    # Wait 30 seconds before the next attempt
            ${wtsemuinstance}           Set Variable    wtsemu_${idx}
            Run Keyword                 ${wtsemuinstance}.ue_summary
            # Flush Egate Console Buffer   # Flush the buffer to be sure to have all egate console log

            # ${status}    Run Keyword And Return Status    wtsemu.Read Wtsemu Output Until Re
            # ...                                            expected=${CONFIGURED_ACTIVE_REGEX}
            # ...                                            timeout=10
            ${status}    ${output}      Run Keyword And Ignore Error    Run Keyword    ${wtsemuinstance}.Read Wtsemu Output Until Re
            ...                                                                         expected=${CONFIGURED_ACTIVE_REGEX}
            ...                                                                         timeout=10
            Dated Log          check on ${wtsemuinstance} ue_summary number ${verification_count} after ${elapsed} / ${timeout} seconds
            Debug Dated Log             D E B U G expected...:>${CONFIGURED_ACTIVE_REGEX}<
            Debug Dated Log             D E B U G status.....:${status}
            Debug Dated Log             D E B U G output.....:${output}
            Run Keyword If              '${status}' == 'PASS'    Exit For Loop
            Dated Log                   all ue are not yet Active on traffic, continuing the loop

            ${elapsed}=                 Evaluate       ${elapsed} + ${interval}
            ${verification_count}=      Evaluate       ${verification_count} + 1
        END

        # Final verification if the condition has not been satisfied
        Run Keyword If    '${elapsed}' >= '${timeout}'    Fail    all Configured UE are not yet Active after ${timeout} seconds.


AEP_multiwtsemu_L3_Call_6Cells_100UEs_Control
    [Arguments]            ${nbVMwts}=1    ${timeout}=300
    [Documentation]        Checks the progress of L3 calls on 6 cells with 100 UEs per WTS instance.
    ...                    Iterates through all configured WTS instances and monitors the activation of UEs and traffic.
    ...                    Waits until all UEs are active or the timeout is reached, logging the status at each interval.
    ...                    Arguments:
    ...                    - nbVMwts: Number of WTS instances to check (default: 1)
    ...                    Example:
    ...                    | AEP_multiwtsemu_L3_Call_6Cells_100UEs_Control | nbVMwts=3
    Dated Log New Line     AEP_multiwtsemu_L3_Call_6Cells_100UEs_mbps_10_10_NxnbVMwts nbVMwts=${nbVMwts}

    Dated Log                       AEP L3 Call ongoing C H E C K . CONFIGURED_ACTIVE

        FOR    ${idx}    IN RANGE       1    ${nbVMwts + 1}
        Dated Log New Line          AEP_multiwtsemu_L3_Call_6Cells_100UEs_mbps_10_10_NxnbVMwts for WTS${idx}
        ${index}=                   Evaluate        ${idx} - 1
        ${dir_path}=                ReadConfig.get_test_pctmp_attribute    ${tl.core[${index}]}    dir_path
        ${tlcoreX}=                 Set Variable    ${tl.core[${index}]}
        ${telnet_egate_addr}=       Set Variable    ${tlcoreX.default_ssh_connection_details.addr}
        ${alias}=                   Connect.get_alias_by_index    ${index}

        ${egate_port}=              ReadConfig.Get Test Pctmp Attribute    ${tlcoreX}    egate_port

        ${timeout}=                 Set Variable    1800    # Total maximum time in seconds (30 minutes)
        ${interval}=                Set Variable    60      # Interval between each check in seconds
        ${elapsed}=                 Set Variable    0       # Elapsed time initialized to 0

        Dated Log New Line       AEP Checking 100 L3 Calls + traffic on 6 cells <= ${timeout} seconds using re:${CONFIGURED_ACTIVE_REGEX}
        ${verification_count}    Set Variable    0
        WHILE    ${elapsed} < ${timeout}
            Dated Log New Line          Verification of Configured and Active values (attempt after ${elapsed} seconds)
            Sleep                       ${interval}    # Wait 30 seconds before the next attempt
            ${wtsemuinstance}           Set Variable    wtsemu_${idx}
            Run Keyword                 ${wtsemuinstance}.ue_summary
            # Flush Egate Console Buffer   # Flush the buffer to be sure to have all egate console log

            # ${status}    Run Keyword And Return Status    wtsemu.Read Wtsemu Output Until Re
            # ...                                            expected=${CONFIGURED_ACTIVE_REGEX}
            # ...                                            timeout=10
            ${status}    ${output}      Run Keyword And Ignore Error    Run Keyword    ${wtsemuinstance}.Read Wtsemu Output Until Re
            ...                                                                         expected=${CONFIGURED_ACTIVE_REGEX}
            ...                                                                         timeout=10
            Dated Log          check on ${wtsemuinstance} ue_summary number ${verification_count} after ${elapsed} / ${timeout} seconds
            Debug Dated Log             D E B U G expected...:>${CONFIGURED_ACTIVE_REGEX}<
            Debug Dated Log             D E B U G status.....:${status}
            Debug Dated Log             D E B U G output.....:${output}
            Run Keyword If              '${status}' == 'PASS'    Exit For Loop
            Dated Log                   all ue are not yet Active on traffic, continuing the loop

            ${elapsed}=                 Evaluate       ${elapsed} + ${interval}
            ${verification_count}=      Evaluate       ${verification_count} + 1
        END

        # Final verification if the condition has not been satisfied
        Run Keyword If    '${elapsed}' >= '${timeout}'    Fail    all Configured UE are not yet Active after ${timeout} seconds.
    END

AEP_multiwtsemu_ResetEgateConsoleBuffer_mwts    # Flush the buffer to be sure to have all egate console log
    [Arguments]            ${wtsemuinstance}=wtsemu_1
    [Documentation]        Sends a command to the good egate console.
    Dated Log New Line     AEP_multiwtsemu_ResetEgateConsoleBuffer_mwts on wtsemuinstance=${wtsemuinstance}

    Run Keyword            ${wtsemuinstance}.script       file=${CURDIR}/WtsEmuReset.sce
    Run Keyword            ${wtsemuinstance}.script_status
    Run Keyword            ${wtsemuinstance}.script_stop

AEP_multiwtsemu_FlushEgateConsoleBuffer_mwts    # Flush the buffer to be sure to have all egate console log
    [Arguments]            ${wtsemuinstance}=wtsemu_1
    [Documentation]        Sends a Flush command to the good egate console.
    Dated Log New Line     AEP_multiwtsemu_FlushEgateConsoleBuffer_mwts on wtsemuinstance=${wtsemuinstance}

    Dated Log              *** Flush done on ${wtsemuinstance} ***
    # following script is used due to sim_log_set flush not working on taf.wts.runner interface ***
    Run Keyword            ${wtsemuinstance}.script       file=/opt/wts/latest/WtsEmuFlush.sce


AEP_multiwtsemu_Egate Console Cmd    # Flush the buffer to be sure to have all egate console log
    [Arguments]            ${cmd}=sim_log_set flush    ${PostEgateCmdExec_timer}=1s
    ...                    ${egate_port}=${tl.core.egate_port}
    ...                    ${host_ip}=${tl.core.default_ssh_connection_details.addr}
    ...                    ${tool_dir}=${tl.core.dir_path}
    [Documentation]        Sends a command to the egate console and waits for a specified time.
    ...                    This keyword use the ute_wtssim library to setup the egate console, execute the command, and then teardown the console.
    Dated Log New Line     AEP_multiwtsemu_Egate Console Cmd cmd=${cmd} PostEgateCmdExec_timer=${PostEgateCmdExec_timer} host_ip=${host_ip}
    ...                    egate_port=${egate_port} tool_dir=${tool_dir}

    ute_wtssim.setup_egate          egate_port=${egate_port}
    ...                             host_ip=${host_ip}
    ...                             tool_dir=${tool_dir}
    ...                             ssh_user=ute
    ...                             ssh_pass=ute
    ...                             alias=egate
    ute_wtssim.execute_egate_command
    ...                             cmd=${cmd}
    ...                             timeout=5s
    ...                             alias=egate
    ute_wtssim.teardown_egate       alias=egate
    sleep                           ${PostEgateCmdExec_timer}

AEP_multiwtsemu_L3Call
    [Arguments]            ${nbVMwts}=1    ${l3callSerialized}=True    ${howlong}=3600    ${pause}=25    ${estimateTimeForL3call}=25
    [Documentation]        Initiates L3 calls on 6 cells with 100 UEs

    IF      ${l3callSerialized} == True
            Dated Log New Line    =====================================================
            Dated Log    ==.................................................==
            Dated Log    ==...███████╗███████╗██████╗.██╗.█████╗.██╗........==
            Dated Log    ==...██╔════╝██╔════╝██╔══██╗██║██╔══██╗██║........==
            Dated Log    ==...███████╗█████╗..██████╔╝██║███████║██║........==
            Dated Log    ==...╚════██║██╔══╝..██╔══██╗██║██╔══██║██║........==
            Dated Log    ==...███████║███████╗██║..██║██║██║..██║███████╗...==
            Dated Log    ==...╚══════╝╚══════╝╚═╝..╚═╝╚═╝╚═╝..╚═╝╚══════╝...==
            Dated Log    ==.................................................==
            Dated Log    =====================================================
            FOR    ${idx}    IN RANGE       1    ${nbVMwts + 1}
                Dated Log New Line    AEP_multiwtsemu_L3_Call_6Cells_100UEs_mbps_10_10_NxnbVMwts_Per_WTS wtstarget=${idx} howlong=${howlong}
                AEP_multiwtsemu_L3_Call_6Cells_100UEs_mbps_10_10_NxnbVMwts_Per_WTS    wtstarget=${idx}    howlong=${howlong}

                # Calculate the pause duration as 40% of the estimated L3 call time (in seconds).
                # The timeout is set to the remaining 60% of the estimated L3 call time (in seconds).
                ${pause}=      Evaluate    int(${estimateTimeForL3call} * 60 - (${estimateTimeForL3call} * 60 * 0.60))    # pause in seconds
                ${timeout}=    Evaluate    int(${estimateTimeForL3call} * 60 - ${pause})

                Dated Log  Waiting ${pause} seconds for L3 calls and traffic to stabilize...
                sleep      ${pause} seconds

                Dated Log      AEP_multiwtsemu_L3_Call_6Cells_100UEs_Control_Per_WTS wtstarget=${idx}
                AEP_multiwtsemu_L3_Call_6Cells_100UEs_Control_Per_WTS    wtstarget=${idx}    timeout=${timeout}
            END
    ELSE
            Dated Log New Line    ==================================================================================
            Dated Log    ==..............................................................................==
            Dated Log    ==...██████╗..█████╗.██████╗..█████╗.██╗.....███████.██╗.....██╗.....███████╗...==
            Dated Log    ==...██╔══██╗██╔══██╗██╔══██╗██╔══██╗██║.....██╔════╝██║.....██║.....██╔════╝...==
            Dated Log    ==...██████╔╝███████║██████╔╝███████║██║.....█████╗..██║.....██║.....█████╗.....==
            Dated Log    ==...██╔═══╝.██╔══██║██╔══██╗██╔══██║██║.....██╔══╝..██║.....██║.....██╔══╝.....==
            Dated Log    ==...██║.....██║..██║██║..██║██║..██║███████╗███████╗███████╗███████╗███████╗...==
            Dated Log    ==...╚═╝.....╚═╝..╚═╝╚═╝..╚═╝╚═╝..╚═╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝...==
            Dated Log    ==..............................................................................==
            Dated Log    ==================================================================================
            AEP_multiwtsemu_L3_Call_6Cells_100UEs_mbps_10_10_NxnbVMwts    nbVMwts=${nbVMwts}    howlong=${howlong}

            # In parallel mode, the pause is set to 25% of the estimated L3 call time (in seconds).
            # The timeout is set to the remaining 75% of the estimated L3 call time (in seconds).
            ${pause}=      Evaluate    int(${estimateTimeForL3call} * 60 - (${estimateTimeForL3call} * 60 * 0.60) * 0.5)    # ratio 0.5 because //
            ${timeout}=    Evaluate    int(${estimateTimeForL3call} * 60 - ${pause})

            ${minutes}=    Evaluate    int(${pause} / 60)
            Dated Log                  Waiting ${minutes} minutes for L3 calls and traffic to stabilize...
            sleep                      ${pause} seconds
            AEP_multiwtsemu_L3_Call_6Cells_100UEs_Control    nbVMwts=${nbVMwts}    timeout=${timeout}
    END

AEP_Start Btslog
    [Arguments]    ${addr}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${username}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${password}=${tl.test_pc.default_ssh_connection_details.password}
    [Documentation]    :Author: Soenke Kullberg
    ...
    ...     KW starts Btslog on Testpc with log-collector
    ...
    ...     https://confluence.int.net.nokia.com/display/EE/EE+BTSlog
    ...
    ...     *Note:* KW works only on ute-vm

    Dated Log                      *** kwmkt_Start Btslog
    Return From Keyword If       '${username}'!='ute'   message=Works only on Cloud
    ${testpc_ssh_config}=         Create Dictionary
    ...                           host=${addr}
    ...                           user=${username}
    ...                           password=${password}
    ${btslog_collector_name}=     Set Variable    btslog
    btslog.create_btslog_collector
    ...                           name=${btslog_collector_name}
    ...                           executor=${testpc_ssh_config}
    btslog.setup_collectors       names=${btslog_collector_name}
    btslog.start_collectors       names=${btslog_collector_name}
    btslog.set_suite_alias        ${btslog_collector_name}

    Dated log                     =====> kwmkt_Start Btslog
    set Test variable             ${BtsLogStarted}    True

AEP_Stop_Btslog
    [Documentation]    :Author: Soenke Kullberg
    ...    Stop and fetch btslog from Testpc
    ...
    ...    *Note:* KW works only on ute-vm
    ...    :return path: Path to btslog file
    ...
    ...    :param target_dir: Directory to store the btslog file

    [Arguments]                    ${target_dir}=None
    ...                            ${username}=${tl.test_pc.default_ssh_connection_details.username}

    kwmkt_dbg_log                  *** kwmkt_Stop Btslog
    Return From Keyword If        '${username}'!='ute'   message=Works only on Cloud

    ${btslog_collector_name}=      Set Variable    btslog
    btslog.stop_collectors         names=${btslog_collector_name}
    # WA for https://jira3.int.net.nokia.com/browse/TALIB-854
    Builtin.Sleep                  15      # wait for btslog to close
    # WA for https://jira3.int.net.nokia.com/browse/TALIB-854
    btslog.collect_collectors      names=${btslog_collector_name}   target_dir=${target_dir}
    btslog.teardown_collectors     names=${btslog_collector_name}
    [RETURN]                       ${target_dir}/${btslog_collector_name}/syslog_files.tgz

AEP_LogCollection
    [documentation]       KWM KeyWord Market
    ...                   This KW help to several log file to global ${logsDir} directory

    # TEMPORARY to bypass pipelines [Arguments]           ${dir}=${LOG_PATH}    ${alias}=${alias_epcsim}
    Dated log   L O G S _ C O L L E C T I O N

    Get Snapshot
    # SSH Exec              mv ${LOG_PATH}/SNAPSHOT_GNB*zip ${dir}    ${alias}

    # Get Sos Report
    # SSH Exec              mv %{HOME}/SosReport*tgz ${dir}           ${alias}


AEP_Test_Teardown

    Dated log New Line                       AEP Test Teardown NG ${TEST_NAME} : begin
    Dated log                                ......................................

    Run Keyword If Test Failed      Set Global Variable           ${test_status}    FAIL
    Run Keyword If Test Failed      Dated log                     TEST - I N T E R R U P T I O N -
    Run Keyword If Test Passed      Set Global Variable           ${test_status}    PASS
    Run Keyword If Test Passed      Dated log                     TEST - N A T U R A L - E N D -

    kwmkt_Alarmslist                End    ${logsDir}
    Dated log                       TEST_NAME : ${TEST NAME}
    ${exists}                       Run Keyword And Return Status    Variable Should Exist    ${ListStep}
    Run Keyword If    ${exists}     Display diagnosis
    # ${alias_epcsim}                 SSH Wait For Connect            ${HOST_EPCSIM}
    # Set Suite Variable             ${alias_epcsim}

    Dated log                       test_status ${test_status} NoSnap ${NoSnap}

    ${attendu}=                     Set Variable    rien
    ${attendu}=                     Set Variable If    '${nosnap}' == '0' and '${test_status}' == 'FAIL'         Collection    ${attendu}
    ${attendu}=                     Set Variable If    '${nosnap}' == '100' and '${test_status}' == 'FAIL'       Collection    ${attendu}
    ${attendu}=                     Set Variable If    '${nosnap}' == '0' and '${test_status}' == 'PASS'         Collection    ${attendu}

    Dated log                      attendu: ${attendu}

    # Temporary Run Keyword If                '${attendu}' == 'Collection'    AEP_LogCollection    ${logsDir}
    # ...                                                                                VMwts_1
    Run Keyword If                '${attendu}' == 'Collection'    AEP_LogCollection
    Run Keyword If                 ${BtsLogStarted}               AEP_Stop_Btslog      ${logsDir}
    ...                                                           ${tl.test_pcs[0].default_ssh_connection_details.username}

    ${aliasWts1}=                  Set Variable    ${alias_list}[0]
    Dated Log                      aliasWts1=${aliasWts1}

    ${aliasWtsUN}                   Connect to Core Vm_mwts        ${aliasWts1}    0    # connect to first core only
    Dated Log                      Configuration collect in ${ConfigDir}
    ssh.execute                    /permavault/AEP_Shells_Aliases/Config_AEP_collector.sh -l ${ConfigDir} -n 3
    ...                            timeout=30
    ...                            connection=${aliasWtsUN}
    OAM Get SCF File               dir=${ConfigDir}    file=AEP_SCF.xml

    Dated log                      Test Teardown  ${TEST_NAME} : end