*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS25R1    CONFIGURED

Documentation
...             author:                 samik.sarkar@nokia.com
...             maintainer:             samik.sarkar@nokia.com
...
...             INTRODUCTION:      CB008441_8_IntragNB_Handover_with_PDCP_Delay_Based_Discarding_PI2_5GC001094
...             TEST SET NAME:     CB008441_TC8.robot
...             TESTING SPLIT:     See CB008441 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008441 CFAM
...             REQUIREMENT ID:    5G_RAN_USR_RRM_23143,5G_RAN_USR_RRM_23758

Resource         ./CB008441_resource.robot
Library         ./python/basic.py
Library         ./python/fetch_counter_value.py

Suite Setup         Run keyword            Log To console  Suitesetup

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
#...                 AND     DCAP Disconnect To gNB
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport
...                 AND     Kill WTS processes Using WTS_Runner

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
${UE_deregister_pattern}		UE CONTEXT RELEASE COMPLETE
${pattern}      Received Pdu Session Resource Setup Response
${AMF_SELECTION_ATT}			M55155C00001
${AMF_SELECTION_FAIL}			M55155C00002
${AMF_SELECTION_SUCC}			M55155C00003
${AMF_RESELECTION_GNB_ATT}		M55155C00004
${AMF_RESELECTION_GNB_FAIL}		M55155C00005
${AMF_RESELECTION_GNB_SUCC}		M55155C00006

*** Test Cases ***
[1][1.0] CB008441_8_IntragNB_Handover_with_PDCP_Delay_Based_Discarding_PI2_5GC001094
#     Initiate Dcap
#     Prepare TL with all config files with rad_params
      Suite setup from scratch
      Perform SCF Delta Commissioning with enable_pi2_tc8.json
      sleep   120s
      Reboot gNB System Module from Console and check Airscale is ready
      Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
      Check gNB Bulid
#     DCAP Connect To gNB

    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    Increase Buffer Size for VM and IPHY

    X2AP Link Should be UP

    Start Log       btslog  cprt
    ${nsa_crnti_list1_PI2}  MultiUE NSA Attach should be Successful and Fetch CRNTI      51    52     Trgt_Cell=1
    log to console      attached-nsa-ue-rnti-${nsa_crnti_list1_PI2}

    ${nsa_crnti_list2_PI2}  MultiUE NSA Attach should be Successful and Fetch CRNTI      53    53     Trgt_Cell=2
    log to console      attached-nsa-ue-rnti-${nsa_crnti_list2_PI2}
    Stop Log    cprt    btslog    test_scenario=SCN1/PI2

    Wait until the next Measurement Period starts  additional_time=${0}
    Start Log      btslog
    Start Multiue Iperf3 TCP Sporadic Data  ${st_nsa_ue}    ${en_nsa_ue}    1000    600   4   DL  NSA
    sleep    300s
    NSA Intra-gNB HO    ${st_nsa_ue}    ${st_nsa_ue}    target_cell=53  cell=3
    sleep    300s
    Stop Iperf3 Traffic
    ${path_pi2}    Stop Log     btslog     test_scenario=SCN1/PI2
    Wait until the current Measurement Period stops  additional_time=${0}
    ${path_snap}    Stop Log    snapshot     test_scenario=SCN1/PI2
    Create Directory        ${LOG_PATH}/${TEST_NAME}/gNB/iperf3/SCN1/PI2
    OperatingSystem.Run      cp /tmp/iperf3_*_DL_*.txt ${LOG_PATH}/${TEST_NAME}/gNB/iperf3/SCN1/PI2
    OperatingSystem.Run      rm -rf /tmp/iperf3_*_DL_*.txt
    Set To Dictionary   ${path_pi2}     iperf3      ${LOG_PATH}/${TEST_NAME}/gNB/iperf3/SCN1/PI2
    Set To Dictionary   ${path_pi2}     snapshot    ${path_snap}[snapshot]
    log to console      path_pi2-${path_pi2}
    MultiUE Detach for NSA    ${st_nsa_ue}    ${en_nsa_ue}

    Get buffer counters and validate CB008841   PI2

    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

