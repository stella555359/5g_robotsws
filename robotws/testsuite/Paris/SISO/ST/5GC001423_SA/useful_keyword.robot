*** Settings ***
Documentation    This file contains the keywords for the SA test cases

Library    BuiltIn


*** Keywords ***
Test Suite Preparation
    # Test directory Preparation
    ${date}             get current date    result_format=%Y%m%d_%H_%M
    ${suite_dir}        replace string      ${SUITE NAME}_${date}    ${SPACE}    _
    ${directory}        replace string      ${TEST NAME}_${date}    ${SPACE}    _
    ${suite_dir}         joinpath        ${OUTPUT DIR}     ${suite_dir}
    create directory    ${suite_dir}
    ${date}             get current date    result_format=%Y%m%d_%H_%M
    ${directory}        replace string      ${TEST NAME}_${date}    ${SPACE}    _
    ${res_path}         joinpath        ${suite_dir}     ${directory}
    create directory    ${res_path}
    Set Suite variable   ${res_path}     ${res_path}
    #Set luashark
    luashark.Get Related Luashark    ${ENB_BUILD}


SA_40_SSB transmission Analysis
    [Arguments]      ${res_path}    ${L1L2_trace_pcap}

    @{csv_files}    Create list
    ${index}    Set variable    0
    FOR    ${pcap_file}   IN    @{L1L2_trace_pcap}
            ${str_index}    Convert to string    ${index}
            ${csv_file}    Set variable    ${res_path}/logs/SSBURST_pcapprocessed${str_index}.txt
            ${cmd}    catenate      tshark -X lua_script:/opt/luashark/luashark.lua -r ${pcap_file} -T fields
    ...   -Y "dldata_slottypereq" -e _ws.col.Info -e DlData_SlotTypeReq.SlotTypeReq.sfn -e DlData_SlotTypeReq.SlotTypeReq.slot
    ...   -e DlData_SlotTypeReq.SlotTypeReq.slotType    -E header=y -E separator=, > ${csv_file}
          Run         ${cmd}
          Append To List    ${csv_files}    ${csv_file}
          ${index}     Evaluate    ${index} +1
    END
    ${SSBURST_pcapprocessed}     pcap_helper.merge_csv_files    ${csv_files}      SSBURST_pcapprocessed.txt
    #To Be continu
    #Check that every SLOT (0x1, 0x3, 0x5, 0x7, 0xb, 0xd, 0xf) per SFN SSBURST is send 12 times.


SA_28_Link-Adaptation DL Analysis
    [Arguments]      ${dst_path}    ${L1L2_trace_pcap}
    Log    Calcultae DL MCS distribution
    @{csv_files}    Create list
    ${index}    Set variable    0
    FOR    ${pcap_file}   IN    @{L1L2_trace_pcap}
            ${str_index}    Convert to string    ${index}
            ${csv_file}    Set variable    ${dst_path}/logs/DL_MCS_pcapprocessed${str_index}.txt
            ${cmd}    catenate      tshark -X lua_script:/opt/luashark/luashark.lua -r ${pcap_file} -T fields
    ...   -Y "dldata_pdschsendreq" -e _ws.col.Info -e frame.time_epoch -e DlData_PdschSendReq.PdschSendReq.sfn
    ...   -e DlData_PdschSendReq.PdschSendReq.slot -e DlData_PdschSendReq.grants_item_0.mcs
    ...   -e DlData_PdschSendReq.grants_item_0.mcsTable
    ...   -E header=y -E separator=, > ${csv_file}
          Run         ${cmd}
          Append To List    ${csv_files}    ${csv_file}
          ${index}     Evaluate    ${index} +1
    END
    ${DL_MCS_pcapprocessed}     pcap_helper.merge_csv_files    ${csv_files}      DL_MCS_pcapprocessed.txt

SA_28_Link-Adaptation UL Analysis
    [Arguments]      ${dst_path}    ${L1L2_trace_pcap}
    Log    Calcultae UL MCS distribution
    @{csv_files}    Create list
    ${index}    Set variable    0
    FOR    ${pcap_file}   IN    @{L1L2_trace_pcap}
            ${str_index}    Convert to string    ${index}
            ${csv_file}    Set variable    ${dst_path}/logs/UL_MCS_pcapprocessed${str_index}.txt
            ${cmd}    catenate      tshark -X lua_script:/opt/luashark/luashark.lua -r ${pcap_file} -T fields
    ...   -Y "uldata_puschreceivereq" -e _ws.col.Info -e frame.time_epoch -e UlData_PuschReceiveReq.PuschReceiveReq.sfn
    ...   -e UlData_PuschReceiveReq.PuschReceiveReq.slot -e UlData_PuschReceiveReq.grants_item_0.mcs
    ...   -e UlData_PuschReceiveReq.grants_item_0.mcsTable
    ...   -E header=y -E separator=, > ${csv_file}
          Run         ${cmd}
          Append To List    ${csv_files}    ${csv_file}
          ${index}     Evaluate    ${index} +1
    END
    ${UL_MCS_pcapprocessed}     pcap_helper.merge_csv_files    ${csv_files}      UL_MCS_pcapprocessed.txt

