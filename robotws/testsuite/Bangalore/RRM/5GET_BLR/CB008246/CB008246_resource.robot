*** Settings ***
Documentation    :copyright: Nokia
...              :authors: xxx
...              :contact: xxx
Variables    ta5g_global_var

Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Library        ../resources/NPS/SWENG/python_libs/luashark_tools.py
Resource       ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../resources/robot/Setup_Env.robot
Resource       ../resources/robot/common_log_collection.robot
Resource        ../resources/ECEcommon/common_file_operation.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/TTI_Traces.robot
Library        luashark_tools.analyzer       WITH NAME       analyzer
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAME    csn
Library           XML    use_lxml=True    WITH NAME    Myxml
Library         ./python/CB008941_utility.py
Library         ./python/verify_rnti_bwpid.py
#Library         ./python/tti_utility.py
Library         ./python/CB008246_validation.py
Library          ../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ./python/CB008246_Verification.py
Library          DateTime

*** Variables ***
#${enhancedSkipUplink_pattern}    enhancedSkipUplinkTxConfigured*
${RD_PARAM}          0x5901C9=1;0x600012=1;0x5901CA=0;0x190297=1;
${RD_PARAM_DIS}      0x5901C9=0;0x600012=0;0x5901CA=0;0x190297=0;
${UE_attach_pattern}    reported successful RA
${Bearer_ID2}          3
${delta_set_collecting_counters_to_five_minutes}=
    ...    /home/ute/Auto5G/testsuite/RRM/5G_SW_WRO/resources/config/5G21B/delta_set_collecting_counters_to_five_minutes.json
@{FIELDS_CellSetupReq}     cellBwpList_item_0     cellBwpList_item_1
${BIP_SCRIPT_PATH}      ${CURDIR}/../resources/NPS/SWENG/config/script
${WEBEM_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${nsa_nr_cap_band66}       SEPARATOR=
...                        E1201000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C200141F107586368E9
...                        315047F2CA4D940E0416C9824060C78C7FE618F28581C0E1E026AA9C06AA9C0002106020F2687C03904000002904000
...                        00A90400001292500001A601F066F2A6F036B7580282000012CA4A080000CB29282000052CA4A080001CB2928200009
...                        2CA4A480002A9652501741B2E9565D03C9A55934AB22BB902401E0068040200000020

${nsa_nr_mrdc_band66}       A10181102C0C03882000000888160641C460000024400401C041200210000804040080108000802020040080

${sa_nr_cap_band66}         SEPARATOR=
...                         E1A01000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A63000A0F883AC31
...                         B47498A823F96524CA01105B260901831E31FF9863CA16070387809BFF701BFF7000400E20800000001010793
...                         43E00482000001001C19A0002000012CA4800683450107801A010080000000000200400840

${sa_nr_cap_FDD_intergnbHO}        SEPARATOR=
...                         F5A01000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A63000A0F883AC31B4
...                         7498A823F96524CA01105B260901831E31FF9863CA16070387809BFF701BFF7000400E208000000010107FD5555
...                         40B00C000E0343E80407810F0380F000E0700000000001C0801C00B0003F0500783E00482000001001C19A000200001
...                         2CA4800683450107801A01008000000000020040084

*** Keywords ***
Modify IPHY File And Send to Airphone Custom
    [Arguments]    ${iphy_path}    ${frag}=${-1}
    ${RRU_type_list}    Get RRU Type From Local IPHY XML Custom   ${iphy_path}    ${frag}
    FOR    ${RRU_type}    IN    @{RRU_type_list}
    ${RRU_Version}    Get RRU Version From TargetBD File Custom    ${RRU_type}    ${OUTPUT_DIR}
    Modify RRU Version Of IPHY XML Custom    ${iphy_path}    ${RRU_type[0]}    ${RRU_Version}
    Send IPHY XML To Airphone custom    ${iphy_path}
    END
#
Get RRU Type From Local IPHY XML Custom
    [Arguments]    ${iphy_path}    ${frag}=${-1}
    ${content}=    OperatingSystem.Get File    path=${iphy_path}
    ${x}  Set Variable      <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>\\n\\s+(?=<\\/RE>)
    ${f1}   Set Variable
    ...     <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>\\n\\s+(?=<fragmentationCapabilities>)
    ${x}    set variable if    ${frag}==${1}     ${f1}     ${x}
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
    ...    "${RRU_type[0]}"=="AEQE"    ${RRU_type[0]}_E1
    ...    "${RRU_type[0]}"=="AHLOA"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AHEH"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEHC"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEUD"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AWEUA"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AHFII"    ${RRU_type[0]}
    ...    "${RRU_type[1]}"=="ecpri"    ${RRU_type[0]}_E1
    ...    ${RRU_type[0]}
    OperatingSystem.Run
    ...    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/TargetBD*.xml ${save_dir}/TargetBD.xml
    OperatingSystem.Should Exist    ${save_dir}/TargetBD.xml
    ${content}=    OperatingSystem.Get File    path=${save_dir}/TargetBD.xml
    ${check_point_regexp}    Set Variable    resourceBuildKey="LTX_${RRU_type}".*resourceSWVersion="(?P<RRU_Version>.*)"
    @{RRU_Version}    String.Get Regexp Matches    ${content}    ${check_point_regexp}    RRU_Version
    [Return]    ${RRU_Version}[0]
#
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

Change IPHY File Value
    [Arguments]    ${RU_TYPE}   ${GSCN}
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "card"|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|
    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
    Run    ${c1}${c2}

    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "GSCN"|awk -F'>' '{print $2 }'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Run    ${c1}${c2}
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  120s

Change IPHY File Value AP ABIO for FDD
    [Arguments]    ${RU_TYPE}   ${GSCN}
	builtin.Log    ${RU_TYPE}
#    ${OUTPUT_DIR}   Set variable    /home/ute/robotws
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}

    ${targetbd_fn}=    Run      ssh toor4nsn@192.168.255.129 ls -ltr /ffs/run/|grep TargetBD.*xml$|awk '{ print $9 }'
    Run     scp toor4nsn@192.168.255.129:/ffs/run/${targetbd_fn} ${OUTPUT_DIR}
    Should Exist    ${OUTPUT_DIR}/${targetbd_fn}
    ${target_bd_path}    Set Variable    ${OUTPUT_DIR}/${targetbd_fn}

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

    ${c1}    Set Variable    cat ${file_path}|grep -m 3 "GSCN"| tail -1 | awk -F'>' '{print $2 }'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Run    ${c1}${c2}

    ${c1}    Set Variable    cat ${file_path}|grep -m 4 "GSCN"| tail -1 | awk -F'>' '{print $2 }'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Run    ${c1}${c2}

    ${x}   ${y}    get_board_type    192.168.200.1   22    toor4nsn    oZPS0POrRieRtu
    Run Keyword if    '${x}'=='ASIL' and '${y}'=='ABIO'
    ...    update_iphy_7145    ${file_path}
    sleep   4s
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  125s


