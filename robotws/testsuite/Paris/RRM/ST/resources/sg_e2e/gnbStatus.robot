*** Settings ***
Library         OperatingSystem
Library         Collections

Library         taf.transport.ssh              WITH NAME   ssh
Library         taf.gnb.oam.megazone_client    WITH NAME   mz
Library         taf.gnb.oam.coam.admin         WITH NAME   coam

Library         ${CURDIR}/myLib_maths.py
Resource        ${CURDIR}/basics.robot
Resource        ${CURDIR}/configuration.robot


*** Keywords ***
Get Software Version
    [Documentation]     Get the software version
    ...                 TAF used taf.gnb.oam.mz_client 3.16.2
    ...                 gNB compatibility: MZ COAM
    ...                 Update: Stephane Croquet - 20190510 - Add COAM
    ...                 20202805 Update Fabienne Magueur : add connection name for C-OAM

    log                 ${oam_type}
    log                 ${oam_vm}
    log                 ${oam_alias}
    ${sw_version}       run keyword if      '${oam_type}' == 'MZ'       mz.get_sw_version    MegaZ
    ...   ELSE IF      '${oam_type}' == 'COAM'      coam.get_sw_version  connection=coamCnx
    [Return]            ${sw_version}



Get All VM Status
    [Documentation]                 Get all VM status
    ...                             TAF used taf.gnb.oam.mz_client 3.16.2
    :FOR                ${cu_vm}    IN      @{cu_vm_list}
    \                   ${availability_status_tmp}      mz.get_vm_availability_status         ${cu_vm}        MegaZ
    \                   ${procedural_status_tmp}        mz.get_vm_procedural_status           ${cu_vm}        MegaZ
    \                   ${cloud_device_status_tmp}      mz.get_vm_cloud_device_status         ${cu_vm}        MegaZ
    \                   Log Many            ${cu_vm}    ${availability_status_tmp}      ${procedural_status_tmp}    ${cloud_device_status_tmp}


Check All VM Status
    [Documentation]                 Check all VM status
    ...                             TAF used taf.gnb.oam.mz_client 3.16.2
    [Arguments]                     ${avail_status}     ${procedural_status}                        ${cloud_device_status}
    :FOR      ${cu_vm}     IN      @{cu_vm_list}
    \         ${status_tmp}       mz.get_vm_availability_status         ${cu_vm}                    MegaZ
    \         Should Be Equal     ${status_tmp}      ${avail_status}             msg=${cu_vm} availability status is not ${avail_status}
    \         ${status_tmp}       mz.get_vm_procedural_status           ${cu_vm}                    MegaZ
    \         Should Be Equal     ${status_tmp}      ${procedural_status}        msg=${cu_vm} procedural status is not ${procedural_status}
    \         ${status_tmp}       mz.get_vm_cloud_device_status         ${cu_vm}                    MegaZ
    \         Should Be Equal     ${status_tmp}      ${cloud_device_status}      msg=${cu_vm} cloud device status is not ${cloud_device_status}


Check VM Status
    [Documentation]                 Check VM status
    ...                             TAF used taf.gnb.oam.mz_client 3.16.2
    [Arguments]                     ${cu_vm}     ${avail_status}     ${procedural_status}     ${cloud_device_status}
    ${status_tmp}                   mz.get_vm_availability_status         ${cu_vm}                    MegaZ
    Should Be Equal                 ${status_tmp}     ${avail_status}     msg=${cu_vm} availability status is not ${avail_status}


Get System Module Status
    [Documentation]                 Get System Module status - ASIK
    ...                             TAF used taf.gnb.oam.mz_client 3.16.2
    [Arguments]                     ${fsm_id}

    ${fsm_avail_status}             mz.get_fsm                        attribute=availabilityStatus        fsm_id=${fsm_id}    session=MegaZ
    ${fsm_procedural_status}        mz.get_fsm                        attribute=proceduralStatus          fsm_id=${fsm_id}    session=MegaZ
    ${fsm_operational_state}        mz.get_fsm                        attribute=operationalState          fsm_id=${fsm_id}    session=MegaZ
    ${fsm_port}                     mz.get_fsm                        attribute=port                      fsm_id=${fsm_id}    session=MegaZ
    ${fsm_ledStatus}                mz.get_fsm                        attribute=ledStatus                 fsm_id=${fsm_id}    session=MegaZ
    ${fsm_type}                     mz.get_fsm                        attribute=type                      fsm_id=${fsm_id}    session=MegaZ
    Log Many                        System Module Status :\n
    ...                             \t avail_status=${fsm_avail_status}\n
    ...                             \t procedural_status=${fsm_procedural_status}\n
    ...                             \t operational_state=${fsm_operational_state}\n
    ...                             \t port=${fsm_port}\n
    ...                             \t led_status=${fsm_ledStatus}\n
    ...                             \t type=${fsm_type}\n

