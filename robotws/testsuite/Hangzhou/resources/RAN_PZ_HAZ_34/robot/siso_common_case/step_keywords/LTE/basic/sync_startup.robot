*** Settings ***
Documentation    This is common keywords for LTE siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library      OperatingSystem
Library      String
Library      taf.transport.ssh    WITH NAME    csn
Library      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/parse_soap.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/soap.robot

*** Variables ***
${syncStatus_path}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/CLOCK_R-1
${lockState_path}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1
${acceptedClock_path}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1
${syncInputType_RAU_path}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
${syncInputType_new}    2.048MHz input
@{accept_clock_value_modify}    6
@{syncstate_ru_ok}    FREERUN    LOCKED

*** Keywords ***
Sync Startup is verified LTE
    [Documentation]  Author: jiayi.tang@nokia-sbell.com
    log to console  \n***Sync Startup is verified***
    ${bts_sync_mode}   Get Parameter Via Webem    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1    filter_param=BTS synchronization mode
    ${bts_sync_mode_1}   Get Parameter Via Webem    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/CLOCK_R-1
    ...    filter_param=Active synchronization mode
    should be equal as strings    ${bts_sync_mode_1}    ${bts_sync_mode}
    ${eCPRI_Master_clock_state}   Get Parameter Via Webem    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1
    ...    filter_param=eCPRI Master clock state
    should be equal as strings    ${eCPRI_Master_clock_state}    MASTER_CLOCK_OK
    Check eCPRI Basic configuration via SOAP message LTE

Check eCPRI Basic configuration via SOAP message LTE
    [Documentation]  Author: jiayi.tang@nokia-sbell.com
    [Arguments]    ${alias}=enb
    ${output}    Check Btsom Log file on LTE   filter=API    alias=${alias}
    Should Contain    ${output}    Sending API_INET_VLAN_SET_REQ_MSG
    Should Contain    ${output}    Sending API_START_PTP_REQ_MSG
    Should Contain    ${output}    Received API_START_PTP_RESP_MSG with status EeCpriStatus_NoError

Check Btsom Log file on LTE
    [Documentation]    Author: jiayi.tang@nokia-sbell.com
    [Arguments]    ${alias}=enb    ${logfolder}=fct-0a_aasyslog  ${filter}=None
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}     alias=${alias}
    ${status}    Run Keyword And Return Status    csn.assert file exists    remote_path=/tmp/startup_BTSOM.log    connection=${alias}
    ${command}    Set Variable If    '${status}'=='True'    cat /tmp/startup_BTSOM.log |grep -i '${filter}'
    ...                              '${status}'=='False'    xzcat /ffs/run/logs/${logfolder}/startup_BTSOM.log.xz |grep -i '${filter}'
    ${output}    csn.execute    command=${command}    connection=${alias}
    csn.disconnect    connection=${alias}
    [Return]    ${output}

Check eCPRI PTP State via Btsom Log LTE
    [Documentation]    Author: jiayi.tang@nokia-sbell.com
    [Arguments]    ${alias}=enb
    ${output}    Check Btsom Log file on LTE    alias=${alias}    filter=EeCpriStatus
    Should Contain    ${output}    Received API_START_SYNCE_RESP_MSG with status EeCpriStatus_NoError

get sync info of LTE
    [Documentation]    Author: jiayi.tang@nokia-sbell.com
    [Arguments]
    ...    ${syncst_path}=${syncStatus_path}
    ...    ${lockst_path}=${lockState_path}
    ...    ${accpetclock_path}=${acceptedClock_path}
    ...    ${syncinput_path}=${syncInputType_RAU_path}
    ${syncstatus}    selenium_coam.get_parameter_value    dist_name=${syncst_path}    filter_param=Clock synchronization status
    ${lockstate}    selenium_coam.get_parameter_value    dist_name=${lockst_path}    filter_param=ToP slave lock state
    ${accpetclock}    selenium_coam.get_parameter_value    dist_name=${accpetclock_path}    filter_param=Accepted clock class list
    sort list    ${accpetclock}
    ${syncinput}    selenium_coam.get_parameter_value    dist_name=${syncinput_path}    filter_param=Sync input type
    ${sync_info}    create dictionary    syncstatus=${syncstatus}    lockstate=${lockstate}
    ...    acceptclock=${accpetclock}   syncinput=${syncinput}
    [Return]    ${sync_info}