Start And Stop Tti Trace Streaming after BWP switch
    [Arguments]         ${path}
    Start Ttitrace With Streaming Mode_2
    Sleep    3s    reason=get *L2TtiTrace_EventsSnapshot
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv        ${path}

Convert Tti To CSV Mode
    [Arguments]         ${path}
    Format Tti In Stream Mode         ${path}/output_dl.csv     ${path}/output_dl_formated.csv
    Format Tti In Stream Mode         ${path}/output_ul.csv     ${path}/output_ul_formated.csv

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
    [Arguments]   ${csv_file_path}   ${rnti}   ${bwp}
    ${rntibwp}   Create Rntibwp Dictionary   ${rnti}   ${bwp}
    ${Result}  verify_rnti_bwpid.check_rnti_bwpid    ${csv_file_path}   ${rntibwp}
    [Return]   ${Result}

Validate UE bwpid from TTI traces
    [Arguments]   ${csv_file_path}   ${rnti}   ${bwp}
    ${Check}  Verify Rnti ueBWPid    ${csv_file_path}/output_dl_formated.csv      ${rnti}   ${bwp}
    run keyword and continue on failure   Run Keyword if   ${Check}!=${True}   Fail   Bwpid is not matching
    ${Check1}  Verify Rnti ueBWPid    ${csv_file_path}/output_ul_formated.csv     ${rnti}   ${bwp}
    run keyword and continue on failure   Run Keyword if   ${Check1}!=${True}   Fail   Bwpid is not matching

Capture TTI Traces and Validate UE bwpid
     [Arguments]   ${LOG_PATH}   ${filename}    ${rnti}   ${bwp}
     Start And Stop Tti Trace Streaming after BWP switch   ${LOG_PATH}/ttitrace_streaming/${filename}
     Convert Tti To CSV Mode     ${LOG_PATH}/ttitrace_streaming/${filename}
     Validate UE bwpid from TTI traces    ${LOG_PATH}/ttitrace_streaming/${filename}     ${rnti}   ${bwp}

Capture TTI Traces and Convert to CSV Mode
     [Arguments]   ${LOG_PATH}   ${filename}
     Start And Stop Tti Trace Streaming after BWP switch   ${LOG_PATH}/ttitrace_streaming/${filename}
     Convert Tti To CSV Mode     ${LOG_PATH}/ttitrace_streaming/${filename}

Check gNB Bulid
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${GNB_SW_VERSION}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    Set Suite Variable    ${GNB_SW_VERSION}
    ${Branch_22R1}    Run Keyword and Return Status   Should Contain    ${GNB_SW_VERSION}     22R1
    Set Suite variable   ${Branch_22R1}

Send Swconfig File To GNB
    [Arguments]    ${path}
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p oZPS0POrRieRtu scp ${path} toor4nsn@192.168.255.1:/ffs/run/swconfig.txt
    Should Be Equal As Integers    ${rc}    0

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

Configure UTE ETH3 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3

