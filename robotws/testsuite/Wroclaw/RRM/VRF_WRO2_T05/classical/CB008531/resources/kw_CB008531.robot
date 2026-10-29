*** Settings ***
Documentation    Suite description
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008531/resources/kw_CB008531.py
Resource        testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot


*** Keywords ***
Set attenuators for CB008531
    Turn off attenuation
    Turn off attenuation_2
    Set attenuation and check    lines=${lines_gNB_190_AHLOA_1_FDD}   value=90
    Set attenuation_2 and check  lines=${lines_gNB_190_AHLOA_3_FDD}   value=90

Start Tshark for CB008531
    [Arguments]  ${filename}=CB008531.pcap
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

Stop Tshark and download logs after handover
    [Arguments]  ${filename}=CB008531.pcap
    ...          ${alias}=asik
    sleep  3s
    ssh.execute  command=killall tcpdump  connection=${alias}
    sleep  3s
    ssh.download_file   /user/toor4nsn/${filename}  ${OUTPUT_DIR}/${SUITE NAME}/${TEST_NAME}_handover.pcap  connection=${alias}
    sleep  3s
    ssh.disconnect  connection=${alias}

Verify mandatory messages
    test pattern in pcap    ${OUTPUT_DIR}/${TEST_NAME}.pcap

Verify FDD SCell activation 8531
    # [Arguments]    ${file_path}=${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    unpack collected syslog
    check if exist in syslog    handleActivateMacCe     handleActivateMacCe done for UE

Verify hanodver success for 8531
    test pattern in pcap    ${OUTPUT_DIR}/${SUITE NAME}/${TEST_NAME}_handover.pcap

Verify Inter-gNB handover procedure
    # verify_inter_gnb_handover_procedure_pcap    ${OUTPUT_DIR}/${SUITE NAME}/${TEST_NAME}_handover.pcap
    unpack collected syslog
    Run Keyword And Continue On Failure  check if exist in syslog    Handling            HandoverRequest
    Run Keyword And Continue On Failure  check if exist in syslog    ActiveProcedure     set to xnInterGnbHandoverOnTarget
    Run Keyword And Continue On Failure  check if exist in syslog    ActiveProcedure     reset from xnInterGnbHandoverOnTarget
    Run Keyword And Continue On Failure  check if exist in syslog    ActiveProcedure     status: Complete
    Run Keyword And Continue On Failure  check if not exist in syslog    ActiveProcedure     Failure

Verify UE Capability Enquiry procedure
    verify_ue_capability_enquiry_procedure_pcap   ${OUTPUT_DIR}/${SUITE NAME}/${TEST_NAME}_handover.pcap
    check if exist in syslog    UeNrCapability
    ...    Interesting band of 66 is not included in IE of rf-Parameters.appliedFreqBandListFilter

Setup attenuator for 154 TL
    att.Setup attenuator    ip_addr=10.42.61.163    port=3001
    ...    attenuation_port_numbers=${atten_ports}    max_attenuation=${max_attenuation_value}    vendor=${atten_vendor}
    ...    alias=att_154

Setup initial attenuation for 154 TL
    [Arguments]      ${lines}    ${value}
    FOR    ${line}    IN    @{lines}
        att.Set attenuation     port=${${line}}     value=${${value}}   attenuator_device=att_154
        ${value_port}    att.Read attenuation    port=${${line}}   attenuator_device=att_154
        Should be equal    ${value_port}    ${${value}}
    END

Perform handover
    Log to console  Pending to trigger handover
    Set attenuation and check  lines=${lines_gNB_410_AHLOA_1_FDD}   value=35
    Sleep  3s
    Set attenuation and check  lines=${lines_gNB_410_AHLOA_1_FDD}   value=0
    sleep  3s
    Setup initial attenuation for 154 TL   lines=${lines_gNB_154_on}   value=0
    sleep  3s
    Setup initial attenuation for 154 TL   lines=${lines_gNB_154_on}   value=10
    sleep  3s
    Setup initial attenuation for 154 TL   lines=${lines_gNB_154_on}   value=30
    sleep  3s
    Setup initial attenuation for 154 TL   lines=${lines_gNB_154_on}   value=40
    sleep  3s
    Setup initial attenuation for 154 TL   lines=${lines_gNB_154_on}   value=45
    sleep  3s
    Setup initial attenuation for 154 TL   lines=${lines_gNB_154_on}   value=50
    sleep  3s
    Setup initial attenuation for 154 TL   lines=${lines_gNB_154_on}   value=55
    sleep  3s
    Setup initial attenuation for 154 TL   lines=${lines_gNB_154_on}   value=60
