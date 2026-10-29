*** Settings ***
Documentation    Author :
...              Squad group : SG_09
...              Feature : 5GC002063
Resource         ./../CUDU_L2/common_setup_teardown.robot
Resource         ./../CUDU_L2/common_dss_command.robot
#Library          ./../CUDU_L2/scripts/python/egate_operator.py
Library          ute_ue
Library          taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info

*** Variables ***
${ALLOC_SUBFRAME_10M_20M_50_50}    0010000010-0111001110-0011001110-0111000110-0011001010-0111001000-0010000000-0110000110
${ALLOC_SUBFRAME_15M_50_50}        0010000000-0111101000-0011100000-0111101000-0011100000-0111101000-0011100000-0011001000
${LOCAL_WTS_DIR}                   ${CURDIR}/Resource/
${WTS_CFG_10M}                     basic_wts_2063_10M.cfg
${WTS_CFG_15M}                     basic_wts_2063_15M.cfg
${WTS_CFG_20M}                     basic_wts_2063_20M.cfg
${WTS_CFG_10M_INTERHO}             basic_wts_2063_10M_InterHO.cfg
${WTS_CFG_MULTI_UES}               multi_ue_sa_fdd_configuration_file.lua
${WTS_CFG_10M_NORATEMATCH}         basic_wts_2063_10M_NoRateMatching.cfg
${WTS_CFG_10M_CONDUCT}             basic_wts_2063_10M_NSA_and_SA.cfg
${MULTIUE_SCRIPT}                  multi_ue_sa_script.lua
${WTS_AP_XML}                      AirPhoneConfig_2063.xml
${DELTA_PATH_10M_B005}             Delta_conf_5GC002063_ET_10M_B005.json
${DELTA_PATH_10M}                  Delta_conf_5GC002063_ET_10M.json
${DELTA_PATH_15M_B004}             Delta_conf_5GC002063_ET_15M_B004.json
${DELTA_PATH_15M_PRB}              Delta_conf_5GC002063_ET_15M_PRB.json
${DELTA_PATH_15M}                  Delta_conf_5GC002063_ET_15M.json
${DELTA_PATH_20M_PRB}              Delta_conf_5GC002063_ET_20M_PRB.json
${DELTA_PATH_20M}                  Delta_conf_5GC002063_ET_20M.json
${DELTA_PATH_10M_INTERHO}          Delta_conf_5GC002063_ET_10M_InterHO.json
${DELTA_PATH_10M_INTERHO27}        Delta_conf_5GC002063_ET_10M_InterHO27.json
${BIP_SCRIPT_PATH}                 /home/ute/generated_luashark/luashark.lua
${FILTER}                          dldata_pdcchsendreq
@{COLUMN_NAME}                     DlData_DciInfo.coresetFreqDomain    dci.dci10    DlData_DciInfo.startCce
${PATTERN_10MUL}                   DlData_PdcchSendReq.*?\\w{10}.*?\\w{0}4
${PATTERN_10MDL}                   DlData_PdcchSendReq.*?\\w{6}([89abcdef]).*?\\w{6}([89abcdef]).*?\\w{7}([02]).*?\\w{7}([02])
${PATTERN_20MUL}                   DlData_PdcchSendReq.*?\\w{1}[0-7].*?\\w{1}[8c]
${PATTERN_20MDL}                   DlData_PdcchSendReq.*?\\w{1}[89abcdef].*?\\w{0}[04].*?\\w{0}[4]
${PATTERN_15MUL_CORESET0}          DlData_PdcchSendReq.*?\\w{10}.*?\\w{0}4
${PATTERN_15MDL_CORESET0}          DlData_PdcchSendReq.*?\\w{1}[89abcdef].*?\\w{8}
${PATTERN_15MUL_CORESET1}          DlData_PdcchSendReq.*?\\w{10}.*?\\w{0}[8]
${PATTERN_15MDL_CORESET1}          DlData_PdcchSendReq.*?\\w{1}[89abcdef].*?\\w{1}[04].*?\\w{0[04]

${PATTERN_15MDL_CORESET0_PRB}      DlData_PdcchSendReq.*?\\w{1}[89abcdef].*?\\w{0}[0]
${PATTERN_15MUL_CORESET0_PRB}      DlData_PdcchSendReq.*?\\w{2}.*?\\w{0}[4]
${PATTERN_15MUL_CORESET1_PRB}      DlData_PdcchSendReq.*?\\w{2}.*?\\w{0}[48]
${PATTERN_15MDL_CORESET1_PRB}      DlData_PdcchSendReq.*?\\w{1}[89abcdef].*?\\w{0}[0]

${PATTERN_20MDL_CORESET0_PRB}      DlData_PdcchSendReq.*?\\w{1}[89abcdef].*?\\w{0}[0]
${PATTERN_20MUL_CORESET0_PRB}      DlData_PdcchSendReq.*?\\w{2}.*?\\w{0}[4]
${PATTERN_20MDL_CORESET1_PRB}      DlData_PdcchSendReq.*?\\w{1}[89abcdef].*?\\w{0}[0]
${PATTERN_20MUL_CORESET1_PRB}      DlData_PdcchSendReq.*?\\w{2}.*?\\w{0}[48]



${IPERF_EGREP_TCP_UL}              egrep -o '[[:digit:]]*.?[[:digit:]]*[[:space:]]Mbits/sec'
${IPERF_EGREP_TCP_DL}              egrep -o '[[:digit:]]*.?[[:digit:]]*[[:space:]]Mbits/sec'
${GNB_BIP_DIR}                     /tmp/CCSPacketCapture/
${GSCN}                            1588
${DL_MBPS}                         50
${UL_MBPS}                         50
${DL_MBPS_HO}                      2
${UL_MBPS_HO}                      2
${DURATION}                        30
${UE_ID}                           1
${PROFILE_ID}                      1
${DL_PORT_FOR_MULTIUE}             7071
${UL_PORT_FOR_MULTIUE}             7131
${CLIENT_IP}                       '1.2.4'
${BIND_IP}                         '10.0.2.1'
${PACKAGE_SIZE}                    1350
${WTS_AVG_INTERVAL}                Average packet interval
${SA_DL_10M}                       17
${SA_DL_15M}                       30
${SA_DL_20M}                       34
${SA_UL}                           1
${MULTI_DL_20M}                    15
${MULTI_DL_10M}                    5
${SA_UL_HO}                        2
${SA_DL_HO}                        2
${SCF_2F}                          ${CURDIR}/config/scf_2F.xml
${IPHY_2F}                         ${CURDIR}/config/iphy_2F.xml
${RD}                              0x4B000F=1

*** Keywords ***
SA Start Multi DLUL Traffic
    ute_wtssim.Execute Egate Command
    ...    cmd=script file=multi_ue_sa_script.lua entry=start_traffic_internal_multiue(1,2,1,8000000,10500000,both,40)
    Sleep    5s    reason=make ul and dl traffic

Start Multiue Register
    Log To Console    Start UE register for multi UEs...
    ${command}    Catenate    script file=multi_ue_sa_script.lua entry=start_multiue_call(1,2,2,internal)
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${command}    pass_regexp=UE2: Established PDU session ID=1     timeout=2minutes

Online Active CMAS
    Log To Console    Online active CMAS...
    Online Change One Para With Admin    ${NRBTS_DISTNAME}    actCMAS    true

CMAS Broadcast And Analysis
    [Arguments]    ${warning_msg}
    ${command}    Catenate    cbs_broadcast_start type=cmas amf=1 gnb=1 concurrent=true nrcgi=all warning_msg=${warning_msg}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${command}    pass_regexp=SystemInformationBlockType8-NR updated    timeout=2minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    SystemInformationBlockType8-NR updated    partial_match=${true}
    Log To Console    \n${output}

Config TL And Start Egate
    [Arguments]    ${delta_file}    ${cfg_file}
    Configure Gnb    ${delta_file}
    Verify Coam Site Is Ready
    Online Configure Srb And Drb InactivityTimer
    Start UTE WTS FOR DSS
    Set Suite Variable    ${WTS_CFG}    ${cfg_file}
    Log To Console    ${WTS_CFG}
    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
    Load Cfg File    ${WTS_CFG}

Check 10M Bip Log
    [Arguments]    ${bip_csv_Log}
    ${content}    OperatingSystem.Get File    ${bip_csv_Log}
    ${res_ul}    String.Get RegExp Matches    ${content}    ${PATTERN_10MUL}
    ${res_dl}    String.Get RegExp Matches    ${content}    ${PATTERN_10MDL}
    ${length_ul}    Get Length    ${res_ul}
    ${length_dl}    Get Length    ${res_dl}
    Log    num of 10MUL CORESET0=${length_ul}    WARN
    Log    num of 10MDL CORESET0=${length_dl}    WARN
    Should Be True    "${length_ul}">"0" or "${length_dl}">"0"

Check 15M Bip Log
    [Arguments]    ${bip_csv_Log}
    ${content}    OperatingSystem.Get File    ${bip_csv_Log}
    ${res_ul_coreset0}    String.Get RegExp Matches    ${content}    ${PATTERN_15MUL_CORESET0}
    ${res_dl_coreset0}    String.Get RegExp Matches    ${content}    ${PATTERN_15MDL_CORESET0}
    ${res_ul_coreset1}    String.Get RegExp Matches    ${content}    ${PATTERN_15MUL_CORESET1}
    ${res_dl_coreset1}    String.Get RegExp Matches    ${content}    ${PATTERN_15MDL_CORESET1}
    ${length_ul_coreset0}    Get Length    ${res_ul_coreset0}
    ${length_dl_coreset0}    Get Length    ${res_dl_coreset0}
    ${length_ul_coreset1}    Get Length    ${res_ul_coreset1}
    ${length_dl_coreset1}    Get Length    ${res_dl_coreset1}
    Log    num of 15MUL CORESET0=${length_ul_coreset0}    WARN
    Log    num of 15MDL CORESET0=${length_dl_coreset0}    WARN
    Log    num of 15MUL CORESET1=${length_ul_coreset1}    WARN
    Log    num of 15MDL CORESET1=${length_dl_coreset1}    WARN
    Should Be True    "${length_ul_coreset0}">"0" or "${length_dl_coreset0}">"0" or "${length_ul_coreset1}">"0" or "${length_dl_coreset1}">"0"

Check 20M Bip Log
    [Arguments]    ${bip_csv_Log}
    ${content}    OperatingSystem.Get File    ${bip_csv_Log}
    ${res_ul}    String.Get RegExp Matches    ${content}    ${PATTERN_20MUL}
    ${res_dl}    String.Get RegExp Matches    ${content}    ${PATTERN_20MDL}
    ${length_ul}    Get Length    ${res_ul}
    ${length_dl}    Get Length    ${res_dl}
    Log    num of 20MUL CORESET0=${length_ul}    WARN
    Log    num of 20MDL CORESET0=${length_dl}    WARN
    Should Be True    "${length_ul}">"0" and "${length_dl}">"0"

Check PRB Enable 15M Bip Log
    [Arguments]    ${bip_csv_Log}
    ${content}    OperatingSystem.Get File    ${bip_csv_Log}
    ${res_ul_coreset0}    String.Get RegExp Matches    ${content}    ${PATTERN_15MUL_CORESET0_PRB}
    ${res_dl_coreset0}    String.Get RegExp Matches    ${content}    ${PATTERN_15MDL_CORESET0_PRB}
    ${res_ul_coreset1}    String.Get RegExp Matches    ${content}    ${PATTERN_15MUL_CORESET1_PRB}
    ${res_dl_coreset1}    String.Get RegExp Matches    ${content}    ${PATTERN_15MDL_CORESET1_PRB}
    ${length_ul_coreset0}    Get Length    ${res_ul_coreset0}
    ${length_dl_coreset0}    Get Length    ${res_dl_coreset0}
    ${length_ul_coreset1}    Get Length    ${res_ul_coreset1}
    ${length_dl_coreset1}    Get Length    ${res_dl_coreset1}
    Log    num of 15MUL CORESET0=${length_ul_coreset0}    WARN
    Log    num of 15MDL CORESET0=${length_dl_coreset0}    WARN
    Log    num of 15MUL CORESET1=${length_ul_coreset1}    WARN
    Log    num of 15MDL CORESET1=${length_dl_coreset1}    WARN
    Should Be True    "${length_ul_coreset0}">"0" or "${length_dl_coreset0}">"0" or "${length_ul_coreset1}">"0" or "${length_dl_coreset1}">"0"

Check PRB Enable 20M Bip Log
    [Arguments]    ${bip_csv_Log}
    ${content}    OperatingSystem.Get File    ${bip_csv_Log}
    ${res_ul_coreset0}    String.Get RegExp Matches    ${content}    ${PATTERN_20MUL_CORESET0_PRB}
    ${res_dl_coreset0}    String.Get RegExp Matches    ${content}    ${PATTERN_20MDL_CORESET0_PRB}
    ${res_ul_coreset1}    String.Get RegExp Matches    ${content}    ${PATTERN_20MUL_CORESET1_PRB}
    ${res_dl_coreset1}    String.Get RegExp Matches    ${content}    ${PATTERN_20MDL_CORESET1_PRB}
    ${length_ul_coreset0}    Get Length    ${res_ul_coreset0}
    ${length_dl_coreset0}    Get Length    ${res_dl_coreset0}
    ${length_ul_coreset1}    Get Length    ${res_ul_coreset1}
    ${length_dl_coreset1}    Get Length    ${res_dl_coreset1}
    Log    num of 20MUL CORESET0=${length_ul_coreset0}    WARN
    Log    num of 20MDL CORESET0=${length_dl_coreset0}    WARN
    Log    num of 20MUL CORESET1=${length_ul_coreset1}    WARN
    Log    num of 20MDL CORESET1=${length_dl_coreset1}    WARN
    Should Be True    "${length_ul_coreset0}">"0" or "${length_dl_coreset0}">"0" or "${length_ul_coreset1}">"0" or "${length_dl_coreset1}">"0"

Prepare Test Env
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Backup Gnb Sw Coniguration
    Modify Gnb Sw Coniguration
    Backup AP Config File
    Configure Airphone
    Hard Reboot Testline
    Verify Coam Site Is Ready
    Set Config Path
    Adjust Network Configuration For Different Branch
    Create GNB BIP Dir

Set Config Path
    Log To Console    ${SW_BRANCH}
    Set Suite Variable    ${JSON_PATH}    ${CURDIR}/config/${SW_BRANCH}
    Log To Console    ${JSON_PATH}

Adjust Network Configuration For Different Branch
    ${localIpAddr}    Run    awk -F "[<|\>]" '/name=\\"localIpAddr\\"/{print $3}' ${OUTPUT_DIR}/SCF_before_suite.xml
    Set Suite Variable    ${localIpAddr}
    Log To Console    ${localIpAddr}
    Run Keyword If    '${localIpAddr}' != '10.0.1.2'
    ...    Modify IP Configuration
    ...    ELSE
    ...    Log To Console    Don't Need adjust network configuration for Trunk.\n

Modify IP Configuration
    Run    sed -i 's/10.0.1.2/${localIpAddr}/g' ${LOCAL_WTS_DIR}/${WTS_CFG_10M}
    Run    sed -i 's/10.0.1.2/${localIpAddr}/g' ${LOCAL_WTS_DIR}/${WTS_CFG_15M}
    Run    sed -i 's/10.0.1.2/${localIpAddr}/g' ${LOCAL_WTS_DIR}/${WTS_CFG_20M}
    Run    sed -i 's/10.0.1.2/${localIpAddr}/g' ${LOCAL_WTS_DIR}/${WTS_CFG_10M_INTERHO}
    Run    sed -i 's/10.0.1.2/${localIpAddr}/g' ${LOCAL_WTS_DIR}/${WTS_CFG_10M_NORATEMATCH}
    Run    sed -i 's/10.0.1.2/${localIpAddr}/g' ${LOCAL_WTS_DIR}/${WTS_CFG_10M_CONDUCT}

Recover Network Configuration For Different Branch
    Run Keyword If    '${localIpAddr}' != '10.0.1.2'
    ...    Recover IP Configuration
    ...    ELSE
    ...    Log To Console    Don't need recover network configuration.\n

Recover IP Configuration
    Run    sed -i 's/${localIpAddr}/10.0.1.2/g' ${LOCAL_WTS_DIR}/${WTS_CFG_10M}
    Run    sed -i 's/${localIpAddr}/10.0.1.2/g' ${LOCAL_WTS_DIR}/${WTS_CFG_15M}
    Run    sed -i 's/${localIpAddr}/10.0.1.2/g' ${LOCAL_WTS_DIR}/${WTS_CFG_20M}
    Run    sed -i 's/${localIpAddr}/10.0.1.2/g' ${LOCAL_WTS_DIR}/${WTS_CFG_10M_INTERHO}
    Run    sed -i 's/${localIpAddr}/10.0.1.2/g' ${LOCAL_WTS_DIR}/${WTS_CFG_10M_NORATEMATCH}
    Run    sed -i 's/${localIpAddr}/10.0.1.2/g' ${LOCAL_WTS_DIR}/${WTS_CFG_10M_CONDUCT}

SA Attach And Traffic For MultiUE
    [Arguments]    ${ue_num}
    Log To Console    start 5G SA attach for multiUE...
    ${pattern}    Set Variable    Script End
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=script file\=${MULTIUE_SCRIPT} entry\=\attach_traffic_detach\(1,${ue_num},180,5,yes,yes,yes\)
    ...    pass_regexp=${pattern}    timeout=6min
    Log To Console    ${output}

Recover TL Configuration
    Wait Until Keyword Succeeds    150s    5s    Check GNB And AP Ping OK
    Wait Until Keyword Succeeds    60s    5s    Check GNB SSH Connect OK
    Wait Until Keyword Succeeds    60s    5s    Check AP SSH Connect OK
    Delete GNB BIP Dir
    Recover Network Configuration For Different Branch
    Wait Until Keyword Succeeds    120s    5s    Recover Gnb Sw Coniguration
    Wait Until Keyword Succeeds    120s    5s    Recover AP Config File
    Teardown All Connections
    Hard Reboot Testline

Recover TL
    Common Test Teardown 2
    Recover Config


Configure Gnb
    [Arguments]    ${delta_file}
    Delta Commission Json File With Admin    delta_json=${delta_file}

Configure Airphone
    Modify GSCN On Airphone    50    ${GSCN}
    ${cmd}    Set Variable  sed -i "s|<cell>[0-9].[0-9]</cell>|<cell>1.1</cell>|" /ffs/run/simmode/iphy.xml
    Run Keyword If    '${ASP_BOARD_TYPE}'=='ABIL'
    ...    OperatingSystem.Run And Return Rc And Output    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} '${cmd}'
    ...    ELSE
    ...    Modify Cell IDs in iphy

