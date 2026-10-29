*** Settings ***
Documentation
...    author: Yuan Hongyan  Zhang haijun
...    contact: hongyan.1.yuan@nokia-sbell.com haijun.zhang@nokia-sbell.com
...    squad group: SG_01
...    feature : 5GC000638-B
Library           taf.transport.ssh    WITH NAME    csn
Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Variables         ${CFGFILE_ON_GIT}/Delta_SCF.py
#Variables         ${CFGFILE_PATH}TLDelta.py
Library           ../Resources/coam_close.py


*** Variables ***
${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}

${mcc}                      ${tl.core.mcc}
${mnc}                       ${tl.core.mnc}
${UPDATE_FILE_PATH}         /opt/ute/tmp
#${CFGFILE_PATH}             /home/ute/TAF/cfgfile
${CFGFILE_ON_GIT}           ${CFGFILE_PATH}5GC000638/
#${CFGFILE_PATH}        /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${GoldenSCF_ON_GIT}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/

${Original_CFGFILE}         ${CFGFILE_ON_GIT}Configuration_scf_original.xml
${EGATE_CFG_NAME}           ${tl.core.cfg_filename}
${WTS_FILE_PATH}            ${tl.core.dir_path}

${MRBTS_ID}                  MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                  NRBTS-${tl.gnbs[0].global_bts_id}

${IMSI}                     ${tl.ues[0].imsi}
${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

${ASIK_LMP_IP}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

${RU_TYPE}                  ${tl.gnbs[0].dus[0].rus[0].radio_type}
${AEQA_IP}                  ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}    # 192.168.254.34

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

##################define these variable for convenient############################
${ALIAS_ASIK}               asik
${ALIAS_ASIK_SLAVE}         asik_slave
${ALIAS_UTE}                ute
${ALIAS_ENBCTLPC}           ENB_PC
${ALIAS_SHP}                SHP
${ALIAS_E500}               E500
${ALIAS_PRISMA}             Prisma
${ALIAS_5GC}                5gcore
${ALIAS_QC}                 qualcomm
${UE_alias}                 UE_0
########################END of alias Define#######################################


*** Keywords ***
[1][1.0] 5GC000638_B_8_AMF responds with the message NG RESET ACK to gNB after received Req
    [Documentation]  related cases:638_B_7
    [Tags]    5GC000638_B    CRT_20A
#    [Setup]  Setup case
    #Power.ResetgNB
    #Wait until keyword succeeds   20x   1min    COAM_VerifyOnAirViaFrontendAndBackend
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=True
    sleep    10s
    ${5Grach_ed}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=True
    power_ue.Verify attach    ue_index=${0}    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    #spark.create_pdu_session     ue_alias=${UE_alias}
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul     apn_address=mdrbnokiacom    throughput=5MKbits/sec    duration=120
    sleep    10s
    power_ue.Stop traffic    ue_type=${UE_TYPE}    apn_address=mdrbnokiacom    direction=ul
    gNB.Connect
    Wireshark.StartCaptureLogFromContainer    filename=GNB_NG_reset.pcap    nodename=CPIF
    #${containerid}    gNB.get_container_id    nodename=CPIF
    gNB initiates global reset
    Sleep    5min
    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    wireshark.DownloadLogToUTEFromContainer    filename=GNB_NG_reset.pcap   nodename=CPIF
    gNB.Disconnect
    Wireshark.ReadLog    filename=GNB_NG_reset.pcap    filter=ngap
    Check NG reset parameter    checkparam=ngap.NGResetAcknowledge_element   comparevalue=NGResetAcknowledge
    Wireshark.Action.Close
    COAM_Admin.Login
    COAM_Admin.ResetSite    timeout=15min
    COAM_Admin.Logout
    [Teardown]  Teardown case

TC.5GC000638_B_12_gNB responds with NG RESET ACK to the AMF after full reset procedure
    [Documentation]
    [Tags]    5GC000638_B    CIT_TRUNK    CIT_20B    CIT_21A
#    [Setup]  Setup case
    #Power.ResetgNB
    #taf.pdu.setup_pdu    host=${PB_ASIK_IP}    model=HBTE
    #taf.pdu.power_off    port=${PB_ASIK_PORT}
    #sleep    10s
    #taf.pdu.power_on    port=${PB_ASIK_PORT}
    Wait until keyword succeeds   20x   1min    COAM_VerifyOnAirViaFrontendAndBackend
    Run Keyword And Ignore Error    gNB.connect
    #Run Keyword And Ignore Error    Wireshark.StartCaptureNGLog    filename=test.pcap
