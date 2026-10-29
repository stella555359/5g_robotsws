*** Settings ***
Library           OperatingSystem
Library           Collections
Library           DateTime
Library           logging
Library           ArchiveLibrary
Library           taf.gnb.oam.commissioning         WITH NAME    commissioning
Library           taf.gnb.oam.megazone_client       WITH NAME    megazone_client
Library           taf.transport.ssh                 WITH NAME    csn
Library           taf.cloud.openstack               WITH NAME    openstack
Library           taf.lteemu                        WITH NAME    lteemu
Library           taf.config.scf                    WITH NAME    scf
Library           taf.sbts.oam.coam.admin           WITH NAME    coam
Library           taf.pdu                           WITH NAME   pdu
#Library           ute_admin                         WITH NAME   ute_adm
Library           taf.sbts.oam.coam.admin           WITH NAME   ute_adm
Library           ../NPS/SWENG/python_libs/luashark_tools.py
Library           luashark_tools.analyzer    isLuaSharkRequired=False    WITH NAME       analyzer
Resource          ../NPS/SWENG/robot/Setup.robot
#Resource          ../NPS/SWENG/robot/Capture.robot
Resource          ../NPS/SWENG/robot/PacketSearch.robot
Library           ../python/conformace_test_verifiers_mcshark.py
Resource          ConformanceConstants/Constants_for_UE1_mcshark.robot
Resource          ConformanceConstants/Constants_for_UE2.robot
Resource          ConformanceConstants/Constants_for_UE3.robot
Resource          ConformanceConstants/Constants_general_mcshark.robot
Library           ../python/BIP_Capture.py
Library           ../python/CPRT_Capture.py
Library          taf.ul.gnb.bip.collection   WITH NAME   bip_collection
Resource         ./common_log_collection.robot


*** Variables ***
${numOfPacket}    1
${sw_version_trunk}     SBTS20A
${BIP_SCRIPT_PATH}      ${CURDIR}/../../resources/NPS/SWENG/config/script/
@{FIELDS_PUCCH_RESP}                slot        sfn
@{FIELDS_PUSCH_RESP}       numOfUciCsiPart1Bits     numOfUciAckBits     numOfUciAckSymbols      numOfUciAckSymbols1bit
@{FIELDS_PUSCH_RESP_MCS}       mcsTable
${Filter_cellsetupreq}      sctp
${tl_mode}          l1b

*** Keywords ***
Start DL Test Transmitter
    [Arguments]    ${test_model}    ${ru_mode}    ${pci}    ${polarization}    ${beamPatternId}   ${p_max}    ${power_backoff}    ${mimo_rank}
    [Documentation]
    ...     Start 5G Downlik Test
    ...
    ...    :param test_model:  One of the following: TM1_1, TM1_2, TM2, TM2A, TM3_1, TM3_1A, TM3_2, TM3_3, TM3_1N.
    ...    :param ru_mode: One of the following: NR_Only, MSR (MSR is supported when RU contains EUTRA.Frequency.Band)
    ...    :param pci: Physical Cell ID -  [1..1007]
    ...    :param polarization: One of the following: P_plus45_or_0, P_minus45_or_90, P_both.
    ...    :param beam: Beam Pattern [0..1200]
    ...
    ...    :return:   It returns dict with data.
    ...
    ...    +-----------------------------------------------------------------------------------------------------------+
    ...    | Usage from Robot                                                                                           |
    ...    +============================================================================================================+
    ...    | Start DL Test Transmitter with the following parameters [TM1_1, NR_Only, 50, P_both, 1200, 26]             |
    ...    +------------------------------------------------------------------------------------------------------------+
    ...
    log to console       Start DL Test Transmitter
    set suite variable          ${test_model_value}     ${test_model}
    ${run_time_id}=    Check run time id
    set suite variable          ${run_time}      ${run_time_id}
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin   release=SBTS21B
    ${my_response}=    coam.start_5g_downlink_test
    ...                dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${run_time}/MRBTS_R-${run_time}/NRBTS_R-1/NRCELL_R-1
    ...                test_model=${test_model}
    ...                beam_pattern_id=${beamPatternId}
    ...                polarization=${polarization}
    ...                power_backoff=${power_backoff}
    ...                ru_mode=${ru_mode}
    ...                phys_cell_id=${pci}
    ...                i11_codebook_4_antports=0
    ...                i2_codebook_4_antports=0
    ...                i13_codebook_4_antports=${0}
    ...                mimo_rank=${mimo_rank}
    ...                codebook_2_antports=${0}
    ...                p_max=${p_max}
    ...                connection=coam_admin
    Log to console        ${my_response}
    ${my_result_node}=    Get From Dictionary    ${my_response}        resultNode
    ${my_parameters}=     Get From Dictionary    ${my_result_node}     parameters
    ${status}=            Get From Dictionary    ${my_parameters}      status
    Log to console        ${status}
    Should Contain         ${status}    Succeeded
    [Return]            ${test_model_value}
    Log Variables

Change beamPattern id
    [Arguments]     ${test_dn}      ${newBeamPatternId}
    [Documentation]
    ...     Change Beam Pattern ID
    ...
    ...    :param beam: Beam Pattern [0..1200]
    ...
    ...    :return:   It returns dict with data.
    ...
    log to console       Change beamPattern id
    set suite variable          ${new_beam}      ${newBeamPatternId}
    ${my_response}=    coam.change_beam_pattern_id
    ...                test_dn=${test_dn}
    ...                beam_pattern_id=${newBeamPatternId}
    ...                connection=coam_admin
    Log to console        ${my_response}
    Should Contain         ${my_response}    Succeeded
    [Return]            ${new_beam}
    Log Variables


Start DL Test Transmitter for TM1_1
    [Arguments]    ${test_model}    ${ru_mode}    ${pci}    ${polarization}    ${beamPatternId}
    log to console      Start DL Test Transmitter
    set suite variable          ${test_model_value}     ${test_model}
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
    ${my_response}=    coam.start_5g_downlink_test    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
    ...                                               test_model=${test_model}
    ...                                               beam_pattern_id=${beamPatternId}
    ...                                               polarization=${polarization}
    ...                                               power_backoff=10
    ...                                               ru_mode=${ru_mode}
    ...                                               phys_cell_id=${pci}
    ...                                               i11_codebook_4_antports=0
    ...                                               i2_codebook_4_antports=0
    ...                                               i13_codebook_4_antports=${0}
    ...                                               mimo_rank=${2}
    ...                                               codebook_2_antports=${0}
    ...                                               p_max=26
    ...                                               connection=coam_admin
    Log to console        ${my_response}
    ${my_result_node}=    Get From Dictionary    ${my_response}        resultNode
    ${my_parameters}=     Get From Dictionary    ${my_result_node}     parameters
    ${status}=            Get From Dictionary    ${my_parameters}      status
    Log to console        ${status}
    Should Contain         ${status}    Succeeded
    [Return]            ${test_model_value}
    Log Variables


Start Test Receiver FRC Index ${frc_index} on ${ruMode}
    [Documentation]
    ...     Starts 5G Uplink Test.
    ...
    ...    :param frc_index:  One of the following: G_FR1_A1_1, G_FR1_A1_2, G_FR1_A1_4, G_FR1_A1_5, G_FR1_A1_7,
    ...                                             G_FR1_A2_1, G_FR1_A2_4, G_FR1_A2_5, GFR2_A1_2, G_FR2_A1_3
    ...    :param ru_mode: One of the following: NR_Only, MSR (MSR is supported when RU contains EUTRA.Frequency.Band)
    ...
    ...    :return:   It returns dict with data.
    ...
    ...    +-----------------------------------------------------------------------------------------------------------+
    ...    | Usage from Robot - e.g.                                                                                   |
    ...    +============================================================================================================+
    ...    | Start Test Receiver FRC Index G_FR1_A5_8 on MSR                                                           |
    ...    +------------------------------------------------------------------------------------------------------------+
    ...
    Log to console                       Start Test Receiver FRC Index ${frc_index} on ${ruMode}
    set suite variable          ${test_model_value}     ${frc_index}
    ${run_time_id}=    Check run time id
    set suite variable          ${run_time}      ${run_time_id}
    ${beampattern}       Create List       ${1}   ${1}
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin   release=SBTS21B
    ${my_response}=    coam.start_5g_uplink_test
    ...                dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${run_time}/MRBTS_R-${run_time}/NRBTS_R-1/NRCELL_R-1
    ...                frc_index=${frc_index}
    ...                beam_pattern_id=${beampattern}
    ...                interval=1
    ...                prb_offset=1
    ...                ru_mode=${ruMode}
    ...                phys_cell_id=50
    ...                connection=coam_admin
    Log to console              ${my_response}
    ${my_result_node}=     Get From Dictionary    ${my_response}        resultNode
    ${my_parameters}=      Get From Dictionary    ${my_result_node}     parameters
    ${status}=             Get From Dictionary    ${my_parameters}      status
    Log to console        ${status}
    Should Contain         ${status}    Succeeded
    [Return]               ${test_model_value}

Start Performance Test PUCCH CB008444
    [Arguments]    ${reporting_int}         ${beamPatternId}            ${pucch_format}       ${ru_mode}        ${pci}
    ...            ${format_2_test_type}    ${pucch_payload_content}    ${num_payload_bit}    ${numPucchSymbol}
    [Documentation]
    ...               Starts 5G Pucch Performance CCM Test (start5GUplinkCCMTest).
    ...
    log to console   Start Performance Test PUCCH
    set suite variable          ${test_model_value}     PUCCH
    set suite variable          ${format_2}     ${format_2_test_type}
    set suite variable          ${pucch_format_type}     ${pucch_format}
    ${run_time_id}=    Check run time id
    set suite variable          ${run_time}      ${run_time_id}
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin   release=SBTS21B
    ${my_response}=    coam.start_5g_uplink_ccm_test_pucch
    ...                dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${run_time}/MRBTS_R-${run_time}/NRBTS_R-1/NRCELL_R-1
    ...                interval=${reporting_int}
    ...                beam_pattern_id=${beamPatternId}
    ...                ru_mode=${ru_mode}
    ...                phys_cell_id=${pci}
    ...                receiving_slot=8
    ...                expectation_slot=8
    ...                pucch_format=${pucch_format}
    ...                prb_offset=1
    ...                largest_prb_index=100
    ...                num_pucch_symbol=${numPucchSymbol}
    ...                num_payload_bit=${num_payload_bit}
    ...                pucch_payload_content=${pucch_payload_content}
    ...                connection=coam_admin
    ...                format3_additional_dmrs=Disabled
    Log to console        ${my_response}
    ${my_result_node}=    Get From Dictionary    ${my_response}        resultNode
    ${my_parameters}=     Get From Dictionary    ${my_result_node}     parameters
    ${status}=            Get From Dictionary    ${my_parameters}      status
    Log to console        ${status}
    Should Contain         ${status}    Succeeded

Start Performance Test PUCCH
    [Arguments]    ${reporting_int}         ${beamPatternId}            ${pucch_format}       ${ru_mode}        ${pci}
    ...            ${format_2_test_type}    ${pucch_payload_content}    ${num_payload_bit}    ${numPucchSymbol}
    ...            ${nrarfcn_ul}            ${nrarfcn_dl}
    [Documentation]
    ...               Starts 5G Pucch Performance CCM Test (start5GUplinkCCMTest).
    ...
    log to console   Start Performance Test PUCCH
    set suite variable          ${test_model_value}     PUCCH
    set suite variable          ${format_2}     ${format_2_test_type}
    set suite variable          ${pucch_format_type}     ${pucch_format}
    ${run_time_id}=    Check run time id
    set suite variable          ${run_time}      ${run_time_id}
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin   release=SBTS23R2
    ${my_response}=    coam.start_5g_uplink_ccm_test_pucch
    ...                dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${run_time}/MRBTS_R-${run_time}/NRBTS_R-1/NRCELL_R-1
    ...                interval=${reporting_int}
    ...                beam_pattern_id=${beamPatternId}
    ...                ru_mode=${ru_mode}
    ...                nrarfcn_ul=${nrarfcn_ul}
    ...                nrarfcn_dl=${nrarfcn_dl}
    ...                phys_cell_id=${pci}
    ...                receiving_slot=780
    ...                expectation_slot=780
    ...                pucch_format=${pucch_format}
    ...                prb_offset=1
    ...                largest_prb_index=100
    ...                num_pucch_symbol=${numPucchSymbol}
    ...                num_payload_bit=${num_payload_bit}
    ...                pucch_payload_content=${pucch_payload_content}
    ...                connection=coam_admin
    ...                format3_additional_dmrs=Disabled
    ...                digital_output_enable=False
    ...                act_high_speed_cell=False
    Log to console        ${my_response}
    ${my_result_node}=    Get From Dictionary    ${my_response}        resultNode
    ${my_parameters}=     Get From Dictionary    ${my_result_node}     parameters
    ${status}=            Get From Dictionary    ${my_parameters}      status
    Log to console        ${status}
    Should Contain         ${status}    Succeeded

Start Performance Test PRACH CB008444
    [Documentation]
    ...     Starts 5G Prach Performance CCM Test (start5GUplinkCCMTest)
    ...
    ...    :return:   It returns dict with data.
    ...
    Log to console                       Start_test_Prach
    set suite variable          ${test_model_value}     PRACH
    ${run_time_id}=    Check run time id
    set suite variable          ${run_time}      ${run_time_id}
    ${beampattern}       Create List       ${900}   ${900}
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
     ${my_response}=    coam.Start 5g Uplink Ccm Test Prach
    ...                 dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${run_time}/MRBTS_R-${run_time}/NRBTS_R-1/NRCELL_R-1
    ...                                                        interval=0.5
    ...                                                        beam_pattern_id=${beampattern}
    ...                                                        ru_mode=NR_Only
    ...                                                        phys_cell_id=50
    ...                                                        receiving_slot=8
    ...                                                        expectation_slot=8
    ...                                                        preamble_index=0
    ...                                                        accepted_timing_error=9
    ...                                                        constant_offset=100
    ...                                                        delay_pattern_single_step_duration=0
    ...                                                        prach_configuration_index=12
    ...                                                        pfa_target_prach_id=P_None
    ...                                                        prach_root_sequence_index=0
    ...                                                        zero_correlation_zone_config=0
    ...                                                        prach_sequence_type=Unrestricted
    ...                                                        connection=coam_admin
    Log to console        ${my_response}
    ${my_result_node}=    Get From Dictionary    ${my_response}        resultNode
    ${my_parameters}=     Get From Dictionary    ${my_result_node}     parameters
    ${test_dn}=           Get From Dictionary    ${my_result_node}     distName
    set suite variable     ${test_dn}     ${test_dn}
    ${status}=            Get From Dictionary    ${my_parameters}      status
    Log to console        ${status}
    Should Contain         ${status}    Succeeded


Start Performance Test PRACH
    [Arguments]    ${nrarfcn_ul}            ${nrarfcn_dl}
    [Documentation]
    ...     Starts 5G Prach Performance CCM Test (start5GUplinkCCMTest)
    ...
    ...    :return:   It returns dict with data.
    ...
    Log to console                       Start_test_Prach
    set suite variable          ${test_model_value}     PRACH
    ${run_time_id}=    Check run time id
    set suite variable          ${run_time}      ${run_time_id}
    ${beampattern}       Create List       ${900}   ${900}
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
    ${my_response}=    coam.Start 5g Uplink Ccm Test Prach
    ...                 dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${run_time}/MRBTS_R-${run_time}/NRBTS_R-1/NRCELL_R-1
    ...                                                        interval=0.5
    ...                                                        beam_pattern_id=${beampattern}
    ...                                                        ru_mode=NR_Only
    ...                                                        nrarfcn_ul=${nrarfcn_ul}
    ...                                                        nrarfcn_dl=${nrarfcn_dl}
    ...                                                        phys_cell_id=67
    ...                                                        receiving_slot=136
    ...                                                        expectation_slot=136
    ...                                                        preamble_index=0
    ...                                                        accepted_timing_error=9
    ...                                                        constant_offset=100
    ...                                                        delay_pattern_single_step_duration=0
    ...                                                        prach_configuration_index=87
    ...                                                        pfa_target_prach_id=P_None
    ...                                                        prach_root_sequence_index=0
    ...                                                        zero_correlation_zone_config=0
    ...                                                        prach_sequence_type=Unrestricted
    ...                                                        digital_output_enable=False
    ...                                                        act_high_speed_cell=False
    ...                                                        connection=coam_admin
    Log to console        ${my_response}
    ${my_result_node}=    Get From Dictionary    ${my_response}        resultNode
    ${my_parameters}=     Get From Dictionary    ${my_result_node}     parameters
    ${test_dn}=           Get From Dictionary    ${my_result_node}     distName
    set suite variable     ${test_dn}     ${test_dn}
    ${status}=            Get From Dictionary    ${my_parameters}      status
    Log to console        ${status}
    Should Contain         ${status}    Succeeded

Start Performance Test PUSCH
    [Arguments]    ${reporting_int}         ${beamPatternId}        ${ru_mode}        ${pci}        ${frcIndex}        ${mapType}
    ...            ${nrarfcn_ul}            ${nrarfcn_dl}
    [Documentation]
    ...               Starts 5G Pusch Performance CCM Test (start5GUplinkCCMTest).
    ...
    log to console   Start Performance Test PUSCH
    set suite variable          ${test_model_value}     ${frcIndex}
    ${run_time_id}=    Check run time id
    set suite variable          ${run_time}      ${run_time_id}
    set suite variable          ${fr2_enabled}     False
    ${fr2_bool}=     Convert To Boolean      ${fr2_enabled}
    ${actpercsi}    Create List     1342177280    2147483648
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin   release=SBTS23R4
    ${my_response}=    coam.start_5g_uplink_ccm_test_pusch
    ...                dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${run_time}/MRBTS_R-${run_time}/NRBTS_R-1/NRCELL_R-1
    ...                interval=${reporting_int}
    ...                beam_pattern_id=${beamPatternId}
    ...                ru_mode=${ru_mode}
    ...                nrarfcn_ul=${nrarfcn_ul}
    ...                nrarfcn_dl=${nrarfcn_dl}
    ...                phys_cell_id=${pci}
    ...                digital_out_type=SerialKeysight
    ...                prb_offset=0
    ...                digital_out_rate=Bitrate_115dot2K
    ...                frc_index=${frcIndex}
    ...                ul_dmrs_mapping_type=${mapType}
    ...                is_ptrs_fr2_enabled=${fr2_bool}
    ...                digital_output_enable=True
    ...                act_high_speed_cell=False
    ...                connection=coam_admin
    Log to console        ${my_response}
    ${my_result_node}=    Get From Dictionary    ${my_response}        resultNode
    ${my_parameters}=     Get From Dictionary    ${my_result_node}     parameters
    ${status}=            Get From Dictionary    ${my_parameters}      status
    Log to console        ${status}
    Should Contain         ${status}    Succeeded

Start Performance Test PUSCH UCI
    [Arguments]    ${reporting_int}         ${beamPatternId}        ${ru_mode}        ${pci}        ${frcIndex}        ${mapType}
    ...            ${nrarfcn_ul}            ${nrarfcn_dl}
    [Documentation]
    ...               Starts 5G Pusch Performance CCM Test (start5GUplinkCCMTest).
    ...
    log to console   Start Performance Test PUSCH
    set suite variable          ${test_model_value}     ${frcIndex}
    ${run_time_id}=    Check run time id
    set suite variable          ${run_time}      ${run_time_id}
    set suite variable          ${fr2_enabled}     False
    ${fr2_bool}=     Convert To Boolean      ${fr2_enabled}
    ${actpercsi}    Create List     1342177280    2147483648
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin   release=SBTS23R2
    ${my_response}=    coam.start_5g_uplink_ccm_test_pusch
    ...                dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${run_time}/MRBTS_R-${run_time}/NRBTS_R-1/NRCELL_R-1
    ...                interval=${reporting_int}
    ...                beam_pattern_id=${beamPatternId}
    ...                ru_mode=${ru_mode}
    ...                nrarfcn_ul=${nrarfcn_ul}
    ...                nrarfcn_dl=${nrarfcn_dl}
    ...                phys_cell_id=${pci}
    ...                digital_out_type=SerialKeysight
    ...                prb_offset=0
    ...                digital_out_rate=Bitrate_115dot2K
    ...                frc_index=${frcIndex}
    ...                num_uci_bits=7
    ...                csi_payload_bit=${actpercsi}
    ...                ul_dmrs_mapping_type=${mapType}
    ...                is_ptrs_fr2_enabled=${fr2_bool}
    ...                digital_output_enable=True
    ...                act_high_speed_cell=False
    ...                connection=coam_admin
    Log to console        ${my_response}
    ${my_result_node}=    Get From Dictionary    ${my_response}        resultNode
    ${my_parameters}=     Get From Dictionary    ${my_result_node}     parameters
    ${status}=            Get From Dictionary    ${my_parameters}      status
    Log to console        ${status}
    Should Contain         ${status}    Succeeded

