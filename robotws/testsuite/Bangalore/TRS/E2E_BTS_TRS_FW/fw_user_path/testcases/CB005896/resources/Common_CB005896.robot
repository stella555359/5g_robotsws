*** Settings ***
Documentation
...		[Author]     	"Boban"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"


variables	ta_e2e_bts_trs_fw
Resource    ${CURDIR}/../../resources/Common_IPSEC_Operations.robot
Resource    ${CURDIR}/../../resources/Admin_Common_Library.robot
Resource    ${CURDIR}/../../resources/common_emssim.robot
Resource    ${CURDIR}/../../resources/common_keywords.robot


*** Keywords ***

Enable Traffic Guard using EMSSIM
    Run Ems Command      config_device=emssim1  command=plan_create
    Sleep   10
    Run Ems Command      config_device=emssim1  command=plan_add CAPLIM-1-1-1
    Sleep   10
    Run Ems Command      config_device=emssim1  command=plan_edit CAPLIM-1 ipTrafficCapacityLimitEnabled 1
    Sleep   10
    Run Ems Command      config_device=emssim1  command=plan_show
    Sleep   10
    Run Ems Command      config_device=emssim1  command=plan_send
    Sleep   30

Disabling Traffic Guard using EMSSIM
    Run Ems Command      config_device=emssim1  command=plan_create
    Sleep   10
    Run Ems Command      config_device=emssim1  command=plan_delete CAPLIM-1-1-1
    Sleep   10
    Run Ems Command      config_device=emssim1  command=plan_show
    Sleep   10
    Run Ems Command      config_device=emssim1  command=plan_send
    Sleep   30


Change iptrafficlim
	Setup Remote Access	remote_device=bts
	Remote Command Execute	command=/opt/trs/bin/trs-iptrafficlim-d execute SetRndParams 5 180 3600
	BuiltIn.Sleep	10
    Run Keyword if      '${productName}'=='${productName_ASOE}'     Remote Command Execute      command=${command_ASOE_CounterSampleSeq_1}
    ...		ELSE IF     '${productName}'=='${productName_ASIK}'     Remote Command Execute      command=${command_ASIK_CounterSampleSeq_1}
    ...		ELSE IF     '${productName}'=='${productName_ASOH}'     Remote Command Execute      command=${command_ASOH_CounterSampleSeq_1}
    ...		ELSE IF     '${productName}'=='${productName_ASIM}'     Remote Command Execute      command=${command_ASIM_CounterSampleSeq_1}
    ...		ELSE IF     '${productName}'=='${productName_ASIL}'     Run Keywords        Remote Command Execute
    ...     command=${command_ASIL_CounterSampleSeq_1}
    ...     AND         Remote Command Execute      command=${command_ASIL_CounterSampleSeq_2}
    ...		ELSE IF     '${productName}'=='${productName_ASIA}' or '${productName}'=='${productName_ASIB}'     Run Keywords
    ...     Remote Command Execute      command=${command_CounterSampleSeq_15}
    ...     AND    Remote Command Execute      command=${command_CounterSampleSeq_16}
    ...     AND    Remote Command Execute      command=${command_CounterSampleSeq_17}
    ...     AND    Remote Command Execute      command=${command_CounterSampleSeq_18}
    ...     AND    Remote Command Execute      command=${command_CounterSampleSeq_19}
    ...		ELSE IF     '${productName}'=='${productName_FSMR3}'     Remote Command Execute      command=${command_FSMR3_CounterSampleSeq_1}
    ...		ELSE      Log    ${runtime_system_module_info_dict}
	[Teardown]	Teardown Remote Access


