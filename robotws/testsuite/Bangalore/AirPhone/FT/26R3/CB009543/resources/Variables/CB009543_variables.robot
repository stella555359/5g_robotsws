*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB008235 only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com


Resource          ../../../../resources/Keywords/gnbbip_convert.robot

*** Variables ***


${CFG_GNB_SCF_DELTA_JSON}          ${CURDIR}/../../config/gnb/CB009543_gNB_Subcell_switch_FDD_SCF.xml
${CB009543_GNB_SCF_DELTA_JSON}               CB009543_gNB_Subcell_switch_FDD_SCF.xml
${CFG_AP_IPHY}                     ${CURDIR}/../../config/ap/CB009543_Subcell_switch_FDD_IPHY.xml
${CFG_WTS_CFG}                     ${CURDIR}/../../config/wts/CB009543_Subcell_switch_FDD_WTS.cfg




#Basic UE1 register traffic deregister
${CM_UE1_DTYPE_INTERNAL}           set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE_1_REGISTER}                ue_register id=1
${CM_UE_1_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
${CM_UE_1_UL_2_MBPS_DATA}                  trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=2 trf_id=1
${CM_UE_1_DL_2_MBPS_DATA}                  trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=2 trf_id=1
${CM_UE_1_DEREG}                   ue_deregister id=1 ue_deregister_type=switch_off

#Basic UE2 register traffic deregister
${CM_UE2_DTYPE_INTERNAL}           set_pdu_param ue=2 pdu=1 trf_type=internal
${CM_UE_2_REGISTER}                ue_register id=2
${CM_UE_2_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=2 nwslice=1 gw=1
${CM_UE_2_UL_2_MBPS_DATA}                  trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=2 trf_id=1
${CM_UE_2_DL_2_MBPS_DATA}                  trf_data_start ue=2 pdu=1 qfi=1 dir=dl mbps=2 trf_id=1
${CM_UE_2_DEREG}                   ue_deregister id=2 ue_deregister_type=switch_off

#Basic UE3 register traffic deregister
${CM_UE3_DTYPE_INTERNAL}           set_pdu_param ue=3 pdu=1 trf_type=internal
${CM_UE_3_REGISTER}                ue_register id=3
${CM_UE_3_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=3 nwslice=1 gw=1
${CM_UE_3_UL_2_MBPS_DATA}                  trf_data_start ue=3 pdu=1 qfi=1 dir=ul mbps=2 trf_id=1
${CM_UE_3_DL_2_MBPS_DATA}                  trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=2 trf_id=1
${CM_UE_3_DEREG}                   ue_deregister id=3 ue_deregister_type=switch_off

#Basic UE4 register traffic deregister
${CM_UE4_DTYPE_INTERNAL}           set_pdu_param ue=4 pdu=1 trf_type=internal
${CM_UE_4_REGISTER}                ue_register id=4
${CM_UE_4_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=4 nwslice=1 gw=1
${CM_UE_4_UL_2_MBPS_DATA}                  trf_data_start ue=4 pdu=1 qfi=1 dir=ul mbps=2 trf_id=1
${CM_UE_4_DL_2_MBPS_DATA}                  trf_data_start ue=4 pdu=1 qfi=1 dir=dl mbps=2 trf_id=1
${CM_UE_4_DEREG}                   ue_deregister id=4 ue_deregister_type=switch_off

#Basic UE5 register traffic deregister
${CM_UE5_DTYPE_INTERNAL}           set_pdu_param ue=5 pdu=1 trf_type=internal
${CM_UE_5_REGISTER}                ue_register id=5
${CM_UE_5_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=5 nwslice=1 gw=1
${CM_UE_5_UL_2_MBPS_DATA}                  trf_data_start ue=5 pdu=1 qfi=1 dir=ul mbps=2 trf_id=1
${CM_UE_5_DL_2_MBPS_DATA}                  trf_data_start ue=5 pdu=1 qfi=1 dir=dl mbps=2 trf_id=1
${CM_UE_5_DEREG}                   ue_deregister id=5 ue_deregister_type=switch_off

#Basic UE6 register traffic deregister
${CM_UE6_DTYPE_INTERNAL}           set_pdu_param ue=6 pdu=1 trf_type=internal
${CM_UE_6_REGISTER}                ue_register id=6
${CM_UE_6_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=6 nwslice=1 gw=1
${CM_UE_6_UL_2_MBPS_DATA}                  trf_data_start ue=6 pdu=1 qfi=1 dir=ul mbps=2 trf_id=1
${CM_UE_6_DL_2_MBPS_DATA}                  trf_data_start ue=6 pdu=1 qfi=1 dir=dl mbps=2 trf_id=1
${CM_UE_6_DEREG}                   ue_deregister id=6 ue_deregister_type=switch_off


#Basic UE7 register traffic deregister
${CM_UE7_DTYPE_INTERNAL}           set_pdu_param ue=7 pdu=1 trf_type=internal
${CM_UE_7_REGISTER}                ue_register id=7
${CM_UE_7_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=7 nwslice=1 gw=1
${CM_UE_7_UL_2_MBPS_DATA}                  trf_data_start ue=7 pdu=1 qfi=1 dir=ul mbps=2 trf_id=1
${CM_UE_7_DL_2_MBPS_DATA}                  trf_data_start ue=7 pdu=1 qfi=1 dir=dl mbps=2 trf_id=1
${CM_UE_7_DEREG}                   ue_deregister id=7 ue_deregister_type=switch_off

#Basic UE8 register traffic deregister
${CM_UE8_DTYPE_INTERNAL}           set_pdu_param ue=8 pdu=1 trf_type=internal
${CM_UE_8_REGISTER}                ue_register id=8
${CM_UE_8_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=8 nwslice=1 gw=1
${CM_UE_8_UL_2_MBPS_DATA}                  trf_data_start ue=8 pdu=1 qfi=1 dir=ul mbps=2 trf_id=1
${CM_UE_8_DL_2_MBPS_DATA}                  trf_data_start ue=8 pdu=1 qfi=1 dir=dl mbps=2 trf_id=1
${CM_UE_8_DEREG}                        ue_deregister id=8 ue_deregister_type=switch_off

#Basic UE9 register traffic deregister
${CM_UE9_DTYPE_INTERNAL}           set_pdu_param ue=9 pdu=1 trf_type=internal
${CM_UE_9_REGISTER}                ue_register id=9
${CM_UE_9_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=9 nwslice=1 gw=1
${CM_UE_9_UL_2_MBPS_DATA}                  trf_data_start ue=9 pdu=1 qfi=1 dir=ul mbps=2 trf_id=1
${CM_UE_9_DL_2_MBPS_DATA}                  trf_data_start ue=9 pdu=1 qfi=1 dir=dl mbps=2 trf_id=1
${CM_UE_9_DEREG}                   ue_deregister id=9 ue_deregister_type=switch_off


#Basic UE10 register traffic deregister
${CM_UE10_DTYPE_INTERNAL}           set_pdu_param ue=10 pdu=1 trf_type=internal
${CM_UE_10_REGISTER}                ue_register id=10
${CM_UE_10_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=10 nwslice=1 gw=1
${CM_UE_10_UL_2_MBPS_DATA}                  trf_data_start ue=10 pdu=1 qfi=1 dir=ul mbps=2 trf_id=1
${CM_UE_10_DL_2_MBPS_DATA}                  trf_data_start ue=10 pdu=1 qfi=1 dir=dl mbps=2 trf_id=1
${CM_UE_10_DEREG}                   ue_deregister id=10 ue_deregister_type=switch_off

#Basic UE11 register traffic deregister
${CM_UE11_DTYPE_INTERNAL}           set_pdu_param ue=11 pdu=1 trf_type=internal
${CM_UE_11_REGISTER}                ue_register id=11
${CM_UE_11_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=11 nwslice=1 gw=1
${CM_UE_11_UL_2_MBPS_DATA}                  trf_data_start ue=11 pdu=1 qfi=1 dir=ul mbps=2 trf_id=1
${CM_UE_11_DL_2_MBPS_DATA}                  trf_data_start ue=11 pdu=1 qfi=1 dir=dl mbps=2 trf_id=1
${CM_UE_11_DEREG}                   ue_deregister id=11 ue_deregister_type=switch_off

#Basic UE12 register traffic deregister
${CM_UE12_DTYPE_INTERNAL}           set_pdu_param ue=12 pdu=1 trf_type=internal
${CM_UE_12_REGISTER}                ue_register id=12
${CM_UE_12_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=12 nwslice=1 gw=1
${CM_UE_12_UL_2_MBPS_DATA}                  trf_data_start ue=12 pdu=1 qfi=1 dir=ul mbps=2 trf_id=1
${CM_UE_12_DL_2_MBPS_DATA}                  trf_data_start ue=12 pdu=1 qfi=1 dir=dl mbps=2 trf_id=1
${CM_UE_12_DEREG}                   ue_deregister id=12 ue_deregister_type=switch_off

#PROFILE_CREATE CMDS
${FDD_SUPER_PROFILE_CREATE_UE1}              fdd_supercell_nr profile_id=1 mode=ATTACH serv_subcell_id=1
${FDD_SUPER_PROFILE_CREATE_UE2}              fdd_supercell_nr profile_id=2 mode=ATTACH serv_subcell_id=2
${FDD_SUPER_PROFILE_CREATE_UE3}              fdd_supercell_nr profile_id=3 mode=ATTACH serv_subcell_id=3
${FDD_SUPER_PROFILE_CREATE_UE4}              fdd_supercell_nr profile_id=4 mode=ATTACH serv_subcell_id=4
${FDD_SUPER_PROFILE_CREATE_UE5}              fdd_supercell_nr profile_id=5 mode=ATTACH serv_subcell_id=1
${FDD_SUPER_PROFILE_CREATE_UE6}              fdd_supercell_nr profile_id=6 mode=ATTACH serv_subcell_id=2
${FDD_SUPER_PROFILE_CREATE_UE7}              fdd_supercell_nr profile_id=7 mode=ATTACH serv_subcell_id=3
${FDD_SUPER_PROFILE_CREATE_UE8}              fdd_supercell_nr profile_id=8 mode=ATTACH serv_subcell_id=4
${FDD_SUPER_PROFILE_CREATE_UE9}              fdd_supercell_nr profile_id=9 mode=ATTACH serv_subcell_id=1
${FDD_SUPER_PROFILE_CREATE_UE10}              fdd_supercell_nr profile_id=10 mode=ATTACH serv_subcell_id=2
${FDD_SUPER_PROFILE_CREATE_UE11}              fdd_supercell_nr profile_id=11 mode=ATTACH serv_subcell_id=3
${FDD_SUPER_PROFILE_CREATE_UE12}              fdd_supercell_nr profile_id=12 mode=ATTACH serv_subcell_id=4

#PROFILE Activation cmds

${FDD_SUPER_PROFILE_ACTIVATION_UE1}             ue_testmode_set_nr profile_id=1 testmode=fdd_supercell_testmode_nr id=1 action=activate
${FDD_SUPER_PROFILE_ACTIVATION_UE2}             ue_testmode_set_nr profile_id=2 testmode=fdd_supercell_testmode_nr id=2 action=activate
${FDD_SUPER_PROFILE_ACTIVATION_UE3}             ue_testmode_set_nr profile_id=3 testmode=fdd_supercell_testmode_nr id=3 action=activate
${FDD_SUPER_PROFILE_ACTIVATION_UE4}             ue_testmode_set_nr profile_id=4 testmode=fdd_supercell_testmode_nr id=4 action=activate
${FDD_SUPER_PROFILE_ACTIVATION_UE5}             ue_testmode_set_nr profile_id=5 testmode=fdd_supercell_testmode_nr id=5 action=activate
${FDD_SUPER_PROFILE_ACTIVATION_UE6}             ue_testmode_set_nr profile_id=6 testmode=fdd_supercell_testmode_nr id=6 action=activate
${FDD_SUPER_PROFILE_ACTIVATION_UE7}             ue_testmode_set_nr profile_id=7 testmode=fdd_supercell_testmode_nr id=7 action=activate
${FDD_SUPER_PROFILE_ACTIVATION_UE8}             ue_testmode_set_nr profile_id=8 testmode=fdd_supercell_testmode_nr id=8 action=activate
${FDD_SUPER_PROFILE_ACTIVATION_UE9}             ue_testmode_set_nr profile_id=9 testmode=fdd_supercell_testmode_nr id=9 action=activate
${FDD_SUPER_PROFILE_ACTIVATION_UE10}            ue_testmode_set_nr profile_id=10 testmode=fdd_supercell_testmode_nr id=10 action=activate
${FDD_SUPER_PROFILE_ACTIVATION_UE11}            ue_testmode_set_nr profile_id=11 testmode=fdd_supercell_testmode_nr id=11 action=activate
${FDD_SUPER_PROFILE_ACTIVATION_UE12}            ue_testmode_set_nr profile_id=12 testmode=fdd_supercell_testmode_nr id=12 action=activate

#subcelL SWITCH SUB-CELL-2
${FDD_SUPER_SUBCELL_SWITCH_2_UE1}             fdd_supercell_nr profile_id=1 mode=SUBCELL_SWITCH dest_subcell_id=2 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_2_UE2}             fdd_supercell_nr profile_id=2 mode=SUBCELL_SWITCH dest_subcell_id=2 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_2_UE3}             fdd_supercell_nr profile_id=3 mode=SUBCELL_SWITCH dest_subcell_id=2 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-2
${FDD_SUPER_SUBCELL_SWITCH_2_UE4}             fdd_supercell_nr profile_id=4 mode=SUBCELL_SWITCH dest_subcell_id=2 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_2_UE5}             fdd_supercell_nr profile_id=5 mode=SUBCELL_SWITCH dest_subcell_id=2 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_2_UE6}             fdd_supercell_nr profile_id=6 mode=SUBCELL_SWITCH dest_subcell_id=2 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_2_UE7}             fdd_supercell_nr profile_id=7 mode=SUBCELL_SWITCH dest_subcell_id=2 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_2_UE8}             fdd_supercell_nr profile_id=8 mode=SUBCELL_SWITCH dest_subcell_id=2 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_2_UE9}             fdd_supercell_nr profile_id=9 mode=SUBCELL_SWITCH dest_subcell_id=2 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_2_UE10}             fdd_supercell_nr profile_id=10 mode=SUBCELL_SWITCH dest_subcell_id=2 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23

#subcelL SWITCH SUB-CELL-3
${FDD_SUPER_SUBCELL_SWITCH_3_UE1}             fdd_supercell_nr profile_id=1 mode=SUBCELL_SWITCH dest_subcell_id=3 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_3_UE2}             fdd_supercell_nr profile_id=2 mode=SUBCELL_SWITCH dest_subcell_id=3 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_3_UE3}             fdd_supercell_nr profile_id=3 mode=SUBCELL_SWITCH dest_subcell_id=3 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-2
${FDD_SUPER_SUBCELL_SWITCH_3_UE4}             fdd_supercell_nr profile_id=4 mode=SUBCELL_SWITCH dest_subcell_id=3 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_3_UE5}             fdd_supercell_nr profile_id=5 mode=SUBCELL_SWITCH dest_subcell_id=3 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_3_UE6}             fdd_supercell_nr profile_id=6 mode=SUBCELL_SWITCH dest_subcell_id=3 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_3_UE7}             fdd_supercell_nr profile_id=7 mode=SUBCELL_SWITCH dest_subcell_id=3 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_3_UE8}             fdd_supercell_nr profile_id=8 mode=SUBCELL_SWITCH dest_subcell_id=3 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_3_UE9}             fdd_supercell_nr profile_id=9 mode=SUBCELL_SWITCH dest_subcell_id=3 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_3_UE10}             fdd_supercell_nr profile_id=10 mode=SUBCELL_SWITCH dest_subcell_id=3 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23


