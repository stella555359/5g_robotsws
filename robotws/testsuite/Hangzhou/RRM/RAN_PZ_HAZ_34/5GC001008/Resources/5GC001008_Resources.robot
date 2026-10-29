*** Settings ***
Documentation     author: Li Yajie
...               contact: yajie.li@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC001008
Library           taf.transport.ssh    WITH NAME    csn
Library    taf.analyzer.pcap    WITH NAME   cap
Resource          ../../5GC000496_C/Resources/L3Call.robot
Library           taf.ue.prisma    WITH NAME    prisma
#Resource          ../../../../../resources/common/prisma_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
#Variables         ${CFGFILE_PATH}/Delta_SCF_1.py
#Variables         ${CFGFILE_PATH}/Delta_SCF_2.py
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.ue    WITH NAME    ute_ue
Library           ../../5GC000742/Resources/MTKUE_extend.py
Library           MTKUE_extend.MTKUE    WITH NAME   MTKUE
Resource           ../../5GC000752/Resources/MTKPC_common_keyword.robot
Library           ../../5GC000752/Resources/output2dict.py
Library           taf.hw.rf_attenuator    WITH NAME    PA
#Variables         ${CFGFILE_ON_GIT}/5GC001008/Delta_SCF.py
#Variables         ${CFGFILE_ON_GIT}/5GC001008/Delta_SCF_2.py
#Variables         ${CFGFILE_ON_GIT}/TLDelta.py




*** Variables ***
#${CFGFILE_ON_GIT}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
#${GoldenSCF_PATH}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/

#${TL_DeltaPath}          ${CFGFILE_PATH}/TLDelta.py
#${DeltaPath}           ${CFGFILE_PATH}/5GC001008/Delta_SCF.py
#${DeltaPath_2}           ${CFGFILE_PATH}/5GC001008/Delta_SCF_2.py

${initial_S1_SCF}         ${LOG_PATH}/TestLineSCF1Cell.xml
${initial_S11_SCF}        ${LOG_PATH}/TestLineSCF2Cell.xml
${initial_S111_SCF}       ${LOG_PATH}/TestLineSCF3Cell.xml


${SPARK_APN_IP}         ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${SPARK_APN_USERNAME}   ${tl.ues[0].iperf_details.ssh_connection_details.username}
${SPARK_APN_PASSWORD}    ${tl.ues[0].iperf_details.ssh_connection_details.password}
${SPARK_APN_PORT}    ${tl.ues[0].iperf_details.port}
${MODIFIED_SCF_B1}    ${LOG_PATH}/1008_B_2.xml
@{1008_B_2_files}    1008_B_NG_case2.pcap    1008_B_CPIF_case2.pcap

@{TwoNG_slice}    ngap.sST    ngap.sd
@{OneNG_slice}    ngap.sST
@{TwoF1_slice}    f1ap.sST    f1ap.sD
@{OneF1_slice}    f1ap.sST
@{TwoE1_slice}    e1ap.sST    e1ap.sD
@{OneE1_slice}    e1ap.sST

@{multiDRB_condition_expression}    f1ap.dRBID == 4    f1ap.dRBID == 5    f1ap.dRBID == 6
@{AMF_IDLE_Status}    IDLE    IDLE    deactivated    deactivated
@{AMF_CONNECTED_Status}    CONNECTED    CONNECTED    activated    activated

${mcc}            ${tl.core.mcc}
${mnc}            ${tl.core.mnc}

${LOG_PATH}             ${OUTPUT DIR}/Logs
#${CFGFILE_PATH}       /home/ute/TAF/cfgfile/1008

${MODIFIED_SCF_1}      ${LOG_PATH}/1008_PC2.xml
${MODIFIED_SCF_2}      ${LOG_PATH}/1008_PC5.xml
${MODIFIED_SCF_3}      ${LOG_PATH}/1008_PC8.xml
${MODIFIED_SCF_4}      ${LOG_PATH}/1008_PC7.xml
${MODIFIED_SCF_5}      ${LOG_PATH}/1008_EA6.xml
${MODIFIED_SCF_6}      ${LOG_PATH}/1008_EA10.xml
${MODIFIED_SCF_7}      ${LOG_PATH}/1008_PD10.xml
${MODIFIED_SCF_8}      ${LOG_PATH}/1008_E11.xml

@{item_PC1}    7116    7317    NgSetupStopRetry
@{item_PC2}    7116    7105    Cells of the TAC barred due to slicing criteria
@{1008_PC_8_files}    1008_PC_NG_case8.pcap    1008_PC_CPIF_case8.pcap

#${UE_TYPE}                  huawei_sigspark
${UE_TYPE}             ${tl.ues[0].capabilities[-1]}
#${UE_alias}                 UE_0

${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

${GNB1_initial_s1_SCF}         ${LOG_PATH}/TestLineSCF2Cell.xml
${GNB2_initial_s1_SCF}         ${LOG_PATH}/GNB2_TestLineSCF1Cell_SA.xml

${GNB1_2145_E_SCF}     /home/ute/TAF/cfgfile/1008/E_1_SBTS5G19_5g_pid12_classical.xml
${CPIF_LOG_NAME}    CPIF_add_SNSSAI.pcap

${MRBTS_ID}      ${tl.gnbs[0].instance_id}
${NRBTS_ID}      ${tl.gnbs[0].global_bts_id}
${MRBTS_ID_2}    ${tl.gnbs[1].instance_id}
${NRBTS_ID_2}    ${tl.gnbs[1].global_bts_id}

#${GNB1_distname_1}    ${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1
#${GNB1_distname_2}    ${MRBTS_ID}/${NRBTS_ID}/SNSSAI-2
#${GNB1_distname_3}    ${MRBTS_ID}/${NRBTS_ID}/SNSSAI-3
${GNB1_SERVEDAMF}    ${MRBTS_ID}/${NRBTS_ID}/SERVEDAMF-1

${GNB2_distname_1}    ${MRBTS_ID_2}/${NRBTS_ID_2}/SNSSAI-1
${GNB2_distname_2}    ${MRBTS_ID_2}/${NRBTS_ID_2}/SNSSAI-2

${ASIK_LMP_IP}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}           ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${UTE_IP}         ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}   ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}   ${tl.test_pc.default_ssh_connection_details.password}

${WEBUI_IP}          ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}        https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

${ENB_WEBUI_IP}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENBWEBUI_URL}    https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

${PB_ASIK_IP}       ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}       ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}     ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

#GNB1 RU2
${PB_5GRU_2_IP}       ${tl.gnbs[0].dus[0].rus[1].pdu_port.pdu.addr}
${PB_5GRU_2_PORT}     ${tl.gnbs[0].dus[0].rus[1].pdu_port.port_no}

${IMSI}                    ${tl.ues[0].imsi}

${SST}       129
${SD}        1
${tac}      210
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
${5GGNB2_RU1_ANT1}    ${7}
${5GGNB2_RU1_ANT2}    ${8}

#prisma

##${AMF_IP}                   ${tl.core.mme_ip}
#${PRISMA_IP}                ${tl.ues[0].airmosaic_ssh_connection_details.addr}
#${PRISMA_USERNAME}          ${tl.ues[0].airmosaic_ssh_connection_details.username}
#${PRISMA_PASSWORD}          ${tl.ues[0].airmosaic_ssh_connection_details.password}
#${tstm_IP}                  ${tl.ues[0].tstm_uu_ssh_connection_details.addr}
#${tstm_USERNAME}            ${tl.ues[0].tstm_uu_ssh_connection_details.username}
#${tstm_PASSWORD}            ${tl.ues[0].tstm_uu_ssh_connection_details.password}
#${LSU_UU}                   ${tl.ues[0].lsu_uu_ssh_connection_details.addr}
#${LSU_CRED}                 ${tl.ues[0].lsu_uu_ssh_connection_details.username}
#${LSU_PWD}                  ${tl.ues[0].lsu_uu_ssh_connection_details.password}


##################define these variable for convenient############################
${ALIAS_ASIK}               asik                                                ##
${ALIAS_ASIK_2}             asik2                                               ##
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
${ALIAS_wap2_AMF}           wap2_AMF                                            ##
${ALIAS_tstm}               TSTM                                                ##
${ALIAS_QC}                 QC                                                  ##
${ALIAS_UPF}                UPF                                                 ##
${ASIK_SSH_IP}              asik_ssh                                            ##
${UE_alias}                 UE_1                                                ##
${ALIAS_5GC}                5gc                                                 ##
${ALIAS_MTKPC}              MTKPC                                               ##
${ALIAS_APN}                APN                                                 ##
########################END of alias Define#######################################

*** Keywords ***
TC.5GC001008_EA_2_Online SNSSAIs addtion and it is supported by AMF
    Commission GNB with retry for 1RU    scf_file=${LOG_PATH}/TestLineSCF1Cell.xml
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    #Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    COAM_WebEM.Login
    COAM_WEBEM.LockUnlcokCell
    Modify SNSSAI Administrative state Parameters
    COAM_WebEM.Logout
    #gNB is only configured with 1 snssai
    Run Keyword And Continue On Failure    Commission GNB with retry for 1RU    scf_file=${LOG_PATH}/TestLineSCF1Cell.xml
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    Run Keyword And Continue On Failure    Check And Update AMFConf
    gNB.Connect
    #Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Run Keyword And Continue On Failure    Wireshark.StartCaptureLogFromContainer    nodename=CPIF
    ...    filename=${CPIF_LOG_NAME}
    Add SNSSAI parameter
    sleep    10s
    Run Keyword And Continue On Failure    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    Run Keyword And Continue On Failure    wireshark.DownloadLogToUTEFromContainer    filename=${CPIF_LOG_NAME}    nodename=CPIF
    Check SNSSAI status on webUI    dist_name=${Dist_name}/SNSSAI-2    status=enabled
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    COAM_WebEM.Login
    COAM_WEBEM.LockUnlcokCell
    COAM_WebEM.Logout
    Wireshark Check SNSSAI parameter    filename=${CPIF_LOG_NAME}
    gNB.Disconnect
    Run Keyword And Continue On Failure    Commission GNB with retry for 1RU    scf_file=${LOG_PATH}/TestLineSCF1Cell.xml

TC.5GC001008_PC_7_CellBarred alarm raised after lock the enabled slice
    Run Keyword And Ignore error    Process.Prepare for 1008 commission    func=COAM.Lock GNB1 all snssai via WEBUI
    gNB.GenerateCaseSCF    InputFile=${LOG_PATH}/TestLineSCF2Cell.xml    OutputFile=${MODIFIED_SCF_4}
    ...                    ResourceFolder=${CURDIR}
	...                    ParameterToDelete=PARAMS_TO_DELETE_1008_PC_case7
	...                    MOsToAdd=ADD_MOs_1008_PC_case7
	...                    ParamterToModify=PARAMS_TO_MODIFY_1008_PC_case7
	...                    ListParamterToModify=MODIFY_List_1008_PC_case7
	...                    ListToAdd=ADD_Lists_TO_MO_1008_PC_case7
#    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    gNB.ModifySCF    InputFile=${initial_S11_SCF}    OutputFile=${MODIFIED_SCF_4}
#    ...     ParameterToDelete=${PARAMS_TO_DELETE_1008_PC_case7}    ParamterToModify=${PARAMS_TO_MODIFY_1008_PC_case7}
#    gNB.Add parameters to scf    input_scf=${MODIFIED_SCF_4}    output_scf=${MODIFIED_SCF_4}
#    ...    parameters_lists=${PARAMS_TO_ADD_1008_1008_PC_case7}
    Set Test Variable    ${MODIFIED_SCF_4}   ${CFGFILE_PATH}/TL1109_golden_1008.xml
    Commission GNB with retry for 2RU    scf_file=${MODIFIED_SCF_4}
    Check 2cell status with reset
