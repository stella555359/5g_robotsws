*** Settings***
Documentation
...    Common keywords for IQ forwarding testcase

Library     OperatingSystem
Library     Process
Library     Collections
Library     DateTime
Library     String
Library     Telnet
Library     XML
Library     json
Library     taf.collectors.core    WITH NAME    CORE
Library     taf.collectors.tcpdump    WITH NAME    TCPDUMP
Library     taf.collectors.tshark    WITH NAME    TSHARK
Library     taf.collectors.journal    WITH NAME    JOURNAL
Library     taf.collectors.btslog    WITH NAME    BTSLOG
Library     taf.collectors.pmcounters    WITH NAME    PMCOUNTER
Library     taf.collectors.snapshot    WITH NAME    SNAPSHOT
Library     taf.collectors.l2stream3    WITH NAME    L2STREAM3
Library     taf.converters.sherpa    WITH NAME    SHERPA
Library     taf.analyzer.sherpa    WITH NAME    SHERPAREADER
Library     taf.ul.parser.pcap    WITH NAME    PCAP
Library     taf.transport.ssh    WITH NAME    SSH
Library     taf.ul.oam.selenium_coam    WITH NAME    SELENIUM
Library     taf.pdu    WITH NAME    PDU
Library     taf.converters.eventdecoder    WITH NAME    EVENTDECODER
#Library    testsuite/QTPH1/AirPhone/resources/ute/yaml_parser.py    WITH NAME    YAMLPARSER_AP
#Library     ./scripts/python/yaml_parser.py    WITH NAME    YAMLPARSER
#Library     ./scripts/python/parse_testconfig_yaml.py    WITH NAME    YAMLPARSER_CN1
Library     ute_wtssim
Library     ute_syslog
Library     ute_fsmaccess
Library     ute_reporting_portal
#Library    ute_admin
#Library    taf.gnb.oam.coam.admin    WITH NAME    COAM
Library     taf.sbts.oam.coam.admin    WITH NAME    COAM
Library     ta5g_egate
Library     ta5g_iperf_traffic
Library     ta_a2a
Library     taf.wts.config
Library     taf.config.wts
Library     ${CURDIR}/tak_xml/

*** Variables ***
${Asik_HOST}                       ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ASIK_USER}                       ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ASIK_PWD}                        ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${WEBUI_HOST}                      ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}                      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}                       ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_ABIL_addr}                    fsp-1-1a
${Loner_addr}                      192.168.253.22
${GNB_ABIL_addr}                   192.168.253.20
${slave_addr}                      192.168.253.21
${Loner_username}                  toor4nsn
${Loner_password}                  oZPS0POrRieRtu
${bip_script}                      ${CURDIR}/../../../CUDU_L2/scripts/BIP/
${file1}                           gnbMirroring.sh
${file2}                           gnbMirroringConfig.sh
${file3}                           gulp
${UE_ID}                           1
${PROFILE_ID_1}                    1
${PROFILE_ID_2}                    2
${scf_path}                        ${CURDIR}
${LOG_PATH}                        ${OUTPUT DIR}
${download_dir}                    ${OUTPUT DIR}/tmp/
${bippath}                         /tmp
${log_name}                        tcpdumpL2L1_filtering_off.pcap0
${1}                               beam_control_testmode_nr
${2}                               ueBeamIndexInitial
${BASELINE}                        ${EMPTY}
${FLAG_CATCH_SUITE_LOG}            ${False}
&{GNB_ASIK}                        ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
@{NR_PHY_CELL_IDS}
${SSH_CMD}                         sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
&{AP_ASIK}                         ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${FILTER_SYSLOG_STATUS}            ${EMPTY}
@{LOG_NAME_LIST}                   btslog    x2pcap    apl3l1    snapshot    egatelog
@{LOG_NAME_SUITE_SETUP}            btslog    x2pcap
@{LOG_NAME_SUITE_TEARDOWN}         snapshot    egatelog    utefiles
${X2AP_CMD}                        tcpdump -i any -s 2000 -w /ffs/run/logs/x2.pcap
${RRU_Version}                     ${EMPTY}
${MAX_WAITTIME_CONFIGURED}         15min
${MAX_WAITTIME_CELL_SETUP}         3min
${MAX_WAITTIME_SOSREPORT}          10min
${MAX_REBOOT_TIME}                 3
${ROOT_TYPE}                       hard_reboot
@{BTS_PROCEDURAL_STATES}           Configured    OnAir    IntegratedToRan
${WTS_DIR}                         /opt/iphy/latest
${WTS_CONFIG_PATH}                 /home/ute/Auto5G/testsuite/QTPH1/AirPhone/resources
@{NR_CELL_DNS}                     /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
${SUITE_LOG_DIRECTORY}             ${EMPTY}
${TEST_LOG_DIRECTORY}              ${EMPTY}
${SW_BRANCH}                       ${EMPTY}    # SBTS22R2
${SW_VERSION}                      ${EMPTY}    # SBTS00    SBTS23R1
${SW_VERSION_TOTAL}                ${EMPTY}    # SBTS00    SBTS23R1_ENB_9999_211111_000006
${WTS_VERSION}                     ${EMPTY}    # 4.0.13303
${SOFTWARE_INFO}                   ${EMPTY}    #SBTS22R2_ENB_9999_211111_000006
${IS_SOFTWARE_KNIFE}               ${False}
${MRBTS_DISTNAME}                  ${EMPTY}    # MRBTS-1
${NRBTS_DISTNAME}                  ${EMPTY}    # MRBTS-1/NRBTS-1
${GNBCUTYPE}                       ${EMPTY}    # NSA/SA
${GNB_FRAME}                       ${EMPTY}    #right_side/left_side
${CELLTECHNOLOGY}                  ${EMPTY}    # TDD/FDD
${FR}                              ${EMPTY}    # mmwv/cmwv
${FCT_BOARD_TYPE}                  ${EMPTY}    # ASIK/ASIB/ASIL
${ASP_BOARD_TYPE}                  ${EMPTY}    # ABIL/ABIO
@{ASP_BOARDS_TYPE}
${RRU_TYPE}                        ${EMPTY}    # AEQA/AHLOA
${RRU_TYPE_LIST}                   # [u'AAHF', u'AHLOA']
${RF_TYPE}                         ${EMPTY}    #CPRI/ECPRI
${L1_TYPE}                         ${EMPTY}    #FS/L1b
${EMIL_DOCKER_COMPOSE_FILE}        ${CURDIR}/scripts/emil/docker-compose.yml
${EMIL_START_CMD}                  ${CURDIR}/scripts/emil/emil_start_cmd.txt
${MPLANE_IP}                       ${EMPTY}
${NR_NON_SIMULATED_CELL_NUM}       ${EMPTY}
${KLL_CMD}                         getResourcesUsage -f cp_rt_all_info_0 -l @Cprt #0x2524
${BOO_CMD}                         getResourcesUsage -f cp_rt_all_info_0 -l @Cprt #0x2515
${CPRT_INFO_LOG_PATH}              /tmp/node_CPRT00/tmp/5gcp_GetResourceUsage/
${MCSHARK_PLUGIN}                  /home/ute/.local/lib/wireshark/plugins/
${AP_PDU_IP}                       ${EMPTY}    #${tl.ues[0].l1.common_units[0].pdu_port.pdu.addr}
${AP_PDU_PORT}                     ${EMPTY}    #${tl.ues[0].l1.common_units[0].pdu_port.port_no}
${GNB_PDU_IP}                      ${EMPTY}    #${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${GNB_PDU_PORT}                    ${EMPTY}    #${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${AP_PDU}                          ${EMPTY}    #${tl.ues[0].l1.common_units[0].pdu_port.pdu}
${GNB_PDU}                         ${EMPTY}    #${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu}
${TLPC_IP}                         ${EMPTY}    #${tl.test_pc.default_ssh_connection_details.addr}
${TLPC_SSH_UE}                     ${EMPTY}    #${tl.test_pc.default_ssh_connection_details.username}
${TLPC_SSH_PWD}                    ${EMPTY}    #${tl.test_pc.default_ssh_connection_details.password}
${VLAN_ID}                         ${EMPTY}    #${tl.gnbs[0].cu.x2c.vlan_id}

*** Keywords ***
Clean Up Env
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=l2stream
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=btslog
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=testVM_Tcpdump
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=oamTShark
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=gnb_pm_counters
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=gnb_coam_snapShot
    Run Keyword And Ignore Error    COAM.Teardown Admin
    Run Keyword And Ignore Error    SHERPA.Teardown    sherpa

Create Suite Directory
    [Documentation]    This keyword is to create a directory for storing suite level logs.
    ...
    ...    ${SUITE_LOG_DIRECTORY} is a suite variable.
    ...    before refine: Test_Suite_Folder_1605087516120
    ...    after refine: Test_Suite_Folder_20201112151625116
    Log To Console    Create Suite Directory...
    Log    ${SUITE_NAME}
    ${time_string}    DateTime.Get Current Date    result_format=timestamp
    ${time_string}    String.Replace String Using Regexp    ${time_string}    (-|:|\\.|\\s)    ${EMPTY}
    ${suite_name2}    String.Replace String    ${SUITE_NAME}    ${SPACE}    _
    Create Directory    ${OUTPUT_DIR}/log/${suite_name2}_${time_string}
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}    ${OUTPUT_DIR}/log/${suite_name2}_${time_string}

Backup Scf
    [Arguments]    ${log_dir}    ${scf_backup_name}
    [Documentation]    This keyword is to back up SCF file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the folder directory to store the scf file |
    ...    | ${scf_backup_name} | Yes | the saved SCF file name. it like SCF_${scf_backup_name}.xml |
    ...
    ...    Examples:
    ...    | Backup Scf | ${SUITE_LOG_DIRECTORY} | before_suite |
    ...    | Backup Scf | ${TEST_LOG_DIRECTORY} | after_suite |
    Log To Console    Backup Scf with name ${scf_backup_name}...
    coam.Setup Admin
    coam.Get Current Scf File    local_dir_path=${log_dir}    file_name=SCF_${scf_backup_name}.xml
    [Teardown]    Run Keyword And Ignore Error    coam.Teardown Admin

Get Default NRBTS DistName
    [Documentation]    This keyword is to get the NRBTS distname for current gNB. e.g.MRBTS-1/NRBTS-1
    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
    ${cells_info}=    COAM.Get Cell List
    ${dist_name}=    Set Variable    ${cells_info['cells']['nr'][0]['id']['configuration']}
    Log    ${dist_name}
    ${mrbts}    ${nrbts}    ${nrcell}    String.Split String    ${dist_name}    /
    Set Suite Variable    ${NRBTS_DISTNAME}    ${mrbts}/${nrbts}
    Set Suite Variable    ${MRBTS_DISTNAME}    ${mrbts}
    Log To Console    NRBTS_DISTNAME: ${NRBTS_DISTNAME}
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Get GNB Type From SCFC
    [Arguments]    ${file_path}=${OUTPUT_DIR}/SCF_before_suite.xml
    [Documentation]    This keyword is to the value of GNB type from current SCF
    ...
    ...    | gNbCuType | NSA/SA/both |
    ...    | cellTechnology | TDD/FDD |
    ...    | freqBandIndicatorNR | mmwv/cmwv | freqBandIndicatorNR>=127 == FR2==mmmv |
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | file_path | No | SCF file path. the default value is ${SUITE_LOG_DIRECTORY}/SCF_before_suite.xml |
    ...
    ...    Examples:
    ...    | Get GNB Type From SCFC |  |  |
    ${GNBCUTYPE}=    Get Single Value From Scf File    ${file_path}    ${NRBTS_DISTNAME}    gNbCuType
    ${GNBCUTYPE}=    Set Variable If    "${GNBCUTYPE}"=="both" or "${GNBCUTYPE}"=="SA+NSA"    SANSA    ${GNBCUTYPE}
    ${CELLTECHNOLOGY}=    Get Single Value From Scf File    ${file_path}    ${NRBTS_DISTNAME}/NRCELL-1    cellTechnology
    ${band_value}=    Get Single Value From Scf File    ${file_path}    ${NRBTS_DISTNAME}/NRCELL-1    freqBandIndicatorNR
    ${fr_tag}    Evaluate    int(${band_value})>=int(127)
    ${FR}    Set Variable If    '${fr_tag}'=='True'    mmwv    cmwv
    ${rf}=    Get Radio Protocol Type    ${file_path}
    Set Suite Variable    ${GNBCUTYPE}
    Set Suite Variable    ${CELLTECHNOLOGY}
    Set Suite Variable    ${FR}
    Set Suite Variable    ${RF_TYPE}    ${rf}

