*** Settings ***
Documentation
...   author: Sylwia Swiatkiewicz
...   contact: sylwia.swiatkiewicz@nokia.com

Library     taf.transport.ssh    WITH NAME    ssh
Library     ./swconfig.py
Library     ./utils.py
Resource    ../resources/admin_infomodel.robot
Resource    ../resources/recovery.robot

*** Keywords ***
Assure flags are in swconfig
    [Documentation]
    ...    This keyword adds 0x10041 = 5 (syslog) and 0x45005A=1 (developer)
    ...    flags to swconfig file on cloud testlines
    ...    It downloads swconfig from ASIK
    ...    checks and adds the flags if missing
    ...    uploads file to ASIK with crasign and reboot
    [Arguments]    ${sw_version}=5G000_AAAA_0000_000000_000000
    download swconfig from bts
    ${is_upload_needed}=  change swconfig file    ${sw_version}
    run keyword if    ${is_upload_needed}==${True}    upload swconfig to bts
    ssh.disconnect
    run keyword if    ${is_upload_needed}==${True}    Wait for new swconfig load


Download swconfig from BTS
    ssh.connect to    192.168.255.1    toor4nsn    oZPS0POrRieRtu
    ssh.download file    /rom/swconfig.txt    /home/ute/swconfig_from_bts.txt


Upload swconfig to BTS
    ssh.upload file    /home/ute/swconfig_from_bts.txt    /rom/swconfig.txt
    ssh.send command    crasign /rom/swconfig.txt
    log to console    New swconfig uploading
    RECOVERY Gnb Power Reset

Wait for new swconfig load
    Wait for OnAir state lost
     Log to console    New swconfig uploaded
#    custom_commissionings.Wait for OnAir

Wait for OnAir state lost
    wait_until_keyword_fails  5min    10s    ADMIN INFOMODEL Check If BTS Is OnAir