#    wireshark.Capture_CPIF_Pcap    filename=1008_PC_case7_CPIF.pcap
    COAM_WebEM.Login
    Modify Parameters of SNSSAI Administrative state    NewValue=Locked
    COAM.Check alarm via webui    item=${item_PC2}
    COAM_WebEM.Login
    COAM.Check slice operational disable state     dist_name=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1
    COAM_WebEM.Logout

TC.5GC001008_PC_8_CellBarred alarm cleared after unlock the slice supported by AMF

    Run Keyword And Ignore error    Process.Prepare for 1008 commission    func=COAM.Lock GNB1 all snssai via WEBUI
    gNB.GenerateCaseSCF    InputFile=${LOG_PATH}/TestLineSCF2Cell.xml    OutputFile=${MODIFIED_SCF_3}
    ...                    ResourceFolder=${CURDIR}
	...                    ParameterToDelete=PARAMS_TO_DELETE_1008_PC_case8
	...                    MOsToAdd=ADD_MOs_1008_PC_case8
	...                    ParamterToModify=PARAMS_TO_MODIFY_1008_PC_case8
	...                    ListParamterToModify=MODIFY_List_1008_PC_case8
	...                    ListToAdd=LIST_TO_ADD_1008_1008_PC_case8
#    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    gNB.ModifySCF    InputFile=${initial_S11_SCF}    OutputFile=${MODIFIED_SCF_3}
#    ...     ParameterToDelete=${PARAMS_TO_DELETE_1008_PC_case8}    ParamterToModify=${PARAMS_TO_MODIFY_1008_PC_case8}
#    ...     MOsToAdd=${ADD_MOs_1008_PC_case8}
#    ...     ListToAdd=${LIST_TO_ADD_1008_1008_PC_case8}

    Commission GNB with retry for 2RU    scf_file=${MODIFIED_SCF_3}
    Check 2cell status with reset

    COAM_WebEM.Login
    COAM.Check slice operational disable state    dist_name=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1
    COAM.Check slice operational enable state    dist_name=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-2
    COAM_WebEM.Logout
#
#    COAM.Check alarm via webui    item=${item_PC2}
#    Adjust Attenuation for RU    RU=RU1    value=${0}
#    Adjust Attenuation for RU    RU=RU2    value=${127}
#    Adjust Attenuation for RU    RU=RU3    value=${127}
#    Process for one PDU of Spark    filename=${1008_PC_8_files}

    COAM_WebEM.Login
    COAM.Unlock one SNSSAI AdministrativeState    dist_name=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1
    COAM_WebEM.Logout

    ${alarm_check}    run keyword and return status    COAM.Check alarm via webui    item=${item_PC2}
    should be true    '${alarm_check}' == 'False'
    COAM_WebEM.Login
    COAM.Check slice operational enable state    dist_name=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1
    COAM_WebEM.Logout

TC.5GC001008_B_2_Successful DL and UL data transmission with two PDU session with the same slice type
    Check GNB cell with reset for 1RU
    PA.AdjustAttenuationValueByGroups
#    Adjust Attenuation for RU    RU=RU1    value=${0}
#    Adjust Attenuation for RU    RU=RU2    value=${127}
#    Adjust Attenuation for RU    RU=RU3    value=${127}
##    Process for two PDU of Spark    filename=${1008_B_2_files}    apn2=wap1.nokia.com
    Process for two PDU of Spark    filename=${1008_B_2_files}

#    Analyse fp0 pcap for two pdu session    filename=1008_B_NG_case2.pcap
#    ...    filter=nas_5gs.sm.message_type == 0xc2 && nas_5gs.cmn.dnn == "wap4.nokia.com"
#    wireshark.Analyse cpif pcap for two pdu session    filename=1008_B_CPIF_case2.pcap
#    ...    filter=nas_5gs.sm.message_type == 0xc2 && nas_5gs.cmn.dnn == "wap1.nokia.com"
#    ...    PDU_sst=${PDU_sst}    PDU_sd=${PDU_sd}    PDU_value=${PDU_value}

    Analyse fp0 pcap for one pdu session    filename=1008_B_NG_case2.pcap
    ...    filter=nas_5gs.sm.message_type == 0xc2
    Analyse cpif pcap for pdu session    filename=1008_B_CPIF_case2.pcap

    run keyword And Ignore error    Get Bcase1 PDU ID
    ${wireshark_release_PDU1}    run keyword and return status    Check PDU release via wireshark
    ...    filename=1008_B_NG_case2.pcap    PDU_ID=${Bcase1_PDU1_ID}

#    run keyword And Ignore error    Get Bcase2 PDU ID
#    ${wireshark_release_PDU1}    run keyword and return status    Check PDU release via wireshark
#    ...    filename=1008_B_NG_case2.pcap    PDU_ID=${Bcase2_PDU1_ID}
#    ${wireshark_release_PDU2}    run keyword and return status    Check PDU release via wireshark
#    ...    filename=1008_B_NG_case2.pcap    PDU_ID=${Bcase2_PDU2_ID}
    should be true    ${wireshark_release_PDU1} or ${SPARK_release_PDU1}
#    should be true    ${wireshark_release_PDU2} or ${SPARK_release_PDU2}

TC.5GC001008_EA_6_Unable to online delete SNSSAI that in enabled state
    Run Keyword And Ignore error    Process.Prepare for 1008 commission    func=COAM.Lock GNB1 all snssai via WEBUI
    gNB.GenerateCaseSCF    InputFile=${LOG_PATH}/TestLineSCF2Cell.xml    OutputFile=${MODIFIED_SCF_5}
    ...                    ResourceFolder=${CURDIR}
	...                    ParameterToDelete=PARAMS_TO_DELETE_1008_EA_case6
	...                    MOsToAdd=ADD_MOs_1008_EA_case6
	...                    ParamterToModify=PARAMS_TO_MODIFY_1008_EA_case6
	...                    ListParamterToModify=MODIFY_List_1008_EA_case6
	...                    ListToAdd=LIST_TO_ADD_1008_EA_case6
#    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    gNB.ModifySCF    InputFile=${initial_S11_SCF}    OutputFile=${MODIFIED_SCF_5}
#    ...     ParameterToDelete=${PARAMS_TO_DELETE_1008_EA_case6}    ParamterToModify=${PARAMS_TO_MODIFY_1008_EA_case6}
#    ...     MOsToAdd=${ADD_MOs_1008_EA_case6}
#    ...     ListToAdd=${LIST_TO_ADD_1008_EA_case6}
    Commission GNB with retry for 1RU    scf_file=${MODIFIED_SCF_5}
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady

    COAM_WebEM.Login
    ${sd_value_1}    COAM_WebEM.GetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1    abbr=Slice Differentiator
    ${sst_value_1}    COAM_WebEM.GetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1    abbr=Slice Service Type

    COAM.RemoveElement   dist_name=${MRBTS_ID}/${NRBTS_ID}/TRACKINGAREA-210
    ...       filter_param=List of SNSSAI distinguished names    node_index=1
    ${result}     COAM_WebEM.ValidateAndActiveParameters
    should be true    "${result}"=="False"
    ${sd_value_2}    COAM_WebEM.GetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1    abbr=Slice Differentiator
    ${sst_value_2}    COAM_WebEM.GetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1    abbr=Slice Service Type

    Should Be Equal    ${sd_value_1}     ${sd_value_2}
    Should Be Equal    ${sst_value_1}    ${sst_value_2}

    COAM_WebEM.Logout

TC.5GC001008_EA_8_Unable to delete the last SNSSAI of TAC
    Run Keyword And Ignore error    Process.Prepare for 1008 commission    func=COAM.Lock GNB1 all snssai via WEBUI
    Commission GNB with retry for 1RU    scf_file=${LOG_PATH}/TestLineSCF1Cell.xml
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady

    COAM_WebEM.Login
    ${sd_value_1}    COAM_WebEM.GetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1    abbr=Slice Differentiator
    ${sst_value_1}    COAM_WebEM.GetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1    abbr=Slice Service Type

    COAM.RemoveElement   dist_name=${MRBTS_ID}/${NRBTS_ID}/TRACKINGAREA-210
    ...       filter_param=List of SNSSAI distinguished names    node_index=0
    ${result}     COAM_WebEM.ValidateAndActiveParameters
    should be true    "${result}"=="False"

    ${sd_value_2}    COAM_WebEM.GetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1    abbr=Slice Differentiator
    ${sst_value_2}    COAM_WebEM.GetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1    abbr=Slice Service Type

    Should Be Equal    ${sd_value_1}     ${sd_value_2}
    Should Be Equal    ${sst_value_1}    ${sst_value_2}

    COAM_WebEM.Logout

TC.5GC001008_EA_10_cell change from barred to unbarred after a new snssai addion in TAC which is supported by AMF
    Run Keyword And Ignore error    Process.Prepare for 1008 commission    func=COAM.Lock GNB1 all snssai via WEBUI
    gNB.GenerateCaseSCF    InputFile=${LOG_PATH}/TestLineSCF2Cell.xml    OutputFile=${MODIFIED_SCF_6}
    ...                    ResourceFolder=${CURDIR}
	...                    ParameterToDelete=PARAMS_TO_DELETE_1008_EA_case10
	...                    MOsToAdd=ADD_MOs_1008_EA_case10
	...                    ParamterToModify=PARAMS_TO_MODIFY_1008_EA_case10
	...                    ListParamterToModify=MODIFY_List_1008_EA_case10
	...                    ListToAdd=LIST_TO_ADD_1008_EA_case10
#    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    gNB.ModifySCF    InputFile=${initial_S11_SCF}    OutputFile=${MODIFIED_SCF_6}
#    ...     ParameterToDelete=${PARAMS_TO_DELETE_1008_EA_case10}    ParamterToModify=${PARAMS_TO_MODIFY_1008_EA_case10}
#    ...     MOsToAdd=${ADD_MOs_1008_EA_case10}
#    ...     ListToAdd=${LIST_TO_ADD_1008_EA_case10}

    Commission GNB with retry for 2RU    scf_file=${MODIFIED_SCF_6}
    Check 2cell status with reset

    Adjust Attenuation for RU    RU=RU1    value=${127}
    Adjust Attenuation for RU    RU=RU2    value=${0}
    Adjust Attenuation for RU    RU=RU3    value=${127}
    Adjust GNB2_RU1 Attenuation to ${127}

    Spark.Check cell status from UE side    name=1008_EA_10.xml
    ...    expression=mib.cellBarred    expect_value=Barred    type='other'

    COAM_WebEM.Login
    Add SNSSAI parameter
    Check SNSSAI status on webUI    dist_name=${Dist_name}/SNSSAI-2    status=enabled
    COAM_WebEM.Logout

    Spark.Check cell status from UE side    name=1008_EA_10.xml
    ...    expression=mib.cellBarred    expect_value=notBarred    type='other'

