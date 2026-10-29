*** Settings ***
Documentation    author：Kaijia.chen
...              contact: kaijia.chen@nokia-sbell.com
...              squad group: mmw_SG_04


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    ${CURDIR}/../../CB009183_TL709/Resources/CB009183_TL709_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.hw.rf_attenuator    WITH NAME    att
Library           taf.selenium.gnb.oam.coam.classical    WITH NAME    selenium
Library           taf.ue  WITH NAME   ute_ue

*** Variables ***
${DU_OAM_IP_TL}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_HTTP_USERNAME_TL}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_HTTP_PASSWORD_TL}     ${tl.gnbs[0].cu.oam_http_connection_details.password}

${DU_OAM_SSH_USERNAME_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${instance_id}               ${tl.gnbs[0].instance_id}

${RU_SSH_USERNAME}      ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
${RU_SSH_PASSWORD}      ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
${RU_SSH_USERNAME_1}      ${tl.gnbs[0].dus[0].rus[1].default_ssh_connection_details.username}
${RU_SSH_PASSWORD_1}      ${tl.gnbs[0].dus[0].rus[1].default_ssh_connection_details.password}

${connection}                 GNB_OAM
${connection1}                GNB_OAM1
${asik_alias}                 ASIK Master
${AlarmInfo1}            Radio's input voltage is 56.01V, higher or equal to configured threshold 56.01V (88%)
${AlarmInfo2}            Radio's input voltage is 56.999V, higher or equal to configured threshold 56.01V (88%)
${AlarmInfo3}            Radio's input voltage is 56.01V, higher or equal to configured threshold 54.525V (70%)
${AlarmInfo4}            Radio's input voltage is 41.49V, lower or equal to configured threshold 41.49V (-88%)
${AlarmInfo5}            Radio's input voltage is 40.55V, lower or equal to configured threshold 41.49V (-88%)
${AlarmInfo6}            Radio's input voltage is 41.49V, lower or equal to configured threshold 42.975V (-70%)

*** Keywords ***
check Critical FID2920 and check minor cancel
     log to console    **********************voltage=38000********************************
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2003R0188
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=38000
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2334R1777
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=38000
     sleep    45s
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${1}
     ...    white_list=${white_list_2920}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${False}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${2}
     ...    white_list=${white_list_2920}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${False}    connection=${connection}

     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7100}    ru_index=${1}
     ...    white_list=${white_list_2920}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Critical    check=${True}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7100}    ru_index=${2}
     ...    white_list=${white_list_2920}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Critical    check=${True}    connection=${connection}

Reconfigure alVoltLowThresholdMinor and check alarm 2920
     log to console    **********************alVoltLowThresholdMinor == -70%********************************
     Modify Parameters with json    input_list=${alVoltLowThresholdMinor_para2}    bts_host=${DU_OAM_IP_TL}
     sleep    30s
     check RU alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${1}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     ...    AlarmInfo=${AlarmInfo6}    white_list=${white_list_2920}
     check RU alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${2}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     ...    AlarmInfo=${AlarmInfo6}    white_list=${white_list_2920}
     check RU alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${4}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     ...    AlarmInfo=${AlarmInfo6}    white_list=${white_list_2920}

     log to console    **********************alVoltLowThresholdMinor == -99%********************************
     Modify Parameters with json    input_list=${alVoltLowThresholdMinor_para3}    bts_host=${DU_OAM_IP_TL}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${1}    white_list=${white_list}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${False}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${2}    white_list=${white_list}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${False}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${4}    white_list=${white_list}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${False}    connection=${connection}

     log to console    **********************alVoltLowThresholdMinor == -88%********************************
     Modify Parameters with json    input_list=${alVoltLowThresholdMinor_para1}    bts_host=${DU_OAM_IP_TL}
     sleep    30s
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${1}
     ...    white_list=${white_list_2920}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${2}
     ...    white_list=${white_list_2920}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${4}
     ...    white_list=${white_list_2920}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${True}    connection=${connection}

     log to console    **********************alVoltLowThresholdMinor == 0%********************************
     Modify Parameters with json    input_list=${alVoltLowThresholdMinor_para4}    bts_host=${DU_OAM_IP_TL}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${1}    white_list=${white_list}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${False}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${2}    white_list=${white_list}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${False}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${4}    white_list=${white_list}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${False}    connection=${connection}

     log to console    **********************alVoltLowThresholdMinor == -88%********************************
     Modify Parameters with json    input_list=${alVoltLowThresholdMinor_para1}    bts_host=${DU_OAM_IP_TL}
     sleep    30s
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${1}
     ...    white_list=${white_list_2920}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${2}
     ...    white_list=${white_list_2920}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${4}
     ...    white_list=${white_list_2920}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${True}    connection=${connection}

