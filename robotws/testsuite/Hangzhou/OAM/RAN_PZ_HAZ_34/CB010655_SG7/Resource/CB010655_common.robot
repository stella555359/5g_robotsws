*** Settings ***
Documentation
...         author: fred.li
...         contact: fred.li@nokia-sbell.com
...         squad group: RAN_PZ_HAZ_4_SG07
...         BBOX5 test

Library     SeleniumLibrary
Library     OperatingSystem
Library     DateTime
Library     XML  use_lxml=True
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.config.scf        WITH NAME    scf
Library     taf.selenium.sbts  WITH NAME   selenium_coam
Library     taf.collectors.btslog  WITH NAME   btslog
Library     taf.collectors.core   WITH NAME   core
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot


*** Keywords ***
Check BBOX5 file On Snapshot
    [Arguments]   ${ru_index}=${1}   ${coverage}=Full    ${snapshot_path}=${TEST_LOG_DIRECTORY}
    ...    ${connection}=GNB_OAM    ${timeout}=600
    log to console    \nGet BBOX5 file On Snapshot
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
#    Run   rm -rf ${snapshot_zip_file_path}
    coam.get_snapshot    target_file_name=${snapshot_zip_file_path}   coverage=${coverage}
    ...    timeout=${timeout}   connection=${connection}
    ${snapshot_unzip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}
    Run   rm -rf ${snapshot_unzip_file_path}
    extract zip file    ${snapshot_zip_file_path}    ${snapshot_unzip_file_path}
    ${output}   OperatingSystem.get file    ${snapshot_unzip_file_path}/snapshot_file_list.txt
    ${pattern}   Set Variable    BTS_part(\\d).zip:[^:]*BTS\\d*_${serial_number}_RMOD_L_[\\d]+_BBOX5_all
    ${btspart_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${btspart}   Set Variable    BTS_part${btspart_list}[0]
    Extract Zip File    ${snapshot_unzip_file_path}/${btspart}.zip
    ...                 ${snapshot_unzip_file_path}/${btspart}
    ${btspart_output} =    Run    command=cd ${snapshot_unzip_file_path}/${btspart};ls
    ${pattern_bbox5}    Set Variable    (BTS\\d*_${serial_number}_RMOD_L_[\\d]+_BBOX5_all).zip
    ${bbox5_list} =    Get Regexp Matches    ${btspart_output}    ${pattern_bbox5}    1
    ${bbox5}    Set Variable    ${bbox5_list}[0]
    Extract Zip File    ${snapshot_unzip_file_path}/${btspart}/${bbox5}.zip
    ...                 ${snapshot_unzip_file_path}/${btspart}/${bbox5}
    ${bbox5_info}    Run    command=cat ${snapshot_unzip_file_path}/${btspart}/${bbox5}/BBOX5
    set suite variable    ${bbox5_info}
    [Return]    ${bbox5_info}

Verify temperature enhancement
    ${pattern_temperature}   Set Variable    <([^<]*)170<
    ${temperature_ranges_list}    Get Regexp Matches     ${bbox5_info}    ${pattern_temperature}    1
    ${temperature_list}    Get Regexp Matches     ${temperature_ranges_list}[0]    -40
    Should be true    ${temperature_list}[0]==${-40}
    log to console    \n temperature Ranges:[${temperature_list}[0] - 170]

Verify Reset Counter
    ${Reset_Counter}    Get Regexp Matches     ${bbox5_info}    Reset Counter:\\s+(\\d+)    1
    ${Reset_Counter_0}    convert to integer    ${Reset_Counter}[0]
    set suite variable    ${Reset_Counter_0}

Verify Reset Counter after reset
    ${Reset_Counter_after_reset}    Get Regexp Matches     ${bbox5_info}    Reset Counter:\\s+(\\d+)    1
    ${Reset_Counter_after_reset_1}    convert to integer    ${Reset_Counter_after_reset}[0]
    Should be true    ${Reset_Counter_after_reset_1}==${Reset_Counter_0}+1

Verify Periodical trigger occur times
    ${Periodical_Counter}    Get Regexp Matches     ${bbox5_info}    Periodical trigger occur times:\\s+(\\d+)    1
    ${Periodical_Counter_0}    convert to integer    ${Periodical_Counter}[0]
    set suite variable    ${Periodical_Counter_0}

Verify Periodical trigger occur times after Modify
    ${Periodical_Counter_after_reset}    Get Regexp Matches     ${bbox5_info}    Periodical trigger occur times:\\s+(\\d+)    1
    ${Periodical_Counter_after_reset_1}    convert to integer    ${Periodical_Counter_after_reset}[0]
    Should be true    ${Periodical_Counter_after_reset_1}>${Periodical_Counter_0}


Clear snapshot on VM
    csn.connect_to    hostname=${TestPC_addr}    username=${TestPC_username}    password=${TestPC_password}    alias=ute
    Run    command=rm -rf /home/ute/Downloads/*

#Perform RU Power Off
#    [Arguments]    ${ru_index}=${1}    ${gnb_index}=${0}    ${du_index}=${0}
#    ...    ${model}=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.pdu.__class__.__name__}
#    ${ru_index}    Convert to integer    ${ru_index}
#    ${ru_pdu_ip}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.pdu.addr}
#    ${ru_pdu_port}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.port_no}
#    pdu.setup_pdu    model=${model}   host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}
#    pdu.power_off    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}
#
#Perform RU Power On
#    [Arguments]    ${ru_index}=${1}    ${gnb_index}=${0}    ${du_index}=${0}
#    ...    ${model}=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.pdu.__class__.__name__}
#    ${ru_index}    Convert to integer    ${ru_index}
#    ${ru_pdu_ip}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.pdu.addr}
#    ${ru_pdu_port}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.port_no}
#    pdu.setup_pdu    model=${model}    host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}
#    pdu.power_on    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}

Modify timeBetweenSaveOnNVM and Activate
    [Arguments]    ${init_value}=${300}    ${target_value}=${86400}    ${connection}=GNB_OAM
    Modify timeBetweenSaveOnNVM Value In BBOX File    init_value=${init_value}    target_value=${target_value}    connection=${connection}
    COAM Reset Site    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min   1min    COAM Check all cells should be onair    connection=GNB_OAM

Suite setup
	robot_common_operations.Common Suite Setup
	AlarmWatchdog.add_allow_alarms    fault_id=8000
	Connect to gnb coam via ssl    connection=GNB_OAM

Suite setup for UTE
    log to console  \n***CI_interface.Common Suite Setup for COAM on UTE***
    CI_interface.Common Suite Setup
	robot_common_operations.Common Suite Setup
	AlarmWatchdog.add_allow_alarms    fault_id=8000
	Connect to gnb coam via ssl    connection=GNB_OAM

Suite teardown
	Run Keyword And Ignore Error   COAM Teardown gnb connections    connection=GNB_OAM
	robot_common_operations.Common Suite Teardown

CB010655 Case Teardown
#    Clear snapshot on VM
    robot_common_operations.Common Case Teardown
    Modify timeBetweenSaveOnNVM and Activate    init_value=300    target_value=86400    connection=GNB_OAM
    CI_interface.Common Case Teardown
