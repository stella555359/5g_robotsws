*** Settings ***
Documentation
    ...    Author: casbo.xing@nokia-sbell.com
    ...    to define CB009514 keywords
Library    OperatingSystem
Library   Collections
Library   String
Library     ..${/}libraries${/}snapshot_files.py
Variables          ..${/}libraries${/}dcap_server_1.py
Variables          ..${/}libraries${/}sherpa_server_1.py
Library   taf.transport.ssh   WITH NAME   csn
Resource           ..${/}resources${/}emil${/}emil.robot
Resource           ..${/}resources${/}dcap.robot
Resource           ..${/}resources${/}test_port.robot
Resource   ..${/}resources${/}case_steps.robot
Variables   ..${/}..${/}libraries${/}global_vars.py
Resource   ..${/}resources${/}decode.robot
Resource   ..${/}resources${/}tshark.robot
Resource   ..${/}resources${/}sherpa.robot
Resource   ..${/}resources${/}emil${/}emil.robot
Resource   ..${/}resources${/}emil${/}test_emil.robot
Resource   ..${/}resources${/}snapshot.robot
Resource   ..${/}resources${/}coam.robot
Resource   ..${/}resources${/}call.robot
Resource   ..${/}resources${/}call.robot
Resource   ..${/}..${/}common${/}taf_coam.robot
Library   ..${/}libraries${/}ui_operation.py
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/coam.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot

*** Variables ***
${Instance_Id}                 ${tl.gnbs[0].instance_id}

*** Keywords ***
L3 CALL For TTI Bin Prepare
#    [Arguments]     ${call_mode}=single
    log to console    Ignore L3 CALL and reset site since bin file too big!
    _cell_onair_operation

L2_Hi_DU Case Steps
    [Arguments]   ${stream}   ${level}   ${exec_type}=${EMPTY}   ${call_mode}=single
    COAM Login   alias=${coam_alias}
    ${gnb_release}   Get gnb release
    ${gnb_release}    Run keyword if   '${gnb_release}'=='TRUNK'      set variable   SBTS21B
    ...   ELSE   set variable   ${gnb_release}
    COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    ...    display=${false}   version=${gnb_release}
    COAM WEBUI Whether Close Start Up View Window
    run keyword and ignore error
    ...   Stop Stream Trace Action    stream=${stream}    level=${level}    exec_type=${exec_type}    trace_flag=all
    Start Stream Trace Action    stream=${stream}    level=${level}    exec_type=${exec_type}    trace_flag=all
    Start UDP Server Collecting   dcap_ip=${dcap_ip}    dcap_username=${dcap_username}    dcap_password=${dcap_password}
    COAM WEBUI Logout
    ${res}   Run Keyword and Ignore Error   Setup Call by mode   call_mode=${call_mode}
    Run Keyword Unless	'${res[0]}' == 'PASS'    log    L3 CALL FAILED!    WARN
    Set Suite Variable   ${call_alias}   ${res[1]}
    [Teardown]    L2_Hi_DU Case Teardown    stream=${stream}    level=${level}

L2_Hi_DU Case Teardown
    [Arguments]   ${stream}   ${level}
    COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    Stop Stream Trace Action    stream=${stream}    level=${level}    exec_type=${EMPTY}    trace_flag=l2_hi
    COAM Logout   connection=${coam_alias}
    Run Keyword and Ignore Error   COAM WEBUI Logout
    Check Trace File Recieved   file_folder=${file_location}
    Get Streaming Files Current gNB   file_folder=${file_location}
    Run Keyword and Ignore Error   csn.Disconnect   connection=${dcap_alias}
    Run Keyword and Ignore Error   csn.Disconnect   connection=${call_alias}

