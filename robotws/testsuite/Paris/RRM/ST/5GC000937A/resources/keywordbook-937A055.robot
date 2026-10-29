*** Settings ***
Documentation
...      todo:clean


*** Keywords ***
Configure Hytem sequence for RRC Re-establishment
    [Arguments]    ${sequence_file}    ${gnb_id}=0    ${login}=players   ${pwd}=players

    #bypass robocop
    ${gnb_id}=    Set Variable    ${gnb_id}
    ${master_channel}    Set Variable if    ${source_cellId} == 0    1    5
    ${all_channels}    Evaluate    list(range(${master_channel}, ${master_channel}+4))

    vm_handler.connect    ${custom['Hytem_IP']}    ${login}    ${pwd}
    FOR    ${channel}    IN    @{all_channels}
        vm_handler.load_seq    ${custom['Hytem_IP']}    1    ${channel}    ${sequence_file}

        ${is_master}    Set Variable If    ${channel} == ${master_channel}    0    1
        vm_handler.sync    ${custom['Hytem_IP']}    1    ${channel}    ${master_channel}    ${is_master}    -1
    END
    vm_handler.close


Set Hytem Player for RRC Re-establishment
    [Arguments]    ${request}     ${login}=players   ${pwd}=players

    ${master_channel}    Set Variable if    ${source_cellId} == 0    1    5
    vm_handler.connect    ${custom['Hytem_IP']}    ${login}    ${pwd}
    vm_handler.set_player    ${custom['Hytem_IP']}    port=1    request=${request}    player_num=${master_channel}
    vm_handler.close


Update gnb parameter values with full commissioning coam source gnb for 937A055
    [Arguments]    ${gnb_id}=0
    set test variable   ${nrbts_dn}        ${gnb_${gnb_id}_bts_distName}
    set test variable   ${nrcell_dn}     ${gnb_${gnb_id}_bts_distName}/${source_distName}

    ${param_list}     Create List
#          general parameters
    ...    modify:${nrbts_dn}:srb3SupportEnabled=${srb3SupportEnabled_src[1]}
    ...    modify:${nrbts_dn}:actCarrierAggregation=${actCarrierAggregation_src[1]}
    ...    modify:${nrcell_dn}:cbraPreamblesPerSsb=${cbraPreamblesPerSsb_src[1]}
    ...    modify:${nrcell_dn}:actCDrx=${actCDrx_src[1]}
    ...    modify:${nrcell_dn}:actPowerSavingBWP=${actPowerSavingBWP_src[1]}
#          modify rrcReestabTypeSA parameter :
    ...    modify:${nrbts_dn}:rrcReestabTypeSA=${rrcReestabTypeSA_src[1]}
#          modify measurement interval parameters
    ...    modify:${gnb_${gnb_id}_pmcadm_distName}:reportingIntervalPm=${measurement_period_in_min}min
    ...    modify:${nrbts_dn}/NRPMRNL-1:miNrRRCC=${measurement_period_in_min}min
    ...    modify:${nrbts_dn}/NRPMRNL-1:miNrPdcch=${measurement_period_in_min}min

    load_scf   ${resultBaseDir}/SCFC_start_gnb_${gnb_id}.xml
    perform_scf_modification   ${param_list}
    save_scf   ${resultBaseDir}/SCFC_updated_gnb_${gnb_id}.xml
    restore SCF coam ext02    gnb_id=${gnb_id}    scf=SCFC_updated_gnb_${gnb_id}.xml



#restore SCF coam ext02
#    [Documentation]    [PRIVATE] restore SCF on classical gnb
#    ...     :Autor: Sylvia Schneider
#    ...     :ext01  Gerard Bonhaure   to manage multi gNB
#    ...     :param ${gnb_id}: gNB instance id
#    ...     :param ${scf}: scf file name
#    [Arguments]     ${gnb_id}=0   ${scf}=SCFC_start_gnb_0.xml
#    builtIn.Log To Console    \nfull commissioning on coam gnb-${gnb_id} started
#    admin.connect_to
#    ...    bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
#    ...    name=gnb
#    admin.perform_commissioning
#  # ...   scf_file=${resultBaseDir}/SCFC_start_gnb_${gnb_id}.xml
#    ...   scf_file=${resultBaseDir}/${scf}
#    ...   skip_parameter_relation_errors=True
#    ...   should_activate=${TRUE}
#    ...   timeout=660
#    ...   connection=gnb
#    admin.teardown    connection=gnb
#    Wait until coam gNB to be onair state and cells enabled ext01   gnb_id=${source_gnb_id}   num_of_disabled_cells=0
#    builtIn.Log To Console    full commissioning on coam gnb-${gnb_id} finished