Get Single Value From Scf File
    [Arguments]    ${file_path}    ${dist_name}    ${para_name}    ${list_name}=${EMPTY}
    [Documentation]    This keyword is to get single parameter value from SCF file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | SCF file path |
    ...    | ${dist_name} | Yes | dist name for the parameter |
    ...    | ${para_name} | Yes | parameter name |
    ...    | ${list_name} | No | list name if the parameter in list, the default value is ${EMPTY} |
    ...
    ...    Examples:
    ...    | Get Single Value From Scf File | ${SUITE_LOG_DIRECTORY}/SCF_before_suite.xml | MRBTS-1/NRBTS-1 | gNbCuType |
    ...    | Get Single Value From Scf File | ${SUITE_LOG_DIRECTORY}/SCF_before_suite.xml | MRBTS-1/NRBTS-1 | actDddsReduction | qciTab5Nsa3x |
    ${root}=    XML.Parse XML    ${file_path}
    Should Be Equal    ${root.tag}    raml
    ${ele}=    Run Keyword If    '${list_name}' == '${empty}'
    ...    XML.Get Element    ${root}    .//managedObject[@distName='${dist_name}']//p[@name='${para_name}']
    ...    ELSE    XML.Get Element    ${root}    .//managedObject[@distName='${dist_name}']//list[@name='${list_name}']//p[@name='${para_name}']
    [Return]    ${ele.text}

Get Radio Protocol Type
    [Arguments]    ${scfc_file}
    [Documentation]    This keyword to get radio protocol type from current scfc file
    ...    Examples:
    ...    | ${RF_TYPE}= | Get Radio Protocol Type| /tmp/SCF.xml |
    ${root}=    XML.Parse XML    ${scfc_file}
    Should Be Equal    ${root.tag}    raml
    ${radio_protocol}=    XML.Get Elements Texts    ${root}    xpath=.//p[@name="radioProtocolType"]
    ${ret}=    Run Keyword And Return Status    Should Contain    ${radio_protocol}[0]    eCPRI
    ${rf}=    Set Variable If    '${ret}'=='${True}'    eCPRI    CPRI
    Set Suite Variable    ${RF_TYPE}    ${rf}
    [Return]    ${rf}

Get L1Bypass Type
    [Documentation]    Get TL is configured as L1Bypass mode or FS mode
    ...    Examples:
    ...    | ${L1_type}= | Get L1Bypass Type |
    ${output}=    Run    (sleep 2s; echo "tag -a";sleep 2s)|sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 telnet localhost 15007
    ${result}=    Run Keyword And Return Status   should contain  ${output}   L1BypassMap
    Log    ${result}
    ${L1_TYPE}=    Set Variable IF     "${result}" == "True"    L1b    FS
    Set Suite Variable    ${L1_TYPE}    ${L1_TYPE}
    [Return]    ${L1_TYPE}

Get Software Version
    ${coam_connection}    coam.Connect To    bts_host=${GNB_ASIK.ip}
    ${software_info_1}=    coam.Get Sw Version    connection=${coam_connection}
    Set Suite Variable    ${SOFTWARE_INFO}    ${software_info_1}
    Log    Software Version: ${SOFTWARE_INFO}    console=${True}    #5G21B_GNB_0000_000800_004084_0oeo9    5G21A_GNB_0011_000800_000601
    @{words}=    String.Split String    ${SOFTWARE_INFO}    _
    ${ENB_BUILD}=    Set Variable    ${words[0][0:4]}
    ${IS_SOFTWARE_KNIFE}=    Set Variable If    "${words[-1][0:3]}"=="000"    ${False}    ${True}
    #${ENB_BUILD}=    String.Get Substring    ${SOFTWARE_INFO}    0    4
    Set Suite Variable    ${ENB_BUILD}
    Set Suite Variable    ${IS_SOFTWARE_KNIFE}
    Get Software Version Total
    [Teardown]    coam.Teardown    ${coam_connection}

Get Software Version Total
    [Documentation]    This keyword is to get gNB software version including below 3 suite variables.
    ...
    ...    | Suite variable | Example | Description |
    ...    | ${SW_VERSION} | SBTS00 | get the QT config files with the related version |
    ...    | ${SW_VERSION_TOTAL} | SBTS21B_ENB_9999_210324_000019 | total sw version |
    ...    | ${SW_BRANCH} | SBTS21B | the folder to stort config files for case |
    ...
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    ${status}    Run Keyword And Return Status    Should Be True    ${sw_list[2]}==9999 or ${sw_list[2]}==9990
    Run Keyword If    '${status}'=='True'    Set Suite Variable    ${SW_VERSION}    SBTS00
    ...    ELSE    Set Suite Variable    ${SW_VERSION}    ${sw_list[0]}
    Run Keyword If    '${status}'=='True'    Set Suite Variable    ${SW_VERSION_TOTAL}
    ...    SBTS00_${sw_list[1]}_${sw_list[2]}_${sw_list[3]}_${sw_list[4]}
    ...    ELSE    Set Suite Variable    ${SW_VERSION_TOTAL}    ${SOFTWARE_INFO}
    Set Suite Variable    ${SW_BRANCH}    ${sw_list[0]}
    Log    Software Version Total: ${SW_VERSION_TOTAL}    console=${True}

Get Airphone Software Version
    ute_fsmaccess.Setup Wts Fsm Access
    ${cmd}=    Set Variable    ls /ffs/run/TargetBD_*.xml
    ${targetbd_file}=    ute_fsmaccess.Execute Command On Wts    ${cmd}
    ${tmp1}=    String.Fetch From Right    ${targetbd_file}    TargetBD_
    ${AP_version}=    String.Fetch From Left    ${tmp1}    .xml
    Log    AP Software Version: ${AP_version}      console=${True}
    Set Suite Variable    ${AP_version}
    Set Suite Metadata    AP Version    ${AP_version}
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access
    [Return]    ${AP_version}

Get WTS Version
    [Documentation]    This keyword is to get WTS version including below 1 suite variable.
    ...
    ...    | Suite variable | Example | Description |
    ...    | ${WTS_VERSION} | 4.0.13303 | WTS version |
    ...
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ls -la /opt/iphy/latest
    @{split_list}    String.Split String    ${output}    /
    Set Suite Variable    ${WTS_VERSION}    ${split_list[-1]}
    Log    WTS Version: ${WTS_VERSION}     console=${True}

Get Control Board Type
    [Documentation]    this keyword is used to get control board Type, ASIK, ASIB, ASIL etc.
    ute_fsmaccess.Setup Enb Fsm Access
    ${cmd}=    Set Variable    cat /proc/device-tree/module-identity/unit-id
    ${board_type}=    ute_fsmaccess.Execute Command On Enb    ${cmd}
    ${board_type}=    String.Replace String Using Regexp    ${board_type}    \x00    ${EMPTY}
    Set Suite Variable    ${FCT_BOARD_TYPE}    ${board_type}
    Log    GNB Control Board Type: ${FCT_BOARD_TYPE}     console=${True}
    [Teardown]    ute_fsmaccess.Teardown Enb Fsm Access
    [Return]    ${board_type}

Get AP Control Board Type
    [Documentation]    this keyword is used to get control board Type, ASIK, ASIB, ASIL etc.
    ute_fsmaccess.Setup Wts Fsm Access
    ${cmd}=    Set Variable    cat /proc/device-tree/module-identity/unit-id
    ${board_type}=    ute_fsmaccess.Execute Command On Wts    ${cmd}
    ${board_type}=    String.Replace String Using Regexp    ${board_type}    \x00    ${EMPTY}
    Set Suite Variable    ${AP_FCT_BOARD_TYPE}    ${board_type}
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access
    [Return]    ${board_type}

Check AP Exist
    ${mplane_ip}=    Get Mplane IP Of GNB
    ${is_airphone}=    Set Variable If    "${mplane_ip}"=="10.0.1.2"    ${True}    ${False}
    [Return]    ${is_airphone}

Setup Connections
    [Arguments]    ${is_airphone}=${True}
    Setup GNB Connection
    Run Keyword If    '${is_airphone}'=='${True}'    Setup AP Connection

Setup GNB Connection
    ${GNB_ASIK_CONNECTION}    SSH.Connect To    hostname=${GNB_ASIK.ip}    username=${GNB_ASIK.username}
    ...    password=${GNB_ASIK.password}    alias=${GNB_ASIK.connection}
    Set Suite Variable    ${GNB_ASIK_CONNECTION}

Setup AP Connection
    ${AP_ASIK_CONNECTION}    SSH.Connect To    hostname=${AP_ASIK.ip}    username=${AP_ASIK.username}
    ...    password=${AP_ASIK.password}    alias=${AP_ASIK.connection}
    Set Suite Variable    ${AP_ASIK_CONNECTION}

Get AP Base Band Boards Type
    [Documentation]    this keyword is used to get base band board Type, ABIL\uff0cABIO\uff0cABIN etc.
    ${frame_id_list}=    Create List    1    2    3
    ${AP_ASP_BOARDS_TYPE}    Create List
    Log    AP Base Band Boards Type: ${AP_ASP_BOARDS_TYPE}     console=${True}
    Set Suite Variable    ${AP_ASP_BOARDS_TYPE}
    [Return]    ${AP_ASP_BOARDS_TYPE}

Get RRU Type
    [Documentation]    this keyword is used to get RRU Type, AEQA,AAHF etc.
    ute_fsmaccess.Setup Wts Fsm Access
    ${cmd}=    Set Variable    cat /ffs/run/simmode/iphy.xml|grep -Eo "<cardName>.*</cardName>"|grep -Eo "[[:upper:]]{4,5}"
    ${RRU_type_1}=    ute_fsmaccess.Execute Command On Wts    ${cmd}
    ${RRU_type_list}=    String.Split To Lines    ${RRU_type_1}
    Set Suite Variable    ${RRU_TYPE}    ${RRU_type_list}[0]
    Set Suite Variable    ${RRU_TYPE_LIST}    ${RRU_type_list}
    Log    RRU Type List: ${RRU_type_list}     console=${True}
    Log    RRU Type: ${RRU_TYPE}     console=${True}
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access
    [Return]    ${RRU_type_1}

Get Host IP
    [Documentation]    This keyword is to get testline control host intranet IP.
    ...    Examples:
    ...    | ${host_ip} | Get Host IP |
    ${command}    Set Variable    sudo ifconfig eth0|awk -F "[ :]+" 'NR==2 {print $3}'
    ${rc}    ${output}=    OperatingSystem.Run and Return RC and Output    ${command}
    Log    Host IP:${output}    console=${True}
    Set Suite Metadata    Host IP    ${output}
    Set Suite Variable    ${HOST_IP}    ${output}
	[Return]    ${output}

