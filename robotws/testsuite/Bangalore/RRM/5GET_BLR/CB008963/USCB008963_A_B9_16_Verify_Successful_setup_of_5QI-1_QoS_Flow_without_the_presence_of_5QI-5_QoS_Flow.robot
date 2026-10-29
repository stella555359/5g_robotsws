*** Settings ***
Force Tags      5G_SC_TDD    5G_RAN     SBTS00     SBTS25R2    CONFIGURED

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Library          taf.sw.scout    WITH NAME     scout
Library          ta5g_pm_counters
Resource         CB008963_resource.robot

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_8963.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1    4

Documentation
...
...      author:            Ganesha.U  ganesha.u@nokia.com
...      maintainer:        Ganesha.U  ganesha.u@nokia.com
...
...      INTRODUCTION:    This user scenario describes the procedure where AMF requests setup of 5QI-1 QoS Flow without
...      the presence of 5QI-5 QoS Flow
...      TEST SET NAME:  [1]USCB008963 A B9 16 Verify Successful setup of 5QI-1 QoS Flow without the presence of 5QI-5 QoS Flow
...      This user scenario describes the procedure where AMF requests setup of 5QI-1 QoS Flow without the

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/TMO_8963_basic.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID1}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${TRF_ID}    1
${Q_O_ADD1}    1
${epc_log_path}    /tmp/
@{5QI2}     2    12    false
@{5QI3}     3    12    false
@{5QI4}     4    12    false
@{5QI6}     6    18    false
@{5QI7}     10    18    false
&{flows_ue1}    ${2}=${5QI2}    ${3}=${5QI3}    ${4}=${5QI4}
&{flows_ue1_pdu2}    ${2}=${5QI2}    ${3}=${5QI3}
&{flows_ue2}     ${2}=${5QI2}    ${3}=${5QI3}    ${4}=${5QI4}     ${5}=${5QI7}

*** Test Cases ***
[1][1.0] USCB008963_A_B9_16_Verify_Successful_setup_of_5QI-1_QoSFlow_without_the_presence_of_5QI-5_QoS_Flow
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Set Test Variable    ${Validation}    ${True}
    Register UE with GBR and check default bearer and PDCP length     ue_id=1    default_drb=false    pdcplength=12
    FOR   ${5QI}   IN RANGE    2   5
        Add Qos flow and check PDCP Lenght and Default DRB    ue_id=1    pdu_id=1    flow_dict=${flows_ue1}    5QI=${5QI}
    END
    Change Default 5QI Value Qos Flow    qos_flow=10  5qi=7   type=non-gbr   default=on
    Add PDU to UE and send data Check PDCP Lenght and Default DRB    ue_id=1   pdu_id=2    nw_id=1    gw_id=1   default_drb=true    pdcplength=18
    Change Default 5QI Value Qos Flow    qos_flow=5  5qi=5   type=non-gbr   default=on
    FOR   ${5QI}   IN RANGE    2   4
        Add Qos flow and check PDCP Lenght and Default DRB   ue_id=1   pdu_id=2    flow_dict=${flows_ue1_pdu2}   5QI=${5QI}
    END
    Change Default 5QI Value Qos Flow    qos_flow=7  5qi=71   type=gbr   default=on
    Register UE with GBR and check default bearer and PDCP length     ue_id=2    default_drb=true    pdcplength=12
    FOR   ${5QI}   IN RANGE    2   6
        Add Qos flow and check PDCP Lenght and Default DRB    ue_id=2    pdu_id=1    flow_dict=${flows_ue2}    5QI=${5QI}
    END
    BuiltIn.Log     Enable dlflowcontrolalgo_for 5QI3 in WEBEM
    Perform SCF Delta Commissioning with Delta_Configuration_dlFlowControlAlgo_3gppFlowControl_nrdrb17_5qi3.json
    Register UE with GBR and check default bearer and PDCP length     ue_id=3    default_drb=true    pdcplength=12
    #need to add qos flow add
    Verify RLC legacy Counters Feature Specific
#    Trigger multiple UE HO to Target Cell  start_ue=1   end_ue=3   meas_id=1   target_cell=51
#    Verify RLC legacy Counters after HO in source NRcell-1
#    Verify RLC legacy Counters after HO to in Target NRcell-2
#    Trigger multiple UE HO to Target Cell  start_ue=1   end_ue=3   meas_id=1   target_cell=50
#    Verify RLC legacy Counters after HO in source NRcell-2
#    Verify RLC legacy Counters after HO to in Target NRcell-1
    [Teardown]   Run Keywords        Link SCOUT SCF to Configuration ID for Reporting
    ...         AND        wts_sim_keywords.MultiUE Deregister should be Successful    1     3
    ...         AND        wts_sim_keywords.Clean edaemon and egate

