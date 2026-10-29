*** Settings ***
Documentation
   ...  author: Heng Liangliang
   ...  common keywords for CB007732

Library     String
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME   csn
Library     taf.analyzer.pcap   WITH NAME   wireshark
Library     ute_wtssim
#Library     ../../libraries/nms_vars.py
Library     ../Library/emil_messages.py
#Library     ../Library/common.py
Variables    ../../libraries/global_vars.py
Variables    ../Library/SubscriberTrace_var.py
Variables    ../Library/emil_vars.py
Variables    ../Library/emil_messages.py

Resource    COAM.robot
Resource    DCAP.robot
Resource    Core_Sim.robot
# Resource    ../../5GC001778/Resource/emil.robot
# Resource    ../../5GC001778/Resource/collect_log.robot
Resource    ../../common/taf_coam.robot
Resource    ../../common/taf_log.robot
Resource    ../../common/qc_tag.robot
Resource    ../../common/gnb.robot
Resource    ../../UUF/Resource/common.robot
#Resource    ../../5GI000114/Resource/NetAct_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
#Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot


*** Variables ***
${INTRA_HO_FILE}   INTRA_HO.pcap
${INTER_HO_XN_SOURCE_FILE}   INTER_HO_xn_source.pcap
${INTER_HO_XN_TARGET_FILE}   INTER_HO_xn_target.pcap
${INTER_HO_NG_SOURCE_FILE}   INTER_HO_ng_source.pcap
${INTER_HO_NG_TARGET_FILE}   INTER_HO_ng_target.pcap
${INTRA_HO_PATH}   ${OUTPUT_DIR}/${INTRA_HO_FILE}
${remote_dir_path}   /tmp
${pcmd_file}   PCMD_5G.pcap
${pcmd_file_webui}   PCMD_webui.pcap
${pcmd_file_netact}   PCMD_netact.pcap
${pcmd_file_webui_de}   PCMD_webui_de.pcap
${pcmd_file_netact_de}   PCMD_netact_de.pcap
${core_sim_scf_path}      /home/ute/WTS_1005
@{core_sim_scf_file}      SBTS24R3_CORE_SIM.xml   SBTS25R1_CORE_SIM.xml    TRUNK_CORE_SIM.xml


*** Keyword ***
Common Suite Setup for 7732
    Wait Until Keyword Succeeds    3x   30s   COAM Login
    Log to console   Commission BTS with WTS Configeration
    ${release}   COAM Get SW Release
#    ${release}   Get gnb release   host=${WEBUI_ADDR}
    # AMFIP=10.57.167.17 in /home/ute/WTS_1005/TRUNK_CORE_SIM.xml
    Run Keyword If   '${release}' == 'SBTS24R3'    COAM SCF Commission    filepath=${core_sim_scf_path}/${core_sim_scf_file}[0]
    ...   ELSE IF  '${release}' == 'SBTS25R1'    COAM SCF Commission    filepath=${core_sim_scf_path}/${core_sim_scf_file}[1]
#    ...   ELSE IF  '${release}' == 'SBTS23R3'    COAM SCF Commission    filepath=${core_sim_scf_path}/${core_sim_scf_file}[2]
    ...   ELSE   COAM SCF Commission    filepath=${core_sim_scf_path}/${core_sim_scf_file}[2]
    Log to console   Retart WTS if BTS not on air after recommission...
    Recover WTS If Issue Occurred
    robot_common_operations.Common Suite Setup
#    robot_common_operations.Common Case Setup  allowed_faults_ids=7305,8000
#    Restart WTS on UTE VM
#    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
#    Log To Console    after coam commissioning if not onair
#    Wait Until Keyword Succeeds   5m   1m   COAM Login
#    Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir
#    Log To Console    COAM Check BTS OnAir
    COAM Backup SCF
    COAM Backup Full SCF
    Reboot UE For 7732   ue_index=${0}
    sleep    90s
    Check UE For 7732   ue_index=${0}
#    Log To Console   Waiting for sync with scout
#    Sleep   5min
    Run Keyword And Ignore Error   Start Syslog Collection

Common Teardown for 7732
    robot_common_operations.Common Suite Teardown
    Check Extra Reset From Blackbox
    Run Keyword And Ignore Error   Save Logs If Case Failed
    Run Keyword And Ignore Error   Check Error Log From Syslog
    Wait Until Keyword Succeeds    3x   15s   COAM Login
    Run Keyword And Ignore Error   COAM SCF Commission
    ...   filepath=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_with_real_AMF.xml
    Run Keyword And Ignore Error   COAM Logout

