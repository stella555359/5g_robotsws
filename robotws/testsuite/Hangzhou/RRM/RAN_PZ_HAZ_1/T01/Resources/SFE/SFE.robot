*** Settings ***
Documentation
...               Author: chong.lin@nokia-sbell.com
...               Contact: chong.lin@nokia-sbell.com
...               Description: This robot cases is used for SFE stability test

#Suite Setup       Common Suite Setup For AIC
#Suite Teardown    Common Suite Teardown For AIC

Library           taf.ue.pioneer.client                 WITH NAME    client
Library           ../SFE/pioneer_extral.py
Library           pioneer_extral.Pioneer_DL_Traffic     WITH NAME    Pioneer_DL_Traffic
Resource          ../Case_Common_Resource.robot
Force Tags
...               CA_RAN_PZ_HAZ_1
...               RAN_PZ_HAZ1_SG01_ST_RRM
...               TA_LEVEL_22

Test Timeout    1600 minutes

*** Variables ***
${DEFAULT_SCF_PATH}    /home/ute/MN/UTE/robotws/commissionings/RRM/SRAN_5G/7_5_UTE5GAIC016T008
${timer}               86400

*** Test Cases ***
# Remove PM File In vCU And vDU
#     [Tags]    PM
#     Remove PM File    master_ip=10.110.11.180    username=core    password=system123
#     ...               namespace=cran16

TC_01_VRAN2.0_SFE_Stability_traffic_ongoing_without_OAM_operation
    log    keyword use only backup case
#    [Tags]     CRT    TC01
#    [Documentation]
#    ...       Author: chong.lin@nokia-sbell.com
#    ...       history change: <date>,<who>,<what and how>
#    ...       20.7.2022,chong.lin@nokia-sbell.com, draft
#    [Setup]    Case Precondition
##    Load SCF For Normal Test
##    ...       ${DEFAULT_SCF_PATH}/CU_SCF_0.250_intraho.xml
##    ...       ${DEFAULT_SCF_PATH}/vDU_SCF_0.300_intraho.xml
##    sleep     ${${timer}/48}
#    sleep     300s
#    Log To Console    Start call
#    Start Predefined Traffic Profiles For UEs Which Are Under NR Cell     sum_number=1
#    ...                                                                   call_duration=${${timer}/3}
#    sleep     5s
#    Log To Console    Start collect log
#    Collect And Check All Required
#    sleep     2s
#    Stop Different Call With Different UE    ue_list=${ue_list}
#    Stop All Test
#   [Teardown]    Case Postcondition
#
#TC_02_VRAN2.0_SFE_Stability_traffic_ongoing_with_service_not_impacted_OAM_operation
#    [Tags]    CRT    TC02
#    [Documentation]
#    ...       Author: chong.lin@nokia-sbell.com
#    ...       history change: <date>,<who>,<what and how>
#    ...       20.7.2022,chong.lin@nokia-sbell.com, draft
#    [Setup]      Case Precondition
##    Load SCF For Normal Test
##    ...       ${DEFAULT_SCF_PATH}/CU_SCF_0.250_intraho.xml
##    ...       ${DEFAULT_SCF_PATH}/vDU_SCF_0.300_intraho.xml
##    sleep     ${${timer}/48}
#    Log To Console    Start call
#    Start Predefined Traffic Profiles For UEs Which Are Under NR Cell     sum_number=1
#    ...                                                                   call_duration=60
#    sleep     ${${timer}/24}
#    Log To Console    Change parameter
#    Start OAM Operation For Both VCU And VDU Periodically
#    sleep     ${${timer}/12}
#    Log To Console    Start collect log
#    Wait For Greater Than 24 Hours And Then Collect and Check All Required Logs
#    sleep     5s
#    Log To Console    Stop test
#    Stop Different Call With Different UE    ue_list=${ue_list}
#    sleep     2s
#    Log To Console    Release pioneer
#    Stop All Test
#    [Teardown]    Case Postcondition
#
#
#TC_03_VRAN2.0_SFE_Stability_traffic_and_mobility_ongoing_with_service_impacted_OAM_operation
#    [Tags]        TC03
#    [Documentation]
#    ...       Author: chong.lin@nokia-sbell.com
#    ...       history change: <date>,<who>,<what and how>
#    ...       20.7.2022,chong.lin@nokia-sbell.com, draft
#    [Setup]    Case Precondition
#    Load SCF For Normal Test
#    ...       ${DEFAULT_SCF_PATH}/CU_SCF_0.250_intraho.xml
#    ...       ${DEFAULT_SCF_PATH}/vDU_SCF_0.300_intraho.xml
#    sleep     ${${timer}/48}
#    Log To Console    Start call first
#    Start Predefined Traffic Profiles For UEs Which Are Under NR Cell     sum_number=1
#    ...                                                                   call_duration=${${timer}/12}
#    sleep     2s
#    Log To Console    Stop test
#    Stop Different Call With Different UE    ue_list=${ue_list}
#    sleep     2s
#    Log To Console    Release pioneer
#    Stop All Test
#    Log To Console    OAM Operation first
#    Wait For 8 Hours And Start OAM Operation For Both VCU And VDU
#    sleep     ${${timer}/48}
#    Log To Console    Start call second
#    Start Predefined Traffic Profiles For UEs Which Are Under NR Cell     sum_number=1
#    ...                                                                   call_duration=${${timer}/12}
#    sleep     2s
#    Log To Console    Stop test
#    Stop Different Call With Different UE    ue_list=${ue_list}
#    sleep     2s
#    Log To Console    Release pioneer
#    Stop All Test
#    Log To Console    OAM Operation second
#    Wait For 8 Hours And Then Start OAM Operations Step By Step
#    sleep     ${${timer}/48}
#    Log To Console    Start call third
#    Start Predefined Traffic Profiles For UEs Which Are Under NR Cell     sum_number=1
#    ...                                                                   call_duration=${${timer}/12}
#    sleep     2s
#    Log To Console    Stop test
#    Stop Different Call With Different UE    ue_list=${ue_list}
#    sleep     2s
#    Log To Console    Release pioneer
#    Stop All Test
#    Log To Console    Collect log
#    Wait For 8 Hours And Then Collect and Check All Required Logs
#    [Teardown]    Case Postcondition
#
#TC_04_VRAN2.0_SFE_Stability_traffic_ongoing_with_Different_UE_Services
#    [Tags]    CRT    TC04
#    [Documentation]
#    ...       Author: chong.lin@nokia-sbell.com
#    ...       history change: <date>,<who>,<what and how>
#    ...       20.7.2022,chong.lin@nokia-sbell.com, draft
#    [Setup]       Case Precondition
#    Load SCF For Normal Test
#    ...       ${DEFAULT_SCF_PATH}/CU_SCF_0.250_intraho.xml
#    ...       ${DEFAULT_SCF_PATH}/vDU_SCF_0.300_intraho.xml
#    sleep     ${${timer}/48}
#    Log To Console    Start call
#    Start Predefined Traffic Profiles For UEs Which Are Under NR Cell1     sum_number=50
#    ...                                                                    call_duration=1
#    sleep     5s
#    Log To Console    Start collect log
#    Collect And Check All Required
#    sleep     2s
#    Log To Console    Release pioneer
#    sleep     2s
#    Stop All Test
#    [Teardown]    Case Postcondition
#
#TC_05_VRAN2.0_SFE_Stability_traffic_ongoing_with_intravDU_interFre_handover
#    [Tags]    CRT    TC05
#    [Documentation]
#    ...       Author: chong.lin@nokia-sbell.com
#    ...       history change: <date>,<who>,<what and how>
#    ...       20.7.2022,chong.lin@nokia-sbell.com, draft
#    [Setup]       Case Precondition
#    Load SCF For Intra vDU Inter Frequecy Handover Test
#    ...       ${DEFAULT_SCF_PATH}/CU_SCF_0.250_interfre_ho.xml
#    ...       ${DEFAULT_SCF_PATH}/vDU_SCF_0.300_interfre_ho.xml
#    sleep     ${${timer}/48}
#    Log To Console    Start call
#    Start Predefined Traffic Profiles For UEs Handover Which Are Under NR Cell    sum_number=1
#    ...                                                                           call_duration=60
#    sleep     30s
#    FOR    ${ho_num}    IN RANGE    0    20
#        Run Keyword And Continue On Failure    Adjust The Signal Via PA Trigger Handover
#        sleep    60s    reason=Wait for HO sucessful
#        Run Keyword And Continue On Failure    Recover The Signal Via PA Trigger Handover
#        sleep    60s    reason=Wait for HO sucessful
#    END
#    Log To Console    Start collect log
#    Collect And Check All Required
#    sleep     2s
#    Log To Console    Stop call
#    Stop Different Call With Different UE    ue_list=${ue_list}
#    sleep     2s
#    Log To Console    Release pioneer
#    Stop All Test
#    [Teardown]    Case Postcondition
#
#TC_06_VRAN2.0_SFE_Stability_traffic_ongoing_with_VONR Call
#    [Tags]    CRT    TC06
#    [Documentation]
#    ...       Author: chong.lin@nokia-sbell.com
#    ...       history change: <date>,<who>,<what and how>
#    ...       20.7.2022,chong.lin@nokia-sbell.com, draft
#    [Setup]       Case Precondition
#    Load SCF For VONR Call Test
#    ...       ${DEFAULT_SCF_PATH}/CU_SCF_0.250_vnor.xml
#    ...       ${DEFAULT_SCF_PATH}/vDU_SCF_0.300_vnor.xml
#    sleep     ${${timer}/48}
#    Log To Console    Start call
#    Start Predefined Traffic Profiles For VONR Call Which Are Under NR Cell    sum_number=1
#    ...                                                                        call_duration=30
#    sleep     5s
#    Log To Console    Start collect log
#    Collect And Check All Required
#    sleep     2s
#    Log To Console    Release pioneer
#    Stop All Test
#    [Teardown]    Case Postcondition
#
#TC_07_VRAN2.0_SFE_Stability_traffic_ongoing_with_2cc CA test
#    [Tags]    CRT    TC06
#    [Documentation]
#    ...       Author: chong.lin@nokia-sbell.com
#    ...       history change: <date>,<who>,<what and how>
#    ...       20.7.2022,chong.lin@nokia-sbell.com, draft
#    [Setup]       Case Precondition
#    Load SCF For 2CC CA test
#    ...       ${DEFAULT_SCF_PATH}/CU_SCF_0.250_ca.xml
#    ...       ${DEFAULT_SCF_PATH}/vDU_SCF_0.300_ca.xml
#    sleep     ${${timer}/48}
#    Log To Console    Start call
#    Start Predefined Traffic Profiles For CA Test Which Are Under NR Cell    sum_number=1
#    ...                                                                      call_duration=30
#    sleep     5s
#    Log To Console    Start collect log
#    Collect And Check All Required
#    sleep     2s
#    Log To Console    Release pioneer
#    Stop All Test
#    [Teardown]    Case Postcondition

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Run keyword and ignore error    Common Test Setup For AIC
    ${ip_list}   ${username_list}   ${password_list}   ${ns_list}    Get SSH Connection Infor For Multiple vCU K8s Master
    Set Test Variable    ${ip_list}
    Set Test Variable    ${username_list}
    Set Test Variable    ${password_list}
    Set Test Variable    ${ns_list}

