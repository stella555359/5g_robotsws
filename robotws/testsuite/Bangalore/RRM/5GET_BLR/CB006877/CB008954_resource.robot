*** Settings ***
Documentation       copyright nokia
Variables    ta5g_global_var
Resource          ./../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser

Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Library        ../resources/NPS/SWENG/python_libs/luashark_tools.py
#Resource       ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../resources/robot/Setup_Env.robot
Resource       ../resources/robot/common_log_collection.robot
Resource        ../resources/ECEcommon/common_file_operation.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library        luashark_tools.analyzer       WITH NAME       analyzer
Library        ute_admin                         WITH NAME   ute_adm
#Library        taf.collectors.core   WITH NAME   CORE
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning

Library        taf.transport.ssh                 WITH NAME    csn
Library           XML    use_lxml=True    WITH NAME    Myxml
Library         ./python/increase_buffer_size.py
Library         ./python/CB008954_validation.py
Library         ../resources/python/avg_dl_data.py

*** Variables ***

${RD_PARAM}          0x5901C9=1;0x600012=1;0x5901CA=0;0x190297=1;
${RD_PARAM_DIS}      0x5901C9=0;0x600012=0;0x5901CA=0;0x190297=0;
${RD_PARAM_8124}     0x420068=6;0x420062=1;0x5901C9=1;0x600012=1;0x5901CA=0;0x190297=1;0x580587=16;0x580588=16;
${delta_set_collecting_counters_to_flive_minutes}=
...   /home/ute/Auto5G/testsuite/RRM/5G_SW_WRO/resources/config/5G21B/delta_set_collecting_counters_to_five_minutes.json
@{FIELDS_CellSetupReq}     cellBwpList_item_0     cellBwpList_item_1
${BIP_SCRIPT_PATH}      ${CURDIR}/../resources/NPS/SWENG/config/script
${WEBEM_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${port}                    22
${failed_pattern}      cause 22
${pdu_session_unsuccess}    PDU Session Resource Modify Unsuccessful Transfer
${ACC_UE_DL_SCH_SLOT_BWP1}    M55308C28001
${ACC_UE_UL_SCH_SLOT_BWP1}    M55308C28003
${PM_SCELL_COUNTER1}    M55139C04511
${PM_SCELL_COUNTER2}    M55139C04512
${PM_SCELL_COUNTER3}    M55139C04513
${PM_SCELL_COUNTER4}    M55115C03001
${PM_SCELL_COUNTER5}    M55115C03002
${PM_SCELL_COUNTER6}    M55167C00002
${PM_SCELL_COUNTER7}    M55167C00003
${PM_SCELL_COUNTER8}    M55167C00001
${GNB_SA_DU_ADM_SUCC_BWP1}      M55139C02501
${MAX_UE_DL_SCH_SLOT_BWP1}      M55308C28002
${MAX_UE_UL_SCH_SLOT_BWP1}      M55308C28004
${NRRC_RCFG_CMP_BWP1_RCVD}      M55166C00003
${NRRC_RRC_RECONF_BWP1_SENT}    M55166C00001
${PRB_USED_PDSCH_BWP1}          M55308C29001
${PRB_USED_PUSCH_BWP1}          M55308C29002
${ACC_UE_DL_SCH_SLOT_BWP2}      M55308C28005
${ACC_UE_UL_SCH_SLOT_BWP2}      M55308C28007
${GNB_SA_DU_ADM_SUCC_BWP2}      M55139C02502
${MAX_UE_DL_SCH_SLOT_BWP2}      M55308C28006
${MAX_UE_UL_SCH_SLOT_BWP2}      M55308C28008
${NRRC_RCFG_CMP_BWP2_RCVD}      M55166C00004
${NRRC_RRC_RECONF_BWP2_SENT}    M55166C00002
${PRB_USED_PDSCH_BWP2}          M55308C29003
${PRB_USED_PUSCH_BWP2}          M55308C29004
${ACC_UE_DL_SCH_SLOT_BWP3}      M55308C00081
${ACC_UE_UL_SCH_SLOT_BWP3}      M55308C00083
${GNB_SA_DU_ADM_SUCC_BWP3}      M55139C02504
${MAX_UE_DL_SCH_SLOT_BWP3}      M55308C00082
${MAX_UE_UL_SCH_SLOT_BWP3}      M55308C00084
${NRRC_RCFG_CMP_BWP3_RCVD}      M55166C00512
${NRRC_RRC_RECONF_BWP3_SENT}    M55166C00511
${PRB_USED_PDSCH_BWP3}          M55308C00085
${PRB_USED_PUSCH_BWP3}          M55308C00086
${GNB_DU_SCELL_ADM_BWP1_SUCC}   M55139C04511
${GNB_DU_SCELL_ADM_BWP2_SUCC}   M55139C04512
${GNB_DU_SCELL_ADM_BWP3_SUCC}   M55139C04513
${GNB_DU_SCELL_ADM_S_BWP_SUCC}  M55139C04001
${GNB_DU_SCELL_ADM_L_BWP_SUCC}  M55139C04002
${SUM_UE_SCELL_CONF_S_BWP}      M55167C00002
${SUM_UE_SCELL_CONF_L_BWP}      M55167C00003
${SGNB_DU_SCELL_ADM_BWP1_SUCC}  M55115C00024
${SGNB_DU_SCELL_ADM_BWP2_SUCC}  M55115C00025
${SGNB_DU_SCELL_ADM_BWP3_SUCC}  M55115C00026
${SGNB_DU_SCELL_ADM_S_BWP_SUCC}     M55115C03001
${SGNB_DU_SCELL_ADM_L_BWP_SUCC}     M55115C03002
${SGNB_NSA_DU_ADM_SUCC_BWP1}    M55115C02001
${SGNB_NSA_DU_ADM_SUCC_BWP2}    M55115C02002
${SGNB_NSA_DU_ADM_SUCC_BWP3}    M55115C02004

${PDCCH_SYMB_DIF_BWP1_BWP3}      M55335C02014
${PDCCH_SYMB_DIF_BWP2_BWP3}      M55335C02015
${PDCCH_SYMB_DIF_BWP1_BWP2}      M55335C02013
${PDCCH_SYMB_DIF_BWP1_PWS_BWP}    M55335C02016
${PDCCH_SYMB_DIF_BWP2_PWS_BWP}    M55335C02017
${PDCCH_SYMB_DIF_BWP3_PWS_BWP}    M55335C02018

#*** Keywords ***
#Modify NIDD parameters
#    [Documentation]     This Keyword modify NIDD parameter as per the requirement of the feature CB008246
#    [Arguments]        ${paramDst}='None'                  ${operation}=update
#     ...                ${paramName}='None'                 ${paramValue}='None'
#    Log to Console      Modifying NIDD parameters
#    admin.Setup admin
#    Online NIDD parameter change    paramDst=${paramDst}        operation=${operation}
#    ...          paramName=${paramName}         paramValue=${paramValue}
#    sleep               60s
#    [Teardown]          admin.Teardown admin


#Online NIDD parameter change
#     [Documentation]    This Keyword used to update NIDD parameter(one at a time)
#     ...                and returns the result
#     ...        [Arguments]    parameter        :  Parameter names to parsed
#     ...                       paramDst         :  Dist name should be parsed
#     ...                       paramValue       :  Value for the parameter to be assigned should be parsed
#     ...                       operation        :  Deffault Value given as update, and can be parsed other operation if required
#     ...                       should_activate  :  Deffault Value is True if you want to set this False then parse the parameter as False
#     ...                       skip_parameter_relation_errors : Default Value is True if you want to set  False then parse the parameter as False
#     [Arguments]        ${paramName}='None'                 ${paramValue}='None'              ${timeout}=300
#     ...                ${paramDst}='None'                  ${operation}=update
#     ...                ${should_activate}=${True}          ${skip_parameter_relation_errors}=${True}
#    admin.perform_parameter_recommissioning          parameter=${paramName}
#     ...        value=${paramValue}             operation=${operation}                         dist_name=${paramDst}
#     ...        skip_parameter_relation_errors=${skip_parameter_relation_errors}
#     ...        should_activate=${should_activate}



#Read Dynamic PUSCH
#    [Arguments]     ${file}
#
#
#    ${pdmlFile}=                    analyzer.pcap_to_pdml        ${file}    pscell
#
#    ${longPucchNumPuschPrb}      analyzer.get_shownames           pdmlFile=${pdmlFile}
#    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
#    ...                                                path=itf_l2_ps_cell_BwpDefinitionUl.longPucchNumPuschPrb_item
#    ...                                                endPacket=${1}
#
#
#
#    ${longPucchStartPuschPrb_item}      analyzer.get_shownames           pdmlFile=${pdmlFile}
#    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
#    ...                                                path=itf_l2_ps_cell_BwpDefinitionUl.longPucchStartPuschPrb_item
#    ...                                                endPacket=${1}
#
#
#    ${longPucchNumDynPuschPrb}   analyzer.get_shownames           pdmlFile=${pdmlFile}
#    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
#    ...                                                path=itf_l2_ps_cell_BwpDefinitionUl.longPucchNumDynPuschPrb_item
#    ...                                                endPacket=${1}
#
#    ${longPucchStartDynPuschPrb_item}      analyzer.get_shownames           pdmlFile=${pdmlFile}
#    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
#    ...                                                path=itf_l2_ps_cell_BwpDefinitionUl.longPucchStartDynPuschPrb_item
#    ...                                                endPacket=${1}
#
#    ${longPucchNumDynPuschPrb_ded_ps}      Create List
#
#    ${longPucchStartDynPuschPrb}           Create List
#
#    FOR   ${prb}   IN   @{longPucchStartDynPuschPrb_item}
#        @{tmp}      Split String   ${prb}    :
#        Append To List      ${longPucchStartDynPuschPrb}    ${tmp[1]}
#    END
#
#    FOR   ${prb}   IN   @{longPucchNumDynPuschPrb}
#        @{tmp}      Split String   ${prb}    :
#        Append To List      ${longPucchNumDynPuschPrb_ded_ps}    ${tmp[1]}
#    END
#
#    set test variable    ${longPucchNumDynPuschPrb_ded_ps}   ${longPucchNumDynPuschPrb_ded_ps}
#    set test variable    ${longPucchStartDynPuschPrb}   ${longPucchStartDynPuschPrb}
#    set test variable    ${longPucchStartPuschPrb_item}   ${longPucchStartPuschPrb_item}
#
#Send Swconfig File To GNB
#    [Arguments]    ${path}
#    ${rc}    OperatingSystem.Run And Return Rc
#    ...    sshpass -p oZPS0POrRieRtu scp ${path} toor4nsn@192.168.255.1:/ffs/run/swconfig.txt
#    Should Be Equal As Integers    ${rc}    0
#Add RD Parameters To GNB Swconfig File
#    [Arguments]    ${rd_parametrs}
#    [Documentation]    This keyword is to add new RD parameters to swconfig.txt
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ${rd_parametrs} | Yes | str joined by symbol ;, like 0x580019=1;0x580011=0;0x580012=0; |
#    ...
#    ...    Examples:
#    ...    | Add RD Parameters To GNB Swconfig File | 0x580019=1;0x580011=0;0x580012=0 |
#    ...
#    ${path}    Get Swconfig File From GNB    ${OUTPUT_DIR}
#    Modify Swconfig File Parameters    ${path}    ${rd_parametrs}
#    Send Swconfig File To GNB    ${path}
#
#Get Swconfig File From GNB
#    [Arguments]    ${save_dir}
#    OperatingSystem.Run
#    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ffs/run/swconfig.txt ${save_dir}/swconfig_gnb.txt
#    OperatingSystem.Should Exist    ${save_dir}/swconfig_gnb.txt
#    ${path}    Set Variable    ${save_dir}/swconfig_gnb.txt
#    [Return]    ${path}
#

#Modify RRU Version Of IPHY XML Custom
#    [Arguments]    ${iphy_path}    ${RRU_type}    ${RRU_Version}
#    ${content}    OperatingSystem.Get File    path=${iphy_path}
#    ${bldVersion}=    String.Get Regexp Matches    ${content}
#    ...    <cardName>${RRU_type}<\/cardName>[\\s\\S]*?<bldVersion>(?P<bldVersion>.*)<\/bldVersion>
#    ...    bldVersion
#    Log Many    ${bldVersion[0]}    ${RRU_Version}
#    ${new_content}    String.Replace String    ${content}    ${bldVersion[0]}    ${RRU_Version}
#    Log To Console    ${new_content}
#    OperatingSystem.Create File    path=${iphy_path}    content=${new_content}
#Send IPHY XML To Airphone custom
#    [Arguments]    ${iphy_path}
#    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
#    ...
#    ...    Examples:
#    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
#    ${rc}    OperatingSystem.Run And Return Rc
#    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} rm -f /ffs/run/simmode/*.xml
#    Should Be Equal As Integers    ${rc}    0
#    ${rc}    OperatingSystem.Run And Return Rc
#    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy_modify.xml
#    Should Be Equal As Integers    ${rc}    0
#    ${soft_link}=    Set Variable    ln -fs /ffs/run/simmode/iphy_modify.xml /ffs/run/simmode/iphy.xml
#    ${rc}    OperatingSystem.Run And Return Rc
#    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} ${soft_link}
#    Should Be Equal As Integers    ${rc}    0

#Change IPHY File Value
#    [Arguments]    ${RU_TYPE}   ${GSCN}
#    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
#    ${c1}    Set Variable    cat ${file_path}|grep -m 4 "card"|tail -n 2|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|
#    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
#    Run    ${c1}${c2}
#
#    ${c1}    Set Variable    cat ${file_path}|grep -m 4 "GSCN"|tail -n 2|awk -F'>' '{print $2 }'|
#    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
#    Run    ${c1}${c2}
#    Send IPHY XML To Airphone   ${file_path}
#    Run    ssh toor4nsn@192.168.200.1 reboot
#    sleep  120s
#
#Change IPHY File Value AP ABIO for FDD
#    [Arguments]    ${RU_TYPE}   ${GSCN}
##    ${OUTPUT_DIR}   Set variable    /home/ute/robotws
#    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
#
#    ${targetbd_fn}=    Run      ssh toor4nsn@192.168.255.129 ls -ltr /ffs/run/|grep TargetBD.*xml$|awk '{ print $9 }'
#    Run     scp toor4nsn@192.168.255.129:/ffs/run/${targetbd_fn} ${OUTPUT_DIR}
#    Should Exist    ${OUTPUT_DIR}/${targetbd_fn}
#    ${target_bd_path}    Set Variable    ${OUTPUT_DIR}/${targetbd_fn}
#
#    ${c1}    Set Variable    cat ${file_path}|grep -m 3 "card"| tail -1 | awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|
#    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
#    Run    ${c1}${c2}
#
#    ${c1}    Set Variable    cat ${file_path}|grep -m 4 "card"|tail -1 | awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|
#    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
#    Run    ${c1}${c2}
#
#    ${c1}    Set Variable    grep -m 3 ${RU_TYPE}|tail -1 | awk -F resourceSWVersion= '{print $2}'|sed 's/"//g;s/>//g'
#    ${new_version}    Run   cat ${target_bd_path}|${c1}
#    log to console     ${new_version}
#
#    ${c2}    Set Variable    grep -m 4 ${RU_TYPE}|tail -1 | awk -F resourceSWVersion= '{print $2}'|sed 's/"//g;s/>//g'
#    ${new_version}    Run   cat ${target_bd_path}|${c2}
#    log to console     ${new_version}
#
#    ${c1}    Set Variable    cat ${file_path}|grep -m 3 '<version>'|tail -1 | awk -F '<version>' '{print $2}'|awk -F '</version>' '{print $1}'|
#    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${new_version}/' ${file_path}
#    Run     ${c1}${c2}
#
#    ${c1}    Set Variable    cat ${file_path}|grep -m 4 '<version>'|tail -1 |awk -F '<version>' '{print $2}'|awk -F '</version>' '{print $1}'|
#    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${new_version}/' ${file_path}
#    Run     ${c1}${c2}
#
#    ${c1}    Set Variable    cat ${file_path}|grep -m 3 "GSCN"| tail -1 | awk -F'>' '{print $2 }'|
#    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
#    Run    ${c1}${c2}
#
#    ${c1}    Set Variable    cat ${file_path}|grep -m 4 "GSCN"| tail -1 | awk -F'>' '{print $2 }'|
#    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
#    Run    ${c1}${c2}
#
#    ${x}   ${y}    get_board_type    192.168.200.1   22    toor4nsn    oZPS0POrRieRtu
#    Run Keyword if    '${x}'=='ASIL' and '${y}'=='ABIO'
#    ...    update_iphy_7145    ${file_path}
#    sleep   4s
#    Send IPHY XML To Airphone   ${file_path}
#    Run    ssh toor4nsn@192.168.200.1 reboot
#    sleep  125s

#Modify IPHY File And Send to Airphone Custom
#    [Arguments]    ${iphy_path}    ${frag}=${-1}
#    ${RRU_type_list}    Get RRU Type From Local IPHY XML Custom   ${iphy_path}    ${frag}
#    FOR    ${RRU_type}    IN    @{RRU_type_list}
#        ${RRU_Version}    Get RRU Version From TargetBD File Custom    ${RRU_type}    ${OUTPUT_DIR}
#        Modify RRU Version Of IPHY XML Custom    ${iphy_path}    ${RRU_type[0]}    ${RRU_Version}
#    END
#    Send IPHY XML To Airphone custom    ${iphy_path}


#Get RRU Type From Local IPHY XML Custom
#    [Arguments]    ${iphy_path}    ${frag}=${-1}
#    ${content}=    OperatingSystem.Get File    path=${iphy_path}
#    ${x}  Set Variable      <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>\\n\\s+(?=<\\/RE>)
#    ${f1}   Set Variable
#    ...     <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>\\n\\s+(?=<fragmentationCapabilities>)
#    ${x}    set variable if    ${frag}==${1}     ${f1}     ${x}
#    @{RRU_type_for_version}    String.Get Regexp Matches    ${content}    ${x}    RRU_type    Ecpri_tag
#    @{RRU_type_list}    String.Get Regexp Matches    ${content}    ${x}    RRU_type
#    Set Suite Variable    ${RRU_TYPE_LIST}    ${RRU_type_list}
#    Set Suite Variable    ${RRU_TYPE}    ${RRU_type_list[0]}
#    Log To Console   RRU Type List from local iphy.xml: ${RRU_type_list}
#     Log To Console    RRU Type from local iphy.xml: ${RRU_TYPE}
#    [Return]    @{RRU_type_for_version}
#
#Get RRU Version From TargetBD File Custom
#    [Arguments]    ${RRU_type}    ${save_dir}
#    ${RRU_type}=    Set Variable If    "${RRU_type[0]}"=="AAHF"    AAHF_C1
#    ...    "${RRU_type[0]}"=="AEUB"    ${RRU_type[0]}
#    ...    "${RRU_type[0]}"=="AEQE"    ${RRU_type[0]}_E1
#    ...    "${RRU_type[0]}"=="AHLOA"    ${RRU_type[0]}
#    ...    "${RRU_type[0]}"=="AEHC"    ${RRU_type[0]}
#    ...    "${RRU_type[0]}"=="AEUD"    ${RRU_type[0]}
#    ...    "${RRU_type[0]}"=="AWEUA"    ${RRU_type[0]}
#    ...    "${RRU_type[0]}"=="AHFII"    ${RRU_type[0]}
#    ...    "${RRU_type[1]}"=="ecpri"    ${RRU_type[0]}_E1
#    ...    ${RRU_type[0]}
#    OperatingSystem.Run
#    ...    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/TargetBD*.xml ${save_dir}/TargetBD.xml
#    OperatingSystem.Should Exist    ${save_dir}/TargetBD.xml
#    ${content}=    OperatingSystem.Get File    path=${save_dir}/TargetBD.xml
#    ${check_point_regexp}    Set Variable    resourceBuildKey="LTX_${RRU_type}".*resourceSWVersion="(?P<RRU_Version>.*)"
#    @{RRU_Version}    String.Get Regexp Matches    ${content}    ${check_point_regexp}    RRU_Version
#    [Return]    @{RRU_Version}[0]

#Check gNB Bulid
#    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
#    ${GNB_SW_VERSION}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
#    Set Suite Variable    ${GNB_SW_VERSION}
#    ${Branch_22R1}    Run Keyword and Return Status   Should Contain    ${GNB_SW_VERSION}     22R1
#    Set Suite variable   ${Branch_22R1}

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

#Load CFG Config
#    [Arguments]    ${wts_cfg_file}
#    Fetch board type
#    Configure UTE ETH3 IPs
#    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
#    ${oam_alias}=    Setup OAM session
#    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
#    #${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
#    Check gNB Airscale is Ready - ${BBoard_Type}
#
#    Log To console     loading cfg file
#    Start Log   btslog    cprt
#    Start WTS Using WTS_Runner and collect SIB1 output     ${wts_cfg_file}
#    ${cprt_log}     Stop Log  cprt  test_scenario=cellsetup
#    set suite variable    ${cprt_log}
#    ${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup
#    set suite variable    ${cell_sys_log}
#
#
#Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
#    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}
#
#
#Read Cellsetup msg
#    [Arguments]    ${file}    ${prbs}=${EMPTY}    ${numbwps}=${EMPTY}
#
#
#    ${pdmlFile}=                    analyzer.pcap_to_pdml        ${file}    pscell
#

#    ${bwptype}      analyzer.get_shownames           pdmlFile=${pdmlFile}
#    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
#    ...                                                path=itf_l2_ps_cell_Bwp.bwpType
#    ...                                                endPacket=${1}



#    ${bandwidth}      analyzer.get_shownames           pdmlFile=${pdmlFile}
#    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
#    ...                                                path=itf_l2_ps_cell_BwpDefinitionUl.bandwidth
#    ...                                                endPacket=${1}

#    ${actprb}      analyzer.get_shownames           pdmlFile=${pdmlFile}
#    ...                                                packetName=itf_l2_ps_cell_cellsetupreq
#    ...                                                path=itf_l2_ps_cell_CellSetupReq_t.actPrbBlanking
#    ...                                                endPacket=${1}
#
#
#  ${pdmlFile}=                    analyzer.pcap_to_pdml        ${file}    nr-rrc
#
#
#    ${scs}      analyzer.get_shownames           pdmlFile=${pdmlFile}
#    ...                                                packetName=nr-rrc.SIB1_element
#    ...                                                path=nr-rrc.ssbSubcarrierSpacing
#    ...                                                endPacket=${-1}
#
#
#
#    ${offset}      analyzer.get_shownames           pdmlFile=${pdmlFile}
#    ...                                                packetName=nr-rrc.SIB1_element
#    ...                                                path=nr-rrc.offsetToPointA
#    ...                                                endPacket=${-1}
#    [RETURN]      ${scs}     ${offset}
##
#
#Start WTS Using WTS_Runner and collect SIB1 output
#    [Arguments]             ${wts_cfg_file}
#    Stop Edaemon and Egate process
#    Stop Sim_enb
#    run    command=sudo rm -rf ${WTS_DIR}/*.log.*
#    Connect To WTS VM
#    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
#    ...                                   directory_path=${WTS_DIR}
#    ...                                   port=22222
#    ...                                   sudo_password=ute
#    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
#    ...                                   directory_path=${WTS_DIR}
#    ...                                   port=20000
#    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
#    ...                                   egate_port=20000
#    wtsrunner.configure                      file=${wts_cfg_file}
#    ${sib1_output}      wtsrunner.read_wtsemu_output_until_re    expected=cell 1: SystemInformationBlockType1-NR updated     timeout=400
#    Set Suite Variable     ${sib1_output}
#    sleep    60s
#    Create File      /home/ute/sib_output.txt       ${sib1_output}
#    Log to Console    Cell onair successful
#    [Return]    ${sib1_output}
#
#Check_and_validate_prb
#     [Arguments]     ${scs}      ${offset}       ${prbs}
#     ${offset}   Remove Duplicates   ${offset}
#     ${scs}      Remove Duplicates   ${scs}
#     ${PointA_30}    Create List
#     ${PointA_15}    Create List
#     FOR     ${i}    IN RANGE   0    2
#     ${single_offset}    Get From List   ${offset}   ${i}
#     ${single_scs}    Get from List   ${scs}      ${i}
#     ${offset_string}   Split String     ${single_offset}
#     ${scs_string}      Split String   ${single_scs}
#     ${30kpointA}        Evaluate    ${Offset_string}[1]/2
#     Run Keyword If  '${scs_string}[1]' == 'kHz30'    Append To List     ${PointA_30}    ${30kpointA}
#     Run Keyword If  '${scs_string}[1]' == 'kHz15'    Append To list     ${PointA_15}    ${Offset_string}[1]
#     END
#     ${Result_15}    Evaluate     ${PointA_15}[0]+20
#     ${Result_30}    Evaluate    ${PointA_30}[0]+20
#     [RETURN]       ${Result_15}    ${Result_30}
#
#Start_capture_testcase_default_logging
#    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
#    set suite variable      ${TEST_NAME}
#    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
#
#Increase Buffer Size for VM and IPHY
#    increase_buffer_size.increase_buffer_size     ${AP_ASIK.ip}      ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}
#
#
#MultiUE Attach for NSA
#    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${chk_fail}=${-1}
#    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
#    LTE Attach should be Successful    ${ue_id}
#    NSA UE Attach    ${UE_ID}    chk_fail=${chk_fail}
#    END
#
#MultiUE DL Traffic Start for NSA
#    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${dl_rate}    ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
#    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
#    Trigger DL Traffic for NSA    ${ue_id}    ${Traffic_rate}    ${dl_rate}    id=${Bearer_ID}    trf_id=${TRF_ID}
#    END
#
#MultiUE UL Traffic Start for NSA
#    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${ul_rate}    ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
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
#
#NSA UE Attach  #NSA
#    [Arguments]    ${UE_ID}    ${chk_fail}=${-1}
#    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
#    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Target_Cells}    ue=${UE_ID}
#    ...                         bearer=${Bearer_ID}    type=split_scg
###    ${fail_pt}    Set Variable    UE${UE_ID}: No band combinations in MR-DC capabilities*
#    ${fail_pt}    Set Variable    value Cause : radioNetwork : tDCprep-expiry
#    ${pattern}    Set Variable If    ${chk_fail}!=${-1}    ${fail_pt}    ${UE_attach_pattern}
#    ${output}    Read WTS Output For Pattern And Print matching Lines    ${pattern}    ${Timeout_NSA}
#    [Return]      ${output}
#
#Add routes
#    [Documentation]    This keyword is to configure VM interfaces..
#    Run    sudo ip addr add 10.0.1.132/24 dev eth3
#    Run    sudo ip addr add 10.0.1.133/24 dev eth3
#    Run    sudo ip addr add 10.0.1.131/24 dev eth3
#    Run    sudo ip addr add 10.0.1.134/24 dev eth3
#    Run    sudo ip addr add 10.0.1.135/24 dev eth3
#    Run    sudo ip addr add 10.0.1.136/24 dev eth3
#    Run    sudo ip addr add 10.0.1.99/24 dev eth3
#    Run    sudo ip addr add 10.0.1.121/24 dev eth3
#    Run    sudo ip addr add 10.0.1.137/24 dev eth3
#    Run    sudo ip addr add 10.0.1.3/24 dev eth3
#    Run    sudo ip addr add 10.0.1.4/24 dev eth3
#    Run    sudo ip addr add 10.0.1.61/24 dev eth3
#    Run    sudo ip addr add 10.0.1.62/24 dev eth3
#    Run    sudo ip addr add 10.0.1.138/24 dev eth3
#    Run    sudo ip addr add 10.0.1.139/24 dev eth3
#    Run    sudo ip addr add 10.0.1.140/24 dev eth3
#    Run    sudo ip addr add 10.0.1.141/24 dev eth3
#
#
#Update GNB R&D Parameter
#   Get GNB Swconfig File    ${LOG_PATH}
#   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
#   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt
#
#
#Trigger A3 RsrpAndRsrq Measurement for intragnb HO Custom
#    [Arguments]     ${start_ue_id}      ${end_ue_id}    ${meas_id}    ${phycell_id}
#    ${houe_crnti_list}      Create List
#    FOR   ${ue_idx}   IN RANGE    ${start_ue_id}      ${end_ue_id}+1
#    wtsrunner.ue_measurement_send_nr    id=${ue_idx}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
#    ...   nrsrp_nr=30    nrsrq_nr=20
#
#    ${output2}   wtsrunner.read_wtsemu_output_until_re    expected=UE${ue_idx}: Intra-eNB handover   timeout=15
#    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
#    ${output1}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
#    Log to Console    ${output}
#    Run      rm -rf ${OUTPUT_DIR}/ho.txt
#    Create File       ${OUTPUT_DIR}/ho.txt     ${output}
#    ${houe_crnti_string}=   Run     cat ${OUTPUT_DIR}/ho.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
#    Append To List     ${houe_crnti_list}   ${houe_crnti_string}
#    BuiltIn.Log     ${houe_crnti_string}
#    END
#    BuiltIn.Log                CRntilist:${houe_crnti_list}
#    [RETURN]        ${houe_crnti_list}
#
#
#Disconnect from DU
#    [Arguments]    ${alias}=default
#    coam.teardown     connection=${alias}
#
#
#Dump RMOD BBMOD And Cell Status
#    Get cgNB RMOD BBMOD And Cell Status
#
#Get cgNB RMOD BBMOD And Cell Status
#    Connect to DU1
#    Check classical RMOD BBMOD And Cell Status
#    [Teardown]    Disconnect from DU
#
#Check classical RMOD BBMOD And Cell Status
#    [Arguments]        ${admin_alias}=default
#    coam.collect_scf     target_file_name=RuntimeStatus.xml      export_type=runtimeObjects      connection=default
#    Get_cGNB_System_Status
#
#Connect to DU1
#    [Arguments]    ${alias}=default
#    ${conn}=    coam.connect_to
##    ...    bts_host=${DU_IP}
#    ...    bts_host=192.168.255.129
#    ...    username=${WEBEM_USERNAME}
#    ...    password=${WEBEM_PASSWORD}
#    ...    name=${alias}
#    [Return]    ${conn}
#
#Verify Counters incrementing as expected
#    Wait until the next Measurement Period starts
#    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
#    Run Keyword And Continue on Failure     Validate PM Counters as per expected value    PM_dir=${PM_dir_1}
#    ...    PM_counter=${NRRC_RRC_RECONF_BWP2_SENT}      expected_value=${2}    moc=NRCELL-3
#
#    Run Keyword And Continue on Failure    Validate PM Counters as per expected value    PM_dir=${PM_dir_1}
#    ...     PM_counter=${NRRC_RCFG_CMP_BWP1_RCVD}      expected_value=${2}    moc=NRCELL-4
#
#Validate PM Counters as per expected value
#    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
#    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
#    ...  pi_id=${PM_counter}    moc=${moc}
#
#Validate PM Counters is non zero
#    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
#    PM_Counters.Check PM counter value bigger than      expected_value=${expected_value}   pm_files_location=${PM_dir}
#    ...  pi_id=${PM_counter}    moc=${moc}
#Verify 8954 counters cell3
#    Wait until the next Measurement Period starts
#    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
#    Run Keyword And Continue on Failure     Validate PM Counters is non zero    PM_dir=${PM_dir_1}    PM_counter=${ACC_UE_DL_SCH_SLOT_BWP1}
#    ...    expected_value=${0}    moc=NRCELL-3
#    Run Keyword And Continue on Failure     Validate PM Counters is non zero    PM_dir=${PM_dir_1}    PM_counter=${ACC_UE_UL_SCH_SLOT_BWP1}
#    ...     expected_value=${0}    moc=NRCELL-3
#    Run Keyword And Continue on Failure     Validate PM Counters as per expected value    PM_dir=${PM_dir_1}
#    ...    PM_counter=${MAX_UE_DL_SCH_SLOT_BWP1}     expected_value=${1}    moc=NRCELL-3
#    Run Keyword And Continue on Failure     Validate PM Counters as per expected value    PM_dir=${PM_dir_1}
#    ...    PM_counter=${MAX_UE_UL_SCH_SLOT_BWP1}    expected_value=${1}    moc=NRCELL-3
#    Run Keyword And Continue on Failure     Validate PM Counters is non zero    PM_dir=${PM_dir_1}    PM_counter=${PRB_USED_PDSCH_BWP1}
#    ...      expected_value=${0}   moc=NRCELL-3
#    Run Keyword And Continue on Failure     Validate PM Counters is non zero    PM_dir=${PM_dir_1}    PM_counter=${PRB_USED_PUSCH_BWP1}
#    ...      expected_value=${0}    moc=NRCELL-3
#Verify 8954 counters cell4
#    Wait until the next Measurement Period starts
#    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
#    Run Keyword And Continue on Failure     Validate PM Counters is non zero    PM_dir=${PM_dir_1}    PM_counter=${ACC_UE_DL_SCH_SLOT_BWP2}
#    ...    expected_value=${0}    moc=NRCELL-4
#    Run Keyword And Continue on Failure     Validate PM Counters is non zero    PM_dir=${PM_dir_1}    PM_counter=${ACC_UE_UL_SCH_SLOT_BWP2}
#    ...   expected_value=${0}    moc=NRCELL-4
#    Run Keyword And Continue on Failure     Validate PM Counters as per expected value   PM_dir=${PM_dir_1}
#    ...   PM_counter=${MAX_UE_DL_SCH_SLOT_BWP2}    expected_value=${1}    moc=NRCELL-4
#    Run Keyword And Continue on Failure     Validate PM Counters as per expected value    PM_dir=${PM_dir_1}
#    ...      PM_counter=${MAX_UE_UL_SCH_SLOT_BWP2}   expected_value=${1}    moc=NRCELL-4
#    Run Keyword And Continue on Failure     Validate PM Counters is non zero    PM_dir=${PM_dir_1}    PM_counter=${PRB_USED_PDSCH_BWP2}
#    ...     expected_value=${0}    moc=NRCELL-4
#    Run Keyword And Continue on Failure     Validate PM Counters is non zero    PM_dir=${PM_dir_1}    PM_counter=${PRB_USED_PUSCH_BWP2}
#    ...     expected_value=${0}    moc=NRCELL-4
#
#Verify locationAndBandwith for allocated BWP
#    [Arguments]      ${logpath}     ${locationandbandwidth_value}
#    log to console       Verifies the value of largeBWP or secondsmallBWP or smallBWP from locationAndBandwith IE captured CPRT logs
#    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}    nr-rrc
#    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
#    ...          field_name=nr-rrc.spCellConfigDedicated_element      attrib_name=showname     attrib_value=spCellConfigDedicated
#    ${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
#    ...    field_name=nr-rrc.locationAndBandwidth    attrib_name=showname
#    ${attrib_values}     convert to string    ${attrib_values}
#    should contain    ${attrib_values}     ${locationandbandwidth_value}
#
#
#Get filtered PDML file from pcap
#    [Arguments]                     ${pcapFile}       ${filterExp}=None
#    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
#    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
#    ...                             filterName=${filterExp}         filterExp=${filterExp}
#    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
#    [Return]    ${pdmlFile}
#
#
#Change GSCN value in IPHY File
#    [Arguments]    ${RU_TYPE}   ${GSCN}
##    ${OUTPUT_DIR}   Set variable    /home/ute/robotws
#    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
#
#    ${targetbd_fn}=    Run      ssh toor4nsn@192.168.255.129 ls -ltr /ffs/run/|grep TargetBD_SBTS.*xml$|awk '{ print $9 }'
#    Run     scp toor4nsn@192.168.255.129:/ffs/run/${targetbd_fn} ${OUTPUT_DIR}
#    Should Exist    ${OUTPUT_DIR}/${targetbd_fn}
#    ${target_bd_path}    Set Variable    ${OUTPUT_DIR}/${targetbd_fn}
#
#    ${c1}    Set Variable    cat ${file_path}|grep -m 2 "GSCN"| awk -F'>' '{print $2 }'|
#    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
#    Run    ${c1}${c2}
#
#    ${x}   ${y}    get_board_type    192.168.200.1   22    toor4nsn    oZPS0POrRieRtu
#    Run Keyword if    '${x}'=='ASIL' and '${y}'=='ABIO'
#    ...    update_iphy_7145    ${file_path}
#    sleep   4s
#    Send IPHY XML To Airphone   ${file_path}
#    Run    ssh toor4nsn@192.168.200.1 reboot
#    sleep  125s
#
#Validate PM Counters
#    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
#    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
#    ...  pi_id=${PM_counter}      moc=MRBTS-1/NRBTS-1/NRCELL-1
#
#Validate PM Counters1
#    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
#    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
#    ...  pi_id=${PM_counter}      moc=MRBTS-1/NRBTS-1/NRCELL-2
#
#Validate PM Counters_pcell_scell
#    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
##    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
##    ...  pi_id=${PM_counter}    moc=${moc}
#    Get Total value of counter and compare   ${PM_dir}   ${PM_counter}   ${expected_value}
#
#
#Verify Counters
#    [Arguments]  ${counters}
#     ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
#     ${counter_ids}=   Get Dictionary Keys    ${counters}
#     FOR   ${counter_id}  IN  @{counter_ids}
#        ${e_value} =	Get From Dictionary	${counters}    ${counter_id}
#        Validate PM Counters_pcell_scell   ${PM_dir_1}   ${counter_id}  ${e_value}   NRCELL-1
#     END
#
#Get Total value of counter and compare
#    [Arguments]   ${pm_files_location}     ${pi_id}    ${expected_value}
#    ${pi_list}=  Create List
#    ...  ${pi_id}
#    ${PM_report_dict_list}=  check_pm.get_pi_value
#    ...  pi_list=${pi_list}
#    ...  pi_dir=${pm_files_location}
#    ...  pi_file_pattern=PM*
#    ${rc}       get_total_cmp      ${PM_report_dict_list}     ${expected_value}
#    Should Contain  ${rc}  PASS
#
#MultiUE NSA Attach should be Successful and Fetch CRNTI  #NSA
#    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${Trgt_Cell}=${Target_Cells}
#    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
#    ${crnti_list}       Create List
#    FOR    ${NSA_UE_ID}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
#    wtsrunner.ue_attach    id=${NSA_UE_ID}
#    ${output}    Read WTS Output For Pattern And Print matching Lines    ${LTE_attach_pattern}    ${Timeout_NSA}
#    Create File     ${OUTPUT_DIR}/regst.txt     ${output}
#    ${x}    Set Variable    grep 'UE performed EPS_ATTACH'
#    ${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt|${x}|awk -F 'crnti: ' '{print $2}'|awk -F ' = ' '{print$1}'
#    BuiltIn.Log     ${crnti_value}
#	Append To List  ${crnti_list}   ${crnti_value}
#    BuiltIn.Log    lte_attach_is_ok
#    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Trgt_Cell}    ue=${NSA_UE_ID}
#    ...  bearer=${Bearer_ID}    type=split_scg
#    ${output1}    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
#    Create File     ${OUTPUT_DIR}/rat1.txt     ${output1}
#    Log to Console             nsa_ue_register_is_ok with ${crnti_value}
#    BuiltIn.Log                nsa_ue_register_is_ok with ${crnti_value}
#    END
#    [Return]      ${crnti_value}
#
#Verify NSA Scell Addition On High Data Traffic
#    [Arguments]     ${start_ue_id}      ${end_ue_id}    ${meas_id}    ${scell_locationbwp}
#    ${caue_crnti_list}      Create List
#    Start NSA 700 Mbps Big DL Data Transfer And Check SCell Activation for 2CC
#    sleep   5s
#    FOR   ${ue_idx}   IN RANGE    ${start_ue_id}      ${end_ue_id}+1
#    Trigger A1 Measurement and verify Scell added successfully    ${ue_idx}   ${meas_id}    ${scell_locationbwp}
#    END
#
#
#MultiUE NSA Attach
#    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${Trgt_Cell}=${Target_Cells}
#    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
#    ${crnti_list}       Create List
#    FOR    ${NSA_UE_ID}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
#    wtsrunner.ue_attach    id=${NSA_UE_ID}
#    ${output}    Read WTS Output For Pattern And Print matching Lines    ${LTE_attach_pattern}    ${Timeout_NSA}
#    BuiltIn.Log    lte_attach_is_ok
#    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Trgt_Cell}    ue=${NSA_UE_ID}
#    ...  bearer=${Bearer_ID}    type=split_scg
#    ${output1}    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
#    Create File     ${OUTPUT_DIR}/rat1.txt     ${output1}
#    ${x}    Set Variable    grep 'newUE-Identity'
#    ${crnti_value}=    Run     cat ${OUTPUT_DIR}/rat1.txt|${x}| awk '{print $2}'|sed 's/.$//'
#    BuiltIn.Log     ${crnti_value}
#    Append To List  ${crnti_list}   ${crnti_value}
#
#    Log to Console             nsa_ue_register_is_ok with ${crnti_value}
#    BuiltIn.Log                nsa_ue_register_is_ok with ${crnti_value}
#    END
#    [Return]      ${crnti_value}
#
#
#
#Start NSA 700 Mbps Big DL Data Transfer And Check SCell Activation for 2CC
#    MultiUE DL Traffic Start for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    mbps    150    id=2    trf_id=1
#    sleep   5s
#    MultiUE DL Traffic Start for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    mbps    150    id=2    trf_id=2
#    sleep   5s    reason=Wait for successful traffic start
#    MultiUE DL Traffic Start for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    mbps    150    id=2    trf_id=3
#    sleep   5s
#    MultiUE DL Traffic Start for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    mbps    150    id=2    trf_id=4
#    sleep   5s    reason=Wait for successful traffic start
#    MultiUE DL Traffic Start for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    mbps    150    id=2    trf_id=5
#    sleep   5s    reason=Wait for successful traffic start
#
#Verify Scell Addition On High Data Traffic
#    [Arguments]     ${start_ue_id}      ${end_ue_id}    ${meas_id}   ${scell_locationbwp}
#    ${caue_crnti_list}      Create List
#    Start 700 Mbps Big DL Data Transfer And Check SCell Activation for 2CC
#    MultiUE Trigger UL Traffic for SA   ${51}  ${52}  Traffic_rate=mbps     ul_rate=110   pdu_id=1   trf_id=1   qfi_id=1
#    sleep   5s
#    FOR   ${ue_idx}   IN RANGE    ${start_ue_id}      ${end_ue_id}+1
#    Trigger A1 Measurement and verify Scell added successfully    ${ue_idx}   ${meas_id}    ${scell_locationbwp}
#    END
#
#Start 700 Mbps Big DL Data Transfer And Check SCell Activation for 2CC
#    MultiUE Trigger DL Traffic for SA    ${1}  ${2}  Traffic_rate=mbps     dl_rate=150   pdu_id=1   trf_id=1   qfi_id=1
#    sleep   5s
#    MultiUE Trigger DL Traffic for SA    ${1}  ${2}  Traffic_rate=mbps     dl_rate=150   pdu_id=1   trf_id=2   qfi_id=1
#    sleep   5s    reason=Wait for successful traffic start
#    MultiUE Trigger DL Traffic for SA    ${1}  ${2}  Traffic_rate=mbps     dl_rate=150   pdu_id=1   trf_id=3   qfi_id=1
#    sleep   5s
#    MultiUE Trigger DL Traffic for SA    ${1}  ${2}  Traffic_rate=mbps     dl_rate=150   pdu_id=1   trf_id=4   qfi_id=1
#    sleep   5s    reason=Wait for successful traffic start
#    MultiUE Trigger DL Traffic for SA    ${1}  ${2}  Traffic_rate=mbps     dl_rate=150   pdu_id=1   trf_id=5   qfi_id=1
#    sleep   5s    reason=Wait for successful traffic start
#
#Verify DL Tput For 2CC T_F
#    FOR   ${ue_idx}   IN RANGE    ${start_ue_id}      ${end_ue_id}+1
#    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${ue_idx}    scell_idx=0    unit=Mbps
#    ${scell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${ue_idx}    scell_idx=1    unit=Mbps
#    Should Be True    ${pcell_tput} > ${140}
#    Should Be True    ${scell_tput} > ${140}
#    END
#
#Verify CA Counters
#    [Arguments]    ${EXPECTED_PCELL_VALUE1}    ${EXPECTED_PCELL_VALUE2}      ${EXPECTED_SCELL_VALUE1}    ${EXPECTED_SCELL_VALUE2}
#    Wait until the next Measurement Period starts
#    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
#    Validate PM Counters is non zero   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER8}
#    ...  expected_value=${EXPECTED_PCELL_VALUE1}   moc=NRCELL-1
#    Validate PM Counters is non zero   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER6}   expected_value=${EXPECTED_PCELL_VALUE2}   moc=NRCELL-1
#    Validate PM Counters bigger than_scell    PM_dir=${PM_dir_1}    PM_counter=${ACC_UE_DL_SCH_SLOT_BWP2}    expected_value=${EXPECTED_SCELL_VALUE1}
#    Validate PM Counters as per expected value   PM_dir=${PM_dir_1}   PM_counter=${MAX_UE_DL_SCH_SLOT_BWP2}
#    ...  expected_value=${EXPECTED_SCELL_VALUE2}   moc=NRCELL-2
#
#Validate PM Counters bigger than_scell
#    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
#    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
#    ...  pi_id=${PM_counter}    moc=NRCELL-2
#
#Modify IPHY File And Send to Airphone
#    [Arguments]    ${iphy_path}
#    ${RRU_type_list}    Get RRU Type From Local IPHY XML   ${iphy_path}
#    FOR    ${RRU_type}    IN    @{RRU_type_list}
#        ${RRU_Version}    Get RRU Version From TargetBD File Custom    ${RRU_type}    ${OUTPUT_DIR}
#    Modify    Modify RRU Version Of IPHY XML Custom    ${iphy_path}    ${RRU_type[0]}    ${RRU_Version}
#    Send IPHY XML To Airphone custom    ${iphy_path}
#
#Get RRU Type From Local IPHY XML
#    [Arguments]    ${iphy_path}
#    ${content}=    OperatingSystem.Get File    path=${iphy_path}
#    ${x}  Set Variable  <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>
#    @{RRU_type_for_version}    String.Get Regexp Matches    ${content}    ${x}    RRU_type    Ecpri_tag
#    @{RRU_type_list}    String.Get Regexp Matches    ${content}    ${x}    RRU_type
#    Set Suite Variable    ${RRU_TYPE_LIST}    ${RRU_type_list}
#    Set Suite Variable    ${RRU_TYPE}    ${RRU_type_list[0]}
#    Log To Console   RRU Type List from local iphy.xml: ${RRU_type_list}
#     Log To Console    RRU Type from local iphy.xml: ${RRU_TYPE}
#    [Return]    @{RRU_type_for_version}
#
#MultiUE Register should be Successful custom
#    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
#    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
#    ${crnti_list}       Create List
#    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
#    wtsrunner.ue_register   id=${ue_idx}
#    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
#    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}
##    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk '{print $9}'
#    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
#    Append To List  ${crnti_list}   ${crnti_string}
#    BuiltIn.Log     ${crnti_string}
#    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
#    Initial Success Message for UE Register and Reregister   ${output}
#
#    # CNI checks 78446 and 81991
#    ${dedicate_conf}    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i -A 15 spCellConfigDedicated|grep firstActiveDownlinkBWP-Id
#    ${rrc_reconf}    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i rrcReconfiguration
#    Should Contain   ${dedicate_conf}   firstActiveDownlinkBWP
#    Should Contain   ${rrc_reconf}   rrcReconfiguration
#    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
#    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
#    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
#    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
#    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
#    END
#
#    Log to Console             multi_ue_register_is_ok with ${crnti_list}
#    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
#    BuiltIn.Log                CRntilist:${crnti_list}
#    [Return]      ${crnti_list}
#
#Start WTS Using WTS_Runner and collect SIB1 output updated
#    [Arguments]             ${wts_cfg_file}
#    Stop Edaemon and Egate process
#    Stop Sim_enb
#    run    command=sudo rm -rf ${WTS_DIR}/*.log.*
#    Connect To WTS VM
#    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
#    ...                                   directory_path=${WTS_DIR}
#    ...                                   port=22222
#    ...                                   sudo_password=ute
#    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
#    ...                                   directory_path=${WTS_DIR}
#    ...                                   port=20000
#    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
#    ...                                   egate_port=20000
#    wtsrunner.configure                      file=${wts_cfg_file}
#    ${sib1_output}      wtsrunner.read_wtsemu_output_until_re    expected=: SystemInformationBlockType1-NR updated     timeout=400
#    Set Suite Variable     ${sib1_output}
#    sleep    60s
#    Create File      /home/ute/sib_output.txt       ${sib1_output}
#    Log to Console    Cell onair successful
#    [Return]    ${sib1_output}
#
#Load CFG Config updated
#    [Arguments]    ${wts_cfg_file}
#    Fetch board type
#    Configure UTE ETH3 IPs
#    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
#    ${oam_alias}=    Setup OAM session
#    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
#    #${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
#    Check gNB Airscale is Ready - ${BBoard_Type}
#
#    Log To console     loading cfg file
#    Start Log   btslog    cprt
#    Start WTS Using WTS_Runner and collect SIB1 output updated     ${wts_cfg_file}
#    ${cprt_log}     Stop Log  cprt  test_scenario=cellsetup
#    set suite variable    ${cprt_log}
#    ${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup
#    set suite variable    ${cell_sys_log}
#
#UE PDU Modfication should be Successful Gbr Congession
#     [Arguments]     ${ue_id}      ${pdu_id}=${Pdu_session_ID}      ${qosflows_to_add}=${Q_O_ADD}
#     wtsrunner.ue_pdu_session_modify      ue=${ue_id}       pdu=${pdu_id}    qosflows_to_add=${qosflows_to_add}    by=amf
#     ${output}    Read WTS Output For Pattern And Print matching Lines    ${pdu_session_unsuccess}     ${Timeout_SA}
#     ${output}    Read WTS Output For Pattern And Print matching Lines    ${failed_pattern}     ${Timeout_SA}
#     Log to Console  ${failed_pattern}
#     [Return]    Pass