#    power_ue.Prepare UE    ue_type=${UE_TYPE}
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    sleep    10s
    log to console    STEP1:UE ATTACH
    ${5Grach_ed}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    sleep    30s
    power_ue.Verify attach    ue_index=${0}    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    gNB.Connect
    Wireshark.StartCaptureLogFromContainer    filename=AMF_NG_reset.pcap    nodename=CPIF
    log to console    STEP2:AMF INITIATE
    Connect to 5GC
    AMF initiates global reset
    Sleep   2min
    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    wireshark.DownloadLogToUTEFromContainer    filename=AMF_NG_reset.pcap   nodename=CPIF
    Disconnect from 5GC
    gNB.Disconnect
    log to console    STEP3:CHECK NGAP LOG
    Wireshark.ReadLog    filename=AMF_NG_reset.pcap    filter=ngap
    Check NG reset parameter    checkparam=ngap.nG_Interface    comparevalue=0
    Check NG reset parameter    checkparam=ngap.NGResetAcknowledge_element   comparevalue=NGResetAcknowledge
    Wireshark.Action.Close
    COAM_Admin.Login
    COAM_Admin.ResetSite    timeout=15min
    COAM_Admin.Logout
#    [Teardown]  Teardown case

#[1][1.0] 5GC000638_B_10_gNB sends NG RESET REQ to AMF with Patial reset configuration and AMF response ACK
#    [Documentation]  gNB triggered NG parial reset. check from NG wiresharp package.
#    ...    "ngap.ResetType == 1" means the reset type is patial,
#    ...    "ngap.radioNetwork == 3" means triggered by ngran.
#    ...     ngap id in NGReset and ACK, shuld be equal with the one in the earlier messages (Pick the 1st in this case.)
#    [Tags]    5GC000638_B    CIT_TRUNK
#    [Setup]  Setup case
#    #Power.ResetgNB
#    #Wait until keyword succeeds   20x   1min    COAM_VerifyOnAirViaFrontendAndBackend
#    power_ue.Prepare UE    ue_type=${UE_TYPE}
#    power_ue.UE Attach    ue_type=${UE_TYPE}
#    spark.create_pdu_session     ue_alias=${UE_alias}
#    gNB.Connect
#    Wireshark.StartCaptureLogFromContainer    filename=NG_Patial_reset.pcap    nodename=CPIF
#    COAM_WebEM.Login
#    COAM_WEBEM.LockUnlcokCell
#    COAM_WEBEM.LockUnlcokCell
#    COAM_WebEM.Logout
#    Sleep   3min
#    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
#    wireshark.DownloadLogToUTEFromContainer    filename=NG_Patial_reset.pcap   nodename=CPIF
#    gNB.Disconnect
#    Wireshark.ReadLog    filename=NG_Patial_reset.pcap    filter=ngap
#    Check NG reset parameter    checkparam=ngap.ResetType   comparevalue=1
#    Check NG reset parameter    checkparam=ngap.NGResetAcknowledge_element   comparevalue=NGResetAcknowledge
#    Wireshark.Action.Close
#    [Teardown]  Teardown case



Connect to 5GC
    csn.connect to    ${5GC_IP}  ${5GC_USERNAME}  ${5GC_PASSWORD}    alias=${ALIAS_5GC}

Disconnect from 5GC
    csn.disconnect    connection=${ALIAS_5GC}

Send AMFConfUpdate from AMF by adding slice
    [Arguments]   ${testslice}=Testslice14
    csn.execute    command=cmm snssai create --name ${testslice} --sliceServiceType 11 --sliceDifferentiator ABCDEF    connection=${ALIAS_5GC}
    csn.execute    command=cmm snssaiListItem create --snssaiListName Snssai1 --snssaiName ${testslice}    connection=${ALIAS_5GC}
    csn.execute    command=cmm snssaiToDnn create --snssaiToDnnListName DNN1 --snssaiName ${testslice} --dataNetworkName wap1.nokia.com
    ...    connection=${ALIAS_5GC}
    ${test_slice_presence}=    csn.execute  cmm snssai list | grep ${testslice}   connection=${ALIAS_5GC}
    log    ${test_slice_presence}

Send AMFConfUpdate from AMF by deleting slice
    [Arguments]   ${testslice}=Testslice14
    csn.execute    command=cmm snssaiToDnn delete DNN1~${testslice}    connection=${ALIAS_5GC}
    csn.execute    command=cmm snssaiListItem delete Snssai1~${testslice}    connection=${ALIAS_5GC}
    csn.execute    command=cmm snssai delete ${testslice}    connection=${ALIAS_5GC}
    ${test_slice_presence}=    csn.execute  cmm snssai list | grep ${testslice}   connection=${ALIAS_5GC}
    log    ${test_slice_presence}


