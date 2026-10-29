*** Settings ***
Documentation   Suite description
Library         OperatingSystem
Library         taf.transport.ssh                           WITH NAME   ssh
Library         ${CURDIR}/../../gnbcOamAdmin.py             WITH NAME   gnbAdmin

Resource        ${CURDIR}/../../gnbStatus.robot
Resource        ${CURDIR}/../../configuration.robot
Resource        ${CURDIR}/../../logs.robot

*** Variable ***
${nrcell}        NRCELL-1


*** Keywords ***
Abf_CPRT_Logs_Check
    [Documentation]     The purpose of this test case is to check Analog
    ...             Beamforming activation at OAM level
    [Arguments]     ${beamset}


    configuration.Create Connections
    configuration.Create ssh

     ## Wait for cell to be online - 5min30s are required
    run keyword if      '${oam_type}' == 'MZ'
    ...      wait until keyword succeeds    5 min     30 sec      gnbStatus.Check carrier activation for cell setup
    run keyword if      '${oam_type}' == 'COAM'
    ...      wait until keyword succeeds    5 min     30 sec      gnbStatus.Check Cell Availability Status V2

    # Lock Unlock Cell group to check CPRT logs.
    Lock Unlock Cell and Collect Syscom and S1X2 Traces      nrcell=${nrcell}

    ${cmd}      catenate
    ...         cat ${CURDIR}/ABF_BeamSet_PatternID
    ...         | grep -E ${beamSet}
    ${res}      Run       ${cmd}
    @{lines}    Split To Lines      ${res}
    @{bs}       Split String    @{lines}[0]    separator=;

    # actBeamforming,true;
    #basicBeamSet,@{bs}[1];
    #basicBeamSetValue, @{bs}[2];
    #numberOfTransmittedSsBlocks,32 beams
    #ssBurstSetPeriod,20;
    #leftEdgeAngle,@{bs}[3];
    #rightEdgeAngle,@{bs}[4];
    #upperEdgeAngle,@{bs}[5];
    #lowerEdgeAngle,@{bs}[6]

    ${file_names}           Function search filenames      ${logs_path}/tcpdump/        CellSetup_syscomAsik_syscomAsik

    ${f}        Set variable    ${logs_path}/tcpdump/CellSetup_syscomAsik.txt
    ${cmd}      catenate        tshark -X lua_script:/opt/luashark/luashark.lua -r ${logs_path}/tcpdump/@{filenames}[0]
                ...             -V -T text -Y "icom_5g" > ${f}
    ${resp}     Run             ${cmd}

    ${resp}     Run     grep -E "actBeamforming (.*)0x01" ${f}
    should contain     ${resp}      actBeamforming

    ${basicBeamSetValue}     convert to integer      0x@{bs}[2]

    ${resp}     Run     grep -E "basicBeamSet (.*)@{bs}[1]" ${f} | grep ${basicBeamSetValue}
    should contain     ${resp}      basicBeamSet

    # Verif : Cell is up radiating at least 32 ssb symbols / cell setup param ? RU unit oam gob ?
    ${resp}     Run     grep -E "numberOfTransmittedSsBlocks (.*)32" ${f}  # 0x20 (32)
    should contain     ${resp}      numberOfTransmittedSsBlocks


Lock Unlock Cell and Collect Syscom and S1X2 Traces
    [Documentation]    This Keywod will apply a look unlook of the lock cell
    ...                and collect syscom traces.
    [Arguments]        ${nrcell}=NRCELL-1    ${board_socid}=0    ${sleep_time}=3s
    [Teardown]    run keyword and continue on failure     logs.Stop Syscom Traces    board_socid=${board_socid}

    ##Start SYSCOM and S1X2 traces
    log     ******* START SYSCOM AND S1X2 TRACES FOR CELL SETUP *******

    run keyword and continue on failure     logs.Start Syscom Traces   CellSetup_syscomAsik    board_socid=${board_socid}

    Lock Unlock Cell    ${nrcell}
    BuiltIn.Sleep    ${sleep_time}
    ## Wait for cell to be online - 5min30s are required
    run keyword if      '${oam_type}' == 'MZ'
    ...      wait until keyword succeeds    5 min     30 sec      gnbStatus.Check carrier activation for cell setup
    run keyword if      '${oam_type}' == 'COAM'
    ...      wait until keyword succeeds    5 min     30 sec      gnbStatus.Check Cell Availability Status V2

    ## Collect of CPRT Logs
    log     ******* STOP SYSCOM AND S1X2 TRACES FOR CELL SETUP *******


Lock Unlock Cell
    [Documentation]    This Keywod will apply a look unlook of the lock cell group
    ...                for more info refer to taf.gnb.oam.coam.admin Library
    [Arguments]        ${nrcell}=NRCELL-1

    ${bts_host}=    Set Variable If   '${GNB_Architecture}' == 'CLOUD'
    ...                   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                   ${tl.gnbs[0].cu.oam_http_connection_details.addr}

    gnbAdmin.connect to   bts_host=${bts_host}
    gnbAdmin.lock_cell      ${nrcell}
    BuiltIn.Sleep    5s
    gnbAdmin.unlock_cell     ${nrcell}
    [Teardown]    gnbAdmin.teardown