*** Keywords ***
Verify RLC legacy Counters Feature Specific
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55310C01001    >100     DL_RLC_VOL_TX_L_QOS_GRP_01_5QI_1
    ...     M55310C01002    >100     DL_RLC_VOL_TX_L_QOS_GRP_02_5QI_2
    ...     M55310C01003    >100     DL_RLC_VOL_TX_L_QOS_GRP_03_5QI_3
    ...     M55310C01004    >100     DL_RLC_VOL_TX_L_QOS_GRP_04_5QI_4
    ...     M55310C01005    >100     DL_RLC_VOL_TX_L_QOS_GRP_05_5QI_5
    ...     M55310C01006    0     DL_RLC_VOL_TX_L_QOS_GRP_06_5QI_6
    ...     M55310C01007    >100      DL_RLC_VOL_TX_L_QOS_GRP_07_5QI_7
    ...     M55310C01008    >100      DL_RLC_VOL_TX_L_QOS_GRP_08_5QI_8
    ...     M55310C01009      0      DL_RLC_VOL_TX_L_QOS_GRP_09_5QI_9
    ...     M55310C01010    >100     DL_RLC_VOL_TX_L_QOS_GRP_10_5QI_71
    ...     M55310C01011    0     DL_RLC_VOL_TX_L_QOS_GRP_11_5QI_72
    ...     M55310C01012    0     DL_RLC_VOL_TX_L_QOS_GRP_12_5QI_76
    ...     M55310C03001    >100     UL_RLC_VOL_RX_L_QOS_GRP_01_5QI_1
    ...     M55310C03002    >100     UL_RLC_VOL_RX_L_QOS_GRP_02_5QI_2
    ...     M55310C03003    >100     UL_RLC_VOL_RX_L_QOS_GRP_03_5QI_3
    ...     M55310C03004    >100     UL_RLC_VOL_RX_L_QOS_GRP_04_5QI_4
    ...     M55310C03005    >100     UL_RLC_VOL_RX_L_QOS_GRP_05_5QI_5
    ...     M55310C03006    0     UL_RLC_VOL_RX_L_QOS_GRP_06_5QI_6
    ...     M55310C03007    >100      UL_RLC_VOL_RX_L_QOS_GRP_07_5QI_7
    ...     M55310C03008    >100      UL_RLC_VOL_RX_L_QOS_GRP_08_5QI_8
    ...     M55310C03009      0      UL_RLC_VOL_RX_L_QOS_GRP_09_5QI_9
    ...     M55310C03010    >100     UL_RLC_VOL_RX_L_QOS_GRP_10_5QI_71
    ...     M55310C03011    0     UL_RLC_VOL_RX_L_QOS_GRP_11_5QI_72
    ...     M55310C03012    0     UL_RLC_VOL_RX_L_QOS_GRP_12_5QI_76
    ...     M55125C05505    1     NNGCC_PDU_SES_STP_REQ_EC_RECD_emergency
    ...     M55125C05506    1     NNGCC_PDU_SES_STP_RESP_EC_SENT
    ...     M55125C05509    2     NNGCC_PDUSESMODREQ_EC_RECD
    ...     M55125C05510    2     NNGCC_PDUSESMODRSP_SUC_EC_SENT
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}


Verify RLC legacy Counters after HO to in Target NRcell-${id}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55310C01001    >100     DL_RLC_VOL_TX_L_QOS_GRP_01_5QI_1
    ...     M55310C01002    >100     DL_RLC_VOL_TX_L_QOS_GRP_02_5QI_2
    ...     M55310C01003    >100     DL_RLC_VOL_TX_L_QOS_GRP_03_5QI_3
    ...     M55310C01004    >100     DL_RLC_VOL_TX_L_QOS_GRP_04_5QI_4
    ...     M55310C01005    >100     DL_RLC_VOL_TX_L_QOS_GRP_05_5QI_5
    ...     M55310C01006    0     DL_RLC_VOL_TX_L_QOS_GRP_06_5QI_6
    ...     M55310C01007    >100      DL_RLC_VOL_TX_L_QOS_GRP_07_5QI_7
    ...     M55310C01008    >100      DL_RLC_VOL_TX_L_QOS_GRP_08_5QI_8
    ...     M55310C01009      0      DL_RLC_VOL_TX_L_QOS_GRP_09_5QI_9
    ...     M55310C01010    >100     DL_RLC_VOL_TX_L_QOS_GRP_10_5QI_71
    ...     M55310C01011    0     DL_RLC_VOL_TX_L_QOS_GRP_11_5QI_72
    ...     M55310C01012    0     DL_RLC_VOL_TX_L_QOS_GRP_12_5QI_76
    ...     M55310C03001    >100     UL_RLC_VOL_RX_L_QOS_GRP_01_5QI_1
    ...     M55310C03002    >100     UL_RLC_VOL_RX_L_QOS_GRP_02_5QI_2
    ...     M55310C03003    >100     UL_RLC_VOL_RX_L_QOS_GRP_03_5QI_3
    ...     M55310C03004    >100     UL_RLC_VOL_RX_L_QOS_GRP_04_5QI_4
    ...     M55310C03005    >100     UL_RLC_VOL_RX_L_QOS_GRP_05_5QI_5
    ...     M55310C03006    0     UL_RLC_VOL_RX_L_QOS_GRP_06_5QI_6
    ...     M55310C03007    >100      UL_RLC_VOL_RX_L_QOS_GRP_07_5QI_7
    ...     M55310C03008    >100      UL_RLC_VOL_RX_L_QOS_GRP_08_5QI_8
    ...     M55310C03009      0      UL_RLC_VOL_RX_L_QOS_GRP_09_5QI_9
    ...     M55310C03010    >100     UL_RLC_VOL_RX_L_QOS_GRP_10_5QI_71
    ...     M55310C03011    0     UL_RLC_VOL_RX_L_QOS_GRP_11_5QI_72
    ...     M55310C03012    0     UL_RLC_VOL_RX_L_QOS_GRP_12_5QI_76
    ...     M55125C05505    1     NNGCC_PDU_SES_STP_REQ_EC_RECD_emergency
    ...     M55125C05506    1     NNGCC_PDU_SES_STP_RESP_EC_SENT
    ...     M55125C05509    2     NNGCC_PDUSESMODREQ_EC_RECD
    ...     M55125C05510    2     NNGCC_PDUSESMODRSP_SUC_EC_SENT
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-${id}
    ...     file_path=${pm_counter_file}

