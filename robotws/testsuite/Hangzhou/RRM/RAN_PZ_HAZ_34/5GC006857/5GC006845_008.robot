# *** Settings ***
# Force Tags    PY36
# Suite Setup
# Suite Teardown    CI_interface.Common Case Teardown
# Documentation
# ...   author: xiaofeng.1.zhu@nokia-sbell.com
# ...   contact: xiaofeng.1.zhu@nokia-sbell.com
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Variables         Resources/5GC006857_modify_para.py
# Library           Resources/5GC006857_AIAE.py
# Library           taf.transport.ssh    WITH NAME    csn
# Library           taf.hw.rf_attenuator    WITH NAME    att
# Library           taf.selenium.gnb.oam.coam.classical    WITH NAME    selenium
# Library           taf.ue  WITH NAME   ute_ue
# Library           ./Resources/common_keyword.py
# *** Variables ***
# ${DU_OAM_IP_TL}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_SSH_USERNAME_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
# ${DU_OAM_SSH_PASSWORD_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
# ${instance_id}               ${tl.gnbs[0].instance_id}
#
# ${connection}                 GNB_OAM
# ${connection1}                GNB_OAM1
# ${ru_alias}                   RU
# ${asik_alias}                 ASIK Master
#
# *** Test Cases ***
# [1]CB006845_008_Automatic_SW_update_when_radio_with_incompatible_SW_version_detected
#     [Documentation]    Automatic SW update when radio with incompatible SW version detected
#     [Tags]     CRT_TRUNK
#     [Setup]
#     check cell onair    BTS_IP=${DU_OAM_IP_TL}
#     ${SN}    login RU to active SW    RU_USERNAME=root    RU_PASSWORD=asmr    container_id=0x2018
#     COAM Get RMOD List    SN=${SN}
#     check fault 23 alarm    BTS_IP=${DU_OAM_IP_TL}     test_alarm_ID=${23}    test_alarm_name=Incompatible SW version detected
#     wait until keyword succeeds    20 min    10 s    check cell onair    BTS_IP=${DU_OAM_IP_TL}
#     coam.connect_to    bts_host=${DU_OAM_IP_TL}   name=${connection}
#     check alarm active    test_alarm_ID=${23}    test_alarm_name=Incompatible SW version detected    flag=False
#     [Teardown]    Logout
#
# *** Keywords ***
# login RU to active SW
#     [Arguments]    ${RU_USERNAME}    ${RU_PASSWORD}    ${container_id}=0x2018    ${buildName}=100
#     csn.connect_to
#     ...    hostname=${DU_OAM_IP_TL}
#     ...    username=${DU_OAM_SSH_USERNAME_TL}
#     ...    password=${DU_OAM_SSH_PASSWORD_TL}
#     ...    alias=${asik_alias}
#     csn.Send Command    command=cat /ffs/run/config/FRIps.txt |grep AWE|cut -d ';' -f 3|head -1|tail -n 1   connection=${asik_alias}
#     ${RU_IP}    csn.Read Output    connection=${asik_alias}
#     ${RU_IP}    strip_string    ${RU_IP}
#     log to console    RU_IP：${RU_IP}
#     csn.Send Command    command=cat /ffs/run/config/FRIps.txt |grep AWE|cut -d ';' -f 4|head -1|tail -n 1   connection=${asik_alias}
#     ${SN}    csn.Read Output    connection=${asik_alias}
#     ${SN}    strip_string    ${SN}
#     log to console    SN:${SN}
#
#     Connect To RU     ru_ip_addr=${RU_IP}    container_id=${container_id}   ru_username=${RU_USERNAME}
#     ...    ru_password=${RU_PASSWORD}
#     log to console    connect RU successful
#     ${file_name1}    Get RU SW version    command=cat /mnt/runtime/swman/slot0_sw |grep file_name|awk '{print $2}'|cut -d '"' -f 2
#     ${file_version1}    Get RU SW version    command=cat /mnt/runtime/swman/slot0_sw |grep file_version|awk '{print $2}'|cut -d '"' -f 2
#     ${build_name1}    Get RU SW version    command=cat /mnt/runtime/swman/slot0_sw |grep build_name|awk '{print $2}'|cut -d '"' -f 2
#     ${build_version1}    Get RU SW version    command=cat /mnt/runtime/swman/slot0_sw |grep build_version|awk '{print $2}'|cut -d '"' -f 2
#
#     ${file_name2}    Get RU SW version    command=cat /mnt/runtime/swman/slot1_sw |grep file_name|awk '{print $2}'|cut -d '"' -f 2
#     ${file_version2}    Get RU SW version    command=cat /mnt/runtime/swman/slot1_sw |grep file_version|awk '{print $2}'|cut -d '"' -f 2
#     ${build_name2}    Get RU SW version    command=cat /mnt/runtime/swman/slot1_sw |grep build_name|awk '{print $2}'|cut -d '"' -f 2
#     ${build_version2}    Get RU SW version    command=cat /mnt/runtime/swman/slot1_sw |grep build_version|awk '{print $2}'|cut -d '"' -f 2
#
#     ${activeBuildName}    Get RU SW version    command=SWmanShellCommand -i |grep activeBuildName:|awk '{print $2}'
#     log to console    build_name1 is:${build_name1}
#     log to console    build_name2 is:${build_name2}
#     log to console    activeBuildName is:${activeBuildName}
#     ${buildName}    set variable if    '${build_name1}'=='${activeBuildName}'    ${build_name2}    ${build_name1}
#     ${buildVersion}    set variable if    '${build_name1}'=='${activeBuildName}'    ${build_version2}    ${build_version1}
#     ${fileName}    set variable if    '${build_name1}'=='${activeBuildName}'    ${file_name2}    ${file_name1}
#     ${fileVersion}    set variable if    '${build_name1}'=='${activeBuildName}'    ${file_version2}    ${file_version1}
#     should not be empty    ${buildName}
#     should not be equal as strings    ${buildName}    100
#     log to console    buildName is:${buildName}
#
#     csn.Send Command    command=SWmanShellCommand -a ${buildName} ${buildVersion} ${fileName} ${fileVersion}    connection=${ru_alias}
#     log to console    SWmanShellCommand -a ${buildName} ${buildVersion} ${fileName} ${fileVersion}
#     sleep    10s
#     #csn.Send Command    command=reboot    connection=${ru_alias}
#     [Return]    ${SN}
#     [Teardown]   Logout
#
# Connect To RU
#     [Arguments]    ${ru_ip_addr}    ${container_id}=0x1018    ${container_alias}=Container    ${ru_alias}=RU
#     ...            ${asik_alias}=ASIK Master    ${fhnet_host_ip}=192.168.255.254
#     ...            ${ru_username}=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
#     ...            ${ru_password}=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
#     ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
#     ${channel}    Call Method    ${connection}    invoke_shell
#     Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
#     Sleep    1 sec
#     Call Method    ${channel}    recv    ${65535}
#     Call Method    ${channel}    send    ps -ef|grep sshd\n
#     Sleep    3 sec
#     ${output}    Call Method    ${channel}    recv    ${65535}
#     ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
#     ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
#     Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
#     ...                                            Sleep    3 sec    AND
#     ...                                            Call Method    ${channel}    recv    ${65535}
#     Call Method    ${channel}    close
#     csn.connect to    hostname=${fhnet_host_ip}
#     ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
#     ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#     ...               alias=${container_alias}
#     ...               proxy=${asik_alias}
#     csn.connect to    hostname=${ru_ip_addr}
#     ...               username=${ru_username}
#     ...               password=${ru_password}
#     ...               alias=${ru_alias}
#     ...               proxy=${container_alias}
#
# #reset site
# #    [Arguments]    ${BTS_IP}
# #    coam.connect_to    bts_host=${BTS_IP}   name=${connection}
# #    coam.reset_site     timeout=300     connection=${connection}   wait_for_reconnection=${true}
# #    [Teardown]    Logout
#
# Get RU SW version
#     [Arguments]    ${command}
#     csn.Send Command    command=${command}    connection=${ru_alias}
#     ${GET_SW}  csn.Read Output    connection=${ru_alias}
#     ${GET_SW}  strip_string    ${GET_SW}
#     log to console    ${GET_SW}
#     [Return]    ${GET_SW}
#
# Logout
#     run keyword and ignore error    csn.disconnect    connection=${ru_alias}
#     run keyword and ignore error    csn.disconnect    connection=${asik_alias}
#     run keyword and ignore error    coam.teardown    connection=${connection}
#
# check fault 23 alarm
#     [Arguments]    ${BTS_IP}    ${test_alarm_ID}    ${test_alarm_name}
#     log to console    check alarm...
#     coam.connect_to    bts_host=${BTS_IP}   name=${connection}
#     wait until keyword succeeds    10 min    10 s    check alarm active    test_alarm_ID=${test_alarm_ID}    test_alarm_name=${test_alarm_name}
#     log to console    check alarm successful
#     [Teardown]    coam.teardown    connection=${connection}
#
# check alarm active
#     [Arguments]    ${test_alarm_ID}    ${test_alarm_name}    ${flag}=True
#     log to console    start check alarm
#     ${alarms}    coam.get_active_alarms    connection=${connection}
#     sleep    1s
#     log     ${alarms}
#     ${fault_id_list}    create list
#     ${fault_name_list}    create list
#     FOR    ${item}    IN    @{alarms}
#          ${fault_id}    get from dictionary    ${item}    faultId
#          ${fault_name}    get from dictionary    ${item}    faultName
#          append to list    ${fault_id_list}    ${fault_id}
#          append to list    ${fault_name_list}    ${fault_name}
#     END
#     log to console    fault_id_list=${fault_id_list}
#     log to console    fault_name_list=${fault_name_list}
#     log to console    test_alarm_ID=${test_alarm_ID}
#     log to console    test_alarm_name=${test_alarm_name}
#     Run Keyword If    '${flag}'=='True'    list should contain value     ${fault_id_list}    ${test_alarm_ID}
#     Run Keyword If    '${flag}'=='True'    list should contain value     ${fault_name_list}    ${test_alarm_name}
#     Run Keyword If    '${flag}'=='False'    list should not contain value     ${fault_id_list}    ${test_alarm_ID}
#     Run Keyword If    '${flag}'=='False'    list should not contain value     ${fault_name_list}    ${test_alarm_name}
#
# check cell onair
#     [Arguments]    ${BTS_IP}
#     coam.connect_to    bts_host=${BTS_IP}   name=${connection}
#     Wait Until Keyword Succeeds    10min    10sec    COAM Check All Cells Onair
#     log to console    check cell onair successful
#     [Teardown]    coam.teardown    connection=${connection}
#
# COAM Check All Cells Onair
#     [Arguments]   ${connection}=${connection}
#     ${cell_list}   COAM Get Cell List   connection=${connection}
#     :FOR   ${cell}   IN   @{cell_list}
#        ${status}   Set Variable   ${cell['status']}
#        Run Keyword and Continue on Failure   COAM Check Dedicated Cell Status   status=${status}
#     END
#
# COAM Get Cell List
#     [Arguments]   ${connection}=COAM
#     ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
#     ${cell_list}   Run Keyword If   ${bts_info.has_key('requestMessage')}
#     ...   Set Variable   ${bts_info['requestMessage']['cells']['nr']}
#     ...   ELSE   Set Variable   ${bts_info['cells']['nr']}
#     [Return]   ${cell_list}
#
# COAM Check Dedicated Cell Status
#     [Arguments]   ${status}
#     Should Contain   ${status['proceduralStatus']}   configured
#     Should Contain   ${status['availabilityStatus']}   Online
#     Should Contain   ${status['operationalState']}   Enabled
#     Should Contain   ${status['usageState']}   Active
#
# COAM Get RMOD List
#     [Arguments]    ${SN}=AH204600551
#     coam.connect_to    bts_host=${DU_OAM_IP_TL}   name=${connection}
#     ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10    connection=${connection}
#     ${RMOD_List}    Set Variable    ${bts_info['radioModules']['rmod']}
#     :FOR   ${RU}   IN   @{RMOD_List}
#        ${serialNumber}   Set Variable   ${RU['serialNumber']}
#        ${serialNumber}  strip_string    ${serialNumber}
#        log to console    ${serialNumber}
#        ${id}   Set Variable   ${RU['id']}
#        ${id}   Set Variable   ${id['configuration']}
#        log to console    ${id}
#        Run Keyword If    '${SN}'=='${serialNumber}'    reset RMOD    ID=${id}
#        exit for loop if    '${SN}'=='${serialNumber}'
#     END
#     [Teardown]    Logout
#
# reset RMOD
#     [Arguments]    ${ID}    ${reset_type}=Soft    ${force}=True
#     log to console    start reset RU
#     ${RMOD_distname}=     Catenate    ${ID}
#     coam.reset_unit    dist_name=${RMOD_distname}    reset_type=Hard    force_radio_reset=True    timeout=300
#     ...    connection=${connection}