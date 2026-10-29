*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com
Library     String
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME   csn
Library     taf.analyzer.pcap   WITH NAME   wireshark

Library     ../../libraries/nms_vars.py

Library     ../Library/pcmd_message.py

Library     ../Library/common.py

Resource    COAM.robot
Resource    DCAP.robot
Resource    PCMD.robot
Resource    ../../common/taf_coam.robot
Resource    ../../common/taf_log.robot
Resource    ../../common/qc_tag.robot
Resource    ../../common/gnb.robot
Resource    ../../UUF/Resource/common.robot
Resource   ../../../../resources/RAN_PZ_HAZ_34/robot/power_ue/UEs/nokia_fastmile.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Variables   ../../libraries/global_vars.py
Variables   ../Library/pcmd_var.py
Variables   ../Library/emil_vars.py
Resource   ../CaseResource/CB007425_001_PCMD_Configuration_Activation_and_Deactivation_Multi_Times.robot
Resource   ../CaseResource/CB007425_002_PCMD_TCE_TCP_Connection_Fault_8000_Raise_And_Clear_Multi_Times.robot
Resource   ../CaseResource/CB007425_003_PCMD_Link_Management_On_Cell_State_Change.robot
Resource   ../CaseResource/CB007425_004_PCMD_Configuration_Activation_and_Reboot.robot
Resource   ../CaseResource/CB007425_007_PCMD_Record_DU_UE_Context_Setup.robot
Resource   ../CaseResource/CB007425_008_PCMD_Record_DU_UE_Context_Release.robot
Resource   ../CaseResource/CB007425_009_PCMD_Record_CU_SgNB_Addition.robot
Resource   ../CaseResource/CB007425_010_PCMD_Record_CU_SgNB_Addition_Rejection.robot
Resource   ../CaseResource/CB007425_011_PCMD_Record_CU_SgNB_Release_MeNB_Initiated.robot
Resource   ../CaseResource/CB007425_012_PCMD_Record_CU_SgNB_Release_SgNB_Initiated.robot
Resource   ../CaseResource/CB007425_013_PCMD_Record_DU_UE_Release_Record.robot
Resource   ../CaseResource/CB007425_014_PCMD_Record_CU_UE_Release_Record.robot
Resource   ../CaseResource/CB007425_015_PCMD_Record_CU_UE_Release_Record_with_cacFailure.robot

*** Variables ***
${INTRA_HO_FILE}   INTRA_HO.pcap
${INTER_HO_FILE}   INTER_HO.pcap
${INTRA_HO_PATH}   ${OUTPUT_DIR}/${INTRA_HO_FILE}
${INTER_HO_PATH}   ${OUTPUT_DIR}/${INTER_HO_FILE}

*** Keyword ***
Common Setup 1756
    Log To Console   ${EMPTY}
    Set Suite Variable   ${MRBTS_ID}   ${tl.gnbs[0].instance_id}
    Set Suite Variable   ${NRBTS_ID}   ${tl.gnbs[0].global_bts_id}
    Set Suite Variable   ${MRBTS}   MRBTS-${MRBTS_ID}
    Set Suite Variable   ${NRBTS}   NRBTS-${NRBTS_ID}
    Set Suite Variable   ${INSID}   ${MRBTS}/${NRBTS}
    # COAM Try Connect gNB
    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
    Wait Until Keyword Succeeds   5m   1m   COAM Login
    Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir
    
    COAM Backup SCF
    COAM Backup Full SCF
    Get ALL Suite Variables
    Run Keyword And Ignore Error   Start Syslog Collection

Common Teardown 1756
    Run Keyword And Ignore Error   Stop and Save Syslog Collection
    Run Keyword And Ignore Error   Check Error Log From Syslog
    Run Keyword And Ignore Error   COAM Logout

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

    ${emil_last_file}   Get Latest Trace File Name By BTSID
    Set Suite Variable   ${emil_last_file}

    COAM Add PCMD Object
    COAM Update PCMD Flag
    COAM Update Celltrace Flag
    Wait Until Keyword Succeeds   3x   1m   Check Session Setup
    Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir

Make L3CALL And Get ALL PCMD MSG
    ${curr_date}   DateTime.Get Current Date   result_format=%Y%m%d_%H%M   exclude_millis=True
    Start Tcpdump To Get PCMD   pcmd_file=TCPDUMP_${curr_date}.pcap
    # L3CALL Precondition
    # Wait Until Keyword Succeeds   3x   10s   Attach UE and Detach
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

