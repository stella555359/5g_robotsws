*** Settings ***
Documentation       7738 GENERIC TEST. Author : Franck NGOUNE
Library             OperatingSystem
Library             Collections
Library             DateTime
Library             taf.transport.ssh    WITH NAME    csn
Library             taf.config.scf       WITH NAME    scf
Library             taf.lteemu           WITH NAME    lteemu
Library             ute_wtssim           WITH NAME    wts
Library             taf.sbts.oam.coam.admin            WITH NAME               coam
Library             ../../../resources/python/luashark_tools.py
Library             luashark_tools.analyzer       WITH NAME       analyzer
Library             ../../../../../resources/SWENG/python/StringTool.py

Resource            ../../../../../resources/SWENG/robot/GenericTest.robot

Resource            CB007738_Kw_TestSetup.robot

Library             ../python/Constants.py         WITH NAME               MyConstants
Library             ../python/tools.py             WITH NAME               nps_7738_tools

Library             ../python/tools.py     WITH NAME    nps_dss_tools
Library             ../python/Common.py
Library             ../../../resources/DSS/python/robot_extension.py      WITH NAME          robot_extension

Resource            ../../../../../resources/SWENG/robot/Counters.robot

# DSS specific
Resource         ../../../resources/DSS/robot/common_Dss_Keywords.robot
Resource         ../../../resources/DSS/robot/common_Dss_command.robot
Resource         ../../../resources/DSS/robot/common_Dss_SA_NSA.robot
Resource         ../../../resources/DSS/robot/common_Dss_CellSetup.robot

Variables           ../../../../../resources/SWENG/python/ReadConfig.py

# 7738 specific
Resource         pcap.robot

*** Variables ***

${kill_btslog}     timeout 5 sudo kill -9 $(ps -ef|grep btslog|grep -v grep|awk '{print $2}') 1>/dev/null 2>&1
${kill_dpkg}       timeout 5 sudo kill -9 $(ps -ef|grep dpkg|grep tti-dec.deb|grep -v grep|awk '{print $2}') 1>/dev/null 2>&1
${kill_sherpa}     timeout 5 sudo kill -9 $(ps -ef|grep ./Sherpa|grep -v grep|grep -v run|awk '{print $2}') 1>/dev/null 2>&1

*** Keywords ***

