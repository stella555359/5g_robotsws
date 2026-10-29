*** Settings ***
Documentation    author:Liu Tiffany
...               contact: tiffany.liu@nokia-sbell.com
...               squad group: SG_01
...               feature : CB006555
Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/Power_ue_supports/power_ue_log.robot
Library           taf.config.scf    WITH NAME    scf
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           ../../5GC000638/Resources/coam_close.py

Library           OperatingSystem
Library           DateTime
Library           ute_wtssim
Library           ute_syslog
Library           ute_admin
Library           urllib
Library           Collections
Library           Process
Library           String
Library           Telnet

#Variables         ${CFGFILE_ON_GIT}/TLDelta.py
#Variables         ${CFGFILE_ON_GIT}/CB006555/Delta_SCF.py

*** Variables ***
${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}
${IMSI}                     ${tl.ues[0].imsi}
${IMSI1}                     ${tl.ues[1].imsi}
#${GoldenSCF_PATH}           ${GoldenSCF_ON_GIT}/${GoldenSCF}
#${CFGFILE_ON_GIT}           /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
#${GoldenSCF_ON_GIT}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/
${link_to_Artifact}         https://esisoj70.emea.nsn-net.net/artifactory/mnp5g-central-public/System_Release/

#${DeltaPath}                ${CFGFILE_PATH}/CB006555/Delta_SCF.py