Load SCF For Normal Test
    [Arguments]         ${default_vcu_scf_path}    ${default_vdu_scf_path}
    Load Default SCF    ${default_vcu_scf_path}    ${default_vdu_scf_path}

Load SCF For Intra vDU Inter Frequecy Handover Test
    [Arguments]         ${default_vcu_scf_path}    ${default_vdu_scf_path}
    Load Default SCF    ${default_vcu_scf_path}    ${default_vdu_scf_path}

Load SCF For VONR Test
    [Arguments]         ${default_vcu_scf_path}    ${default_vdu_scf_path}
    Load Default SCF    ${default_vcu_scf_path}    ${default_vdu_scf_path}

Load SCF For 2CC CA test
    [Arguments]         ${default_vcu_scf_path}    ${default_vdu_scf_path}
    Load Default SCF    ${default_vcu_scf_path}    ${default_vdu_scf_path}

Load SCF For VONR Call Test
    [Arguments]         ${default_vcu_scf_path}    ${default_vdu_scf_path}
    Load Default SCF    ${default_vcu_scf_path}    ${default_vdu_scf_path}

Stop All Test
    client.stoplog        service=pioneer
    client.release_ues    service=pioneer

Start Predefined Traffic Profiles For UEs Which Are Under NR Cell
    [Arguments]     ${sum_number}    ${call_duration}
    ${UEs_info}=    Detect UE number and get UEs info    10.97.97.142    root
    ...                                                  123456          pioneer    30999
    Start Predefined Traffic Profiles For All UEs Under NR Cells         UEs_info=${UEs_info}
    ...                                                                  sum_number=${sum_number}
    ...                                                                  call_duration=${call_duration}

Start Predefined Traffic Profiles For UEs Which Are Under NR Cell1
    [Arguments]     ${sum_number}    ${call_duration}
    ${UEs_info}=    Detect UE number and get UEs info    10.97.97.142    root
    ...                                                  123456          pioneer    30999
    Start Predefined Traffic Profiles For All UEs Under NR Cell1         UEs_info=${UEs_info}
    ...                                                                  sum_number=${sum_number}
    ...                                                                  call_duration=${call_duration}