Check System Module Status
    [Documentation]        Check System Module status - ASIK
    ...                    Could be improved with : fsm_port, fsm_ledStatus, fsm_type
    ...                    Improvement : fsm_id should be removed from argument and fill in automatically (whatever nb fsm in the TL)
    ...                    TAF used taf.gnb.oam.mz_client 3.16.2
    [Arguments]            ${fsm_id}       ${fsm_avail_status}     ${fsm_procedural_status}      ${fsm_operational_state}

    ${status_tmp}       mz.get_fsm          attribute=availabilityStatus    fsm_id=${fsm_id}   session=MegaZ
    Should Be Equal     ${status_tmp}       ${fsm_avail_status}             msg=System Module : availability status is not ${fsm_avail_status}
    ${status_tmp}       mz.get_fsm          attribute=proceduralStatus      fsm_id=${fsm_id}   session=MegaZ
    Should Be Equal     ${status_tmp}       ${fsm_procedural_status}        msg=System Module : procedural status is not ${fsm_procedural_status}
    ${status_tmp}       mz.get_fsm          attribute=operationalState      fsm_id=${fsm_id}   session=MegaZ
    Should Be Equal     ${status_tmp}       ${fsm_operational_state}        msg=System Module : operational status is not ${fsm_operational_state}


Get BroadBand Module Status
    [Documentation]                 Get BroadBand Module status
    ...                             TAF used taf.gnb.oam.mz_client 3.16.2
    [Arguments]                     ${fbb_id}

    ${fbb_avail_status}             mz.get_fbb                        attribute=availabilityStatus        fbb_id=${fbb_id}    session=MegaZ
    ${fbb_procedural_status}        mz.get_fbb                        attribute=proceduralStatus          fbb_id=${fbb_id}    session=MegaZ
    ${fbb_operational_state}        mz.get_fbb                        attribute=operationalState          fbb_id=${fbb_id}    session=MegaZ
    ${fbb_ledStatus}                mz.get_fbb                        attribute=ledStatus                 fbb_id=${fbb_id}    session=MegaZ
    Log Many                        BroadBand Module Status :\n
    ...                             \t avail_status=${fbb_avail_status}\n
    ...                             \t procedural_status=${fbb_procedural_status}\n
    ...                             \t operational_state=${fbb_operational_state}\n
    ...                             \t led_status=${fbb_ledStatus}\n

Check BroadBand Module Status
    [Documentation]        Check BroadBand Module status
    ...                    Improvement : fbb_id should be removed from argument and fill in automatically (whatever nb fbb in the TL)
    ...                    TAF used taf.gnb.oam.mz_client 3.16.2
    [Arguments]            ${fbb_id}    ${fbb_avail_status}    ${fbb_procedural_status}    ${fbb_operational_state}    ${fbb_ledStatus}

    ${status_tmp}           mz.get_fbb      attribute=availabilityStatus        fbb_id=${fbb_id}    session=MegaZ
    Should Be Equal         ${status_tmp}   ${fbb_avail_status}   msg=BroadBand Module : availability status is not ${fbb_avail_status}
    ${status_tmp}           mz.get_fbb      attribute=proceduralStatus          fbb_id=${fbb_id}    session=MegaZ
    Should Be Equal         ${status_tmp}   ${fbb_procedural_status}    msg=BroadBand Module : procedural status is not ${fbb_procedural_status}
    ${status_tmp}           mz.get_fbb      attribute=operationalState          fbb_id=${fbb_id}    session=MegaZ
    Should Be Equal         ${status_tmp}   ${fbb_operational_state}    msg=BroadBand Module : operational state is not ${fbb_operational_state}
    ${status_tmp}           mz.get_fbb      attribute=ledStatus                 fbb_id=${fbb_id}    session=MegaZ
    Should Be Equal As Integers     ${status_tmp}    ${fbb_ledStatus}       msg=BroadBand Module : led status is not ${fbb_ledStatus}


Get BroadBand Fsp Module Status
    [Documentation]                 Get BroadBand SFP Module status
    ...                             TAF used taf.gnb.oam.mz_client 3.16.2
    [Arguments]                     ${fbb_id}

    ${fsp_avail_status}             mz.get_broadband_fsp              attribute=availabilityStatus        fbb_id=${fbb_id}    session=MegaZ
    ${fsp_procedural_status}        mz.get_broadband_fsp              attribute=proceduralStatus          fbb_id=${fbb_id}    session=MegaZ
    ${fsp_operational_state}        mz.get_broadband_fsp              attribute=operationalState          fbb_id=${fbb_id}    session=MegaZ
    ${fsp_sensors_info}             mz.get_broadband_fsp              attribute=sensors                   fbb_id=${fbb_id}    session=MegaZ
    Log Many                        BroadBand Fsp Module Status :\n
    ...                             \t avail_status=${fsp_avail_status}\n
    ...                             \t procedural_status=${fsp_procedural_status}\n
    ...                             \t operational_state=${fsp_operational_state}\n
    ...                             \t sensors=${fsp_sensors_info}\n
    # To see all information returned by this command
    &{fsp_info}                     mz.get_broadband_fsp        fbb_id=${fbb_id}    session=MegaZ
    Log                             BroadBand Fsp Module Status :\n &{fsp_info}


