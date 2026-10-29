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
Library         Dialogs
Library         XML     use_lxml=True
Resource        ${CURDIR}/../interfaceCheck.robot
Resource        ${CURDIR}/../logs.robot
Resource        ${CURDIR}/../metascripts.robot

#Specific to feature
Resource        ./5GC000511_E_NonReg_Resource.robot
Resource        ./privateKW_RACH.robot
Variables       ./mediation_RACH.yaml

*** Keywords ***
5GC000511_E_NonReg_CellSetup
    [Documentation]
    ...          Author: Stephane Croquet
    [Teardown]  run keywords  privateKW_RACH.Teardown With All Traces AIO

    ...  get_full_logs=0  ext_mirroring=${ext_mirroring}  AND
    ...  run keyword if  '${band}'=='FR2'  Implicite Pass 511_E CellSetup FR2

    Append To File   ${suite_dir}/result.txt   \n\n${TEST NAME}\n
    Append To File   ${suite_dir}/result.txt   ********************************************************************\n


    set test variable  ${ext_mirroring}  0

    set test variable  ${parameterToBeUpdated}  ${EMPTY}
    set test variable  ${parameterUpdated}  ${EMPTY}

    run keyword if  '${band}'=='FR2'
    ...  Launch cell setup test  ${rsrpThresholdSSB}  ${powerRampingStep}  ${preambleReceivedTargetPower}  ${preambleTransMax}
    ...  ${raContentionResolutionTimer}  ${raResponseWindow}  ${zeroCorrelationZoneConfig}  ${prachConfigurationIndex}
    ...  ${prachRootSequenceIndex}  ${cbraPreamblesPerSsb}  ${msg1FrequencyStart}  ${msg3DeltaPreamble}


Implicite Pass 511_E CellSetup FR2
    log    ${parameterUpdated}
    run keyword if      'rsrpThresholdSSB_x2' in '${parameterUpdated}'  Implicite passed  5GC000511_E_002
    run keyword if      'preambleTransMax_x2' in '${parameterUpdated}'  Implicite passed  5GC000511_E_005
    ${status1}  evaluate    'zeroCorrelationZoneConfig_syscom' in """${parameterUpdated}"""
    ${status2}  evaluate    'zeroCorrelationZoneConfig_x2' in """${parameterUpdated}"""
    run keyword if  ${status1} and ${status2}    Implicite passed  5GC000511_E_008
    run keyword if      'msg3DeltaPreamble_x2' in '${parameterUpdated}'  Implicite passed  5GC000511_E_013

    run keyword if      'cbraPreamblesPerSsb_syscom' in '${parameterUpdated}'  Implicite passed  5GC000511_E_011
    run keyword if      'powerRampingStep_x2' in '${parameterUpdated}'  Implicite passed  5GC000511_E_003
    run keyword if      'initialPreambleReceivedTargetPower_x2' in '${parameterUpdated}'  Implicite passed  5GC000511_E_004
    run keyword if      'prachConfigurationIndex_x2' in '${parameterUpdated}'  Implicite passed  5GC000511_E_009
    run keyword if      'prachRootSequenceIndex_x2' in '${parameterUpdated}'  Implicite passed  5GC000511_E_010
    run keyword if      'msg1FrequencyStart_x2' in '${parameterUpdated}'  Implicite passed  5GC000511_E_012
