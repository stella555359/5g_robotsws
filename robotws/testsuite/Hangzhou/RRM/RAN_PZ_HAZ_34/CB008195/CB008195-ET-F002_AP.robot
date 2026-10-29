*** Settings ***
Documentation
...    author:  keyun.ma@nokia-sbell.com
...    contact: keyun.ma@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R2    tl-CLOUD_5G_I_BOO_AP_LOO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
#${EMIL_FLAG}    ${False}
#${AUTO_ANALYSIS_FLAG}    ${False}
${SYSCOM_FLAG}    ${True}
#${SNAPSHOT_FLAG}    pass:False,fail:False
#${SOS_REPORT_FLAG}    pass:False,fail:False
#${GNB_BIP_FLAG}    ${False}
#${AP_BIP_FLAG}    ${False}
#${RECREATE_WIRESHARK_FLAG}    ${False}

${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

#SYSLOG output severity prints (0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable)
@{PARAMS_IN_SWCONFIG}    0x1003F=1    0x10040=1    0x10041=1    0x1002A=1    0x4F0214=0    0x590072=1    0x66001b=1
...    0x890001=0    0x890002=0    0x890003=1    0x890004=1    0x890005=0    0x890006=0    0x890008=0
#"0x1003F=1"   # ERadCcs_AaSysLogInputLevel,0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable
#"0x10040=1"   # ERadCcs_AaSysLogOutputLevel
#"0x10041=1"   # OutputMode,0=none 1=all 2=udp 3=sic 4=standard output 5=local 6=remote 7=not valid
#"0x1002A=1"   # EMIL, AaTrace used flag:0=not used, 1=used, 2=used only (ignore configuration messages)
#"0x4F0214=0"  # ignore HWF file information in gNB
#"0x590072=1"  # CP_RT
#"0x66001b=1"  # CP_NRT
#"0x890001=0"  # CP_NB log level
#"0x890002=0"  # CP_SB log level
#"0x890003=1"  # CP_UE log level
#"0x890004=1"  # CP_CL log level
#"0x890005=0"  # CP_IF log level
#"0x890006=0"  # CP_SCTP log level
#"0x890008=0"  # CP_E2 log level


${pdu_id}    1
${gw_id}    1

@{Result_F002_60}
...    rrcReconfigurationComplete
...    pcid:60, scellIdx:1
...    SCellIndex 1 activated successfully

@{Result_F002_50}
...    rrcReconfigurationComplete
...    pcid:50, scellIdx:2
...    SCellIndex 2 activated successfully

@{Expect_Failed}
...    rrcReconfigurationComplete

*** Test Cases ***
CB008195-F-ET_002_Verify succesful intra-gNB SCell Addition in case static cell limits check resources are assigned within common pool
    [Documentation]
    ...    using FDD (CELL-11 & CELL-12), TDD (CELL-1), CELL-12 is pcell, cell-11 / cell-1 can be scell of cell-12
    ...    Step1:	SA UE81 with SNSSAI-2 attach to cell-12 and SA UE82 with SNSSAI-2
    ...             and attach to cell-11 and SA UE83 with SNSSAI-1 in cell-1, then start traffic
    ...    		result:  Ue-81,ue-82, ue-83 attach successfully
    ...    Step2:	For UE-81, Trigger FDD DL Scell Addition Via A1 report but less than a1ThresholdSCellAddSsbRsrpTDD
    ...    		result: CELL-11 cannot be scell of ue-1 since exceed maxQuota of RG-2
    ...    Step3:	release UE-82 and  repeat step2 again
    ...			result：CELL-11 become the scell of ue-1
    ...    Step4:	Trigger scell release
    ...  		result: scell released
    ...    Step5:	repeat step2 again
    ...    		result:	CELL-11 become the scell of ue-1
    ...	   Step6:	Scell Change to be TDD Via A1 report larger than a1ThresholdSCellAddSsbRsrpTDD
    ...			result: SCELL changed from CELL-11 to TDD CELL-1.stable DL throughput for UE(No BLER, DTX, NACK, CRC KO)
    ...	   Step7: check the counters

    [Tags]    owner-keyun.ma    owner-yin.zhang
    log to console    ==== test case: CB008195-F-ET_002 ====
    clear counter files    wait=False
    Step1 3UE attach successfully
    Step2 UE-81 add CELL-11 as scell failed
    Step3 release UE-82 then UE-81 add CELL-11 as scell successfully
    Step4 release scell of UE-81 successfully
    Step5 UE-81 add CELL-11 as scell successfully
    Step6 UE-81 change from CELL-11 to CELL-1 as scell successfully
    Step7 check counters successfully
    release ues    ue_type=all

    log to console    ==== test case: CB008195-SR-J-J015 ====
    log to console    step1: online change NRBTS.NRRESOURCEGROUP_PROFILE.bypassRgLimits to bypass UE context resources check
    Delta Commission Parameters And Wait Cells Onair    ${DELTA_BYPASS_UE_CONTEXT_RES_CHECK}
    clear counter files

    log to console    step2: attach SA UE81 to cell12 (RG2), UE82 to cell11 (RG2), UE83 to cell1(RG1), and start traffic
    UE Attach To Target Cell    ue_id=81    nwslice=2    cell_id=12
    UE Attach To Target Cell    ue_id=82    nwslice=2    cell_id=11
    UE Attach To Target Cell    ue_id=83    nwslice=1    cell_id=1

    log to console   step3: for UE81,trigger FDD DL Scell Addition Via A1 report but less than a1ThresholdSCellAddSsbRsrpTDD
    Trigger ScellAdd or ScellChange    ${Result_F002_60}    ue_id=81    srsrp_nr=80    scell_id=1

    log to console    step4: FDD Scell Change to be TDD Via A1 report larger than a1ThresholdSCellAddSsbRsrpTDD
    Trigger ScellAdd or ScellChange    ${Result_F002_50}    ue_id=81    srsrp_nr=91    scell_id=2

    log to console    step5: check counters
    Check Counters    ${PM_Counters_Check_ET_J015}
    release ues    ue_type=all

    log to console    ==== test case: CB008195-SR-J-J020 ====
    log to console    step1: online change NRBTS.NRRESOURCEGROUP_PROFILE.bypassRgLimits to enable UE context resources check
    Delta Commission Parameters And Wait Cells Onair    ${DELTA_ENABLE_UE_CONTEXT_RES_CHECK}
    clear counter files

    log to console    step2: attach SA UE81 to cell12 (RG2), UE82 to cell11 (RG2), UE83 to cell1(RG1), and start traffic
    UE Attach To Target Cell    ue_id=81    nwslice=2    cell_id=12
    UE Attach To Target Cell    ue_id=82    nwslice=2    cell_id=11
    UE Attach To Target Cell    ue_id=83    nwslice=1    cell_id=1

    log to console   step3: for UE81,trigger FDD DL Scell Addition Via A1 report, should fail since exceed maxQuota of cell12 RG-2
    Trigger ScellAdd or ScellChange and expect failed    ${Expect_Failed}    ue_id=81    srsrp_nr=80

    log to console    step4: check counters
    Check Counters    ${PM_Counters_Check_ET_J020}

*** Keywords ***
Step1 3UE attach successfully
    UE Attach To Target Cell    ue_id=81    nwslice=2    cell_id=12
    UE Attach To Target Cell    ue_id=82    nwslice=2    cell_id=11
    UE Attach To Target Cell    ue_id=83    nwslice=1    cell_id=1

Step2 UE-81 add CELL-11 as scell failed
    Trigger ScellAdd or ScellChange and expect failed    ${Expect_Failed}    ue_id=81
    ...    srsrp_nr=80

Step3 release UE-82 then UE-81 add CELL-11 as scell successfully
    Release Ues    ue_id=82
    Trigger ScellAdd or ScellChange    ${Result_F002_60}    ue_id=81    srsrp_nr=80    scell_id=1

Step4 release scell of UE-81 successfully
    trigger A2 Scell Release    event_type=A2    carrierfreq=424090    srsrp_nr=7    srsrq_nr=7    ue_id=81    scell_id=1

Step5 UE-81 add CELL-11 as scell successfully
    Trigger ScellAdd or ScellChange    ${Result_F002_60}    ue_id=81    srsrp_nr=80    scell_id=1

Step6 UE-81 change from CELL-11 to CELL-1 as scell successfully
    Trigger ScellAdd or ScellChange    ${Result_F002_50}    ue_id=81    srsrp_nr=91    scell_id=2

Step7 check counters successfully
    Check Counters    pm_counters_expression=${PM_Counters_Check_ET_F02}

Modify Cfg
    ${gnb3_cell1}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01
    ...    tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=524310:524310 gscn=6549 mandatory_for_activation=off
   Update Cfg    ${gnb3_cell1}
   Update Cfg    set_amf_region id=1 tac_list=0,200,300 plmn=311:489,311:500
   Update Cfg    set_nwslice id=1 snssai=0x01:13714341 default=on ue=all amf_region_id=1 plmn_list=311:489,311:500
   Update Cfg    set_nwslice id=2 snssai=0x01:13714342 ue=all amf_region_id=1 plmn_list=311:489,311:500
   Update Cfg    set_nwslice id=3 snssai=0x01:13714343 ue=all amf_region_id=1 plmn_list=311:489,311:500

Set UE Parameters Before Register
    [Arguments]    ${send_xn_setup}=true    ${ho_type}=xn_based
    Execute Egate Command    ue_history_information_list id=1 action=reset
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=1 action=commit
    Execute Egate Command    ue_enb_param id=81 ue_history_list=1
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=${send_xn_setup} sa_ho=${ho_type}
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    #build XN setup
    Execute Egate Command    ue_gnb_param id=81 candidate_cells_hex_for_interrat_ho=0B1FFAB95F571630684325A3C7

UE Attach To Target Cell
    [Arguments]    ${cell_id}=1    ${ue_id}=81    ${pcell_dl}=0    ${nwslice}=3
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    @{pdu_success}    create list    QoS Routing Table    drx-Config setup
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    pass_regexp=${pdu_success}
    Send Throuput    ue_id=${ue_id}
    Verify Throuput on Pcell    pcell_dl=${pcell_dl}

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=50    ${ul}=0
    sleep    10s    #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pcell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=10    ${scell_dl}=10    ${ul}=0    ${scell_id}=1
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger ScellAdd or ScellChange
    [Arguments]    ${Result}    ${event_type}=A1    ${carrierfreq}=126750    ${srsrp_nr}=80    ${srsrq_nr}=50    ${ue_id}=81
    ...    ${pcell_dl}=0    ${scell_dl}=0    ${scell_id}=2
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${Result}
    Verify Throuput on Pcell and Scell    pcell_dl=${pcell_dl}    scell_dl=${scell_dl}    scell_id=${scell_id}

Trigger ScellAdd or ScellChange and expect failed
    [Arguments]    ${expect_failed}    ${event_type}=A1    ${carrierfreq}=126750    ${srsrp_nr}=80    ${srsrq_nr}=50    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    fail_regexp=${expect_failed}

trigger A2 Scell Release
    [Arguments]    ${event_type}=A2    ${carrierfreq}=633216    ${srsrp_nr}=7    ${srsrq_nr}=7    ${ue_id}=81    ${scell_id}=2
    ...    ${pcell_dl}=50
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} scell=${scell_id}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Verify Throuput on Pcell    pcell_dl=${pcell_dl}
