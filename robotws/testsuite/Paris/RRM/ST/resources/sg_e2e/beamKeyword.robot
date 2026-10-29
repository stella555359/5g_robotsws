*** Settings ***
Documentation   description


*** Keywords ***
Download writer
    [Documentation]    This keyword upload and compiles writer tool on ABIL Xeon A

    # Copy "writer" source on VM and compile the executable
    ${writerDirectoy}=    Catenate    SEPARATOR=    %{HOME}    /refinedBeamWriter
    Create Directory      ${writerDirectoy}
    ${source_writer}=     Set Variable    writerRefined.c
    ${source_writer_path}=     catenate    SEPARATOR=    ${CURDIR}    /writerRefined.c
    Copy File             ${source_writer_path}    ${writerDirectoy}/${source_writer}

    ${writer_binary_path}=    catenate    SEPARATOR=      ${writerDirectoy}    /writer
    ${resultat}=    Run    /usr/bin/cc ${writerDirectoy}/${source_writer} -o ${writer_binary_path} -lrt

    ${remote_writer_path}=    Set Variable    /dev/shm/writer
    ssh.Upload File    local_path=${writer_binary_path}    remote_path=${remote_writer_path}    connection=abilXeonACnx

Download Recovery Script
    [Documentation]    This keyword upload and recovery sh scrpts on ABIL Xeon A
    [Arguments]      ${local_recovery_path}    ${connection}=asikFhCnx

    ${remote_recovery_path}=    Set Variable    /ffs/run/config/recovery_script.sh
    ssh.Upload File    local_path=${local_recovery_path}    remote_path=${remote_recovery_path}    connection=${connection}

Set Beam Attenuation
    [Documentation]    This keyword uses writer tool to set attenuation on beams.
    ...                If writer tool is not already present, calls keyword "Download Writer", and
    ...                launch attenuation provided in argument
    ...                Example of command to apply 10dB attenuation on SSB beam 0 and 0dB attenuation on SSB Beams 1 to 7,
    ...                for a pattern of 8 beams and 0 refined beams:
    ...                ./writer BeamformingTestMode.map.9913 64 "\x0A\x00\x00\x00\x00\x00\x00\x00"
    ...                Example of command to apply an attenuation on SSB 0, 6 dB attenuation of SSB1, no attenuation on first refined beam
    ...                of SSB0, 6dB attenuation on second refined bealm of SSB0, and full attenuation on all other beams, for a pattern
    ...                of 8 beams and 32 refined beams:
    ...                NB: the pattern is shown on 5 lines due to coding rules, but the command is actually on one line only.
    ...                ./writer BeamformingTestMode.map.9913 64 \\x00\\x06\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF
    ...                                                       \\x00\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF
    ...                                                       \\x06\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF
    ...                                                       \\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF
    ...                                                       \\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF
    ...                Example of command to apply an attenuation on SSB 0, 6 dB attenuation of SSB1, for a pattern of 32 beams and no refined beams:
    ...                ./writer BeamformingTestMode.map.9913 64 \\x00\\x06\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF
    ...                                                       \\x00\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF
    ...                                                       \\x06\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF
    ...                                                       \\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF
    ...                                                       \\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF
    [Arguments]        ${beam_attenuation_string}

    # create ssh connections
    # configuration.Create ssh

    ${remote_writer_path}=    Set Variable    /dev/shm/writer
    ${is_writer_downloaded}=    ssh.File exists    remote_path=${remote_writer_path}    connection=abilXeonACnx
    #Run keyword unless    ${is_writer_downloaded}    Download writer
    Run keyword if    ${is_writer_downloaded} == ${False}    Download writer

    # build beamforming commands
    ${list_beam_file}=    ssh.execute       cd /dev/shm; ls Beam*      connection=abilXeonACnx
    @{list_beam_file2}=    string.Split string    ${list_beam_file}

    ${beam_file_1}=    set variable    @{list_beam_file2}[0]
    ${beam_file_2}=    set variable    @{list_beam_file2}[1]

    ${writer_cmd1}=    catenate    cd /dev/shm;./writer ${beam_file_1} 64     ${beam_attenuation_string}
    ${writer_cmd2}=    catenate    cd /dev/shm;./writer ${beam_file_2} 64     ${beam_attenuation_string}

    ssh.execute       chmod 777 /dev/shm/writer   connection=abilXeonACnx
    ssh.execute       ${writer_cmd1}           connection=abilXeonACnx
    ssh.execute       ${writer_cmd2}           connection=abilXeonACnx

    # Close ssh connections
    # configuration.Close Connections SSH


