*** Settings ***
Documentation    author:Liu Tiffany
...               contact: ning.4.liu@nokia-sbell.com
...               History: Do some adaption for CB006443 by LiuNing
...               feature : CB006443
#Resource          ../../../../RRM/5GC000496_C/Resources/L3Call.robot
Resource          ../../None_Feature_SG1/OAM_Interface.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
#Library           ReadJason.py
Library           OperatingSystem
Library           DateTime
Library           ute_wtssim
Library           ute_syslog
Library           ute_admin
#Library           urllib.request
Library           requests
Library           Collections
Library           Process
Library           String
Library           Telnet
#Library           SeleniumLibrary
Variables         ./TLDelta.py


*** Variables ***

${link_to_Artifact}       https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release/
${UPDATE_FILE_PATH}       /home/ute/Download_gNB_Package
${YAFT_PATH}              /opt/ute/YAFT

${PROGRAM}                  ${None}

${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}

${ASIK_LMP_IP_URL}          https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}                  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}



${PB_DU_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_DU_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${PB_DU_Vendor}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
#${PB_DU_Vendor}             HBTE
${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}


${MRBTS_ID}                 MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                 NRBTS-${tl.gnbs[0].global_bts_id}

${4G_WEBUI_IP}              ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${5G_WEBUI_IP}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${BTSMOD}                   5GOnly
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
########################END of alias Define#######################################
#CASE_INPUT_CB006443	=	{
#    'CB006443':{'LoopTimeout':'30','LoopTimeoutForSWUpdate':'90',},
#    'CB006443_IA_15':{'UpdateByYAFT':'true',},
#}
*** Keywords ***
#reset site via webUI
TC.CB006443_HA_03_OAM_KPI_61a_Software_Reset_Startup_Success_Rate
    KW.PassRateStatusFinal
TC.CB006443_HA_06_OAM_KPI_63_Power_Reset_Success_Rate
    KW.PassRateStatusFinal
TC.CB006443_HA_09_OAM_KPI_651_RU_Software_Reset_Startup_Success_Rate
     KW.PassRateStatusFinal
TC.CB006443_IA_18_OAM_KPI_64_SWM_SW_Upgrade_Success_Rate_Intra_Release
     KW.PassRateStatusFinal
TC.CB006443_HA_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
    [Arguments]   ${WebUI_reset_times}=${CASE_INPUT_CB006443['CB006443_HA_KPI1a']['WebUI_reset_times']}
    ...   ${KPI1a_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI1a']['KPI1a_MAX']}
    ...   ${KPI1a_AVG}=${CASE_INPUT_CB006443['CB006443_HA_KPI1a']['KPI1a_AVG']}
    ...    ${Check_Call}=${False}    ${call_loop}=${2}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}     ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300

	&{kpi_results}=    Create Dictionary    kpi1a=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_1a
    Set Test Variable  ${target_kpis}

    gnb resetViaWebUIWithRetry   case_name=site_reset    retry_times=${WebUI_reset_times}
    ...   KPI1a_MAX=${KPI1a_MAX}
    ...   KPI1a_AVG=${KPI1a_AVG}
    ...    Check_Call=${Check_Call}    call_loop=${call_loop}
    ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
    ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
    ...    exepected_ul_tp=${exepected_ul_tp}     exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}
    ...    duration_dl=${duration_dl}
	[Teardown]    Report KPI    kpi1a

# power reset
TC.CB006443_HA_04_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
    [Arguments]   ${Power_reset_times}=${CASE_INPUT_CB006443['CB006443_HA_KPI3']['Power_reset_times']}
    ...    ${KPI3_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI3']['KPI3_MAX']}
    ...    ${KPI3_AVG}=${CASE_INPUT_CB006443['CB006443_HA_KPI3']['KPI3_AVG']}
    ...    ${fail_loop_max}=${CASE_INPUT_CB006443['CB006443_HA_KPI3']['fail_loop_max']}
    ...    ${Check_Call}=${False}    ${call_loop}=${2}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}     ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300

	&{kpi_results}=    Create Dictionary    kpi3=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_3
    Set Test Variable  ${target_kpis}

    gnb PowerResetWithRetry   case_name=power_reset       retry_times=${Power_reset_times}
    ...    KPI3_MAX=${KPI3_MAX}   KPI3_AVG=${KPI3_AVG}      fail_loop_max=${fail_loop_max}
    ...    Check_Call=${Check_Call}    call_loop=${call_loop}
    ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
    ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
    ...    exepected_ul_tp=${exepected_ul_tp}     exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}
    ...    duration_dl=${duration_dl}
	[Teardown]    Report KPI    kpi3

#SWM,SW update
TC.CB006443_IA_15_OAM_KPI_4_SWM_SW_Upgrade_Time_Intra_Release_Single_Core
    [Arguments]     ${SW_update_times}=${CASE_INPUT_CB006443['CB006443_IA_KPI4']['SW_update_times']}
    ...    ${Update_By_YAFT}=${CASE_INPUT_CB006443['CB006443_IA_15']['UpdateByYAFT']}
    ...    ${KPI4_MAX}=${CASE_INPUT_CB006443['CB006443_IA_KPI4']['KPI4_MAX']}
    ...    ${KPI4_AVG}=${CASE_INPUT_CB006443['CB006443_IA_KPI4']['KPI4_AVG']}
    ...    ${SCF}=None
    run    command=rm -rf ${UPDATE_FILE_PATH}
    sleep   10s
    run    command=mkdir ${UPDATE_FILE_PATH}
    ${version_Target}    ${version_Original}    Get gNB SW version
    log to console    original=${version_Original}
    log to console    target=${version_Target}
    log to console    AFtarget=${TargetBTSVersion}
    log to console    ${Update_By_YAFT}
    ${Intermediate_upgrade_package_path}    run keyword if    '${Update_By_YAFT}'=='true'
    ...            KW.PreparePackageByYAFT
    ...    ELSE    KW.PreparePackage
    ${Target_package_path}        SoftwareUpdate.Download_gNB_Package    build_version=${TargetBTSVersion}
    log to console    package prepared
    set suite variable    ${CaseState}      package_prepared
    SWUpdateWithRetry    case_name=swm    Intermediate_upgrade_package_path=${Intermediate_upgrade_package_path}
    ...    Target_package_path=${Target_package_path}     retry_times=${SW_update_times}
    ...    KPI4_MAX=${KPI4_MAX}    KPI4_AVG=${KPI4_AVG}    SCF=${SCF}

KW.CheckRUAlarmOrOnair
    [Documentation]    History:1. delete check cell onair due to this KW is for YAFT
    #${res}     run keyword and ignore error     Check BTS Onair
    #return from keyword if   '${res[0]}'=='PASS'    NO
    wait until keyword succeeds    10min    30s    COAM_WebEM.Login
    ${ret}=    selenium_coam.get_active_alarm_info    alarm_filter=BASE STATION SOFTWARE MANAGEMENT PROBLEM
    Log   ${ret}
    Should Not Be Empty   ${ret}
    [Return]      YES
    [TearDown]    run keyword and ignore error    COAM_WebEM.Logout


KW.PreparePackage
    ${version_Target}    ${version_Original}    Get gNB SW version
    ${version_Original}    Basic.AdjustBTSVersion    sw_version=${version_Original}    stream=${TargetBTSStream}
    ${Intermediate_gnb_package}   Select PreReleased gnb package    version_target=${version_Target}
    log to console     Intermediate_gnb_package is:${Intermediate_gnb_package}
    Run Keyword If    '${Intermediate_gnb_package}'=='${version_Original}'    Fail
    ${Intermediate_upgrade_package_path}       SoftwareUpdate.Download_gNB_Package    build_version=${Intermediate_gnb_package}
    [Return]       ${Intermediate_upgrade_package_path}