Clean Up Env
    [Arguments]    ${host_ip}=localhost
    [Documentation]    This keyword is to clean up testline process such as btslog and so on.
    ...    Examples:
    ...    | Clean Up Env |
    ${HOME}=    Get Environment Variable    name=HOME
    Run Keyword If     '${host_ip}'=='127.0.0.1' or '${host_ip}'=='localhost'    Run Keywords    Run     ${kill_btslog}
    ...     AND     Run   ${kill_dpkg}
    ...     AND     Run   ${kill_sherpa}
    ...     AND     Run    rm /tmp/admin_api_*.txt -f
    ...     AND     Run    rm /tmp/disconnect*.ims2 -f
    ...     AND     Run    rm ${EXECDIR}/admin_api_*.txt -f
    ...     AND     Run    rm ${EXECDIR}/disconnect*.ims2 -f
    ...     AND     Run    rm ${HOME}/SosReport*.tgz -f
    ...     AND     Run    rm ${HOME}/WTS*.tgz -f
    ...     AND     run keyword and ignore error   Run   command=cd ${EXECDIR}; find . -name '*disconnect*.ims2' -type f -print -exec rm -rf {} \\;
    ...     AND     Run    rm /tmp/*.pcap* -rf
    ...     AND     Run    sudo rm /tmp/*.pcap* -rf
    ...     ELSE    Run keywords    SSH.Connect To    ${host_ip}    ute    ute    alias=remote_connection
    ...     AND     SSH.Execute    ${kill_btslog}    connection=remote_connection
    ...     AND     SSH.Disconnect    connection=remote_connection

# here , for the moment , force ${shouldUseLua}=${True} only for NSA => to improve with new archi....
Start WTS for NSA
   #[Arguments]                 ${egate_alias}=egate    ${edaemon_alias}=edaemon    ${shouldUseLua}=${True}    ${nbUe}=1
   [Arguments]                 ${egate_alias}=egate       ${shouldUseLua}=${True}    ${nbUe}=1
    Dated log     Start WTS WITH shouldUseLua=${shouldUseLua}
    Setup WTS Only    shouldUseLua=${shouldUseLua}    nbUe=${nbUe}
    Launch WTS   egate_alias=${egate_alias}

TC DSS Phase3 CellSetup
    [Documentation]                Generic test for 1745: test purpose is to setup X2, Xp and DSS CellSetup Phase3
    [Arguments]                    ${param}     ${alias}=default
    Init Sequence                  ${param}
    common_Dss_Keywords.Restart     OwnTLReset=${False}     GNBCallback=common_Dss_Keywords.Set Reset Loop Counter
    # R. Ads
    # Save current SCF file used during test cases
    ${current_scf_file}            OAM Get SCF File            dir=${testCaseDir}      file=SCF_used_for_CNI-95172_${param.seq.bandwidth}_Tests.xml
    Set Suite Variable             ${current_scf_file}
    Dated Log New Line             Current CNI-95172 SCF file stored to ${current_scf_file}
    # end R. Ads
    Step                           Start capture Backhaul XP for DSS     argument=BH.XP.CellSetup     depends=common_Dss_Keywords.Restart
    Step                           Start WTS                    argument=${alias}
    Step                           Wait Xp link Up                 argument=${alias}        depends=Start WTS
    Step                           X2Ap link Setup             argument=${alias}        depends=Start WTS
    Step                           common_Dss_CellSetup.DSS_CRM_Cell_Setup_Phase3    alias=${alias}  wtsObj=${wtsObj}   depends=Wait Xp link Up
    ${pdmlFile}                    Stop capture Backhaul XP for DSS
    Run Keyword if       '${CELLSETUP_SHOULD_BE_CHECK}' == '1'
    ...      Step    common_Dss_CellSetup.Check DSS CellSetup Phase3    argument=${pdmlFile}  depends=common_Dss_CellSetup.DSS_CRM_Cell_Setup_Phase3
    Critical Step                  common_Dss_CellSetup.Wait gNB cell 5g On air     globalCellId=1
    Critical Step                  common_Dss_CellSetup.Verify AP Classical Cell Setup
    [Teardown]               GenericTest.Display diagnosis

TC 7738 CellSetup A1
    [Documentation]                Generic test for 7738: test purpose is to setup X2, Xp and DSS CellSetup Phase3
    [Arguments]                    ${param}     ${alias}=default
    Init Sequence                  ${param}
    common_Dss_Keywords.Restart     OwnTLReset=${False}     GNBCallback=common_Dss_Keywords.Set Reset Loop Counter
    Step                           Start Capture CPRT
    Step                           Start WTS                         argument=${alias}
    Step                           Wait Xp link Up                     argument=${alias}        depends=Start WTS
    Step                           X2Ap link Setup                   argument=${alias}        depends=Start WTS
    Step                           7738_DSS_CRM_Cell_Setup_Phase3    argument=${alias}        depends=Wait Xp link Up
    Step                           Stop Capture CPRT
    Dated log             Point AF_PATH and ENB_BUILD to luashark sw package
    Point ENB_BUILD to luashark sw package
    Point AF_PATH to current sw package
    Step                           Check actLteNrDssFastAlloc in cellSetupreq Pcap          argument=${CaptureCPRT}
    Critical Step                  common_Dss_CellSetup.Verify AP Classical Cell Setup
    Dated log             Point AF_PATH and ENB_BUILD to local luashark XP package
    Point AF_PATH to local luashark XP package
    Point ENB_BUILD to local luashark XP package
    [Teardown]       Run Keywords      Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${CaptureCPRT.path}      AND
    ...                                Run Keyword And Ignore Error    OperatingSystem.Copy File    ${CaptureCPRT.path}    ${testCaseDir}    AND
    ...                                GenericTest.Display diagnosis

TC 7738 CellSetup A2
    [Documentation]                Generic test for 7738: test purpose is to setup X2, Xp and DSS CellSetup Phase3
    [Arguments]                    ${param}     ${alias}=default
    Init Sequence                  ${param}
    common_Dss_Keywords.Restart     OwnTLReset=${False}     GNBCallback=common_Dss_Keywords.Set Reset Loop Counter
    Step                           Start capture Backhaul XP for DSS     argument=BH.XP.CellSetup
    Step                           Start WTS                         argument=${alias}
    Step                           Wait Xp link Up                     argument=${alias}        depends=Start WTS
    Step                           X2Ap link Setup                   argument=${alias}        depends=Start WTS
    Step                           7738_DSS_CRM_Cell_Setup_Phase3    argument=${alias}        depends=Wait Xp link Up
    Dated log             Point AF_PATH and ENB_BUILD to local luashark XP package
    Point AF_PATH to local luashark XP package
    Point ENB_BUILD to local luashark XP package
    ${pdmlFile}                    Stop capture Backhaul XP for DSS
    ${mcshark_present}  ${MCShark}=    pcap.Check MCShark if present
    Run Keyword if     "${mcshark_present}"=="True"   pcap.Convert Xp PCAP To CSV using MCShark to check Dss Cellsetup
    ...                                                            pcap_file=${testCaseDir}/${capture_BH_GNB.name}.pcap
    ...                                                            tc_id=7738_CellSetup
    Run Keyword if     "${mcshark_present}"=="False"   Step      Check dlSharingAlgo in Coordination Msgs                 argument=${pdmlFile}
    # Check using MCShark
    Run Keyword if     "${mcshark_present}"=="True"    Step      Check dlSharingAlgo in Coordination Msgs Using MCShark   argument=${pdmlFile}
    Run Keyword if     "${mcshark_present}"=="True"
    ...       Step    Check enDssDlCellResourceAreaCoordinationUpdateInd inside Pcap Using MCShark
    ...                                                                                   argument=${testCaseDir}/${capture_BH_GNB.name}.pcap
    ...                                                                                   depends=7738_DSS_CRM_Cell_Setup_Phase3
    Critical Step                  common_Dss_CellSetup.Verify AP Classical Cell Setup
    [Teardown]                     GenericTest.Display diagnosis

Check enDssDlCellResourceAreaCoordinationUpdateInd inside Pcap Using MCShark
    [Documentation]      KW used to check DSS enDssDlCellResourceAreaCoordinationUpdateInd inside PDML file
    [Arguments]                     ${pcapFile}
    ${output}=    nps_7738_tools.check_dlResourceSharingAlgo    pcapFile=${pcapFile}
    ...                                                         packetName=xp_dss_xpdssmessage
    ...                                                         packetType=enDssDlCellResourceAreaCoordinationUpdateInd
    should contain     ${output.lower()}    passed   dlResourceSharingAlgo not present in DL Coordination Req/Update Ind as expected

TC 7738 A3 CellSetup, 5g SA attach and UL DL Traffic
    [Documentation]                Generic test for 7738: test purpose is to setup X2, Xp and DSS CellSetup Phase3, 5g SA attach, DL/UL Tput
    ...                            Check nGBR in Load Indication Msgs
    [Arguments]                    ${param}     ${alias}=default
    Init Sequence                  ${param}
    common_Dss_Keywords.Restart     OwnTLReset=${False}     GNBCallback=common_Dss_Keywords.Set Reset Loop Counter
    Step                           Start capture Backhaul XP for DSS    argument=BH.XP.CellSetup
    Step                           Start WTS                        argument=${alias}
    Step                           Wait Xp link Up                    argument=${alias}        depends=Start WTS
    Step                           X2Ap link Setup                  argument=${alias}        depends=Start WTS
    Step                           7738_DSS_CRM_Cell_Setup_Phase3   argument=${alias}        depends=Wait Xp link Up
    Step                           Stop capture Backhaul XP for DSS                          depends=Start capture Backhaul XP for DSS
    Critical Step                  common_Dss_CellSetup.Verify AP Classical Cell Setup
    Step                           common_Dss_SA_NSA.DSS_5g_Call_SA     argument=${alias}        depends=7738_DSS_CRM_Cell_Setup_Phase3
    common_Dss_SA_NSA.DSS_5g_SA_UL_DL_Traffic      ${param}    ul_rate=20    dl_rate=80   alias=${alias}
    Step                           Start capture Backhaul XP for DSS    argument=BH.XP.UL_DL_Tput
    Traced sleep    2s
    Dated log             Point AF_PATH and ENB_BUILD to local luashark XP package
    Point AF_PATH to local luashark XP package
    Point ENB_BUILD to local luashark XP package
    ${pdmlFile}                    Stop capture Backhaul XP for DSS
    Step                           Check nGBR in Load Indication Msgs                argument=${pdmlFile}
    [Teardown]                     GenericTest.Display diagnosis


Teardown 7738
    [Arguments]                 ${alias}=${HOST_EPCSIM.alias}
    [Teardown]      Run Keywords    common_Dss_Keywords.Collect Logs if needed   ${alias}    AND
    ...                             set Suite Variable  ${testCaseDir}  None
    BuiltIn.Log      \nTest ${TEST_NAME} 7738 ending   console=yes

    # get Alarm at the end of the test and store it into a file
    Dated log New Line  OAM Get Active Alarms to Save into file
    ${aliasGNB}                     OAM Connect                             ${GNB_DU.oam}

    ${active_alarms}     OAM Get Active Alarms                   oam=${GNB_DU.oam}      textFormat=${False}
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    ${alarm_name_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
          ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
          ${tmp_name_id}    Get From Dictionary    ${active_alarms[${i}]}    faultName
          Append To List    ${alarm_id_list}    ${tmp_id}
          Append To List    ${alarm_name_list}    ${tmp_name_id}
    # Dated log     Active alarms: alarm_id_list=${alarm_id_list}
    # Dated log     Active alarms: alarm_name_list=${alarm_name_list}
    END
    Append To File    ${LOG_PATH}/OAM_Alarms_After_${TEST_NAME}.txt     Active Alarms Id List:\n${alarm_id_list}\n\n
    Append To File    ${LOG_PATH}/OAM_Alarms_After_${TEST_NAME}.txt     Active Alarms Name List:\n${active_alarms}\n\n

    OAM Disconnect                          ${GNB_DU.oam}

    # Restore WTS cfg file name
    Run Keyword If   '${Param.seq.bandwidth}'!='10MHz'    restoreFilename

    Run Keyword And Ignore Error     common_Dss_Keywords.Collect EGATE console Logs

    # Get EPC file configuration used during 7738 tests
    ${alias_epc}                    SSH Wait For Connect                ${HOST_EPCSIM}
    run keyword and ignore error     csn.download_file          remote_path=${tl.core.dir_path}/${LuaFileName_generated}
    ...                             local_path=${testCaseDir}/basic_wts_used_for_7738_${Param.seq.bandwidth}_Tests.lua
    ...                             connection=${alias_epc}

    # wts.stop_and_collect_wts_logs   subdirectory=${LOG_PATH}
    wts.teardown_all_aliases_for_egate
    wts.teardown_all_aliases_for_edaemon

    # [Teardown]      Run Keywords    GenericTest.Display diagnosis        AND
    # ...                             common_Dss_Keywords.Collect Logs if needed   ${alias}    AND
    # ...                             set Suite Variable  ${testCaseDir}  None

    #FTS



Test suite teardown for CNI-95172
    [Documentation]          Test suite teardown for all CNI-95172 TCs.
    ...                      Restores existing configuration files

    run keyword and ignore error     common_DSS_Keywords.Restore Orignal Configuration DSS
    Run Keyword If                   '${REMOVE_PDML_FILE_END_TEST_SUITE}' == '1'
    ...                              OperatingSystem.Remove File    ${LOG_PATH}/*.pdml
    Run Keyword If                   '${SHOULD_BE_RECOMMISSIONED_GNB}' == '1'       Dated Log
    ...                              Recommissioning gNB with original SCF file
    Run Keyword If                   '${SHOULD_BE_RECOMMISSIONED_GNB}' == '1'
    ...                              run keyword and ignore error     OAM Perform Full Commissioning          ${original_scf_file}
    ${isOAMRebooted}      Run Keyword If        '${SHOULD_BE_RECOMMISSIONED_GNB}' == '1'
    ...                             SSH Was OAM Rebooted         ${GNB_DU}
    ...                             timeout=60
    # If gNB was rebooted after re-commissioning, wait until it's ready again.
    Run Keyword If   '${SHOULD_BE_RECOMMISSIONED_GNB}' == '1'
    ...              Run Keyword If  '${isOAMRebooted}' == 'True'  Airscale Wait for Ready  ${GNB_DU}
    # Run Keyword If           '${isOAMRebooted}' == 'True'        Airscale Wait for Ready         ${GNB_DU}
    common_Dss_Keywords.Conn.ResetCache


Check BTS status in WEM for cOAM
    [Documentation]   This keyword is used to Check BTS status in WEM for cOAM.
    ...    author: Ch SAMSON
    [Arguments]     ${cell_id}=0
    BuiltIn.log     cell_id=${cell_id}
    ${aliasGNB}                     OAM Connect                             ${GNB_DU.oam}
    ${bts_status}=    coam.get_bts_statuses    timeout=30    connection=${GNB_DU.oam.httpAlias}
    Dated log      =======> Current bts status is ${bts_status}
    # should be equal    ${bts_status['operationalState']}     Enabled         ignore_case=true
    should be equal    ${bts_status['proceduralState']}       configured       msg=ENB is not OK, status is ${bts_status}
    ...                                                                        ignore_case=true
    # should be equal    ${bts_status['proceduralState']}       OnAir          ignore_case=true
    should be equal    ${bts_status['blockingState']}       Unblocked            ignore_case=true

    ${cell_info}=    coam.get_cells_info    cell_type=nr    timeout=30    connection=${GNB_DU.oam.httpAlias}
    Dated log      =======> Current cell(s) info is ${cell_info}
    FOR    ${elem}    IN    @{cell_info}
#    ${cell_info}=    set variable   ${cell_info[${cell_id}]['status']}
#        Should be equal    ${elem['status']['operationalState']}    Enabled    ignore_case=true
#        Should be equal    ${elem['status']['proceduralStatus']}    configured    ignore_case=true
        Should be equal    ${elem['status']['proceduralStatus']}    not initialized    ignore_case=true
        Should be equal    ${elem['status']['administrativeState']}    Unlocked    ignore_case=true
    END
    OAM Disconnect                  ${GNB_DU.oam}

Restart TL wo WTS clear
    [Documentation]                 Entry point for the restart of a TL, Classical only , without WTS clear
    [Arguments]                     ${GNBCallback}=None                     ${APCallback}=None
    ...                             ${isOAMRebooted}=False
    Dated Log                       Start Restart TL ${TLConfig.configName}. Is GNB Cloud: ${TLConfig.isGnbCloud}
    ...                             first=True
    Private Restart Gnb Classical           GNBCallback=${GNBCallback}          APCallback=${APCallback}
    ...                             isOAMRebooted=${isOAMRebooted}


reset TL if BTS not OnAir
    [Arguments]  ${connection}=${GNB_DU.oam}
    ${aliasGNB}                     OAM Connect                             ${connection}
    ${bts_status}=  coam.get_bts_statuses   connection=${connection.httpAlias}
    OAM Disconnect                  ${GNB_DU.oam}
    Dated log     BTS procedural state is now: ${bts_status["proceduralState"]}
    ${gnb_status}=     evaluate    '${bts_status["proceduralState"]}'.lower()
    Run Keyword If  '${gnb_status}'!='OnAir'.lower() and '${gnb_status}'!='Configured'.lower()
    ...          Run Keywords       Log To Console  \n BTS procedural state is now: ${bts_status["proceduralState"]} ==> Reset TL    AND
    ...                             Restart TL wo WTS clear     AND
    ...                             run keyword and ignore error        Start WTS        egate_alias_default   AND
    ...                             run keyword and ignore error        X2Ap link Setup     egate_alias_default


Get gNB cell 5g On air
    [Documentation]       get gNB 5g cell On air
    Return From Keyword If    "${WAIT_5G_CELL_ONAIR}" == "0"
    Log to Console like Next Step     0     Get gNB 5g cell OnAir
    ${aliasGNB}                     OAM Connect                             ${GNB_DU.oam}
    ${bts_status}=  coam.get_bts_statuses   connection=${GNB_DU.oam.httpAlias}
    OAM Disconnect                  ${GNB_DU.oam}
    Log To Console  \n BTS procedural state is now: ${bts_status["proceduralState"]}
    ${gnb_status}=     evaluate    '${bts_status["proceduralState"]}'.lower()
    Return From Keyword If    '${gnb_status}'=='OnAir'.lower() or '${gnb_status}'=='Configured'.lower()
    run keyword and ignore error        Start WTS        egate_alias_default
    run keyword and ignore error        X2Ap link Setup     egate_alias_default
    run keyword and ignore error        wait until keyword succeeds    2min    30s      Check BTS status in WEM for cOAM
    Dated log new line         =======> Restart TL if needed to get Cell Is OnAir/Configured
    run keyword and ignore error        reset TL if BTS not OnAir
    run keyword and ignore error        wait until keyword succeeds    5min    30s      Check BTS status in WEM for cOAM

Install MCShark if Needed
    [Arguments]               ${current_sw_version}=None
    ${mcshark_present}  ${MCShark}=    pcap.Check MCShark if present
    ${logs_dir}=    run Keyword if   "${mcshark_present}"=="False"
    ...                        common_Dss_Keywords.Prepare Logs Directory Path   resultDir=${LOG_PATH}   subdir=install_Logs    with_timestamp=True
    ...   ELSE                 set variable    None
    run Keyword if   "${mcshark_present}"=="False"    pcap.Install wslte plugins for MCShark    sw_version=${current_sw_version}
    ...                                                                                         local_dir=${logs_dir}
    ...   ELSE     Dated log    wslte plugins for MCShark ${MCShark} already installed
    # update variable
    ${mcshark_present}   ${MCShark}=      pcap.Check MCShark if present
    ${msg}=   run Keyword if   "${mcshark_present}"=="True"    StringTool.getHeaderLine    MCShark plugin   ${MCShark}
    ...   ELSE                                        StringTool.getHeaderLine    MCShark plugin     Not installed
    run Keyword if   "${msg}"!="${EMPTY}"      Dated log      ${msg}
    set suite variable    ${mcshark_present}

set WS preference
    ${pref_items}=  set Variable   decode_as_entry: tcp.port,29211,(none),SYSCOM
    ${profile_name}=   pcap.wireshark.CreatePersonalConfProfile   pref_items=${pref_items}
    ...                                        profie_path=/home/ute/.config/wireshark/profiles
    ...                                        profile_name=customized_profile
    ...                                        filename=decode_as_entries
    Dated log    ${profile_name} created or updated with ${pref_items} ...
    ${profile_name}=   pcap.wireshark.CreatePersonalConfProfile   pref_items=${pref_items}
    ...                                        profie_path=/home/ute/.config
    ...                                        profile_name=wireshark
    ...                                        filename=decode_as_entries
    Dated log    ${profile_name} created or updated with ${pref_items} ...

Test Suite Setup for CNI-95172
    [Documentation]          Test suite setup for all CNI-95172 TCs.
    ...                      It calls Test Suite Setup common KW and:
    ...                      Saves existing configuration files (swconfig + WTS)
    ...                      Configure common SCF parameters
    ...                      Configure common swconfig parameters
    ...                      Configure common WTS parameters
    #[Arguments]               ${default_mcs}=0

    # Call to generic test suite setup KW
    setup.Suite Setup

    run Keyword           MyConstants.hello
    ${mcshark_present}   ${MCShark}=      pcap.Check MCShark if present
    ${msg}=   run Keyword if   "${mcshark_present}"=="True"    StringTool.getHeaderLine    MCShark plugin   ${MCShark}
    ...   ELSE                                        StringTool.getHeaderLine    MCShark plugin     Not installed
    run Keyword if   "${msg}"!="${EMPTY}"      Dated log      ${msg}
    set suite variable    ${mcshark_present}
    Dated Log New Line    COLLECT_LOGS if TEST STATUS is FAIL and EXCLUDE_LOGS_IF_FAIL == 0
    Dated Log             COLLECT_LOGS if COLLECT_LOGS == 1
    Dated log             default_test_strategy : WAIT_5G_CELL_ONAIR = ${WAIT_5G_CELL_ONAIR}
    Dated Log             default_test_strategy : SHOULD_BE_COMMISSIONED_GNB_FIRST = ${SHOULD_BE_COMMISSIONED_GNB_FIRST}
    Dated log             default_test_strategy : SHOULD_UPDATE_SCF_AND_RAD = ${SHOULD_UPDATE_SCF_AND_RAD}
    Dated log             default_test_strategy : SHOULD_UPDATE_RAD = ${SHOULD_UPDATE_RAD}
    Dated log             default_test_strategy : CELLSETUP_SHOULD_BE_CHECK = ${CELLSETUP_SHOULD_BE_CHECK}
    Dated log             default_test_strategy : UL_TPUT_SHOULD_BE_CHECK = ${UL_TPUT_SHOULD_BE_CHECK}
    Dated log             default_test_strategy : SHOULD_BE_RECOMMISSIONED_GNB = ${SHOULD_BE_RECOMMISSIONED_GNB}
    Dated log             default_test_strategy : COLLECT_LOGS = ${COLLECT_LOGS}
    Dated log             default_test_strategy : EXCLUDE_LOGS_IF_FAIL = ${EXCLUDE_LOGS_IF_FAIL}
    Dated log             default_test_strategy : PCAP_XP_BIP_L1L2_ATTACH = ${PCAP_XP_BIP_L1L2_ATTACH}
    Dated log             default_test_strategy : REMOVE_PDML_FILE_END_TEST_SUITE = ${REMOVE_PDML_FILE_END_TEST_SUITE}
    Dated log             default_test_strategy : TRAFFIC_DL_RATE = ${TRAFFIC_DL_RATE}
    Dated log             default_test_strategy : TRAFFIC_UL_RATE = ${TRAFFIC_UL_RATE}
    Dated log             default_test_strategy : UL_DL_TPUT_CHECK_BASED_AASYSLOG = ${UL_DL_TPUT_CHECK_BASED_AASYSLOG}
    Dated log             default_test_strategy : UL_TPUT_CHECK_BASED_TTITRACE = ${UL_TPUT_CHECK_BASED_TTITRACE}
    Dated log             default_test_strategy : WITH_UPLOAD_1586_CONFIGURATION = ${WITH_UPLOAD_1586_CONFIGURATION}
    Dated log             default_test_strategy : WITH_MCSHARK_INSTALATION = ${WITH_MCSHARK}
    Dated log             default_test_strategy : SharkTool = ${SharkTool}
    Dated log             default_test_strategy : SHOULD_UPDATE_DEBUG_L2PS_RAD = ${SHOULD_UPDATE_DEBUG_L2PS_RAD}

    common_DSS_Keywords.Create Test Suite Folder
    common_DSS_Keywords.Clean Old WTS Logs
    common_DSS_Keywords.Get Testline Name
    run keyword and ignore error     common_DSS_Keywords.Get Orignal Configuration DSS
    robot_extension.Run Keyword And Warn On Failure    common_DSS_Keywords.Init Trace color
    common_Dss_Keywords.Connect to COAM ADMIN

    ${test_scf_file}             OAM Get SCF File            dir=${LOG_PATH}      file=SCF.xml
    Set Suite Variable              ${test_scf_file}
    ${cellDepType}=   CB007738_Kw_TestSetup.get cellDepType from SCF
    ${TestDSS10Mhz_7738_A1.Context.cellDepType}      set variable    ${cellDepType}
    ${TestDSS10Mhz_7738_B10.Context.cellDepType}      set variable    ${cellDepType}
    # BEWARE : lines commented here because eNBId=1 and gNBId=2 to be able to perform SA and NSA 5g Call
    # run Keyword if    '${TestDSS10Mhz_7738_A1.Context.cellDepType}' == 'SA+NSA'
    # ...                    CB007738_Kw_TestSetup.update eNbId and gNBId In Context   ${TestDSS10Mhz_7738_A1}   2   1
    ${TestDSS10Mhz_7738_A1.scfFile.nrdsslte.eNodeBId}    set variable     ${TestDSS10Mhz_7738_A1.Context.eNBId}
    ${TestDSS10Mhz_7738_B10.scfFile.nrdsslte.eNodeBId}    set variable     ${TestDSS10Mhz_7738_B10.Context.eNBId}

    #Run Keyword If   '${WITH_UPLOAD_1586_CONFIGURATION}' == '0'     run Keyword
    common_DSS_Keywords.Update SpecificParameters to setup DSS configuration In WTS Cfg File    ${TestDSS10Mhz_7738_A1}
    common_DSS_Keywords.Update SpecificParameters to setup DSS configuration In WTS Cfg File    ${TestDSS10Mhz_7738_B10}

    # &{UE_SIMPLE_CellDSS}                ue=1                                    profile=1
    # ...                                 bearer=2                                testMode=False
    # ...                                 trf_id=1                                burst=${None}
    # ...                                 throughput=${DEFAUT_THROUGHPUT}         testModeValue=csi_report_override
    # ...                                 target_gnb=2                            target_cells=1

    #define UE profile for Mono-Ue tests (cell-2.1)
    ${UE_SIMPLE_CellDSS}                 Tools.Dictionary Get              ${UE_SIMPLE}
    ${UE_SIMPLE_CellDSS.target_gnb}      set Variable	       ${TestDSS10Mhz_7738_A1.Context.gNBId}
    ${UE_SIMPLE_CellDSS.target_gnb}      set Variable	       ${TestDSS10Mhz_7738_B10.Context.gNBId}
    ${UE_SIMPLE_CellDSS.target_cells}    set Variable	       1
    ${UE_SIMPLE_CellDSS.ue}              set Variable	       ${TestDSS10Mhz_7738_A1.Context.UeId1}
    ${UE_SIMPLE_CellDSS.ue}              set Variable	       ${TestDSS10Mhz_7738_B10.Context.UeId1}
    Set Suite Variable              ${UE_SIMPLE_CellDSS}

    ${CAPTURE_L1L2_GNB_FS_GNB_DSS}                Capture L1L2 Set Upon Config
    Set Suite Variable              ${CAPTURE_L1L2_GNB_FS_GNB_DSS}

    Dated log                       Get SW Version from OAM
    ${sw_version}=    common_DSS_Keywords.Fetch common OAM SW version
    Set Suite Variable              ${my_sw_version}                           ${sw_version}
    Set Suite Metadata    gNB sw    ${sw_version}

    ${ap_version}=    robot_extension.Run Keyword And Warn On Failure       common_DSS_Keywords.Get Airphone SW version

    common_DSS_Keywords.Software Converter    ${my_sw_version}    0
    ${sw_version_list}     Split String   ${my_sw_version}   _
    Set Suite Variable     ${trunk}     False
    Set Suite Variable     ${branch}     None
    Run Keyword If                  '${master_version}' == '0'        Set Suite Variable     ${trunk}     False
    Run Keyword If                  '${master_version}' == '9999'     Set Suite Variable     ${trunk}     True
    ${branch}              Get From List    ${sw_version_list}    0
    Dated log                       \tGNB_SW_VERSION=${my_sw_version}
    Dated log                       \tconvert_version=${convert_version}
    Dated log                       \tmaster_version=${master_version}
    Dated log                       \ttrunk=${trunk}
    Dated log                       \tbranch=${branch}

    ${sw_version}=        pcap.Get Software Version
    Set Suite Variable     ${current_sw_version_for_lua_gNB}     ${my_sw_version}
    Dated log      sw version for lua gNB is ${current_sw_version_for_lua_gNB}

    run Keyword if    '${trunk}' == 'True'         set WS preference
    run Keyword if    '${WITH_MCSHARK}' == '1'     run Keyword and ignore Error    Install MCShark if Needed
    ...                                                                         current_sw_version=${current_sw_version_for_lua_gNB}

    # needed to install only once
    Dated Log         First Do install Mirroring scripts in GNB
    common_DSS_Keywords.Get gNB mirroring into local repo  scriptDef=${CAPTURE_L1L2_GNB_FS_GNB_DSS.scriptDef}
    common_DSS_Keywords.Mirror Script Install for DSS     scriptDef=${CAPTURE_L1L2_GNB_FS_GNB_DSS.scriptDef}
    ...                                                   PathToScriptsRepo=${LOCAL_REPO_DIR}

    ${the var}=    Get Variable Value    ${AF_PATH}
    ${AF_PATH is set}=      Set Variable If    """${the var}""" != 'None'    ${True}    ${False}
    Dated log     AF_PATH is set to ${AF_PATH is set} => set it to empty if False
    set suite variable    ${AF_PATH is set}
    run Keyword if   "${AF_PATH is set}"=="False"      set suite variable   ${AF_PATH}     ${empty}
    ${the var}=    Get Variable Value    ${ENB_BUILD}
    ${ENB_BUILD is set}=      Set Variable If    """${the var}""" != 'None'    ${True}    ${False}
    Dated log     ENB_BUILD is set to ${ENB_BUILD is set} => set it to empty if False
    set suite variable     ${ENB_BUILD is set}
    run Keyword if   "${ENB_BUILD is set}"=="False"      set suite variable   ${ENB_BUILD}     ${empty}
    Dated log    AF_PATH is ${AF_PATH}
    Dated log    ENB_BUILD is ${ENB_BUILD}

    Dated Log    First Do install Xp LuaShark
    # make implode  => zip src dir to generated_luashark-9.1800.330.zip if needed
    ${output}=   run   command= ls ${CURDIR}/../../../resources/DSS/XpShark/9.1800.330/generated_luashark-9.1800.330.zip
    log many     ${output}
    ${contains}=    Run Keyword And Return Status    Should Contain    ${output}     No such file or directory
    run keyword if    "${contains}"=="${True}"     run    command=cd ${CURDIR}/../../../resources/DSS/XpShark/9.1800.330 && make implode
    Do install Xp LuaShark into home     ${CURDIR}/../../../resources/DSS/XpShark/9.1800.330/generated_luashark-9.1800.330.zip

    Dated log             Point AF_PATH and ENB_BUILD to local luashark XP package
    pcap.Point AF_PATH to local luashark XP package
    pcap.Point ENB_BUILD to local luashark XP package

    Run Keyword if   '${GNB_DU.sys[0].M.boardType}'=='ASIK'      Dated log    Install classicalbts log collector into gNB     AND
    ...                                                          CB007738_Kw_TestSetup.Install classicalbts log collector into gNB

    Run Keyword if   '${GNB_DU.sys[0].M.boardType}'=='ASIK'      Dated log    Install classicalbts log collector into Airphone     AND
    ...                                                          CB007738_Kw_TestSetup.Install classicalbts log collector into Airphone


Check actPrachMultiplexing and get prachPrbOffset values in ps_CellSetupReq
    [Arguments]                    ${testParam}
    Dated log                      path: ${CaptureCPRT.path}
    ${pdmlFile}=                   analyzer.pcap_to_pdml           ${CaptureCPRT.path}

    Check Field In Message             ${pdmlFile}
    ...                            itf_l2_ps_cell_CellSetupReq
    ...                            CellSetupReq.actPrachMultiplexing
    ...                            ${testParam.ActFlag}

	${prachPrbOffset_hex}          get_unique         pdmlFile=${pdml_file}
    ...                             			      packetName=itf_l2_ps_cell_CellSetupReq
    ...                             		    	  path=.*/itf_l2_ps_cell_CellSetupReq.rachConfig.prachPrbOffset
    ...                             			      kind=show
    ...                             			      startPacket=${1}
    ...                             				  endPacket=${1}

	${prachPrbOffset_int}           Convert To Integer     ${prachPrbOffset_hex}

    Set Suite Variable        ${prachPrbOffset_int}