config voltage=40550 and check 2920 alarm cancel
      log to console    **********************voltage=40550********************************
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2003R0188
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=40550
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2334R1777
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=40550
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME_1}    ru_sn=1M242908386
     ...    RU_PASSWORD=${RU_SSH_PASSWORD_1}    container_id=0x2018    voltage=40550

     check RU alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${1}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     ...    AlarmInfo=${AlarmInfo5}    white_list=${white_list_2920}
     check RU alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${2}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     ...    AlarmInfo=${AlarmInfo5}    white_list=${white_list_2920}
     check RU alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${4}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     ...    AlarmInfo=${AlarmInfo5}    white_list=${white_list_2920}

     log to console    **********************voltage=41500********************************
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2003R0188
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=41500
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2334R1777
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=41500
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME_1}    ru_sn=1M242908386
     ...    RU_PASSWORD=${RU_SSH_PASSWORD_1}    container_id=0x2018    voltage=41500

     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${1}    white_list=${white_list}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${False}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${2}    white_list=${white_list}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${False}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${4}    white_list=${white_list}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${False}    connection=${connection}

config alVoltHighThresholdMinor == -88% voltage=41490 and check 2920 alarm cancel
     log to console    **********************alVoltLowThresholdMinor == -88%********************************
     Modify Parameters with json    input_list=${alVoltLowThresholdMinor_para1}    bts_host=${DU_OAM_IP_TL}
     check cell onair    BTS_IP=${DU_OAM_IP_TL}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${1}    white_list=${white_list}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${False}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${2}    white_list=${white_list}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${False}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${4}    white_list=${white_list}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${False}    connection=${connection}

     log to console    **********************voltage=41490*******************************
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2003R0188
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=41490
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2334R1777
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=41490
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME_1}    ru_sn=1M242908386
     ...    RU_PASSWORD=${RU_SSH_PASSWORD_1}    container_id=0x2018    voltage=41490

     sleep    30s

     check RU alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${1}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     ...    AlarmInfo=${AlarmInfo4}    white_list=${white_list_2920}
     check RU alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${2}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     ...    AlarmInfo=${AlarmInfo4}    white_list=${white_list_2920}
     check RU alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${4}
     ...    test_fault_ID=${2920}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     ...    AlarmInfo=${AlarmInfo4}    white_list=${white_list_2920}

check RU alarm
     [Arguments]    ${BTS_IP}    ${test_alarm_ID}    ${test_fault_ID}    ${test_alarm_Severity}    ${check}    ${ru_index}
     ...   ${AlarmInfo}    ${connection}=GNB_OAM    ${white_list}=white_list
     log to console    start check RU${ru_index} alarm
     sleep    5s
     coam.connect_to    bts_host=${BTS_IP}   name=${connection}
     ${alarms}    coam.get_active_alarms    connection=${connection}
     sleep    1s
     log     ${alarms}
     ${status}    Set Variable    ${False}
     FOR    ${item}    IN    @{alarms}
          ${fault_id}    get from dictionary    ${item}    faultId
          ${status}    Run Keyword And Return Status    list should contain value     ${white_list}    ${faultId}
          Run Keyword if    ${status} == ${False}    Save TL Snapshot
          Should Be Equal as strings    ${status}    ${True}
     END
     FOR    ${item}    IN    @{alarms}
          ${ObjectName}    get from dictionary    ${item}    configObjectName
          ${alarm_id}    get from dictionary    ${item}    alarmId
          ${fault_id}    get from dictionary    ${item}    faultId
          ${fault_Severity}    get from dictionary    ${item}    faultSeverity
          ${alarmText}  get from dictionary    ${item}   alarmText
          ${alarmAdditionalInfo}  get from dictionary    ${alarmText}    alarmAdditionalInfo
          ${supplAlarmInfo}  get from dictionary    ${alarmAdditionalInfo}   supplAlarmInfo
          list should not contain value     ${Trunk_roll_list}    ${faultId}
          log to console     ${supplAlarmInfo}
          ${status}    Run Keyword If

          ...    '${ALARM_RU_NAME1}${ru_index}'=='${ObjectName}' and '${alarm_id}'=='${test_alarm_ID}'    Compare RU alarm detail
          ...    alarm_id=${alarm_id}    fault_id=${fault_id}    fault_Severity=${fault_Severity}
          ...    test_alarm_ID=${test_alarm_ID}    test_fault_ID=${test_fault_ID}     test_alarm_Severity=${test_alarm_Severity}
          ...    supplAlarmInfo= ${supplAlarmInfo}  AlarmInfo=${AlarmInfo}
           Exit For Loop If    '${status}'=='${True}'
     END
     Run Keyword If    '${status}'=='None'    Set Suite Variable    ${status}    ${False}
     ${status}    Run Keyword And Return Status    Should Be Equal as strings    ${status}    ${check}
     Run Keyword if    ${status} == ${False}    Save TL Snapshot
     Should Be Equal as strings    ${status}    ${True}
     [Teardown]    Logout

Compare RU alarm detail
    [Arguments]    ${alarm_id}    ${fault_id}    ${fault_Severity}    ${supplAlarmInfo}    ${AlarmInfo}
    ...    ${test_alarm_ID}    ${test_fault_ID}    ${test_alarm_Severity}
    should be equal    ${alarm_id}            ${test_alarm_ID}
    should be equal    ${fault_id}            ${test_fault_ID}
    should be equal    ${fault_Severity}      ${test_alarm_Severity}
    Should Be Equal    '${supplAlarmInfo.lstrip(' ')}'    '${AlarmInfo}'
    ${status}    Set Variable    ${True}
    [Return]    ${status}