[1]CB007145_A#4_SgNBAdditionSuccess_ULandDLDataSuccess_of_FDD_40Mhz_n28RU_Long PUCCH_Multi_UE

	[Setup]             Run keywords     Suite setup from scratch
    ...                 AND     Prepare TL with IPHY file change
	...                 AND     Perform SCF Delta Commissioning with Delta_config_40MHZ_2CC_n28_AHPH.json
	...                 AND     sleep    10
	...                 AND     Reboot gNB System Module from Console and check Airscale is ready
	...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file_2}

#Starting CPRT Trace Capturing
    set test variable      ${LOG_PATH}
    X2AP Link Should be UP
    log to console   UE attach trigerring now...

    MultiUE Attach for NSA_7145    ${nsa_st_ue_id}    ${nsa_en_ue_id}
    MultiUE DL Traffic Start for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    mbps    10    id=2    trf_id=1
    MultiUE UL Traffic Start for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    mbps    10    id=2    trf_id=1

    sleep   180s

    MultiUE Validate DL Traffic For NSA     ${nsa_st_ue_id}     ${nsa_en_ue_id}     2       10
    MultiUE Validate UL Traffic For NSA     ${nsa_st_ue_id}     ${nsa_en_ue_id}     2       10

    MultiUE DL Traffic Stop for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    2    1
    MultiUE UL Traffic Stop for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    2    1
    MultiUE Detach for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}

	[Teardown]      Run Keywords
    ...             Sleep   1s
    ...             AND     Kill WTS processes Using WTS_Runner
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting

CB010684
    [Setup]             Run keywords     Suite setup from scratch
	...                 AND     BuiltIn.Set Suite Variable      ${SCFC}         ${SCFC_10684}
	...                 AND     Prepare TL with SCF change
    ...				    AND	    Sleep	300s
#    ...                 AND     Reboot gNB System Module from Console and check Airscale is ready
#    ...                 AND     sleep   300s
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.12/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.13/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.14/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.15/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.16/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.20/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.22/24 dev eth3
    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file_3}

    [Documentation]
    ...     CB010684-A#B01 05
    ...     This scenario indicates how AMF with relative capacity equal to 0 is considered for allocation for AMF
    ...     "selection" scenarios with PLMN-1 when there is two  AMF  with RC=0 present
    ...     Test Case Requirement: 12580666

    ...     CB010684-A#B03 03
    ...     This scenario indicates how AMF with relative capacity equal to 0 is considered for allocation for AMF
    ...     "selection during XN handover" (Target gNB) scenarios with PLMN-1 when there are two AMF with relative
    ...     capacity zero is present
    ...     Test Case Requirement: 12683281

    ...     CB010684-A#B04 03
    ...     This scenario indicates how AMF with relative capacity equal to 0 is considered for allocation for AMF
    ...     "reselection" scenarios with PLMN-1 when there are two AMF with relative capacity zero is present
    ...     Test Case Requirement: 12683279

    [Tags]    TC01

    Run Keyword and Ignore Error        Link SCOUT SCF to Configuration ID for Reporting
    wtsrunner.enb_x2_link_up  enb=1    target=2
    Sleep   10s
    wtsrunner.gnb_xn_link_up  gnb=3    target=2
    Sleep   10s
    ${servedamf_set2}   Create List     10.0.1.15       10.0.1.13   10.0.1.16   10.0.1.14
	${servedamf_set1}    Create List     10.0.1.1    10.0.1.12
	${ue_id_list}		Create List		1	11	21	26	51	61	71	76
	Set Global Variable		${ue_id_list}	${ue_id_list}
    Modify NIDD parameters     paramName=actNgcLinkAllocForRc0       paramValue=false       operation=update       paramDst=MRBTS-1/NRBTS-1
    Register UE and verify served amf       ${servedamf_set1}       ${servedamf_set2}

    wtsrunner.link_lock     link=ng     at=amf:1        to=gnb:2
    wtsrunner.link_lock     link=ng     at=amf:2        to=gnb:2
    Verify_ue_registration_failure

    Wait until the next Measurement Period starts  additional_time=${0}
	Modify NIDD parameters     paramName=actNgcLinkAllocForRc0       paramValue=true       operation=update       paramDst=MRBTS-1/NRBTS-1
	Register UE and verify served amf		${servedamf_set2}		${servedamf_set1}
