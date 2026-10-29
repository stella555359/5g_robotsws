*** Settings ***
Documentation
...    author:  Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Library     OperatingSystem
Library     BuiltIn
Library     Collections
Library     String
Library     DateTime
Library     ta_attenuator
Library     taf.ue
Library     SSHLibrary
Library     ute_admin_infomodel
Library     taf.sbts.oam.coam.admin   WITH NAME   taf_admin
Library     taf.ul.alarms_watchdog    WITH NAME   WATCHDOG
Library     ute_tshark   WITH NAME   tshark
Library     taf.sw.syslog   WITH NAME    taf_syslog
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CNI140449/resources/test_specific_keywords.py
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CNI140449/resources/test_specific_keywords.py
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/allowed_alarms.py

*** Variables ***
${ABSTRACT_LIB_CONFIG}   /home/ute/testline_configuration/7_16_UTE5GCLOUDT302/ue_config.yaml
${GNB_1_CELL_1_ALIAS}            GNB_1_CELL_1
${GNB_1_CELL_2_ALIAS}            GNB_1_CELL_2
${GNB_2_CELL_1_ALIAS}            GNB_2_CELL_1
${GNB_2_CELL_2_ALIAS}            GNB_2_CELL_2
${syslog_path}              syslog/syslog_gNB50831.log
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
    Remove Special Characters From Anr Testname
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
    Run Keyword And Ignore Error    taf_admin.Teardown All Aliases For Admin
    Run Keyword And Ignore Error    tshark.Teardown All Aliases For Tshark
    Run Keyword And Continue On Failure    Detach Ue    UE_1
    Set Attenuation    ${GNB_1_CELL_1_ALIAS}    90dB
    Set Attenuation    ${GNB_1_CELL_2_ALIAS}    90dB
    Set Attenuation    ${GNB_2_CELL_1_ALIAS}    90dB
    Set Attenuation    ${GNB_2_CELL_2_ALIAS}    90dB
    Release Attenuator
    Run Keyword And Ignore Error    Stop Collecting Syslog For All
    Run Keyword If Test Failed    Collect BTS Snapshot
    Add Scout Scf Id To Test Data
    Delete All Nrrele And Nradjecell Objects
    Remove XNLINK And NRADJGNB Objects
    Run Keyword And Ignore Error    interface.Common Step Trigger


Remove Special Characters From Anr Testname
    ${test_name}=    Replace String Using Regexp   ${TESTNAME}   ${space}   _
    ${test_name}=    Replace String Using Regexp   ${test_name}   &   _
    ${test_name}=    Remove String   ${test_name}   (
    ${test_name}=    Remove String   ${test_name}   )
    Set Test Variable   ${test_name}


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
    @{distname_nradjgnb_list}=    Create List
    @{distname_xnlink_list}=    Create List
    @{scfc_lines}=    Split to lines    ${scfc_file}
    FOR    ${line}    IN    @{scfc_lines}
        ${distname_nradjgnb}=    Run Keyword And Ignore Error    Should Match Regexp    ${line}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJGNB-\[0-9]{1}
        ${distname_xnlink}=    Run Keyword And Ignore Error    Should Match Regexp    ${line}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/XNLINK-\[0-9]{1}
        IF   '${distname_nradjgnb[0]}'=='PASS'  Append To List    ${distname_nradjgnb_list}    ${distname_nradjgnb[1]}
        IF   '${distname_xnlink[0]}'=='PASS'  Append To List    ${distname_xnlink_list}    ${distname_xnlink[1]}
    END
    Log To Console    ${distname_nradjgnb_list}
    Log To Console    ${distname_xnlink_list}
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=${distname_nradjgnb_list[0]}
    ...                                         parameter=@{EMPTY}
    ...                                         operation=delete
    ...                                         connection=delete
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=${distname_xnlink_list[0]}
    ...                                         parameter=@{EMPTY}
    ...                                         operation=delete
    ...                                         connection=delete
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=${distname_nradjgnb_list[1]}
    ...                                         parameter=@{EMPTY}
    ...                                         operation=delete
    ...                                         connection=delete
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=${distname_xnlink_list[1]}
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
    Release Attenuator Cell    ${gnb_cells}


Verify Bts Is Operational
    Log To Console  \nBTS Verification Ongoing...
    Verify Gnb Is OnAir
    WATCHDOG.Check Detected Alarms


