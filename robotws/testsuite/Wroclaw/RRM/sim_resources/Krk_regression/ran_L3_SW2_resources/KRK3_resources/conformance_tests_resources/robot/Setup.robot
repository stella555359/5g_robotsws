*** Settings ***
Library                             DateTime
Library                             OperatingSystem
Resource                            Tools.robot
Resource                            Connect.robot
Resource                            Oam.robot
Resource                            Container.robot
Resource                            CallSetup.robot
Resource                            Backup.robot
Resource                            Topology.robot
Resource                            ET_test_env_additional_config_for_ute_cloud.robot
Library                             ../python/StringTool.py
Library                             ../python/Airscale.py
Library                             ../python/Setup.py

*** Variables ***
${STATUS_FILE_NAME}                 Status_Before_Testsuite.txt
@{NO_BACKUP_FILES}
@{SUITE_BACKUP_FILES}
${enable_sherpa}

*** Keywords ***

Suite Setup
    [Documentation]                 Add automaticTeardown option, to get SOS report & Snapshot
    ...                             Default value is false, possible values:
    ...                             automaticTeardown=True         launched after every failed tests
    ...                             automaticTeardown=False        Never launched (default value)
    ...                             automaticTeardown=Force        launched at suite teardown
    ...                             automaticTeardown=FirstFail    launched ONLY after first failed test
    [Arguments]                     ${listBackupFiles}=${NO_BACKUP_FILES}    ${automaticTeardown}=${False}
    Log to console                  Suite Setup
    Setup Ute Env if required
    # temp var to manage non existing value
    ${hire_sherpa} =                Get Variable Value                      ${hire_a_sherpa}
    ...                             False
    # the boolean good variable
    ${enable_sherpa} =              Set Variable If                      '${hire_sherpa}'=='True'
    ...                             ${True}                              ${False}
    Set Suite Variable              ${enable_sherpa}
    get_l1_mode                     ${TLConfig}
    call method                     ${TLConfig}                             printConfig
    ...                             TLConfig
    TOPO Read
    # Compute LOG path
    # Replace " " with "_" to have a correct file name (because stupid robot replace _ with spaces)
    ${timestamp}                    Get Current Date                        result_format=%Y%m%d_%H%M%S%f
    ${fullSuiteName}                getFormattedSuiteName
    Set Suite Variable              ${LOG_PATH}
    ...                             ${OUTPUT DIR}/Logs/${timestamp}.${fullSuiteName}
    Create Directory                ${LOG_PATH}
    # Create temp path
    ${TEMP_PATH}                    OperatingSystem.run                     mktemp -d
    Set Suite Variable              ${TEMP_PATH}
    Set Suite Variable              ${snapshot_path}                        ${LOG_PATH}/Snapshot.zip
    Get TL Info
    # Upload SWconfig File
    ${boot_ids_after_startup}       Create Dictionary
    Set Suite Variable              ${boot_ids_after_startup}
    ${alias}                        SSH Connect                             ${AIRSCALE_GNB.sys[0].M}
    ${boot_id_startup}=             Read Boot ID
    ...                                 alias=${alias}
    ...                                 name=fct
    ...                                 boot_ids=${boot_ids_after_startup}
    Set Suite Variable              ${boot_id_startup}
    # Backup of SCF
    OAM Get SCF Files
    Check Network Type
    Set Gscn Parameter Name
    # Backup files if required
    Suite Backup Files              listBackupFiles=${listBackupFiles}
    setTestTeardownFlag             ${automaticTeardown}

