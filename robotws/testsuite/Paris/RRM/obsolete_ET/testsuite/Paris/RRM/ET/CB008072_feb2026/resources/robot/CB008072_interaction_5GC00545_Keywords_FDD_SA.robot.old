*** Settings ***
Documentation     [PURPOSE] Set of keywords used for CB008072 feature tests cases
...
...               Automation author           : bernard.hoche@nokia.com
...               Automation contact          : bernard.hoche@nokia.com
...               Creation Date               : 05-June-2019
...               Modified Date               : 05-June-2019
...               Last Modified by            : bernard.hoche@nokia.com
...               Last Modified by            : martial.hummel@nokia.com marie-laurence.le_borgne@nokia.com: adapt to CB006062
...               Last Modified by            : martial.hummel@nokia.com marie-laurence.le_borgne@nokia.com: adapt to CB007782
...               Last Modified by            : martial.hummel@nokia.com marie-laurence.le_borgne@nokia.com: adapt to CB008072 with 5GC00545
...               Last Modified by            : martial.hummel@nokia.com marie-laurence.le_borgne@nokia.com: adapt to AP_LO
...               Last Modified by            : The way to trigger BLER UL depends of AP Topology (AP_KL or AP_LO)
...               Last Modified by            : KW Suite Setup DFT_s_OFDM / Decrease SINR TO Trigger TransformPrecoder Enabled/ are changed



Resource          ../../../../../resources/SWENG/robot/Tools.robot
Resource          ../../../../../resources/SWENG/robot/SetConfig.robot
Resource          ../../../../../resources/SWENG/robot/WtsCfgConfig.robot

Library           taf.config.scf                WITH NAME      scf
Library           Collections
Library           ute_fsmaccess
Library           taf.wts.runner                WITH NAME      wtsemu


*** Variables ***

# Configure the threshold to trigger transform Precoder Disabled to Transform Precoder Enabled as 5 in gNB swconfig.txt
${RAD_SWITCH_PRECODER_OFF_TO_ON}        0x580376
${THRESHOLD_ENABLING_TRANSCODER}        0x5
# Configure the threshold to trigger transform Precoder Enabled to Transform Precoder Disabled as 2 in gNB swconfig.txt
${RAD_SWITCH_PRECODER_ON_TO_OFF}        0x580377
${THRESHOLD_DISABLING_TRANSCODER}       0x2

# Variables for setting L1 BLER in AP ABIL
${AP_ASIK_IP}                192.168.200.1
${AP_ASIK_LONER_IP}          192.168.253.86
${CONF_FILE_LONER_DIR}       /etc/5g-layer-1
${CONF_FILE_MASTER_DIR}      /ffs/run/boardcfg/1/C/mcu-aspa/boot

# Variables for setting L1 BLER in AP ABIO
${ABIO_cell_noise}           -500

# Variables for setting Pathloss in AP ABIO
${ABIO_pathloss}           120

# Variables for setting ue_id
# Be carefull even if this is a NSA call ue_id has to be set to 1 (Not 11 as expected in the basic_wts_step2.cfg)
# Because in the basic_wts_step2.lua (located under /opt/iphy/latest) ue_id=11 is renamed ue_id=1
# Also you can notice that in the egate_console.log file, all the egate commands are called with ue_id=1 (even for a NSA call)
${ue_Id}                     1

*** Keywords ***

Suite Setup DFT_s_OFDM
	CB008072_Keywords_common.Suite Setup 8072
	${ue_capu_type}       set variable     ${AP_DU.bb[0].M.boardType}
    Set Suite Variable    ${ue_capu_type}
    ${console_msg}        Evaluate     "The Board Type used on Arrphone is ${ue_capu_type}"
    Dated Log             ${console_msg}
    Run keyword if    '${ue_capu_type}' == 'ABIL'
	...    Run Keywords
	...    Add Noise To AP L1

#=======================================================================================================================
# KW to set some parameters in SCF
#=======================================================================================================================