set sync info of LTE
    [Documentation]    Author: jiayi.tang@nokia-sbell.com
    [Arguments]
    ...    ${accpetclock_path}=${acceptedClock_path}
    ...    ${syncinput_path}=${syncInputType_RAU_path}
    ...    ${syncinput}=${syncInputType_new}
    ...    ${acceptclock}=${accept_clock_value_modify}
    selenium_coam.set_parameter_value
    ...    abbr=syncInputType
    ...    dist_name=${syncinput_path}
    ...    filter_param=Sync input type
    ...    new_value=${syncinput}
    sleep    1s
    selenium_coam.set_parameter_value
    ...    abbr=acceptedClockClass
    ...    dist_name=${accpetclock_path}
    ...    filter_param=Accepted clock class list
    ...    new_value=${acceptclock}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True

check sync info of RU LTE
    [Documentation]    Author: jiayi.tang@nokia-sbell.com
    [Arguments]    ${status}
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}    alias=ASIK Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP LTE    ru_username=${ru_username}    ru_password=${ru_password}
         ...   ru_index=${ru_index}  ru_alias=RU_${ru_index}
        ${log_path_ute}    Wait Until Keyword Succeeds   3x   10s    getsoapfile    connection=RU_${ru_index}
        ${syncstate}    get syncstate from soap log    local_soap_path=${log_path_ute}
        run keyword if    ${status}=='abnormal'    should be equal    ${syncstate[-1]}    FREERUN
         ...   ELSE    should be equal    ${syncstate}    ${syncstate_ru_ok}
        ${lockstate}    get lockstate from soap log    local_soap_path=${log_path_ute}
        run keyword if    ${status}=='abnormal'    should be equal    ${lockstate[-1]}    UNLOCKED
         ...   ELSE    should be equal    ${lockstate[-1]}    LOCKED
        ${acceptclock}    get acceptclock from soap log    local_soap_path=${log_path_ute}
        @{acceptclock_list}    split string    ${acceptclock[-1]}    ,
        ${accept_clock_value_modify}    convert to string    ${accept_clock_value_modify[0]}
        run keyword if    ${status}=='abnormal'    should be equal    ${acceptclock[-1]}    ${accept_clock_value_modify}
         ...   ELSE    should be equal    ${acceptclock_list}    ${sync_old['acceptclock']}
        csn.Disconnect    connection=RU_${ru_index}
    END

check sync status change of LTE
    [Documentation]    Author: jiayi.tang@nokia-sbell.com
    [Arguments]
    ...    ${syncst_path}=${syncStatus_path}
    ...    ${lockst_path}=${lockState_path}
    FOR  ${i}    IN RANGE    10
        ${syncstatus}    selenium_coam.get_parameter_value    dist_name=${syncst_path}    filter_param=Clock synchronization status
        Run keyword if    '${syncstatus}'=='Freerun'    exit for loop
        sleep    1s
    END
    Should be True    '${syncstatus}'=='Freerun'
    ${lockstate}    selenium_coam.get_parameter_value    dist_name=${lockst_path}    filter_param=ToP slave lock state
    Should be True    '${lockstate}'=='OutOfLock'

Wait For Expect Fault Present LTE
    [Documentation]   Auther: jiayi.tang@nokia-sbell.com
    ...               Description: wait expected fault to present
    ...               :param faultId<int|str>
    ...               :param timeout<str>: sec
    ...               :param source<str>: optional, full or partly match
    ...                 eg. MRBTS-75/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
    ...                     CABINET_R-1/SMOD_R-1
    ...                     SMOD_R-1
    ...               :param connection<str>:coam admin alias
    [Arguments]   ${faultId}   ${timeout}   ${source}=${None}   ${connection}=GNB_OAM
    Wait Until Keyword Succeeds   ${timeout} sec   5 sec    Expect Fault Should Present LTE
    ...                                                     faultId=${faultId}
    ...                                                     source=${source}
    ...                                                     connection=${connection}

