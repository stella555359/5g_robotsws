*** Settings ***
Force Tags    CLOUD_5G_I_LOO_AP_LOOO
...           RAN_5G_TDD_FDD   RAN_5G     CONFIGURED

Documentation       :copyright:   Nokia
...                 :author   :   Arun Velusamy
...                 :contact  :   arun.velusamy@nokia.com
...                 :Feature  :   CB010981-B ->  The purpose of the Test case is to validate activation and
...                  de-activation of CB010981-B Sub Feature and verify its functionality in LOKI Platform

Resource          resources/Keywords/CB010981_Keywords_LOKI.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${DL_RT}			10
${UL_RT}			150
${UL_RT_VoNR}		23
${pl_ini}			140
${pl_min}			145
${pl_max}			165
${pl_step}			5
${value}			1
@{PhyCellid}		51	57
@{NRCELL_ID}		1	7
@{UEs_list_TDD}		1	2	3
@{UEs_list_FDD}		51	52	53
@{AllUE_list}		1	2	3	21	22	23	31	32	33	41	42	43	51	52	53
...					71	72	73	81	82	83	91	92	93


*** Test Cases ***
[1]CB010981_Feature_validation_LOKI
	[Tags]    QC_278938   QCD_MN_RAN    QCP_RAN_VRF
	[Documentation]    To validate CB010981-B Feature in LOKI Platform
	[Setup]    Prepare For CB010981
	slog.Start Syslog  ${Log_Path}     SysLogCap.LOG
	FOR     ${ueid}     IN    @{AllUE_list}
		${wts_output}		UE Register Should Be Successful For SA    ${ueid}
		${output}	Print Matching Lines From Output File	${wts_output}      ${ACSI_pattern}
		Should Not Be Empty		${output}
		Log    Starting Downlink and Uplink Traffic for UE ${ueid}
		DL Traffic Should Be Successful    ${DL_RT}    ${ueid}
		UL Traffic Should Be Successful    ${UL_RT}    ${ueid}
		Log To Console      Starting Dl and Ul Traffic for UE ${ueid}
		Modify PDU Session For UE To add	${ueid}		${PDU_ID1}		${QFI_5}
		DL Traffic Should Be Successful    ${DL_RT}    ${ueid}		${QFI_2}
		UL Traffic Should Be Successful    ${UL_RT}    ${ueid}		${QFI_2}
		Modify PDU Session For UE To add	${ueid}		${PDU_ID1}		${QFI_6}
		DL Traffic Should Be Successful    ${DL_RT}    ${ueid}		${QFI_3}	${kbps}
		UL Traffic Should Be Successful    ${UL_RT_VoNR}    ${ueid}		${QFI_3}	${kbps}
	END
	Wait For Next Full Pm Interval
	Start Interface Mirroring With NR Phy Cellids	name=l1l2bip_${PhyCellid}[0]	PhyCell=${PhyCellid}[0]
	...		MirrFilt=SpecificL1L2Messages	MsgId=0xE24B
	FOR		${ueid}		IN		@{UEs_list_TDD}
		UL SINR Testmode NR     profile_id=${ueid}    pathloss=${pl_ini}    pcmax=30
		Sleep   5s
		UE Testmode Set NR      id=${ueid}     testmode=ul_sinr     action=activate    profile_id=${ueid}
		Sleep   10s
		FOR    ${pl}    IN RANGE    ${pl_min}    ${pl_max}	${pl_step}
			UL SINR Testmode NR     profile_id=${ueid}    pathloss=${pl}    pcmax=30
			Sleep   5s
		END
	END
	Stop Interface Mirroring With NR Phy Cellids	name=l1l2bip_${PhyCellid}[0]
	Verify CB010981 ACSI Reports for PhyCellid		cell=${PhyCellid}[0]
	Wait For Next Full Pm Interval
	${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
	Set Test Variable       ${pm_counter_file}
	Verify PM Counter Values	${pm_counter_file}	${CNT_TP_ENB}	${NRCELL_ID}[0]
	Verify PM Counter Values in PMQAP	${DFTS_INI_R1_PMQAP}	${NRCELL_ID}[0]		${PMQAP_LIST}	${pm_counter_file}
	UE Disp
	Wait For Next Full Pm Interval
	Start Interface Mirroring With NR Phy Cellids	name=l1l2bip_${PhyCellid}[1]	PhyCell=${PhyCellid}[1]
	...		MirrFilt=SpecificL1L2Messages	MsgId=0xE24B
	FOR		${ueid}		IN		@{UEs_list_FDD}
		UL SINR Testmode NR     profile_id=${ueid}    pathloss=${pl_ini}    pcmax=30
		Sleep   5s
		UE Testmode Set NR      id=${ueid}     testmode=ul_sinr     action=activate    profile_id=${ueid}
		Sleep   10s
		FOR    ${pl}    IN RANGE    ${pl_min}    ${pl_max}	${pl_step}
			UL SINR Testmode NR     profile_id=${ueid}    pathloss=${pl}    pcmax=30
			Sleep   5s
		END
	END
	Stop Interface Mirroring With NR Phy Cellids	name=l1l2bip_${PhyCellid}[1]
	Verify CB010981 ACSI Reports for PhyCellid		cell=${PhyCellid}[1]
	Wait For Next Full Pm Interval
	${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
	Verify PM Counter Values	${pm_counter_file}	${CNT_TP_ENB}	${NRCELL_ID}[1]
	Verify PM Counter Values in PMQAP	${DFTS_INI_R1_PMQAP}	${NRCELL_ID}[1]		${PMQAP_LIST}	${pm_counter_file}
	UE Disp
	Wait For Next Full Pm Interval
	FOR		${ueid}		IN		@{UEs_list_TDD}
		UE Testmode Set NR	id=${ueid}	testmode=ul_sinr	action=deactivate	profile_id=${ueid}
		Sleep   10s
	END
	Wait For Next Full Pm Interval
	${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
	Verify PM Counter Values	${pm_counter_file}	${CNT_TP_DISB}	${NRCELL_ID}[0]
	Wait For Next Full Pm Interval
	FOR		${ueid}		IN		@{UEs_list_FDD}
		UE Testmode Set NR	id=${ueid}	testmode=ul_sinr	action=deactivate	profile_id=${ueid}
		Sleep   10s
	END
	Wait For Next Full Pm Interval
	${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
	Verify PM Counter Values	${pm_counter_file}	${CNT_TP_DISB}	${NRCELL_ID}[1]
	UE Disp
	FOR		${ueid}		IN		@{AllUE_list}
		UE Deregister Should Be Successful For SA	${ueid}
		Log		De-Registered UE ${ueid}
	END
	[Teardown]	Run Keyword And Ignore Error	Common Tear Down