Get Host Name
    ${ret}    ${host_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    Log    Host Name: ${host_name}     console=${True}
    Log    Testline init file is /home/ute/testline_configuration/${host_name}/      console=${True}
    Set Suite Metadata    Host Name    ${host_name}
    [Return]    ${host_name}

Get Cell Numbers
    ${nr_phy_cell_ids}=    Get PhysCellId Of GNB
    ${cell_number}=    Get Length    ${nr_phy_cell_ids}
    Set Suite Variable    ${COMPONENT_CARRIER}    ${cell_number}
    Log    Cells Number: ${COMPONENT_CARRIER}     console=${True}
    [Return]    ${cell_number}

Get PhysCellId Of GNB
    [Documentation]    This keyword to get radio protocol type from current scfc file
    ${coam_connection}    COAM.Connect To    bts_host=${GNB_ASIK.ip}
    ${cells_info}=    COAM.get_cell_list    connection=${coam_connection}
    ${cell_num}=    Get Length    ${cells_info['cells']['nr']}
    ${pci}=    Create List
    FOR    ${cell_id}    IN RANGE    ${cell_num}
        Append To List    ${pci}    ${cells_info['cells']['nr'][${cell_id}]['physicalCellId']}
    END
    Set Suite Variable    ${NR_PHY_CELL_IDS}
    [Return]    ${pci}
    [Teardown]    COAM.Teardown    ${coam_connection}

Get Mplane IP Of GNB
    [Documentation]    localIpAddr
    ${ip}=    OperatingSystem.Run    ${SSH_CMD} ip addr|grep "inet "|grep -oE "10.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}"|sed -n "1p"
    Set Suite Variable    ${MPLANE_IP}    ${ip}
    [Return]    ${MPLANE_IP}

Suite Setup For Common Setting
    [Arguments]    ${iphy_file}=${EMPTY}
#    Run Keyword And Ignore Error    Run Cmd On PC    pip install ta_a2a -U
#    Run Keyword And Ignore Error    Run Cmd On PC    /opt/tti-dec/venv/bin/pip3 install pandas -U
    Import Testline Variables
    Check GNB EIF Ping OK
    Check AP EIF Ping OK
    Sync Timezone For GNB AP And WTS
    Print Current Time    Start Robot File Time
    Clean Up Env
    Run Keyword If    "${SUITE_LOG_DIRECTORY}"==""    Create Suite Directory
    Backup Scf    ${OUTPUT_DIR}    before_suite
    Get All Testline Information And Set Suite Variable
    Modify UTE Memory Size
    Run Keyword If    '${iphy_file}'!='${empty}'    Get RRU Type From Local IPHY XML    ${iphy_file}
    Print Testline Info Ahead Of Report
    Setup Connections
    Set CP Debug Log

Suite Setup Update GNB
    [Arguments]    ${swconfig_param}=${empty}    ${scf_file}=${empty}    ${iphy_file}=${empty}    ${swconfig_param_AP}=${empty}    ${log}=${True}
    ...    ${force_reboot}=${False}    ${skip_reboot}=${False}    ${vendor_change_list}=${empty}
    [Documentation]    This keyword is to update the configuration of GNB and WTS both, and wait for configured.
    ...                It also capture the logs for cell setup.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${swconfig_param} | No | set RD parameter in swconfig file, e.g.0x580017=3;0x580019=1; |
    ...    | ${scf_file} | No | use scf.xml/delta.json to update gNB parameters |
    ...    |  |  | If ${scf_file} is endwith .xml, Full Commission With SCF File will be triggered. |
    ...    |  |  | If ${scf_file} is endwith .jsom, Delta Commission With SCF File will be triggered. |
    ...    |  |  | It usual exist in ${scf_path}/${SW_BRANCH}/SCF/${scf_file}. |
    ...    |  |  | ${scf_path} set in suite file, ${SW_BRANCH} is a suite variable, can be used directly. |
    ...    | ${iphy_file} | No | update iphy.xml. not support yet |
    ...
    ...    This keyword will reboot testline if need to update configuration.
    ...    The max times to reboot testline is set by ${MAX_REBOOT_TIME} to make sure the TL will onair.
    ...
    ...    Example1: no need to update anything
    ...    | Suite Setup | Run Keywords | Suite Setup Update GNB |
    ...    | ... | AND | Suite Setup Copy WTS Config Files From QT |
    ...    | ... | AND | Suite Setup Start WTS And Check OnAir |
    ...
    ...    Example2: no need to update WTS configuration
    ...    | Suite Setup | Run Keywords | Suite Setup Update GNB | scf_file=scf.xml | swconfig_param=0x580017=3;0x580019=1; |
    ...    | ... | AND | Suite Setup Copy WTS Config Files From QT |
    ...    | ... | AND | Suite Setup Start WTS And Check OnAir |
    ...
    ...    Example3: need update cfg file of WTS,${WTS_DIR}/${WTS_CFG} is a suite variable
    ...    | *** Variables *** | Set below variable if need to update WTS configuration file. | used in example3,5 |
    ...    | @{CFG_OLD_PARAMS} | plmn=[0-9]+:[0-9]+ |
    ...    | @{CFG_NEW_PARAMS} | plmn=302:610 |
    ...
    ...    | Suite Setup | Run Keywords | Suite Setup Update GNB | scf_file=delta.json | swconfig_param=0x580017=3;0x580019=1; |
    ...    | ... | AND | Suite Setup Copy WTS Config Files From QT |
    ...    | ... | AND | Modify Text File | ${WTS_DIR}/${WTS_CFG} | ${cfg_old_params} | ${cfg_new_params} |
    ...    | ... | AND | Suite Setup Start WTS And Check OnAir |
    ...
    ...    Example4: need update xml file of WTS,${WTS_DIR}/${WTS_AP_XML} is a suite variable
    ...    | *** Variables *** | Set below variable if need to update WTS configuration file. | used in example 4,5 |
    ...    | &{xml_params_dict} | prachStartSymbol=2 | prachPreambleFormat=8 | bestBeamRsrp=555 |
    ...
    ...    | Suite Setup | Run Keywords | Suite Setup Update GNB | scf_file=scf.xml | swconfig_param=0x580017=3;0x580019=1; |
    ...    | ... | AND | Suite Setup Copy WTS Config Files From QT |
    ...    | ... | AND | Modify XML File | ${WTS_DIR}/${WTS_AP_XML} | ${xml_params_dict} |
    ...    | ... | AND | Suite Setup Start WTS And Check OnAir |
    ...
    ...    Example5: need update config file of gNB and WTS
    ...    | Suite Setup | Run Keywords | Suite Setup Update GNB | scf_file=delta.json | swconfig_param=0x580017=3;0x580019=1; | |
    ...    | ... | AND | Suite Setup Copy WTS Config Files From QT |  |  |  |
    ...    | ... | AND | Modify Text File | ${WTS_DIR}/${WTS_CFG} | ${cfg_old_params} | ${cfg_new_params} |
    ...    | ... | AND | Modify XML File | ${WTS_DIR}/${WTS_AP_XML} | ${xml_params_dict} |
    ...    | ... | AND | Suite Setup Start WTS And Check OnAir |
    ...
    ...    Example6: need update config file of gNB and WTS from local
    ...    | *** Variables *** | Set below variable if need to update WTS configuration file. | used in example3,5 |
    ...    | ${LOCAL_WTS_DIR} | ${CURDIR}/config |
    ...    | ${WTS_CFG} | xxx.cfg |
    ...    | ${WTS_AP_XML} | xxx.xml |
    ...
    ...    | Suite Setup | Run Keywords | Suite Setup Update GNB | scf_file=delta.json | swconfig_param=0x580017=3;0x580019=1; |
    ...    | ... | AND | Suite Setup Copy WTS Config Files From Local | ${LOCAL_WTS_DIR} |
    ...    | ... | AND | Modify Text File | ${WTS_DIR}/${WTS_CFG} | ${cfg_old_params} | ${cfg_new_params} |
    ...    | ... | AND | Modify XML File | ${WTS_DIR}/${WTS_AP_XML} | ${xml_params_dict} |
    ...    | ... | AND | Suite Setup Start WTS And Check OnAir |
    ...
    ...    Example7: for vendor file
    ...    | &{xml_params_dict1} | Create Dictionary | maxNumLayerPrbDlL1Sp=200 | maxNumLayerPrbUlL1Sp=100 |
    ...    | ...| maxNumStreamPrbDlL1Sp=300 | maxNumStreamPrbUlL1Sp=200 |
    ...    | &{vendor_change_dict1} | Create Dictionary | list_name=bbL1SpPrbCapacity |
    ...    | ... |    | ref_value=ABIO\\d+FDD48 | params_dict=${xml_params_dict1} |
    ...    | &{xml_params_dict2} | Create Dictionary | guaranteedResourceRatioPerCell=10 |
    ...    | &{vendor_change_dict2} | Create Dictionary | list_name=${EMPTY} |
    ...    |  ref_value=${EMPTY}  |  params_dict=${xml_params_dict2} | ${vendor_change_dict2} |
    ...    | @{vendor_change_list} | Create List | ${vendor_change_dict1} | ${vendor_change_dict2} |
    ...    | Suite Setup Update GNB | vendor_change_list=${VENDOR_CHANGE_LIST} |
    Suite Setup For Common Setting
#    Get Default NRBTS DistName
    Run Keyword If    "${log}"=="${True}"    Start Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}
    Set Suite Variable for Suite Backup Files
    Backup And Update Iphy Swconfig File    ${iphy_file}    ${swconfig_param}    ${swconfig_param_AP}
    Backup And Update Vendor SCF File    ${scf_file}    ${vendor_change_list}
    Run Keyword And Return If    '${skip_reboot}'=='${True}'    Log    testline is forced to skip reboot ...    WARN
    ${file_empty_state}=    Catenate    '${scf_file}'!='${empty}' or '${swconfig_param}'!='${empty}' or '${swconfig_param_AP}'!='${empty}'
     ...    or '${iphy_file}'!='${empty}'
    ${file_state}=    Evaluate    ${file_empty_state}
    ${scf_iphy_empty_state}=    Evaluate    '${scf_file}'!='${empty}' or '${swconfig_param}'!='${empty}'
    Run Keyword If    '${file_state}'=='${True}' or '${force_reboot}'=='${True}'
    ...    Reboot TL And Check Configured
    Run Keyword If    '${scf_iphy_empty_state}'=='${True}'    Get All Testline Information And Set Suite Variable

Suite Setup Copy WTS Config Files From Local
    [Arguments]    ${local_wts_dir}    ${wts_cfg_file}=${WTS_CFG}
    [Documentation]    This keyword is used to copy cfg and xml files from local path.
    ...    If this keyword is used, pls make sure you define below 3 parameters in your case.
    ...    ${LOCAL_WTS_DIR}    ${WTS_CFG}    ${WTS_AP_XML}
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${local_dir} | Yes | where cfg and xml files can be found |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    ${LOCAL_WTS_DIR}    ${CURDIR}/resources/wts
    ...    ${WTS_CFG}          basic_fullstack_nsa_call_tdd_cmwv.cfg
    ...    ${WTS_AP_XML}       AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml
    ...
    ...    | Suite Setup Copy WTS Config Files From Local | local_dir=${LOCAL_WTS_DIR} |
    ...
    #Get GNB Type From SCFC
    OperatingSystem.Run    cp ${local_wts_dir}/${wts_cfg_file} ${WTS_DIR}
    # OperatingSystem.Run    cp ${local_wts_dir}/${WTS_AP_XML} ${WTS_DIR}
    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${WTS_DIR}/${wts_cfg_file}
    Set Suite Variable    ${WTS_CFG}    ${wts_cfg_file}
    # Run Keyword And Ignore Error    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${WTS_DIR}/${WTS_AP_XML}

Suite Setup Start WTS And Check OnAir
    [Arguments]        ${log}=${True}    ${enb_id}=1    ${gnb_id}=2    ${wts_cfg_file}=${WTS_CFG}    ${gnb_num}=1
    ${status}    Run Keyword And Return Status
    ...    Suite Setup Start WTS And Check OnAir Without Workaround    ${log}    ${enb_id}    ${gnb_id}    ${wts_cfg_file}    ${gnb_num}
    Run Keyword If    '${status}'=='False'    Workaround For Check SIB2 Fail    ${log}    ${enb_id}    ${gnb_id}    ${wts_cfg_file}    ${gnb_num}

Suite Setup Start WTS And Check OnAir Without Workaround
    [Arguments]    ${log}=${True}    ${enb_id}=1    ${gnb_id}=2    ${wts_cfg_file}=${WTS_CFG}    ${gnb_num}=1
    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Start UTE WTS    ${wts_cfg_file}
    #Get NR Cell Number
    Run Keyword If    '${GNBCUTYPE}'=='NSA'    Setup X2 Connection    ${enb_id}    ${gnb_id}
    Verify Cell Setup    gnb_num=${gnb_num}
    [Teardown]    Run Keyword If    "${log}"=="${True}"    Stop Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}

Start UTE WTS
    [Arguments]    ${wts_cfg_file}=${WTS_CFG}
    [Documentation]    This keyword is to kill Running WTS Binaries If Any, Configure ETH3, Retrieve Files And Configure WTS
    Log To Console    Starting WTS...
    Run Keyword And Ignore Error    Stop Edaemon Egate
    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}     save_egate=${True}
    ute_wtssim.Start Egate Process
    Run Keyword If    '${GNBCUTYPE}'=='SA'    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/${wts_cfg_file}
    ...    pass_regexp=SCTP proxy link    timeout=2min
    ...  ELSE IF    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/${wts_cfg_file}
    ...    pass_regexp=(SimMode is ready now|UEC-1 is active)    timeout=2min
    ...    ELSE    Log To Console    WARN: No cfg file is imported in egate console!!!
#    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Wait Until Keyword Succeeds    120sec    15sec
#    ...    ute_wtssim.Execute Egate Command    state_sim_disp    pass_regexp=The state is ACTIVE

Setup X2 Connection
    [Arguments]    ${enb_id}=1    ${gnb_id}=2
    [Documentation]    This keyword is to setup X2 connection and check x2 is ok
    Log To Console    setup X2 connection...
    ${pattern}    Set Variable    ENB-${enb_id}: X2AP Link with GNB-${gnb_id} .* is up
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    enb_x2_link_up enb\=${enb_id} target\=${gnb_id}
    ...    pass_regexp=${pattern}    timeout=5min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    x2_is_ok