Attach UE and Detach
    [Arguments]   ${ue_index}=${ue_index}
    Attach UE BETA   ue_index=${ue_index}
    [Teardown]   Detach UE BETA   ue_index=${ue_index}

Attach UE Again
    [Arguments]   ${ue_index}=${ue_index}    ${gnb_index}=${0}
    ${mode_status}   Get UE Airmode status   ue_index=${ue_index}
    run keyword if  not '${mode_status}'=='1'   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
    power_ue.UE Attach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}    gnb_index=${gnb_index}
    ${mode_status}   Get UE Airmode status   ue_index=${ue_index}
    Run Keyword If   '${mode_status}'!='0'   Sleep   10s
    ...   ELSE    UE Forced Reboot   ue_index=${ue_index}   detach_request=${false}

Detach UE Again
    [Arguments]   ${ue_index}=${ue_index}
    Run Keyword And Ignore Error   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

Case Teardown for CB007732-5G-A-17
     AMF Restore Guamis

Case Teardown for CB007732-5G-A-02
    Log To Console   Case Teardown: CB007732-5G-A-02
    Kill egate and edaemon
    Start WTS on UTE    WTS_CFG=${WTS_CFG}
    Check NG link Up
    Run Keyword And Ignore Error   Initialize PA for CB007732-5G-A-02

Case Teardown for CB007732-5G-A-13
    Log To Console   Case Teardown: CB007732-5G-A-13
    Kill egate and edaemon
    Start WTS on UTE     WTS_CFG=${WTS_CFG}
    Check NG link Up
    Run Keyword And Ignore Error   Initialize PA for CB007732-5G-A-13

Case Teardown for CB007732-5G-A-15
    Log To Console   Case Teardown: CB007732-5G-A-15
    Stop Trace of NGAP Handover Request
    COAM Xn HO
    Run Keyword And Ignore Error   Initialize PA for CB007732-5G-A-15

Get HO Suite Variables
    Set Suite Variable   ${LOCAL_SSH_ADDR}   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Set Suite Variable   ${LOCAL_SSH_USER}   ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    Set Suite Variable   ${LOCAL_SSH_PWD}   ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    Set Suite Variable   ${MRBTS_ID}   ${tl.gnbs[0].instance_id}
    Set Suite Variable   ${NRBTS_ID}   ${tl.gnbs[0].global_bts_id}
    Set Suite Variable   ${MRBTS}   MRBTS-${MRBTS_ID}
    Set Suite Variable   ${NRBTS}   NRBTS-${NRBTS_ID}
    Set Suite Variable   ${INSID}   ${MRBTS}/${NRBTS}
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

    ${SMOD_NAME}   Get SMOD Product Name
    Set Suite Variable   ${SMOD_NAME}

    ${peer_mcc}   XML.Get Element Text   ${peer_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="mcc"]
    ${peer_mnc}   XML.Get Element Text   ${peer_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="mnc"]
    ${peer_mnclength}   XML.Get Element Text   ${peer_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="mncLength"]

    ${peer_tmp}   Set Variable If
    ...   '${peer_mnclength}'=='2'   ${peer_mcc}f${peer_mnc.zfill(int(${peer_mnclength}))}
    ...   '${peer_mnclength}'=='3'   ${peer_mcc}${peer_mnc.zfill(int(${peer_mnclength}))}
    Set Suite Variable   ${PEER_PLMN_IDENTITY}   ${peer_tmp[1]}${peer_tmp[0]}${peer_tmp[3]}${peer_tmp[2]}${peer_tmp[5]}${peer_tmp[4]}

    ${local_xml}   XML.Parse XML   ${OUTPUT_DIR}/full_commission.xml
    ${nrcellid_source}   XML.Get Element Text   ${peer_xml}   xpath=cmData/managedObject[@distName="${PEER_INSID}/NRCELL-1"]/p[@name="nrCellIdentity"]
    Set Suite Variable   ${nrcellid_source}
    ${nrcellid_target}   XML.Get Element Text   ${peer_xml}   xpath=cmData/managedObject[@distName="${PEER_INSID}/NRCELL-2"]/p[@name="nrCellIdentity"]
    Set Suite Variable   ${nrcellid_target}
    ${drx_source}   XML.Get Element Text   ${peer_xml}   xpath=cmData/managedObject[@distName="${PEER_INSID}/NRCELL-1"]/p[@name="actCDrx"]
    Set Suite Variable   ${drx_source}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=PEER