Unlock cell if locked
    [Documentation]   To recover env, unlock cell if it is locked.
    [Arguments]   ${cell_idx}=1    ${timeout}=60
    ${cell_info}=    selenium_coam.get_cell_info
    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="Locked"
    ...                selenium_coam.unlock_cell    cell_idx=1    timeout=${timeout}
    ${cell_info}=    selenium_coam.get_cell_info
    log   ${cell_info['Status']['Administrative state']}
    Sleep  2 mins

COAM_WEBEM.CheckBTSConutersWithConditioanalTraget
    [Arguments]    ${counter_id}   ${target_value}
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_bts_counters_info   counter_id=${counter_id}
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    should be true     ${values[-1]}>=${target_value}

Verify gNB Readiness and Fail Case if Not after reset
    ${gNB_on_air}    run keyword and return status    COAM_VerifyOnAirViaFrontendAndBackend
    run keyword if  not ${gNB_on_air}   Reset gNB if Not Ready

Reset gNB if Not Ready
    Power.ResetgNB
    ${gNB_on_air}    run keyword and return status    wait until keyword succeeds   6x   5min   COAM_VerifyOnAirViaFrontendAndBackend
    run keyword if  not ${gNB_on_air}    fail    msg=gnb is not on air!

Check_And_Require_MTK
    UE.Require_With_Retry
    UE.Init_MTK_With_Retry

Process.Ue Attach
    [Arguments]    ${UE_alias}=UE_1
    Clear UE info from AMF with Retry
    ute_ue.attach_ue    ue_alias=${UE_alias}
    ${res}    MTKUE.collect_ota_message_until    expected=5GMM_REGISTRATION_COMPLETE    wait_timeout=${120}
    should contain    ${res}    5GMM_REGISTRATION_COMPLETE

Clear UE info from AMF with Retry
   [Arguments]  ${ue_imsi}=${IMSI}   ${retry_times}=2
    FOR    ${i}    IN RANGE    ${retry_times}
        Clear UE info from AMF
    END
    Log    UeAttach retry for ${i + 1} times.

Clear UE info from AMF
   [Arguments]  ${ue_imsi}=${IMSI}   ${retry_times}=2
   Connect to 5GC
   ${imsi_presence}=    csn.execute   cmm subscriber show --imsi ${ue_imsi} | head -n 7 | grep GENERALINFO    connection=${ALIAS_5GC}
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    csn.execute   cmm subscriber delete --imsi ${ue_imsi}    connection=${ALIAS_5GC}
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    sleep   2min    # WA, make IMSI clear opeation is done completely.
   Disconnect from 5GC

UE.Require_With_Retry
    [Arguments]    ${UE_alias}=UE_1    ${UE_CAPABILITIES}=REAL_MEDIATEK_UE
    ${status}   Run Keyword And Return Status    ute_ue.require Ue    ue_alias=${UE_alias}    capabilities=${UE_CAPABILITIES}
    Run keyword if    '${status}'=='False'    Run Keywords    UE.Power_Reset
    ...    AND    ute_ue.require Ue    ue_alias=${UE_alias}    capabilities=${UE_CAPABILITIES}

UE.Init_MTK_With_Retry
    ${status}   Run Keyword And Return Status    MTKUE.init_mtk
    Run keyword if    '${status}'=='False'    Run Keywords    UE.Power_Reset
    ...    AND    MTKUE.init_mtk

UE.Power_Reset
    facom.PowerOnOff    pdu_ip=${MTK_FACOM_IP}    Port_Number=${MTK_FACOM_PORT}    Action=power_off
    facom.PowerOnOff    pdu_ip=${MTK_FACOM_IP}    Port_Number=${MTK_FACOM_PORT}    Action=power_on
    sleep    60s

gNB initiates global reset
    [Arguments]    ${container}=0xe004    ${connection}=${ALIAS_ASIK_SLAVE}
    #ssh.execute   command=lxc-attach -n ${container} -- iptables -t filter -A OUTPUT -p sctp --dport 38472 -j DROP    connection=${connection}
    #${result}    ssh.execute    command=ps -ef|grep CPRT    connection=${connection}
    #${ret}    ${CPRT_v6}    should match Regexp    ${result}    ([a-f|0-9]{2,4}:?){8}
    #ssh.execute   command=ip6tables -t filter -I OUTPUT 1 -s ${ret} -j DROP    connection=${connection}
    ssh.execute   command=ip6tables -t filter -I OUTPUT 1 -s fd5f:4268:2387:a881:40:43ff:fe80:a3 -j DROP    connection=${connection}

