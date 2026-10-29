# Keywords used for robot scripts of feature 5GC002060

*** Variables ***

*** Settings ***
Documentation
...             Usefull keywords for 5GC002060 management
Library     taf.rfrl.common_resources.python.check_cap.CapPacket    WITH NAME   cap
Library         BuiltIn
Library         OperatingSystem
Library         Collections
Library         String
Library         XML
Library         ArchiveLibrary
Library         taf.sbts.oam.coam.admin      WITH NAME       coam
Library         taf.collectors.core         WITH NAME       mycore
Library         taf.transport.ssh           WITH NAME       myssh
Library         taf.collectors.tcpdump      WITH NAME       mytcpdump
Library         taf.config.scf              WITH NAME       scf
Library         list_gNodeB_alarms.py
Variables    taf/rfrl/common_resources/python/dynamic_import_selenium.py
Library      taf.rfrl.common_resources.python.dynamic_import_selenium.selenium_coam    WITH NAME   selenium_coam
Library         Downloadluashark.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource      testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008196_B_TDD_ST/Resource/COAM.robot
*** Variables ***

${GN_OAM_ADDR}=      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ASIK_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ASIK_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${Log_directory}            /home/ute/robot_temporary/2060_script
${hw_type}          ${tl.tl_cloud_topology.split('_')[4]}

*** Keywords ***

Do Attach UE
    [Arguments]    ${ue_type}=huawei    ${attach_mode}=5G_NSA    ${5Gstatus}=PASS    ${ue_index}=${0}
    Run Keyword And Ignore Error    Do Detach UE     
    Log to console         UE Attached
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    log_type=Aasyslog
    ...    attach_mode=${attach_mode}
    ${power_status}    Run Keyword And Return Status  power_ue.Verify attach    ue_type=${ue_type}
    ...    5Grach_ed=${5Grach_ed}     5Gstatus=${5Gstatus}    ue_index=${ue_index}
    Run Keyword If   ${power_status} ==False and '${attach_mode}'=='5G_NSA'  Wait Until Keyword Succeeds  3x  10s  Verify attach by adb
    ...   ue_index=${ue_index}
    Run Keyword If   ${power_status} ==False and '${attach_mode}'=='5G_SA'  Wait Until Keyword Succeeds  3x  10s  Verify attach by adb
    ...   ue_index=${ue_index}    attach_mode=5G_SA


Verify attach by adb
    [Arguments]    ${ue_index}=${0}    ${sleep_time_before_read_output}=5s
    ...   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...   ${attach_mode}=5G_NSA
    Connect to control pc enhanced    ${ue_index}
    csn.send command
    ...    command=adb -s ${serial_number} shell dumpsys telephony.registry
    ...    connection=cpc_${ue_index}
    ...    timeout=15
    run keyword if    '${sleep_time_before_read_output}'!='${None}'    BuiltIn.sleep    ${sleep_time_before_read_output}
    ${result} =    csn.read output    connection=cpc_${ue_index}
    Run Keyword If   '${attach_mode}' == '5G_NSA'    Should contain  ${result}    accessNetworkTechnology=LTE
    Run Keyword If   '${attach_mode}' == '5G_NSA'    Should contain  ${result}    nrState=CONNECTED
    Should contain  ${result}    mDataRegState=0
    Run Keyword If   '${attach_mode}' == '5G_NSA'    Log to console    \nINFO:UE ATTACH NSA successfully.
    Run Keyword If   '${attach_mode}' == '5G_SA'    Should contain  ${result}    accessNetworkTechnology=NR
    # Run Keyword If   '${attach_mode}' == '5G_SA'    Should contain  ${result}    mPci = ${physCellId}      
    Run Keyword If   '${attach_mode}' == '5G_SA'    Log to console    \nINFO:UE ATTACH SA successfully.
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=cpc_${ue_index}

Do Detach UE
    power_ue.UE Detach    ue_type=huawei    
    Log         UE Detached

Check if gNB is OnAir GUI
    coam_gnb_classical.COAM Check GNB cell on air    connection=GNB_OAM    

check value in scf by dist_name
  [Arguments]           ${Dist_Name}      ${Parameter_Name}      ${Parameter_Value}
  Log    \nChecking feature parameter dist_name=${Dist_Name}, ${Parameter_Name} is equal to ${Parameter_Value}
  ${val}=               scf.get_value_from_scf      dist_name=${Dist_Name}     p_name=${Parameter_Name}
  Log                   ${Parameter_Name} = ${val}
  Should be equal       ${val}                      ${Parameter_Value}

get and validate scf file
  [Arguments]           ${SCF_Filename}
  Log                   \nGet scf file ${SCF_Filename} and copy it to ${Log_directory}
  OperatingSystem.Create Directory    ${Log_directory}     
  coam.get_current_scf_file    ${Log_directory}     ${SCF_Filename}    connection=GNB_OAM
  scf.load_scf          ${Log_directory}/${SCF_Filename}
  ${result}=            coam.validate_scf                ${Log_directory}/${SCF_Filename}    connection=GNB_OAM
  Log                   Validation result = ${result}
  [return]              ${result}

get value in scf by dist_name
  [Arguments]           ${Dist_Name}      ${Parameter_Name}
  Log                   \nGet initial feature parameter value of dist_name=${Dist_Name}, p_name=${Parameter_Name}
  ${val}=               scf.get_value_from_scf      dist_name=${Dist_Name}            p_name=${Parameter_Name}
  Log                   ${Parameter_Name}=${val}

list active alarms
  [Tags]                alarms
  ${alarm_result}=      coam.get_active_alarms    connection=GNB_OAM
  Log                   List of alarms=${alarm_result}
  ${faulty_result}=     list_alarms           ${alarm_result}
  Run keyword if        ${faulty_result}==${True}        Log       Major or critical alarm present
  Should not be True    ${faulty_result}      ${False}

modify value in scf by dist_name
  [Arguments]           ${Dist_Name}      ${Parameter_Name}      ${Parameter_Value}      ${List_Name}=${None}
  scf.modify_scf_element    value=${Parameter_Value}             dist_name=${Dist_Name}    p_name=${Parameter_Name}
  ...    list_name=${List_Name}

scf uploading and commissioning
    [Tags]                          commissioning
    [Arguments]                     ${SCF_Filename}     ${tcpdumpguard}=${false}
    Log                             \nCommissioning gNodeB with ${Log_directory}/${SCF_Filename}
    coam_gnb_classical.COAM Commission with scf file    scf_file_path=${Log_directory}/${SCF_Filename}    
    ...    is_pdl_checking_needed=${False}    timeout=900
    wait until keyword succeeds    1200      30s    coam_gnb_classical.COAM Check GNB cell on air
    Run Keyword And Continue On Failure    Wait For Fault with Alarm to disappear    FaultID=7319
    Run Keyword And Continue On Failure    Wait For Fault with Alarm to disappear    FaultID=7300
#    Sleep    5mins   

validate modified values
  [Arguments]           ${SCF_Filename}
  Log                   \nSaving to ${Log_directory}/${SCF_Filename} and validating
  scf.save_scf          ${Log_directory}/${SCF_Filename}
  ${result}=            coam.validate_scf                ${Log_directory}/${SCF_Filename}    connection=GNB_OAM
  Log                   Validation result = ${result}
  [return]              ${result}