config alVoltHighThresholdMinor == 88% voltage=56010 and set volt to trigger 2919 alarm
     Modify Parameters with json    input_list=${alVoltHighThresholdMinor_para1}    bts_host=${DU_OAM_IP_TL}
     check cell onair    BTS_IP=${DU_OAM_IP_TL}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${1}    white_list=${white_list}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${False}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${2}    white_list=${white_list}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${False}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${4}    white_list=${white_list}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${False}    connection=${connection}

     log to console    **********************voltage=56010********************************
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2003R0188
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=56010
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2334R1777
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=56010
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME_1}    ru_sn=1M242908386
     ...    RU_PASSWORD=${RU_SSH_PASSWORD_1}    container_id=0x2018    voltage=56010

     sleep    30s

     check RU alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${1}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     ...    AlarmInfo=${AlarmInfo1}    white_list=${white_list_2919}
     check RU alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${2}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     ...    AlarmInfo=${AlarmInfo1}    white_list=${white_list_2919}
     check RU alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${4}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     ...    AlarmInfo=${AlarmInfo1}    white_list=${white_list_2919}

config voltage=56999 and check 2919 alarm voltage 56V cancelled
     log to console    **********************voltage=56999********************************
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2003R0188
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=56999
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2334R1777
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=56999
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME_1}    ru_sn=1M242908386
     ...    RU_PASSWORD=${RU_SSH_PASSWORD_1}    container_id=0x2018    voltage=56999

     check RU alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${1}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     ...    AlarmInfo=${AlarmInfo2}    white_list=${white_list_2919}
     check RU alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${2}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     ...    AlarmInfo=${AlarmInfo2}    white_list=${white_list_2919}
     check RU alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${4}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     ...    AlarmInfo=${AlarmInfo2}    white_list=${white_list_2919}

     log to console    **********************voltage=56000********************************
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2003R0188
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=56000
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2334R1777
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=56000
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME_1}    ru_sn=1M242908386
     ...    RU_PASSWORD=${RU_SSH_PASSWORD_1}    container_id=0x2018    voltage=56000

     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${1}    white_list=${white_list}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${False}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${2}    white_list=${white_list}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${False}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${4}    white_list=${white_list}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${False}    connection=${connection}

Reconfigure alVoltHighThresholdMinor and check alarm
     log to console    **********************alVoltHighThresholdMinor == 70%********************************
     Modify Parameters with json    input_list=${alVoltHighThresholdMinor_para2}    bts_host=${DU_OAM_IP_TL}
     sleep    30s
     check RU alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${1}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     ...    AlarmInfo=${AlarmInfo3}    white_list=${white_list_2919}
     check RU alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${2}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     ...    AlarmInfo=${AlarmInfo3}    white_list=${white_list_2919}
     check RU alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${4}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     ...    AlarmInfo=${AlarmInfo3}    white_list=${white_list_2919}

     log to console    **********************alVoltHighThresholdMinor == 106%********************************
     Modify Parameters with json    input_list=${alVoltHighThresholdMinor_para3}    bts_host=${DU_OAM_IP_TL}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${1}     white_list=${white_list}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${False}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${2}     white_list=${white_list}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${False}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${4}     white_list=${white_list}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${False}    connection=${connection}

     log to console    **********************alVoltHighThresholdMinor == 88%********************************
     Modify Parameters with json    input_list=${alVoltHighThresholdMinor_para1}    bts_host=${DU_OAM_IP_TL}
     sleep    30s
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${1}
     ...    white_list=${white_list_2919}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${2}
     ...    white_list=${white_list_2919}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${True}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${4}
     ...    white_list=${white_list_2919}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${True}    connection=${connection}

check Critical FID2919 and check minor cancel
     log to console    **********************voltage=59000********************************
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2003R0188
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=59000
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2334R1777
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=59000
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME_1}    ru_sn=1M242908386
     ...    RU_PASSWORD=${RU_SSH_PASSWORD_1}    container_id=0x2018    voltage=59000

     sleep    40s
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${1}
     ...    white_list=${white_list_2919}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${False}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${2}
     ...    white_list=${white_list_2919}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${False}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7115}    ru_index=${4}
     ...    white_list=${white_list_2919}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Minor    check=${False}    connection=${connection}

     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7100}    ru_index=${1}
     ...    white_list=${white_list_2919}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Critical    check=${True}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7100}    ru_index=${2}
     ...    white_list=${white_list_2919}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Critical    check=${True}    connection=${connection}
     check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7100}    ru_index=${4}
     ...    white_list=${white_list_2919}
     ...    test_fault_ID=${2919}    test_alarm_Severity=Critical    check=${True}    connection=${connection}

config alVoltHighThreshold to 116% and set volt to trigger 2919 alarm
     modify parameter and check alarm    input_list=${alVoltHighThreshold_para1}   test_fault_ID1=${2919}    test_fault_ID2=${2919}
     ...    test_fault_ID4=${2919}    check=${false}    test_alarm_Severity=Critical    status=${True}    white_list=${white_list}
     login RU to trigger and check alarm    voltage1=59000    voltage2=59000    voltage4=59000    check=${True}    test_fault_ID1=${2919}
     ...    test_alarm_ID=${7100}    test_alarm_Severity=Critical    white_list=${white_list_2919}    test_fault_ID2=${2919}
     ...    test_fault_ID4=${2919}

