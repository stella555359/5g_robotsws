*** Settings ***
Documentation
...    author:  Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Library     OperatingSystem
Library     DateTime
Library     ta_attenuator
Library     taf.ue
Library     SSHLibrary
Library     ute_admin_infomodel
Library     taf.sbts.oam.coam.admin   WITH NAME   taf_admin
Library     taf.ul.alarms_watchdog    WITH NAME   WATCHDOG
Library     ute_tshark   WITH NAME   tshark
Library     taf.sw.syslog   WITH NAME    taf_syslog
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CNI117433/resources/test_specific_keywords.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.anr_utils
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CNI117433/resources/test_specific_keywords.py
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/allowed_alarms.py

*** Variables ***
${ABSTRACT_LIB_CONFIG}   /home/ute/testline_configuration/7_16_UTE5GCLOUDT302/ue_config.yaml
${GNB_1_CELL_1_ALIAS}            GNB_1_CELL_1
${GNB_1_CELL_2_ALIAS}            GNB_1_CELL_2
${GNB_2_CELL_1_ALIAS}            GNB_2_CELL_1
${GNB_2_CELL_2_ALIAS}            GNB_2_CELL_2
${syslog_path}              syslog/syslog_gNB50831.log
${syslog_path_ho}           syslog/syslog_ho_gNB50832.log
${syslog_cycles_count}      syslog/syslog_cycles_count.log
${LOG_PATH}                 ${OUTPUT DIR}
${GNB_IP}                   ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${GNB_ID}                   ${tl.gnbs[0].global_bts_id}
${GNB_ID_REMOTE}            ${tl.gnbs[1].global_bts_id}
${VM_IP}                    ${tl.test_pcs[0].default_ssh_connection_details.addr}
${VM_IP_REMOTE}             ${tl.test_pcs[1].default_ssh_connection_details.addr}
${NRADJECELL}               ${EMPTY}
${REMOTE_MPLANE_IP}         ${tl.gnbs[1].cu.backhaul_site_oam_ip.v4}
@{MPLANE_LIST}              ${GNB_IP}    ${REMOTE_MPLANE_IP}

*** Keywords ***
Test Setup
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    Verify Bts Is Operational
    Delete All Nrrele And Nradjecell Objects
    Set Initial Parameters On Source
    Set Initial Parameters On Target
    Prepare Ue
    Remove XNLINK And NRADJGNB Objects
    Collect SCF Before Test


Test Teardown
    WATCHDOG.Check Detected Alarms
    WATCHDOG.Stop Watching Alarms
    Run Keyword If Test Failed    Killall Tcpdump After Test    @{MPLANE_LIST}
    Run Keyword And Ignore Error    taf_admin.Teardown All Aliases For Admin
    Run Keyword And Ignore Error    tshark.Teardown All Aliases For Tshark
    Run Keyword And Continue On Failure    Detach Ue    UE_1
    Set Attenuation    ${GNB_1_CELL_1_ALIAS}    90dB
    Set Attenuation    ${GNB_1_CELL_2_ALIAS}    90dB
    Set Attenuation    ${GNB_2_CELL_1_ALIAS}    90dB
    Set Attenuation    ${GNB_2_CELL_2_ALIAS}    90dB
    Release Attenuator
    Run Keyword If Test Failed    Stop Collecting Syslog For All
    Run Keyword If Test Failed    Stop Collecting Syslog For Cycles Count
    Run Keyword If Test Failed    Collect BTS Snapshot
    Add Scout Scf Id To Test Data
    Delete All Nrrele And Nradjecell Objects
    Run Keyword And Ignore Error    interface.Common Step Trigger


Delete All Nrrele And Nradjecell Objects
    [Arguments]    ${cell_1_id}=1
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRREL-256
    ...                                         parameter=@{EMPTY}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJNRCELL-12288
    ...                                         parameter=@{EMPTY}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    taf_admin.Teardown Admin    connection=nrrel_del


Remove XNLINK And NRADJGNB Objects
    Log To Console    Removing XNLINK And NRADJGNB Objects...
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=delete
    ${scfc_file}    taf_admin.Get Scf    connection=delete
    ${distname_nradjgnb}    Run Keyword And Ignore Error    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJGNB-\[0-9]{1}
    ${distname_xnlink}    Run Keyword And Ignore Error    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/XNLINK-\[0-9]{1}
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=${distname_nradjgnb[1]}
    ...                                         parameter=@{EMPTY}
    ...                                         operation=delete
    ...                                         connection=delete
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=${distname_xnlink[1]}
    ...                                         parameter=@{EMPTY}
    ...                                         operation=delete
    ...                                         connection=delete
    taf_admin.Teardown Admin    connection=delete


