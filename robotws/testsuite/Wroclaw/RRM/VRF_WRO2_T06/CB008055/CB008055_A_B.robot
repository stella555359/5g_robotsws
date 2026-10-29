*** Settings ***
Force Tags    CONFIGURED   CRT    RAN_5G    SBTS00    CLOUD_5G_I_[LO][LO]_AP_[LOO]

Documentation   :copyright: Nokia
...             :authors: Edyta Rudnik

Resource       ../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/logging.robot
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
Library        ta5g_file_system
Library        ../../resources/scout_report.py
Library        ../resources/multignb_variables.py


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
${SCFC_GNB_1}=                   scfc_AB_gnb1_n25_3A_n66_2A_n71A.xml
${SCFC_GNB_2}=                   scfc_AB_gnb2_n25_2A_n66_2A_n71B.xml
${delta_3CC}=                    Delta_3CC_FDD.json
${delta_5CC}=                    Delta_5CC_FDD.json
${delta_6CC}=                    Delta_6CC_FDD.json
${delta_max_num_of_CA_users}=    delta_maxNumOfCaUsersNRCell_40.json
@{FAULT_IDS_LIST}=               6450    4383    2087    7101
@{REMOTE_HOSTS}=                 None

*** Test Cases ***
CB008055_A_B_Multi_UE_5CC6CC_DL_SCell_Addition_Robustness
    Set Internal Traffic Type For Ue    ue=1-40    pdu=1
    Attach Multiple Ues    first_ue_id=1    last_ue_id=15   enb=2
    Wait For Next Full Pm Interval
    Setup PDU Session for UE#1-UE#15 with one non-GBR QoS Flow- 5QI 6
    Perform PDU Session Modification By Adding 5QI    first_UE=1    last_UE=14    5QI=5
    Perform PDU Session Modification By Adding 5QI    first_UE=1    last_UE=14    5QI=1
    Start non-GBR 80 MBPS DL Data Traffic For UEs With IDs 1-14 On 5QI 6 With Traffic ID 1
    Start 5 MBPS UL data traffic for UEs with IDs 1-14 On 5QI 6
    Start VoNR data traffic for UEs with IDs 1-14
    Start Ping Tput For UE    UE_ID=15
    Verify Blind 5CC 6CC PM Counters For 15UEs In saCell-1

    Wait For Next Full Pm Interval
    Perform RRCReestablishment via RRC Setup For UE#1 - UE#15
    Wait 60s For RRCRelease
    Verify Blind 5CC and 6CC SCell Addition And Reestablishment PM counters in saCell#1
    Start non-GBR 80 MBPS DL Data Traffic For UEs With IDs 1-14 On 5QI 6 With Traffic ID 1
    Start 5 MBPS UL data traffic for UEs with IDs 1-14 On 5QI 6
    Start Ping Tput For UE    UE_ID=15

    Wait For Next Full Pm Interval
    Perform PDU Session Modification By Adding 5QI    first_UE=1    last_UE=14    5QI=2
    Perform PDU Session Modification By Removing 5QI    first_UE=1     last_UE=14    5QI=2
    Perform PDU Session Modification By Removing 5QI    first_UE=1     last_UE=14    5QI=1
    Perform PDU Session Modification By Removing 5QI    first_UE=1     last_UE=14    5QI=5
    Verify nonGBR and GBR Counters After Blind SCell Addition For 15UEs
    Verify DL thoughput For UE#1-UE#5 On 4 SCells
    Verify DL thoughput For UE#6-UE#14 On 5 SCells
    Verify DL thoughput For UE#15

    Wait For Next Full Pm Interval
    Attach Multiple Ues    first_ue_id=16    last_ue_id=35    enb=2
    Setup PDU Session for UE#16-UE#35 with one non-GBR QoS Flow- 5QI 6
    Start non-GBR 80 MBPS DL Data Traffic For UEs With IDs 16-35 On 5QI 6 With Traffic ID 1
    UE#16-UE#35 sends A1 measurement With MeasId-1 For SCell Addition To PhyCellId 53
    Verify A1 Meas Based 5CC 6CC SCell Addition PM counters In saCell#3 For 5 5CC UEs and 15 6CC UEs

    Wait For Next Full Pm Interval
    Perform PDU Session Modification By Adding 5QI    first_UE=16    last_UE=25    5QI=5
    Perform PDU Session Modification By Adding 5QI    first_UE=16    last_UE=25    5QI=1
    Perform PDU Session Modification By Adding 5QI    first_UE=16    last_UE=25    5QI=2
    Start VoNR Data Traffic For UEs With IDs 16-25
    Start Video Call data traffic for UEs with IDs 16-25
    Perform PDU Session Modification By Removing 5QI    first_UE=16     last_UE=25   5QI=2
    Perform PDU Session Modification By Removing 5QI    first_UE=16     last_UE=25    5QI=1
    Verify nonGBR and GBR Counters After A1based SCell Addition For 20UEs
    Verify DL thoughput For UE#16-UE#20 On 4 SCells
    Verify DL thoughput For UE#21-UE#35 On 5 SCells

    Wait For Next Full Pm Interval
    Find Scfc and Send Delta Commissioning   scfc_filename=${delta_5CC}
    Attach UE    ue_id=36    enb=2    cell=3    # UE#36 is 6CC Capable
    Setup PDU Session for UE#36-UE#36 with one non-GBR QoS Flow- 5QI 6
    Perform PDU Session Modification By Adding 5QI    first_UE=36    last_UE=36    5QI=5
    Perform PDU Session Modification By Adding 5QI    first_UE=36    last_UE=36    5QI=1
    Start non-GBR 80 MBPS DL Data Traffic For UEs With IDs 36-36 On 5QI 6 With Traffic ID 1
    Delay RRCReconfigurationComplete For UE    ue_id=36
    Send Ue Measurement Nr    ue_id=36    meas_id=1    phycell_id=53    srsrp_nr=80    event=A1
    Verify A1 meas based 5CC SCell Addition And Lack Of RRCReconfigurationComplete PM counters in saCell#3

    Wait For Next Full Pm Interval
    Find Scfc and Send Delta Commissioning   scfc_filename=${delta_3CC}
    Attach UE    ue_id=37    enb=2    cell=3
    Setup PDU Session for UE#37-UE#37 with one non-GBR QoS Flow- 5QI 6
    Start non-GBR 80 MBPS DL Data Traffic For UEs With IDs 37-37 On 5QI 6 With Traffic ID 1
    Send Ue Measurement Nr    ue_id=37    meas_id=1    phycell_id=53    srsrp_nr=80    event=A1
    Verify A1 meas based 4CC SCell Addition For UE#37
    Verify DL thoughput For UE#37-UE#37 On 3 SCells

    Wait For Next Full Pm Interval
    Find Scfc and Send Delta Commissioning   scfc_filename=${delta_6CC}
    Attach UE    ue_id=38    enb=2    cell=3
    Setup PDU Session for UE#38-UE#38 with one non-GBR QoS Flow- 5QI 6
    Start non-GBR 80 MBPS DL Data Traffic For UEs With IDs 38-38 On 5QI 6 With Traffic ID 1
    Send Ue Measurement Nr    ue_id=38    meas_id=1    phycell_id=53    srsrp_nr=80    event=A1
    Verify A1 Meas Based 5CC 6CC SCell Addition PM counters In saCell#3 For 1 5CC UEs and 0 6CC UEs
    Verify DL thoughput For UE#38-UE#38 On 4 SCells

    Wait For Next Full Pm Interval
    Attach UE    ue_id=39    enb=2    cell=3
    Setup PDU Session for UE#39-UE#39 with one non-GBR QoS Flow- 5QI 6
    Start non-GBR 80 MBPS DL Data Traffic For UEs With IDs 39-39 On 5QI 6 With Traffic ID 1
    Send Ue Measurement Nr    ue_id=39    meas_id=1    phycell_id=53    srsrp_nr=80    event=A1
    Verify RAC Failure For 5CC UE In NrCell-3

    Find Scfc and Send Delta Commissioning   scfc_filename=${delta_max_num_of_CA_users}
    Deregister Ue    ue_id=1-15
    Deregister Ue    ue_id=36-39
    Trigger RLF For UE#16 - UE#35
    Deactivate RLF profile For UE#16 - UE#35
    Exit Idle Mode For UE#16-UE#35

    Wait For Next Full Pm Interval
    Attach Multiple Ues    first_ue_id=1    last_ue_id=15    enb=2    cell=3
    Attach Multiple Ues    first_ue_id=36    last_ue_id=40    enb=2    cell=3
    Setup PDU Session for UE#1-UE#15 with one non-GBR QoS Flow- 5QI 6
    Setup PDU Session for UE#36-UE#40 with one non-GBR QoS Flow- 5QI 6
    Wait For Next Full Pm Interval
    UE#1-UE#40 sends A1 measurement With MeasId-1 For SCell Addition To PhyCellId 53

    Verify A1 Meas Based 5CC 6CC SCell Addition PM counters In saCell#3 For 12 5CC UEs and 28 6CC UEs
    Start non-GBR 60 MBPS DL Data Traffic For UEs With IDs 1-40 On 5QI 6 With Traffic Id 2
    Verify DL throughput for 5CC 6CC 30 CA UEs
    [Teardown]     Run Keywords    Deregister UE    ue_id=1-40
    ...            AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
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
Verify DL thoughput For UE#15
    Wait Until Keyword Succeeds    5x    5sec    Expected Throughput For Ue Should Be Reached    ue_id=15    retry=0    throughput=0.16
    ...    direction=dl    selection_type=average    layer=physical    scells=0-0  margin=0.15

