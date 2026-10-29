*** Settings ***
Documentation
...    author: tina.luo
...    contact:tina.luo@nokia-sbell.com
...    squad group: RAN_PZ_HAZ3_SG03
...    feature : CB008158

Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library     taf.hw.rf_attenuator    WITH NAME    att
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/coam_check_status.robot
Library     caculated_lifetime.py
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RF_module_power_reset.robot
#Variables   CB008158_scf_modify.py


*** Variables ***
${scf_file_template_path}    ${commissionings_path}/HGZ/${testline_name}


*** Keywords ***

CB014999 SA case Preparation
    COAM Create log directory
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    COAM Commission with scf file    scf_file_path=${scf_file_template_path}/SCF_${stream}_${carrier_num}CC.xml
    ...    timeout=600s
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
   [Teardown]    COAM Teardown gnb connections


Reset Rmod via admin cli
   [Arguments]    ${ru_index}   ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=GNB_OAM
    ${before_active_fault_list}    Get Alarm Fault Id List   alarm_type=active    connection=${connection}
    ${before_history_fault_list}    Get Alarm Fault Id List   alarm_type=history    connection=${connection}
    # ${ru_index_list}    Get All RU Index    connection=${connection}
    # FOR    ${ru_index}    IN    @{ru_index_list}
    #     log to console    \n***RF Module index ${ru_index} Reset via admin**
    #     ${ru_index}  Convert To Integer    ${ru_index}
    #     coam.reset_unit    dist_name=MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-${ru_index}
    #     ...    force_radio_reset=${True}    timeout=${300}    connection=${connection}
    # END
    log to console    \n***RF Module index ${ru_index} Reset via admin**
    ${ru_index}    Convert To Integer    ${ru_index}
    coam.reset_unit    dist_name=MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-${ru_index}
    ...    force_radio_reset=${True}    timeout=${300}    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM


Get Snapshot and find the needed BBOX5 file
    [Arguments]   ${ru_index}=${1}   ${coverage}=Full    ${snapshot_path}=${TEST_LOG_DIRECTORY}
    ...    ${connection}=GNB_OAM    ${timeout}=600
    log to console    \nGet BBOX5 file On Snapshot
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    ${timestamp}    DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    Run   rm -rf ${snapshot_zip_file_path}
    coam.get_snapshot    target_file_name=${snapshot_zip_file_path}   coverage=${coverage}
    ...    timeout=${timeout}   connection=${connection}
    ${snapshot_unzip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}
    Run   rm -rf ${snapshot_unzip_file_path}
    extract zip file    ${snapshot_zip_file_path}    ${snapshot_unzip_file_path}
    ${output}   OperatingSystem.get file    ${snapshot_unzip_file_path}/snapshot_file_list.txt
    ${pattern}   Set Variable    BTS_part(\\d+).zip:[^:]*BTS\\d+_${serial_number}_RMOD_L_[\\d]+_BBOX5_all
    ${btspart_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${btspart}   Set Variable    ${btspart_list}[0]
    ${btspart}   Catenate    BTS_part${btspart}
    Extract Zip File    ${snapshot_unzip_file_path}/${btspart}.zip
    ...                 ${snapshot_unzip_file_path}/${btspart}
    ${btspart_output} =    Run    command=cd ${snapshot_unzip_file_path}/${btspart};ls
    ${pattern_bbox5}    Set Variable    (BTS\\d+_${serial_number}_RMOD_L_[\\d]+_BBOX5_all).zip
    ${bbox5_list} =    Get Regexp Matches    ${btspart_output}    ${pattern_bbox5}    1
    ${bbox5}    Set Variable    ${bbox5_list}[0]
    Extract Zip File    ${snapshot_unzip_file_path}/${btspart}/${bbox5}.zip
    ...                 ${snapshot_unzip_file_path}/${btspart}/${bbox5}
    set suite variable    ${bbox5_file_path}    ${snapshot_unzip_file_path}/${btspart}/${bbox5}/BBOX5
#    set suite variable    ${bbox5_file_path}    ${snapshot_unzip_file_path}/${btspart}/${bbox5}/BBOX5
    [Return]    ${bbox5_file_path}


Get the rtwp lifetime counter for selected RMOD
    ${rtwp_list}    Create List
    FOR    ${index}    IN RANGE    0   ${carrier_num}
       ${result}    caculate_lifetime_sums    filename=${bbox5_file_path}    antenna_count=${antenna_count}    carrier_type=NR_5G_TDD
       ...   carrier_center_freq=${carrier_center_freq_list}[${index}]   carrier_bandwidth=${carrier_bandwidth_list}[${index}]
       log to console    the result is ${result}
       Append To List   ${rtwp_list}    ${result}
    END
    #set suite variable   ${rtwp_list}
    [return]   ${rtwp_list}
