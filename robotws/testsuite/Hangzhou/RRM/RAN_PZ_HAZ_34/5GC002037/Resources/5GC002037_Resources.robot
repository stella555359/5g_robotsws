*** Settings ***
Documentation           author: Li Yajie
...                     contact: yajie.li@nokia-sbell.com
...                     squad group: SG_01
...                     feature : 5GC002037
Library                 taf.transport.ssh    WITH NAME    csn
Library    taf.analyzer.pcap    WITH NAME   cap
#Library    taf.analyzer.pcap     WITH NAME    cap
Resource                ../../5GC000496_C/Resources/L3Call.robot

Library                 taf.collectors.core   WITH NAME   core
Library                 taf.collectors.btslog  WITH NAME   btslog
Library                 taf.ue    WITH NAME    ute_ue
Library                 taf.hw.rf_attenuator    WITH NAME    PA
#Variables               ${CFGFILE_ON_GIT}/5GC002037/Delta_SCF.py
#Variables               ${CFGFILE_ON_GIT}/TLDelta.py
#Variables               ${CFGFILE_ON_GIT}/5GC002037/Delta_SCF_ENB.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ipsl.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot


*** Variables ***
#${UE_TYPE}              huawei_sigspark
${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}
${log_dir}              /ffs/run/config/toor4nsn

#${CFGFILE_ON_GIT}       /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
#${GoldenSCF_PATH}       /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/${GoldenSCF}
#${GoldenSCF_ON_GIT}     /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/

#${TL_DeltaPath}         ${CFGFILE_PATH}/TLDelta.py
#${DeltaPath}            ${CFGFILE_PATH}/5GC002037/Delta_SCF.py
#${initial_ENB_SCF}      ${CFGFILE_PATH}/TestLineSCFeNB.xml

${MRBTS_ID}             ${tl.gnbs[0].instance_id}
${NRBTS_ID}             ${tl.gnbs[0].global_bts_id}

${ASIK_LMP_IP}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}              ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${UTE_IP}               ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}         ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}         ${tl.test_pc.default_ssh_connection_details.password}

${WEBUI_IP}             ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}       ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}            https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

${PB_ASIK_IP}           ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}         ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}           ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}         ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

${ENB_WEBUI_IP}          ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENB_USERNAME}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${ENB_PASSWORD}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}

${IMSI}                 ${tl.ues[0].imsi}

${5GC_IP}               ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}         ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}         ${tl.core.default_ssh_connection_details.password}

## Attenuator parameter ##
${PA_INFO}            ${tl.attenuator}

####GNB1####
${5GRU1_ANT1}    ${1}
${5GRU1_ANT2}    ${2}
${5GRU2_ANT1}    ${3}
${5GRU2_ANT2}    ${4}
${5GRU3_ANT1}    ${5}
${5GRU3_ANT2}    ${6}

####GNB2####
${5GRU4_ANT1}    ${7}
${5GRU4_ANT2}    ${8}

##IPSL for 2037
${IPSL_TOOL_DIR}           c:/IpslTools
${IPSL_COMPILER_FLAGS}      /pDIA05IGX /its /b
${IPSL_CONFIG_CPC}         C:/IPSL/2037_ipsl

${IPSL_IP}           ${tl.ues[0].ssh_connection_details.addr}
${IPSL_USERNAME}    ${tl.ues[0].ssh_connection_details.username}
${IPSL_PASSWORD}    ${tl.ues[0].ssh_connection_details.password}

##################define these variable for convenient############################
${ALIAS_ASIK}               asik                                                ##
${ALIAS_ASIK_SLAVE}         asik_slave                                          ##
${ALIAS_ABIL}               abil                                                ##
${ALIAS_ABIL_SLAVE}         abil_slave                                          ##
${ALIAS_UTE}                ute                                                 ##
${ALIAS_ASP_1A}             ASP_1A                                              ##
${ALIAS_AMF}                AMF                                                 ##
${ALIAS_QC}                 QC                                                  ##
${ALIAS_UPF}                UPF                                                 ##
${ASIK_SSH_IP}              asik_ssh                                            ##
${ALIAS_5GC}                5gc                                                 ##
${ALIAS_APN}                APN                                                 ##
${ALIAS_ENB}                ENB                                                 ##
########################END of alias Define#######################################



