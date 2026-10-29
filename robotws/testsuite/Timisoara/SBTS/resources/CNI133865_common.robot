*** Settings ***
Documentation     author: ruiyu.han
...               contact: ruiyu,han@nokia-sbell.com
...               squad group: SG_07
...               feature : CB012144

Library     BuiltIn
Library     String
Library     Process
Library     DateTime
Library     XML    True
#Library     Collections
#Library     OperatingSystem
Library     taf.transport.ssh   WITH NAME   csn
Library     taf.analyzer.pcap   WITH NAME   wireshark
Library     taf.selenium.sbts   WITH NAME   selenium_sbts
Library     taf.ul.oam_kpi_calculations   WITH NAME   oam_kpi
Library     taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Library     taf.collectors.btslog   WITH NAME   btslog
Library     taf.collectors.core   WITH NAME   core
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    CB012144_common.robot
Resource    oam_common.robot



Library           OperatingSystem
Library           Collections
#Library           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001681_794/libraries/snapshot_files.py
Library           snapshot_files.py
#Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
#Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
Resource          siso_common.robot
#Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/oam_common.robot
#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
#Variables         testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
#Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
#Library           SSHLibrary
#Library           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/btslog_handle.py
#Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB012144/Resource/CB012144_common.robot



*** Keywords ***
Case Setup for CNI133865
    [Arguments]
    robot_common_operations.Common Case Setup
##    Run Keyword And Ignore Error   Update Rad for BTSSyslog in AaShell via SSHLibrary
    Run Keyword And Ignore Error   Start Syslog Collection
##    COAM Login
##    CI_interface.Common Suite Setup
##    COAM Reset Site
##    Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
    BTS Site reset
    Log to console    inport current SCF file
    ${BTS Files path}    coam.Get Current SCF File
    ...    ${BTS Files}  SCF.xml  timeout=120   export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues
    set test variable  ${BTS Files path}
#    Log to console    inported current SCF file
#    Log to console    BTS file= ${BTS Files}
#    Log to console    BTS Files path este ${BTS Files path}
#    COAM Backup Full SCF    file_name=siso_scf.xml
    ${smod_name_postion}    Get SMOD Position Dic    full_scf_path=${BTS Files path}

    ${bbmod_name_postion}    Get BBMOD Position Dic    full_scf_path=${BTS Files path}
    ${rmod_name_dic}        Get RMOD SerialNumber List    full_scf_path=${BTS Files path}
    ${rmod_cell_mapping}    ${cell_num}    UUF Get RMOD SN Cell Mapping From Full SCF    source=${BTS Files path}
    ${rmod_serial_mapping}    UUF Get RMOD SerialNumber Mapping    source=${BTS Files path}
    ${bbmod_mapping}     Siso Common Get BBMOD Mapping RMOD    source=${BTS Files path}
    ${bbmod_cell_mapping}    Siso Common Get BBMOD Mapping Cell     source=${BTS Files path}
    ${bbmods_info}     Get BBMODs info
    ${SCF_xml}    set variable    ${BTS Files path}
    Set Suite Variable    ${SCF_xml}
    set test variable     ${bbmod_mapping}
    set test variable     ${bbmods_info}
    set test variable     ${bbmod_cell_mapping}
    set suite variable    ${rmod_cell_mapping}
    set suite variable    ${rmod_serial_mapping}
    Set Suite Variable    ${smod_name_postion}
    Set Suite Variable    ${bbmod_name_postion}
    Set Suite Variable    ${rmod_name_dic}


     ${rmod_cell_mapping}    ${cell_num}    UUF Get RMOD SN Cell Mapping From Full SCF    source=${BTS Files path}
     ${rmod_serial_mapping}    UUF Get RMOD SerialNumber Mapping    source=${BTS Files path}
     set test variable     ${rmod_cell_mapping}
     set test variable     ${rmod_serial_mapping}
#     ${rus}   Set Variable   ${tl.gnbs[0].dus[0].rus}
#     ${ru_count}   Get Length   ${rus}
#     set test variable     ${rus}
     ${ru_count}   Get Length   ${rmod_serial_mapping}
     Log to console    ru count este ${ru_count}
     set test variable     ${ru_count}


#    ${actRuResetResiliency}    COAM Get Parameter Value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
#    ...   parameter=actRuResetResiliency
    set test variable    ${actRuResetResiliency}    'true'
    run keyword if   ${actRuResetResiliency}=='true'    COAM Change actRuResetResiliency Value    value=false
    run keyword if   ${actRuResetResiliency}=='true'    wait until keyword succeeds   15m   1m   COAM Check All Cells Onair


Case Teardown for CNI133865
    Check Extra Reset From Blackbox
    run keyword and ignore error    COAM Login
    Run Keyword If   ${KEYWORD STATUS.count('PASS')}<=0    Catch Snapshot COAM
    ${actRuResetResiliency}    COAM Get Parameter Value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...   parameter=actRuResetResiliency
    run keyword if   '${actRuResetResiliency}'=='false'    COAM Change actRuResetResiliency Value    value=true
    run keyword if   '${actRuResetResiliency}'=='false'    wait until keyword succeeds   15m   1m   COAM Check All Cells Onair
    Run Keyword And Ignore Error   Stop and Save Syslog Collection
    Run Keyword And Ignore Error   CI_interface.Common Case Teardown
    Run Keyword And Ignore Error   COAM Logout


