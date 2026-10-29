*** Settings ***
Library    taf.config.scf    WITH NAME    scf
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.scf.scf_analysis.ScfAnalysis    WITH NAME    scf_analysis

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot


*** Keywords ***
Cloud Enter to TDS Mode
    [Documentation]    *****************
    ...    This keyword is used to enter the Test Mode in the Cloud.
    ...    - [Keyword Details]
    ...    This keyword accepts the vDU index and gNB index as arguments.
    ...    It then generates a unique string and uses it to connect to the vDU.
    ...    It deletes the SWRESETREQ-1 MO by Delta Plan and resets the vDU with check cell on air.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | vdu index in testline configuration file. Default is 0. |
    ...    | gnb_index | No | gnb index in testline configuration file. Default is 0. |
    ...    | local_output_dir | No | The local directory path to save the SCF file. Default is ${SAVE LOG DIRECTORY}. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 15.05.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    [Arguments]   ${vdu_index}=0    ${gnb_index}=0    ${local_output_dir}=${SAVE LOG DIRECTORY}
    Log    \nEnter Test Model in Cloud    console=yes
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    ${TDS_dist_name}    Set Variable    MRBTS-${mrbts_id}/MNL-1/CMD-1/SWRESETREQ-1
    ${scf_path}    vdu.Get_Current_Plan_File    local_dir_path=${local_output_dir}    filename=scf.xml
    ...    include_runtime_data=${False}    vdu_connection=${conn_alias}
    scf.load scf    ${scf_path}
    ${expected_dn_exists}    scf.Is Object In Scf    ${TDS_dist_name}
    # If the SWRESETREQ-1 MO exists, delete it first, otherwise vDU cann't enter the TDS mode.
    Run Keyword If    "${expected_dn_exists}"=="True"    Cloud Delete SWRESETREQ-1 MO By Delta Plan    mrbts_id=${mrbts_id}
    ${delta_plan_name}    generic_utils.get_unique_id_string    prefix=TDS_Mode_Plan    precise=LOW
    ${plan_id}    vdu_cm_base.generate_dela_plan_file    delta_plan_name=${delta_plan_name}    conn_alias=${conn_alias}
    vdu_cm_base.create_managed_object_for_delta_plan    parent_mo_dn=MRBTS-${mrbts_id}/MNL-1/CMD-1
    ...    mo_name=SWRESETREQ-1    conn_alias=${conn_alias}
    ${para_dict}=    Create Dictionary    swResetLevel=resetToTestLevel
    vdu_cm_base.update_parameter_for_delta_plan    mo_dn=${TDS_dist_name}    delta_param_dict=${para_dict}
    ...    operation=add    conn_alias=${conn_alias}
    vdu_cm_base.validate_delta_plan    conn_alias=${conn_alias}
    vdu_cm_base.activate_delta_plan    conn_alias=${conn_alias}
    Wait Until Keyword Succeeds    12min    20s    Cloud Check vDU Status Should Be Expected
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Exit TDS Mode
    [Documentation]    *****************
    ...    This keyword is used to exit the Test Mode in the Cloud.
    ...    - [Keyword Details]
    ...    This keyword accepts the vDU index and gNB index as arguments.
    ...    It then generates a unique string and uses it to connect to the vDU.
    ...    It deletes the SWRESETREQ-1 MO by Delta Plan and resets the vDU with check cell on air.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | vdu index in testline configuration file. Default is 0. |
    ...    | gnb_index | No | gnb index in testline configuration file. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 15.05.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    [Arguments]   ${vdu_index}=0    ${gnb_index}=0
    Log    \nExit Test Model in Cloud    console=yes
    Cloud Delete SWRESETREQ-1 MO By Delta Plan    mrbts_id=${mrbts_id}
    Cloud Reset vDU and Check Cell On Air   need_check_on_air=${True}