Full Commission With SCF File
    [Arguments]    ${scf_file}    ${auto_update}=False
    [Documentation]    This keyword is to update parameters with delta file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scf_file | Yes | SCF file name.It usual exist in ${scf_path}/${SW_BRANCH}/SCF/${scf_file}. |
    ...    |  |  | ${SW_BRANCH} is get in keyword 'Suite Setup Update GNB', like 5G20A |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${scf_path} | Set Variable | ${CURDIR}/config |
    ...    | Full Commission With SCF File | SCF_5GC002504.xml |    |
    ...    Example2:
    ...    | ${scf_file} | Set Variable | ${CURDIR}/scf.xml |
    ...    | Full Commission With SCF File | ${scf_file} |    |
    Log To Console    Perform full commissioning\uff0cplease use the scf with full configuration saved.
    Get Software Version
    ${scf_pull_path}=    Check Config File Absolute Path Or Relative Path    ${scf_file}
    Log To Console    Config file is ${scf_pull_path}
    ${NRBTS_DISTNAME}    Set Variable If    '${NRBTS_DISTNAME}'==''    MRBTS-1/NRBTS-1    ${NRBTS_DISTNAME}
    ${MRBTS_DISTNAME}    Set Variable If    '${MRBTS_DISTNAME}'==''    MRBTS-1    ${MRBTS_DISTNAME}
    Modify File Parameter    ${scf_pull_path}    MRBTS-[0-9]+/NRBTS-[0-9]+    ${NRBTS_DISTNAME}
    Modify File Parameter    ${scf_pull_path}    MRBTS-[0-9]+    ${MRBTS_DISTNAME}
    Modify VlanId In SCF File    ${scf_pull_path}
    ${auto_update}=    Set Variable If    "${IS_SOFTWARE_KNIFE}"=="${True}" or "${SKIP_ADMIN_CLI}"=="${True}"     ${False}    ${True}
    ${sw}=    Set Variable If    "${BASELINE}"!=""    ${BASELINE}    ${SW_VERSION_TOTAL}
    ${new_scf_path}    Run Keyword If    "${ENB_BUILD}"=="SBTS" and "${auto_update}"=="True"   Migration SCF To New Release    ${scf_pull_path}
    ...    ${sw}
    ${new_scf_path}=    Set Variable If    "${new_scf_path}"=="${None}"    ${scf_pull_path}    ${new_scf_path}
    File Should Exist    ${new_scf_path}
    ${bts_id}    Get Regexp Matches    MRBTS-1/NRBTS-1    MRBTS-(?P<bts_id>\\d+)\\/    bts_id
    COAM.Setup Admin
    COAM.Perform Commissioning
    ...    bts_id=${bts_id[0]}
    ...    scf_file=${new_scf_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Migration SCF To New Release
    [Arguments]    ${scf_path}    ${sw}=${SW_VERSION_TOTAL}
    [Documentation]    This keyword is to use ADMIN CLI to migration SCF for new version.Only support SBTS package.
    ...    This keyword doesn't support 0.400 package.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scf_path} | Yes | the path name for SCF file which need to migrate.
    ...           The SCF file should be saved with FULL CONFIGURATION as need to know swVerion for the SCF file. |
    ...
    ...    Examples:
    ...    | Migration SCF To New Release | /home/ute/Auto5G/testsuite/RRM/ECE/CUDU_L2/Full_Configuration_scf.xml |
    Log To Console    Migration SCF To New Release...
    OperatingSystem.File Should Exist    ${scf_path}
    ${download_file}    Download Zip From WFT    sw=${sw}    store_path=/tmp/
    ${new_scf_path}=    Unzip And Do Migration SCF    ${download_file}    ${scf_path}
    [Return]    ${new_scf_path}

Download Zip From WFT
    [Arguments]    ${sw}=${SW_VERSION_TOTAL}    ${store_path}=/tmp/
    [Documentation]    This keyword is to download zip file from release note.
    ...    used in keyword 'Migration SCF To New Release'
    ...    Return ${download_status}, if download success, it's True. if not, it's False.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${sw} | Yes | the sw release, such as 0.800.1487 |
    ...    | ${store_path} | Yes | the path need to store from download,such as ${output_dir} |
    ...
    ...    Examples:
    ...    | Download Zip From WFT | 0.800.1487 | 5G_0.800.1487_ADMIN_CLI.zip | ${output_dir} |
    Log To Console    Download ADMIN CLI file...
    ${release_url_SBTS}    Set Variable
    ...    ${PACKAGE_FTP_URL_WFT_SBTS}/${SW_VERSION}/${sw}/${sw}_ADMIN_CLI.zip
    OperatingSystem.Run    wget ${release_url_SBTS} -P ${store_path}
    ${ret}=    run keyword and return status    OperatingSystem.Should Exist    ${store_path}/${sw}_ADMIN_CLI.zip
    ${rc}    ${output}=    run and return rc and output    traceroute lterel.es-si-s3-z2.eecloud.nsn-net.net
    run keyword if    "${ret}"=="${False}" and "${rc}"!="0"    Fail    WRN:can't connect to WFT,firewall not open.
    run keyword if    "${ret}"=="${False}" and "${rc}"=="0"    Fail    WRN:There is no ${sw}_ADMIN_CLI.zip on WFT.
    [Return]    ${store_path}/${sw}_ADMIN_CLI.zip

Unzip And Do Migration SCF
    [Arguments]    ${zip_file}    ${input_scf_path}
    [Documentation]    This keyword is to unzip and do migration.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${zip_file} | Yes | the name of the zip file storeed |
    ...    | ${input_scf_path} | Yes | the path of the inputed scf file  |
    ...    Examples: see the detail in keyword 'Migration SCF To New Release'
    ...
    Log To Console    Unzip ADMIN CLI file and do migration...
    ${folder}    ${file_name}=    OperatingSystem.Split Path    ${zip_file}
    OperatingSystem.Run    rm -rf ${folder}/admin_cli/; unzip ${zip_file} -d ${folder}/admin_cli/
    OperatingSystem.Should Exist    ${folder}/admin_cli/migrateScf.sh
    OperatingSystem.Run    cd ${folder}/admin_cli/;sh ${folder}/admin_cli/migrateScf.sh --input-file ${input_scf_path} --output-file output_file.xml
    OperatingSystem.Should Exist    ${folder}/admin_cli/output_file.xml
    [Return]    ${folder}/admin_cli/output_file.xml

Set Suite Variable for Suite Backup Files
    Set Suite Variable    ${SCF_SUITE_BAK_FILE}    ${SUITE_LOG_DIRECTORY}/bak/SCF_before_suite.xml
    Set Suite Variable    ${VENDOR_SUITE_BAK_FILE}    ${SUITE_LOG_DIRECTORY}/bak/Vendor_before_suite.xml
    Set Suite Variable    ${IPHY_SUITE_BAK_FILE}    ${SUITE_LOG_DIRECTORY}/bak/iphy.xml
    Set Suite Variable    ${GNB_SWCONFIG_SUITE_BAK_FILE}    ${SUITE_LOG_DIRECTORY}/bak/swconfig_gnb.txt
    Set Suite Variable    ${AP_SWCONFIG_SUITE_BAK_FILE}    ${SUITE_LOG_DIRECTORY}/bak/swconfig_ap.txt

Set CP Debug Log
    [Documentation]    This keyword is to set CP debug log on GNB_ASIK with the cmd
    ...     echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
    ${cmd_open_cp_debug}    Set Variable    echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
    ${connection_gnb}    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
    SSH.Execute    ${cmd_open_cp_debug}

Backup And Update Iphy Swconfig File
    [Arguments]    ${iphy_file}=${empty}    ${swconfig_param}=${empty}
    ...    ${backup_dir}=${SUITE_LOG_DIRECTORY}/bak
    Create Directory    ${backup_dir}
#    Add RD Parameters To GNB Swconfig File    0x1002A=1    #open catching emil fuction
    Run Keyword If    '${iphy_file}'!='${empty}'    Run Keywords    Get IPHY XML From Airphone    ${backup_dir}
    ...                 AND    Modify IPHY File And Send to Airphone    ${iphy_file}
    Run Keyword If    '${swconfig_param}'!='${empty}'     Run Keywords    Get Swconfig File From GNB    ${backup_dir}
    ...                 AND    Add RD Parameters To GNB Swconfig File    ${swconfig_param}


Get IPHY XML From Airphone
    [Arguments]    ${save_dir}
    [Documentation]    This keyword is to get iphy.xml from Airphone, return file_path include name
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${save_dir} | Yes | where to save iphy.xml |
    ...
    ...    Examples:
    ...    | ${iphy_path} | Get IPHY XML From Airphone | ${OUTPUT_DIR} |
    ...
    ${rc}    ${output}    Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} scp ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy.xml ${save_dir}
    OperatingSystem.Should Exist    ${save_dir}/iphy.xml
    ${iphy_path}    Set Variable    ${save_dir}/iphy.xml
    [Return]    ${iphy_path}

Stop Edaemon Egate
    Run Keyword And Ignore Error    Clean Edaemon And Egate
    OperatingSystem.Run    sudo pkill edaemon
    OperatingSystem.Run    sudo pkill egate
    OperatingSystem.Run    sudo pkill 22222
    OperatingSystem.Run    sudo pkill 20000

Modify RRU Version Of IPHY XML
    [Arguments]    ${iphy_path}    ${RRU_type}    ${RRU_Version}
    ${content}    OperatingSystem.Get File    path=${iphy_path}
    ${bldVersion}=    String.Get Regexp Matches    ${content}
    ...    <cardName>${RRU_type}<\/cardName>[\\s\\S]*?<bldVersion>(?P<bldVersion>.*)<\/bldVersion>
    ...    bldVersion
    Log Many    ${bldVersion[0]}    ${RRU_Version}
    ${new_content}    String.Replace String    ${content}    ${bldVersion[0]}    ${RRU_Version}
    Log    ${new_content}
    OperatingSystem.Create File    path=${iphy_path}    content=${new_content}

Get RRU Version From TargetBD File
    [Arguments]    ${RRU_type}    ${save_dir}
    ${RRU_type}=    Set Variable If    "${RRU_type[0]}"=="AAHF"    AAHF_C1
    ...    "${RRU_type[0]}"=="AEUB"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEHC"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEUD"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AWEUA"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AWHHF"    AWHHF_N1
    ...    "${RRU_type[1]}"=="true"    ${RRU_type[0]}_E1
    ...    ${RRU_type[0]}
    OperatingSystem.Run
    ...    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/TargetBD*.xml ${save_dir}/TargetBD.xml
    OperatingSystem.Should Exist    ${save_dir}/TargetBD.xml
    ${content}=    OperatingSystem.Get File    path=${save_dir}/TargetBD.xml
    ${check_point_regexp}    Set Variable    resourceBuildKey="LTX_${RRU_type}".*resourceSWVersion="(?P<RRU_Version>.*)"
    @{RRU_Version}    String.Get Regexp Matches    ${content}    ${check_point_regexp}    RRU_Version
    [Return]    ${RRU_Version}[0]

Modify IPHY File And Send to Airphone
    [Arguments]    ${iphy_path}
    ${RRU_type_list}    Get RRU Type From Local IPHY XML    ${iphy_path}
    FOR    ${RRU_type}    IN    @{RRU_type_list}
        ${RRU_Version}    Get RRU Version From TargetBD File    ${RRU_type}    ${OUTPUT_DIR}
        Modify RRU Version Of IPHY XML    ${iphy_path}    ${RRU_type[0]}    ${RRU_Version}
    END
    Send IPHY XML To Airphone    ${iphy_path}

Send IPHY XML To Airphone
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

Check Config File Absolute Path Or Relative Path
    [Arguments]    ${config_file}
    [Documentation]    This keyword is used to check scf or delta file absolute path or relative path
    ...    This keyword is very complicated. If you want to modify it,you should run UT.
    ...    UT address:
    ...    Examples:
    ...    Check Config File Absolute Path Or Relative Path    ${CURDIR}/scf.xml
    ...    Check Config File Absolute Path Or Relative Path    ${CURDIR}/delta.json
    ...    Check Config File Absolute Path Or Relative Path    scf.xml
    ...    Check Config File Absolute Path Or Relative Path    delta.json
    Should Not Start With    ${config_file}    .    msg=ERROR: use \$\{CURDIR\} instead of . for config file
    ${dir_status}=    Run Keyword and Return Status    Should Contain    ${config_file}    /
    ${ret}=    run keyword and return status    File Should Exist    ${config_file}
    ${ret2}=    run keyword and return status    File Should Exist    ${SCF_PATH}/${config_file}
    ${ret3}=    run keyword and return status    File Should Exist    ${SCF_DIR}/${config_file}
    ${config_pull_path1}=    set variable if    "${ret}"=="${True}" and ${dir_status}    ${config_file}
    ...    "${ret2}"=="${True}"    ${SCF_PATH}/${config_file}
    ...    "${ret3}"=="${True}"    ${SCF_DIR}/${config_file}
    ${config_pull_path}=    set variable if    "${config_pull_path1}"!="None"    ${config_pull_path1}
    ...    "${config_pull_path2}"!="None"    ${config_pull_path2}
    File Should Exist    ${config_pull_path}
    [Return]    ${config_pull_path}

