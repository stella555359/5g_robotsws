*** Settings ***
Documentation
Library     String
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME   csn
Library     taf.analyzer.pcap   WITH NAME   wireshark

Library     ../Library/pcmd_message.py
Library     ../Library/common.py

Resource    COAM.robot
Resource    DCAP.robot
Resource    PCMD.robot

Resource    ../../outsides/common_8196/l3call.robot
Resource    ../../outsides/common_8196/L3_Call.robot
Resource    ../../outsides/common_8196/taf_coam.robot
Resource    ../../outsides/common_8196/taf_log.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot

Variables   ../../outsides/common_8196/libraries/global_vars.py
Variables   ../Library/pcmd_var.py
Variables   ../Library/emil_vars.py

*** Variables ***
${INTRA_HO_FILE}   INTRA_HO.pcap
${INTER_HO_FILE}   INTER_HO.pcap
${INTRA_HO_PATH}   ${OUTPUT_DIR}/${INTRA_HO_FILE}
${INTER_HO_PATH}   ${OUTPUT_DIR}/${INTER_HO_FILE}

*** Keyword ***
Common Setup 8196
    Log To Console   ${EMPTY}
    Set Suite Variable   ${MRBTS_ID}   ${tl.gnbs[0].instance_id}
    Set Suite Variable   ${NRBTS_ID}   ${tl.gnbs[0].global_bts_id}
    Set Suite Variable   ${MRBTS}   MRBTS-${MRBTS_ID}
    Set Suite Variable   ${NRBTS}   NRBTS-${NRBTS_ID}
    Set Suite Variable   ${INSID}   ${MRBTS}/${NRBTS}
    COAM commissioning if not onair
    Wait Until Keyword Succeeds   5m   1m   COAM Login
    Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir
    COAM Backup SCF
    COAM Backup Full SCF
    COAM Update Celltrace Flag
    COAM Update PCMD Flag
    Get ALL Suite Variables
    Run Keyword And Ignore Error   Start Syslog Collection
    L3CALL Precondition   ${0}
    L3CALL Precondition   ${1}


Get ALL Suite Variables
    Set Suite Variable   ${LOCAL_SSH_ADDR}   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Set Suite Variable   ${LOCAL_SSH_USER}   ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    Set Suite Variable   ${LOCAL_SSH_PWD}   ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

    ${SMOD_NAME}   Get SMOD Product Name
    Set Suite Variable   ${SMOD_NAME}

    ${local_xml}   XML.Parse XML   ${OUTPUT_DIR}/full_commission.xml
    ${gNbIdLength}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="gNbIdLength"]
    Set Suite Variable   ${gNbIdLength}

    ${mcc}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="mcc"]
    ${mnc}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="mnc"]
    ${mnclength}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="mncLength"]

    ${local_tmp}   Set Variable If
    ...   '${mnclength}'=='2'   ${mcc}f${mnc.zfill(int(${mnclength}))}
    ...   '${mnclength}'=='3'   ${mcc}${mnc.zfill(int(${mnclength}))}
    Set Suite Variable   ${PLMN_IDENTITY}   ${local_tmp[1]}${local_tmp[0]}${local_tmp[3]}${local_tmp[2]}${local_tmp[5]}${local_tmp[4]}

    ${ssbScs}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/NRCELL-1"]/p[@name="ssbScs"]
    Set Suite Variable   ${ssbScs}

    ${chBw}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/NRCELL-1"]/p[@name="chBw"]
    Set Suite Variable   ${chBw}

    ${arfcnSsbPbch}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/NRCELL-1"]/p[@name="arfcnSsbPbch"]
    Set Suite Variable   ${arfcnSsbPbch}
    ${AMF_IP}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/SERVEDAMF-1"]/p[@name="amfIPAddress"]
    Set Suite Variable   ${AMF_IP}
    ${physCellId}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/NRCELL-1"]/p[@name="physCellId"]
    Set Suite Variable   ${physCellId}
    ${numberOfTransmittedSsBlocks}   XML.Get Element Text   ${local_xml}
    ...    xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELLGRP"]/p[@name="numberOfTransmittedSsBlocks"]
    ${numberOfSsBlocks}   Fetch From Left   ${numberOfTransmittedSsBlocks}  ${SPACE}
    Set Suite Variable   ${numberOfSsBlocks}


Get HO Suite Variables
    Set Suite Variable   ${PEER_MRBTS_ID}   ${tl.gnbs[1].instance_id}
    Set Suite Variable   ${PEER_NRBTS_ID}   ${tl.gnbs[1].global_bts_id}
    Set Suite Variable   ${PEER_MRBTS}   MRBTS-${PEER_MRBTS_ID}
    Set Suite Variable   ${PEER_NRBTS}   NRBTS-${PEER_NRBTS_ID}
    Set Suite Variable   ${PEER_INSID}   ${PEER_MRBTS}/${PEER_NRBTS}

    Set Suite Variable   ${PEER_SSH_ADDR}   ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
    Set Suite Variable   ${PEER_SSH_USER}   ${tl.gnbs[1].cu.oam_ssh_connection_details.username}
    Set Suite Variable   ${PEER_SSH_PWD}   ${tl.gnbs[1].cu.oam_ssh_connection_details.password}

    Set Suite Variable   ${PEER_WEBUI_ADDR}   ${tl.gnbs[1].cu.oam_http_connection_details.addr}
    Set Suite Variable   ${PEER_WEBUI_USER}   ${tl.gnbs[1].cu.oam_http_connection_details.username}
    Set Suite Variable   ${PEER_WEBUI_PWD}   ${tl.gnbs[1].cu.oam_http_connection_details.password}

    Wait Until Keyword Succeeds   5m   1m   COAM Login
    ...   bts_host=${PEER_WEBUI_ADDR}
    ...   username=${PEER_WEBUI_USER}
    ...   password=${PEER_WEBUI_PWD}
    ...   alias=PEER
    COAM Backup SCF   file_name=old_commission_peer.xml   connection=PEER
    COAM Backup Full SCF   file_name=full_commission_peer.xml   connection=PEER
    ${peer_xml}   XML.Parse XML   ${OUTPUT_DIR}/full_commission_peer.xml
    ${peer_gNbIdLength}   XML.Get Element Text   ${peer_xml}
    ...   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="gNbIdLength"]
    Set Suite Variable   ${PEER_gNbIdLength}

    ${peer_mcc}   XML.Get Element Text   ${peer_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="mcc"]
    ${peer_mnc}   XML.Get Element Text   ${peer_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="mnc"]
    ${peer_mnclength}   XML.Get Element Text   ${peer_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="mncLength"]

    ${peer_tmp}   Set Variable If
    ...   '${peer_mnclength}'=='2'   ${peer_mcc}f${peer_mnc.zfill(int(${peer_mnclength}))}
    ...   '${peer_mnclength}'=='3'   ${peer_mcc}${peer_mnc.zfill(int(${peer_mnclength}))}
    Set Suite Variable   ${PEER_PLMN_IDENTITY}   ${peer_tmp[1]}${peer_tmp[0]}${peer_tmp[3]}${peer_tmp[2]}${peer_tmp[5]}${peer_tmp[4]}

    ${local_xml}   XML.Parse XML   ${OUTPUT_DIR}/full_commission.xml
    ${nrcellid_source}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/NRCELL-1"]/p[@name="nrCellIdentity"]
    Set Suite Variable   ${nrcellid_source}
    ${nrcellid_target}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/NRCELL-2"]/p[@name="nrCellIdentity"]
    Set Suite Variable   ${nrcellid_target}
    ${drx_source}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/NRCELL-1"]/p[@name="actCDrx"]
    Set Suite Variable   ${drx_source}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=PEER

Remove And Add PCMD Object
    COAM Remove PCMD Object

    COAM Add PCMD Object
    COAM Update PCMD Flag
    COAM Update Celltrace Flag
    Wait Until Keyword Succeeds   3x   1m   Check Session Setup
    Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir

