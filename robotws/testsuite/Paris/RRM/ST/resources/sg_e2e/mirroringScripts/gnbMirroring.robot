*** Settings ***
Library      DateTime
Library      Collections
Library      OperatingSystem
Library      String
Library      taf.transport.ssh              WITH NAME   ssh


*** Keywords ***
Prepare gnbMirroring Script
    [Documentation]    Downloads mirroring scripts on ASIK
    ...                To stay compatible with UTE Cloud, mirroring is performed on ASIK ABIL shared directory instead of EIF2
    ...                Mirroring scripts gnbMirroring.sh and gnbMirroringConfig.sh V50
    ...                Author: Abderrahmane NEZROUK
    [Arguments]        ${connection}=asikFhCnx

    wait until keyword succeeds    5 min     30 sec     ssh.force reconnect     ${connection}

    # Check SW release
    # set test variable    ${sw_release}    ${5GRelease}

    ${remote_dir}    Set variable    /ffs/run/config/scripts

    ${remote_dir_exists}    ssh.File exists    remote_path=${remote_dir}    connection=${connection}
    ${cmd}           Set variable    mkdir ${remote_dir}
    Run keyword if    '${remote_dir_exists}' == 'False'
    ...        ssh.Execute    ${cmd}    connection=${connection}

    ${local_path1}          Set variable    ${CURDIR}/gnbMirroring.sh
    ${local_path2}          Set variable    ${CURDIR}/gnbMirroringConfig.sh

    ${remote_path1}=    catenate    SEPARATOR=    /ffs/run/config/scripts/gnbMirroring.sh
    ${remote_path2}=    catenate    SEPARATOR=    /ffs/run/config/scripts/gnbMirroringConfig.sh

    #Create scripts backup if file already exist.
    ssh.execute     cp ${remote_path1} ${remote_path1}.sav    connection=${connection}
    ssh.execute     cp ${remote_path2} ${remote_path2}.sav    connection=${connection}

    ssh.Upload file    local_path=${local_path1}    remote_path=${remote_path1}    connection=${connection}
    ssh.Upload file    local_path=${local_path2}    remote_path=${remote_path2}    connection=${connection}
    ssh.Execute        chmod 777 ${remote_path1}    connection=${connection}
    ssh.Execute        chmod 777 ${remote_path2}   connection=${connection}

    # return absolute path of gnbMirroring script on ASIK
    [return]    ${remote_path1}

Update gnbMirroringConfig Script
    [Documentation]  This keyword update gnbMirroringConfig.sh according to parameters provided in argument
    ...                Author: Abderrahmane NEZROUK
    [Arguments]     ${capturing_time}=infinite    ${number_of_files}=1    ${file_size_mbytes}=50
    ...             ${filtering}=off    ${filter}=${EMPTY}    ${mirroring_mode}=local    ${l2_l1_bip}=true    ${syscom_mirroring}=false
    ...             ${BB_SLOT_1}=true    ${connection}=asikFhCnx

    ${mirroring_script}    set variable    /ffs/run/config/scripts/gnbMirroringConfig.sh
    ${mirroring_script_sav}    set variable    /ffs/run/config/scripts/gnbMirroringConfig.sh.sav

    ssh.execute     sed -i -e 's/CAPTURING_TIME_SECONDS\=[0-9]*/CAPTURING_TIME_SECONDS\=${capturing_time}/g' ${mirroring_script}
    ...             connection=${connection}

    ssh.execute     sed -i -e 's/NUMBER_OF_FILES\=[0-9]*/NUMBER_OF_FILES\=${number_of_files}/g' ${mirroring_script}    connection=${connection}

    ssh.execute     sed -i -e 's/FILE_SIZE_MBYTES\=[0-9]*/FILE_SIZE_MBYTES\=${file_size_mbytes}/g' ${mirroring_script}    connection=${connection}

    ssh.execute     sed -i -e "s/FILTERING\='.*'/FILTERING\='${filtering}'/g" ${mirroring_script}    connection=${connection}

    #for V30
    ssh.execute     sed -i -e "s/MIRRORING_MODE\='.*'/MIRRORING_MODE\='${mirroring_mode}'/g" ${mirroring_script}    connection=${connection}

    ssh.execute     sed -i -e "s/FILTER\='.*'/FILTER\='${filter}'/g" ${mirroring_script}    connection=${connection}

    ssh.execute     sed -i -e "s/L2_L1_BIP\='.*'/L2_L1_BIP\='${l2_l1_bip}'/g" ${mirroring_script}    connection=${connection}

    ssh.execute     sed -i -e "s/SYSCOM_MIRRORING\='.*'/SYSCOM_MIRRORING\='${syscom_mirroring}'/g" ${mirroring_script}    connection=${connection}

    ssh.execute     sed -i -e "s/BB_SLOT_1\='.*'/BB_SLOT_1\='${BB_SLOT_1}'/g" ${mirroring_script}    connection=${connection}

    Set Test Variable     ${num_of_tcpdump_file}    ${${number_of_files}}

