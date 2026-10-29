***Settings ***
Documentation
    ...     [Procedure]             "RP002338-A-a - One logical SBTS with mixed (ASIA/ASIB) dual common units operation"
    ...     [Date]                  "02-03-21"
    ...     [Author]                "Madhuri Thokala"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "3RAT 0n-air , block unblock ,reset of LTE WCDMA AND GSM Cell and Enable/disable SSH"
    ...     [Feature_ID]            "RP002338-A"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "IAV_BLR_TL3815"


variables	   ta_e2e_bts_trs_fw
Resource  	   taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot


Library	SSHLibrary
Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***
TRS_SR002338_block_and_unblock_SSH_and_RD_ports
    ${mplane_ipv4_1}=     Get Parameter   param_path=${mplane_ipv4_ip_moc}
    Set Suite Variable          ${mplane_ipv4_1}
    setup oamops    bts_host=${mplane_ipv4_1}   alias=upgrade_mplane
   Reset Bts       verify_bts=True  vreq_rat=all     should_be_onair=True     wait_for=1000    alias=upgrade_mplane
    Sleep   300
    ${mplane_ipv4_1}=     Get Parameter   param_path=${mplane_ipv4_ip_moc}
    Set Suite Variable          ${mplane_ipv4_1}
    Perform Recommissioning        type=delta      delta_file=${SR002338_3RAT_SSH_enable_Primary}
    ...       skip_parameter_relation_errors=${True}      timeout=300    alias=upgrade_mplane
    SSHLibrary.Open connection    host=${mplane_ipv4_1}
    ${check}=		Run Keyword And Return Status		SSHLibrary.Login    username=${username}   password={password}
    SSHLibrary.Open connection    host=${LMP_IP}
    ${check}=		Run Keyword And Return Status		SSHLibrary.Login    username=${username}   password=${password}
    Perform Recommissioning        type=delta      delta_file=${SR002338_3RAT_SSH_Disable_Primary}
    ...       skip_parameter_relation_errors=${True}      timeout=300    alias=upgrade_mplane
    ${output6}=    Run   sshpass -p {password} ssh ${username}@${LMP_IP}
     Should Contain    ${output6}   ${Connection_timed_out_output}
    ${output7}=    Run   sshpass -p {password} ssh ${username}@${mplane_ipv4_1}
     Should Contain    ${output7}   ${Connection_timed_out_output}
    Perform Recommissioning        type=delta      delta_file=${SR002338_3RAT_SSH_enable_Primary}
    ...       skip_parameter_relation_errors=${True}      timeout=300    alias=upgrade_mplane
     [Teardown]    Teardown oamops    alias=upgrade_mplane