Make L3CALL And Get ALL PCMD TCPDUMP File
    [Arguments]   ${ue_index}=${ue_index}    ${tcptump_path}=None
    ${curr_date}   DateTime.Get Current Date   result_format=%Y%m%d_%H%M   exclude_millis=True
    Start Tcpdump To Get PCMD   pcmd_file=TCPDUMP_${curr_date}.pcap
    # L3CALL Precondition
    # Wait Until Keyword Succeeds   3x   10s   Attach UE and Detach
    Run Keyword and Ignore Error   Wait Until Keyword Succeeds   2x   20s
    ...   Call Setup and check tput   ue_index=${ue_index}   duration=60    tput=100    tput_expect=50   4G_check=false
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
    Run Keyword If   '${mode_status}'!='0'   Sleep   10s
    ...   ELSE    UE Forced Reboot   ue_index=${ue_index}   detach_request=${false}

Detach UE BETA
    [Arguments]   ${ue_index}=${ue_index}
    Run Keyword And Ignore Error   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

Trigger INTRA HO
    # SET PA Initial value
    # Set TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL864 cell2(intraHOtargetcell) (A3-B3,A4-B4) value to 40
    # Set TL865 cell1(interHOtargetcell) (A5-B5,A6-B6) value to 127
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=20
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=40
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=127

    Start Tcpdump To Get PCMD   pcmd_file=${INTRA_HO_FILE}
    # L3CALL Precondition
    # Wait Until Keyword Succeeds   3x   10s   Attach UE BETA
    Wait Until Keyword Succeeds   3x   20s   Call Setup and check tput   tput=100   tput_expect=10   traffic_stop=${false}   duration=900s


    # trigger Intra gnb HO by adjust adjustable attenuation
    # Keep TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL864 cell2(intraHOtargetcell) (A3-B3,A4-B4) value to 0
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=0
    Sleep   30s


    # power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL
    # power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

    # Stop Tcpdump To Get PCMD   pcmd_file=INTRA_HO.pcap

    # Run Keyword And Ignore Error   Detach UE BETA
    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL   AND
    ...   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   AND
    ...   Stop Tcpdump To Get PCMD   pcmd_file=${INTRA_HO_FILE}

Trigger INTER HO
    # SET PA Initial value
    # Set TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL864 cell2(intraHOtargetcell) (A3-B3,A4-B4) value to 40
    # Set TL865 cell1(interHOtargetcell) (A5-B5,A6-B6) value to 127
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=20
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=127
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=40

    Start Tcpdump To Get PCMD
    ...   hostname=${PEER_SSH_ADDR}   username=${PEER_SSH_USER}   password=${PEER_SSH_PWD}   connection=PEER
    ...   pcmd_file=${INTER_HO_FILE}
    # L3CALL Precondition
    # Wait Until Keyword Succeeds   3x   10s   Attach UE BETA
    Wait Until Keyword Succeeds   3x   20s   Call Setup and check tput   tput=100   tput_expect=10   traffic_stop=${false}   duration=900s

    # trigger Intra gnb HO by adjust adjustable attenuation
    # Keep TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL865 cell1(interHOtargetcell) (A5-B5,A6-B6) value to 5
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=5
    Sleep   30s

    # power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL
    # power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

    # Stop Tcpdump To Get PCMD   pcmd_file=INTER_HO.pcap

    # Run Keyword And Ignore Error   Detach UE BETA
    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL   AND
    ...   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   AND
    ...   Stop Tcpdump To Get PCMD
    ...      hostname=${PEER_SSH_ADDR}   username=${PEER_SSH_USER}   password=${PEER_SSH_PWD}   connection=PEER
    ...      pcmd_file=${INTER_HO_FILE}

Initialize PA
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=20
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=127
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=127

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
    # SET PA Initial value
    # Set TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL864 eNB cell1(sourcecell) (A1-B1,A2-B2) value to 20 127 for NSA, 127 127 for SA
    # Set TL864 cell2(intraHOtargetcell) (A3-B3,A4-B4) value to 40
    # Set TL865 cell1(interHOtargetcell) (A5-B5,A6-B6) value to 127
    ${value_init}   run keyword if   '${type}'=='NSA'   Create List   20   20   20   127
    ...   ELSE   Create List   20   20   127   127
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=${value_init}
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=40
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=127

    Start Tcpdump To Get PCMD   pcmd_file=${INTRA_HO_filename}
    # L3CALL Precondition
    # Wait Until Keyword Succeeds   3x   10s   Attach UE BETA
    Wait Until Keyword Succeeds   3x   20s   Call Setup and check tput   ue_index=${ue_index}   tput=100   tput_expect=10
    ...   traffic_stop=${false}   duration=900s


    # trigger Intra gnb HO by adjust adjustable attenuation
    # Keep TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL864 cell2(intraHOtargetcell) (A3-B3,A4-B4) value to 0
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=0
    Sleep   5s


    # power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL
    # power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

    # Stop Tcpdump To Get PCMD   pcmd_file=INTRA_HO.pcap

    # Run Keyword And Ignore Error   Detach UE BETA
    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL   AND
    ...   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   AND
    ...   Stop Tcpdump To Get PCMD   pcmd_file=${INTRA_HO_filename}