Modify Cell IDs in iphy
    ${cmd1}    Set Variable  sed -i "s|<cell>2.1</cell>|<cell>1.1</cell>|" /ffs/run/simmode/iphy.xml
    ${cmd2}    Set Variable  sed -i "s|<cell>2.2</cell>|<cell>1.2</cell>|" /ffs/run/simmode/iphy.xml
    OperatingSystem.Run And Return Rc And Output    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} '${cmd1}'
    OperatingSystem.Run And Return Rc And Output    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} '${cmd2}'

Backup Gnb Sw Coniguration
    ${cmd}    Set Variable    cd /ffs/run/;cp ./swconfig.txt ./swconfig-TA.txt
    OperatingSystem.Run And Return Rc And Output    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} '${cmd}'

Modify Gnb Sw Coniguration
    ${cmd}    Set Variable    echo -e "\n0x59005D=1">>/ffs/run/swconfig.txt;crasign /ffs/run/swconfig.txt
    OperatingSystem.Run And Return Rc And Output    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} '${cmd}'

Recover Gnb Sw Coniguration
    ${cmd}    Set Variable    cd /ffs/run/;rm -rf ./swconfig.txt;mv swconfig-TA.txt swconfig.txt;crasign swconfig.txt
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} '${cmd}'

Recover Config
    ${bts_id}    Get BTS Id
    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
    Log To Console    recover gnb configuratio...
    COAM.Perform Commissioning
    ...    bts_id=${bts_id}
    ...    scf_file=${OUTPUT_DIR}/SCF_before_suite.xml
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=500
    Run Keyword And Ignore Error    COAM.Teardown