Stop Test Transmitter test model
    [Documentation]
    ...     Stop 5G Downlik Test
    ...
    ...    :param str dist_name: `NRCELL_R` object to stop the test on.
    ...
    ...    :return:   It returns dict with data.
     Log to console                       Stop Transmitter_test_model
     coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
     ${my_response}=    coam.stop_5g_downlink_test
     ...                dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${run_time}/MRBTS_R-${run_time}/NRBTS_R-1/NRCELL_R-1   connection=coam_admin

     Log to console        ${my_response}
     ${my_result_node}=    Get From Dictionary    ${my_response}        resultNode
     ${my_parameters}=     Get From Dictionary    ${my_result_node}     parameters
     ${status}=            Get From Dictionary    ${my_parameters}      status
     Log to console        ${status}
     Should Contain         ${status}    Succeeded


Stop Control Test for MRBTS_R-${mrbts_id}
    [Documentation]
    ...     Stop 5G Downlik Test
    ...
    ...    :param str dist_name: `NRCELL_R` object to stop the test on.
    ...
    ...    :return:   It returns dict with data.
    Log to console       Stop Control Test for MRBTS_R-${mrbts_id}
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
    ${my_response}=    coam.Stop 5g Uplink Ccm Test
    ...                dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${mrbts_id}/MRBTS_R-${mrbts_id}/NRBTS_R-1/NRCELL_R-1
    ...                connection=coam_admin

    Log to console        ${my_response}
    ${my_result_node}=    Get From Dictionary    ${my_response}        resultNode
    ${my_parameters}=     Get From Dictionary    ${my_result_node}     parameters
    ${status}=            Get From Dictionary    ${my_parameters}      status

    Log to console         ${status}
    Should Contain         ${status}    Succeeded


Stop Test Receiver test model
     Log to console                       Stop Receiver_test_model
     coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
     ${my_response}=    coam.Stop 5g Uplink Ccm Test
     ...                dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${run_time}/MRBTS_R-${run_time}/NRBTS_R-1/NRCELL_R-1
     ...                connection=coam_admin

     Log to console        ${my_response}
     ${my_result_node}=    Get From Dictionary    ${my_response}        resultNode
     ${my_parameters}=     Get From Dictionary    ${my_result_node}     parameters
     ${status}=            Get From Dictionary    ${my_parameters}      status

     Log to console            ${status}
     Should Contain         ${status}    Succeeded

Stop Test Receiver G_FR model
     Log to console                       Stop Receiver_test_model
     coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
     ${my_response}=    coam.stop_5g_uplink_test
     ...                dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${run_time}/MRBTS_R-${run_time}/NRBTS_R-1/NRCELL_R-1
     ...                connection=coam_admin

     Log to console        ${my_response}
     ${my_result_node}=    Get From Dictionary    ${my_response}        resultNode
     ${my_parameters}=     Get From Dictionary    ${my_result_node}     parameters
     ${status}=            Get From Dictionary    ${my_parameters}      status

     Log to console            ${status}
     Should Contain         ${status}    Succeeded

Get information elements from L2PS_StartConformanceTestReq message
    [Documentation]     Retrieves data values from l2_ps_tm_cell_startconformancetestreq at CPRT level
    Log to console             Checking StartConformanceTestReq OAM-CPRT IE
    Log Variables

    ${start_conf_variables}     run keyword if     '${AirScale}' == 'ASOE'     Get IE from L2PS_StartConformanceTestReq
    ...                 ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap    itf_l2_ps_tm_cell_startconformancetestreq
    ...        ELSE      Get IE from L2PS_StartConformanceTestReq
    ...                 ${CaptureCPRT.path}    itf_l2_ps_tm_cell_startconformancetestreq
    set suite variable       ${start_conf_variables}     ${start_conf_variables}
    Log Variables


Get IE from L2PS_StartConformanceTestReq
    [Arguments]         ${pcapFile}    ${filter_req}
    [Documentation]
    ...                 Constructs and return a dictionary with
    ...                 key-value data structure from OAM-CPRT
    ...
    ${pdmlFile} =    Get filtered PDML file from pcap    ${pcapFile}    ${filter_req}

    ${packet}        set variable                  itf_l2_ps_tm_cell_StartConformanceTestReq_t

    ${beamPatternId}      analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*beamPatternIdList_item\\[1\\]
    ...                                                endPacket=${1}

    ${beamPatternId1}      analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*beamPatternIdList_item\\[2\\]
    ...                                                endPacket=${1}

    ${polarization}     analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*polarization$
    ...                                                endPacket=1

    ${ruMode_type}     analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*ruMode$
    ...                                                endPacket=1

    ${subFeatureFlag}     analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*subFeatureFlag$
    ...                                                endPacket=1

    ${harqEnable}     analyzer.get_unique              pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*harqEnable$
    ...                                                endPacket=1

    ${testModel}     analyzer.get_unique               pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*testModel$
    ...                                                endPacket=1

    ${i11Codebook4Ant}     analyzer.get_unique         pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*i11Codebook4AntPorts$
    ...                                                endPacket=1

    ${i2Codebook4Ant}     analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*i2Codebook4AntPorts$
    ...                                                endPacket=1

    &{start_conf_variables}     Create Dictionary         ruMode_type=${ruMode_type}
    ...                                                   beamPatternId=${beamPatternId}
    ...                                                   beamPatternId1=${beamPatternId1}
    ...                                                   polarization=${polarization}
    ...                                                   harqEnable=${harqEnable}
    ...                                                   i11Codebook4Ant= ${i11Codebook4Ant}
    ...                                                   i2Codebook4Ant=${i2Codebook4Ant}
    [Return]            ${start_conf_variables}
    Log Variables