Trigger INTER gNB HO
    [Arguments]   ${ue_index}   ${INTRA_HO_target_filename}   ${INTRA_HO_source_filename}=None   ${type}=NSA
    # SET PA Initial value
    # Set TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL864 eNB cell1(sourcecell) (A1-B1,A2-B2) value to 20 127 for NSA, 127 127 for SA
    # Set TL864 cell2(intraHOtargetcell) (A3-B3,A4-B4) value to 40
    # Set TL865 cell1(interHOtargetcell) (A5-B5,A6-B6) value to 127
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
    # L3CALL Precondition
    # Wait Until Keyword Succeeds   3x   10s   Attach UE BETA
    Wait Until Keyword Succeeds   3x   20s   Call Setup and check tput   ue_index=${ue_index}   tput=100   tput_expect=10
    ...   traffic_stop=${false}   duration=900s

    # trigger Intra gnb HO by adjust adjustable attenuation
    # Keep TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL865 cell1(interHOtargetcell) (A5-B5,A6-B6) value to 5
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=5
    Sleep   5s

    # power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL
    # power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

    # Stop Tcpdump To Get PCMD   pcmd_file=INTER_HO.pcap

    # Run Keyword And Ignore Error   Detach UE BETA
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
    # SET PA Initial value
    # Set TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL864 eNB cell1(sourcecell) (A7-B7,A8-B8) value to 20  30
    # Set TL864 cell2(intraHOtargetcell) (A3-B3,A4-B4) value to 127
    # Set TL865 cell1(interHOtargetcell) (A5-B5,A6-B6) value to 127
    ${value_init}   Create List   20   20   20   30
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=${value_init}
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=127
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=127

    Start Tcpdump To Get PCMD
    ...   hostname=${ip}   username=${user}   password=${password}   connection=LOCAL
    ...   pcmd_file=${INTRA_HO_filename}
    # L3CALL Precondition
    # Wait Until Keyword Succeeds   3x   10s   Attach UE BETA
    Wait Until Keyword Succeeds   3x   20s   Call Setup and check tput   ue_index=${ue_index}   tput=100   tput_expect=10
    ...   traffic_stop=${false}   duration=900s

    # trigger Intra gnb HO by adjust adjustable attenuation
    # Keep TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL864 eNB cell1(interHOtargetcell) (A5-B5,A6-B6) value to 20 10
    ${value_change}   Create List   20   20   20   10
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=${value_change}
    Sleep   5s

    # power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL
    # power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

    # Stop Tcpdump To Get PCMD   pcmd_file=INTER_HO.pcap

    # Run Keyword And Ignore Error   Detach UE BETA
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
#    set suite variable     ${snapshot_path}    ${OUTPUT_DIR}/snapshot_${curr_data}.zip
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

Initial PA For SA Call
    Modify All Attenuation Ports Value For Specific RU    gnb_id=0    RU_id=0    value=20
    Modify All Attenuation Ports Value For Specific RU    gnb_id=0    RU_id=1    value=127
    Modify All Attenuation Ports Value For Specific RU    gnb_id=1    RU_id=0    value=127
    Modify All Attenuation Ports Value For eNB Specific RU    enb_id=0    RU_id=0    value=127
    Modify All Attenuation Ports Value For eNB Specific RU    enb_id=1    RU_id=0    value=127

Initial PA For NSA Call
    Modify All Attenuation Ports Value For Specific RU    gnb_id=0    RU_id=0    value=20
    Modify All Attenuation Ports Value For Specific RU    gnb_id=0    RU_id=1    value=127
    Modify All Attenuation Ports Value For Specific RU    gnb_id=1    RU_id=0    value=127
    Modify All Attenuation Ports Value For eNB Specific RU    enb_id=0    RU_id=0    value=0
    Modify All Attenuation Ports Value For eNB Specific RU    enb_id=1    RU_id=0    value=127

