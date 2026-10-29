*** Settings ***
Documentation    author: Gao Ge
...               contact: ge.gao@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC000742

#Resource          ../../5GC002056/Resources/5GC002056_Resources.robot
Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Variables         ${CFGFILE_ON_GIT}5GC000742/Delta.py
#Variables         ${CFGFILE_ON_GIT}TLDelta.py


*** Variables ***
${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}
${UPDATE_FILE_PATH}         /opt/ute/tmp/
${Local_CFGFILE_PATH}       /home/ute/TAF/cfgfile/
#${CFGFILE_ON_GIT}           /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
${lua_script_path}       ${Local_CFGFILE_PATH}luashark/generated_luashark/luashark.lua
${Original_CFGFILE}      ${LOG_PATH}/TestLineSCF1Cell.xml
${MODIFIED_CFGFILE_1}    ${CFGFILE_PATH}5GC002334/barred.xml
${MODIFIED_CFGFILE_2}    ${CFGFILE_PATH}5GC002334/semiStatic_u1_d4.xml
${MODIFIED_CFGFILE_3}    ${CFGFILE_PATH}5GC002334/SCF_742c.xml
${MODIFIED_CFGFILE_4}    ${CFGFILE_PATH}5GC002334/SCF_742Y.xml
${MODIFIED_CFGFILE_11}      ${LOG_PATH}/checkcounters.xml
${MODIFIED_CFGFILE_12}      ${LOG_PATH}/band.xml
${SCF_Y30}                  ${CFGFILE_PATH}Configuration_scf_Y30.xml
${MODIFIED_CFGFILE_H56}    ${CFGFILE_PATH}5GC000742/2197_1cell_742_H56.xml


${MODIFIED_CFGFILE_TLSCF}   /home/ute/TAF/cfgfile/modified_SCF/
#${GoldenScf_PATH}           /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG




${EGATE_CFG_NAME}           ${tl.core.cfg_filename}
${WTS_FILE_PATH}            ${tl.core.dir_path}
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${AMF_IP}                   ${tl.core.mme_ip}
${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}
${UE_alias}                 UE_0
${ALIAS_5GC}                5gc