Setup SA L3 Call
    Log To Console    SA Attach...
    SA Register UE    ${UE_ID}    ${PROFILE_ID}
    SA 5G PDU Session Setup    ${UE_ID}
    Log To Console    SA Traffic...
    SA Start DLUL Traffic    ${DL_MBPS}    ${UL_MBPS}    ${DURATION}

Setup SA L3 Call For TCP Traffic
    Log To Console    SA Attach...
    SA Register UE    ${UE_ID}    ${PROFILE_ID}
    SA PDU Session Setup    ${UE_ID}
    Log To Console    SA Traffic...
    SA Start DLUL TCP Traffic    10    10    30

Load Cfg File
    [Arguments]    ${cfg_file}
    Log To Console    ${cfg_file}
    ute_wtssim.Execute Egate Command    cfg file\=${cfg_file}    pass_regexp=NG link is Up    timeout=360

Setup XP
    [Arguments]    ${nor_subframe}    ${prb_list}    ${min_dss_ratio}    ${max_dss_ratio}    ${min_prb_ratio}=30    ${max_prb_ratio}=70
    Setup XP LINK
    Set LTE NR DSS Mode
    Setup DSS Link
    Set DL RESOURCE Cell Reservation    ${min_dss_ratio}    ${max_dss_ratio}
    Cell Resource Coordination
    UL Resource Cell Reservation    ${min_prb_ratio}    ${max_prb_ratio}
    Cell Allocation    nor_subframe=${nor_subframe}    prb_list=${prb_list}