Check BroadBand Fsp Module Status
    [Documentation]                 Check BroadBand SFP Module status
    ...                             TAF used taf.gnb.oam.mz_client 3.16.2
    [Arguments]                     ${fbb_id}       ${fsp_avail_status}     ${fsp_procedural_status}      ${fsp_operational_state}

    ${status_tmp}      mz.get_broadband_fsp     attribute=availabilityStatus    fbb_id=${fbb_id}    session=MegaZ
    Should Be Equal    ${status_tmp}     ${fsp_avail_status}        msg=BroadBand Fsp Module : availability status is not ${fsp_avail_status}
    ${status_tmp}      mz.get_broadband_fsp     attribute=proceduralStatus      fbb_id=${fbb_id}    session=MegaZ
    Should Be Equal    ${status_tmp}     ${fsp_procedural_status}   msg=BroadBand Fsp Module : procedural status is not ${fsp_procedural_status}
    ${status_tmp}      mz.get_broadband_fsp     attribute=operationalState      fbb_id=${fbb_id}    session=MegaZ
    Should Be Equal    ${status_tmp}   ${fsp_operational_state}   msg=BroadBand Fsp Module : operational state is not ${fsp_operational_state}


Get Antenna Info
    [Documentation]                 Get Antenna information
    ...                             TAF used taf.gnb.oam.mz_client 3.16.2

    &{antenna_info}                 mz.get_antennas                   session=MegaZ
    Log                             Antenna info :\n&{antenna_info}

Get Gps Status
    [Documentation]                 Get Gps Status
    ...                             TAF used taf.gnb.oam.mz_client 3.16.2

    ${gps_status}                   mz.get_gps_status                  session=MegaZ
    Log                             Gps status : ${gps_status}

Check Gps Status
    [Documentation]                 Check Gps Status
    ...                             TAF used taf.gnb.oam.mz_client 3.16.2
    [Arguments]                     ${expected_gps_status}

    ${status_tmp}                   mz.get_gps_status     session=MegaZ
    Should Be Equal                 ${status_tmp}      ${expected_gps_status}            msg=Gps Status is not ${expected_gps_status}


Get Rap Infos
    [Documentation]                 Get Rap Infos
    ...                             Returns infos passivePackage, fronthaulCplaneIpAddress, hostname, syscomPort, planningStatus, faults ...
    ...                             TAF used taf.gnb.oam.mz_client 3.16.2
    [Arguments]                     ${rap_id}=1

    &{rap_infos}                    mz.get_rap_interface                session=MegaZ
    Log                             RAP Interface Infos : \n &{rap_infos}
    ${rap_status}                   mz.get_rap_status                   ${rap_id}                         session=MegaZ
    Log                             RAP Status : \n ${rap_status}


Check Rap Status
    [Documentation]                 Check Rap Status
    ...                             TAF used taf.gnb.oam.mz_client 3.16.2
    [Arguments]                     ${expected_rap_status}                   ${rap_id}=1

    ${status_tmp}                   mz.get_rap_status      ${rap_id}                          session=MegaZ
    Should Be Equal                 ${status_tmp}          ${expected_rap_status}             msg=Rap Status is not ${expected_rap_status}

Get Radio Module Status
    [Documentation]                 Get Radio Module status
    ...                             TBCompleted with FrequencyBand ...
    ...                             TAF used taf.gnb.oam.mz_client 3.16.2


    ${frm_avail_status}             mz.get_frm                        attribute=availabilityStatus        session=MegaZ
    ${frm_procedural_status}        mz.get_frm                        attribute=proceduralStatus          session=MegaZ
    ${frm_operational_state}        mz.get_frm                        attribute=operationalState          session=MegaZ
    # ${frm_freqBand}                 mz.get_frm                        attribute=frequencyBand             session=MegaZ
    Log Many                        Radio Module Status :\n
    ...                             \t avail_status=${frm_avail_status}\n
    ...                             \t procedural_status=${frm_procedural_status}\n
    ...                             \t operational_state=${frm_operational_state}\n
    # ...                             \t frequencyBand=${frm_freqBand}\n