Verify DL throughput for 5CC 6CC 30 CA UEs
    Verify DL thoughput For UE#1-UE#5 On 4 SCells
    Verify DL thoughput For UE#6-UE#15 On 5 SCells
    Verify DL thoughput For UE#16-UE#20 On 4 SCells
    Verify DL thoughput For UE#21-UE#30 On 5 SCells

Verify Blind 5CC 6CC PM Counters For 15UEs In saCell-${cell_id}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
       ...   M55118C02015      5      RRC_RECONF_ADD4DLSCELL_ATT_SA
       ...   M55118C02014      5      RRC_RECONF_ADD4DLSCELL_SUCC_SA
       ...   M55118C11054      5      GNB_DL_SCELL_4_CONFIG_REQ_SA
       ...   M55118C11064      5      GNB_DL_SCELL_4_CONFIG_SUCC_SA
       ...   M55138C00048      5      GNB_SCELL_4_ADMI_REQ_SA
       ...   M55138C00049      5      GNB_SCELL_4_ADMI_SUCC_SA
       ...   M55138C03513      5      GNB_DL_SCELL_4_ADMI_REQ_SA
       ...   M55138C03520      5      GNB_DL_SCELL_4_ADMI_SUCC_SA
       ...   M55139C05505      5      GNB_DU_DL_SCELL_4_ADMI_REQ_SA
       ...   M55139C05512      5      GNB_DU_DL_SCELL_4_ADMI_SUCC_SA
       ...   M55138C01503      0      GNB_SCELL_ADMI_UNSUCC_SA
       ...   M55139C00023      5      GNB_DU_SCELL_4_ADMI_REQ_SA
       ...   M55139C00024      5      GNB_DU_SCELL_4_ADMI_SUCC_SA

       ...   M55118C00001     10       RRC_RECONF_ADD5DLSCELL_ATT_SA
       ...   M55118C00004     10       RRC_RECONF_ADD5DLSCELL_SUCC_SA
       ...   M55118C11055     10       GNB_DL_SCELL_5_CONFIG_REQ_SA
       ...   M55118C11065     10       GNB_DL_SCELL_5_CONFIG_SUCC_SA
       ...   M55138C03504     10       GNB_SCELL_5_ADMI_REQ_SA
       ...   M55138C03507     10       GNB_SCELL_5_ADMI_SUCC_SA
       ...   M55138C03514     10       GNB_DL_SCELL_5_ADMI_REQ_SA
       ...   M55138C03521     10       GNB_DL_SCELL_5_ADMI_SUCC_SA
       ...   M55139C05506     10       GNB_DU_DL_SCELL_5_ADMI_REQ_SA
       ...   M55139C05513     10       GNB_DU_DL_SCELL_5_ADMI_SUCC_SA
       ...   M55139C03003     10       GNB_DU_SCELL_5_ADMI_REQ_SA
       ...   M55139C03006     10       GNB_DU_SCELL_5_ADMI_SUCC_SA

       ...   M55138C01001     14       GBR_DRB_REQ
       ...   M55138C01002     14       GBR_DRB_SUCC

       ...   M55138C00015     29       PEAK_NUMBER_OF_SA_NGBR
       ...   M55138C00016     15       PEAK_NUMBER_OF_SA_NGBR_USERS
       ...   M55138C01007     14       PEAK_NUMBER_OF_SA_GBR
       ...   M55125C09517     14       NG_FLOW_SETUP_ATT_TOT_5QI1
       ...   M55125C09518     14       NG_FLOW_SETUP_SUCC_TOT_5QI1
       ...   M55125C09530     14       PEAK_NUMBER_OF_UE_5QI1

       ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${cell_id}
       ...    file_path=${pm_counter_file}

