*** Settings ***
Documentation    Keywords for gNB swconfig or SCF management
...              last updates :
...                     24.06.2021    Annie Wong


Library          taf.transport.ssh           WITH NAME       ssh
Library          taf.config.scf                 WITH NAME    scf
#--deprécated : taf.gnb.oam coam.admin                     WITH NAME     admin
Library          taf.sbts.oam.coam.admin                    WITH NAME     admin
Library          ../../swconfig_handler.py        WITH NAME     swconf
Resource         Keywords_gNB.robot


*** Keywords ***
Create Session with alias
    [Arguments]         ${gnb_id}=0     ${alias}=oam_session
    [Documentation]  Connect to Node B.
    ...     gnb_id:  BTS gnb id in Testline configuration i.e ${tl.gnbs[]}
    ...     alias:   AdminConnection object or if used, string name alias
    ...     Release  session before creation to avoid multiple session open
    Teardown Session with alias       alias=${alias}
    oam.create_session          base_url=${GN_WEBUI[${gnb_id}]}
    ...                         alias=${alias}


Teardown Session with alias
    [Arguments]         ${alias}=oam_session
    [Documentation]  Disconnects and destroy node.js daemon
    ...     alias:   AdminConnection object or if used, string name alias
    run keyword and ignore error        oam.teardown_session        session=${alias}


Archive ORI SCF
    [Arguments]                 ${gNB}=0
    Create Session with alias        gnb_id=${gNB}    alias=oam_session
    oam.get_current_scf_file    local_dir_path=${LOCAL_SCF_DIR_PATH}
    ...                         file_name=${ORIG_SCF_FILE_NAME[${gNB}]}
    ...                         session=oam_session
    ...                         timeout=60
    oam.teardown_session        session=oam_session


Archive ORI Swconfig
    [Documentation]             Backup ori swconfig.txt file so that it can be restored at the end of the suite
    [Arguments]                 ${gNB}=0
    ${asik_cnx}                 ssh.connect_to       ${ASIK_ADDR[${gNB}]}
    ...                                              ${ASIK_USERNAME[${gNB}]}
    ...                                              ${ASIK_PASSWORD[${gNB}]}
    ...                                              alias=asik_als
    swconf.backup_swconfig      ${asik_cnx}     /ffs/run/swconfig.txt    ${ORIG_SWCONFIG[${gNB}]}
    ssh.disconnect              connection=${asik_cnx}


Backup initial SCF
    [Documentation]             Backup initial SCF so that it can be restored at the end of the test
    [Arguments]                 ${gNB}=0
    # Get current scf file
    Log              backup file: ${BACKUP_SCF_FULLNAME[${gNB}]}
    Remove File                 ${BACKUP_SCF_FULLNAME[${gNB}]}
    Remove File                 ${LOCAL_SCF_FULLNAME}
    oam.create_session          base_url=${GN_WEBUI[${gNB}]}
    ...                         alias=oam_session
    oam.get_current_scf_file    local_dir_path=${LOCAL_SCF_PATH}
    ...                         file_name=${LOCAL_SCF_NAME}
    ...                         session=oam_session
    ...                         timeout=60
    oam.teardown_session        session=oam_session

    # Load the current scf file into memory
    scf.load_scf                ${LOCAL_SCF_FULLNAME}

    # Copy the current scf file into the backup
    Copy file                   ${LOCAL_SCF_FULLNAME}       ${BACKUP_SCF_FULLNAME[${gNB}]}

    # Check the backup
    File should exist           ${BACKUP_SCF_FULLNAME[${gNB}]}
    ${current_value}            scf.get_value_from_scf      p_name=btsName
    Set Suite Variable          ${BACKUP_VALUE}             ${current_value}


Restore initial SCF
    [Documentation]             Restore initial SCF that was backup at the beginning of the test
    [Arguments]                 ${gNB}=0
    # Validate and commission the backup file
    Do Commissioning            ${BACKUP_SCF_FULLNAME[${gNB}]}       ${gNB}