${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

${RU_TYPE}                  ${tl.gnbs[0].dus[0].rus[0].radio_type}
${AEQA_IP}                  ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

${PB_PORT}                  5000
${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

${MRBTS_ID}   				MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                 NRBTS-${tl.gnbs[0].global_bts_id}

${dist_name}    ${MRBTS_ID}/${NRBTS_ID}

${TLDelta_PATH}              ${CFGFILE_PATH}
##################define these variable for convenient############################
${ALIAS_ASIK}               asik                                                ##
${ALIAS_ASIK_SLAVE}         asik_slave                                          ##
${ALIAS_ABIL}                abil                                               ##
${ALIAS_ABIL_SLAVE}         abil_slave                                          ##
${ALIAS_LONER}              loner                                               ##
${ALIAS_UTE}                ute                                                 ##
${ALIAS_ENBCTLPC}           ENB_PC                                              ##
${ALIAS_SHP}                SHP                                                 ##
########################END of alias Define#######################################

*** Keywords ***
####Case Level  Keywords#####
TC.5GC000742_B_005_Dynamic reconfiguration of SA cell in MIB and SIB1
    [Teardown]    Run Keyword And Ignore Error    UE recovery to initial state
    Run Keyword And Ignore Error    UE recovery to initial state
    gNB.GenerateCaseSCF    InputFile=${Original_CFGFILE}    OutputFile=${LOG_PATH}/742_B05_Barred.xml
    ...                    ResourceFolder=${CURDIR}
    ...                    ParameterToDelete=PARAMS_TO_DELETE_barred
	...                    ParamterToModify=PARAMS_TO_MODIFY_barred
    power_ue.Prepare UE    ue_type=${UE_TYPE}     ue_index=${0}
    ...    detach_request=${true}
    ...    power_reset=false
    gNB.CommissionWithRetry    scf_file=${LOG_PATH}/742_B05_Barred.xml
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend

    log to console    Step1:cell is barred or not?
    ${result}    run keyword and return status    GetAttachvalue    power_reset=false
    sleep     30s
    should be true    '${result}'=='False'
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
    log to console   Step1_Result:PASS cell is barred

    log to console   Step2:cell is barred or not?
    COAM_WebEM.Login
    COAM.SetParameterValue    distname=${dist_name}/NRCELL-1    filter_param=Cell Barred
    ...    value=notBarred    abbr=cellBarred
    ValidateAndActiveParameters
    COAM_WebEM.Logout
    gNB.VerifyOnAirViaOAMUntilReady
    Run Keyword And Ignore Error    UE recovery to initial state
    ${result}    run keyword and return status    GetAttachvalue    power_reset=false
    sleep     10s
    should be true    '${result}'=='True'
    log to console   Step2_Result:PASS cell is notbarred

    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
    log to console   Step3:t301 is 300ms or not
    COAM_WebEM.Login
    COAM.SetParameterValue    distname=${dist_name}/NRCELL-1    filter_param=Timer t301
    ...    value=300ms    abbr=t301
    ValidateAndActiveParameters
    COAM_WebEM.Logout
    Run Keyword If    '${UE_TYPE}'=='huawei_sigspark' or '${UE_TYPE}'=='askey_sigspark'
    ...    Run Keyword   spark.Start Log    ue_alias=${UE_alias}
    ${result}    run keyword and return status    GetAttachvalue    power_reset=false
    sleep    10s
    Run Keyword If    '${UE_TYPE}'=='huawei' or '${UE_TYPE}'=='samsung'
    ...    should be true    '${result}'=='True'
    Run Keyword If    '${UE_TYPE}'=='huawei_sigspark' or '${UE_TYPE}'=='askey_sigspark'
    ...    Stop and read spark log    msg=NR SystemInformationBlock1    expression=t301    except_res=ms300
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
    log to console   Step3_Result:t301 is 300ms


TC.5GC000742_C_023_Reconfiguration of SIBs (MCS9)
#    gNB.ModifySCF        InputFile=${Original_CFGFILE}
#    ...                  OutputFile=${LOG_PATH}/742_C023_Barred.xml
#    ...                  ParameterToDelete=${PARAMS_TO_DELETE_742C}
#    ...                  ParamterToModify=${PARAMS_TO_MODIFY_742C}
#    ...                  ListToAdd=${LIST_TO_ADD_742C}
    gNB.GenerateCaseSCF    InputFile=${Original_CFGFILE}    OutputFile=${LOG_PATH}/742_C023_Barred.xml
    ...                    ResourceFolder=${CURDIR}
    ...                    ParameterToDelete=PARAMS_TO_DELETE_742C
	...                    ParamterToModify=PARAMS_TO_MODIFY_742C
	...                    ListToAdd=LIST_TO_ADD_742C
    gNB.CommissionWithRetry    scf_file=${LOG_PATH}/742_C023_Barred.xml
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    COAM_WebEM.Login
# sib2
    COAM.SetParameterValue    distname=${dist_name}/NRSYSINFO_PROFILE-1    value=s30
    ...    filter_param=Duration for evaluation criteria    abbr=tEvaluation
    COAM.SetParameterValue    distname=${dist_name}/NRCELL-1   value=1
    ...    filter_param=Absolute priority for NR frequency    abbr=cellReselectionPriority
# sib3
    COAM.SetParameterValue    distname=${dist_name}/NRSYSINFO_PROFILE-1/NRIAFIM-1   value=58
    ...    filter_param=Physical cell identifier    abbr=physCellId
    COAM.SetParameterValue    distname=${dist_name}/NRSYSINFO_PROFILE-1/NRIAFIM-1   value=61
    ...    filter_param=Physical cell identifier start    abbr=physCellId
# sib4
    COAM.SetParameterValue    distname=${dist_name}/NRSYSINFO_PROFILE-1/NRIRFIM-1   value=71
    ...    filter_param=Physical cell identifier    abbr=physCellId
    COAM.SetParameterValue    distname=${dist_name}/NRSYSINFO_PROFILE-1/NRIRFIM-1   value=101
    ...    filter_param=Physical cell identifier start    abbr=physCellId
# sib5
    COAM.SetParameterValue    distname=${dist_name}/NRSYSINFO_PROFILE-1/NRLIM-1   value=2
    ...    filter_param=Absolute priority for NR frequency    abbr=cellReselectionPriority
    COAM.SetParameterValue    distname=${dist_name}/NRSYSINFO_PROFILE-1/NRLIM-1   value=oDot4
    ...    filter_param=Fractional priority for NR frequency    abbr=cellReselectionSubPriority
    ValidateAndActiveParameters
    COAM_WebEM.Logout
    gNB.VerifyOnAirViaOAMUntilReady

    power_ue.Prepare UE    ue_type=${UE_TYPE}     ue_index=${0}
    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    #${5Grach_ed}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}
    #power_ue.Verify attach    ue_index=${0}    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    ${result}    run keyword and return status    GetAttachvalue
    should be true    '${result}'=='True'
#    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl     throughput=10MKbits/sec    duration=600
#    ...      apn_address=mdrbnokiacom
#    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul     throughput=5MKbits/sec    duration=600
#    ...       apn_address=mdrbnokiacom
#    sleep    60
#    process.check_Bi_throughput    ue_type=${UE_TYPE}   ultarget_throughput=5    dltarget_throughput=10
#    ...    target_avg_percent=0.5    min_percent=0.2    cell_idx=1

#    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=True

TC.5GC000742_B_017_2_Support of generic slot format_semiStatic_u1_d4
    Process.ModifyAndCommissionAndCellSearchAndAttach
    ...    original_cfgfile=${Original_CFGFILE}    modified_cfgfile=${MODIFIED_CFGFILE_2}
    ...    parameters_to_modify=PARAMS_TO_MODIFY_SemiStatic_U1_D4


TC.5GC000742_B_006_Dynamic reconfiguration of SA cell in served cell information
    Process.ModifyAndCommissionAndCheckOnair    original_cfgfile=${Original_CFGFILE}
    ...    modified_cfgfile=${MODIFIED_CFGFILE_12}    parameters_to_modify=PARAMS_TO_MODIFY_band
    gNB.Connect

    Wireshark.StartCaptureLogFromContainer    filename=CPIF_band.pcap    nodename=CPIF
    COAM_WebEM.Login
    COAM.SetParameterValue    distname=${dist_name}/NRCELL-1    filter_param=Frequency band Indicator NR
    ...    value=${band}    abbr=freqBandIndicatorNR
    ValidateAndActiveParameters
    COAM_WebEM.Logout
    Sleep   30s
    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    wireshark.DownloadLogToUTEFromContainer    filename=CPIF_band.pcap   nodename=CPIF
    gNB.Disconnect
    Wireshark.ReadLog    filename=CPIF_band.pcap   filepath=${LOG_PATH}   filter=f1ap
    Run Keyword And Continue On Failure    Wireshark.CheckExpression    expression=f1ap.freqBandIndicatorNr == ${band}
    Close wireshark on UTE
    power_ue.Prepare UE    ue_type=${UE_TYPE}
#    power_ue.UE Attach    ue_type=${UE_TYPE}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${UE_TYPE}   ue_alias=${UE_alias}   power_reset=True
    power_ue.Verify attach    ue_index=${0}    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}

TC.5GC000742_H_056_Search space in CORESET 0 with two symbols PDCCH, 48 PRBs
    Process.ModifyAndCommissionAndCheckOnair    original_cfgfile=${Original_CFGFILE}
    ...    modified_cfgfile=${MODIFIED_CFGFILE_H56}     parameters_to_modify=PARAMS_TO_MODIFY_742_H56
    ...    parameter_to_delete=PARAMS_TO_DELETE_742_H56
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    gNB.Connect
    Wireshark.StartCaptureLogFromContainer    filename=CPIF_UEattach_H56.pcap    nodename=CPIF
    Run Keyword And Continue On Failure    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=${True}
    sleep    5s
    Run Keyword And Continue On Failure    power_ue.UE Detach    ue_type=${UE_TYPE}    power_reset=True
    sleep    5s
    Run Keyword And Continue On Failure    power_ue.UE Attach    ue_type=${UE_TYPE}    power_reset=True
    Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl     throughput=10MKbits/sec    duration=120
    ...    apn_address=${SA_APN}   ue_mode=SA
    Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul     throughput=5MKbits/sec    duration=120
    ...    apn_address=${SA_APN}   ue_mode=SA
    sleep    30
    Run Keyword And Continue On Failure    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=dl    throughput=5
    Run Keyword And Continue On Failure    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=ul    throughput=2
    Run Keyword And Continue On Failure    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl
    ...    apn_address=${SA_APN}   ue_mode=SA
    Run Keyword And Continue On Failure    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul
    ...    apn_address=${SA_APN}   ue_mode=SA
    Run Keyword And Continue On Failure    power_ue.UE Detach    ue_type=${UE_TYPE}
    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
    wireshark.DownloadLogToUTEFromContainer    filename=CPIF_UEattach_H56.pcap   nodename=CPIF
    gNB.Disconnect
    #Close wireshark on UTE


####Case Level  Keywords#####

KW.CaseInit
    TestCase.Start
    log to console     Case Start

KW.CaseDestroy
    #Collect snapshot via webui
    Run Keyword And Ignore Error    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
    Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    #Run Keyword And Ignore Error    force_close_coam_webdriver
    Conn.ResetCache
    TestCase.Stop

KW.TestSuiteDestroy
    TestSuite.Stop

KW.TestSuiteInit
    TestSuite.Start
#    Import Variables        ${CFGFILE_PATH}/5GC000742/Delta.py
    Create Log Directories
    set suite variable    ${Log_PATH_Artifactory}    /root/workspace/CIT/Master/Case_Logs/
    set suite variable   ${OAM_TYPE}    COAM
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["detach_request"]    default_value=${true}
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["power_reset"]        default_value=true
    Conn.ResetCache
    gNB.FormatBTSID
    gNB.GenerateTestLineSCFs
#    ${info}     Basic.GetStreamInfo     vstring=${AF_PATH}
#    ${StreamInfo}    convert to string    ${info}
#    Run Keyword If    "${StreamInfo}"=="None"    gNB.Generate TL SCF
#    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}    TLDelta_PATH=${CFGFILE_PATH}
#    ...            TestLineSCF_cell_num=${1}   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    ...    ELSE    gNB.Generate TL SCF
#    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${info['GoldenSCF']}    TLDelta_PATH=${CFGFILE_PATH}/TLDelta_${info['StreamPrefix']}.py
#    ...            TestLineSCF_cell_num=${1}   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}

Stop and read spark log
    [Arguments]     ${msg}=NR MasterInformationBlock    ${expression}=cellBarred    ${except_res}=barred
    spark.Stop Log     ue_alias=${UE_alias}    logname=${LOG_PATH}/742_B05_${except_res}.xml
    spark.Read Log     logname=${LOG_PATH}/742_B05_${except_res}.xml
    ${res}    spark.Get Expected Val     msg=${msg}    expression=${expression}    type='other'
    Should Be Equal    ${res}    ${except_res}

Process.ModifyAndCommissionAndCellSearchAndAttach
    [Documentation]   1. Modify SCF
    ...                2. Commission Modified SCF
    ...                3. Wait gNB start and verify gNB is On Air until timeout.
    ...                4. Do cell search and ue attach and Check
    [Arguments]       ${original_cfgfile}
        ...            ${modified_cfgfile}
        ...            ${parameters_to_modify}
#    gNB.ModifySCF     InputFile=${original_cfgfile}
#    ...               OutputFile=${modified_cfgfile}
#    ...               ParameterToDelete=${MO_DELETE_SemiStatic_U1_D4}
#    ...               MOsToAdd=${MO_ADD_SemiStatic_U1_D4}
#    ...               ParamterToModify=${parameters_to_modify}
#    ...               ListParamterToModify=${LIST_PARAMETER_MODIFY_SemiStatic_U1_D4}
#    ...               ListToAdd=${LIST_ADD_SemiStatic_U1_D4}
    run   command=cp ${CFGFILE_PATH}\SCF_SBTS00.xml ${original_cfgfile}
    gNB.GenerateCaseSCF    InputFile=${original_cfgfile}    OutputFile=${modified_cfgfile}
    ...                    ResourceFolder=${CURDIR}
    ...               ParameterToDelete=MO_DELETE_SemiStatic_U1_D4
    ...               MOsToAdd=MO_ADD_SemiStatic_U1_D4
    ...               ParamterToModify=${parameters_to_modify}
    ...               ListParamterToModify=LIST_PARAMETER_MODIFY_SemiStatic_U1_D4
    ...               ListToAdd=LIST_ADD_SemiStatic_U1_D4

    gNB.CommissionWithRetry    scf_file=${modified_cfgfile}
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    #TLCommonConfig['MultiUECFG'] configed 2ues,This case only test SA ue 0
    @{SA_UE}    create list    0
    Set To Dictionary    ${TLCommonConfig['MultiUECFG']}    ue_index_for_call     ${SA_UE}
    MultiUE.L3Call  UECFG=${TLCommonConfig['MultiUECFG']}

#    txt by tiffany 4/26/2023:comment out old attach version,and replaced with new one
#    power_ue.Prepare UE    ue_type=${UE_TYPE}
#    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
#    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
#    power_ue.UE Detach     ue_type=${UE_TYPE}   ue_alias=${UE_alias}   power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
#    ${5Grach_ed}    power_ue.UE Attach    ue_type=${UE_TYPE}   ue_alias=${UE_alias}   power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
#    power_ue.Verify attach    ue_index=${0}    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}


Process.CheckCountersOfModifyCell
    selenium_coam.get_bts_name
    COAM_WEBEM.CheckBTSConutersWithTraget   #gNB-CU ConfUpdate msg sent by CU for Reconf
    ...       counter_id=M55117C00503    target_value=1
    COAM_WEBEM.CheckBTSConutersWithTraget   #gNB-CU ConfUpdate msg received by DU for Reconf
    ...       counter_id=M55117C00530    target_value=1
    COAM_WEBEM.CheckBTSConutersWithTraget   #gNB-CU ConfigUpdateAck msg sent by DU with proc for all cells succ for Reconf
    ...       counter_id=M55117C00534    target_value=1
    COAM_WEBEM.CheckBTSConutersWithTraget   #gNB-CU ConfigUpdateAck msg received by CU with proc for all cells succ for Reconf
    ...       counter_id=M55117C00507    target_value=1
    COAM_WEBEM.CheckBTSConutersWithTraget   #gNB-DU ConfigUpdate msg sent by DU for cell reconf
    ...       counter_id=M55117C00548    target_value=1
    COAM_WEBEM.CheckBTSConutersWithTraget   #gNB-DU ConfigUpdate msg received by CU for cell reconf
    ...       counter_id=M55117C00522    target_value=1

Process.ModifyAndCommissionAndCheckOnair
    [Documentation]   1. Modify SCF
    ...                2. Commission Modified SCF
    ...                3. Wait gNB start and verify gNB is On Air until timeout.
    ...                4. Do cell search and ue attach and Check
    [Arguments]        ${original_cfgfile}
        ...            ${modified_cfgfile}
        ...            ${parameters_to_modify}
        ...            ${parameter_to_delete}='NULL'
#    gNB.ModifySCF        InputFile=${original_cfgfile}
#    ...                  OutputFile=${modified_cfgfile}
#    ...                  ParamterToModify=${parameters_to_modify}
#    ...                  ParameterToDelete=${parameter_to_delete}
    gNB.GenerateCaseSCF    InputFile=${original_cfgfile}    OutputFile=${modified_cfgfile}
    ...                    ResourceFolder=${CURDIR}
    ...                    ParamterToModify=${parameters_to_modify}
    ...                    ParameterToDelete=${parameter_to_delete}
    gNB.CommissionWithRetry    scf_file=${modified_cfgfile}
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady

ValidateAndActiveParameters
    [Arguments]    ${activate_plan_despite_errors}=True
    ${error}    selenium_coam.validate_plan
    log    ${error}
    Run Keyword If    '${activate_plan_despite_errors}'=='True'   selenium_coam.activate_plan    activate_plan_despite_errors=True
    ...    ELSE      selenium_coam.activate_plan

Modify GoldenSCF to TestLineSCF
    gNB.GenerateTestLineSCFs
#    run    cp ${GoldenSCF_ON_GIT}/${GoldenSCF} ${LOG_PATH}/GoldenSCF.xml
#    gNB.ReplaceSCFbtsID     SCFFilePath=${LOG_PATH}/GoldenSCF.xml
#	...                     MRBTSID=${MRBTS_ID}
#    ...                     NRBTSID=${NRBTS_ID}
#    gNB.ReplaceDeltaID     DeltaPath=${TLDelta_PATH}/TLDelta.py
#    ...                    MRBTSID=${MRBTS_ID}
#    ...                    NRBTSID=${NRBTS_ID}
#    gNB.ModifySCF    InputFile=${LOG_PATH}/GoldenSCF.xml
#    ...              OutputFile=${Original_CFGFILE}
#    ...              ParameterToDelete=${TL_PARAMS_TO_DELETE_1CELL}
#    ...              MOsToAdd=${TL_ADD_MOS_1CELL}
#    ...              ParamterToModify=${TL_PARAMS_TO_MODIFY_1CELL}
#    ...              ListParamterToModify=${TL_LIST_PARAMS_TO_MODIFY_1CELL}
#    ...              ListToAdd=${TL_LIST_TO_ADD_1CELL}

COAM.SetParameterValue
    [Arguments]    ${distname}    ${filter_param}    ${value}    ${abbr}
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=${filter_param}
    ...    new_value=${value}    abbr=${abbr}

GetAttachvalue
    [Arguments]    ${power_reset}=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=${power_reset}
    sleep    10s
    ${5Grach_ed}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=${power_reset}
    ${Rach_status}    run keyword and return status    power_ue.Verify attach    ue_index=${0}
    ...    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    should be true    '${Rach_status}'=='True'


Close Wireshark on ute
    Conn.ConnectWithTimeout    ${ALIAS_UTE}
    ssh.execute     command=ps -ef|grep -i wireshark    connection=${ALIAS_UTE}
    ssh.send command    command=killall wireshark     connection=${ALIAS_UTE}
    Conn.Disconnect      ${ALIAS_UTE}
    sleep  2s


Setup My Suite
    TestSuite.Start
    gNB.FormatBTSID
#    Import Variables    ${CFGFILE_PATH}5GC000742/Delta.py
    Create Log Directories
    set suite variable    ${Log_PATH_Artifactory}    /root/workspace/CIT/Master/Case_Logs/
    set suite variable   ${OAM_TYPE}    COAM
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["detach_request"]    default_value=${true}
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["power_reset"]        default_value=true
    Conn.ResetCache
    #Modify GoldenSCF to TestLineSCF
    gNB.GenerateTestLineSCFs
    Run Keyword And Ignore Error    COAMGetCellBand

COAMGetCellBand
    COAM_WebEM.Login
    &{output}    selenium_coam.get_cell_info
    ${result}    Remove String    ${output}[Band]    n
    set suite variable    ${band}    ${result}
    COAM_WebEM.Logout


TestSuilt.Destroy
    TestSuite.Stop

UE recovery to initial state
    Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${UE_TYPE}     ue_index=${0}
    ...    detach_request=${false}
    Run Keyword And Ignore Error    power_ue.UE Attach    ue_type=${UE_TYPE}    power_reset=true
    sleep    10s
    Run Keyword And Ignore Error    power_ue.UE Attach    ue_type=${UE_TYPE}
    sleep    20s
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${UE_TYPE}
    sleep    20s
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${UE_TYPE}    power_reset=true
    sleep    10s
    Run Keyword And Ignore Error    power_ue.UE Attach    ue_type=${UE_TYPE}    power_reset=true
