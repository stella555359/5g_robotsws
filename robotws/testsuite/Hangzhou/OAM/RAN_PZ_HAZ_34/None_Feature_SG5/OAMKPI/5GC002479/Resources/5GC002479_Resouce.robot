*** Settings ***
Documentation    author:Liu Tiffany
...               contact: tiffany.liu@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC002479
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource          ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
Variables         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/None_Feature_SG1/OAM_Interface.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource          taf/rfrl/bts/robot/common/gnb_cell.robot
Resource          taf/rfrl/bts/robot/common/gnb_ru.robot
Resource          taf/rfrl/bts/robot/common/gnb_log.robot
Resource          ./var_test_suite.robot
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           ReadJason.py
Library           OperatingSystem
Library           DateTime
Library           ute_wtssim
Library           ute_syslog
Library           ute_admin
Library           requests
Library           Collections
Library           Process
Library           String
Library           Telnet
Library         ./ims_keywords.py
Library         taf.ul.oam_kpi_calculations.utilities
Library         taf.ul.oam_kpi_calculations  WITH NAME  oam_kpi_calculations
Library          ute_reporting_portal
Library         taf.rfrl.common_resources.oam_kpi.report_oam_kpi
Variables       targets.py

*** Variables ***
#${CFGFILE_ON_GIT}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
#${GoldenSCF_PATH}         ${GoldenSCF_ON_GIT}/${GoldenSCF}
#${CFGFILE_PATH}           /home/ute/TAF/cfgfile/
#${CFGFILE_ON_GIT}         ${CFGFILE_PATH}/5GC002479/

#${GoldenSCF_ON_GIT}       /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/
#${link_to_Artifact}       https://esisoj70.emea.nsn-net.net/artifactory/mnp5g-central-public/System_Release/
${link_to_Artifact}       https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release/
${UPDATE_FILE_PATH}       /home/ute/Download_gNB_Package
${YAFT_PATH}              /opt/ute/YAFT

#${rmod_index}                1
#@{ALLOWED_FAULT}            &{fault_61652}    &{fault_61524}
#${RU_TYPE}                  ${tl.gnbs[0].du.rus[0].radio_type.value}
${PROGRAM}                  ${None}

${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}

${ASIK_LMP_IP_URL}          https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

#${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

#${PB_PORT}                  5000

${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

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
#CASE_INPUT_5GC002479	=	{
#    '5GC002479':{'LoopTimeout':'30','LoopTimeoutForSWUpdate':'90',},
#    '5GC002479_IA_15':{'UpdateByYAFT':'true',},
#}
*** Keywords ***
#reset site via webUI
TC.5GC002479_HA_03_OAM_KPI_61a_Software_Reset_Startup_Success_Rate
    KW.PassRateStatusFinal
TC.5GC002479_HA_06_OAM_KPI_63_Power_Reset_Success_Rate
    KW.PassRateStatusFinal
TC.5GC002479_HA_09_OAM_KPI_651_RU_Software_Reset_Startup_Success_Rate
     KW.PassRateStatusFinal
TC.5GC002479_IA_18_OAM_KPI_64_SWM_SW_Upgrade_Success_Rate_Intra_Release
     KW.PassRateStatusFinal
TC.5GC002479_HA_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
    [Arguments]   ${WebUI_reset_times}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['WebUI_reset_times']}

    &{kpi_results}  Create Dictionary  kpi1a=@{EMPTY}
    Set suite Variable  ${kpi_results}
    ${kpi_list}  Get Dictionary Keys  ${kpi_results}
    Set Test Variable  ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_1a
    Set Test Variable  ${target_kpis}
    gnb resetViaWebUIWithRetry   case_name=site_reset    retry_times=${WebUI_reset_times}
# power reset
TC.5GC002479_HA_04_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
    [Arguments]   ${Power_reset_times}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI3']['Power_reset_times']}
    &{kpi_results}  Create Dictionary  kpi3=@{EMPTY}
    Set suite Variable  ${kpi_results}
    ${kpi_list}  Get Dictionary Keys  ${kpi_results}
    Set Test Variable  ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_3
    Set Test Variable  ${target_kpis}
    gnb PowerResetWithRetry   case_name=power_reset       retry_times=${Power_reset_times}
# RF reset
TC.5GC002479_HA_08_OAM_KPI_51_RU_Reset_Time
    [Arguments]   ${RF_reset_times}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI51a']['RF_reset_times']}

    &{kpi_results}  Create Dictionary  kpi51a=@{EMPTY}
    Set suite Variable  ${kpi_results}
    ${kpi_list}  Get Dictionary Keys  ${kpi_results}
    Set Test Variable  ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_51a
    Set Test Variable  ${target_kpis}

    Ru WEbUIResetWithRetry   case_name=rf_reset        retry_times=${RF_reset_times}
#SWM,SW update
TC.5GC002479_IA_15_OAM_KPI_4_SWM_SW_Upgrade_Time_Intra_Release_Single_Core
    [Arguments]   ${SW_update_times}=${CASE_INPUT_5GC002479['5GC002479_HA_KPI4']['SW_update_times']}
    run    command=rm -rf ${UPDATE_FILE_PATH}
    sleep   10s
    run    command=mkdir ${UPDATE_FILE_PATH}
    ${version_Target}    ${version_Original}    Get gNB SW version 5GC002479
    log to console    original=${version_Original}
    log to console    target=${version_Target}
    log to console    AFtarget=${TargetBTSVersion}
    log to console    ${CASE_INPUT_5GC002479['5GC002479_IA_15']['UpdateByYAFT']}
    ${Intermediate_upgrade_package_path}    run keyword if    '${CASE_INPUT_5GC002479['5GC002479_IA_15']['UpdateByYAFT']}'=='true'
    ...            KW.PreparePackageByYAFT
    ...    ELSE    KW.PreparePackage
    ${Target_package_path}        SoftwareUpdate.Download_gNB_Package    build_version=${TargetBTSVersion}
    log to console    package prepared
    set suite variable    ${CaseState}      package_prepared
    SWUpdateWithRetry    case_name=swm    Intermediate_upgrade_package_path=${Intermediate_upgrade_package_path}
    ...        Target_package_path=${Target_package_path}     retry_times=${SW_update_times}

