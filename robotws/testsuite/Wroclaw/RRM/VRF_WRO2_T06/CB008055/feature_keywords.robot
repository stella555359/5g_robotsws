*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Library        ta5g_ue_measurements
Library        ta5g_pm_counters
Library        ta5g_ue_mobility
Library        ta5g_throughput
*** Variables ***
@{5CC_6CC_cp_if_rdparam}=    0x8900a7=1 #rdAllowPureFdd5ccAnd6ccSolution
@{5CC_6CC_cp_rt_rdparam}=    0x5902b0=1 #rdAllowPureFdd5ccAnd6ccSolution
@{8055_SWCONFIG_FLAGS}=      @{5CC_6CC_cp_if_rdparam}    @{5CC_6CC_cp_rt_rdparam}


*** Keywords ***
UE#${first_UE}-UE#${last_UE} sends A1 measurement With MeasId-${meas_id} For SCell Addition To PhyCellId ${phycell_id}
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Send Ue Measurement Nr    ue_id=${UE}    meas_id=${meas_id}    phycell_id=${phycell_id}   srsrp_nr=80    event=A1
    ...    pass_regexp=sCellToAddModList
    Wait 1s For SCell Addition
    END

Delay RRCReconfigurationComplete For UE
    [Arguments]    ${ue_id}    ${delay_time}=10000
    Execute Egate Command     cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=${delay_time}

Trigger RLF For UE#${first_UE} - UE#${last_UE}
    Execute Egate Command     cmd=rlf_testmode_nr profile_id=6 num_stop_csi_report=1000 num_stop_dlharq_tx=2000
    Wait 2s For RLF Profile Activation
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Execute Egate Command     cmd=ue_testmode_set_nr id=${UE} profile_id=6 testmode=rlf action=activate
    Wait 10s For RLF
    END

Deactivate RLF profile For UE#${first_UE} - UE#${last_UE}
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Execute Egate Command     cmd=ue_testmode_set_nr id=${UE} profile_id=6 testmode=rlf action=deactivate
    END

Start non-GBR ${MBPS} MBPS DL Data Traffic For UEs With IDs ${first_UE}-${last_UE} On 5QI ${5QI_ID} WIth Traffic ID ${traffic_id}
    ${QFI_ID}=     Set variable if
    ...     '${5QI_ID}'=='6'             1
    ...     '${5QI_ID}'=='5'             2
    Start Data Traffic for Multiple UEs    UE_ID=${first_UE}    ALL_UES=${last_UE}    PDU_ID=1    QFI_ID=${QFI_ID}    TRF_ID=${traffic_id}    DIR=dl
    ...    MBPS=${MBPS}
    Wait 2s For Throughput To Stabilize

Start ${MBPS} MBPS UL data traffic for UEs with IDs ${first_UE}-${last_UE} On 5QI ${5QI_ID}
    ${QFI_ID}=     Set variable if
    ...     '${5QI_ID}'=='6'             1
    ...     '${5QI_ID}'=='5'             2
    ...     '${5QI_ID}'=='1'             3
    Start Data Traffic for Multiple UEs    UE_ID=${first_UE}    ALL_UES=${last_UE}    PDU_ID=1    QFI_ID=${QFI_ID}    TRF_ID=1
    ...    DIR=ul    MBPS=${MBPS}
    Wait 2s For Throughput To Stabilize

Start VoNR Data Traffic For UEs With IDs ${first_UE}-${last_UE}
    Start GBR Data Traffic for Multiple UEs    UE_ID=${first_UE}    ALL_UES=${last_UE}    PDU_ID=1    QFI_ID=3    TRF_ID=1    DIR=dl    KBPS=5

Start Video Call Data Traffic For UEs With IDs ${first_UE}-${last_UE}
    Start GBR Data Traffic for Multiple UEs    UE_ID=${first_UE}    ALL_UES=${last_UE}    PDU_ID=1    QFI_ID=4    TRF_ID=1    DIR=dl    KBPS=5

