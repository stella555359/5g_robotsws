*** Settings ***
Documentation        keywords for BIP Traces capture with gnbMirroring scripts
...                  Author: Annie Wong      annie.wong@nokia.com
...                  Last update : 27.05.2021   add ABIO slot in parameter

Library        BuiltIn
Library        Collections
Library        String
Library        taf.transport.ssh                       WITH NAME      ssh
Library        capture.py


*** Variables ***
# DEF_SCRIPT_MIRROR_LONER_GNB : Dictionaries, that should contain:
#   scripts    : list of files names of script to be downloaded
#   remotepath : location on taget where to download them
&{DEF_SCRIPT_MIRROR_LONER_GNB}       filelist=gnbMirroring.sh,gnbMirroringConfig.sh
...                                  script=gnbMirroring.sh
...                                  remotepath=/ffs/run/config/scripts

&{DEF_SCRIPT_MIRROR_LONER_GNB_ABIO}       filelist=ABIO_BIP_Mirroring.sh
...                                       script=ABIO_BIP_Mirroring.sh
...                                       remotepath=/ffs/run/config/scripts


*** Keywords ***
Dictionary Get
    [Documentation]      Perform a copy of a dictionary, and return new dictionary
     ...                 Interest is that original one is not modified
    [Arguments]          ${dico}
    ${copy_dico}         Copy Dictionary     ${dico}
    [Return]             ${copy_dico}


SSH gNB wait for connect
    [Documentation]      Service to loop and attempt to establish a connection to a host until success
    ...                  Attempt is executed every <every> seconds and until success or a timeout
    [Arguments]          ${cnx_alias}=cnx_mirroring_alias    ${gNB_id}=0
    ...                  ${timeout}=5 min                    ${every}=20s
    wait until keyword succeeds       ${timeout}       ${every}
    ...                  ssh.connect_to              ${GNB_AIRSCALE_IP[${gNB_id}]}
    ...                                              ${GNB_AIRSCALE_USERNAME[${gNB_id}]}
    ...                                              ${GNB_AIRSCALE_PASSWORD[${gNB_id}]}
    ...                                              alias=${cnx_alias}


SSH Upload Mirroring Script
    [Documentation]       Upload script on a host (remotepath), and prepare for execution (chmod +x)
    ...                   Connection should have been previously established
    [Arguments]        ${cnx_alias}       ${scriptfile}
    ...                ${localpath}       ${remotepath}
    # remove old script on remote
    ${rm_cmd}    catenate    rm ${remotepath}/${scriptfile}
    ${script_exists}=     ssh.file_exists   ${remotepath}/${scriptfile}      connection=${cnx_alias}
    Run keyword if       ${script_exists}    ssh.execute    command=${rm_cmd}    connection=${cnx_alias}

    # upload new script to remote
    ssh.upload file       remote_path=${remotepath}/${scriptfile}
    ...                   local_path=${localpath}/${scriptfile}
    ...                   connection=${cnx_alias}

    ${cmd}    catenate    chmod +x ${remotepath}/${scriptfile}
    Log       Execute cmd (ssh session)=${cmd}       console=${DEBUG_MODE_CONSOLE}
    ssh.execute     command=${cmd}    connection=${cnx_alias}


Is trace capturing process exist
    [Documentation]    (Author: Liu Zheng)
    ...                Check if the tcpdump process is triggered .
    [Arguments]         ${log_prefix}    ${connection_alias}
    ${check_process}    ssh.Execute    ps -ef | grep tcpdump | grep -v grep | grep ${log_prefix}
    ...                  connection=${connection_alias}
    ${check_process}    Strip string    ${check_process}
    ${output_len}    Get length    ${check_process}
    ${is_process_exist}    set variable if    ${output_len}!=0    ${True}    ${False}
    [Return]    ${is_process_exist}


Trace capturing process should be triggered
    [Documentation]    (Author: Liu Zheng)
    ...                Make sure tcpdump process should be triggered.
    ...                There is tcpdump process after start the tcpdump process,
    ...                but when to stop the process, the tcpdump process disappeared in rare cases.
    ...                So to make sure the process is really trigged, there are default three check times to make sure tcpdump process exist.
    [Arguments]         ${log_prefix}    ${connection_alias}   ${check_times}=${3}    ${sleep_interval}=1 sec
    ${process_check_list}    Create list
    FOR    ${check_time}    IN RANGE    ${check_times}
        ${is_process_exist}    Is trace capturing process exist    log_prefix=${log_prefix}    connection_alias=${connection_alias}
        Append to list    ${process_check_list}    ${is_process_exist}
        Sleep    ${sleep_interval}
    END
    Should be equal as strings    ${process_check_list[-1]}    True


