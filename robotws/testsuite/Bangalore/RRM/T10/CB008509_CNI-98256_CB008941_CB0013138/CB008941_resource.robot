*** Settings ***
Documentation       this robot file contains keywords for execution 8941 feature and validation
...                 of executed test steps
Variables    ta5g_global_var


Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Library        ../resources/NPS/SWENG/python_libs/luashark_tools.py
Resource       ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../resources/robot/Setup_Env.robot
Resource       ../resources/robot/common_log_collection.robot
Resource        ../resources/ECEcommon/common_file_operation.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library        luashark_tools.analyzer       WITH NAME       analyzer
Library        	taf.sbts.oam.coam.admin                   WITH NAME   ute_adm
#Library        taf.collectors.core   WITH NAME   CORE
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAME    csn
Library        ./python/verify_rnti_bwpid.py
Library           XML    use_lxml=True    WITH NAME    Myxml

Library         ./python/CB008941_utility.py
Library         ./python/tti_utility.py
Library         ./python/increase_buffer_size.py
*** Variables ***

${RD_PARAM}          0x5901C9=1;0x600012=1;0x5901CA=0;0x190297=1;
${RD_PARAM_DIS}      0x5901C9=0;0x600012=0;0x5901CA=0;0x190297=0;
${RD_PARAM_8124}     0x420068=6;0x420062=1;0x5901C9=1;0x600012=1;0x5901CA=0;0x190297=1;0x580587=16;0x580588=16;
${delta_set_collecting_counters_to_five_minutes}=
    ...    /home/ute/Auto5G/testsuite/RRM/5G_SW_WRO/resources/config/5G21B/delta_set_collecting_counters_to_five_minutes.json