TC.5GC001008_PD_10_Verify MEAS_PERIOD_NR_PDCP_SLICE when gNB configured with sst=1 sd=null and AMF configured with sst=1 sd = 0xffffff
    #before modify snssai shue lock cell and snssai Administrative state = locked
    Run Keyword And Ignore error    Process.Prepare for 1008 commission    func=COAM.Lock GNB1 all snssai via WEBUI
    gNB.GenerateCaseSCF    InputFile=${LOG_PATH}/TestLineSCF2Cell.xml    OutputFile=${MODIFIED_SCF_7}
    ...                    ResourceFolder=${CURDIR}
	...                    ParameterToDelete=PARAMS_TO_REMOVE_1008_PD_10
	...                    ParamterToModify=PARAMS_TO_MODIFY_1008_PD_10
	gNB.CommissionWithRetry    scf_file=${MODIFIED_SCF_7}
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
#    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    gNB.ModifySCFAndCommissionAndCheckOnair    InputFile=${initial_S11_SCF}    OutputFile=${MODIFIED_SCF_7}
#    ...    ParamterToModify=${PARAMS_TO_MODIFY_1008_PD_10}    ParamterToDelete=${PARAMS_TO_REMOVE_1008_PD_10}
    sleep    10min
    Check MEAS_PERIOD_NR_PDCP_SLICE from gNB

TC.5GC001008_PC_10_Unsucessful SNSSAI modification before lock the SNSSAI
    Run Keyword And Ignore error    Process.Prepare for 1008 commission    func=COAM.Lock GNB1 all snssai via WEBUI
    Commission GNB with retry for 1RU    scf_file=${LOG_PATH}/TestLineSCF1Cell.xml
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady

    COAM_WebEM.Login

    ${sd_value_1}    COAM_WebEM.GetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1    abbr=Slice Differentiator
    ${sst_value_1}    COAM_WebEM.GetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1    abbr=Slice Service Type
    COAM_WebEM.SetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1    abbr=Slice Differentiator    value=123
    COAM_WebEM.SetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1    abbr=Slice Service Type    value=201

    ${result}    COAM_WebEM.ValidateAndActiveParameters
    should be true    "${result}"=="False"

    ${sd_value_2}    COAM_WebEM.GetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1    abbr=Slice Differentiator
    ${sst_value_2}    COAM_WebEM.GetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1    abbr=Slice Service Type

    Should Be Equal    ${sd_value_1}     ${sd_value_2}
    Should Be Equal    ${sst_value_1}    ${sst_value_2}

    Run Keyword And Ignore Error    COAM_WebEM.Logout

TC.5GC001008_PD_11_Verify NUMBER_OF_SA_SLICE_USERS and SA_NGBR_DRB_CU_SUCC_SLICE in PDU session setup procedure
   #prepare scf for case, main to decrease the counter's timer in order to checker coutner easier
    Run Keyword And Ignore error    Process.Prepare for 1008 commission    func=COAM.Lock GNB1 all snssai via WEBUI
    gNB.GenerateCaseSCF    InputFile=${LOG_PATH}/TestLineSCF2Cell.xml    OutputFile=${MODIFIED_SCF_7}
    ...                    ResourceFolder=${CURDIR}
	...                    ParameterToDelete=PARAMS_TO_REMOVE_1008_PD_11
	...                    ParamterToModify=PARAMS_TO_MODIFY_1008_PD_11
	gNB.CommissionWithRetry    scf_file=${MODIFIED_SCF_7}
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
#    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    gNB.ModifySCFAndCommissionAndCheckOnair    InputFile=${initial_S11_SCF}    OutputFile=${MODIFIED_SCF_7}
#    ...    ParamterToModify=${PARAMS_TO_MODIFY_1008_PD_11}    ParamterToDelete=${PARAMS_TO_REMOVE_1008_PD_11}


    #make UE attach and PDU session establish, traffic is no need
    Run Keyword And Continue On Failure  power_ue.Prepare UE    ue_type=${UE_TYPE}
    sleep    10s
    Run Keyword And Continue On Failure    power_ue.UE Attach    ue_type=${UE_TYPE}

    #sleep to waiting for counter increase
    sleep    10min
    Check NUMBER_OF_SA_SLICE_USERS from gNB
    Check SA_NGBR_DRB_CU_SUCC_SLICE from gNB

TC.5GC001008_K_1_Successful initial context setup with one PDU session in L3Call
    #prepare gNB environment
    Run Keyword And Ignore error    Process.Prepare for 1008 commission    func=COAM.Lock GNB1 all snssai via WEBUI
    Commission GNB with retry for 1RU    scf_file=${LOG_PATH}/TestLineSCF1Cell.xml
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady

    #start tcpdump
    gNB.connect
    Wireshark.StartCaptureNGLog    filename=1008_K_case1.pcap

    #L3call
    Run Keyword And Continue On Failure  power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=1
    sleep    10s
    Run Keyword And Continue On Failure    power_ue.UE Attach    ue_type=${UE_TYPE}    ue_index=1
    Run Keyword And Continue On Failure    power_ue.Start traffic    ue_index=1     ue_type=${UE_TYPE}    direction=dl
    ...    throughput=10MKbits/sec    duration=600    apn_address=${SA_APN}    ue_mode=SA
    Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${UE_TYPE}   ue_index=1    direction=ul
    ...    throughput=5MKbits/sec    duration=600    apn_address=${SA_APN}    ue_mode=SA
    sleep    30s
    Run Keyword And Continue On Failure    power_ue.Check throughput    ue_type=${UE_TYPE}    ue_index=1     direction=dl    throughput=5
    Run Keyword And Continue On Failure    power_ue.Check throughput    ue_type=${UE_TYPE}    ue_index=1     direction=ul    throughput=2

    #wireshak check      Wireshark.Download_NG_Pcap    filename=1008_E_NG_case4.pcap
    Wireshark.StopCaptureNGLog
    Wireshark.DownloadLogToUTE    filename=1008_K_case1.pcap
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=1008_K_case1.pcap    filter=ngap.id == 0 && ngap.procedureCode == 14

    ${PDU_sst}      Wireshark.GetElementValueAndCompareWithEmpty    check_param=ngap.sST
    ${PDU_sd}      Wireshark.GetElementValueAndCompareWithEmpty    check_param=ngap.sD
    should be equal    ${PDU_sst}   ${01}
    should be equal    ${PDU_sd}    ${d1:43:a5}

TC.5GC001008_E_11_Successful snssai modification in an existing TAC
#prepare gNB, mainly to configure gNB with two SNSSAI
    Run Keyword And Ignore error    Process.Prepare for 1008 commission    func=COAM.Lock GNB1 all snssai via WEBUI
    gNB.GenerateCaseSCF    InputFile=${LOG_PATH}/TestLineSCF2Cell.xml    OutputFile=${MODIFIED_SCF_8}
    ...                    ResourceFolder=${CURDIR}
	...                    ParameterToDelete=PARAMS_TO_DELETE_1008_E_case11
	...                    ParamterToModify=PARAMS_TO_MODIFY_1008_E_case11
	...                    MOsToAdd=ADD_MOs_1008_E_case11
	...                    ListToAdd=LIST_TO_ADD_1008_E_case11
#    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    gNB.ModifySCF    InputFile=${initial_S11_SCF}    OutputFile=${MODIFIED_SCF_8}
#    ...     ParameterToDelete=${PARAMS_TO_DELETE_1008_E_case11}    ParamterToModify=${PARAMS_TO_MODIFY_1008_E_case11}
#    ...     MOsToAdd=${ADD_MOs_1008_E_case11}
#    ...     ListToAdd=${LIST_TO_ADD_1008_E_case11}
    Commission GNB with retry for 1RU    scf_file=${MODIFIED_SCF_8}
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady

    COAM_WebEM.Login
#lock one SNSSAI
    Run Keyword And Continue On Failure    COAM.Lock one SNSSAI AdministrativeState    dist_name=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-2
#modify value
    COAM_WebEM.SetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-2
    ...    abbr=Slice Service Type    value=233    Abbreviation=sst
    COAM_WebEM.ValidateAndActiveParameters
#unlock SNSSAI
    COAM.Unlock one SNSSAI AdministrativeState    dist_name=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-2
#check operation state
    Check SNSSAI status on webUI    dist_name=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-2    status=disabled
#check sst new value
    COAM_WebEM.Login
    ${sst_value}    COAM_WebEM.GetParameterValue   distName=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-2    abbr=Slice Service Type
    Should be equal   ${sst_value}   233

    Run Keyword And Ignore Error    COAM_WebEM.Logout

Check MEAS_PERIOD_NR_PDCP_SLICE from gNB
    wait until keyword succeeds    3x    1min    COAM_WebEM.Login
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55328C00001    target_value=300
    COAM_WebEM.Logout

Check NUMBER_OF_SA_SLICE_USERS from gNB
    wait until keyword succeeds    3x    1min    COAM_WebEM.Login
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55149C00022    target_value=1
    COAM_WebEM.Logout

Check SA_NGBR_DRB_CU_SUCC_SLICE from gNB
    wait until keyword succeeds    3x    1min    COAM_WebEM.Login
    COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55149C00020    target_value=1
    COAM_WebEM.Logout

COAM_WEBEM.CheckBTSConutersWithConditioanalTraget
    [Arguments]    ${counter_id}   ${target_value}
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_bts_counters_info   counter_id=${counter_id}
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    should be true     ${values[-1]}==${target_value}

COAM_WEBEM.LockAllCell
    [Arguments]   ${timeout}=60
    ${cell_count}=    selenium_coam.get_number_of_cells
     FOR    ${i}    IN RANGE    ${cell_count}
        ${cell_info}=    selenium_coam.get_cell_info    cell_idx=${i+1}
        run keyword if    ${cell_info}!="None"and'${cell_info['Status']['Administrative state']}'=="Unlocked"
        ...                selenium_coam.lock_cell    cell_idx=${i+1}    timeout=${timeout}
        Sleep  2 mins
     END

Modify SNSSAI Administrative state Parameters
    [Arguments]    ${DistName}=${DIST_NAME}    ${FilterParam}=Administrative state    ${NewValue}=Locked
    COAM_WEBEM.ModifyParameters    DistName=${DistName}/SNSSAI-1    FilterParam=${FilterParam}    NewValue=${NewValue}
    Run Keyword And Ignore Error    COAM_WEBEM.ModifyParameters    DistName=${DistName}/SNSSAI-2
    ...    FilterParam=Administrative state    NewValue=Locked
    COAM_WebEM.ValidateAndActiveParameters

Check And Update AMFConf
    [Arguments]   ${testslice}=Testslice213    ${sst}=${SST}    ${sd}=${SD}
    Connect to 5GC
    ${test_slice_presence}=    csn.execute    command=cmm snssai list | grep ${testslice}    connection=${ALIAS_5GC}
    run keyword if   '${test_slice_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
    ...    Send AMFConfUpdate from AMF by adding slice    testslice=${testslice}    sst=${sst}    sd=${sd}
    Disconnect from 5GC

Wireshark Check SNSSAI parameter
    [Arguments]    ${filename}
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=${filename}
    ...    filter=ngap.RANConfigurationUpdate_element && ngap.sST == 81 && ngap.sD == 00:00:01
    Run Keyword And Continue On Failure    Wireshark.CheckExpression    ngap.procedureCode == 35
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=${filename}
    ...    filter=f1ap.GNBDUConfigurationUpdate_element && f1ap.sST == 81 && f1ap.sD == 00:00:01
    Run Keyword And Continue On Failure    Wireshark.CheckExpression    f1ap.procedureCode == 3

Check SNSSAI status on webUI
    [Arguments]    ${dist_name}=${distname_id_1}/SNSSAI-1   ${status}=enabled
    Check parameter should be correct for gNB    value=${status}    url=${WEBUI_URL}
    ...    dist_name=${dist_name}    filter_param=Operational state

COAM_WEBEM.ModifyParameters
    [Arguments]    ${DistName}    ${FilterParam}   ${NewValue}
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${DistName}    filter_param=${FilterParam}    new_value=${NewValue}

