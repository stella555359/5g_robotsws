import sys

global_variable = {"duration": 0}


def script_sleep(script, duration):
    script.write(f"script_sleep {duration}\n")
    global_variable["duration"] += duration


def ue_register(script, ue):
    script.write(f"ue_register id={ue}\n")
    script_sleep(script, 3)


def ue_attach(script, ue):
    script.write(f"ue_attach id={ue}\n")
    script_sleep(script, 1)


def ue_dual_connectivity_start(script, ue, target_cell):
    script.write(f"enb_ue_dc_start target_gnb=2 target_cells={target_cell} ue={ue} bearer=2 type=split_scg\n")
    script_sleep(script, 0.8)


def ue_dual_connectivity_release(script, ue):
    script.write(f"enb_dc_ue_release by=enb ue={ue} cause=MISC_CauseMisc_unspecified\n")
    script_sleep(script, 0.8)


def link_x2_reset(script, first_ue, nb_of_ues):
    script.write(f"link_x2_reset ue=")
    last_ue = first_ue + nb_of_ues - 1
    for ue in range(first_ue, last_ue):
        script.write(f"{ue},")
    script.write(f"{last_ue} from=1 to=2\n")
    script_sleep(script, 0.8)


def ue_pdu_session_setup(script, ue):
    script.write(f"set_pdu_param ue={ue} pdu=1 trf_type=internal\n")
    script_sleep(script, 1)
    script.write(f"ue_pdu_session_setup ue={ue} pdu=1 gw={ue} nwslice=1\n")
    script_sleep(script, 4)


def trf_data_start(script, ue, is_sa, trf_id, kbps, protocol, period_ms, direc):
    rate = int(kbps)
    if is_sa:
        channel = "pdu=1 qfi=1"
    else:
        channel = "id=2"
    script.write(f"trf_data_start ue={ue} {channel} trf_id={trf_id} kbps={rate} dir={direc} protocol={protocol}")
    if period_ms != 0:
        script.write(f" period_ms={period_ms}")
    script.write(f"\n")
    script_sleep(script, 1)


def trf_data_keep_alive(script, ue, is_sa):
    if is_sa:
        channel = "pdu=1 qfi=1"
    else:
        channel = "id=2"
    script.write(f"trf_data_start ue={ue} {channel} trf_id=9 bps=100 dir=dl protocol=tcp\n")
    script_sleep(script, 0.4)


def trf_data_stop(script, ue, is_sa, trf_id):
    if is_sa:
        channel = "pdu=1 qfi=1"
    else:
        channel = "id=2"
    script.write(f"trf_data_stop ue={ue} {channel} trf_id={trf_id}\n")
    script_sleep(script, 1)


def ue_pdu_session_release(script, ue):
    script.write(f"ue_pdu_session_release ue={ue} pdu=1\n")
    script_sleep(script, 2)


def ue_deregister(script, ue):
    script.write(f"ue_deregister id={ue} ue_deregister_type=switch_off\n")
    script_sleep(script, 1)


def ue_detach(script, ue):
    script.write(f"ue_detach id={ue}\n")
    script_sleep(script, 1)


def ue_stats_nr(script, ue):
    script.write(f"ue_stats_nr id={ue} scell=primary\n")
    script_sleep(script, 0.4)
    script.write(f"ue_stats_nr id={ue} scell=secondary\n")
    script_sleep(script, 0.4)


def bler_testmode_nr(script, initial_dl_bler=0, initial_ul_bler=0):
    initial_dl_bler_on_1000_samples = int(initial_dl_bler * 10)
    dlBler = initial_dl_bler_on_1000_samples
    initial_ul_bler_on_1000_samples = int(initial_ul_bler * 10)
    ulBler = initial_ul_bler_on_1000_samples
    script.write(f"bler_testmode_nr profile_id=1 dl_bler={dlBler},26,8,2,1,0,0,0 ul_bler={ulBler},8,1,0,0,0,0,0\n")
    script_sleep(script, 1)


def dl_bler_testmode_nr(script, initial_dl_bler=9):
    initial_dl_bler_on_1000_samples = int(initial_dl_bler * 10)
    script.write(f"bler_testmode_nr profile_id=1 dl_bler={initial_dl_bler_on_1000_samples},26,8,2,1,0,0,0\n")
    script_sleep(script, 1)


def ul_bler_testmode_nr(script, initial_ul_bler=9):
    initial_ul_bler_on_1000_samples = int(initial_ul_bler * 10)
    script.write(f"bler_testmode_nr profile_id=1 ul_bler={initial_ul_bler_on_1000_samples},8,1,0,0,0,0,0\n")
    script_sleep(script, 1)


def rlf_testmode_nr(script):
    script.write(f"rlf_testmode_nr profile_id=1 num_stop_csi_report=5000 num_stop_dlharq_tx=5000\n")
    script_sleep(script, 1)


def ul_sinr_testmode_nr(script):
    script.write(f"ul_sinr_testmode_nr profile_id=1 sinr_target_srs=300 sinr_target_pusch=200" +
                 f" sinr_target_pucch=300 sinr_target_preamble=100\n")
    script_sleep(script, 1)