Release Resource Again
    [Arguments]   ${stream}   ${level}
    COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    run keyword and ignore error    Stop Stream Trace Action
    ...    stream=${stream}    level=${level}    exec_type=${EMPTY}    trace_flag=l2_hi
    run keyword and ignore error    COAM Logout   connection=${coam_alias}
    Run Keyword and Ignore Error   COAM WEBUI Logout
    run keyword and return status   Clean Traffic Files   file_folder=${file_location}
    Run Keyword and Ignore Error   csn.Disconnect   connection=${dcap_alias}
    Run Keyword and Ignore Error   csn.Disconnect   connection=${call_alias}

Check Ueidcu in L2HiDU
    [Arguments]    ${csvname}
#    Download Earlist CSV File in TAF    ${csvname}
    ${row}    wait until keyword succeeds   1m    20s     get_one_row_as_defined_str
    ...    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    str=BearerSetupParam(0x60)
    ${row_value}   split string from right  ${row}    ;
    ${ueidcu}    set variable   ${row_value[-7]}
    ${row_list}    split_rows_as_defined_str    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    str1=BearerSetupParam(0x60)
    ...   str2=(0x83)
    FOR   ${row}   IN   @{row_list}
        ${row_value}   split string from right  ${row}    ;
        ${passed}  run keyword and return status   should be equal    ${row_value[-7]}    ${ueidcu}
        Exit For Loop If  ${passed}
    END

Check Ueidcu in L2HiCU
    [Arguments]    ${csvname}
#    Download Earlist CSV File in TAF    ${csvname}
    ${row}    wait until keyword succeeds   1m    20s     get_one_row_as_defined_str
    ...    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    str=BearerSetupParam(0x60)
    ${row_value}   split string from right  ${row}    ;
    ${ueidcu}    set variable   ${row_value[-7]}
    ${row_list}    split_rows_as_defined_str    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    str1=BearerSetupParam(0x60)
    ...   str2=(0x41)
    FOR   ${row}   IN   @{row_list}
        ${row_value}   split string from right  ${row}    ;
        ${passed}  run keyword and return status   should be equal    ${row_value[-7]}    ${ueidcu}
        Exit For Loop If  ${passed}
    END

Check Defined Msg Included in Msg
    [Arguments]     ${csvname}   ${msg_name}    ${msg_param}
    ${row}    wait until keyword succeeds   1m    20s     get_param_in_msg
    ...    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    msg_name=${msg_name}    msg_param=${msg_param}

Check message in L2HiCU
#    [Arguments]    ${csvname}
    Check Defined Msg Included in Sherpa log    csvname=ControlFlows    defined_event=BearerSetupParam(0x60)
    Check Defined Msg Included in Sherpa log    csvname=ControlFlows    defined_event=BearerModifyReq(0x3a)
    Check Defined Msg Included in Sherpa log    csvname=ControlFlows    defined_event=BearerDelete(0x32)
    Check Defined Msg Included in Sherpa log    csvname=ControlFlows    defined_event=SessionSetup(0x61)
    Check Defined Msg Included in Sherpa log    csvname=ControlFlows    defined_event=SessionDelete(0x62)

Check SDU in L2LO
#    [Arguments]    ${csvname}
    Check Defined Msg Included in Sherpa log    csvname=ControlFlows    defined_event=BearerAdd(0x82)
    Check Defined Msg Included in Sherpa log    csvname=ControlFlows    defined_event=BearerDelete(0x31)

Check message in L2HiDU
#    [Arguments]    ${csvname}
    Check Defined Msg Included in Sherpa log    csvname=ControlFlows    defined_event=CpuMeasurment(0x4a)

Check message in L2Hi
#    [Arguments]    ${csvname}
    Check Defined Msg Included in Sherpa log    csvname=ControlFlows    defined_event=BearerSetupParam(0x60)
    Check Defined Msg Included in Sherpa log    csvname=ControlFlows    defined_event=BearerModifyReq(0x3a)
    Check Defined Msg Included in Sherpa log    csvname=ControlFlows    defined_event=BearerDelete(0x32)
    Check Defined Msg Included in Sherpa log    csvname=ControlFlows    defined_event=CpuMeasurment(0x4a)