Verify Blind 5CC and 6CC SCell Addition And Reestablishment PM counters in saCell#${cell_id}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
       ...   M55118C02015      5      RRC_RECONF_ADD4DLSCELL_ATT_SA
       ...   M55118C02014      5      RRC_RECONF_ADD4DLSCELL_SUCC_SA
       ...   M55118C11054      5      GNB_DL_SCELL_4_CONFIG_REQ_SA
       ...   M55118C11064      5      GNB_DL_SCELL_4_CONFIG_SUCC_SA
       ...   M55138C00048      5      GNB_SCELL_4_ADMI_REQ_SA
       ...   M55138C00049      5      GNB_SCELL_4_ADMI_SUCC_SA
       ...   M55138C03513      5      GNB_DL_SCELL_4_ADMI_REQ_SA
       ...   M55138C03520      5      GNB_DL_SCELL_4_ADMI_SUCC_SA
       ...   M55139C05505      5      GNB_DU_DL_SCELL_4_ADMI_REQ_SA
       ...   M55139C05512      5      GNB_DU_DL_SCELL_4_ADMI_SUCC_SA
       ...   M55138C01503      0       GNB_SCELL_ADMI_UNSUCC_SA
       ...   M55139C00023      5      GNB_DU_SCELL_4_ADMI_REQ_SA
       ...   M55139C00024      5      GNB_DU_SCELL_4_ADMI_SUCC_SA

       ...   M55118C00001     10       RRC_RECONF_ADD5DLSCELL_ATT_SA
       ...   M55118C00004     10       RRC_RECONF_ADD5DLSCELL_SUCC_SA
       ...   M55118C11055     10       GNB_DL_SCELL_5_CONFIG_REQ_SA
       ...   M55118C11065     10       GNB_DL_SCELL_5_CONFIG_SUCC_SA
       ...   M55138C03504     10       GNB_SCELL_5_ADMI_REQ_SA
       ...   M55138C03507     10       GNB_SCELL_5_ADMI_SUCC_SA
       ...   M55138C03514     10       GNB_DL_SCELL_5_ADMI_REQ_SA
       ...   M55138C03521     10       GNB_DL_SCELL_5_ADMI_SUCC_SA
       ...   M55139C05506     10       GNB_DU_DL_SCELL_5_ADMI_REQ_SA
       ...   M55139C05513     10       GNB_DU_DL_SCELL_5_ADMI_SUCC_SA
       ...   M55139C03003     10       GNB_DU_SCELL_5_ADMI_REQ_SA
       ...   M55139C03006     10       GNB_DU_SCELL_5_ADMI_SUCC_SA
       ...   M55124C00001     15       NRRCC_RRC_RELEASE_SENT

       ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${cell_id}
       ...    file_path=${pm_counter_file}