Check SA Traffic
    [Arguments]    ${tp_dl}    ${tp_ul}
    SA Check Average Traffic Bigger Than Target    dl    ${tp_dl}
    SA Check Average Traffic Bigger Than Target    ul    ${tp_ul}

Verify UE RRC Connection Release
    Log To Console    Check UE change to idle state
    ${cmd}    Set Variable    ue_pdu_session_setup ue=${ue_id} gw=1 pdu=1 nwslice=1
    ${pdusession_flag}    Set Variable    Initial Context Setup Successful for UE
    ${release_flag}    Set Variable    UE1: Received RRC Release while in FIVE-GS-MM-REGISTERED state
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}    pass_regexp=Received RRC Release    timeout=5minutes
    ${info_pdu}    String.Get Lines Matching Regexp    ${output}    ${pdusession_flag}    partial_match=${true}
    Log To Console    \n${info_pdu}
    ${info}    String.Get Lines Matching Regexp    ${output}    ${release_flag}    partial_match=${true}
    Log To Console    \n${info}

Verify RRC Release For TC A28
    Log To Console    Check RRC release because of UE not support rate matching
    ${cmd}    Set Variable    ue_pdu_session_setup ue=${ue_id} gw=1 pdu=1 nwslice=1
    ${release_flag}    Set Variable    Received Initial Context Setup Failure from GNB-1 with cause RAN release due to ngran generated reason.
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}    pass_regexp=AMF-1: UE CONTEXT RELEASE COMPLETE: gNB=1, AMF_UE_NGAP_ID=1    timeout=5minutes
    ${info}    String.Get Lines Matching Regexp    ${output}    ${release_flag}    partial_match=${true}
    Log To Console    \n${info}

