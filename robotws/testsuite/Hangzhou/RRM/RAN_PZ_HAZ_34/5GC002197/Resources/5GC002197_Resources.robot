*** Settings ***
Documentation     author: Li Yajie
...               contact: yajie.li@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC002197
Library           taf.transport.ssh    WITH NAME    csn
Library    taf.analyzer.pcap    WITH NAME   cap
Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource          ../../5GC000900/Resources/5GC000900_PowerUE.robot
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.ue    WITH NAME    ute_ue
Library           taf.hw.rf_attenuator    WITH NAME    PA
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/sigspark.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Variables         ${CFGFILE_ON_GIT}/TLDelta.py
#Variables         ${SCF_DELTA_PATH}/Delta_SCF.py
#Variables         ${CFGFILE_ON_GIT}/5GC002197/Delta_SCF.py

*** Variables ***
${LOG_PATH}             ${OUTPUT DIR}/Logs
#${CFGFILE_ON_GIT}           /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
#${GoldenSCF_PATH}    ${GoldenSCF_ON_GIT}/${GoldenSCF}

#${TL_DeltaPath}        ${CFGFILE_PATH}/TLDelta.py
#${DeltaPath}           ${CFGFILE_PATH}/5GC002197/Delta_SCF.py
${initial_S111_SCF}    ${LOG_PATH}/TestLineSCF3Cell_Both.xml
${MODIFIED_SCF_1}      ${LOG_PATH}/TestLineSCF3Cell_SA.xml


#${UE_TYPE}                  huawei_sigspark
${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}
${IMSI}                    ${tl.ues[0].imsi}

${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}

${UTE_IP}         ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}   ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}   ${tl.test_pc.default_ssh_connection_details.password}

${ASIK_LMP_IP}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}           ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${WEBUI_IP}          ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}        https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

${ENB_WEBUI_IP}      ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENBWEBUI_URL}      https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
#GNB1 PB
${PB_ASIK_IP}       ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

#GNB1 RU1 PB
${PB_5GRU_IP}       ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}     ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

#GNB1 RU2 PB
${PB_5GRU_2_IP}       ${tl.gnbs[0].dus[0].rus[1].pdu_port.pdu.addr}
${PB_5GRU_2_PORT}     ${tl.gnbs[0].dus[0].rus[1].pdu_port.port_no}

#GNB1 RU3 PB
${PB_5GRU_3_IP}       ${tl.gnbs[0].dus[0].rus[2].pdu_port.pdu.addr}
${PB_5GRU_3_PORT}     ${tl.gnbs[0].dus[0].rus[2].pdu_port.port_no}

#eNB1 RU PB
${PB_4GRU_IP}     ${tl.enbs[0].rms.pdu_port.pdu.addr}
${PB_4GRU_PORT}    ${tl.enbs[0].rms.pdu_port.port_no}
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

##################define these variable for convenient############################
${ALIAS_ASIK}               asik                                                ##
${ALIAS_ASIK_SLAVE}         asik_slave                                          ##
${ALIAS_ABIL}               abil                                               ##
${ALIAS_ABIL_SLAVE}         abil_slave                                          ##
${ALIAS_UTE}                ute                                                 ##
${ALIAS_ENBCTLPC}           ENB_PC                                              ##
${ALIAS_SHP}                SHP                                                 ##
${ALIAS_E500}               E500                                                ##
${ALIAS_LONER}              LONER                                               ##
${ALIAS_ASP_1A}             ASP_1A                                              ##
${ALIAS_PRISMA}             Prisma                                              ##
${ALIAS_AMF}                AMF                                                 ##
${ALIAS_tstm}               TSTM                                                ##
${ALIAS_QC}                 QC                                                  ##
${ALIAS_UPF}                UPF                                                 ##
${ASIK_SSH_IP}              asik_ssh                                            ##
${UE_alias}                 UE_0                                                ##
${ALIAS_5GC}                5gc                                                 ##
${ALIAS_MTKPC}              MTKPC                                               ##
${ALIAS_APN}                APN                                                 ##
########################END of alias Define#######################################

*** Keywords ***

TC.5GC000742_H_056_Search space in CORESET 0 with two symbols PDCCH, 48 PRBs
    2197_H_Common_Make SA call