Setup Ute Env if required
    # Update tl.core fields igf we are in UTE
    Run Keyword if                  ${TLConfig.isUTE}==${True}
    ...                             ET_test_env_additional_config_for_ute_cloud.ET test env additional config for ute cloud
    # port for PM with TL ute
    Run Keyword If                  ${TLConfig.isUTE}
    ...                             Set suite variable    ${tl.gnbs[0].cu.oam_http_connection_details.port}    443
    # Update EPCSIM ssh connection (all cases)
    call method                     ${HOST_EPCSIM}
    ...                             setSshConnection
    ...                             ${tl.core.default_ssh_connection_details}

    #Set To Dictionary               ${HOST_EPCSIM}
    #...                             sshConnection=${tl.core.default_ssh_connection_details}
    ${CAPTURE_CORE_WTS_ETH3.host}   set variable                            ${HOST_EPCSIM}
    StringTool.printHeaderLine      name=EPCSIM tl.core path                value=${tl.core.dir_path}/${tl.core.cfg_filename}
    Manage Additional UE

Suite Teardown
    [Documentation]                 Add reset_ap flag, to launch a restart of Airphone, in case gnb restarts
    [Arguments]                     ${reset_ap}=${False}
    Log to console                  Test Suite Teardown
    # Run Keyword if                  ${TLConfig.isGnbCloud}==${False}          OAM Restore
    Suite Restore Files
    Run keyword if                  "${automaticTeardown}"=="Force"           Test Teardown if Fail

Test Setup
    Dated Log                       Start Test Setup

Test Teardown
    Dated Log                       Start Test Teardown
    Run keyword if                  '${TEST_STATUS}'=='FAIL'
    ...                             Test Teardown if Fail

Test Teardown if Fail
    Dated log                       Get Sos Report and Snapshot
    Get Sos Report
    Get Snapshot

Read Boot ID
    [Arguments]                     ${alias}
    ...                             ${name}
    ...                             ${boot_ids}
    ${bootNr}                       SSH Cmd
    ...                                 journalctl --list-boots | tail -n 1 | awk '{print $1}' | tr -d '\r\n'
    ...                                 alias=${alias}
    Run Keyword If                  '${bootNr}'!='0'
    ...                             FAIL                                    msg=\n\t${name}: wrong bootNr=${bootNr}\n
    ${bootId}                       SSH Cmd
    ...                                 journalctl --list-boots | tail -n 1 | awk '{print $2}' | tr -d '\r\n'
    ...                                 alias=${alias}
    Collections.Set To Dictionary   ${boot_ids}             ${name}         ${bootId}
    [Return]                        ${bootId}


Suite Backup Files
    [Documentation]                 Backup all files included in a list of files description
    ...                             If this list is empty, nothing is done
    ...                             The name of the list of saved to be reused for restore action
    [Arguments]                     ${listBackupFiles}=${FD_ALL}
    Set Suite Variable              ${SUITE_BACKUP_FILES}                   ${listBackupFiles}
    ${len}                          Get length                              ${listBackupFiles}
    Run keyword if                  ${len}!=0
    ...                             Backup Files                            ${listBackupFiles}

Suite Restore Files
    [Documentation]                 Restore all files included in the SUITE_BACKUP_FILES list
    ...                             If this list is empty, nothing is done
    ...                             The list should have been previously defined (by "Suite Backup Files" keyword)
    ${len}                          Get length                              ${SUITE_BACKUP_FILES}
    Run keyword if                  ${len}!=0
    ...                             Restore Files                           ${SUITE_BACKUP_FILES}

#=======================================================================================================================
# Get TL Info from OAM
#=======================================================================================================================
Get TL Info
    [Documentation]                 Retrieve several info from GNB OAM, display them and print them in a log file
    ...                             Information retrieved are :
    ...                                 BTS_INFO, MRBTS_ID and NRCELL_DIST_NAME
    ...                                 GNB software version
    ...                                 GNB alarms
    Get TL Info Struct
    Get TL Info From Oam            entity=${GNB_DU}                        create=${True}
    Get TL Info From Oam            entity=${GNB_CU}                        create=${False}