Precondition For BIP Capture with gnbMirroring scripts
    [Documentation]       Create ssh cnx, upload the scripts on airscale
    [Arguments]           ${cnx_alias}       ${gNB_id}=0
    ${_type}   set variable   ${tl.gnbs[${gNB_id}].dus[0].airscale.common_units[0].capacity_units[2].hardware_type}
    #${mirror_dico}           Dictionary Get       ${DEF_SCRIPT_MIRROR_LONER_GNB}
    ${mirror_dico}       run Keyword if    '${_type}'=='ABIO'
    ...               Dictionary Get    ${DEF_SCRIPT_MIRROR_LONER_GNB_ABIO}
    ...    ELSE       Dictionary Get    ${DEF_SCRIPT_MIRROR_LONER_GNB}
    @{scripts_list}          Split String         ${mirror_dico.filelist}        separator=,
    ${scripts_local_path}    run Keyword if    '${_type}'=='ABIO'
    ...               Get ABIO Mirroring Scripts Path
    ...    ELSE       Get Mirroring Scripts Path
    Log       mirroring scripts list=${mirror_dico.filelist}               console=${DEBUG_MODE_CONSOLE}
    Log       mirroring scripts remotepath=${mirror_dico.remotepath}       console=${DEBUG_MODE_CONSOLE}
    Log       mirroring scripts localpath=${scripts_local_path}            console=${DEBUG_MODE_CONSOLE}

    SSH gNB wait for connect        cnx_alias=${cnx_alias}     gNB_id=${gNB_id}

    ${mkdir_cmd}    catenate     mkdir -p ${mirror_dico.remotepath}
    ${script_path_exists}    ssh.file_exists    remote_path=${mirror_dico.remotepath}    connection=${cnx_alias}
    Run Keyword if      ${script_path_exists} == ${False}    ssh.execute    command=${mkdir_cmd}      connection=${cnx_alias}

    FOR    ${script}     IN     @{scripts_list}
          SSH Upload Mirroring Script
          ...        cnx_alias=${cnx_alias}              scriptfile=${script}
          ...        localpath=${scripts_local_path}       remotepath=${mirror_dico.remotepath}
    END
    [Teardown]   Run Keyword And Ignore Error    ssh.disconnect    connection=${cnx_alias}


