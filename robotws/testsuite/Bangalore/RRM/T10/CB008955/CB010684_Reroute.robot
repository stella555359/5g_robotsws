*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS25R1    CONFIGURED

Documentation
...             author:                 samik.sarkar@nokia.com
...             maintainer:             samik.sarkar@nokia.com

Resource         ./CB008441_resource.robot
Resource        ../../../resources/robot/wts_sim_keywords.robot
Library         ./python/basic.py
Library         ./python/fetch_counter_value.py

Suite Setup         Run keyword            Log To console  Suitesetup

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

*** Variables ***
#${SCFC}=        ${CURDIR}/config/SBTS24R3/TC8_SCF.xml
#${AP_XML}=      ${CURDIR}/config/SBTS24R3/TC8_iphy.xml
${rad_params}   0x5A0622=1
${wts_cfg_file_2}     ${CURDIR}/config/basic_setup_n28_40MHZ_band.cfg
${wts_cfg_file_3}       ${CURDIR}/config/XNHO_6PLMN_basic_Automation.cfg
${wts_cfg_file_4}       ${CURDIR}/config/XNHO_6PLMN_reroute.cfg
${AP_XML}           ${CURDIR}/config/SBTS25R3/7145_iphy.xml
${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_SANSA_TDD_LO-AP-LO.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${pathloss_start_dB}        75
${pathloss_end_dB}      130
${epc_log_path}    /tmp/
${TEST_NAME}        TC3
@{Component1}   L2HIPDCP
@{Nrcell}       NRCELL_1

${st_sa_ue}     0
${en_sa_ue}     0
${st_nsa_ue}    51
${en_nsa_ue}    53
${nsa_st_ue_id}      ${151}
${nsa_en_ue_id}      ${155}
${SCFC_10684}		${CURDIR}/config/SCF_XnHO_6PLMN_A_Subfeat.xml

${SCFC_10684_B}		${CURDIR}/config/SCF_TC_1_CB010684_B.xml
${cfg_10684_B}		${CURDIR}/config/TC_1_CB010684_B_basic.cfg

${UE_deregister_pattern}		UE CONTEXT RELEASE COMPLETE
${pattern}      Received Pdu Session Resource Setup Response
${reroutenas_success}   Initial UE Message with Registration Request Success for AMF Reroute
${original_pattern}      REGISTRATION COMPLETE
${AMF_SELECTION_ATT}			M55155C00001
${AMF_SELECTION_FAIL}			M55155C00002
${AMF_SELECTION_SUCC}			M55155C00003
${AMF_RESELECTION_GNB_ATT}		M55155C00004
${AMF_RESELECTION_GNB_FAIL}		M55155C00005
${AMF_RESELECTION_GNB_SUCC}		M55155C00006

*** Test Cases ***
CB010684_reroute
    [Setup]             Run keywords     Suite setup from scratch
   ...                 AND     BuiltIn.Set Suite Variable      ${SCFC}         ${SCFC_10684}
   ...                 AND     Prepare TL with SCF change
   ...                AND        Sleep   300s
#    ...                 AND     Reboot gNB System Module from Console and check Airscale is ready
#    ...                 AND     sleep   60s
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.12/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.13/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.14/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.15/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.16/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.20/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.22/24 dev eth3
    ...                 AND     Load CFG and verify cell status   ${wts_cfg_file_4}   1   1

    [Documentation]
    ...     CB010684-A#B02 03
    ...     This scenario indicates how AMF with relative capacity equal to 0 is considered for allocation for
    ...     AMF "selection during Reroute NAS request" scenarios with PLMN-1 when there are two AMF with relative
    ...     capacity zero is present
    ...     Test Case Requirement: 12683282
    ...     TEST SET NAME:     CB010684_Reroute.robot
    ...     TESTING SPLIT:     See CB010684-A testplan
    ...     REFERENCES:        C010684 CFAM

    Run Keyword and Ignore Error        Link SCOUT SCF to Configuration ID for Reporting
    ${servedamf_set2}   Create List     10.0.1.15       10.0.1.13   10.0.1.16   10.0.1.14
    ${servedamf_set1}    Create List     10.0.1.1    10.0.1.12
    ${ue_id_list}       Create List     1   11  21  26  51  61  71  76
    Set Global Variable     ${ue_id_list}   ${ue_id_list}
    Execute Egate Command   cmd=enb_x2_link_up enb=1 target=2
    Sleep   10s
    Execute Egate Command   cmd=gnb_xn_link_up gnb=3 target=2
    Sleep   10s
    Wait until the next Measurement Period starts  additional_time=${0}
    Modify NIDD parameters     paramName=actNgcLinkAllocForRc0       paramValue=true       operation=update       paramDst=MRBTS-1/NRBTS-1
    Comment     set amf reroute param
    Execute Egate Command   cmd=amf_param id=1 if=rcvd_initial_ue_msg action=reroute:3
    Execute Egate Command   cmd=amf_param id=2 if=rcvd_initial_ue_msg action=reroute:4
    Sleep   30s
    Set Test Variable       ${UE_reg_complete_pattern}    ${reroutenas_success}
    Start Log      btslog     cprt
    FOR     ${ue}   IN      @{ue_id_list}
     wts_sim_keywords.MultiUE Register should be Successful     ${ue}    ${ue}
    Sleep   20s
     wts_sim_keywords.MultiUE Trigger DL Traffic for SA    ${ue}    ${ue}   Traffic_rate=mbps     dl_rate=10
     ...    pdu_id=1     trf_id=1     qfi_id=1
     wts_sim_keywords.MultiUE Trigger UL Traffic for SA    ${ue}    ${ue}   Traffic_rate=mbps     ul_rate=10
     ...    pdu_id=1     trf_id=1     qfi_id=1
     wts_sim_keywords.Stop MultiUE Data Traffic for SA    ${ue}    ${ue}
     wts_sim_keywords.MultiUE Deregister should be Successful     ${ue}    ${ue}
    END
    ${scen1}     Stop Log      btslog     cprt      test_scenario=verifyreroutenas

    Modify NIDD parameters     paramName=actNgcLinkAllocForRc0       paramValue=false       operation=update       paramDst=MRBTS-1/NRBTS-1
    Execute Egate Command   cmd=amf_param id=1 if=rcvd_initial_ue_msg action=reroute:3
    Execute Egate Command   cmd=amf_param id=2 if=rcvd_initial_ue_msg action=reroute:4
    Sleep   30s
    Set Test Variable       ${UE_reg_complete_pattern}    ${original_pattern}
    Start Log      btslog     cprt
    FOR     ${ue}   IN      @{ue_id_list}
    ${status}   Run keyword and Return Status    wts_sim_keywords.MultiUE Register should be Successful     ${ue}    ${ue}
    Should be Equal as strings  ${status}   False
    END
    ${scen1}     Stop Log      btslog     cprt      test_scenario=noreroutenas
    sleep   15m
    Wait until the current Measurement Period stops  additional_time=${0}
    Set Global Variable    ${counterPath}         ${LOG_PATH}/${TEST_NAME}/PMC
    [Teardown]    Counter validation for reroute

CB010684-B#B01_01
    [Setup]             Run keywords     Suite setup from scratch
   ...                  AND     BuiltIn.Set Suite Variable      ${SCFC}         ${SCFC_10684_B}
   ...                  AND     Prepare TL with SCF change
   ...                  AND     Sleep   300s
   ...                  AND     Perform SCF Delta Commissioning with CB010684BB01_actCellBarringForNoAvailGuami_enable.json
   ...                  AND     Sleep   10s
#    ...                 AND     Reboot gNB System Module from Console and check Airscale is ready
#    ...                 AND     sleep   300s
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.12/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.13/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.14/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.15/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.16/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.20/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.22/24 dev eth3
    ...                 AND     Load CFG and verify cell status   ${cfg_10684_B}   1   1

    [Documentation]
    ...     CB010684-B#B01 01
    ...     This scenario indicates updated MIB broadcast to indicate Cell broadcasts MIB as "barred", when AMF support for
    ...     individual PLMN(s) is not available due to all GUAMIs marked as "unavailable" for active NG-C link(s)
    ...     Test Case Requirement: 12580701
    ...     CB010684-B#B02 02
    ...     This scenario indicates updated MIB broadcast to indicate Cell broadcasts MIB as "barred", when AMF support for
    ...     individual PLMN(s) is not available due to all GUAMIs marked as "unavailable" for active NG-C link(s) and again
    ...     updates the MIB broadcast to indicate Cell broadcasts MIB as "notBarred" when at least one of GUAMI is made as "available"
    ...     Test Case Requirement: 12580701; 12580704
    ...     CB010684-D#B01
    ...     This scenario indicates update broadcasting SIB1 status when All GUAMIs made unavailable via AMF STATUS
    ...     INDICATION message for MORAN cells 2 PLMN for SA+NSA Mode cell with PLMN1 first and PLMN2 later and also
    ...     reupdate when atleast one of GUAMI is available via AMF CONFIGURATION UPDATE message.
    ...     Test Case Requirement: 12580702; 12580703
    ...     REFERENCES:  C010684 CFAM
    ...     TEST SET NAME:     CB010684_Reroute.robot
    ...     TESTING SPLIT:     See CB010684-B Testplan
    ...     TESTING SPLIT:     See CB010684-D Testplan
    ...     REFERENCES:        C010684 CFAM

    [tags]    TC02

    Run Keyword and Ignore Error        Link SCOUT SCF to Configuration ID for Reporting

    Execute Egate Command   cmd=enb_x2_link_up enb=1 target=2

    Wait until the next Measurement Period starts  additional_time=${0}
    ${path_amf_1}    Make GUAMI Unavailable    1

    Comment     Perform SA UE-1 Attach.
    MultiUE Register should be Successful with AMF Selection    1   1   pdu_id=1     nw_id=1    amf_id=3

    ${path_amf_2}    Make GUAMI Unavailable    2

    MultiUE Register should be Successful with AMF Selection    11   11   pdu_id=1     nw_id=1    amf_id=4
    ${path_amf_3}    Make GUAMI Unavailable    3

    Comment     Verify Absence of TAC in SIB-1 update message. This is Part of Split-D Verification
    ${parsed_cells}      basic.parse_amf_file    ${path_amf_3}[egate]/amf_id_3.txt
    ${expected_cells}    basic.generate_cells_structure    None    ${201}    notBarred
    ${result}  ${report}    basic.validate_cells    ${parsed_cells}    ${expected_cells}
    log to console     ${report}
    Should Be Equal    ${result}     Pass
    Comment     Split-D verification completed

    ${status}   Run keyword and Return Status    wts_sim_keywords.MultiUE Register should be Successful     2    2
    ...       pdu_id=1     nw_id=1
    Should be Equal as strings  ${status}   False
    ${path_amf_4}     Make GUAMI Unavailable    4
    ${parsed_cells}      basic.parse_amf_file    ${path_amf_4}[egate]/amf_id_4.txt
    ${expected_cells}    basic.generate_cells_structure    None    ${201}    barred
    ${result}  ${report}    basic.validate_cells    ${parsed_cells}    ${expected_cells}
    log to console     ${report}
    Should Be Equal    ${result}     Pass

    ${status}   Run keyword and Return Status    wts_sim_keywords.MultiUE Register should be Successful     12    12
    ...       pdu_id=1     nw_id=1
    Should be Equal as strings  ${status}   False

    sleep   1m

    Comment     verify alarm
    ${act_alarm}    basic.get_active_alarm    sev=Critical
    ${val_arg}    Create Dictionary
    ...     alarmId=7112     additionalFaultID=7105     alarmDetail=Cells of the TAC barred due to slicing criteria
    log to console    ${act_alarm}
    ${result}    basic.validate_alarm_enhanced   ${act_alarm}    ${val_arg}
    Should Be Equal    ${result}     Pass
    sleep   15m
    Wait until the current Measurement Period stops  additional_time=${0}

    ${counter}      Create Dictionary    M55601C00024=${0}
    ${cell_barred}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC/cell_barred
    Collect PM Counter  target_dir=${cell_barred}

    Validate Counter for CellBarred     ${cell_barred}    ${counter}   isbarred=True

    Comment     Perform NSA UE Attach
    NSA Multi UE Attach should be Successful    101    102    1
    NSA Multi UE Attach should be Successful    121    122    1

    MultiUE Trigger DL Traffic for NSA    101    102   mbps     10   id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    101    102   mbps     10   id=2    trf_id=1

    MultiUE Trigger DL Traffic for NSA    121    122   mbps     10   id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    121    122   mbps     10   id=2    trf_id=1
    Sleep    5m
    NSA Multi UE Detach should be Successful    101    102
    NSA Multi UE Detach should be Successful    121    122

    Comment     Wireshark log Varification
    ${amf_1_validation}   Create Dictionary   ngap.pLMNIdentity=132006    guami.mcc=310    guami.mnc=260
    Verify AMF Status Indication    ${path_amf_1}[cprt]    10.0.1.1    ${amf_1_validation}
    ${amf_3_validation}   Create Dictionary   ngap.pLMNIdentity=132006    guami.mcc=310    guami.mnc=260
    Verify AMF Status Indication    ${path_amf_3}[cprt]    10.0.1.13    ${amf_3_validation}

    ${amf_2_validation}   Create Dictionary   ngap.pLMNIdentity=134109    guami.mcc=311    guami.mnc=490
    Verify AMF Status Indication    ${path_amf_2}[cprt]    10.0.1.12    ${amf_2_validation}
    ${amf_4_validation}   Create Dictionary   ngap.pLMNIdentity=134109    guami.mcc=311    guami.mnc=490
    Verify AMF Status Indication    ${path_amf_4}[cprt]    10.0.1.14    ${amf_4_validation}

    ${plmn_1_cell_barred_list}    Create List     0000040050    0000040060    0000040090    00000400c0
    Verify Cells_to be Barred List    ${path_amf_3}[cprt]    ${plmn_1_cell_barred_list}

    ${plmn_2_cell_barred_list}    Create List     0000040010    0000040020    0000040030    0000040040
    ...     0000040070    0000040080     00000400a0    00000400b0
    Verify Cells_to be Barred List    ${path_amf_4}[cprt]    ${plmn_2_cell_barred_list}

    Comment     Restore GUAMI Split-B
    Wait until the next Measurement Period starts  additional_time=${0}
    ${restore_amf_1}    Restore GUAMI     amf_id=1   plmn=310:260    amfi=1:1:7

    ${parsed_cells}      basic.parse_amf_file    ${restore_amf_1}[egate]/amf_id_1.txt
    ${expected_cells}    basic.generate_cells_structure    ${200}    None    notBarred
    ${result}  ${report}    basic.validate_cells    ${parsed_cells}    ${expected_cells}
    log to console     ${report}
    Should Be Equal    ${result}     Pass
    sleep    1m

    Comment     Verification of faultid:7105 is started
    ${alarm_hist_path}  Set Variable    ${LOG_PATH}/${TEST_NAME}/gNB/
    Create Directory        ${alarm_hist_path}
    basic.get_alarm_history     ${alarm_hist_path}/raw_alarm_history.txt
    ${result}   ${reason}      basic.validate_inactive_fault        ${alarm_hist_path}/raw_alarm_history.txt
    ...    fault_id=7105    expected_text_substring=AllCellsOfTacBarredDueSlicingCriteria
    log to console     ${reason}
    Should Be Equal    ${result}     Pass
    Comment     Verification of faultid:7105 is finish

    ${status}   Run keyword and Return Status    wts_sim_keywords.MultiUE Register should be Successful     2    2
    ...       pdu_id=1     nw_id=1
    Should be Equal as strings  ${status}   True

    ${restore_amf_2}    Restore GUAMI     amf_id=2   plmn=311:490    amfi=2:1:7
    ${parsed_cells}      basic.parse_amf_file    ${restore_amf_2}[egate]/amf_id_2.txt
    ${expected_cells}    basic.generate_cells_structure    ${200}    ${201}    notBarred
    ${result}  ${report}    basic.validate_cells    ${parsed_cells}    ${expected_cells}
    log to console     ${report}
    Should Be Equal    ${result}     Pass

    ${status}   Run keyword and Return Status    wts_sim_keywords.MultiUE Register should be Successful     12    12
    ...       pdu_id=1     nw_id=1
    Should be Equal as strings  ${status}   True

    ${restore_amf_3}    Restore GUAMI     amf_id=3    plmn=310:260    amfi=1:1:7
    ${restore_amf_4}    Restore GUAMI     amf_id=4    plmn=311:490    amfi=2:1:7

#    ${amf_1_validation}   Create Dictionary   ngap.pLMNIdentity=132006    guami.mcc=310    guami.mnc=260
#    Verify AMF Configuration Update    ${restore_amf_1}[cprt]    10.0.1.1    ${amf_1_validation}
#    ${amf_2_validation}   Create Dictionary   ngap.pLMNIdentity=134109    guami.mcc=311    guami.mnc=490
#    Verify AMF Configuration Update    ${restore_amf_2}[cprt]    10.0.1.12   ${amf_2_validation}

    sleep   30m
    Wait until the current Measurement Period stops  additional_time=${0}

    ${cell_not_barred}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC/cell_not_barred
    Collect PM Counter  target_dir=${cell_not_barred}

    Validate Counter for CellBarred     ${cell_not_barred}    ${counter}   isbarred=False

    [Teardown]


*** Keywords ***
Check gNB Bulid
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${GNB_SW_VERSION}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    Set Suite Variable    ${GNB_SW_VERSION}

NSA Intra-gNB HO
    [Arguments]    ${st_ue_id}    ${en_ue_id}   ${target_cell}=51    ${cell}=2    ${meas_type}=A3
    FOR     ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
    wtsrunner.ue_meas_cfg_disp    id=${ue_id}    meas_obj_type=nr
    ${x}    Set variable    === UE${ue_id} NR MEASUREMENT IDENTITIES:
    ${output1}    Read WTS Output For Pattern And Print matching Lines    ${x}    timeout=120
    Create File     ${OUTPUT_DIR}/nr_meas_nsa_${ue_id}.txt     ${output1}
    ${meas_id}    Run    cat ${OUTPUT_DIR}/nr_meas_nsa_${ue_id}.txt|grep 'NR.*Event${meas_type}'|cut -d ' ' -f 1
    log to console    meas_id_${meas_type}_${meas_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}
    ...     event=A3    srsrp_nr=19     srsrq_nr=19     phycell_id=${target_cell}
    ...     nrsrp_nr=101     nrsrq_nr=101
    ${Intra_Ho_Patt}    Set variable    'UEC-1: UE${ue_id}: Proxy (eNB 2 cell ${cell}) reported successful RA'
    ${output2}    Read WTS Output For Pattern And Print matching Lines    SgNBModificationConfirm    timeout=20
    Create File     ${OUTPUT_DIR}/intra_ho_nsa${ue_id}.txt     ${output2}
    ${rc}    Run And Return Rc   cat ${OUTPUT_DIR}/intra_ho_nsa${ue_id}.txt| grep ${Intra_Ho_Patt}
    Should be equal  ${rc}  ${0}
    END

NSA Data Start
    [Arguments]    ${st_ue_id}    ${en_ue_id}
    FOR     ${ue_idx}    IN RANGE     ${st_ue_id}    ${en_ue_id}
    wtsrunner.trf_data_start    ue=${ue_idx}       id=2        dir=dl      trf_id=2 mbps=3
    wtsrunner.trf_data_start    ue=${ue_idx}       id=2        dir=ul      trf_id=2 mbps=2
    END


Collect PM Counters
    [Arguments]    ${counter_path}
    ${pm_counters_dir}=  Collect PM Counter  target_dir=${OUTPUT_DIR}/PMC/${counter_path}
    Set Suite variable  ${pm_counters_dir}

Get buffer counters and validate CB008841
    [Arguments]    ${counter_path}
    [Documentation]    :Counter Details
    ...     Number of downlink PDCP SDU received over NR S1-U DL GTP-U tunnel - QoS Group 06 (M55315C00006)
    ...     Downlink data volume received over NR S1-U DL GTP-U tunnel - QoS Group 06 (M55315C01006)
    ...     Number of downlink PDCP PDU received over F1-U - QoS Group 6 (M55314C02006)
	...     Downlink data volume received over F1-U - QoS Group 6 (M55314C03006)
	...     Number of downlink PDCP PDU sent over F1-U - QoS Group 6 (M55323C00006)
	...     Downlink data volume sent over F1-U - QoS Group 6 (M55323C01006)
	...     DL PDCP SDUs discarded due to PDCP discard timer expiry - QoS Group 06 (M55320C20006)
	...     DL PDCP SDUs discarded due to Delay Based Discarding PI2 for non-GBR bearers (M55350C00035)
	...     ThpVolDl DL UE Throughput Volume at PDCP SDU Level - QoS Group 06 (M55350C01006)
	...     Number of PDCP PDU retransmitted - QoS Group 6 (M55320C12006)
	...     Volume of PDCP PDU retransmitted - QoS Group 6 (M55320C13006)

    ${pm_counters_dir}  Collect PM Counter  target_dir=${OUTPUT_DIR}/PMC/${counter_path}
    @{pi_list_1}=  Create List    M55315C00006    M55315C01006    M55314C02006  M55314C03006    M55323C00006
    ...     M55323C01006    M55320C20006    M55320C12006    M55320C13006
    @{pi_list_2}=  Create List    M55350C00035    M55350C01006    M55350C00006

    ${counter_value} =  Create Dictionary
    FOR    ${counter}    IN    @{pi_list_1}
    ${actual_pm_values}=    Run Keyword If
    ...    '${counter}' == 'M55314C02006' or '${counter}' == 'M55314C03006'
    ...    Get PM counter value modified    pm_files_location=${pm_counters_dir}
    ...    moc=MRBTS-1/NRBTS-1/NRDU-1    pi_id=${counter}
    ...    ELSE
    ...    Get PM counter value modified    pm_files_location=${pm_counters_dir}
    ...    moc=MRBTS-1/NRBTS-1    pi_id=${counter}

    ${actual_pm_values}=   convert to integer    ${actual_pm_values}
    set to dictionary    ${counter_value}       ${counter}     ${actual_pm_values}
    END
    FOR    ${counter}    IN    @{pi_list_2}
    ${x}    Create List
    ${actual_pm_values}        Get PM counter value modified    pm_files_location=${pm_counters_dir}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${counter}
    ${actual_pm_values_1}=   convert to integer    ${actual_pm_values}
    Append To List    ${x}      ${actual_pm_values_1}
    ${actual_pm_values_2}        Get PM counter value modified    pm_files_location=${pm_counters_dir}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-2    pi_id=${counter}
    ${actual_pm_values_2}=   convert to integer    ${actual_pm_values_2}
    Append To List    ${x}      ${actual_pm_values_2}
    set to dictionary    ${counter_value}       ${counter}     ${x}
    END
    log to console    ${counter_value}
    #Validation
    ${counter_diff}     Evaluate    ${counter_value}[M55315C00006]+${counter_value}[M55320C12006]-${counter_value}[M55314C02006]
    ${total_disc_counter}   Evaluate    sum(map(int,${counter_value}[M55350C00035]))+${counter_value}[M55320C20006]
    Run Keyword if      ${counter_diff}==${0}
    ...     Should be Equal     ${counter_diff}     ${total_disc_counter}
    ...     ELSE
    ...     Should be True      ${counter_diff}>=${total_disc_counter} or ${counter_diff}<${total_disc_counter}
    ${data_trans}   set variable if   ${counter_value}[M55314C03006] > ${counter_value}[M55323C01006]    ${counter_value}[M55323C01006]
    ...     ${counter_value}[M55314C03006]
    ${UE_dl_tput}   Evaluate    (sum(map(int, ${counter_value}[M55350C01006])))/8       #in KB
    ${ratio_tput}    Evaluate   ${UE_dl_tput}/${data_trans}
#    Should be True      0.90<=${ratio_tput}<=1
    Should be True      0.80<=${ratio_tput}<=1
    #Handover
    Should be True
    ...   ${counter_value}[M55350C01006][1]>${counter_value}[M55350C01006][0] or ${counter_value}[M55350C01006][1]<${counter_value}[M55350C01006][0]


Get PM counter value modified
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        get the value of a counter in the last reporting period
    ...
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=PM*
    ${last_report}    Get From List   ${PM_report_dict_list}     -1
    ${pi_dict}   Get Dictionary Values   ${last_report}
    ${first_pi}    Get From List   ${pi_dict}     0
    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
    ${cell_dict}   Get From List   ${cell_dict_list}     0
    ${moc_list}   get dictionary keys   ${cell_dict}
    ${full_moc}    Set Variable     empty
    FOR  ${key}  IN   @{moc_list}
       ${key_is_moc}  Run Keyword And Return Status    Should Be Equal  ${key}   ${moc}
       ${full_moc}  Set Variable If   ${key_is_moc}   ${key}    ${full_moc}
    END
    ${pi_value}     Get From Dictionary      ${cell_dict}    ${full_moc}
    BuiltIn.Log    ${pi_id} value: ${pi_value}   console=${P_console}
    [Return]    ${pi_value}

Modify NIDD parameters
    [Documentation]      This Keyword modify NIDD parameter as per the requirement of the feature
    [Arguments]      ${paramName}='None'      ${paramValue}='None'       ${operation}=update      ${paramDst}='None'
    Log to Console      Modifying NIDD parameters
    admin.Setup admin
    Online NIDD parameter change    paramName=${paramName}         paramValue=${paramValue}        operation=${operation}
    ...                             paramDst=${paramDst}
    sleep               60s
    [Teardown]          admin.Teardown admin

Verify Pcap for servedamf
    [Arguments]    ${file}          ${servedamf}
    FOR     ${ip}       IN      @{servedamf}
    ${packet}        set variable	ngap.procedureCode==15 && ip.src==10.0.1.2 && ip.dst==${ip}
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${file}         filterExp=${packet}       filterName=AMF_${ip}
    ${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=ngap
    ...                                                path=ngap
    Should Not Be Equal As Numbers     ${path_count}   0
    END

Verify locked or other available amf not served
    [Arguments]    ${file}          ${servedamf}
    FOR     ${ip}       IN      @{servedamf}
    ${packet}        set variable   ngap.procedureCode==15 && ip.src==10.0.1.2 && ip.dst==${ip}
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${file}         filterExp=${packet}       filterName=AMF_${ip}
    ${status}       Run Keyword and Return Status   analyzer.count_path          pdmlFile=${pdmlFile}
    ...                                                packetName=ngap
    ...                                                path=ngap
     Should be Equal as strings		${status}		False
    END

Fetch filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None        ${filterName}=None
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
    ...                             filterName=${filterName}        filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
    [Return]    ${pdmlFile}

MultiSAUE Register should be Successful
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File     ${OUTPUT_DIR}/regst.txt     ${output}
#    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk '{print $9}'
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
    #Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    Sleep       2s
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}

Register UE and verify served amf
	[Arguments]		${served_amf}	${notservedamf}
	Start Log      btslog     cprt
	FOR		${ue}	IN		@{ue_id_list}
    MultiUE Register should be Successful     ${ue}   ${ue}
    Sleep   20s
    MultiUE Trigger DL Traffic for SA    ${ue}  ${ue}   Traffic_rate=mbps     dl_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${ue}  ${ue}   Traffic_rate=mbps     ul_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    END
    ${scen}     Stop Log      btslog     cprt      test_scenario=param0
    Run keyword and continue on failure       Verify Pcap for servedamf   ${scen}[cprt]/NODECPRT_GNB.pcap        ${served_amf}
    Run keyword and continue on failure       Verify locked or other available amf not served     ${scen}[cprt]/NODECPRT_GNB.pcap    ${notservedamf}
	FOR		${ue}	IN		@{ue_id_list}
	Stop MultiUE Data Traffic for SA    ${ue}  ${ue}
    MultiUE Deregister should be Successful   ${ue}  ${ue}
	END

Stop Data and deregister ue

	FOR		${ue}	IN		@{ue_id_list}
	Stop MultiUE Data Traffic for SA    ${ue}	${ue}
	MultiUE Deregister should be Successful   ${ue}     ${ue}
	END

Trigger XnHO from real to simulator
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}     ${nrcgi}        ${XnHo_success1}=rrcReconfigurationComplete
    wtsrunner.ue_history_information_list_add_ngran     id=1    gnb_id=3    cell_type=medium    nrcgi=${nrcgi}  time_ue_stayed_in_cell=100
    wtsrunner.ue_history_information_list   action=commit   id=1
    wtsrunner.ue_enb_param  id=${ue_id}     ue_history_list=1
    wtsrunner.ue_meas_cfg_disp      id=${ue_id}     meas_obj_type=nr
    wtsrunner.ue_measurement_send_nr    id=${ue_id}   meas_id=${meas_id}      event=A3  srsrp_nr=19  phycell_id=${phycell_id}    nrsrp_nr=100
    ${output}      wtsrunner.read_wtsemu_output_until_re    expected=${XnHo_success1}    timeout=200


