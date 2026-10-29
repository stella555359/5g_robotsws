*** Settings ***
Documentation
...  Author:  przemyslaw.sas@nokia.com, bartosz.grzegorczyk@nokia.com, marcin.szulc@nokia.com
...  Mantainer:  marcin.plawny@nokia.com

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library    testsuite/Wroclaw/RRM/resources/scout_report.py
Library    ta5g_testline_management
Library    ta5g_ue_measurements
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_delta
Library    ta5g_cell_operations
Library    ta5g_setups_and_teardowns
Library    ta5g_ue_mobility
Library    testsuite/Wroclaw/RRM/resources/syslog_checker.py

*** Variables ***
${NR_RRC_SIB1_PLMN_AND_RESERVED_STATUS_BEFORE_AMFS_SUPPORT}=    ${SIB1} && iphy.cell_id == 1 && nr-rrc.plmn_IdentityInfoList == 2
...                                                             && nr-rrc.cellReservedForOperatorUse == 0
${NR_RRC_SIB1_PLMN_AND_RESERVED_STATUS_AFTER_AMFS_SUPPORT}=     ${SIB1} && iphy.cell_id == 1 && nr-rrc.plmn_IdentityInfoList == 4
...                                                             && nr-rrc.cellReservedForOperatorUse == 0
${robustness_loop_number}=    15
${SUCCESSFUL_HO_REGEX_A2_SA}=    ServingCellMO is not present in CellGroupConfig
${SUCCESSFUL_HO_REGEX_A2_NSA}=    Successfully reconfigured dual connectivity
${SUCCESSFUL_HO_REGEX_A5_SA}=    : .. Handover [Ss]uccessfully completed at Target
${SUCCESSFUL_HO_REGEX_A5_NSA}=    : .=== Bearer-type change from MCG to SCG-split is successful, HandoverType = sn_change ===

${PLMN_object}=    MRBTS-1/NRBTS-1/NRPLMN-
@{Plmn_DNList_NSA}=    ${PLMN_object}2    ${PLMN_object}3    ${PLMN_object}4    ${PLMN_object}5    ${PLMN_object}6
@{Plmn_DNList_SA_1}=    ${PLMN_object}2    ${PLMN_object}3    ${PLMN_object}4
@{Plmn_DNList_SA_2}=    ${PLMN_object}6

*** Keywords ***
Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:gNB3_S1U  ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:gNB4_S1U  ip_with_mask=10.0.1.4/24
    Start Vm Ethernet Interface    if_name=eth3:gNB3_XN  ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:gNB3_NG  ip_with_mask=10.0.1.102/24
    Start Vm Ethernet Interface    if_name=eth3:gNB4_XN  ip_with_mask=10.0.1.103/24
    Start Vm Ethernet Interface    if_name=eth3:gNB4_NG  ip_with_mask=10.0.1.104/24
    Start Vm Ethernet Interface    if_name=eth3:gNB3_X2  ip_with_mask=10.0.1.105/24
    Start Vm Ethernet Interface    if_name=eth3:gNB4_X2  ip_with_mask=10.0.1.106/24
    Start Vm Ethernet Interface    if_name=eth3:eNB1_X2U  ip_with_mask=10.0.1.135/24
    Start Vm Ethernet Interface    if_name=eth3:eNB1_S1  ip_with_mask=10.0.1.136/24
    Start Vm Ethernet Interface    if_name=eth3:eNB1_X2  ip_with_mask=10.0.1.137/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:gNB3_S1U  ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB4_S1U  ip_with_mask=10.0.1.4/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB3_XN  ip_with_mask=10.0.1.101/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB3_NG  ip_with_mask=10.0.1.102/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB4_XN  ip_with_mask=10.0.1.103/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB4_NG  ip_with_mask=10.0.1.104/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB3_X2  ip_with_mask=10.0.1.105/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB4_X2  ip_with_mask=10.0.1.106/24
    Stop Vm Ethernet Interface    if_name=eth3:eNB1_X2U  ip_with_mask=10.0.1.135/24
    Stop Vm Ethernet Interface    if_name=eth3:eNB1_S1  ip_with_mask=10.0.1.136/24
    Stop Vm Ethernet Interface    if_name=eth3:eNB1_X2  ip_with_mask=10.0.1.137/24

