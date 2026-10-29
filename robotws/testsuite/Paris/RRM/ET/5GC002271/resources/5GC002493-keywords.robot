*** Settings ***
Documentation
...             author:                 Nelsandro Sampaio, nelsandro.sampaio@nokia.com
...                                     Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com
...                                     Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...             maintainer:             Kamil Deregowski, kamil.deregowski@nokia.com

Library           OperatingSystem
Library           Collections
Library           DateTime
Library           ArchiveLibrary
Library           taf.gnb.oam.commissioning         WITH NAME    commissioning
Library           taf.gnb.oam.megazone_client       WITH NAME    megazone_client
Library           taf.transport.ssh                 WITH NAME    csn
Library           taf.config.scf                    WITH NAME    scf
Library           taf.hw.pdu                        WITH NAME    pdu
Library           ute_admin                         WITH NAME    ute_adm
Resource          taf/rfrl/common_resources/robot/common_definitions.robot
Resource          ../../resources_KRK/conformance_tests/frt.robot
Library           ../../../../resources/SWENG/python/ReadConfig.py
Resource          ../../../../resources/SWENG/robot/Restart.robot
Resource          ../../../../resources/SWENG/robot//Setup.robot
Resource          ../../../../resources/SWENG/robot//PacketSearch.robot
Library           CprtFilter.py
Library           SyslogFilter.py
Library           conformance_test_verifiers.py
Resource          5GC002493_constants_for_UE1.robot
Resource          5GC002493_constants_for_UE2.robot
Resource          5GC002493_constants_for_UE3.robot
Resource          5GC002493_constants_general.robot

*** Variables ***
${numOfPacket}    1

*** Keywords ***
Start DL Test Transmitter
    [Arguments]    ${test_model}    ${ru_mode}    ${pci}    ${polarization}    ${beamPatternId}
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
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin   release=admin21b
    ${my_response}=    coam.start_5g_downlink_test
    ...                dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${run_time}/MRBTS_R-${run_time}/NRBTS_R-1/NRCELL_R-1
    ...                test_model=${test_model}
    ...                beam_pattern_id=${beamPatternId}
    ...                polarization=${polarization}
    ...                power_backoff=10
    ...                ru_mode=${ru_mode}
    ...                phys_cell_id=${pci}
    ...                i11_codebook_4_antports=0
    ...                i2_codebook_4_antports=0
    ...                i13_codebook_4_antports=${0}
    ...                mimo_rank=${2}
    ...                codebook_2_antports=${0}
    ...                p_max=26
    ...                connection=coam_admin
    Log to console        ${my_response}
    ${my_result_node}=    Get From Dictionary    ${my_response}        resultNode
    ${my_parameters}=     Get From Dictionary    ${my_result_node}     parameters
    ${status}=            Get From Dictionary    ${my_parameters}      status
    Log to console        ${status}
    Should Contain         ${status}    Succeeded
    [Return]            ${test_model_value}
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
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin   release=admin21b
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
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
    ${my_response}=    coam.start_5g_uplink_ccm_test_pucch
    ...                dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${run_time}/MRBTS_R-${run_time}/NRBTS_R-1/NRCELL_R-1
    ...                interval=${reporting_int}
    ...                beam_pattern_id=${beamPatternId}
    ...                ru_mode=${ru_mode}
    ...                phys_cell_id=${pci}
    ...                receiving_slot=1023
    ...                expectation_slot=1023
    ...                pucch_format=${pucch_format}
    ...                prb_offset=1
    ...                largest_prb_index=100
    ...                num_pucch_symbol=${numPucchSymbol}
    ...                num_payload_bit=${num_payload_bit}
    ...                pucch_payload_content=${pucch_payload_content}
    ...                connection=coam_admin
    ...                format3_additional_dmrs=Disabled
    ...                digital_output_enable=false
    ...                nrarfcn_ul=${nrarfcn_ul}
    ...                nrarfcn_dl=${nrarfcn_dl}
    ...                act_high_speed_cell=false

    Log to console        ${my_response}
    ${my_result_node}=    Get From Dictionary    ${my_response}        resultNode
    ${my_parameters}=     Get From Dictionary    ${my_result_node}     parameters
    ${status}=            Get From Dictionary    ${my_parameters}      status
    Log to console        ${status}
    Should Contain         ${status}    Succeeded