KW.AutoClearLog
    [Arguments]    ${loop}=0
    run keyword if     ${loop}>${20} and '${CASE_INPUT_5GC002479['5GC002479']['AutoClearLog']}'=='true'
    ...    KW.ClearLog    loop=${loop-20}

KW.ClearLog
    [Arguments]    ${loop}=0
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    run     cd ${LOG_PATH}&&rm *${filename}_${loop}*

KW.LMILogInit
    log to console    KW.LMILogInit
    run keyword and ignore error    Log.LMIConsoleLogInit   lmi=${TLCommonConfig['rus']['0']}
    Log.LMIBtsLogInit  lmi=${TLCommonConfig['rus']['0']}

KW.LMIEthOn
    log to console    KW.LMIEthOn
    Log.LMIEnableLMIOn    lmi=${TLCommonConfig['rus']['0']}

KW.LMILogCollect
    [Arguments]    ${loop}=0    ${result}=pass
    log to console    KW.LMILogCollect
    run keyword if    '${result}'!='pass'   run keyword and ignore error    Log.LMIRULogCollect
    ...    lmi=${TLCommonConfig['rus']['0']}    loop=${loop}
    run keyword and ignore error    Log.LMIBtsLogCollect  lmi=${TLCommonConfig['rus']['0']}    loop=${loop}
    run keyword and ignore error    Log.LMIConsoleLogCollect    lmi=${TLCommonConfig['rus']['0']}    loop=${loop}

KW.CheckRUAlarmOrOnair
    ${res}     run keyword and ignore error     Check BTS Onair
    return from keyword if   '${res[0]}'=='PASS'    NO
    wait until keyword succeeds    10min    60s    COAM_WebEM.Login
    ${ret}=    Wait Until Keyword Succeeds    1min    5s
    ...    selenium_coam.get_active_alarm_info    alarm_filter=BASE STATION SOFTWARE MANAGEMENT PROBLEM
    run keyword and ignore error    COAM_WebEM.Logout
    Log   ${ret}
    Should Not Be Empty   ${ret}
    [Return]      YES

KW.PreparePackage
    ${version_Target}    ${version_Original}    Get gNB SW version 5GC002479
    ${version_Original}    Basic.AdjustBTSVersion    sw_version=${version_Original}    stream=${TargetBTSStream}
    ${Intermediate_gnb_package}   Select PreReleased gnb package    version_target=${version_Target}
    log to console     Intermediate_gnb_package is:${Intermediate_gnb_package}
    Run Keyword If    '${Intermediate_gnb_package}'=='${version_Original}'    Fail
    ${Intermediate_upgrade_package_path}       SoftwareUpdate.Download_gNB_Package    build_version=${Intermediate_gnb_package}
    [Return]       ${Intermediate_upgrade_package_path}

KW.PreparePackageByYAFT
    ${version_Target}    ${version_Original}    Get gNB SW version 5GC002479
    ${version_Original}    Basic.AdjustBTSVersion    sw_version=${version_Original}    stream=${TargetBTSStream}
    log to console     version_Original is:${version_Original}
    ${Intermediate_upgrade_package_path}       SoftwareUpdate.Download_gNB_Package    build_version=${version_Original}
    Set Suite Variable    ${OriginalVersion}    ${version_Original}
    [Return]       ${Intermediate_upgrade_package_path}

KW.PrepareENVbyYAFT
    [Arguments]    ${filename}
    ${Smods}    COAM_Admin.GetBTSTopology
    ${length}=   Get Length   ${Smods}
#    run keyword if    ${filename.count('${TargetBTSVersion}')}>0    Set Suite Variable    ${gSCF}    None
#    ...    ELSE       Set Suite Variable    ${gSCF}    ${OriginalStreamSCF}
    run keyword if  '${length}'=='1'      KW.SWM.PrepareEnvByYAFT    filename=${filename}    scf=None
    ...    ELSE    KW.PrepareENVDualCore    filename=${filename}

KW.PrepareENVDualCore
    [Arguments]    ${filename}
    ${SecondaryUTEVMIP}       set variable    ${CASE_INPUT_5GC002479['5GC002479_IA']['SecondaryUTEVMIP']}
    ssh.Connect to    hostname=${SecondaryUTEVMIP}    username=ute     password=ute     alias=SecondaryUTEVMIP
    ${cmd}=  Catenate     SEPARATOR=${SPACE}
    ...                   source ~/CIENV/${CASE_INPUT_5GC002479['5GC002479_IA']['SecondaryTLName']}/bin/activate &&
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
    ${version_Target}    ${version_Original}    wait until keyword succeeds    30min    60s    Get gNB SW version 5GC002479
    log to console     active=${version_Target}
    log to console     passive=${version_Original}
    log to console    Second YAFT
    KW.TryEnableSSH
    wait until keyword succeeds    3x    60s    SoftwareUpdate.YAFT    filepath=${filename}
    ${version_Target}    ${version_Original}    wait until keyword succeeds    30min    60s    Get gNB SW version 5GC002479
    log to console     active=${version_Target}
    log to console     passive=${version_Original}
    log to console    Second YAFT END and wait onair
    KW.TryEnableSSH
    #run keyword if    '${scf}'!='None'    set suite variable    ${WEBUI_IP}        ${ASIK_LMP_IP}
    run keyword if    '${scf}'!='None'    wait until keyword succeeds    30min    60s   gNB.Commission   scf_file=${scf}
    FOR    ${i}    IN RANGE    ${20}
        ${res}    wait until keyword succeeds    30min    60s    KW.CheckRUAlarmOrOnair
        run keyword if     '${res}'=='YES'        KW.UpGradeForRU    filename=${filename}
        ...    ELSE    Exit For Loop
    END
    Set Suite Variable    ${ASIK_IP}      ${ASIK_IP_BAK}
    Set Suite Variable    ${WEBUI_IP}     ${WEBUI_IP_BAK}
    Set Suite Variable    ${WEBUI_URL}    ${WEBUI_URL_BAK}