Verify RLC legacy Counters after HO in source NRcell-${id}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55310C01001    0     DL_RLC_VOL_TX_L_QOS_GRP_01_5QI_1
    ...     M55310C01002    0     DL_RLC_VOL_TX_L_QOS_GRP_02_5QI_2
    ...     M55310C01003    0     DL_RLC_VOL_TX_L_QOS_GRP_03_5QI_3
    ...     M55310C01004    0     DL_RLC_VOL_TX_L_QOS_GRP_04_5QI_4
    ...     M55310C01005    0     DL_RLC_VOL_TX_L_QOS_GRP_05_5QI_5
    ...     M55310C01006    0     DL_RLC_VOL_TX_L_QOS_GRP_06_5QI_6
    ...     M55310C01007    0      DL_RLC_VOL_TX_L_QOS_GRP_07_5QI_7
    ...     M55310C01008    0      DL_RLC_VOL_TX_L_QOS_GRP_08_5QI_8
    ...     M55310C01009    0      DL_RLC_VOL_TX_L_QOS_GRP_09_5QI_9
    ...     M55310C01010    0     DL_RLC_VOL_TX_L_QOS_GRP_10_5QI_71
    ...     M55310C01011    0     DL_RLC_VOL_TX_L_QOS_GRP_11_5QI_72
    ...     M55310C01012    0     DL_RLC_VOL_TX_L_QOS_GRP_12_5QI_76
    ...     M55310C03001    0     UL_RLC_VOL_RX_L_QOS_GRP_01_5QI_1
    ...     M55310C03002    0     UL_RLC_VOL_RX_L_QOS_GRP_02_5QI_2
    ...     M55310C03003    0     UL_RLC_VOL_RX_L_QOS_GRP_03_5QI_3
    ...     M55310C03004    0     UL_RLC_VOL_RX_L_QOS_GRP_04_5QI_4
    ...     M55310C03005    0     UL_RLC_VOL_RX_L_QOS_GRP_05_5QI_5
    ...     M55310C03006    0     UL_RLC_VOL_RX_L_QOS_GRP_06_5QI_6
    ...     M55310C03007    0      UL_RLC_VOL_RX_L_QOS_GRP_07_5QI_7
    ...     M55310C03008    0      UL_RLC_VOL_RX_L_QOS_GRP_08_5QI_8
    ...     M55310C03009    0      UL_RLC_VOL_RX_L_QOS_GRP_09_5QI_9
    ...     M55310C03010    0     UL_RLC_VOL_RX_L_QOS_GRP_10_5QI_71
    ...     M55310C03011    0     UL_RLC_VOL_RX_L_QOS_GRP_11_5QI_72
    ...     M55310C03012    0     UL_RLC_VOL_RX_L_QOS_GRP_12_5QI_76
    ...     M55125C05505    0    NNGCC_PDU_SES_STP_REQ_EC_RECD_emergency
    ...     M55125C05506    0    NNGCC_PDU_SES_STP_RESP_EC_SENT
    ...     M55125C05509    0     NNGCC_PDUSESMODREQ_EC_RECD
    ...     M55125C05510    0     NNGCC_PDUSESMODRSP_SUC_EC_SENT
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-${id}
    ...     file_path=${pm_counter_file}
