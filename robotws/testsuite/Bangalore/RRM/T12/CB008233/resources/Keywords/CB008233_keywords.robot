*** Settings ***
Library         BuiltIn
Library         Collections
Library         DateTime
Library         OperatingSystem
Library         Process
Library         String
Library         XML
Library         re
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         taf.sw.syslog       WITH NAME   slog
Library         ta5g_pm_counters
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot

Documentation       :copyright: Nokia
...                 :author   : Vikash Kumar
...                 :contact  : vikash.20.kumar@nokia.com
...                 :Feature Related all common Keywords


*** Variables ***
${DELTACONFIGDIR}          ${CURDIR}/../../config/gnb_scf
${APCONFIGDIR}             ${CURDIR}/../../config/ap_iphy
${VLAN_ID}                 ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}          MRBTS-1
${VLANIF_DISTNAME}         ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${NG_LINK_RESET}           Received NG Reset
${X2AP_FILTER}             x2ap.X2AP_PDU == 1
${RES_C24}                 0
${AP_CONFIG_BASIC}         ${CURDIR}/../../config/wts


*** Keywords ***
Prepare For CB008233
    [Documentation]    Prepare For CB008233
    ${Log_Path}    Create Log Directory    CB008233
    Link SCOUT SCF To Configuration ID For Reporting
    Log To Console    \nlog path created ${Log_Path}
    Adding Required Ips For The TestCase 8233
    IF   '${STREAM_NR}' == 'SBTS00'
         GNB Delta Commission    ${DELTACONFIGDIR}/CB008233_Delta_config.json
    ELSE
         GNB Delta Commission    ${DELTACONFIGDIR}/CB008233_Delta_config_old.json
    END
    Wait Coam Site To Be Ready
    Start UTE WTS     CB008233_wts.cfg
    Basic Bring Up

Get Current Time As HHMM
    [Documentation]     This keyword is used to create variable base on timein hour and min in HHMM format
    ${time}     Get Time    result_format=%H%M
    ${hh}       Get Substring       ${time}   11  13
    ${mm}       Get Substring       ${time}   14  16
    ${hhmm}     Set Variable        ${hh}${mm}
    [Return]    ${hhmm}

Prepare For CB008233 TMO
    [Documentation]    Prepare For CB008233 C24
    ${hhmm}     Get Current Time As HHMM
    ${Log_Path}    Create Log Directory    CB008233
    Link SCOUT SCF To Configuration ID For Reporting
    Log To Console    \nlog path created ${Log_Path}
    Adding Required Ips For The TestCase 8233
    IF   '${STREAM_NR}' == 'SBTS25R2'
         GNB Delta Commission    ${DELTACONFIGDIR}/8233_c24_branch.json
    ELSE
         GNB Delta Commission    ${DELTACONFIGDIR}/8233_c24.json
    END
    Wait Coam Site To Be Ready
    Start UTE WTS     CB008233_C24.cfg
    Basic Bring Up

Teardown For CB008233 TMO
    slog.Stop Syslog
    Collect Logs For The Test                   ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB008233.zip ${LOG_PATH}
    GNB Delta Commission        ${DELTACONFIGDIR}/Reverse_Delta_CB008233_TMO.json
    Sleep   30s
    RAT Block Unblock

Common Tear Down For CB008233 MPLOTDD
    [Documentation]    Common Tear Down For CB008233 MP_AP_LO_TDD
    slog.Stop Syslog
    Collect Logs For The Test                   ${Log_Path}
    GNB Delta Commission        ${DELTACONFIGDIR}/Reverse_Delta_CB008233.json
    RAT Block Unblock
    Wait Coam Site To Be Ready

NSA UE Attach To Gnb
    [Documentation]    NSA UE Attach To Gnb
    [Arguments]        ${NSA_UE_ID}=${NSA_UE_ID}        ${Target_Cells}=1       ${sgw_id}=1
    wtsrunner.Ue Mme Param      id=${NSA_UE_ID}       sgw_id=${sgw_id}
    LTE Attach Should Be Successful For NSA        ${NSA_UE_ID}
    UE Attach Should Be Successful For NSA         ${NSA_UE_ID}         ${Target_Cells}