Start capture Backhaul XP for DSS
   [Arguments]                    ${prefix}=BH.XP
    ${capture_BH_GNB}=             set Backhaul Capture                     prefix=${prefix}
    ${capture_BH_GNB}=             Initialize Filter XP message Capture     capture=${capture_BH_GNB}
    set global variable            ${capture_BH_GNB}
    common_Dss_Keywords.Start capture Backhaul XP for DSS New               capture=${capture_BH_GNB}

Stop capture Backhaul XP for DSS TO REMOVE LATER
    ${pdmlFile}      common_Dss_Keywords.Stop capture for Backhaul XP DSS New     capture=${capture_BH_GNB}
    ...                                                             lua_path=/home/ute/tools/luashark/generated_luashark-9.1800.330/luashark.lua
    [return]    ${pdmlFile}

Stop capture Backhaul XP for DSS
    # 21/03/2022 : remove lua_path=/home/ute/tools/luashark/generated_luashark-9.1800.330/luashark.lua to point to xpshark lua delivered by UTE
    # 24/03/2022 : make it dynamic...
    ${mcshark_present}  ${MCShark}=    pcap.Check MCShark if present
    run Keyword if   "${mcshark_present}"=="True"    Dated log    Stop capture for Backhaul XP and decode using MCShark plugin ${MCShark}
    ${pdmlFile}   run Keyword if   "${mcshark_present}"=="False"   common_Dss_Keywords.Stop capture for Backhaul XP DSS New
    ...                                                                capture=${capture_BH_GNB}
    ...                                                                lua_path=/home/ute/tools/luashark/generated_luashark-9.1800.330/luashark.lua
    ...   ELSE                                                     common_Dss_Keywords.Stop capture for Backhaul XP DSS New
    ...                                                                capture=${capture_BH_GNB}
    ...                                                                lua_path=None
    [return]    ${pdmlFile}

