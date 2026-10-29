*** Settings ***
Force Tags    CONFIGURED   CRT    RAN_5G    SBTS00    CLOUD_5G_I_[LO][LO]_AP_[LOO]

Documentation   :copyright: Nokia
...             :authors: Edyta Rudnik

Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       ../../WRO_2/keywords/logging.robot
Resource       feature_keywords.robot
Resource       testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/tshark_verifying.robot
Resource       testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/traffic.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/Error_finder.robot
Library        ta5g_commissioning
Library        ta5g_enb
Library        ta5g_iphy
Library        ta5g_ue_mobility
Library        ute_fsmaccess
Library        ta5g_pm_counters
Library        ta5g_ue_measurements
Library        ta5g_throughput
Library        ../../resources/scout_report.py
Library        ../resources/multignb_variables.py
Library        ../resources/syslog_collector.py
Variables      ../resources/remote_host_policy.py


Suite Setup        Run Keywords
...                Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Log To Console    message=${REMOTE_HOSTS}
...    AND         Update And Put Iphy Xml         input_filepath=${IPHY}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_2}
...                remote_host=${REMOTE_HOST_1_IP}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_1}
...    AND         Reach Onair    lua_cfg=${cfg}    remote_hosts=${REMOTE_HOSTS}

Suite Teardown    Compress Test Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    remote_host=${REMOTE_HOST_1_IP}


*** Variables ***
${IPHY}=                         ${CURDIR}/config/iphy_MN_AHFII_AHLOA_AHFIB_SN_AHFII_AHLOA_AHFIB.xml
${cfg}=                          ${CURDIR}/config/cfg_40UEs_5CC_6CC.cfg
${SCFC_GNB_1}=                   scfc_CD_gnb1_n25_3A_n66_2A_n71A.xml
${SCFC_GNB_2}=                   scfc_CD_gnb2_n25_2A_n66_2A_n71B.xml
${delta_3CC}=                    Delta_3CC_FDD.json
${delta_5CC}=                    Delta_5CC_FDD.json
${delta_6CC}=                    Delta_6CC_FDD.json
${delta_max_num_of_CA_users}=    delta_maxNumOfCaUsersNRCell_40.json
@{FAULT_IDS_LIST}=               6450    4383    2087    7101
@{REMOTE_HOSTS}=                 None

