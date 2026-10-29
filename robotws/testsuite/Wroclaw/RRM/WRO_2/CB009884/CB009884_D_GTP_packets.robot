*** Settings ***
Force Tags    CONFIGURED    CIT    PY310    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Documentation   :copyright: Nokia
...             :authors: Milosz Dunikowski
...             :contact: milosz.dunikowski@nokia.com

Resource       CB009884_keywords.robot
Resource       ../resources/testing_env.robot
Resource       ../keywords/traffic.robot

Library        taf.ul.ettf.setups

Library        ta5g_enb
Library        ta5g_iphy
Library        ta5g_pm_counters
Library        ../CB008933/nrpmqap_counter_checker/feautere_keywords.py
Library        ../CB008490/resources/multignb_variables.py
Library        testsuite/Wroclaw/RRM/resources/scout_report.py

Variables      logging_policy.py

Suite Setup        Run Keywords
...                Update And Put Iphy Xml         input_filepath=${IPHY}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_SN}
...                remote_host=${REMOTE_HOST_1_IP}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_MN}
...    AND         With Simulator Configuration    config=${cfg}    remote_hosts=${REMOTE_HOSTS}

*** Variables ***
${LOGGING_POLICY}=          REMOTE_HOST_POLICY
${SCFC_GNB_MN}=             scfc_9884_D_MN_real.xml
${SCFC_GNB_SN}=             scfc_9884_D_SN_real.xml
${IPHY}=                    ${CURDIR}/config/CB009884_D_iphy.xml
${cfg}=                     ${CURDIR}/config/9884_D_real_nodes_nrdc.cfg
${MN_CELL_1}=               1
${MN_CELL_2}=               2
${MN_CELL_3}=               3
${MN_CELL_4}=               4
${NRDC_SN_CELL}=            5
@{MN_CELLS}=                1    2    3    4
@{SN_CELLS}=                5    6    7    8
@{SN_CELLS_after_test}=     6    7    8
@{FAULT_IDS_LIST}=          6450    4383

*** Test Cases ***
CB009884_D1_GTP_Data_Packet_Loss_in_gNB-DU_during_inter-gNB_NRDC_with_both_NR-DC_and_SA_UEs
    Verify Pm Counters Values Before Test Starts
    Enable GTP-U Sequence Number inclusion in bearer packets
    Register UEs with No Testmode Activated    UE_ID=1    ALL_UES=7
    Establish PDU Session With Traffic and Send A4 Measurement for NR-DC UEs with Different PDU ID    UE_ID=1    ALL_UES=3    MEAS_ID=1
    Establish PDU Session With Traffic For Multiple UEs with Different PDU ID    UE_ID=3    ALL_UES=7
    Wait 5s For Traffic To Stabilize
    Trigger Out of Order Packets on N3 interface   UE_ID=1    PDU_ID=1    SEQ=30:30:1
    Trigger Lost Packets on N3 interface    UE_ID=2    PDU_ID=2    SEQ=33:90:2
    Trigger Out of Order Packets on N3 interface   UE_ID=3    PDU_ID=3    SEQ=45:30:1
    Trigger Out of Order Packets on N3 interface   UE_ID=5    PDU_ID=5    SEQ=35:30:1
    Trigger Lost Packets on N3 interface    UE_ID=6    PDU_ID=6    SEQ=20:90:2
    Wait 10s For Counters To Be Pegged
    Verify Pm Counters Values After Test

    [Teardown]     Run Keywords
    ...                            Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
    ...            AND             Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
    ...            AND             Add Scout Scf Id To Test Data