validate modified values with pdl error
  [Arguments]           ${SCF_Filename}
  Log                   \nSaving to ${Log_directory}/${SCF_Filename} and validating
  scf.save_scf          ${Log_directory}/${SCF_Filename}
  ${result}=            Run Keyword and Expect Error    *pdlValidationResult': {u'status': u'FAIL'*
  ...                   coam.validate_scf                ${Log_directory}/${SCF_Filename}    connection=GNB_OAM
  Log                   Validation result = ${result}
  [return]              ${result}

Get list of all cells
    ${cells}    coam.Get parameters for all    NRCEL    connection=GNB_OAM
    ${cells_id}    Create List
    #${cell}        Set Variable     ${EMPTY}
    FOR    ${cell}    IN    @{cells}
        ${cell_id}    Get From Dictionary    ${cell}    configurationId
        Append To List   ${cells_id}    NRCELL-${cell_id}
    END
    [Return]    ${cells_id}

Set 5G Load Version
    [Documentation]                    Extract the SW Version from WebEM
    set suite variable                 ${5GLoadVersion}    trunk
    ${swversion}=                      coam.get_sw_version    connection=GNB_OAM
    set suite variable                 ${swversion}
    Run Keyword if                     'SBTS' in '${swversion}'    set suite variable    ${5GLoadVersion}    trunk
    Run Keyword if                     '5G20B' in '${swversion}'    set suite variable    ${5GLoadVersion}    trunk
    Run Keyword if                     '5G21A' in '${swversion}'    set suite variable    ${5GLoadVersion}    trunk

Set edrx parameters standard
    [Arguments]     ${EDRXCONFIG}=DLC160        ${cells_id}=${empty}    ${cellgrps_id}=${empty}
    ${edrxcfg}      Get From Dictionary         ${params5GC002060}      ${EDRXCONFIG}
    log             ${edrxcfg}\n                #formatter=repr
    ${edrxnrcellcfg}    Get From Dictionary     ${edrxcfg}              NRCELL
    log             ${edrxnrcellcfg}\n          #formatter=repr
    ${edrxnrcgrpcfg}    Get From Dictionary     ${edrxcfg}              NRCELLGRP
    log             ${edrxnrcgrpcfg}\n          #formatter=repr
    FOR     ${CGRP}     IN      @{cellgrps_id}
        ${distname_grp}=    catenate     SEPARATOR=/    ${BTS_Path}        ${CGRP}
        ${edrxparam}        Get From Dictionary     ${edrxnrcgrpcfg}        csiReportPeriodicity
        Log    \nModifying in object ${distname_grp} :\nElement csiReportPeriodicity with value ${edrxparam}\n
        modify value in scf by dist_name    ${distname_grp}     csiReportPeriodicity    ${edrxparam}
    END
    FOR     ${CELL}     IN      @{cells_id}
        ${distname_grp}=    catenate     SEPARATOR=/    ${BTS_Path}        ${CELL}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        actCDrx
        modify value in scf by dist_name            ${distname_grp}         actCDrx                 ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxInactivityTimer
        modify value in scf by dist_name            ${distname_grp}         drxInactivityTimer      ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxLongCycle
        modify value in scf by dist_name            ${distname_grp}         drxLongCycle            ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxOnDurationTimer
        modify value in scf by dist_name            ${distname_grp}         drxOnDurationTimer      ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxRetransTimerDl
        modify value in scf by dist_name            ${distname_grp}         drxRetransTimerDl       ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxRetransTimerUl
        modify value in scf by dist_name            ${distname_grp}         drxRetransTimerUl       ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxWactDlEnabled
        modify value in scf by dist_name            ${distname_grp}         drxWactDlEnabled        ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxWactUlEnabled
        modify value in scf by dist_name            ${distname_grp}         drxWactUlEnabled        ${edrxparam}
    END

Set edrx parameters trunk
    [Arguments]     ${EDRXCONFIG}=DLC160        ${cells_id}=${empty}    ${cellgrps_id}=${empty}
    ${edrxcfg}      Get From Dictionary         ${params5GC002060}      ${EDRXCONFIG}
    log             ${edrxcfg}\n                #formatter=repr
    ${edrxnrcellcfg}    Get From Dictionary     ${edrxcfg}              NRCELL
    log             ${edrxnrcellcfg}\n          #formatter=repr
    ${edrxnrcgrpcfg}    Get From Dictionary     ${edrxcfg}              NRCELLGRP
    log             ${edrxnrcgrpcfg}\n          #formatter=repr
    ${edrxnrbtscfg}    Get From Dictionary     ${edrxcfg}               NRBTS
    log             ${edrxnrbtscfg}\n          #formatter=repr
    set test variable                 ${ListName}    drxProfile1

    FOR     ${CELL}     IN      @{cells_id}
        ${distname_grp}=    catenate     SEPARATOR=/    ${BTS_Path}        ${CELL}

        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        actTcpBoostPug
        ${result}    ${release}    Run Keyword And Ignore Error
        ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
        ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
        Run keyword If  '${release_sbts}'=='SBTS23R2' or '${release_sbts}'=='SBTS23R3'
        ...    Log To Console  no_need_modify_actTcpBoostPug
        ...    ELSE   modify value in scf by dist_name    ${distname_grp}    actTcpBoostPug   ${edrxparam}

        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        actCDrx
        modify value in scf by dist_name            ${distname_grp}         actCDrx                 ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxInactivityTimer
        modify value in scf by dist_name            ${distname_grp}         drxInactivityTimer      ${edrxparam}
        ...      ${ListName}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxLongCycle
        modify value in scf by dist_name            ${distname_grp}         drxLongCycle            ${edrxparam}
        ...      ${ListName}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxOnDurationTimer
        modify value in scf by dist_name            ${distname_grp}         drxOnDurationTimer      ${edrxparam}
        ...      ${ListName}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxRetransTimerDl
        modify value in scf by dist_name            ${distname_grp}         drxRetransTimerDl       ${edrxparam}
        ...      ${ListName}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxRetransTimerUl
        modify value in scf by dist_name            ${distname_grp}         drxRetransTimerUl       ${edrxparam}
        ...      ${ListName}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxWactDlEnabled
        modify value in scf by dist_name            ${distname_grp}         drxWactDlEnabled        ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxWactUlEnabled
        modify value in scf by dist_name            ${distname_grp}         drxWactUlEnabled        ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcgrpcfg}        csiReportPeriodicity
        Log    \nModifying in object ${distname_grp} :\nElement csiReportPeriodicity with value ${edrxparam}\n
        modify value in scf by dist_name 		    ${distname_grp}     	csiReportPeriodicity    ${edrxparam}
    END
    ${edrxparam}        Get From Dictionary     ${edrxnrbtscfg}        actDedicatedAnrDrxProfile
    modify value in scf by dist_name            ${BTS_Path}            actDedicatedAnrDrxProfile            ${edrxparam}
    ${edrxparam}        Get From Dictionary     ${edrxnrbtscfg}        actDisableUlProactGrantAnr
    modify value in scf by dist_name            ${BTS_Path}            actDisableUlProactGrantAnr           ${edrxparam}
    ${edrxparam}        Get From Dictionary     ${edrxnrbtscfg}        actNsaUeBasedAnrNr
    modify value in scf by dist_name            ${BTS_Path}            actNsaUeBasedAnrNr                   ${edrxparam}
    ${edrxparam}        Get From Dictionary     ${edrxnrbtscfg}        actSaUeBasedInterFreqAnrNr
    modify value in scf by dist_name            ${BTS_Path}            actSaUeBasedInterFreqAnrNr           ${edrxparam}

