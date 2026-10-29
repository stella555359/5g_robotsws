*** Settings ***
Documentation     author: Ruiyu Han
...               contact: ruiyu.han@nokia-sbell.com
...               Upgrade and Rollback UUF case.
Library    taf.ul.selenium.netact    WITH NAME    selenium_netact
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.pdu    WITH NAME    pdu
Library           ../../libraries/TestCaseRequirement.py
Library    String
Library    Collections
Library           DateTime
Resource           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/NetAct_selenium.robot
Resource           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/NetAct_swing.robot
Resource           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/netact_swm.robot
Resource           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/gnb.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/gnb.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/symptom_collectors_hangzhou.robot
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/mcs_request.py
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/UUF_vars.py
Library     OperatingSystem
Library   XML
Library     Process
Library     String
Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Scripts/gnb_handler.py
Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Scripts/record_gnb_status.py
Library   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/snapshot_structure.py
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/NetAct_ssh.robot
Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Scripts/UUF_common.py
Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Scripts/btslog_handle.py
Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/get_bts_info.py
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/fallback_common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/L3_Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/RU.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/remote.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/netact_integration.robot
Resource   moran.robot
Library    OperatingSystem

*** Variables ***
${file_name}    RU_logs.zip
${package_path}    /home/ute/AirScale-${origin_version}.zip
${package_web_service}    https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${package_web_service_hz}    https://artifactory-hz1.ext.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release
${knife_package_web_service}    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/Customer_Knife
${enb_wft_addr}   http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
${common_web_service}    https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
${common_web_service2}    https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
@{common_web_service_hz}    https://10.57.169.252/build
...   https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build
...   http://10.135.157.75:8081/artifactory/mn5gran_hzlog-local
@{abil_a_addr_list}   20   24   28   36   40   44
@{abil_c_addr_list}   22   26   30   38   42   46
@{loner_addr_list}   22   26   30
@{exist_abil_log_process}
&{NetAct_LOGS}    SWM=@{SWM_LOGS}   FM=@{FM_LOGS}    CM=@{CM_LOGS}    MEDIATION=@{mediation_LOGS}
@{SWM_LOGS}   /var/opt/oss/log/swm/oss_activity_ITSMCluster_*_*.log    /var/opt/oss/log/swm/oss_error_ITSMCluster_*_*.log
...   /var/opt/oss/log/swm/oss_trace_ITSMCluster_*_*.log
@{FM_LOGS}   /var/opt/oss/log/fm/fmservices/oss_activity_FMCluster_*_*.log    /var/opt/oss/log/fm/fmservices/oss_error_FMCluster_*_*.log
...   /var/opt/oss/log/fm/fmservices/oss_trace_FMCluster_*_*.log    /var/opt/oss/log/audit/oss_security_FMCluster_*_*.log
...   /var/opt/oss/log/audit/oss_change_FMCluster_*_*.log
@{CM_LOGS}   /var/opt/oss/log/audit/oss_change_CMCluster_*_*.log    /var/opt/oss/log/rac/oss_trace_CMCluster_*_*.log
...   /var/opt/oss/log/rac/oss_error_CMCluster_*_*.log
@{mediation_LOGS}   /var/opt/oss/log/common_mediations/oss_activity*_*.log    /var/opt/oss/log/common_mediations/oss_error*_*.log
@{NE3S_LOGS}   /rom/config/ne3sadapt/managers    /ram/ne3sadapt/notifs
...   /ffs/run/swpool/OAM/rules/SCFD    /ffs/stb/swpool/OAM/rules/SCFD
${origin_version}    7.1836.1008
${upgrade_version}    7.3836.231
${test_mode}    UUF
${nom_nodeip}    ${netact_nodeip}
${nom_username}    neonetics
${LMP_URL}    https://${LMP_ADDR}
${WEBUI_URL}    https://${WEBUI_ADDR}
${DEBUG}   false
${ru_log_script}   ${CURDIR}/../Scripts/collect_ru_general_logs.py
${ru_tcpdump_script}   ${CURDIR}/../Scripts/collect_ru_tcpdump.py
#${scf_link}    git@gitlabe1.ext.net.nokia.com:SG8/golden_scf.git
${deltaplan_script}   ${CURDIR}${/}..${/}Scripts${/}monitor_and_download_file.py
${snapshot_script}   ${CURDIR}${/}..${/}Scripts${/}save_single_snapshot.py
${enable_ssh_script}   ${CURDIR}${/}..${/}Scripts${/}enable_ssh_to_ru.py
${enable_made_script}   ${CURDIR}${/}..${/}Scripts${/}collect_made_logs.py
${enable_collect_log_script}   ${CURDIR}${/}..${/}Scripts${/}collect_logs_when_alarm_report.py
${l3_call}   N
${enable_ru_flag_script}   ${CURDIR}${/}..${/}Scripts${/}enable_ru_flag.py

*** Keywords ***
test suite setup
    [Arguments]    ${webui_tool}=Megazone    ${upgrade_tool}=webui
    Check running nms mode
    ${bts_id}   convert to string   ${MRBTS_ID}
    set suite variable    ${bts_id}
    ${slave_bts_id}    Run Keyword If   '${bts_id}' in @{Multi_BTS_ID}   convert to string   ${PEER_BTS_ID}
    set suite variable    ${slave_bts_id}
    run keyword and ignore error  Run   ps -ef|grep ${enable_collect_log_script}|grep -v grep| awk '{print $2}' |xargs kill -2
    run keyword and ignore error   Check if Unexpected Active Alarm Exist and Set Stop Flag   stop_with_trunk_roll_fault=True
    Check If Asik and Abil not detected and set stop flag
    Get All Enb IPs
    FOR     ${enb_ip}    IN    @{enb_ip_list}
        run keyword and ignore error    Check if Unexpected Active Alarm Exist and Set Stop Flag   web_ip=${enb_ip}
        ...   stop_with_trunk_roll_fault=True   if_enb=True
        Check If Asik and Abil not detected and set stop flag    ${enb_ip}
    END
    Run Keyword If   ${if_moran}   run keyword and ignore error
    ...   Check if Unexpected Active Alarm Exist and Set Stop Flag   web_ip=${peer_asik_addr}   bts_id=870   position=_slave
    ...   stop_with_trunk_roll_fault=True
    Run Keyword If   ${if_moran} or '${bts_id}' in @{Multi_BTS_ID}       run keyword and ignore error
    ...   Check If Asik and Abil not detected and set stop flag    ${peer_asik_addr}
    Run Keyword If   '${bts_id}' in @{Multi_BTS_ID}   run keyword and ignore error
    ...   Check if Unexpected Active Alarm Exist and Set Stop Flag   web_ip=${Peer_WEBUI_ADDR}   stop_with_trunk_roll_fault=True
    ...   bts_id=${slave_bts_id}
    run keyword if    ${stop_flag}==1   FAIL
    run keyword if  not ${${DEBUG}}   selenium_netact.enable_virtual_display
    ${bts_id}   convert to string   ${MRBTS_ID}
    set suite variable    ${bts_id}
    run keyword and ignore error     Delete Code and Log from TAF
    Remove logs    savefolder=${webui_tool}
    Remove Planned Space
    Get Available Space on Test PC
    Set gNB SW version and Release
    log to console    Start to switch source build for all sites.
    Run Keyword If   '${bts_id}' in @{Multi_BTS_ID}     Switch to source build   ssh_ip=${peer_asik_addr}   slave_flag=${True}
    ...  web_addr=${Peer_WEBUI_ADDR}
    Run Keyword If   ${if_moran}   Switch to source build   ssh_ip=${peer_asik_addr}   slave_flag=${True}   web_addr=${Peer_WEBUI_ADDR}
    Switch to source build
#    Run Keyword If   ${if_moran}   Switch to enb source build   host=${peer_asik_addr}   type=gNB
    # The log below is for compass tool to see if gnb switch build already finished.
    # So please make sure that this log is right after switch gnb build job finish and before switch enb build.
    log to console    All gnb sites on the source build(${origin_version}) now!
    run keyword and ignore error   run keyword if   '${bts_id}' in @{Concurrent_BTS_ID} or '${bts_id}' in @{Multi_BTS_ID}
    ...   Switch to enb source build
    # The log below is for compass tool to see if enb switch build already finished.
    # So please make sure that this log is right after switch enb build job finish.
    run keyword if   '${bts_id}' in @{Concurrent_BTS_ID} or '${bts_id}' in @{Multi_BTS_ID}
    ...    log to console    All enb sites on the source build(${enb_source_version}) now!
    ...    ELSE    log to console    No need to switch enb source build.
    log to console    Remove source package now.
    run keyword and ignore error   Run   rm -rf /home/ute/${origin_version}.zip
    run keyword if   ('${bts_id}' in @{Concurrent_BTS_ID} or '${bts_id}' in @{Multi_BTS_ID}) and '${enb_source_version}'!='${enb_target_version}'
    ...    Check taget SW package exist in taf server    version=${enb_target_version}
    Set gNB SW version and Release
    COAM Download SCF to Current Dir
    Get SCF Param
    run keyword if  'both' in ${cellDepType} or 'NSA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   COAM Download SCF to Current Dir    filename=X2ENB_SCF_BACKUP.xml    bts_host=${ENBs[0]['addr']}
    ${x2_enb_mrbtsId}    run keyword if  'both' in ${cellDepType} or 'NSA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   get_bts_info.Get_LNBTS_ID    ${cpri_scf}/X2ENB_SCF_BACKUP.xml
    run keyword if  'both' in ${cellDepType} or 'NSA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   set suite variable    ${x2_enb_mrbtsId}
    Check if taget SW package exist   upgradetool=${upgrade_tool}    version=${upgrade_version}
    Check gNB memory
    Get Disk Space at Beginning
    run keyword and ignore error   Modify miNrCellAvailability
    run keyword and ignore error  Check Active Alarms and Trigger Recovery Action According to Fault ID
    run keyword and ignore error    Clear RD Flag in Uboot Environment
    run keyword and ignore error   Check if Unexpected Active Alarm Exist and Set Stop Flag
    Check Flag in Swconfig File
    run keyword if    '${bts_id}' in @{Multi_BTS_ID}    Check Flag in Swconfig File    UUF    ${peer_asik_addr}
    FOR     ${enb_ip}    IN    @{enb_ip_list}
        run keyword if    '${bts_id}' in @{Concurrent_BTS_ID}   Check Flag in Swconfig File    UUF    ${enb_ip}    ${True}
    END
    run keyword and ignore error   run keyword if    '${test_mode}'=='UUF'    Check Flag in FSMF
    Site Reset by command if Cell not onAir
    run keyword and ignore error   run keyword if    '${upgrade_tool}'=='webui'    Validate Config by WebEM
    run keyword if   ${upgrade_tool.count('netact')}>0 and '${NMS_TYPE}'=='netact'    Get Netact Release
    run keyword and ignore error   Create Env Config File
    run keyword if  'both' in ${cellDepType} or 'NSA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   run keyword and ignore error  Check eNB Cell Status
    run keyword if  'both' in ${cellDepType} or 'NSA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   run keyword and ignore error   Site reset if eNB not onair
    ${status}    ${passive_not_target}   run keyword and ignore error   Check if Passive Verison is not Target Version
    set suite variable   ${passive_not_target}
    run keyword and ignore error    Get Correspondence between BBMOD and RMOD
    run keyword and ignore error    Check if need add 1815 to ignore history alarm list
    run keyword and ignore error   run keywords    Enable ssh to RU
    ...   AND   Check RU reachability from test PC
    ...   AND   add json to file   disconnected_PC   ${disconnected_pc}
    ...   ${OUTPUT_DIR}/execution_results.json   upgrade
    ...   AND   run keyword if   ${enable_ssh_via_PC}==${True}   Stop ssh RU Script for all ControlPC
#    ...   AND   run keyword if   '${test_mode}'=='UUF'    Precheck RU Flags
    [Teardown]   Run Keyword If   ${if_moran}   Moran Set Share Mode   mode=true

test suite teardown
    [Arguments]     ${webui_tool}=Megazone
    run keyword and ignore error   Delete Log from FTP Within Five Days
    ${if_sg7}   run keyword and return status   should contain   ${OUTPUT_DIR}   HZ_7_SG
    Run Keyword If Any Tests Failed   run keyword if   ${if_sg7}    run keyword and ignore error    Upload TAF Log to FTP Server
    run keyword if  not ${${DEBUG}}   selenium_netact.disable_virtual_display

Test regression robust suite setup
    [Arguments]    ${webui_tool}=Megazone    ${upgrade_tool}=webui
    Check running nms mode
    run keyword if  not ${${DEBUG}}   selenium_netact.enable_virtual_display
    run keyword and ignore error     Delete Code and Log from TAF
    Remove logs    savefolder=${webui_tool}
    Remove Planned Space
    Set gNB SW version and Release
    Switch to source build
    ${bts_id}   convert to string   ${MRBTS_ID}
    set suite variable    ${bts_id}
    Set gNB SW version and Release
    COAM Download SCF to Current Dir
    Get SCF Param
    Check if taget SW package exist   upgradetool=${upgrade_tool}    version=${upgrade_version}
    Check gNB memory
    Get Disk Space at Beginning
    run keyword and ignore error  Check Active Alarms and Trigger Recovery Action According to Fault ID
    run keyword and ignore error    Clear RD Flag in Uboot Environment
    Site Reset by command if Cell not onAir
    run keyword if   ${upgrade_tool.count('netact')}>0    Get Netact Release
    ${status}    ${passive_not_target}   run keyword and ignore error   Check if Passive Verison is not Target Version
    set suite variable   ${passive_not_target}
    run keyword if    ${passive_not_target}==${False}   FAIL

#test robust suite teardown
Test regression robust suite teardown
    [Arguments]     ${webui_tool}=Megazone
    run keyword and ignore error    Upload TAF Log to FTP Server
    run keyword if  not ${${DEBUG}}   selenium_netact.disable_virtual_display