TC.5GC002197_J_006_SIB1 and OSI of multi cells updated
    Parameters modify process for J06
    Spark.Check value from UE side    name=2197_J06_1.xml    msg=NR SystemInformationBlock1
    ...    expression=ue-TimersAndConstants.t310    expect_value=ms200
    Spark.Check log without attach    name=2197_J06_1.xml    msg=NR SystemInformationBlocks
    ...    expression=criticalExtensions.systemInformation.sib-TypeAndInfo.sib2.cellReselectionInfoCommon.q-Hyst    expect_value=dB1
    PA.AdjustAttenuationValueByGroup    PAGroup=${TLCommonConfig['PAGroups']['1']}    value=${127}
    PA.AdjustAttenuationValueByGroup    PAGroup=${TLCommonConfig['PAGroups']['2']}    value=${0}
#    PA.Adjust RU1 Attenuation to ${127}
#    PA.Adjust RU2 Attenuation to ${0}
    Spark.Check value from UE side    name=2197_J06_2.xml    msg=NR SystemInformationBlock1
    ...    expression=ue-TimersAndConstants.t310    expect_value=ms500
    Spark.Check log without attach    name=2197_J06_2.xml    msg=NR SystemInformationBlocks
    ...    expression=criticalExtensions.systemInformation.sib-TypeAndInfo.sib2.cellReselectionInfoCommon.q-Hyst    expect_value=dB4
    PA.AdjustAttenuationValueByGroup    PAGroup=${TLCommonConfig['PAGroups']['2']}    value=${127}
    PA.AdjustAttenuationValueByGroup    PAGroup=${TLCommonConfig['PAGroups']['3']}    value=${0}
#    PA.Adjust RU2 Attenuation to ${127}
#    PA.Adjust RU3 Attenuation to ${0}
    Spark.Check value from UE side    name=2197_J06_3.xml    msg=NR SystemInformationBlock1
    ...    expression=ue-TimersAndConstants.t310    expect_value=ms1000
    Spark.Check log without attach    name=2197_J06_3.xml    msg=NR SystemInformationBlocks
    ...    expression=criticalExtensions.systemInformation.sib-TypeAndInfo.sib2.cellReselectionInfoCommon.q-Hyst    expect_value=dB3

##### 2197-M Keywords#####
2197_H_Common_Make SA call
    [Documentation]  This is the common part for all 2197-M cases.
    Generate H56 SCF    tl_scf_file=${LOG_PATH}/TestLineSCF1Cell_Both.xml
    gNB.Commission    scf_file=${LOG_PATH}/2197_1cell_H56.xml   timeout=${2400}
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    gNB.Connect
    Wireshark.StartCaptureLogFromContainer    filename=CPIF_UEattach_H56.pcap    nodename=CPIF
    #Wireshark.CaptureBIPLog
    #Wireshark.DownloadLogToUTE    filename=tcpdumpL2L1_filtering_off.pcap0      localname=Bip_H56.pcap
    Run Keyword And Continue On Failure    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=${True}
    sleep    5s
    Run Keyword And Continue On Failure    power_ue.UE Detach    ue_type=${UE_TYPE}    power_reset=True
    sleep    5s
    Run Keyword And Continue On Failure    power_ue.UE Attach    ue_type=${UE_TYPE}    power_reset=True
    Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl     throughput=10MKbits/sec    duration=600
    ...    apn_address=${SA_APN}   ue_mode=SA
    Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul     throughput=5MKbits/sec    duration=600
    ...    apn_address=${SA_APN}   ue_mode=SA
    sleep    30
    Run Keyword And Continue On Failure    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=dl    throughput=5
    Run Keyword And Continue On Failure    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=ul    throughput=2
    Run Keyword And Continue On Failure    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl
    ...    apn_address=${SA_APN}   ue_mode=SA
    Run Keyword And Continue On Failure    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul
    ...    apn_address=${SA_APN}   ue_mode=SA
    Run Keyword And Continue On Failure    power_ue.UE Detach    ue_type=${UE_TYPE}    power_reset=True
    #Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    #wireshark.DownloadLogToUTEFromContainer    filename=CPIF_UEattach_H56.pcap   nodename=CPIF
    gNB.Disconnect
    #Close wireshark on UTE