Setup X2 Links
    Setup X2 Link    initiator_device=1  complementary_device=2
    Setup X2 Link    initiator_device=1  complementary_device=3
    Setup X2 Link    initiator_device=1  complementary_device=4

Set AMF To Use Mobility Restriction List
    [Arguments]    ${param_id}=1    ${mrl_id}=1
    Execute Egate Command    cmd=amf_ue_ng_handover_request_param id=${param_id} mobility_restriction_list_id=${mrl_id}

Configure DRX for NSA UE
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=ue_enb_param id=${ue_id} drx_config=on
    Sleep    1s  reason=Waiting for param setup

Configure DRX and Meas Gap for NSA UE
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=ue_enb_param id=${ue_id} drx_config=on measurement_gap=gp0:0 gap_trigger=gnb_triggered
    Sleep    1s  reason=Waiting for param setup

Attach UE To Enb And Start Gnb Addition
    [Arguments]    ${ue_id}
    Attach UE To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure    ue=${ue_id}  target_cells=1  target_gnb=2  bearer=2  dc_type=split_scg
    Sleep    2s  reason=Waiting for ue_dc_enb_start request to be processed

Attach NSA UE With Session And Send A2 Measurement
    [Arguments]    ${ue_id}    ${meas_id}=1    ${pass_regexp}=${SUCCESSFUL_HO_REGEX_A2_NSA}
    Attach UE To Enb And Start Gnb Addition    ue_id=${ue_id}
    Send A2 Measurement    ue_id=${ue_id}  meas_id=${meas_id}  pass_regexp=${pass_regexp}

Attach UE And Establish PDU Session And Send A5 Measurement For Inter Freq NSA HO
    [Arguments]    ${ue_id}    ${meas_id}=5    ${meas_idA2}=3    ${target_phycell_id}=51    ${nrsrp_nr}=120    ${nrsrq_nr}=120
    ...            ${pass_regexp_A2}=${SUCCESSFUL_HO_REGEX_A2_NSA}    ${pass_regexp_A5}=${ue_id}${SUCCESSFUL_HO_REGEX_A5_NSA}
    Attach NSA UE With Session And Send A2 Measurement    ue_id=${ue_id}  meas_id=${meas_idA2}  pass_regexp=${pass_regexp_A2}
    Send A5 Measurement And Attempt Handover    ue_id=${ue_id}  meas_id=${meas_id}  target_phycell_id=${target_phycell_id}
    ...                                         nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}  pass_regexp=${pass_regexp_A5}

Attach UE And Establish PDU Session And Send A5 Measurement For Intra Freq NSA HO
    [Arguments]    ${ue_id}    ${meas_id}=2    ${target_phycell_id}=51
    ...            ${nrsrp_nr}=120    ${nrsrq_nr}=120    ${pass_regexp_A5}=${ue_id}${SUCCESSFUL_HO_REGEX_A5_NSA}
    Attach UE To Enb And Start Gnb Addition    ue_id=${ue_id}
    Send A5 Measurement And Attempt Handover    ue_id=${ue_id}  meas_id=${meas_id}  target_phycell_id=${target_phycell_id}
    ...                                         nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}  pass_regexp=${pass_regexp_A5}

Attach UE And Establish PDU Session And Send A3 Measurement For Intra Freq NSA HO
    [Arguments]    ${ue_id}    ${meas_id}=2    ${target_phycell_id}=51
    ...            ${nrsrp_nr}=120    ${nrsrq_nr}=120    ${pass_regexp_A3}=${ue_id}${SUCCESSFUL_HO_REGEX_A5_NSA}
    Attach UE To Enb And Start Gnb Addition    ue_id=${ue_id}
    Send A3 Measurement And Attempt Handover    ue_id=${ue_id}  meas_id=${meas_id}  target_phycell_id=${target_phycell_id}
    ...                                         nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}  pass_regexp=${pass_regexp_A3}

Configure Xn Response To Send PLMN TAC List
    [Arguments]    ${gnb_id}=3    ${cell_id}=1    ${plmn_list}=311:489,311:492,311:495,311:498,311:500,311:501
    ${command} =  catenate  SEPARATOR=
    ...           gnb_xn_bcast_plmn_param gnb_id=${gnb_id} cell_id=${cell_id}
    ...           \ xn_setup_bcast_plmn_list=${plmn_list} xn_setup_bcast_plmn_id_info_list=${plmn_list}
    Execute Egate Command    cmd=${command}
    Sleep    1s  reason=Waiting for param setup