set 58.5 volt and wait 5min to recover 2919 alarm
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2003R0188
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=58500
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2334R1777
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=58500
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME_1}    ru_sn=1M242908386
     ...    RU_PASSWORD=${RU_SSH_PASSWORD_1}    container_id=0x2018    voltage=58500

     log to console    sleep 5min
     sleep    5min

     check fault alarm    BTS_IP=${DU_OAM_IP_TL}     test_alarm_ID=${7100}    test_fault_ID=${2919}    ru_index=${1}
     ...    test_alarm_Severity=Critical    check=${False}    white_list=${white_list}
     check fault alarm    BTS_IP=${DU_OAM_IP_TL}     test_alarm_ID=${7100}    test_fault_ID=${2919}    ru_index=${2}
     ...    test_alarm_Severity=Critical    check=${False}    white_list=${white_list}
     check fault alarm    BTS_IP=${DU_OAM_IP_TL}     test_alarm_ID=${7100}    test_fault_ID=${2919}    ru_index=${4}
     ...    test_alarm_Severity=Critical    check=${False}    white_list=${white_list}

config different alVoltHighThreshold parameter to trigger or recover 2919 alarm
     modify parameter and check alarm    input_list=${alVoltHighThreshold_para2}   test_fault_ID1=${2919}    test_fault_ID2=${2919}
     ...    test_fault_ID4=${2919}    check=${False}    test_alarm_Severity=Critical    white_list=${white_list}
     modify parameter and check alarm    input_list=${alVoltHighThreshold_para3}   test_fault_ID1=${2919}    test_fault_ID2=${2919}
     ...    test_fault_ID4=${2919}    check=${True}    test_alarm_Severity=Critical    white_list=${white_list_2919}
     modify parameter and check alarm    input_list=${alVoltHighThreshold_para4}   test_fault_ID1=${2919}    test_fault_ID2=${2919}
     ...    test_fault_ID4=${2919}    check=${False}    test_alarm_Severity=Critical    white_list=${white_list}

config alVoltLowThreshold to -111% and set volt to trigger 2920 alarm
     modify parameter and check alarm    input_list=${alVoltLowThreshold_para1}   test_fault_ID1=${2920}    test_fault_ID2=${2920}
     ...    test_fault_ID4=${2920}    check=${False}    test_alarm_Severity=Critical    status=${True}    white_list=${white_list}

     login RU to trigger and check alarm    voltage1=38500    voltage2=38500    voltage4=38500    check=${True}    test_fault_ID1=${2920}
     ...    test_alarm_ID=${7100}    test_alarm_Severity=Critical    white_list=${white_list_2920}    test_fault_ID2=${2920}
     ...    test_fault_ID4=${2920}

set 38.6 volt and wait 5min to recover 2920 alarm
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2003R0188
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=38600
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2334R1777
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=38600
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME_1}    ru_sn=1M242908386
     ...    RU_PASSWORD=${RU_SSH_PASSWORD_1}    container_id=0x2018    voltage=38600

     log to console    sleep 5min
     sleep    5min

     check fault alarm    BTS_IP=${DU_OAM_IP_TL}     test_alarm_ID=${7100}    test_fault_ID=${2920}    ru_index=${1}
     ...    test_alarm_Severity=Critical    check=${False}    white_list=${white_list}
     check fault alarm    BTS_IP=${DU_OAM_IP_TL}     test_alarm_ID=${7100}    test_fault_ID=${2920}    ru_index=${2}
     ...    test_alarm_Severity=Critical    check=${False}    white_list=${white_list}
     check fault alarm    BTS_IP=${DU_OAM_IP_TL}     test_alarm_ID=${7100}    test_fault_ID=${2920}    ru_index=${4}
     ...    test_alarm_Severity=Critical    check=${False}    white_list=${white_list}

config different alVoltLowThreshold parameter to trigger or recover 2920 alarm
     modify parameter and check alarm    input_list=${alVoltLowThreshold_para2}   test_fault_ID1=${2920}    test_fault_ID2=${2920}
     ...    test_fault_ID4=${2920}    check=${False}    test_alarm_Severity=Critical    white_list=${white_list}
     modify parameter and check alarm    input_list=${alVoltLowThreshold_para3}   test_fault_ID1=${2920}    test_fault_ID2=${2920}
     ...    test_fault_ID4=${2920}    check=${True}    test_alarm_Severity=Critical    white_list=${white_list_2920}
     modify parameter and check alarm    input_list=${alVoltLowThreshold_para4}   test_fault_ID1=${2920}    test_fault_ID2=${2920}
     ...    test_fault_ID4=${2920}    check=${False}    test_alarm_Severity=Critical    white_list=${white_list}

config alVoltUnstableThreshold to 2 and set volt to trigger 2919 and 2920 alarm
     modify parameter and check alarm    input_list=${alVoltUnstableThreshold_para1}   test_fault_ID1=${2920}
     ...    test_fault_ID2=${2920}    test_fault_ID4=${2920}
     ...    check=${False}    test_alarm_Severity=Critical    status=${True}    white_list=${white_list}
     login RU to trigger and check alarm    voltage1=36000    voltage2=60000    voltage4=60000    check=${True}    test_fault_ID1=${2920}
     ...    test_fault_ID2=${2919}    test_fault_ID4=${2919}
     ...    test_alarm_ID=${7100}    test_alarm_Severity=Critical    white_list=${white_list_4680}