Set Initial Parameters On Source
    Log To Console    \nSetting Up Initial Parameters gNB50831...
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=initial_source
    taf_admin.Create_Delta    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${GNB_ID}/NRBTS-${GNB_ID}    actSaUeBasedAnrNr
    ...                                         true    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRANR-1    actAutoNrNbRemoval
    ...                                         false    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${GNB_ID}/NRBTS-${GNB_ID}    actSaUeBasedInterFreqAnrNr
    ...                                         true    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${GNB_ID}/NRBTS-${GNB_ID}    actIntraNrNgHo
    ...                                         sourceAndTarget    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${GNB_ID}/NRBTS-${GNB_ID}    actConflictConfiguration
    ...                                         true    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${GNB_ID}/NRBTS-${GNB_ID}    actIncXn
    ...                                         true    delta_id=delta
    ${delta}    taf_admin.Get_Delta    delta_id=delta
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=initial_source
    taf_admin.Teardown Admin    connection=initial_source


Set Initial Parameters On Target
    Log To Console    \nSetting Up Initial Parameters on gNB50832...
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
    ...                                         true    delta_id=delta
    ${delta}    taf_admin.Get_Delta    delta_id=delta
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=initial_target
    taf_admin.Teardown Admin    connection=initial_target


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
    FOR    ${i}  IN RANGE  0  30  1
        Set Attenuation  GNB_1_CELL_1  ${i}db
        Sleep  1s
    END
    Sleep  4s
    Set Attenuation  GNB_1_CELL_1  90db
    Set Attenuation  GNB_2_CELL_1  0db
    Log To Console    HO procedure done...


Check Nradjgnb And Xnlink Objects Exist
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=status
    ${scfc_file}    taf_admin.Get Scf    connection=status
    ${distname_nradjgnb}    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJGNB-\[0-9]{1}
    ${distname_xnlink}    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/XNLINK-\[0-9]{1}
    Log To Console    ${distname_nradjgnb} Object exists!
    Log To Console    ${distname_xnlink} Object exists!
    taf_admin.Teardown Admin    connection=status


Check Nrrel And Nradjnrcell Objects Exist
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=both_status
    ${scfc_file}    taf_admin.Get Scf    connection=both_status
    ${distname_nradjnrcell}    Should Match Regexp    ${scfc_file}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-\[0-9]{1,5}
    ${distname_nrrel}    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-1/NRREL-\[0-9]{1,3}
    Log To Console    ${distname_nradjnrcell} Object exists!
    Log To Console    ${distname_nrrel} Object exists!
    taf_admin.Teardown Admin    connection=both_status


Check Specific Nradjgnb And Xnlink Objects Exist
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=status
    ${scfc_file}    taf_admin.Get Scf    connection=status
    ${distname_nradjgnb_1}    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJGNB-2
    ${distname_nradjgnb_2}    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJGNB-3
    ${distname_xnlink_1}    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/XNLINK-2
    ${distname_xnlink_2}    Should Match Regexp    ${scfc_file}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/XNLINK-3
    Log To Console    ${distname_nradjgnb_1} Object exists!
    Log To Console    ${distname_nradjgnb_2} Object exists!
    Log To Console    ${distname_xnlink_1} Object exists!
    Log To Console    ${distname_xnlink_2} Object exists!
    taf_admin.Teardown Admin    connection=status


Create Nradjgnb And Xnlink Objects
    [Arguments]    ${nradjgnb_id}=NRADJGNB-2    ${xnlink_id}=XNLINK-2
    Log To Console    \nCreating Nradjgnb And Xnlink Objects...
    taf_admin.Setup Admin      bts_host=${gNB_IP}    alias=object_creation
    taf_admin.Create_Delta    delta_id=delta
    taf_admin.Append_Managed_Object_To_Delta    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${nradjgnb_id}    create    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${nradjgnb_id}    administrativeState
    ...                                           Unlocked    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${nradjgnb_id}    cPlaneIpSecTrsAddr
    ...                                           0.0.0.0    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${nradjgnb_id}    gNbIdLength
    ...                                           22    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${nradjgnb_id}    gNodeBId
    ...                                           50822    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${nradjgnb_id}    gNodeBIdCtrl
    ...                                           oamControlled    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${nradjgnb_id}    xnLinkRef
    ...                                           2    delta_id=delta
    taf_admin.append_complex_item_to_delta    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${nradjgnb_id}
    ...     gnbPlmn
    ...     mcc=540
    ...     mnc=1
    ...     mncLength=2
    ...     delta_id=delta
    taf_admin.Append_Managed_Object_To_Delta    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${xnlink_id}    create    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${xnlink_id}    cPlaneIpAddr
    ...                                           10.44.224.67    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${xnlink_id}    cPlaneIpAddrCtrl
    ...                                           oamControlled    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${xnlink_id}    xnLinkId
    ...                                           2    delta_id=delta
    ${delta}    taf_admin.Get_Delta    delta_id=delta
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=object_creation
    taf_admin.Teardown Admin    connection=object_creation


