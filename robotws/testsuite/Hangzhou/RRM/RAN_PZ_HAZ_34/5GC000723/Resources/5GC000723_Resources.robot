*** Settings ***
Documentation     author: Liu Tiffany Zhang Haijun
...               contact: tiffany.liu@nokia-sbell.com haijun.zhang@nokia-sbell.com
Resource          ../../5GC000728/Resources/5GC000728_MTK_resources.robot
Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Library           ../../../../../resources/python_libs/Attenuation.py
Library    taf.hw.rf_attenuator    WITH NAME    atten
#Library           Attenuation.Attenuation    WITH NAME    atten
Library           taf.hw.rf_attenuator    WITH NAME    PA
Library           taf.sw.dcap.rd                        WITH NAME    rd
#Variables         ${CFGFILE_ON_GIT}Delta_SCF.py
#Variables         ${TLDelta_PATH_ON_GIT}TLDelta.py

*** Variables ***
${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}
#${CFGFILE_PATH}             /home/ute/TAF/cfgfile
${SHERPA_LOG_PATH}         /home/ute/sherpa_log/
#${CFGFILE_ON_GIT}           ${CFGFILE_PATH}5GC000723/
#${TLDelta_PATH_ON_GIT}        /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${GoldenSCF_ON_GIT}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/
${MRBTS_ID}   				MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                  NRBTS-${tl.gnbs[0].global_bts_id}
${dist_name}                 ${MRBTS_ID}/${NRBTS_ID}
${IMSI}                     ${tl.ues[0].imsi}

