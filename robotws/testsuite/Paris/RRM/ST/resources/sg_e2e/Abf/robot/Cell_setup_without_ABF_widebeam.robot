*** Settings ***
Documentation   Suite description
Library         OperatingSystem
Library         taf.transport.ssh                           WITH NAME   ssh
Library         taf.gnb.oam.coam.admin                      WITH NAME   coam

Resource        ${CURDIR}/../../gnbStatus.robot
Resource        ${CURDIR}/../../configuration.robot
Resource        ${CURDIR}/../../mirroringScripts/gnbMirroring.robot
Resource        ${CURDIR}/../../metascripts.robot
Resource        ${CURDIR}/ABF_resources_1ABF.robot

*** Keywords ***
Cell_setup_without_ABF_widebeam
    [Documentation]     This keyword deactivates analog beamforming and checks that cell setup is working
    [Teardown]      Run keyword and ignore error      configuration.Close Connections SSH

    Alarm initial status

    ${scf_modi_param}  Set variable  actBeamforming,false;basicBeamSet,beamSetAbf_1A;numberOfTransmittedSsBlocks,1 beam;ssBurstSetPeriod,10
    ${output_scf}           configuration.set scf param       ${scf_modi_param}
    configuration.SCF Validate  ${output_scf}
    configuration.SCF Commission  ${output_scf}
    configuration.Close Connections SSH
    sleep   45

    configuration.Create Connections
    configuration.Create ssh
    # Cell setup with syscom
    metascripts.Cell Setup TCPDump

    #Take L1L2 logs
    gnbMirroring.Start Mirroring Traces    connection=asikFhCnx
    sleep    20
    ${l1l2file}    gnbMirroring.Stop and Collect Mirroring Traces    connection=asikFhCnx

    configuration.luashark config       expand_field=0         expand_struct=0
    ${cmd}    catenate      tshark -X lua_script:/opt/luashark/luashark.lua -c 50000 -r ${l1l2file} -T fields
    ...       -Y "dldata_slottypereq" -e _ws.col.Info -e DlData_SlotTypeReq.SlotTypeReq.sfn
    ...       -e DlData_SlotTypeReq.SlotTypeReq.slot
    ...       -e DlData_SlotTypeReq.SlotTypeReq.slotType
    ...       -E header=y -E separator=, > ${logs_path}/pcapprocessedSlotTypeReq.txt
    Run         ${cmd}

    ${cmd}    catenate      tshark -X lua_script:/opt/luashark/luashark.lua -c 50000 -r ${l1l2file} -T fields
    ...       -Y "dldata_patternconfigreq" -e _ws.col.Info -e DlData_PatternConfigReq.PatternConfigReq.sfn
    ...       -e DlData_PatternConfigReq.PatternConfigReq.slot
    ...       -e DlData_PatternConfigReq.patternIdPolList.patternIdPolList
    ...       -E header=y -E separator=, > ${logs_path}/pcapprocessedPatterns.txt
    Run         ${cmd}

    configuration.luashark config

    SSB RACH mapping check 1 ABF

    Alarm final status
