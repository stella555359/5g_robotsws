*** Settings ***
Documentation
...   Author: Xiang Liang
...   Contact: liang.xiang@nokia-sbell.com
...   Description: This case describes the support of the activation and deactivation of PRACH format B4 per cell,
...                and the support of both starting symbol 0 and 2
...    Deprecated case removed by civen.chen
#
#Suite Setup       Common Suite Setup For AIC
#Suite Teardown    Common Suite Teardown For AIC
#Test Setup        Common Test Setup For AIC
##Test Teardown     Common Test Teardown For AIC
#
#Force Tags
#...                CA_RAN_PZ_HAZ_1
#...                RAN_PZ_HAZ1_SG02_ST_RRM
#...                TA_LEVEL_22
#...                CRT
#...                TRUNK
#
#Library     String
#Library     taf.transport.ssh                WITH NAME    ssh
#Library     taf.ue.pioneer.client            WITH NAME    client
#Library     taf.ue.pioneer.api               WITH NAME    api
#
#Test Timeout    50 minutes
#
#Resource    ../../Resources/Cloud/AIC_Common_Resource.robot
#
#
#
#*** Test Cases ***
#[1]5GC001304_Activation_and_deactivation_of_Random_access_procedure_with_PRACH_format_B4
#    [Tags]    QC_244938       QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: liang.xiang@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    25.11.2021,liang.xiang@nokia-sbell.com
#    Set The Value of PrachConfigurationIndex To 159
#    Start Wireshark Log In vDU
##    Prepare UE0
##    Attach UE0
##    Start DL Call For UE0
##    Start UL Call For UE0
##    sleep    30
#    pioneer multi-UE L3 call
#    Check DL Tput By K8s Log
#    Check UL Tput By K8s Log
#    Stop Wireshark Log And Check Prachindex 159
##    Detach UE0
##    Set the value of prachConfigurationIndex to 89
##    Start Wireshark Log In vDU
##    Stop Wireshark Log And Check Prachindex 89
#
#
#[1]CB007802_CB006429_5G_A_11_Data transfer over DRB with AES Ciphering NEA2_NIA2
#    [Tags]    QC_326442       QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: tracy.zheng@nokia-sbell.com
#    ...    history change: 19/05/2022,ZHENG TRACY,initial version
#    ...    19.5.2022,tracy.zheng@nokia-sbell.com
##    Prepare UE0
#    Start Wireshark Log In vCU
#    pioneer multi-UE L3 call
##    Attach UE0
##    Start DL Call For UE0     throughput=10M    duration=10
#    Stop Wireshark Log And Check CiPHER
##    Stop call
##    Detach UE0
#
#
#[1]CB007802_5GC000884_A_C_PUSCH_SRS_Feature_activation_deactivation
#    [Tags]    QC_326411       QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: rong.nie@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    23.03.2022,rong.nie@nokia-sbell.com
#    Check both vDU and vCU cells should be onair
##    Prepare UE0
##    Attach UE0 And Start UL TPUT
#    pioneer multi-UE L3 call
#    Check UL Tput By K8s Log
##    Stop UL THPUT And Detach UE0
#    Set The Value of actUlClosedLoopPwrCtrl is pucchPuschSrs
#    pioneer multi-UE L3 call
##    Attach UE0 And Start UL TPUT
#    Check UL Tput By K8s Log
##    Stop UL THPUT And Detach UE0
#    Set The Value of actUlClosedLoopPwrCtrl is disabled
#    pioneer multi-UE L3 call
##    Attach UE0 And Start UL TPUT
#    Check UL Tput By K8s Log
##    Stop UL THPUT And Detach UE0
#
#
#[1]CB007802_5GC000884_B_C_PUCCH_Feature_activation_deactivation
#    [Tags]    QC_326412       QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: rong.nie@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    23.03.2022,rong.nie@nokia-sbell.com
#    Check both vDU and vCU cells should be onair
#    Set The Value of actUlClosedLoopPwrCtrl is pucch
##    Prepare UE0
##    Attach UE0 And Start UL TPUT
#    pioneer multi-UE L3 call
#    Check UL Tput By K8s Log
##    Stop UL THPUT And Detach UE0
#    Set The Value of actUlClosedLoopPwrCtrl is pucchPuschSrs
##    Attach UE0 And Start UL TPUT
#    pioneer multi-UE L3 call
#    Check UL Tput By K8s Log
##    Stop UL THPUT And Detach UE0
#    Set The Value of actUlClosedLoopPwrCtrl is disabled
#    pioneer multi-UE L3 call
##    Attach UE0 And Start UL TPUT
#    Check UL Tput By K8s Log
##    Stop UL THPUT And Detach UE0
#
#[1]CB007802_UL_Peak_TPUT_with_multi_features_on
#    [Tags]    QC_275166       QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: rong.nie@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    23.03.2022,rong.nie@nokia-sbell.com
#    Check both vDU and vCU cells should be onair
#    Set The Value of actUlClosedLoopPwrCtrl is pucch
#    pioneer multi-UE L3 call
##    Prepare UE0
##    Attach UE0 And Start UL TPUT
#    Check UL Tput By K8s Log
##    Stop UL THPUT And Detach UE0
#
#*** Keywords ***
#pioneer multi-UE L3 call
#   @{UEs_info}=    Detect UE and get UEs info    10.97.83.70    root    123456    pioneer    30999
#   FOR    ${index}    IN    @{UEs_info}
#        &{ue_upd_info_dict}    Attach UEs    ${index}[imsi]    stdata1
#        ${ue_ip}    Set Variable    &{ue_upd_info_dict}[Param]
#        ${ip}    Set Variable     ${ue_ip}[IP]
#        Should Not Be Empty    ${ip}
#        Log    ${ip}
#        Log To Console    \n*** make call with ${index} ***
#        Run keyword and continue on failure    Start FtpDL With Pioneer
#            ...                                    ${index}[imsi]
#        sleep    2s
#        Log To Console    \n*** make call with ${index} ***
#        Run keyword and continue on failure    Start FtpUL With pioneer
#            ...                                    ${index}[imsi]
#        sleep    2s
#   END
#
#Set The Value of PrachConfigurationIndex to ${value}
#   ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#   &{parameter_dict_new}    Create Dictionary   prachConfigurationIndex=${value}
#   &{parameter_dict}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
#   ...                                                                      mo_parameter_dict=&{parameter_dict_new}
#   vDU Login By Rest
#   Run Keyword If  &{parameter_dict} != &{Empty}    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
#    ...                                          updated_paras_list=${parameter_dict_new}
#	...                                          operation=replace
#	...                                          activate=${True}
#    ...                                          force_reset=${False}
#    ...                                          auto_lock_cells=${True}
#    ...                                          wait_vdu_up=${False}
#    vDU Logout By Rest
#
#Prepare UE0
#    ${ue0_type}    translate_power_ue_type_from_testline    ue_index=${0}
#	Set Test Variable    ${ue0_type}
#	Log to Console    \n***Prepare UE***
#    Prepare UE    ${ue0_type}    ue_index=${0}    ui_version=MATE40PROUI1.0
#
#Stop Wireshark Log And Check prachindex ${value}
#    ${wireshark_local_file_path}    Stop Wireshark Log And Download To K8s Master In vDU   gnb_index=${0}
#    ...                                                                    vdu_index=${0}
#    ...                                                                    container_name=nwmgmt
#    ...                                                                    pod_name=cprt
#    ...                                                                    timeout=${10}
#    ...                                                                    log_name=prach_${value}
#    ${_filter} =    catenate    nr-rrc.prach_ConfigurationIndex == ${value}
#    ${result} =    Analysis Wireshark Log    input_file=${wireshark_local_file_path}
#	...                                      filter_expression=${_filter}
#	should contain    ${result}    RRC Setup Request
#    should contain    ${result}    UEContextModificationResponse
#    ${measgap_filter} =    catenate    nr-rrc.c1 == 2
#    ${result2} =    Analysis Wireshark Log    input_file=${wireshark_local_file_path}
#	...                                        filter_expression=${measgap_filter}
#
#
#Start Collect Wireshark Log In vDU
#    [Arguments]    ${container_name}=cprt    ${pod_name}=cprt
#    Log To Console    ${container_name}
#    Log To Console    ${pod_name}
#    Start Wireshark Log In vDU   gnb_index=${0}
#    ...                          vdu_index=${0}
#    ...                          container_name=cprt
#    ...                          pod_name=cprt
#    ...                          timeout=${10}
#    ...                          protocol=sctp
#    ...                          interface=any
#
#Check DL Tput By K8s Log
#    ${dl_l2rt_tput_local_file_path}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}
#    ...                                      container_name=l2rt    pod_name=up   timeout=${10}
#    Set Test Variable    ${dl_l2rt_tput_local_file_path}
#    ${ave_dl_tput}    ${max_dl_tput}    ${min_dl_tput}    k8s.get_dl_tput_from_k8s_log    ${dl_l2rt_tput_local_file_path}
#    should be true  ${max_dl_tput}>0
#
#Check UL Tput By K8s Log
#    ${ul_l2rt_tput_local_file_path}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}
#    ...                                                     container_name=l2rt    pod_name=up   timeout=${10}
#    Set Test Variable    ${ul_l2rt_tput_local_file_path}
#    ${ave_ul_tput}    ${max_ul_tput}    ${min_ul_tput}    k8s.get_ul_tput_from_k8s_log    ${ul_l2rt_tput_local_file_path}
#    should be true  ${max_ul_tput}>0
#
#Attach UE0
#    Log to Console    \n***UE Attach***
#    UE Attach    ${ue0_type}    ue_index=${0}    verify_attach=True
#
#Start DL Call For UE0
#    [Arguments]    ${throughput}=800M    ${duration}=${6000}
#    Log To Console    \nStart the DL TPUT
#    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=dl    dt_index=${0}
#	...              throughput=${throughput}    duration=${duration}
#
#Start UL Call For UE0
#    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=ul    dt_index=${0}
#	...              throughput=500M    duration=${600}
#
#Set The Value of actUlClosedLoopPwrCtrl is ${value}
#   ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#   &{parameter_dict_new}    Create Dictionary   actUlClosedLoopPwrCtrl=${value}
#   &{parameter_dict}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
#   ...                                                                      mo_parameter_dict=&{parameter_dict_new}
#   vDU Login By Rest
#   Run Keyword If  &{parameter_dict} != &{Empty}    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
#    ...                                          updated_paras_list=${parameter_dict_new}
#    ...                                          operation=replace
#    ...                                          activate=${True}
#    ...                                          force_reset=${False}
#    ...                                          auto_lock_cells=${True}
#    ...                                          wait_vdu_up=${False}
#    [Teardown]   vDU Logout By Rest
#
#Attach UE0 And Start UL TPUT
#    Log To Console    Attach UE0 And Start UL TPUT
#    Attach UE0
#    sleep    60s
#    Start UL TPUT for UE0
#    sleep    10s
#
#Stop UL THPUT And Detach UE0
#    log to console    Stop UL THPUT And Detach UE0
#    Stop UL THPUT for UE0
#    Detach UE0
#
#Check both vDU and vCU cells should be onair
#    Log To Console    \n*** check on air state in cu ***
#    wait until keyword succeeds    900    20
#    ...        Check All Cells On Air In vCU
#    Log To Console    \n*** check on air state in du ***
#    wait until keyword succeeds    900    20
#    ...        vDU Check All Cells Status Should Be Onair
#
#Stop UL THPUT for UE0
#    log to console    Stop UL THPUT for UE0
#    Stop traffic    ${ue0_type}    ue_index=${0}    direction=ul
#
#Start UL TPUT for UE0
#    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=ul    dt_index=${0}
#    ...              throughput=100M    duration=${300}
#
#Detach UE0
#    Log to Console    \n***UE Detach***
#    UE Detach    ${ue0_type}    ue_index=${0}
#
#Stop Wireshark Log And Check CiPHER
#    ${wireshark_local_file_path}    Stop Wireshark Log And Download To K8s Master In vCU   gnb_index=${0}
#    ...                                                                    container_name=nwmgmt
#    ...                                                                    pod_name=cpif
#    ...                                                                    timeout=${10}
#    ...                                                                    log_name=5QI
#    ${cipher_filter} =    catenate    nr-rrc.cipheringAlgorithm == 2
#    ${integrity_filter} =    catenate    nr-rrc.integrityProtAlgorithm == 2
#    ${result} =    Analysis Wireshark Log    input_file=${wireshark_local_file_path}
#	...                                      filter_expression=${cipher_filter}
#	${result} =    Analysis Wireshark Log    input_file=${wireshark_local_file_path}
#	...                                      filter_expression=${integrity_filter}
#
#Stop call
#    Stop traffic    ue_type=${ue0_type}       direction=dl
#    UE Detach    ${ue0_type}    ue_index=${0}
#
#Detect UE and get UEs info
#    [Arguments]    ${host}    ${username}    ${password}    ${alias}    ${port}
#    [Documentation]    Prepare UE resource.
#    client.setup_service
#    ...    host=${host}    port=${port}    ssh_username=${username}
#    ...    ssh_password=${password}    alias=${alias}
#    @{UEs_info}    client.prepare_ues    service=${alias}
#    [Return]    @{UEs_info}
#
#Attach UEs
#    [Arguments]    ${imsi}   ${apn}
#    [Documentation]    Prepare UE resource.
#    client.require_ue    imsi=${imsi}    service=pioneer    ue_alias=mate20x
#    sleep    2s
#    client.poweroff     ue=mate20x
#    sleep    2s
#    client.poweron     ue=mate20x
#    sleep    10s
#    &{ue_upd_info_dict}    client.getpduinfo   apn=${apn}    ue=mate20x
#    [return]    &{ue_upd_info_dict}
#
##Start ul traffic in x62 module
##    [Arguments]    ${protocol}=UDP    ${address}=10.69.9.10    ${port}=5001    ${testtime}=20
##        ...    ${bandwidth}=10000    ${buffersize}=1024    ${packetsize}=1400
##    client.startultraffic
##    ...    protocol=${protocol}
##    ...    address=${address}
##    ...    port=${port}
##    ...    testtime=${testtime}
##    ...    bandwidth=${bandwidth}
##    ...    buffersize=${buffersize}
##    ...    packetsize=${packetsize}
##    ...    ue=mate20x
#
#Get pdu info
#    [Arguments]    ${apn}
#    [Documentation]    Prepare UE resource.
#    &{upd_infos}    client.getpduinfo   apn=${apn}
#    [return]    &{upd_infos}
#
#
#
#Start FtpUL With pioneer
#    [Arguments]      ${imsi}
#    Run keyword and continue on failure    UE Attach For FtpUL Action    ${imsi}
#    ...                                                                  stdata1
#
#
#Get UL Throughput Info
#    FOR    ${index}    IN RANGE    0    3
#        ${ul_throughput_dict}=      client.getparammac    ue=mate20x
#        Exit For Loop If    ${ul_throughput_dict}[Param][MACUL] > 2000000
#        sleep    2s
#    END
#
#Start FtpDL With Pioneer
#    [Arguments]      ${imsi}
#    Run keyword and continue on failure    UE Attach For FtpDL Action    ${imsi}
#    ...                                                                  stdata1
#
#UE Attach For FtpUL Action
#    [Arguments]        ${imsi}    ${apn}
#    [Documentation]    Ue attach and do traffic for call action.
#    FOR    ${index}    IN RANGE      0    2
#        wait until keyword succeeds  10s  5s    client.require_ue
#        ...      imsi=${imsi}    service=pioneer      ue_alias=mate20x
#        sleep    1s
#        wait until keyword succeeds  10s  5s    client.poweroff     until_timeout=180    ue=mate20x
#
#        sleep    2s
#        wait until keyword succeeds  10s  5s    client.poweron      until_timeout=180    ue=mate20x
#        sleep    15s
#        ${upd_info}    Run keyword and continue on failure    client.getpduinfo    until_timeout=120
#        ...                                                                        apn=${apn}     ue=mate20x
#        Exit For Loop If    ${upd_info}[Param][State]==0
#    END
#    Run keyword and continue on failure    Start FTP UL traffic     ue=mate20x
#    sleep    30s
#    Run Keyword And Ignore Error    Get UL Throughput Info
#    Run Keyword And Ignore Error    client.stop_test     ue=mate20x
#
#
#UE Attach For FtpDL Action
#    [Arguments]        ${imsi}    ${apn}
#    [Documentation]    Ue attach and do traffic for call action.
#    FOR    ${index}    IN RANGE      0    2
#        wait until keyword succeeds  10s  5s    client.require_ue
#        ...      imsi=${imsi}    service=pioneer      ue_alias=mate20x
#        sleep    1s
#        wait until keyword succeeds  10s  5s    client.poweroff     until_timeout=180    ue=mate20x
#
#        sleep    2s
#        wait until keyword succeeds  10s  5s    client.poweron      until_timeout=180    ue=mate20x
#        sleep    15s
#        ${upd_info}    Run keyword and continue on failure    client.getpduinfo    until_timeout=120
#        ...                                                                        apn=${apn}     ue=mate20x
#        Exit For Loop If    ${upd_info}[Param][State]==0
#    END
#    Run keyword and continue on failure    Start FTP DL traffic
#    sleep    30s
#    Run Keyword And Ignore Error    Get DL Throughput Info
#    Run Keyword And Ignore Error    client.stop_test     ue=mate20x
#
#Start FTP DL traffic
#    [Arguments]               ${host}=10.69.9.10          ${port}=22
#    ...                       ${username}=ute            ${password}=ute
#    ...                       ${modetype}=1              ${savefile}=${True}
#    ...                       ${hostdir}=/home/ute/Downloads/Python.zip
#    ...                       ${localdir}=D:\\upload     ${duration}=300
#    ...                       ${threadcount}=30          ${ftptype}=SFTP
#    ...                       ${until_timeout}=30
#    client.startftpdl         host=${host}                 port=${port}
#    ...                       username=${username}         password=${password}
#    ...                       modetype=${modetype}         savefile=${savefile}
#    ...                       hostdir=${hostdir}
#    ...                       localdir=${localdir}
#    ...                       duration=${duration}
#    ...                       threadcount=${threadcount}
#    ...                       ftptype=${ftptype}
#    ...                       until_timeout=${until_timeout}
#    ...                       ue=mate20x
#
#
#Start FTP UL traffic
#    [Arguments]               ${ue}
#    client.startftpul          host=10.69.9.10        port=${22}
#    ...                        username=ute           password=ute
#    ...                        modetype=${1}          hostdir=/home/ute/upload/
#    ...                        size=${100000}         duration=${300}
#    ...                        threadcount=${30}      ftptype=SFTP
#    ...                        deletefile=${True}     until_timeout=30
#    ...                        ue=${ue}
#
#
#Get DL Throughput Info
#    FOR    ${index}    IN RANGE    0    3
#        ${dl_throughput_dict}=      client.getparammac    ue=mate20x
#        Exit For Loop If    ${dl_throughput_dict}[Param][MACDL] > 2000000
#        sleep    2s
#    END