Get information elements from L2PS_StartConformanceTestReq message for NR UL
    [Documentation]     Retrieves data values from l2_ps_tm_cell_startconformancetestreq at CPRT level
    ...                 for NR Performance Test
    Log to console                       Checking StartConformanceTestReq OAM-CPRT IE
    Log Variables
    ${start_conf_variables}     run keyword if     '${AirScale}' == 'ASOE'      Get IE from L2PS_StartConformanceTestReq for NR UL
    ...                     pcapFile=${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap       filter_req=itf_l2_ps_tm_cell_startconformancetestreq
    ...                        ELSE    Get IE from L2PS_StartConformanceTestReq for NR UL
    ...                     pcapFile=${CaptureCPRT.path}       filter_req=itf_l2_ps_tm_cell_startconformancetestreq
    set suite variable       ${start_conf_variables}     ${start_conf_variables}
    Log Variables

Get information elements from L2PS_StartConformanceTestReq message for NR RECEIVER
    [Documentation]     Retrieves data values from l2_ps_tm_cell_startconformancetestreq at CPRT level
    ...                 for NR Receiver test
    Log to console                       Checking StartConformanceTestReq OAM-CPRT IE
    Log Variables


    ${start_conf_variables}     run keyword if     '${AirScale}' == 'ASOE'      Get IE from L2PS_StartConformanceTestReq for NR UL
    ...                 pcapFile=${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap
    ...                 filter_req=itf_l2_ps_tm_cell_startconformancetestreq
    ...                ELSE     Get IE from L2PS_StartConformanceTestReq for NR UL
    ...                  pcapFile=${CaptureCPRT.path}
    ...                  filter_req=itf_l2_ps_tm_cell_StartConformanceTestReq.StartConformanceTestReq.type == 1

    set suite variable       ${start_conf_variables}     ${start_conf_variables}
    Log Variables

Get IE from L2PS_StartConformanceTestReq for NR UL
    [Arguments]                      ${pcapFile}    ${filter_req}
    ${pdmlFile} =    Get filtered PDML file from pcap    ${pcapFile}    ${filter_req}

    ${packet}        set variable                  itf_l2_ps_tm_cell_StartConformanceTestReq_t


    ${beamPatternId}      analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*beamPatternIdList_item\\[1\\]
    ...                                                endPacket=${1}

    ${beamPatternId1}      analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*beamPatternIdList_item\\[2\\]
    ...                                                endPacket=${1}

    ${reportingTimeInterval}     analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*reportingTimeInterval$
    ...                                                endPacket=1

    ${ruMode_type}     analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*ruMode$
    ...                                                endPacket=1

    ${numPayloadBit}     analyzer.get_unique           pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*numPayloadBit$
    ...                                                endPacket=1

    ${subFeatureFlag}     analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*subFeatureFlag$
    ...                                                endPacket=1

    ${prbOffset}     analyzer.get_unique               pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=itf_l2_ps_tm_SPucchPerfTestConf.prbOffset
    ...                                                endPacket=1

    ${prbOffset_receive_test}     analyzer.get_unique    pdmlFile=${pdmlFile}
    ...                                                  packetName=${packet}
    ...                                                  path=itf_l2_ps_tm_SReceiverTestingConfig.prbOffset
    ...                                                  endPacket=1

    ${largestPrbIndex}     analyzer.get_unique         pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*largestPrbIndex$
    ...                                                endPacket=1

    ${harqEnable}     analyzer.get_unique              pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*harqEnable$
    ...                                                endPacket=1

    ${testModel}     analyzer.get_unique               pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*testModel$
    ...                                                endPacket=1

    ${i11Codebook4Ant}     analyzer.get_unique         pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*i11Codebook4AntPorts$
    ...                                                endPacket=1

    ${i2Codebook4Ant}     analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*i2Codebook4AntPorts$
    ...                                                endPacket=1

    ${pucchFormat}     analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*pucchFormat$
    ...                                                endPacket=1

     ${numPucchSymbol}     analyzer.get_unique         pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*numPucchSymbol$
    ...                                                endPacket=1

    ${controlChannelTestType}     analyzer.get_unique  pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*controlChannelTestType$
    ...                                                endPacket=1

    &{start_conf_variables}     Create Dictionary    largestPrbIndex=${largestPrbIndex}
    ...                                              pucchFormat=${pucchFormat}
    ...                                              numPayloadBit=${numPayloadBit}
    ...                                              controlChannelTestType=${controlChannelTestType}
    ...                                              numPucchSymbol=${numPucchSymbol}
    ...                                              ruMode_type=${ruMode_type}
    ...                                              beamPatternId=${beamPatternId}
    ...                                              polarization=${polarization}
    ...                                              harqEnable=${harqEnable}
    ...                                              i11Codebook4Ant= ${i11Codebook4Ant}
    ...                                              i2Codebook4Ant=${i2Codebook4Ant}
    ...                                              prbOffset=${prbOffset}
    ...                                              prbOffset_receive_test=${prbOffset_receive_test}

    [Return]            ${start_conf_variables}
    Log Variables


Get Information elements from StartConformanceTestReq message for Long PUCCH TCs and verify
    Log to console                       Checking StartConformanceTestReq OAM-CPRT IE
    Log Variables
    ${start_conf_variables}        Get Information Element from L2PS UCI  ${CaptureCPRT.path}     itf_l2_ps_tm_cell_startconformancetestreq
    set suite variable       ${start_conf_variables}     ${start_conf_variables}
    Log Variables
    should be true    ${start_conf_variables.reportingTimeInterval} == 0.7
	Verify pusch StartConformanceTestReq_frc    frcIndex     G_FR1_A4_9
	Verify pusch StartConformanceTestReq    harqEnable     1
	Verify pusch StartConformanceTestReq    prbOffset_receive_test      0
	#Verify pusch StartConformanceTestReq    prbOffset      0
	Verify pusch StartConformanceTestReq    ruMode_type    0
    Verify pusch StartConformanceTestReq    ulDmrsMappingType      1
	Verify pusch StartConformanceTestReq    csiPayloadBit-Length    2
	Verify pusch StartConformanceTestReq    csiPayloadBit_item_0     1342177280
	Verify pusch StartConformanceTestReq    csiPayloadBit_item_1     2147483648
	Verify pusch StartConformanceTestReq    numUciBits     7

Get Information elements from StartConformanceTestReq message for PUSCH-C TC and verify
    Log to console                       Checking StartConformanceTestReq OAM-CPRT IE
    Log Variables
    ${start_conf_variables}        Get Information Element from L2PS    ${CaptureCPRT.path}     itf_l2_ps_tm_cell_startconformancetestreq
    set suite variable       ${start_conf_variables}     ${start_conf_variables}
    Log Variables
    should be true    ${start_conf_variables.reportingTimeInterval} == 0.2
	Verify pusch StartConformanceTestReq_frc    frcIndex     G_FR1_A3_31
	Verify pusch StartConformanceTestReq    harqEnable     1
	Verify pusch StartConformanceTestReq    prbOffset_receive_test      0
	#Verify pusch StartConformanceTestReq    prbOffset      0
	Verify pusch StartConformanceTestReq    ruMode_type    0
    Verify pusch StartConformanceTestReq    ulDmrsMappingType      0

Get Information elements from StartConformanceTestReq message for PUSCH-G TC and verify
    Log to console                       Checking StartConformanceTestReq OAM-CPRT IE
    Log Variables
    ${start_conf_variables}        run keyword if     '${AirScale}' == 'ASOE'    Get Information Element from L2PS
    ...           ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap      itf_l2_ps_tm_cell_startconformancetestreq
    ...    ELSE     Get Information Element from L2PS     ${CaptureCPRT.path}     itf_l2_ps_tm_cell_startconformancetestreq
    set suite variable       ${start_conf_variables}     ${start_conf_variables}
    Log Variables
    should be true    ${start_conf_variables.reportingTimeInterval} == 0.1
	Verify pusch StartConformanceTestReq_frc    frcIndex      G_FR1_A3_32
	Verify pusch StartConformanceTestReq    harqEnable     1
	Verify pusch StartConformanceTestReq    prbOffset_receive_test      0
#	Verify pusch StartConformanceTestReq    prbOffset      0
	Verify pusch StartConformanceTestReq    ruMode_type    0
    Verify pusch StartConformanceTestReq    ulDmrsMappingType      0

Get Information elements from StartConformanceTestReq message for PUSCH-G TC and verify CB010308
    Log to console                       Checking StartConformanceTestReq OAM-CPRT IE
    Log Variables
    ${start_conf_variables}        run keyword if     '${AirScale}' == 'ASOE'    Get Information Element from L2PS
    ...           ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap      itf_l2_ps_tm_cell_startconformancetestreq
    ...    ELSE     Get Information Element from L2PS     ${CaptureCPRT.path}     itf_l2_ps_tm_cell_startconformancetestreq
    set suite variable       ${start_conf_variables}     ${start_conf_variables}
    Log Variables
    should be true    ${start_conf_variables.reportingTimeInterval} == 0.1
	Verify pusch StartConformanceTestReq_frc    frcIndex    ${frcIndex}
	Verify pusch StartConformanceTestReq    harqEnable     1
	Verify pusch StartConformanceTestReq    prbOffset_receive_test      0
#	Verify pusch StartConformanceTestReq    prbOffset      0
	Verify pusch StartConformanceTestReq    ruMode_type    0
    Verify pusch StartConformanceTestReq    ulDmrsMappingType      0

Get Information elements from StartConformanceTestReq message for PUSCH-G TC and verify CB010308 Mappingtype_B
    Log to console                       Checking StartConformanceTestReq OAM-CPRT IE
    Log Variables
    ${start_conf_variables}        run keyword if     '${AirScale}' == 'ASOE'    Get Information Element from L2PS
    ...           ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap      itf_l2_ps_tm_cell_startconformancetestreq
    ...    ELSE     Get Information Element from L2PS     ${CaptureCPRT.path}     itf_l2_ps_tm_cell_startconformancetestreq
    set suite variable       ${start_conf_variables}     ${start_conf_variables}
    Log Variables
    should be true    ${start_conf_variables.reportingTimeInterval} == 0.1
	Verify pusch StartConformanceTestReq_frc    frcIndex    ${frcIndex}
	Verify pusch StartConformanceTestReq    harqEnable     1
	Verify pusch StartConformanceTestReq    prbOffset_receive_test      0
#	Verify pusch StartConformanceTestReq    prbOffset      0
	Verify pusch StartConformanceTestReq    ruMode_type    0
    Verify pusch StartConformanceTestReq    ulDmrsMappingType      1

Get Information elements from StartConformanceTestReq message for PUSCH TC and verify
    [Arguments]         ${frcindex}
    Log to console                       Checking StartConformanceTestReq OAM-CPRT IE
    Log Variables
    ${start_conf_variables}        run keyword if     '${AirScale}' == 'ASOE'    Get Information Element from L2PS
    ...           ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap      itf_l2_ps_tm_cell_startconformancetestreq
    ...    ELSE     Get Information Element from L2PS     ${CaptureCPRT.path}     itf_l2_ps_tm_cell_startconformancetestreq
    set suite variable       ${start_conf_variables}     ${start_conf_variables}
    Log Variables
    should be true    ${start_conf_variables.reportingTimeInterval} == 0.2
	Verify pusch StartConformanceTestReq_frc    frcIndex     ${frcindex}
	Verify pusch StartConformanceTestReq    harqEnable     1
	Verify pusch StartConformanceTestReq    prbOffset_receive_test      0
#	Verify pusch StartConformanceTestReq    prbOffset      0
	Verify pusch StartConformanceTestReq    ruMode_type    0
    Verify pusch StartConformanceTestReq    ulDmrsMappingType      0

Verify pusch StartConformanceTestReq
   [Arguments]      ${key}     ${expected_value}
   ${value}     get from dictionary       ${start_conf_variables}     ${key}
   ${value}     convert to integer      ${value}
   ${value}     convert to string      ${value}
   should be equal      ${value}     ${expected_value}

Verify pusch StartConformanceTestReq_frc
   [Arguments]      ${key}     ${expected_value}
   ${value}     get from dictionary       ${start_conf_variables}     ${key}
   ${value}     verify_frc_index_value  ${value}
#   ${value}     convert to string      ${value}
   should be equal      ${value}     ${expected_value}

Get Information Element from L2PS UCI
    [Arguments]                      ${pcapFile}    ${filter_req}
    ${pdmlFile} =    Get filtered PDML file from pcap    ${pcapFile}    ${filter_req}

    ${packet}        set variable                  itf_l2_ps_tm_cell_StartConformanceTestReq_t

    ${numPucchSymbol}      analyzer.get_unique    pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*numPucchSymbol$
    ...                                           endPacket=${1}

    ${numPayloadBit}      analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*numPayloadBit$
    ...                                           endPacket=${1}

    ${pucchPayloadContent}  analyzer.get_unique   pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*pucchPayloadContent$
    ...                                           endPacket=${1}

    ${pucchFormat}      analyzer.get_unique       pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*pucchFormat$
    ...                                           endPacket=${1}

    ${beamPatternId}      analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*beamPatternIdList_item\\[1\\]
    ...                                           endPacket=${1}

    ${polarization}     analyzer.get_unique       pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*polarization$
    ...                                           endPacket=1

    ${ruMode_type}     analyzer.get_unique        pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*ruMode$
    ...                                           endPacket=1

    ${subFeatureFlag}     analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*subFeatureFlag$
    ...                                           endPacket=1

    ${prbOffset}     analyzer.get_unique                 pdmlFile=${pdmlFile}
    ...                                                  packetName=${packet}
    ...                                                  path=itf_l2_ps_tm_SPucchPerfTestConf.prbOffset
    ...                                                  endPacket=1
    ${prbOffset_receive_test}     analyzer.get_unique                 pdmlFile=${pdmlFile}
    ...                                                  packetName=${packet}
    ...                                                  path=itf_l2_ps_tm_SReceiverTestingConfig.prbOffset
    ...                                                  endPacket=1
    ${harqEnable}     analyzer.get_unique         pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*harqEnable$
    ...                                           endPacket=1

    ${testModel}     analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*testModel$
    ...                                           endPacket=1

    ${i11Codebook4Ant}     analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                            packetName=${packet}
    ...                                            path=.*i11Codebook4AntPorts$
    ...                                            endPacket=1

    ${i2Codebook4Ant}     analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*i2Codebook4AntPorts$
    ...                                                endPacket=1

    ${largestPrbIndex}     analyzer.get_unique         pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*largestPrbIndex$
    ...                                                endPacket=1

    ${ulDmrsMappingType}     analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*ulDmrsMappingType$
    ...                                                endPacket=1
    ${reportingTimeInterval}     analyzer.get_unique         pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*reportingTimeInterval$
    ...                                                endPacket=1

    ${frcIndex}     analyzer.get_unique_showname     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*frcIndex$
    ...                                                endPacket=1
	${numUciBits}     analyzer.get_unique         pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*numUciBits$
    ...                                                endPacket=1

    ${csiPayloadBit-Length}     analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=itf_l2_ps_tm_sreceivertestingconfig.*.Length
    ...                                                endPacket=1
    ${csiPayloadBit_item_0}     analyzer.get_unique         pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=itf_l2_ps_tm_sreceivertestingconfig.*.*csiPayloadBit_item\\[1\\]
    ...                                                endPacket=1

    ${csiPayloadBit_item_1}     analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=itf_l2_ps_tm_sreceivertestingconfig.*.csiPayloadBit_item\\[2\\]
    ...                                                endPacket=1

    &{start_conf_variables}     Create Dictionary       ruMode_type=${ruMode_type}
    ...                                                 largestPrbIndex=${largestPrbIndex}
    ...                                                 pucchFormat=${pucchFormat}
    ...                                                 pucchPayloadContent=${pucchPayloadContent}
    ...                                                 numPayloadBit=${numPayloadBit}
    ...                                                 numPucchSymbol=${numPucchSymbol}
    ...                                                 beamPatternId=${beamPatternId}
    ...                                                 polarization=${polarization}
    ...                                                 prbOffset=${prbOffset}
    ...                                                 harqEnable=${harqEnable}
    ...                                                 i11Codebook4Ant= ${i11Codebook4Ant}
    ...                                                 i2Codebook4Ant=${i2Codebook4Ant}
    ...                                                 largestPrbIndex=${largestPrbIndex}
    ...                                                 ulDmrsMappingType=${ulDmrsMappingType}
    ...                                                 reportingTimeInterval=${reportingTimeInterval}
    ...                                                 frcIndex=${frcIndex}
    ...                                                 numUciBits=${numUciBits}
    ...                                                 csiPayloadBit-Length= ${csiPayloadBit-Length}
    ...                                                 csiPayloadBit_item_0=${csiPayloadBit_item_0}
    ...                                                 csiPayloadBit_item_1=${csiPayloadBit_item_1}
    ...                                                 prbOffset_receive_test=${prbOffset_receive_test}
    [Return]            ${start_conf_variables}
    Log Variables

Get Information Element from L2PS
    [Arguments]                      ${pcapFile}    ${filter_req}
    ${pdmlFile} =    Get filtered PDML file from pcap    ${pcapFile}    ${filter_req}

    ${packet}        set variable                  itf_l2_ps_tm_cell_StartConformanceTestReq_t

    ${numPucchSymbol}      analyzer.get_unique    pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*numPucchSymbol$
    ...                                           endPacket=${1}

    ${numPayloadBit}      analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*numPayloadBit$
    ...                                           endPacket=${1}

    ${pucchPayloadContent}  analyzer.get_unique   pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*pucchPayloadContent$
    ...                                           endPacket=${1}

    ${pucchFormat}      analyzer.get_unique       pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*pucchFormat$
    ...                                           endPacket=${1}

    ${beamPatternId}      analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*beamPatternIdList_item\\[1\\]
    ...                                           endPacket=${1}

    ${polarization}     analyzer.get_unique       pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*polarization$
    ...                                           endPacket=1

    ${ruMode_type}     analyzer.get_unique        pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*ruMode$
    ...                                           endPacket=1

    ${subFeatureFlag}     analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*subFeatureFlag$
    ...                                           endPacket=1

    ${prbOffset}     analyzer.get_unique                 pdmlFile=${pdmlFile}
    ...                                                  packetName=${packet}
    ...                                                  path=itf_l2_ps_tm_SPucchPerfTestConf.prbOffset
    ...                                                  endPacket=1
    ${prbOffset_receive_test}     analyzer.get_unique                 pdmlFile=${pdmlFile}
    ...                                                  packetName=${packet}
    ...                                                  path=itf_l2_ps_tm_SReceiverTestingConfig.prbOffset
    ...                                                  endPacket=1
    ${harqEnable}     analyzer.get_unique         pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*harqEnable$
    ...                                           endPacket=1

    ${testModel}     analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*testModel$
    ...                                           endPacket=1

    ${i11Codebook4Ant}     analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                            packetName=${packet}
    ...                                            path=.*i11Codebook4AntPorts$
    ...                                            endPacket=1

    ${i2Codebook4Ant}     analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*i2Codebook4AntPorts$
    ...                                                endPacket=1

    ${largestPrbIndex}     analyzer.get_unique         pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*largestPrbIndex$
    ...                                                endPacket=1

    ${ulDmrsMappingType}     analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*ulDmrsMappingType$
    ...                                                endPacket=1
    ${reportingTimeInterval}     analyzer.get_unique         pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*reportingTimeInterval$
    ...                                                endPacket=1

    ${frcIndex}     analyzer.get_unique_showname     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*frcIndex$
    ...                                                endPacket=1

    &{start_conf_variables}     Create Dictionary       ruMode_type=${ruMode_type}
    ...                                                 largestPrbIndex=${largestPrbIndex}
    ...                                                 pucchFormat=${pucchFormat}
    ...                                                 pucchPayloadContent=${pucchPayloadContent}
    ...                                                 numPayloadBit=${numPayloadBit}
    ...                                                 numPucchSymbol=${numPucchSymbol}
    ...                                                 beamPatternId=${beamPatternId}
    ...                                                 polarization=${polarization}
    ...                                                 prbOffset=${prbOffset}
    ...                                                 harqEnable=${harqEnable}
    ...                                                 i11Codebook4Ant= ${i11Codebook4Ant}
    ...                                                 i2Codebook4Ant=${i2Codebook4Ant}
    ...                                                 largestPrbIndex=${largestPrbIndex}
    ...                                                 ulDmrsMappingType=${ulDmrsMappingType}
    ...                                                 reportingTimeInterval=${reportingTimeInterval}
    ...                                                 frcIndex=${frcIndex}
    ...                                                 prbOffset_receive_test=${prbOffset_receive_test}
    [Return]            ${start_conf_variables}
    Log Variables


Get Information Elements from DlCell_SetupReq
    [Documentation]         Creates a dictionary containing IE from DL Cell Setup message from OAM
    Log to console                  Checking DL Cell Setup IE
     &{cell_setup_variables}         run keyword if     '${AirScale}' == 'ASOE'    Get IE from DlCellSetup
    ...                             ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap     dlcell_setupreq
    ...                             ELSE    Get IE from DlCellSetup   ${CaptureCPRT.path}    dlcell_setupreq
    set suite variable       &{cell_setup_variables}      &{cell_setup_variables}


Get IE from DlCellSetup
    [Arguments]                      ${pcapFile}    ${filter_req}
    ${pdmlFile} =    Get filtered PDML file from pcap    ${pcapFile}    ${filter_req}
    ${packet}        set variable                  DlCell_SetupReq_t

    ${dlSubcellType}      analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                                  packetName=${packet}
    ...                                                  path=.*dlSubcellType$
    ...                                                  endPacket=1

    ${dlMimomode}        analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                                 packetName=${packet}
    ...                                                 path=.*dlMimoMode$
    ...                                                 endPacket=1

    ${physcellId}        analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                                 packetName=${packet}
    ...                                                 path=.*physCellId$
    ...                                                 endPacket=1

    ${dlBW}             analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                 packetName=${packet}
    ...                                                 path=.*dlBandwidth$
    ...                                                 endPacket=1

    ${SCS}             analyzer.get_unique              pdmlFile=${pdmlFile}
    ...                                                 packetName=${packet}
    ...                                                 path=.*scs$
    ...                                                 endPacket=1

    &{cell_setup_variables}     Create Dictionary       physcellId=${physcellId}        dlBandWith=${dlBW}           scs=${SCS}
    ...    dlSubcellType=${dlSubcellType}    dlMimoMode=${dlMimomode}
    [Return]            &{cell_setup_variables}
    Log Variables


Get Information Elements from UlCell_SetupReq
    [Documentation]         Creates a dictionary containing IE from DL Cell Setup message from OAM
    Log to console                       Checking UL Cell Setup IE

    &{UL_cell_setup_variables}         run keyword if     '${AirScale}' == 'ASOE'   Get IE from UlCellSetup
    ...                             ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap     ulcell_setupreq
    ...                             ELSE    Get IE from UlCellSetup   ${CaptureCPRT.path}    ulcell_setupreq
    set suite variable       &{UL_cell_setup_variables}      &{UL_cell_setup_variables}


Get IE from UlCellSetup
    [Arguments]                      ${pcapFile}    ${filter_req}
    ${pdmlFile} =    Get filtered PDML file from pcap    ${pcapFile}    ${filter_req}
    ${packet}        set variable                  UlCell_SetupReq_t

    ${ulSubcellType}      analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                                  packetName=${packet}
    ...                                                  path=.*ulSubcellType$
    ...                                                  endPacket=1

    ${physcellId}        analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                                 packetName=${packet}
    ...                                                 path=.*physCellId$
    ...                                                 endPacket=1

    ${ulBW}             analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                 packetName=${packet}
    ...                                                 path=.*ulBandwidth$
    ...                                                 endPacket=1

    ${bbselector}       analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                 packetName=${packet}
    ...                                                 path=.*bbSelector$
    ...                                                 endPacket=1

    ${SCS}             analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                 packetName=${packet}
    ...                                                 path=.*scs$
    ...                                                 endPacket=1

    ${prachFormat}       analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                 packetName=${packet}
    ...                                                 path=.*prachFormat$
    ...                                                 endPacket=1

    ${prachConfigurationIndex}             analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                 packetName=${packet}
    ...                                                 path=.*prachConfigurationIndex_item
    ...                                                 endPacket=1

    ${pfaTargetPrachId}             analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                 packetName=${packet}
    ...                                                 path=.*pfaTargetPrachId$
    ...                                                 endPacket=1

    &{UL_cell_setup_variables}     Create Dictionary    physcellId=${physcellId}   ulBandWith=${ulBW}   bbselector=${bbselector}   scs=${SCS}
    ...                           prachFormat=${prachFormat}     prachConfigurationIndex=${prachConfigurationIndex}
    ...                           pfaTargetPrachId=${pfaTargetPrachId}
    [Return]            &{UL_cell_setup_variables}
    Log Variables


Get filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
    ...                             filterName=${filterExp}         filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
    [Return]    ${pdmlFile}


Rnti of each packet returned in a list
    [Arguments]                     ${message}          ${pdmlFile}
    [Documentation]                 returns a list of packets for each rnti value
    @{listpacketMatch}              analyzer.get_match_from_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=${message}
    ...                             path=rnti$
    ...                             startPacket=1
    ...                             endPacket=10
    [return]          @{listpacketMatch}


Clean Old Logs
    [Documentation]                 Clean unnecessary logs created
    Run Keyword And Ignore Error    common_frt.Ssh Execute With Timeout     cd ${tl.core.dir_path} && rm -f *log*    lteemu


Set CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture init		${capture_var_cprt}
	Capture start		${capture_var_cprt}


Set L1L2 capture
    [Arguments]         ${capture_var_l1l2}
    Modify BIP Script File      ${BIP_SCRIPT_PATH}
    Capture init		${capture_var_l1l2}
    Capture start		${capture_var_l1l2}


Stop CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture stop		${capture_var_cprt}


Stop L1L2 capture
    [Arguments]         ${capture_var_l1l2}
    Capture stop		${capture_var_l1l2}


Verify that DlData_SlotTypeReq message contains the correct slot type based on cell technology
    [Arguments]         ${tl_type}=${tl_mode}
    [Documentation]      Verifies the DLDATA_SLOTTYPEREQ message and based on configuration it
    ...                  matches the correct slot type wheter we have FDD/TDD setup

#    ${BIP_pcap}     Set Variable If    '${tl_type}'!='l1b'    BIP_L1L2      AP_BIP_L1L2
#    ${pdmlFile} =     run keyword if     '${AirScale}' == 'ASOE'    Get filtered PDML file from pcap
#    ...               ${LOG_PATH1}/BIP_L1L2.pcap    dldata_slottypereq
#    ...               ELSE   Get filtered PDML file from pcap    ${CaptureL1L2.path}    dldata_slottypereq
    ${pdmlFile} =    Get filtered PDML file from pcap    ${CaptureL1L2.path}    dldata_slottypereq
    Extract and verify the slot type from dldata_slottypereq             ${pdmlFile}


Verify that DlData_SlotTypeReq message contains the correct slot type based on cell technology for TM2 and TM2a
    [Documentation]      Verifies the DLDATA_SLOTTYPEREQ message and based on configuration it
    ...                  matches the correct slot type wheter we have FDD/TDD setup
    ${pdmlFile} =    Get filtered PDML file from pcap    ${CaptureL1L2.path}    dldata_slottypereq
    Extract and verify the slot type from dldata_slottypereq for TM2 and TM2a             ${pdmlFile}

Verify that DlData_SlotTypeReq message contains the correct slot type based on cell technology for TM2 and TM2a 9500
    [Documentation]      Verifies the DLDATA_SLOTTYPEREQ message and based on configuration it
    ...                  matches the correct slot type wheter we have FDD/TDD setup
    ${pdmlFile} =    Get filtered PDML file from pcap    ${CaptureL1L2.path}    dldata_slottypereq
    Extract and verify the slot type from dldata_slottypereq for TM2 and TM2a 9500             ${pdmlFile}



Verify that IE from message matches with encoded message in dictionary
    [Arguments]                    ${message}    ${message_ie_dictionary}    ${pdmlFile}    ${numOfPacket}=1
    [Documentation]               Verifies within message per rnit the value of a specific field and matches it with
    ...                           the corresponding enconded message in the message IE dictionary

    check_information_element_message_decimal     message=${message}
    ...                                           message_ie_dictionary=${message_ie_dictionary}
    ...                                           pdml_file=${pdmlFile}
    ...                                           num_of_packet=${numOfPacket}

Check IE in PUCCH Messages
    [Arguments]                    ${message}    ${message_ie_dictionary}    ${pdmlFile}    ${numOfPacket}=1
    [Documentation]               Verifies within message per rnit the value of a specific field and matches it with
    ...                           the corresponding enconded message in the message IE dictionary

    check_information_element_message_decimal_pucch     message=${message}
    ...                                                 message_ie_dictionary=${message_ie_dictionary}
    ...                                                 pdml_file=${pdmlFile}
    ...                                                 sw_version=${sw_version}
    ...                                                 num_of_packet=${numOfPacket}

Extract and verify the slot type from dldata_slottypereq
    [Arguments]                     ${pdml}
    log to console     Verifies the DLDATA_SLOTTYPEREQ message and checks the slot and slot type
#    ${slotPath}             Set Variable                icom_5g/dldata_slottypereq/DlData_SlotTypeReq_t.slot
#    ${slotTypePath}         Set Variable                icom_5g/dldata_slottypereq/DlData_SlotTypeReq_t.slotType
    ${slotPath}        Set Variable    icom_5g/nr_l1dl_l2ps/dldata_slottypereq/nr_l1dl_l2ps_dldata_slottypereq_t/_3gpp.slot
    ${slotTypePath}    Set Variable    icom_5g/nr_l1dl_l2ps/dldata_slottypereq/nr_l1dl_l2ps_dldata_slottypereq_t/DlData_SlotTypeReq_t.slotType
      @{pathList}        Create list                 ${slotPath}    ${slotTypePath}
    verify_the_slot_type         pdml=${pdml}
    ...                          path_list=${pathList}
    ...                          ru_mode=${start_conf_variables.ruMode_type}
    ...                          scs=${cell_setup_variables.scs}
    ...                          slot_path=${slotPath}
    ...                          slot_type_path=${slotTypePath}

Extract and verify the slot type from dldata_slottypereq for TM2 and TM2a
    [Arguments]                     ${pdml}
    log to console     Verifies the DLDATA_SLOTTYPEREQ message and checks the slot and slot type
    ${slotPath}             Set Variable                icom_5g/dldata_slottypereq/DlData_SlotTypeReq.SlotTypeReq.slot
    ${slotTypePath}         Set Variable                icom_5g/dldata_slottypereq/DlData_SlotTypeReq.SlotTypeReq.slotType
    @{pathList}             Create list                 ${slotPath}$    ${slotTypePath}$

    verify_the_slot_type_tm2_2a         pdml=${pdml}
    ...                          	path_list=${pathList}
    ...                          	ru_mode=${start_conf_variables.ruMode_type}
    ...                          	scs=${cell_setup_variables.scs}
    ...                          	slot_path=${slotPath}
    ...                          	slot_type_path=${slotTypePath}

Extract and verify the slot type from dldata_slottypereq for TM2 and TM2a 9500
    [Arguments]                     ${pdml}
    log to console     Verifies the DLDATA_SLOTTYPEREQ message and checks the slot and slot type
    ${slotPath}        Set Variable    icom_5g/nr_l1dl_l2ps/dldata_slottypereq/nr_l1dl_l2ps_dldata_slottypereq_t/_3gpp.slot
    ${slotTypePath}    Set Variable    icom_5g/nr_l1dl_l2ps/dldata_slottypereq/nr_l1dl_l2ps_dldata_slottypereq_t/DlData_SlotTypeReq_t.slotType
    @{pathList}             Create list                 ${slotPath}$    ${slotTypePath}$

    verify_the_slot_type_tm2_2a         pdml=${pdml}
    ...                          	path_list=${pathList}
    ...                          	ru_mode=${start_conf_variables.ruMode_type}
    ...                          	scs=${cell_setup_variables.scs}
    ...                          	slot_path=${slotPath}
    ...                          	slot_type_path=${slotTypePath}


Fetch gnb software version
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${GNB_SW_VERSION}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}

    run keyword if   '${AirScale}' == 'ASOE'
    ...      Set Suite Variable              ${sw_version}    SBTS00
    ...   ELSE     Set Suite Variable              ${sw_version}     ${GNB_SW_VERSION}

Verify that UlData_PucchReceiveReq message is in accordance with TC assumptions
   [Documentation]        Verifies the IE message from ULDATA_PUCCHRECEIVEREQ message for each format from NR Performance,
   ...                    then matches the incoming content with pre-defined dictionaries containing expected message-fields.
    Log to console              Checking PUCCH IE in Message Decimal
    ${pdmlFile}=         Get filtered PDML file from pcap        ${CaptureL1L2.path}         uldata_pucchreceivereq
    Fetch gnb software version

    ${num_of_prb}           extract_num_of_prb_from_message      ${sw_version}      ${pdmlFile}     UlData_PucchReceiveReq.pucchResources_item_{}
    ${second_hop_prb}       extract_second_hop_prb_based_on_largest_prb_index     ${num_of_prb}         ${start_conf_variables.largestPrbIndex}

    &{DICTONARY_PUCCHRECEIVEREQ_IE_variables}          Create Dictionary
    ...                              UlData_PucchReceiveReq.pucchResources_item_{}.dmrsScramblingSequenceInt=${UL_cell_setup_variables.physcellId}
    ...                              UlData_PucchReceiveReq.pucchResources_item_{}.dataScramblingInt=${UL_cell_setup_variables.physcellId}
    ...                              UlData_PucchReceiveReq.pucchResources_item_{}.pucchFormat=${start_conf_variables.pucchFormat}
    ...                              UlData_PucchReceiveReq.pucchResources_item_{}.numOfBitsOfUciInformation=${start_conf_variables.numPayloadBit}
    ...                              UlData_PucchReceiveReq.pucchResources_item_{}.numOfSymbols=${start_conf_variables.numPucchSymbol}
    ...                              UlData_PucchReceiveReq.pucchResources_item_{}.startPrb=${start_conf_variables.prbOffset}
    ...                              UlData_PucchReceiveReq.pucchResources_item_{}.secondHopPrb=${second_hop_prb}


    &{UL_PUCCHRECEIVEREQ_IE}    Create Dictionary    UlData_PucchReceiveReq.patternId.patternId_item_0=${start_conf_variables.beamPatternId}

    Check IE in PUCCH Messages    UlData_PucchReceiveReq           ${DICTONARY_PUCCHRECEIVEREQ_IE}                   ${pdmlFile}
    Check IE in PUCCH Messages    UlData_PucchReceiveReq           ${DICTONARY_PUCCHRECEIVEREQ_IE_variables}    ${pdmlFile}
    check_beam_pattern    UlData_PucchReceiveReq    ${UL_PUCCHRECEIVEREQ_IE}    ${pdmlFile}    ${start_conf_variables.beamPatternId}

    run keyword if       '${pucch_format_type}'=="F2" and '${format_2}'=='Uci'
    ...                  Check IE in PUCCH Messages    UlData_PucchReceiveReq       ${DICTONARY_PUCCHRECEIVEREQ_F2_UCI_IE}     ${pdmlFile}
    ...     ELSE IF      '${pucch_format_type}'=="F2" and '${format_2}'=='Ack'
    ...                  Check IE in PUCCH Messages    UlData_PucchReceiveReq       ${DICTONARY_PUCCHRECEIVEREQ_F2_ACK_IE}     ${pdmlFile}
    ...     ELSE IF      '${pucch_format_type}'=="F0"
    ...                  Check IE in PUCCH Messages    UlData_PucchReceiveReq       ${DICTONARY_PUCCHRECEIVEREQ_F0_IE}         ${pdmlFile}
    ...     ELSE IF      '${pucch_format_type}'=="F1"
    ...                  Check IE in PUCCH Messages    UlData_PucchReceiveReq       ${DICTONARY_PUCCHRECEIVEREQ_F1_IE}         ${pdmlFile}
    ...     ELSE IF      '${pucch_format_type}'=="F3"
    ...                  Check IE in PUCCH Messages    UlData_PucchReceiveReq       ${DICTONARY_PUCCHRECEIVEREQ_F3_IE}         ${pdmlFile}

    run keyword if      ('${start_conf_variables.numPucchSymbol}'=='1' and '${pucch_format_type}'=="F0")
    ...    Check IE in PUCCH Messages    UlData_PucchReceiveReq    ${DICTONARY_PUCCHRECEIVEREQ_F0_F2_firstSymbol_freqhopping_1}   ${pdmlFile}
    run keyword if      ('${start_conf_variables.numPucchSymbol}'=='1' and '${pucch_format_type}'=="F2")
    ...    Check IE in PUCCH Messages    UlData_PucchReceiveReq    ${DICTONARY_PUCCHRECEIVEREQ_F0_F2_firstSymbol_freqhopping_1}   ${pdmlFile}
    run keyword if      ('${start_conf_variables.numPucchSymbol}'=='2' and '${pucch_format_type}'=="F0")
    ...    Check IE in PUCCH Messages    UlData_PucchReceiveReq    ${DICTONARY_PUCCHRECEIVEREQ_F0_F2_firstSymbol_freqhopping_2}   ${pdmlFile}
    run keyword if      ('${start_conf_variables.numPucchSymbol}'=='2' and '${pucch_format_type}'=="F2")
    ...    Check IE in PUCCH Messages    UlData_PucchReceiveReq    ${DICTONARY_PUCCHRECEIVEREQ_F0_F2_firstSymbol_freqhopping_2}   ${pdmlFile}



    ${DICTONARY_PUCCHRECEIVEREQ_IE_nANPucch}     Create Dictionary
    ...          UlData_PucchReceiveReq.pucchResources_item_{}.nANPucch=${start_conf_variables.numPayloadBit}

    run keyword if      '${format_2}'=='Uci'
    ...    Check IE in PUCCH Messages    UlData_PucchReceiveReq    ${DICTONARY_PUCCHRECEIVEREQ_nANPucch}     ${pdmlFile}
    ...     ELSE IF     '${format_2}'=='Ack'
    ...    Check IE in PUCCH Messages    UlData_PucchReceiveReq    ${DICTONARY_PUCCHRECEIVEREQ_IE_nANPucch}   ${pdmlFile}

    &{DICTONARY_PUCCHRECEIVEREQ_IE_additionalDmrs}   Create Dictionary
    ...         UlData_PucchReceiveReq.pucchResources_item_{}.additionalDmrs=${start_conf_variables.format3AdditionDmrs}

    run keyword if      '${pucch_format_type}'=="F3"
    ...    Check IE in PUCCH Messages    UlData_PucchReceiveReq    ${DICTONARY_PUCCHRECEIVEREQ_IE_additionalDmrs}    ${pdmlFile}

Verify that UlData_PuschReceiveReq message is in accordance with TC assumptions
   [Documentation]        Verifies the IE message from ULDATA_PUSCHRECEIVEREQ message for each format from NR Performance,
   ...                    then matches the incoming content with pre-defined dictionaries containing expected message-fields.
    Log to console              Checking PUSCH IE in Message Decimal

#    ${pdmlFile}=       run keyword if     '${AirScale}' == 'ASOE'    Get filtered PDML file from pcap
#    ...                         ${LOG_PATH1}/AP_BIP_L1L2.pcap         uldata_puschreceivereq
#    ...                 ELSE    Get filtered PDML file from pcap    ${CaptureL1L2.path}        uldata_puschreceivereq

    ${pdmlFile}=       Get filtered PDML file from pcap    ${CaptureL1L2.path}        uldata_puschreceivereq
    &{DICTONARY_PUSCHRECEIVEREQ_IE_variables}          Create Dictionary
    ...        nr_l1ul_l2ps_uldata_puschreceivereqgrant_t\\[1\\].*.startPrb=${start_conf_variables.prbOffset_receive_test}
    ...        nr_l1ul_l2ps_uldata_puschreceivereqgrant_t\\[1\\].*.dmrsScramblingSequenceInt=${UL_cell_setup_variables.physcellId}

    &{DICTONARY_PUSCHRECEIVEREQ_IE_variables_BRANCH}          Create Dictionary
    ...                                      startPrb=${start_conf_variables.prbOffset_receive_test}
    ...                                      dmrsScramblingSequenceInt=${UL_cell_setup_variables.physcellId}

    ${DICT_IE_viables}    set variable if     '${sw_version_trunk}' in '${sw_version}'     ${DICTONARY_PUSCHRECEIVEREQ_IE_variables_BRANCH}
    ...                                                                                    ${DICTONARY_PUSCHRECEIVEREQ_IE_variables}

    ${DICT}    set variable if     '${sw_version_trunk}' in '${sw_version}'     ${DICTONARY_PUSCHRECEIVEREQ_IE_BRANCH}
    ...                                                                         ${DICTONARY_PUSCHRECEIVEREQ_IE}
    Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICT}
    ...                                                                       pdmlFile=${pdmlFile}
    Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICT_IE_viables}
    ...                                                                       pdmlFile=${pdmlFile}

    ${DICT_G_FR1_A2_5}    set variable if     '${sw_version_trunk}' in '${sw_version}'     ${DICTONARY_PUSCHRECEIVEREQ_G_FR1_A2_5_IE_BRANCH}
    ...                                                                         ${DICTONARY_PUSCHRECEIVEREQ_G_FR1_A2_5_IE}

    run keyword if      '${test_model_value}'=='G_FR1_A1_5'
    ...           Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICTONARY_PUSCHRECEIVEREQ_G_FR1_A1_5_IE}
    ...                                                                       pdmlFile=${pdmlFile}
    ...  ELSE IF        '${test_model_value}'=='G_FR1_A2_5'
    ...           Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICT_G_FR1_A2_5}
    ...                                                                       pdmlFile=${pdmlFile}
    ...  ELSE IF        '${test_model_value}'=='G_FR1_A4_31'
    ...           Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICTONARY_PUSCHRECEIVEREQ_G_FR1_A4_31_IE}
    ...                                                                       pdmlFile=${pdmlFile}
    ...  ELSE IF        '${test_model_value}'=='G_FR1_A4_31A'
    ...           Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICTONARY_PUSCHRECEIVEREQ_G_FR1_A4_31A_IE}
    ...                                                                       pdmlFile=${pdmlFile}
    ...  ELSE IF        '${test_model_value}'=='G_FR1_A4_32'
    ...           Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICTONARY_PUSCHRECEIVEREQ_G_FR1_A4_32_IE}
    ...                                                                       pdmlFile=${pdmlFile}
    ...  ELSE IF        '${test_model_value}'=='G_FR1_A4_32A'
    ...           Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICTONARY_PUSCHRECEIVEREQ_G_FR1_A4_32A_IE}
    ...                                                                       pdmlFile=${pdmlFile}

