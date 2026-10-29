*** Settings ***
Documentation     author: jianwu
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: jianwu.qian@nokia-sbell.com

Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    csns
Library    taf.config.scf        WITH NAME    scf
Library    taf.pdu       WITH NAME    pdu
Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     ./Regex_1358.py

Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Variables    ./5GC001358_variables.py

*** Variables ***
${UE_type}    ${tl.ues[-1].capabilities[-1]}
${gNb_CuType}    NSA
${gnb_path}    /tmp/
${scf_path}    ${commissionings_path}/HGZ/${testline_name}
${btslog_save_path}    /home/ute/dir/
${swconfig_save_path}    /home/ute/dir/
${scf_name_original}    5GC001358.xml
${8_antenna_scf_name}    SCF_8T8R_SBTS00.xml
${4_antenna_scf_name}    SCF_4T4R_SBTS00.xml
${2cells_scf_name}    2cells_scf.xml
${vmute_addr}    ${tl.test_pc.default_ssh_connection_details.addr}
${vmute_user}    ${tl.test_pc.default_ssh_connection_details.username}
${vmute_pwd}    ${tl.test_pc.default_ssh_connection_details.password}
${TS_CASE_LOG_PATH}     /home/ute/dir/
${SAVE LOG DIRECTORY}    /home/ute/dir/
${8T8R_scf_name}      SCF_8T8R_SBTS00.xml
${att_ipaddr}               ${tl.attenuator.ip_addr}
${att_port_number}         ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_0}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_1}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_2}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_3}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${att_port_4}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[4].port_no}
${att_port_5}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[5].port_no}
${att_port_6}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[6].port_no}
${att_port_7}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[7].port_no}
${att_port_8}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[8].port_no}
${att_port_9}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[9].port_no}
${att_port_10}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[10].port_no}
${att_port_11}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[11].port_no}
${att_api_port}             ${tl.attenuator.port}
${vendor}                   HBTE
${HBTE_max_value}           ${127}    ##no signal
${PACKAGE_FTP_URL}    http://files.ute.nsn-rdnet.net/builds/enb/base/
${tmp_file}      /home/ute/tcpdump_L2L1_bip_filtering_off.pcap
${FILTER_For_2538}                dldata_ssblocksendreq||dldata_pdschsendreq||dldata_csirssendreq
@{COLUMN_NAME}                   DlData_PdschSendReq.PdschSendReq.sfn    DlData_PdschSendReq.PdschSendReq.slot
...                              DlData_PdschSendReq.grants_item_0.numOfPrb
...                              DlData_SsBlockSendReq.SsBlockSendReq.sfn    DlData_SsBlockSendReq.SsBlockSendReq.slot
...                              DlData_CsiRsSendReq.CsiRsSendReq.sfn    DlData_CsiRsSendReq.CsiRsSendReq.slot
${CHECK_PDSCH_IN_SSB_REGEXP}     SEPARATOR=    DlData_SsBlockSendReq.*?(?P<sfn>0x\\w+).*?(?P<slot>0x\\w+)\\".*?
...                              \\n(?:.*?DlData_PdschSendReq.*?(?P=sfn).*?(?P=slot).*?\\n){1}
${CHECK_PDSCH_IN_TRS_REGEXP}     SEPARATOR=    DlData_CsiRsSendReq.*?(?P<sfn>0x\\w+).*?(?P<slot>0x\\w+)\\".*?
...                              \\n(?:.*?DlData_PdschSendReq.*?(?P=sfn).*?(?P=slot).*?\\n){1}
${WEBUI_ADDR}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WebUI_User}        Nemuadmin
${WebUI_Password}    nemuuser
${arti_hz_sbts}=    https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/
${SCF_with_5793_CPRI}    SCF_SBTS00_5793_CPRI.xml
${SCF_with_5793_eCPRI}    SCF_SBTS00_5793_eCPRI.xml
${SCF_with_5793_CPRI_22R2}    SCF_SBTS22R2_5793_CPRI.xml
${SCF_with_5793_CPRI_22R3}    SCF_SBTS22R3_5793_CPRI.xml
${asik_addr}                ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${gnb_pdu_ip}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${gnb_pdu_port}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

&{fault_61524}    faultId=${61524}    source=SMOD_R-1    #faultId:SSH_ENABLED  source:RU1
&{fault_61652}    faultId=${61652}    source=SMOD_R-1    #faultId:R&D_SERVICE_PORT_ENABLED  source:RU1
&{fault_61649}    faultId=${61649}    source=SMOD_R-1    #LMP access via port 443
&{fault_4654}    faultId=${4654}    source=SMOD_R-1    #faultId:Ethernet port security is disabled
&{fault_4592}    faultId=${4592}    source=SMOD_R-1    #faultId:Bts Reset Cause
&{fault_4655}    faultId=${4655}    #faultId:Increased BER detected on the optical connector
&{fault_4681}    faultId=${4681}    #Sanity Check Error
@{ALLOWED_FAULT_LIST}    &{fault_61524}    &{fault_61652}    &{fault_61649}    &{fault_4655}    &{fault_4654}    &{fault_4592}
...    &{fault_4681}
${model}    PA-16-16-6-127-0.5-B-S
*** Keywords ***
Common Suite Setup for 1358
    [Arguments]    ${timeout}=1min
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    wait until keyword succeeds    ${timeout}    2sec    Connect to gnb coam via ssl
    ${sw_version} =     coam.get_sw_version    connection=GNB_OAM
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    ${sw_version}    replace string    ${sw_version}    SBTS22R4    SBTS00
    Set Suite Variable    ${sw_version}
    Create directory    ${SUITE_LOG_PATH}

Common Suite Teardown for 1358
    Connect to gnb coam via ssl
    COAM Teardown gnb connections

Coam Suite Setup
    log to console    \n***Coam Suite Setup***
	CI_interface.Common Suite Setup
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path
    set suite variable      ${Golden_SCF_Path}
    ${gNb_CuType}   Get gNB CU type
    set suite variable      ${gNb_CuType}
    Generate suite log path
    set suite variable      ${SUITE_LOG_PATH}
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable    ${mrbtsID}
    set suite variable    ${nrbtsID}
    set suite variable    ${backup_scf_path}    ${scf_path}
    ${radio_protocol_temp}    get_radio_protocal_via_admin
    run keyword if
    ...    '${radio_protocol_temp}'=='CPRI'    Active related branch CPRI SCF and wait onair
    #${5793_scf_dir_path}     String.Replace String     ${Golden_SCF_Path}    SCF_SBTS00.xml    5GC001358_5793
    #run keyword if    '${radio_protocol_temp}'=='CPRI'    Commissioning SCF And Check On Air
    #...    scf_path=${5793_scf_dir_path}/${SCF_with_5793_CPRI}    ELSE    Commissioning SCF And Check On Air
    #...    scf_path=${5793_scf_dir_path}/${SCF_with_5793_eCPRI}
    ${stream}    get stream from version    ${Active_SW_version}
    run keyword if    '${stream}'=='SBTS22R3'    Set Current Pkg
    run keyword and ignore error    coam.teardown    connection=GNB_OAM

Coam Suite Teardown
    log to console    \n***Coam Suite Teardown***
    Connect to gnb coam via ssl
	Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    #Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}
    #...    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
	COAM Teardown gnb connections
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True
    Run Keyword And Ignore Error    selenium_coam.close_browser
    Selenium Logout And Close Browser
    #Run Keyword And Ignore Error    delete Downloaded    ${SUITE_LOG_PATH}/${current_pkg}
    Run Keyword And Ignore Error    delete Downloaded    ${current_pkg}
    #Run Process    rm -rf    ${SUITE_LOG_PATH}

Coam Test Setup
    log to console    \n***Coam Test Setup***
    log to console    Active_SW_version:${Active_SW_version}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}

Coam Test Teardown
    log to console    \n***Coam Test Teardown***
    Connect to gnb coam via ssl
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    should be true    ${cell_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT_LIST}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_HISTORY_FAULT}
    #${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    #run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}
    #run keyword if test failed     Collect Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}
    Run Keyword And Ignore Error    delete Downloaded    ${SUITE_LOG_PATH}/${current_pkg}

teardown
    log to console    case teardown stage
    #power_ue.UE Detach    ue_index=${0}    ue_type=askey

Adapt SCF Name By Release
    wait until keyword succeeds    60s    2s    Connect to gnb coam via ssl
    ${sw_version} =     coam.get_sw_version    connection=GNB_OAM
    Set Suite Variable    ${sw_version}
    ${stream}    get stream from version    ${SW_version}
    Set Suite Variable    ${stream}
    ${8T8R_scf_name}    Run keyword if   '${stream}'=='SBTS23R1'     set variable   SCF_8T8R_SBTS00_23R1.xml
    ...   ELSE IF    '${stream}'=='SBTS23R2'     set variable   SCF_8T8R_SBTS00_23R2.xml
    ...   ELSE IF    '${stream}'=='SBTS23R3'     set variable   SCF_8T8R_SBTS00_23R3.xml
    ...   ELSE IF    '${stream}'=='SBTS23R4'     set variable   SCF_8T8R_SBTS00_23R4.xml
    ...   ELSE        set variable   SCF_8T8R_SBTS00.xml
    ${2cells_scf_name}    Run keyword if   '${stream}'=='SBTS23R1'     set variable   2cells_scf_23R1.xml
    ...   ELSE IF    '${stream}'=='SBTS23R2'     set variable   2cells_scf_23R2.xml
    ...   ELSE IF    '${stream}'=='SBTS23R3'     set variable   2cells_scf_23R3.xml
    ...   ELSE        set variable   2cells_scf.xml
    Set Suite Variable    ${2cells_scf_name}
    Set Suite Variable    ${8T8R_scf_name}
    [Teardown]    coam.teardown    connection=GNB_OAM


Set Current Pkg
    ${current_pkg}    Download trunk SW    SW=${Active_SW_version}
    set suite variable    ${current_pkg}

Scf commition and parameter modify
    [Arguments]    ${target_scf}    ${is_scf_modify}=${False}    ${parameters_to_update_via_webui}=${None}
    log to console    Scf commition and parameter modify
    Scf commition and wair for on-air    scf_name=${target_scf}
    run keyword if    '${is_scf_modify}' == '${True}'    Scf para modify
    ...    parameters_to_update_via_webui=${parameters_to_update_via_webui}
    ...    ELSE    log to console    SCF no need to update

Change Parameter online
    [Documentation]
    ...  gets parameter value and changes it
    [Arguments]    ${dist_name}    ${parameter}    ${operation}    ${value}    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning       ${dist_name}
    ...                                           ${parameter}
    ...                                           ${operation}
    ...                                           ${value}
    ...                                           skip_parameter_relation_errors=${True}
    ...                                           should_activate=${True}
    ...                                           connection=${connection}

