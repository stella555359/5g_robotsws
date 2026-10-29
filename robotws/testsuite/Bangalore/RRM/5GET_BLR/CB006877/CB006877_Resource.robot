*** Settings ***

Documentation    :copyright: Nokia


Variables    ta5g_global_var
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../resources/robot/TTI_Traces.robot
Library           ../resources/python/CPRT_Capture.py
Resource         ../resources/NPS/SWENG/robot/PacketSearch_mcshark.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../resources/robot/BBpooling_MuMIMO.robot
Library          ../resources/python/avg_dl_data.py
Library          ta5g_commissioning
Library          ta5g_pm_counters
Library          String
Library         taf.ul.ue.sim.env_setup

*** Variables ***
@{pathlist}    startPrb
${filter}   ${EMPTY}
${startPacket}   1
${endPacket}   1000
${num_of_prbs_using_lower_pcsi}   0
${num_of_prbs_using_upper_pcsi}   0
${num_of_prbs_lower_pcsi}   0
${count_of_prbs_using_lower_pcsi}   0


*** Keywords ***
Start Default Logging Gnb ASIL_ABIO
    Start Log   btslog

Stop Default Logging Gnb ASIL_ABIO
    Stop Log   btslog    snapshot    sosreport

Modify IPHY File And Send to Airphone Custom
    [Arguments]    ${iphy_path}
    ${RRU_type_list}    Get RRU Type From Local IPHY XML Custom   ${iphy_path}
    FOR    ${RRU_type}    IN    @{RRU_type_list}
        ${RRU_Version}    Get RRU Version From TargetBD File Custom    ${RRU_type}    ${OUTPUT_DIR}
        Modify RRU Version Of IPHY XML Custom    ${iphy_path}    ${RRU_type[0]}    ${RRU_Version}
    END
    Send IPHY XML To Airphone custom    ${iphy_path}

Get RRU Type From Local IPHY XML Custom
    [Arguments]    ${iphy_path}
    ${content}=    OperatingSystem.Get File    path=${iphy_path}
    ${x}  Set Variable  <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>
    @{RRU_type_for_version}    String.Get Regexp Matches    ${content}    ${x}    RRU_type    Ecpri_tag
    @{RRU_type_list}    String.Get Regexp Matches    ${content}    ${x}    RRU_type
    Set Suite Variable    ${RRU_TYPE_LIST}    ${RRU_type_list}
    Set Suite Variable    ${RRU_TYPE}    ${RRU_type_list[0]}
    Log To Console   RRU Type List from local iphy.xml: ${RRU_type_list}
     Log To Console    RRU Type from local iphy.xml: ${RRU_TYPE}
    [Return]    @{RRU_type_for_version}

Get RRU Version From TargetBD File Custom
    [Arguments]    ${RRU_type}    ${save_dir}
    ${RRU_type}=    Set Variable If    "${RRU_type[0]}"=="AAHF"    AAHF_C1
    ...    "${RRU_type[0]}"=="AHEGG"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEHC"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEQE"    ${RRU_type[0]}_E1
    ...    "${RRU_type[0]}"=="AEUD"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AWEUA"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AHLOA"    ${RRU_type[0]}
    ...    "${RRU_type[1]}"=="ecpri"    ${RRU_type[0]}_E1
    ...    ${RRU_type[0]}
    OperatingSystem.Run
    ...    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/TargetBD_SBTS*.xml ${save_dir}/TargetBD.xml
    OperatingSystem.Should Exist    ${save_dir}/TargetBD.xml
    ${content}=    OperatingSystem.Get File    path=${save_dir}/TargetBD.xml
    ${check_point_regexp}    Set Variable    resourceBuildKey="LTX_${RRU_type}".*resourceSWVersion="(?P<RRU_Version>.*)"
    @{RRU_Version}    String.Get Regexp Matches    ${content}    ${check_point_regexp}    RRU_Version
    [Return]    ${RRU_Version}[0]

Modify RRU Version Of IPHY XML Custom
    [Arguments]    ${iphy_path}    ${RRU_type}    ${RRU_Version}
    ${content}    OperatingSystem.Get File    path=${iphy_path}
    ${bldVersion}=    String.Get Regexp Matches    ${content}
    ...    <cardName>${RRU_type}<\/cardName>[\\s\\S]*?<bldVersion>(?P<bldVersion>.*)<\/bldVersion>
    ...    bldVersion
    Log Many    ${bldVersion[0]}    ${RRU_Version}
    ${new_content}    String.Replace String    ${content}    ${bldVersion[0]}    ${RRU_Version}
    Log To Console    ${new_content}
    OperatingSystem.Create File    path=${iphy_path}    content=${new_content}