Prepare Ue
    Set Initial Attenuation
    Require Ue    UE_1    capabilities=REAL_ANDROID_UE
    Detach Ue     UE_1


Start Collecting Syslog
    [Arguments]    ${VM_IP}    ${NAME}
    IF    '${VM_IP}' == '${tl.test_pcs[0].default_ssh_connection_details.addr}'
    ...               taf_syslog.Start Syslog    log_dir=${LOG_PATH}/${test_name}/syslog/    log_name=syslog_${NAME}.log    ip=192.168.255.126
    ...                               alias=${NAME}    virtualenv_dir=/home/ute/test_repo
    IF    '${VM_IP}' != '${tl.test_pcs[0].default_ssh_connection_details.addr}'
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


Start Collecting Syslog For Cycles Count
    Start Collecting Syslog    10.44.149.146    cycles_count
    Set Test Variable    ${current_syslog_path}   ${LOG_PATH}/${test_name}/${syslog_cycles_count}


Stop Collecting Syslog For Cycles Count
    [Arguments]    ${NAME}=cycles_count
    ${file_path}    taf_syslog.Collect Syslog Results    alias=${NAME}
    RETURN      ${file_path}


Set Initial Attenuation
    ${cell_list}=   Create List   GNB_1_CELL_1    GNB_1_CELL_2   GNB_2_CELL_1    GNB_2_CELL_2
    Set Global Variable   ${GNB_CELLS}   ${cell_list}
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of    ${gnb_cells}
    Set Attenuation    ${GNB_1_CELL_1_ALIAS}    90dB
    Set Attenuation    ${GNB_1_CELL_2_ALIAS}    90dB
    Set Attenuation    ${GNB_2_CELL_1_ALIAS}    90dB
    Set Attenuation    ${GNB_2_CELL_2_ALIAS}    90dB
    Sleep  2s


Release Attenuator
    Set Attenuation For All Cells  90dB
    Release attenuator cell    ${gnb_cells}


Verify Bts Is Operational
    Log To Console  \nBTS Verification Ongoing...
    Verify Gnb Is OnAir
    WATCHDOG.Check Detected Alarms


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


Set Initial Parameters On Source
    Log To Console    \nSetting Up Initial Parameters
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=initial_source
    taf_admin.Create_Delta    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${GNB_ID}/NRBTS-${GNB_ID}    actSaUeBasedAnrNr
    ...                                         true    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${GNB_ID}/NRBTS-${GNB_ID}    actSaUeBasedInterFreqAnrNr
    ...                                         true    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${GNB_ID}/NRBTS-${GNB_ID}    actIntraNrNgHo
    ...                                         sourceAndTarget    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${GNB_ID}/NRBTS-${GNB_ID}    actConflictConfiguration
    ...                                         true    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRANRPR-1   idleTimeForNrNbRemoval
    ...                                         2    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${GNB_ID}/NRBTS-${GNB_ID}    actIncXn
    ...                                         false    delta_id=delta
    ${delta}    taf_admin.Get_Delta    delta_id=delta
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=initial_source
    taf_admin.Teardown Admin    connection=initial_source


Set Initial Parameters On Target
    Log To Console    \nSetting Up Initial Parameters
    taf_admin.Setup Admin      bts_host=${REMOTE_MPLANE_IP}    alias=initial_target
    taf_admin.Create_Delta    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${GNB_ID_REMOTE}/NRBTS-${GNB_ID_REMOTE}    actSaUeBasedAnrNr
    ...                                         true    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${GNB_ID_REMOTE}/NRBTS-${GNB_ID_REMOTE}    actSaUeBasedInterFreqAnrNr
    ...                                         true    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${GNB_ID_REMOTE}/NRBTS-${GNB_ID_REMOTE}    actIntraNrNgHo
    ...                                         disabled    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${GNB_ID_REMOTE}/NRBTS-${GNB_ID_REMOTE}    actConflictConfiguration
    ...                                         true    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${GNB_ID_REMOTE}/NRBTS-${GNB_ID_REMOTE}    actIncXn
    ...                                         false    delta_id=delta
    ${delta}    taf_admin.Get_Delta    delta_id=delta
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=initial_target
    taf_admin.Teardown Admin    connection=initial_target