Start BIP Capture with gnbMirroring scripts
    [Documentation]      Start BIP Capture with gnbMirroring scripts version V30
    ...    1/ create cnx to arscale
    ...    2/ upload mirroring scripts to ASIK (remove old scripts, upload scripts, chmod -x on scripts)
    ...    3/ run gnbMirroring.sh with arguments
    ...    4/ verify output of command contains "Filter"
    ...
    ...    The mirroring scripts origine and location:
    ...    \\eseefsn50.emea.nsn-net.net\rotta4internal\5G\Oulu_L3_CAMP\gnbMirroring\
    ...    :param MIRRORING_MODE='local' # remote/local/manual/local_in_l2rt_core,
    ...        remote: mirrors to EIF2,
    ...        local: dumps data to gNB,
    ...        manual: enables mirroring but ABIL Master/Slave Xeon but does not capture data or disable mirroring
    ...    (Mirror BB boards)
    ...    :param MIRROR_ABIL_1='true' # true/false
    ...    :param MIRROR_ABIL_2='false' # true/false, do not enable for CA configs
    ...    :param MIRROR_ABIL_3='false' # true/false, do not enable for CA configs
    ...    (Mirrored interfaces, the less interfaces are configured, better are chances not to drop packets)
    ...    :param L2_L1_BIP='true' # true/false
    ...    :param SYSCOM_MIRRORING='false' # true/false, mirrors syscom traffic between control and baseband boards
    ...    :param CARRIER_AGGREGATION='false' # true/false, for GC2/GD2 L2-RT instances
    ...    :param BACKHAUL_MIRRORING='false' # true/false
    ...    :param L2HI_L2LO_MIRRORING='false' # true/false
    ...    # Local mode options
    ...    :param FILTERING='off' # off/on, on filters out control messages sent in every TTI
    ...    :param FILTER='ether[0x18:2]!=0xe101 && ether[0x18:2]!=0x131 && ether[0x18:2]!=0x240
    ...                   && ether[0x18:2]!=0x127 && ether[0x18:2]!=0x12a && ether[0x18:2]!=0x233
    ...                   && ether[0x18:2]!=0x122 && ether[0x18:2]!=0x12b'
    ...    :param USE_GULP='false' # true/false, use gulp engine for capturing instead of tcpdump, better performance
    ...    :param CAPTURING_TIME_SECONDS=300 # in seconds/special value 'infinite' keeps capture rolling
    ...    :param NUMBER_OF_FILES=1 # number of files created, tcpdump -W
    ...    :param FILE_SIZE_MBYTES=500 # size of file create, tcpdump -C
    ...    :param connection <str> : asik master connection alias
    ...    Output is saved to /tmp/tcpdumpL2L1_filtering_$FILTERING.pcap$

    [Arguments]         ${cnx_alias}       ${gNB_id}=0
    ...                 ${filtering}=off   ${filter}=default
    ...                 ${capturing_time_seconds}=infinite     ${file_size_mbytes}=500
    ...                 ${mirror_abil_1}=true    ${mirror_abil_2}=false    ${mirror_abil_3}=false
    ...                 ${use_gulp}=false        ${L2_L1_bip}=true
    ...                 ${syscom_mirroring}=false      ${carrier_aggregation}=false
    ...                 ${backhaul_mirroring}=false    ${L2HI_L2LO_mirroring}=false
    ...                 ${mirroring_mode}=local        ${number_of_files}=1

    Precondition For BIP Capture with gnbMirroring scripts        cnx_alias=${cnx_alias}    gNB_id=${gNB_id}

    ${mirror_scripts_dico}           Dictionary Get       ${DEF_SCRIPT_MIRROR_LONER_GNB}

    # cmd is : nohup sh /ffs/run/config/scripts/gnbMirroring.sh
    ${cmd}            catenate   nohup sh ${mirror_scripts_dico.remotepath}/${mirror_scripts_dico.script}
    ${parameters1}    catenate   --mirroring_mode=${mirroring_mode} --mirror_abil_1=${mirror_abil_1}
    ...              --mirror_abil_2=${mirror_abil_2} --mirror_abil_3=${mirror_abil_3}
    ...              --l2_l1_bip=${L2_L1_bip} --syscom_mirroring=${syscom_mirroring}
    ...              --carrier_aggregation=${carrier_aggregation} --backhaul_mirroring=${backhaul_mirroring}
    ...              --l2hi_l2lo_mirroring=${L2HI_L2LO_mirroring}
    ...              --filtering=${filtering}

    ${parameters2}    catenate     --use_gulp=${use_gulp} --capturing_time_seconds=${capturing_time_seconds}
    ...                            --number_of_files=${number_of_files} --file_size_mbytes=${filesize_mbytes}

    ${parameters}     run keyword if    'filter'=='default'   set variable    ${parameters1} ${parameters2}
    ...                             ELSE           set variable    ${parameters1} --filter=${filter} ${parameters2}

    SSH gNB wait for connect        cnx_alias=${cnx_alias}         gNB_id=${gNB_id}
    Log        Send command (ssh session)=${cmd} ${parameters}     console=${DEBUG_MODE_CONSOLE}
    ssh.Send Command       command=${cmd} ${parameters}            connection=${cnx_alias}
    ssh.Read Output Until       Filter       timeout=10            connection=${cnx_alias}
    # Sleep    5s
    # Trace capturing process should be triggered    log_prefix=tcpdumpL2L1    connection_alias=${cnx_alias}
    Log        Started gnbMirroring.sh      console=${DEBUG_MODE_CONSOLE}


