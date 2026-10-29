*** Settings ***
Library    ute_fsmaccess

Documentation
...    author: Masztalerz Adam
...    description: CB007813 common keywords

*** Variables ***
${AP_ASIK_IP}                192.168.200.1
${AP_ASIK_LONER_IP}          192.168.253.86
${CONF_FILE_LONER_DIR}       /etc/5g-layer-1
${CONF_FILE_MASTER_DIR}      /ffs/run/boardcfg/1/C/mcu-aspa/boot
${MAX_WAITTIME_TP_ENABLE}    12s

*** Keywords ***
Add Noise To AP L1
    Log    ${output_dir}
    ${local_save_path}    Get Const Customizer From AP    ${output_dir}
    Modify AP L1 Noise    ${local_save_path}
    Send AP L1 New Noise File To AP    ${local_save_path}

Get Const Customizer From AP
    [Arguments]    ${save_dir}
    ute_fsmaccess.Setup Wts Fsm Access
    Log    Copy AP loner const_customizer.conf to master
    ute_fsmaccess.Execute Command On Wts    scp toor4nsn@${AP_ASIK_LONER_IP}:${CONF_FILE_LONER_DIR}/const_customizer.conf ${CONF_FILE_MASTER_DIR}
    ute_fsmaccess.Execute Command On Wts    ls -l ${CONF_FILE_MASTER_DIR} | grep const_customizer.conf
    OperatingSystem.Run
    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@${AP_ASIK_IP}:${CONF_FILE_MASTER_DIR}/const_customizer.conf ${save_dir}/const_customizer.conf
    OperatingSystem.Should Exist    ${save_dir}/const_customizer.conf
    ${path}    Set Variable    ${save_dir}/const_customizer.conf
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access
    [Return]    ${path}

Modify AP L1 Noise
    [Arguments]    ${path}
    Log    Update tx_noise_gen_en_ant0/tx_noise_gen_en_ant1/tx_noise_gen_en_ant2/tx_noise_gen_en_ant3's value to 1
    FOR    ${index}    IN RANGE    0    4
        ${content} =    OperatingSystem.Get File    path=${path}
        ${noise_regexp} =    Set Variable    tx_noise_gen_en_ant${index} = (?P<noise_old>\\d)
        ${replace_noise_with} =    Set Variable    tx_noise_gen_en_ant${index} = 1
        ${new_content} =    String.Replace String Using Regexp
    ...    string=${content}
    ...    pattern=${noise_regexp}
    ...    replace_with=${replace_noise_with}
        OperatingSystem.Create File    path=${path}    content=${new_content}
    END

Send AP L1 New Noise File To AP
    [Arguments]    ${path}
    Log    Send new noise file to AP master and sign for it.
    OperatingSystem.Run
    ...    sshpass -p oZPS0POrRieRtu scp ${path} toor4nsn@${AP_ASIK_IP}:/ffs/run/boardcfg/1/C/mcu-aspa/boot/const_customizer.conf
    ${crasign_cmd}    Set Variable    crasign /ffs/run/boardcfg/1/C/mcu-aspa/boot/const_customizer.conf
    ${craverify_cmd}    Set Variable    craverify /ffs/run/boardcfg/1/C/mcu-aspa/boot/const_customizer.conf*
    OperatingSystem.Run
    ...    sshpass -p oZPS0POrRieRtu ssh toor4nsn@${AP_ASIK_IP} ${crasign_cmd}
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p oZPS0POrRieRtu ssh toor4nsn@${AP_ASIK_IP} ${craverify_cmd}
    Should Be Equal As Integers    ${rc}    0