Send AMFConfUpdate from AMF by adding slice
    [Arguments]   ${testslice}=Testslice213    ${sst}=${SST}    ${sd}=${SD}
    csn.execute    command=cmm snssai create --name ${testslice} --sliceServiceType ${sst} --sliceDifferentiator 00000${sd}
    ...    connection=${ALIAS_5GC}
    csn.execute    command=cmm snssaiListItem create --snssaiListName Snssai1 --snssaiName ${testslice}    connection=${ALIAS_5GC}
    csn.execute    command=cmm snssaiToDnn create --snssaiToDnnListName DNN1 --snssaiName ${testslice} --dataNetworkName wap1.nokia.com
    ...    connection=${ALIAS_5GC}
    ${test_slice_presence}=    csn.execute    command=cmm snssai list | grep ${testslice}    connection=${ALIAS_5GC}
    log    ${test_slice_presence}

Add SNSSAI parameter
    COAM_WebEM.Login
    sleep    5s
    #add SNSSAI-2
    selenium_coam.add_object    object_name=${nrbtsid}    object_class_name=SNSSAI    id_value=2
    selenium_coam.set_parameter_value    dist_name=${Dist_name}/SNSSAI-2    filter_param=Slice Service Type    new_value=${SST}
    selenium_coam.set_parameter_value    dist_name=${Dist_name}/SNSSAI-2    filter_param=Slice Differentiator    new_value=${SD}
    selenium_coam.set_parameter_value    dist_name=${Dist_name}/SNSSAI-2    filter_param=Administrative state    new_value=Unlocked
    selenium_coam.add_element    dist_name=${Dist_name}/SNSSAI-2    filter_param=List of NRPLMN distinguished names
    selenium_coam.set_parameter_value    dist_name=${Dist_name}/SNSSAI-2    filter_param=List of NRPLMN distinguished names
    ...    new_value=${MRBTS_ID}/${NRBTS_ID}/NRPLMN-1    node_index=${0}
    #add SNSSAI-2 IN TRACKINGAREA-210
    selenium_coam.add_element    dist_name=${MRBTS_ID}/${NRBTS_ID}/TRACKINGAREA-${tac}    filter_param=List of SNSSAI distinguished names
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/TRACKINGAREA-${tac}    filter_param=List of SNSSAI distinguished names
    ...    new_value=${Dist_name}/SNSSAI-2    node_index=${1}

    selenium_coam.validate_plan
    sleep    5s
    ${output}    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
    sleep    5s
    COAM_WebEM.Logout
    [Return]    ${output}

Check parameter should be correct for gNB
    [Arguments]    ${value}    ${url}    ${dist_name}    ${filter_param}
    COAM_WebEM.Login
    sleep    5s
    ${Para_value}=    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}
    COAM_WebEM.Logout
    Should Be Equal    ${Para_value}    ${value}

Refine PA Port
#    ${PORTS}    Get Dictionary Keys    ${tl.attenuator.attenuator_ports}
#    ${PORTS}    Get Dictionary Keys    ${tl.attenuator.attenuation_port_numbers}
    Set Suite Variable     ${5GRU1_ANT1}    ${PA_PORT[0]}
    Set Suite Variable     ${5GRU1_ANT2}    ${PA_PORT[1]}
    Set Suite Variable     ${5GRU2_ANT1}    ${PA_PORT[2]}
    Set Suite Variable     ${5GRU2_ANT2}    ${PA_PORT[3]}
    Set Suite Variable     ${5GRU3_ANT1}    ${PA_PORT[4]}
    Set Suite Variable     ${5GRU3_ANT2}    ${PA_PORT[5]}
    Set Suite Variable     ${5GGNB2_RU1_ANT1}    ${PA_PORT[6]}
    Set Suite Variable     ${5GGNB2_RU1_ANT2}    ${PA_PORT[7]}
############################################### Commisssion basic Operation ############################################
Commission GNB with retry for 1RU
    [Arguments]    ${scf_file}
    ${commission_check}    run keyword and return status    gNB.Commission    scf_file=${scf_file}    oam_type=COAM    timeout=900
    Run keyword if    ${commission_check}== True    Log    continue next steps
    Run keyword if    ${commission_check}== False    run keywords     Power.ResetgNB    model=HBTE
                      ...    AND    Power.Reset5GRU    model=HBTE
                      ...    AND    sleep    4min
                      ...    AND    gNB.Commission    scf_file=${scf_file}    oam_type=COAM    timeout=900

Commission GNB with retry for 2RU
    [Arguments]    ${scf_file}
    ${commission_check}    run keyword and return status    gNB.Commission    scf_file=${scf_file}    oam_type=COAM    timeout=900
    Run keyword if    ${commission_check}== True    Log    continue next steps
    Run keyword if    ${commission_check}== False    run keywords     Power.ResetgNB
                      ...    model=${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}
                      ...    AND    Power.Reset5GRU    model=${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.vendor}
                      ...    AND    Power.Reset5G_RU2  model=${tl.gnbs[0].dus[0].rus[1].pdu_port.pdu.vendor}
                      ...    AND    sleep    4min
                      ...    AND    gNB.Commission    scf_file=${scf_file}    oam_type=COAM    timeout=900

Power.Reset5G_RU2
    [Arguments]    ${model}=HBTE
    facom.PowerOnOff    pdu_ip=${PB_5GRU_2_IP}    Port_Number=${PB_5GRU_2_PORT}     Action=power_off    model=${model}
    facom.PowerOnOff    pdu_ip=${PB_5GRU_2_IP}    Port_Number=${PB_5GRU_2_PORT}     Action=power_on    model=${model}

Remove Elements From Scf
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load Scf    ${input_scf}
    FOR    ${item}    IN    @{parameters_lists}
        scf.Remove Element From Scf    dist_name=${item}[dist_name]    p_name=${item}[p_name]
    END
    scf.Save Scf    ${output_scf}


########################################### gNB basic operation ########################################################
Process.Cellsetup
    Conn.ResetCache
    gNB.Connect
    Check Cell On Air Via WEBUI
    gNB.Disconnect
    Sleep  10s

Check Cell On Air Via WEBUI
    wait until keyword succeeds   12x   2min    COAM_Admin.Login
    wait until keyword succeeds   12x   2min    COAM_Admin.CheckBTSOnAir
    COAM_Admin.Logout

Fail if cell not on air
    ${cell_check}    run keyword and return status    Process.Cellsetup
    Run keyword if    ${cell_check}== False    Fail   GNB cell not air

Check GNB cell with reset for 1RU
    ${cell_check}    run keyword and return status    Process.Cellsetup
    Run keyword if    ${cell_check}== False    run keywords    Power.ResetgNB    model=HBTE
     ...    AND    Power.Reset5GRU    model=HBTE
     ...    AND    Fail if cell not on air
     ...    ELSE    Log    continue the next steps

Setup 1008 case suite
#    Run Keyword And Ignore Error    Import Variables      ${CFGFILE_PATH}/Delta_SCF_1.py
#    Run Keyword And Ignore Error    Import Variables      ${CFGFILE_PATH}/Delta_SCF_2.py
#    Import Variables      ${CFGFILE_PATH}/5GC001008/Delta_SCF.py
#    Import Variables      ${CFGFILE_PATH}/5GC001008/Delta_SCF_2.py
    TestSuite.Start
#    set suite variable    ${TL_DeltaPath}          ${CFGFILE_PATH}/TLDelta.py
#    set suite variable    ${DeltaPath}           ${CFGFILE_PATH}/5GC001008/Delta_SCF.py
#    set suite variable    ${DeltaPath_2}           ${CFGFILE_PATH}/5GC001008/Delta_SCF_2.py
#    Refine PA Port
    Create Log Directories1
    set suite variable    ${Log_PATH_Artifactory}    /opt/ute/workspace/CIT/Master/Case_Logs
    set suite variable   ${OAM_TYPE}    COAM
    gNB.GenerateTestLineSCFs
#    gNB.FormatBTSID
#	gNB.Generate TL SCF    GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}    TLDelta_PATH=${CFGFILE_PATH}
#    ...            TestLineSCF_cell_num=${1}   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    gNB.Generate TL SCF    GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}    TLDelta_PATH=${CFGFILE_PATH}
#    ...            TestLineSCF_cell_num=${2}   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    gNB.Generate TL SCF    GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}    TLDelta_PATH=${CFGFILE_PATH}
#    ...            TestLineSCF_cell_num=${3}   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}

    Conn.ResetCache
    gNB.SetLoggingSeverity    LoggingSeverity=debug
#    GNB.SwconfigReplace  file_path=${CFGFILE_PATH}/5GC001008
Setup 1008 case suite temp
    Run Keyword And Ignore Error    Import Variables      ${CFGFILE_PATH}/Delta_SCF_1.py
    Run Keyword And Ignore Error    Import Variables      ${CFGFILE_PATH}/Delta_SCF_2.py
    Import Variables      ${CFGFILE_PATH}/5GC001008/Delta_SCF.py
    Import Variables      ${CFGFILE_PATH}/5GC001008/Delta_SCF_2.py

    TestSuite.Start
    set suite variable    ${TL_DeltaPath}          ${CFGFILE_PATH}/TLDelta.py
    set suite variable    ${DeltaPath}           ${CFGFILE_PATH}/5GC001008/Delta_SCF.py
    set suite variable    ${DeltaPath_2}           ${CFGFILE_PATH}/5GC001008/Delta_SCF_2.py
    Refine PA Port
    Create Log Directories1
    set suite variable    ${Log_PATH_Artifactory}    /opt/ute/workspace/CIT/Master/Case_Logs
    set suite variable   ${OAM_TYPE}    COAM
    gNB.FormatBTSID
    run    cp ${CFGFILE_PATH}/TestLineSCF2Cell_Both.xml ${LOG_PATH}/TestLineSCF2Cell_Both.xml
    run    cp ${CFGFILE_PATH}/TestLineSCF2Cell_Both.xml ${LOG_PATH}/TestLineSCF1Cell_Both.xml
    Conn.ResetCache
    gNB.SetLoggingSeverity    LoggingSeverity=debug

Teardown Suite
    TestSuite.Stop

Teardown Suite For 1008
    Teardown Suite
    Suite Teardown for 1008 GNB1

Create Log Directories1
    Create Directory    ${LOG_PATH}

Clear Python and ELT in MTK CtrlPC
     [Arguments]  ${elt_path}=${ELT_PATH}
     Connect MTK CtrlPC
     ${pythonCnt}  Conn.Execute  cmd=ps -Wef | grep python |grep -v grep|awk '{print$2}'|awk 'END{print NR}'  alias=${ALIAS_MTKPC}
     FOR    ${i}    IN RANGE    ${pythonCnt}
         ${PID1}  Conn.Execute  cmd=ps -Wef|grep python|awk '{{print $2}}'|head -n 1  alias=${ALIAS_MTKPC}
         Log  message=Killing ${i+1}st python process with PID ${PID1}.
         Conn.Execute   cmd=/bin/kill -f ${PID1.strip()}   alias=${ALIAS_MTKPC}
     END
     Conn.Execute  cmd=ps -Wef | grep python |grep -v grep    alias=${ALIAS_MTKPC}
     ${PID2}  Conn.Execute  cmd=ps -Wef|grep "ELT\.exe"|awk '{{print $2}}'|head -n 1  alias=${ALIAS_MTKPC}
     Conn.Execute  cmd=/bin/kill -f ${PID2.strip()}  alias=${ALIAS_MTKPC}
     Conn.Execute  cmd=cd ${elt_path}/Temp;ls |grep "\.tmp" |xargs rm -rf  alias=${ALIAS_MTKPC}
     Disconnect MTK CtrlPC