Start Predefined Traffic Profiles For UEs Handover Which Are Under NR Cell
    [Arguments]     ${sum_number}    ${call_duration}
    ${UEs_info}=    Detect UE number and get UEs info    10.97.97.142    root
    ...                                                  123456          pioneer    30999
    Start Predefined Traffic Profiles For All UEs Under NR Cells For Handover     UEs_info=${UEs_info}
    ...                                                                           sum_number=${sum_number}
    ...                                                                           call_duration=${call_duration}

Start Predefined Traffic Profiles For VONR Call Which Are Under NR Cell
    [Arguments]     ${sum_number}    ${call_duration}
    ${UEs_info}=    Detect UE number and get UEs info    10.97.97.142    root
    ...                                                  123456          pioneer    30999
    Start Predefined Traffic Profiles For All UEs Under NR Cells For VONR Call    UEs_info=${UEs_info}
    ...                                                                           sum_number=${sum_number}
    ...                                                                           call_duration=${call_duration}

Start Predefined Traffic Profiles For CA Test Which Are Under NR Cell
    [Arguments]     ${sum_number}    ${call_duration}
    ${UEs_info}=    Detect UE number and get UEs info    10.97.97.142    root
    ...                                                  123456          pioneer    30999
    Start Predefined Traffic Profiles Under NR Cells For CA Test         UEs_info=${UEs_info}
    ...                                                                  sum_number=${sum_number}
    ...                                                                  call_duration=${call_duration}

Detect UE number and get UEs info
    [Arguments]    ${host}     ${username}    ${password}
    ...            ${alias}    ${port}
    [Documentation]    Prepare UE resource.
    client.setup_service    host=${host}    port=${port}    ssh_username=${username}
    ...                     ssh_password=${password}        alias=${alias}
    ${UEs_info}    client.prepare_ues    service=${alias}
    ${cnt}=    Get length    ${UEs_info}
    Should Be Equal          ${cnt}      ${7}
    sleep    1s
    client.remove_remote_files    folder_path=d:/pioneer_logs/    service=${alias}
    sleep    5s
    client.startlog    logpath=d:/pioneer_logs/    logname=ta_log    service=${alias}
    sleep    1s
    [Return]                 ${UEs_info}

UE Attach For Call Action
    [Arguments]        ${imsi}    ${apn}    ${iperf_port}
    [Documentation]    Ue attach and do traffic for call action.
    FOR    ${index}    IN RANGE      0    2
        wait until keyword succeeds  10s  5s    client.require_ue
        ...      imsi=${imsi}    service=pioneer      ue_alias=mate20x
        sleep    1s
        wait until keyword succeeds  10s  5s    client.poweroff     until_timeout=180    ue=mate20x

        sleep    2s
        wait until keyword succeeds  10s  5s    client.poweron      until_timeout=180    ue=mate20x
        sleep    15s
        ${upd_info}    Run keyword and continue on failure    client.getpduinfo    until_timeout=120
        ...                                                                        apn=${apn}     ue=mate20x
        Exit For Loop If    ${upd_info}[Param][State]==0
    END
    Run keyword and continue on failure    Start DL UDP Traffic
    ...                                    ${iperf_port}           ${upd_info}[Param][IP]
    Run keyword and continue on failure    Start UL UDP Traffic    ${iperf_port}

UE Attach For FtpDL Action
    [Arguments]        ${imsi}    ${apn}
    [Documentation]    Ue attach and do traffic for call action.
    FOR    ${index}    IN RANGE      0    2
        wait until keyword succeeds  10s  5s    client.require_ue
        ...      imsi=${imsi}    service=pioneer      ue_alias=mate20x
        sleep    1s
        wait until keyword succeeds  10s  5s    client.poweroff     until_timeout=180    ue=mate20x

        sleep    2s
        wait until keyword succeeds  10s  5s    client.poweron      until_timeout=180    ue=mate20x
        sleep    15s
        ${upd_info}    Run keyword and continue on failure    client.getpduinfo    until_timeout=120
        ...                                                                        apn=${apn}     ue=mate20x
        Exit For Loop If    ${upd_info}[Param][State]==0
    END
    Run keyword and continue on failure    Start FTP DL traffic
    sleep    30s
    Run Keyword And Ignore Error    Get DL Throughput Info
    Run Keyword And Ignore Error    client.stop_test     ue=mate20x

Get UL Throughput Info
    FOR    ${index}    IN RANGE    0    3
        ${ul_throughput_dict}=      client.getparammac    ue=mate20x
        Exit For Loop If    ${ul_throughput_dict}[Param][MACUL] > 2000000
        sleep    2s
    END

Get DL Throughput Info
    FOR    ${index}    IN RANGE    0    3
        ${dl_throughput_dict}=      client.getparammac    ue=mate20x
        Exit For Loop If    ${dl_throughput_dict}[Param][MACDL] > 2000000
        sleep    2s
    END

UE Attach For FtpUL Action
    [Arguments]        ${imsi}    ${apn}
    [Documentation]    Ue attach and do traffic for call action.
    FOR    ${index}    IN RANGE      0    2
        wait until keyword succeeds  10s  5s    client.require_ue
        ...      imsi=${imsi}    service=pioneer      ue_alias=mate20x
        sleep    1s
        wait until keyword succeeds  10s  5s    client.poweroff     until_timeout=180    ue=mate20x

        sleep    2s
        wait until keyword succeeds  10s  5s    client.poweron      until_timeout=180    ue=mate20x
        sleep    15s
        ${upd_info}    Run keyword and continue on failure    client.getpduinfo    until_timeout=120
        ...                                                                        apn=${apn}     ue=mate20x
        Exit For Loop If    ${upd_info}[Param][State]==0
    END
    Run keyword and continue on failure    Start FTP UL traffic     ue=mate20x
    sleep    30s
    Run Keyword And Ignore Error    Get UL Throughput Info
    Run Keyword And Ignore Error    client.stop_test     ue=mate20x

Start FTP DL traffic
    [Arguments]               ${host}=10.69.9.10         ${port}=22
    ...                       ${username}=ute            ${password}=ute
    ...                       ${modetype}=1              ${savefile}=${True}
    ...                       ${hostdir}=/home/ute/Downloads/Python.zip
    ...                       ${localdir}=D:\\upload     ${duration}=300
    ...                       ${threadcount}=30          ${ftptype}=SFTP
    ...                       ${until_timeout}=30
    client.startftpdl         host=${host}                 port=${port}
    ...                       username=${username}         password=${password}
    ...                       modetype=${modetype}         savefile=${savefile}
    ...                       hostdir=${hostdir}
    ...                       localdir=${localdir}
    ...                       duration=${duration}
    ...                       threadcount=${threadcount}
    ...                       ftptype=${ftptype}
    ...                       until_timeout=${until_timeout}
    ...                       ue=mate20x