Attach UE and Verify DRx parameters
    [Arguments]         ${EDRXCONFIG}=DLC160        ${cells_id}=${empty}    ${cellgrps_id}=${empty}    
    ...    ${attach_mode}=5G_NSA 
    ${edrxcfgfull}      Get From Dictionary         ${params5GC002060}      ${EDRXCONFIG}
    log                 ${edrxcfgfull}\n            #formatter=repr
    ${edrxf1apcfg}      Get From Dictionary         ${edrxcfgfull}          F1APSETUP
    log                 ${edrxf1apcfg}\n            #formatter=repr
    ${edrxf1apval}      Get From Dictionary         ${edrxf1apcfg}          setupvalue
    log                 ${edrxf1apval}\n            #formatter=repr
    Run keyword if    'ASIKL' in '${hw_type}'        Set collecting for ASIK    attach_mode=${attach_mode}
    ...    positionInSubrack=${true}
    Run keyword if    'ASIKR' in '${hw_type}'        Set collecting for ASIK    attach_mode=${attach_mode}
    ...    positionInSubrack=${false}
    Run keyword if    'ASIB' in '${hw_type}'        Set collecting for ASIB    attach_mode=${attach_mode}        
    wait until keyword succeeds     2 min       5 s     cap.read_cap
    ...                             cap_file=Results_Logs/SCTP/SCTP.pcap
    ...                             tshark_path=/usr/bin/tshark
    #...                             X=lua_script:/home/ute/luashark/generated_luashark/
    ...                             display_filter=x2ap||f1ap
    ${ReadValues}=                  cap.get_element_value   nr-rrc.drx_Config
    log                             \nConfiguration value ${ReadValues}
    Should Contain                  ${ReadValues}[0]    ${edrxf1apval}

Do DL ping
    [Arguments]     ${toipaddr}
    ...             ${intervalofpings}=5
    ...             ${numberofping}=25
    ${timeouttoused}=               Evaluate        ${numberofping} * ${intervalofpings} + 15
    Log                             \ntimeout : ${timeouttoused}
    ${commandtolaunch}=    Set variable
    ...        ping -c ${numberofping} -i ${intervalofpings} ${toipaddr} | grep -E 'loss|rtt'
    Log                             \nCommand to launch : ${commandtolaunch}
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             myssh.connect_to              hostname=${serverIp}
    ...                             username=${serverName}      password=${serverPwd}
    ...                             alias=Serv-conn
    ${output_from_remote}=          myssh.execute    command=${commandtolaunch}    connection=Serv-conn
    ...    timeout=${timeouttoused} s
    Log                             \n${output_from_remote}
    [return]                        ${output_from_remote}

Do UL ping
    [Arguments]     ${toipaddr}
    ...             ${intervalofpings}=5
    ...             ${numberofping}=25
    ${timeouttoused}=               Evaluate        ${numberofping} * ${intervalofpings} + 10
    Log                             \ntimeout : ${timeouttoused}
    ${commandtolaunch}=             Set variable
    ...     adb shell "ping -c ${numberofping} -i ${intervalofpings} ${toipaddr} | grep -E 'loss|rtt'"
    Log                             \nCommand to launch : ${commandtolaunch}
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             robssh.Open Connection      ${ip_addr_pcue}
    ...                             escape_ansi=True            newline=CRLF
    ...                             alias=PCUE-conn
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             robssh.Login
    ...                             username=${pcue_uname}      password=${pcue_pswd}
    sleep                           2 s
    ${topurge}=                     robssh.Read
    robssh.Set client Configuration     prompt=${prompt_pc_ue}
    ${output_from_remote}=          robssh.Execute Command      adb root                timeout=30 s
    ${output_from_remote}=          robssh.Execute Command      ${commandtolaunch}      timeout=${timeouttoused} s
    Log                             \n${output_from_remote}
    robssh.Close Connection

    [return]                        ${output_from_remote}

Get average rtt
    [Arguments]         ${pingreport}
    log                 \String to scan : ${pingreport}
    ${averagertt}       Get Regexp Matches      ${pingreport}   [0123456789]{1,4}\.[0123456789]{1,3}
    log                 \n${averagertt}         #formatter=repr
    [return]            ${averagertt[1]}

Verify no ping lost
    [arguments]         ${pingreport}
    ${pinglost}=        Get Regexp Matches      ${pingreport}   [0123456789.]{1,7}%
    should be equal as strings      ${pinglost[0]}    0%

Verify latency
    [arguments]         ${reflatency}           ${checklalency}     ${EDRXCONFIG}=DLC160
    Log                 \nRef latency : ${reflatency}\nCheck latency : ${checklalency}      #formatter=repr
    ${edrxcfg}          Get From Dictionary         ${params5GC002060}      ${EDRXCONFIG}
    log                 ${edrxcfg}\n                #formatter=repr
    ${latency}          Get From Dictionary         ${edrxcfg}              LATENCY
    log                 ${latency}\n                #formatter=repr
    ${maxlatency}       Get From Dictionary         ${latency}              maxlatency
    ${inducedlatency}   Evaluate                    "%.2f" % (${checklalency}*1.0 - ${reflatency}*1.0)
    Log                 \nInduced latency : ${inducedlatency}
    Should be true      ${inducedlatency} <= ${maxlatency}

Initalize UE Type Android
    power_ue.Prepare UE    ue_type=huawei 
    Log             UE available
    Set Suite Variable
    ...     ${serverIp}         ${tl.ues[0].iperf_details.ssh_connection_details.addr}
    Set Suite Variable
    ...     ${serverName}       ${tl.ues[0].iperf_details.ssh_connection_details.username}
    Set Suite Variable
    ...     ${serverPwd}      ${tl.ues[0].iperf_details.ssh_connection_details.password}

Wait for next pm period
    [Documentation]     This keyword first get the time in second from gNB. It
    ...                 then calculate how long time to wait to be some seconds before or after
    ...                 the next pm period (15 mn based). It then sleeps for this value
    ...                 Author : Philippe Maron   philippe.maron@nokia.com
    [Arguments]     ${guardtime}=30     ${before}=${true}
    #Connect to OAM
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             ssh.connect_to              hostname=${ip_addr}
    ...                             username=toor4nsn           password=oZPS0POrRieRtu
    ...                             alias=OAM-conn
    ${stdout}=                      ssh.execute                 command=date -u +"%s"
    ...                             connection=OAM-conn

    ${basetime}=                    Run Keyword if          ${before}
    ...                             Evaluate                (${stdout} + ${guardtime})
    ...                             ELSE
    ...                             Evaluate                (${stdout} - ${guardtime})
    ${timetowait}=                  Evaluate            900 - (${basetime} % 900)
    log                             time to wait : ${timetowait}
    sleep    ${timetowait}

Get last pm counter file and expand it
    Remove Directory                ${Log_directory}/Counters            recursive=${true}
    Create Directory                ${Log_directory}/Counters
    #Connect to OAM
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             ssh.connect_to              hostname=${ip_addr}
    ...                             username=toor4nsn           password=oZPS0POrRieRtu
    ...                             alias=OAM-conn
    ${stdout}=                      ssh.execute
    ...                             command=cd /tmp;ls -dr1 PM*.xml.gz |head -1
    ...                             connection=OAM-conn
    ${stdout}=                      Strip string    ${stdout}   mode=right      characters=\r\n
    Log                             \nPM Gzipped file : ${stdout}
    ssh.download_file               remote_path=/tmp/${stdout}
    ...                             local_path=${Log_directory}/Counters/counters.xml.gz
    ...                             connection=OAM-conn
    Run and Return RC               gunzip ${Log_directory}/Counters/counters.xml.gz
    Log                             \nFile to analyze : ${Log_directory}/Counters/counters.xml
    
