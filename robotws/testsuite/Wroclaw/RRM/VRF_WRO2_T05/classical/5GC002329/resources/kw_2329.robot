*** Settings ***
Documentation    Suite description
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002329/resources/kw_2329.py
Resource        testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
*** Keywords ***
Set attenuators for 2329
    Turn off attenuation
    Turn off attenuation_2
    # Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}   value=0
    Set attenuation_2 and check  lines=${lines_gNB_410_AEHC_6_TDD}   value=0

# Connect to ASIK
#     Connect to ASIK   alias=asik

Start Tshark for 2329
    [Arguments]  ${filename}=5GC002329.pcap
    ...          ${hostname}=192.168.255.129
    ...          ${username}=toor4nsn
    ...          ${password}=oZPS0POrRieRtu
    ...          ${alias}=asik
    ssh.connect_to  hostname=${hostname}  username=${username}
    ...             password=${password}  alias=${alias}
    Wait until keyword succeeds    5 min    1 min
    ...    ssh.send_command    command=tcpdump sctp -i any -w ${filename}   connection=${alias}
    sleep  3s
    Mkdir for logs

Stop Tshark and download logs after VoNR start
    [Arguments]  ${filename}=5GC002329.pcap
    ...          ${alias}=asik
    sleep  3s
    ssh.execute  command=killall tcpdump  connection=${alias}
    sleep  3s
    ssh.download_file   /user/toor4nsn/${filename}  ${OUTPUT_DIR}/${SUITE NAME}/${TEST_NAME}_startVoNR.pcap  connection=${alias}
    sleep  3s
    ssh.disconnect  connection=${alias}

Stop Tshark and download logs after VoNR stop
    [Arguments]  ${filename}=5GC002329.pcap
    ...          ${alias}=asik
    sleep  3s
    ssh.execute  command=killall tcpdump  connection=${alias}
    sleep  3s
    ssh.download_file   /user/toor4nsn/${filename}  ${OUTPUT_DIR}/${SUITE NAME}/${TEST_NAME}_stopVoNR.pcap  connection=${alias}
    sleep  3s
    ssh.disconnect  connection=${alias}

Verify mandatory messages
    test pattern in pcap    ${OUTPUT_DIR}/${TEST_NAME}.pcap

Verify FDD SCell configuration
    # [Arguments]    ${file_path}=${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    unpack collected syslog
    ${condition}=     Run keyword and Return Status
    ...               check if exist in syslog    AddedServingCellsList     Store addedSCellList:AddedServingCellsList
    Run keyword if    ${condition} == False
    ...               check if exist in syslog    AddedServingCellItem     Store addedSCellList
    check if exist in syslog    ScellAddition
    ...                         ScellAddition procedure Completed with No ScellAddition Error

Verify FDD SCell activation 2329
    # [Arguments]    ${file_path}=${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    unpack collected syslog
    check if exist in syslog    handleActivateMacCe     handleActivateMacCe done for UE

Verify VoNR call success
    ${fiveQI}  check_vonr_call_success    ${OUTPUT_DIR}/${SUITE NAME}/${TEST_NAME}_startVoNR.pcap
    should be true    ${fiveQI}

Verify VoNR call release
    ${fiveQI}  check_vonr_release_success    ${OUTPUT_DIR}/${SUITE NAME}/${TEST_NAME}_stopVoNR.pcap
    should be true    ${fiveQI}

