*** Settings ***
Documentation     [PURPOSE] Set of keywords used for CB007487 scripts utilities
...
...               Automation author           : yann.ah.herve@nokia.com
...               Automation contact          : davide.bacchiega@nokia.com
...               Creation Date               : 30-Sept-2021
...               Modified Date               : 17-Mars-2022 
...               Last Modified by            : denis.taupin@nokia.com

Resource          ../../../../Paris/resources/SWENG/robot/Oam.robot
Resource          ../../../../Paris/resources/SWENG/robot/Restart.robot
Resource          ../../../../Paris/resources/SWENG/robot/Tools.robot
Resource          ../../../../Paris/resources/SWENG/robot/Setup.robot

Variables         ../../../resources/SWENG/python/Colors.py

Library           taf.sbts.oam.coam.admin           WITH NAME   sbts_coam
Library           taf.gnb.oam.coam.admin            WITH NAME   coam

*** Variables **

${onair_timeout}                5 min
${blocked_timeout}              1 min

${time_between_each_reset_loop}                 1 min
${time_between_each_block_unblock_loop}         1 min
${perform_wts_setup_anyway}                     False
${gnb_alias}                                    gnb_under_test

*** Keywords ***

Check Bts Is On Air
    [Documentation]         Check if Bts is on Air by checking cOAM BTS status

    ${NrBtsStatus}=         OAM Run Command         cmd=get_bts_info

    # Check also that BTS is "onAir"
    ${bts_status}=          Set Variable       ${NrBtsStatus['status']}

    ${console_msg}          Evaluate     "${RED}BTS status for operationalState is ${bts_status['operationalState']}${NORMAL}"
    Run Keyword If          '${bts_status['operationalState']}'!='Enabled'
    ...                     Dated Log       ${console_msg}
    Should Be true          '${bts_status['operationalState']}'=='Enabled'

    ${console_msg}          Evaluate     "${RED}BTS status for proceduralState is ${bts_status['proceduralState']}${NORMAL}"
    Run Keyword If          '${bts_status['proceduralState']}'!='OnAir'
    ...                     Dated Log       ${console_msg}
    Should Be true          '${bts_status['proceduralState']}'=='OnAir'

    ${console_msg}          Evaluate     "${RED}BTS status for blockingState is ${bts_status['blockingState']}${NORMAL}"
    Run Keyword If          '${bts_status['blockingState']}'!='Unblocked'
    ...                     Dated Log       ${console_msg}
    Should Be true          '${bts_status['blockingState']}'=='Unblocked'

Check Cell Is On Air
    [Documentation]         Check if Cell is on Air by checking cOAM Cell status
    [Arguments]             ${cell_name}

    ${NrCellsStatus}=       OAM Run Command         cmd=get_cells_info

    ${nbCells}              Get length          ${NrCellsStatus}
    Dated Log               Nb cells is ${nbCells}
    FOR    ${cell_index}    IN RANGE          ${nbCells}
        ${cell_status}      Evaluate        '${cell_name}'=='${NrCellsStatus[${cell_index}]['id']['internal']}'      
        Run Keyword If      '${cell_name}'=='${NrCellsStatus[${cell_index}]['id']['internal']}'      
        ...                 Exit For Loop
    END
    ${cell_status}=         Set Variable        ${NrCellsStatus[${cell_index}]['status']}

    ${console_msg}          Evaluate     "${RED}operationalState for cell ${cell_index} is ${cell_status['operationalState']}${NORMAL}"
    Run Keyword If          '${cell_status['operationalState']}'!='enabled'
    ...                     Dated Log       ${console_msg}
    Should Be true          '${cell_status['operationalState']}'=='enabled'

    ${console_msg}          Evaluate     "${RED}administrativeState for cell ${cell_index} is ${cell_status['administrativeState']}${NORMAL}"
    Run Keyword If          '${cell_status['administrativeState']}'!='Unlocked'
    ...                     Dated Log       ${console_msg}
    Should Be true          '${cell_status['administrativeState']}'=='Unlocked'
        
    ${console_msg}          Evaluate     "${RED}usageState for cell ${cell_index} is ${cell_status['usageState']}${NORMAL}"
    Run Keyword If          '${cell_status['usageState']}'!='Active'
    ...                     Dated Log       ${console_msg}
    Should Be true          '${cell_status['usageState']}'=='Active'

    ${console_msg}          Evaluate     "${RED}blockingState for cell ${cell_index} is ${cell_status['blockingState']}${NORMAL}"
    Run Keyword If          '${cell_status['blockingState']}'!='Unblocked'
    ...                     Dated Log       ${console_msg}
    Should Be true          '${cell_status['blockingState']}'=='Unblocked'

    ${console_msg}          Evaluate     "${RED}barringStatus for cell ${cell_index} is ${cell_status['barringStatus']}${NORMAL}"
    Run Keyword If          '${cell_status['barringStatus']}'!='unbarred'
    ...                     Dated Log       ${console_msg}
    Should Be true          '${cell_status['barringStatus']}'=='unbarred'

    ${console_msg}          Evaluate     "${RED}proceduralStatus for cell ${cell_index} is ${cell_status['proceduralStatus']}${NORMAL}"
    Run Keyword If          '${cell_status['proceduralStatus']}'!='configured'
    ...                     Dated Log       ${console_msg}
    Should Be true          '${cell_status['proceduralStatus']}'=='configured'