${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

${MTK_CtrlPC_IP}            ${tl.ues[0].ssh_connection_details.addr}
${MTK_CtrlPC_USERNAME}      ${tl.ues[0].ssh_connection_details.username}
${MTK_CtrlPC_PASSWORD}      ${tl.ues[0].ssh_connection_details.password}

#${MTK_CtrlPC_IP}           ${tl.ues[1].ssh_connection_details.addr}
#${MTK_CtrlPC_USERNAME}     ${tl.ues[1].ssh_connection_details.username}
#${MTK_CtrlPC_PASSWORD}     ${tl.ues[1].ssh_connection_details.password}


${ASIK_LMP_IP}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

${PA_INFO}                  ${tl.attenuator}

${Sherpa_decode}    /opt/Nokia/Sherpa_5G_18/Sherpa.run -o /home/ute/sherpa_log/ -d 2000 -p Sherpa /home/ute/sherpa_log/
##################define these variable for convenient############################
${ALIAS_ASIK}     asik
${ALIAS_ASIK_SLAVE}    asik_slave
${ALIAS_UTE}      ute
${ALIAS_ENBCTLPC}    ENB_PC
${ALIAS_SHP}      SHP
${ALIAS_E500}     E500
${ALIAS_PRISMA}    Prisma
${ALIAS_REAL_EPC_SERVER}    Real_EPC
${ALIAS_LONER}    LONER
${ALIAS_ASP_1A}    ASP_1A
${AlIAS_QC}       Qualcomm
${UE_alias}       UE_0
${ALIAS_5GC}      5gc
${dcap_alias}               dcap
########################END of alias Define#######################################

*** Keywords ***
TC.5GC000723 ATB of msg5 in SA call
#    Generate 723_ATB_1cell_SA    InputFile=${LOG_PATH}/TestLineSCF1Cell_Both.xml
    Generate 723_ATB_1cell_SA    ${Original_CFGFILE_1Cell}
    gNB.Commission   scf_file=${LOG_PATH}/723_ATB_1cell_SA.xml
    wait until keyword succeeds    30x    1min    gNB.VerifyOnAirViaOAMUntilReady      oam_type=coam
    PA.setup_attenuator    attenuator=${PA_INFO}
    PA.AdjustTheAttenuationValue    ports=${PA_PORTS_FOR_ATB[0]}    value=${CASE_INPUT_5GC000723['PA_VALUE_FOR_DECREASE_RSRP']}
    ...    attenuator=${PA_INFO}
    PA.AdjustTheAttenuationValue    ports=${PA_PORTS_FOR_ATB[1]}    value=${CASE_INPUT_5GC000723['PA_VALUE_FOR_DECREASE_RSRP']}
    ...    attenuator=${PA_INFO}
    sleep    30
    Stream Case Steps   stream=sherpa   level=l2_ps   exec_type=PDCP
    Decode_Sherpa_log

TestCase.CommonStop_for_ATB_of_msg5
    [Documentation]    1.stop with stop log
    ...                2.kill processes
    PA.AdjustTheAttenuationValue    ports=${PA_PORTS_FOR_ATB[0]}    value=${CASE_INPUT_5GC000723['PA_VALUE_FOR_DEFAULT']}
    ...    attenuator=${PA_INFO}
    PA.AdjustTheAttenuationValue    ports=${PA_PORTS_FOR_ATB[1]}    value=${CASE_INPUT_5GC000723['PA_VALUE_FOR_DEFAULT']}
    ...    attenuator=${PA_INFO}
    gNB.Connect
    Run Keyword And Ignore Error     ssh.execute   command=killall -2 tcpdump   connection=${ALIAS_ASIK}
    Run Keyword And Ignore Error     ssh.execute   command=killall -2 tcpdump   connection=${ALIAS_ASIK_SLAVE}
    Run Keyword And Ignore Error     run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error     BtsLog.StopBTSlogCollectionandGetlog
    Run Keyword And Ignore error     selenium_coam.disable_virtual_display
    Run Keyword And Ignore error     run    command=killall firefox
    Run Keyword And Ignore error     run    command=killall geckodriver
    Conn.ResetCache
    TestCase.Stop

TestSuite.CommonSuiteStart_for_723_ATB
    [Documentation]    1.set log level
    ...                2.generate TL scf
    TestSuite.Start
#    Import Variables    ${CFGFILE_ON_GIT}Delta_SCF.py
    Create Log Directories
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    gNB.SetLoggingSeverity    LoggingSeverity=debug
    gNB.FormatBTSID    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
	set suite variable    ${DIST_NAME}   ${MRBTS_ID}/${NRBTS_ID}
#    gNB.Generate TL SCF    GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${Golden_SCF}    TLDelta_PATH=${TLDelta_PATH}
#    ...            TestLineSCF_cell_num=1   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    ${info}     Basic.GetStreamInfo     vstring=${AF_PATH}
#    ${StreamInfo}    convert to string    ${info}
#    ${outputfile_1cell}    Run Keyword If    "${StreamInfo}"=="None"    gNB.Generate TL SCF
#    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}    TLDelta_PATH=${CFGFILE_PATH}
#    ...            TestLineSCF_cell_num=${1}   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    ...    ELSE    gNB.Generate TL SCF
#    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${info['GoldenSCF']}    TLDelta_PATH=${CFGFILE_PATH}/TLDelta_${info['StreamPrefix']}.py
#    ...            TestLineSCF_cell_num=${1}   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    gNB.GenerateTestLineSCFs
    set suite variable    ${Original_CFGFILE_1Cell}    ${LOG_PATH}/TestLineSCF1Cell.xml

Generate 723_ATB_1cell_SA
	[Arguments]    ${InputFile}
	gNB.GenerateCaseSCF    InputFile=${InputFile}    OutputFile=${LOG_PATH}/723_ATB_1cell_SA.xml
    ...                    ResourceFolder=${CURDIR}
    ...                    ParamterToModify=PARAMS_TO_MODIFY_FOR_723_ATB
#	gNB.ModifySCF     InputFile=${InputFile}
#    ...               OutputFile=${LOG_PATH}/723_ATB_1cell_SA.xml
#    ...               ParamterToModify=${PARAMS_TO_MODIFY_FOR_723_ATB}
	[Return]     ${LOG_PATH}/723_ATB_1cell_SA.xml


Stream Case Steps
    [Arguments]   ${stream}   ${level}   ${exec_type}=${EMPTY}
    ...    ${ip_mode}=ipv4   ${host}=${ASIK_IP}       ${L3CALL}=${True}
    run    command=cd ${SHERPA_LOG_PATH} ; rm -f ${ASIK_IP}*
    COAM_WebEM.Login
#    run keyword and ignore error   Copy Luashark to Local
#    run keyword and ignore error    Stop Stream Trace sherpa L2-ps
    Sleep   15s
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    power_ue.UE Attach     ue_type=${UE_TYPE}     power_reset=True
    power_ue.UE Detach     ue_type=${ue_type}       power_reset=Flase
#    Start UDP Server Collecting   dcap_ip=${dcap_ip}    dcap_username=${dcap_username}    dcap_password=${dcap_password}
#    Start Stream Trace sherpa L2-ps
#    ...   level=${level}   exec_type=${exec_type}   stream=${stream}   ip_mode=${ip_mode}   host=${host}
    Run Keyword And Continue On Failure    KW.Start_Collect_Sherpa_Trace
    power_ue.UE Attach     ue_type=${ue_type}       power_reset=Flase
    sleep    5
#    spark.create_pdu_session    ue_alias=UE_0     id=1    apn=${SA_APN}    verify=True
#    sleep    5
    [Teardown]    Stream Case Teardown    stream=${stream}    level=${level}    exec_type=${exec_type}    host=${host}

KW.Start_Collect_Sherpa_Trace
    Log to console   Start collect sherpa log
    @{trace_type}    create list   L2Ps_Sherpa
    &{bts_info}   Create Dictionary    host=${WEBUI_IP}    username=${WEBUI_USERNAME}
    ...                                password=${WEBUI_PASSWORD}    port=443
    rd.connect_to    host=${CASE_INPUT_5GC000723['dcap_server_ip']}
    ...              port=${CASE_INPUT_5GC000723['dcap_server_port']}
    ...              secure=True
#    rd.get_all_bts_info
    DCAP.Delete_Bts_if_Exist
    rd.create_bts    host=${WEBUI_IP}
    rd.start_trace    bts=&{bts_info}    gnb_custom_profile=${trace_type}
    sleep    20s

KW.Stop_Collect_Sherpa_Trace
    Log to console   Stop collect sherpa log
    rd.stop_trace
    sleep    2min
    ${trace_logpath}    rd.get_results
    run    command=cd ${LOG_PATH}&&rm -rf sherpa_log&&mkdir sherpa_log
    run    command=cp ${trace_logpath} ${LOG_PATH}/sherpa_log
    run    command=rm -f ${trace_logpath}
    rd.delete_trace
    rd.delete_bts

Stream Case Teardown
    [Arguments]   ${stream}   ${level}   ${exec_type}=${EMPTY}   ${host}=${ASIK_IP}
#    COAM_WebEM.Login
#    Wait Until Keyword Succeeds   1min    5s      Stop Stream Trace sherpa L2-ps
    Run Keyword And Continue On Failure    KW.Stop_Collect_Sherpa_Trace
#    COAM_Admin.Logout
    Run Keyword And Continue On Failure     power_ue.UE Detach      ue_type=${UE_TYPE}     power_reset=True
    Run Keyword and Ignore Error   COAM_WebEM.Logout
#    Check Trace File Recieved   file_folder=${file_location}   host=${host}
#    Get Streaming Files Current gNB   file_folder=${file_location}   source_ip=${host}


Decode_Sherpa_log
    [Arguments]
    Log to console   Start decode file
    ${sherpa_log_dir}  set variable    ${LOG_PATH}/sherpa_log/
    run    command=cd ${sherpa_log_dir}&&rm -rf unziplog&&mkdir unziplog&&unzip *.zip -d unziplog
    ${unzip_sherpa_file}    run    command=cd ${sherpa_log_dir}/unziplog;find . -name "*.pcap"
    ${files}    Split String    ${unzip_sherpa_file}    separator=\n
    FOR    ${file}    IN    @{files}
        # run    command=mkdir ${sherpa_log_dir}/sherpa_decode
        ${filepath}   ${filename}   Split String From Right    string=${file}   separator=/     max_split=1
        #run    command=cp ${file} ${sherpa_log_dir}/${filename}.pcap
        run   command=mkdir ${sherpa_log_dir}/unziplog/${filename}
        run   command=/opt/Nokia/Sherpa_5G_18/Sherpa.run -o ${sherpa_log_dir}/unziplog/${filename} -d 0 -p Sherpa ${sherpa_log_dir}/unziplog/${file}
        ${var}    run    command=cd ${sherpa_log_dir}/unziplog/${filename}; cat Sherpa_l1l2Trace.csv | grep "Dl PdcchSendReq" |grep "UL grant 0-1"
        ${res}   run keyword and return status    Should Be Empty    ${var}
        run keyword if     '${res}'=='True'     Continue For Loop
        @{lines_list}=    Split to lines    ${var}
        ${line}    Fetch From Right    string=${lines_list}[0]    marker=nbPrb=
        @{value_of_nbPrb}    Split String    string=${line}    separator=,    max_split=1
        ${status}    run keyword and return status     Should be true       0< ${value_of_nbPrb}[0] < 16
        return from keyword if    "${status}" == "True"
    END
    Fail    Sherpa decode error, no result found


Copy Luashark to Local
    ssh.Connect to   hostname=${sherpa_server_ip}    username=${sherpa_server_username}    password=${sherpa_server_password}
    ...    alias=sherpa_vm
    ssh.execute    command=cd /cygdrive/c/Users/nokia5g/AppData/Roaming/NOKIA/Sherpa5G_18/;cp -r interfaces_lua /home/nokia5G/
    ...    connection=sherpa_vm
    ssh.execute    command=cd /home/nokia5G/interfaces_lua;tar -cvf luashark.tar *     connection=sherpa_vm
    ssh.Download File   remote_path=/home/nokia5G/interfaces_lua/luashark.tar   local_path=/home/ute/luashark.tar   connection=sherpa_vm
    run    cd /home/ute;sudo rm -rf interfaces_lua;mkdir interfaces_lua;tar xf /home/ute/luashark.tar -C /home/ute/interfaces_lua
    [Teardown]    ssh.Disconnect    connection=sherpa_vm


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


Configure Logging Agent
    [Arguments]   ${uplane_destination}   ${dscp}    ${source_ip}=${ASIK_IP}
    Run Keyword and Ignore Error   selenium_coam.deactivate_internal_trace
    selenium_coam.configure_logging_agent    source_ip=${source_ip}   vlan=${EMPTY}   dscp=${dscp}
    ...   cplane_destination=${EMPTY}   uplane_destination=${uplane_destination}
    Run Keyword and Ignore Error   selenium_coam.activate_internal_trace
    Log To Console   Logging Agent: ${source_ip}, DSCP: ${dscp}, Service: ${uplane_destination}


Start UDP Server Collecting
    [Arguments]   ${dcap_ip}    ${dcap_username}    ${dcap_password}   ${alias}=${dcap_alias}
    ssh.Connect to   hostname=${dcap_ip}    username=${dcap_username}    password=${dcap_password}    alias=${alias}
#    ssh.Execute    command=docker stop udptracer    connection=${alias}
    Clean Traffic Files   file_folder=${CASE_INPUT_5GC000723['file_location']}
    Sleep   5s
    ${res}   ssh.Execute    command=docker start udptracer    connection=${alias}
    Should Contain   ${res}   udptracer
    Log To Console   Start UDP Server Collecting

Check Trace File Recieved
    [Arguments]   ${file_folder}   ${host}=${ASIK_IP}   ${alias}=${dcap_alias}
    sleep   5s
    ${file_name}    ssh.Execute   command=cd ${file_folder}; ls   connection=${dcap_alias}
    should contain    container=${file_name}   item=${host}   msg=No Trace File Found for ${host}

Get Streaming Files Current gNB
    [Arguments]   ${file_folder}   ${source_ip}=${ASIK_IP}   ${alias}=${dcap_alias}
    ${files}    ssh.Execute   command=cd ${CASE_INPUT_5GC000723['file_location']};ls ${source_ip}*   connection=${dcap_alias}
    ${file_list}   Set Variable   ${files.split()}
    FOR   ${file}   IN   @{file_list}
        ${size_value}    ssh.Execute   command=cd ${CASE_INPUT_5GC000723['file_location']};du -sh ${file}  connection=${dcap_alias}
        ${size_value}    Fetch From Left    ${size_value}    \t
        run keyword if  '${size_value}'=='0'    run keywords    Remove Values From List    ${file_list}    ${file}
        ...    AND    exit for loop
    END
    FOR   ${file}   IN   @{file_list}
        ${local_pcap_path}   Join Path   ${SHERPA_LOG_PATH}   ${file}
        ${dcap_file}   Join Path   ${CASE_INPUT_5GC000723['file_location']}   ${file}
        ssh.Download File   remote_path=${dcap_file}   local_path=${local_pcap_path}   connection=${dcap_alias}
    END
     [Teardown]   ssh.Disconnect     connection=${dcap_alias}

Get and Upload Files Needs Decode
    [Arguments]   ${ip}=${ASIK_IP}   ${src}=${SHERPA_LOG_PATH}
    ${file_list}   OperatingSystem.List Files In Directory   ${src}   ${ip}*.pcap
    [Return]   ${file_list}


Start Streaming WebEM
    [Arguments]   ${level}   ${exec_type}   ${stream}=sherpa   ${cells_list}=${EMPTY}   ${ip_mode}=ipv4   ${host}=${ASIK_IP}
#    ui_operation.Verify Input Start Trace   level=${level}   exec_type=${exec_type}
    ${gnb_release}   Get gnb release
    ${input}   Run Keyword If   '${gnb_release}'=='5G20A' and '${exec_type}' == 'PDCP'   Create Dictionary
    ...   ELSE IF   '${gnb_release}'=='5G20A' and '${exec_type}' == 'pdcp'   Create Dictionary
    ...   ELSE IF   '${gnb_release}'=='TRUNK' and '${exec_type}' == 'PDCP'   Create Dictionary
    ...   ELSE IF   '${gnb_release}'=='TRUNK' and '${exec_type}' == 'pdcp'   Create Dictionary
    ...   ELSE IF   '${gnb_release}'=='5G19B' and '${exec_type}'=='PDCP'   Create Dictionary
    ...   ELSE IF   '${gnb_release}'=='5G19B' and '${exec_type}'=='pdcp'   Create Dictionary
    ...   ELSE IF   '${gnb_release}'=='5G19B' and '${exec_type}'=='RLC'   Create Dictionary
    ...   ELSE IF   '${gnb_release}'=='5G19B' and '${exec_type}'=='rlc'   Create Dictionary
    ...   ELSE IF   '${gnb_release}'=='5G20B' and '${exec_type}'=='PDCP'   Create Dictionary
    ...   ELSE IF   '${gnb_release}'=='5G20B' and '${exec_type}'=='pdcp'   Create Dictionary
    ...   ELSE   Create Dictionary   cells_list=${cells_list}
    ${status}   Run Keyword and Ignore Error
    ...   selenium_coam.start_${level}_${stream}_trace_and_return_result   &{input}
    Should Be Equal   ${status[0]}   PASS
    Should Contain   ${status[1]}   ucce
    [Return]   ${status[1]}

Clean Traffic Files
    [Arguments]   ${file_folder}   ${source_ip}=${ASIK_IP}   ${alias}=${dcap_alias}
    ${search_regex}   Join Path   ${CASE_INPUT_5GC000723['file_location']}   ${source_ip}
    ssh.Execute   command=sudo rm -f ${search_regex}*   connection=${alias}
    sleep   5s
    ${file_clear}   ssh.Execute   command=ls ${search_regex}*   connection=${alias}
    ${cp1}   Run Keyword and Return Status   should be empty    ${file_clear}
    ${cp2}   Run Keyword and Return Status   should contain    ${file_clear}   No such file or directory
    Should Be True   ${cp1} or ${cp2}

Get gnb release
    [Documentation]   Get gnb release version from TargetBD file
    ssh.Connect To   hostname=${ASIK_IP}    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}    alias=release_info
    ${info}   ssh.Execute    ls /ffs/run/TargetBD*xml   connection=release_info
    ${main_branch}   Set Variable   ${info.split('_')[3]}
    ${release_info}   Run Keyword If   '${main_branch}'=='0000'   Set Variable   TRUNK
    ...   ELSE   set variable    ${info.split('_')[1]}
    [Return]    ${release_info}
    [Teardown]   ssh.Disconnect   connection=release_info