Generate H56 SCF
	[Arguments]  ${tl_scf_file}
	gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}
	gNB.ModifySCF     InputFile=${LOG_PATH}/TestLineSCF1Cell_Both.xml
    ...               OutputFile=${LOG_PATH}/2197_1cell_H56.xml
	...               ParamterToModify=${PARAMS_TO_MODIFY_2197_H56}
	...               ParameterToDelete=${PARAMS_TO_REMOVE_2197_H56}

#Refine PA Port
##    ${PORTS}    Get Dictionary Keys    ${tl.attenuator.attenuator_ports}
##    ${PORTS}    Get Dictionary Keys    ${tl.attenuator.attenuation_port_numbers}
#    Set Suite Variable     ${5GRU1_ANT1}    ${PA_PORT[0]}
#    Set Suite Variable     ${5GRU1_ANT2}    ${PA_PORT[1]}
#    Set Suite Variable     ${5GRU2_ANT1}    ${PA_PORT[2]}
#    Set Suite Variable     ${5GRU2_ANT2}    ${PA_PORT[3]}
#    Set Suite Variable     ${5GRU3_ANT1}    ${PA_PORT[4]}
#    Set Suite Variable     ${5GRU3_ANT2}    ${PA_PORT[5]}
#    Set Suite Variable     ${5GGNB2_RU1_ANT1}    ${PA_PORT[6]}
#    Set Suite Variable     ${5GGNB2_RU1_ANT2}    ${PA_PORT[7]}

Setup My Suite
#    Reset gNB until Ready
    Import Variables      ${CFGFILE_PATH}/5GC002197/Delta_SCF.py
    Setup Suite
    set suite variable    ${TL_DeltaPath}        ${CFGFILE_PATH}/TLDelta.py
    set suite variable    ${DeltaPath}           ${CFGFILE_PATH}/5GC002197/Delta_SCF.py
    set suite variable    ${SCF_DELTA_PATH}      ${CFGFILE_PATH}/5GC002197
    set suite variable    ${GoldenSCF_PATH}      ${GoldenSCF_ON_GIT}/${GoldenSCF}
#    Refine PA Port
    gNB.FormatBTSID
    gNB.SetLoggingSeverity    LoggingSeverity=debug
    GNB.SwconfigReplace  file_path=${SCF_DELTA_PATH}
    gNB.Generate TL SCF    GoldenSCF_PATH=${GoldenSCF_PATH}    TLDelta_PATH=${CFGFILE_PATH}
    ...            TestLineSCF_cell_num=${1}   cell_type=Both
    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    #GNB.Commissioning   scf_file=TestLineSCF1Cell_Both.xml  file_path=${LOG_PATH}


#    ENB.Commissioning    scf_file=TestLineSCFeNB.xml    file_path=${CFGFILE_PATH}

#    Prepare Feature Level SCF and Commission
    PA.AdjustAttenuationValueByGroups
#    Adjust RU1 Attenuation to ${0}
    Process.Verify gNB Readiness and Fail Case if Not After Reset
    ## The following is a R&D WA, the paramater will be removed after the fainal solution is done.
#    COAM_WebEM.Login
#    COAM_WebEM.ModifyAndActiveParameters   DistName={MRBTS_ID}/${NRBTS_ID}    FilterParam=Temporary parameter #7   NewValue=1
#    COAM_WebEM.Logout

Teardown My Suite
    [Arguments]    ${recover_flags}=yes    ${recover_scf}=yes
    Teardown Suite
    #gNB.Connect
    #Basic.SedReplaceLine    matchValue='0x59005D'    newValue='#0x59005D=1'   file="/ffs/run/swconfig.txt"  alias=${ALIAS_ASIK}
    #Basic.SedReplaceLine    matchValue='0x5801A1'    newValue='#0x5801A1=1'   file="/ffs/run/swconfig.txt"  alias=${ALIAS_ASIK}
    #Conn.Execute    cmd=cd /ffs/run/ && crasign swconfig.txt    alias=${ALIAS_ASIK}
    #gNB.Disconnect