Check tcpdump Process is Running
    [Documentation]    this keyword to unsure collecting tcpdump process is running
    ...                Author: Abderrahmane NEZROUK
    [Arguments]   ${connection}=asikFhCnx
    ${cmd}       Set Variable    ps aux | grep tcpdump
    ${output}    ssh.Execute    ${cmd}    connection=${connection}
    @{output_list}=    string.Split string    ${output}
    @{list_items}=    Get Matches    ${output_list}    *tcpdump_L2L1*
    Run Keyword If    @{list_items}==@{EMPTY}
    ...    Fail    tcpdump process did not start.

Start Customized Mirroring Traces
    [Documentation]    Launch mirroring command. Mirroring scripts must have been downloaded and configured before this keyword is used.
    [Arguments]   ${remote_script_path}      ${connection}=asikFhCnx

    Log               ************** Start gnbMirroring.sh ************
    # launch tcpdump
    #ssh.Send Command    command=sh ${remote_script_path}      connection=${connection}
    #ssh.Send Command    echo $(sh ${remote_script_path}) \\\\n   connection=${connection}
    ssh.Send Command   command=nohup sh /ffs/run/config/scripts/gnbMirroring.sh    get_pty=True   connection=${connection}
    ${error out}=   ssh.Read Output   size=48    connection=${connection}
    # ensure that tcpdump started before to continue
    Sleep    5s
    wait until keyword succeeds    10 sec     0 sec     Check tcpdump Process is Running     ${connection}

Start Mirroring Traces
    [Documentation]    Prepare and launch tcpdump. T
    [Arguments]     ${capturing_time}=infinite    ${number_of_files}=1    ${file_size_mbytes}=50    ${filtering}=off
    ...             ${filter}=${EMPTY}    ${mirroring_mode}=local    ${l2_l1_bip}=true    ${syscom_mirroring}=false
    ...             ${BB_SLOT_1}=true    ${connection}=asikFhCnx

    ${remote_path1}    Prepare gnbMirroring Script    ${connection}

    Update gnbMirroringConfig Script    capturing_time=${capturing_time}   number_of_files=${number_of_files}
    ...        file_size_mbytes=${file_size_mbytes}     filtering=${filtering}    filter=${filter}   mirroring_mode=${mirroring_mode}
    ...        l2_l1_bip=${l2_l1_bip}    syscom_mirroring=${syscom_mirroring}    BB_SLOT_1=${BB_SLOT_1}    connection=${connection}

    Start Customized Mirroring Traces    ${remote_path1}    ${connection}


Stop tcpdump Mirroring Traces
    [Documentation]    Stops L1L2 traces if not already stopped
    ...                Author: Abderrahmane NEZROUK
    [Arguments]        ${connection}=asikFhCnx    ${board_socid}=0
    # Force reconnect
    # wait until keyword succeeds    5 min     30 sec     ssh.force reconnect     asikFhCnx
    # Stop tcpdump on ABIL/ABIO and ASIK/ASIB if still running
    # nb: Keyword compatible with ASIB/ASIK conf
    Log               ************** Stop Traces ************
    ${cmd}         set variable if   '${board_socid}'!='0'
    ...     bsh ${board_socid} pkill -2 tcpdump
    ...     pkill -2 tcpdump
    ${run}=        ssh.execute           command=${cmd}    connection=${connection}