Expect Fault Should Present LTE
    [Documentation]    Auther: jiayi.tang@nokia-sbell.com
    ...               Description: check expect alarm exist,add severity checkpoint by journey.jin@nokia-sbell.com
    ...               :param severity<str>: optional,value:Critical,Major,Minor,Warning
    ...               add checkpoint alarm id and fault id should be mapped by zheng.4.liu@nokia-sbell.com
    ...               add ${alarm['configObjectName']} due to some object don't have runtime object by zheng.4.liu@nokia-sbell.com
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=GNB_OAM    ${severity}=${None}    ${alarmId}=${None}
    ...            ${configObjectName}=${None}
    ${faultId}    Convert To Integer    ${faultId}
    Connect to gnb coam via ssl    bts_host=${sbts_addr}    username=${http_username}    password=${http_password}    connection=${connection}
    @{alarms}    coam.get_active_alarms    connection=${connection}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
       Exit For Loop If    ${alarm_num}==${0}
       ${present_status}    Run Keyword And Return Status    Run Keywords
                  ...                      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
                  ...                      Run Keyword If    '${source}'!='${None}'
                  ...                      Should Contain     ${alarm['notifier']}    ${source}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${severity}'!='${None}'
                  ...                      Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${alarmId}'!='${None}'
                  ...                      Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}    AND
                  ...                      Run Keyword If    '${config_object_name}'!='${None}'
                  ...                      Should Contain    ${alarm['configObjectName']}    ${config_object_name}
      Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on lte.

Wait For Expect Fault To Disappear LTE
    [Documentation]   Auther: jiayi.tang@nokia-sbell.com
    ...               Description: wait expected fault to disappear
    ...               :param faultId<int|str>
    ...               :param timeout<str>: sec
    ...               :param source<str>: optional, full or partly match
    ...                 eg. MRBTS-75/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
    ...                     CABINET_R-1/SMOD_R-1
    ...                     SMOD_R-1
    ...               :param connection<str>:coam admin alias
    [Arguments]   ${faultId}   ${timeout}   ${source}=${None}   ${connection}=GNB_OAM
    Wait Until Keyword Succeeds   ${timeout} sec   5 sec    Expect Fault Should Absent LTE
    ...                                                     faultId=${faultId}
    ...                                                     source=${source}
    ...                                                     connection=${connection}

Expect Fault Should Absent LTE
    [Documentation]    Auther: jiayi.tang@nokia-sbell.com
    [Arguments]   ${faultId}   ${source}=${None}   ${connection}=GNB_OAM
    ${status}    Run Keyword And Return Status   Expect Fault Should Present LTE   faultId=${faultId}
    ...                                                                        source=${source}
    ...                                                                        connection=${connection}
    Run Keyword If  ${status}==${True}   Fail   faultId ${faultId} reported by source ${source} is still present on lte.

Alarm in Given Alarm list Present LTE
    [Arguments]  ${connection}=GNB_OAM
    log to console  \n Check fault 1900 or 4008 on WebUI
    ${alarm_list}    create list    1900    4008
    ${status}    set variable    ${False}
    FOR    ${faultId}    IN    @{alarm_list}
        ${status}    run keyword and return status  Expect Fault Should Present LTE    faultId=${faultId}    connection=${connection}
        run keyword if    ${status}    log to console  \n fault ${faultId} raise on WebUI
        exit for loop if    ${status}
    END
    should be true    ${status}

Connect to RU With Allocated IP LTE
    [Documentation]   Auther: jiayi.tang@nokia-sbell.com
    ...               Description: Get RU IP address In ASIK from RMOD_L object
    [Arguments]  ${ru_index}=${1}   ${ru_alias}=RU   ${asik_alias}=ASIK Master   ${connection}=GNB_OAM
    ...          ${container_id}=0x1018    ${container_alias}=Container    ${fhnet_host_ip}=192.168.255.254
    ...          ${ru_username}=${tl.enbs[0].rms[0].default_ssh_connection_details.username}
    ...          ${ru_password}=${tl.enbs[0].rms[0].default_ssh_connection_details.password}
	  ${container_id}    Get FHNET Container ID    asik_alias=${asik_alias}
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${ru_ip_addr}  Coam Get RU IP via RMOD object  ru_serial_number=${ru_info['serialNumber']}  connection=${connection}
    ${output}    csn.execute    lxc-ls    connection=${asik_alias}
    ${feature_1834_opened}    Run Keyword And Return Status    Should Contain    ${output}    ${container_id}
    Run Keyword If    ${feature_1834_opened}
    ...    Connect To RU Via FHNET Container LTE   ru_ip_addr=${ru_ip_addr}
    ...                                         container_id=${container_id}
    ...                                         container_alias=${container_alias}
    ...                                         ru_alias=${ru_alias}
    ...                                         asik_alias=${asik_alias}
    ...                                         fhnet_host_ip=${fhnet_host_ip}
    ...                                         ru_username=${ru_username}
    ...                                         ru_password=${ru_password}
    ...                                         ru_index=${ru_index}
    ...                                         coam_connection=${connection}
    ...    ELSE    csn.connect to    hostname=${ru_ip_addr}
    ...                              username=${ru_username}
    ...                              password=${ru_password}
    ...                              alias=${ru_alias}
    ...                              proxy=${asik_alias}

