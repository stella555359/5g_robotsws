*** Settings ***
Library         Collections
Library         taf.transport.ssh                           WITH NAME   ssh
Resource        ${CURDIR}/configuration.robot
Resource        ${CURDIR}/metascripts.robot

*** Keywords ***
aBF attenuation power
    [Arguments]             &{beams_to_activate}
    ${beams_Index}          get dictionary keys              ${beams_to_activate}
    ${beams_value}          get dictionary values            ${beams_to_activate}
    ${var}=                 set variable                     ${0}
    ${var}=                 Convert To Integer               ${var}
    # update  &{beams_input}  with &{beams_activated} input
    FOR                   ${i}            IN                  @{beams_Index}
                           ${key_tmp}=       set variable                    @{beams_to_activate}[${var}]
                           ${value_tmp}=     get from dictionary      ${beams_to_activate}        ${key_tmp}
                           Collections.Set To Dictionary       ${beams_input}          ${key_tmp}=${value_tmp}
                           ${var}            set variable            ${var+1}
    END
    ${var}                  set variable                        ${0}
    ${created_string}       set variable                        '
    ${repeated_string}      set variable                        \\x
    FOR                   ${i}         IN       @{beams_input}
                           ${key_tmp}=           set variable                    @{beams_input}[${var}]
                           ${value_tmp}=         get from dictionary             ${beams_input}         ${key_tmp}
                           ${created_string}=    set variable      ${created_string}${repeated_string}${value_tmp}
                           ${var}                set variable                    ${var+1}
    END
    ${created_string}=      set variable                        ${created_string}'>/dev/shm/
    # Look for the files beginning by "BeamformingTestMode.map."==> cnx: Xeon A of ABIL
    ${file_names}           Function search filenames       /dev/shm      BeamformingTestMode.map.      abilXeonACnx
    FOR                    ${i}            IN                  @{file_names}
                           ssh.execute         command=echo -ne ${created_string}${i}      connection=abilXeonACnx
    END
    #ssh.disconnect          connection=abilXeonACnx

aBF attenuation power mute all
    ${file_names}           Function search filenames      /dev/shm        BeamformingTestMode.map.     abilXeonACnx
    ${att}                  Evaluate    '\\xFF' * 32
    FOR                    ${i}            IN                  @{file_names}
                           ssh.execute     command=echo -ne '${att}' > /dev/shm/${i}       connection=abilXeonACnx
   END
   #ssh.disconnect           connection=abilXeonACnx

aBF attenuation power unmute all
    ${file_names}           Function search filenames    /dev/shm     BeamformingTestMode.map.      abilXeonACnx
    ${att}                  Evaluate    '\\x00' * 32
    FOR                    ${i}            IN                  @{file_names}
                           ssh.execute     command=echo -ne '${att}' > /dev/shm/${i}       connection=abilXeonACnx
    END
    #ssh.disconnect          connection=abilXeonACnx

aBF fixed beam activation
    [Arguments]             ${rdAbfScanOffset}    ${rdAbfScanStep}=0     ${swconfig_file_path}=/ffs/run/swconfig.txt
    ${radparam}             Set Variable    "0x5800C6=${rdAbfScanStep} 0x5800C5=${rdAbfScanOffset} 0x5800C7=1"
    Log                     ${radparam}
    configuration.Modify bits in swconfig         ${radparam}     ${swconfig_file_path}      asikFhCnx

aBF fixed beam deactivation
    [Arguments]             ${swconfig_file_path}=/ffs/run/swconfig_local.txt
    configuration.Modify bits in swconfig    "#0x5800C5 #0x5800C6 #0x5800C7"     ${swconfig_file_path}      asikFhCnx

aBF force beam
    [Arguments]         ${beamid}=None   ${main_attenuation}=00    ${other_attenuation}=78
    return from keyword if      ${beamid} is ${None}      No beam required
    testmode.activate power testmode
    ${ind}                  convert to integer      ${beamid}
    ${att}                  Catenate   SEPARATOR=    x     ${other_attenuation}
    ${att}                  Evaluate    '${att}' * ${ind}
    ${att}                  Catenate   SEPARATOR=    ${att}     x     ${main_attenuation}
    ${ind}                  Evaluate    31 - ${ind}
    ${att2}                 Evaluate    'x${other_attenuation}' * ${ind}
    ${att}                  Catenate   SEPARATOR=    ${att}     ${att2}
    ${att}                  Replace String          ${att}      x       \\x
    log                     echo -ne '${att}' > /dev/shm/toto
    ${file_names}           Function search filenames      /dev/shm        BeamformingTestMode.map.     abilXeonACnx
    FOR                    ${i}            IN                  @{file_names}
                           ssh.execute     command=echo -ne '${att}' > /dev/shm/${i}       connection=abilXeonACnx
    END

activate power testmode
    ${testmode}      ssh.execute    command=cat ${swconfig_file_path} | grep -i "^ *0x5800C7=1"   connection=asikFhCnx
    return from keyword if  len($testmode) > 0    Power Testmode already activated

    run keyword if  len($testmode) == 0    configuration.Modify bits in swconfig   "0x5800C7=1"     ${swconfig_file_path}      asikFhCnx

    configuration.Site Reset
    sleep   60
    wait until keyword succeeds    5 min     60 sec     ssh.force reconnect 	  connection=asikFhCnx
    #wait until keyword succeeds    15 min     60 sec     Check specific alarm       No X2 link available     0
    # Cell setup with syscom
    metascripts.Cell Setup TCPDump
    #wait until keyword succeeds    15 min     60 sec     gnbStatus.Check Cell radiation

    #Reconnect after RAP reset
    ssh.force reconnect 	  connection=abilLonerCnx
    configuration.BIP L1L2 message mirroring configuration