*** Test Cases ***
CB008055_C_D_Multi_UE_5CC6CC_DL_2CC_UL_SCell_Addition_Mobility_Robustness
    Start Collecting Syslog From Gnbs
    Set Internal Traffic Type For Ue    ue=1-40    pdu=1
    Attach Multiple Ues    first_ue_id=1    last_ue_id=40   enb=2    cell=1
    Wait For Next Full Pm Interval
    Setup PDU Session for UE#1-UE#40 with one non-GBR QoS Flow- 5QI 6
    Perform PDU Session Modification By Adding 5QI    first_UE=6    last_UE=10    5QI=5
    Perform PDU Session Modification By Adding 5QI    first_UE=6    last_UE=10    5QI=1
    UE#1-UE#40 sends A1 measurement With MeasId-2 For SCell Addition To PhyCellId 51
    Start non-GBR 40 MBPS DL Data Traffic For UEs With IDs 1-40 On 5QI 6 With Traffic Id 1
    Start 3 MBPS UL data traffic for UEs with IDs 1-40 On 5QI 6
    Start VoNR data traffic for UEs with IDs 1-5
    Verify A1 Meas Based 5CC 6CC SCell Addition PM counters In saCell#1 For 12 5CC UEs and 28 6CC UEs
    Verify nonGBR and GBR Counters in saCell-1
    Verify UL CA Counters Are Incremented To Value Higher Than 38 In SaCell-1
    Verify DRX Counters in saCell-1
    Verify DL throughput for 5CC 6CC 30 CA UEs

    Wait For Next Full Pm Interval
    UE#6-UE#15 sends A2 measurement For PCell Switch To Cell-4
    UE#21-UE#30 sends A2 measurement For PCell Switch To Cell-4
    Verify DL and UL throughput After PCell Switch
    UE#6-UE#15 sends A1 measurement With MeasId-9 For SCell Addition To PhyCellId 54
    UE#21-UE#30 sends A1 measurement With MeasId-9 For SCell Addition To PhyCellId 54
    Verify A1 Meas Based 5CC 6CC SCell Addition PM counters In saCell#4 For 0 5CC UEs and 20 6CC UEs
    Verify Counters after PCell Switch From saCell#1 to saCell#4
    Verify DRX Counters in saCell-4
    Verify UL CA Counters Are Incremented To Value Higher Than 19 In SaCell-4

    Wait For Next Full Pm Interval
    UE#6-UE#15 sends A2 measurement For PCell Switch to Cell-1
    UE#21-UE#30 sends A2 measurement For PCell Switch to Cell-1
    Verify DL and UL throughput After PCell Switch
    UE#6-UE#15 sends A1 measurement With MeasId-18 For SCell Addition To PhyCellId 51
    UE#21-UE#30 sends A1 measurement With MeasId-18 For SCell Addition To PhyCellId 51
    Start non-GBR 40 MBPS DL Data Traffic For UEs With IDs 1-40 On 5QI 6 With Traffic Id 2
    Verify A1 Meas Based 5CC 6CC SCell Addition PM counters In saCell#1 For 0 5CC UEs and 20 6CC UEs
    Verify Counters after PCell Switch From saCell#4 to saCell#1
    Verify DRX Counters in saCell-1
    Verify UL CA Counters Are Incremented To Value Higher Than 19 In SaCell-1
    Verify DL throughput for 5CC 6CC 30 CA UEs

    Wait For Next Full Pm Interval
    UE#6-UE#15 sends A2 measurement with measId-17 below threshold for inter-frequency HO
    UE#21-UE#30 sends A2 measurement with measId-17 below threshold for inter-frequency HO
    UE#6-UE#15 sends A3 measurement with measId-26 for inter-frequency inter-gNB HO to psycell_id-60
    UE#21-UE#29 sends A3 measurement with measId-26 for inter-frequency inter-gNB HO to psycell_id-60
    run keyword and expect error    *    UE#30-UE#30 sends A3 measurement with measId-26 for inter-frequency inter-gNB HO to psycell_id-60
    Verify HO On Source gNB
    Verify HO And CA Counters On Target gNB
    Verify DL throughput for 5CC 6CC 30 CA UEs

    Wait For Next Full Pm Interval
    UE#6-UE#15 sends A2 measurement with measId-28 below threshold for inter-frequency HO
    UE#21-UE#30 sends A2 measurement with measId-28 below threshold for inter-frequency HO
    UE#6-UE#15 sends A3 measurement with measId-30 for inter-frequency inter-gNB HO to psycell_id-51
    UE#21-UE#29 sends A3 measurement with measId-30 for inter-frequency inter-gNB HO to psycell_id-51
    UE#6-UE#15 sends A1 measurement With MeasId-32 For SCell Addition To PhyCellId 51
    UE#21-UE#29 sends A1 measurement With MeasId-32 For SCell Addition To PhyCellId 51
    Verify A1 Meas Based 5CC 6CC SCell Addition PM counters In saCell#1 For 0 5CC UEs and 19 6CC UEs

    Wait For Next Full Pm Interval
    UE#6-UE#15 perform inter-cell HO
    UE#21-UE#29 perform inter-cell HO
    Verify DL throughput for 5CC 6CC 30 CA UEs

    [Teardown]     Run Keywords    Deregister UE    ue_id=1-40
    ...            AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
    ...            AND    Stop Collecting Syslog And Download Files
    ...            AND    Find Errors    remote_host=True
    ...            AND    Add Scout Scf Id To Test Data
    ...            AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...            AND    Collect Selected Debug Files
    ...                   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                   omit_collectors=sos_report
    ...            AND    Get BTS Snapshot
    ...                   output_filepath=${OUTPUT_DIR}/${TEST_NAME}/remote_host_bts_snapshot.zip
    ...                   remote_host=${REMOTE_HOST_1_IP}