Lock Unlock NRADJGNBs On Source
    [Arguments]    ${state}
    Log To Console    \nSetting ${state} administrativeState for NRADJGNB
    taf_admin.Setup Admin      bts_host=${gNB_IP}    alias=lock_unlock
    taf_admin.Create Delta    delta_id=lock_unlock
    taf_admin.Append Parameter Update To Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJGNB-1    administrativeState
    ...                                         ${state}    delta_id=lock_unlock
    taf_admin.Append Parameter Update To Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJGNB-2    administrativeState
    ...                                         ${state}    delta_id=lock_unlock
    ${delta}    taf_admin.Get Delta    delta_id=lock_unlock
    taf_admin.Remove All Delta Id
    taf_admin.Perform Delta Recommissioning    ${delta}    connection=lock_unlock
    taf_admin.Teardown Admin    alias=lock_unlock


Set XnLinkRef Parameters On Source
    Log To Console    \nChnaging XnLinkRef for NRADJGNB objects....
    taf_admin.Setup Admin      bts_host=${gNB_IP}    alias=XnLinkRef
    taf_admin.Create Delta    delta_id=XnLinkRef
    taf_admin.Append Parameter Update To Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJGNB-1    xnLinkRef
    ...                                         2    delta_id=XnLinkRef
    taf_admin.Append Parameter Update To Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJGNB-2    xnLinkRef
    ...                                         1    delta_id=XnLinkRef
    ${delta}    taf_admin.Get Delta    delta_id=XnLinkRef
    taf_admin.Remove All Delta Id
    taf_admin.Perform Delta Recommissioning    ${delta}    connection=XnLinkRef
    taf_admin.Teardown Admin    alias=XnLinkRef


Check Nradjgnb And Xnlink Objects Not Exist
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nradjgnb_removal_status
    ${objects_status}    taf_admin.Get Scf    connection=nradjgnb_removal_status
    Should Not Contain    ${objects_status}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJGNB-1
    Should Not Contain    ${objects_status}    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/XNLINK-1
    taf_admin.Teardown Admin    connection=nradjgnb_removal_status


Check Proper Values For Xnlink And Nradjgnb Objects On Source GNB
    Log To Console    \nChecking Xnlink And Nradjgnb values on source GNB...
    @{dist_name_nradjgnb_list}=    Create List
    @{dist_name_xnlink_list}=    Create List
    Setup Infomodel    address=192.168.255.129    port=443    use_ssl=True    alias=infomodel
    Connect Infomodel    alias=infomodel
    ${query_nradjgnb}=    Query Infomodel    query=get list //NRADJGNB_A-*    alias=infomodel
    ${query_xnlink}=    Query Infomodel    query=get list //XNLINK_A-*    alias=infomodel
    FOR    ${q}    IN    ${query_nradjgnb}
        Append To List    ${dist_name_nradjgnb_list}    ${q[0]['dist_name']}
        Append To List    ${dist_name_nradjgnb_list}    ${q[1]['dist_name']}
        Sort List    ${dist_name_nradjgnb_list}
        Log To Console    ${dist_name_nradjgnb_list}
        Set Test Variable    ${dist_name_nradjgnb_1}    ${dist_name_nradjgnb_list[0]}
        Set Test Variable    ${dist_name_nradjgnb_2}    ${dist_name_nradjgnb_list[1]}
    END
    FOR    ${q}    IN    ${query_xnlink}
        Append To List    ${dist_name_xnlink_list}    ${q[0]['dist_name']}
        Append To List    ${dist_name_xnlink_list}    ${q[1]['dist_name']}
        Sort List    ${dist_name_xnlink_list}
        Log To Console    ${dist_name_xnlink_list}
        Set Test Variable    ${dist_name_xnlink_1}    ${dist_name_xnlink_list[0]}
        Set Test Variable    ${dist_name_xnlink_2}    ${dist_name_xnlink_list[1]}
    END
    Disconnect Infomodel    alias=infomodel
    Teardown Infomodel    alias=infomodel
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=check
    ${params_nradjgnb_1}=    taf_admin.Get Parameters    dist_name=${dist_name_nradjgnb_1}    connection=check
    ${params_nradjgnb_2}=    taf_admin.Get Parameters    dist_name=${dist_name_nradjgnb_2}    connection=check
    ${params_xnlink_1}=    taf_admin.Get Parameters    dist_name=${dist_name_xnlink_1}    connection=check
    ${params_xnlink_2}=    taf_admin.Get Parameters    dist_name=${dist_name_xnlink_2}    connection=check
    taf_admin.Teardown Admin    connection=check
    FOR    ${parameter}    IN    ${params_nradjgnb_1}
        Should Be Equal As Integers    ${parameter['gNbIdLength']}    22
        Should Be Equal As Integers    ${parameter['gNodeBId']}    50822
        Should Be Equal As Integers    ${parameter['xnLinkRef']}    2
        Should Be Equal As Integers    ${parameter['gnbPlmn']['mcc']}    540
        Should Be Equal As Integers    ${parameter['gnbPlmn']['mnc']}    1
        Should Be Equal As Integers    ${parameter['gnbPlmn']['mncLength']}    2
        Should Be Equal    ${parameter['gNodeBIdCtrl']}    oamControlled
    END
    FOR    ${parameter}    IN    ${params_nradjgnb_2}
        Should Be Equal As Integers    ${parameter['gNbIdLength']}    22
        Should Be Equal As Integers    ${parameter['gNodeBId']}    50832
        Should Be Equal As Integers    ${parameter['xnLinkRef']}    3
        Should Be Equal As Integers    ${parameter['gnbPlmn']['mcc']}    540
        Should Be Equal As Integers    ${parameter['gnbPlmn']['mnc']}    1
        Should Be Equal As Integers    ${parameter['gnbPlmn']['mncLength']}    2
        Should Be Equal    ${parameter['gNodeBIdCtrl']}    oamControlled
    END
    FOR    ${parameter}    IN    ${params_xnlink_1}
        Should Be Equal    ${parameter['cPlaneIpAddr']}    10.44.224.67
        Should Be Equal    ${parameter['cPlaneIpAddrCtrl']}    oamControlled
    END
    FOR    ${parameter}    IN    ${params_xnlink_2}
        Should Be Equal    ${parameter['cPlaneIpAddr']}    10.44.224.87
        Should Be Equal    ${parameter['cPlaneIpAddrCtrl']}    oamControlled
    END


