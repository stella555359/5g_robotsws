*** Settings ***
Documentation
...   author: Bartosz Kozlowski
...   contact: bartosz.1.kozlowski@nokia.com
...   This is the ROBOT KEYWORDS file for feature CB009027, based on the sister feature CB008021


Library      taf.ue
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library      testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009027/resources/test_specific_keywords_9027.py

Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009027/resources/test_specific_keywords_9027.py


*** Keywords ***
UL_INTERFERENCE_AND_NOISE_MEASUREMENT_PRACH_PUCCH
    [Documentation]   Setup for CB009027 testcases using PRACH and PUCCH F1 measurement
	Setup and check preconditions in scf   params_to_check=${prach_pucch_f1_params}    bts_host=192.168.255.129
	${pm_periods}=    GnbCounter.Wait for next pm period   interval=${pm_interval_9027}

    Require UE   UE_1   capabilities=REAL_UE_SA

    Attach to cell at ports    ${cell_2_attenuator_ports}

    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                   direction=dl       duration=${tput_duration_9027}
    ...                   packet_size=1200            throughput=${tput_dl_9027}         protocol=${tput_protocol_9027}
    ...                   iperf_version=2
    Start data transfer   dt_name=DT_UL               ue_alias=UE_1                   direction=ul       duration=${tput_duration_9027}
    ...                   packet_size=1200            throughput=${tput_ul_9027}         protocol=${tput_protocol_9027}
    ...                   iperf_version=2
    BuiltIn.Sleep                 ${tput_duration_9027}
    check_data_transfer_is_alive    dt_name=DT_UL
    check_data_transfer_is_alive    dt_name=DT_DL
    Stop data transfer    dt_name=DT_UL
    Stop data transfer    dt_name=DT_DL

    Detach UE    UE_1

    GnbCounter.Wait for next pm period   interval=${pm_interval_9027}

     ${counters}=    Generate Counters String
    ...    first_counter=${first_counter_set_9027}
    ...    last_counter=${last_counter_set_9027}

    ${counters_2}=    Generate Counters String
    ...    first_counter=${first_counter_set_9027_range2}
    ...    last_counter=${last_counter_set_9027_range2}

    ${counter_dict}=    Get Counters    counter_ids=${counters}
    ${counter_dict_2}=    Get Counters    counter_ids=${counters_2}
    ${cell_list}=    gnbcell.Get All Cells ID
    ${bts_id}=       gnbcell.Get Global BTS ID

    ${counters_dict_for_cell1}=    Find PM Counters For Cell   ${counter_dict}   ${cell_id_9027_1}   ${pm_periods}
    ${prbs_prach_pucch_f1_cell1}=   Get PRBs From Dict   ${counters_dict_for_cell1}   cell1
    Set Global Variable   ${prbs_prach_pucch_f1_cell1}

    ${counters_dict_for_cell2}=    Find PM Counters For Cell   ${counter_dict}   ${cell_id_9027_2}   ${pm_periods}
    ${prbs_prach_pucch_f1_cell2}=   Get PRBs From Dict   ${counters_dict_for_cell2}   cell2
    Set Global Variable   ${prbs_prach_pucch_f1_cell2}

    ${counters_dict_for_cell1_range2}=    Find PM Counters For Cell   ${counter_dict_2}   ${cell_id_9027_1}   ${pm_periods}
    ${prbs_prach_pucch_f1_cell1_range2}=   Get PRBs From Dict   ${counters_dict_for_cell1_range2}   cell1
    Set Global Variable   ${prbs_prach_pucch_f1_cell1_range2}

    ${counters_dict_for_cell2_range2}=    Find PM Counters For Cell   ${counter_dict_2}   ${cell_id_9027_2}   ${pm_periods}
    ${prbs_prach_pucch_f1_cell2_range2}=   Get PRBs From Dict   ${counters_dict_for_cell2_range2}   cell2
    Set Global Variable   ${prbs_prach_pucch_f1_cell2_range2}