#KW.PrepareEnvByYAFT
#    [Arguments]    ${filename}
#    #KW.RollbackAndBackupSCFFile
#    log to console    YAFT Started
#    KW.TryEnableSSH
#    KW.YAFT    filename=${filename}
#    ${version_Target}    ${version_Original}    Get gNB SW version 5GC002479
#    log to console     active=${version_Target}
#    log to console     passive=${version_Original}
#    log to console    Second YAFT
#    KW.TryEnableSSH
#    KW.YAFT    filename=${filename}
#    ${version_Target}    ${version_Original}    Get gNB SW version 5GC002479
#    log to console     active=${version_Target}
#    log to console     passive=${version_Original}
#    log to console    Second YAFT END and wait onair
#    FOR    ${i}    IN RANGE    ${20}
#        ${res}    wait until keyword succeeds    30min    60s    KW.CheckRUAlarmOrOnair
#        run keyword if     '${res}'=='YES'        KW.UpGradeForRU    filename=${filename}
#        ...    ELSE    Exit For Loop
#    END
##    gNB.Connect
##    gNB.CheckHWStatusUntilReady
##    gNB.Disconnect
##    COAM_Admin.commission    scf_file=${SCFFile}    bts_host=${5G_WEBUI_IP}
#    KW.TryEnableSSH

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
    [Arguments]    ${filename}
    Check all cells Should Be On Air
    rollback site
    Check all cells Should Be On Air
    wait until keyword succeeds    10min    60s    COAM_WebEM.Login
    Download and update package of site      if_active=${True}     upgrade_package_path=${filename}
    Check all cells Should Be On Air
    rollback site
    Check all cells Should Be On Air

KW.TryEnableSSH
    ${value}    Run Keyword And Ignore error    ssh.Connect to    hostname=${ASIK_IP}    username=${ASIK_USERNAME}
    ...    password=${ASIK_PASSWORD}     alias=${ALIAS_ASIK}
    Run Keyword And Ignore error    Conn.Disconnect    alias=ALIAS_ASIK
    Return From Keyword if    '${value[0]}'=='PASS'
    wait until keyword succeeds    15min    30s    COAM_WebEM.Login    url=${ASIK_LMP_IP_URL}
    COAM.EnableSSH
    COAM_WebEM.Logout

#KW.YAFT
#    [Arguments]    ${filename}=AS__*.zip
#    log   ${filename}
#    gNB.Connect
#    ${BOARD}    gNB.GetSystemModuleName
#    gNB.Disconnect
#    ${yaft_command}    Set Variable If   '${BOARD}'=='ASIL'
#    ...    cd ${YAFT_PATH} &&python ./yaft.py -i ${5G_WEBUI_IP} -z ${filename} -K --ignore_FSPs
#    ...    cd ${YAFT_PATH} &&python ./yaft.py -i ${5G_WEBUI_IP} -z ${filename} -K --ignore_FSPs
#    log  ${yaft_command}
#    run  rm -rf ${YAFT_PATH}/YAFT_IMAGE
#    ${result}  run  ${yaft_command}
#    Should Contain Any   ${result}   Flashing done    Cannot establish SSH session with FCT    Waiting for FC* after reboot

KW.LoopForSWUpdate
    [Arguments]    ${loop}    ${Intermediate_upgrade_package_path}    ${Target_package_path}
    #[Timeout]    ${CASE_INPUT_5GC002479['5GC002479']['LoopTimeoutForSWUpdate']} minutes
    run keyword if     '${StopCase}'=='true'    Fail    loop stoped for Software update
    ${version_Active}    GetgNBActiveSWVersion
    ${version_Passive}    GetPassivegNBSWVersion
    Exit For Loop If    '${version_Active}'=='Null' or '${version_Passive}'=='null'
    #####    rollback from Intermediate to original
    run keyword if    '${CASE_INPUT_5GC002479['5GC002479_IA_15']['UpdateByYAFT']}'=='true'
     ...            KW.PrepareEnvByYAFT    filename=${Intermediate_upgrade_package_path}
     ...    ELSE    KW.PrepareEnvByRollback   filename=${Intermediate_upgrade_package_path}
    ###############    update gnb package from original to target#####################
    log to console    case started
    wait until keyword succeeds    10min    60s    COAM_WebEM.Login       url=${ASIK_LMP_IP_URL}
    ${timestartTmp}   Get Current Date
    ${timestart}      convert date    ${timestartTmp}    epoch
    Download and update package of site      if_active=${True}     upgrade_package_path=${Target_package_path}
    ${reset_status_Tmp}     Run Keyword And Return Status      Check all cells Should Be On Air
    ${timeendTmp}     Get Current Date
    ${timeend}        convert date    ${timeendTmp}     epoch
    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    ${reset_status}	   Set Variable If	  "${reset_status_Tmp}"=="True" and ${duration_time_tmp}<3600   pass      fail
    log to console    case  end
    run keyword and ignore error  COAM_WebEM.Logout
    [Return]    ${reset_status}   ${duration_time_tmp}

