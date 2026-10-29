*** Settings ***
Documentation
...    author/contact: julia.luszcz@nokia.com


*** Keywords ***
BTS_start-up_with_configured_predefined_RU_full_commissioning
    [Arguments]    ${is_asir}=False     ${ru_id}=3   ${radio_type}=rmod    ${bts_id}=${0}
    ${radio_type} =    Set variable if    ${is_asir}
    ...                                   asirmod
    ...                                   rmod
    Change RU to predefined     ${is_asir}
    Check predefined statuses       ${is_asir}   ${ru_id}
    ${scfs_files}=    operations.Download_bts_configuration    bts_id=${bts_id}
    Run keywords           gnbscf.reset_configuration
    ...    AND             gnbbbu.wait_until_smod_is_online
    ...    AND             gnbbbu.wait_until_bbmod_is_online        timeout=240
    ...    AND             gnbbbu.verify_bts_is_not_commissioned

    Log to console    Perform BTS commissioning
    ${asir_scf}    Set Variable If    'ASIR' in ${scfs_files}   ${scfs_files}[ASIR]    ${None}
    operations.Perform_bts_commissioning               bts_id=${bts_id}    scf_path=${scfs_files}[BTS]
    ...                                     asir_scf_path=${asir_scf}
    ...                                     commissioning_timeout=${400}
    ...                                     asir_commissioning_timeout=${120}
    ...                                     wait_for_on_air=${False}
    Check predefined statuses               is_asir=${is_asir}
    ...                                     ru_id=${ru_id}
    ...                                     procedural_status=not initialized
    ...                                     timeout=600
    Wait Until Keyword Succeeds     600sec     30sec    Verify not predefined RUs statuses      is_asir=${is_asir}
    ...                                     ru_id=${ru_id}
    ...                                     radio_type=${radio_type}
    ...                                     timeout=10min

Change RU to predefined
    [Arguments]   ${is_asir}=False
    gnbscf.Perform bts delta_commissioning  delta=${predefined_delta}
    Run Keyword If    ${is_asir}    gnb_asir.Perform Asir Recommissioning       ${asir_delta}

Change RU to not predefined
    [Arguments]   ${is_asir}=False
    gnbscf.Perform bts delta_commissioning  delta=${not_predefined_delta}
    Run Keyword If    ${is_asir}    gnb_asir.Perform Asir Recommissioning       ${not_predefined_asir_delta}


Check predefined statuses
    [Arguments]   ${is_asir}=False  ${radio_type}=rmod    ${ru_id}=3      ${procedural_status}=configured
    ...             ${timeout}=240
    ${radio_type} =    Set variable if    ${is_asir}
    ...                                   asirmod
    ...                                   rmod
    Log to console      ${radio_type}
    ${procedural_status} =  Set Procedural Status   ${procedural_status}
    gnbru.Wait for Radio Unit statuses      ru_id=${ru_id}
    ...                                     radio_type=${radio_type}
    ...                                     operational_state=disabled
    ...                                     procedural_status=initializing
    gnbru.Wait for Radio Unit statuses     ru_id=${ru_id}
    ...                                 radio_type=${radio_type}
    ...                                 operational_state=enabled
    ...                                 procedural_status=configured
    ...                                 timeout=${timeout}
    FOR     ${cell}     IN      @{predefined_cells}
        gnbcell.Wait for Cell statuses    cell_id=${cell}
        ...                             availability_status=offline
        ...                             operational_state=disabled
        ...                             blocking_state=Unblocked
        ...                             administrative_state=Unlocked
        ...                             procedural_status=${procedural_status}
    END
    Run Keyword If    ${is_asir}   Check ASIR predefined statuses


Check not predefined statuses
    [Arguments]   ${is_asir}=False      ${radio_type}=rmod    ${ru_id}=3
    ${radio_type} =    Set variable if    ${is_asir}
    ...                                   asirmod
    ...                                   rmod
    Log to console      ${radio_type}
    gnbru.Wait for Radio Unit statuses      ru_id=${ru_id}
    ...                                     radio_type=${radio_type}
    ...                                     operational_state=enabled
    ...                                     procedural_status=configured
    ...                                     timeout=240

    FOR     ${cell}     IN      @{predefined_cells}
        gnbcell.Wait for Cell statuses      cell_id=${cell}
        ...                                 availability_status=online
        ...                                 operational_state=enabled
        ...                                 blocking_state=Unblocked
        ...                                 administrative_state=Unlocked
        ...                                 procedural_status=configured
        ...                                 timeout=600
    END
    Run Keyword If    ${is_asir}    Wait Until Keyword Succeeds     600sec     30sec
    ...     gnb_asir.Verify status of all asir cells is operational

Turn on automated activation
    gnbscf.Perform bts delta_commissioning  delta=${automated_activation_on}

Turn off automated activation
    gnbscf.Perform bts delta_commissioning  delta=${automated_activation_off}

Check ASIR predefined statuses
    verify predefined asir cells status            ant_id=1

Verify not predefined RUs statuses
    [Arguments]   ${is_asir}=False    ${radio_type}=rmod    ${ru_id}=0      ${timeout}=2min
    ${radio_type} =    Set variable if    ${is_asir}
    ...                                   ASIRMOD
    ...                                   RMOD
    Wait Until Keyword Succeeds     ${timeout}     30sec     verify not predefined rus and cells      predefined_id=${ru_id}
    ...                                                 radio_type=${radio_type}
    Run Keyword If    ${is_asir}    verify not predefined asir cells status            ant_id=1
