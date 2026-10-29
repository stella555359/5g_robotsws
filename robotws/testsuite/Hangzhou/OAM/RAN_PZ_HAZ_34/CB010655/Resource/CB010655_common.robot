*** Settings ***
Documentation
...         author: yingying.li
...         contact: yingying.li@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
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


*** Keywords ***
Get BBOX5 file On Snapshot
    [Arguments]   ${ru_index}=${1}   ${coverage}=Full    ${snapshot_path}=${TEST_LOG_DIRECTORY}
    ...    ${connection}=GNB_OAM    ${timeout}=600
    log to console    \nGet BBOX5 file On Snapshot
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    Run   rm -rf ${snapshot_zip_file_path}
    coam.get_snapshot    target_file_name=${snapshot_zip_file_path}   coverage=${coverage}
    ...    timeout=${timeout}   connection=${connection}
    ${snapshot_unzip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}
    Run   rm -rf ${snapshot_unzip_file_path}
    extract zip file    ${snapshot_zip_file_path}    ${snapshot_unzip_file_path}
    ${output}   OperatingSystem.get file    ${snapshot_unzip_file_path}/snapshot_file_list.txt
    ${pattern}   Set Variable    BTS_part(\\d).zip:[^:]*BTS_${serial_number}_RMOD_L_[\\d]+_BBOX5
    ${btspart_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${btspart}   Set Variable    BTS_part${btspart_list}[0]
    Extract Zip File    ${snapshot_unzip_file_path}/${btspart}.zip
    ...                 ${snapshot_unzip_file_path}/${btspart}
    ${btspart_output} =    Run    command=cd ${snapshot_unzip_file_path}/${btspart};ls
    ${pattern_bbox5}    Set Variable    (BTS_${serial_number}_RMOD_L_[\\d]+_BBOX5)_all.zip
    ${bbox5_list} =    Get Regexp Matches    ${btspart_output}    ${pattern_bbox5}    1
    ${bbox5}    Set Variable    ${bbox5_list}[0]
    Run    command=cd ${snapshot_unzip_file_path}/${btspart};unzip ${snapshot_unzip_file_path}/${btspart}/${bbox5}_all.zip
    ${bbox5_info}    Run    command=cat ${snapshot_unzip_file_path}/${btspart}/BBOX5
    set suite variable    ${bbox5_info}
    [Return]    ${bbox5_info}

check temperature enhancement
    ${pattern_temperature}   Set Variable    <([^<]*)170<
    ${temperature_ranges_list}    Get Regexp Matches     ${bbox5_info}    ${pattern_temperature}    1
    ${temperature_list}    Get Regexp Matches     ${temperature_ranges_list}[0]    -40
    Should be true    ${temperature_list}[0]==${-40}
    log to console    \n temperature Ranges:[${temperature_list}[0] - 170]

check Reset Counter
    ${Reset_Counter}    Get Regexp Matches     ${bbox5_info}    Reset Counter:\\s+(\\d+)    1
    ${Reset_Counter_0}    convert to integer    ${Reset_Counter}[0]
    set suite variable    ${Reset_Counter_0}

check Reset Counter after reset
    ${Reset_Counter_after_reset}    Get Regexp Matches     ${bbox5_info}    Reset Counter:\\s+(\\d+)    1
    ${Reset_Counter_after_reset_1}    convert to integer    ${Reset_Counter_after_reset}[0]
    Should be true    ${Reset_Counter_after_reset_1}==${Reset_Counter_0}+1

Clear snapshot on UTE
    csn.connect_to    hostname=${TestPC_addr}    username=${TestPC_username}    password=${TestPC_password}    alias=ute
    Run    command=rm -rf /home/ute/Downloads/*

Suite setup
    CI_interface.Common Case Setup
	Connect to gnb coam via ssl    connection=default
	robot_common_operations.Common Suite Setup

Suite teardown
	COAM Teardown gnb connections    connection=default
	robot_common_operations.Common Suite Teardown
