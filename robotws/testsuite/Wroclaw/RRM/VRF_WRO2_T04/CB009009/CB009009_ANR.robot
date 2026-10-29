*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com
...   Test for ANRs related feautres

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009009/resources/keywords.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009009/resources/anr_pm_counters.py


*** Keywords ***
CB009009_ANR_for_SA_intra_NR
    Show Text on Console    Prepare BTS before test
    Set Attenuation  90dB  ${ATTENUATOR['AHFII_1']['ports']}  confirm=${TRUE}
    Set Attenuation  90dB  ${ATTENUATOR['AHLOB_1']['ports']}  confirm=${TRUE}
    block_nr_cell   cell_id=410
    ${scf_file}   wro4_scf.download_scf
    Set Test Variable   ${scf_file}
    Set Test Variable   ${UE}   UE_5
    Require Ue   ${UE}  capabilities=${UE}
    Run Keyword If   ${is_rsrp_need_to_check}   Attach UE to check RSRP Level for HO cells
    ${serving_cell}   Set Variable   400
    set_preferred_cell   cell_id=${serving_cell}

    Show Text on Console    Run 5GC001085 ANR for SA intra-NR intra-frequency scenario   colour=${REDBG}  show_timestamp=no
    ${ho_type}   Set Variable   intra_freq
    ${ho_cell}   Set Variable If   '${ho_type}' == 'intra_freq'   500  510
    ${nrrel_instance_no}   Set Variable   ${256}
    anr.prepare_startup_values
    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch
    Attach UE to Given Cell   cell=${serving_cell}
    Make SA Handover   from_cell=${serving_cell}  ho_cell=${ho_cell}  ho_type=${ho_type}   nrrel_instance_no=${nrrel_instance_no}
    wro4_pm.sync_to_next_reporting_interval   offset=1
    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch
    ${counter_values}   Collect Counters from Given Time    ${pm_start_time}  ${pm_stop_time}  ANR_PM_COUNTERS
    Verification PM Counters   ${counter_values}  ANR_PM_COUNTERS

    Show Text on Console    Run CB008241 ANR for SA intra-NR inter-frequency scenario  colour=${REDBG}  show_timestamp=no
    Set Attenuation  0dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}
    Set Attenuation  90dB  ${ATTENUATOR['AEHC_2']['ports']}  confirm=${TRUE}
    ${ho_type}   Set Variable   inter_freq
    ${ho_cell}   Set Variable If   '${ho_type}' == 'intra_freq'   500  510
    ${nrrel_instance_no}   Set Variable   ${255}
    anr.prepare_startup_values
    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch
    Attach UE to Given Cell   cell=${serving_cell}
    Make SA Handover   from_cell=${serving_cell}  ho_cell=${ho_cell}  ho_type=${ho_type}  nrrel_instance_no=${nrrel_instance_no}
    wro4_pm.sync_to_next_reporting_interval   offset=1
    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch
    ${counter_values}   Collect Counters from Given Time    ${pm_start_time}  ${pm_stop_time}  ANR_PM_COUNTERS
    Verification PM Counters   ${counter_values}  ANR_PM_COUNTERS

    [Teardown]   Run Keywords
    ...           Detach Ue   ${UE}
    ...   AND     Run Keyword And Ignore Error   unblock_nr_cell   cell_id=500
    ...   AND     Run Keyword And Ignore Error   unblock_nr_cell   cell_id=510
    ...   AND     Set Attenuation  0dB  ${ATTENUATOR['SECTOR_${sector_no}']['ports']}  confirm=${TRUE}
    ...   AND     Set Attenuation  90dB  ${ATTENUATOR['AEHC_2']['ports']}  confirm=${TRUE}
    ...   AND     remove_relation_object   cell_id=${serving_cell}  instance_number=256
    ...   AND     remove_relation_object   cell_id=${serving_cell}  instance_number=255
    ...   AND     unblock_nr_cell   cell_id=410
    ...   AND     unset_preferred_cell
    ...   AND     Stop Tracing On SMOD


