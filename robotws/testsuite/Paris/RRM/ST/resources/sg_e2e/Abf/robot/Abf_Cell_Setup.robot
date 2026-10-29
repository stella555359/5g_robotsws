*** Settings ***
Documentation   Suite description
Library         OperatingSystem
Library         taf.transport.ssh                           WITH NAME   ssh
Library         taf.gnb.oam.coam.admin                      WITH NAME   coam
Library         ${CURDIR}/../../radParams_handler.py        WITH NAME   radParams

Resource        ${CURDIR}/../../gnbStatus.robot
Resource        ${CURDIR}/../../configuration.robot
Resource        ${CURDIR}/../../metascripts.robot


*** Keywords ***
Abf_Cell_Setup
    [Documentation]     The purpose of this test case is to check Analog
    ...             Beamforming activation at OAM level only
    [Arguments]     ${beamset}    ${testMode}=False    ${BeamOffset}=0

    Alarm initial status

    # seting the rad params.
    # Set Test Mode Rad Params    ${testMode}    ${BeamOffset}

    ${cmd}      catenate
    ...         cat ${CURDIR}/ABF_BeamSet_PatternID
    ...         | grep -E ${beamSet}
    ${res}      Run       ${cmd}
    @{lines}    Split To Lines      ${res}
    @{bs}       Split String    @{lines}[0]    separator=;

    ${scf_modi_param}  catenate      SEPARATOR=;  actBeamforming,true;basicBeamSet,@{bs}[1];numberOfTransmittedSsBlocks,32 beams
    ...                ssBurstSetPeriod,20;leftEdgeAngle,@{bs}[3];rightEdgeAngle,@{bs}[4];upperEdgeAngle,@{bs}[5];lowerEdgeAngle,@{bs}[6]
    ...                tiltOffset,${EMPTY}
    ${output_scf}           configuration.set scf param      ${scf_modi_param}
    #configuration.SCF Validate  ${output_scf}
    configuration.SCF Commission  ${output_scf}

    sleep   75

# GBR Begin : 11/02/2022 comment this fonction not working fine
# -------------------------------------------------------------
#   # Cell setup with syscom
#     metascripts.Cell Setup TCPDump


#   ${file_names}           Function search filenames      ${logs_path}/tcpdump/        CellSetup_syscomAsik_syscomAsik


#   ${f}        Set variable    ${logs_path}/tcpdump/CellSetup_syscomAsik.txt
#   ${cmd}      catenate        tshark -X lua_script:/opt/luashark/luashark.lua -r ${logs_path}/tcpdump/@{filenames}[0]
#               ...             -V -T text -Y "icom_5g" > ${f}
#   ${resp}     Run             ${cmd}

#   ${resp}     Run     grep -E "actBeamforming (.*)0x01" ${f}
#   should contain     ${resp}      actBeamforming

#   ${resp}     Run     grep -E "basicBeamSet (.*)@{bs}[1]" ${f}
#   should contain     ${resp}      basicBeamSet

#   # Verif : Cell is up radiating at least 32 ssb symbols / cell setup param ? RU unit oam gob ?
#   ${resp}     Run     grep -E "numberOfTransmittedSsBlocks (.*)32" ${f}  # 0x20 (32)
#   should contain     ${resp}      numberOfTransmittedSsBlocks

    wait until keyword succeeds    10 min     10 sec     ssh.connect to
    ...     ${oam_vm}           ${oam_vm_login}         ${oam_vm_password}      alias=asikFhCnx_nc
    ssh.Send Command
    ...    command=telnet 0 15007  connection=asikFhCnx_nc
    ssh.Read Output Until
    ...    match=AaShell>${SPACE}
    ...    timeout=3
    ...    connection=asikFhCnx_nc
    ssh.Write Input
    ...    data=rad -w 0x10041 1\r                # AaSysLogOutputMode [0=none; 1=all; 2=udp; 3=sic; 4=standard output; 5=local; 6=remote]
    ...    connection=asikFhCnx_nc
    ssh.Write Input
    ...    data=rad -w 0x1003F 1\r                # AaSysLogInputLevel [0/6=disabled; 1=DBG; 2=INF; 3=WRN; 4=ERR; 5=VIP]
    ...    connection=asikFhCnx_nc
    ssh.Write Input
    ...    data=rad -w 0x10040 1\r                # AaSysLogOutputLevel
    ...    connection=asikFhCnx_nc
    ssh.Write Input
    ...    data=rad -w 0x10042 0x7F000001\r       # AaSysLogUdpAddress 127.0.0.1  loopback addr
    ...    connection=asikFhCnx_nc
    ssh.Write Input
    ...    data=rad -w 0x10043 0xC738\r           # AaSysLogudpPort
    ...    connection=asikFhCnx_nc
    ssh.Write Input
    ...    data=quit\r
    ...    connection=asikFhCnx_nc
    ssh.Read Output Until
    ...    match=Bye ...
    ...    timeout=3
    ...    connection=asikFhCnx_nc
    ssh.Send Command    command=nc -u -w 100 -l 127.0.0.1 51000 | grep -a "L2_PS_CELL" > /tmp/syslog.txt &   connection=asikFhCnx_nc
    Sleep    120s
    ssh.Send Command    command=ps -ef |grep nc|grep 51000| grep -v grep| awk '{print $2}'|xargs kill -9    connection=asikFhCnx_nc
    ssh.Send Command    command=grep -aE "SysInfoConfigResp received" /tmp/syslog.txt   connection=asikFhCnx_nc
    ${buffer}    ssh.Read Output      connection=asikFhCnx_nc
    Log to console      \nbuffer contains :\n${buffer}
    Should not be empty     ${buffer}

    Sleep    10s
    ssh.download_file                remote_path=/tmp/syslog.txt
    ...                              local_path=${logs_path}/syslog.txt
    ...                              connection=asikFhCnx_nc
    Sleep    10s
    run keyword and ignore error   ssh.disconnect   asikFhCnx_nc

    configuration.Create Connections
    Alarm final status
# GBR End


Set Test Mode Rad Params
    [Arguments]     ${testMode}    ${BeamOffset}
    ${rad_lags}=    Set Variable If    '${testMode}'=='True'    0x5800C7=1 0x5800DF=${BeamOffset}
    ...                                                         0x5800C7=0 0x5800DF=${BeamOffset}
    radParams.set_rad_flags    ${rad_lags}    ssh_host=${oam_vm}     persistently=True