Start capture Bip and Xp for 7738
    [Documentation]                Start capture Bip and Xp for 2574
    [Arguments]                    ${prefix}=XP_L1L2_BIP

    # set a specific name to keep the trace
    ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH}               Capture L1L2 Set Upon Config
    ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.prefix}         set Variable   ${prefix}
    ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.withTN}         set Variable   False
    Set Suite Variable              ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH}

    ${capture_BH_GNB}=             set Backhaul Capture                     prefix=BH.XP
    set global variable            ${capture_BH_GNB}
    ${capture_BH_GNB}=             Initialize Filter XP message Capture     capture=${capture_BH_GNB}

    # ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.filter}       Get Filter all BIP msgs
    # to manage the case vlan218 encapsulated within vlan305 (seen with ABIO / ABIP) and the case vlan218 only (seen with ABIP & ABIL)
    ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.filter}       set variable   ether[12:2]=0x8951 or ether[16:2]=0x8951
    ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.filter}       Catenate    ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.filter}

    # Initialize Capture                ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH}
    # ==== Capture Init Kw introduce 30s sleep , not very good !!!!
    Capture Init                    ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH}
    Capture Start                   ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH}
    # Start capture BH data on GNB
    common_Dss_Keywords.Start capture Backhaul XP for DSS New               capture=${capture_BH_GNB}

