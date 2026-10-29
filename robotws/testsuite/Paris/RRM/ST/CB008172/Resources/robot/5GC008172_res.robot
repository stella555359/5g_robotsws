*** Settings ***
Documentation
...     Test Suite Purpose:
...         Perform 5GC008172 feature testing
...     TL Target:
...         gNB Classical
...         Prisma


Resource           ../../../resources/sg_radio_perf/robot/Keywords_UE.robot
Resource           ../../../resources/sg_radio_perf/BIP/capture.robot
Resource           keywords_5GC008172_common.robot
Resource           ${CURDIR}/mcshark.robot
Library            taf.gnb.oam.coam.admin      WITH NAME       admin

*** Variables ***
${pcaps_dir}=    /tmp


*** Keywords ***
Pcaps To Tag
    [Arguments]    ${pcaps_dir}=/tmp/    ${filter}=${None}    ${fields}=''    ${tag}=csv
    [Documentation]    man tshark or thsark --help for more

    ${fields_str}=    Catenate    SEPARATOR=${SPACE}-e${SPACE}    @{fields}
#    ${rm}=    Set Variable    rm ${pcaps_dir}\*.pcap\*.${tag}
    ${rm}=    Set Variable    rm ${pcaps_dir}\/\*.${tag}
    Run    ${rm}
#    ${pcap_files}=    Run    ls ${pcaps_dir}\*.pcap\*
    ${pcap_files}=    Run    ls ${pcaps_dir}\/\*.pcap*
    @{pcap_files_arr}=    Split String    ${pcap_files}
    FOR    ${pcap_file}    IN    @{pcap_files_arr}
	${cmd}=    Catenate    SEPARATOR=${SPACE}
	...    tshark
	...    -r ${pcap_file}
	...    -Y '${filter}'
#	...    -T json
    ...    -T fields
#	...    -e _ws.col.No.
#	...    -e _ws.col.Protocol
#	...    -e _ws.col.Info
#	...    -e _ws.col.Time
	...    -e ${fields_str}
	...    -E header=y
	...    -E separator=,
	...    -E quote=d
	...    -E occurrence=a
	...    > ${pcap_file}.${tag}

	${rc}    OperatingSystem.Run And Return RC    ${cmd}
    END
    [Return]    ${pcaps_dir}

