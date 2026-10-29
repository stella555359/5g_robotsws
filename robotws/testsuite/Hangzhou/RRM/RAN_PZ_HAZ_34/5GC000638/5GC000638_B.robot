*** Settings ***
Suite Setup    Setup suite
Suite Teardown    Teardown suite
Force Tags     RAN_5G  RAN_5G_TDD  CLOUD_5G_CLASSICAL_ASIML_ABIPB1_2xAWHQE_ENB  STATE_SW_UPLOADED  SBTS00  SBTS21B
...    PY36
...               SBTS22R1
#...    commissionings/RRM/Hangzhou/5GC000496_C/5GC000496_C_NSACamp_HDBDE_AEQA
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.ue.prisma    WITH NAME    prisma
Resource          ../5GC000496_C/Resources/L3Call.robot
#Resource          ../../../../resources/common/prisma_common_keywords.robot
#Variables    ../../../commissionings/RRM/Hangzhou/5GC000496_C/5GC000496_C_NSACamp_HDBDE_AEQA/__init__.py
#Variables         ${CFGFILE_PATH}/Delta_SCF.py
Library           Resources/coam_close.py
Library           taf.ue    WITH NAME   ute_ue
Library           ../5GC000742/Resources/MTKUE_extend.py
Library           MTKUE_extend.MTKUE    WITH NAME   MTKUE
#Variables         ${TLCFGFILE_PATH}/TLDelta.py

Documentation
...    author: Yuan Hongyan
...    contact: hongyan.1.yuan@nokia-sbell.com
...    squad group: SG_01
...    feature : 5GC000638-B

*** Variables ***
${mcc}                      ${tl.core.mcc}
${mnc}                       ${tl.core.mnc}
${UPDATE_FILE_PATH}         /opt/ute/tmp
#${CFGFILE_PATH}             /home/ute/TAF/cfgfile
${WA_SCF_FILE_BLOW6G}       /home/ute/TAF/cfgfile/SBTS5G18A_5g_pid12_classical.xml
${WA_SCF_FILE_ABOVE6G}      /home/ute/TAF/cfgfile/SBTS5G18A_5g_pid11_classical.xml

${EGATE_CFG_NAME}           ${tl.core.cfg_filename}
${WTS_FILE_PATH}            ${tl.core.dir_path}