set 50v and wait 5min to recover 2919 and 2920 alarm
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2003R0188
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=50000
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2334R1777
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=50000
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME_1}    ru_sn=1M242908386
     ...    RU_PASSWORD=${RU_SSH_PASSWORD_1}    container_id=0x2018    voltage=50000

     log to console    sleep 5min
     sleep    5min

     check fault alarm    BTS_IP=${DU_OAM_IP_TL}     test_alarm_ID=${7100}    test_fault_ID=${2920}    ru_index=${1}
     ...    test_alarm_Severity=Critical    check=${False}    white_list=${white_list}
     check fault alarm    BTS_IP=${DU_OAM_IP_TL}     test_alarm_ID=${7100}    test_fault_ID=${2919}    ru_index=${2}
     ...    test_alarm_Severity=Critical    check=${False}    white_list=${white_list}
     check fault alarm    BTS_IP=${DU_OAM_IP_TL}     test_alarm_ID=${7100}    test_fault_ID=${2919}    ru_index=${4}
     ...    test_alarm_Severity=Critical    check=${False}    white_list=${white_list}

set 36v on RMOD1 and 60v on RMOD 2 to trigger 4680 alarm
    login RU to trigger and check alarm    voltage1=36000    voltage2=60000    voltage4=60000    check=${True}    test_fault_ID1=${4680}
     ...    test_alarm_ID=${7100}    test_alarm_Severity=Critical    white_list=${white_list_4680}    test_fault_ID2=${4680}
     ...    test_fault_ID4=${4680}

set 50v and config alVoltUnstableThreshold to 1 recover 4680 alarm
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2003R0188
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=50000
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2334R1777
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=50000
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME_1}    ru_sn=1M242908386
     ...    RU_PASSWORD=${RU_SSH_PASSWORD_1}    container_id=0x2018    voltage=50000

     Modify Parameters with json1    input_list=${alVoltUnstableThreshold_para2}    bts_host=${DU_OAM_IP_TL}

     check fault alarm    BTS_IP=${DU_OAM_IP_TL}     test_alarm_ID=${7100}    test_fault_ID=${4680}    ru_index=${1}
     ...    test_alarm_Severity=Critical    check=${False}    white_list=${white_list}
     check fault alarm    BTS_IP=${DU_OAM_IP_TL}     test_alarm_ID=${7100}    test_fault_ID=${4680}    ru_index=${2}
     ...    test_alarm_Severity=Critical    check=${False}    white_list=${white_list}
     check fault alarm    BTS_IP=${DU_OAM_IP_TL}     test_alarm_ID=${7100}    test_fault_ID=${4680}    ru_index=${4}
     ...    test_alarm_Severity=Critical    check=${False}    white_list=${white_list}

modify parameter and check alarm
     [Arguments]    ${input_list}    ${check}    ${test_fault_ID1}    ${test_fault_ID2}    ${test_fault_ID4}
     ...    ${test_alarm_Severity}=Critical    ${status}=${false}    ${white_list}=white_list
     Modify Parameters with json1    input_list=${input_list}    bts_host=${DU_OAM_IP_TL}
     Run Keyword If  '${status}' == 'True'    check cell onair    BTS_IP=${DU_OAM_IP_TL}
     sleep     5s
     wait until keyword succeeds    60s    10 s    check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7100}    ru_index=${1}
     ...    test_fault_ID=${test_fault_ID1}    test_alarm_Severity=${test_alarm_Severity}    check=${check}    connection=${connection}
     ...    white_list=${white_list}
     wait until keyword succeeds    60s    10 s    check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7100}    ru_index=${2}
     ...    test_fault_ID=${test_fault_ID2}    test_alarm_Severity=${test_alarm_Severity}    check=${check}    connection=${connection}
     ...    white_list=${white_list}
     wait until keyword succeeds    60s    10 s    check active alarm    BTS_IP=${DU_OAM_IP_TL}    test_alarm_ID=${7100}    ru_index=${4}
     ...    test_fault_ID=${test_fault_ID4}    test_alarm_Severity=${test_alarm_Severity}    check=${check}    connection=${connection}
     ...    white_list=${white_list}

