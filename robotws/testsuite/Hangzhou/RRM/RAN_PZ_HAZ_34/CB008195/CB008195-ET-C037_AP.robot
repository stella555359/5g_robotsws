*** Settings ***
Documentation
...    author:  damon.lei@nokia-sbell.com
...    contact: damon.lei@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/4cells_2T2F
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R2    tl-CLOUD_5G_I_LO_AP_LO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${EMIL_FLAG}    ${False}
${AUTO_ANALYSIS_FLAG}    ${False}
${SYSCOM_FLAG}    ${True}
${SNAPSHOT_FLAG}    pass:False,fail:False
${SOS_REPORT_FLAG}    pass:False,fail:False
${GNB_BIP_FLAG}    ${False}
${AP_BIP_FLAG}    ${False}
${RECREATE_WIRESHARK_FLAG}    ${False}

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

@{FAULTS_EXCLUDED_CHECKING}    7516

*** Test Cases ***
CB008195-ET-C037_Verify_Unsuc_HO_Since_NSA_NONGBR_DRB_RAC_check_Fail_Due_to_Max_Quota_for_RG_not_reached_but_no_resouce_in_dedicated_and_common_pool
    [Documentation]
    ...         step1&2:ue-11 attach to cell-1 with 2 drb with PLMN-1
	...         step3: ue-12 attach to cell-3 with 1drb with PLMN-2
	...         step4: ue-12 do HO to cell-1 and HO back to cell-3
	...               (ok for HO to cell-1,since 1 + nGbrLimitCellGroupNsaCurrentUnavailableCapacity <= nGbrLimitCellGroupNsa)
	...         step5: ue-12 add 1 more drb, now has 2 drb with PLMN-2
	...         step6: ue-12 HO to cell-1, shall be failed; only 1 drb after recover
	...         step7: ue-12 do HO to cell-1, shall be ok
	...         step8&9: ue-13 attach to cell-3 with 1 drb with PLMN-2 ok, but HO failed to cell-1
    ...         step10 to end: add 8195-J08 check points
    [Tags]    QC_XXXXX
    Delta Commission Parameters    ${DELTA_PARAS_NonBypass}
    Clear Counter files
    setup X2 link to gNBs
    ${scalingfactor}  get_scf_parameter_value  NRCELL-1:rgRacMinQuotaLimitationInfo
    should be equal    ${scalingfactor}    [Scaling factor] = 0.833; [Multicell group type]: L2POOL;[Resource type]: UeContxt;
    NSA UE attach    ue_id=11    selected_plmn=311:489    target_cells=1
	NSA add drb    ue_id=11
    NSA UE attach    ue_id=12    selected_plmn=311:406    target_cells=3
	UE-12 HO from CELL-3 to CELL-1 and then back to CELL-3
	NSA add drb    ue_id=12
    UE-12 HO from CELL-3 to CELL-1 failed and do the recover
	UE-12 HO from CELL-3 to cell-1 ok
    NSA UE attach    ue_id=13    selected_plmn=311:406    target_cells=3
	UE-13 HO from CELL-3 to cell-1 fail
	Check Counters    ${PM_Counters_Check_ET_C037}
    Release UEs    ue_type=all
	Delta Commission Parameters    ${DELTA_PARAS_Bypass}
    Clear Counter files
	Run Keyword And Expect Error    STARTS: No element matching    get_scf_parameter_value    NRCELL-1:rgRacMinQuotaLimitationInfo
    NSA UE attach    ue_id=11    selected_plmn=311:489    target_cells=1
	NSA add drb    ue_id=11
    NSA UE attach    ue_id=12    selected_plmn=311:406    target_cells=3
	UE-12 HO from CELL-3 to CELL-1 and then back to CELL-3
	NSA add drb    ue_id=12
    UE-12 HO from CELL-3 to CELL-1 failed and do the recover
	UE-12 HO from CELL-3 to cell-1 ok
    NSA UE attach    ue_id=13    selected_plmn=311:406    target_cells=3
	UE-13 HO from CELL-3 to cell-1 fail
	Check Counters    ${PM_Counters_Check_J08}

*** Keywords ***
NSA add drb
    [Arguments]    ${ue_id}=11
	Execute Egate Command    bearer_add ue=${ue_id} id=4 filter=0 precedence=4
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_add=4 by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    ...    pass_regexp=success-SgNBReconfComp

UE-12 HO from CELL-3 to cell-1 ok
    ${A3_measid}    get nr meas id for specific type and frequency    ue_id=12    carrierfreq=127210    event_type=A3
	${cmd_1}   catenate   ue_measurement_send_nr id=12 meas_id=${A3_measid} event=A3 srsrp_nr=19 srsrq_nr=19 phycell_id=60 nrsrp_nr=31 nrsrq_nr=31
    Execute Egate Command   ${cmd_1}    UE12: Proxy \\(eNB 2 cell 1\\) reported successful RA