KW.PreparePackageByYAFT
    ${version_Target}    ${version_Original}    Get gNB SW version
    ${version_Original}    Basic.AdjustBTSVersion    sw_version=${version_Original}    stream=${TargetStream}
    log to console     version_Original is:${version_Original}
    ${Intermediate_upgrade_package_path}       SoftwareUpdate.Download_gNB_Package    build_version=${version_Original}
    Set Suite Variable    ${OriginalVersion}    ${version_Original}
    [Return]       ${Intermediate_upgrade_package_path}

KW.RollbackAndBackupSCFFile
    return from keyword if     '${SCFPrepared}'=='prepared'
    rollback site
    ${SCFFile}    Backup SCF from SBTS by admin
    set suite variable    ${SCFFile}    ${SCFFile}
    set suite variable    ${SCFPrepared}    ${prepared}

KW.PrepareENVbyYAFT
    [Arguments]    ${filename}     ${SCF}=None
    ${Smods}    COAM_Admin.GetBTSTopology
    ${length}=   Get Length   ${Smods}
#    run keyword if    ${filename.count('${TargetBTSVersion}')}>0    Set Suite Variable    ${gSCF}    None
#    ...    ELSE       Set Suite Variable    ${gSCF}    ${OriginalStreamSCF}
    #run keyword if  '${length}'=='1'      KW.SWM.PrepareEnvByYAFT    filename=${filename}    scf=None
    #...    ELSE    KW.PrepareENVDualCore    filename=${filename}
    run keyword if  '${length}'=='1'      KW.SWM.PrepareEnvByYAFT    filename=${filename}    scf=${SCF}
    ...    ELSE    KW.PrepareENVDualCore    filename=${filename}

#This KW is not used in CB006443 and CB008181
KW.PrepareENVDualCore
    [Arguments]    ${filename}
    ${SecondaryUTEVMIP}       set variable    ${CASE_INPUT_CB006443['CB006443_IA']['SecondaryUTEVMIP']}
    ssh.Connect to    hostname=${SecondaryUTEVMIP}    username=ute     password=ute     alias=SecondaryUTEVMIP
    ${cmd}=  Catenate     SEPARATOR=${SPACE}
    ...                   source ~/CIENV/${CASE_INPUT_CB006443['CB006443_IA']['SecondaryTLName']}/bin/activate &&
    ...                   robot -t TC.PrepareENVOnSecondary -L TRACE -b debug.log -d /home/ute/TAF/debug_log/123456/
    ...                  -l "123456".html -v ip:${SecondaryDefaultIP} -v version:${OriginalVersion}
    ...                  /home/ute/TAF/robotws5g/testsuite/OAM/Hangzhou/None_Feature_SG1/common_case.robot
    ...                  && deactivate
    ${out}    Conn.Execute    cmd=${cmd}    alias=SecondaryUTEVMIP
    should contain    ${out}    1 test total, 1 passed, 0 failed
    should contain    ${out}    PrepareENVOnSecondary Success
    Conn.Disconnect     alias=SecondaryUTEVMIP
#    run keyword if    ${filename.count('${TargetBTSVersion}')}>0    Set Suite Variable    ${gSCF}    ${CurrentStreamSCF}
#    ...    ELSE       Set Suite Variable    ${gSCF}    ${OriginalStreamSCF}
    KW.SWM.PrepareEnvByYAFT    filename=${filename}    scf=${CurrentStreamSCF}

KW.SWM.PrepareEnvByYAFT
    [Arguments]    ${filename}    ${scf}=None
    log to console    YAFT Started
    ${ASIK_IP_BAK}    Set Variable        ${ASIK_IP}
    ${WEBUI_IP_BAK}   Set Variable        ${WEBUI_IP}
    ${WEBUI_URL_BAK}   Set Variable       ${WEBUI_URL}
    Set Suite Variable    ${ASIK_IP}      ${5G_WEBUI_IP}
    Set Suite Variable    ${WEBUI_IP}     ${5G_WEBUI_IP}
    Set Suite Variable    ${WEBUI_URL}    ${ASIK_LMP_IP_URL}

    KW.TryEnableSSH
    wait until keyword succeeds    3x    60s    SoftwareUpdate.YAFT    filepath=${filename}
    ${version_Target}    ${version_Original}    wait until keyword succeeds    30min    60s    Get gNB SW version
    log to console     active=${version_Target}
    log to console     passive=${version_Original}
    log to console    Second YAFT
    KW.TryEnableSSH
    wait until keyword succeeds    3x    60s    SoftwareUpdate.YAFT    filepath=${filename}
    ${version_Target}    ${version_Original}    wait until keyword succeeds    30min    60s    Get gNB SW version
    log to console     active=${version_Target}
    log to console     passive=${version_Original}
    log to console    Second YAFT END and wait onair
    #KW.TryEnableSSH
    run keyword if    '${scf}'!='None'    wait until keyword succeeds    30min    60s   gNB.Commission   scf_file=${scf}
    FOR    ${i}    IN RANGE    ${20}
        ${res}    wait until keyword succeeds    20min    60s    KW.CheckRUAlarmOrOnair
        run keyword if     '${res}'=='YES'        KW.UpGradeForRU    filename=${filename}
        ...    ELSE    Exit For Loop
    END
    Set Suite Variable    ${ASIK_IP}      ${ASIK_IP_BAK}
    Set Suite Variable    ${WEBUI_IP}     ${WEBUI_IP_BAK}
    Set Suite Variable    ${WEBUI_URL}    ${WEBUI_URL_BAK}

KW.UpGradeForRU
    [Arguments]    ${filename}
    FOR    ${i}    IN RANGE    ${5}
        wait until keyword succeeds    10min    60s    COAM_WebEM.Login    url=${ASIK_LMP_IP_URL}
        ${finish}    Download and update package of site
        ...    if_active=${True}     upgrade_package_path=${filename}    checkReset=false
        run keyword and ignore error  COAM_WebEM.Logout
        exit for loop if    '${finish}'=='true'
        Sleep    60
    END

KW.PrepareEnvByRollback
    [Arguments]    ${filename}    ${connection}=COAM
    Check all cells Should Be On Air     connection=${connection}    login_flag=${True}
    ...    wait_time=8min    reset_flag=${False}
    rollback site
    Check all cells Should Be On Air     connection=${connection}    login_flag=${True}
    ...    wait_time=8min    reset_flag=${False}
    wait until keyword succeeds    10min    60s    COAM_WebEM.Login
    Download and update package of site      if_active=${True}     upgrade_package_path=${filename}
    Check all cells Should Be On Air     connection=${connection}    login_flag=${True}
    ...    wait_time=8min    reset_flag=${False}
    rollback site
    Check all cells Should Be On Air     connection=${connection}    login_flag=${True}
    ...    wait_time=8min    reset_flag=${False}

KW.TryEnableSSH
    ${value}    Run Keyword And Ignore error    ssh.Connect to    hostname=${ASIK_IP}    username=${ASIK_USERNAME}
    ...    password=${ASIK_PASSWORD}     alias=${ALIAS_ASIK}
    Run Keyword And Ignore error    Conn.Disconnect    alias=ALIAS_ASIK
    Return From Keyword if    '${value[0]}'=='PASS'
    wait until keyword succeeds    15min    30s    COAM_WebEM.Login    url=${ASIK_LMP_IP_URL}
    COAM.EnableSSH
    COAM_WebEM.Logout