Stop capture Bip and Xp for 7738
    [Arguments]
    ${alias}                        SSH Connect                             host=${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.target.host}
    Capture Stop                   ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH}
    common_Dss_Keywords.Stop capture for Backhaul XP DSS New     capture=${capture_BH_GNB}    w_pdml=False    w_traces_archived=False
    Run               cp ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.path} ${PCAP_PATH_TMP_VM}
    @{pcap_files_list}     set variable   ${PCAP_PATH_TMP_VM}    ${capture_BH_GNB.path}
    Merge pcap files    ${pcap_files_list}    ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.path}

    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.path}
    Run Keyword And Ignore Error    OperatingSystem.Move File    ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.path}    ${testCaseDir}
    Dated Log     dss pcap file ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.path} copied into ${testCaseDir}

Start Capture CPRT
    ${CaptureCPRT}                  Capture CPRT Set Upon Config            airscale=${GNB_DU}
	${CaptureCPRT.filter}           Get Filter For SCTP
#   Keep code for future use regarding  Syscom over TCP
#    ${CaptureCPRT.filter}           Run Keyword If    'SBTS22R3' in '${TLConfig.topo.gnbVersion}'
#    ...                                   capture=${CaptureCPRT}
#	...         ELSE
#	...                             Get Filter For TCP
    Capture Init                    ${CaptureCPRT}
    Capture Start                   ${CaptureCPRT}
    Set Suite Variable              ${CaptureCPRT}