*** Keywords ***
TC.5GC002037_A_01_Vlan configuration for APN based slicing
    Run Keyword And Continue On Failure    GNB Commission For 2037 Case    SCF=2037_A6_SCF.xml
    ...    ParameterToDelete=PARAMS_TO_DELETE_2037_A6    ParamterToModify=PARAMS_TO_MODIFY_2037_A6
    ...        MOsToAdd=ADD_MOs_2037_A6    ListToAdd=ADD_TO_List_2037_A6
    Run Keyword And Continue On Failure    WEBUI.Check NSA Slice And Vlan Info

TC.5GC002037_A_06_Add 20 slices to single PLMN
    Run Keyword And Continue On Failure    GNB Commission For 2037 Case    SCF=2037_A6_SCF.xml
    ...    ParameterToDelete=PARAMS_TO_DELETE_2037_A6
    ...    ParamterToModify=PARAMS_TO_MODIFY_2037_A6    MOsToAdd=ADD_MOs_2037_A6    ListToAdd=ADD_TO_List_2037_A6
    Run Keyword And Continue On Failure    WEBUI.Check NSA Slice And Vlan Info

TC.5GC002037_A_08_Delete and modify slices successful
    Run Keyword And Continue On Failure    GNB Commission For 2037 Case    SCF=2037_A8_SCF.xml
    ...    ParameterToDelete=PARAMS_TO_DELETE_2037_A8
    ...    ParamterToModify=PARAMS_TO_MODIFY_2037_A8    MOsToAdd=ADD_MOs_2037_A8    ListToAdd=ADD_TO_List_2037_A8
    Run Keyword And Continue On Failure    WEBUI.Modify 2037 Feature Flag    new_value=true
    Run Keyword And Continue On Failure    WEBUI.Delete And Modify Slices

TC.5GC002037_A_09_Active feature flag with configed slices is successful
    Run Keyword And Continue On Failure    GNB Commission For 2037 Case    SCF=2037_A8_SCF.xml
    ...    ParameterToDelete=PARAMS_TO_DELETE_2037_A8    ParamterToModify=PARAMS_TO_MODIFY_2037_A8
    ...    MOsToAdd=ADD_MOs_2037_A8    ListToAdd=ADD_TO_List_2037_A8
    Run Keyword And Continue On Failure    WEBUI.Modify 2037 Feature Flag    new_value=true
    Run Keyword And Continue On Failure    WEBUI.Delete And Modify Slices

TC.5GC002037_A_12_Ongoing call is released when corresponding slice is deleted_ASIB
    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${1}
    Run Keyword And Continue On Failure    GNB Commission For 2037 Case    SCF=2037_A12_SCF.xml
    ...    ParameterToDelete=PARAMS_TO_DELETE_2037_A12    ParamterToModify=PARAMS_TO_MODIFY_2037_A12
    ...    MOsToAdd=ADD_MOs_2037_A12    ListToAdd=ADD_TO_List_2037_A12
    Run Keyword And Continue On Failure    CheckX2StatusUntilReady
    Run Keyword And Continue On Failure    IPSL server preparation without replace files    ipsl_config_dir=${IPSL_CONFIG_CPC}
    Run Keyword And Continue On Failure    COAM_WebEM.Login
    Run Keyword And Continue On Failure    Start to collect the X2 log on eNB    x2_log_name=2037_A12_ENB.pcap
    Run Keyword And Continue On Failure    UE.UE attach with DL traffic    ue_type=${UE_TYPE}    ue_index=${1}
    ...    apn_address=${NSA_APN}   ue_mode=NSA
    Run Keyword And Continue On Failure    WEBUI.Delete NSA Slice    NSA_Slice=NRNWSLICE_NSA-1
    sleep    30s
    Run Keyword And Continue On Failure    Stop and download X2 Logs on eNB    x2_log_name=2037_A12_ENB.pcap
    Run Keyword And Continue On Failure    Wireshark.Analyse ENDCPartialReset    filename=2037_A12_ENB.pcap
    Run Keyword And Ignore Error    UE.Detach UE with Stop traffic    ue_type=${UE_TYPE}    ue_index=${1}
    ...    apn_address=${NSA_APN}   ue_mode=NSA
    Run Keyword And Ignore Error    COAM_WebEM.Logout