Check Radio Module Status
    [Documentation]       Check Radio Module status
    ...                   TAF used taf.gnb.oam.mz_client 3.16.2
    [Arguments]           ${frm_avail_status}     ${frm_procedural_status}        ${frm_operational_state}

    ${status_tmp}         mz.get_frm       attribute=availabilityStatus        session=MegaZ
    Should Be Equal       ${status_tmp}    ${frm_avail_status}   msg=Radio Module: availability status is not ${frm_avail_status}
    ${status_tmp}         mz.get_frm       attribute=proceduralStatus          session=MegaZ
    Should Be Equal       ${status_tmp}    ${frm_procedural_status}   msg=Radio Module: procedural status is not ${frm_procedural_status}
    ${status_tmp}         mz.get_frm       attribute=operationalState          session=MegaZ
    Should Be Equal       ${status_tmp}    ${frm_operational_state}   msg=Radio Module: operational state is not ${frm_operational_state}
    # ${frm_freqBand}      mz.get_frm                        attribute=frequencyBand             session=MegaZ

Get Detected Hw
    [Documentation]                 Get detected Hw. Returns a dictionnary
    ...                             detected_hw_list with vendor type, serial number and board type...
    ...                             TAF used taf.gnb.oam.mz_client 3.16.2

    #[Tags]                          EricVG          Tested

    &{detected_hw_list}             mz.get_detected_hw                session=MegaZ
    Log Many                        detected_hw_list = &{detected_hw_list}
    ${detected_ABIL}                mz.get_detected_hw                inventoryUnitType=ABIL              session=MegaZ
    Log Many                        Detected ABIL  ${detected_ABIL}
    ${ABIL_info}                    collections.get from dictionary         ${detected_ABIL}                    102
    Log Many                        ABIL Info  ${ABIL_info}


Get CellId Status
    [Documentation]                 Get CellId status
    ...                             Id from [1 .. 8]
    ...                             TAF used taf.gnb.oam.mz_client 4.0.0
    #[Tags]                          EricVG          Tested
    [Arguments]                     ${cellId}
    ${cellId_Status}                mz.get_cell_status    number=${cellId}   session=MegaZ
    Log Many                        Cell ${cellId} Status is : ${cellId_Status}\n

Check CellId Status
    [Documentation]                 Check Cell Id status is online/offline
    ...                             Id from [1 .. 8]
    ...                             TAF used taf.gnb.oam.mz_client 4.0.0
    #[Tags]                          EricVG          Tested
    [Arguments]                     ${cellId}=1       ${CellId_status}=online
    ${cellId_Status_tmp}            mz.get_cell_status    number=${cellId}    session=MegaZ
    Should Be Equal                 ${cellId_Status_tmp}     ${CellId_status}    msg=Cell ${cellId} Status is not ${CellId_status}

Check S1-U Connectivity
    [Documentation]                 Check  S1-U Connectivity from UEUP VM to S1U_SGW_itf
    ...                             In 5G18A (NSA mode), the S1-C is managed at eNB side, so the S1 Megazone.client keywords are not available
    ...                             WA : Check the S1-U SGW ip @ is reachable from UEUP VM
    ...                             By default, 9 ping are sent to S1-U SGW
    ...                             S1U_SGW_itf should be defined in tlconfig file
    ...                             TAF used taf.transport.ssh 4.0.0
    [Arguments]                     ${count}=9

    ssh.connect to                  upue-0.local    robot       rastre1     proxy=${oam_alias}       alias=upueVM
    ${ping_result}                  ssh.execute     ping -c ${count} ${S1U_SGW_itf}                 connection=upueVM
    Log Many                        Ping Result = \n${ping_result}\n
    Should Match Regexp             ${ping_result}              packet loss
    ${notExpectedValue}             Catenate        100%        packet loss
    Log                             ${notExpectedValue}
    Should Not Match Regexp         ${ping_result}              ${notExpectedValue}

    # The command result could also be checked with the #packets received (see the 3 lines below)
    # But the above solution seems to be better !
    #${expectedValue}                Catenate        ${count}       received
    #Log                             ${expectedValue}
    #Should Match Regexp             ${ping_result}              ${expectedValue}


Get gNB Status
    [Documentation]                 Get the gNB status :
    ...                                 SW version
    ...                                 Detected HW ? Not linked to eNB status. Should be removed !!!
    ...                                 Antenna info
    ...                                 Gps Status
    ...                                 Rap Status
    ...                                 Get VM Status
    ...                                 radio module (get_frm)
    ...                                 system module (get_fsm)
    ...                                 broadband (get_fbb)
    ...                                 get_broadband_fsp
    ...                                 CellId status (Id = 1..8)
    ...                                 To be completed with :
    ...                                     real time module get_rtm
    ...                                     S1, X2, F1 link
    ...                                     ...

    #[Tags]                          EricVG          Tested

    Get Software Version
    Get Detected Hw
    Get Antenna Info
    Get Gps Status
    Get Rap Infos
    Get All VM Status
    Get Radio Module Status
    Get System Module Status            1
    Get BroadBand Module Status         1
    Get BroadBand Fsp Module Status     1
    Get CellId Status                   1

    #:FOR                ${cellId}       IN RANGE    1   9   1
    #\                   Get CellId Status    ${cellId}