Stop Capture CPRT
    Capture Stop                    ${CaptureCPRT}



# Msg Checking

Check actLteNrDssFastAlloc in cellSetupreq Pcap
    [Arguments]                     ${capture}
    [Documentation]                 Check actLteNrDssFastAlloc from CPRT -> L2PS in GNB_CPRT_NODE Pcap
    Dated log             Point AF_PATH and ENB_BUILD to luashark sw package
    Point ENB_BUILD to luashark sw package
    Point AF_PATH to current sw package
    ${pdmlFile}                     analyzer.pcap_to_pdml                  ${capture.path}
    # filtering dont work here !!!
    # ${filterPcap1}                   analyzer.filter_pcap            ${capture.path}
    # ...                             filterName=filteredBymsg_itf_l2_ps_cell_cellsetupreq        filterExp=itf_l2_ps_cell_cellsetupreq
    # ${pdmlFile}                     analyzer.pcap_to_pdml                  ${filterPcap1}
    Dated log                   Checking actLteNrDssFastAlloc inside PDML file    ${pdmlFile}
    Dated log                   ---Checking actLteNrDssFastAlloc in itf_l2_ps_cell_cellsetupreq
    ${DssFastAllocValueWaiting}=    set variable if   '${mcshark_present}'=='${True}'     1
    ...                                                                                   ${param.seq.DssFastAllocValue}
    analyzer.check_exists_once             pdmlFile=${pdmlFile}
    ...                             packetName=itf_l2_ps_cell_cellsetupreq
    ...                             path=.*actLteNrDssFastAlloc$
    ...                             value=${DssFastAllocValueWaiting}
    # ${filterPcap2}                   analyzer.filter_pcap            ${capture.path}
    # ...                           filterName=filteredBymsg_itf_l2_ps_cell_dsscellcrmclientcfgreq   filterExp=itf_l2_ps_cell_dsscellcrmclientcfgreq
    # ${pdmlFile}                     analyzer.pcap_to_pdml                  ${filterPcap2}
    Dated log                   ---Checking dlResourceSharingAlgo in itf_l2_ps_cell_dsscellcrmclientcfgreq
    analyzer.check_exists_once             pdmlFile=${pdmlFile}
    ...                             packetName=itf_l2_ps_cell_dsscellcrmclientcfgreq
    ...                             path=.*dlResourceSharingAlgo$
    ...                             kind="value"
    ...                             value=${param.seq.SharingAlgoValue}
    ...                             startPacket=${1}
    ...                             endPacket=${-1}
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${capture.path}
    Run Keyword And Ignore Error    OperatingSystem.Move File    ${capture.path}    ${testCaseDir}
    # Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${filterPcap1}
    # Run Keyword And Ignore Error    OperatingSystem.Move File    ${filterPcap1}    ${testCaseDir}
    # Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${filterPcap2}
    # Run Keyword And Ignore Error    OperatingSystem.Move File    ${filterPcap2}    ${testCaseDir}
    Dated log             Point AF_PATH and ENB_BUILD to local luashark XP package
    pcap.Point AF_PATH to local luashark XP package
    pcap.Point ENB_BUILD to local luashark XP package