Setup Case
    TestCase.Start
    Start BTSlogs Collection

Teardown 1008 case
    [Arguments]   ${connection}=COAM
    TestCase.Stop
    Run Keyword And Ignore Error    Stop BTSlogs Collection and get logs
    Run Keyword And Ignore Error    Backup current SCF
    gNB.Connect
    Run Keyword And Ignore Error    kill GNB wireshark process
    log     ${TEST STATUS}
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    Collect logs
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect logs
    Run Keyword And Ignore Error    Clean GNB wireshark log
    Run Keyword And Ignore Error    kill admin process
    Run Keyword And Ignore Error    run   command=killall firefox
    Conn.ResetCache

kill GNB wireshark process
    Run Keyword And Ignore Error    ssh.execute    command=killall -2 tcpdump    connection=${ALIAS_ASIK}
    ${container}    gnb.get_container_id    nodename=CPIF
    Run Keyword And Ignore Error    ssh.execute    command=lxc-attach -n ${container} -- killall -2 tcpdump    connection=${ALIAS_ASIK_SLAVE}

Collect logs
#    ${gNB_logName}=    catenate    SEPARATOR=_    ${TEST NAME.replace(" ", "_")}   gNB.log
#    Run Keyword And Ignore Error    gnb.collectlog    logName=${gNB_logName}
#    Run Keyword And Ignore Error    run    command=sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
#    Run Keyword And Ignore Error    run    command=sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    Collect snapshot via webui

Clean GNB wireshark log
    [Arguments]
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.Execute  cmd=rm -rf /ffs/run/config/toor4nsn/1008*.pcap   alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}

kill admin process
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9

Collect snapshot via webui
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}

Check HW status
    COAM_WebEM.Login
    wait until keyword succeeds    10x    2min    COAM.CheckHWStatus
    COAM_WebEM.Logout
    sleep    3min

COAM.CheckHWStatus
    ${ASIK_info}    selenium_coam.get_asik_info
    should be equal   ${ASIK_info['Status']['Availability status']}    Online
    should be equal   ${ASIK_info['Status']['Operational state']}    Enabled

    ${ABIL_info}    selenium_coam.get_abil_info
    should be equal   ${ABIL_info['Status']['Availability status']}    Online
    should be equal   ${ABIL_info['Status']['Operational state']}    Enabled



Suite Teardown for 1008 GNB1
    run keyword and ignore error    COAM_WebEM.Login
    run keyword and ignore error    COAM.Lock all cells via WEBUI
    run keyword and ignore error    COAM.Lock GNB1 all snssai via WEBUI
    run keyword and ignore error    COAM_WebEM.Logout
    run keyword and ignore error    Commission GNB with retry for 1RU     scf_file=${GNB1_initial_s1_SCF}
    run keyword and ignore error    Process.Cellsetup

Wireshark.StartCaptureNG
    [Arguments]   ${filename}    ${log_dir}=/ffs/run/config/toor4nsn    ${connection}=${ALIAS_ASIK}
    ssh.send command    command=tcpdump -n -i fp0 -w ${log_dir}/${filename} -vv &>/dev/null &    connection=${connection}

Wireshark.Capture_NG_Pcap
    [Arguments]  ${filename}
    gNB.Connect
    wait until keyword succeeds    25 min    1 min    gNB.CheckCPRIStatus
    Wireshark.StartCaptureNG    filename=${filename}

Wireshark.Download_NG_Pcap
    [Arguments]  ${filename}
    gNB.Connect
    Wireshark.StopCapturinglogforIP    filename=${filename}
    sleep    5s
    Wireshark.DownloadLog    filename=${filename}
    gNB.Disconnect

Wireshark.StopCapturinglogforIP
    [Arguments]   ${filename}
    ssh.send command    command=ps -ef|grep -i ${filename} | grep -v "grep" | awk -F " " '{print $2}' | xargs kill -2   connection=${ALIAS_ASIK}

Wireshark.DownloadLog
    [Arguments]    ${filename}
    ssh.download_file   local_path=${LOG_PATH}/${filename}    remote_path=/ffs/run/config/toor4nsn/${filename}   connection=${ALIAS_ASIK}
    sleep    20s

wireshark.Capture_CPIF_Pcap
    [Arguments]  ${filename}
    gNB.Connect
    wait until keyword succeeds    25 min    1 min    gNB.CheckCPRIStatus
    Wireshark.StartCaptureLogFromContainer    filename=${filename}    container=0xe004    nodename=CPIF

Wireshark.Download_CPIF_Pcap
    [Arguments]  ${filename}
    gNB.Connect
    Wireshark.StopCapturinglogFromContainer    container=0xe004    nodename=CPIF
    sleep    5s
    wireshark.DownloadLogToUTEFromContainer    filename=${filename}    nodename=CPIF
    sleep    20s
    gNB.Disconnect

Wireshark.Check PDU session release
    [Arguments]    ${PDU_ID}
    #release request
    Run Keyword And Continue On Failure    Wireshark.CheckExpression
    ...    expression=nas_5gs.pdu_session_id == ${PDU_ID} && nas_5gs.sm.message_type == 0xd1
    #release command
    Run Keyword And Continue On Failure    Wireshark.CheckExpression
    ...    expression=nas_5gs.pdu_session_id == ${PDU_ID} && nas_5gs.sm.message_type == 0xd3
    #release complete
#    Run Keyword And Continue On Failure    Wireshark.CheckExpression
#    ...    expression=nas_5gs.pdu_session_id == ${PDU_ID} && nas_5gs.sm.message_type == 0xd4


ASIK.Connect
    [Arguments]     ${alias}
    Run Keyword And Continue On Failure  ssh.Connect to   hostname=${ASIK_IP}    username=${ASIK_USERNAME}
    ...    password=${ASIK_PASSWORD}   alias=${alias}

ASIK.Disconnect
     [Arguments]     ${alias}
    Run Keyword And Continue On Failure  Conn.Disconnect    alias=${alias}

#Wireshark.Capture NGPcap for PDUrelease
#    [Arguments]  ${filename}   ${log_dir}=/tmp    ${alias}=${ALIAS_ASIK_2}
#    ASIK.Connect    alias=${alias}
#    wait until keyword succeeds    25 min    1 min    gNB.CheckCPRIStatus    alias=${alias}
#    ssh.send command    command=tcpdump -n -i fp0 -s 0 -w ${log_dir}/${filename} -vv &>/dev/null &    connection=${alias}
#
#Wireshark.Download NGPcap for PDUrelease
#    [Arguments]  ${filename}    ${alias}=${ALIAS_ASIK_2}
#    ASIK.Connect  alias=${alias}
#    ssh.send command    command=ps aux | grep tcpdump | awk '{print $2}' | xargs sudo kill -9     connection=${alias}
#    ssh.download_file   local_path=${LOG_PATH}/${filename}    remote_path=/tmp/${filename}   connection=${alias}
#    sleep    20s
#    ASIK.Disconnect  alias=${alias}

Analyse fp0 pcap for one pdu session
    [Arguments]    ${filename}    ${filter}
#    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds   2x    1min
#    ...    Wireshark.CheckInitialContextSetupRequest    filename=${filename}
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds   2x    1min
    ...    Wireshark.Check PDU Session First Setup    filename=${filename}    filter=${filter}

Analyse cpif pcap for pdu session
    [Arguments]    ${filename}
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds   2x    1min
    ...    wireshark.CheckUEContextSetupRequest    filename=${filename}   filter=f1ap.procedureCode == 5 && f1ap.F1AP_PDU == 0
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds   2x    1min
    ...    wireshark.CheckBearerContextRequest    filename=${filename}    filter=e1ap.procedureCode == 8 && e1ap.E1AP_PDU == 0

Wireshark.CheckInitialContextSetupRequest
    [Arguments]    ${filename}
    [Documentation]
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=${filename}    filter=ngap.id == 0
    ${ICSR_sst}    run keyword and return status    Wireshark.GetElementValueAndCompareWithEmpty    check_param=ngap.sST
    ${ICSR_sd}    run keyword and return status    Wireshark.GetElementValueAndCompareWithEmpty    check_param=ngap.sD
    Run keyword if     ${ICSR_sd}==False     Wireshark.GetElementValueAndCompareWithEmpty    check_param=ngap.sST
    Run keyword if     ${ICSR_sd}==True     run keywords    Wireshark.GetElementValueAndCompareWithEmpty    check_param=ngap.sST
    ...      AND    Wireshark.GetElementValueAndCompareWithEmpty    check_param=ngap.sD

Wireshark.Check PDU Session First Setup
    [Arguments]    ${filename}    ${filter}
    [Documentation]
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=${filename}    filter=${filter}
    ${PDU1}     Wireshark.GetElementValue    check_param=ngap.pDUSessionID
    ${PDU1_ID}    Set Variable    ${PDU1[0][0]}
    run keyword and ignore error    Set Test Variable    ${PDU1_ID}

    Wireshark.GetElementValueAndCompareWithTLInfo   check_param=ngap.sST     condition_expression=${filter}
    Wireshark.GetElementValueAndCompareWithTLInfo    check_param=ngap.sD     condition_expression=${filter}
#    Set Test Variable    ${PDU_sst}
#    Set Test Variable    ${PDU_sd}
#    @{PDU_value}    Run keyword if     ${PDU_sd}==False     wireshark.CheckOneValue     expression=${OneNG_slice}
#    ...    condition_expression=${filter}
#    ...    ELSE    wireshark.CheckTwoValues    expression=${TwoNG_slice}
#    ...    condition_expression=${filter}
#    Set Test Variable    @{PDU_value}

#    [Return]    @{PDU_value}

wireshark.CheckOneValue
    [Arguments]    ${expression}    ${condition_expression}=${None}
    [Documentation]
    ${Value_0}    Wireshark.GetElementValue    check_param=${expression[0]}    condition_expression=${condition_expression}

   [Return]    ${Value_0}

wireshark.CheckTwoValues
    [Arguments]    ${expression}    ${condition_expression}=${None}
    [Documentation]
    ${Value_0}    Wireshark.GetElementValue    check_param=${expression[0][0]}    condition_expression=${condition_expression}
    ${Value_1}    Wireshark.GetElementValue    check_param=${expression[1][0]}    condition_expression=${condition_expression}

   [Return]    ${Value_0}    ${Value_1}

wireshark.CheckUEContextSetupRequest
    [Arguments]    ${filename}    ${filter}
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=${filename}    filter=${filter}
#    ${UECSR_sst}    run keyword and return status    Wireshark.GetElementValueAndCompareWithEmpty    check_param=f1ap.sST
#    ...   condition_expression=f1ap.procedureCode == 5 &&f1ap.F1AP_PDU == 0
#    ${UECSR_sd}    run keyword and return status    Wireshark.GetElementValueAndCompareWithEmpty    check_param=f1ap.sD
#    ...   condition_expression=f1ap.procedureCode == 5 &&f1ap.F1AP_PDU == 0
#    should be equal    ${PDU_sst}    ${UECSR_sst}
#    should be equal    ${PDU_sd}    ${UECSR_sd}
#    @{UECSR_value}    Run keyword if     ${UECSR_sd}==False     wireshark.CheckOneValue     expression=${OneF1_slice}
#    ...    condition_expression=f1ap.procedureCode == 5 &&f1ap.F1AP_PDU == 0
#    ...    ELSE    wireshark.CheckTwoValues    expression=${TwoF1_slice}
#    ...    condition_expression=f1ap.procedureCode == 5 &&f1ap.F1AP_PDU == 0
#    Lists Should Be Equal    ${PDU_value}    ${UECSR_value}
    Wireshark.GetElementValueAndCompareWithTLInfo   check_param=f1ap.sST     condition_expression=${filter}
    Wireshark.GetElementValueAndCompareWithTLInfo    check_param=f1ap.sD     condition_expression=${filter}