UE attach and check tp
    [Arguments]    ${tp_direction}=both    ${dl_tp}=100M    ${ul_tp}=100M
    ...    ${exp_dl_tp}=100    ${exp_ul_tp}=100    ${check_times}=30s
    log to console    UE attach and check tp
    UE prepare and attach
    UE start traffic   tp_direction=${tp_direction}   ul_tp=${ul_tp}    dl_tp=${dl_tp}
    Run keyword and continue on failure    UE check throughput by syslog    tp_direction=${tp_direction}
    ...   exp_ul_tp=${exp_ul_tp}    exp_dl_tp=${exp_dl_tp}    check_times=${check_times}
    power_ue.Stop traffic    direction=${tp_direction}    ue_index=${0}    ue_type=${UE_TYPE}
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

UE prepare and attach
    log to console    UE prepare and attach
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False

UE start traffic
    [Arguments]    ${tp_direction}=both    ${ul_tp}=100M    ${dl_tp}=100M
    log to console    UE start traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${dl_tp}   duration=1200    ue_type=${ue_type}    buffer_size=1400B
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${ul_tp}    duration=1200    ue_type=${ue_type}    iperf_type=via_command

UE check throughput by syslog
    [Arguments]    ${tp_direction}=both    ${exp_ul_tp}=100    ${exp_dl_tp}=100    ${check_times}=60s
    log to console    UE check throughput by syslog
    AAsys log captrue    stop_aasys_flag=${False}
    sleep    ${check_times}
    ${all_tp}    Get ul and dl peak and ave throughput and return result    aasys_start_flag=${False}
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...      should be true    ${all_tp[1]}>${exp_dl_tp}
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...     should be true    ${all_tp[4]}>${exp_ul_tp}
    Set Suite Variable    ${all_tp}

Get ul and dl peak and ave throughput and return result
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}
    ...    du_index=${du_index}
    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log for TRUNK
    ...    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb
    ...    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb
    ...    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}
    ...    ${ul_average_tp}    ${ul_minimum_tp}

Scf commition and wair for on-air
    [Arguments]    ${scf_name}    ${is_pdl_checking_needed}=${True}
    log to console    Scf commition and wair for on-air
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_name}    is_pdl_checking_needed=${is_pdl_checking_needed}    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master

Perform bts reboot and wait for on air
    log to console    Perform bts reboot and wait for on air
    Perform BTS Site Reset    download_dir=${CURDIR}
    sleep    60s
    Wait Until Keyword Succeeds    20min    20s    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
    [Teardown]    coam.teardown    connection=GNB_OAM

Get antenna number
    log to console    get antenna number
    Connect to gnb coam via ssl
    ${bts_info}   coam.get_bts_info   connection=GNB_OAM   timeout=10
    ${antenna_list}   Run Keyword If   ${bts_info.has_key('requestMessage')}
    ...   Set Variable   ${bts_info['requestMessage']['radioModules']['rmod'][0]['antenaUsageInfo']}
    ...   ELSE   Set Variable   ${bts_info['radioModules']['rmod'][0]['antenaUsageInfo']}
    ${antenna_numbers}    get length    ${antenna_list}
    Log To Console    current env antenna number is ${antenna_numbers}
    set suite variable    ${antenna_numbers}
    [Return]    ${antenna_numbers}

SiSo SOAP RP1 verification
    [Arguments]  ${ru_index}=1  ${ru_type}=${ru_type_init}
    log to console  \n*** Verify SOAP RP1 ***
    Enable capture soap msg flag on RU    ru_alias=RU_${ru_index}
    sleep  20s
    Connect to gnb coam via ssl
	ssh.force_reconnect    connection=RU_${ru_index}
    ${soap_log_path}    Download soap msg from RU    ru_alias=RU_${ru_index}    log_path=${TS_CASE_LOG_PATH}
    &{soap_info}    Get Detail Info From SOAP Message    Soap_log_path=${soap_log_path}
    ${ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}
    ${ru_target_build}    COAM get expected ru sw version from target BD file    ru_resource_build_key=LTX_${ru_type}_E1
    Should Be Equal As Strings    ${soap_info['productCode']}    ${ru_info['productCode']}
    Should Be Equal As Strings    ${soap_info['serialNum']}    ${ru_info['serialNumber']}
    Should Be Equal As Strings    ${soap_info['moduleType']}    RRH
    Should Be Equal As Strings    ${soap_info['interfaceType']}    eCPRI
    Should Be Equal As Strings    ${soap_info['bldName']}    ${ru_target_build}
    Should Contain    ${soap_info['bldVersion']}    ${ru_target_build}

Get Detail Info From SOAP Message
    [Documentation]    Author: Xu Huamin.1
    ...                Return Dict, Key are productCode,serialNum,moduleType,interfaceType,bldName,bldVersion
    [Arguments]    ${Soap_log_path}
    ${soap_log}    Run    cat "${Soap_log_path}"
    ${soap_log}    Replace String    ${soap_log}    <vendor>Nokia\n</vendor>    <vendor>Nokia</vendor>
    @{msg_list}    Split To Lines    ${soap_log}
    ${productCode}    set variable
    FOR     ${msg}    IN    @{msg_list}
        Continue For Loop If    '${msg}' == ''
        ${msg}    Replace String Using Regexp    ${msg}    <timestamp(.*)Z/>    ${EMPTY}
        ${flag}    Run Keyword And Return Status    xml.parse xml    ${msg}
        ${xml}    Run keyword If    '${flag}'=='False'    Continue For Loop
                    ...     ELSE    xml.parse xml    ${msg}
        ${msg_type}    Get Soap Msg type    ${xml}
        Continue For Loop If    '${msg_type}' == 'UNKNOW'
        ${Status}=    Run Keyword And Return Status     xml.Element Should Not Exist    ${xml}    .//moduleReadyInd/productCode
        Run Keyword If    '${Status}'=='True'     Continue For Loop
        ${productCode}    Run Keyword If    '${msg_type}' == 'MCI'    xml.Get Element Text    ${xml}    Body/moduleReadyInd/productCode
        ${serialNum}    Run Keyword If    '${msg_type}' == 'MCI'    xml.Get Element Text    ${xml}    Body/moduleReadyInd/serialNum
        ${moduleType}    Run Keyword If    '${msg_type}' == 'MCI'    xml.Get Element Text    ${xml}    Body/moduleReadyInd/moduleType
        ${interfaceType}    Run Keyword If    '${msg_type}' == 'MCI'    xml.Get Element Text    ${xml}    Body/moduleReadyInd/interfaceType
        Exit For Loop
    END
    FOR     ${msg}    IN    @{msg_list}
        Continue For Loop If    '${msg}' == ''
        ${msg}    Replace String Using Regexp    ${msg}    <timestamp(.*)Z/>    ${EMPTY}
        ${flag}    Run Keyword And Return Status    xml.parse xml    ${msg}
        ${xml}    Run keyword If    '${flag}'=='False'    Continue For Loop
                    ...     ELSE    xml.parse xml    ${msg}
        ${msg_type}    Get Soap Msg type    ${xml}
        Continue For Loop If    '${msg_type}' == 'UNKNOW' or '${msg_type}' == 'MCI'
        ${Status}=    Run Keyword And Return Status     xml.Element Should Not Exist    ${xml}    .//swInventoryRsp/bldData/bldName
        Run Keyword If    '${Status}'=='True'     Continue For Loop
        ${bldName}    Run Keyword If    '${msg_type}' == 'SIRSP'    xml.Get Element Text    ${xml}    Body/swInventoryRsp/bldData/bldName
        ${bldVersion}    Run Keyword If    '${msg_type}' == 'SIRSP'    xml.Get Element Text    ${xml}    Body/swInventoryRsp/bldData/bldVersion
        Exit For Loop
    END
    &{soap_info}     Create Dictionary   productCode=${productCode}
    ...                                  serialNum=${serialNum}
    ...                                  moduleType=${moduleType}
    ...                                  interfaceType=${interfaceType}
    ...                                  bldName=${bldName}
    ...                                  bldVersion=${bldVersion}
    [Return]    &{soap_info}


Scf para modify
    [Arguments]      ${parameters_to_update_via_webui}    ${download_dir}=${TS_CASE_LOG_PATH}
    ...       ${is_need_to_check_validation_errors}=${True}
    log to console    Scf para modify
    @{diff_para} =    create list
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    FOR  ${cur_para_to_update}  IN  @{parameters_to_update_via_webui}
      ${cur_para_value}    selenium_coam.get_parameter_value
     ...    dist_name=${cur_para_to_update['dist_name']}
     ...    abbr=${cur_para_to_update['abbr']}
     ...    filter_param=${cur_para_to_update['filter_param']}
      Run keyword if    '${cur_para_value}'=='${cur_para_to_update['new_value']}'
     ...    Log to console    current value is ${cur_para_value}, no need to update
     ...    ELSE    run keywords
     ...    selenium_coam.set_parameter_value
     ...    dist_name=${cur_para_to_update['dist_name']}
     ...    abbr=${cur_para_to_update['abbr']}
     ...    filter_param=${cur_para_to_update['filter_param']}
     ...    new_value=${cur_para_to_update['new_value']}    AND
     ...    Append to list    ${diff_para}    ${cur_para_to_update}
    END
    Run keyword if    ${diff_para}    run keywords
    ...    selenium_coam.validate_plan    AND
    ...    COAM check validation errors from webui
    ...    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}    AND
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Teardown]    run keywords    selenium logout and close browser

Scf xml modify
    [Arguments]      ${scf_file_path}    ${parameters_to_update_xml}
    log to console    Scf xml modify
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${scf_dir_path}    String.Replace string    ${scf_file_path}    /${scf_file_name}    ${EMPTY}
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${scf_file_name_after_modify}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extention}
    ...    _${timestamp}_updated.xml
    ${modified_scf_file_path}    set variable    ${scf_dir_path}/${scf_file_name_after_modify}
    scf.Load Scf    ${scf_file_path}
    FOR  ${modify_para}  IN  @{parameters_to_update_xml}
      run keyword if    '${modify_para['operate']}'=='update'    scf.modify_scf_element
      ...    value=${modify_para['new_value']}    dist_name=${modify_para['dist_name']}
      ...    p_name=${modify_para['p_name']}
      run keyword if    '${modify_para['operate']}'=='delete'    scf.remove_mo_with_descendant_mos
      ...    dist_name=${modify_para['dist_name']}
      run keyword if    '${modify_para['operate']}'=='add_mo'    scf.add_object_to_scf
      ...    class_name=${modify_para['class_name']}    dist_name=${modify_para['dist_name']}
      ...    version=${modify_para['version']}
    END
    scf.save_scf    ${modified_scf_file_path}
    [Return]  ${modified_scf_file_path}