#/OMeS/PMSetup/PMMOResult/NE-WBTS_1.0/M55308C11001
Check 2060 PM counters
    [Arguments]         ${EDRXCONFIG}=DLC160
    ${edrxcfg}          Get From Dictionary         ${params5GC002060}      ${EDRXCONFIG}
    log                 ${edrxcfg}\n                #formatter=repr
    ${refratio}         Get From Dictionary         ${edrxcfg}              SLOTRATIO
    log                 ${refratio}\n               #formatter=repr
    ${minratio}         Get From Dictionary         ${refratio}             min
    ${maxratio}         Get From Dictionary         ${refratio}             max
    ${root} =           Parse XML                   ${Log_directory}/Counters/counters.xml
    @{DRxC11001}=       Get Elements Texts          ${root}     PMSetup/PMMOResult/NE-WBTS_1.0/M55308C11001
    @{DRxC11002}=       Get Elements Texts          ${root}     PMSetup/PMMOResult/NE-WBTS_1.0/M55308C11002
    ${numbercells}=     Get Length                  ${DRxC11001}
    ${nbunusedcells}=   Count Values In List        ${DRxC11001}        0
    Should Not Be Equal As Integers                 ${numbercells}      ${nbunusedcells}
    Length Should be    ${DRxC11002}                ${numbercells}
    FOR     ${idx}    IN RANGE    0                       ${numbercells}
        ${ratio}=       Run Keyword if              '${DRxC11001[${idx}]}' != '0'
        ...             Evaluate                    "%.2f" % (${DRxC11002[${idx}]}*1.0 / ${DRxC11001[${idx}]}*1.0)
        Log             \n${ratio}
        Run Keyword if  '${DRxC11001[${idx}]}' == '0'
        ...     Should be Equal     ${DRxC11002[${idx}]}    ${DRxC11001[${idx}]}
        ...     ELSE
        ...     Should be true      (${ratio} <= ${maxratio}) and (${ratio} >= ${minratio})
        log             \n${DRxC11001[${idx}]}\t${DRxC11002[${idx}]}        #formatter=repr
    END

Set edrx parameters trunk apple
    [Arguments]     ${EDRXCONFIG}=DLC160        ${cells_id}=${empty}    ${cellgrps_id}=${empty}
    ${edrxcfg}      Get From Dictionary         ${params5GC002060}      ${EDRXCONFIG}
    log             ${edrxcfg}\n                #formatter=repr
    ${edrxnrcellcfg}    Get From Dictionary     ${edrxcfg}              NRCELL
    log             ${edrxnrcellcfg}\n          #formatter=repr
    ${edrxnrcgrpcfg}    Get From Dictionary     ${edrxcfg}              NRCELLGRP
    log             ${edrxnrcgrpcfg}\n          #formatter=repr

    FOR     ${CELL}     IN      @{cells_id}
        ${distname_grp}=    catenate     SEPARATOR=/    ${BTS_Path}        ${CELL}

        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        actTcpBoostPug
        ${result}    ${release}    Run Keyword And Ignore Error
        ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
        ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
        Run keyword If  '${release_sbts}'=='SBTS23R2' or '${release_sbts}'=='SBTS23R3'
        ...    Log To Console  no_need_modify_actTcpBoostPug
        ...    ELSE   modify value in scf by dist_name    ${distname_grp}    actTcpBoostPug   ${edrxparam}

        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        actCDrx
        modify value in scf by dist_name            ${distname_grp}         actCDrx                 ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxInactivityTimer
        modify value in scf by dist_name            ${distname_grp}         drxInactivityTimer      ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxLongCycle
        modify value in scf by dist_name            ${distname_grp}         drxLongCycle            ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxOnDurationTimer
        modify value in scf by dist_name            ${distname_grp}         drxOnDurationTimer      ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxRetransTimerDl
        modify value in scf by dist_name            ${distname_grp}         drxRetransTimerDl       ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxRetransTimerUl
        modify value in scf by dist_name            ${distname_grp}         drxRetransTimerUl       ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxWactDlEnabled
        modify value in scf by dist_name            ${distname_grp}         drxWactDlEnabled        ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        drxWactUlEnabled
        modify value in scf by dist_name            ${distname_grp}         drxWactUlEnabled        ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcellcfg}        actBeamforming
        modify value in scf by dist_name            ${distname_grp}         actBeamforming          ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcgrpcfg}        csiReportPeriodicity
        Log    \nModifying in object ${distname_grp} :\nElement csiReportPeriodicity with value ${edrxparam}\n
        modify value in scf by dist_name 		    ${distname_grp}     	csiReportPeriodicity    ${edrxparam}                
    END
    FOR     ${CELLGRPS}     IN      @{cellgrps_id}
        ${distname_grp}=    catenate     SEPARATOR=/    ${BTS_Path}        ${CELLGRPS}
        ${edrxparam}        Get From Dictionary     ${edrxnrcgrpcfg}        ulSchedTimeInterval
        ${status}=    Run Keyword And Return Status
        ...    modify value in scf by dist_name    ${distname_grp}     	ulSchedTimeInterval    ${edrxparam}
        Run Keyword If  '${status}'=='False' 
        ...    Add element in scf by dist_name     ${distname_grp}         ulSchedTimeInterval        ${edrxparam}
        ${edrxparam}        Get From Dictionary     ${edrxnrcgrpcfg}        actProactUlScheduling        
        modify value in scf by dist_name 		    ${distname_grp}     	actProactUlScheduling    ${edrxparam}
    END
    
Set two edrx parameters trunk apple
    [Arguments]     ${cells_id}=${empty}    ${cellgrps_id}=${empty}
    ${edrxparam1}=    Convert To Integer     150
    ${edrxparam2}=    Convert To Integer     1250       

    FOR     ${CELL}     IN      @{cells_id}
        ${distname_grp}=    catenate     SEPARATOR=/    ${BTS_Path}        ${CELL}        
        ${status}=    Run Keyword And Return Status     
        ...    modify value in scf by dist_name            ${distname_grp}         ulProGrantTimer        ${edrxparam2}
        Run Keyword If  '${status}'=='False' 
        ...    Add element in scf by dist_name     ${distname_grp}         ulProGrantTimer        ${edrxparam2}
    END
    FOR     ${CELLGRPS}     IN      @{cellgrps_id}
        ${distname_grp}=    catenate     SEPARATOR=/    ${BTS_Path}        ${CELLGRPS}
        ${status}=    Run Keyword And Return Status
        ...    modify value in scf by dist_name 		    ${distname_grp}     	ulSchedTimeInterval    ${edrxparam1}
        Run Keyword If  '${status}'=='False' 
        ...    Add element in scf by dist_name     ${distname_grp}         ulSchedTimeInterval        ${edrxparam1}
    END  

Add element in scf by dist_name
  [Arguments]           ${Dist_Name}      ${Parameter_Name}      ${Parameter_Value}
  scf.add_element_to_scf    dist_name=${Dist_Name}           p_name=${Parameter_Name}    value=${Parameter_Value}