def ue_measurement_send_nr(script, ue, target_cell):
    script.write(f"ue_measurement_send_nr id={ue} meas_id=1 event=A3 phycell_id={target_cell}" +
                 f" nrsrp_nr=90 rs_type=ssb index=0 nrs_result=11:12:13\n")
    script_sleep(script, 0.8)


def PET_mode_APL2(script):
    # added to avoid BLER in case of scenario with 30 UEs and more PR748615
    # with following constraint when enabled:
    # CSI test mode parameters - cqi_mode, pmi_mode, ri_mode, cri_mode and li_mode can be set only to "FIXED"
    script.write(f"uec_l2_testmode_params fixed_csi_report=true\n")
    script_sleep(script, 2)


def ue_testmode_set_nr(script, ue, mode, is_sa, activation_flag, pcell=False, scell=False):
    activation_string = "activate"
    if not activation_flag:
        activation_string = "deactivate"
    if is_sa and pcell:
        script.write(f"ue_testmode_set_nr id={ue} scell=0 testmode={mode} profile_id=1 action={activation_string}\n")
        script_sleep(script, 1)
    if is_sa and scell:
        script.write(f"ue_testmode_set_nr id={ue} scell=1 testmode={mode} profile_id=1 action={activation_string}\n")
        script_sleep(script, 1)
    if not is_sa:
        script.write(f"ue_testmode_set_nr id={ue} scell=8 testmode={mode} profile_id=1 action={activation_string}\n")
        script_sleep(script, 0.2)


def amf_paging_start(script, ue):
    script.write(f"amf_paging_start id=1 ue={ue}\n")
    script_sleep(script, 0.4)


def create_script(path, name, nb_of_loops=1,
                  max_duration_minutes=60 * 12,
                  nb_of_ues=1, first_ue=1,
                  ue_register_enabled=False,
                  ue_attach_enabled=False,
                  link_x2_reset_enabled=False,
                  ue_dual_connectivity_release_enabled=False,
                  ue_dual_connectivity_start_enabled=False, target_cell=1,
                  ue_pdu_session_setup_enabled=False,
                  trf_data_keep_alive_enabled=False,
                  amf_paging_start_enabled=False,
                  trf_data_start_dl_enabled=False, dl_total_mbps=10.0, is_sa=True,
                  trf_data_start_ul_enabled=False, ul_total_mbps=10,
                  trf_id=1, protocol="tcp", period_ms=0,
                  bler_testmode_nr_enabled=False,
                  dl_bler_testmode_nr_enabled=False, initial_dl_bler=0,
                  ul_bler_testmode_nr_enabled=False, initial_ul_bler=0,
                  rlf_testmode_nr_enabled=False,
                  ul_sinr_testmode_nr_enabled=False,
                  trf_data_stop_dl_enabled=False,
                  trf_data_stop_ul_enabled=False,
                  ue_stats_nr_enabled=False,
                  ue_measurement_send_nr_enabled=False,
                  ue_pdu_session_release_enabled=False,
                  ue_deregister_enabled=False,
                  ue_detach_enabled=False,
                  PET_mode_APL2_enabled=False,
                  after_loop_wait=10
                  ):
    dl_kbps = (dl_total_mbps * 1000) / nb_of_ues
    ul_kbps = (ul_total_mbps * 1000) / nb_of_ues
    file_name = f"{path}/{name}"
    print(f"Writing {file_name}")
    with open(file_name, "w") as script:
        script.write(f"# **** Starting {name}\n")
        if bler_testmode_nr_enabled:
            bler_testmode_nr(script, initial_dl_bler, initial_ul_bler)
        if dl_bler_testmode_nr_enabled:
            dl_bler_testmode_nr(script, initial_dl_bler)
        if ul_bler_testmode_nr_enabled:
            ul_bler_testmode_nr(script, initial_ul_bler)
        if rlf_testmode_nr_enabled:
            rlf_testmode_nr(script)
        if ul_sinr_testmode_nr_enabled:
            ul_sinr_testmode_nr(script)