Cloud Delete SWRESETREQ-1 MO By Delta Plan
    [Documentation]    *****************
    ...    This keyword is used to delete the SWRESETREQ-1 MO by Delta Plan in the Cloud.
    ...    - [Keyword Details]
    ...    This keyword accepts the MRBTS ID, vDU index, and gNB index as arguments.
    ...    It then generates a unique string and uses it to login to the vDU.
    ...    It deletes the MO of the Delta Plan and retrieves the action ID.
    ...    It then validates and activates the Delta Plan.
    ...    After the operation, it logs out from the vDU.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | mrbts_id | Yes | The MRBTS ID. |
    ...    | vdu_index | No | vdu index in testline configuration file. Default is 0. |
    ...    | gnb_index | No | gnb index in testline configuration file. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 15.05.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    [Arguments]    ${mrbts_id}    ${vdu_index}=0    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    Log    \nDelete SWRESETREQ-1 MO    console=yes
    ${delta_plan_name}    generic_utils.get_unique_id_string    prefix=TDS_Mode_Delete_SWRESETREQ_Plan    precise=LOW
    ${plan_id}   vdu_cm_base.generate_dela_plan_file   delta_plan_name=${delta_plan_name}   conn_alias=${conn_alias}
    Cloud Delete Delta Plan MO DN    plan_id=${plan_id}   mo_dn=MRBTS-${mrbts_id}/MNL-1/CMD-1/SWRESETREQ-1
    vdu_cm_base.validate_delta_plan    conn_alias=${conn_alias}
    vdu_cm_base.activate_delta_plan    conn_alias=${conn_alias}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Start Downlink Test Model
    [Documentation]    *****************
    ...    This keyword is used to start the Downlink Test Model in the Cloud.
    ...    - [Keyword Details]
    ...    This keyword accepts the test model, cell ID, vDU index, and gNB index as arguments.
    ...    It then generates a unique string and uses it to connect to the vDU.
    ...    It retrieves the NRARFCN, power backoff, pMax, and physical cell ID from the SCF for each cell ID in the list.
    ...    It then starts the 5G downlink test for each cell ID in the list.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | test_model | No | The test model. Default is NR-FR1-TM1.1. |
    ...    | cell_id | No | The cell ID. Default is all. |
    ...    | vdu_index | No | vdu index in testline configuration file. Default is 0. |
    ...    | gnb_index | No | gnb index in testline configuration file. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 15.05.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    [Arguments]  ${test_model}=NR-FR1-TM1.1    ${cell_id}=all    ${vdu_index}=0    ${gnb_index}=0
    ...    ${scf_path}=${Golden_VDU_SCF_Path}
    Log    \nStart Downlink Test Model ${test_model}    console=yes
    scf_analysis.setup    scf_path=${scf_path}
    ${cell_list}    Cloud Get Cells Id List    cell_id=${cell_id}
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    FOR    ${cell_id}    IN    @{cell_list}
        Log    \nStart Downlink Test Model in cell: ${cell_id}    console=yes
        ${nrarfcn}    scf_analysis.get_nrarfcn_from_scf    cell_id=${cell_id}
        ${power_backoff}    scf_analysis.get_dlQam256PowerBackoffSub6_from_scf    cell_id=${cell_id}
        ${pmax}    scf_analysis.get_pMax_from_scf    cell_id=${cell_id}
        ${pmax}    evaluate    int(${pmax})/10
        ${physical_cell_id}    scf_analysis.get_physCellId_from_scf    cell_id=${cell_id}
        @{beam_pattern_id}    create list    ${1}    ${1}    ${1}    ${1}
        vdu.start_5g_downlink_test    nrcell_id=${cell_id}
        ...                           test_model=${test_model}
        ...                           beam_pattern_id=${beam_pattern_id}
        ...                           polarization=P_both
        ...                           power_backoff=${power_backoff}
        ...                           ru_mode=NR_only
        ...                           phys_cell_id=${physical_cell_id}
        ...                           codebook_2_antports=0
        ...                           i11_codebook_4_antports=0
        ...                           i2_codebook_4_antports=0
        ...                           i13_codebook_4_antports=0
        ...                           mimo_rank=Rank1
        ...                           nrarfcn=${nrarfcn}
        ...                           p_max=${pmax}
        ...                           timeout=120
        ...                           vdu_connection=${conn_alias}
        sleep    1min
    END
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Stop Downlink Test Model
    [Documentation]    *****************
    ...    This keyword is used to stop the Downlink Test Model in the Cloud.
    ...    - [Keyword Details]
    ...    This keyword accepts the FRC index, cell ID, SCF path, vDU index, and gNB index as arguments.
    ...    It then generates a unique string and uses it to connect to the vDU.
    ...    It retrieves the NRARFCN and physical cell ID from the SCF for each cell ID in the list.
    ...    It then starts the 5G uplink test for each cell ID in the list.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | cell_id | No | The cell ID. Default is all. |
    ...    | vdu_index | No | vdu index in testline configuration file. Default is 0. |
    ...    | gnb_index | No | gnb index in testline configuration file. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 15.05.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    [Arguments]  ${cell_id}=all    ${vdu_index}=0    ${gnb_index}=0
    Log    \nStop Downlink Test Model    console=yes
    ${cell_list}    Cloud Get Cells Id List    cell_id=${cell_id}
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    FOR    ${cell_id}    IN    @{cell_list}
        Log    \nStop Downlink Test Model in cell: ${cell_id}    console=yes
        vdu.stop_5g_downlink_test    nrcell_id=${cell_id}    timeout=120    vdu_connection=${conn_alias}
    END
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Test Downlink Test Model
    [Documentation]    *****************
    ...    This keyword is used to test the Downlink Test Model in the Cloud.
    ...    - [Keyword Details]
    ...    This keyword accepts the test model list and cell ID as arguments.
    ...    It then iterates over the test model list, starting and stopping the Downlink Test Model for each test model.
    ...    If the cell ID is set to 'all', it applies the operation to all cells.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | test_model_list | Yes | The test model list. |
    ...    | cell_id | No | The cell ID. Default is all. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 15.05.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    [Arguments]  ${test_model_list}    ${cell_id}=all
    FOR    ${test_model}    IN    @{test_model_list}
        Cloud Start Downlink Test Model    test_model=${test_model}    cell_id=${cell_id}
        sleep    2min
        Cloud Stop Downlink Test Model
    END

