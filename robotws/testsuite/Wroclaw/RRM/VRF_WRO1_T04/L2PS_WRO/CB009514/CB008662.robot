*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO   VARIANT_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    RAN_5G
...   RAN_5G_TDD

Documentation    :copyright: Nokia
...              :authors: Kamil Galczynski
...              :contact: kamil.galczynski@nokia.com

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     resources/CB009514_keywords.robot
Resource    ../CB007813/connect.robot
Library    ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library     taf.collectors.tcpdump          WITH NAME    tcpdump
Library     taf.collectors.l2stream3        WITH NAME    tcl
Library     taf.collectors.core             WITH NAME    tcc
Library     taf.converters.eventdecoder     WITH NAME    tce
Library     taf.sbts.oam.coam.admin         WITH NAME    coam10.0.108.14
Library     taf.transport.ssh               WITH NAME    ssh
Library    ../CB007813/CB007813-B_keywords.py
Library    resources/vendor_file_modifier.py
Library    resources/CB008662.py
Library    Collections
Resource     ../resources/configuration_id.robot


Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_1xAVQL.xml
    ...                        swconfig_flags_list=@{SWCONFIG_FLAGS}
    ...        AND             Start Default Logging
    ...        AND             Download and Modify Vendor File and perform commissioning    scf=full_CB008662
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_CB008662.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{SWCONFIG_FLAGS}=      0x8000A6=0


*** Test Cases ***
[1][1.0] TC01_CB008662-A#B1_basic algorithm wo change of modulation order in DL_default settings
    Set Bad DL Conditions
    Attach UEs
    Start Dl Traffic For All UEs
    Collect Tti Trace For 3 Seconds with DL_No_feature_activated
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...     parameter=actAdaptiveReTxResMcs    value=true
    Sleep   30s
    Set Bad DL Conditions
    Attach UEs
    Start Dl Traffic For All UEs
    Collect Tti Trace For 3 Seconds with DL_Feature_Activated
    CB008662.Regular MCS DL Check    file_path=${OUTPUT_DIR}/TTI_TRACE_DL_No_feature_activated/TTI_TRACE_dl
    CB008662.Reserved MCS DL Check    file_path=${OUTPUT_DIR}/TTI_TRACE_DL_Feature_Activated/TTI_TRACE_dl
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE-1
    ...    AND    Stop All Data Transfers And Detach UE-2
    ...    AND    Stop All Data Transfers And Detach UE-3
    ...    AND    Stop All Data Transfers And Detach UE-4
    ...    AND    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...     parameter=actAdaptiveReTxResMcs    value=false
    ...    AND    Sleep   30s
    ...    AND    Send Configuration ID To Scout

[1][1.0] TC06_CB008662-A#B2_basic algorithm wo change of modulation order in UL_default settings
	Set Bad UL Conditions
	Attach UEs
    Start Ul Traffic For All UEs
    Collect Tti Trace For 3 Seconds with UL_No_feature_activated
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...     parameter=actAdaptiveReTxResMcs    value=true
    Sleep   30s
    Set Bad UL Conditions
	Attach UEs
    Start Ul Traffic For All UEs
    Collect Tti Trace For 3 Seconds with UL_Feature_Activated
    CB008662.Regular MCS UL Check    file_path=${OUTPUT_DIR}/TTI_TRACE_UL_No_feature_activated/TTI_TRACE_ul
    CB008662.Reserved MCS UL Check    file_path=${OUTPUT_DIR}/TTI_TRACE_UL_Feature_Activated/TTI_TRACE_ul
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE-1
    ...    AND    Stop All Data Transfers And Detach UE-2
    ...    AND    Stop All Data Transfers And Detach UE-3
    ...    AND    Stop All Data Transfers And Detach UE-4
    ...    AND    Send Configuration ID To Scout


*** Keywords ***
Start Ul Traffic For All UEs
    FOR    ${id}    IN RANGE    1    5
		Start Ul Traffic     ue_id=${id}
    END
    Sleep    30s

Start Dl Traffic For All UEs
    FOR    ${id}    IN RANGE    1    5
		Start Dl Traffic     ue_id=${id}
    END
    Sleep    30s