Backup Initial Swconfig
    [Documentation]             Backup initial swconfig.txt file so that it can be restored at the end of the test
    [Arguments]                 ${gNB}=0
    ${asik_cnx}                 ssh.connect_to       ${ASIK_ADDR[${gNB}]}
    ...                                              ${ASIK_USERNAME[${gNB}]}
    ...                                              ${ASIK_PASSWORD[${gNB}]}
    ...                                              alias=asik_als
    # Download the current swconfig.txt file
    swconf.backup_swconfig      ${asik_cnx}     /ffs/run/swconfig.txt      ${BACKUP_SWC_FULLNAME[${gNB}]}
    ssh.disconnect              connection=${asik_cnx}


Restore Initial Swconfig
    [Documentation]             Restore initial swconfig.txt file that was backup at the beginning of the test
    [Arguments]                 ${gNB}=0
    ${asik_cnx}                 ssh.connect_to       ${ASIK_ADDR[${gNB}]}
    ...                                              ${ASIK_USERNAME[${gNB}]}
    ...                                              ${ASIK_PASSWORD[${gNB}]}
    ...                                              alias=asik_als
    swconf.set_swconfig         ${asik_cnx}       ${BACKUP_SWC_FULLNAME[${gNB}]}      /ffs/run/swconfig.txt
    ssh.disconnect              connection=${asik_cnx}


Set Swconfig
    [Documentation]             Download a swconfig.txt file to the ASIK master
    [Arguments]                 ${swconf_name}
    ...                         ${gNB}=0
    ${asik_cnx}                 ssh.connect_to       ${ASIK_ADDR[${gNB}]}
    ...                                              ${ASIK_USERNAME[${gNB}]}
    ...                                              ${ASIK_PASSWORD[${gNB}]}
    ...                                              alias=asik_als
    ${reset_needed}             swconf.set_swconfig         ${asik_cnx}     ${swconf_name}      /ffs/run/swconfig.txt
    ssh.disconnect              connection=${asik_cnx}
    Run Keyword If		        '${reset_needed}' == '1'
    ...                         Reset Site and Check Cell   ${gNB}


Do Commissioning
    [Documentation]             Perform the commissioning and wait the OAM is ready
    [Arguments]                 ${new_scf_file}         ${gNB}=0
    Log                       Perform the commissioning of gNB ${gNB}
    ## as the session may have expired, we shall reopen it
    run keyword and ignore error        oam.teardown_session      session=oam_session
    ##old: oam.create_session    base_url=${GN_WEBUI[${gNB}]}   alias=oam_session
    oam.create_session          base_url=${tl.gnbs[${gNB}].cu.oam_http_connection_details.addr}
    ...                         alias=oam_session
    # change timeout=360 instead of 300
    admin.perform_commissioning
    ...    scf_file=${new_scf_file}
    ...    skip_parameter_relation_errors=${True}
    ...    timeout=360
    ...    connection=oam_session
    Log        Wait 5mn to be sure the OAM is restarted       console=${DEBUG_MODE_CONSOLE}
    sleep                       300s     Wait some time to be sure the OAM VM is restarted
    Keywords_gNB.Check gNB State             ${gNB}
    [Teardown]    run keyword and ignore error     oam.teardown_session      session=oam_session