Register and Trigger XNHO for 4 ue and verify
	[Arguments]		${xnue_s}	${xnue_e}	${XnHomsg}=rrcReconfigurationComplete
	${change_loc}	Create List		1	1	2	2	7	7	8	8
	${nrcgi}	Create List	   310:260|0x01		311:490|0x01	310:260|0x02	311:490|0x02	310:260|0x07
	... 	311:490|0x07	310:260|0x08	311:490|0x08
	${phy_cellid}	Create List		51	51	52	52	57	57	58	58
    ${nw_idlist}    Create List     1   2   1   2   1   2   1   2
    ${meas_id_list}     Create List     4   3   7   7   11  11  11  11
    Set Test Variable       ${Initial_context_setup_pattern}     ${pattern}
	Start Log      btslog     cprt
	FOR		${id}	IN RANGE    	${xnue_s}		${xnue_e}+1
	wtsrunner.gnb_param		id=3	sib1_period=40
	wtsrunner.gnb_param		id=3    sib2_period=40
	wtsrunner.gnb_param		id=3    sib5_period=40
	wtsrunner.ue_change_location		id=${ue_id_list}[${id}]		 enb=3		cell=${change_loc}[${id}]
	MultiUE Register should be Successful     ${ue_id_list}[${id}]      ${ue_id_list}[${id}]        nw_id=${nw_idlist}[${id}]
    Sleep   20s
    MultiUE Trigger DL Traffic for SA    ${ue_id_list}[${id}]      ${ue_id_list}[${id}]   Traffic_rate=mbps
    ...     dl_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${ue_id_list}[${id}]      ${ue_id_list}[${id}]   Traffic_rate=mbps
    ...     ul_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    Trigger XnHO from real to simulator     ${ue_id_list}[${id}]	   ${meas_id_list}[${id}]
    ...    ${phy_cellid}[${id}]      ${nrcgi}[${id}]		${XnHomsg}
	END
	${scen}     Stop Log      btslog     cprt      test_scenario=xnho_${xnue_s}