Verify DL thoughput For UE#${fist_UE}-UE#${last_UE} On ${num_of_scells} SCells
    FOR    ${UE}     IN RANGE   ${fist_UE}    ${last_UE}+1
    Wait Until Keyword Succeeds    2x    5sec    Expected Throughput For Ue Should Be Reached    ue_id=${UE}    retry=0    throughput=0.2
    ...    direction=dl    selection_type=average    layer=physical    scells=0-${num_of_scells}    margin=0.15
    Wait 2s For Egate Stabilization
    END

Verify UL thoughput For UE#${fist_UE}-UE#${last_UE} On ${num_of_scells} SCells
    FOR    ${UE}     IN RANGE   ${fist_UE}    ${last_UE}+1
    Wait Until Keyword Succeeds    5x    5sec    Expected Throughput For Ue Should Be Reached    ue_id=${UE}    retry=0    throughput=0.2
    ...    direction=ul    selection_type=average    layer=physical    scells=0-${num_of_scells}    margin=0.15
    Wait 2s For Egate Stabilization
    END

Verify RAC Failure For 5CC UE In NrCell-${cell_id}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
       ...   M55118C02015      0      RRC_RECONF_ADD4DLSCELL_ATT_SA
       ...   M55118C02014      0      RRC_RECONF_ADD4DLSCELL_SUCC_SA
       ...   M55118C11054      0      GNB_DL_SCELL_4_CONFIG_REQ_SA
       ...   M55118C11064      0      GNB_DL_SCELL_4_CONFIG_SUCC_SA
       ...   M55138C00048      0      GNB_SCELL_4_ADMI_REQ_SA
       ...   M55138C00049      0      GNB_SCELL_4_ADMI_SUCC_SA
       ...   M55138C03513      0      GNB_DL_SCELL_4_ADMI_REQ_SA
       ...   M55138C03520      0      GNB_DL_SCELL_4_ADMI_SUCC_SA
       ...   M55139C05505      0      GNB_DU_DL_SCELL_4_ADMI_REQ_SA
       ...   M55139C05512      0      GNB_DU_DL_SCELL_4_ADMI_SUCC_SA
       ...   M55138C01503      0      GNB_SCELL_ADMI_UNSUCC_SA
       ...   M55139C00023      0      GNB_DU_SCELL_4_ADMI_REQ_SA
       ...   M55139C00024      0      GNB_DU_SCELL_4_ADMI_SUCC_SA

       ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${cell_id}
       ...    file_path=${pm_counter_file}