Trigger INTER gNB HO
    [Arguments]   ${ue_index}=0  ${INTER_HO_target_filename}=${INTER_HO_XN_TARGET_FILE}   ${INTER_HO_source_filename}=${INTER_HO_XN_SOURCE_FILE}
    # SET PA Initial value
    # Set TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL864 eNB cell1(sourcecell) (A1-B1,A2-B2) value to 20 127 for NSA, 127 127 for SA
    # Set TL864 cell2(intraHOtargetcell) (A3-B3,A4-B4) value to 127
    # Set TL865 cell1(interHOtargetcell) (A5-B5,A6-B6) value to 40
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=20
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=1   value=127
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=40
    Sleep   30s
    Start Tcpdump To Get PCMD
    ...   hostname=${PEER_SSH_ADDR}   username=${PEER_SSH_USER}   password=${PEER_SSH_PWD}   connection=PEER
    ...   pcmd_file=${INTER_HO_target_filename}
    Start Tcpdump To Get PCMD
    ...   hostname=${LOCAL_SSH_ADDR}  username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   connection=LOCAL
    ...   pcmd_file=${INTER_HO_source_filename}

     UE precondition   ue_index=0
     Attach UE BETA
     UE Status Checking
     Trace Start

#    Wait Until Keyword Succeeds   3x   20s   Call Setup and check tput   tput=100   tput_expect=10   traffic_stop=${false}   duration=900s
     Start Android UE L3 Call with core-sim without Attach   duration=60   tput=100   tput_expect=10   4G_check=false

    # L3CALL Precondition
    # Wait Until Keyword Succeeds   3x   10s   Attach UE BETA
#    Wait Until Keyword Succeeds   3x   20s   Call Setup and check tput   ue_index=${ue_index}   tput=100   tput_expect=10
#    ...   traffic_stop=${false}   duration=900s

    # trigger Intra gnb HO by adjust adjustable attenuation
    # Keep TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL865 cell1(interHOtargetcell) (A5-B5,A6-B6) value to 5
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=10
    Sleep   30s
    Trace Stop
    # power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL
    # power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

    # Stop Tcpdump To Get PCMD   pcmd_file=INTER_HO.pcap

    # Run Keyword And Ignore Error   Detach UE BETA
    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL   AND
    ...   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   AND
    ...   Stop Tcpdump To Get PCMD
    ...      hostname=${PEER_SSH_ADDR}   username=${PEER_SSH_USER}   password=${PEER_SSH_PWD}   connection=PEER
    ...      pcmd_file=${INTER_HO_target_filename}
    ...   AND   Stop Tcpdump To Get PCMD
    ...      hostname=${LOCAL_SSH_ADDR}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   connection=LOCAL
    ...      pcmd_file=${INTER_HO_source_filename}

Trigger INTER gNB HO NG
    [Arguments]   ${ue_index}=0  ${INTER_HO_target_filename}=${INTER_HO_NG_TARGET_FILE}   ${INTER_HO_source_filename}=${INTER_HO_NG_SOURCE_FILE}
    # SET PA Initial value
    # Set TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL864 eNB cell1(sourcecell) (A1-B1,A2-B2) value to 20 127 for NSA, 127 127 for SA
    # Set TL864 cell2(intraHOtargetcell) (A3-B3,A4-B4) value to 127
    # Set TL865 cell1(interHOtargetcell) (A5-B5,A6-B6) value to 40
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=20
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=1   value=127
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=40
    Sleep   30s
    NGAP Handover Request
    Start Tcpdump To Get PCMD
    ...   hostname=${PEER_SSH_ADDR}   username=${PEER_SSH_USER}   password=${PEER_SSH_PWD}   connection=PEER
    ...   pcmd_file=${INTER_HO_target_filename}
    Start Tcpdump To Get PCMD
    ...   hostname=${LOCAL_SSH_ADDR}  username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   connection=LOCAL
    ...   pcmd_file=${INTER_HO_source_filename}

     UE precondition   ue_index=0
     Attach UE BETA
     UE Status Checking

#    Wait Until Keyword Succeeds   3x   20s   Call Setup and check tput   tput=100   tput_expect=10   traffic_stop=${false}   duration=900s
     Start Android UE L3 Call with core-sim without Attach   duration=60   tput=100   tput_expect=10   4G_check=false

    # L3CALL Precondition
    # Wait Until Keyword Succeeds   3x   10s   Attach UE BETA