UE-12 HO from CELL-3 to CELL-1 and then back to CELL-3
    ${A3_measid}    get nr meas id for specific type and frequency    ue_id=12    carrierfreq=127210    event_type=A3
    ${cmd_1}   catenate   ue_measurement_send_nr id=12 meas_id=${A3_measid} event=A3 srsrp_nr=19 srsrq_nr=19 phycell_id=60 nrsrp_nr=31 nrsrq_nr=31
    Execute Egate Command   ${cmd_1}    UE12: Proxy \\(eNB 2 cell 1\\) reported successful RA
	sleep    1s
    ${A3_measid2}    get nr meas id for specific type and frequency    ue_id=12    carrierfreq=127210    event_type=A3
	${cmd_2}   catenate  ue_measurement_send_nr id=12 meas_id=${A3_measid2} event=A3 srsrp_nr=19 srsrq_nr=19 phycell_id=61 nrsrp_nr=31 nrsrq_nr=31
    Execute Egate Command	${cmd_2}    UE12: Proxy \\(eNB 2 cell 3\\) reported successful RA

UE-12 HO from CELL-3 to CELL-1 failed and do the recover
    ${A3_measid}    get nr meas id for specific type and frequency    ue_id=12    carrierfreq=127210    event_type=A3
	${cmd_1}   catenate   ue_measurement_send_nr id=12 meas_id=${A3_measid} event=A3 srsrp_nr=19 srsrq_nr=19 phycell_id=60 nrsrp_nr=31 nrsrq_nr=31
    Execute Egate Command	${cmd_1}   Bearer-type change from SCG-split to MCG is successful
    Execute Egate Command    ue_dc_enb_start ue=12 target_gnb=2 target_cells=3 bearer=2 type=split_scg
    ...    UE12: Proxy \\(eNB 2 cell 3\\) reported successful RA

UE-13 HO from CELL-3 to cell-1 fail
    ${A3_measid}    get nr meas id for specific type and frequency    ue_id=13    carrierfreq=127210    event_type=A3
	${cmd_1}   catenate   ue_measurement_send_nr id=13 meas_id=${A3_measid} event=A3 srsrp_nr=19 srsrq_nr=19 phycell_id=60 nrsrp_nr=31 nrsrq_nr=31
    Execute Egate Command    ${cmd_1}    Bearer-type change from SCG-split to MCG is successful
Modify Cfg
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=9
    ${set_ue11}    catenate    set_ue simulated id=11 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645400
    ${set_ue12}    catenate    set_ue simulated id=12 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645401
    ${set_ue13}    catenate    set_ue simulated id=13 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645402
    ${set_ue14}    catenate    set_ue simulated id=14 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:406:21645403
    ${set_ue15}    catenate    set_ue simulated id=15 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:406:21645404
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    set_bearer id=3 ue=11 qci=8 pdn=1
    Update Cfg    set_bearer id=4 ue=11 qci=7 pdn=1
    Update Cfg    set_bearer id=5 ue=11 qci=6 pdn=1
    Update Cfg    set_bearer id=6 ue=11 qci=5 pdn=1
    Update Cfg    set_bearer id=3 ue=12 qci=8 pdn=1
    Update Cfg    set_bearer id=4 ue=12 qci=7 pdn=1
    Update Cfg    set_bearer id=5 ue=12 qci=6 pdn=1
    Update Cfg    set_bearer id=6 ue=12 qci=5 pdn=1
    Update Cfg    set_bearer id=3 ue=14 qci=8 pdn=1
    Update Cfg    set_bearer id=4 ue=14 qci=7 pdn=1
    Update Cfg    set_bearer id=5 ue=14 qci=6 pdn=1
    Update Cfg    set_bearer id=6 ue=14 qci=5 pdn=1
    Update Cfg    set_bearer id=3 ue=15 qci=8 pdn=1
    Update Cfg    set_bearer id=4 ue=15 qci=7 pdn=1
    Update Cfg    set_bearer id=5 ue=15 qci=6 pdn=1
    Update Cfg    set_bearer id=6 ue=15 qci=5 pdn=1
    Update Cfg    ${set_ue11}
    Update Cfg    ${set_ue12}
    Update Cfg    ${set_ue13}
    Update Cfg    ${set_ue14}
    Update Cfg    ${set_ue15}

NSA UE attach
    [Arguments]  ${ue_id}=11    ${selected_plmn}=311:489    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    enb_endc_param id=1 selected_plmn=${selected_plmn}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    UE${ue_id}: Proxy \\(eNB 2 cell ${target_cells}\\) reported successful RA
NSA UE attach failed
    [Arguments]  ${ue_id}=11    ${selected_plmn}=311:489    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    enb_endc_param id=1 selected_plmn=${selected_plmn}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    no-radio-resources-available

setup X2 link to gNBs
    Execute Egate Command    enb_x2_link_up enb=1 target=2    is up