KW.LoopForResetViaWEBUI
    [Arguments]    ${loop}=0
    oam_kpi_calculations.clear_results
    oam_kpi_calculations.save_search_start_timestamp
    #wait until keyword succeeds   10x   1min    COAM_Admin.Login
    wait until keyword succeeds    10min    10s    COAM_WebEM.Login
    #wait until keyword succeeds    10min    10s    Selenium Login And Disable Screen Lock
    selenium_coam.reset_site
    #COAM_Admin.ResetSite     timeout=1800
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    #Selenium Logout And Close Browser
    sleep    1min
    ${reset_status_Tmp}          Run Keyword And Return Status     Check all cells Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}
    Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${loop}_ims2/
    ${status}  Analyse IMS File   kpi_list=${kpi_list}    loop=${loop}
    ${status}  Evaluate  ${status} or ${alarm_status} or ${ACTIVATE_SNAPSHOT}
    ${duration_time_tmp}    Set Variable   ${kpi_avg}
    ${reset_status}	   Set Variable If	  "${reset_status_Tmp}"=="True" and ${duration_time_tmp}<1800 	    pass      fail
    run keyword and ignore error    COAM_Admin.Logout
    ims_keywords.instance_disconnect  gnbbbu

    [Return]    ${reset_status}   ${duration_time_tmp}

KW.LoopForPowerReset
    [Arguments]    ${loop}
    #[Timeout]    ${CASE_INPUT_5GC002479['5GC002479']['LoopTimeout']} minutes
    KW.PowerOff5GRUs
    Power.ResetgNB     model=${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}
    sleep    3s
    oam_kpi_calculations.clear_results
    #oam_kpi_calculations.save_search_start_timestamp
    ${bts_power_on_timestamp}    ims_keywords.Get_Start_Point_Timestamp    kpi_names=${kpi_list}
    KW.PowerOn5GRUs
    sleep    3s
    ${reset_status_Tmp}          Run Keyword And Return Status     Check all cells Should Be On Air
    #oam_kpi_calculations.save_search_end_timestamp
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}
    Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${loop}_ims2/
    ${status}  Analyse IMS File   kpi_list=${kpi_list}    loop=${loop}    kpi_params=${bts_power_on_timestamp}
    ${status}  Evaluate  ${status} or ${alarm_status} or ${ACTIVATE_SNAPSHOT}
    #${timestart}      convert date    ${timestartTmp}    epoch
    #${timeendTmp}     Get Current Date
    #${timeend}        convert date    ${timeendTmp}     epoch
    #${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    ${duration_time_tmp}    Set Variable   ${kpi_avg}
    ${reset_status}	   Set Variable If   "${reset_status_Tmp}"=="True" and ${duration_time_tmp}<1800      pass      fail
    run keyword and ignore error    COAM_Admin.Logout
    [Return]    ${reset_status}   ${duration_time_tmp}
    [Teardown]    Run Keyword And Ignore Error   ims_keywords.instance_disconnect  gnbbbu

KW.LoopForWebUIReset
    [Arguments]    ${loop}
    #[Timeout]      ${CASE_INPUT_5GC002479['5GC002479']['LoopTimeout']} minutes
    oam_kpi_calculations.clear_results
    oam_kpi_calculations.save_search_start_timestamp
    wait until keyword succeeds    10min    10s    COAM_WebEM.Login
##    ${timestartTmp}   Get Current Date
    WEBUI.ResetRU    ru_index=${CASE_INPUT_5GC002479['5GC002479_HA_08_KPI51a']['ru_index']}
    sleep    2min
    COAM_WebEM.Logout
    sleep    1min
    ${reset_status_Tmp}          Run Keyword And Return Status     Check all cells Should Be On Air
    oam_kpi_calculations.save_search_end_timestamp
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}
    Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${loop}_ims2/
    ${status}  Analyse IMS File   kpi_list=${kpi_list}    loop=${loop}
    ${status}  Evaluate  ${status} or ${alarm_status} or ${ACTIVATE_SNAPSHOT}
##    ${timestart}      convert date    ${timestartTmp}    epoch
##    ${timeendTmp}     Get Current Date
##    ${timeend}        convert date    ${timeendTmp}     epoch
##    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    ${duration_time_tmp}    Set Variable   ${kpi_avg}
    ${reset_status}	   Set Variable If    "${reset_status_Tmp}"=="True" and ${duration_time_tmp}<1800   pass      fail
    run keyword and ignore error    COAM_Admin.Logout
    ims_keywords.instance_disconnect  gnbbbu
##    ${duration_time_tmp}   Evaluate    ${duration_time_tmp}-${CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['KPI51_AVG_ADJ']}
    [Return]    ${reset_status}   ${duration_time_tmp}

KW.Suite setup for 2479
    [Documentation]
    [Arguments]
    TestSuite.Start
    Create Log Directories
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    run keyword and ignore error    Import Variables         /home/ute/TAF/cfgfile/2479_Loop_times.py
    set suite variable    ${GoldenSCF_PATH}         ${GoldenSCF_ON_GIT}/${GoldenSCF}
    set suite variable    ${SCFPrepared}    notstart
    set suite variable    ${StopCase}       false
    set suite variable    ${CaseState}      notstart
    ${stream}    ${version_Target}    Basic.GetStreamAndVersion
    #${version_Target}          get regexp matches    ${AF_PATH}     [0-9]+.[0-9]+.[0-9]+
    set suite variable    ${TargetBTSVersion}    ${version_Target}
    set suite variable    ${TargetBTSStream}     ${stream}
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479']['LoopTimeout']    default_value=30
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479']['LoopTimeoutForSWUpdate']    default_value=90
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_15']['UpdateByYAFT']    default_value=false
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_08_KPI51a']['ru_index']    default_value=1
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI3']['KPI3_AVG']    default_value=450    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI3']['KPI3_MAX']    default_value=540    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['KPI1a_AVG']    default_value=450    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['KPI1a_MAX']    default_value=540    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI51a']['KPI51a_AVG']    default_value=360    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI51a']['KPI51a_MAX']    default_value=432    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_KPI4']['KPI4_AVG']    default_value=1320    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_KPI4']['KPI4_MAX']    default_value=1584    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI51a']['KPI51a_AVG_ADJ']   default_value=0    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['WebUI_reset_times']
    ...                         default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI3']['Power_reset_times']
    ...                         default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI51a']['RF_reset_times']
    ...                         default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI4']['SW_update_times']
    ...                         default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479']['AutoClearLog']    default_value=true
    KW.CaseStatusInit    retry_times=${100}
    ${CurrentStreamSCF}   COAM_Admin.BackupSCF

    #Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA']['OriginalStreamSCF']    default_value=None
    Set Suite Variable    ${CurrentStreamSCF}     ${CurrentStreamSCF}
    Set Suite Variable    ${OriginalStreamSCF}     ${CFGFILE_PATH}/OriginalStreamSCF.xml
    ${ACTIVATE_SNAPSHOT}=  Get Variable Value  ${ACTIVATE_SNAPSHOT}  ${False}
    Set Suite Variable  ${ACTIVATE_SNAPSHOT}
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
    SISO Coam Suite Setup
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
    [Arguments]        ${case_avg}=${0}    ${max_loop}=${0}
    ${avg}    run keyword if     ${CaseAVGLoop}>0   Evaluate    ${CaseSUM}/${CaseAVGLoop}
    ...    ELSE    Fail    0 loop pass
    should be true    ${avg}<=${case_avg}

