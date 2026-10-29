*** Settings ***
Documentation     author: Frank Luo
...               Group: HGZ_SG1
...               contact: frank.s.luo@nokia-sbell.com

Resource          ../../5GC000496_C/Resources/L3Call.robot
#Resource         ../../common/made_siso_common.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Library           ../../../../SISO/RAN_PZ_HAZ_34/5GC001278/Library/get_bts_info.py    WITH NAME    lib\
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.config.scf    WITH NAME    scf
Library           XML   WITH NAME    ParseXML
Library           OperatingSystem
Library           Process
Library           Collections
Library           DateTime
Library           String
Library           ../../5GC000638/Resources/coam_close.py
#Variables         TestData/variables.py
#Variables         ${CFGFILE_ON_GIT}/Delta_SCF.py
#Variables         ${TLDelta_PATH_ON_GIT}TLDelta.py

*** Variables ***
${UPDATE_FILE_PATH}         /opt/ute/tmp/
${Local_CFGFILE_PATH}       /home/ute/TAF/cfgfile/
${MODIFIED_CFGFILE_TLSCF}   /home/ute/TAF/cfgfile/modified_SCF/


#${TLDelta_PATH_ON_GIT}      /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${GoldenSCF_ON_GIT}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/
#${CFGFILE_ON_GIT}           ${CFGFILE_PATH}/5GC001473/
#${MODIFIED_CFGFILE_NSA}    ${CFGFILE_ON_GIT}90M_NSA_SCF.xml
#${MODIFIED_CFGFILE_SA}    ${CFGFILE_ON_GIT}90M_SA_SCF.xml
#${MODIFIED_CFGFILE_1}       ${CFGFILE_ON_GIT}1473H_QAM64_2x2MIMO.xml
#${MODIFIED_CFGFILE_2}       ${CFGFILE_ON_GIT}1473G_QAM256_2x2MIMO.xml
#${MODIFIED_CFGFILE_3}       ${CFGFILE_ON_GIT}1473G_QAM256_4x2MIMO.xml

${MRBTS}                    ${tl.gnbs[0].instance_id}
${NRBTS}                    ${tl.gnbs[0].global_bts_id}

${mrbtsID}                   ${tl.gnbs[0].instance_id}
${nrbtsID}                   ${tl.gnbs[0].global_bts_id}

${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}
${EGATE_CFG_NAME}           ${tl.core.cfg_filename}
${WTS_FILE_PATH}            ${tl.core.dir_path}
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${IMSI}                     ${tl.ues[0].imsi}
${AMF_IP}                   ${tl.core.mme_ip}
${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}
${UE_alias}                 UE_0
${ALIAS_5GC}                5gc
${ALIAS_AMF}                AMF

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


${MRBTS_ID}        ${tl.gnbs[0].instance_id}
${NRBTS_ID}        ${tl.gnbs[0].global_bts_id}


&{fault_10}                 faultId=${10}    source=RMOD_R-1    severity=Critical    # No connection to unit
${alarm_filter_0}           1807
${alarm_filter_1}           No connection to unit
${CPRI_link_status}         /tmp/CPRI_link.log
${VM_CPRI_link}             /tmp/CPRI/
${vm_path}                  /home/ute/
${create_backup_dir}        backupscf/

#${UE_TYPE}                  huawei
${asik_dir}                 /ffs/run/config/toor4nsn/

${remote_dir}=    /mnt/sw/
${local_dir}=   ${CURDIR}/
${file_name}=    DIR1
${correct_file}=   DIR2
${log_file_name}=   ru_log
${log_remote_dir}=    /ram/
${log_local_dir}=   ${OUTPUT_DIR}/


#@{bandswith}   60   80   100
#@{bandswith}    90
#${cell_index}   1

#${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}
${UPDATE_FILE_PATH}         /opt/ute/tmp/
${Local_CFGFILE_PATH}       /home/ute/TAF/cfgfile/
${MODIFIED_CFGFILE_TLSCF}   /home/ute/TAF/cfgfile/modified_SCF/