Set collecting for ASIK
    [Arguments]           ${attach_mode}=5G_NSA    ${positionInSubrack}=${true} 
    ${gNB_ASIK_collector_config}=   create dictionary   host=${ip_addr}
    ...                                                 user=toor4nsn
    ...                                                 password=oZPS0POrRieRtu
    Set Test Variable  ${ip_addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ${ip_addr_b}    Set Variable If    ${positionInSubrack}    192.168.253.17    192.168.253.33
    ${gNB_XEONB_collector_config}=   create dictionary   host=${ip_addr_b}
    ...                                                  user=toor4nsn
    ...                                                  password=oZPS0POrRieRtu
    ...                                                  proxy=${gNB_ASIK_collector_config}
    mytcpdump.create_tcpdump_collector                name=SCTP
    ...                                             options=-i any proto 0x84
    ...                                             executor=${gNB_XEONB_collector_config}
    mycore.setup_collectors       names=SCTP
    mycore.start_collectors       names=SCTP
    log                         \nStarting tcpdump
    sleep       10s
    Do Attach UE    attach_mode=${attach_mode} 
    sleep       20s
    mycore.stop_collectors        names=SCTP
    log                         \Stop tcpdump
    mycore.collect_collectors     names=SCTP          target_dir=./Results_Logs
    sleep       5s
    mycore.teardown_collectors    names=SCTP

Set collecting for ASIB
    [Arguments]           ${attach_mode}=5G_NSA
    ${gNB_ASIK_collector_config}=   create dictionary   host=${ip_addr}
    ...                                                 user=toor4nsn
    ...                                                 password=oZPS0POrRieRtu
    mytcpdump.create_tcpdump_collector                name=SCTP
    ...                                             options=-i any proto 0x84
    ...                                             executor=${gNB_ASIK_collector_config}
    mycore.setup_collectors       names=SCTP
    mycore.start_collectors       names=SCTP
    log                         \nStarting tcpdump
    Wait Until Keyword Succeeds  3x  10s    Do Attach UE    attach_mode=${attach_mode} 
    sleep       20s
    mycore.stop_collectors        names=SCTP
    log                         \Stop tcpdump
    mycore.collect_collectors     names=SCTP          target_dir=./Results_Logs
    sleep       5s
    mycore.teardown_collectors    names=SCTP



    
Change PM interal to 5min
    Log                   \nChange PM interal to 5min
    myssh.Connect to     hostname=${GN_OAM_ADDR}    username=${ASIK_username}    password=${ASIK_password}	alias=ASIK
    ${output}=    myssh.Execute    ls -trl /ffs/run/ | grep -w "swconfig.txt" | awk '{print $5}'    connection=ASIK
    Run Keyword If    '${output.split("\r\n")[0]}' != '0'    Run keyword and return status    myssh.Execute                    
    ...    sed -i '/0x340000=3/d' /ffs/run/swconfig.txt   connection=ASIK
    Run Keyword If    '${output.split("\r\n")[0]}' != '0'    Run keyword and return status    myssh.Execute                    
    ...    command=sed -i '$a\0x340000=3' /ffs/run/swconfig.txt   connection=ASIK
    [Teardown]    Run Keyword And Continue On Failure  myssh.Disconnect  connection=ASIK

#Download luashark file
#    [Documentation]                    Download luashark file
#    OperatingSystem.Create Directory    /home/ute/luashark
#    OperatingSystem.List Files In Directory    /home/ute    *luashark*
#    OperatingSystem.Remove Files    /home/ute/*luashark.zip*
#    OperatingSystem.Remove Files    /home/ute/luashark*.zip*
#    OperatingSystem.List Files In Directory    /home/ute    *luashark*
#    Run Keyword if    '_9999_' in '${swversion}'    Downloadluashark.get_file_for_Trunk_Load    ${swversion}
#    Run Keyword if    '_0000_' in '${swversion}'    Downloadluashark.get_file_for_21B_Load    ${swversion}
#    Run Keyword if    '5G21A' in '${swversion}'    Downloadluashark.get_file_for_21A_Load    ${swversion}
#    Run Keyword if    '5G20B' in '${swversion}'    Downloadluashark.get_file_for_20B_Load    ${swversion}
#    Downloadluashark.unzip_file
#    OperatingSystem.Directory Should Not Be Empty      /home/ute/luashark/generated_luashark
    
gNB Get CellId and BTSId DN in SCF  
    coam_gnb_classical.Connect to gnb coam via ssl    connection=GNB_OAM    
    ${content}=         coam.get_current_scf_content    connection=GNB_OAM
    ${parsed_xml}=    XML.Parse Xml    ${content}
    ${cell_elements}=     XML.Get Elements    ${parsed_xml}
    ...    cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"] 
    BuiltIn.Should Not Be Empty    ${cell_elements} 
    ${cell_num}=    BuiltIn.Get Length    ${cell_elements}
    BuiltIn.Set Suite Variable    ${BTS_Path}       ${cell_elements[0].attrib['distName'].split('/NRCELL')[0]} 
    BuiltIn.Set Suite Variable    ${BTS_Path_SA}    ${BTS_Path}
    Set Suite Variable    ${CV_NRCELL_1}    ${cell_elements[0].attrib['distName']}
    ${result}=          XML.Get Element    ${parsed_xml}
    ...                 .//managedObject[@distName="${CV_NRCELL_1}"]/p[@name="physCellId"]
    BuiltIn.Set Suite Variable            ${physCellId}    ${result.text}
    
    ${group_elements}=     XML.Get Elements    ${parsed_xml}
    ...    cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELLGRP"] 
    BuiltIn.Should Not Be Empty    ${group_elements} 
    ${group_num}=    BuiltIn.Get Length    ${group_elements}
    Set Suite Variable    ${group_num}
    ${cellgrps_id}    BuiltIn.Create List 
    FOR    ${index}    IN RANGE    ${group_num}    
        ${cellgrp_id}    BuiltIn.Set Variable    ${group_elements[${index}].attrib['distName'].split('/')[-1]}
        Append To List    ${cellgrps_id}    ${cellgrp_id}
    END
    BuiltIn.Set Suite Variable    ${cellgrps_id}

Get UE IP
    [Arguments]    ${ue_index}=${0}
    Connect to control pc via cygwin    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}   ue_index=${ue_index}
    ${serial_number}=     Set Variable     ${tl.ues[${ue_index}].serial_number}
    sleep   5s 
    Run Keyword And Ignore Error    myssh.send_command    
    ...    command=adb -s ${serial_number} shell ip addr | grep rmnet | grep inet | awk '{print $2}'
    ...    connection=cygwin
    ${output}=    myssh.Read Output    connection=cygwin    
    ${UE_IP}=    Strip String    ${output}
    ${UE_IP}=    string.Fetch From Left    string=${UE_IP}    marker=/ 
    sleep   2s
    myssh.disconnect      connection=cygwin 
    [return]    ${UE_IP}

Wait For Fault with Alarm to disappear
  [Arguments]  ${FaultID}
  wait until keyword succeeds  1200      5    Fault Should Not Be Present   ${FaultID}
  
Fault Should Not Be Present
  [Arguments]    ${fault_id}
  ${active_alarms}    coam.get_active_alarms    timeout=600s    connection=GNB_OAM
  ${len}    Get Length    ${active_alarms}
  ${alarm_id_list}    Create List
  FOR    ${i}    IN RANGE    ${len}
      ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
      Append To List    ${alarm_id_list}    ${tmp_id}
  END
  ${list}     convert to string  ${alarm_id_list}
  Should Not Contain     ${list}    ${fault_id}
  
Test Setup
    Run Keyword And Ignore Error    coam_gnb_classical.COAM Teardown gnb connections
    gNB Get CellId and BTSId DN in SCF
    Set Environment Variable               https_proxy                 ${empty}
    Run keyword and ignore error           list active alarms
    Run keyword and continue on failure    get and validate scf file   SCF_init.xml
    Run keyword and ignore error    Change PM interal to 5min
    Initalize UE Type Android   

