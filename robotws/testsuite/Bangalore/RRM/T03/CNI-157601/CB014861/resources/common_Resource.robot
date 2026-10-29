*** Settings ***
Documentation    :copyright: Nokia

Variables    ta5g_global_var
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../../../../../resources/robot/TTI_Traces.robot
Library           ../../../../../resources/python/CPRT_Capture.py
Resource         ../../../../../resources/NPS/SWENG/robot/PacketSearch_mcshark.robot
Resource         ../../../../../resources/robot/Setup_Env.robot
Resource         ../../../../../resources/robot/Airphone.robot
Resource         ../../../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../../../resources/robot/PM_Counters.robot
Resource         ../../../../../resources/robot/common_log_collection.robot
Resource         ../../../../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../../../../../resources/robot/BBpooling_MuMIMO.robot
Library          ../../../../../resources/python/avg_dl_data.py
Library          ta5g_commissioning
Library          ta5g_pm_counters
Library          String
Library        verify_rnti_bwpid.py


*** Variables ***
${PDU_session_resource_setup_without_ICS}   PDU SESSION ID-.* setup.*reestablishment complete
${LTE_Bearer_creation_success}      Bearer-.* .*EBI=.* \nQCI=.*.* created
${ENDC_Sgnb_modification}     Successfully reconfigured dual connectivi
${FIELDS}    (itf_L2Log_Du_Ps_Events_DlFdSchedData_DlFdSchedData_t.muStatus == 0x15)

