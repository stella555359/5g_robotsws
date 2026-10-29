*** Settings ***
Documentation    author: Lu Ming
...               contact: ming.lu@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC0002334_AE_742
Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Variables         ${CFGFILE_PATH}5GC002334/Delta.py
#Variables         ${CFGFILE_PATH}TLDelta.py
Library           ../../5GC000638/Resources/coam_close.py



*** Variables ***
${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}
${UPDATE_FILE_PATH}         /opt/ute/tmp/
${Local_CFGFILE_PATH}       /home/ute/TAF/cfgfile/
#${CFGFILE_PATH}           /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
${lua_script_path}       ${Local_CFGFILE_PATH}luashark/generated_luashark/luashark.lua
${Original_CFGFILE}      ${LOG_PATH}/TestLineSCF1Cell_Both.xml
${MODIFIED_CFGFILE_1}    ${CFGFILE_PATH}5GC002334/barred.xml
${MODIFIED_CFGFILE_2}    ${CFGFILE_PATH}5GC002334/semiStatic_u1_d4.xml
${MODIFIED_CFGFILE_3}    ${CFGFILE_PATH}5GC002334/SCF_742c.xml
${MODIFIED_CFGFILE_4}    ${CFGFILE_PATH}5GC002334/SCF_742Y.xml
${MODIFIED_CFGFILE_TLSCF}   /home/ute/TAF/cfgfile/modified_SCF/
#${GoldenScf_PATH}           /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG


${MRBTS}                    MRBTS-${tl.gnbs[0].instance_id}
${NRBTS}                    NRBTS-${tl.gnbs[0].global_bts_id}

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
            
${PB_PORT}                  4001
${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
            
${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}



${MRBTS_1}    MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_1}    NRBTS-${tl.gnbs[0].global_bts_id}

${dist_name}    ${MRBTS_1}/${NRBTS_1}

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
TC.5GC000742_B_005_Dynamic reconfiguration of SA cell in MIB and SIB1
    [Documentation]  Main test Steps:
    ...   1) modify cell to barred and wait cell on air
    ...   2) start Huawei UE to attach(should be fail)
    ...   3) Check MIB from UE log(should be barred)
    ...   4) modify cell to notBarred and wait cell on air
    ...   5) start Huawei UE to attach(should be success)
    ...   4) modify parameter for SIB1 and wait cell on air
    ...   5) start Huawei UE to attach and check modified parameter in SIB1
    [Tags]    5GC000742_B      CRT_TRUNK    CRT_20B    CRT_21A
#    [Setup]    Setup case
#    [Teardown]  Teardown case
    gNB.ModifySCF        InputFile=${Original_CFGFILE}
    ...                  OutputFile=${MODIFIED_CFGFILE_1}
    ...                  ParameterToDelete=${PARAMS_TO_DELETE_barred}
    ...                  ParamterToModify=${PARAMS_TO_MODIFY_barred}
    gNB.CommissionWithRetry    scf_file=${MODIFIED_CFGFILE_1}
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend

    power_ue.Prepare UE    ue_type=${UE_TYPE}     ue_index=${0}
    #${5Grach_ed}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}
    #${Rach_status}    run keyword and return status    power_ue.Verify attach    ue_index=${0}
    #...    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    ${result}    run keyword and return status    GetAttachvalue
    should be true    '${result}'=='False'
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=True

    COAM_WebEM.Login
    COAM.SetParameterValue    distname=${dist_name}/NRCELL-1    filter_param=Cell Barred
    ...    value=notBarred    abbr=cellBarred
    ValidateAndActiveParameters
    COAM_WebEM.Logout
    gNB.VerifyOnAirViaOAMUntilReady

    power_ue.Prepare UE    ue_type=${UE_TYPE}     ue_index=${0}
    #${5Grach_ed}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}
    #power_ue.Verify attach    ue_index=${0}    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    ${result}    run keyword and return status    GetAttachvalue
    should be true    '${result}'=='True'
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

    COAM_WebEM.Login
    COAM.SetParameterValue    distname=${dist_name}/NRCELL-1    filter_param=Timer t301
    ...    value=300ms    abbr=t301
    ValidateAndActiveParameters
    COAM_WebEM.Logout
    Sleep    5s

    power_ue.Prepare UE    ue_type=${UE_TYPE}     ue_index=${0}
    #${5Grach_ed}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}
    #power_ue.Verify attach    ue_index=${0}    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    ${result}    run keyword and return status    GetAttachvalue
    should be true    '${result}'=='True'
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}


