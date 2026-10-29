*** Settings ***
Documentation     author: Ming Lu
...               Group: HGZ_SG1
...               contact: ming.lu@nokia-sbell.com

Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Library           ../../../../SISO/RAN_PZ_HAZ_34/5GC001278/Library/get_bts_info.py    WITH NAME    lib\
Library           taf.selenium.gnb.oam.coam.classical    WITH NAME    selenium_coam
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.config.scf    WITH NAME    scf
Library           XML   WITH NAME    ParseXML
Library           taf.sw.dcap.rd                        WITH NAME    rd
Library           Process
Library           ../../5GC000638/Resources/coam_close.py
#Variables         TestData/variables.py
#Variables         ${CFGFILE_ON_GIT}/Delta_SCF.py
#Variables         ${TLDelta_PATH_ON_GIT}TLDelta.py
#Variables         ${TLDelta_PATH_ON_GIT}TLDelta_21B.py
#Variables         ${TLDelta_PATH_ON_GIT}TLDelta_SBTS.py

*** Variables ***
${SHERPA_LOG_PATH}          /home/ute/sherpa_log/

#${CFGFILE_ON_GIT}           ${CFGFILE_PATH}/5GC001817/
#${DeltaPath}                ${CFGFILE_ON_GIT}Delta_SCF.py
#${TLDelta_PATH_ON_GIT}      /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${GoldenSCF_ON_GIT}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/

${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}
${IMSI1}                     ${tl.ues[0].imsi}
${IMSI2}                     ${tl.ues[1].imsi}

${AMF_IP}                   ${tl.core.mme_ip}
${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

${ENB_WEBUI_IP}             ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENBWEBUI_URL}             https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

${PA_INFO}                  ${tl.attenuator}