AMF initiates global reset
    [Arguments]    ${connection}=${ALIAS_5GC}
    ${result1}    ssh.execute
    ...    command=cmm amfMultiLink list --amfIntfType N2 -c linkIndex -c remoteIp1 -c linkIdentifier -c linkOperationState --startLinkIndex 1
    ...    connection=${ALIAS_5GC}
    ${result2}    ssh.execute
    ...    command=cmm amfMultiLink list --amfIntfType N2 -c linkIndex -c remoteIp1 -c linkIdentifier -c linkOperationState --startLinkIndex 100
    ...    connection=${ALIAS_5GC}
	${result3}    ssh.execute
    ...    command=cmm amfMultiLink list --amfIntfType N2 -c linkIndex -c remoteIp1 -c linkIdentifier -c linkOperationState --startLinkIndex 200
    ...    connection=${ALIAS_5GC}
    ${ret}    ${linkindex}    should match Regexp    ${result1}+${result2}+${result3}    \\|\ (\\d+)\ .*${ASIK_IP}\ .*\\|
    ssh.execute   command=cmm ngReset --linkIndex ${linkIndex}    connection=${connection}

Wireshark.Action.Close
    Conn.ConnectWithTimeout    alias=${ALIAS_UTE}
    ssh.execute     command=ps -ef|grep -i wireshark    connection=${ALIAS_UTE}
    ssh.send command    command=killall wireshark     connection=${ALIAS_UTE}
    Conn.Disconnect      ${ALIAS_UTE}
    sleep  2s

Check NG reset parameter
    [Arguments]    ${checkparam}    ${comparevalue}
    Wireshark.GetElementValueAndCompareWithDesiredValue    check_param=${checkparam}   compare_value=${comparevalue}
    ...    element_idx=${0}   condition_expression=ngap.procedureCode == 20

Setup suite
    TestSuite.Start
    Create Log Directories
    #set suite variable      ${Log_PATH_Artifactory}    /root/workspace/CIT/Master/Case_Logs/
    set suite variable   ${OAM_TYPE}    COAM
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["detach_request"]    default_value=${true}
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["power_reset"]        default_value=true
    gNB.GenerateTestLineSCFs
    gNB.GenerateCaseSCF    InputFile=${LOG_PATH}/TestLineSCF1Cell.xml    OutputFile=${LOG_PATH}/5GC000638_base_SCF.xml
    ...               ResourceFolder=${CURDIR}
    ...               ParameterToDelete=PARAMS_TO_DELETE_638
	...               MOsToAdd=MOs_TO_Add_638
    ...               ParamterToModify=PARAMS_TO_MODIFY_638
    ...               ListParamterToModify=LIST_PARAMS_TO_MODIFY_638
    ...               ListToAdd=LIST_TO_ADD_638
    log to console    Setup Suite:gNB start to commission
    gNB.Commission    scf_file=${LOG_PATH}/5GC000638_base_SCF.xml    timeout=${2400}
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    log to console    Setup Suite:gNB is onair
    Run Keyword And Ignore Error    force_close_coam_webdriver
    Conn.ResetCache
	
Teardown suite
    COAM_WebEM.Login
#    Wait Until Keyword Succeeds    3x   2min    Unlock cell if locked
    Wait Until Keyword Succeeds    3x   2min    COAM_WEBEM.LockUnlcokCell     action=unlock
    COAM_WebEM.Logout
    TestSuite.Stop

KW.CaseInit
    log to console    CaseInit start
    TestCase.Start
    Conn.ResetCache
    run    command=killall firefox
    run    command=killall geckodriver
    Run Keyword And Ignore Error    force_close_coam_webdriver

KW.CaseDestroy
#    ${L3sim_logName}=    catenate    SEPARATOR=_    ${TEST NAME}   egate_console.log
    Run Keyword And Ignore Error    gNB.connect
    Run Keyword And Ignore Error    Wireshark.StopCaptureNGLog
    Run Keyword And Ignore Error    Wireshark.DownloadLogToUTE    filename=tset.pcap
    ${tm}    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}    .    :
    ${gNB_logName}=    catenate    SEPARATOR=_    ${TEST NAME.replace(" ", "_")}   gNB-${tm}.log
    Run Keyword And Ignore Error    gnb.collectlog    ${gNB_logName}
    #Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    #Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    Run Keyword And Ignore error    force_close_coam_webdriver
#    L3sim.CollectLog   ${L3sim_logName}
    Run Keyword And Ignore error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=True
    Conn.ResetCache
    run    command=killall firefox
    run    command=killall geckodriver
    TestCase.Stop