CB009009_ANR_for_NSA_intra_NR
    Show Text on Console    Prepare BTS before test
    Set Attenuation  90dB  ${ATTENUATOR['AHLOB_1']['ports']}  confirm=${TRUE}  # to avoid HO
    block_nr_cell   cell_id=410
    ${scf_file}   wro4_scf.download_scf
    Set Test Variable   ${scf_file}
    Set Test Variable   ${UE}   UE_1
    Require Ue   ${UE}  capabilities=${UE}
    Run Keyword If   ${is_rsrp_need_to_check}   Attach UE to check RSRP Level for HO cells
    ${serving_cell}   Set Variable   400
    enable_band_config   UE_1   NSA_b2_n41

    Show Text on Console    Run 5GC001296 ANR for EN-DC intra-NR intra-frequency scenario   colour=${REDBG}  show_timestamp=no
    ${ho_type}   Set Variable   intra_freq
    ${ho_cell}   Set Variable If   '${ho_type}' == 'intra_freq'   500  510
    ${nrrel_instance_no}   Set Variable   ${256}
    anr.prepare_startup_values
    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch
    Make NSA Attach to Given NR Cell   cell=${serving_cell}
    Make NSA Handover   from_cell=${serving_cell}  ho_cell=${ho_cell}  ho_type=${ho_type}  nrrel_instance_no=${nrrel_instance_no}
    wro4_pm.sync_to_next_reporting_interval   offset=1
    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch
    ${counter_values}   Collect Counters from Given Time    ${pm_start_time}  ${pm_stop_time}  ANR_PM_COUNTERS
    Verification PM Counters   ${counter_values}  ANR_PM_COUNTERS

    Show Text on Console    Run 5GC002198 ANR for EN-DC intra-NR inter-frequency scenario   colour=${REDBG}  show_timestamp=no
    Set Attenuation  0dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}
    Set Attenuation  90dB  ${ATTENUATOR['AEHC_2']['ports']}  confirm=${TRUE}
    ${ho_type}   Set Variable   inter_freq
    ${ho_cell}   Set Variable If   '${ho_type}' == 'intra_freq'   500  510
    ${nrrel_instance_no}   Set Variable   ${255}
    anr.prepare_startup_values
    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch
    Make NSA Attach to Given NR Cell   cell=${serving_cell}
    Make NSA Handover   from_cell=${serving_cell}  ho_cell=${ho_cell}  ho_type=${ho_type}  nrrel_instance_no=${nrrel_instance_no}
    wro4_pm.sync_to_next_reporting_interval   offset=1
    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch
    ${counter_values}   Collect Counters from Given Time    ${pm_start_time}  ${pm_stop_time}  ANR_PM_COUNTERS
    Verification PM Counters   ${counter_values}  ANR_PM_COUNTERS

    [Teardown]   Run Keywords
    ...           enable_band_config   UE_1   NR_ONLY
    ...   AND     Detach Ue   ${UE}
    ...   AND     Run Keyword And Ignore Error   unblock_nr_cell   cell_id=500
    ...   AND     Run Keyword And Ignore Error   unblock_nr_cell   cell_id=510
    ...   AND     Set Attenuation  0dB  ${ATTENUATOR['SECTOR_${sector_no}']['ports']}  confirm=${TRUE}
    ...   AND     Set Attenuation  90dB  ${ATTENUATOR['AEHC_2']['ports']}  confirm=${TRUE}
    ...   AND     remove_relation_object   cell_id=${serving_cell}  instance_number=256
    ...   AND     remove_relation_object   cell_id=${serving_cell}  instance_number=255
    ...   AND     unblock_nr_cell   cell_id=410
    ...   AND     Stop Tracing On SMOD


CB009009_ANR_for_SA_Inter_RAT_NR_LTE
    Show Text on Console    Prepare BTS before test
    Set Attenuation  90dB  ${ATTENUATOR['AHFII_1']['ports']}  confirm=${TRUE}
    block_nr_cell   cell_id=410
    Change APN   ue_name=SAMSUNG_S24_1   apn_name=n26wro
    ${scf_file}   wro4_scf.download_scf
    Set Test Variable   ${scf_file}
    Set Test Variable   ${UE}   UE_1
    Require Ue   ${UE}  capabilities=${UE}
    enable_band_config   UE_1   LTE_2_NR_41
    ${ho_cell}   Set Variable   10
    ${serving_cell}   Set Variable   400
    # only tac=7152 works on apn=n26wro
    Update Parameter   param=tac  value=7152  distname=MRBTS-${mrbts_id}/LNBTS-${nrbts_id}/LNCEL-${ho_cell}
    # increase time to do iRAT before UE moves to idle
    Update Parameter   param=drbInactivityTimerSA  value=240
    set_preferred_cell   cell_id=${serving_cell}

    Show Text on Console    Run CB008239 ANR for SA Inter-RAT NR-LTE scenario   colour=${REDBG}  show_timestamp=no
    ${nrrel_instance_no}   Set Variable   ${256}
    anr.prepare_startup_values
    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch
    Attach UE to Given Cell   cell=${serving_cell}
    Make iRAT Handover   from_cell=${serving_cell}  ho_cell=${ho_cell}  nrrel_instance_no=${nrrel_instance_no}
    wro4_pm.sync_to_next_reporting_interval   offset=1
    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch
    ${counter_values}   Collect Counters from Given Time    ${pm_start_time}  ${pm_stop_time}  ANR_PM_COUNTERS
    Verification PM Counters   ${counter_values}  ANR_PM_COUNTERS

    [Teardown]   Run Keywords
    ...           Change APN   ue_name=SAMSUNG_S24_1   apn_name=internet
    ...   AND     enable_band_config   UE_1   NR_ONLY
    ...   AND     Detach Ue   ${UE}
    ...   AND     Set Attenuation  0dB  ${ATTENUATOR['SECTOR_${sector_no}']['ports']}  confirm=${TRUE}
    ...   AND     remove_relation_object   cell_id=${serving_cell}  instance_number=256  rel_to_cell=4G
    ...   AND     unblock_nr_cell   cell_id=410
    ...   AND     Update Parameter   param=tac  value=7151  distname=MRBTS-${mrbts_id}/LNBTS-${nrbts_id}/LNCEL-${ho_cell}
    ...   AND     Update Parameter   param=drbInactivityTimerSA  value=45
    ...   AND     unset_preferred_cell
    ...   AND     Stop Tracing On SMOD