${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${dist_name}                ${MRBTS_ID}/${NRBTS_ID}

${PA1_INFO}                  ${tl.attenuators[0]}
${PA2_INFO}                  ${tl.attenuators[1]}
##################define these variable for convenient############################
${UE_alias}                 UE_0
${ALIAS_5GC}                5gc
${ALIAS_AMF}                AMF
${ALIAS_ASIK}               asik
${ALIAS_ASIK_SLAVE}         asik_slave
########################END of alias Define#######################################

*** Keywords ***

####Case Level  Keywords#####

TC.5GC001817_A_05_Aperiodic CSI handling, DRX and MG disabled, with data transmission in FDD SA mode_MTK
    KW.ModifyAndCommissionAndCheckOnair    original_cfgfile=${Original_CFGFILE}    modified_cfgfile=${LOG_PATH}/1817_A_05_SCF.xml
    ...    parameters_to_modify=PARAMS_TO_MODIFY_1817_A_05    parameters_to_delete=PARAMS_TO_DELETE_1817_A_05
    ...    mo_to_add=ADD_MOS_1817_A_05    list_parameter_to_modify=LIST_PARAMS_TO_MODIFY_1817_A_05
    ...    list_to_add=LIST_TO_ADD_1817_A_05
    KW.Get NR Cell Indentities
    KW.Adjust PA before attach
    KW.Prepare and Attach UE
    KW.Start Bi Traffic and Check Throughtput with Sherpa Log Collected
    run keyword and continue on failure    DCAP.Extract_out_Log_Files   tracer=udptracer
    run keyword and continue on failure    DCAP.Decode_Sherpa_Logs
    run keyword and continue on failure    KW.Verify_Sherpa_Logs


TC.5GC001817_A_05_Aperiodic CSI handling, DRX and MG disabled, with data transmission in FDD SA mode
    Process.ModifyAndCommissionAndCheckOnair    original_cfgfile=${Original_CFGFILE}    modified_cfgfile=${LOG_PATH}/1817_A_05_SCF.xml
    ...    parameters_to_modify=${PARAMS_TO_MODIFY_1817_A_05}    parameters_to_delete=${PARAMS_TO_DELETE_1817_A_05}
    ...    mo_to_add=${ADD_MOS_1817_A_05}    list_parameter_to_modify=${LIST_PARAMS_TO_MODIFY_1817_A_05}
    ...    list_to_add=${LIST_TO_ADD_1817_A_05}
    run keyword and ignore error    KW.BtsLog.StartBTSlogCollection
    Run Keyword And Continue On Failure    KW.UE_Call_With_DL_UL_Traffic    duration_dl=1800    duration_ul=1800
    ...    throughput_dl=2MKbits/sec    throughput_ul=2MKbits/sec
    ...    check_throughput_dl=0.5     check_throughput_ul=0.5
    Run Keyword And Continue On Failure    KW.Start_Collect_Sherpa_Trace
    sleep    10s
    Run Keyword And Continue On Failure    KW.Stop_Collect_Sherpa_Trace
    run keyword and ignore error    UE.One_UE_Stop_traffic_and_Detach    ue_index=${0}   power_reset=false
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    Run Keyword And Continue On Failure    Decode_Sherpa_log_ACSI



TC.5GC001817_A_11_Aperiodic CSI handling, DRX and MG enabled, closed loop 4x4
    Process.ModifyAndCommissionAndCheckOnair    original_cfgfile=${Original_CFGFILE}    modified_cfgfile=${LOG_PATH}/1817_A_11_SCF.xml
    ...    parameters_to_modify=${PARAMS_TO_MODIFY_1817_A_11}    parameters_to_delete=${PARAMS_TO_DELETE_1817_A_11}
    ...    mo_to_add=${ADD_MOS_1817_A_11}    list_parameter_to_modify=${LIST_PARAMS_TO_MODIFY_1817_A_11}
    ...    list_to_add=${LIST_TO_ADD_1817_A_11}
#    eNB.Commission    file_path=${CFGFILE_ON_GIT}/TestLineSCFeNB.xml
    run keyword and ignore error    KW.BtsLog.StartBTSlogCollection
    Run Keyword And Continue On Failure    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Run Keyword And Continue On Failure    Wireshark.StartCaptureLogFromContainer   nodename=CPIF    filename=CPIF_1817_A11_A2enable.pcap
    Run Keyword And Continue On Failure    KW.UE_Call_With_DL_UL_Traffic    ue_index=${1}    ue_mode=NSA    attach_mode=5G_NSA
    ...    duration_dl=3600    duration_ul=3600    throughput_dl=2MKbits/sec    throughput_ul=2MKbits/sec
    ...    check_throughput_dl=0.5     check_throughput_ul=0.5    4G_check=true    imsi=${IMSI2}
    KW.PA.Adjust RU1 Attenuation to ${${CASE_INPUT_5GC001817['5GC001817_A_11']['PA_Value']}}
    sleep   10s
    Run Keyword And Continue On Failure    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    Run Keyword And Continue On Failure    wireshark.DownloadLogToUTEFromContainer   filename=CPIF_1817_A11_A2enable.pcap    nodename=CPIF
    Conn.Disconnect  alias=${ALIAS_ASIK}
    Run Keyword And Continue On Failure    KW.Start_Collect_Sherpa_Trace
    sleep   10s
    Run Keyword And Continue On Failure    KW.Stop_Collect_Sherpa_Trace
    Run Keyword And Continue On Failure    Decode_Sherpa_log_ACSI
    Run Keyword And Continue On Failure    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Run Keyword And Continue On Failure    Wireshark.StartCaptureLogFromContainer   nodename=CPIF    filename=CPIF_1817_A11_A1enable.pcap
    Run Keyword And Continue On Failure    KW.PA.Adjust RU1 Attenuation to ${0}
    sleep    10s
    Run Keyword And Continue On Failure    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    Run Keyword And Continue On Failure    wireshark.DownloadLogToUTEFromContainer   filename=CPIF_1817_A11_A1enable.pcap    nodename=CPIF
    Conn.Disconnect  alias=${ALIAS_ASIK}
    Run Keyword And Continue On Failure    KW.Start_Collect_Sherpa_Trace
    sleep   10s
    Run Keyword And Continue On Failure    KW.Stop_Collect_Sherpa_Trace
    Run Keyword And Continue On Failure    Decode_Sherpa_log_ACSI
    run keyword and ignore error   COAM_WebEM.Logout
    Run Keyword And Ignore error    UE.One_UE_Stop_traffic_and_Detach    ue_type=${UE_TYPE}    ue_index=${1}    ue_mode=NSA   power_reset=false
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    Check A2 Event    filename=CPIF_1817_A11_A2enable.pcap
    Check A1 Event    filename=CPIF_1817_A11_A1enable.pcap


TC.5GC001817_C_07_Aperiodic CSI handling, DL data load changed from high to low, then to high again
    Process.ModifyAndCommissionAndCheckOnair    original_cfgfile=${Original_CFGFILE}    modified_cfgfile=${LOG_PATH}/1817_C_07_SCF.xml
    ...    parameters_to_modify=${PARAMS_TO_MODIFY_1817_C_07}    parameters_to_delete=${PARAMS_TO_DELETE_1817_C_07}
    ...    mo_to_add=${ADD_MOS_1817_C_07}    list_parameter_to_modify=${LIST_PARAMS_TO_MODIFY_1817_C_07}
    ...    list_to_add=${LIST_TO_ADD_1817_C_07}
    run keyword and ignore error    KW.BtsLog.StartBTSlogCollection
    Run Keyword And Continue On Failure    KW.UE_Call_With_DL_Traffic    duration_dl=1600    throughput_dl=2MKbits/sec
    ...    check_throughput_dl=0.5
    Run Keyword And Continue On Failure    KW.Start_Collect_Sherpa_Trace
    sleep    5s
    KW.PA.Adjust RU1 Attenuation to ${${CASE_INPUT_5GC001817['5GC001817_C_07']['PA_Value']}}
    sleep    5s
    Run Keyword And Continue On Failure    KW.Stop_Collect_Sherpa_Trace
    Run Keyword And Continue On Failure    KW.PA.Adjust RU1 Attenuation to ${0}
    Run Keyword And Continue On Failure    KW.Decode_Sherpa_log_UCIonly
    run keyword and ignore error    UE.One_UE_Stop_traffic_and_Detach    ue_index=${0}   power_reset=false
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog



TC.5GC001817_CA_5GC001118_05_Aperiodic CSI handling, dynamic betaoffset enabled
    Process.ModifyAndCommissionAndCheckOnair    original_cfgfile=${Original_CFGFILE}    modified_cfgfile=${LOG_PATH}/1817_CA_05_SCF.xml
    ...    parameters_to_modify=${PARAMS_TO_MODIFY_1817_CA_05}    parameters_to_delete=${PARAMS_TO_DELETE_1817_CA_05}
    ...    mo_to_add=${ADD_MOS_1817_CA_05}    list_parameter_to_modify=${LIST_PARAMS_TO_MODIFY_1817_CA_05}
    ...    list_to_add=${LIST_TO_ADD_1817_CA_05}
    run keyword and ignore error    KW.BtsLog.StartBTSlogCollection
    Run Keyword And Continue On Failure    KW.UE_Call_With_DL_UL_Traffic    duration_dl=1800    duration_ul=1800
    ...    throughput_dl=2MKbits/sec    throughput_ul=2MKbits/sec
    ...    check_throughput_dl=1     check_throughput_ul=1
    Run Keyword And Continue On Failure    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Run Keyword And Continue On Failure    Wireshark.StartCaptureLogFromContainer   nodename=CPIF    filename=CPIF_1817_CA05.pcap
    KW.PA.Adjust RU1 Attenuation to ${${CASE_INPUT_5GC001817['5GC001817_CA_05']['PA_Value']}}
    sleep   10s
    Run Keyword And Continue On Failure    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    Run Keyword And Continue On Failure    wireshark.DownloadLogToUTEFromContainer   filename=CPIF_1817_CA05.pcap    nodename=CPIF
    Conn.Disconnect  alias=${ALIAS_ASIK}
    Run Keyword And Continue On Failure    KW.Start_Collect_Sherpa_Trace
    sleep   10s
    Run Keyword And Continue On Failure    KW.Stop_Collect_Sherpa_Trace
    Run Keyword And Continue On Failure    KW.PA.Adjust RU1 Attenuation to ${0}
    sleep    5s
    run keyword and ignore error    UE.One_UE_Stop_traffic_and_Detach    ue_index=${0}   power_reset=false
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
    Run Keyword And Continue On Failure    Decode_Sherpa_log_ACSI
    Wireshark.ReadLog    filename=CPIF_1817_CA05.pcap    filter=f1ap.procedureCode == 12 && nr-rrc.transformPrecoder == 0
    Run Keyword And Continue On Failure    Wireshark.CheckExpression   expression=f1ap.procedureCode == 12 && nr-rrc.transformPrecoder == 0



TC.5GC001817_D_03_Aperiodic CSI handling, SA UE peak throughput and latency with RSRP -60 dBm
    Process.ModifyAndCommissionAndCheckOnair    original_cfgfile=${Original_CFGFILE}    modified_cfgfile=${LOG_PATH}/1817_D_03_SCF.xml
    ...    parameters_to_modify=${PARAMS_TO_MODIFY_1817_D_03}    parameters_to_delete=${PARAMS_TO_DELETE_1817_D_03}
    ...    mo_to_add=${ADD_MOS_1817_D_03}    list_parameter_to_modify=${LIST_PARAMS_TO_MODIFY_1817_D_03}
    ...    list_to_add=${LIST_TO_ADD_1817_D_03}
    run keyword and ignore error    KW.BtsLog.StartBTSlogCollection
    KW.UE_Call_With_DL_UL_Traffic    duration_dl=1800    duration_ul=1800    throughput_dl=400MKbits/sec    throughput_ul=100MKbits/sec
    ...    check_throughput_dl=315     check_throughput_ul=75    traffic_time=60
    Run Keyword And Continue On Failure    KW.Start_Collect_Sherpa_Trace
    sleep   10s
    Run Keyword And Continue On Failure    KW.Stop_Collect_Sherpa_Trace
    Run Keyword And Continue On Failure    Decode_Sherpa_log_ACSI
    run keyword and ignore error    UE.One_UE_Stop_traffic_and_Detach    ue_index=${0}   power_reset=false
    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog



####Case Level Keywords#####
KW.Get NR Cell Indentities
    ${CellIndexs}   Create List    1
    ${CellIDs}   gNB.GetCellIDbyIndex    cell_index_list=${CellIndexs}
    ${first_cell_to_check}    Create List   ${CellIDs}[0]
    set test variable    ${first_cell_to_check}
#    Connect to gnb coam via ssl    connection=GNB_OAM
#    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=GNB_OAM
#    COAM Teardown gnb connections   connection=GNB_OAM
#    ${cell_id_list}    Get Dictionary Keys    ${cell_mapping}
#    ${nrCellIdentity_list}    Create List
#    FOR    ${item}    IN     @{cell_id_list}
#        ${nrCellIdentity}    Evaluate    int(${cell_mapping[${item}]['nrCellIdentity']})
#        Append To List    ${nrCellIdentity_list}    ${nrCellIdentity}
#    END
#    ${first_cell_to_check}    Create List   ${nrCellIdentity_list}[0]
#    set test variable    ${first_cell_to_check}
#    [Return]    ${nrCellIdentity_list}

KW.Adjust PA before attach
    [Arguments]
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
    ...    value=${CASE_INPUT_5GC001817['5GC001817_A_05']['PA_Value_1']}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA values for RU1 before attach.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_5GC001817['5GC001817_A_05']['PA_Value_2']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU2 before attach.

KW.PA_Adjust Attenuation Ports To Same Value
    [Arguments]    ${ports}    ${value}    ${attenuator}   ${logging_message}=Adjusting PA values
    log to console    ${logging_message}
    PA_.setup_attenuator    attenuator=${attenuator}
    ${length}    Get Length    ${ports}
    FOR    ${i}    IN RANGE    ${length}
        PA_.set_attenuation     port=${ports[${i}]}    value=${value}
        PA_.read_attenuation    port=${ports[${i}]}
    END

KW.Prepare and Attach UE
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    set test variable    ${ue_type}
    run keyword and continue on failure    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    run keyword and ignore error   power_ue.Verify attach    ue_type=${ue_type}    4G_check=False    5Grach_ed=${5Grach_ed}


KW.Start Bi Traffic and Check Throughtput with Sherpa Log Collected
    [Arguments]  ${ul_throughput}=2M   ${dl_throughput}=2M   ${duration}=1800    ${ul_target}=0.5   ${dl_target}=0.5
    run keyword and continue on failure    power_ue.Start traffic    ue_type=${ue_type}    direction=ul
    ...    throughput=${ul_throughput}   duration=${duration}
    run keyword and continue on failure    power_ue.Start traffic    ue_type=${ue_type}    direction=dl
    ...    throughput=${dl_throughput}   duration=${duration}
    sleep    40s
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=100
    run keyword and continue on failure     power_ue.Check Tput    ue_type=${ue_type}    direction=DL   log=${tput_log}
    ...    cells=${first_cell_to_check}    target_throughput=${dl_target}
    run keyword and continue on failure     power_ue.Check Tput    ue_type=${ue_type}    direction=UL   log=${tput_log}
    ...    cells=${first_cell_to_check}    target_throughput=${ul_target}
    @{traces}    create list   L2Ps_Sherpa
    run keyword and continue on failure    DCAP.Start_Collect_Trace   traces=${traces}
    sleep   10s
    run keyword and continue on failure    DCAP.Stop_Collect_Trace_and_Get_Result
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=ul

KW.Verify_Sherpa_Logs
#    [Arguments]    ${log_cheking_kws}
    [Documentation]  verify each checkpoint for sherpa.
    FOR    ${item}    IN     @{folders_for_decoded_sherpa_logs}
        KW.Check_Sherpa_log_ACSI    csv_filepath=${item}
    END

KW.Check_Sherpa_log_ACSI
    [Arguments]   ${csv_filepath}  ${acsi_mismatch_min}=-3    ${acsi_mismatch_max}=3    ${ACSI_NOK_percent}=0.03
#    ...    ${csv_filepath}=${SHERPA_LOG_PATH}${file_name}
#    KW.Start decode files
    ${num_of_ACSI_request}    run    command=cd ${csv_filepath} ; cat Sherpa_l1l2Trace.csv | grep "bitMapACSI=1" -c
    Log to console   A-CSI request ${num_of_ACSI_request} times
    Should Be True   0<${num_of_ACSI_request}
#    ${all_numOfUciCsiPart2Bits}    run    cat Sherpa_l1l2Trace.csv | grep "numOfUciCsiPart2Bits" | awk -F:'$0!="numOfUciCsiPart2Bits"' >ACSI.txt
    ${cmd1}   Set Variable    Sherpa_l1l2Trace.csv | grep "numOfUciCsiPart2Bits" | grep -v "numOfUciCsiPart2Bits=0" >ACSI.txt
    ${all_numOfUciCsiPart2Bits}    run    command=cd ${csv_filepath} ; cat ${cmd1}
#    @{lines_numOfUciCsiPart2Bits}=    Split to lines    ${all_numOfUciCsiPart2Bits}
#    ${line}    Fetch From Right    string=@{lines_list}    marker=dtxCsiPart1=
#    @{value_of_numOfUciCsiPart2Bits}    Split String    string=${line}    separator=,    max_split=1
    ${num_of_ACSI_report}    run    command=cd ${csv_filepath} ; cat ACSI.txt | grep "cqi" -c
    ${num_of_psDTX}    run    command=cd ${csv_filepath}; cat ACSI.txt | grep "dtx=DTX" -c
    ${num_of_part1DTX}    run    command=cd ${csv_filepath} ; cat ACSI.txt | grep "dtxCsiPart1=DTX" -c
    ${num_of_part2DTX}    run    command=cd ${csv_filepath} ; cat ACSI.txt | grep "dtxCsiPart2=DTX" -c
    ${num_of_part1CRCNOK}    run    command=cd ${csv_filepath} ; cat ACSI.txt | grep "csiPart1CrcCheck=1" -c
    ${num_of_part2CRCNOK}    run    command=cd ${csv_filepath} ; cat ACSI.txt | grep "csiPart2CrcCheck=1" -c
    ${cmd2}   Set Variable    ACSI.txt | grep "dtx=DTX\|dtxCsiPart1=DTX\|dtxCsiPart2=DTX\|csiPart1CrcCheck=1\|csiPart2CrcCheck=1" -c
    ${num_of_allDTXCRCNOK}    run    command=cd ${csv_filepath} ; cat ${cmd2}
#    Should Be True  ${acsi_mismatch_min}< ${num_of_ACSI_request}-${num_of_ACSI_report} < ${acsi_mismatch_max}
    Should Be True  ${num_of_allDTXCRCNOK}/${num_of_ACSI_report} < ${ACSI_NOK_percent}

Check A2 Event
    [Arguments]   ${filename}
    Wireshark.ReadLog    filename=${filename}    filter=nr-rrc
    Run Keyword And Continue On Failure    Wireshark.CheckExpression   expression=f1ap.procedureCode == 7 && nr-rrc.measGapConfig == 1
    Run Keyword And Continue On Failure  Wireshark.CheckExpression   expression=x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 1

Check A1 Event
    [Arguments]   ${filename}
    Wireshark.ReadLog    filename=${filename}    filter=nr-rrc
    Run Keyword And Continue On Failure    Wireshark.CheckExpression   expression=f1ap.procedureCode == 7 && nr-rrc.measGapConfig == 0
    Run Keyword And Continue On Failure  Wireshark.CheckExpression   expression=x2ap.procedureCode == 30 && x2ap.X2AP_PDU == 1


Decode_Sherpa_log_ACSI
    [Arguments]   ${acsi_mismatch_min}=-2    ${acsi_mismatch_max}=2    ${ACSI_NOK_percent}=0.03
    KW.Start decode files
    ${num_of_ACSI_request}    run    command=cd ${SHERPA_LOG_PATH}${file_name} ; cat Sherpa_l1l2Trace.csv | grep "bitMapACSI=1" -c
    Log to console   A-CSI request ${num_of_ACSI_request} times
    Should Be True   0<${num_of_ACSI_request}
#    ${all_numOfUciCsiPart2Bits}    run    cat Sherpa_l1l2Trace.csv | grep "numOfUciCsiPart2Bits" | awk -F:'$0!="numOfUciCsiPart2Bits"' >ACSI.txt
    ${cmd1}   Set Variable    Sherpa_l1l2Trace.csv | grep "numOfUciCsiPart2Bits" | grep -v "numOfUciCsiPart2Bits=0" >ACSI.txt
    ${all_numOfUciCsiPart2Bits}    run    command=cd ${SHERPA_LOG_PATH}${file_name} ; cat ${cmd1}
#    @{lines_numOfUciCsiPart2Bits}=    Split to lines    ${all_numOfUciCsiPart2Bits}
#    ${line}    Fetch From Right    string=@{lines_list}    marker=dtxCsiPart1=
#    @{value_of_numOfUciCsiPart2Bits}    Split String    string=${line}    separator=,    max_split=1
    ${num_of_ACSI_report}    run    command=cd ${SHERPA_LOG_PATH}${file_name} ; cat ACSI.txt | grep "numOfUciCsiPart2Bits" -c
    ${num_of_psDTX}    run    command=cd ${SHERPA_LOG_PATH}${file_name} ; cat ACSI.txt | grep "dtx=DTX" -c
    ${num_of_part1DTX}    run    command=cd ${SHERPA_LOG_PATH}${file_name} ; cat ACSI.txt | grep "dtxCsiPart1=DTX" -c
    ${num_of_part2DTX}    run    command=cd ${SHERPA_LOG_PATH}${file_name} ; cat ACSI.txt | grep "dtxCsiPart2=DTX" -c
    ${num_of_part1CRCNOK}    run    command=cd ${SHERPA_LOG_PATH}${file_name} ; cat ACSI.txt | grep "csiPart1CrcCheck=1" -c
    ${num_of_part2CRCNOK}    run    command=cd ${SHERPA_LOG_PATH}${file_name} ; cat ACSI.txt | grep "csiPart2CrcCheck=1" -c
    ${cmd2}   Set Variable    ACSI.txt | grep "dtx=DTX\|dtxCsiPart1=DTX\|dtxCsiPart2=DTX\|csiPart1CrcCheck=1\|csiPart2CrcCheck=1" -c
    ${num_of_allDTXCRCNOK}    run    command=cd ${SHERPA_LOG_PATH}${file_name} ; cat ${cmd2}
    Should Be True  ${acsi_mismatch_min}< ${num_of_ACSI_request}-${num_of_ACSI_report} < ${acsi_mismatch_max}
    Should Be True  ${num_of_allDTXCRCNOK}/${num_of_ACSI_report} < ${ACSI_NOK_percent}



Get gnb release
    [Documentation]   Get gnb release version from TargetBD file
    ssh.Connect To   hostname=${ASIK_IP}    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}    alias=release_info
    ${info}   ssh.Execute    ls /ffs/run/TargetBD*xml   connection=release_info
    ${release_info}   Set Variable   ${info.split('_')[1]}