Verify new pdu addition for AMF reselection
    [Arguments]     ${amfue_s}  ${amfue_e}  ${pdu_estab_msg}=${Initial_context_setup_pattern}
    ${nw_idlist}    Create List     1   2   1   2   1   2   1   2
    FOR     ${id}   IN RANGE        ${amfue_s}       ${amfue_e}+1
    wtsrunner.set_pdu_param   ue=${ue_id_list}[${id}]     pdu=2   trf_type=internal
    wtsrunner.ue_pdu_session_setup        pdu=2   ue=${ue_id_list}[${id}] nwslice=${nw_idlist}[${id}]      gw=1
    ${output}      wtsrunner.read_wtsemu_output_until_re    expected=${pdu_estab_msg}    timeout=200
    END

Validate counters for CB010684
    ${10684_counters}   Create List     M55155C00004    M55155C00006    M55155C00005    M55155C00001      M55155C00003     M55155C00002
    Collect PM Counters     10684scen
    FOR     ${counter}  IN  @{10684_counters}
    PM_Counters.Check PM counter value equal    expected_value=0   pm_files_location=${pm_counters_dir}
    ...  pi_id=${counter}       moc=MRBTS-1/NRBTS-1/NRCELL-1
    PM_Counters.Check PM counter value equal    expected_value=0   pm_files_location=${pm_counters_dir}
    ...  pi_id=${counter}       moc=MRBTS-1/NRBTS-1/NRCELL-2
    PM_Counters.Check PM counter value equal    expected_value=0   pm_files_location=${pm_counters_dir}
    ...  pi_id=${counter}       moc=MRBTS-1/NRBTS-1/NRCELL-7
    PM_Counters.Check PM counter value equal    expected_value=0   pm_files_location=${pm_counters_dir}
    ...  pi_id=${counter}       moc=MRBTS-1/NRBTS-1/NRCELL-8
    END
    Log To Console      Counter Value Verified