TC.5GC000723_A_07_SRB0_SRB1_Counters_check
#    [Tags]    Classicalbts    Blow6GHz   MTK   CIT_19B    CIT_TRUNK    CIT_20A    CIT_20B    CIT_21A
#    [Setup]    TestCase.Init    mcs=0
    #Power.ResetgNB
    #wait until keyword succeeds    30x    1min    gNB.VerifyOnAirViaOAMUntilReady
    5GC.DeleteIMSI   imsi=${IMSI}  AMF_IP=${5GC_IP}   AMF_USERNAME=${5GC_USERNAME}
    ...        AMF_PASSWORD=${5GC_PASSWORD}  alias=${ALIAS_AMF}
#    power_ue.Prepare UE    ue_type=${UE_TYPE}
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    gNB.connect
    Wireshark.StartCaptureNGLog   filename=NG_723_Z_case7.pcap
    #Run Keyword And Continue On Failure    power_ue.UE Attach    ue_type=${UE_TYPE}
#    Run Keyword And Ignore Error        spark.power_off    ue_alias=${UE_alias}
#    sleep    10s
#    Run Keyword And Ignore Error        spark.power_on     ue_alias=${UE_alias}
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    sleep    10s
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${UE_TYPE}   ue_alias=${UE_alias}   power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    sleep    30s
    power_ue.Verify attach    ue_index=${0}    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    sleep   10s
    gNB.connect
    Wireshark.StopCaptureNGLog
    Wireshark.DownloadLogToUTE   filename=NG_723_Z_case7.pcap
    Wireshark.ReadLog    filename=NG_723_Z_case7.pcap    filter=ngap.procedureCode == 15
    Wireshark.Check NG InitialUEMessage
    Wait Until Keyword Succeeds    15min    1min    Check SRB0_SRB1_Counters