Restore swconfig and reboot gnb
    [Arguments]    ${ASIK_MASTER_ALIAS}=ASIK Master
    log to console    Restore swconfig and reboot gnb
    Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
    swconf.Restore swConfig file on asik and crasign    asik_alias=${ASIK_MASTER_ALIAS}
    csn.disconnect    connection=${ASIK_MASTER_ALIAS}
    Perform bts reboot and wait for on air

Change NCPRI PM Interval with version
    [Arguments]    ${interval}    ${SW_version}=${Active_SW_version}
    log to console   \nChange NCPRI PM Interval to ${interval}
    ${stream}    get stream from version    ${SW_version}
    ${dist_name}    set variable    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ${filter_param}=    Set Variable If
    ...     '${stream}'=='SBTS22R2'        eCPRI Master clock statistics measurement interval
    ...     SBTS NR eCPRI Master Statistics
    ${filter_param}=    Set Variable If
    ...     '${stream}'=='SBTS00'        SBTS eCPRI Master Statistics
    ...     SBTS NR eCPRI Master Statistics
    ${origin_value}  Get Parameter Via Webem    dist_name=${dist_name}    filter_param=${filter_param}
    run keyword if    '${interval}'!='${origin_value}'    selenium_coam.set_parameter_value  dist_name=${dist_name}
    ...    filter_param=${filter_param}
    ...    abbr=eCpriMasterStatisticsInterval    new_value=${interval}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Return]    ${origin_value}

Get lastest PM counter
    [Arguments]    ${counter_id}    ${counter_type}=BTS
    log to console    Get lastest PM counter
    Selenium Login With Version
    ${content}    run keyword if    '${counter_type}'=='BTS'    selenium_coam.get_bts_counters_info
    ...    counter_id=${counter_id}
    ...    ELSE    selenium_coam.get_transport_counters
    ...    counter_id=${counter_id}
    ${values}    Get Dictionary Values   ${content}
    [Return]     ${values[-1]}
    [Teardown]  run keywords    selenium logout and close browser

Check PM counter exception
    [Arguments]    ${counter_id}    ${exp_counter}    ${counter_type}=BTS
    log to console    Check PM counter exception
    ${actual_counter}    Get lastest PM counter    counter_id=${counter_id}    counter_type=${counter_type}
    should be true    '${actual_counter}'=='${exp_counter}'

Adjust HBTE ATT Values
    [Arguments]      ${attenuation_values_of_all_ports}
    log to console    Adjust HBTE ATT Value
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}   max_attenuation=${HBTE_max_value}    vendor=${vendor}
    ...    model=${model}
    FOR  ${port_num}    IN RANGE    0    8
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END

Adjust HBTE ATT Values seperate
    [Arguments]      ${attenuation_values_of_all_ports}
    log to console    Adjust HBTE ATT Value
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}   max_attenuation=${HBTE_max_value}    vendor=${vendor}
    ...    model=${model}
    FOR  ${port_num}    IN RANGE    0    4
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END
    FOR  ${port_num}    IN RANGE    8    12
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END

Catch bip log
    [Arguments]      ${sleep_time}
    Catch Bip log and download    ${sleep_time}
    ${list_log_path_local}  Download BIP Log
    [Return]    ${list_log_path_local}

Catch Bip log and download
    [Arguments]      ${time}
    Log To Console    \n ###start to catch bip log ###
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=ASIK Master
    Precondition for bip capture with gnbMirroring scripts
    Bip Capture with gnbMirroring scripts   sleep_time=${time}
    csn.send command    command=killall tcpdump     connection=ASIK Master

Download BIP Log
    [Arguments]       ${log_path}=${CURDIR}   ${download_type}=Download
    Log To Console    \n ###download bip log to testPC ###
    ${list_log_path_local}    Download BIP Logs From ASIK To TestPC and rename it
    ...    log_path=${log_path}
    ...    download_type=${download_type}
    Set Suite Variable      ${list_log_path_local}
    [Return]    ${list_log_path_local}

Verify Single UE PDSCH Schedule In SSB Slot
    [Arguments]       ${BIP_CSV_LOG}
    ${matches}    Get Match List From BIP Csv File    ${BIP_CSV_LOG}    ${CHECK_PDSCH_IN_SSB_REGEXP}
    Should Not Be Empty    ${matches}
    ${csv_content}    OperatingSystem.Get File    ${BIP_CSV_LOG}
    ${CHECK_PDSCH_PRB_REGEXP}     Set Variable
    ...        DlData_PdschSendReq.*?(?P<sfn>${matches[1][0]}).*?(?P<slot>0x00000010).*?(?P<numOfPrb>0x\\w+).*?
    ${PDSCH}    String.Get Regexp Matches    ${csv_content}    ${CHECK_PDSCH_PRB_REGEXP}   numOfPrb
    ${PDSCH}     Run Keyword    hex to oct    ${PDSCH[0]}
    FOR   ${item}   IN   @{matches}
          ${CHECK_PDSCH_IN_SSB_PRB_REGEXP}     Set Variable
          ...        DlData_PdschSendReq.*?(?P<sfn>${item[0]}).*?(?P<slot>${item[1]}).*?(?P<numOfPrb>0x\\w+).*?
          ${PDSCH_IN_SSB}    String.Get Regexp Matches    ${csv_content}    ${CHECK_PDSCH_IN_SSB_PRB_REGEXP}   numOfPrb
          ${PDSCH_IN_SSB}     Run Keyword    hex to oct    ${PDSCH_IN_SSB[0]}
          should be true     (${PDSCH}-32)>=${PDSCH_IN_SSB}>= (${PDSCH}-48)
    END

Verify Single UE PDSCH Schedule In TRS Slot
    [Arguments]        ${BIP_CSV_LOG}
    ${matches}    Get Match List From BIP Csv File    ${BIP_CSV_LOG}    ${CHECK_PDSCH_IN_TRS_REGEXP}
    Should Not Be Empty    ${matches}
    ${csv_content}    OperatingSystem.Get File    ${BIP_CSV_LOG}
    ${CHECK_PDSCH_PRB_REGEXP}     Set Variable
    ...        DlData_PdschSendReq.*?(?P<sfn>${matches[2][0]}).*?(?P<slot>0x00000010).*?(?P<numOfPrb>0x\\w+).*?
    ${PDSCH}    String.Get Regexp Matches    ${csv_content}    ${CHECK_PDSCH_PRB_REGEXP}   numOfPrb
    ${PDSCH}     Run Keyword    hex to oct    ${PDSCH[0]}
    FOR   ${item}   IN   @{matches}
          ${CHECK_PDSCH_IN_TRS_PRB_REGEXP}     Set Variable
          ...        DlData_PdschSendReq.*?(?P<sfn>${item[0]}).*?(?P<slot>${item[1]}).*?(?P<numOfPrb>0x\\w+).*?
          ${PDSCH_IN_TRS}    String.Get Regexp Matches    ${csv_content}    ${CHECK_PDSCH_IN_TRS_PRB_REGEXP}   numOfPrb
          ${PDSCH_IN_TRS}     Run Keyword    hex to oct    ${PDSCH_IN_TRS[0]}
          should be true     ${PDSCH_IN_TRS}== ${PDSCH}
    END

Verify Multi UE PDSCH Schedule In SSB Slot
    [Arguments]       ${BIP_CSV_LOG}
    ${matches}    Get Match List From BIP Csv File    ${BIP_CSV_LOG}    ${CHECK_PDSCH_IN_SSB_REGEXP}
    Should Not Be Empty    ${matches}
    ${csv_content}    OperatingSystem.Get File    ${BIP_CSV_LOG}
    ${CHECK_PDSCH_PRB_REGEXP}     Set Variable
    ...        DlData_PdschSendReq.*?(?P<sfn>${matches[1][0]}).*?(?P<slot>0x00000010).*?(?P<numOfPrb>0x\\w+).*?
    ${PDSCH}    String.Get Regexp Matches    ${csv_content}    ${CHECK_PDSCH_PRB_REGEXP}   numOfPrb
    ${total_prb_expected}    Calculate total prb    ${PDSCH}
    FOR   ${item}   IN   @{matches}
          ${CHECK_PDSCH_IN_SSB_PRB_REGEXP}     Set Variable
          ...        DlData_PdschSendReq.*?(?P<sfn>${item[0]}).*?(?P<slot>${item[1]}).*?(?P<numOfPrb>0x\\w+).*?
          ${PDSCH_IN_SSB}    String.Get Regexp Matches    ${csv_content}    ${CHECK_PDSCH_IN_SSB_PRB_REGEXP}   numOfPrb
          ${total_prb_in_SSB}    Calculate total prb    ${PDSCH_IN_SSB}
          should be true     (${total_prb_expected}-32)>=${total_prb_in_SSB}>= (${total_prb_expected}-48)
    END

Verify Multi UE PDSCH Schedule In TRS Slot
    [Arguments]        ${BIP_CSV_LOG}
    ${matches}    Get Match List From BIP Csv File    ${BIP_CSV_LOG}    ${CHECK_PDSCH_IN_TRS_REGEXP}
    Should Not Be Empty    ${matches}
    ${csv_content}    OperatingSystem.Get File    ${BIP_CSV_LOG}
    ${CHECK_PDSCH_PRB_REGEXP}     Set Variable
    ...        DlData_PdschSendReq.*?(?P<sfn>${matches[2][0]}).*?(?P<slot>0x00000010).*?(?P<numOfPrb>0x\\w+).*?
    ${PDSCH}    String.Get Regexp Matches    ${csv_content}    ${CHECK_PDSCH_PRB_REGEXP}   numOfPrb
    ${total_prb_expected}    Calculate total prb    ${PDSCH}
    FOR   ${item}   IN   @{matches}
          ${CHECK_PDSCH_IN_TRS_PRB_REGEXP}     Set Variable
          ...        DlData_PdschSendReq.*?(?P<sfn>${item[0]}).*?(?P<slot>${item[1]}).*?(?P<numOfPrb>0x\\w+).*?
          ${PDSCH_IN_TRS}    String.Get Regexp Matches    ${csv_content}    ${CHECK_PDSCH_IN_TRS_PRB_REGEXP}   numOfPrb
          ${total_prb_in_TRS}    Calculate total prb    ${PDSCH_IN_TRS}
          should be true     ${total_prb_in_TRS} == ${total_prb_expected}
    END

Calculate total prb
    [Arguments]       ${ue_prb_list}
        ${total_prb}    set variable    ${0}
        FOR    ${ue_prb}    IN    @{ue_prb_list}
              ${ue_prb}    Run Keyword    hex to oct    ${ue_prb}
              ${total_prb}    evaluate    ${total_prb}+ ${ue_prb}
        END
    [Return]    ${total_prb}

