*** Settings ***
Documentation    This license common keyword, contain the login in/out clientMain.exe, get qualcomm license, drop license and so on.
...              Please do not modify the file without notification to author
...              Author: helen.1.chen
...              Contact: helen.1.chen@nokia-sbell
...              Squard: MMW_HZ_2

Library     ../python/licence_keeper.py
Library     licence_keeper.licence_keeper     WITH NAME    LK
Library     ../python/book_licence.py
Library     book_licence.LicenceBooker    WITH NAME     LB

*** Variables ***

*** Keywords ***
Prepare LKC
    [Documentation]  Author: helen.1.chen@nokia-sbell.com
    ...              Descrition：Start clientMain.exe and Login clientMain.exe
    [Arguments]    ${ue_index}
    LK.create_ssh_runner    host=${UE_pc_ip}    username=${UE_pc_user}    password=${UE_pc_password}    alias=${LKC_CLIENT_ALIAS}
    ${res} =    LK.licence_keeper_client_is_running    alias=${LKC_CLIENT_ALIAS}
    Run Keyword If    ${res} == ${True}     Kill ClientMain Process    ue_index=${ue_index}
    connect to control pc enhanced    ue_index=${ue_index}
    csn.send command
    ...    command=${LKC_CLIENT_PATH}/ClientMain.exe
    ...    connection=cpc_${ue_index}    timeout=100
    Sleep    5s
    LK.connect    host=${UE_pc_ip}    port=${LKC_CLIENT_PORT}
    LK.login    username=${LKC_LOGIN_USER}    password=${LKC_LOGIN_PWD}    timeout=30
    csn.disconnect      connection=cpc_${ue_index}
    LK.disconnect_ssh_runner    alias=${LKC_CLIENT_ALIAS}

Get Qualcomm License
    [Documentation]  Author: helen.1.chen@nokia-sbell.com
    ...              Descrition：get license for qxdm.exe and qcat.exe
    [Arguments]    ${ue_index}    ${keep_secs}    ${book_interval}
    Kill QXDM process    ue_index=${ue_index}
    Kill QPST process    ue_index=${ue_index}
    Prepare LKC    ue_index=${ue_index}
    LK.create_ssh_runner    host=${UE_pc_ip}    username=${UE_pc_user}    password=${UE_pc_password}    alias=${LKC_CLIENT_ALIAS}
    Keep 5G Licence    keep_secs=${keep_secs}    book_interval=${book_interval}
    LK.disconnect_ssh_runner    alias=${LKC_CLIENT_ALIAS}

Keep 5G Licence
    [Documentation]  Author: helen.1.chen@nokia-sbell.com
    ...              Descrition：Get 5G QXDM and 5G QCAT license
    [Arguments]    ${keep_secs}=${1200}    ${book_interval}=${600}
    ${lk instance} =    Get Library Instance     LK
    LB.Require Licence Keeper     ${lk instance}
    LB.Book Licence      keep_secs=${keep_secs}    book_interval=${book_interval}

Drop License
    [Documentation]  Author: helen.1.chen@nokia-sbell.com
    ...              Descrition：Release 5G QXDM and 5G QCAT license
    [Arguments]    ${ue_index}=${0}
    LK.create_ssh_runner    host=${UE_pc_ip}    username=${UE_pc_user}    password=${UE_pc_password}    alias=${LKC_CLIENT_ALIAS}
    LB.Release
    LK.disconnect
    LK.disconnect_ssh_runner    alias=${LKC_CLIENT_ALIAS}