Set Beam Attenuation writer
    [Documentation]    This keyword compiles and uses an executable "writer" to attenuate beams in conducted mode
    ...                It uploads "writer" on ABIL Xeon A and launch attenuation provided in argument
    ...                It shall be used on each RF in conducted mode
    ...                Example of command to apply 10dB attenuation on SSB beam 0 and 0dB attenuation on SSB Beams 1 to 7:
    ...                ./writer BeamformingTestMode.map.9913 64 "\x0A\x00\x00\x00\x00\x00\x00\x00"
    ...                Example of command to apply ino attenuation on SSB 0, 6 dB attenuation of SSB1, no attenuation on first refined beam
    ...                of SSB0, 6dB attenuation on second refined bealm of SSB0, and full attenuation on all other beams:
    ...                NB: the pattern is shown on 5 lines due to coding rules, but the command is actually on one line only.
    ...                ./writer BeamformingTestMode.map.9913 64 \\x00\\x06\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF
    ...                                                       \\x00\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF
    ...                                                       \\x06\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF
    ...                                                       \\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF
    ...                                                       \\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF

    [Arguments]        ${beam_attenuation_string}


    # Copy "writer" source on VM and compile the executable
    ${writerDirectoy}=    Catenate    SEPARATOR=    %{HOME}    /refinedBeamWriter
    Create Directory      ${writerDirectoy}
    ${source_writer}=     Set Variable    writerRefined.c
    ${source_writer_path}=     catenate    SEPARATOR=    ${CURDIR}    /writerRefined.c
    Copy File             ${source_writer_path}    ${writerDirectoy}/${source_writer}

    ${writer_binary_path}=    catenate    SEPARATOR=      ${writerDirectoy}    /writer
    ${resultat}=    Run    /usr/bin/cc ${writerDirectoy}/${source_writer} -o ${writer_binary_path} -lrt


    # create ssh connections
    configuration.Create ssh

    # build beamforming commands
    ${list_beam_file}=    ssh.execute       cd /dev/shm; ls Beam*      connection=abilXeonACnx
    @{list_beam_file2}=    string.Split string    ${list_beam_file}

    ${beam_file_1}=    set variable    @{list_beam_file2}[0]
    ${beam_file_2}=    set variable    @{list_beam_file2}[1]

    ${writer_cmd1}=    catenate    cd /dev/shm;./writer ${beam_file_1} 64     ${beam_attenuation_string}
    ${writer_cmd2}=    catenate    cd /dev/shm;./writer ${beam_file_2} 64     ${beam_attenuation_string}

    ${remote_writer_path}=    Set Variable    /dev/shm/writer
    ssh.Upload File    local_path=${writer_binary_path}    remote_path=${remote_writer_path}    connection=abilXeonACnx
    ssh.execute       chmod 777 /dev/shm/writer   connection=abilXeonACnx
    ssh.execute       ${writer_cmd1}           connection=abilXeonACnx
    ssh.execute       ${writer_cmd2}           connection=abilXeonACnx

    # Close ssh connections
    configuration.Close Connections SSH


