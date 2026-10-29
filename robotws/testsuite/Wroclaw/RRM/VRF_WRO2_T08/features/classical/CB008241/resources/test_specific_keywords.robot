*** Settings ***
Documentation
...    author:  Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Library     OperatingSystem
Library     DateTime
Library     ta_attenuator
Library     taf.sw.syslog   WITH NAME    taf_syslog
Library     ute_ue
Library     SSHLibrary
Library     ute_admin_infomodel
Library     taf.sbts.oam.coam.admin   WITH NAME   taf_admin
Library     ute_tshark   WITH NAME   tshark
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB008241/resources/test_specific_keywords.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.anr_utils
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils
Library     testsuite/Wroclaw/RRM/resources/webUI_operations.py
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB008241/resources/test_specific_keywords.py

*** Variables ***
${ABSTRACT_LIB_CONFIG}      /home/ute/testline_configuration/7_16_UTE5GCLOUDT322/ue_config.yaml
${GNB_1_CELL_1_ALIAS}       GNB_1_CELL_1
${GNB_1_CELL_2_ALIAS}       GNB_1_CELL_2
${GNB_1_CELL_4_ALIAS}       GNB_1_CELL_4
${GNB_2_CELL_1_ALIAS}       GNB_2_CELL_1
${syslog_path}              syslog/syslog_gNB50834.log
${syslog_path_ho}           syslog/syslog_ho_gNB50834.log
${LOG_PATH}                 ${OUTPUT DIR}
${GNB_IP}                   ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${GNB_ID}                   ${tl.gnbs[0].global_bts_id}
${VM_IP}                    ${tl.test_pc[0].default_ssh_connection_details.addr}
${VM_IP_REMOTE}             ${tl.test_pcs[1].default_ssh_connection_details.addr}
${NRADJECELL}               ${EMPTY}
${REMOTE_MPLANE_IP}         ${tl.gnbs[1].cu.backhaul_site_oam_ip.v4}
@{MPLANE_LIST}              ${GNB_IP}    ${REMOTE_MPLANE_IP}
${UE_INTRA_HO_MSG_1}        xnap and ip.src == 10.44.224.88 and ip.dst == 10.44.224.106 and xnap.procedureCode == 0 and
...                         xnap.radioNetwork == 1
${UE_INTRA_HO_MSG_2}        xnap and ip.src == 10.44.224.106 && ip.dst == 10.44.224.88 && xnap.procedureCode == 0
${UE_INTRA_HO_MSG_3}        xnap and ip.src == 10.44.224.88 && ip.dst == 10.44.224.106 && xnap.procedureCode == 1
${UE_INTRA_HO_MSG_4}        xnap and ip.src == 10.44.224.106 && ip.dst == 10.44.224.88 && xnap.procedureCode == 6
${UE_INTRA_HO_MSG_5}        ngap and ngap.procedureCode == 25 and ip.src == 10.44.225.106 and ip.dst == 10.27.28.136
${UE_INTRA_HO_MSG_6}        ngap and ngap.procedureCode == 25 and ip.src == 10.27.28.136 and ip.dst == 10.44.225.106 and ngap.NGAP_PDU == 1


*** Keywords ***
Test Setup
    [Arguments]  ${require_ue}=${TRUE}    ${anr_activation_flag_off}=${FALSE}    ${objects_removal}=${FALSE}
    ...          ${unblock_cells}=${FALSE}
    Remove Special Characters From Anr Testname
    Set Test Variable  ${require_ue}
    Set Test Variable  ${anr_activation_flag_off}
    Set Test Variable  ${objects_removal}
    Set Test Variable  ${unblock_cells}
    Delete All Nrrele And Nradjecell Objects
    IF    ${require_ue}    Prepare Ue
    IF    ${anr_activation_flag_off}    Set CB008241 Flag    false
    IF    ${objects_removal}    Remove XNLINK And NRADJGNB Objects
    Collect SCF Before Test


Test Teardown
    Run Keyword If Test Failed    Killall Tcpdump After Test    @{MPLANE_LIST}
    Run Keyword And Ignore Error    taf_admin.Teardown All Aliases For Admin
    Run Keyword And Ignore Error    tshark.Teardown All Aliases For Tshark
    IF   ${require_ue} == ${TRUE}   Run Keywords
    ...    Run Keyword And Continue On Failure    Detach Ue    UE_1   AND
    ...    Set Attenuation    ${GNB_1_CELL_1_ALIAS}    90dB    AND
    ...    Set Attenuation    ${GNB_1_CELL_2_ALIAS}    90dB    AND
    ...    Set Attenuation    ${GNB_1_CELL_4_ALIAS}    90dB    AND
    ...    Set Attenuation    ${GNB_2_CELL_1_ALIAS}    90dB    AND
    ...    Release Attenuator
    Run Keyword If Test Failed    Stop Collecting Syslog For All
    Run Keyword If Test Failed      Collect Snapshot
    Add Scout Scf Id To Test Data
    Run Keyword And Ignore Error    taf_syslog.Teardown All Aliases For Syslog
    IF    ${unblock_cells}    Run Keyword And Ignore Error    Unblock Cells
    Delete All Nrrele And Nradjecell Objects
    IF    ${anr_activation_flag_off}    Set CB008241 Flag    true
    Set Auto Removal Flag    false
    Set idleTimeForNrNbRemoval    2
    Run Keyword And Ignore Error    interface.Common Step Trigger