StaticCall FeatureNotActive NSA
     [Arguments]    ${attach_mode}=5G_NSA
    # Get Cells list:
    ${cells_id}                        Get list of all cells

    # First the gNB is configured with feature deactivated and network is verified checking that no packet lost
    # in a 120 packets ping,
    # the average latency is saved to verify the introduced latency is no more than expected
    log                                gNB is configured with feature deactivated
    Set 5G Load Version
    Run Keyword And Ignore Error       Set edrx parameters ${5GLoadVersion}     DRXOFF      ${cells_id}
    ...     ${cellgrps_id}
    ${Validationresult}                validate modified values    SCF_DRXOFF.xml
    scf uploading and commissioning    SCF_DRXOFF.xml

    COAM Update SERVEDAMF administrativeState    Locked
    sleep    60s

    Wait Until Keyword Succeeds  600  10s    Do Attach UE                       attach_mode=${attach_mode}
    ${ip_addr_ue}                      5GC002060keysTDD.Get UE IP
    ${pingres}=                        Do DL ping      ${ip_addr_ue}   numberofping=120    intervalofpings=1
    ${linelostping}=                   Get lines containing String     ${pingres}          packet loss
    Verify no ping lost                pingreport=${linelostping}
    ${linertt}=                        Get lines containing String     ${pingres}          min/avg/max/mdev
    ${refrtt}=                         Get average rtt                 pingreport=${linertt}
    Do Detach UE
    sleep                              10s
    [Return]   ${cells_id}   ${cellgrps_id}    ${refrtt}

StaticCall FeatureNotActive SA
    [Arguments]    ${attach_mode}=5G_SA
    # Get Cells list:
    ${cells_id}                        Get list of all cells

    # First the gNB is configured with feature deactivated and network is verified checking that no packet lost
    # in a 120 packets ping,
    # the average latency is saved to verify the introduced latency is no more than expected
    log                                gNB is configured with feature deactivated
    Set 5G Load Version
    Run Keyword And Ignore Error       Set edrx parameters ${5GLoadVersion}     DRXOFF      ${cells_id}
    ...     ${cellgrps_id}
    ${Validationresult}                validate modified values    SCF_DRXOFF.xml
    scf uploading and commissioning    SCF_DRXOFF.xml

    COAM Update SERVEDAMF administrativeState    Unlocked

    Do Attach UE                       attach_mode=${attach_mode}
    sleep                              10s
    ${ip_addr_ue}                      5GC002060keysTDD.Get UE IP
    ${pingres}=                        Do DL ping      ${ip_addr_ue}   numberofping=120    intervalofpings=1
    ${linelostping}=                   Get lines containing String     ${pingres}          packet loss
    Verify no ping lost                pingreport=${linelostping}
    ${linertt}=                        Get lines containing String     ${pingres}          min/avg/max/mdev
    ${refrtt}=                         Get average rtt                 pingreport=${linertt}
    Do Detach UE
    sleep                              10s
    [Return]   ${cells_id}   ${cellgrps_id}    ${refrtt}

StaticCall FeatureNotActive
    [Arguments]    ${attach_mode}=5G_NSA
    # Get Cells list:
    ${cells_id}                        Get list of all cells

    # First the gNB is configured with feature deactivated and network is verified checking that no packet lost
    # in a 120 packets ping,
    # the average latency is saved to verify the introduced latency is no more than expected
    log                                gNB is configured with feature deactivated
    Set 5G Load Version
    Run Keyword And Ignore Error       Set edrx parameters ${5GLoadVersion}     DRXOFF      ${cells_id}
    ...     ${cellgrps_id}
    ${Validationresult}                validate modified values    SCF_DRXOFF.xml
    scf uploading and commissioning    SCF_DRXOFF.xml

    Do Attach UE                       attach_mode=${attach_mode}
    sleep                              10s
    ${ip_addr_ue}                      5GC002060keysTDD.Get UE IP
    ${pingres}=                        Do DL ping      ${ip_addr_ue}   numberofping=120    intervalofpings=1
    ${linelostping}=                   Get lines containing String     ${pingres}          packet loss
    Verify no ping lost                pingreport=${linelostping}
    ${linertt}=                        Get lines containing String     ${pingres}          min/avg/max/mdev
    ${refrtt}=                         Get average rtt                 pingreport=${linertt}
    Do Detach UE
    sleep                              10s
    [Return]   ${cells_id}   ${cellgrps_id}    ${refrtt}

Test Teardown
    Run Keyword And Ignore Error    Do Detach UE
    #scf uploading and commissioning        SCF_init.xml
    CI_interface.Common Suite Setup

    #Log to console    COAM Teardown gnb connections
    #coam_gnb_classical.COAM Teardown gnb connections
    Run Keyword And Ignore Error       myssh.reset_cache
  
StaticCall_DrxLongCycle160_lowDLTraffic
    [Documentation]    a bad configuration using 160 mS DLC is tried, relation errors should be raised
    ...    when validating:
    #log                                gNB is configured with a bad configuration using 160 mS DLC

    # Then a DLC160 configuration is used and activated, a UE is attached and a verification is done on the used
    ...    parameters:
    [Arguments]    ${cells_id}    ${cellgrps_id}    ${refrtt}
    #Download luashark file
    Run Keyword And Ignore Error    Set edrx parameters ${5GLoadVersion}     DLC160      ${cells_id}
    ...     ${cellgrps_id}
    ${Validationresult}                    validate modified values    SCF_DLC160.xml
    scf uploading and commissioning        SCF_DLC160.xml      tcpdumpguard=${true}
    COAM Update SERVEDAMF administrativeState    Locked
    sleep    60s
    Attach UE and Verify DRx parameters    DLC160

    # A 120 packets ping is then launched and no packets should be lost,
    # and the average latency should be less equal to the latency without drx activated plus the drx cyle
    # (160 in this case):
    ${ip_addr_ue}                      5GC002060keysTDD.Get UE IP
    ${pingres}=                        Do DL ping      ${ip_addr_ue}   numberofping=120    intervalofpings=1
    ${linelostping}=                   Get lines containing String     ${pingres}          packet loss
    Verify no ping lost                pingreport=${linelostping}
    ${linertt}=                        Get lines containing String     ${pingres}          min/avg/max/mdev
    ${checkrtt}=                       Get average rtt                 pingreport=${linertt}
    Verify latency                     ${refrtt}                       ${checkrtt}      DLC160
    Do Detach UE
    # All actions done before validate the 5GC002060_1 test
	  Set suite variable                 ${5GC002060_1}        PASSED

    # Wait the next PM Counters period
    Wait for next pm period            guardtime=30          before=${false}

    # Now the 5GC002060_6 actions will be launched:
    # UE is attached and it is pinged every 5 second for a little more than the test duration to maintain it connected
    Attach UE and Verify DRx parameters    DLC160
    ${ip_addr_ue}                      5GC002060keysTDD.Get UE IP
    ${pingres}=                        Do DL ping      ${ip_addr_ue}   numberofping=195    intervalofpings=5
    ${linelostping}=                   Get lines containing String     ${pingres}          packet loss
    Verify no ping lost                pingreport=${linelostping}

    # At the end of the ping, the last pm counter file is retrieved and the counters are checked.
    Get last pm counter file and expand it
    ${PM_file}=    Check 2060 PM counters             EDRXCONFIG=DLC160
    Do Detach UE
	  Set suite variable                 ${5GC002060_6}  PASSED
	  