#${CFGFILE_PATH}           /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
${lua_script_path}       ${Local_CFGFILE_PATH}luashark/generated_luashark/luashark.lua

${AMF_IP}                   ${tl.core.mme_ip}
${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}
${UE_alias}                 UE_0
${ALIAS_5GC}                5gc
${ALIAS_ASIK}               asik
${ALIAS_ASIK_SLAVE}         asik_slave    ##
${ALIAS_UTE}                ute    ##

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

${MRBTS_ID}     ${tl.gnbs[0].instance_id}
${NRBTS_ID}     ${tl.gnbs[0].global_bts_id}

${dist_name}    ${MRBTS_ID}/${NRBTS_ID}

*** Keywords ***


####Case Level  Keywords#####
TC.Cell_Setup_With_Configed_BandWidth
    [Documentation]  Main test Steps:
    ...    modify 90M and NSA to SCF and commission and wait cell on air
#    COAM_WebEM.Lock Cell and SNSSAI
    Process.ModifyAndCommissionAndCheckOnair    original_cfgfile=${Original_CFGFILE}    modified_cfgfile=${MODIFIED_CFGFILE_NSA}
    ...    parameters_to_modify=${PARAMS_TO_MODIFY_1473_90M_NSA}    parameters_to_delete=${PARAMS_TO_DELETE_1473_90M_NSA}
    ...    mo_to_add=${TL_ADD_MOS_1473_90M_NSA}    list_parameter_to_modify=${TL_LIST_PARAMS_TO_MODIFY_1473_90M_NSA}
    ...    list_to_add=${TL_LIST_TO_ADD_1473_90M_NSA}

TC.L3_Call_Setup_With_Configed_BandWidth
    [Documentation]  Main test Steps:
    ...    modify 90M and SA to SCF and commission and , then do L3CALL and start UL and DL traffic
    ${StreamInfo}        Basic.GetStreamInfo    StreamInfoName=STREAM_INFOs
    ${StreamPrefix}      set variable    ${StreamInfo['StreamPrefix']}
    ${GoldenSCF}         set variable    ${GoldenSCF_ON_GIT}${StreamInfo['GoldenSCF']}
    gNB.ReplaceSwconfig
    run   command=cp ${GoldenSCF} ${Original_CFGFILE}
    gNB.ModifySCF     InputFile=${Original_CFGFILE}
    ...               OutputFile=${MODIFIED_CFGFILE_1}
    ...               ParameterToDelete=${PARAMS_TO_DELETE_1473_90M_SA}
    ...               MOsToAdd=${TL_ADD_MOS_1473_90M_SA}
    ...               ParamterToModify=${PARAMS_TO_MODIFY_1473_90M_SA}
    ...               ListParamterToModify=${TL_LIST_PARAMS_TO_MODIFY_1473_90M_SA}
    ...               ListToAdd=${TL_LIST_TO_ADD_1473_90M_SA}
    gNB.CommissionWithRetry    scf_file=${MODIFIED_CFGFILE_1}    model=HBTE
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    wait until keyword succeeds    20min    10s    COAM_Admin.CheckAllCellsOnair
    wait until keyword succeeds    20min    10s    COAM_Admin.CheckAllCellsOnair     type=lte
    @{SA_UE}    create list    0
    Set To Dictionary    ${TLCommonConfig['MultiUECFG']}    ue_index_for_call      ${SA_UE}
    MultiUE.L3Call    UECFG=${TLCommonConfig['MultiUECFG']}