Set Parameters on SCF_COAM_FDD
   [Documentation]                 Set ChBw and eventual PuschType and XDMRSAdditionalPosition upon dir parameter
    ...                             dir should be one of 'UL', 'DL', 'UL_DL' or 'None'
    [Arguments]                     ${puschMappingType_value}=${param.puschMappingType}
    ...                             ${dmrsTypeAPosition_value}=${param.dmrsTypeAPosition}
    ...                             ${actUlDataDmrsFdm_value}=${param.actUlDataDmrsFdm}
    ...                             ${ulDataDmrsFdmThres64QamMcs_value}=${param.ulDataDmrsFdmThres64QamMcs}
    ...                             ${ulDMRSAdditionalPosition_value}=${param.ulDMRSAdditionalPosition}
    ...                             ${actUlDftSOfdm_value}=${param.actUlDftSOfdm}
    ...                             ${ulTransPrecodeOffSinrThresh_value}=${param.ulTransPrecodeOffSinrThresh}
    ...                             ${ulTransPrecodeOnSinrThresh_value}=${param.ulTransPrecodeOnSinrThresh}
    ...                             ${ulTransPrecodeOffSinrThrRedCap_value}=${param.ulTransPrecodeOffSinrThrRedCap}
    ...                             ${ulTransPrecodeOnSinrThrRedCap_value}=${param.ulTransPrecodeOnSinrThrRedCap}

    SCF Set element                 dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}      element_name=actInactDetNSAUe
    ...                             element_value=false
    FOR    ${i}     IN RANGE    1    3
           ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${i}

           SCF Set element                 dist_name=${dn}      element_name=puschMappingType
           ...                             element_value=${puschMappingType_value}

           SCF Set element                 dist_name=${dn}      element_name=dmrsTypeAPosition
           ...                             element_value=${dmrsTypeAPosition_value}

           SCF Set element                 dist_name=${dn}      element_name=actUlDataDmrsFdm
           ...                             element_value=${actUlDataDmrsFdm_value}

           SCF Set element                 dist_name=${dn}      element_name=ulDataDmrsFdmThres64QamMcs
           ...                             element_value=${ulDataDmrsFdmThres64QamMcs_value}

           SCF Set element                 dist_name=${dn}      element_name=ulDMRSAdditionalPosition
           ...                             element_value=${ulDMRSAdditionalPosition_value}

           SCF Set element                 dist_name=${dn}      element_name=actUlDftSOfdm
           ...                             element_value=${actUlDftSOfdm_value}

           SCF Set element                 dist_name=${dn}      element_name=ulTransPrecodeOffSinrThresh
           ...                             element_value=${ulTransPrecodeOffSinrThresh_value}

           SCF Set element                 dist_name=${dn}      element_name=ulTransPrecodeOnSinrThresh
           ...                             element_value=${ulTransPrecodeOnSinrThresh_value}

           SCF Set element                 dist_name=${dn}      element_name=ulTransPrecodeOffSinrThrRedCap
           ...                             element_value=${ulTransPrecodeOffSinrThrRedCap_value}

           SCF Set element                 dist_name=${dn}      element_name=ulTransPrecodeOnSinrThrRedCap
           ...                             element_value=${ulTransPrecodeOnSinrThrRedCap_value}

           ${console_msg}                  Evaluate     "Database Modifications completed for NRCELL-${i}"
           Dated Log                       ${console_msg}
    END


Set Context FDD
    [Tags]                          SETUP
    Copy File                       ${SCF_SETUP_PATH}     ${SCF_SETUP_PATH}.ori
    ${scf_file_name}                Fetch from right      ${SCF_SETUP_PATH}      /
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${scf_name_for_update}            catenate    SEPARATOR=${EMPTY}    ${file_name_without_extention}
    ...                               _8072_FDD.xml
    ${scf_file_update_path}          set variable    ${LOG_PATH}/${scf_name_for_update}
    SCF StartSession                scf_file=${SCF_SETUP_PATH}
    ${modify_param}                 Set Parameters on SCF_COAM_FDD
    Dated log                       ${modify_param}
    SCF StopSession                 scf_file=${scf_file_update_path}

    ${TestName}                     getFormattedName
    Copy File                       ${LOG_PATH}/${scf_name_for_update}     ${LOG_PATH}/${TestName}.xml

    Update gNB swconfig file
    OAM Perform Full Commissioning  scf_file=${scf_file_update_path}
    Airscale Wait for Ready         ${GNB_DU}