Verify that UlData_PuschReceiveReq message is in accordance with TC assumptions asoe
   [Documentation]        Verifies the IE message from ULDATA_PUSCHRECEIVEREQ message for each format from NR Performance,
   ...                    then matches the incoming content with pre-defined dictionaries containing expected message-fields.
    Log to console              Checking PUSCH IE in Message Decimal

#    ${pdmlFile}=       run keyword if     '${AirScale}' == 'ASOE'    Get filtered PDML file from pcap
#    ...                         ${LOG_PATH1}/AP_BIP_L1L2.pcap         uldata_puschreceivereq
#    ...                 ELSE    Get filtered PDML file from pcap    ${CaptureL1L2.path}        uldata_puschreceivereq

    ${pdmlFile}=       Get filtered PDML file from pcap    ${CaptureL1L2.path}        uldata_puschreceivereq
    ${DICT}    set variable if     '${sw_version_trunk}' in '${sw_version}'     ${DICTONARY_PUSCHRECEIVEREQ_IE_BRANCH}
    ...                                                                         ${DICTONARY_PUSCHRECEIVEREQ_IE_ASOE}
    Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICT}
    ...                                                                       pdmlFile=${pdmlFile}


Verify message DlData_PdcchSendReq for ConformanceTest_A001
    Log to console   Verify message DlData_PdcchSendReq for ConformanceTest_A001

#    ${pdmlFile1}=            run keyword if     '${AirScale}' == 'ASOE'   Get filtered PDML file from pcap
#    ...                            ${LOG_PATH1}/AP_BIP_L1L2.pcap         dldata_pdcchsendreq
#    ...                       ELSE     Get filtered PDML file from pcap  ${CaptureL1L2.path}   dldata_pdcchsendreq
    ${pdmlFile1}=      Get filtered PDML file from pcap    ${CaptureL1L2.path}   dldata_pdcchsendreq
    Fetch gnb software version
    ${DICT}    set variable if     '${sw_version_trunk}' in '${sw_version}'     ${DICTONARY_PDCCHSENDREQ_IE_BRANCH}    ${DICTONARY_PDCCHSENDREQ_IE}
    &{DICTONARY_PDCCHSENDREQ_IE_variables}       Create Dictionary
    ...                                          DlData_DciInfo.polarizationSelection=${start_conf_variables.polarization}
    ...                                          _3gpp.dmrsScramblingSequenceInt=${cell_setup_variables.physcellId}
    ...                                 DlData_DciInfo.patternId_item\\[1\\]=${beampatternchangereq_variables.beamPatternIdList_item_0}
    &{DICTONARY_PDCCHSENDREQ_IE_variables_BRANCH}       Create Dictionary
    ...                                          DlData_PdcchSendReq.dciInfo_item_15.polarizationSelection=${start_conf_variables.polarization}
    ...                                          DlData_PdcchSendReq.dciInfo_item_15.dmrsScramblingSequenceInt=${cell_setup_variables.physcellId}
    ...                                 DlData_PdcchSendReq.patternId.patternId_item_0=${beampatternchangereq_variables.beamPatternIdList_item_0}
    ${DICT_varibales}    set variable if     '${sw_version_trunk}' in '${sw_version}'      ${DICTONARY_PDCCHSENDREQ_IE_variables_BRANCH}
    ...                                                ${DICTONARY_PDCCHSENDREQ_IE_variables}

    Verify that IE from message matches with encoded message in dictionary    message=DlData_PdcchSendReq
    ...                                                                       message_ie_dictionary=${DICT}
    ...                                                                       pdmlFile=${pdmlFile1}
    Verify that IE from message matches with encoded message in dictionary    message=DlData_PdcchSendReq
    ...                                                                       message_ie_dictionary=${DICT_varibales}
    ...                                                                       pdmlFile=${pdmlFile1}

Verify message DlData_PdcchSendReq for ConformanceTest_A001 ABIN 9500
    Log to console   Verify message DlData_PdcchSendReq for ConformanceTest_A001

#    ${pdmlFile1}=            run keyword if     '${AirScale}' == 'ASOE'   Get filtered PDML file from pcap
#    ...                            ${LOG_PATH1}/AP_BIP_L1L2.pcap         dldata_pdcchsendreq
#    ...                       ELSE     Get filtered PDML file from pcap  ${CaptureL1L2.path}   dldata_pdcchsendreq
    ${pdmlFile1}=            Get filtered PDML file from pcap  ${CaptureL1L2.path}   dldata_pdcchsendreq
    Fetch gnb software version
    ${DICT}    set variable if    '${sw_version_trunk}' in '${sw_version}'    ${DICTONARY_PDCCHSENDREQ_IE_BRANCH}    ${DICTONARY_PDCCHSENDREQ_IE_4x4}
    &{DICTONARY_PDCCHSENDREQ_IE_variables}       Create Dictionary
    ...                                          DlData_DciInfo.polarizationSelection=${start_conf_variables.polarization}
    ...                                          _3gpp.dmrsScramblingSequenceInt=${cell_setup_variables.physcellId}
    ...                                 DlData_DciInfo.patternId_item\\[1\\]=${beampatternchangereq_variables.beamPatternIdList_item_0}
    &{DICTONARY_PDCCHSENDREQ_IE_variables_BRANCH}       Create Dictionary
    ...                                          DlData_PdcchSendReq.dciInfo_item_15.polarizationSelection=${start_conf_variables.polarization}
    ...                                          DlData_PdcchSendReq.dciInfo_item_15.dmrsScramblingSequenceInt=${cell_setup_variables.physcellId}
    ...                                 DlData_PdcchSendReq.patternId.patternId_item_0=${beampatternchangereq_variables.beamPatternIdList_item_0}
    ${DICT_varibales}    set variable if     '${sw_version_trunk}' in '${sw_version}'      ${DICTONARY_PDCCHSENDREQ_IE_variables_BRANCH}
    ...                                                ${DICTONARY_PDCCHSENDREQ_IE_variables}

    Verify that IE from message matches with encoded message in dictionary    message=DlData_PdcchSendReq
    ...                                                                       message_ie_dictionary=${DICT}
    ...                                                                       pdmlFile=${pdmlFile1}
    Verify that IE from message matches with encoded message in dictionary    message=DlData_PdcchSendReq
    ...                                                                       message_ie_dictionary=${DICT_varibales}
    ...                                                                       pdmlFile=${pdmlFile1}

Verify message DlData_PdcchSendReq for ConformanceTest_A001 without change beam
    [Arguments]         ${tl_type}=${tl_mode}    ${DICTONARY_PDCCHSENDREQ_IE}=${DICTONARY_PDCCHSENDREQ_IE}
    Log to console   Verify message DlData_PdcchSendReq for ConformanceTest_A001
    ${BIP_pcap}     Set Variable If    '${tl_type}'!='l1b'    BIP_L1L2_ASOE      AP_BIP_L1L2
#   ${pdmlFile1} =     run keyword if     '${AirScale}' == 'ASOE'    Get filtered PDML file from pcap
#   ...               ${LOG_PATH1}/${BIP_pcap}.pcap    dldata_pdcchsendreq
#    ...                       ELSE     Get filtered PDML file from pcap  ${CaptureL1L2.path}   dldata_pdcchsendreq
    ${pdmlFile1} =      Get filtered PDML file from pcap  ${CaptureL1L2.path}   dldata_pdcchsendreq
    Fetch gnb software version
    ${DICT}    set variable if     '${sw_version_trunk}' in '${sw_version}'     ${DICTONARY_PDCCHSENDREQ_IE_BRANCH}    ${DICTONARY_PDCCHSENDREQ_IE}
    &{DICTONARY_PDCCHSENDREQ_IE_variables}       Create Dictionary
    ...                                          polarizationSelection=${start_conf_variables.polarization}
    ...                                          dmrsScramblingSequenceInt=${cell_setup_variables.physcellId}
    ...                                          patternId_item\\[1\\]=${start_conf_variables.beamPatternId}
    &{DICTONARY_PDCCHSENDREQ_IE_variables_BRANCH}       Create Dictionary
    ...                                          DlData_PdcchSendReq.dciInfo_item_15.polarizationSelection=${start_conf_variables.polarization}
    ...                                          DlData_PdcchSendReq.dciInfo_item_15.dmrsScramblingSequenceInt=${cell_setup_variables.physcellId}
    ...                                 DlData_PdcchSendReq.patternId.patternId_item_0=${start_conf_variables.beamPatternId}
    ${DICT_varibales}    set variable if     '${sw_version_trunk}' in '${sw_version}'      ${DICTONARY_PDCCHSENDREQ_IE_variables_BRANCH}
    ...                                          ${DICTONARY_PDCCHSENDREQ_IE_variables}

    Verify that IE from message matches with encoded message in dictionary    message=DlData_PdcchSendReq
    ...                                                                       message_ie_dictionary=${DICT}
    ...                                                                       pdmlFile=${pdmlFile1}
    Verify that IE from message matches with encoded message in dictionary    message=DlData_PdcchSendReq
    ...                                                                       message_ie_dictionary=${DICT_varibales}
    ...                                                                       pdmlFile=${pdmlFile1}

Verify message DlData_PdschSendReq for ConformanceTest_A001
    Log to console  Verify message DlData_PdschSendReq for ConformanceTest_A001
    ${pdmlFile}=            Get filtered PDML file from pcap        ${CaptureL1L2.path}         dldata_pdschsendreq

    ${DICTONARY_PDSCHSENDREQ_IE_variables}    Create Dictionary
    ...                                       dmrsScramblingSequenceInt=${cell_setup_variables.physcellId}
    ${DICTONARY_PDSCHSENDREQ_IE_variables_BRANCH}    Create Dictionary
    ...                                       DlData_PdschSendReq.grants_item_15.dmrsScramblingSequenceInt=${cell_setup_variables.physcellId}
    ${DICT_varibales}    set variable if     '${sw_version_trunk}' in '${sw_version}'     ${DICTONARY_PDSCHSENDREQ_IE_variables_BRANCH}
    ...                                          ${DICTONARY_PDSCHSENDREQ_IE_variables}

    Verify that IE from message matches with encoded message in dictionary    message=dldata_pdschsendreq
    ...                                                                       message_ie_dictionary=${DICT_varibales}
    ...                                                                       pdmlFile=${pdmlFile}
    ${DICT_UE1}    set variable if     '${sw_version_trunk}' in '${sw_version}'      ${DL_PDSCHSENDREQ_TM_FDD_3.3_FR1_IE_5GC002493_UE1_BRANCH}
    ...                                          ${DL_PDSCHSENDREQ_TM_FDD_3.3_FR1_IE_5GC002493_UE1}
    ${DICT_UE2}    set variable if     '${sw_version_trunk}' in '${sw_version}'      ${DL_PDSCHSENDREQ_TM_FDD_3.3_FR1_IE_5GC002493_UE2_BRANCH}
    ...                                          ${DL_PDSCHSENDREQ_TM_FDD_3.3_FR1_IE_5GC002493_UE2}
    ${DICT_UE3}    set variable if     '${sw_version_trunk}' in '${sw_version}'      ${DL_PDSCHSENDREQ_TM_FDD_3.3_FR1_IE_5GC002493_UE3_BRANCH}
    ...                                          ${DL_PDSCHSENDREQ_TM_FDD_3.3_FR1_IE_5GC002493_UE3}

    @{listpacketMatch}=        Rnti of each packet returned in a list          dldata_pdschsendreq           ${pdmlFile}
    verify_information_elements_within_dldata_pdsch_sendreq     ${pdmlFile}
    ...                                                         ${listpacketMatch}
    ...                                                         False
    ...                                                         ${test_model_value}
    ...                                                         ${DICT_UE1}
    ...                                                         ${DICT_UE2}
    ...                                                         ${DICT_UE3}
    ...                                                         1
    ...                                                         2
    ...                                                         3
    ...                                                         20MHz


Verify that UlData_PucchReceiveReq is set in accordance with conformance test - prbOffset and largetPrbIndex verified for ${format_type}-ACK
    Log to console     Verify that UlData_PucchReceiveReq is set in accordance with conformance test