#    ${release_info}   Run Keyword If   '${main_branch}'=='0000'   Set Variable   TRUNK
#    ...   ELSE   set variable    ${info.split('_')[1]}
    [Return]    ${release_info}
    [Teardown]   ssh.Disconnect   connection=release_info

Setup suite
    TestSuite.Start
    set suite variable    ${CFGFILE_ON_GIT}           ${CFGFILE_PATH}/5GC001817/
    set suite variable    ${DeltaPath}                ${CFGFILE_ON_GIT}Delta_SCF.py
    Import Variables        ${CFGFILE_ON_GIT}/Delta_SCF.py
    Import Variables        ${CFGFILE_PATH}TLDelta_21B.py
    Import Variables        ${CFGFILE_PATH}TLDelta_SBTS00.py
    Import Variables        ${CFGFILE_PATH}TLDelta_SBTS22R1.py

    Basic.CheckVariableValid    var=${${CASE_INPUT_5GC001817['5GC001817']['PA_PORT_0']}}    default_value=30
    Basic.CheckVariableValid    var=${${CASE_INPUT_5GC001817['5GC001817']['PA_PORT_1']}}    default_value=30
    Basic.CheckVariableValid    var=${${CASE_INPUT_5GC001817['5GC001817']['PA_PORT_2']}}    default_value=30
    Basic.CheckVariableValid    var=${${CASE_INPUT_5GC001817['5GC001817']['PA_PORT_3']}}    default_value=30
    Basic.CheckVariableValid    var=${CASE_INPUT_5GC001817['5GC001817']['dcap_server_ip']}    default_value=30
    Basic.CheckVariableValid    var=${CASE_INPUT_5GC001817['5GC001817']['dcap_server_port']}    default_value=30