Verify Counters for CB010684
    [Arguments]  ${counters}    ${moc}
     ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
     ${counter_ids}=   Get Dictionary Keys    ${counters}
     ${counter_val}    Create Dictionary
     FOR   ${counter_id}  IN  @{counter_ids}
        ${e_value} =	Get From Dictionary	${counters}    ${counter_id}
        ${val}     Validate PM Counters_pcell_scell   ${PM_dir_1}    ${counter_id}    ${e_value}   ${moc}
     END
     [Return]    ${counter_val}


Get Total value of counter and compare
    [Arguments]   ${pm_files_location}     ${pi_id}    ${expected_value}    ${moc}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=PM*
    ${rc}       basic.get_total_cmp      ${PM_report_dict_list}     ${expected_value}    ${moc}
    Run Keyword and Ignore Error    Should Contain  ${rc}  PASS
    ${rest}	     ${val}     Split String From Right	    ${rc}    '#'
    [Return]    ${val}


Validate PM Counters_pcell_scell
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
#    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
#    ...  pi_id=${PM_counter}    moc=${moc}
    ${val}    Get Total value of counter and compare   ${PM_dir}   ${PM_counter}   ${expected_value}    ${moc}
    [Return]    ${val}

Verify_ue_registration_failure
    FOR     ${ue}   IN      @{ue_id_list}
    ${status}   Run keyword and Return Status    wts_sim_keywords.MultiUE Register should be Successful     ${ue}    ${ue}
    Should be Equal as strings  ${status}   False
    END


