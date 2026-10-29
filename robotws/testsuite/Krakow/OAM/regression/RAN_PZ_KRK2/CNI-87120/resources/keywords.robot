*** Settings ***
Documentation
...   File contains Robot variables and keywords to assist in performing common tasks
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Library     ute_syslog
Library     taf.transport.ssh  WITH NAME  ssh
Library     testsuite.Krakow.OAM.regression.RAN_PZ_KRK2.CNI-87120.resources.helpers
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

*** Variables ***
${IP_ADDR}              192.168.255.129
${USERNAME}             toor4nsn
${PASSWORD}             oZPS0POrRieRtu
${SSH_FAN_COMMAMD}      for i in {1..80}; do echo '255' >/dev/ddal/fan/0/pwm; echo '255' > /dev/ddal/fan/1/pwm; sleep 1; done

*** Keywords ***
gNB SSH connect
    ssh.connect_to  hostname=${IP_ADDR}
    ...             username=${USERNAME}
    ...             password=${PASSWORD}

gNB SSH disconnect
    ssh.disconnect

Execute SSH command and verify that command was executed with no errors
    [Arguments]  ${command}
    ${ssh_output}  ssh.execute  command=${command}
    ssh.assert exit status  0
    [Return]  ${ssh_output}

CNI-87120 test setup
    Common preconditions with watching alarms

CNI-87120 test teardown
    Common postconditions with watching alarms

Wait for fan alarm status in syslog
    [Arguments]  ${status}  ${timeout}
    Wait for message in syslog file  regexp=Detector 4080 /MRBTS-[0-9]+/EQM-[0-9]+/SMOD-[0-9]+/FAN-1] ${status}
    ...                              timeout=${timeout}
    Wait for message in syslog file  regexp=Detector 4080 /MRBTS-[0-9]+/EQM-[0-9]+/SMOD-[0-9]+/FAN-2] ${status}
    ...                              timeout=10s
    Log to console  'Fan alarm ${status} in syslog'

Verify alarm in RawAlarmHistory file
    ssh.download_file  /tmp/RawAlarmHistory.txt
    ...                ${OUTPUTDIR}/RawAlarmHistory.txt
    Verify fan overspeed alarm exist in file  filepath=${OUTPUTDIR}/RawAlarmHistory.txt
    ...                                       expected_alarm_count=2

Perform test for alarm disabled
    [Arguments]  ${syslog_name}  ${dist_name}  ${param_name}  ${param_value}
    Log to console  'Testing with ${param_name} = ${param_value}'
    Start syslog  log_dir=${OUTPUTDIR}
    ...           log_name=${syslog_name}
    Perform configuration parameter recommissioning on gNB  dist_name=${dist_name}
    ...                                                     param_name=${param_name}
    ...                                                     param_value=${param_value}
    Execute SSH command and verify that command was executed with no errors  command=${SSH_FAN_COMMAMD}
    Wait for fan alarm status in syslog  status=active  timeout=10s
    Sleep  10s
    Verify alarm is not active on gNB  fault_name=Cooling fan is over speeding
    Wait for fan alarm status in syslog  status=inactive  timeout=120s
    Collect syslog results

Perform test for alarm enabled
    [Arguments]  ${syslog_name}  ${dist_name}  ${param_name}  ${param_value}
    Log to console  'Testing with ${param_name} = ${param_value}'
    Start syslog  log_dir=${OUTPUTDIR}
    ...           log_name=${syslog_name}
    gnb_alarm.Allow alarm    Cooling fan is over speeding
    Perform configuration parameter recommissioning on gNB  dist_name=${dist_name}
    ...                                                     param_name=${param_name}
    ...                                                     param_value=${param_value}
    Execute SSH command and verify that command was executed with no errors  command=${SSH_FAN_COMMAMD}
    Wait for fan alarm status in syslog  status=active  timeout=10s
    Sleep  10s
    Verify alarm is active on gNB  fault_name=Cooling fan is over speeding
    Wait for fan alarm status in syslog  status=inactive  timeout=120s
    Sleep  10s
    gnb_alarm.Disallow alarm    Cooling fan is over speeding
    Verify alarm is not active on gNB  fault_name=Cooling fan is over speeding
    Collect syslog results
