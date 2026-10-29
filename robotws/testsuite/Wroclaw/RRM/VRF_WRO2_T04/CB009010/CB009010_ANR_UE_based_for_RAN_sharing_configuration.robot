*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com


Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009010/resources/keywords_9010.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009010/resources/interanr_pm_counters.py


*** Keywords ***
CB009010_A__Handover_restriction_on_the_Target_for_UEs_using_PLMN_that_is_reserved_on_the_Target_cell_NRPLMNSET_SA
    Show Text on Console    Prepare BTS before test
    ${scf_file}   wro4_scf.download_scf
    Set Test Variable   ${scf_file}
    Set Test Variable   ${UE}   UE_5
    Set Test Variable   ${nrrel_instance_no}   256
    Set Test Variable   ${nradjnrcell_instance_no}   50
    Require Ue   ${UE}  capabilities=${UE}
    Set Test Variable   ${serving_cell}  311
    Set Test Variable   ${ho_cell}   50
    set_preferred_cell   cell_id=${serving_cell}

    Show Text on Console    Execute successfull HANDOVER when HO Cell is not reserved   colour=${REDBG}  show_timestamp=no
    ${nr_cells}   interanr.prepare_startup_values
    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch
    Set Attenuation  0dB  ${ATTENUATOR['AZHL']['ports']}  confirm=${TRUE}
    ...    attenuator_id=${ATTENUATOR['AZHL']['att_id']}
    Attach UE to Given Cell   cell=${serving_cell}
    Make inter gNB Handover   from_cell=${serving_cell}  ho_cell=${ho_cell}

    Show Text on Console    Execute fail HANDOVER when HO Cell is reserved   colour=${REDBG}  show_timestamp=no
    Set HO cell as reserved on remote gNB
    Attach UE to Given Cell   cell=${serving_cell}
    Try inter gNB Handover   from_cell=${serving_cell}  ho_cell=${ho_cell}


    wro4_pm.sync_to_next_reporting_interval   offset=1
    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch
    ${counter_values}   keywords_9103.Collect Counters from Both BTSs    ${pm_start_time}  ${pm_stop_time}  INTERANR_PM_COUNTERS
    Verification PM Counters   ${counter_values}  INTERANR_PM_COUNTERS  ${nr_cells}

    [Teardown]   Run Keywords
    ...           Detach Ue   ${UE}
    ...   AND     Set Attenuation  90dB  ${ATTENUATOR['AZHL']['ports']}  confirm=${TRUE}
    ...                   attenuator_id=${ATTENUATOR['AZHL']['att_id']}
    ...   AND     Set Attenuation  0dB  ${ATTENUATOR['AEHC_1']['ports']}  confirm=${TRUE}
    ...                   attenuator_id=${ATTENUATOR['AEHC_1']['att_id']}
    ...   AND     Run Keyword And Ignore Error   remove_relation_object   cell_id=${serving_cell}  instance_number=256
    ...   AND     Run Keyword And Ignore Error   remove_adj_nrplmnset_objects   instance_number=${nradjnrcell_instance_no}
    ...   AND     unset_preferred_cell
    ...   AND     Set HO cell as notReserved on remote gNB
    ...   AND     Stop Tracing On SMOD
