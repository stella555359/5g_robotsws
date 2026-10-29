*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/tti/tti.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008717/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009208/resources/CB009208_kw.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009208/resources/CB009208.py    WITH NAME    CB009208
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009208/resources/CB009208.py


*** Variables ***
${srs_beams_tput_DL_bandwith}          100 Mbits/sec
${srs_beams_tput_UL_bandwith}          50 MBits/sec
${srs_beams_tput_duration}             200s
${srs_beams_ps_config_step_1}          ${CURDIR}${/}resources${/}ps_configs${/}CB009208-C_Check_best_and_second_used_DL_SRS_beams_with_2CSIRS_1.csv
${srs_beams_ps_config_step_2}          ${CURDIR}${/}resources${/}ps_configs${/}CB009208-C_Check_best_and_second_used_DL_SRS_beams_with_2CSIRS_2.csv
${srs_beams_apn_name}                  internet

${mu_scheduling_ps_config}             ${CURDIR}${/}resources${/}ps_configs${/}CB009208-C_MU_scheduling_with_dynamic_DL_beam_tapering_selection.csv
${mu_scheduling_tput_DL_bandwith}      1500 Mbits/sec
${mu_scheduling_tput_duration}         80s

${c_packet_Size}                       1300
${mrbts_id}                            ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${beam_template_dir}                   ${CURDIR}${/}resources${/}beam_pattern_templates
${resource_path_9208-C}                ${CURDIR}${/}resources