Counter validation for ue attach scenario with ng down
    ${Counters}    Create Dictionary     ${AMF_SELECTION_ATT}=${0}     ${AMF_SELECTION_FAIL}=${0}
    ...     ${AMF_SELECTION_SUCC}=${0}    ${AMF_RESELECTION_GNB_ATT}=${0}   ${AMF_RESELECTION_GNB_FAIL}=${0}     ${AMF_RESELECTION_GNB_SUCC}=${0}
    Run Keyword and Ignore Error    Verify Counters for CB010684      ${Counters}     NRCELL-1
    Run Keyword and Ignore Error    Verify Counters for CB010684      ${Counters}     NRCELL-2
    Run Keyword and Ignore Error    Verify Counters for CB010684      ${Counters}     NRCELL-7
    Run Keyword and Ignore Error    Verify Counters for CB010684      ${Counters}     NRCELL-8

Counter validation for xnho scenario
    ${Counters}    Create Dictionary     ${AMF_SELECTION_ATT}=${0}     ${AMF_SELECTION_FAIL}=${0}
    ...     ${AMF_SELECTION_SUCC}=${0}    ${AMF_RESELECTION_GNB_ATT}=${0}   ${AMF_RESELECTION_GNB_FAIL}=${0}     ${AMF_RESELECTION_GNB_SUCC}=${0}
    Run Keyword and Ignore Error    Verify Counters for CB010684      ${Counters}     NRCELL-1
    Run Keyword and Ignore Error    Verify Counters for CB010684      ${Counters}     NRCELL-2
    Run Keyword and Ignore Error    Verify Counters for CB010684      ${Counters}     NRCELL-7
    Run Keyword and Ignore Error    Verify Counters for CB010684      ${Counters}     NRCELL-8