#    Basic.CheckVariableValid    var=${CASE_INPUT_5GC001817['5GC001817']['dcap_password']}    default_value=30
#    Basic.CheckVariableValid    var=${CASE_INPUT_5GC001817['5GC001817']['dcap_alias']}    default_value=30
#    Basic.CheckVariableValid    var=${CASE_INPUT_5GC001817['5GC001817']['file_location']}    default_value=30
#    Basic.CheckVariableValid    var=${CASE_INPUT_5GC001817['5GC001817']['uplane_destination']}    default_value=30
#    Basic.CheckVariableValid    var=${CASE_INPUT_5GC001817['5GC001817']['dscp']}    default_value=30

    set suite variable    ${5GRU1_ANT1}               ${${CASE_INPUT_5GC001817['5GC001817']['PA_PORT_0']}}
    set suite variable    ${5GRU1_ANT2}               ${${CASE_INPUT_5GC001817['5GC001817']['PA_PORT_1']}}
    set suite variable    ${5GRU1_ANT3}               ${${CASE_INPUT_5GC001817['5GC001817']['PA_PORT_2']}}
    set suite variable    ${5GRU1_ANT4}               ${${CASE_INPUT_5GC001817['5GC001817']['PA_PORT_3']}}
    set suite variable    ${dcap_server_ip}           ${CASE_INPUT_5GC001817['5GC001817']['dcap_server_ip']}
    set suite variable    ${dcap_server_port}         ${CASE_INPUT_5GC001817['5GC001817']['dcap_server_port']}