Start Collecting Logs
    [Arguments]    ${syslog}=${TRUE}
    IF   ${syslog} == ${TRUE}    Start Collecting Syslog For All
    IF   ${require_ue} == ${TRUE}    Start Tcpdump On CU    filename=${test_name}_SCTP.pcap
    IF   ${require_ue} == ${TRUE}    Start Tcpdump On Remote CU    ${REMOTE_MPLANE_IP}
    Log to Console    Logging started...


Stop Collecting Logs
    [Arguments]    ${syslog}=${TRUE}
    IF   ${syslog} == ${TRUE}    Stop Collecting Syslog For All
    IF   ${require_ue} == ${TRUE}    Run Keywords    Stop Tcpdump On CU And Download Logs    filename=${test_name}_SCTP.pcap    AND
    ...              Move File   ${LOG_PATH}/${test_name}_SCTP.pcap   ${LOG_PATH}/${test_name}/${test_name}_SCTP.pcap    AND
    ...              Set Test Variable   ${pcap_path}   ${LOG_PATH}/${test_name}/${test_name}_SCTP.pcap
    IF   ${require_ue} == ${TRUE}    Stop Tcpdump On CU And Download Logs For Remote DU
    Log To Console    Logging stopped...


Start Tcpdump On Remote CU
    [Arguments]    ${REMOTE_MPLANE_IP}
    SSHLibrary.Open Connection    host=${REMOTE_MPLANE_IP}    alias=target_pcap
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Start Command    tcpdump -i any sctp -w /tmp/target_SCTP.pcap


Stop Tcpdump On Local
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_SCTP.pcap
    Move File   ${LOG_PATH}/${test_name}_SCTP.pcap    ${LOG_PATH}/${test_name}/${test_name}_SCTP.pcap
    Set Test Variable    ${pcap_path}    ${LOG_PATH}/${test_name}/${test_name}_SCTP.pcap


Stop Tcpdump On CU And Download Logs For Remote DU
    SSHLibrary.Start Command    killall tcpdump
    Sleep    10s
    ${response}    Read Command Output
    Log To Console    ${response}
    SSHLibrary.Start Command    chmod 777 /tmp/target_SCTP.pcap
    SSHLibrary.File Should Exist    /tmp/target_SCTP.pcap
    SSHLibrary.Get File    /tmp/target_SCTP.pcap  destination=${LOG_PATH}/${TESTNAME}/${TESTNAME}_target_SCTP.pcap
    SSHLibrary.Start Command    rm /tmp/target_SCTP.pcap
    SSHLibrary.Close Connection


Killall Tcpdump After Test
    [Arguments]    @{MPLANE_LIST}
    FOR  ${mplane}  IN  @{MPLANE_LIST}
        SSHLibrary.Open Connection    host=${mplane}    alias=target_pcap
        SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
        SSHLibrary.Start Command    killall tcpdump
        Sleep    10s
        ${response}    Read Command Output
        Log To Console    ${response} on ${mplane}
    END


Collect SCF Before Test
    taf_admin.Setup Admin    bts_host=${GNB_IP}     alias=admin_gnb
    Log To Console    \nCollecting Backup SCF
    taf_admin.Get Current Scf File  ${LOG_PATH}/${test_name}/scf/  backup_scf.xml  timeout=60  connection=admin_gnb
    taf_admin.Teardown Admin    connection=admin_gnb


Start Collecting Syslog
    [Arguments]    ${VM_IP}    ${NAME}
    IF    '${VM_IP}' == '${tl.test_pc[0].default_ssh_connection_details.addr}'
    ...               taf_syslog.Start Syslog    log_dir=${LOG_PATH}/${test_name}/syslog/    log_name=syslog_${NAME}.log    ip=192.168.255.126
    ...                               alias=${NAME}    virtualenv_dir=/home/ute/test_repo
    IF    '${VM_IP}' != '${tl.test_pc[0].default_ssh_connection_details.addr}'
    ...               taf_syslog.Start Syslog    log_dir=${LOG_PATH}/${test_name}/syslog/    log_name=syslog_${NAME}.log    ip=192.168.255.126
    ...                               host_ip=${VM_IP}    alias=${NAME}    virtualenv_dir=/home/ute/test_repo


Stop Collecting Syslog
    [Arguments]    ${NAME}
    ${file_path}    taf_syslog.Collect Syslog Results    alias=${NAME}
    RETURN    ${file_path}


Start Collecting Syslog For All
    FOR    ${key}    IN    @{CONFIGS.keys()}
        Log To Console    Starting Syslog on ${key}
        Start Collecting Syslog    ${CONFIGS["${key}"]["VM_IP"]}    ${key}
    END
    Set Test Variable    ${current_syslog_path}   ${LOG_PATH}/${test_name}/${syslog_path}


