# @Time    : 2025/2/14 18:17
# @Author  : Chun.li
# @Email   : chun.li@nokia-sbell.com
# @File    : 3G_RRM_Keywords.robot
# @Software: PyCharm
# @Doc     : Common Keywords for SRAN 3G RRM regression
*** Settings ***

Documentation
...    author: Chun Li
...    Contact: chun.li@nokia-sbell.com
...    Team: RAN RD VRF HAZ3 5
...    Feature: For SRAN 3G RRM


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Variables ***
@{POLQA MOS NB}    POLQA MOS NB

*** Keywords ***
Open Pionner
    [Arguments]    ${ue_index}=${0}
    [Documentation]    This KW used to open Dingli Pionner in the UE PC.
    ...    Please note that schedule task should be created with name dingli in the windows UE PC.

    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    csn.send_command    command=schtasks /run /tn dingli
    ...    connection=cygwin
    sleep    50s

Close Pioneer
    [Arguments]    ${ue_index}=${0}
    [Documentation]    This KW used to Close Pionner in the UE PC.

    Commercial_mobile_phone_adb_common_keywords.Connect to control pc via cygwin    ue_index=${ue_index}
    csn.Execute       command=taskkill /F /IM Pioneer.exe       connection=cygwin


Prepare 2UE in Pionner
    [Arguments]    ${host}=${tl.ues[0].ssh_connection_details.addr}
        ...    ${username}=${tl.ues[0].ssh_connection_details.username}
        ...    ${password}=${tl.ues[0].ssh_connection_details.password}
        ...    ${imsi1}=${imsi1}    ${imsi2}=${imsi2}    ${alias}=pioneer    ${ue_alias1}=UE1    ${ue_alias2}=UE2
        ...    ${port}=30999    &{kwargs}
    [Documentation]    Prepare UE for L3 call test.

    pclient.setup_service
    ...    host=${host}
    ...    port=${port}
    ...    ssh_username=${username}
    ...    ssh_password=${password}
    ...    alias=${alias}
    ...    timeout=300
    Run Keyword And Ignore Error    pclient.prepare_ues    service=${alias}
	sleep    60s
    pclient.remove_remote_files    folder_path=c:/pioneer_logs/    service=${alias}
    pclient.require_ue    service=${alias}     imsi=${imsi1}    ue_alias=${ue_alias1}
    pclient.require_ue    service=${alias}     imsi=${imsi2}    ue_alias=${ue_alias2}
    ${is_kirin}     pclient.is_kirin_chip    ue=${ue_alias1}
    ${is_kirin}     pclient.is_kirin_chip    ue=${ue_alias2}
    sleep    2s

Check 3G MOS
    [Arguments]    ${UE_ID}=UE1
    [Documentation]    This KW used to check MOS value for 3G NB voice call.
    ...    MOS_value_rang1 means the percentage of MOS score in the rang of (4,+INF);
    ...    MOS_value_rang2 means the percentage of MOS score in the rang of (3.5,4];

    ${POLQA MOS score}=    pclient.get_param_summary_statistics_result    ue=${UE_ID}    paramname=@{POLQA MOS NB}
    ${MOS_score}    set variable    ${POLQA MOS score['Param']['POLQA MOS NB']['Avg']}
    Should Be True    ${MOS_score} > ${mos_expect}
    ${POLQA MOS distribution}=    pclient.get_param_statistics_result    ue=${UE_ID}    paramname=@{POLQA MOS NB}
    ${MOS_value_rang1}    set variable    ${POLQA MOS distribution['Param']['POLQA MOS NB']}[3]
    ${MOS_value_rang2}    set variable    ${POLQA MOS distribution['Param']['POLQA MOS NB']}[2]
    ${MOS_value_PDF1}    set variable    ${MOS_value_rang1['PDF']}
    ${MOS_value_PDF2}    set variable    ${MOS_value_rang2['PDF']}
    ${MOS_value_count1}    set variable    ${MOS_value_rang1['Count']}
    ${MOS_value_count2}    set variable    ${MOS_value_rang2['Count']}
    ${MOS_value_count}    Evaluate    ${MOS_value_count1} + ${MOS_value_count2}
    Should Be True     ${MOS_value_count} > 0
    ${MOS_value_PDF1}    Evaluate    ${MOS_value_PDF1.strip("%")}
    ${MOS_value_PDF2}    Evaluate    ${MOS_value_PDF2.strip("%")}
    ${MOS_value}    Evaluate    ${MOS_value_PDF1} + ${MOS_value_PDF2}
    Should Be True    ${MOS_value} > ${98}