#    5GC.DeleteIMSI   imsi=${IMSI}  AMF_IP=${5GC_IP}   AMF_USERNAME=${5GC_USERNAME}
#    ...        AMF_PASSWORD=${5GC_PASSWORD}  alias=${ALIAS_AMF}
#    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${CASE_INPUT_5GC001473["1473_K"]["ue_index"]}
#    ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
#    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
#    sleep    10
#    power_ue.UE Detach    ue_type=${UE_TYPE}    power_reset=True    ue_index=${CASE_INPUT_5GC001473["1473_K"]["ue_index"]}
#    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
#    sleep    10
#    ${5Grach_ed}  power_ue.UE Attach    ue_type=${UE_TYPE}   ue_index=${CASE_INPUT_5GC001473["1473_K"]["ue_index"]}
#    ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
#    sleep    20
#    power_ue.Verify attach    ue_type=${UE_TYPE}   4G_check=false   5Grach_ed=${5Grach_ed}
#    power_ue.Start traffic    ue_type=${UE_TYPE}    ue_index=${CASE_INPUT_5GC001473["1473_K"]["ue_index"]}
#    ...    direction=ul     throughput=2MKbits/sec    duration=800    apn_address=${CASE_INPUT_5GC001473["1473_K"]["apn"]}
##    sleep    30
##    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=ul    throughput=0.2    start_offset=${0}
#    power_ue.Start traffic    ue_type=${UE_TYPE}    ue_index=${CASE_INPUT_5GC001473["1473_K"]["ue_index"]}
#    ...    direction=dl     throughput=5MKbits/sec    duration=800    apn_address=${CASE_INPUT_5GC001473["1473_K"]["apn"]}
##    sleep    30
##    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=dl    throughput=0.5    start_offset=${0}
#    sleep    60
##    ${tput_log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    duration=120
##    COAM_WebEM.Login
##    &{output}    selenium_coam.get_cell_info
##    ${list_of_cell_ids}    Create list   &{output}[NR cell ID]
##    Power_ue.Check Bi Tput    ue_type=${UE_TYPE}    log=${tput_log}    cells=${list_of_cell_ids}
##    ...    ultarget_throughput=0.2    dltarget_throughput=0.5
#    process.check_Bi_throughput    ue_type=${UE_TYPE}    ue_index=${CASE_INPUT_5GC001473["1473_K"]["ue_index"]}
#    ...    ultarget_throughput=2    dltarget_throughput=5
#    ...    cell_idx=${CASE_INPUT_5GC001473["1473_K"]["cell_index"]}    target_avg_percent=0.9    min_percent=0.7
#
#    power_ue.Stop traffic    ue_type=${UE_TYPE}    ue_index=${CASE_INPUT_5GC001473["1473_K"]["ue_index"]}    direction=dl
#    ...    apn_address=${CASE_INPUT_5GC001473["1473_K"]["apn"]}
#    power_ue.Stop traffic    ue_type=${UE_TYPE}    ue_index=${CASE_INPUT_5GC001473["1473_K"]["ue_index"]}    direction=ul
#    ...    apn_address=${CASE_INPUT_5GC001473["1473_K"]["apn"]}
##   power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${CASE_INPUT_5GC001473["1473_K"]["ue_index"]}    power_reset=True
##   Run Keyword And Continue On Failure   L3_Call

TC.UL_and_DL_LA_data_traffic_QAM64_2x2MIMO_SA
    gNB.ModifySCF     InputFile=${Original_CFGFILE}
    ...               OutputFile=${MODIFIED_CFGFILE_1}
    ...               ParameterToDelete=${PARAMS_TO_DELETE_1473_90M_SA}
    ...               MOsToAdd='NULL'
    ...               ParamterToModify=${PARAMS_TO_MODIFY_1473_90M_SA}
    ...               ListParamterToModify='NULL'
    ...               ListToAdd='NULL'
    gNB.CommissionWithRetry    scf_file=${MODIFIED_CFGFILE_1}    model=HBTE
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    5GC.DeleteIMSI   imsi=${IMSI}  AMF_IP=${5GC_IP}   AMF_USERNAME=${5GC_USERNAME}
    ...        AMF_PASSWORD=${5GC_PASSWORD}  alias=${ALIAS_AMF}
    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=${True}
    ${5Grach_ed}  power_ue.UE Attach    ue_type=${UE_TYPE}
    power_ue.Verify attach    ue_type=${UE_TYPE}   4G_check=false   5Grach_ed=${5Grach_ed}
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl     throughput=800MKbits/sec    duration=1200
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul     throughput=70MKbits/sec    duration=1200
    sleep    60
    COAM_Admin.Login    alias=GNB_OAM
    power_ue.Check peak throughput    ue_type=${ue_type}    theory_dl_peak=488.7    theory_ul_peak=51.6
        ...    total_time=10    interval=5s    duration_time_for_once=100s
        ...    acceptable_tput_percentage=0.3
    COAM_Admin.Logout   connection=GNB_OAM
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul
    power_ue.UE Detach    ue_type=${UE_TYPE}