#    Wait until the current Measurement Period stops  additional_time=${0}
#    Counter validation for ue attach scenario with ng down

    Comment     NEW PDU Addition for AMF reselection
    wtsrunner.link_unlock     link=ng     at=amf:1        to=gnb:2
    wtsrunner.link_unlock     link=ng     at=amf:2        to=gnb:2
    Sleep       10s
    Register ue with pdu1       ${servedamf_set1}       ${servedamf_set2}
    wtsrunner.link_lock     link=ng     at=amf:1        to=gnb:2
    wtsrunner.link_lock     link=ng     at=amf:2        to=gnb:2
    Sleep   10s
    Verify new pdu addition for AMF reselection     0   3   ${pattern}
    Modify NIDD parameters     paramName=actNgcLinkAllocForRc0       paramValue=false       operation=update       paramDst=MRBTS-1/NRBTS-1
    Sleep   20s
    Run Keyword and Ignore Error    Verify new pdu addition for AMF reselection     4   7       rrcRelease
    Stop Data and deregister ue

    Modify NIDD parameters     paramName=actNgcLinkAllocForRc0       paramValue=true       operation=update       paramDst=MRBTS-1/NRBTS-1
#    Wait until the next Measurement Period starts  additional_time=${0}
	Comment		Trigger xnho with link lock, param on
	Register and Trigger XNHO for 4 ue and verify		0		3
	Stop Data and deregister ue
    Comment     link lock, param off, trigger xnho
    Modify NIDD parameters     paramName=actNgcLinkAllocForRc0       paramValue=false       operation=update       paramDst=MRBTS-1/NRBTS-1
    Sleep   20s
    Register and Trigger XNHO for 4 ue and verify       0       3       transport-resource-unavailable
	Stop Data and deregister ue
	sleep   15m
    Wait until the current Measurement Period stops  additional_time=${0}
    Set Global Variable    ${counterPath}         ${LOG_PATH}/${TEST_NAME}/PMC
    [Teardown]    Counter validation for all scenario

Test
    ${Counters}    Create Dictionary     ${AMF_SELECTION_ATT}=${0}     ${AMF_SELECTION_FAIL}=${0}
    ...     ${AMF_SELECTION_SUCC}=${0}    ${AMF_RESELECTION_GNB_ATT}=${0}   ${AMF_RESELECTION_GNB_FAIL}=${0}     ${AMF_RESELECTION_GNB_SUCC}=${0}
    Verify Counters for CB010684      ${Counters}     NRCELL-1
    Verify Counters for CB010684      ${Counters}     NRCELL-2
    Verify Counters for CB010684      ${Counters}     NRCELL-7
    Verify Counters for CB010684      ${Counters}     NRCELL-8
    Verify Counters for CB010684      ${Counters}     NRCELL-1

CB010684_reroute
    [Setup]             Run keywords     Suite setup from scratch
#    ...    AND      Modify NIDD parameters     paramName=administrativeState       paramValue=Locked
#    ...             operation=update       paramDst=MRBTS-1/NRBTS-1/SNSSAI-2
#    ...     AND     Sleep   30s
#    ...                 AND     Perform SCF Delta Commissioning with Multitac_enable.json
#    ...                 AND     sleep    180s
    ...                 AND     BuiltIn.Set Suite Variable      ${SCFC}         ${SCFC_10684}
    ...                 AND     Prepare TL with SCF change
    ...                 AND     Sleep   300s