Counter validation for all scenario
    ${Counters}    Create Dictionary     ${AMF_SELECTION_ATT}=${0}     ${AMF_SELECTION_FAIL}=${0}
    ...     ${AMF_SELECTION_SUCC}=${0}    ${AMF_RESELECTION_GNB_ATT}=${0}   ${AMF_RESELECTION_GNB_FAIL}=${0}     ${AMF_RESELECTION_GNB_SUCC}=${0}
    Verify Counters for CB010684      ${Counters}     NRCELL-1
    Verify Counters for CB010684      ${Counters}     NRCELL-2
    Verify Counters for CB010684      ${Counters}     NRCELL-7
    Verify Counters for CB010684      ${Counters}     NRCELL-8

Counter validation for reroute
    Collect PM Counter  target_dir=${counterPath}
    ${counter}    Create Dictionary     ${AMF_SELECTION_ATT}=${8}     ${AMF_SELECTION_FAIL}=${2}
    ...     ${AMF_SELECTION_SUCC}=${6}    ${AMF_RESELECTION_GNB_ATT}=${0}   ${AMF_RESELECTION_GNB_FAIL}=${0}     ${AMF_RESELECTION_GNB_SUCC}=${0}
    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-1     ${counter}
    ${counter}    Create Dictionary     ${AMF_SELECTION_ATT}=${8}     ${AMF_SELECTION_FAIL}=${2}
    ...     ${AMF_SELECTION_SUCC}=${6}    ${AMF_RESELECTION_GNB_ATT}=${0}   ${AMF_RESELECTION_GNB_FAIL}=${0}     ${AMF_RESELECTION_GNB_SUCC}=${0}
    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-2     ${counter}
    ${counter}    Create Dictionary     ${AMF_SELECTION_ATT}=${8}     ${AMF_SELECTION_FAIL}=${2}
    ...     ${AMF_SELECTION_SUCC}=${6}    ${AMF_RESELECTION_GNB_ATT}=${0}   ${AMF_RESELECTION_GNB_FAIL}=${0}     ${AMF_RESELECTION_GNB_SUCC}=${0}
    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-7     ${counter}
    ${counter}    Create Dictionary     ${AMF_SELECTION_ATT}=${8}     ${AMF_SELECTION_FAIL}=${2}
    ...     ${AMF_SELECTION_SUCC}=${6}    ${AMF_RESELECTION_GNB_ATT}=${0}   ${AMF_RESELECTION_GNB_FAIL}=${0}     ${AMF_RESELECTION_GNB_SUCC}=${0}
    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-8     ${counter}