Start ABIO_BIP_Mirroring
    [Arguments]
        ...    ${gNB}=0
        ...    ${abio_slot}=1

    ${cnx}=    ssh.connect_to
    ...    ${tl.gnbs[${gNB}].cu.oam_ssh_connection_details.addr}
    ...    ${tl.gnbs[${gNB}].cu.oam_ssh_connection_details.username}
    ...    ${tl.gnbs[${gNB}].cu.oam_ssh_connection_details.password}
    ...    alias=abio_alias

    Run    rm /tmp/*.pcap*
    ssh.send_command    rm /tmp/*.pcap*    timeout=1    connection=${cnx}
    sleep   2
    ${cmd}=    Catenate
    ...    nohup /ffs/run/config/scripts/ABIO_BIP_Mirroring.sh
    ...    tcpdump_L2L1_ABIO.pcap
    ...    ${abio_slot}
    ...    CV66

    sleep   5

#    ssh.send_command	${cmd}    connection=${cnx}
    ssh.send_command    /ffs/run/config/scripts/gnbMirroring.sh    connection=${cnx}
    sleep   5
    ssh.execute    ls /tmp/*.pcap*    timeout=30s    connection=${cnx}
    ssh.disconnect    connection=${cnx}


Stop Mirroring
    [Documentation]    Stops gnbMirroring.sh/ABIO_BIP_Mirroring.sh by killing tcpdump processes
    ...    Download *.pcap* files to dl_dir

    [Arguments]
        ...    ${gNB}=0
        ...    ${dl_dir}=/tmp/

    ${cnx}=    ssh.connect_to
    ...    ${tl.gnbs[${gNB}].cu.oam_ssh_connection_details.addr}
    ...    ${tl.gnbs[${gNB}].cu.oam_ssh_connection_details.username}
    ...    ${tl.gnbs[${gNB}].cu.oam_ssh_connection_details.password}
    ...    alias=alias

    ssh.execute    ls /tmp/*.pcap*    timeout=30s    connection=${cnx}
#    ssh.send_command    bsh 1:1 "pkill -2 tcpdump"    connection=${cnx}
    ssh.send_command    "pkill -2 tcpdump"    connection=${cnx}
    ssh.execute    ls /tmp/*.pcap*    timeout=30s    connection=${cnx}
    ssh.execute     pkill -2 tcpdump    connection=${cnx}
    ssh.execute    ls /tmp/*.pcap*    timeout=30s    connection=${cnx}
#    ssh.send_command	bsh 1:1 "killall -9 tcpdump"    connection=${cnx}
    ssh.send_command	"killall -9 tcpdump"    connection=${cnx}
    sleep   1
    ${pcap_files}=    ssh.execute    ls /tmp/*.pcap*    timeout=30s    connection=${cnx}
    @{pcap_files_arr}=    Split String    ${pcap_files}
    FOR    ${pcap_file}    IN    @{pcap_files_arr}
       ssh.download_file    remote_path=${pcap_file}
       ...                  local_path=${pcap_file}
       ...                  connection=${cnx}
    END
    ssh.disconnect    connection=${cnx}

    ${cmd}=    Catenate    mv /tmp/*.pcap*    ${dl_dir}
    Run    ${cmd}
    [Return]    ${dl_dir}


My_Suite01_Setup
   keywords_5GC008172_common.TestSuite_8172_Common_Preconditions

My_Suite01_Teardown
    preconditions.TestSuite Basic Teardown      restore_gnb_config=${False}    restore_type=scf     gnb=${source_gnb}

TC_01_SCENARIO_ACT_8172
    [Documentation]
    ...     Test Steps:  Activate 5GC008172 by loading SCF or modifying parameters, wait gNB onair and cells enabled
    ...     (Attach UE, Run UL traffic)
    ...     wait end of period, collect pm files, compare counters in PM file to targets
    ...     note for case Prisma: variable   ${scenario_prisma_file_name} is set in calling TC


    log     Start TC_01_SCENARIO_ACT_8172:         console=${DEBUG_MODE_CONSOLE}

    ###### load swconfig file
    log     Set Swconfig from archive templates:         console=${DEBUG_MODE_CONSOLE}
    keywords_5GC008172_common.Set Swconfig from archive templates
    ...          swconf_name=${swconfig_8172_metric_based}
    ...          gNB=${source_gnb}

    ####### prepare scf
    #log     Prepare_SCF:         console=${DEBUG_MODE_CONSOLE}
    #keywords_5GC008172_common.Update parameter values with delta commissioning for feature activate
    #...          gnb_id=${source_gnb}

    # Connecto to oam
    log     Connecto to oam:         console=${DEBUG_MODE_CONSOLE}
    Wait until Keyword Succeeds  600s   1s
    ...   admin.connect_to   bts_host=192.168.255.129   bts_port=443  username=Nemuadmin   password=nemuuser   name=coam

    #  Perform commissioning
    log     perform_commissioning:         console=${DEBUG_MODE_CONSOLE}
    ${templates_full_path}      config_paths.Get Template Fullname      Configuration_scf_MRBTS-66_8172_act.xml
    log     SCF template fullpath=${templates_full_path}        console=${DEBUG_MODE_CONSOLE}
    admin.perform_commissioning
    ...	   scf_file=${templates_full_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...	   timeout=900
    ...    connection=coam

    admin.teardown    connection=coam

    log     Start ABIO_BIP_Mirroring    console=${DEBUG_MODE_CONSOLE}

    Start ABIO_BIP_Mirroring
    ...    gNB=0
    ...    abio_slot=1

    #  Perform parameter recommissioning
    #perform_parameter_recommissioning
    #...	   dist_name=MRBTS-${MRBTS}/NRBTS-${NRBTS}
    #...    parameter=actSpatialStreamPooling
    #...    operation=update
    #...    value=${True}
    #...    skip_parameter_relation_errors=True
    #...    should_activate=True
    #...    connection=coam
    #admin.teardown    connection=coam


    log     wait gNB to be onair state and cells enabled:         console=${DEBUG_MODE_CONSOLE}
    keywords_5GC008172_common.wait gNB to be onair state and cells enabled     gnb_id=${source_gnb}

    log     Stop Mirroring    console=${DEBUG_MODE_CONSOLE}
    Stop Mirroring
    ...    gNB=0
    ...    dl_dir=/tmp

     # conversion to csv with filtering
     @{fields}=    Create List
    ...    DlCell_SetupReq_t.l1SubpoolId
    ...    UlCell_SetupReq_t.l1SubpoolId
    ...    DlCell_SetupReq_t.dlSubcellType
    ...    UlCell_SetupReq_t.ulSubcellType
    log    Pcaps To Tag            console=${DEBUG_MODE_CONSOLE}
    Pcaps To Tag
    ...    pcaps_dir=${pcaps_dir}
    ...    filter=dlcell_setupreq \|\|\ ulcell_setupreq
    ...    fields=@{fields}
    ...    tag=csv

    # Analyze UL csv files
    ${pcap_files}=    Run    ls /tmp/*.csv
    ${pcap_files_arr}=    Split String    ${pcap_files}
    FOR    ${pcap_file}    IN    @{pcap_files_arr}
        ${cmd}=    Catenate
        ...    cat
        ...    ${pcap_file}
        ...    | grep ',"0",,"1"'| wc -l
        # ${nb_UL}=   Run     cat /tmp/L1L2_TL08_20211102_120415_off.pcap03.csv | grep ',"0",,"1"'| wc -l
        ${nb_UL}=   Run    ${cmd}
        Run Keyword If    '${nb_UL}' == '3'    Exit For Loop
    END
    Should Be True  ${nb_UL} == 3

    # Analyze DL csv files
    FOR    ${pcap_file}    IN    @{pcap_files_arr}
        ${cmd}=    Catenate
        ...    cat
        ...    ${pcap_file}
        ...    | grep '"0",,"1",'| wc -l
        # ${nb_DL}=   Run     cat /tmp/L1L2_TL08_20211102_120415_off.pcap03.csv | grep '"0",,"1",'| wc -l
        ${nb_DL}=   Run    ${cmd}
        Run Keyword If    '${nb_DL}' == '6'    Exit For Loop
    END
    Should Be True  ${nb_DL} == 6

######################################################################################################################

TC_02_SCENARIO_DEACT_8172
    [Documentation]
    ...     Test Steps:  Deactivate 5GC008172 by loading SCF or modifying parameters, wait gNB onair and cells enabled
    ...     (Attach UE, Run UL traffic)
    ...     wait end of period, collect pm files, compare counters in PM file to targets
    ...     note for case Prisma: variable   ${scenario_prisma_file_name} is set in calling TC


    log     Start TC_02_SCENARIO_DEACT_8172:         console=${DEBUG_MODE_CONSOLE}

    ###### load swconfig file with feature deactivate
    log     Set Swconfig from archive templates:         console=${DEBUG_MODE_CONSOLE}
    keywords_5GC008172_common.Set Swconfig from archive templates
    ...          swconf_name=${swconfig_8172_metric_based}
    ...          gNB=${source_gnb}

    ####### prepare scf with required param values
    #log     Prepare SCF:         console=${DEBUG_MODE_CONSOLE}
    #keywords_5GC008172_common.Update parameter values with delta commissioning for feature deactivate
    #...          gnb_id=${source_gnb}

    # Connecto to oam
    log     Connecto to oam:         console=${DEBUG_MODE_CONSOLE}
    Wait until Keyword Succeeds  600s   1s
    ...   admin.connect_to   bts_host=192.168.255.129   bts_port=443  username=Nemuadmin   password=nemuuser   name=coam

    #  Perform commissioning
    log     perform_commissioning:        console=${DEBUG_MODE_CONSOLE}
    ${templates_full_path}      config_paths.Get Template Fullname      Configuration_scf_MRBTS-66_8172_deact.xml
    log     SCF template fullpath=${templates_full_path}        console=${DEBUG_MODE_CONSOLE}
    admin.perform_commissioning
    ...	   scf_file=${templates_full_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...	   timeout=900
    ...    connection=coam
    admin.teardown    connection=coam


    #  Perform parameter recommissioning
    #log     perform_parameter_recommissioning:
    #MRBTS-${MRBTS}/NRBTS-${NRBTS}/actSpatialStreamPooling        console=${DEBUG_MODE_CONSOLE}
    #perform_parameter_recommissioning
    #...	   dist_name=MRBTS-${MRBTS}/NRBTS-${NRBTS}
    #...    parameter=actSpatialStreamPooling
    #...    operation=update
    #...    value=${False}
    #...    skip_parameter_relation_errors=True
    #...    should_activate=True
    #...    connection=coam
    #admin.teardown    connection=coam


    #log     wait gNB to be onair state and cells enabled:         console=${DEBUG_MODE_CONSOLE}
    #keywords_5GC008172_common.wait gNB to be onair state and cells enabled     gnb_id=${source_gnb}
    log     Start ABIO_BIP_Mirroring    console=${DEBUG_MODE_CONSOLE}

    Start ABIO_BIP_Mirroring
    ...    gNB=0
    ...    abio_slot=1

    #log     wait gNB to be onair state and cells enabled:         console=${DEBUG_MODE_CONSOLE}
    #keywords_5GC008172_common.wait gNB to be onair state and cells enabled     gnb_id=${source_gnb}
    sleep   1000
    log     Stop Mirroring    console=${DEBUG_MODE_CONSOLE}
    Stop Mirroring
    ...    gNB=0
    ...    dl_dir=/tmp

    # conversion to csv with filtering
     @{fields}=    Create List
    ...    DlCell_SetupReq_t.l1SubpoolId
    ...    UlCell_SetupReq_t.l1SubpoolId
    ...    DlCell_SetupReq_t.dlSubcellType
    ...    UlCell_SetupReq_t.ulSubcellType
    log    Pcaps To Tag            console=${DEBUG_MODE_CONSOLE}
    Pcaps To Tag
    ...    pcaps_dir=${pcaps_dir}
    ...    filter=dlcell_setupreq \|\|\ ulcell_setupreq
    ...    fields=@{fields}
    ...    tag=csv

    # Analyze UL csv files
    ${pcap_files}=    Run    ls /tmp/*.csv
    ${pcap_files_arr}=    Split String    ${pcap_files}
    FOR    ${pcap_file}    IN    @{pcap_files_arr}
        ${cmd}=    Catenate
        ...    cat
        ...    ${pcap_file}
        ...    | grep ',"0",,"1"'| wc -l
        # 1 UlCell_SetupReq per cell. Count number of UlCell_SetupReq_t.l1SubpoolId=0 and UlCell_SetupReq_t.ulSubcellType = 1 --> shall be 2
        #${nb_UL}=   Run     cat /tmp/L1L2_TL08_20211102_120415_off.pcap03.csv | grep ',"0",,"1"'| wc -l
        ${nb_UL}=   Run    ${cmd}
        Run Keyword If    '${nb_UL}' == '2'    Exit For Loop
    END
    Should Be True  ${nb_UL} == 2

    # Analyze DL csv files
    FOR    ${pcap_file}    IN    @{pcap_files_arr}
        ${cmd}=    Catenate
        ...    cat
        ...    ${pcap_file}
        ...    | grep '"0",,"1",'| wc -l
        # 2 DlCell_SetupReq per cell. Count number of DlCell_SetupReq_t.l1SubpoolId=0 and DlCell_SetupReq_t.dlSubcellType = 1 --> shall be 4
        #${nb_DL}=   Run     cat /tmp/L1L2_TL08_20211102_120415_off.pcap03.csv | grep '"0",,"1",'| wc -l
        ${nb_DL}=   Run    ${cmd}
        Run Keyword If    '${nb_DL}' == '4'    Exit For Loop
    END
    Should Be True  ${nb_DL} == 4

#######################################################################################################

TC_tempo
#    keywords_5GC008172_common.Set Swconfig from archive templates
#    ...          swconf_name=${swconfig_8172_metric_based}
#    ...          gNB=${source_gnb}

    #keywords_5GC008172_common.Update parameter values with delta commissioning for feature activate
    #...          gnb_id=${source_gnb}
    Wait until Keyword Succeeds  600s   1s
    ...   admin.connect_to   bts_host=192.168.255.129   bts_port=443  username=Nemuadmin   password=nemuuser   name=coam
    ${templates_full_path}      config_paths.Get Template Fullname      Configuration_scf_MRBTS-66_8172_act.xml
#    admin.perform_commissioning
#    ...	   scf_file=${templates_full_path}
#    ...    skip_parameter_relation_errors=True
#    ...    should_activate=True
#    ...	   timeout=900
#    ...    connection=coam
    admin.teardown    connection=coam

    #  Perform parameter recommissioning
    #log     perform_parameter_recommissioning: MRBTS-${MRBTS}/NRBTS-${NRBTS}/actSpatialStreamPooling        console=${DEBUG_MODE_CONSOLE}
    #perform_parameter_recommissioning
    #...	   dist_name=MRBTS-${MRBTS}/NRBTS-${NRBTS}
    #...    parameter=actSpatialStreamPooling
    #...    operation=update
    #...    value=${True}
    #...    skip_parameter_relation_errors=True
    #...    should_activate=True
    #...    connection=coam
    #admin.teardown    connection=coam

    keywords_5GC008172_common.wait gNB to be onair state and cells enabled     gnb_id=${source_gnb}
    keywords_5GC008172_common.Run Call and Traffic on UE List and save PM files
    ...          list_of_ues=${UE_LIST}
    ...          traffic_direction=ULDL
    ...          traffic_duration=${ul_time_s}
    ...          tput_dl=${dl_throughput}
    ...          tput_ul=${ul_throughput}
    ...          gNB=${source_gnb}
    ${pm_file_period_n2}=       keywords_5GC008172_common.Get N-1 PERIOD FILENAME

    #keywords_5GC008172_common.Compare Counters in PM file to Targets
    #...       pmfile=${pm_file_period_n2}
    #...       target_M55601C00002=900
    #...       target_M55315C03009=100
    #...       target_M55335C03003=0
    #...       target_M55308C10002=0
    #...       target_M55308C18001=0
    #...       target_M55310C01009=0
    #...       target_M55335C03008=0
    #...       target_M55308C10001=0
    #...       target_M55308C17001=0

#    ${new_version}        mcshark.Check MCShark Version
#    ...                       sw_version=SBTS00_ENB_9999_210914_000003

#    log    need_luashark_installed            console=${DEBUG_MODE_CONSOLE}
#    need_luashark_installed(method)


#    ${pdmlFile}          analyzer.pcap_to_pdml       pcapFile=/tmp/trace_ABIO.pcap0

# How to get the path containing DlCell_SetupReq/dlSubCellType ????
# How to count the number of dlSubCellType=C4 in DlCell_SetupReq ???? : count_path looks not being matched

#    log    count_path            console=${DEBUG_MODE_CONSOLE}
#    ${count}                        analyzer.count_path
#    ...                             pdmlFile=${pdmlFile}
#    ...                             filter=DlCell_SetupReq
#    ...                             packetName=DlCell_SetupReq
#    ...                             path=${path}
#    should be equal as integers     ${count}
#    log    count_path containing DlCell_SetupReq=${count}            console=${DEBUG_MODE_CONSOLE}

# 8172 activated : count_path containing DlCell_SetupReq should be 6
# 8172 deactivated : count_path containing DlCell_SetupReq should be 4
# How to compare count_path with value=4 or 6 : if {count]==4 or 6

#    log    check_field            console=${DEBUG_MODE_CONSOLE}
#    analyzer.check_field
#    ...           pdmlFile=${pdmlFile}
#    ...           packetName=DlCell_SetupReq
#    ...           fieldName=dlSubCellType
#    ...           value=C4
#    ...           test="=="