Change iptrafficlim eda
	Setup Remote Access	remote_device=bts
	Remote Command Execute	command=/opt/trs/bin/trs-iptrafficlim-d execute SetRndParams 5 3600 10
	BuiltIn.Sleep	10
    Run Keyword if      '${productName}'=='${productName_ASOE}'     Remote Command Execute      command=${command_ASOE_CounterSampleSeq_1}
    ...		ELSE IF     '${productName}'=='${productName_ASIK}'     Remote Command Execute      command=${command_ASIK_CounterSampleSeq_1}
    ...		ELSE IF     '${productName}'=='${productName_ASOH}'     Remote Command Execute      command=${command_ASOH_CounterSampleSeq_1}
    ...		ELSE IF     '${productName}'=='${productName_ASIM}'     Remote Command Execute      command=${command_ASIM_CounterSampleSeq_1}
    ...		ELSE IF     '${productName}'=='${productName_ASIL}'     Run Keywords        Remote Command Execute
    ...     command=${command_ASIL_CounterSampleSeq_1}
    ...     AND         Remote Command Execute      command=${command_ASIL_CounterSampleSeq_2}
    ...		ELSE IF     '${productName}'=='${productName_ASIA}' or '${productName}'=='${productName_ASIB}'     Run Keywords
    ...     Remote Command Execute      command=${command_CounterSampleSeq_15}
    ...     AND    Remote Command Execute      command=${command_CounterSampleSeq_16}
    ...     AND    Remote Command Execute      command=${command_CounterSampleSeq_17}
    ...     AND    Remote Command Execute      command=${command_CounterSampleSeq_18}
    ...     AND    Remote Command Execute      command=${command_CounterSampleSeq_19}
    ...		ELSE IF     '${productName}'=='${productName_FSMR3}'     Remote Command Execute      command=${command_FSMR3_CounterSampleSeq_1}
    ...		ELSE      Log    ${runtime_system_module_info_dict}
	[Teardown]	Teardown Remote Access


Change iptrafficlim_upd
	Setup Remote Access	remote_device=bts
	Remote Command Execute	command=/opt/trs/bin/trs-iptrafficlim-d execute SetRndParams 5 180 180
	BuiltIn.Sleep	10
    Run Keyword if      '${productName}'=='${productName_ASOE}'     Remote Command Execute      command=${command_ASOE_CounterSampleSeq_1}
    ...		ELSE IF     '${productName}'=='${productName_ASIK}'     Remote Command Execute      command=${command_ASIK_CounterSampleSeq_1}
    ...		ELSE IF     '${productName}'=='${productName_ASOH}'     Remote Command Execute      command=${command_ASOH_CounterSampleSeq_1}
    ...		ELSE IF     '${productName}'=='${productName_ASIM}'     Remote Command Execute      command=${command_ASIM_CounterSampleSeq_1}
    ...		ELSE IF     '${productName}'=='${productName_ASIL}'     Run Keywords        Remote Command Execute
    ...     command=${command_ASIL_CounterSampleSeq_1}
    ...     AND         Remote Command Execute      command=${command_ASIL_CounterSampleSeq_2}
    ...		ELSE IF     '${productName}'=='${productName_ASIA}' or '${productName}'=='${productName_ASIB}'     Run Keywords
    ...     Remote Command Execute      command=${command_CounterSampleSeq_15}
    ...     AND    Remote Command Execute      command=${command_CounterSampleSeq_16}
    ...     AND    Remote Command Execute      command=${command_CounterSampleSeq_17}
    ...     AND    Remote Command Execute      command=${command_CounterSampleSeq_18}
    ...     AND    Remote Command Execute      command=${command_CounterSampleSeq_19}
    ...		ELSE IF     '${productName}'=='${productName_FSMR3}'     Remote Command Execute      command=${command_FSMR3_CounterSampleSeq_1}
    ...		ELSE      Log    ${runtime_system_module_info_dict}
	[Teardown]	Teardown Remote Access


VerifyAlarmSuppBeforeReset
        [Arguments]       ${Alarm_list}
	FOR    ${i}    IN   @{Alarm_list}
           ${fault_id}=     Get From Dictionary     ${i}     faultId
           ${supplAlarmInfoBeforeReset}=     Run Keyword if     '${fault_id}'=='${faultnum}'         Get From Dictionary
    ...     ${i}         supplAlarmInfo
           Exit for loop if        '${fault_id}'=='${faultnum}'
	Set Suite Variable	${supplAlarmInfoBeforeReset}
	END


VerifyAlarmSuppAfterReset
        [Arguments]       ${Alarm_list}
	FOR    ${i}    IN   @{Alarm_list}
           ${fault_id}=     Get From Dictionary     ${i}     faultId
           ${supplAlarmInfoAfterReset}=     Run Keyword if     '${fault_id}'=='${faultnum}'         Get From Dictionary
    ...     ${i}         supplAlarmInfo
           Run Keyword if     '${fault_id}'=='${faultnum}'        Should Contain     '${supplAlarmInfoAfterReset}'
    ...     ${TGsupplAlarmInfoAfterReset}
           Exit for loop if        '${fault_id}'=='${faultnum}'
	Set Suite Variable	${supplAlarmInfoAfterReset}
	END