TC.5GC002037_A_14_Ongoing call is released when the QCI of corresponding slice is changed_ASIB
    Run Keyword And Continue On Failure    GNB Commission For 2037 Case    SCF=2037_A14_SCF.xml
    ...    ParameterToDelete=PARAMS_TO_DELETE_2037_A12    ParamterToModify=PARAMS_TO_MODIFY_2037_A12
    ...        MOsToAdd=ADD_MOs_2037_A12    ListToAdd=ADD_TO_List_2037_A12
    Run Keyword And Continue On Failure    CheckX2StatusUntilReady
    Run Keyword And Continue On Failure    IPSL server preparation without replace files    ipsl_config_dir=${IPSL_CONFIG_CPC}
    Run Keyword And Continue On Failure    COAM_WebEM.Login
    Run Keyword And Continue On Failure    Start to collect the X2 log on eNB    x2_log_name=2037_A14_ENB.pcap
    Run Keyword And Continue On Failure    UE.UE attach with DL traffic    ue_type=${UE_TYPE}    ue_index=${1}
    ...    apn_address=${NSA_APN}   ue_mode=NSA
    Run Keyword And Continue On Failure    WEBUI.Modify NSA Slice   NSA_Slice=NRNWSLICE_NSA-1    new_value=${130}    except_value=130
    sleep    30s
    Run Keyword And Continue On Failure    Stop and download X2 Logs on eNB    x2_log_name=2037_A14_ENB.pcap
    Run Keyword And Continue On Failure    Wireshark.Analyse ENDCPartialReset    filename=2037_A14_ENB.pcap
    Run Keyword And Ignore Error    UE.Detach UE with Stop traffic    ue_type=${UE_TYPE}    ue_index=${1}
    ...    apn_address=${NSA_APN}   ue_mode=NSA
    Run Keyword And Ignore Error    COAM_WebEM.Logout

TC.5GC002037_A_27_Counter update checking for VLAN_ASIB
    Run Keyword And Continue On Failure    GNB Commission For 2037 Case    SCF=2037_A27_SCF.xml
    ...    ParameterToDelete=PARAMS_TO_DELETE_2037_A27    ParamterToModify=PARAMS_TO_MODIFY_2037_A27
    ...    MOsToAdd=ADD_MOs_2037_A27    ListToAdd=ADD_TO_List_2037_A27
    Run Keyword And Continue On Failure    CheckX2StatusUntilReady
    Run Keyword And Continue On Failure    IPSL server preparation without replace files    ipsl_config_dir=${IPSL_CONFIG_CPC}
    Run Keyword And Continue On Failure    Start to collect the X2 log on eNB    x2_log_name=2037_A27_ENB.pcap
    Run Keyword And Continue On Failure    UE.UE attach with ULDL traffic    ue_type=${UE_TYPE}    ue_index=${1}
    ...    apn_address=${NSA_APN}   ue_mode=NSA
    Run Keyword And Continue On Failure    Stop and download X2 Logs on eNB    x2_log_name=2037_A27_ENB.pcap
    Run Keyword And Continue On Failure    Wireshark.Analyse ENB pcap for A27    filename=2037_A27_ENB.pcap    localIpAddr=IPIF-2/IPADDRESSV4-2
    wait until keyword succeeds    4x    3min    Process.Check Counters of 2037 A27    VLANIF=VLANIF-${CASE_INPUT_5GC002037['vlanId']}
    Run Keyword And Ignore Error    UE.Detach UE with Stop traffic    ue_type=${UE_TYPE}    ue_index=${1}
    ...    apn_address=${NSA_APN}   ue_mode=NSA