Check Cell Is Blocked
    [Documentation]         Check if Cell is Blocked by checking cOAM Cell status
    [Arguments]             ${cell_name}

    ${NrCellsStatus}=       OAM Run Command         cmd=get_cells_info

    ${nbCells}              Get length          ${NrCellsStatus}
    FOR    ${cell_index}    IN RANGE            ${nbCells}
        Run Keyword If      '${cell_name}'=='${NrCellsStatus[${cell_index}]['id']['internal']}'
        ...                 Exit For Loop
    END
    ${cell_status}=         Set Variable        ${NrCellsStatus[${cell_index}]['status']}

    ${console_msg}          Evaluate     "${RED}blockingState for cell ${cell_name} is ${cell_status['blockingState']}${NORMAL}"
    Run Keyword If          '${cell_status['blockingState']}'!='Blocked'
    ...                     Dated Log       ${console_msg}
    Should Be true          '${cell_status['blockingState']}'=='Blocked'

Modify WTS Heart Beat
    [Documentation]                 KW used to either enable HB or modify HB duration
    ...                             This is used to keep WTS polling towards AP and gNB after reset
    ...                             and perform automatic X2 / UEC reconnections after reset.
    ...                             It's based on AF KW Modify Field in WtsEmu Cfg File
    ...                             Original KW was not suitable for complete string replacement.
    ...                             link_ctrl_param command is supposed to exist inside WTS configuration file

    ${cfg_file}                     Set Variable                            ${tl.core.dir_path}/${tl.core.cfg_filename}
    #${sed_cmd}                      Catenate        sed --follow-symlinks -i 
    #...                             "s/link_ctrl_param.*[[:graph:]]*/link_ctrl_param use_hb=on hb_period=60 hb_retries=10/g" 
    #...                             ${cfg_file}

    ${sed_cmd}                      Catenate        sed --follow-symlinks -i 
    ...                             "s/link_ctrl_param.*[[:graph:]]*/link_ctrl_param use_hb=off/g" 
    ...                             ${cfg_file}

    Dated log                       Changing link heart beat value inside WTS configuration
    SSH Wait For Connect and Cmd    command=sudo ${sed_cmd}                 host=${HOST_EPCSIM}

Wait Until All Cells Are OnAir
    [Documentation]                 This KW is here because robot framework does not support nested loop
    ...                             So, an intermediate KW called from the main loop is used instead.
    ...                             It returns a global cell status.

    ${NrCellsStatus}=               OAM Run Command         cmd=get_cells_info
    ${nbCells}                      Get length              ${NrCellsStatus}

    ${global_cell_status}           Set Variable            True
    FOR    ${cell_id}               IN RANGE                ${nbCells}

        # Retrieve cell name
        ${cell_name}                Set Variable            ${NrCellsStatus[${cell_id}]['id']['internal']}
        Dated Log                   Cell name is ${cell_name}
        # Wait until cells are onAir again
        ${cell_status}=             Run Keyword And Return Status    Wait Until Keyword Succeeds     ${onair_timeout}        30 sec
        ...                         Check Cell Is On Air    ${cell_name}

        ${console_msg}              Evaluate     "${RED}Cell status for cell ${cell_id} is ${cell_status}${NORMAL}"
        Run Keyword If              '${cell_status}'=='False'
        ...                         Dated Log       ${console_msg}
        
        ${global_cell_status}       Evaluate       '${cell_status}'=='True' and ${global_cell_status}
    END

    [Return]            ${global_cell_status}

Redo Wts Configuration
    [Documentation]         KW useed to reset egate as a WA for sporadic
    ...                     pooling lost during gNB/AP resets

    # Reset WTS configuration
    wtsemu.Reset_Wtsemu_Cfg
    Traced Sleep        5 seconds
    # Reload WTS configuration
    WTS Configure
    Traced Sleep        5 seconds    
    # X2 link establishment (NSA)
    WTS Set X2 Link