Attach UE And Establish PDU Session Without Traffic
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${gw_id}=1
    Attach UE    ue_id=${ue_id}
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id}
    Sleep    2s  reason=Waiting for establish PDU Session

Attach UE And Establish PDU Session
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${gw_id}=1
    Attach UE    ue_id=${ue_id}
    Establish PDU Session With Traffic    ue_id=${ue_id}  pdu_id=${pdu_id}  gw_id=${gw_id}
    Sleep    2s  reason=Waiting for RRCReconfigurationComplete for A2 measurement report setup

Send A2 Measurement
    [Arguments]    ${ue_id}    ${meas_id}=1    ${pass_regexp}=${SUCCESSFUL_HO_REGEX_A2_SA}
    Send Custom UE Measurement Nr    pass_regexp=${pass_regexp}
    ...                              id=${ue_id}  meas_id=${meas_id}  event=A2  srsrp_nr=11  srsrq_nr=11  srs_result=0:11:11:0
    Sleep    3s  reason=Waiting for A5 measurement report setup

Attach UE And Establish PDU Session And Send A2 Measurement
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${gw_id}=1    ${meas_id}=1    ${pass_regexp}=${SUCCESSFUL_HO_REGEX_A2_SA}
    Attach UE And Establish PDU Session  ue_id=${ue_id}  pdu_id=${pdu_id}  gw_id=${gw_id}
    Send A2 Measurement    ue_id=${ue_id}  meas_id=${meas_id}  pass_regexp=${pass_regexp}

Send A5 Measurement And Attempt Handover
    [Arguments]    ${ue_id}    ${meas_id}=3    ${target_phycell_id}=51    ${nrsrp_nr}=120    ${nrsrq_nr}=120
    ...            ${pass_regexp}=${ue_id}${SUCCESSFUL_HO_REGEX_A5_SA}
    Send Custom UE Measurement Nr    pass_regexp=${pass_regexp}  id=${ue_id}  meas_id=${meas_id}  index=0  get_ue_meas_cfg=1
    ...                              nrs_result=${nrsrp_nr}:${nrsrq_nr}:0  event=A5  srsrp_nr=11  srsrq_nr=11  srs_result=0:11:11:0
    ...                              phycell_id=${target_phycell_id}  nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}  rs_type=ssb
    Sleep    3s  reason=Waiting for handover request to be processed

Send A3 Measurement And Attempt Handover
    [Arguments]    ${ue_id}    ${meas_id}=2    ${target_phycell_id}=51    ${nrsrp_nr}=120    ${nrsrq_nr}=120
    ...            ${pass_regexp}=${ue_id}${SUCCESSFUL_HO_REGEX_A5_SA}
    Send Custom UE Measurement Nr    pass_regexp=${pass_regexp}  id=${ue_id}  meas_id=${meas_id}  index=0  get_ue_meas_cfg=1
    ...                              nrs_result=${nrsrp_nr}:${nrsrq_nr}:0  event=A3  srsrp_nr=11  srsrq_nr=11  srs_result=0:11:11:0
    ...                              phycell_id=${target_phycell_id}  nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}  rs_type=ssb
    Sleep    3s  reason=Waiting for handover request to be processed

Attach UE And Establish PDU Session And Send A5 Measurement For Inter Freq HO
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${gw_id}=1    ${meas_id}=3    ${meas_idA2}=1    ${target_phycell_id}=51    ${nrsrp_nr}=120
    ...            ${nrsrq_nr}=120    ${pass_regexp_A2}=${SUCCESSFUL_HO_REGEX_A2_SA}    ${pass_regexp_A5}=${ue_id}${SUCCESSFUL_HO_REGEX_A5_SA}
    Attach UE And Establish PDU Session And Send A2 Measurement    ue_id=${ue_id}  pdu_id=${pdu_id}  gw_id=${gw_id}  meas_id=${meas_idA2}
    ...                                                            pass_regexp=${pass_regexp_A2}
    Send A5 Measurement And Attempt Handover    ue_id=${ue_id}  meas_id=${meas_id}  target_phycell_id=${target_phycell_id}
    ...                                         nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}  pass_regexp=${pass_regexp_A5}