*** Keywords ***
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
    ...    "${RRU_type[0]}"=="AQQJ"    ${RRU_type[0]}_E1
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
    Wait Until Keyword Succeeds    8min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    30min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    ${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    Check gNB Airscale is Ready - ${BBoard_Type}

    Log To console     loading cfg file
    #Start Log   btslog    cprt
    Start WTS Using WTS_Runner      ${wts_cfg_file}
    FOR     ${i}    IN RANGE   1   ${no_of_cells}+1
        Wait Until Keyword Succeeds     200s    5s	Check MIB_SIB status of GNB cell   ${i}
    END
    #${cprt_log}     Stop Log  cprt  test_scenario=cellsetup
    #set suite variable    ${cprt_log}
    #${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup_sys
    #set suite variable    ${cell_sys_log}

Load CFG Config And Verify cell setup in Capture CPRT Traces ASOH
    [Arguments]    ${wts_cfg_file}   ${no_of_cells}
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    8min    20sec     Check gNB Airscale is Ready ASOH - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    15min    20sec    Verify Single Radio is Online      connection=${oam_alias}
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

Verify DL_MUMIO Pairing
    [Arguments]      ${pcapFile}
    ${pdmlFile}=   Get filtered PDML file from pcap   ${pcapFile}[ttitrace]/tcpdump_ttitrace.pcap   ${FIELDS}
    ${mupair_count}       analyzer.count_path          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_L2Log_Du_Ps_Events_DlFdSchedData_DlFdSchedData_t
    ...                                                path=.*muStatus
    ...                                                pkt_count=${1}
    should be true  ${mupair_count} > 2000

Verify actNbrForNonGbrBearers In CellSetupReq
    [Documentation]      this KW Verifies the actNbrForNonGbrBearers In CellSetupReq captured in CPRT logs
    log to console       Verifying actNbrForNonGbrBearers In CellSetupReq captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${cprt_log}[cprt]/NODECPRT_GNB.pcap       sctp
    ${allowGBR}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=.*actNbrForNonGbrBearers$
    ...                                                endPacket=${1}
    Should be equal    ${allowGBR}    True


Verify actNbrForNonGbrBearers In CellSetupReq ASOH
    [Documentation]      this KW Verifies the actNbrForNonGbrBearers In CellSetupReq captured in CPRT logs
    log to console       Verifying actNbrForNonGbrBearers In CellSetupReq captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap       itf_l2_ps_cell_cellsetupreq
    ${allowGBR}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=actNbrForNonGbrBearers
    ...                                                endPacket=${1}
    Should be equal    ${allowGBR}    True

Verify actNbrForNonGbrBearers In CellReconfigurationReq
    [Arguments]      ${logpath}       ${filter_req}
    [Documentation]      this KW Verifies the actNbrForNonGbrBearers In CellReconfigurationReq captured in CPRT logs
    log to console       Verifying actNbrForNonGbrBearers In CellReconfigurationReq captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${allowGBR}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_CellReconfigurationReq
    ...                                                path=actNbrForNonGbrBearers
    ...                                                endPacket=${1}
    Should be equal    ${allowGBR}    True

Verify nbrDrbSpecificParams In bearersetupreq
    [Arguments]      ${logpath}       ${filter_req}     ${allownbr_dl_value}   ${allownbr_ul_value}
    [Documentation]      this KW Verifies the nbrDrbSpecificParams In BearerSetupReq captured in CPRT logs
    log to console       Verifying nbrDrbSpecificParams In BearerSetupReq captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${allowNBR_DL}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_user_bearersetupreq
    ...                                                path=.*nbrDl_item$
    ...                                                endPacket=${1}
    ${allowNBR_UL}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_user_bearersetupreq
    ...                                                path=.*nbrUl_item$
    ...                                                endPacket=${1}
    Should Contain    ${allowNBR_DL}    ${allownbr_dl_value}
    Should Contain    ${allowNBR_UL}    ${allownbr_ul_value}

Verify nbrDrbSpecificParams In bearersetupreq ASOE
    [Arguments]      ${logpath}       ${filter_req}     ${allownbr_dl_value}   ${allownbr_ul_value}
    [Documentation]      this KW Verifies the nbrDrbSpecificParams In BearerSetupReq captured in CPRT logs
    log to console       Verifying nbrDrbSpecificParams In BearerSetupReq captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${allowNBR_DL}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_NbrDrbSpecificParams
    ...                                                path=nbrDl_item
    ...                                                endPacket=${1}
    ${allowNBR_UL}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_NbrDrbSpecificParams
    ...                                                path=nbrUl_item
    ...                                                endPacket=${1}
    Should Contain    ${allowNBR_DL}    ${allownbr_dl_value}
    Should Contain    ${allowNBR_UL}    ${allownbr_ul_value}

Verify nbrDrbSpecificParams In bearersetupreq for Scells
    [Arguments]      ${logpath}       ${filter_req}     ${allownbr_dl_value}
    [Documentation]      this KW Verifies the nbrDrbSpecificParams In BearerSetupReq captured in CPRT logs
    log to console       Verifying nbrDrbSpecificParams In BearerSetupReq captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${allowNBR_DL}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_user_bearersetupreq
    ...                                                path=.*nbrDl_item$
    ...                                                endPacket=${1}
    Should Contain    ${allowNBR_DL}    ${allownbr_dl_value}

Verify Bearer Delete for all cells
    [Arguments]      ${logpath}       ${filter_req}
    [Documentation]      this KW Verifies the bearer delete is seen
    log to console       Verifying BearerDeleteReq captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${bearer_rel}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_user_bearerdeletereq
    ...                                                path=.*drbScellDeletionInd$
    ...                                                endPacket=${1}
    Should Contain    ${bearer_rel}    False


Verify nbrDrbSpecificParams In usersetupreq
    [Arguments]      ${logpath}       ${filter_req}     ${allownbr_dl_value}   ${allownbr_ul_value}
    [Documentation]      this KW Verifies the nbrDrbSpecificParams In usersetupreq captured in CPRT logs
    log to console       Verifying nbrDrbSpecificParams In usersetupreq captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${allowNBR_DL}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_user_usersetupreq
    ...                                                path=.*nbrDl_item$
    ...                                                endPacket=${2}
    ${allowNBR_UL}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_user_usersetupreq
    ...                                                path=.*nbrUl_item$
    ...                                                endPacket=${2}
    Should Contain    ${allowNBR_DL}    ${allownbr_dl_value}
    Should Contain    ${allowNBR_UL}    ${allownbr_ul_value}

Get filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
    ...                             filterName=${filterExp}         filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
    [Return]    ${pdmlFile}

UE Tirgger Intra-Freq Intra-GNB HO back and forth
    [Arguments]    ${ue}
    BuiltIn.Log    UE${ue} Tirgger Intra-Frequency Intra-DU HO To Cell...    console=${True}
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${measid_1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=518598    event_type=A3
    ${intra_freq_intra_DU_1}    catenate
    ...    ue_measurement_send_nr id=${ue} meas_id=${measid_1} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=80 nrsrq_nr=80
    execute egate command    ${intra_freq_intra_DU_1}    pass_regexp=Intra-eNB handover
    ${measid_2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=518598    event_type=A3
    ${intra_freq_intra_DU_2}    catenate
    ...    ue_measurement_send_nr id=${ue} meas_id=${measid_2} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80
    execute egate command    ${intra_freq_intra_DU_2}    pass_regexp=Intra-eNB handover

Validate DL UL Traffic For UE
    [Arguments]    ${UE_ID}    ${Pdu_session_ID}   ${QFI_ID}   ${rate}
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=${rate}   pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}
    Run Keyword and Ignore Error   Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=${rate}   pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}

Validate DL UL Throughput For UE
    [Arguments]    ${UE_ID}    ${Pdu_session_ID}   ${QFI_ID}   ${dlrate}   ${ulrate}
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=${dlrate}   pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}
    Run Keyword and Ignore Error   Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=${ulrate}   pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}