StaticCall_DrxLongCycle320_lowDLTraffic
    [Documentation]    Then a DLC320 configuration is used and activated, a UE is attached and a verification is done
    ...    on the used parameters:
    [Arguments]    ${cells_id}    ${cellgrps_id}    ${refrtt}
    log                                    gNB is configured with a configuration using 320 mS DLC
    Run Keyword And Ignore Error           Set edrx parameters ${5GLoadVersion}     DLC320      ${cells_id}
    ...     ${cellgrps_id}
    ${Validationresult}                    validate modified values    SCF_DLC320.xml
    scf uploading and commissioning        SCF_DLC320.xml      tcpdumpguard=${true}
    COAM Update SERVEDAMF administrativeState    Locked
    sleep    60s
    Attach UE and Verify DRx parameters    DLC320

    # A 120 ping is then launch and no packets should be lost,
    # the average latency should be less equal to the latency without drx activated plus the drx cyle (320 in this case)
    ${ip_addr_ue}                      5GC002060keysTDD.Get UE IP
    ${pingres}=                        Do DL ping      ${ip_addr_ue}   numberofping=120    intervalofpings=1
    ${linelostping}=                   Get lines containing String     ${pingres}          packet loss
    Verify no ping lost                pingreport=${linelostping}

    # All actions done before validate the 5GC002060_35 test
	  Set suite variable                 ${5GC002060_35}         PASSED

    # Check the latency
    ${linertt}=                        Get lines containing String     ${pingres}          min/avg/max/mdev
    ${checkrtt}=                       Get average rtt                 pingreport=${linertt}
    Verify latency                     ${refrtt}                       ${checkrtt}      DLC320
    Do Detach UE
    
StaticCall_DrxLongCycle320_Counters
    [Documentation]    First the gNB is configure DLC 320 configuration, then the the begining of next reporting 
    ...    period is waited
    [Arguments]    ${cells_id}    ${cellgrps_id}
    Set 5G Load Version
    Run Keyword And Ignore Error       Set edrx parameters ${5GLoadVersion}     DLC320      ${cells_id}
    ...     ${cellgrps_id}
    ${Validationresult}                validate modified values    SCF_DLC320.xml
    scf uploading and commissioning    SCF_DLC320.xml      tcpdumpguard=${true}
    COAM Update SERVEDAMF administrativeState    Locked
    Wait for next pm period five min            guardtime=30
#    Wait for next pm period            guardtime=30        before=${false}

    # A UE is attached and it is pinged every 5 second for a little more than the test duration to maintained it 
    # connected
    Attach UE and Verify DRx parameters    DLC320
    ${ip_addr_ue}                      5GC002060keysTDD.Get UE IP
    ${pingres}=                            Do DL ping      ${ip_addr_ue}   numberofping=195    intervalofpings=5
    ${linelostping}=                       Get lines containing String     ${pingres}          packet loss
    Verify no ping lost                    pingreport=${linelostping}

    # At the end of the ping, the last pm counter file is retrieved and the counters are checked.
    Do Detach UE
#    Wait for next pm period            guardtime=30        before=${false}
    Wait for next pm period twenty min            guardtime=30          before=${False}
    Get last pm counter file and expand it
    Check 2060 PM counters                 EDRXCONFIG=DLC320
    
StaticCall_DrxLongCycle640_lowDLTraffic
    [Documentation]    Then a good configuration is used and activated, a UE is attached and a verification is done
    ...    on the used parameters:
    [Arguments]    ${cells_id}    ${cellgrps_id}
    Run Keyword And Ignore Error           Set edrx parameters ${5GLoadVersion}     DLC640      ${cells_id}
    ...     ${cellgrps_id}
    ${Validationresult}                    validate modified values    SCF_DLC640.xml
    log                                    validation of SCF_DLC640 is ${Validationresult}
    scf uploading and commissioning        SCF_DLC640.xml              tcpdumpguard=${true}
    COAM Update SERVEDAMF administrativeState    Locked
    sleep    60s
    Attach UE and Verify DRx parameters    DLC640

    # A 120 packets ping is then launched and no packets should be lost:
    ${ip_addr_ue}                      5GC002060keysTDD.Get UE IP
    ${pingres}=                        Do DL ping      ${ip_addr_ue}   numberofping=120    intervalofpings=1
    ${linelostping}=                   Get lines containing String     ${pingres}          packet loss
    Verify no ping lost                pingreport=${linelostping}
    Do Detach UE
	  Set suite variable                 ${Test_Result}                  PASSED
	  
StaticCall_DrxLongCycle160_Apple_Counters
    [Documentation]    Then a DLC160APPLE configuration is used and activated, a UE is attached and a verification 
    ...    is done on the used parameters:
    [Arguments]    ${cells_id}    ${cellgrps_id}    ${refrtt}
    Run Keyword And Ignore Error       Set edrx parameters ${5GLoadVersion}     DLC160APPLE      ${cells_id}
    ...     ${cellgrps_id}
    ${Validationresult}                validate modified values        SCF_DLC160APPLE.xml
    scf uploading and commissioning    SCF_DLC160APPLE.xml             tcpdumpguard=${true}
    COAM Update SERVEDAMF administrativeState    Unlocked
    Attach UE and Verify DRx parameters    DLC160APPLE    attach_mode=5G_SA

    # A 120 packets ping is then launched and no packets should be lost, and the average latency
    # should be less equal to the latency without drx activated plus the drx cyle (160 in this case):
    ${ip_addr_ue}                      5GC002060keysTDD.Get UE IP
    ${pingres}=                        Do DL ping      ${ue_ip}   numberofping=120    intervalofpings=1
    ${linelostping}=                   Get lines containing String     ${pingres}          packet loss
    Verify no ping lost                pingreport=${linelostping}
    ${linertt}=                        Get lines containing String     ${pingres}          min/avg/max/mdev
    ${checkrtt}=                       Get average rtt                 pingreport=${linertt}
    Verify latency                     ${refrtt}                       ${checkrtt}      DLC160APPLE
    Do Detach UE
    # All actions done before validate the 5GC002060_1 test
	  Set suite variable                 ${5GC002060_37}       PASSED

    # Wait the next PM Counters period
#    Wait for next pm period            guardtime=30          before=${false}

    # Now the 5GC002060_38 actions will be launched:
    # ASKEY UE is attached and it is pinged every 5 second for a little more than the test duration to maintained it 
    # connected
    Attach UE and Verify DRx parameters    DLC160APPLE    attach_mode=5G_SA
    ${ip_addr_ue}                      5GC002060keysTDD.Get UE IP
    Wait for next pm period twenty min            guardtime=30
    ${pingres}=                        Do DL ping      ${ue_ip}    numberofping=1275    intervalofpings=1
    ${linelostping}=                   Get lines containing String      ${pingres}          packet loss
    Verify no ping lost                pingreport=${linelostping}
    # At the end of the ping, the last pm counter file is retrieved and the counters are checked.
    Get last pm counter file and expand it
    Check 2060 PM counters             EDRXCONFIG=DLC160APPLE
    Do Detach UE
	  Set suite variable                 ${5GC002060_38}       PASSED
	  