#    ${pdmlFile}=        run keyword if     '${AirScale}' == 'ASOE'    Get filtered PDML file from pcap
#    ...                       ${LOG_PATH1}/AP_BIP_L1L2.pcap      uldata_pucchreceivereq
#    ...       ELSE     Get filtered PDML file from pcap        ${CaptureL1L2.path}         uldata_pucchreceivereq
#    Fetch gnb software version

    ${first_symbol}          extract_first_symbol_based_on_num_of_symbols          ${start_conf_variables.numPucchSymbol}
    ${frequency_hopping}     extract_freq_hopping_based_on_num_of_symbols          ${start_conf_variables.numPucchSymbol}
    ${num_of_prb}            extract_num_of_prb_from_message    ${sw_version}     ${pdmlFileuldata}
    ...        _5g_l1_ul_l2_ps_uldata_pucchreceivereqpucchresource_t
    ${second_hop_prb}        extract_second_hop_prb_based_on_largest_prb_index     ${num_of_prb}         ${start_conf_variables.largestPrbIndex}

    &{DICTONARY_PUCCHRECEIVEREQ_IE_GENERAL}          Create Dictionary
    ...        _5g_l1_ul_l2_ps_uldata_pucchreceivereqpucchresource_t\\[1\\].*.dmrsScramblingSequenceInt=${UL_cell_setup_variables.physcellId}
    ...        _5g_l1_ul_l2_ps_uldata_pucchreceivereqpucchresource_t\\[1\\].*.dataScramblingInt=${UL_cell_setup_variables.physcellId}
    ...        _5g_l1_ul_l2_ps_uldata_pucchreceivereqpucchresource_t\\[1\\].*.startPrb=${start_conf_variables.prbOffset}
    ...        _5g_l1_ul_l2_ps_uldata_pucchreceivereqpucchresource_t\\[1\\].*.nANPucch=${start_conf_variables.numPayloadBit}
    ...        _5g_l1_ul_l2_ps_uldata_pucchreceivereqpucchresource_t\\[1\\].*.numOfBitsOfUciInformation=${start_conf_variables.numPayloadBit}
    ...        _5g_l1_ul_l2_ps_uldata_pucchreceivereqpucchresource_t\\[1\\].*.numOfSymbols=${start_conf_variables.numPucchSymbol}
    ...        _5g_l1_ul_l2_ps_uldata_pucchreceivereqpucchresource_t\\[1\\].*.firstSymbol=${first_symbol}
    ...        _5g_l1_ul_l2_ps_uldata_pucchreceivereqpucchresource_t\\[1\\].*.frequencyHopping=${frequency_hopping}
    ...        _5g_l1_ul_l2_ps_uldata_pucchreceivereqpucchresource_t\\[1\\].*.secondHopPrb=${second_hop_prb}

    &{DICTONARY_PUCCHRECEIVEREQ_IE_GENERAL_BRANCH}          Create Dictionary
    ...                           UlData_PucchReceiveReq.pucchResources_item_15.dmrsScramblingSequenceInt=${UL_cell_setup_variables.physcellId}
    ...                           UlData_PucchReceiveReq.pucchResources_item_15.dataScramblingInt=${UL_cell_setup_variables.physcellId}
    ...                           UlData_PucchReceiveReq.pucchResources_item_15.startPrb=${start_conf_variables.prbOffset}
    ...                           UlData_PucchReceiveReq.pucchResources_item_15.nANPucch=${start_conf_variables.numPayloadBit}
    ...                           UlData_PucchReceiveReq.pucchResources_item_15.numOfBitsOfUciInformation=${start_conf_variables.numPayloadBit}
    ...                           UlData_PucchReceiveReq.pucchResources_item_15.numOfSymbols=${start_conf_variables.numPucchSymbol}
    ...                           UlData_PucchReceiveReq.pucchResources_item_15.firstSymbol=${first_symbol}
    ...                           UlData_PucchReceiveReq.pucchResources_item_15.frequencyHopping=${frequency_hopping}
    ...                           UlData_PucchReceiveReq.pucchResources_item_15.secondHopPrb=${second_hop_prb}
#    ${DICT_general}    set variable if     '${sw_version_trunk}' in '${sw_version}'    ${DICTONARY_PUCCHRECEIVEREQ_IE_GENERAL_BRANCH}
#    ...                             ${DICTONARY_PUCCHRECEIVEREQ_IE_GENERAL}

    # General verification
#    Check IE in PUCCH Messages    UlData_PucchReceiveReq     ${DICT_general}      ${pdmlFileuldata}
     Check IE in PUCCH Messages    UlData_PucchReceiveReq     ${DICTONARY_PUCCHRECEIVEREQ_IE_GENERAL}      ${pdmlFileuldata}
    # Format types-based verification
#    ${DICT_F0}    set variable if     '${sw_version_trunk}' in '${sw_version}'    ${DICTONARY_PUCCHRECEIVEREQ_F0_ACK_IE_5GC002493_BRANCH}
#    ...                             ${DICTONARY_PUCCHRECEIVEREQ_F0_ACK_IE_5GC002493}
#    ${DICT_F2}    set variable if     '${sw_version_trunk}' in '${sw_version}'    ${DICTONARY_PUCCHRECEIVEREQ_F2_ACK_IE_5GC002493_BRANCH}
#    ...                             ${DICTONARY_PUCCHRECEIVEREQ_F2_ACK_IE_5GC002493}
    run keyword if      '${format_type}'=='F0'
    ...       Check IE in PUCCH Messages     UlData_PucchReceiveReq    ${DICTONARY_PUCCHRECEIVEREQ_F0_ACK_IE_5GC002493}    ${pdmlFileuldata}
    ...       ELSE IF   '${format_type}'=='F2'
    ...       Check IE in PUCCH Messages     UlData_PucchReceiveReq    ${DICTONARY_PUCCHRECEIVEREQ_F2_ACK_IE_5GC002493}    ${pdmlFileuldata}

Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements
    Log to console  Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements
    Verify that DlData_SlotTypeReq message contains the correct slot type based on cell technology


Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements for TM2 and TM2a
    Log to console  Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements for TM2 and TM2a
    Verify that DlData_SlotTypeReq message contains the correct slot type based on cell technology for TM2 and TM2a



Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    Log to console              Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    ${pdmlFile}=            run keyword if     '${AirScale}' == 'ASOE'    Get filtered PDML file from pcap
    ...                                        ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap         dlcell_setupreq
    ...                     ELSE     Get filtered PDML file from pcap    ${CaptureCPRT.path}         dlcell_setupreq
    Verify that IE from message matches with encoded message in dictionary    message=DlCell_SetupReq
    ...                                                                       message_ie_dictionary=${DICTIONARY_DLCELL_SETUP_REQ_CL_2x2}
    ...                                                                       pdmlFile=${pdmlFile}

Verify that DlCell_CellSetupReq contains dlMimoMode set to 1 (CL 4x4 or 4x2 MIMO)
    Log to console              Verify that DlCell_CellSetupReq contains dlMimoMode set to 1 (CL 4x4 or 4x2 MIMO)
     ${pdmlFile}=            run keyword if     '${AirScale}' == 'ASOE'    Get filtered PDML file from pcap
    ...                                        ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap         dlcell_setupreq
    ...                     ELSE     Get filtered PDML file from pcap    ${CaptureCPRT.path}         dlcell_setupreq
    Verify that IE from message matches with encoded message in dictionary    message=DlCell_SetupReq
    ...                                                                       message_ie_dictionary=${DICTIONARY_DLCELL_SETUP_REQ_CL_4x4_4x2}
    ...                                                                       pdmlFile=${pdmlFile}

Verify that DlCell_CellSetupReq contains dlMimoMode set to 2 (OL 2x2 MIMO)
    Log to console              Verify that DlCell_CellSetupReq contains dlMimoMode set to 2 (OL 2x2 MIMO)
     ${pdmlFile}=            run keyword if     '${AirScale}' == 'ASOE'    Get filtered PDML file from pcap
    ...                                        ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap         dlcell_setupreq
    ...                     ELSE     Get filtered PDML file from pcap    ${CaptureCPRT.path}         dlcell_setupreq
    Verify that IE from message matches with encoded message in dictionary    message=DlCell_SetupReq
    ...                                                                       message_ie_dictionary=${DICTIONARY_DLCELL_SETUP_REQ_OL_2x2}
    ...                                                                       pdmlFile=${pdmlFile}

Verify that DlCell_CellSetupReq contains dlMimoMode set to 3 (OL 4x4 or 4x2 MIMO)
    Log to console              Verify that DlCell_CellSetupReq contains dlMimoMode set to 3 (OL 4x4 or 4x2 MIMO)
     ${pdmlFile}=            run keyword if     '${AirScale}' == 'ASOE'    Get filtered PDML file from pcap
    ...                                        ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap         dlcell_setupreq
    ...                     ELSE     Get filtered PDML file from pcap    ${CaptureCPRT.path}         dlcell_setupreq
    Verify that IE from message matches with encoded message in dictionary    message=DlCell_SetupReq
    ...                                                                       message_ie_dictionary=${DICTIONARY_DLCELL_SETUP_REQ_OL_4x4_4x2}
    ...                                                                       pdmlFile=${pdmlFile}

Verify that message DlData_PdcchSendReq contains IE values in accordance with conformance test requirements
    Verify message DlData_PdcchSendReq for ConformanceTest_A001

Verify that message DlData_PdcchSendReq contains IE values in accordance with conformance test requirements ABIN 9500
    Verify message DlData_PdcchSendReq for ConformanceTest_A001 ABIN 9500

Verify that DlCell_CellSetupReq contains dlBandwidth set to ${value}
    Log to console              Verify that DlCell_CellSetupReq contains dlbandwidth set to ${value}

     ${pdmlFile}=            run keyword if     '${AirScale}' == 'ASOE'    Get filtered PDML file from pcap
    ...                                        ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap         dlcell_setupreq
    ...                     ELSE     Get filtered PDML file from pcap    ${CaptureCPRT.path}         dlcell_setupreq
    ${hex_value}            convert value to hex      ${value}

    &{DICTIONARY_DLCELL_SETUP_REQ_DL_BANDWIDTH}       Create Dictionary        DlCell_SetupReq_t.dlBandwidth=${hex_value}

    Verify that IE from message matches with encoded message in dictionary    message=DlCell_SetupReq
    ...                                                                       message_ie_dictionary=${DICTIONARY_DLCELL_SETUP_REQ_DL_BANDWIDTH}
    ...                                                                       pdmlFile=${pdmlFile}


Verify message DlData_PdschSendReq based on Test Model Dictionary - ${DICTIONARY} for UE_${ue_id} - BW: ${bw}
    Log to console  Verify message DlData_PdschSendReq based on Test Model Dictionary - ${DICTIONARY} for UE_${ue_id}

#    ${pdmlFile}=          run keyword if     '${AirScale}' == 'ASOE'    Get filtered PDML file from pcap
#    ...                                      ${LOG_PATH1}/BIP_L1L2.pcap         dldata_pdschsendreq
#    ...                    ELSE     Get filtered PDML file from pcap    ${CaptureL1L2.path}    dldata_pdschsendreq
    ${pdmlFile}=      Get filtered PDML file from pcap    ${CaptureL1L2.path}    dldata_pdschsendreq
    Fetch gnb software version
    ${DICT}    set variable    ${DICTIONARY}
    ${DICTIONARY}    set variable if      '${sw_version_trunk}' in '${sw_version}'       ${${DICT}_BRANCH}       ${${DICT}}
    ${DICTONARY_PDSCHSENDREQ_IE_variables}    Create Dictionary
    ...                                       dmrsScramblingSequenceInt=${cell_setup_variables.physcellId}
    ${DICTONARY_PDSCHSENDREQ_IE_variables_BRANCH}    Create Dictionary
    ...                                       dmrsScramblingSequenceInt=${cell_setup_variables.physcellId}
    ${DICTIONARY_variables}    set variable if      '${sw_version_trunk}' in '${sw_version}'      ${DICTONARY_PDSCHSENDREQ_IE_variables_BRANCH}
    ...                                              ${DICTONARY_PDSCHSENDREQ_IE_variables}

    Verify that IE from message matches with encoded message in dictionary    message=dldata_pdschsendreq
    ...                                                                       message_ie_dictionary=${DICTIONARY_variables}
    ...                                                                       pdmlFile=${pdmlFile}

    @{listpacketMatch}=     Rnti of each packet returned in a list          DlData_PdschSendReq              ${pdmlFile}
    verify_information_elements_based_on_same_dictionary        ${pdmlFile}
    ...                                                         ${listpacketMatch}
    ...                                                         ${ue_id}
    ...                                                         ${test_model_value}
    ...                                                         ${DICTIONARY}
    ...                                                         ${DICTIONARY}
    ...                                                         ${DICTIONARY}
    ...                                                         ${bw}

Start Collecting Syslog
    [Arguments]    ${VM_IP}=${tl.test_pc.default_ssh_connection_details.addr}    ${NAME}=5g
    ${ports}=   Create List   51000    51001    51003    50011
    ${CURRENT_SYSLOG_PATH}  Set Variable  ${LOG_PATH}/
    set test variable      ${CURRENT_SYSLOG_PATH}
    Start Syslog  log_dir=${CURRENT_SYSLOG_PATH}  log_name=syslog_${NAME}.log  ip=192.168.255.126
    ...    ssh_username=ute    ssh_password=ute    ports=${ports}  alias=${NAME}

Stop Collecting Syslog
    [Arguments]    ${NAME}=5g
    ${file_path}    Collect Syslog Results    alias=${NAME}
    [Return]      ${file_path}


Check the syslog contain the startconformance test and other parameters for TDD
    [Arguments]    ${logpath}    ${test_model}    ${change_beam}=True
    log to console     Verifying syslog
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A2 "StartConformanceTestReq:"
    FOR   ${item}   IN    @{syslog_parameters_${test_model}_startconformancereq}
        should contain    ${status}    ${item}
    END
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "TCodebook2AntPorts"
    should contain    ${status}    Codebook2AntPorts = 0
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "TI11Codebook4AntPorts"
    should contain    ${status}    TI11Codebook4AntPorts = 0
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "TI13Codebook4AntPorts"
    should contain    ${status}    TI13Codebook4AntPorts = 0
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "TI2Codebook4AntPorts"
    should contain    ${status}    TI2Codebook4AntPorts = 0
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep "Received OK "
    should contain    ${status}    Recv OK StartConformanceTestResp
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep "cp_rt/L2PsStartConformanceTest"
    should contain    ${status}    Received PsTmStartConformanceTestResp ok
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A25 "{testModel: CpRtCm::Definitions"
    FOR   ${item}   IN    @{syslog_parameters_${test_model}_cprt}
        should contain    ${status}    ${item}
    END
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep "scs"
    should contain    ${status}    ${syslog_parameters_${test_model}_scs}
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "PhysCellId"
    should contain    ${status}    ${syslog_parameters_${test_model}_pyscellid}
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "SubFeatureFlag"
    should contain    ${status}    SubFeatureFlag = SF1716_B
    Run Keyword if    '${test_model}' == 'pucch'    Validate pucch parameters in syslog    ${test_model}
    Run Keyword if    '${change_beam}' == 'True'    Validate changebeam id    ${test_model}

Validate pucch parameters in syslog
    [Arguments]     ${test_model}
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "pucchFormat: CpRtCm::Definitions"
    FOR   ${item}   IN    @{syslog_parameters_${test_model}_params}
        should contain    ${status}    ${item}
    END

Validate changebeam id
    [Arguments]     ${test_model}
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A2 "BeamPatternChangeReq:"
    FOR   ${item}   IN    @{syslog_parameters_${test_model}_beamchange}
        should contain    ${status}    ${item}
    END
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A2 "SBeamPatternChangeReq"
    FOR   ${item}   IN    @{syslog_parameters_${test_model}_beamchangereq}
        should contain    ${status}    ${item}
    END

Check the syslog contain the startconformance test and other parameters for FDD
    [Arguments]    ${logpath}     ${test_model}    ${change_beam}=True
    log to console     Verifying syslog
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A2 "StartConformanceTestReq:"
    FOR   ${item}   IN    @{syslog_parameters_${test_model}_startconformancereq}
        should contain    ${status}    ${item}
    END
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep "Received OK "
    should contain    ${status}    Received OK StartConformanceTestResp
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep "cp_rt/L2PsStartConformanceTest"
    should contain    ${status}    Recv PsTmStartConformanceTestResp ok
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "{testModel: CpRtCm::Definitions"
    FOR   ${item}   IN    @{syslog_parameters_${test_model}_cprt}
        should contain    ${status}    ${item}
    END
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep "dlBandwidth"
    should contain    ${status}    ${syslog_parameters_${test_model}_chbwdl}
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep "ulBandwidth"
    should contain    ${status}    ${syslog_parameters_${test_model}_chbwul}
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep "scs"
    should contain    ${status}    ${syslog_parameters_${test_model}_scs}
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "PhysCellId"
    should contain    ${status}    ${syslog_parameters_${test_model}_pyscellid}
    ${status} =   run    command=sudo cat ${logpath}/syslog_5g.log | grep -A4 "SubFeatureFlag"
    should contain    ${status}    SubFeatureFlag = SF1716_B
    Run Keyword if    '${change_beam}' == 'True'    Validate changebeam id    ${test_model}

Verify PN23 sequence for PdschPayloadTbSendReq for testmodel
    [Arguments]                      ${testmodel}
    BuiltIn.Set Test Variable      ${not_expected_1}            00:00:00:00:00:00:00:00:00:00
    BuiltIn.Set Test Variable      ${not_expected_2}            00:00:00:00:00:00:00:00:00:00
    BuiltIn.Set Test Variable      ${not_expected_3}            00:00:00:00:00:00:00:00:00:00
    BuiltIn.Set Test Variable       ${ue1_payload}          'initial'
    BuiltIn.Set Test Variable       ${ue2_payload}          'initial'
    BuiltIn.Set Test Variable       ${pdsch_variables_1}          'initial'
    BuiltIn.Set Test Variable       ${pdsch_variables_2}          'initial'
    Run keyword if          (${testmodel}=='tm3_2' or ${testmodel}=='tm3_3' or ${testmodel}=='tm1_2')
    ...         Get payload IE for 3UEs      ${testmodel}
    ...         ELSE IF       (${testmodel}=='tm2' or ${testmodel}=='tm2_a')
    ...         Get payload IE for 1UE      ${testmodel}
    ...         ELSE       Get payload IE for 2UEs      ${testmodel}
    should not be equal     ${not_expected}     ${pdcch_variables}

Get payload IE for 2UEs
    [Arguments]                      ${testmodel}
    Get Information Elements from DlData_PdschPayloadTbSendReq for 2UEs        ${testmodel}
    ${ue1_payload}=      Get Substring       ${pdsch_variables_1}    0    29
    ${ue2_payload}=      Get Substring       ${pdsch_variables_2}    0    29
    should not be equal     ${not_expected_1}      ${ue1_payload}
    should not be equal     ${not_expected_2}      ${ue2_payload}

Get payload IE for 1UE
    [Arguments]                      ${testmodel}
    Get Information Elements from DlData_PdschPayloadTbSendReq for 1UE        ${testmodel}
    ${ue1_payload}=      Get Substring       ${pdsch_variables_1}    0    29
    should not be equal     ${not_expected_1}     ${ue1_payload}

Get payload IE for 3UEs
    [Arguments]                      ${testmodel}
    Get Information Elements from DlData_PdschPayloadTbSendReq for 3UEs        ${testmodel}
    ${ue1_payload}=      Get Substring       ${pdsch_variables_1}    0    29
    ${ue2_payload}=      Get Substring       ${pdsch_variables_2}    0    29
    should not be equal     ${not_expected_1}      ${ue1_payload}
    should not be equal     ${not_expected_2}      ${ue2_payload}
    ${ue3_payload}=      Get Substring       ${pdsch_variables_3}    0    29
    should not be equal      ${not_expected_3}      ${ue3_payload}

Get Information Elements from DlData_PdschPayloadTbSendReq for 3UEs
    [Arguments]                      ${testmodel}
    [Documentation]         Creates a dictionary containing IE from DlData_PdschPayloadTbSendReq
    Log to console                  Checking DlData_PdschPayloadTbSendReq IE
    ${pdsch_variables_1}     ${pdsch_variables_2}      ${pdsch_variables_3}     Get IE from DlData_PdschPayloadTbSendReq for testmodel for 3UEs
    ...             ${CaptureL1L2.path}      dldata_pdschpayloadtbsendreq       ${testmodel}
    set suite variable       ${pdsch_variables_1}      ${pdsch_variables_1}
    set suite variable       ${pdsch_variables_2}      ${pdsch_variables_2}
    set suite variable       ${pdsch_variables_3}      ${pdsch_variables_3}

Get IE from DlData_PdschPayloadTbSendReq for testmodel for 3UEs
    [Arguments]                      ${pcapFile}    ${filter_req}    ${testmodel}
    ${pdmlFile} =    Get filtered PDML file from pcap    ${pcapFile}    ${filter_req}
    ${packet}        set variable                  DlData_PdschPayloadTbSendReq.payload
    ${Payload_1}      analyzer.get_unique          pdmlFile=${pdmlFile}
      ...                                                  packetName=${packet}
      ...                                                  path=.*payload-Items$
      ...                                                  startPacket=1
      ...                                                  endPacket=1
      ${Payload_2}      analyzer.get_unique          pdmlFile=${pdmlFile}
      ...                                                  packetName=${packet}
      ...                                                  path=.*payload-Items$
      ...                                                  startPacket=2
      ...                                                  endPacket=2
      ${Payload_3}      analyzer.get_unique          pdmlFile=${pdmlFile}
      ...                                                  packetName=${packet}
      ...                                                  path=.*payload-Items$
      ...                                                  startPacket=3
      ...                                                  endPacket=3
      [Return]            ${Payload_1}        ${Payload_2}      ${Payload_3}