wireshark.CheckBearerContextRequest
    [Arguments]    ${filename}    ${filter}
    [Documentation]
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=${filename}    filter=${filter}
#    ${BCR_sst}    run keyword and return status    Wireshark.GetElementValueAndCompareWithEmpty    check_param=e1ap.sST
#    ...    condition_expression=e1ap.procedureCode == 8 && e1ap.E1AP_PDU == 0
#    ${BCR_sd}    run keyword and return status    Wireshark.GetElementValueAndCompareWithEmpty    check_param=e1ap.sD
#    ...    condition_expression=e1ap.procedureCode == 8 && e1ap.E1AP_PDU == 0
#    should be equal    ${PDU_sst}    ${BCR_sst}
#    should be equal    ${PDU_sd}    ${BCR_sd}
#     @{BCR_value}    Run keyword if     ${BCR_sd}==False     wireshark.CheckOneValue     expression=${OneE1_slice}
#    ...    condition_expression=e1ap.procedureCode == 8 && e1ap.E1AP_PDU == 0
#    ...    ELSE    wireshark.CheckTwoValues    expression=${TwoE1_slice}
#    ...    condition_expression=e1ap.procedureCode == 8 && e1ap.E1AP_PDU == 0
#    Lists Should Be Equal    ${PDU_value}    ${BCR_value}
    Wireshark.GetElementValueAndCompareWithTLInfo    check_param=e1ap.sST     condition_expression=${filter}
    Wireshark.GetElementValueAndCompareWithTLInfo    check_param=e1ap.sD     condition_expression=${filter}

Wireshark.GetElementValueAndCompareWithEmpty
    [Arguments]    ${check_param}    ${element_idx}=${0}    ${default_value}=False    ${condition_expression}=${None}
    @{value}    Wireshark.GetElementValue    ${check_param}    ${element_idx}
    ...                               ${default_value}   ${condition_expression}
    Should Not Be Empty    ${value[0][0]}

Wireshark.GetElementValueAndCompareWithTLInfo
    [Arguments]    ${check_param}    ${element_idx}=${0}    ${default_value}=False    ${condition_expression}=${None}
    @{value}    Wireshark.GetElementValue    ${check_param}    ${element_idx}
    ...                               ${default_value}   ${condition_expression}
    run keyword if   '${check_param}'=='ngap.sST'
    ...    Should Be Equal    ${value[0][0]}    ${CASE_INPUT_5GC001008['PDU_sst']}
    ...    ELSE IF   '${check_param}'=='ngap.sD'
    ...    Should Be Equal    ${value[0][0]}    ${CASE_INPUT_5GC001008['PDU_sd']}
    ...    ELSE IF   '${check_param}'=='f1ap.sST'
    ...    Should Be Equal    ${value[0][0]}    ${CASE_INPUT_5GC001008['UECSR_sst']}
    ...    ELSE IF   '${check_param}'=='f1ap.sD'
    ...    Should Be Equal    ${value[0][0]}    ${CASE_INPUT_5GC001008['UECSR_sd']}
    ...    ELSE IF   '${check_param}'=='e1ap.sST'
    ...    Should Be Equal    ${value[0][0]}    ${CASE_INPUT_5GC001008['BCR_sst']}
    ...    ELSE IF   '${check_param}'=='e1ap.sD'
    ...    Should Be Equal    ${value[0][0]}    ${CASE_INPUT_5GC001008['BCR_sd']}

Create Cell and Verify Cell Sync
    prisma.create_5g_cell    ${lsu_uu}
    sleep    10s
    wait until keyword succeeds    5 min    20 sec    Check the NRcell sync

Prisma attach to gNB
    Start airmosaic
    sleep   1min
    Perform UE attach for 1008    sid_file_name=${sid_file_name}    scenario=${scenario}
    Wait until keyword succeeds    20 s    4 sec    Check Random access    ra_times=${ra_times}
    Check scenario status
    Sleep    10s

Perform UE attach for 1008
    [Arguments]    ${sid_file_name}    ${scenario}
    prisma.prepare_test    sid=${sid_file_name}    config_dir=${scenario}    timeout=300
    ${output}=     prisma.get_scenario_status
	sleep    40s
    prisma.ue_attach
    ${output}=      prisma.get_scenario_status

AMF.Connect
     run keyword and ignore error    ssh.Connect to    hostname=${5GC_IP}    username=${5GC_USERNAME}
     ...    password=${5GC_PASSWORD}    alias=${ALIAS_AMF}

AMF.Disconnect
    run keyword and ignore error    Conn.Disconnect    alias=${ALIAS_AMF}

Process.GetDLBlerAndTP
    [Arguments]    ${DLThroughput}=10000000    ${Percentage}=10
    Conn.ConnectWithTimeout    alias=${ALIAS_ASIK}
    Conn.ConnectToAsp1a    alias=${ALIAS_ASP_1A}
    ${dTP}    Run Keyword And Continue On Failure   gNB.GetDLThroughput    ALIAS_ASP_1A=${ALIAS_ASP_1A}    location=${16}
    Conn.Disconnect    alias=${ALIAS_ASP_1A}
    Conn.Disconnect    alias=${ALIAS_ASIK}
    ${DLPercent}    Run Keyword And Continue On Failure    Evaluate    ${dTP}*${100}*${1000}*${1000}/${DLThroughput}
    Set Test Variable    ${DLPercent}
    Set Test Variable    ${dTP}
    Run Keyword And Continue On Failure    Should be true    ${DLPercent}>${Percentage}

Process.GetULBlerAndTP
    [Arguments]    ${ULThroughput}=5000000    ${Percentage}=10
    Conn.ConnectWithTimeout    alias=${ALIAS_ASIK}
    Conn.ConnectToAsp1a    alias=${ALIAS_ASP_1A}
    ${uTP}    Run Keyword And Continue On Failure    gNB.GetULThroughput
    Conn.Disconnect    alias=${ALIAS_ASP_1A}
    Conn.Disconnect    alias=${ALIAS_ASIK}
    ${ULPercent}    Run Keyword And Continue On Failure    Evaluate    ${uTP}*${100}*${1000}*${1000}/${ULThroughput}
    Set Test Variable    ${ULPercent}
    Set Test Variable    ${uTP}
    Run Keyword And Continue On Failure     Should be true    ${ULPercent}>${Percentage}

Modify RD flag of rdUeContextRequest
    [Arguments]    ${before_value}    ${after_value}    ${file}
    Conn.Connect    alias=${ALIAS_ASIK}
    Conn.Execute    cmd=rm -rf /tmp/cpue && mkdir /tmp/cpue    alias=${ALIAS_ASIK}
    ${output}    Conn.Execute    cmd=cd /ffs/run/swpool/5G/CPUENODE/addons/ && ls cp_ue_*.txz    alias=${ALIAS_ASIK}
    ${filename}=	 Remove String    ${output}    \r\n
    Conn.Execute    cmd=tar -xvf /ffs/run/swpool/5G/CPUENODE/addons/${filename} -C /tmp/cpue    alias=${ALIAS_ASIK}
    Conn.Execute    cmd=sed -i "s/${before_value}/${after_value}/g" /tmp/cpue/opt/nokia/SS_CPLANE/etc/${file}  alias=${ALIAS_ASIK}
    Conn.Execute    cmd=cd /tmp/cpue && tar -Jcvf ${filename} opt/ usr/    alias=${ALIAS_ASIK}
    Conn.Execute    cmd=cd /tmp/cpue && cp ${filename} /ffs/run/swpool/5G/CPUENODE/addons/    alias=${ALIAS_ASIK}
    Conn.Execute    cmd=cd /ffs/run/swpool/5G/CPUENODE/addons/ && crasign ${filename} && rm /ffs/run/HashContainer*    alias=${ALIAS_ASIK}
    Conn.Execute    cmd=reboot    alias=${ALIAS_ASIK}
    Conn.Disconnect    alias=${ALIAS_ASIK}

Enable RD flag of rdUeContextRequest
    Modify RD flag of rdUeContextRequest    before_value=rdUeContextRequest=False    after_value=rdUeContextRequest=True
    ...    file=cp_ue.enb_conf.ini

Disable RD flag of rdUeContextRequest
    Modify RD flag of rdUeContextRequest    before_value=rdUeContextRequest=True    after_value=rdUeContextRequest=False
    ...    file=cp_ue.enb_conf.ini

COAM.GetParameterValue
    [Arguments]    ${dist_name}   ${filter_param}    ${abbr}
    ${value}   Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}    abbr=${abbr}
    [Return]       ${value}

COAM.SetParameterValue
    [Arguments]    ${dist_name}    ${filter_param}    ${new_value}    ${abbr}
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}    new_value=${new_value}    abbr=${abbr}

COAM.DeleteParameter
    [Arguments]    ${dist_name}   ${filter_param}    ${abbr}
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.delete_parameter    dist_name=${dist_name}    filter_param=${filter_param}    abbr=${abbr}

COAM.RemoveElement
    [Arguments]    ${dist_name}   ${filter_param}    ${node_index}
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.remove_element    dist_name=${dist_name}    filter_param=${filter_param}    node_index=${node_index}

COAM.ValidateAndActiveParameters
    ${error}    selenium_coam.validate_plan
    log    ${error}
    Run Keyword And Ignore error    selenium_coam.activate_plan    activate_plan_despite_errors=True

Prepare process for lock cell
    [Arguments]    ${cell_idx}
    ${cell_info}    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    log    ${cell_info} and ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="Locked"
    ...         Run Keywords    selenium_coam.unlock_cell    cell_idx=${cell_idx}    timeout=60    AND    sleep    2min
    ...         ELSE     Log    continue the next steps

Process for lock/unlock cell
    [Arguments]    ${func}    ${cell_idx}
    Run Keyword And Continue On Failure    ${func}    cell_idx=${cell_idx}    timeout=60
    sleep    2min
    ${cell_info}    selenium_coam.get_cell_info    cell_idx=${cell_idx}

Start BTSlogs Collection
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf BTSLOG_TRACE_*.bin ; rm -rf SYSLOG_*.LOG
    run keyword and ignore error    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    run keyword and ignore error    btslog.Set Global Alias     btslog
    run keyword and ignore error    core.setup_collectors      names=btslog
    run keyword and ignore error    core.start_collectors      names=btslog

Stop BTSlogs Collection and get logs
    run keyword and ignore error    core.stop_collectors      names=btslog
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz SYSLOG_combine.LOG
    run keyword and ignore error    run    command=cp /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz ${LOG_PATH}

Backup current SCF
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    coam.get_current_scf_file   local_dir_path=${LOG_PATH}   file_name=${TEST NAME.replace(" ", "_")}.xml   connection=COAM   timeout=10
    COAM_Admin.Logout

Process.Prepare for 1008 commission
    [Arguments]    ${func}
    Run Keyword And Continue On Failure    COAM_WebEM.Login
    Run Keyword And Continue On Failure    COAM.Lock all cells via WEBUI
    Run Keyword And Continue On Failure    ${func}
    Run Keyword And Continue On Failure    COAM_WebEM.Logout