${PB_PORT}                  5000
${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
${PB_4GRU_IP}               ${tl.enbs[0].rms.pdu_port.pdu.addr}
${PB_4GRU_PORT}             ${tl.enbs[0].rms.pdu_port.port_no}
${PB_WMPeNB_IP}             ${tl.enbs[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_WMPeNB_PORT}           ${tl.enbs[0].airscale.common_units[0].pdu_port.port_no}

${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

${ENB_WEBUI_IP}             ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENBWEBUI_URL}             https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

#${BTS_ID}                    1101
${rmod_index}                1
#@{ALLOWED_FAULT}            &{fault_61652}    &{fault_61524}
#${RU_TYPE}                  ${tl.gnbs[0].du.rus[0].radio_type.value}
${PROGRAM}                  ${None}

${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}

${ASIK_LMP_IP}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

#${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

${MRBTS_ID}                 MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                 NRBTS-${tl.gnbs[0].global_bts_id}

${4G_WEBUI_IP}              ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${5G_WEBUI_IP}              ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${BTSMOD}                   5GOnly
${PA_INFO}                  ${tl.attenuator}
##################define these variable for convenient############################
${ALIAS_ASIK}               asik                                                ##
${ALIAS_ASIK2}              asik2                                               ##
${ALIAS_ASIK_SLAVE}         asik_slave                                          ##
${ALIAS_ABIL}               abil                                                ##
${ALIAS_ABIL_SLAVE}         abil_slave                                          ##
${ALIAS_UTE}                ute                                                 ##
${ALIAS_ENBCTLPC}           ENB_PC                                              ##
${ALIAS_SHP}                SHP                                                 ##
${ALIAS_LONER}              LONER                                               ##
${ALIAS_ASP_1A}             ASP_1A                                              ##
${ALIAS_MTKPC}                MTKPC                                             ##
${ALIAS_APN1}               APN1                                                ##
${ALIAS_APN2}               APN2                                                ##
${UE_alias}                 UE_0                                                ##
${ALIAS_5GC}                5gc                                                 ##
${OAM_TYPE}                 COAM                                                ##
########################END of alias Define#######################################

*** Keywords ***

TC.CB006555_A_02_CORESET duration pattern modification due to lack of Type1-PDCCH availability in SA call_newCP
    gNB.GenerateCaseSCF    InputFile=${TL_S1_base_SCF}    OutputFile=${LOG_PATH}/6555_A02_SCF.xml
    ...                    ResourceFolder=${CURDIR}
    ...                    ParameterToDelete=PARAMS_TO_DELETE_6555_A02
    ...                    MOsToAdd=ADD_MOs_6555_A02
    ...                    ParamterToModify=PARAMS_TO_MODIFY_6555_A02
    ...                    ListParamterToModify=LIST_PARAMS_TO_MODIFY_6555_A02
    ...                    ListToAdd=LIST_TO_ADD_6555_A02
    #run keyword and ignore error    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${0}
    log to console    CASE STEP1:upload SCF,gNB start commission
    gNB.CommissionWithRetry    scf_file=${LOG_PATH}/6555_A02_SCF.xml    model=HBTE
    log to console    gNB commission successful end
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady
    log to console    gNB is onair\n CASE STEP2:SA UE attach and start peak traffic
    ${uecfg}    MultiUE._L3CallBuildParameters   power_reset=true
    ...    apn=${SA_APN}
    ...    ue_index=${0}
    ...    dl_target_throughput=${CASE_INPUT_CB006555['Peak_Traffic_DL']}
    ...    ul_target_throughput=${CASE_INPUT_CB006555['Peak_Traffic_UL']}
    ...    target_avg_percent=0.5
    ...    check_throughput_duration=300
    MultiUE.ClearUEInfoFromAMF    UECFG=${uecfg}
    MultiUE.PrepareUE             UECFG=${uecfg}
    MultiUE.Attach                UECFG=${uecfg}
    MultiUE.StartDLTraffic        UECFG=${uecfg}
    MultiUE.StartULTraffic        UECFG=${uecfg}
#    UE.One_UE_Call_with_traffic    ue_index=${0}    Traffic_hold=True    imsi=${IMSI}    apn_address=${SA_APN}
#    ...    throughput_dl=${CASE_INPUT_CB006555['Peak_Traffic_DL']}MKbits/sec
#    ...    throughput_ul=${CASE_INPUT_CB006555['Peak_Traffic_UL']}MKbits/sec
#    ...    check_throughput_dl=${CASE_INPUT_CB006555['Peak_Traffic_DL']*0.5}
#    ...    check_throughput_ul=${CASE_INPUT_CB006555['Peak_Traffic_UL']*0.5}
    log to console    gNB is onair\n CASE STEP2:SA UE attach and start peak traffic
    log to console    SA UE attach successful\n CASE STEP3:start to collect Sherpa log
    &{logtype}     create dictionary    dcap={"type":["L2Ps_Sherpa"]}
    Log.Init     logtype=${logtype}
    sleep   20s
    Log.Collect
    MultiUE.CheckThoughput     UECFG=${uecfg}
    run keyword and continue on failure    DCAP.Extract_out_Log_Files   tracer=udptracer
    run keyword and continue on failure    DCAP.Decode_Sherpa_Logs
    run keyword and continue on failure    DCAP.Sherpa_Verify_DL_UL_Schedule
    MultiUE.StopDLTraffic      UECFG=${uecfg}
    MultiUE.StopULTraffic      UECFG=${uecfg}
    MultiUE.Detach             UECFG=${uecfg}

TC.CB006555_A_02_CORESET duration pattern modification due to lack of Type1-PDCCH availability in SA call
#    gNB.FormatBTSID
#    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}
#    gNB.ModifySCF    InputFile=${TL_S1_base_SCF}    OutputFile=${LOG_PATH}/6555_A02_SCF.xml
#    ...    ParameterToDelete=${PARAMS_TO_DELETE_6555_A02}
#    ...    MOsToAdd=${ADD_MOs_6555_A02}
#    ...    ParamterToModify=${PARAMS_TO_MODIFY_6555_A02}
#    ...    ListParamterToModify=${LIST_PARAMS_TO_MODIFY_6555_A02}
#    ...    ListToAdd=${LIST_TO_ADD_6555_A02}
    gNB.GenerateCaseSCF    InputFile=${TL_S1_base_SCF}    OutputFile=${LOG_PATH}/6555_A02_SCF.xml
    ...                    ResourceFolder=${CURDIR}
    ...                    ParameterToDelete=PARAMS_TO_DELETE_6555_A02
    ...                    MOsToAdd=ADD_MOs_6555_A02
    ...                    ParamterToModify=PARAMS_TO_MODIFY_6555_A02
    ...                    ListParamterToModify=LIST_PARAMS_TO_MODIFY_6555_A02
    ...                    ListToAdd=LIST_TO_ADD_6555_A02
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${0}
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${1}
    log to console    CASE STEP1:upload SCF,gNB start commission
    gNB.CommissionWithRetry    scf_file=${LOG_PATH}/6555_A02_SCF.xml    model=HBTE
    log to console    gNB commission successful end
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady
    log to console    gNB is onair\n check X2 link status until ready
#    gNB.Connect
#    gNB.CheckX2StatusUntilReady    dep_1514=Yes    alias=${ALIAS_ASIK_SLAVE}
#    gNB.Disconnect
    COAM_WebEM.CheckX2StatusUntilReady
    log to console    X2 link is available\n CASE STEP2:SA UE attach and start peak traffic
    UE.One_UE_Call_with_traffic    ue_index=${0}    Traffic_hold=True    imsi=${IMSI}    apn_address=${SA_APN}
    ...    throughput_dl=${CASE_INPUT_CB006555['Peak_Traffic_DL']}MKbits/sec
    ...    throughput_ul=${CASE_INPUT_CB006555['Peak_Traffic_UL']}MKbits/sec
    ...    check_throughput_dl=${CASE_INPUT_CB006555['Peak_Traffic_DL']*0.8}
    ...    check_throughput_ul=${CASE_INPUT_CB006555['Peak_Traffic_UL']*0.8}
    ...    duration_dl=${1200}
    log to console    SA UE attach successful\n CASE STEP3:NSA UE attach
    #delete argument attach_mode=5G_NSA,because spark is not stable with only detach and attach function
    UE.One_UE_Call_with_traffic    ue_index=${1}    Traffic_hold=True  imsi=${IMSI1}    apn_address=${NSA_APN}
    ...    ue_mode=NSA
    ...    throughput_dl=${CASE_INPUT_CB006555['Peak_Traffic_DL_NSA']}MKbits/sec
    ...    throughput_ul=${CASE_INPUT_CB006555['Peak_Traffic_UL_NSA']}MKbits/sec
    ...    check_throughput_dl=0          check_throughput_ul=0
    log to console    NSA UE successful\n CASE STEP4:check SA UE peak traffic again
    COAM_Admin.Login    alias=GNB_OAM
    power_ue.Check peak throughput    ue_type=${UE_TYPE}    theory_dl_peak=${CASE_INPUT_CB006555['Peak_Traffic_DL']}
        ...   theory_ul_peak=${CASE_INPUT_CB006555['Peak_Traffic_UL']}    total_time=10    interval=5s
        ...    duration_time_for_once=100s    acceptable_tput_percentage=0.8
    COAM_Admin.Logout   connection=GNB_OAM
    log to console    SA UE peak traffic is normal\n



Setup Suite For 6555
    TestSuite.Start
#    Import Variables   ${CFGFILE_PATH}/CB006555/Delta_SCF.py
    set suite variable   ${GoldenSCF_PATH}    ${GoldenSCF_ON_GIT}/${GoldenSCF}
#    set suite variable   ${DeltaPath}                ${CFGFILE_PATH}/CB006555/Delta_SCF.py
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
    set suite variable    ${TL_S1_base_SCF}     ${LOG_PATH}/TestLineSCF1Cell.xml
    Run Keyword And Ignore Error    PA.AdjustTheAttenuationValue
    ...    ports=${PA_PORTS[0]}    value=${0}    attenuator=${PA_INFO}
    Run Keyword And Ignore Error    PA.AdjustTheAttenuationValue
    ...    ports=${PA_PORTS[1]}    value=${0}    attenuator=${PA_INFO}

Teardown Suite For 6555
    TestSuite.Stop


Setup 6555 Case
    TestCase.Start
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Run Keyword And Ignore Error    BtsLog.StartBTSlogCollection

Teardown 6555 Case
#    COAM_WebEM.Login
#    Run Keyword And Ignore error    UE.One_UE_Stop_traffic_and_Detach
#    ...    ue_type=${UE_TYPE}    ue_index=${0}    ue_mode=SA    apn_address=${SA_APN}
#    Run Keyword And Ignore error    UE.One_UE_Stop_traffic_and_Detach
#    ...    ue_type=${UE_TYPE}    ue_index=${1}    ue_mode=NSA    apn_address=${NSA_APN}
#    Run Keyword And Ignore Error    COAM_WEBEM.LockUnlcokCell    cell_idx=1    timeout=60
#    Run Keyword And Ignore Error    COAM_WEBEM.LockUnlcokCell    cell_idx=2    timeout=60
#    COAM_WebEM.Logout
    Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog
    #gNB.Connect
    Run Keyword And Ignore Error    ssh.execute    command=killall -2 tcpdump    connection=${ALIAS_ASIK}
    Run Keyword And Ignore Error    ssh.execute    command=lxc-attach -n 0xe004 -- killall -2 tcpdump    connection=${ALIAS_ASIK}
    log     ${TEST STATUS}
    Run Keyword If  '${TEST STATUS}' == 'FAIL'        gNB.CollectSnapshot
    Run Keyword And Ignore Error    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=killall firefox
    Conn.ResetCache
    log to console    CASE DONE
    Run Keyword And Ignore Error    TestCase.Stop


#KW.Verify_Sherpa_Logs
##    [Arguments]    ${log_cheking_kws}
#    [Documentation]  verify each checkpoint for sherpa.
#    FOR    ${item}    IN     @{folders_for_decoded_sherpa_logs}
#        DCAP.Sherpa_Verify_DL_UL_Schedule    csv_filepath=${item}
#    END