KW.PassRateStatusFinal
    run keyword if    '${CasePassRateStatus}'!='PASS'    Fail    case ${CaseAVGLoop} loop pass in ${CaseMaxTime} loop

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
    run keyword if    '${checkReset}'=='true'    Wait until keyword succeeds    20min    10s    5GC002479_Resouce.gNB.CheckgNBReset
#    ...    ELSE IF     '${finish}'=='true'    Check all cells Should Be On Air
    ...    ELSE IF     '${finish}'=='true'    Sleep    60
#    wait until keyword succeeds    10min    10s    check_software_update_progress
    [Return]    ${finish}

rollback site
    ${active_version_before}   ${passive_version_before}     Get gNB SW version 5GC002479
    log to console     active before:${active_version_before}
    log to console     passive before:${passive_version_before}
    log to console     rollback site on webUI
    wait until keyword succeeds    10min    60s    COAM_WebEM.Login
    selenium_coam.software_rollback
#    Run Keyword And Ignore Error    COAM_WebEM.Logout
    Wait until keyword succeeds    20min    20s    5GC002479_Resouce.gNB.CheckgNBReset
    sleep  10s
#    selenium_coam.disable_screen_lock
#    wait until keyword succeeds    18min    10s    check site reset actually finished
#    Run Keyword And Ignore Error    wait until keyword succeeds    2min    15s     COAM_WebEM.Logout
    #Run Keyword And Ignore Error    run process    taskkill /f /im firefoxdriver.exe    shell=True
    #Run Keyword And Ignore Error    run process    ps -ef|grep firefox | awk '{print $2}' |xargs kill -9    shell=True
#    Run Keyword And Ignore Error    wait until keyword succeeds    30min    5s    COAM_WebEM.Login

    ${active_version_after}   ${passive_version_after}   Get gNB SW version 5GC002479
    log to console     active after:${active_version_after}
    log to console     passive after:${passive_version_after}
    should be equal   ${passive_version_before}    ${active_version_after}

check board and cell status
    Check ABIL is UP
    Check ASIK is UP
    Check all cells Should Be On Air

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
    should be equal      ${output}[Availability status]     Online
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
       [Arguments]      ${version_target}=0.800
#       ${version_target}=    set variable   ${0}
#       ${Intermediate_version}=    set variable   ${0}
       #${version_target}     GetgNBActiveSWVersion

#       ${key}          get regexp matches    ${AF_PATH}     [0-9]+.[0-9]+
#       ${key1}          get regexp matches    ${AF_PATH}     [0-9]+.[0-9]+.[0-9]+
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

Get common info
    [Arguments]    ${testline}=${testline_name}    ${case_name}=case_tmp       ${case_result}=pass  ${loop_number}=0  ${duration_time}=0
    ...    ${enb_version}=NA    ${URL}=http://toolscenter.eecloud.dynamic.nsn-net.net/api/oamkpi/input/?version=
    ${enb_version}    run keyword if   '${BTSMOD}'=='ConCorrent'    COAM_Admin.GetActiveSoftwareVersion    bts_host=${4G_WEBUI_IP}
    ...    ELSE    set variable    NA
    ${duration_time_int}     Evaluate      int(${duration_time})
    #${version}    GetgNBActiveSWVersion
    ${version}       set variable     ${TargetBTSVersion}
    ${URL_tmp1}      set variable     ${URL}${version}&testline=${testline}&casename=${case_name}&case_result=${case_result}
    ${res}    requests.get
    #version=0.800.1356&testline=7_5_UTE5G402TXXX&casename=site_reset&case_result:pass&loop_number=1&duration_time=hh:mm:ss
    ...   url=${URL_tmp1}&loop_number=${loop_number}&duration_time=${duration_time_int}&enb_version=${enb_version}&module=single_core
    #log to console       ${res.read()}

#SeleniumCoamGetGnbSWVersion
#    [Arguments]    ${key}=Passive
#    COAM_WebEM.Login
#    selenium_coam.check_current_software_version     key=${key}
#    COAM_WebEM.Logout

