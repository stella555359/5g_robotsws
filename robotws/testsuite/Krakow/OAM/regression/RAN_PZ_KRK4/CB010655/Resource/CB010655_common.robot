*** Settings ***
Documentation
...         author: yingying.li
...         contact: yingying.li@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         BBOX5 test

Library     Collections
Library     ArchiveLibrary
Library     SeleniumLibrary
Library     String
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

*** Variables ***
${GNB_SSH_ADDR}          ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${GNB_SSH_USERNAME}      ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${GNB_SSH_PASSWORD}      ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${GNB_HTTP_ADDR}         ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${GNB_HTTP_USERNAME}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
${GNB_HTTP_PASSWORD}     ${tl.gnbs[0].cu.oam_http_connection_details.password}

*** Keywords ***
Get BBOX5 file On Snapshot
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
    ${pattern}   Set Variable    BTS_part(\\d).zip:[^:]*BTS\\d+_${serial_number}_RMOD_L_[\\d]+_BBOX5_all
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
    ${bbox5_info}    Run    command=cat ${snapshot_unzip_file_path}/${btspart}/${bbox5}/BBOX5
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

Connect to gNB cOAM via SSL
    [Arguments]  ${connection}=GNB_OAM    ${bts_host}=${GNB_HTTP_ADDR}    ${username}=${GNB_HTTP_USERNAME}
    ...    ${password}=${GNB_HTTP_PASSWORD}    ${admin_api_log_dir}=${TEST_LOG_DIRECTORY}
    coam.connect_to    bts_host=${bts_host}
    ...                     bts_port=${443}
    ...                     username=${username}
    ...                     password=${password}
    ...                     name=${connection}
    ...                     admin_api_log_dir=${admin_api_log_dir}
    ...                     release=SBTS00

COAM get ru detial info by ru index
    [Documentation]  Author: Ding Binmei
    ...              Description: Get RU detail info by ru index
    ...              ${ru_index} Should be start from 1, should match the value with RMOD-*
    [Arguments]    ${ru_index}=1    ${connection}=GNB_OAM
    ${ru_index}    Convert to string    ${ru_index}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    Should be true    ${count_RUs}>=1    msg=No RU found
    &{dict_RUs_detail_info}   Create dictionary
    FOR    ${RU}    IN    @{list_RUs}
        ${status}    Run Keyword And Return Status    Should Contain   '${RU}'   RMOD-${ru_index}
        Run keyword if   '${status}'=='True'    Set to dictionary    ${dict_RUs_detail_info}    ${ru_index}    ${RU}
    END
    [Return]  ${dict_RUs_detail_info['${ru_index}']}

COAM Reset Site
    Reset gNB

Create cOAM session with alias
    [Arguments]  ${port}=3600  ${alias}=default
    [Documentation]  Connect to Node B.
    ...  port:  BTS gNB port ID. default 3600
    ...  alias:  AdminConnection object or if used, string name alias
    comment  Release cOAM session before creation to avoid multiple session open
    run keyword and ignore error  coam.teardown  connection=default
    coam.Connect to  bts_host=${GNB_SSH_ADDR}  bts_port=${port}  name=${alias}
