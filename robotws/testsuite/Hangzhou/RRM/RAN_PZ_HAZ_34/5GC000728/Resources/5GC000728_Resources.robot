*** Settings ***
Documentation     author: Liu Tiffany
...               contact: tiffany.liu@nokia-sbell.com
Resource          ../Resources/5GC000728_MTK_resources.robot
Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Variables         ${CFGFILE_ON_GIT}/Delta_SCF.py
#Variables         ${TLDelta_PATH_ON_GIT}TLDelta.py

*** Variables ***
${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}
#${CFGFILE_PATH}             /home/ute/TAF/cfgfile/
${CFGFILE_ON_GIT}           ${CFGFILE_PATH}5GC000728/
#${TLDelta_PATH_ON_GIT}        /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${GoldenSCF_ON_GIT}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/

${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

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

${MRBTS_ID}                  MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                  NRBTS-${tl.gnbs[0].global_bts_id}

${dist_name}                ${MRBTS_ID}/${NRBTS_ID}

${REPEAT_TIME}    ${50}
${THRESHOLD}      ${49}
${EXPECTED_PRECENT}    10

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
${ALIAS_AMF}                AMF                                                 ##
########################END of alias Define#######################################

*** Keywords ***
TC.5GC000728_A_01_SA_UE_detach_trigger_by_AMF_with_PDU_Sessions
#    [Tags]    Classicalbts    Blow6GHz   MTK   CIT_19B    CIT_TRUNK    CIT_20A    CIT_20B    CIT_21A
#    [Setup]    TestCase.Init    mcs=0
    wait until keyword succeeds    30x    1min    gNB.VerifyOnAirViaOAMUntilReady
    5GC.DeleteIMSI   imsi=${IMSI}  AMF_IP=${5GC_IP}   AMF_USERNAME=${5GC_USERNAME}
    ...        AMF_PASSWORD=${5GC_PASSWORD}  alias=${ALIAS_AMF}
    gNB.Connect
    Wireshark.StartCaptureNGLog   filename=728_Z_case1.pcap
#    power_ue.Prepare UE    ue_type=${UE_TYPE}
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}

    #power_ue.UE Attach    ue_type=${UE_TYPE}
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    sleep    10s
    ${5Grach_ed}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    sleep    30s
    power_ue.Verify attach    ue_index=${0}    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul     apn_address=mdrbnokiacom    throughput=5MKbits/sec    duration=120
    sleep    10s
    power_ue.Stop traffic    ue_type=${UE_TYPE}    apn_address=mdrbnokiacom    direction=ul
#    5GC.DeleteIMSI   imsi=${IMSI}  AMF_IP=${5GC_IP}   AMF_USERNAME=${5GC_USERNAME}
#    ...        AMF_PASSWORD=${5GC_PASSWORD}  alias=${ALIAS_AMF}
#    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=True
    gNB.Connect
    Wireshark.StopCaptureNGLog
    Wireshark.DownloadLogToUTE   filename=728_Z_case1.pcap
    Wireshark.ReadLog    filename=728_Z_case1.pcap    filter=ngap
    Wireshark.Check UE context release complete
#    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=True
#    [Teardown]    TestCase.Destory

KW.CaseInit
    TestCase.Init

KW.CaseDestroy
    TestCase.Destory

Setup My Suite
    TestSuite.Start
    Import Variables    ${CFGFILE_ON_GIT}Delta_SCF.py
    TestSuilt.Init
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["detach_request"]    default_value=${true}
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["power_reset"]        default_value=true
	${outputfile}    gNB.Generate TL SCF    
	...                  GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}   TLDelta_PATH=${CFGFILE_PATH}
	...                  TestLineSCF_cell_num=${1}    cell_type=Both
	...                  MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
	Generate 728_1cell_SA    InputFile=${outputfile}
    GNB.SwconfigReplace  file_path=${CFGFILE_ON_GIT}
    GNB.Commissioning   scf_file=728_1cell_SA.xml   file_path=${LOG_PATH}
	wait until keyword succeeds    30x    1min    gNB.VerifyOnAirViaOAMUntilReady

Generate 728_1cell_SA
	[Arguments]    ${InputFile}
	gNB.ModifySCF     InputFile=${InputFile}
    ...               OutputFile=${LOG_PATH}/728_1cell_SA.xml
    ...               ParameterToDelete=${PARAMS_TO_DELETE_728}
	...               MOsToAdd=${MOs_TO_Add_728}
    ...               ParamterToModify=${PARAMS_TO_MODIFY_728}
    ...               ListParamterToModify=${LIST_PARAMS_TO_MODIFY_728}
    ...               ListToAdd=${LIST_TO_ADD_728}	
	
Wireshark.Check NG InitialUEMessage
    Run Keyword And Continue On Failure    Wireshark.CheckExpression   expression=ngap.procedureCode == 15

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