Start FTP UL traffic
    [Arguments]               ${ue}
    client.startftpul          host=10.69.9.10        port=${22}
    ...                        username=ute           password=ute
    ...                        modetype=${1}          hostdir=/home/ute/upload/
    ...                        size=${100000}         duration=${300}
    ...                        threadcount=${30}      ftptype=SFTP
    ...                        deletefile=${True}     until_timeout=30
    ...                        ue=${ue}

UE Attach For Ping Action
    [Arguments]        ${imsi}    ${apn}
    [Documentation]    Ue attach and do traffic for call action.
    FOR    ${index}    IN RANGE      0    2
        wait until keyword succeeds  10s  5s    client.require_ue
        ...      imsi=${imsi}    service=pioneer      ue_alias=mate20x
        sleep    1s
        wait until keyword succeeds  10s  5s    client.poweroff      until_timeout=180    ue=mate20x

        sleep    2s
        wait until keyword succeeds  10s  5s    client.poweron       until_timeout=180    ue=mate20x
        sleep    15s
        ${upd_info}    Run keyword and continue on failure    client.getpduinfo    until_timeout=120
        ...                                                                        apn=${apn}     ue=mate20x
        Exit For Loop If    ${upd_info}[Param][State]==0
    END
    Run keyword and continue on failure    Start Ping     ue=mate20x
    sleep    5s
    Run Keyword And Ignore Error    client.stop_test      ue=mate20x

UE Attach For VONR Action
    [Arguments]        ${imsi}    ${apn}
    [Documentation]    Ue attach for VONR call action.
    FOR    ${index}    IN RANGE    0    1
        Run Keyword And Ignore Error    client.require_ue
        ...                    imsi=${imsi}        service=pioneer      ue_alias=mate20x
        sleep    1s
        ${poweroff_result}=    client.poweroff     until_timeout=180    ue=mate20x
        sleep    1s
        Exit For Loop If      ${poweroff_result}==None
        Exit For Loop If      '${poweroff_result}[Param][State]'=='-1'
        sleep    2s
        ${poweron_result}=    client.poweron       until_timeout=180    ue=mate20x
        sleep   1s
        Exit For Loop If      ${poweron_result}==None
        Exit For Loop If      '${poweron_result}[Param][State]'=='-1'
        sleep    15s
        ${upd_info}    Run keyword and continue on failure    client.getpduinfo    until_timeout=120
        ...                                                                        apn=${apn}     ue=mate20x
        Exit For Loop If    ${upd_info}==None
        Exit For Loop If    '${upd_info}[Param][State]'=='-1'
        Log    ${upd_info}[Param][IP]
#        dail number    006688
    END

Start Ping
    [Arguments]               ${ue}
    client.startping          host=10.69.9.10              packetsize=${50}
    ...                       livetime=${10}               timeout=${100}     atping=${False}
    ...                       until_timeout=10
    ...                       ue=${ue}

UEs Attach For DL Trafic
    [Arguments]        ${imsi}    ${apn}    ${iperf_port}
    [Documentation]    Ues attach and do traffic for handover.
    FOR    ${index}    IN RANGE    0    2
        wait until keyword succeeds  10s  5s     client.require_ue
        ...    imsi=${imsi}      service=pioneer      ue_alias=mate20x
        sleep    2s
        wait until keyword succeeds  10s  5s    client.poweroff     until_timeout=180    ue=mate20x
        sleep    2s
        wait until keyword succeeds  10s  5s    client.poweron      until_timeout=180    ue=mate20x
        sleep    15s
        ${upd_info}    Run Keyword And Continue On Failure    client.getpduinfo    until_timeout=120
        ...                                                   apn=${apn}     ue=mate20x
        Exit For Loop If    ${upd_info}[Param][State]==0
        sleep    1s
    END
        Run keyword and continue on failure     Start DL UDP Traffic
        ...                                     ${iperf_port}    ${upd_info}[Param][IP]

Case Postcondition
    log to console    Case Postcondition
    Run keyword and ignore error    Common Test Teardown For AIC

Start Predefined Traffic Profiles For All UEs Under NR Cells
    [Arguments]    ${UEs_info}       ${sum_number}      ${call_duration}
    ${ue_list}     Create List       ${UEs_info}[0]     ${UEs_info}[1]
    ...                              ${UEs_info}[2]     ${UEs_info}[3]
    ...                              ${UEs_info}[4]     ${UEs_info}[5]
    ...                              ${UEs_info}[6]
    Set Test Variable    ${ue_list}
    Make Different Call Greater Than N Hours With Different UE    sum_number=${sum_number}
    ...                                                           call_duration=${call_duration}

Start Predefined Traffic Profiles For All UEs Under NR Cell1
    [Arguments]    ${UEs_info}       ${sum_number}     ${call_duration}
    ${ue1_list}    Create List       ${UEs_info}[0]
    ${ue2_list}    Create List       ${UEs_info}[1]
    ${ue3_list}    Create List       ${UEs_info}[2]
    ${ue4_list}    Create List       ${UEs_info}[3]
    ${ue5_list}    Create List       ${UEs_info}[4]
    ...                              ${UEs_info}[5]
    ...                              ${UEs_info}[6]
    Set Test Variable    ${ue1_list}
    Set Test Variable    ${ue2_list}
    Set Test Variable    ${ue3_list}
    Set Test Variable    ${ue4_list}
    Set Test Variable    ${ue5_list}
    Make Different Call Greater Than N Hours With Different UEs    sum_number=${sum_number}
    ...                                                            call_duration=${call_duration}

Start Predefined Traffic Profiles For All UEs Under NR Cells For Handover
    [Arguments]    ${UEs_info}       ${sum_number}     ${call_duration}
    ${ue_list}     Create List       ${UEs_info}[0]    ${UEs_info}[1]
    ...                              ${UEs_info}[2]    ${UEs_info}[3]
    ...                              ${UEs_info}[4]    ${UEs_info}[5]
    ...                              ${UEs_info}[6]
    Set Test Variable    ${ue_list}
    Make Different Call Greater Than N Hours With Different UE For Handover    sum_number=${sum_number}
    ...                                                                        call_duration=${call_duration}

Make Different Call Greater Than N Hours With Different UE For Handover
    [Arguments]    ${sum_number}    ${call_duration}
    FOR    ${index}    IN RANGE     ${sum_number}
        Log to console    Loop count ${index}
        Make Call With Different UE For Handover    ue_list=${ue_list}    call_duration=${call_duration}
    END