Connect To RU Via FHNET Container LTE
    [Documentation]   Auther: jiayi.tang@nokia-sbell.com
    ...               Description: Connect To RU Via FHNET Container
    ...               ContainerID is 0x1018 for left side of AMIA, 0x2018 for right side.
    ...               eth0(FHNET) ip is 192.168.255.254
    [Arguments]    ${ru_ip_addr}    ${container_id}=0x1018    ${container_alias}=Container    ${ru_alias}=RU
    ...            ${asik_alias}=ASIK Master    ${fhnet_host_ip}=192.168.255.254
    ...            ${ru_username}=${tl.enbs[0].rms[0].default_ssh_connection_details.username}
    ...            ${ru_password}=${tl.enbs[0].rms[0].default_ssh_connection_details.password}
    ...            ${ru_index}=${1}
    ...            ${coam_connection}=GNB_OAM
    ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
    ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
    ...                                            Sleep    3 sec    AND
    ...                                            Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    close
    csn.connect to    hostname=${fhnet_host_ip}
    ...               username=${ssh_username}
    ...               password=${ssh_password}
    ...               alias=${container_alias}
    ...               proxy=${asik_alias}
    ${version_active_sw}    Coam Get Active SW Version    connection=${coam_connection}
    ${release}    Coam Get program version based on gNB active version    version_active_sw=${version_active_sw}
    ${ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}    connection=${coam_connection}
    ${radio_type}    set variable    ${ru_info}[productName]
    Run keyword if    '${release}' in @{release_need_service_account} and '${radio_type}' in @{ru_login_with_service_account}
    ...    Connect To RU By ServiceAccount
    ...            ru_ip_addr=${ru_ip_addr}
    ...            service_username=${service_username}
    ...            service_password=${service_password_${release}}
    ...            container_alias=${container_alias}
    ...            ru_alias=${ru_alias}
    ...    ELSE    csn.connect to
    ...            hostname=${ru_ip_addr}
    ...            username=${ru_username}
    ...            password=${ru_password}
    ...            alias=${ru_alias}
    ...            proxy=${container_alias}

Verify SOAP RP1 LTE
    [Arguments]  ${ru_index}=1  ${ru_type}=${ru_type_init}
    log to console  \n*** Verify SOAP RP1 ***
    Enable capture soap msg flag on RU    ru_alias=RU_${ru_index}
    sleep  20s
    ${soap_log_path}    Download soap msg from RU    ru_alias=RU_${ru_index}    log_path=${TS_CASE_LOG_PATH}
    Connect to gnb coam via ssl    bts_host=${sbts_addr}    username=${http_username}    password=${http_password}
    ${radio_protocol}    get_radio_protocal_via_admin    ru_index=${ru_index}
    &{soap_info}    Get Detail Info In SOAP Message    Soap_log_path=${soap_log_path}
    ${ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}
    ${ru_target_build}    COAM get expected ru sw version from target BD file    ru_resource_build_key=LTX_${ru_type}
    Should Be Equal As Strings    ${soap_info['productCode']}    ${ru_info['productCode']}
    Should Be Equal As Strings    ${soap_info['serialNum']}    ${ru_info['serialNumber']}
    Should Be Equal As Strings    ${soap_info['moduleType']}    RRH
    ${soap_interfaceType}    convert to uppercase    ${soap_info['interfaceType']}
    Should Be Equal As Strings    ${soap_interfaceType}    ${radio_protocol}
    Should Be Equal As Strings    ${soap_info['bldName']}    ${ru_target_build}
    Should Contain    ${soap_info['bldVersion']}    ${ru_target_build}

Change NCPRI PM Interval LTE
    [Arguments]  ${interval}
    log to console   \nChange NCPRI PM Interval to ${interval}
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    ${dist_name}    set variable    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ${filter_param}    set variable    SBTS NR eCPRI Master Statistics
    ${origin_value}  Get Parameter Via Webem    dist_name=${dist_name}    filter_param=${filter_param}
    run keyword if    '${interval}'!='${origin_value}'    selenium_coam.set_parameter_value  dist_name=${dist_name}
    ...    filter_param=${filter_param}
    ...    abbr=eCpriMasterStatisticsInterval    new_value=${interval}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    sleep    5s
    [Return]    ${origin_value}
    [Teardown]  Selenium Logout And Close Browser

