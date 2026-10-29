*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    ../5GC001354/CB001354_keywords.robot
Resource    keywords_CB008828.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ta5g_pm_counters
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.config.wts       WITH NAME    wts
Variables     CB008828_variables.py

Documentation
...    author: Pawel Konieczny
...    maintainer: Pawel Konieczny (pawel.konieczny@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 24R2

Suite Setup     Run Keywords    Enable Syslog Info Level Prints
    ...       AND    Enable X2 Measurments
    ...       AND    Enable Actslicenumext
    ...       AND    Enable 25 Snssai Objects
    ...       AND    Enable Pmqap Moc Nsa Qci6
    ...       AND    Configure Additional Slices In Cfg

Test Setup      Run Keywords    Prepare Sa Test Environement And Reach Onair
    ...              perform_tl_reset=${RESET_TL}
    ...              cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
    ...       AND    Set Internal Traffic Type To UEs
Test Teardown    Run Keywords    Check For An Unexpected Alarm
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs
    ...       AND    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s
${TIME_FOR_X2_UP}=         5s

*** Test Cases ***
CB008828_Counters_From_CB008204_Should_Be_Incremented
    Sleep    ${TIME_FOR_X2_UP}
    Attach Ue To Enb    ue_id=11
    Start Gnb Addition Procedure    ue=11    bearer=2    target_cells=1    dc_type=split_scg
    Start Low Dl And Ul Data Traffic With Udp
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats
    Verify If Dl Pdcp Sdus Were Transmitted For Nsa Bearer
    Verify If Specyfic Cb008204 Pdcp Sdu Pm Counters Are Incremented With Cb008828
    Detach Ue    ue_id=11

*** Keywords ***
Enable Pmqap Moc Nsa Qci6
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_Pmqap_Moc_Nsa_Qci6.json

Start Low Dl And Ul Data Traffic With Udp
    Start Data Traffic  ues=11    bearer_id=2    direction=dl    throughput=5mbps    optional_parameters=protocol=udp
    Start Data Traffic  ues=11    bearer_id=2    direction=ul    throughput=5mbps    optional_parameters=protocol=udp

Force Packet Losts On X2-U
    Execute Egate Command    cmd=bearer_ue_gnb_param ue=11 id=2 dud_retx_indication=on
    Execute Egate Command    cmd=ue_enb_endc_param id=11 bearer=5 dud_drop_cfg=5:5

Display Bearer Stats
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=11 id=2

Verify If Dl Pdcp Sdus Were Transmitted For Nsa Bearer
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_SDU_TX_NSA_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_TX_NSA_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify If Specyfic Cb008204 Pdcp Sdu Pm Counters Are Incremented With Cb008828
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_UL_PDCP_SDU_CU_PMQAP}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_PDCP_SDU_USDAT_CU_PMQAP}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_PDCP_SDU_VOL_RCV_PMQAP}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1   filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_UL_PDCP_SDU_VOL_SNT_PMQAP}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1   filepath=${PM_COUNTERS}