Check actLteNrDssFastAlloc in cellSetupreq Pcap old version
    [Arguments]                     ${capture}
    [Documentation]                 Check actLteNrDssFastAlloc from CPRT -> L2PS in GNB_CPRT_NODE Pcap
    Dated log             Point AF_PATH and ENB_BUILD to luashark sw package
    Point ENB_BUILD to luashark sw package
    Point AF_PATH to current sw package
    ${pdmlFile}                     analyzer.pcap_to_pdml                  ${capture.path}
    Dated log                   Checking actLteNrDssFastAlloc inside PDML file    ${pdmlFile}
    Dated log                   ---Checking actLteNrDssFastAlloc in itf_l2_ps_cell_cellsetupreq
    analyzer.check_exists_once             pdmlFile=${pdmlFile}
    ...                             packetName=itf_l2_ps_cell_cellsetupreq
    ...                             path=.*actLteNrDssFastAlloc$
    ...                             value=${param.seq.DssFastAllocValue}
    Dated log                   ---Checking dlResourceSharingAlgo in itf_l2_ps_cell_dsscellcrmclientcfgreq
    analyzer.check_exists_once             pdmlFile=${pdmlFile}
    ...                             packetName=itf_l2_ps_cell_dsscellcrmclientcfgreq
    ...                             path=.*dlResourceSharingAlgo$
    ...                             value=${param.seq.SharingAlgoValue}

    Dated log             Point AF_PATH and ENB_BUILD to local luashark XP package
    pcap.Point AF_PATH to local luashark XP package
    pcap.Point ENB_BUILD to local luashark XP package


Check dlSharingAlgo in Coordination Msgs
    [Documentation]      KW used to check DSS dlResourceSharingAlgo values in
    ...                  enDssDlCellResourceAreaCoordinationReq
    ...                  enDssDlCellResourceAreaCoordinationUpdateInd
    [Arguments]                     ${pdmlFile}

    Dated log                   Checking dlResourceSharingAlgo enDssDlCellResourceAreaCoordinationReq inside PDML

    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_XpDssMessage
    ...                             path=.dlResourceSharingAlgo.dlResourceSharingAlgo_item_0$
    ...                             kind="value"
    ...                             value=${param.seq.xpSharingAlgoValue}
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

    Dated log                   Checking dlResourceSharingAlgo enDssDlCellResourceAreaCoordinationUpdateInd

Check dlSharingAlgo in Coordination Msgs Using MCShark
    [Documentation]      KW used to check DSS dlResourceSharingAlgo values in
    ...                  enDssDlCellResourceAreaCoordinationReq
    ...                  enDssDlCellResourceAreaCoordinationUpdateInd
    [Arguments]                     ${pdmlFile}

    Dated log                   Checking dlResourceSharingAlgo enDssDlCellResourceAreaCoordinationReq inside PDML

    analyzer.check_exists_once      pdmlFile=${pdmlFile}
    ...                             packetName=xp_dss_xpdssmessage
    ...                             path=.xp_dss_EnDssDlCrmSfInfoExtension1.dlResourceSharingAlgo_item$
    ...                             kind="value"
    ...                             value=01000000
    ...                             startPacket=${1}
    ...                             endPacket=${-1}

    Dated log                   Checking dlResourceSharingAlgo enDssDlCellResourceAreaCoordinationUpdateInd

Check nGBR in Load Indication Msgs
    [Documentation]      KW used to check DSS Measured nGBR nNBR load values in
    ...                  EN DSS UL QoS LOAD INDICATION
    [Arguments]                     ${pdmlFile}

    Dated log                   Checking dlResourceSharingAlgo UL Qos Load Indication MeasuredNgbrNnbrLoad inside PDML

    ${status}   ${avg_ul_MeasuredNgbrNnbrLoad}=  Run Keyword and Ignore Error  common_Dss_Keywords.Check UL Qos Load Indication MeasuredNgbrNnbrLoad
    ...                                                                                              ${pdmlFile}
    ...                                                                                              value=64
    ...                                                                                              with_verdict=False

    #${expect_UL_Qos_load_Ind_value}    set variable    70
    #${expect_UL_Qos_load_Ind}=    Evaluate    float(${expect_UL_Qos_load_Ind_value})
    #${avg_ul_MeasuredNgbrNnbrLoad_Ind}=    Evaluate    float(${avg_ul_MeasuredNgbrNnbrLoad})
    #7738 Verify UL Qos Load Ind as expected         ${avg_ul_MeasuredNgbrNnbrLoad}      ${expect_UL_Qos_load_Ind_value}       0.1


7738 Verify UL Qos Load Ind as expected
    [Documentation]                     =${ul_Qos_Load_deviation}=0.1
    [Arguments]    ${ul_qos_load_value}    ${expect_ul_qos_load_value}    ${deviation}
    run keyword if    ${expect_ul_qos_load_value}==${0}    run keywords
    ...    should be true    ${ul_qos_load_value}>=0    AND   return from keyword

    ${min}    evaluate    ${expect_ul_qos_load_value}*(1-${deviation})
    ${max}    evaluate    ${expect_ul_qos_load_value}*(1+${deviation})
    ${is_ul_qos_load_as_expected}    evaluate    ${min} <= ${ul_qos_load_value} <= ${max}
    Run Keyword If                  '${is_ul_qos_load_as_expected}'=='True'
    ...    Log to Console            \t${green} Average UL DSS Ratio REACHED: expected = 70 % , current = ${ul_qos_load_value} % ${normal}
    ...    ELSE
    ...    Log to Console            \t${red} Average UL DSS RATIO NOT REACHED: expected = 70 %, current = ${ul_qos_load_value} % ${normal}
    should be true    '${is_ul_qos_load_as_expected}'=='True'    UL Qos load Indication is not as expected!