Set Beam Attenuation echo
    [Documentation]    This keyword uses echo command to attenuate beams in conducted mode
    ...                It is launched on ABIL Xeon A and set attenuation provided in argument
    ...                It shall be used on each RF in conducted mode
    ...                Example of command to apply 10dB attenuation on SSB beam 0 and 0dB attenuation on SSB Beams 1 to 7:
    ...                echo -ne '\x0A\x00\x00\x00\x00\x00\x00\x00' | tee /dev/shm/BeamformingTestMode.map.* >>stdout
    ...                Example of command to apply no attenuation on SSB 0, 6 dB attenuation of SSB1, no attenuation on first refined beam
    ...                of SSB0, 6dB attenuation on second refined bealm of SSB0, and full attenuation on all other beams:
    ...                NB: the pattern is shown on 5 lines due to coding rules, but the command is actually on one line only.
    ...                echo -ne '\x00\x06\xFF\xFF\xFF\xFF\xFF\xFF
    ...                          \x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF
    ...                          \x06\xFF\xFF\xFF\xFF\xFF\xFF\xFF
    ...                          \xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF
    ...                          \xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF' | tee /dev/shm/BeamformingTestMode.map.* >>stdout
    ...                NB: due to robot syntax, all \, /, |  must be escaped by a \, so the beam_attenuation string to provide should have the
    ...                following syntax:
    ...                '\\x0A\\x00\\x00\\x00\\x00\\x00\\x00\\x00'

    [Arguments]        ${beam_attenuation_string}


    # create ssh connections
    configuration.Create ssh

    # ...                echo -ne '\x0A\x00\x00\x00\x00\x00\x00\x00' | tee /dev/shm/BeamformingTestMode.map.* >>stdout

    # build beamforming commands
    ${echo_cmd}=    catenate    SEPARATOR=
    ...                         cd /dev/shm;echo -ne '    ${beam_attenuation_string}    ' | tee /dev/shm/BeamformingTestMode.map.* >>stdout

    ssh.execute       ${echo_cmd}           connection=abilXeonACnx

    # Close ssh connections
    configuration.Close Connections SSH

Set Beam Weights
    [Documentation]    This keyword uses bfloader to set beam weight according to beamset configuration and
    ...                Ue cabling. Ports used on AEQD are port 21 and 22 (mandatory).
    ...                bfloader used is the one delivered in RF package. It is loaded on RF in /usr/bin
    ...                csv file describing weigth is delivered with robot test suite
# Modifier le keyword pour prendre en compte la commande writer et le type de RF
    [Arguments]   ${BeamSet}    ${BeamRefinement}

    # create ssh connections
    configuration.Create ssh


    # Get RF IP adress from startup_BTSOM.log
    ${RF_IP_Addr}=    configuration.Get RF IP Address From Dhcp Lease
    Log               Adresse IP du RF: ${RF_IP_Addr}
    ssh.connect to    ${RF_IP_Addr}    username=root    password=umniedziala    alias=RfCnx    proxy=asikFhCnx


    # beam weight file to use according to beamset and refinement mode
    ${csv_beamfile_beamset_2_refined}=    Set Variable    ${CURDIR}/Beam_Set2_SSB0_Ant20_SSBRefined_Ant21_SSB1_Ant22.csv
    ${remote_csv_beamfile_beamset_2_refined}=    Set Variable    /ram/Beam_Set2_SSB0_Ant20_SSBRefined_Ant21_SSB1_Ant22.csv

    ${csv_beamfile_beamset_2_not_refined}=    Set Variable    ${CURDIR}/Beam_Set2_SSB1_Ant20_Ant21_SSB2_Ant22_no_refinement.csv
    ${remote_csv_beamfile_beamset_2_notrefined}=    Set Variable    /ram/Beam_Set2_SSB1_Ant20_Ant21_SSB2_Ant22_no_refinement.csv

    # build beamforming commands
    ${bf_cmd}=    Set Variable    /usr/bin/bfloader -l gen3lf/BfCoefVector -w -f
    ${bf_arg }=    Set Variable    -a fpga -o 0xa00 -d 4

    ${bf_cmd_beamset_2_refined}=    Catenate    ${bf_cmd}    ${remote_csv_beamfile_beamset_2_refined}    ${bf_arg}
    ${bf_cmd_beamset_2_not_refined}=    Catenate    ${bf_cmd}    ${remote_csv_beamfile_beamset_2_not_refined}    ${bf_arg}

    # Activate the right csv file according to beamset given in arguments and activate it
    Run keyword if    '${BeamSet}' == 'beamset_2' and '${BeamRefinement}' == 'true'    Run keywords
    ...                         ssh.Upload File    local_path=${csv_beamfile_beamset_2_refined}
    ...                         remote_path=${remote_csv_beamfile_beamset_2_refined}
    ...                         connection=RfCnx          AND
    ...                         ssh.execute   ${bf_cmd_beamset_2_refined}   connection=RfCnx
    Run keyword if    '${BeamSet}' == 'beamset_2' and '${BeamRefinement}' == 'false'    Run keywords
    ...                         ssh.Upload File    local_path=${csv_beamfile_beamset_2_not_refined}
    ...                         remote_path=${remote_csv_beamfile_beamset_2_not_refined}
    ...                         connection=RfCnx          AND
    ...                         ssh.execute   ${bf_cmd_beamset_2_not_refined}   connection=RfCnx

    # Close ssh connections
    configuration.Close Connections SSH