Check gNB Status
    [Documentation]                 Check the gNB status :
    ...                                 Gps Status
    ...                                 Rap Status
    ...                                 VM Status
    ...                                 radio module (get_frm)
    ...                                 system module (get_fsm)
    ...                                 broadband (get_fbb)
    ...                                 get_broadband_fsp
    ...                                 Cells Status (Cell1 = online, cell 2..8 = offline)
    ...                                 To be completed with :
    ...                                     real time module get_rtm
    ...                                     X2, F1 link
    ...                                     ...
    ...                              Update: 20181119 EricBP - get gNB status call incleded within the keyword.
    #[Tags]                          EricVG          Tested
    Get gNB Status
    Check Gps Status                           inUse
#                                           avail_status        procedural_status           cloud_device_status/operationalState
    Check Rap Status                           online
    Check All VM Status                        online                configured                 configured
    Check Radio Module Status                  online                configured                 enabled
    Check System Module Status          1      online                configured                 enabled
    Check BroadBand Module Status       1      online                configured                 enabled                 2
    Check BroadBand Fsp Module Status   1      online                configured                 enabled
    Check CellId Status                 1      online

    #:FOR                ${cellId}       IN RANGE    2   9   1
    #\                   Check CellId Status    ${cellId}       offline

    Check S1-U Connectivity

Get alarm list
    [Arguments]                ${target_path}
    [Documentation]
    ...                 collect the alarms list into megazone and write all the alarms into a file which has the patch given in argument
    ...                 return: a list including the alarms colelcted into the megazone
    ...                 TAF used: gnb.oam.megazone

    @{alarm_list}     run keyword if      '${oam_type}' == 'MZ'       mz.get active alarms    MegaZ
    ...   ELSE IF      '${oam_type}' == 'COAM'      coam.get active alarms  connection=coamCnx
    log many                    @{alarm_list}
    :FOR              ${alarm}     IN     @{alarm_list}
    \                           ${alarm}             convert to string     ${alarm}
    \                           append to file      ${target_path}     ${alarm}\n
    [return]                    @{alarm_list}

Check specific alarm
    [Arguments]         ${alarm_text}   ${present}=0
    [Documentation]         check that alarm is still raised or not, with a text part as reported in WebUI.
    ...                     Author: Denis Verdier
    ...                     Update EricBP 20181206
    @{alarm_list}     run keyword if      '${oam_type}' == 'MZ'       mz.get active alarms    MegaZ
    ...   ELSE IF      '${oam_type}' == 'COAM'      coam.get active alarms  connection=coamCnx
    log many                    @{alarm_list}
    @{alarm_list_values}        Collections.get dictionary values   @{alarm_list}
    Run Keyword if     ${present}==0      Collections.Should Not Contain Match   ${alarm_list_values}    ${alarm_text}   case_insensitive=True
    ...                ELSE               Collections.Should Contain Match       ${alarm_list_values}    ${alarm_text}   case_insensitive=True

Check cell setup starts on CPIF
    [Arguments]         ${session}
    [Documentation]     Performs a grep on CPIF journalctl, checking if F1 link setup has started ("Received CpIfDeploymentCompleteInd" msg)
    ...                 CPIF connection is needed
    ...                 TAF used: transport.ssh version 3.3.1
    ${f1_start} =       ssh.execute     sudo journalctl -b -u cp_if | grep "Received CpIfDeploymentCompleteInd"     connection=${session}
    should contain      ${f1_start}     Received CpIfDeploymentCompleteInd


Check active Software Version number
    [Documentation]    ...
    ...                gNB compatibility: CLOUD and CLASSICAL.
    ...                Author: Jacob Velasco - 20191010
    run keyword if     '${GNB_Architecture}' == 'CLOUD'
    ...                gnbStatus.Check active Software Version number Cloud
    run keyword if     '${GNB_Architecture}' == 'CLASSICAL'
    ...                gnbStatus.Check active Software Version number Classical

Check active Software Version number Cloud
    ${sw_d}=     mz.get sw version      MegaZ
    Log many       ${sw_d}
    set suite variable        ${sw_d}

Check active Software Version number Classical
    [Documentation]    ...
    ...                20200528: Update Fabienne Magueur: add timeout and connection name
    ${sw_d}=     coam.get sw version    10 sec     coamCnx
    Log many       ${sw_d}
    set suite variable        ${sw_d}