Get TL Info From Oam
    [Arguments]                     ${entity}=${GNB_DU}                     ${create}=${True}
    return from keyword if          '${entity}'=='None'
    StringTool.printLineWithTitle   Get TL info from OAM ${entity.oam.alias}
    @{alarms}                       OAM Get Active Alarms                   oam=${entity.oam}
    ${alias}                        OAM Connect                             ${entity.oam}
    ${version}                      OAM Get SW Version                      oam=${entity.oam}
    OAM Get GNB BTS Info            oam=${entity.oam}
    # Open file if required
    run keyword if                  ${create}
    ...                             Create File                             ${LOG_PATH}/${STATUS_FILE_NAME}
    # For each variable, display it, store in file, and eventually store in global variable
    ${postfix}                      OAM Get Postfix                         ${entity.oam}
    ${i}                            Set variable                            ${0}
    FOR  ${alarm}       IN          @{alarms}
        ${i}                        evaluate                                ${i}+${1}
        Trace and Store             val=${alarm}                            name=GNB${postfix}_OAM_ALARM[${i}]
    END
    # Trace and Store                 val=${alarms}                           name=GNB${postfix}_OAM_ALARMS
    Trace and Store                 val=${version}                          name=SW${postfix}
    Trace and Store                 val=${MRBTS_ID${postfix}}               name=MRBTS_ID${postfix}
    Trace and Store                 val=${NRBTS_ID${postfix}}               name=NRBTS_ID${postfix}
    Trace and Store                 val=${NRCELL_DIST_NAME${postfix}}       name=NRCELL_DIST_NAME${postfix}
    [Teardown]                      Run keyword if                          '${entity}'!='None'
    ...                             OAM Disconnect                          ${entity.oam}

Trace and Store
    [Arguments]                     ${val}                                  ${name}
    Dated log                       \t${name}=${val}
    # Store in log file
    Append To File                  ${LOG_PATH}/${STATUS_FILE_NAME}         ${name}=${val}\n\n

Get TL Info Struct
    StringTool.printLineWithTitle   Get INFO on TL from SYS/BB cards (GNB and AP)
    Get Info From cards             airscale=${AIRSCALE_GNB}                kind=GNB
    Get Info From cards             airscale=${AIRSCALE_AP}                 kind=AP
    WA Update Nodes and Logs Def

Get Info From cards
    [Documentation]                 retrieve all info on SYS on Broadband cards from TL
    [Arguments]                     ${airscale}                             ${kind}=GNB
    Get SYS Board Type              airscale=${airscale}
    # no BB board for ASOE
    Run Keyword If                  '${airscale.sys[0].M.boardType}'=='ASOE'
    ...                             Set BB Card List To Empty               airscale=${airscale}
    ...       ELSE                  Get BB Board Type                       airscale=${airscale}
    Set Domain ID upon slot         airscale=${airscale}                    kind=${kind}
    Get Node ID                     airscale=${airscale}
    ${partition}                    Get Active Partition                    airscale=${airscale}
    displayAirscale                 airscale=${airscale}                    partition=${partition}

Get SYS Board Type
    [Documentation]                 Use DDAL commands to identify board type (system card case)
    ...                             Update airscale structure
    ...                             in case of ASIB, Sys[0].S will then point on sys[0].M
    [Arguments]                     ${airscale}
    ...                             ${sysIndex}=${0}
    ${alias}                        SSH Connect                             ${airscale.sys[${sysIndex}].M}
    ${cmd}                          Set variable                            ddal -s ddal_sysinfo_module_get_unit_id 0
    ${SYS_BOARD_TYPE}               SSH Cmd                                 ${cmd} | grep value | cut -d= -f2
    ...                             alias=${alias}
    ${SYS_BOARD_TYPE}               Remove String                           ${SYS_BOARD_TYPE}    '
    ${SYS_BOARD_TYPE}               getStringFromCmdReturn                  ${SYS_BOARD_TYPE}
    ${airscale.sys[0].M.boardType}  Set Variable                            ${SYS_BOARD_TYPE}
    ${airscale.sys[0].S.boardType}  Set Variable                            ${SYS_BOARD_TYPE}
    # In case of ASIB, ASIL or ASOE, no slave. So, slave is pointing on master (else [ASIK] keep ${airscale.sys[0].S})
    ${airscale.sys[0].S}            Set variable if
    ...                             '${SYS_BOARD_TYPE}'=='ASIB' or '${SYS_BOARD_TYPE}'=='ASIL' or '${SYS_BOARD_TYPE}'=='ASOE'
    ...                             ${airscale.sys[0].M}                    ${airscale.sys[0].S}
    ${airscale.slotNumber}          Get Slot Number                         ${airscale.sys[0].M}
    ${airscale.domainId}            Get Domain Id                           ${airscale.sys[0].M}
    Set Global Variable             ${airscale}
    Set Airscale sshId              ${airscale}
    [Return]                        ${SYS_BOARD_TYPE}