Start Performance Test PRACH with ${format_type} formats on ${ruMode}
    [Documentation]
    ...     Starts 5G Prach Performance CCM Test (start5GUplinkCCMTest)
    ...    :return:   It returns dict with data.
    ...    +-----------------------------------------------------------------------------------------------------------+
    ...    | Usage from Robot - e.g.                                                                                    |
    ...    +============================================================================================================+
    ...    | Start Test PRACH with F_C2 formats on MSR                                                                  |
    ...    +------------------------------------------------------------------------------------------------------------+

    Log to console                       Start_test_Prach_MSR_F_C2
    set suite variable          ${test_model_value}     PRACH
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
     ${my_response}=    coam.Start 5g Uplink Ccm Test Prach    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
    ...                                                        interval=1
    ...                                                        beam_pattern_id=999
    ...                                                        ru_mode=${ruMode}
    ...                                                        phys_cell_id=50
    ...                                                        receiving_slot=1023
    ...                                                        expectation_slot=1023
    ...                                                        format=${format_type}
    ...                                                        preamble_index=0
    ...                                                        accepted_timing_error=260
    ...                                                        constant_offset=0
    ...                                                        delay_pattern_single_step_duration=0
    ...                                                        connection=coam_admin

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
    ${start_conf_variables}      Get IE from L2PS_StartConformanceTestReq     ${CaptureCPRT.path}     itf_l2_ps_tm_cell_startconformancetestreq
    set suite variable       ${start_conf_variables}     ${start_conf_variables}
    Log Variables


Get IE from L2PS_StartConformanceTestReq
    [Arguments]         ${pcapFile}    ${filter_req}
    [Documentation]
    ...                 Constructs and return a dictionary with
    ...                 key-value data structure from OAM-CPRT
    ...
    ${msg_json}    Get First Message from pcap as JSON    pcapFile=${pcapFile}    filter=${filter_req}
    Save JSON to File    ${msg_json}    ${pcapFile}    ${filter_req}

    ${beamPatternIdList0}        Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=beamPatternIdList_item
    ...                          item=0

    ${beamPatternIdList1}        Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=beamPatternIdList_item
    ...                          item=1

    ${polarization}              Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=polarization

    ${ruMode_type}               Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=ruMode

    ${subFeatureFlag}            Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=subFeatureFlag

    ${harqEnable}                Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=harqEnable

    ${testModel}                 Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=testModel

    ${i11Codebook4Ant}           Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=i11Codebook4AntPorts

    ${i2Codebook4Ant}            Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=i2Codebook4AntPorts

    &{start_conf_variables}     Create Dictionary         ruMode_type=${ruMode_type}
    ...                                                   beamPatternIdList0=${beamPatternIdList0}
    ...                                                   beamPatternIdList1=${beamPatternIdList1}
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
    ${start_conf_variables}     Get IE from L2PS_StartConformanceTestReq for NR UL    pcapFile=${CaptureCPRT.path}
    ...                                                                               filter_req=itf_l2_ps_tm_cell_startconformancetestreq
    set suite variable       ${start_conf_variables}     ${start_conf_variables}
    Log Variables

Get IE from L2PS_StartConformanceTestReq for NR UL
    [Arguments]                      ${pcapFile}    ${filter_req}
    ${msg_json}    Get First Message from pcap as JSON    pcapFile=${pcapFile}    filter=${filter_req}
    Save JSON to File    ${msg_json}    ${pcapFile}    ${filter_req}

    ${beamPatternIdList0}        Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=beamPatternIdList_item
    ...                          item=0

    ${beamPatternIdList1}        Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=beamPatternIdList_item
    ...                          item=1

    ${polarization}              Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=polarization

    ${ruMode_type}               Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=ruMode

    ${numPayloadBit}             Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=numPayloadBit

    ${subFeatureFlag}            Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=subFeatureFlag

    ${prbOffset}                 Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=PucchPerfTestConf.prbOffset

    ${prbOffset_receive_test}    Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=ReceiverTestingConfig.prbOffset

    ${largestPrbIndex}           Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=largestPrbIndex

    ${harqEnable}                Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=harqEnable

    ${testModel}                 Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=testModel

    ${i11Codebook4Ant}           Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=i11Codebook4AntPorts

    ${i2Codebook4Ant}            Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=i2Codebook4AntPorts

    ${pucchFormat}               Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=pucchFormat

    ${numPucchSymbol}            Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=numPucchSymbol

    ${controlChannelTestType}    Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=controlChannelTestType

    &{start_conf_variables}     Create Dictionary    largestPrbIndex=${largestPrbIndex}
    ...                                              pucchFormat=${pucchFormat}
    ...                                              numPayloadBit=${numPayloadBit}
    ...                                              controlChannelTestType=${controlChannelTestType}
    ...                                              numPucchSymbol=${numPucchSymbol}
    ...                                              ruMode_type=${ruMode_type}
    ...                                              beamPatternIdList0=${beamPatternIdList0}
    ...                                              beamPatternIdList1=${beamPatternIdList1}
    ...                                              polarization=${polarization}
    ...                                              harqEnable=${harqEnable}
    ...                                              i11Codebook4Ant= ${i11Codebook4Ant}
    ...                                              i2Codebook4Ant=${i2Codebook4Ant}
    ...                                              prbOffset=${prbOffset}
    ...                                              prbOffset_receive_test=${prbOffset_receive_test}
    [Return]            ${start_conf_variables}
    Log Variables