#    [Teardown]    TestCase.Destory

TC.5GC000723_G_01_RACH_Successful_with_aligned_rrcconnectionsetup_2x2
#    [Tags]    Classicalbts    Blow6GHz   MTK    CRT_19B    CRT_TRUNK    CRT_20A    CRT_20B
#    [Setup]    TestCase.Init    mcs=0
    wait until keyword succeeds    30x    1min    gNB.VerifyOnAirViaOAMUntilReady
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${UE_TYPE}   ue_alias=${UE_alias}   power_reset=True
    power_ue.Verify attach    ue_index=${0}    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
#   [Teardown]  TestCase.Destory

Setup Suite
    Setup Suite For 2056
    set suite variable  ${scf_commission}    False
    #gNB.ReplaceSwconfig    Path=${CFGFILE_ON_GIT}
    gNB.SetLoggingSeverity    LoggingSeverity=trace


Teardown Suite
    Teardown Suite For 2056
    gNB.SetLoggingSeverity    LoggingSeverity=info
    Run Keyword And Ignore Error    run    cat ${TP_FILE}

Setup Suite For 2056
    Run Keyword And Ignore Error    TestSuite.Start
    Run Keyword And Ignore Error    Create Log Directories
    gNB.FormatBTSID
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["detach_request"]    default_value=${true}
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["power_reset"]        default_value=true
	Run Keyword And Ignore Error    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${0}
	...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