NSA UE Detach To Gnb
    [Documentation]    NSA UE Detach To Gnb
    [Arguments]        ${NSA_UE_ID}=${NSA_UE_ID}
    UE 5GDetach Should Be Successful For NSA    ${NSA_UE_ID}
    UE Detach Should Be Successful For NSA      ${NSA_UE_ID}

X2 Link Reset
    [Documentation]    X2 Link Reset
    [Arguments]        ${from}=1        ${to}=2
    wtsrunner.Link X2 Reset             from_id=${from}    to=${to}
    Log To Console    X2 link rest is done

Break X2 GTP-U Path CB008233
    [Documentation]    Command to trigger break X2 GTP-U path CB008233 for Feature CB008233
    [Arguments]        ${enb}=1         ${skip_echo_req}=10.0.1.135,10.0.1.2,10
    wtsrunner.Enb Trigger     enb=${enb}     skip_echo_req=${skip_echo_req}
    Sleep   60s
    Log To Console    X2 GTP-U Path has break done...
    admin.Setup Admin
    ${alarms}      admin.Get Alarms
    [Return]       ${alarms}
    [Teardown]     admin.Teardown Admin

Skip Echo Message From Gnb To Sgw
    [Documentation]    Skip Echo Message From Gnb To Sgw
    [Arguments]        ${id}=1        ${skip_echo_req}=10.0.1.1,10.0.1.3,10
    wtsrunner.Upf Param            id=${id}    skip_echo_req=${skip_echo_req}
    Log To Console    skip message from gnb to sgw
    Sleep   90s
    admin.Setup Admin
    ${alarms}      admin.Get Alarms
    [Return]       ${alarms}
    [Teardown]     admin.Teardown Admin

Skip Echo Message From SGW Trigger
    [Documentation]    Skip Echo Message From SGW Trigger and capture alarms...
    [Arguments]        ${id}=1        ${skip_echo_req}=10.0.1.133,10.0.1.3,10
    wtsrunner.SGW Trigger            id=${id}    skip_echo_req=${skip_echo_req}
    wtsrunner.SGW Trigger            id=${id}    skip_echo_req=10.0.1.133,10.0.1.2,10
    Log To Console    skip Echo message from SGW Trigger
    Sleep   60s
    admin.Setup Admin
    ${alarms}      admin.Get Alarms
    [Return]       ${alarms}
    [Teardown]     admin.Teardown Admin

Verifying The PM Counter For 8233A
    [Documentation]    Verifying The PM Counter For 8233A
    [Arguments]         ${peak}=0           ${denom}=300
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55121C00016    ${peak}        PEAK_NUM_SUPERVISED_GTP_U_PATH
    ...     M55121C00017    ${denom}     DENOM_1_SEC_SAMPLE
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...     file_path=${pm_counter_file}

Updating Localipaddress
    [Documentation]    Updating Local ip address
    admin.Setup Admin
    Online NIDD Parameter Change    paramName=localIpAddr            paramValue=10.0.1.5
    ...                             paramDst=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
    [Teardown]      admin.Teardown Admin