Set Domain ID upon slot
    [Arguments]                     ${airscale}                             ${kind}
    return from keyword if          '${airscale.domainId}'!='${EMPTY}'
    ${domainId}                     set variable if                         '${airscale.slotNumber}'=='0'
    ...                             ${1}                                    ${2}
    ${domainId}                     set variable if                         '${kind}'=='AP'
    ...                             ${domainId}+${4}                        ${domainId}
    ${airscale.domainId}            set variable                            ${domainId}
    Set Global Variable             ${airscale}

Get Slot Number
    [Arguments]                     ${host}
    ${slotNumber}                   SSH Connect and Cmd
    ...                             command=cat /proc/device-tree/soc-identity/chassis-slot-number
    ...                             host=${host}
    ${slotNumber}                   get subString                           ${slotNumber}   0   1
    [Return]                        ${slotNumber}

Get Domain Id
    [Arguments]                     ${host}
    ${alias}                        SSH Connect                             ${host}
    ${cmd}                          Set variable                            ddal -s ddal_sysinfo_module_get_domain_id 0
    ${domainId}                     SSH Cmd                                 ${cmd} | grep dmid | cut -d= -f2
    ...                             alias=${alias}
    ${domainId}                     getStringFromCmdReturn                  ${domainId}
    Run Keyword If                  '${domainId}'=='${EMPTY}'               Fail    Cannot retrieve the domain ID form the testline
    # StringTool.printHeaderLine      name=${host.alias}:Domain ID            value=${domainId}
    [Return]                        ${domainId}

Set Airscale sshId
    [Arguments]                     ${airscale}
    # for ASIB,  no domain id string inside ssh ids
    ${domainStr}                    set variable if
    ...                            '${airscale.domainId}'=='${EMPTY}' or '${airscale.sys[0].M.boardType}'=='ASIB'
    ...                             ${EMPTY}                                -${airscale.domainId}
    # Take initial slot number
    ${sn}                           Set Variable                            ${airscale.slotNumber}
    ${airscale.sys[0].M.sshId}      set variable                            fct${domainStr}-${sn}a
    # In case of ASIB, no slave card is expected
    ${airscale.sys[0].S.sshId}      set variable if                         '${airscale.sys[0].M.boardType}'=='ASIB'
    ...                             ${airscale.sys[0].M.sshId}              fct${domainStr}-${sn}b
    # Increment slot number for first ABIL card
    ${sn}                           Convert To Integer                      ${sn}
    ${sn}                           Evaluate                                ${sn}+1
    ${airscale.bb[0].M.sshId}       set variable                            fsp${domainStr}-${sn}a
    ${airscale.bb[0].S.sshId}       set variable                            fsp${domainStr}-${sn}b
    ${airscale.bb[0].L1.sshId}      set variable                            fsp${domainStr}-${sn}c
    Set Global Variable             ${airscale}

Set BB Card List To Empty
    [Documentation]                 Set the airscale BB card list to empty
    [Arguments]                     ${airscale}

    # ${airscale.bb}                  Set Variable     ${None}
    ${airscale.bb}                    Create List

