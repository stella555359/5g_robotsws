*** Settings ***
Documentation
...    author:  yuhua.zhu@nokia-sbell.com
...    contact: yuhua.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    tl-CLOUD_5G_I_BOO_AP_LOO    release-25R1 
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

@{Result_F001}
...    rrcReconfigurationComplete
...    pcid:50, scellIdx:1
...    SCellIndex 1 activated successfully

${pdu_id}    1
${gw_id}    1

@{unexpectedUE81ScellAddition}
...    SCellIndex 1 activated successfully at airphone
...    physCellId 52


@{expectedUE81ScellAddition}
...    SCellIndex 2 activated successfully at airphone
...    physCellId 61

@{unexpectedUE82ScellAddition}
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    physCellId 52
...    physCellId 61

${SA_Capa_Support_3CC_Not_Support_4CC_CA}
...    A11FF82384C0C03850001C46000000122205C160601C46000002022205C2606018280388C00000824440B84C0C038500018460001848881005011
...    A0140030506504893A24ED8E7C3853A76C0000449D1276C0000440360000008018800020101002008040300608000402020180308000201010020
...    00040300610000402020040100806000

*** Test Cases ***
CB008195-F-ET_007_Verify unsuccesful intragnb SCell Addition
    [Documentation]
    ...    Verify succesful intra-gNB SCell Addition in case multiple-cell pooled resource limits check resources are assigned within common pool
    ...    Step 1: SA UE81 register and setup pdu session on CELL11 with PLMN-1 and SNSSAI-2. 
    ...    Expected Result: UE is admitted by ResourceGroupId-2 with dedicated RG resource.
    
    ...    Step 2: PRE NSA UE91 attach to CELL3 with PLMN-2 to occupy RG2 common resource.  
    ...    Expected Result: UE is admitted by ResourceGroupId-2 within maxnumofUsersPerNRcell in common RG resource.
    
    ...    Step 3: trigger A1 to add scell for SA UE81.
    ...    Expected Result:
    ...    a. gNB-DU identifies RG-2 for SCells.
    ...    b. gNB-DU checks available resource, and admit only CELL2 as scell in common pool.
    ...    c. gNB-DU sends to gNB-CU F1AP: UEContextModificationResponse including not admitted SCells (CELL3) in SCell-FailedToSetupMod-List
    
    ...    Step 4: SA UE82 register and setup pdu session on CELL11 with PLMN-1 and SNSSAI-2.
    ...    Expected Result: UE is admitted by ResourceGroupId-2 with dedicated RG resource.
    
    ...    Step 5: trigger A1 to add scell for SA UE82.
    ...    Expected Result:
    ...    a. gNB-DU identifies RG-2 for SCells CELL1 and CELL3.
    ...    b. gNB-DU checks available resource, admission control fails at gNB-DU as maximum quota in RG selected for UE are reached and gNB-DU
    ...	   sends to gNB-CU-CP F1AP: UEContextModificationFailure 
    [Tags]    QC_****    F007
	Clear Counter Files
    UE Attach To Target Cell    ue_id=81    nwslice=2    cell_id=11
	NSA Addition successfully    ue_id=91
	UE Send A1 To Trigger Scell Partial Addition     expectedString=@{expectedUE81ScellAddition}
    ...    unexpectedString=@{unexpectedUE81ScellAddition}
	UE Attach To Target Cell    ue_id=82    nwslice=2    cell_id=11
    UE Send A1 To Trigger Scell Partial Addition     ue_id=82    unexpectedString=@{unexpectedUE82ScellAddition}
	Check Counters    ${PM_Counters_F007}

*** Keywords ***  
Modify Cfg
    ${gnb3_cell1}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01
    ...    tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=524310:524310 gscn=6549 mandatory_for_activation=off
    Update Cfg    ${gnb3_cell1}
    Update Cfg    set_amf_region id=1 tac_list=0,200 plmn=311:489,311:406
    Update Cfg    set_nwslice id=1 snssai=0x01:13714341 default=on ue=all amf_region_id=1 plmn_list=311:489,311:406
    Update Cfg    set_nwslice id=2 snssai=0x01:13714342 ue=all amf_region_id=1 plmn_list=311:489,311:406
    Update Cfg    set_nwslice id=3 snssai=0x01:13714343 ue=all amf_region_id=1 plmn_list=311:489,311:406
	${set_ue91}    catenate    set_ue simulated id=91 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
	...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g imsi=311:406:21645491
    Update Cfg    ${set_ue91}

UE Send A1 To Trigger Scell Partial Addition
    [Arguments]    ${expectedString}=${None}    ${unexpectedString}=${None}    ${ue_id}=81    ${cellfreq}=125050
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    #...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=100 srsrq_nr=40
    ...    pass_regexp=${expectedString}    fail_regexp=${unexpectedString}
    Sleep    5s    #wait all sysinfo

UE Attach To Target Cell
    [Arguments]    ${cell_id}=11    ${ue_id}=81    ${pcell_dl}=0    ${nwslice}=3
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table
    Should Contain    ${ret1}    drx-Config setup
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
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${ul}=0
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
    [Arguments]    ${Result}    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=80    ${srsrq_nr}=50    ${ue_id}=81    ${phycell_id}=60
    ...    ${pcell_dl}=0    ${scell_dl}=0    ${scell_id}=2
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${Result}
    Verify Throuput on Pcell and Scell    pcell_dl=${pcell_dl}    scell_dl=${scell_dl}    scell_id=${scell_id}

Trigger ScellAdd or ScellChange and expect failed
    [Arguments]    ${expected_failed_result}    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=80    ${srsrq_nr}=50
    ...    ${ue_id}=81    ${phycell_id}=60    ${pcell_dl}=0    ${scell_dl}=0    ${scell_id}=2
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    fail_regexp=${expected_failed_result}

NSA Addition successfully
    [Arguments]    ${cell_id}=3    ${ue_id}=91
    NSA UE Attach To Target Cell   ${cell_id}    ${ue_id}
    Send And Verify Throuput    ${ue_id}    2    1.8    all

	
Send And Verify Throuput
    [Arguments]    ${UE_ID}    ${BEARER_ID}    ${ul_throuput_expect}    ${dcgroup}
    Execute Egate Command    data_trf_start ue=${UE_ID} id=2 dir=dl mbps=2 trf_id=2    UE ${UE_ID}: UDP DL
    Execute Egate Command    data_trf_start ue=${UE_ID} id=2 dir=ul mbps=2    UE ${UE_ID}: UDP UL
    Verify Throuput    ${UE_ID}    ${BEARER_ID}    ${ul_throuput_expect}    ${dcgroup}

Verify Throuput
    [Arguments]    ${UE_ID}    ${BEARER_ID}    ${ul_throuput_expect}    ${dcgroup}    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${UE_ID}     bearer_id=${BEARER_ID}    direction=ul    dc_cell_group=${dcgroup}
	...    rate_type=ave
    Should Be True    ${ul_throuput}/1000>=${ul_throuput_expect}
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${UE_ID}     bearer_id=${BEARER_ID}    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>1.8


NSA UE Attach To Target Cell
    [Arguments]    ${cell_id}=3    ${ue_id}=91
    Log To Console    attach:${ue_id} to cell:${cell_id}
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
	Execute Egate Command    enb_endc_param selected_plmn=311:406 id=1
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    reported successful RA

setup X2 link to gNBs
    Execute Egate Command    enb_x2_link_up enb=1 target=2    is up