#subcelL SWITCH SUB-CELL-4
${FDD_SUPER_SUBCELL_SWITCH_4_UE1}             fdd_supercell_nr profile_id=1 mode=SUBCELL_SWITCH dest_subcell_id=4 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_4_UE2}             fdd_supercell_nr profile_id=2 mode=SUBCELL_SWITCH dest_subcell_id=4 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_4_UE3}             fdd_supercell_nr profile_id=3 mode=SUBCELL_SWITCH dest_subcell_id=4 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_4_UE4}             fdd_supercell_nr profile_id=4 mode=SUBCELL_SWITCH dest_subcell_id=4 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_4_UE5}             fdd_supercell_nr profile_id=5 mode=SUBCELL_SWITCH dest_subcell_id=4 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_4_UE6}             fdd_supercell_nr profile_id=6 mode=SUBCELL_SWITCH dest_subcell_id=4 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_4_UE7}             fdd_supercell_nr profile_id=7 mode=SUBCELL_SWITCH dest_subcell_id=4 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_4_UE8}             fdd_supercell_nr profile_id=8 mode=SUBCELL_SWITCH dest_subcell_id=4 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_4_UE9}             fdd_supercell_nr profile_id=9 mode=SUBCELL_SWITCH dest_subcell_id=4 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23
${FDD_SUPER_SUBCELL_SWITCH_4_UE10}             fdd_supercell_nr profile_id=10 mode=SUBCELL_SWITCH dest_subcell_id=4 dest_subcell_tx_power_offset=23
...           serv_subcell_tx_power_reduction=-23


${Log_Path}                        /home/ute/logs

${MCSHARK_PLUGIN}                  /home/ute/wireshark/plugins
${tashark_version}                 4.2
${BSR_FILE_AVQL}                   ${CURDIR}/../../config/gnb/BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip
${BSR_FILE_AVQL_PASS}              /home/ute/Desktop/12_01_worked_CB011059/BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip
${FILTER_CB009543_1}                      UlData_prachReceiveIndSubcell_t.detectedPrachPreambles.Length !=0
${FILTER_CB009543_2}                    UlData_prachReceiveIndSubcell_t.detectedPrachPreambles.Length !=0
${BIP_CSV_NAME}                    BIP_L1L2_filter_SCN1.csv
${BIP_CSV_SUBCELL_1}               BIP_L1L2_SUBCELL_1.csv
${BIP_CSV_SUBCELL_2}               BIP_L1L2_SUBCELL_2.csv
${BIP_CSV_SUBCELL_3}               BIP_L1L2_SUBCELL_3.csv
${BIP_CSV_SUBCELL_4}               BIP_L1L2_SUBCELL_4.csv