Prepare TL with config files
     Log To Console    Configure ENV with SCFC/AP.xml/LUA
     add gnb configuration    scfc=${SCFC}
     add simulator  sim_type=airphone  config=${AP_XML}
#     add 5gc  config=${BASIC_CFG}  edaemon_ports=10000
     configure environment       rmod_detection_timeout=300s
     Log To Console    After Configure ENV

Send IPHY XML To Airphone custom
    [Arguments]    ${iphy_path}
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} rm -f /ffs/run/simmode/*.xml
    Should Be Equal As Integers    ${rc}    0
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy_modify.xml
    Should Be Equal As Integers    ${rc}    0
    ${soft_link}=    Set Variable    ln -fs /ffs/run/simmode/iphy_modify.xml /ffs/run/simmode/iphy.xml
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} ${soft_link}
    Should Be Equal As Integers    ${rc}    0

Load CFG Config And Verify cell setup in Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}   ${no_of_cells}
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    ${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    Check gNB Airscale is Ready - ${BBoard_Type}

    Log To console     loading cfg file
    Start Log   btslog    cprt
    Start WTS Using WTS_Runner      ${wts_cfg_file}
    FOR     ${i}    IN RANGE   1   ${no_of_cells}+1
        Wait Until Keyword Succeeds     200s    5s	Check MIB_SIB status of GNB cell   ${i}
    END
    ${cprt_log}     Stop Log  cprt  test_scenario=cellsetup
    set suite variable    ${cprt_log}
    ${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup_sys
    set suite variable    ${cell_sys_log}


Load CFG Config And Verify cell setup in Capture CPRT Traces ASOH
    [Arguments]    ${wts_cfg_file}   ${no_of_cells}
    Fetch board type
    Configure UTE ETH3 IPs
    ${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready ASOH - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    ${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    Check gNB Airscale is Ready ASOH - ${BBoard_Type}

    Log To console     loading cfg file
    Start Log   btslog
    CPRT Monitoring Start ASOH
    Start WTS Using WTS_Runner      ${wts_cfg_file}
    FOR     ${i}    IN RANGE   1   ${no_of_cells}+1
        Wait Until Keyword Succeeds     200s    5s	Check MIB_SIB status of GNB cell   ${i}
    END
    CPRT Monitoring Stop Collect ASOH    ${LOG_PATH}
    set suite variable    ${LOG_PATH}
    ${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup_sys
    set suite variable    ${cell_sys_log}

Load CFG Config And Verify cell setup in Capture CPRT Traces ASOH TC42
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    Configure UTE ETH3 IPs
    ${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready ASOH - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    ${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    Check gNB Airscale is Ready ASOH - ${BBoard_Type}

    Log To console     loading cfg file
    Start Log   btslog
    CPRT Monitoring Start ASOH
    Start WTS Using WTS_Runner      ${wts_cfg_file}
    CPRT Monitoring Stop Collect ASOH    ${LOG_PATH}
    Move File       ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap      ${LOG_PATH}/${file_name}
    Move File       ${LOG_PATH}/External_NODECPRT_GNB.pcap     ${LOG_PATH}/External_NODECPRT_GNB_cellsetup.pcap
    set suite variable    ${LOG_PATH}
    ${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup_sys
    set suite variable    ${cell_sys_log}

Configure UTE ETH3 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3

Check gNB Bulid
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${GNB_SW_VERSION}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    Set Suite Variable    ${GNB_SW_VERSION}
    ${Branch_22R1}    Run Keyword and Return Status   Should Contain    ${GNB_SW_VERSION}     22R1
    Set Suite variable   ${Branch_22R1}

get matched packet in filtered list
    [Arguments]                     ${message}          ${pdmlFile}     ${FIELDS_name}
    [Documentation]                 returns a list of packets for matched packet
    @{listpacketMatch}              analyzer.get_match_from_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=${message}
    ...                             path=${FIELDS_name}
    ...                             startPacket=1
    ...                             endPacket=100
    [return]          @{listpacketMatch}

get gbr packet in filtered list
    [Arguments]                     ${message}          ${pdmlFile}     ${FIELDS_name}   ${startPacket}   ${endPacket}
    [Documentation]                 returns a list of packets for matched packet
    @{listpacketMatch}              analyzer.get_match_from_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=${message}
    ...                             path=${FIELDS_name}
    ...                             startPacket=${startPacket}
    ...                             endPacket=${endPacket}
    [return]          @{listpacketMatch}

Verify InitialContextSetupFailure in pcap
#    [Arguments]      ${logpath}       ${filter_req}
    [Arguments]      ${filter_req}
    [Documentation]      this KW Verifies the InitialContextSetupFailure captured in CPRT logs
    log to console       Verifying InitialContextSetupFailure In captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${cprt_log}[cprt]/NODECPRT_GNB.pcap   ${filter_req}

Verify gbrload in pcap
    [Arguments]      ${logpath}
    [Documentation]      this KW Verifies the GBR DL UL load captured in CPRT logs
    log to console       Verifying the GBR DL UL load In captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}[cprt]/NODECPRT_GNB.pcap   ${gbr_load}
    @{list_of_values}    get gbr packet in filtered list     itf_l2_ps_cell_cellulgbrloadind
    ...  ${pdmlFile}   itf_l2_ps_cell_CellUlGbrLoadInd_t   -2   -1
    ${total_ulgbr_load}   get length   ${list_of_values}
    ${total_ulgbr_load}=  evaluate    ${total_ulgbr_load} - ${1}
    FOR      ${ul_gbr_load}     IN      ${list_of_values}[${total_ulgbr_load}]
        ${gbr_ul_load}               Get Value In Packet Match
        ...                   packetMatch=${ul_gbr_load}
        ...                   field=gbrTdLoad
        ${gbr_ul_load}=    convert to integer      ${gbr_ul_load}
    END
    @{list_of_values}    get gbr packet in filtered list    itf_l2_ps_cell_celldlgbrloadind
    ...     ${pdmlFile}   itf_l2_ps_cell_CellDlGbrLoadInd_t   -2   -1
    ${total_dlgbr_load}   get length   ${list_of_values}
    ${total_dlgbr_load}=  evaluate    ${total_dlgbr_load} - ${1}
    FOR      ${dl_gbr_load}     IN      ${list_of_values}[${total_dlgbr_load}]
        ${gbr_dl_load}               Get Value In Packet Match
        ...                   packetMatch=${dl_gbr_load}
        ...                   field=gbrTdLoad
        ${gbr_dl_load}=    convert to integer      ${gbr_dl_load}
    END
    [Return]    ${gbr_ul_load}    ${gbr_dl_load}

Verify Dynamic PUSCH in CellSetup
    [Arguments]      ${logpath}       ${filter_req}
    [Documentation]      this KW Verifies the  longPucchStartDynPuschPrb and longPucchNumDynPuschPrb in cellSetupreq
    log to console       Verifying longPucchStartDynPuschPrb and longPucchNumDynPuschPrb in cellSetupreq
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${longPucchStartDynPuschPrb}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=.*longPucchStartDynPuschPrb_item$
    ...                                                endPacket=${2}
    ${longPucchNumDynPuschPrb}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=.*longPucchNumDynPuschPrb_item$
    ...                                                endPacket=${2}
    ${longPucchStartPuschPrb}      analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
    ...                                        kind=show
    ...                                        path=.*longPucchStartPuschPrb_item$
    ...                                        endPacket=1
    ${longPucchNumPuschPrb}        analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
    ...                                        kind=show
    ...                                        path=.*longPucchNumPuschPrb_item$
    ...                                        endPacket=1
    Should Be True    ${longPucchStartDynPuschPrb}<${longPucchStartPuschPrb}[1]
    Should Be True    ${longPucchNumDynPuschPrb}>${longPucchNumPuschPrb}[1]
    [Return]    ${longPucchStartPuschPrb}[1]    ${longPucchStartDynPuschPrb}

Verify UL PUSCH PRBs In CellSetupReq
    [Arguments]      ${cprt_log}
    [Documentation]      this KW Verifies the longPucchStartDynPuschPrb & longPucchNumDynPuschPrb In CellSetupReq
    log to console       Verifying the longPucchStartDynPuschPrb & longPucchNumDynPuschPrb In CellSetupReq
    ${pdmlFile} =    Get filtered PDML file from pcap     ${cprt_log}[cprt]/NODECPRT_GNB.pcap   sctp
    @{list_of_values}    get matched packet in filtered list     itf_l2_ps_cell_cellsetupreq    ${pdmlFile}   longPucchStartPuschPrb_item
    FOR      ${PuschPrb}     IN      ${list_of_values}[0]
        ${StartPuschPrb}               Get Value In Packet Match
        ...                   packetMatch=${PuschPrb}
        ...                   field=longPucchStartPuschPrb_item
        ${StartPuschPrb}=    convert to integer      ${StartPuschPrb}
    END
    @{list_of_values}    get matched packet in filtered list     itf_l2_ps_cell_cellsetupreq    ${pdmlFile}   longPucchNumPuschPrb_item
    FOR      ${PuschPrb}     IN      ${list_of_values}[0]
        ${NumPuschPrb}               Get Value In Packet Match
        ...                   packetMatch=${PuschPrb}
        ...                   field=longPucchNumPuschPrb_item
        ${NumPuschPrb}=    convert to integer      ${NumPuschPrb}
    END
    @{list_of_values}    get matched packet in filtered list     itf_l2_ps_cell_cellsetupreq    ${pdmlFile}   longPucchStartDynPuschPrb_item
    FOR      ${PuschPrb}     IN      ${list_of_values}[0]
        ${StartDynPuschPrb}               Get Value In Packet Match
        ...                   packetMatch=${PuschPrb}
        ...                   field=longPucchStartDynPuschPrb_item
        ${StartDynPuschPrb}=    convert to integer      ${StartDynPuschPrb}
    END
    @{list_of_values}    get matched packet in filtered list     itf_l2_ps_cell_cellsetupreq    ${pdmlFile}   longPucchNumDynPuschPrb_item
    FOR      ${PuschPrb}     IN      ${list_of_values}[0]
        ${NumDynPuschPrb}               Get Value In Packet Match
        ...                   packetMatch=${PuschPrb}
        ...                   field=longPucchNumDynPuschPrb_item
        ${NumDynPuschPrb}=    convert to integer      ${NumDynPuschPrb}
    END
    Run Keyword and continue on Failure     should be true  ${StartDynPuschPrb} < ${StartPuschPrb}
    Run Keyword and continue on Failure     should be true  ${NumDynPuschPrb} > ${NumPuschPrb}
    [Return]      ${StartPuschPrb}    ${StartDynPuschPrb}

Verify UL PUSCH PRBs In CellSetupReq ASOH
    [Arguments]      ${LOG_PATH}
    [Documentation]      this KW Verifies the longPucchStartDynPuschPrb & longPucchNumDynPuschPrb In CellSetupReq
    log to console       Verifying the longPucchStartDynPuschPrb & longPucchNumDynPuschPrb In CellSetupReq
    ${pdmlFile} =    Get filtered PDML file from pcap     ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap   itf_l2_ps_cell_cellsetupreq
    @{list_of_values}    get matched packet in filtered list     itf_l2_ps_cell_cellsetupreq    ${pdmlFile}   longPucchStartPuschPrb_item
    FOR      ${PuschPrb}     IN      ${list_of_values}[0]
        ${StartPuschPrb}               Get Value In Packet Match
        ...                   packetMatch=${PuschPrb}
        ...                   field=longPucchStartPuschPrb_item
        ${StartPuschPrb}=    convert to integer      ${StartPuschPrb}
    END
    @{list_of_values}    get matched packet in filtered list     itf_l2_ps_cell_cellsetupreq    ${pdmlFile}   longPucchNumPuschPrb_item
    FOR      ${PuschPrb}     IN      ${list_of_values}[0]
        ${NumPuschPrb}               Get Value In Packet Match
        ...                   packetMatch=${PuschPrb}
        ...                   field=longPucchNumPuschPrb_item
        ${NumPuschPrb}=    convert to integer      ${NumPuschPrb}
    END
    @{list_of_values}    get matched packet in filtered list     itf_l2_ps_cell_cellsetupreq    ${pdmlFile}   longPucchStartDynPuschPrb_item
    FOR      ${PuschPrb}     IN      ${list_of_values}[0]
        ${StartDynPuschPrb}               Get Value In Packet Match
        ...                   packetMatch=${PuschPrb}
        ...                   field=longPucchStartDynPuschPrb_item
        ${StartDynPuschPrb}=    convert to integer      ${StartDynPuschPrb}
    END
    @{list_of_values}    get matched packet in filtered list     itf_l2_ps_cell_cellsetupreq    ${pdmlFile}   longPucchNumDynPuschPrb_item
    FOR      ${PuschPrb}     IN      ${list_of_values}[0]
        ${NumDynPuschPrb}               Get Value In Packet Match
        ...                   packetMatch=${PuschPrb}
        ...                   field=longPucchNumDynPuschPrb_item
        ${NumDynPuschPrb}=    convert to integer      ${NumDynPuschPrb}
    END
    Run Keyword and continue on Failure     should be true  ${StartDynPuschPrb} < ${StartPuschPrb}
    Run Keyword and continue on Failure     should be true  ${NumDynPuschPrb} > ${NumPuschPrb}
    [Return]      ${StartPuschPrb}    ${StartDynPuschPrb}


Verify Ul PUSCH PRBs In CellSetup for PRB Blank
    [Arguments]
    ...      ${pcapFile}   ${cell_id}    ${bwp_id}
    ${pdmlFile}=         Get filtered PDML file from pcap        ${pcapFile}    sctp
    ${pathlist}    Create List     longPucchStartPuschPrb_item    longPucchNumPuschPrb_item
    ...      longPucchStartDynPuschPrb_item   longPucchNumDynPuschPrb_item
    ...      itf_l2_ps_cell_CellSetupReq_t.lcrId   itf_l2_ps_cell_Bwp.bwpType
    @{list_of_values}    Get Packet Match List     ${pdmlFile}     itf_l2_ps_cell_cellsetupreq
    ...                  ${pathlist}
    FOR   ${prb_packet}     IN      @{list_of_values}
            ${list}   Get Value in Match Packet for PUCCH PRB Blank    ${prb_packet}   ${cell_id}    ${bwp_id}
            Exit For Loop IF   ${list[4]} == ${cell_id}
    END
#   List 0, 1, 2, 3 ==> StaticStartPuschPrb, StaticNumPuschPrb, DynStartPuschPrb ,DynNumPuschPrb
#   Condition is  ${StartDynPuschPrb} < ${StartPuschPrb}   and ${NumDynPuschPrb} > ${NumPuschPrb}
    Run Keyword and continue on Failure    should be true  ${list[2]} < ${list[0]}
    Run Keyword and continue on Failure    should be true  ${list[3]} > ${list[1]}
    [Return]      ${list[0]}    ${list[2]}

Verify Ul PUSCH PRBs In CellSetup for PRB Blank ASOH
    [Arguments]
    ...      ${pcapFile}   ${cell_id}    ${bwp_id}
    ${pdmlFile}=         Get filtered PDML file from pcap        ${pcapFile}    syscom
    ${pathlist}    Create List     longPucchStartPuschPrb_item    longPucchNumPuschPrb_item
    ...      longPucchStartDynPuschPrb_item   longPucchNumDynPuschPrb_item
    ...      itf_l2_ps_cell_CellSetupReq_t.lcrId   itf_l2_ps_cell_Bwp.bwpType
    @{list_of_values}    Get Packet Match List     ${pdmlFile}     itf_l2_ps_cell_cellsetupreq
    ...                  ${pathlist}
    FOR   ${prb_packet}     IN      @{list_of_values}
            ${list}   Get Value in Match Packet for PUCCH PRB Blank    ${prb_packet}   ${cell_id}    ${bwp_id}
            Exit For Loop IF   ${list[4]} == ${cell_id}
    END
#   List 0, 1, 2, 3 ==> StaticStartPuschPrb, StaticNumPuschPrb, DynStartPuschPrb ,DynNumPuschPrb
#   Condition is  ${StartDynPuschPrb} < ${StartPuschPrb}   and ${NumDynPuschPrb} > ${NumPuschPrb}
    Run Keyword and continue on Failure    should be true  ${list[2]} < ${list[0]}
    Run Keyword and continue on Failure    should be true  ${list[3]} > ${list[1]}
    [Return]      ${list[0]}    ${list[2]}

Get Value in Match Packet for PUCCH PRB Blank
    [Arguments]    ${packetMatch}   ${cell_id}     ${bwp_id}
    @{listPath}                     Get Dictionary Keys                 ${packetMatch.fields}
    ${packet_bwpid}=    Set Variable   'None'
    ${packet_DynStartPuschPrb}=     Set Variable    'None'
    ${packet_DynNumPuschPrb}=     Set Variable      'None'
    ${packet_StaticStartPuschPrb}=    Set Variable   'None'
    ${packet_StaticNumPuschPrb}=     Set Variable    'None'
    FOR   ${path}  IN   @{listPath}
        ${fieldName}            Get Field Name From Path            ${path}
        ${packet_lcrid}=        Set Variable if     '${fieldName}'=='lcrId'    ${packetMatch.fields['${path}'].show}   ${packet_lcrid}
        ${packet_bwpid}=        Set Variable if     '${fieldName}'=='bwpType'   ${packetMatch.fields['${path}'].show}   ${packet_bwpid}
        ${packet_DynNumPuschPrb}=     Set Variable if     '${fieldName}'=='bwpType'   None
        ${packet_StaticStartPuschPrb}=    Set Variable if     '${fieldName}'=='longPucchStartPuschPrb_item'
        ...      ${packetMatch.fields['${path}'].show}    ${packet_StaticStartPuschPrb}
        ${packet_StaticNumPuschPrb}=     Set Variable if     '${fieldName}'=='longPucchNumPuschPrb_item'
        ...      ${packetMatch.fields['${path}'].show}   ${packet_StaticNumPuschPrb}
        ${packet_DynStartPuschPrb}=    Set Variable if     '${fieldName}'=='longPucchStartDynPuschPrb_item'
        ...      ${packetMatch.fields['${path}'].show}   ${packet_DynStartPuschPrb}
        ${packet_DynNumPuschPrb}=     Set Variable if     '${fieldName}'=='longPucchNumDynPuschPrb_item'
        ...      ${packetMatch.fields['${path}'].show}      ${packet_DynNumPuschPrb}
        ${condition_flag}     Run Keyword if
        ...      ${packet_lcrid} == ${cell_id} and ${packet_bwpid} == ${bwp_id} and ${packet_DynNumPuschPrb} != None
        ...      Set Variable  TRUE
        Exit For Loop IF      '${condition_flag}' == 'TRUE'
    END
    [Return]   ${packet_StaticStartPuschPrb}   ${packet_StaticNumPuschPrb}   ${packet_DynStartPuschPrb}
    ...   ${packet_DynNumPuschPrb}   ${packet_lcrid}


Verify prbs in uldata_puschreceivereq
    [Arguments]
    ...      ${pcapFile}   ${start_prb}   ${start_dprb}   ${cell_subgroup_id}
    [Documentation]
    ...     Verifies start prb and number of prbs value used in uldata_puschreceivereq in provided pcap traces
    ${pdmlFile}=         Get filtered PDML file from pcap        ${pcapFile}     (uldata_puschreceivereq) && (3gpp.subcellid == ${cell_subgroup_id})
    @{list_of_values}    Get Packet Match List     ${pdmlFile}   uldata_puschreceivereq    ${pathlist}
    ...                  ${filter}   ${startPacket}   ${endPacket}
    ${total_uldata_pusch}   get length   ${list_of_values}
    FOR      ${prb_packet}     IN      @{list_of_values}
        ${num_of_prbs_using_lower_pcsi}   Get Value In Match Packet     ${prb_packet}     startPrb    ${start_prb}   ${start_dprb}
        ${num_of_prbs_lower_pcsi}=   Evaluate   ${num_of_prbs_using_lower_pcsi} + ${num_of_prbs_lower_pcsi}
    END
    ${dynamic_pusch_prb}=   Evaluate   (${num_of_prbs_lower_pcsi}/${total_uldata_pusch})*100
    Should be True   ${dynamic_pusch_prb} > 70

Get Value In Match Packet
    [Arguments]                     ${packetMatch}   ${field}    ${start_prb}    ${start_dprb}   ${kind}=show
    @{listPath}                     Get Dictionary Keys                 ${packetMatch.fields}
    FOR    ${path}         IN      @{listPath}
            ${fieldName}            Get Field Name From Path            ${path}
            ${startprb}=   Run Keyword if     '${fieldName}'=='${field}'   Set Variable   ${packetMatch.fields['${path}'].${kind}}
            ${startprb}=    convert to integer      ${startprb}
            ${start_prb}=    convert to integer      ${start_prb}
            ${start_dprb}=    convert to integer      ${start_dprb}
            ${num_of_prbs_using_lower_pcsi}=  Run Keyword if    ${startprb} >=${start_prb} and ${startprb} <${start_dprb}
            ...                               Evaluate   ${num_of_prbs_using_lower_pcsi} + 1
            ...                               ELSE     Set Variable   ${num_of_prbs_using_lower_pcsi}
            ${count_of_prbs_using_lower_pcsi}=   Set Variable if   '${num_of_prbs_using_lower_pcsi}' >= '2'   1   ${num_of_prbs_using_lower_pcsi}
    END
    [Return]                        ${count_of_prbs_using_lower_pcsi}

Get filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
    ...                             filterName=${filterExp}         filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
    [Return]    ${pdmlFile}

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Register multiple NSA UE to cell
    [Arguments]    ${cell}   ${first_ue_id}    ${last_ue_id}
    FOR     ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         LTE Attach should be Successful    ${ue_id}
         UE Attach should be Successful     ${ue_id}   ${cell}
    END

Start and validate UL and DL traffic NSA UE
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${dl_rate}   ${ul_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger DL Traffic for NSA     ${ue_id}    mbps   ${dl_rate}
         sleep  2s
         Trigger UL Traffic for NSA     ${ue_id}    mbps   ${ul_rate}
         sleep  2s
    END
    sleep   10s


Multiple NSA UE Detach
    [Arguments]    ${first_ue_id}    ${last_ue_id}
    FOR   ${ue_id}   IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         UE Detach should be Successful    ${ue_id}
    END

Attach multiple SA UE with traffic
    [Arguments]    ${first_ue}      ${last_ue}
    FOR    ${ue_id}    IN RANGE    ${first_ue}     ${last_ue}+${1}
          UE Register should be Success    ${ue_id}
          Trigger DL Traffic SA   ${ue_id}   50
          sleep   1s
          Trigger UL Traffic SA   ${ue_id}   100
          sleep   1s
    END
    sleep   20s
    #FOR    ${ue_id}    IN RANGE    ${first_ue}     ${last_ue}+${1}
    #      #Validate DL UL Throughput For UE   ${ue_id}   40   100
    #END

Attach multiple SA UE with ICS nGBR,5QI1 & 2 and verify gbrload
    [Arguments]    ${first_ue}      ${last_ue}
    wtsrunner.smf_param   additional_qosflows_to_activate=2,3,4   id=1
    FOR    ${ue_id}    IN RANGE    ${first_ue}     ${last_ue}+${1}
        Start Log    cprt
        UE Register with ICS nGBR,5QI1 & 2    ${ue_id}
        Trigger DL & UL for nGR,5QI1,2 Traffic   ${ue_id}   10
        ${cprt_6877_on}     Stop Log  cprt  test_scenario=6877_${ue_id}
        ${gbr_ul_load}   ${gbr_dl_load}   Verify gbrload in pcap   ${cprt_6877_on}

    END

Trigger DL & UL for nGR,5QI1,2 Traffic
    [Arguments]    ${ue_id}      ${rate}
    FOR   ${i}    IN RANGE    1     4+${1}
       wtsrunner.trf_data_start   ue=${ue_id}  pdu=${Pdu_session_ID}   qfi=${i}  dir=dl  trf_id=${TRF_ID}
         ...   protocol=udp   ack_mode=off  cl_trf_stats=on   mbps=${rate}   ack_mode=off  cl_trf_stats=on
       sleep   1s
       wtsrunner.trf_data_start   ue=${ue_id}  pdu=${Pdu_session_ID}   qfi=${i}  dir=ul  trf_id=${TRF_ID}
        ...    protocol=udp   ack_mode=off  cl_trf_stats=on   mbps=${rate}    ack_mode=off  cl_trf_stats=on
       sleep   1s
    END

Trigger DL Traffic SA
    [Arguments]    ${ue_id}      ${dl_rate}     ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}      ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    #Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=dl  trf_id=${trf_id}   protocol=udp   ack_mode=off  cl_trf_stats=on
    ...    mbps=${dl_rate}   ack_mode=off  cl_trf_stats=on
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully

Trigger UL Traffic SA
    [Arguments]    ${ue_id}     ${ul_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}      ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the UL Traffic for the SA variant
   # Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=ul  trf_id=${trf_id}   protocol=udp   ack_mode=off  cl_trf_stats=on
    ...   mbps=${ul_rate}    ack_mode=off  cl_trf_stats=on
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    UL_traffic_data_is_started_successfully

Check Average Data Rate
    [Arguments]    ${bearer_stat}    ${dir}    ${mbps}
    ${output}         Get Regexp Matches    ${bearer_stat}    Average data rate +(\\d+)    1
    ${result}         Evaluate    (${mbps} * 1000000 * 1.3) > int(${output[0]}) > (${mbps} * 1000000 * 0.8)
    Run Keyword if    ${result}    Log to Console    ${dir} Average data rate: ${output[0]}
    ...               ELSE    BuiltIn.Log     ${dir} Average data rate: ${output[0]}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Average data rate failed!

Check cell level UL tput SA
    [Arguments]   ${first_ue}    ${last_ue}
    ${cell_ul_tput}   set variable  0
    FOR     ${ue_idx}   IN RANGE    ${first_ue}    ${last_ue}+1
    wtsrunner.bearer_stats   ue=${ue_idx}   pdu=${Pdu_session_ID}   qfi=${QFI_ID}   dir=ul
    ${ul_avg_tput}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    ${output}         Get Regexp Matches    ${ul_avg_tput}    Average data rate +(\\d+)    1
    ${cell_ul_tput}     Evaluate    ${cell_ul_tput} + int(${output[0]})
    END
    [Return]   ${cell_ul_tput}

Check cell level UL tput NSA
    [Arguments]   ${first_ue}    ${last_ue}
    ${cell_ul_tput}   set variable  0
    FOR     ${ue_idx}   IN RANGE    ${first_ue}    ${last_ue}+1
    wtsrunner.bearer_stats  ue=${ue_idx}   id=2   dir=ul
    ${ul_avg_tput}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    ${output}         Get Regexp Matches    ${ul_avg_tput}    Average data rate +(\\d+)    1
    ${cell_ul_tput}     Evaluate    ${cell_ul_tput} + int(${output[0]})
    END
    [Return]   ${cell_ul_tput}

Validate DL UL Throughput For UE
    [Arguments]    ${UE_ID}    ${dlrate}   ${ulrate}   ${pdu_id}=${Pdu_session_ID}   ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=${pdu_id}   qfi=${qfi_id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Data Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=${pdu_id}   qfi=${qfi_id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Data Rate      ${bearer_stat_ul}    UL    ${ul_rate}

UE Register should be Success
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal   log_traffic_stats=off
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Log to Console    ---> ${UE_register_complete_pattern}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    BuiltIn.Log                UE_${ue_id}_register_is_ok

UE Register with ICS nGBR,5QI1 & 2
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal   log_traffic_stats=off
    wtsrunner.ue_register   id=${ue_id}    nwslice=${nw_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Log to Console    ---> ${UE_register_complete_pattern}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}

Attach Single SA CA UE and Get Throughput
    [Arguments]    ${UE_ID}=3    ${dl_tp_set}=175    ${ul_tp_set}=175
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
    Sleep    10s
    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl
    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul
    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    ${scell_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
    ${scell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=scell    scell_index=1
    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
    [Teardown]    SA 5G Detach    ue_id=${UE_ID}
    [Return]    ${pcell_dl_tp}    ${scell_dl_tp}    ${pcell_ul_tp}    ${scell_ul_tp}

Introduce BLER
    [Documentation]     Introduce BLER in UL with SINR
    wtsrunner.ul_sinr_testmode_nr     profile_id=1      sinr_target_pusch=-359
    wtsrunner.ue_testmode_set_nr    id=1    scell=1       testmode=ul_sinr   action=activate   profile_id=1

Trigger High DL Traffic SA
    [Arguments]    ${ue_id}      ${dl_rate}     ${pdu_id}=${Pdu_session_ID}     ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    ${dl_rate_loop}=      Evaluate      ${dl_rate}//175
    ${dl_rate_reminder}=     Evaluate      ${dl_rate}%175
    ${dl_rate_loop}=      Evaluate     ${dl_rate_loop}+1
    ${TRF_ID}=   Set Variable   1
    FOR   ${loop}   IN RANGE   0   ${dl_rate_loop}
    #Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
            Run Keyword if    ${loop}==0       wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=dl
            ...     trf_id=${TRF_ID}   protocol=udp   ack_mode=off  cl_trf_stats=on    mbps=${dl_rate_reminder}   ack_mode=off  cl_trf_stats=on
            Run Keyword if    ${loop}>0        wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=dl
            ...     trf_id=${TRF_ID}   protocol=udp   ack_mode=off  cl_trf_stats=on    mbps=175   ack_mode=off  cl_trf_stats=on
            ${TRF_ID}=      Evaluate     ${TRF_ID}+1
        sleep   2s
    END
    BuiltIn.Log    DL_traffic_data_is_started_successfully

Get CA Cell Average Throughput
    [Arguments]    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}
    [Documentation]    This keyword is to get Pcell/Scell Average throughput,1Mbps=1000Kbps
    ...    The unit of return throughput is Mbps.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue_id |
    ...    | ${dir} | Yes | dl/ul |
    ...    | ${cell_type} | Yes | pcell/scell |
    ...    | ${scell_index} | Yes | 1/2/3...|
    ...
    ...    | Examples: |
    ...    | ${pcell_tput} | Get CA Cell Average Throughput | 1 | dl | pcell | 0 |
    ...    | ${scell1_tput} | Get CA Cell Average Throughput | 1 | dl | scell | 1 |
    ...    | ${scell2_tput} | Get CA Cell Average Throughput | 1 | ul | scell | 2 |
    ...
    ${type}    Set Variable If    '${dir}'=='dl'    pdsch    pusch
    wtsrunner.ue_stats_nr     id=${ue_id} type=${type} scell=${scell_index} format=long
    ${output}    wtsrunner.read_wtsemu_output_until    expected=Number of received DL TBs dropped for error simulation
    ...                     timeout=30
    ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
    ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
    ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
    ${cell_tp}=    Evaluate    sum(map(float,${avg_tp_list}))
    ${cell_tp}=    Set Variable If    "${cell_tp}"=="0.0"    0    ${cell_tp}
    ${tp_unit_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    TputUnit
    ${tp_unit_empty}    ${ret}    Run Keyword And Ignore Error    Should Be Empty    ${tp_unit_list[0]}
    Run Keyword If    "${cell_tp}"=="0"    Append To List    ${tp_unit_list}    Mbps
    ${Kbps_to_Mbps}    Evaluate    float(${cell_tp}/1000)
    ${bps_to_Mbps}    Evaluate    float(${cell_tp}/1000/1000)
    ${cell_tput_Mbps}    Set Variable If    '${tp_unit_list[0]}'=='Kbps'    ${Kbps_to_Mbps}
    ...                                     '${cell_tp}'!='0' and '${tp_unit_empty}'=='PASS'    ${bps_to_Mbps}
    ...                                     ${cell_tp}
    [Return]    ${cell_tput_Mbps}

cell tput using ue_stats
    [Arguments]      ${start_ue}   ${end_ue}
    ${cell_dl_tp}   set variable  0
    ${cell_ul_tp}   set variable  0
    FOR    ${i}    IN RANGE    ${start_ue}    ${end_ue}+1
            ${cell_ul_tput}=    Get CA Cell Average Throughput    ue_id=${i}    dir=ul    cell_type=scell    scell_index=0
            ${cell_ul_tp}     Evaluate    ${cell_ul_tp} + int(${cell_ul_tput})
    END
    [Return]   ${cell_ul_tp}
