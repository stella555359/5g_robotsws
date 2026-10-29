*** Settings ***
Documentation      author: Zhang Xuewen
...                contact: xuewen.zhang@nokia-sbell.com
...                This robot file is for Operability Capacity & Performance

Resource          OMKPI_KW_GNB.robot
Resource          OMKPI_KW_WebEM.robot
Resource    ../../../../../resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource     ../../../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009576_SG05/resource/CB009576_X_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/SISO_Pre.robot
Library    taf.collectors.core   WITH NAME   core
Library    taf.sbts.oam.coam.admin  WITH NAME   admin
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.selenium.sbts   WITH NAME   selenium_sbts
# Variables           ./OAMKPI_TLDelta.py



*** Variables ***
${CFGFILE_PATH}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
${GoldenSCF_ON_GIT}     /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/
${UPDATE_FILE_PATH}     /home/ute/Download_gNB_Package
#Configure the TL specific variable
${USER_LOG_DIR}        /opt/ute/Logs

${UTE_IP}    ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}

${ASIK_LMP_IP}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_LMP_USERNAME}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_LMP_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${ASIK_LMP_IP_URL}          https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}             ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${WEBUI_IP}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}

${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${distname}                 ${MRBTS_ID}/${NRBTS_ID}

${PB_ASIK_IP}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${model}    ${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}

${LOGIN_BOX}=    xpath=//*[@id="login-view"]/div/div[1]/div[1]/ng-view/div/form/div[2]/input
${PASS_BOX}=    xpath=//*[@id="login-view"]/div/div[1]/div[1]/ng-view/div/form/div[3]/input
${URL_LMP}       192.168.255.129
${LEGAL}=     xpath=//html/body/div[1]/div/div/ui-modal-renderer/login-banner-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button[1]/button
${LOGIN_BUTTON}=    xpath=//*[@id="login-view"]/div/div[1]/div[1]/ng-view/div/form/div[4]/div[1]/div/ui-button[1]/button

##################define these variable for convenient############################
${ALIAS_ASIK}     asik    ##
${ALIAS_ASIK_SLAVE}    asik_slave    ##
${ALIAS_UTE}      ute    ##
########################END of alias Define#######################################
${BTSSWServerPath}          https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release
#################define kpi relate parameters#####################################
@{lock_unlock_kpis}    kpi16a    kpi16b
@{block_unblock_kpis}    kpi17a    kpi17b
${BTS_HOST_IP}           ${URL_LMP}  #  IP used in admin setup
*** Keywords ***
SetUp Case
    [Arguments]    ${connection}=COAM    ${reset_flag}=${True}
    ...    ${wait_time}=8min
    TestCase.Start
    CreateCaseResultFile
    wait until keyword succeeds    20min    60s    DU_WebEM.LogIn and Check all NR Cell On Air
    ...    login_flag=${True}    connection=${connection}    wait_time=${wait_time}    reset_flag=${reset_flag}
    wait until keyword succeeds     1min   5s     connect to DU by ADMIN API    connection_AdminApi=${connection}
    run keyword and ignore error    Update or Create parameter by Admin API
       ...    class_name=TRBLCADM_A    parameter_Abbreviation=actRemoteSyslogTransmission
	   ...    Expected_Value=false    Dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
	run keyword and ignore error    Update or Create parameter by Admin API
       ...    class_name=TRBLCADM_A    parameter_Abbreviation=actRemoteSyslogTransmission
	   ...    Expected_Value=true    Dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
	[Teardown]     run keyword and ignore error  DisConnect to DU by ADMIN API     connection_AdminApi=${connection}

TestCase.Start
    CI_interface.Common Case Setup
TestCase.Stop
    Run Keyword And Ignore Error    run    command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

Teardown Case
    Run Keyword If Test Failed    Teardown case if case fail
    TestCase.Stop

KW.TestSuilt.Start
    [Arguments]
    TestSuilt.Start
    set suite variable    ${OAM_TYPE}    COAM
    set suite variable    ${TLDelta_PATH_ON_GIT}        ${CFGFILE_PATH}
    gNB.FormatBTSID       MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    set suite variable    ${dist_name}   ${MRBTS_ID}/${NRBTS_ID}
    ${version_Target}    Basic.GetStreamAndVersion
    set suite variable    ${TargetBTSVersion}    ${version_Target}
    ${BACKUP_SCF}   COAM_Admin.BackupSCF
    set suite variable    ${BACKUP_SCF}
    #${StreamVersion}    Get stream version     Stream_Master=${TargetBTSVersion[1]}
    ${StreamVersion}   ${subversion}    Split String   string=${TargetBTSVersion[1]}   separator=_     max_split=1
    set suite variable    ${StreamVersion}
    Wait Until Keyword Succeeds    3min    30s    DU_WebEM.LogIn and Check all NR Cell On Air

TestSuilt.Start

    Log to Console   TestSuiltStart
    Create Log Directories
    run    rm ${LOG_PATH}/* -rf
    run    python3 -c "import warnings;warnings.simplefilter('ignore', ResourceWarning)"
    run keyword and ignore error    UTECloud.AdaptCommissionFiles
    GNB.FormatBTSID

    ${L3CallLogConf}=  Catenate     SEPARATOR=${SPACE}
    ...                   {"snapshot":{"enabled":"false"},
    ...                    "lmilog":{"enabled":"false","lmiconfig":""},
    ...                    "btslog":{"enabled":"false"},
    ...                    "wireshark":{"enabled":"false","type":["none"]},
    ...                    "dcap":{"enabled":"false","host":"dcap","port":"100","type":["none"]},
    ...                    "rulog":{"enabled":"false","mode":"","position":"","ruIndex":"","ruUsr":"","ruPwd":""}
    ...                   }
    ${L3CallLogConf}    Evaluate        json.loads('''${L3CallLogConf}''')                   json
    Set Suite Variable    ${L3CallLogConf}

    ${keyword_logInit}     Create Dictionary  btslog=BtsLogInit    wireshark=WiresharkLogInit
    ...                                       dcap=DcapLogInit     snapshot=SnapshotInit
    ...                                       rulog=RuLogInit      lmilog=LMIlogInit
    set suite variable    ${keyword_logInit}
    ${keyword_logCollect}  Create Dictionary  btslog=BtsLogCollect    wireshark=WiresharkLogCollect
    ...                                       dcap=DcapLogCollect     snapshot=SnapshotCollect
    ...                                       rulog=RuLogCollect      lmilog=LMIlogCollect
    set suite variable    ${keyword_logCollect}

#    Log.Init    snapshot=true
    #run keyword and ignore error    Import Variables       ${CFGFILE_PATH}TLDelta.py
    #run keyword and ignore error    Import Variables       ${CFGFILE_PATH}TLSCFDelta.py
    run keyword and ignore error    gNB.ReplaceDeltaID     DeltaPath=${CFGFILE_PATH}TLDelta.py
    ...                    MRBTSID=${MRBTSID}
    ...                    NRBTSID=${NRBTSID}
    run keyword and ignore error    gNB.ReplaceDeltaID     DeltaPath=${CFGFILE_PATH}TLSCFDelta.py
    ...                    MRBTSID=${MRBTSID}
    ...                    NRBTSID=${NRBTSID}
    run keyword and ignore error    gNB.ReplaceDeltaID     DeltaPath=${CFGFILE_PATH}TLConfiguration.py
    ...                    MRBTSID=${MRBTSID}
    ...                    NRBTSID=${NRBTSID}
    run keyword and ignore error    gNB.ReplaceDeltaID     DeltaPath=${TLDATA_PATH}TLConfiguration.py
    ...                    MRBTSID=${MRBTSID}
    ...                    NRBTSID=${NRBTSID}

UTECloud.AdaptCommissionFiles
    #${SCF_PATH}     Get Substring  ${CURDIR}  0  -57
    return from keyword if    '${testline_name}'!='null'
    run keyword and ignore error     set suite variable     ${AF_PATH}    ${ENB_BUILD}
    ${SCF_PATH}    Fetch From Left    ${CURDIR}   testsuite
    log to console     ${SCF_PATH}
    ${TL_NAME}   set variable if      '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_${TLNAME}[0]
    set suite variable    ${testlinename}    ${testlinename}
    set suite variable    ${CFGFILE_PATH}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/
    set suite variable    ${GoldenScf_PATH}    ${SCF_PATH}/commissionings/HGZ/GoldenSCF/
    set suite variable    ${TLDATA_PATH}      ${SCF_PATH}/testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/TLData/${testlinename}/
    set suite variable    ${GoldenSCF_ON_GIT}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/
    run keyword and ignore error     CI_interface.Common Suite Setup

KW.TestSuilt.Stop
    Log to Console   TestSuiltStop

TC.teardown
    Run Keyword And Ignore Error    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
    Run Keyword And Ignore Error    run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
    csn.Reset Cache

TC.Precondition
    KW.CleanFirefox

TC.OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
    [Arguments]   ${WebUI_reset_times}=${CASE_INPUT_CB006443['CB006443_HA_KPI1a']['WebUI_reset_times']}
    ...   ${KPI1a_MAX}=${CASE_INPUT_CASE_INPUT_CB006443CB006443['CB006443_HA_KPI1a']['KPI1a_MAX']}
    ...   ${KPI1a_AVG}=${CASE_INPUT_CB006443['CB006443_HA_KPI1a']['KPI1a_AVG']}
    ...    ${Check_Call}=${False}    ${call_loop}=${2}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}     ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300

    gnb resetViaWebUIWithRetry   case_name=site_reset    retry_times=${WebUI_reset_times}
    ...   KPI1a_MAX=${KPI1a_MAX}
    ...   KPI1a_AVG=${KPI1a_AVG}
    ...    Check_Call=${Check_Call}    call_loop=${call_loop}
    ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
    ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
    ...    exepected_ul_tp=${exepected_ul_tp}     exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}
    ...    duration_dl=${duration_dl}

# power reset
TC.OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
    [Arguments]   ${Power_reset_times}=${CASE_INPUT_CB006443['CB006443_HA_KPI3']['Power_reset_times']}
    ...    ${KPI3_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI3']['KPI3_MAX']}
    ...    ${KPI3_AVG}=${CASE_INPUT_CB006443['CB006443_HA_KPI3']['KPI3_AVG']}
    ...    ${fail_loop_max}=${CASE_INPUT_CB006443['CB006443_HA_KPI3']['fail_loop_max']}
    ...    ${Check_Call}=${False}    ${call_loop}=${2}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}     ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300

    gnb PowerResetWithRetry   case_name=power_reset       retry_times=${Power_reset_times}
    ...    KPI3_MAX=${KPI3_MAX}   KPI3_AVG=${KPI3_AVG}      fail_loop_max=${fail_loop_max}
    ...    Check_Call=${Check_Call}    call_loop=${call_loop}
    ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
    ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
    ...    exepected_ul_tp=${exepected_ul_tp}     exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}
    ...    duration_dl=${duration_dl}


TC.OAM_KPI_51a_RU_Reset_Time
    [Arguments]    ${RF_reset_times}=${CASE_INPUT_CB006443['CB006443_HA_KPI51']['RF_reset_times']}
    ...    ${KPI51_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI51']['KPI51_MAX']}
    ...    ${KPI51_AVG}=${CASE_INPUT_CB006443['CB006443_HA_KPI51']['KPI51_AVG']}
    ...    ${Login_Flag}=${True}     ${Check_Call}=${False}    ${call_loop}=${2}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}    ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300
    [Documentation]  This is for test case OAM_KPI_51a_RU_Reset_Time
    wait until keyword succeeds     8min   3s     connect to DU by ADMIN API
    DU_WebEM.Get RMOD NAME
    Run Keyword if    '${Login_Flag}'=='True'    run keyword and ignore error     DisConnect to DU by ADMIN API
    set test variable   ${loop_counter}     ${1}
    KW.CaseStatusInit    retry_times=${1}
    DU_WebEM.loop reset all RMOD    RMOD_id_list=${RMOD_id_list}    connection=${connection}
    ...    reset_times=${RF_reset_times}    KPI51_MAX=${KPI51_MAX}     KPI51_AVG=${KPI51_AVG}
    ...    Login_Flag=${Login_Flag}    Check_Call=${Check_Call}    call_loop=${call_loop}
    ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
    ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
    ...    exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}     duration_dl=${duration_dl}
    ${RMOD_ID}    evaluate    random.choice(${RMOD_id_list})    random
    #log to console      ${RMOD_ID['configuration']}
    DU_WebEM.loop reset one RMOD    RMOD_id=${RMOD_ID}     connection=${connection}
    ...     retry_times=${RF_reset_times}    KPI51_MAX=${KPI51_MAX}     KPI51_AVG=${KPI51_AVG}
    ...    Login_Flag=${Login_Flag}    Check_Call=${Check_Call}    call_loop=${call_loop}
    ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
    ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
    ...    exepected_ul_tp=${exepected_ul_tp}     exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}
    ...    duration_dl=${duration_dl}
    [Teardown]    run keywords   run keyword and ignore error  DisConnect to DU by ADMIN API    AND     TC.teardown

TC.OAM_KPI_16_Cell_Lock_Unclock
    [Documentation]  This KW is for locking one cell and unblocking one cell by cell distname
    [Arguments]    ${KPI16a}=${KPI['CB008457_KPI16']['KPI16a_MAX']}
    ...    ${KPI16b}=${KPI['CB008457_KPI16']['KPI16b_MAX']}
    ...    ${repeat_times}=${KPI['CB008457_KPI16']['lock_cell_times']}
    ...    ${fail_times}=${KPI['CB008457_KPI16']['fail_times']}
    ...    ${Check_Call}=${False}    ${call_loop}=${2}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}     ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300
    ${connection}    Connect to DU by ADMIN API
    DU_WebEM.Get NR Cell distname and id
    set test variable    ${fail_num}    ${0}
    ${case_status_all}    RUN KEYWORD AND RETURN STATUS     DU_WebEM.lock cell and unlock cell one by one
    ...    cell_id_list=${cell_id_list}    connection=${connection}
    ...    KPI16a=${KPI16a}    KPI16b=${KPI16b}
    ${cellid}    evaluate    random.choice(${cell_id_list})    random
    log to console      ${cellid}
    @{block_case_status}    create list    ${empty}
    FOR    ${i}    IN RANGE    1   ${repeat_times}
        ${res}    Run Keyword And Ignore error
        ...    DU_WebEM.lock cell and unlock cell every loop
        ...    cell_id=${cellid}     connection=${connection}
        ...    KPI16a=${KPI16a}    KPI16b=${KPI16b}    loop=${i+1}
        ${case_status_one}    set variable if    '${res[0]}'=='PASS'      ${res[1][0]}    ${False}
        ${case_status_one}    set variable if    '${res[1][0]}'=='FAIL'      ${False}    ${case_status_one}
        ${snapshot_file}    Run Keyword If    '${case_status_one}'=='${False}'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot
        ${remainder}    Evaluate    (${i}+1)%${call_loop}
        Run Keyword If    '${case_status_one}'=='${True}' and '${Check_Call}'=='${True}' and '${remainder}'=='${0}'
        ...    RUN KEYWORD AND CONTINUE ON FAILURE    Verify UE send full UDP UL data and full UDP DL data
        ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
        ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
        ...    exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}    duration_dl=${duration_dl}
        RUN KEYWORD IF    '${case_status_one}'=='False'    Append to list    ${block_case_status}    ${case_status_one}
        ${fail_num}    Count Values In List    ${block_case_status}      ${False}
        Exit for loop if    ${fail_num}>=${fail_times}
    END
    Should be true    ${fail_num}==0
    [Teardown]    run keywords    run keyword and ignore error    DisConnect to DU by ADMIN API
    ...    AND    run keyword and ignore error    TC.teardown

TC.OAM_KPI_10_5G_RAT_reset
    [Documentation]   OM_GEN_SFS_PERF_CAP.12897
    ...  Purpose:Aim to test KPI10 5G RAT reset duration
    ...  Precondition:BTS is commissioned with 5G RAT
    ...  Test tools:WebUI
    ...  Test Steps:
    ...    Step1: login WebEM to check gnb is single core or dual core - target is extended 60 seconds if dual core
    ...    Step2: Check gnb type, get sctpWaitTimeInitSeqRetryX2 value if it is NSA - target is extended sctpWaitTimeInitSeqRetryX2 if NSA
    ...    Step3: Perform NR RAT reset   --start point
    ...    Step4: Wait until all cells are up  -- end point
    ...    Step5: Check the duatation is not more than target
    ...    Checkpoint configuration:
    [Arguments]
    ...    ${repeat_times}=${1}
    ...    ${KPI10}=${KPI['CB008457_KPI10']['KPI10']}
    ...    ${DualCoreExtend}=${KPI['CB008457_KPI10']['DualCoreExtend']}
    ...    ${NSAExtend}=${KPI['CB008457_KPI10']['NSAExtend']}
     log to console    Step1: login WebEM to check gnb is single core or dual core - target is extended 60 seconds if dual core
     gNB.CheckgNBCoreMode
     ${gNBMode}    gNB.CheckgNBCoreMode
     ${gNBType}    KW.CP_GetgNBType
     ${ModeExtendValue}=    Set Variable if   "${gNBMode}"=="Dualcore"   ${DualCoreExtend}    ${0}
     log to console     Step2. target is extended sctpWaitTimeInitSeqRetryX2 if NSA
     ${NSAExtendValue}=    Set Variable if   "${gNBType}"!="SA"   ${NSAExtend}    ${0}
     ${ExtendValue}=    Catenate    ${KPI10}+${ModeExtendValue}+${NSAExtendValue}
     ${KPI10}    Evaluate    ${ExtendValue}
     @{fail_case_status}    create list    ${empty}
     FOR    ${i}    IN RANGE    ${repeat_times}
             wait until keyword succeeds   10min    10s    COAM_WebEM.Login    version=SBTS22R4
             log to console      Step3: Perform NR RAT reset   --start point
             Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
             selenium_sbts.Reset NR
             run keyword and ignore error    COAM_WebEM.Logout
             wait until keyword succeeds     8min   3s     connect to DU by ADMIN API
             DU_WebEM.Get NR Cell distname and id      connection=${connection}
             Wait Until Keyword Succeeds    20x    5s     DU_WebEM.Check all NR Cell status
             ...    cell_id_list=${cell_id_list}    all_flag=True
             ...    operational_State=disabled    procedural_Status=configured
             ...    blockingState=Unblocked    administrative_State=Unlocked    connection=${connection}
             run keyword and ignore error  DisConnect to DU by ADMIN API     connection_AdminApi=${connection}
             log to console      Step4: Wait until all cells are up  -- end point
             wait until keyword succeeds   10x   1min    COAM_Admin.Login
             ${cell_status}    RUN KEYWORD AND RETURN STATUS    RUN KEYWORD AND CONTINUE ON FAILURE    Check all cells Should Be On Air
             ${duration}     SYSLOG.GetDuration    TimeStartString=${KEY_TIMESTART_KPI10}
             ...    TimeEndString=${kEY_TIMEEND_KPI10}    select_start=head    select_end=tail
             run keyword and ignore error    COAM_Admin.Logout
             Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}
             AppendCaseResultToFile    target_value=${KPI10}    result_value=${duration}
             ${case_status}    RUN KEYWORD AND RETURN STATUS    RUN KEYWORD AND CONTINUE ON FAILURE
             ...    Should Be True     ${duration}<=${KPI10}     ignore_case=true
             ${reset_status}	   Set Variable If	  '${case_status}'=='${True}'   pass      fail
             log to console     RAT reset loop:${i+1} duration:${duration} result:${reset_status}
             ${snapshot_file}    Run Keyword If    '${case_status}'=='${False}'
             ...    Run Keyword And Ignore error    WEBUI.Collect snapshot
             Run Keyword If    '${cell_status}'=='${False}'
             ...    Run Keyword And Ignore error    Do site reset to recovery gnb
             RUN KEYWORD IF    '${case_status}'=='False'    Append to list    ${fail_case_status}    ${case_status}
     END
     ${fail_num}    Count Values In List    ${fail_case_status}      ${False}
     should be true    ${fail_num}==0

TC.OAM_KPI_17_Cell_Block_Unblock_manually
    [Documentation]  This is for test case TC.CB006443_HA_05_OAM_KPI_17_Cell_Block_Unblock_manually
    [Arguments]    ${KPI17a}=${1}
    ...    ${KPI17b}=${1}
    ...    ${repeat_times}=${1}
    ...    ${check_history}=True     ${Check_Call}=${False}    ${call_loop}=${2}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}    ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300

    @{block_case_status}    create list    ${empty}
    ${connection}    Connect to DU by ADMIN API
    DU_WebEM.Get NR Cell distname and id
    ${fail_num0}     DU_WebEM.Block cell and unblock cell one by one
    ...    cell_id_list=${cell_id_list}    connection=${connection}   expected_alarm_index=${49}
    ...	   KPI17a=${KPI17a}    KPI17b=${KPI17b}    check_history=${check_history}
    ${cellid}    evaluate    random.choice(${cell_id_list})    random
    #log to console      ${cellid}
    FOR    ${i}    IN RANGE    1    ${repeat_times}
        ${case_status}    RUN KEYWORD AND RETURN STATUS
        ...    RUN KEYWORD AND CONTINUE ON FAILURE   DU_WebEM.Block cell and unblock cell
        ...    cell_id=${cellid}     connection=${connection}   	KPI17a=${KPI17a}    KPI17b=${KPI17b}
        ...    expected_alarm_index=${49}    loop=${i+1}
        ...    check_history=${check_history}
        RUN KEYWORD IF    '${case_status}'=='False'    Append to list    ${block_case_status}    ${False}
        RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${case_status}    ${True}    ignore_case=true
        ${snapshot_file}    Run Keyword If    '${case_status}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot
        ${remainder}    Evaluate    (${i}+1)%${call_loop}
        Run Keyword If    '${case_status}'=='${True}' and '${Check_Call}'=='${True}' and '${remainder}'=='${0}'
        ...    RUN KEYWORD AND CONTINUE ON FAILURE    Verify UE send full UDP UL data and full UDP DL data
        ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
        ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
        ...    exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}    duration_dl=${duration_dl}
    END
    ${fail_num1}    Count Values In List    ${block_case_status}      ${False}
    Should be true    ${fail_num0}==0
    Should be true    ${fail_num1}==0
    [Teardown]    run keyword and ignore error  TC.teardown


##########start keyword for CB006443_HA_05_OAM_KPI_17_Cell_Block_Unblock_manually#############
DU_WebEM.Block cell and unblock cell
    [Documentation]  This KW is for blocking one cell and unblocking one cell by cell distname
    [Arguments]    ${cell_id}    ${connection}    ${expected_alarm_index}   ${loop}=${1}
    ...    ${KPI17a}=${1}
    ...    ${KPI17b}=${1}
    ...    ${check_history}=True
    #log to console    block cell start
    BtsLog.StartBTSlogCollection
    ${faultid_list_0}    DU_WebEM.Get alarm in DU     ParameterInput=False    check_history=${check_history}
    #${block_startTime}    KW.TimerStart
    wait until keyword succeeds   1min   2s    DU_Rest.block_cell
    ...    dist_name=${cell_id['configuration']}    timeout=60    connection=${connection}
    ${alarm_startTime}    KW.TimerStart
    ${cell}    Evaluate    "${cell_id['configuration']}".split("/")[-1]
    wait until keyword succeeds   10x   30s    DU_WebEM.Check NR Cell status
    ...    cell_internal_id=${cell_id['internal']}
    ...    timeout=30   operational_State=Disabled    procedural_Status=configured
    ...    blockingState=Blocked    administrative_State=Unlocked
    sleep   5s
    #${block_duration}     KW.TimerStop    timestart=${block_startTime}
    ${status}    wait until keyword succeeds   15s   66ms    DU_WebEM.check alarm by string    FaultFlag=Raised
    ${alarm_duration}     KW.TimerStop    timestart=${alarm_startTime}

#####start check no new alarm raised #######
   #log to console    start check no new alarm raised
    ${faultid_list}    DU_WebEM.Get alarm in DU    check_history=${check_history}
    ...    active_fault_list=${status[0]}    historic_fault_list=${status[1]}
    ${res1}    Run Keyword And Return Status    RUN KEYWORD AND CONTINUE ON FAILURE
    ...    DU_WebEM.Validate alarm is raised or canceled in DU
    ...    active_fault_list_0=${faultid_list_0[0]}     historic_fault_list_0=${faultid_list_0[1]}
    ...    active_fault_list=${faultid_list[0]}    historic_fault_list=${faultid_list[1]}
    ...    expected_alarm_index=${expected_alarm_index}    alarm_status=raised    check_history=${check_history}
    Run Keyword If      '${res1}'=='False'    log to console    check fault raised failed
#####unblock cell start#######
    #log to console    unblock cell start
    ${faultid_list_0}    DU_WebEM.Get alarm in DU     ParameterInput=False    check_history=${check_history}
    ${unblock_startTime}    KW.TimerStart
    wait until keyword succeeds   15s   5s    DU_Rest.unblock_cell
    ...    dist_name=${cell_id['configuration']}    timeout=60    connection=${connection}
    wait until keyword succeeds   10x   30s    DU_WebEM.Check NR Cell status
    ...    cell_internal_id=${cell_id['internal']}    timeout=30   operational_State=Enabled
    ...    procedural_Status=configured
    ...    blockingState=Unblocked    administrative_State=Unlocked
    #${unblock_duration}     KW.TimerStop    timestart=${unblock_startTime}
    ${status}    wait until keyword succeeds   15s   5ms    DU_WebEM.check alarm by string    FaultFlag=Cleared
    ${cancelalarm_duration}     KW.TimerStop    timestart=${unblock_startTime}
    #log to console    start check no new alarm raised after unblock cell
    ${faultid_list}    DU_WebEM.Get alarm in DU    check_history=${check_history}
    ...    active_fault_list=${status[0]}   historic_fault_list=${status[1]}
    ${res1}    RUN KEYWORD AND CONTINUE ON FAILURE      DU_WebEM.Validate alarm is raised or canceled in DU
    ...    active_fault_list_0=${faultid_list_0[0]}     historic_fault_list_0=${faultid_list_0[1]}
    ...    active_fault_list=${faultid_list[0]}    historic_fault_list=${faultid_list[1]}
    ...    expected_alarm_index=${expected_alarm_index}    alarm_status=canceled    check_history=${check_history}
    Run Keyword If      '${res1}'=='False'    log to console    check fault raised failed
    Stop BTSlogs Collection and get logs for every loop    loop=${cell}_${loop}
    ${block_duration}     SYSLOG.GetDuration    TimeStartString=${KEY_TIMESTART_KPI17a}    TimeEndString=${kEY_TIMEEND_KPI17a}
    ${unblock_duration}   SYSLOG.GetDuration    TimeStartString=${KEY_TIMESTART_KPI17b}    TimeEndString=${kEY_TIMEEND_KPI17b}
    ${block_result}    set variable if    ${0}<${block_duration}<${KPI17a}    Pass    Fail
    ${unblock_result}    set variable if    ${0}<${unblock_duration}<${KPI17b}    Pass    Fail

    log to console    ${cell} block loop:${loop} duration:${block_duration}s result:${block_result}
    log to console    ${cell} unblock loop:${loop} duration:${unblock_duration}s result:${unblock_result}

#####unblock cell end#######
    RUN KEYWORD AND CONTINUE ON FAILURE   Should be true
    ...    ${0}<${block_duration}<${KPI17a}
    RUN KEYWORD AND CONTINUE ON FAILURE   Should be true
     ...    ${0}<${unblock_duration}<${KPI17b}
#    RUN KEYWORD AND CONTINUE ON FAILURE   Should be true
#    ...   ${0}<${alarm_duration}<${KPI17a}
#    RUN KEYWORD AND CONTINUE ON FAILURE   Should be true
#    ...   ${0}<${cancelalarm_duration}<${KPI17a}
    [Teardown]    run keyword and ignore error     DU_WebEM.TearDown.unblock one cell
    ...    cell=${cell_id}     connection=${connection}

DU_WebEM.Block cell and unblock cell one by one
    [Documentation]  This KW is for blocking cell and unblocking cell one by one
    [Arguments]    ${cell_id_list}    ${connection}    ${expected_alarm_index}
    ...    ${KPI17a}=${1}
    ...    ${KPI17b}=${1}
    ...    ${check_history}=True
    @{block_case_status}    create list    ${empty}
    set test variable    ${fail_num}    ${0}
    FOR    ${cell}    IN    @{cell_id_list}
        ${case_status}    RUN KEYWORD AND RETURN STATUS
        ...    RUN KEYWORD AND CONTINUE ON FAILURE   DU_WebEM.Block cell and unblock cell
        ...    cell_id=${cell}     connection=${connection}
        ...    expected_alarm_index=${expected_alarm_index}    	KPI17a=${KPI17a}    KPI17b=${KPI17b}
        ...    check_history=${check_history}
#        ${snapshot_file}    Run Keyword If    '${case_status}'=='False'
#        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot
        RUN KEYWORD IF    '${case_status}'=='False'    Append to list    ${block_case_status}    ${False}
    END
    ${fail_num}    Count Values In List    ${block_case_status}      ${False}
    [Return]  ${fail_num}

DU_WebEM.TearDown.unblock cell
    [Arguments]    ${cell_id_list}    ${connection}
    FOR    ${cell}    IN    @{cell_id_list}
        ${res}    run keyword and ignore error    DU_WebEM.Check NR Cell status
        ...    cell_internal_id=${cell['internal']}    timeout=30   operational_State=Enabled
        ...    procedural_Status=configured
        ...    blockingState=Unblocked    administrative_State=Unlocked
        RUN KEYWORD If    '${res[0]}'=='FAIL'    run keyword and ignore error    DU_Rest.unblock_cell
        ...    dist_name=${cell['configuration']}    timeout=60    connection=${connection}
    END

DU_WebEM.TearDown.unblock one cell
    [Arguments]    ${cell}    ${connection}
        ${res}    run keyword and ignore error    DU_WebEM.Check NR Cell status
        ...    cell_internal_id=${cell['internal']}    timeout=30   operational_State=Enabled
        ...    procedural_Status=configured
        ...    blockingState=Unblocked    administrative_State=Unlocked
        RUN KEYWORD If    '${res[0]}'=='FAIL'    run keyword and ignore error    DU_Rest.unblock_cell
        ...    dist_name=${cell['configuration']}    timeout=60    connection=${connection}

##########End keyword for CB006443_HA_05_OAM_KPI_17_Cell_Block_Unblock_manually#############

TC.OAM_KPI_5_Capacity_Module_Reset_Outage_Duration
    [Documentation]  This is for test case CB006443_HA_06_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration
    [Arguments]    ${KPI5_MAX}=${1}
    ...    ${repeat_times}=${1}
    ...    ${fail_loop_max}=${1}
    ...    ${Check_Call}=${False}    ${call_loop}=${2}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}    ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300

    ${connection}    Connect to DU by ADMIN API
    DU_WebEM.Get NR Cell distname and id
    DU_WebEM.Get BBMOD distname and id
    FOR    ${BBMOD}    IN    @{BBMOD_id_list}
        BtsLog.StartBTSlogCollection
        ${res}    Run Keyword And Ignore Error    DU_WebEM.reset BBMOD
        ...    BBMOD_id=${BBMOD}     connection=${connection}     KPI5_MAX=${KPI5_MAX}
                ${case_status}         set variable if    '${res[0]}'=='FAIL' or "${res[1][0]}"=="fail"      ${False}    ${True}
        RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${case_status}    ${True}    ignore_case=true
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        ${snapshot_file}    Run Keyword If    '${case_status}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot
        ${BBMOD_name}    Evaluate    "${BBMOD['configuration']}".split("/")[-1]
        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${BBMOD_name}_${1}
        log to console    BBMOD reset loop:${1} duration:${duration_time_tmp} result:${res[1][0]}
    END
    ${BBMOD_ID}    evaluate    random.choice(@{BBMOD_id_list})    random
    @{result_list}    create list
    FOR    ${i}    IN RANGE    1   ${repeat_times}
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        ${res}    run keyword and ignore error   DU_WebEM.reset BBMOD
        ...    BBMOD_id=${BBMOD_ID}     connection=${connection}     KPI5_MAX=${KPI5_MAX}
        ${case_status}         set variable if    '${res[0]}'=='FAIL' or "${res[1][0]}"=="fail"      ${False}    ${True}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}
        RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${case_status}    ${True}    ignore_case=true
        log to console    BBMOD reset loop:${i+1} duration:${duration_time_tmp} result:${res[1][0]}
        ${snapshot_file}    Run Keyword If    '${case_status}'=='${False}'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot

        ${remainder}    Evaluate    (${i}+1)%${call_loop}
        Run Keyword If    '${case_status}'=='${True}' and '${Check_Call}'=='${True}' and '${remainder}'=='${0}'
        ...    RUN KEYWORD AND CONTINUE ON FAILURE    Verify UE send full UDP UL data and full UDP DL data
        ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
        ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
        ...    exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}    duration_dl=${duration_dl}
        Append To List    ${result_list}    ${case_status}
        ${fail_num}    Count Values In List    ${result_list}     False
        Exit for loop if    ${fail_num}>=${fail_loop_max}
    END
    [Teardown]    run keywords   run keyword and ignore error  DisConnect to DU by ADMIN API    AND     TC.teardown

TC.OAM_KPI_54a_RU_cold_Reset_Time
    [Documentation]   This is for test RU cold reset KPI 54a
    ...    Precondition: RU PB information must configured in testline_configuration/_init_.py.
    ...    The RU order must be aligned with RU index
    [Arguments]    ${KPI54A_MAX}=${1}
    ...    ${repeat_times}=${1}
    ...    ${fail_loop_max}=${1}
    ...    ${Check_Call}=${False}    ${call_loop}=${2}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}    ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300
    ${connection}    Connect to DU by ADMIN API
    DU_WebEM.Get NR Cell distname and id
    ${length}=   Get Length     ${tl.gnbs[0].dus[0].rus}
    set test variable   ${loop_counter}     ${1}
    FOR    ${i}    IN RANGE    ${length}
         ${case_status}    Run Keyword And Ignore error
         ...    PB.Power on or off one RU     pdu_ip=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.addr}
         ...    Port_Number=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.port_no}
         ...    model=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.vendor}
         ...    KPI54A_MAX=${KPI54A_MAX}
         log to console     RU power reset loop:${loop_counter} duration:${case_status[1]} result:${case_status[0]}
         RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${case_status[0]}    PASS   ignore_case=true
#         ${snapshot_file}    Run Keyword If    '${case_status[0]}'=='FAIL'
#         ...    Run Keyword And Ignore error    WEBUI.Collect snapshot

    END
    ${RU_INDEX}     Evaluate    random.randint(0, ${length}-1)    modules=random
    log to console    ${tl.gnbs[0].dus[0].rus[${RU_INDEX}].radio_type}
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${repeat_times-1}
         ${case_status}    Run Keyword And Ignore error
         ...    PB.Power on or off one RU     pdu_ip=${tl.gnbs[0].dus[0].rus[${RU_INDEX}].pdu_port.pdu.addr}
         ...    Port_Number=${tl.gnbs[0].dus[0].rus[${RU_INDEX}].pdu_port.port_no}
         ...    model=${tl.gnbs[0].dus[0].rus[${RU_INDEX}].pdu_port.pdu.vendor}
         ...    KPI54A_MAX=${KPI54A_MAX}
        ${loop_counter}    Evaluate    ${loop_counter}+1
        log to console     RU power reset loop:${loop_counter} duration:${case_status[1]} result:${case_status[0]}
        RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${case_status[0]}    PASS    ignore_case=true
#        ${snapshot_file}    Run Keyword If    '${case_status[0]}'=='FAIL'
#        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot

        ${remainder}    Evaluate    (${i}+1)%${call_loop}
        Run Keyword If    '${case_status[0]}'=='${True}' and '${Check_Call}'=='${True}' and '${remainder}'=='${0}'
        ...    RUN KEYWORD AND CONTINUE ON FAILURE    Verify UE send full UDP UL data and full UDP DL data
        ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
        ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
        ...    exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}    duration_dl=${duration_dl}

        Append To List    ${result_list}    ${case_status}
        ${fail_num}    Count Values In List    ${result_list}     False
        Exit for loop if    ${fail_num}>=${fail_loop_max}
    END
    [Teardown]    run keywords   run keyword and ignore error  DisConnect to DU by ADMIN API    AND     TC.teardown


KW.LoginWithAlias
    [Documentation]   parameter should be ${True} or ${False}
    [Arguments]      ${url}=${WEBUI_URL}    ${alias}=None
    #run keyword if     ${virtual_enable}     selenium_coam.enable_virtual_display
    wait until keyword succeeds  15x   1min  selenium_coam.login
    ...    url=${url}    username=${WEBUI_USERNAME}    password=${WEBUI_PASSWORD}    alias=${alias}

KW.TimerStart
    ${timeTmp}   robot.libraries.DateTime.Get Current Date
    ${timestart}      robot.libraries.DateTime.convert date    ${timeTmp}    epoch
    [Return]     ${timestart}

KW.TimerStop
    [Arguments]   ${timestart}
    ${timeTmp}    robot.libraries.DateTime.Get Current Date
    ${timeend}    robot.libraries.DateTime.convert date    ${timeTmp}     epoch
    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    [Return]     ${duration_time_tmp}

KW.CleanFirefox
    Log to Console    CleanFirefox
    Run Keyword And Ignore error   run   command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error   run   command=killall Xvfb
    Run Keyword And Ignore error   run   command=killall geckodriver

TestteardownforWebEM
    [Documentation]    History: add step collect snapshot
    [Arguments]
    Set test Variable    ${CLI_PATH}    NotSet
    Run Keyword If Test Failed   run keyword and ignore error    WEBUI.Collect snapshot
    Run Keyword And Ignore Error    run    command=ps xafu |grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    GNB.kill admin process
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
    Run Keyword And Ignore Error    force_close_coam_webdriver
    Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog
    Run Keyword And Ignore Error    run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
    csn.Reset Cache
    Run Keyword And Ignore Error         KW.CleanFirefox
    TestCase.Stop


CreateCaseResultFile
    ${version}    Basic.GetStreamAndVersion
    log    ${version}
    @{suite_name}    Split String    ${SUITE SOURCE}    /
    @{suite_name}    Split String    ${suite_name[-1]}    .
    Generate suite log path
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set test variable    ${case_result_save_path}    ${TS_CASE_LOG_PATH}/${testline_name}_${suite_name[0]}_${version[1]}.csv
    Create File    ${case_result_save_path}
    ${file_head}    Catenate    SEPARATOR=,    case name    requirement id    index    Ru type    Ru index
    ...    target value    result value    case result\n
    Append To File    ${case_result_save_path}    ${file_head}

AppendCaseResultToFile
    [Arguments]   ${requirement_id}=NA    ${index}=NA    ${ru_type}=NA    ${ru_index}=NA
    ...           ${target_value}=NA   ${result_value}=NA    ${case_result}=NA
    ${check_kpi_value}    run keyword if
    ...    '${result_value}'!='NA' and '${target_value}'!='NA' and ${result_value}<=${target_value} and ${result_value}>${0}
    ...    set variable    pass
    ...    ELSE    set variable    fail

    ${data}    run keyword if    '${case_result}'!='NA'
    ...   Catenate    SEPARATOR=,    ${TEST NAME}    ${requirement_id}    ${index}    ${ru_type}
    ...   ${ru_index}    ${target_value}    ${result_value}    ${case_result}\n
    ...   ELSE    Catenate    SEPARATOR=,    ${TEST NAME}    ${requirement_id}    ${index}    ${ru_type}
    ...   ${ru_index}    ${target_value}    ${result_value}    ${check_kpi_value}\n

    Append To File    ${case_result_save_path}    ${data}

DU_WebEM.lock cell and unlock cell every loop
    [Documentation]  This KW is for locking one cell and unblocking one cell by cell distname
    [Arguments]    ${cell_id}    ${connection}    ${KPI16a}=${KPI['CB008457_KPI16']['KPI16a']}
    ...    ${KPI16b}=${KPI['CB008457_KPI16']['KPI16b']}    ${loop}=${0}
    ${res}    Run Keyword And Ignore Error    DU_WebEM.lock cell
    ...    cell_id=${cell_id}     connection=${connection}
    ...    KPI16a=${KPI16a}   loop=${loop}
    ${lock_duration}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1]}
    run keyword and continue on failure    should be true    '${res[0]}'=='PASS'
    ${res}    Run Keyword And Ignore Error   DU_WebEM.unlock cell
    ...    cell_id=${cell_id}     connection=${connection}
    ...    KPI16b=${KPI16b}   loop=${loop}
    ${unlock_duration}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1]}
    run keyword and continue on failure    should be true    '${res[0]}'=='PASS'
    ${cell}    Evaluate    "${cell_id['configuration']}".split("/")[-1]
    log to console
    ...  loop:${loop} ${cell} duration lock:${lock_duration}s unlock:${unlock_duration}s result:${res[0]}
    ${case_result}    set variable if    ${lock_duration} != 1800 and ${unlock_duration} != 1800      True    False
    [Return]   ${case_result}

DU_WebEM.lock cell with check
    [Documentation]  This KW is for locking one cell and unblocking one cell by cell distname
    [Arguments]    ${dist_name}    ${cell_internal_id}    ${connection}
    DU_Rest.lock
    ...    dist_name=${dist_name}    timeout=120    connection=${connection}

    ${result}    wait until keyword succeeds   10x   10s    DU_WebEM.Check NR Cell status
    ...    cell_internal_id=${cell_internal_id}
    ...    timeout=30   operational_State=disabled    procedural_Status=initialization required
    ...    blockingState=Unblocked    administrative_State=Locked
    should be true   '${result}'=='PASS'
    [Return]  ${result}

DU_WebEM.lock cell
    [Documentation]  This KW is for locking one cell and unblocking one cell by cell distname
    [Arguments]    ${cell_id}    ${connection}
    ...    ${KPI16a}=${KPI['CB008457_KPI16']['KPI16a']}    ${loop}=${0}
    log to console    lock cell start
    BtsLog.StartBTSlogCollection
    ${result}    wait until keyword succeeds   3x   70s    DU_WebEM.lock cell with check
    ...    dist_name=${cell_id['configuration']}    cell_internal_id=${cell_id['internal']}   connection=${connection}

    ${cell}    Evaluate    "${cell_id['configuration']}".split("/")[-1]
    Stop BTSlogs Collection and get logs for every loop    loop=${cell}_${loop}
    ${lock_duration}     SYSLOG.GetDuration    TimeStartString=${KEY_TIMESTART_KPI16a}    TimeEndString=${kEY_TIMEEND_KPI16a}
    RUN KEYWORD AND CONTINUE ON FAILURE   Should be true
    ...    0<${lock_duration}<${KPI16a}
    [Return]   ${lock_duration}
    [Teardown]   Run Keyword If    '${result}'!='PASS'     Stop BTSlogs Collection and get logs for every loop    loop=fail_${loop}

DU_WebEM.unlock cell
    [Arguments]    ${cell_id}    ${connection}
    ...    ${KPI16b}=${KPI['CB008457_KPI16']['KPI16b']}    ${loop}=${0}
    log to console    unlock cell start
    BtsLog.StartBTSlogCollection
    wait until keyword succeeds   5x   60s    DU_Rest.unlock
    ...    dist_name=${cell_id['configuration']}    timeout=60    connection=${connection}
    ${cell}    Evaluate    "${cell_id['configuration']}".split("/")[-1]
    ${result}    wait until keyword succeeds   10x   10s    DU_WebEM.Check NR Cell status
    ...    cell_internal_id=${cell_id['internal']}    timeout=30   operational_State=Enabled
    ...    procedural_Status=configured
    ...    blockingState=Unblocked    administrative_State=Unlocked

    ${unlock_duration}     SYSLOG.GetDuration    TimeStartString=${KEY_TIMESTART_KPI16b}    TimeEndString=${kEY_TIMEEND_KPI16b}
    Stop BTSlogs Collection and get logs for every loop    loop=${cell}_${loop}
    #####unlock cell end#######
    RUN KEYWORD AND CONTINUE ON FAILURE   Should be true
     ...    0<${unlock_duration}<${KPI16b}
    [Return]   ${unlock_duration}
    [Teardown]       Run Keyword If    '${result}'!='PASS'     run keywords     run keyword and ignore error
    ...     DU_WebEM.TearDown.unlock one cell    cell=${cell_id}     connection=${connection}
    ...    AND    Stop BTSlogs Collection and get logs for every loop    loop=fail_${loop}

DU_WebEM.lock cell and unlock cell one by one
    [Documentation]  This KW is for locking cell and unlocking cell one by one
    [Arguments]    ${cell_id_list}    ${connection}
    ...    ${KPI16a}=${KPI['CB008457_KPI16']['KPI16a']}
    ...    ${KPI16b}=${KPI['CB008457_KPI16']['KPI16b']}
    FOR    ${cell}    IN    @{cell_id_list}
        ${res}    Run Keyword And Ignore Error    DU_WebEM.lock cell
        ...    cell_id=${cell}     connection=${connection}
        ...    KPI16a=${KPI16a}
        ${lock_duration}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1]}
        ${cellid}    Evaluate    "${cell['configuration']}".split("/")[-1]
        log to console   loop:1 ${cellid} duration lock:${lock_duration}s result:${res[0]}
        run keyword and continue on failure    should be true    '${res[0]}'=='PASS'
        ${res}    Run Keyword And Ignore Error    DU_WebEM.unlock cell
        ...    cell_id=${cell}     connection=${connection}
        ...    KPI16b=${KPI16b}
        ${unlock_duration}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1]}
        log to console   loop:1 ${cellid} duration unlock:${unlock_duration}s result:${res[0]}
        run keyword and continue on failure    should be true    '${res[0]}'=='PASS'
    END


DU_WebEM.TearDown.unlock cell
    [Arguments]    ${cell_id_list}    ${connection}
    FOR    ${cell}    IN    @{cell_id_list}
        wait until keyword succeeds   1min    2s    DU_Rest.unlock
        ...    dist_name=${cell['configuration']}    timeout=60    connection=${connection}
    END

DU_WebEM.TearDown.unlock one cell
    [Arguments]    ${cell}    ${connection}
    ${res}    run keyword and ignore error    DU_WebEM.Check NR Cell status
    ...    cell_internal_id=${cell['internal']}    timeout=30   operational_State=Enabled
    ...    procedural_Status=configured
    ...    blockingState=Unblocked    administrative_State=Unlocked
    RUN KEYWORD If    '${res[0]}'=='FAIL'    wait until keyword succeeds   1min    2s    DU_Rest.unlock
    ...    dist_name=${cell['configuration']}    timeout=60    connection=${connection}

##########start keyword for CB008681-SR-A########################################################
TC.CM_Full_Plan_Download_Validation_Activation_Operations
    [Documentation]
    ...  Purpose:Aim to test the KPI of load, validate and active the SCF on WebUI
    ...  Precondition:No error when do validation
    ...  Test tools:WebUI
    ...  Test Steps:
    ...    Step1: Create a full configuration plan with error and load the scf on WebUI
    ...           eg:modify ABIL ID to generate error
    ...    Step2: Check the validation duration should no more than requirement in WebEM,
    ...           and validate the scf and check error exist.
    ...    Step3: Create a full configuration plan without error and load the scf in WebUI
    ...    Step4: Do validation operation in WebEM,
    ...           and Check the validation duration should no more than requirement
    ...    Step5: Check both the load scf duration should no more than requirement
    ...    Step6: Active the scf without error and check the active duration should no more than requirement
    [Arguments]   ${Duration_SCFLoad}=${KPI['CM_A_01']['Duration_SCFLoad']}
    ...           ${Duration_ValidationError}=${KPI['CM_A_01']['Duration_ValidationError']}
    ...           ${Duration_Validation}=${KPI['CM_A_01']['Duration_Validation']}
    ...           ${Duration_Activation}=${KPI['CM_A_01']['Duration_Activation']}
    run   cp ${BACKUP_SCF} ${LOG_PATH}/ErrorSCF.xml
    Basic.SedReplaceLine    <p name=\\"secondEndpointDN\\">${MRBTS_ID}\\/EQM-1\\/APEQM-1\\/CABINET-1\\/BBMOD-1<\\/p>
    ...    \\<p name=\\"secondEndpointDN\\"\\>${MRBTS_ID}\\/EQM-1\\/APEQM-1\\/CABINET-1\\/BBMOD-9999\\<\\/p\\>
    ...    ${LOG_PATH}/ErrorSCF.xml
    COAM_WebEM.Login    version=${StreamVersion}
    Log To Console    Step1: Create a full configuration plan with error and load the scf on WebUI
    ${status}=    selenium_coam.load_commissioning_file_and_check_load_status
    ...           file_path=${LOG_PATH}/ErrorSCF.xml
    Should be True    ${status}
    Log To Console   Step2: Check the validation duration should no more than requirement in WebEM,
    ...           and validate the scf and check error exist.
    selenium_coam.validate_plan     timeout=${Duration_ValidationError}
    ${error}    selenium_coam.get_relation_errors
    Should Not Be Empty    ${error}
    log to console    Step3: Create a full configuration plan without error and load the scf in WebUI
    ${status}=    selenium_coam.load_commissioning_file_and_check_load_status
     ...           file_path=${BACKUP_SCF}
    Should be True    ${status}
    Log To Console    Step4: Do validation operation in WebEM,
    ...           and Check the validation duration should no more than requirement
    selenium_coam.validate_plan     timeout=${Duration_Validation}
#    ${error}    selenium_coam.get_relation_errors
##    Should Be Empty     ${error}
    #first error load commission file
    log To Console    Step5: Check both the load scf duration should no more than defined by requirement
    ${timestart}    run    cat ${OUTPUT DIR}/debug.log |grep "//load-action-button//input"|awk '{print $1,$2}'|head -n 1|tail -1
    ${timestart}      convert date    ${timestart}    epoch
    ${timeend}    run    cat ${OUTPUT DIR}/debug.log |grep "END KW: selenium_coam.Load Commissioning"|awk '{print $1,$2}'|head -n 1|tail -1
    ${timeend}      convert date    ${timeend}    epoch
    ${duration1}    Evaluate    ${timeend}-${timestart}
    log to console    ${duration1}
    should be true     ${duration1}<${Duration_SCFLoad}
    #second success load commission file
    ${timestart}    run    cat ${OUTPUT DIR}/debug.log |grep "//load-action-button//input"|awk '{print $1,$2}'|head -n 3|tail -1
    ${timestart}      convert date    ${timestart}    epoch
    ${timeend}    run    cat ${OUTPUT DIR}/debug.log |grep "END KW: selenium_coam.Load Commissioning"|awk '{print $1,$2}'|head -n 2|tail -1
    ${timeend}      convert date    ${timeend}    epoch
    ${duration2}    Evaluate    ${timeend}-${timestart}
    log to console    ${duration2}
    should be true     ${duration2}<${Duration_SCFLoad}
    Log To Console    Step6: Active the scf without error and check the active duration should no more than requirement
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=${Duration_Activation}
    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend

COAM_VerifyOnAirViaFrontendAndBackend
   ${frontend}    run keyword and return status    COAM_WebEM.VerifyCellOnAir
   ${backend}     run keyword and return status    COAM_Admin.VerifyCellOnAir
   should be true    ${frontend} or ${backend}

TC.CM_Delta_Plan_Validation_Activation_Operations_No_Service_Outage
    [Documentation]
    ...   Purpose:Test case is to check configuration file_delta plan(No service outage) can be validation/activation
    ...            successful and duration meet requirement.
    ...   Precondition: No error after do validation.
    ...   Test tools:WebUI
    ...   Test Steps:
    ...     Step1: Modify parameter which will not cause site reset but will cause error when do validation.
    ...            eg:modify 'shutdownNogNBCellTmr' to wrong value in webem.
    ...     Step2: Caculate validate duration(duration is captured from system) and check validation duration no more than
    ...            requirement.
    ...     Step3: Validate and check error exist on WebEM.
    ...     Step4: Restore environment,which means modify parmeter back,do validation and activation.
    [Arguments]   ${InActSA_ErrValue}=80000
    ...           ${Duration_DeltaValidation}=${KPI['CM_A_02']['Duration_DeltaValidation_error']}
    COAM_WebEM.Login
    Log To Console    Step1: Modify parameter which will not cause site reset but will cause error when do validation.
    ...            eg:modify 'shutdownNogNBCellTmr' to wrong value in webem.
    ${timestartTmp}   Get Current Date
    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=Waiting timer for SCTP link shutdown due to no gNB cell
    ...    new_value=${InActSA_ErrValue}
    ${validate_message_STEP1}   selenium_coam.get_error_info_after_set_parameter
    Log To Console    Step2: Caculate validate duration(duration is captured from system) and check validation duration no more than
    ...            requirement
    ${timestart}      convert date    ${timestartTmp}    epoch
    ${timeendTmp}     Get Current Date
    ${timeend}        convert date    ${timeendTmp}     epoch
    ${duration_time_tmp_CB006443AA02}    Evaluate    ${timeend}-${timestart}
    Should Be True     ${0}<${duration_time_tmp_CB006443AA02}<=${Duration_DeltaValidation}
    Log To Console    Step3: Validate and check error exist on WebEM.
    Should Not Be Empty       ${validate_message_STEP1}
    selenium_coam.undo_changes
    Log To Console    Step4: Restore environment,which means modify parmeter back,do validation and activation.
    ${InActSA_Value}    selenium_coam.get_parameter_value
    ...    dist_name=${distname}    filter_param=Waiting timer for SCTP link shutdown due to no gNB cell
    ${InActSA_Value}    get regexp matches    ${InActSA_Value}     [0-9]+
    ${InActSA_Value}    Evaluate    ${InActSA_Value[0]}+1
    ${InActSA_CorrectValue}=  set variable if    ${InActSA_Value} >= ${5}   3   8
    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=Waiting timer for SCTP link shutdown due to no gNB cell
    ...    new_value=${InActSA_CorrectValue}
    selenium_coam.validate_plan
    ${error}    selenium_coam.get_relation_errors
    Should Be Empty     ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    COAM_WebEM.Logout

TC.CM_Delta_Plan_Validation_Activation_Operations_Site_Level_Service_Outage
    [Documentation]
    ...   Purpose:test case is to check configuration file_delta plan(Site level service outage need)
    ...            can be validation/activation can be successful and duration meet requirement.
    ...   Precondition: No error after do validation.
    ...   Test tools:WebUI
    ...   Test Steps:
    ...     Step1: Modify parameter which will cause site reset has error when do validation.
    ...            eg:modify 'drxDefaultPaging' to a different value.
    ...     Step2: Validate and check error not exist on WebEM.
    ...     Step3: Do activation,caculate activation duration(duration is captured from system) and check validation
    ...            duration no more than requirement.
    [Arguments]   ${Duration_DeltaActivation}=${KPI['CM_A_04']['Duration_DeltaActivation']}
    COAM_WebEM.Login
    Log To Console    Step1:Modify parameter which will cause site reset has error when do validation.
    ${drxDefaultPaging_Value}    selenium_coam.get_parameter_value
    ...    dist_name=${distname}    filter_param=Default DRX paging cycle value for the gNB    abbr=drxDefaultPaging
    run keyword if    "${drxDefaultPaging_Value}"=="v256"
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${distname}              filter_param=Default DRX paging cycle value for the gNB
    ...    new_value=v128   abbr=drxDefaultPaging
    ...    ELSE
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${distname}              filter_param=Default DRX paging cycle value for the gNB
    ...    new_value=v256   abbr=drxDefaultPaging
    Log To Console    Step2: Validate and check error not exist on WebEM.
    selenium_coam.validate_plan
    ${error}    selenium_coam.get_relation_errors
    Should Be Empty     ${error}
    Log To Console    Step3: Do activation,caculate activation duration and check validation duration no more than requirement
    ${timestartTmp}   Get Current Date
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    ...    timeout=120
    ${timestart}      convert date    ${timestartTmp}    epoch
    ${timeendTmp}     Get Current Date
    ${timeend}        convert date    ${timeendTmp}     epoch
    ${duration_time_tmp_STEP2}    Evaluate    ${timeend}-${timestart}
    Should Be True     ${0}<${duration_time_tmp_STEP2}<=${Duration_DeltaActivation}
    wait until keyword succeeds   6x   3min     COAM_VerifyOnAirViaFrontendAndBackend

TC.CM_Duration_of_CM_Change_Notification
    [Documentation]
    ...   Purpose:The BTS/DU/CU/vDU shall complete the CM change notification generation and transmission
    ...   within the times defined in 10+7s.
    ...   Precondition: NetAct ENV shall be integrated.
    ...   Test tools:WebUI, btslog
    ...   Test Steps:
    ...     Step1: Modify parameter which will not cause site reset and will not cause error when do validation.
    ...            eg:modify 'shutdownNogNBCellTmr' to a different value
    ...     Step2: Validate and check error not exist on WebEM.
    ...     Step3: Capture btslog and do activation.
    ...     Step4: Caculate duration between message "finishActivation" and "Transfer ccn succeedand"
    ...     in btslog and check duration no more than requirement
    [Arguments]    ${Duration_ChangeNoti}=${KPI['CM_A_11']['Duration_ChangeNoti']}
    COAM_WebEM.Login
    Log To Console    Step1: Modify parameter which will not cause site reset and will not cause error when do validation.
    ${InActSA_Value}    selenium_coam.get_parameter_value
    ...    dist_name=${distname}    filter_param=Waiting timer for SCTP link shutdown due to no gNB cell
    ${InActSA_Value}    get regexp matches    ${InActSA_Value}     [0-9]+
    ${InActSA_Value}    Evaluate    ${InActSA_Value[0]}+1
    ${InActSA_Value_New}=  set variable if    ${InActSA_Value} >= ${5}   3   8
    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=Waiting timer for SCTP link shutdown due to no gNB cell
    ...    new_value=${InActSA_Value_New}
    selenium_coam.validate_plan
    Log To Console    Step2: Validate and check error not exist on WebEM.
    ${error}    selenium_coam.get_relation_errors
    Should Be Empty     ${error}
    Log To Console    Step3: Capture btslog and do activation.
    ${CheckString}    set variable     "finishActivation|Transfer ccn succeed"
    run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
    run keyword and ignore error    run    command=cd /tmp/;rm -rf BTSLOG_AA_11.txt
    BtsLog.StartBTSlogCollection
    #run    command=tail -f /tmp/btslog2/SYSLOG_*.LOG |grep -E ${CheckString} >> /tmp/BTSLOG_AA_11.txt&
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    Sleep    5s
    run    command=ps -ef|grep tail|grep -v grep|awk '{print $2}' | xargs kill -9
    Sleep    2s
    COAM_WebEM.Logout
    BtsLog.StopBTSlogCollectionandGetlog
    Log To Console    Step4: Caculate duration between message "finishActivation" and "Transfer ccn succeedand"
    ...     in btslog and check duration no more than requirement.
    run    command=cat /tmp/btslog2/SYSLOG_*.LOG |grep -E ${CheckString} >> /tmp/BTSLOG_AA_11.txt&
    Sleep    2s
    ${Noti_Time0}     run    command=cat /tmp/BTSLOG_AA_11.txt|grep finishActivation|awk '{print $7}'|head -n 1|tail -1
    Should Not Be Empty     ${Noti_Time0}
    ${Noti_Time0}        convert date    ${Noti_Time0.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${Noti_Time2}    run    command=cat /tmp/BTSLOG_AA_11.txt | grep "Transfer ccn succeed"|awk '{print $7}'|head -n 3|tail -1
    Should Not Be Empty     ${Noti_Time2}
    ${Noti_Time2}        convert date    ${Noti_Time2.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${Noti_Duration1}    Evaluate    ${Noti_Time2}-${Noti_Time0}
    Should Be True     ${Noti_Duration1}<=${Duration_ChangeNoti} and ${Noti_Duration1}>${0}

TC.SWM_Duration_of_Copy_SW_from_Active_to_Passive_Partition_Manually_Triggered
   [Documentation]
    ...   Purpose:Check duration of Copy SW from active to Passive with health check
    ...   Precondition: SWs in active partition and passive partition are diff
    ...   Test tools:WebEM，btslog
    ...   Test Steps:
    ...     Step1: login WebEM and set the relate parameters
    ...     Step2: wait SW copy succeed
    ...     Step3: check the duration from syslogs
    [Arguments]   ${DurationOfSwCopyManual}=${KPI['CM_A_12']['DurationOfSwCopyManual']}
    set test variable    ${execution_result}    fail
    Log To Console    Step1: login WebEM and set the relate parameters
    COAM_WebEM.Login
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${active_version}    string.split string    string=${version}[Active]
    ${passive_version}    string.split string    string=${version}[Passive]
    run keyword if    ${active_version}==${passive_version}    Fail    precondition not meet.
    run keyword and ignore error    selenium_coam.remove_object    object_name=${MRBTS_ID}/MNL-1/CMD-1/COPYSWTOPASSIVEREQ-1
    run keyword and ignore error    COAM_WebEM.ValidateAndActiveParameters
    btslog.startbtslogcollection
    ${object_list}    selenium_coam.get_object_name_list    object_name=${MRBTS_ID}/MNL-1/CMD-1
    ${object_num}   Get Length   ${object_list}
    Run Keyword If  ${object_num}==${0}    selenium_coam.add_object    object_name=${MRBTS_ID}/MNL-1
    ...    object_class_name=CMD  id_value=1    timeout=60
    Wait Until Keyword Succeeds    2min    5s   selenium_coam.add_object    object_name=${MRBTS_ID}/MNL-1/CMD-1
    ...    object_class_name=COPYSWTOPASSIVEREQ   timeout=60
    run keyword and ignore error   COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/MNL-1/CMD-1/COPYSWTOPASSIVEREQ-1
    ...      abbr=COPYSWTOPASSIVEREQ instance id    value=${1}
    Wait Until Keyword Succeeds    2min    5s   COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/MNL-1/CMD-1/COPYSWTOPASSIVEREQ-1
    ...      abbr=Copy SW and config to passive partition command    value=SW and config with health check
    COAM_WebEM.ValidateAndActiveParameters
    Log To Console    Step2: wait SW copy succeed
    sleep   10min
    btslog.stopbtslogcollectionandgetlog
    Log To Console    Step3: check the duration from syslogs
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "COPYSWTOPASSIVEREQ"|
    ...       awk '{print $7}'|head -n 1|tail -1
    ${SwCopy_startTime}=     run    command=${cmd}
    Should Not Be Empty     ${SwCopy_startTime}
    ${SwCopy_startTime}     convert date
    ...    ${SwCopy_startTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${cmd}     Catenate    cat /tmp/btslog2/SYSLOG_*.LOG|grep "CopySwToPassive"|grep -E
    ...     "Result succesfull|Copy Sw to passive was successfull"|awk '{print $7}'|head -n 1|tail -1
    ${SwCopy_endTime}=     run    command=${cmd}
    Should Not Be Empty     ${SwCopy_endTime}
    ${SwCopy_endTime}        convert date
    ...     ${SwCopy_endTime.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${DurationOfSwCopy_tmp_SWM18}    Evaluate    ${SwCopy_endTime}-${SwCopy_startTime}
    AppendCaseResultToFile    requirement_id=${TEST NAME}
    ...    target_value=${DurationOfSwCopyManual}    result_value=${DurationOfSwCopy_tmp_SWM18}
    run keyword and continue on failure    Should Be True
    ...    ${DurationOfSwCopy_tmp_SWM18}<=${DurationOfSwCopyManual} and ${DurationOfSwCopy_tmp_SWM18}>${0}
    Log To Console   Duration of Copy SW from active to passive is ${DurationOfSwCopy_tmp_SWM18}s
    set test variable    ${execution_result}    pass

TC.LOG_Manual_Trigger_Snapshot
    [Documentation]
    ...   Purpose:Check manually triggered on-demand snapshot can be success and duration meeting requirement
    ...   Precondition:NA
    ...   Test tools:webui
    ...   Test Steps:
    ...     Step1:Save snapshot by choosing all log files,and check duration meet target
    [Arguments]   ${snapshot_save_time}=${KPI['CM_A_13']['snapshot_save_time']}
    set test variable    ${execution_result}    fail
    log to console    Step1:Save snapshot by choosing all log files,and check duration meet target
    BtsLog.StartBTSlogCollection
    COAM_WebEM.Login
    ${timestartTmp}   Get Current Date
    ${timestart}      convert date    ${timestartTmp}    epoch
    ${timeendTmp}     Get Current Date
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    ${timeendTmp}     Get Current Date
    ${timeend}        convert date    ${timeendTmp}     epoch
    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}
    log     ${duration_time_tmp}
    AppendCaseResultToFile    requirement_id=${TEST NAME}}
    ...    target_value=${snapshot_save_time}    result_value=${duration_time_tmp}
    Should Be True     ${duration_time_tmp}<=${snapshot_save_time}     Snapshot collect time is more than 15 minute
    set test variable    ${execution_result}    pass

TC.LOG_Automatically_Triggered_Snapshot
    [Documentation]
    ...   Purpose:Check snapshot is triggered by fault can be success and duration meeting requirement
    ...   Precondition:Netact is integrated.
    ...   Test tools:webui,netact
    ...   Test Steps:
    ...     Step1:Set fault number and trigger type in WebUI
    ...     Step2:Trigger fault which set in step1
    ...     Step3:Check snapshot exist in Netact logserver,and duration meet requirement.
    [Arguments]   ${FilePresentTime}=${KPI['CM_A_14']['FilePresentTime']}
    [Teardown]    KW.WebEMRestore
    set test variable    ${execution_result}    fail
    log to console    Step1:Set fault number and trigger type in WebUI
    BtsLog.StartBTSlogCollection
    wait until keyword succeeds   15min    10s    COAM_WebEM.Login
    run keyword and ignore error     COAM_WebEM.DeleteParameter    distName=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    abbr=Fault snapshot triggers
    sleep    2s
    COAM_WebEM.ValidateAndActiveParameters
    run keyword and ignore error     selenium_coam.add_element    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
     ...    filter_param=Fault snapshot triggers      timeout=${100}
    sleep    2s
    run keyword and ignore error     selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault number     parameter_status=Show only modified parameters    new_value=${7516}    node_index=${0}    timeout=${100}
    sleep    2s
    run keyword and ignore error    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Trigger type      new_value=onFaultDetection    node_index=${0}    timeout=${100}
    sleep    2s
    COAM_WebEM.ValidateAndActiveParameters
    log to console    trigger fault

#    ${Smods}    COAM_Admin.GetBTSTopology
#    FOR    ${smod}    IN    @{Smods}
#        wait until keyword succeeds   15min    10s    COAM_WebEM.Login
#        ${CellID}    set variable    ${smod['BBMODs'][0]['RUs'][0]['Cells'][0]['id']}
#        set test variable    ${CellID}
#        ${pdcch_org}    CM_WebEM.GetListParameter     dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${CellID}    filter_param=${PdcchMonOccsnPo}
#        ...     node_index=${0}
#        set test variable      ${pdcch_org}
#        Process.ChangeCellParameterToTestFault    filter_param=${PdcchMonOccsnPo}   newvalue=${pdcch_wrong}    cellid=${CellID}
#
#        wait until keyword succeeds   1min    2s    Alarm.Check Certain Alarm with Severity form Active Alarms   target_alarm_id=7114
#        ...    target_fault_id=7516    target_fault_name=Incorrect cell parameter configuration    target_severity=major
#
#        Timer.Start
#        wait until keyword succeeds   ${FilePresentTime}min   20s    KW.CheckFilePresent
#        ${duration}    Timer.Stop
#        log to console    ${duration}
#    END
     log to console    Step2:Trigger fault which set in step1
     ${Smods}    COAM_Admin.GetBTSTopology
     FOR    ${smod}    IN    @{Smods}
         #Note:Modify ${gscn} in nrcell1 per smod to trgger fault
         run keyword and ignore error    KW.CheckFilePresent
         wait until keyword succeeds   15min    10s    COAM_WebEM.Login
         ${CellID}    set variable    ${smod['BBMODs'][0]['RUs'][0]['Cells'][0]['id']}
         set test variable    ${CellID}
         ${gscn_org}    CM_WebEM.GetListParameter     dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${CellID}    filter_param=${gscn}
         set test variable    ${gscn_org}
         set suite variable    ${restored}    false
         Process.ChangeCellParameterToTestFault    filter_param=${gscn}   newvalue=${gscn_wrong}    cellid=${CellID}
         wait until keyword succeeds   1min   2s    Alarm.Check Certain Alarm with Severity form Active Alarms   target_alarm_id=7114
         ...    target_fault_id=7516    target_fault_name=Incorrect cell parameter configuration    target_severity=critical
         log to console    Step3:Check snapshot exist in Netact logserver,and duration meet requirement.
         Timer.Start
         wait until keyword succeeds   30min   20s    KW.CheckFilePresent
         ${duration}    Timer.Stop
         log to console    ${duration}
         KW.FM.CancelCriticalFault7516
         Alarm.check alarm is not in active alarms    alarm_filter=7114
         set suite variable    ${restored}    true
         AppendCaseResultToFile    requirement_id=${TEST NAME}
         ...    target_value=${FilePresentTime}    result_value=${duration}
         Should be true    ${duration}<=${FilePresentTime}
    END
    set test variable    ${execution_result}    pass

TC.Troubleshooting_IP_connectivity_test
    [Documentation]   OM_GEN_SFS_PERF_CAP.6964
    ...  Purpose:Aim to test IP connectivity test duration
    ...  Precondition:BTS is commissioned
    ...  Test tools:WebUI
    ...  Test Steps:
    ...    Step1: login WebEM to perform  IP connectivity test then start point
    ...    Step2: Wait until next IP connectivity test successful  -- end point
    ...    Step3: Check the duatation is not more than target
    ...    Checkpoint configuration:
    [Arguments]   ${IP_connectivity}=20
    set test variable    ${execution_result}    fail
    log to console    Step1: login WebEM to perform IP connectivity test
    wait until keyword succeeds   15min    10s    COAM_Admin.Login
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    admin.test_ip_connectivity    remote_address=${UTE_IP}    dscp=10    payload_size=34    source_address=User-defined address    connection=COAM
    sleep    2s
    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${1}
    ${duration}     SYSLOG.GetDuration    TimeStartString=${KEY_TIMESTART_IP_connectivity_test}
    ...    TimeEndString=${KEY_TIMEEND_IP_connectivity_test}    option=-E
    ${res}    set variable if    ${duration}<=${IP_connectivity}      pass    fail
    log to console   IP_connectivity_check:${duration}s target:${IP_connectivity}s result:${res}
    AppendCaseResultToFile    requirement_id=${TEST NAME}
    ...    target_value=${IP_connectivity}    result_value=${duration}
    Should Be True     ${duration}<=${IP_connectivity}
    COAM_Admin.Logout
    set test variable    ${execution_result}    pass
    [Teardown]   RUN KEYWORD If    '${execution_result}'=='fail'
    ...     run keyword and ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${2}

TC.Troubleshooting_System_Module_Sanity_Checker
    [Documentation]   OM_GEN_SFS_PERF_CAP.10677
    ...  Purpose:Aim to test run sanity checker duration
    ...  Precondition:BTS is commissioned
    ...  Test tools:WebUI
    ...  Test Steps:
    ...    Step1: login WebEM to perform run sanity checker --start point
    ...    Step2: sanity checker successful  -- end point
    ...    Step3: Check the duatation is not more than target
    ...    Checkpoint configuration:
    [Arguments]   ${Sanity_Checker}=60
    set test variable    ${execution_result}    fail
    log to console    Step1: System Module Sanity Checker
    wait until keyword succeeds   15min    10s    COAM_Admin.Login
    #Timer.Start
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    admin.run_sanity_check    connection=COAM
    #${duration}    Timer.Stop
    sleep    2s
    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${1}
    ${duration}     SYSLOG.GetDuration    TimeStartString=${KEY_TIMESTART_SanityChecker}    TimeEndString=${kEY_TIMEEND_SanityChecker}
    ${res}    set variable if    ${duration}<=${Sanity_Checker}      pass    fail
    log to console   sanity_check:${duration}s target:${Sanity_Checker}s result:${res}
    AppendCaseResultToFile    requirement_id=${TEST NAME}
    ...    target_value=${Sanity_Checker}    result_value=${duration}
    Should Be True     ${duration}<=${Sanity_Checker}
    COAM_Admin.Logout
    set test variable    ${execution_result}    pass
    [Teardown]   RUN KEYWORD If    '${execution_result}'=='fail'
    ...     run keyword and ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${2}
##########end keyword for CB008681-SR-A########################################################

##########start keyword for kpi calculate base on IMS file#####################################
OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core_IMS
    [Arguments]    ${WebUI_reset_times}=1
    KPI_Test_Case_cycle    case_name=OAM_KPI_1a_Site_Reset    KPI_target_average=${KPI1a_AVG}
    ...    times=${WebUI_reset_times}    pass=${WebUI_reset_times}
OAM_KPI_1f_Site_Reset_Without_RU_reset_Outage_Duration_Single_Core_IMS
    [Arguments]    ${WebUI_reset_times}=1
    KPI_Test_Case_cycle    case_name=OAM_KPI_1f_Site_Reset_without_RU_reset    KPI_target_average=${KPI1f_AVG}
    ...    times=${WebUI_reset_times}    pass=${WebUI_reset_times}
OAM_KPI_3_Power_on_startup_availability_IMS
    [Arguments]    ${WebUI_reset_times}=1
    KPI_Test_Case_cycle    case_name=OAM_KPI_3_Power_on_reset    KPI_target_average=${KPI3_AVG}
    ...    times=${WebUI_reset_times}    pass=${WebUI_reset_times}
OAM_KPI_51a_Manual_RU_reset_downtime_IMS
    [Arguments]    ${WebUI_reset_times}=1    ${ru_index}=1
    KPI51a_Test_Case_cycle    ru_index=${ru_index}    times=${WebUI_reset_times}    pass=${WebUI_reset_times}
OAM_KPI_10a_RAT_Reset_downtime_IMS
    [Arguments]    ${WebUI_reset_times}=1
    General_KPI_Test_Case    case_name=OAM_KPI_10a_RAT_Reset    times=${WebUI_reset_times}    pass=${WebUI_reset_times}
OAM_KPI_10b_RAT_Reset_downtime_IMS
    [Arguments]    ${WebUI_reset_times}=1
    General_KPI_Test_Case    case_name=OAM_KPI_10b_RAT_Reset    times=${WebUI_reset_times}    pass=${WebUI_reset_times}
OAM_KPI_54a_Manual_RU_power_on_reset_downtime_IMS
    [Arguments]    ${WebUI_reset_times}=1    ${ru_index}=1
    KPI54a_Test_Case_cycle    ru_index=${ru_index}    times=${WebUI_reset_times}    pass=${WebUI_reset_times}
OAM_KPI_16a_16b_Manual_lock_unlock_cell_downtime_IMS
    [Arguments]    ${WebUI_reset_times}=1    ${cell_index}=1
    KPI_Test_Case_cycle_with_16a_16b    cell_index=${cell_index}
    ...    times=${WebUI_reset_times}    pass=${WebUI_reset_times}
OAM_KPI_17a_17b_Manual_block_unblock_cell_downtime_IMS
    [Arguments]    ${WebUI_reset_times}=1    ${cell_index}=1
    KPI_Test_Case_cycle_with_17a_17b    cell_index=${cell_index}
    ...    times=${WebUI_reset_times}    pass=${WebUI_reset_times}
OAM_KPI_11_remote_power_reset_downtime_IMS
    [Arguments]    ${WebUI_reset_times}=1
    KPI_Test_Case_cycle    case_name=OAM_KPI_11_Remote_Power_Reset    KPI_target_average=${KPI11_AVG}
    ...    times=${WebUI_reset_times}    pass=${WebUI_reset_times}
OAM_KPI_14_capacity_module_power_reset_IMS
    [Arguments]    ${WebUI_reset_times}=1    ${baseband_unit}=BBMOD-1 / BBMOD_R-1 (ABIO)
    KPI14_Test_Case_cycle    baseband_unit=${baseband_unit}    times=${WebUI_reset_times}    pass=${WebUI_reset_times}
    ...    KPI_target_average=${KPI14_AVG}
OAM_KPI_5_capacity_module_reset_IMS
    [Arguments]    ${WebUI_reset_times}=1    ${baseband_index}=${1}
    KPI5_Test_Case_cycle    times=${WebUI_reset_times}    pass=${WebUI_reset_times}    baseband_index=${baseband_index}
OAM_KPI_12_BTS_Reset_After_Plan_Activation_downtime_IMS
    [Arguments]    ${WebUI_reset_times}=1
    KPI_Test_Case_cycle    case_name=OAM_KPI_12_BTS_Reset_After_Plan_Activation_downtime
    ...    KPI_target_average=${KPI12_AVG}
    ...    times=${WebUI_reset_times}    pass=${WebUI_reset_times}
OAM_KPI_19_cell_reset_IMS
    [Arguments]    ${WebUI_reset_times}=1    ${cell_index}=${1}
    KPI19_Test_Case_cycle    cell_index=${cell_index}    times=${WebUI_reset_times}    pass=${WebUI_reset_times}
OAM_KPI_15_cell_locking_downtime_IMS
    [Arguments]    ${WebUI_reset_times}=1    ${cell_index}=${1}
    KPI15_Test_Case_cycle    cell_index=${cell_index}    times=${WebUI_reset_times}    pass=${WebUI_reset_times}
OAM_KPI_1a_Site_Reset
    [Arguments]
    oam_kpi_calculations.clear_results
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
#    oam_kpi_calculations.save_search_start_timestamp
    log to console    start to reset gnb
    selenium_coam.reset_site
    selenium logout and close browser
    sleep    1min
    wait until keyword succeeds    15min    10s    Check all cells Info Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/
    sleep    2min
    check no unexpected alarm    is_check_historyalarm=${True}
    oam_kpi_calculations.calculate_kpi1a    ims_file_path=${ims_file}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${SAVE LOG DIRECTORY}/loop_ims2/results_${ims_file_date}.json
    ${kpi_result}    oam_kpi_calculations.get_results
    ${kpi1a_value}=    oam_kpi_calculations.get_average_results    kpi_name=kpi1a
    Should Be True    ${kpi1a_value}<${KPI1a_MAX}
    log to console    kpi1a_value is ${kpi1a_value}\n
    ${KPI_intotall} =    Evaluate    ${KPI_intotall} + ${kpi1a_value}
    set test variable     ${KPI_intotall}
OAM_KPI_1f_Site_Reset_without_RU_reset
    [Arguments]    ${with_graceful}=False    ${without_radio_reset}=True
    oam_kpi_calculations.clear_results
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
#    oam_kpi_calculations.save_search_start_timestamp
    log to console    start to reset gnb
    selenium_coam.reset_site    ${with_graceful}    ${without_radio_reset}
    selenium logout and close browser
    sleep    1min
    wait until keyword succeeds    15min    10s    Check all cells Info Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/
    sleep    2min
    check no unexpected alarm    is_check_historyalarm=${True}
    oam_kpi_calculations.calculate_kpi1f    ims_file_path=${ims_file}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${SAVE LOG DIRECTORY}/loop_ims2/results_${ims_file_date}.json
    ${kpi_result}    oam_kpi_calculations.get_results
    ${kpi1f_value}=    oam_kpi_calculations.get_average_results    kpi_name=kpi1f
    Should Be True    ${kpi1f_value}<${KPI1f_MAX}
    log to console    kpi1a_value is ${kpi1f_value}\n
    ${KPI_intotall} =    Evaluate    ${KPI_intotall} + ${kpi1f_value}
    set test variable     ${KPI_intotall}
OAM_KPI_3_Power_on_reset
    oam_kpi_calculations.clear_results
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    log to console    start to power off gnb
    Perform Site Power Off
    sleep    30s
    log to console    start to power on gnb
    Perform Site Power On
    ${bts_power_on_timestamp}     DateTime.Get current date    time_zone=UTC
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    sleep    1min
    wait until keyword succeeds    10min    10s    Check all cells Info Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    sleep    2min
    check no unexpected alarm
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/
    oam_kpi_calculations.calculate_kpi3    ims_file_path=${ims_file}    start_point_timestamp=${bts_power_on_timestamp}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${SAVE LOG DIRECTORY}/loop_ims2/results_${ims_file_date}.json
    ${kpi_result}    oam_kpi_calculations.get_results
    ${kpi3_value}=    oam_kpi_calculations.get_average_results    kpi_name=kpi3
    Should Be True    ${kpi3_value}<${KPI3_MAX}
    log to console    kpi3_value is ${kpi3_value}\n
    ${KPI_intotall} =    Evaluate    ${KPI_intotall} + ${kpi3_value}
    set test variable     ${KPI_intotall}
OAM_KPI_51a_RU_Reset_IMS
    [Arguments]    ${ru_index}=1
    oam_kpi_calculations.clear_results
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
#    oam_kpi_calculations.save_search_start_timestamp
    selenium_coam.reset_ru    ru_index=${ru_index}
    selenium logout and close browser
    sleep    1min
    wait until keyword succeeds    15min    10s    Check all cells Info Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/
    check no unexpected alarm    is_check_historyalarm=${True}
    oam_kpi_calculations.calculate_kpi51a    ims_file_path=${ims_file}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${SAVE LOG DIRECTORY}/loop_ims2/results_${ims_file_date}.json
    ${kpi_result}    oam_kpi_calculations.get_results
    ${kpi51a_value}=    oam_kpi_calculations.get_average_results    kpi_name=kpi51a
    Should Be True    ${kpi51a_value}<${KPI51a_MAX}
    log to console    kpi51a_value is ${kpi51a_value}\n
OAM_KPI_54a_RU_Power_On_Reset_IMS
    [Arguments]    ${ru_index}=1
    oam_kpi_calculations.clear_results
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
#    oam_kpi_calculations.save_search_start_timestamp
    Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    Wait until keyword succeeds    3 min    20 sec    RU Should Be Power Off    ru_index=${ru_index}
    Perform RU Power On    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    ${bts_power_on_timestamp}     DateTime.Get current date    time_zone=UTC
    sleep    1min
    wait until keyword succeeds    15min    10s    Check all cells Info Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/
    ${Fault_4589}    Create Dictionary    faultId=${4589}
    Append to list     ${ALLOWED_FAULT}    ${Fault_4589}
    check no unexpected alarm
    oam_kpi_calculations.calculate_kpi54a    ims_file_path=${ims_file}    start_point_timestamp=${bts_power_on_timestamp}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${SAVE LOG DIRECTORY}/loop_ims2/results_${ims_file_date}.json
    ${kpi_result}    oam_kpi_calculations.get_results
    ${kpi54a_value}=    oam_kpi_calculations.get_average_results    kpi_name=kpi54a
    Should Be True    ${kpi54a_value}<${KPI54a_MAX}
    log to console    kpi54a_value is ${kpi54a_value}\n
OAM_KPI_10a_RAT_Reset
    oam_kpi_calculations.clear_results
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
#    oam_kpi_calculations.save_search_start_timestamp
    log to console    start to Rat reset
    selenium_coam.reset_nr    with_graceful=${False}
    selenium logout and close browser
    sleep    60s
    wait until keyword succeeds    10min    10s    Check all cells Info Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    sleep    2min
    check no unexpected alarm    is_check_historyalarm=${True}
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/
    oam_kpi_calculations.calculate_kpi10a    ims_file_path=${ims_file}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${SAVE LOG DIRECTORY}/loop_ims2/results_${ims_file_date}.json
    ${result}    oam_kpi_calculations.get_results
    ${kpi10a_avg}=    oam_kpi_calculations.get_average_results    kpi_name=kpi10a
    Should Be True    ${kpi10a_avg}<${KPI10a_MAX}
    log to console    kpi10a_avg is ${kpi10a_avg}\n
OAM_KPI_10b_RAT_Reset
    oam_kpi_calculations.clear_results
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
#    oam_kpi_calculations.save_search_start_timestamp
    log to console    start to Rat hard reset
    selenium_coam.reset_nr    with_hard=${True}    with_graceful=${False}
    selenium logout and close browser
    sleep    2min
    run keyword and ignore error    COAM Check X2 link status from GNB    connection=GNB_OAM
    wait until keyword succeeds    10min    10s    Check all cells Info Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    check no unexpected alarm    is_check_historyalarm=${True}
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/
    oam_kpi_calculations.calculate_kpi10b    ims_file_path=${ims_file}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${SAVE LOG DIRECTORY}/loop_ims2/results_${ims_file_date}.json
    ${result}    oam_kpi_calculations.get_results
    ${kpi10b_avg}=    oam_kpi_calculations.get_average_results    kpi_name=kpi10b
    Should Be True    ${kpi10b_avg}<${KPI10b_MAX}
    log to console    kpi10b_avg is ${kpi10b_avg}\n
OAM_KPI_16a_16b_lock_unlock_cell
    [Arguments]    ${cell_index}=1
    oam_kpi_calculations.clear_results
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
#    oam_kpi_calculations.save_search_start_timestamp
    log to console    start to lock cell-${cell_index}
    Perform cell lock via rest api    cell_idx=${cell_index}
    Wait Until Keyword Succeeds   3 min  10 sec   Cell Should Be Locked
    ...    cell_idx=${cell_index}   cell_group_idx=${${cell_index}-1}
    log to console    start to unlock cell-${cell_index}
    Perform cell unlock via rest api    cell_idx=${cell_index}
    sleep    3s
    wait until keyword succeeds    2min    6s    Check all cells Info Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/
    check no unexpected alarm
    oam_kpi_calculations.calculate_kpis    kpi_names=${lock_unlock_kpis}    ims_file_path=${ims_file}
    Run Keyword and Continue on Failure    oam_kpi_calculations.save_results_to_file
    ...    file_path=${SAVE LOG DIRECTORY}/loop_ims2/results_${ims_file_date}.json
    ${kpi_result}    oam_kpi_calculations.get_results
    ${kpi16a_value}=    oam_kpi_calculations.get_average_results    kpi_name=kpi16a
    ${kpi16b_value}=    oam_kpi_calculations.get_average_results    kpi_name=kpi16b
    Should Be True    ${kpi16a_value}<${KPI16a_MAX}
    Should Be True    ${kpi16b_value}<${KPI16b_MAX}
    log to console    kpi16a_value is ${kpi16a_value}\n
    log to console    kpi16b_value is ${kpi16b_value}\n
OAM_KPI_17a_17b_block_unblock_cell
    [Arguments]    ${cell_index}=1    ${technology}=nr
    oam_kpi_calculations.clear_results
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    wait until keyword succeeds    2min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
#    oam_kpi_calculations.save_search_start_timestamp
    log to console    start to block cell-${cell_index}
    selenium_coam.block_cell    cell_idx=${cell_index}    technology=${technology}
    sleep    3s
    log to console    start to unblock cell-${cell_index}
    selenium_coam.unblock_cell    cell_idx=${cell_index}    technology=${technology}
    sleep    2s
    wait until keyword succeeds    1min    3s    Check all cells Info Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    selenium logout and close browser
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/
    check no unexpected alarm
    oam_kpi_calculations.calculate_kpis    kpi_names=${block_unblock_kpis}    ims_file_path=${ims_file}
    Run Keyword and Continue on Failure    oam_kpi_calculations.save_results_to_file
    ...    file_path=${SAVE LOG DIRECTORY}/loop_ims2/results_${ims_file_date}.json
    ${kpi_result}    oam_kpi_calculations.get_results
    ${kpi17a_value}=    oam_kpi_calculations.get_average_results    kpi_name=kpi17a
    ${kpi17b_value}=    oam_kpi_calculations.get_average_results    kpi_name=kpi17b
    Should Be True    ${kpi17a_value}<${KPI17a_MAX}
    Should Be True    ${kpi17b_value}<${KPI17b_MAX}
    log to console    kpi17a_value is ${kpi17a_value}\n
    log to console    kpi17b_value is ${kpi17b_value}\n
KPI_Test_Case_cycle
    [Arguments]   ${case_name}    ${KPI_target_average}    ${times}=${1}    ${pass}=${1}
    ${pass_times}   Set variable    ${0}
    Log to console    \nstability test begin
    FOR    ${itime}    IN RANGE    1    ${times}+1
           Log to console    \n---------------------\nstability run: ${itime}/${times}
           ${result} =    Run Keyword And Return Status    ${case_name}
           log to console    result:${result}\n---------------------\n
           ${pass_times}    Run Keyword If    ${result}    evaluate    ${pass_times}+1    ELSE    set variable    ${pass_times}
           ${fail_in_loop}    evaluate    (${itime}-${pass_times})>(${times}-${pass})
           run keyword if    ${fail_in_loop}     Fail    Fail times excceed
    END
    ${rate}    evaluate    ${pass_times}/${times}*100
    ${KPI_average}    evaluate    ${KPI_intotall}/${times}
    Should Be True    ${KPI_average}<${KPI_target_average}
    ${check_type}    run keyword if    ${pass}>1     run keywords    log to console    pass/total: ${pass_times}/${times}
    ...    AND    should be true    ${pass_times}>=${pass}    AND    Return From Keyword    ${pass_times}
    ...    ELSE   run keywords   log to console   pass rate: ${rate}%    AND    should be true    ${rate}>=${pass}
    ...    AND    Return From Keyword    ${rate}%

KPI51a_Test_Case_cycle
    [Arguments]    ${times}=${1}    ${pass}=${1}     ${ru_index}=1
    ${pass_times}   Set variable    ${0}
    Log to console    \nstability test begin
    FOR    ${itime}    IN RANGE    1    ${times}+1
           Log to console    \n---------------------\nstability run: ${itime}/${times}
           ${result} =    Run Keyword And Return Status    OAM_KPI_51a_RU_Reset_IMS    ru_index=${ru_index}
           log to console    result:${result}\n---------------------\n
           ${pass_times}    Run Keyword If    ${result}    evaluate    ${pass_times}+1    ELSE    set variable    ${pass_times}
           ${fail_in_loop}    evaluate    (${itime}-${pass_times})>(${times}-${pass})
           run keyword if    ${fail_in_loop}     Fail    Fail times excceed
    END
    ${rate}    evaluate    ${pass_times}/${times}*100
    ${check_type}    run keyword if    ${pass}>1     run keywords    log to console    pass/total: ${pass_times}/${times}
    ...    AND    should be true    ${pass_times}>=${pass}    AND    Return From Keyword    ${pass_times}
    ...    ELSE   run keywords   log to console   pass rate: ${rate}%    AND    should be true    ${rate}>=${pass}
    ...    AND    Return From Keyword    ${rate}%
KPI54a_Test_Case_cycle
    [Arguments]     ${times}=${1}    ${pass}=${1}     ${ru_index}=1
    ${pass_times}   Set variable    ${0}
    Log to console    \nstability test begin
    FOR    ${itime}    IN RANGE    1    ${times}+1
           Log to console    \n---------------------\nstability run: ${itime}/${times}
           ${result} =    Run Keyword And Return Status    OAM_KPI_54a_RU_Power_On_Reset_IMS    ru_index=${ru_index}
           log to console    result:${result}\n---------------------\n
           ${pass_times}    Run Keyword If    ${result}    evaluate    ${pass_times}+1    ELSE    set variable    ${pass_times}
           ${fail_in_loop}    evaluate    (${itime}-${pass_times})>(${times}-${pass})
           run keyword if    ${fail_in_loop}     Fail    Fail times excceed
    END
    ${rate}    evaluate    ${pass_times}/${times}*100
    ${check_type}    run keyword if    ${pass}>1     run keywords    log to console    pass/total: ${pass_times}/${times}
    ...    AND    should be true    ${pass_times}>=${pass}    AND    Return From Keyword    ${pass_times}
    ...    ELSE   run keywords   log to console   pass rate: ${rate}%    AND    should be true    ${rate}>=${pass}
    ...    AND    Return From Keyword    ${rate}%
KPI_Test_Case_cycle_with_16a_16b
    [Arguments]    ${times}=${1}    ${pass}=${1}    ${cell_index}=1
    ${pass_times}   Set variable    ${0}
    Log to console    \nstability test begin
    FOR    ${itime}    IN RANGE    1    ${times}+1
           Log to console    \n---------------------\nstability run: ${itime}/${times}
           ${result} =    Run Keyword And Return Status    OAM_KPI_16a_16b_lock_unlock_cell    cell_index=${cell_index}
           log to console    result:${result}\n---------------------\n
           ${pass_times}    Run Keyword If    ${result}    evaluate    ${pass_times}+1    ELSE    set variable    ${pass_times}
           ${fail_in_loop}    evaluate    (${itime}-${pass_times})>(${times}-${pass})
           run keyword if    ${fail_in_loop}     Fail    Fail times excceed
    END
    ${rate}    evaluate    ${pass_times}/${times}*100
    ${check_type}    run keyword if    ${pass}>1     run keywords    log to console    pass/total: ${pass_times}/${times}
    ...    AND    should be true    ${pass_times}>=${pass}    AND    Return From Keyword    ${pass_times}
    ...    ELSE   run keywords   log to console   pass rate: ${rate}%    AND    should be true    ${rate}>=${pass}
    ...    AND    Return From Keyword    ${rate}%
KPI_Test_Case_cycle_with_17a_17b
    [Arguments]    ${times}=${1}    ${pass}=${1}    ${cell_index}=1
    ${pass_times}   Set variable    ${0}
    Log to console    \nstability test begin
    FOR    ${itime}    IN RANGE    1    ${times}+1
           Log to console    \n---------------------\nstability run: ${itime}/${times}
           ${result} =    Run Keyword And Return Status    OAM_KPI_17a_17b_block_unblock_cell    cell_index=${cell_index}
           log to console    result:${result}\n---------------------\n
           ${pass_times}    Run Keyword If    ${result}    evaluate    ${pass_times}+1    ELSE    set variable    ${pass_times}
           ${fail_in_loop}    evaluate    (${itime}-${pass_times})>(${times}-${pass})
           run keyword if    ${fail_in_loop}     Fail    Fail times excceed
    END
    ${rate}    evaluate    ${pass_times}/${times}*100
    ${check_type}    run keyword if    ${pass}>1     run keywords    log to console    pass/total: ${pass_times}/${times}
    ...    AND    should be true    ${pass_times}>=${pass}    AND    Return From Keyword    ${pass_times}
    ...    ELSE   run keywords   log to console   pass rate: ${rate}%    AND    should be true    ${rate}>=${pass}
    ...    AND    Return From Keyword    ${rate}%
KPI14_Test_Case_cycle
    [Arguments]    ${KPI_target_average}    ${baseband_unit}=BBMOD-1 / BBMOD_R-1 (ABIO)
    ...    ${times}=${1}    ${pass}=${1}
    ${pass_times}   Set variable    ${0}
    Log to console    \nstability test begin
    FOR    ${itime}    IN RANGE    1    ${times}+1
           Log to console    \n---------------------\nstability run: ${itime}/${times}
           ${result} =    Run Keyword And Return Status    OAM_KPI_14_capacity_module_power_reset    baseband_unit=${baseband_unit}
           log to console    result:${result}\n---------------------\n
           ${pass_times}    Run Keyword If    ${result}    evaluate    ${pass_times}+1    ELSE    set variable    ${pass_times}
           ${fail_in_loop}    evaluate    (${itime}-${pass_times})>(${times}-${pass})
           run keyword if    ${fail_in_loop}     Fail    Fail times excceed
    END
    ${rate}    evaluate    ${pass_times}/${times}*100
    ${KPI_average}    evaluate    ${KPI_intotall}/${times}
    Should Be True    ${KPI_average}<${KPI_target_average}
    ${check_type}    run keyword if    ${pass}>1     run keywords    log to console    pass/total: ${pass_times}/${times}
    ...    AND    should be true    ${pass_times}>=${pass}    AND    Return From Keyword    ${pass_times}
    ...    ELSE   run keywords   log to console   pass rate: ${rate}%    AND    should be true    ${rate}>=${pass}
    ...    AND    Return From Keyword    ${rate}%
    ${KPI_intotall}=    Set Variable    ${0}

OAM_KPI_14_capacity_module_power_reset
    [Arguments]     ${baseband_unit}=BBMOD-1 / BBMOD_R-1 (ABIO)
    oam_kpi_calculations.clear_results
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
#    oam_kpi_calculations.save_search_start_timestamp
    log to console    start to BBMOD power reset
    selenium_sbts.baseband_power_reset
    ...   baseband_unit=${baseband_unit}   with_graceful=${False}     timeout=600
    selenium logout and close browser
    sleep    1min
    wait until keyword succeeds    15min    10s    Check all cells Info Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/
    check no unexpected alarm
    oam_kpi_calculations.calculate_kpi14    ims_file_path=${ims_file}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${SAVE LOG DIRECTORY}/loop_ims2/results_${ims_file_date}.json
    ${kpi_result}    oam_kpi_calculations.get_results
    ${kpi14_value}=    oam_kpi_calculations.get_average_results    kpi_name=kpi14
    Should Be True    ${kpi14_value}<${KPI14_MAX}
    log to console    kpi14_value is ${kpi14_value}\n
    ${KPI_intotall} =    Evaluate    ${KPI_intotall} + ${kpi14_value}
    set test variable     ${KPI_intotall}
TestSuite_setup_withIMS
    KW.TestSuilt.Start
    SISO Coam Suite Setup
TestSuite_teardown_withIMS
    KW.TestSuilt.Stop
    SISO Coam Suite Teardown
OAM_KPI_11_Remote_Power_Reset
    [Arguments]
    oam_kpi_calculations.clear_results
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
#    oam_kpi_calculations.save_search_start_timestamp
    log to console    start to remote power reset gnb
    selenium_coam.power_reset
    ...   with_snapshot_collection=${False}   with_graceful=${False}     timeout=600
    selenium logout and close browser
    sleep    1min
    wait until keyword succeeds    15min    10s    Check all cells Info Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/
    sleep    2min
    check no unexpected alarm
    oam_kpi_calculations.calculate_kpi11    ims_file_path=${ims_file}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${SAVE LOG DIRECTORY}/loop_ims2/results_${ims_file_date}.json
    ${kpi_result}    oam_kpi_calculations.get_results
    ${kpi11_value}=    oam_kpi_calculations.get_average_results    kpi_name=kpi11
    Should Be True    ${kpi11_value}<${KPI11_MAX}
    log to console    kpi11_value is ${kpi11_value}\n
    ${KPI_intotall} =    Evaluate    ${KPI_intotall} + ${kpi11_value}
    set test variable     ${KPI_intotall}
KPI5_Test_Case_cycle
    [Arguments]    ${baseband_index}=${1}    ${times}=${1}    ${pass}=${1}
    ${pass_times}   Set variable    ${0}
    Log to console    \nstability test begin
    FOR    ${itime}    IN RANGE    1    ${times}+1
           Log to console    \n---------------------\nstability run: ${itime}/${times}
           ${result} =    Run Keyword And Return Status    OAM_KPI_5_capacity_module_reset    baseband_index=${baseband_index}
           log to console    result:${result}\n---------------------\n
           ${pass_times}    Run Keyword If    ${result}    evaluate    ${pass_times}+1    ELSE    set variable    ${pass_times}
           ${fail_in_loop}    evaluate    (${itime}-${pass_times})>(${times}-${pass})
           run keyword if    ${fail_in_loop}     Fail    Fail times excceed
    END
    ${rate}    evaluate    ${pass_times}/${times}*100
    ${check_type}    run keyword if    ${pass}>1     run keywords    log to console    pass/total: ${pass_times}/${times}
    ...    AND    should be true    ${pass_times}>=${pass}    AND    Return From Keyword    ${pass_times}
    ...    ELSE   run keywords   log to console   pass rate: ${rate}%    AND    should be true    ${rate}>=${pass}
    ...    AND    Return From Keyword    ${rate}%
OAM_KPI_5_capacity_module_reset
    [Arguments]    ${baseband_index}=${1}
    oam_kpi_calculations.clear_results
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
#    oam_kpi_calculations.save_search_start_timestamp
    log to console    start to reset capacity module
    selenium_coam.reset_baseband    baseband_index=${baseband_index}
    selenium logout and close browser
    sleep    1min
    wait until keyword succeeds    15min    10s    Check all cells Info Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/
    check no unexpected alarm    is_check_historyalarm=${True}
    oam_kpi_calculations.calculate_kpi5    ims_file_path=${ims_file}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${SAVE LOG DIRECTORY}/loop_ims2/results_${ims_file_date}.json
    ${kpi_result}    oam_kpi_calculations.get_results
    ${kpi5_value}=    oam_kpi_calculations.get_average_results    kpi_name=kpi5
    Should Be True    ${kpi5_value}<${KPI5_MAX}
    log to console    kpi5_value is ${kpi5_value}\n

OAM_KPI_12_BTS_Reset_After_Plan_Activation_downtime
    [Arguments]
    oam_kpi_calculations.clear_results
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
#    oam_kpi_calculations.save_search_start_timestamp
    log to console    start to modify paremeter
    modify_reseting_paremeter
    sleep    1min
    wait until keyword succeeds    15min    10s    Check all cells Info Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/
    check no unexpected alarm
    oam_kpi_calculations.calculate_kpi12    ims_file_path=${ims_file}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${SAVE LOG DIRECTORY}/loop_ims2/results_${ims_file_date}.json
    ${kpi_result}    oam_kpi_calculations.get_results
    ${kpi12_value}=    oam_kpi_calculations.get_average_results    kpi_name=kpi12
    Should Be True    ${kpi12_value}<${KPI12_MAX}
    log to console    kpi12_value is ${kpi12_value}\n
    ${KPI_intotall} =    Evaluate    ${KPI_intotall} + ${kpi12_value}
    set test variable     ${KPI_intotall}
    #[Teardown]    KPI12_teardown
KPI19_Test_Case_cycle
    [Arguments]    ${cell_index}=${1}
    ...    ${times}=${1}    ${pass}=${1}
    ${pass_times}   Set variable    ${0}
    Log to console    \nstability test begin
    FOR    ${itime}    IN RANGE    1    ${times}+1
           Log to console    \n---------------------\nstability run: ${itime}/${times}
           ${result} =    Run Keyword And Return Status    OAM_KPI_19_cell_reset    cell_index=${cell_index}
           log to console    result:${result}\n---------------------\n
           ${pass_times}    Run Keyword If    ${result}    evaluate    ${pass_times}+1    ELSE    set variable    ${pass_times}
           ${fail_in_loop}    evaluate    (${itime}-${pass_times})>(${times}-${pass})
           run keyword if    ${fail_in_loop}     Fail    Fail times excceed
    END
    ${rate}    evaluate    ${pass_times}/${times}*100
    ${check_type}    run keyword if    ${pass}>1     run keywords    log to console    pass/total: ${pass_times}/${times}
    ...    AND    should be true    ${pass_times}>=${pass}    AND    Return From Keyword    ${pass_times}
    ...    ELSE   run keywords   log to console   pass rate: ${rate}%    AND    should be true    ${rate}>=${pass}
    ...    AND    Return From Keyword    ${rate}%
OAM_KPI_19_cell_reset
    [Arguments]    ${cell_index}=${1}
    oam_kpi_calculations.clear_results
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
#    oam_kpi_calculations.save_search_start_timestamp
    log to console    start to reset cell
    selenium_coam.reset_cell    cell_idx=${cell_index}
    selenium logout and close browser
    sleep    10s
    wait until keyword succeeds    15min    10s    Check all cells Info Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/
    check no unexpected alarm
    oam_kpi_calculations.calculate_kpi19    ims_file_path=${ims_file}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${SAVE LOG DIRECTORY}/loop_ims2/results_${ims_file_date}.json
    ${kpi_result}    oam_kpi_calculations.get_results
    ${kpi19_value}=    oam_kpi_calculations.get_average_results    kpi_name=kpi19
    Should Be True    ${kpi19_value}<${KPI19_MAX}
    log to console    kpi19_value is ${kpi19_value}\n
SCF_activation_with_cell_locking_downtime_KPI#15_CNF_5G_25
    ${KPI15_MAX}    set variable    ${KPI['CB008457_KPI15a']['CNF_5G_25']['KPI15_MAX']}
    set test variable    ${KPI15_MAX}
    OAM_KPI_15_cell_locking_downtime_IMS    WebUI_reset_times=${KPI['CB008457_KPI15a']['WebUI_reset_times']}
    ...    cell_index=${1}
SCF_activation_with_cell_locking_downtime_KPI#15_CNF_5G_11
    ${ru_index_list}    get all ru index
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}
        ${ru_type}    set variable    ${ru_info}[productName]
        ${KPI15_MAX}=    Set Variable If    '${ru_type}' == 'AKQJ' or '${ru_type}' == 'AQNA' or '${ru_type}' == 'AQQJ'
        ...    ${KPI['CB008457_KPI15']['CNF_5G_11']['KPI15_MAX']}
        ...    ${KPI['CB008457_KPI15']['CNF_5G_11']['KPI15_master_MAX']}
        set test variable    ${KPI15_MAX}
        OAM_KPI_15_cell_locking_downtime_IMS    WebUI_reset_times=${KPI['CB008457_KPI15']['WebUI_reset_times']}
        ...    cell_index=${ru_index}
    END
KPI15_Test_Case_cycle
    [Arguments]    ${times}=${1}    ${pass}=${1}     ${cell_index}=1
    ${pass_times}   Set variable    ${0}
    Log to console    \nstability test begin
    FOR    ${itime}    IN RANGE    1    ${times}+1
            Log to console    \n---------------------\nstability run: ${itime}/${times}
            ${result} =    Run Keyword And Return Status    OAM_KPI_15_SCF_activation_with_cell_locking_downtime_IMS
            ...    cell_index=${cell_index}
            log to console    result:${result}\n---------------------\n
            ${pass_times}    Run Keyword If    ${result}    evaluate    ${pass_times}+1    ELSE    set variable    ${pass_times}
            ${fail_in_loop}    evaluate    (${itime}-${pass_times})>(${times}-${pass})
            run keyword if    ${fail_in_loop}     Fail    Fail times excceed
    END
    ${rate}    evaluate    ${pass_times}/${times}*100
    ${check_type}    run keyword if    ${pass}>1     run keywords    log to console    pass/total: ${pass_times}/${times}
    ...    AND    should be true    ${pass_times}>=${pass}    AND    Return From Keyword    ${pass_times}
    ...    ELSE   run keywords   log to console   pass rate: ${rate}%    AND    should be true    ${rate}>=${pass}
    ...    AND    Return From Keyword    ${rate}%
OAM_KPI_15_SCF_activation_with_cell_locking_downtime_IMS
    [Arguments]    ${cell_index}=1
    oam_kpi_calculations.clear_results
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
#    oam_kpi_calculations.save_search_start_timestamp
    log to console    start to modify locking paremeter
    modify_locking_paremeter    cell_index=${cell_index}
    selenium logout and close browser
    sleep    20s
    wait until keyword succeeds    15min    10s    Check all cells Info Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    Collect IMS File    log_dir=${SAVE LOG DIRECTORY}/loop_ims2/
    check no unexpected alarm    is_check_historyalarm=${True}
    oam_kpi_calculations.calculate_kpi15    ims_file_path=${ims_file}
    Run Keyword and Continue on Failure    oam_kpi_calculations.save_results_to_file
    ...    file_path=${SAVE LOG DIRECTORY}/loop_ims2/results_${ims_file_date}.json
    ${kpi_result}    oam_kpi_calculations.get_results
    ${kpi15_value}=    oam_kpi_calculations.get_average_results    kpi_name=kpi15
    Should Be True    ${kpi15_value}<${KPI15_MAX}
    log to console    kpi15_value is ${kpi15_value}\n

modify_reseting_paremeter
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    ${current_value}    selenium_sbts.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate disabling of NR remote interference management RS at gNB level
    ...    abbr=actDisableNrRimRsAtGnbLevel
    ${new_value}    Set Variable if    '${current_value}'=='true'    false    true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate disabling of NR remote interference management RS at gNB level
    ...    abbr=actDisableNrRimRsAtGnbLevel    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    selenium logout and close browser
modify_locking_paremeter
    [Arguments]    ${cell_index}=1
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    ${current_value}    selenium_sbts.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
    ...    filter_param=Activate FD resource allocation type1
    ...    abbr=actRat1Alloc
    ${new_value}     Set Variable if    '${current_value}'=='true'    false    true
    selenium_sbts.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
    ...    filter_param=Activate FD resource allocation type1
    ...    abbr=actRat1Alloc    new_value=${new_value}
    selenium_sbts.validate_plan
    selenium_sbts.activate_plan
    selenium logout and close browser
set RAT reset precondition
    [Arguments]    ${input_value}
    wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    ${current_value}    selenium_sbts.get_parameter_value    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate RAT reset enhancement
    ...    abbr=actRatResetEnhancement
    Run Keyword If    '${current_value}'!='${input_value}'    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate RAT reset enhancement
    ...    abbr=actRatResetEnhancement    new_value=${input_value}
    selenium_sbts.validate_plan
    selenium_sbts.activate_plan
    selenium logout and close browser