Make L3CALL And Get ALL PCMD MSG
    ${curr_date}   DateTime.Get Current Date   result_format=%Y%m%d_%H%M   exclude_millis=True
    Start Tcpdump To Get PCMD   pcmd_file=TCPDUMP_${curr_date}.pcap
    Run Keyword and Ignore Error   Wait Until Keyword Succeeds   2x   20s
    ...   Call Setup and check tput   duration=60   tput=100   tput_expect=10   4G_check=false

    Stop Tcpdump To Get PCMD   pcmd_file=TCPDUMP_${curr_date}.pcap
    Set Suite Variable   ${TCPDUMP_PATH}   ${OUTPUT_DIR}/TCPDUMP_${curr_date}.pcap

    ${file_list}   Get Newest Trace Files By BTSID   bts_id=${MRBTS_ID}   latest_skip_file=${emil_last_file}   local_dir=${OUTPUT_DIR}
    ${txt_file}   Covert Emil Logs to TXT   file_list=${file_list}   local_dir=${OUTPUT_DIR}
    Set Suite Variable   ${TXT_FILE}
    ${empty_msg_count}   check_empty_pcmd_msg   source_file=${txt_file}
    Run Keyword If   ${empty_msg_count}>0   Log   PCMD EMPTY MSG COUNT: ${empty_msg_count}. Please Manual Check.   WARN
    ${all_pcmd_msg}   get_all_pcmd_msgs   source_file=${txt_file}
    Set Suite Variable   ${ALL_PCMD_MSG}

Make L3CALL And Start PCMD TCPDUMP
    [Arguments]   ${ue_index}=${ue_index}
    ${curr_date}   DateTime.Get Current Date   result_format=%Y%m%d_%H%M   exclude_millis=True
    Set test variable  ${curr_date}
    Start Tcpdump To Get PCMD   pcmd_file=TCPDUMP_${curr_date}.pcap
    Run Keyword and Ignore Error   Wait Until Keyword Succeeds   2x   20s
    ...   Call Setup and check tput   ue_index=${ue_index}   duration=60    tput=100    tput_expect=50   4G_check=false   traffic_stop=${false}

Get ALL PCMD TCPDUMP File After Call And Traffic
    [Arguments]   ${tcptump_path}=None
    Stop Tcpdump To Get PCMD   pcmd_file=TCPDUMP_${curr_date}.pcap
    run keyword if   '${tcptump_path}'=='None'   Set Suite Variable   ${TCPDUMP_PATH}    ${OUTPUT_DIR}/TCPDUMP_${curr_date}.pcap
    ...   ELSE   run keywords   RUN   mv ${OUTPUT_DIR}/TCPDUMP_${curr_date}.pcap ${tcptump_path}
    ...   AND   Set Suite Variable   ${tcptump_path}

L3CALL Precondition
    [Arguments]   ${ue_index}=${ue_index}
    UE precondition   ue_index=${ue_index}
    run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

Attach UE and Detach
    [Arguments]   ${ue_index}=${ue_index}
    Attach UE BETA   ue_index=${ue_index}
    [Teardown]   Detach UE BETA   ue_index=${ue_index}

Attach UE BETA
    [Arguments]   ${ue_index}=${ue_index}
    ${mode_status}   Get UE Airmode status   ue_index=${ue_index}
    run keyword if  not '${mode_status}'=='1'   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
    power_ue.UE Attach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
    ${mode_status}   Get UE Airmode status   ue_index=${ue_index}
    Run Keyword If   '${mode_status}'!='1'   Sleep   10s
    ...   ELSE    UE Forced Reboot   ue_index=${ue_index}   detach_request=${false}

Detach UE BETA
    [Arguments]   ${ue_index}=${ue_index}
    power_ue.Prepare UE   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   is_need_to_kill_vysor=${false}
    Run Keyword And Ignore Error   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

Trigger INTRA HO
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=20
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=40
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=127

    Start Tcpdump To Get PCMD   pcmd_file=${INTRA_HO_FILE}
    Wait Until Keyword Succeeds   3x   20s   Call Setup and check tput   tput=100   tput_expect=10   traffic_stop=${false}   duration=900s


    # trigger Intra gnb HO by adjust adjustable attenuation
    # Keep TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL864 cell2(intraHOtargetcell) (A3-B3,A4-B4) value to 0
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=0
    Sleep   30s



    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL   AND
    ...   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   AND
    ...   Stop Tcpdump To Get PCMD   pcmd_file=${INTRA_HO_FILE}

Trigger INTER HO
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=20
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=127
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=40

    Start Tcpdump To Get PCMD
    ...   hostname=${PEER_SSH_ADDR}   username=${PEER_SSH_USER}   password=${PEER_SSH_PWD}   connection=PEER
    ...   pcmd_file=${INTER_HO_FILE}
    Wait Until Keyword Succeeds   3x   20s   Call Setup and check tput   tput=100   tput_expect=10   traffic_stop=${false}   duration=900s

    # trigger Intra gnb HO by adjust adjustable attenuation
    # Keep TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL865 cell1(interHOtargetcell) (A5-B5,A6-B6) value to 5
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=5
    Sleep   30s


    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL   AND
    ...   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   AND
    ...   Stop Tcpdump To Get PCMD
    ...      hostname=${PEER_SSH_ADDR}   username=${PEER_SSH_USER}   password=${PEER_SSH_PWD}   connection=PEER
    ...      pcmd_file=${INTER_HO_FILE}

Initialize PA
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=20

Get Initial Attenuation Values For eNB RU
    [Documentation]
    ...                <<Keyword>> is to get initial attenuation values based on channel port numbers get form testline config.
    ...                :param RU_id <str> : ru id which you want to operate
    ...                :param att_id <str> : <id> for example 0 or 1, if several attenuators used and RU id is not the same with att id.
    ...                                      ${None} as default, if more than one PAs and RUs defined in init.py.
    ...                                              please set RU id the same with Attenuator id in init.py,
    ...                                              even attenuator0 and attenuator1 has the same ip.
    ...                                              for example, RU0 use _attenuator_0(10.57.232.105, port 3&4)
    ...                                                           RU1 use _attenuator_1(10.57.232.105, port 7&8)
    ...                :Return initial_att_values<list> : previous attenuation values are returned for futher use.
    [Arguments]    ${RU_id}=0    ${vendor}=TopYoung    ${gnb_id}=0    ${att_id}=${None}
    ${attenuation_port_numbers} =     gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${RU_id}    gnb_id=${gnb_id}
    ${channel_numbers}     Get Length       ${attenuation_port_numbers}
    ${att_obj_in_ru_port}    Set Variable    ${tl.gnbs[${gnb_id}].dus[0].rus[${RU_id}].attenuation_ports[0].attenuator}
    ${att_index}    Get Index From List    ${tl.attenuators}    ${att_obj_in_ru_port}
    ${is_single_att_used}    Get Variable Value    ${tl.attenuator.vendor}
    ${ip_addr}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.ip_addr}    ${tl.attenuators[${att_index}].ip_addr}
    ${port}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.port}    ${tl.attenuators[${att_index}].port}
    ${vendor}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.vendor}    ${tl.attenuators[${att_index}].vendor}
    ${model}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.model}    ${tl.attenuators[${att_index}].model}
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${ip_addr}
    ...    port=${port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}
    ...    vendor=${vendor}
    ...    model=${model}
    ${initial_att_values}    Create List
    FOR  ${index}  IN RANGE    ${channel_numbers}
       ${values}=    attenuator.read_attenuation     port=${attenuation_port_numbers[${index}]}    attenuator_device=${configured_attenuator}
       Append To List     ${initial_att_values}     ${values}
    END
    [Return]    ${initial_att_values}


Get Attenuation Channels For RU
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                To get channel ports  of attenuation which connect to RU.
    ...                :param RU_id <str> : ru id which get form Testline Configuration, default is 0
    ...                :Return attenuation_port_numbers<list> : eg [9:10]
    [Arguments]    ${RU_id}=0    ${gnb_id}=0
    ${attenuation_channels}     set variable    ${tl.gnbs[${gnb_id}].dus[0].rus[${RU_id}].attenuation_ports}
    @{attenuation_port_numbers}    create list
    ${channel_numbers}     Get Length       ${attenuation_channels}
    FOR  ${index}  IN RANGE   ${channel_numbers}
        ${channel_port}   set variable    ${tl.gnbs[${gnb_id}].dus[0].rus[${RU_id}].attenuation_ports[${index}].port_no}
        Append To List     ${attenuation_port_numbers}    ${channel_port}
    END
    [Return]    ${attenuation_port_numbers}

