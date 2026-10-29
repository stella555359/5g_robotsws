*** Settings ***
Documentation   Suite description
Library         OperatingSystem
Library         Process
Library         Collections
Library         String
Library         DateTime
#Library         taf.gnb.oam.commissioning                   WITH NAME   cm
#Library         taf.transport.ssh                           WITH NAME   ssh
#Library         taf.gnb.oam.coam.admin                      WITH NAME   coam
#Library         taf.config.scf                              WITH NAME   scf
Library         Dialogs
Resource        ${CURDIR}/../logs.robot
Resource        ${CURDIR}/../interfaceCheck.robot
Resource        ${CURDIR}/../metascripts.robot

#Specific to feature
Resource        ${CURDIR}/5GC000511_E_NonReg_Resource.robot
Resource        ${CURDIR}/privateKW_RACH.robot
Variables       ${CURDIR}/mediation_RACH.yaml

*** Keywords ***
5GC000511_E_NonReg_Online
    [Documentation]
    ...          Author: Stephane Croquet
    [Teardown]  run keywords  privateKW_RACH.Teardown With All Traces AIO

    ...  get_full_logs=0  ext_mirroring=${ext_mirroring}  AND
    ...  run keyword if  '${band}'=='FR2'  Implicite Pass 511_E Online FR2

    Append To File   ${suite_dir}/result.txt   \n\n${TEST NAME}\n
    Append To File   ${suite_dir}/result.txt   ********************************************************************\n

    ${ext_mirroring}=   set variable    0

    set test variable  ${parameterToBeUpdated}  ${EMPTY}
    set test variable  ${parameterUpdated}  ${EMPTY}

#Check current values and target values
    Append To File   ${suite_dir}/result.txt   \nCheck current values and target values
    set test variable   ${currentValueStatus}          ${TRUE}
    configuration.save scf  current_scf_for_check.xml
    ${xml_root} =   XML.parse xml   ${scf_path}/current_scf_for_check.xml
    Run keyword if    '${rsrpThresholdSSB}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     rsrpThresholdSSB    ${rsrpThresholdSSB}
    Run keyword if    '${powerRampingStep}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     powerRampingStep    ${powerRampingStep}
    Run keyword if    '${preambleReceivedTargetPower}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     initialPreambleReceivedTargetPower   ${preambleReceivedTargetPower}
    Run keyword if    '${preambleTransMax}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     preambleTransMax    ${preambleTransMax}
    Run keyword if    '${raContentionResolutionTimer}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     raContentionResolutionTmr    ${raContentionResolutionTimer}
    Run keyword if    '${raResponseWindow}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     raResponseWindow    ${raResponseWindow}
    Run keyword if    '${msg3DeltaPreamble}' != '${EMPTY}'
    ...    privateKW_RACH.Check not equal with current value      ${xml_root}     msg3DeltaPreamble    ${msg3DeltaPreamble}

    run keyword if    ${currentValueStatus} == ${FALSE} and ${is_unitary_test} == ${TRUE}
    ...  Fail    Parameter is already set

    #run keyword unless  ${currentValueStatus}  run keywords
    run keyword if  ${currentValueStatus} == ${False}  run keywords
    ...  Append To File      ${suite_dir}/result.txt     \n\n\tSome paramter(s) already set      AND
    ...  run keyword and continue on failure   fail    Some paramter(s) already set

# Download gnbMirrorig scripts and configure them
# it is necessary to reset the DU to disable previous mirroring configuration before loading new one
    configuration.Site reset
    wait until keyword succeeds    10 min    30 sec    gnbStatus.Check Cell Availability Status V2
    configuration.create SSH
    configuration.create Connections

    # Download and configure mirroring scripts on system module board - ASIK or ASOD
    Run keyword if    '${system_module_type}' == 'ASIK'    Run keywords
    ...                               privateKW_RACH.Prepare Mirroring ASIK                AND
    ...                               logs.Update gnbMirroringConfig    connection=asikFhCnx    mirroring_mode=manual
    ...                               l2_l1_bip=true    syscom_mirroring=true
    Run keyword if    '${system_module_type}' == 'ASOD'    privateKW_RACH.Prepare Mirroring ASOD

    Run keyword if    '${system_module_type}' == 'ASIK'
    ...          logs.Start Mirroring manual or remote on Asik     asikFhCnx    ${gnb_mirroring_script_path}
    Run keyword if    '${system_module_type}' == 'ASOD'
    ...          logs.Start Mirroring on Asod    asikFhCnx    ${gnb_mirroring_script_path}

    ${dist_name}     set variable     MRBTS-${mr_bts}/NRBTS-${GNB_nr_bts}/NRCELL-1