TC.5GC000742_C_023_Reconfiguration of SIBs (MCS9)
    [Documentation]  Main test Steps:
    ...   1) modify parameter for SIB2-SIB5 in SCF and commission and wait cell on air
    ...   2) modify parameter for SIB2-SIB5 by WEBUI and active
    ...   3) start Huawei UE to attach(should be success)
    ...   3) check modified parameter in SIB2-SIB5 from UE logs
    [Tags]    5GC000742_B    CRT_20A    CRT_TRUNK    CRT_20B    CRT_21A
#    [Setup]    Setup case
#    [Teardown]  Teardown case
    gNB.ModifySCF        InputFile=${Original_CFGFILE}
    ...                  OutputFile=${MODIFIED_CFGFILE_3}
    ...                  ParameterToDelete=${PARAMS_TO_DELETE_742C}
    ...                  ParamterToModify=${PARAMS_TO_MODIFY_742C}
    ...                  ListToAdd=${LIST_TO_ADD_742C}
    gNB.CommissionWithRetry    scf_file=${MODIFIED_CFGFILE_3}
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
    #${5Grach_ed}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}
    #power_ue.Verify attach    ue_index=${0}    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    ${result}    run keyword and return status    GetAttachvalue
    should be true    '${result}'=='True'
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}


Wireshark.StartCaptureLog
    [Arguments]    ${listen_port}     ${log_dir}     ${filename}    ${connection}
    ssh.send command    tcpdump -s 0 -i ${listen_port} -w ${log_dir}/${filename} &>/dev/null &    connection=${connection}

Wireshark.Action.Capture
    [Arguments]   ${filename}    ${conn}    ${listen_port}=fp0    ${log_dir}=/tmp
    ASIK.Connect   alias=${conn}
    Wireshark.StartCaptureLog    listen_port=fp0    log_dir=/tmp     filename=${filename}    connection=${conn}
    sleep    2

Wireshark.Action.Stop_And_Download
    [Arguments]   ${conn}=${ALIAS_ASIK}    ${filename}=tcpdumpL2L1_filtering_off.pcap0
    ...   ${log_dir}=/tmp    ${listen_port}=fp0    ${localname}=${filename}
    sleep    2
    Wireshark.StopCapturinglog    connection=${conn}    listen_port=${listen_port}
    sleep    2
    Wireshark.DownloadLogToUTE    filename=${filename}   connection=${conn}    localname=${localname}
    sleep    5

ASIK.Connect
    [Arguments]   ${alias}
    Run Keyword And Continue On Failure  ssh.Connect to    hostname=${ASIK_IP}
     ...    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}  alias=${alias}

ASIK.Disconnect
     [Arguments]   ${alias}
    Run Keyword And Continue On Failure  Conn.Disconnect    ${alias}

Clear UE info from AMF
   [Arguments]  ${ue_imsi}=${IMSI}   ${retry_times}=2
   Connect to 5GC
   ${imsi_presence}=    csn.execute   cmm subscriber show --imsi ${ue_imsi} | head -n 7 | grep GENERALINFO    connection=${ALIAS_5GC}
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    csn.execute   cmm subscriber delete --imsi ${ue_imsi}    connection=${ALIAS_5GC}
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    sleep   2min    # WA, make IMSI clear opeation is done completely.
   Disconnect from 5GC

Connect to 5GC
    csn.connect to    ${5GC_IP}  ${5GC_USERNAME}  ${5GC_PASSWORD}    alias=${ALIAS_5GC}

Disconnect from 5GC
    csn.disconnect    connection=${ALIAS_5GC}

Process.ModifyAndCommissionAndCellSearchAndAttach
    [Documentation]   1. Modify SCF
    ...                2. Commission Modified SCF
    ...                3. Wait gNB start and verify gNB is On Air until timeout.
    ...                4. Do cell search and ue attach and Check
    [Arguments]       ${original_cfgfile}
        ...            ${modified_cfgfile}
        ...            ${parameters_to_modify}
    ModifyParametersToSCF        input_scf=${original_cfgfile}
    ...                  output_scf=${modified_cfgfile}
    ...                  modify_parameters_lists=${parameters_to_modify}
    gNB.CommissionWithRetry    scf_file=${modified_cfgfile}
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    ${result}    run keyword and return status    GetAttachvalue
    should be true    '${result}'=='True'