#    run keyword if    '${recover_flags}'=='yes'    GNB.SwconfigReplace  file_path=${CFGFILE_PATH}
    #@{2197_flags}    Create list    0x59005D   0x5801A1
    #run keyword if    '${recover_flags}'=='yes'    Disable Feature by commenting out flags    flags=${2197_flags}
#    run keyword if    '${recover_scf}'=='yes'    GNB.Commissioning  scf_file=TestLineSCF1Cell_Both.xml   file_path=${CFGFILE_PATH}
    PA.AdjustAttenuationValueByGroups
#    Adjust RU1 Attenuation to ${0}
#    Adjust GNB2_RU1 Attenuation to ${0}


#GNB.SwconfigReplace
#    [Arguments]    ${file_path}=${CFGFILE_PATH}
#    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
#    Conn.UploadFile    local_path=${file_path}/swconfig.txt    remote_path=/ffs/run/swconfig.txt    alias=${ALIAS_ASIK}
#    Conn.Execute    cmd=cd /ffs/run/ && crasign swconfig.txt    alias=${ALIAS_ASIK}
#    Conn.Disconnect  alias=${ALIAS_ASIK}

##### 2197-J-06 Keywords#####
Suite setup for 2197_J
    [Documentation]
    [Arguments]
    Setup 2197 case suite
    set suite variable   ${SCF_DELTA_PATH}      ${CFGFILE_PATH}/5GC002197
    set suite variable    ${DeltaPath}           ${CFGFILE_PATH}/5GC002197/Delta_SCF.py
    Import Variables    ${SCF_DELTA_PATH}/Delta_SCF.py
    Import Variables    ${CFGFILE_PATH}/5GC002197/Delta_SCF.py
    Refine PA Port
    set suite variable   ${GoldenSCF_PATH}    ${GoldenSCF_ON_GIT}/${GoldenSCF}
    gNB.FormatBTSID
    gNB.SetLoggingSeverity    LoggingSeverity=debug
	gNB.Generate TL SCF    GoldenSCF_PATH=${GoldenSCF_PATH}    TLDelta_PATH=${CFGFILE_PATH}
    ...            TestLineSCF_cell_num=${3}   cell_type=Both
    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    GNB.commision for 2197_J
    WEBUI.Check 3cell status with reset
    WEBUI.add NRSYSINFO_PROFILE

Setup 2197 case suite
    TestSuite.Start
    Create Log Directories
    set suite variable    ${Log_PATH_Artifactory}    /opt/ute/workspace/CIT/Master/Case_Logs
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    GNB.SwconfigReplace     file_path=${CFGFILE_PATH}/5GC002197/

GNB.commision for 2197_J
    [Documentation]
    [Arguments]
    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    gNB.ModifySCF    InputFile=${initial_S111_SCF}    OutputFile=${MODIFIED_SCF_1}
    ...    ParameterToDelete=${PARAMS_TO_DELETE_2197_J}    ParamterToModify=${PARAMS_TO_MODIFY_2197_J}
    GNB.Commission with retry for 3RU    scf_file=${MODIFIED_SCF_1}

WEBUI.add NRSYSINFO_PROFILE
    [Documentation]
    [Arguments]
    Run Keyword And Continue On Failure    COAM_WebEM.Login
    Run Keyword And Continue On Failure    selenium_coam.add_object    object_name=${MRBTS_ID}/${NRBTS_ID}    object_class_name=NRSYSINFO_PROFILE
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=${MRBTS_ID}/${NRBTS_ID}/NRSYSINFO_PROFILE-1    include_subobject=true    id_value=2
    Run Keyword And Continue On Failure    selenium_coam.add_object    object_name=${MRBTS_ID}/${NRBTS_ID}    object_class_name=NRSYSINFO_PROFILE
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=${MRBTS_ID}/${NRBTS_ID}/NRSYSINFO_PROFILE-1    include_subobject=true    id_value=3
    Run Keyword And Continue On Failure    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-2
    ...    filter_param=New Radio System Information Profile distinguished name   new_value=${MRBTS_ID}/${NRBTS_ID}/NRSYSINFO_PROFILE-2
    ...    abbr=nrSysInfoProfileDN
    Run Keyword And Continue On Failure    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-3
    ...    filter_param=New Radio System Information Profile distinguished name   new_value=${MRBTS_ID}/${NRBTS_ID}/NRSYSINFO_PROFILE-3
    ...    abbr=nrSysInfoProfileDN
    Run Keyword And Continue On Failure    WEBUI.ValidateAndActiveTheParameters
    Run Keyword And Continue On Failure    COAM_WebEM.Logout

