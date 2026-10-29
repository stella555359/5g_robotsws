# # 
# # *** Settings ***
# # Documentation
# # ...    author: Han Ruiyu
# # ...    contact: ruiyu.han@nokia-sbell.com
# # ...    squad group: NSB MN 5G&SC 5G Pz Verf CN 07 SG
# # Library    OperatingSystem
# # Library   Collections
# # Library   String
# # Library     ..${/}libraries${/}snapshot_files.py
# # Variables          ..${/}libraries${/}dcap_server_1.py
# # Variables          ..${/}libraries${/}sherpa_server_1.py
# # Library   taf.transport.ssh   WITH NAME   csn
# # Resource           ..${/}resources${/}emil${/}emil.robot
# # Resource           ..${/}resources${/}dcap.robot
# # Resource           ..${/}resources${/}test_port.robot
# # Resource   ..${/}resources${/}case_steps.robot
# # Variables   ..${/}..${/}libraries${/}global_vars.py
# # Resource   ..${/}resources${/}decode.robot
# # Resource   ..${/}resources${/}tshark.robot
# # Resource   ..${/}resources${/}sherpa.robot
# # Resource   ..${/}resources${/}emil${/}emil.robot
# # Resource   ..${/}resources${/}emil${/}test_emil.robot
# # Resource   ..${/}resources${/}snapshot.robot
# # Resource   ..${/}resources${/}coam.robot
# # Resource   ..${/}resources${/}call.robot
# # Resource   ..${/}resources${/}call.robot
# # Resource   ..${/}..${/}common${/}taf_coam.robot
# # Library   ..${/}libraries${/}ui_operation.py
# # 
# # Force Tags   SG_07   CA_5G_OAM    CRT_UTE   master_classicalbts_all   5G_RAN
# # ...    PY36
# # ...   5G_RAN_TDD   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIKL_ABILB1_AEQN_NETACT   STATE_SW_UPLOADED
# # ...   AUTHOR_johnny.1.jiang@nokia-sbell.com   RAN_5G   RAN_5G_TDD   SBTS00
# # 
# # Suite Setup    Run Keywords   common.Common Setup    AND
# # ...  run keyword and continue on failure    Cplane log Setup
# # #Suite Setup      Cplane and Uplane log Setup
# # Suite Teardown    Cplane and Uplane log Teardown
# # 
# # *** Variables ***
# # 
# # *** Test Cases ***
# # [1]5GC001808_A_ZMQ traces via EMil for Classical_SA BTS
# #     [Tags]
# #     [Timeout]    60min
# #     [Setup]
# #     Check Zmq Msg in the Log    log_path=${output_txt_path}
# #     [Teardown]
# # 
# # 
# # [1]5GC001808_D_TTI Trace Analyses Tool Decode bin file for Classical_SA BTS
# #     [Tags]   AUTHOR_ruiyu.han@nokia-sbell.com
# #     [Timeout]    60 min
# #     [Setup]    run keywords    robot_common_operations.Common Case Setup
# #     ...   AND   L3 CALL For TTI Bin Prepare
# #     ${key_TTI}    check snapshot_TTI
# #     Check TTI Decoder Tool    input_file=${key_TTI}
# #     [Teardown]    robot_common_operations.Common Case Teardown
# # 
# # #
# # [1]5GC001808_F_SHERPA_Trace_to_include_periodic_information_including_PCI_list_from_L2HiDU
# #     [Timeout]    30 min
# #     [Setup]    robot_common_operations.Common Case Setup
# #     COAM Login   alias=${coam_alias}
# # #    selenium_coam.enable_virtual_display
# #     COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
# #     ${MRBTS_ID}   selenium_coam.get_bts_id
# #     ${pci_list}  Get PCI list
# #     ${mcc}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
# #      ...   filter_param=MCC in PLMN
# #     ${mnc}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
# #      ...   filter_param=MNC in PLMN
# #     COAM Logout   connection=${coam_alias}
# #     Run Keyword and Ignore Error   COAM WEBUI Logout
# # #    ${context1}    Set Variable    plmnid:${mcc}-0${mnc} pciNum:2 pci:${pci_list[0]} pci:${pci_list[1]}
# #     ${context1}    Set Variable    plmnid= ${mcc}-0${mnc}
# #     ${pci_nb}    Evaluate   len(${pci_list})
# #     ${context2}    set variable    pciNum:${pci_nb}
# #     :FOR  ${pci}  IN   @{pci_list}
# #     \    Check Defined Trace Included in Sherpa log   csvname=ControlFlows    defined_event=0x52    defined_info=${pci}
# #     #Set Suite Variable    ${context}    plmnid:262-03, pciNum:2, pci:91, pci:92
# #     Check Defined Trace Included in Sherpa log   csvname=ControlFlows    defined_event=0x52    defined_info=${context1}
# #     Check Defined Trace Included in Sherpa log   csvname=ControlFlows    defined_event=0x52    defined_info=${context2}
# #     [Teardown]    robot_common_operations.Common Case Teardown
# # 
# # [1]5GC001808_F_SHERPA_Trace_to_include_periodic_information_including_PCI_list_from_L2LO
# #     [Timeout]    30 min
# #     [Setup]    robot_common_operations.Common Case Setup
# #     COAM Login   alias=${coam_alias}
# # #    selenium_coam.enable_virtual_display
# #     COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
# #     ${MRBTS_ID}   selenium_coam.get_bts_id
# #     ${pci_list}  Get PCI list
# #     ${mcc}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
# #      ...   filter_param=MCC in PLMN
# #     ${mnc}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
# #      ...   filter_param=MNC in PLMN
# #     COAM Logout   connection=${coam_alias}
# #     Run Keyword and Ignore Error   COAM WEBUI Logout
# # #    Set Suite Variable    ${context1}    plmnid=${mcc}-0${mnc} nbPci:1 pci: ${pci_list[0]};
# # #    Set Suite Variable    ${context2}    plmnid=${mcc}-0${mnc} nbPci:1 pci: ${pci_list[1]};
# #     ${context1}    Set Variable    plmnid= ${mcc}-0${mnc}
# #     ${pci_nb}    Evaluate   len(${pci_list})
# #     ${context2}    set variable    nbPci:${pci_nb}
# #     :FOR  ${pci}  IN   @{pci_list}
# #     \    Check Defined Trace Included in Sherpa log   csvname=ControlFlows    defined_event=0x54   defined_info=${pci}
# #     Check Defined Trace Included in Sherpa log   csvname=ControlFlows    defined_event=0x54   defined_info=${context1}
# #     Check Defined Trace Included in Sherpa log   csvname=ControlFlows    defined_event=0x54   defined_info=${context2}
# #     [Teardown]   robot_common_operations.Common Case Teardown
# # 
# # 
# # [1]5GC001808_H_Paging_Information_to_SHERPA_L2PS
# #     [Timeout]    60 min
# #     [Setup]
# #      Check Trace File Recieved    file_list=${sherpa_log_file_list}
# #     [Teardown]
# # 
# # 
# # [1]5GC001808_J_ All Beam Id reported in 4x4 MIMO case for Classical_SA BTS
# #     [Timeout]    30 min
# #     [Setup]
# #     Check Trace File Recieved    file_list=${sherpa_log_file_list}
# #     [Teardown]
# # 
# # 
# # 
# # *** Keywords ***
# # L3 CALL For TTI Bin Prepare
# #     [Arguments]     ${call_mode}=single
# #     log to console    Ignore L3 CALL and reset site since bin file too big!
# #     _cell_onair_operation
# # 
# # L2_Hi_DU Case Steps
# #     [Arguments]   ${stream}   ${level}   ${exec_type}=${EMPTY}   ${call_mode}=single
# #     COAM Login   alias=${coam_alias}
# #     ${gnb_release}   Get gnb release
# #     ${gnb_release}    Run keyword if   '${gnb_release}'=='TRUNK'      set variable   SBTS21B
# #     ...   ELSE   set variable   ${gnb_release}
# #     COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
# #     ...    display=${false}   version=${gnb_release}
# #     COAM WEBUI Whether Close Start Up View Window
# #     run keyword and ignore error
# #     ...   Stop Stream Trace Action    stream=${stream}    level=${level}    exec_type=${EMPTY}    trace_flag=all
# #     Start Stream Trace Action    stream=${stream}    level=${level}    exec_type=${EMPTY}    trace_flag=all
# #     Start UDP Server Collecting   dcap_ip=${dcap_ip}    dcap_username=${dcap_username}    dcap_password=${dcap_password}
# #     COAM WEBUI Logout
# #     ${res}   Run Keyword and Ignore Error   Setup Call by mode   call_mode=single
# #     Run Keyword Unless	'${res[0]}' == 'PASS'    log    L3 CALL FAILED!    WARN
# #     Set Suite Variable   ${call_alias}   ${res[1]}
# #     [Teardown]    L2_Hi_DU Case Teardown    stream=${stream}    level=${level}
# # 
# # L2_Hi_DU Case Teardown
# #     [Arguments]   ${stream}   ${level}
# #     COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
# #     Stop Stream Trace Action    stream=${stream}    level=${level}    exec_type=${EMPTY}    trace_flag=l2_hi
# #     COAM Logout   connection=${coam_alias}
# #     Run Keyword and Ignore Error   COAM WEBUI Logout
# #     Check Trace File Recieved   file_folder=${file_location}
# #     Get Streaming Files Current gNB   file_folder=${file_location}
# #     Run Keyword and Ignore Error   csn.Disconnect   connection=${dcap_alias}
# #     Run Keyword and Ignore Error   csn.Disconnect   connection=${call_alias}
# # 
# # Release Resource Again
# #     [Arguments]   ${stream}   ${level}
# #     COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
# #     run keyword and ignore error    Stop Stream Trace Action
# #     ...    stream=${stream}    level=${level}    exec_type=${EMPTY}    trace_flag=l2_hi
# #     run keyword and ignore error    COAM Logout   connection=${coam_alias}
# #     Run Keyword and Ignore Error   COAM WEBUI Logout
# #     run keyword and return status   Clean Traffic Files   file_folder=${file_location}
# #     Run Keyword and Ignore Error   csn.Disconnect   connection=${dcap_alias}
# #     Run Keyword and Ignore Error   csn.Disconnect   connection=${call_alias}
# # 
# # Check L2_Hi Ueidcu in Sherpa log
# #     [Arguments]    ${csvname}
# # #    Download Earlist CSV File in TAF    ${csvname}
# #     ${row}    wait until keyword succeeds   1m    20s     get_one_row_as_defined_str
# #     ...    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    str=BearerSetupParam(0x60)
# #     ${row_value}   split string from right  ${row}    ;
# #     ${ueidcu}    set variable   ${row_value[-6]}
# #     ${row_list}    split_rows_as_defined_str    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    str1=BearerSetupParam(0x60)
# #     ...   str2=(0x4c)
# #     :FOR   ${row}   IN   @{row_list}
# #         ${row_value}   split string from right  ${row}    ;
# #         ${passed}  run keyword and return status   should be equal    ${row_value[-6]}    ${ueidcu}
# #         Exit For Loop If  ${passed}
# #     END
# # 
# # Check Defined Msg Included in Msg
# #     [Arguments]     ${csvname}   ${msg_name}    ${msg_param}
# #     ${row}    wait until keyword succeeds   1m    20s     get_param_in_msg
# #     ...    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    msg_name=${msg_name}    msg_param=${msg_param}
# # 
# # 
# # Check L2-hi-CU Log
# #     wait until keyword succeeds     3x    20s
# #     ...     Check Defined Msg Included in Sherpa log    csvname=ControlFlows    defined_event=BearerSetupParam(0x60)
# #     wait until keyword succeeds     3x    20s
# #     ...    Check Defined Msg Included in Sherpa log    csvname=ControlFlows    defined_event=SessionSetup(0x61)
# # 
# # Check Defined Msg Included in Sherpa log One By One
# #     [Arguments]    ${csvname}    ${defined_event}
# #     ${file_list}    Get and Upload Files Needs Decode
# #     should not be empty  ${file_list}
# #     :FOR   ${file}   IN   @{file_list}
# #         ${passed}    run keyword and return status     _Check Defined Msg    pcapfile=${file}
# #         ...   csvname=${csvname}    defined_event=${defined_event}
# #         Exit For Loop If  ${passed}
# #     END
# #     run keyword unless  ${passed}    FAIL    CANNOT FIND ${defined_event} in ALL Pcap LOGS!    ERROR
# # 
# # _Check Defined Msg
# #     [Arguments]    ${pcapfile}    ${csvname}    ${defined_event}
# #     ${row}    wait until keyword succeeds   1m    20s     get_one_row_as_defined_str
# #     ...    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    str=${defined_event}
# # 
# # Call Setup and check tput 2times
# #     [Arguments]   ${ue_index}=${ue_index}   ${tput}=100   ${tput_expect}=${tput}   ${loop_idx}=1
# #     Call Setup and check tput    ue_index=${ue_index}   tput=${tput}   tput_expect=${tput_expect}
# #     ...   traffic_stop=${false}
# #     power_ue.Stop Traffic   ue_type=${ue_${ue_index}_type}   direction=${direction}
# #     :FOR  ${i}  IN RANGE  ${loop_idx}
# #         Start Traffic With Throughput Check   ue_type=${ue_${ue_index}_type}
# #         ...   ue_index=${ue_index}   direction=DL   throughput=${tput}   expect=${tput_expect}
# #         sleep  15s
# #     END
# #     [Return]   cpc_${ue_index}   ${ue_type}
# # 
# # Stream Case Start
# #     [Arguments]   ${stream}   ${level}   ${exec_type}=${EMPTY}   ${call_mode}=multi
# #     COAM Login   alias=${coam_alias}
# #     COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
# #     Run Keyword and Ignore Error   selenium_coam.stop_${stream}_trace
# #     ...   uplane_sherpa_name=${level.replace('_', '-').upper()}   source=${exec_type.upper()}
# #     sleep   15s
# #     Configure Logging Agent   uplane_destination=${uplane_destination}
# #     Start Stream Trace Action   level=${level}   exec_type=${exec_type}   stream=${stream}
# #     Start UDP Server Collecting   dcap_ip=${dcap_ip}    dcap_username=${dcap_username}    dcap_password=${dcap_password}
# #     COAM WEBUI Logout
# #     ${res}   Run Keyword and Ignore Error   Setup Call by mode single    call_mode=single
# #     Run Keyword Unless	'${res[0]}' == 'PASS'    log    L3 CALL FAILED!    WARN
# #     Set Suite Variable   ${call_alias}   ${res[1]}
# #     Stream Case Teardown    stream=${stream}    level=${level}    exec_type=${exec_type}
# # 
# # Setup Call by mode single
# #     [Arguments]   ${call_mode}
# #     ${alias}   Run Keyword If   '${call_mode.lower()}'=='single'  Call Setup and check tput 2times  port=58909
# #     ...   duration=${duration}   tput_expect=10
# #     ...   ELSE   Setup MultiCell Call   duration=${duration}
# #     [Return]   ${alias}
# # 
# # 
# # check recieved file
# #     [Arguments]    ${csvname}    ${defined_event}
# #     ${row}    get_one_row_as_defined_str    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    str=${defined_event}
# #     ${row2}    get_one_row_as_defined_str    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    str=DCI[k2
# # 
# # Check SRB in L2LO
# #     [Arguments]    ${csvname}
# #     ${row1}    wait until keyword succeeds   1m    20s     get_one_row_as_defined_str
# #     ...    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    str=UserSetupNoDrb(0x10)
# #     ${row1_value}   split string from right  ${row1}    ;
# #     ${SRB1_value}    set variable   ${row1_value[-5]}
# #     ${row2}    wait until keyword succeeds   1m    20s     get_one_row_as_defined_str
# #     ...    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    str=BearerAdd(0x82)
# #     ${row2_value}   split string from right  ${row2}    ;
# #     ${SRB2_value}    set variable   ${row2_value[-5]}
# #     should be equal    ${SRB1_value}    1
# #     should be equal    ${SRB2_value}    2
# # 
# # Get Coam Snapshop SA
# #     COAM Login
# #     ${snapshot_filename}    Catch Snapshot COAM
# #     COAM Logout
# #     run   rm -rf ${OUTPUT_DIR}/snapshot
# #     ${command_unzip}    Set Variable    unzip ${snapshot_filename} -d ${OUTPUT_DIR}/snapshot
# #     run   ${command_unzip}
# #     ${FILE_STRUCT}    snapshot_files.get_snapshot_file_orgnization    file_folder=${OUTPUT_DIR}/snapshot
# #     [Return]   ${FILE_STRUCT}
# # 
# # check recieved file T
# # #    ${traceSeqNum}   ${utcTimeStampMicro}   Get Tshark Filter from Sherpa Log   csvname=ControlFlows   defined_event=Ul LO
# # #    ${filter_expression}=    Run keyword if    '${traceSeqNum}'==''    Set Variable    L2Log_StreamInd_t.utcTimeStamp
# ...Micro == ${utcTimeStampMicro}
# # #    ...   ELSE   Set Variable   L2Log_StreamInd_t.utcTimeStampMicro == ${utcTimeStampMicro} && L2Log_StreamIndSherpa_
# ...t.traceSeqNum == ${traceSeqNu
# # m}
# # #    ${return_value}   Check value in wireshark with sharpa log
# # #    ...   input_file=${local_pcap_path}
# # #    ...   xpath=.//DU_L2LO_UL_t.bufferedSlot
# # #    ...   filter=L2Log_StreamInd_t.utcTimeStampMicro==${utcTimeStampMicro}
# # #    ...   filter_expression=${filter_expression}
# # #    ${return_element_num}   Check value in wireshark with sharpa log
# # #    ...   input_file=${local_pcap_path}
# # #    ...   xpath=.//RNTI08_t.elementNb
# # #    ...   filter=L2Log_StreamInd_t.utcTimeStampMicro==${utcTimeStampMicro}
# # #    ...   `=${filter_expression}
# # ##    Run keyword if    ${return_element_num[0]}>60   FAIL
# # #    ${return_mac_num}   Check value in wireshark with sharpa log
# # #    ...   input_file=${local_pcap_path}
# # #    ...   xpath=.//RNTI08_t.numberBytesMacCe
# # #    ...   filter=L2Log_StreamInd_t.utcTimeStampMicro==${utcTimeStampMicro}
# # #    ...   filter_expression=${filter_expression}
# #     wait until keyword succeeds   1m    20s     get_one_row_as_defined_str
# #     ...    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_ControlFlows.csv    str=Ul LO