ModifyParametersToSCF
    [Documentation]   Modify Parameters in ${modify_parameters_lists} to ${input_scf}
    [Arguments]    ${input_scf}    ${output_scf}    ${modify_parameters_lists}
    ${exist}=    run keyword and return status    File Should Exist    ${CFGFILE_PATH}5GC002334/Delta.py
    run keyword if    ${exist}    commissioning.modify_scf    input_scf=${input_scf}
    ...    output_scf=${output_scf}    parameters_lists=${modify_parameters_lists}


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


COAM.SetParameterValue
    [Arguments]    ${distname}    ${filter_param}    ${value}    ${abbr}
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=${filter_param}
    ...    new_value=${value}    abbr=${abbr}

ValidateAndActiveParameters
    [Arguments]    ${activate_plan_despite_errors}=True
    ${error}    selenium_coam.validate_plan
    log    ${error}
    Run Keyword If    '${activate_plan_despite_errors}'=='True'   selenium_coam.activate_plan    activate_plan_despite_errors=True
    ...    ELSE      selenium_coam.activate_plan

Close Wireshark on ute
    Conn.ConnectWithTimeout    ${ALIAS_UTE}
    ssh.execute     command=ps -ef|grep -i wireshark    connection=${ALIAS_UTE}
    ssh.send command    command=killall wireshark     connection=${ALIAS_UTE}
    Conn.Disconnect      ${ALIAS_UTE}
    sleep  2s

Process.ModifyAndCommissionAndCheckOnair
    [Documentation]   1. Modify SCF
    ...                2. Commission Modified SCF
    ...                3. Wait gNB start and verify gNB is On Air until timeout.
    ...                4. Do cell search and ue attach and Check
    [Arguments]       ${original_cfgfile}
        ...            ${modified_cfgfile}
        ...            ${parameters_to_modify}
    gNB.ModifySCF        InputFile=${original_cfgfile}
    ...                  OutputFile=${modified_cfgfile}
    ...                  ParamterToModify=${parameters_to_modify}
    gNB.CommissionWithRetry    scf_file=${modified_cfgfile}
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady

Setup My Suite
    Import Variables      ${CFGFILE_PATH}5GC002334/Delta.py
    TestSuite.Start
    Create Log Directories
    set suite variable    ${Log_PATH_Artifactory}    /root/workspace/CIT/Master/Case_Logs/
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    Modify GoldenSCF to TestLineSCF

Modify GoldenSCF to TestLineSCF
    run    cp ${GoldenSCF_ON_GIT}/${GoldenSCF} ${LOG_PATH}/GoldenSCF.xml
    gNB.ReplaceSCFbtsID     SCFFilePath=${LOG_PATH}/GoldenSCF.xml
	...                     MRBTSID=${MRBTS}
    ...                     NRBTSID=${NRBTS}
    gNB.ReplaceDeltaID     DeltaPath=${TLDelta_PATH}/TLDelta.py
    ...                    MRBTSID=${MRBTS}
    ...                    NRBTSID=${NRBTS}
    gNB.ModifySCF    InputFile=${LOG_PATH}/GoldenSCF.xml
    ...              OutputFile=${Original_CFGFILE}
    ...              ParameterToDelete=${TL_PARAMS_TO_DELETE_1CELL}
    ...              MOsToAdd=${TL_ADD_MOS_1CELL}
    ...              ParamterToModify=${TL_PARAMS_TO_MODIFY_1CELL}
    ...              ListParamterToModify=${TL_LIST_PARAMS_TO_MODIFY_1CELL}
    ...              ListToAdd=${TL_LIST_TO_ADD_1CELL}

KW.CaseDestroy
    #Collect snapshot via webui
    Run Keyword And Ignore Error    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
    Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    force_close_coam_webdriver
    Conn.ResetCache
    TestCase.Stop

Collect snapshot via webui
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}

KW.CaseInit
    TestCase.Start
    log to console     Case Start

TestSuilt.Destroy
    TestSuite.Stop

GetAttachvalue
    [Arguments]
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=True
    sleep    10s
    ${5Grach_ed}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=True
    ${Rach_status}    run keyword and return status    power_ue.Verify attach    ue_index=${0}
    ...    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    should be true    '${Rach_status}'=='True'