Online Configure Srb And Drb InactivityTimer
    Log To Console    Online configure srbInactivityTimerSA...
    Online Change One Para With Admin    ${NRBTS_DISTNAME}    srbInactivityTimerSA    10
    Log To Console    Online configure drbInactivityTimerSA...
    Online Change One Para With Admin    ${NRBTS_DISTNAME}    drbInactivityTimerSA    10

Deploy MultiUE SCRIPT
    OperatingSystem.Run    cp ${LOCAL_WTS_DIR}/${MULTIUE_SCRIPT} ${WTS_DIR}

SA Get UE Average Traffic For MultiUE
    [Arguments]    ${dir}    ${id}
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | dir | Yes | Direction of Traffic |
    ...    Example:
    ...    | SA Get UE Average Traffic | ul |
    ...    | SA Get UE Average Traffic | dl |
    OperatingSystem.Run    ${IPERF_EGREP} /tmp/iperf_${dir}_${id}.txt | awk '{print $(1)}' > ${OUTPUT DIR}/iperf_${dir}_${id}_parsed.txt
    ${output}    OperatingSystem.Run    cat ${OUTPUT DIR}/iperf_${dir}_${id}_parsed.txt
    ${add_tmp}    Set Variable    0
    ${packet_number}    Set Variable    0
    ${list}    Split String    ${output}    \n
    FOR    ${var}    IN    @{list}
    ${add_tmp}    Evaluate    ${var}+${add_tmp}
    ${packet_number}    Evaluate    ${packet_number}+1
    END
    ${avg}    Evaluate    ${add_tmp}/${packet_number}
    Log    The ${dir} Troughput is ${avg}M    console=True
    [Return]    ${avg}

SA Check Average Traffic Bigger Than Target For Multi UE
    [Arguments]    ${dir}    ${tp_rate}    ${iperf_file_id}
    ${tput_avg}=    SA Get UE Average Traffic For MultiUE    ${dir}    ${iperf_file_id}
    ${tp_delta}    Evaluate    ${tput_avg}-${tp_rate}
    Log To Console    For UE${iperf_file_id}:\n
    Log To Console    Actual ${dir} TPUT=${tput_avg}M, Expected ${dir} TPUT=${tp_rate}M
    Should Be True    ${tp_delta}>=0    Throughtput is not bigger than the expected value!

Backup AP Config File
    ${cmd}    Set Variable    cd /ffs/run/simmode/;cp ./iphy.xml /ffs/run/iphy-bak-TA.xml
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} '${cmd}'

Recover AP Config File
    ${cmd}    Set Variable    cd /ffs/run/simmode/;rm -rf ./iphy.xml;mv /ffs/run/iphy-bak-TA.xml ./iphy.xml
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} '${cmd}'