#    Wait Until Keyword Succeeds   3x   20s   Call Setup and check tput   ue_index=${ue_index}   tput=100   tput_expect=10
#    ...   traffic_stop=${false}   duration=900s

    # trigger Intra gnb HO by adjust adjustable attenuation
    # Keep TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL865 cell1(interHOtargetcell) (A5-B5,A6-B6) value to 5
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=10
    Sleep   30s
    Trace Stop
    # power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL
    # power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

    # Stop Tcpdump To Get PCMD   pcmd_file=INTER_HO.pcap

    # Run Keyword And Ignore Error   Detach UE BETA
    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL   AND
    ...   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   AND
    ...   Stop Tcpdump To Get PCMD
    ...      hostname=${PEER_SSH_ADDR}   username=${PEER_SSH_USER}   password=${PEER_SSH_PWD}   connection=PEER
    ...      pcmd_file=${INTER_HO_target_filename}
    ...   AND   Stop Tcpdump To Get PCMD
    ...      hostname=${LOCAL_SSH_ADDR}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   connection=LOCAL
    ...      pcmd_file=${INTER_HO_source_filename}
    ...   AND    Stop Trace of NGAP Handover Request

Trigger INTRA gNB HO
    [Arguments]   ${ue_index}=0    ${INTRA_HO_filename}=${INTRA_HO_FILE}
    Log To Console  "${INTRA_HO_filename}"
    # SET PA Initial value
    # Set TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL864 eNB cell1(sourcecell) (A1-B1,A2-B2) value to 20 127 for NSA, 127 127 for SA
    # Set TL864 cell2(intraHOtargetcell) (A3-B3,A4-B4) value to 40
    # Set TL865 cell1(interHOtargetcell) (A5-B5,A6-B6) value to 127
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=127
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=20
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=1   value=127
    Sleep   60s

    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=1   value=40
    Sleep   60s
    Start Tcpdump To Get PCMD
    ...   hostname=${PEER_SSH_ADDR}   username=${PEER_SSH_USER}   password=${PEER_SSH_PWD}   connection=PEER
    ...   pcmd_file=${INTRA_HO_FILE}
    # L3CALL Precondition
    # Wait Until Keyword Succeeds   3x   10s   Attach UE BETA
#    Wait Until Keyword Succeeds   3x   20s   Call Setup and check tput   ue_index=${ue_index}   tput=100   tput_expect=10
#    ...   traffic_stop=${false}   duration=900s

     UE precondition   ue_index=0
     Attach UE BETA    gnb_index=1
     UE Status Checking
     Trace Start

#    Wait Until Keyword Succeeds   3x   20s   Call Setup and check tput   tput=100   tput_expect=10   traffic_stop=${false}   duration=900s
     Start Android UE L3 Call with core-sim without Attach   duration=60   tput=100   tput_expect=10   4G_check=false   gnb_index=1

    # trigger Intra gnb HO by adjust adjustable attenuation
    # Keep TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # Set TL864 cell2(intraHOtargetcell) (A3-B3,A4-B4) value to 0
     Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=1   value=5
     Sleep   30s
     Trace Stop

    # power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL
    # power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}

    # Stop Tcpdump To Get PCMD   pcmd_file=INTRA_HO.pcap

    # Run Keyword And Ignore Error   Detach UE BETA
    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   power_ue.Stop traffic    ue_type=${ue_${ue_index}_type}   direction=DL   AND
    ...   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   AND
    ...   Stop Tcpdump To Get PCMD
    ...      hostname=${PEER_SSH_ADDR}   username=${PEER_SSH_USER}   password=${PEER_SSH_PWD}   connection=PEER
    ...      pcmd_file=${INTRA_HO_FILE}

Initialize PA for CB007732-5G-A-13
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=20
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=1   value=127
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=127

Initialize PA for CB007732-5G-A-02
    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=20
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=1   value=127
    Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=20

Start Tcpdump To Get PCMD
    [Arguments]   ${remote_dir_path}=${remote_dir_path}   ${pcmd_file}=${pcmd_file}
    ...   ${hostname}=${LOCAL_SSH_ADDR}   ${username}=${LOCAL_SSH_USER}   ${password}=${LOCAL_SSH_PWD}   ${connection}=LOCAL
    csn.Connect To   hostname=${hostname}   username=${username}   password=${password}   alias=${connection}
    ${eth_port}   Set Variable If
    ...   '${SMOD_NAME}'=='ASIK'   fp0
    ...   '${SMOD_NAME}'=='ASIB'   br1
    ...   '${SMOD_NAME}'=='ASIL'   br0
    ...   '${SMOD_NAME}'=='ASOE'   br0
    ${any_port}   Set Variable   any
    ${is_CRT}   run keyword and return status   should contain    ${OUTPUT_DIR}   CRT
    ${port}   set variable if   ${is_CRT}   any   ${eth_port}
    csn.Send Command   command=tcpdump -i ${port} -w ${remote_dir_path}/${pcmd_file} &> /dev/null &   connection=${connection}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}