TC.UL_and_DL_LA_Peak_QAM256_2x2MIMO_SA
    gNB.ModifySCF     InputFile=${Original_CFGFILE}
    ...               OutputFile=${MODIFIED_CFGFILE_2}
    ...               ParameterToDelete=${PARAMS_TO_DELETE_1473_90M_SA_256QAM}
    ...               MOsToAdd='NULL'
    ...               ParamterToModify=${PARAMS_TO_MODIFY_1473_90M_SA_256QAM}
    ...               ListParamterToModify='NULL'
    ...               ListToAdd='NULL'
    gNB.CommissionWithRetry    scf_file=${MODIFIED_CFGFILE_2}    model=HBTE
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    5GC.DeleteIMSI   imsi=${IMSI}  AMF_IP=${5GC_IP}   AMF_USERNAME=${5GC_USERNAME}
    ...        AMF_PASSWORD=${5GC_PASSWORD}  alias=${ALIAS_AMF}
    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=${True}
    ${5Grach_ed}  power_ue.UE Attach    ue_type=${UE_TYPE}
    power_ue.Verify attach    ue_type=${UE_TYPE}   4G_check=false   5Grach_ed=${5Grach_ed}
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl     throughput=800MKbits/sec    duration=1200
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul     throughput=70MKbits/sec    duration=1200
    sleep    60
    COAM_Admin.Login    alias=GNB_OAM
    power_ue.Check peak throughput    ue_type=${ue_type}    theory_dl_peak=645.7    theory_ul_peak=51.6
        ...    total_time=10    interval=5s    duration_time_for_once=100s
        ...    acceptable_tput_percentage=0.7
    COAM_Admin.Logout   connection=GNB_OAM
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul
    power_ue.UE Detach    ue_type=${UE_TYPE}


TC.UL_and_DL_LA_data_traffic_QAM256_4x4MIMO_SA
    gNB.ModifySCF     InputFile=${Original_CFGFILE}
    ...               OutputFile=${MODIFIED_CFGFILE_3}
    ...               ParameterToDelete=${PARAMS_TO_DELETE_1473_90M_SA_4layer}
    ...               MOsToAdd=${PARAMS_TO_ADD_MOS_1473_90M_SA_4layer}
    ...               ParamterToModify=${PARAMS_TO_MODIFY_1473_90M_SA_4layer}
    ...               ListParamterToModify=${LIST_PARAMS_TO_MODIFY_1473_90M_SA_4layer}
    ...               ListToAdd=${LIST_TO_ADD_1473_90M_SA_4layer}
    gNB.CommissionWithRetry    scf_file=${MODIFIED_CFGFILE_3}    model=HBTE
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    5GC.DeleteIMSI   imsi=${IMSI}  AMF_IP=${5GC_IP}   AMF_USERNAME=${5GC_USERNAME}
    ...        AMF_PASSWORD=${5GC_PASSWORD}  alias=${ALIAS_AMF}
    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=${True}
    ${5Grach_ed}  power_ue.UE Attach    ue_type=${UE_TYPE}
    power_ue.Verify attach    ue_type=${UE_TYPE}   4G_check=false   5Grach_ed=${5Grach_ed}
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl     throughput=1500MKbits/sec    duration=1200
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul     throughput=70MKbits/sec    duration=1200
    sleep    60
    wait until keyword succeeds    5 min    30s    COAM_Admin.Login    alias=GNB_OAM
    power_ue.Check peak throughput    ue_type=${ue_type}    theory_dl_peak=1255.7    theory_ul_peak=51.6
        ...    total_time=10    interval=5s    duration_time_for_once=100s
        ...    acceptable_tput_percentage=0.6
    COAM_Admin.Logout   connection=GNB_OAM
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul
    power_ue.UE Detach    ue_type=${UE_TYPE}