#    set suite variable    ${dcap_password}            ${CASE_INPUT_5GC001817['5GC001817']['dcap_password']}
#    set suite variable    ${dcap_alias}               ${CASE_INPUT_5GC001817['5GC001817']['dcap_alias']}
#    set suite variable    ${file_location}            ${CASE_INPUT_5GC001817['5GC001817']['file_location']}
#    set suite variable    ${uplane_destination}       ${CASE_INPUT_5GC001817['5GC001817']['uplane_destination']}
#    set suite variable    ${dscp}                     ${CASE_INPUT_5GC001817['5GC001817']['dscp']}

    Create Log Directories
    set suite variable    ${Log_PATH_Artifactory}    /opt/ute/workspace/CIT/Master/Case_Logs
    set suite variable   ${OAM_TYPE}    COAM
    ${info}     Basic.GetStreamInfo     vstring=${AF_PATH}
    ${StreamInfo}    convert to string    ${info}
    ${outputfile}    Run Keyword If    "${StreamInfo}"=="None"    gNB.Generate TL SCF
    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}   TLDelta_PATH=${CFGFILE_PATH}
	...            TestLineSCF_cell_num=${1}    cell_type=Both
	...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    ...    ELSE    gNB.Generate TL SCF
    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${info['GoldenSCF']}
    ...            TLDelta_PATH=${CFGFILE_PATH}/TLDelta_${info['StreamPrefix']}.py
    ...            TestLineSCF_cell_num=${1}   cell_type=Both    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    set suite variable    ${Original_CFGFILE}    ${outputfile}
	gNB.FormatBTSID    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
	set suite variable    ${dist_name}   ${MRBTS_ID}/${NRBTS_ID}
	Run Keyword And Ignore Error    KW.PA.Adjust RU1 Attenuation to ${0}
