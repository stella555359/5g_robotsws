*** Settings ***
Documentation
...     [Author]        "Mamtha Kshirsagar"
...     [Maintenance]   "TRS ET Bangalore Team"
...     [Procedure]     "The test case is planned to verify ssh behaviour, webem access restriction behaviour and
...     password functionality for local user accounts"
...     [Date]          "05-01-2021"
...     [Feature_ID]    "CB007962"
...     [Requirement ID]    "WgNB_SEC_58854,WgNB_SEC_58904,5G_RAN_USR_COM_481"
...     [Config]    "This script requires basic SCF loading."
...     [RunTime Parameters]    "bts_id used is 1599"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot



Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***
[1]CB007962-B_Verify the SSH behavior,functionality
    Perform Recommissioning     type=param      rat=common     param_path=${sessionidletimer}  operation=update
    ...     value=120     timeout=300           alias=default
    Setup Remote Access  remote_device=bts    alias=default
    sleep   120
    Run Keyword And Expect Error       *${socket_error}*   Execute Interactive Remote Command  command=${command}
    ...     alias=default
    Teardown Remote Access      alias=default
    Setup Remote Access  remote_device=bts    alias=default
    Execute Interactive Remote Command  command= ${command2}   alias=default
    sleep   120
    Execute Interactive Remote Command  command=${command}   alias=default
    Teardown Remote Access      alias=default
    Perform Recommissioning     type=param      rat=common     param_path=${sessionidletimer}  operation=update
    ...     value=20     timeout=300           alias=default
    ${date}=    Get Current Date
    Setup Remote Access  remote_device=bts    alias=default
    @{cmd_1}=  Create List  scp_cmd
    ${cmd_2}=  Get Config Variable  ${cmd_1}
    Execute Interactive Remote Command  command=${cmd_2}  alias=default
    Execute Interactive Remote Command  command=yes     alias=default
    Execute Interactive Remote Command  command=ute     prompt=>      wait_for_prompt=${True}     alias=default
    ${date1}=   Get Current Date
    @{list1}=    Split String    ${date1}
    @{list}=    Split String    ${date}
    Log     @{list}[1]
    ${time}=    Subtract Time From Time     @{list1}[1]    @{list}[1]
    Should Be True  '${time}'>'20'
    [Teardown]  Teardown Remote Access      alias=default

[1]CB007962-C_Verify the webEM access restriction behavior,functionality
    Change credentials of user Using 'btsapplication' 'Crypto@262' 'BTSApplication' 'nemuuser' 'BtsApplication'
    Change credentials of user Using 'btssecurity' 'Crypto@262' 'BTSSecurity' 'nemuuser' 'BtsSecurity'
    Setup Oamops       dut=bts     alias=conn
    Perform Recommissioning     type=param      rat=common     param_path=${web_server_enable_moc}  operation=update
     ...        value=true     timeout=300           alias=default
    Perform Recommissioning     type=param      rat=common     param_path=${web_server_timer_moc}  operation=update
    ...     value=60     timeout=60              alias=default
    Sleep   60
    Run Keyword And Expect Error       *${sessionId_invalid}*       Perform Recommissioning     type=param      rat=common
    ...     param_path=${web_server_enable_moc}  operation=update    value=true     timeout=300           alias=conn
     Teardown Oamops        alias=conn
    Run Keyword And Expect Error       *${sessionId_invalid}*              Setup Oamops           alias=conn1
    Run Keyword And Expect Error        *${key_error}*                      Teardown Oamops        alias=conn1
    Run Keyword And Expect Error       *${sessionId_invalid}*              Setup Oamops     dut=bts1     alias=conn2
    Run Keyword And Expect Error        *${key_error}*                      Teardown Oamops     dut=bts1     alias=conn2
    Run Keyword And Expect Error       *${sessionId_invalid}*              Setup Oamops    dut=bts2     alias=conn3
    Run Keyword And Expect Error        *${key_error}*                      Teardown Oamops     dut=bts2     alias=conn3
    [Teardown]  Perform Recommissioning     type=param      rat=common     param_path=${web_server_enable_moc}
    ...     operation=update    value=false     timeout=300           alias=default

[1]CB007962-D_Verify the password functionality for localuser accounts
    Setup Oamops     dut=bts2     alias=conn2
    Teardown Oamops     dut=bts2     alias=conn2
    User Account Manage     operation=manage_local_user_account  account_type=BtsSecurity   old_username=BTSSecurity
    ...     old_password=Crypto@262    new_password=Crypto@262m
    Setup Oamops     dut=bts3     alias=conn2
    Teardown Oamops     dut=bts3     alias=conn2
    Run Keyword And Expect Error     *${password_too_weak}*   User Account Manage     operation=manage_local_user_account
    ...     account_type=BtsSecurity   old_username=BTSSecurity     old_password=Crypto@262m    new_password=crypto
    Run Keyword And Expect Error    *${derived_from_username}*   User Account Manage
    ...     operation=manage_local_user_account  account_type=BtsSecurity   old_username=BTSSecurity
    ...     old_password=Crypto@262m    new_password=BTSsecurity@12
    [Teardown]  User Account Manage     operation=manage_local_user_account  account_type=BtsSecurity
    ...     old_username=BTSSecurity     old_password=Crypto@262m    new_password=Crypto@262

***Keywords***
Change credentials of user Using '${new_username}' '${new_password}' '${old_username}' '${old_password}' '${account_type}'
     User Account Manage     operation=manage_local_user_account   new_username=${new_username}
     ...    new_password=${new_password}    old_username=${old_username}    old_password=${old_password}   account_type=${account_type}
     User Account Manage     operation=change_account_state      account_type=${account_type}    enable=${True}
