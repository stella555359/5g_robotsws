*** Settings ***
Documentation
...	[Procedure]				"[1]TRS_SBTS_multiplexing_demultiplexing_Iub_dual_uplane_multivlan_RP000720"
...	[Date]					"09-03-2023"
...	[Author]				"Boban Mathew"
...	[Feature_ID] 			"RP000720"
...	[Maintenance]			"TRS I & V Tools Bangalore Team"
...	[Funtion_Hash_Tags] 	"FPMUX"
...	[DELTA_FILE_DEPENDENCY] "FPMUX WRONG PORT VALUE"
...	[Validated_TestLine] 	"Local ASIM TL 10.58.143.113"
...	[Config_Comments] 		"2G and 3G Configuration"
...	[Precondition] 			"WCDMA RAT should be onAIR"
...	[QC_Path]               "Root\Test_Sets\23R2\Regression\BB_TRS_VRF_ET\CRT\NF_Automated_Regression"
...	[QC_ID]					"1282157"

Resource	${CURDIR}/resources/Common_RP000720.robot


Force Tags      CA_E2ET_BTSTRSPZ        SBTS00      SBTS25R2     4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT

Suite Setup		Run Keywords	Suite Setup Preconditions
...             AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...             AND		Teardown Oamops


***Test Cases***
[1]TRS_SBTS_multiplexing_demultiplexing_Iub_dual_uplane_multivlan_RP000720
	Perform Commissioning       scf_file=${FPMUX_scf}    verify_bts_status=False      timeout=600      alias=default
	Sleep    900
	${alarm}=   Verify Alarm
	Traffic Capture Start	capture_device=oam_device	alias=capture_alias	mode=file	measurement_point=NE_Terminated
	Sleep	60
	${fpmux_packets}=	Traffic Capture Stop	alias=capture_alias	mode=file
	Analyse Pcap        pcap_filename=${fpmux_packets}        analysis=fpmux_ul      filter_file_name=${fpmux_asim}
	Analyse Pcap        pcap_filename=${fpmux_packets}        analysis=fpmux_dl      filter_file_name=${fpmux_asim}
	Traffic Capture Start	capture_device=oam_device	alias=capture_alias_1	mode=file	measurement_point=Transport_Interface
	Sleep	60
	${fpmux_packets}=	Traffic Capture Stop	alias=capture_alias_1	mode=file
	Analyse Pcap        pcap_filename=${fpmux_packets}        analysis=fpmux_ul      filter_file_name=${fpmux_asim}
	Analyse Pcap        pcap_filename=${fpmux_packets}        analysis=fpmux_dl      filter_file_name=${fpmux_asim}