Stop Collecting Syslog For All
    FOR    ${key}    IN    @{CONFIGS.keys()}
        Log To Console    Collecting syslog from ${key}
        Stop Collecting Syslog    ${key}
    END


Set Initial Attenuation
    ${cell_list}=   Create List   GNB_1_CELL_1    GNB_1_CELL_2   GNB_1_CELL_4    GNB_2_CELL_1
    Set Global Variable   ${GNB_CELLS}   ${cell_list}
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of    ${gnb_cells}
    Set Attenuation    ${GNB_1_CELL_1_ALIAS}    90dB
    Set Attenuation    ${GNB_1_CELL_2_ALIAS}    90dB
    Set Attenuation    ${GNB_1_CELL_4_ALIAS}    90dB
    Set Attenuation    ${GNB_2_CELL_1_ALIAS}    90dB
    Sleep  2s


Release Attenuator
    Release Attenuator Cell    ${GNB_CELLS}


Prepare Ue
    Set Initial Attenuation
    Require Ue    UE_1    capabilities=REAL_ANDROID_UE
    Detach Ue     UE_1


Perform Attach
    Set Attenuation    ${GNB_1_CELL_1_ALIAS}    0dB
    Sleep   10s
    Attach UE    UE_1
    Log To Console    UE_1 attached!
    Sleep   5s


Collect Snapshot
    Log To Console    \nCollecting BTS Snapshot!
    Make Snapshot In Case Of Error


Set CB008241 Flag
    [Arguments]  ${anr_activation_flag}
    Log To Console    \nSetting Up Anr Activation Flag actSaUeBasedInterFreqAnrNr to "${anr_activation_flag}"
    taf_admin.Setup Admin      bts_host=${gNB_IP}    alias=anr_activation
    taf_admin.Create Delta    delta_id=anr_activation
    taf_admin.Append Parameter Update To Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}  actSaUeBasedInterFreqAnrNr
    ...                                         ${anr_activation_flag}    delta_id=anr_activation
    ${delta}    taf_admin.Get Delta    delta_id=anr_activation
    taf_admin.Remove All Delta Id
    taf_admin.Perform Delta Recommissioning    ${delta}    connection=anr_activation
    taf_admin.Teardown Admin    alias=anr_activation


Set Auto Removal Flag
    [Arguments]  ${auto_removal}
    Log To Console    \nSetting Up Auto Removal Flag actAutoNrNbRemoval to "${auto_removal}"
    taf_admin.Setup Admin      bts_host=${gNB_IP}    alias=anr_activation
    taf_admin.Create Delta    delta_id=anr_activation
    taf_admin.Append Parameter Update To Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANR-1  actAutoNrNbRemoval
    ...                                         ${auto_removal}    delta_id=anr_activation
    ${delta}    taf_admin.Get Delta    delta_id=anr_activation
    taf_admin.Remove All Delta Id
    taf_admin.Perform Delta Recommissioning    ${delta}    connection=anr_activation
    taf_admin.Teardown Admin    alias=anr_activation


Set idleTimeForNrNbRemoval
    [Arguments]  ${idleTimeForNrNbRemoval}
    Log To Console    \nSetting Up idleTimeForNrNbRemoval = ${idleTimeForNrNbRemoval}
    taf_admin.Setup Admin      bts_host=${gNB_IP}    alias=anr_activation
    taf_admin.Create Delta    delta_id=anr_activation
    taf_admin.Append Parameter Update To Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-2  idleTimeForNrNbRemoval
    ...                                         ${idleTimeForNrNbRemoval}    delta_id=anr_activation
    ${delta}    taf_admin.Get Delta    delta_id=anr_activation
    taf_admin.Remove All Delta Id
    taf_admin.Perform Delta Recommissioning    ${delta}    connection=anr_activation
    taf_admin.Teardown Admin    alias=anr_activation


Remove XNLINK And NRADJGNB Objects
    Log To Console    Removing XNLINK And NRADJGNB Objects...
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=delete
    ${params}    Get Empty List
    ${scfc_file}    taf_admin.Get Scf    connection=delete
    ${distname_nradjgnb}    Run Keyword And Ignore Error    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJGNB-\[0-9]{1}
    ${distname_xnlink}    Run Keyword And Ignore Error    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/XNLINK-\[0-9]{1}
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=${distname_nradjgnb[1]}
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=delete
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=${distname_xnlink[1]}
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=delete
    taf_admin.Teardown Admin    connection=delete


Delete All Nrrele And Nradjecell Objects
    [Arguments]    ${cell_1_id}=1
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nrrel_del
    ${params}    Get Empty List
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRREL-256
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRREL-255
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRREL-1
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJECELL-5000
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRRELE-1
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJECELL-1
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRRELE-2
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJECELL-2
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRRELE-123
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJECELL-123
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJNRCELL-12288
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJNRCELL-1
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    taf_admin.Teardown Admin    connection=nrrel_del