#exple method : Do AES Security Commissioning    current_scf_fullname=${ORIG_SCF[${gNB}]}    gNB=${gNB}
#                 ....                                nea0=1     nea1_128=3    nea2_128=4     nea3_128=2
#       ou      Do AES Security Commissioning   current_scf_fullname=${BACKUP_SCF_FULLNAME[${gNB}]}    gNB=${gNB}
#                 ....                                nea0=1     nea1_128=3    nea2_128=4     nea3_128=2
Do AES Security Commissioning
    [Documentation]             Perform the AES Security commissioning and wait the OAM is ready
    [Arguments]                 ${current_scf_fullname}         ${gNB}=0
    ...                         ${nea0}=1     ${nea1_128}=3    ${nea2_128}=4     ${nea3_128}=2
    scf.load_scf               ${current_scf_fullname}
    #Set the parameter to activate the AES security
    scf.modify_scf_element      value=${nea0}
    ...                         p_name=nea0
    ...                         dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}
    ...                         list_name=cipherPrefL
    scf.modify_scf_element      value=${nea1_128}
    ...                         p_name=nea1_128
    ...                         dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}
    ...                         list_name=cipherPrefL
    scf.modify_scf_element      value=${nea2_128}
    ...                         p_name=nea2_128
    ...                         dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}
    ...                         list_name=cipherPrefL
    scf.modify_scf_element      value=${nea3_128}
    ...                         p_name=nea3_128
    ...                         dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}
    ...                         list_name=cipherPrefL
    Remove File                 ${LOCAL_SCF_FULLNAME}
    scf.save_scf                ${LOCAL_SCF_FULLNAME}
    #${local_scf_test}           Join Path   ${OUTPUT DIR}   ${SUITE NAME}   ${TEST NAME}    scf_AES_precondition.xml
    ${local_scf_test}           Join Path   ${OUTPUT DIR}   ${SUITE NAME}   scf_AES_Commissioning_gnb${gNB}.xml
    Copy file                   ${LOCAL_SCF_FULLNAME}       ${local_scf_test}
    log                         Save a copy of the modified scf=${local_scf_test}   console=${True}
    #Perform the commissioning
    Do Commissioning            ${LOCAL_SCF_FULLNAME}    ${gNB}


Verify SCF AES Cipher
    [Arguments]                 ${current_scf_fullname}      ${gNB}=0
    ...                         ${nea0}=1     ${nea1_128}=3    ${nea2_128}=4     ${nea3_128}=2
    #${current_scf_fullname}      set variable         ${LOCAL_TEMPLATE_DIR_PATH}/${ORIG_SCF_FILE_NAME}
    scf.load_scf	 ${current_scf_fullname}

    ${new_value}	 scf.get_value_from_scf   p_name=nea0
    ...          dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}
    ...          list_name=cipherPrefL
    run keyword and continue on failure    Should Be Equal As Strings    ${new_value}    ${nea0}    ignore_case=True

    ${new_value}     scf.get_value_from_scf   p_name=nea1_128
    ...          dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}
    ...          list_name=cipherPrefL
    run keyword and continue on failure    Should Be Equal As Strings    ${new_value}   ${nea1_128}   ignore_case=True

    ${new_value}     scf.get_value_from_scf   p_name=nea2_128
    ...           dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}
    ...           list_name=cipherPrefL
    run keyword and continue on failure    Should Be Equal As Strings   ${new_value}    ${nea2_128}   ignore_case=True

    ${new_value}     scf.get_value_from_scf   p_name=nea3_128
    ...           dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}
    ...           list_name=cipherPrefL
    Should Be Equal As Strings    ${new_value}    ${nea3_128}    ignore_case=True


Recommission actEnhancedLinkAdaptation
    [Arguments]         ${value}=False     ${should_activate}=True       ${gNB}=0     ${connection}=coam_admin
    # Keywords_gNB.Create cOAM Session with alias    gnb_id=${gNB}   alias=coam_admin
    # set the DST_NAME
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
	...      parameter=actEnhancedLinkAdaptation
	...      operation=update
	...      value=${value}
	...      skip_parameter_relation_errors=True
	...      should_activate=${should_activate}
	...      connection=${connection}
    sleep		  2s
    # Keywords_gNB.Teardown cOAM Session with alias    alias=coam_admin


Recomission ullaDeltaSinrMax
    [Arguments]        ${value}=30     ${should_activate}=True     ${gNB}=0    ${cell_id}=1    ${connection}=coam_admin
    ${name}=      set variable   MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell_id}
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
	...      parameter=ullaDeltaSinrMax
	...      operation=update
	...      value=${value}
	...      skip_parameter_relation_errors=True
	...      should_activate=${should_activate}
	...      connection=${connection}
    sleep		  2s


Recomission ullaDeltaSinrStepDown
    [Arguments]       ${value}=20     ${should_activate}=True     ${gNB}=0    ${cell_id}=1     ${connection}=coam_admin
    ${name}=      set variable   MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell_id}
    admin.perform_parameter_recommissioning
	...      dist_name=${name}
	...      parameter=ullaDeltaSinrStepdown
	...      operation=update
	...      value=${value}
	...      skip_parameter_relation_errors=True
	...      should_activate=${should_activate}
	...      connection=${connection}
    sleep		  2s