#    ChangeSwcofigByFlag    flag=0x10043    value=50002
#    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    Conn.ResetCache


Setup Suite for MTK
    TestSuite.Start
    Create Log Directories
    set suite variable   ${OAM_TYPE}    COAM
    Import Variables        ${CURDIR}/CaseSCFDelta.py
    Import Variables        ${CFGFILE_PATH}TLConfiguration.py
    Import Variables        ${CFGFILE_PATH}TLSCFDelta_SBTSTRUNK.py
    Import Variables        ${CFGFILE_PATH}TLSCFDelta_SBTS22R1.py
    Import Variables        ${CFGFILE_PATH}TLSCFDelta_SBTS22R2.py
    Import Variables        ${CFGFILE_PATH}TLSCFDelta_SBTS22R3.py
    set suite variable    ${DeltaPath}                ${CURDIR}/CaseSCFDelta.py
#    ${info}     Basic.GetStreamInfo     vstring=${AF_PATH}
#    ${StreamInfo}    convert to string    ${info}
#    ${outputfile}    Run Keyword If    "${StreamInfo}"=="None"    gNB.Generate TL SCF
#    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}   TLDelta_PATH=${TLDelta_PATH_ON_GIT}
#	...            TestLineSCF_cell_num=${1}    cell_type=Both
#	...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    ...    ELSE    gNB.Generate TL SCF
#    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${info['GoldenSCF']}
#    ...            TLDelta_PATH=${TLDelta_PATH_ON_GIT}/TLDelta_${info['StreamPrefix']}.py
#    ...            TestLineSCF_cell_num=${1}   cell_type=Both    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    ${outputfile}    gNB.GenerateTestLineSCFs
    set suite variable    ${Original_CFGFILE}    ${outputfile}
#	gNB.FormatBTSID    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#	set suite variable    ${dist_name}   ${MRBTS_ID}/${NRBTS_ID}
    Conn.ResetCache
    set suite variable     ${5GRU1_PA_Ports}       ${CASE_INPUT_5GC001817['5GC001817']['5GRU1_PA_Ports']}
    set suite variable     ${5GRU2_PA_Ports}       ${CASE_INPUT_5GC001817['5GC001817']['5GRU2_PA_Ports']}
    set suite variable     ${dcap_ip}    ${CASE_INPUT_5GC001817['5GC001817']['dcap_server_ip']}
    set suite variable     ${dcap_port}    ${CASE_INPUT_5GC001817['5GC001817']['dcap_server_port']}

Teardown Suite
    TestSuite.Stop

Teardown Suite for MTK
    TestSuite.Stop
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
    ...    value=${CASE_INPUT_CB008131['CB008131_A_01']['PA_Value_1']}   attenuator=${PA1_INFO}
    ...    logging_message=Set back PA values for RU1.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB008131['CB008131_A_01']['PA_Value_2']}   attenuator=${PA2_INFO}
    ...    logging_message=Set back PA values for RU1.