#    Run Keyword And Ignore Error    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${1}
#    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
#    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    gNB.SetLoggingSeverity    LoggingSeverity=debug
    gNB.GenerateTestLineSCFs
#    ${info}     Basic.GetStreamInfo     vstring=${AF_PATH}
#    ${StreamInfo}    convert to string    ${info}
#    ${outputfile_1cell}    Run Keyword If    "${StreamInfo}"=="None"    gNB.Generate TL SCF
#    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}    TLDelta_PATH=${CFGFILE_PATH}
#    ...            TestLineSCF_cell_num=${2}   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    ...    ELSE    gNB.Generate TL SCF
#    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${info['GoldenSCF']}    TLDelta_PATH=${CFGFILE_PATH}/TLDelta_${info['StreamPrefix']}.py
#    ...            TestLineSCF_cell_num=${2}   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    set suite variable    ${Original_CFGFILE_1Cell}    ${LOG_PATH}/TestLineSCF1Cell.xml

    Run Keyword And Ignore Error    PA_Adjust Attenuation Ports To Same Value
    ...    ports=${PA_PORTS}    value=${120}    attenuator=${PA_INFO}
    Run Keyword And Ignore Error    PA.AdjustTheAttenuationValue
    ...    ports=${PA_PORTS[0]}    value=${0}    attenuator=${PA_INFO}
    Run Keyword And Ignore Error    PA.AdjustTheAttenuationValue
    ...    ports=${PA_PORTS[1]}    value=${0}    attenuator=${PA_INFO}
    Run Keyword And Ignore error   run   command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error   run   command=killall Xvfb
    Run Keyword And Ignore error   run   command=killall geckodriver