Set PA To Trigger NSA Intra-DU Handover Bi Direction
    Modify All Attenuation Ports Value For Specific RU    gnb_id=0    RU_id=1    value=10
    Sleep    10s
    Modify All Attenuation Ports Value For Specific RU    gnb_id=0    RU_id=1    value=30

Set PA To Trigger NSA Inter MeNB Without PScell Change Bi Direction
    Modify All Attenuation Ports Value For eNB Specific RU    enb_id=0    RU_id=0    value=20
    Sleep     10s
    Modify All Attenuation Ports Value For eNB Specific RU    enb_id=1    RU_id=0    value=0
    Sleep     5s

Get eNB Attenuation Channels For RU
    [Documentation]    Auther:Jing.Qu@nokia-sbell.com
    ...                To get channel ports  of attenuation which connect to RU.
    ...                :param RU_id <str> : ru id which get form Testline Configuration, default is 0
    ...                :Return attenuation_port_numbers<list> : eg [9:10]
    [Arguments]    ${RU_id}=0    ${enb_id}=0
    ${attenuation_channels}     set variable    ${tl.enbs[${enb_id}].rms[0].attenuation_ports}
    @{attenuation_port_numbers}    create list
    ${channel_numbers}     Get Length       ${attenuation_channels}
    FOR  ${index}  IN RANGE   ${channel_numbers}
        ${channel_port}   set variable    ${tl.enbs[${enb_id}].rms[0].attenuation_ports[${index}].port_no}
        Append To List     ${attenuation_port_numbers}    ${channel_port}
    END
    [Return]    ${attenuation_port_numbers}

Modify All Attenuation Ports Value For eNB Specific RU
    [Documentation]   Jing.Qu@nokia-sbell.com
    ...           Modify all atteuation ports for specific RU to some value.
    ...           :param RU_id <str> : ru id which you want to operate
    ...           :param att_id <str> : <id> for example 0 or 1, if several attenuators used and RU id is not the same with att id.
    ...                                ${None} as default, if more than one PAs and RUs defined in init.py.
    ...                                        please set RU id the same with Attenuator id in init.py,
    ...                                               even attenuator0 and attenuator1 has the same ip.
    ...                                         for example, RU0 use _attenuator_0(10.57.232.105, port 3&4)
    ...                                                      RU1 use _attenuator_1(10.57.232.105, port 7&8)
    ...           :param ${value}: <list> or <string>, it can be several values or only one.
    ...           for example:
    ...           if ${value} = [10, 20, 20, 30], it means port 5=10, 6=20, 7=20, 9=30.
    ...           if ${value} = 10, it will set all ports under RU to value 10.
    [Arguments]    ${value}    ${RU_id}=0    ${enb_id}=0    ${att_id}=${None}
    ${all_channels}    Get eNB Attenuation Channels For RU    RU_id=${RU_id}    enb_id=${enb_id}
    ${att_obj_in_ru_port}    Set Variable    ${tl.enbs[${enb_id}].rms[0].attenuation_ports[0].attenuator}
    ${att_index}    Get Index From List    ${tl.attenuators}    ${att_obj_in_ru_port}
    ${is_single_att_used}    Get Variable Value    ${tl.attenuator.vendor}
    ${ip_addr}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.ip_addr}    ${tl.attenuators[${att_index}].ip_addr}
    ${port}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.port}    ${tl.attenuators[${att_index}].port}
    ${vendor}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.vendor}    ${tl.attenuators[${att_index}].vendor}
    ${model}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.model}    ${tl.attenuators[${att_index}].model}
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${ip_addr}
    ...    port=${port}
    ...    attenuation_port_numbers=${all_channels}
    ...    vendor=${vendor}
    ...    model=${model}
    ${value_type}    Evaluate    type(${value}).__name__
    ${channels_to_modify}    Create Dictionary
    FOR    ${channel}    IN    @{all_channels}
        ${index} =    get index from list    ${all_channels}    ${channel}
        ${value_dict}    set variable if    'list' in '${value_type}'    ${value}[${index}]    ${value}
        ${channel}    Convert To String    ${channel}
        Set To Dictionary    ${channels_to_modify}    ${channel}    ${value_dict}
    END
    Log To Console    ${channels_to_modify}
    Modify eNB Attenuation    channels_to_modify=${channels_to_modify}
    ...    RU_id=${ru_id}    enb_id=${enb_id}    attenuator_device=${configured_attenuator}

