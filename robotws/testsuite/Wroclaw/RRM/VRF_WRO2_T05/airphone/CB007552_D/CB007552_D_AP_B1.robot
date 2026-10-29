*** Settings ***
Force Tags    RAN_5G    SBTS00    NoResUsage    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation   :copyright: Nokia
...             :authors: Kornel Dluzniewski
...             :contact: kornel.dluzniewski@nokia.com


Resource       ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       testsuite/Wroclaw/RRM/resources/airphone/scout_reporting/reporting_portal.robot

Library        ta5g_commissioning
Library        ta5g_tshark
Library        ta5g_enb
Library        ta5g_pm_counters
Library        ta5g_iphy
Library        ta5g_egate
Library        ta_messaging
Library        ta5g_ue_mobility
Library        ta5g_testline_management
Library        taf.ue



Suite Setup        Run Keywords
...                Put Swconfig File    ${SW_CONFIG}
...    AND         Update And Put Iphy Xml     input_filepath=${IPHY}
...    AND         Find Scfc And Fix And Send Full Commissioning    scfc_filename=${SCFC}

Test Setup         Run Keywords
...                Start Default Logging    output_dirpath=${OUTPUT_DIR}
...    AND         Reach Onair    lua_cfg=${EGATE}
...    AND         Wait For Next Full Pm Interval

Test Teardown      Stop Default Logging   output_dirpath=${OUTPUT_DIR}

Suite Teardown    Run Keywords
...           Stop Default Processes And Gather Logs And Compress Logs
...    AND    Add scout external execution id to reporting portal


*** Variables ***
${SW_CONFIG}                ${CURDIR}/config/swconfig.txt
${SCFC}=                    scfc_n25_n66.xml
${IPHY}=                    ${CURDIR}/config/iphy_n25_n66_LO_AP_LO.xml
${EGATE}=                   ${CURDIR}/config/n25_n66_Ho.lua
${LOCAL_MOID}=              PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${ue_id}=                   2
${HO_WITHOUT_CA_ACTIVE} =    (f1ap.HandoverPreparationInformation) && (!nr-rrc.sCellToAddModList)

*** Test Cases ***
[1][1.0] CNI_78446_B_1_SA intra-gNB Handover after inital RRC Setup with dedicated config in initialDownlinkBWP to large BWP
    Register UE
    Execute Egate Command
    ...  cmd=ue_testmode_decode_muxphychan phy_chan=decode_PDSCH
    Establish Pdu Session With Traffic      ue_id=${ue_id}    throughput=60mbps
    Perform UE Handover    ue_id=2    a2_meas_id=1    a3_meas_id=5    phycell_id=51
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 dir=ul mbps=60
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 dir=dl mbps=60
    Verify HO Without CA
    Verify That Correct BWP Profile Was Selected For The UE
    Verify Pm Counters                      local_moid=${LOCAL_MOID}

    [Teardown]    Run Keywords    Stop Default Syslog For Enb And Iphy
    ...           AND             Add Scout External Execution ID To Reporting Portal

*** Keywords ***
Register UE
    ta5g_ue_mobility.attach ue    ue_id=${ue_id}
Register UE2
    ta5g_ue_mobility.attach ue    ue_id=3
Verify Pm Counters
    [Arguments]    ${local_moid}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55166C00002    1     NRRC_RRC_RECONF_BWP2_SENT
        ...    M55166C00004    1     NRRC_RCFG_CMP_BWP2_RCVD
        ...    M55139C02502    1     GNB_SA_DU_ADM_SUCC_BWP2
        ...    M55335C05008    >0     DL_SLT_3_SYMB_ALLOC_CBWP1
        ...    local_moid=${local_moid}
        ...    file_path=${pm_counter_file}

Perform UE Handover
    [Arguments]    ${ue_id}    ${a2_meas_id}=1    ${a3_meas_id}=5    ${phycell_id}=51
    Send A2 Measurement To Reconfigure A3    ue_id=${ue_id}    a2_meas_id=${a2_meas_id}
    Send A3 Measurement To Perform UE Handover    ue_id=${ue_id}    phycell_id=${phycell_id}    a3_meas_id=${a3_meas_id}

Send A2 Measurement To Reconfigure A3
    [Arguments]    ${ue_id}    ${a2_meas_id}    ${a2_rsrp}=30
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${a2_meas_id} event\=A2 srsrp_nr\=${a2_rsrp}

Send A3 Measurement To Perform UE Handover
    [Arguments]    ${ue_id}     ${phycell_id}    ${a3_meas_id}    ${a3_rsrp}=100
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${a3_meas_id} phycell_id\=${phycell_id} nrsrp_nr\=${a3_rsrp} event\=A3
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed

Verify HO Without CA
    Verify Tcpdump Log      ${HO_WITHOUT_CA_ACTIVE}

Verify That Correct BWP Profile Was Selected For The UE
    Wait For Specified Message In Syslog    selectedBwpprofile ID:35
    Wait For Specified Message In Syslog    selectedBwpprofile ID:37