Recommission ullaIniMcs
    [Arguments]         ${value}=3      ${should_activate}=True     ${gNB}=0   ${cell_id}=1    ${connection}=coam_admin
    ${name}=      set variable   MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell_id}
    admin.perform_parameter_recommissioning
	...      dist_name=${name}
	...      parameter=ullaIniMcs
	...      operation=update
	...      value=${value}
	...      skip_parameter_relation_errors=True
	...      should_activate=${should_activate}
	...      connection=${connection}
    sleep		  2s


Recommission ullaBlerTarget
    [Arguments]         ${value}=10      ${should_activate}=True     ${gNB}=0   ${cell_id}=1    ${connection}=coam_admin
    ${name}=      set variable   MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell_id}
    admin.perform_parameter_recommissioning
	...      dist_name=${name}
	...      parameter=ullaBlerTarget
	...      operation=update
	...      value=${value}
	...      skip_parameter_relation_errors=True
	...      should_activate=${should_activate}
	...      connection=${connection}
    sleep		  2s


Recomission dllaDeltaCqiMax
    [Arguments]         ${value}=150    ${should_activate}=True     ${gNB}=0   ${cell_id}=1    ${connection}=coam_admin
    ${name}=      set variable   MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell_id}
    admin.perform_parameter_recommissioning
	...      dist_name=${name}
	...      parameter=dllaDeltaCqiMax
	...      operation=update
	...      value=${value}
	...      skip_parameter_relation_errors=True
	...      should_activate=${should_activate}
	...      connection=${connection}
    sleep		  2s


Recomission dllaDeltaCqiStepDown
    [Arguments]       ${value}=20     ${should_activate}=True    ${gNB}=0    ${cell_id}=1     ${connection}=coam_admin
    ${name}=      set variable   MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell_id}
    admin.perform_parameter_recommissioning
	...      dist_name=${name}
	...      parameter=dllaDeltaCqiStepdown
	...      operation=update
	...      value=${value}
	...      skip_parameter_relation_errors=True
	...      should_activate=${should_activate}
	...      connection=${connection}
    sleep		  2s


Recommission dllaIniMcs
    [Arguments]       ${value}=3    ${should_activate}=True   ${gNB}=0    ${cell_id}=1    ${connection}=coam_admin
    ${name}=      set variable   MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell_id}
    admin.perform_parameter_recommissioning
	...      dist_name=${name}
	...      parameter=dllaIniMcs
	...      operation=update
	...      value=${value}
	...      skip_parameter_relation_errors=True
	...      should_activate=${should_activate}
	...      connection=${connection}
    sleep		  2s


Recommission actGeneralConnectivitySilver
    [Arguments]         ${value}=true      ${gNB}=0     ${connection}=coam_admin        ${should_activate}=True
    # set the DST_NAME
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=actGeneralConnectivitySilver
    ...      operation=update
    ...      value=${value}
    ...      skip_parameter_relation_errors=True
    ...      should_activate=${should_activate}
    ...      connection=${connection}
    sleep                 2s


Recommission actDl256Qam
    [Arguments]         ${value}=true     ${cell}=1     ${gNB}=0    ${connection}=coam_admin    ${should_activate}=True
    # set the DST_NAME
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell}
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=actDl256Qam
    ...      operation=update
    ...      value=${value}
    ...      skip_parameter_relation_errors=True
    ...      should_activate=${should_activate}
    ...      connection=${connection}
    sleep                 2s