Start BIP Capture with gnbMirroring scripts Mirroring Mode local
    [Arguments]         ${cnx_alias}       ${gNB_id}=0
    ...                 ${filtering}=off   ${filter}=default
    ...                 ${capturing_time_seconds}=infinite     ${file_size_mbytes}=500
    ...                 ${mirror_abil_1}=true    ${mirror_abil_2}=false    ${mirror_abil_3}=false
    ...                 ${L2_L1_bip}=true
    ${hwtype}   set variable   ${tl.gnbs[${gNB_id}].dus[0].airscale.common_units[0].capacity_units[2].hardware_type}
    ${capacity_unit_addr}   set variable   ${tl.gnbs[${gNB_id}].dus[0].airscale.common_units[0].capacity_units[3].addr}
    #get ABIO 1 slot (1 left: 'fsp-1a", or 5 right: "fsp-5a")
    ${slot}=    run Keyword if    '${hwtype}'=='ABIO' and '${capacity_unit_addr}'=='fsp-5a'   set variable    ${5}
    ...            ELSE IF        '${hwtype}'=='ABIO' and '${capacity_unit_addr}'=='fsp-1a'   set variable    ${1}
    ...            ELSE           set variable    ${1}
    run Keyword if    '${hwtype}'=='ABIO'
    ...                Start ABIO BIP Capture with gnbMirroring scripts Mirroring Mode local
    ...                    cnx_alias=${cnx_alias}     gNB_id=${gNB_id}      slot_abio=${slot}
    ...   ELSE         Start BIP Capture with gnbMirroring scripts
    ...    cnx_alias=${cnx_alias}    gNB_id=${gNB_id}   filtering=${filtering}    filter=${filter}
    ...    capturing_time_seconds=${capturing_time_seconds}     file_size_mbytes=${file_size_mbytes}
    ...    mirror_abil_1=${mirror_abil_1}    mirror_abil_2=${mirror_abil_2}    mirror_abil_3=${mirror_abil_3}
    ...    L2_L1_bip=${L2_L1_bip}      use_gulp=false       syscom_mirroring=false      carrier_aggregation=false
    ...    backhaul_mirroring=false    L2HI_L2LO_mirroring=false      mirroring_mode=local     number_of_files=1


Stop gnbMirroring And Get BIP log
    [Documentation]       Stop tcpdump and gather BIP log
    ...        Arguments :
    ...        local_directory : directory on VM test where pcap will be stored
    ...        local_L1L2_filename : new local pcap name
    ...        gnbMirroring_filtering : 'on' or 'off' (not used in ABIO case)

    [Arguments]     ${cnx_alias}      ${local_directory}     ${local_L1L2_filename}
    ...             ${gnbMirroring_filtering}=off      ${gNB_id}=0
    ${hwtype}   set variable   ${tl.gnbs[${gNB_id}].dus[0].airscale.common_units[0].capacity_units[2].hardware_type}
    run Keyword if    '${hwtype}'=='ABIO'
    ...               Stop ABIO BIP gnbMirroring and retrieve L1L2 log
    ...                     cnx_alias=${cnx_alias}
    ...                     local_directory=${local_directory}
    ...                     local_L1L2_filename=${local_L1L2_filename}
    ...                     gNB_id=${gNB_id}
    ...    ELSE       Stop gnbMirroring and retrieve BIP
    ...                     cnx_alias=${cnx_alias}
    ...                     local_directory=${local_directory}
    ...                     local_L1L2_filename=${local_L1L2_filename}
    ...                     gnbMirroring_filtering=${gnbMirroring_filtering}
    ...                     gNB_id=${gNB_id}


Stop gnbMirroring and retrieve BIP
    [Documentation]       Stop tcpdump and gather BIP log
    ...       1/ Stop the tcpdump process on ASIK
    ...       2/ download L1L2 pcap file (manage only 1 pcap file) from ASIK to local directory
    ...       3/ remove /tmp/tcpdumpL2L1_filtering_*.pcap on ASIK
    ...        Arguments :
    ...        local_directory : directory on VM test where pcap will be stored
    ...        local_L1L2_filename : new local pcap name
    ...        gnbMirroring_filtering : 'on' or 'off' (pcap file extension on gNB, depending if cature with filtering)
    [Arguments]     ${cnx_alias}      ${local_directory}     ${local_L1L2_filename}
    ...             ${gnbMirroring_filtering}=off      ${gNB_id}=0

    Run Keyword And Ignore Error    ssh.disconnect    connection=${cnx_alias}
    SSH gNB wait for connect        cnx_alias=${cnx_alias}     gNB_id=${gNB_id}
    #cmd used previsouly: killall tcpdump, not working on CV374
    ${cmd}     set variable     ps -ef|grep tcpdumpL2L1|grep -v grep|awk '{print $2}'|xargs kill -2
    Log        Stop gnbMirroring.sh with cmd=${cmd}        console=${DEBUG_MODE_CONSOLE}
    ssh.execute       command=${cmd}    connection=${cnx_alias}
    sleep    3
    ssh.Download File    local_path=${local_directory}/${local_L1L2_filename}
    ...                  remote_path=/tmp/tcpdumpL2L1_filtering_${gnbMirroring_filtering}.pcap
    ...                  connection=${cnx_alias}
    ssh.execute     command=rm /tmp/tcpdumpL2L1_filtering_${gnbMirroring_filtering}.pcap     connection=${cnx_alias}
    [Teardown]      Run Keyword And Ignore Error    ssh.disconnect    connection=${cnx_alias}