Create Nradjcell And Nrrel Objects
    [Arguments]    ${nradjnrcell_id}=NRADJNRCELL-1   ${nrrel_id}=NRREL-1
    ${nradjnrcell_params}=    Get Params For Nradjnrcell Object
    ${nrrel_params}=    Get Params For Nrrel Object
    Log To Console    \nCreating Nradjcell And Nrrel Objects...
    taf_admin.Setup Admin      bts_host=${gNB_IP}    alias=object_creation
    taf_admin.Perform Object Recommissioning    dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${nradjnrcell_id}
    ...                                         parameter=${nradjnrcell_params}
    ...                                         operation=create
    ...                                         connection=object_creation
    taf_admin.Perform Object Recommissioning    dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-1/${nrrel_id}
    ...                                         parameter=${nrrel_params}
    ...                                         operation=create
    ...                                         connection=object_creation
    taf_admin.Teardown Admin    alias=object_creation


Create Nradjgnb And Xnlink Objects
    [Arguments]    ${xnlink_id}=XNLINK-1    ${nradjgnb_id}=NRADJGNB-1
    ${nradjgnb_params}=    Get Params For Nradjgnb Object
    ${xnlink_params}=    Get Params For Xnlink Object
    Log To Console    \nCreating Nradjgnb And Xnlink Objects...
    taf_admin.Setup Admin      bts_host=${gNB_IP}    alias=object_creation
    taf_admin.Perform Object Recommissioning    dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${xnlink_id}
    ...                                         parameter=${xnlink_params}
    ...                                         operation=create
    ...                                         connection=object_creation
    taf_admin.Perform Object Recommissioning    dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${nradjgnb_id}
    ...                                         parameter=${nradjgnb_params}
    ...                                         operation=create
    ...                                         connection=object_creation
    taf_admin.Teardown Admin    alias=object_creation


Check All Objects Removal
    [Arguments]    ${Var_1}=2   ${Var_2}=3   ${Var_3}=4
    FOR    ${i}    IN RANGE    200
        ${fire_counter}=    Count Fires    syslog_path=${current_syslog_path}
        ${date}  Get Current Date
        Log To Console   \n${fire_counter}:${date}
        IF    ${fire_counter} == ${Var_3}    BREAK
        IF    ${fire_counter} < ${Var_1}    Check Nrrel Object Exist
        IF    ${fire_counter} < ${Var_2}    Check Nradjnrcell Object Exist
        IF    ${fire_counter} < ${Var_3}    Check Nradjgnb And Xnlink Objects Exist
        IF    ${fire_counter} == ${Var_1}   Wait Until Keyword Succeeds    20x    5s    Check Nrrel Object Not Exist
        IF    ${fire_counter} == ${Var_2}   Wait Until Keyword Succeeds    20x    5s    Check Nradjnrcell Object Not Exist
        Sleep    30s
    END
    Should Be Equal As Integers    ${fire_counter}    ${Var_3}
    Wait Until Keyword Succeeds    10x    10s    Check Nradjgnb And Xnlink Objects Not Exist
    Sleep    5s


Check All Objects Exist For One Cycle
    FOR    ${i}    IN RANGE    200
        ${fire_counter}=    Count Fires    syslog_path=${current_syslog_path}
        ${date}  Get Current Date
        Log To Console   \n${fire_counter}:${date}
        IF    ${fire_counter} == 1    BREAK
        Check Nrrel And Nradjnrcell Objects Exist
        Check Nradjgnb And Xnlink Objects Exist
    END
    Set idleTimeForNrNbRemoval    3


Check All Objects Removal For Cell Blocekd Case
    [Arguments]    ${Var_1}=2   ${Var_2}=3   ${Var_3}=4
    FOR    ${i}    IN RANGE    200
        ${fire_counter}=    Count Fires    syslog_path=${current_syslog_path}
        ${date}  Get Current Date
        Log To Console   \n${fire_counter}:${date}
        IF    ${fire_counter} == ${Var_3}    BREAK
        IF    ${fire_counter} < ${Var_1}    Check Both Nrrels Objects Exist
        IF    ${fire_counter} < ${Var_2}    Check Nradjnrcell Object Exist
        IF    ${fire_counter} < ${Var_3}    Check Nradjgnb And Xnlink Objects Exist
        IF    ${fire_counter} == ${Var_1}   Wait Until Keyword Succeeds    20x    5s    Check Nrrel Object Not Exist
        IF    ${fire_counter} == ${Var_2}   Wait Until Keyword Succeeds    20x    5s    Check Nradjnrcell Object Not Exist
        Sleep    30s
    END
    Should Be Equal As Integers    ${fire_counter}    ${Var_3}
    Wait Until Keyword Succeeds    10x    10s    Check Nradjgnb And Xnlink Objects Not Exist
    Sleep    5s