Get Information Elements from DlData_PdschPayloadTbSendReq for 2UEs
    [Arguments]                      ${testmodel}
    [Documentation]         Creates a dictionary containing IE from DlData_PdschPayloadTbSendReq
    Log to console                  Checking DlData_PdschPayloadTbSendReq IE
    ${pdsch_variables_1}     ${pdsch_variables_2}          Get IE from DlData_PdschPayloadTbSendReq for testmodel for 2UEs
    ...        ${CaptureL1L2.path}      dldata_pdschpayloadtbsendreq       ${testmodel}
    set suite variable       ${pdsch_variables_1}      ${pdsch_variables_1}
    set suite variable       ${pdsch_variables_2}      ${pdsch_variables_2}

Get IE from DlData_PdschPayloadTbSendReq for testmodel for 2UEs
    [Arguments]                      ${pcapFile}    ${filter_req}    ${testmodel}
    ${pdmlFile} =    Get filtered PDML file from pcap    ${pcapFile}    ${filter_req}
    ${packet}        set variable                  DlData_PdschPayloadTbSendReq.payload
    ${Payload_1}      analyzer.get_unique          pdmlFile=${pdmlFile}
      ...                                                  packetName=${packet}
      ...                                                  path=.*payload-Items$
      ...                                                  startPacket=1
      ...                                                  endPacket=1
      ${Payload_2}      analyzer.get_unique          pdmlFile=${pdmlFile}
      ...                                                  packetName=${packet}
      ...                                                  path=.*payload-Items$
      ...                                                  startPacket=2
      ...                                                  endPacket=2
      [Return]            ${Payload_1}        ${Payload_2}

Get Information Elements from DlData_PdschPayloadTbSendReq for 1UE
    [Arguments]                      ${testmodel}
    [Documentation]         Creates a dictionary containing IE from DlData_PdschPayloadTbSendReq
    Log to console                  Checking DlData_PdschPayloadTbSendReq IE
    ${pdsch_variables_1}          Get IE from DlData_PdschPayloadTbSendReq for testmodel for 1UE     ${CaptureL1L2.path}
    ...            dldata_pdschpayloadtbsendreq       ${testmodel}
    set suite variable       ${pdsch_variables_1}      ${pdsch_variables_1}


Get IE from DlData_PdschPayloadTbSendReq for testmodel for 1UE
    [Arguments]                      ${pcapFile}    ${filter_req}    ${testmodel}
    ${pdmlFile} =    Get filtered PDML file from pcap    ${pcapFile}    ${filter_req}
    ${packet}        set variable                  DlData_PdschPayloadTbSendReq.payload
    ${Payload_1}      analyzer.get_unique          pdmlFile=${pdmlFile}
      ...                                                  packetName=${packet}
      ...                                                  path=.*payload-Items$
      ...                                                  startPacket=1
      ...                                                  endPacket=1
      [Return]            ${Payload_1}

Verify PN23 sequence for PdcchSendReq
    Get Information Elements from DlData_PdcchSendReq
    BuiltIn.Set Test Variable      ${not_expected}        00:00:00:00:00:00
    should not be equal     ${not_expected}          ${pdcch_variables}
#    should be equal        ${not_expected}         ${pdcch_variables}

Get Information Elements from DlData_PdcchSendReq
    [Documentation]         Creates a dictionary containing IE from DlData_PdcchSendReq
    Log to console                  Checking DlData_PdcchSendReq IE
#    &{pdcch_variables}         Get IE from DlData_PdcchSendReq     ${CaptureL1L2.path}     dldata_pdcchsendreq

    ${pdcch_variables}        run keyword if     '${AirScale}' == 'ASOE'    Get IE from DlData_PdcchSendReq
    ...                                     ${LOG_PATH1}/AP_BIP_L1L2.pcap      dldata_pdcchsendreq
    ...                        ELSE    Get IE from DlData_PdcchSendReq    ${CaptureL1L2.path}    dldata_pdcchsendreq
    set suite variable       ${pdcch_variables}      ${pdcch_variables}

Get IE from DlData_PdcchSendReq
    [Arguments]                      ${pcapFile}    ${filter_req}
    ${pdmlFile} =    Get filtered PDML file from pcap    ${pcapFile}    ${filter_req}
    ${packet}        set variable                  _5g_l1_dl_l2_ps_dldata_dciep

    ${dciPayload_item}      analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                  packetName=${packet}
    ...                                                  path=.*dci.dci10$
    ...                                                  endPacket=1
    [Return]            ${dciPayload_item}

uldata_receivereq of each packet returned in a list
    [Arguments]                     ${message}          ${pdmlFile}
    [Documentation]                 returns a list of packets for each uldata_pucchreceivereq
    @{listpacketMatch}              analyzer.get_match_from_paths
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=${message}
    ...                             pathList=${FIELDS_PUCCH_RESP}
    ...                             startPacket=1
    ...                             endPacket=-1
    [return]          @{listpacketMatch}

Verify that ULData_PucchReceiveReq message contains the correct slot type based on recieving slot set
    [Documentation]      Verifies the DLDATA_SLOTTYPEREQ message and based on configuration it
    ...                  matches the correct slot

#    ${pdmlFile} =     run keyword if     '${AirScale}' == 'ASOE'    Get filtered PDML file from pcap
#    ...                       ${LOG_PATH1}/AP_BIP_L1L2.pcap     uldata_pucchreceivereq
#    ...                ELSE     Get filtered PDML file from pcap   ${CaptureL1L2.path}    uldata_pucchreceivereq
    ${pdmlFile} =     Get filtered PDML file from pcap   ${CaptureL1L2.path}    uldata_pucchreceivereq
    Set Suite Variable     ${pdmlFileuldata}       ${pdmlFile}
    @{list_of_values}    uldata_receivereq of each packet returned in a list     uldata_pucchreceivereq    ${pdmlFileuldata}
    FOR      ${slot_packet}     IN      @{list_of_values}
        ${slot}               Get Value In Packet Match
       ...                   packetMatch=${slot_packet}
       ...                   field=slot
       ${slot}       Convert To Integer      ${slot}
       should be true      ${slot} == 18 or ${slot} == 19
    END
    ${sfn_packet}    Get Value In Packet Match
    ...                   packetMatch=@{list_of_values}[0]
    ...                   field=sfn
    ${sfn_packet}       Convert To Integer      ${sfn_packet}
    Should be true       (${sfn_packet} % 2) == 0

Verify that ULData_PucchReceiveReq message contains the correct slot type based on recieving slot set CB008444 PUCCH
    [Documentation]      Verifies the DLDATA_SLOTTYPEREQ message and based on configuration it
    ...                  matches the correct slot

#    ${pdmlFile} =     run keyword if     '${AirScale}' == 'ASOE'    Get filtered PDML file from pcap
#    ...                       ${LOG_PATH1}/AP_BIP_L1L2.pcap     uldata_pucchreceivereq
#    ...                ELSE     Get filtered PDML file from pcap   ${CaptureL1L2.path}    uldata_pucchreceivereq
    ${pdmlFile} =     Get filtered PDML file from pcap   ${CaptureL1L2.path}    uldata_pucchreceivereq
    @{list_of_values}    uldata_receivereq of each packet returned in a list     uldata_pucchreceivereq    ${pdmlFile}
    FOR      ${slot_packet}     IN      @{list_of_values}
        ${slot}               Get Value In Packet Match
       ...                   packetMatch=${slot_packet}
       ...                   field=slot
       ${slot}       Convert To Integer      ${slot}
       should be true      ${slot} == 3 or ${slot} == 3
    END
    ${sfn_packet}    Get Value In Packet Match
    ...                   packetMatch=@{list_of_values}[0]
    ...                   field=sfn
    ${sfn_packet}       Convert To Integer      ${sfn_packet}
    Should be true       (${sfn_packet} % 2) == 0

Verify that ULData_PrachReceiveReq message contains the correct slot type based on recieving slot set
    [Documentation]      Verifies the DLDATA_SLOTTYPEREQ message and based on configuration it
    ...                  matches the correct slot
    ${pdmlFile} =    run keyword if     '${AirScale}' == 'ASOE'     Get filtered PDML file from pcap
    ...         ${LOG_PATH1}/AP_BIP_L1L2.pcap   uldata_prachreceivereq
    ...         ELSE    Get filtered PDML file from pcap       ${CaptureL1L2.path}    uldata_prachreceivereq
    @{list_of_values}    uldata_receivereq of each packet returned in a list     uldata_prachreceivereq     ${pdmlFile}
    FOR      ${slot_packet}     IN      @{list_of_values}
        ${slot}               Get Value In Packet Match
       ...                   packetMatch=${slot_packet}
       ...                   field=slot
       ${slot}       Convert To Integer      ${slot}
       should be true      ${slot} == 19
    END
    ${sfn_packet}    Get Value In Packet Match
    ...                   packetMatch=@{list_of_values}[0]
    ...                   field=sfn
    ${sfn_packet}       Convert To Integer      ${sfn_packet}
    Run Keyword and Ignore Error    Should be true       (${sfn_packet} % 2) == 0

Verify that ULData_PrachReceiveReq message contains the correct slot type based on recieving slot set CB008444
    [Documentation]      Verifies the DLDATA_SLOTTYPEREQ message and based on configuration it
    ...                  matches the correct slot
    ${pdmlFile} =    run keyword if     '${AirScale}' == 'ASOE'     Get filtered PDML file from pcap
    ...         ${LOG_PATH1}/AP_BIP_L1L2.pcap   uldata_prachreceivereq
    ...         ELSE    Get filtered PDML file from pcap    ${CaptureL1L2.path}    uldata_prachreceivereq
    @{list_of_values}    uldata_receivereq of each packet returned in a list     uldata_prachreceivereq     ${pdmlFile}
    FOR      ${slot_packet}     IN      @{list_of_values}
        ${slot}               Get Value In Packet Match
       ...                   packetMatch=${slot_packet}
       ...                   field=slot
       ${slot}       Convert To Integer      ${slot}
       should be true      ${slot} == 3
    END
    ${sfn_packet}    Get Value In Packet Match
    ...                   packetMatch=@{list_of_values}[0]
    ...                   field=sfn
    ${sfn_packet}       Convert To Integer      ${sfn_packet}
    Run Keyword and Ignore Error    Should be true       (${sfn_packet} % 2) == 0


Verify that StartConformance message contains the correct 8 bits for Receiving slot and Expection slot

    ${pdmlFile} =     run keyword if     '${AirScale}' == 'ASOE'     Get filtered PDML file from pcap
    ...         ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap     itf_l2_ps_tm_cell_startconformancetestreq
    ...        ELSE    Get filtered PDML file from pcap     ${CaptureCPRT.path}     itf_l2_ps_tm_cell_startconformancetestreq
    Set Test Variable    ${slot0_bits}     0x30
    Set Test Variable    ${slot1_bits}     0xc0
    Bits should be equal    ${pdmlFile}    itf_l2_ps_tm_TSlotsPattern.byte     ${slot0_bits}      1
    Bits should be equal    ${pdmlFile}    itf_l2_ps_tm_TSlotsPattern.byte     ${slot1_bits}      2
    Bits should be equal    ${pdmlFile}    itf_l2_ps_tm_TSlotsPattern.byte     ${slot0_bits}      4
    Bits should be equal    ${pdmlFile}    itf_l2_ps_tm_TSlotsPattern.byte     ${slot1_bits}      5

Verify that prach StartConformance message contains the correct 8 bits for Receiving slot and Expection slot
    ${pdmlFile} =    run keyword if     '${AirScale}' == 'ASOE'     Get filtered PDML file from pcap
    ...     ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap     itf_l2_ps_tm_cell_startconformancetestreq
    ...     ELSE    Get filtered PDML file from pcap    ${CaptureCPRT.path}     itf_l2_ps_tm_cell_startconformancetestreq
    Set Test Variable    ${slot0_bits}     0x11
    Set Test Variable    ${slot1_bits}     0x00
    Bits should be equal    ${pdmlFile}    itf_l2_ps_tm_TSlotsPattern.byte     ${slot0_bits}      1
    Bits should be equal    ${pdmlFile}    itf_l2_ps_tm_TSlotsPattern.byte     ${slot1_bits}      2
    Bits should be equal    ${pdmlFile}    itf_l2_ps_tm_TSlotsPattern.byte     ${slot0_bits}      4
    Bits should be equal    ${pdmlFile}    itf_l2_ps_tm_TSlotsPattern.byte     ${slot1_bits}      5

Verify that prach StartConformance message contains the correct 8 bits for Receiving slot and Expection slot CB008444
    ${pdmlFile} =    run keyword if     '${AirScale}' == 'ASOE'     Get filtered PDML file from pcap
    ...     ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap     itf_l2_ps_tm_cell_startconformancetestreq
    ...     ELSE    Get filtered PDML file from pcap    ${CaptureCPRT.path}     itf_l2_ps_tm_cell_startconformancetestreq
    Set Test Variable    ${slot0_bits}     0x10
    Set Test Variable    ${slot1_bits}     0x00
    Bits should be equal    ${pdmlFile}    itf_l2_ps_tm_TSlotsPattern.byte    ${slot0_bits}     1
    Bits should be equal    ${pdmlFile}    itf_l2_ps_tm_TSlotsPattern.byte    ${slot1_bits}     2
    Bits should be equal    ${pdmlFile}    itf_l2_ps_tm_TSlotsPattern.byte    ${slot0_bits}     4
    Bits should be equal    ${pdmlFile}    itf_l2_ps_tm_TSlotsPattern.byte    ${slot1_bits}     5

Bits should be equal
    [Arguments]    ${pdmlfile}    ${grep_string}    ${slot_bits}       ${index}
    ${value} =   run    command=sudo cat ${pdmlFile} | grep "${grep_string}"
    ${string}=    Split String    ${value}     :
    ${expected_bits}    Get Substring    ${string}[${index}]    1    5
    should be equal     ${expected_bits}     ${slot_bits}

Verify the Reporting Time Interval between the MeasurementRepInd messages
    [Arguments]      ${reporting_time}
    @{time_list}=    Create List

    ${pdmlFile} =      run keyword if     '${AirScale}' == 'ASOE'     Get filtered PDML file from pcap
    ...                 ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap       itf_l2_ps_tm_cell_measurementreportind
    ...             ELSE   Get filtered PDML file from pcap  ${CaptureCPRT.path}     itf_l2_ps_tm_cell_measurementreportind
    @{listpacketMatch}              analyzer.get_match_from_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=itf_l2_ps_tm_cell_measurementreportind
    ...                             path=timestamp
    ...                             startPacket=1
    ...                             endPacket=-1
    FOR      ${time_packet}     IN      @{listpacketMatch}
        ${time}               Get Value In Packet Match
       ...                   packetMatch=${time_packet}
       ...                   field=timestamp
       ${time}       Split String      ${time}
       ${time}       DateTime.Convert Time    ${time}[3]
       Append To List    ${time_list}    ${time}
    END
    FOR     ${time}     IN RANGE     (len(${time_list})-1)
        ${step1_index}    evaluate   ${time} + 1
        ${time_diff}=    evaluate    (${time_list}[${step1_index}]) - (${time_list}[${time}])
        ${roundoff_time}    convert to number    ${time_diff}     1
        ${expected_reporting_time}    convert to string    ${roundoff_time}
        should be equal     ${expected_reporting_time}    ${reporting_time}
    END

Get Information Elements from cellsetupreq message and verify prach parameters
    [Arguments]      ${bandwidth}
    [Documentation]         Creates a dictionary containing IE from cell Setup message from OAM
    Log to console                 Checking Cell Setup Req IE
    &{cellsetup_varibles_expected}     create dictionary      cell_technology=1    ul_mimo_mode=20   dl_mimo_mode=30
    ...       phycellid=67     dlbandwidth=${bandwidth}    ulbandwidth=${bandwidth}     prach_configuration_index=87
    ...       actUlDftSOfdm=0
    &{cell_setup_variables}           Get IE from cellsetupreq     ${CaptureCPRT.path}     ${Filter_cellsetupreq}
    set suite variable       &{cell_setup_variables}      &{cell_setup_variables}
    Dictionaries Should Be Equal     ${cellsetup_varibles_expected}     ${cell_setup_variables}

Get Information Elements from cellsetupreq message and verify prach parameters CB008444
    [Arguments]      ${bandwidth}
    [Documentation]         Creates a dictionary containing IE from cell Setup message from OAM
    Log to console                 Checking Cell Setup Req IE
    &{cellsetup_varibles_expected}     create dictionary      cell_technology=0    ul_mimo_mode=20   dl_mimo_mode=50
    ...       phycellid=0x00000032     dlbandwidth=${bandwidth}    ulbandwidth=${bandwidth}     prach_configuration_index=0x0000000c
    ...       actUlDftSOfdm=0x00000000
    &{cell_setup_variables}           Run Keyword If    '${AirScale}' == 'ASOE'    Get IE from cellsetupreq
    ...      ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap      ${Filter_cellsetupreq}
    ...      ELSE     Get IE from cellsetupreq      ${CaptureCPRT.path}     ${Filter_cellsetupreq}
    set suite variable       &{cell_setup_variables}      &{cell_setup_variables}
    Dictionaries Should Be Equal     ${cellsetup_varibles_expected}     ${cell_setup_variables}

Get Information Elements from cellsetupreq message and verify pusch-c parameters
    [Documentation]         Creates a dictionary containing IE from cell Setup message from OAM
    Log to console                 Checking Cell Setup Req IE
    &{cellsetup_varibles_expected}     create dictionary      cell_technology=0    ul_mimo_mode=20   dl_mimo_mode=30
    ...       phycellid=50     dlbandwidth=25    ulbandwidth=25    prach_configuration_index=12       actUlDftSOfdm=1
    &{cell_setup_variables}           Get IE from cellsetupreq     ${CaptureCPRT.path}      ${Filter_cellsetupreq}
    set suite variable       &{cell_setup_variables}      &{cell_setup_variables}
    Dictionaries Should Be Equal     ${cellsetup_varibles_expected}     ${cell_setup_variables}


Get Information Elements from cellsetupreq message and verify pusch-g parameters
    [Documentation]         Creates a dictionary containing IE from cell Setup message from OAM
    Log to console                 Checking Cell Setup Req IE
    &{cellsetup_varibles_expected}     create dictionary      cell_technology=1    ul_mimo_mode=20   dl_mimo_mode=30
    ...       phycellid=50     dlbandwidth=273    ulbandwidth=273    prach_configuration_index=0x5d      actUlDftSOfdm=1
    &{cell_setup_variables}     run keyword if    '${AirScale}' == 'ASOE'   Get IE from cellsetupreq    ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap
    ...    ${Filter_cellsetupreq}
    ...    ELSE    Get IE from cellsetupreq       ${CaptureCPRT.path}     ${Filter_cellsetupreq}
    set suite variable       &{cell_setup_variables}      &{cell_setup_variables}
    Dictionaries Should Be Equal     ${cellsetup_varibles_expected}     ${cell_setup_variables}

Get Information Elements from cellsetupreq message and verify pusch-g parameters CB9500
    [Documentation]         Creates a dictionary containing IE from cell Setup message from OAM
    Log to console                 Checking Cell Setup Req IE
    &{cellsetup_varibles_expected}     create dictionary      cell_technology=1    ul_mimo_mode=20   dl_mimo_mode=30
    ...       phycellid=50     dlbandwidth=24    ulbandwidth=24    prach_configuration_index=93      actUlDftSOfdm=1
    &{cell_setup_variables}     run keyword if    '${AirScale}' == 'ASOE'   Get IE from cellsetupreq    ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap
    ...    ${Filter_cellsetupreq}
    ...    ELSE    Get IE from cellsetupreq       ${CaptureCPRT.path}     ${Filter_cellsetupreq}
    set suite variable       &{cell_setup_variables}      &{cell_setup_variables}
    Dictionaries Should Be Equal     ${cellsetup_varibles_expected}     ${cell_setup_variables}