Get gNB SW version 5GC002479
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
    [Arguments]      ${case_name}  ${retry_times}=3
    KW.CaseStatusInit    retry_times=${retry_times}
    Set Test Variable    ${PowerReset}    True
    FOR    ${i}    IN RANGE    ${retry_times}

        Run Keyword And Ignore error   KW.LMILogInit
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        ims_keywords.check_instance_connection    gnbbbu
        ${res}    run keyword and ignore error    KW.LoopForResetViaWEBUI    loop=${i+1}
        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Ignore error   KW.LMIEthOn
        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['KPI1a_MAX']}
        log to console     Case loop ${i+1} END
        Run Keyword And Ignore error    Get common info
        ...    case_result=${reset_status}    case_name=${case_name}   loop_number=${i+1}  duration_time=${duration_time_tmp}
        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}
        Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${i+1}
        ${result}  set variable if    ${duration_time_tmp}>${CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['KPI1a_MAX']}   failed    pass
        Run Keyword And Ignore error    KW.LMILogCollect   loop=${i+1}    result=${result}
        Run Keyword And Ignore error    KW.AutoClearLog    loop=${i+1}
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ute_reporting_portal.Set Reference Configuration Id   ref_configuration_id=CNF_5G_T459
        Report OAM KPI    oam_kpi_targets=${OAM_KPI_TARGETS}
        #Run Keyword If    ${duration_time_tmp}>${CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['KPI1a_MAX']}    Fatal Error    exit suite
    END
    Run Keyword and Continue on Failure   ims_keywords.save_results  ${kpi_results}  ${LOG_PATH}/results_all_${ext_json_name}.json
    ${kpi_avg}  ims_keywords.calculate_kpi_average  ${kpi_results['kpi1a']}
    Run Keyword If  ${kpi_avg} > ${CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['KPI1a_AVG']}   Fail
    ...   KPI1a average is above Target ${CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['KPI1a_AVG']}

    KW.CaseStatusFinnal    case_avg=${CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['KPI1a_AVG']}    max_loop=${retry_times}
gnb PowerResetWithRetry
    [Arguments]      ${case_name}    ${retry_times}=5
    KW.CaseStatusInit    retry_times=${retry_times}
    Set Test Variable    ${PowerReset}    True
    FOR    ${i}    IN RANGE    ${retry_times}
        Run Keyword And Ignore error   KW.LMILogInit
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        ims_keywords.check_instance_connection    gnbbbu
        ${res}    run keyword and ignore error    KW.LoopForPowerReset    loop=${i+1}
        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Ignore error   KW.LMIEthOn
        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${CASE_INPUT_5GC002479['5GC002479_HA_KPI3']['KPI3_MAX']}
        log to console     Case loop ${i+1} END
        Run Keyword And Ignore error    Get common info
        ...    case_result=${reset_status}    case_name=${case_name}   loop_number=${i+1}  duration_time=${duration_time_tmp}
        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}
        Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${i+1}
        ${result}  set variable if    ${duration_time_tmp}>${CASE_INPUT_5GC002479['5GC002479_HA_KPI3']['KPI3_MAX']}   failed    pass
        Run Keyword And Ignore error    KW.LMILogCollect   loop=${i+1}    result=${result}
        Run Keyword And Ignore error    KW.AutoClearLog     loop=${i+1}
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ute_reporting_portal.Set Reference Configuration Id   ref_configuration_id=CNF_5G_T459
        Report OAM KPI    oam_kpi_targets=${OAM_KPI_TARGETS}
        #Run Keyword If    ${duration_time_tmp}>${CASE_INPUT_5GC002479['5GC002479_HA_KPI3']['KPI3_MAX']}    Fatal Error    exit suite
    END
    Run Keyword and Continue on Failure   ims_keywords.save_results  ${kpi_results}  ${LOG_PATH}/results_all_${ext_json_name}.json
    ${kpi_avg}  ims_keywords.calculate_kpi_average  ${kpi_results['kpi3']}
    Run Keyword If  ${kpi_avg} > ${CASE_INPUT_5GC002479['5GC002479_HA_KPI3']['KPI3_AVG']}   Fail
    ...   KPI3 average is above Target ${CASE_INPUT_5GC002479['5GC002479_HA_KPI3']['KPI3_AVG']}
    KW.CaseStatusFinnal    case_avg=${CASE_INPUT_5GC002479['5GC002479_HA_KPI3']['KPI3_AVG']}    max_loop=${retry_times}

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

Ru WEbUIResetWithRetry
    [Arguments]      ${case_name}     ${retry_times}=5
    KW.CaseStatusInit    retry_times=${retry_times}
    Set Test Variable    ${PowerReset}    False
    FOR    ${i}    IN RANGE    ${retry_times}
        Run Keyword And Ignore error   KW.LMILogInit
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        ims_keywords.check_instance_connection    gnbbbu
        ${res}    run keyword and ignore error    KW.LoopForWebUIReset    loop=${i+1}
        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Ignore error   KW.LMIEthOn
        ${reset_status}         set variable if    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${CASE_INPUT_5GC002479['5GC002479_HA_KPI51a']['KPI51a_MAX']}
        log to console     Case loop ${i+1} END
        Run Keyword And Ignore error    Get common info
        ...    case_result=${reset_status}    case_name=${case_name}   loop_number=${i+1}  duration_time=${duration_time_tmp}
        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${i+1}
        Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${i+1}
        ${result}  set variable if    ${duration_time_tmp}>${CASE_INPUT_5GC002479['5GC002479_HA_KPI51a']['KPI51a_MAX']}   failed    pass
        Run Keyword if   '${result}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${i+1}
        Run Keyword And Ignore error    KW.LMILogCollect   loop=${i+1}    result=${result}
        Run Keyword And Ignore error    KW.AutoClearLog     loop=${i+1}
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        ute_reporting_portal.Set Reference Configuration Id   ref_configuration_id=CNF_5G_T459
        Report OAM KPI    oam_kpi_targets=${OAM_KPI_TARGETS}
        #Run Keyword If    ${duration_time_tmp}>${CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['KPI51_MAX']}    Fatal Error    exit suite
    END
    Run Keyword and Continue on Failure   ims_keywords.save_results  ${kpi_results}  ${LOG_PATH}/results_all_${ext_json_name}.json
    ${kpi_avg}  ims_keywords.calculate_kpi_average  ${kpi_results['kpi51a']}
    Run Keyword If  ${kpi_avg} > ${CASE_INPUT_5GC002479['5GC002479_HA_KPI51a']['KPI51a_AVG']}   Fail
    ...   KPI51a average is above Target ${CASE_INPUT_5GC002479['5GC002479_HA_KPI51a']['KPI51a_AVG']}
    KW.CaseStatusFinnal    case_avg=${CASE_INPUT_5GC002479['5GC002479_HA_KPI51a']['KPI51a_AVG']}    max_loop=${retry_times}