*** Keywords ***
Verify nonGBR and GBR Counters in saCell-${cell_id}
       ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
       Verify Any Counters In File
       ...   M55138C00015     45   PEAK_NUMBER_OF_SA_NGBR
       ...   M55138C00016     40   PEAK_NUMBER_OF_SA_NGBR_USERS
       ...   M55138C01001     5    GBR_DRB_REQ
       ...   M55138C01002     5    GBR_DRB_SUCC
       ...   M55138C01007     5    PEAK_NUMBER_OF_SA_GBR
       ...   M55125C09517     5    NG_FLOW_SETUP_ATT_TOT_5QI1
       ...   M55125C09518     5    NG_FLOW_SETUP_SUCC_TOT_5QI1
       ...   M55125C09530     5    PEAK_NUMBER_OF_UE_5QI1
       ...   local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${cell_id}
       ...   file_path=${pm_counter_file}

Verify UL CA Counters Are Incremented To Value Higher Than ${value} In SaCell-${cell_id}
       ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
       Verify Last Counters In File
       ...   M55118C10001    >${value}    RRC_RECONF_ADD1ULSCELL_ATT_SA
       ...   M55118C10002    >${value}    RRC_RECONF_ADD1ULSCELL_SUCC_SA
       ...   M55156C10007    >${value}    MAX_UE_PCELL_1_CONF_SCEL_UL_SA
       ...   local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${cell_id}
       ...   file_path=${pm_counter_file}
       #due to load balancing not all UEs will be configured with UL CA

Verify DRX Counters in saCell-${cell_id}
       ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
       Verify Last Counters In File
       ...   M55308C11001    >1000    SLOTS_UE_DRX_ACTIVE
       ...   local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${cell_id}
       ...   file_path=${pm_counter_file}

Verify DL throughput for 5CC 6CC 30 CA UEs
    Verify DL thoughput For UE#1-UE#5 On 4 SCells
    Verify DL thoughput For UE#6-UE#15 On 5 SCells
    Verify DL thoughput For UE#16-UE#20 On 4 SCells
    Verify DL thoughput For UE#21-UE#30 On 5 SCells

UE#${fist_UE}-UE#${last_UE} sends A2 measurement For PCell Switch To Cell-4
    FOR    ${UE}     IN RANGE   ${fist_UE}    ${last_UE}+1
    Execute Egate Command
    ...     cmd=ue_measurement_send_nr id=${UE} meas_id=8 event=A2 srsrp_nr=11 srsrq_nr=11 scell=3 scell_rsrp=12 scell_rsrq=12
    ...     pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.4 performed
    Log To Console    PCell Switch from Cell 1 to Cell 4 executed for UE ${UE}
    Wait 2s For PCell Switch
    END

UE#${fist_UE}-UE#${last_UE} sends A2 measurement For PCell Switch To Cell-1
    FOR    ${UE}     IN RANGE   ${fist_UE}    ${last_UE}+1
    Execute Egate Command
    ...     cmd=ue_measurement_send_nr id=${UE} meas_id=16 event=A2 srsrp_nr=11 srsrq_nr=11 scell=1 scell_rsrp=12 scell_rsrq=12
    ...     pass_regexp=Intra-eNB handover from EXT_ENB-2.4 to EXT_ENB-2.1 performed
    Log To Console    PCell Switch from Cell 4 to Cell 1 executed for UE ${UE}
    Wait 2s For PCell Switch
    END

UE#${fist_UE}-UE#${last_UE} sends A2 measurement with measId-${meas_id} below threshold for inter-frequency HO
    FOR    ${UE}     IN RANGE   ${fist_UE}    ${last_UE}+1
    Execute Egate Command
    ...     cmd=ue_measurement_send_nr id=${UE} meas_id=${meas_id} event=A2 srsrp_nr=1 srsrq_nr=1
    Log To Console     UE-${UE} sent A2 measurement for HO purposes
    Wait 2s For A2 measurement processing
    END

Verify Counters after PCell Switch From saCell#${source_cell_id} to saCell#${target_cell_id}
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...   M55118C00013    >1000   UE_PCELL_5_CONF_SCELL_DL_SA
    ...   local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${target_cell_id}
    ...   file_path=${pm_counter_file}
    Verify Last Counters In File
    ...   M55118C00094    >0     PCELL_UL_1_SCELL_CONFIG_DUR_SA
    ...   local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${source_cell_id}
    ...   file_path=${pm_counter_file}