COAM Change actRuResetResiliency Value
    [Arguments]    ${value}
    ${dict_param}    Create Dictionary    value=${value}    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actRuResetResiliency
    ${list_param}    Create List    ${dict_param}
    ${param_dic_to_change}    Create Dictionary    update=${list_param}
    COAM Commission Prameters Operation    param_dic_to_change=${param_dic_to_change}


Verify Snapshot has pm logs
    [Arguments]    ${path}    ${rmod_name_dic}
    run   rm -rf ${OUTPUT_DIR}/snapshot
    ${command_unzip}    Set Variable    unzip ${path} -d ${OUTPUT_DIR}/snapshot
    run   ${command_unzip}
    ${FILE_STRUCT}    wait until keyword succeeds    5min   30s
    ...   snapshot_files.get_snapshot_file_orgnization    file_folder=${OUTPUT_DIR}/snapshot
    ${strs}    Convert To String    ${FILE_STRUCT}
    ${GLOBAL_BTS_ID}    evaluate    ${MRBTS_ID}
    FOR    ${rmod}    IN    @{rmod_name_dic}
        Continue For Loop If    '${rmod_name_dic['${rmod}']}' != 'AEHC'
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm1\\S+_node0.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm1\\S+_node1.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm1\\S+_node2.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm1\\S+_node3.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm1\\S+_node4.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm1\\S+_node5.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm1\\S+_node6.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm1\\S+_node7.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm1\\S+_node8.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm1\\S+_node9.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm2\\S+_node0.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm2\\S+_node1.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm2\\S+_node2.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm2\\S+_node3.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm2\\S+_node4.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm2\\S+_node5.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm2\\S+_node6.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm2\\S+_node7.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm2\\S+_node8.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm2\\S+_node9.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm3\\S+_node0.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm3\\S+_node1.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm3\\S+_node9.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm4\\S+_node0.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm4\\S+_node1.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm4\\S+_node9.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm5\\S+_node0.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm5\\S+_node1.
        Should Match Regexp       ${strs}    BTS${GLOBAL_BTS_ID}_${rmod}_RMOD_L_\\S*_pm5\\S+_node9.
    END


AEHC Get Radio Startup Time by btslog
    [Arguments]    ${start_str}
    ${btslog_path}     RUN    cd /tmp/btslog2;ls
    ${start_time}    get_specific_str_timestamp
    ...   file_input=/tmp/btslog2/${btslog_path}   filter_str=${start_str}
    ${stop_time}    get_specific_str_timestamp
    ...   file_input=/tmp/btslog2/${btslog_path}   filter_str=onModuleReadyInd: Radio Module detected
    run keyword if   len(${start_time}) < len(${stop_time})    _extend_list    ${start_time}    ${stop_time}
    ...   ELSE    set variable    ${start_time}
    ${time_dict_single}   Create Dictionary
    FOR   ${index}   IN RANGE   len(${stop_time})
         ${startup_time}    calc_time_interval
         ...   time_stamp1=${start_time[${index}]}    time_stamp2=${stop_time[${index}]}
         Set To Dictionary   ${time_dict_single}   ru_${index}   ${startup_time}
    END
    [Return]      ${time_dict_single}


All RUs Reset and check downtime
     [Arguments]    ${keycheck}=${False}
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
    ${downtime_list}    create list
    FOR     ${RU}     IN     @{rmod_serial_mapping}
        Continue For Loop If    '${rmod_name_dic['${RU}']}' != 'AEHC'
        ${start_time}    DateTime.Get Current Date   result_format=epoch
        run keyword and ignore error    COAM Reset RMOD    dist_name=${rmod_serial_mapping['${RU}']['configDN']}    timeout=${20}
        Wait Until Keyword Succeeds   5m   10s   RU and corresponding Cell Status should Disabled   sn_value=${RU}
#        Check Other RU and Cell Status except one    dist_name=${rmod_serial_mapping['${RU}']['configDN']}
        run keyword if  ${rulog_exist}
        ...   run keyword and ignore error    run keywords
        ...   Wait Until Keyword Succeeds    5m    1m   Validate RU IP Reachability from Control PC by SN
        ...   ru_sn=${RU}  exp_status=${False}
        ...   AND   wait until keyword succeeds    5m    1m   Enable Single LMI RU at ControlPC by SN    ru_sn=${RU}
        Wait Until Keyword Succeeds   15m   5s
        ...   Power Check RU Status COAM   rmod_configDN=${rmod_serial_mapping['${RU}']['configDN']}
        ${stop_time}    DateTime.Get Current Date   result_format=epoch
        ${downtime}    evaluate    ${stop_time}-${start_time}
        Append to list    ${downtime_list}    ${downtime}
#        Check Other RU and Cell Status except one    dist_name=${rmod_serial_mapping['${RU}']['configDN']}
     END
     ${ave_downtime}    Evaluate    sum(${downtime_list})/len(${downtime_list})
     should be true    ${ave_downtime} < 340
     Wait Until Keyword Succeeds    20m    1m   COAM Check all cells should be onair
     [Teardown]     Siso Common Each Time Teardown     keycheck=${keycheck}

AEHC Single time Site Reset
     Start Syslog Collection
     ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
     Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
     Set Test Variable   ${CASE_PROCESS_START}
     COAM Reset Site
     run keyword if  ${rulog_exist}
     ...   run keyword and ignore error   wait until keyword succeeds    15min    1min   Enable LMI RU at ControlPC
     Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
     [Teardown]     Siso Common Each Time Teardown