Verify A1 Meas Based 5CC 6CC SCell Addition PM counters In saCell#${cell_id} For ${nr_of_5CC_UEs} 5CC UEs and ${nr_of_6CC_UEs} 6CC UEs
    ${num_of_scells_added}=    Evaluate    (${nr_of_5CC_UEs} * 4) + (${nr_of_6CC_UEs} * 5)
    ${num_of_scells_added_String}=    Convert To String    ${num_of_scells_added}
    ${total_nr_of_UEs}=    Evaluate    ${nr_of_5CC_UEs} + ${nr_of_6CC_UEs}
    ${total_nr_of_UEs_String}=    Convert To String    ${total_nr_of_UEs}
    Wait For Next Full Pm Interval
    ${pm_counter_file_5CC_6CC}=    Get Latest Unpacked Full Pm Counters File
    Set Suite Variable    ${pm_counter_file_5CC_6CC}
    Verify Any Counters In File
       ...   M55118C02015     ${nr_of_5CC_UEs}                 RRC_RECONF_ADD4DLSCELL_ATT_SA
       ...   M55118C02014     ${nr_of_5CC_UEs}                 RRC_RECONF_ADD4DLSCELL_SUCC_SA
       ...   M55118C11054     ${nr_of_5CC_UEs}                 GNB_DL_SCELL_4_CONFIG_REQ_SA
       ...   M55118C11064     ${nr_of_5CC_UEs}                 GNB_DL_SCELL_4_CONFIG_SUCC_SA
       ...   M55138C00048     ${nr_of_5CC_UEs}                 GNB_SCELL_4_ADMI_REQ_SA
       ...   M55138C00049     ${nr_of_5CC_UEs}                 GNB_SCELL_4_ADMI_SUCC_SA
       ...   M55138C03513     ${nr_of_5CC_UEs}                 GNB_DL_SCELL_4_ADMI_REQ_SA
       ...   M55138C03520     ${nr_of_5CC_UEs}                 GNB_DL_SCELL_4_ADMI_SUCC_SA
       ...   M55139C05505     ${nr_of_5CC_UEs}                 GNB_DU_DL_SCELL_4_ADMI_REQ_SA
       ...   M55139C05512     ${nr_of_5CC_UEs}                 GNB_DU_DL_SCELL_4_ADMI_SUCC_SA
       ...   M55138C01503     0                                GNB_SCELL_ADMI_UNSUCC_SA
       ...   M55139C00023     ${nr_of_5CC_UEs}                 GNB_DU_SCELL_4_ADMI_REQ_SA
       ...   M55139C00024     ${nr_of_5CC_UEs}                 GNB_DU_SCELL_4_ADMI_SUCC_SA
       ...   M55118C00001     ${nr_of_6CC_UEs}                 RRC_RECONF_ADD5DLSCELL_ATT_SA
       ...   M55118C00004     ${nr_of_6CC_UEs}                 RRC_RECONF_ADD5DLSCELL_SUCC_SA
       ...   M55118C11055     ${nr_of_6CC_UEs}                 GNB_DL_SCELL_5_CONFIG_REQ_SA
       ...   M55118C11065     ${nr_of_6CC_UEs}                 GNB_DL_SCELL_5_CONFIG_SUCC_SA
       ...   M55138C03504     ${nr_of_6CC_UEs}                 GNB_SCELL_5_ADMI_REQ_SA
       ...   M55138C03507     ${nr_of_6CC_UEs}                 GNB_SCELL_5_ADMI_SUCC_SA
       ...   M55138C03514     ${nr_of_6CC_UEs}                 GNB_DL_SCELL_5_ADMI_REQ_SA
       ...   M55138C03521     ${nr_of_6CC_UEs}                 GNB_DL_SCELL_5_ADMI_SUCC_SA
       ...   M55139C05506     ${nr_of_6CC_UEs}                 GNB_DU_DL_SCELL_5_ADMI_REQ_SA
       ...   M55139C05513     ${nr_of_6CC_UEs}                 GNB_DU_DL_SCELL_5_ADMI_SUCC_SA
       ...   M55139C03003     ${nr_of_6CC_UEs}                 GNB_DU_SCELL_5_ADMI_REQ_SA
       ...   M55139C03006     ${nr_of_6CC_UEs}                 GNB_DU_SCELL_5_ADMI_SUCC_SA
       ...   M55118C00032     ${num_of_scells_added_String}    A1_SCELL_ADDED_SA
       ...   M55124C02003     ${total_nr_of_UEs_String}        NRRCC_MEAS_A1_REC
       ...   M55124C00001     0                                NRRCC_RRC_RELEASE_SENT

       ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${cell_id}
       ...    file_path=${pm_counter_file_5CC_6CC}

Verify DRX Counters In saCell${cell_id}
       Wait For Next Full Pm Interval
       ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
       Verify Any Counters In File
       ...
       ...   local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${cell_id}
       ...   file_path=${pm_counter_file}

Verify nonGBR and GBR Counters After Blind SCell Addition For 15UEs
       Wait For Next Full Pm Interval
       ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
       Verify Any Counters In File
       ...   M55138C00015     29    PEAK_NUMBER_OF_SA_NGBR
       ...   M55138C00016     15    PEAK_NUMBER_OF_SA_NGBR_USERS
       ...   M55138C01001     14    GBR_DRB_REQ
       ...   M55138C01002     14    GBR_DRB_SUCC
       ...   M55138C01007     28    PEAK_NUMBER_OF_SA_GBR
       ...   M55125C09517     0     NG_FLOW_SETUP_ATT_TOT_5QI1
       ...   M55125C09518     0     NG_FLOW_SETUP_SUCC_TOT_5QI1
       ...   M55125C09530     14    PEAK_NUMBER_OF_UE_5QI1
       ...   local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-1
       ...   file_path=${pm_counter_file}

