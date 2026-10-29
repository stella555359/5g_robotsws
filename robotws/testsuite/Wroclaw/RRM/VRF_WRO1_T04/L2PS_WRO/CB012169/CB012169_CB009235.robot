*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LOOO   VARIANT_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    RAN_5G
...   RAN_5G_TDD

Documentation    :copyright: Nokia
...              :authors: Kamil Galczynski
...              :contact: kamil.galczynski@nokia.com

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource    ../CB009843/resources/CB009843_keywords.robot
Resource    ../CB007813/connect.robot
Library    ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library    ../CB007813/CB007813-B_keywords.py
Library    resources/vendor_file_modifier.py
Library    resources/CB012169_CB009235.py
Library    Collections
Resource     ../resources/configuration_id.robot
Library     taf.collectors.tcpdump          WITH NAME    tcpdump
Library     taf.collectors.l2stream3        WITH NAME    tcl
Library     taf.collectors.core             WITH NAME    tcc
Library     taf.converters.eventdecoder     WITH NAME    tce
Library     taf.sbts.oam.coam.admin         WITH NAME    coam10.0.108.14
Library     taf.transport.ssh               WITH NAME    ssh


Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_3xAQQL_3xAVQL.xml
    ...                        swconfig_flags_list=@{SWCONFIG_FLAGS}
    ...        AND             Start Default Logging
    ...        AND             Get and Update BSR File  bsr_file_name=BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002.zip
    ...        AND             Get and Update BSR File  bsr_file_name=BSR_AQQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002.zip
    ...        AND             Download and Modify Vendor File and perform commissioning    scf=full_CB012169_CB009235
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_CB009235.cfg
Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
@{SWCONFIG_FLAGS}=      0x8000A6=0  0x42009d=31
${PROFILE1}        ul_ue_beam_pos_nr profile_id=1 num_beam_paths=2 azimuth=-70,-70 zenith=-40,-40 power=-250,-250
${PROFILE2}        ul_ue_beam_pos_nr profile_id=2 num_beam_paths=2 azimuth=-53,-53 zenith=-30,-30 power=-250,-250
${PROFILE3}        ul_ue_beam_pos_nr profile_id=3 num_beam_paths=2 azimuth=-35,-35 zenith=-30,-30 power=-250,-250
${PROFILE4}        ul_ue_beam_pos_nr profile_id=4 num_beam_paths=2 azimuth=-18,-18 zenith=-10,-10 power=-250,-250
${PROFILE5}        ul_ue_beam_pos_nr profile_id=5 num_beam_paths=2 azimuth=0,0 zenith=0,0 power=-250,-250
${PROFILE6}        ul_ue_beam_pos_nr profile_id=6 num_beam_paths=2 azimuth=35,35 zenith=20,20 power=-250,-250
${PROFILE7}        ul_ue_beam_pos_nr profile_id=7 num_beam_paths=2 azimuth=18,18 zenith=10,10 power=-250,-250
${PROFILE8}        ul_ue_beam_pos_nr profile_id=8 num_beam_paths=2 azimuth=53,53 zenith=30,30 power=-250,-250
${PROFILE9}        ul_ue_beam_pos_nr profile_id=9 num_beam_paths=2 azimuth=-18,-18 zenith=-20,-20 power=-250,-250
${PROFILE10}       ul_ue_beam_pos_nr profile_id=10 num_beam_paths=2 azimuth=18,18 zenith=-20,-20 power=-250,-250
${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=5 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id\=12 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-5 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id\=14 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-10 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE15}    ul_mimo_srs_beam_pos_nr profile_id\=15 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE16}    ul_mimo_srs_beam_pos_nr profile_id\=16 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-20 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE17}    ul_mimo_srs_beam_pos_nr profile_id\=17 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-25 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE18}    ul_mimo_srs_beam_pos_nr profile_id\=18 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-30 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE19}    ul_mimo_srs_beam_pos_nr profile_id\=19 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-35 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE20}    ul_mimo_srs_beam_pos_nr profile_id\=20 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=1 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-40 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
${PRB_DL_MU_MIMO_2PAIR_UE} =    M55308C34013
${LOCAL_MOID_CELL1}=         PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${LOCAL_MOID_CELL2}=         PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
${LOCAL_MOID_CELL3}=         PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
${LOCAL_MOID_CELL4}=         PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
${LOCAL_MOID_CELL5}=         PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
${LOCAL_MOID_CELL6}=         PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-6
@{cell_ids_to_check}=       50  51  52  53  54  55

*** Test Cases ***
[1]CB009235_A_B103_Case26_performance_test_for_16UEsPerSlot_when_rdNumberOfCorrelationCalculation_default_value
	Set Pos For 120UE
    Attach_Multi_SA_UE_and_send_traffic    120
    Verify UEs Pairing Counters
    Collect Tti Trace For 1 Seconds with CB012169
    CB012169_CB009235.Count Pairs    filepath=${OUTPUT_DIR}/TTI_TRACE_CB012169/TTI_TRACE_dl.csv      cell_ids=@{cell_ids_to_check}
    [Teardown]    Send Configuration ID To Scout

*** Keywords ***
Attach_Multi_SA_UE_and_send_traffic
    [Arguments]    ${Num_UE}
	FOR    ${ue_id}    IN RANGE     1    ${Num_UE}+1
	    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=1
        Attach Ue    ue_id=${ue_id}
        Establish Pdu Session    ue_id=${ue_id}     pdu_id=1     gw_id=${ue_id}
	    Start Dl and UL Traffic     ue_id=${ue_id}
	    sleep    2s
	END