*** Keywords ***
Verify Pm Counters Values Before Test Starts
    Wait For Next Full Pm Interval
    ${pm_counter_file_MN}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{MN_CELLS}
        ${result}=    verify counters list increased

            ...    M55352C03031        1-5                  ==0            PDCP_SDU_LOST_N3_PMQP
            ...    M55352C03032        1-5                  ==0            PDCP_SDU_RCV_N3_ORDR_CU_PMQP
            ...    M55352C03033        1-5                  ==0            PDCP_SDU_RCV_N3_OUTORD_CU_PMQP
            ...    M55376C00006        1-5                  ==0            PDCP_PDU_LOST_F1_PMQP
            ...    M55376C00007        1-5                  ==0            PDCP_PDU_RCV_F1_ORDR_DU_PMQP
            ...    M55376C00008        1-5                  ==0            PDCP_PDU_RCV_F1_OUTORD_DU_PMQP
            ...    M55378C00001        1-5                  ==0            PDCP_PDU_LOST_XN_PMQP
            ...    M55378C00002        1-5                  ==0            PDCP_PDU_RCV_XN_ORDR_DU_PMQP
            ...    M55378C00003        1-5                  ==0            PDCP_PDU_RCV_XN_OUTORD_DU_PMQP

            ...    pm_counter_file=${pm_counter_file_MN}
            ...    cell_id=${local_moid}

        Run Keyword If   not ${result}
            ...    Fail    msg=*HTML*<p style="color:red; font-size:16px; font-weight: bold;">Counters verification failed. Please check table </p>
    END

    ${pm_counter_file_SN}=    Get Latest Unpacked Full Pm Counters File    remote_host=${REMOTE_HOST_1_IP}
    FOR    ${local_moid}    IN    @{SN_CELLS}
        ${result}=    verify counters list increased

            ...    M55352C03031        1-5                  ==0            PDCP_SDU_LOST_N3_PMQP
            ...    M55352C03032        1-5                  ==0            PDCP_SDU_RCV_N3_ORDR_CU_PMQP
            ...    M55352C03033        1-5                  ==0            PDCP_SDU_RCV_N3_OUTORD_CU_PMQP
            ...    M55376C00006        1-5                  ==0            PDCP_PDU_LOST_F1_PMQP
            ...    M55376C00007        1-5                  ==0            PDCP_PDU_RCV_F1_ORDR_DU_PMQP
            ...    M55376C00008        1-5                  ==0            PDCP_PDU_RCV_F1_OUTORD_DU_PMQP
            ...    M55378C00001        1-5                  ==0            PDCP_PDU_LOST_XN_PMQP
            ...    M55378C00002        1-5                  ==0            PDCP_PDU_RCV_XN_ORDR_DU_PMQP
            ...    M55378C00003        1-5                  ==0            PDCP_PDU_RCV_XN_OUTORD_DU_PMQP

            ...    pm_counter_file=${pm_counter_file_SN}
            ...    cell_id=${local_moid}

        Run Keyword If   not ${result}
            ...    Fail    msg=*HTML*<p style="color:red; font-size:16px; font-weight: bold;">Counters verification failed. Please check table </p>
    END