Verify Carrier visibility
    [Documentation]    This keyword verify the activation of carriers in ASIK NODEOAM log
    ...                It connect to ASIK and verify the exchange of message between CPRT,NODEOAM and RFSW
    ...                NODEOAM receive the message Antenna carrier activation req from CPRT
    ...                NODEOAM send the request to RFSW and receive the response
    ...                NODEOAM respond to the CPRT with Antenna carrier activation resp including the status
    ...                How it woks:
    ...                       . open an asik ssh Connection
    ...                       . A predefined list of elements and expected keys must be provided to be checked in the
    ...                         startup_NODEOAM.log --> @{log_to_check} & @{expected_res}
    ...                       . Keyword "Log Checker Online" is then used to assert the presence of elements and keys
    ...                       . TAF used: taf.ul.ssh_addons   WITH NAME   common_ssh_addons version 1.0.0

    #Asik Connection
    # @{log_to_check}: element for grep command
    @{log_to_check}    Create List        CPRT_CM_ANTENNA_CARRIER_ACTIVATION_REQ_MSG
        ...                               sending CPRT_CM_ANTENNA_CARRIER_ACTIVATION_RESP_MSG
        ...                               (CPRT_CM_ANTENNA_CARRIER_ACTIVATION_RESP_MSG):
        #...                               EVENTS:emit: /mz/p/v1/pbts/1/fsm/1/localCellDu/1 operationalState:
        #...                              Sending carrier activation to radio
    #@{expected_res}:  keys that should be contained in the grep result
    @{expected_res}    Create List        CPRT_CM_ANTENNA_CARRIER_ACTIVATION_REQ_MSG
        ...                               true
        ...                               "status":0
        #...                              enabled;
        #...                              Sending carrier activation to radio
    basics.Log Checker Online
        ...                              expected_log=${log_to_check}
        ...                              expected_res=${expected_res}
        ...                              connection=asikcnx
        ...                              log_path=${AsikNODEOAMLOGPATH}
        ...                              timeout=120 s
   	#Asik Disconnection



TBD Check carrier activation for cell setup
    [Documentation]          Carrier Activation msg in Startup default file
    #[Teardown]               ssh.disconnect           asikCheckCarrier
    run keyword if      '${GNB_Architecture}' == 'CLOUD'
    ...                 ssh.connect to      ${asik_fh}          ${asik_fh_login}	    ${asik_fh_password}
    ...                 proxy=${oam_alias}      alias=asikCheckCarrier
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL'
    ...                 ssh.connect to      ${oam_vm}           ${oam_vm_login}         ${oam_vm_password}
    ...                 alias=asikCheckCarrier
    ${file}=        ssh.execute   ls /tmp/startup_DEFAULT.log*      connection=asikCheckCarrier
    ${status}=       run keyword and return status   Should Contain      ${file}       xz
    ${status}=       run keyword if  ${status}
    ...  ssh.execute   xzgrep CPRT_CM_ANTENNA_CARRIER_ACTIVATION_RESP_MSG /tmp/startup_DEFAULT.log.xz    connection=asikCheckCarrier
    ...  ELSE   ssh.execute   grep CPRT_CM_ANTENNA_CARRIER_ACTIVATION_RESP_MSG /tmp/startup_DEFAULT.log    connection=asikCheckCarrier
    Should Contain      ${status}     CPRT_CM_ANTENNA_CARRIER_ACTIVATION_RESP_MSG

Check carrier activation for cell setup
    [Documentation]    Carrier Activation msg in Startup default file
    ...                gNB compatibility: CLOUD and CLASSICAL
    ...                OAM compatibility: MzOAM and cOAM
    ...                Update: Stephane Croquet - 20190731
    ...                Add OAM compatibilty
    run keyword if      '${oam_type}' == 'MZ'
    ...                 Check carrier activation for cell setup MzOAM
    run keyword if      '${oam_type}' == 'COAM'
# 2019-11-16
# Eric VG
    ...                 Check Cell Availability Status V2
#    ...                 Check carrier activation for cell setup cOAM

Check carrier activation for cell setup MzOAM
    [Documentation]    Carrier Activation msg in Startup default file for MzOAM
    ...                Author: Stephane Croquet - 20190731
    run keyword if      '${GNB_Architecture}' == 'CLOUD'
    ...                 ssh.connect to      ${asik_fh}          ${asik_fh_login}	    ${asik_fh_password}
    ...                 proxy=${oam_alias}      alias=asikCheckCarrier
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL'
    ...                 ssh.connect to      ${oam_vm}           ${oam_vm_login}         ${oam_vm_password}
    ...                 alias=asikCheckCarrier
    ${cmd1}=    catenate  xzgrep CPRT_CM_ANTENNA_CARRIER_ACTIVATION_RESP_MSG /tmp/startup_DEFAULT.log.xz
    ${cmd2}=    catenate  grep CPRT_CM_ANTENNA_CARRIER_ACTIVATION_RESP_MSG /tmp/startup_DEFAULT.log
    ${file}=    ssh.execute   ls /tmp/startup_DEFAULT.log*      connection=asikCheckCarrier
    ${status}=  run keyword and return status   Should Contain      ${file}       xz
    ${status}=  run keyword if  ${status}
    ...  ssh.execute  ${cmd1}   connection=asikCheckCarrier
    ...  ELSE   ssh.execute    ${cmd2}  connection=asikCheckCarrier
    Should Contain    ${status}     CPRT_CM_ANTENNA_CARRIER_ACTIVATION_RESP_MSG

