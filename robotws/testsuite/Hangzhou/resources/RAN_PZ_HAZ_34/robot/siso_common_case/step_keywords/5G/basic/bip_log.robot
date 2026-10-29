*** Settings ***
Documentation    This is common keywords for siso RU related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4   HZ SG8

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
*** Keywords ***

Check BBMOD And Get Slot Id
    [Arguments]    ${cmd}=bmutool -I    ${abil_1}=${0}    ${abil_2}=${0}    ${abil_3}=${0}   ${abil_5}=${0}   ${abil_6}=${0}  ${abil_7}=${0}
    [Documentation]   Check BBMOD is ABIO or ABIL  and IF Slot Id exist Set True Or Set Flase
#    ${modules}   csn.Execute   command=bmutool -I   connection=bip
    ${modules}   csn.Execute   command=${cmd}   connection=bip   timeout=30
    ${abil_1_exist}   Evaluate   ${modules.count('${abil_1}')}>0
    ${abil_2_exist}   Evaluate   ${modules.count('${abil_2}')}>0
    ${abil_3_exist}   Evaluate   ${modules.count('${abil_3}')}>0
    ${abil_5_exist}   Evaluate   ${modules.count('${abil_5}')}>0
    ${abil_6_exist}   Evaluate   ${modules.count('${abil_6}')}>0
    ${abil_7_exist}   Evaluate   ${modules.count('${abil_7}')}>0
    ${abil_1_exist}   Convert to String   ${abil_1_exist}
    ${abil_2_exist}   Convert to String   ${abil_2_exist}
    ${abil_3_exist}   Convert to String   ${abil_3_exist}
    ${abil_5_exist}   Convert to String   ${abil_5_exist}
    ${abil_6_exist}   Convert to String   ${abil_6_exist}
    ${abil_7_exist}   Convert to String   ${abil_7_exist}
    [Return]   ${abil_1_exist}  ${abil_2_exist}  ${abil_3_exist}   ${abil_5_exist}   ${abil_6_exist}   ${abil_7_exist}


Start BIP Logs Capture
    [Arguments]     ${gnb_index}=${0}
    [Documentation]   collect bip logs from ASIK
    log to console    start to collect BIP logs
    Connect to Common Unit Master  alias=bip    gnb_index=${gnb_index}
    run keyword and ignore error    csn.Execute   command=rm -rf /tmp/tcpdumpL2L1*   connection=bip
    ${modules}   csn.Execute   command=bmutool -I   connection=bip
    ${ABIO_exist}   Evaluate   ${modules.count('ABINO')}>0
    ${abio_1_exist}  ${abio_2_exist}  ${abio_3_exist}   ${abio_5_exist}   ${abio_6_exist}   ${abio_7_exist}   Run Keyword If   ${ABIO_exist}
    ...   Check BBMOD And Get Slot Id   cmd=bmutool -I   abil_1=slot-id 1): ABINO   abil_2=slot-id 2): ABINO   abil_3=slot-id 3): ABINO
    ...    abil_5=slot-id 5): ABINO    abil_6=slot-id 6): ABINO  abil_7=slot-id 7): ABINO
    ${ABIL_exist}   Evaluate   ${modules.count('ABIL')}>0
    ${abil_1_exist}  ${abil_2_exist}  ${abil_3_exist}   ${abil_5_exist}   ${abil_6_exist}   ${abil_7_exist}   Run Keyword If   ${ABIL_exist}
    ...    Check BBMOD And Get Slot Id   cmd=arp -a   abil_1=fsp-1-1   abil_2=fsp-1-2   abil_3=fsp-1-2
    ...    abil_5=fsp-2-5    abil_6=fsp-2-6  abil_7=fsp-2-7
    ...    ELSE IF   ${ABIO_exist}    Set Variable   ${abio_1_exist}  ${abio_2_exist}  ${abio_3_exist}   ${abio_5_exist}
    ...    ${abio_6_exist}   ${abio_7_exist}
    ${bip_start}   Set Variable   ${True}
    ${bip_start}   Run Keyword If  '${ABIO_exist}'=='True' or '${ABIL_exist}'=='True'     Run Keyword and Return Status
    ...   Bip Capture with gnbMirroring scripts with retry   connection=bip
    ...   bb_slot_1=${abil_1_exist.lower()}   bb_slot_2=${abil_2_exist.lower()}   bb_slot_3=${abil_3_exist.lower()}
    ...   bb_slot_5=${abil_5_exist.lower()}  bb_slot_6=${abil_6_exist.lower()}   bb_slot_7=${abil_7_exist.lower()}
    ...   file_size_mbytes=900   number_of_files=1
    ...   ELSE   log to console    BBMOD not ABIO or ABIL, not support collect bip
    run keyword if  not ${bip_start}   Log to Console   [WARN]Bip start failed
    [Teardown]   csn.Disconnect   connection=bip

Stop BIP Logs Capture And DownLoad Logs
    [Arguments]   ${bip_log_path}=${SAVE LOG DIRECTORY}     ${gnb_index}=${0}
    Connect to Common Unit Master  alias=bip    gnb_index=${gnb_index}
    Stop BIP Capture On ASIK    interface=tcpdump_L2L1    connection=bip    kill_type=2
    ${list_log_path_local}    Download BIP Logs From ASIK To TestPC and rename it
    ...    log_path=${bip_log_path}
    ...    connection=bip
    log to console    collect bip logs Done
    [Return]   ${list_log_path_local}
    [Teardown]   csn.Disconnect   connection=bip
