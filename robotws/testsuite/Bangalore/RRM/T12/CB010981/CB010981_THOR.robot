*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO
...           RAN_5G_TDD_FDD   RAN_5G     CONFIGURED

Documentation       :copyright:   Nokia
...                 :author   :   Arun Velusamy
...                 :contact  :   arun.velusamy@nokia.com
...                 :Feature  :   CB010981-B ->  The purpose of the Test case is to validate presence of
...                  non-DTX ACSI-2 Reports when ACSI-1 DTX Reports are observed in BIP Logs

Resource          resources/Keywords/CB010981_Keywords_THOR.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${DL_RT}                10
${UL_RT}                100
${pl_ini}				140
${pl_min}				145
${pl_max}				165
${pl_step}				5
@{PhyCellid}		52	53
@{UE_list}          51	52	53	54	55	71	72	73	74	75


*** Test Cases ***
[1][1.0] CB010981_Feature_CSI1_DTX_CSI2_nonDTX_verification
	[Tags]		QC_275753   QCD_MN_RAN    QCP_RAN_VRF
	[Documentation]		To validate CB010981-B Feature on THOR platform
	[Setup]    Prepare For CB010981
	slog.Start Syslog  ${Log_Path}     SysLogCap.LOG
	FOR     ${ueid}     IN    @{UE_list}
		${wts_output}		UE Register Should Be Successful For SA    ${ueid}
		Print Matching Lines From Output File	${wts_output}      ${ACSI_pattern}
		Log    Starting Downlink and Uplink Traffic for UE ${ueid}
		DL Traffic Should Be Successful    ${DL_RT}    ${ueid}
		UL Traffic Should Be Successful    ${UL_RT}    ${ueid}
		Log To Console      Starting Dl and Ul Traffic for UE ${ueid}
		UL SINR Testmode NR     profile_id=${ueid}    pathloss=${pl_ini}    pcmax=30
		Sleep   2s
		UE Testmode Set NR      id=${ueid}     testmode=ul_sinr     action=activate    profile_id=${ueid}
		Sleep   5s
		FOR    ${pl}    IN RANGE    ${pl_min}    ${pl_max}	${pl_step}
			UL SINR Testmode NR     profile_id=${ueid}    pathloss=${pl}    pcmax=30
			Sleep   5s
		END
		wtsrunner.ue_stats_nr	id=${ueid}	type=pdsch,pusch
		Sleep   5s
	END
	UE Disp
	FOR    ${cellid}	IN	@{PhyCellid}
		Start Interface Mirroring With NR Phy Cellids	name=l1l2bip_${cellid}	PhyCell=${cellid}
		Sleep   60s
		Stop Interface Mirroring With NR Phy Cellids	name=l1l2bip_${cellid}
		Verify CB010981 Activation and ACSI Reports		${cellid}	FAF=True
	END
	Perform GNB Delta Commission	FAF=False
	FOR    ${cellid}	IN	@{PhyCellid}
		Start Interface Mirroring With NR Phy Cellids	name=l1l2bip_${cellid}	PhyCell=${cellid}
		Sleep   60s
		Stop Interface Mirroring With NR Phy Cellids	name=l1l2bip_${cellid}
		Verify CB010981 Activation and ACSI Reports		${cellid}	FAF=False
	END
	Perform GNB Delta Commission		FAF=True
	FOR    ${cellid}	IN	@{PhyCellid}
		Start Interface Mirroring With NR Phy Cellids	name=l1l2bip_${cellid}	PhyCell=${cellid}
		Sleep   60s
		Stop Interface Mirroring With NR Phy Cellids	name=l1l2bip_${cellid}
		Verify CB010981 Activation and ACSI Reports		${cellid}	FAF=True
	END
	FOR		${ueid}		IN		@{UE_list}
		UE Testmode Set NR	id=${ueid}	testmode=ul_sinr	action=deactivate	profile_id=${ueid}
		Sleep   5s
	END
	FOR		${ueid}		IN		@{UE_list}
		UE Deregister Should Be Successful For SA	${ueid}
		Log   De-Registered UE ${ueid}
	END
	[Teardown]		Run Keyword And Ignore Error		Common Tear Down