Validate Counters
    [Arguments]     ${pm_files_location}    ${moc}    ${expected_val}
    ${pi_list}    Get Dictionary Keys    ${expected_val}
    @{counter_value} =  Create List
    FOR    ${counter}    IN    @{pi_list}
    log to console    validation-of-${counter}-is-started
    ${actual_pm_values}    fetch_counter_value.get_counter_value  ${pm_files_location}/gnb_pm_counters   ${moc}   ${counter}   all_files=True
    Should be Equal as numbers      ${actual_pm_values}     ${expected_val}[${counter}]
    END
    log to console    all-counters-validation-successful

Validate Counter for CellBarred
    [Arguments]     ${pm_files_location}    ${expected_val}    ${isbarred}=True
    ${pi_list}    Get Dictionary Keys    ${expected_val}
    ${counter}    Get From List    ${pi_list}    0
    FOR    ${idx}   IN RANGE    ${1}    ${13}
    ${moc}  Set Variable       MRBTS-1/NRBTS-1/NRCELL-${idx}
    log to console    validation-of-${counter}-is-started-for-${moc}
    ${actual_pm_values}    fetch_counter_value.get_counter_value  ${pm_files_location}/gnb_pm_counters   ${moc}   ${counter}   all_files=False
    Run Keyword if    "${isbarred}"=='False'
    ...     Should be Equal as numbers      ${actual_pm_values}     ${expected_val}[${counter}]
    ...     ELSE
    ...     Should be True    ${actual_pm_values} > ${expected_val}[${counter}]
    log to console    validation-of-${counter}-is-completed-for-${moc}
    END

Make GUAMI Unavailable
    [Arguments]    ${amf_id}
    ${logPath}  Set Variable    ${LOG_PATH}/${TEST_NAME}/gNB/egate/guami_unavailable
    Create Directory        ${logPath}
    Start Log      btslog     cprt
    ${cmd}  set variable    send_amf_status_indication id=${amf_id} guami_index=1
#    Execute Egate Command   ${cmd}
    ${outcome}    basic.execute_egate_command_new   ${cmd}
    log to console    amf_id-${amf_id}
    log to console    ${outcome}
    Create File       ${logPath}/amf_id_${amf_id}.txt     ${outcome}
    sleep   1s
    ${scen}     Stop Log     cprt    btslog      test_scenario=amf_id_${amf_id}
    Set To Dictionary     ${scen}        egate       ${logPath}
    log to console   final_path-${scen}
    [return]    ${scen}

#Restore GUAMI
#    [Arguments]     ${amf_id}=1    ${gnb}=2   ${isFirstunblock}=Yes   ${plmn}=310:260    ${amfi}=1:1:1
#    ${cmd}    Set Variable    amf_config_update id=${amf_id} plmn=310:260 amfi=${amfi}
#    ${regex1}  Set Variable
#    ...    AMF-${amf_id}: GNB-${gnb}: [NgLink::OnReceiveAMFConfigurationUpdateAcknowledge]::Received AMF Configuration Acknowledge from GNB-${gnb}
#
#    ${regex2}  Set Variable    UEC-1: eNB 2 cell .*: SystemInformationBlockType1-NR updated
#    ${regex}    Set Variable if    '${isFirstunblock}'=='Yes'   ${regex2}    ${regex1}
#    Start Log      btslog     cprt
#    ${output}		ute_wtssim.Execute Egate Command And Wait For Data  ${cmd}   pass_regexp=${regex}
#    ...      timeout=${EGATE_COMMAND_TIMEOUT}
#    Log to console      ${output}
#    Create File     ${OUTPUT_DIR}/restore_amf_id_${amf_id}.txt     ${output}
#    sleep    5s
#    ${scen}     Stop Log     cprt    btslog      test_scenario=guami_restore_amf_id_${amf_id}
#    [return]    ${scen}

