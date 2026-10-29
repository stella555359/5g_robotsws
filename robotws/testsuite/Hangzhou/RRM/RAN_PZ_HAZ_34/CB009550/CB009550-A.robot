*** Settings ***
Documentation     author: y63li
...               contact: ying.15.li@nokia-sbell.com
...               squad group: MMW_SG3

Suite Setup        Run Keyword And Ignore Error       robot_common_operations.Common Suite Setup
Suite Teardown     Run Keyword And Ignore Error       robot_common_operations.Common Suite Teardown

Resource       Resources/CB009550_Common_Keywords.robot
*** Variables ***
${TS_CASE_LOG_PATH}   /home/ute/log

*** Test Cases ***
#    [1]CB009550-A_12_PM_M55308C00036&M55308C00037
#    [Setup]    Case Setup      chbw=${20}
#    Enable Counter collect
#    Configure actFdmInitialDedicatedFdd to true
#    Repeat Keyword   2x   Attach 3 SA UEs and Data Transfer
#    wait until keyword succeeds    6min    2min     Check PM Counter update as Expect
#    Stop 3 traffic and SA UEs Detach
#    Connect to DU via ssl
#    Configure actFdmInitialDedicatedFdd to false
#    Repeat Keyword   2x   Attach 3 SA UEs and Data Transfer
#    wait until keyword succeeds    6min    2min     Check PM Counter update as Expect
#    Stop 3 traffic and SA UEs Detach
#    [Teardown]    Case Teardown

[1]CB009550-B_15_Counter_M55306C09012_M55306C09013_Verification
    [Setup]    Case Setup
    #Run Keyword And Ignore Error    robot_common_operations.Common case setup
    Connect to DU via ssl
    Configure actFdmSchedulingInitialBWP to false
    Enable Counter collect
    #Attach 4 SA UEs and Data Transfer
    #sleep    5min
    #Connect to DU via ssl
    #${release}    coam.get_sw_release_name    connection=${GNB_COAM_ALIAS}
    #${counter_value}   run keyword if    '${release}' == 'SBTS23R4'
    #...     Get PM counter when modify BWP    counter_id=M55306C09013   full_path=${full_path1}
    #...    ELSE    Get PM counter when modify BWP    counter_id=M55306C09013   full_path=${full_path2}
    #${counter_value}      Check PM counter     counter_id=M55306C09013      full_path=${full_path}
    #${counter_true}    Set Variable     ${counter_value}
    #Detach multi-UEs
    Connect to DU via ssl
    Configure actFdmSchedulingInitialBWP to true
    #Attach 4 SA UEs and Data Transfer
    #sleep    5min
    #${counter_value}      Check PM counter     counter_id=M55306C09013      full_path=${full_path}
    #${counter_false}    Set Variable   ${counter_value}
    #Detach multi-UEs
    #BuiltIn.Should Be True     ${counter_true} < ${counter_false}
    [Teardown]    Case Teardown

*** Keywords ***
Prepare ue
    log to console      Prepare ue
    client.setup_service    host=${host}    port=${port}   ssh_username=${username}
    ...    ssh_password=${password}    alias=${alias}
    @{UEs_info}    client.prepare_ues    service=pioneer
    ${imsi_list}    create list
    FOR    ${item}    IN    @{UEs_info}
    Append To List     ${imsi_list}     ${item}[imsi]
    END
    Remove values From List    ${imsi_list}    ERROR
    Set Suite Variable    ${imsi_list}

Combine ${ue_num} UE Group
    log to console      Combine UE Group
    ${uegroup}    create list
    FOR    ${i}    IN RANGE    ${ue_num}
    client.require_ue    imsi=${imsi_list}[${i}]    service=${alias}    ue_alias=${ue_alias}${i}
    Append To List     ${uegroup}     ${ue_alias}${i}
    END
    Set Suite Variable    ${uegroup}


Attach multi-UEs
     log to console      UE attach
     client.poweroff     ue=${uegroup}    until_timeout=${30}
     sleep    5s
     client.poweron     ue=${uegroup}     until_timeout=${30}
     sleep    10s

Start traffic
    log to console      traffic start
    client.Startraffic
    ...    ue=${uegroup}
    ...    protocol=UDP
    ...    address=${app_addr}
    ...    port=${app_port}
    ...    testtime=20
    ...    bandwidth=10000
    ...    buffersize=${1024}
    ...    packetsize=${1400}
    ...    direction=${1}
    ...    threadcount=${1}
    ...    ue=${uegroup}
    ...    until_timeout=${30}

Detach UE
    log to console      1 UE detach
    Run Keyword And Ignore Error    client.poweroff     ue=${ue_alias}${0}    until_timeout=${30}

Detach multi-UEs
     log to console      serveral UE detach
     Run Keyword And Ignore Error    client.poweroff     ue=${uegroup}    until_timeout=${30}