CB009027-1_Verification_of_scheduled_PRB_values_for_1_enabledWithPRACH_PUCCH_F1_ABIP
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements for PRACH and PUCCH F1 channel
     Check If Counter PRBs Values Are In Range
     ...   ${prbs_prach_pucch_f1_cell1}
     ...   ${prbs_prach_pucch_f1_cell2}
     ...   ${prbs_prach_pucch_f1_cell1_range2}
     ...   ${prbs_prach_pucch_f1_cell2_range2}


UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PRACH
    [Documentation]   Setup for CB009027 testcases using interference measurement without PRACH
    Setup and check preconditions in scf   params_to_check=${without_prach_params}    bts_host=192.168.255.129

    ${pm_periods}=    GnbCounter.Wait for next pm period   interval=${pm_interval_9027}

    Require UE   UE_1   capabilities=REAL_UE_SA

    Attach to cell at ports    ${cell_2_attenuator_ports}

    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                   direction=dl       duration=${tput_duration_9027}
    ...                   packet_size=1200            throughput=${tput_dl_9027}         protocol=${tput_protocol_9027}
    ...                   iperf_version=2
    Start data transfer   dt_name=DT_UL               ue_alias=UE_1                   direction=ul       duration=${tput_duration_9027}
    ...                   packet_size=1200            throughput=${tput_ul_9027}         protocol=${tput_protocol_9027}
    ...                   iperf_version=2
    BuiltIn.Sleep                 ${tput_duration_9027}
    check_data_transfer_is_alive    dt_name=DT_UL
    check_data_transfer_is_alive    dt_name=DT_DL
    Stop data transfer    dt_name=DT_UL
    Stop data transfer    dt_name=DT_DL

    Detach UE    UE_1

    GnbCounter.Wait for next pm period   interval=${pm_interval_9027}

    ${counters}=    Generate Counters String
    ...    first_counter=${first_counter_set_9027}
    ...    last_counter=${last_counter_set_9027}

    ${counters_2}=    Generate Counters String
    ...    first_counter=${first_counter_set_9027_range2}
    ...    last_counter=${last_counter_set_9027_range2}

    ${counter_dict}=    Get Counters    counter_ids=${counters}
    ${counter_dict_2}=    Get Counters    counter_ids=${counters_2}
    ${cell_list}=    gnbcell.Get All Cells ID
    ${bts_id}=       gnbcell.Get Global BTS ID

    ${counters_dict_for_cell1}=    Find PM Counters For Cell   ${counter_dict}   ${cell_id_9027_1}   ${pm_periods}
    ${prbs_without_prach_cell1}=   Get PRBs From Dict   ${counters_dict_for_cell1}   cell1
    Set Global Variable   ${prbs_without_prach_cell1}

    ${counters_dict_for_cell2}=    Find PM Counters For Cell   ${counter_dict}   ${cell_id_9027_2}   ${pm_periods}
    ${prbs_without_prach_cell2}=   Get PRBs From Dict   ${counters_dict_for_cell2}   cell2
    Set Global Variable   ${prbs_without_prach_cell2}

    ${counters_dict_for_cell1_range2}=    Find PM Counters For Cell   ${counter_dict_2}   ${cell_id_9027_1}   ${pm_periods}
    ${prbs_without_prach_cell1_range2}=   Get PRBs From Dict   ${counters_dict_for_cell1_range2}   cell1
    Set Global Variable   ${prbs_without_prach_cell1_range2}

    ${counters_dict_for_cell2_range2}=    Find PM Counters For Cell   ${counter_dict_2}   ${cell_id_9027_2}   ${pm_periods}
    ${prbs_without_prach_cell2_range2}=   Get PRBs From Dict   ${counters_dict_for_cell2_range2}   cell2
    Set Global Variable   ${prbs_without_prach_cell2_range2}