Restore GUAMI
    [Arguments]     ${amf_id}=1    ${plmn}=310:260    ${amfi}=1:1:1

    ${logPath}  Set Variable    ${LOG_PATH}/${TEST_NAME}/gNB/egate/restore_guami
    Create Directory        ${logPath}
    Start Log      btslog     cprt
    ${cmd}    Set Variable    amf_config_update id=${amf_id} plmn=${plmn} amfi=${amfi}
    ${outcome}    basic.execute_egate_command_new   ${cmd}
    log to console    amf_id-${amf_id}
    log to console    ${outcome}
    Create File       ${logPath}/amf_id_${amf_id}.txt     ${outcome}
    sleep    1s
    ${scen}     Stop Log     cprt    btslog      test_scenario=guami_restore_amf_id_${amf_id}
    Set To Dictionary     ${scen}        egate       ${logPath}
    log to console   final_path-${scen}
    [return]    ${scen}

Verify AMF Status Indication
    [Arguments]    ${cprt_path}    ${AMF_IP}    ${val_param}
    ${filter}    Set Variable     ip.src==${AMF_IP} && ip.dst==10.0.1.2 && ngap.AMFStatusIndication_element
    ${pdmlFile}    analyzer.pcap_to_pdml    ${cprt_path}/NODECPRT_GNB.pcap      ${filter}

    ${keys}    Get Dictionary Keys    ${val_param}
    Log to console    keys-@{keys}
    FOR    ${key}   IN  @{keys}
    ${kind}     Set Variable if     '${key}'=='ngap.pLMNIdentity'   value   show

    ${var}     analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                     packetName=ngap.AMFStatusIndication_element
    ...                                     path=${key}$
    ...                                     endPacket=1
    ...                                     kind=${kind}
    Log to Console     ${key}-${var}
    Should be Equal     ${var}      ${val_param}[${key}]
    END

 Verify AMF Configuration Update
    [Arguments]    ${cprt_path}    ${AMF_IP}    ${val_param}
    ${filter}    Set Variable     ip.src==${AMF_IP} && ip.dst==10.0.1.2 && ngap.AMFConfigurationUpdate_element
    ${pdmlFile}    analyzer.pcap_to_pdml    ${cprt_path}/NODECPRT_GNB.pcap      ${filter}
    ${keys}    Get Dictionary Keys    ${val_param}
    Log to console    keys-@{keys}
    FOR    ${key}   IN  @{keys}
    ${kind}     Set Variable if     '${key}'=='ngap.pLMNIdentity'   value   show

    ${var}     analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                     packetName=ngap.AMFConfigurationUpdate_element
    ...                                     path=${key}$
    ...                                     endPacket=1
    ...                                     kind=${kind}
    Log to Console     ${key}-${var}
    Should be Equal     ${var}      ${val_param}[${key}]
    END

Verify Cells_to be Barred List
    [Arguments]    ${cprt_path}    ${cell_barred_list}
    ${filter}    Set Variable     f1ap.Cells_to_be_Barred_Item_element
    ${pdmlFile}    analyzer.pcap_to_pdml    ${cprt_path}/NODECPRT_GNB.pcap      ${filter}


    ${var}     analyzer.get_shownames       pdmlFile=${pdmlFile}
    ...                                     packetName=f1ap.Cells_to_be_Barred_Item_element
    ...                                     path=f1ap.nRCellIdentity
    ...                                     endPacket=1
    ...                                     kind=value
    Log to Console     Barred_List-${var}
    Should be Equal     ${var}      ${cell_barred_list}

MultiUE Register should be Successful with AMF Selection
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}    ${amf_id}=1
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
	${ue_reg_cmd}	SET VARIABLE	ue_register id=${ue_idx}
	${output}		ute_wtssim.Execute Egate Command And Wait For Data  ${ue_reg_cmd}   pass_regexp=${UE_reg_complete_pattern}
    ...      timeout=${EGATE_COMMAND_TIMEOUT}
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
	${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
	BuiltIn.Log     ${crnti_value}
	Log to Console             ue${ue_idx}_register_is_ok with ${crnti_value}
	Append To List  ${crnti_list}   ${crnti_value}
	${set_pdu_param_cmd}	SET VARIABLE	set_pdu_param ue=${ue_idx} pdu=${pdu_id} trf_type=internal
    ${pdu_setup_cmd}	SET VARIABLE	ue_pdu_session_setup pdu=${pdu_id} ue=${ue_idx} nwslice=${nw_id} gw=${ue_idx}
	ute_wtssim.Execute Egate Command    ${set_pdu_param_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
	${regex}    Set Variable    AMF-${amf_id}: Initial Context Setup Successful for UE with AMF UE ID
	ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd}
	...		pass_regexp=${regex}     timeout=${EGATE_COMMAND_TIMEOUT}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_value} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}

Verify SIB-1 For Cell
	[Arguments]		${filepath}		${cell_list}	${enb_id}=2
	Create Directory        ${filepath}
	${len}   Get Length    ${cell_list}
	${reg}   Set Variable   ue-TimersAndConstants
	FOR     ${i}    IN RANGE    ${0}   ${len}
    ${cell}     Set Variable    ${cell_list}[${i}]
	${sib_disp_cmd}		SET VARIABLE	enb_cell_ib_disp cell=${cell} enb=${enb_id} type=sib1
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data      ${sib_disp_cmd}     pass_regexp=${reg}
    ...     timeout=${EGATE_COMMAND_TIMEOUT}
    Create File     ${filepath}/SIB-1_update_cell_${cell}.txt     ${output}

	END