Start Ul Traffic
	[Arguments]    ${ue_id}
	Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} dir=ul mbps=175 trf_id=1
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:${ue_id} UpfId:1 Pdu:${ue_id} Qfi:1 TrfId:1

Start Dl Traffic
	[Arguments]    ${ue_id}
	Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} dir=dl mbps=175 trf_id=1
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:${ue_id} Qfi:1 TrfId:1

Attach UEs
	FOR    ${id}    IN RANGE    1    5
		Set Internal Traffic Type To UE    ue_id=${id}    pdu_id=${id}
        Attach Ue    ue_id=${id}
        Establish Pdu Session    ue_id=${id}     pdu_id=${id}     gw_id=${id}
    END

Set Internal Traffic Type To UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Set Bad DL Conditions
	Execute Egate Command   cmd=ue_testmode_decode_muxphychan decode_mux_phy_chan=decode_PDSCH
	Execute Egate Command   cmd=bler_testmode_nr profile_id=1 dl_bler=100,100,100,50
	Execute Egate Command   cmd=csi_override_testmode_nr profile_id=3 ri=1 ri_mode=fixed cqi=1 cqi_mode=fixed
	FOR    ${id}    IN RANGE    1    5
		Execute Egate Command   cmd=ue_testmode_set_nr id=${id} testmode=csi_override profile_id=3 scell=secondary
		...     action=activate
	    Execute Egate Command   cmd=ue_testmode_set_nr id=${id} testmode=bler profile_id=1 action=activate
    END

Set Bad UL Conditions
	Execute Egate Command   cmd=ul_cell_noise_testmode_nr profile_id=1 noise_pusch=-710
	Execute Egate Command   cmd=ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=-210
	FOR    ${id}    IN RANGE    1    5
	    Execute Egate Command   cmd=ue_testmode_set_nr id=${id} testmode=ul_sinr profile_id=1 action=activate
    END

Collect Tti Trace For ${time} Seconds with ${feature_status}
    Start TTI trace
    Sleep    ${time}s
    Stop TTI trace
    Convert TTI trace from pcap to excelCsv    ${feature_status}

Start TTI trace
    ${configurations}=  tcc.Load Configurations
    ...  ${CURDIR}/ttitrace_collectors.yaml
    tcc.Create collectors
    ...  names=l2stream3
    ...  configurations=${configurations['collectors']}
    tcl.Set suite alias
    ...  alias=l2stream3
    tcc.Setup collectors
    ...  names=l2stream3
    tcc.Start collectors
    ...  names=l2stream3

Stop TTI trace
    tcc.Stop collectors
    ...  names=l2stream3
    tcc.Collect collectors
    ...  names=l2stream3
    ...  target_dir=${OUTPUT_DIR}
    tcc.Teardown collectors
    ...  names=l2stream3

Convert TTI trace from pcap to excelCsv
    [Arguments]    ${feature_status}
    tce.Create eventDecoder converter
    ...  name=ttitrace_converter
    ...  input_file_path=${OUTPUT_DIR}/l2stream3/tcpdump/tcpdump.pcap
    ...  output_file_format=excelCsv
    ...  output_file_path=${OUTPUTDIR}/TTI_TRACE/
    tce.Convert
    ...  name=ttitrace_converter

    Move File    ${OUTPUT_DIR}/l2stream3/tcpdump/tcpdump.pcap    ${OUTPUT_DIR}/TTI_TRACE_${feature_status}/tcpdump.pcap
    Move File    ${OUTPUT_DIR}/TTI_TRACE_dl*.csv   ${OUTPUT_DIR}/TTI_TRACE_${feature_status}/TTI_TRACE_dl.csv
    Move File    ${OUTPUT_DIR}/TTI_TRACE_ul*.csv   ${OUTPUT_DIR}/TTI_TRACE_${feature_status}/TTI_TRACE_ul.csv

Stop All Data Transfers And Detach UE-${id}
    Execute Egate Command    cmd=trf_data_stop ue=${id} pdu=${id}
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=${id} ue_deregister_type=switch_off