Trigger INTRA gNB HO
    [Arguments]   ${ue_index}   ${INTRA_HO_filename}   ${type}=NSA
    ${value_init}   run keyword if   '${type}'=='NSA'   Create List   20   20   20   127
    ...   ELSE   Create List   20   20   127   127
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=${value_init}
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=40
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=127

    Start Tcpdump To Get PCMD   pcmd_file=${INTRA_HO_filename}
    Wait Until Keyword Succeeds   3x   20s   Call Setup and check tput   ue_index=${ue_index}   tput=100   tput_expect=10
    ...   traffic_stop=${false}   duration=900s


    # trigger Intra gnb HO by adjust adjustable attenuation
    # Keep TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL864 cell2(intraHOtargetcell) (A3-B3,A4-B4) value to 0
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=0
    Sleep   5s



    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL   AND
    ...   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   AND
    ...   Stop Tcpdump To Get PCMD   pcmd_file=${INTRA_HO_filename}

Trigger INTER gNB HO
    [Arguments]   ${ue_index}   ${INTRA_HO_target_filename}   ${INTRA_HO_source_filename}=None   ${type}=NSA
    ${value_init}   run keyword if   '${type}'=='NSA'   Create List   20   20   20   127
    ...   ELSE   Create List   20   20   127   127
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=${value_init}
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=127
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=40

    Start Tcpdump To Get PCMD
    ...   hostname=${PEER_SSH_ADDR}   username=${PEER_SSH_USER}   password=${PEER_SSH_PWD}   connection=PEER
    ...   pcmd_file=${INTRA_HO_target_filename}

    run keyword if   '${type}'=='NSA'   Start Tcpdump To Get PCMD
    ...   hostname=${LOCAL_SSH_ADDR}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   connection=LOCAL
    ...   pcmd_file=${INTRA_HO_source_filename}
    Wait Until Keyword Succeeds   3x   20s   Call Setup and check tput   ue_index=${ue_index}   tput=100   tput_expect=10
    ...   traffic_stop=${false}   duration=900s

    # trigger Intra gnb HO by adjust adjustable attenuation
    # Keep TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL865 cell1(interHOtargetcell) (A5-B5,A6-B6) value to 5
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=5
    Sleep   5s


    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL   AND
    ...   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   AND
    ...   Stop Tcpdump To Get PCMD
    ...      hostname=${PEER_SSH_ADDR}   username=${PEER_SSH_USER}   password=${PEER_SSH_PWD}   connection=PEER
    ...      pcmd_file=${INTRA_HO_target_filename}   AND
    ...   run keyword if   '${type}'=='NSA'   Stop Tcpdump To Get PCMD
    ...   hostname=${LOCAL_SSH_ADDR}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   connection=LOCAL
    ...      pcmd_file=${INTRA_HO_source_filename}

Trigger INTRA eNB HO
    [Arguments]   ${ue_index}   ${INTRA_HO_filename}  ${ip}=${LOCAL_SSH_ADDR}   ${user}=${LOCAL_SSH_USER}   ${password}=${LOCAL_SSH_PWD}
    log to console   Trigger INTRA eNB HO
    ${value_init}   Create List   20   20   20   30
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=${value_init}
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=127
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=127

    Start Tcpdump To Get PCMD
    ...   hostname=${ip}   username=${user}   password=${password}   connection=LOCAL
    ...   pcmd_file=${INTRA_HO_filename}
    Wait Until Keyword Succeeds   3x   20s   Call Setup and check tput   ue_index=${ue_index}   tput=100   tput_expect=10
    ...   traffic_stop=${false}   duration=900s

    # trigger Intra gnb HO by adjust adjustable attenuation
    # Keep TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL864 eNB cell1(interHOtargetcell) (A5-B5,A6-B6) value to 20 10
    ${value_change}   Create List   20   20   20   10
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=${value_change}
    Sleep   5s


    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL   AND
    ...   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   AND
    ...   Stop Tcpdump To Get PCMD
    ...      hostname=${ip}   username=${user}   password=${password}   connection=LOCAL
    ...      pcmd_file=${INTRA_HO_filename}

Get eNB Variables
    &{eNB_info}   Create Dictionary
    Set To Dictionary   ${eNB_info}   globaleNBId   ${tl.enbs[0].global_bts_id}
    Set To Dictionary   ${eNB_info}   ip   ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    [Return]  &{eNB_info}

Save gNB Snapshot
    [Arguments]  ${host}=${LOCAL_SSH_ADDR}   ${alias}=master
    log to console    Save Snapshot logs
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    COAM Login   bts_host=${host}   alias=${alias}
    Run Keyword And Ignore Error   taf_coam.Catch Snapshot COAM   local_file_path=${OUTPUT_DIR}/snapshot_${curr_data}.zip    connection=${alias}
    [Teardown]   run keyword and ignore error    COAM Logout   connection=${alias}

Get Physical Cell ID from Target gnb
    COAM Login
    ${targetcell_pci}    COAM Get Parameter Value
    ...  dist_name=${INSID}/NRADJNRCELL-1
    ...  parameter=physCellId
    set test variable   ${targetcell_pci}
    [Teardown]   run keyword and ignore error    COAM Logout

Get CellIdentity and Convert it to Filter
    [Arguments]  ${cell_id}   ${BTS_ip}=${WEBUI_ADDR}   ${usernanme}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
    ${conn}   Wait Until Keyword Succeeds   5 min   1 min    coam.connect_to
    ...   bts_host=${BTS_ip}
    ...   username=${usernanme}
    ...   password=${password}
    ...   name=gnb_conn
    ${cellsInfo}   coam.get_parameters_for_all   class_name=NRCEL   connection=${conn}
    FOR   ${item}   IN   @{cellsInfo}
        ${cellIdentity}   run keyword if   '${item['configurationId']}'=='${cell_id}'   set variable   ${item['nrCellIdentity']}
        Exit For Loop If   '${item['configurationId']}'=='${cell_id}'
    END
    ${cellIdentity_filter}   convert_cellidentity_to_tcpdump_filter   ${cellIdentity}
    [Return]  ${cellIdentity_filter}
    [Teardown]  run keyword and ignore error   coam.teardown   connection=${conn}

Get traceRecordingSessionRef PeriodicalmeasId dict
    [Documentation]   retrieve measID of periodical type of report from the first RRC reconfiguration message,
    ...               which is used for later filtering for periodical measurementReport
    [Arguments]       ${tcp_file}    ${packet_filter}
    Load Pcap File with Filter any Expression
    ...                        pcap_file=${tcp_file}
    ...                        any_expression=${packet_filter}
    ...                        filter=tcp.dstport==${dcap_server_port}
    ${traceRecordingSessionRef_periodicalmeasId_dic}   Create dictionary  
    ${peridicalMeasId}=   wireshark.get_field_value_by_xpath   xpath=.//nr-rrc.periodical_element
    ${peridicalMeasId_count}=  Get Length   ${peridicalMeasId}
    ${valid_peridicalMeasId}    run keyword and return status      should be true  ${peridicalMeasId_count} > ${0}
    ${traceRecordingSessionRef_Id}    ${periodicalmeasId}     run keyword if     ${valid_peridicalMeasId}
    ...    Get traceRecordingSessionRef vs periodicalmeasID
    FOR    ${id}    IN RANGE    ${peridicalMeasId_count}
        run keyword if   ${valid_peridicalMeasId}   set to dictionary
        ...    ${traceRecordingSessionRef_periodicalmeasId_dic}  ${traceRecordingSessionRef_Id}[${id}]   ${periodicalmeasId}[${id}]
    END
    ${cuRecord}=   wireshark.get_field_value_by_xpath   xpath=.//nr-rrc.reportConfigToAddModList
    ${cuRecord_count}=  Get Length   ${cuRecord}
     ${valid_cuRecordNoperidicalMeasId}    run keyword and return status      should be true
     ...   ${peridicalMeasId_count}==${0} and ${cuRecord_count}>0
     run keyword if   ${valid_cuRecordNoperidicalMeasId}   set to dictionary
     ...    ${traceRecordingSessionRef_periodicalmeasId_dic}   9999
    ${dict_No}=  Get length   ${traceRecordingSessionRef_periodicalmeasId_dic}
    set test variable  ${dict_No}
    Run Keyword if   ${dict_No}==0   Fail   No traceRecordingSessionRef found
    [Return]    ${traceRecordingSessionRef_periodicalmeasId_dic}