Start Predefined Traffic Profiles For All UEs Under NR Cells For VONR Call
    [Arguments]    ${UEs_info}       ${sum_number}     ${call_duration}
    ${ue_list}     Create List       ${UEs_info}[0]    ${UEs_info}[1]
    ...                              ${UEs_info}[2]    ${UEs_info}[3]
    ...                              ${UEs_info}[4]    ${UEs_info}[5]
    ...                              ${UEs_info}[6]
    FOR    ${index}    IN RANGE     ${sum_number}
        Log to console    Loop count ${index}
        Make Call With Different UE For VONR Call    ue_list=${ue_list}    call_duration=${call_duration}
        Stop Call With Different UE For VONR Call    ue_list=${ue_list}
    END


Start Predefined Traffic Profiles Under NR Cells For CA Test
    [Arguments]    ${UEs_info}        ${sum_number}      ${call_duration}
    ${ue_list}     Create List        ${UEs_info}[0]     ${UEs_info}[1]
    ...                               ${UEs_info}[2]     ${UEs_info}[3]
    ...                               ${UEs_info}[4]     ${UEs_info}[5]
    ...                               ${UEs_info}[6]
    Set Test Variable    ${ue_list}
    Make Different Call Greater Than N Hours With Different UE For CA Test     sum_number=${sum_number}
    ...                                                                        call_duration=${call_duration}

Make Different Call Greater Than N Hours With Different UE For CA Test
    [Arguments]    ${sum_number}    ${call_duration}
    FOR    ${index}    IN RANGE     ${sum_number}
        Log to console    Loop count ${index}
        Make Call With Different UE For CA Test      ue_list=${ue_list}
        ...                                          call_duration=${call_duration}
        Stop Call With Different UE For CA Test      ue_list=${ue_list}
    END

Make Different Call Greater Than N Hours With Different UEs
    [Arguments]    ${sum_number}    ${call_duration}
    FOR    ${index}    IN RANGE     ${sum_number}
        Log to console    Loop count ${index}
        Make Different Call With Different UEs    ue1_list=${ue1_list}    ue2_list=${ue2_list}
        ...                                       ue3_list=${ue3_list}    ue4_list=${ue4_list}
        ...                                       ue5_list=${ue5_list}    call_duration=${call_duration}
        Stop Different Call With Different UEs
        ...                                      ue1_list=${ue1_list}
        ...                                      ue5_list=${ue5_list}
    END

Make Different Call Greater Than N Hours With Different UE
    [Arguments]    ${sum_number}    ${call_duration}
    FOR    ${index}    IN RANGE     ${sum_number}
        Log to console    Loop count ${index}
        Make Different Call With Different UE    ue_list=${ue_list}
        ...                                      call_duration=${call_duration}
    END

Make Different Call With Different UEs
    [Arguments]    ${ue1_list}    ${ue2_list}
    ...            ${ue3_list}    ${ue4_list}
    ...            ${ue5_list}    ${call_duration}
    FOR    ${ue_num}     IN       @{ue1_list}
        Log To Console    \n*** make call with ${ue_num} ***
        Run keyword and continue on failure    Start DL And UL Call With Pioneer
        ...     ${ue_num}[eqindex]     ${ue_num}[imsi]
    END
    sleep    2s
    FOR    ${ue_num}     IN    @{ue2_list}
        Log To Console    \n*** make call with ${ue_num} ***
        Run keyword and continue on failure    Start FtpDL With Pioneer
        ...                                    ${ue_num}[imsi]
    END
    sleep    2s
    FOR    ${ue_num}     IN    @{ue3_list}
        Log To Console    \n*** make call with ${ue_num} ***
        Run keyword and continue on failure    Start FtpUL With pioneer
        ...                                    ${ue_num}[imsi]
    END
    sleep    2s
    FOR    ${ue_num}     IN    @{ue4_list}
        Log To Console    \n*** make call with ${ue_num} ***
        Run keyword and continue on failure    Start Ping With pioneer
        ...                                    ${ue_num}[imsi]
    END
    sleep    2s
    FOR    ${ue_num}     IN     @{ue5_list}
        Log To Console    \n*** make call with ${ue_num} ***
        Run keyword and continue on failure    Start DL Call With Pioneer
        ...     ${ue_num}[eqindex]     ${ue_num}[imsi]
        sleep    2s
    END
    sleep    60s
    Run Keyword And Continue On Failure    Adjust The Signal Via PA Trigger Handover
    sleep    60s    reason=Wait for HO sucessful
    Run Keyword And Continue On Failure    Recover The Signal Via PA Trigger Handover
    sleep    ${call_duration}

Make Different Call With Different UE
    [Arguments]    ${ue_list}    ${call_duration}
    FOR    ${ue_num}    IN    @{ue_list}
        Log To Console    \n*** make call with ${ue_num} ***
        Run keyword and continue on failure    Start DL And UL Call With Pioneer
        ...     ${ue_num}[eqindex]     ${ue_num}[imsi]
        sleep    3s
    END
#    sleep    10s
#    FOR    ${ho_num}    IN RANGE    0    2
#        Run Keyword And Continue On Failure    Adjust The Signal Via PA Trigger Handover
#        sleep    60s    reason=Wait for HO sucessful
#        Run Keyword And Continue On Failure    Recover The Signal Via PA Trigger Handover
#        sleep    60s    reason=Wait for HO sucessful
#    END
    sleep    ${call_duration}

Make Call With Different UE For Handover
    [Arguments]    ${ue_list}    ${call_duration}
    FOR    ${ue_num}     IN       @{ue_list}
        Log To Console    \n*** make call with ${ue_num} ***
        Run keyword and continue on failure    Start DL And UL Call With Pioneer
        ...     ${ue_num}[eqindex]     ${ue_num}[imsi]
        sleep    2s
    END
    sleep    ${call_duration}

Make Call With Different UE For VONR Call
    [Arguments]    ${ue_list}    ${call_duration}
    FOR    ${ue_num}     IN       @{ue_list}
        Log To Console    \n*** make call with ${ue_num} ***
        Run keyword and continue on failure    Start VONR Call With Pioneer
        ...        ${ue_num}[imsi]
        sleep    2s
    END
    sleep    ${call_duration}

Make Call With Different UE For CA Test
    [Arguments]    ${ue_list}    ${call_duration}
    FOR    ${ue_num}     IN      @{ue_list}
        Log To Console    \n*** make call with ${ue_num} ***
        Run keyword and continue on failure    Start CA Test With Pioneer
        ...     ${ue_num}[eqindex]     ${ue_num}[imsi]
        sleep    2s
    END
    sleep    ${call_duration}

Stop Call With Different UE For CA Test
    [Arguments]     ${ue_list}
    FOR    ${ue_num}     IN    @{ue_list}
        Run Keyword And Continue On Failure    Stop Dl Call With Pioneer
        ...                                    ${ue_num}[imsi]    ${ue_num}[eqindex]
        sleep    2s
    END