Teardown Suite For 2056
    Run Keyword And Ignore Error    TestSuite.Stop

Setup case
    [Arguments]    ${mcs}=0
    Setup Case For 2056
    log to console    CASE STARTING
    BtsLog.StartBTSlogCollection
    SCF has commissioned or not
    wait until keyword succeeds    8x    2min    gNB.VerifyOnAirViaOAMUntilReady
    Run keyword If    ${mcs}==0    SetTestVariables    mcs=0    ul=6M    dl=22M
    Run keyword If    ${mcs}==16   SetTestVariables    mcs=16    ul=64M    dl=248M
    Run keyword If    ${mcs}==20    SetTestVariables    mcs=20    ul=83M    dl=323M
    Run keyword If    ${mcs}==21    SetTestVariables    mcs=21    ul=91M    dl=352M
    Run keyword If    ${mcs}==26    SetTestVariables    mcs=26    ul=129M    dl=495M
    Run keyword If    ${mcs}==27    SetTestVariables    mcs=27    ul=134M    dl=516M
    Run keyword If    ${mcs}==28    SetTestVariables    mcs=28    ul=140M    dl=536M

#Teardown case
#    [Arguments]
#    Teardown Case For 2056
#    log to console    CASE DONE

Setup Case For 2056
    Run Keyword And Ignore Error    TestCase.Start
#    Import Variables    ${CFGFILE_PATH}5GC000723/Delta_SCF.py

