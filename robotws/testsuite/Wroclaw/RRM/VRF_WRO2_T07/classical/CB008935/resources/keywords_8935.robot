*** Settings ***
Documentation
...   Test keywords for 5GC008935

Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod   WITH NAME   TcpdumpSmod
Library     taf.ue
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008935/resources/test_specific_keywords_8935.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils     WITH NAME    AdminUtils
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/common.robot


*** Variables ***
@{cells_used_in_8935}=      19
@{cRbSizeDls}=              270    160         # 7552 /BWP 4, 33/       => /cRbSizeDl 106, 160, 106/
#@{cRbSizeDls}=              106    160         # 7552 /BWP 35, 37, 74/  => /cRbSizeDl 106, 160, 106/
${call_1_result}=           ${False}
${call_2_result}=           ${False}
${50mhz_ids}=               4   5   6   7   8
${30mhz_ids}=               9   10  11  12  13


*** Keywords ***
CB008935_AB1_Successful_UE_attachment_and_traffic_NSA_Mode_Thor
    Preconditions 8935

    Attach                      MTK_UE

    Verify Attach Type From PCAP
    ...     ${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/cplane_collector/cplane_collector.pcap
    ...     NSA

    Start tput transfer         ul  UT_1    UE_1    200
    ...                         dl  DT_1    UE_1    200
    BuiltIn.Sleep    60
    Stop tput transfer          DT_1    UT_1    100    40

    Enabling 256 QAM params
    Start tput transfer         ul  UT_2    UE_1    200
    ...                         dl  DT_2    UE_1    200
    BuiltIn.Sleep    60
    Stop tput transfer          DT_2    UT_1    100    40

    taf.ue.Detach Ue            UE_1

    [Teardown]  Run Keywords
    ...            Run keyword and ignore error        log to console      all done      AND
    ...            Run keyword and ignore error        taf.ue.Detach Ue    UE_1          AND
    ...            Run keyword and ignore error        AdminUtils.unlock all cells


CB008935_AB2_Successful_UE_attachment_and_traffic_SA_Mode_Thor
    Preconditions 8935

    Attach                      MTK_UE

    Verify Attach Type From PCAP
    ...     ${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/cplane_collector/cplane_collector.pcap
    ...     SA

    Start tput transfer         ul      UT_1    UE_1     200
    ...                         dl      DT_1    UE_1     250
    BuiltIn.Sleep     60
    Stop tput transfer          DT_1    UT_1     100    40

    Enabling 256 QAM params                                      # actDl256Qam   actUl256Qam
    Start tput transfer         ul      UT_2    UE_1     200
    ...                         dl      DT_2    UE_1     250
    BuiltIn.Sleep     60
    Stop tput transfer          DT_2    UT_2    100     40

    taf.ue.Detach Ue            UE_1

    [Teardown]  Run Keywords
    ...            Run keyword and ignore error        log to console      all done      AND
    ...            Run keyword and ignore error        taf.ue.Detach Ue    UE_1          AND
    ...            Run keyword and ignore error        AdminUtils.unlock all cells


USCB008935_B_IWK_2_3_Interworking_with_CB007552_SA

    Preconditions 7552
    Preconditions 8935

    Attach 2 UEs with BWP verification    MTK_UE   ASUS_UE

    # This only works in this particular order, with delays between each step. Go figure.
    Start tput transfer 1 stream only        UL  UT_1     UE_1     200     # UE1 tput
    BuiltIn.Sleep     5
    Start tput transfer 1 stream only        UL  UT_2     UE_2     200     # UE2 tput
    BuiltIn.Sleep     5
    Start tput transfer 1 stream only        DL  DT_1     UE_1     250     # UE1 tput
    BuiltIn.Sleep     5
    Start tput transfer 1 stream only        DL  DT_2     UE_2     250     # UE2 tput

    BuiltIn.Sleep     30

    Stop tput transfer 1 stream only        DT_1     100
    Stop tput transfer 1 stream only        DT_2     80
    Stop tput transfer 1 stream only        UT_1     50
    Stop tput transfer 1 stream only        UT_2     50


    [Teardown]  Run Keywords
    ...            Run keyword and ignore error        log to console      all done     AND
    ...            Run keyword and ignore error        taf.ue.Detach Ue    UE_1         AND
    ...            Run keyword and ignore error        taf.ue.Detach Ue    UE_2


##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####

Preconditions 8935
    Change 256 QAM Value           ${cells_used_in_8935}     false
    ${check_256_QAM_for_cells}=    check_256_qam      ${cells_used_in_8935}
    Should not be true             ${check_256_QAM_for_cells}

    AdminUtils.lock all cells
    AdminUtils.unlock cells        ${cells_used_in_8935}

    log to console              done

Preconditions 7552
    ${check_actMultipleDedicatedBWPs}=      check_actMultipleDedicatedBWPs
    Should be true                          ${check_actMultipleDedicatedBWPs}

    log to console              done

Attach
    [Arguments]    ${UE_caps}
    Setup cplane tcpdump collector
    Start cplane Logs
    Require UE          UE_1      ${UE_caps}
    Attach UE           UE_1
    BuiltIn.Sleep               10
    Stop cplane logs


Attach 2 UEs with BWP verification
    [Arguments]       ${UE_1_caps}     ${UE_2_caps}
    ...               ${PATH}=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/cplane_collector/cplane_collector.pcap
    Setup cplane tcpdump collector
    Start cplane Logs
    Require UE          UE_1      ${UE_1_caps}
    Attach UE           UE_1
    BuiltIn.Sleep               10s
    Stop cplane logs
    Verify bwp profile    ${PATH}    ${50mhz_ids}
    Start cplane Logs
    Require UE          UE_2      ${UE_2_caps}
    Attach UE           UE_2
    BuiltIn.Sleep    10
    Stop cplane logs
    Verify bwp profile    ${PATH}   ${30mhz_ids}


Start tput transfer
    [Arguments]     ${direction_1}    ${name_1}     ${ue_1}    ${tput_1}
    ...             ${direction_2}    ${name_2}     ${ue_2}    ${tput_2}

    log to console        - - - starting tput - - -

    Start data transfer   dt_name=${name_1}     ue_alias=${ue_1}         direction=${direction_1}       duration=1000s
    ...                   packet_size=1200      throughput=${tput_1} Mbits/sec                       protocol=udp
    ...                   iperf_version=3
    check_data_transfer_is_alive    ${name_1}

    Start data transfer   dt_name=${name_2}       ue_alias=${ue_2}        direction=${direction_2}     duration=1000s
    ...                   packet_size=1200      throughput=${tput_2} Mbits/sec   protocol=udp
    ...                   iperf_version=3
    check_data_transfer_is_alive    ${name_2}

Stop tput transfer
    [Arguments]    ${data_1}    ${data_2}    ${tput_dl}=100    ${tput_ul}=100
    Stop data transfer  ${data_1}
    Stop data transfer  ${data_2}
    log to console        - - - stopping tput - - -
    Verify average throughput   dt_name=${data_1}   tput_min=${tput_dl}Mbits/sec
    Verify average throughput   dt_name=${data_2}   tput_min=${tput_ul}Mbits/sec

Enabling 256 QAM params
    Change 256 QAM value                ${cells_used_in_8935}     true
    ${check_256_QAM_for_cells}=    check_256_qam       ${cells_used_in_8935}
    Should be true                  ${check_256_QAM_for_cells}

Start tput transfer 1 stream only
    [Arguments]     ${direction_1}    ${name_1}     ${ue_1}    ${tput_1}

    log to console        - - - starting ${direction_1} tput only - - -

    Start data transfer   dt_name=${name_1}     ue_alias=${ue_1}         direction=${direction_1}       duration=1000s
    ...                   packet_size=1200      throughput=${tput_1} Mbits/sec                       protocol=udp
    ...                   iperf_version=3
    check_data_transfer_is_alive    ${name_1}

Stop tput transfer 1 stream only
    [Arguments]         ${data_1}            ${tput_dl}=100
    Stop data transfer  ${data_1}
    log to console        - - - stopping tput - - -
    Verify average throughput   dt_name=${data_1}   tput_min=${tput_dl}Mbits/sec
