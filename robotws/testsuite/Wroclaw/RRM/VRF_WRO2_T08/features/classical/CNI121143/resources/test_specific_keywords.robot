*** Settings ***
Documentation
...    Author: rafal.kaczmarski@nokia.com
...    Maintainer: rafal.kaczmarski@nokia.com

Library     ta_attenuator
Library     taf.ue
Library     taf.sbts.oam.coam.admin   WITH NAME   taf_admin
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CNI121143/resources/test_specific_keywords.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.elt_log_collector.EltLogCollector   WITH NAME   ELT
Library     OperatingSystem
Library     DateTime
Library     SSHLibrary
Library     taf.ul.alarms_watchdog    WITH NAME   WATCHDOG
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/allowed_alarms.py

*** Variables ***
${LOG_PATH}         ${OUTPUT_DIR}
${GNB_IP}           ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${gNB_ID}           ${tl.gnbs[0].global_bts_id}

*** Keywords ***
CNI-121143_B1_PCI_Res_Failure_No_NR_CGI
    Log To Console    \nStarting test...
    ELT.Start Log Collecting
    Perform Intra Gnb Handover From Cell 1 To Cell 3 With Failure
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${test_name}/elt_log.json
    Detach Ue    UE_1
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Check Syslog    ${OUTPUT_DIR}/${TEST_NAME}/btslog/SYSLOG_1.LOG
    Validate Pci Res Failure    ${LOG_PATH}/${test_name}/elt_log.json
    Sleep    60s
    Check NRREL Not Exists
    WATCHDOG.Check Detected Alarms


Test Setup
    Run Keyword And Ignore Error    taf_admin.Teardown All Aliases For Admin
    Delete All Nrrel And Nradjnrcell Objects
    Collect SCF Before Test
    Set Initial Parameters
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    ELT.Setup    configuration=${CONFIGURATION}
    ELT.Set Logging Filter   OTA
    ELT.Set Logging Filter   SYS    ${CODES}
    Create Syslog Collector    BtsLog.tgz
    Start Syslog


Test Teardown
    Release Attenuator
    WATCHDOG.Check Detected Alarms
    WATCHDOG.Stop Watching Alarms
    Run Keyword If Test Failed    Collect Bts Snapshot
    Add Scout Scf Id To Test Data
    Run Keyword And Ignore Error  taf_admin.Teardown All Aliases For Admin
    ELT.Shutdown


Release Attenuator
    Set Attenuation For All Cells  90dB
    Release attenuator cell    ${gnb_cells}


Verify Bts Is Operational
    Log To Console  \nBTS Verification Ongoing...
    Verify Gnb Is OnAir
    WATCHDOG.Check Detected Alarms


Delete All Nrrel And Nradjnrcell Objects
    [Arguments]    ${cell_1_id}=1
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nrrel_del
    ${params}    Get Empty List
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRREL-256
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRREL-1
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRREL-2
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJNRCELL-12288
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJNRCELL-2
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJNRCELL-3
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    taf_admin.Teardown Admin    connection=nrrel_del


Set Initial Attenuation
    ${cell_list}=   Create list   GNB_1_CELL_1    GNB_1_CELL_2    GNB_1_CELL_3   GNB_2_CELL_1   GNB_2_CELL_2
    Set global variable   ${GNB_CELLS}   ${cell_list}
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of    ${gnb_cells}
    Set Attenuation    ${GNB_1_CELL_2_ALIAS}    90dB
    Set Attenuation    ${GNB_1_CELL_3_ALIAS}    90dB
    Set Attenuation    ${GNB_2_CELL_1_ALIAS}    90dB
    Set Attenuation    ${GNB_2_CELL_2_ALIAS}    90dB
    Set Attenuation    ${GNB_1_CELL_1_ALIAS}    0dB
    Sleep  2s


Prepare Ue
    Set Initial Attenuation
    Require Ue    UE_1    capabilities=REAL_ANDROID_UE
    Detach Ue     UE_1


Perform Attach
    Prepare Ue
    Attach UE    UE_1
    Sleep   5s


Perform Intra Gnb Handover From Cell 1 To Cell 3 With Failure
    Perform Attach
    Log To Console    \nStarting IntraGnb Inter Freq HO...
    Set Attenuation    GNB_1_CELL_1    0db
    Set Attenuation    GNB_1_CELL_3    30db
    Start Data Transfer    dt_name=DT_1    ue_alias=UE_1    direction=dl    duration=60s    protocol=udp
    ...                    throughput=300Mbits/sec    packet_size=1400
    FOR    ${i}  IN RANGE  0  42  2
        Set Attenuation  GNB_1_CELL_1  ${i}db
        Sleep  1s
    END
    Set Attenuation    GNB_1_CELL_1    0db
    Await Data Transfer Finish    DT_1


Check NRREL Not Exists
    [Arguments]    ${cell_id}=1
    taf_admin.Setup Admin    name=nrrel_status
    ${nrrel_status}    taf_admin.Get Scf    connection=nrrel_status
    Should Not Contain    ${nrrel_status}    distName="MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-${cell_id}/NRREL-256
    taf_admin.Teardown Admin    connection=nrrel_status