Configure in VM for RANK-4
    [Documentation]    This keyword is to configure RANK-4 in VM
    Log To Console    configure VM for RANK-4..
    OperatingSystem.Run    sudo sysctl -w net.core.wmem_max=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.wmem_default=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.rmem_max=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.rmem_default=20971520

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
    ${cprt_log_1}     Stop Log  cprt  test_scenario=cellsetup
    set suite variable    ${cprt_log_1}
    ${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup_sys
    set suite variable    ${cell_sys_log}

Load CFG Config And Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    CB008246_resource.Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    Check gNB Airscale is Ready - ${BBoard_Type}
    Log To console     loading cfg file
    Start Log   btslog    cprt    bip
    CB008246_resource.Check Cell On Air      ${wts_cfg_file}
    ${log_path_1}     Stop Log    cprt    bip    btslog  test_scenario=cellsetup
    log to console      cprt-${log_path_1}
    set suite variable    ${log_path_1}

Load CFG Config And Capture CPRT Traces_new
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    Check gNB Airscale is Ready - ${BBoard_Type}
    Log To console     loading cfg file
    Check Cell On Air      ${wts_cfg_file}

Load CFG Config
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    #${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap

    Log To console     loading cfg file
    Start Log   btslog    cprt
    Start WTS Using WTS_Runner and collect SIB1 output     ${wts_cfg_file}
    ${cprt_log}     Stop Log  cprt  test_scenario=cellsetup
    set suite variable    ${cprt_log}
    ${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup
    set suite variable    ${cell_sys_log}

Start WTS Using WTS_Runner and collect SIB1 output
    [Arguments]             ${wts_cfg_file}
    Stop Edaemon and Egate process
    Stop Sim_enb
    run    command=sudo rm -rf ${WTS_DIR}/*.log.*
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    wtsrunner.configure                      file=${wts_cfg_file}
    ${sib1_output}      wtsrunner.read_wtsemu_output_until_re    expected=cell 1: SystemInformationBlockType1-NR updated     timeout=400
    Set Suite Variable     ${sib1_output}
    sleep    60s
    Create File      /home/ute/sib_output.txt       ${sib1_output}
    Log to Console    Cell onair successful
    [Return]    ${sib1_output}

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

MultiUE Attach for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Target_Cell}     ${chk_fail}=${-1}
    ${nsa_rnti_list}      Create List
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    LTE Attach should be Successful    ${ue_id}
    ${nsa_rnti}    NSA UE Attach    ${UE_ID}    ${Target_Cell}    chk_fail=${chk_fail}
    Append To List  ${nsa_rnti_list}   ${nsa_rnti}
    BuiltIn.Log     ${nsa_rnti_list}
    END
    [Return]    ${nsa_rnti_list}

MultiUE Register should be Successful fixed
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pattern}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
    Read WTS Output For Pattern And Print matching Lines    ${pattern}    ${Timeout_SA}
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}

MultiUE Attach of two bearers for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${chk_fail}=${-1}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    LTE Attach should be Successful    ${ue_id}
    NSA UE Attach for 2 bearers    ${UE_ID}    chk_fail=${chk_fail}
    END

MultiUE DL Traffic Start for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${dl_rate}    ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
	builtin.Log    ${id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    Trigger DL Traffic for NSA    ${ue_id}    ${Traffic_rate}    ${dl_rate}    id=${Bearer_ID}    trf_id=${TRF_ID}
    END

MultiUE UL Traffic Start for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${ul_rate}    ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
	builtin.Log    ${id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    Trigger UL Traffic for NSA    ${ue_id}    ${Traffic_rate}    ${ul_rate}    id=${Bearer_ID}    trf_id=${TRF_ID}
    END

MultiUE Validate UL Traffic For NSA
    [Arguments]    ${st_ue_id}    ${en_ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
    FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
    Validate UL Traffic For NSA    ${ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
    END

MultiUE Validate DL Traffic For NSA
    [Arguments]    ${st_ue_id}    ${en_ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
    FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
    Validate DL Traffic For NSA    ${ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
    END

MultiUE DL Traffic Stop for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Bearer_ID}    ${trf_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    TRF Data Stop for NSA    ${ue_id}    ${Bearer_ID}    dl    ${trf_id}
    END

MultiUE UL Traffic Stop for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Bearer_ID}    ${trf_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    TRF Data Stop for NSA    ${ue_id}    ${Bearer_ID}    ul    ${trf_id}
    END

MultiUE Detach for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    UE Detach should be Successful    ${ue_id}
    END

NSA UE Attach  #NSA
    [Arguments]    ${UE_ID}    ${Target_Cell}     ${chk_fail}=${-1}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Target_Cell}    ue=${UE_ID}
    ...                         bearer=${Bearer_ID}    type=split_scg
#    ${fail_pt}    Set Variable    UE${UE_ID}: No band combinations in MR-DC capabilities*
    ${fail_pt}    Set Variable    value Cause : radioNetwork : tDCprep-expiry
    ${pattern}    Set Variable If    ${chk_fail}!=${-1}    ${fail_pt}    ${UE_attach_pattern}
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${pattern}    ${Timeout_NSA}
    Create File	    ${OUTPUT_DIR}/nsa.txt	    ${output}
    sleep    1s
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/nsa.txt |grep -i newUE-Identity |awk '{print $2}'|cut -d ',' -f 1
    [Return]      ${crnti_string}

NSA UE Attach for 2 bearers
    [Arguments]    ${UE_ID}    ${chk_fail}=${-1}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Target_Cells}    ue=${UE_ID}
    ...                         bearer=${Bearer_ID},${Bearer_ID2}    type=split_scg
#    ${fail_pt}    Set Variable    UE${UE_ID}: No band combinations in MR-DC capabilities*
    ${fail_pt}    Set Variable    value Cause : radioNetwork : tDCprep-expiry
    ${pattern}    Set Variable If    ${chk_fail}!=${-1}    ${fail_pt}    ${UE_attach_pattern}
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${pattern}    ${Timeout_NSA}
    [Return]      ${output}

Sgnb Modification
    [Arguments]    ${UE_ID}    ${chk_fail}=${-1}
	builtin.Log    ${chk_fail}
    [Documentation]    This keyword is used to add different QCI other than the one added as a default.
    wtsrunner.bearer_add    ue=${UE_ID}  id=3  filter=0  precedence=0
    wtsrunner.enb_ue_dc_modify   ue=${UE_ID}  bearer_to_add=3  by=enb  cause=RN_CauseRadioNetwork_unspecified
    ...                          type=split_scg

Sgnb Modification_Bearer id 2 released_Bearer id 3 added
    [Arguments]    ${UE_ID}    ${chk_fail}=${-1}
	builtin.Log    ${chk_fail}
    [Documentation]    This keyword is used to add different QCI other than the one added as a default.
    wtsrunner.bearer_add    ue=${UE_ID}  id=3  filter=0  precedence=0
    sleep     1s
    wtsrunner.enb_ue_dc_modify   ue=${UE_ID}  bearer_to_add=3  by=enb  cause=RN_CauseRadioNetwork_unspecified
    ...                          type=split_scg
    sleep     1s
    wtsrunner.enb_ue_dc_modify   ue=${UE_ID}  bearer_to_release=2  by=enb  cause=RN_CauseRadioNetwork_unspecified
    ...                          type=split_scg

Sgnb Modification_Bearer id 3 released
    [Arguments]    ${UE_ID}    ${chk_fail}=${-1}
	builtin.Log    ${chk_fail}
    [Documentation]    This keyword is used to add different QCI other than the one added as a default.
    wtsrunner.bearer_add    ue=${UE_ID}  id=3  filter=0  precedence=0
    wtsrunner.enb_ue_dc_modify   ue=${UE_ID}   bearer_to_release=3  by=enb  cause=RN_CauseRadioNetwork_unspecified
    ...                          type=split_scg


Change IPHY File Value AP ABIO
    [Arguments]    ${RU_TYPE}   ${GSCN}
#    ${OUTPUT_DIR}   Set variable    /home/ute/robotws
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}

    ${targetbd_fn}=    Run      ssh toor4nsn@192.168.255.129 ls -ltr /ffs/run/|grep TargetBD.*xml$|awk '{ print $9 }'
    Run     scp toor4nsn@192.168.255.129:/ffs/run/${targetbd_fn} ${OUTPUT_DIR}
    Should Exist    ${OUTPUT_DIR}/${targetbd_fn}
    ${target_bd_path}    Set Variable    ${OUTPUT_DIR}/${targetbd_fn}

    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "card"|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|
    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
    Run    ${c1}${c2}

    ${c1}    Set Variable    grep -m 1 ${RU_TYPE}|awk -F resourceSWVersion= '{print $2}'|sed 's/"//g;s/>//g'
    ${new_version}    Run   cat ${target_bd_path}|${c1}
    log to console     ${new_version}
    ${c1}    Set Variable    cat ${file_path}|grep -m 1 '<version>'|awk -F '<version>' '{print $2}'|awk -F '</version>' '{print $1}'|
    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${new_version}/' ${file_path}
    Run     ${c1}${c2}

    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "GSCN"|awk -F'>' '{print $2 }'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Run    ${c1}${c2}

    ${x}   ${y}    get_board_type    192.168.200.1   22    toor4nsn    oZPS0POrRieRtu
    Run Keyword if    '${x}'=='ASIL' and '${y}'=='ABIO'
    ...    update_iphy_7145    ${file_path}
    sleep   4s
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  125s

Change CFG File Value
    [Arguments]    ${file_path}    ${ul_arfcn}   ${dl_arfcn}    ${sa_cap}   ${nsa_nr_cap}   ${nsa_mrdc_cap}
    ${x}    Set Variable    nr_arfcn
    ${y}    Set Variable    nr_arfcn=
    ${z}    Catenate    SEPARATOR=:   ${ul_arfcn}   ${dl_arfcn}
    ${nsa_pat}  Set Variable       ue_eutra_nr_capabilities
    ${sa_pat}   Set Variable       ue_nr_capabilities


    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${x}"|awk -F'${y}' '{print $2 }'|
    ${c2}   Set Variable    awk -F ' ' '{print $1}'|xargs -I {} sed -i 's/{}/${z}/g' ${file_path}
    Run    ${c1}${c2}

    #Below is for SA cap changes
    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${sa_pat}"|awk -F'${sa_pat}=' '{print $2}'|
    ${c2}   Set Variable    xargs -I {} sed -i 's/{}/${sa_cap}/g' ${file_path}
    Run    ${c1}${c2}
    #Below is for NSA cap changes
    #NSA_UE_NR cap changes
    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${nsa_pat}"|awk -F'${SPACE}${SPACE}dual_conn=eutra_nr' '
    ${c2}   Set Variable    {print $1}'|awk -F'${sa_pat}=' '{print $2}'|
    ${c3}   Set Variable    xargs -I {} sed -i 's/{}/${nsa_nr_cap}/g' ${file_path}
    Run    ${c1}${c2}${c3}
    #NSA DC cap changes
    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${nsa_pat}"|awk -F'${nsa_pat}=' '{print $2}'|
    ${c2}   Set Variable    xargs -I {} sed -i 's/{}/${nsa_mrdc_cap}/g' ${file_path}
    Run     ${c1}${c2}

Change dl_ul arfcn in CFG File
    [Arguments]    ${file_path}    ${ul_arfcn}   ${dl_arfcn}
    ${x}    Set Variable    nr_arfcn
    ${y}    Set Variable    nr_arfcn=
    ${z}    Catenate    SEPARATOR=:   ${ul_arfcn}   ${dl_arfcn}
    ${nsa_pat}  Set Variable       ue_eutra_nr_capabilities
    ${sa_pat}   Set Variable       ue_nr_capabilities


    ${c1}   Set Variable    cat ${file_path}|grep -m 1 "${x}"|awk -F'${y}' '{print $2 }'|
    ${c2}   Set Variable    awk -F ' ' '{print $1}'|xargs -I {} sed -i 's/{}/${z}/g' ${file_path}
    Run    ${c1}${c2}

Read Cellsetup msg
#    ${bts_log}      Set Variable  ${log_path_1}[btslog]/gnb_syslog.log
    ${cprt_log}      Set Variable  ${cprt_log_1}[cprt]/NODECPRT_GNB.pcap
    ${pdmlFile}    analyzer.pcap_to_pdml    ${cprt_log}         itf_l2_ps_cell_cellsetupreq
    ${CellSetupParam}    Create Dictionary    dllaDeltaCqiStepdownHR=20     dllaDeltaCqiMaxHR=150
    ${moc_list}=    Get Dictionary Keys    ${CellSetupParam}
    FOR    ${item}   IN    @{moc_list}
    ${var}      analyzer.get_shownames         pdmlFile=${pdmlFile}
    ...                                        packetName=itf_l2_ps_cell_cellsetupreq
    ...                                        kind=show
    ...                                        path=.*${item}$
    ...                                        endPacket=1
    ${var}      convert to integer     ${var[${-1}]}
    log to console    ${item}-${var}
    Set To Dictionary   ${CellSetupParam}    ${item}=${var}
    END
#    ${value} 	Get From Dictionary	${CellSetupParam}	numPdschPrbInSsbSlots
#    ${usable_prb_on_ssb}    Run Keyword if    ${value}!=${0}
#    ...    Run  cat ${bts_log} |grep -i -m 1 "Usable PRB count:"|awk -F 'Usable PRB count:' '{print $2}'| cut -d "," -f1
#    log to console      usable_prb_on_ssb-${usable_prb_on_ssb}
#    ${usable_prb_on_ssb}   Set Variable if     ${value}!=${0}    ${usable_prb_on_ssb}    ${numPdschPrbInSsbSlots}
#    ${usable_prb_on_ssb}      convert to integer     ${usable_prb_on_ssb}
#    Set To Dictionary	${CellSetupParam}	usable_prb_on_ssb=${usable_prb_on_ssb}
#    log to console     CellSetupParam-${CellSetupParam}
#    set suite variable    ${CellSetupParam}

Check Cell On Air
    [Arguments]             ${wts_cfg_file}
    Stop Edaemon and Egate process
    Stop Sim_enb
    run    command=sudo rm -rf ${WTS_DIR}/*.log.*
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    wtsrunner.configure                   file=${wts_cfg_file}
#    wtsrunner.read_wtsemu_output_until_re    expected=Airphone: Cell Setup completed     timeout=240
    wtsrunner.read_wtsemu_output_until_re    expected=UEC-1: eNB 2 cell 1: SystemInformationBlockType4-NR updated     timeout=240
Convert PCAP to CSV

    [Arguments]    ${PcapFile}    ${filters}    ${event}    @{headers}
    @{files}      List Files In Directory	   ${PcapFile}/L1L2_bipmon/
    ${JsonPath}    ConvertPcapToJson    ${PcapFile}/L1L2_bipmon/@{files}[0]    ${filters}
    ${csv_file_path}    get_values    ${JsonPath}  ${event}    @{headers}
    [Return]    ${csv_file_path}

Verify CB008509 Parameters
    [Arguments]    ${log_path}   ${packet}    ${actConfDlInterferenceGen}    ${targetTotalLoadSectorBeam}    ${mcsIndexForArtificialLoad}
    ${pdmlFile}    analyzer.pcap_to_pdml    ${log_path}/NODECPRT_GNB.pcap         ${packet}
    ${dummy}    Create Dictionary    actConfDlInterferenceGen=${actConfDlInterferenceGen}
    ...                              targetTotalLoadSectorBeam_item=${targetTotalLoadSectorBeam}
    ...                              mcsIndex=${mcsIndexForArtificialLoad}
    FOR    ${item}   IN    @{dummy}
    ${var}      analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                        packetName=${packet}
    ...                                        path=.*${item}$
    ...                                        endPacket=1
    Should BE Equal    ${var}    ${dummy}[${item}]
    END

Modify_online NIDD param under NRPDCCHHRLA-1 NRPDSCHHRLA-1 NRPUCCHHRLA-1
    Modification_online_PDCCHHRBLER      MRBTS-1/NRBTS-1/NRPDCCHHRLA-1       update
    Modification_online_PDSCHHRBLER      MRBTS-1/NRBTS-1/NRPDSCHHRLA-1       update
    Modification_online_PUSCHHRBLER      MRBTS-1/NRBTS-1/NRPUSCHHRLA-1       update

Modification_online_PDCCHHRBLER
    [Documentation]     This Keyword modify NRPDCCHHRLA NIDD parameter as per the requirement of the feature CB008246
    [Arguments]        ${paramDstName}=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1          ${operation}=update
    ${nidd_param}=      Create Dictionary      pdcchHRBlerOutagePercentage=20
    ...                                        pdcchHRBlerRecoverPercentage=20
    FOR    ${key}   IN    @{nidd_param}
    Modify NIDD parameters        ${paramDstName}       ${operation}     ${key}      ${nidd_param.${key}}
    END

Modification_online_PDSCHHRBLER
    [Documentation]     This Keyword modify NRPDSCHHRLA NIDD parameter as per the requirement of the feature CB008246
    [Arguments]        ${paramDstName}=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1          ${operation}=update
    ${nidd_param}=      Create Dictionary      dlHRBlerOutagePercentage=90
    ...                                        dlHRBlerRecoverPercentage=90
    FOR    ${key}   IN    @{nidd_param}
    Modify NIDD parameters        ${paramDstName}       ${operation}     ${key}      ${nidd_param.${key}}
    END

Modification_online_PUSCHHRBLER
    [Documentation]     This Keyword modify NRPUSCHHRLA NIDD parameter as per the requirement of the feature CB008246
    [Arguments]        ${paramDstName}=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1          ${operation}=update
    ${nidd_param}=      Create Dictionary      ulHRBlerOutagePercentage=90
    ...                                        ulHRBlerRecoverPercentage=90
    FOR    ${key}   IN    @{nidd_param}
    Modify NIDD parameters        ${paramDstName}       ${operation}     ${key}      ${nidd_param.${key}}
    END

Online NIDD parameter change
     [Documentation]    This Keyword used to update NIDD parameter(one at a time)
     ...                and returns the result
     ...        [Arguments]    parameter        :  Parameter names to parsed
     ...                       paramDst         :  Dist name should be parsed
     ...                       paramValue       :  Value for the parameter to be assigned should be parsed
     ...                       operation        :  Deffault Value given as update, and can be parsed other operation if required
     ...                       should_activate  :  Deffault Value is True if you want to set this False then parse the parameter as False
     ...                       skip_parameter_relation_errors : Default Value is True if you want to set this False then parse the parameter as False
     [Arguments]        ${paramName}='None'                 ${paramValue}='None'              ${timeout}=300
     ...                ${paramDst}='None'                  ${operation}=update
     ...                ${should_activate}=${True}          ${skip_parameter_relation_errors}=${True}
	builtin.Log    ${timeout}
    admin.perform_parameter_recommissioning          parameter=${paramName}
     ...        value=${paramValue}             operation=${operation}                         dist_name=${paramDst}
     ...        skip_parameter_relation_errors=${skip_parameter_relation_errors}
     ...        should_activate=${should_activate}

Modify NIDD parameters
    [Documentation]     This Keyword modify NIDD parameter as per the requirement of the feature CB008246
    [Arguments]        ${paramDst}='None'                  ${operation}=update
     ...                ${paramName}='None'                 ${paramValue}='None'
    Log to Console      Modifying NIDD parameters
    admin.Setup admin
    Online NIDD parameter change    paramDst=${paramDst}        operation=${operation}
    ...          paramName=${paramName}         paramValue=${paramValue}
    sleep               60s
    [Teardown]          admin.Teardown admin

Simulate cqi
    [Documentation]    This keyword simulate csi_override testmode command
    [Arguments]    ${cqi}       ${start_ue_id}    ${end_ue_id}
    Introduce csi_override_cqi      ${cqi}
    Activate csi_override_for_UE        ${start_ue_id}    ${end_ue_id}

Introduce csi_override_cqi
    [Documentation]    This keyword introduces csi_override testmode command
    [Arguments]    ${cqi}
    wtsrunner.csi_override_testmode_nr    profile_id=2    cqi=${cqi}     cqi_mode=fixed
    wtsrunner.csi_override_testmode_nr      profile_id=2
    sleep    5s

Simulate bler_testmode
    [Documentation]    This keyword simulate csi_override testmode command
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    Introduce bler_testmode
    Activate bler_testmode_for_UE        ${start_ue_id}    ${end_ue_id}

Introduce bler_testmode
    [Documentation]    This keyword introduces bler testmode command
    wtsrunner.bler_testmode_nr      profile_id=4        target_mcs=2        target_bler=100,100,100,95,90,50,10,1,0.5,0.1,0,0,0,0,0
    ...     mcs_table=qam64LowSE        rank=0
    wtsrunner.bler_testmode_nr      profile_id=4
    sleep    5s

Introduce pathloss
    [Arguments]    ${start_ue_id}    ${end_ue_id}	${loss}=75
    FOR  ${ue_idx}   IN RANGE   ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ul_sinr_testmode_nr    profile_id=3    pathloss=${loss}
    END

Activate pathloss_for_UE
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR  ${ue_idx}   IN RANGE   ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr        id=${ue_idx}     testmode=ul_sinr        profile_id=3        action=activate
    END

Vary pathloss
    [Arguments]    ${pathloss_start_dB}=75    ${pathloss_end_dB}=130    ${pathloss_step_dB}=1
    FOR    ${pathloss}    IN RANGE    ${pathloss_start_dB}    ${pathloss_end_dB}    ${pathloss_step_dB}
    wtsrunner.ul_sinr_testmode_nr    profile_id=3    pathloss=${pathloss}
    END

Deactivate pathloss_for_UE
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR  ${ue_idx}   IN RANGE   ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr        id=${ue_idx}     testmode=ul_sinr        profile_id=3        action=deactivate
    END

Activate bler_testmode_for_UE
    [Documentation]    This keyword activate bler testmode for n UEs
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr        id=${ue_idx}        scell=primary       testmode=bler       profile_id=4        action=activate
    END

Deactivate bler_testmode_for_UE
    [Documentation]    This keyword deactivate bler testmode for n UEs
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr        id=${ue_idx}        scell=primary       testmode=bler       profile_id=4        action=deactivate
    END

Activate csi_override_for_UE
    [Documentation]    This keyword activate csi_override testmode for n UEs
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr        id=${ue_idx}        scell=0       testmode=csi_override       profile_id=2        action=activate
    END

Validate PM Counters_pcell_scell
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value equal or bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}

Validate PM Counters_pcell_scell_UPD
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    Get Total value of counter and compare   ${PM_dir}   ${PM_counter}   ${expected_value}

Get Total value of counter and compare
    [Arguments]   ${pm_files_location}     ${pi_id}    ${expected_value}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=PM*
    ${rc}       get_total_cmp      ${PM_report_dict_list}     ${expected_value}
    Should Contain  ${rc}  PASS

Verify Counters PDCCH_Legacy_Counters
    [Arguments]     ${EXPECTED_PCELL_VALUE}
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER8}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER11}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER12}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER14}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER15}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER17}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER18}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER19}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER20}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER21}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER22}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-2

Ng-based InterGnb RealToSIM HO SA A3
    [Arguments]    ${ue_id}=1
    wtsrunner.ue_meas_cfg_disp    id=${ue_id}    meas_obj_type=nr
    wtsrunner.ue_measurement_send_nr       id=${ue_id}  meas_id=1 event=A3   srsrp_nr=10   srsrq_nr=5   ssinr_nr=10
    ...       phycell_id=52   nrsrp_nr=40   nrsrq_nr=40   nsinr_nr=50
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}

Ng-based InterGnb SIMToReal HO SA A3
    [Arguments]    ${ue_id}=1
    wtsrunner.ue_history_information_list_add_ngran     id=${ue_id}     gnb_id=3    cell_type=large    nrcgi=311:489|0x03  time_ue_stayed_in_cell=100
    wtsrunner.ue_history_information_list   id=${ue_id}  action=commit
    wtsrunner.ue_enb_param     id=${ue_id}  ue_history_list=1
    wtsrunner.upf_param   id=${ue_id}  end_markers_delay=10s
    wtsrunner.ue_meas_cfg_disp    id=${ue_id}    meas_obj_type=nr
    wtsrunner.ue_measurement_send_nr       id=${ue_id}  meas_id=1  event=A3  srsrp_nr=19  phycell_id=52  nrsrp_nr=100
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}


Unsuccessful Ng-based InterGnb SIMToReal HO SA A3
    [Arguments]    ${ue_id}=1
    wtsrunner.ue_history_information_list_add_ngran     id=${ue_id}     gnb_id=3    cell_type=large    nrcgi=311:489|0x03  time_ue_stayed_in_cell=100
    wtsrunner.ue_history_information_list   id=${ue_id}  action=commit
    wtsrunner.ue_enb_param     id=${ue_id}  ue_history_list=1
    wtsrunner.upf_param   id=${ue_id}  end_markers_delay=10s
    wtsrunner.ue_meas_cfg_disp    id=${ue_id}    meas_obj_type=nr
    wtsrunner.ue_measurement_send_nr       id=${ue_id}  meas_id=4  event=A2  srsrp_nr=19  phycell_id=52  nrsrp_nr=100
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=RAN radio resources not available   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    RAN radio resources not available   partial_match=${TRUE}
    Log to Console    ${output}


trigger handover to LTE
    [Documentation]    [PRIVATE]    trigger handover to LTE
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1    ${A2_meas_id}=1   ${B2_meas_id}=2
	builtin.Log    ${ue_id}
	builtin.Log    ${A2_meas_id}
	builtin.Log    ${B2_meas_id}

    wtsrunner.ue_measurement_send_nr  id=1  meas_id=1  event=A2  srsrp_nr=11  srsrq_nr=11  srs_result=0:11:11:0  phycell_id=50  nrsrp_nr=30
    ...    nrsrq_nr=30  rs_type=ssb  index=0  nrs_result=30:30:0
    wtsrunner.ue_measurement_send_nr  id=1  meas_id=2  event=B2  srsrp_nr=11  srsrq_nr=11  srs_result=0:11:11:0  phycell_id=11
    ...   nrsrp_nr=30  nrsrq_nr=30
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15

trigger handover to 5G
    [Documentation]    [PRIVATE]    trigger handover to 5G
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=${1}    ${negtive}=${-1}
	builtin.Log    ${negtive}
	builtin.Log    ${ue_id}
    wtsrunner.gnb_trigger_inter_rat_handover_to_5g   ue=1  target_gnb=2   target_cell=1   plmn=311:489
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=criticalExtensions rrcReconfigurationComplete   timeout=15

Verify CB008246 Parameters
    [Arguments]    ${log_path}   ${packet}    ${mcsTable}
    ${pdmlFile}    analyzer.pcap_to_pdml      ${log_path}/NODECPRT_GNB.pcap       ${packet}

    ${var}      analyzer.get_shownames            pdmlFile=${pdmlFile}
    ...                                        packetName=${packet}
    ...                                        path=${mcsTable}
#    ...                                        endPacket=1

    Should Contain    ${var[${0}]}     qam64LowSE

#           ...                                        path=${mcsTable}
##    ...                                        endPacket=1
#    log to console     wertt-${var}
#    ${var}    remove duplicates   ${var}
#    log to console     xty-${var}
#    for     ${item}    IN RANGE    ${var}
#    Run keyword if     'qam64LowSE' in ${item}
#    ...    Should Contain    ${var}     qam64LowSE

Verify PDCCH_Counters
    [Arguments]     ${EXPECTED_PCELL_VALUE}
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER1}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER2}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER4}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER5}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER6}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER7}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER8}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER9}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER10}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER11}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER12}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER13}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER14}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER15}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER16}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER17}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER18}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER19}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER20}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER21}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER22}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER23}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1
    Validate PM Counters_pcell_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER24}       expected_value=${EXPECTED_PCELL_VALUE}
    ...     moc=NRCELL-1



verification for CG
    [Arguments]    ${file_name}    ${event}    ${physCellId}    ${arg}
    ${result}    validation    ${file_name}    ${event}    ${physCellId}    ${arg}
    Should Contain    ${result}    pass

verification for 2271
    [Arguments]    ${file_name}    ${event}    ${physCellId}    ${arg}
    ${result}    validation_2271    ${file_name}    ${event}    ${physCellId}    ${arg}
    Should Contain    ${result}    pass

Verify CsRnti
    ${x}    Run    cat ${LOG_PATH}/test_case/gNB/btslog/gnb_syslog.log|grep -i "csRnti:"
    [Return]    ${x}

Trigger MultiUE VoNR DL Traffic with multiple trfids
    [Arguments]    ${start_ue_id}    ${end_ue_id}     ${pdu_id}=1     ${num_trf_id}=1
	...     ${qfi_id}=1   ${rtp_codec}=custom
    [Documentation]    This keyword starts the VoNR DL Traffic for the SA variant having some rtp codec
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning VoNR DL Traffic for ue=${ue_idx} with ${rtp_codec}...
    Start dl traffic with multiple trfids    ${ue_idx}    ${pdu_id}   ${qfi_id}    ${num_trf_id}    ${rtp_codec}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic Receiver*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ue=${ue_idx} ${output} VoNR_DL_traffic_data_is_started_successfully
    BuiltIn.Log       ue=${ue_idx} VoNR_DL_traffic_data_is_started_successfully
	END
	sleep       10s
	BuiltIn.Log       All_ue_started_DL_VoNR_traff_succesfully
	Log to Console    All_ue_started_DL_VoNR_traff_succesfully

Start dl traffic with multiple trfids
    [Arguments]    ${ue_idx}    ${pdu_id}    ${qfi_id}    ${num_trf_id}    ${rtp_codec}
    FOR     ${traffic_id}   IN RANGE    ${1}    ${num_trf_id}+1
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=dl    trf_id=${traffic_id}    rtp_codec=${rtp_codec}
    ...     rtp_ps=900 period_ms=10 rtp_voice_silence=200:1 rtp_send_silence_period=10 rtp_silence_ps=900
    END

Start ul traffic with multiple trfids
    [Arguments]    ${ue_idx}    ${pdu_id}    ${qfi_id}    ${num_trf_id}    ${rtp_codec}
    FOR     ${traffic_id}   IN RANGE    ${1}    ${num_trf_id}+1
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=ul    trf_id=${traffic_id}    rtp_codec=${rtp_codec}
    ...     rtp_ps=900 period_ms=10 rtp_voice_silence=200:1 rtp_send_silence_period=10 rtp_silence_ps=900
    END

Trigger MultiUE VoNR UL Traffic with multiple trfids
    [Arguments]    ${start_ue_id}    ${end_ue_id}     ${pdu_id}=1     ${num_trf_id}=1
	...     ${qfi_id}=1   ${rtp_codec}=custom
    [Documentation]    This keyword starts the VoNR UL Traffic for the SA variant having some rtp codec
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning VoNR UL Traffic for ue=${ue_idx} with ${rtp_codec}...
    Start ul traffic with multiple trfids    ${ue_idx}    ${pdu_id}   ${qfi_id}    ${num_trf_id}    ${rtp_codec}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*      timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ue=${ue_idx} ${output} VoNR_UL_traffic_data_is_started_successfully
    BuiltIn.Log       ue=${ue_idx} VoNR_UL_traffic_data_is_started_successfully
	END
	sleep       10s
	BuiltIn.Log       All_ue_started_UL_VoNR_traff_succesfully
	Log to Console    All_ue_started_UL_VoNR_traff_succesfully

Change GSCN value in IPHY File
    [Arguments]    ${RU_TYPE}   ${GSCN}
	builtin.Log    ${RU_TYPE}
#    ${OUTPUT_DIR}   Set variable    /home/ute/robotws
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}

    ${targetbd_fn}=    Run      ssh toor4nsn@192.168.255.129 ls -ltr /ffs/run/|grep TargetBD_SBTS.*xml$|awk '{ print $9 }'
    Run     scp toor4nsn@192.168.255.129:/ffs/run/${targetbd_fn} ${OUTPUT_DIR}
    Should Exist    ${OUTPUT_DIR}/${targetbd_fn}
    ${target_bd_path}    Set Variable    ${OUTPUT_DIR}/${targetbd_fn}

    ${c1}    Set Variable    cat ${file_path}|grep -m 3 "GSCN"| awk -F'>' '{print $2 }'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Run    ${c1}${c2}

    ${x}   ${y}    get_board_type    192.168.200.1   22    toor4nsn    oZPS0POrRieRtu
    Run Keyword if    '${x}'=='ASIL' and '${y}'=='ABIO'
    ...    update_iphy_7145    ${file_path}
    sleep   4s
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  125s

Common TTI PCAP to CSV Converter
    [Arguments]    ${ttitrace_path}    ${dir}=dl
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
    ${tti_file_size}    Get File Size    ${tti_path}/tcpdump_ttitrace.pcap
    Run Keyword If  ${tti_file_size} <= 60000000
    ...   Decode TTI Trace    ${ttitrace_path}
    ...   ELSE
    ...   Decode TTI Trace For Large File Size    ${ttitrace_path}  ${dir}


Decode TTI Trace For Large File Size
    [Arguments]    ${ttitrace_path}  ${dir}
    Dated Log                        converting large ttitrace pcap to csv
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
    run     tcpdump -r ${tti_path}/tcpdump_ttitrace.pcap -w ${tti_path}/tti_split.pcap -C 22
    ${files}    OperatingSystem.List Files In Directory     ${tti_path}     tti_split.*
    log to console    file_list-${files}
    ${count}    Count Files In Directory    ${tti_path}     tti_split.*
    log to console    file_count-${count}
    FOR    ${i}  IN RANGE   0   ${count}
    Run keyword if  ${i}!=0 and 'tti_split.pcap${i}' in ${files}
    ...    run     mv ${tti_path}/tti_split.pcap${i} ${tti_path}/tti_split_${i}.pcap
    ...    ELSE
    ...    run     mv ${tti_path}/tti_split.pcap ${tti_path}/tti_split_${i}.pcap
    Dated Log         converting ${tti_path}/tti_split_${i}.pcap to ${tti_path}/output_${dir}_formated_${i}.csv
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}    filename=tti_split_${i}.pcap
    Common Format Tti In Stream Mode         ${tti_path}/output_${dir}.csv     ${tti_path}/output_${dir}_formated_${i}.csv
    run     rm ${tti_path}/tti_split_${i}.pcap
    END
    merge_multiple_csv      ${tti_path}   ${dir}

IRAT Configuration IP addition
    OperatingSystem.Run     sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.4/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.5/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.6/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.7/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.121/24 dev eth3