SWUpdateWithRetry
    [Arguments]      ${case_name}     ${Intermediate_upgrade_package_path}    ${Target_package_path}   ${retry_times}=5
    KW.CaseStatusInit    retry_times=${retry_times}
    FOR    ${i}    IN RANGE    ${retry_times}
        Run Keyword And Ignore error   KW.LMILogInit
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        ${res}    run keyword and ignore error    KW.LoopForSWUpdate
        ...    loop=${i+1}   Intermediate_upgrade_package_path=${Intermediate_upgrade_package_path}    Target_package_path=${Target_package_path}
        run keyword if     '${res[0]}'=='FAIL' and '${CASE_INPUT_5GC002479['5GC002479_IA_15']['UpdateByYAFT']}'!='true'
        ...    set suite variable    ${StopCase}    true
        Run Keyword And Ignore error   KW.LMIEthOn
        ${reset_status}         set variable if    '${res[0]}'=='FAIL' or '${StopCase}'=='true'      fail    ${res[1][0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='FAIL' or '${StopCase}'=='true'      3600    ${res[1][1]}
        KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${CASE_INPUT_5GC002479['5GC002479_IA_KPI4']['KPI4_MAX']}
        log to console     Case loop ${i+1} END
        Run Keyword And Ignore error    Get common info
        ...    case_result=${reset_status}    case_name=${case_name}   loop_number=${i+1}   duration_time=${duration_time_tmp}
        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop       loop=${i+1}
        Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${i+1}
        Run Keyword And Ignore error    KW.LMILogCollect    loop=${i+1}
        Run Keyword And Ignore error    KW.AutoClearLog     loop=${i+1}
    END
    KW.CaseStatusFinnal    case_avg=${CASE_INPUT_5GC002479['5GC002479_IA_KPI4']['KPI4_AVG']}    max_loop=${retry_times}

#COAM_WebEM_LMP_Login
#    [Documentation]   parameter should be ${True} or ${False}
#    [Arguments]      ${virtual_enable}=${TRUE}
#    run keyword if     ${virtual_enable}     selenium_coam.enable_virtual_display
#    run keyword and ignore error    selenium_coam.logout
#    selenium_coam.login    url=${ASIK_LMP_IP_URL}    username=${WEBUI_USERNAME}    password=${WEBUI_PASSWORD}
#    selenium_coam.disable_message_box
#    selenium_coam.disable_screen_lock
#    sleep    15s
#    ${res}    selenium_coam.start_up_view_window_exists
#    run keyword if    '${res}'=='True'        selenium_coam.close_start_up_view_window

Check all cells Should Be On Air
     wait until keyword succeeds    30min    1s    Check BTS Onair

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

gNB.CheckgNBReset
    ${status}    Run Keyword And Return Status    5GC002479_Resouce.gNB.PingOAM
    Should Be True    '${status}'=='False'

gNB.PingOAM
    ${result}  run   command=ping ${ASIK_IP} -c 10
    should contain    ${result}    64 bytes from ${ASIK_IP}

COAM_WebEM.VerifyAllCellsAreOnlineFor2479
    COAM_Admin.CheckAllCellsOnair    type=nr    bts_host=${5G_WEBUI_IP}

Check if gNB is Cell On Air
    [Arguments]   ${failure_msg}=Gnb not on air!
    ${gNB_on_air}    run keyword and return status    wait until keyword succeeds   5x   2min   COAM_VerifyOnAirViaFrontendAndBackend
    run keyword if  not ${gNB_on_air}    fail    msg=${failure_msg}

Cell Should Be Online
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=COAM
    ${subcell_status}=  Get Cell Status by CellID      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings  ${subcell_status["operationalState"]}   Enabled
    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}  Online
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
    TestCase.Start
    Run Keyword And Ignore error      COAM_WebEM.Login
    ${onair_check}    run keyword and return status     COAM_WebEM.VerifyAllCellsAreOnlineFor2479
    Run keyword if    '${onair_check}'=='False'     Do site reset to recovery gnb
    ...    ELSE IF    '${onair_check}'=='True'      log     gnb is onair
    Run Keyword And Ignore error      COAM_WebEM.Logout
    SISO Coam Test Setup

Teardown Case
    Teardown case if case fail
    TestCase.Stop

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
    [Arguments]   ${loop}
    core.teardown_collectors      names=btslog
    ${time}    Get time    epoch
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
#    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
#    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME.replace(" ", "_")}${loop}_SYSLOG.tgz SYSLOG_combine.LOG
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/BTSLOG_${filename}_${loop}_${time}.tgz SYSLOG_*.LOG
    run    command=cp /tmp/BTSLOG_${filename}_${loop}_${time}.tgz ${LOG_PATH}

Teardown case if case fail
    [Arguments]   ${connection}=COAM
    Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog
    Run Keyword And Ignore Error    WEBUI.Backup current SCF
    log     ${TEST STATUS}
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    WEBUI.Collect snapshot
    ...    ELSE    run keyword if    '${TEST STATUS}' == 'PASS'    log to console    Not collect snapshot logs
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
         Run Keyword And Ignore error    Get common info
         ...    case_result=${reset_status}    case_name=swm   loop_number=${i+1}   duration_time=${duration_time_tmp}
     END
Do site reset to recovery gnb
    wait until keyword succeeds   10x   1min    COAM_Admin.Login
    COAM_Admin.ResetSite     timeout=1800
    Run Keyword And Ignore Error     Check all cells Should Be On Air
    Run Keyword And Ignore Error    COAM_Admin.Logout
    Run Keyword And Ignore Error    COAM_WebEM.Logout

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
    ${alarm_info}    Wait Until Keyword Succeeds    1min    5s
    ...    selenium_coam.get_active_alarm_info
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

ASIK.Disconnect
     [Arguments]   ${alias}=${ALIAS_ASIK}
    Run Keyword And Continue On Failure  Conn.Disconnect    ${alias}

Collect snapshot via webui
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}