VerifyAlarmSupp
        [Arguments]       ${Alarm_list}
	FOR    ${i}    IN   @{Alarm_list}
           ${fault_id}=     Get From Dictionary     ${i}     faultId
           ${supplAlarmInfo}=     Run Keyword if     '${fault_id}'=='${faultnum}'         Get From Dictionary     ${i}
    ...     supplAlarmInfo
           Run Keyword if     '${fault_id}'=='${faultnum}'        Should Contain     '${supplAlarmInfo}'          ${TGsupplAlarmInfo}
           Exit for loop if        '${fault_id}'=='${faultnum}'
	END


VerifyAlarmSuppeda
        [Arguments]       ${Alarm_list}
	FOR    ${i}    IN   @{Alarm_list}
           ${fault_id}=     Get From Dictionary     ${i}     faultId
           ${supplAlarmInfo}=     Run Keyword if     '${fault_id}'=='${faultnum}'         Get From Dictionary     ${i}
    ...     supplAlarmInfo
           Run Keyword if     '${fault_id}'=='${faultnum}'        Should Contain     '${supplAlarmInfo}'          ${TGsupplAlarmInfo}
           Exit for loop if        '${fault_id}'=='${faultnum}'
	END


LimitRateVerification
	Should Be Equal As Strings	${supplAlarmInfoBeforeReset}	${supplAlarmInfoAfterReset}


Inactive State Verification
	Setup Remote Access		remote_device=bts
	${stdout}	Remote Command Execute		command=cat /ffs/run/trs_data/active/ipTrafficCapacityBackup
	Should contain		${stdout}		curState_|1
    ${stdout}   Remote Command Execute      command=cat /rom/config/IPTrafficCapa.log
    Should contain      ${stdout}       Traffic Guard state changed to INACTIVE
	[Teardown]	Teardown Remote Access


Software Upgrade
        ${mplane_ipv4}=     Get Parameter   param_path=${mplane_ipv4_ip_moc}
        Execute command on enodeb      ls /ffs/run/ |awk '/TargetBD/' |cut -d'_' -f2 |head -1
        ${enb_status}=      Run Keyword and return status        Should Contain      ${stdout}     SBTS25R3
        Set Suite variable    ${enb_status}
        ${profile}=     Run Keyword IF     '${enb_status}'=='True'          Set variable        sbtstrunk_00        ELSE        Set variable
        ...     SBTS25R2
	setup oamops    bts_host=${mplane_ipv4}    alias=upgrade_mplane
	Perform software download and update     wft_profile=${profile}     package=auto     activate_sw=true    update_timeout=4500
	...     alias=upgrade_mplane	download_path=/home/ute/Downloads/

Start NSA Call1
    Configure UE	5g=5g_basic_ASIK_ASIL:data  command=enb_x2_link_up	enb=1	target=2
    sleep  3
    Configure UE	5g=5g_basic_ASIK_ASIL:data  command=ue_attach	id=101	profile=1
    sleep  3
    Configure UE	5g=5g_basic_ASIK_ASIL:data  command=enb_ue_dc_start	ue=101	target_gnb=2	target_cells=1	bearer=2	type=split_scg
    sleep  3
    Configure UE	5g=5g_basic_ASIK_ASIL:data  command=trf_data_start	ue=101	id=2	dir=dl	trf_id=2	mbps=71


Stop NSA Call1
    Configure UE	5g=5g_basic_ASIK_ASIL:data  command=trf_data_stop	ue=101	id=2	dir=dl	trf_id=2
    sleep  3
    Configure UE	5g=5g_basic_ASIK_ASIL:data  command=ue_detach	id=101



Start NSA Call
    Configure UE	5g=5g_basic_ASIK_ASIL:data  command=enb_x2_link_up	enb=1	target=2
    sleep  3
    Configure UE	5g=5g_basic_ASIK_ASIL:data  command=ue_attach	id=11	profile=1
    sleep  3
    Configure UE	5g=5g_basic_ASIK_ASIL:data  command=enb_ue_dc_start	ue=11	target_gnb=2	target_cells=1	bearer=2	type=split_scg
    sleep  3
    Configure UE	5g=5g_basic_ASIK_ASIL:data  command=trf_data_start	ue=11	id=2	dir=dl	trf_id=2	mbps=71