Get Information Elements from cellsetupreq message and verify pusch-a parameters
    [Arguments]      ${dlbandwidth}     ${ulbandwidth}
    [Documentation]         Creates a dictionary containing IE from cell Setup message from OAM
    Log to console                 Checking Cell Setup Req IE
    &{cellsetup_varibles_expected}     create dictionary      cell_technology=1    ul_mimo_mode=20   dl_mimo_mode=30
    ...       phycellid=50     dlbandwidth=${dlbandwidth}    ulbandwidth=${ulbandwidth}
    ...       actUlDftSOfdm=1
    &{cell_setup_variables}     run keyword if    '${AirScale}' == 'ASOE'   Get IE from cellsetupreq pusch-a    ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap
    ...    ${Filter_cellsetupreq}
    ...    ELSE    Get IE from cellsetupreq pusch-a       ${CaptureCPRT.path}     ${Filter_cellsetupreq}
    set suite variable       &{cell_setup_variables}      &{cell_setup_variables}
    Dictionaries Should Be Equal     ${cellsetup_varibles_expected}     ${cell_setup_variables}

Get Information Elements from cellsetupreq message and verify pusch-a1 parameters
    [Arguments]      ${dlbandwidth}     ${ulbandwidth}
    [Documentation]         Creates a dictionary containing IE from cell Setup message from OAM
    Log to console                 Checking Cell Setup Req IE
    &{cellsetup_varibles_expected}     create dictionary      cell_technology=1    ul_mimo_mode=20   dl_mimo_mode=30
    ...       phycellid=50     dlbandwidth=${dlbandwidth}    ulbandwidth=${ulbandwidth}
    ...       actUlDftSOfdm=0
    &{cell_setup_variables}     run keyword if    '${AirScale}' == 'ASOE'   Get IE from cellsetupreq pusch-a    ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap
    ...    ${Filter_cellsetupreq}
    ...    ELSE    Get IE from cellsetupreq pusch-a       ${CaptureCPRT.path}     ${Filter_cellsetupreq}
    set suite variable       &{cell_setup_variables}      &{cell_setup_variables}
    Dictionaries Should Be Equal     ${cellsetup_varibles_expected}     ${cell_setup_variables}
Get Information Elements from cellsetupreq message and verify pusch-a-fdd parameters
    [Arguments]      ${dlbandwidth}     ${ulbandwidth}
    [Documentation]         Creates a dictionary containing IE from cell Setup message from OAM
    Log to console                 Checking Cell Setup Req IE
    &{cellsetup_varibles_expected}     create dictionary      cell_technology=0    ul_mimo_mode=20   dl_mimo_mode=30
    ...       phycellid=50     dlbandwidth=${dlbandwidth}    ulbandwidth=${ulbandwidth}
    ...       actUlDftSOfdm=1
    &{cell_setup_variables}           Get IE from cellsetupreq pusch-a     ${CaptureCPRT.path}      ${Filter_cellsetupreq}
    set suite variable       &{cell_setup_variables}      &{cell_setup_variables}
    Dictionaries Should Be Equal     ${cellsetup_varibles_expected}     ${cell_setup_variables}

Get IE from cellsetupreq
    [Arguments]                   ${pcapFile}    ${filter_req}
    ${pdmlFile} =    Get filtered PDML file from pcap           ${pcapFile}     ${filter_req}
    ${packet}        set variable                  itf_l2_ps_cell_cellsetupreq

    ${cell_technology}      analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*cellTechnology$
    ...                                                endPacket=${1}

    ${ul_mimo_mode}     analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*ulMimoMode$
    ...                                                endPacket=1

    ${dl_mimo_mode}     analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*dlMimoMode$
    ...                                                endPacket=1

    ${phycellid}     analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*physCellId$
    ...                                                endPacket=1

    ${dlbandwidth}     analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*dlBandwidth$
    ...                                                endPacket=1

    ${ulbandwidth}     analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*ulBandwidth$
    ...                                                endPacket=1

    ${prach_configuration_index}     analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*prachConfigurationIndex$
    ...                                                endPacket=1

    ${actUlDftSOfdm}      analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*actUlDftSOfdm$
    ...                                                endPacket=${1}

    &{cellsetup_variables}     Create Dictionary         cell_technology=${cell_technology}
    ...                                                   ul_mimo_mode=${ul_mimo_mode}
    ...                                                   dl_mimo_mode=${dl_mimo_mode}
    ...                                                   phycellid=${phycellid}
    ...                                                   dlbandwidth=${dlbandwidth}
    ...                                                   ulbandwidth=${ulbandwidth}
    ...                                                   prach_configuration_index=${prach_configuration_index}
    ...                                                   actUlDftSOfdm=${actUlDftSOfdm}

    [Return]            ${cellsetup_variables}
    Log Variables

Get IE from cellsetupreq pusch-a
    [Arguments]                   ${pcapFile}    ${filter_req}
    ${pdmlFile} =    Get filtered PDML file from pcap           ${pcapFile}     ${filter_req}
    ${packet}        set variable                  itf_l2_ps_cell_cellsetupreq

    ${cell_technology}      analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*cellTechnology$
    ...                                                endPacket=${1}

    ${ul_mimo_mode}     analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*ulMimoMode$
    ...                                                endPacket=1

    ${dl_mimo_mode}     analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*dlMimoMode$
    ...                                                endPacket=1

    ${phycellid}     analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*physCellId$
    ...                                                endPacket=1

    ${dlbandwidth}     analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*dlBandwidth$
    ...                                                endPacket=1

    ${ulbandwidth}     analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*ulBandwidth$
    ...                                                endPacket=1

    ${actUlDftSOfdm}      analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*actUlDftSOfdm$
    ...                                                endPacket=${1}

    &{cellsetup_variables}     Create Dictionary         cell_technology=${cell_technology}
    ...                                                   ul_mimo_mode=${ul_mimo_mode}
    ...                                                   dl_mimo_mode=${dl_mimo_mode}
    ...                                                   phycellid=${phycellid}
    ...                                                   dlbandwidth=${dlbandwidth}
    ...                                                   ulbandwidth=${ulbandwidth}
    ...                                                   actUlDftSOfdm=${actUlDftSOfdm}

    [Return]            ${cellsetup_variables}
    Log Variables



Get Information Elements from Beampatternchangereq and verify
    [Arguments]         ${direction}      @{beampatternlist}
    [Documentation]         Creates a dictionary containing IE from cell Setup message from OAM
    Log to console                       Checking Beampatternchangereq
    &{beampatternchangereq_variables}      run keyword if     '${AirScale}' == 'ASOE'     Get IE from Beampatternchangereq
    ...      ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap     itf_l2_ps_tm_cell_beampatternchangereq
    ...        ELSE      Get IE from Beampatternchangereq     ${CaptureCPRT.path}     itf_l2_ps_tm_cell_beampatternchangereq
    set suite variable       &{beampatternchangereq_variables}      &{beampatternchangereq_variables}
    ${direction_pdml}=    Get From Dictionary      ${beampatternchangereq_variables}    direction
    Should be equal     ${direction_pdml}     ${direction}
    ${beampattern0}=    Get From Dictionary      ${beampatternchangereq_variables}    beamPatternIdList_item_0
    ${beampattern0}=    convert to Integer      ${beampattern0}
    ${beampatternlist0}    get from list      @{beampatternlist}     0
    Should be equal     ${beampattern0}      ${beampatternlist0}
    ${beampattern1}=    Get From Dictionary      ${beampatternchangereq_variables}    beamPatternIdList_item_1
    ${beampattern1}=    convert to Integer      ${beampattern0}
    ${beampatternlist1}    get from list      @{beampatternlist}     1
    Should be equal     ${beampattern1}      ${beampatternlist1}

Get IE from Beampatternchangereq
    [Arguments]                   ${pcapFile}      ${filter_req}
    ${pdmlFile} =    Get filtered PDML file from pcap    ${pcapFile}    ${filter_req}
    ${packet}        set variable                  itf_l2_ps_tm_cell_beampatternchangereq_t

    ${direction}      analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*direction$
    ...                                                endPacket=${1}

    ${beamPatternIdList_item_0}     analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                                            packetName=${packet}
    ...                                                            path=.*beamPatternIdList_item\\[1\\]
    ...                                                            endPacket=1

    ${beamPatternIdList_item_1}     analyzer.get_unique             pdmlFile=${pdmlFile}
    ...                                                             packetName=${packet}
    ...                                                             path=.*beamPatternIdList_item\\[2\\]
    ...                                                             endPacket=1

    &{beampatternchangereq_variables}     Create Dictionary         direction=${direction}
    ...                                                   beamPatternIdList_item_0=${beamPatternIdList_item_0}
    ...                                                   beamPatternIdList_item_1=${beamPatternIdList_item_1}
    set suite variable      &{beampatternchangereq_variables}     &{beampatternchangereq_variables}
    [Return]            ${beampatternchangereq_variables}
    Log Variables

Get Information Elements from Beampatternchangeresp and verify
    [Arguments]       ${direction}
    [Documentation]         Creates a dictionary containing IE from cell Setup message from OAM
    Log to console           Checking Beampatternchangeresp IE
    ${pdmlFile} =     run keyword if     '${AirScale}' == 'ASOE'       Get filtered PDML file from pcap
    ...                      ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap      itf_l2_ps_tm_cell_beampatternchangeresp
    ...               ELSE   Get filtered PDML file from pcap    ${CaptureCPRT.path}    itf_l2_ps_tm_cell_beampatternchangeresp
    ${packet}        set variable          itf_l2_ps_tm_cell_beampatternchangeresp_t

    ${direction_pdml}      analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*direction$
    ...                                                endPacket=${1}
    should be equal     ${direction_pdml}     ${direction}

Verify that ULCell_CellSetupReq contains prachformat is 0 for prachConfigurationIndex
    ${pdmlFile} =    run keyword if     '${AirScale}' == 'ASOE'
    ...      Get filtered PDML file from pcap    ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap     ulcell_setupreq
    ...      ELSE     Get filtered PDML file from pcap    ${CaptureCPRT.path}     ulcell_setupreq
    ${value} =   run    command=sudo cat ${pdmlFile} | grep "prachFormat"
#    ${string}=    Split String    ${value}     (
#    ${value}=    Split String    ${string}[1]     :
#    ${expected_format}    Get Substring    ${string}[1]    0    8
#    ${expected_format}=    Split String    ${value}[1]
    should contain     ${value}    FORMAT_0


Verify that ULCell_CellSetupReq contains prachformat is A2 for prachConfigurationIndex set to 87
    ${pdmlFile} =    Get filtered PDML file from pcap    ${CaptureCPRT.path}     ulcell_setupreq
    ${value} =   run    command=sudo cat ${pdmlFile} | grep "prachFormat"
    ${string}=    Split String    ${value}     :
    ${string}=    Split String    ${string}[1]     .
    ${expected_format}    Get Substring    ${string}[0]    1    10
    should be equal     ${expected_format}    FORMAT_A2

Get Information Elements from UlCell_SetupReq and verify prachConfigurationIndex and pfaTargetPrachId
    [Arguments]      ${prachConfigurationIndex}     ${pfaTargetPrachId}      ${PhysCellId}
    Get Information Elements from UlCell_SetupReq
    ${prachConfigurationIndex_pdml}=    Get From Dictionary      ${UL_cell_setup_variables}    prachConfigurationIndex
    ${prachConfigurationIndex_pdml}=    convert to integer     ${prachConfigurationIndex_pdml}
    ${prachConfigurationIndex_pdml}=    convert to string     ${prachConfigurationIndex_pdml}
    should be equal     ${prachConfigurationIndex_pdml}     ${prachConfigurationIndex}
    ${pfaTargetPrachId_pdml}=    Get From Dictionary      ${UL_cell_setup_variables}    pfaTargetPrachId
    ${pfaTargetPrachId_pdml}=    convert to integer     ${pfaTargetPrachId_pdml}
    ${pfaTargetPrachId_pdml}=    convert to string     ${pfaTargetPrachId_pdml}
    should be equal     ${pfaTargetPrachId_pdml}     ${pfaTargetPrachId}
    ${PhysCellId_pdml}=    Get From Dictionary      ${UL_cell_setup_variables}    physcellId
    ${PhysCellId_pdml}=    convert to integer     ${PhysCellId_pdml}
    ${PhysCellId_pdml}=    convert to string     ${PhysCellId_pdml}
    should be equal     ${PhysCellId_pdml}     ${PhysCellId}


uldata_puschreceivereq of each packet returned in a list
    [Arguments]                     ${message}          ${pdmlFile}
    [Documentation]                  returns a list of packets for each uldata_puschreceivereq
    @{listpacketMatch}              analyzer.get_match_from_paths
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=${message}
    ...                             pathList=${FIELDS_PUSCH_RESP}
    ...                             startPacket=1
    ...                             endPacket=-1
    [return]          @{listpacketMatch}

uldata_puschreceivereq of each packet returned in a list for mcsTable
    [Arguments]                     ${message}          ${pdmlFile}
    [Documentation]                  returns a list of packets for each uldata_puschreceivereq
    @{listpacketMatch}              analyzer.get_match_from_paths
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=${message}
    ...                             pathList=${FIELDS_PUSCH_RESP_MCS}
    ...                             startPacket=1
    ...                             endPacket=-1
    [return]          @{listpacketMatch}

Verify that ULData_PuschReceiveReq message contains the numofUciCsiPart1Bits
    [Documentation]      Verifies the uldata_puschreceivereq message and based on configuration of
    ...                  numofUciCsiPart1Bits
    log to console       Verifies the uldata_puschreceivereq message and based on configuration of numofUciCsiPart1Bits
    ${pdmlFile} =    Get filtered PDML file from pcap    ${CaptureL1L2.path}    uldata_puschreceivereq
    @{list_of_values}    uldata_puschreceivereq of each packet returned in a list     UlData_PuschReceiveReq.grants_item_15    ${pdmlFile}
    @{list_of_values}     get slice from list     ${list_of_values}     0     20
    Get the pusch field value     numOfUciCsiPart1Bits    5      @{list_of_values}
    Get the pusch field value     numOfUciAckBits         0      @{list_of_values}
    Get the pusch field value     numOfUciAckSymbols      15      @{list_of_values}
    Get the pusch field value     numOfUciAckSymbols1bit    0      @{list_of_values}
    Get the pusch field value     numOfUciCsiPart1Symbols    12      @{list_of_values}
    Get the pusch field value     maxNumOfUciCsiPart2Symbols    3444      @{list_of_values}

Verify that ULData_PuschReceiveReq message contains the mcsTable
    [Documentation]      Verifies the uldata_puschreceivereq message and based on configuration of
    ...                  mcsTable
    log to console       Verifies the uldata_puschreceivereq message and based on configuration of mcsTable
    ${pdmlFile} =    Get filtered PDML file from pcap    ${CaptureL1L2.path}    uldata_puschreceivereq
    @{list_of_values}    uldata_puschreceivereq of each packet returned in a list for mcsTable
    ...                  UlData_PuschReceiveReq.grants_item_0    ${pdmlFile}
    @{list_of_values}     get slice from list     ${list_of_values}     0     20
    Get the pusch field value     mcsTable    1      @{list_of_values}

Get the pusch field value
    [Arguments]     ${packet_name}     ${expected_value}     @{list_of_values}
    FOR      ${packet}     IN      @{list_of_values}
        ${value}               Get Value In Packet Match
       ...                   packetMatch=${packet}
       ...                   field=${packet_name}
       ${value}       Convert To Integer      ${value}
       ${value}       convert to string       ${value}
       should be true      ${value} == ${expected_value}
    END

Verify the detected and missed counters in the MeasurementRepInd messages for Pusch
    log to console       Verify the detected and missed counters in the MeasurementRepInd messages for Pusch
    @{fields_measurementind}=     Create List     detectedCounter1     missedCounter1
    ${pdmlFile} =    Get filtered PDML file from pcap    ${CaptureCPRT.path}     itf_l2_ps_tm_cell_measurementreportind
    @{listpacketMatch}              analyzer.get_match_from_paths
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=itf_l2_ps_tm_cell_measurementreportind
    ...                             pathList=${fields_measurementind}
    ...                             startPacket=1
    ...                             endPacket=-1
    FOR      ${packet}     IN      @{listpacketMatch}
        ${value}               Get Value In Packet Match
       ...                   packetMatch=${packet}
       ...                   field=${fields_measurementind}[1]
       ${value}       Convert To Integer      ${value}
       ${value}       convert to string       ${value}
       should be true      ${value}
    END

Verify that ULData_PuschReceiveResp message contains array of numofUciCsiPart1Bits
    log to console       Verify that ULData_PuschReceiveResp message contains array of numofUciCsiPart1Bits
    @{puschRecieveResp}=     Create List     uci.pusch.part1bits     uci.pusch.part2bits
    ${pdmlFile} =    Get filtered PDML file from pcap    ${CaptureL1L2.path}     uldata_puschreceiverespps
    @{listpacketMatch}              analyzer.get_match_from_paths
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=uldata_puschreceiverespps
    ...                             pathList=${puschRecieveResp}
    ...                             startPacket=1
    ...                             endPacket=-1
    @{listpacketMatch}     get slice from list     ${listpacketMatch}     0     20
    Get the puschreceiveresp field value    part1bits      @{listpacketMatch}
    Get the puschreceiveresp field value    part2bits      @{listpacketMatch}
#    Get the puschreceiveresp field value    uciCsiPart1Bits_item_1      @{listpacketMatch}
#    Get the puschreceiveresp field value    uciCsiPart1Bits_item_2      @{listpacketMatch}
#    Get the puschreceiveresp field value    uciCsiPart1Bits_item_3      @{listpacketMatch}
#    Get the puschreceiveresp field value    uciCsiPart1Bits_item_4      @{listpacketMatch}
#    Get the puschreceiveresp field value    uciCsiPart1Bits_item_5      @{listpacketMatch}
#    Get the puschreceiveresp field value    uciCsiPart1Bits_item_6      @{listpacketMatch}
#    Get the puschreceiveresp field value    uciCsiPart1Bits_padding      @{listpacketMatch}
#    Get the puschreceiveresp field value    uciCsiPart2Bits_item_0      @{listpacketMatch}
#    Get the puschreceiveresp field value    uciCsiPart2Bits_item_1      @{listpacketMatch}
#    Get the puschreceiveresp field value    uciCsiPart2Bits_item_2      @{listpacketMatch}
#    Get the puschreceiveresp field value    uciCsiPart2Bits_item_3      @{listpacketMatch}
#    Get the puschreceiveresp field value    uciCsiPart2Bits_item_4      @{listpacketMatch}
#    Get the puschreceiveresp field value    uciCsiPart2Bits_item_5      @{listpacketMatch}
#    Get the puschreceiveresp field value    uciCsiPart2Bits_item_6      @{listpacketMatch}
#    Get the puschreceiveresp field value    uciCsiPart2Bits_padding      @{listpacketMatch}


Get the puschreceiveresp field value
    [Arguments]     ${packet_name}        @{listpacketMatch}
    FOR      ${packet}     IN      @{listpacketMatch}
        ${value}               Get Value In Packet Match
       ...                   packetMatch=${packet}
       ...                   field=${packet_name}
#       ${value}       Convert To Integer      ${value}
       ${value}       convert to string       ${value}
       should be equal      ${value}     00:00:00:00:00:00:00
    END

Verify that ULData_PuschReceiveReq message contains the puschTransformPrecoderFlag disabled
    [Documentation]      Verifies the uldata_puschreceivereq message and based on configuration of
    ...                  puschTransformPrecoderFlag
    log to console       Verifies the uldata_puschreceivereq message and based on configuration of puschTransformPrecoderFlag
#    ${pdmlFile} =      run keyword if     '${AirScale}' == 'ASOE'    Get filtered PDML file from pcap
#    ...      ${LOG_PATH1}/BIP_L1L2.pcap     uldata_puschreceivereq
#    ...    ELSE    Get filtered PDML file from pcap       ${CaptureL1L2.path}    uldata_puschreceivereq
    ${pdmlFile} =      Get filtered PDML file from pcap       ${CaptureL1L2.path}    uldata_puschreceivereq
    @{listpacketMatch}              analyzer.get_match_from_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=uldata_puschreceivereq
    ...                             path=puschTransformPrecoderFlag
    ...                             startPacket=1
    ...                             endPacket=-1
    @{listpacketMatch}     get slice from list     ${listpacketMatch}     0     20
    FOR      ${packet}     IN      @{listpacketMatch}
        ${value}               Get Value In Packet Match
       ...                   packetMatch=${packet}
       ...                   field=puschTransformPrecoderFlag
       should be equal    ${value}    0
    END

Verify that ULData_PuschReceiveReq message contains the puschTransformPrecoderFlag
    [Documentation]      Verifies the uldata_puschreceivereq message and based on configuration of
    ...                  puschTransformPrecoderFlag
    log to console       Verifies the uldata_puschreceivereq message and based on configuration of puschTransformPrecoderFlag