Get Information elements from StartConformanceTestReq message for Long PUCCH TCs
    Log to console                       Checking StartConformanceTestReq OAM-CPRT IE
    Log Variables
    ${start_conf_variables}        Get Information Element from L2PS    ${TEST_tcpdump_gnb_path}     itf_l2_ps_tm_cell_startconformancetestreq
    set suite variable       ${start_conf_variables}     ${start_conf_variables}
    Log Variables


Get Information Element from L2PS
    [Arguments]                      ${pcapFile}    ${filter_req}
    ${msg_json}    Get First Message from pcap as JSON    pcapFile=${pcapFile}    filter=${filter_req}
    Save JSON to File    ${msg_json}    ${pcapFile}    ${filter_req}

    ${numPucchSymbol}            Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=numPucchSymbol

    ${numPayloadBit}             Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=numPayloadBit

    ${pucchPayloadContent}       Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=pucchPayloadContent

    ${pucchFormat}               Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=pucchFormat

    ${beamPatternIdList0}        Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=beamPatternIdList_item
    ...                          item=0

    ${beamPatternIdList1}        Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=beamPatternIdList_item
    ...                          item=1

    ${polarization}              Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=polarization

    ${ruMode_type}               Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=ruMode

    ${subFeatureFlag}            Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=subFeatureFlag

    ${prbOffset}                 Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=PucchPerfTestConf.prbOffset

    ${harqEnable}                Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=harqEnable

    ${testModel}                 Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=testModel

    ${i11Codebook4Ant}           Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=i11Codebook4AntPorts

    ${i2Codebook4Ant}            Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=i2Codebook4AntPorts

    ${largestPrbIndex}           Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=largestPrbIndex

    ${format3AdditionDmrs}       Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=PucchPerfTestConf.format3AdditionalDmrs
    &{start_conf_variables}     Create Dictionary       ruMode_type=${ruMode_type}
    ...                                                 format3AdditionDmrs=${format3AdditionDmrs}
    ...                                                 largestPrbIndex=${largestPrbIndex}
    ...                                                 pucchFormat=${pucchFormat}
    ...                                                 pucchPayloadContent=${pucchPayloadContent}
    ...                                                 numPayloadBit=${numPayloadBit}
    ...                                                 numPucchSymbol=${numPucchSymbol}
    ...                                                 beamPatternIdList0=${beamPatternIdList0}
    ...                                                 beamPatternIdList1=${beamPatternIdList1}
    ...                                                 polarization=${polarization}
    ...                                                 prbOffset=${prbOffset}
    ...                                                 harqEnable=${harqEnable}
    ...                                                 i11Codebook4Ant= ${i11Codebook4Ant}
    ...                                                 i2Codebook4Ant=${i2Codebook4Ant}
    [Return]            ${start_conf_variables}
    Log Variables


Get Information Elements from DlCell_SetupReq
    [Documentation]         Creates a dictionary containing IE from DL Cell Setup message from OAM
    Log to console                  Checking DL Cell Setup IE
    &{cell_setup_variables}         Get IE from DlCellSetup     ${TEST_tcpdump_gnb_path}     dlcell_setupreq
    set suite variable       &{cell_setup_variables}      &{cell_setup_variables}


Get IE from DlCellSetup
    [Arguments]                      ${pcapFile}    ${filter_req}
    ${msg_json}    Get First Message from pcap as JSON    pcapFile=${pcapFile}    filter=${filter_req}
    Save JSON to File    ${msg_json}    ${pcapFile}    ${filter_req}

    ${dlSubcellType}             Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=dlSubcellType

    ${dlMimomode}                Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=dlMimoMode

    ${physcellId}                Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=physCellId

    ${dlBW}                      Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=dlBandwidth

    ${SCS}                       Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=scs

    &{cell_setup_variables}     Create Dictionary       physcellId=${physcellId}        dlBandWith=${dlBW}           scs=${SCS}
    [Return]            &{cell_setup_variables}
    Log Variables


Get Information Elements from UlCell_SetupReq
    [Documentation]         Creates a dictionary containing IE from DL Cell Setup message from OAM
    Log to console                       Checking UL Cell Setup IE
    &{UL_cell_setup_variables}              Get IE from UlCellSetup     ${TEST_tcpdump_gnb_path}     ulcell_setupreq
    set suite variable       &{UL_cell_setup_variables}      &{UL_cell_setup_variables}


Get IE from UlCellSetup
    [Arguments]                      ${pcapFile}    ${filter_req}
    ${msg_json}    Get First Message from pcap as JSON    pcapFile=${pcapFile}    filter=${filter_req}
    Save JSON to File    ${msg_json}    ${pcapFile}    ${filter_req}

    ${ulSubcellType}             Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=ulSubcellType

    ${physcellId}                Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=physCellId

    ${ulBW}                      Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=ulBandwidth

    ${bbselector}                Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=bbSelector

    ${SCS}                       Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=scs

    &{UL_cell_setup_variables}     Create Dictionary    physcellId=${physcellId}   ulBandWith=${ulBW}   bbselector=${bbselector}   scs=${SCS}
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
    @{listpacketMatch}  	        analyzer.get_match_from_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=${message}
    ...                             path=rnti$
    ...                             startPacket=1
    ...                             endPacket=10
    [return]          @{listpacketMatch}