KW.LoopForSWUpdate
    [Arguments]    ${Intermediate_upgrade_package_path}    ${Target_package_path}
     ...    ${Update_By_YAFT}=${CASE_INPUT_CB006443['CB006443_IA_15']['UpdateByYAFT']}
     ...    ${connection}=COAM
     ...    ${SCF}=None
    #[Timeout]    ${CASE_INPUT_CB006443['CB006443']['LoopTimeoutForSWUpdate']} minutes
    run keyword if     '${StopCase}'=='true'    Fail    loop stoped for Software update
    ${version_Active}    GetgNBActiveSWVersion
    ${version_Passive}    GetPassivegNBSWVersion
    Exit For Loop If    '${version_Active}'=='Null' or '${version_Passive}'=='null'
    #####    rollback from Intermediate to original
    run keyword if    '${Update_By_YAFT}'=='true'
     ...            KW.PrepareEnvByYAFT    filename=${Intermediate_upgrade_package_path}     SCF=${SCF}
     ...    ELSE    KW.PrepareEnvByRollback   filename=${Intermediate_upgrade_package_path}
    ###############    update gnb package from original to target#####################
    log to console    case started
    wait until keyword succeeds    8min    2s    COAM_WebEM.Login       url=${ASIK_LMP_IP_URL}
    ${timestartTmp}   Get Current Date
    ${timestart}      convert date    ${timestartTmp}    epoch
    Download and update package of site      if_active=${True}     upgrade_package_path=${Target_package_path}
    ${reset_status_Tmp}     Run Keyword And Return Status      Check all cells Should Be On Air
    ...    connection=${connection}    login_flag=${True}
    ...    wait_time=8min    reset_flag=${False}
    ${timeendTmp}     Get Current Date
    ${timeend}        convert date    ${timeendTmp}     epoch
    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    ${reset_status}	   Set Variable If	  "${reset_status_Tmp}"=="True" and ${duration_time_tmp}<3600   pass      fail
    log to console    case  end
    run keyword and ignore error  COAM_WebEM.Logout
    [Return]    ${reset_status}   ${duration_time_tmp}