Set Beam Weights 21A
    [Documentation]    This keyword uses bfloader to set beam weight according to beamset configuration and
    ...                Ue cabling. Ports used on AEQD are port 21 and 22 (mandatory).
    ...                bfloader used is the one delivered in RF package. It is loaded on RF in /usr/bin
    ...                csv file describing weigth is delivered with robot test suite
    ...                Starting for 21A, RF can be reached only through FHNET and previous keyword can not
    ...                be used anymore
    [Arguments]   ${BeamSet}    ${BeamRefinement}

    # Get RF IP adress
    ${RF_IP_Addr}=    configuration.Get RF IP Address From Dhcp Lease 21A
    Log               Adresse IP du RF: ${RF_IP_Addr}

    # beam weight file to use according to beamset and refinement mode
    ${csv_beamfile_beamset_2_refined}=    Set Variable    ${CURDIR}/Beam_Set2_SSB0_Ant20_SSBRefined_Ant21_SSB1_Ant22.csv
    ${remote_csv_beamfile_beamset_2_refined}=    Set Variable    /ram/Beam_Set2_SSB0_Ant20_SSBRefined_Ant21_SSB1_Ant22.csv

    ${csv_beamfile_beamset_2_not_refined}=    Set Variable    ${CURDIR}/Beam_Set2_SSB1_Ant20_Ant21_SSB2_Ant22_no_refinement.csv
    ${remote_csv_beamfile_beamset_2_notrefined}=    Set Variable    /ram/Beam_Set2_SSB1_Ant20_Ant21_SSB2_Ant22_no_refinement.csv

    # build beamforming commands
    ${bf_cmd}=    Set Variable    /usr/bin/bfloader -l gen3lf/BfCoefVector -w -f
    ${bf_arg }=    Set Variable    -a fpga -o 0xa00 -d 4

    ${bf_cmd_beamset_2_refined}=    Catenate    ${bf_cmd}    ${remote_csv_beamfile_beamset_2_refined}    ${bf_arg}
    ${bf_cmd_beamset_2_not_refined}=    Catenate    ${bf_cmd}    ${remote_csv_beamfile_beamset_2_not_refined}    ${bf_arg}

    # Create connection to RF unit
    ssh.Connect To       ${oam_vm}           ${oam_vm_login}         ${oam_vm_password}     alias=asikRU
    ${connection}    ssh.get_connection_by_alias    alias=asikRU
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n 0x1018\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    Call Method    ${channel}    send    ${sshd_command}\n
    Sleep    3 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    close

    ssh.connect to   192.168.255.254    ${oam_vm_login}    ${oam_vm_password}    alias=container    proxy=asikRU
    ssh.connect to   hostname=${RF_IP_Addr}    username=root    password=umniedziala    alias=rucnx    proxy=container

    ssh.send_command    command=cd /ram; ls -lrt    connection=rucnx
    ${output}=          ssh.read output         connection=rucnx


    # Activate the right csv file according to beamset given in arguments and activate it
    Run keyword if    '${BeamSet}' == 'beamset_2' and '${BeamRefinement}' == 'true'    Run keywords
    ...                         ssh.Upload File    local_path=${csv_beamfile_beamset_2_refined}
    ...                         remote_path=${remote_csv_beamfile_beamset_2_refined}
    ...                         connection=rucnx          AND
    ...                         ssh.execute   ${bf_cmd_beamset_2_refined}   connection=rucnx
    Run keyword if    '${BeamSet}' == 'beamset_2' and '${BeamRefinement}' == 'false'    Run keywords
    ...                         ssh.Upload File    local_path=${csv_beamfile_beamset_2_not_refined}
    ...                         remote_path=${remote_csv_beamfile_beamset_2_not_refined}
    ...                         connection=rucnx          AND
    ...                         ssh.execute   ${bf_cmd_beamset_2_not_refined}   connection=rucnx
    ${output}=          ssh.read output         connection=rucnx


    # Disconnect from RF
    ssh.disconnect     connection=rucnx
    ssh.disconnect     connection=container
    ssh.disconnect     connection=asikRU