COAM.Lock all cells via WEBUI
    ${cell_num}    selenium_coam.get_number_of_cells
    FOR    ${i}    IN RANGE    ${cell_num}
        ${cell_info}    selenium_coam.get_cell_info    cell_idx=${i+1}
        log    ${cell_info} and ${cell_info['Status']['Administrative state']}
        run keyword if    '${cell_info['Status']['Administrative state']}'=="Unlocked"
        ...         Run Keywords    selenium_coam.lock_cell    cell_idx=${i+1}    timeout=60    AND    sleep    2min
        ...         ELSE     Log    continue the next steps
    END

COAM.Lock GNB1 all snssai via WEBUI
    Run Keyword And Continue On Failure    COAM.Lock one SNSSAI AdministrativeState    dist_name=${GNB1_distname_1}
    run keyword and ignore error    COAM.Lock one SNSSAI AdministrativeState    dist_name=${GNB1_distname_2}
    run keyword and ignore error     COAM.Lock one SNSSAI AdministrativeState    dist_name=${GNB1_distname_3}

COAM.Lock one SNSSAI AdministrativeState
    [Arguments]    ${dist_name}
    ${before_status}    Run Keyword And Continue On Failure     selenium_coam.get_parameter_value    dist_name=${dist_name}
    ...    filter_param=Administrative state     abbr=administrativeState
    Run Keyword If   '${before_status}' == 'Unlocked'
    ...    COAM.Lock/Unlock one SNSSAI AdministrativeState    dist_name=${dist_name}    new_value=Locked
    ...    ELSE     Log    continue next steps


COAM.Unlock one SNSSAI AdministrativeState
    [Arguments]    ${dist_name}
    ${before_status}    Run Keyword And Continue On Failure     selenium_coam.get_parameter_value    dist_name=${dist_name}
    ...    filter_param=Administrative state     abbr=administrativeState
    Run Keyword If   '${before_status}' == 'Locked'
    ...    COAM.Lock/Unlock one SNSSAI AdministrativeState    dist_name=${dist_name}    new_value=Unlocked
    ...    ELSE     Log    continue next steps

COAM.Lock/Unlock one SNSSAI AdministrativeState
    [Arguments]    ${dist_name}    ${new_value}
    Run Keyword And Continue On Failure    COAM.SetParameterValue    dist_name=${dist_name}    filter_param=Administrative state
    ...    new_value=${new_value}    abbr=administrativeState
    Run Keyword And Continue On Failure    COAM.ValidateAndActiveParameters
    ${after_status}    Run Keyword And Continue On Failure     selenium_coam.get_parameter_value    dist_name=${dist_name}
    ...    filter_param=Administrative state     abbr=administrativeState
    Run Keyword And Continue On Failure    Should be equal    ${after_status}    ${new_value}


COAM.Check slice operational enable state
    [Arguments]    ${dist_name}
    Run Keyword And Continue On Failure    COAM.Check slice value wia webui    dist_name=${dist_name}
    Run Keyword And Continue On Failure    COAM.Check slice operational state wia webui    slice_state_except=enabled    dist_name=${dist_name}

COAM.Check slice operational disable state
    [Arguments]    ${dist_name}
    Run Keyword And Continue On Failure    COAM.Check slice value wia webui    dist_name=${dist_name}
    Run Keyword And Continue On Failure    COAM.Check slice operational state wia webui    slice_state_except=disabled    dist_name=${dist_name}

COAM.Check slice operational state wia webui
    [Arguments]    ${slice_state_except}    ${dist_name}
    ${slice_state_result}    COAM.GetParameterValue    dist_name=${dist_name}   filter_param=Operational state    abbr=operationalState
    Run Keyword And Continue On Failure    Should be equal    ${slice_state_except}    ${slice_state_result}

COAM.Check slice value wia webui
    [Arguments]    ${dist_name}
    ${sst_value}    COAM.GetParameterValue    dist_name=${dist_name}    filter_param=Slice Service Type    abbr=sst
    ${sd_value}    COAM.GetParameterValue    dist_name=${dist_name}    filter_param=Slice Differentiator    abbr=sd

   [Return]    ${sst_value}    ${sd_value}


################################################ MTK operation #########################################################
UE.Require_With_Retry
    [Arguments]    ${UE_alias}=UE_1    ${UE_CAPABILITIES}=REAL_MEDIATEK_UE
    ${status}   Run Keyword And Return Status    ute_ue.require Ue    ue_alias=${UE_alias}    capabilities=${UE_CAPABILITIES}
    Run keyword if    '${status}'=='False'    Run Keywords    UE.Power_Reset
    ...    AND    ute_ue.require Ue    ue_alias=${UE_alias}    capabilities=${UE_CAPABILITIES}

UE.Init_MTK_With_Retry
    [Arguments]    ${beforeattach}=0
    ${status}   Run Keyword And Return Status    MTKUE.init_mtk    beforeattach=${beforeattach}
    Run keyword if    '${status}'=='False'    Run Keywords    UE.Power_Reset
    ...    AND    MTKUE.init_mtk    beforeattach=${beforeattach}

UE.Power_Reset
    facom.PowerOnOff    pdu_ip=${MTK_FACOM_IP}    Port_Number=${MTK_FACOM_PORT}    Action=power_off
    sleep    10s
    facom.PowerOnOff    pdu_ip=${MTK_FACOM_IP}    Port_Number=${MTK_FACOM_PORT}    Action=power_on
    sleep    60s

Check_And_Require_MTK
    [Arguments]    ${beforeattach}
    UE.Require_With_Retry
    UE.Init_MTK_With_Retry    beforeattach=${beforeattach}

Process.Ue Attach
#    Wait until keyword succeeds    2x    10s    MTK.UE Attach
    MTK.UE Attach
    Verify if UE registered to AMF

MTK.UE Attach
    [Arguments]    ${UE_alias}=UE_1
#    Run Keyword And Ignore Error    Process.Ue Deteach
    Clear UE info from AMF with Retry
    ute_ue.attach_ue    ${UE_alias}
    ${res}    MTKUE.collect_ota_message_until    expected=5GMM_REGISTRATION_COMPLETE    wait_timeout=${120}
    should contain    ${res}    5GMM_REGISTRATION_COMPLETE

Clear UE info from AMF with Retry
   [Arguments]  ${ue_imsi}=${IMSI}   ${retry_times}=2
    FOR    ${i}    IN RANGE    ${retry_times}
        Clear UE info from AMF
    END
    Log    UeAttach retry for ${i + 1} times.

Connect to 5GC
    csn.connect to    ${5GC_IP}  ${5GC_USERNAME}  ${5GC_PASSWORD}    alias=${ALIAS_5GC}

Disconnect from 5GC
    csn.disconnect    connection=${ALIAS_5GC}

Clear UE info from AMF
   [Arguments]  ${ue_imsi}=${IMSI}   ${retry_times}=2
   Connect to 5GC
   ${imsi_presence}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi} 2> /dev/null| head -n 7 | grep GENERALINFO
   ...    connection=${ALIAS_5GC}
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    csn.execute   command=cmm subscriber delete --imsi ${ue_imsi}    connection=${ALIAS_5GC}
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    sleep   2min    # WA, make IMSI clear opeation is done completely.
   Disconnect from 5GC

Verify if UE registered to AMF
   [Arguments]  ${ue_imsi}=${IMSI}
   Connect to 5GC
   ${output}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep amfRmState   connection=${ALIAS_5GC}
   should contain   container=${output}   item=REGISTERED
   ${output}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep amfCmState  connection=${ALIAS_5GC}
   should contain   container=${output}   item=CONNECTED
   Disconnect from 5GC

Check UE status from AMF
   [Documentation]  This is to doublecheck ue attach result from 5GC side, avoiding a false-positve registration-complete.
   [Arguments]  ${ue_imsi}=${IMSI}
   Connect to 5GC
   ${UE_Status}=    csn.execute    command=cmm subscriber show --imsi ${ue_imsi}  connection=${ALIAS_5GC}
   ${RM_Status}=    csn.execute    command=cmm subscriber show --imsi ${ue_imsi}| grep amfRmState   connection=${ALIAS_5GC}
   ${CM_Status}=    csn.execute    command=cmm subscriber show --imsi ${ue_imsi}| grep amfCmState  connection=${ALIAS_5GC}
   ${PDN_Status}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi}| grep pnd  connection=${ALIAS_5GC}
   Log   message=${UE_Status}
   Log to console   message=RM state is: ${RM_Status}
   Log to console    message=CM state is: ${CM_Status}
   Log to console    message=PDU state is:${PDN_Status}
   Disconnect from 5GC

Process.Start DL Traffic
    [Arguments]    ${Expected_Tput}=22Mbits/sec    ${DT_Name}=dt1_dl    ${UE_alias}=UE_1    ${direction}=dl    ${Duration}=90s    ${Data_Type}=udp
    ...    ${Packet_Size}=1024
    ute_ue.start_data_transfer    dt_name=${DT_Name}    ue_alias=${UE_alias}    direction=${direction}    throughput=${Expected_Tput}
    ...    duration=${Duration}    protocol=${Data_Type}    packet_size=${Packet_Size}

Proess.Start UL Traffic
    [Arguments]    ${Expected_Tput}=6Mbits/sec    ${DT_Name}=dt1_ul   ${UE_alias}=UE_1    ${direction}=ul    ${Duration}=90s    ${Data_Type}=udp
    ...    ${Packet_Size}=1024
    ute_ue.start_data_transfer    dt_name=${DT_Name}    ue_alias=${UE_alias}    direction=${direction}    throughput=${Expected_Tput}
    ...    duration=${Duration}    protocol=${Data_Type}    packet_size=${Packet_Size}

Connect MTK CtrlPC
    ssh.Connect to    hostname=${MTKPC_IP}    username=${MTKPC_USERNAME}    password=${MTKPC_PASSWORD}    alias=${ALIAS_MTKPC}

Disconnect MTK CtrlPC
    ssh.disconnect    connection=${ALIAS_MTKPC}

GNB.SwconfigReplace
    [Arguments]    ${file_path}=${CFGFILE_PATH}
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.UploadFile    local_path=${file_path}/swconfig.txt    remote_path=/ffs/run/swconfig.txt    alias=${ALIAS_ASIK}
    Conn.Execute    cmd=cd /ffs/run/ && crasign swconfig.txt    alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}


##################################################### 1008-A common keywords ###########################################
Check 2cell status with reset
    [Arguments]
    ${2cell_check}    run keyword and return status    Check Cell Until Success
    Run keyword if    ${2cell_check}== True    Log    continue the next steps
    Run keyword if    ${2cell_check}== False    run keywords
    ...    Power.ResetgNB    model=${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}
    ...    AND    Power.Reset5GRU    model=${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.vendor}
    ...    AND    Power.Reset5G_RU2  model=${tl.gnbs[0].dus[0].rus[1].pdu_port.pdu.vendor}
    ...    AND    wait until keyword succeeds   13x   2min    Get 2cell status

Check Cell Until Success
    wait until keyword succeeds   20x   1min    Get 2cell status

Get 2cell status
    [Arguments]   ${connection}=COAM
    COAM_Admin.Login
    ${subcells_info}    coam.get_subcells_status    connection=${connection}   timeout=10

#    ${availabilityStatus_1}   Set Variable   ${subcells_info['NRCELLGRP-0']['NRCELL-1']['NRCELL_R']['availabilityStatus']}
#    Run Keyword And Continue On Failure    Should Contain   ${availabilityStatus_1}   Online
    ${operationalState_1}   Evaluate   '${subcells_info['NRCELLGRP-0']['NRCELL-1']['NRCELL_R']['operationalState']}'.lower()
    Run Keyword And Continue On Failure    Should Contain   ${operationalState_1}   enabled