Verify Pm Counters Values After Test
    Wait For Next Full Pm Interval
    ${pm_counter_file_MN}=    Get Latest Unpacked Full Pm Counters File
    ${pm_counter_file_SN}=    Get Latest Unpacked Full Pm Counters File    remote_host=${REMOTE_HOST_1_IP}

    ${result}=    verify counters list increased

        ...    M55352C03031        1-5                  ==0            PDCP_SDU_LOST_N3_PMQP
        ...    M55352C03032        1,3                  >0             PDCP_SDU_RCV_N3_ORDR_CU_PMQP
        ...    M55352C03033        1-5                  ==0            PDCP_SDU_RCV_N3_OUTORD_CU_PMQP
        ...    M55376C00006        1-5                  ==0            PDCP_PDU_LOST_F1_PMQP
        ...    M55376C00007        1,3                  >0             PDCP_PDU_RCV_F1_ORDR_DU_PMQP
        ...    M55376C00008        1-5                  ==0            PDCP_PDU_RCV_F1_OUTORD_DU_PMQP
        ...    M55378C00001        1-5                  ==0            PDCP_PDU_LOST_XN_PMQP
        ...    M55378C00002        1,3                  >0             PDCP_PDU_RCV_XN_ORDR_DU_PMQP
        ...    M55378C00003        1-5                  ==0            PDCP_PDU_RCV_XN_OUTORD_DU_PMQP

        ...    M55352C03032        2,4-5                ==0            PDCP_SDU_RCV_N3_ORDR_CU_PMQP
        ...    M55376C00007        2,4-5                ==0            PDCP_PDU_RCV_F1_ORDR_DU_PMQP
        ...    M55378C00002        2,4-5                ==0            PDCP_PDU_RCV_XN_ORDR_DU_PMQP

        ...    pm_counter_file=${pm_counter_file_MN}
        ...    cell_id=${MN_CELL_1}

    Run Keyword If   not ${result}
        ...    Fail    msg=*HTML*<p style="color:red; font-size:16px; font-weight: bold;">Counters verification failed. Please check table </p>

    ${result}=    verify counters list increased

        ...    M55352C03031        1,3                  >0             PDCP_SDU_LOST_N3_PMQP
        ...    M55352C03032        1,3                  >0             PDCP_SDU_RCV_N3_ORDR_CU_PMQP
        ...    M55352C03033        1,3                  >0             PDCP_SDU_RCV_N3_OUTORD_CU_PMQP
        ...    M55376C00006        1-5                  ==0            PDCP_PDU_LOST_F1_PMQP
        ...    M55376C00007        1,3                  >0             PDCP_PDU_RCV_F1_ORDR_DU_PMQP
        ...    M55376C00008        1-5                  ==0            PDCP_PDU_RCV_F1_OUTORD_DU_PMQP
        ...    M55378C00001        1-5                  ==0            PDCP_PDU_LOST_XN_PMQP
        ...    M55378C00002        1-5                  ==0            PDCP_PDU_RCV_XN_ORDR_DU_PMQP
        ...    M55378C00003        1-5                  ==0            PDCP_PDU_RCV_XN_OUTORD_DU_PMQP

        ...    M55352C03031        2,4-5                ==0            PDCP_SDU_LOST_N3_PMQP
        ...    M55352C03032        2,4-5                ==0            PDCP_SDU_RCV_N3_ORDR_CU_PMQP
        ...    M55352C03033        2,4-5                ==0            PDCP_SDU_RCV_N3_OUTORD_CU_PMQP
        ...    M55376C00007        2,4-5                ==0            PDCP_PDU_RCV_F1_ORDR_DU_PMQP

        ...    pm_counter_file=${pm_counter_file_MN}
        ...    cell_id=${MN_CELL_2}

    Run Keyword If   not ${result}
        ...    Fail    msg=*HTML*<p style="color:red; font-size:16px; font-weight: bold;">Counters verification failed. Please check table </p>


    ${result}=    verify counters list increased

        ...    M55352C03031        1-5                  ==0            PDCP_SDU_LOST_N3_PMQP
        ...    M55352C03032        1,3                  >0             PDCP_SDU_RCV_N3_ORDR_CU_PMQP
        ...    M55352C03033        1-5                  ==0            PDCP_SDU_RCV_N3_OUTORD_CU_PMQP
        ...    M55376C00006        1-5                  ==0            PDCP_PDU_LOST_F1_PMQP
        ...    M55376C00007        1,3                  >0             PDCP_PDU_RCV_F1_ORDR_DU_PMQP
        ...    M55376C00008        1-5                  ==0            PDCP_PDU_RCV_F1_OUTORD_DU_PMQP
        ...    M55378C00001        1-5                  ==0            PDCP_PDU_LOST_XN_PMQP
        ...    M55378C00002        1-5                  ==0            PDCP_PDU_RCV_XN_ORDR_DU_PMQP
        ...    M55378C00003        1-5                  ==0            PDCP_PDU_RCV_XN_OUTORD_DU_PMQP

        ...    M55352C03032        2,4-5                ==0            PDCP_SDU_RCV_N3_ORDR_CU_PMQP
        ...    M55376C00007        2,4-5                ==0            PDCP_PDU_RCV_F1_ORDR_DU_PMQP

        ...    pm_counter_file=${pm_counter_file_MN}
        ...    cell_id=${MN_CELL_3}

    Run Keyword If   not ${result}
        ...    Fail    msg=*HTML*<p style="color:red; font-size:16px; font-weight: bold;">Counters verification failed. Please check table </p>

    ${result}=    verify counters list increased

        ...    M55352C03031        1,3                  >0             PDCP_SDU_LOST_N3_PMQP
        ...    M55352C03032        1,3                  >0             PDCP_SDU_RCV_N3_ORDR_CU_PMQP
        ...    M55352C03033        1,3                  >0             PDCP_SDU_RCV_N3_OUTORD_CU_PMQP
        ...    M55376C00006        1-5                  ==0            PDCP_PDU_LOST_F1_PMQP
        ...    M55376C00007        1,3                  >0             PDCP_PDU_RCV_F1_ORDR_DU_PMQP
        ...    M55376C00008        1-5                  ==0            PDCP_PDU_RCV_F1_OUTORD_DU_PMQP
        ...    M55378C00001        1-5                  ==0            PDCP_PDU_LOST_XN_PMQP
        ...    M55378C00002        1-5                  ==0            PDCP_PDU_RCV_XN_ORDR_DU_PMQP
        ...    M55378C00003        1-5                  ==0            PDCP_PDU_RCV_XN_OUTORD_DU_PMQP

        ...    M55352C03031        2,4-5                ==0            PDCP_SDU_LOST_N3_PMQP
        ...    M55352C03032        2,4-5                ==0            PDCP_SDU_RCV_N3_ORDR_CU_PMQP
        ...    M55352C03033        2,4-5                ==0            PDCP_SDU_RCV_N3_OUTORD_CU_PMQP
        ...    M55376C00007        2,4-5                ==0            PDCP_PDU_RCV_F1_ORDR_DU_PMQP

        ...    pm_counter_file=${pm_counter_file_MN}
        ...    cell_id=${MN_CELL_4}

    Run Keyword If   not ${result}
        ...    Fail    msg=*HTML*<p style="color:red; font-size:16px; font-weight: bold;">Counters verification failed. Please check table </p>

    #Secondary Node

    ${result}=    verify counters list increased
        ...    M55352C03031        1,3                  >0             PDCP_SDU_LOST_N3_PMQP
        ...    M55352C03032        1,3                  >0             PDCP_SDU_RCV_N3_ORDR_CU_PMQP
        ...    M55352C03033        1,3                  >0             PDCP_SDU_RCV_N3_OUTORD_CU_PMQP
        ...    M55376C00006        1-5                  ==0            PDCP_PDU_LOST_F1_PMQP
        ...    M55376C00007        1,3                  >0             PDCP_PDU_RCV_F1_ORDR_DU_PMQP
        ...    M55376C00008        1-5                  ==0            PDCP_PDU_RCV_F1_OUTORD_DU_PMQP
        ...    M55378C00001        1-5                  ==0            PDCP_PDU_LOST_XN_PMQP
        ...    M55378C00002        1-5                  ==0            PDCP_PDU_RCV_XN_ORDR_DU_PMQP
        ...    M55378C00003        1-5                  ==0            PDCP_PDU_RCV_XN_OUTORD_DU_PMQP

        ...    M55352C03031        2,4-5                ==0            PDCP_SDU_LOST_N3_PMQP
        ...    M55352C03032        2,4-5                ==0            PDCP_SDU_RCV_N3_ORDR_CU_PMQP
        ...    M55352C03033        2,4-5                ==0            PDCP_SDU_RCV_N3_OUTORD_CU_PMQP

        ...    pm_counter_file=${pm_counter_file_SN}
        ...    cell_id=${NRDC_SN_CELL}

    Run Keyword If   not ${result}
            ...    Fail    msg=*HTML*<p style="color:red; font-size:16px; font-weight: bold;">Counters verification failed. Please check table </p>

    FOR    ${local_moid}    IN    @{SN_CELLS_after_test}
        ${result}=    verify counters list increased

            ...    M55352C03031        1-5                  ==0             PDCP_SDU_LOST_N3_PMQP
            ...    M55352C03032        1-5                  ==0             PDCP_SDU_RCV_N3_ORDR_CU_PMQP
            ...    M55352C03033        1-5                  ==0             PDCP_SDU_RCV_N3_OUTORD_CU_PMQP
            ...    M55376C00006        1-5                  ==0             PDCP_PDU_LOST_F1_PMQP
            ...    M55376C00007        1-5                  ==0             PDCP_PDU_RCV_F1_ORDR_DU_PMQP
            ...    M55376C00008        1-5                  ==0             PDCP_PDU_RCV_F1_OUTORD_DU_PMQP
            ...    M55378C00001        1-5                  ==0            PDCP_PDU_LOST_XN_PMQP
            ...    M55378C00002        1-5                  ==0            PDCP_PDU_RCV_XN_ORDR_DU_PMQP
            ...    M55378C00003        1-5                  ==0            PDCP_PDU_RCV_XN_OUTORD_DU_PMQP

            ...    pm_counter_file=${pm_counter_file_SN}
            ...    cell_id=${local_moid}

        Run Keyword If   not ${result}
            ...    Fail    msg=*HTML*<p style="color:red; font-size:16px; font-weight: bold;">Counters verification failed. Please check table </p>
    END