SA Start DLUL TCP Traffic
    [Arguments]    ${dlmbps}=5    ${ulmbps}=5    ${duration}=10
    [Documentation]    This keyword is to start DL and UL TCP traffic by iperf at the same time.
    ...    | Input Parameters | Man. | Description |
    ...    | dlmbps | Yes | mbps, default is 5M |
    ...    | ulmbps | Yes | mbps, default is 5M |
    ...    | duration | Yes | duration, default is 10s |
    ...    Example:
    ...    | SA Start DLUL TCP Traffic | 20 | 10 | 10 |
    Log To Console    ready to start DL and UL TCP traffic at the same time...
    Log To Console    start DL traffic...
    Execute Iperf In Linux    args=-s -p 7070 -i 1 -l 1400 -B 10.0.2.1
    ...    pipe_args=| tee /tmp/iperf_dl.txt
    Execute Iperf In Linux    args=-c 1.2.4.2 -p 7070 -l 1400 -i 1 -t ${duration} -B 10.0.2.1
    Log To Console    Running DL Traffic ${dlmbps}M for ${duration}s
    Log To Console    start UL traffic...
    Execute Iperf In Linux    args=-s -p 7071 -i 1 -l 1400 -B 10.0.2.1
    ...    pipe_args=| tee /tmp/iperf_ul.txt
    Execute Iperf In Linux    args=-c 72.23.0.1 -p 7071 -l 1400 -i 1 -t ${duration} -B 10.0.2.1
    Log To Console    Running UL Traffic ${ulmbps}M for ${duration}s
    Sleep    ${duration}s

Setup SA L3 Call For InterHO
    Log To Console    SA Attach...
    SA Register UE    ${UE_ID}    ${PROFILE_ID}
    SA 5G PDU Session Setup    ${UE_ID}
    Log To Console    SA Traffic...
    SA Start DLUL Traffic For InterHO    ${DL_MBPS_HO}    ${UL_MBPS_HO}    ${DURATION}

Load Cfg File For InterHO
    [Arguments]    ${cfg_file}
    Log To Console    ${cfg_file}
    ute_wtssim.Execute Egate Command    cfg file\=${cfg_file}    pass_regexp=GNB-3: XnAP Link with GNB-1 .* is up    timeout=360

Configure IP For InterHO
    [Documentation]    This keyword is to configure VM interfaces for InterHO.
    Log To Console    configure VM interfaces for InterHO ...
    OperatingSystem.Run    sudo ip addr add 10.0.3.151/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.3.153/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 192.168.6.252/32 dev eth2

Delete InterHO IP
    [Documentation]    This keyword is to delete VM interfaces for InterHO.
    Log To Console    delete VM interfaces for InterHO ...
    OperatingSystem.Run    sudo ip addr del 10.0.3.151/32 dev eth3
    OperatingSystem.Run    sudo ip addr del 10.0.3.153/32 dev eth3
    OperatingSystem.Run    sudo ip addr del 192.168.6.252/32 dev eth2

Trigger A3 Rsrp Measurement From Real To Sim
    ${a3_rsrp_cmd}    Set Variable
    ...    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=20 srsrq_nr=40 phycell_id=49 nrsrp_nr=100 nrsrq_nr=50
    Execute Egate Command    ${a3_rsrp_cmd}    pass_regexp=Inter-eNB handover
    Sleep    10s    reason=wait ULDL Traffic after InterHO

Trigger A3 Rsrp Measurement From Sim To Real
    ${a3_rsrp_cmd}    Set Variable
    ...    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=20 srsrq_nr=40 phycell_id=50 nrsrp_nr=100 nrsrq_nr=50
    Execute Egate Command    ${a3_rsrp_cmd}    pass_regexp=Inter-eNB handover
    Sleep    10s    reason=wait ULDL Traffic after InterHO

Setup WTS Config For InterHO
    Set Suite Variable    ${WTS_CFG}    ${WTS_CFG_10M_INTERHO}
    Log To Console    ${WTS_CFG}    ${WTS_AP_XML}
    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
    Load Cfg File For InterHO    ${WTS_CFG}

Set Parameter For Trigger Hanover By A3 Event Should Success
    Log To Console    Set parameter for InterHO...
    Set Parameter In EGate
    Setup Xn Listening Status
    Setup One Xnlink Up

Set Parameter In EGate
    ${prepare_1}    Set Variable
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=1 time_ue_stayed_in_cell=97
    ${prepare_2}    Set Variable
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    ${prepare_3}    Set Variable
    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=1 time_ue_stayed_in_cell=97
    ${prepare_4}    Set Variable    ue_history_information_list id=1 action=commit
    ${prepare_5}    Set Variable    ue_enb_param id=1 ue_history_list=1
    ute_wtssim.Execute Egate Command    ${prepare_1}
    ute_wtssim.Execute Egate Command    ${prepare_2}
    ute_wtssim.Execute Egate Command    ${prepare_3}
    ute_wtssim.Execute Egate Command    ${prepare_4}
    ute_wtssim.Execute Egate Command    ${prepare_5}

Setup Xn Listening Status
    ${cmd1}    Catenate    gnb_param id=3 xn_listening_socket=1 send_xn_setup=True measEvent=A3
    ute_wtssim.Execute Egate Command    ${cmd1}

Setup One Xnlink Up
    ${cmd1}    Catenate    gnb_xn_link_up    gnb=3 target=1
    ute_wtssim.Execute Egate Command    ${cmd1}
    ute_wtssim.Execute Egate Command    ${cmd1}