Clean Old Logs
    [Documentation]                 Clean unnecessary logs created
    Run Keyword And Ignore Error    frt.Ssh Execute With Timeout     cd ${tl.core.dir_path} && rm -f *log*    lteemu
    ${l1l2bip_status}    Run Keyword And Return Status    Directory Should Exist    ${OUTPUT DIR}/Logs/l1l2bip/
    Run Keyword If    ${l1l2bip_status}    Remove Directory    ${OUTPUT DIR}/Logs/l1l2bip/    recursive=True

Set CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture init		${capture_var_cprt}
	Capture start		${capture_var_cprt}


Set L1L2 capture
    [Arguments]         ${capture_var_l1l2}
    Capture init		${capture_var_l1l2}
	Capture start		${capture_var_l1l2}


Stop CPRT capture
    [Arguments]         ${capture_var_cprt}
    Capture stop		${capture_var_cprt}


Stop L1L2 capture
    [Arguments]         ${capture_var_l1l2}
    Capture stop		${capture_var_l1l2}



Verify that DlData_SlotTypeReq message contains the correct slot type based on cell technology
    [Documentation]      Verifies the DLDATA_SLOTTYPEREQ message and based on configuration it
    ...                  matches the correct slot type wheter we have FDD/TDD setup
    ${pdmlFile} =    Get filtered PDML file from pcap    ${CaptureCPRT.path}    dldata_slottypereq
    Extract and verify the slot type from dldata_slottypereq             ${pdmlFile}

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
    [Documentation]      Verifies the DLDATA_SLOTTYPEREQ message and checks the slot and slot type
    ${slotPath}             Set Variable                icom_5g/dldata_slottypereq/DlData_SlotTypeReq.SlotTypeReq.slot
    ${slotTypePath}         Set Variable                icom_5g/dldata_slottypereq/DlData_SlotTypeReq.SlotTypeReq.slotType
    @{pathList}             Create list                 ${slotPath}$    ${slotTypePath}$

    verify_the_slot_type         pdml=${pdml}
    ...                          path_list=${pathList}
    ...                          ru_mode=${start_conf_variables.ruMode_type}
    ...                          scs=${cell_setup_variables.scs}
    ...                          slot_path=${slotPath}
    ...                          slot_type_path=${slotTypePath}


Verify that UlData_PucchReceiveReq message is in accordance with TC assumptions
   [Documentation]        Verifies the IE message from ULDATA_PUCCHRECEIVEREQ message for each format from NR Performance,
   ...                    then matches the incoming content with pre-defined dictionaries containing expected message-fields.
    Log to console              Checking PUCCH IE in Message Decimal
    ${msg_json}    Get First Message from pcap as JSON    pcapFile=${l1l2_trace}    filter=uldata_pucchreceivereq
    Save JSON to File    ${msg_json}    ${l1l2_trace}    uldata_pucchreceivereq

    ${num_of_prb}                Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=numOfPrb
    ${second_hop_prb}    Evaluate    hex(0x${start_conf_variables.largestPrbIndex} - (0x${num_of_prb} - 0x1))

    &{DICTONARY_PUCCHRECEIVEREQ_IE_variables}          Create Dictionary
    ...                              3gpp.pucchResources_item_0.dmrsScramblingSequenceInt=0x${UL_cell_setup_variables.physcellId}
    ...                              UlData_PucchReceiveReq.pucchResources_item_0.dataScramblingInt=0x${UL_cell_setup_variables.physcellId}
    ...                              UlData_PucchReceiveReq.pucchResources_item_0.pucchFormat=0x${start_conf_variables.pucchFormat}
    ...                              UlData_PucchReceiveReq.pucchResources_item_0.numOfBitsOfUciInformation=0x${start_conf_variables.numPayloadBit}
    ...                              UlData_PucchReceiveReq.pucchResources_item_0.numOfSymbols=0x${start_conf_variables.numPucchSymbol}
    ...                              UlData_PucchReceiveReq.pucchResources_item_0.startPrb=0x${start_conf_variables.prbOffset}
    ...                              UlData_PucchReceiveReq.pucchResources_item_0.secondHopPrb=0x${second_hop_prb}


    @{UL_PUCCHRECEIVEREQ_IE}    Create List    0x0    0x0

    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_IE}
    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_IE_variables}
    Verify Array in JSON Message    ${msg_json}    UlData_PucchReceiveReq.patternId.patternId_item    ${UL_PUCCHRECEIVEREQ_IE}

    run keyword if       '${pucch_format_type}'=="F2" and '${format_2}'=='Uci'
    ...                  Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_F2_UCI_IE}
    ...     ELSE IF      '${pucch_format_type}'=="F2" and '${format_2}'=='Ack'
    ...                  Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_F2_ACK_IE}
    ...     ELSE IF      '${pucch_format_type}'=="F0"
    ...                  Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_F0_IE}
    ...     ELSE IF      '${pucch_format_type}'=="F1"
    ...                 Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_F1_IE}
    ...     ELSE IF      '${pucch_format_type}'=="F3"
    ...                  Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_F3_IE}

    run keyword if      ('${start_conf_variables.numPucchSymbol}'=='1' and '${pucch_format_type}'=="F0")
    ...    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_F0_F2_firstSymbol_freqhopping_1}
    run keyword if      ('${start_conf_variables.numPucchSymbol}'=='1' and '${pucch_format_type}'=="F2")
    ...    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_F0_F2_firstSymbol_freqhopping_1}
    run keyword if      ('${start_conf_variables.numPucchSymbol}'=='2' and '${pucch_format_type}'=="F0")
    ...    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_F0_F2_firstSymbol_freqhopping_2}
    run keyword if      ('${start_conf_variables.numPucchSymbol}'=='2' and '${pucch_format_type}'=="F2")
    ...    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_F0_F2_firstSymbol_freqhopping_2}

    &{DICTONARY_PUCCHRECEIVEREQ_IE_nANPucch}     Create Dictionary
    ...          UlData_PucchReceiveReq.pucchResources_item_0.nANPucch=${start_conf_variables.numPayloadBit}

    run keyword if      '${format_2}'=='Uci'
    ...    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_nANPucch}
    ...     ELSE IF     '${format_2}'=='Ack'
    ...    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_IE_nANPucch}

    &{DICTONARY_PUCCHRECEIVEREQ_IE_additionalDmrs}   Create Dictionary
    ...         UlData_PucchReceiveReq.pucchResources_item_0.additionalDmrs=${start_conf_variables.format3AdditionDmrs}

    run keyword if      '${pucch_format_type}'=="F3"
    ...    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_IE_additionalDmrs}