Cloud Start Uplink Test Model
    [Documentation]    *****************
    ...    This keyword is used to start the Uplink Test Model in the Cloud.
    ...    - [Keyword Details]
    ...    This keyword accepts the FRC index, cell ID, SCF path, vDU index, and gNB index as arguments.
    ...    It then generates a unique string and uses it to connect to the vDU.
    ...    It retrieves the NRARFCN and physical cell ID from the SCF for each cell ID in the list.
    ...    It then starts the 5G uplink test for each cell ID in the list.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | frc_index | No | The FRC index. Default is NR-FR1-TM1.1. |
    ...    | cell_id | No | The cell ID. Default is all. |
    ...    | scf_path | No | The SCF path. Default is ${Golden_VDU_SCF_Path}. |
    ...    | vdu_index | No | vdu index in testline configuration file. Default is 0. |
    ...    | gnb_index | No | gnb index in testline configuration file. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 15.05.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    [Arguments]  ${frc_index}=NR-FR1-TM1.1    ${cell_id}=all    ${scf_path}=${Golden_VDU_SCF_Path}    ${vdu_index}=0
    ...    ${gnb_index}=0
    Log    \nStart Uplink Test Model ${frc_index}    console=yes
    ${cell_list}    Cloud Get Cells Id List    cell_id=${cell_id}
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    scf_analysis.setup    scf_path=${scf_path}
    FOR    ${cell_id}    IN    @{cell_list}
        Log    \nStart Uplink Test Model in cell: ${cell_id}    console=yes
        ${nrarfcn}    scf_analysis.get_nrarfcn_from_scf    cell_id=${cell_id}
        ${physical_cell_id}    scf_analysis.get_physCellId_from_scf    cell_id=${cell_id}
        @{beam_pattern_id}    create list    ${1}    ${1}    ${1}    ${1}
        vdu.start_5g_uplink_test    nrcell_id=${cell_id}
        ...                         frc_index=${frc_index}
        ...                         beam_pattern_id=${beam_pattern_id}
        ...                         interval=1
        ...                         prb_offset=0
        ...                         ru_mode=NR_only
        ...                         phys_cell_id=${physical_cell_id}
        ...                         nrarfcn=${nrarfcn}
        ...                         timeout=120
        ...                         vdu_connection=${conn_alias}
        Log To Console    sleep 1min
        sleep  1min
        vdu.get_5g_uplink_test_results    nrcell_id=${cell_id}    vdu_connection=${conn_alias}
    END
    [Teardown]  vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Stop Uplink Test Model
    [Documentation]    *****************
    ...    This keyword is used to stop the Uplink Test Model in the Cloud.
    ...    - [Keyword Details]
    ...    This keyword accepts the cell ID, vDU index, and gNB index as arguments.
    ...    It then generates a unique string and uses it to connect to the vDU.
    ...    It retrieves the list of all cell IDs from the vDU if the cell ID is set to 'all'.
    ...    It then stops the 5G uplink test for each cell ID in the list.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | cell_id | No | The cell ID. Default is all. |
    ...    | vdu_index | No | vdu index in testline configuration file. Default is 0. |
    ...    | gnb_index | No | gnb index in testline configuration file. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 15.05.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    [Arguments]  ${cell_id}=all    ${vdu_index}=0    ${gnb_index}=0
    Log    \nStop Uplink Test Model    console=yes
    ${cell_list}    Cloud Get Cells Id List    cell_id=${cell_id}
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    FOR    ${cell_id}    IN    @{cell_list}
        Log    \nStop Uplink Test Model in cell: ${cell_id}    console=yes
        vdu.stop_5g_uplink_test    nrcell_id=${cell_id}    timeout=120    vdu_connection=${conn_alias}
    END
    [Teardown]  vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Test Uplink Test Model
    [Documentation]    *****************
    ...    This keyword is used to test the Uplink Test Model in the Cloud.
    ...    - [Keyword Details]
    ...    This keyword accepts the FRC index list and cell ID as arguments.
    ...    It then iterates over the FRC index list, starting and stopping the Uplink Test Model for each FRC index.
    ...    If the cell ID is set to 'all', it applies the operation to all cells.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | frc_index_list | Yes | The FRC index list. |
    ...    | cell_id | No | The cell ID. Default is all. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 15.05.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    [Arguments]  ${frc_index_list}    ${cell_id}=all
    FOR    ${frc_index}    IN    @{frc_index_list}
        Cloud Start Uplink Test Model    frc_index=${frc_index}    cell_id=${cell_id}
        sleep    2min
        Cloud Stop Uplink Test Model
    END