Stop Different Call With Different UE
    [Arguments]    ${ue_list}
    FOR    ${ue_num}    IN    @{ue_list}
        Run Keyword And Continue On Failure    Stop Dl And UL Call With Pioneer
        ...                                    ${ue_num}[imsi]    ${ue_num}[eqindex]
        sleep    1s
    END

Stop Different Call With Different UEs
    [Arguments]     ${ue1_list}
    ...             ${ue5_list}
    FOR    ${ue_num}     IN    @{ue1_list}
        Run Keyword And Continue On Failure    Stop Dl And UL Call With Pioneer
        ...                                    ${ue_num}[imsi]    ${ue_num}[eqindex]
        sleep    1s
    END
    FOR    ${ue_num}     IN    @{ue5_list}
        Run Keyword And Continue On Failure    Stop Dl Call With Pioneer
        ...                                    ${ue_num}[imsi]    ${ue_num}[eqindex]
        sleep    1s
    END

Stop Call With Different UE For Handover
    [Arguments]     ${ue_list}
    FOR    ${ue_num}     IN    @{ue_list}
        Run Keyword And Continue On Failure    Stop Dl And UL Call With Pioneer
        ...                                    ${ue_num}[imsi]    ${ue_num}[eqindex]
        sleep    1s
    END

Start DL And UL Call With Pioneer
    [Arguments]      ${eqindex}       ${imsi}
    ${iperf_port}    Set Variable     ${${6600}+${eqindex}}
    Run keyword and continue on failure    UE Attach For Call Action
    ...                      ${imsi}    stdata1      ${iperf_port}

Start DL Call With Pioneer
    [Arguments]       ${eqindex}       ${imsi}
    ${iperf_port}    Set Variable      ${${6600}+${eqindex}}
    Run keyword and continue on failure    UEs Attach For DL Trafic
    ...     ${imsi}     stdata1       ${iperf_port}

Stop Dl And UL Call With Pioneer
    [Arguments]     ${imsi}    ${eqindex}
    client.require_ue       imsi=${imsi}
    ...                     service=pioneer
    ...                     ue_alias=mate20x
  	client.stopultraffic    ue=mate20x
    sleep    1s
	  ${ue_upd_info_dict}=    client.getpduinfo     until_timeout=120     apn=stdata1    ue=mate20x
    sleep    1s
    ${iperf_port}    Set Variable     ${${6600}+${eqindex}}
  	Pioneer_DL_Traffic.stop_dl_traffic    ${ue_upd_info_dict}[Param][IP]    ${iperf_port}
    sleep    1s

Stop Call With Different UE For VONR Call
    [Arguments]     ${ue_list}
    FOR    ${ue_num}     IN    @{ue_list}
        Run Keyword And Continue On Failure    Stop Dl Call With Pioneer
        ...                                    ${ue_num}[imsi]    ${ue_num}[eqindex]
        sleep    2s
    END

Start CA Test With Pioneer
    [Arguments]     ${eqindex}    ${imsi}
    Start DL Call With Pioneer    ${eqindex}    ${imsi}

Stop Dl Call With Pioneer
    [Arguments]     ${imsi}    ${eqindex}
    client.require_ue    imsi=${imsi}
    ...                  service=pioneer
    ...                  ue_alias=mate20x
	  ${ue_upd_info_dict}=    client.getpduinfo     until_timeout=120    apn=stdata1    ue=mate20x
    sleep    1s
    ${iperf_port}    Set Variable     ${${6600}+${eqindex}}
  	Pioneer_DL_Traffic.stop_dl_traffic    ${ue_upd_info_dict}[Param][IP]    ${iperf_port}
    sleep    1s

Start UL UDP Traffic
    [Arguments]    ${iperf_port}            ${protocol}=UDP
    ...            ${address}=10.69.9.10    ${port}=${${iperf_port}+1000}
    ...            ${testtime}=86400         ${bandwidth}=10000
    ...            ${buffersize}=1024       ${packetsize}=1400
    client.startultraffic    protocol=${protocol}        address=${address}
    ...                      port=${port}                testtime=${testtime}
    ...                      bandwidth=${bandwidth}      buffersize=${buffersize}
    ...                      packetsize=${packetsize}    ue=mate20x
    sleep    30s
    Run Keyword And Ignore Error    Get UL Throughput Info

Start DL UDP Traffic
    [Arguments]    ${port}    ${ueip}
    Pioneer_DL_Traffic.start_dl_traffic    ${ueip}     ${port}
    sleep    15s
    Run Keyword And Ignore Error    Get DL Throughput Info

Start FtpDL With Pioneer
    [Arguments]      ${imsi}
    Run keyword and continue on failure    UE Attach For FtpDL Action    ${imsi}
    ...                                                                  stdata1

Start FtpUL With pioneer
    [Arguments]      ${imsi}
    Run keyword and continue on failure    UE Attach For FtpUL Action    ${imsi}
    ...                                                                  stdata1

Start Ping With pioneer
    [Arguments]      ${imsi}
    Run keyword and continue on failure    UE Attach For Ping Action     ${imsi}
    ...                                                                  stdata1

Start VONR Call With Pioneer
    [Arguments]     ${imsi}
    Run keyword and continue on failure    UE Attach For VONR Action     ${imsi}
    ...                                                                  stdata1

Collect And Check All Required
    [Arguments]    ${vdu_index}=${0}    ${gnb_index}=${0}
    Run keyword and continue on failure   Check All Cells On Air In vCU
    Run keyword and continue on failure    vDU Check All Cells Status Should Be Onair For All DUs     gnb_index=${0}
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vdu_alarm_teardown    file_name=vdu_active_alarm.txt
    Run keyword and ignore error    Save vDU Active Alarm    file_name=${file}    vdu_index=${vdu_index}
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vdu_alarm_teardown    file_name=vdu_historical_alarm.txt
    Run keyword and ignore error    Save vDU Historical Alarm    file_name=${file}    vdu_index=${vdu_index}
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vcu_alarm_teardown    file_name=vcu_historical_alarm.txt
    Run keyword and ignore error    Get Active Alarm In vCU    file_name=${file}   gnb_index=${gnb_index}
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/vcu_alarm_teardown    file_name=vcu_historical_alarm.txt
    Run keyword and ignore error    Get Historical Alarm In VCU    file_name=${file}   gnb_index=${gnb_index}

Adjust The Signal Via PA Trigger Handover
    Log to console    Adjust The Signal Via PA Trigger Handover
    ${attenuation_channels}    Get Attenuation port    RU_id=1    du_id=0
    ${initial_att_values}      Get Initial Attenuation Values    RU_id=1    vendor=HBTE    du_id=0
    &{channels_to_modify}      create dictionary    ${attenuation_channels[0]}=25    ${attenuation_channels[1]}=25
    ...                                             ${attenuation_channels[2]}=25    ${attenuation_channels[3]}=25
    Modify Attenuation Value    ${channels_to_modify}    RU_id=1    du_id=0