Check Proper Values For Xnlink And Nradjgnb Objects On Target GNB 50832
    Log To Console    \nChecking Xnlink And Nradjgnb values on target GNB...
    Setup Infomodel    address=192.168.255.129   remote_host=10.44.149.147    port=443    use_ssl=True    alias=infomodel
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
    taf_admin.Setup Admin      remote_host=10.44.149.147    alias=check
    ${params_nradjgnb}=    taf_admin.Get Parameters    dist_name=${dist_name_nradjgnb}    connection=check
    ${params_xnlink}=    taf_admin.Get Parameters    dist_name=${dist_name_xnlink}    connection=check
    taf_admin.Teardown Admin    connection=check
    FOR    ${parameter}    IN    ${params_nradjgnb}
        Should Be Equal As Integers    ${parameter['gNbIdLength']}    22
        Should Be Equal As Integers    ${parameter['gNodeBId']}    50831
        Should Be Equal    ${parameter['gNodeBIdCtrl']}    gnbControlled
    END
    FOR    ${parameter}    IN    ${params_xnlink}
        Should Be Equal    ${parameter['cPlaneIpAddr']}    10.44.224.86
        Should Be Equal    ${parameter['cPlaneIpAddrCtrl']}    gnbControlled
    END


CNI-140449_ANR_triggered_Xnlink_setup_after_prior_Xnlink_removal
    Log To Console    \nStarting Test
    Start Collecting Syslog For All
    Perform Attach
    Perform Inter Gnb Handover From Gnb_1 Cell 1 To Gnb_2 Cell 1
    Detach Ue    UE_1
    Sleep    60s
    Check Nrrel And Nradjnrcell Objects Exist
    Check Nradjgnb And Xnlink Objects Exist
    Create Nradjgnb And Xnlink Objects
    Lock Unlock NRADJGNBs On Source    Locked
    Sleep    10s
    Set XnLinkRef Parameters On Source
    Lock Unlock NRADJGNBs On Source    Unlocked
    Sleep    10s
    Check Nradjgnb And Xnlink Objects Not Exist
    Stop Collecting Syslog    gNB50831
    Start Collecting Syslog    10.44.149.146    gNB50831_2
    Perform Attach
    Perform Inter Gnb Handover From Gnb_1 Cell 1 To Gnb_2 Cell 1
    Sleep    60s
    Check Specific Nradjgnb And Xnlink Objects Exist
    Stop Collecting Syslog    gNB50831_2
    Check Ho In Syslog    ${LOG_PATH}/${test_name}/syslog/syslog_gNB50831.log
    Check Ho In Syslog    ${LOG_PATH}/${test_name}/syslog/syslog_gNB50831_2.log
    Check Proper Values For Xnlink And Nradjgnb Objects On Source GNB
    Check Proper Values For Xnlink And Nradjgnb Objects On Target GNB 50832