Get BB Board Type
    [Documentation]                 Use DDAL commands to identify board type (broadband card case)
    [Arguments]                     ${airscale}
    ...                             ${bbIndex}=${0}
    ${alias}                        SSH Connect                             ${airscale.bb[${bbIndex}].M}
    ${cmd}                          Set variable                            ddal -s ddal_sysinfo_module_get_unit_id 0
    ${BB_BOARD_TYPE}                SSH Cmd                                 ${cmd} | grep value | cut -d= -f2
    ...                             alias=${alias}
    ${BB_BOARD_TYPE}                Remove String                           ${BB_BOARD_TYPE}    '
    ${BB_BOARD_TYPE}                getStringFromCmdReturn                  ${BB_BOARD_TYPE}
    ${airscale.bb[0].M.boardType}
    ...                             Set Variable        ${BB_BOARD_TYPE}
    ${airscale.bb[0].S.boardType}
    ...                             Set Variable        ${BB_BOARD_TYPE}
    ${airscale.bb[0].L1.boardType}
    ...                             Set Variable        ${BB_BOARD_TYPE}
    [Return]                        ${BB_BOARD_TYPE}

Get UEid upon Topology
    [Documentation]                 Return the UE_id values usable in some KW according to used topology.
    ...                             At the moment the value is 11 for SANSA, 1 for others
    ${UE_id}                        Set Variable If                         ${isSANSA}
    ...                             11                                      1
    [Return]                        ${UE_id}

Get Node ID
    [Documentation]                 Connect on airscale and use /usr/bin/ownnid command to identify its nodeId
    [Arguments]                     ${airscale}
    ...                             ${sysIndex}=0
    ${alias}                        SSH Connect                             ${airscale.sys[${sysIndex}].M}
    ${airscale.sys[0].M.nodeId}     Airscale.getNodeId                      connection=${alias}

    ${airscale.listNodeId}          create List
    ...                             0x${airscale.domainId}0
    # ASOE has only 1 node, other boards have 2 nodes
    Run Keyword If                  '${airscale.sys[0].M.boardType}'!='ASOE'
    ...                             Append To List 	${airscale.listNodeId}    0x${airscale.domainId}2
    Set Global Variable             ${airscale}

Get Active Partition
    [Documentation]                 Read active partition on an airscale, using 2 methods:
    ...                             1) launch of command uboot_env get active_partition
    ...                             2) look into /ffs if run is pointing on fs1 or fs2
    ...                             Result is a string, aggregation of thoses 2 methods : <resMethod1> (<resMethod2>)
    [Arguments]                     ${airscale}=${AIRSCALE_GNB}
    ${alias}                        SSH Connect                             host=${airscale.sys[0].M}
    ${partMethod1}                  SSH Cmd                                 uboot_env get active_partition | cut -d "=" -f2
    ...                             alias=${alias}
    ${partMethod1}                  getStringFromCmdReturn                  ${partMethod1}
    ${partMethod2}                  SSH Exec                                ls -al /ffs/ | grep run
    ...                             alias=${alias}
    ${partMethod2}                  Fetch From Right                        ${partMethod2}      ->
    ${partMethod2}                  getStringFromCmdReturn                  ${partMethod2}
    ${partMethod2}                  set variable                            ${partMethod2.replace(" ","")}
    [Return]                        ${partMethod1} (${partMethod2})

