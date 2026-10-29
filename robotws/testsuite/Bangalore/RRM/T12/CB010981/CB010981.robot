*** Settings ***
Force Tags    CLOUD_5G_I_LOO_AP_LOOO
...           RAN_5G_TDD_FDD   RAN_5G     CONFIGURED

Documentation       :copyright:   Nokia
...                 :author   :   Arun Velusamy
...                 :contact  :   arun.velusamy@nokia.com
...                 :Feature  :   CB010981-B ->  The purpose of the Test case is to validate activation and
...                  de-activation of CB010981-B Sub Feature

Resource          resources/Keywords/CB010981_Keywords.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${DL_RT}                20
${UL_RT}                20
@{PhyCellid}		51	52	53	54	57	58	60	61
@{UE_list}          1	21	31	41	51	71	81	91


*** Test Cases ***
[1][1.0] CB010981_Feature_Activation_and_Deactivation
	[Tags]    QC_263698   QCD_MN_RAN    QCP_RAN_VRF
	[Documentation]    To validate CB010981-B Feature Activation/Deactivation
	[Setup]    Prepare For CB010981
	slog.Start Syslog  ${Log_Path}     SysLogCap.LOG
	FOR     ${ueid}     IN    @{UE_list}
		UE Register Should Be Successful For SA    ${ueid}
		Log    Starting Downlink and Uplink Traffic for UE ${ueid}
		DL Traffic Should Be Successful    ${DL_RT}    ${ueid}
		UL Traffic Should Be Successful    ${UL_RT}    ${ueid}
		Log To Console      Starting Dl and Ul Traffic for UE ${ueid}
	END
	UE Disp
	FOR    ${cellid}	IN	@{PhyCellid}
		Start Interface Mirroring With NR Phy Cellids	name=l1l2bip_${cellid}	PhyCell=${cellid}
		Sleep   10s
		Stop Interface Mirroring With NR Phy Cellids	name=l1l2bip_${cellid}
	END
	Perform GNB Delta Commission		FAF=False
	FOR    ${cellid}	IN	@{PhyCellid}
		Start Interface Mirroring With NR Phy Cellids	name=l1l2bip_${cellid}	PhyCell=${cellid}
		Sleep   10s
		Stop Interface Mirroring With NR Phy Cellids	name=l1l2bip_${cellid}
	END
	FOR    ${cellid}	IN	@{PhyCellid}
		Verify CB010981 Activation		${cellid}
	END
	FOR     ${ueid}     IN    @{UE_list}
		UE Deregister Should Be Successful For SA       ${ueid}
		Log   De-Registered UE ${ueid}
	END
	[Teardown]    Run Keyword And Ignore Error          Common Tear Down