Stop NSA Call
    Configure UE	5g=5g_basic_ASIK_ASIL:data  command=trf_data_stop	ue=11	id=2	dir=dl	trf_id=2
    sleep  3
    Configure UE	5g=5g_basic_ASIK_ASIL:data  command=ue_detach	id=11


Start SA Call
    Configure UE	5g=5g_basic_ASIK_ASIL:data  command=ue_register	id=1
    sleep  3
    Configure UE	5g=5g_basic_ASIK_ASIL:data  command=set_pdu_param	ue=1	pdu=1	trf_type=internal
    sleep  3
    Configure UE	5g=5g_basic_ASIK_ASIL:data  command=ue_pdu_session_setup	pdu=1	gw=1	ue=1
    sleep  3
    Configure UE	5g=5g_basic_ASIK_ASIL:data  command=trf_data_start	ue=1	pdu=1	qfi=1	dir=dl	mbps=71

Stop SA Call
    Configure UE	5g=5g_basic_ASIK_ASIL:data  command=trf_data_stop	ue=1	pdu=1	qfi=1



Get System Module HW Variant
    ${runtime_system_module_info_dict} =     Query Admin Infomodel    query=get object //CABINET_R-*/SMOD_R-*
    Log    ${runtime_system_module_info_dict}
    ${productName} =      Get From Dictionary    ${runtime_system_module_info_dict}    productName
    Set Suite Variable      ${productName}

Perform Call Setup Based On HW Variant
    Run Keyword if      '${productName}'=='${productName_ASIB}'     Call Setup  5g=5g_basic_ASIK_ASIL:data      parallel=${False}
    ...     verify_attach=${False}    attach=${False}     timeout=300
    ...		ELSE IF     '${productName}'=='${productName_ASIL}'     Call Setup  5g=5g_basic_ASIK_ASIL:data      parallel=${False}
    ...     verify_attach=${False}    attach=${False}     timeout=300
    ...		ELSE IF     '${productName}'=='${productName_ASIK}'     Call Setup  5g=5g_basic_ASIK_ASIL:data      parallel=${False}
    ...     verify_attach=${False}    attach=${False}     timeout=300
    ...		ELSE IF     '${productName}'=='${productName_ASOE}'     Call Setup  5g=5g_basic_ASIK_ASIL:data      parallel=${False}
    ...     verify_attach=${False}    attach=${False}     timeout=300
    ...		ELSE IF     '${productName}'=='${productName_ASOH}'     Call Setup  5g=5g_basic_ASIK_ASIL:data      parallel=${False}
    ...     verify_attach=${False}    attach=${False}     timeout=300
    ...		ELSE IF     '${productName}'=='${productName_ASIM}'     Call Setup  5g=5g_basic_ASIK_ASIL:data      parallel=${False}
    ...     verify_attach=${False}    attach=${False}     timeout=300
    ...		ELSE      Log    ${runtime_system_module_info_dict}

Start Calls Based On HW Variant
    Run Keyword if      '${productName}'=='${productName_ASIL}' or '${productName}'=='${productName_ASOH}'	Start NSA Call1
    ...		ELSE IF     '${productName}'=='${productName_ASIB}' or '${productName}'=='${productName_ASIK}'	Start NSA Call
    ...		ELSE IF		'${productName}'=='${productName_ASOE}'		Start NSA Call
    ...		ELSE IF     '${productName}'=='${productName_ASIM}'		Start SA Call


Stop Calls Based On HW Variant
    Run Keyword if      '${productName}'=='${productName_ASOE}'     Stop NSA Call
    ...     ELSE IF     '${productName}'=='${productName_ASOH}'     Stop NSA Call1
    ...     ELSE IF     '${productName}'=='${productName_ASIB}'     Stop NSA Call
    ...     ELSE IF     '${productName}'=='${productName_ASIL}'     Stop NSA Call1
    ...		ELSE IF     '${productName}'=='${productName_ASIK}'		Stop NSA Call
    ...		ELSE IF     '${productName}'=='${productName_ASIM}'		Stop SA Call

Keywords To Run At End
  teardown Emssim
    Run     cd /opt/iphy/latest/ ; sudo killall egate edaemon