Verify UlData_PucchReceiveReq message
   [Arguments]            ${l1l2_bip_file}
   [Documentation]        Verifies the IE message from ULDATA_PUCCHRECEIVEREQ message for each format from NR Performance,
   ...                    then matches the incoming content with pre-defined dictionaries containing expected message-fields.
    Log to console              Checking PUCCH IE in Message Decimal
    ${msg_json}    Get First Message from pcap as JSON    pcapFile=${l1l2_bip_file}    filter=uldata_pucchreceivereq
    Save JSON to File    ${msg_json}    ${l1l2_bip_file}    uldata_pucchreceivereq

    ${num_of_prb}                Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=numOfPrb

    &{DICTONARY_PUCCHRECEIVEREQ_IE_variables}          Create Dictionary
    ...                              3gpp.pucchResources_item_0.dmrsScramblingSequenceInt=0x${UL_cell_setup_variables.physcellId}
    ...                              UlData_PucchReceiveReq.pucchResources_item_0.dataScramblingInt=0x${UL_cell_setup_variables.physcellId}
    ...                              UlData_PucchReceiveReq.pucchResources_item_0.pucchFormat=0x${start_conf_variables.pucchFormat}
    ...                              UlData_PucchReceiveReq.pucchResources_item_0.numOfBitsOfUciInformation=0x${start_conf_variables.numPayloadBit}
    ...                              UlData_PucchReceiveReq.pucchResources_item_0.numOfSymbols=0x${start_conf_variables.numPucchSymbol}
    ...                              UlData_PucchReceiveReq.pucchResources_item_0.startPrb=0x${start_conf_variables.prbOffset}
    ...                              UlData_PucchReceiveReq.pucchResources_item_0.secondHopPrb=0x${start_conf_variables.largestPrbIndex}


    @{UL_PUCCHRECEIVEREQ_IE}    Create List    0x0    0x0

    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_IE}
    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_IE_variables}
    Verify Array in JSON Message    ${msg_json}    UlData_PucchReceiveReq.patternId.patternId_item    ${UL_PUCCHRECEIVEREQ_IE}

    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_F3_IE}

    &{DICTONARY_PUCCHRECEIVEREQ_IE_nANPucch}     Create Dictionary
    ...          UlData_PucchReceiveReq.pucchResources_item_0.nANPucch=${start_conf_variables.numPayloadBit}

    Run keyword if      '${format_2}'=='Uci'
    ...    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_nANPucch}
    ...     ELSE IF     '${format_2}'=='Ack'
    ...    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_IE_nANPucch}

    &{DICTONARY_PUCCHRECEIVEREQ_IE_additionalDmrs}   Create Dictionary
    ...         UlData_PucchReceiveReq.pucchResources_item_0.additionalDmrs=${start_conf_variables.format3AdditionDmrs}

    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_IE_additionalDmrs}