Recover The Signal Via PA Trigger Handover
    Log to console    Adjust The Signal Via PA Trigger Handover
    ${attenuation_channels}     Get Attenuation port    RU_id=1    du_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=1    vendor=HBTE    du_id=0
    &{channels_to_modify}    create dictionary    ${attenuation_channels[0]}=55    ${attenuation_channels[1]}=55
    ...                                           ${attenuation_channels[2]}=55    ${attenuation_channels[3]}=55
    Modify Attenuation Value    ${channels_to_modify}    RU_id=1    du_id=0
    sleep    5s
    &{channels_to_modify}    create dictionary    ${attenuation_channels[0]}=63    ${attenuation_channels[1]}=63
    ...                                           ${attenuation_channels[2]}=63    ${attenuation_channels[3]}=63
    Modify Attenuation Value    ${channels_to_modify}    RU_id=1    du_id=0

Start OAM Operation For Both VCU And VDU Periodically
    FOR    ${index}    IN RANGE    0    5
        Run keyword and continue on failure    Start OAM Operation For Both VCU And VDU
        sleep    ${${timer}/24}
    END

Wait For Greater Than 24 Hours And Then Collect and Check All Required Logs
    Collect And Check All Required

Start OAM Operation For Both VCU And VDU
#    Run keyword and continue on failure    Save Local Snapshot In vDU    local_snapshot_location=vDU_snapshot
#    Run keyword and continue on failure    Save Local Snapshot In vCU    local_snapshot_location=vCU_snapshot
    # Run keyword and continue on failure    Start All Logs
    # Sleep    5s    reason=Wait for collect log
    # Run keyword and continue on failure    Stop All Logs
    FOR    ${index}    IN RANGE    0    1
        Run keyword and continue on failure    Feature Deactivation And Activation In vCU And vDU
    END
    FOR    ${index}    IN RANGE    0    1
        Run keyword and continue on failure    Online Parameter Change And Revert In vCU And vDU
    END

Start All Logs
    Start Wireshark Log In vCU
    Start Wireshark Log In vDU
    Start Bip Log
    Start TTI Log In vDU

Stop All Logs
    Stop TTI Log In vDU
    Stop Bip Log And Download To K8s Master
    Stop Wireshark Log In vCU
    Stop Wireshark Log In vDU
    Collect K8s Log With OAMconfig

Feature Deactivation And Activation In vCU And vDU
    Run keyword and continue on failure     Feature Deactivation In vCU And vDU
    Run keyword and continue on failure     Feature Activation In vCU And vDU