Get traceRecordingSessionRef vs periodicalmeasID
    ${count}=    Set Variable    0
    ${traceRecordingSessionRef_Id}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.CuRecordingSessionReport_element/nsetapx.traceRecordingSessionRef   attribute_name=show
    ${reportConfigId_list}    create list
    ${reportCount_list}    create list
    ${reportType_show}=   wireshark.get_field_value_by_xpath   xpath=.//nr-rrc.reportType   attribute_name=show
    FOR  ${i}  IN   @{reportType_show}
        ${passed} =  run keyword and return status     Should be equal   ${i}   0  # 0 is periodical report
        run keyword if  ${passed}    append to list   ${reportCount_list}    ${count}
        ${count}=    Evaluate    ${count}+1
    END
    FOR  ${count}  IN   @{reportCount_list}
        ${reportConfigId}    Fetch ReportConfigId    ${count}
        append to list   ${reportConfigId_list}    ${reportConfigId}
    END

    ${periodicalmeasId_list}    create list
    FOR  ${i}  IN   @{reportConfigId_list}
        ${measId}    Fetch MeasId    ${i}
        append to list   ${periodicalmeasId_list}    ${measId}
    END
    Log to console     ${traceRecordingSessionRef_Id}
    Log to console     ${periodicalmeasId_list}
    Log to console     ${reportConfigId_list}
    [Return]    ${traceRecordingSessionRef_Id}    ${periodicalmeasId_list}

Fetch ReportConfigId
    [Documentation]   retrieve reportConfigId
    [Arguments]       ${count}
    ${xpath_reportConfigId}   set variable   .//nr-rrc.ReportConfigToAddMod_element/nr-rrc.reportConfigId
    ${reportConfigId_showname_list}=   wireshark.get_field_value_by_xpath   xpath=${xpath_reportConfigId}   attribute_name=showname
    ${reportConfigId_showname}=    Set Variable     ${reportConfigId_showname_list}[${count}]
    ${reportConfigId}   Fetch From Right   ${reportConfigId_showname}  ${SPACE}
    [Return]    ${reportConfigId}


Fetch MeasId
    [Documentation]   retrieve measID
    [Arguments]       ${Id}
    ${count}=    Set Variable    0
    ${xpath_reportConfigId}   set variable   .//nr-rrc.MeasIdToAddMod_element/nr-rrc.reportConfigId
    ${reportConfigId_showname_list}=   wireshark.get_field_value_by_xpath   xpath=${xpath_reportConfigId}   attribute_name=showname
    FOR  ${i}  IN   @{reportConfigId_showname_list}
        ${reportConfigId}   Fetch From Right   ${i}  ${SPACE}
        Exit For Loop IF    "${reportConfigId}"=="${Id}"
        ${count}=    Evaluate    ${count}+1
    END
    ${measId_showname_list}=   wireshark.get_field_value_by_xpath   xpath=.//nr-rrc.MeasIdToAddMod_element/nr-rrc.measId   attribute_name=showname
    ${measId_showname}=    Set Variable     ${measId_showname_list}[${count}]
    ${measId}   Fetch From Right   ${measId_showname}  ${SPACE}
    [Return]    ${measId}

Check Measurement Report with CellTrace filter
    [Arguments]    ${tcp_file}    ${packet_filter}   ${traceRecordingSessionRef_periodicalmeasId_dic}   ${reportType}=periodical   ${reportAmount}=2
    [Documentation]   check the measurement report sent include correct content
    ...               argument traceRecordingSessionRef_periodicalmeasId_dic is dict with key as traceRecordingSessionRef
    ...                        and value periodicalmeasId of a UE's Meas Report, which is achieved from RRCReconfiguraiton message
    ...                        reportType=   periodical
    ...                                 or   event
    Run keyword if    '${reportAmount}'!='no_check'    Get Report Variables
    FOR  ${traceRecordingSessionRef}  IN   @{traceRecordingSessionRef_periodicalmeasId_dic}
        run keyword if  "${traceRecordingSessionRef_periodicalmeasId_dic}[${traceRecordingSessionRef}]"!="9999"
        ...    Extract NSETAPX And Check Cell Trace Periodical Measurement Report    ${tcp_file}    ${packet_filter}
        ...   ${traceRecordingSessionRef_periodicalmeasId_dic}[${traceRecordingSessionRef}]    ${traceRecordingSessionRef}    ${reportType}
        ...   ${reportAmount}
        #ToDo FAIL if the periodical is not there.
#        run keyword if  "${reportType}"=="event"
#        ...    Extract NSETAPX And Check Cell Trace Event Triggered Measurement Report    ${tcp_file}    ${packet_filter}
#        ...   ${traceRecordingSessionRef_periodicalmeasId_dic}[${traceRecordingSessionRef}]    ${traceRecordingSessionRef}    ${reportType}
    END

Extract NSETAPX And Check Cell Trace Periodical Measurement Report
    [Arguments]    ${tcp_file}    ${packet_filter}   ${measId_periodical}    ${traceRecordingSessionRef}
    ...    ${reportType}=periodical    ${reportAmount}=2
    [Documentation]   check the measurement report sent include correct content
    ...               argument measId_periodical is the measId for type periodcal report
    ...                        reportType=   periodical
    ...                                 or   event
    ${packet_filter}=    Catenate    SEPARATOR=&&
    ...   ${packet_filter}
    ...   (nsetapx.traceRecordingSessionRef==${traceRecordingSessionRef})
    Load Pcap File with Filter any Expression
    ...                        pcap_file=${tcp_file}
    ...                        any_expression=${packet_filter}
    ...                        filter=nr-rrc.measId==${measId_periodical}
    ${CellTraceMeasurement_couter}    set variable   ${0}
    ${CellTraceMeasurement}=   wireshark.get_field_value_by_xpath   xpath=.//nr-rrc.measResults_element
    ${CellTraceMeasurement_couter}=  Get Length   ${CellTraceMeasurement}
    run keyword if      ${CellTraceMeasurement_couter} > ${0}
    ...    check Source Cell and Target Cell measurements data   ${reportAmount}
    Run keyword if   ${CellTraceMeasurement_couter}==${0}   Fail   No Measurement Report sent