#Check carrier activation for cell setup cOAM
#    [Documentation]    Carrier Activation msg in Startup default file for cOAM
#    ...                Author: Stephane Croquet - 20190731
#    ssh.connect to   ${asik_slave}    ${asik_fh_login}	 ${asik_fh_password}   proxy=asikFhCnx  alias=asikSlaveCarrier
#    ${cmd1}=    catenate  xzgrep GnbCuConfigurationUpdateAck /ffs/run/logs/0xe005_aasyslog/startup_cp_rt.log.xz
#    ${cmd2}=    catenate  xzgrep GnbCuConfigurationUpdateAck /ffs/run/logs/0xe005_aasyslog/startup_cp_rt.log
#    ${file}=    ssh.execute   ls /ffs/run/logs/0xe005_aasyslog/startup_cp_rt.log*      connection=asikSlaveCarrier
#    ${status}=  run keyword and return status   Should Contain      ${file}       xz
#    ${status}=  run keyword if  ${status}
#    ...  ssh.execute   ${cmd1}  connection=asikSlaveCarrier
#    ...  ELSE   ssh.execute      ${cmd2}    connection=asikSlaveCarrier
#    Should Contain     ${status}     GnbCuConfigurationUpdateAck

Check Cell radiation
    [Documentation]
    ...                     check on DL CPRI samples, there are non zero sample as for 1 SSB in 10ms at least: 2192 samples in mmWv
    ...                     Then, same check on JESD capture.
    ...                     Not cmWv compliant
    ...                     Author: EricBP
    ...                     Dependancy: myLib_maths.py, logs.robot
    ...                     Update 20181109: call to get RU asik IP adresse removed
    ...                     Update 20181113: result criteria update: change to get > or = to 2192 sample.
    logs.Get RU DDR4                 CPRI_DL0    CPRI_DL0.hex
    logs.Get RU DDR4                 JESD_DL_ANT0    JESD_DL_ANT0.hex
    ${local_path}               join path   ${logs_path}     RU
    ${tmp_path}                 join path   ${local_path}     CPRI_DL0.hex
    ${output}                   run         cat ${tmp_path} | grep -v 0x00000000 -c
    ${output}                   myLib_maths.comparison      ${output}   2192  >=
    should be true              ${output}   there are less non zero samples than 1 SSB required at CPRI side
    ${tmp_path}                 join path   ${local_path}     JESD_DL0_ANT0.hex
    ${output}                   run         cat ${tmp_path} | grep -v 0x00000000 -c
    ${output}                   myLib_maths.comparison      ${output}   2192  >=
    should be true              ${output}   there are less non zero samples than 1 SSB required at JESD side

Check Cell Availability Status V2
    [Documentation]    20200528: Update Fabienne Magueur: parameter for coam.get_subcells_status
    ...                20220110: Update Abderrahmane NEZROUK : parametet coam.get_cells_info for all cells
    ...                20220127  Update Abderrahmane NEZROUK : reworking in case AVailabilityStatus element present or not
    #${status}       run keyword  coam.get_subcells_status    10    coamCnx
    # ${value}        set variable   ${status['NRCELLGRP-0']['NRCELL-1']['NRCELL_R']['availabilityStatus']} ==> depricated
    # Should Contain     ${value}     Online

    # ${cells}       run keyword  coam.get_cells_info    timeout=10    connection=coamCnx
    # FOR    ${cell}    IN     @{cells}
    #      Should not Contain    ${cell['status']}    availabilityStatus
    # END

    # 20220127  Update Abderrahmane NEZROUK rework
    ${cells}       run keyword  coam.get_cells_info    timeout=10    connection=coamCnx
    FOR    ${cell}    IN     @{cells}
        ${stateInfo}=  run keyword and return status  dictionary should contain key  ${cell['status']}  AvalalibiltyStatus
        Run keyword if  ${stateInfo}  Should Be Equal As Strings  ${cell['status']["availabilityStatus"]}  Online  ignore_case=True
    END

Check Cell Setup On CPCL
    [Documentation]         Check configuration update Ack
    ...                     gNB compatibility: CLOUD and CLASSICAL.
    ...                     Author: Stephane Croquet - 20190425
    run keyword if          '${GNB_Architecture}' == 'CLASSICAL'
    ...                     Check Cell Setup on CPCL Classical