Check Nrrel And Nradjnrcell Objects Exist
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=both_status
    ${scfc_file}    taf_admin.Get Scf    connection=both_status
    ${distname_nradjnrcell}    Should Match Regexp    ${scfc_file}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-\[0-9]{1,5}
    ${distname_nrrel}    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-1/NRREL-\[0-9]{1,3}
    Log To Console    ${distname_nradjnrcell} Object exists!
    Log To Console    ${distname_nrrel} Object exists!
    taf_admin.Teardown Admin    connection=both_status


Check Both Nrrels Objects Exist
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=intra_status
    ${scfc_file}    taf_admin.Get Scf    connection=intra_status
    ${distname_nrrel_intra}    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-1/NRREL-255
    ${distname_nrrel_inter}    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-1/NRREL-256
    Log To Console    ${distname_nrrel_intra} Object exists!
    Log To Console    ${distname_nrrel_inter} Object exists!
    taf_admin.Teardown Admin    connection=intra_status


Check Nradjgnb And Xnlink Objects Exist
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=status
    ${scfc_file}    taf_admin.Get Scf    connection=status
    ${distname_nradjgnb}    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJGNB-\[0-9]{1}
    ${distname_xnlink}    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/XNLINK-\[0-9]{1}
    Log To Console    ${distname_nradjgnb} Object exists!
    Log To Console    ${distname_xnlink} Object exists!
    taf_admin.Teardown Admin    connection=status


Check Nradjnrcell Object Exist
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nradjnrcell_status
    ${scfc_file}    taf_admin.Get Scf    connection=nradjnrcell_status
    ${distname_nradjnrcell}    Should Match Regexp    ${scfc_file}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-\[0-9]{1,5}
    Log To Console    ${distname_nradjnrcell} exist!
    taf_admin.Teardown Admin    connection=nradjnrcell_status


Check Nrrel Object Exist
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nradjnrcell_status
    ${scfc_file}    taf_admin.Get Scf    connection=nradjnrcell_status
    ${distname_nrrel}    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-1/NRREL-\[0-9]{1,3}
    Log To Console    ${distname_nrrel} exist!
    taf_admin.Teardown Admin    connection=nradjnrcell_status


Check Nrrel Object Not Exist
    taf_admin.Setup Admin      bts_host=${gNB_IP}    alias=nrrel_removal_status
    ${nrrel_status}    taf_admin.Get Scf    connection=nrrel_removal_status
    Should Not Contain    ${nrrel_status}    distName=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-1/NRREL-1
    taf_admin.Teardown Admin    alias=nrrel_removal_status


Check Nradjnrcell Object Not Exist
    taf_admin.Setup Admin      bts_host=${gNB_IP}    alias=nradjnrcell_removal_status
    ${nradjnrcell_status}    taf_admin.Get Scf    connection=nradjnrcell_removal_status
    Should Not Contain    ${nradjnrcell_status}    distName=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-1
    taf_admin.Teardown Admin    alias=nradjnrcell_removal_status


Check Nradjgnb And Xnlink Objects Not Exist
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nradjgnb_removal_status
    ${objects_status}    taf_admin.Get Scf    connection=nradjgnb_removal_status
    Should Not Contain    ${objects_status}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJGNB-1
    Should Not Contain    ${objects_status}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/XNLINK-1
    taf_admin.Teardown Admin    connection=nradjgnb_removal_status


Check Proper Values For Nrrel And Nradjnrcell Objects
    Log To Console    \nChecking Nrrel And Nradjnrcell values...
    Setup Infomodel    address=192.168.255.1    port=443    use_ssl=True    alias=infomodel
    Connect Infomodel    alias=infomodel
    ${query_nradjnrcell}=    Query Infomodel    query=get object //NRADJNRCELL_A-*    alias=infomodel
    ${query_nrrel}=    Query Infomodel    query=get object //NRREL_A-256    alias=infomodel
    FOR    ${q}    IN    ${query_nradjnrcell}
        Set Test Variable    ${dist_name_nradjnrcell}    ${q['dist_name']}
    END
    FOR    ${q}    IN    ${query_nrrel}
        Set Test Variable    ${dist_name_nrrel}    ${q['dist_name']}
    END
    Disconnect Infomodel    alias=infomodel
    Teardown Infomodel    alias=infomodel
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nrrele_status
    ${params_nradjnrcell}=    taf_admin.Get Parameters    dist_name=${dist_name_nradjnrcell}    connection=nrrele_status
    ${params_nrrel}=    taf_admin.Get Parameters    dist_name=${dist_name_nrrel}    connection=nrrele_status
    taf_admin.Teardown Admin    connection=nrrele_status
    FOR   ${parameter}    IN    ${params_nradjnrcell}
        Should Be Equal    ${parameter['cellDepType']}    SA+NSA
        Should Be Equal As Integers    ${parameter['fiveGsTac']}    7152
        Should Be Equal As Integers    ${parameter['freqBandIndicatorNR']}    66
        Should Be Equal As Integers    ${parameter['gNbId']}    50848
        Should Be Equal As Integers    ${parameter['gNbIdLength']}   24
        Should Be Equal As Integers    ${parameter['gnbPlmn']['mcc']}    540
        Should Be Equal As Integers    ${parameter['gnbPlmn']['mnc']}   1
        Should Be Equal As Integers    ${parameter['gnbPlmn']['mncLength']}   2
        Should Be Equal As Integers    ${parameter['lcrId']}    1
        Should Be Equal As Integers    ${parameter['nrarfcn']}    434000
        Should Be Equal As Integers    ${parameter['physCellId']}    999
        Should Be Equal As Integers    ${parameter['ssbFrequency']}    433970
    END
    FOR   ${parameter}    IN    ${params_nrrel}
        Should Be Equal As Integers    ${parameter['gNbId']}    50848
        Should Be Equal As Integers    ${parameter['gNbIdLength']}   24
        Should Be Equal As Integers    ${parameter['gnbPlmn']['mcc']}    540
        Should Be Equal As Integers    ${parameter['gnbPlmn']['mnc']}   1
        Should Be Equal As Integers    ${parameter['gnbPlmn']['mncLength']}   2
        Should Be Equal As Integers    ${parameter['lcrId']}    1
    END