Collect PM Counters File
    [Documentation]                 KW to get counters and store in specific directory with day date

    ${date}                          Get Current Date
    ${date_in_dir_name}              Convert Date         ${date}     result_format=%d%m%Y_%H%M
    ${log_path_pm}                   Set Variable         ${LOG_PATH}/PM_${date_in_dir_name}
    BuiltIn.Log              The PM counters file collected from gnb will be stored under : ${log_path_pm}
    ${pm_latest}                    Counters.Collect PM files from BTS    ${log_path_pm}
    set Suite Variable              ${LATEST_FILE}       ${pm_latest}
    set Suite Variable              ${log_path_pm}
    BuiltIn.Log     Latest pm counters file : ${LATEST_FILE}

Check DSSCounterState
    [Documentation]                 M55332C03002  EN_DSS_MAX_RTT_TO_CRM
    ...                             and M55332C03004
    [Arguments]         ${expValueM55332C03002}    ${expValueM55332C03004}

    Dated Log New Line          ====================================================
    Dated Log           PM Counter M55332C03002 and M55332C03004 analysis
    Dated Log          ====================================================

    ${val1}        Counters.Retrieve Latest Single Counter Value From Pm File with CellID
    ...                             ${LATEST_FILE}        M55332C03002      1
    Dated Log           Value of M55332C03002 : ${val1}

    ${val3}        Counters.Retrieve Latest Single Counter Value From Pm File with CellID
    ...                             ${LATEST_FILE}        M55332C03004      1
    Dated Log           Value of M55332C03004 : ${val3}


    should be true      ${val1} <= ${expValueM55332C03002}
    should be true      ${val3} <= ${expValueM55332C03004}

Verify xL tput
    [Documentation]  deviation in percent
    ...              retun True or False
    [Arguments]    ${dir}=UL    ${tput_value}=1    ${expect_tput_value}=1    ${tput_deviation}=5

    run keyword if    ${expect_tput_value}==${0}    run keywords
    ...    should be true    ${tput_value}>=0    AND   return from keyword

    Log to Console   \tdebug: direction ${dir} current tput value ${tput_value} expect_tput_value ${expect_tput_value} deviation ${tput_deviation} %
    ${is_tput_as_expected}  Set Variable    False
    # ${min}    evaluate    ${expect_tput_value}*(1-${deviation})
    # ${max}    evaluate    ${expect_tput_value}*(1+${deviation})
    ${min}    evaluate    ${expect_tput_value}-(${expect_tput_value}*${deviation}/100)
    ${max}    evaluate    ${expect_tput_value}+(${expect_tput_value}*${deviation}/100)
    ${is_tput_as_expected}    evaluate    ${min} <= ${tput_value} <= ${max}
    ${msg}=     Run Keyword If     '${is_tput_as_expected}'=='True'
    ...    Catenate     \t${green} ${dir} Tput for all Ues REACHED: expected = ${expect_tput_value} Mbps,
    ...                            current = ${tput_value} Mbps ${normal}
    ...    ELSE
    ...    Catenate     \t${red} ${dir} Tput for all Ues NOT REACHED: expected = ${expect_tput_value} Mbps,
    ...                          current = ${tput_value} Mbps ${normal}
    Log to Console         ${msg}
    [Return]      ${is_tput_as_expected}

DSS_5g_SA_UL_DL_Traffic
    [Arguments]         ${param}      ${ul_rate}=15      ${dl_rate}=80    ${alias}=default
    [Documentation]
    ...   Start generating Traffic for one UE. It is required to have attached UE and setup choosen bearer before.
    ...
    ...    :param dl_rate:  the volume of downlink traffic in megabits per second. Default value is 1mbit/s.
    ...    :param ul_rate:  the volume of uplink traffic in megabits per second. Default value is 1mbit/s.
    ...    :param ue: UE id

    ${pattern}    Set Variable    UDP DL TRF
    ${cmd}=     Catenate         trf_data_start ue=${Param.Context.UeId1} pdu=1 qfi=1 trf_id=1 mbps=${dl_rate} dir=dl
    ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}    timeout=30    alias=${alias}
    ${pattern}    Set Variable    UDP UL TRF:
    ${cmd}=     Catenate         trf_data_start ue=${Param.Context.UeId1} pdu=1 qfi=1 trf_id=1 mbps=${ul_rate} dir=ul
    ${output}      wts.execute egate command        cmd=${cmd}    pass_regexp=${pattern}     timeout=30    alias=${alias}
    Log to Console     Started DL + UL Traffic for UE=${Param.Context.UeId1}


Stop Generating Traffic
    [Arguments]    ${ue}=1    ${bearer}=2
    [Documentation]    Stop generating traffic for one UE
    ...    :param ue: UE id
    ...    :param bearer: configured bearer
    ...
    Log to Console    Stopping DL + UL Traffic...
    ${output}      wts.execute egate command        cmd=trf_data_stop ue=${ue} id=${bearer}
    # ${output}   wts.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    # ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}

CheckInEgateConsoleLog_DldatacsisendReq_sent_in_MSG2_Slot
    [Documentation]    This keyword is used for DSS to check in BackHaul log parameter result after ue_register:
    ...                - in measConfig :  csi-IM-ResourceToAddModList + csi-IM-ResourceElementPattern pattern0
    ...                - in pdschConfig : zp-CSI-RS-ResourceToAddModList
    sleep   5
    ${csi-IM-ResourceToAddModList}                 Set Variable        "csi-IM-ResourceToAddModList"
    ${pattern_zp-CSI-RS-ResourceToAddModList}      Set Variable        "zp-CSI-RS-ResourceToAddModList"
    ${pattern0}                                    Set Variable        "csi-IM-ResourceElementPattern pattern0"


    ${msg}    Catenate    Check in DldatacsisendReq MSG2 in egate_console.log:  ${csi-IM-ResourceToAddModList}
    ...                   ${pattern_zp-CSI-RS-ResourceToAddModList}  and  ${pattern0}
    Dated Log New Line      ${msg}

    ${alias}       SSH Connect          ${HOST_EPCSIM}

    ${cmd}=        Catenate    grep ${csi-IM-ResourceToAddModList} ${tl.core.dir_path}/egate_console.log
    ${output}=     SSH Exec
    ...            command=${cmd}
    ...            alias=${alias}
    ...            debug=${True}
    Dated Log  ${output}
    Should Not Be Empty     ${output}  msg=no ${csi-IM-ResourceToAddModList} found in ${tl.core.dir_path}/egate_console.log



    ${cmd}=    Catenate    grep ${pattern_zp-CSI-RS-ResourceToAddModList} ${tl.core.dir_path}/egate_console.log | grep -v nzp
    ${output}=     SSH Exec
    ...            command=${cmd}
    ...            alias=${alias}
    ...            debug=${True}
    Dated Log  ${output}
    Should Not Be Empty     ${output}  msg=no ${pattern_zp-CSI-RS-ResourceToAddModList} found in ${tl.core.dir_path}/egate_console.log

    ${cmd}=    Catenate    grep -e ${pattern0} ${tl.core.dir_path}/egate_console.log
    ${output}=     SSH Exec
    ...            command=${cmd}
    ...            alias=${alias}
    ...            debug=${True}
    Dated Log  ${output}
    Should Not Be Empty     ${output}  msg=no ${pattern0} found in ${tl.core.dir_path}/egate_console.log