# 28/06/2024 DO NOTHING UNTIL PRECHECK RESOLUTION - CONFLICT WITH RLF TEST MODE
# => next if commented
#        if PET_mode_APL2_enabled:
#            PET_mode_APL2(script)
        loop = 1
        global_variable["duration"] = 0
        while (loop <= nb_of_loops) and (global_variable["duration"] < max_duration_minutes * 60):
            script.write(f"# **** Loop {loop} ***********************************************************\n")
            if link_x2_reset_enabled:
                link_x2_reset(script, first_ue, nb_of_ues)
            for ue in range(first_ue, first_ue + nb_of_ues):
                if ue_dual_connectivity_release_enabled:
                    ue_dual_connectivity_release(script, ue)
            for ue in range(first_ue, first_ue + nb_of_ues):
                if ue_register_enabled:
                    ue_register(script, ue)
                if ue_attach_enabled:
                    ue_attach(script, ue)
                if ue_pdu_session_setup_enabled:
                    ue_pdu_session_setup(script, ue)
                if ue_dual_connectivity_start_enabled:
                    ue_dual_connectivity_start(script, ue, target_cell)
                if trf_data_keep_alive_enabled:
                    trf_data_keep_alive(script, ue, is_sa)
            for ue in range(first_ue, first_ue + nb_of_ues):
                if amf_paging_start_enabled and (trf_data_start_dl_enabled or trf_data_start_ul_enabled):
                    amf_paging_start(script, ue)
                if trf_data_start_dl_enabled:
                    trf_data_start(script, ue, is_sa, trf_id, dl_kbps, protocol, period_ms, "dl")
                if trf_data_start_ul_enabled:
                    trf_data_start(script, ue, is_sa, 10 + trf_id, ul_kbps, protocol, period_ms, "ul")
                if dl_bler_testmode_nr_enabled:
                    ue_testmode_set_nr(script, ue, "bler", is_sa, activation_flag=(initial_dl_bler != 0),
                                       pcell=True, scell=True)
                if ul_bler_testmode_nr_enabled:
                    ue_testmode_set_nr(script, ue, "bler", is_sa, activation_flag=(initial_ul_bler != 0),
                                       pcell=True, scell=True)
            for ue in range(first_ue, first_ue + nb_of_ues):
                if ue_measurement_send_nr_enabled:
                    ue_measurement_send_nr(script, ue, 51)
                if rlf_testmode_nr_enabled:
                    ue_testmode_set_nr(script, ue, "rlf", is_sa, activation_flag=True, pcell=True)
                    script_sleep(script, 4)
                    ue_testmode_set_nr(script, ue, "rlf", is_sa, activation_flag=False, pcell=True)
            for ue in range(first_ue, first_ue + nb_of_ues):
                if ue_measurement_send_nr_enabled:
                    ue_measurement_send_nr(script, ue, 50)
                if ul_sinr_testmode_nr_enabled:
                    ue_testmode_set_nr(script, ue, "ul_sinr", is_sa, activation_flag=True, pcell=True)
            for ue in range(first_ue, first_ue + nb_of_ues):
                if trf_data_stop_dl_enabled:
                    trf_data_stop(script, ue, is_sa, trf_id)
                if trf_data_stop_ul_enabled:
                    trf_data_stop(script, ue, is_sa, 10 + trf_id)
            for ue in range(first_ue, first_ue + nb_of_ues):
                if ue_stats_nr_enabled:
                    ue_stats_nr(script, ue)
            for ue in range(first_ue, first_ue + nb_of_ues):
                if amf_paging_start_enabled and ue_pdu_session_release_enabled:
                    amf_paging_start(script, ue)
                if ue_pdu_session_release_enabled:
                    ue_pdu_session_release(script, ue)
                if ue_deregister_enabled:
                    ue_deregister(script, ue)
                if ue_detach_enabled:
                    ue_detach(script, ue)
            if loop != nb_of_loops:
                script.write(f"# End of loop {loop}, you can stop with script_stop\n")
                if after_loop_wait > 0:
                    script_sleep(script, after_loop_wait)
            loop += 1
        script.write(f"# End of {name}, approximate duration {global_variable['duration'] / 60} minutes\n")
        script.close()


def get_robot_file_name():
    return sys.argv[-1].split("/")[-1]