Case setup for 2197_J
    [Documentation]
    [Arguments]
    PA.AdjustAttenuationValueByGroups
#    Run Keyword And Continue On Failure    PA.Adjust RU1 Attenuation to ${0}
#    Run Keyword And Continue On Failure    PA.Adjust RU2 Attenuation to ${127}
#    Run Keyword And Continue On Failure    PA.Adjust RU3 Attenuation to ${127}
##    run keyword and ignore error           PA.Adjust RU4 Attenuation to ${127}
##    Run Keyword And Continue On Failure    Restore initial parameters for 2197_J
    Run Keyword And Continue On Failure    Setup 2197 case

Case teardown for 2197_J
    [Documentation]
    [Arguments]
    PA.AdjustAttenuationValueByGroups
#    Run Keyword And Continue On Failure    PA.Adjust RU1 Attenuation to ${0}
#    Run Keyword And Continue On Failure    PA.Adjust RU2 Attenuation to ${127}
#    Run Keyword And Continue On Failure    PA.Adjust RU3 Attenuation to ${127}
##    run keyword and ignore error           PA.Adjust RU4 Attenuation to ${127}
#    Run Keyword And Continue On Failure    Restore initial parameters for 2197_J
    Run Keyword And Continue On Failure    Teardown 2197 case

Parameters modify process for J06
    [Documentation]    online modify parameter: cell1: t310=200ms qHyst=dB1; cell2: t310=500ms qHyst=dB4; cell3:t310=1000ms qHyst=dB3
    [Arguments]
    Run Keyword And Continue On Failure    COAM_WebEM.Login
    Run Keyword And Continue On Failure    WEBUI.modify t310 value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1    expect_value=200ms
    Run Keyword And Continue On Failure    WEBUI.modify t310 value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-2    expect_value=500ms
    Run Keyword And Continue On Failure    WEBUI.modify t310 value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-3    expect_value=1000ms
    Run Keyword And Continue On Failure    WEBUI.modify qHyst value   dist_name=${MRBTS_ID}/${NRBTS_ID}/NRSYSINFO_PROFILE-1    expect_value=dB1
    Run Keyword And Continue On Failure    WEBUI.modify qHyst value   dist_name=${MRBTS_ID}/${NRBTS_ID}/NRSYSINFO_PROFILE-2    expect_value=dB4
    Run Keyword And Continue On Failure    WEBUI.modify qHyst value   dist_name=${MRBTS_ID}/${NRBTS_ID}/NRSYSINFO_PROFILE-3    expect_value=dB3
    Run Keyword And Continue On Failure    WEBUI.ValidateAndActiveTheParameters
    Run Keyword And Continue On Failure    COAM_WebEM.Logout

WEBUI.modify t310 value
    [Documentation]
    [Arguments]    ${dist_name}    ${expect_value}
    ${before_status}    Run Keyword And Continue On Failure     selenium_coam.get_parameter_value    dist_name=${dist_name}
    ...    filter_param=Timer t310     abbr=t310
    Run Keyword If   '${before_status}' == '${expect_value}'    Log    continue next steps
    ...    ELSE     Run Keyword And Continue On Failure    selenium_coam.set_parameter_value
    ...    dist_name=${dist_name}    filter_param=Timer t310    new_value=${expect_value}    abbr=t310

WEBUI.modify qHyst value
    [Documentation]
    [Arguments]    ${dist_name}    ${expect_value}
    ${before_status}    Run Keyword And Continue On Failure     selenium_coam.get_parameter_value    dist_name=${dist_name}
    ...    filter_param=Hysterisis value for ranking criteria     abbr=qHyst
    Run Keyword If   '${before_status}' == '${expect_value}'    Log    continue next steps
    ...    ELSE     Run Keyword And Continue On Failure    selenium_coam.set_parameter_value
    ...    dist_name=${dist_name}    filter_param=Hysterisis value for ranking criteria    new_value=${expect_value}    abbr=qHyst