Set Pos For 120UE
    Execute Egate Command    ${PROFILE1}
	Execute Egate Command    ${PROFILE2}
    Execute Egate Command    ${PROFILE3}
	Execute Egate Command    ${PROFILE4}
    Execute Egate Command    ${PROFILE5}
	Execute Egate Command    ${PROFILE6}
    Execute Egate Command    ${PROFILE7}
	Execute Egate Command    ${PROFILE8}
    Execute Egate Command    ${PROFILE9}
	Execute Egate Command    ${PROFILE10}
	Execute Egate Command    ${PROFILE11}
	Execute Egate Command    ${PROFILE12}
	Execute Egate Command    ${PROFILE13}
	Execute Egate Command    ${PROFILE14}
	Execute Egate Command    ${PROFILE15}
	Execute Egate Command    ${PROFILE16}
	Execute Egate Command    ${PROFILE17}
	Execute Egate Command    ${PROFILE18}
	Execute Egate Command    ${PROFILE19}
	Execute Egate Command    ${PROFILE20}

	FOR    ${id}    IN RANGE    1    11
	    ${profile_id}=    Evaluate    ${id} + 10
		Execute Egate Command    cmd=ue_testmode_set_nr id=${id} testmode=ul_mimo_srs_beam_pos action=activate profile_id=${profile_id}
    END

    FOR    ${id}    IN RANGE    10    21
		Execute Egate Command    cmd=ue_testmode_set_nr id=${id} testmode=ul_mimo_srs_beam_pos action=activate profile_id=${profile_id}
    END

    FOR    ${id}    IN RANGE    21    31
        ${profile_id}=    Evaluate    ${id} - 10
		Execute Egate Command    cmd=ue_testmode_set_nr id=${id} testmode=ul_mimo_srs_beam_pos action=activate profile_id=${profile_id}
    END

    FOR    ${id}    IN RANGE    31    41
        ${profile_id}=    Evaluate    ${id} - 20
		Execute Egate Command    cmd=ue_testmode_set_nr id=${id} testmode=ul_mimo_srs_beam_pos action=activate profile_id=${profile_id}
    END

    FOR    ${id}    IN RANGE    41    51
        ${profile_id}=    Evaluate    ${id} - 30
		Execute Egate Command    cmd=ue_testmode_set_nr id=${id} testmode=ul_mimo_srs_beam_pos action=activate profile_id=${profile_id}
    END

    FOR    ${id}    IN RANGE    51    61
        ${profile_id}=    Evaluate    ${id} - 40
		Execute Egate Command    cmd=ue_testmode_set_nr id=${id} testmode=ul_mimo_srs_beam_pos action=activate profile_id=${profile_id}
    END

    FOR    ${id}    IN RANGE    61    71
        ${profile_id}=    Evaluate    ${id} - 60
		Execute Egate Command    cmd=ue_testmode_set_nr id=${id} testmode=ue_ul_beam_position action=activate profile_id=${profile_id}
    END

    FOR    ${id}    IN RANGE    71    81
        ${profile_id}=    Evaluate    ${id} - 70
		Execute Egate Command    cmd=ue_testmode_set_nr id=${id} testmode=ue_ul_beam_position action=activate profile_id=${profile_id}
    END

    FOR    ${id}    IN RANGE    81    91
        ${profile_id}=    Evaluate    ${id} - 80
		Execute Egate Command    cmd=ue_testmode_set_nr id=${id} testmode=ue_ul_beam_position action=activate profile_id=${profile_id}
    END

    FOR    ${id}    IN RANGE    91    101
        ${profile_id}=    Evaluate    ${id} - 90
		Execute Egate Command    cmd=ue_testmode_set_nr id=${id} testmode=ue_ul_beam_position action=activate profile_id=${profile_id}
    END

    FOR    ${id}    IN RANGE    101    111
        ${profile_id}=    Evaluate    ${id} - 100
		Execute Egate Command    cmd=ue_testmode_set_nr id=${id} testmode=ue_ul_beam_position action=activate profile_id=${profile_id}
    END

    FOR    ${id}    IN RANGE    111    121
        ${profile_id}=    Evaluate    ${id} - 110
		Execute Egate Command    cmd=ue_testmode_set_nr id=${id} testmode=ue_ul_beam_position action=activate profile_id=${profile_id}
    END

Start Dl and UL Traffic
	[Arguments]    ${ue_id}
	Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl mbps=20 trf_id=1

    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 dir=ul mbps=5 trf_id=1

Set Internal Traffic Type To UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Verify UEs Pairing Counters
    Wait For Next Full Pm Interval
    ${pm_counters_filepath}=    Get Latest Unpacked Raw Pm Counters File

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_2PAIR_UE}
    ...    value=100
    ...    local_moid=${LOCAL_MOID_CELL1}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_2PAIR_UE}
    ...    value=100
    ...    local_moid=${LOCAL_MOID_CELL2}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_2PAIR_UE}
    ...    value=100
    ...    local_moid=${LOCAL_MOID_CELL3}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_2PAIR_UE}
    ...    value=100
    ...    local_moid=${LOCAL_MOID_CELL4}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_2PAIR_UE}
    ...    value=100
    ...    local_moid=${LOCAL_MOID_CELL5}
    ...    filepath=${pm_counters_filepath}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${PRB_DL_MU_MIMO_2PAIR_UE}
    ...    value=100
    ...    local_moid=${LOCAL_MOID_CELL6}
    ...    filepath=${pm_counters_filepath}

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