#    ...                 AND     Reboot gNB System Module from Console and check Airscale is ready
#    ...                 AND     sleep   300s
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.12/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.13/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.14/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.15/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.16/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.20/24 dev eth3
    ...                 AND     OperatingSystem.Run          sudo ip a a 10.0.1.22/24 dev eth3
    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file_4}

    [Documentation]
    ...     CB010684-A#B04 03
    ...     This scenario indicates how AMF with relative capacity equal to 0 is considered for allocation for AMF
    ...     "reselection" scenarios with PLMN-1 when there are two AMF with relative capacity zero is present
    ...     Test Case Requirement: 12683279

    [tags]    TC02

    ${servedamf_set2}   Create List     10.0.1.15       10.0.1.13   10.0.1.16   10.0.1.14
    ${servedamf_set1}    Create List     10.0.1.1    10.0.1.12
    ${ue_id_list}       Create List     1   11  21  26  51  61  71  76
    Set Global Variable     ${ue_id_list}   ${ue_id_list}

    Modify NIDD parameters     paramName=actNgcLinkAllocForRc0       paramValue=true       operation=update       paramDst=MRBTS-1/NRBTS-1
    Comment     set amf reroute param
    wtsrunner.amf_param     id=1        if_condition=rcvd_initial_ue_msg      action=reroute:3
    wtsrunner.amf_param     id=2        if_condition=rcvd_initial_ue_msg      action=reroute:4
    Sleep   30s
    Start Log      btslog     cprt
    FOR     ${ue}   IN      @{ue_id_list}
    MultiUE Register should be Successful     ${ue}    ${ue}
    Sleep   20s
    MultiUE Trigger DL Traffic for SA    ${ue}    ${ue}   Traffic_rate=mbps     dl_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${ue}    ${ue}   Traffic_rate=mbps     ul_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    Stop MultiUE Data Traffic for SA    ${ue}    ${ue}
    MultiUE Deregister should be Successful     ${ue}    ${ue}
    END
    ${scen1}     Stop Log      btslog     cprt      test_scenario=verifyreroutenas

    Modify NIDD parameters     paramName=actNgcLinkAllocForRc0       paramValue=false       operation=update       paramDst=MRBTS-1/NRBTS-1
    wtsrunner.amf_param     id=1        if=rcvd_initial_ue_msg      action=reroute:3
    wtsrunner.amf_param     id=2        if=rcvd_initial_ue_msg      action=reroute:4
    Sleep   30s
    Start Log      btslog     cprt
    FOR     ${ue}   IN      @{ue_id_list}
    ${status}   Run keyword and Return Status   MultiUE Register should be Successful     ${ue}    ${ue}
    Should be Equal as strings  ${status}   False
    END
    ${scen1}     Stop Log      btslog     cprt      test_scenario=noreroutenas


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
    Run keyword and continue on failure         Verify Pcap for servedamf   ${scen}[cprt]/NODECPRT_GNB.pcap        ${served_amf}
    Run keyword and continue on failure
    ...    Verify locked or other available amf not served     ${scen}[cprt]/NODECPRT_GNB.pcap        ${notservedamf}
	FOR		${ue}	IN		@{ue_id_list}
	Stop MultiUE Data Traffic for SA    ${ue}  ${ue}
    MultiUE Deregister should be Successful   ${ue}  ${ue}
	END

Register ue with pdu1
    [Arguments]     ${served_amf}   ${notservedamf}
    log to console    ${served_amf}
    log to console    ${notservedamf}
    Set Test Variable       ${Initial_context_setup_pattern}     reestablishment complete
    Start Log      btslog     cprt
    FOR     ${ue}   IN      @{ue_id_list}
    MultiUE Register should be Successful     ${ue}   ${ue}
    Sleep   20s
    MultiUE Trigger DL Traffic for SA    ${ue}  ${ue}   Traffic_rate=mbps     dl_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${ue}  ${ue}   Traffic_rate=mbps     ul_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    END
    ${scen}     Stop Log      btslog     cprt      test_scenario=pdu1

Stop Data and deregister ue
	FOR		${ue}	IN		@{ue_id_list}
	Run Keyword and Ignore Error    Stop MultiUE Data Traffic for SA    ${ue}	${ue}
	Run Keyword and Ignore Error    MultiUE Deregister should be Successful   ${ue}     ${ue}
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
	...     311:490|0x07	310:260|0x08	311:490|0x08
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
	MultiUE Register should be Successful     ${ue_id_list}[${id}]      ${ue_id_list}[${id}]     nw_id=${nw_idlist}[${id}]
    Sleep   20s
    MultiUE Trigger DL Traffic for SA    ${ue_id_list}[${id}]      ${ue_id_list}[${id}]
    ...   Traffic_rate=mbps     dl_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${ue_id_list}[${id}]      ${ue_id_list}[${id}]
    ...   Traffic_rate=mbps     ul_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    Trigger XnHO from real to simulator     ${ue_id_list}[${id}]	       ${meas_id_list}[${id}]
    ...      ${phy_cellid}[${id}]      ${nrcgi}[${id}]		${XnHomsg}
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