Modify File Parameter
    [Arguments]    ${file_path}    ${old_value}    ${new_value}
    [Documentation]    This keyword is to replace string for file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | No | the file path which need to modify |
    ...    | ${old_value} | No | the value need to be replaced |
    ...    | ${new_value} | No | the new value |
    ...
    ...    Examples:
    ...    | ${delta_path} | OperatingSystem.Join Path | ${scf_path} | ${SW_BRANCH} | SCF | Delta_Conf_5GC002504.json |
    ...    | Modify File Parameter | ${delta_path} | MRBTS-[0-9]+/NRBTS-[0-9]+ | ${NRBTS_DISTNAME} |
    ${content}=    OperatingSystem.Get File    path=${file_path}
    ${content}=    String.Replace String Using Regexp    string=${content}    pattern=${old_value}    replace_with=${new_value}
    OperatingSystem.Create File    path=${file_path}    content=${content}

Get RRU Type From Local IPHY XML
    [Arguments]    ${iphy_path}
    ${ret}    tak_xml.Evaluate Xml Xpath    ${iphy_path}   count(//RE)
    ${num}    Evaluate      int(${ret})+1
    ${RRU_type_list}    Create List
    ${RRU_type_ecpri_list}    Create List
    FOR     ${index}    IN RANGE     1      ${num}
        ${rru_type}    tak_xml.Evaluate Xml Xpath    ${iphy_path}   string(//RE[${index}]/identity/cardName)
        ${ecpri_tag}    tak_xml.Evaluate Xml Xpath    ${iphy_path}   string(//RE[${index}]/ecpri)
        ${type_list}    Create List    ${rru_type}    ${ecpri_tag}
        Append To List    ${RRU_type_list}    ${rru_type}
        Append To List    ${RRU_type_ecpri_list}    ${type_list}
    END
    Set Suite Variable    ${RRU_type_list}
    Set Suite Variable    ${RRU_TYPE}    ${RRU_type_list[0]}
    [Return]    @{RRU_type_ecpri_list}

Hard Reboot Testline
    Log To Console    Start to hard reboot testline...
    Print Current Time    Hard Reboot Time
    Log To Console    Start to power off AP and GNB...
    ${AP_PDU}=    Get Variable Value    ${AP_PDU}    ${EMPTY}
    Run Keyword If    "${AP_PDU}"=="${EMPTY}"    Import Testline Variables
    Power Off AP
    Wait Until Keyword Succeeds    120s    5s    Check AP Ping NOK
    Power Off GNB
    Wait Until Keyword Succeeds    120s    5s    Check GNB Ping NOK
    Log To Console    Start to power on AP and GNB...
    PDU.Power On    port=${AP_PDU_PORT}    pdu_device=pdu_alias_ap
    PDU.Power On    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_gnb
    ${ret}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    150s    5s    Check GNB And AP Ping OK
    Run Keyword If    "${ret}"=="${False}"    PDU.Power On    port=${AP_PDU_PORT}    pdu_device=pdu_alias_ap
    Run Keyword If    "${ret}"=="${False}"    PDU.Power On    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_gnb
    Wait Until Keyword Succeeds    150s    5s    Check GNB And AP Ping OK
    Wait Until Keyword Succeeds    60s    5s    Check GNB SSH Connect OK
    Wait Until Keyword Succeeds    60s    5s    Check AP SSH Connect OK

Power Off GNB
    PDU.Setup Pdu    ${GNB_PDU}    alias=pdu_alias_gnb
    PDU.Power Off    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_gnb
    #Wait Until Keyword Succeeds    120s    3s    Check PDU Status    pdu_alias_gnb    off    ${GNB_PDU_PORT}

Power Off AP
    PDU.Setup Pdu    ${AP_PDU}    alias=pdu_alias_ap
    PDU.Power Off    port=${AP_PDU_PORT}    pdu_device=pdu_alias_ap
    #Wait Until Keyword Succeeds    120s    3s    Check PDU Status    pdu_alias_ap    off    ${AP_PDU_PORT}

Hard Reboot GNB
    Power Off GNB
    PDU.Power On    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_gnb
    #Wait Until Keyword Succeeds    120s    3s    Check PDU Status    pdu_alias_gnb    on    ${GNB_PDU_PORT}

Hard Reboot Airphone
    Power Off AP
    PDU.Power On    port=${AP_PDU_PORT}    pdu_device=pdu_alias_ap
    #Wait Until Keyword Succeeds    120s    3s    Check PDU Status    pdu_alias_ap    on    ${AP_PDU_PORT}

Check GNB Ping NOK
    ${ret}    ${output}=    Run And Return Rc And Output    ping -c 3 192.168.255.1
    ${console_log}=    Set Variable If    "${ret}"=="0"    VM ping GNB OK!    VM ping GNB NOK!
    Log To Console    ${console_log}
    ${status}=    Set Variable If    "${ret}"=="1"    ${True}    ${False}
    Should Be True    "${ret}"=="1"    WRN:VM ping GNB OK!
    [Return]    ${status}

Check AP Ping NOK
    ${ret}    ${output}=    Run And Return Rc And Output    ping -c 3 192.168.200.1
    ${console_log}=    Set Variable If    "${ret}"=="0"    VM ping GNB OK!    VM ping GNB NOK!
    Log To Console    ${console_log}
    ${status}=    Set Variable If    "${ret}"=="1"    ${True}    ${False}
    Should Be True    "${ret}"=="1"    WRN:VM ping AP OK!
    [Return]    ${status}

Check GNB Ping OK
    ${ret}    ${output}=    Run And Return Rc And Output    ping -c 3 192.168.255.1
    ${console_log}=    Set Variable If    "${ret}"=="0"    VM ping GNB OK!    VM ping GNB NOK!
    Log To Console    ${console_log}
    ${status}=    Set Variable If    "${ret}"=="1"    ${False}    ${True}
    Should Be True    "${ret}"=="0"    WRN:VM ping GNB NOK!
    [Return]    ${status}

Check AP Ping OK
    ${ret}    ${output}=    Run And Return Rc And Output    ping -c 3 192.168.200.1
    ${console_log}=    Set Variable If    "${ret}"=="0"    VM ping AP OK!    VM ping AP NOK!
    Log To Console    ${console_log}
    ${status}=    Set Variable If    "${ret}"=="1"    ${False}    ${True}
    Should Be True    "${ret}"=="0"    WRN:VM ping AP NOK!

Check GNB And AP Ping OK
    ${ret_1}    ${output}=    Run And Return Rc And Output    ping -c 3 192.168.255.1
    ${ret_2}    ${output}=    Run And Return Rc And Output    ping -c 3 192.168.200.1
    ${console_log}=    Set Variable If    "${ret_1}"=="0"    VM ping GNB OK!    VM ping GNB NOK!
    Log To Console    ${console_log}
    ${console_log}=    Set Variable If    "${ret_2}"=="0"    VM ping AP OK!    VM ping AP NOK!
    Log To Console    ${console_log}
    ${status}=    Set Variable If    "${ret_1}"=="1"or "${ret_2}"=="1"    ${False}    ${True}
    Should Be True    "${ret_1}"=="0" and "${ret_2}"=="0"    WRN:VM ping GNB and AP NOK!
    [Return]    ${status}

Check GNB SSH Connect OK
    ${ret}    ${output}=    Run And Return Rc And Output    timeout 5s sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 pwd
    ${console_log}=    Set Variable If    "${ret}"=="0"    SSH connect GNB OK!    SSH connect GNB NOK!
    Log To Console    ${console_log}
    ${status}=    Set Variable If    "${ret}"=="1"    ${False}    ${True}
    Should Be True    "${ret}"=="0"    WRN:VM ssh GNB failed!
    [Return]    ${status}

Check AP SSH Connect OK
    ${ret}    ${output}=    Run And Return Rc And Output    timeout 5s sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 pwd
    ${console_log}=    Set Variable If    "${ret}"=="0"    SSH connect AP OK!    SSH connect AP NOK!
    Log To Console    ${console_log}
    ${status}=    Set Variable If    "${ret}"=="1"    ${False}    ${True}
    Should Be True    "${ret}"=="0"    WRN:VM ssh AP failed!
    [Return]    ${status}

Verify Coam Site Is Ready
    [Documentation]    This keyword is to check the state of gNB is configured and Radio is online.
    Log To Console    verify bts site is ready...
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify BTS Is Configured
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify Radio Is Online
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify All Cells Are Configured

Verify BTS Is Configured
    [Documentation]    This keyword is to check the state of gNB is Configured or IntegratedToRan
    Log To Console    verify BTS is configured...
    Run Keyword And Ignore Error    COAM.Setup Admin
    ${bts_state}    COAM.Get Mrbts State
    Log To Console    [INFO] BTS STATE : ${bts_state}
    Should Contain Any    ${bts_state}    Configured    IntegratedToRan    OnAir    ignore_case=True
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Verify Radio Is Online
    [Documentation]    This keyword is to check the state of Radios are online
    #[Arguments]    ${ru_nums}=${RRU_NUMS}
    #${ru_nums}=    Evaluate    len(${RRU_TYPE_LIST})
    Log To Console    verify Radio is online...
    Run Keyword And Ignore Error    COAM.Setup Admin
    ${bts_hw_info}    COAM.Get Bts Info
    ${ru_nums}=    Get Length    ${bts_hw_info['radioModules']['rmod']}
    Log    RRU number: ${ru_nums}    console=True
    FOR    ${id}    IN RANGE    0    ${ru_nums}
        ${radio_state}    Set Variable
        ...    ${bts_hw_info['radioModules']['rmod'][ ${id}]['status']['operationalState']}
        ${ru_id}=    Evaluate    ${id}+1
        Log To Console    [INFO]    RADIO${ru_id}    STATE : ${radio_state}
        Should Be Equal As Strings    ${radio_state}    enabled    ignore_case=True
    END
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown Admin

Verify All Cells Are Configured
    ${all_cell_status}    Get All Cell Status From COAM
    List Should Not Contain Value    ${all_cell_status}    initializing    WRN:cell is not configured.Check SCF para!

Get All Cell Status From COAM
    [Arguments]    ${status_type}=proceduralStatus
    [Documentation]    This keyword is to get cell status from COAM.
    ...    status_type = administrativeState/availabilityStatus/blockingState/operationalState/proceduralStatus/usageState
    [Teardown]    coam.Teardown    ${coam_connection}
    ${coam_connection}    coam.Connect To
    ${all_cell_info}    coam.Get Cells Info    cell_type=nr    timeout=30    connection=${coam_connection}
    ${all_cell_status}    Create List
    FOR    ${cell_info}    IN    @{all_cell_info}
        ${cell_status}    Evaluate    ${cell_info}.get('status').get('${status_type}')
        Append To List    ${all_cell_status}    ${cell_status}
    END
    [Return]    ${all_cell_status}

Workaround For Check SIB2 Fail
    [Arguments]    ${log}=${True}    ${enb_id}=1    ${gnb_id}=2    ${wts_cfg_file}=${WTS_CFG}    ${gnb_num}=1
    Run Keyword And Ignore Error    Clean Edaemon And Egate
    Run Keyword If    "${gnb_num}"=="1"    Reboot TL And Check Configured
    Suite Setup Start WTS And Check OnAir Without Workaround    ${log}    ${enb_id}    ${gnb_id}    ${wts_cfg_file}    ${gnb_num}

Clean Edaemon And Egate
    ute_wtssim.Teardown Edaemon    alias=edaemon
    ute_wtssim.Teardown Egate

Verify Process Start Success
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}
    [Documentation]    This keyword is to verify if log process start success
    ...    Notice: just available in keywords:Start X2 Pcap Log; Start Gnb BIP Log
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${process_msg} | Yes | A string for the whole command |
    ...    | ${connection} | Yes | the connection to execute the command |
    ...
    ...    Examples:
    ...    | ${cmd} | Set Variable | tcpdump -i etha01 -C 50 -W 2 -w /tmp/5GBipL2L1_filtering_off.pcap |
    ...    | Verify BIP Start Success | 5GBipL2L1_filtering_off.pcap || ${cmd} | ${GNB_ASIK_CONNECTION} |
    ...
    Judge Process Existed    ${part_proc_msg}    ${process_msg}    ${connection}

Judge Process Existed
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}
    [Documentation]    This keyword is to kill the process with the ${process_msg} if it exist.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${process_msg} | Yes | the msg to filter the related process |
    ...    | ${connection} | Yes | the SSH connection to kill process |
    ...
    ...    Examples:
    ...    | ${cmd} | Set Variable | tcpdump -i etha01 -C 50 -W 2 -w /tmp/5GBipL2L1_filtering_off.pcap |
    ...    | Kill Process If Existed | 5GBipL2L1_filtering_off.pcap || ${cmd} | ${GNB_ASIK_CONNECTION} |
    ...
    ${process}    SSH.Execute    command=ps aux|grep '${part_proc_msg}'    connection=${connection}
    ${check_status}    Run Keyword And Return Status     Should Contain    ${process_msg}    \\
    Run Keyword If    '${check_status}'=='${true}'    Should Match Regexp    ${process}    ${process_msg}
    ...    ELSE    Should Contain    ${process}    ${process_msg}

Add RD Parameters To GNB Swconfig File
    [Arguments]    ${rd_parametrs}
    [Documentation]    This keyword is to add new RD parameters to swconfig.txt
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${rd_parametrs} | Yes | str joined by symbol ;, like 0x580019=1;0x580011=0;0x580012=0; |
    ...
    ...    Examples:
    ...    | Add RD Parameters To GNB Swconfig File | 0x580019=1;0x580011=0;0x580012=0 |
    ...
    ${path}    Get Swconfig File From GNB    ${OUTPUT_DIR}
    Modify Swconfig File Parameters    ${path}    ${rd_parametrs}
    Send Swconfig File To GNB    ${path}

Get Swconfig File From GNB
    [Arguments]    ${save_dir}
    OperatingSystem.Run
    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ffs/run/swconfig.txt ${save_dir}/swconfig_gnb.txt
    OperatingSystem.Should Exist    ${save_dir}/swconfig_gnb.txt
    ${path}    Set Variable    ${save_dir}/swconfig_gnb.txt
    [Return]    ${path}

Send Swconfig File To GNB
    [Arguments]    ${path}
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p oZPS0POrRieRtu scp ${path} 'toor4nsn@192.168.255.1:/ffs/run/swconfig.txt;crasign /ffs/run/swconfig.txt'
    Should Be Equal As Integers    ${rc}    0

Modify Swconfig File Parameters
    [Arguments]    ${path}    ${rd_parametrs}
    [Documentation]    This keyword is to append new RD parametes to the end of swconfig.txt or modify if RD already exists.
    ...    This keyword is excuted locally, not on gnb or airphone
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${path} | Yes | str, like: /home/ute/results/swconfig.txt |
    ...    | ${rd_parametrs} | Yes | str, like: 0x580019=1;0x580011=0;0x580012=0 |
    ...
    ...    Examples:
    ...    | Modify Swconfig File Parameters | /home/ute/results/swconfig.txt | 0x580019=1;0x580011=0;0x580012=0; |
    ...
    ${content}    OperatingSystem.Get File    ${path}
    ${rd_items}    String.Split String    ${rd_parametrs}    ;
    FOR    ${item}    IN    @{rd_items}
         Continue For Loop If    '${item}'=='${EMPTY}'
         ${key}    ${val}    String.Split String    ${item}    =    1
         ${matches}    String.Get Regexp Matches    ${content}    (?m)^${key} ?= ?\\w+
         ${content}    Run Keyword If    len(${matches})>0    String.Replace String Using Regexp
    ...    ${content}    @{matches}[0]    ${key}=${val}    ELSE    Set Variable    ${content}\n${item}
    END
    OperatingSystem.Create File    ${path}    ${content}

Modify VlanId In SCF File
    [Arguments]    ${scf_path}
    [Documentation]    This keyword is to make sure VlanId in SCF file as the same as the testline.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |${scf_path} | Yes | the path for scf file, the modified file path is same as the origin one. |
    ...
    ...    Examples:
    ...    | Modify VlanId In SCF File | ${CURDIR}/SCF_after_suite.xml |
    ${MRBTS_DISTNAME}    Set Variable If    '${MRBTS_DISTNAME}'==''    MRBTS-1    ${MRBTS_DISTNAME}
    ${vlanif_distname}    Set Variable    ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
    ${vlan_id}    Convert To String    ${VLAN_ID}
    ${vlan_id_scf}    Get Single Value From Scf File    file_path=${scf_path}    dist_name=${vlanif_distname}    para_name=vlanId
    Log To Console    VlanId in Testline: ${vlan_id}
    Log To Console    VlanId in Origin SCF file: ${vlan_id_scf}
    Set Single Value From Scf File    file_path=${scf_path}
    ...    dist_name=${vlanif_distname}    para_name=vlanId    para_value=${vlan_id}

Set Single Value From Scf File
    [Arguments]    ${file_path}    ${dist_name}    ${para_name}    ${para_value}    ${list_name}=${EMPTY}
    [Documentation]    This keyword is to get single parameter value from SCF file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | SCF file path |
    ...    | ${dist_name} | Yes | dist name for the parameter |
    ...    | ${para_name} | Yes | parameter name |
    ...    | ${list_name} | No | list name if the parameter in list, the default value is ${EMPTY} |
    ...
    ...    Examples:
    ...    | ${file_path} | Set Variable | ${suite_log_directory}/SCF_before_suite.xml |
    ...    | Set Single Value From Scf File | ${file_path} | MRBTS-1/NRBTS-1 | vlanId | 1901 |
    ...    | Set Single Value From Scf File | ${file_path} | MRBTS-1/NRBTS-1 | actDddsReduction | false | qciTab5Nsa3x |
    ${root}=    XML.Parse XML    ${file_path}
    Should Be Equal    ${root.tag}    raml
    Run Keyword If    '${list_name}' == '${empty}'
    ...    XML.Set Element Text    source=${root}    text=${para_value}    xpath=.//managedObject[@distName='${dist_name}']//p[@name='${para_name}']
    ...    ELSE    XML.Set Element Text    source=${root}    text=${para_value}
    ...    xpath=.//managedObject[@distName='${dist_name}']//list[@name='${list_name}']//p[@name='${para_name}']
    XML.Save Xml    ${root}    ${file_path}

Backup And Update Vendor SCF File
    [Arguments]    ${scf_file}=${empty}    ${vendor_change_list}=${empty}
    ...    ${backup_dir}=${SUITE_LOG_DIRECTORY}/bak    ${backup_file_tag}=before_suite
    ${scf_file_type}    Get File Type    ${scf_file}
    Create Directory    ${backup_dir}
    Backup SCF    ${backup_dir}    ${backup_file_tag}
    ${vendor_num}    Get Length    ${vendor_change_list}
    Run Keyword If    '${vendor_num}'!='0'
    ...            Download Vendor File     ${backup_dir}     Vendor_${backup_file_tag}.xml
    Run Keyword If    '${scf_file_type}'=='xml' and '${vendor_num}'=='0'    Full Commission With SCF File    ${scf_file}

Suite Setup Copy WTS Config Files From QT
    [Documentation]    This keyword is to copy the configuration files of WTS from QT by testline type.
    ...    | QT config files | /home/ute/Auto5G/testsuite/QTPH1/AirPhone/resources. |
    ...    | git path | https://wrgitlab.int.net.nokia.com/5G/robotws5g/tree/master/testsuite/QTPH1/AirPhone/resources |
    ...
    ...    | for SA testline | l1_mode is L1Bypass | file is like l1b_tdd_sa_cmwv/0.800/AirPhoneConfig_l1bypass_tdd_sa_cmwv.xml |
    ...    | for NSA testline | l1_mode is FullStack | file is like  fs_fdd_nsa_cmwv/9.1800/AirPhoneConfig_fullstack_fdd_nsa_cmwv.xml |
    Set Suite Variable    ${WTS_CFG}    basic_setup.cfg
    Log    cfg file=${WTS_CFG}
    #Add the part to modify the UE capability to updated ones, since cfg file in QT is out of date sometime
    #Run Keyword If    '${GNBCUTYPE}'=='SA' and '${CELLTECHNOLOGY}'=='TDD' and '${FR}'=='cmwv'
    #...    Modify UE Capabilities In CFG    ${WTS_DIR}/${WTS_CFG}    ${UE_NR_CAPABILITIES_PATT}    ${UE_NR_CAPABILITIES_VAL}

Modify UTE SCTP Timeout
    [Documentation]    This keyword is to start AirPhone load 4.0.10852, The Sack Timeout In The WTS VM And AP ASIK Must Be
    ...    configured before cell setup.This Aims To Prevent Delayed Messaging Between AirPhone
    ...    and WTS (e.g. CTRL_ADD_UE_NR for attach procedure).
    Log To Console    Modify UTE SCTP Timeout...
    OperatingSystem.Run    sudo sysctl -w net.sctp.sack_timeout=20
    OperatingSystem.Run    sudo sysctl -w net.sctp.rto_min=200
    OperatingSystem.Run    sudo sysctl -w net.sctp.rto_initial=200
    OperatingSystem.Run    sudo sysctl -w net.sctp.rto_max=800

Modify AP SCTP Timeout
    [Documentation]    This keyword is to Modify AP SCTP Timeout in Airphon ASIK
    ...      To Prevent Delayed Messaging Between AirPhone and WTS (e.g. CTRL_ADD_UE_NR for attach procedure).
    Log To Console    Modify AP SCTP Timeout...
    ${command}    Catenate    sysctl -w net.sctp.sack_timeout=10 &&
    ...    sysctl -w net.sctp.rto_min=200 &&
    ...    sysctl -w net.sctp.rto_initial=200 &&
    ...    sysctl -w net.sctp.rto_max=800
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 '${command}'

Configure UTE ETH3
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.122/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.123/24 dev eth3    #gnb4
    OperatingSystem.Run    sudo ip addr add 10.0.1.124/24 dev eth3    #gnb3
    OperatingSystem.Run    sudo ip addr add 10.0.1.125/24 dev eth3    #gnb4
    OperatingSystem.Run    sudo ip addr add 10.0.1.12/24 dev eth3    #MO_X2
    OperatingSystem.Run    sudo ip addr add 10.0.1.200/24 dev eth3    #LOLO_AP_LOO
    OperatingSystem.Run    sudo ip addr add 10.0.2.90/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.2.91/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.2.99/24 dev eth4

Teardown All Connections
    [Arguments]    ${is_airphone}=${True}
    SSH.Disconnect    connection=${GNB_ASIK_CONNECTION}
    Run Keyword If    '${is_airphone}'=='${True}'    SSH.Disconnect    connection=${AP_ASIK_CONNECTION}

Start GNB AP Syslog
    [Arguments]    ${log_dir}
    Run Keyword And Ignore Error    ute_syslog.Stop Syslog    alias=${GNB_SYSLOG.alias}
    Run Keyword And Ignore Error    ute_syslog.Stop Syslog    alias=${AP_SYSLOG.alias}
    Run Keyword And Ignore Error    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${log_dir}
    ...    log_name=${GNB_SYSLOG.log_name}    ip=${GNB_SYSLOG.ip}    alias=${GNB_SYSLOG.alias}
    Run Keyword And Ignore Error    ute_syslog.Start Syslog    file_limit=${AP_SYSLOG.file_limit}    log_dir=${log_dir}
    ...    log_name=${AP_SYSLOG.log_name}    ip=${AP_SYSLOG.ip}    alias=${AP_SYSLOG.alias}

Start Logs
    [Arguments]    ${log_name_list}    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to start to capture logs.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_name_list} | Yes | log type list, right now  |
    ...
    ...    | *** Variables *** |
    ...    | @{LOG_NAME_LIST} | btslog | snapshot | tcpdump | tshark | pmcounter |
    ...    Examples:
    ...    | Start Logs | ${log_name_list} |
    ${is_airphone}=    Check AP Exist
    Setup Connections    ${is_airphone}
    Set Suite Variable    ${FLAG_CATCH_SUITE_LOG}    ${True}
    FOR    ${log}    IN    @{log_name_list}
        ${log}    String.Convert To Lowercase    ${log}
        Run Keyword If    '${log}'=='btslog' and "${is_airphone}"=="${True}"    Start GNB AP Syslog    ${log_dir}
    END

