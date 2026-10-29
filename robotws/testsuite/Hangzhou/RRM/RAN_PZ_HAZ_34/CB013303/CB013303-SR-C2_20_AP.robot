# *** Settings ***
# Documentation
# ...    author: Zhong rebecca
# ...    contact: rebecca.zhong@nokia-sbell.com
# ...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_08
# Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F
# Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
# Test Setup        Common Test Setup And Start To Capture Logs
# Test Teardown     Common Test Teardown And Stop Capture Logs
# Force Tags        release-SBTS24R3    tl-CLOUD_5G_I_BOO_AP_LOO
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot
# 
# 
# *** Variables ***
# ${SYSCOM_FLAG}    True
# @{PARAMS_IN_IPHY_XML}  fddFrequencyRange=FR1_WB
# @{PARAMS_IN_SWCONFIG}
# ...    @{rdULCaEnablerPhase}
# ...    @{rdUseOptimizedDpaAlgo}
# ...    @{rd9169Enable}
# @{rdULCaEnablerPhase}
# ...    0x580591=0
# @{rd9169Enable}
# ...    0x580692=1
# @{rdUseOptimizedDpaAlgo}
# ...    0x58056B=1
# 
# ${Cell_2_TDD_PCI}    51
# ${Cell_3_TDD_PCI}    52
# ${Cell_12_FDD_PCI}    61
# ${Cell_11_FDD_PCI}    60
# ${Cell_13_FDD_PCI}    62
# ${Cell_14_FDD_PCI}    63
# 
# #the following parameters are used in pdm check
# ${TDD_PRB_for_80M}    217
# ${FDD_PRB_for_10M}    52
# ${FDD_PRB_for_20M}    106
# ${FDD_PRB_for_30M}    160
# ${TDD_PRB_for_60M}    162
# ${Cell_1_TDD_PCI}    50
# 
# # GNB configuration
# #TDD cell-1: band41 Chbw=60M PCI=50 (16385)
# #TDD cell-2: band78 chbw=80M PCI=51 (16386)
# 
# #FDD cell-11: band66 CHbw=20M PCI=60 (16395)
# #FDD cell-13: band66 CHbw=30M PCI=62 (16397)
# #FDD cell-12: band71 CHbw=10M PCI=61 (16396)
# #FDD cell-14: band71 CHbw=10M PCI=63 (16398)
# 
# ${carrierAggregationSupportList}    SEPARATOR=
# ...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,
# ...    ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl,ca_Fdd_Fr1Tdd_Sa_WithUl
# 
# 
# ${a1ThresholdSCellAddSsbRsrpFDD}    50
# 
# 
# ${N41DLUL_N78DL_and_N41DLUL_N66DLUL_N71DLUL_without_lch}    SEPARATOR=
# ...    F9A0700047D0FFA17DF8E6BC520001A0349CF9A44F3E005800C403E03E0300FC700FBCF89A01EF7ADC3419140838
# ...    00001D708800A2D92D502C09F21CFA023C639F30C7942C0E070F0527FC9FF1A20003650000500000379F10403DEF
# ...    5B8683228107000003AE1100145B25AA05813E439F40478C73E618F28581C0E1E0C9FFA7FEDE7C4600F7BD6E1A0C
# ...    8A041C00000EB84400516C96A81604F90E7D011E31CF9863CA160703878327FE9FFF79F0A003DEF5B86832281070
# ...    00003AE1100145B25AA05813E439F40478C73E618F28581C0E1E0C4FF93FE3440006CA0000A000000250B882001C
# ...    28000E268000080980A83C28000E26800000098080380510136020C0461B40004405100D8E7C3040001C086307F0
# ...    000003E000F800AC70500703F09001C0C0018003E021CB400001C01CB400005C01CB400009C01CB40000DC01CB40
# ...    0011C0008CA4BCA8AC0CACA4AC14A018300000030000C0000A0C000300004030000C000180C00006E5305F2A82B8
# ...    2C15CA60A1E0022009E0F0783C1E0000808080100202004008404008000100400820200C01808010001010060000
# ...    40080100080400810100A00C0401000080805000020080104140280380300700A00C140080180400900400840201
# ...    4018080100202004008D40380010203038D92939278140601480
# 
# ${SOS_REPORT_FLAG}    pass:False,fail:False
# 
# *** Test Cases ***
# CB013303-SR-C2_20_UL SCell addition after associated non-CA eligible nonGBR DRB setup when UE not support lchToSCellRestriction
#     [Documentation]
#     ...    precondition:
#     ...    UE_capabilit:N41A*-N78A*, N41A*-N66A*-N66A*
#     ...    dlToUlContributionRatio=50, NRcell-13:maxNumOfSCellAlloc=1
#     ...    scell addition A1 threshold: a1ThresholdSCellAddSsbRsrpFDD=60, a1ThresholdSCellAddSsbRsrpTDD=50
#     ...    step1: register UE1 to FDD cell-11 and setup PDU with 5qi6 and 5qi7
#     ...    step2: start traffic on UL and DL
#     ...    step3: trigger
#     ...    step4: UE-1 report A1 for F+T+T 3CC scell addition with RSRP large than TDD only
#     delta commission parameters and wait cells onair    ${C2_20_PARAMS}
#     Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-11    ue_id=1
#     UE start DL And UL traffic    ue_id=1
#     Trigger BLER To GNB    ue_id=1
#     Send A1 report to trigger TDD Scell Addition with RSRP large than TDD threshold    ue_id=1    cell_freq=${cell_11_ssbFrequency}
# 
# 
# *** Keywords ***
# Modify Cfg
#     Update Cfg    set_qosflow id=1 5qi=7 default=on
#     Update Cfg    set_qosflow id=3 5qi=1
#     Update Cfg    set_qosflow id=2 5qi=5
#     Update Cfg    set_qosflow id=4 5qi=2
#     Update Cfg    set_qosflow id=5 5qi=3
#     Update Cfg    set_qosflow id=6 5qi=4
#     Update Cfg    set_qosflow id=7 5qi=6
#     Update Cfg    set_qosflow id=8 5qi=8
#     Update Cfg    set_qosflow id=9 5qi=128 qos_flow_type=gbr mfbr_dl=250 mfbr_ul=250 gfbr_dl=120 gfbr_ul=120
#     Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
#     Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
#     Update Cfg    set_nwslice id=1 qos_flows=8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=1-30 amf=1
#     Update Cfg    ue_nr_capabilities id=1-30 voice_over_nr=on:on:off
#     Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
#     ${Update_Cfg_4}    catenate
#     ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222
#     ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
#     Update Cfg    ${Update_Cfg_4}
#     Update Cfg    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=off proxy=10.0.2.92:9999 nr_arfcn=136100:126900 gscn=1587
#     Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true
#     Update Cfg    gnb_param id=3 x2_listening_socket=1 measEvent=A3
#     FOR    ${SA_id}    IN RANGE    1    31
#         Update Cfg    set_pdu_gateway id=${SA_id} ue_nat_ip=72.23.0.${SA_id} dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
#     END
# 
# Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-11
#     [Arguments]    ${ue_id}=1    ${ue_capa}=${N41DLUL_N78DL_and_N41DLUL_N66DLUL_N71DLUL_without_lch}
#     Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=11
#     Additional qosflows to activate    id=1    addition_qosflow=7
#     Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
#     Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
#     Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=QoS Routing Table
# 
# Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-11 and trigger blind CA
#     [Arguments]    ${ue_id}=1    ${ue_capa}=${N41DLUL_N78DL_and_N41DLUL_N66DLUL_N71DLUL_without_lch}
#     Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=11
#     Additional qosflows to activate    id=1    addition_qosflow=7
#     Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
#     Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
#     ${expect_output}    Create List
#     ...    rrcReconfigurationComplete
#     ...    pcid:${Cell_1_TDD_PCI}, scellIdx:1
#     ...    pcid:${Cell_2_TDD_PCI}, scellIdx:2
#     Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=${expect_output}
# 
# Additional qosflows to activate
#     [Arguments]    ${id}=1    ${addition_qosflow}=1
#     Execute Egate Command      smf_param id=${id} reset
#     Execute Egate Command      smf_param id=${id} additional_qosflows_to_activate=${addition_qosflow}
# 
# Send A1 report to trigger TDD Scell Addition with RSRP large than TDD threshold
#     [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_11_ssbFrequency}
#     Start rrc log    TDD_scell_add_UE${ue_id}
#     ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
#     ${expect_output}    Create List
#     ...    rrcReconfigurationComplete
#     ...    pcid:${Cell_1_TDD_PCI}, scellIdx:1
#     ...    pcid:${Cell_2_TDD_PCI}, scellIdx:2
#     ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=55 ssinr_nr=120 srsrq_nr=32
#     ...    pass_regexp=${expect_output}
#     ${ttitrace_log_path}     Capture Gnb Ttitrace For A While    tag=scell_add_A1    cell_id=1,2,11     decode_flag=True
#     Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#     ...                      targetbler=0.05
#     ...                      stepdown=0.8
#     ...                      cell_ids=11
#     ...                      mcstable=QAM64
#     Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#     ...                      targetbler=0.05
#     ...                      stepdown=0.8
#     ...                      cell_ids=2
#     ...                      mcstable=QAM64
#     sleep    10s
#     Get RRC log
# 
# Send A1 report to trigger FDD Scell Addition with RSRP large than FDD threshold
#     [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
#     Start rrc log    FDD_scell_add_UE${ue_id}
#     ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
#     ${expect_output}    Create List
#     ...    rrcReconfigurationComplete
#     ...    scellIdx:1
#     ...    scellIdx:2
#     ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=55 ssinr_nr=120 srsrq_nr=32
#     ...    pass_regexp=${expect_output}
#     Get RRC log
# 
# UE start DL And UL traffic
#     [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${qfi_id_2}=2
#     Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=1    pass_regexp=Started Downlink
#     Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=2    pass_regexp=Started Downlink
#     Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=3    pass_regexp=Started Downlink
#     Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id_2} dir=dl mbps=170 trf_id=1    pass_regexp=Started Downlink
#     Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=100 trf_id=1    pass_regexp=Started Uplink
#     Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id_2} dir=ul mbps=100 trf_id=1    pass_regexp=Started Uplink
# #trigger iBLER for UE
# #    [Arguments]    ${ue_id}=1
# #    Execute Egate Command    ue_harq_error id=${ue_id} cell=current scell=0-7 tb1_err_ratio=0-7:100:20:0 ul_err_ratio=0-7:100:20:0
# #    sleep  20s
# 
# Trigger BLER To GNB
#     [Arguments]    ${ue_id}=1    ${scell_id1}=1    ${scell_id2}=2
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=70
#     Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1 scell=0
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=80
#     Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1 scell=0
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=90
#     Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1 scell=0
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=100
#     Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1 scell=0
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=110
#     Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1 scell=0
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=70
#     Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1 scell=${scell_id1}
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=80
#     Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1 scell=${scell_id1}
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=90
#     Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1 scell=${scell_id1}
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=100
#     Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1 scell=${scell_id1}
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=110
#     Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1 scell=${scell_id1}
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=70
#     Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1 scell=${scell_id2}
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=80
#     Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1 scell=${scell_id2}
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=90
#     Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1 scell=${scell_id2}
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=100
#     Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1 scell=${scell_id2}
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=110
#     Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1 scell=${scell_id2}
#     Execute Egate Command    ul_sinr_testmode_nr profile_id=1
#     Sleep    2s
# 
# ADD 5QI-8 AND CHECK BLER
#     [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=8
#     ${ret1}=  Execute Egate Command  ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qfi_id} by=amf
#     ...  pass_regexp=Received Uplink NAS Transport Message with RAN UE NGAP ID
#     Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi 8 qfi 3
#     sleep  20s
# 
# release 5QI-8 AND CHECK BLER
#     [Arguments]    ${ue_id}=1    ${qfi_id}=8
#     ${ret1}=  Execute Egate Command  ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qfi_id} by=amf
#     ...  rrcReconfigurationComplete
#     Should Contain  ${ret1}  Removed FiveQi:Qfi mapping fiveQi 8 qfi 3
#     sleep  10s
# 
# Check TTI Trace
#     [Arguments]    ${tag}=CB008285_B_01    ${physCellId}=50    ${trf_dir}=uldl
#     Decode Log File And Convet File Format
#     ...    tag=${tag}    target_dir=${SAVE LOG DIRECTORY}
#     ${list_physCellId}=    Evaluate    list(map(float, @{physCellId.split('|')}))
#     ${list_physCellId}=    Evaluate    list(map(int, @{list_physCellId}))
#     ${cell_cnt}=    Evaluate    int(len(${list_physCellId}))
#     Run Keyword    Validate TTI Trace ${cell_cnt}Cell
#     ...    tag=${tag}    list_physCellId=${list_physCellId}      trf_dir=${trf_dir}