Attach UE And Establish PDU Session And Send A5 Measurement For Intra Freq HO
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${gw_id}=1    ${meas_id}=3    ${target_phycell_id}=51
    ...            ${nrsrp_nr}=120    ${nrsrq_nr}=120  ${pass_regexp_A5}=${ue_id}${SUCCESSFUL_HO_REGEX_A5_SA}
    Attach UE And Establish PDU Session    ue_id=${ue_id}  pdu_id=${pdu_id}  gw_id=${gw_id}
    Send A5 Measurement And Attempt Handover    ue_id=${ue_id}  meas_id=${meas_id}  target_phycell_id=${target_phycell_id}
    ...                                         nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}  pass_regexp=${pass_regexp_A5}

Attach UE And Establish PDU Session And Send A3 Measurement For Intra Freq HO
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${gw_id}=1    ${meas_id}=2    ${target_phycell_id}=51
    ...            ${nrsrp_nr}=120    ${nrsrq_nr}=120
    Attach UE And Establish PDU Session    ue_id=${ue_id}  pdu_id=${pdu_id}  gw_id=${gw_id}
    Send A3 Measurement And Attempt Handover    ue_id=${ue_id}  meas_id=${meas_id}  target_phycell_id=${target_phycell_id}
    ...                                         nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}

Add Item To UE History Information List
    [Arguments]    ${ue_id}    ${gnb_id}=3    ${history_list_id}=4
    ${command}=    Catenate    ue_history_information_list_add_ngran id=${history_list_id} gnb_id=${gnb_id}
    ...                        cell_type=medium nrcgi=311:498|0x03 time_ue_stayed_in_cell=100
    Execute Egate Command
    ...  cmd=${command}
    Execute Egate Command    cmd=ue_history_information_list id=${history_list_id} action=commit
    Execute Egate Command    cmd=ue_enb_param id=${ue_id} ue_history_list=${history_list_id}

Attach Ue And Establish Pdu Session With History List
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${gw_id}=1    ${history_list_id}=4    ${gnb_id}=3
    Attach UE And Establish PDU Session Without Traffic    ue_id=${ue_id}  pdu_id=${pdu_id}  gw_id=${gw_id}
    Add Item To UE History Information List    ue_id=${ue_id}  history_list_id=${history_list_id}  gnb_id=${gnb_id}

Perform A5 Handover to Real GNB
    [Arguments]    ${ue_id}    ${phycell_id}=50    ${meas_id}=1    ${pass_regexp}=Inter-eNB handover from
    Send Custom Ue Measurement Nr    pass_regexp=${pass_regexp}  get_ue_meas_cfg=1
    ...                              id=${ue_id}  meas_id=${meas_id}  event=A5  srsrp_nr=19  phycell_id=${phycell_id}  nrsrp_nr=68
    Sleep    5s  reason=Waiting for handover request to be processed

Verify Handover Preparation Failure Message
    Verify Tcpdump Log    packet_filter=${NGAP_HANDOVER_FAILURE} && ngap.radioNetwork == 8

Verify Handover Preparation Success Message
    Verify Tcpdump Log    packet_filter=${NGAP_HANDOVER_REQUEST_ACKNOWLEDGE}

Verify NRADJNRCELL Object
    [Documentation]    Validate NRADJNRCELL object created in network plan by ANR feature.
    ...                Keyword compares requested parameters to values in SCF configuration.
    [Arguments]    ${NRADJNRCELL}    ${mcc}    ${mnc}    ${mncLength}    ${physCellId}    ${cellDepType}    ${nrarfcn}    ${ssbFrequency}
    ...            ${gNbId}    ${gNbIdLength}
    Should Be Equal As Integers    ${NRADJNRCELL.gnbPlmn.mcc}    ${mcc}
    Should Be Equal As Integers    ${NRADJNRCELL.gnbPlmn.mnc}    ${mnc}
    Should Be Equal As Integers    ${NRADJNRCELL.gnbPlmn.mncLength}    ${mncLength}
    Should Be Equal As Integers    ${NRADJNRCELL.physCellId}     ${physCellId}
    Should Be Equal    ${NRADJNRCELL.cellDepType}     ${cellDepType}
    Should Be Equal As Integers    ${NRADJNRCELL.nrarfcn}    ${nrarfcn}
    Should Be Equal As Integers    ${NRADJNRCELL.ssbFrequency}    ${ssbFrequency}
    Should Be Equal As Integers    ${NRADJNRCELL.gNbId}    ${gNbId}
    Should Be Equal As Integers    ${NRADJNRCELL.gNbIdLength}    ${gNbIdLength}