Stop Logs
    [Arguments]    ${log_name_list}    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to stop logs.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | @{log_name_list} | Yes | log type list, right now  |
    ...
    ...    | *** Variables *** |
    ...    | @{LOG_NAME_LIST} | btslog | snapshot | tcpdump | tshark | pmcounter |
    ...    Examples:
    ...    | Stop Logs | @{log_name_list} |
    #Setup Connections
    ${is_airphone}=    Check AP Exist
    Set Suite Variable    ${FLAG_CATCH_SUITE_LOG}    ${False}
    FOR    ${log}    IN    @{log_name_list}
        ${log}    String.Convert To Lowercase    ${log}
        Run Keyword If    '${log}'=='btslog' and "${is_airphone}"=="${True}"
        ...    Run Keyword And Ignore Error    Collect Syslog Results    log_dir=${log_dir}
        Run Keyword If    '${log}'=='snapshot'    Run Keyword And Ignore Error    Save Coam SnapShot    log_dir=${log_dir}
        Run Keyword If    '${log}'=='utefiles'    Run Keyword And Ignore Error    Collect UTE Files    log_dir=${log_dir}
        Run Keyword If    '${log}'=='egatelog'    Run Keyword And Ignore Error    Save Egate Log    ${log_dir}
    END

Collect UTE Files
    [Arguments]    ${log_dir}
    Run Keyword And Ignore Error    OperatingSystem.Copy Files    ${wts_dir}/${wts_cfg}    ${wts_dir}/${wts_ap_xml}
    ...    ${tl_init_dir}/DEBUG_log.txt    ${tl_init_dir}/INFO_log.txt    ${log_dir}/
    SSH.Connect To    ${AP_ASIK.ip}    ${AP_ASIK.username}    ${AP_ASIK.password}
    ...    alias=${AP_ASIK.connection}
    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
    ...    alias=${GNB_ASIK.connection}
    @{configs}    Create List    /ffs/run/swconfig.txt    /rom/simmode/iphy.xml
    SSH.Download File    ${configs}    ${log_dir}/    ${AP_ASIK.connection}
    SSH.Download File    /ffs/run/swconfig.txt    ${log_dir}/swconfig_gnb.txt
    ...    ${GNB_ASIK.connection}