Start ABIO BIP Capture with gnbMirroring scripts Mirroring Mode local
    [Arguments]         ${cnx_alias}          ${gNB_id}=0        ${slot_abio}=1
    Precondition For BIP Capture with gnbMirroring scripts      cnx_alias=${cnx_alias}    gNB_id=${gNB_id}
    ${mirror_scripts_dico}      Dictionary Get       ${DEF_SCRIPT_MIRROR_LONER_GNB_ABIO}
    SSH gNB wait for connect        cnx_alias=${cnx_alias}         gNB_id=${gNB_id}
    ssh.execute     command=rm /tmp/trace_ABIO.pcap0      connection=${cnx_alias}
    ${cmd}    catenate     nohup sh ${mirror_scripts_dico.remotepath}/${mirror_scripts_dico.script} ${slot_abio}
    ssh.Send Command       command=${cmd}        connection=${cnx_alias}
    Log      Send command (ssh session)=${cmd}   console=${DEBUG_MODE_CONSOLE}
    Wait until keyword succeeds   30s   3s       ssh.Assert File Exists    /tmp/trace_ABIO.pcap0
    ...                                          connection=${cnx_alias}


Stop ABIO BIP gnbMirroring and retrieve L1L2 log
    [Documentation]  Stops the ABIO_BIP_Mirroring.sh script
    ...              and downloads /tmp/trace_ABIO.pcap0 from ASIK to a chosen directory
    ...              then remove /tmp/trace_ABIO.pcap0 on ASIK
    [Arguments]         ${cnx_alias}      ${local_directory}    ${local_L1L2_filename}    ${gNB_id}=0

    SSH gNB wait for connect        cnx_alias=${cnx_alias}     gNB_id=${gNB_id}
    Tcpdump is Alive        connection=${cnx_alias}
    ${cmd}     set variable     ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'|xargs kill -2
    ssh.execute       command=${cmd}    connection=${cnx_alias}
    Log        Stop ABIO_BIP_Mirroring.sh with cmd=${cmd}        console=${DEBUG_MODE_CONSOLE}
    Wait until keyword succeeds   30s   3s     Wait Tcpdump is killed      connection=${cnx_alias}
    Wait until keyword succeeds   30s   3s     ssh.Assert File Exists    /tmp/trace_ABIO.pcap0
    ...                                                     connection=${cnx_alias}
    ssh.Download File    local_path=${local_directory}/${local_L1L2_filename}
    ...                  remote_path=/tmp/trace_ABIO.pcap0        connection=${cnx_alias}
    #ssh.execute     command=rm /tmp/trace_ABIO.pcap0      connection=${cnx_alias}
    [Teardown]      Run Keyword And Ignore Error    ssh.disconnect    connection=${cnx_alias}


Wait Tcpdump is killed
    [Arguments]         ${connection}
    ${check_command}     Set Variable    ps -ef |grep tcpdump|grep -v grep
    ${is_process_killed} =    ssh.Execute    command=${check_command}    connection=${connection}
    Should Be Empty    ${is_process_killed}       msg=tcpdump is not killed


Tcpdump is Alive
    [Arguments]         ${connection}
    ${check_command}     Set Variable    ps -ef |grep tcpdump|grep -v grep
    ${is_process_killed} =    ssh.Execute    command=${check_command}    connection=${connection}
    Should Not Be Empty    ${is_process_killed}      msg=tcpdump is not alive