Update gNB swconfig file
    ${precoder_on_threshold}=        Create dictionary    field=${RAD_SWITCH_PRECODER_OFF_TO_ON}    value=${THRESHOLD_ENABLING_TRANSCODER}
    ${precoder_off_threshold}=       Create dictionary    field=${RAD_SWITCH_PRECODER_ON_TO_OFF}    value=${THRESHOLD_DISABLING_TRANSCODER}
    ${param_list_rad_param}=         Create List                    ${precoder_on_threshold}                ${precoder_off_threshold}
    ${console_msg}                   Evaluate     "Updating RAD params on gNB ${precoder_on_threshold}"
    Dated Log                        ${console_msg}
    ${console_msg}                   Evaluate     "Updating RAD params on gNB ${precoder_off_threshold}"
    Dated Log                        ${console_msg}
    Set Fields in swconfig DU        param_list=${param_list_rad_param}

Add Noise To AP L1
    Log                                ${output_dir}
    ${local_save_path}                 Get Const Customizer From AP    ${output_dir}
    ${console_msg}                     Evaluate     "Get const_customizer.conf From AP and copy it in ${output_dir}"
    Dated Log                          ${console_msg}
    Modify AP L1 Noise                 ${local_save_path}
    ${console_msg}                     Evaluate     "Modified const_customizer.conf file available in ${output_dir}"
    Dated Log                          ${console_msg}
    Send AP L1 New Noise File To AP    ${local_save_path}
    ${console_msg}                     Evaluate     "Sending and crasigning L1 New Noise File To AP in Master Abil ${CONF_FILE_MASTER_DIR}"
    Dated Log                          ${console_msg}

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

Decrease SINR TO Trigger TransformPrecoder Enabled on AP ABIL
    [Documentation]             This KW is used to decrease AP sinr_pusch step by step
    ...                         Each step is decreasing ul_sinr by -5dB
    ...                         Starting  from -50 dB ....-100 dB .....-150 dB.....until -300dB (6 steps)
    ...                         Each step has a duration of 15 seconds
    [Arguments]    ${max_num_pusch_down}=6
    ${pusch_power} =    Set Variable    0
    FOR    ${index_time}    IN RANGE    1    ${max_num_pusch_down}+1
        ${pusch_power} =    Evaluate    ${pusch_power}-50
        Adjust Sinr Target Pusch Step By Step       ${ue_id}         ${pusch_power}
        ${console_msg}              Evaluate     "sinr_target_pusch decreased ${pusch_power} dB"
        Dated Log                   ${console_msg}
        Sleep    5s
    END
    wtsemu.ue_disp            id=${ue_id}
    Dated Log                        --->Decrease SINR TO Trigger TransformPrecoder Enabled on AP ABIL\n

Adjust Sinr Target Pusch Step By Step
    [Documentation]             This KW is used to send a command to WTS in order to decrease AP sinr_pusch
    ...                         until triggering TransformPrecoder enabled
    ...                         Testmode ul_sinr is activated for this purpose.
    ...                         Once ul_sinr is 'THRESHOLD_ENABLING_TRANSCODER' times consecutive lower than
    ...                         the threshold 'ulTransPrecodeOnSinrThresh'..... TransformPrecoder is enabled at gNB.
    [Arguments]    ${ue_id}=11    ${sinr_target_pusch}=-10
    wtsemu.ul_sinr_testmode_nr             profile_id=1             sinr_target_pusch=${sinr_target_pusch}
    wtsemu.ue_testmode_set_nr              id=${ue_id}             testmode=ul_sinr            action=activate            profile_id=1
    wtsemu.ul_sinr_testmode_nr             profile_id=1