#    ${availabilityStatus_2}   Set Variable   ${subcells_info['NRCELLGRP-1']['NRCELL-2']['NRCELL_R']['availabilityStatus']}
#    Run Keyword And Continue On Failure    Should Contain   ${availabilityStatus_2}   Online
    ${operationalState_2}   Evaluate   '${subcells_info['NRCELLGRP-1']['NRCELL-2']['NRCELL_R']['operationalState']}'.lower()
    Run Keyword And Continue On Failure    Should Contain   ${operationalState_2}   enabled

    COAM_Admin.Logout

Second slice addition triggered by AMF
    [Documentation]    TestsliceE14: rename for 1008_E_14 case; Snssai1: not rename
    AMF.Connect
    operation cmd by AMF    cmd=cmm snssai create --name TestsliceE14 --sliceServiceType 6 --sliceDifferentiator 000006
    operation cmd by AMF    cmd=cmm snssaiListItem create --snssaiListName Snssai1 --snssaiName TestsliceE14
    AMF.Disconnect

Second slice delete triggered by AMF
    AMF.Connect
    operation cmd by AMF    cmd=cmm snssaiListItem delete Snssai1~TestsliceE14
    operation cmd by AMF    cmd=cmm snssai delete TestsliceE14
    AMF.Disconnect

operation cmd by AMF
    [Arguments]    ${cmd}
    ${output}    ssh.execute    ${cmd}
    ...    connection=${ALIAS_AMF}
    Log    ${output}

Restore GNB1 rdUeContextRequest
    run keyword and ignore error    Disable RD flag of rdUeContextRequest
    run keyword and ignore error    Process.Cellsetup

Suite Teardown for 1008_B
    Teardown Suite
    run keyword and ignore error    Restore GNB1 rdUeContextRequest

Suite setup for 1008_B
    Setup 1008 case suite
    run keyword and ignore error    Enable RD flag of rdUeContextRequest
    Check GNB cell with reset for 1RU
    #gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    Run Keyword And Continue On Failure    gNB.ModifySCF    InputFile=${initial_S1_SCF}    OutputFile=${MODIFIED_SCF_B1}
#    ...     ParameterToDelete=${PARAMS_TO_DELETE_1008_B_case2}    ParamterToModify=${PARAMS_TO_MODIFY_1008_B_case2}
    gNB.GenerateCaseSCF    InputFile=${LOG_PATH}/TestLineSCF1Cell.xml    OutputFile=${MODIFIED_SCF_B1}
    ...                    ResourceFolder=${CURDIR}
	...                    ParameterToDelete=PARAMS_TO_DELETE_1008_B_case2
	...                    ParamterToModify=PARAMS_TO_MODIFY_1008_B_case2
    Run Keyword And Continue On Failure    Commission GNB with retry for 1RU    scf_file=${MODIFIED_SCF_B1}

Process for two PDU of Spark
    [Arguments]    ${filename}    ${ue_alias}=UE_0
#    [Arguments]    ${filename}    ${apn2}    ${ue_alias}=UE_0
    Run Keyword And Continue On Failure  Clear UE info from AMF    ue_imsi=${IMSI}
    Run Keyword And Continue On Failure  power_ue.Prepare UE    ue_type=${UE_TYPE}
    Run Keyword And Continue On Failure    Wireshark.Capture_NG_Pcap   filename=${filename[0]}
    Run Keyword And Continue On Failure    wireshark.Capture_CPIF_Pcap  filename=${filename[1]}
    Run Keyword And Continue On Failure    power_ue.UE Detach    ue_type=${UE_TYPE}    power_reset=True
    sleep    10s
    Run Keyword And Continue On Failure    power_ue.UE Attach    ue_type=${UE_TYPE}    power_reset=True
    Run Keyword And Continue On Failure    power_ue.Verify attach    ue_type=${UE_TYPE}
    Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl
    ...    throughput=10MKbits/sec    duration=600    apn_address=${SA_APN}    ue_mode=SA
    Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul
    ...    throughput=5MKbits/sec    duration=600    apn_address=${SA_APN}    ue_mode=SA
    sleep    30s
    Run Keyword And Continue On Failure    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=dl    throughput=5
    Run Keyword And Continue On Failure    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=ul    throughput=2

#    ${UE_IP2}    Run Keyword And Continue On Failure    spark.create_pdu_session    ue_alias=${ue_alias}
#    ...    id=2    apn=wap1.nokia.com    verify=True
#    Run Keyword And Ignore error    set test variable   ${UE_IP2}
#    Run Keyword And Continue On Failure    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl
#    Run Keyword And Continue On Failure    Spark.StartDLTraffic    host=${UE_IP2}
#    Run Keyword And Continue On Failure    Spark.DL throughput check
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl   apn_address=${SA_APN}    ue_mode=SA
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul    apn_address=${SA_APN}    ue_mode=SA
    ${SPARK_release_PDU1}    run keyword and return status    spark.release_pdu_session    ue_alias=${ue_alias}   id=1
#    ${SPARK_release_PDU2}    run keyword and return status    spark.release_pdu_session    ue_alias=${ue_alias}   id=2
    Run Keyword And Ignore error    set test variable    ${SPARK_release_PDU1}
#    Run Keyword And Ignore error    set test variable    ${SPARK_release_PDU2}
    Run Keyword And Continue On Failure    power_ue.UE Detach    ue_type=${UE_TYPE}
    Run Keyword And Continue On Failure    Wireshark.Download_CPIF_Pcap    filename=${filename[1]}
    Run Keyword And Continue On Failure    Wireshark.Download_NG_Pcap    filename=${filename[0]}
#    Run Keyword And Ignore Error    Spark.kill iperf in AppServer

Get Bcase1 PDU ID
    ${Bcase1_PDU1_ID}    Set Variable    ${PDU1_ID}
    Set Suite Variable    ${Bcase1_PDU1_ID}

Check PDU release via wireshark
    [Arguments]    ${filename}    ${PDU_ID}
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=${filename}    filter=ngap.NGAP_PDU == 0
    Run Keyword And Continue On Failure    wait until keyword succeeds   2x   1min
    ...    Wireshark.Check PDU session release    PDU_ID=${PDU_ID}

    #PDUSessionResourceReleaseResponse
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=${filename}    filter=ngap.NGAP_PDU == 1
    Run Keyword And Continue On Failure    Wireshark.CheckExpression
    ...    expression=ngap.pDUSessionID == ${PDU_ID} && ngap.procedureCode == 28


###################################################ENB operation #######################################################
ENB.Commissioning
    [Arguments]    ${scf_file}    ${file_path}=${CFGFILE_PATH}
    ENB_Admin.Commission    scf_file=${file_path}/${scf_file}
    sleep    3min

ENB_Admin.Commission
    [Arguments]    ${scf_file}    ${timeout}=${600}    ${connnection}=ENB
    wait until keyword succeeds    3x    1min    ENB_Admin.Login    bts_host=${ENB_WEBUI_IP}
    coam.perform_commissioning    scf_file=${scf_file}    skip_parameter_relation_errors=True    should_activate=${true}    timeout=${timeout}
    ...    connection=${connnection}
    ENB_Admin.Logout

ENB_Admin.Login
    [Arguments]    ${bts_host}=${ENB_WEBUI_IP}    ${username}=${WEBUI_USERNAME}    ${password}=${WEBUI_PASSWORD}    ${bts_port}=${443}
    ...    ${log_dir}=${OUTPUT_DIR}    ${alias}=ENB
    coam.connect_to    bts_host=${bts_host}    bts_port=${bts_port}    username=${username}    password=${password}    use_ssl=${True}
    ...    update_interval=${5000}    admin_api_log_dir=${log_dir}    name=${alias}

ENB_Admin.Logout
    [Arguments]    ${connection}=ENB
    coam.teardown    connection=${connection}

## PA side operation ##
Adjust ${RU} Attenuation to ${value}
    ${value}    RemoveZeroString     ${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT1}    value=${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT2}    value=${value}

Adjust Attenuation for RU
    [Arguments]    ${RU}    ${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT1}    value=${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT2}    value=${value}

Adjust the Attenuation Value
    [Arguments]    ${ports}    ${value}
    PA.setup_attenuator    attenuator=${PA_INFO}
    PA.set_attenuation     port=${ports}    value=${value}
    PA.read_attenuation    port=${ports}

slice addition triggered by AMF for 1008_EA
    [Documentation]    TestsliceEA13: rename for 1008_EA_TDD_13 case; add snssai from AMF side：sst=200，sd=1
    AMF.Connect
    operation cmd by AMF    cmd=cmm snssai create --name TestsliceEA13 --sliceServiceType 200 --sliceDifferentiator 000001
    operation cmd by AMF    cmd=cmm snssaiListItem create --snssaiListName Snssai1 --snssaiName TestsliceEA13
    AMF.Disconnect

slice delete triggered by AMF for 1008_EA
    [Documentation]    TestsliceEA13: rename for 1008_EA_TDD_13 case; delete snssai from AMF side：sst=200，sd=1
    AMF.Connect
    operation cmd by AMF    cmd=cmm snssaiListItem delete Snssai1~TestsliceEA13
    operation cmd by AMF    cmd=cmm snssai delete TestsliceEA13
    AMF.Disconnect

gNB.Add parameters to scf
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    Run Keyword And Continue On Failure    gNB.Add objects to scf  input_scf=${input_scf}  output_scf=${output_scf}
    ...    parameters_lists=${parameters_lists[0]}
    Run Keyword And Continue On Failure    gNB.Add elements to object  input_scf=${output_scf}  output_scf=${output_scf}
    ...    parameters_lists=${parameters_lists[1]}
    Run Keyword And Continue On Failure    gNB.Add lists to object  input_scf=${output_scf}  output_scf=${output_scf}
    ...    parameters_lists=${parameters_lists[2]}
    Run Keyword And Continue On Failure    gNB.Add items to list    input_scf=${output_scf}  output_scf=${output_scf}
    ...    parameters_lists=${parameters_lists[3]}
    Run Keyword And Continue On Failure    gNB.Add elements to list  input_scf=${output_scf}  output_scf=${output_scf}
    ...    parameters_lists=${parameters_lists[4]}

Spark.Check cell status from UE side
    [Arguments]    ${name}    ${expression}    ${expect_value}    ${type}='last'    ${ue_alias}=UE_0
    Run Keyword And Continue On Failure  Clear UE info from AMF    ue_imsi=${IMSI}
    Run Keyword And Continue On Failure  power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=0
    Run Keyword And Continue On Failure    spark.start log    ue_alias=${ue_alias}
    Run Keyword And Ignore error    spark.power_off    ue_alias=${UE_alias}
    Run Keyword And Ignore error    spark.power_on    ue_alias=${UE_alias}
    Run Keyword And Ignore error    power_ue.Verify attach    ue_type=${ue_type}    ue_index=0
    sleep    30s
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=0
    Run Keyword And Continue On Failure    spark.stop log    ue_alias=${ue_alias}    logname=${LOG_PATH}/${name}
    Run Keyword And Continue On Failure    spark.read_log     logname=${LOG_PATH}/${name}
    ${res}    spark.get_expected_val     msg=NR MasterInformationBlock    expression=${expression}    type=${type}
    should be equal     ${res}    ${expect_value}

##################################################### 1008-PC-7 keywords ###########################################
Modify Parameters of SNSSAI Administrative state
    [Arguments]    ${DistName}=${MRBTS_ID}/${NRBTS_ID}/SNSSAI-1    ${FilterParam}=Administrative state    ${NewValue}=Locked
    COAM_WEBEM.ModifyParameters    DistName=${DistName}    FilterParam=${FilterParam}    NewValue=${NewValue}
    COAM_WebEM.ValidateAndActiveParameters

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