Save Egate Log
    [Arguments]    ${log_path}=${SUITE_LOG_DIRECTORY}
    [Documentation]    This keyword is to copy egate console log from /opt/iphy/latest/egate_console.log to ${log_path}
    ...    after execute 'sim_log_set flush'
    ute_wtssim.Execute Egate Command    sim_log_set flush
    OperatingSystem.Copy Files    /opt/iphy/latest/egate_console.log*    ${log_path}

Save Coam SnapShot
    [Arguments]    ${log_dir}=${test_log_directory}
    ${coam_connection}    coam.Connect To    bts_host=${GNB_ASIK.ip}
    coam.Get SnapShot    target_file_name=${log_dir}/snapShot.zip    coverage=Full    force=True    connection=${coam_connection}
    [Teardown]    coam.Teardown    ${coam_connection}

Verify Cell Setup
    [Arguments]    ${gnb_num}=1
    [Documentation]    This keyword is to wait for cell setup successfully.It checks print in aiphone APL3.log
    ...
    ...           The max waiting time is set by ${MAX_WAITTIME_CELL_SETUP},the default value is 3 minutes
    Log To Console    verify cell setup...
    Get NR Cell Number    ${gnb_num}
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CELL_SETUP}    15s    Check UTE ASIK AP Cell Setup    ${NR_NON_SIMULATED_CELL_NUM}
    Log    cell_setup_is_ok

Get NR Cell Number
    [Arguments]    ${gnb_num}=1
    ${cell_num_cfg}=    Get Cell Number From Cfg
    ${cell_num_gnb}=    Run Keyword If    "${gnb_num}"=="1"    Get Cell Numbers
    ${cell_num}=    Set Variable If    ${cell_num_cfg}<${cell_num_gnb}    ${cell_num_cfg}    ${cell_num_gnb}
    Set Suite Variable    ${NR_NON_SIMULATED_CELL_NUM}    ${cell_num}

Get Cell Number From Cfg
    [Arguments]    ${cfg_path}=${WTS_DIR}    ${wts_cfg_file}=${WTS_CFG}
    [Documentation]    This keyword is to get cell num from cfg file with count the number of 'set_cell id='
    ...
    ${content}    OperatingSystem.Get File    path=${cfg_path}/${wts_cfg_file}
    ${regexp}    Set Variable    ^set_cell id=.*?gnb=
    ${match_list}     Get Lines Matching Regexp    ${content}    ${regexp}    partial_match=true
    Log    ${match_list}
    ${cell_num}    Get Count    ${match_list}    set_cell id=
    [Return]    ${cell_num}

Check UTE ASIK AP Cell Setup
    [Documentation]    This keyword is to check "Cell Setup Completed" in Airphone ASIK
    [Arguments]    ${check_cell_count}=1
    Log To Console    check ute ASIK AP cell setup...
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.200.1:/tmp/APL3.log ${OUTPUT_DIR}
    ${cell_complete_print}=    Set Variable    Cell Setup completed
    ${output}=    OperatingSystem.Run    grep -i "${cell_complete_print}" ${OUTPUT_DIR}/APL3.log
    ${cell_complete_num}=    Get Count    ${output}    ${cell_complete_print}
    Should Be True    ${cell_complete_num}>=${check_cell_count}

NSA LTE Attach
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate UE attach on LTE side during NSA L3 Call on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | profile_id | Yes | profile id |
    ...    Example:
    ...    | NSA LTE Attach | 1 | 1 |
    Log To Console    start LTE attach...
    ${output}    ute_wtssim.Execute Egate Command
    ...    cmd=ue_attach id\=${ue_id}    pass_regexp=UE IS ACTIVE    timeout=300
    Log To Console    lte_attach_is_ok
    Sleep    3s    reason=wait LTE attach is stable
    [Return]    ${output}

NSA 5G Attach
    [Arguments]    ${ue_id}    ${gnb_id}    ${cell_id}    ${bearer_id}
    [Documentation]    This keyword is used to simulate UE attach on 5GNR side during NSA L3 Call on eGate.
    ...    Expected output is: "UE1: Proxy (eNB 2 Cell 2 ) reported successful RA" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | gnb_id | Yes | gnb id |
    ...    | cell_id | Yes | cell id |
    ...    | bearer_id | Yes | bearer id |
    ...    Example:
    ...    | NSA 5G Attach | 1 | 2 | 2 | 2 |
    Log To Console    start 5G attach...
    ${output}=    ute_wtssim.Execute Egate Command
    ...    cmd=ue_dc_enb_start ue\=${ue_id} target_gnb\=${gnb_id} target_cells\=${cell_id} bearer\=${bearer_id} type\=split_scg
    ...    pass_regexp=reported successful RA|Proxy reported failure    timeout=300
    ${ret}=    Run Keyword And Return Status    Should Contain    ${output}    reported successful RA
    Run Keyword If    "${ret}"=="${False}"    Fail    NSA 5G Attach fails!!!
    Should Be True    ${ret}
    Log To Console    UE_attach_is_ok
    Sleep    3s    reason=wait 5G attach is stable
    [Return]    ${output}

NSA LTE Detach
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to detach ue.
    ute_wtssim.Execute Egate Command    cmd=ue_detach id\=${ue_id}    pass_regexp=detached

NSA Start DL Traffic
    [Arguments]    ${ue_id}    ${bearer_id}    ${mbps}    ${trf_id}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | mbps | Yes | mbps |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Start DL Traffic | 1 | 2 | 10 |
    ${times}    Evaluate    int(${mbps}/${175})
    Run Keyword If    ${times}==${0} or '${mbps}'=='175'     ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} id\=${bearer_id} dir=dl mbps\=${mbps} trf_id\=${trf_id} seconds=9999
    Sleep    2s    reason=wait DL traffic is stable

NSA Start UL Traffic
    [Arguments]    ${ue_id}    ${bearer_id}    ${mbps}    ${trf_id}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | mbps | Yes | mbps |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Start UL Traffic | 1 | 2 | 10 |
    Log To Console    start UL traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} id\=${bearer_id} dir=ul mbps\=${mbps} trf_id\=${trf_id} seconds=9999
    Sleep    5s    reason=wait UL traffic is stable

NSA Stop Traffic
    [Arguments]    ${ue_id}    ${bearer_id}    ${dir}=bi    ${trf_id}=1
    [Documentation]    This keyword is to stop traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | dir | Yes | ul or dl, default is bi |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Stop Traffic | 1 | 2 | dl |
    Log To Console    stop ${dir} traffic...\n
    Run Keyword If    '${dir}'=='bi'    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} id\=${bearer_id} dir\=${dir}
    ...    ELSE    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} id\=${bearer_id} dir\=${dir} trf_id\=${trf_id}

NSA UE Check Throughput
    [Arguments]    ${UE_ID}=11    ${dl_tp_threshold}=5    ${ul_tp_threshold}=5
    ${dl_tp}=    NSA Get UE Average Traffic    ue_id=${UE_ID}    bearer_id=2    dir=dl
    ${ul_tp}=    NSA Get UE Average Traffic    ue_id=${UE_ID}    bearer_id=2    dir=ul
    log    DL Troughput is ${dl_tp}    console=True
    log    UL Troughput is ${ul_tp}    console=True
    ${tp_delta}    Evaluate    ${dl_tp}-${dl_tp_threshold}
    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
    Log To Console    The TPUT is bigger than target: ${dl_tp_threshold}M \n
    ${tp_delta}    Evaluate    ${ul_tp}-${ul_tp_threshold}
    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
    Log To Console    The TPUT is bigger than target: ${ul_tp_threshold}M \n

NSA Get UE Average Traffic
    [Arguments]    ${ue_id}    ${bearer_id}    ${dir}
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | dir | Yes | Direction of Traffic |
    ...    Example:
    ...    | NSA Get UE Average Traffic | 1 | 2 | ul |
    ...    | NSA Get UE Average Traffic | 1 | 2 | dl |
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} id\=${bearer_id} dir\=${dir} dc_cell_group=all
    ...    pass_regexp=Average packet interval    timeout=150
    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${tp_delta}    Evaluate    ${avg}*0.000001
    [Return]    ${tp_delta}

Kill Process If Existed
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}    ${kill_para}=2
    [Documentation]    This keyword is to kill the process with the ${process_msg} if it exist.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${process_msg} | Yes | the msg to filter the related process |
    ...    | ${connection} | Yes | the SSH connection to kill process |
    ...
    ...    Examples:
    ...    | ${cmd} | Set Variable | tcpdump -i etha01 -C 50 -W 2 -w /tmp/5GBipL2L1_filtering_off.pcap |
    ...    | Kill Process If Existed | 5GBipL2L1_filtering_off.pcap || ${cmd} | ${GNB_ASIK_CONNECTION} |
    ...
    ${status}    Run Keyword And Return Status    Judge Process Existed    ${part_proc_msg}    ${process_msg}    ${connection}
    Run Keyword If    '${status}'=='${true}'    SSH.Execute
    ...    command=ps aux|grep '${part_proc_msg}'|awk '{print $2}'|xargs kill -${kill_para}    connection=${connection}

Get File Type
    [Arguments]    ${file}
    [Documentation]    This keyword is to get the name extension of a file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file} | Yes | file name need to get the name extension |
    ...
    ...    Examples:
    ...    | Get File Type | delta.json |
    ...    | Get File Type | scf.xml |
    @{file_list}    String.Split String    ${file}    .
    [Return]    ${file_list[-1]}

Reboot TL And Check Configured
    [Documentation]    This keyword is to soft reboot testline and check the status is configured.
    ...            It with try ${MAX_REBOOT_TIME} times to make sure the testline can be reboot successfully.
    Log To Console    Make sure BTS site is ready by rebooting at most ${MAX_REBOOT_TIME} times...
    #Run Keyword And Ignore Error    Wait GNB And AP SSH Connect OK
    Set Suite Variable    ${reboot_sucess_flag}    ${False}
    FOR    ${index}    IN RANGE    1    ${MAX_REBOOT_TIME}+1
        Log To Console    ===============Reboot Time: ${index}==============
        Hard Reboot Testline
        ${res}    Run Keyword And Return Status    Verify Coam Site Is Ready
        ${reboot_sucess_flag}=    Set Variable If    '${res}'=='True'    ${True}
        Exit For Loop If    '${res}'=='True'
    END
    Should Be True    "${reboot_sucess_flag}"=="${True}"    WRN:Reboot ${MAX_REBOOT_TIME} times,RRU still can't go to green state.