CB009027-2_Verification_of_scheduled_PRB_values_for_2_enabledWithoutPRACH_ABIP
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements without PRACH channel
     Check If Counter PRBs Values Are In Range
     ...   ${prbs_without_prach_cell1}
     ...   ${prbs_without_prach_cell2}
     ...   ${prbs_without_prach_cell1_range2}
     ...   ${prbs_without_prach_cell2_range2}


UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH
    [Documentation]   Setup for CB009027 testcases using interference measurement without PUCCH
    Setup and check preconditions in scf   params_to_check=${without_pucch_params}    bts_host=192.168.255.129

    ${pm_periods}=    GnbCounter.Wait for next pm period   interval=${pm_interval_9027}
    Require UE   UE_1   capabilities=REAL_UE_SA

    Attach to cell at ports    ${cell_2_attenuator_ports}

    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                   direction=dl       duration=${tput_duration_9027}
    ...                   packet_size=1200            throughput=${tput_dl_9027}         protocol=${tput_protocol_9027}
    ...                   iperf_version=2
    Start data transfer   dt_name=DT_UL               ue_alias=UE_1                   direction=ul       duration=${tput_duration_9027}
    ...                   packet_size=1200            throughput=${tput_ul_9027}         protocol=${tput_protocol_9027}
    ...                   iperf_version=2
    BuiltIn.Sleep                 ${tput_duration_9027}
    check_data_transfer_is_alive    dt_name=DT_UL
    check_data_transfer_is_alive    dt_name=DT_DL
    Stop data transfer    dt_name=DT_UL
    Stop data transfer    dt_name=DT_DL

    Detach UE    UE_1

    GnbCounter.Wait for next pm period   interval=${pm_interval_9027}

    ${counters}=    Generate Counters String
    ...    first_counter=${first_counter_set_9027}
    ...    last_counter=${last_counter_set_9027}

    ${counters_2}=    Generate Counters String
    ...    first_counter=${first_counter_set_9027_range2}
    ...    last_counter=${last_counter_set_9027_range2}

    ${counter_dict}=    Get Counters    counter_ids=${counters}
    ${counter_dict_2}=    Get Counters    counter_ids=${counters_2}
    ${cell_list}=    gnbcell.Get All Cells ID
    ${bts_id}=       gnbcell.Get Global BTS ID

    ${counters_dict_for_cell1}=    Find PM Counters For Cell   ${counter_dict}   ${cell_id_9027_1}   ${pm_periods}
    ${prbs_without_pucch_cell1}=   Get PRBs From Dict   ${counters_dict_for_cell1}   cell1
    Set Global Variable   ${prbs_without_pucch_cell1}

    ${counters_dict_for_cell2}=    Find PM Counters For Cell   ${counter_dict}   ${cell_id_9027_2}   ${pm_periods}
    ${prbs_without_pucch_cell2}=   Get PRBs From Dict   ${counters_dict_for_cell2}   cell2
    Set Global Variable   ${prbs_without_pucch_cell2}

   ${counters_dict_for_cell1_range2}=    Find PM Counters For Cell   ${counter_dict_2}   ${cell_id_9027_1}   ${pm_periods}
    ${prbs_without_pucch_cell1_range2}=   Get PRBs From Dict   ${counters_dict_for_cell1_range2}   cell1
    Set Global Variable   ${prbs_without_pucch_cell1_range2}

    ${counters_dict_for_cell2_range2}=    Find PM Counters For Cell   ${counter_dict_2}   ${cell_id_9027_2}   ${pm_periods}
    ${prbs_without_pucch_cell2_range2}=   Get PRBs From Dict   ${counters_dict_for_cell2_range2}   cell2
    Set Global Variable   ${prbs_without_pucch_cell2_range2}

CB009027-3_Verification_of_scheduled_PRB_values_for_3_enabledWithoutPUCCH_F1_ABIP
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements without PUCCH channel
     Check If Counter PRBs Values Are In Range
     ...   ${prbs_without_pucch_cell1}
     ...   ${prbs_without_pucch_cell2}
     ...   ${prbs_without_pucch_cell1_range2}
     ...   ${prbs_without_pucch_cell2_range2}


UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH_AND_PRACH
    [Documentation]   Setup for CB009027 testcases using interference measurement without PUCCH and PRACH
    Setup and check preconditions in scf   params_to_check=${without_pucch_and_prach_params}    bts_host=192.168.255.129

    ${pm_periods}=    GnbCounter.Wait for next pm period   interval=${pm_interval_9027}
    Require UE   UE_1   capabilities=REAL_UE_SA

    Attach to cell at ports    ${cell_2_attenuator_ports}

    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                   direction=dl       duration=${tput_duration_9027}
    ...                   packet_size=1200            throughput=${tput_dl_9027}         protocol=${tput_protocol_9027}
    ...                   iperf_version=2
    Start data transfer   dt_name=DT_UL               ue_alias=UE_1                   direction=ul       duration=${tput_duration_9027}
    ...                   packet_size=1200            throughput=${tput_ul_9027}         protocol=${tput_protocol_9027}
    ...                   iperf_version=2
    BuiltIn.Sleep                 ${tput_duration_9027}
    check_data_transfer_is_alive    dt_name=DT_UL
    check_data_transfer_is_alive    dt_name=DT_DL
    Stop data transfer    dt_name=DT_UL
    Stop data transfer    dt_name=DT_DL

    Detach UE    UE_1

    GnbCounter.Wait for next pm period   interval=${pm_interval_9027}

    ${counters}=    Generate Counters String
    ...    first_counter=${first_counter_set_9027}
    ...    last_counter=${last_counter_set_9027}

    ${counters_2}=    Generate Counters String
    ...    first_counter=${first_counter_set_9027_range2}
    ...    last_counter=${last_counter_set_9027_range2}

    ${counter_dict}=    Get Counters    counter_ids=${counters}
    ${counter_dict_2}=    Get Counters    counter_ids=${counters_2}
    ${cell_list}=    gnbcell.Get All Cells ID
    ${bts_id}=       gnbcell.Get Global BTS ID

    ${counters_dict_for_cell1}=    Find PM Counters For Cell   ${counter_dict}   ${cell_id_9027_1}   ${pm_periods}
    ${prbs_without_pucch_and_prach_cell1}=   Get PRBs From Dict   ${counters_dict_for_cell1}   cell1
    Set Global Variable   ${prbs_without_pucch_and_prach_cell1}

    ${counters_dict_for_cell2}=    Find PM Counters For Cell   ${counter_dict}   ${cell_id_9027_2}   ${pm_periods}
    ${prbs_without_pucch_and_prach_cell2}=   Get PRBs From Dict   ${counters_dict_for_cell2}   cell2
    Set Global Variable   ${prbs_without_pucch_and_prach_cell2}

    ${counters_dict_for_cell1_range2}=    Find PM Counters For Cell   ${counter_dict_2}   ${cell_id_9027_1}   ${pm_periods}
    ${prbs_without_pucch_and_prach_cell1_range2}=   Get PRBs From Dict   ${counters_dict_for_cell1_range2}   cell1
    Set Global Variable   ${prbs_without_pucch_and_prach_cell1_range2}

    ${counters_dict_for_cell2_range2}=    Find PM Counters For Cell   ${counter_dict_2}   ${cell_id_9027_2}   ${pm_periods}
    ${prbs_without_pucch_and_prach_cell2_range2}=   Get PRBs From Dict   ${counters_dict_for_cell2_range2}   cell2
    Set Global Variable   ${prbs_without_pucch_and_prach_cell2_range2}

CB009027-4_Verification_of_scheduled_PRB_values_for_4_enabledWithoutPRACH_PUCCH_F1_ABIP
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements with PRACH and PUCCH channel disabled
     Check If Counter PRBs Values Are In Range
     ...   ${prbs_without_pucch_and_prach_cell1}
     ...   ${prbs_without_pucch_and_prach_cell2}
     ...   ${prbs_without_pucch_and_prach_cell1_range2}
     ...   ${prbs_without_pucch_and_prach_cell2_range2}