Check Proper Values For Xnlink And Nradjgnb Objects
    Log To Console    \nChecking Xnlink And Nradjgnb values...
    Setup Infomodel    address=192.168.255.1    port=443    use_ssl=True    alias=infomodel
    Connect Infomodel    alias=infomodel
    ${query_nradjgnb}=    Query Infomodel    query=get object //NRADJGNB_A-*    alias=infomodel
    ${query_xnlink}=    Query Infomodel    query=get object //XNLINK_A-*    alias=infomodel
    FOR    ${q}    IN    ${query_nradjgnb}
        Set Test Variable    ${dist_name_nradjgnb}    ${q['dist_name']}
    END
    FOR    ${q}    IN    ${query_xnlink}
        Set Test Variable    ${dist_name_xnlink}    ${q['dist_name']}
    END
    Disconnect Infomodel    alias=infomodel
    Teardown Infomodel    alias=infomodel
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=status
    ${params_nradjgnb}=    taf_admin.Get Parameters    dist_name=${dist_name_nradjgnb}    connection=status
    ${params_xnlink}=    taf_admin.Get Parameters    dist_name=${dist_name_xnlink}    connection=status
    taf_admin.Teardown Admin    connection=status
    FOR    ${parameter}    IN    ${params_nradjgnb}
        Should Be Equal As Integers    ${parameter['gNbIdLength']}    24
        Should Be Equal As Integers    ${parameter['gNodeBId']}    50848
        Should Be Equal As Integers    ${parameter['gnbPlmn']['mcc']}    540
        Should Be Equal As Integers    ${parameter['gnbPlmn']['mnc']}    1
        Should Be Equal As Integers    ${parameter['gnbPlmn']['mncLength']}    2
        Should Be Equal    ${parameter['gNodeBIdCtrl']}    oamControlled
    END
    FOR    ${parameter}    IN    ${params_xnlink}
        Should Be Equal    ${parameter['cPlaneIpAddr']}    10.44.224.106
        Should Be Equal    ${parameter['cPlaneIpAddrCtrl']}    oamControlled
    END


Remove Special Characters From Anr Testname
    ${test_name}=    Replace String Using Regexp   ${TESTNAME}   ${space}   _
    ${test_name}=    Replace String Using Regexp   ${test_name}   &   _
    ${test_name}=    Remove String   ${test_name}   (
    ${test_name}=    Remove String   ${test_name}   )
    Set Test Variable   ${test_name}


Perform Inter Gnb Handover From Gnb_1 Cell 1 To Gnb_2 Cell 1
    Perform Attach
    Trigger Inter-gNB HO
    Sleep   2s


Perform Intra Gnb Handover From Cell 1 To Cell 2
    Perform Attach
    Trigger Intra-gNB HO
    Sleep   2s


Trigger Inter-gNB HO
    Log To Console    Starting InterGNB HO...
    Set Attenuation    GNB_2_CELL_1    0db
    FOR    ${i}  IN RANGE  0  90  1
        Set Attenuation  GNB_1_CELL_1  ${i}db
        Sleep  1s
    END
    Log To Console    HO procedure done...


Trigger Intra-gNB HO
    Log To Console    Starting IntraGNB HO...
    Set Attenuation    GNB_1_CELL_4    25db
    FOR    ${i}  IN RANGE  0  50  1
        Set Attenuation  GNB_1_CELL_1  ${i}db
        Sleep  1s
    END
    Log To Console    HO procedure done...


Perform Inter GNB HO With actSaUeBasedInterFreqAnrNr Online Modification
    Perform Attach
    Sleep   10s
    Log To Console    Starting InterGNB HO...
    Set Attenuation    GNB_2_CELL_1    0db
    FOR    ${i}  IN RANGE  0  90  2
        Set Attenuation  GNB_1_CELL_1  ${i}db
        ${fire_counter}=    Count Fires For Pci Resolution    syslog_path=${LOG_PATH}/${test_name}/${syslog_path}
        Log To Console   ${fire_counter}
        IF    ${fire_counter} > 1    BREAK
        Sleep    1s
    END
    Set CB008241 Flag    true
    Log To Console    HO procedure done...