#    ${pdmlFile} =      run keyword if     '${AirScale}' == 'ASOE'    Get filtered PDML file from pcap
#    ...      ${LOG_PATH1}/AP_BIP_L1L2.pcap     uldata_puschreceivereq
#    ...    ELSE    Get filtered PDML file from pcap       ${CaptureL1L2.path}    uldata_puschreceivereq
    ${pdmlFile} =      Get filtered PDML file from pcap       ${CaptureL1L2.path}    uldata_puschreceivereq
    @{listpacketMatch}              analyzer.get_match_from_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=uldata_puschreceivereq
    ...                             path=puschTransformPrecoderFlag
    ...                             startPacket=1
    ...                             endPacket=-1
    @{listpacketMatch}     get slice from list     ${listpacketMatch}     0     20
    FOR      ${packet}     IN      @{listpacketMatch}
        ${value}               Get Value In Packet Match
       ...                   packetMatch=${packet}
       ...                   field=puschTransformPrecoderFlag
       should be equal    ${value}    1
    END

Full Commission SCF
    [Arguments]    ${scf_file}
    ute_adm.Setup Admin    alias=cOAM
    ute_adm.Perform Commissioning
    ...    bts_id=1
    ...    scf_file=${scf_file}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=500
    ...    alias=cOAM
    Run Keyword And Ignore Error    ute_adm.Teardown Admin    alias=cOAM


####### KW added for CB008938 ##############################
Verify that ps_cell_CellSetupReq contains dlMimoMode set to 12 and nrCellType set to 6 (1x1 Single Antenna Transmission)
    [Documentation]    NRBTS.NRCELL.nrCellType (new configuration value 12 (1DL2UL) introduced by CB008510). The new config
    ...    value corresponds to dlSubcellType = A1 in PsCell_CellSetupReq message from CP-RT to L2-PS
    ...    NRBTS.NRCELL.dlMimoMode (new configuration value 12 introduced by CB008983). The new config value corresponds to
    ...    dlMimoMode = "SingleAntennaTransmission_1x1" in PsCell_CellSetupReq message from CP-RT to L2-PS

    Log to console         Verify that DlCell_CellSetupReq contains dlMimoMode set to 12 and nrCellType set to 6 (1x1 Single Antenna Transmission)
    ${pdmlFile}=            run keyword if     '${AirScale}' == 'ASOE'    analyzer.pcap_to_pdml
    ...                                        ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap        itf_l2_ps_cell_cellsetupreq
    ...                     ELSE     analyzer.pcap_to_pdml    ${CaptureCPRT.path}         itf_l2_ps_cell_cellsetupreq
    ${dlMimoMode}           Evaluate    ${cell_setup_variables.dlMimoMode}*2+2
    ${dlMimoMode}       Convert To String   ${dlMimoMode}
    &{DICTONARY_dlMimoMode_dlSubcellType_IE_variables}       Create Dictionary
    ...                                                      dlSubcellType=${cell_setup_variables.dlSubcellType}
    ...                                                      dlMimoMode=${dlMimoMode}

    Verify that IE from message matches with encoded message in dictionary    message=itf_l2_ps_cell_cellsetupreq
    ...                                                                   message_ie_dictionary=&{DICTONARY_dlMimoMode_dlSubcellType_IE_variables}
    ...                                                                   pdmlFile=${pdmlFile}

Start L1L2 Bip Mon on classical gNB
    Log to Console     \n-----> Start L1L2 Mon <-----
    Bip_Mon_Start_ASIM_ABIP
#   Bip_Conf_Start_ASOE_L1bypass
#   Bip_Conf_Start_ASOE_FS


Stop and Collect L1L2 Bip Monitoring on classical gNB
    [Arguments]     ${log_path}
    Log to Console     \n-----> Stop and Collect L1L2 Mon <-----
    Create Folder        ${log_path}/L1L2_bipmon/
    Bip_Mon_Stop_Collect_ASIM_ABIP      ${log_path}/L1L2_bipmon/
#   Bip_Stop_Collect_ASOE_L1bypass      ${log_path}/L1L2_bipmon/
#   Bip_Stop_Collect_ASOE_FS        ${log_path}/L1L2_bipmon/

Start BIP capture taf
     [Documentation]     Collect L1L2 BIP Logs using taf.ul.gnb.bip.collection - scripting approach
    ...     -   :param alias:     Alias for l1l2bip which is also a directory name (default L1L2_BIP_Logs)
    ...     -   :param bb_mods:   List of BB modules to start collection from them, default: [ABIO]
    [Arguments]    ${gNB_common_unit}    ${bb_mods}    ${l1_type}    ${dir}=L1L2_BIP_Logs
    bip_collection.Configure Bip Collection     l1_type=${l1_type}
    ...                                         gNB_common_unit=${gNB_common_unit}
    ...                                         gNB_capacity_units=${bb_mods}
    ...                                         use_script=True
    ...                                         script_parameters=--bb_slot_1='false' --bb_slot_5='true'
    bip_collection.Start Bip Trace
    Log to console  BIP logs collecting started

Stop BIP capture taf
     [Documentation]     Stop collecting BIP Logs and save them at selected location
    ...     -   :param alias:       Alias for l1l2bip which is also a directory name without spaces (default L1L2_BIP_Logs)
    ...     -   :param dir_path:    Path where BIP logs should be copied (default ${OUTPUT_DIR}/
    ...     -   :param delay:       Time to wait before collecting the logs
    [Arguments]
    ...     ${dir}=L1L2_BIP_Logs    ${log_dir}=${OUTPUT_DIR}
#    Create directory  path=${dir_path}/${alias}
    Create directory  path=${log_dir}
    Create directory  path=/tmp/${dir}
    bip_collection.Stop Bip Trace   target_dir=/tmp/${dir}
    ${rc}=    Run And Return Rc  mergecap /tmp/${dir}/*.pcap* -w /tmp/${dir}/tcpdump.pcap
    Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
    Copy File    /tmp/${dir}/tcpdump.pcap    ${log_dir}/BIP_L1L2.pcap
    Remove directory    /tmp/${dir}    recursive=True
    Log to console  BIP logs collecting finished

Get Information elements from StartConformanceTestReq message for PUSCH-G TC_9500_TC5 and verify
    Log to console                       Checking StartConformanceTestReq OAM-CPRT IE
    Log Variables
    ${start_conf_variables}        run keyword if     '${AirScale}' == 'ASOE'    Get Information Element from L2PS
    ...           ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap      itf_l2_ps_tm_cell_startconformancetestreq
    ...    ELSE     Get Information Element from L2PS     ${CaptureCPRT.path}     itf_l2_ps_tm_cell_startconformancetestreq
    set suite variable       ${start_conf_variables}     ${start_conf_variables}
    Log Variables
    should be true    ${start_conf_variables.reportingTimeInterval} == 0.1
   Verify pusch StartConformanceTestReq_frc    frcIndex      G_FR1_A5_11
#    Verify pusch StartConformanceTestReq_frc    frcIndex       ${frcindex}
    Verify pusch StartConformanceTestReq    harqEnable     1
    Verify pusch StartConformanceTestReq    prbOffset_receive_test      0
#   Verify pusch StartConformanceTestReq    prbOffset      0
    Verify pusch StartConformanceTestReq    ruMode_type    0
    Verify pusch StartConformanceTestReq    ulDmrsMappingType      0

Get Information elements from StartConformanceTestReq message for PUSCH-G TC_9500_TC2 and verify
    Log to console                       Checking StartConformanceTestReq OAM-CPRT IE
    Log Variables
    ${start_conf_variables}        run keyword if     '${AirScale}' == 'ASOE'    Get Information Element from L2PS
    ...           ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap      itf_l2_ps_tm_cell_startconformancetestreq
    ...    ELSE     Get Information Element from L2PS     ${CaptureCPRT.path}     itf_l2_ps_tm_cell_startconformancetestreq
    set suite variable       ${start_conf_variables}     ${start_conf_variables}
    Log Variables
    should be true    ${start_conf_variables.reportingTimeInterval} == 0.1
   Verify pusch StartConformanceTestReq_frc    frcIndex      G_FR1_A3_11

    Verify pusch StartConformanceTestReq    harqEnable     1
    Verify pusch StartConformanceTestReq    prbOffset_receive_test      0
#   Verify pusch StartConformanceTestReq    prbOffset      0
    Verify pusch StartConformanceTestReq    ruMode_type    0
    Verify pusch StartConformanceTestReq    ulDmrsMappingType      0


Get Information elements from StartConformanceTestReq message for PUSCH-G_9500 TC and verify
    [Arguments]         ${frcindex}
    Log to console                       Checking StartConformanceTestReq OAM-CPRT IE
    Log Variables
    ${start_conf_variables}        run keyword if     '${AirScale}' == 'ASOE'    Get Information Element from L2PS
    ...           ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap      itf_l2_ps_tm_cell_startconformancetestreq
    ...    ELSE     Get Information Element from L2PS 9500     ${CaptureCPRT.path}     itf_l2_ps_tm_cell_startconformancetestreq
    set suite variable       ${start_conf_variables}     ${start_conf_variables}
    Log Variables
    should be true    ${start_conf_variables.reportingTimeInterval} == 1
#Fix this issue, 2 FRC coming for TX and RX
#	Verify pusch StartConformanceTestReq_frc    frcIndex      G_FR1_A1_2
    Verify pusch StartConformanceTestReq_frc    frcIndex       ${frcindex}
	Verify pusch StartConformanceTestReq    harqEnable     0
	Verify pusch StartConformanceTestReq    prbOffset_receive_test      0
#	Verify pusch StartConformanceTestReq    prbOffset      0
	Verify pusch StartConformanceTestReq    ruMode_type    0
    Verify pusch StartConformanceTestReq    ulDmrsMappingType      0


Get Information Element from L2PS 9500
    [Arguments]                      ${pcapFile}    ${filter_req}
    ${pdmlFile} =    Get filtered PDML file from pcap    ${pcapFile}    ${filter_req}

    ${packet}        set variable                  itf_l2_ps_tm_cell_StartConformanceTestReq_t

    ${numPucchSymbol}      analyzer.get_unique    pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*numPucchSymbol$
    ...                                           endPacket=${1}

    ${numPayloadBit}      analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*numPayloadBit$
    ...                                           endPacket=${1}

    ${pucchPayloadContent}  analyzer.get_unique   pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*pucchPayloadContent$
    ...                                           endPacket=${1}

    ${pucchFormat}      analyzer.get_unique       pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*pucchFormat$
    ...                                           endPacket=${1}

    ${beamPatternId}      analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*beamPatternIdList_item\\[1\\]
    ...                                           endPacket=${1}

    ${polarization}     analyzer.get_unique       pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*polarization$
    ...                                           endPacket=1

    ${ruMode_type}     analyzer.get_unique        pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*ruMode$
    ...                                           endPacket=1

    ${subFeatureFlag}     analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*subFeatureFlag$
    ...                                           endPacket=1

    ${prbOffset}     analyzer.get_unique                 pdmlFile=${pdmlFile}
    ...                                                  packetName=${packet}
    ...                                                  path=itf_l2_ps_tm_SPucchPerfTestConf.prbOffset
    ...                                                  endPacket=1
    ${prbOffset_receive_test}     analyzer.get_unique                 pdmlFile=${pdmlFile}
    ...                                                  packetName=${packet}
    ...                                                  path=itf_l2_ps_tm_SReceiverTestingConfig.prbOffset
    ...                                                  endPacket=1
    ${harqEnable}     analyzer.get_unique         pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*harqEnable$
    ...                                           endPacket=1

    ${testModel}     analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                           packetName=${packet}
    ...                                           path=.*testModel$
    ...                                           endPacket=1

    ${i11Codebook4Ant}     analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                            packetName=${packet}
    ...                                            path=.*i11Codebook4AntPorts$
    ...                                            endPacket=1

    ${i2Codebook4Ant}     analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*i2Codebook4AntPorts$
    ...                                                endPacket=1

    ${largestPrbIndex}     analyzer.get_unique         pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*largestPrbIndex$
    ...                                                endPacket=1

    ${ulDmrsMappingType}     analyzer.get_unique     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*ulDmrsMappingType$
    ...                                                endPacket=1
    ${reportingTimeInterval}     analyzer.get_unique         pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*reportingTimeInterval$
    ...                                                endPacket=1

    ${frcIndex}     analyzer.get_unique_showname     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=.*frcIndex$
    ...                                                startPacket=2
    ...                                                endPacket=2
    &{start_conf_variables}     Create Dictionary       ruMode_type=${ruMode_type}
    ...                                                 largestPrbIndex=${largestPrbIndex}
    ...                                                 pucchFormat=${pucchFormat}
    ...                                                 pucchPayloadContent=${pucchPayloadContent}
    ...                                                 numPayloadBit=${numPayloadBit}
    ...                                                 numPucchSymbol=${numPucchSymbol}
    ...                                                 beamPatternId=${beamPatternId}
    ...                                                 polarization=${polarization}
    ...                                                 prbOffset=${prbOffset}
    ...                                                 harqEnable=${harqEnable}
    ...                                                 i11Codebook4Ant= ${i11Codebook4Ant}
    ...                                                 i2Codebook4Ant=${i2Codebook4Ant}
    ...                                                 largestPrbIndex=${largestPrbIndex}
    ...                                                 ulDmrsMappingType=${ulDmrsMappingType}
    ...                                                 reportingTimeInterval=${reportingTimeInterval}
    ...                                                 frcIndex=${frcIndex}
    ...                                                 prbOffset_receive_test=${prbOffset_receive_test}
    [Return]            ${start_conf_variables}
    Log Variables

Verify that UlData_PuschReceiveReq message is in accordance with TC assumptions_9500
   [Documentation]        Verifies the IE message from ULDATA_PUSCHRECEIVEREQ message for each format from NR Performance,
   ...                    then matches the incoming content with pre-defined dictionaries containing expected message-fields.
    Log to console              Checking PUSCH IE in Message Decimal
#    ${pdmlFile}=       run keyword if     '${AirScale}' == 'ASOE'    Get filtered PDML file from pcap
#    ...                         ${LOG_PATH1}/AP_BIP_L1L2.pcap         uldata_puschreceivereq
#    ...                 ELSE    Get filtered PDML file from pcap    ${CaptureL1L2.path}        uldata_puschreceivereq
    ${pdmlFile}=       Get filtered PDML file from pcap    ${CaptureL1L2.path}        uldata_puschreceivereq
    &{DICTONARY_PUSCHRECEIVEREQ_IE_variables}          Create Dictionary
    ...        _5g_l1_ul_l2_ps_uldata_puschreceivereqgrant_t\\[1\\].*.startPrb=${start_conf_variables.prbOffset_receive_test}
    ...        _5g_l1_ul_l2_ps_uldata_puschreceivereqgrant_t\\[1\\].*.dmrsScramblingSequenceInt=${UL_cell_setup_variables.physcellId}
    &{DICTONARY_PUSCHRECEIVEREQ_IE_variables_BRANCH}          Create Dictionary
    ...                                      startPrb=${start_conf_variables.prbOffset_receive_test}
    ...                                      dmrsScramblingSequenceInt=${UL_cell_setup_variables.physcellId}
    ${DICT_IE_viables}    set variable if     '${sw_version_trunk}' in '${sw_version}'     ${DICTONARY_PUSCHRECEIVEREQ_IE_variables_BRANCH}
    ...                                                                                    ${DICTONARY_PUSCHRECEIVEREQ_IE_variables}
    ${DICT}    set variable if     '${sw_version_trunk}' in '${sw_version}'     ${DICTONARY_PUSCHRECEIVEREQ_IE_BRANCH}
    ...                                                                         ${DICTONARY_PUSCHRECEIVEREQ_IE}
    run keyword if      '${test_model_value}'=='G_FR1_A2_2'
    ...           Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICT_G_FR1_A2_2}
    ...                                                                       pdmlFile=${pdmlFile}
    ...  ELSE IF        '${test_model_value}'=='G_FR1_A3_11'
    ...           Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICT_G_FR1_A3_11}
    ...                                                                       pdmlFile=${pdmlFile}
    ...  ELSE IF        '${test_model_value}'=='G_FR1_A5_11'
    ...           Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICT_G_FR1_A5_11}
    ...                                                                       pdmlFile=${pdmlFile}
    ...  ELSE IF        '${test_model_value}'=='G_FR1_A9_5'
    ...           Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICT_G_FR1_A9_5}
    ...                                                                       pdmlFile=${pdmlFile}
    ...  ELSE IF        '${test_model_value}'=='G_FR1_A9_2'
    ...           Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICT_G_FR1_A9_2}
    ...                                                                       pdmlFile=${pdmlFile}
    ...  ELSE IF        '${test_model_value}'=='G_FR1_A9_1'
    ...           Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICT_G_FR1_A9_1}
    ...                                                                       pdmlFile=${pdmlFile}
    ...  ELSE IF        '${test_model_value}'=='G_FR1_A9_3'
    ...           Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICT_G_FR1_A9_3}
    ...                                                                       pdmlFile=${pdmlFile}
    ...  ELSE IF        '${test_model_value}'=='G_FR1_A9_4'
    ...           Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICT_G_FR1_A9_4}
    ...                                                                       pdmlFile=${pdmlFile}

Get information elements from L2PS_StartConformanceTestReq message for NR RECEIVER_9500
    [Documentation]    Retrieves data values from l2_ps_tm_cell_startconformancetestreq at CPRT level
    ...                for NR Receiver test
     Log to console                       Checking StartConformanceTestReq OAM-CPRT IE
     Log Variables
     ${start_conf_variables}    run keyword if    '${AirScale}' == 'ASOE'    Get IE from L2PS_StartConformanceTestReq for NR UL
     ...                    pcapFile=${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap
     ...                    filter_req=itf_l2_ps_tm_cell_startconformancetestreq
     ...                    ELSE     Get IE from L2PS_StartConformanceTestReq for NR UL
     ...                    pcapFile=${CaptureCPRT.path}
     ...                    filter_req=itf_l2_ps_tm_cell_StartConformanceTestReq_t.type == 1
    set suite variable     ${start_conf_variables}     ${start_conf_variables}
    Log Variables


Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements_ABIL9500
    Log to console  Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements
    Verify that DlData_SlotTypeReq message contains the correct slot type based on cell technology_ABIL9500

Verify that DlData_SlotTypeReq message contains the correct slot type based on cell technology_ABIL9500
    [Arguments]         ${tl_type}=${tl_mode}
    [Documentation]      Verifies the DLDATA_SLOTTYPEREQ message and based on configuration it
    ...                  matches the correct slot type wheter we have FDD/TDD setup

#    ${BIP_pcap}     Set Variable If    '${tl_type}'!='l1b'    BIP_L1L2      AP_BIP_L1L2
#    ${pdmlFile} =     run keyword if     '${AirScale}' == 'ABIL'    Get filtered PDML file from pcap
#    ...               ${LOG_PATH}/BIP_L1L2.pcap    dldata_slottypereq
#    ...               ELSE   Get filtered PDML file from pcap    ${LOG_PATH}/BIP_L1L2.pcap    dldata_slottypereq
    ${pdmlFile} =     Get filtered PDML file from pcap    ${CaptureL1L2.path}        dldata_slottypereq
    Extract and verify the slot type from dldata_slottypereq             ${pdmlFile}


Verify that ULData_PuschReceiveReq message contains the puschTransformPrecoderFlag_ABIL9500
    [Documentation]      Verifies the uldata_puschreceivereq message and based on configuration of
    ...                  puschTransformPrecoderFlag
    log to console       Verifies the uldata_puschreceivereq message and based on configuration of puschTransformPrecoderFlag
#    ${pdmlFile} =      run keyword if     '${AirScale}' == 'ASOE'    Get filtered PDML file from pcap
#    ...      ${LOG_PATH1}/AP_BIP_L1L2.pcap     uldata_puschreceivereq
#    ...    ELSE    Get filtered PDML file from pcap       ${LOG_PATH}/BIP_L1L2.pcap    uldata_puschreceivereq
    ${pdmlFile} =     Get filtered PDML file from pcap    ${CaptureL1L2.path}        uldata_puschreceivereq
    @{listpacketMatch}              analyzer.get_match_from_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=uldata_puschreceivereq
    ...                             path=puschTransformPrecoderFlag
    ...                             startPacket=1
    ...                             endPacket=-1
    @{listpacketMatch}     get slice from list     ${listpacketMatch}     0     20
    FOR      ${packet}     IN      @{listpacketMatch}
        ${value}               Get Value In Packet Match
       ...                   packetMatch=${packet}
       ...                   field=puschTransformPrecoderFlag
       should be equal    ${value}    1
    END
