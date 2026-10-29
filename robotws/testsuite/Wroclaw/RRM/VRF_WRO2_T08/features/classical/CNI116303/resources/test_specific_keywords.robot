*** Settings ***
Documentation
...    author:  Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Library     OperatingSystem
Library     DateTime
Library     ta_attenuator
Library     ute_ue
Library     SSHLibrary
Library     ute_admin_infomodel
Library     taf.sbts.oam.coam.admin   WITH NAME   taf_admin
Library     taf.ul.alarms_watchdog    WITH NAME   WATCHDOG
Library     ute_tshark   WITH NAME   tshark
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CNI116303/resources/test_specific_keywords.py
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CNI116303/resources/test_specific_keywords.py
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/allowed_alarms.py

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

*** Keywords ***
Test Setup
    [Arguments]    ${all_objects_removal}=${FALSE}    ${create_nrrel_nradjnrcell}=${FALSE}
    Set Test Variable  ${all_objects_removal}
    Set Test Variable  ${create_nrrel_nradjnrcell}
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    Verify Bts Is Operational
    Delete All Nrrele And Nradjecell Objects
    Prepare Ue
    IF    ${all_objects_removal}    Remove XNLINK And NRADJGNB Objects
    Collect SCF Before Test


Test Teardown
    WATCHDOG.Check Detected Alarms
    WATCHDOG.Stop Watching Alarms
    Run Keyword If Test Failed    Killall Tcpdump After Test    @{MPLANE_LIST}
    Run Keyword And Ignore Error    taf_admin.Teardown All Aliases For Admin
    Run Keyword And Ignore Error    tshark.Teardown All Aliases For Tshark
    Run Keyword And Continue On Failure    Detach Ue    UE_1
    Set actIntraNrNgHo    sourceAndTarget
    Set Attenuation    ${GNB_1_CELL_1_ALIAS}    90dB
    Set Attenuation    ${GNB_1_CELL_2_ALIAS}    90dB
    Set Attenuation    ${GNB_1_CELL_4_ALIAS}    90dB
    Set Attenuation    ${GNB_2_CELL_1_ALIAS}    90dB
    Release Attenuator
    Run Keyword If Test Failed    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Run Keyword If Test Failed    Collect BTS Snapshot
    Add Scout Scf Id To Test Data
    Delete All Nrrele And Nradjecell Objects
    Run Keyword And Ignore Error    interface.Common Step Trigger


Prepare Ue
    Set Initial Attenuation
    Require Ue    UE_1    capabilities=REAL_ANDROID_UE
    Detach Ue     UE_1


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


Delete All Nrrele And Nradjecell Objects
    [Arguments]    ${cell_1_id}=1
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRREL-256
    ...                                         parameter=@{EMPTY}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRREL-255
    ...                                         parameter=@{EMPTY}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRREL-1
    ...                                         parameter=@{EMPTY}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJNRCELL-12288
    ...                                         parameter=@{EMPTY}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJNRCELL-1
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



Perform Inter Gnb Handover From Gnb_1 Cell 1 To Gnb_2 Cell 1
    Perform Attach
    Trigger Inter-gNB HO
    Sleep   2s


Perform Attach
    Set Attenuation    ${GNB_1_CELL_1_ALIAS}    0dB
    Sleep   10s
    Attach UE    UE_1
    Log To Console    UE_1 attached!
    Sleep   5s


Trigger Inter-gNB HO
    Log To Console    Starting InterGNB HO...
    Set Attenuation    GNB_2_CELL_1    0db
    FOR    ${i}  IN RANGE  0  90  1
        Set Attenuation  GNB_1_CELL_1  ${i}db
        Sleep  1s
    END
    Log To Console    HO procedure done...


Set actIntraNrNgHo
    [Arguments]  ${actIntraNrNgHo}
    Log To Console    \nSetting Up actIntraNrNgHo = ${actIntraNrNgHo}
    taf_admin.Setup Admin      bts_host=${gNB_IP}    alias=actIntraNrNgHo
    taf_admin.Create Delta    delta_id=actIntraNrNgHo
    taf_admin.Append Parameter Update To Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}    actIntraNrNgHo
    ...                                         ${actIntraNrNgHo}    delta_id=actIntraNrNgHo
    ${delta}    taf_admin.Get Delta    delta_id=actIntraNrNgHo
    taf_admin.Remove All Delta Id
    taf_admin.Perform Delta Recommissioning    ${delta}    connection=actIntraNrNgHo
    taf_admin.Teardown Admin    alias=actIntraNrNgHo


CNI-116303_B1_Measurement_Report_Handing_With_Unknown_PCI_NG_Allowed
    Log To Console    \nStarting Test
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    B_1
    Start Syslog
    Start TCP Dump
    Perform Inter Gnb Handover From Gnb_1 Cell 1 To Gnb_2 Cell 1
    Log To Console    Waiting For ANR Objects to appear...
    Sleep     60s
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Check Nrrel And Nradjnrcell Objects Exist
    Check Nradjgnb And Xnlink Objects Exist
    Verify B1 Pcap


CNI-116303_B2_Measurement_Report_Handing_With_Unknown_PCI_NG_Not_Allowed
    Log To Console    \nStarting Test
    Set actIntraNrNgHo    disabled
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    B_2
    Start Syslog
    Start TCP Dump
    Perform Inter Gnb Handover From Gnb_1 Cell 1 To Gnb_2 Cell 1
    Log To Console    Waiting For ANR Objects to appear...
    Sleep     60s
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Verify B2 Pcap


CNI-116303_B2_Alt1_Measurement_Report_Handing_With_Known_PCI_NG_Not_Allowed
    Log To Console    \nStarting Test
    Set actIntraNrNgHo    disabled
    Create Nradjcell And Nrrel Objects
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    B_2_alt1
    Start Syslog
    Start TCP Dump
    Perform Inter Gnb Handover From Gnb_1 Cell 1 To Gnb_2 Cell 1
    Log To Console    Waiting For ANR Objects to appear...
    Sleep     60s
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Verify B2 Alt1 Pcap