Stop Tcpdump To Get PCMD
    [Arguments]   ${remote_dir_path}=${remote_dir_path}   ${pcmd_file}=${pcmd_file}
    ...   ${hostname}=${LOCAL_SSH_ADDR}   ${username}=${LOCAL_SSH_USER}   ${password}=${LOCAL_SSH_PWD}   ${connection}=LOCAL
    csn.Connect To   hostname=${hostname}   username=${username}   password=${password}   alias=${connection}
    ${eth_port}   Set Variable If
    ...   '${SMOD_NAME}'=='ASIK'   fp0
    ...   '${SMOD_NAME}'=='ASIB'   br1
    ...   '${SMOD_NAME}'=='ASIL'   br0
    ...   '${SMOD_NAME}'=='ASOE'   br0
    ${any_port}   Set Variable   any
    ${is_CRT}   run keyword and return status   should contain    ${OUTPUT_DIR}   CRT
    ${port}   set variable if   ${is_CRT}   any   ${eth_port}
    csn.Execute   command=ps -ef | grep ${remote_dir_path}/${pcmd_file} | grep -v grep | awk '{print $2}' | xargs kill -9   connection=${connection}
    csn.Execute   command=ps -ef|grep tcpdump|grep -v grep|grep ${port}   connection=${connection}
    csn.Execute   command=ps -ef|grep tcpdump|grep -v grep|grep ${port}   connection=${connection}
    csn.Download File
    ...   remote_path=${remote_dir_path}/${pcmd_file}
    ...   local_path=${OUTPUT_DIR}/${pcmd_file}
    ...   connection=${connection}
    csn.Execute   command=rm -rf ${remote_dir_path}/${pcmd_file}   connection=${connection}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}

Save Logs If Case Failed
    run keyword and ignore error    Capature Sreenshot COAM
    run keyword and ignore error    Catch Snapshot COAM
    run keyword and ignore error    Stop and Save Syslog Collection
    run keyword and ignore error    Stop and Delete Syslog Collection

Reboot UE For 7732
    [Arguments]    ${ue_type}=huawei   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    log to console    execute_ue_reboot_for_7732 ue_type=${ue_type}
    Run Keyword And Ignore Error   csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} reboot
    ...   connection=${connection}
    Run Keyword And Ignore Error   csn.disconnect      connection=${connection}

Check UE For 7732
    [Arguments]    ${ue_type}=huawei   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    log to console    check_ue_status_for_7732 ue_type=${ue_type}
    Run Keyword And Ignore Error   csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    Run Keyword And Ignore Error    csn.send_command    command=adb devices
    ...   connection=${connection}
    sleep    5s
    ${status}    run keyword and return status
    ...    csn.Read Output Until    connection=${connection}   match=${serial_number}   timeout=30
    Run Keyword And Ignore Error   csn.disconnect      connection=${connection}

Recover WTS If Issue Occurred
     Sleep  90s
     ${if_recovery_need}   Check Cell status and Alarm
     run keyword if   ${if_recovery_need}    Restart WTS on UTE VM
     ${cell_status_after_WTS_restart}   run keyword and return status
     ...   Wait Until Keyword Succeeds   10m   15s   COAM Check all cells should be onair
     run keyword unless   ${cell_status_after_WTS_restart}   run keywords    COAM Reset Site
     ...   AND   Wait Until Keyword Succeeds   15m   20s   COAM Check all cells should be onair

Check Cell status and Alarm
    [Arguments]    ${if_recovery_need}=${False}
    FOR   ${i}   IN RANGE   ${60}
        ${cell_status}   run keyword and return status   COAM Check all cells should be onair
        Exit For Loop If    ${cell_status}
        ${active_fault}    COAM Get Active Fault ID
        ${fault_status}    run keyword and return status    should contain any     ${active_fault}
        ...   ${7523}   ${7107}   ${7305}   ${7304}
        ${if_recovery_need}   Set Variable If   ${fault_status}   ${True}
        Exit For Loop If    ${fault_status}
        Sleep   15s
    END
    [Return]    ${if_recovery_need}