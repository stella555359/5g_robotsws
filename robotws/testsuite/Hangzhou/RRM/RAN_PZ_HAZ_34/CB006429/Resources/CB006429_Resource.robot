*** Settings ***
Documentation     author: Yuan Hongyan
...               contact: hongyan.1.yuan@nokia-sbell.com
...               Common KWs for feature CB006429

Library           taf.transport.ssh		WITH NAME	csn
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           ../../5GC000638/Resources/coam_close.py
Library           taf.hw.rf_attenuator    WITH NAME    PA
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/sigspark.py
Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Variables         ${CFGFILE_ON_GIT}/TLDelta.py
#Variables         ${CFGFILE_ON_GIT}/CB006429/Delta_SCF.py

*** Variables ***
${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}
#${GoldenSCF_ON_GIT}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/
#${CFGFILE_ON_GIT}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${GoldenSCF_PATH}    ${GoldenSCF_ON_GIT}/${GoldenSCF}

${TL_DeltaPath}        ${CFGFILE_PATH}/TLDelta.py
${DeltaPath}           ${CFGFILE_PATH}/CB006429/Delta_SCF.py
${initial_S1_SCF}      ${LOG_PATH}/TestLineSCF1Cell_Both.xml

${USER_LOG_DIR}    /opt/ute/Logs
${UPDATE_FILE_PATH}    /opt/ute/tmp

${UTE_IP}         ${tl.core.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.core.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.core.default_ssh_connection_details.password}

${PB_ASIK_IP}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${PB_5GRU_IP}     ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}    ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
${PB_GNB_MODEL}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.__class__.__name__}
${PB_5GRU_MODEL}     ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.__class__.__name__}

${IMSI}              ${tl.ues[0].imsi}

${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

${ASIK_LMP_IP}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}        ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}

&{NEA0}    filter_param=Null ciphering algorithm  abbr=nea0   new_value=0
&{NEA1}    filter_param=SNOW 3G-based algorithm  abbr=nea1_128   new_value=0
&{NEA2}    filter_param=AES-based algorithm  abbr=nea2_128   new_value=0
&{NEA3}    filter_param=ZUC-based algorithm  abbr=nea3_128   new_value=0
&{NIA1}    filter_param=SNOW 3G-based algorithm  abbr=nia1_128   new_value=0
&{NIA2}    filter_param=AES-based algorithm  abbr=nia2_128   new_value=0
&{NIA3}    filter_param=ZUC-based algorithm  abbr=nia3_128   new_value=0

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
${QC_UE_alias}       QC_UE
${MTK_UE_alias}       MTK_UE
${ALIAS_5GC}      5gc
########################END of alias Define#######################################
*** Keywords ***
###Cases Steps###
TC.CB006429-5G_A_08_AS Security algorithm selection in security mode command
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${0}
    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    Set Agorism Values    nea0_value=0  nea1_value=0  nea2_value=0  nea3_value=5   nia1_value=0   nia2_value=0   nia3_value=5
    Modify Ciphering and Integration value for gNB
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady
    UE Attach and DL data transfer with CPIF log captured
    Wireshark.ReadLog
    ...    filename=${TEST NAME.replace(" ", "_").replace("[1]", "").replace("[1.0]", "")}_CPIF.pcap    filter=ngap || f1ap
	Wireshark.CheckExpression    expression=nr-rrc.cipheringAlgorithm == 3 && nr-rrc.integrityProtAlgorithm == 3
    Run Keyword And Ignore error    UE.One_UE_Stop_traffic_and_Detach    ue_type=${UE_TYPE}    ue_index=${0}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}

TC.CB006429_A_09_AS security Key derivation in initial context setup
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${0}
    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    Set Agorism Values   nia1_value=0   nia2_value=0   nia3_value=5   nea0_value=0  nea1_value=0  nea2_value=0  nea3_value=5
    Modify Ciphering and Integration value for gNB
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady
    UE Attach and DL data transfer with CPIF log captured
    Wireshark.ReadLog
    ...    filename=${TEST NAME.replace(" ", "_").replace("[1]", "").replace("[1.0]", "")}_CPIF.pcap    filter=ngap || f1ap
	${SecKey}    Wireshark.GetElementValue   check_param=ngap.SecurityKey
	Should not be empty    ${SecKey}
    Run Keyword And Ignore error    UE.One_UE_Stop_traffic_and_Detach    ue_type=${UE_TYPE}    ue_index=${0}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}