Check Sync Counter LTE
    [Arguments]    ${change_interval}=5    ${TNL_ETHLK}=TNL-2/ETHLK/ETHLK-3
    log to console  \n***Check Sync Counter***
    Wait Until Next Counter Update    counter_period=${change_interval}
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    ${SyncMsg_Latest_value}    Get Transport Counters    counter_id=M40102C0
    ...                                        full_path=${TNL_ETHLK}/SBTS_NCPRI/topTxEcpriMstSyncMessg
    ${status}    Run Keyword And Ignore Error    Should Be True    4798 <= ${SyncMsg_Latest_value} <= 4802
    run keyword and ignore error    selenium_coam.refresh_page
    ${AnnMsg_Latest_value}    Get Transport Counters    counter_id=M40102C1
    ...                                       full_path=${TNL_ETHLK}/SBTS_NCPRI/topTxEcpriMstAnnounceMessg
    ${status}    Run Keyword And Ignore Error    Should Be True    2398 <= ${AnnMsg_Latest_value} <= 2402
    run keyword and ignore error    selenium_coam.refresh_page
    ${DelayRespMsg_Latest_value}    Get Transport Counters    counter_id=M40102C2
    ...                                       full_path=${TNL_ETHLK}/SBTS_NCPRI/topTxEcpriMstDelayRespMessg
    run keyword and ignore error    selenium_coam.refresh_page
    ${DelayReqMsg_Latest_value}    Get Transport Counters    counter_id=M40102C3
    ...                                       full_path=${TNL_ETHLK}/SBTS_NCPRI/topRxEcpriMstDelayReqMessg
    Should Be True    ${DelayRespMsg_Latest_value} == ${DelayReqMsg_Latest_value}
    run keyword and ignore error    selenium_coam.refresh_page
    ${SsmMsg_Latest_value}    Get Transport Counters    counter_id=M40102C4
    ...                                       full_path=${TNL_ETHLK}/SBTS_NCPRI/synceTxEcpriMstSsmMessg
    ${status}    Run Keyword And Ignore Error    Should Be True    298 <= ${SsmMsg_Latest_value} <= 302
    [Teardown]  Selenium Logout And Close Browser

Wait Until Next Counter Update
    [Arguments]    ${counter_period}=5    ${gnb_connection}=ASIK Master
    ${period}    Evaluate    ${counter_period}*60
    ${current}     csn.execute    command=date +%s    connection=${gnb_connection}
    ${current}    Get Line    ${current}    -1
    ${sleep}    Evaluate    ${period}+${period}-${current}+int(${current}/${period})*${period}
    Sleep    ${sleep}
    sleep    30

Get Transport Counters
    [Arguments]    ${counter_id}    ${full_path}
    ${counters}    selenium_coam.get_transport_counters    counter_id=${counter_id}    full_path=${full_path}
    ${values}    Get Dictionary Values   ${counters}
    [Return]    ${values[-1]}

Connect to Ru and check if certificate exists LTE
    [Arguments]    ${ru_index}=1
    csn.connect to   hostname=${sbts_addr}   username=${ssh_username}   password=${ssh_password}   alias=ASIK Master
    Connect to RU With Allocated IP LTE    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${cmd}   Set Variable  ls /etc/ssl/certs -l | grep "Nokia*"
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    csn.disconnect    connection=RU_${ru_index}
    Should Contain    ${output}    NokiaFactoryCA.pem
    Should Contain    ${output}    NokiaFactoryCA2067.pem
    Should Contain    ${output}    NokiaRootCA.pem
    Should Contain    ${output}    NokiaRootCA2067.pem
    [Teardown]    run keyword and ignore error    csn.disconnect    connection=ASIK Master

Check_Integrity_On_RU_LTE
    [Arguments]    ${ru_index}=1
    csn.connect to   hostname=${sbts_addr}   username=${ssh_username}   password=${ssh_password}   alias=ASIK Master
    Connect to RU With Allocated IP LTE    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${cmd}   Set Variable  sudo openssl x509 -in /etc/ssl/certs/NokiaRootCA.pem -text -noout
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    csn.disconnect    connection=RU_${ru_index}
    Should contain  ${output}  Signature Algorithm: sha256WithRSAEncryption
    Should contain  ${output}  Digital Signature, Certificate Sign, CRL Sign
    [Teardown]    run keyword and ignore error    csn.disconnect    connection=ASIK Master
