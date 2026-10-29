*** Settings ***
Library          ./keywords.py
Library          ./ru_functions.py
Library          ./ssh_keys_verification.py
Resource         taf/rfrl/bts/robot/gnb.robot

*** Keywords ***
Check tcpdump
    ${tcpdump}=  get_tcpdump
    Run keyword IF  ${tcpdump} == ${FALSE}    Fail  Tcpdump did not caught

Verify SSH and hash
    [Arguments]    ${password}=${SERVICEUSER_DEFAULT_PASSWORD}
    ${ssh}=  Compare SSH Login Configuration Parameters Between Bts and RU    password=${password}
    Run keyword IF  ${ssh} == ${FALSE}    Fail  SSH dont match
    ${hash}=  Compare Password Hashes Between Bts and RU    password=${password}
    Run keyword IF  ${hash} == ${FALSE}    Fail  HASH dont match

Change param via WebEM
    [Arguments]   ${param_value}  ${param}
    Perform Configuration Parameter Recommissioning On gNB    dist_name=MRBTS-{}/MNL-1/MNLENT-1/SECADM-1
    ...   param_name=${param}   operation=update    param_value=${param_value}
    ...   skip_parameter_relation_errors=${true}
    Sleep  60s

Manually trigger the Service Account synchronization to RU RF MODULE
    Manually trigger the service account synchronization

Manually trigger the Service Account synchronization to RU RF MODULE with diffrent accounts
    Manually trigger the service account synchronization   web_user=BTSSecurity   web_password=Nemu@123
    Manually trigger the service account synchronization   web_user=BTSApplication   web_password=Nemu@123
    Manually trigger the service account synchronization   web_user=BTSRead   web_password=Nemu@123
    Manually trigger the service account synchronization

Verify automatic synchronization with different webEM accounts
    try_change_flag  username=Nemuadmin  password=nemuuser
    try_change_flag  username=BTSSecurity  password=Nemu@123
    try_change_flag  username=BTSApplication  password=Nemu@123
    try_change_flag  username=BTSRead  password=Nemu@123

Verify SSH Session Delay Timer
    [Arguments]     ${timeout}=20   ${bts_id}=0     ${du_id}=0
    verify_sshSessionLoginDelayTimer_parameter    timeout=${timeout}  bts_id=${bts_id}  du_id=${du_id}