####Case Level Keywords#####

Setup suite
    TestSuite.Start
    set suite variable   ${CFGFILE_ON_GIT}           ${CFGFILE_PATH}/5GC001473/
    set suite variable   ${TLDelta_PATH}              ${CFGFILE_ON_GIT}
    set suite variable   ${MODIFIED_CFGFILE_NSA}    ${CFGFILE_ON_GIT}90M_NSA_SCF.xml
    set suite variable   ${MODIFIED_CFGFILE_SA}    ${CFGFILE_ON_GIT}90M_SA_SCF.xml
    set suite variable   ${MODIFIED_CFGFILE_1}       ${CFGFILE_ON_GIT}1473H_QAM64_2x2MIMO.xml
    set suite variable   ${MODIFIED_CFGFILE_2}       ${CFGFILE_ON_GIT}1473G_QAM256_2x2MIMO.xml
    set suite variable   ${MODIFIED_CFGFILE_3}       ${CFGFILE_ON_GIT}1473G_QAM256_4x2MIMO.xml
    Import Variables    ${CFGFILE_ON_GIT}/Delta_SCF.py
    Create Log Directories
    set suite variable    ${Log_PATH_Artifactory}    /root/workspace/CIT/Master/Case_Logs/
    set suite variable   ${OAM_TYPE}    COAM
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["detach_request"]    default_value=${true}
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["power_reset"]        default_value=true
#     Run Keyword And Ignore Error        spark.power_off    ue_alias=${UE_alias}
#    ${outputfile}    gNB.Generate TL SCF
#	...                  GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}   TLDelta_PATH=${CFGFILE_PATH}
#	...                  TestLineSCF_cell_num=${1}    cell_type=Both
#	...                  MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    ${outputfile}   gNB.GenerateTestLineSCFs
	set suite variable    ${Original_CFGFILE}    ${outputfile}
	gNB.FormatBTSID    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
	set suite variable    ${dist_name}   ${MRBTS_ID}/${NRBTS_ID}


#    ChangeSwcofigByFlag    flag=0x10043    value=50002
#    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    Conn.ResetCache

Teardown Suite
    TestSuite.Stop

Setup case
    TestCase.Start
    log to console     Case Start
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}

Teardown case
    #COAM_WebEM.Collect snapshot via webui
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul
    Run Keyword And Ignore Error    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
    Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    force_close_coam_webdriver
    Conn.ResetCache
    TestCase.Stop

Process.ModifyAndCommissionAndCheckOnair
    [Documentation]    1. Modify SCF
    ...                2. Commission Modified SCF
    ...                3. Wait gNB start and verify gNB is On Air until timeout.
    ...                4. Do cell search and ue attach and Check
    [Arguments]       ${original_cfgfile}
    ...               ${modified_cfgfile}
    ...               ${parameters_to_modify}='NULL'
    ...               ${parameters_to_delete}='NULL'
    ...               ${mo_to_add}='NULL'
    ...               ${list_parameter_to_modify}='NULL'
    ...               ${list_to_add}='NULL'
    gNB.ModifySCF        InputFile=${original_cfgfile}
    ...                  OutputFile=${modified_cfgfile}
    ...                  ParamterToModify=${parameters_to_modify}
    ...                  ParameterToDelete=${parameters_to_delete}
    ...                  MOsToAdd=${mo_to_add}
    ...                  ListParamterToModify=${list_parameter_to_modify}
    ...                  ListToAdd=${list_to_add}
    gNB.CommissionWithRetry    scf_file=${modified_cfgfile}     model=HBTE
    wait until keyword succeeds   20min   1min    gNB.VerifyOnAirViaOAMUntilReady

