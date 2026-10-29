*** Settings ***
Library        taf.transport.ssh                    WITH NAME   ssh
Resource       connections.robot
Library        Collections
Resource       taf/rfrl/bts/robot/gnb.robot
Resource       taf/rfrl/bts/robot/common/gnb_cu.robot
Resource       taf/rfrl/bts/robot/common/gnb_log.robot

*** Variables ***
${log_index}
${gnbMirroring_filtering}=   off
${LOG_PATH}         ${OUTPUT DIR}

*** Keywords ***

Start tcpdump on CU
    [Arguments]   ${filename}=${test_name}.pcap   ${interface}=any    ${protocol}=sctp   ${sleep_after_start_s}=3
    ${alias}=    Connect to gNB
    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...              ssh.send_command    command=tcpdump ${protocol} -i ${interface} -w "/tmp/${filename}"   connection=${alias}
    ...              ELSE
    ...              ssh.send_command    command=sudo tcpdump ${protocol} -i ${interface} -w "/tmp/${filename}"   connection=${alias}
    sleep   ${sleep_after_start_s} s


Stop tcpdump on CU and download logs
    [Arguments]     ${filename}=${test_name}.pcap
    sleep   3 s
    ${alias}=        Connect to gNB
    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...              ssh.execute
    ...              command=killall tcpdump
    ...              connection=${alias}
    ...              ELSE
    ...              ssh.execute
    ...              command=sudo killall tcpdump
    ...              connection=${alias}
    ssh.execute      command=chmod 777 /tmp/${filename}
    ...              connection=${alias}
    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...              ssh.download_file
    ...              /tmp/${filename}
    ...              ${LOG_PATH}/${filename}
    ...              connection=${alias}
    ...              ELSE
    ...              ssh.download_file
    ...              /tmp/${filename}
    ...              ${LOG_PATH}/${filename}
    ...              connection=${alias}
    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...              ssh.execute
    ...              command=rm "/tmp/${filename}"
    ...              connection=${alias}
    ...              ELSE
    ...              ssh.execute
    ...              command=sudo rm "/tmp/${filename}"
    ...              connection=${alias}
    sleep   3 s