@{FIELDS_CellSetupReq}     cellBwpList_item_0     cellBwpList_item_1
${BIP_SCRIPT_PATH}      ${CURDIR}/../resources/NPS/SWENG/config/script
${WEBEM_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${port}                    22
*** Keywords ***
Modify IPHY File And Send to Airphone Custom
    [Arguments]    ${iphy_path}
    ${RRU_type_list}    Get RRU Type From Local IPHY XML Custom   ${iphy_path}
    FOR    ${RRU_type}    IN    @{RRU_type_list}
    ${RRU_Version}    Get RRU Version From TargetBD File Custom    ${RRU_type}    ${OUTPUT_DIR}
    Modify RRU Version Of IPHY XML Custom    ${iphy_path}    ${RRU_type[0]}    ${RRU_Version}
    Send IPHY XML To Airphone custom    ${iphy_path}
    END

Get RRU Type From Local IPHY XML Custom
    [Arguments]    ${iphy_path}
    ${content}=    OperatingSystem.Get File    path=${iphy_path}
    ${x}  Set Variable  <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>\\n\\s+(?=<fragmentationCapabilities>)
    @{RRU_type_for_version}    String.Get Regexp Matches    ${content}    ${x}    RRU_type    Ecpri_tag
    @{RRU_type_list}    String.Get Regexp Matches    ${content}    ${x}    RRU_type
    Set Suite Variable    ${RRU_TYPE_LIST}    ${RRU_type_list}
    Set Suite Variable    ${RRU_TYPE}    ${RRU_type_list[0]}
    Log To Console   RRU Type List from local iphy.xml: ${RRU_type_list}
     Log To Console    RRU Type from local iphy.xml: ${RRU_TYPE}
    [Return]    @{RRU_type_for_version}

Get RRU Version From TargetBD File Custom
    [Arguments]    ${RRU_type}    ${save_dir}
    ${RRU_type}=    Set Variable If    "${RRU_type[0]}"=="AAHF"    AAHF_C1
    ...    "${RRU_type[0]}"=="AEUB"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEHC"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEUD"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AWEUA"    ${RRU_type[0]}
    ...    "${RRU_type[1]}"=="ecpri"    ${RRU_type[0]}_E1
    ...    ${RRU_type[0]}
    OperatingSystem.Run
    ...    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/TargetBD*.xml ${save_dir}/TargetBD.xml
    OperatingSystem.Should Exist    ${save_dir}/TargetBD.xml
    ${content}=    OperatingSystem.Get File    path=${save_dir}/TargetBD.xml
    ${check_point_regexp}    Set Variable    resourceBuildKey="LTX_${RRU_type}".*resourceSWVersion="(?P<RRU_Version>.*)"
    @{RRU_Version}    String.Get Regexp Matches    ${content}    ${check_point_regexp}    RRU_Version
#    [Return]    @{RRU_Version}[0]
    [Return]    ${RRU_Version}[0]

Modify RRU Version Of IPHY XML Custom
    [Arguments]    ${iphy_path}    ${RRU_type}    ${RRU_Version}
    ${content}    OperatingSystem.Get File    path=${iphy_path}
    ${bldVersion}=    String.Get Regexp Matches    ${content}
    ...    <cardName>${RRU_type}<\/cardName>[\\s\\S]*?<bldVersion>(?P<bldVersion>.*)<\/bldVersion>
    ...    bldVersion
    Log Many    ${bldVersion[0]}    ${RRU_Version}
    ${new_content}    String.Replace String    ${content}    ${bldVersion[0]}    ${RRU_Version}
    Log To Console    ${new_content}
    OperatingSystem.Create File    path=${iphy_path}    content=${new_content}


Send IPHY XML To Airphone custom
    [Arguments]    ${iphy_path}
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} rm -f /ffs/run/simmode/*.xml
    Should Be Equal As Integers    ${rc}    0
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy_modify.xml
    Should Be Equal As Integers    ${rc}    0
    ${soft_link}=    Set Variable    ln -fs /ffs/run/simmode/iphy_modify.xml /ffs/run/simmode/iphy.xml
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} ${soft_link}
    Should Be Equal As Integers    ${rc}    0



Create Rntibwp Dictionary
    [Arguments]   ${rnti}   ${bwpid}
    ${Dict1}   Create Dictionary
    ${len}   Get Length    ${rnti}
    FOR    ${i}    IN RANGE   ${len}
         Set To Dictionary   ${Dict1}    ${rnti}[${i}]   ${bwpid}[${i}]
    END
    Run Keyword if   ${len}==0    Set To Dictionary   ${Dict1}    ${EMPTY}   ${bwpid}[0]
    [Return]   &{Dict1}

Verify Rnti ueBWPid
    [Arguments]   ${csv_file_path}   ${rnti}   ${bwp}   ${flag}
    ${rntibwp}   Create Rntibwp Dictionary   ${rnti}   ${bwp}
    ${Result}  verify_rnti_bwpid.check_rnti_bwpid    ${csv_file_path}   ${rntibwp}   ${flag}
    [Return]   ${Result}

Validate UE bwpid from TTI traces
    [Arguments]   ${csv_file_path}   ${rnti}   ${bwp}   ${flag}
    ${Check}  Verify Rnti ueBWPid    ${csv_file_path}/output_dl_formated.csv      ${rnti}   ${bwp}   ${flag}
    run keyword and continue on failure   Run Keyword if   ${Check}!=${True}   Fail   Bwpid is not matching
    ${Check1}  Verify Rnti ueBWPid    ${csv_file_path}/output_ul_formated.csv     ${rnti}   ${bwp}   ${flag}
    run keyword and continue on failure   Run Keyword if   ${Check1}!=${True}   Fail   Bwpid is not matching

Capture TTI Traces and Validate UE bwpid
     [Arguments]   ${LOG_PATH}   ${filename}    ${rnti}   ${bwp}   ${flag}
     builtin.Log      ${LOG_PATH}
     Start Log   ttitrace
     sleep   2s
     ${tti}  Stop Log   ttitrace    test_scenario=${filename}
     Decode TTI Trace  ${filename}

     Validate UE bwpid from TTI traces    ${tti}[ttitrace]     ${rnti}   ${bwp}   ${flag}

Get MCShark Version_8941
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${sw_version}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    ${list_version}    Split String    ${sw_version}    _
    ${first}    ${rest}    Split String    ${sw_version}    _    1
    ${new_version}    Set Variable If    "${list_version}[2]"=="9999"
    ...    SBTS00_${rest}      ${sw_version}
    ${list_version}    Split String    ${new_version}    _
    ${rest}    ${last}    Split String From Right    ${new_version}    _    1
    ${latest_version}    Set Variable If    "${list_version}[0]"!="SBTS00" and "${list_version}[-1]"!="000000"
    ...    ${rest}_000000      ${new_version}
    [Return]    ${latest_version}

Download MCShark To UTE_8941
    ${wireshark_version}    Run    ls /usr/lib/x86_64-linux-gnu/wireshark/plugins
    set suite variable     ${wireshark_version}
    ${sw_version}    Get MCShark Version_8941
    ${cmd}    Set Variable    wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_version}/
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${MCShark}    Run    find /home/ute/ -name mcshark-3.6*buster.so
    ${is_present}  Run   ls /home/ute/.local/lib/wireshark/plugins/3.6/epan/mcshark-${wireshark_version}*buster.so
    set suite variable     ${MCShark}
    ${is_MCShark_exist}    Run keyword and return status    Should contain    ${is_present}    No such file or directory
    Run keyword if   ${is_MCShark_exist}==${True}   Download MCShark If Have
    ...  ELSE         log to console    version allready present

Download MCShark If Have
    Run    sudo rm /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/mcshark-*buster.so
    Run    sudo cp ${MCShark} /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/
    log to console    download mcshark successfully to UTE

Check gNB Bulid
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${GNB_SW_VERSION}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    Set Suite Variable    ${GNB_SW_VERSION}
    ${Branch_22R1}    Run Keyword and Return Status   Should Contain    ${GNB_SW_VERSION}     22R1
    Set Suite variable   ${Branch_22R1}

Send Swconfig File To GNB_8941
    [Arguments]    ${path}
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p oZPS0POrRieRtu scp ${path} toor4nsn@192.168.255.1:/ffs/run/swconfig.txt
    Should Be Equal As Integers    ${rc}    0
Add RD Parameters To GNB Swconfig File_8941
    [Arguments]    ${rd_parametrs}
    [Documentation]    This keyword is to add new RD parameters to swconfig.txt
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${rd_parametrs} | Yes | str joined by symbol ;, like 0x580019=1;0x580011=0;0x580012=0; |
    ...
    ...    Examples:
    ...    | Add RD Parameters To GNB Swconfig File_8941 | 0x580019=1;0x580011=0;0x580012=0 |
    ...
    ${path}    Get Swconfig File From GNB_8941    ${OUTPUT_DIR}
    Modify Swconfig File Parameters    ${path}    ${rd_parametrs}
    Send Swconfig File To GNB_8941    ${path}

Get Swconfig File From GNB_8941
    [Arguments]    ${save_dir}
    OperatingSystem.Run
    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ffs/run/swconfig.txt ${save_dir}/swconfig_gnb.txt
    OperatingSystem.Should Exist    ${save_dir}/swconfig_gnb.txt
    ${path}    Set Variable    ${save_dir}/swconfig_gnb.txt
    [Return]    ${path}

#Configure UTE ETH3 IPs
#    [Documentation]    This keyword is to configure VM interfaces.
#    Log To Console    configure VM interfaces...
#    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3
Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    #${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    Check gNB Airscale is Ready - ${BBoard_Type}

    Log To console     loading cfg file
    Start Log   btslog    cprt
    Start WTS Using WTS_Runner      ${wts_cfg_file}
    sleep    240s
    ${cprt_log}     Stop Log  cprt  test_scenario=cellsetup
    set suite variable    ${cprt_log}
    ${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup_sys
    set suite variable    ${cell_sys_log}


#Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
#    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

UE Beamforming Profile And Association For 2 Beams SA
    [Arguments]    ${max_ue_num}
    wtsrunner.beam_control_testmode_nr    profile_id=1   ueBeamIndexInitial=0,1   ssbeam_bestbeam=0
    ...   ssbeam_rsrp_best=-44   ssbeam_rsrp_avg=-50
    ${op}=      wtsrunner.read_wtsemu_output
    wtsrunner.beam_control_testmode_nr    profile_id=2 ueBeamIndexInitial=1,0   ssbeam_bestbeam=1   ssbeam_rsrp_best=-45
    ...   ssbeam_rsrp_avg=-120
    ${op}=      wtsrunner.read_wtsemu_output
    ${end_ue}=     evaluate   ${max_ue_num}/${2}
    ${end_ue}    convert to integer  ${end_ue}
    FOR   ${ue_id}    IN RANGE    1    ${end_ue}
    wtsrunner.ue_testmode_set_nr  id=${ue_id}  testmode=beam_control  action=activate  profile_id=1  beamaction=attach
    END

    FOR    ${ue_id}    IN RANGE    ${end_ue}    ${max_ue_num} + 1
        wtsrunner.ue_testmode_set_nr  id=${ue_id}  testmode=beam_control  action=activate  profile_id=2  beamaction=attach
    END


Read Cellsetup msg_8941
    [Arguments]    ${file}      ${CB008678_enable}=${-1}
    ${bts_log}      Set Variable  ${cell_sys_log}[btslog]/gnb_syslog.log
    ${cmd}  Set Variable    StartCrbCommonPucchHighPart|awk -F'rrmStartCrbCommonPucchHighPart:' '{print $2}'| awk -F ":" '{print $1}'|cut -d , -f1
    ${CommonPucchHighPartstartprb}    Run  cat ${bts_log}|grep -i -m 1 ${cmd}
    ${cmd}  Set Variable    StartCrbCommonPucchHighPart|awk -F'rrmStartCrbCommonPucchHighPart:' '{print $2}'| awk -F ":" '{print $2}'|cut -d , -f1
    ${CommonPucchLowPartstartprb}     Run  cat ${bts_log}|grep -i -m 1 ${cmd}
    ${cmd}  Set Variable    StartCrbCommonPucchHighPart|awk -F'rrmStartCrbCommonPucchHighPart:' '{print $2}'| awk -F ":" '{print $3}'
    ${NumPrbCommonPucch}      Run  cat ${bts_log}|grep -i -m 1 ${cmd}
    set test variable   ${CommonPucchHighPartstartprb}   ${CommonPucchHighPartstartprb}
    set test variable   ${CommonPucchLowPartstartprb}   ${CommonPucchLowPartstartprb}
    set test variable   ${NumPrbCommonPucch}   ${NumPrbCommonPucch}
    ${pdmlFile}=                    analyzer.pcap_to_pdml        ${file}    pscell


    ${longPucchNumPuschPrb}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=itf_l2_ps_cell_BwpDefinitionUl.longPucchNumPuschPrb_item
    ...                                                endPacket=${1}



    ${longPucchStartPuschPrb_item}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=itf_l2_ps_cell_BwpDefinitionUl.longPucchStartPuschPrb_item
    ...                                                endPacket=${1}


    Run keyword if    ${CB008678_enable}==${1}        Read Dynamic PUSCH    ${pdmlFile}




    ${longPucchStartSr1Prb}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartSr1Prb
    ...                                                endPacket=${1}


    ${longPucchStartSr2Prb}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartSr2Prb
    ...                                                endPacket=${1}


    ${longPucchStartHarq1Prb}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartHarq1Prb
    ...                                                endPacket=${1}


    ${longPucchStartHarq2Prb}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartHarq2Prb
    ...                                                endPacket=${1}


    ${longPucchStartPcsi1Prb}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartPcsi1Prb
    ...                                                endPacket=${1}


    ${longPucchStartPcsi2Prb}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartPcsi2Prb
    ...                                                endPacket=${1}



    ${longPucchNumSrPrb}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchNumSrPrb
    ...                                                endPacket=${1}



    ${longPucchNumHarqPrb}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchNumHarqPrb
    ...                                                endPacket=${1}


    ${longPucchNumPcsiPrb}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchNumPcsiPrb
    ...                                                endPacket=${1}


    ${longPucchNumPuschPrb_init_ded_ps}    Create List
    ${longPucchStartPuschPrb}              Create List

    FOR   ${prb}   IN   @{longPucchNumPuschPrb}
        @{tmp}      Split String   ${prb}    :
        Append To List      ${longPucchNumPuschPrb_init_ded_ps}    ${tmp[1]}
    END
    FOR   ${prb}   IN   @{longPucchStartPuschPrb_item}
        @{tmp}      Split String   ${prb}    :
        Append To List      ${longPucchStartPuschPrb}    ${tmp[1]}
    END

    @{tmp}      Split String   ${longPucchStartSr1Prb[0]}    :
    ${longPucchStartSr1Prb}   Set variable      ${tmp[1]}
    set test variable    ${longPucchStartSr1Prb}   ${longPucchStartSr1Prb}
    @{tmp}      Split String   ${longPucchStartSr2Prb[0]}    :
    ${longPucchStartSr2Prb}   Set variable      ${tmp[1]}
    set test variable    ${longPucchStartSr2Prb}   ${longPucchStartSr2Prb}
    @{tmp}      Split String   ${longPucchStartHarq1Prb[0]}    :
    ${longPucchStartHarq1Prb}   Set variable      ${tmp[1]}
    set test variable    ${longPucchStartHarq1Prb}     ${longPucchStartHarq1Prb}
    @{tmp}      Split String   ${longPucchStartHarq2Prb[0]}    :
    ${longPucchStartHarq2Prb}   Set variable      ${tmp[1]}
    set test variable    ${longPucchStartHarq2Prb}    ${longPucchStartHarq2Prb}
    @{tmp}      Split String   ${longPucchStartPcsi1Prb[0]}    :
    ${longPucchStartPcsi1Prb}   Set variable      ${tmp[1]}
    set test variable    ${longPucchStartPcsi1Prb}    ${longPucchStartPcsi1Prb}
    @{tmp}      Split String   ${longPucchStartPcsi2Prb[0]}    :
    ${longPucchStartPcsi2Prb}   Set variable      ${tmp[1]}
    set test variable    ${longPucchStartPcsi2Prb}    ${longPucchStartPcsi2Prb}
    @{tmp}      Split String   ${longPucchNumSrPrb[0]}    :
    ${longPucchNumSrPrb}   Set variable      ${tmp[1]}
    set test variable    ${longPucchNumSrPrb}      ${longPucchNumSrPrb}
    @{tmp}      Split String   ${longPucchNumHarqPrb[0]}    :
    ${longPucchNumHarqPrb}   Set variable      ${tmp[1]}
    set test variable    ${longPucchNumHarqPrb}    ${longPucchNumHarqPrb}
    @{tmp}      Split String   ${longPucchNumPcsiPrb[0]}    :
    ${longPucchNumPcsiPrb}   Set variable      ${tmp[1]}
    set test variable    ${longPucchNumPcsiPrb}   ${longPucchNumPcsiPrb}

    set test variable    ${longPucchNumPuschPrb_init_ded_ps}   ${longPucchNumPuschPrb_init_ded_ps}
    set test variable    ${longPucchStartPuschPrb}    ${longPucchStartPuschPrb}




Read Dynamic PUSCH
    [Arguments]     ${pdmlFile}
    ${longPucchNumDynPuschPrb}   analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=itf_l2_ps_cell_BwpDefinitionUl.longPucchNumDynPuschPrb_item
    ...                                                endPacket=${1}

    ${longPucchStartDynPuschPrb_item}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
    ...                                                path=itf_l2_ps_cell_BwpDefinitionUl.longPucchStartDynPuschPrb_item
    ...                                                endPacket=${1}

    ${longPucchNumDynPuschPrb_ded_ps}      Create List

    ${longPucchStartDynPuschPrb}           Create List

    FOR   ${prb}   IN   @{longPucchStartDynPuschPrb_item}
        @{tmp}      Split String   ${prb}    :
        Append To List      ${longPucchStartDynPuschPrb}    ${tmp[1]}
    END

    FOR   ${prb}   IN   @{longPucchNumDynPuschPrb}
        @{tmp}      Split String   ${prb}    :
        Append To List      ${longPucchNumDynPuschPrb_ded_ps}    ${tmp[1]}
    END

    set test variable    ${longPucchNumDynPuschPrb_ded_ps}   ${longPucchNumDynPuschPrb_ded_ps}
    set test variable    ${longPucchStartDynPuschPrb}   ${longPucchStartDynPuschPrb}


Read pucch boundary
    [Arguments]    ${file}   ${multided_ps_dyn}=${0}   ${scen}=${0}    ${path_count}=${2000}
    ${pdmlFile}=                    analyzer.pcap_to_pdml        ${file}    uldata_pucchreceivereql1sw
    builtin.Log      ${multided_ps_dyn}
#    ${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
#    ...                                                packetName=uldata_pucchreceivereql1sw
#    ...                                                path=UlData_pucchAreaBoundariesL1sw_t.numPucchBoundaries

    ${numPucchBoundaries}      analyzer.get_shownames              pdmlFile=${pdmlFile}
    ...                                                packetName=uldata_pucchreceivereql1sw
    ...                                                path=UlData_pucchAreaBoundariesL1sw_t.numPucchBoundaries
    ...                                                endPacket=${2000}

    ${startPrb}      analyzer.get_shownames            pdmlFile=${pdmlFile}
    ...                                                packetName=uldata_pucchreceivereql1sw
    ...                                                path=UlData_pucchBoundaryL1sw_t.startPrb
    ...                                                endPacket=${2000}

    ${numOfPrb}      analyzer.get_shownames            pdmlFile=${pdmlFile}
    ...                                                packetName=uldata_pucchreceivereql1sw
    ...                                                path=UlData_pucchBoundaryL1sw_t.numOfPrb
    ...                                                endPacket=${2000}

    ${startSymbol}      analyzer.get_shownames            pdmlFile=${pdmlFile}
    ...                                                packetName=uldata_pucchreceivereql1sw
    ...                                                path=UlData_pucchBoundaryL1sw_t.startSymbol
    ...                                                endPacket=${2000}

    ${numOfSymbol}      analyzer.get_shownames            pdmlFile=${pdmlFile}
    ...                                                packetName=uldata_pucchreceivereql1sw
    ...                                                path=UlData_pucchBoundaryL1sw_t.numOfSymbol
    ...                                                endPacket=${2000}


    ${rc}       CB008941_utility.form_pucch_pkt_struct_verify   ${path_count}     ${numPucchBoundaries}  ${startPrb}
    ...       ${numOfPrb}  ${startSymbol}  ${numOfSymbol}
    ...       ${longPucchStartSr1Prb}     ${longPucchStartSr2Prb}    ${longPucchStartHarq1Prb}
    ...       ${longPucchStartHarq2Prb}   ${longPucchStartPcsi1Prb}     ${longPucchStartPcsi2Prb}     ${longPucchNumSrPrb}
    ...     ${longPucchNumHarqPrb}   ${longPucchNumPcsiPrb}  ${CommonPucchHighPartstartprb}    ${CommonPucchLowPartstartprb}   ${NumPrbCommonPucch}
    ...        multided_ps_dyn=${multided_ps_dyn}  scen=${scen}
    [Return]        ${rc}


Verify PUSCH_PUCCH
    [Arguments]   ${pcapFile}
    [Documentation]
    ...     is usable only when 6878 is enabled
    ${chunk}        Set variable     ${100}
    ${endpkt}    Set variable     ${0}
    ${pdmlFile}=         Get filtered PDML file from pcap        ${pcapFile}         uldata_puschreceivereq
    ${total_pkt}=    analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=uldata_puschreceivereq
    ...                                                path=uldata_puschreceivereq
    ...                                                pkt_count=1
    ${flag}     Create List   0   0
    FOR     ${idx}  IN RANGE    ${1}      ${total_pkt}
#    FOR     ${idx}  IN RANGE    ${1}      ${1210}
        Exit For Loop If    ${endpkt} >= ${total_pkt}
        ${diff}      Evaluate  ${idx}-${1}
        ${startpkt}        Evaluate  ${chunk}*${diff}+${1}
        ${endpkt}       Evaluate    ${idx}*${chunk}
        ${endpkt}       Set Variable if   ${endpkt}>${total_pkt}      ${total_pkt}     ${endpkt}
        ${start_prb}    get prb info     uldata_puschreceivereq    ${pdmlFile}   startPrb       ${startpkt}   ${endpkt}
        ${num_prb}    get prb info     uldata_puschreceivereq    ${pdmlFile}   numOfPrb         ${startpkt}   ${endpkt}
        ${flag}       verify PUSCH occupy pCSI       ${start_prb}     ${num_prb}
        Exit For Loop If  ${flag[0]} == ${1} and ${flag[0]} == ${1}
    END
    [Return]    ${flag}



get prb info
    [Arguments]                     ${message}          ${pdmlFile}     ${FIELDS_name}   ${start}    ${end}
    [Documentation]                 returns a list of packets for matched packet
    @{raw_prbinfo_list}              analyzer.get_shownames
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=${message}
    ...                             path=${FIELDS_name}
    ...                             startPacket=${start}
    ...                             endPacket=${end}
    ${prb_info}     Create List
    FOR   ${prb}   IN    @{raw_prbinfo_list}
    @{tmp}      Split String   ${prb}    :
    Append To List      ${prb_info}    ${tmp[1]}
    END
    [return]          @{prb_info}

verify PUSCH occupy pCSI
    [Arguments]     ${startprb}     ${numprb}
    Log to console    ${longPucchNumPuschPrb_init_ded_ps}
    Log to console    ${longPucchStartPuschPrb}
    Log to console    ${longPucchNumDynPuschPrb_ded_ps}
    Log to console    ${longPucchStartDynPuschPrb}
    ${len_lower_pCSI}       Evaluate    ${longPucchStartPuschPrb[1]} - ${longPucchStartDynPuschPrb[0]}
    ${len_upper_pCSI}       Evaluate    ${longPucchNumDynPuschPrb_ded_ps[0]} - ${longPucchNumPuschPrb_init_ded_ps[1]}

    ${upper_pCSI_start}        Evaluate    ${longPucchStartPuschPrb[1]} + ${longPucchNumPuschPrb_init_ded_ps[1]}
    ${upper_pCSI_end}     Evaluate    ${longPucchStartDynPuschPrb[0]} + ${longPucchNumDynPuschPrb_ded_ps[0]}

    ${lower_pCSI_start}     Set variable   ${longPucchStartDynPuschPrb[0]}
    ${lower_pCSI_end}       Set variable   ${longPucchStartPuschPrb[1]}

    ${lower_pCSI_prb}       Create list
    ${upper_pCSI_prb}       Create list

    FOR   ${idx}  IN RANGE   ${longPucchStartDynPuschPrb[0]}    ${longPucchStartPuschPrb[1]}
        Append To List      ${lower_pCSI_prb}    ${idx}
    END

    FOR   ${idx}  IN RANGE   ${upper_pCSI_start}    ${upper_pCSI_end}
        Append To List      ${upper_pCSI_prb}    ${idx}
    END

    ${len}      Get Length      ${startprb}
    ${flag_upper}     Set variable     ${0}
    ${flag_lower}     Set variable     ${0}
    FOR    ${idx}   IN RANGE    ${0}     ${len}

        ${prb_number}     Evaluate      ${startprb[${idx}]} + ${numprb[${idx}]}
        ${flag_upper}     Set variable if    ${upper_pCSI_start} <= ${prb_number} and ${prb_number} <= ${upper_pCSI_end}   ${1}    ${flag_upper}
        ${flag_lower}     Set variable if    ${lower_pCSI_start} <= ${prb_number} and ${prb_number} <= ${lower_pCSI_end}   ${1}    ${flag_lower}
        Exit For Loop If   ${flag_upper} == ${1} and ${flag_lower} == ${1}
    END
    Set Test Variable    ${lower_pCSI_prb}   ${lower_pCSI_prb}
    Set Test Variable    ${upper_pCSI_prb}   ${upper_pCSI_prb}
    [Return]      ${flag_upper}   ${flag_lower}


Check ACSI per on PUSCH slot
    [Arguments]    ${path}  ${min_acsi_on_pusch}    ${file_name}
    ${result} =    check_num_of_acsi_on_pusch_per_slot    ${min_acsi_on_pusch}    ${path}/${file_name}
    [return]    ${result}


Change CQI For UCIonly SA
    Log To Console    Change CQI ...
    wtsrunner.csi_override_testmode_nr   profile_id=2 cqi=15 cqi_mode=oneway cqi_min=4 cqi_max=15 cqi_step=-1 cqi_period=32
    wtsrunner.ue_testmode_set_nr  id=1-15  testmode=csi_override  profile_id=2  action=activate


Read pucch boundary on short pucch
    [Arguments]    ${file}   ${multided_ps_dyn}=${0}   ${scen}=${0}
    builtin.Log      ${scen}
    builtin.Log      ${multided_ps_dyn}
    ${pdmlFile}=                    analyzer.pcap_to_pdml        ${file}    uldata_pucchreceivereql1sw


    ${path_count}      analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=uldata_pucchreceivereql1sw
    ...                                                path=UlData_pucchAreaBoundariesL1sw_t.numPucchBoundaries

    ${numPucchBoundaries}      analyzer.get_shownames              pdmlFile=${pdmlFile}
    ...                                                packetName=uldata_pucchreceivereql1sw
    ...                                                path=UlData_pucchAreaBoundariesL1sw_t.numPucchBoundaries
#    ...                                                endPacket=${10}

    ${length} =	Get Length	${numPucchBoundaries}
    FOR     ${i}  IN RANGE   ${length}
        ${a}   ${b}   Split String From right   ${numPucchBoundaries[${i}]}   ${SPACE}   1
        Should Be Equal   0    ${b}
    END


#MultiUE Attach for NSA
#    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${chk_fail}=${-1}
#    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
#    LTE Attach should be Successful    ${ue_id}
#    NSA UE Attach    ${UE_ID}    chk_fail=${chk_fail}
#    END
#
#MultiUE DL Traffic Start for NSA
#    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${dl_rate}    ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
#    builtin.Log      ${id}
#    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
#    Trigger DL Traffic for NSA    ${ue_id}    ${Traffic_rate}    ${dl_rate}    id=${Bearer_ID}    trf_id=${TRF_ID}
#    END
#
#MultiUE UL Traffic Start for NSA
#    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${ul_rate}    ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
#    builtin.Log      ${id}
#    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
#    Trigger UL Traffic for NSA    ${ue_id}    ${Traffic_rate}    ${ul_rate}    id=${Bearer_ID}    trf_id=${TRF_ID}
#    END
#
#MultiUE Validate UL Traffic For NSA
#    [Arguments]    ${st_ue_id}    ${en_ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
#    FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
#    Validate UL Traffic For NSA    ${ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
#    END
#
#MultiUE Validate DL Traffic For NSA
#    [Arguments]    ${st_ue_id}    ${en_ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
#    FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
#    Validate DL Traffic For NSA    ${ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
#    END
#
#MultiUE DL Traffic Stop for NSA
#    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Bearer_ID}    ${trf_id}
#    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
#    TRF Data Stop for NSA    ${ue_id}    ${Bearer_ID}    dl    ${trf_id}
#    END
#
#MultiUE UL Traffic Stop for NSA
#    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Bearer_ID}    ${trf_id}
#    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
#    TRF Data Stop for NSA    ${ue_id}    ${Bearer_ID}    ul    ${trf_id}
#    END
#
#MultiUE Detach for NSA
#    [Arguments]    ${start_ue_id}    ${stop_ue_id}
#    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
#    UE Detach should be Successful    ${ue_id}
#    END

NSA UE Attach  #NSA
    [Arguments]    ${UE_ID}    ${chk_fail}=${-1}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Target_Cells}    ue=${UE_ID}
    ...                         bearer=${Bearer_ID}    type=split_scg
#    ${fail_pt}    Set Variable    UE${UE_ID}: No band combinations in MR-DC capabilities*
    ${fail_pt}    Set Variable    value Cause : radioNetwork : tDCprep-expiry
    ${pattern}    Set Variable If    ${chk_fail}!=${-1}    ${fail_pt}    ${UE_attach_pattern}
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${pattern}    ${Timeout_NSA}
    [Return]      ${output}

Selective UE Deregister should be Successful
    [Arguments]    ${UE_LIST}
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    FOR	    ${ue_idx}   IN  @{UE_LIST}
    wtsrunner.ue_deregister    id=${ue_idx}    ue_deregister_type=switch_off
    Read WTS Output For Pattern And Print matching Lines    ${UE_deregister_pattern}    ${Timeout_SA}
    END
    BuiltIn.Log                multi_ue_deregister_is_ok

#Increase Buffer Size for VM and IPHY
#    increase_buffer_size.increase_buffer_size     ${AP_ASIK.ip}      ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}