Feature Activation In vCU And vDU
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    &{vcu_actCDrxVoNR_param}    create dictionary    operation_type=replace    parameter_path=/actCDrxVoNR
    ...                                                                         value=true
    @{updated_actCDrxVoNR_vcu}    Create List    ${vcu_actCDrxVoNR_param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=actCDrxVoNR
    ...                                                   updated_paras_dict=${updated_actCDrxVoNR_vcu}
    ...                                                   compare_value=true
    ...                                                   mo_dn=${mo_dn}
    &{parameter_dict}    Create Dictionary   actCDrxVoNR=true
    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
    ...                                                                      mo_parameter_dict=&{parameter_dict}
    vDU Login By Rest
    Run Keyword If  &{parameter_dict1} != &{Empty}
    ...             VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
	  ...                                          updated_paras_list=${parameter_dict}
  	...                                          operation=replace
  	...                                          activate=${True}
    ...                                          force_reset=${False}
    ...                                          auto_lock_cells=${False}
    ...                                          wait_vdu_up=${False}
    vDU Logout By Rest

Feature Deactivation In vCU And vDU
    ${mo_dn}   Set Variable     MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    &{vcu_actCDrxVoNR_param}    create dictionary    operation_type=replace    parameter_path=/actCDrxVoNR
    ...                                                                         value=false
    @{updated_actCDrxVoNR_vcu}    Create List    ${vcu_actCDrxVoNR_param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=actCDrxVoNR
    ...                                                   updated_paras_dict=${updated_actCDrxVoNR_vcu}
    ...                                                   compare_value=false
    ...                                                   mo_dn=${mo_dn}
    &{parameter_dict}    Create Dictionary   actCDrxVoNR=false
    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
    ...                                                                      mo_parameter_dict=&{parameter_dict}
    vDU Login By Rest
    Run Keyword If  &{parameter_dict1} != &{Empty}
    ...             VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
  	...                                          updated_paras_list=${parameter_dict}
	  ...                                          operation=replace
  	...                                          activate=${True}
    ...                                          force_reset=${False}
    ...                                          auto_lock_cells=${False}
    ...                                          wait_vdu_up=${False}
    vDU Logout By Rest

Online Parameter Change And Revert In vCU And vDU
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1
    &{vcu_param}    create dictionary    operation_type=replace
    ...                                  parameter_path=/numOfDrbsReservForEmergency
    ...                                  value=5
    @{updated_vcu_param}    Create List    ${vcu_param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=numOfDrbsReservForEmergency
    ...                                                   updated_paras_dict=${updated_vcu_param}
    ...                                                   compare_value=5
    ...                                                   mo_dn=${mo_dn}
    &{parameter_dict}     Create Dictionary   numOfDrbsReservForEmergency=5
    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
    ...                   mo_parameter_dict=&{parameter_dict}
    vDU Login By Rest
    Run Keyword If  &{parameter_dict1} != &{Empty}
    ...             VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
  	...                                          updated_paras_list=${parameter_dict}
  	...                                          operation=replace
	  ...                                          activate=${True}
    ...                                          force_reset=${False}
    ...                                          auto_lock_cells=${False}
    ...                                          wait_vdu_up=${False}
    vDU Logout By Rest

Remove Xn Neighbor
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJGNB-2
    ${name}   Set Variable    NRADJGNB-2
    Login To vCU By Rest    gnb_index=${0}
    get_current_plan_tree_diff
    &{current_plan_tree}    cu.get_current_plan_tree_diff
    @{plan_tree}=    set variable    ${current_plan_tree["created"]}
    FOR    ${mo_info}    IN    @{plan_tree}
       run keyword if    '${mo_info["name"]}'=='${name}'    run keywords    set test variable    ${result}    true
       ...                                                  AND    exit for loop
    END
    Run Keyword If    '${result}'== 'true'    vCU Online Delete MO Via Rest    mo_dn=${mo_dn}
    ...                                                                        gnb_index=${0}
    [Teardown]   Run keyword and ignore error    Logout To vCU By Rest


Recover Xn Neighbor
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJGNB-2
    &{param1}    create dictionary    operation_type=replace    parameter_path=/administrativeState
    ...                                                                         value=Unlocked
    &{param2}    create dictionary    operation_type=replace    parameter_path=/gNbIdLength
    ...                                                                         value=22
    &{param3}    create dictionary    operation_type=replace    parameter_path=/gNodeBId
    ...                                                                         value=11078
    &{param4}    create dictionary    operation_type=replace    parameter_path=/gnbPlmn/mcc
    ...                                                                         value=262
    &{param5}    create dictionary    operation_type=replace    parameter_path=/gnbPlmn/mnc
    ...                                                                         value=3
    &{param6}    create dictionary    operation_type=replace    parameter_path=/gnbPlmn/mncLength
    ...                                                                         value=2
    @{updated_param}    Create List    ${param1}    ${param2}    ${param3}    ${param4}    ${param5}    ${param6}
    vCU Online Create MO With Modify Parameter Via Rest    para_list=${updated_param}
    ...                                                    name=com.nokia.srbts.nrbts:NRADJGNB
    ...                                                    instance_id=${2}
    ...                                                    gnb_index=${0}
    ...                                                    mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJGNB-2

Wait For 8 Hours And Start OAM Operation For Both VCU And VDU
    Feature Deactivation And Activation With Reset In vCU And vDU
    Lock Cell
    Unlock Cell


Wait For 8 Hours And Then Start OAM Operations Step By Step
    Run keyword and continue on failure    Reset vCU With Check Cell On Air    gnb_index=0
    Run keyword and continue on failure    Lock vDU
    Run keyword and continue on failure    Unlock vDU
    Run keyword and continue on failure    Lock RU
    Run keyword and continue on failure    Unlock RU
    # Run keyword and continue on failure    Lock NG-C Links
    # Run keyword and continue on failure    Unlock NG-C Links
    # Run keyword and continue on failure    Online Modify Xn To Locked
    # Run keyword and continue on failure    Online Modify Xn To Unlocked

Wait For 8 Hours And Then Collect and Check All Required Logs
    Run keyword and continue on failure    Collect And Check All Required

Feature Deactivation And Activation With Reset In vCU And vDU
    Run keyword and continue on failure    Feature Activation With Reset In vCU And vDU
    Run keyword and continue on failure    Feature Deactivation With Reset In vCU And vDU


Feature Activation With Reset In vCU And vDU
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    &{vcu_actCDrxVoNR_param}    create dictionary    operation_type=replace    parameter_path=/actCDrxVoNR
    ...                                                                         value=true
    @{updated_actCDrxVoNR_vcu}    Create List    ${vcu_actCDrxVoNR_param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=actCDrxVoNR
    ...                                                   updated_paras_dict=${updated_actCDrxVoNR_vcu}
    ...                                                   compare_value=true
    ...                                                   mo_dn=${mo_dn}
    &{parameter_dict}    Create Dictionary   actCDrxVoNR=true
    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
    ...                                                                      mo_parameter_dict=&{parameter_dict}
    vDU Login By Rest
    Run Keyword If  &{parameter_dict1} != &{Empty}
    ...             VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
	  ...                                          updated_paras_list=${parameter_dict}
	  ...                                          operation=replace
	  ...                                          activate=${True}
    ...                                          force_reset=${False}
    ...                                          auto_lock_cells=${False}
    ...                                          wait_vdu_up=${False}
    vDU Logout By Rest

Feature Deactivation With Reset In vCU And vDU
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    &{vcu_actCDrxVoNR_param}    create dictionary    operation_type=replace    parameter_path=/actCDrxVoNR
    ...                                                                         value=false
    @{updated_actCDrxVoNR_vcu}    Create List    ${vcu_actCDrxVoNR_param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=actCDrxVoNR
    ...                                                   updated_paras_dict=${updated_actCDrxVoNR_vcu}
    ...                                                   compare_value=false
    ...                                                   mo_dn=${mo_dn}
    &{parameter_dict}    Create Dictionary   actCDrxVoNR=false
    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
    ...                                                                      mo_parameter_dict=&{parameter_dict}
    vDU Login By Rest
    Run Keyword If  &{parameter_dict1} != &{Empty}
    ...             VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
  	...                                          updated_paras_list=${parameter_dict}
  	...                                          operation=replace
  	...                                          activate=${True}
    ...                                          force_reset=${False}
    ...                                          auto_lock_cells=${False}
    ...                                          wait_vdu_up=${False}
    vDU Logout By Rest

Lock Cell
    ${cell_id_list}    Create List    1
    Lock Cell In vDU    cell_id_list=${cell_id_list}

Unlock Cell
    ${cell_id_list}    Create List    1
    ${cell_id_list}    Create List    1
    Unlock Cell In vDU    cell_id_list=${cell_id_list}

Lock NG-C Links
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-1
    &{param}    create dictionary    operation_type=replace    parameter_path=/administrativeState
    ...                                                                         value=Locked
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Locked
    ...                                                   mo_dn=${mo_dn}

Unlock NG-C Links
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-1
    &{param}    create dictionary    operation_type=replace    parameter_path=/administrativeState
    ...                                                                         value=Unlocked
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Unlocked
    ...                                                   mo_dn=${mo_dn}

Lock RU
    @{rmod_id_list}    Create List    1
    Lock RU With Ru Id And Check Status In vDU    rmod_id_list=${rmod_id_list}

Unlock RU
    @{rmod_id_list}    Create List    1
    Unlock RU With Ru Id And Check Status In vDU    rmod_id_list=${rmod_id_list}

Lock vDU
    ${du_id_list}=    Create List    1
    Lock vDU In vCU    du_id_list=${du_id_list}    gnb_index=0    expected_dn=MRBTS-11073/NRBTS-11073/NRDU-1
    ...                compare_value=Locked

Unlock vDU
    ${du_id_list}=    Create List    1
    Unlock vDU In vCU    du_id_list=${du_id_list}    gnb_index=0    expected_dn=MRBTS-11073/NRBTS-11073/NRDU-1
    ...                compare_value=Unlocked

Online Modify Xn To Locked
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJGNB-2
    &{param}    create dictionary    operation_type=replace    parameter_path=/administrativeState
    ...                                                                         value=Locked
    @{updated_param}    Create List    ${param}
    Login To vCU By Rest    gnb_index=${0}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Locked
    ...                                                   mo_dn=${mo_dn}

Online Modify Xn To Unlocked
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJGNB-2
    &{param}    create dictionary    operation_type=replace    parameter_path=/administrativeState
    ...                                                                         value=Unlocked
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Unlocked
    ...                                                   mo_dn=${mo_dn}