WEBUI.ValidateAndActiveTheParameters
    [Documentation]
    [Arguments]
    ${error}    selenium_coam.validate_plan
    log    ${error}
    Run Keyword And Ignore error    selenium_coam.activate_plan    activate_plan_despite_errors=True


Setup 2197 case
    TestCase.Start
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection

Teardown 2197 case
    [Arguments]   ${connection}=COAM
    TestCase.Stop
    Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog
    Run Keyword And Ignore Error    WEBUI.Backup current SCF
    log     ${TEST STATUS}
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    WEBUI.Collect snapshot
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect snapshot logs
    Run Keyword And Ignore Error    GNB.Clean pcap logs
    Run Keyword And Ignore Error    GNB.kill admin process
    Run Keyword And Ignore Error    run   command=killall firefox
    Conn.ResetCache

WEBUI.Backup current SCF
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    coam.get_current_scf_file   local_dir_path=${LOG_PATH}   file_name=${TEST NAME.replace(" ", "_")}.xml   connection=COAM   timeout=10
    COAM_Admin.Logout

GNB.kill admin process
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9

GNB.Clean pcap logs
    [Arguments]
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.Execute  cmd=rm -rf /ffs/run/config/toor4nsn/2197*.pcap   alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}

WEBUI.Collect snapshot
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}

Spark.Check value from UE side
    [Arguments]    ${name}    ${msg}    ${expression}    ${expect_value}    ${type}='last'    ${ue_alias}=UE_0
    Run Keyword And Continue On Failure  AMF.ClearUEInfoFromAMF    ue_imsi=${IMSI}
    Run Keyword And Continue On Failure  power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=0
    Run Keyword And Continue On Failure    spark.start log    ue_alias=${ue_alias}
    Run Keyword And Ignore error    spark.power_off    ue_alias=${UE_alias}
    Run Keyword And Ignore error    spark.power_on    ue_alias=${UE_alias}
    Run Keyword And Ignore error    power_ue.Verify attach    ue_type=${ue_type}    ue_index=0
    sleep    30s
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=0
    Run Keyword And Continue On Failure    spark.stop log    ue_alias=${ue_alias}    logname=${LOG_PATH}/${name}
    Run Keyword And Continue On Failure    spark.read_log     logname=${LOG_PATH}/${name}
    ${res}    spark.get_expected_val     msg=${msg}    expression=${expression}    type=${type}
    should be equal     ${res}    ${expect_value}

Spark.Check log without attach
    [Arguments]    ${name}    ${msg}    ${expression}    ${expect_value}
    Run Keyword And Continue On Failure    spark.read_log     logname=${LOG_PATH}/${name}
    ${res}    spark.get_expected_val     msg=${msg}    expression=${expression}
    should be equal     ${res}    ${expect_value}

GNB.Commission with retry for 3RU
    [Arguments]    ${scf_file}
    ${commission_check}    run keyword and return status    gNB.Commission    scf_file=${scf_file}    oam_type=COAM    timeout=900
    Run keyword if    ${commission_check}== True    Log    continue next steps
    Run keyword if    ${commission_check}== False    run keywords     Power.ResetgNB    model=HBTE
                      ...    AND    Power.Reset5GRU    pdu_ip=${PB_5GRU_IP}    Port_Number=${PB_5GRU_PORT}    model=HBTE
                      ...    AND    Power.Reset5GRU    pdu_ip=${PB_5GRU_2_IP}    Port_Number=${PB_5GRU_2_PORT}    model=HBTE
                      ...    AND    Power.Reset5GRU    pdu_ip=${PB_5GRU_3_IP}    Port_Number=${PB_5GRU_3_PORT}    model=HBTE
                      ...    AND    sleep    4min
                      ...    AND    gNB.Commission    scf_file=${scf_file}    oam_type=COAM    timeout=900