Refine PA Port
    run keyword and ignore error    Set Suite Variable     ${5GRU1_ANT1}    ${PA_PORT[0]}
    run keyword and ignore error    Set Suite Variable     ${5GRU1_ANT2}    ${PA_PORT[1]}
    run keyword and ignore error    Set Suite Variable     ${5GRU2_ANT1}    ${PA_PORT[2]}
    run keyword and ignore error    Set Suite Variable     ${5GRU2_ANT2}    ${PA_PORT[3]}
    run keyword and ignore error     Set Suite Variable     ${5GRU3_ANT1}    ${PA_PORT[4]}
    run keyword and ignore error     Set Suite Variable     ${5GRU3_ANT2}    ${PA_PORT[5]}
    run keyword and ignore error     Set Suite Variable     ${5GRU4_ANT1}    ${PA_PORT[6]}
    run keyword and ignore error     Set Suite Variable     ${5GRU4_ANT2}    ${PA_PORT[7]}

Suite Setup For 2037
    TestSuite.Start
#    set suite variable   ${TL_DeltaPath}         ${CFGFILE_PATH}/TLDelta.py
#    set suite variable   ${DeltaPath}            ${CFGFILE_PATH}/5GC002037/Delta_SCF.py
    set suite variable   ${initial_ENB_SCF}      ${CFGFILE_PATH}/TestLineSCFeNB.xml
#    run keyword and ignore error    Refine PA Port
    Create Log Directories
    set suite variable    ${Log_PATH_Artifactory}    /opt/ute/workspace/CIT/Master/Case_Logs
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    gNB.FormatBTSID
    gNB.SetLoggingSeverity    LoggingSeverity=debug
#    ${info}     Basic.GetStreamInfo     vstring=${AF_PATH}
#    ${StreamInfo}    convert to string    ${info}
#    ${TL_S1_base_SCF}    Run Keyword If    "${StreamInfo}"=="None"    gNB.Generate TL SCF
#    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}    TLDelta_PATH=${CFGFILE_PATH}
#    ...            TestLineSCF_cell_num=${1}   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    ...    ELSE    gNB.Generate TL SCF
#    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${info['GoldenSCF']}    TLDelta_PATH=${CFGFILE_PATH}/TLDelta_${info['StreamPrefix']}.py
#    ...            TestLineSCF_cell_num=${1}   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    gNB.GenerateTestLineSCFs
    set suite variable    ${TL_S1_base_SCF}    ${LOG_PATH}/TestLineSCF1Cell.xml
#    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}
#    run keyword and ignore error     PA.AdjustAttenuationValueByGroups
#    run keyword and ignore error    PA.Adjust RU1 Attenuation to ${0}
#    run keyword and ignore error    PA.Adjust RU2 Attenuation to ${127}
#    run keyword and ignore error    PA.Adjust RU3 Attenuation to ${127}
##    run keyword and ignore error    PA.Adjust RU4 Attenuation to ${127}

Suite Setup For 2037-A
#    Import Variables    ${CFGFILE_PATH}/5GC002037/Delta_SCF.py
#    Import Variables    ${CFGFILE_PATH}/5GC002037/Delta_SCF_ENB.py
    TestSuite.Start
    Suite Setup For 2037
#    run keyword and ignore error    ENB Commission for 2037

Teardown Suite
    TestSuite.Stop

