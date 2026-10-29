*** Settings ***
Documentation
...  author: He Jingmin
...  contact: jingmin.he@nokia-sbell.com
Library   taf.transport.ssh   WITH NAME   csn

Library   OperatingSystem
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot

*** Variables ***
${stop_bip_cmd}   ps -ef | grep tcpdump | grep etha01 | grep -v grep | awk '{print $2}' |xargs sudo kill -9

*** Keywords ***
Start BIP Collection New
    [Documentation]   TBD. Use bip collection common keyword in resources folder
    csn.Connect To   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=bip
    csn.Execute   command=rm -f /tmp/tcpdumpL2L1*   connection=bip
    ${modules}   csn.Execute   command=arp -a   connection=bip
    ${abil_2_exist}   Evaluate   ${modules.count('fsp-1-2')}>0
    ${abil_3_exist}   Evaluate   ${modules.count('fsp-1-3')}>0
    ${abil_2_exist}   Convert to String   ${abil_2_exist}
    ${abil_3_exist}   Convert to String   ${abil_3_exist}
    ${bip_start}   Run Keyword and Return Status   Bip Capture with gnbMirroring scripts with retry   connection=bip
    ...   bb_slot_2=${abil_2_exist.lower()}   bb_slot_3=${abil_3_exist.lower()}
    run keyword if  not ${bip_start}   Log to Console   [WARN]Bip start failed
    [Teardown]   csn.Disconnect   connection=bip
#
Stop BIP Collection New
    [Arguments]   ${bip_log}=bip.pcap
    csn.Connect To   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=bip
    Stop BIP Capture with gnbMirroring scripts On Common Unit   connection=bip
    ${file_path}   csn.Execute   command=ls /tmp/tcpdumpL2L1*   connection=bip
    Should Not Be Empty   ${file_path}
    csn.Download File   remote_path=${file_path}   local_path=${OUTPUT_DIR}/${bip_log}   connection=bip
    csn.Execute   command=rm -f /tmp/tcpdumpL2L1*   connection=bip
    [Return]   ${bip_log}
    [Teardown]   csn.Disconnect   connection=bip