#check Source Cell and Target Cell measurements data
#    [Arguments]    ${reportAmount}=2
#    #check source Cell ID
#    ${HandoverSourceCellItems}=   wireshark.get_field_value_by_xpath
#    ...    xpath=.//nr-rrc.measResultServingCell_element/nr-rrc.physCellId   attribute_name=showname
#    ${SourceCell_count}=  Get Length   ${HandoverSourceCellItems}
#    Run keyword if   '${reportAmount}' != 'no_check'     should be equal   '${SourceCell_count}'   '${reportAmount}'
#    FOR  ${i}  IN   @{HandoverSourceCellItems}
#        ${status1}  Run Keyword And Return Status   Should Contain  ${i}   physCellId: ${physCellId}
#        Exit For Loop IF    '${status1}'== 'False'
#    END
#    ${Xpath1}=    Builtin.set variable    nr-rrc.resultsSSB_Cell_element
#    ${Xpath2}=    Builtin.set variable    nr-rrc.measQuantityResults.rsrp
#    ${Xpath}=    Catenate    SEPARATOR=/    ./   ${Xpath1}   ${Xpath2}
#    ${SourceCellrsrps}=   wireshark.get_field_value_by_xpath   xpath=${Xpath}   attribute_name=showname
#    ${SourceCellrsrps_count}=  Get Length   ${SourceCellrsrps}
#    should be equal   ${SourceCell_count}   ${SourceCellrsrps_count}
#    FOR  ${i}  IN   @{SourceCellrsrps}
#        ${status2}  Run Keyword And Return Status   Should Contain  ${i}   rsrp:
#        Exit For Loop IF    '${status2}'== 'False'
#    END
#    ${Xpath1}=    Builtin.set variable    nr-rrc.resultsSSB_Cell_element
#    ${Xpath2}=    Builtin.set variable    nr-rrc.measQuantityResults.rsrq
#    ${Xpath}=    Catenate    SEPARATOR=/    ./   ${Xpath1}   ${Xpath2}
#    ${SourceCellrsrqs}=   wireshark.get_field_value_by_xpath   xpath=${Xpath}   attribute_name=showname
#    ${SourceCellrsrqs_count}=  Get Length   ${SourceCellrsrqs}
#    should be equal   ${SourceCell_count}   ${SourceCellrsrqs_count}
#    FOR  ${i}  IN   @{SourceCellrsrqs}
#        ${status3}  Run Keyword And Return Status   Should Contain  ${i}   rsrq:
#        Exit For Loop IF    '${status3}'== 'False'
#    END
#    ${Xpath1}=    Builtin.set variable    nr-rrc.resultsSSB_Cell_element
#    ${Xpath2}=    Builtin.set variable    nr-rrc.measQuantityResults.sinr
#    ${Xpath}=    Catenate    SEPARATOR=/    ./   ${Xpath1}   ${Xpath2}
#    ${SourceCellsinrs}=   wireshark.get_field_value_by_xpath   xpath=${Xpath}   attribute_name=showname
#    ${SourceCellsinrs_count}=  Get Length   ${SourceCellsinrs}
#    should be equal   ${SourceCell_count}   ${SourceCellsinrs_count}
#    FOR  ${i}  IN   @{SourceCellsinrs}
#        ${status4}  Run Keyword And Return Status   Should Contain  ${i}   sinr:
#        Exit For Loop IF    '${status4}'== 'False'
#    END
#    ${Xpath1}=    Builtin.set variable    nr-rrc.ResultsPerSSB_Index_element
#    ${Xpath2}=    Builtin.set variable    nr-rrc.ssb_Index
#    ${Xpath}=    Catenate    SEPARATOR=/    ./   ${Xpath1}   ${Xpath2}
#    ${SourceSSBIndex}=   wireshark.get_field_value_by_xpath   xpath=${Xpath}   attribute_name=show
#    ${SourceSSBIndex_count}=  Get Length   ${SourceSSBIndex}
#    FOR  ${i}  IN   @{SourceSSBIndex}
#        ${status5}  Run Keyword And Return Status   Should Be True  ${i} == ${numberOfSsBlocks} - 1
#        Exit For Loop IF    ${status5}
#    END
#    ${Xpath1}=    Builtin.set variable    nr-rrc.ssb_Results_element
#    ${Xpath2}=    Builtin.set variable    nr-rrc.measQuantityResults.rsrp
#    ${Xpath}=    Catenate    SEPARATOR=/    ./   ${Xpath1}   ${Xpath2}
#    ${SourceSSBrsrps}=   wireshark.get_field_value_by_xpath   xpath=${Xpath}   attribute_name=showname
#    ${SourceSSBrsrps_count}=  Get Length   ${SourceSSBrsrps}
#    FOR  ${i}  IN   @{SourceSSBrsrps}
#        ${status6}  Run Keyword And Return Status   Should Contain  ${i}   rsrp:
#        Exit For Loop IF    '${status6}'== 'False'
#    END
#    ${Xpath1}=    Builtin.set variable    nr-rrc.ssb_Results_element
#    ${Xpath2}=    Builtin.set variable    nr-rrc.measQuantityResults.rsrq
#    ${Xpath}=    Catenate    SEPARATOR=/    ./   ${Xpath1}   ${Xpath2}
#    ${SourceSSBrsrqs}=   wireshark.get_field_value_by_xpath   xpath=${Xpath}   attribute_name=showname
#    ${SourceSSBrsrqs_count}=  Get Length   ${SourceSSBrsrqs}
#    FOR  ${i}  IN   @{SourceSSBrsrqs}
#        ${status7}  Run Keyword And Return Status   Should Contain  ${i}   rsrq:
#        Exit For Loop IF    '${status7}'== 'False'
#    END
#    ${Xpath1}=    Builtin.set variable    nr-rrc.ssb_Results_element
#    ${Xpath2}=    Builtin.set variable    nr-rrc.measQuantityResults.sinr
#    ${Xpath}=    Catenate    SEPARATOR=/    ./   ${Xpath1}   ${Xpath2}
#    ${SourceSSBsinrs}=   wireshark.get_field_value_by_xpath   xpath=${Xpath}   attribute_name=showname
#    ${SourceSSBsinrs_count}=  Get Length   ${SourceSSBsinrs}
#    FOR  ${i}  IN   @{SourceSSBsinrs}
#        ${status8}  Run Keyword And Return Status   Should Contain  ${i}   sinr:
#        Exit For Loop IF    '${status8}'== 'False'
#    END
#
#    #check Target Cell ID
#    ${HandoverTargetCellItems}=   wireshark.get_field_value_by_xpath
#    ...    xpath=.//nr-rrc.MeasResultNR_element/nr-rrc.physCellId   attribute_name=showname
#    FOR  ${i}  IN   @{HandoverTargetCellItems}
#        ${status9}  Run Keyword And Return Status    Should Contain  ${i}   physCellId: ${physCellIdTarget}
#        Exit For Loop IF    ${status9}
#    END
#    ${Xpath1}=    Builtin.set variable   field[@name='nsetapx.asn1_Data_element']
#    ${Xpath2}=    Builtin.set variable   field[@name='nr-rrc.MeasResultNR_element']
#    ${Xpath3}=    Builtin.set variable   field[@name='nr-rrc.resultsSSB_Cell_element']
#    ${Xpath4}=    Builtin.set variable   field[@name='nr-rrc.measQuantityResults.rsrp']
#    ${Xpath}=    Catenate    SEPARATOR=//    .   ${Xpath1}   ${Xpath2}  ${Xpath3}   ${Xpath4}
#    ${TargetCellrsrps}=   wireshark.get_field_value_by_xpath
#    ...    xpath=.//nr-rrc.MeasResultNR_element/nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.rsrp   attribute_name=showname
#    FOR  ${i}  IN   @{TargetCellrsrps}
#        ${status10}  Run Keyword And Return Status   Should Contain  ${i}   rsrp:
#        Exit For Loop IF    '${status10}'== 'False'
#    END
#    ${Xpath1}=    Builtin.set variable    field[@name='nsetapx.asn1_Data_element']
#    ${Xpath2}=    Builtin.set variable    field[@name='nr-rrc.MeasResultNR_element']
#    ${Xpath3}=    Builtin.set variable    field[@name='nr-rrc.resultsSSB_Cell_element']
#    ${Xpath4}=    Builtin.set variable    field[@name='nr-rrc.measQuantityResults.rsrq']
#    ${Xpath}=    Catenate    SEPARATOR=//    .   ${Xpath1}   ${Xpath2}  ${Xpath3}   ${Xpath4}
#    ${TargetCellrsrqs}=   wireshark.get_field_value_by_xpath
#    ...    xpath=.//nr-rrc.MeasResultNR_element/nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.rsrq   attribute_name=showname
#    FOR  ${i}  IN   @{TargetCellrsrqs}
#        ${status11}  Run Keyword And Return Status   Should Contain  ${TargetCellrsrq}   rsrq:
#        Exit For Loop IF    '${status11}'== 'False'
#    END
#    ${Xpath1}=    Builtin.set variable    field[@name='nsetapx.asn1_Data_element']
#    ${Xpath2}=    Builtin.set variable    field[@name='nr-rrc.MeasResultNR_element']
#    ${Xpath3}=    Builtin.set variable    field[@name='nr-rrc.resultsSSB_Cell_element']
#    ${Xpath4}=    Builtin.set variable    field[@name='nr-rrc.measQuantityResults.sinr']
#    ${Xpath}=    Catenate    SEPARATOR=//    .   ${Xpath1}   ${Xpath2}  ${Xpath3}   ${Xpath4}
#    ${TargetCellsinrs}=   wireshark.get_field_value_by_xpath
#    ...    xpath=.//nr-rrc.MeasResultNR_element/nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.sinr   attribute_name=showname
#    FOR  ${i}  IN   @{TargetCellsinrs}
#        ${status12}  Run Keyword And Return Status   Should Contain  ${TargetCellsinr}   sinr:
#        Exit For Loop IF    '${status12}'== 'False'
#    END
#    ${status_CellTraceSource}=    evaluate
#    ...   ${status1} and ${status2} and ${status3} and ${status4} and ${status5} and ${status6} and ${status7} and ${status8}
#    Run keyword if   '${status_CellTraceSource}' == 'False'   Fail   Cell Trace Measurement Report check failing
#    ###todo