Verify that UlData_PuschReceiveReq message is in accordance with TC assumptions
   [Documentation]        Verifies the IE message from ULDATA_PUSCHRECEIVEREQ message for each format from NR Performance,
   ...                    then matches the incoming content with pre-defined dictionaries containing expected message-fields.
    Log to console              Checking PUSCH IE in Message Decimal
    ${pdmlFile}=         Get filtered PDML file from pcap        ${CaptureL1L2.path}         uldata_puschreceivereq

    &{DICTONARY_PUSCHRECEIVEREQ_IE_variables}          Create Dictionary
    ...                                      UlData_PuschReceiveReq.grants_item_0.startPrb=${start_conf_variables.prbOffset_receive_test}
    ...                                      UlData_PuschReceiveReq.grants_item_0.dmrsScramblingSequenceInt=${UL_cell_setup_variables.physcellId}

    Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICTONARY_PUSCHRECEIVEREQ_IE}
    ...                                                                       pdmlFile=${pdmlFile}
    Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICTONARY_PUSCHRECEIVEREQ_IE_variables}
    ...                                                                       pdmlFile=${pdmlFile}
    run keyword if      '${test_model_value}'=='G_FR1_A1_5'
    ...           Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICTONARY_PUSCHRECEIVEREQ_G_FR1_A1_5_IE}
    ...                                                                       pdmlFile=${pdmlFile}
    ...  ELSE IF        '${test_model_value}'=='G_FR1_A2_5'
    ...           Verify that IE from message matches with encoded message in dictionary    message=UlData_PuschReceiveReq
    ...                                                                       message_ie_dictionary=${DICTONARY_PUSCHRECEIVEREQ_G_FR1_A2_5_IE}
    ...                                                                       pdmlFile=${pdmlFile}

Verify message DlData_PdcchSendReq for 5GC002493_A001
    Log to console   Verify message DlData_PdcchSendReq for 5GC002493_A001
    ${msg_json}    Get First Message from pcap as JSON    pcapFile=${CaptureL1L2.path}    filter=dldata_pdcchsendreq
    Save JSON to File    ${msg_json}    ${CaptureL1L2.path}    dldata_pdcchsendreq

    &{DICTONARY_PDCCHSENDREQ_IE_variables}       Create Dictionary
    ...                                          DlData_PdcchSendReq.dciInfo_item_0.polarizationSelection=0x${start_conf_variables.polarization}
    ...                                          3gpp.dciInfo_item_0.dmrsScramblingSequenceInt=0x${cell_setup_variables.physcellId}
    ...                                          DlData_PdcchSendReq.patternId.patternId_item=0x${start_conf_variables.beamPatternIdList0}

    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PDCCHSENDREQ_IE}    usePrefix=${False}
    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PDCCHSENDREQ_IE_variables}    usePrefix=${False}

Verify message DlData_PdschSendReq for 5GC002493_A001
    Log to console  Verify message DlData_PdschSendReq for 5GC002493_A001
    ${msg_json}    Get First Message from pcap as JSON    pcapFile=${CaptureL1L2.path}    filter=dldata_pdschsendreq
    Save JSON to File    ${msg_json}    ${CaptureL1L2.path}    dldata_pdschsendreq

    ${DICTONARY_PDSCHSENDREQ_IE_variables}    Create Dictionary
    ...                                       DlData_PdschSendReq.grants_item_0.dmrsScramblingSequenceInt=0x${cell_setup_variables.physcellId}

    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PDSCHSENDREQ_IE_variables}    usePrefix=${False}

    ${msg_rnti0}    Get First Message from pcap as JSON    pcapFile=${CaptureL1L2.path}
    ...    filter=(dldata_pdschsendreq) && (3gpp.rnti == 0)
    ${msg_rnti1}    Get First Message from pcap as JSON    pcapFile=${CaptureL1L2.path}
    ...    filter=(dldata_pdschsendreq) && (3gpp.rnti == 1)
    ${msg_rnti2}    Get First Message from pcap as JSON    pcapFile=${CaptureL1L2.path}
    ...    filter=(dldata_pdschsendreq) && (3gpp.rnti == 2)
    Save JSON to File    ${msg_rnti0}    ${CaptureL1L2.path}    dldata_pdschsendreq_rnti0
    Save JSON to File    ${msg_rnti1}    ${CaptureL1L2.path}    dldata_pdschsendreq_rnti1
    Save JSON to File    ${msg_rnti2}    ${CaptureL1L2.path}    dldata_pdschsendreq_rnti2

    Verify JSON Message Against Dictionary    ${msg_rnti0}    ${DL_PDSCHSENDREQ_TM_FDD_3.3_FR1_IE_5GC002493_UE1}    usePrefix=${False}
    Verify JSON Message Against Dictionary    ${msg_rnti1}    ${DL_PDSCHSENDREQ_TM_FDD_3.3_FR1_IE_5GC002493_UE2}    usePrefix=${False}
    Verify JSON Message Against Dictionary    ${msg_rnti2}    ${DL_PDSCHSENDREQ_TM_FDD_3.3_FR1_IE_5GC002493_UE3}    usePrefix=${False}