WEBUI.Check 3cell status with reset
    ${3cell_check}    run keyword and return status    WEBUI.Check Cell Until Success
    Run keyword if    ${3cell_check}== True    Log    continue the next steps
    Run keyword if    ${3cell_check}== False    run keywords     Power.ResetgNB    model=HBTE
                      ...    AND    Power.Reset5GRU    pdu_ip=${PB_5GRU_IP}    Port_Number=${PB_5GRU_PORT}    model=HBTE
                      ...    AND    Power.Reset5GRU    pdu_ip=${PB_5GRU_2_IP}    Port_Number=${PB_5GRU_2_PORT}    model=HBTE
                      ...    AND    Power.Reset5GRU    pdu_ip=${PB_5GRU_3_IP}    Port_Number=${PB_5GRU_3_PORT}    model=HBTE
                      ...    AND    wait until keyword succeeds   13x   2min    WEBUI.Get 3cell status

WEBUI.Check Cell Until Success
    wait until keyword succeeds   20x   1min    WEBUI.Get 3cell status

WEBUI.Get 3cell status
    [Arguments]   ${connection}=COAM
    COAM_Admin.Login
    ${subcells_info}    coam.get_subcells_status    connection=${connection}   timeout=10

    ${availabilityStatus_1}   Set Variable   ${subcells_info['NRCELLGRP-0']['NRCELL-1']['NRCELL_R']['availabilityStatus']}
    Run Keyword And Continue On Failure    Should Contain   ${availabilityStatus_1}   Online
    ${operationalState_1}   Set Variable   ${subcells_info['NRCELLGRP-0']['NRCELL-1']['NRCELL_R']['operationalState']}
    Run Keyword And Continue On Failure    Should Contain   ${operationalState_1}   Enabled

    ${availabilityStatus_2}   Set Variable   ${subcells_info['NRCELLGRP-1']['NRCELL-2']['NRCELL_R']['availabilityStatus']}
    Run Keyword And Continue On Failure    Should Contain   ${availabilityStatus_2}   Online
    ${operationalState_2}   Set Variable   ${subcells_info['NRCELLGRP-1']['NRCELL-2']['NRCELL_R']['operationalState']}
    Run Keyword And Continue On Failure    Should Contain   ${operationalState_2}   Enabled

    ${availabilityStatus_3}   Set Variable   ${subcells_info['NRCELLGRP-2']['NRCELL-3']['NRCELL_R']['availabilityStatus']}
    Run Keyword And Continue On Failure    Should Contain   ${availabilityStatus_3}   Online
    ${operationalState_3}   Set Variable   ${subcells_info['NRCELLGRP-2']['NRCELL-3']['NRCELL_R']['operationalState']}
    Run Keyword And Continue On Failure    Should Contain   ${operationalState_3}   Enabled

    COAM_Admin.Logout

COAM.Check alarm via webui
    [Arguments]    ${item}
    Run Keyword And Continue On Failure    COAM_WebEM.Login
    ${alarm_info}    selenium_coam.get_active_alarm_info
    Set test variable    ${alarm_info}
    ${length}    Get length     ${alarm_info}
    FOR    ${i}    IN RANGE    ${length}
        Set test variable    ${i}
        ${res_check}    run keyword and return status    COAM.Check alarm    item=${item}
        ${res}=    Run Keyword And Ignore error    should be true    '${res_check}' == 'True'
        Run Keyword If    ${res} == ('PASS', None)    Exit For Loop
    END
    Run keyword if    ${res} != ('PASS', None)    Fail    alarm check fail
    Run Keyword And Continue On Failure    COAM_WebEM.Logout

COAM.Check alarm
    [Arguments]    ${item}
    ${alarm_id}   Set Variable   ${alarm_info[${i}]['Alarm ID']}
    ${fault_id}   Set Variable   ${alarm_info[${i}]['Fault ID']}
    ${alarm_name}   Set Variable   ${alarm_info[${i}]['Fault name']}
    Run Keyword And Continue On Failure    should contain   container=${Alarm ID}   item=${item[0]}
    Run Keyword And Continue On Failure    should contain   container=${fault_id}   item=${item[1]}
    Run Keyword And Continue On Failure    should contain   container=${alarm_name}   item=${item[2]}