Verify NRREL Object
    [Documentation]    Validate NRREL object created in network plan by ANR feature.
    ...                Keyword compares requested parameters to values in SCF configuration.
    [Arguments]    ${NRREL}    ${mcc}    ${mnc}    ${mncLength}    ${gNbId}    ${gNbIdLength}    ${removeNotAllowed}=${False}
    ...            ${cellIndividualSsbRsrpOffset}=0dB    ${cellIndividualSsbRsrqOffset}=0dB
    Should Be Equal    ${NRREL.cellIndividualSsbRsrpOffset}    ${cellIndividualSsbRsrpOffset}
    Should Be Equal    ${NRREL.cellIndividualSsbRsrqOffset}    ${cellIndividualSsbRsrqOffset}
    Should Be Equal As Integers    ${NRREL.gnbPlmn.mcc}    ${mcc}
    Should Be Equal As Integers    ${NRREL.gnbPlmn.mnc}    ${mnc}
    Should Be Equal As Integers    ${NRREL.gnbPlmn.mncLength}    ${mncLength}
    Should Be Equal As Integers    ${NRREL.gNbId}     ${gNbId}
    Should Be Equal As Integers    ${NRREL.gNbIdLength}     ${gNbIdLength}
    Should Be Equal    ${NRREL.removeNotAllowed}    ${removeNotAllowed}

Verify Created NRADJNRCELL And NRREL Objects
    [Arguments]    ${PCI}=150    ${gNB_id}=3    ${NRADJNRCELL_ID}=12288    ${NRREL_ID}=256    ${mcc}=311    ${mnc}=489    ${nrarfcn}=636666
    ...            ${timeout}=150    ${gNbIdLength}=22    ${ssbFrequency}=636576
    Wait For Object To Exist    object_name=NRADJNRCELL_A-${NRADJNRCELL_ID}  moc=NRADJNRCELL_A  timeout=${timeout}
    Wait For Object To Exist    object_name=NRCELL_A-1/NRREL_A-${NRREL_ID}  moc=NRREL_A  timeout=${timeout}
    &{NRADJNRCELL}=    Get Managed Object  object_name=NRADJNRCELL_A-${NRADJNRCELL_ID}  moc=NRADJNRCELL_A
    &{NRREL}=    Get Managed Object  object_name=NRCELL_A-1/NRREL_A-${NRREL_ID}  moc=NRREL_A
    Verify NRADJNRCELL Object    NRADJNRCELL=&{NRADJNRCELL}  mcc=${mcc}  mnc=${mnc}
    ...                            mncLength=3  physCellId=${PCI}  cellDepType=SA+NSA
    ...                            nrarfcn=${nrarfcn}  ssbFrequency=${ssbFrequency}  gNbId=${gNB_id}  gNbIdLength=${gNbIdLength}
    Verify NRREL Object    NRREL=&{NRREL}  mcc=${mcc}  mnc=${mnc}  mncLength=3  gNbId=${gNB_id}  gNbIdLength=${gNbIdLength}

Verify Created NRPLMNSET_NSA Object
    [Documentation]    Validate NRPLMNSET_NSA object created in network plan by ANR feature.
    ...                Keyword compares requested parameters to values in SCF configuration.
    [Arguments]    ${NRPLMNSET_NSA}    ${cellReservedForOperatorUse}    ${nrPlmnDNList}
    Should Be Equal    ${NRPLMNSET_NSA.cellReservedForOperatorUse}    ${cellReservedForOperatorUse}
    Should Be Equal    ${NRPLMNSET_NSA.nrPlmnDNList}    ${nrPlmnDNList}

Verify Created NRPLMNSET_SA Object
    [Documentation]    Validate NRPLMNSET_SA object created in network plan by ANR feature.
    ...                Keyword compares requested parameters to values in SCF configuration.
    [Arguments]    ${NRPLMNSET_SA}    ${cellReservedForOperatorUse}    ${fiveGsTac}    ${nrPlmnDNList}
    Should Be Equal    ${NRPLMNSET_SA.cellReservedForOperatorUse}    ${cellReservedForOperatorUse}
    Should Be Equal As Integers    ${NRPLMNSET_SA.fiveGsTac}    ${fiveGsTac}
    Should Be Equal    ${NRPLMNSET_SA.nrPlmnDNList}    ${nrPlmnDNList}