TC.CB006429-5G_A_10_AS Security integrity and ciphering scheme activation between gNB and UE
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${0}
    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    Set Agorism Values   nia1_value=0   nia2_value=0   nia3_value=5   nea0_value=0  nea1_value=0  nea2_value=0  nea3_value=5
    Modify Ciphering and Integration value for gNB
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady
    spark.start log    ue_alias=UE_0
    UE Attach and DL data transfer with CPIF log captured
    spark.stop log    ue_alias=UE_0   logname=${LOG_PATH}/spark_log_CB6429_10.xml   filter=event
    spark.read_log     logname=${LOG_PATH}/spark_log_CB6429_10.xml
    ${SMC}    spark.get_expected_val     msg=NR SecurityModeCommand
    ...    expression=c1.securityModeCommand.criticalExtensions.securityModeCommand.securityConfigSMC.securityAlgorithmConfig
    ${RRC_reconf}    spark.get_expected_val     msg=NR RRCReconfiguration
    ...    expression=c1.rrcReconfiguration.criticalExtensions.rrcReconfiguration.radioBearerConfig.securityConfig.securityAlgorithmConfig
    ${res_SMC_NEA}    Fetch From Left    ${SMC[0]}    :
    ${res_SMC_NIA}    Fetch From Left    ${SMC[1]}    :
    ${res_RRCReconf_NEA}    Fetch From Left    ${RRC_reconf[0]}    :
    ${res_RRCReconf_NEI}    Fetch From Left    ${RRC_reconf[1]}    :
    Should Be Equal    ${res_SMC_NEA}    nea3
    Should Be Equal    ${res_SMC_NIA}    nia3
    Should Be Equal    ${res_RRCReconf_NEA}    nea3
    Should Be Equal    ${res_RRCReconf_NEI}    nia3
    Run Keyword And Ignore error    UE.One_UE_Stop_traffic_and_Detach    ue_type=${UE_TYPE}    ue_index=${0}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}

TC.CB006429_A_22_gNB selects the algorithms with the highest priority for NIA1 NEA1
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${0}
    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    Set Agorism Values   nia1_value=8   nia2_value=6   nia3_value=4   nea0_value=1  nea1_value=7  nea2_value=5  nea3_value=3
    Modify Ciphering and Integration value for gNB
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady
    UE Attach and DL data transfer with CPIF log captured
    Wireshark.ReadLog
    ...    filename=${TEST NAME.replace(" ", "_").replace("[1]", "").replace("[1.0]", "")}_CPIF.pcap    filter=ngap || f1ap
	Wireshark.CheckExpression    expression=nr-rrc.cipheringAlgorithm == 1 && nr-rrc.integrityProtAlgorithm == 1
    Run Keyword And Ignore error    UE.One_UE_Stop_traffic_and_Detach    ue_type=${UE_TYPE}    ue_index=${0}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}

TC.CB006429-5G_A_23_gNB selects the algorithms with the highest priority for NIA2 NEA2
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${0}
    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    Set Agorism Values   nia1_value=2   nia2_value=4   nia3_value=3   nea0_value=1  nea1_value=2  nea2_value=4  nea3_value=3
    Modify Ciphering and Integration value for gNB
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady
    UE Attach and DL data transfer with CPIF log captured
    Wireshark.ReadLog
    ...    filename=${TEST NAME.replace(" ", "_").replace("[1]", "").replace("[1.0]", "")}_CPIF.pcap    filter=ngap || f1ap
	Wireshark.CheckExpression    expression=nr-rrc.cipheringAlgorithm == 2 && nr-rrc.integrityProtAlgorithm == 2
    Run Keyword And Ignore error    UE.One_UE_Stop_traffic_and_Detach    ue_type=${UE_TYPE}    ue_index=${0}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}

TC.CB006429-5G_A_24_gNB selects the algorithms with the highest priority for NIA3 NEA3
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${0}
    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    Set Agorism Values   nia1_value=1   nia2_value=2   nia3_value=3   nea0_value=0  nea1_value=1  nea2_value=2   nea3_value=3
    Modify Ciphering and Integration value for gNB
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady
    UE Attach and DL data transfer with CPIF log captured
    Wireshark.ReadLog
    ...    filename=${TEST NAME.replace(" ", "_").replace("[1]", "").replace("[1.0]", "")}_CPIF.pcap    filter=ngap || f1ap
	Wireshark.CheckExpression    expression=nr-rrc.cipheringAlgorithm == 3 && nr-rrc.integrityProtAlgorithm == 3
    Run Keyword And Ignore error    UE.One_UE_Stop_traffic_and_Detach    ue_type=${UE_TYPE}    ue_index=${0}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}

#######Function Keywords######
KW.TestSuiteInit
    Log to Console    TestSuilt.Init
    TestSuite.Start
    Create Log Directories
    set suite variable      ${Log_PATH_Artifactory}    /opt/ute/workspace/CIT/Master/Case_Logs
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    gNB.SetLoggingSeverity    LoggingSeverity=debug
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["detach_request"]    default_value=${true}
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["power_reset"]        default_value=true
    gNB.GenerateTestLineSCFs
    set suite variable    ${TL_S1_base_SCF}    ${LOG_PATH}/TestLineSCF1Cell.xml
    gNB.GenerateCaseSCF    InputFile=${TL_S1_base_SCF}    OutputFile=${LOG_PATH}/CB6429_SCF.xml
    ...                    ResourceFolder=${CURDIR}
    ...                    ParamterToModify=PARAMS_TO_MODIFY_CB6429
    gNB.CommissionWithRetry   scf_file=${LOG_PATH}/CB6429_SCF.xml  model=HBTE   # to be uncommented after tl delta works.
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady



KW.TestSuiteDestroy
    [Arguments]    ${recover_scf}=no
    Log to Console    TestSuilt.Destroy
    run keyword if    '${recover_scf}'=='yes'    gNB.Commission  scf_file=${TL_S1_base_SCF}
    TestSuite.Stop

KW.CaseInit
    Log to Console    KW.CaseInit
    TestCase.Start
    Run Keyword And Ignore Error    BtsLog.StartBTSlogCollection

KW.CaseDestroy
    Log to Console    KW.CaseDestroy
    Run Keyword And Ignore error    UE.One_UE_Stop_traffic_and_Detach
    ...    ue_type=${UE_TYPE}    ue_index=${0}    ue_mode=SA
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Run Keyword And Ignore Error     Wireshark.StopCapturingALLlog     # to be combined with the following two
    Run Keyword And Ignore Error     ssh.execute   command=killall -2 tcpdump   connection=${ALIAS_ASIK}
    Run Keyword And Ignore Error     BtsLog.StopBTSlogCollectionandGetlog
    Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    Run Keyword And Ignore error     selenium_coam.disable_virtual_display
    Run Keyword And Ignore error     Kill Xvfb in UTE
    Run Keyword And Ignore error     force_close_coam_webdriver
    Run Keyword And Ignore error     run    command=killall firefox
    Run Keyword And Ignore error     run    command=killall geckodriver
    Conn.ResetCache
    TestCase.Stop

Modify Ciphering and Integration value for gNB
    [Arguments]  ${dist_name}=${MRBTS_ID}/${NRBTS_ID}   ${change_list}=@{ALG_CHANGE_LIST}
    COAM_WebEM.Login
    FOR    ${item}    IN    @{change_list}
        selenium_coam.set_parameter_value    dist_name=${dist_name}  filter_param=${item}[filter_param]  abbr=${item}[abbr]
    ...    new_value=${item}[new_value]
    END
    sleep    3s
    selenium_coam.validate_plan
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    5s
    COAM_WebEM.Logout

Set Agorism Values
    [Arguments]   ${nea0_value}=0   ${nea1_value}=0   ${nea2_value}=0   ${nea3_value}=0    ${nia1_value}=0  ${nia2_value}=0  ${nia3_value}=0
    Set To Dictionary    ${NEA0}    new_value=${nea0_value}
    Set To Dictionary    ${NEA1}    new_value=${nea1_value}
    Set To Dictionary    ${NEA2}    new_value=${nea2_value}
    Set To Dictionary    ${NEA3}    new_value=${nea3_value}
    Set To Dictionary    ${NIA1}    new_value=${nia1_value}
    Set To Dictionary    ${NIA2}    new_value=${nia2_value}
    Set To Dictionary    ${NIA3}    new_value=${nia3_value}
    ${change_list}=    create list    ${NEA0}   ${NEA1}   ${NEA2}   ${NEA3}   ${NIA1}   ${NIA2}   ${NIA3}
    Set Suite Variable    ${ALG_CHANGE_LIST}     ${change_list}
    Log    ${ALG_CHANGE_LIST}

UE Attach and DL data transfer with CPIF log captured
    [Documentation]
    [Arguments]    ${ue_index}=${0}   ${duration}=600    ${imsi}=${IMSI}
    [Timeout]      15min
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Wireshark.StartCaptureLogFromContainer  nodename=CPIF
    ...    filename=${TEST NAME.replace(" ", "_").replace("[1]", "").replace("[1.0]", "")}_CPIF.pcap
    UE.One_UE_Call_with_traffic    ue_index=${ue_index}    Traffic_hold=True    imsi=${imsi}
    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    Wireshark.StopCapturinglogFromContainer   nodename=CPIF
    wireshark.DownloadLogToUTEFromContainer
    ...    filename=${TEST NAME.replace(" ", "_").replace("[1]", "").replace("[1.0]", "")}_CPIF.pcap    nodename=CPIF
    csn.execute   command=rm ~/*.pcap  connection=${ALIAS_ASIK}

Wireshark.StopCapturingALLlog
    ssh.send command   command=ps -ef|grep tcpdump|grep -v grep|grep fp0|awk '{print $2}'|xargs kill -2   connection=${ALIAS_ASIK}
#    ${pid}  ssh.execute   command=lxc-attach -n 0xe004 -- ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'  connection=${ALIAS_ASIK}
#    ssh.execute   command=lxc-attach -n 0xe004 -- kill -2 ${pid.replace('\r\n','')}   connection=${ALIAS_ASIK}

Kill Xvfb in UTE
    ${Xvfb_Cnt}  run  command=ps -ef | grep -i Xvfb |grep -v grep|awk '{print$2}'|awk 'END{print NR}'
    FOR    ${i}    IN RANGE    ${Xvfb_Cnt}
        ${PID1}  run  command=ps -ef|grep -i Xvfb|awk '{{print $2}}'|head -n 1
        Log  message=Killing ${i+1}st Xvfb process with PID ${PID1}.
        run  command=/bin/kill -9 ${PID1.strip()}
    END
    run  command=ps -ef | grep -i Xvfb |grep -v grep