Modify eNB Attenuation
    [Documentation]    Auther:Jing.Qu@nokia-sbell.com
    ...                <<Keyword>> is to modify values of attenuation which connect to RU.
    ...                :param channels_to_modify <dict>:channel ports and values which need to modify in programmable attenuation.
    ...                 for example: &{channels_to_modify}    create dictionary   9=20   10=20
    ...                 in this way, you want to set Port "9" to value "20".
    [Arguments]    ${channels_to_modify}    ${attenuator_device}=${None}    ${RU_id}=0    ${enb_id}=0
    ${attenuation_port_numbers} =     Get eNB Attenuation Channels For RU    RU_id=${RU_id}    enb_id=${enb_id}
    @{channelports_to_modify}    get dictionary keys      ${channels_to_modify}
    @{ports}    Create List
    @{values}    Create List
    FOR    ${item}    IN    @{channelports_to_modify}
        ${item} =    Convert To Integer    ${item}
        ${channelport_value}    Evaluate    float(${channels_to_modify['${item}']})
        List Should Contain Value    ${attenuation_port_numbers}    ${item}
        ${index} =    Get Index From List    ${attenuation_port_numbers}    ${item}
        ${port} =    Convert To Integer    ${attenuation_port_numbers[${index}]}
        Append To List    ${ports}    ${port}
        Append To List    ${values}    ${channelport_value}
    END
    Run Keyword If    '${attenuator_device}' is '${None}'
    ...    Modify Attenuation Port One By One And Verify    ports=${ports}    values=${values}    attenuator_device=${attenuator_device}
    ...    ELSE IF     'topyoung' in '${attenuator_device}'
    ...             Modify Attenuation Port One By One And Verify   ports=${ports}    values=${values}    attenuator_device=${attenuator_device}
    ...    ELSE    Modify Attenuation Ports And Verify    ports=${ports}    values=${values}    attenuator_device=${attenuator_device}
    Log To Console    \n change attenuation to ${channels_to_modify}

Make L3 Call And Trigger Inter_MeNB Handover
    # Set PA for NSA call initiate
    Initial PA For NSA Call
    # detach UE for precondition
    # start tcpdump on gNB which will save the .pcap file on /tmp/pcmd_file
    Start Tcpdump To Get PCMD   pcmd_file=${NSA_INTER_MeNB_HO_FILE}
    # Make Call And Keep dumping while TCP dump ongoing
    Wait Until Keyword Succeeds   1x   20s   Call Setup and check tput    tput=100   tput_expect=10
    ...   traffic_stop=${false}   duration=900s
    Set PA To Trigger NSA Inter MeNB Without PScell Change Bi Direction
    Sleep    5s
    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   Initial PA For NSA Call     AND
    ...   power_ue.Stop traffic    ue_type=${tl.ues[${ue_index}].capabilities[1]}   direction=DL   AND
    ...   power_ue.UE Detach   ue_type=${tl.ues[${ue_index}].capabilities[1]}   ue_index=${ue_index}   AND
    ...   Stop Tcpdump To Get PCMD    pcmd_file=${NSA_INTER_MeNB_HO_FILE}
    
Make L3 Call and Capture Tcpdump Log
    #COAM Update PCMD Flag    true 
    Start Tcpdump To Get PCMD   pcmd_file=${pcmd_file_webui}
    nokia_fastmile.Prepare UE
    nokia_fastmile.UE Attach
    nokia_fastmile.Verify attach
    Sleep   3s
    nokia_fastmile.UE Detach                                                                     
    Stop Tcpdump To Get PCMD    pcmd_file=${pcmd_file_webui}
    
Make L3 Call and Capture Tcpdump Log with NsaInactivityTimer Equal to 0
    #COAM Update PCMD Flag    true 
    Start Tcpdump To Get PCMD   pcmd_file=${pcmd_file_webui}_nsaInactivityTimer
    nokia_fastmile.Prepare UE
    nokia_fastmile.UE Attach
    nokia_fastmile.Verify attach
    Sleep   30s
    nokia_fastmile.UE Detach                                                                     
    Stop Tcpdump To Get PCMD    pcmd_file=${pcmd_file_webui}_nsaInactivityTimer

Make L3 Call and Capture Tcpdump Log with MaxNumOfUsersNRCell Equal to 0
    #COAM Update PCMD Flag    true 
    Start Tcpdump To Get PCMD   pcmd_file=${pcmd_file_webui}_maxNumOfUsersNRCell
    nokia_fastmile.Prepare UE
    nokia_fastmile.UE Attach
    nokia_fastmile.Verify attach
    Sleep   2s
    nokia_fastmile.UE Detach                                                                     
    Stop Tcpdump To Get PCMD    pcmd_file=${pcmd_file_webui}_maxNumOfUsersNRCell
