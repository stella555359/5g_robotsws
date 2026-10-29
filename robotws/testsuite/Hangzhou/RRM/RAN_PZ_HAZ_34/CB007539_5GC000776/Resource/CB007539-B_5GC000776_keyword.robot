*** Settings ***
Documentation
...    author: yingying.li
...    contact: yingying.1i@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    csn

Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource          ../../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          ../../../../resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot


*** Keywords ***
Check GNB cell on air
    [Documentation]  Author: Ding Binmei
    ...              Description: Check if GNB is in cell on air status
    Connect to COAM
    COAM Check All Cells Onair

Connect to COAM
    [Arguments]    ${connection}=COAM
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}

Modify case1 and case2 parameter
    log to console    change actNonGbrServiceDiff to true and check
    Set parameter actNonGbrServiceDiff  key=actNonGbrServiceDiff    value=${true}
    log to console    change actMultiDrbNSA to true and check
    Set parameter actMultiDrbNSA   key=actMultiDrbNSA    value=${true}
    log to console    change MRBTS-917/NRBTS-917/NRDRB-4 schedulWeight to 10  and check
    Set parameter QCI4 schedulWeight    key=schedulWeight    value=${10}
    log to console    change MRBTS-917/NRBTS-917/NRDRB-8 schedulWeight to 1  and check
    Set parameter QCI8 schedulWeight   key=schedulWeight    value=${1}

Modify case3 parameter
    log to console    change actNonGbrServiceDiff to true and check
    Set parameter actNonGbrServiceDiff  key=actNonGbrServiceDiff    value=${true}
    log to console    change actMultiDrbNSA to true and check
    Set parameter actMultiDrbNSA   key=actMultiDrbNSA    value=${true}
    log to console    change MRBTS-917/NRBTS-917/NRDRB-4 schedulWeight to 5  and check
    Set parameter QCI4 schedulWeight    key=schedulWeight    value=${5}
    log to console    change MRBTS-917/NRBTS-917/NRDRB-8 schedulWeight to 3  and check
    Set parameter QCI8 schedulWeight   key=schedulWeight    value=${3}

Set parameter actNonGbrServiceDiff
    [Arguments]  ${key}    ${value}    ${dict_name}=MRBTS-917/NRBTS-917
    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=COAM
    sleep    60s

Set parameter actMultiDrbNSA
    [Arguments]  ${key}    ${value}    ${dict_name}=MRBTS-917/NRBTS-917
    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=COAM
    sleep    60s

Set parameter QCI4 schedulWeight
    [Arguments]  ${key}    ${value}    ${dict_name}=MRBTS-917/NRBTS-917/NRDRB-4
    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=COAM
    sleep    60s

Set parameter QCI8 schedulWeight
    [Arguments]  ${key}    ${value}    ${dict_name}=MRBTS-917/NRBTS-917/NRDRB-8
    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=COAM
    sleep    60s

Get Interval Seconds
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]  ${interval}
    ${num}    get substring    ${interval}     0    -3
    ${num}    convert to integer    ${num}
    ${interval_seconds}    evaluate    ${num}*60
    [Return]  ${interval_seconds}