Check Defined Msg Included in Sherpa log One By One
    [Arguments]    ${csvname}    ${defined_event}
    ${file_list}    Get and Upload Files Needs Decode
    should not be empty  ${file_list}
    FOR   ${file}   IN   @{file_list}
        ${passed}    run keyword and return status     _Check Defined Msg    pcapfile=${file}
        ...   csvname=${csvname}    defined_event=${defined_event}
        Exit For Loop If  ${passed}
    END
    run keyword if  not ${passed}    FAIL    CANNOT FIND ${defined_event} in ALL Pcap LOGS!    ERROR

_Check Defined Msg
    [Arguments]    ${csvname}    ${defined_event}
    ${row}    wait until keyword succeeds   1m    20s     get_one_row_as_defined_str
    ...    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    str=${defined_event}

Call Setup and check tput 2times
    [Arguments]   ${ue_index}=${ue_index}   ${tput}=100   ${tput_expect}=${tput}   ${loop_idx}=1
    Call Setup and check tput    ue_index=${ue_index}   tput=${tput}   tput_expect=${tput_expect}
    ...   traffic_stop=${false}
    power_ue.Stop Traffic   ue_type=${ue_${ue_index}_type}   direction=${direction}
    FOR  ${i}  IN RANGE  ${loop_idx}
        Start Traffic With Throughput Check   ue_type=${ue_${ue_index}_type}
        ...   ue_index=${ue_index}   direction=DL   throughput=${tput}   expect=${tput_expect}
        sleep  15s
    END
    [Return]   cpc_${ue_index}   ${ue_type}

Stream Case Start
    [Arguments]   ${stream}   ${level}   ${exec_type}=${EMPTY}
    COAM Login   alias=${coam_alias}
    COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    Run Keyword and Ignore Error   selenium_coam.stop_${stream}_trace
    ...   uplane_sherpa_name=${level.replace('_', '-').upper()}   source=${exec_type.upper()}
    sleep   15s
    Configure Logging Agent   uplane_destination=${uplane_destination}
    Start Stream Trace Action   level=${level}   exec_type=${exec_type}   stream=${stream}
    Start UDP Server Collecting   dcap_ip=${dcap_ip}    dcap_username=${dcap_username}    dcap_password=${dcap_password}
    COAM WEBUI Logout
    ${res}   Run Keyword and Ignore Error   Setup Call by mode single    call_mode=single
    Run Keyword Unless	'${res[0]}' == 'PASS'    log    L3 CALL FAILED!    WARN
    Set Suite Variable   ${call_alias}   ${res[1]}
    Stream Case Teardown    stream=${stream}    level=${level}    exec_type=${exec_type}

Setup Call by mode single
    [Arguments]   ${call_mode}
    ${alias}   Run Keyword If   '${call_mode.lower()}'=='single'  Call Setup and check tput 2times  port=58909
    ...   duration=${duration}   tput_expect=10
    ...   ELSE   Setup MultiCell Call   duration=${duration}
    [Return]   ${alias}