KW.LoopForResetViaWEBUI
    [Arguments]    ${loop}=0
    ...    ${KPI1a_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI1a']['KPI1a_MAX']}
    oam_kpi_calculations.clear_results
    ${connection_AdminApi}    wait until keyword succeeds   5x   1min    Connect to DU by ADMIN API
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${referrence_time}      convert date    ${timestamp_log}    epoch
    Run Keyword and Continue on Failure    taf.sbts.oam.coam.admin.reset    timeout=1800    connection=${connection_AdminApi}
    ${reset_status_Tmp}          Run Keyword And Return Status     Check all cells Should Be On Air
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms    loop=${loop}
    ...    referrence_time=${referrence_time}
    Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${loop}_ims2/
    #sleep    60s
    #run    ls -al /home/ute/y6lu/LOGs/Logs/loop1_ims2/
    ${status}  Run Keyword And Continue On Failure    Analyse IMS File   kpi_list=${kpi_list}    loop=${loop}
    ${status}  Evaluate  ${status} or ${alarm_status} or ${history_alarm_status}
	#or ${ACTIVATE_SNAPSHOT}
    ${duration_time_tmp}    Set Variable   ${kpi_avg}
    ${reset_status}	   Set Variable If
    ...   "${reset_status_Tmp}"=="True" and ${duration_time_tmp}<${KPI1a_MAX} and "${status}"=="False"	    pass      fail
    ${snapshot_file}    Run Keyword If    '${reset_status}'=='fail'
        ...    Run keywords   sleep    60s
        ...    AND     Run Keyword And Ignore error     wait until keyword succeeds    30x    2min    WEBUI.Collect snapshot
        ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${loop}
        Run Keyword If    '${reset_status}'=='pass'     Run Keyword And Ignore Error
        ...    Run keywords    Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
        ...    AND    Run    sudo rm -rf ${LOG_PATH}/loop${loop}_ims2/
        Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
        Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
        Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    log to console       This reset site loop${loop} is ${reset_status} and KPI is ${duration_time_tmp}
    run keyword and ignore error     DisConnect to DU by ADMIN API
    ims_keywords.instance_disconnect  gnbbbu
    [Return]    ${reset_status}   ${duration_time_tmp}

KW.LoopForPowerReset
    [Arguments]     ${cell_id_list}    ${PowerOnOffRmod}=False     ${loop}=${0}
    ...    ${KPI3_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI3']['KPI3_MAX']}
    oam_kpi_calculations.clear_results
    ims_keywords.check_instance_connection    gnbbbu
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${referrence_time}      convert date    ${timestamp_log}    epoch
	${kpi_params}    ims_keywords.get_start_point_timestamp    kpi_names=${kpi_list}
    Run Keyword If   '${PowerOnOffRmod}'=='TRUE'    KW.PowerOff5GRUs
    PB.PowerOnOff     pdu_ip=${PB_DU_IP}    Port_Number=${PB_DU_PORT}    Action=both    model=${PB_DU_Vendor}
    #${timestartTmp}   Get Current Date
    Run Keyword If   '${PowerOnOffRmod}'=='TRUE'    KW.PowerOn5GRUs
    log to console    check all cell status start
    ${login_status}     Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    20min    3s     Connect to DU by ADMIN API
    ${cell_status}     Run Keyword And Return Status    Run Keyword and Continue on Failure
     ...    Wait Until Keyword Succeeds    20min    1s     DU_WebEM.Check all NR Cell status
     ...    cell_id_list=${cell_id_list}    all_flag=True
     ...    operational_State=Enabled    procedural_Status=configured
     ...    blockingState=Unblocked    administrative_State=Unlocked

    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}_${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure
    ...    Collect new history Alarms    loop=${loop}_${timestamp_log}    ALLOWED_ALARMS=${ALLOWED_ALARMS_KPI3}
    ...    referrence_time=${referrence_time}
    #${timestart}      convert date    ${timestartTmp}    epoch
    #${timeendTmp}     Get Current Date
    #${timeend}        convert date    ${timeendTmp}     epoch

    Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${loop}_${timestamp_log}_ims2/
	${status}  Run Keyword And Continue On Failure     Analyse IMS File
	...    kpi_list=${kpi_list}    loop=${loop}_${timestamp_log}    kpi_params=${kpi_params}
    ${status}  Evaluate  ${status} or ${alarm_status} or ${history_alarm_status}
    ${duration_time_tmp}    Set Variable    ${kpi_avg}
    ${reset_status}	   Set Variable If
    ...    "${cell_status}"=="True" and "${status}"=="False" and ${10}<${duration_time_tmp}<${KPI3_MAX}
    ...    pass      fail
    RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${reset_status}    pass    ignore_case=true
    ${snapshot_file}    Run Keyword If    '${reset_status}'=='fail'
    ...    Run keywords   sleep    60s
    ...    AND    Run Keyword And Ignore error     wait until keyword succeeds    30x    2min    WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${loop}
    Run Keyword If    '${reset_status}'=='pass'     Run Keyword And Ignore Error
    ...    Run keywords      Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    ...    AND    Run    sudo rm -rf ${LOG_PATH}/loop${loop}_${timestamp_log}_ims2/
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    run keyword and ignore error    COAM_Admin.Logout
    ims_keywords.instance_disconnect  gnbbbu
    [Return]    ${reset_status}   ${duration_time_tmp}
    [Teardown]    Run Keywords    Run Keyword If   '${PowerOnOffRmod}'=='TRUE'
    ...    run keyword and ignore error    KW.PowerOn5GRUs
    ...   AND     run keyword and ignore error   DisConnect to DU by ADMIN API

KW.Suite setup for 2479
    [Documentation]
    [Arguments]
    TestSuite.Start
    Create Log Directories
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    run keyword and ignore error    Import Variables         /home/ute/TAF/cfgfile/6443_Loop_times.py
    set suite variable    ${GoldenSCF_PATH}         ${GoldenSCF_ON_GIT}/${GoldenSCF}
    set suite variable    ${SCFPrepared}    notstart
    set suite variable    ${StopCase}       false
    set suite variable    ${CaseState}      notstart
    ${stream}    ${version_Target}    Basic.GetStreamAndVersion
    #${version_Target}          get regexp matches    ${AF_PATH}     [0-9]+.[0-9]+.[0-9]+
    set suite variable    ${TargetBTSVersion}    ${version_Target}
    set suite variable    ${TargetBTSStream}     ${stream}
    Basic.CheckVariableValid    var=CASE_INPUT_CB006443['CB006443']['LoopTimeout']    default_value=30
    Basic.CheckVariableValid    var=CASE_INPUT_CB006443['CB006443']['LoopTimeoutForSWUpdate']    default_value=90
    Basic.CheckVariableValid    var=CASE_INPUT_CB006443['CB006443_IA_15']['UpdateByYAFT']    default_value=false
    Basic.CheckVariableValid    var=CASE_INPUT_CB006443['CB006443_HA_08_KPI51']['ru_index']    default_value=1
    Basic.CheckVariableValid    var=CASE_INPUT_CB006443['CB006443_HA_KPI3']['KPI3_AVG']    default_value=450    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_CB006443['CB006443_HA_KPI3']['KPI3_MAX']    default_value=540    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_CB006443['CB006443_HA_KPI1a']['KPI1a_AVG']    default_value=450    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_CB006443['CB006443_HA_KPI1a']['KPI1a_MAX']    default_value=540    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_CB006443['CB006443_HA_KPI51']['KPI51_AVG']    default_value=360    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_CB006443['CB006443_HA_KPI51']['KPI51_MAX']    default_value=432    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_CB006443['CB006443_IA_KPI4']['KPI4_AVG']    default_value=1320    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_CB006443['CB006443_IA_KPI4']['KPI4_MAX']    default_value=1584    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_CB006443['CB006443_HA_KPI51']['KPI51_AVG_ADJ']   default_value=0    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_CB006443['CB006443_HA_KPI1a']['WebUI_reset_times']
    ...                         default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_CB006443['CB006443_HA_KPI3']['Power_reset_times']
    ...                         default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_CB006443['CB006443_HA_KPI51']['RF_reset_times']
    ...                         default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_CB006443['CB006443_HA_KPI4']['SW_update_times']
    ...                         default_value=3    is_digit=True
    KW.CaseStatusInit    retry_times=${100}
    ${CurrentStreamSCF}   Backup SCF from SBTS by admin

    #Basic.CheckVariableValid    var=CASE_INPUT_CB006443['CB006443_IA']['OriginalStreamSCF']    default_value=None
    Set Suite Variable    ${CurrentStreamSCF}     ${CurrentStreamSCF}

    #Set Suite Variable    ${OriginalStreamSCF}    None

    ${res}    run keyword and ignore error    log to console    ${cell_number}
    ${scffile}    run keyword if    '${res[0]}'!='FAIL'    gNB.Generate TL SCF
    ...    GoldenSCF_PATH=${GoldenSCF_PATH}    TLDelta_PATH=${CFGFILE_PATH}    TestLineSCF_cell_num=${cell_number}
    ...    cell_type=${cell_type}    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    run keyword if    '${res[0]}'!='FAIL'    run keyword and ignore error    gNB.Commission
    ...    scf_file=${scffile}    timeout=${1800}
     run keyword if    '${res[0]}'!='FAIL'    Check all cells Should Be On Air and caputre snapshot if not on air
     Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog_setup
     wait until keyword succeeds    1min    1s    Check BTS Onair

KW.Teardown Suite
    TestSuite.Stop

KW.CaseStatusInit
    [Arguments]           ${retry_times}=3
    Set Suite Variable    ${CasePassRateStatus}     NotExecute
    Set Suite Variable    ${CaseAVGLoop}     ${0}
    Set Suite Variable    ${CaseMaxTime}     ${retry_times}
    Set Suite Variable    ${CaseSUM}         ${0}

KW.CaseStatusCaluate
    [Arguments]       ${duration}=${0}    ${max}=${0}
    ${CaseSUM}        run keyword if    ${duration}<=${max}    Evaluate    ${CaseSUM}+${duration}
    ...    ELSE    Set Variable    ${CaseSUM}
    ${CaseAVGLoop}    run keyword if    ${duration}<=${max}    Evaluate    ${CaseAVGLoop}+${1}
     ...    ELSE    Set Variable    ${CaseAVGLoop}
    Set Suite Variable    ${CaseSUM}     ${CaseSUM}
    Set Suite Variable    ${CaseAVGLoop}         ${CaseAVGLoop}
    run keyword if    '${CasePassRateStatus}'=='NotExecute'    Set Suite Variable    ${CasePassRateStatus}    PASS
    run keyword if    ${duration}>${max}    Set Suite Variable    ${CasePassRateStatus}    FAIL

KW.CaseStatusFinnal
   [Arguments]       ${case_avg}=${600}     ${max_loop}=${2}
    log to console      parameter case_avg: "${case_avg}" and max_loop:"${max_loop}" is not used and can be ignored
    ${avg}    run keyword if     ${CaseAVGLoop}>0   Evaluate    ${CaseSUM}/${CaseAVGLoop}
    ...    ELSE    Fail    0 loop pass
    #should be true    ${avg}<=${case_avg}

KW.PassRateStatusFinal
    run keyword if    '${CasePassRateStatus}'!='PASS'    Fail    case ${CaseAVGLoop} loop pass in ${CaseMaxTime} loop

Test_COAM_WebEM.Login
    [Documentation]   parameter should be ${True} or ${False}
#    run keyword if     ${virtual_enable}     selenium_coam.enable_virtual_display
    run keyword and ignore error    selenium_coam.logout
    selenium_coam.login    ${WEBUI_URL}    ${WEBUI_USERNAME}    ${WEBUI_PASSWORD}
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock
    sleep    15s
    ${res}    selenium_coam.start_up_view_window_exists
    run keyword if    '${res}'=='True'        selenium_coam.close_start_up_view_window

check SW download progress finished
    ${result}    selenium_coam.check_software_update_progress
    log to console   ${result}
#    should be equal    &{result}[status]    Download completed
    ${res}    Basic.CheckContainString    substring=Activating software...    string=${result}[status]
    return from keyword if    '${res}'=='true'    true
    ${res}    Basic.CheckContainString    substring=Site resetting...      string=${result}[status]
    return from keyword if    '${res}'=='true'    true
    ${res}    Basic.CheckContainString    substring=Activation completed      string=${result}[status]
    return from keyword if    '${res}'=='true'    true
    ${res}    Basic.CheckContainString    substring=Activation completed, require unit reset    string=${result}[status]
    return from keyword if    '${res}'=='true'    true
    ${res}    Basic.CheckContainString    substring=Download failed    string=${result}[status]
    return from keyword if    '${res}'=='true'    false
    Fail    need more check
#    ${RU_Reset}    set variable if     '&{result}[status]'=='Activation completed, require unit reset'    true    false
#    [Return]    ${RU_Reset}
#    should be equal    &{result}[percentage]    100%

check_software_update_progress
    [Documentation]    this KW is to check the reset status when the upgrade package is same as active version
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${result}    selenium_coam.check_software_update_progress
    should be equal    ${result}[status]     Activation completed
    #should be equal    ${result}[percentage]     100% completed

Download and update package of site
    [Documentation]    the input value should be False or Ture
    [Arguments]    ${if_active}    ${upgrade_package_path}    ${checkReset}=true
    log to console    upgrade package to ${upgrade_package_path}
    ${result}    selenium_coam.load_software_package_from_local_drive    ${upgrade_package_path}
    should be equal      ${result}    software package load success
    selenium_coam.software_update     is_activate=${if_active}
    ${finish}    wait until keyword succeeds    50min    10s    check SW download progress finished
#    Run Keyword And Ignore Error    COAM_WebEM.Logout
    run keyword if    '${checkReset}'=='true'    Wait until keyword succeeds    20min    10s    CB006443_Resouce.gNB.CheckgNBReset
    ...    ELSE IF     '${finish}'=='true'    Sleep    60
#    wait until keyword succeeds    10min    10s    check_software_update_progress
    [Return]    ${finish}

rollback site
    ${active_version_before}   ${passive_version_before}     Get gNB SW version
    log to console     active before:${active_version_before}
    log to console     passive before:${passive_version_before}
    log to console     rollback site on webUI
    wait until keyword succeeds    10min    60s    COAM_WebEM.Login
    selenium_coam.software_rollback
#    Run Keyword And Ignore Error    COAM_WebEM.Logout
    Wait until keyword succeeds    20min    20s    CB006443_Resouce.gNB.CheckgNBReset
    sleep  10s
#    selenium_coam.disable_screen_lock
#    wait until keyword succeeds    18min    10s    check site reset actually finished
#    Run Keyword And Ignore Error    wait until keyword succeeds    2min    15s     COAM_WebEM.Logout
    #Run Keyword And Ignore Error    run process    taskkill /f /im firefoxdriver.exe    shell=True
    #Run Keyword And Ignore Error    run process    ps -ef|grep firefox | awk '{print $2}' |xargs kill -9    shell=True
#    Run Keyword And Ignore Error    wait until keyword succeeds    30min    5s    COAM_WebEM.Login

    ${active_version_after}   ${passive_version_after}   Get gNB SW version
    log to console     active after:${active_version_after}
    log to console     passive after:${passive_version_after}
    should be equal   ${passive_version_before}    ${active_version_after}


Check ASIK is UP
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    run keyword and ignore error    selenium_coam.logout
    sleep  2s
    selenium_coam.login    ${WEBUI_URL}    ${WEBUI_USERNAME}    ${WEBUI_PASSWORD}
    ${output}    selenium_coam.get_hw_parameters    hw_type=SMOD    index=1
    ${output_tmp}    set variable    ${output}[Runtime parameters]
    ${P_name_smod}    set variable    ${output_tmp}[Product name]
    run keyword if    '${P_name_smod}' == 'ASIK AirScale Common'    Check ASIK State
    run keyword if    '${P_name_smod}' == 'ASIB AirScale Common'    Check ASIB State

Check ABIL is UP
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    run keyword and ignore error    selenium_coam.logout
    sleep  2s
    selenium_coam.login    ${WEBUI_URL}    ${WEBUI_USERNAME}    ${WEBUI_PASSWORD}
    ${output_tmp}    selenium_coam.get_abil_info
    ${output}    set variable    ${output_tmp}[Status]
    should be equal      ${output}[Administrative state]    Unlocked
    #should be equal      &{output}[Availability status]     Online
    should be equal      ${output}[Procedural status]     configured

check site reset actually finished
    [Documentation]    this KW is to check the reset status when site will reset actually
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${result}    selenium_coam.check_software_update_progress
    should be empty    ${result}[status]
    should be equal    ${result}[percentage]     0% completed

SoftwareUpdate.Download_gNB_Package
    [Arguments]    ${build_version}
    ${filename}   SoftwareUpdate.DownloadPackageFromWFT    build_version=${build_version}
    ${result}    run keyword if    '${filename}'=='False'
    ...    SoftwareUpdate.DownloadPackageFromWFT    build_version=${build_version}    wftlink=true
    ${finalfilename}   Set Variable if    '${filename}'=='False'   ${result}   ${filename}
    [Return]    ${finalfilename}

Select PreReleased gnb package
       ${key}    ${key1}    Basic.GetStreamAndVersion
       ${release}           set variable if    ${TargetBTSStream.count('SBTS')}>${0}      ${TargetBTSStream}       ${prefix_of_release}${key}
       ${target_version}    set variable if    ${TargetBTSStream.count('SBTS')}>${0}      ${TargetBTSVersion}      ${prefix_of_release}${key1}
       ${tprefix_of_release}    set variable if    ${TargetBTSStream.count('SBTS')}>${0}      ""      ${prefix_of_release}
       ${Intermediate_gnb_package}=  get_buildid_form_wft    release=${release}     target_version=${target_version}
       ...        prefix_of_release=${tprefix_of_release}
       log   ${Intermediate_gnb_package}
       [Return]     ${Intermediate_gnb_package}

Get The Version link For Download
    [Documentation]     get the dwonload package link like planned/active/passive version
    [Arguments]    ${version_type}
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${result}     string.split string    string=${version}[${version_type}]    separator=_
    ${result1}    convert to integer    ${result}[-1]
    ${result2}    convert to integer    ${result}[-2]
    ${result3}    convert to integer    ${result}[-3]
    ${result4}     convert to string    ${result}[-5]
    ${SW_vesion}    set variable      ${result3}.${result2}.${result1}
    #${package_full_link}    set variable    ${package_link}/${SW_vesion}/AirScale-${SW_vesion}.zip
    ${package_full_link}=   Run Keyword If   "${result4}"=="5G20A"
    ...   Set Variable    ${package_link}/${SW_vesion}/AirScale-${SW_vesion}.zip
    ...   ELSE IF    "${result4}"=="5G20B"
    ...   Set Variable    ${package_link}/${SW_vesion}/AirScale-${SW_vesion}.zip
    ...   ELSE     Set Variable     ${package_link}/${SW_vesion}/AirScale-${SW_vesion}.zip
    [Return]      ${package_full_link}

WEBUI.ResetRU
      [Documentation]   Reset ru on webui.
      [Arguments]      ${ru_index}=1
      selenium_coam.reset_ru_from_site_view       ru_index=${ru_index}

COAM_web_Get_Cell_Number
    [Documentation]   This kw is to get the number of cells.
    [Arguments]
    wait until keyword succeeds    10min    60s    COAM_WebEM.Login
    ${CellNum}    selenium_coam.get_number_of_cells
    COAM_WebEM.Logout
    [Return]      ${CellNum}

#   http://toolscenter.eecloud.dynamic.nsn-net.net/api/oamkpi/input/?version=0.800.2568&testline=7_5_UTE5GT1105&casename=site_reset
#   &case_result=pass&loop_number=1&duration_time=290&enb_verson=SBTS20C_ENB_0000_000595_000000&module=single_core/dual_core
Get common info
    [Arguments]    ${testline}=${testline_name}    ${case_name}=case_tmp       ${case_result}=pass  ${loop_number}=0  ${duration_time}=0
    ...    ${enb_version}=NA    ${URL}=http://toolscenter.eecloud.dynamic.nsn-net.net/api/oamkpi/input/?version=
    ${enb_version}    run keyword if   '${BTSMOD}'=='ConCorrent'    COAM_Admin.GetActiveSoftwareVersion    bts_host=${4G_WEBUI_IP}
    ...    ELSE    set variable    NA
    ${duration_time_int}     Evaluate      int(${duration_time})
    #${version}    GetgNBActiveSWVersion
    ${version}       set variable     ${TargetBTSVersion}
    ${URL_tmp1}      set variable     ${URL}${version}&testline=${testline}&casename=${case_name}&case_result=${case_result}
    #${res}     urllib.request.urlopen
    ${res}     requests.get
    #version=0.800.1356&testline=7_5_UTE5G402TXXX&casename=site_reset&case_result:pass&loop_number=1&duration_time=hh:mm:ss
    ...   url=${URL_tmp1}&loop_number=${loop_number}&duration_time=${duration_time_int}&enb_version=${enb_version}&module=single_core
    #log to console       ${res.read()}
#    [Arguments]    ${key}=Passive
#    COAM_WebEM.Login
#    selenium_coam.check_current_software_version     key=${key}
#    COAM_WebEM.Logout

Get gNB SW version
    ${active_sw_version}     GetgNBActiveSWVersion
    ${passive_sw_version}    GetPassivegNBSWVersion
    [Return]   ${active_sw_version}     ${passive_sw_version}

GetgNBActiveSWVersion
    [Arguments]   ${connection}=COAM
    wait until keyword succeeds   10x   1min    COAM_Admin.Login
    ${sw_info}   coam.get_software_info   connection=${connection}   timeout=10
    #${active_5g_rat_version}   Set Variable   ${sw_info['Active 5G RAT version']}
    ${active_sw_version}   Run Keyword If   "${sw_info['Active SW version']}"!="${None}" and "${sw_info['Active SW version']}"!=""
    ...   COAM_Admin.TransferSWVersion   ${sw_info['Active SW version']}
    log to console       get gNB SW version completed
    COAM_Admin.Logout
    [Return]   ${active_sw_version}

GetPassivegNBSWVersion
    [Arguments]   ${connection}=COAM
    wait until keyword succeeds   10x   1min    COAM_Admin.Login
    ${sw_info}   coam.get_software_info   connection=${connection}   timeout=10
    #${active_5g_rat_version}   Set Variable   ${sw_info['Active 5G RAT version']}
    ${passive_sw_version}   Run Keyword If   "${sw_info['Passive SW version']}"!="${None}" and "${sw_info['Passive SW version']}"!=""
    ...   COAM_Admin.Transfer SW Version   ${sw_info['Passive SW version']}
    log to console       get gNB Passive SW version completed
    COAM_Admin.Logout
    [Return]    ${passive_sw_version}

gnb resetViaWebUIWithRetry
    [Arguments]      ${case_name}  ${retry_times}=3   ${KPI1a_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI1a']['KPI1a_MAX']}
    ...   ${KPI1a_AVG}=${CASE_INPUT_CB006443['CB006443_HA_KPI1a']['KPI1a_AVG']}
    ...    ${Check_Call}=${False}    ${call_loop}=${2}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}     ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300
    KW.CaseStatusInit    retry_times=${retry_times}
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${retry_times}
        ims_keywords.check_instance_connection    gnbbbu
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        ${res}    run keyword and ignore error    KW.LoopForResetViaWEBUI    loop=${i+1}
        ...     KPI1a_MAX=${KPI1a_MAX}
        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${KPI1a_MAX}
        log to console     Case loop ${i+1} END
        Run Keyword And Ignore error     Get common info     case_result=${reset_status}
        ...    case_name=${case_name}   loop_number=${i+1}  duration_time=${duration_time_tmp}
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${reset_status}    pass

        ${remainder}    Evaluate    (${i}+1)%${call_loop}
        Run Keyword If    '${reset_status}'=='pass' and '${Check_Call}'=='${True}' and '${remainder}'=='${0}'
        ...    RUN KEYWORD AND CONTINUE ON FAILURE    Verify UE send full UDP UL data and full UDP DL data
        ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
        ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
        ...    exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}    duration_dl=${duration_dl}

        Append To List    ${result_list}    ${reset_status}
        ${fail_num}    Count Values In List    ${result_list}     fail
        Exit for loop if    ${fail_num}>=2
		#${result}  set variable if    ${duration_time_tmp}>${KPI1a_MAX}   failed    pass
    END
	Run Keyword and Continue on Failure   ims_keywords.save_results  ${kpi_results}  ${LOG_PATH}/results_all_${ext_json_name}.json
    ${kpi_avg}  ims_keywords.calculate_kpi_average  ${kpi_results['kpi1a']}
    Run Keyword If  ${kpi_avg} > ${KPI1a_MAX}   Fail
    ...   KPI1a average is above Target ${KPI1a_MAX}
    KW.CaseStatusFinnal    case_avg=${KPI1a_AVG}   max_loop=${retry_times}

gnb PowerResetWithRetry
    [Arguments]      ${case_name}    ${retry_times}=${1}
    ...    ${KPI3_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI3']['KPI3_MAX']}
    ...    ${KPI3_AVG}=${CASE_INPUT_CB006443['CB006443_HA_KPI3']['KPI3_AVG']}
    ...    ${fail_loop_max}=${CASE_INPUT_CB006443['CB006443_HA_KPI3']['fail_loop_max']}
    ...    ${Check_Call}=${False}    ${call_loop}=${2}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}     ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300
    ${Fault_ID} =    Set Variable   4590
    Set suite variable    ${ALLOWED_ALARMS_KPI3}    ${ALLOWED_ALARMS}
    Append to list   ${ALLOWED_ALARMS_KPI3}    ${Fault_ID}
    KW.CaseStatusInit    retry_times=${retry_times}
    ${connection}    Connect to DU by ADMIN API
    DU_WebEM.Get NR Cell distname and id
    DisConnect to DU by ADMIN API
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${retry_times}
        log to console    start power reset Site loop${i}
        ${res}    Run Keyword and Continue on Failure    KW.LoopForPowerReset    loop=${i+1}    cell_id_list=${cell_id_list}
        ...    PowerOnOffRmod=False     KPI3_MAX=${KPI3_MAX}
        #${alarm_result}=    KW.GetAndCheckAlarm
        #Run Keyword And Ignore error   KW.LMIEthOn
        #${reset_status}         set variable if    '${res[0]}'=='fail'      fail    ${res[1][0]}
        #${duration_time_tmp}    set variable if    '${res[0]}'=='fail'      1800    ${res[1][1]}
        KW.CaseStatusCaluate    duration=${res[1]}   max=${KPI3_MAX}
        Run Keyword And Ignore error    Get common info
        ...    case_result=${res[0]}    case_name=${case_name}   loop_number=${i+1}  duration_time=${res[1]}
        #${result}  set variable if    ${duration_time_tmp}>${KPI3_MAX}   failed    pass
        ${remainder}    Evaluate    (${i}+1)%${call_loop}
        Run Keyword And Ignore error
        ...    Run Keyword If    '${res[0]}'=='pass' and '${Check_Call}'=='${True}' and '${remainder}'=='${0}'
        ...    RUN KEYWORD AND CONTINUE ON FAILURE    Verify UE send full UDP UL data and full UDP DL data
        ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
        ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
        ...    exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}    duration_dl=${duration_dl}
        Append To List    ${result_list}     ${res[0]}
        ${fail_num}    Count Values In List    ${result_list}     fail
        log to console    this power reset Site loop${i} is ${res[0]} and KPI is ${res[1]}
        Exit for loop if    ${fail_num}>=${fail_loop_max}
    END
	Run Keyword and Continue on Failure   ims_keywords.save_results  ${kpi_results}  ${LOG_PATH}/results_all_${ext_json_name}.json
    ${kpi_avg}  ims_keywords.calculate_kpi_average  ${kpi_results['kpi3']}
    Run Keyword If  ${kpi_avg} > ${KPI3_MAX}   Fail
    ...   KPI3 average is above Target ${KPI3_MAX}
    KW.CaseStatusFinnal    case_avg=${KPI3_AVG}    max_loop=${retry_times}