check Source Cell and Target Cell measurements data
    [Arguments]    ${reportAmount}=2
    #check source Cell ID
    ${HandoverSourceCellItems}=   wireshark.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.measResultServingCell_element/nr-rrc.physCellId   attribute_name=showname
    ${SourceCell_count}=  Get Length   ${HandoverSourceCellItems}
    Run keyword if   '${reportAmount}' != 'no_check'     should be equal   '${SourceCell_count}'   '${reportAmount}'
    FOR  ${i}  IN   @{HandoverSourceCellItems}
        ${status1}  Run Keyword And Return Status   Should Contain  ${i}   physCellId: ${physCellId}
        Exit For Loop IF    '${status1}'== 'False'
    END
    ${Xpath1}=    Builtin.set variable    nr-rrc.resultsSSB_Cell_element
    ${Xpath2}=    Builtin.set variable    nr-rrc.measQuantityResults.rsrp
    ${Xpath}=    Catenate    SEPARATOR=/    ./   ${Xpath1}   ${Xpath2}
    ${SourceCellrsrps}=   wireshark.get_field_value_by_xpath   xpath=${Xpath}   attribute_name=showname
    ${SourceCellrsrps_count}=  Get Length   ${SourceCellrsrps}
    should be true   ${SourceCell_count}<=${SourceCellrsrps_count}
    FOR  ${i}  IN   @{SourceCellrsrps}
        ${status2}  Run Keyword And Return Status   Should Contain  ${i}   rsrp:
        Exit For Loop IF    '${status2}'== 'False'
    END



    ${Xpath1}=    Builtin.set variable    nr-rrc.resultsSSB_Cell_element
    ${Xpath2}=    Builtin.set variable    nr-rrc.measQuantityResults.rsrq



    ${Xpath}=    Catenate    SEPARATOR=/    ./   ${Xpath1}   ${Xpath2}
    ${SourceCellrsrqs}=   wireshark.get_field_value_by_xpath   xpath=${Xpath}   attribute_name=showname
    ${SourceCellrsrqs_count}=  Get Length   ${SourceCellrsrqs}
    should be true   ${SourceCell_count}<=${SourceCellrsrqs_count}
    FOR  ${i}  IN   @{SourceCellrsrqs}
        ${status3}  Run Keyword And Return Status   Should Contain  ${i}   rsrq:
        Exit For Loop IF    '${status3}'== 'False'
    END
    ${Xpath1}=    Builtin.set variable    nr-rrc.resultsSSB_Cell_element
    ${Xpath2}=    Builtin.set variable    nr-rrc.measQuantityResults.sinr
    ${Xpath}=    Catenate    SEPARATOR=/    ./   ${Xpath1}   ${Xpath2}
    ${SourceCellsinrs}=   wireshark.get_field_value_by_xpath   xpath=${Xpath}   attribute_name=showname
    ${SourceCellsinrs_count}=  Get Length   ${SourceCellsinrs}
    should be true   ${SourceCell_count}<=${SourceCellsinrs_count}
    FOR  ${i}  IN   @{SourceCellsinrs}
        ${status4}  Run Keyword And Return Status   Should Contain  ${i}   sinr:
        Exit For Loop IF    '${status4}'== 'False'
    END
    ${Xpath1}=    Builtin.set variable    nr-rrc.ResultsPerSSB_Index_element
    ${Xpath2}=    Builtin.set variable    nr-rrc.ssb_Index
    ${Xpath}=    Catenate    SEPARATOR=/    ./   ${Xpath1}   ${Xpath2}
    ${SourceSSBIndex}=   wireshark.get_field_value_by_xpath   xpath=${Xpath}   attribute_name=show
    ${SourceSSBIndex_count}=  Get Length   ${SourceSSBIndex}
    FOR  ${i}  IN   @{SourceSSBIndex}
        ${status5}  Run Keyword And Return Status   Should Be True  ${i} == ${numberOfSsBlocks} - 1
        Exit For Loop IF    ${status5}
    END
    ${Xpath1}=    Builtin.set variable    nr-rrc.ssb_Results_element
    ${Xpath2}=    Builtin.set variable    nr-rrc.measQuantityResults.rsrp
    ${Xpath}=    Catenate    SEPARATOR=/    ./   ${Xpath1}   ${Xpath2}
    ${SourceSSBrsrps}=   wireshark.get_field_value_by_xpath   xpath=${Xpath}   attribute_name=showname
    ${SourceSSBrsrps_count}=  Get Length   ${SourceSSBrsrps}
    FOR  ${i}  IN   @{SourceSSBrsrps}
        ${status6}  Run Keyword And Return Status   Should Contain  ${i}   rsrp:
        Exit For Loop IF    '${status6}'== 'False'
    END
    ${Xpath1}=    Builtin.set variable    nr-rrc.ssb_Results_element
    ${Xpath2}=    Builtin.set variable    nr-rrc.measQuantityResults.rsrq
    ${Xpath}=    Catenate    SEPARATOR=/    ./   ${Xpath1}   ${Xpath2}
    ${SourceSSBrsrqs}=   wireshark.get_field_value_by_xpath   xpath=${Xpath}   attribute_name=showname
    ${SourceSSBrsrqs_count}=  Get Length   ${SourceSSBrsrqs}
    FOR  ${i}  IN   @{SourceSSBrsrqs}
        ${status7}  Run Keyword And Return Status   Should Contain  ${i}   rsrq:
        Exit For Loop IF    '${status7}'== 'False'
    END
    ${Xpath1}=    Builtin.set variable    nr-rrc.ssb_Results_element
    ${Xpath2}=    Builtin.set variable    nr-rrc.measQuantityResults.sinr
    ${Xpath}=    Catenate    SEPARATOR=/    ./   ${Xpath1}   ${Xpath2}
    ${SourceSSBsinrs}=   wireshark.get_field_value_by_xpath   xpath=${Xpath}   attribute_name=showname
    ${SourceSSBsinrs_count}=  Get Length   ${SourceSSBsinrs}
    FOR  ${i}  IN   @{SourceSSBsinrs}
        ${status8}  Run Keyword And Return Status   Should Contain  ${i}   sinr:
        Exit For Loop IF    '${status8}'== 'False'
    END



    #check Target Cell ID
    ${HandoverTargetCellItems}=   wireshark.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.MeasResultNR_element/nr-rrc.physCellId   attribute_name=showname
    FOR  ${i}  IN   @{HandoverTargetCellItems}
        ${status9}  Run Keyword And Return Status    Should Contain  ${i}   physCellId: ${physCellIdTarget}
        Exit For Loop IF    ${status9}
    END
    ${Xpath1}=    Builtin.set variable   field[@name='nsetapx.asn1_Data_element']
    ${Xpath2}=    Builtin.set variable   field[@name='nr-rrc.MeasResultNR_element']
    ${Xpath3}=    Builtin.set variable   field[@name='nr-rrc.resultsSSB_Cell_element']
    ${Xpath4}=    Builtin.set variable   field[@name='nr-rrc.measQuantityResults.rsrp']
    ${Xpath}=    Catenate    SEPARATOR=//    .   ${Xpath1}   ${Xpath2}  ${Xpath3}   ${Xpath4}
    ${TargetCellrsrps}=   wireshark.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.MeasResultNR_element/nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.rsrp   attribute_name=showname
    FOR  ${i}  IN   @{TargetCellrsrps}
        ${status10}  Run Keyword And Return Status   Should Contain  ${i}   rsrp:
        Exit For Loop IF    '${status10}'== 'False'
    END
    ${Xpath1}=    Builtin.set variable    field[@name='nsetapx.asn1_Data_element']
    ${Xpath2}=    Builtin.set variable    field[@name='nr-rrc.MeasResultNR_element']
    ${Xpath3}=    Builtin.set variable    field[@name='nr-rrc.resultsSSB_Cell_element']
    ${Xpath4}=    Builtin.set variable    field[@name='nr-rrc.measQuantityResults.rsrq']
    ${Xpath}=    Catenate    SEPARATOR=//    .   ${Xpath1}   ${Xpath2}  ${Xpath3}   ${Xpath4}
    ${TargetCellrsrqs}=   wireshark.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.MeasResultNR_element/nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.rsrq   attribute_name=showname
    FOR  ${i}  IN   @{TargetCellrsrqs}
        ${status11}  Run Keyword And Return Status   Should Contain  ${TargetCellrsrq}   rsrq:
        Exit For Loop IF    '${status11}'== 'False'
    END
    ${Xpath1}=    Builtin.set variable    field[@name='nsetapx.asn1_Data_element']
    ${Xpath2}=    Builtin.set variable    field[@name='nr-rrc.MeasResultNR_element']
    ${Xpath3}=    Builtin.set variable    field[@name='nr-rrc.resultsSSB_Cell_element']
    ${Xpath4}=    Builtin.set variable    field[@name='nr-rrc.measQuantityResults.sinr']
    ${Xpath}=    Catenate    SEPARATOR=//    .   ${Xpath1}   ${Xpath2}  ${Xpath3}   ${Xpath4}
    ${TargetCellsinrs}=   wireshark.get_field_value_by_xpath



    ...    xpath=.//nr-rrc.MeasResultNR_element/nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.sinr   attribute_name=showname
    FOR  ${i}  IN   @{TargetCellsinrs}
        ${status12}  Run Keyword And Return Status   Should Contain  ${TargetCellsinr}   sinr:
        Exit For Loop IF    '${status12}'== 'False'
    END
    ${status_CellTraceSource}=    evaluate
    ...   ${status1} and ${status2} and ${status3} and ${status4} and ${status5} and ${status6} and ${status7} and ${status8}
    Run keyword if   '${status_CellTraceSource}' == 'False'   Fail   Cell Trace Measurement Report check failing
    ###todo