Activate Frame 3 7
    [Documentation]             Perform the Frame 3 7 commissioning and wait the OAM is ready
    [Arguments]                 ${current_scf_fullname}         ${gNB}=0
    ...                         ${prach_config}=98      ${guard_period}=2Symbols        ${ul_dl_ratio}=3/7
    ...                         ${nb_ssb}=2 beams       ${beam_set}=beamSet_2
    ...                         ${qam256}=true          ${dl_mimo}=2x2 Closed Loop Spatial Multiplexing
    ...                         ${mcs_dl}=3             ${mcs_ul}=0        ${cell}=1

    scf.load_scf               ${current_scf_fullname}
    #Set the parameters to activate the Frame 3 7
    scf.modify_scf_element      value=${prach_config}
    ...                         p_name=prachConfigurationIndex
    ...                         dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell}
    scf.modify_scf_element      value=semiStatic
    ...                         p_name=frameStructureType
    ...                         dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell}
    ...                         list_name=tddFrameStructure
    scf.modify_scf_element      value=${guard_period}
    ...                         p_name=guardPeriodLength
    ...                         dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell}
    ...                         list_name=tddFrameStructure
    scf.modify_scf_element      value=${ul_dl_ratio}
    ...                         p_name=ulDlDataSlotRatio
    ...                         dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell}
    ...                         list_name=tddFrameStructure
    scf.modify_scf_element      value=${nb_ssb}
    ...                         p_name=numberOfTransmittedSsBlocks
    ...                         dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELLGRP-0
    scf.modify_scf_element      value=20
    ...                         p_name=ssBurstSetPeriod
    ...                         dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELLGRP-0
    scf.modify_scf_element      value=true
    ...                         p_name=actBeamforming
    ...                         dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell}
    scf.modify_scf_element      value=${beam_set}
    ...                         p_name=basicBeamSet
    ...                         dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell}
    ...                         list_name=beamSet
    scf.modify_scf_element      value=${qam256}
    ...                         p_name=actDl256Qam
    ...                         dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell}

    # Run Keyword If  '${nb_ssb}' == '8 beams'   scf.modify_scf_element      value=20     p_name=leftEdgeAngle
    # ...                             dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1
    # ...                             list_name=beamSet
    # Run Keyword Unless   '${nb_ssb}' == '8 beams'   scf.modify_scf_element   value=60    p_name=leftEdgeAngle
    # ...                             dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1
    # ...                             list_name=beamSet
    # Run Keyword If   '${nb_ssb}' == '8 beams'   scf.modify_scf_element    value=20      p_name=rightEdgeAngle
    # ...                             dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1
    # ...                             list_name=beamSet
    # Run Keyword Unless   '${nb_ssb}' == '8 beams'   scf.modify_scf_element   value=60   p_name=rightEdgeAngle
    # ...                             dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1
    # ...                             list_name=beamSet

    scf.modify_scf_element      value=${dl_mimo}
    ...                         p_name=dlMimoMode
    ...                         dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell}
    scf.modify_scf_element      value=${mcs_dl}
    ...                         p_name=dllaIniMcs
    ...                         dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell}
    scf.modify_scf_element      value=${mcs_ul}
    ...                         p_name=ullaIniMcs
    ...                         dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell}
    Remove File                 ${LOCAL_SCF_FULLNAME}
    scf.save_scf                ${LOCAL_SCF_FULLNAME}
    ${local_scf_test}           Join Path   ${OUTPUT DIR}   ${SUITE NAME}   scf_Frame_3_7_gnb${gNB}.xml
    Copy file                   ${LOCAL_SCF_FULLNAME}       ${local_scf_test}
    log                         Save a copy of the modified scf=${local_scf_test}   console=${True}
    Do Commissioning            ${LOCAL_SCF_FULLNAME}    ${gNB}