Covert BIP To Csv
    [Arguments]       ${list_log_path_local}   ${FILTER}=${FILTER_For_2538}
    ${bip_name}    Set Variable    ${list_log_path_local[0]}
    ${BIP_CSV_LOG}    Convert BIP Log Pcap To Csv
    ...       bip_log=${bip_name}    filter=${FILTER}    column_name=${COLUMN_NAME}    csv_name_tag=ssbtrs
    Set Suite Variable    ${BIP_CSV_LOG}
    [Return]    ${BIP_CSV_LOG}

Download And Unzip Lua File On Common Package
    [Arguments]    ${sw}
    Log To Console    download and unzip lua file...
    OperatingSystem.Run    rm ${output_dir}/luashark-*.zip
    ${lua_url}    Set Variable
    ...    ${PACKAGE_FTP_URL}/${sw}/${sw}_luashark.zip
    OperatingSystem.Run    wget ${lua_url} -P ${output_dir}
    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${output_dir}/${sw}_luashark.zip
  #  Run Keyword If    '${res}'=='False'    Download Previous Lua File    ${sw}
    OperatingSystem.Run    rm -rf ${output_dir}/generated_luashark
    OperatingSystem.Run    unzip ${output_dir}/*_luashark.zip -d ${output_dir}
    ${lua_script_path}    Set Variable    ${output_dir}/generated_luashark/luashark.lua
    [Return]    ${lua_script_path}

Get wait value minutes
    [Arguments]    ${interval}
    Connect to Common Unit Master
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    Get time from GNB
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    ${wait_time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
    [Return]    ${wait_time}

Check BTS Counter M55308C
    [Arguments]    ${interval}
	Connect to Common Unit Master
	selenium login and disable screen lock
	${value_M55308C00005}    Get PM Counter via Webem    counter_id=M55308C00005    interval=${interval}
	Should be True    ${value_M55308C00005} > 0
    ${value_M55308C00008}    Get PM Counter via Webem    counter_id=M55308C00008    interval=${interval}
    Should be True    ${value_M55308C00008} > 0
	${value_M55308C00015}    Get PM Counter via Webem    counter_id=M55308C00015    interval=${interval}
	Should be True    ${value_M55308C00015} > 0
    ${value_M55308C00017}    Get PM Counter via Webem    counter_id=M55308C00017    interval=${interval}
    Should be True    ${value_M55308C00017} > 0
	${value_M55308C00018}    Get PM Counter via Webem    counter_id=M55308C00018    interval=${interval}
	Should be True    ${value_M55308C00018} > 0
    selenium logout and close browser

Convert BIP Log Pcap To Csv
    [Arguments]    ${bip_log}    ${filter}    ${column_name}    ${csv_name_tag}
    [Documentation]    This keyword is to convert BIP log from pcap to csv
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_log} | Yes | pcap bip log incloude bip log folder and bip log name |
    ...    | ${filter} | yes | the filter to filter the massage need to check |
    ...    | ${column_name} | yes | the column whose value need to check |
    ...    | ${csv_name_tag} | yes | the tag for BIP csv log name |
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${bip_log} |    | /home/ute/5GBipL2L1_filtering_off.pcap |
    ...    | ${filter} |    | /home/ute/generated_luashark/luashark.lua |
    ...    | @{column_name} |    | DlData_PdschSendReq.PdschSendReq.slot | DlData_PdschSendReq.PdschSendReq.sfn |
    ...    | ... |    | DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot | DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.sfn |
    ...    | ... |    | DlData_PdschSendReq.PdschSendReq.slot | DlData_SsBlockSendReq.SsBlockSendReq.sfn |
    ...    | ${bip_csv_log} | Convert BIP Log Pcap To Csv | ${bip_log} | ${filter} | ${column_name} | pdsch |
    ${lua_script_path}    Download And Unzip Lua File On Common Package   sw=${sw_version}
    Log To Console    \nConvert BIP Log from Pcap to csv...
    ${column_name_str}    Catenate    SEPARATOR=${SPACE}-e${SPACE}    @{column_name}
    ${csv_log_name}    String.Replace String Using Regexp    ${bip_log}    \\.pcap.*    _${csv_name_tag}.csv
    ${cmd}    Catenate    SEPARATOR=${SPACE}    tshark -r ${bip_log} -X lua_script:${lua_script_path} -Y '${filter}'
    ...    -T fields -e _ws.col.No. -e _ws.col.Protocol -e _ws.col.Info
    ...    -e ${column_name_str} -E header=y -E separator=, -E quote=d -E occurrence=a > ${csv_log_name}
    ${rc}    OperatingSystem.Run And Return RC    ${cmd}
    [Return]    ${csv_log_name}

Get Match List From BIP Csv File
    [Arguments]    ${bip_csv_log}    ${check_point_regexp}
    [Documentation]    This keyword is to get match list from bip csv log with the specified regexp.
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_csv_log} | Yes | the file path for bip csv log |
    ...    | ${check_point_regexp} | Yes | the regexp for the check point |
    ...    Examples:
    ...    | ${dl_check_point_regexp} | Set Variable | UlData_PucchReceiveRespHarqD\\",+\\"(?P<NACK>0x\\d+)\\" |
    ...    | Get Match List From BIP Csv File | /home/ute/tcpdumpL2L1_filtering_off_dl_nack.csv | ${dl_check_point_regexp} |
    Log To Console    \nGet Match List From BIP Csv File...
    ${csv_content}    OperatingSystem.Get File    ${bip_csv_log}
    @{group_list}    Get Regexp Group List    ${check_point_regexp}
    @{match_list}    String.Get Regexp Matches    ${csv_content}    ${check_point_regexp}    @{group_list}
    [Return]    @{match_list}

Get Regexp Group List
    [Arguments]    ${check_point_regexp}
    [Documentation]    This keyword is to get group name form the specified regexp
    ...    | Input Parameters | Man. | Description |
    ...    | ${check_point_regexp} | Yes | the regexp for the check point |
    ...    Examples:
    ...    | @{group_list} | Get Regexp Group List | UlData_PucchReceiveRespHarqD\\",+\\"(?P<NACK>0x\\d+)\\" |
    @{group_list}    String.Get Regexp Matches    ${check_point_regexp}    \\(\\?P\\<(\\w+)\\>    1
    [Return]    @{group_list}

5GC001358_5GC002538 recovery
    [Arguments]    ${ue_type}
    Adjust HBTE ATT Values   ${ATTENUATION_VALUE_default}
    UE Detach for ${ue_type}
    CI_interface.Common Case Teardown

Check Value for 2537
    [Arguments]      ${bip_log_path}   ${luashark_path}   ${command_template}  ${num}=1
    Log To Console    Check Value for 2537
    ${packets}    Load BIP Log with Template Command
    ...      pcap_file=${bip_log_path}    command_template=${command_template}   luashark_path=${luashark_path}
    FOR    ${i}    IN RANGE    ${num}
        ${i}    Evaluate    ${i}+1
        @{mcs}    Get value from Bip Log by xpath    packets=${packets}
        ...    field_name=.//uldata_puschreceivereq[${i}]/UlData_PuschReceiveReq.grants_item_0.mcs
        @{nol}    Get value from Bip Log by xpath    packets=${packets}
        ...    field_name=.//uldata_puschreceivereq[${i}]/UlData_PuschReceiveReq.grants_item_0.numOfLayers
        @{nop}    Get value from Bip Log by xpath    packets=${packets}
        ...    field_name=.//uldata_puschreceivereq[${i}]/UlData_PuschReceiveReq.grants_item_0.numOfPrb
        ${length}    Get Length    ${mcs}
        should be true    ${length}>0
        check numOfLayers    length=${length}    mcs=@{mcs}    nol=@{nol}   nop=@{nop}
    END

Load BIP Log with Template Command
    [Arguments]    ${pcap_file}    ${command_template}    ${luashark_path}   ${tshark_path}=${TSHARK_PATH}
    ${packets}=   cap.load_pcap_file   pcap_file=${pcap_file}
    ...                                 tshark_path=${tshark_path}
    ...                                 luashark_path=${luashark_path}
    ...                                 command_template=${command_template}
    [Return]    ${packets}

Get value from Bip Log by xpath
    [Arguments]    ${packets}    ${field_name}
    ${value}    cap.get_field_value_by_xpath    pdml_list=${packets}    xpath=${field_name}
    [Return]    ${value}

check numOfLayers
    [Arguments]    ${length}    ${mcs}    ${nol}    ${nop}
    FOR    ${len}    IN RANGE    ${length}
        Run Keyword If    ${mcs}[${len}]==0x00000000 and ${nol}[${len}]==0x00000001    should be true    ${nop}[${len}]<=0x0000005D
        ...    ELSE IF    ${mcs}[${len}]==0x00000000 and ${nol}[${len}]==0x00000002    should be true    ${nop}[${len}]<=0x0000002E
        ...    ELSE    log    "not fit"
    END

Scf commission and wait for on-air
    [Arguments]   ${scf_name}
    Connect to gnb coam via ssl
    coam.perform_commissioning
    ...   scf_file=${scf_path}/${scf_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    COAM Check All Cells Onair    connection=GNB_OAM

Check ReferenceLevel and gainCorrection in RU SOAP log
    log to console    Check ReferenceLevel and gainCorrection in RU SOAP log
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}  ru_alias=RU_${ru_index}
        ${ru_type}    get ru type    ru_index=${ru_index}
        ${status}    csn.file_exists    remote_path=/ram/UnitOAM_SOAP_Log0.xml.gz    connection=RU_${ru_index}
        ${status_xml}    csn.file_exists    remote_path=/ram/UnitOAM_SOAP_Log0.xml    connection=RU_${ru_index}
        run keyword if    ${status}    csn.execute    command=gzip -d /ram/UnitOAM_SOAP_Log0.xml.gz    connection=RU_${ru_index}
        ${ReferenceLevel}     csns.execute
        ...    cat /ram/UnitOAM_SOAP_Log0.xml |grep -i '<parameterName>referenceLevel</parameterName><newValue>16.1</newValue>'
        ...    connection=RU_${ru_index}
        Should Contain    ${ReferenceLevel}    <parameterName>referenceLevel</parameterName><newValue>16.1</newValue>
        ${gainCorrection}    csns.execute
        ...    cat /ram/UnitOAM_SOAP_Log0.xml |grep -i '<parameterName>gainCorrection</parameterName><newValue>-19.8206</newValue>'
        ...    connection=RU_${ru_index}
        Should Contain    ${gainCorrection}    <parameterName>gainCorrection</parameterName><newValue>-19.8206</newValue>
        csn.Disconnect    connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master

Connect to Capacity Unit Loner AZQG
    [Documentation]    Connect to Capacity Unit Loner with IP or hostname which search from ASIK Master.
    ...                username and password are same to related ASIK Master.
    ...                set related ASIK Master as proxy is mandantory.
    ...                one ASIK connect to ABIL minnum one and maxnum three.
    ...                one ABIL contains one ABIL Master, one ABIL Slave, one ABIL Loner.
    [Arguments]    ${du_index}=${0}    ${hw_slot}=${1}    ${alias}=ABIL Loner    ${asik_alias}=ASIK Master
    ...            ${gnb_index}=${0}
    ${is_asib}    Check if ASIB card used    du_index=${du_index}    alias=${asik_alias}    gnb_index=${gnb_index}
    ${is_left_enabled}    If GNB In Left Side Of AMIA    connection=${asik_alias}
    ${hw_slot}    Run Keyword If    '${is_left_enabled}'=='${True}' and 0 < ${hw_slot} < 4    Set Variable
    ...    ${hw_slot}    ELSE IF    '${is_left_enabled}'=='${True}' and ${hw_slot} > 4    Evaluate    ${hw_slot}-4
    ...    ELSE IF    '${is_left_enabled}'=='${False}' and 0 < ${hw_slot} < 4    Evaluate    ${hw_slot}+4
    ...    ELSE IF    '${is_left_enabled}'=='${False}' and ${hw_slot} > 4    Set Variable    ${hw_slot}
    ...    ELSE    Set Variable    ${hw_slot}
    run keyword if    ${is_asib}    Connect to Capacity Unit Loner with hostname    gnb_index=${gnb_index}
    ...    du_index=${du_index}    hw_slot=${hw_slot}    alias=${alias}    master_alias=${asik_alias}
    ...    ELSE    Connect to Capacity Unit Loner with IP    du_index=${du_index}    hw_slot=${hw_slot}
    ...    alias=${alias}    asik_alias=${asik_alias}    gnb_index=${gnb_index}

Connect to Capacity Unit Master AZQG
    [Documentation]    Connect to Capacity Unit Master with IP or hostname which search from ASIK Master.
    ...                username and password are same to related ASIK Master.
    ...                set related ASIK Master as proxy is mandantory.
    ...                one ASIK connect to ABIL minnum one and maxnum three.
    ...                one ABIL contains one ABIL Master, one ABIL Slave, one ABIL Loner.
    [Arguments]    ${du_index}=${0}    ${hw_slot}=${1}    ${alias}=ABIL Master    ${asik_alias}=ASIK Master
    ...            ${gnb_index}=${0}
    ${is_asib}    Check if ASIB card used    du_index=${du_index}    alias=${asik_alias}    gnb_index=${gnb_index}
    ${is_left_enabled}    If GNB In Left Side Of AMIA    connection=${asik_alias}
    ${hw_slot}    Run Keyword If    '${is_left_enabled}'=='${True}' and 0 < ${hw_slot} < 4    Set Variable
    ...    ${hw_slot}    ELSE IF    '${is_left_enabled}'=='${True}' and ${hw_slot} > 4    Evaluate    ${hw_slot}-4
    ...    ELSE IF    '${is_left_enabled}'=='${False}' and 0 < ${hw_slot} < 4    Evaluate    ${hw_slot}+4
    ...    ELSE IF    '${is_left_enabled}'=='${False}' and ${hw_slot} > 4    Set Variable    ${hw_slot}
    ...    ELSE    Set Variable    ${hw_slot}
    ${hw_type}    Get hardware type    alias=${asik_alias}
    Run keyword if    ${is_asib}    Connect to Capacity Unit Master with hostname    gnb_index=${gnb_index}
    ...    du_index=${du_index}    hw_slot=${hw_slot}    alias=${alias}    master_alias=${asik_alias}
    ...    ELSE IF    'ASOD' in '${hw_type}'    Connect to fctlb    alias=${alias}    asik_alias=${asik_alias}
    ...    ELSE    Connect to Capacity Unit Master with IP    du_index=${du_index}    hw_slot=${hw_slot}
    ...    alias=${alias}    asik_alias=${asik_alias}    gnb_index=${gnb_index}

Check if ASIB card used
    [Documentation]    Author: Wang Yixiang     5G_PZ_MMW_HZ_1_SG
    ...    Get info from testline and check if ASIB used.
    ...    return ${True} or ${False}
    [Arguments]    ${du_index}=${0}    ${alias}=ASIK Master    ${gnb_index}=${0}
    ssh.connect_to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${alias}
    ${gnb_card_info}=    ssh.execute    command=ddal -s ddal_sysinfo_module_get_unit_id 0
    ...    connection=${alias}
    log to console    gNB card info:${gnb_card_info}
    ${ret}    run keyword and return status    should contain    ${gnb_card_info}    ASIB
    [Return]    ${ret}

COAM WebEM Login
    [Documentation]    login the coam webui
    [Arguments]   ${url}=https://${WEBUI_ADDR}   ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}   ${display}=${false}
    ...   ${driver_alias}=WEBEM_DRIVER   ${version}=None   ${alias}=${None}
    Return From Keyword If   '${alias}' in @{selenium_gnb_login}
    Run Keyword If   '${alias}'=='None'   Stop Firefox Pid
    run keyword if  not ${display}   selenium_coam.enable_virtual_display

    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${download_dir}   Set Variable   /tmp/tmp_download_${curr_data}
    ${driver}   selenium_coam.create_firefox_web_driver   download_dir=${download_dir}   name=${driver_alias}
    selenium_coam.set_scope   alias=${driver_alias}   scope=global
    selenium_coam.login
    ...   url=${url}
    ...   username=${username}
    ...   password=${password}
    ...   browser=${driver}
    ...   download_dir=${download_dir}
    ...   timeout=${120}
    ...   version=${version}
    ...   alias=${alias}
    Run Keyword and Ignore Error   selenium_coam.disable_message_box   coam=${alias}
    Run Keyword and Ignore Error   selenium_coam.disable_screen_lock   coam=${alias}
    Append To List   ${selenium_gnb_login}   ${alias}
    Set Global Variable   ${selenium_gnb_login}
    [Return]   ${driver}

Stop Firefox Pid
    OperatingSystem.Run   ps -ef | grep firefox | grep -v grep | awk '{print $2}' | xargs kill -9
    OperatingSystem.Run   ps -ef | grep firefox | grep -v grep | awk '{print $3}' | xargs kill -9

PTP Precondition
    Log To Console    PTP Precondition
    admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    name=default
    Get BTSId
    set test variable    ${syncStatus_path}    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/CLOCK_R-1
    set test variable    ${lockState_path}    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1
    set test variable    ${acceptedClock_path}    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1
    set test variable    ${syncInputType_RAU_path}    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    set test variable    ${syncInputType_new}    2.048MHz input
    set test variable    @{accept_clock_value_modify}    6
    set test variable    @{syncstate_ru_error}    HOLDOVER    FREERUN
    set test variable    @{syncstate_ru_ok}    FREERUN    LOCKED
    #set test variable    @{band78_thresholds}    78    100    3

Get BTSId
    ${bts_info}=  admin_cli.get_bts_info    connection=default
    set suite variable    ${mrbts_id}    ${bts_info["mrbtsID"]}
    set suite variable    ${nrbts_id}    ${bts_info['nrBtsId']}

Check all cells onAir
    Log To Console    Check cells onAir
    COAM Check All Cells Onair    connection=default

Lock cell
    log to console    Lock cell
    ${stream}    get stream from version    ${Active_SW_version}
    run keyword if    '${stream}'!='SBTS22R3'
    ...    admin_cli.lock    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    timeout=60s    connection=default
    ...    ELSE
    ...    admin_cli.lock_cell    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    timeout=60s    connection=default

Unlock cell
    log to console    unlock cell
    ${stream}    get stream from version    ${Active_SW_version}
    run keyword if    '${stream}'!='SBTS22R3'
    ...    admin_cli.unlock    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    timeout=60s    connection=default
    ...    ELSE
    ...    admin_cli.unlock_cell    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    timeout=60s    connection=default

Confirm cell status is locked
    log to console    Confirm cell status is locked
    Sleep    10s
    &{Cell_locked}    Wait Until Keyword Succeeds    2min    2s    selenium_coam.get_cell_info
    ${Cell_Locked}    set variable    ${Cell_locked}[Status]
    should be equal    ${Cell_Locked}[Administrative state]    Locked    ignore_case=True

Confirm cell status is unlocked
    log to console    Confirm cell status is unlocked
    Sleep    30s
    &{Cell_unlocked}    Wait Until Keyword Succeeds    2min    2s    selenium_coam.get_cell_info
    ${Cell_unlocked}    set variable    ${Cell_unlocked}[Status]
    should be equal    ${Cell_unlocked}[Administrative state]    Unlocked    ignore_case=True

Check If BTS Is OnAir
    ${bts_statuses_response}=    admin_cli.Get Bts Info    connection=default
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=OnAir

Lock RU via WebEM
    ${ru_list}    Get list of all ru
    FOR    ${ru_id}    IN    @{ru_list}
          selenium_coam.lock_ru    ru_index=${ru_id}
          sleep    30s
    END

Get list of all ru
    [Arguments]    ${connection}=default
    ${rmods}    coam.get_ids_for_all    class_name=RMOD   connection=${connection}
    ${rmods_id}    Create List
    FOR    ${rmod}    IN    @{rmods}
          ${rmod_id}    Fetch From Right    ${rmod}    -
          Append To List   ${rmods_id}    ${rmod_id}
    END
    [Return]    ${rmods_id}

Check if all RU is locked
    ${ru_list}    Get list of all ru
    FOR    ${ru_id}    IN    @{ru_list}
          ${ru_info_full}   selenium_coam.get_ru_info    ru_index=${ru_id}
          ${ru_info}         Get From Dictionary    ${ru_info_full}    Status
          should match regexp    ${ru_info}[Administrative state]    Locked
    END

Unlock RU via WebEM
    ${ru_list}    Get list of all ru
    FOR    ${ru_id}    IN    @{ru_list}
          selenium_coam.unlock_ru   ru_index=${ru_id}
          sleep    30s
    END

Check if all RU is unlocked
    ${ru_list}    Get list of all ru
    FOR    ${ru_id}    IN    @{ru_list}
          ${ru_info_full}   selenium_coam.get_ru_info    ru_index=${ru_id}
          ${ru_info}         Get From Dictionary    ${ru_info_full}    Status
          #Check given state    ${cell_info}    Administrative state    unlocked
    END

L3 call in unlocked RU
    Log To Console    L3 call in unlocked RU
    UE attach and check tp    tp_direction=both    dl_tp=200M    ul_tp=100M    exp_dl_tp=50    exp_ul_tp=50

UE teardown
    Log To Console    Stop traffic
    run keyword and ignore error    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
    run keyword and ignore error    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

Set parameters via webUI
    [Arguments]      ${parameters_to_update_via_webui}
    ...              ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    FOR  ${cur_para_to_update}  IN  @{parameters_to_update_via_webui}
        selenium_coam.set_parameter_value
        ...    abbr=${cur_para_to_update['abbr']}
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        ...    new_value=${cur_para_to_update['new_value']}
    END

TDDCPRI_eCPRI_switch_on_WebEM
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify remote update of RU from CPRI to eCRPI fronthaul
    ...    protocol type via WebEM interface.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 13.08.2021 - - Created
    ...    *******************
    [Arguments]    ${switch_to_radio_protocol}=ECPRI
    ${radio_protocol_temp}    get_radio_protocal_via_admin
    run keyword if    '${radio_protocol_temp}'=='${switch_to_radio_protocol}'
    ...    5GC001358_common_keyword.Gnb Cpri Ecpri Switch    current_pkg=${current_pkg}
    5GC001358_common_keyword.Gnb Cpri Ecpri Switch    current_pkg=${current_pkg}
	power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}
    UE attach and check tp    tp_direction=both    dl_tp=100M    ul_tp=100M    exp_dl_tp=20    exp_ul_tp=5
    #[Teardown]  delete Downloaded    ${current_pkg}

Gnb Cpri Ecpri Switch
    [Arguments]    ${current_pkg}
    selenium login and disable screen lock
    Delete CMD Object If Exist
    5GC001358_common_keyword.Add PRTCLCHGRES Object Via Webem
    log to console  start check fault 23 appear
    Wait For Expect Fault Present    faultId=23   timeout=600
    log to console  upload current version package and activate: ${current_pkg}
    Perform SW Update  ${SUITE_LOG_PATH}/${current_pkg}
    sleep  360
    Wait Until Keyword Succeeds    10min    360s    Check HW modules detection
    log to console  start check fault 23 disappear
    Wait For Expect Fault To Disappear  faultId=23   timeout=600
    run keyword and ignore error    Validate Check on WebEM
    COAM Wait gnb And Cells ready    timeout=15 min
    selenium login and disable screen lock
    Check Protocol Change Result Via Webem
    Delete CMD Object If Exist
    Selenium Logout And Close Browser
    ${radio_protocol_after_switch}    get_radio_protocal_via_admin
    #${scf_file_backup}    COAM Download scf from cluster  scf_dir_path=${SAVE LOG DIRECTORY}
    #log to console  after swicth to ${radio_protocol_after_switch},back up SCF PATH:${scf_file_backup}
    #${5793_SCF2}   run keyword if    '${radio_protocol_after_switch}'=='CPRI'
    #...    Replace String    ${Case_SCF_Path}    .xml    _5793_CPRI.xml
    #run keyword if    '${radio_protocol_after_switch}'=='CPRI'
    #...    Commissioning SCF And Check On Air      scf_path=${5793_SCF2}

Add PRTCLCHGRES Object Via Webem
    #[Arguments]    ${link_speed}    ${radio_protocol_type}
    log to console  \n***Add PRTCLCHGRES Object Via Webem***
    ${iqCompression}    ${link_speed}    ${radio_protocol_type}    5GC001358_common_keyword.Get Cpri Ecpri Switch Params
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1
    ...    object_class_name=CMD    id_value=1    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/CMD-1
    ...    object_class_name=PRTCLCHGREQ    id_value=1    timeout=15
    ${ru_index_list}    get all ru index
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${dist_name}    set variable    MRBTS-${mrbtsID}/MNL-1/CMD-1/PRTCLCHGREQ-1
        ${ru_index_temp}    convert to number  ${ru_index}
        ${node_index_temp}    Evaluate  ${ru_index_temp}-1
        selenium_coam.add_element    dist_name=${dist_name}
        ...    filter_param=Radio modules upgrade    abbr=rModUpgrade    timeout=15
        selenium_coam.set_parameter_value  dist_name=${dist_name}    filter_param=IQ Compression
        ...    abbr=iqCompression    new_value=${iqCompression}    node_index=${node_index_temp}
        selenium_coam.set_parameter_value  dist_name=${dist_name}    filter_param=Link speed
        ...    abbr=linkSpeed    new_value=${link_speed}    node_index=${node_index_temp}
        selenium_coam.set_parameter_value  dist_name=${dist_name}    filter_param=Radio protocol type
        ...    abbr=radioProtocolType    new_value=${radio_protocol_type}    node_index=${node_index_temp}
        selenium_coam.set_parameter_value  dist_name=${dist_name}    filter_param=Radio module distinguished name
        ...    abbr=rModDN    new_value=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    node_index=${node_index_temp}
    END
    selenium_coam.validate_plan
    run keyword and ignore error    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=15

Get Cpri Ecpri Switch Params
    [Documentation]    Auther: tingting.zhong@nokia-sbell.com
    Wait Until Keyword Succeeds    1min    10s    Connect to gnb coam via ssl
    ${radio_protocol}    get_radio_protocal_via_admin
    ${link_speed}    set variable if    '${radio_protocol}'=='CPRI'    eCpri25    Cpri7
    ${radio_protocol_type}    set variable if    '${radio_protocol}'=='CPRI'    25eCPRI    TDDCPRI
    ${iqCompression}    set variable if    '${radio_protocol}'=='CPRI'    eCPRI 9bits    none
    [Return]  ${iqCompression}    ${link_speed}    ${radio_protocol_type}

Download trunk SW
    [Arguments]    ${SW}=${Active_SW_version}    ${package_store_path}=${SAVE LOG DIRECTORY}
    ${sw_name}    ${sw_full_url}    get trunk sw name    SW=${SW}
    ${status}          run keyword and return status    file should exist  ${package_store_path}/${sw_name}
    run keyword if      ${status}    remove file    ${package_store_path}/${sw_name}
    ${sw_url}          Catenate    sudo wget ${sw_full_url} -nv -P ${package_store_path}
    ${res}             Run         ${sw_url}
    ${status}          run keyword and return status    file should exist  ${package_store_path}/${sw_name}
    should be true    ${status}
    [Return]    ${sw_name}

get trunk sw name
    [Arguments]    ${SW}=${Active_SW_version}
    ${sbts_status}    run keyword and return status     Should contain    ${SW}    SBTS
    #${sbts_temp}    run keyword and return status     Should Contain Any   ${SW}    SBTS00_ENB_9999    SBTS22R3_ENB_9999
    ${sbts_temp_22R2}    run keyword and return status     Should Contain   ${SW}    SBTS22R2
    ${sbts_temp_22R3}    run keyword and return status     Should Contain   ${SW}    SBTS22R3
    ${sbts_temp_trunk}    run keyword and return status     Should Contain   ${SW}    SBTS22R4
    ${sw_version}   run keyword if    ${sbts_temp_trunk}    Replace String    ${SW}    SBTS22R4    SBTS00
    ...           ELSE    set variable     ${SW}
    ${sw_name}    set variable if      ${sbts_status}    ${sw_version}_release_BTSSM_downloadable_A54.zip
    ...    AirScale-${SW}.zip
    ${arti_path}    run keyword if
    ...    ${sbts_status}==${True} and ${sbts_temp_trunk}==${True}      set variable     ${arti_hz_sbts}SBTS00_packages/
    ...    ELSE IF      ${sbts_status}==${True} and ${sbts_temp_22R2}==${True}      set variable     ${arti_hz_sbts}SBTS22R2_packages/
    ...    ELSE IF      ${sbts_status}==${True} and ${sbts_temp_22R3}==${True}      set variable     ${arti_hz_sbts}SBTS22R3_packages/
    ...    ELSE      set variable    ${arti_hz}
    ${sw_full_url}  set variable     ${arti_path}${sw_version}/${sw_name}
    [Return]    ${sw_name}    ${sw_full_url}

Active related branch CPRI SCF and wait onair
    ${sbts_temp_22R2}    run keyword and return status     Should Contain   ${Active_SW_version}    SBTS22R2
    ${sbts_temp_22R3}    run keyword and return status     Should Contain   ${Active_SW_version}    SBTS22R3
    ${sbts_temp_trunk}    run keyword and return status     Should Contain   ${Active_SW_version}    SBTS22R4
	run keyword if
    ...    ${sbts_temp_22R2}==${True}    Active 22R2 CPRI SCF
    ...    ELSE IF      ${sbts_temp_22R3}==${True}    Active 22R3 CPRI SCF
	...    ELSE IF      ${sbts_temp_trunk}==${True}    Active trunk CPRI SCF

Active 22R2 CPRI SCF
    ${5793_scf_dir_path}     String.Replace String     ${Golden_SCF_Path}    SCF_SBTS22R2.xml    5GC001358_5793
    Commissioning SCF And Check On Air    scf_path=${5793_scf_dir_path}/${SCF_with_5793_CPRI_22R2}

Active 22R3 CPRI SCF
    ${5793_scf_dir_path}     String.Replace String     ${Golden_SCF_Path}    SCF_SBTS22R3.xml    5GC001358_5793
    Commissioning SCF And Check On Air    scf_path=${5793_scf_dir_path}/${SCF_with_5793_CPRI_22R3}

Active trunk CPRI SCF
    ${5793_scf_dir_path}     String.Replace String     ${Golden_SCF_Path}    SCF_SBTS00.xml    5GC001358_5793
    Commissioning SCF And Check On Air    scf_path=${5793_scf_dir_path}/${SCF_with_5793_CPRI}


Validate Check on WebEM
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    selenium_coam.validate_plan
    ${relation_errors}    wait until keyword succeeds    1min    5s   selenium_coam.get_relation_errors
    ${ralation_error_list_num}   Get Length   ${relation_errors}
    Run Keyword And Ignore Error    Should be True    ${ralation_error_list_num}==${0}
	${hardware_errors}    wait until keyword succeeds    1min    5s   selenium_coam.get_hardware_errors
    ${hardware_error_list_num}   Get Length   ${hardware_errors}
    Run Keyword And Ignore Error    Should be True    ${hardware_error_list_num}==${0}

Save snapshot
    Log To Console    Save snapshot    console=yes
    ${snapshot_path}    ADMIN Collect Snapshot
    Set Suite Variable    ${snapshot_path}

ADMIN Collect Snapshot
    [Arguments]    ${snapshot_path}=${OUTPUT DIR}
    ${date}    DateTime.Get current date    result_format=%Y%m%d_%H%M%S
    coam.Collect snapshot
    ...        target_file_name=${snapshot_path}/Snapshot_${date}.zip
    ...        coverage=Full
    ...        force=True
    ...        timeout=1200
    ...        connection=default
    [Return]    ${snapshot_path}/Snapshot_${date}.zip

Verify if the snapshot contains the RFSW logs
    [Arguments]    ${snapshot_file}
    Extract zip file    ${snapshot_file}    /tmp/snapshot
    ${filecontents}     Grep file           /tmp/snapshot/snapshot_file_list.txt            *_RMOD_L_[0-9]_
    Log to Console      \n RMOD Files :\n${filecontents}
    Should contain      ${filecontents}     _RMOD_L_1_startup.zip       ignore_case=True
    Should contain      ${filecontents}     _RMOD_L_1_runtime.zip       ignore_case=True

Perform RU Reset repetition via WebEM
    [Arguments]    ${repitition_num}=1
    Log To Console    Perform RU Reset repetition via WebEM
    FOR    ${index}    IN RANGE    ${repitition_num}
       Perform RU Reset via WebEM
	   COAM Navigate to login page via webUI   download_dir=${TS_CASE_LOG_PATH}
       Wait Until Keyword Succeeds    20 min    30 sec    RU Led Status Change to Green
	   Selenium Logout And Close Browser
    END

Perform RU Reset via WebEM
    [Arguments]    ${ru_index}=${1}   ${download_dir}=${TS_CASE_LOG_PATH}
    ${ru_index}  Convert To Integer    ${ru_index}
    COAM Navigate to login page via webUI   download_dir=${download_dir}
    selenium_coam.reset_ru  ru_index=${ru_index}
	[Teardown]    Selenium Logout And Close Browser

RU Led Status Change to Green
    log to console    RU Led Status Change to Green    console=yes
    #COAM Navigate to login page via webUI   download_dir=${OUTPUT_DIR}
    ${RU_State}      Get Led status of given unit    unit_name=RMOD-1
    should be equal    ${RU_State}    Enabled
    #[Teardown]    COAM selenium logout

Get Led status of given unit
    [Arguments]    ${unit_name}
    Close startup view if visible
    ${led_status}    selenium_coam.Get Led Status Of An Unit    unit=${unit_name}
    [Return]    ${led_status}

Close startup view if visible
    #${startup_view_visible}=    run keyword and return status    Wait Until Element Is Visible    timeout=30
    #...    locator=//div[@class="footer"]//button[text()=" Close"]
    #run keyword if    ${startup_view_visible}    Click Element   locator=//div[@class="footer"]//button[text()=" Close"]
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window

Check RF config via WebEM
    log to console    Check RF config via WebEM
    #get RF SW from TargetBD
    log to console    \nget RF SW from TargetBD
    ${ruSW_expect_active}=    get RFSW active version in TargetBD
	${ruSW_expect_passive}=    get RFSW passive version in TargetBD
    #get RF SW from RF module
    log to console    \nget RF SW from RF module
    ${ruSW_fromModule}=    5GC001358_common_keyword.get RFSW version from radio module
    #get RF configuration from webui
    log to console    \nget RF configuration from webui
    ${output_ru}      selenium_coam.get_ru_info
    ${output_cell}    selenium_coam.get_cell_info
    &{rmodInfo_webui}    selenium_coam.get_hw_parameters     hw_type=RMOD    ###index=1
    ${pCode_webui}     set variable      ${output_ru}[Product code]    # 474877A.X21
    ${pName_webui}     set variable      ${output_ru}[Product name]    # AWHQG
    ${serNum_webui}    set variable      ${output_ru}[Serial number]   # EB193764266
    ${hwVer_webui}     set variable      ${output_ru}[HW version]      # X21
    ${nrBand_webui}    set variable      ${output_cell}[Band]          # n78
    ${runtimeParam_ru}     set variable    ${rmodInfo_webui}[Runtime parameters]
    ${ruSW_webui}          set variable    ${runtimeParam_ru}[RU active SW version]    # MRM69.11.R03
    #get RF configuration from M-Plane (OAM)
    log to console    \nget RF configuration from M-Plane (OAM)
    coam.connect_to    bts_host=${asik_addr}    name=GNB_OAM
    &{hw_info}       coam.get_detected_hw_info    connection=GNB_OAM
    ${pCode_oam}    set variable    ${hw_info.radioModules.rmod[0].productCode}    # 474877A.X21
    ${pName_oam}    set variable    ${hw_info.radioModules.rmod[0].productName}    # AWHQG
    ${serNum_oam}   set variable    ${hw_info.radioModules.rmod[0].serialNumber}   # EB193764266
    @{tmp}          split string    ${pCode_oam}    separator=.
    ${hwVer_oam}    set variable    ${tmp}[-1]       # X21
    coam.teardown    connection=GNB_OAM
    #get RF configuration from spec
    log to console    \nget RF configuration from spec
    define BPF params value from spec
    @{prodCode_tmp}    Get Regexp matches    ${ProductCode_expect}    <p Name="Visible.Product.Code">(.*)</p>   1
    set test variable    ${prodCode_expect}    ${prodCode_tmp}[0]
    @{unitType_tmp}    Get Regexp matches    ${unitType_expect}    <unitType>(.*)</unitType>   1
    set test variable    ${unitType_expect}    ${unitType_tmp}[0]
    @{variant_tmp}    Get Regexp matches    ${variant_expect}    <variant>(.*)</variant>   1
    set test variable    ${variant_expect}    ${variant_tmp}[0]
    ${pName_expect}    Catenate   SEPARATOR=   ${unitType_expect}    ${variant_expect}
    @{NRFreqBand_tmp}    Get Regexp matches    ${NRFreqBand_expect}   <list Name="NR.Frequency.Band"><p>(.*)</p><p>(.*)</p></list>  1
    set test variable    ${NRFreqBand_expect}    ${NRFreqBand_tmp}[0]
    ${NRFreqBand_expect}    Catenate   SEPARATOR=   n   ${NRFreqBand_expect}
    #compare RF configuration
    log to console    \ncompare RF configuration
	should be true    '${ruSW_webui}'=='${ruSW_expect_active}' or '${ruSW_webui}'=='${ruSW_expect_passive}'
    should be true    '${ruSW_fromModule}'=='${ruSW_webui}'
    should be true    '${serNum_webui}'=='${serNum_oam}'
    should be true    '${hwVer_webui}'=='${hwVer_oam}'
    should be true    '${pCode_webui}'=='${pCode_oam}' and '${pCode_oam}'=='${prodCode_expect}.${hwVer_webui}'
    should be true    '${pName_webui}'=='${pName_oam}' and '${pName_oam}'=='${pName_expect}'
    should be true    '${nrBand_webui}'=='${NRFreqBand_expect}'

get RFSW active version in TargetBD
    [Arguments]   ${radio_type}=${ru_type_init}
    ${TargetBD_FileName}   ${save_path}    5GC001358_common_keyword.check TargetBD exist and match for 1358
    set test variable    ${resBuild_key}    LTX_${radio_type}
    ${cmd_grep}   set variable   cat ${save_path}/${TargetBD_FileName}|grep 'hwResource resourceBuildKey="${resBuild_key}'
    ${result}=    Run Process    ${cmd_grep}    shell=True   timeout=30s   alias=myproc
    ${output_resBuildKey}=    Get Process Result     myproc
    @{ru_version}    Get Regexp matches    ${output_resBuildKey.stdout}    resourceSWVersion="(.*)"    1
    set test variable    ${ruSW_TargetBD}    ${ru_version}[0]
    [Return]    ${ruSW_TargetBD}

get RFSW passive version in TargetBD
    [Arguments]   ${radio_type}=${ru_type_init}
    ${TargetBD_FileName}   ${save_path}    5GC001358_common_keyword.check TargetBD exist and match for 1358
    set test variable    ${resBuild_key}    LTX_${radio_type}
    ${cmd_grep}   set variable   cat ${save_path}/${TargetBD_FileName}|grep 'hwResource resourceBuildKey="${resBuild_key}'
    ${result}=    Run Process    ${cmd_grep}    shell=True   timeout=30s   alias=myproc
    ${output_resBuildKey}=    Get Process Result     myproc
    @{ru_version}    Get Regexp matches    ${output_resBuildKey.stdout}    resourceSWVersion="(.*)"    1
    set test variable    ${ruSW_TargetBD}    ${ru_version}[1]
    [Return]    ${ruSW_TargetBD}

check TargetBD exist and match for 1358
    @{version}=    5GC001358_common_keyword.check SW version    Active
    set test variable    ${active_version}    ${version}[0]
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}   alias=gNB_target
    sleep   2s
    csn.send command    command=cd /ffs/run/;ls TargetBD_*.xml    connection=gNB_target
    ${TargetBD_FileName}=    csn.read output    connection=gNB_target
    run keyword and ignore error    csn.download file
    ...    /ffs/run/TargetBD_${active_version}.xml    ${TS_CASE_LOG_PATH}/TargetBD_${active_version}.xml
    ...    connection=gNB_target
    csn.disconnect    connection=gNB_target
    @{TargetBD_FileName}    string.split string    ${TargetBD_FileName}    separator=\
    ${TargetBD_FileName}    set variable    ${TargetBD_FileName}[0]
    should be equal as strings    '${TargetBD_FileName}'   'TargetBD_${active_version}.xml'
    ${save_path}    set variable    ${TS_CASE_LOG_PATH}
    [Return]    ${TargetBD_FileName}    ${save_path}

check SW version
    [Documentation]     output planned/active/passive version like:5G19_FSMK_0000_018351_000316
    [Arguments]      ${version_type}
    ${version}    selenium_coam.check_current_software_version
    ${output}    set variable    ${version}[${version_type}]
    [Return]      ${output}    ${version}

get RFSW version from radio module
    [Arguments]
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master
    Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1    asik_alias=ASIK Master    connection=GNB_OAM
    set test variable    ${cmd_ruSW}    cat /etc/version
    ${output_cmd_ruSW}    csn.execute    command=${cmd_ruSW}    connection=RU_1    timeout=60s
    ${ruSW_fromModule}    Fetch from left   string=${output_cmd_ruSW}    marker=${SPACE}
    ${ruSW_fromModule}    Strip string    ${ruSW_fromModule}
    run keyword and ignore error    csn.disconnect    connection=RU_1
    run keyword and ignore error    csn.disconnect    connection=ASIK Master
    [Return]    ${ruSW_fromModule}

Connect to AZQG With Allocated IP
    [Documentation]
    ...               Description: Get RU IP address In ASIK : Get RU IP Address from log in ASIK : /rom/config/FRIps.txt
    [Arguments]  ${ru_index}=${1}   ${ru_alias}=RU   ${asik_alias}=ASIK Master   ${connection}=default
    ...          ${container_id}=0x1018    ${container_alias}=Container    ${fhnet_host_ip}=192.168.255.254
    ...          ${ru_username}=${ru_username}
    ...          ${ru_password}=${ru_password}
    ${container_id}    Get FHNET Container ID    asik_alias=${asik_alias}
    &{ru_info}    get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${ru_ip_addr}   Coam Get RU IP via RMOD object  ru_serial_number=${ru_info['serialNumber']}  connection=${connection}
    ${output}    csn.execute    lxc-ls    connection=${asik_alias}
    ${feature_1834_opened}    Run Keyword And Return Status    Should Contain    ${output}    ${container_id}
    Run Keyword If    ${feature_1834_opened}
    ...    Connect To RU by FHNET Container    ru_ip_addr=${ru_ip_addr}
    ...                                         container_id=${container_id}
    ...                                         container_alias=${container_alias}
    ...                                         ru_alias=${ru_alias}
    ...                                         asik_alias=${asik_alias}
    ...                                         fhnet_host_ip=${fhnet_host_ip}
    ...                                         ru_username=${ru_username}
    ...                                         ru_password=${ru_password}
    ...    ELSE    csn.connect to    hostname=${ru_ip_addr}
    ...                              username=${ru_username}
    ...                              password=${ru_password}
    ...                              alias=${ru_alias}
    ...                              proxy=${asik_alias}

get ru detial info by ru index
    [Documentation]
    ...              Description: Get RU detail info by ru index
    ...              ${ru_index} Should be start from 1, should match the value with RMOD-*
    [Arguments]    ${ru_index}=1    ${connection}=default
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

Connect To RU by FHNET Container
    [Arguments]    ${ru_ip_addr}    ${container_id}=0x1018    ${container_alias}=Container    ${ru_alias}=RU
    ...            ${asik_alias}=ASIK Master    ${fhnet_host_ip}=192.168.255.254
    ...            ${ru_username}=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
    ...            ${ru_password}=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
    ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
    ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
    ...                                            Sleep    3 sec    AND
    ...                                            Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    close
    csn.connect to    hostname=${fhnet_host_ip}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${container_alias}
    ...               proxy=${asik_alias}
    csn.connect to    hostname=${ru_ip_addr}
    ...               username=${ru_username}
    ...               password=${ru_password}
    ...               alias=${ru_alias}
    ...               proxy=${container_alias}

define BPF params value from spec
    [Documentation]   This keyword defines BPF params value from Spec pov, such as
    ...    unit name, type, variant, product code, supported technologies, bands, bandwidth, powers, antennas, optical ports
    ...    Author: shasha.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    Example
    ...    |     | define BPF params value from spec | AWHQG |
    [Arguments]   ${radio_type}=${ru_type_init}
    set test variable   ${radio_type}
    run keyword if     '${radio_type}'=='AZQG'         run keywords
    ...    set test variable    ${ProductCode_expect}   <p Name="Visible.Product.Code">474994A</p>    AND
    ...    set test variable    ${unitType_expect}      <unitType>AZ</unitType>    AND
    ...    set test variable    ${variant_expect}       <variant>QG</variant>    AND
    ...    set test variable    ${SuppTech_expect}      <list Name="Supported.Technology"><p>5G</p></list>    AND
    ...    set test variable    ${FreqBand_expect}      <list Name="Frequency.Band"><p>3500</p>    AND
    ...    set test variable    ${optical_expect}       <p Name="Opt.Interfaces">0;1</p>    AND
    ...    set test variable    ${NumTRX_expect}        <p Name="Num.Of.RX">16</p><p Name="Num.Of.TX">16</p>    AND
    ...    set test variable    ${Bandwidth_expect}     <p Name="Max.Total.Bandwidth">100</p>    AND
    ...    set test variable    ${NRFreqBand_expect}    <list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>    AND
    ...    set test variable    ${MinFreq_expect}       <p Name="Min.Frequency">3400.0</p>    AND
    ...    set test variable    ${MaxFreq_expect}       <p Name="Max.Frequency">3599.9</p>
    ...    ELSE   log to console    not AZQG

399 Case Setup
    COAM Create log directory
    Wait Until Keyword Succeeds    5 min    5 sec    Connect to Common Unit Master
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    COAM Check GNB cell on air
    #Wait Until Keyword Succeeds    300 sec   5 sec     Check Gnb Type Via Webui
    ${exist_fault}    coam_gnb_classical.COAM Get active alarms
    Set test variable    ${exist_fault}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault}

399 Case TearDown
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run Keyword And Ignore Error    coam_gnb_classical.COAM Get active alarms
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error   csn.disconnect    connection=RU
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Slave
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master
    run keyword and ignore error   COAM Teardown gnb connections
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    CI_interface.Common Case Teardown

Validate And activate Plan
    [Arguments]    ${is_need_to_check_validation_errors}=False    ${activate_plan_despite_errors}=True
    selenium_coam.validate_plan
    COAM check validation errors from webui    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    COAM selenium logout

Restore Parameter If Test Case Failed
    [Arguments]     ${parameters_to_update_via_webui}=None     ${download_dir}=${TS_CASE_LOG_PATH}
    Run Keyword If Test Failed     Run Keyword And Ignore Error    Run Keyword    COAM Update several parameters via webUI
    ...                            parameters_to_update_via_webui=${parameters_to_update_via_webui}
    ...                            download_dir=${download_dir}
    ...                            is_gnb_restrat_after_online_modify=${True}
    Run Keyword And Ignore Error    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min

Check quantity of RD files on BTS for AZQG
    csn.connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    csn.Send Command    ls /tmp |grep RD.BTS    connection=ASIK Master
    ${files}=    csn.read_output    connection=ASIK Master
    @{files_list}=    Split String    ${files}    \n
    ${num_of_files}    Get Length    ${files_list}
    Should Be True    ${num_of_files}>2
    [Teardown]    csn.disconnect    connection=ASIK Master

Get snapshot and return parsed RD files for AZQG
    admin_cli.connect_to    bts_host=${asik_addr}     bts_port=${443}
    ${time}=    Get Current Date    result_format=%Y%m%d-%H%M%S
    set suite variable    ${snapshot_path}    /home/ute/Downloads/s${time}/Snapshot_${time}.zip
    set suite variable    ${unzipped}    /home/ute/Downloads/s${time}
    set suite variable    ${unzipped_PM}    ${unzipped}/PM
    admin_cli.get_snapshot    target_file_name=${snapshot_path}  timeout=2700
    OperatingSystem.Run    unzip ${snapshot_path} -d ${unzipped}
    ${files}=    OperatingSystem.Run    ls /home/ute/Downloads/s${time}/ | grep _2011_part_
    ${RD_files_list}    Get correct file with PM for AZQG   ${files}
    ${parsed_files}=    Extract and parse RD files for AZQG    ${RD_files_list}    ${unzipped_PM}
    [Return]     ${parsed_files}

Get correct file with PM for AZQG
    [Arguments]     ${files}
    @{files_list}=    Split String    ${files}    \n
    ${num_of_files}    Get Length    ${files_list}
    ${second_file}    evaluate    ${num_of_files} - 1
    ${third_file}    evaluate    ${num_of_files} - 2
    @{three_last_files}    create list   ${num_of_files}    ${second_file}   ${third_file}
    @{RD_files_list}    create list
    FOR    ${no}    IN    @{three_last_files}
        ${PM_file}=    Get Lines Containing String    ${files}    _2011_part_${no}
        OperatingSystem.Run    unzip ${unzipped}/${PM_file} -d ${unzipped_PM}
        ${RD_files}=    OperatingSystem.Run    ls ${unzipped}/PM | grep RD.BTS.*xml.gz
        @{RD_files_split_list}=    Split String    ${RD_files}    \n
        ${PMfile}=    get length    ${RD_files_split_list}
        Run Keyword If    ${PMfile}>1    Append to List    ${RD_files_list}    @{RD_files_split_list}
        Exit for loop if    ${RD_files_list}
    END
    [Return]    ${RD_files_list}

Extract and parse RD files for AZQG
    [Arguments]    ${RD_files_list}    ${unzipped_PM}
    FOR    ${file}    IN    @{RD_files_list}
        Run    gzip -d ${unzipped_PM}/${file}
        ${extracted_file}    Fetch From Left    ${file}    .gz
        ${parsed_files}    XML.Parse Xml    ${unzipped_PM}/${extracted_file}
    END
    [Return]    ${parsed_files}

Check counters from SFP monitoring- file iteration for AZQG
    [Arguments]    ${parsed_files}    ${MOD_SFP_dict}    ${measurementType}
    FOR    ${file}    IN    @{parsed_files}
       ${MOD_list}    Get Dictionary Keys    ${MOD_SFP_dict}
       Check counters from SFP monitoring- MOD iteration for AZQG    ${MOD_SFP_dict}    ${MOD_list}    ${file}    ${measurementType}
    END

Check counters from SFP monitoring- MOD iteration for AZQG
    [Arguments]    ${MOD_SFP_dict}    ${MOD_list}    ${file}    ${measurementType}
    FOR    ${MOD}    IN    @{MOD_list}
       @{SFP_list}    Get From Dictionary    ${MOD_SFP_dict}    ${MOD}
       Check counters from SFP monitoring- SFP iteration for AZQG    ${MOD_SFP_dict}    ${MOD}    ${file}    ${measurementType}    ${SFP_list}
    END

Check counters from SFP monitoring- SFP iteration for AZQG
    [Arguments]    ${MOD_SFP_dict}    ${MOD}    ${file}    ${measT}    ${SFP_list}
    log    ${MOD_SFP_dict}
    FOR    ${SFP}    IN    @{SFP_list}
       ${TEMPERATURE}    XML.Get Element Text    ${file}
       ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_TEMPERATURE
       ${XCVR_TX_SUPPLY_VOLTAGE}    XML.Get Element Text    ${file}
       ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_XCVR_TX_SUPPLY_VOLTAGE
       ${XCVR_TX_BIAS_CURRENT}    XML.Get Element Text    ${file}
       ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_XCVR_TX_BIAS_CURRENT
       ${XCVR_TX_PWR}    XML.Get Element Text    ${file}
       ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_XCVR_TX_PWR
       ${XCVR_RX_OPT_PWR}    XML.Get Element Text    ${file}
       ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_XCVR_RX_OPT_PWR
       Should Be True    -128<=${TEMPERATURE}<=128
       Should Be True    0<=${XCVR_TX_SUPPLY_VOLTAGE}<=100
       Should Be True    0<=${XCVR_TX_BIAS_CURRENT}<1000
       Should Be True    -100<=${XCVR_TX_PWR}<=100
       Should Be True    -100<=${XCVR_RX_OPT_PWR}<=100
    END

ASIx Power Off
    [Documentation]
    [Arguments]    ${model}=TOPYOUNG
    pdu.setup_pdu    model=${model}   host=${gnb_pdu_ip}    alias=gnb_pdu
    pdu.power_off    port=${gnb_pdu_port}    pdu_device=gnb_pdu

ASIx Power On
    [Documentation]
    [Arguments]    ${model}=TOPYOUNG
    pdu.setup_pdu    model=${model}   host=${gnb_pdu_ip}    alias=gnb_pdu
    pdu.power_on    port=${gnb_pdu_port}    pdu_device=gnb_pdu
