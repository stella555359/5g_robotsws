*** Settings ***
Documentation    This is common keywords for LTE siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library      OperatingSystem
Library      String
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/csn.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/common_ru_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/sync_startup.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/bpf.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/5GC000399_Keyword.robot

*** Keywords ***
Perform RU Power reset LTE
    [Arguments]  ${ru_index}=1
    log to console    \n***Perform RU Power reset**
    Perform RU Power Off LTE    ru_index=${ru_index}    model=${ru_pdu_vendor}    ru_pdu_ip=${ru_pdu_addr}
    ...    ru_pdu_port=${ru_pdu_port}
    Wait until keyword succeeds    3 min    20 sec    RU Should Be Power Off    ru_index=${ru_index}
    Perform RU Power On LTE    ru_index=${ru_index}    model=${ru_pdu_vendor}    ru_pdu_ip=${ru_pdu_addr}
    ...    ru_pdu_port=${ru_pdu_port}
    Wait until keyword succeeds    8 min    20 sec    RU Should Be Online    ru_index=${ru_index}

Perform RU Power Off LTE
    [Arguments]    ${ru_index}=${1}    ${model}=${tl.enbs[0].rms[${ru_index}-1].pdu_port.pdu.vendor}
    ...    ${ru_pdu_ip}=${tl.enbs[0].rms[${ru_index}-1].pdu_port.pdu.addr}
    ...    ${ru_pdu_port}=${tl.enbs[0].rms[${ru_index}-1].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}
    pdu.power_off    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}

Perform RU Power On LTE
    [Arguments]    ${ru_index}=${1}    ${model}=${tl.enbs[0].rms[${ru_index}-1].pdu_port.pdu.vendor}
    ...    ${ru_pdu_ip}=${tl.enbs[0].rms[${ru_index}-1].pdu_port.pdu.addr}
    ...    ${ru_pdu_port}=${tl.enbs[0].rms[${ru_index}-1].pdu_port.port_no}
    pdu.setup_pdu    model=${model}    host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}
    pdu.power_on    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}

Check LED Status In RU Log LTE
    [Arguments]  ${led_status_list}  ${log_name}=RU_log    ${ru_index}=1  ${timestamp}=${None}  ${exclude_led_status}=GREEN GREEN
    log to console    \n***Check LED Status In RU Log***
    Collect RF Logs To TestPC LTE    log_name=${log_name}    ru_index=${ru_index}
    ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status LTE    log_name=${log_name}    timestamp=${timestamp}
    check LED list    matches=${mathes}    led_status_list=${led_status_list}    exclude_led_status=${exclude_led_status}
    [Return]  ${new_timestamp}

Collect RF Logs To TestPC LTE
    [Arguments]  ${log_name}=ru_log  ${ru_index}=1  ${asik_alias}=ASIK Master  ${log_path}=${TS_CASE_LOG_PATH}
    ${ru_log_name}    set variable    ${log_name}.zip
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}  alias=${asik_alias}
    Connect to RU With Allocated IP LTE    ru_username=${ru_username}    ru_password=${ru_password}   ru_index=${ru_index}
    ...    asik_alias=${asik_alias}    ru_alias=RU_${ru_index}
    FOR  ${i}    IN RANGE    3
        csn.execute     cd /usr/bin;ccsShell.sh log -a -c full -z /ram/${log_name}.zip    connection=RU_${ru_index}    timeout=300
        sleep  15
        ${output_log}    csn.execute    ls /ram/ |grep -i ${log_name}.zip    connection=RU_${ru_index}
        ${output_log}    replace string    ${output_log}    \r\n    ${EMPTY}
        ${status_log}    run keyword and return status    should contain    ${output_log}    ${log_name}.zip
        Exit For Loop if    ${status_log}==True
    END
    &{ru_info}    COAM get ru detial info by ru index   connection=GNB_OAM
    ${ru_ip_addr}   Coam Get RU IP via RMOD object  ru_serial_number=${ru_info['serialNumber']}  connection=GNB_OAM
    Wait until keyword succeeds    5 min    20 sec    csn.download file    remote_path=/ram/${log_name}.zip
    ...    local_path=${log_path}/${log_name}.zip   connection=RU_${ru_index}
    [Teardown]  Run Keywords   Run Keyword And Ignore Error   csn.disconnect   connection=RU_${ru_index}  AND
    ...                        Run Keyword And Ignore Error   csn.disconnect   connection=Container   AND
    ...                        Run Keyword And Ignore Error   csn.disconnect   connection=${asik_alias}