Prepare Abf Writer
    [Documentation]    This keyword uploads "writer" on ffs shared folder
    [Arguments]        ${connection}=asikFhCnx

    #bypass robocop
    ${connection}    set variable    ${connection}
    # Copy "writer" source on VM and compile the executable
    ${writerDirectoy}=    Catenate    SEPARATOR=    %{HOME}    /refinedBeamWriter
    Create Directory      ${writerDirectoy}
    ${source_writer}=     Set Variable    writerRefined.c
    ${source_writer_path}=     catenate    SEPARATOR=    ${CURDIR}    /writerRefined.c
    Copy File             ${source_writer_path}    ${writerDirectoy}/${source_writer}

    ${writer_binary_path}=    catenate    SEPARATOR=      ${writerDirectoy}    /writer
    ${resultat}=    Run    /usr/bin/cc ${writerDirectoy}/${source_writer} -o ${writer_binary_path} -lrt
    log    ${resultat}
    #copy writer on gNB shared folder /ffs/run/config
    ${remote_writer_path}=    Set Variable    /ffs/run/config/writer
    ssh.Upload File    local_path=${writer_binary_path}    remote_path=${remote_writer_path}    connection=asikFhCnx

Delete Writer on Asik
    [Documentation]    This keyword delete "writer" on ffs shared folder
    ssh.execute    rm /ffs/run/config/writer    connection=asikFhCnx