Get Sos Report
    [Documentation]      Get Sos Report on WTS
    ${alias}                            SSH Connect                             ${HOST_EPCSIM}
    Dated Log                           \tStart generating Sos Report
    ${output}                           SSH Exec                                rm %{HOME}/SosReport*tgz
    ...                                 alias=${alias}
    # the .tgz file is generated in $HOME directory
    ${output}                           SSH Cmd                                 ${tl.core.dir_path}/sosReport.sh -nr -c -s
    ...                                 alias=${alias}                          timeout=900
    should contain                      ${output}                               _complete_iphy1.tgz created
    # rename the SOS Report file
    ${current_date}=                    DateTime.Get Current Date               result_format=%Y%m%d
    ${sos_src_file}                     set variable                            %{HOME}/SosReport${current_date}_*.tgz
    # remove space and ' from TEST_NAME (otherwise the filename is invalid)
    ${tmp1_test_name}                   replace string                          ${TEST_NAME}         ${SPACE}    ${EMPTY}
    ${tmp_test_name}                    replace string                          ${tmp1_test_name}    \u2019      ${EMPTY}
    ${sos_dst_file}                     set variable                            %{HOME}/SosReport_${tmp_test_name}.tgz
    ${output}                           SSH Exec                                mv ${sos_src_file} ${sos_dst_file}
    ...                                 alias=${alias}
    # download the SOS report to the local dir
    ${timestamp}=                       DateTime.Get Current Date               result_format=%Y%m%d-%H%M%S
    ${local_sos_file}                   Set variable                            ${LOG_PATH}/SosReport_${tmp_test_name}.tgz
    csn.download_file                   remote_path=${sos_dst_file}
    ...                                 local_path=${local_sos_file}
    ...                                 connection=${alias}
    Dated Log                           \tSos Report = ${local_sos_file}

Get Snapshot
    [Documentation]                     Get GNB snapshot
    Dated Log                           \tStart getting snapshot from OAM
    ${snapshot_path}=                   OAM Get Snapshot
    Dated Log                           \tSnapshot = ${snapshot_path}

Check Network Type
    ${gNbCuType}                        Run
    ...                                 grep -m 1 gNbCuType ${SCF_SETUP_PATH}|awk -F'>' '{print $2}'|cut -d"<" -f1
    ${cellDepType}                      Run
    ...                                 grep -m 1 cellDepType ${SCF_SETUP_PATH}|awk -F'>' '{print $2}'|cut -d"<" -f1
    should be true                      '${cellDepType}'=='${gNbCuType}'
    set suite variable                  ${NWtype}                               ${gNbCuType}

Set Gscn Parameter Name
    # ${gscnPattern}                      Run
    # ...                                 grep gscnOrSsPbchArfcn ${SCF_SETUP_PATH}|awk -F'>' '{print $2}'|cut -d"<" -f1
    ${gscnPattern} =                    OperatingSystem.Grep File               ${SCF_SETUP_PATH}           gscnOrSsPbchArfcn
    ${nomalizedPattern} =               set variable    ${gscnPattern.replace('\r','\\r').replace('\n','\\n')}
    Dated Log                           \tgscnPattern = ${nomalizedPattern}
    ${gscnParameterName}                set variable if    '${nomalizedPattern}' == '${EMPTY}'    gscn    gscnOrSsPbchArfcn
    set suite variable                  ${gscnParameterName}
    Dated Log                           \tgscn parameter name = ${gscnParameterName}

Manage Additional UE
    # Fix for the addition of UEs in basic_setup.cfg (id=2,12) file for LO topology
    ${cfg_path}    Set Variable     ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${cmd}    set variable    sed -i -e '/^set_ue simulated id=[0,2-9]/d' -e '/^set_ue simulated id=[0-9][0,2-9]/d' ${cfg_path}
    ${res}    run    ${cmd}
    ${cmd}    set variable    sed -i -e '/^ue_param id=[0,2-9]/d' -e '/^ue_param id=[0-9][0,2-9]/d' ${cfg_path}
    ${res}    run    ${cmd}
    ${cmd}    set variable    sed -i -e '/^set_pdu_gateway id=[0,2-9]/d' -e '/^set_pdu_gateway id=[0-9][0,2-9]/d' ${cfg_path}
    ${res}    run    ${cmd}
    ${cmd}    set variable    sed -i -e '/^set_bearer id=2 ue=[0,2-9]/d' -e '/^set_bearer id=2 ue=[0-9][0,2-9]/d' ${cfg_path}
    ${res}    run    ${cmd}