Verify Frame 3 7
    [Arguments]                 ${current_scf_fullname}
    ...                         ${prach_config}=98      ${guard_period}=2Symbols        ${ul_dl_ratio}=3/7
    ...                         ${nb_ssb}=2 beams       ${beam_set}=beamSet_2
    ...                         ${qam256}=true          ${dl_mimo}=2x2 Closed Loop Spatial Multiplexing
    ...                         ${mcs_dl}=3       ${mcs_ul}=0    ${gNB}=0    ${cell}=1

    scf.load_scf	 ${current_scf_fullname}

    ${new_value}	 scf.get_value_from_scf   p_name=prachConfigurationIndex
    ...              dist_name=MRBTS-${MRBTS}/NRBTS-${NRBTS}/NRCELL-${cell}
    run keyword and continue on failure   Should Be Equal As Strings   ${new_value}   ${prach_config}   ignore_case=True
    ${new_value}	 scf.get_value_from_scf   p_name=frameStructureType
    ...              dist_name=MRBTS-${MRBTS}/NRBTS-${NRBTS}/NRCELL-${cell}   list_name=tddFrameStructure
    run keyword and continue on failure    Should Be Equal As Strings   ${new_value}    semiStatic    ignore_case=True
    ${new_value}	 scf.get_value_from_scf   p_name=guardPeriodLength
    ...              dist_name=MRBTS-${MRBTS}/NRBTS-${NRBTS}/NRCELL-${cell}   list_name=tddFrameStructure
    run keyword and continue on failure   Should Be Equal As Strings   ${new_value}   ${guard_period}   ignore_case=True
    ${new_value}	 scf.get_value_from_scf   p_name=ulDlDataSlotRatio
    ...              dist_name=MRBTS-${MRBTS}/NRBTS-${NRBTS}/NRCELL-${cell}   list_name=tddFrameStructure
    run keyword and continue on failure   Should Be Equal As Strings   ${new_value}   ${ul_dl_ratio}    ignore_case=True
    ${new_value}	 scf.get_value_from_scf   p_name=numberOfTransmittedSsBlocks
    ...              dist_name=MRBTS-${MRBTS}/NRBTS-${NRBTS}/NRCELLGRP-0
    run keyword and continue on failure    Should Be Equal As Strings    ${new_value}    ${nb_ssb}    ignore_case=True
    ${new_value}	 scf.get_value_from_scf   p_name=ssBurstSetPeriod
    ...              dist_name=MRBTS-${MRBTS}/NRBTS-${NRBTS}/NRCELLGRP-0
    run keyword and continue on failure    Should Be Equal As Strings    ${new_value}    20    ignore_case=True
    ${new_value}	 scf.get_value_from_scf   p_name=actBeamforming
    ...              dist_name=MRBTS-${MRBTS}/NRBTS-${NRBTS}/NRCELL-${cell}
    run keyword and continue on failure    Should Be Equal As Strings    ${new_value}    true    ignore_case=True
    ${new_value}	 scf.get_value_from_scf   p_name=basicBeamSet
    ...              dist_name=MRBTS-${MRBTS}/NRBTS-${NRBTS}/NRCELL-${cell}   list_name=beamSet
    run keyword and continue on failure    Should Be Equal As Strings    ${new_value}    ${beam_set}    ignore_case=True
    ${new_value}	 scf.get_value_from_scf   p_name=actDl256Qam
    ...              dist_name=MRBTS-${MRBTS}/NRBTS-${NRBTS}/NRCELL-${cell}
    run keyword and continue on failure    Should Be Equal As Strings    ${new_value}    ${qam256}    ignore_case=True
    ${new_value}	 scf.get_value_from_scf   p_name=dlMimoMode
    ...              dist_name=MRBTS-${MRBTS}/NRBTS-${NRBTS}/NRCELL-${cell}
    run keyword and continue on failure    Should Be Equal As Strings    ${new_value}    ${dl_mimo}    ignore_case=True
    ${new_value}	 scf.get_value_from_scf   p_name=dllaIniMcs
    ...              dist_name=MRBTS-${MRBTS}/NRBTS-${NRBTS}/NRCELL-${cell}
    run keyword and continue on failure    Should Be Equal As Strings    ${new_value}    ${mcs_dl}    ignore_case=True
    ${new_value}	 scf.get_value_from_scf   p_name=ullaIniMcs
    ...              dist_name=MRBTS-${MRBTS}/NRBTS-${NRBTS}/NRCELL-${cell}
	Should Be Equal As Strings    ${new_value}    ${mcs_ul}    ignore_case=True

    ${dlDMRS}	 scf.get_value_from_scf   p_name=dlDMRSAdditionalPosition
    ...              dist_name=MRBTS-${MRBTS}/NRBTS-${NRBTS}/NRCELL-${cell}
	set suite variable     ${dlDMRS}

    ${ulDMRS}	 scf.get_value_from_scf   p_name=ulDMRSAdditionalPosition
    ...              dist_name=MRBTS-${MRBTS}/NRBTS-${NRBTS}/NRCELL-${cell}
	set suite variable     ${ulDMRS}