Check Cell Setup On CPCL Classical
    [Documentation]          Check cell activation status in cpcl trace

    ${5G_Release_major}    String.Get substring    ${5GRelease}   2    4
    ${5G_Release_major_int}    BuiltIn.Convert to integer    ${5G_Release_major}

    ${match}    ${value}    Run keyword and ignore error    Should be true    ${5G_Release_major_int} > 20
    Run keyword if    '${match}' == 'PASS'    Check Cell Setup On CPCL Classical 21A
    ...    ELSE    Check Cell Setup On CPCL Classical 19B


Check Cell Setup On CPCL Classical 19B
    [Documentation]          Check cell activation status in cpcl trace

    configuration.Create ssh
    ${status} =              ssh.execute   grep "finished cell activation" /tmp/node_0xe002/tmp/startup_cp_cl.log   connection=asikFhCnx
    Should Contain           ${status}     Failed to activate cells: []
    Log    ${MASTER_CELL_ID}
    Should Match Regexp       ${status}     Activated cells: \\[NRCellIdentity: <LOG_SCRAM_\\d{2}>${MASTER_CELL_ID}<.{1,2}LOG_SCRAM_\\d{2}>\\]

Check Cell Setup On CPCL Classical 21A
    [Documentation]          Check cell activation status in cpcl trace

    configuration.Create ssh
    ${status}                   ssh.execute     ls -lrt /ram/node_CPCL00/tmp/startup_cp_cl.log
    ...                         connection=asikFhCnx    timeout=10 s
    ${info}                     Set Variable    No such file or directory
    ${match}     ${value}       Run Keyword And Ignore Error    Should Contain     ${status}     ${info}
    ${startup_cp_cl}          Run Keyword If  '${match}'=='PASS'    Set variable    /ffs/run/logs/CPCL00_aasyslog/startup_cp_cl.log.xz
    ...                         ELSE                                  Set variable    /ram/node_CPCL00/tmp/startup_cp_cl.log

    ${check_cell_activation}         ssh.execute     xzgrep "finished cell activation" ${startup_cp_cl}    connection=asikFhCnx    timeout=10 s
    log                         ${check_cell_activation}

    Should Contain           ${check_cell_activation}     Failed to activate cells: []
    Log    ${MASTER_CELL_ID}
    Should Match Regexp       ${check_cell_activation}     Activated cells: \\[NRCellIdentity: ${MASTER_CELL_ID}\\]
    Run keyword and ignore error    configuration.Close Connections SSH

Alarm initial status
    [Tags]              test
    ${target_path}              joinpath        ${res_path}     Alarm/Alarm_init.txt
    create file                 ${target_path}
    ${alarm_init_list}          gnbStatus.get alarm list            ${target_path}
    set suite variable          ${alarm_init_list}

Alarm final status
    [Tags]              test	SCF	Checks
    ${target_path}              joinpath        ${res_path}     Alarm/Alarm_final.txt
    create file                 ${target_path}
    ${alarm_final_list}         gnbStatus.get alarm list            ${target_path}
    Run Keyword and Return Status      lists should be equal       ${alarm_init_list}   ${alarm_final_list}
    ...         if difference in the lists = alarms have been raised during the test

Get gNB Current Utc Time
    [Documentation]  This keyword return current time from gNB
    ...              Author: Abderrahmane NEZROUK
    [Arguments]     ${connection}=asikFhCnx
    ${current_time}=    ssh.execute    date -u +"%Y-%m-%d %H:%M:%S%z"    connection=${connection}
    log             gNB current time:${current_time}
    [Return]    ${current_time}

Get gNB Current Utc Time with Added Pm Periods
    [Documentation]  This keyword return in seconds the current time from gNB with added a number of periods times
    ...              Author: Abderrahmane NEZROUK
    [Arguments]    ${number_pm_period}    ${connection}=asikFhCnx
    ${curr_sec_str}=    ssh.execute    date -u +"%s"    connection=asikFhCnx
    ${curr_sec}=    Convert To Integer    ${curr_sec_str}
    Log    ${curr_sec_str}
    ${number_pm_period} =    Convert To Integer    ${number_pm_period}
    Log    ${number_pm_period}
    ${final_sec}=    Evaluate    ${curr_sec}+${pm_min_period}*${number_pm_period}*60
    ${final_sec}=    Convert Date    ${final_sec}    result_format=%Y-%m-%dT%H:%M    date_format=%s
    log    ${final_sec}
    [Return]    ${final_sec}

Clean PMCounter Temps Files
    [Documentation]  This keyword clean PMCounter logs
    ...              Author: Abderrahmane NEZROUK
    [Arguments]     ${connection}=asikFhCnx
    ${outcome}    ssh.execute     ls -lrt /mnt/services/mzoam/config/5G*/pm/reports/|head -2| awk '{print $9}'
    ...           connection=${connection}
    ${outcome}    Strip String    ${outcome}
    ssh.send command    cd /mnt/services/mzoam/config/5G*/pm/reports/;ls |grep -v ${outcome} |xargs rm -f
    ...           connection=${connection}
    log             gNB PMCounter logs cleaned