Get Alarm By Details
    [Documentation]    Getting Alarm details of GNB
    [Arguments]  ${additional_fault_id}  ${alarm_detail}  ${fault_description}  ${alarms}
    ${res_C24}     Set Variable    0
    FOR  ${alarm}  IN  @{alarms}
        ${current_alarm_info}              Get From Dictionary  ${alarm}                      alarmInformation
        ${current_additional_info}         Get From Dictionary  ${current_alarm_info}         alarmAdditionalInfo
        ${current_additional_fault_id}     Get From Dictionary  ${current_additional_info}    additionalFaultID
        ${current_alarm_detail}            Get From Dictionary  ${current_alarm_info}         alarmDetail
        ${current_fault_description}       Get From Dictionary  ${current_alarm_info}         faultDescription
        ${con1}       Evaluate       '${current_additional_fault_id}' == '${additional_fault_id}'
        ${con2}       Evaluate       '${current_alarm_detail}' == '${alarm_detail}'
        ${con3}       Evaluate       '${current_fault_description}' == '${fault_description}'
        Run Keyword If  ${con1} and ${con2} and ${con3}  Set Test Variable    ${res_C24}    1
        Run Keyword If  ${con1} and ${con2} and ${con3}  Exit For Loop
    END
    Should Be Equal     ${res_C24}       1
    [Return]            ${res_C24}


Stop Pcap Collection In GNB CU
    [Documentation]    This keyword is to stop PCAP logs from gnB
    ...     [arguments]    name     : This is file name where pcap logs will be collected, default name is gnbTcpdump
    ...                    Log_path : Path where pcap log file will be stored, default path is Log_Path
    ...     [return]    pcap_file   : pcap file path captured on wts
    ...     [usage]     Stop pcap collection in gNB
    ...                 Stop pcap collection in gNB     name=PCAPLOG    Log_Path= dir/dir/filename
    ...                 Stop pcap collection in gNB     gnbTcpdump1     dir/dir/filename
    [Arguments]                     ${name}=gnbTcpdump                  ${Log_Path}=${Log_Path}
    core.Stop Collectors            names=${name}
    core.Collect Collectors         names=${name}       target_dir=${Log_Path}
    core.Teardown Collectors        names=${name}
    ${pcap_file}    Join Path       ${Log_Path}         ${name}         ${name}.pcap
    Log To Console                  pcap capture is stopped
    [Return]                        ${pcap_file}

Get Transport Id From Pcap
    [Documentation]    Get Transport Id From Pcap for given filter and field name
    [Arguments]        ${PcapFile}              ${Filter}      ${FieldName}=e1ap.transport
    ${TransportId}     Get Fields From Pcap     ${PcapFile}    ${Filter}        ${FieldName}
    Log To Console     ${TransportId}
    Run Keyword And Ignore Error     Should Be Equal    ${TransportId}    1

Check ENDCPartialResetConfirm Message From Pcap
    [Documentation]    Finding ENDCPartialResetConfirm message from pcap when breaking GTP-U Tunner
    ...         filter - x2ap.procedureCode == 40   field = x2ap.X2AP_PDU
    ...         It Should return 40 for succesful else Fail
    [Arguments]    ${pcap_file}      ${filter}=${X2AP_FILTER}       ${field}=x2ap.procedureCode
    ${X2AP_PDU}     Get Fields from Pcap       ${pcap_file}        ${filter}        ${field}
    Should Contain      ${X2AP_PDU}     40

Adding Required Ips For The TestCase 8233
    [Documentation]    The required IPs for the test has been added with this Keyword.
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.139/24 dev eth3
    Run    sudo ip addr add 10.0.1.140/24 dev eth3
    Run    sudo ip addr add 10.0.1.161/24 dev eth3
    Run    sudo ip addr add 10.0.1.162/24 dev eth3
    Run    sudo ip addr add 10.0.1.163/24 dev eth3
    Run    sudo ip addr add 10.0.1.164/24 dev eth3
    Run    sudo ip addr add 10.0.1.165/24 dev eth3
    Run    sudo ip addr add 10.0.1.166/24 dev eth3
    Run    sudo ip addr add 10.0.1.167/24 dev eth3
    Run    sudo ip addr add 10.0.1.168/24 dev eth3
    Run    sudo ip addr add 10.0.1.169/24 dev eth3
    Run    sudo ip addr add 10.0.1.170/24 dev eth3
    Run    sudo ip addr add 10.0.1.4/24 dev eth3
    Run    sudo ip addr add 10.0.1.5/24 dev eth3