PowerReset5GRUs
    [Arguments]
    ${length}=   Get Length     ${tl.gnbs[0].dus[0].rus}
    FOR    ${i}    IN RANGE    ${length}
        Power.OnOff     pdu_ip=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.addr}
        ...                 Port_Number=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.port_no}
        ...                 Action=power_off
        ...                 model=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.vendor}
    END
    sleep   10s
    FOR    ${i}    IN RANGE    ${length}
        Power.OnOff     pdu_ip=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.addr}
        ...                 Port_Number=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.port_no}
        ...                 Action=power_on
        ...                 model=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.vendor}
    END

KW.PowerOff5GRUs
    [Arguments]
    ${length}=   Get Length     ${tl.gnbs[0].dus[0].rus}
    FOR    ${i}    IN RANGE    ${length}
        Power.OnOff     pdu_ip=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.addr}
        ...                 Port_Number=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.port_no}
        ...                 Action=power_off
        ...                 model=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.vendor}
    END

KW.PowerOn5GRUs
    ${length}=   Get Length     ${tl.gnbs[0].dus[0].rus}
    FOR    ${i}    IN RANGE    ${length}
        Power.OnOff     pdu_ip=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.addr}
        ...                 Port_Number=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.port_no}
        ...                 Action=power_on
        ...                 model=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.vendor}
    END