OAM Soft Reset Site
    [Documentation]                 Reset the OAM
    [Arguments]                     ${oam}
    Call method secure              ${oam}                  startReset


TC_CB007487_RESET_SUCCESS_RATIO
    [Documentation]                 KW used to check site reset ratio success in case of ABIP.
    [Arguments]                     ${reset_params}

    ${nbLoops}                      Get From Dictionary     ${reset_params}     nbSiteReset
    ${successRatio}                 Get From Dictionary     ${reset_params}     successRatio

    # Using "Restart TL" should not be useful as TL should already be ready to perform cellsetup.
    # But I have noticed that if TL is not restarted, WTS or gNB (???) stay in a wrong state (???), and
    # WTS stops pooling X2 and UEC links...
    #
    # Performing a TL restart before reset loop seems to refresh everything.
    Restart TL

    # Modify WTS configuration file in order to remove heart timeout regarding ethernet connections
    # Like this, it lets the cell come back to onAir state by itseilf, without restarting WTS.
    # gNB and AP are supposed up and running
    # The strategy is to replace the full HB command and
    # set HB to off (I have seen several configuration inside test line config repository)
    #
    Modify WTS Heart Beat

    WTS Setup

    Dated Log                       Checking that cells and gNB are up before entering reset loop

    ${cells_status}=                Run Keyword And Return Status       Wait Until All Cells Are OnAir
    Should Be True                  '${cells_status}'=='True'
    ${bts_status}=                  Run Keyword And Return Status       Check Bts Is On Air
    Should Be True                  '${bts_status}'=='True'

    ${reset_failure}=               Set Variable        0.0
    ${total_reset_duration}=        Set Variable        0
    FOR    ${loop}                  IN RANGE            ${nbLoops}

        ${console_msg}              Evaluate     "${BLUE}- Starting reset loop ${loop}${NORMAL}"
        Dated Log                   ${console_msg}

        ${start_reset}=             Get Current Date
        OAM Soft Reset Site         ${GNB_DU.oam}
        # coam.Reset_Site             connection=${GNB_DU.oam}

        # Keep the option to restart WTS anyway after a gNB reset in case of connection pooling
        # does not work.
        Run Keyword If              '${perform_wts_setup_anyway}'=='True'           Redo Wts Configuration

        ${cells_status}             Run Keyword And Return Status       Wait Until All Cells Are OnAir
        ${bts_status}=              Run Keyword And Return Status       Check Bts Is On Air
        ${global_status}            Evaluate    ${cells_status} and ${bts_status}      

        # Is it the right way to do this ?
        ${reset_failure}            Run Keyword If              '${global_status}'=='False'
        ...                         Evaluate        ${reset_failure} + 1
        ...                         ELSE
        ...                         Evaluate        ${reset_failure} + 0

        Run Keyword If              '${global_status}'=='False'       Run Keywords
        ...                         Get Snapshot
        ...                         AND
        ...                         Get Sos Report

        ${console_msg}              Evaluate     "${BLUE}- End of loop ${loop}: Reset failures value is ${reset_failure}${NORMAL}"
        Dated Log                   ${console_msg}
        ${end_reset}=               Get Current Date
        ${reset_duration}=          Subtract Date From Date     ${end_reset}        ${start_reset}
        Dated Log                   - Time for performing gNB reset with AP is: ${reset_duration} s
        ${total_reset_duration}     Evaluate            ${total_reset_duration} + ${reset_duration}

        Traced Sleep                ${time_between_each_reset_loop}
        ...                         msg=Sleeping for ${time_between_each_reset_loop} before resetting again
    END

    ${reset_success_num}            Evaluate        ${nbLoops} - ${reset_failure}
    Dated Log                       Number of successful site reset: ${reset_success_num} over ${nbLoops} site resets
    ${reset_success_ratio}          Evaluate        100 * (${reset_success_num} / ${nbLoops})
    Dated Log                       Success ratio reset loop is: ${reset_success_ratio} %
    ${avg_reset_duration}           Evaluate            ${total_reset_duration} / ${nbLoops}
    Dated Log                       Average time for gNB reset with AP RU is : ${avg_reset_duration} s
    Should Be True                  ${reset_success_ratio} >= ${successRatio}