Set actSaUeBasedAnrNr Parameters On Source
    [Arguments]    ${actSaUeBasedAnrNr}    ${actSaUeBasedInterFreqAnrNr}
    Log To Console    \nSetting Up ANR parameters
    taf_admin.Setup Admin      bts_host=${gNB_IP}    alias=anr_params
    taf_admin.Create Delta    delta_id=anr_params
    taf_admin.Append Parameter Update To Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}    actSaUeBasedAnrNr
    ...                                         ${actSaUeBasedAnrNr}    delta_id=anr_params
    taf_admin.Append Parameter Update To Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}    actSaUeBasedInterFreqAnrNr
    ...                                         ${actSaUeBasedInterFreqAnrNr}    delta_id=anr_params
    ${delta}    taf_admin.Get Delta    delta_id=anr_params
    taf_admin.Remove All Delta Id
    taf_admin.Perform Delta Recommissioning    ${delta}    connection=anr_params
    taf_admin.Teardown Admin    alias=anr_params


Set actIncXn On Target
    Log To Console    \nSetting Up actIncXn parameter
    taf_admin.Setup Admin      bts_host=${REMOTE_MPLANE_IP}    alias=actIncXn
    taf_admin.Create Delta    delta_id=actIncXn
    taf_admin.Append Parameter Update To Delta  MRBTS-${GNB_ID_REMOTE}/NRBTS-${GNB_ID_REMOTE}    actIncXn
    ...                                         true    delta_id=actIncXn
    ${delta}    taf_admin.Get Delta    delta_id=actIncXn
    taf_admin.Remove All Delta Id
    taf_admin.Perform Delta Recommissioning    ${delta}    connection=actIncXn
    taf_admin.Teardown Admin    alias=actIncXn


Perform Inter Gnb Handover From Gnb_1 Cell 1 To Gnb_2 Cell 1
    Trigger Inter-gNB HO
    Sleep   2s


Perform Attach
    Set Attenuation    ${GNB_1_CELL_1_ALIAS}    0dB
    Set Attenuation    ${GNB_2_CELL_1_ALIAS}    90dB
    Sleep   10s
    Attach UE    UE_1
    Log To Console    UE_1 attached!
    Sleep   5s


Trigger Inter-gNB HO
    Log To Console    Starting InterGNB HO...
    Set Attenuation    GNB_2_CELL_1    0db
    FOR    ${i}  IN RANGE  0  30  2
        Set Attenuation  GNB_1_CELL_1  ${i}db
        Sleep  1s
    END
    Sleep  4s
    Set Attenuation  GNB_1_CELL_1  0db
    Set Attenuation  GNB_2_CELL_1  90db
    Log To Console    HO procedure done...


Check Nrrel And Nradjnrcell Objects Exist
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=both_status
    ${scfc_file}    taf_admin.Get Scf    connection=both_status
    ${distname_nradjnrcell}    Should Match Regexp    ${scfc_file}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-\[0-9]{1,5}
    ${distname_nrrel}    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-1/NRREL-\[0-9]{1,3}
    Log To Console    ${distname_nradjnrcell} Object exists!
    Log To Console    ${distname_nrrel} Object exists!
    taf_admin.Teardown Admin    connection=both_status


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


Check All Objects Removal
    [Arguments]    ${Var_1}=2   ${Var_2}=3   ${Var_3}=4
    FOR    ${i}    IN RANGE    200
        ${fire_counter}=    Count Fires    syslog_path=${LOG_PATH}/${test_name}/syslog/syslog_cycles_count.log
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


CNI-117433_ANR_triggered_Xnlink_setup_after_prior_Xnlink_removal
    Log To Console    \nStarting Test
    Start Collecting Syslog For All
    Create TCPDump Collector    step_1
    Start TCP Dump
    Perform Attach
    Perform Inter Gnb Handover From Gnb_1 Cell 1 To Gnb_2 Cell 1
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Detach Ue    UE_1
    Verify Xnap Setup Failure
    Set actSaUeBasedAnrNr Parameters On Source    false    false
    Set actIncXn On Target
    Set actSaUeBasedAnrNr Parameters On Source    true    false
    Perform Attach
    Stop Collecting Syslog    gNB50831
    Start Collecting Syslog For Cycles Count
    Perform Inter Gnb Handover From Gnb_1 Cell 1 To Gnb_2 Cell 1
    Sleep    60s
    Check Nrrel And Nradjnrcell Objects Exist
    Check Nradjgnb And Xnlink Objects Exist
    Check All Objects Removal
    Stop Collecting Syslog For Cycles Count
    Stop Collecting Syslog    gNB50832