Get Last LED Timestamp and Status LTE
    [Arguments]  ${log_name}=ru_log     ${timestamp}=${None}
    Run  rm -rf ${TS_CASE_LOG_PATH}/${log_name}
    Run  unzip ${TS_CASE_LOG_PATH}/${log_name}.zip -d ${TS_CASE_LOG_PATH}/${log_name}
    Run  unzip ${TS_CASE_LOG_PATH}/${log_name}/${ru_runtime_zip} -d ${TS_CASE_LOG_PATH}/${log_name}
    Run  unxz ${TS_CASE_LOG_PATH}/${log_name}/${ru_runtime_xz}
    ${content}  get_binary_file  ${TS_CASE_LOG_PATH}/${log_name}/${ru_runtime_log}
    ${content}  Convert To String    ${content}
    ${new_content}  ${new_timestamp}  Cut Out Runtime Log  content=${content}  timestamp=${timestamp}
    ${matches}    Get Regexp Matches    ${new_content}    New status for led 0: Colors: (.+?) Priority:    1
    [Return]  ${matches}  ${new_timestamp}

Perform RAC and RAU Power Off LTE
    [Arguments]  ${ru_index_list}
    log to console    \n***Perform RAC and RAU Power Off***
    Perform Site Power Off LTE   model=${smod_pdu_vendor}    smod_pdu_addr=${smod_pdu_addr}    smod_pdu_port=${smod_pdu_port}
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power Off LTE   ru_index=${ru_index}    model=${ru_pdu_vendor}    ru_pdu_ip=${ru_pdu_addr}
        ...    ru_pdu_port=${ru_pdu_port}
        sleep    15s
    END

Perform RAC Power On LTE
    [Arguments]  ${ru_index_list}  ${timeout}=17min
    log to console    \n***Perform RAC Power On***
    Perform Site Power On LTE   model=${smod_pdu_vendor}    smod_pdu_addr=${smod_pdu_addr}    smod_pdu_port=${smod_pdu_port}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    bts_host=${sbts_addr}    username=${http_username}    password=${http_password}
    Wait For Expect Fault Present LTE  faultId=10  timeout=${timeout}
    FOR  ${ru_index}  IN  @{ru_index_list}
         RU Should Be Power Off    ru_index=${ru_index}
    END

Power On RU_and_check RF Delayed Startup LTE
    [Arguments]  ${ru_index_list}
    log to console    \n***Power On RU_and_check RF Delayed Startup***
    FOR  ${ru_index}  IN  @{ru_index_list}
         Perform RU Power On LTE    ru_index=${ru_index}    model=${ru_pdu_vendor}    ru_pdu_ip=${ru_pdu_addr}
         ...    ru_pdu_port=${ru_pdu_port}
    END
#    Wait Until Keyword Succeeds    20min     30s     verify all cells should be onair    cell_type=${cell_type}
    Wait Until Keyword Succeeds    20min     30s     Check all cells info should be onair