ENB Commission for 2037
    [Arguments]
    ${ENB_SCF}     COAM_Admin.GeteNBSCFbyStream    IP=${ENB_WEBUI_IP}
    Import Variables    ${CFGFILE_PATH}/Delta_SCF_ENB.py
    gNB.ModifySCF    InputFile=${initial_ENB_SCF}    OutputFile=${LOG_PATH}/ENB_2037_A_SCF.xml
    ...               ParameterToDelete=${PARAMS_TO_DELETE_ENB_2037_A}
    ...               MOsToAdd=${ADD_MOs_ENB_2037_A}
    ...               ParamterToModify=${PARAMS_TO_MODIFY_ENB_2037_A}
    ...               ListParamterToModify=${LIST_PARAMS_TO_MODIFY_ENB_2037_A}
    ...               ListToAdd=${ADD_TO_List_ENB_2037_A}
    eNB.Commission    file_path=${LOG_PATH}/ENB_2037_A_SCF.xml    bts_host=${ENB_WEBUI_IP}

Case Setup For 2037
    TestCase.Start
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection

Case Teardown For 2037
    [Arguments]   ${connection}=COAM
    TestCase.Stop
    Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog
    Run Keyword And Ignore Error    WEBUI.Backup current SCF
    log     ${TEST STATUS}
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    gNB.CollectSnapshot
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect snapshot logs
    Run Keyword And Ignore Error    GNB.Clean pcap logs
    Run Keyword And Ignore Error    GNB.kill admin process
    Run Keyword And Ignore Error    run   command=killall firefox
    Conn.ResetCache
    TestCase.Stop

Case Teardown For 2037 IPSL
    [Arguments]   ${ipsl_alias}=ipsl
    Run Keyword And Ignore Error    connect to IPSL server
    ...    ipsl_srv_ip=${IPSL_IP}    ipsl_user=${IPSL_USERNAME}    ipsl_pw=${IPSL_PASSWORD}    ipsl_alias=ipsl
    Run Keyword And Ignore Error    Stop IPSL server process    ipsl_alias=${ipsl_alias}
    Run Keyword And Ignore Error    disconnect from IPSL server    ipsl_alias=${ipsl_alias}
    Case Teardown For 2037


WEBUI.Backup current SCF
    [Arguments]    ${filename}=${TEST NAME.replace(" ", "_")}.xml
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    coam.get_current_scf_file   local_dir_path=${LOG_PATH}   file_name=${filename}   connection=COAM   timeout=10
    COAM_Admin.Logout

GNB.kill admin process
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9

