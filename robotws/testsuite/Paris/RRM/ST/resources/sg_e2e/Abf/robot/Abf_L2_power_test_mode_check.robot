*** Settings ***
Documentation   Suite description

Library         OperatingSystem
Library         Process
Library         Collections
Library         String
Library         DateTime

Library         taf.gnb.oam.commissioning                   WITH NAME   cm
Library         taf.transport.ssh                           WITH NAME   ssh

Resource        ${CURDIR}/../../configuration.robot
Resource        ${CURDIR}/../../mirroringScripts/gnbMirroring.robot
Resource        ${CURDIR}/../../QCT_androidUe_useful_keywords.robot
Resource        ${CURDIR}/../../beamKeyword.robot

*** Keywords ***
Abf_L2_power_test_mode_check
    [Arguments]     ${beamset}
    [Teardown]      Run keyword and ignore error      configuration.Close Connections SSH

    # Prepare L1L2 traces
    configuration.Create ssh
    ${path_of_mirroring_script_on_ASIK}    logs.Prepare Mirroring script on Asik    connection=asikFhCnx
    gnbMirroring.Update gnbMirroringConfig Script    connection=asikFhCnx    number_of_files=5    file_size_mbytes=90

    # With writer tool, setup beam attenuations so that Ue chooses radiated beam 44 - SSB Id 21
    ${beam_attenuation_pattern}=    Catenate    SEPARATOR=    \\x10\\x00\\x00\\x00\\x00\\x00\\x00\\x00
    ...                                                       \\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00
    ...                                                       \\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00
    ...                                                       \\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00
    ...                                                       \\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00
    beamKeyword.Set Beam Attenuation    beam_attenuation_string=${beam_attenuation_pattern}

    # Start traces L1L2
    logs.Start Customized Mirroring Traces on Asik    connection=asikFhCnx    remote_path1=${path_of_mirroring_script_on_ASIK}

    Sleep   10s

    # With writer tool, setup beam attenuations for step 1
    # Stopping and gathering Ue traces takes a very long time, it is mandattory to stop L1L2 traces first
    gnbMirroring.Stop tcpdump Mirroring Traces    connection=asikFhCnx
    ${L1L2_log_first_step}=     logs.Collect and clean mirroring traces on ASIK    connection=asikFhCnx

    # Rename L1L2 trace files with step1
    FOR    ${file}    IN    @{L1L2_log_first_step}
           ${root_file_name}=          string.fetch from left    ${file}    .
           ${suffix_file_name}=        string.fetch from right   ${file}    .
           ${L1L2_trace_step1}         catenate    SEPARATOR=    ${root_file_name}    _step1.    ${suffix_file_name}
           Move File                   ${file}    ${L1L2_trace_step1}
    END



    # Step 2 change beam
    #####################

    # Start L1L2 and Ue traces
    logs.Start Customized Mirroring Traces on Asik    connection=asikFhCnx    remote_path1=${path_of_mirroring_script_on_ASIK}
    # With writer tool, setup beam attenuations for step 2
    ${beam_attenuation_pattern}=    Catenate    SEPARATOR=    \\x00\\x00\\x00\\x00\\xFF\\xFF\\xFF\\xFF
    ...                                                       \\xFF\\xFF\\xFF\\xFF\\x00\\xFF\\xFF\\xFF
    ...                                                       \\x00\\xFF\\xFF\\xFF\\x00\\xFF\\xFF\\xFF
    ...                                                       \\x00\\xFF\\xFF\\xFF\\x00\\xFF\\xFF\\xFF
    ...                                                       \\x00\\xFF\\xFF\\xFF\\x00\\xFF\\xFF\\xFF
    beamKeyword.Set Beam Attenuation    beam_attenuation_string=${beam_attenuation_pattern}
    BuiltIn.Sleep    10

    # Stop and collect Ue and L1L2 traces
    gnbMirroring.Stop tcpdump Mirroring Traces    connection=asikFhCnx
    ${L1L2_log_second_step}=     logs.Collect and clean mirroring traces on ASIK    connection=asikFhCnx
    BuiltIn.Sleep    5
    ${Ue_log_file_step2}=     Get Decoded Qmdl Files Path   ${Ue_alias}    10

    # Rename L1L2 trace files with step2
    FOR    ${file}    IN    @{L1L2_log_second_step}
           ${root_file_name}=          string.fetch from left    ${file}    .
           ${suffix_file_name}=        string.fetch from right   ${file}    .
           ${L1L2_trace_step2}         catenate    SEPARATOR=    ${root_file_name}    _step1.    ${suffix_file_name}
           Move File                   ${file}    ${L1L2_trace_step2}
    END

    #Test analysis Step 1
    Log                         ${L1L2_trace_step1}
    ${cmd}    catenate    tshark -X lua_script/opt/luashark/luashark.lua -r ${L1L2_trace_step1} -T fields -Y "dldata_slottypereq"
    ...         -e _ws.col.Info -e DlData_SlotTypeReq.SlotTypeReq.slot -e DlData_SlotTypeReq.SlotTypeReq.slotType
    ...         -e DlData_SlotTypeReq.pwrReductionPerSymb_dB.pwrReductionPerSymb_dB
    ...         -E header=y -E separator=, > ${logs_path}/pcapprocessed_003_step1.txt
    Run       ${cmd}

    #Check on slot1 that the power is reduced by 0x10 on slot 1 (slotype 2)
    ${cmd}    catenate      cat ${logs_path}/pcapprocessed_003_step1.txt | grep -P
    #...         'ICOM_5G/DlData_SlotTypeReq,0x00000001,0x00000002,(([0-9a-z][0-9a-z]){2})0000ffff' -c
    #...         'ICOM_5G/DlData_SlotTypeReq,0x00000005,0x00000002,(([0-9a-z][0-9a-z]){2})000005051010' -c
    ...         'ICOM_5G/DlData_SlotTypeReq\t0x00000001\t2\tffff1010000000000000ffffffff' -c
    ${nb_pwr-on}      Run      ${cmd}
    Should Be True      ${nb_pwr-on} > 0

    #${nb_slot}      Run      cat ${logs_path}/pcapprocessed.txt | grep -E 'ICOM_5G/DlData_SlotTypeReq,0x00000001,0x00000002' -c
    #${nb_slot}      Run      cat ${logs_path}/pcapprocessed.txt | grep -E 'ICOM_5G/DlData_SlotTypeReq,0x00000005,0x00000002' -c
    ${nb_slot}      Run      cat ${logs_path}/pcapprocessed_003_step1.txt | grep -P 'ICOM_5G/DlData_SlotTypeReq\t0x00000001\t2\t' -c

    Should be equal as integers      ${nb_pwr-on}       ${nb_slot}

    #Check that the power is reduced by 0xFF on slot 3 and slot5 (slotype 2)
    ${cmd}    catenate      cat ${logs_path}/pcapprocessed_003_step2.txt | grep -P
    ...         'ICOM_5G/DlData_SlotTypeReq\t(0x00000003|0x00000005)\t2\tffffffffffffffffffffffffff00' -c
    ${nb_pwr-on}      Run      ${cmd}
    Should Be True      ${nb_pwr-on} > 0

    ${nb_slot}      Run      cat ${logs_path}/pcapprocessed_003_step2.txt | grep -P 'ICOM_5G/DlData_SlotTypeReq\t(0x00000003|0x00000005)\t2\t' -c

    Should be equal as integers      ${nb_pwr-on}       ${nb_slot}

    #Check that the power is reduced by 0xFF on slot 7 (slotype 2)
    ${cmd}    catenate      cat ${logs_path}/pcapprocessed_003_step2.txt | grep -P
    ...         'ICOM_5G/DlData_SlotTypeReq\t(0x00000007)\t2\tffff0000ffffffffffffffffffff' -c
    ${nb_pwr-on}      Run      ${cmd}
    Should Be True      ${nb_pwr-on} > 0

    ${nb_slot}      Run      cat ${logs_path}/pcapprocessed_003_step2.txt | grep -P 'ICOM_5G/DlData_SlotTypeReq\t(0x00000007)\t2\t' -c

    Should be equal as integers      ${nb_pwr-on}       ${nb_slot}

    #Check that the power is reduced by 0xFF on slot 11 and 13 (slotype 2)
    ${cmd}    catenate      cat ${logs_path}/pcapprocessed_003_step2.txt | grep -P
    ...         'ICOM_5G/DlData_SlotTypeReq\t(0x0000000b|0x0000000d)\t2\tffff0000ffffffffffffffffffff' -c
    ${nb_pwr-on}      Run      ${cmd}
    Should Be True      ${nb_pwr-on} > 0

    ${nb_slot}      Run      cat ${logs_path}/pcapprocessed_003_step2.txt | grep -P 'ICOM_5G/DlData_SlotTypeReq\t(0x0000000b|0x0000000d)\t2\t' -c

    Should be equal as integers      ${nb_pwr-on}       ${nb_slot}

    #Check that the power is reduced by 0xFF on slot 15 and 17 (slotype 2)
    ${cmd}    catenate      cat ${logs_path}/pcapprocessed_003_step2.txt | grep -P
    ...         'ICOM_5G/DlData_SlotTypeReq\t(0x0000000f|0x00000011)\t2\tffff0000ffffffffffffffffffff' -c
    ${nb_pwr-on}      Run      ${cmd}
    Should Be True      ${nb_pwr-on} > 0

    ${nb_slot}      Run      cat ${logs_path}/pcapprocessed_003_step2.txt | grep -P 'ICOM_5G/DlData_SlotTypeReq\t(0x0000000f|0x00000011)\t2\t' -c

    Should be equal as integers      ${nb_pwr-on}       ${nb_slot}