Perform Site Power Off LTE
    [Arguments]    ${model}=${tl.enbs[0].system_module[0].pdu_port.pdu.vendor}
    ...    ${smod_pdu_addr}=${tl.enbs[0].system_module[0].pdu_port.pdu.addr}
    ...    ${smod_pdu_port}=${tl.enbs[0].system_module[0].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${smod_pdu_addr}    alias=gnb_pdu
    pdu.power_off    port=${smod_pdu_port}    pdu_device=gnb_pdu
    BuiltIn.Log    Reset Site via Power off and Power On.

Perform Site Power On LTE
    [Arguments]    ${model}=${tl.enbs[0].system_module[0].pdu_port.pdu.vendor}
    ...    ${smod_pdu_addr}=${tl.enbs[0].system_module[0].pdu_port.pdu.addr}
    ...    ${smod_pdu_port}=${tl.enbs[0].system_module[0].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${smod_pdu_addr}    alias=gnb_pdu
    pdu.power_on    port=${smod_pdu_port}    pdu_device=gnb_pdu

Power On RU And Check LTE
    [Arguments]  ${ru_index_list}
    log to console    \n***Power On RU And Check***
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power on LTE    ru_index=${ru_index}    model=${ru_pdu_vendor}    ru_pdu_ip=${ru_pdu_addr}
         ...    ru_pdu_port=${ru_pdu_port}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Online   ru_index=${ru_index}
    END
    Wait Until Keyword Succeeds    20min     30s     verify all cells should be onair    cell_type=${cell_type}

Lock all RUs and check status LTE
    [Arguments]    ${ru_index_list}
    log to console  \n***Lock all RUs and check status ***
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.lock_ru  ru_index=${ru_index}
        sleep  30
    END
    connect to gnb coam via ssl    bts_host=${sbts_addr}    username=${http_username}    password=${http_password}
    FOR  ${ru_index}  IN  @{ru_index_list}
        wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${ru_index}
    END

Unlock all RUs and check status LTE
    [Arguments]      ${ru_index_list}
    log to console  \n***Unlock all RUs and check status ***
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.unlock_ru  ru_index=${ru_index}
        sleep  30
    END
    FOR  ${ru_index}  IN  @{ru_index_list}
        wait until keyword succeeds  5min  20sec  RU Should Be Unlocked    ru_index=${ru_index}
    END

Perform BTS Site Reset LTE
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    [Teardown]  Selenium Logout And Close Browser

    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.reset_site    with_graceful=${False}

Perform RU Power Off And On LTE
    [Arguments]    ${ru_index_list}    ${ru_index}=${1}
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power reset LTE    ru_index=${ru_index}
    END

check RU config LTE
    [Arguments]    ${ru_index_list}
    csn.connect to   hostname=${sbts_addr}   username=${ssh_username}   password=${ssh_password}   alias=ASIK Master
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP LTE    ru_username=${ru_username}    ru_password=${ru_password}
        ...    ru_index=${ru_index}    asik_alias=ASIK Master    ru_alias=RU_${ru_index}
        ${PC_soap_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
        ${productCode_cmd_cat}=    Catenate    cat ${PC_soap_path} | grep productCode
        ...    | tail -n 1 | awk -F'productCode>' '{print$2}' | awk -F'<' '{print$1}' | tr -d '\r\n'
        ${output_productCode_cmd_catSOAP}    run    command=${productCode_cmd_cat}
        ${serialNum_cmd_cat}=    Catenate    cat ${PC_soap_path} | grep serialNum |
        ...    sed -n '1p' | awk -F'serialNum>' '{print$2}' | awk -F'<' '{print$1}' | tr -d '\r\n'
        ${output_serialNum_cmd_catSOAP}    run    command=${serialNum_cmd_cat}
        ${bldName_cmd_cat}=    Catenate    cat ${PC_soap_path} | grep bldName |
        ...    tail -n 1 | awk -F'bldName>' '{print$2}' | awk -F'<' '{print$1}' | tr -d '\r\n'
        ${output_bldName_cmd_catSOAP}    run    command=${bldName_cmd_cat}
        log to console    \n***Check RF config from webui***
        ${radio_type}    get ru type  ru_index=${ru_index}
        ${ruSW_expect}=    get RFSW version from TargetBD LTE    radio_type=${radio_type}
        ${pCode_webui}  ${pName_webui}  ${pName_webui}  ${serNum_webui}  ${hwVer_webui}
        ...    get RF configuration from webui LTE  ru_index=${ru_index}
        Should Be Equal As Strings    ${output_productCode_cmd_catSOAP}    ${pCode_webui}
        Should Be Equal As Strings    ${output_serialNum_cmd_catSOAP}    ${serNum_webui}
        Should Be Equal As Strings    ${output_bldName_cmd_catSOAP}    ${ruSW_expect}
    END

get RFSW version from TargetBD LTE
    [Arguments]   ${radio_type}=${ru_type_init}
    ${Radio_Protocol_Type}  Get Radio Protocol
    ${TargetBD_FileName}   ${save_path}    check TargetBD exist and match LTE
    set test variable    ${resBuild_key}    LTX_${radio_type}
    ${cmd_grep}   set variable   cat '${save_path}/${TargetBD_FileName}'|grep 'hwResource resourceBuildKey="${resBuild_key}'
    ${result}=    Run Process    ${cmd_grep}    shell=True   timeout=30s   alias=myproc
    ${output_resBuildKey}=    Get Process Result     myproc
    @{ru_version}    Get Regexp matches    ${output_resBuildKey.stdout}    resourceSWVersion="(.*)"    1
    ${version_length}    get length    ${ru_version}
    ${ruSW_TargetBD}    set variable if    ${version_length}==${1} or '${Radio_Protocol_Type}'=='CPRI'    ${ru_version}[0]
    ...    ${ru_version}[1]
    [Return]    ${ruSW_TargetBD}

get RF configuration from webui LTE
    [Arguments]  ${ru_index}=1
    log to console    \n get RF configuration from webui
    ${output_ru}      selenium_coam.get_ru_info    ru_index=${ru_index}
    log to console    ${output_ru}
    &{rmodInfo_webui}    selenium_coam.get_hw_parameters     hw_type=RMOD    ###index=1
    ${pCode_webui}     set variable      ${output_ru}[Product code]    # 474877A.X21
    ${pName_webui}     set variable      ${output_ru}[Product name]    # AWHQG
    ${serNum_webui}    set variable      ${output_ru}[Serial number]   # EB193764266
    ${hwVer_webui}     set variable      ${output_ru}[HW version]      # X21
    [Return]  ${pCode_webui}  ${pName_webui}  ${pName_webui}  ${serNum_webui}  ${hwVer_webui}

Get RU IP AND Check Pingable LTE
    [Arguments]    ${ru_index}    ${container_id}=0x1018
    ${ip}=    Get RU IP Address LTE    ru_index=${ru_index}
        csn.connect to   hostname=${sbts_addr}   username=${ssh_username}   password=${ssh_password}   alias=ASIK Master
    ${output}=    ssh.execute    command=lxc-attach -n ${container_id} -- ping -c 30 -W 10 ${ip}    connection=ASIK Master
    Should contain    ${output}    30 packets transmitted, 30 received
    ssh.disconnect                   connection=ASIK Master

Get RU Beamforming Count Enhance LTE
    [Arguments]  ${ru_index}=1    ${get_count}=${False}    ${connection}=GNB_OAM    ${check_time}=15
    csn.connect to   hostname=${sbts_addr}   username=${ssh_username}   password=${ssh_password}   alias=ASIK Master
    ${radio_protocol}    get_radio_protocal_via_admin    ru_index=${ru_index}    connection=${connection}
    Connect to RU With Allocated IP LTE    ru_username=${ru_username}    ru_password=${ru_password}   ru_index=${ru_index}
    ...    asik_alias=ASIK Master    ru_alias=RU_${ru_index}
    ${tx_num}    ${rx_num}    ${time}    Check ECPRI RU Beamforming Enhance    ru_alais=RU_${ru_index}
    ...    get_count=${get_count}
    csn.execute    command=sudo bfcali -forceStart    connection=RU_${ru_index}
    sleep    30s
    ${tx_num_force}    ${rx_num_force}    ${time_force}    Check ECPRI RU Beamforming Enhance    ru_alais=RU_${ru_index}
    ...    get_count=${get_count}
    should be true    ${tx_num_force}>${tx_num}
    should be true    ${rx_num_force}>${rx_num}
    ${time_diff}=  Subtract Date From Date    ${time_force}    ${time}
    should be true    ${time_diff}>0
    sleep    ${check_time}min
    ${tx_num_wait}    ${rx_num_wait}    ${time_wait}    Check ECPRI RU Beamforming Enhance    ru_alais=RU_${ru_index}
    ...    get_count=${get_count}
    should be true    ${tx_num_wait}>${tx_num_force}
    should be true    ${rx_num_wait}>${rx_num_force}
    ${time_diff_wait}=  Subtract Date From Date    ${time_wait}    ${time_force}
    should be true    ${time_diff_wait}>0
    csn.execute    command=sudo bfcali -stop    connection=RU_${ru_index}
    sleep    ${check_time}min
    ${tx_num_stop}    ${rx_num_stop}    ${time_stop}    Check ECPRI RU Beamforming Enhance    ru_alais=RU_${ru_index}
    ...    get_count=${get_count}
    Should Be Equal    ${tx_num_stop}  ${tx_num_wait}
    Should Be Equal    ${rx_num_stop}  ${rx_num_wait}
    ${time_diff_stop}    robot.libraries.DateTime.Subtract Date From Date    ${time_stop}    ${time_wait}
    ${time_diff_stop}    convert to string    ${time_diff_stop}
    Should be Equal As Strings    ${time_diff_stop}  0.0
    csn.execute    command=sudo bfcali -forceStart    connection=RU_${ru_index}
    sleep    30s
    ${tx_num_force_2}    ${rx_num_force_2}    ${time_force_2}    Check ECPRI RU Beamforming Enhance
    ...    ru_alais=RU_${ru_index}    get_count=${get_count}
    should be true    ${tx_num_force_2}>${tx_num_stop}
    should be true    ${rx_num_force_2}>${rx_num_stop}
    ${time_diff_force_2}    robot.libraries.DateTime.Subtract Date From Date    ${time_force_2}    ${time_stop}
    should be true    ${time_diff_force_2}>0
    csn.Disconnect  connection=RU_${ru_index}
    [Return]    ${tx_num}    ${rx_num}    ${time}
    [Teardown]    csn.Disconnect  connection=ASIK Master