Collect and Clean Single Remote Trace
    [Documentation]    Collect pcap file on VM
    ...                Author: Abderrahmane NEZROUK
    [Arguments]        ${connection}=asikFhCnx    ${filtering}=off

    ${path_tmp}  JoinPath       ${res_path}     logs/tcpdump
    Create Directory            ${path_tmp}
    Set Suite Variable          ${path_tcpdump}     ${path_tmp}
    OperatingSystem.Directory Should Exist      ${path_tmp}         ${path_tmp} directory should be created

    ${local_path}  JoinPath       ${path_tmp}     tcpdumpL2L1.pcap
    ${remote_path}    Set Variable      /tmp/tcpdump_L2L1_bip_filtering_${filtering}.pcap
    Run Keyword and Ignore Error    ssh.download file    remote_path=${remote_path}
    ...       local_path=${local_path}   connection=${connection}
    ssh.send command    rm ${remote_path}    connection=${connection}
    [Return]    ${local_path}

Collect and Clean Multiple Remote Traces
    [Documentation]    Collect pcap file on VM
    ...                Author: Abderrahmane NEZROUK
    [Arguments]        ${connection}=asikFhCnx    ${filtering}=off

    ${path_tmp}  JoinPath       ${res_path}     logs/tcpdump
    Create Directory            ${path_tmp}
    Set Suite Variable          ${path_tcpdump}     ${path_tmp}
    OperatingSystem.Directory Should Exist      ${path_tmp}         ${path_tmp} directory should be created
    ${script_fname}=    Set Variable    tcpdump_L2L1_bip_filtering
    @{download_list_local}    Create list
    FOR    ${index}     IN RANGE    ${num_of_tcpdump_file}
        ${local_path}=    Set Variable    ${path_tmp}/${script_fname}_${filtering}.pcap${index}
        ${remote_path}=   Set Variable    /tmp/${script_fname}_${filtering}.pcap${index}
        Run Keyword and Ignore Error    ssh.download file    remote_path=${remote_path}
        ...       local_path=${local_path}   connection=${connection}
        ssh.send command    rm ${remote_path}    connection=${connection}
        APPEND TO LIST    ${download_list_local}    ${local_path}
    END
    [Return]    ${download_list_local}

Restore Remote File from Backup
    [Documentation]  This keyword restore original file from backup file.sav
    [Arguments]     ${file_path}    ${backup_file_path}    ${connection}=asikFhCnx

    ssh.execute     rm ${file_path}    connection=${connection}
    Run Keyword If    '${backup_file_path}' != '${EMPTY}'
    ...          ssh.execute     mv ${backup_file_path} ${file_path}    connection=${connection}

Clean Mirroring Script
    [Documentation]    Delete mirroring scripts on ASIK
    ...                Author: Abderrahmane NEZROUK
    [Arguments]        ${connection}=asikFhCnx

    ${remote_path1}    Set variable    /ffs/run/config/scripts/gnbMirroring.sh
    ${remote_path2}    Set variable    /ffs/run/config/scripts/gnbMirroringConfig.sh
    Restore Remote File from Backup    ${remote_path1}    ${remote_path1}.sav    connection=${connection}
    Restore Remote File from Backup    ${remote_path2}    ${remote_path2}.sav    connection=${connection}

Stop and Collect Mirroring Traces
    [Documentation]    Stops traces on ABIL/ABIO if not already stopped
    ...                Collect pcap file on VM
    ...                Clean Asik/ASIB board
    ...                Author: Abderrahmane NEZROUK
    [Arguments]        ${connection}=asikFhCnx    ${board_socid}=0    ${filtering}=off    ${clean_scripts}=yes

    Stop tcpdump Mirroring Traces    ${connection}    ${board_socid}
    BuiltIn.sleep         5s
    # Depending on mirroring configuration several files may be generated
    ${L1L2_trace_pcap}         Run Keyword If     '${num_of_tcpdump_file}'=='1'
    ...        Collect and Clean Single Remote Trace    connection=${connection}    filtering=${filtering}
    ...              ELSE
    ...       Collect and Clean Multiple Remote Traces    connection=${connection}    filtering=${filtering}
    Set Test Variable    ${L1L2_trace_pcap}    ${L1L2_trace_pcap}
    Run Keyword If    '${clean_scripts}'=='yes'
    ...    Clean Mirroring Script    connection=${connection}
    [Return]    ${L1L2_trace_pcap}