#Set and Test macContentionResTimer Syscom L2 l2ps - cell reconfiguration
    ${current_step}   set variable if    '${raContentionResolutionTimer}' != '${EMPTY}'    cellReconfiguration1
    Run keyword if    '${raContentionResolutionTimer}' != '${EMPTY}'    Run keywords
    ...    run keyword and continue on failure     privateKW_RACH.Start Syscom on mirroring   ${current_step}   filter=${EMPTY}    AND
    ...    configuration.Set Parameter Value  ${dist_name}   raContentionResolutionTmr   ${raContentionResolutionTimer}            AND
    ...    run keyword and continue on failure     privateKW_RACH.Stop Syscom on mirroring                                         AND
    ...    run keyword and continue on failure   privateKW_RACH.Check in syscom L2 for cell reconfiguration
    ...        ${current_step}  expectedMacContentionResTimer=${raContentionResolutionTimer}

#Set and Test raContentionResolutionTimer in Syscom L2 l2ps - cell reconfiguration
    ${current_step}    set variable if    '${raResponseWindow}' != '${EMPTY}'    cellReconfiguration2
    Run keyword if    '${raResponseWindow}' != '${EMPTY}'    Run keywords
    ...   run keyword and continue on failure     privateKW_RACH.Start Syscom on mirroring   ${current_step}    filter=${EMPTY}    AND
    ...   configuration.Set Parameter Value  ${dist_name}   raResponseWindow   ${raResponseWindow}                                 AND
    ...   run keyword and continue on failure     privateKW_RACH.Stop Syscom on mirroring                                          AND
    ...   run keyword and continue on failure   privateKW_RACH.Check in syscom L2 for cell reconfiguration
    ...       ${current_step}  expectedRaResponseWindowSizeSize=${raResponseWindow}

#Set others paramaters before call setup
    Run keyword if    '${rsrpThresholdSSB}' != '${EMPTY}'
    ...    configuration.Set Parameter Value  ${dist_name}   rsrpThresholdSSB   ${rsrpThresholdSSB}
    Run keyword if    '${powerRampingStep}' != '${EMPTY}'
    ...    configuration.Set Parameter Value  ${dist_name}   powerRampingStep   ${powerRampingStep}
    Run keyword if    '${preambleReceivedTargetPower}' != '${EMPTY}'
    ...    configuration.Set Parameter Value  ${dist_name}   initialPreambleReceivedTargetPower   ${preambleReceivedTargetPower}
    Run keyword if    '${preambleTransMax}' != '${EMPTY}'
    ...    configuration.Set Parameter Value  ${dist_name}   preambleTransMax   ${preambleTransMax}
    Run keyword if    '${msg3DeltaPreamble}' != '${EMPTY}'
    ...    configuration.Set Parameter Value  ${dist_name}   msg3DeltaPreamble   ${msg3DeltaPreamble}

    ${current_step}       set variable    callSetup
    ${filter}    catenate    ether[24:2]== 0x0240||ether[24:2]== 0x0219
    run keyword and continue on failure     privateKW_RACH.Perform call with all traces   ${current_step}  ${filter}

#Check parameters value in X2 for call setup
    run keyword and continue on failure     privateKW_RACH.Check in X2 for call setup  ${current_step}
    ...  expectedRsrpThresholdSSB=${rsrpThresholdSSB}
    ...  expectedPowerRampingStep=${powerRampingStep}
    ...  expectedInitialPreambleReceivedTargetPower=${preambleReceivedTargetPower}
    ...  expectedPreambleTransMax=${preambleTransMax}
    ...  expectedMacContentionResTimer=${raContentionResolutionTimer}
    ...  expectedRaResponseWindowSize=${raResponseWindow}
    ...  expectedMsg3DeltaPreamble=${msg3DeltaPreamble}

Implicite Pass 511_E Online FR2
    log    ${parameterUpdated}
    run keyword if      'raResponseWindow_syscom' in '${parameterUpdated}'  Implicite passed  5GC000511_E_023
    run keyword if      'raContentionResolutionTmr_syscom' in '${parameterUpdated}'  Implicite passed  5GC000511_E_024
    run keyword if      'initialPreambleReceivedTargetPower_x2' in '${parameterUpdated}'  Implicite passed  5GC000511_E_031
    run keyword if      'preambleTransMax_x2' in '${parameterUpdated}'  Implicite passed  5GC000511_E_032

    run keyword if      'raResponseWindow_x2' in '${parameterUpdated}'  Implicite passed  5GC000511_E_034
    run keyword if      'raContentionResolutionTmr_x2' in '${parameterUpdated}'  Implicite passed  5GC000511_E_035
    run keyword if      'msg3DeltaPreamble_x2' in '${parameterUpdated}'  Implicite passed  5GC000511_E_037
