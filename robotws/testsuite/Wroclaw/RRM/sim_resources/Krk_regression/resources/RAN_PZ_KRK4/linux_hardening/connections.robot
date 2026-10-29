*** Settings ***
Documentation  Keyword allows ssh connection to remote machine.
...            IP addresses are available in common variables files or can be overwritten in every TL config.

Library    taf.transport.ssh		WITH NAME	csn
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/resources/RAN_PZ_KRK4/linux_hardening/wro/trs_resources.py
Library    taf.ul.oam.selenium_megazone
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/resources/RAN_PZ_KRK4/linux_hardening/wro/ssh_keys.py
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/resources/RAN_PZ_KRK4/linux_hardening/wro/check_IP.py
Library    taf.rfrl.bts.commissioning
Resource   testsuite/Wroclaw/RRM/sim_resources/Krk_regression/resources/RAN_PZ_KRK4/linux_hardening/hardening_keywords.robot
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource   taf/rfrl/bts/robot/gnb.robot
Resource   taf/rfrl/bts/robot/logs_collecting.robot
Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***
${BB1_IP}      192.168.255.129
${BB1_LOGIN}=        toor4nsn
${BB1_PASSWORD}=     oZPS0POrRieRtu


*** Keywords ***
Connect to OAM
    [Arguments]    ${oam_addr}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...            ${oam_username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...            ${oam_password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...            ${alias}=OAM
    csn.Connect to     ${oam_addr}     ${oam_username}     ${oam_password}    alias=${alias}

Connect to BB
    [Arguments]     ${alias}=BB1    ${proxy}=proxy
    Log   ${proxy}
    csn.Connect to    hostname=${BB1_IP}    username=${BB1_LOGIN}     password=${BB1_PASSWORD}    alias=${alias}

Connect to test pc
    [Arguments]    ${proxy_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${proxy_login}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${proxy_password}=${tl.test_pc.default_ssh_connection_details.password}
    ...            ${alias}=proxy
    csn.Connect to     hostname=${proxy_ip}    username=${proxy_login}     password=${proxy_password}   alias=${alias}

Preconditions
    Common Suite Setup With Commissioning
    Connect to test pc
    Connect to BB

Postconditions_DU_CU
    Wait For Site To Be Onair
    DU_check_active_alarms
    Common Suite Teardown