TC_CB007487_BLOCK_UNBLOCK_SUCCESS_RATIO
    [Documentation]                 KW used to check cell block/unblock success ratio in case of ABIP.
    ...                             It's like using "Block" button on the cell by using the webUI.
    [Arguments]                     ${block_unblock_params}

    ${cell_to_block_unblock}        Get From Dictionary     ${block_unblock_params}       cellId
    ${nbLoops}                      Get From Dictionary     ${block_unblock_params}       nbBlockUnblock
    ${expectedSuccessRatio}         Get From Dictionary     ${block_unblock_params}       successRatio

    # Should not be useful as TL is expected to be "ready" when test is started
    Restart TL

    # In case of lock/unlock scenario and if gNB is configured with only one cell, X2 link is dropped
    # WTS starts to pool X2 link. So, modify pooling configuration in order to keep pooling X2 link until
    # cell is Unblocked again.
    Modify WTS Heart Beat

    WTS Setup

    Should Be True                      1 <= ${cell_to_block_unblock}
    Should Be True                      ${cell_to_block_unblock} <= 2
    ${cell_index_to_block_unblock}      Evaluate            ${cell_to_block_unblock} - 1
    Dated Log                           Checking that gNB is up before entering cell block/unblock loop

    # Open connection towards cOAM
    sbts_coam.connect_to                name=${gnb_alias}

    # Retrieve cell name
    ${NrCellsStatus}=                   OAM Run Command         cmd=get_cells_info
    ${cell_name}                        Set Variable            ${NrCellsStatus[${cell_index_to_block_unblock}]['id']['internal']}

    ${cell_status}=                     Run Keyword And Return Status
    ...                                 Check Cell Is On Air        ${cell_name}
    Should Be True                      '${cell_status}'=='True'

    # Check BTS is on Air
    ${bts_status}=                      Run Keyword And Return Status
    ...                                 Check Bts Is On Air
    Should Be True                      '${bts_status}'=='True'

    ${block_unblock_failure}            Set Variable        0.0
    FOR                                 ${n}                IN RANGE          ${nbLoops}

        ${console_msg}                  Evaluate     "${BLUE}- Starting lock/unlock loop ${n}${NORMAL}"
        Dated Log                       ${console_msg}

        ${blocking_test_status}         Set Variable        True

        sbts_coam.block_cell            dist_name=${cell_name}          connection=${gnb_alias}
        # SWENG command does not work because it uses com library instead of sbts
        #&{cmdArgs}                      Create Dictionary               dist_name="${cell_name}"
        #${NrCellsStatus}=               OAM Run Command                 cmd=block_cell      cmd_args=${cmdArgs}         

        # Check cell is Blocked:
        ${block_status}=                Run Keyword And Return Status       Wait Until Keyword Succeeds     ${blocked_timeout}      30 sec
        ...                             Check Cell Is Blocked               ${cell_name}
        ${blocking_test_status}         Evaluate    ${block_status} and ${blocking_test_status}

        Traced Sleep                    ${time_between_each_block_unblock_loop}
        ...                             msg=Sleeping for ${time_between_each_block_unblock_loop} before unblocking

        sbts_coam.unblock_cell          dist_name=${cell_name}          connection=${gnb_alias}
        #&{cmdArgs}                      Create Dictionary               dist_name="${cell_name}"
        #${NrCellsStatus}=               OAM Run Command                 cmd=unblock_cell    cmd_args=${cmdArgs}

        # Wait until cells are onAir again
        ${cell_status}=                 Run Keyword And Return Status   Wait Until Keyword Succeeds     ${onair_timeout}        30 sec
        ...                             Check Cell Is On Air            ${cell_name}
        ${blocking_test_status}         Evaluate    ${cell_status} and ${blocking_test_status}

        ${block_unblock_failure}        Run Keyword If              '${blocking_test_status}'=='False'
        ...                             Evaluate        ${block_unblock_failure} + 1
        ...                             ELSE
        ...                             Evaluate        ${block_unblock_failure} + 0
        Run Keyword If                  '${blocking_test_status}'=='False'       Run Keywords
        ...                             Get Snapshot
        ...                             AND
        ...                             Get Sos Report

        ${console_msg}                  Evaluate
        ...                             "${BLUE}- End of loop ${n} Lock/Unlock failures number is ${block_unblock_failure}${NORMAL}"
        Dated Log                       ${console_msg}

        Traced Sleep                    ${time_between_each_block_unblock_loop}
        ...                             msg=Sleeping for ${time_between_each_block_unblock_loop} before blocking again

    END

    ${block_unblock_success_num}        Evaluate        ${nbLoops} - ${block_unblock_failure}
    Dated Log                           Number of successful cell block/unblock : ${block_unblock_success_num} over ${nbLoops} block/unblock
    ${block_unblock_success_ratio}      Evaluate        100 * (${block_unblock_success_num} / ${nbLoops})
    Dated Log                           Success ratio block/unblock loop is: ${block_unblock_success_ratio} %

    Should Be True                      ${block_unblock_success_ratio} >= ${expectedSuccessRatio}

    [TearDown]                          sbts_coam.teardown    connection=${gnb_alias}