#Setup suite
#    Create Log Directories
#    #set suite variable      ${Log_PATH_Artifactory}    /root/workspace/CIT/Master/Case_Logs/
#    set suite variable   ${OAM_TYPE}    COAM
#	${outputfile}    gNB.Generate TL SCF
#	...                  GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}   TLDelta_PATH=${TLDelta_PATH_ON_GIT}
#	...                  TestLineSCF_cell_num=${1}    cell_type=Both
#	...                  MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#	${Original_CFGFILE_754}    Generate 754_1cell_SA    InputFile=${outputfile}
#	set suite variable    ${Original_CFGFILE_754}
#    gNB.Commission    scf_file=${Original_CFGFILE_754}    timeout=${2400}
#    Wait until keyword succeeds   30min   1min    COAM_VerifyOnAirViaFrontendAndBackend
#    Conn.ResetCache
	
#Setup case
    #run keyword and ignore error    Start BTSlogs Collection

WEBUI.Collect snapshot
    [Arguments]    ${loop}=0
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    Run Keyword And Ignore Error    run    command=mv ${snapshot_file} ${LOG_PATH}/snapshot_${filename}_${loop}.zip

WEBUI.Backup current SCF
    wait until keyword succeeds   10x   1min    COAM_Admin.Login
    coam.get_current_scf_file   local_dir_path=${LOG_PATH}   file_name=${TEST NAME.replace(" ", "_")}.xml   connection=COAM   timeout=10
    COAM_Admin.Logout

GNB.kill admin process
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9

KW.GetAndCheckAlarm
    @{Fault_whitelist}    Create list    4655   4654   61524   61652   4459
    Run Keyword if   '${PowerReset}' == 'True'    append to list    ${Fault_whitelist}    4592
    #COAM_WebEM.Login
    Selenium Login And Disable Screen Lock    version=SBTS25R1
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    ${active_alarm}    Wait Until Keyword Succeeds    1min    5s
    ...    selenium_coam.get_active_alarm_info
    log    ${active_alarm}
    ${history_alarm}    Wait Until Keyword Succeeds    1min    5s
    ...    selenium_coam.get_history_alarm_info
    log    ${history_alarm}
    ${fault_id_list}    create list
    ${unexpect_fault}    create list
    FOR    ${item}    IN    @{active_alarm}
         ${fault_id}    get from dictionary    ${item}    Fault ID
         append to list    ${fault_id_list}    ${fault_id}
    END
    FOR    ${item}    IN    @{history_alarm}
         ${fault_id}    get from dictionary    ${item}    Fault ID
         append to list    ${fault_id_list}    ${fault_id}
    END
    log    ${fault_id_list}
    ${length}    Get length     ${fault_id_list}
    FOR    ${i}    IN RANGE    ${length}
        ${result}=    Run Keyword And Return Status    list should contain value      ${Fault_whitelist}    ${fault_id_list[${i}]}
        Run Keyword if   '${result}' == 'False'
        ...   append to list    ${unexpect_fault}    ${fault_id_list[${i}]}
    END
    log    ${unexpect_fault}
    ${alarm_result}=    run keyword and return status    should be empty    ${unexpect_fault}
    #COAM_WebEM.Logout
    Selenium Logout And Close Browser
    [Return]    ${alarm_result}
Analyse IMS File
    [Arguments]  ${kpi_list}   ${kpi_params}=${None}    ${loop}=0
    oam_kpi_calculations.Calculate Kpis  kpi_names=${kpi_list}   ims_file_path=${ims_file}    kpi_params=${kpi_params}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${LOG_PATH}/loop${loop}_ims2/results_${ext_json_name}.json
    ${result}  oam_kpi_calculations.get_results
##    [Return]    ${results}
    ims_keywords.save_kpi_to_csv_results  ${loop}  ${LOG_PATH}/loop${loop}_ims2  ${result}  ${active_alarms_list}
    FOR  ${kpi}  IN  @{kpi_list}
        ${x} = 	Combine Lists 	${kpi_results['${kpi}']} 	${result['${kpi}']}
        Set To Dictionary  ${kpi_results}  ${kpi}  ${x}
    END
    FOR  ${kpi_name}  IN  @{target_kpis}
        ${kpi}=  Set Variable  ${kpi_name.replace('KPI_', 'kpi')}
        ${kpi_avg}  oam_kpi_calculations.get_average_results  kpi_name=${kpi}
        Return From Keyword If  ${kpi_avg} > ${CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['KPI1a_MAX']}  ${True}
        ${duration_time_tmp}    Set test Variable   ${kpi_avg}
    END

    Return From Keyword    ${False}

Collect IMS File
   [Arguments]   ${log_dir}
   ${ims_file_path}  gnb_log.Collect IMS Log From gNB  log_dir=${log_dir}  timeout=${600}
   @{ims_files}=  List Files In Directory  ${log_dir}  pattern=*.bin
   Set Suite Variable  ${ims_file}  ${log_dir}${ims_files[-1]}
   OperatingSystem.run  find ${log_dir} -name \"*.ims2\" -exec rm {} \\;
Collect Active Alarms
    [Arguments]    ${loop}=0
    ${active_alarms_list}=   ims_keywords.Get Active Alarms  allowed_alarms=${ALLOWED_ALARMS}
    Set Test Variable  ${active_alarms_list}
    ims_keywords.Save Alarms  ${active_alarms_list}  ${LOG_PATH}/loop${loop}
    Return From Keyword If  ${active_alarms_list} != @{EMPTY}   ${True}
    Return From Keyword    ${False}