Setup case
    TestCase.Start
    log to console     Case Start
#    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
#    set test variable  ${TS_CASE_LOG_PATH}    ${LOG_PATH}/${time_stamp}/
#    create directory   ${TS_CASE_LOG_PATH}

Teardown case
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul
    log     ${TEST STATUS}
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    gNB.CollectSnapshot
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect snapshot logs
    Run Keyword And Ignore Error    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
    Run Keyword And Ignore Error    force_close_coam_webdriver
    Conn.ResetCache
    TestCase.Stop

Setup case for MTK
#    TestCase.Start
    log to console     Case Start

Teardown case for MTK
#    log     ${TEST STATUS}
#    Run Keyword If  '${TEST STATUS}' == 'FAIL'    gNB.CollectSnapshot
#    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect snapshot logs
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
    Run Keyword And Ignore Error     rd.delete_bts
    ${status}  ${5Grach_ed}  run keyword and ignore error   power_ue.UE Detach  ue_type=${ue_type}
    Run Keyword And Ignore Error    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
#    Run Keyword And Ignore Error    force_close_coam_webdriver
    Conn.ResetCache
#    TestCase.Stop

Process.ModifyAndCommissionAndCheckOnair
    [Documentation]    1. Modify SCF
    ...                2. Commission Modified SCF
    ...                3. Wait gNB start and verify gNB is On Air until timeout.
    ...                4. Do cell search and ue attach and Check
    [Arguments]       ${original_cfgfile}
    ...               ${modified_cfgfile}
    ...               ${parameters_to_modify}='NULL'
    ...               ${parameters_to_delete}='NULL'
    ...               ${mo_to_add}='NULL'
    ...               ${list_parameter_to_modify}='NULL'
    ...               ${list_to_add}='NULL'
    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}
    gNB.ModifySCF        InputFile=${original_cfgfile}
    ...                  OutputFile=${modified_cfgfile}
    ...                  ParamterToModify=${parameters_to_modify}
    ...                  ParameterToDelete=${parameters_to_delete}
    ...                  MOsToAdd=${mo_to_add}
    ...                  ListParamterToModify=${list_parameter_to_modify}
    ...                  ListToAdd=${list_to_add}
    gNB.CommissionWithRetry    scf_file=${modified_cfgfile}     model=HBTE
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady

KW.ModifyAndCommissionAndCheckOnair
    [Documentation]    1. Modify SCF
    ...                2. Commission Modified SCF
    ...                3. Wait gNB start and verify gNB is On Air until timeout.
    ...                4. Do cell search and ue attach and Check
    [Arguments]       ${original_cfgfile}
    ...               ${modified_cfgfile}
    ...               ${parameters_to_modify}='NULL'
    ...               ${parameters_to_delete}='NULL'
    ...               ${mo_to_add}='NULL'
    ...               ${list_parameter_to_modify}='NULL'
    ...               ${list_to_add}='NULL'
    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}
    gNB.GenerateCaseSCF    InputFile=${original_cfgfile}
    ...                    OutputFile=${modified_cfgfile}
    ...                    ResourceFolder=${CURDIR}
    ...                    ParamterToModify=${parameters_to_modify}
    ...                    ParameterToDelete=${parameters_to_delete}
    ...                    MOsToAdd=${mo_to_add}
    ...                    ListParamterToModify=${list_parameter_to_modify}
    ...                    ListToAdd=${list_to_add}
    gNB.CommissionWithRetry    scf_file=${modified_cfgfile}     model=HBTE
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady

KW.BtsLog.StartBTSlogCollection
    [Documentation]    collect syslogs from ute VM.
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf TRACE_*.bin ; rm -rf SYSLOG_*.LOG
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/ute/tools/btslog/btslog
    ...   btslog_launcher_path=/opt/ute/tools/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    btslog.Set Global Alias     btslog
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog


KW.Prepare_UE_and_UE_Attach
    [Arguments]   ${ue_type}=${UE_TYPE}   ${ue_index}=${0}     ${attach_mode}=5G_SA    ${4G_check}=false   ${imsi}=${IMSI1}
    run keyword and ignore error    5GC.DeleteIMSI   imsi=${imsi}  AMF_IP=${5GC_IP}   AMF_USERNAME=${5GC_USERNAME}
    ...        AMF_PASSWORD=${5GC_PASSWORD}  alias=${ALIAS_AMF}
    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${ue_index}    reset_sol=${True}
    power_ue.UE Detach       ue_type=${UE_TYPE}    power_reset=True   ue_index=${ue_index}
    power_ue.UE Attach    ue_type=${UE_TYPE}    ue_index=${ue_index}    power_reset=True    attach_mode=${attach_mode}
#    power_ue.UE Attach    ue_type=${UE_TYPE}    ue_index=${ue_index}    attach_mode=${attach_mode}
    power_ue.Verify attach    ue_type=${UE_TYPE}   ue_index=${ue_index}    4G_check=${4G_check}