Verify Inter GNB HO By CGI Report
    [Arguments]    ${case}=${None}
    Log To Console   \nChecking Inter GNB Handover Msgs In Pcap File...
    Verify InterGNB HO By CGI Report Pcap    ${case}


Verify Dedicated DRX Profile Setup
    Log To Console   \nChecking Dedicated DRX Profile Setup In Pcap File...
    Verify Dedicated Drx Profile Setup Pcap


Check Counters
    [Arguments]  @{counters}  ${cell_id}=1  ${cell_id_2}=2  ${cell_id_3}=01  ${expected_value}=1
    Collect Counters
    ${updated_counter_values}    Get Last Counter Values    @{counters}
    Cleanup All Downloaded Counter Files
    ${results}=  Check If Counters Increased  ${updated_counter_values}  cell_id=${cell_id}  cell_id_2=${cell_id_2}  cell_id_3=${cell_id_3}
    ...          expected_value=${expected_value}


Perform Site Reset And Wait For OnAir State
    Perform Site Reset
    Wait For X2 Link Available    cells_up
    Log To Console    \ngNB On air


Perform Site Reset
    [Arguments]    ${gNB_IP}=${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
    taf_admin.Setup Admin    bts_host=${gNB_IP}    alias=site_reset
    taf_admin.Reset Site    timeout=600s    connection=site_reset
    taf_admin.Teardown Admin    alias=site_reset


Wait For X2 Link Available
    [Arguments]  ${admin_alias}
    taf_admin.Setup Admin    alias=${admin_alias}
    Wait Until Keyword Succeeds  900  10  testline_preparation.Verify X2 Link Is Available  ${admin_alias}
    taf_admin.Teardown Admin    connection=${admin_alias}


Wait One Removal Cycle
    Start Collecting Syslog    ${VM_IP}    wait_one_cycle
    FOR    ${i}    IN RANGE    200
        ${fire_counter}=    Count Fires    ${LOG_PATH}/${test_name}/syslog/syslog_wait_one_cycle.log
        ${date}  Get Current Date
        IF    ${fire_counter} == 1    BREAK
        Sleep    5s
    END
    Stop Collecting Syslog    wait_one_cycle


Block Cells
    Log To Console    \nBlocking target cells...
    taf_admin.Setup Admin    alias=block_local
    taf_admin.Block Cell    MRBTS-50834/NRBTS-50834/NRCELL-2    connection=block_local
    taf_admin.Teardown Admin    connection=block_local
    taf_admin.Setup Admin    remote_host=${VM_IP_REMOTE}    alias=block_remote
    taf_admin.Block Cell    MRBTS-50848/NRBTS-50848/NRCELL-1    connection=block_remote
    taf_admin.Teardown Admin    connection=block_remote
    Log To Console    \nCells blocked!


Unblock Cells
    taf_admin.Setup Admin    alias=unblock_local
    taf_admin.Unblock Cell    MRBTS-50834/NRBTS-50834/NRCELL-2    connection=unblock_local
    taf_admin.Teardown Admin    connection=unblock_local
    taf_admin.Setup Admin    remote_host=${VM_IP_REMOTE}    alias=unblock_remote
    taf_admin.Unblock Cell    MRBTS-50848/NRBTS-50848/NRCELL-1    connection=unblock_remote
    taf_admin.Teardown Admin    connection=unblock_remote


CB008241_A_B2_Inter-gNB_HO_By_CGI_Report_With_XN_Configured
    Log To Console    \nStarting Test
    @{counters_1}=     Create List                    M55124C05001  M55124C05002  M55147C01001  M55153C00001  M55153C00002
    @{counters_2}=     Create List                    M55124C05001  M55124C05002  M55153C00001  M55153C00002
    @{counters_3}=     Create List                    M55147C01001
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters_1}  expected_value=0
    Log To Console    \nStarting Test
    Start Collecting Logs
    Perform Inter Gnb Handover From Gnb_1 Cell 1 To Gnb_2 Cell 1
    Stop Collecting Logs
    Log To Console    Waiting For ANR Objects to appear...
    Sleep     60s
    Check Nrrel And Nradjnrcell Objects Exist
    Check Proper Values For Nrrel And Nradjnrcell Objects
    Verify Inter GNB HO By CGI Report
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters_2}
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters_3}


CB008241_A_B4_Inter-gNB_HO_By_CGI_Report_Add_NRADJNRCELL_And_NRREL_To_NPF
    Log To Console    \nStarting Test
    @{counters_1}=     Create List                    M55124C05001  M55124C05002  M55147C01001  M55153C00001  M55153C00002
    @{counters_2}=     Create List                    M55124C05001  M55124C05002  M55153C00001  M55153C00002
    @{counters_3}=     Create List                    M55147C01001
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters_1}  expected_value=0
    Start Collecting Logs
    Perform Inter Gnb Handover From Gnb_1 Cell 1 To Gnb_2 Cell 1
    Stop Collecting Logs
    Log To Console    Waiting For ANR Objects to appear...
    Sleep     60s
    Check Nrrel And Nradjnrcell Objects Exist
    Check Proper Values For Nrrel And Nradjnrcell Objects
    Verify Inter GNB HO By CGI Report
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters_2}
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters_3}