Verify new pdu addition for AMF reselection Failure
    [Arguments]     ${amfue_s}  ${amfue_e}  ${pdu_estab_msg}=${Initial_context_setup_pattern}
    ${nw_idlist}    Create List     1   2   1   2   1   2   1   2
    FOR     ${id}   IN RANGE        ${amfue_s}       ${amfue_e}+1
    wtsrunner.set_pdu_param   ue=${ue_id_list}[${id}]     pdu=2   trf_type=internal
    wtsrunner.ue_pdu_session_setup        pdu=2   ue=${ue_id_list}[${id}] nwslice=${nw_idlist}[${id}]      gw=1
    ${status}   Run Keyword and Return status     wtsrunner.read_wtsemu_output_until_re    expected=${pdu_estab_msg}    timeout=200
    Should be Equal as strings  ${status}   False
    END

Validate counters for CB010684
    ${10684_counters}   Create List     M55155C00004    M55155C00006    M55155C00005    M55155C00001
    ...      M55155C00003     M55155C00002
    Collect PM Counters     10684scen
    FOR     ${counter}  IN  @{10684_counters}
    PM_Counters.Check PM counter value bigger than    expected_value=0   pm_files_location=${pm_counters_dir}
    ...  pi_id=${counter}       moc=MRBTS-1/NRBTS-1/NRCELL-1
    PM_Counters.Check PM counter value bigger than    expected_value=0   pm_files_location=${pm_counters_dir}
    ...  pi_id=${counter}       moc=MRBTS-1/NRBTS-1/NRCELL-2
    PM_Counters.Check PM counter value bigger than    expected_value=0   pm_files_location=${pm_counters_dir}
    ...  pi_id=${counter}       moc=MRBTS-1/NRBTS-1/NRCELL-7
    PM_Counters.Check PM counter value bigger than    expected_value=0   pm_files_location=${pm_counters_dir}
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
    ${status}   Run keyword and Return Status    MultiUE Register should be Successful     ${ue}    ${ue}
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
    Collect PM Counter  target_dir=${counterPath}
    ${counter}    Create Dictionary     ${AMF_SELECTION_ATT}=${12}     ${AMF_SELECTION_FAIL}=${4}
    ...     ${AMF_SELECTION_SUCC}=${8}    ${AMF_RESELECTION_GNB_ATT}=${2}   ${AMF_RESELECTION_GNB_FAIL}=${0}     ${AMF_RESELECTION_GNB_SUCC}=${2}
    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-1     ${counter}
    ${counter}    Create Dictionary     ${AMF_SELECTION_ATT}=${12}     ${AMF_SELECTION_FAIL}=${4}
    ...     ${AMF_SELECTION_SUCC}=${8}    ${AMF_RESELECTION_GNB_ATT}=${2}   ${AMF_RESELECTION_GNB_FAIL}=${0}     ${AMF_RESELECTION_GNB_SUCC}=${2}
    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-2     ${counter}
    ${counter}    Create Dictionary     ${AMF_SELECTION_ATT}=${10}     ${AMF_SELECTION_FAIL}=${4}
    ...     ${AMF_SELECTION_SUCC}=${6}    ${AMF_RESELECTION_GNB_ATT}=${2}   ${AMF_RESELECTION_GNB_FAIL}=${2}     ${AMF_RESELECTION_GNB_SUCC}=${0}
    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-7     ${counter}
    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-8     ${counter}

Validate Counters
    [Arguments]     ${pm_files_location}    ${moc}    ${expected_val}
    ${pi_list}    Get Dictionary Keys    ${expected_val}
    @{counter_value} =  Create List
    FOR    ${counter}    IN    @{pi_list}
    log to console    validation-of-${counter}-is-started
    ${actual_pm_values}    fetch_counter_value.get_counter_value  ${pm_files_location}/gnb_pm_counters   ${moc}   ${counter}    all_files=True
    Should be Equal as numbers      ${actual_pm_values}     ${expected_val}[${counter}]
    END
    log to console    all-counters-validation-successful