KW.UE_Call_With_DL_Traffic
    [Arguments]   ${ue_type}=${UE_TYPE}   ${ue_index}=${0}     ${attach_mode}=5G_SA    ${duration_dl}=800
    ...    ${throughput_dl}=10MKbits/sec    ${apn_address}=wap1nokiacom    ${check_throughput_dl}=5    ${ue_mode}=SA
    ...    ${start_offset}=${0}    ${4G_check}=false
    KW.Prepare_UE_and_UE_Attach    ue_type=${ue_type}   ue_index=${ue_index}     attach_mode=${attach_mode}   4G_check=${4G_check}
    Sleep    10s
    power_ue.Start traffic     ue_type=${ue_type}   direction=dl
    ...        throughput=${throughput_dl}     duration=${duration_dl}    ue_index=${ue_index}
    ...        apn_address=${apn_address}      ue_mode=${ue_mode}
    Sleep    30s
    power_ue.Check throughput    ue_type=${ue_type}      direction=dl      throughput=${check_throughput_dl}
    ...                          ue_index=${ue_index}    start_offset=${start_offset}


KW.UE_Call_With_DL_UL_Traffic
    [Arguments]   ${ue_type}=${UE_TYPE}   ${ue_index}=${0}     ${attach_mode}=5G_SA    ${apn_address}=wap1nokiacom
    ...    ${duration_dl}=800    ${duration_ul}=800    ${throughput_dl}=10MKbits/sec    ${throughput_ul}=5MKbits/sec
    ...    ${check_throughput_dl}=5     ${check_throughput_ul}=2
    ...    ${start_offset}=${0}    ${ue_mode}=SA   ${4G_check}=false  ${imsi}=${IMSI1}   ${traffic_time}=30

    KW.Prepare_UE_and_UE_Attach    ue_type=${ue_type}   ue_index=${ue_index}     attach_mode=${attach_mode}
    ...   4G_check=${4G_check}  imsi=${imsi}
    Sleep    10s
    log to console    START DATA TRANSFER
    power_ue.Start traffic     ue_type=${ue_type}   direction=ul
    ...        throughput=${throughput_ul}     duration=${duration_ul}    ue_index=${ue_index}
    ...        apn_address=${apn_address}      ue_mode=${ue_mode}
    power_ue.Start traffic     ue_type=${ue_type}   direction=dl
    ...        throughput=${throughput_dl}     duration=${duration_dl}    ue_index=${ue_index}
    ...        apn_address=${apn_address}      ue_mode=${ue_mode}
    Sleep    ${traffic_time}s
    power_ue.Check throughput    ue_type=${ue_type}      direction=dl      throughput=${check_throughput_dl}
    ...                          ue_index=${ue_index}    start_offset=${start_offset}
    power_ue.Check throughput    ue_type=${ue_type}      direction=ul      throughput=${check_throughput_ul}
    ...                          ue_index=${ue_index}    start_offset=${start_offset}


KW.Start_Collect_Sherpa_Trace
    Log to console   Start collect sherpa log
    @{trace_type}    create list   L2Ps_Sherpa
    &{bts_info}   Create Dictionary    host=${WEBUI_IP}    username=${WEBUI_USERNAME}
    ...                                password=${WEBUI_PASSWORD}    port=443
    rd.connect_to    host=${dcap_server_ip}
    ...              port=${dcap_server_port}
    ...              secure=True
#    rd.get_all_bts_info
    rd.create_bts    host=${WEBUI_IP}
    rd.start_trace    bts=&{bts_info}    gnb_custom_profile=${trace_type}
    sleep    60s

KW.Stop_Collect_Sherpa_Trace
    Log to console   Stop collect sherpa log
    rd.stop_trace
    sleep    2min
    ${trace_logpath}    rd.get_results
    run    command=cd ${SHERPA_LOG_PATH};rm -r *
    run    command=cp ${trace_logpath} ${SHERPA_LOG_PATH}
    run    command=rm -f ${trace_logpath}
    rd.delete_trace
    rd.delete_bts

KW.PA.Adjust ${RU} Attenuation to ${value}
    ${value}    RemoveZeroString     ${value}
    PA.AdjustTheAttenuationValue    ports=${5G${RU}_ANT1}    value=${value}
    PA.AdjustTheAttenuationValue    ports=${5G${RU}_ANT2}    value=${value}
    PA.AdjustTheAttenuationValue    ports=${5G${RU}_ANT3}    value=${value}
    PA.AdjustTheAttenuationValue    ports=${5G${RU}_ANT4}    value=${value}


KW.Start decode files
    Log to console   Start decode files
    run    command=cd ${SHERPA_LOG_PATH};unzip *.zip
    ${unzip_sherpa_file}    run    command=cd ${SHERPA_LOG_PATH};find . -name "*.pcap"
    ${file_name_1}    Fetch From Right     ${unzip_sherpa_file}   /
    ${file_name}    Fetch From Left       ${file_name_1}  _
    run    command=cd ${SHERPA_LOG_PATH} ; mkdir ${file_name}
    set test variable    ${file_name}
    run    command=cd ${SHERPA_LOG_PATH};cp ${unzip_sherpa_file} ${LOG_PATH}/${file_name}.pcap
    run    command=/opt/Nokia/Sherpa_5G_18/Sherpa.run -o ${SHERPA_LOG_PATH}${file_name} -d 0 -p Sherpa ${LOG_PATH}/${file_name}.pcap
    Sleep   10s

KW.Decode_Sherpa_log_UCIonly
    [Arguments]
    Run Keyword And Continue On Failure    Decode_Sherpa_log_ACSI
    KW.Start decode files
    ${cmd3}   Set Variable    Sherpa_l1l2Trace.csv | grep "bitMapACSI=1" | grep "ulSchInd=0" -c
    ${num_of_ucionly_true}  run    command=cd ${SHERPA_LOG_PATH}${file_name} ; cat ${cmd3}
    Log to console   ucionly true ${num_of_ucionly_true} times
    Should Be True  ${num_of_ucionly_true} >=1