GNB.Clean pcap logs
    [Arguments]    ${alias}=${ALIAS_ASIK}
    gNB.Connect
    Conn.Execute  cmd=rm -rf /ffs/run/config/toor4nsn/*.pcap   alias=${alias}
    gNB.Disconnect

CheckX2StatusUntilReady
    [Arguments]
#    gNB.Connect
#    gNB.CheckX2StatusUntilReady    dep_1514=Yes
#    gNB.Disconnect
     COAM_WebEM.CheckX2StatusUntilReady

IPSL server preparation without replace files
    [Documentation]    start IPSL server and verify server status.
    [Arguments]    ${ipsl_config_dir}    ${ipsl_alias}=ipsl    ${ipsl_listen_port}=13868
    ...    ${ipsl_tool_dir}=${IPSL_TOOL_DIR}    ${ipsl_compiler_flags}=${IPSL_COMPILER_FLAGS}
    ...    ${ipsl_srv_ip}=${IPSL_IP}    ${ipsl_user}=${IPSL_USERNAME}    ${ipsl_pw}=${IPSL_PASSWORD}
    ...    ${wait_time_for_connection_setup}=5min

    connect to IPSL server    ipsl_srv_ip=${ipsl_srv_ip}    ipsl_user=${ipsl_user}    ipsl_pw=${ipsl_pw}    ipsl_alias=${ipsl_alias}
    Stop IPSL server process    ipsl_alias=${ipsl_alias}
    compile files and start IPSL server    ipsl_config_dir=${ipsl_config_dir}    ipsl_tool_dir=${ipsl_tool_dir}
    wait until keyword succeeds  2min    3s    Verify IPSL server process is started    ipsl_alias=${ipsl_alias}
    wait until keyword succeeds  ${wait_time_for_connection_setup}    3s
    ...    Verify IPSL server status    ipsl_alias=${ipsl_alias}    ipsl_listen_port=${ipsl_listen_port}

#    [Teardown]    disconnect from IPSL server    ipsl_alias=${ipsl_alias}

GNB Commission For 2037 Case
    [Arguments]    ${SCF}    ${ParameterToDelete}    ${ParamterToModify}    ${MOsToAdd}    ${ListToAdd}    ${InputFile}=${TL_S1_base_SCF}
#    gNB.ModifySCF    InputFile=${InputFile}    OutputFile=${LOG_PATH}/${SCF}
#    ...     ParameterToDelete=${ParameterToDelete}    ParamterToModify=${ParamterToModify}
#    ...    MOsToAdd=${MOsToAdd}    ListToAdd=${ListToAdd}
    run   command=cp ${CFGFILE_PATH}\TL1109_golden.xml ${InputFile}
    gNB.GenerateCaseSCF    InputFile=${InputFile}    OutputFile=${LOG_PATH}/${SCF}
    ...                    ResourceFolder=${CURDIR}
    ...                    ParameterToDelete=${ParameterToDelete}
    ...                    ParamterToModify=${ParamterToModify}
    ...                    MOsToAdd=${MOsToAdd}
    ...                    ListToAdd=${ListToAdd}
    gNB.CommissionWithRetry    scf_file=${LOG_PATH}/${SCF}    model=HBTE
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady


WEBUI.Get NSA Slice Info
    [Arguments]    ${distname}    ${nrPlmnDN_except}   ${ipV4Address_expect}    ${QCI_except}  ${IPv4address_filter}=Primary IPv4 address reference

    ${nrPlmnDN_result}    selenium_coam.get_parameter_value    dist_name=${distname}
    ...    filter_param=New Radio PLMN distinguished name    abbr=nrPlmnDN
    Run Keyword And Continue On Failure    Should be equal    ${nrPlmnDN_except}    ${nrPlmnDN_result}
    ${ipV4Address_result}    selenium_coam.get_parameter_value    dist_name=${distname}
    ...    filter_param=${IPv4address_filter}    abbr=ipV4AddressDN1
    Run Keyword And Continue On Failure    Should be equal    ${ipV4Address_expect}    ${ipV4Address_result}
    ${QCI_result}    selenium_coam.get_parameter_value    dist_name=${distname}
    ...    filter_param=List of operator specific QCIs    node_index=${0}    abbr=operatorSpecificQCIList
    Run Keyword And Continue On Failure    Should Be Equal    ${QCI_except}    ${QCI_result}


WEBUI.Get Vlan Info
    [Arguments]    ${VLANIF}    ${vlanId_except}    ${IPIF}

    ${vlanId_result}    selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/${VLANIF}
    ...    filter_param=VLAN ID    abbr=vlanId
    Run Keyword And Continue On Failure    Should be equal    ${vlanId_except}    ${vlanId_result}
    ${localIpAddr_result}    selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/TNLSVC-1/TNL-1/IPNO-1/${IPIF}
    ...    filter_param=Local IPv4 address    abbr=localIpAddr


WEBUI.Check NSA Slice And Vlan Info
    [Arguments]
    Run Keyword And Continue On Failure    COAM_WebEM.Login
    Run Keyword And Continue On Failure    WEBUI.Get NSA Slice Info    distname=${MRBTS_ID}/${NRBTS_ID}/NRNWSLICE_NSA-1
    ...    nrPlmnDN_except=${MRBTS_ID}/${NRBTS_ID}/NRPLMN-1
    ...    ipV4Address_expect=${MRBTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1    QCI_except=128
    ...    IPv4address_filter=${IPv4address_filter}
    Run Keyword And Continue On Failure    WEBUI.Get NSA Slice Info    distname=${MRBTS_ID}/${NRBTS_ID}/NRNWSLICE_NSA-2
    ...    nrPlmnDN_except=${MRBTS_ID}/${NRBTS_ID}/NRPLMN-1
    ...    ipV4Address_expect=${MRBTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-2    QCI_except=129
    ...    IPv4address_filter=${IPv4address_filter}
#    Run Keyword And Continue On Failure    WEBUI.Get Vlan Info    VLANIF=VLANIF-${CASE_INPUT_5GC002037['vlanId']}
#    ...    vlanId_except=${CASE_INPUT_5GC002037['vlanId']}    IPIF=IPIF-2/IPADDRESSV4-2
    Run Keyword And Continue On Failure    COAM_WebEM.Logout


WEBUI.Modify 2037 Feature Flag
    [Arguments]    ${new_value}
    Run Keyword And Continue On Failure    COAM_WebEM.Login
    Run Keyword And Continue On Failure    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}
    ...    filter_param=Activate NSA network slicing support    new_value=${new_value}    abbr=actNsaSlice
    Run Keyword And Continue On Failure    COAM_WebEM.ValidateAndActiveParameters
    ${actNsaSlice_result}    selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}
    ...    filter_param=Activate NSA network slicing support    abbr=actNsaSlice
    Run Keyword And Continue On Failure    Should be equal    ${actNsaSlice_result}    ${new_value}
    Run Keyword And Continue On Failure    COAM_WebEM.Logout
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady


WEBUI.Delete And Modify Slices
    [Arguments]
    Run Keyword And Continue On Failure    COAM_WebEM.Login
    Run Keyword And Continue On Failure    WEBUI.Modify NSA Slice   NSA_Slice=NRNWSLICE_NSA-1    new_value=${130}    except_value=130
    Run Keyword And Continue On Failure    WEBUI.Delete NSA Slice     NSA_Slice=NRNWSLICE_NSA-2
    Run Keyword And Continue On Failure    COAM_WebEM.Logout
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady

UE.UE attach
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}
    Run Keyword And Continue On Failure    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${ue_index}
    Run Keyword And Continue On Failure    power_ue.UE Detach   ue_type=${ue_type}   ue_index=${ue_index}   power_reset=true
    power_ue.UE Attach    ue_type=${ue_type}     ue_index=${ue_index}   power_reset=true
    sleep    5s
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}

UE.UE attach with DL traffic
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${iperf_port}=5410    ${apn_address}=${SA_APN}   ${ue_mode}=SA
    Run Keyword And Continue On Failure    UE.UE attach    ue_type=${ue_type}     ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=10MKbits/sec
    ...    duration=500    iperf_port=${iperf_port}    apn_address=${apn_address}    ue_mode=${ue_mode}
    sleep    15s
    power_ue.Check throughput    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=5

UE.UE attach with ULDL traffic
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${iperf_port}=5410    ${apn_address}=${SA_APN}   ${ue_mode}=SA
    Run Keyword And Continue On Failure    UE.UE attach    ue_type=${ue_type}     ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul     throughput=5MKbits/sec
    ...    duration=500    iperf_port=${iperf_port}    apn_address=${apn_address}    ue_mode=${ue_mode}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=10MKbits/sec
    ...    duration=500    iperf_port=${iperf_port}     apn_address=${apn_address}    ue_mode=${ue_mode}
    sleep    15s
    power_ue.Check throughput    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=5
    power_ue.Check throughput    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    throughput=2


UE.Detach UE with Stop traffic
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${apn_address}=${SA_APN}   ${ue_mode}=SA
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${UE_TYPE}    ue_index=${ue_index}    direction=dl
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${UE_TYPE}    ue_index=${ue_index}    direction=ul
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${UE_TYPE}     ue_index=${ue_index}    power_reset=True

WEBUI.Modify NSA Slice
    [Arguments]    ${NSA_Slice}    ${new_value}    ${except_value}    ${node_index}=${0}
    Run Keyword And Continue On Failure    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/${NSA_Slice}
    ...    filter_param=List of operator specific QCIs    new_value=${new_value}    node_index=${node_index}    abbr=operatorSpecificQCIList
    Run Keyword And Continue On Failure    COAM_WebEM.ValidateAndActiveParameters
    ${QCI_result}    selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/${NSA_Slice}
    ...    filter_param=List of operator specific QCIs    node_index=${node_index}    abbr=operatorSpecificQCIList
    Run Keyword And Continue On Failure    should be true    ${QCI_result} == ${except_value}


WEBUI.Delete NSA Slice
    [Arguments]    ${NSA_Slice}
    Run Keyword And Continue On Failure    selenium_coam.remove_object    object_name=${MRBTS_ID}/${NRBTS_ID}/${NSA_Slice}
    Run Keyword And Continue On Failure    COAM_WebEM.ValidateAndActiveParameters
    ${QCI_result}    run keyword and return status    selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/${NSA_Slice}
    ...    filter_param=List of operator specific QCIs    node_index=0    abbr=operatorSpecificQCIList
    Run Keyword And Continue On Failure    should be true    '${QCI_result}' == 'False'

Wireshark.Analyse ENDCPartialReset
    [Arguments]    ${filename}
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=${filename}    filter=x2ap
    Run Keyword And Continue On Failure    Wireshark.CheckExpression    expression=x2ap.procedureCode == 40 && x2ap.X2AP_PDU == 0
    Run Keyword And Continue On Failure    Wireshark.CheckExpression    expression=x2ap.procedureCode == 40 && x2ap.X2AP_PDU == 1

Wireshark.Analyse ENB pcap for A27
    [Arguments]    ${filename}    ${localIpAddr}
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=${filename}    filter=x2ap.id == 210
    ${S1}     Wireshark.GetElementValue    check_param=x2ap.transportLayerAddressIPv4
    ${S1_IP}    Set Variable    ${S1[0]}
    run keyword and ignore error    Set Test Variable    ${S1_IP}

    Run Keyword And Continue On Failure    COAM_WebEM.Login
    ${IPv4_IP}    selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/TNLSVC-1/TNL-1/IPNO-1/${localIpAddr}
    ...    filter_param=Local IPv4 address    abbr=localIpAddr
    run keyword and ignore error    Set Test Variable    ${IPv4_IP}
    Run Keyword And Continue On Failure    COAM_WebEM.Logout

    should be equal    ${S1_IP}    ${IPv4_IP}

Process.Check Counters of 2037 A27
    [Documentation]   M51302C2: DL>>>VlanEthIfInOctets    M51302C4:UL>>>VlanEthIfOutOctets
    [Arguments]    ${VLANIF}
    Run Keyword And Continue On Failure    COAM_WebEM.Login
    Run Keyword And Continue On Failure    COAM_WEBEM.CheckTRSConutersWithUPandLowerValue
    ...    counter_id=M51302C2    full_path=TNL-1/VLANIF/${VLANIF}/VLAN_stats/VlanEthIfInOctets    up_value=500000000    lower_value=5000000
    Run Keyword And Continue On Failure    COAM_WEBEM.CheckTRSConutersWithUPandLowerValue
    ...    counter_id=M51302C4    full_path=TNL-1/VLANIF/${VLANIF}/VLAN_stats/VlanEthIfOutOctets    up_value=500000000    lower_value=5000000
    Run Keyword And Continue On Failure    COAM_WebEM.Logout

COAM_WEBEM.CheckTRSConutersWithUPandLowerValue
    [Arguments]    ${counter_id}   ${up_value}   ${lower_value}    ${full_path}=${None}
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_transport_counters   counter_id=${counter_id}    full_path=${full_path}
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    should be true    ${values[-1]} > ${lower_value}
    should be true    ${values[-1]} < ${up_value}