Verify nonGBR and GBR Counters After A1based SCell Addition For 20UEs
       Wait For Next Full Pm Interval
       ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
       Verify Any Counters In File
       ...   M55138C00015     30    PEAK_NUMBER_OF_SA_NGBR
       ...   M55138C00016     20    PEAK_NUMBER_OF_SA_NGBR_USERS
       ...   M55138C01001     20    GBR_DRB_REQ
       ...   M55138C01002     20    GBR_DRB_SUCC
       ...   M55138C01007     20    PEAK_NUMBER_OF_SA_GBR
       ...   M55125C09517     10    NG_FLOW_SETUP_ATT_TOT_5QI1
       ...   M55125C09518     10    NG_FLOW_SETUP_SUCC_TOT_5QI1
       ...   M55125C09530     10    PEAK_NUMBER_OF_UE_5QI1
       ...   local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-3
       ...   file_path=${pm_counter_file}

Verify nonGBR and GBR Counters After A1based SCell Addition For 40UEs
       Wait For Next Full Pm Interval
       ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
       Verify Any Counters In File
       ...   M55138C00015     80    PEAK_NUMBER_OF_SA_NGBR
       ...   M55138C00016     40    PEAK_NUMBER_OF_SA_NGBR_USERS
       ...   M55138C01001     40    GBR_DRB_REQ
       ...   M55138C01002     40    GBR_DRB_SUCC
       ...   M55138C01007     40    PEAK_NUMBER_OF_SA_GBR
       ...   M55125C09517     40    NG_FLOW_SETUP_ATT_TOT_5QI1
       ...   M55125C09518     40    NG_FLOW_SETUP_SUCC_TOT_5QI1
       ...   M55125C09530     40    PEAK_NUMBER_OF_UE_5QI1
       ...   local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-3
       ...   file_path=${pm_counter_file}

Verify A1 meas based 4CC SCell Addition For UE#37
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
       ...   M55118C09503     1        RRC_RECONF_ADD3DLSCELL_ATT_SA
       ...   M55118C09502     1        RRC_RECONF_ADD3DLSCELL_SUCC_SA
       ...   M55118C11053     1        GNB_DL_SCELL_3_CONFIG_REQ_SA
       ...   M55118C11063     1        GNB_DL_SCELL_3_CONFIG_SUCC_SA
       ...   M55138C03001     1        GNB_SCELL_3_ADMI_REQ_SA
       ...   M55138C03002     1        GNB_SCELL_3_ADMI_SUCC_SA
       ...   M55138C03512     1        GNB_DL_SCELL_3_ADMI_REQ_SA
       ...   M55138C03519     1        GNB_DL_SCELL_3_ADMI_SUCC_SA
       ...   M55138C03532     0        GNB_DL_SCELL_3_ADMI_UNSUCC_SA
       ...   M55139C05504     1        GNB_DU_DL_SCELL_3_ADMI_REQ_SA
       ...   M55139C05511     1        GNB_DU_DL_SCELL_3_ADMI_SUCC_SA
       ...   M55138C01503     0        GNB_SCELL_ADMI_UNSUCC_SA
       ...   M55139C03001     1        GNB_DU_SCELL_3_ADMI_REQ_SA
       ...   M55139C03002     1        GNB_DU_SCELL_3_ADMI_SUCC_SA
       ...   M55118C00032     3        A1_SCELL_ADDED_SA
       ...   M55124C02003     1        NRRCC_MEAS_A1_REC

       ...   local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-3
       ...   file_path=${pm_counter_file}

Verify A1 meas based 5CC SCell Addition And Lack Of RRCReconfigurationComplete PM counters in saCell#${cell_id}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
       ...   M55118C02015     1        RRC_RECONF_ADD4DLSCELL_ATT_SA
       ...   M55118C02014     0        RRC_RECONF_ADD4DLSCELL_SUCC_SA
       ...   M55118C11054     1        GNB_DL_SCELL_4_CONFIG_REQ_SA
       ...   M55118C11064     0        GNB_DL_SCELL_4_CONFIG_SUCC_SA
       ...   M55138C00048     1        GNB_SCELL_4_ADMI_REQ_SA
       ...   M55138C00049     1        GNB_SCELL_4_ADMI_SUCC_SA
       ...   M55138C03513     1        GNB_DL_SCELL_4_ADMI_REQ_SA
       ...   M55138C03520     1        GNB_DL_SCELL_4_ADMI_SUCC_SA
       ...   M55139C05505     1        GNB_DU_DL_SCELL_4_ADMI_REQ_SA
       ...   M55139C05512     1        GNB_DU_DL_SCELL_4_ADMI_SUCC_SA
       ...   M55138C01503     0        GNB_SCELL_ADMI_UNSUCC_SA
       ...   M55139C00023     1        GNB_DU_SCELL_4_ADMI_REQ_SA
       ...   M55139C00024     1        GNB_DU_SCELL_4_ADMI_SUCC_SA
       ...   M55118C00032     0        A1_SCELL_ADDED_SA
       ...   M55124C02003     1        NRRCC_MEAS_A1_REC
       ...   M55124C00001     1        NRRCC_RRC_RELEASE_SENT

       ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${cell_id}
       ...    file_path=${pm_counter_file}