login RU to trigger and check alarm
    [Arguments]    ${voltage1}    ${voltage2}    ${voltage4}    ${check}    ${test_fault_ID1}    ${test_fault_ID2}    ${test_fault_ID4}
    ...    ${test_alarm_ID}    ${test_alarm_Severity}    ${white_list}
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2003R0188
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=${voltage1}
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME}    ru_sn=EB2334R1777
     ...    RU_PASSWORD=${RU_SSH_PASSWORD}    container_id=0x2018    voltage=${voltage2}
     login RU to trigger alarm    RU_USERNAME=${RU_SSH_USERNAME_1}    ru_sn=1M242908386
     ...    RU_PASSWORD=${RU_SSH_PASSWORD_1}    container_id=0x2018    voltage=${voltage4}

     sleep    45s

     check fault alarm    BTS_IP=${DU_OAM_IP_TL}     test_alarm_ID=${test_alarm_ID}    test_fault_ID=${test_fault_ID1}
     ...    ru_index=${1}    test_alarm_Severity=${test_alarm_Severity}    check=${check}    white_list=${white_list}
     check fault alarm    BTS_IP=${DU_OAM_IP_TL}     test_alarm_ID=${test_alarm_ID}    test_fault_ID=${test_fault_ID2}
     ...    ru_index=${2}    test_alarm_Severity=${test_alarm_Severity}    check=${check}    white_list=${white_list}
     check fault alarm    BTS_IP=${DU_OAM_IP_TL}     test_alarm_ID=${test_alarm_ID}    test_fault_ID=${test_fault_ID4}
     ...    ru_index=${4}    test_alarm_Severity=${test_alarm_Severity}    check=${check}    white_list=${white_list}

CI_interface common setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Check allow alarm list    allowed_list=${white_list}    bts_host=${DU_OAM_IP_TL}

Case Setup 9903
    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=2919
    AlarmWatchdog.add_allow_alarms    fault_id=2920

Case Teardown 9903
    [Arguments]
    AlarmWatchdog.remove_allow_alarms    fault_id=2919
    AlarmWatchdog.remove_allow_alarms    fault_id=2920
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown

Check allow alarm list
    [Arguments]    ${bts_host}    ${allowed_list}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    connection=${connection}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}    connection=${connection}
    [Teardown]    coam.teardown    connection=${connection}

login RU to trigger alarm
     [Arguments]    ${RU_USERNAME}    ${RU_PASSWORD}    ${container_id}    ${voltage}    ${ru_sn}
     log to console    login RU:${ru_sn} to trigger alarm
#     ${Serial_number}    Get ru info    bts_host=${DU_OAM_IP_TL}    ru_index=${ru_index}
     csn.connect_to
     ...    hostname=${DU_OAM_IP_TL}
     ...    username=${DU_OAM_SSH_USERNAME_TL}
     ...    password=${DU_OAM_SSH_PASSWORD_TL}
     ...    alias=${asik_alias}
     csn.Send Command    command=cat /ffs/run/config/FRIps.txt |grep ${ru_sn}|cut -d ';' -f 3|head -1|tail -n 1
     ...    connection=${asik_alias}
     ${RU_IP}    csn.Read Output    connection=${asik_alias}
     Should Not Be Empty  ${RU_IP}
     ${RU_IP}    strip_string    ${RU_IP}
     log to console    RU_IP：${RU_IP}

     ${ru_alias}    Connect To TL RU    ru_ip_addr=${RU_IP}
     ...    container_id=${container_id}
     ...    asik_alias=${asik_alias}
     ...    ru_username=${RU_USERNAME}
     ...    ru_password=${RU_PASSWORD}

     ${connection_ru}    csn.get_connection_by_alias    alias=${ru_alias}
     ${channel}    Call Method    ${connection_ru}    invoke_shell
     Call Method    ${channel}    send    rad -mw 0x110032 ${voltage}\n
     sleep    3 sec
     ${output}    Call Method    ${channel}    recv    ${65535}
     ${output}    Convert To String    ${output}
     log to console    RU:${ru_sn} trigger alarm successful
     [Teardown]    csn.disconnect    connection=${asik_alias}

Connect To TL RU
    [Arguments]    ${ru_ip_addr}    ${container_id}=0x2018    ${container_alias}=Container    ${ru_alias}=RU
    ...            ${asik_alias}=ASIK Master    ${fhnet_host_ip}=192.168.255.254
    ...            ${ru_username}=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
    ...            ${ru_password}=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
    ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
    ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
    ...                                            Sleep    3 sec    AND
    ...                                            Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    close
    csn.connect to    hostname=${fhnet_host_ip}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${container_alias}
    ...               proxy=${asik_alias}
    csn.connect to
    ...               hostname=${ru_ip_addr}
    ...               username=${ru_username}
    ...               password=${ru_password}
    ...               alias=${ru_alias}
    ...               proxy=${container_alias}
    [Return]    ${ru_alias}

Login Page Via WebUI
    selenium.enable_virtual_display
    selenium.login    url=https://${DU_OAM_IP_TL}   username=${DU_OAM_HTTP_USERNAME_TL}    password=${DU_OAM_HTTP_PASSWORD_TL}
    selenium.disable_message_box
    selenium.disable_screen_lock

Logout
     run keyword and ignore error    csn.disconnect    connection=${ru_alias}
     run keyword and ignore error    csn.disconnect    connection=${asik_alias}
     run keyword and ignore error    csn.disconnect    connection=${connection_ru}
     run keyword and ignore error    coam.teardown    connection=${connection}
     run keyword and ignore error    selenium.logout

