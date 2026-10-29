*** Settings ***
Documentation    Suite description
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/FGCR-10228/resources/kw_10228.py
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
*** Keywords ***
Set attenuator for 10228 step 1
    Turn off attenuation         # 10.42.54.152
    Turn off attenuation_2       # 10.42.61.6
    Set attenuation and check  lines=${lines_gNB_190_AHLOA_1_TDD}   value=0   #AHLOA PCI:101
    Set attenuation and check  lines=${lines_gNB_190_AHLOA_2_TDD}   value=0   #AHLOA PCI:102
    Set attenuation and check  lines=${lines_gNB_190_AHLOA_3_TDD}   value=0   #AHLOA PCI:103

Set attenuator for 10228 step 2
    Set attenuation_2 and check    lines=${lines_gNB_190_AHLOA_3_FDD}   value=0   #AEHC PCI:104
    Set attenuation_2 and check    lines=${lines_gNB_190_AEHC_4_FDD}   value=0    #AEHC PCI:105
    Set attenuation_2 and check    lines=${lines_gNB_190_AEHC_5_FDD}   value=0    #AEHC PCI:106
    Set attenuation and check  lines=${lines_gNB_190_AHFIB_5_FDD}   value=0   #AHLOA PCI:107

Start tput on Qualcomm UE1
    [Arguments]     ${tput_DL_bandwith}=35Mbits/sec   ${tput_UL_bandwith}=15MBits/sec  ${tput_duration}=300s
    sleep                5s
    Start Data Transfer  dt_name=DT_DL_UE1  ue_alias=UE_1  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp   packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_UE1  ue_alias=UE_1  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                20s
    Check Data Transfer Is Alive               DT_DL_UE1
    Check Data Transfer Is Alive               DT_UL_UE1

Start tput on Samsung UE2
    [Arguments]     ${tput_DL_bandwith}=35Mbits/sec   ${tput_UL_bandwith}=15MBits/sec  ${tput_duration}=300s
    sleep                5s
    Start Data Transfer  dt_name=DT_DL_UE2  ue_alias=UE_2  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp   packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_UE2  ue_alias=UE_2  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                20s
    Check Data Transfer Is Alive               DT_DL_UE2
    Check Data Transfer Is Alive               DT_UL_UE2

Start tput on Samsung UE3
    [Arguments]     ${tput_DL_bandwith}=35Mbits/sec   ${tput_UL_bandwith}=15MBits/sec  ${tput_duration}=300s
    sleep                5s
    Start Data Transfer  dt_name=DT_DL_UE3  ue_alias=UE_3  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp   packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_UE3  ue_alias=UE_3  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                20s
    Check Data Transfer Is Alive               DT_DL_UE3
    Check Data Transfer Is Alive               DT_UL_UE3

Start tput on Nokia UE4
    [Arguments]     ${tput_DL_bandwith}=35Mbits/sec   ${tput_UL_bandwith}=15MBits/sec  ${tput_duration}=300s
    sleep                5s
    Start Data Transfer  dt_name=DT_DL_UE4  ue_alias=UE_4  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp   packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_UE4  ue_alias=UE_4  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                20s
    Check Data Transfer Is Alive               DT_DL_UE4
    Check Data Transfer Is Alive               DT_UL_UE4

Verify tputs
    [Arguments]     ${tput_DL_bandwith}=35Mbits/sec   ${tput_UL_bandwith}=15MBits/sec
    Await Data Transfer Finish                 DT_UL_UE1
    Verify Average Throughput With Deviation   DT_UL_UE1   ${tput_UL_bandwith}   ${tput_deviation}
    Await Data Transfer Finish                 DT_DL_UE1
    Verify Average Throughput With Deviation   DT_DL_UE1   ${tput_DL_bandwith}   ${tput_deviation}

    Await Data Transfer Finish                 DT_UL_UE2
    Verify Average Throughput With Deviation   DT_UL_UE2   ${tput_UL_bandwith}   ${tput_deviation}
    Await Data Transfer Finish                 DT_DL_UE2
    Verify Average Throughput With Deviation   DT_DL_UE2   ${tput_DL_bandwith}   ${tput_deviation}

    Await Data Transfer Finish                 DT_UL_UE3
    Verify Average Throughput With Deviation   DT_UL_UE3   ${tput_UL_bandwith}   ${tput_deviation}
    Await Data Transfer Finish                 DT_DL_UE3
    Verify Average Throughput With Deviation   DT_DL_UE3   ${tput_DL_bandwith}   ${tput_deviation}