Verify that UlData_PucchReceiveReq is set in accordance with 5GC002493 - prbOffset and largetPrbIndex verified
    [Arguments]        ${format_type}       ${l1l2_bip_file}
    Log to console     Verify that UlData_PucchReceiveReq is set in accordance with 5GC002493

    ${msg_json}    Get First Message from pcap as JSON    pcapFile=${l1l2_bip_file}    filter=uldata_pucchreceivereq
    Save JSON to File    ${msg_json}    ${l1l2_bip_file}    uldata_pucchreceivereq

    ${first_symbol}         Set Variable If    ${start_conf_variables.numPucchSymbol}==${0x1}    ${0xd}    ${0xc}
    ${frequency_hopping}    Set Variable If    ${start_conf_variables.numPucchSymbol}==${0x1}    ${0x0}    ${0x1}
    ${num_of_prb}                Get Field Value from JSON as Hex
    ...                          json=${msg_json}
    ...                          pattern=UlData_pucchReceiveReqPucchResource_t.numOfPrb

    ${second_hop_prb}    Evaluate    hex(0x${start_conf_variables.largestPrbIndex} - (0x${num_of_prb} - 0x1))

    &{DICTONARY_PUCCHRECEIVEREQ_IE_GENERAL}          Create Dictionary
    ...                           3gpp.pucchResources_item_0.dmrsScramblingSequenceInt=${UL_cell_setup_variables.physcellId}
    ...                           UlData_PucchReceiveReq.pucchResources_item_0.dataScramblingInt=${UL_cell_setup_variables.physcellId}
    ...                           UlData_PucchReceiveReq.pucchResources_item_0.startPrb=${start_conf_variables.prbOffset}
    ...                           UlData_PucchReceiveReq.pucchResources_item_0.nANPucch=${start_conf_variables.numPayloadBit}
    ...							  UlData_PucchReceiveReq.pucchResources_item_0.numOfBitsOfUciInformation=${start_conf_variables.numPayloadBit}
    ...							  UlData_PucchReceiveReq.pucchResources_item_0.numOfSymbols=${start_conf_variables.numPucchSymbol}
    ...							  UlData_PucchReceiveReq.pucchResources_item_0.firstSymbol=${first_symbol}
    ...							  UlData_PucchReceiveReq.pucchResources_item_0.frequencyHopping=${frequency_hopping}
    ...							  UlData_PucchReceiveReq.pucchResources_item_0.secondHopPrb=${second_hop_prb}

    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_IE_GENERAL}
    run keyword if      '${format_type}'=='F0'
    ...       Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_F0_ACK_IE_5GC002493}
    ...       ELSE IF   '${format_type}'=='F2'
    ...       Verify JSON Message Against Dictionary    ${msg_json}    ${DICTONARY_PUCCHRECEIVEREQ_F2_ACK_IE_5GC002493}

Verify that DlData_SlotTypeReq is set in accordance with 5GC002493 requirements
    Log to console  Verify that DlData_SlotTypeReq is set in accordance with 5GC002493 requirements
    Verify that DlData_SlotTypeReq message contains the correct slot type based on cell technology

Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    Log to console              Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    ${msg_json}    Get First Message from pcap as JSON    pcapFile=${TEST_tcpdump_gnb_path}    filter=dlcell_setupreq
    Save JSON to File    ${msg_json}    ${TEST_tcpdump_gnb_path}    dlcell_setupreq
    Verify JSON Message Against Dictionary    ${msg_json}    ${DICTIONARY_DLCELL_SETUP_REQ_CL_2x2}

Verify that DlCell_CellSetupReq contains dlMimoMode set to 1 (CL 4x4 or 4x2 MIMO)
    Log to console              Verify that DlCell_CellSetupReq contains dlMimoMode set to 1 (CL 4x4 or 4x2 MIMO)
    ${pdmlFile}=            Get filtered PDML file from pcap    ${CaptureCPRT.path}         dlcell_setupreq
    Verify that IE from message matches with encoded message in dictionary    message=DlCell_SetupReq
    ...                                                                       message_ie_dictionary=${DICTIONARY_DLCELL_SETUP_REQ_CL_4x4_4x2}
    ...                                                                       pdmlFile=${pdmlFile}
Verify that message DlData_PdcchSendReq contains IE values in accordance with 5GC002493 requirements
    Verify message DlData_PdcchSendReq for 5GC002493_A001

Verify that DlCell_CellSetupReq contains dlBandwidth set to ${value}
    Log to console              Verify that DlCell_CellSetupReq contains dlbandwidth set to ${value}
    ${pdmlFile}=            Get filtered PDML file from pcap    ${CaptureCPRT.path}         dlcell_setupreq
    ${hex_value}            convert value to hex      ${value}

    &{DICTIONARY_DLCELL_SETUP_REQ_DL_BANDWIDTH}       Create Dictionary        DlCell_SetupReq.SetupReq.dlBandwidth=${hex_value}

    Verify that IE from message matches with encoded message in dictionary    message=DlCell_SetupReq
    ...                                                                       message_ie_dictionary=${DICTIONARY_DLCELL_SETUP_REQ_DL_BANDWIDTH}
    ...                                                                       pdmlFile=${pdmlFile}