check fault alarm
     [Arguments]    ${BTS_IP}    ${test_alarm_ID}    ${test_fault_ID}
     ...    ${test_alarm_Severity}    ${ru_index}    ${check}    ${white_list}=white_list
     log to console    check RU${ru_index} alarm...
     sleep   10s
     ${status}    Run Keyword And Return Status     wait until keyword succeeds    30s    10 s    check active alarm
     ...    BTS_IP=${BTS_IP}    test_alarm_ID=${test_alarm_ID}    white_list=${white_list}
     ...    test_fault_ID=${test_fault_ID}    test_alarm_Severity=${test_alarm_Severity}    ru_index=${ru_index}
     ...    check=${check}    connection=${connection}
     Run Keyword if    ${status} == ${False}    Save TL Snapshot
     Should Be Equal as strings    ${status}    ${True}
     log to console    check RU${ru_index} alarm successful

check active alarm
     [Arguments]    ${BTS_IP}    ${test_alarm_ID}    ${test_fault_ID}    ${test_alarm_Severity}    ${check}    ${ru_index}
     ...    ${connection}=GNB_OAM    ${white_list}=white_list
     log to console    start check RU${ru_index} alarm
     coam.connect_to    bts_host=${BTS_IP}   name=${connection}
     ${alarms}    coam.get_active_alarms    connection=${connection}
     sleep    1s
     log     ${alarms}
     ${status}    Set Variable    ${False}
     FOR    ${item}    IN    @{alarms}
          ${fault_id}    get from dictionary    ${item}    faultId
          ${status}    Run Keyword And Return Status    list should contain value     ${white_list}    ${faultId}
          Run Keyword if    ${status} == ${False}    Save TL Snapshot
          Should Be Equal as strings    ${status}    ${True}
     END
     FOR    ${item}    IN    @{alarms}
          ${ObjectName}    get from dictionary    ${item}    configObjectName
          ${alarm_id}    get from dictionary    ${item}    alarmId
          ${fault_id}    get from dictionary    ${item}    faultId
          ${fault_Severity}    get from dictionary    ${item}    faultSeverity
          ${status}    Run Keyword If
          ...    '${ALARM_RU_NAME1}${ru_index}'=='${ObjectName}' and '${alarm_id}'=='${test_alarm_ID}'    Compare alarm detail
          ...    alarm_id=${alarm_id}    fault_id=${fault_id}    fault_Severity=${fault_Severity}
          ...    test_alarm_ID=${test_alarm_ID}    test_fault_ID=${test_fault_ID}     test_alarm_Severity=${test_alarm_Severity}
           Exit For Loop If    '${status}'=='${True}'
     END
     Run Keyword If    '${status}'=='None'    Set Suite Variable    ${status}    ${False}
     Should Be Equal as strings    ${status}    ${check}
     log to console    check RU${ru_index} alarm successful
#     ${status}    Run Keyword And Return Status    Should Be Equal as strings    ${status}    ${check}
     [Teardown]    Save log

Save log
    coam.teardown    connection=${connection}

Compare alarm detail
    [Arguments]    ${alarm_id}    ${fault_id}    ${fault_Severity}
    ...    ${test_alarm_ID}    ${test_fault_ID}    ${test_alarm_Severity}
    should be equal    ${alarm_id}            ${test_alarm_ID}
    should be equal    ${fault_id}            ${test_fault_ID}
    should be equal    ${fault_Severity}      ${test_alarm_Severity}
    ${status}    Set Variable    ${True}
    [Return]    ${status}

Check voltage
     [Arguments]    ${voltage}    ${ru_index}
     log to console    Check voltage..
     ${Serial_number}    ${radio_voltage}    Get RU type and Voltage    ru_index=${ru_index}
     should be equal as strings    ${radio_voltage}    ${voltage}

Recover action
     log to console    recover action...
#     Modify Parameters with json1    input_list=${recoover_para}    bts_host=${DU_OAM_IP_TL}
#     Reset RMOD    ID=${MR_BTS_RU_NAME1}
#     Reset RMOD    ID=${MR_BTS_RU_NAME2}
     Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save TL Snapshot
     Setup Commission SCF1    bts_host=${DU_OAM_IP_TL}
     check cell status and save log
     [Teardown]    Case Teardown 9903

check cell status and save log
     wait until keyword succeeds    15 min    10 s    check cell onair    BTS_IP=${DU_OAM_IP_TL}
     [Teardown]    save cell status log

save cell status log
     ${status}=    Run Keyword And Return Status    check cell onair    BTS_IP=${DU_OAM_IP_TL}
     Run Keyword if    ${status} == ${False}    Save TL Snapshot

check cell onair
     [Arguments]    ${BTS_IP}
     log to console    check cell status
     coam.connect_to    bts_host=${BTS_IP}   name=${connection}
     COAM Check All Cells Onair
     [Teardown]    coam.teardown    connection=${connection}

COAM Check All Cells Onair
     [Arguments]   ${connection}=${connection}
     ${cell_list}   COAM Get Cell List   connection=${connection}
     FOR   ${cell}   IN   @{cell_list}
        ${status}   Set Variable   ${cell['status']}
        log    ${status}
       Run Keyword and Continue on Failure   COAM Check Dedicated Cell Status   status=${status}
     END

COAM Get Cell List
     [Arguments]   ${connection}=COAM
     ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
     ${cell_list}   Set Variable   ${bts_info['cells']['nr']}
     [Return]   ${cell_list}

COAM Check Dedicated Cell Status
     [Arguments]   ${status}
     Should Contain   ${status['proceduralStatus']}   configured
     Should Contain   ${status['operationalState']}   enabled
     Should Contain   ${status['usageState']}   Active