Get All Testline Information And Set Suite Variable
    Get Default NRBTS DistName
    Get GNB Type From SCFC
    Get L1Bypass Type
    Run Keyword If    '${SW_BRANCH}'=='${EMPTY}'    Get Software Version
    Get Airphone Software Version
    Get WTS Version
    Get Control Board Type
    Get AP Control Board Type
    Get AP Base Band Boards Type
    Get RRU Type
    Get Host IP
    Get Host Name
    Get Cell Numbers
    Get Mplane IP Of GNB

Common Suite Setup 2
    Suite Setup Update GNB    log=${False}
    Suite Setup Copy WTS Config Files From QT
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3

Import Testline Variables
    ${ret}    ${host_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${testline_config_path}=    Set Variable    /home/ute/testline_configuration/${host_name}/
    ${ret}=    Run Keyword And Return Status    File Should Exist    ${testline_config_path}/__init__.py
    ${testline_config_path}=    Set Variable If    "${ret}"=="${True}"    ${testline_config_path}
    ...    /home/ute/testline_init_results/configs/${host_name}/
    Log    Testline init file is ${testline_config_path}      console=${True}
    Import Variables    ${testline_config_path}
    Set Suite Variable    ${AP_PDU_IP}    ${tl.ues[0].l1.common_units[0].pdu_port.pdu.addr}
    Set Suite Variable    ${AP_PDU_PORT}    ${tl.ues[0].l1.common_units[0].pdu_port.port_no}
    Set Suite Variable    ${GNB_PDU_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    Set Suite Variable    ${GNB_PDU_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    Set Suite Variable    ${AP_PDU}    ${tl.ues[0].l1.common_units[0].pdu_port.pdu}
    Set Suite Variable    ${GNB_PDU}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu}
    Set Suite Variable    ${TLPC_IP}    ${tl.test_pc.default_ssh_connection_details.addr}
    Set Suite Variable    ${TLPC_SSH_UE}    ${tl.test_pc.default_ssh_connection_details.username}
    Set Suite Variable    ${TLPC_SSH_PWD}    ${tl.test_pc.default_ssh_connection_details.password}
    Set Suite Variable    ${VLAN_ID}    ${tl.gnbs[0].cu.x2c.vlan_id}

Start WTS And Check OnAir
    Start UTE WTS    # This step already includes kill egate and edaemon
    Verify Cell Setup
    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup X2 Connection

Common Test Setup 2
    Create Test Directory
    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}

Create Test Directory
    [Documentation]    This keyword is to create a directory for storing case level logs.
    ...
    ...        ${TEST_LOG_DIRECTORY} is a test variable.
    Log To Console    Create Case Directory...
    ${SUITE_LOG_DIRECTORY}    Get Variable Value    ${SUITE_LOG_DIRECTORY}    ${EMPTY}
    Run Keyword If    "${SUITE_LOG_DIRECTORY}"=="${EMPTY}"    Create Suite Directory
    ${test_name2}    string.Replace String    ${TEST_NAME[:50]}    ${space}    _
    Create Directory    ${SUITE_LOG_DIRECTORY}/${test_name2}
    Set Test Variable    ${TEST_LOG_DIRECTORY}    ${SUITE_LOG_DIRECTORY}/${test_name2}

Check GNB EIF Ping OK
    ${ret}    ${output}=    Run And Return Rc And Output    ping -c 3 10.0.1.2 -i 0.5
    ${status}=    Set Variable If    "${ret}"=="1"    ${False}    ${True}
    Should Be True    "${ret}"=="0"    WRN:VM ping GNB EIF failed!
    ${ret}    ${output}=    Run And Return Rc And Output    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 "ping -c 3 10.0.1.1"
    ${status}=    Set Variable If    "${ret}"=="1"    ${False}    ${True}
    Should Be True    "${ret}"=="0"    WRN:GNB EIF ping VM failed!
    [Return]    ${status}

Check AP EIF Ping OK
    ${ret}    ${output}=    Run And Return Rc And Output    ping -c 3 10.0.2.80 -i 0.5
    ${status}=    Set Variable If    "${ret}"=="1"    ${False}    ${True}
    Should Be True    "${ret}"=="0"    WRN:VM ping AP EIF failed!
    ${ret}    ${output}=    Run And Return Rc And Output    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 "ping -c 3 10.0.2.1"
    ${status}=    Set Variable If    "${ret}"=="1"    ${False}    ${True}
    Should Be True    "${ret}"=="0"    WRN:AP EIF ping VW failed!
    [Return]    ${status}

Sync Timezone For GNB AP And WTS
    OperatingSystem.Run    sudo timedatectl set-timezone UTC
    Sleep    5s    wait for timezone is changed.
    ${get_time_cmd}=    Set Variable    echo $(date "+%Y-%m-%d %H:%M:%S").$((`date "+%N"`/1000000))
    ${vm_date}=    Run    ${get_time_cmd}
    ${gnb_date}=    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 ${get_time_cmd} 2>/dev/null
    ${ap_date}=    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 ${get_time_cmd} 2>/dev/null
    Log    vm_time:${vm_date},gnb_time:${gnb_date},ap_time:${gnb_date}    console=True
    #OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 timedatectl set-timezone "Asia/Shanghai"
    #OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 timedatectl set-timezone "Asia/Shanghai"

Print Current Time
    [Arguments]    ${log}=...
    ${date}=    DateTime.Get Current Date
    BuiltIn.log to console    ${date}:${log}

Common Suite Teardown
    [Documentation]    This keyword is to collect the logs.
    Run Keyword And Ignore Error    Get Alarms
    Run Keyword And Ignore Error    Stop Logs    ${LOG_NAME_SUITE_TEARDOWN}    ${SUITE_LOG_DIRECTORY}
#    Run Keyword If    '${mode}'!='debug'    Run Keyword And Ignore Error    Stop Logs    {LOG_NAME_SUITE_TEARDOWN}    ${SUITE_LOG_DIRECTORY}
    Teardown All Connections
    ute_wtssim.Teardown All Aliases For Wts
    Run Keyword And Ignore Error    Stop Edaemon Egate
    Run Keyword And Ignore Error    Filter ERR WRN Message From Syslog By Log Path    ${SUITE_LOG_DIRECTORY}
    ...    ${CURDIR}/filter_msg.txt    ${SUITE_LOG_DIRECTORY}/suite_fatal_log.txt
    Auto_Analyze_Error    ${SUITE_LOG_DIRECTORY}/suite_fatal_log.txt

Get Alarms
    [Documentation]    not issue alarm:
    ...    61652: R&D Service Port enabled
    ...    4654: Ethernet port security is disabled
    ...    4655: Service account root access is enabled
    ...    61524: SSH enabled
    ...    7523: Cell Activation timeout at gNB-DU
    ...    61649: LMP access via port 443
    ...    7103: SA cell activation failed
    ...    7100: F1 Cell activation failed due to X2 link unavailable
    ...    7305: NG SCTP setup fail
    ...    4298: ToP reference missing
    ...    7300: No X2 link available
    ...    7101: gNB CpCell configuration update failure
    ${alarm_white_list}=    Create List    61652    61524    4654    4655    61649    4298
    ${alarm_message_list}=    Create List
    ${fault_id_list}=    Create List
    COAM.Setup Admin
    ${alarm}=    COAM.Get Alarms
    FOR    ${item}    IN    @{alarm}
        ${alarmId}=    Set Variable    &{item}[alarmId]
        ${faultId}=    Set Variable    &{item}[faultId]
        ${faultSeverity}=    Set Variable    &{item}[faultSeverity]
        ${alarm_info}=    Set Variable    &{item}[alarmInformation]
        ${faultDescription}=    Set Variable    &{alarm_info}[faultDescription]
        #${alarm_white_list}=    Evaluate    map(int,${alarm_white_list})
        ${ret}=    Evaluate    ${faultId} in ${alarm_white_list}
        Run Keyword If    "${ret}"=="${False}"    append to list    ${alarm_message_list}
        ...    ${faultId}: ${faultDescription}:${faultSeverity}
        Run Keyword If    "${ret}"=="${False}"    append to list    ${fault_id_list}
        ...    ${faultId}
    END
    ${alarm_message}=    Catenate    SEPARATOR=${\n}    @{alarm_message_list}
    Log    ${alarm_message}    WARN
    Set Suite Variable    ${ALARM_MESSAGE}    ${alarm_message}
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
    [Return]    ${fault_id_list}

Modify UTE Memory Size
    [Documentation]    This keyword is to start AirPhone load 4.0.10852, The Sack Timeout In The WTS VM And AP ASIK Must Be
    ...    configured before cell setup.This Aims To Prevent Delayed Messaging Between AirPhone
    ...    and WTS (e.g. CTRL_ADD_UE_NR for attach procedure).
    Log To Console    Modify UTE Memory Size...
    OperatingSystem.Run    sudo sysctl -w net.core.wmem_max=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.wmem_default=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.rmem_max=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.rmem_default=20971520

Print Testline Info Ahead Of Report
    Set Suite Metadata    GNB FCT Type    ${FCT_BOARD_TYPE}
    Set Suite Metadata    GNB ASPs Type    ${ASP_BOARDS_TYPE}
    Set Suite Metadata    AP FCT Type    ${AP_FCT_BOARD_TYPE}
    Set Suite Metadata    AP ASPs Type    ${AP_ASP_BOARDS_TYPE}
    Set Suite Metadata    RRU Type    ${RRU_TYPE}
    Set Suite Metadata    RRU Type List    ${RRU_TYPE_LIST}
    Set Suite Metadata    WTS Version    ${WTS_VERSION}
    Set Suite Metadata    Software Version Total    ${SW_VERSION_TOTAL}
    Set Suite Metadata    Software Version    ${SW_VERSION}

Filter ERR WRN Message From Syslog By Log Path
    [Arguments]    ${log_path}    ${filter_message_file}    ${output_file_path}
    [Documentation]    This keyword is used to filter error and warnning message from syslog path.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_path} | Yes | absolute log path, for example: ${SUITE_LOG_DIRECTORY} |
    ...    | ${filter_message_file} | Yes | txt file which contains filterred message |
    ...    | ${output_file} | Yes | txt file which contains output message |
    ...    Examples:
    ...    | Filter ERR WRN Message From Syslog By Log Path | ${SUITE_LOG_DIRECTORY}    ${CURDIR}/filter_msg.txt    ${CURDIR}/output_log.txt |
    OperatingSystem.Run And Return Rc And Output    rm -f ${output_file_path}
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    find ${log_path} -maxdepth 1 -name Gnb_syslog.tar.gz
    Set Suite Variable    ${FILTER_SYSLOG_STATUS}    ${FALSE}
    Run Keyword If    """${output}"""!=""    Unzip And Filter Gnb_syslog    ${output}    ${filter_message_file}    ${output_file_path}

Unzip And Filter Gnb_syslog
    [Arguments]    ${output}    ${filter_message_file}    ${output_file_path}
    ${files_list}=    String.Split To Lines    ${output}
    OperatingSystem.Run    rm -rf Gnb_syslog_*
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    tar -xzvf ${files_list}[0]
    Log    ${output}
    ${files_list_1}=    String.Split To Lines    ${output}
    Run Keyword If    """${output}"""!=""    Filter ERR WRN Message From Syslog    Gnb_syslog_*
    ...    ${filter_message_file}    ${output_file_path}
    ${status}=    Run Keyword And Return Status    File Should Not Be Empty    ${output_file_path}
    Set Suite Variable    ${FILTER_SYSLOG_STATUS}    ${status}

Filter ERR WRN Message From Syslog
    [Arguments]    ${log_file}    ${filter_message_file}    ${output_file}
    [Documentation]    This keyword is used to filter error and warnning message from one file.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_file} | Yes | log file which needs to be filterred. |
    ...    | ${filter_message_file} | Yes | txt file which contains filterred message |
    ...    | ${output_file} | Yes | txt file which contains output message |
    ...    Examples:
    ...    | Filter ERR WRN Message From Syslog By One File | ${CURDIR}/syslog.txt    ${CURDIR}/filter_log.txt    ${CURDIR}/output_log.txt |
    OperatingSystem.File Should Exist    ${filter_message_file}
    ${content}=    Get File    ${filter_message_file}
    ${content_list}=    String.Split To Lines    ${content}
    FOR    ${filter_item}    IN    @{content_list}
         OperatingSystem.Run And Return Rc And Output    egrep "${filter_item}" ${log_file}>>${output_file}
    END

Auto_Analyze_Error
    [Arguments]    ${filter_syslog}
    #Run Keyword And Ignore Error    Auto_Analyze_Check_Gnb_Container
    #Run Keyword If    "${status}"=="${TRUE}"    Check Syslog All Crash Error    ${filter_syslog}
    Run    cat ${filter_syslog}