SA Start DLUL Traffic For InterHO
    [Arguments]    ${dlmbps}=5    ${ulmbps}=5    ${duration}=10
    [Documentation]    This keyword is to start DL and UL traffic by iperf at the same time.
    ...    | Input Parameters | Man. | Description |
    ...    | dlmbps | Yes | mbps, default is 5M |
    ...    | ulmbps | Yes | mbps, default is 5M |
    ...    | duration | Yes | duration, default is 10s |
    ...    Example:
    ...    | SA Start DLUL Traffic | 20 | 10 | 10 |
    Log To Console    ready to start DL and UL traffic at the same time...
    Log To Console    start DL traffic...
    Execute Iperf In Linux    args=-c 1.2.4.2 -u -p ${DL_PORT} -l 1300 -b ${dlmbps}M -i 1 -t ${duration}
    Execute Iperf In Linux    args=-s -u -p ${DL_PORT} -i 1 -B 10.0.2.1
    ...    pipe_args=| tee /tmp/iperf_dl.txt
    Log To Console    Running DL Traffic ${dlmbps}M for ${duration}s
    Log To Console    start UL traffic...
    Execute Iperf In Linux    args=-c 72.23.0.1 -u -p ${UL_PORT} -l 1300 -b ${ulmbps}M -i 1 -t ${duration}
    Execute Iperf In Linux    args=-s -u -p ${UL_PORT} -i 1 -B 10.0.2.1
    ...    pipe_args=| tee /tmp/iperf_ul.txt
    Log To Console    Running UL Traffic ${ulmbps}M for ${duration}s
    Sleep    5s

SA Start TCP DLUL Traffic
    [Arguments]    ${dlmbps}=5    ${ulmbps}=5    ${duration}=3600
    [Documentation]    This keyword is to start TCP DL and UL traffic by iperf at the same time.
    ...    | Input Parameters | Man. | Description |
    ...    | dlmbps | Yes | mbps, default is 5M |
    ...    | ulmbps | Yes | mbps, default is 5M |
    ...    | duration | Yes | duration, default is 10s |
    ...    Example:
    ...    | SA Start TCP DLUL Traffic | 20 | 10 | 10 |
    Log To Console    Ready to start DL and UL TCP traffic at the same time...
    Log To Console    start DL TCP traffic...
    Execute Iperf In Linux    args=-c 1.2.4.2 -p ${DL_PORT} -l 1400 -i 1 -b ${dlmbps}M -t ${duration} -B 10.0.2.1
    Execute Iperf In Linux    args=-s -p ${DL_PORT} -i 1 -B 10.0.2.1
    ...    pipe_args=| tee /tmp/iperf_dl.txt
    Log To Console    Running DL TCP Traffic ${dlmbps}M for ${duration}s
    Log To Console    start UL TCP traffic...
    Execute Iperf In Linux    args=-c 72.23.0.1 -p ${UL_PORT} -l 1400 -i 1 -b ${ulmbps}M -t ${duration} -B 10.0.2.1
    Execute Iperf In Linux    args=-s -p ${UL_PORT} -i 1 -B 10.0.2.1
    ...    pipe_args=| tee /tmp/iperf_ul.txt
    Log To Console    Running UL TCP Traffic ${ulmbps}M for ${duration}s
    Sleep    ${duration}s

Setup NSA L3 Call For Concurrent Mode
    ute_wtssim.Execute Egate Command    cmd=enb_x2_link_up enb\=2 target\=1    pass_regexp=is up    timeout=300
    ute_wtssim.Execute Egate Command    cmd=ue_attach id\=11    pass_regexp=UE IS ACTIVE    timeout=300
    BuiltIn.Log    \n NSA Attach is OK \n    console=yes
    ${traffic_cmd}    Set Variable    ue_dc_enb_start ue=11 target_gnb=1 target_cells=1 bearer=2 type=split_scg
    ute_wtssim.Execute Egate Command    cmd=${traffic_cmd}    pass_regexp=SgNB Modification Confirm    timeout=300
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=11 id\=2 dir\=dl mbps\=35 seconds\=60
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=11 id\=2 dir\=ul mbps\=25 seconds\=60
    Sleep    10s
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=11 id\=2
    Check Traffic On NSA In WTS    ${SA_DL_10M}    ${SA_UL}    
    BuiltIn.Log    \n NSA Traffic is OK \n    console=yes

Check Traffic On NSA In WTS
    [Arguments]    ${throughput_dl}    ${throughput_ul}
    ${check_cmd}    Set Variable    bearer_stats ue=11 id=2 type=l3 dc_cell_group=all
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${check_cmd}    pass_regexp=${WTS_AVG_INTERVAL}    timeout=150
    Create File    /tmp/nsa_traffic.txt    ${output}
    ${avg_dl}    Run    cat /tmp/nsa_traffic.txt | grep -m 2 'Average data rate' | awk '{print $4}' | sed -n '2p'
    ${real_tp_dl}    Evaluate    ${avg_dl}*0.000001
    Should Be True    ${throughput_dl}<=${real_tp_dl}
    ${avg_ul}    Run    cat /tmp/nsa_traffic.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${real_tp_ul}    Evaluate    ${avg_ul}*0.000001
    Should Be True    ${throughput_ul}<=${real_tp_ul}

Modify Delta File
    Run    sed -i 's/10.0.1.1/10.0.1.121/g' ${JSON_PATH}/${DELTA_PATH_10M}

Recover Delta File
    Run    sed -i 's/10.0.1.121/10.0.1.1/g' ${JSON_PATH}/${DELTA_PATH_10M}