UE Register should be Successful Vonr
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal   log_traffic_stats=off
    wtsrunner.ue_register   id=${ue_id}    nwslice=${nw_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Log to Console    ---> ${UE_register_complete_pattern}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${output}

UE Register should be Success
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal   log_traffic_stats=off
    wtsrunner.ue_register   id=${ue_id}    nwslice=${nw_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Log to Console    ---> ${UE_register_complete_pattern}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${output}

Trigger DL Traffic for SA Vonr
    [Arguments]    ${ue_id}      ${dl_rate}     ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}      ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    #Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=dl  trf_id=${trf_id}   protocol=udp   ack_mode=off  cl_trf_stats=on
    ...    mbps=${dl_rate}   ack_mode=off  cl_trf_stats=on
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully

Trigger UL Traffic for SA Vonr
    [Arguments]    ${ue_id}     ${ul_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}      ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the UL Traffic for the SA variant
   # Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=ul  trf_id=${trf_id}   protocol=udp   ack_mode=off  cl_trf_stats=on
    ...   mbps=${ul_rate}    ack_mode=off  cl_trf_stats=on
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    UL_traffic_data_is_started_successfully

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

Modify NIDD parameters
    [Documentation]     This Keyword modify NIDD parameter as per the requirement of the feature CB005788
    [Arguments]        ${paramDst}='None'                  ${operation}=update
     ...                ${paramName}='None'                 ${paramValue}='None'
    Log to Console      Modifying NIDD parameters
    admin.Setup admin
    Online NIDD parameter change    paramDst=${paramDst}        operation=${operation}
    ...          paramName=${paramName}         paramValue=${paramValue}
    sleep               60s
    [Teardown]          admin.Teardown admin

Online NIDD parameter change
     [Documentation]    This Keyword used to update NIDD parameter(one at a time)
     ...                and returns the result
     ...        [Arguments]    parameter        :  Parameter names to parsed
     ...                       paramDst         :  Dist name should be parsed
     ...                       paramValue       :  Value for the parameter to be assigned should be parsed
     ...                       operation        :  Deffault Value given as update, and can be parsed other operation if required
     ...                       should_activate  :  Deffault Value is True if you want to set this False then parse the parameter as False
     ...                       skip_parameter_relation_errors : Default Value is True if you want to set this False then parse the parameter as False
     [Arguments]        ${paramName}='None'         ${paramValue}='None'
     ...                ${paramDst}='None'                  ${operation}=update
     ...                ${should_activate}=${True}          ${skip_parameter_relation_errors}=${True}
    admin.perform_parameter_recommissioning          parameter=${paramName}
     ...        value=${paramValue}             operation=${operation}                         dist_name=${paramDst}
     ...        skip_parameter_relation_errors=${skip_parameter_relation_errors}
     ...        should_activate=${should_activate}


UE Register with ICS should be Successful
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration with ICS in the output file for the SA variant
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.amf_param   id=1   send_ics_registration=on
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Log to Console    ---> UE Registeration with ICS Success
    Print Matching Lines from Output File    ${output}    ${UE_register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    Verify Initial Context Response   ${output}
#    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${PDU_session_resource_setup_without_ICS}    ${Timeout_SA}
    Verify PDU Session resoruce setup response    ${output}    ${ue_id}    ${pdu_id}
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${output}

UE Register with ICS+PDU should be Successful
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration with ICS+PDU in the output file for the SA variant
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_register   id=${ue_id}
    sleep   5s
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    sleep   5s
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${PDU_session_resource_setup_without_ICS}    ${Timeout_SA}
    Verify PDU Session resoruce setup response    ${output}    ${ue_id}    ${pdu_id}
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${output}

Verify Initial Context Response
    [Arguments]    ${output}
    [Documentation]    This keyword checks the Initial Context Response  message in  UE Registration
    ...                in the output file for the SA variant
    Should Contain    ${output}    ${Initial_context_setup_pattern}    ignore_case=True
    Print Matching Lines from Output File    ${output}    ${Initial_context_setup_pattern}


Verify PDU Session resoruce setup response
    [Arguments]    ${output}    ${ue_id}     ${pdu_session_id}
    [Documentation]    This keyword checks the PDU Session resoruce setup response without ICS
    ...                in the output file for the SA variant
    Run Keyword and Continue on failure     BuiltIn.Should Match Regexp     ${output}
    ...     UE-${ue_id}.*\\n.*PDU SESSION ID-${pdu_session_id} setup/reestablishment complete

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Multiple NSA UE Register
    [Arguments]    ${first_ue_id}    ${last_ue_id}   ${gnb_cell_id}=1
    FOR     ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         LTE Attach should be Successful    ${ue_id}
         UE Attach should be Successful     ${ue_id}   Trgt_Cell=${gnb_cell_id}
    END

Multiple NSA UE start and validate DL Traffic
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${dl_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger DL Traffic for NSA     ${ue_id}    mbps   ${dl_rate}
         sleep  5s
         Validate DL Traffic For NSA     ${ue_id}     ${dl_rate}
    END

Multiple NSA UE start and validate UL Traffic
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${dl_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger UL Traffic for NSA     ${ue_id}    mbps   ${dl_rate}
         sleep  5s
         Validate UL Traffic For NSA     ${ue_id}     ${dl_rate}
    END

Multiple NSA UE Detach
    [Arguments]    ${first_ue_id}    ${last_ue_id}
    FOR   ${ue_id}   IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         UE Detach should be Successful    ${ue_id}
    END

Add new LTE Bearer
    [Arguments]    ${ue_id}   ${bearer_id}    ${precedence}
    wtsrunner.bearer_add    ue=${ue_id}   id=${bearer_id}  filter=0  precedence=${precedence}
    ${output}    Read WTS Output Until Pattern Matches    ${LTE_Bearer_creation_success}    ${10}
    Print Matching Lines from Output File    ${output}    ${LTE_Bearer_creation_success}
    Log to console    New LTE Bearer addition is Success

ENDC Modify for Bearer Addition
    [Arguments]    ${ue_id}   ${bearer_id}    ${cause}=RN_CauseRadioNetwork_unspecified
    wtsrunner.enb_ue_dc_modify   ue=${ue_id}   bearer_to_add=${bearer_id}   by=enb   cause=${cause}
    ${output}    Read WTS Output Until Pattern Matches    ${ENDC_Sgnb_modification}    ${10}
    Print Matching Lines from Output File    ${output}    ${ENDC_Sgnb_modification}
    Log to console    ENDC Modify for Bearer Addition Success

Wait for UE to go to INACTIVE state
    [Arguments]       ${inactivity_timer}
    Log to Console          Wait ${inactivity_timer}s for UE to move inactive state
    sleep   ${inactivity_timer}s
    sleep   30s       #add extra delta

Trigger RRC Re-establishment
    [Arguments]    ${ue_id}   ${cell_id}
    wtsrunner.ue_rrc_reestablish    id=${ue_id}     cell=${cell_id}
    sleep    2s

Validate SA_DU_DRB_NBR_DL Counter
    [Arguments]    ${PM_dir1}
    Log to Console     verifying counter M55139C03509
    Set Suite variable   ${PM_dir1}
    ${M55139C03509}    Check PM counter value   ${PM_dir1}    PM_counter=M55139C03509
    PM_Counters.Check PM counter value equal or bigger than   expected_value=1   pm_files_location=${PM_dir1}
    ...  pi_id=M55139C03509   moc=NRCELL-1

Collect and Store PM Counter Files
    Log to Console     Collecting PM Files
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    [Return]    ${PM_dir1}

Check PM counter value
    [Arguments]    ${PM_dir}   ${PM_counter}   ${moc}=NRCELL-1
    ${pi_value}=   Get PM counter value   pm_files_location=${PM_dir}   pi_id=${PM_counter}    moc=${moc}
    ${pi_value}=   convert to integer    ${pi_value}
    [Return]    ${pi_value}


IntragNB Intercell HO SA A5 UE measurements
    [Arguments]    ${ue_id}=1
    wtsrunner.ue_measurement_send_nr       id=${ue_id}  meas_id=2 event=A5 srsrp_nr=19 phycell_id=50 nrsrp_nr=100 phycell_id=51
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}

Verify NBR counter updating for handover in target cell
    ${pm_counter_file}=   Get Next Unpacked Raw Pm Counters File    output_dirpath=${OUTPUT DIR}/nbr_counter
    Verify Any Counters In File
    ...  M55139C03509  >0  SA_DU_DRB_NBR_DL
    ...  M55139C03510  >0  SA_DU_DRB_NBR_UL
    ...  M55139C03507  >0  SA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  M55139C03508   0  SA_DU_DRB_NBR_ADMIT_NOT_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...  file_path=${pm_counter_file}


Trigger High DL Traffic for NSA
    [Arguments]    ${ue_id}     ${Traffic_rate}     ${dl_rate}    ${bearer_id}
    [Documentation]    This keyword starts the DL Traffic for the SA variant for higher data rate
    ${dl_rate_loop}=      Evaluate      ${dl_rate}//165
    ${dl_rate_reminder}=     Evaluate      ${dl_rate}%165
    ${dl_rate_loop}=      Evaluate     ${dl_rate_loop}+1
    ${TRF_ID}=   Set Variable   1
    FOR   ${loop}   IN RANGE   0   ${dl_rate_loop}
        Run Keyword if    ${loop}==0    Trigger DL Traffic For NSA   ue_id=${ue_id}    Traffic_rate=${Traffic_rate}
        ...   dl_rate=${dl_rate_reminder}     id=${bearer_id}   trf_id=${TRF_ID}
        Run Keyword if    ${loop}>0     Trigger DL Traffic For NSA   ue_id=${ue_id}    Traffic_rate=${Traffic_rate}
        ...   dl_rate=165     id=${bearer_id}    trf_id=${TRF_ID}
        ${TRF_ID}=      Evaluate     ${TRF_ID}+1
        sleep   2s
    END

Trigger High UL Traffic for NSA
    [Arguments]    ${ue_id}     ${Traffic_rate}     ${ul_rate}      ${bearer_id}
    [Documentation]    This keyword starts the UL Traffic for the SA variant for higher data rate
    ${ul_rate_loop}=      Evaluate      ${ul_rate}//165
    ${ul_rate_reminder}=     Evaluate      ${ul_rate}%165
    ${ul_rate_loop}=      Evaluate     ${ul_rate_loop}+1
    ${TRF_ID}=   Set Variable   1
    FOR   ${loop}   IN RANGE   0   ${ul_rate_loop}
        Run Keyword if    ${loop}==0    Trigger UL Traffic for NSA   ue_id=${ue_id}    Traffic_rate=${Traffic_rate}
        ...   ul_rate=${ul_rate_reminder}     id=${bearer_id}   trf_id=${TRF_ID}
        Run Keyword if    ${loop}>0     Trigger UL Traffic for NSA   ue_id=${ue_id}    Traffic_rate=${Traffic_rate}
        ...   ul_rate=165     id=${bearer_id}    trf_id=${TRF_ID}
        ${TRF_ID}=      Evaluate     ${TRF_ID}+1
        sleep   2s
    END

Multiple NSA UE start DL Traffic
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${dl_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger DL Traffic for NSA     ${ue_id}    mbps   ${dl_rate}
    END

Multiple NSA UE start UL Traffic
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${ul_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger UL Traffic for NSA     ${ue_id}    mbps   ${ul_rate}
    END

Validate DL UL Throughput For NSA UE
    [Arguments]    ${UE_ID}   ${bearer_id}    ${dlrate}   ${ulrate}
    Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${UE_ID}     dl_rate=${dlrate}   id=${bearer_id}
    Run Keyword and continue on Failure   Validate UL Traffic For NSA   ue_id=${UE_ID}     ul_rate=${ulrate}   id=${bearer_id}

Send A1 Measurement for Scell Addition
    [Arguments]    ${ue_id}   ${meas_id}    ${srsrp_nr}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr   id=${ue_id}    meas_id=${meas_id}   event=A1  srsrp_nr=${srsrp_nr}   phycell_id=${phycell_id}

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

Trigger High UL Traffic SA
    [Arguments]    ${ue_id}      ${ul_data}     ${pdu_id}=${Pdu_session_ID}     ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the \UL Traffic for the SA variant
    ${TRF_ID}=   Set Variable   1
    wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=ul   trf_id=${TRF_ID}   protocol=udp    mbps=${ul_data}
    BuiltIn.Log    UL_traffic_data_is_started_successfully

Validate UE beamid from TTI traces
    [Arguments]   ${csv_file_path}   ${rnti}    ${beamid}
    ${Check}  Verify Rnti ueBamid    ${csv_file_path}/output_dl_formated.csv      ${rnti}   ${beamid}
    run keyword and continue on failure   Run Keyword if   ${Check}!=${True}   Fail   Beamid is not matching

Capture TTI Traces and Validate UE bwpid
     [Arguments]   ${phy_id}   ${LOG_PATH}   ${filename}    ${rnti}   ${bwp}   ${flag}
     Start And Stop Tti Trace Streaming after BWP switch  ${phy_id}   ${LOG_PATH}/ttitrace_streaming/${filename}
     Convert Tti To CSV Mode     ${LOG_PATH}/ttitrace_streaming/${filename}
     Validate UE bwpid from TTI traces    ${LOG_PATH}/ttitrace_streaming/${filename}     ${rnti}   ${bwp}   ${flag}

Capture TTI Traces and Validate UE bwpid Per Cell
     [Arguments]   ${LOG_PATH}   ${filename}    ${rnti}   ${bwp}   ${flag}    ${pysical_cell_ids}
     Start And Stop Tti Trace Per Cell  ${LOG_PATH}/ttitrace_streaming/${filename}
     ...    pysical_cell_ids=${pysical_cell_ids}    duration=1s
     Convert Tti To CSV Mode     ${LOG_PATH}/ttitrace_streaming/${filename}
     Validate UE bwpid from TTI traces    ${LOG_PATH}/ttitrace_streaming/${filename}     ${rnti}   ${bwp}   ${flag}

Validate UE bwpid from TTI traces
    [Arguments]   ${csv_file_path}   ${rnti}   ${bwp}   ${flag}
    ${Check}  Verify Rnti ueBWPid    ${csv_file_path}/output_dl_formated.csv      ${rnti}   ${bwp}   ${flag}
    run keyword and continue on failure   Run Keyword if   ${Check}!=${True}   Fail   Bwpid is not matching
    ${Check1}  Verify Rnti ueBWPid    ${csv_file_path}/output_ul_formated.csv     ${rnti}   ${bwp}   ${flag}
    run keyword and continue on failure   Run Keyword if   ${Check1}!=${True}   Fail   Bwpid is not matching

Convert Tti To CSV Mode
    [Arguments]         ${path}
    Format Tti In Stream Mode         ${path}/output_dl.csv     ${path}/output_dl_formated.csv
    Format Tti In Stream Mode         ${path}/output_ul.csv     ${path}/output_ul_formated.csv

Create Rntibwp Dictionary
    [Arguments]   ${rnti}   ${bwpid}
    ${Dict1}   Create Dictionary
    ${len}   Get Length    ${rnti}
    FOR    ${i}    IN RANGE   ${len}
         Set To Dictionary   ${Dict1}    ${rnti}[${i}]   ${bwpid}[${i}]
    END
    Run Keyword if   ${len}==0    Set To Dictionary   ${Dict1}    ${EMPTY}   ${bwpid}[0]
    [Return]   &{Dict1}

Verify Rnti ueBWPid
    [Arguments]   ${csv_file_path}   ${rnti}   ${bwp}   ${flag}
    ${rntibwp}   Create Rntibwp Dictionary   ${rnti}   ${bwp}
    ${Result}  verify_rnti_bwpid.check_rnti_bwpid    ${csv_file_path}   ${rntibwp}   ${flag}
    [Return]   ${Result}

Start And Stop Tti Trace Streaming after BWP switch
    [Arguments]    ${phy_id}   ${path}
    #Start Ttitrace With Streaming Mode_2    ${phy_id}
    Start Ttitrace With Streaming Mode Per Cell    pysical_cell_ids=${phy_id}
    Sleep    1s    reason=get *L2TtiTrace_EventsSnapshot
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv        ${path}

MultiUE NSA Attach should be Successful and Fetch CRNTI
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${Trgt_Cell}=${Target_Cells}
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ${crnti_list}       Create List
    FOR    ${NSA_UE_ID}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_attach    id=${NSA_UE_ID}
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${LTE_attach_pattern}    ${Timeout_NSA}
    BuiltIn.Log    lte_attach_is_ok
    Log to Console  crnti_list-${crnti_list}
    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Trgt_Cell}    ue=${NSA_UE_ID}
    ...  bearer=${Bearer_ID}    type=split_scg
    ${output1}    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
    Create File     ${OUTPUT_DIR}/regst_nsa.txt     ${output1}
    ${crnti_value}=    Run     grep 'newUE-Identity' ${OUTPUT_DIR}/regst_nsa.txt|awk '{gsub(/ +/, " "); print}' | awk -F' |,' '{print $3}'
    BuiltIn.Log     ${crnti_value}
    Append To List  ${crnti_list}   ${crnti_value}
    Log to Console             nsa_ue_register_is_ok with ${crnti_value}
    BuiltIn.Log                nsa_ue_register_is_ok with ${crnti_value}
    END
    [Return]      ${crnti_list}