StaticCall_DrxLongCycle80_lowDLTraffic
    [Documentation]    Then a good configuration is used and activated, a UE is attached and a verification is done
    ...    on the used parameters:
    [Arguments]    ${cells_id}    ${cellgrps_id}
    Run Keyword And Ignore Error           Set edrx parameters ${5GLoadVersion}     DLC80      ${cells_id}
    ...     ${cellgrps_id}
    ${Validationresult}                    validate modified values    SCF_DLC80.xml
    log                                    validation of SCF_DLC80 is ${Validationresult}
    scf uploading and commissioning        SCF_DLC80.xml               tcpdumpguard=${true}
    COAM Update SERVEDAMF administrativeState    Locked
    sleep    300s
    Attach UE and Verify DRx parameters    DLC80

    # A 120 packets ping is then launched and no packets should be lost:
    ${ip_addr_ue}                      5GC002060keysTDD.Get UE IP
    ${pingres}=                        Do DL ping      ${ip_addr_ue}   numberofping=120    intervalofpings=1
    ${linelostping}=                   Get lines containing String     ${pingres}          packet loss
    Verify no ping lost                pingreport=${linelostping}
    Do Detach UE

StaticSACall_DrxLongCycle160_lowDLTraffic
    [Documentation]    Then a good configuration is used and activated, a UE is attached and a verification is
    ...    done on the used parameters:
    [Arguments]    ${cells_id}    ${cellgrps_id}
    #Download luashark file
    Run Keyword And Ignore Error       Set edrx parameters ${5GLoadVersion}     DLC160SA      ${cells_id}
    ...     ${cellgrps_id}
    ${Validationresult}                validate modified values        SCF_DLC160.xml
    scf uploading and commissioning    SCF_DLC160.xml                  tcpdumpguard=${true}
    COAM Update SERVEDAMF administrativeState    Unlocked
    # Do Require UE
    Attach UE and Verify DRx parameters     DLC160SA    attach_mode=5G_SA

    # A 120 packets ping is launched and no packets should be lost:
    ${ip_addr_ue}                      5GC002060keysTDD.Get UE IP
    ${pingres}=                        Do DL ping      ${ip_addr_ue}   numberofping=120    intervalofpings=1
    ${linelostping}=                   Get lines containing String     ${pingres}          packet loss
    Verify no ping lost                pingreport=${linelostping}

    # Detach UE:
    Do Detach UE
    
StaticCall_DrxLongCycle160_Apple_lowDLTraffic
    [Documentation]    Then a DLC160APPLE configuration is used and activated, a UE is attached and a verification
    ...    is done on the used parameters 
    # Get Cells list:
    ${cells_id}                        Get list of all cells
    Run Keyword And Ignore Error       Set edrx parameters trunk apple     DLC160APPLE38      ${cells_id}     ${cellgrps_id}
    ${Validationresult}                validate modified values        SCF_DLC160APPLE38_1.xml
    scf uploading and commissioning    SCF_DLC160APPLE38_1.xml             tcpdumpguard=${true}
    Wait for next pm period five min            guardtime=60          before=${true}
    Attach UE and Verify DRx parameters    DLC160APPLE38    attach_mode=5G_SA
    Wait for next pm period twenty min            guardtime=30          before=${False}
    Get last pm counter file and expand it
    Check 2060 PM counters             EDRXCONFIG=DLC160APPLE38
    Do Detach UE
    Log                 \nSubcase1 : passed\n
    
    # Wait the next PM Counters period
    Wait for next pm period five min            guardtime=60          before=${true}

    # ASKEY UE is attached and it is pinged every 5 second for a little more than the test duration to maintained it connected
    Do Attach UE    attach_mode=5G_SA
    ${ue_ip}    5GC002060keysTDD.Get UE IP
    ${pingres}=                        Do DL ping      ${ue_ip}    numberofping=195    intervalofpings=5
    ${linelostping}=                   Get lines containing String      ${pingres}          packet loss
    Verify no ping lost                pingreport=${linelostping}

    # At the end of the ping, the last pm counter file is retrieved and the counters are checked.
    Get last pm counter file and expand it
    Check 2060 PM counters             EDRXCONFIG=DLC160APPLE38
    Do Detach UE
    Log                 \nSubcase2 : passed\n
    
    Run Keyword And Ignore Error       Set two edrx parameters trunk apple    ${cells_id}     ${cellgrps_id}
    ${Validationresult}                validate modified values        SCF_DLC160APPLE38_2.xml
    scf uploading and commissioning    SCF_DLC160APPLE38_2.xml             tcpdumpguard=${true}
    Attach UE and Verify DRx parameters    DLC160APPLE38    attach_mode=5G_SA
    Wait for next pm period twenty min            guardtime=30          before=${False}
    Get last pm counter file and expand it
    Check 2060 PM counters             EDRXCONFIG=DLC160APPLE38_3
    Do Detach UE
    Log                 \nSubcase3 : passed\n
    
    Wait for next pm period five min            guardtime=60          before=${true}
    Do Attach UE    attach_mode=5G_SA
    ${ue_ip}    5GC002060keysTDD.Get UE IP
    ${pingres}=                        Do DL ping      ${ue_ip}    numberofping=195    intervalofpings=5
    ${linelostping}=                   Get lines containing String      ${pingres}          packet loss
    Verify no ping lost                pingreport=${linelostping}
    Do Detach UE

    # At the end of the ping, the last pm counter file is retrieved and the counters are checked.
    Wait for next pm period twenty min            guardtime=30          before=${False}
    Get last pm counter file and expand it
    Check 2060 PM counters             EDRXCONFIG=DLC160APPLE38_3
    #Do Detach UE
    Log                 \nSubcase4 : passed\n
	  Set suite variable                 ${5GC002522_38}       PASSED


Wait for next pm period five min
    [Documentation]     This keyword first get the time in second from gNB. It
    ...                 then calculate how long time to wait to be some seconds before or after
    ...                 the next pm period (15 mn based). It then sleeps for this value
    ...                 Author : Philippe Maron   philippe.maron@nokia.com
    [Arguments]     ${guardtime}=30     ${before}=${true}
    #Connect to OAM
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             ssh.connect_to              hostname=${ip_addr}
    ...                             username=toor4nsn           password=oZPS0POrRieRtu
    ...                             alias=OAM-conn
    ${stdout}=                      ssh.execute                 command=date -u +"%s"
    ...                             connection=OAM-conn

    ${basetime}=                    Run Keyword if          ${before}
    ...                             Evaluate                (${stdout} + ${guardtime})
    ...                             ELSE
    ...                             Evaluate                (${stdout} - ${guardtime})
    ${timetowait}=                  Evaluate            300 - (${basetime} % 300)
    log                             time to wait : ${timetowait}
    sleep    ${timetowait}

Wait for next pm period twenty min
    [Documentation]     This keyword first get the time in second from gNB. It
    ...                 then calculate how long time to wait to be some seconds before or after
    ...                 the next pm period (15 mn based). It then sleeps for this value
    ...                 Author : Philippe Maron   philippe.maron@nokia.com
    [Arguments]     ${guardtime}=30     ${before}=${true}
    #Connect to OAM
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             ssh.connect_to              hostname=${ip_addr}
    ...                             username=toor4nsn           password=oZPS0POrRieRtu
    ...                             alias=OAM-conn
    ${stdout}=                      ssh.execute                 command=date -u +"%s"
    ...                             connection=OAM-conn

    ${basetime}=                    Run Keyword if          ${before}
    ...                             Evaluate                (${stdout} + ${guardtime})
    ...                             ELSE
    ...                             Evaluate                (${stdout} - ${guardtime})
    ${timetowait}=                  Evaluate            1200 - (${basetime} % 1200)
    log                             time to wait : ${timetowait}
    sleep    ${timetowait}