Setup PDU Session for UE#${first_UE}-UE#${last_UE} with one non-GBR QoS Flow- 5QI 6
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Establish Pdu Session    ue_id=${UE}    pdu_id=1    nwslice=1    gw_id=${UE}    check_timestamps=${False}
    Wait 2s For PDU Session Establishment
    END

Perform PDU Session Modification By Adding 5QI
    [Arguments]    ${first_UE}    ${last_UE}    ${5QI}
    ${QoS_To_Add}=     Set variable if
    ...     '${5QI}'=='6'             3
    ...     '${5QI}'=='5'             1
    ...     '${5QI}'=='1'             2
    ...     '${5QI}'=='2'             4
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Modify Pdu Session       ue_id=${UE}    pdu_id=1    qos_to_add=${QoS_To_Add}    validation=on
    Wait 2s For PDU Session Modification
    END

Perform PDU Session Modification By Removing 5QI
    [Arguments]    ${first_UE}    ${last_UE}    ${5QI}
    ${QoS_To_Remove}=     Set variable if
    ...     '${5QI}'=='6'             1
    ...     '${5QI}'=='5'             2
    ...     '${5QI}'=='1'             3
    ...     '${5QI}'=='2'             4
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Modify Pdu Session       ue_id=${UE}    pdu_id=1    qos_to_del=${QoS_To_Remove}    validation=off
    Wait 2s For PDU Session Modification
    END

Perform RRCReestablishment via RRC Setup For UE#${first_UE} - UE#${last_UE}
    FOR    ${UE}     IN RANGE    ${first_UE}    ${last_UE}+1
    Reestablishment Via RRCSetup    ue_id=${UE}    dst_gnb=2    dst_cell=1
    END

Start Data Traffic for Multiple UEs
    [Arguments]    ${UE_ID}    ${ALL_UES}    ${PDU_ID}    ${QFI_ID}    ${TRF_ID}    ${DIR}    ${MBPS}
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}+1
        Execute Egate Command    cmd=trf_data_start ue=${ID} pdu=${PDU_ID} qfi=${QFI_ID} trf_id=${TRF_ID} dir=${DIR} mbps=${MBPS}
    END

Start GBR Data Traffic for Multiple UEs
    [Arguments]    ${UE_ID}    ${ALL_UES}    ${PDU_ID}    ${QFI_ID}    ${TRF_ID}    ${DIR}    ${KBPS}
    FOR  ${ID}    IN RANGE    ${UE_ID}    ${ALL_UES}+1
        Execute Egate Command    cmd=trf_data_start ue=${ID} pdu=${PDU_ID} qfi=${QFI_ID} trf_id=${TRF_ID} dir=${DIR} kbps=${KBPS}
    END

Exit Idle Mode For UE#${first_UE}-UE#${last_UE}
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Exit Idle Mode    ue_id=${UE}    pass_regexp=UE performed IM exit
    END

Wait ${x:\d+}s For ${reason}
    Sleep    ${x}s    ${reason}

Start Ping Tput For UE
    [Arguments]    ${UE_ID}    ${PDU_ID}=1    ${QFI_ID}=1    ${TRF_ID}=1    ${DIR}=dl    ${KBPS}=10
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=${PDU_ID} qfi=${QFI_ID} trf_id=${TRF_ID} dir=${DIR} kbps=${KBPS}

Setup PDU Session for UE#${first_UE}-UE#${last_UE} with one nonGBR QOS Flow
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Establish Pdu Session    ue_id=${UE}    pdu_id=1    nwslice=1    gw_id=${UE}
    END