Teardown Case For 2056
    COAM_WebEM.Login
    Run Keyword And Ignore error    Stop UE Traffic   ue_index=${0}
    Run Keyword And Ignore error    Stop UE Traffic   ue_index=${1}
    Run Keyword And Ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${0}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    #Run Keyword And Ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${1}
    Run Keyword And Ignore Error
    ...    spark.Stop Log     logname=${LOG_PATH}/${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_UE0.xml
    ...                       ue_alias=UE_0
    Run Keyword And Ignore Error
    ...    spark.Stop Log     logname=${LOG_PATH}/${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_UE1.xml
    ...                       ue_alias=UE_1

    Run Keyword And Ignore Error    Unlock Cell   cell_idx=1
    Run Keyword And Ignore Error    Unlock Cell   cell_idx=2
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog
    #gNB.Connect
    Run Keyword And Ignore Error    kill GNB wireshark process
    log     ${TEST STATUS}
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    Collect logs For 2056
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect logs
    Run Keyword And Ignore Error    kill admin process
    Run Keyword And Ignore Error    run   command=killall firefox
    Conn.ResetCache
    log to console    CASE DONE
    Run Keyword And Ignore Error    TestCase.Stop

Stop UE Traffic
    [Arguments]   ${ue_index}=${0}
    ${apn_address}     Set variable if  ${ue_index}==${0}    ${SA_APN}    ${NSA_APN}
    ${ue_mode}    Set variable if  ${ue_index}==${0}    SA    NSA
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl    ue_index=${ue_index}
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul    ue_index=${ue_index}
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}

Unlock Cell
    [Arguments]   ${cell_idx}=1    ${timeout}=300
    ${cell_info}=    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="Locked"    run keywords
    ...    selenium_coam.unlock_cell    cell_idx=${cell_idx}   timeout=${timeout}
    ...    AND    Sleep  5s
    ${cell_info}=    selenium_coam.get_cell_info   cell_idx=${cell_idx}
    should be true    '${cell_info['Status']['Administrative state']}'=="Unlocked"

Collect logs For 2056
    #${gNB_logName}=    catenate    SEPARATOR=_    ${TEST NAME.replace(" ", "_")}   gNB.log
    #Run Keyword And Ignore Error    gnb.collectlog    logName=${gNB_logName}
    #Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    #Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    gNB.CollectSnapshot

#kill admin process
#    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9

SCF has commissioned or not
    return from keyword if  '${scf_commission}' == 'True'
    gNB.GenerateCaseSCF    InputFile=${Original_CFGFILE_1Cell}    OutputFile=${LOG_PATH}/723.xml
    ...                    ResourceFolder=${CURDIR}
    ...                    ParameterToDelete=PARAMS_TO_DELETE_723
	...                    ParamterToModify=PARAMS_TO_MODIFY_723
	...                    MOsToAdd=MOs_TO_ADD_723
	...                    ListParamterToModify=LIST_PARAMS_TO_MODIFY_723
    ...                    ListToAdd=List_TO_ADD_723
#    gNB.ModifySCF     InputFile=${Original_CFGFILE_1Cell}
#    ...               OutputFile=${LOG_PATH}/723.xml
#    ...               ParameterToDelete=${PARAMS_TO_DELETE_723}
#    ...               ParamterToModify=${PARAMS_TO_MODIFY_723}
#    ...               MOsToAdd=${MOs_TO_ADD_723}
#    ...               ListParamterToModify=${LIST_PARAMS_TO_MODIFY_723}
#    ...               ListToAdd=${List_TO_ADD_723}
    gNB.Commission   scf_file=${LOG_PATH}/723.xml
    set suite variable  ${scf_commission}    True

PA_Adjust Attenuation Ports To Same Value
    [Arguments]    ${ports}    ${value}    ${attenuator}=${PA_INFO}
    PA.setup_attenuator    attenuator=${attenuator}
    ${length}    Get Length    ${ports}
    FOR    ${i}    IN RANGE    ${length}
        PA.set_attenuation    port=${ports[${i}]}    value=${value}
        PA.read_attenuation    port=${ports[${i}]}
    END

KW.CaseInit
    TestCase.Init

KW.CaseDestroy
    TestCase.Destory

Setup My Suite
    TestSuite.Start
#    Import Variables    ${CFGFILE_ON_GIT}Delta_SCF.py
    TestSuilt.Init
#	${outputfile}    gNB.Generate TL SCF
#	...                  GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}   TLDelta_PATH=${CFGFILE_PATH}
#	...                  TestLineSCF_cell_num=${1}    cell_type=Both
#	...                  MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    gNB.GenerateTestLineSCFs
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["detach_request"]    default_value=${true}
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["power_reset"]        default_value=true
	set suite variable   ${TestLineSCF_1cell_Both}    ${LOG_PATH}/TestLineSCF1Cell.xml
	Generate 723_1cell_SA    InputFile=${TestLineSCF_1cell_Both}
    #GNB.SwconfigReplace  file_path=${CFGFILE_ON_GIT}
    gNB.Commission    scf_file=${LOG_PATH}/723_1cell_SA.xml    timeout=${2400}
    #GNB.Commissioning   scf_file=723_1cell_SA.xml   file_path=${LOG_PATH}
    wait until keyword succeeds    30x    1min    gNB.VerifyOnAirViaOAMUntilReady

Generate 723_1cell_SA
	[Arguments]    ${InputFile}
	gNB.GenerateCaseSCF    InputFile=${InputFile}    OutputFile=${LOG_PATH}/723_1cell_SA.xml
    ...                    ResourceFolder=${CURDIR}
    ...                    ParameterToDelete=PARAMS_TO_DELETE_723
	...                    MOsToAdd=MOs_TO_Add_723
    ...                    ParamterToModify=PARAMS_TO_MODIFY_723
    ...                    ListParamterToModify=LIST_PARAMS_TO_MODIFY_723
#   ...               ListToAdd=${LIST_TO_ADD_723}
#	gNB.ModifySCF     InputFile=${InputFile}
#    ...               OutputFile=${LOG_PATH}/723_1cell_SA.xml
#    ...               ParameterToDelete=${PARAMS_TO_DELETE_723}
#	...               MOsToAdd=${MOs_TO_Add_723}
#    ...               ParamterToModify=${PARAMS_TO_MODIFY_723}
#    ...               ListParamterToModify=${LIST_PARAMS_TO_MODIFY_723}
#    ...               ListToAdd=${LIST_TO_ADD_723}

#Wireshark.Check NG InitialUEMessage
#    Run Keyword And Continue On Failure    Wireshark.CheckExpression   ngap.procedureCode == 15

COAM_Admin.CheckBTSConterWithTraget
    [Arguments]    ${counter_id}    ${target_value}=0
    ${date}   Get Current Date   exclude_millis=True
    ${res}  selenium_coam.get_bts_counters_info   counter_id=${counter_id}
    ${values}    get dictionary values   ${res}
    should be true    ${values[-1]}>${target_value}

Check SRB0_SRB1_Counters
    wait until keyword succeeds    3x    1min    COAM_WebEM.Login
    COAM_Admin.CheckBTSConterWithTraget     counter_id=M55309C09001
    COAM_Admin.CheckBTSConterWithTraget     counter_id=M55309C07001
    COAM_Admin.CheckBTSConterWithTraget    counter_id=M55309C03001
    COAM_Admin.CheckBTSConterWithTraget    counter_id=M55309C05001
    COAM_WebEM.Logout

Modify parameter value via webui for common
    [Arguments]    ${dist_name}    ${new_value}    ${filter_param}    ${abbr}
    COAM_WebEM.Login
    ${vlaue_before}    COAM.GetParameterValue    dist_name=${dist_name}
    ...    filter_param=${filter_param}    abbr=${abbr}
    COAM.SetParameterValue    dist_name=${dist_name}
    ...    filter_param=${filter_param}    new_value=${new_value}    abbr=${abbr}
    COAM.ValidateAndActiveParameters
    ${vlaue_after}    COAM.GetParameterValue    dist_name=${dist_name}
    ...    filter_param=${filter_param}        abbr=${abbr}
    Should be equal    ${new_value}    ${vlaue_after}
    COAM_WebEM.Logout

gNB.ASIBConnect
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
gNB.ASIBDisconnect
    Conn.Disconnect  alias=${ALIAS_ASIK}

TeardownCase
    [Arguments]   ${connection}=COAM
    Run Keyword And Ignore Error    Stop BTSlogs Collection and get logs
    Run Keyword And Ignore Error    Backup current SCF
    gNB.ASIBConnect
    Run Keyword And Ignore Error    kill GNB wireshark process
    log     ${TEST STATUS}
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    Collect logs
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect logs
    #Run Keyword And Ignore Error    Clean GNB wireshark log
    Run Keyword And Ignore Error    kill admin process
    Run Keyword And Ignore Error    run   command=killall firefox
    Conn.ResetCache