${IMSI}                     ${tl.ues[0].imei}
${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

#${ASIK_IP}                  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
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

${MTK_FACOM_IP}                   ${tl.ues[0].pdu.pdu.addr}
${MTK_FACOM_PORT}                   ${tl.ues[0].pdu.port_no}

${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

${yml_path}    ${CURDIR}/Resources/camp_prisma_84.yml
${sid_file_name}    5GNSAFullMode.sid
${5g_cellid_expected}    50

${scenario}    ${CURDIR}/Resources/sid_sce_084/
${attach_times}    1
${detach_times}    1
${ra_times}    1


${MRBTS_ID}                  MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                  NRBTS-${tl.gnbs[0].global_bts_id}
#${TLCFGFILE_PATH}             /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
##################define these variable for convenient############################
${ALIAS_ASIK}               asik
${ALIAS_ASIK_SLAVE}         asik_slave
${ALIAS_UTE}                ute
${ALIAS_ENBCTLPC}           ENB_PC
${ALIAS_SHP}                SHP
${ALIAS_E500}               E500
${ALIAS_PRISMA}             Prisma
${ALIAS_5GC}                5gcore
${ALIAS_QC}               qualcomm

########################END of alias Define#######################################


*** Test Cases ***
[1]5GC000638_B_19_EDA_00920416_lock 1 of 2 cells with same TAI will not trigger RAN CONFIGURATION UPDATE by gNB
    [Documentation]  related cases:638_B_7
    [Tags]    5GC000638_B    CRT_20B    CRT_TRUNK    CRT_TL13   CRT_21B   CRT_UTE    CRT_22R1    CRT_22R2    CRT_22R3
    [Setup]    robot_common_operations.Common Case Setup
    gNB.FormatBTSID    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    COAM_WebEM.Login
    COAM_WebEM.SetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1    abbr=Cell deployment type    value=SA
    COAM_WebEM.SetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-2    abbr=Cell deployment type    value=SA
    Run Keyword And Ignore Error    COAM_WebEM.DeleteParameter  distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1    abbr=Configured EPS tracking area code
    Run Keyword And Ignore Error    COAM_WebEM.DeleteParameter  distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-2    abbr=Configured EPS tracking area code
    COAM_WebEM.ValidateAndActiveParameters
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    Wait until keyword succeeds   15x   1min    COAM_WebEM.VerifyAllCellsAreOnline
    gNB.Connect
    Wireshark.StartCaptureNGLog    filename=FP0.pcap
    COAM_WebEM.Login
    COAM_WEBEM.LockUnlcokCell    cell_idx=1    action=lock
    Wireshark.StopCaptureNGLog
    COAM_WEBEM.LockUnlcokCell    cell_idx=1    action=unlock
    COAM_WebEM.Logout
    Wireshark.DownloadLogToUTE   filename=FP0.pcap
    gNB.Disconnect
    Wireshark.ReadLog    filename=FP0.pcap    filter=ngap.procedureCode == 35
    ${res}    Run Keyword And Ignore Error    Wireshark.CheckExpression     expression= ngap.procedureCode == 35
    Should Be True    '${res[0]}'=='FAIL'
    [Teardown]    TestCase.Stop

[1]5GC000638_B_8_AMF responds with the message NG RESET ACK to gNB after received Req
    [Documentation]  related cases:638_B_7
    [Tags]    5GC000638_B    CRT_19B    CRT_TRUNK
    [Setup]  Setup case
    Power.ResetgNB     model=HBTE
    Wait until keyword succeeds   20x   1min    COAM_VerifyOnAirViaFrontendAndBackend
    Check_And_Require_MTK
    ute_ue.attach_ue    ue_alias=UE_1
    MTKUE.create_pdu_session    id=1    wap=mdrb.nokia.com    retry=5
    gNB.Connect
    Wireshark.StartCaptureLogFromContainer    filename=GNB_NG_reset.pcap    nodename=CPIF
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

#[1]5GC000638_B_12_gNB responds with NG RESET ACK to the AMF after full reset procedure
#    [Documentation]
#    [Tags]    5GC000638_B    CRT_19B    CRT_TRUNK
#    [Setup]  Setup case
#    Power.ResetgNB
#    Wait until keyword succeeds   20x   1min    COAM_VerifyOnAirViaFrontendAndBackend
#    Check_And_Require_MTK
#    Process.Ue Attach
#    MTKUE.create_pdu_session    id=1    wap=multipleqci.nokia.com    retry=5
#    gNB.Connect
#    Wireshark.StartCaptureLogFromContainer    filename=AMF_NG_reset.pcap    nodename=CPIF
#    Connect to 5GC
#    AMF initiates global reset
#    Sleep   2min
#    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
#    wireshark.DownloadLogToUTEFromContainer    filename=AMF_NG_reset.pcap   nodename=CPIF
#    Disconnect from 5GC
#    gNB.Disconnect
#    Wireshark.ReadLog    filename=AMF_NG_reset.pcap    filter=ngap
#    Check NG reset parameter    checkparam=ngap.nG_Interface    comparevalue=0
#    Check NG reset parameter    checkparam=ngap.NGResetAcknowledge_element   comparevalue=NGResetAcknowledge
#    Wireshark.Action.Close
#    COAM_Admin.Login
#    COAM_Admin.ResetSite    timeout=15min
#    COAM_Admin.Logout
#    [Teardown]  Teardown case

#[1]5GC000638_B_16_gNB stores this configuration and new Name will be used in future
#    [Documentation]  related cases: 638_B_15
#    [Tags]  5GC000638_B    CRT_19B   CRT_TRUNK
#    [Setup]  Setup case
#    COAM_WebEM.Login
#    Trigger AMFConfUpdate from AMF
#    Wait until keyword succeeds   5x   8min    Check AMFConfUpdateResp and AMFConfUpdateACK from gNB
#    COAM_WebEM.Logout
#    [Teardown]  Teardown case
#
#[1]5GC000638_B_18_AMF stores and responds wth message RAN CONFIGURATION UPDATE success
#    [Documentation]  related cases: 638_B_17
#    [Tags]  5GC000638_B    CRT_19B    CRT_TRUNK
#    [Setup]   Setup case
#    COAM_WebEM.Login
#    Wait Until Keyword Succeeds    3x   2min    Trigger RANConfUpdate from gNB
#    Wait until keyword succeeds    5x   8min    Check RANConfUpdateResp and RANConfUpdateACK from gNB
#    COAM_WEBEM.LockUnlcokCell
#    COAM_WebEM.Logout
#    [Teardown]  Teardown case
#
#[1]5GC000638_B_7_gNB initiate NG full reset procedure send NG RESET Req to AMF
#    [Documentation]
#    [Tags]    5GC000638_B    CIT_19B    CIT_TRUNK
#    [Setup]  Setup case
#    Wait until keyword succeeds   5x   1min    COAM_VerifyOnAirViaFrontendAndBackend
#    Check_And_Require_MTK
#    #Process.Ue Attach
#    ute_ue.attach_ue    ue_alias=UE_1
#    MTKUE.create_pdu_session    id=1    wap=multipleqci.nokia.com    retry=5
#    gNB.Connect
#    Wireshark.StartCaptureLogFromContainer    listen_port=any    filename=GNB_NG_reset.pcap
#    gNB initiates global reset
#    Sleep    5min
#    Wireshark.StopCapturinglogFromContainer
#    DownloadCPIFToUTE    filename=GNB_NG_reset.pcap
#    gNB.Disconnect
#    Wireshark.ReadLog    filename=GNB_NG_reset.pcap    filter=ngap
#    Check NG reset parameter    checkparam=ngap.nG_Interface    comparevalue=0
#    Wireshark.Action.Close
#    COAM_Admin.Login
#    COAM_Admin.ResetSite    timeout=15min
#    COAM_Admin.Logout
#    [Teardown]  Teardown case
#
#[1]5GC000638_B_10_gNB sends NG RESET REQ to AMF with Patial reset configuration and AMF response ACK
#    [Documentation]  gNB triggered NG parial reset. check from NG wiresharp package.
#    ...    "ngap.ResetType == 1" means the reset type is patial,
#    ...    "ngap.radioNetwork == 3" means triggered by ngran.
#    ...     ngap id in NGReset and ACK, shuld be equal with the one in the earlier messages (Pick the 1st in this case.)
#    [Tags]    5GC000638_B    CRT_19B    CRT_TRUNK
#    [Setup]  Setup case
#    Power.ResetgNB
#    Wait until keyword succeeds   20x   1min    COAM_VerifyOnAirViaFrontendAndBackend
#    Check_And_Require_MTK
#    Process.Ue Attach
#    MTKUE.create_pdu_session    id=1    wap=multipleqci.nokia.com    retry=5
#    gNB.Connect
#    Wireshark.StartCaptureLogFromContainer    filename=NG_Patial_reset.pcap
#    COAM_WebEM.Login
#    COAM_WEBEM.LockUnlcokCell
#    COAM_WEBEM.LockUnlcokCell
#    COAM_WebEM.Logout
#    Sleep   3min
#    Wireshark.StopCapturinglogFromContainer
#    DownloadCPIFToUTE    filename=NG_Patial_reset.pcap
#    gNB.Disconnect
#    Wireshark.ReadLog    filename=NG_Patial_reset.pcap    filter=ngap
#    Check NG reset parameter    checkparam=ngap.ResetType   comparevalue=1
#    Check NG reset parameter    checkparam=ngap.NGResetAcknowledge_element   comparevalue=NGResetAcknowledge
#    Wireshark.Action.Close
#    [Teardown]  Teardown case


*** Keywords ***
Connect to 5GC
    csn.connect to    ${5GC_IP}  ${5GC_USERNAME}  ${5GC_PASSWORD}    alias=${ALIAS_5GC}

Disconnect from 5GC
    csn.disconnect    connection=${ALIAS_5GC}

Trigger FullReset from AMF
   Connect to 5GC
   [Arguments]  ${GNB_IP}=${ASIK_IP}
   log to console   ${GNB_IP}
   ${cmd}  set variable  cmm amfMultiLink list --amfIntfType N2 -c linkIndex -c remoteIp1 -c linkIdentifier -c linkOperationState --startLinkIndex 1
   ${output}  csn.execute  command=${{cmd} | grep ${GNB_IP}    connection=${ALIAS_5GC}
   @{output_splited}  Split String  ${output}  |
   ${link_index}   Strip String   ${output_splited}[0]
   ${output1}  csn.execute  command=cmm ngReset --linkIndex ${link_index}
   should contain   ${output1}   ngReset | ${link_index}
   Disconnect from 5GC

Trigger AMFConfUpdate from AMF
    [Arguments]   ${testslice}=Testslice14
    Connect to 5GC
    ${test_slice_presence}=    csn.execute   cmm snssai list | grep ${testslice}    connection=${ALIAS_5GC}
    run keyword if   '${test_slice_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
    ...    Send AMFConfUpdate from AMF by adding slice
    run keyword if  not '${test_slice_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
    ...    Send AMFConfUpdate from AMF by deleting slice
    Disconnect from 5GC

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


Trigger Patial Reset from gNB
   [Documentation]   triggerred by resettng abil
    Wait Until Keyword Succeeds    3x    1min    COAM_WebEM.Login
    Wait Until Keyword Succeeds    3x   2min    selenium_coam.reset_abil
    COAM_WebEM.Logout

Trigger RANConfUpdate from gNB
    COAM_WEBEM.LockUnlcokCell


Unlock cell if locked
    [Documentation]   To recover env, unlock cell if it is locked.
    [Arguments]   ${cell_idx}=1    ${timeout}=60
    log to console   ${cell_idx}
    ${cell_info}=    selenium_coam.get_cell_info
    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="Locked"
    ...                selenium_coam.unlock_cell    cell_idx=1    timeout=${timeout}
    ${cell_info}=    selenium_coam.get_cell_info
    log   ${cell_info['Status']['Administrative state']}
    Sleep  2 mins

Check AMFConfUpdateResp and AMFConfUpdateACK from gNB
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55119C00017    target_value=1
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55119C00018    target_value=1


Check RANConfUpdateResp and RANConfUpdateACK from gNB
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55119C00015    target_value=1
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55119C00016    target_value=1


COAM_WEBEM.CheckBTSConutersWithConditioanalTraget
    [Arguments]    ${counter_id}   ${target_value}
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_bts_counters_info   counter_id=${counter_id}
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    should be true     ${values[-1]}>=${target_value}

Reset DU to initiate NG full reset
    no operation

Check NG Reset Message and Reset Type
    Wireshark.CheckExpression    e212.mcc == 262
    Wireshark.GetElementValueAndCompareWithDesiredValue    ngap.gNB_ID    00:00:14    ${1}

Check NG Reset ACK Message
   no operation   # to be added.

Reset CP_CU to initiate NG partial reset
   no operation   # to be added.


Process.UE Attach With MTK
    log   to be added.


Wireshark.TiggerAndAnalyzeWithExpression
    [Arguments]    ${filename}   ${trigger}    ${duration}    ${expression}    ${connection}=${ALIAS_ASIK}
    log to console   ${connection}
    gNB.Connect
    Wireshark.StartCaptureNGLog   filename=${filename}
    run keyword   ${trigger}
    sleep  ${duration}
    Wireshark.StopCapturinglog
    Wireshark.DownloadLogToUTE   filename=${filename}
    Wireshark.ReadLog    filename=${filename}
    Wireshark.CheckExpression     expression=${expression}


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

Process.Ue Deteach
    [Arguments]    ${UE_alias}=UE_1
    ute_ue.detach_ue    ue_alias=${UE_alias}
    sleep    10s

Process.Ue Attach
    [Arguments]    ${UE_alias}=UE_1
    Clear UE info from AMF with Retry
    ute_ue.attach_ue    ue_alias=${UE_alias}
    ${res}    MTKUE.collect_ota_message_until    expected=5GMM_REGISTRATION_COMPLETE    wait_timeout=${120}
    should contain    ${res}    5GMM_REGISTRATION_COMPLETE

Clear UE info from AMF with Retry
   [Arguments]  ${ue_imsi}=${IMSI}   ${retry_times}=2
   log to console   ${ue_imsi}
    FOR    ${i}    IN RANGE    ${retry_times}
        Clear UE info from AMF
    END
    Log    UeAttach retry for ${i + 1} times.

Clear UE info from AMF
   [Arguments]  ${ue_imsi}=${IMSI}   ${retry_times}=2
   log to console   ${retry_times}
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
    [Arguments]    ${container}=0xe004    ${connection}=${ALIAS_ASIK}
    ssh.execute   command=lxc-attach -n ${container} -- iptables -t filter -A OUTPUT -p sctp --dport 38472 -j DROP    connection=${connection}


AMF initiates global reset
    [Arguments]    ${connection}=${ALIAS_5GC}
    ${result}    ssh.execute
    ...    command=cmm amfMultiLink list --amfIntfType N2 -c linkIndex -c remoteIp1 -c linkIdentifier -c linkOperationState --startLinkIndex 1
    ...    connection=${ALIAS_5GC}
    ${ret}    ${linkindex}    should match Regexp    ${result}    \\|\ (\\d+)\ .*${ASIK_IP}.*\\|
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
    Run Keyword And Ignore Error    Import Variables    ${CFGFILE_PATH}/Delta_SCF.py
    Create Log Directories
    #set suite variable      ${Log_PATH_Artifactory}    /root/workspace/CIT/Master/Case_Logs/
    Conn.ResetCache
#    Process.CellSetup
#    Process.UE Attach

Teardown suite
    COAM_WebEM.Login
    Wait Until Keyword Succeeds    3x   2min    Unlock cell if locked
    COAM_WebEM.Logout

Setup case
    Conn.ResetCache
    run    command=killall firefox
    run    command=killall geckodriver

Teardown case
#    ${L3sim_logName}=    catenate    SEPARATOR=_    ${TEST NAME}   egate_console.log
    ${tm}    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}    .    :
    ${gNB_logName}=    catenate    SEPARATOR=_    ${TEST NAME.replace(" ", "_")}   gNB-${tm}.log
    Run Keyword And Ignore Error    gnb.collectlog    ${gNB_logName}
#    Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
#    Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    Run Keyword And Ignore error    force_close_coam_webdriver
#    L3sim.CollectLog   ${L3sim_logName}
    Conn.ResetCache
    run    command=killall firefox
    run    command=killall geckodriver