SA Attach Release And Traffic For MultiUE
    [Arguments]    ${ue_num}
    Log To Console    start 5G SA attach for multiUE...
    ${pattern}    Set Variable    Script End
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=script file\=${MULTIUE_SCRIPT} entry\=\attach_traffic_detach\(1,${ue_num},180,5,yes,no,no\)
    ...    pass_regexp=${pattern}    timeout=6min
    Log To Console    ${output}    
    Wait Until Keyword Succeeds    1 min    5s    Check MultiUE Release    2    ${output}    
    Log To Console    start 5G SA traffic for multiUE...
    Sleep    60s    reason=wait for process completed
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=script file\=${MULTIUE_SCRIPT} entry\=\attach_traffic_detach\(1,${ue_num},180,5,no,yes,yes\)
    ...    pass_regexp=${pattern}    timeout=6min
    Log To Console    ${output}

Check MultiUE Release
    [Arguments]    ${ue_num}    ${output}
    ${loop}    Evaluate    ${ue_num}+1
    :FOR    ${id}    IN RANGE    1    ${loop}
    \    ${pdusession_flag}    Set Variable    Initial Context Setup Successful for UE with AMF UE ID ${id}
    \    ${release_flag}    Set Variable    UE${id}: Received RRC Release while in FIVE-GS-MM-REGISTERED state
    \    ${info_pdu}    String.Get Lines Matching Regexp    ${output}    ${pdusession_flag}    partial_match=${true}
    \    Log To Console    \n${info_pdu}
    \    ${info}    String.Get Lines Matching Regexp    ${output}    ${release_flag}    partial_match=${true}
    \    Log To Console    \n${info}

SA Get UE Average Traffic For TCP
    [Arguments]    ${dir}
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | dir | Yes | Direction of Traffic |
    ...    Example:
    ...    | SA Get UE Average Traffic | ul |
    ...    | SA Get UE Average Traffic | dl |
    Run Keyword If    '${dir}'=='dl'
    ...    OperatingSystem.Run    ${IPERF_EGREP_TCP_DL} /tmp/iperf_${dir}.txt | awk '{print $(1)}' > ${OUTPUT DIR}/iperf_${dir}_parsed.txt
    ...    ELSE
    ...    OperatingSystem.Run    ${IPERF_EGREP_TCP_UL} /tmp/iperf_${dir}.txt | awk '{print $(1)}' > ${OUTPUT DIR}/iperf_${dir}_parsed.txt
    ${output}    OperatingSystem.Run    cat ${OUTPUT DIR}/iperf_${dir}_parsed.txt
    ${add_tmp}    Set Variable    0
    ${packet_number}    Set Variable    0
    ${list}    Split String    ${output}    \n
    FOR    ${var}    IN    @{list}
    ${add_tmp}    Evaluate    ${var}+${add_tmp}
    ${packet_number}    Evaluate    ${packet_number}+1
    END
    ${avg}    Evaluate    ${add_tmp}/${packet_number}
    [Return]    ${avg}

SA Check Average Traffic Bigger Than Target For TCP
    [Arguments]    ${dir}
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | dir | Yes | Direction of Traffic |
    ...    | tp_rate | Yes | Throughput Rate for traffic |
    ...    Example:
    ...    | SA Check Average Traffic bigger than target | ul |
    ...    | SA Check Average Traffic bigger than target | dl |
    ${tput_avg}=    SA Get UE Average Traffic For TCP    ${dir}
    Run Keyword If    '${dir}'=='dl'
    ...    Log To Console    Actual ${dir} TPUT=${tput_avg}K
    ...    ELSE
    ...    Log To Console    Actual ${dir} TPUT=${tput_avg}M
    Should Be True    ${tput_avg}>0    Throughtput is not bigger than the expected value!

Check SA TCP Traffic
    SA Check Average Traffic Bigger Than Target For TCP    dl
    SA Check Average Traffic Bigger Than Target For TCP    ul

Create GNB BIP Dir
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 mkdir ${GNB_BIP_DIR} -p

Delete GNB BIP Dir
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 rm -rf ${GNB_BIP_DIR}

Collect And Convert GNB BIP
    [Arguments]    ${log_path}
    Collect GNB BIP By Admin Method    ${log_path}
    Convert BIP to CSV By MCShark    ${log_path}/5GBipL2L1_filtering_off.pcap    ${log_path}/coreset.csv    ${FILTER}    ${COLUMN_NAME}

Collect And Convert GNB BIP For Branch
    [Arguments]    ${log_path}
    OperatingSystem.Run     mkdir -p ${log_path}
    Copy BIP Files And Return Count    ${log_path}
    ${bip_csv_Log}=    Convert BIP Log Pcap To Csv    ${log_path}/5GBipL2L1_filtering_off.pcap0    ${FILTER}    ${COLUMN_NAME}    CORESET
    [Return]    ${bip_csv_Log}

Check TL Type And Suite Setup
    ${testline_type}=    Get Testline Type
    Run Keyword If    '${testline_type}'=='CLOUD_5G_I_LO_AP_LO'    Run Keywords    
    ...    Prepare Configuration For Each Case
    ...    AND    Backup Scf    ${OUTPUT_DIR}    before_suite
    ...    ELSE    Suite Setup Update GNB

Recover TL2
    Common Test Teardown 2    egate=false
    Recover Config

Prepare Configuration For Each Case
    Suite Setup Update GNB
    Add RD Parameters To GNB Swconfig File    ${RD}
    Modify IPHY File And Send to Airphone    ${IPHY_2F}
    Full Commission With SCF File    ${SCF_2F}
    Sleep    120s    wait testline can reboot stable.
    ${res}    Run Keyword And Return Status    Verify Coam Site Is Ready
    Run Keyword If    '${res}'=='False'    Reboot TL And Check Configured