Check PCMD Report
    [Arguments]    ${tcp_file}     ${traceRecordingSessionRef_periodicalmeasId_dic}    ${reportAmount}=2    ${reportType}=periodical
    FOR  ${traceRecordingSessionRef}  IN   @{traceRecordingSessionRef_periodicalmeasId_dic}
        ${packet_filter}=    Catenate    SEPARATOR=&&    (nsetapx.ueMeasRecord)
        ...   (nsetapx.traceRecordingSessionRef==${traceRecordingSessionRef})
        Load Pcap File with Filter any Expression
        ...                        pcap_file=${tcp_file}
        ...                        any_expression=${packet_filter}
        ...                        filter=tcp.dstport==${dcap_server_port}
        run keyword if
        ...    "${reportType}"=="periodical" and "${traceRecordingSessionRef_periodicalmeasId_dic}[${traceRecordingSessionRef}]"!="9999"
        ...    Check PCMD packet    ${reportAmount}
    END

Check PCMD packet
    [Arguments]    ${reportAmount}=2
    ${CellTraceMeasurement}=   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.ueMeasRecord   attribute_name=showname
    ${CellTraceMeasurement_counter}=  Get Length   ${CellTraceMeasurement}
    Run keyword if   ${CellTraceMeasurement_counter}==${0}   Fail   No Measurement Report sent
    Run keyword if   '${reportAmount}' != 'no_check'     should be equal   '${CellTraceMeasurement_counter}'   '${reportAmount}'

    Check if it is a periodic and mdt PCMD Report
    Check if the PCMD Report with correct Serving Cell Data   ${CellTraceMeasurement_counter}


Check if it is a periodic and mdt PCMD Report
    ${triggerType}  wireshark.get_field_value_by_xpath   xpath=.//nsetapx.triggerType   attribute_name=show
    FOR  ${i}  IN   @{triggerType}
        Run Keyword If    "${i}"!="6"    Fail   Not periodic PCMD Report
    END
    ${purpose}  wireshark.get_field_value_by_xpath   xpath=.//nsetapx.purpose   attribute_name=show
    FOR  ${i}  IN   @{purpose}
        Run Keyword If    "${i}"!="3"    Fail   Not periodic PCMD Report
    END

Check if the PCMD Report with correct Serving Cell Data
    [Arguments]    ${trace_counter}
    ${is_present_servCell_pci}=    Check PCMD with correct Serving Cell PCI
    ${status_measResultServingMos}=    Check PCMD with correct Serving Cell Meas Data
    ${status_measResultSsbIndexes}=    Check PCMD with correct Serving Cell SsbIndexes Data    ${trace_counter}
    ${status_PCMD}=    evaluate    ${is_present_servCell_pci} and ${status_measResultServingMos} and ${status_measResultSsbIndexes}
    Run Keyword If    "${status_PCMD}"!="True"    Fail   Not correct periodic PCMD Report

Check PCMD with correct Serving Cell PCI
    ${is_present_servCell_pci}=    Set Variable      False
    ${servCellId_items}=   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.MeasResultServingMo_element/nsetapx.pci   attribute_name=showname
    FOR  ${i}  IN   @{servCellId_items}
        ${is_present_servCell_pci}  Run Keyword And Return Status    Should Contain  ${i}   pci: ${physCellId}
        Exit For Loop IF    '${is_present_servCell_pci}' == 'False'
    END
    [Return]    ${is_present_servCell_pci}

Check PCMD with correct Serving Cell Meas Data
    ${is_present_servCell_rsrp}=    Set Variable      False
    ${is_present_servCell_rsrq}=    Set Variable      False
    ${is_present_servCell_sinr}=    Set Variable      False
    ${ssbCellRsrp}=   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.ssbCellResult_element/nsetapx.rsrp   attribute_name=showname
    FOR  ${i}  IN   @{ssbCellRsrp}
        ${is_present_servCell_rsrp}  Run Keyword And Return Status   Should Contain  ${i}   rsrp:
        Exit For Loop IF    '${is_present_servCell_rsrp}' == 'False'
    END
    ${ssbCellRsrq}=   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.ssbCellResult_element/nsetapx.rsrq   attribute_name=showname
    FOR  ${i}  IN   @{ssbCellRsrq}
        ${is_present_servCell_rsrq}  Run Keyword And Return Status   Should Contain  ${i}   rsrq:
        Exit For Loop IF    '${is_present_servCell_rsrq}' == 'False'
    END
    ${ssbCellSinr}=   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.ssbCellResult_element/nsetapx.sinr   attribute_name=showname
    FOR  ${i}  IN   @{ssbCellSinr}
        ${is_present_servCell_sinr}  Run Keyword And Return Status   Should Contain  ${i}   sinr:
        Exit For Loop IF    '${is_present_servCell_sinr}' == 'False'
    END
    ${status_measResultServingMos}=    evaluate    ${is_present_servCell_rsrp} and ${is_present_servCell_rsrq} and ${is_present_servCell_sinr}
    [Return]    ${status_measResultServingMos}