Verify Created NRPLMNSET_SA and NRPLMNSET_NSA Objects
    [Documentation]    This keyword is test specific, it checks if 2 NRPLMNSET_SA and 1 NRPLMNSET_NSA objects are created.
    ...                Objects will be created with values defined in variables: Plmn_DNList_SA_1, Plmn_DNList_SA_2, Plmn_DNList_NSA
    [Arguments]    ${NRADJNRCELL_ID}=12288
    &{NRPLMNSET_NSA}=    Get Managed Object  object_name=NRADJNRCELL_A-${NRADJNRCELL_ID}/ADJ_NRPLMNSET_NSA_A-1  moc=ADJ_NRPLMNSET_NSA_A
    &{NRPLMNSET_SA_1}=    Get Managed Object  object_name=NRADJNRCELL_A-${NRADJNRCELL_ID}/ADJ_NRPLMNSET_SA_A-1  moc=ADJ_NRPLMNSET_SA_A
    &{NRPLMNSET_SA_2}=    Get Managed Object  object_name=NRADJNRCELL_A-${NRADJNRCELL_ID}/ADJ_NRPLMNSET_SA_A-2  moc=ADJ_NRPLMNSET_SA_A
    Verify Created NRPLMNSET_NSA Object    NRPLMNSET_NSA=&{NRPLMNSET_NSA}    cellReservedForOperatorUse=notReserved
    ...                                    nrPlmnDNList=@{Plmn_DNList_NSA}
    Verify Created NRPLMNSET_SA Object    NRPLMNSET_SA=&{NRPLMNSET_SA_1}    cellReservedForOperatorUse=notReserved
    ...                                   fiveGsTac=200  nrPlmnDNList=@{Plmn_DNList_SA_1}
    Verify Created NRPLMNSET_SA Object    NRPLMNSET_SA=&{NRPLMNSET_SA_2}    cellReservedForOperatorUse=reserved
    ...                                   fiveGsTac=201  nrPlmnDNList=@{Plmn_DNList_SA_2}

SIB1 Verify For PLMN Count With CellReserved Status Before Activation AMFs PLMN Support
    Verify Uu Messages    packet_filter=${NR_RRC_SIB1_PLMN_AND_RESERVED_STATUS_BEFORE_AMFS_SUPPORT}
    ...                   relation_symbol=>=

Activate AMFs Support
    Execute Egate Command    cmd=amf_param ignore_ng=off id=1
    Execute Egate Command    cmd=amf_param ignore_ng=off id=2

SIB1 Verify For PLMN Count With CellReserved Status After Activation AMFs PLMN Support
    Verify Uu Messages    packet_filter=${NR_RRC_SIB1_PLMN_AND_RESERVED_STATUS_AFTER_AMFS_SUPPORT}
    ...                   relation_symbol=>=    timeout=180

AMF1 Ng Link Reset and UE Attache Check
    Execute Egate Command    cmd=amf_ng_setup_param id=1 gnb=2 request_ignore=on
    Execute Egate Command    cmd=link_drop link=ng by=amf:1 to=gnb:2 msg_type=abort
    Execute Egate Command    cmd=amf_ng_setup_param id=1 gnb=2 request_ignore=off
    Sleep    30s    reason=Waiting For Ng Request Setup
    Attach UE    ue_id=6
    Deregister UE without confirmation    ue_id=all

Lock Unlock Cell 1
    Lock Single Cell    cell_id=1    timeout=90
    Unlock Single Cell    cell_id=1    timeout=90

Loop For Robustness AMF1 Ng Link Reset and UE Attache Check
    [Arguments]    ${test_name}    ${loop_number}
    ${status_of_execution}    create list
    set test variable    ${exec_number}    0
    FOR    ${i}    IN RANGE    ${loop_number}
        ${TC_status}    run keyword and return status    ${test_name}
        Append To List    ${status_of_execution}    ${TC_status}
    END
    Check If None Of Executions Fails    ${status_of_execution}

Check If None Of Executions Fails
    [Arguments]    ${status_of_execution}
    FOR    ${exec}    IN    @{status_of_execution}
        should not be equal as strings    ${exec}    False
    END