SWUpdateWithRetry
    [Arguments]      ${case_name}    ${Intermediate_upgrade_package_path}    ${Target_package_path}   ${retry_times}=5
    ...    ${Update_By_YAFT}=${CASE_INPUT_CB006443['CB006443_IA_15']['UpdateByYAFT']}
    ...    ${KPI4_MAX}=${CASE_INPUT_CB006443['CB006443_IA_KPI4']['KPI4_MAX']}
    ...    ${KPI4_AVG}=${CASE_INPUT_CB006443['CB006443_IA_KPI4']['KPI4_AVG']}
    ...    ${SCF}=None
    KW.CaseStatusInit    retry_times=${retry_times}
    FOR    ${i}    IN RANGE    ${retry_times}
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        ${res}    run keyword and ignore error    KW.LoopForSWUpdate
        ...    loop=${i+1}   Intermediate_upgrade_package_path=${Intermediate_upgrade_package_path}
        ...    Target_package_path=${Target_package_path}    SCF=${SCF}
        run keyword if     '${res[0]}'=='FAIL' and '${Update_By_YAFT}'!='true'
        ...    set suite variable    ${StopCase}    true
        ${reset_status}         set variable if    '${res[0]}'=='FAIL' or '${StopCase}'=='true'      fail    ${res[1][0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL' or '${StopCase}'=='true'      3600    ${res[1][1]}
        KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${KPI4_MAX}
        log to console     Case loop ${i+1} END
        Run Keyword And Ignore error     Get common info
        ...    case_result=${reset_status}    case_name=${case_name}
        ...    loop_number=${i+1}   duration_time=${duration_time_tmp}
        ${snapshot_file}    Run Keyword If    '${reset_status}'=='fail'
        ...    Run keywords   sleep    60s
        ...    AND    Run Keyword And Ignore error     wait until keyword succeeds    30x    2min    WEBUI.Collect snapshot
         Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop       loop=${i+1}
         log to console     The snapshot of failed SWUpdateWithRetry${i} is ${snapshot_file}
    END
    KW.CaseStatusFinnal    case_avg=${KPI4_AVG}   max_loop=${retry_times}


Select Intermediate gnb package save
        [Arguments]      ${qt_sub_release}=CPRI_TDD_SA_ASIK_cmw:released
        ...              ${qt_sub_release_with_res}=CPRI_TDD_SA_ASIK_cmw:released_with_restrictions
        ${version_target}=    set variable   ${0}
        ${Intermediate_version}=    set variable   ${0}
        ${version_target}     GetgNBActiveSWVersion
        @{version_target_list}   Split String   ${version_target}    .
        ${last_part_version_target_list}    Set Variable    ${${version_target_list[-1]}}
        ${int_last_part_version_target}     Evaluate     int(${last_part_version_target_list})
        ${version_original}    GetPassivegNBSWVersion
        @{version_original_list}   Split String   ${version_original}    .
        ${last_part_version_original_list}    Set Variable    ${${version_original_list[-1]}}
        ${int_last_part_version_original}     Evaluate     int(${last_part_version_original_list})
        ${get_version_from_wft_cmd_Tmp1}  set variable  python -m com.interface.wft query-package --lookup_status=released --lookup_status=
        ${get_version_from_wft_cmd_Tmp2}  set variable  released_with_restrictions --stream_version=0.800 --limit_number
        run    command=${get_version_from_wft_cmd_Tmp1}${get_version_from_wft_cmd_Tmp2}=20 --cit=true --output=cli.output1.txt
        ${wft_request_result}   read_jason_file
        log      ${wft_request_result}
        FOR     ${item}     IN      @{wft_request_result}
                log     ${item}
                ${state_tmp}    Get From Dictionary   ${item}     state
                ${Intermediate_version_tmp}    Get From Dictionary   ${item}     version
                Run Keyword If    '${state_tmp}[9]'=='None'    Continue For Loop
                ${state_tmp_4}    Get From List   ${state_tmp}     9
                ${Intermediate_version}   Set variable if  '${state_tmp}[9]'=='${qt_sub_release}' or '${state_tmp}[9]'=='${qt_sub_release_with_res}'
                ...            ${Intermediate_version_tmp}
#               Run Keyword If    '${target_version}'=='None'    Continue For Loop
                @{Intermediate_list}   Split String   ${Intermediate_version}    .
                ${Intermediate_last_part}   Set Variable   ${${Intermediate_list[-1]}}
                ${int_Intermediate_last_part}     Evaluate     int(${Intermediate_last_part})
                Exit For Loop If      ${int_last_part_version_original}<${int_Intermediate_last_part}<${int_last_part_version_target}
        END
        [Return]     ${Intermediate_version}


Check all cells Should Be On Air
    [Arguments]      ${connection}=COAM    ${login_flag}=${True}    ${wait_time}=12min    ${reset_flag}=${False}
     Run Keyword and Continue on Failure      DU_WebEM.LogIn and Check all NR Cell On Air
     ...    login_flag=${login_flag}    connection=${connection}    wait_time=${wait_time}    reset_flag=${reset_flag}

Check all cells Should Be On Air and caputre snapshot if not on air
     ${cell_status}     Run Keyword And Return Status   wait until keyword succeeds    30min    1s    Check BTS Onair
     Run Keyword If    '${cell_status}'=='False'    Run Keyword And Ignore error    WEBUI.Collect snapshot
      ...    ELSE IF    '${cell_status}'=='True'      log     gnb is onair

BtsLog.StopBTSlogCollectionandGetlog_setup
    core.teardown_collectors      names=btslog
    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/setup_SYSLOG.tgz SYSLOG_combine.LOG
    run    command=cp /tmp/setup_SYSLOG.tgz ${LOG_PATH}/.

Check BTS Onair
    Run Keyword If   '${BTSMOD}'=='5GOnly'    COAM_Admin.CheckAllCellsOnair    type=nr    bts_host=${5G_WEBUI_IP}
    ...    ELSE IF          '${BTSMOD}'=='ConCorrent'    run keywords
    ...    COAM_Admin.CheckAllCellsOnair    type=nr    bts_host=${5G_WEBUI_IP}    AND
    ...    COAM_Admin.CheckAllCellsOnair    type=lte   bts_host=${4G_WEBUI_IP}
    ...    ELSE    Fail

CB006443_Resouce.gNB.CheckgNBReset
    ${status}    Run Keyword And Return Status    CB006443_Resouce.gNB.PingOAM
    Should Be True    '${status}'=='False'

CB006443_Resouce.gNB.PingOAM
    ${result}  run   command=ping ${ASIK_IP} -c 10
    should contain    ${result}    64 bytes from ${ASIK_IP}

Check if gNB is Cell On Air
    [Arguments]   ${failure_msg}=Gnb not on air!
    ${gNB_on_air}    run keyword and return status    wait until keyword succeeds   5x   2min   COAM_VerifyOnAirViaFrontendAndBackend
    run keyword if  not ${gNB_on_air}    fail    msg=${failure_msg}

COAM.VerifyAllCellsAreOnline
    [Documentation]   This kw is to check all cells are online in COAM
    [Arguments]
    wait until keyword succeeds    10min    60s    COAM_WebEM.Login
    ${CellNum}    selenium_coam.get_number_of_cells
    FOR    ${i}    IN RANGE    ${CellNum}
        ${Idx}    Evaluate     1+${i}
        Cell Should Be Online    cell_idx=${Idx}    cell_group_idx=${i}
    END
    COAM_WebEM.Logout

Cell Should Be Online
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=COAM
    ${subcell_status}=  Get Cell Status by CellID      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings  ${subcell_status["operationalState"]}   Enabled
    #Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}  Online
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  Unlocked

Get Cell Status by CellID
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=COAM
    ${cell_idx}   Convert To Integer   ${cell_idx}
    ${cell_group_idx}  Convert To Integer    ${cell_group_idx}
    ${subcells_status}    coam.get_subcells_status   timeout=${timeout}    connection=${connection}
    ${status_dict}   Catenate   'operationalState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["operationalState"]}',
    ...                         'availabilityStatus':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["availabilityStatus"]}',
    ...                         'administrativeState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["administrativeState"]}'
    ${subcell_status}    Evaluate   {${status_dict}}
    [Return]   ${subcell_status}

#####################################  for setup and teardown & log collect #####################################

SetUp Case
    [Arguments]    ${connection}=COAM    ${reset_flag}=${True}
    ...    ${wait_time}=8min
    TestCase.Start
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
    Run Keyword And Ignore Error    robot_common_operations.Common case setup


Teardown Case
    Teardown case if case fail
    TestCase.Stop
    Run Keyword And Ignore Error    robot_common_operations.Common case Teardown


Case SetUp
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection

Start BTSlogs Collection
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf TRACE_*.bin ; rm -rf SYSLOG_*.LOG
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/home/ute/btslog/btslog
    ...   btslog_launcher_path=/home/ute/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    btslog.Set Global Alias     btslog
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog

Stop BTSlogs Collection and get logs
    core.teardown_collectors      names=btslog
    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz SYSLOG_combine.LOG
    run    command=cp /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz ${LOG_PATH}

Stop BTSlogs Collection and get logs for every loop
    [Arguments]   ${loop}=${1}
    core.teardown_collectors      names=btslog
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${BTS_syslog}    Set Variable    ${TEST NAME}_SYSLOG_${loop}_${timestamp}.tgz
    ${BTS_syslog}     Remove String    ${BTS_syslog}    ${SPACE}
    ${BTS_zip_path}      Set Variable   ${BTS_syslog}
    ${BTS_zip_path}      Set Variable   /tmp/btslog2/${timestamp}
    Set Test Variable      ${BTS_zip_path}
    run    command=mkdir -p ${BTS_zip_path}
    run    command=cd /tmp/btslog2 ; tar -zcvf "${BTS_zip_path}/${BTS_syslog}" SYSLOG_*.LOG
    run    command=cp "${BTS_zip_path}/${BTS_syslog}" ${LOG_PATH}
    Set Test Variable         ${LOG_PATH}
    Set Test Variable         ${BTS_zip_path}
    [Return]    ${BTS_syslog}

Teardown case if case fail
    [Documentation]   History: 1.delete power on RU,not all case need  this step
    ...    2.delete step Collect snapshot, for loop case, this is not enough
    ...    3.This KW is used for case without WEBEM
    #Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog
    Run Keyword And Ignore Error    GNB.kill admin process
    Run Keyword And Ignore Error    run   command=killall firefox
    Conn.ResetCache

Teardown case for KPI4
    Run Keyword And Ignore Error     run    command=rm -r ${UPDATE_FILE_PATH}/*
    run keyword if   '${CaseState}'!='package_prepared'    KW.SendFailReport
    Teardown case if case fail
    TestCase.Stop

KW.SendFailReport
     FOR    ${i}    IN RANGE    ${SW_update_times}
         ${reset_status}         set variable     fail
         ${duration_time_tmp}    set variable     3600
         Run Keyword And Ignore error     Get common info
         ...    case_result=${reset_status}    case_name=swm   loop_number=${i+1}   duration_time=${duration_time_tmp}
     END


############   setup and teardown end #########################################################################

COAM.modfy parameters and check alarms
    [Arguments]    ${item}    ${DistName}   ${FilterParam}   ${NewValue}    ${alarm_status}
    COAM_WebEM.Login
    Run Keyword And Continue On Failure     COAM_WebEM.ModifyAndActiveParameters   ${DistName}   ${FilterParam}   ${NewValue}
    log to console    Parameters modify completed
    COAM_WebEM.Logout
    sleep  30s
    ${alarm_check}    run keyword and return status    COAM.Check alarm via webui    ${item}
    Run keyword if    '${alarm_status}'=='present'     should be true    '${alarm_check}' == 'True'
    ...    ELSE IF    '${alarm_status}'=='disapeared'    should be true    '${alarm_check}' == 'false'

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
    log to console    check alarms completed

COAM.Check alarm
    [Arguments]    ${item}
    ${alarm_id}   Set Variable   ${alarm_info[${i}]['Alarm ID']}
    ${fault_id}   Set Variable   ${alarm_info[${i}]['Fault ID']}
    ${alarm_name}   Set Variable   ${alarm_info[${i}]['Fault name']}
    Run Keyword And Continue On Failure    should contain   container=${Alarm ID}   item=${item[0]}
    Run Keyword And Continue On Failure    should contain   container=${fault_id}   item=${item[1]}
    Run Keyword And Continue On Failure    should contain   container=${alarm_name}   item=${item[2]}

Check fault on WebUI
    [Arguments]    ${alarm_filter}   ${Alarm_ID_CP}    ${Alarm_name_CP}    ${Fault_name_CP}
    #WEBUI Login
    @{alarm info}=    Wait Until Keyword Succeeds    1min    2s
    ...    selenium_coam.get_active_alarm_info    alarm_filter=${alarm_filter}    timeout=100
    ${fault_dic}   set variable    ${alarm info}[0]
    ${Alarm_ID}    set variable    ${fault_dic}[Alarm ID]
    ${Alarm_name}    set variable    ${fault_dic}[Alarm name]
    #${Fault_ID}    set variable    &{fault_dic}[Fault ID]
    ${Fault_name}    set variable    ${fault_dic}[Fault name]
    #${Severity}    set variable    &{fault_dic}[Severity]
    should be equal     ${Alarm_ID}     ${Alarm_ID_CP}
    should be equal     ${Alarm_name}     ${Alarm_name_CP}
    #should be equal     ${Fault_ID}     ${Fault_ID_CP}
    should be equal     ${Fault_name}     ${Fault_name_CP}
    #should be equal     ${Severity}     ${Severity_CP}
    #should be equal     ${Alarming_object}     ${Alarm_ob_CP}
COAM_WebEM.ModifyParameters
    [Arguments]    ${DistName}=MRBTS-1907/NRBTS-7/NRCELL-1    ${FilterParam}=Timer t301    ${NewValue}=600ms
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${DistName}    filter_param=${FilterParam}    new_value=${NewValue}

    COAM_WebEM.ValidateAndActiveParameters

Case TearDown
    Run Keyword And Ignore Error    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    file_path=${TS_CASE_LOG_PATH}
    #Run Keyword If Test Failed    COAM Save snapshot via rest api
    #run keyword and ignore error    COAM Teardown gnb connections
Get BTS Information via rest api
    [Arguments]    ${connection}=GNB_OAM
    Log to console    Info: ready to Get BTS Information
    ${bts_info} =    coam.get_bts_info    connection=${connection}
    [Return]    ${bts_info}

ASIK.Connect
    [Arguments]   ${alias}=${ALIAS_ASIK}
    Run Keyword And Continue On Failure  ssh.Connect to    hostname=${ASIK_IP}
     ...    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}  alias=${alias}
get leng
ASIK.Disconnect
     [Arguments]   ${alias}=${ALIAS_ASIK}
    Run Keyword And Continue On Failure  Conn.Disconnect    ${alias}


WEBUI.Collect snapshot
    [Arguments]   ${timeout}=${960}
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${snapshot_file}    set variable    ${MRBTS_ID}_Snapshot_${timestamp_log}.zip
    ${login_status_Tmp}     Run Keyword And Return Status
    ...   wait until keyword succeeds    20min   10s     Connect to DU by ADMIN API    connection_AdminApi=COAM2
    Run Keyword And Ignore Error     log to console   Log in SBTS for snapshot is ${login_status_Tmp}
    #selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=${location}
    RUN KEYWORD AND CONTINUE ON FAILURE    taf.sbts.oam.coam.admin.collect_snapshot
    ...    target_file_name=${LOG_PATH}/${snapshot_file}      timeout=${timeout}    connection=COAM2
    #log to console    Failure snapshot is ${snapshot_file}
    #${snapshot_name_o}    Fetch From Right    ${snapshot_file}    /
    #${snapshot_path}    Remove String    ${snapshot_file}    ${snapshot_name_o}
    #${snapshot_name}    Run Keyword And Ignore Error    Remove String    ${snapshot_name_o}     ${SPACE}
    #Run Keyword And Continue On Failure    run
    #...    command=cp '${snapshot_file}' ${LOG_PATH}/${snapshot_name[1]}
    #${saved_snapshot}    set variable  ${LOG_PATH}/${snapshot_name[1]}
    ${snapshot_file}    set variable  ${LOG_PATH}/${snapshot_file}
    set suite variable     ${snapshot_file}
    Should not contain     ${snapshot_file}     CollectSnapshotFailed     collectsnapshotfailed
    [Return]     ${snapshot_file}
    [Teardown]     run keyword and ignore error     DisConnect to DU by ADMIN API    connection_AdminApi=COAM2


GNB.kill admin process
    run    command=sudo ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