Check PCMD with correct Serving Cell SsbIndexes Data
    [Arguments]    ${trace_counter}
    ${is_present_SsbIndexes}=    Set Variable      False
    ${is_present_SsbIndexes_rsrp}=    Set Variable      False
    ${is_present_SsbIndexes_rsrq}=    Set Variable      False
    ${is_present_SsbIndexes_sinr}=    Set Variable      False
    ${SsbIndexes}=   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.MeasResultSsbIndex_element/nsetapx.ssbIndex   attribute_name=show
    ${SsbIndexes_count}=  Get Length   ${SsbIndexes}
    FOR  ${i}  IN   @{SsbIndexes}
        ${is_present_SsbIndexes}  Run Keyword And Return Status   Should Be True  ${i} == ${numberOfSsBlocks} - 1
        Exit For Loop IF    ${is_present_SsbIndexes}
    END
    ${SsbIndexes_Rsrp}=   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.measResultSsb_element/nsetapx.rsrp   attribute_name=showname
    ${SsbIndexes_Rsrp_count}=  Get Length   ${SsbIndexes_Rsrp}
    FOR  ${i}  IN   @{SsbIndexes_Rsrp}
        ${is_present_SsbIndexes_rsrp}  Run Keyword And Return Status   Should Contain  ${i}   rsrp:
        Exit For Loop IF    '${is_present_SsbIndexes_rsrp}' == 'False'
    END
    ${SsbIndexes_Rsrq}=   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.measResultSsb_element/nsetapx.rsrq   attribute_name=showname
    ${SsbIndexes_Rsrq_count}=  Get Length   ${SsbIndexes_Rsrq}
    FOR  ${i}  IN   @{SsbIndexes_Rsrq}
        ${is_present_SsbIndexes_rsrq}  Run Keyword And Return Status   Should Contain  ${i}   rsrq:
        Exit For Loop IF    '${is_present_SsbIndexes_rsrq}' == 'False'
    END
    ${SsbIndexes_Sinr}=   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.measResultSsb_element/nsetapx.sinr   attribute_name=showname
    ${SsbIndexes_Sinr_count}=  Get Length   ${SsbIndexes_Sinr}
    FOR  ${i}  IN   @{SsbIndexes_Sinr}
        ${is_present_SsbIndexes_sinr}  Run Keyword And Return Status   Should Contain  ${i}   sinr:
        Exit For Loop IF    '${is_present_SsbIndexes_sinr}' == 'False'
    END
    ${status_measResultSsbIndexes}=    evaluate    ${is_present_SsbIndexes_rsrp} and ${is_present_SsbIndexes_rsrq} and ${is_present_SsbIndexes_sinr}
    [Return]    ${status_measResultSsbIndexes}


Remove And Add NRCTRLTS Object
    [Arguments]  ${add_object}=${add_all_pcmd}
    Wait Until Keyword Succeeds   5m   1m   COAM Login
    COAM Remove NRCTRLTS Object
    COAM Add NRCTRLTS Object  ${add_object}
    Wait Until Keyword Succeeds   3x   1m   Check Session Setup
    Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir

Check CellTrace And PCMD
    [Arguments]    ${tcp_file}  ${reportType}=periodical    ${trace_no}=1   ${reportAmount}=2
    ${traceRecordingSessionRef_periodicalmeasId_dic1}    Get traceRecordingSessionRef PeriodicalmeasId dict
    ...    ${tcp_file}    packet_filter=(nsetapx.asn1_MsgId == 3)
    ${dict_No}=  Get length   ${traceRecordingSessionRef_periodicalmeasId_dic1}
    Run Keyword if   '${dict_No}'!='${trace_no}' and '${trace_no}'!='no_check'   Fail   traceRecordingSession number not correct
    Check Measurement Report with CellTrace filter   ${tcp_file}   ${packet_filter}   ${traceRecordingSessionRef_periodicalmeasId_dic1}
    ...   ${reportType}   ${reportAmount}
    Check PCMD Report   ${tcp_file}   ${traceRecordingSessionRef_periodicalmeasId_dic1}   ${reportAmount}

Attach 2UE And Get TCPDUMP File
    [Arguments]    ${tcp_file}    ${detach}=False
    power_ue.Prepare UE   ue_type=${ue_0_type}   ue_index=${0}   is_need_to_kill_vysor=${false}
    Get Report Variables
    ${reportInterval_tmp}    Convert reportInterval    ${reportInterval}
    Start Tcpdump To Get PCMD   pcmd_file=${tcp_file}
    Run Keyword And Ignore Error    Attach UE BETA   ue_index=${0}
    ${ue_1_time}=  Get Current Date
    ${add_time}=   Set Variable If   '${reportAmount}'!='no_check'   ${${reportAmount} * ${reportInterval_tmp}}
    ${ue_2_time}=   Run keyword if   '${reportAmount}'!='no_check'  Add Time To Date  ${ue_1_time}  ${add_time}
    Set test variable  ${ue_2_time}
    power_ue.Prepare UE   ue_type=${ue_1_type}   ue_index=${1}   is_need_to_kill_vysor=${false}
    Run Keyword And Ignore Error    Attach UE BETA   ue_index=${1}
    Run keyword if   ${detach}
    ...     Run keywords
    ...     Detach UE BETA   ue_index=${0}
    ...     AND             Detach UE BETA   ue_index=${1}
    Stop Tcpdump To Get PCMD   pcmd_file=${tcp_file}

Convert reportInterval
    [Arguments]    ${interval}
    ${reportInterval_ms}=    Run keyword if    ('ms' in '${interval}')    Fetch From Right  ${interval}  s
    ${reportInterval_min}=    Run keyword if    ('min' in '${interval}')    Fetch From Right  ${interval}  n
    ${reportInterval}    Set Variable If    ('ms' in '${interval}')
    ...    ${${reportInterval_ms} / 1000}   ${${reportInterval_ms} * 60}
    [Return]  ${reportInterval}

Get Report Variables
    Wait Until Keyword Succeeds   5m   1m   COAM Login
    COAM Backup Full SCF
    ${local_xml}   XML.Parse XML   ${OUTPUT_DIR}/full_commission.xml
    ${reportAmount_tmp}   XML.get element text   ${local_xml}
    ...   xpath=cmData/managedObject[@distName='${INSID}/NRCTRLTS-1/NRMTRACECU-1']/list/item/p[@name='reportAmount']
    ${reportAmount_1}   Fetch From Right  ${reportAmount_tmp}  r
    ${reportAmount}   Set Variable If    '${reportAmount_tmp}'=='infinity'   no_check    ${reportAmount_1}
    Set test variable   ${reportAmount}
    ${reportInterval}   XML.get element text   ${local_xml}
    ...   xpath=cmData/managedObject[@distName='${INSID}/NRCTRLTS-1/NRMTRACECU-1']/list/item/p[@name='reportInterval']
    Set test variable   ${reportInterval}

Attach 1UE And Start TCPDUMP
    [Arguments]    ${tcp_file}   ${ue_index}=${0}
    ${ue_type}=   set variable   ${ue_${ue_index}_type}
    power_ue.Prepare UE   ue_type=${ue_type}   ue_index=${ue_index}   is_need_to_kill_vysor=${false}
    Start Tcpdump To Get PCMD   pcmd_file=${tcp_file}
    Run Keyword And Ignore Error    Attach UE BETA   ue_index=${ue_index}

Check SgNBRelease
    [Arguments]    ${pcap_file}
    Load Pcap File with Filter any Expression
    ...                        pcap_file=${pcap_file}
    ...                        any_expression=x2ap.procedureCode == 32
    ...                        filter=tcp.dstport==49148
    ${x2ap_radioNetwork_dic}=   wireshark.get_field_value_by_xpath   xpath=.//x2ap.radioNetwork   attribute_name=showname
    FOR  ${x2ap_radioNetwork}  IN   @{x2ap_radioNetwork_dic}
        ${status}  Run Keyword And Return Status   Should Contain  ${x2ap_radioNetwork}  user-inactivity
        Run keyword if   '${status}' == 'False'   Fail   SgNB_Release Cause not SgNB_Initiated_Normal_Release
    END