check recieved file
    [Arguments]    ${csvname}    ${defined_event}
    ${row}    get_one_row_as_defined_str    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    str=${defined_event}
    ${row2}    get_one_row_as_defined_str    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    str=DCI[k2

Check SRB in L2LO
    [Arguments]    ${csvname}
    ${row1}    wait until keyword succeeds   1m    20s     get_one_row_as_defined_str
    ...    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    str=UserSetupNoDrb(0x10)
    ${row1_value}   split string from right  ${row1}    ;
    ${SRB1_value}    set variable   ${row1_value[-6]}    #lcid
    ${row2}    wait until keyword succeeds   1m    20s     get_one_row_as_defined_str
    ...    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_${csvname}.csv    str=BearerAdd(0x82)
    ${row2_value}   split string from right  ${row2}    ;
    ${SRB2_value}    set variable   ${row2_value[-6]}    #lcid
    should be equal    ${SRB1_value}    1
    should be equal    ${SRB2_value}    2

Check PLMN in L2LO and L2HiDU
#    [Arguments]    ${csvname}
    COAM Login   alias=${coam_alias}
#    selenium_coam.enable_virtual_display
    COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    ${MRBTS_ID}   selenium_coam.get_bts_id
    ${pci_list}  Get PCI list
    ${mcc}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
     ...   filter_param=MCC in PLMN
    ${mnc}   selenium_coam.get_parameter_value   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
     ...   filter_param=MNC in PLMN
    COAM Logout   connection=${coam_alias}
    Run Keyword and Ignore Error   COAM WEBUI Logout
#    Set Suite Variable    ${context1}    plmnid=${mcc}-0${mnc} nbPci:1 pci: ${pci_list[0]};
#    Set Suite Variable    ${context2}    plmnid=${mcc}-0${mnc} nbPci:1 pci: ${pci_list[1]};
    ${context1}    Set Variable if    '${mcc}'=='1'    plmnid= 00${mcc}-0${mnc}    plmnid= ${mcc}-0${mnc}
    ${pci_nb}    Evaluate   len(${pci_list})
    ${context2}    set variable    nbPci:${pci_nb}
    ${context3}    set variable    pciNum:${pci_nb}
    #L2LO check
#    Check method not right for cells in multi du
#    :FOR  ${pci}  IN   @{pci_list}
#    \    Check Defined Trace Included in Sherpa log   csvname=ControlFlows    defined_event=Periodic3(0x54)   defined_info=${pci}
#    Check Defined Trace Included in Sherpa log   csvname=ControlFlows    defined_event=Periodic3(0x54)   defined_info=${context1}
#    Check Defined Trace Included in Sherpa log   csvname=ControlFlows    defined_event=Periodic3(0x54)   defined_info=${context2}
    #L2HiDU check
    FOR  ${pci}  IN   @{pci_list}
        Check Defined Trace Included in Sherpa log   csvname=ControlFlows    defined_event=Periodic(0x52)    defined_info=${pci}
    END
    Check Defined Trace Included in Sherpa log   csvname=ControlFlows    defined_event=Periodic(0x52)    defined_info=${context1}
    Check Defined Trace Included in Sherpa log   csvname=ControlFlows    defined_event=Periodic(0x52)    defined_info=${context3}

Get Coam Snapshop SA
    COAM Login
    ${snapshot_filename}    Catch Snapshot COAM
    COAM Logout
    run   rm -rf ${OUTPUT_DIR}/snapshot
    ${command_unzip}    Set Variable    unzip ${snapshot_filename} -d ${OUTPUT_DIR}/snapshot
    run   ${command_unzip}
    ${FILE_STRUCT}    snapshot_files.get_snapshot_file_orgnization    file_folder=${OUTPUT_DIR}/snapshot
    [Return]   ${FILE_STRUCT}

check recieved file T
#    ${traceSeqNum}   ${utcTimeStampMicro}   Get Tshark Filter from Sherpa Log   csvname=ControlFlows   defined_event=Ul LO
#    ${filter_expression}=    Run keyword if    '${traceSeqNum}'==''    Set Variable    L2Log_StreamInd_t.utcTimeStampMicro == ${utcTimeStampMicro}
#    ...   ELSE   Set Variable   L2Log_StreamInd_t.utcTimeStampMicro == ${utcTimeStampMicro} && L2Log_StreamIndSherpa_t.traceSeqNum == ${traceSeqNum}
#    ${return_value}   Check value in wireshark with sharpa log
#    ...   input_file=${local_pcap_path}
#    ...   xpath=.//DU_L2LO_UL_t.bufferedSlot
#    ...   filter=L2Log_StreamInd_t.utcTimeStampMicro==${utcTimeStampMicro}
#    ...   filter_expression=${filter_expression}
#    ${return_element_num}   Check value in wireshark with sharpa log
#    ...   input_file=${local_pcap_path}
#    ...   xpath=.//RNTI08_t.elementNb
#    ...   filter=L2Log_StreamInd_t.utcTimeStampMicro==${utcTimeStampMicro}
#    ...   `=${filter_expression}
##    Run keyword if    ${return_element_num[0]}>60   FAIL
#    ${return_mac_num}   Check value in wireshark with sharpa log
#    ...   input_file=${local_pcap_path}
#    ...   xpath=.//RNTI08_t.numberBytesMacCe
#    ...   filter=L2Log_StreamInd_t.utcTimeStampMicro==${utcTimeStampMicro}
#    ...   filter_expression=${filter_expression}
    wait until keyword succeeds   1m    20s     get_one_row_as_defined_str
    ...    csv_filename=${OUTPUT_LOG_PATH}/Sherpa_ControlFlows.csv    str=Ul LO

Pre&Post Conditoin: Update Configuration of actEcpri72e
     [Arguments]   ${celltype}=4t4r
#     log to console    Modify_Vendor
#     ${to_4t4r}   set variable
#     ...   cd ${OUTPUT_DIR};sudo sed -i 's|<p name="actEcpri72e">.*</p>|<p name="actEcpri72e">Ecpri72eULDL</p>|g' vendor_5g.xml
#     ${to_2t4r}   set variable
#     ...   cd ${OUTPUT_DIR};sudo sed -i 's|<p name="actEcpri72e">.*</p>|<p name="actEcpri72e">Ecpri72eULDL</p>|g' vendor_5g.xml
#     ${to_defualt}   set variable
#     ...   cd ${OUTPUT_DIR};sudo sed -i 's|<p name="actEcpri72e">.*</p>|<p name="actEcpri72e">disabled</p>|g' vendor_5g.xml
#     coam.connect to    bts_host=${WEBUI_ADDR}    username=${WEBUI_USER}
#     ...   password=${WEBUI_PASSWORD}    name=coam_admin
#     coam.download_vendor_file    target_file_name=${OUTPUT_DIR}/vendor_5g.xml    connection=coam_admin
#     sleep    3s
#     run keyword if    '${celltype}'=='4t4r'   Update Vendor Parameter    ${to_4t4r}
#     ...    ELSE IF    '${celltype}'=='2t4r'   Update Vendor Parameter    ${to_2t4r}
#     ...    ELSE IF    '${celltype}'=='default'   Update Vendor Parameter    ${to_defualt}
     run keyword if   '${celltype}'=='4t4r'    Load and Commission With Cell Type Updated    type_to_update=4T4R
     ...    ELSE IF    '${celltype}'=='2t4r'     Load and Commission With Cell Type Updated    type_to_update=2T4R
     ...    ELSE IF    '${celltype}'=='default'    Load and Commission With Cell Type Updated    type_to_update=default
     Wait Until Keyword Succeeds   5m   30s   gNB not Connected
     Wait Until Keyword Succeeds   5m   10s   Try Connect gNB
#     run keyword if    '${celltype}'!='default'   Online Update BBPOOL Value As WA of CB010891
     Wait Until Keyword Succeeds   1m   30s   COAM Login
     Wait Until Keyword Succeeds   15m   30s   COAM Check All Cells Onair
     [Teardown]    run keyword and ignore error   COAM WEBUI Logout


Update Vendor Parameter
    [Arguments]  ${parameter_to_be_updated}
     Connect to TestPc   alias=TestPc
     csn.execute    command=${parameter_to_be_updated}   connection=TestPc
     [Teardown]  csn.disconnect    connection=TestPc

Load and Commission With Cell Type Updated
    [Arguments]  ${type_to_update}
     run keyword and ignore error    COAM WEBUI Login
#     ${result}   selenium_coam.load_vendor_file_and_validate    file_path=${OUTPUT_DIR}/vendor_5g.xml
#     Run keyword if   '${result}'=='Validation failed!'
#     ...   selenium_coam.load_vendor_file_and_validate    file_path=${OUTPUT_DIR}/vendor_5g.xml
#     sleep   5s
     run keyword and ignore error   COAM WEBUI Whether Close Start Up View Window
     selenium_coam.load_commissioning_file_and_check_load_status
     ...   file_path=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/TL${Instance_Id}_${type_to_update}.xml   timeout=${120}
     selenium_coam.validate_plan
     selenium_coam.activate_plan   activate_plan_despite_errors=${True}
    [Teardown]    run keywords   run keyword and ignore error    COAM WEBUI Whether Close Start Up View Window
     ...   AND   run keyword and ignore error   COAM WEBUI Logout
     ...   AND   run keyword and ignore error   coam.teardown   connection=coam_admin

Online Update BBPOOL Value As WA of CB010891
#    log to console   Since SBTS00_ENB_9999_240806_000004, CB010891 force the BB pooling features to True which impact 7.2e to be onair
#    ...    manually pooling value update needed
    Log to console   since CB012605  actBbPoolingTddFr1Ecpri72e is true in vendor, which conflict with 72a BBPOOLING set,
    ...   will impact UE access, manually pooling value update to false
    sleep   15min
    COAM WEBUI Login
    COAM WEBUI Whether Close Start Up View Window
    ${current_bbpool}   selenium_coam.get_parameter_value   dist_name=MRBTS-${Instance_Id}/NRBTS-${Instance_Id}
	...   filter_param=Activate baseband resource pooling FR1 TDD
    Return from keyword if     '${current_bbpool}'=='false'     BBPooling already falsed
#    ${result}   selenium_coam.load_vendor_file_and_validate    file_path=${OUTPUT_DIR}/vendor_5g.xml
#    Run keyword if   '${result}'=='Validation failed!'
#    ...   selenium_coam.load_vendor_file_and_validate    file_path=${OUTPUT_DIR}/vendor_5g.xml
#    sleep   5s
    selenium_coam.set_parameter_value   dist_name=MRBTS-${Instance_Id}/NRBTS-${Instance_Id}
	 ...   filter_param=Activate baseband resource pooling FR1 TDD extension      new_value=false
    selenium_coam.set_parameter_value   dist_name=MRBTS-${Instance_Id}/NRBTS-${Instance_Id}
	...   filter_param=Activate baseband resource pooling FR1 TDD     new_value=false
	selenium_coam.set_parameter_value   dist_name=MRBTS-${Instance_Id}/NRBTS-${Instance_Id}
	...   filter_param=Activate enhanced algorithm of baseband resource pooling FR1 TDD     new_value=false
	selenium_coam.set_parameter_value   dist_name=MRBTS-${Instance_Id}/NRBTS-${Instance_Id}
	...   filter_param=Activate baseband resource pooling FR1 TDD enhancements    new_value=false
	selenium_coam.set_parameter_value   dist_name=MRBTS-${Instance_Id}/NRBTS-${Instance_Id}
	...   filter_param=Activate large baseband resource pooling FR1 TDD    new_value=false
	selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Teardown]    run keywords   COAM WEBUI Whether Close Start Up View Window
     ...   AND   run keyword and ignore error   COAM WEBUI Logout


Collect Snapshot and Screenshot If Keyword Failed
    [Documentation]   Collect Snapshot and Screenshot For Case Failed
    run keyword and ignore error    Stop and Save Syslog Collection
    run keyword and ignore error    Stop and Delete Syslog Collection
    Run Keyword And Ignore Error    Screenshot for case fail
    Run Keyword And Ignore Error    Save Snapshot logs On COAM  IP_WEBUI=${WEBUI_ADDR}