def create_scripts(path):
    create_script(path, "AutoGen_UE_1_Setup_DL150mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=150,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_SetupNSA_DL150mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,  # FDx: will be 3 with SA+NSA variant
                  trf_data_start_dl_enabled=True, dl_total_mbps=150, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_Stats.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=1,
                  nb_of_ues=1,
                  ue_stats_nr_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_Stats_Short.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  ue_stats_nr_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_ReleaseNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  trf_data_stop_dl_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_3_StopTrafficNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=3,
                  trf_data_stop_dl_enabled=True, is_sa=False,
                  trf_data_stop_ul_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_5_Setup_DL5mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=5,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=5,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_5_Setup_DL440mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=5,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=440,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_to_105_Setup_DL440mbps.sce",
                  nb_of_loops=1,
                  first_ue=101, nb_of_ues=5,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=440,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_5_SetupNSA_DL485mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=5,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,  # FDx: will be 3 with SA+NSA variant
                  trf_data_start_dl_enabled=True, dl_total_mbps=485, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_5_SetupNSA_DL580mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=5,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,  # FDx: will be 3 with SA+NSA variant
                  trf_data_start_dl_enabled=True, dl_total_mbps=580, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_to_105_SetupNSA_DL485mbps.sce",
                  nb_of_loops=1,
                  first_ue=101, nb_of_ues=5,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=2,  # FDx: will be 4 with SA+NSA variant
                  trf_data_start_dl_enabled=True, dl_total_mbps=485, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_5_DlBler0.sce",
                  nb_of_loops=1,
                  nb_of_ues=5,
                  dl_bler_testmode_nr_enabled=True, initial_dl_bler=0,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_5_DlBler9.sce",
                  nb_of_loops=1,
                  nb_of_ues=5,
                  dl_bler_testmode_nr_enabled=True, initial_dl_bler=9,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_5_HO.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=12,
                  nb_of_ues=5,
                  ue_measurement_send_nr_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_5_Stats.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=1,
                  nb_of_ues=5,
                  ue_stats_nr_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_5_ScellActivEndur_DL250mbps.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=1,
                  nb_of_ues=5,
                  trf_data_start_dl_enabled=True, trf_id=2, dl_total_mbps=250,
                  trf_data_stop_dl_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_5_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=5,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_to_105_Release.sce",
                  nb_of_loops=1,
                  first_ue=101, nb_of_ues=5,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_5_ReleaseNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=5,
                  trf_data_stop_dl_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_to_105_ReleaseNSA.sce",
                  nb_of_loops=1,
                  first_ue=101, nb_of_ues=5,
                  trf_data_stop_dl_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_6_to_10_Setup_DL11mbps.sce",
                  nb_of_loops=1,
                  first_ue=6, nb_of_ues=5,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=11,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_10_Setup_DL440mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=10,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=440,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_10_SetupNSA_DL580mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=10,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,  # FDx: will be 3 with SA+NSA variant
                  trf_data_start_dl_enabled=True, dl_total_mbps=580, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_11_to_20_SetupNSA_DL450mbps_UL15mbps.sce",
                  nb_of_loops=1,
                  first_ue=11, nb_of_ues=10,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,
                  trf_data_start_dl_enabled=True, dl_total_mbps=450, is_sa=False,
                  trf_data_start_ul_enabled=True, ul_total_mbps=15,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_21_to_25_SetupNSA.sce",
                  nb_of_loops=1,
                  first_ue=21, nb_of_ues=5,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_21_to_25_DualConnEndur.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=12,
                  first_ue=21, nb_of_ues=5,
                  link_x2_reset_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,
                  after_loop_wait=0
                  )

    create_script(path, "AutoGen_UE_101_to_110_Setup_DL440mbps.sce",
                  nb_of_loops=1,
                  first_ue=101, nb_of_ues=10,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=440,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_111_to_120_SetupNSA_DL450mbps_UL15mbps.sce",
                  nb_of_loops=1,
                  first_ue=111, nb_of_ues=10,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=2,
                  trf_data_start_dl_enabled=True, dl_total_mbps=450, is_sa=False,
                  trf_data_start_ul_enabled=True, ul_total_mbps=15,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_10_Setup_DL10mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=10,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=10,
                  after_loop_wait=10
                  )

    create_script(path, "AutoGen_UE_1_to_10_Stats.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=1,
                  nb_of_ues=10,
                  ue_stats_nr_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_11_to_20_Stats.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=1,
                  first_ue=11, nb_of_ues=10,
                  ue_stats_nr_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_10_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=10,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=10
                  )

    create_script(path, "AutoGen_UE_1_to_10_ReleaseNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=10,
                  trf_data_stop_dl_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_to_110_Release.sce",
                  nb_of_loops=1,
                  first_ue=101, nb_of_ues=10,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=10
                  )

    create_script(path, "AutoGen_UE_11_to_20_ReleaseNSA.sce",
                  nb_of_loops=1,
                  first_ue=11, nb_of_ues=10,
                  trf_data_stop_dl_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_11_to_25_ReleaseNSA.sce",
                  nb_of_loops=1,
                  first_ue=11, nb_of_ues=15,
                  trf_data_stop_dl_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_111_to_120_ReleaseNSA.sce",
                  nb_of_loops=1,
                  first_ue=111, nb_of_ues=10,
                  trf_data_stop_dl_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_20_Setup_DL440mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=20,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=440,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_20_SetupNSA_DL580mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=20,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,  # FDx: will be 3 with SA+NSA variant
                  trf_data_start_dl_enabled=True, dl_total_mbps=580, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_to_120_Setup_DL440mbps.sce",
                  nb_of_loops=1,
                  first_ue=101, nb_of_ues=20,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=440,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_20_Stats.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=1,
                  nb_of_ues=20,
                  ue_stats_nr_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_20_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=20,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_20_ReleaseNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=20,
                  trf_data_stop_dl_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_to_120_Release.sce",
                  nb_of_loops=1,
                  first_ue=101, nb_of_ues=20,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=10
                  )

    create_script(path, "AutoGen_UE_1_to_30_Setup_DL440mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=30,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=440,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_to_130_Setup_DL440mbps.sce",
                  nb_of_loops=1,
                  first_ue=101, nb_of_ues=30,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=440,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_30_Stats.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=1,
                  nb_of_ues=30,
                  ue_stats_nr_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_30_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=30,
                  PET_mode_APL2_enabled=False,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=10
                  )

    create_script(path, "AutoGen_UE_101_to_130_Release.sce",
                  nb_of_loops=1,
                  first_ue=101, nb_of_ues=30,
                  PET_mode_APL2_enabled=False,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=10
                  )

    create_script(path, "AutoGen_UE_1_to_40_Setup_DL330mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=40,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=330,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_40_Setup_DL380mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=40,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=380,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_40_Setup_DL440mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=40,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=440,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_40_SetupNSA_DL580mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=40,
                  PET_mode_APL2_enabled=True,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,  # FDx: will be 3 with SA+NSA variant
                  trf_data_start_dl_enabled=True, dl_total_mbps=580, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_to_140_Setup_DL380mbps.sce",
                  nb_of_loops=1,
                  first_ue=101, nb_of_ues=40,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=380,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_to_140_Setup_DL440mbps.sce",
                  nb_of_loops=1,
                  first_ue=101, nb_of_ues=40,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=440,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_40_Setup_DL430mbps_UL20mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=40,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=430,
                  trf_data_start_ul_enabled=True, ul_total_mbps=20,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_40_Stats.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=1,
                  nb_of_ues=40,
                  ue_stats_nr_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_40_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=40,
                  PET_mode_APL2_enabled=False,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=10
                  )

    create_script(path, "AutoGen_UE_1_to_40_ReleaseNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=40,
                  PET_mode_APL2_enabled=False,
                  trf_data_stop_dl_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_to_140_Release.sce",
                  nb_of_loops=1,
                  first_ue=101, nb_of_ues=40,
                  PET_mode_APL2_enabled=False,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=10
                  )

    create_script(path, "AutoGen_UE_1_to_50_Setup_DL5mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=50,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=5,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_41_to_50_Setup_DL11mbps.sce",
                  nb_of_loops=1,
                  first_ue=41, nb_of_ues=10,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=11,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_141_to_150_Setup_DL11mbps.sce",
                  nb_of_loops=1,
                  first_ue=141, nb_of_ues=10,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=11,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_41_to_100_Setup_DL11mbps.sce",
                  nb_of_loops=1,
                  first_ue=41, nb_of_ues=60,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=11,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_41_to_100_Setup_DL30mbps.sce",
                  nb_of_loops=1,
                  first_ue=41, nb_of_ues=60,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=30,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_50_DlBler0.sce",
                  nb_of_loops=1,
                  nb_of_ues=50,
                  dl_bler_testmode_nr_enabled=True, initial_dl_bler=0,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_50_DlBler9.sce",
                  nb_of_loops=1,
                  nb_of_ues=50,
                  dl_bler_testmode_nr_enabled=True, initial_dl_bler=9,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_to_150_DlBler0.sce",
                  first_ue=101, nb_of_loops=1,
                  nb_of_ues=50,
                  dl_bler_testmode_nr_enabled=True, initial_dl_bler=0,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_to_150_DlBler9.sce",
                  first_ue=101, nb_of_loops=1,
                  nb_of_ues=50,
                  dl_bler_testmode_nr_enabled=True, initial_dl_bler=9,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_50_Stats.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=1,
                  nb_of_ues=50,
                  ue_stats_nr_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_50_ScellActivEndur_DL495mbps.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=1,
                  nb_of_ues=50,
                  trf_data_start_dl_enabled=True, trf_id=2, dl_total_mbps=495,
                  trf_data_stop_dl_enabled=True,
                  after_loop_wait=10
                  )

    create_script(path, "AutoGen_UE_1_to_50_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=50,
                  PET_mode_APL2_enabled=False,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_to_150_Release.sce",
                  nb_of_loops=1,
                  first_ue=101, nb_of_ues=50,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_60_SetupNSA_DL570mbps_UL30mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=60,
                  PET_mode_APL2_enabled=True,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,  # FDx: will be 3 with SA+NSA variant
                  trf_data_start_dl_enabled=True, dl_total_mbps=570, is_sa=False,
                  trf_data_start_ul_enabled=True, ul_total_mbps=30,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_61_to_70_SetupNSA.sce",
                  nb_of_loops=1,
                  first_ue=61, nb_of_ues=10,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,  # FDx: will be 3 with SA+NSA variant
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_61_to_70_DualConnEndur.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=12,
                  first_ue=61, nb_of_ues=10,
                  link_x2_reset_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,  # FDx: will be 3 with SA+NSA variant
                  after_loop_wait=0
                  )

    create_script(path, "AutoGen_UE_61_to_70_DualConnEndur_oneloop.sce",
                  nb_of_loops=1,
                  first_ue=61, nb_of_ues=10,
                  link_x2_reset_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,  # FDx: will be 3 with SA+NSA variant
                  after_loop_wait=0
                  )

    create_script(path, "AutoGen_UE_1_to_70_ReleaseNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=70,
                  PET_mode_APL2_enabled=False,
                  trf_data_stop_dl_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_61_to_70_ReleaseNSA.sce",
                  nb_of_loops=1,
                  first_ue=61, nb_of_ues=10,
                  PET_mode_APL2_enabled=False,
                  trf_data_stop_dl_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_80_Setup_DL65mbps_UL30mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=80,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=65,
                  trf_data_start_ul_enabled=True, ul_total_mbps=30,
                  after_loop_wait=10
                  )

    create_script(path, "AutoGen_UE_1_to_80_SetupNSA_DL570mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=80,
                  PET_mode_APL2_enabled=True,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,  # FDx: will be 3 with SA+NSA variant
                  trf_data_start_dl_enabled=True, dl_total_mbps=570, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_80_SetupNSA_DL570mbps_UL30mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=80,
                  PET_mode_APL2_enabled=True,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,  # FDx: will be 3 with SA+NSA variant
                  trf_data_start_dl_enabled=True, dl_total_mbps=570, is_sa=False,
                  trf_data_start_ul_enabled=True, ul_total_mbps=30,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_80_SetupNSA_DL485mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=80,
                  PET_mode_APL2_enabled=True,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,  # FDx: will be 3 with SA+NSA variant
                  trf_data_start_dl_enabled=True, dl_total_mbps=485, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_80_DlBler0.sce",
                  nb_of_loops=1,
                  nb_of_ues=80,
                  dl_bler_testmode_nr_enabled=True, initial_dl_bler=0, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_80_UlSinr.sce",
                  nb_of_loops=1,
                  nb_of_ues=80,
                  ul_sinr_testmode_nr_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_80_DlBler9.sce",
                  nb_of_loops=1,
                  nb_of_ues=80,
                  dl_bler_testmode_nr_enabled=True, initial_dl_bler=9, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_80_Stats.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=1,
                  nb_of_ues=80,
                  ue_stats_nr_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_80_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=80,
                  PET_mode_APL2_enabled=False,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_80_ReleaseNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=80,
                  PET_mode_APL2_enabled=False,
                  trf_data_stop_dl_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_to_180_Setup_DL400mbps_UL30mbps.sce",
                  nb_of_loops=1,
                  first_ue=101, nb_of_ues=80,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=400,
                  trf_data_start_ul_enabled=True, ul_total_mbps=30,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_to_180_UlSinr.sce",
                  nb_of_loops=1,
                  first_ue=101, nb_of_ues=80,
                  ul_sinr_testmode_nr_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_to_180_Release.sce",
                  nb_of_loops=1,
                  first_ue=101, nb_of_ues=80,
                  PET_mode_APL2_enabled=False,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_81_to_96_SetupNSA.sce",
                  nb_of_loops=1,
                  first_ue=81, nb_of_ues=16,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,  # FDx: will be 3 with SA+NSA variant
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_81_to_96_DualConnEndur.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=12,
                  first_ue=81, nb_of_ues=16,
                  link_x2_reset_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,  # FDx: will be 3 with SA+NSA variant
                  after_loop_wait=0
                  )

    create_script(path, "AutoGen_UE_81_to_96_ReleaseNSA.sce",
                  nb_of_loops=1,
                  first_ue=81, nb_of_ues=16,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_96_SetupNSA_DL570mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=96,
                  PET_mode_APL2_enabled=True,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,  # FDx: will be 3 with SA+NSA variant
                  trf_data_start_dl_enabled=True, dl_total_mbps=570, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_96_SetupNSA_DL430mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=96,
                  PET_mode_APL2_enabled=True,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,  # FDx: will be 3 with SA+NSA variant
                  trf_data_start_dl_enabled=True, dl_total_mbps=430, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_96_Stats.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=1,
                  nb_of_ues=96,
                  ue_stats_nr_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_96_ReleaseNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=96,
                  PET_mode_APL2_enabled=False,
                  trf_data_stop_dl_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_100_Setup_DL30mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=100,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=30, period_ms=2000,
                  after_loop_wait=10
                  )

    create_script(path, "AutoGen_UE_1_to_100_DlBler0.sce",
                  nb_of_loops=1,
                  nb_of_ues=100,
                  dl_bler_testmode_nr_enabled=True, initial_dl_bler=0,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_100_DlBler9.sce",
                  nb_of_loops=1,
                  nb_of_ues=100,
                  dl_bler_testmode_nr_enabled=True, initial_dl_bler=9,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_100_Stats.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=1,
                  nb_of_ues=100,
                  ue_stats_nr_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_100_ScellActivEndur_DL470mbps.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=1,
                  nb_of_ues=100,
                  trf_data_start_dl_enabled=True, trf_id=2, dl_total_mbps=470,
                  trf_data_stop_dl_enabled=True,
                  after_loop_wait=10
                  )

    create_script(path, "AutoGen_UE_1_to_100_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=100,
                  PET_mode_APL2_enabled=False,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_60_Setup_DL300mbps_UL30mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=60,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=300,
                  trf_data_start_ul_enabled=True, ul_total_mbps=30,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_61_to_120_Setup_DL300mbps_UL30mbps.sce",
                  nb_of_loops=1,
                  first_ue=61, nb_of_ues=60,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=300,
                  trf_data_start_ul_enabled=True, ul_total_mbps=30,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_121_to_180_Setup_DL300mbps_UL30mbps.sce",
                  nb_of_loops=1,
                  first_ue=121, nb_of_ues=60,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=300,
                  trf_data_start_ul_enabled=True, ul_total_mbps=30,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_180_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=180,
                  PET_mode_APL2_enabled=False,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_25_to_32_Setup_DL90mbps.sce",
                  nb_of_loops=1,
                  first_ue=25, nb_of_ues=8,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_keep_alive_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=90,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_33_to_48_Setup_DL300mbps.sce",
                  nb_of_loops=1,
                  first_ue=33, nb_of_ues=16,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_keep_alive_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=300,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_25_to_48_Stats.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=1,
                  first_ue=25, nb_of_ues=24,
                  ue_stats_nr_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_25_to_48_Release.sce",
                  nb_of_loops=1,
                  first_ue=25, nb_of_ues=24,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_200_Deregister.sce",
                  nb_of_loops=1,
                  nb_of_ues=200,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_32_Setup_DL440mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=32,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=440,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_33_to_55_SetupEndur_DL8mbps.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=14,
                  first_ue=33, nb_of_ues=23,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=7.7, period_ms=2000,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_32_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=32,
                  PET_mode_APL2_enabled=False,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_6_RLF_DL20mbps.sce",
                  nb_of_loops=1,
                  first_ue=6, nb_of_ues=1,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=20,
                  rlf_testmode_nr_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_6_to_10_RLF_DL1mbps.sce",
                  nb_of_loops=1,
                  first_ue=6, nb_of_ues=5,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=1, period_ms=2000,
                  rlf_testmode_nr_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_181_to_190_RLF_DL1mbps.sce",
                  nb_of_loops=1,
                  first_ue=181, nb_of_ues=10,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=1,
                  rlf_testmode_nr_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

# start of section with steps for endurance 48h and more added from 19/06/2024 by denis.taupin@nokia.com
    create_script(path, "AutoGen_UE_1_to_50_Setup_DL300mbps_UL30mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=50,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=300,
                  trf_data_start_ul_enabled=True, ul_total_mbps=30,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_61_to_110_Setup_DL300mbps_UL30mbps.sce",
                  nb_of_loops=1,
                  first_ue=61, nb_of_ues=50,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=300,
                  trf_data_start_ul_enabled=True, ul_total_mbps=30,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_50_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=50,
                  PET_mode_APL2_enabled=False,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_61_to_110_Release.sce",
                  nb_of_loops=1,
                  first_ue=61,
                  nb_of_ues=50,
                  PET_mode_APL2_enabled=False,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_111_to_120_RLF_DL1mbps.sce",
                  nb_of_loops=1,
                  first_ue=111, nb_of_ues=10,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=1,
                  rlf_testmode_nr_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )
# end of section with steps for endurance 48h and more added from 19/06/2024 by denis.taupin@nokia.com

# start of section with steps from Krakow CRT Tansversal Robustness added from 20/03/2024 by denis.taupin@nokia.com
    create_script(path, "AutoGen_UE_1_to_50_Setup_DL50mbps_UL150mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=50,
                  PET_mode_APL2_enabled=True,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=50,
                  trf_data_start_ul_enabled=True, ul_total_mbps=150,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_50_UlDlStop_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=50,
                  PET_mode_APL2_enabled=False,
                  trf_data_stop_dl_enabled=True,
                  trf_data_stop_ul_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_20_Setup_DL200mbps_UL100mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=20,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=200,
                  trf_data_start_ul_enabled=True, ul_total_mbps=100,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_20_UlDlStop_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=20,
                  trf_data_stop_dl_enabled=True,
                  trf_data_stop_ul_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_50_UlBler9.sce",
                  nb_of_loops=1,
                  nb_of_ues=50,
                  ul_bler_testmode_nr_enabled=True, initial_ul_bler=9,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_50_UlBler0.sce",
                  nb_of_loops=1,
                  nb_of_ues=50,
                  ul_bler_testmode_nr_enabled=True, initial_ul_bler=0,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_20_DlBler9.sce",
                  nb_of_loops=1,
                  nb_of_ues=20,
                  dl_bler_testmode_nr_enabled=True, initial_dl_bler=9,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_20_DlBler0.sce",
                  nb_of_loops=1,
                  nb_of_ues=20,
                  dl_bler_testmode_nr_enabled=True, initial_dl_bler=0,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_20_UlBler9.sce",
                  nb_of_loops=1,
                  nb_of_ues=20,
                  ul_bler_testmode_nr_enabled=True, initial_ul_bler=9,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_20_UlBler0.sce",
                  nb_of_loops=1,
                  nb_of_ues=20,
                  ul_bler_testmode_nr_enabled=True, initial_ul_bler=0,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_20_DlBler9_UlBler9.sce",
                  nb_of_loops=1,
                  nb_of_ues=20,
                  bler_testmode_nr_enabled=True, initial_dl_bler=9, initial_ul_bler=9,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_20_DlBler0_UlBler0.sce",
                  nb_of_loops=1,
                  nb_of_ues=20,
                  bler_testmode_nr_enabled=True, initial_dl_bler=0, initial_ul_bler=0,
                  after_loop_wait=1
                  )

    # Alarms check
    # SA part
    create_script(path, "AutoGen_UE_1_Setup.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=1,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_21_Setup.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=21,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_51_Setup.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=51,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_71_Setup.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=71,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_StartTraffic_DL100mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=1,
                  trf_data_start_dl_enabled=True, dl_total_mbps=100,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_21_StartTraffic_DL100mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=21,
                  trf_data_start_dl_enabled=True, dl_total_mbps=100,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_51_StartTraffic_DL100mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=51,
                  trf_data_start_dl_enabled=True, dl_total_mbps=100,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_71_StartTraffic_DL100mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=71,
                  trf_data_start_dl_enabled=True, dl_total_mbps=100,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_StartTraffic_UL50mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=1,
                  trf_data_start_ul_enabled=True, ul_total_mbps=50,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_21_StartTraffic_UL50mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=21,
                  trf_data_start_ul_enabled=True, ul_total_mbps=50,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_51_StartTraffic_UL50mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=51,
                  trf_data_start_ul_enabled=True, ul_total_mbps=50,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_71_StartTraffic_UL50mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=71,
                  trf_data_start_ul_enabled=True, ul_total_mbps=50,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_171_Stats.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=1,
                  nb_of_ues=171,
                  first_ue=1,
                  ue_stats_nr_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_StopTraffic_DL_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=1,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_21_StopTraffic_DL_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=21,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_51_StopTraffic_DL_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=51,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_71_StopTraffic_DL_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=71,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_StopTraffic_UL_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=1,
                  trf_data_stop_ul_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_21_StopTraffic_UL_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=21,
                  trf_data_stop_ul_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_51_StopTraffic_UL_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=51,
                  trf_data_stop_ul_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_71_StopTraffic_UL_Release.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=71,
                  trf_data_stop_ul_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    # NSA part
    create_script(path, "AutoGen_UE_101_SetupNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=101,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=1,  # FDx: will be 3 with SA+NSA variant
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_121_SetupNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=121,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=2,  # FDx: will be 3 with SA+NSA variant
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_151_SetupNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=151,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=3,  # FDx: will be 3 with SA+NSA variant
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_171_SetupNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=171,
                  ue_attach_enabled=True,
                  ue_dual_connectivity_start_enabled=True, target_cell=4,  # FDx: will be 3 with SA+NSA variant
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_StartTrafficNSA_DL100mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=101,
                  trf_data_start_dl_enabled=True, dl_total_mbps=100, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_121_StartTrafficNSA_DL100mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=121,
                  trf_data_start_dl_enabled=True, dl_total_mbps=100, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_151_StartTrafficNSA_DL100mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=151,
                  trf_data_start_dl_enabled=True, dl_total_mbps=100, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_171_StartTrafficNSA_DL100mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=171,
                  trf_data_start_dl_enabled=True, dl_total_mbps=100, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_StartTrafficNSA_UL50mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=101,
                  trf_data_start_ul_enabled=True, ul_total_mbps=50, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_121_StartTrafficNSA_UL50mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=121,
                  trf_data_start_ul_enabled=True, ul_total_mbps=50, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_151_StartTrafficNSA_UL50mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=151,
                  trf_data_start_ul_enabled=True, ul_total_mbps=50, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_171_StartTrafficNSA_UL50mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=171,
                  trf_data_start_ul_enabled=True, ul_total_mbps=50, is_sa=False,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_StopTraffic_DL_ReleaseNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=101,
                  trf_data_stop_dl_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_121_StopTraffic_DL_ReleaseNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=121,
                  trf_data_stop_dl_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_151_StopTraffic_DL_ReleaseNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=151,
                  trf_data_stop_dl_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_171_StopTraffic_DL_ReleaseNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=171,
                  trf_data_stop_dl_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_101_StopTraffic_UL_ReleaseNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=101,
                  trf_data_stop_ul_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_121_StopTraffic_UL_ReleaseNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=121,
                  trf_data_stop_ul_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_151_StopTraffic_UL_ReleaseNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=151,
                  trf_data_stop_ul_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_171_StopTraffic_UL_ReleaseNSA.sce",
                  nb_of_loops=1,
                  nb_of_ues=1,
                  first_ue=171,
                  trf_data_stop_ul_enabled=True, is_sa=False,
                  ue_detach_enabled=True,
                  after_loop_wait=1
                  )
# end of section with Krakow CRT Tansversal Robustness

# beg of section with steps for CNI-110775 added from 19/08/2024 by denis.taupin@nokia.com
    create_script(path, "AutoGen_UE_1_to_30_Setup_DL150mbps_UL30Mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=30,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=150,
                  trf_data_start_ul_enabled=True, ul_total_mbps=30,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_31_to_40_SetupEndur.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=14,
                  first_ue=31, nb_of_ues=10,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=1, period_ms=2000,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_30_Release_CNI110775.sce",
                  nb_of_loops=1,
                  nb_of_ues=30,
                  trf_data_stop_dl_enabled=True,
                  trf_data_stop_ul_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_70_Setup_DL350mbps_UL70Mbps.sce",
                  nb_of_loops=1,
                  nb_of_ues=70,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=350,
                  trf_data_start_ul_enabled=True, ul_total_mbps=70,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_71_to_100_SetupEndur.sce",
                  nb_of_loops=10000,
                  max_duration_minutes=14,
                  first_ue=71, nb_of_ues=30,
                  ue_register_enabled=True,
                  ue_pdu_session_setup_enabled=True,
                  trf_data_start_dl_enabled=True, dl_total_mbps=1, period_ms=2000,
                  trf_data_stop_dl_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )

    create_script(path, "AutoGen_UE_1_to_70_Release_CNI110775.sce",
                  nb_of_loops=1,
                  nb_of_ues=70,
                  trf_data_stop_dl_enabled=True,
                  trf_data_stop_ul_enabled=True,
                  ue_pdu_session_release_enabled=True,
                  ue_deregister_enabled=True,
                  after_loop_wait=1
                  )
# end of section with steps for CNI-110775 added from 19/08/2024 by denis.taupin@nokia.com


if __name__ == '__main__':
    create_scripts(sys.argv[1])