Verify DL and UL throughput After PCell Switch
    Verify DL thoughput For UE#6-UE#15 On 1 SCells
    Verify DL thoughput For UE#21-UE#30 On 1 SCells
    Verify UL thoughput For UE#6-UE#15 On 1 SCells
    Verify UL thoughput For UE#21-UE#30 On 1 SCells

UE#${first_UE}-UE#${last_UE} sends A3 measurement with measId-${meas_id} for inter-frequency inter-gNB HO to psycell_id-60
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Execute Egate Command
    ...     cmd=ue_measurement_send_nr id=${UE} meas_id=${meas_id} event=A3 srsrp_nr=1 phycell_id=60 nrsrp_nr=120
    ...     pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to EXT_ENB-3.10 performed
    Log To Console    Inter-eNB handover from EXT_ENB-2.1 to EXT_ENB-3.10 performed for UE#${UE}
    END

UE#${first_UE}-UE#${last_UE} sends A3 measurement with measId-${meas_id} for inter-frequency inter-gNB HO to psycell_id-51
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Execute Egate Command
    ...     cmd=ue_measurement_send_nr id=${UE} meas_id=${meas_id} event=A3 srsrp_nr=1 phycell_id=51 nrsrp_nr=120
    ...     pass_regexp=Inter-eNB handover from EXT_ENB-3.10 to EXT_ENB-2.1 performed
    Log To Console    Inter-eNB handover from EXT_ENB-3.10 to EXT_ENB-2.1 performed for UE#${UE}
    END

UE#${first_UE}-UE#${last_UE} perform inter-cell HO
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
        Execute Egate Command
    ...     cmd=ue_reauth id=${UE} nr_sec_cap=zuc|zuc
    ...     pass_regexp=Reauthentication procedure is complete
    Log To Console   Intra-Cell Handover executed for UE#${UE}
    END

Verify HO On Source gNB
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C02002      20      NRRCC_MEAS_A2_REC
    ...    M55143C00001      19      XN_HO_REQ_ACK_RECEIVED
    ...    M55143C00004      20      XN_HO_REQ_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-1
    ...    file_path=${pm_counter_file}

Verify HO And CA Counters On Target gNB
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File    remote_host=${REMOTE_HOST_1_IP}
    Verify Last Counters In File
    ...   M55143C00005       20     XN_HO_REQ__RECEIVED
    ...   M55143C00006       19     XN_HO_REQ_ACK_SENT
    ...   M55118C10001       >18    RRC_RECONF_ADD1ULSCELL_ATT_SA
    ...   M55118C10002       >18    RRC_RECONF_ADD1ULSCELL_SUCC_SA
    ...   M55138C01011       5      SA_HO_GBR_DRB_REQ
    ...   M55138C01013       5      SA_HO_GBR_DRB_SUCC
    ...   M55118C00001       19     RRC_RECONF_ADD5DLSCELL_ATT_SA
    ...   M55118C00004       19     RRC_RECONF_ADD5DLSCELL_SUCC_SA
    ...   M55118C11055       19     GNB_DL_SCELL_5_CONFIG_REQ_SA
    ...   M55118C11065       19     GNB_DL_SCELL_5_CONFIG_SUCC_SA
    ...   M55138C03504       19     GNB_SCELL_5_ADMI_REQ_SA
    ...   M55138C03507       19     GNB_SCELL_5_ADMI_SUCC_SA
    ...   M55138C03514       19     GNB_DL_SCELL_5_ADMI_REQ_SA
    ...   M55138C03521       19     GNB_DL_SCELL_5_ADMI_SUCC_SA
    ...   M55139C05506       19     GNB_DU_DL_SCELL_5_ADMI_REQ_SA
    ...   M55139C05513       19     GNB_DU_DL_SCELL_5_ADMI_SUCC_SA
    ...   M55139C03003       19     GNB_DU_SCELL_5_ADMI_REQ_SA
    ...   M55139C03006       19     GNB_DU_SCELL_5_ADMI_SUCC_SA

    ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRCELL-10
    ...    file_path=${pm_counter_file}