Verify message DlData_PdschSendReq based on Test Model Dictionary - ${DICTIONARY} for UE_${ue_id} - BW: ${bw}
    Log to console  Verify message DlData_PdschSendReq based on Test Model Dictionary - ${DICTIONARY} for UE_${ue_id}
    ${pdmlFile}=            Get filtered PDML file from pcap        ${CaptureL1L2.path}         dldata_pdschsendreq

    ${DICTONARY_PDSCHSENDREQ_IE_variables}    Create Dictionary
    ...                                       DlData_PdschSendReq.grants_item_0.dmrsScramblingSequenceInt=${cell_setup_variables.physcellId}

    Verify that IE from message matches with encoded message in dictionary    message=DlData_PdschSendReq
    ...                                                                       message_ie_dictionary=${DICTONARY_PDSCHSENDREQ_IE_variables}
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

Get First Message from pcap as JSON
    [Documentation]     Returns first message from filtered pcap file in JSON format
    [Arguments]    ${pcapFile}    ${filter}
    ${rc}    ${json}    Run And Return Rc And Output
    ...    tshark -r ${pcapFile} -R "${filter}" -T json -2 -c 1
    Should Be Equal As Integers    ${rc}    0
    ...    msg=tshark returned error: ${json}
    Should Not Be Equal As Strings    ${json}    []
    ...    msg=No message found in file\=${pcapFile} using filter\=${filter}
    [Return]    ${json}

Get Field Value from JSON as Hex
    [Documentation]     Searches for pattern and returns field value from a JSON formatted message as hex
    ...                 In case of array elements an item index can be specified
    [Arguments]    ${json}    ${pattern}    ${item}=0
    ${ret}    Get Lines Matching Pattern    ${json}    *${pattern}*    case_insensitive=${True}
    Should Not Be Empty    ${ret}
    ...    msg=Pattern ${pattern} matched no field
    Should Not Contain Any    ${ret}    {    }
    ...    msg=Pattern ${pattern} matched a structure, not a field
    @{lines}    Split To Lines    ${ret}
    ${line}    Remove String    ${lines}[${item}]    ,    "
    ${line}    Strip String    ${line}
    ${field}    ${value}    Split String    ${line}    separator=:
    ${value}    Convert To Hex   ${value}
    [Return]    ${value}

Verify JSON Message Against Dictionary
    [Arguments]    ${json}    ${dictionary}    ${usePrefix}=${True}
    @{keys}    Get Dictionary Keys    ${dictionary}
    FOR    ${field}    IN    @{keys}
      ${prefix}    ${middle}    ${pattern}    Split String    ${field}    separator=.
      ${filter}    Set Variable If    ${usePrefix}    ${prefix}*${pattern}    ${pattern}
      ${msg_value}    Get Field Value from JSON as Hex    ${json}    ${filter}
      ${dict_val_hex}    Convert To Hex   ${dictionary}[${field}]
      Should Be Equal As Integers    ${msg_value}    ${dict_val_hex}
      ...    msg=Dictionary item ${field}:${dict_val_hex} does not equal message value:${msg_value}
      ...    base=16
    END

Verify Array in JSON Message
    [Arguments]    ${json}    ${field}    ${values_list}
    ${prefix}    ${middle}    ${pattern}    Split String    ${field}    separator=.
    ${n}    Set Variable    0
    FOR    ${item}    IN    @{values_list}
        ${msg_value}    Get Field Value from JSON as Hex    ${json}    ${prefix}*${pattern}    item=${n}
        ${val_hex}    Convert To Hex   ${item}
        Should Be Equal As Integers    ${msg_value}    ${val_hex}
        ...    msg=Array item ${field}\[${n}\]:${val_hex} does not equal message value:${msg_value}
        ...    base=16
        ${n}    Evaluate    ${n}+1
    END

Save JSON to File
    [Arguments]    ${json}    ${pcapFilePath}    ${filter}
    ${jsonPath}    Replace String    ${pcapFilePath}    .pcap    _${filter}.json
    Create File    ${jsonPath}    ${json}

Verify StartConformanceTestReq logs from snapshot
    Log to console    Verify cprt logs from snapshot
    ${snapshot_path}=   Collect Snapshot From GNB   log_dir=${EXECDIR}/Logs/Snapshot   connection=coam_admin
    Get all cprt logs    snapshot_path=${snapshot_path}
    ...                  output_path=${EXECDIR}/Logs/cprt_logs.txt
    Check if narfcn is correct    log_input=${EXECDIR}/Logs/cprt_logs.txt
    ...                           log_output=${EXECDIR}/Logs/cprt_logs-filtered.txt