CB008241_A_B3_Inter-gNB_HO_By_CGI_Report-Dedicated_DRX_Profile_Setup
    Log To Console    \nStarting Test
    Start Collecting Logs
    Perform Inter Gnb Handover From Gnb_1 Cell 1 To Gnb_2 Cell 1
    Stop Collecting Logs
    Log To Console    Waiting For ANR Objects to appear...
    Sleep     60s
    Check Nrrel And Nradjnrcell Objects Exist
    Check Proper Values For Nrrel And Nradjnrcell Objects
    Verify Dedicated DRX Profile Setup


CB008241_B_B5_Inter-gNB_HO_By_CGI_Report-actSaUeBasedInterFreqAnrNr=true_Real-Time_Modification
    Log To Console    \nStarting Test
    Start Collecting Logs
    Perform Inter GNB HO With actSaUeBasedInterFreqAnrNr Online Modification
    Stop Collecting Logs
    Log To Console    Waiting For ANR Objects to appear...
    Sleep     60s
    Check Nrrel And Nradjnrcell Objects Exist
    Check Proper Values For Nrrel And Nradjnrcell Objects
    Confirm Ho After Act Flag    syslog_path=${current_syslog_path}
    Verify Inter GNB HO By CGI Report


CB008241_B_B6_actAutoNrNbRemoval=true
    Log To Console    \nStarting Test
    Start Collecting Syslog For All
    Create Nradjcell And Nrrel Objects
    Create Nradjgnb And Xnlink Objects
    Check Nrrel And Nradjnrcell Objects Exist
    Check Nradjgnb And Xnlink Objects Exist
    Set Auto Removal Flag    true
    Check All Objects Removal
    Stop Collecting Syslog For All
    Check Removal Syslog Messages    syslog_path=${current_syslog_path}


CB008241_B_B6_idleTimeForNrNbRemoval_Value_Real-Time_Modification
    Log To Console    \nStarting Test
    Set Auto Removal Flag    true
    Start Collecting Syslog For All
    Perform Inter Gnb Handover From Gnb_1 Cell 1 To Gnb_2 Cell 1
    Detach Ue    UE_1
    Set Attenuation    GNB_1_CELL_1    90db
    Set Attenuation    GNB_2_CELL_1    90db
    Sleep    30s
    Check Nrrel And Nradjnrcell Objects Exist
    Check Nradjgnb And Xnlink Objects Exist
    Check All Objects Exist For One Cycle
    Perform Inter Gnb Handover From Gnb_1 Cell 1 To Gnb_2 Cell 1
    Detach Ue    UE_1
    Set Attenuation    GNB_1_CELL_1    90db
    Set Attenuation    GNB_2_CELL_1    90db
    Check All Objects Removal    4    5    6
    Stop Collecting Syslog For All
    Check Removal Syslog Messages For Online Modification    syslog_path=${current_syslog_path}
    Start Collecting Logs    syslog=${FALSE}
    Perform Inter Gnb Handover From Gnb_1 Cell 1 To Gnb_2 Cell 1
    Stop Collecting Logs    syslog=${FALSE}
    Log To Console    Waiting For ANR Objects to appear...
    Sleep     60s
    Check Nrrel And Nradjnrcell Objects Exist
    Check Nradjgnb And Xnlink Objects Exist
    Check Proper Values For Nrrel And Nradjnrcell Objects
    Verify Inter GNB HO By CGI Report    xnlink/nglink


CB008241_B_B7_Inter-gNB_HO_By_CGI_Report-No_XN_Configured
    Log To Console    \nStarting Test
    Set Auto Removal Flag    true
    Wait One Removal Cycle
    Start Collecting Logs
    Perform Inter Gnb Handover From Gnb_1 Cell 1 To Gnb_2 Cell 1
    Detach Ue    UE_1
    Set Attenuation    GNB_1_CELL_1    90db
    Set Attenuation    GNB_2_CELL_1    90db
    Perform Intra Gnb Handover From Cell 1 To Cell 2
    Detach Ue    UE_1
    Set Attenuation    GNB_1_CELL_1    90db
    Set Attenuation    GNB_1_CELL_4    90db
    Block Cells
    Stop Tcpdump On Local
    Stop Tcpdump On CU And Download Logs For Remote DU
    Check Both Nrrels Objects Exist
    Check Nradjnrcell Object Exist
    Check Nradjgnb And Xnlink Objects Exist
    Check Proper Values For Nrrel And Nradjnrcell Objects
    Check Proper Values For Xnlink And Nradjgnb Objects
    Verify Inter GNB HO By CGI Report    xnlink/nglink
    Check All Objects Removal For Cell Blocekd Case
    Stop Collecting Syslog For All
    Check Removal Syslog Messages For Intra And Inter Ho    syslog_path=${current_syslog_path}