Get Container Name
    [Documentation]    This keyword help to get container Name
    ...                Example 0x1740 or 0x2740.
    [Arguments]        ${alias}=asikRU

    ssh.Connect To       ${oam_vm}
    ...                  ${oamVMLogin}
    ...                  ${oamVMPassword}
    ...                  alias=${alias}

    ${connection}    ssh.get_connection_by_alias    alias=${alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    bsh 1:1\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    lxc-ls\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    ### Close the connection
    Call Method    ${channel}    close

    Return from keyword if  '0x1740' in """${output}"""    0x1740
    Return from keyword if  '0x2740' in """${output}"""    0x2740


Set Beam Attenuation for New RuGen
    [Documentation]    This keyword uses an executable "writer" to attenuate beams for Ru Gen4 and Upper
    ...                Example of command to apply 10dB attenuation on SSB beam 0 and 0dB attenuation on SSB Beams 1 to 7:
    ...                ./writer BeamformingTestMode.map.9913 64 "\x0A\x00\x00\x00\x00\x00\x00\x00"
    ...                Example of command to apply ino attenuation on SSB 0, 6 dB attenuation of SSB1, no attenuation on first refined beam
    ...                of SSB0, 6dB attenuation on second refined bealm of SSB0, and full attenuation on all other beams:
    ...                NB: the pattern is shown on 5 lines due to coding rules, but the command is actually on one line only.
    ...                ./writer BeamformingTestMode.map.9913 64 \\x00\\x06\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF
    ...                                                       \\x00\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF
    ...                                                       \\x06\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF
    ...                                                       \\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF
    ...                                                       \\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF\\xFF

    [Arguments]        ${beams_att_pattern}    ${lxc_name}    ${alias}=asikRU
    # Connection to RF unit
    ssh.Connect To       ${oam_vm}
    ...                  ${oamVMLogin}
    ...                  ${oamVMPassword}
    ...                  alias=${alias}

    ${connection}    ssh.get_connection_by_alias    alias=${alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    bsh 1:1\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    lxc-attach -n ${lxc_name}\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    cp /ffs/run/config/writer /dev/shm/writer\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    chmod 777 /dev/shm/writer\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    # build beamforming commands
    ${cmd}=    Set Variable    cd /dev/shm; ls Beam*
    Call Method    ${channel}    send    ${cmd}\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    @{output_list}=    string.Split string    ${output}
    @{list_beam_file}=    Get Matches    ${output_list}    BeamformingTestMode*
    ${beam_file_1}=    set variable    @{list_beam_file}[0]
    ${beam_file_2}=    set variable    @{list_beam_file}[1]

    ${writer_cmd1}=    catenate    cd /dev/shm;./writer ${beam_file_1} 64     ${beams_att_pattern}
    ${writer_cmd2}=    catenate    cd /dev/shm;./writer ${beam_file_2} 64     ${beams_att_pattern}

    Call Method    ${channel}    send    ${writer_cmd1}\n
    Sleep    2 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ${writer_cmd2}\n
    Sleep    2 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    ## log the writer application
    ${cmd}=    catenate     xxd -g 1 /dev/shm/${beam_file_1}
    Call Method    ${channel}    send    ${cmd}\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    Log    writer exec ${beam_file_1}: ${output}
    ${cmd}=    catenate     xxd -g 1 /dev/shm/${beam_file_2}
    Call Method    ${channel}    send    ${cmd}\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    Log    writer exec ${beam_file_2}: ${output}
    ## delete the writer from Container
    Call Method    ${channel}    send    rm /dev/writer\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    ### Close the connection
    Call Method    ${channel}    close

Set Beam Attenuation ABIO
    [Documentation]    This keyword uses an executable "writer" to attenuate beams for equiped
    ...                with ASIB: 1 / ABIO: 1 / RU AZQO
    ...                ./writer BeamformingTestMode.map.9913 64 "\x0A\x00\x00\x00\x00\x00\x00\x00"
    ...                Example of command to apply ino attenuation on SSB 0, 6 dB attenuation of SSB1, no attenuation on first refined beam
    ...                of SSB0, 6dB attenuation on second refined bealm of SSB0, and full attenuation on all other beams:
    ...                NB: the pattern is shown on 5 lines due to coding rules, but the command is actually on one line only.
    ...                ./writer2 BeamformingTestMode.map.199 64 \\x00\\x10\\x20\\xFF\\xFF\\xFF\\xFF\\xFF
    ...                                                       \\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00
    ...                                                       \\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00
    ...                                                       \\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00
    ...                                                       \\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00

    [Arguments]        ${beam_attenuation_string}    ${lxc_name}    ${alias}=asikRU
    # Create connection to RF unit
    ssh.Connect To       ${oam_vm}   # ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                  ${oamVMLogin}   # ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                  ${oamVMPassword}    #${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                  alias=${alias}

    ${connection}    ssh.get_connection_by_alias    alias=${alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    bsh 1:0\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    lxc-attach -n ${lxc_name}\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    cp /ffs/run/config/writer /dev/shm/writer\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    chmod 777 /dev/shm/writer\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    # build beamforming commands
    ${cmd}=    Set Variable    cd /dev/shm; ls Beam*
    Call Method    ${channel}    send    ${cmd}\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    @{output_list}=    string.Split string    ${output}
    @{list_beam_file}=    Get Matches    ${output_list}    BeamformingTestMode*
    ${beam_file_1}=    set variable    @{list_beam_file}[0]

    ${writer_cmd1}=    catenate    cd /dev/shm;./writer ${beam_file_1} 64     ${beam_attenuation_string}

    Call Method    ${channel}    send    ${writer_cmd1}\n
    Sleep    2 sec
    ${output}  Call Method    ${channel}    recv    ${65535}

    ## delete the writer from Container
    Call Method    ${channel}    send    rm /dev/shm/writer\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    ## Close the connection
    Call Method    ${channel}    close

Run Beam recovery Scenario
    [Documentation]    This keyword uses an executable "writer" and linux script to attenuate beams for Ru Gen4 and Upper
    [Arguments]        ${recovery_scipt}    ${lxc_name}    ${alias}=asikRU
    # Create connection to RF unit
    ssh.Connect To       ${oam_vm}
    ...                  ${oamVMLogin}
    ...                  ${oamVMPassword}
    ...                  alias=${alias}

    ${connection}    ssh.get_connection_by_alias    alias=${alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    bsh 1:1\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    lxc-attach -n ${lxc_name}\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    # CP Delete Writer
    Call Method    ${channel}    send    cp /ffs/run/config/writer /dev/shm/writer\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    chmod 777 /dev/shm/writer\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    # copy recovery script
    log    cp /ffs/run/config/${recovery_scipt} /dev/shm/${recovery_scipt}\n
    Call Method    ${channel}    send    cp /ffs/run/config/${recovery_scipt} /dev/shm/${recovery_scipt}\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    chmod 777 /dev/shm/${recovery_scipt}\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    # build beamforming commands
    ${cmd}=    Set Variable    cd /dev/shm; ls Beam*
    Call Method    ${channel}    send    ${cmd}\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    @{output_list}=    string.Split string    ${output}
    @{list_beam_file}=    Get Matches    ${output_list}    BeamformingTestMode*
    ${beam_file_1}=    set variable    @{list_beam_file}[0]
    ${beam_file_2}=    set variable    @{list_beam_file}[1]

    ${sed_cmd1}=    catenate    sed -i -e "s/beam_file_1/${beam_file_1}/g" /dev/shm/${recovery_scipt}\n
    ${sed_cmd2}=    catenate    sed -i -e "s/beam_file_2/${beam_file_2}/g" /dev/shm/${recovery_scipt}\n
    Call Method    ${channel}    send    ${sed_cmd1}\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ${sed_cmd2}\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}

    Call Method    ${channel}    send    /dev/shm/${recovery_scipt}\n

    #Wait Until Process End
    ${output}  Call Method    ${channel}    recv    ${65535}
    wait until keyword succeeds    15 min     45 sec
    ...            Recovery Script Terminated     ${channel}
    ## delete the writer and script from Container
    Call Method    ${channel}    send    rm /dev/shm/writer\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    rm /dev/shm/${recovery_scipt}\n
    Sleep    1 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    # close the connections
    Call Method    ${channel}    close

Recovery Script Terminated
    [Arguments]  ${channel}
    Sleep    3 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    Should Contain    ${output}    root

Abf 32 Beams Set Attenuation Pattern
    [Documentation]    This keyword will apply attenuate:
    ...             Set attenuation pattern of alls beams except of ${beamId_list}
    [Arguments]   ${ssbidx}=@{EMPTY}    ${ssbidx_att}=\\x00    ${att}=\\xFF
    ${beams_att_pattern}    Set variable    "
    FOR    ${id}   IN RANGE    1   33
          ${beam_att}=    Set variable if    ${id} in @{ssbidx}    ${ssbidx_att}    ${att}
          ${beams_att_pattern}=    Catenate    SEPARATOR=    ${beams_att_pattern}    ${beam_att}
    END
    ${beams_att_pattern}=    Catenate    SEPARATOR=    ${beams_att_pattern}    "
    [Return]    ${beams_att_pattern}