Test setup
    [Arguments]     ${upgrade_tool}=webui   ${webui_tool}=Megazone   ${action}=provision
    run keyword if    ${stop_flag}==1   FAIL
    run keyword and ignore error   Check gNB memory
    run keyword and ignore error   Write gNB Status to Excel   title=memory   content=${totalmem}
    run keyword and ignore error   Get Disk Space at Beginning
    run keyword and ignore error   Write gNB Status to Excel   title=run space   content=${run_spare}
    run keyword and ignore error   Write gNB Status to Excel   title=stb space   content=${stb_spare}
    run keyword and ignore error   COAM Download SCF to Current Dir   dir=${OUTPUT_DIR}   filename=SCF_before_${action}.xml
    run keyword and ignore error   run keyword if    '${upgrade_tool}'=='netact' and '${NMS_TYPE}'=='netact'    Check NetAct Operations
    run keyword and ignore error   Disable RU Swcofnig Cleanup   ${rus}
    Start BTS LOG Collection On Gnb And Rus
    run keyword and ignore error  Start journalctl log for RU   action=${action}
    run keyword and ignore error   Clear Previous RU Console Log
    run keyword if   '${bts_id}' in @{DSS_monitor_ID}   Start eNB TRS Tcpdump
    #here login for getting the first ims2 for get downtime
    gnb_handler.login   ip=${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   gnb_type=coam   connection=get_ims2
    ...    admin_api_log_dir=${OUTPUT_DIR}/${TEST_NAME}/${action}
    ${admin_active_process}   gnb_handler.get_node_process_counter   ${WEBUI_ADDR}
    Log to Console   Active admin process: ${admin_active_process}

Test robust setup
    [Arguments]     ${upgrade_tool}=webui   ${webui_tool}=Megazone   ${action}=robust
    run keyword and ignore error   COAM Download SCF to Current Dir   dir=${OUTPUT_DIR}   filename=SCF_${action}.xml
    run keyword and ignore error   Netact SWM Precheck or Postcheck   operation=Precheck   taget_version=${upgrade_version}
    Start BTS LOG Collection On Gnb And Rus
    run keyword and ignore error  Start journalctl log for RU   action=${action}
    run keyword and ignore error   Clear Previous RU Console Log

Test Reset Setup
    run keyword if    ${stop_flag}==1   FAIL
    Start BTS LOG Collection On Gnb And Rus
    run keyword and ignore error   Clear Previous RU Console Log
    run keyword and ignore error  Start journalctl log for RU   action=reset

Test UUF Teardown
    [Arguments]    ${dir}    ${upgrade_tool}=webui
#    run keyword and ignore error    Change RollbackReject by CM Provsion in Bankend on ${NMS_TYPE}   bts=${input_btsname}   rollback_status=false
    ${upgrade_case}   run keyword and return status  should match regexp  ${TEST_NAME}   .*Upgrade
    ${L3callBTS_status}   run keyword and return status   Dictionary Should Contain Key   ${BTS_L3call}   ${bts_id}
    ${cells}   run keyword if  ${L3callBTS_status}   set variable   ${BTS_L3call}[${bts_id}]
    ${tput}   Set Variable If  '${bts_id}' in @{E2E_BTS_ID}  ${E2E_L3Call_tput}  ${Common_L3Call_tput}
    run keyword if  ${upgrade_case} and ${L3callBTS_status} and '${l3_call}'=='Y'   run keyword and continue on failure
    ...   Data Transfer Conducted for UUF   dir=${TEST_NAME}/provision   cells=${cells}   tput=${tput}
#    ...   ELSE   run keyword and ignore error  add json to file   l3_call   ${call_status_list}
#    ...   ${OUTPUT_DIR}/execution_results.json   upgrade
    #here logout for getting the first ims2 for get downtime
    run keyword and ignore error    gnb_handler.logout    connection=get_ims2
    run keyword and continue on failure  run keyword if  ${upgrade_case} and '${bts_id}' not in @{notDowntime_BTS_ID}
    ...   Get Downtime via Offline and Online Time   ${dir}
    ${admin_active_process}   gnb_handler.get_node_process_counter   ${WEBUI_ADDR}
    Log to Console   Active admin process: ${admin_active_process}
    run keyword and ignore error   run keyword if  ${upgrade_case} and ${passive_not_target}   run keywords
    ...   run keyword and ignore error   UUF_common.get_sw_process_duration_from_swdlreport   process=Download   action=${dir}
    ...   sw_process=${sw_process}   file_path=${OUTPUT_DIR}/execution_results.json   ip=${asik_addr}
    ...   AND   run keyword and ignore error   UUF_common.get_sw_process_duration_from_swdlreport   process=Activation   action=${dir}
    ...   sw_process=${sw_process}   file_path=${OUTPUT_DIR}/execution_results.json   ip=${asik_addr}
    run keyword and continue on failure  Coam Check Site Status
    run keyword and continue on failure    Check if Unexpected Active Alarm Exist and Set Stop Flag   ${dir}
    run keyword and continue on failure  Check if Unexpected History Alarm Exist   ${dir}
#    run keyword and ignore error  Stop tcpdump and Collect log   ${TEST_NAME}/${dir}
    run keyword and continue on failure  Check Extra Reset from Blackbox File   ${dir}
    run keyword if  'both' in ${cellDepType} or 'NSA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   run keyword and continue on failure   Check eNB Cell Status
    Run Keyword If   ${if_moran}   Run Keywords
    ...   run keyword and continue on failure  Check Extra Reset from Blackbox File   ${dir}   host=${peer_asik_addr}
    ...   AND   run keyword and continue on failure   Check if Unexpected Active Alarm Exist and Set Stop Flag
    ...   ${dir}   web_ip=${peer_asik_addr}   bts_id=870   position=_slave
    ...   AND   run keyword and continue on failure  Check if Unexpected History Alarm Exist
    ...   ${dir}   host=${peer_asik_addr}   position=_slave
    Run Keyword If   '${bts_id}' in @{Multi_BTS_ID}  Run Keywords
    ...   run keyword and continue on failure  Check Extra Reset from Blackbox File   ${dir}   host=${peer_asik_addr}
    ...   AND   run keyword and continue on failure   Check if Unexpected Active Alarm Exist and Set Stop Flag
    ...   ${dir}   web_ip=${peer_asik_addr}   bts_id=${slave_bts_id}   position=_slave
    ...   AND   run keyword and continue on failure  Check if Unexpected History Alarm Exist
    ...   ${dir}   host=${peer_asik_addr}   position=_slave
    ${enb_alarm_status}    run keyword if  'both' in ${cellDepType} or 'NSA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   run keyword and return status  Check eNB Active Alarms  ${dir}
    ...   ELSE   set variable  ${True}
    run keyword if  '${enb_alarm_status}'=='False' and '${bts_id}' in @{eNB_alarm_BTS_ID}   Fail
    run keyword if   '${bts_id}' in @{made2_ru_BTS_ID}  run keyword and ignore error    Check made power
    run keyword and ignore error  COAM Download SCF to Current Dir     dir=${OUTPUT_DIR}     filename=SCF_${dir}.xml
#    Validate Config by BackGround     dir=${OUTPUT_DIR}     filename=SCF_${dir}.xml
    wait until keyword succeeds    10 min    30s   Validate PM Report Generated on gNB
    run keyword and ignore error  run keyword if test passed    Log Collection for Pass Case
    run keyword if test passed    Remove logs    savefolder=${TEST_NAME}/${dir}
    run keyword and ignore error  Stop RU journalctl log
    run keyword if test failed    _fail_case_operaton    folder=${TEST_NAME}/${dir}    webui_tool=${OAM_TYPE}
    run keyword and ignore error   run keyword if    '${upgrade_tool}'=='netact' and '${NMS_TYPE}'=='netact'
    ...    Change Parameter Value by CM Provsion in Bankend on NetAct
    ...    param_path=PLMN-PLMN/${input_btsname}   param_value=${input_btsname}   param_name=btsName
    run keyword if  'both' in ${cellDepType} or 'NSA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...    run keyword and ignore error   Site reset if eNB not onair   dir=${dir}   is_teardown=True
#    run keyword unless   'SA' in ${cellDepType}    run keyword and ignore error  Check eNB Active Alarms
    ${admin_active_process}   gnb_handler.get_node_process_counter   ${WEBUI_ADDR}
    Log to Console   Active admin process: ${admin_active_process}
    gnb_handler.reset_cache

Test Robust Teardown
    [Arguments]    ${dir}
    run keyword and continue on failure  Coam Check Site Status
#    run keyword and continue on failure    Check if Unexpected Active Alarm Exist and Set Stop Flag   ${dir}
#    run keyword and continue on failure  Check if Unexpected History Alarm Exist   ${dir}
#    run keyword and ignore error  Stop tcpdump and Collect log   ${TEST_NAME}/${dir}
    run keyword and continue on failure  Check Extra Reset from Blackbox File   ${dir}
#    run keyword and ignore error  run keyword if test passed    Log Collection for Pass Case
    run keyword if test passed    Remove logs    savefolder=${TEST_NAME}/${dir}
    run keyword and ignore error  Stop RU journalctl log
    run keyword if test failed    _fail_case_operaton    folder=${TEST_NAME}/${dir}    webui_tool=${OAM_TYPE}

Test Reset Teardown
    [Arguments]    ${dir}
    run keyword and continue on failure   L3call for E2E site   dir=${dir}
    run keyword and ignore error    run keyword if   '${bts_id}' in @{enable_BTS_ID}    Enable ssh to RU
    run keyword and continue on failure    Check if Unexpected Active Alarm Exist and Set Stop Flag   ${dir}
    run keyword and continue on failure  Check if Unexpected History Alarm Exist   ${dir}
    run keyword and continue on failure  Check Extra Reset from Blackbox File   ${dir}
    Run Keyword If   '${bts_id}' in @{Multi_BTS_ID}  Run Keywords
    ...   run keyword and continue on failure  Check Extra Reset from Blackbox File   ${dir}   host=${peer_asik_addr}
    ...   AND   run keyword and continue on failure   Check if Unexpected Active Alarm Exist and Set Stop Flag
    ...   ${dir}   web_ip=${peer_asik_addr}   bts_id=${slave_bts_id}   position=_slave
    ...   AND   run keyword and continue on failure  Check if Unexpected History Alarm Exist
    ...   ${dir}   host=${peer_asik_addr}   position=_slave
    run keyword and continue on failure  Check syslog
    run keyword and continue on failure   Coam Check Site Status
    run keyword if  'both' in ${cellDepType} or 'NSA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   run keyword and continue on failure   Check eNB Cell Status
    ${enb_alarm_status}    run keyword if   'SA' in ${cellDepType}    set variable  ${True}
    ...   ELSE   run keyword and return status  Check eNB Active Alarms  ${dir}
    run keyword if  'both' in ${cellDepType} or 'NSA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   run keyword if  '${enb_alarm_status}'=='False' and '${bts_id}' in @{eNB_alarm_BTS_ID}   Fail
#    run keyword and ignore error  run keyword if test passed    Log Collection for Pass Case
    run keyword if test passed    Remove logs    savefolder=${TEST_NAME}/${dir}
#    run keyword and ignore error  Stop tcpdump and Collect log   ${TEST_NAME}/${dir}
    run keyword and ignore error  Stop RU journalctl log
    run keyword if test failed    _fail_case_operaton    folder=${TEST_NAME}/${dir}    webui_tool=${OAM_TYPE}
    run keyword if  'both' in ${cellDepType} or 'NSA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}   run keyword and ignore error
    ...   Site reset if eNB not onair   dir=${dir}   is_teardown=True
    run keyword if  'both' in ${cellDepType} or 'NSA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   run keyword and ignore error  Check eNB Active Alarms

_fail_case_operaton
    [Arguments]    ${folder}    ${webui_tool}
    run keyword and ignore error  Run   ps -ef|grep ${enable_collect_log_script}|grep -v grep| awk '{print $2}' |xargs kill -2
    Save logs    folder=${folder}
    #check active alarm again, In case that fualt10 appears later than the verification in teardown
#    run keyword and continue on failure    Check if Unexpected Active Alarm Exist and Set Stop Flag
#    run keyword and ignore error    Check If Module Raise Critical Alarm
#    run keyword if   ${fault10_exist} and ${SMOD_Critical_Alarm}==${False}    run keyword and ignore error    Reset BBMOD When RMOD Raise Fault10
    run keyword if   ${stop_flag}!=1 and 'Reset' not in '${folder}'   Site Reset After Case Failed   folder=${folder}
    ...   ELSE IF    ${stop_flag}!=1 and 'Reset' in '${folder}'   Site Reset After Reset Case Failed   folder=${folder}


Site Reset After Case Failed
    [Arguments]    ${folder}
    ${alarm_status}   run keyword and return status  Check if Unexpected Active Alarm Exist and Set Stop Flag   stop_with_trunk_roll_fault=True
    Check If Asik and Abil not detected and set stop flag
    ${gnb_status}   Run Keyword and Return Status   Coam Check Site Status   if_ignore_cablink=${False}
    run keyword if  ${gnb_status} and ${alarm_status}    log to console  gNB is ok Site Reset will not perform\n
    ...   ELSE IF    ${stop_flag}==1    log to console  fault occurred, will not perform reset to save environment\n
    ...   ELSE   Site Reset And Check Status   folder=${folder}   recover_status=True
    Check if Unexpected Active Alarm Exist and Set Stop Flag   stop_with_trunk_roll_fault=True

Site Reset After Reset Case Failed
    [Arguments]    ${folder}
    ${alarm_status}   run keyword and return status  Check if Unexpected Active Alarm Exist and Set Stop Flag   stop_with_trunk_roll_fault=True
    Check If Asik and Abil not detected and set stop flag
    ${historyalarm_status}   run keyword and return status  Check if Unexpected History Alarm Exist
    ${gnb_status}   Run Keyword and Return Status   Coam Check Site Status
    run keyword if  ${gnb_status} and ${alarm_status} and ${historyalarm_status}    log to console  gNB is ok Site Reset will not perform\n
    ...   ELSE IF    ${stop_flag}==1    log to console  fault occurred, will not perform reset to save environment\n
    ...   ELSE   Site Reset And Check Status   folder=${folder}   recover_status=True
    Check if Unexpected Active Alarm Exist and Set Stop Flag   stop_with_trunk_roll_fault=True
    Check if Unexpected History Alarm Exist

Site Reset And Check Status
    [Arguments]    ${folder}=${dir}   ${recover_status}=False    ${login_ip}=${WEBUI_ADDR}
    Site Reset by Webui    ${login_ip}
    wait until keyword succeeds    15 min    3 min   Check Site Status After Upgrade or Rollback    ip=${login_ip}
    run keyword if   '${recover_status}'=='True'    run keyword and ignore error
    ...   Save Snapshot logs    dir=${folder}   status=after_recover

Create Env Config File
    Create File    ${OUTPUT_DIR}/Environment_Configuration.txt    ${input_btsname} Environment Configuration${\n}
    Append To File    ${OUTPUT_DIR}/Environment_Configuration.txt    ${\n}***gNB Memory***${\n}${totalmem}${\n}
    Append To File    ${OUTPUT_DIR}/Environment_Configuration.txt
    ...    ${\n}***gNB Space***${\n}run space: ${run_spare}${\n}stb space: ${stb_spare}${\n}
    Append To File    ${OUTPUT_DIR}/Environment_Configuration.txt    ${\n}***gNB Alarm***${\n}
    FOR   ${alarm}   IN   @{active_alarm_list}
       Append To File    ${OUTPUT_DIR}/Environment_Configuration.txt   ${alarm}${\n}
    END
    Append To File    ${OUTPUT_DIR}/Environment_Configuration.txt    ${\n}***NetAct Release***${\n}${netact_release}${\n}
    Append To File    ${OUTPUT_DIR}/Environment_Configuration.txt    ${\n}***Active ENB Version***${\n}${active_enb_version}${\n}
    Append To File    ${OUTPUT_DIR}/Environment_Configuration.txt    ${\n}***Passive ENB Version***${\n}${passive_enb_version}${\n}
    Append To File    ${OUTPUT_DIR}/Environment_Configuration.txt    ${\n}***Upgrade Duration***${\n}${upgrade_duration}${\n}

Write gNB Status to Excel
     [Arguments]   ${title}   ${content}
     ${file_path}   run   command=cd ${OUTPUT_DIR}/;cd ..;pwd
     record_gnb_status.write_gnb_status_info_to_excel   test_run=${TEST_NAME}   type=${title}
     ...   info=${content}   file_name=${file_path}/gNB_Status_Infomation_MRBTS-${MRBTS_ID}_${origin_version}.xlsx

Check If Active Software Version Updated
    [Arguments]   ${action}=provision   ${ip}=${LMP_ADDR}   ${upgrade_version}=${upgrade_version}   ${source_build}=${origin_version}
    ${active_version}   ${passive_version}   Get gNB SW version   ip=${ip}
#    ${active_gNB}   Check gNB Version is Common Build   ${active_version}
    ${upgrade_build}   Check gNB Version is Common Build   ${upgrade_version}
    ${origin_build}   Check gNB Version is Common Build   ${source_build}
    log to console    Active verision is ${active_version}, passive version is ${passive_version}.
    run keyword if   '${action}'=='provision'    should be equal  ${upgrade_build}    ${active_version}
    ...    ELSE    should be equal  ${origin_build}    ${active_version}

#Check If Enb Active Software Version Updated
#    [Arguments]   ${action}=provision   ${host}=${ENBs[1]['addr']}
#    ${enb_active_version}   ${enb_passive_version}   Get gNB SW version   ${host}
#    ${upgrade_build}   Check gNB Version is Common Build   ${enb_target_version}
#    ${origin_build}   Check gNB Version is Common Build   ${enb_source_version}
#    log to console    Active Enb verision is ${enb_active_version}, passive Enb version is ${enb_passive_version}.
#    run keyword if   '${action}'=='provision'    should be equal  ${enb_active_version}    ${upgrade_build}
#    ...    ELSE    should be equal  ${origin_build}    ${enb_active_version}

Get Disk Space at Beginning
    ${run_spare}    set suite variable    ${empty}
    ${stb_spare}    set suite variable    ${empty}
    ${run_spare}   ${stb_spare}   Check Disk space
    set suite variable   ${run_spare}
    set suite variable   ${stb_spare}
    should be true   ${${run_spare[:-1]}} >= ${1} and ${${stb_spare[:-1]}} >= ${1}
     ...   msg=[FAIL] gNB run or stb Space is Less Then 1G!!

Get Available Space on Test PC
     ${Taf_Space}   run   df -h | grep /dev/vda2
     @{Split_Taf_Space}   Split String   ${Taf_Space}
     ${Available_Space}   set variable   ${Split_Taf_Space[3]}
     log to console    Available Size of TAF is ${Available_Space}
     run keyword and ignore error   should be true    ${${Available_Space[:-1]}} > ${5}
     ...   msg=[WARN] TAF Space is Less Then 5G!!
     [Return]   ${Available_Space}

Remove Unfinished Downloaded Packages
    [Arguments]   ${package_version}   ${package_name}
    run keyword and ignore error  Run   rm -rf /home/ute/${package_name}
    run keyword and ignore error  Run   rm -rf /home/ute/${package_version}*

Download SW package to TAF VM
    [Arguments]   ${package_version}   ${package_name}
    Remove Unfinished Downloaded Packages   ${package_version}   ${package_name}
    ${if_common}   run keyword and return status   should contain   ${package_version}   SBTS
    ${if_special}   run keyword if   ${if_common}   run keyword and return status   should contain   ${package_version}   9990
    ${common_release}   run keyword if  ${if_common}   Split String   ${package_version}   _   1
    run keyword if   ${if_special}   Set List Value   ${common_release}   0   SBTSCD00
    ${package_download_dir}   Set Variable if  ${if_common}   ${common_web_service}/${common_release}[0]   ${package_web_service}/${package_version}
    FOR   ${item}   IN   @{common_web_service_hz}
        ${if_old_ci}   run keyword and return status   should contain   ${item}   10.135.157.75
        ${package_download_dir_hz}   Set Variable if
        ...    ${if_common} and ${if_old_ci}   ${item}/${common_release}[0]_packages/${package_version}
        ...    ${if_common} and ${if_old_ci}==${False}    ${item}/${common_release}[0]/${package_version}
        ...    ${if_common}==${False}    ${package_web_service}/${package_version}
        ${wget_suffix}    set variable if    ${if_common} and ${if_old_ci}==${False}    ${True}    ${False}
        ${if_package_exists_hz}    UUF_common.check_if_package_exists    ${package_download_dir_hz}
        Exit for loop if   ${if_package_exists_hz}
    END
    ${if_package_exists_espoo}    UUF_common.check_if_package_exists    ${package_download_dir}/${package_version}
    ${if_package_exists_espoo2}    run keyword if  not ${if_package_exists_espoo}    set variable   ${True}
    Set Suite Variable   ${package_path}   /home/ute/${package_name}
    ${file_exists}   Run Keyword and Return Status   OperatingSystem.File Should Exist   ${package_path}
    ${package_download_path}    run keyword if    ${if_package_exists_hz}    Set Variable   ${package_download_dir_hz}/${package_name}
    ...    ELSE IF    ${if_package_exists_espoo}    Set Variable   ${package_download_dir}/${package_version}/${package_name}
    ...    ELSE IF    ${if_package_exists_espoo2}    Set Variable   ${common_web_service2}/${common_release}[0]/${package_name}
    ...    ELSE    Fail    No package exists in hangzhou and espoo server
    run keyword if  not ${file_exists}   Log    \nPackage Do Not Exist, Start to Download Package From WFT!    WARN
    run keyword if  not ${file_exists}   Run   rm -f wget-log*
    ${wget_command}    set variable if    ${wget_suffix}
    ...    wget -b ${package_download_path} -P /home/ute --no-check-certificate
    ...    wget -b ${package_download_path} -P /home/ute
    run keyword if  not ${file_exists}   Run   ${wget_command}
    sleep    30s
    ${file_size}    run keyword if  not ${file_exists}   Run   ls -l /home/ute | grep ${package_name} | grep -v grep |awk '{print $5}'
    ${file_size_length}    Get Length    ${file_size}
    run keyword if    '${file_size_length}'=='0'    Fail    No package exists in hangzhou and espoo server
    run keyword if  not ${file_exists}   Wait Until Keyword Succeeds   2h   1m   taf_env.Wait Until wget process done
    ...   ${package_name}
    run keyword if  not ${file_exists}   OperatingSystem.File Should Exist   ${package_path}
    run keyword if  not ${file_exists}   Log To Console    Download Package Finished!
    run keyword if  ${if_common}   Run   mv ${package_path} /home/ute/${package_version}.zip
    ...   ELSE   Run   mv ${package_path} /home/ute/AirScale-${package_version}.zip
    run keyword if  ${if_common}   set suite variable  ${package_path}   /home/ute/${package_version}.zip
    ...   ELSE   set suite variable  ${package_path}   /home/ute/AirScale-${package_version}.zip
    [Return]   ${package_path}
    [Teardown]   Run Keyword If   $KEYWORD_STATUS == "FAIL"   Remove Unfinished Downloaded Packages   ${package_version}   ${package_name}

Download SW knife package to TAF VM
    [Arguments]   ${package_version}   ${package_name}
    Remove Unfinished Downloaded Packages   ${package_version}   ${package_name}
    ${package_download_dir}    Set Variable    ${knife_package_web_service}/${package_version}/${package_name}
    ${if_knife_package_exists}    UUF_common.check_if_package_exists    ${package_download_dir}
    Set Suite Variable   ${package_path}   /home/ute/${package_name}
    ${file_exists}   Run Keyword and Return Status   OperatingSystem.File Should Exist   ${package_path}
    Run Keyword if   ${if_knife_package_exists} and ${file_exists}==${False}
    ...   Log To Console   Knife Package Do Not Exist in TAF, Start to Download Package From WFT!
    ...   ELSE    Fail    Knife Package Do Not Exist in espoo1!Please upload knife to taf by maunal!
    run keyword if  not ${file_exists}   Run   rm -f wget-log*
    run keyword if  not ${file_exists}   Run   wget -b ${package_download_dir} -P /home/ute
    run keyword if  not ${file_exists}   Wait Until Keyword Succeeds   2h   1m   taf_env.Wait Until wget process done
    ...   ${package_name}
    run keyword if  not ${file_exists}   OperatingSystem.File Should Exist   ${package_path}
    run keyword if  not ${file_exists}   Log To Console    Download Package Finished!
    run keyword and ignore error   Run   mv ${package_path} /home/ute/AirScale-${package_version}.zip
    run keyword and ignore error   set suite variable  ${package_path}   /home/ute/AirScale-${package_version}.zip
    [Return]   ${package_path}
    [Teardown]   Run Keyword If   $KEYWORD_STATUS == "FAIL"   Remove Unfinished Downloaded Packages   ${package_version}   ${package_name}

Check if taget SW package exist
    [Arguments]    ${upgradetool}    ${version}
    run keyword if  ${upgradetool.count('netact')}>0   Check taget SW package exist in ${NMS_TYPE} server   version=${version}
    run keyword if  ${upgradetool.count('webui')}>0    Check taget SW package exist in taf server    version=${version}

Check taget SW package exist in taf server
    [Arguments]    ${version}
    ${package_release}   Catch build release  ${version}
    ${if_commonbuild}   run keyword and return status  should contain   ${package_release}   SBTS
    ${version_suffix}    run keyword if  not ${if_commonbuild}   Fetch From Right    ${version}    .
    ${check_version}   run keyword if  "${package_release}"=="5G20A"   set variable  1130
    ...   ELSE IF   "${package_release}"=="trunk"   set variable  2002
    ...   ELSE   set variable  0
    ${knife_status}   run keyword if   ${if_commonbuild}    set variable    ${False}
    ...   ELSE   run keyword and return status  should contain  ${version_suffix}  -
    ${package_name}   run keyword if   ${knife_status}   set variable   AirScale-${version}.zip
    ...   ELSE IF   ${if_commonbuild}   set variable   ${version}_release_BTSSM_downloadable_A54.zip
    ...   ELSE   set variable if  ${${version_suffix}}<${${check_version}}
    ...   AirScale-${version}_ASIK_ABIL.zip   AirScale-${version}.zip
    ${status}    run keyword if  ${if_commonbuild}
    ...   run keyword and return status   OperatingSystem.File Should Exist    /home/ute/${version}.zip
    ...   ELSE   run keyword and return status   OperatingSystem.File Should Exist    /home/ute/AirScale-${version}.zip
    run keyword if  ${status} == ${False} and ${knife_status}==${False}  Download SW package to TAF VM
    ...   package_version=${version}   package_name=${package_name}
    run keyword if  ${status} == ${False} and ${knife_status}   Download SW knife package to TAF VM
    ...   package_version=${version}   package_name=${package_name}

Check taget SW package exist in nom server
    [Arguments]   ${version}
    ${apigw_url}    ${user_mgmt_url}    ${password}    ${client_id}    Get Nom Uri and Password    ${nom_nodeip}
    ${nom_rf_secret}   nom.register_the_client
    ...   client_id=${client_id}
    ...   username=${nom_username}
    ...   password=${password}
    ...   apigw_uri=${apigw_url}
    nom.connect_to
    ...   user_mgmt_uri=${user_mgmt_url}
    ...   apigw_uri=${apigw_url}
    ...   client_id=${client_id}
    ...   client_secret=${nom_rf_secret}
    ...   port=443
    ...   username=${nom_username}
    ...   password=${password}
    ...   nom_version=nom_v1
    ...   secure=${True}
    ${package_list}    nom.get_sw_package_list    ne_type=MRBTS
    FOR   ${each_package_detail}   IN   @{package_list}
       ${status}    run keyword and return status    dictionary should contain value   ${each_package_detail}   ${upgrade_version}
       exit for loop if    ${status}
    END
    run keyword if  not ${status}    fail   msg=Target SW package doesn't exist in nom server!
    [Teardown]   nom.delete_the_client
    ...   client_id=${client_id}
    ...   username=${nom_username}
    ...   password=${password}
    ...   apigw_uri=${apigw_url}

Catch Realtime Log
    [Arguments]    ${operation}
    log to console  Catch Realtime Log
#    run keyword and ignore error   Start tcpdump gNB   file_name=tcpdump_anyport    timeout=1000000    alias=gnb   port=any
#    run keyword and ignore error   Start tcpdump gNB CPlane  cpif_dump    1000000    gnb    ${cpif_ip}
#    run keyword and ignore error   Start tcpdump gNB CPlane   cp16_dump    1000000    gnb    ${cp16_ip}
#    run keyword and ignore error   Start tcpdump gNB CPlane   cpcl_dump    1000000    gnb    ${cpcl_ip}
#    run keyword and ignore error   Start tcpdump gNB CPlane   cpnb_dump    1000000    gnb    ${cpnb_ip}
#    run keyword and ignore error   Start tcpdump SCTP gNB   file_name=tcpdump_sctp_etha01   timeout=1000000   alias=gnb   port=etha01
#    Start Tcpdump for RU   action=${operation}
    run keyword and ignore error   run keyword if  '${bts_id}' in @{made_log_BTS_ID}    Start MaDe log
    run keyword and ignore error   Catch All Abil Logs Real Time    num=${TEST_NAME}/${operation}
    run keyword and ignore error   Start tcpdump on ASIK and ABIL
#    run keyword and ignore error   Start tcpdump gNB   file_name=netact_swm_gnb_run   timeout=1000000    alias=gnb    port=fp0　

Save logs
    [Arguments]    ${folder}=1   ${middle_status}=False
    run keyword and ignore error    run keyword if   '${bts_id}' in @{enable_BTS_ID}    Enable ssh to RU
    Wait Until Keyword Succeeds   3 times   2 min    WEBEM Login   sbts=save_logs
    run keyword and ignore error    Screenshot for COAM     dir=${folder}   sbts=save_logs
    run keyword and ignore error    Get Alarm Sreenshot in COAM    dir=${folder}   sbts=save_logs
    run keyword and ignore error    Collect log for special 6450 case    dir=${folder}
#    run keyword and ignore error    Cat Conntrack File
#    run keyword and ignore error    Save collector logs   dir=${folder}
    run keyword if   '${middle_status}'=='False'
    ...   run keyword and ignore error    Stop And Download And Remove BTS LOG Collection On Gnb And Rus    dir=${folder}
    run keyword if   '${bts_id}' in @{DSS_monitor_ID}   run keyword and ignore error    Stop eNB TRS Tcpdump     dir=${folder}
    run keyword and ignore error   run keyword if  '${enodeb_status}'=='False' or '${bts_id}' in @{eNB_snapshot}  Save eNB Snapshot   dir=${folder}
    ${status}   run keyword and return status    wait until keyword succeeds    4x    5min    Collect Snapshot By Admin
    ...    ${LMP_ADDR}    ${folder}
    run keyword if  not ${status}   Log    collect gnb snapshot failed on ${LMP_ADDR}    WARN
#    run keyword and ignore error    Save Snapshot logs    dir=${folder}
    run keyword and ignore error    Run Keyword If   ${if_moran} or '${bts_id}' in @{Multi_BTS_ID}   Collect Snapshot By Admin
    ...   host=${Peer_WEBUI_ADDR}   spec_name=Slave   dir=${folder}
#    run keyword and ignore error    Save tcpdump logs    filedir=${folder}    tcpdump_folder=rom
#    ...    gnb_tcpdump_file=tcpdump_anyport    localname=run_tcpdump_anyport
#    run keyword and ignore error    Save tcpdump logs    filedir=${folder}    tcpdump_folder=ffs/stb
#    ...    gnb_tcpdump_file=tcpdump_anyport    localname=run_tcpdump_anyport
#    run keyword and ignore error    Stop Tcpdump in NetAct
#    run keyword and ignore error    Save tcpdump logs from NetAct   ${folder}    root    tcpdump_netact    tcpdump_netact
#    run keyword and ignore error    Save tcpdump logs    filedir=${folder}    tcpdump_folder=rom
#    ...    gnb_tcpdump_file=netact_swm_gnb    localname=run_netact_swm_gnb
#    run keyword and ignore error    Save tcpdump logs    filedir=${folder}    tcpdump_folder=rom
#    ...    gnb_tcpdump_file=netact_swm_gnb_run    localname=netact_swm_gnb_run_add
#    run keyword and ignore error    Save tcpdump logs    filedir=${folder}    tcpdump_folder=ffs/stb
#    ...    gnb_tcpdump_file=netact_swm_gnb    localname=stb_netact_swm_gnb
#    run keyword and ignore error    Save tcpdump logs    ${folder}    ffs/stb     cpif_dump    stb_cpif_dump
#    run keyword and ignore error    Save tcpdump logs    ${folder}    ffs/stb     cp16_dump    stb_cp16_dump
#    run keyword and ignore error    Save tcpdump logs    ${folder}    ffs/stb     cpnb_dump    stb_cpnb_dump
#    run keyword and ignore error    Save tcpdump logs    ${folder}    ffs/stb     cpcl_dump    stb_cpcl_dump
#    run keyword and ignore error    Save tcpdump logs    ${folder}    rom    cpif_dump    run_cpif_dump
#    run keyword and ignore error    Save tcpdump logs    ${folder}    rom    cp16_dump    run_cp16_dump
#    run keyword and ignore error    Save tcpdump logs    ${folder}    rom    cpnb_dump    run_cpnb_dump
#    run keyword and ignore error    Save tcpdump logs    ${folder}    rom    cpcl_dump    run_cpcl_dump
#    run keyword and ignore error    Save tcpdump logs    filedir=${folder}    tcpdump_folder=rom
#    ...    gnb_tcpdump_file=tcpdump_sctp_etha01    localname=run_tcpdump_sctp_etha01
#    run keyword and ignore error    Catch NetAct Log by Area   Log_Area=SWM    num=${folder}
#    run keyword and ignore error    Catch NetAct Log by Area   Log_Area=CM    num=${folder}
#    run keyword and ignore error    Catch NetAct Log by Area   Log_Area=FM    num=${folder}
#    run keyword and ignore error    Catch NetAct Log by Area   Log_Area=MEDIATION    num=${folder}
#    run keyword and ignore error    Catch NE3S Logs from gNB    num=${folder}
#    run keyword and ignore error    COAM Download OAM Log     dir=${folder}
#    run keyword and ignore error    COAM Delete OAM Log
#    run keyword and ignore error    Stop All Abil Logs Process
#    run keyword and ignore error    Collect ABIL Log     dir=${folder}
#    run keyword and ignore error    Save Tail RU Log by SSH    dir=${folder}
    run keyword and ignore error  run keyword if   '${bts_id}' in @{enable_BTS_ID}   Enable ssh to RU for ControlPC
    run keyword and ignore error    RU Log Collections   dir=${folder}
    Run Keyword If   '${bts_id}' in @{Multi_BTS_ID}   run keyword and ignore error    RU Log Collections   dir=${folder}   gnb_ip=${Peer_WEBUI_ADDR}
    run keyword and ignore error  run keyword if   ${enable_ssh_via_PC}==${True}   Stop ssh RU Script for all ControlPC
#    run keyword and ignore error    Stop And Download And Remove BTS LOG Collection On Gnb And Rus    dir=${folder}
    run keyword and ignore error    Screenshot for COAM     dir=${folder}   sbts=save_logs
#    run keyword and ignore error   run keyword if   '${input_btsname}' in @{eNB_snapshot}   Save eNB Snapshot   dir=${folder}
#    run keyword and ignore error   run keyword unless  ${enb_status}  Save eNB Snapshot   dir=${folder}
#    run keyword and ignore error   run keyword unless  ${enodeb_status}  Save eNB Snapshot   dir=${folder}
#    run keyword and ignore error  Save RU Tcpdump Through Local IP   dir=${folder}   filename=RU_tcpdump.pcap
    run keyword and ignore error   Save RUs Console Log    dir=${folder}
#    run keyword and ignore error   Stop tcpdump and Collect log    dir=${folder}
    run keyword and ignore error   run keyword if  '${enodeb_status}'=='False' or '${bts_id}' in @{eNB_snapshot}   Stop eNB Snapshot Process   20
    [Teardown]   WEBEM Logout   sbts=save_logs

Remove logs
    [Arguments]    ${savefolder}=1
    run keyword and ignore error  run keyword if   '${bts_id}' in @{enable_BTS_ID}   Stop ssh RU Script for all ControlPC
#    run keyword and ignore error    Remove tcpdump logs in gNB     tcpdump_folder=ffs/stb
#    run keyword and ignore error    Remove tcpdump logs in gNB     tcpdump_folder=rom
#    run keyword and ignore error    Remove tcpdump logs in gNB     tcpdump_folder=ffs/stb    gnb_tcpdump_file=cpif_dump
#    run keyword and ignore error    Remove tcpdump logs in gNB     tcpdump_folder=rom    gnb_tcpdump_file=cpif_dump
#    run keyword and ignore error    Remove tcpdump logs in gNB     tcpdump_folder=ffs/stb    gnb_tcpdump_file=cp16_dump
#    run keyword and ignore error    Remove tcpdump logs in gNB     tcpdump_folder=rom    gnb_tcpdump_file=cp16_dump
#    run keyword and ignore error    Remove tcpdump logs in gNB     tcpdump_folder=ffs/stb    gnb_tcpdump_file=cpnb_dump
#    run keyword and ignore error    Remove tcpdump logs in gNB     tcpdump_folder=rom    gnb_tcpdump_file=cpnb_dump
#    run keyword and ignore error    Remove tcpdump logs in gNB     tcpdump_folder=ffs/stb    gnb_tcpdump_file=cpcl_dump
#    run keyword and ignore error    Remove tcpdump logs in gNB     tcpdump_folder=rom    gnb_tcpdump_file=cpcl_dump
#    run keyword and ignore error    Remove tcpdump logs in gNB     tcpdump_folder=ffs/stb    gnb_tcpdump_file=netact_swm_gnb_run
#    run keyword and ignore error    Remove tcpdump logs in gNB     tcpdump_folder=rom    gnb_tcpdump_file=netact_swm_gnb_run
#    run keyword and ignore error    Remove tcpdump logs in gNB     tcpdump_folder=ffs/stb    gnb_tcpdump_file=tcpdump_sctp_etha01
#    run keyword and ignore error    Remove tcpdump logs in gNB     tcpdump_folder=rom    gnb_tcpdump_file=tcpdump_sctp_etha01
#    run keyword and ignore error    Remove tcpdump logs in gNB     tcpdump_folder=ffs/stb    gnb_tcpdump_file=tcpdump_anyport
#    run keyword and ignore error    Remove tcpdump logs in gNB     tcpdump_folder=rom    gnb_tcpdump_file=tcpdump_anyport
#    run keyword and ignore error    Stop Tcpdump in NetAct
#    run keyword and ignore error    Remove tcpdump logs in NetAct   tcpdump_netact
#    run keyword and ignore error    COAM Delete OAM Log
#    run keyword and ignore error    Remove Reatime ABIL Log    num=${savefolder}
    Stop And Remove BTS LOG Collection On Gnb And Rus
    run keyword and ignore error   Stop eNB TRS Tcpdump     dir=${folder}
#    run keyword and ignore error    Remove RU Tail log by SSH    num=${savefolder}
#    run keyword and ignore error    Remove RU Tcpdump Through Local IP   filename=RU_tcpdump.pcap

Remove Planned Space
     ${connection_asik}=  csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK
     ${Planned} =    csn.execute    command=cd /ffs/stb;ls -al | grep planned   timeout=300   connection=ASIK
     ${Status}   run keyword and return status   should contain   ${Planned}   planned
     run keyword if   ${Status}==True
     ...   csn.execute    command=mount -o rw,remount /ffs/stb;rm -rf /ffs/stb/planned   timeout=300   connection=ASIK
     [Teardown]   csn.disconnect    connection=ASIK

Save Snapshot logs
    [Arguments]    ${dir}=1   ${status}=before_recover
    log to console    Save Snapshot logs
    Create Directory    ${OUTPUT_DIR}/${dir}
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    set suite variable     ${snapshot_path}    ${OUTPUT_DIR}/${dir}/${status}_snapshot_${curr_data}.zip
    run keyword    Debug Catch snapshot COAM    snapshot_path=${snapshot_path}    http=${LMP_ADDR}

Check Extra Reset from Blackbox File
     [Arguments]  ${action}   ${host}=${asik_addr}
     csn.Connect to   hostname=${host}   username=${asik_username}   password=${asik_password}   alias=ASIK
     csn.force_reconnect    connection=ASIK
     ${blackbox}   csn.execute    command=cd /ffs/run/config/lifedata;cat blackbox   timeout=300   connection=ASIK
     @{blackbox_split} =   Split String   ${blackbox}     \r\n
     ${orngin_release}   Catch build release   ${origin_version}
     ${tartget_release}   Catch build release   ${upgrade_version}
     FOR   ${reset}   IN   @{Extra_Reset}
        ${status}   run keyword and return status   Should Not Contain   ${blackbox_split[-8]}    ${reset}    msg=Extra Reboot Happen
        @{black_result}   Split String   ${blackbox_split[-8]}   /ffs
        run keyword and ignore error  run keyword if  not ${status}   add json to file    blackbox    ${black_result[-1]}
     ...   ${OUTPUT_DIR}/execution_results.json    ${action}
        run keyword if  not ${status}   fail  msg=Unexpected gnb reset happen: ${black_result[-1]}
     END
     [Teardown]   csn.disconnect    connection=ASIK

Save tcpdump logs
    [Arguments]     ${filedir}    ${tcpdump_folder}   ${gnb_tcpdump_file}=temp    ${localname}=temp
    log to console    Save tcpdump logs
    wait until keyword succeeds    5 min    30 s
    ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    Create Directory     ${OUTPUT_DIR}/${filedir}
    gnb.Download tcpdump data   file_dir=${OUTPUT_DIR}/${filedir}   tcpdumfile=${tcpdump_folder}
    ...   gnb_tcpdump_file=${gnb_tcpdump_file}    local_name=${localname}
    [Teardown]    run keywords   run keyword if  '${tcpdump_folder}' == 'ffs/stb'
    ...    csn.execute    command=mount -o rw,remount /ffs/stb;rm /ffs/stb/${gnb_tcpdump_file}.pcap    connection=gnb
    ...   ELSE IF    '${tcpdump_folder}' == 'rom'
    ...    csn.execute    command=rm /rom/${gnb_tcpdump_file}.pcap    connection=gnb
    ...   AND   csn.Disconnect   connection=gnb

Save collector logs
    [Arguments]     ${dir}=1
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    Create Directory     ${OUTPUT_DIR}/${dir}
    wait until keyword succeeds    5 min    30 s
    ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.execute     command=cd /user/toor4nsn;./all_log_collector.sh -o all_log_collected_${curr_data}   connection=gnb
    sleep   50s
    csn.execute     command=cd /user/toor4nsn;tar -cvf all_log_collected_${curr_data}.tar all_log_collected_${curr_data}/   connection=gnb
    sleep  30s
    csn.Download File    remote_path=/user/toor4nsn/all_log_collected_${curr_data}.tar
    ...    local_path=${OUTPUT_DIR}/${dir}/all_log_collected_${curr_data}.tar   connection=gnb
#    csn.disconnect    connection=gnb
#    run process
#    ...sudo sshpass -p ${asik_password} scp -r ${asik_username}@${asik_addr}:/user/toor4nsn/all_log_collected_${curr_data}.tar ${OUTPUT_DIR}/${num}
#    ...     shell=yes
    sleep    20s
    [Teardown]    run keywords    csn.execute     command=rm -rf /user/toor4nsn/all_log_collected_${curr_data}   connection=gnb
    ...   AND   csn.execute     command=rm -f /user/toor4nsn/all_log_collected_${curr_data}.tar   connection=gnb
    ...   AND   sleep  10s
    ...   AND   csn.disconnect    connection=gnb

Remove Reatime ABIL Log
    [Arguments]    ${num}=1
    Stop All Abil Logs Process
    ${dir}    ${dir1}    Split String   ${num}   /
    ${dir_num}    Count Directories In Directory    ${OUTPUT_DIR}/${dir}
    run keyword if   ${dir_num}==${2}
    ...   Remove Directory    ${OUTPUT_DIR}/${num}    recursive=True
    ...   ELSE    Remove Directory    ${OUTPUT_DIR}/${dir}    recursive=True

Collect ABIL Log
    [Arguments]     ${dir}=1
    ${connection_asik}=  csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK
    run keyword and ignore error   csn.Execute    command=mkdir ABIL_LOG   connection=ASIK
    run keyword and ignore error   csn.Execute    command=bsh 1:0 cp /var/log/loner/loner.msg /ffs/run/config/toor4nsn/ABIL_LOG/   connection=ASIK
    run keyword and ignore error   csn.Execute    command=bsh 1:2 lococtl -tar /tmp/request    connection=ASIK
    sleep   15s
    run keyword and ignore error   csn.Execute    command=bget 1:2 /tmp/request.tgz /ffs/run/config/toor4nsn/ABIL_LOG/   connection=ASIK
    sleep   3s
    run keyword and ignore error   csn.Execute    command=cp /rom/startup_SLOADER.log /ffs/run/config/toor4nsn/ABIL_LOG/   connection=ASIK
    run keyword and ignore error   csn.Execute    command=cp /rom/startup_NLOADER.log /ffs/run/config/toor4nsn/ABIL_LOG/   connection=ASIK
    run keyword and ignore error   csn.Execute    command=cp /tftpboot/slot03/devC/bootlog.msg /ffs/run/config/toor4nsn/ABIL_LOG/bootlog03.msg
    ...   connection=ASIK
    run keyword and ignore error   csn.Execute    command=cp /ram/node_0xe001/lxc.cfg /ffs/run/config/toor4nsn/ABIL_LOG/lxc.cfg
    ...   connection=ASIK
    run keyword and ignore error   csn.Execute    command=cp /tftpboot/slot02/devC/bootlog.msg /ffs/run/config/toor4nsn/ABIL_LOG/bootlog02.msg
    ...   connection=ASIK
    run keyword and ignore error   csn.Execute    command=cp /tftpboot/slot01/devC/bootlog.msg /ffs/run/config/toor4nsn/ABIL_LOG/bootlog01.msg
    ...   connection=ASIK
    run keyword and ignore error   csn.Execute    command=cp /proc/net/nf_conntrack /ffs/run/config/toor4nsn/ABIL_LOG/nf_contrack
    ...   connection=ASIK
    run keyword and ignore error   csn.Execute    command=cd /tftpboot;tar -cvf slot.zip slot*   connection=ASIK
    run keyword and ignore error   csn.Execute    command=cp /tftpboot/slot.zip /ffs/run/config/toor4nsn/ABIL_LOG/   connection=ASIK
    run keyword and ignore error   csn.Execute    command=cd /tftpboot;rm -rf slot.zip   connection=ASIK
    run keyword and ignore error   csn.Execute    command=cd /user/toor4nsn;tar -cvf ABIL_LOG.tar ABIL_LOG/   connection=ASIK
    sleep   30s
    run keyword and ignore error   csn.Download File    remote_path=/user/toor4nsn/ABIL_LOG.tar
    ...    local_path=${OUTPUT_DIR}/${dir}/ABIL_LOG.tar   connection=ASIK
    run keyword and ignore error   csn.Execute    command=rm -rf /user/toor4nsn/ABIL_LOG   connection=ASIK
    run keyword and ignore error   csn.Execute    command=rm -rf /user/toor4nsn/ABIL_LOG.tar   connection=ASIK
    csn.disconnect    connection=ASIK

Start BTS LOG Collection On Gnb And Rus
    ${btslog_info}    btslog_handle.get_gnb_and_ru_control_pc_info
    log to console    \nStart BTS LOG Collection On Gnb And Rus
    FOR   ${value}   IN   @{btslog_info}
       continue for loop if   '${value['ctrl_addr']}'=='1.1.1.1'
       ${status}   run keyword and return status   Create Btslog log collection on remote machine for UUF   name=${value['btslog_name']}
    ...   btslog_path=/opt/btslog/btslog    btslog_launcher_path=/opt/btslog/btslog_launcher    log_dir=/tmp/
    ...   host=${value['ctrl_addr']}    user=${value['ctrl_username']}    password=${value['ctrl_password']}
       run keyword if  not ${status}   Log   start btslog collection failed on ${value['ctrl_addr']}   WARN
    END
    ${windows_ru_info}    btslog_handle.get_windows_ru_control_pc_info
    FOR   ${value}   IN   @{windows_ru_info}
       ${windows_status}   run keyword and return status   Start BTS LOG Collection In Windows PC
    ...    windows_host=${value['ctrl_addr']}    windows_user=${value['ctrl_username']}
    ...    windows_password=${value['ctrl_password']}
       run keyword if  not ${windows_status}   Log   start btslog failed on windows ${value['ctrl_addr']}   WARN
    END
    Run Keyword If   '${bts_id}' in @{Multi_BTS_ID}   log to console   Start BTS LOG Collection On SLAVE GNB
    run keyword and ignore error   Run Keyword If   '${bts_id}' in @{Multi_BTS_ID}   Create Btslog log collection on remote machine for UUF
    ...   name=enb_btslog_${SLAVE_GNB_DU['pc_addr']}    btslog_path=/opt/btslog/btslog    btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   log_dir=/tmp/    host=${SLAVE_GNB_DU['pc_addr']}    user=${SLAVE_GNB_DU['pc_username']}   password=${SLAVE_GNB_DU['pc_password']}
    log to console    Start BTS LOG Collection On ENB
    ${ENBs}    Remove Duplicates    ${ENBs}
    FOR   ${enb}   IN   @{ENBs}
        ${status_addr}    ${pc_addr}    run keyword and ignore error    Get From Dictionary    ${enb}    pc_addr
        continue for loop if   '${pc_addr}'=='1.1.1.1'
#        continue for loop if    '${status_addr}' != 'PASS'
        run keyword and ignore error    Create Btslog log collection on remote machine for UUF
        ...   name=enb_btslog_${enb['pc_addr']}    btslog_path=/opt/btslog/btslog    btslog_launcher_path=/opt/btslog/btslog_launcher
        ...   log_dir=/tmp/    host=${enb['pc_addr']}    user=${enb['pc_username']}   password=${enb['pc_password']}
    END

Stop And Download And Remove BTS LOG Collection On Gnb And Rus
    [Arguments]    ${dir}
    log to console    Stop And Download And Remove BTS LOG Collection On Gnb And Rus
    ${btslog_info}    btslog_handle.get_gnb_and_ru_control_pc_info
    FOR   ${value}   IN   @{btslog_info}
       continue for loop if   '${value['ctrl_addr']}'=='1.1.1.1'
       ${collect_status}   run keyword and return status   Collect_logs    names=${value['btslog_name']}
       run keyword if  not ${collect_status}   Log   Collect logs failed on ${value['ctrl_addr']}   WARN
       ${download_status}   run keyword and return status   Download Btslog To Log Path    dir=${dir}    TAF_ADDR=${value['ctrl_addr']}
    ...   TAF_USERNAME=${value['ctrl_username']}    TAF_PASSWORD=${value['ctrl_password']}
       run keyword if  not ${download_status}   Log   Download logs failed on ${value['ctrl_addr']}   WARN
       ${remove_status}   run keyword and return status   Remove Btslog From Temp Folder    TAF_ADDR=${value['ctrl_addr']}
    ...   TAF_USERNAME=${value['ctrl_username']}    TAF_PASSWORD=${value['ctrl_password']}
       run keyword if  not ${remove_status}   Log   Remove logs failed on ${value['ctrl_addr']}   WARN
    END
    ${windows_ru_info}    btslog_handle.get_windows_ru_control_pc_info
    FOR   ${value}   IN   @{windows_ru_info}
       ${stop_download_status}   run keyword and return status   Stop and Download Btslog In Windows PC
    ...   dir=${dir}   host=${value['ctrl_addr']}    user=${value['ctrl_username']}    password=${value['ctrl_password']}
       run keyword if  not ${stop_download_status}   Log   stop and download btslog failed on ${value['ctrl_addr']} WARN
    END
    Run Keyword If   '${bts_id}' in @{Multi_BTS_ID}  log to console    Stop And Download And Remove Consurrent Gnb Slave BTS LOG Collection
    run keyword and ignore error   run keyword if   '${bts_id}' in @{Multi_BTS_ID}   run keywords
    ...   Collect_logs    names=enb_btslog_${SLAVE_GNB_DU['pc_addr']}
    ...   AND   Download Btslog To Log Path    dir=${dir}    TAF_ADDR=${SLAVE_GNB_DU['pc_addr']}
    ...   TAF_USERNAME=${SLAVE_GNB_DU['pc_username']}    TAF_PASSWORD=${SLAVE_GNB_DU['pc_password']}
    ...   AND   Remove Btslog From Temp Folder    TAF_ADDR=${SLAVE_GNB_DU['pc_addr']}
    ...   TAF_USERNAME=${SLAVE_GNB_DU['pc_username']}    TAF_PASSWORD=${SLAVE_GNB_DU['pc_password']}
    log to console    Stop And Download And Remove Consurrent Enb BTS LOG Collection
    ${ENBs}    Remove Duplicates    ${ENBs}
    FOR   ${enb}   IN   @{ENBs}
        ${status_addr}    ${pc_addr}    run keyword and ignore error    Get From Dictionary    ${enb}    pc_addr
        continue for loop if   '${pc_addr}'=='1.1.1.1'
#        continue for loop if    '${status_addr}' != 'PASS'
        run keyword and ignore error   run keywords
        ...   Collect_logs    names=enb_btslog_${enb['pc_addr']}
        ...   AND   Download Btslog To Log Path    dir=${dir}    TAF_ADDR=${enb['pc_addr']}
        ...   TAF_USERNAME=${enb['pc_username']}    TAF_PASSWORD=${enb['pc_password']}
        ...   AND   Remove Btslog From Temp Folder    TAF_ADDR=${enb['pc_addr']}
        ...   TAF_USERNAME=${enb['pc_username']}    TAF_PASSWORD=${enb['pc_password']}
    END

Stop And Remove BTS LOG Collection On Gnb And Rus
    log to console    Stop And Remove BTS LOG Collection On Gnb And Rus
    ${btslog_info}    btslog_handle.get_gnb_and_ru_control_pc_info
    FOR   ${value}   IN   @{btslog_info}
       continue for loop if   '${value['ctrl_addr']}'=='1.1.1.1'
       ${collect_status}   run keyword and return status   Collect_logs    names=${value['btslog_name']}
       run keyword if  not ${collect_status}   Log   Collect logs failed on ${value['ctrl_addr']}   WARN
       ${download_status}   run keyword and return status   Remove Btslog From Temp Folder    TAF_ADDR=${value['ctrl_addr']}
    ...   TAF_USERNAME=${value['ctrl_username']}    TAF_PASSWORD=${value['ctrl_password']}
       run keyword if  not ${download_status}   Log   Remove logs failed on ${value['ctrl_addr']}   WARN
    END
    ${ENBs}    Remove Duplicates    ${ENBs}
    FOR   ${enb}   IN   @{ENBs}
        ${status_addr}    ${pc_addr}    run keyword and ignore error    Get From Dictionary    ${enb}    pc_addr
        continue for loop if   '${pc_addr}'=='1.1.1.1'
#        continue for loop if    '${status_addr}' != 'PASS'
        run keyword and ignore error   run keywords
        ...   Collect_logs    names=enb_btslog_${enb['pc_addr']}
        ...   AND   Remove Btslog From Temp Folder    TAF_ADDR=${enb['pc_addr']}
        ...   TAF_USERNAME=${enb['pc_username']}    TAF_PASSWORD=${enb['pc_password']}
    END

Download Btslog To Log Path
    [Arguments]   ${dir}   ${TAF_ADDR}   ${TAF_USERNAME}    ${TAF_PASSWORD}
    ${ip_filter}   Run   sudo ifconfig | grep ${TAF_ADDR}
    ${ip_exists}   Run Keyword and Return Status   Should Contain   ${ip_filter}   ${TAF_ADDR}
    Run Keyword If   ${ip_exists}   Run   cd /tmp/btslog2;tar -czvf ${OUTPUT_DIR}/${dir}/btslog_${TAF_ADDR}.tgz SYSLOG*
    ...   ELSE   Download Remote Btslog To Local   dir=${dir}   TAF_ADDR=${TAF_ADDR}   TAF_USERNAME=${TAF_USERNAME}    TAF_PASSWORD=${TAF_PASSWORD}

Download Remote Btslog To Local
    [Arguments]   ${dir}   ${TAF_ADDR}   ${TAF_USERNAME}    ${TAF_PASSWORD}
#    ${cmd_prefix}   Set Variable If   '${TAF_USERNAME}'=='root'   ${EMPTY}   sudo${SPACE}
    ${connection_asik}=  csn.connect_to    hostname=${TAF_ADDR}    username=${TAF_USERNAME}    password=${TAF_PASSWORD}    alias=taf
    run keyword and ignore error   csn.Execute    command=cd /tmp/btslog2;tar -czvf btslog_${TAF_ADDR}.tgz SYSLOG*   timeout=60   connection=taf
    run keyword and ignore error   csn.Download File    remote_path=/tmp/btslog2/btslog_${TAF_ADDR}.tgz
    ...    local_path=${OUTPUT_DIR}/${dir}/btslog_${TAF_ADDR}.tgz   connection=taf
    sleep   3s
    csn.disconnect    connection=taf

Check syslog
    ${taf_addr}     Set variable    ${tl.test_pc.default_ssh_connection_details.addr}
    ${taf_username}    Set variable    ${tl.test_pc.default_ssh_connection_details.username}
    ${taf_password}    Set variable    ${tl.test_pc.default_ssh_connection_details.password}
    ${taf_info_dict}    create dictionary    pc_addr=${taf_addr}    pc_username=${taf_username}    pc_password=${taf_password}
    ${ENBs}    Remove Duplicates    ${ENBs}
    Append To List    ${ENBs}    ${taf_info_dict}
    FOR  ${value}  IN  @{ENBs}
        ${status_addr}    ${pc_addr}    run keyword and ignore error    Get From Dictionary    ${value}    pc_addr
        ${status_username}    ${pc_username}    run keyword and ignore error    Get From Dictionary    ${value}    pc_username
        ${status_password}    ${pc_password}    run keyword and ignore error    Get From Dictionary    ${value}    pc_password
        continue for loop if   '${pc_addr}'=='1.1.1.1'
#        continue for loop if    '${status_addr}' != 'PASS'
        ${connection_asik}=  csn.connect_to    hostname=${pc_addr}    username=${pc_username}
        ...    password=${pc_password}    alias=taf
        ${offline_output}   RUN    cat /tmp/btslog2/SYSLOG*.LOG |grep 'CELL NOTIFICATION 4329 Radio memory consumption exceeds abnormal threshold'
        ${status1}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
        ${offline_output}   RUN    cat /tmp/btslog2/SYSLOG*.LOG |grep 'FaultId: 4329'
        ${status2}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
        ${offline_output}   RUN    cat /tmp/btslog2/SYSLOG*.LOG |grep 'FaultId: 4330'
        ${status3}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
        ${offline_output}   RUN    cat /tmp/btslog2/SYSLOG*.LOG |grep 'Detector 4329'
        ${status4}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
        ${offline_output}   RUN    cat /tmp/btslog2/SYSLOG*.LOG |grep 'Detector 4330'
        ${status5}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
        ${offline_output}   RUN    cat /tmp/btslog2/SYSLOG*.LOG |grep 'active 4329'
        ${status6}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
        ${offline_output}   RUN    cat /tmp/btslog2/SYSLOG*.LOG |grep 'active 4330'
        ${status7}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
        ${offline_output}   RUN    cat /tmp/btslog2/SYSLOG*.LOG |grep '4230 Radio memory consumption exceeds critical threshold'
        ${status8}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
        ${offline_output}   RUN    cat /tmp/btslog2/SYSLOG*.LOG |grep '\\-\\=\\-\\='
        ${status9}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
        ${command}    set variable    cat /tmp/btslog2/SYSLOG*.LOG |
        ${command}    set variable    ${command}grep 'Please contact the owner of' |
        ${command}    set variable    ${command}grep -v '/ffs/run/logs' |grep -v 'is not defined in SysinfoQuota.xml'
        ${offline_output}   RUN    ${command}
        ${status10}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
        csn.disconnect    connection=taf
        ${status_list}    create list    ${status1}    ${status2}    ${status3}    ${status4}    ${status5}    ${status6}
        ...    ${status7}    ${status8}    ${status9}    ${status10}
        run keyword and continue on failure    list should not contain value    ${status_list}    ${False}
    END

Remove Btslog From Temp Folder
    [Arguments]   ${TAF_ADDR}   ${TAF_USERNAME}    ${TAF_PASSWORD}
    ${connection_asik}=  csn.connect_to    hostname=${TAF_ADDR}    username=${TAF_USERNAME}    password=${TAF_PASSWORD}    alias=taf
    run keyword and ignore error   csn.Execute    command=rm -rf /tmp/btslog2/btslog_${TAF_ADDR}.tgz   timeout=60   connection=taf
    run keyword and ignore error   csn.Execute    command=ll /tmp/btslog2/;rm -rf /tmp/btslog2/SYSLOG*   timeout=60   connection=taf
    run keyword and ignore error   csn.Execute    command=rm -rf /tmp/btslog2/BTSLOG_TRACE*   timeout=60   connection=taf
    csn.disconnect    connection=taf

Collect RU Log via gNB
    [Arguments]   ${ru_info}   ${active_release}   ${download_dir}=${OUTPUT_DIR}
    ${ru_passwd}   UUF_common.get_ru_username_password   ru_type=${ru_info[1]['type']}   build_release=${active_release}
    ...   if_need_handle_dollar=${False}
    ${username}   ${password}   Run Keyword If   ${ru_passwd}   Set Variable   ${ru_passwd[0]['username']}   ${ru_passwd[0]['password']}
    ...   ELSE   Set Variable   root   ${EMPTY}

    ${container_id}   Get FHNET Container ID   asik_alias=${ru_info[1]['source']}
    Connect To RU Via FHNET Container   ru_ip_addr=${ru_info[1]['ip']}   ru_username=${username}   ru_password=${password}
    ...   container_id=${container_id}    ru_index=${ru_info[1]['index']}   asik_alias=${ru_info[1]['source']}
    ${sudo_cmd}   Set Variable If   $username=='root'   ${EMPTY}   sudo${SPACE}
    ${rfsw_log_path}    Set Variable    /ram/rfsw_log_${ru_info[0]}.zip
    csn.execute     cd /usr/bin;${sudo_cmd}ccsShell.sh log -a -z ${rfsw_log_path}    connection=RU
    Wait Until Keyword Succeeds   5m   5s   Check if remote file size not increased   file_path=${rfsw_log_path}   connection=RU
    ${RU_log_exists}   Run Keyword and Return Status   csn.Download File
    ...   remote_path=${rfsw_log_path}   local_path=${download_dir}/RULOG_${ru_info[0]}.zip   connection=RU
    [Return]   ${RU_log_exists}
    [Teardown]   Run keywords
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=RU   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=Container

Catch Detected RU Logs via System Module
    [Arguments]   ${detected_RUs}   ${not_connect_RUs}   ${ru_index_list}   ${is_dual_core}=${False}   ${download_dir}=${OUTPUT_DIR}
    ...   ${login_ip}=${asik_addr}
    ${ip}   set variable if   '${bts_id}' in @{Multi_BTS_ID}   ${peer_asik_addr}  ${LMP_ADDR}
    ${active}  ${passive}   Get gNB SW version    format=full   ip=${ip}
    ${active_release}   Fetch From Left    ${active}   _
    csn.Connect to   hostname=${login_ip}   username=${asik_username}   password=${asik_password}   alias=gNB
    # Run Keyword And Ignore Error   csn.Execute   command=rm -rf /user/toor4nsn/.ssh/known_hosts   connection=gNB   timeout=60

    ${gnb_left}    Run Keyword If   ${is_dual_core}   If GNB In Left Side    connection=gNB
    ${hostname}   Set Variable If   ${gnb_left}   fct-4a   fct-0a
    Run Keyword If   ${is_dual_core}
    ...   csn.Connect to   hostname=${hostname}   username=${asik_username}   password=${asik_password}   proxy=gNB   alias=dual
    # Run Keyword If   ${is_dual_core}
    # ...   Run Keyword And Ignore Error   csn.Execute   command=rm -rf /user/toor4nsn/.ssh/known_hosts   connection=dual   timeout=60
    COAM Login   alias=GNB_OAM   bts_host=${login_ip}
    FOR   ${ru_info}   IN   @{detected_RUs.items()}
        Run Keyword And Ignore Error   csn.Execute
        ...   command=ssh-keygen -f "/user/toor4nsn/.ssh/known_hosts" -R ${ru_info[1]['ip']}
        ...   connection=${ru_info[1]['source']}
        ...   timeout=60
        ${RU_log_exists}   Collect RU Log via gNB   ru_info=${ru_info}   active_release=${active_release}
        ...   download_dir=${download_dir}
        ${not_connect_RUs}   Run Keyword If   ${RU_log_exists}   Set Variable   ${not_connect_RUs}
        ...   ELSE   Append Not Detected RU Index
        ...   ru_index=${ru_info[1]['index']}   ru_index_list=${ru_index_list}   disconnect_list=${not_connect_RUs}
    END
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Run Keyword If   ${is_dual_core}   csn.Disconnect   connection=dual   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=gNB   AND
    ...   Run Keyword And Ignore Error   COAM Logout   connection=GNB_OAM

RU Log Collections
    [Arguments]   ${dir}   ${gnb_ip}=${WEBUI_ADDR}
    COAM Login   bts_host=${gnb_ip}
    ${smod_list}   coam.get_fsm_info   connection=COAM
    ${is_dual_core}   Set Variable If   len(${smod_list}) > 1   ${True}   ${False}
    ${detected_RUs}   Get gNB detected RUs   is_dual_core=${is_dual_core}   login_ip=${gnb_ip}
    ${detected_RUs}   ${not_connect_RUs}   ${ru_index_list}   Get not detected RU index   detected_RUs=${detected_RUs}
    Catch Detected RU Logs via System Module   detected_RUs=${detected_RUs}   download_dir=${OUTPUT_DIR}/${dir}
    ...   ru_index_list=${ru_index_list}   not_connect_RUs=${not_connect_RUs}   is_dual_core=${is_dual_core}   login_ip=${gnb_ip}
    ${local_required_RUs}   Create List
    ${local_RU_count}   Get Length   ${rus}
    FOR   ${index}   IN    @{not_connect_RUs}
       Run Keyword If   ${index} <= ${local_RU_count}   Append To List   ${local_required_RUs}    ${rus[${index}]}
    END
    Catch RU Log Through Local IP   dir=${dir}   ru_list=${local_required_RUs}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout

Catch RU Log Through Local IP
    [Arguments]   ${dir}   ${ru_list}=${rus}
    ${ip}   set variable if   '${bts_id}' in @{Multi_BTS_ID}   ${peer_asik_addr}  ${LMP_ADDR}
    ${active}  ${passive}   Get gNB SW version    format=full   ip=${ip}
    ${active_release}   Fetch From Left    ${active}   _
    FOR   ${value}   IN   @{ru_list}
       set suite variable  ${TAF_ADDR}   ${value['ctrl_addr']}
       set suite variable  ${TAF_USERNAME}   ${value['ctrl_username']}
       set suite variable  ${TAF_PASSWORD}   ${value['ctrl_password']}
       set suite variable  ${RU_ADDR}   ${value['addr']}
       set suite variable  ${RU_TYPE}   ${value['ru_type']}
       continue for loop if    '${TAF_ADDR}'=='1.1.1.1'
       ${local_connected}   Try RU connected by local   RU_ADDR=${RU_ADDR}
       ...   TAF_ADDR=${TAF_ADDR}   TAF_USERNAME=${TAF_USERNAME}   TAF_PASSWORD=${TAF_PASSWORD}
       Run Keyword If   ${local_connected}   Catch RU Log and RU space Through Local IP Separately
       ...   TAF_ADDR=${TAF_ADDR}   TAF_USERNAME=${TAF_USERNAME}   TAF_PASSWORD=${TAF_PASSWORD}
       ...   dir=${dir}   release=${active_release}   RU_ADDR=${RU_ADDR}   RU_TYPE=${RU_TYPE}
    END

Try RU connected by local
    [Arguments]   ${RU_ADDR}   ${TAF_ADDR}   ${TAF_USERNAME}   ${TAF_PASSWORD}
    ${taf_connected}   Run Keyword and Return Status   csn.Connect to
    ...   ${TAF_ADDR}   ${TAF_USERNAME}   ${TAF_PASSWORD}   alias=RU_TRY
    run keyword if  not ${taf_connected}   Run Keywords   Log   RU PC ${TAF_ADDR} unreachable   WARN
    ...   AND   Return From Keyword   ${taf_connected}
    ${ru_reply}   csn.Execute   ping -c 3 ${RU_ADDR}   connection=RU_TRY
    Run Keyword If   ${ru_reply.count('100% packet loss')} > 0
    ...   Log   Local RU ${RU_ADDR} in TAF ${TAF_ADDR} unreachable   WARN
    Return From Keyword If   ${ru_reply.count('100% packet loss')} > 0   ${False}
    Run Keyword If   $TAF_USERNAME == 'root'   csn.Execute   rm -f /root/.ssh/known_hosts   connection=RU_TRY
    ...   ELSE   csn.Execute   rm -f /home/${TAF_USERNAME}/.ssh/known_hosts   connection=RU_TRY
    [Return]   ${True}
    [Teardown]   Run Keyword If   ${taf_connected}   csn.Disconnect   connection=RU_TRY

Catch RU Log and RU space Through Local IP Separately
    [Timeout]   10m
    [Arguments]   ${RU_ADDR}   ${RU_TYPE}    ${TAF_ADDR}   ${TAF_USERNAME}   ${TAF_PASSWORD}   ${dir}    ${release}
    ${connection_ru}   ${connection_taf}   UUF_common.connet_to_ru   ${TAF_ADDR}   ${TAF_USERNAME}
    ...   ${TAF_PASSWORD}   ${RU_ADDR}   ${RU_TYPE}    ${release}
    ${remote_path}   Set Variable   /ram/RULOG_${TAF_ADDR}.tar
    csn.execute   command=ccsShell.sh log -a -c full -z RULOG_${TAF_ADDR}.tar   timeout=600   connection=${connection_ru}
    Wait Until Keyword Succeeds   5m   5s   Check if remote file size not increased
    ...   file_path=${remote_path}   connection=${connection_ru}
    run keyword and ignore error   csn.Download File    remote_path=${remote_path}
    ...    local_path=${OUTPUT_DIR}/${dir}/RULOG_${TAF_ADDR}.tar   timeout=300   connection=${connection_ru}
    run keyword and ignore error   csn.execute   command=rm -rf ${remote_path}  connection=${connection_ru}
    log to console    check ru space and runtime
    ${ru_space_info}   csn.Execute   df -h   timeout=300   connection=${connection_ru}
    @{ru_space_split} =   Split String   ${ru_space_info}     \r\n
    ${runtime_info}   csn.Execute   ls -al /mnt/runtime   timeout=300   connection=${connection_ru}
    @{runtime_split} =   Split String   ${runtime_info}     \r\n
    ${tree_info}   csn.Execute   tree /mnt/runtime   timeout=300   connection=${connection_ru}
    [Teardown]   UUF_common.disconnect_ru   ${connection_taf}   ${connection_ru}

Check made power
    log to console    start to check made power
#    ${power_status_list}   create list
    ${keyword_status}    run keyword and ignore error    run keyword if   '${bts_id}' in @{enable_BTS_ID}
    ...   Enable LMI on RU via System Module
    ${active}  ${passive}   Get gNB SW version    format=full
    ${active_release}   Fetch From Left    ${active}   _
    FOR   ${value}   IN   @{rus}
       ${TAF_ADDR}   set variable  ${value['ctrl_addr']}
       ${TAF_USERNAME}   set variable  ${value['ctrl_username']}
       ${TAF_PASSWORD}   set variable  ${value['ctrl_password']}
       ${RU_ADDR}   set variable  ${value['addr']}
       ${RU_TYPE}   set variable  ${value['ru_type']}
       ${is_made2_ru}      Run Keyword and Return Status   list should contain value   ${made2_ru}   ${RU_TYPE}
       ${pc_reachable}   run keyword and return status    Validate IP Reachability from Test PC
       ...   ip_addr=${TAF_ADDR}   exp_status=${True}
       Continue For Loop If   '${TAF_ADDR}' == '1.1.1.1' or '${is_made2_ru}' == '${False}' or '${pc_reachable}'=='${False}'
       ${power_status}   ${output}   run keyword and continue on failure   UUF_common.check_made_power   ${TAF_ADDR}   ${TAF_USERNAME}
       ...   ${TAF_PASSWORD}   ${RU_ADDR}   ${RU_TYPE}    ${active_release}
       log to console    \n ${value['ru_type']} Power status: ${power_status}
#       append to list  ${power_status_list}   ${power_status}
#       run keyword and ignore error  add json to file   power_status   ${power_status_list}
#       ...   ${OUTPUT_DIR}/execution_results.json   upgrade
       should contain   ${power_status}   power normal   RU power is abnormal!
    END

Catch All Abil Logs Real Time
    [Arguments]   ${num}   ${enable_a_log}=${true}   ${enable_c_log}=${true}
    Create Directory    ${OUTPUT_DIR}/${num}
    Run Keyword If   ${enable_a_log}   Catch Abil Logs By IP Ending   log_dir=${OUTPUT_DIR}/${num}   ending_list=${abil_a_addr_list}
    Run Keyword If   ${enable_c_log}   Catch Abil Logs By IP Ending   log_dir=${OUTPUT_DIR}/${num}   ending_list=${abil_c_addr_list}


Catch Abil Logs By IP Ending
    [Arguments]   ${log_dir}   ${ending_list}
    FOR   ${ip_ending}   IN   @{ending_list}
       ${unit_exist}   Unit IP reachable   host=${LMP_ADDR}   username=${asik_username}
    ...   password=${asik_password}  ip_addr=192.168.253.${ip_ending}
       Run Keyword If   ${unit_exist}   Start Abil log collection   log_file_dir=${log_dir}   ip_ending=${ip_ending}   alias=abil_${ip_ending}
       Run Keyword If   ${unit_exist}   Append To List   ${exist_abil_log_process}   abil_${ip_ending}
    END

Stop All Abil Logs Process
    FOR   ${process_alias}   IN   @{exist_abil_log_process}
       Stop Abil log collection   alias=${process_alias}
       Remove From List   ${exist_abil_log_process}   0
    END
    Log   ${exist_abil_log_process}

Catch SWM Logs from NetAct
    [Arguments]    ${node_ip}   ${username}   ${password}   ${Log_Area}   ${num}=1
    ${connection_NetAct}    csn.connect_to   hostname=${node_ip}   username=${username}   password=${password}   alias=NetAct_WASnode
    ${NetAct_logs}    set variable    ${NetAct_LOGS['${Log_Area}']}
    FOR    ${item}    IN    @{NetAct_logs}
        Download Log to TAF from NetAct    log=${item}    alias=${connection_NetAct}    num=${num}
    END
    [Teardown]    csn.disconnect    connection=${connection_NetAct}

Catch NetAct Log by Area
    [Arguments]    ${Log_Area}   ${num}=1
    ${connection_NetAct}    csn.connect_to   hostname=${netact_nodeip}   username=${netact_account}
    ...   password=${netact_pwd}   alias=netact
    ${netact_mediation_node}   Run Keyword If   '${Log_Area}'=='MEDIATION'   Get NetAct Node by Area
    ...   area=mediation   alias=netact
    ${connection_Mediation}   Run Keyword If   '${Log_Area}'=='MEDIATION'  csn.connect_to   hostname=${netact_mediation_node}
    ...   username=root   password=arthur   alias=mediation_node   proxy=netact
    ${connection_log_node}  Set Variable If   '${Log_Area}'=='MEDIATION'   ${connection_Mediation}   ${connection_NetAct}
    ${NetAct_logs}    set variable   ${NetAct_LOGS['${Log_Area}']}
    FOR    ${item}    IN    @{NetAct_logs}
        Download Log to TAF from NetAct    log=${item}    alias=${connection_log_node}    num=${num}
    END
    [Teardown]    run keywords  run keyword if   '${Log_Area}'=='MEDIATION'   csn.disconnect    connection=${connection_Mediation}
    ...   AND   csn.disconnect    connection=${connection_NetAct}

Get NetAct Node by Area
    [Arguments]    ${area}=mediation    ${alias}=netact
    ${connection}    csn.get_connection_by_alias    alias=${alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Sleep  2
    Call Method    ${channel}    send    ssh root@${netact_nodeip}\n
    Sleep  2
    Call Method    ${channel}    send    arthur\n
    sleep   2
    Call Method    ${channel}    recv    ${65535}
    sleep  2
    Call Method    ${channel}    send    smanager.pl status service ${area}\n
    sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${status}    Run Keyword And Return Status    Should Not Be Empty    ${output}
    ${mediation_vm_node}    run keyword if    ${status}    set variable    ${output.split(':')[1]}
    [Return]   ${mediation_vm_node}

Catch NE3S Logs from gNB
    [Arguments]    ${num}=1   ${download_path}=${OUTPUTDIR}/
    ${connection_asik}   wait until keyword succeeds    15 min    30 s
    ...   csn.Connect To   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    FOR    ${log}    IN    @{NE3S_LOGS}
        ${fold_name}    set variable    ${log.split('/')[-1]}
        ${ffs_name}    set variable    ${log.split('/')[2]}
        ${fold_name_download}    set variable    ${ffs_name}_${fold_name}
        csn.Execute    command=tar -cvPf /tmp/${fold_name_download}.tar ${log}   connection=${connection_asik}
        ${current_date}    DateTime.Get Current Date
        ${date_str}    DateTime.Convert Date    ${current_date}    %Y%m%d%H%M
        csn.download_file    remote_path=/tmp/${fold_name_download}.tar
    ...   local_path=${download_path}${num}/ne3s_gnb_${date_str}_${fold_name_download}.tar    connection=${connection_asik}
        csn.execute   command=rm -rf /tmp/${fold_name_download}.tar  connection=${connection_asik}
    END
    [Teardown]    csn.disconnect    connection=${connection_asik}

Download Log to TAF from NetAct
    [Arguments]    ${log}    ${alias}    ${num}=1   ${download_path}=${OUTPUTDIR}/
    ${all_log}    csn.Execute    command=ls -lt ${log}    connection=${alias}
    ${status}    run keyword and return status    should contain    ${log}    *
    ${log_reg}    run keyword if    ${status}    set variable    ${log.split('/')[-1].split('*')[0]}
    ...    ELSE    set variable    ${log.split('/')[-1].split('.')[0]}
    ${log_path}    Remove String Using Regexp    ${log}    ${log_reg}.*.log
    ${log_name}    should match regexp    ${all_log}    ${log_reg}.*.log
    ${current_date}    DateTime.Get Current Date
    ${DATE_STR}    DateTime.Convert Date    ${current_date}    %Y%m%d%H%M
    csn.download_file    remote_path=${log_path}${log_name}    local_path=${download_path}${num}/NetAct_${DATE_STR}_${log_name}
    ...   connection=${alias}

Upload TAF Log to FTP Server
    ${output_res_log}   Set Variable   /home/ute/upload.log
    ${file_exists}   Run Keyword and Return Status   File Should Exist   ${output_res_log}
    run keyword if  not ${file_exists}   Run   touch ${output_res_log}
    Run   python ${CURDIR}/../Scripts/upload_logs_to_server.py upload ${OUTPUT_DIR}/ ${bts_Id}
    #nohup python ${CURDIR}/../Scripts/upload_logs_to_server.py ${OUTPUT_DIR}/ ${bts_Id} >${output_res_log} 2>&1 &

Get SCF Param
    [Arguments]     ${SCF_path}=${CURDIR}/SCF_BACKUP.xml
    ${input_btsname}    XML.Get Element Attribute    ${SCF_path}    distName    xpath=cmData/managedObject[@class="com.nokia.srbts:MRBTS"]
    Set Suite Variable    ${input_btsname}
    ${cellnum}    XML.Get Element Count    ${SCF_path}    xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    Set Suite Variable    ${cellnum}
    ${fbbnum}    XML.Get Element Count    ${SCF_path}    xpath=cmData/managedObject[@class="com.nokia.srbts.eqm:BBMOD"]
    Set Suite Variable    ${fbbnum}
    ${fsmnum}    XML.Get Element Count    ${SCF_path}    xpath=cmData/managedObject[@class="com.nokia.srbts.eqm:SMOD"]
    Set Suite Variable    ${fsmnum}
    ${frmnum}    XML.Get Element Count    ${SCF_path}    xpath=cmData/managedObject[@class="com.nokia.srbts.eqm:RMOD"]
    Set Suite Variable    ${frmnum}
    ${tlsnum}    XML.Get Element Count    ${SCF_path}    xpath=cmData/managedObject/p[@name="oamTls"]
    Set Suite Variable    ${tlsnum}
    ${oamtls_value}    run keyword if    ${tlsnum}==${1}
    ...    XML.Get Element Text   ${SCF_path}   xpath=cmData/managedObject/p[@name="oamTls"]
    Set Suite Variable    ${oamtls_value}
#    ${cellDepType}   XML.Get Elements Texts   ${SCF_path}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]/p[@name="cellDepType"]
#    Set Suite Variable   ${cellDepType}
    ${cellDepType}   XML.Get Elements Texts   ${SCF_path}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]/p[@name="gNbCuType"]
    Set Suite Variable   ${cellDepType}
    ${syncInputType}   XML.Get Elements Texts   ${SCF_path}
    ...   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:CLOCK"]/list/item/p[@name="syncInputType"]
    Set Suite Variable   ${syncInputType}
    ${EQM}    XML.Get Element Attribute    ${SCF_path}    distName    xpath=cmData/managedObject[@class="com.nokia.srbts.eqm:EQM"]
    ${EQM_num}    String.Fetch From Right    ${EQM}    -
    Set Suite Variable    ${EQM_num}    ${EQM_num.strip()}
    ${HWTOP}    XML.Get Element Attribute    ${SCF_path}    distName    xpath=cmData/managedObject[@class="com.nokia.srbts.eqm:HWTOP"]
    ${HWTOP_num}    String.Fetch From Right    ${HWTOP}    -
    Set Suite Variable    ${HWTOP_num}    ${HWTOP_num.strip()}
    ${MNL}    XML.Get Element Attribute    ${SCF_path}    distName    xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:MNL"]
    ${MNL_num}    String.Fetch From Right    ${MNL}    -
    Set Suite Variable    ${MNL_num}    ${MNL_num.strip()}
    ${MNLENT}    XML.Get Element Attribute    ${SCF_path}    distName    xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:MNLENT"]
    ${MNLENT_num}    String.Fetch From Right    ${MNLENT}    -
    Set Suite Variable    ${MNLENT_num}    ${MNLENT_num.strip()}
    ${FEATCADM}    XML.Get Element Attribute    ${SCF_path}    distName    xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:FEATCADM"]
    ${FEATCADM_num}    String.Fetch From Right    ${FEATCADM}    -
    Set Suite Variable    ${FEATCADM_num}    ${FEATCADM_num.strip()}

Check Gnb Version
    [Arguments]    ${disk}=run
    run    rm /home/ute/TargetBD_5G19*
    wait until keyword succeeds    15 min    30 s
    ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    ${versionfile}    csn.execute    command=cd /ffs/${disk};ls | grep TargetBD_5G19*.xml    connection=gnb
    ${version}    run keyword if  ${versionfile.count('TargetBD_5G19')}>0     _Get_version_format    ${versionfile}    ${disk}
    ...   ELSE     set variable     -
    [Return]    ${version}
    [Teardown]    csn.disconnect    connection=gnb

_Get_version_format
    [Arguments]     ${versionfile}    ${disk}
    ${versionfile}    Fetch From Left    ${versionfile}    \r
    ${knifestring}    Knife_Version_String_Handle    ${versionfile}
    csn.Download File    remote_path=/ffs/${disk}/${versionfile}    local_path=/home/ute/${versionfile}   connection=gnb
    ${version}         run         tac /home/ute/${versionfile} | grep -o "[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+"
    ${version}    Fetch From Right    ${version}    \n
    ${version}     set variable     ${version}${knifestring}
    [Return]    ${version}

Knife_Version_String_Handle
    [Arguments]    ${versionfile}
    ${knifestring}    Fetch From Left    ${versionfile}    .xml
    ${knifestring}    Remove String Using Regexp    ${knifestring}    \\S+\\d+_
    ${status}    run keyword and return status      Should Match Regexp    ${knifestring}    ^\\d+$
    ${knifestring}    run keyword if  ${status}    set variable    ${empty}
    ...   ELSE    set variable    _${knifestring}
    [Return]     ${knifestring}

Delete Code and Log from TAF
    log to console   Start Delete Code and Log from TAF
    ${connection_asik}=  csn.connect_to    hostname=${TESTPC_ADDR}    username=${TESTPC_user}    password=${TESTPC_pwd}    alias=taf
    FOR   ${log_Path}   IN   @{log_Path_List}
       run keyword and ignore error   csn.Execute
       ...   command=find ${log_Path} -mtime +4 -type f -delete  connection=taf
       run keyword and ignore error   csn.Execute
       ...   command=find ${log_Path} -mtime +4 -type l -delete  connection=taf
       run keyword and ignore error   csn.Execute
       ...   command=find ${log_Path} -type d -empty -delete  connection=taf
    END
    log to console   Delete Code and Log from TAF Done
    [Teardown]   csn.Disconnect   connection=taf

Delete Log from FTP Within Five Days
     ${dele_status}      Run Keyword and Return Status   should be equal    ${MRBTS_ID}    ${upload_log_id}
     run keyword if    ${dele_status}    Delete Log from FTP

Delete Log from FTP
    ${connection_ftp}=  csn.connect_to    hostname=${ftp_server}    username=ute    password=iW_K#8.ute%A10h0m0ra    alias=ftp
#    run keyword and ignore error   csn.Execute      command=sudo -i   connection=ftp
    run keyword and ignore error   csn.Execute
    ...   command=sudo find /home/ute/UUF_LOG/ -mtime +4 -type f -delete  connection=ftp
    run keyword and ignore error   csn.Execute
    ...   command=sudo find /home/ute/UUF_LOG/ -mtime +4 -type l -delete  connection=ftp
    run keyword and ignore error   csn.Execute
    ...   command=sudo find /home/ute/UUF_LOG/ -type d -empty -delete  connection=ftp
#    :FOR   ${log_Path}   IN   @{log_Path_List}
#       run keyword and ignore error   csn.Execute
#       ...   command=find /home/ute/UUF_LOG${log_Path} -mtime +4 -type f -delete  connection=ftp
#       run keyword and ignore error   csn.Execute
#       ...   command=find /home/ute/UUF_LOG${log_Path} -mtime +4 -type l -delete  connection=ftp
#       run keyword and ignore error   csn.Execute
#       ...   command=find /home/ute/UUF_LOG${log_Path} -type d -empty -delete  connection=ftp
#    END
    log to console   Delete Log from FTP Done
    [Teardown]   csn.Disconnect   connection=ftp

Get OAM Type From gNB
    [Arguments]  ${version}
#    ${release}   set variable  ${version.split('.')[0]}.${version.split('.')[1]}
    ${release}   Catch build release   ${version}
    ${OAM_type}    set variable    COAM
    [Return]  ${OAM_type}

Check Cell Setup from Site
     log to console    Check Cell Setup from Site
     FOR     ${number}    IN RANGE    ${40}
          ${status}    run keyword and return status    Check Cell Setup from Site COAM and MZOAM
          Exit For Loop If    ${status}
          sleep   30s
     END
     run keyword if  not ${status}    FAIL    [ERROR]cell not ready exceed 20 min!
     [Teardown]   gnb_handler.logout   connection=gnb

Check Cell Setup from Site COAM and MZOAM
     gnb_handler.login   ip=${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   gnb_type=coam   connection=gnb
     common.Get Cell Status Coam
     [Teardown]   gnb_handler.logout   connection=gnb

Check Site Status After Upgrade or Rollback
    [Arguments]  ${ip}=${WEBUI_ADDR}    ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
    Coam Check Site Status    ip=${ip}    username=${username}    password=${password}

Coam Check Site Status
     [Arguments]  ${if_ignore_cablink}=${True}    ${ip}=${WEBUI_ADDR}    ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
     Log To Console  Coam Check Site Status
     gnb_handler.login   ip=${ip}   username=${username}   password=${password}   gnb_type=coam   connection=gnb
     run keyword and continue on failure    Check ASIK Status Coam
     run keyword and continue on failure    Check ABIL Status Coam
     run keyword and continue on failure    Check RU Status Coam
     run keyword if    ${if_ignore_cablink}==${True}    run keyword and ignore error    Check Cablink Status Coam
     ...    ELSE     Check Cablink Status Coam
     run keyword and continue on failure    common.Get Cell Status Coam
     [Teardown]   run keyword and ignore error  gnb_handler.logout   connection=gnb

Check if Unexpected Active Alarm Exist and Set Stop Flag
     [Arguments]  ${action}=None   ${web_ip}=${WEBUI_ADDR}   ${bts_id}=${MRBTS_ID}   ${position}=${EMPTY}
     ...   ${stop_with_trunk_roll_fault}=False    ${if_enb}=False
     ${mplane_disable}      Run Keyword and Return Status   gnb_handler.login   ip=${web_ip}   username=${WEBUI_USER}
     ...    password=${WEBUI_PASSWORD}   gnb_type=coam   connection=gnb
     ${fault_should_ignore}    set variable if    ${if_enb}    ${eNB_Ignore_Fault}    ${Ignore_Fault}
     @{return_active_alarm}   gnb_handler.get_active_alarms   connection=gnb   except_alarms=${fault_should_ignore}
     ${fault_exist}   UUF_common.find_value_in_list   check_list=@{return_active_alarm}   check_key=faultId   check_value_list=${Stop_Fault_ID}
     ${bts_id}   convert to string   ${bts_id}
     ${is_stop_bts}      Run Keyword and Return Status   list should contain value   ${Stop_BTS_ID}   ${bts_id}
     ${trunk_roll_fault}   Create List   10    1806    4341    4352    4383    4085
     ${trunk_roll_fault_exist}   UUF_common.find_value_in_list   check_list=@{return_active_alarm}
     ...    check_key=faultId   check_value_list=${trunk_roll_fault}
     set suite variable    ${trunk_roll_fault_exist}
     run keyword if    '${stop_with_trunk_roll_fault}'=='True' and '${mplane_disable}'=='False'    set suite variable    ${stop_flag}   1
     ...    ELSE IF        ${trunk_roll_fault_exist} and '${stop_with_trunk_roll_fault}'=='True'    set suite variable    ${stop_flag}   1
     ...    ELSE IF    ${fault_exist} and ${is_stop_bts}    set suite variable    ${stop_flag}   1
     run keyword if   ${stop_flag}==1   log to console   stop flag is set to 1\n
     ${enb_alarm}    Run Keyword If    ${if_enb}    get json from file    eNB_active_alarm    ${OUTPUT_DIR}/execution_results.json    ${action}
     Run Keyword If    ${if_enb}    Set To Dictionary    ${enb_alarm}    ${web_ip}    ${return_active_alarm}
     ${json_name}    set variable if    ${if_enb}    eNB_active_alarm    active_alarm${position}
     ${json_value}    set variable if    ${if_enb}    ${enb_alarm}    ${return_active_alarm}
     run keyword and ignore error  add json to file    ${json_name}
     ...    ${json_value}    ${OUTPUT_DIR}/execution_results.json    ${action}
     Run Keyword If    ${return_active_alarm}!=[]
     ...   FAIL    [ERROR] Active Alarm: ${return_active_alarm}
     [Teardown]  gnb_handler.logout   connection=gnb

Check X2 Link Status
    WebEM Login
    Log To Console  Try to get_hw_info LTEENB-${x2_enb_mrbtsId}
    ${x2_info}  selenium_sbts.get_hw_info  hw_name=LTEENB-${x2_enb_mrbtsId}
    Log To Console  X2 Link Info:${x2_info}
    Log To Console  X2 link status:${x2_info['X2 Link Status']}, should be available
    Log To Console  X2 link lock:${x2_info['X2 link lock']}, should be unlocked
    ${link_state}    Convert To Lower Case    ${x2_info['X2 Link Status']}
    ${link_lock}    Convert To Lower Case    ${x2_info['X2 link lock']}
    Should Be Equal   ${link_state}    available
    Should Be Equal   ${link_lock}    unlocked
    [Teardown]  WebEM Logout

Check if alarm of X2 is exist
    gnb_handler.login   ip=${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   gnb_type=coam   connection=gnb
    ${x2_alarm}    create list    7300    7319
    @{return_active_alarm}   gnb_handler.get_active_alarms   connection=gnb
    ${fault_exist}   UUF_common.find_value_in_list   check_list=@{return_active_alarm}   check_key=faultId   check_value_list=${x2_alarm}
    run keyword if    ${fault_exist}    Fail    establish x2 failed
    [Teardown]  gnb_handler.logout   connection=gnb

Check ASIK Status Coam
     @{return_ASIK_status}   gnb_handler.check_gnb_asik_status   connection=gnb
     Check Status Seperately Coam   Return_Status=${return_ASIK_status}

Check Cablink Status Coam
    [Arguments]  ${connection}=gnb
     @{return_cablink_status}   gnb_handler.check_gnb_cablink_status   connection=${connection}
     FOR   ${Module_Status}   IN   @{return_cablink_status}
#        run keyword and continue on failure   Should Contain    ${Module_Status['availabilityStatus']}    nline
#         ...   msg=[ERROR] status abnormal: ${Module_Status['name']} availabilityStatus：${Module_Status['availabilityStatus']}
        run keyword and continue on failure   Should Contain    ${Module_Status['operationalState']}    nabled
         ...   msg=[ERROR] status abnormal: ${Module_Status['name']} operationalState：${Module_Status['operationalState']}
     END

Check ABIL Status Coam
     @{return_ABIL_status}   gnb_handler.check_gnb_abil_status   connection=gnb
     Check Status Seperately Coam   Return_Status=${return_ABIL_status}

Check RU Status Coam
     @{return_RU_status}   gnb_handler.check_gnb_ru_status   connection=gnb
     Check Status Seperately Coam    Return_Status=${return_RU_status}

Check If Asik and Abil not detected and set stop flag
     [Arguments]  ${ip}=${WEBUI_ADDR}    ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
     gnb_handler.login   ip=${ip}   username=${username}   password=${password}   gnb_type=coam   connection=gnb
     @{return_ASIK_status}   gnb_handler.check_gnb_asik_status   connection=gnb
     FOR   ${ASIK_Status}   IN   @{return_ASIK_status}
         ${asik_operational_state}    Convert To Lower Case    ${ASIK_Status['operationalState']}
         ${asik_status}    run keyword and return status   Should Not Contain    ${asik_operational_state}    disable
         ...   msg=[ERROR] status abnormal: ${ASIK_Status['name']} operationalState：${asik_operational_state}
         run keyword if  not ${asik_status}    set suite variable    ${stop_flag}   1
         run keyword if   ${stop_flag}==1   log to console   stop flag is set to 1\n
         run keyword if  not ${asik_status}    FAIL    [ERROR] ASIK status: ${asik_operational_state}
     END
     @{return_ABIL_status}   gnb_handler.check_gnb_abil_status   connection=gnb
     FOR   ${ABIL_Status}   IN   @{return_ABIL_status}
         ${abil_operational_state}    Convert To Lower Case    ${ABIL_Status['operationalState']}
         ${abil_status}    run keyword and return status   Should Not Contain    ${abil_operational_state}    disable
         ...   msg=[ERROR] status abnormal: ${ABIL_Status['name']} operationalState：${abil_operational_state}
         run keyword if  not ${abil_status}    set suite variable    ${stop_flag}   1
         run keyword if   ${stop_flag}==1   log to console   stop flag is set to 1\n
         run keyword if  not ${abil_status}    FAIL    [ERROR] ABIL status: ${abil_operational_state}
     END
     [Teardown]   run keyword and ignore error  gnb_handler.logout   connection=gnb

Get Cell Status Coam
    [Arguments]  ${connection}=gnb   ${check_proceduralStatus}=${True}
    ${cell_type_list}    Create List    lte    wcdma    gsm    nr
    FOR   ${cell_type}   IN   @{cell_type_list}
        @{return_Cell_status}   gnb_handler.check_gnb_cell_status   connection=${connection}    cell_type=${cell_type}
        ${check_proceduralStatus}    set variable if    '${cell_type}'=='nr'    ${True}    ${False}
        ${check_administrativestatus}    set variable if    '${cell_type}'=='wcdma'    ${False}    ${True}
        run keyword and continue on failure    run keyword if    ${return_Cell_status}!=[]
        ...    Check Status Seperately Coam    Return_Status=${return_Cell_status}
        ...    check_proceduralStatus=${check_proceduralStatus}    check_administrativestatus=${check_administrativestatus}
    END

Check Status Seperately Coam
     [Arguments]   ${Return_Status}   ${check_proceduralStatus}=${True}    ${check_administrativestatus}=${True}
     FOR   ${Module_Status}   IN   @{Return_Status}
        ${availability_status}    create list    Online    ${None}    online
        run keyword and continue on failure   List Should Contain Value    ${availability_status}    ${Module_Status['availabilityStatus']}
         ...   msg=[ERROR] status abnormal: ${Module_Status['name']} availabilityStatus：${Module_Status['availabilityStatus']}
        ${operational_state}    Convert To Lower Case    ${Module_Status['operationalState']}
        run keyword and continue on failure   Should Contain    ${operational_state}    enabled
         ...   msg=[ERROR] status abnormal: ${Module_Status['name']} operationalState：${Module_Status['operationalState']}
        run keyword if  ${check_proceduralStatus}   run keyword and continue on failure
         ...   Should Contain    ${Module_Status['proceduralStatus']}    configured
         ...   msg=[ERROR] status abnormal: ${Module_Status['name']} proceduralStatus：${Module_Status['proceduralStatus']}
        ${administrative_state}    run keyword if  ${check_administrativestatus}    Convert To Lower Case    ${Module_Status['administrativeState']}
        run keyword if  ${check_administrativestatus}   run keyword and continue on failure
        ...    Should Contain    ${administrative_state}   unlocked
         ...   msg=[ERROR] status abnormal: ${Module_Status['name']}administrativeState：${Module_Status['administrativeState']}
     END

Trigger Recovery Action According to Fault ID
    [Arguments]  ${fault_ID}
    ${fault_exist}   Check If Fault existed   ${fault_ID}
    ${has_action}   run keyword and return status  set suite variable  ${action}   ${Recovery_to_Fault}[${fault_ID}]
    run keyword if  ${fault_exist} and ${has_action}   run keyword  ${action}

Site Reset by Command
    log to console  Will Perform Site Reset by command\n
    sleep    60s
    Wait Until Keyword Succeeds    15 min    1 min
    ...   csn.Connect to   hostname=${LMP_ADDR}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.execute    command=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN    timeout=15   connection=gnb
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${False}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
    [Teardown]   csn.disconnect   connection=gnb

Site Reset by Webui
    [Arguments]    ${login_ip}=${WEBUI_ADDR}
    log to console  Will Perform Site Reset by Webui for ${login_ip}\n
    ${ipv6}  run keyword and return status   should contain   ${login_ip}  :
    run keyword if  '${ipv6}' == 'True'    selenium_sbts.login   https://${WEBUI_ADDR}/   ${WEBUI_USER}   ${WEBUI_PASSWORD}   timeout=${120}
    ...    ELSE    selenium_sbts.login   https://${login_ip}/   ${WEBUI_USER}   ${WEBUI_PASSWORD}   timeout=${120}
    selenium_sbts.reset_site
    sleep   2s
    run keyword and ignore error  selenium_sbts.logout
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${login_ip}  exp_status=${False}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${login_ip}  exp_status=${True}

Check If Fault existed
    [Arguments]  @{fault_ID}
    wait until keyword succeeds  15min   30s   gnb_handler.login   ip=${WEBUI_ADDR}   gnb_type=coam
    @{alarm_list}    gnb_handler.get_active_alarms   except_alarms=${Ignore_Fault}
    run keyword and ignore error  gnb_handler.logout
    ${fault_status}    find_value_in_list    ${alarm_list}   faultId   @{fault_ID}
    [Return]  ${fault_status}

CM Upload in Backend on NetAct
    log to console  CM Upload in Backend on NetAct
    ${upload_command}   set variable  racclimx.sh -v -op Upload -DN PLMN-PLMN/${input_btsname}
    ${expect_output}   set variable   The operation was successfully completed.:Upload is Successful
    wait until keyword succeeds  2 times   10s   Connect to NetAct WasNode and execute command   wasNode_IP=${netact_nodeip}
    ...   omc_uername=${netact_nodeusername}   omc_passowrd=${netact_nodepassword}  command=${upload_command}   expect_output=${expect_output}

FM Upload in Backend on NetAct
    log to console  FM Upload in Backend on NetAct
    ${upload_command}=   set variable  sh fmCLI.sh -operation alarmupload -dn PLMN-PLMN/${input_btsname}
    ${expect_output}=   set variable   jobid:
    ${actual_output}   wait until keyword succeeds  2 times   10s   Connect to NetAct WasNode and execute command   wasNode_IP=${netact_nodeip}
    ...   omc_uername=${netact_nodeusername}   omc_passowrd=${netact_nodepassword}  command=${upload_command}   expect_output=${expect_output}
    ${jobid}   should match regexp  ${actual_output}   \\d+
    ${uploadstatus_command}=   set variable  sh fmCLI.sh -operation status -jobid ${jobid}
    ${expect_output}=   set variable   Alarm Upload: SUCCESS
    wait until keyword succeeds  2 times   10s   Connect to NetAct WasNode and execute command   wasNode_IP=${netact_nodeip}
    ...   omc_uername=${netact_nodeusername}   omc_passowrd=${netact_nodepassword}  command=${uploadstatus_command}   expect_output=${expect_output}

Reset GPS Module in Case GPS Error
    [Arguments]  @{GPS_fault}
    log to console  Reset GPS Module in Case GPS Error
    ${fault_status}   Check If Fault Existed   ${gnb_type}   @{GPS_fault}
    run keyword if   ${fault_status}   run keywords  Reset GPS by Command
    ...   AND   wait until keyword succeeds  15min   30s   run keyword  Check GPS Status on COAM

Reset GPS by Command
    ${connection}   csn.Connect To   hostname=${oam_addr}
    ...   username=${oam_username}  password=${oam_password}   alias=ASIK  timeout=60
    ${command_part1}   set variable  python /opt/hwmt/python/SendOMMessage.py -s 0x04cb -d HWAGNSS-1/DEVICE-1/MANAGEMENT-1
    ${command_part2}   set variable  --proto GNSS/management -t execute --action resetDevice
    ${command}   set variable   ${command_part1} ${command_part2}
    csn.Execute   command=${command}   timeout=120   connection=${connection}
    [Teardown]  run keyword and ignore error  csn.Disconnect   connection=${connection}

Check GPS Status on COAM
    [Arguments]  ${ip}=${WEBUI_ADDR}
    ${connection}   wait until keyword succeeds  5min   1min   coam.connect_to   bts_host=${ip}
    ${gps_status}   coam.get_gnsses_statuses   timeout=120   connection=${connection}
    should be equal  ${gps_status['GNSSE_R-1']['administrativeState'].lower()}   unlocked
#    should be equal  ${gps_status['GNSSE_R-1']['availabilityStatus'].lower()}   online
    should be equal  ${gps_status['GNSSE_R-1']['operationalState'].lower()}   enabled
    [Teardown]  run keyword and ignore error  coam.teardown   connection=${connection}

Check if Unexpected History Alarm Exist
    [Arguments]  ${action}=None   ${host}=${WEBUI_ADDR}   ${position}=${EMPTY}
    log to console  Check if Unexpected History Alarm Exist ${host}
    gnb_handler.login   ip=${host}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    ${ignore_fault}     Set Variable if   '${bts_id}' in @{Concurrent_BTS_ID}   ${ignore_history_fault_for_concurrent}
    ...   ${if_moran}   ${ignore_history_fault_for_concurrent}
    ...   '${bts_id}' in @{Multi_BTS_ID}   ${ignore_history_fault_for_concurrent}
    ...   ${ignore_history_fault}
    ${ignore_fault}     Set Variable if   ${if_moran} and $position=='_slave'   ${ignore_history_fault_moran_slave}   ${ignore_fault}
    @{return_history_alarm}   wait until keyword succeeds  2min   10s   gnb_handler.get_history_alarms   except_alarms=${ignore_fault}
    run keyword and ignore error  add json to file    history_alarm${position}
    ...    ${return_history_alarm}    ${OUTPUT_DIR}/execution_results.json    ${action}
    should be empty   item=${return_history_alarm}   msg=unexpected history alarm reported: ${return_history_alarm}
    [Teardown]  run keyword and ignore error  gnb_handler.logout

Validate Config by WebEM
    [Arguments]  ${host}=${WEBUI_ADDR}
    run keyword and ignore error  Run   killall firefox
    selenium_sbts.enable_virtual_display
    wait until keyword succeeds  3min   30s   selenium_sbts.login   https://${host}   ${WEBUI_USER}   ${WEBUI_PASSWORD}   timeout=${120}
    run keyword and ignore error    selenium_sbts.disable_message_box
    wait until keyword succeeds  3 times   15s   selenium_sbts.validate_plan
    sleep   10s
    ${Relation_Validation_Result}   wait until keyword succeeds  5 times   5s   selenium_sbts.get_relation_errors   timeout=${20}
    ${Definition_Validation_Result}   wait until keyword succeeds  5 times   5s   selenium_sbts.get_Definition_errors   timeout=${20}
    ${Hardware_Validation_Result}   wait until keyword succeeds  5 times   5s   selenium_sbts.get_Hardware_errors   timeout=${20}
    should be empty   ${Relation_Validation_Result}
    should be empty   ${Definition_Validation_Result}
    should be empty   ${Hardware_Validation_Result}
    [Teardown]   selenium_sbts.logout

Validate Config by BackGround
    [Arguments]    ${dir}=${CURDIR}    ${filename}=SCF_BACKUP.xml
    ${connection}   wait until keyword succeeds  5min   1min   coam.connect_to   bts_host=${WEBUI_ADDR}
    Set Suite Variable  ${ORIGINAL_SCF_PATH}  ${dir}/${filename}
    ${scf_validation_results}  coam.validate_scf  scf_file=${ORIGINAL_SCF_PATH}  timeout=600s  connection=${connection}
    Should Be Equal As Strings  ${scf_validation_results["pdlValidationResult"]["status"]}  OK

Start journalctl log for RU
    [Arguments]  ${action}
    log to console  Start journalctl log for RU
    Run   ps -ef|grep ${ru_log_script}|grep -v grep| awk '{print $2}' |xargs kill -9
    ${index}   set variable  1
    ${start_time}    DateTime.Get Current Date
    ${DATE_STR}   DateTime.Convert Date   ${start_time}   %Y%m%d%H%M
    ${active}  ${passive}   Get gNB SW version    format=full
    ${active_release}   Fetch From Left    ${active}   _
    FOR   ${ru}   IN   @{rus}
       run keyword and ignore error  Start Process   python   ${ru_log_script}   ${ru['ctrl_addr']}   ${ru['ctrl_username']}
       ...   ${ru['ctrl_password']}   ${ru['addr']}   ${RU_journallog_command}    ${value['ru_type']}    ${active_release}
       ...   ${OUTPUT_DIR}/journal_ru_${action}_${DATE_STR}_${ru['ctrl_addr']}.log   alias=ru${index}
       ${index}   evaluate  ${index}+1
    END

Stop RU journalctl log
    log to console  Stop RU journalctl log
    ${index}   set variable  1
    FOR   ${value}   IN   @{rus}
       run keyword and ignore error  Stop journalctl log collection   alias=ru${index}
       ${index}   evaluate  ${index}+1
    END

Stop journalctl log collection
    [Arguments]   ${alias}
    Terminate Process   handle=${alias}   kill=true
    ${pid}   Get Process Id   ${alias}
    run keyword and ignore error  Run   kill -9 ${pid}
    ${result}   Get Process Result   ${alias}

test suite setup reset
    Check running nms mode
    ${bts_id}   convert to string   ${MRBTS_ID}
    set suite variable    ${bts_id}
    ${slave_bts_id}    Run Keyword If   '${bts_id}' in @{Multi_BTS_ID}   convert to string   ${PEER_BTS_ID}
    set suite variable    ${slave_bts_id}
    run keyword and ignore error    Check if Unexpected Active Alarm Exist and Set Stop Flag   stop_with_trunk_roll_fault=True
    Run Keyword If   '${bts_id}' in @{Multi_BTS_ID}   run keyword and ignore error
    ...   Check if Unexpected Active Alarm Exist and Set Stop Flag   web_ip=${Peer_WEBUI_ADDR}   stop_with_trunk_roll_fault=True
    ...   bts_id=${slave_bts_id}
    Check If Asik and Abil not detected and set stop flag
    Get All Enb IPs
    FOR     ${enb_ip}    IN    @{enb_ip_list}
        run keyword and ignore error    Check if Unexpected Active Alarm Exist and Set Stop Flag   web_ip=${enb_ip}
        ...   stop_with_trunk_roll_fault=True   if_enb=True
        Check If Asik and Abil not detected and set stop flag    ${enb_ip}
    END
    run keyword if    ${stop_flag}==1   FAIL
    run keyword and ignore error    run keyword if   '${bts_id}' in @{enable_BTS_ID}    Enable ssh to RU
    run keyword if  not ${${DEBUG}}   selenium_netact.enable_virtual_display
    run keyword and ignore error     Delete Code and Log from TAF
    Remove logs    savefolder=COAM
#    run keyword and ignore error    Remove RU Tcpdump Through Local IP   filename=RU_tcpdump.pcap
#    run keyword and ignore error    Remove Tcpdump RU Log Through Local IP   filename=RadioDumpOPT3.pcap
    Get Available Space on Test PC
    Set gNB SW version and Release
    run keyword   COAM Download SCF to Current Dir
    Get SCF Param
    run keyword if  'both' in ${cellDepType} or 'NSA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   COAM Download SCF to Current Dir    filename=X2ENB_SCF_BACKUP.xml    bts_host=${ENBs[0]['addr']}
    ${x2_enb_mrbtsId}    run keyword if  'both' in ${cellDepType} or 'NSA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   get_bts_info.Get_LNBTS_ID    ${cpri_scf}/X2ENB_SCF_BACKUP.xml
    run keyword if  'both' in ${cellDepType} or 'NSA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   set suite variable    ${x2_enb_mrbtsId}
    Run Keyword If   '${bts_id}' in @{Multi_BTS_ID}   Switch to target build   ssh_ip=${peer_asik_addr}   slave_flag=${True}
    ...   web_addr=${Peer_WEBUI_ADDR}
    run keyword if   '${bts_id}' in @{Concurrent_BTS_ID} or '${bts_id}' in @{Multi_BTS_ID}   Switch to enb target build
    Switch to target build
    Check gNB memory
    Get Disk Space at Beginning
    run keyword and ignore error  Check Active Alarms and Trigger Recovery Action According to Fault ID
    run keyword and ignore error   Check if Unexpected Active Alarm Exist and Set Stop Flag   stop_with_trunk_roll_fault=True
#    Check eNB status
    run keyword if    '${bts_id}' in @{Multi_BTS_ID}    Check Flag in Swconfig File    reset    ${peer_asik_addr}
    Check Flag in Swconfig File    reset
    run keyword if  'both' in ${cellDepType} or 'NSA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   run keyword and ignore error  Check eNB Cell Status
    run keyword if  'both' in ${cellDepType} or 'NSA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   run keyword and ignore error   Site reset if eNB not onair
    run keyword if  'both' in ${cellDepType} or 'NSA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   run keyword and ignore error   Check eNB Active Alarms
    FOR     ${enb_ip}    IN    @{enb_ip_list}
        run keyword if    '${bts_id}' in @{Concurrent_BTS_ID}    Check Flag in Swconfig File    reset    ${enb_ip}    ${True}
    END
    run keyword and ignore error   run keyword if    '${test_mode}'=='UUF'    Check Flag in FSMF
    Site Reset by command if Cell not onAir
    run keyword and ignore error    Get Correspondence between BBMOD and RMOD
    run keyword and ignore error    Check if need add 1815 to ignore history alarm list
    run keyword and ignore error   Create Env Config File
    run keyword and ignore error   run keywords    Enable ssh to RU
    ...   AND   Check RU reachability from test PC
    ...   AND   add json to file   disconnected_PC   ${disconnected_pc}
    ...   ${OUTPUT_DIR}/execution_results.json   upgrade
    ...   AND   run keyword if   ${enable_ssh_via_PC}==${True}   Stop ssh RU Script for all ControlPC
#    ...   AND   run keyword if   '${test_mode}'=='UUF'    Precheck RU Flags


reset common setup
    run keyword and ignore error  Reset GPS Module in Case GPS Error   @{GPS_fault}
    run keyword and ignore error   Start BTS LOG Collection On Gnb And Rus

COAM Site Reset Process
    COAM Reset Site via WebEM
    ${reset_start_time}    DateTime.Get Current Date
    set suite variable     ${reset_start_time}
    Catch Realtime Log    operation=provision
    Check Cell Setup in COAM by API
    ${reset_finish_time}    DateTime.Get Current Date
    set suite variable     ${reset_finish_time}
    Check if Unexpected Active Alarm Exist and Set Stop Flag
    ${reset_duration}    Subtract Date From Date    ${reset_finish_time}    ${reset_start_time}    compact
    log to console    reset duration is ${reset_duration}
    set suite variable    ${reset_duration}
    ${conver_upgrade_duration}    Convert Time    ${reset_duration}
    COAM check gNB state after cell setup
    Check Site Status After Upgrade or Rollback

COAM Reset Site via WebEM
    Wait Until Keyword Succeeds   5 min   1 min    COAM Login
    coam.reset_site    connection=COAM
    log to console     COAM reset site finished!
    [Teardown]   run keyword and ignore error    COAM Logout

Varify CM Provsion in Bankend on NetAct via Change BTS Name
    log to console  Varify CM Provsion in Bankend on NetAct via Change BTS Name
    ${current_date}   DateTime.Get Current Date
    ${date_str}   DateTime.Convert Date   ${current_date}   %Y%m%d%H%M
    ${btsname}   set variable   ${input_btsname}-${date_str}
    Change Parameter Value by CM Provsion in Bankend on NetAct   param_path=PLMN-PLMN/${input_btsname}   param_value=${btsname}   param_name=btsName
    ${modified_btsname}   wait until keyword succeeds  3 times   1min   get_parameter_from_webem
    ...   dist_name=${input_btsname}   filter_param=BTS name   abbr=btsName
    ...   addr=https://${WEBUI_ADDR}  username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    should be equal  ${modified_btsname}   ${btsname}

Change Parameter Value by CM Provsion in Bankend on NetAct
    [Arguments]  ${param_path}   ${param_value}   ${param_name}
    ${provision_command_part1}   set variable  racclimx.sh -op Provision_Mass_Modification -DN
    ${provision_command_part2}   set variable  ${param_path} -parameterValuesByNames ${param_name}=${param_value} -v
    ${provision_command}   set variable   ${provision_command_part1} ${provision_command_part2}
    ${expect_output}   set variable   Provision of the plan was successful
    wait until keyword succeeds  2 times   1min   Connect to NetAct WasNode and execute command   wasNode_IP=${netact_nodeip}
    ...   omc_uername=${netact_nodeusername}   omc_passowrd=${netact_nodepassword}  command=${provision_command}   expect_output=${expect_output}

Get eNB SW version
    [Arguments]   ${lte_addr}
     ${active_sw_version}   ${passive_sw_version}    gnb_handler.get_sw_version_by_ssh   gnb_ip=${lte_addr}
    [Return]    ${active_sw_version}   ${passive_sw_version}

Site reset if eNB not onair
    [Arguments]     ${dir}=1   ${is_teardown}=False
    ${index}   set variable  -1
    FOR   ${status}   IN   @{abnormal_enb_list}
       ${index}   evaluate  ${index}+1
       continue for loop if   '${ENBs[${index}]['addr']}'=='1.1.1.1'
       ${alarm_status}   run keyword and return status  Check if Unexpected Active Alarm Exist and Set Stop Flag   web_ip=${ENBs[${index}]['addr']}
       ...   stop_with_trunk_roll_fault=True    if_enb=True
       continue for loop if  ${status} and ${alarm_status}
       Check If Asik and Abil not detected and set stop flag    ${ENBs[${index}]['addr']}
       run keyword if   ${stop_flag}==1    log to console  fault occurred, will not perform reset to save environment\n
       ...   ELSE   Site Reset And Check Status   folder=${TEST_NAME}/${dir}    login_ip=${ENBs[${index}]['addr']}
       Check if Unexpected Active Alarm Exist and Set Stop Flag   stop_with_trunk_roll_fault=True   web_ip=${ENBs[${index}]['addr']}   if_enb=True
       run keyword if   '${is_teardown}'=='True'   run keyword and ignore error
       ...   Save eNB Snapshot   dir=${TEST_NAME}/${dir}   status=after_recover
#       ${alarm_status}  run keyword and return status   Check Single eNB Active Alarms
#       ...   ip=${ENBs[${index}]['addr']}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
#       continue for loop if  ${status} and ${alarm_status}
#       Wait Until Keyword Succeeds    2 min    20 s   csn.Connect to
#    ...   hostname=${ENBs[${index}]['addr']}   username=${ENBs[${index}]['username']}   password=${ENBs[${index}]['password']}   alias=enb
#       csn.execute    command=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN    timeout=20   connection=enb
#       run keyword and ignore error  csn.Disconnect   connection=enb
#       Wait Until Keyword Succeeds   5 min   30 s    Validate IP Reachability from Test PC
#    ...   ip_addr=${ENBs[${index}]['addr']}  exp_status=${False}
#       Wait Until Keyword Succeeds   5 min   30 s    Validate IP Reachability from Test PC
#    ...   ip_addr=${ENBs[${index}]['addr']}  exp_status=${True}
#       wait until keyword succeeds    20 min    3 min   Check eNB Cell Status Seperately   lte_addr=${ENBs[${index}]['addr']}

    END
#    wait until keyword succeeds    20 min    3 min   Check eNB Cell Status
#    wait until keyword succeeds    15 min    3 min   Check eNB status

Check eNB status for Concurrent
    [Arguments]   ${lte_addr}    ${if_ignore_cablink}=${True}
    log to console  Check eNB status for Concurrent
    wait until keyword succeeds  3 times   5s   gnb_handler.login   gnb_type=enb   ip=${lte_addr}   connection=enb
    @{enb_status}   gnb_handler.check_gnb_cell_status   connection=enb    cell_type=lte
    Check eNB Module Status Seperately    Return_Status=${enb_status}
    run keyword if    ${if_ignore_cablink}==${True}    run keyword and ignore error    Check Cablink Status Coam    enb
    ...    ELSE     Check Cablink Status Coam    enb
    [Teardown]  run keyword and ignore error  gnb_handler.logout   connection=enb

Check X2eNB status
    [Arguments]   ${lte_addr}    ${if_ignore_cablink}=${True}
    log to console  Check X2eNB status
    wait until keyword succeeds  3 times   5s   gnb_handler.login   gnb_type=enb   ip=${lte_addr}   connection=enb
    @{enb_status}   gnb_handler.check_gnb_cell_status   connection=enb    cell_type=lte
    Check eNB Module Status Seperately    Return_Status=${enb_status}
    [Teardown]  run keyword and ignore error  gnb_handler.logout   connection=enb

Check eNB Module Status Seperately
     [Arguments]   ${Return_Status}
     FOR   ${Module_Status}   IN   @{Return_Status}
         ${availability_status}    create list    Online    ${None}    online
         run keyword and continue on failure   List Should Contain Value    ${availability_status}    ${Module_Status['availabilityStatus']}
         ...   msg=[ERROR] status abnormal: ${Module_Status['name']} availabilityStatus：${Module_Status['availabilityStatus']}
         ${operational_state}    Convert To Lower Case    ${Module_Status['operationalState']}
         run keyword and continue on failure   Should Contain    ${operational_state}    enabled
         ...   msg=[ERROR] status abnormal: ${Module_Status['name']} operationalState：${Module_Status['operationalState']}
         ${administrative_state}    Convert To Lower Case    ${Module_Status['administrativeState']}
         run keyword and continue on failure   Should Contain    ${administrative_state}   unlocked
         ...   msg=[ERROR] status abnormal: ${Module_Status['name']}administrativeState：${Module_Status['administrativeState']}
     END

Get gNB SW version
    [Arguments]  ${ip}=${LMP_ADDR}    ${format}=abbreviation
    ${active_sw_version}   ${passive_sw_version}   wait until keyword succeeds   3 min   30 s
    ...   gnb_handler.get_sw_version_by_ssh   gnb_ip=${ip}    format=${format}
#    ${active_is_common}   run keyword and return status  should contain   ${active_sw_version}   SBTS
#    ${active_version}   run keyword if   ${active_is_common} or '${active_sw_version}'==''   set variable   ${active_sw_version}
#    ...   ELSE   Get 5G Build Version   ${active_sw_version}
#    ${passive_is_common}   run keyword and return status  should contain   ${passive_sw_version}   SBTS
#    ${passive_version}   run keyword if   ${passive_is_common} or '${passive_sw_version}'==''   set variable   ${passive_sw_version}
#    ...   ELSE   Get 5G Build Version   ${passive_sw_version}
    [Return]    ${active_sw_version}   ${passive_sw_version}


Get gNB SW release
    [Arguments]  ${ip}=${cu_addr}
     ${active_sw_version}   ${passive_sw_version}   wait until keyword succeeds   3 min   30 s
     ...   gnb_handler.get_sw_version_by_ssh   gnb_ip=${ip}   format=full
     ${active_release}       Fetch From Left    ${active_sw_version}    _
     ${passive_release}      Fetch From Left    ${passive_sw_version}    _
    [Return]    ${active_release}   ${passive_release}

Set gNB SW version and Release
     ${active_version}   ${passive_version}    Get gNB SW version
     set global variable   ${ACTIVE_GNB_VERSION}    ${active_version}
     set global variable   ${PASSIVE_GNB_VERSION}   ${passive_version}
     ${active_sw_release}   ${passive_sw_release}    Get gNB SW release
     set global variable    ${ACTIVE_GNB_RELEASE}   ${active_sw_release}
     set global variable    ${PASSIVE_GNB_RELEASE}  ${passive_sw_release}
#     ${is_common}   run keyword and return status   ${ACTIVE_GNB_RELEASE}   SBTS
     set global variable    ${OAM_TYPE}   COAM

Catch build release
      [Arguments]   ${build_type}
      ${release_type}   run keyword and return status   should contain   ${build_type}   SBTS
      ${build_version}       run keyword if  ${release_type}   Split String   ${build_type}   _   1
      ...   ELSE   Fetch From Left    ${build_type}   .
      ${is_SBTS00}   run keyword and return status   should contain   ${build_version}[0]   SBTS00
      ${common_time}   run keyword if  ${release_type}   split string   ${build_type}   _
      ${time}   set variable if   ${release_type}   ${common_time}[3]   0
      ${common_version}   run keyword if   ${release_type} and ${is_SBTS00} and '${time}'<='210526'   set variable   SBTS21B
      ...   ELSE IF   ${release_type} and ${is_SBTS00} and '${time}'>'210526' and '${time}'<'210928'   set variable   SBTS22R1
      ...   ELSE IF   ${release_type} and ${is_SBTS00} and '${time}'>='210928' and '${time}'<'220110'   set variable   SBTS22R2
      ...   ELSE IF   ${release_type} and ${is_SBTS00} and '${time}'>='220110' and '${time}'<'220428'  set variable   SBTS22R3
      ...   ELSE IF   ${release_type} and ${is_SBTS00} and '${time}'>='220428' and '${time}'<'220804'   set variable   SBTS22R4
      ...   ELSE IF   ${release_type} and ${is_SBTS00} and '${time}'>='220804' and '${time}'<'221110'   set variable   SBTS23R1
      ...   ELSE IF   ${release_type} and ${is_SBTS00} and '${time}'>='221110' and '${time}'<'230216'   set variable   SBTS23R2
      ...   ELSE IF   ${release_type} and ${is_SBTS00} and '${time}'>='230216' and '${time}'<'230524'   set variable   SBTS23R3
      ...   ELSE IF   ${release_type} and ${is_SBTS00} and '${time}'>='230524' and '${time}'<'230817'   set variable   SBTS23R4
      ...   ELSE IF   ${release_type} and ${is_SBTS00} and '${time}'>='230817'   set variable   SBTS24R1
      ...   ELSE IF   ${release_type} and '${is_SBTS00}'=='False'   set variable   ${build_version}[0]
      ${build_release}     run keyword if   ${release_type}  set variable   ${common_version}
      ...  ELSE IF   '${build_version}' == '11'   set variable   5G21A
      ...  ELSE IF   '${build_version}' == '103'   set variable   trunk
      ...  ELSE IF   '${build_version}' == '0'   set variable   trunk
      [Return]  ${build_release}

COAM Simple Rollback Actions
    [Arguments]   ${host}=${cu_addr}
    COAM rollback package   login_ip=${host}
    Wait Until Keyword Succeeds   10 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${host}  exp_status=${False}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${host}  exp_status=${True}
    run keyword and ignore error    run keyword if  '${bts_id}' not in @{not_collect_log_when_alarm}
    ...   Wait Until Keyword Succeeds   3x   10 s    Enable collect logs when alarm report
    ...   ${OUTPUT_DIR}/${TEST_NAME}/rollback    ${host}
    Wait Until Keyword Succeeds   25min   1min   Check Cell Status after SW Version Modified   login_ip=${host}

Switch to source build
    [Arguments]   ${ssh_ip}=${cu_addr}   ${slave_flag}=${False}   ${web_addr}=${WEBUI_ADDR}
    ${current_active_version}   ${current_active_release}    ${current_passive_version}   ${current_passive_release}
    ...   Get Current gNB SW version And Release   login_ip=${ssh_ip}   slave_flag=${slave_flag}
    ${o_release}   Catch build release   ${origin_version}
    ${origin_ver_for_cmp}   Check gNB Version is Common Build   ${origin_version}
    ${shared_RUs}   Run Keyword If   ${if_moran}   Create List
    Run Keyword If   ${if_moran}   Set Suite Variable   ${shared_RUs}
    Return From Keyword If   '${current_active_version}' == '${origin_ver_for_cmp}'
    ${slave_msg}    Set Variable If    ${slave_flag}    slave    master
    log to console    Start Switch to source build(${origin_version}) for ${web_addr}, this is ${slave_msg} node.
    run keyword and ignore error   Disable RU Swcofnig Cleanup   ${rus}
    run keyword if   '${slave_flag}'=='False' and '${current_active_release}' > '${o_release}' and '${current_passive_release}' > '${o_release}'
    ...   Downgrade to Lower Release
    ...   ELSE IF   '${slave_flag}'=='False' and '${current_active_release}' > '${o_release}' and '${current_passive_release}' == 'LN'
    ...   Downgrade to Lower Release
    ...   ELSE IF   '${current_active_release}' > '${o_release}' and '${current_passive_release}' <= '${o_release}'
    ...   run keywords    COAM rollback package   login_ip=${web_addr}
    ...   AND    Wait Until Keyword Succeeds   10 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${ssh_ip}  exp_status=${False}
    ...   AND    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${ssh_ip}  exp_status=${True}
    ...   AND    Wait Until Keyword Succeeds   25min   1min   Check Cell Status after SW Version Modified   login_ip=${web_addr}
    ...   AND    run keyword if    '${current_passive_version}' == '${origin_ver_for_cmp}'
    ...   log to console    Finish Switch to source build for ${web_addr}.
    ...   AND    Return From Keyword If   '${current_passive_version}' == '${origin_ver_for_cmp}'
    run keyword if   '${slave_flag}'=='True' and '${current_active_release}' > '${o_release}' and '${current_passive_release}' > '${o_release}'
    ...    log to console    Finish Switch to source build for ${web_addr}.
    Return From Keyword If
    ...   '${slave_flag}'=='True' and '${current_active_release}' > '${o_release}' and '${current_passive_release}' > '${o_release}'
    run keyword if   not ${slave_flag}   Set gNB SW version and Release
    ${current_active_version}   ${current_active_release}    ${current_passive_version}   ${current_passive_release}
    ...   Get Current gNB SW version And Release   login_ip=${ssh_ip}   slave_flag=${slave_flag}
    run keyword if  '${current_active_version}' != '${origin_ver_for_cmp}'   Log    Current version is not origin version!    WARN
    Run Keyword If   ${if_moran}   Moran Set Share Mode
    run keyword if  '${current_active_version}' != '${origin_ver_for_cmp}'    run keywords    log to console    Load origin package
    ...   AND    Check if taget SW package exist   upgradetool=webui    version=${origin_version}
    ...   AND    run keyword and ignore error   Disable RU Swcofnig Cleanup   ${rus}
    ...   AND    COAM Upgrade package    package=${origin_version}   ip=${web_addr}
    ...   AND    Wait Until Keyword Succeeds   50 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${ssh_ip}   exp_status=${False}
    ...   AND    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${ssh_ip}  exp_status=${True}
    ...   AND     Wait Until Keyword Succeeds   25min   1min   Check Cell Status after SW Version Modified   login_ip=${web_addr}
    log to console    Finish Switch to source build for ${web_addr}.

Get Current gNB SW version And Release
    [Arguments]   ${login_ip}=${cu_addr}      ${slave_flag}=${False}
    ${active_version}   ${passive_version}   run keyword if   ${slave_flag}   Get gNB SW version   ip=${login_ip}
    ${active_release}   ${passive_release}   run keyword if   ${slave_flag}   Get gNB SW release   ip=${login_ip}
    ${current_active_version}   set variable if   ${slave_flag}   ${active_version}   ${ACTIVE_GNB_VERSION}
    ${current_active_release}   set variable if   ${slave_flag}   ${active_release}   ${ACTIVE_GNB_RELEASE}
    ${current_passive_version}   set variable if   ${slave_flag}   ${passive_version}   ${PASSIVE_GNB_VERSION}
    ${current_passive_release}   set variable if   ${slave_flag}   ${passive_release}   ${PASSIVE_GNB_RELEASE}
    [Return]   ${current_active_version}   ${current_active_release}    ${current_passive_version}   ${current_passive_release}

Switch to target build
    [Arguments]   ${ssh_ip}=${cu_addr}   ${slave_flag}=${False}   ${web_addr}=${WEBUI_ADDR}
    ${current_active_version}   ${current_active_release}    ${current_passive_version}   ${current_passive_release}
    ...   Get Current gNB SW version And Release   login_ip=${ssh_ip}   slave_flag=${slave_flag}
    ${upgrade_release}   Catch build release   ${upgrade_version}
    ${upgrade_ver_for_cmp}   Check gNB Version is Common Build   ${upgrade_version}
    run keyword if   '${current_active_release}' > '${upgrade_release}' and '${current_passive_release}' > '${upgrade_release}'
    ...   Fail    Not Support Downgrade to Lower Release
    run keyword if  '${current_active_release}' > '${current_passive_release}' and '${current_active_version}' != '${upgrade_ver_for_cmp}'
    ...   run keywords    run keyword and ignore error   Disable RU Swcofnig Cleanup   ${rus}
    ...   AND    COAM rollback package   login_ip=${web_addr}
    ...   AND    Wait Until Keyword Succeeds   10 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${ssh_ip}  exp_status=${False}
    ...   AND    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${ssh_ip}  exp_status=${True}
    ...   AND    Wait Until Keyword Succeeds   25min   1min   Check Cell Status after SW Version Modified   login_ip=${web_addr}
    ...   AND    run keyword and ignore error   Check If GPS Upgrade Alarm Clear and GPS Status   ip=${web_addr}
    run keyword if   not ${slave_flag}   Set gNB SW version and Release
    ${current_active_version}   ${current_active_release}    ${current_passive_version}   ${current_passive_release}
    ...   Get Current gNB SW version And Release   login_ip=${ssh_ip}   slave_flag=${slave_flag}
    run keyword if  '${current_active_version}' != '${upgrade_ver_for_cmp}'    run keywords    log to console    Load target package
    ...   AND    Check if taget SW package exist   upgradetool=webui    version=${upgrade_version}
    ...   AND    run keyword and ignore error   Disable RU Swcofnig Cleanup   ${rus}
    ...   AND    COAM Upgrade package    package=${upgrade_version}   ip=${web_addr}
    ...   AND    Wait Until Keyword Succeeds   50 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${ssh_ip}   exp_status=${False}
    ...   AND    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${ssh_ip}  exp_status=${True}
    ...   AND     Wait Until Keyword Succeeds   25min   1min   Check Cell Status after SW Version Modified  login_ip=${web_addr}
    ...   AND     run keyword and ignore error   Check If GPS Upgrade Alarm Clear and GPS Status   ip=${web_addr}

Switch to enb target build
    FOR     ${enb_ip}    IN    @{enb_ip_list}
        ${count_index}    UUF_common.count_list_contain_sub_dict    ${ENBs}    addr    ${enb_ip}
        continue for loop if     '${enb_ip}' == '${ENBs[0]['addr']}' and '${count_index}' == '1'
        ${upgrade_release}   Catch build release   ${enb_target_version}
        ${upgrade_ver_for_cmp}   Check gNB Version is Common Build   ${enb_target_version}
        ${active_version}   ${passive_version}   Get eNB SW version   ${enb_ip}
        ${active_release}   ${passive_release}   Get gNB SW release   ${enb_ip}
        run keyword if   '${active_release}' > '${upgrade_release}' and '${passive_release}' > '${upgrade_release}'
        ...   FAIL   Downgrade is not supported!
        run keyword if  '${active_version}' != '${upgrade_ver_for_cmp}'
        ...   Log    Current version for ${enb_ip} is not target version!    WARN
        run keyword if  '${active_release}' > '${passive_release}' and '${active_version}' != '${upgrade_ver_for_cmp}'
        ...   run keywords    log to console    rollback enb package
        ...   AND   COAM Rollback package    ${enb_ip}
        ...   AND   run keyword and ignore error    Wait Until Keyword Succeeds   30 min   10 s    Validate IP Reachability from Test PC
        ...   ip_addr=${enb_ip}   exp_status=${False}
        ...   AND   Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
        ...   ip_addr=${enb_ip}  exp_status=${True}
        ...   AND   run keyword and continue on failure   Wait Until Keyword Succeeds   20 min   20 s
        ...   Check eNB status for Concurrent    ${enb_ip}
        ${active_version}   ${passive_version}   Get eNB SW version   ${enb_ip}
        run keyword if  '${active_version}' != '${upgrade_ver_for_cmp}'   run keywords    log to console    Load enb target package
        ...   AND    Check taget SW package exist in taf server    version=${enb_target_version}
        ...   AND    Upgrade eNB and Check Cell Setup   action=provision    enb_ip=${enb_ip}    save_log=${False}    ignore_fault=${True}
    END

Switch to enb source build
    [Arguments]   ${host}=${ENBs[1]['addr']}   ${type}=eNB
    FOR     ${enb_ip}    IN    @{enb_ip_list}
        ${count_index}    UUF_common.count_list_contain_sub_dict    ${ENBs}    addr    ${enb_ip}
        continue for loop if     '${enb_ip}' == '${ENBs[0]['addr']}' and '${count_index}' == '1'
        ${o_rel}   ${o_version}   Split String   ${enb_source_version}   _   1
        ${o_release}   Catch build release   ${enb_source_version}
        ${active_version}   ${passive_version}   Get eNB SW version   ${enb_ip}
        ${active_release}   ${passive_release}   Get gNB SW release   ${enb_ip}
        ${current_active_version}   ${current_active_release}    ${current_passive_version}   ${current_passive_release}
        ...   Get Current gNB SW version And Release   login_ip=${enb_ip}   slave_flag=${True}
        ${enborigin_ver_for_cmp}   Check gNB Version is Common Build   ${enb_source_version}
        continue for loop if   '${current_active_version}' == '${enborigin_ver_for_cmp}'
        log to console    Start Switch to enb source build(${enb_source_version}) for ${enb_ip}.
        run keyword if   '${active_release}' > '${o_release}' and '${passive_release}' > '${o_release}'
        ...   run keywords    log to console    Downgrade is not supported!
        ...   AND    FAIL   Downgrade is not supported!
        run keyword if  '${active_version}' != '${o_version}'   Log    Current version is not origin version!    WARN
        run keyword if  '${active_release}' > '${o_release}' and '${passive_release}' <= '${o_release}'
        ...   run keywords    log to console    rollback enb package
        ...   AND   COAM Rollback package    ${enb_ip}
        ...   AND   run keyword and ignore error    Wait Until Keyword Succeeds   30 min   10 s    Validate IP Reachability from Test PC
        ...   ip_addr=${enb_ip}   exp_status=${False}
        ...   AND   Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
        ...   ip_addr=${enb_ip}  exp_status=${True}
        ...   AND   run keyword and continue on failure   Wait Until Keyword Succeeds   20 min   20 s
        ...   Check eNB status for Concurrent    ${enb_ip}
        ${active_version}   ${passive_version}   Get eNB SW version   ${enb_ip}
        Run Keyword If   ${if_moran}   Moran Set Share Mode
        run keyword if  '${active_version}' != '${o_version}'   run keywords    log to console    Load enb origin package
        ...   AND    Check taget SW package exist in taf server    version=${enb_source_version}
        ...   AND    Upgrade eNB and Check Cell Setup   eNB_package=${enb_source_version}    action=switch_source   enb_ip=${enb_ip}
        ...   save_log=${False}    ignore_fault=${True}
        log to console    ${enb_ip} is on source build!
    END

Check Active Alarms and Trigger Recovery Action According to Fault ID
    log to console  Check Active Alarms and Trigger Recovery Action According to Fault ID
    wait until keyword succeeds  5min   20s   gnb_handler.login   ip=${WEBUI_ADDR}   gnb_type=coam
    @{alarm_list}    gnb_handler.get_active_alarms   except_alarms=${Ignore_Fault}
    run keyword and ignore error  gnb_handler.logout
    FOR    ${alarm}    IN    @{alarm_list}
       run keyword and ignore error  Trigger Recovery Action According to Fault ID   ${alarm["faultId"]}
    END

Site Reset by command if Cell not onAir
    log to console  Site Reset by command if Cell not onAir
    ${status}   run keyword and return status  Coam Check Site Status
    run keyword if  not ${status}   run keywords  Site Reset by Webui
    ...   AND   wait until keyword succeeds  20min   10s   Coam Check Site Status

Check NetAct Operations
    CM Upload in Backend on NetAct
    NetAct SWM Upload
    run keyword and ignore error    Check Acive Alarm between WebEM and NetAct
    ...   netactnode=${netact_nodeip}   username=${netact_nodeusername}   password=${netact_nodepassword}   btsname=PLMN-PLMN/${input_btsname}
    run keyword and ignore error  Check Active Alarm from NetAct Backend
    ...   netactnode=${netact_nodeip}   username=${netact_nodeusername}   password=${netact_nodepassword}
    ...   btsname=PLMN-PLMN/${input_btsname}   ignore_fault_id=${Ignore_Fault}
#    FM upload failed with high occurrence rate due to PR505621, was identified as robot related issue.
    ${FM_status}   run keyword and return status  FM Upload in Backend on NetAct
    run keyword if  not ${FM_status}   log to console  [Warn]: FM upload fail!
    run keyword and ignore error  Start Deltaplan Monitor and Save Deltaplan
    run keyword if  '${MRBTS_ID}' not in ${Ignore_CM_BTS}   Varify CM Provsion in Bankend on NetAct via Change BTS Name
    run keyword and ignore error  Stop Deltaplan Monitor Script

Check Flag in Swconfig File
    [Arguments]    ${action}=UUF    ${hostname}=${asik_addr}    ${if_enb}=${false}
    Set Suite Variable    ${need_site_reset}    ${false}
    ${swconfig_exist_status}   Check if There is swconfig File in Site    hostname=${hostname}
    run keyword if    ${swconfig_exist_status} and '${test_mode}'=='UUF'    Check if Other Flag Added    hostname=${hostname}    action=${action}
    run keyword if    ${swconfig_exist_status} and '${test_mode}'=='UUF'    Check and Ensure btslog Flag in Swconfig File    hostname=${hostname}
    run keyword if    ${swconfig_exist_status} and '${action}'=='reset'    check and add HWF reset flag    hostname=${hostname}
    run keyword if    ${swconfig_exist_status} and '${action}'!='reset'    check and remove HWF reset flag    hostname=${hostname}
    run keyword if   '${swconfig_exist_status}'=='${False}' and '${if_enb}'=='${False}'   Fetch swconfig from Git and Upload to Site
    run keyword if   ${need_site_reset}    Site Reset by Webui    ${hostname}
    run keyword and ignore error    wait until keyword succeeds    15 min    2 min   Coam Check Site Status    ip=${hostname}

Check if There is swconfig File in Site
    [Arguments]    ${hostname}=${asik_addr}
    Wait Until Keyword Succeeds    15 min    1 min
    ...   csn.Connect to   hostname=${hostname}   username=${asik_username}   password=${asik_password}    alias=gnb
    ${output}   csn.execute    command=cd /rom;ls -al | grep swconfig.txt | grep -v swconfig.txt.p7   connection=gnb
    ${swconfig_exist_status}   run keyword and return status   should not be empty   ${output}
    [Return]   ${swconfig_exist_status}
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=gnb

Fetch swconfig from Git and Upload to Site
    ${TL_Name}    set variable   TL${MRBTS_ID}
    ${swconfig_link}   set variable   git@gitlabe1.ext.net.nokia.com:SG8/golden_scf.git
    log to console    Swconfig File did not Set in Site and Fetch swconfig.txt from Git
    Run    sudo rm -rf /home/ute/scf/
    Sleep    10s
    Run    sudo rm -f /home/ute/output*.log
    Log    \nStart to Download swconfig.txt From GIT!    WARN
    ${output}    Run   git clone ${swconfig_link} /home/ute/scf --progress --verbose
    Wait Until Git Clone Process Done    output=${output}
    ${output}    Run    ls /home/ute/scf/${TL_Name}/COAM/
    run keyword if     ${output.count('swconfig')}>0
    ...    run keyword    Upload Swconfig from Taf to gnb    ${TL_Name}
    ...    ELSE    Add btslog Flag in Swconfig File
    Set Suite Variable    ${need_site_reset}    ${true}

Upload Swconfig from Taf to gnb
    [Arguments]    ${TL_Name}
    ${swconfig_path}    Set Variable       /home/ute/scf/${TL_Name}/COAM/swconfig.txt
    Wait Until Keyword Succeeds    15 min    1 min
    ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.Upload File    local_path=${swconfig_path}    remote_path=/rom/swconfig.txt    connection=gnb
    csn.execute    crasign /rom/swconfig.txt    connection=gnb
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=gnb

Add btslog Flag in Swconfig File
    Wait Until Keyword Succeeds    15 min    1 min
    ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.execute    command=echo "0x10041=5" >> /ffs/run/swconfig.txt;crasign /ffs/run/swconfig.txt.p7   connection=gnb
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=gnb

Check and Ensure btslog Flag in Swconfig File
    [Arguments]    ${hostname}=${asik_addr}
    ${btsflag1}   set variable   0x10041=5
    ${btsflag2}   set variable   0x10041 = 5
    Wait Until Keyword Succeeds    15 min    1 min
    ...   csn.Connect to   hostname=${hostname}   username=${asik_username}   password=${asik_password}    alias=gnb
     ${swc_output}   csn.execute    command=cat /ffs/run/swconfig.txt |grep 0x10041   connection=gnb
     ${btslogflag_status}  run keyword and return status   should contain any    ${swc_output.split('\r\n')[0]}   ${btsflag1}   ${btsflag2}
     run keyword if  not ${btslogflag_status}    run keywords
    ...    csn.execute    command=echo "0x10041=5" >> /ffs/run/swconfig.txt;crasign /ffs/run/swconfig.txt.p7   connection=gnb
    ...   AND   Set Suite Variable    ${need_site_reset}    ${true}
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=gnb

Check if Other Flag Added
    [Arguments]    ${hostname}=${asik_addr}    ${action}=UUF
    Wait Until Keyword Succeeds    15 min    1 min
    ...   csn.Connect to   hostname=${hostname}   username=${asik_username}   password=${asik_password}    alias=gnb
    ${swc_output}   csn.execute    command=cat /ffs/run/swconfig.txt    connection=gnb
    ${swcoutput_btslog} =   Remove String   ${swc_output}     0x10041=5   0x10041 = 5    0x1A0020 = 1    0x1A0020=1
    ${swcoutput_btslog}    run keyword if    '${action}'=='reset'    Remove String    ${swcoutput_btslog}    0x190030=0    0x4F0214=0
    ...   ELSE    set variable    ${swcoutput_btslog}
    ${swcoutput_annotation} =   Remove String Using Regexp   ${swcoutput_btslog}     \#.*\r\n
    ${swcoutput_otherflag} =   Remove String   ${swcoutput_annotation}     \r\n
    ${swcoutput_otherflag} =    Strip String    ${swcoutput_otherflag}
    ${otherflag_status}   run keyword and return status  should be empty  ${swcoutput_otherflag}
    run keyword if  ${otherflag_status}   log to console    no other flag in gnb
    ...   ELSE   Run Keywords    log to console   [warning]${swcoutput_otherflag}, will remove those unexpected flags!
    ...   AND   csn.execute   command=cat /dev/null > /ffs/run/swconfig.txt   timeout=10  connection=gnb
    ...   AND   csn.execute   command=echo "0x10041=5" >> /ffs/run/swconfig.txt   connection=gnb
    ...   AND   csn.execute   command=echo "0x1A0020 = 1 #enable SSH" >> /ffs/run/swconfig.txt   connection=gnb
    ...   AND   csn.execute    command=crasign /ffs/run/swconfig.txt.p7   connection=gnb
    ...   AND   Set Suite Variable    ${need_site_reset}    ${true}
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=gnb

Check Flag in FSMF
    ${fsmf_length}   Get Length   ${fsmf}
    ${fsmf_length}    Convert To Integer    ${fsmf_length}
    FOR     ${index}    IN RANGE    ${fsmf_length}
        Wait Until Keyword Succeeds    15 min    1 min    csn.Connect to   hostname=${fsmf[${index}]['test_pc_ip']}
        ...    username=${fsmf[${index}]['test_pc_user']}   password=${fsmf[${index}]['test_pc_pass']}    alias=pc
        csn.Connect to   hostname=${fsmf[${index}]['ssh_addr']}   username=${fsmf[${index}]['username']}
        ...    password=${fsmf[${index}]['password']}   proxy=pc   alias=fsmf
        ${swc_output}   csn.execute    command=cat /ffs/run/swconfig.txt    connection=fsmf
        ${swcoutput_btslog} =   Remove String   ${swc_output}     0x10041=5   0x10041 = 5    0x1A0020 = 1    0x1A0020=1
        ${swcoutput_annotation} =   Remove String Using Regexp   ${swcoutput_btslog}     \#.*\r\n
        ${swcoutput_otherflag} =   Remove String   ${swcoutput_annotation}     \r\n
        ${swcoutput_otherflag} =    Strip String    ${swcoutput_otherflag}
        ${otherflag_status}   run keyword and return status  should be empty  ${swcoutput_otherflag}
        run keyword if  ${otherflag_status}   log to console    no other flag in fsmf
        ...   ELSE   Run Keywords    log to console   [warning]${swcoutput_otherflag}, will remove those unexpected flags in FSMF!
        ...   AND   csn.execute   command=cat /dev/null > /ffs/run/swconfig.txt   timeout=10  connection=fsmf
        ...   AND   csn.execute   command=echo "0x10041=5" >> /ffs/run/swconfig.txt   connection=fsmf
        ...   AND   csn.execute   command=echo "0x1A0020 = 1 #enable SSH" >> /ffs/run/swconfig.txt   connection=fsmf
        ...   AND   csn.execute    command=crasign /ffs/run/swconfig.txt.p7   connection=fsmf
        ...   AND   Site Reset by Webui    ${fsmf[${index}]['mplane_addr']}
        run keyword and ignore error    csn.Disconnect   connection=fsmf
        run keyword and ignore error    csn.Disconnect   connection=pc
        run keyword and ignore error    wait until keyword succeeds    15 min    2 min   Coam Check Site Status
        ...    ip=${fsmf[${index}]['mplane_addr']}
    END

check and remove HWF reset flag
    [Arguments]    ${hostname}=${asik_addr}
    ${flag1}   set variable   0x190030=0
    ${flag2}   set variable   0x4F0214=0
    log to console    check and remove HWF reset flag
    Wait Until Keyword Succeeds    15 min    1 min
    ...   csn.Connect to   hostname=${hostname}   username=${asik_username}   password=${asik_password}    alias=gnb
    ${swc_output1}   csn.execute    command=cat /ffs/run/swconfig.txt |grep 0x190030   connection=gnb
    ${swc_output2}   csn.execute    command=cat /ffs/run/swconfig.txt |grep 0x4F0214   connection=gnb
    ${flag1_status}  run keyword and return status   should contain any    ${swc_output1.split('\r\n')[0]}   ${flag1}
    ${flag2_status}  run keyword and return status   should contain any    ${swc_output2.split('\r\n')[0]}   ${flag2}
    run keyword if   ${flag1_status}    run keywords
    ...    csn.execute    command=sed -i 's/0x190030=0//g' /ffs/run/swconfig.txt   connection=gnb
    ...    AND   csn.execute    command=sed -i 's/#HWF reset flag for releases before 15 December 2021//g' /ffs/run/swconfig.txt
    ...    connection=gnb
    run keyword if   ${flag2_status}    run keywords
    ...    csn.execute    command=sed -i 's/0x4F0214=0//g' /ffs/run/swconfig.txt   connection=gnb
    ...    AND   csn.execute    command=sed -i 's/#HWF reset flag for releases after 15 December 2021//g' /ffs/run/swconfig.txt
    ...    connection=gnb
    run keyword if    ${flag1_status} or ${flag2_status}    run keywords
    ...    csn.execute    command=sed -i '/^[ ]*$/d' /ffs/run/swconfig.txt    connection=gnb
    ...    AND   csn.execute    command=crasign /ffs/run/swconfig.txt.p7   connection=gnb
    ...    AND   Set Suite Variable    ${need_site_reset}    ${true}
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=gnb

check and add HWF reset flag
    [Arguments]    ${hostname}=${asik_addr}
    ${flag1}   set variable   0x190030=0
    ${flag2}   set variable   0x4F0214=0
    log to console    check and add HWF reset flag
    Wait Until Keyword Succeeds    15 min    1 min
    ...   csn.Connect to   hostname=${hostname}   username=${asik_username}   password=${asik_password}    alias=gnb
    ${swc_output1}   csn.execute    command=cat /ffs/run/swconfig.txt |grep 0x190030   connection=gnb
    ${swc_output2}   csn.execute    command=cat /ffs/run/swconfig.txt |grep 0x4F0214   connection=gnb
    ${flag1_status}  run keyword and return status   should contain any    ${swc_output1.split('\r\n')[0]}   ${flag1}
    ${flag2_status}  run keyword and return status   should contain any    ${swc_output2.split('\r\n')[0]}   ${flag2}
    run keyword if  not ${flag1_status}    csn.execute
    ...    command=echo "0x190030=0 #HWF reset flag for releases before 15 December 2021" >> /ffs/run/swconfig.txt
    ...    connection=gnb
    run keyword if  not ${flag2_status}    csn.execute
    ...    command=echo "0x4F0214=0 #HWF reset flag for releases after 15 December 2021" >> /ffs/run/swconfig.txt
    ...    connection=gnb
    run keyword if    '${flag1_status}'=='${False}' or '${flag2_status}'=='${False}'    run keywords
    ...    csn.execute    command=crasign /ffs/run/swconfig.txt.p7   connection=gnb
    ...    AND   Set Suite Variable    ${need_site_reset}    ${true}
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=gnb

Wait Until Git Clone Process Done
    [Arguments]    ${output}
    log to console    Wait Until Git Clone Process Done
    Should Contain   ${output}   Receiving objects: 100%
    Should Contain   ${output}   Resolving deltas: 100%

Save eNB Snapshot
    [Arguments]    ${dir}=1   ${status}=before_recover
    log to console    Save eNB Snapshot logs
    ${index}   set variable  1
    Run   ps -ef|grep ${snapshot_script}|grep -v grep| awk '{print $2}' |xargs kill -9
    @{processId}   create list
    ${ENBs}    Remove Duplicates    ${ENBs}
    FOR   ${single_eNB}  IN   @{ENBs}
       ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
       ${snapshot_path}    set variable     ${OUTPUT_DIR}/${dir}/${status}_eNB_snapshot_${single_eNB['addr']}_${curr_data}.zip
       run keyword and ignore error  Start Process   python   ${snapshot_script}   ${single_eNB['addr']}   ${ENB_user}   ${ENB_psd}
       ...   ${snapshot_path}   snapshot${index}   alias=enb${index}
       ${index}   evaluate  ${index}+1
       sleep   2s
    END

Collect Snapshot By Admin
    [Arguments]   ${host}=${WEBUI_ADDR}   ${dir}=1   ${spec_name}=before_recover    ${timeout}=5400
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    gnb_handler.login   ip=${host}    gnb_type=coam
    ${snapshot_path}   set variable    ${OUTPUT_DIR}/${dir}/${spec_name}_snapshot_${curr_data}.zip
    gnb_handler.collect_snapshot   file_path=${snapshot_path}    timeout=${timeout}
    [Teardown]  run keyword and ignore error  gnb_handler.logout

Upgrade to Current SW Version
    ${active_version}   ${passive_version}    Get gNB SW version
    ${active_release}   ${passive_release}    Get gNB SW release
    ${commonbuild}   run keyword and return status   should contain   ${active_release}   SBTS
    ${build_name}   set variable if   ${commonbuild}   ${active_release}_${active_version}.zip   AirScale-${active_version}.zip
    Force SW Upgrade COAM   build_name=${build_name}

Force SW Upgrade COAM
    [Arguments]   ${build_name}   ${host}=${WEBUI_ADDR}
    gnb_handler.login   ip=${host}    gnb_type=coam
    gnb_handler.force_sw_upgrade   package_path=/home/ute/${build_name}
    [Teardown]  run keyword and ignore error  gnb_handler.logout

Verify RU Status on COAM
    gnb_handler.login   ip=${WEBUI_ADDR}    gnb_type=coam
    @{return_RU_status}   gnb_handler.check_gnb_ru_status
    Check Status Seperately Coam    Return_Status=${return_RU_status}
    [Teardown]  run keyword and ignore error  gnb_handler.logout

Log Collection for Pass Case
    run keyword and ignore error  Run   ps -ef|grep ${enable_collect_log_script}|grep -v grep| awk '{print $2}' |xargs kill -2
    ${active_version}   ${passive_version}    Get gNB SW version
    ${log_dir}   set variable  ../${active_version}_pass_logs
    ${dir_status}   run keyword and return status  OperatingSystem.Directory Should Exist   ${OUTPUT_DIR}/${log_dir}
    run keyword if  not ${dir_status}   OperatingSystem.Create Directory   ${OUTPUT_DIR}/${log_dir}
    ${btslog_status}   Compare File Count in Directory   dir=${log_dir}   filename=btslog*   filecount=1
    ${snapshot_status}   Compare File Count in Directory   dir=${log_dir}   filename=*snapshot*   filecount=1
    run keyword if  '${bts_id}' not in @{Ignore_pass_log}    run keyword if  not ${btslog_status} and ${snapshot_status}
    ...   Save Logs for Pass Case   dir=${log_dir}

Compare File Count in Directory
    [Arguments]   ${dir}   ${filename}   ${filecount}
    @{file}   OperatingSystem.List Files In Directory   ${OUTPUT_DIR}/${dir}   ${filename}
    ${file_length}   Get Length   ${file}
    ${status}   run keyword and return status  should be true  ${file_length}>=${filecount}
    [Return]  ${status}

Save Logs for Pass Case
    [Arguments]  ${dir}
    log to console  Save Logs for Pass Case
    Run   rm -rf ${OUTPUT_DIR}/${dir}
    OperatingSystem.Create Directory   ${OUTPUT_DIR}/${dir}
    save logs   folder=${dir}

Validate IP Reachability from Test PC
    [Arguments]  ${ip_addr}  ${exp_status}
    ${ipv6}  run keyword and return status   should contain   ${ip_addr}  :
    ${output}   run keyword if  '${ipv6}' == 'True'
    ...    RUN    sudo ping6 ${asik_addr} -c 3
    ...    ELSE   RUN    sudo ping ${ip_addr} -c 3
    ${output}    Get Regexp Matches    ${output}    \\d{0,3}% packet loss
    ${output}    Fetch From Left    ${output[0]}    %
    ${status}  set variable if   '${output}'== '0'   ${True}   ${False}
    should be equal   ${exp_status}   ${status}

Get Downtime via Offline and Online Time
    [Arguments]  ${action}
    #    ${offline_output}   RUN    cat /tmp/btslog2/SYSLOG*.LOG |grep 'Online to Offline'
#    @{offline_output}    split string   ${offline_output}   \n
#    ${offline_time}   should match regexp    @{offline_output}[0]   \\d+-\\d+-\\d+T\\d+:\\d+:\\d+.\\d+
#    ${online_output}    RUN    cat /tmp/btslog2/SYSLOG*.LOG |grep 'Offline to Online' |grep 'CellDriver'
#    ${online_output}   run keyword and ignore error   run keyword if   '${online_output}'==''
#    ...   RUN    cat /tmp/btslog2/SYSLOG*.LOG |grep 'Degraded to Online' |grep 'CellDriver'
#    ...   ELSE   RUN    cat /tmp/btslog2/SYSLOG*.LOG |grep 'Offline to Online' |grep 'CellDriver'
#    @{online_output}    split string   @{online_output}[-1]   \n
#    ${online_time}   should match regexp    @{online_output}[-1]  \\d+-\\d+-\\d+T\\d+:\\d+:\\d+.\\d+
#    ${downtime}   DateTime.Subtract Date From Date    ${online_time}    ${offline_time}    compact
    ${admin_active_process}   gnb_handler.get_node_process_counter   ${WEBUI_ADDR}
    Log to Console   Active admin process: ${admin_active_process}
    gnb_handler.login   ip=${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    ...    gnb_type=coam   connection=downtime
    gnb_handler.collect_im_snapshot     connection=downtime    target_file_name=${OUTPUT_DIR}/${TEST_NAME}/${action}/after_upgrade.ims2
    ...    timeout=${300}
    @{file}   OperatingSystem.List Files In Directory   ${OUTPUT_DIR}/${TEST_NAME}/${action}/   admin_api_default_disconnect_at_*
    ${path}    create list    ${OUTPUT_DIR}/${TEST_NAME}/${action}/${file}[0]    ${OUTPUT_DIR}/${TEST_NAME}/${action}/after_upgrade.ims2
    ${downtime}    UUF_common.get_downtime_from_ims2    ${path}
    log to console    downtime: ${downtime}
    run keyword and ignore error   Write gNB Status to Excel   title=Upgrade Downtime   content=${downtime}
#    ${convert_downtime}    DateTime.Convert Time    ${downtime}
    run keyword and ignore error  add json to file    downtime    ${downtime}    ${OUTPUT_DIR}/execution_results.json    ${action}
    ${max_downtime}   Set Downtime by Config
    should be true  ${downtime} < ${max_downtime}
    ...   msg=upgrade downtime ${downtime} exceed performance criteria downtime ${max_downtime}
    [Teardown]   run keyword and ignore error    gnb_handler.logout    connection=downtime

Start Tcpdump for RU
    [Arguments]  ${action}
    log to console  Start Tcpdump for RU
    Run   ps -ef|grep ${ru_tcpdump_script}|grep -v grep| awk '{print $2}' |xargs kill -9
    ${index}   set variable  1
    ${start_time}    DateTime.Get Current Date
    ${DATE_STR}   DateTime.Convert Date   ${start_time}   %Y%m%d%H%M
    ${active}  ${passive}   Get gNB SW version    format=full
    ${active_release}   Fetch From Left    ${active}   _
    FOR   ${ru}   IN   @{rus}
       run keyword and ignore error  Start Process   python   ${ru_tcpdump_script}   ${ru['ctrl_addr']}   ${ru['ctrl_username']}
       ...   ${ru['ctrl_password']}   ${ru['addr']}   ${RU_tcpdump_command}    ${value['ru_type']}    ${active_release}
       ...   ${OUTPUT_DIR}/ru_tcpdump_${action}_${DATE_STR}_${ru['ctrl_addr']}.log   alias=ru${index}
       ${index}   evaluate  ${index}+1
    END

Save RU Tcpdump Through Local IP
    [Arguments]   ${dir}   ${filename}
    ${index}   set variable  1
    FOR   ${value}   IN   @{rus}
       continue for loop if   '${value['ctrl_addr']}'=='1.1.1.1'
       run keyword and ignore error  Stop RU Tcpdump collection   alias=ru${index}
       ${index}   evaluate  ${index}+1
       run keyword and ignore error  Save RU Tcpdump Through Local IP Separately   RU_addr=${value['addr']}   RU_username=${value['username']}
       ...   RU_password=${value['password']}   TAF_addr=${value['ctrl_addr']}   TAF_username=${value['ctrl_username']}
       ...   TAF_password=${value['ctrl_password']}   dir=${dir}  filename=${filename}
    END

Save RU Tcpdump Through Local IP Separately
    [Arguments]   ${RU_addr}   ${RU_username}   ${RU_password}   ${TAF_addr}   ${TAF_username}   ${TAF_password}   ${dir}   ${filename}
    ${connection_taf}  wait until keyword succeeds  3 times   5s   csn.connect_to
    ...   hostname=${TAF_addr}    username=${TAF_username}    password=${TAF_password}    alias=taf
    ${connection_ru}  wait until keyword succeeds  10 min   10s   csn.Connect To    hostname=${RU_addr}    username=${RU_username}
    ...   password=${RU_password}   proxy=taf   alias=RU
    sleep   10s
    run keyword and ignore error   wait until keyword succeeds  3 times   10s   csn.Download File    remote_path=/ram/${filename}
    ...    local_path=${OUTPUT_DIR}/${dir}/${TAF_ADDR}_${filename}   connection=RU
    [Teardown]  run keywords  run keyword and ignore error   csn.execute   command=rm -rf /ram/${filename}  connection=RU
    ...   AND   run keyword and ignore error   csn.disconnect    connection=RU
    ...   AND   run keyword and ignore error   csn.disconnect    connection=taf

Remove RU Tcpdump Through Local IP
    [Arguments]   ${filename}
    ${index}   set variable  1
    ${active}  ${passive}   Get gNB SW version    format=full
    ${active_release}   Fetch From Left    ${active}   _
    FOR   ${value}   IN   @{rus}
       continue for loop if    '${value['ctrl_addr']}'=='1.1.1.1'
       run keyword and ignore error  Stop RU Tcpdump collection   alias=ru${index}
       ${index}   evaluate  ${index}+1
       run keyword and ignore error  Remove RU Tcpdump Through Local IP Separately   RU_addr=${value['addr']}
       ...   RU_type=${value['ru_type']}   TAF_addr=${value['ctrl_addr']}   TAF_username=${value['ctrl_username']}
       ...   TAF_password=${value['ctrl_password']}   filename=${filename}    release=${active_release}
    END

Remove RU Tcpdump Through Local IP Separately
    [Arguments]   ${RU_addr}   ${RU_type}   ${TAF_addr}   ${TAF_username}   ${TAF_password}   ${filename}   ${release}
    ${connection_ru}   ${connection_taf}   UUF_common.connet_to_ru   ${TAF_addr}   ${TAF_username}
    ...   ${TAF_password}   ${RU_addr}   ${RU_type}    ${release}
    run keyword and ignore error   wait until keyword succeeds  3 times   10s   csn.execute   command=rm -rf /ram/${filename}
    ...   connection=${connection_ru}
    UUF_common.disconnect_ru   ${connection_taf}   ${connection_ru}

Stop RU Tcpdump collection
    [Arguments]   ${alias}
    Terminate Process   handle=${alias}   kill=true
    ${pid}   Get Process Id   ${alias}
    run keyword and ignore error  Run   kill -9 ${pid}
    ${result}   Get Process Result   ${alias}

Clear RD Flag in Uboot Environment
     ${connection_asik}=  csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    FOR   ${bsh}   IN    @{bsh_lsit}
       ${uart_output}   csn.execute   command=${bsh} uboot_env get |grep console_uart   timeout=60  connection=gnb
       ${uart_output_status}  run keyword and return status  should contain    ${uart_output}   load pubkey
       run keyword if  not ${uart_output_status}  exit for loop
        ${uart_return_status}   run keyword and return status  should contain   ${uart_output}   console_uart=-1
        run keyword if  not ${uart_return_status}    csn.execute   command=${bsh} uboot_env set console_uart=-1   timeout=60  connection=gnb
       ${watchdog_output}    csn.execute   command=${bsh} uboot_env get |grep disable_watchdog   timeout=60  connection=gnb
       ${watchdog_status}  run keyword and return status   should not contain  ${watchdog_output}   disable_watchdog=1
       run keyword if  not ${watchdog_status}  csn.execute   command=${bsh} uboot_env del disable_watchdog   timeout=60  connection=gnb
    END
    [Teardown]  run keyword and ignore error   csn.disconnect    connection=gnb

Save RUs Console Log
    [Arguments]   ${dir}
    FOR   ${value}   IN   @{rus}
       continue for loop if   '${value['ctrl_addr']}'=='1.1.1.1'
       ${remote_path}    set variable if    '${value['ctrl_username']}'=='nokia5G'    C:\\TEMP\\putty.txt    /tmp/putty.txt
       Save RU Console Log   ru_pc_addr=${value['ctrl_addr']}   ru_pc_username=${value['ctrl_username']}
    ...   ru_pc_password=${value['ctrl_password']}   dir=${dir}   remote_path=${remote_path}
    END

Save RU Console Log
    [Arguments]  ${ru_pc_addr}   ${ru_pc_username}   ${ru_pc_password}   ${dir}   ${remote_path}=/tmp/putty.txt
    ${connection_taf}=  csn.connect_to    hostname=${ru_pc_addr}    username=${ru_pc_username}    password=${ru_pc_password}    alias=testpc
    run keyword and ignore error   csn.Download File    remote_path=${remote_path}
    ...    local_path=${OUTPUT_DIR}/${dir}/RU_console_${ru_pc_addr}.txt   connection=testpc
    csn.disconnect    connection=testpc

Clear Previous RU Console Log
    FOR   ${value}   IN   @{rus}
       continue for loop if   '${value['ctrl_addr']}'=='1.1.1.1'
       ${connection_taf}=  csn.connect_to    hostname=${value['ctrl_addr']}  username=${value['ctrl_username']}
    ...   password=${value['ctrl_password']}   alias=testpc
       run keyword and ignore error   csn.execute   command=sudo chmod 777 /tmp/putty.txt  connection=testpc
       run keyword and ignore error   csn.execute   command=cat /dev/null > /tmp/putty.txt  connection=testpc
       csn.disconnect    connection=testpc
    END

Start tcpdump on ASIK and ABIL
    ${connection_asik}=  csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    run keyword and ignore error    csn.execute   command=nohup tcpdump -i rlan0 -w /tmp/rlan0.pcap   timeout=10  connection=gnb
    wait until keyword succeeds  3 min   5 s    Wait for Fisrt ABIL Available
    run keyword and ignore error    Start Abil Tcpdump Logs By IP Ending   ending_list=${loner_addr_list}
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=gnb

Stop tcpdump and Collect log
    [Arguments]   ${dir}
    ${connection_asik}=  csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    ${start_time}    DateTime.Get Current Date
    ${DATE_STR}   DateTime.Convert Date   ${start_time}   %Y%m%d%H%M
    run keyword and ignore error  csn.execute   command=ps -ef |grep tcpdump |grep -v grep|awk '{print $2}' |xargs kill -9
    ...    timeout=15  connection=gnb
    ${status}    run keyword and return status    csn.Assert file exists    remote_path=/tmp/rlan0.pcap    connection=gnb
    run keyword and ignore error   csn.Download File    remote_path=/tmp/rlan0.pcap
    ...   local_path=${OUTPUT_DIR}/${dir}/rlan0_ASIK_${DATE_STR}.pcap   connection=gnb
    run keyword and ignore error  csn.Execute    command=rm -rf /tmp/rlan0.pcap   connection=gnb
    run keyword and ignore error   Stop and Collect ABIL tcpdump Log to ASIK   ending_list=${loner_addr_list}   dir=${dir}

Start Abil Tcpdump Logs By IP Ending
    [Arguments]    ${ending_list}
    FOR   ${ip_ending}   IN   @{ending_list}
       ${connection_asik}=  csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
       ${unit_exist}   Unit IP reachable   host=${asik_addr}   username=${asik_username}
    ...   password=${asik_password}  ip_addr=192.168.253.${ip_ending}
       run keyword if  ${unit_exist}   Start tcpdump Log on ABIL   ip_abil=${ip_ending}
       run keyword and ignore error    csn.Disconnect   connection=gnb
    END

Start tcpdump Log on ABIL
    [Arguments]  ${ip_abil}
    run keyword and ignore error     csn.Connect to   hostname=192.168.253.${ip_abil}
    ...   username=${asik_username}   password=${asik_password}    proxy=gnb   alias=abil
    wait until keyword succeeds  3 min   10s   Run Keyword And Expect Error   CommandOutputTimeoutError: timed out while waiting for command to end.
    ...   csn.execute   command=nohup tcpdump -i rlan0 -w /tmp/rlan0_ABIL_${ip_abil}.pcap   timeout=10  connection=abil
    run keyword and ignore error    csn.Disconnect   connection=abil

Stop and Collect ABIL tcpdump Log to ASIK
    [Arguments]    ${ending_list}   ${dir}
    ${connection_asik}=  csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    FOR   ${ip_ending}   IN   @{ending_list}
       ${unit_exist}   Unit IP reachable   host=${asik_addr}   username=${asik_username}
    ...   password=${asik_password}  ip_addr=192.168.253.${ip_ending}
       run keyword if   ${unit_exist}   csn.Connect to   hostname=192.168.253.${ip_ending}
    ...   username=${asik_username}   password=${asik_password}    proxy=gnb   alias=abil
       run keyword if   ${unit_exist}   Download ABIL log From ASIK to TAF   ip_abil=${ip_ending}   dir=${dir}
    END
    run keyword and ignore error    csn.Disconnect   connection=gnb

Download ABIL log From ASIK to TAF
    [Arguments]  ${ip_abil}   ${dir}
    ${start_time}    DateTime.Get Current Date
    ${DATE_STR}   DateTime.Convert Date   ${start_time}   %Y%m%d%H%M
    run keyword and ignore error  csn.execute   command=ps -ef |grep tcpdump |grep -v grep|awk '{print $2}' |xargs kill -9
    ...   timeout=15  connection=abil
    run keyword and ignore error   csn.Download File    remote_path=/tmp/rlan0_ABIL_${ip_abil}.pcap
    ...   local_path=${OUTPUT_DIR}/${dir}/rlan0_ABIL_${ip_abil}_${DATE_STR}.pcap   connection=abil
    run keyword and ignore error  csn.Execute    command=rm -rf /tmp/rlan0_ABIL_${ip_abil}.pcap   connection=abil
    run keyword and ignore error    csn.Disconnect   connection=abil

Wait for Fisrt ABIL Available
    ${output}  csn.Execute   command=sudo ping 192.168.253.22 -c 3   timeout=60   connection=gnb
    should not contain   ${output}   0 received

Check Active Alarm from NetAct Backend
    [Arguments]  ${netactnode}   ${username}   ${password}   ${btsname}   ${ignore_fault_id}
    log to console  Check Active Alarm from NetAct Backend
    ${active}    wait until keyword succeeds  3 times   10s   get_active_alarm_on_netact_backend
    ...   netactnode=${netactnode}   username=${username}   password=${password}   dn=${btsname}
    ...   ignore_fault=${ignore_fault_id}
    should be empty   ${active}

Dwonload eNB SW to TAF
    [Arguments]  ${lte_build}
    ${enb_release}   Fetch From Left   ${lte_build}   _
    ${download_path}   set variable  ${enb_wft_addr}/${enb_release}
    Run   rm -f wget-log*
    Run   wget -b ${download_path}/${lte_build}_release_BTSSM_downloadable_A54.zip -P /home/ute/
    Wait Until Keyword Succeeds   2h   2min   taf_env.Wait Until wget process done
    ...   ${lte_build}
    Run   mv /home/ute/${lte_build}_release_BTSSM_downloadable_A54.zip /home/ute/${lte_build}.zip

Create Btslog log collection on remote machine for UUF
    [Arguments]    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog
    ...             ${btslog_launcher_path}=/opt/btslog/btslog_launcher          ${log_dir}=/tmp/
    ...             ${host}=${tl.test_pc.default_ssh_connection_details.addr}
    ...             ${user}=${tl.test_pc.default_ssh_connection_details.username}
    ...             ${password}=${tl.test_pc.default_ssh_connection_details.password}
    [Documentation]    create btslog log collector on testvm.
    ...                name: name of the collector. Ex: btslog
    ...                btslog_path: (optional) path of the ‘btslog’ executable default value:”/opt/btslog/btslog”
    ...                btslog_launcher_path: (optional) path of ‘btslog_launcher’
    ...                executable default value:”/opt/btslog/btslog_launcher”
    ...                log_dir: path from where to get btslog files default value: “/tmp/btslog2”
    run keyword and ignore error   Clean BTSlog on Remote Machine   host=${host}   user=${user}   password=${password}
    &{executor}=    create dictionary    host=${host}
    ...                                  user=${user}
    ...                                  password=${password}
    btslog.create_btslog_collector       name=${name}          btslog_path=${btslog_path}
    ...                                  btslog_launcher_path=${btslog_launcher_path}
    ...                                  executor=${executor}    log_dir=${log_dir}
    btslog.Set Suite Alias               ${name}
    Wait Until Keyword Succeeds    3x   5s    core.setup_collectors    names=${name}
    core.start_collectors                names=${name}

Clean BTSlog on Remote Machine
    [Arguments]  ${host}   ${user}   ${password}
#    ${cmd_prefix}   Set Variable If   '${user}'=='root'   ${EMPTY}   sudo${SPACE}
    csn.Connect to   hostname=${host}   username=${user}   password=${password}  alias=testpc
    csn.Execute   command=pkill -9 -f -x '/opt/btslog/btslog -NOGUI'   timeout=60   connection=testpc
    csn.Execute   command=rm -rf /tmp/BTSLogCommandsLocalServer   timeout=60    connection=testpc
    ${iptables_ruls}    csn.Execute    sudo iptables -L    connection=testpc
    ${contain_100}    run keyword and return status    should contain    ${iptables_ruls}    192.168.100.0/24
    ${contain_101}    run keyword and return status    should contain    ${iptables_ruls}    192.168.101.0/24
    run keyword if  not ${contain_100}    csn.Execute
    ...    command=sudo iptables -I INPUT -p udp -s 192.168.100.1/24 -j ACCEPT   timeout=60    connection=testpc
    run keyword if  not ${contain_101}    csn.Execute
    ...    command=sudo iptables -I INPUT -p udp -s 192.168.101.1/24 -j ACCEPT   timeout=60    connection=testpc
    [Teardown]   csn.Disconnect   connection=testpc

Check If GPS Upgrade Alarm Clear and GPS Status
    [Arguments]  ${ip}=${WEBUI_ADDR}
    log to console    Check GPS Firmware Upgrade Alarm
    wait until keyword succeeds    20 min   1min    Check GPS Firmware Upgrade Alarm Not Exist    ${ip}
    log to console    Check GPS Status on COAM
    run keyword if    '1pps/ToD from external GNSS receiver' in ${syncInputType}
    ...   wait until keyword succeeds    10 min   30s    Check GPS Status on COAM    ${ip}

Check GPS Firmware Upgrade Alarm Not Exist
    [Arguments]  ${ip}=${WEBUI_ADDR}
    gnb_handler.login   ip=${ip}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   gnb_type=coam   connection=gnb
    @{return_active_alarm}   gnb_handler.get_active_alarms   connection=gnb   except_alarms=${Ignore_Fault}
    ${fault_status}    find_value_in_list    ${return_active_alarm}   faultId   ${GPS_firmware_upgrade_alarm}
    run keyword if    ${fault_status}   fail
    [Teardown]    gnb_handler.logout   connection=gnb

Validate PM Report Generated on gNB
    [Arguments]  ${pmcounter}=M55601C00002  ${host}=${cu_addr}   ${user}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}   ${port}=${443}
    log to console    Validate PM Report Generated on gNB
    ${cellid}    UUF_common.get_random_cell_id    ${cu_addr}    ${WEBUI_USER}    ${WEBUI_PASSWORD}
    ${pm_counter_value}   get_pm_counter_from_gnb   cellid=${cellid}   pmcounter=${pmcounter}   host=${host}
    Should Not Be empty   ${pm_counter_value}

Set Downtime by Config
    ${source_release}   Catch build release   ${origin_version}
    ${target_release}   Catch build release   ${upgrade_version}
    ${upgrade_path}   set variable if  '${source_release}' == '${target_release}'   Intra   Inter
    ${core_type}   set variable if   '${cellDepType}[0]' == 'SA'   SA   NSA
    ${downtime_index}   set variable   ${target_release}_${upgrade_path}_${core_type}
    ${downtime}   set variable    ${Downtime_With_Different_Config}[${downtime_index}]
    [Return]  ${downtime}

Downgrade to Lower Release
    Run Keyword If   '${MRBTS_ID}' in @{Dual_Core_BTS_ID}   Fail   Dual Core Module can not Downgrade to Lower Release !
    ${o_release}   Catch build release   ${origin_version}
    ${scf_existstatus}   ${scf_path}   Find and Download SCF for Commissioning
    run keyword if  not ${scf_existstatus}    FAIL    lower release scf not exist,downgrade will not perfrom!
    Check taget SW package exist in taf server    ${origin_version}
    Check and Ensure Enable Ssh Flag in Swconfig File
    Wait Until Keyword Succeeds   20 min   10 s   Coam Check Site Status
    ${lmp_connection}   COAM LMP Login
    log to console   start to downgrade and reset configuration!
    coam.reset_configuration    remove_site_id=${MRBTS_ID}   timeout=500   connection=${lmp_connection}
    run keyword and ignore error   COAM LMP Logout
    Wait Until Keyword Succeeds   20 min   10 s    Check bts status should be   host=${LMP_ADDR}   status=NotCommissioned
    COAM Upgrade package    ${origin_version}    ${LMP_ADDR}
    run keyword and ignore error   Wait Until Keyword Succeeds   5 min   10 s   Validate IP Reachability from Test PC
    ...   ip_addr=${LMP_ADDR}   exp_status=${False}
    Wait Until Keyword Succeeds   20 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${LMP_ADDR}   exp_status=${True}
    run keyword if   ${o_release.startswith('5G')}   Delete User Json File
    Wait Until Keyword Succeeds   3 min   10 s    gnb_handler.login   ip=${LMP_ADDR}
     ...   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   gnb_type=coam   connection=gnb
    Wait Until Keyword Succeeds   20 min   10 s    Check ASIK Status Coam
#    Wait Until Keyword Succeeds   20 min   10 s    Check ABIL Status Coam
    Wait Until Keyword Succeeds   3x   30s   gNB_import_SCF_on_COAM    ${LMP_ADDR}    ${scf_path}
    Run Keyword and Ignore Error   Wait Until Keyword Succeeds   20 min   10 s
    ...   Check bts status should be   status=Configured
    ${fault23_exist}   run keyword and return status
    ...   Wait Until Keyword Succeeds   20 min   10 s    Ensure Fault 23 Raised
    Log to Console   Start to cancel fault 23
    run keyword if  ${fault23_exist}   Upgrade to Current SW Version
    Wait Until Keyword Succeeds   20 min   10 s   Coam Check Site Status

gNB_import_SCF_on_COAM
    [Arguments]   ${ip_webui}   ${scf_file}
    ${connection}   wait until keyword succeeds  3 min   10 s   coam.connect_to   bts_host=${ip_webui}   name=COAM
    Log to console   \nImport SCF File: ${scf_file}
    run keyword and ignore error  selenium_sbts.disable_message_box
    run keyword and ignore error  selenium_sbts.disable_screen_lock
    wait until keyword succeeds  20min   10min   coam.perform_commissioning
    ...   scf_file=${scf_file}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=${connection}
    [Teardown]  run keyword and ignore error  coam.teardown   connection=${connection}

Find and Download SCF for Commissioning
    ${ori_release}   Catch build release   ${origin_version}
#    ${scf}   set variable   Convert To Lowercase
#    ...   gnb_scf_${ori_release}_${stand_alone}_${netact_global_configuration['${netact_nodeip}']['name']}.xml
    ${NE_release}   Convert To Lowercase   ${ori_release}
    ${stand_alone}    Online Get BTS Parameter value    ip_addr=${cu_addr}   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...   filter_param=gNB CU type
    ${stand_type}   Convert To Lowercase   ${stand_alone}
    ${NetAct_name}   Convert To Lowercase   ${netact_global_configuration['${netact_nodeip}']['name']}
    ${if_both}   run keyword and return status    should contain   ${stand_type}   +
    ${scf}   set variable if   ${if_both}    gnb_scf_${NE_release}_nsa+sa_${NetAct_name}.xml
    ...   gnb_scf_${NE_release}_${stand_type}_${NetAct_name}.xml
    ${scf_link}   set variable   git@gitlabe1.ext.net.nokia.com:SG8/golden_scf.git
    Run    sudo rm -rf /home/ute/scf/
    Sleep    10s
    Run    sudo rm -f /home/ute/output*.log
    ${output}    Run   git clone ${scf_link} /home/ute/scf --progress --verbose
    Wait Until Git Clone Process Done    output=${output}
    ${output}    Run    ls /home/ute/scf/TL${MRBTS_ID}/COAM/
    ${scf_existstatus}   run keyword and return status  evaluate   ${output.count('${scf}')}>0
    ${scf_path}   set variable   /home/ute/scf/TL${MRBTS_ID}/COAM/${scf}
    Get SCF Param    SCF_path=${scf_path}
    [Return]   ${scf_existstatus}   ${scf_path}

Online Get BTS Parameter value
    [Arguments]  ${ip_addr}   ${dist_name}   ${filter_param}
    selenium_coam.login
    ...    url=https://${ip_addr}/    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
    ${value}   selenium_coam.get_parameter_value   dist_name=${dist_name}
     ...   filter_param=${filter_param}
    [Return]  ${value}
    [Teardown]  run keyword and ignore error    selenium_coam.logout

Ensure Fault 23 Raised
    ${fault23_exist}   Check If Fault existed   ${23}
     should be equal    ${fault23_exist}    ${True}
    [Return]   ${fault23_exist}

Check eNB Cell Status
    log to console  Check eNB Cell Status
    ${abnormal_enb_list}   create list
    ${ENBs}    Remove Duplicates    ${ENBs}
    FOR   ${enb}   IN   @{ENBs}
        Get eNB SW version   lte_addr=${enb['addr']}
        ${lte_status}   run keyword and return status   Check eNB Cell Status Seperately   lte_addr=${enb['addr']}
        append to list     ${abnormal_enb_list}   ${lte_status}
    END
    set suite variable  ${abnormal_enb_list}
    ${enb_status}  run keyword and return status  list should not contain value   ${abnormal_enb_list}   ${False}
    set suite variable  ${enodeb_status}   ${enb_status}
    run keyword if  not ${enodeb_status}   FAIL

Check eNB Cell Status Seperately
    [Arguments]   ${lte_addr}
    gnb_handler.login   ip=${lte_addr}   gnb_type=enb   connection=enb_conn
    Get Cell Status Coam   connection=enb_conn   check_proceduralStatus=${False}
    Check Cablink Status Coam    enb_conn
    [Teardown]  run keyword and ignore error  gnb_handler.logout   connection=enb_conn

Check eNB Active Alarms
    [Arguments]  ${action}=None
    log to console  Check eNB Active Alarms
    ${ENBs}    Remove Duplicates    ${ENBs}
    FOR   ${enb}   IN   @{ENBs}
        run keyword and continue on failure   Check Single eNB Active Alarms
        ...   ip=${enb['addr']}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}    action=${action}
#       gnb_handler.login   ip=${enb['addr']}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   gnb_type=coam   connection=enb_conn
#       @{return_active_alarm}   gnb_handler.get_active_alarms   connection=enb_conn   except_alarms=${eNB_Ignore_Fault}
#       run keyword and ignore error  add json to file    eNB_active_alarm    ${return_active_alarm}
#       ...    ${OUTPUT_DIR}/execution_results.json    ${action}
#       Run Keyword If    ${return_active_alarm}!=[]   FAIL    [ERROR] Active Alarm: ${return_active_alarm}
#       run keyword and ignore error  gnb_handler.logout   connection=enb_conn
    END

Check Single eNB Active Alarms
    [Arguments]  ${ip}   ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}    ${action}=None
    gnb_handler.login   ip=${ip}   username=${username}   password=${password}   gnb_type=coam   connection=enb_conn
    @{return_active_alarm}   gnb_handler.get_active_alarms   connection=enb_conn   except_alarms=${eNB_Ignore_Fault}
    ${enb_alarm}    get json from file    eNB_active_alarm    ${OUTPUT_DIR}/execution_results.json    ${action}
    Set To Dictionary    ${enb_alarm}    ${ip}    ${return_active_alarm}
    run keyword and ignore error  add json to file    eNB_active_alarm    ${enb_alarm}
    ...    ${OUTPUT_DIR}/execution_results.json    ${action}
    Run Keyword If    ${return_active_alarm}!=[]   FAIL    [ERROR] Active Alarm: ${return_active_alarm}
    [Teardown]  run keyword and ignore error  gnb_handler.logout   connection=enb_conn

Start Deltaplan Monitor and Save Deltaplan
    log to console  Start Deltaplan Monitor and Save Deltaplan
    run keyword and ignore error  Run   ps -ef|grep ${deltaplan_script}|grep -v grep| awk '{print $2}' |xargs kill -9
    ${current_date}   DateTime.Get Current Date
    ${date_str}   DateTime.Convert Date   ${current_date}   %Y%m%d%H%M
    run keyword and ignore error  Start Process   python   ${deltaplan_script}   ${asik_addr}   ${asik_username}   ${asik_password}
    ...   /ram/ne3sadapt/cm_fullplan/deltaplan*   ${OUTPUT_DIR}/Deltaplan_${date_str}.xml   alias=gNB

Stop Deltaplan Monitor Script
    log to console  Stop Deltaplan Monitor Script
    run keyword and ignore error  Run   ps -ef|grep ${deltaplan_script}|grep -v grep| awk '{print $2}' |xargs kill -9

Check if Python Process Stop
    [Arguments]  ${python_script}
    ${pid}   Run   ps -ef|grep ${python_script}|grep -v grep| awk '{print $2}'
    should be empty  ${pid}

Stop eNB Snapshot Process
    [Arguments]  ${timeout}=10
    ${status}   run keyword and return status  wait until keyword succeeds  ${timeout}min   10s   Check if Python Process Stop   ${snapshot_script}
    run keyword if  not ${status}   run keywords   run keyword and ignore error
    ...   Run   ps -ef|grep ${snapshot_script}|grep -v grep| awk '{print $2}' |xargs kill -9
    ...   AND   run keyword and ignore error  Run   ps -ef|grep admin|grep -v grep| awk '{print $2}' |xargs kill -9

Check gNB Version is Common Build
    [Arguments]  ${version}
    ${is_common}   run keyword and return status   should contain   ${version}   SBTS
    ${commond_build}   run keyword if  ${is_common}   Split String   ${version}   _   1
    ${gNB_version}   set variable if   ${is_common}   ${commond_build}[1]   ${version}
    [Return]  ${gNB_version}


Enable ssh to RU for ControlPC
    log to console  Enable ssh to RU from ControlPC
    run keyword and ignore error  Run   ps -ef|grep ${enable_ssh_script}|grep -v grep| awk '{print $2}' |xargs kill -9
    ${index}   set variable  1
    ${active}  ${passive}   Get gNB SW version    format=full
    ${active_release}   Fetch From Left    ${active}   _
    FOR   ${value}   IN   @{rus}
        ${ru_ssh_username_and_password}    UUF_common.get_ru_username_password    ${value['ru_type']}    ${active_release}
        run keyword and ignore error  Start Process   python   ${enable_ssh_script}   ${value['ctrl_addr']}   ${value['ctrl_username']}
        ...   ${value['ctrl_password']}   ${value['addr']}   @{ru_ssh_username_and_password}   alias=ru${index}
        ${index}   evaluate  ${index}+1
    END

Enable LMI on RU via System Module
    log to console  Enable ssh to RU for gNB
    run keyword and ignore error   Login to RU via System Module and execute command
    ...   command=lmi-eth on   cmd_with_sudo=${True}

Login to RU via System Module and execute command
    [Arguments]  ${command}   ${cmd_with_sudo}=${False}   ${timeout}=30s
    ${active}  ${passive}   Get gNB SW version    format=full
    ${active_release}   Fetch From Left    ${active}   _
    COAM Login   alias=GNB_OAM
    ${smod_list}   coam.get_fsm_info   connection=GNB_OAM
    ${is_dual_core}   Set Variable If   len(${smod_list}) > 1   ${True}   ${False}
    ${detected_RUs}   Get gNB detected RUs   is_dual_core=${is_dual_core}

    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=gNB
    # Run Keyword And Ignore Error   csn.Execute   command=rm -rf /user/toor4nsn/.ssh/known_hosts   connection=gNB   timeout=60

    ${gnb_left}    Run Keyword If   ${is_dual_core}   If GNB In Left Side    connection=gNB
    ${hostname}   Set Variable If   ${gnb_left}   fct-4a   fct-0a
    Run Keyword If   ${is_dual_core}
    ...   csn.Connect to   hostname=${hostname}   username=${asik_username}   password=${asik_password}   proxy=gNB   alias=dual
    # Run Keyword If   ${is_dual_core}
    # ...   Run Keyword And Ignore Error   csn.Execute   command=rm -rf /user/toor4nsn/.ssh/known_hosts   connection=dual   timeout=60

    FOR   ${ru_info}   IN   @{detected_RUs.items()}
        Run Keyword And Ignore Error   csn.Execute
        ...   command=ssh-keygen -f "/user/toor4nsn/.ssh/known_hosts" -R ${ru_info[1]['ip']}
        ...   connection=${ru_info[1]['source']}
        ...   timeout=60
        ${container_id}   Get FHNET Container ID    ${ru_info[1]['source']}
        ${ru_passwd}   UUF_common.get_ru_username_password   ru_type=${ru_info[1]['type']}   build_release=${active_release}
        ...   if_need_handle_dollar=False
        ${username}   Set Variable   ${ru_passwd[0]['username']}
        ${password}   Set Variable   ${ru_passwd[0]['password']}
        ${exec_cmd}   Set Variable If   $username != "root" and ${cmd_with_sudo}   sudo ${command}   ${command}
        Connect To RU Via FHNET Container   ru_ip_addr=${ru_info[1]['ip']}   ru_username=${username}   ru_password=${password}
        ...   container_id=${container_id}    asik_alias=${ru_info[1]['source']}
        ${command_return}=   csn.execute   command=${exec_cmd}   connection=RU    timeout=${timeout}

        Run Keyword And Ignore Error   csn.Disconnect   connection=RU
        Run Keyword And Ignore Error   csn.Disconnect   connection=Container
    END
    [Return]  ${command_return}
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=RU   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=Container   AND
    ...   Run Keyword And Ignore Error   Run Keyword If   ${is_dual_core}   csn.Disconnect   connection=dual   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=gNB   AND
    ...   Run Keyword And Ignore Error   COAM Logout   connection=GNB_OAM

Enable ssh to RU
    set suite variable     ${enable_ssh_via_PC}   ${False}
    log to console  Enable ssh to RU from gNB
    run keyword and ignore error   run keyword if   '${bts_id}' in @{enable_BTS_ID}   Login to RU via System Module and execute command
    ...   command=lmi-eth on   cmd_with_sudo=${True}    timeout=15s
    ${run_status}   ${ru_pc_reachable}    run keyword and ignore error   Check RU reachability from test PC
    ${active_version}   ${passive_version}    Get gNB SW version
    run keyword and ignore error   run keyword if
    ...   ${ru_pc_reachable}==${False} and '${bts_id}' in @{enable_BTS_ID} and '${active_version}'!='5G21A'
    ...   run keywords    Enable ssh to RU for ControlPC
    ...   AND  set suite variable     ${enable_ssh_via_PC}   ${True}

Stop ssh RU Script for all ControlPC
    log to console  Stop ssh RU Script for all ControlPC
    ${index}   set variable  1
    FOR   ${value}   IN   @{rus}
       run keyword and ignore error  Stop ssh RU Script   alias=ru${index}
       ${index}   evaluate  ${index}+1
    END
    run keyword and ignore error  Run   ps -ef|grep ${enable_ssh_script}|grep -v grep| awk '{print $2}' |xargs kill -9

Stop ssh RU Script
    [Arguments]   ${alias}
    Terminate Process   handle=${alias}   kill=true
    ${pid}   Get Process Id   ${alias}
    run keyword and ignore error  Run   kill -9 ${pid}
    ${result}   Get Process Result   ${alias}

Enable SSH for COAM
    [Arguments]  ${WEBUI_IP}=${LMP_ADDR}   ${WEBUI_USER}=${WEBUI_USER}   ${WEBUI_PASSWORD}=${WEBUI_PASSWORD}
    log to console   \nEnable SSH for COAM
    Wait Until Keyword Succeeds   10 min   1min   selenium_sbts.login   https://${WEBUI_IP}   ${WEBUI_USER}   ${WEBUI_PASSWORD}
    selenium_sbts.enable_ssh_service   timeout=360
    [Teardown]  Run Keyword and Ignore Error   selenium_sbts.logout

Start MaDe log
    log to console  Start journalctl log for RU
    Run   ps -ef|grep ${enable_made_script}|grep -v grep| awk '{print $2}' |xargs kill -9
    ${index}   set variable  1
    ${start_time}    DateTime.Get Current Date
    ${DATE_STR}   DateTime.Convert Date   ${start_time}   %Y%m%d%H%M
    ${active}  ${passive}   Get gNB SW version    format=full
    ${active_release}   Fetch From Left    ${active}   _
    FOR   ${ru}   IN   @{rus}
        continue for loop if   '${pc_addr}'=='1.1.1.1'
        ping slave node    ${ru['ctrl_addr']}    ${ru['ctrl_username']}    ${ru['ctrl_password']}
        run keyword and ignore error  Start Process   python   ${enable_made_script}   ${ru['ctrl_addr']}   ${ru['ctrl_username']}
        ...   ${ru['ctrl_password']}   ${ru['addr']}   ${value['ru_type']}    ${active_release}
        ...   ${OUTPUT_DIR}/journal_ru_made_${DATE_STR}_${ru['ctrl_addr']}.log   alias=ru${index}
        ${index}   evaluate  ${index}+1
    END

ping slave node
    [Arguments]  ${pc_ip}    ${pc_username}    ${pc_password}
    FOR    ${i}    IN RANGE    ${20}
        ${unit_exist}   Unit IP reachable   host=${pc_ip}   username=${pc_username}
        ...   password=${pc_password}  ip_addr=192.168.101.2
        exit for loop if  ${unit_exist}
        sleep  5s
        run keyword if    ${i}==${59}    Fail    msg=Slave node is not pingable.
    END

Get SW Process Duration from SWDLreport
     [Arguments]  ${process}=Download   ${action}=None   ${SW_Process}=${SW_Process}
     ${time}   Create List
     wait until keyword succeeds   3 times   10s   csn.Connect to
     ...   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK
     ${grepText}   set variable   ${SW_Process}[${process}]
     FOR   ${item}   IN   @{grepText}
         ${start_time}   csn.execute    command=cat /ffs/run/config/SWDLreport.txt | grep '${item}'
         ...   timeout=300   connection=ASIK
         @{startTime_split} =   Split String   ${start_time}     \r\n
         ${start}   should match regexp    ${startTime_split}[-2]  \\d+-\\d+-\\d+T\\d+:\\d+:\\d+
         append to list   ${time}   ${start}
     END
     ${Duration}   Subtract Date From Date    ${time}[1]    ${time}[0]    compact
     ${convert_Duration}    Convert Time    ${Duration}
     run keyword and ignore error  add json to file   ${process}   ${convert_Duration}
     ...   ${OUTPUT_DIR}/execution_results.json   ${action}
     [Teardown]   run keyword and ignore error   csn.disconnect    connection=ASIK

Check if Passive Verison is not Target Version
    ${target_ver}   Check gNB Version is Common Build   ${upgrade_version}
    ${active_ver}   ${passive_ver}   Get gNB SW version
    ${passive_not_target}    run keyword and return status    should not be equal    ${passive_ver}    ${target_ver}
    [Return]  ${passive_not_target}

Data Transfer Conducted for Single Cell
    [Arguments]   ${bip_log_path}=1   ${cell_index}=402    ${ue_index}=${0}   ${bip_enable}=${false}    ${traffic_stop}=${true}    ${duration}=90s
    ...   ${tput}=100
    log to console   Data Transfer Conducted for Single Cell
    Create Directory    ${OUTPUT_DIR}/${bip_log_path}
    ${instance_id}   convert to string   ${tl.gnbs[0].instance_id}
    ${id_number}   Get Length   ${instance_id}
    ${iperf_port}   Run Keyword If   '${tl.gnbs[0].instance_id}'=='3'   Set Variable   57${tl.gnbs[0].instance_id}
    ...   ELSE   Set Variable   57808
#    run keyword and ignore error   csn.Connect To   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=bip
#    run keyword and ignore error   Bip Capture with gnbMirroring scripts with retry    connection=bip
    run keyword and continue on failure  Call Setup and check tput  ue_index=${ue_index}   port=${iperf_port}   tput_expect=85
    ...   bip_request=${bip_enable}    traffic_stop=${traffic_stop}    duration=${duration}   tput=${tput}   actImgGeneration=${False}
#    run keyword and ignore error   csn.Connect To   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=bip_again
#    ${bip_log}    run keyword and ignore error   Stop BIP capture on ASIK if needed and download BIP Logs to testPC
#    ...   log_path=${OUTPUT_DIR}/${bip_log_path}    connection=bip_again

Data Transfer Conducted for UUF
    [Arguments]  ${dir}   ${cells}   ${bip_enable}=${false}    ${traffic_stop}=${true}    ${duration}=90s   ${tput}=100
    ${index}   set variable   ${0}
#    ${call_status}   Create List
    ${l3call_status_list}   create list
    FOR  ${cell}  IN   @{cells}
       ${status}   run keyword and return status   Data Transfer Conducted for Single Cell   bip_log_path=${dir}
       ...   cell_index=${cell}   ue_index=${index}   bip_enable=${bip_enable}   traffic_stop=${traffic_stop}   duration=${duration}
       ...   tput=${tput}
       log to console   ${cell} L3call ${status}
#       append to list  ${call_status}   ${status}
       ${l3call_status}   set variable if   ${status}   cell-${cell} pass   cell-${cell} fail
       append to list  ${l3call_status_list}   ${l3call_status}
       ${index}   evaluate   int(${index}+1)
    END
    run keyword and ignore error  add json to file   l3_call   ${l3call_status_list}
    ...   ${OUTPUT_DIR}/execution_results.json   upgrade
#    list should not contain value     ${call_status}   ${False}
    should not contain match     ${l3call_status_list}   cell-* fail

L3call for E2E site
    [Arguments]    ${dir}=GNB_reset
    ${L3callBTS_status}   Run Keyword And Return Status   Dictionary Should Contain Key   ${BTS_L3call}   ${bts_id}
    ${cells}   Run Keyword If  ${L3callBTS_status}   Set Variable   ${BTS_L3call}[${bts_id}]
    ${L3callBTS_status}   Set Variable If  '${bts_id}' in @{E2E_BTS_ID}  ${L3callBTS_status}  ${False}
    ${tput}   Set Variable If  '${bts_id}' in @{E2E_BTS_ID}  ${E2E_L3Call_tput}  ${Common_L3Call_tput}
    Run Keyword If  ${L3callBTS_status} and '${l3_call}'=='Y'
    ...   Data Transfer Conducted for UUF   dir=${TEST_NAME}/${dir}   cells=${cells}   tput=${tput}

Check if Trace Session Alive
    [Arguments]  ${session}
    csn.Connect to   hostname=${cu_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    ${output}   csn.execute    command=netstat -tan |grep ${session}   timeout=15   connection=gnb
    should not be empty   ${output}

WA for Fault 10
    ${RU_num}   Get MO Nmuber from Fault   fault_id=10
    gNB RU Power reset   ${RU_num}
    wait until keyword succeeds  40min   20s   Check Specific RU Status on COAM   ${RU_num}

Power Reset RU for Special Fault
    wait until keyword succeeds  5min   20s   gnb_handler.login   ip=${WEBUI_ADDR}   gnb_type=coam
    @{alarm_list}    gnb_handler.get_active_alarms   except_alarms=${Ignore_Fault}
    run keyword and ignore error  gnb_handler.logout
    ${fault_status}   set variable  ${false}
    FOR    ${alarm}    IN    @{alarm_list}
       ${RU_index}   run keyword if  '${alarm['faultId']}' in ${RU_power_reset_fault}
       ...   Get MO Nmuber from Fault   fault_id=${alarm['faultId']}
       gNB RU Power reset   ${RU_index}
       wait until keyword succeeds  20min   20s   Check Specific RU Status on COAM   ${RU_index}
       exit for loop if  ${RU_index}
    END

Reset GPS and Check GPS Status
    Reset GPS by Command
    wait until keyword succeeds  15min   30s   run keyword  Check GPS Status on COAM

Check Specific RU Status on COAM
    [Arguments]  ${RU_num}
    gnb_handler.login   ip=${WEBUI_ADDR}    gnb_type=coam
    @{Return_Status}   gnb_handler.check_gnb_ru_status
    FOR   ${Module_Status}   IN   @{Return_Status}
       ${status}   run keyword and return status  should contain  ${Module_Status['name']}   ${RU_num}
       run keyword if   ${status}   run keywords
       ...   run keyword and continue on failure   Should Contain    ${Module_Status['availabilityStatus']}    Online
       ...   msg=[ERROR] status abnormal: ${Module_Status['name']} availabilityStatus：${Module_Status['availabilityStatus']}
       ...   AND   run keyword and continue on failure   Should Contain    ${Module_Status['operationalState']}    Enabled
       ...   msg=[ERROR] status abnormal: ${Module_Status['name']} operationalState：${Module_Status['operationalState']}
       ...   AND   run keyword and continue on failure   Should Contain    ${Module_Status['proceduralStatus']}    configured
       ...   msg=[ERROR] status abnormal: ${Module_Status['name']} proceduralStatus：${Module_Status['proceduralStatus']}
       ...   AND   run keyword and continue on failure   Should Contain    ${Module_Status['administrativeState']}   Unlocked
       ...   msg=[ERROR] status abnormal: ${Module_Status['name']}administrativeState：${Module_Status['administrativeState']}
       exit for loop if  ${status}
    END
    [Teardown]  run keyword and ignore error  gnb_handler.logout

Get MO Nmuber from Fault
    [Arguments]  ${fault_id}
    wait until keyword succeeds  5min   30s   gnb_handler.login   ip=${WEBUI_ADDR}   gnb_type=coam
    @{alarm_list}    gnb_handler.get_active_alarms   except_alarms=${Ignore_Fault}
#    ${fault_status}   set variable  ${false}
    FOR    ${alarm}    IN    @{alarm_list}
       ${fault_obj}   set variable   ${alarm["alarmObject"]}
       ${obj_name}   fetch from right  ${fault_obj}   /
       ${obj_num}   fetch from right  ${obj_name}   -
       ${RU_num}   set variable if    "${alarm["faultId"]}"=="${fault_id}"   ${obj_num}
       exit for loop if  ${RU_num}
    END
    [Return]  ${RU_num}
    [Teardown]  run keyword and ignore error  gnb_handler.logout

gNB RU Power reset
    [Arguments]  ${RU_index}=1
    ${status}   run keyword and return status  power reset via facoam or hbte
    ...   host=${rus_PB_info[${RU_index}-1]['addr']}   port=${rus_PB_info[${RU_index}-1]['port']}   model=HBTE
    run keyword if  not ${status}   power reset via facoam or hbte
    ...   host=${rus_PB_info[${RU_index}-1]['addr']}   port=${rus_PB_info[${RU_index}-1]['port']}   model=TOPYOUNG

Varify CM Provsion in Bankend on NetAct via Change RollbackReject
    log to console  Varify CM Provsion in Bankend on NetAct via Change RollbackReject
    ${modified_rollback}   wait until keyword succeeds  3 times   1min   get_parameter_from_webem
    ...   dist_name=${input_btsname}/MNL-1/MNLENT-1/FEATCADM-1   filter_param=Activate SW Rollback Rejection   abbr=actSWRollbackReject
    ...   addr=https://${WEBUI_ADDR}  username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    should be equal  ${modified_rollback}   false

Varify CM Provsion in Bankend on Nom via Change RollbackReject
    log to console    Varify CM Provsion in Bankend on Nom via Change RollbackReject
    log to console    no action in nom

COAM RollbackReject package
    [Arguments]    ${login_ip}=${WEBUI_ADDR}
    log to console    COAM Rollback package
    Wait Until Keyword Succeeds   3 min   5sec    WEBEM Login    https://${login_ip}/
    run keyword and ignore error    selenium_sbts.disable_message_box
    run keyword and ignore error    selenium_sbts.disable_screen_lock
    selenium_sbts.software_rollback
    Check If Trigger RollbackReject Succeed    rollback
    [Teardown]   run keyword and ignore error    WEBEM Logout

Check If Trigger RollbackReject Succeed
    [Arguments]   ${action}   ${package}=${None}    ${type}=gNB
    ${active_version}   ${passive_version}   run keyword if  '${type}'=='gNB'    Get gNB SW version
    ...    ELSE    Get gNB SW version   ${ENBs[1]['addr']}
#    ${passive_build}   Check gNB Version is Common Build   ${passive_version}
    ${target_version}   Check gNB Version is Common Build   ${package}
    ${if_passive_target}    run keyword and return status    should not be equal    ${passive_version}    ${target_version}
#    set suite variable   ${if_passive_target}
    ${sleep_time}    set variable    10s
    FOR    ${i}    IN RANGE    ${60}
        ${result}    selenium_sbts.check_software_update_progress
        ${success_status}    run keyword and return status   should contain    ${result}[status]     Rollback failed, rejected by BTS
        ...    msg=change actSWRollbackReject success
		${reset_status}    run keyword and return status   should contain    ${result}[status]    reset    msg=${result}[status]
        ${if_status_empty}    run keyword and return status   should be empty    ${result}[status]    msg=Result status is empty.
        exit for loop if  ${success_status}
        exit for loop if  ${reset_status}
        exit for loop if  ${if_status_empty}
        sleep  ${sleep_time}
        run keyword if    ${i}==${59}    Fail    msg=BTS has no resetting action.
    END
    run keyword if    ${reset_status} or ${if_status_empty}   Fail    msg=upgrade or rollback failed, ${result}[status]

Change RollbackReject by CM Provsion in Bankend on NetAct
    [Arguments]  ${bts}   ${rollback_status}
    ${provision_command_part1}   set variable  racclimx.sh -op Provision_Mass_Modification -DN
    ${provision_command_part2}   set variable  PLMN-PLMN/${bts}/MNL-1/MNLENT-1/FEATCADM-1 -parameterValuesByNames
    ${provision_command_part3}   set variable  actSWRollbackReject=${rollback_status} -v
    ${provision_command}   set variable   ${provision_command_part1} ${provision_command_part2} ${provision_command_part3}
    ${expect_output}   set variable   Provision of the plan was successful
    wait until keyword succeeds  2 times   1min   Connect to NetAct WasNode and execute command   wasNode_IP=${netact_nodeip}
    ...   omc_uername=${netact_nodeusername}   omc_passowrd=${netact_nodepassword}  command=${provision_command}   expect_output=${expect_output}

Change RollbackReject by CM Provsion in Bankend on Nom
    [Arguments]  ${bts}   ${rollback_status}
    log to console    Change RollbackReject by CM Provsion in Bankend on Nom
    log to console    no action in nom

Check running nms mode
    ${status}    run keyword and return status    dictionary should contain key    ${nom_global_configuration}    ${nom_nodeip}
    ${NMS_TYPE}    set variable if    ${status}    nom     netact
    set suite variable   ${NMS_TYPE}

Check RU reachability from test PC
    ${disconnected_pc}   Create List
    ${ru_pc_reachable}   set variable    ${False}
    FOR   ${value}   IN   @{rus}
       ${pc_addr}   set variable   ${value['ctrl_addr']}
       ${pc_username}   set variable   ${value['ctrl_username']}
       ${pc_password}   set variable   ${value['ctrl_password']}
       ${ru_addr}    set variable   ${value['addr']}
       continue for loop if   '${pc_addr}'=='1.1.1.1'
       log to console    Check RU reachability from test PC ${pc_addr}
       ${ru_pc_reachable}   run keyword and return status
       ...   wait until keyword succeeds   1min   10s   Check control PC and RU connectivity   host=${pc_addr}   username=${pc_username}
       ...   password=${pc_password}   ip_addr=${ru_addr}
       run keyword if   ${ru_pc_reachable}==${False}   Append To List   ${disconnected_pc}   ${pc_addr}
    END
    set suite variable    ${disconnected_pc}
    [RETURN]  ${ru_pc_reachable}

Check control PC and RU connectivity
    [Arguments]   ${host}   ${username}   ${password}   ${ip_addr}
    ${ru_reachable}   set variable    false
    ${pc_reachable}   run keyword and return status    Validate IP Reachability from Test PC
    ...   ip_addr=${host}   exp_status=${True}
    ${ru_reachable}   run keyword if   ${pc_reachable}==${True}
    ...   Unit IP reachable   host=${host}   username=${username}
    ...   password=${password}   ip_addr=${ip_addr}
    run keyword if  not ${pc_reachable}   Log   PC ${host} is not reachable   WARN
    should be equal   ${pc_reachable}   ${True}
    run keyword if  not ${ru_reachable}   Log   RU ${ip_addr} is not reachable from PC ${host}   WARN
    should be equal   ${ru_reachable}   ${True}

Check and Ensure Enable Ssh Flag in Swconfig File
    log to console    Check and ensure enable ssh flag in swconfig file
    ${btsflag1}   set variable   0x1A0020=1
    ${btsflag2}   set variable   0x1A0020 = 1
    Wait Until Keyword Succeeds    15 min    1 min
    ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
     ${swc_output}   csn.execute    command=cat /ffs/run/swconfig.txt |grep 0x1A0020   connection=gnb
     ${btslogflag_status}  run keyword and return status   should contain any    ${swc_output.split('\r\n')[0]}   ${btsflag1}   ${btsflag2}
     run keyword if  not ${btslogflag_status}    run keywords
    ...    csn.execute    command=echo -e "0x1A0020=1" >> /ffs/run/swconfig.txt;crasign /ffs/run/swconfig.txt.p7   connection=gnb
    ...   AND   COAM Reset Site via WebEM
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=gnb

Delete User Json File
    log to console    Delete user json file
    run keyword and ignore error   Wait Until Keyword Succeeds   5 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${LMP_ADDR}   exp_status=${False}
    Wait Until Keyword Succeeds   20 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${LMP_ADDR}   exp_status=${True}
    sleep   120s
    Wait Until Keyword Succeeds    15 min    1 min
    ...   csn.Connect to   hostname=${LMP_ADDR}   username=${asik_username}   password=${asik_password}    alias=lmp_gnb
    csn.execute    command=rm /ffs/run/config/users.json   connection=lmp_gnb
    csn.execute    command=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN   connection=lmp_gnb
    run keyword and ignore error    csn.Disconnect   connection=lmp_gnb
    Wait Until Keyword Succeeds   20 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${LMP_ADDR}   exp_status=${false}
    Wait Until Keyword Succeeds   20 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${LMP_ADDR}   exp_status=${True}

rollback x2enb to lower build
    run keyword if  not ${${DEBUG}}   selenium_netact.enable_virtual_display
    ${active_release}   ${passive_release}   Get gNB SW release   ${ENBs[0]['addr']}
    run keyword if  '${active_release}' > '${passive_release}'
    ...   run keywords    log to console    rollback enb package
    ...   AND   COAM Rollback package    ${ENBs[0]['addr']}
    ...   AND   run keyword and ignore error    Wait Until Keyword Succeeds   30 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${ENBs[0]['addr']}   exp_status=${False}
    ...   AND   Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${ENBs[0]['addr']}  exp_status=${True}
    ...   AND   run keyword and continue on failure   Wait Until Keyword Succeeds   20 min   20 s
    ...   Check X2eNB status    ${ENBs[0]['addr']}

Start BTS LOG Collection In Windows PC
    [Arguments]    ${windows_host}    ${windows_user}    ${windows_password}
    ${Btslog_exist}   run keyword and return status   UUF_common.send_command_on_windows_pc
    ...    hostname=${windows_host}    username=${windows_user}   password=${windows_password}    command=ps -ef |grep BTSlog
    run keyword and ignore error    run keyword if    ${Btslog_exist}    UUF_common.send_command_on_windows_pc
    ...    hostname=${windows_host}   username=${windows_user}    password=${windows_password}    command=taskkill /F /IM BTSlog2.exe
    UUF_common.send_command_on_windows_pc    hostname=${windows_host}    username=${windows_user}   password=${windows_password}
    ...    command=rm -rf /cygdrive/c/TEMP/Logs/*.*
    Execute BTSlog command in Windows PC   host=${windows_host}   user=${windows_user}   password=${windows_password}

Execute BTSlog command in Windows PC
    [Arguments]  ${host}   ${user}   ${password}
    log to console    Start BTSlog Collection in Windows PC
    UUF_common.start_ru_btslog_at_windows_pc    hostname=${host}   username=${user}   password=${password}

Stop and Download Btslog In Windows PC
    [Arguments]    ${dir}    ${host}    ${user}    ${password}
    log to console    Stop and Download Btslog in Windows PC
    UUF_common.send_command_on_windows_pc    hostname=${host}   username=${user}    password=${password}    command=taskkill /F /IM BTSlog2.exe
    ${Btslog_exist}   run keyword and return status   UUF_common.send_command_on_windows_pc
    ...    hostname=${host}    username=${user}   password=${password}    command=ps -ef |grep BTSlog
    run keyword and ignore error    run keyword if    ${Btslog_exist}    UUF_common.send_command_on_windows_pc
    ...    hostname=${host}   username=${user}    password=${password}    command=taskkill /F /IM BTSlog2.exe
    Download BTSlog from Windowns PC    dir=${dir}   win_host=${host}   win_user=${user}    win_password=${password}

Download BTSlog from Windowns PC
    [Arguments]  ${dir}    ${win_host}   ${win_user}   ${win_password}
    log to console    Download BTSlog in Windows PC
    csn.Connect to   hostname=${win_host}   username=${win_user}   password=${win_password}  alias=Windows_pc
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    csn.Execute    command=tar -czvf c:/TEMP/Logs/btslog_${win_host}_${curr_data}.tar c:/TEMP/Logs/SYSLOG* --force-local
    ...    connection=Windows_pc
    sleep   5s
    csn.Download File    remote_path=c:/TEMP/Logs/btslog_${win_host}_${curr_data}.tar
    ...    local_path=${OUTPUT_DIR}/${dir}/RU_btslog_${win_host}.tar   connection=Windows_pc
    sleep   5s
    [Teardown]    csn.Disconnect   connection=Windows_pc

COAM Rollback and Verify
    [Arguments]   ${host}=${cu_addr}
    COAM Simple Rollback Actions    host=${host}
    ${source_build}   Set Variable If   $host==$cu_addr   ${origin_version}   ${enb_source_version}
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated    action=rollback   ip=${host}
    ...   source_build=${source_build}
    Wait Until Keyword Succeeds   10 min   30 s    Coam Check Site Status     if_ignore_cablink=${False}     ip=${host}
    Wait Until Keyword Succeeds   10 min   30 s    Coam Check Site Status     if_ignore_cablink=${False}     ip=${peer_asik_addr}

NetAct SW Operation Steps
    [Arguments]   ${action}=provision   ${host}=${cu_addr}   ${input_btsname}=${input_btsname}
    ${source_build}   Set Variable If   $host==$cu_addr   ${origin_version}   ${enb_source_version}
    ${rollback_status}   Run Keyword and Return Status   NetAct SW ${action}   input_btsname=${input_btsname}
    run keyword if  not ${rollback_status}   Run Keyword and Ignore Error   Wait Until Keyword Succeeds   10 min   20 s
    ...   Validate IP Reachability from Test PC   ip_addr=${host}  exp_status=${False}
    Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC    ip_addr=${host}  exp_status=${True}
    run keyword and ignore error    run keyword if  '${bts_id}' not in @{not_collect_log_when_alarm}
    ...   Wait Until Keyword Succeeds   3x   10 s    Enable collect logs when alarm report
    ...   ${OUTPUT_DIR}/${TEST_NAME}/${action}    ${host}
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated    action=${action}   ip=${host}
    ...   source_build=${source_build}
    Wait Until Keyword Succeeds   10 min   30 s    Coam Check Site Status     if_ignore_cablink=${False}     ip=${host}
    Wait Until Keyword Succeeds   10 min   30 s    Coam Check Site Status     if_ignore_cablink=${False}     ip=${peer_asik_addr}

Check Acive Alarm between WebEM and NetAct
    [Arguments]  ${netactnode}   ${username}   ${password}   ${btsname}   ${ignore_fault_id}=${empty}
    log to console    \nStart to check if FM can auto upload active alarm
    gnb_handler.login   ip=${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   gnb_type=coam   connection=gnb
    @{WebEM_active_alarm}   gnb_handler.get_active_alarms   connection=gnb
    ${WebEM_active_alarm}   convert to string   ${WebEM_active_alarm}
    ${fault_exist_in_WebEM}   run keyword and return status   should contain   ${WebEM_active_alarm}   61652
    ${active_alarm_NetAct}    wait until keyword succeeds  3 times   10s   get_active_alarm_on_netact_backend
    ...   netactnode=${netactnode}   username=${username}   password=${password}   dn=${btsname}
    ${active_alarm_NetAct}   convert to string   ${active_alarm_NetAct}
    ${fault_exist_in_NetAct}   run keyword and return status   should contain   ${active_alarm_NetAct}   61652
    ${fault_exist}    run keyword if   ${fault_exist_in_WebEM} and ${fault_exist_in_NetAct}  run keyword and return status
    ...   Change Prameter in NetAct and Check alarm whether exist
    ...   netactnode=${netactnode}   username=${username}   password=${password}
    ...   param_path=${btsname}/MNL-1/MNLENT-1/SECADM-1   param_value=false   param_name=actServicePortState   btsname=${btsname}
    run keyword and continue on failure    run keyword if    ${fault_exist_in_WebEM} and ${fault_exist_in_NetAct}    run keywords
    ...   run keyword and continue on failure    run keyword if  not ${fault_exist}    FAIL
    ...   AND   log to console    \nFM Auto Uplod Verify finish And Start to change parameter to previous value!
    ...   AND   Change Parameter Value by CM Provsion in Bankend on NetAct
    ...   param_path=${btsname}/MNL-1/MNLENT-1/SECADM-1  param_value=true   param_name=actServicePortState
    ${fault_exist}    run keyword if   ${fault_exist_in_WebEM}==${False} and ${fault_exist_in_NetAct}==${False}  run keyword and return status
    ...   Change Prameter in NetAct and Check alarm whether exist
    ...   netactnode=${netactnode}   username=${username}   password=${password}
    ...   param_path=${btsname}/MNL-1/MNLENT-1/SECADM-1   param_value=true   param_name=actServicePortState   btsname=${btsname}
    run keyword and continue on failure    run keyword if   ${fault_exist_in_WebEM}==${False} and ${fault_exist_in_NetAct}==${False}    run keywords
    ...   run keyword if    ${fault_exist}==${False}    FAIL
    ...   AND   log to console    \nFM Auto Uplod Verify finish And Start to change parameter to previous value!
    ...   AND   Change Parameter Value by CM Provsion in Bankend on NetAct   param_path=${btsname}/MNL-1/MNLENT-1/SECADM-1   param_value=false
    ...   param_name=actServicePortState
    run keyword and continue on failure   run keyword if  ${fault_exist_in_WebEM}==${False} and ${fault_exist_in_NetAct}   FAIL
    run keyword and continue on failure   run keyword if  ${fault_exist_in_NetAct}==${False} and ${fault_exist_in_WebEM}   FAIL
    [Teardown]    gnb_handler.logout   connection=gnb

Change Prameter in NetAct and Check alarm whether exist
    [Arguments]  ${netactnode}   ${username}   ${password}   ${param_path}   ${param_value}   ${param_name}
    ...   ${btsname}   ${ignore_fault_id}=${EMPTY}
    Change Parameter Value by CM Provsion in Bankend on NetAct   param_path=PLMN-PLMN/${input_btsname}/MNL-1/MNLENT-1/SECADM-1
    ...   param_value=${param_value}   param_name=${param_name}
    ${active_alarm_NetAct}    wait until keyword succeeds  3 times   10s   get_active_alarm_on_netact_backend
    ...   netactnode=${netactnode}   username=${username}   password=${password}   dn=${btsname}
    ${active_alarm_NetAct}   convert to string   ${active_alarm_NetAct}
    ${fault_exist}   run keyword and return status   should contain   ${active_alarm_NetAct}   61652
    [Return]   ${fault_exist}

Enable collect logs when alarm report
    [Arguments]     ${location}   ${ip}=${WEBUI_ADDR}   ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
    log to console  Enable collect logs when alarm report
    Create Directory     ${location}
    ${vm_ip}   set variable    ${tl.test_pc.default_ssh_connection_details.addr}
    ${vm_username}   set variable    ${tl.test_pc.default_ssh_connection_details.username}
    ${vm_password}   set variable    ${tl.test_pc.default_ssh_connection_details.password}
    run keyword and ignore error  Run   ps -ef|grep ${enable_collect_log_script}|grep -v grep| awk '{print $2}' |xargs kill -2
    ${active}  ${passive}   Get gNB SW version    format=full
    ${active_release}   Fetch From Left    ${active}   _
    ${ignore_history_fault}     Set Variable if   '${bts_id}' in @{Concurrent_BTS_ID}   ${ignore_history_fault_for_concurrent}
    ...   ${if_moran}   ${ignore_history_fault_for_concurrent}
    ...   '${bts_id}' in @{Multi_BTS_ID}   ${ignore_history_fault_for_concurrent}
    ...   ${ignore_history_fault}
    ${need_open_lmi}    Set Variable if   '${bts_id}' in @{enable_BTS_ID}    ${True}    ${False}
    run keyword and ignore error  Start Process   python   ${enable_collect_log_script}   ${ip}   ${username}   ${password}
    ...   ${rus}   ${ignore_history_fault}   ${ignore_history_fault}   ${vm_ip}   ${vm_username}   ${vm_password}   ${location}
    ...   ${active_release}    ${need_open_lmi}   alias=collect_log_when_alarm_report
    ${output}   RUN    ps -ef|grep collect|grep -v grep
    should not be empty    ${output}

Disable RU Swcofnig Cleanup
    [Arguments]   ${ru_list}=${rus}
    ${ip}   set variable if   '${bts_id}' in @{Multi_BTS_ID}   ${peer_asik_addr}  ${LMP_ADDR}
    ${active}  ${passive}   Get gNB SW version    format=full   ip=${ip}
    ${active_release}   Fetch From Left    ${active}   _
    FOR   ${value}   IN   @{ru_list}
       continue for loop if    '${value['ctrl_addr']}'=='1.1.1.1'
       run keyword if   '${value['ru_type']}' in @{disable_swconfig_cleanup_ru}   Add Disable Cleanup File   ${value}   ${active_release}
    END

Add Disable Cleanup File
    [Arguments]   ${value}   ${release}
    set suite variable  ${TAF_ADDR}   ${value['ctrl_addr']}
    set suite variable  ${TAF_USERNAME}   ${value['ctrl_username']}
    set suite variable  ${TAF_PASSWORD}   ${value['ctrl_password']}
    set suite variable  ${RU_ADDR}   ${value['addr']}
    set suite variable  ${RU_TYPE}   ${value['ru_type']}
    ${local_connected}   Try RU connected by local   RU_ADDR=${RU_ADDR}
    ...   TAF_ADDR=${TAF_ADDR}   TAF_USERNAME=${TAF_USERNAME}   TAF_PASSWORD=${TAF_PASSWORD}
    ${connection_ru}   ${connection_taf}   run keyword if   ${local_connected}   UUF_common.connet_to_ru   ${TAF_ADDR}   ${TAF_USERNAME}
    ...   ${TAF_PASSWORD}   ${RU_ADDR}   ${RU_TYPE}    ${release}
    run keyword if   ${local_connected}   csn.execute   command=touch /ram/disable_swman_cleanup   timeout=10  connection=${connection_ru}
    run keyword if   ${local_connected}==${False}   Log to console   can't connect to RU from pc ${TAF_ADDR}
    [Teardown]   UUF_common.disconnect_ru   ${connection_taf}   ${connection_ru}

Precheck RU Flags
    Log to console   Check if standard flags enabled on RU
    run keyword and ignore error   Run   ps -ef|grep ${enable_ru_flag_script}|grep -v grep| awk '{print $2}' |xargs kill -9
    ${active}  ${passive}   Get gNB SW version    format=full
    ${release}   Fetch From Left    ${active}   _
    ${index}   set variable  1
    FOR   ${ru}   IN   @{rus}
        continue for loop if   '${ru['ctrl_addr']}'=='1.1.1.1'
        continue for loop if   '${ru['ctrl_addr']}'=='10.10.10.10'
        ${ru_ip_segment}    should match regexp   ${ru['addr']}   \\d+.\\d+.\\d+
        ${ru_ip_gw}   Get RU Gateway IP   ${ru['ctrl_addr']}   ${ru['ctrl_username']}   ${ru['ctrl_password']}   ${ru_ip_segment}
        ${if_standard}   ${if_standard_local}   Check If RU Standard Flag Existed   ${ru['addr']}   ${ru['ru_type']}   ${ru['ctrl_addr']}
        ...   ${ru['ctrl_username']}   ${ru['ctrl_password']}   ${release}
        run keyword if   ${if_standard}==${False} and ${if_standard_local}==${False}   run keyword and ignore error
        ...   Start Process   python   ${enable_ru_flag_script}   ${ru['ctrl_addr']}   ${ru['ctrl_username']}   ${ru['ctrl_password']}
        ...   ${ru['addr']}   ${ru['ru_type']}    ${release}   ${ru_ip_gw}   alias=ru${index}
        ${index}   evaluate  ${index}+1
    END

Check If RU Standard Flag Existed
    [Arguments]  ${ru_addr}   ${ru_type}  ${taf_addr}   ${taf_user}   ${taf_pw}   ${release}
    ${connection_ru}   ${connection_taf}   UUF_common.connet_to_ru   ${taf_addr}   ${taf_user}
    ...   ${taf_pw}   ${ru_addr}   ${ru_type}    ${release}
    ${swconfig_output}   csn.execute   command=cat /rom/swconfig.txt   timeout=10  connection=${connection_ru}
    ${if_swconfig_exist}    run keyword and return status   should not contain   ${swconfig_output}   No such file or directory
    ${swconfig_local_output}   csn.execute   command=cat /rom/swconfig_local.txt   timeout=10  connection=${connection_ru}
    ${if_swconfig_local_exist}  run keyword and return status   should not contain   ${swconfig_local_output}   No such file or directory
    run keyword if   ${if_swconfig_exist}   Check If Unexpected Flag Existed
    ...   ${swconfig_output}   swconfig.txt   ${connection_ru}
    run keyword if   ${if_swconfig_local_exist}   Check If Unexpected Flag Existed
    ...   ${swconfig_local_output}  swconfig_local.txt   ${connection_ru}
    ${swconfig_output_1}   csn.execute   command=cat /rom/swconfig.txt   timeout=10  connection=${connection_ru}
    ${swconfig_local_output_1}   csn.execute   command=cat /rom/swconfig_local.txt   timeout=10  connection=${connection_ru}
    ${if_standard}   run keyword and return status   should contain    ${swconfig_output_1}   0x10042
    ${if_standard_local}   run keyword and return status   should contain    ${swconfig_local_output_1}   0x10042
    ###remove unused flag
    [Return]   ${if_standard}   ${if_standard_local}
    [Teardown]   UUF_common.disconnect_ru   ${connection_taf}   ${connection_ru}

Check If Unexpected Flag Existed
    [Arguments]    ${flags}   ${flag_file}  ${alias}
     ${flag_split}  split string  ${flags}   \r\n
     ${index}   set variable  1
     FOR  ${value}  IN    @{flag_split}
        continue for loop if   '${value}'==''
        ${swconfig_flag}   should match regexp   ${value}   \\d+x\\d+
        ${if_unexpected}    run keyword and return status   list should not contain value  ${RU_Standard_Flag}   ${swconfig_flag}
        run keyword if  ${if_unexpected}    run keywords    Log to console   Unexpected Flag ${swconfig_flag} Existed on RU, Will Remove it.
        ...   AND   csn.execute   command=rm /rom/${flag_file}   timeout=10  connection=${alias}
        exit for loop if   ${if_unexpected}
        ${index}   evaluate  ${index}+1
     END

Get RU Gateway IP
    [Arguments]  ${ru_pc_addr}   ${ru_pc_user}   ${ru_pc_pw}   ${ru_ip_segment}
    csn.Connect to   hostname=${ru_pc_addr}   username=${ru_pc_user}   password=${ru_pc_pw}   alias=ru_pc
    ${output}   csn.execute   command=cat /etc/network/interfaces |grep ${ru_ip_segment}   connection=ru_pc
    ${gw_ip}    should match regexp   ${output}   \\d+.\\d+.\\d+.\\d+
    ${ru_gw_flag}   set variable   ${RU_GW_IP}[${gw_ip}]
    [Return]   ${ru_gw_flag}
    [Teardown]  csn.Disconnect   connection=ru_pc

Collect log for special 6450 case
    [Arguments]  ${dir}
    csn.Connect to   hostname=${cu_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    ${output}   csn.execute   command=ls -l /ffs/run/l1soc  timeout=10   connection=gnb
    ${if_l1soc_exist}   run keyword and return status   should not contain   ${output}   No such file or directory
    run keyword if   ${if_l1soc_exist}   run keywords
    ...   csn.execute   command=cd /tmp;tar -cvf l1soc.tar /ffs/run/l1soc   timeout=30   connection=gnb
    ...   AND   csn.Download File    remote_path=/tmp/l1soc.tar
    ...   local_path=${OUTPUT_DIR}/${dir}/l1soc.tar   connection=gnb
    ...   AND   csn.execute   command=rm -rf /ffs/run/l1soc   timeout=10   connection=gnb
    [Teardown]  csn.Disconnect   connection=gnb

Modify miNrCellAvailability
    [Arguments]   ${value}=5min
    WebEM Login
    ${last_value}   selenium_sbts.Get Parameter Value   dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRPMRNL-1   abbr=miNrCellAvailability
    ...    filter_param=NR Cell Availability
    log to console    miNrCellAvailability is ${last_value}
    run keyword if   '${last_value}'!='5min'   log to console    Modify miNrCellAvailability to 5min
    run keyword if   '${last_value}'!='5min'   selenium_sbts.Set Parameter Value   dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRPMRNL-1
    ...    abbr=miNrCellAvailability   new_value=${value}    filter_param=NR Cell Availability
    run keyword if   '${last_value}'!='5min'   selenium_sbts.Validate Plan
    run keyword if   '${last_value}'!='5min'   selenium_sbts.Activate Plan
    [Teardown]  WebEM Logout

Reset BBMOD When RMOD Raise Fault10
    gnb_handler.login   ip=${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   gnb_type=coam   connection=gnb
    @{return_active_alarm}   gnb_handler.get_active_alarms   connection=gnb   except_alarms=${Ignore_Fault}
    FOR   ${i}   IN   @{return_active_alarm}
        ${alarm_Object}    set variable if    ${i['faultId']} == 10      ${i['alarmObject']}    None
        Continue For Loop If    '${alarm_Object}' == 'None'
        ${RMOD_INDEX}    Set Variable   ${alarm_Object.split('/')[-1]}
        log to console    ${alarm_Object.split('/')[-1]} raise fault10!
        ${status}   ${fid10_bbmod_info}    run keyword and ignore error    Get BBMOD Index Accorrding To RMOD    ${alarm_Object.split('/')[-1]}
    END
    ${fid10_bbmod_info}    Remove Duplicates    ${fid10_bbmod_info}
    log to console    these BBMOD need to reset accorrding to RU fault10: BBMOD-${fid10_bbmod_info}
    run keyword and ignore error    Reset BBMOD Via WebEM     ${fid10_bbmod_info}
    wait until keyword succeeds  15min   30s   Coam Check Site Status
    [Teardown]   gnb_handler.logout   connection=gnb

Get BBMOD Index Accorrding To RMOD
    [Arguments]    ${RMOD_INDEX}
     ${fid10_bbmod_info}   Create List
     FOR   ${Module_Status}   IN   @{cablink_correspondence}
        ${if_contain_rmod}   run keyword and return status   should contain   ${Module_Status['secondEndPointId']}    ${RMOD_INDEX}
        ${firstEndPointId}    set variable    ${Module_Status['firstEndPointId']}
        ${if_contain_bbmod}   run keyword and return status   should contain   ${firstEndPointId}    BBMOD
        run keyword if    ${if_contain_rmod} and ${if_contain_bbmod}    append to list    ${fid10_bbmod_info}    ${firstEndPointId.split('-')}[-1]
        exit for loop if    ${if_contain_rmod} and ${if_contain_bbmod}
     END
     [Return]    ${fid10_bbmod_info}

Reset BBMOD Via WebEM
    [Arguments]    ${fid10_bbmod_info}
    selenium_coam.login    url=${WEBUI_URL}    username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    FOR   ${i}   IN   @{fid10_bbmod_info}
        log to console    start to reset BBMOD-${i}!
        selenium_coam.reset_abil    abil_index=${i}
    END
    [Teardown]    run keyword and ignore error    selenium_coam.logout

Check If Module Raise Critical Alarm
    gnb_handler.login   ip=${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   gnb_type=coam   connection=gnb
    @{return_active_alarm}   gnb_handler.get_active_alarms   connection=gnb   except_alarms=${Ignore_Fault}
    ${SMOD_Critical_Alarm}    set variable    ${False}
    FOR   ${i}   IN   @{return_active_alarm}
        ${i_str}   convert to string   ${i}
        ${If_SMOD}    run keyword and return status   should contain   ${i_str}   SMOD
        Continue For Loop If    '${If_SMOD}' == '${False}'
        ${SMOD_Critical_Alarm}    set variable if    '${i['severity']}' == 'Critical' and ${If_SMOD}     ${True}    ${False}
        run keyword if    ${SMOD_Critical_Alarm}    log to console    SMOD Rsise Critical Alarm!
        exit for loop if    ${SMOD_Critical_Alarm}
    END
    set suite variable    ${SMOD_Critical_Alarm}
    [Teardown]   gnb_handler.logout   connection=gnb

Get Correspondence between BBMOD and RMOD
    [Arguments]    ${ip}=${WEBUI_ADDR}   ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
    gnb_handler.login   ip=${ip}   username=${username}   password=${password}   gnb_type=coam   connection=gnb
    @{cablink_correspondence}   gnb_handler.check_gnb_cablink_status   connection=gnb
    set suite variable    ${cablink_correspondence}
    [Teardown]   run keyword and ignore error  gnb_handler.logout   connection=gnb

Get All Enb IPs
    ${enb_ip_list}    Create List
    ${enb_length}   Get Length   ${ENBs}
    ${enb_length}    Convert To Integer    ${enb_length}
    FOR     ${index}    IN RANGE    ${enb_length}
        continue for loop if   '${ENBs[${index}]['addr']}'=='1.1.1.1'
        append to list    ${enb_ip_list}    ${ENBs[${index}]['addr']}
    END
    ${enb_ip_list}    Remove Duplicates    ${enb_ip_list}
    set suite variable    ${enb_ip_list}

Check if need add 1815 to ignore history alarm list
    @{radio_type_related_to_1815}    create list    AHBCC    AHPE    AHLOA    AHFIB    AHFIG   AHPB
    WebEM Login
    FOR   ${Module_Status}   IN   @{cablink_correspondence}
        ${if_ext}    run keyword and return status    should contain    ${Module_Status['firstEndPointId'].lower()}    ext
        Continue For Loop If    ${if_ext}
        ${radio_protocol_type}   selenium_sbts.Get Parameter Value
        ...    dist_name=MRBTS-${bts_id}/EQM-${EQM_num}/HWTOP-${HWTOP_num}/${Module_Status['name']}
        ...    abbr=radioProtocolType    filter_param=Radio protocol type
        ${if_ecpri}   run keyword and return status   should contain   ${radio_protocol_type.lower()}    ecpri
        Continue For Loop If    ${if_ecpri}
        ${ru_index}    Set Variable    ${Module_Status['secondEndPointId'].split('-')}[-1]
        ${need_radio}   run keyword and return status
        ...    List Should Contain Value    ${radio_type_related_to_1815}    ${rus[${ru_index}-1]['ru_type']}
        Continue For Loop If    '${need_radio}'=='${False}'
        ${rf_share}   selenium_sbts.Get Parameter Value   dist_name=MRBTS-${bts_id}/MNL-${MNL_num}/MNLENT-${MNLENT_num}/FEATCADM-${FEATCADM_num}
        ...    abbr=rfSharingEnabled    filter_param=Rf sharing enabled
        ${if_rf_share}   run keyword and return status    Should Be Equal As Strings    ${rf_share.lower()}    true
        Continue For Loop If    '${if_rf_share}'=='${False}'
        set suite variable    ${ignore_history_fault}    ${ignore_history_fault},1815
        set suite variable    ${ignore_history_fault_for_concurrent}    ${ignore_history_fault_for_concurrent},1815
        set suite variable    ${ignore_history_fault_moran_slave}    ${ignore_history_fault_moran_slave},1815
        Exit For Loop
    END
    [Teardown]  WebEM Logout