*** Keywords ***
CB009208-5G_2_Check_best_and_second_used_DL_SRS_beams_with_2CSIRS
    # CB009208.delta_commisioning    json_delta=CB009208-5G_2_SRS_beams_v1.0
    # Wait until keyword succeeds    20 min    1 min    CB009208.Verify all cells onair with admin

    CB009208_kw.Add 0x580265=0 flag to sw config and wait cells on air

    CB009208_kw.Load scf for NR 9208    ${resource_path_9208-C}    SCFs    CB009208-5G_2_SRS_beams.xml

    CB009208_kw.Setup phase shifter
    CB009208_kw.Update phase shifter config    config_file=${srs_beams_ps_config_step_1}

    Prepare and start DCAP   bts_mpalne=${mrbts_id}   nrCells=NRCELL_R-501
    Attach Ue     UE_4
    sleep  10s
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Verify JSON file from DCAP  expected_messages=${messages_9208}
    Start Data Transfer  dt_name=DT_DL_SA  ue_alias=UE_4  direction=dl  duration=${srs_beams_tput_duration}
    ...                  throughput=${srs_beams_tput_DL_bandwith}              protocol=udp  packet_size=${c_packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA  ue_alias=UE_4  direction=ul  duration=${srs_beams_tput_duration}
    ...                  throughput=${srs_beams_tput_UL_bandwith}              protocol=udp
    Check Data Transfer Is Alive               DT_DL_SA
    Check Data Transfer Is Alive               DT_UL_SA

    Start New L1L2 Logs  suffix=initial_UE_position
    Start TTI trace streaming
    sleep  10s
    Stop TTI trace  decoded_output_file=initial_UE_position
    Stop New L1L2 Logs And Download PCAP  suffix=initial_UE_position

    CB009208_kw.Update phase shifter config    config_file=${srs_beams_ps_config_step_2}

    Start New L1L2 Logs  suffix=final_UE_position
    Start TTI trace streaming
    sleep  10s
    Stop TTI trace  decoded_output_file=final_UE_position
    Stop New L1L2 Logs And Download PCAP  suffix=final_UE_position

    Check beam pattern based on ttitrace  ${beam_template_dir}  decoded_output_file=initial_UE_position  lower_treshold=${37}  higher_treshold=${46}
    Check beam pattern based on ttitrace  ${beam_template_dir}  decoded_output_file=final_UE_position  lower_treshold=${-46}  higher_treshold=${-37}

    Await Data Transfer Finish                 DT_DL_SA
    Await Data Transfer Finish                 DT_UL_SA


    [Teardown]  Run keywords
    ...         Delete active DCAP trace for BTS  ${mrbts_id}    AND
    ...         CB009208_kw.Restore original sw config and wait cells on air    AND
    ...         CB009208_kw.Teardown phase shifter

CB009208-5G_4_MU_scheduling_with_dynamic_DL_beam_tapering_selection
    # CB009208.delta_commisioning    json_delta=CB009208-5G_4_MU_scheduling_v1.0
    # Wait until keyword succeeds    20 min    1 min    CB009208.Verify all cells onair with admin

    CB009208_kw.Load scf for NR 9208    ${resource_path_9208-C}    SCFs    CB009208-5G_4_MU_scheduling.xml

    CB009208_kw.Setup phase shifter
    CB009208_kw.Update phase shifter config    config_file=${mu_scheduling_ps_config}

    Attach Ue     UE_1
    Attach Ue     UE_3

    Start Data Transfer  dt_name=DT_DL_SA_3_initial  ue_alias=UE_3  direction=dl  duration=${mu_scheduling_tput_duration}
    ...                  throughput=${mu_scheduling_tput_DL_bandwith}  protocol=udp  packet_size=${c_packet_Size}  #apn=${srs_beams_apn_name}
    Start Data Transfer  dt_name=DT_DL_SA_1_initial  ue_alias=UE_1  direction=dl  duration=${mu_scheduling_tput_duration}
    ...                  throughput=${mu_scheduling_tput_DL_bandwith}  protocol=udp  packet_size=${c_packet_Size}  #apn=${srs_beams_apn_name}
    sleep  10s
    Check Data Transfer Is Alive               DT_DL_SA_3_initial
    Check Data Transfer Is Alive               DT_DL_SA_1_initial

    Start New L1L2 Logs  suffix=initial_UE_position
    Start TTI trace streaming
    sleep  5s
    Stop TTI trace  decoded_output_file=initial_UE_position
    Stop New L1L2 Logs And Download PCAP  suffix=initial_UE_position

    Await Data Transfer Finish                 DT_DL_SA_3_initial
    Await Data Transfer Finish                 DT_DL_SA_1_initial

    Check dlfdscheddata mupair exist ttitrace  decoded_output_file=initial_UE_position

    CB009208.Set dlMuMimoCorrThd on cell  501  0.0
    Wait until keyword succeeds    20 min    1 min    CB009208.Verify all cells onair with admin
    sleep  5s

    Start Data Transfer  dt_name=DT_DL_SA_3_final  ue_alias=UE_3  direction=dl  duration=${mu_scheduling_tput_duration}
    ...                  throughput=${mu_scheduling_tput_DL_bandwith}  protocol=udp  packet_size=${c_packet_Size}  #apn=${srs_beams_apn_name}
    Start Data Transfer  dt_name=DT_DL_SA_1_final  ue_alias=UE_1  direction=dl  duration=${mu_scheduling_tput_duration}
    ...                  throughput=${mu_scheduling_tput_DL_bandwith}  protocol=udp  packet_size=${c_packet_Size}  #apn=${srs_beams_apn_name}
    sleep  10s
    Check Data Transfer Is Alive               DT_DL_SA_3_final
    Check Data Transfer Is Alive               DT_DL_SA_1_final

    Start New L1L2 Logs  suffix=final_UE_position
    Start TTI trace streaming
    sleep  5s
    Stop TTI trace  decoded_output_file=final_UE_position
    Stop New L1L2 Logs And Download PCAP  suffix=final_UE_position

    Await Data Transfer Finish                 DT_DL_SA_3_final
    Await Data Transfer Finish                 DT_DL_SA_1_final

    Check dlfdscheddata mupair not exist ttitrace  decoded_output_file=final_UE_position

    CB009208_kw.Verify PM Counters For Mu Scheduling

    [Teardown]  Run keyword
    ...         CB009208_kw.Teardown phase shifter