COAM Get RMOD List
     [Arguments]    ${SN}=AH204600551
     coam.connect_to    bts_host=${DU_OAM_IP_TL}   name=${connection}
     ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10    connection=${connection}
     ${RMOD_List}    Set Variable    ${bts_info['radioModules']['rmod']}
     FOR   ${RU}   IN   @{RMOD_List}
        ${serialNumber}   Set Variable   ${RU['serialNumber']}
        ${serialNumber}  strip_string    ${serialNumber}
        log to console    ${serialNumber}
        ${id}   Set Variable   ${RU['id']}
        ${id}   Set Variable   ${id['configuration']}
        log to console    ${id}
        Run Keyword If    '${SN}'=='${serialNumber}'    reset RMOD    ID=${id}
        exit for loop if    '${SN}'=='${serialNumber}'
     END
     [Teardown]    coam.teardown    connection=${connection}

Reset RMOD
     [Arguments]    ${ID}
     log to console    start reset RU
     coam.connect_to    bts_host=${DU_OAM_IP_TL}   name=${connection}
     ${RMOD_distname}=     Catenate    ${ID}
     coam.reset_unit    dist_name=${RMOD_distname}    reset_type=Hard    force_radio_reset=True    timeout=300
     ...    connection=${connection}
     [Teardown]    coam.teardown    connection=${connection}

Get RU type and Voltage
    [Arguments]    ${ru_index}=1
    Login Page Via WebUI
    ${ru_info}    selenium.get_ru_info    ru_index=${ru_index}
    log    ${ru_info}
    ${Serial_number}    set variable    ${ru_info}[Serial number]
    ${radio_voltage}    set variable    ${ru_info}[Voltage]
    ${match}   ${radio_voltage}   Should Match Regexp   ${radio_voltage}   (\\d+) mV
    log to console    radio${ru_index}_SN:${Serial_number}
    log to console    radio${ru_index}_voltage:${radio_voltage}
    [Return]    ${Serial_number}    ${radio_voltage}
    [Teardown]    selenium.logout

Modify Parameters with json1
    [Timeout]  10min
    [Arguments]    ${input_list}    ${bts_host}    ${delta_id}=update_parameter    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    connection=${connection}
    coam.create_delta    delta_id=${delta_id}
    FOR    ${item}  IN    @{input_list}
        ${operation}    get from dictionary    ${item}    operation
        Run keyword if    '${operation}'=='update'
        ...    coam.append_parameter_update_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    value=${item['value']}    delta_id=${delta_id}
        Run keyword if    '${operation}'=='delete'
        ...    coam.append_parameter_delete_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    delta_id=${delta_id}
        Log to console    Add task - ${operation}: ${item['dist_name']}.${item['parameter']}
    END
    ${delta_file}    coam.get_delta    delta_id=${delta_id}
    ${timeout}    set variable    480
    Log to console    Perform parameters via delta_id:${delta_id} is ongoing, timeout ${timeout}s.
    coam.perform_delta_recommissioning
    ...    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${timeout}
    ...    connection=${connection}
    Log to console    Perform parameters done.
    sleep    5s
    run keyword and ignore error    coam.remove_delta    delta_id=${delta_id}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

Set default SCF1
    [Arguments]      ${bts_host}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
    ${version_scf}    run keyword if    '${version_list[2]}'=='9999'    Set Variable    SBTS00
    ...    ELSE   Set Variable    ${version_list[0]}
    ${default_scf_path}    set variable    ${CURDIR_path}/SCF_${version_scf}.xml
    set suite variable    ${default_scf_path}
    log to console   ${default_scf_path}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Setup Commission SCF1
    [Arguments]  ${bts_host}    ${connection}=GNB_OAM
    Adapt to ute cloud commission scf1
    Set default SCF1    bts_host=${bts_host}
    Connect to gnb coam via ssl    bts_host=${bts_host}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf_path}    connection=${connection}    timeout=1000
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Adapt to ute cloud commission scf1
    ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TLNAME}   Set Variable    7_5${TLNAME}[0]
    Set Suite Variable    ${CURDIR_path}    ${CURDIR}/../../../../../../commissionings/HGZ/${TLNAME}

Save TL Snapshot
    [Arguments]    ${connection}=cOAM    ${timeout}=10min
    log to console    Save Snapshot...
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP_TL}    connection=${connection}
    ${snapshot_path}    coam.Get Snapshot From BTS    alias=${connection}    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}

Get ru info
    [Arguments]  ${bts_host}    ${ru_index}=1    ${connection}=GNB_OAM
    ${Serial_number_list}    Create list
    Connect to gnb coam via ssl    bts_host=${bts_host}    connection=${connection}
    ${bts_info}    coam.get_bts_info    connection=${connection}
    ${Serial_number_Tmp}    set variable    ${bts_info['radioModules']['rmod']}
    FOR  ${item}  IN  @{Serial_number_Tmp}
        ${Serial_number}    set variable    ${item['serialNumber']}
        Append to list    ${Serial_number_list}    ${Serial_number}
    END
    ${ru_index}=    Evaluate    ${ru_index} - 1
    [Return]    ${Serial_number_list}[${ru_index}]
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