Veryfy tput on Nokia
    [Arguments]     ${tput_DL_bandwith}=35Mbits/sec   ${tput_UL_bandwith}=15MBits/sec
    Await Data Transfer Finish                 DT_UL_UE4
    Verify Average Throughput With Deviation   DT_UL_UE4   ${tput_UL_bandwith}   ${tput_deviation}
    Await Data Transfer Finish                 DT_DL_UE4
    Verify Average Throughput With Deviation   DT_DL_UE4   ${tput_DL_bandwith}   ${tput_deviation}

check how much uniq lines in syslog
    [Arguments]    ${grepfilter}    ${expected value}
    ${syslogOutput}    Run    grep -i "${grepfilter}" ${OUTPUT DIR}/${SUITE NAME}/${test_name}.log |awk -F '>' '{print $2}'sort|uniq|wc -l
    should contain    ${syslogOutput}    ${expected value}

Verify registration to FDD PCells
    # [Arguments]    ${file_path}=${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    unpack collected syslog
    check if exist in syslog    AddedServingCellsList     Store addedSCellList:AddedServingCellsList
    check if exist in syslog    ScellAddition
    ...                         ScellAddition procedure Completed with No ScellAddition Error for ueIdCu
   # check how much uniq lines in syslog   ScellAddition   4

Verify TDD SCells activation
    # [Arguments]    ${file_path}=${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    unpack collected syslog
    check if exist in syslog    handleActivateMacCe     handleActivateMacCe done for UE
    check how much uniq lines in syslog   handleActivateMacCe done for UE   3

Read counters value 10228
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list  M55316C09000  M55118C05507  M55118C05508  M55311C42009  M55311C44009
    FOR    ${counter}    IN      @{counters}
       ${value}     Get sum of n last counter values   4  ${counter}
       Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 10228
    log to console              Waiting for BTS Counters update 300s
    sleep   300s
    log to console              Verify PM counters values
    ${counters}                 Read Counters Value 10228
    ${pcell_104}                    get_counter_value   ${counters}  104    M55316C09000
    ${pcell_105}                    get_counter_value   ${counters}  105    M55316C09000
    ${pcell_106}                    get_counter_value   ${counters}  106    M55316C09000
    ${ca_ues_scell_101}             get_counter_value   ${counters}  101    M55118C05507
    ${ca_ues_scell_102}             get_counter_value   ${counters}  102    M55118C05507
    ${ca_ues_scell_103}             get_counter_value   ${counters}  103    M55118C05507
    ${ca_ues_pcell_104}             get_counter_value   ${counters}  104    M55118C05508
    ${ca_ues_pcell_105}             get_counter_value   ${counters}  105    M55118C05508
    ${ca_ues_pcell_106}             get_counter_value   ${counters}  106    M55118C05508
    # ${RLC_PDU_vol_over_pcell}   get_counter_value   ${counters}  1      M55311C42009
    # ${RLC_PDU_vol_over_scell}   get_counter_value   ${counters}  1      M55311C44009
    Should Be True      0<${pcell_104}
    Should Be True      0<${pcell_105}
    Should Be True      0<${pcell_106}
    Should Be True      250<=${ca_ues_scell_101}
    Should Be True      250<=${ca_ues_scell_102}
    Should Be True      250<=${ca_ues_scell_103}
    Should Be True      250<=${ca_ues_pcell_104}
    Should Be True      250<=${ca_ues_pcell_105}
    Should Be True      250<=${ca_ues_pcell_106}
    # ${calc1}           Evaluate  (${RLC_PDU_vol_over_pcell} * 8) / 300
    # ${calc2}           Evaluate  (${RLC_PDU_vol_over_scell} * 8) / 300