Add static cell noise at Airphone ABIO
    [Documentation]             This KW is used to generate cell noise at Airphone ABIO through a WTS command
    ...                         For AP ABIO, no more need to modify const_customizer.conf file at AP
    ...                         This Test mode will generate noise for Pusch Pucch Srs and Prach
    ...                         leading to decrease ul_sinr
    ...                         Once ul_sinr is 'THRESHOLD_ENABLING_TRANSCODER' times consecutive lower than
    ...                         the threshold 'ulTransPrecodeOnSinrThresh'..... TransformPrecoder is enabled at gNB.
    [Arguments]    ${noise}=${ABIO_cell_noise}    ${gnb}=2    ${cell_id}=all    ${profile_id}=1
    wtsemu.ul_cell_noise_testmode_nr    profile_id=${profile_id}    noise_pusch=${noise}    noise_pucch=${noise}
    ...    noise_prach=${noise}    noise_srs=${noise}
    ${console_msg1}        Evaluate     "sending egate command --> ul_cell_noise_testmode_nr profile_id=${profile_id}"
    ${console_msg2}        Evaluate     "noise_pusch=${noise} noise_pucch=${noise} noise_prach=${noise} noise_srs=${noise}"
    ${console_msg}         Catenate     ${console_msg1}    ${console_msg2}
    Dated Log             ${console_msg}
    Sleep                 5s
    wtsemu.cell_testmode_set_nr    gnb=${gnb}    cell_id=${cell_id}    testmode=ul_cell_noise    profile_id=${profile_id}    action=activate
    ${console_msg1}        Evaluate     "sending egate command --> cell_testmode_set_nr gnb=${gnb} cell_id=${cell_id}"
    ${console_msg2}        Evaluate     "testmode=ul_cell_noise profile_id=${profile_id} action=activate"
    ${console_msg}         Catenate     ${console_msg1}    ${console_msg2}
    Dated Log             ${console_msg}
    Sleep                 5s

Add PathLoss at Airphone ABIO
    [Documentation]             This KW is used to generate cell noise at Airphone ABIO through a WTS command
    ...                         For AP ABIO, no more need to modify const_customizer.conf file at AP
    ...                         This Test mode will generate noise for Pusch Pucch Srs and Prach
    ...                         leading to decrease ul_sinr
    ...                         Once ul_sinr is 'THRESHOLD_ENABLING_TRANSCODER' times consecutive lower than
    ...                         the threshold 'ulTransPrecodeOnSinrThresh'..... TransformPrecoder is enabled at gNB.
    [Arguments]    ${pathloss}=${ABIO_pathloss}    ${profile_id}=1    ${ue_id}=1
    wtsemu.ul_sinr_testmode_nr    profile_id=${profile_id}    pathloss=${pathloss}
    ${console_msg1}        Evaluate     "sending egate command --> ul_sinr_testmode_nr profile_id=${profile_id}"
    ${console_msg2}        Evaluate     "pathloss=${ABIO_pathloss}"
    ${console_msg}         Catenate     ${console_msg1}    ${console_msg2}
    Dated Log             ${console_msg}
    Sleep                 5s
    wtsemu.ue_testmode_set_nr    id=${ue_id}    testmode=ul_sinr   action=activate    profile_id=${profile_id}
    ${console_msg1}        Evaluate     "sending egate command --> ue_testmode_set_nr id=${ue_id}"
    ${console_msg2}        Evaluate     "testmode=ul_sinr action=activate profile_id=${profile_id}"
    ${console_msg}         Catenate     ${console_msg1}    ${console_msg2}
    Dated Log             ${console_msg}
    Sleep                 5s

Decrease SINR TO Trigger TransformPrecoder Enabled
    [Documentation]             Regarding AP Topology (ABIL or ABIO)
    ...                         This KW switches to the method for generating UL cell noise on AP
    #[Arguments]    ${TargetedNoise}=-500     ${TargetedPathLoss}=120
    [Arguments]     ${TargetedPathLoss}=120
    Run keyword if    '${ue_capu_type}' == 'ABIO'
    #...    Run Keywords
    #...    Add static cell noise at Airphone ABIO    noise=${TargetedNoise}
    #...    AND
    ...    Run Keyword
    ...    Add PathLoss at Airphone ABIO    pathloss=${TargetedPathLoss}
    Run keyword if    '${ue_capu_type}' == 'ABIL'
    ...    Run Keyword
    ...    Decrease SINR TO Trigger TransformPrecoder Enabled on AP ABIL
    ...    ELSE
    ...    Dated Log            UL NOISE will not be generated AP modem is neither an ABIL nor an ABIO
