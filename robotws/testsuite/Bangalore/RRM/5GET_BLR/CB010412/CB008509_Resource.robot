*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Samik Sarkar
...              :contact: samik.sarkar@nokia.com

Variables    ta5g_global_var

Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../resources/robot/TTI_Traces.robot
Resource         ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/common_log_collection.robot


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          luashark_tools.analyzer       WITH NAME       analyzer
#Library          ute_admin                         WITH NAME   ute_adm
Library          Collections
Library          OperatingSystem
Library          ta5g_tshark
Library          ta5g_commissioning
Library          taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library          taf.transport.ssh                 WITH NAME    csn
Library          taf.ul.gnb.bip.collection   WITH NAME   bip_collection
Library          OperatingSystem
Library          String
Library          ../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../resources/NPS/SWENG/python_libs/luashark_tools.py
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ../resources/python/ssh_command.py
Library          ./python/increase_buffer_size.py
#Library          ./resources/python/CB008509_Verification.py
Library          ./python/CB008509_Counter_Verify.py
Library          DateTime

*** Variables ***
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${BIP_SCRIPT_PATH}         /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/resources/NPS/SWENG/config/script/
${port}                    22

#   Add your vonr codec speed
&{vonr_codec_rate}         amr_wb_18_25=18.6      amr_wb_23_85=21.4
@{gbr_qfi_list_cfg}        3	4	5 	6	7	8	9	10	11	12	13	14	15

${nsa_nr_cap_band66}       SEPARATOR=
...                        E1201000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A61000A0F883AC31B474
...                        98A823F96526CA01105B260901831E31FF9863CA16070387809ABA701ABA700008418083C9A1F00E41000000A4100
...                        0002A41000004A494000069807C15BCA9BC0DADD600A0800004B29282000032CA4A0800014B29282000072CA4A080
...                        0024B292920000AA5949405D05CBA559740F269564D2AC8AEE40107801A010080000008


${nsa_nr_mrdc_band66}      A10181102C0C03882000000888160641C460000024400401C041200210000804040080108000802020040080

${sa_nr_cap_band66}        SEPARATOR=
#...                        E1A01000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C600141F107586368
#...                        E9315047F2CA49940E0416C9824060C78C7FE618F28581C0E1E026AE9C06AE9C001007882001C4100000000420C04
#...                        1F413003800241C140180F82400603E00482000001001C15A0002000012CA4800682C509007801A01008000000000
#...                        0600400C0080108
...                        F5A03C0047D4FFBEFFFFBAF064003C170101E0935F1FFFB7C009009A3CE3FF30C7942C000DC0407E3802517041FF9
...                        BCA3BC857C1043E594962090105B29BA01893EB1079127C245116F9F804A2E009FF37944215F0410F965258824041
...                        6CA6E80624FAC41E449F091445BE7E0101407808001C41000000FF000FC0400083E20800401E001A01811B649F03F
...                        FFE00013003E00281C140180C426006000783A0070500603000020000300900180F80364800000564800001000B03
...                        2B0328020800004B29282000032CA4A00A80D5501AA12011001F24E03C9380000004040080101004008200

${nsa_nr_cap_band28}       SEPARATOR=
...                        E1201000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A61000A0F837AC31B474
...                        98A823F96526CA01105B260901831E31FF9863CA16070387809AAA701AAA700008418037C9A1F00E41000000A4100
...                        0002A41000004A494000069807C19BCA9BC0DADD600A0800004B29282000032CA4A0800014B29282000072CA4A080
...                        0024B292920000AA5949405D06CBA559740F269564D2AC8AEE40107801A010080000008

${nsa_nr_mrdc_band28}      A10181102C0C03836000000888160641C460000024400401C01B200210000804040080108000802020040080

${sa_nr_cap_band28}        SEPARATOR=
...                        E1A01000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A63000A0F837AC31B474
...                        98A823F96524CA01105B260901831E31FF9863CA16070387809BFF701BFF7000400E0D800000001006F9343E00482
...                        000001001C19A0002000012CA4800683450107801A010080000000000200400840

${radparam}                SEPARATOR=${EMPTY}   0x58057a=4;0x58057b=16842752;0x58057f=256;0x66001b=1;0x590072=1
*** Keywords ***
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

Load CFG Config And Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    Check gNB Airscale is Ready - ${BBoard_Type}
    Log To console     loading cfg file
    Start Log   btslog    cprt
    Check Cell On Air      ${wts_cfg_file}
    ${log_path_1}     Stop Log    cprt    btslog  test_scenario=cellsetup
    log to console      cprt-${log_path_1}
    set suite variable    ${log_path_1}

Read Cellsetup msg
    ${bts_log}      Set Variable  ${log_path_1}[btslog]/gnb_syslog.log
    ${cprt_log}      Set Variable  ${log_path_1}[cprt]/NODECPRT_GNB.pcap
    ${pdmlFile}    analyzer.pcap_to_pdml    ${cprt_log}         itf_l2_ps_cell_cellsetupreq
    ${CellSetupParam}    Create Dictionary    numPdschPrbInSsbSlots=0    numPdschPrbInTrsSlots=0
    ...    maxNumPdschAllocationPerSlot=0    ssbScs=0    dlBandwidth=0    targetTotalLoadSectorBeam_item=0
    ...    actConfDlInterferenceGen=0    mcsIndex=0    basicBeamSet=0    ulDlDataSlotRatio=0
    ...    rbgSizePdsch=0
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
    ${value} 	Get From Dictionary	${CellSetupParam}	numPdschPrbInSsbSlots
    ${usable_prb_on_ssb}    Run Keyword if    ${value}!=${0}
    ...    Run  cat ${bts_log} |grep -i -m 1 "Usable PRB count:"|awk -F 'Usable PRB count:' '{print $2}'| cut -d "," -f1
    log to console      usable_prb_on_ssb-${usable_prb_on_ssb}
    ${usable_prb_on_ssb}   Set Variable if     ${value}!=${0}    ${usable_prb_on_ssb}    ${numPdschPrbInSsbSlots}
    ${usable_prb_on_ssb}      convert to integer     ${usable_prb_on_ssb}
    Set To Dictionary	${CellSetupParam}	usable_prb_on_ssb=${usable_prb_on_ssb}
    log to console     CellSetupParam-${CellSetupParam}
    set suite variable    ${CellSetupParam}

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
    FOR   ${ue_id}    IN RANGE    1    ${end_ue} + 1
    wtsrunner.ue_testmode_set_nr  id=${ue_id}  testmode=beam_control  action=activate  profile_id=1  beamaction=attach
    END
    FOR    ${ue_id}    IN RANGE    ${end_ue}+1    ${max_ue_num} + 1
        wtsrunner.ue_testmode_set_nr  id=${ue_id}  testmode=beam_control  action=activate  profile_id=2  beamaction=attach
    END

## Delta Commissioning
Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size     ${AP_ASIK.ip}      ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}

Change GSCN Value
    [Arguments]    ${GSCN}
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
    Run    cat ${file_path}|grep -m 1 "GSCN"|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Send IPHY XML To Airphone   ${file_path}

Change IPHY File Value
    [Arguments]    ${RU_TYPE}   ${GSCN}
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
    Run    cat ${file_path}|grep -m 1 "card"|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
    Run    cat ${file_path}|grep -m 1 "GSCN"|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  300s

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

#    ${x}   ${y}    get_board_type    192.168.200.1   22    toor4nsn    oZPS0POrRieRtu
#    Run Keyword if    '${x}'=='ASIL' and '${y}'=='ABIO'
#    ...    update_iphy_7145    ${file_path}
#    sleep   4s
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  125s

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
    OperatingSystem.Run    sshpass -p ${AP_ASIK.password} scp ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy.xml ${save_dir}
    OperatingSystem.Should Exist    ${save_dir}/iphy.xml
    ${iphy_path}    Set Variable    ${save_dir}/iphy.xml
    [Return]    ${iphy_path}

Send IPHY XML To Airphone
    [Arguments]    ${iphy_path}
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ...
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/
    Should Be Equal As Integers    ${rc}    0

Change CFG File Value
    [Arguments]    ${file_path}    ${ul_arfcn}   ${dl_arfcn}    ${sa_cap}   ${nsa_nr_cap}   ${nsa_mrdc_cap}
    ${x}    Set Variable    nr_arfcn
    ${y}    Set Variable    nr_arfcn=
    ${z}    Catenate    SEPARATOR=:   ${ul_arfcn}   ${dl_arfcn}
    ${nsa_pat}  Set Variable       ue_eutra_nr_capabilities
    ${sa_pat}   Set Variable       ue_nr_capabilities
    Run    cat ${file_path}|grep -m 1 "${x}"|awk -F'${y}' '{print $2 }'|awk -F ' ' '{print $1}'|xargs -I {} sed -i 's/{}/${z}/g' ${file_path}
    #Below is for SA cap changes
    Run    cat ${file_path}|grep -m 1 "${sa_pat}"|awk -F'${sa_pat}=' '{print $2}'|xargs -I {} sed -i 's/{}/${sa_cap}/' ${file_path}
    #Below is for NSA cap changes
    #NSA_UE_NR cap changes
    ${cmd1}    Set Variable    cat ${file_path}|grep -m 1 "${nsa_pat}"|awk -F'${SPACE}${SPACE}dual_conn=eutra_nr' '{print $1}'
    ${cmd2}    Set Variable    |awk -F'${sa_pat}=' '{print $2}'|xargs -I {} sed -i 's/{}/${nsa_nr_cap}/g' ${file_path}
    ${cmd}     Set Variable    ${cmd1}${cmd2}
#   Run    cat ${file_path}|grep -m 1 "${nsa_pat}"|awk -F'${SPACE}${SPACE}dual_conn=eutra_nr' '{print $1}'|
#   ...    awk -F'${sa_pat}=' '{print $2}'|xargs -I {} sed -i 's/{}/${nsa_nr_cap}/g' ${file_path}
    Run    ${cmd}
    #NSA DC cap changes
    Run    cat ${file_path}|grep -m 1 "${nsa_pat}"|awk -F'${nsa_pat}=' '{print $2}'|xargs -I {} sed -i 's/{}/${nsa_mrdc_cap}/g' ${file_path}

Set user defined bler for multiple UE
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${dirct}    ${bler_per}    ${profile}=1
    FOR     ${ue_id}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
        Run Keyword if  '${dirct}' == 'dl'    wtsrunner.bler_testmode_nr    profile_id=${profile}
        ...    dl_bler=${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per}
        Run Keyword if  '${dirct}' == 'dl'    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=bler
        ...    action=activate    profile_id=${profile}
        # Fr UL SINR
        Run Keyword if  '${dirct}' == 'ul'    wtsrunner.bler_testmode_nr    profile_id=1
        ...    ul_bler=${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per}
        Run Keyword if  '${dirct}' == 'ul'    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=bler
        ...    action=activate    profile_id=${profile}
        # For both UL & DL
        Run Keyword if  '${dirct}' == 'both'    wtsrunner.bler_testmode_nr    profile_id=${profile}
        ...    dl_bler=${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per}
        ...    ul_bler=${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per},${bler_per}
        Run Keyword if  '${dirct}' == 'both'    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=bler
        ...    action=activate    profile_id=${profile}
	END

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

Read Bip Log
    [Arguments]    ${log_path}  ${event}   ${packet}  @{header}
    ${pdmlFile}    analyzer.pcap_to_pdml    ${log_path}/L1L2_GNB_FS_LO.pcap      dldata_pdschsendreq
    ${x}  Get Slice From List   ${path_list}    1
    ${data}      analyzer.get_match_from_paths         pdmlFile=${pdmlFile}
    ...                                                packetName=dldata_pdschsendreq
    ...                                                pathList=${x}
    ...                                                verbose=False
    ...                                                startPacket=1
    ...                                                endPacket=-1
    ...                                                getValue=True

    create_csv_file   ${filePath}  ${event}    ${data}  @{header}

Convert PCAP to CSV
    [Arguments]    ${PcapFile}    ${filters}    ${event}    @{headers}
    @{files}      OperatingSystem.List Files In Directory	   ${PcapFile}
    log to console      file-@{files}
    ${JsonPath}    ConvertPcapToJson    ${PcapFile}/${files}[0]    ${filters}
    ${csv_file_path}    get_values    ${JsonPath}  ${event}    @{headers}
    [Return]    ${csv_file_path}

Calculate Target Load Sector Beam
    [Arguments]    ${chBW}    ${ConfigType}    ${targetload}    ${nbrOfBlankedPRBsHighEdgeDL}=${0}
    ...    ${nbrOfBlankedPRBsLowEdgeDL}=${0}
    ${entireprb}  ${usablepdsch}  ${rat0bitmap}    cal_num_of_pdsch    ${chBW}    ${ConfigType}    ${nbrOfBlankedPRBsHighEdgeDL}
    ...    ${nbrOfBlankedPRBsLowEdgeDL}

    ${numofpdsch}   cal_total_target_load    ${entireprb}    ${usablepdsch}    ${rat0bitmap}    ${targetload}
    [Return]    ${numofpdsch}

Calculate Target Load Sector Beam PDCCH
    [Arguments]    ${chBW}    ${targetload}
    ${numofpdcch}    cal_total_target_load_pdcch    ${chBW}    ${targetload}
    [Return]    ${numofpdcch}
#Counter Verification Code

CB008509 Collect PM Counters New
    ${pm_counters_dir}=  Collect PM Counter  target_dir=${OUTPUT_DIR}/PMC
    Set Suite variable  ${pm_counters_dir}

Get buffer counters and validate
    [Arguments]    ${DL_SLOTS_BELOW_TGT_LOAD}    ${DL_SLOTS_ARTIFICIAL_LOAD}    ${DL_PRB_ARTIFICIAL_LOAD}
    ...    ${TRS_SLOTS}    ${SS_BURST_SLOTS}    ${DL_DATA_SLOTS}    ${PRB_USED_PDSCH}    ${MAX_LOAD_PERCENT}    ${idx}    ${numofpdsch}

    @{pi_list}=  Create List  ${DL_SLOTS_ARTIFICIAL_LOAD}    ${DL_SLOTS_BELOW_TGT_LOAD}    ${DL_PRB_ARTIFICIAL_LOAD}
    ...    ${TRS_SLOTS}    ${SS_BURST_SLOTS}    ${DL_DATA_SLOTS}    ${PRB_USED_PDSCH}
    @{counter_value} =  Create List
    FOR    ${counter}    IN    @{pi_list}
        ${actual_pm_values}
        ...    Get PM counter value modified    pm_files_location=${OUTPUT_DIR}/PMC/gnb_pm_counters
        ...    pi_id=${counter}      moc=MRBTS-1/NRBTS-1/NRCELL-3
        ${actual_pm_values}=   convert to integer    ${actual_pm_values}
#        Should Be True    ${actual_pm_values}
        Append To List    ${counter_value}    ${actual_pm_values}
        Log To Console    ${counter_value}
    END
	${loadperslot}    Run Keyword If   ${idx}==1 or ${idx}==2
	...     Evaluate  ((@{counter_value}[2]+@{counter_value}[6])/@{counter_value}[0])
	${loadperslot}    Run Keyword If   ${idx}==1 or ${idx}==2   convert to integer    ${loadperslot}
	Run Keyword If   ${idx}==1 or ${idx}==2
    ...     Should Be Equal    ${loadperslot}    ${numofpdsch}
    ...     ELSE
	...     Should Be Equal    @{counter_value}[2]    ${0}
	...     Should Be Equal    @{counter_value}[0]    ${0}

    ${trs}   Evaluate   ((1000/80) * 300)
    ${trs}   convert to integer    ${trs}
    log to console    trs_slot-${trs}
    Should Be Equal    ${trs}    @{counter_value}[3]

    ${ssb}   Evaluate   ((1000/20) * 300)
    ${ssb}   convert to integer    ${ssb}
    log to console    ssb_slot-${ssb}
    Should Be Equal    ${ssb}    @{counter_value}[4]

    ${dlslot}   Evaluate   ((75/80) * 300 * 1000)
    ${dlslot}   convert to integer    ${dlslot}
    log to console    dl_slot-${dlslot}
    Should Be Equal    ${dlslot}    @{counter_value}[5]

Calculate SSB Slot in One Cycle FDD
    [Arguments]   ${ssbperiod}    ${cycle_dur}
    ${x}   Evaluate   (1000/${ssbperiod}) * ${cycle_dur}


Get PM counter value modified
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        get the value of a counter in the last reporting period
    ...
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=PM*
    ${last_report}    Get From List   ${PM_report_dict_list}     -1
    ${pi_dict}   Get Dictionary Values   ${last_report}
    ${first_pi}    Get From List   ${pi_dict}     0
    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
    ${cell_dict}   Get From List   ${cell_dict_list}     0
    ${moc_list}   get dictionary keys   ${cell_dict}
    ${full_moc}    Set Variable     empty
    FOR  ${key}  IN   @{moc_list}
       ${key_is_moc}  Run Keyword And Return Status    Should Be Equal  ${key}   ${moc}
       ${full_moc}  Set Variable If   ${key_is_moc}   ${key}    ${full_moc}
    END
    ${pi_value}     Get From Dictionary      ${cell_dict}    ${full_moc}
    BuiltIn.Log    ${pi_id} value: ${pi_value}   console=${P_console}
    [Return]    ${pi_value}

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

MultiUE Attach for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    LTE Attach should be Successful    ${ue_id}
    UE Attach should be Successful    ${ue_id}
    END

MultiUE DL Traffic Start for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${dl_rate}    ${id}=${Bearer_ID}
    ...     ${trf_id}=${TRF_ID}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    Trigger DL Traffic for NSA    ${ue_id}    ${Traffic_rate}    ${dl_rate}    id=${Bearer_ID}    trf_id=${TRF_ID}
    END

MultiUE UL Traffic Start for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${ul_rate}    ${id}=${Bearer_ID}
    ...     ${trf_id}=${TRF_ID}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    Trigger UL Traffic for NSA    ${ue_id}    ${Traffic_rate}    ${ul_rate}    id=${Bearer_ID}    trf_id=${TRF_ID}
    END

MultiUE Validate DL Traffic For NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Bearer_ID}    ${dl_rate}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    Validate DL Traffic For NSA    ${ue_id}    ${dl_rate}   id=${Bearer_ID}
    END

MultiUE Validate UL Traffic For NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Bearer_ID}    ${ul_rate}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    Validate UL Traffic For NSA    ${ue_id}    ${ul_rate}   id=${Bearer_ID}
    END

MultiUE Detach for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    UE Detach should be Successful   ${ue_id}
    END

Enable CPRT Debug Log
    ${cmd}  set variable
    ...   ssh toor4nsn@192.168.255.1 'echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini; chmod a+r /ffs/run/cp_runtime.ini'
    Run    ${cmd}

Get counters and validate
    [Arguments]    ${PRB_USED_PDSCH}     ${DL_DATA_SLOTS}     ${SS_BURST_SLOTS}     ${DATA_SLOT_PDSCH}     ${SSB_SLOT_PDSCH}
    ...    	${TRS_SLOT_PDSCH}     ${DL_SLOTS_BELOW_TGT_LOAD}	${DL_SLOTS_ARTIFICIAL_LOAD}     ${DL_PRB_ARTIFICIAL_LOAD}     ${TRS_SLOTS}
    ...     ${AVE_NUMBER_OF_SA_RRC}     ${AVE_NUMBER_OF_NSA_USERS}     ${scenario}    ${SA_UE}    ${NSA_UE}
    ...     ${actualtargetload}    ${targetload}     ${mea_cycle}=${300}     ${moc}=MRBTS-1/NRBTS-1/NRCELL-1

    @{pi_list}=  Create List    ${PRB_USED_PDSCH}    ${DL_DATA_SLOTS}     ${SS_BURST_SLOTS}    ${DATA_SLOT_PDSCH}    ${SSB_SLOT_PDSCH}
    ...    	${TRS_SLOT_PDSCH}    ${DL_SLOTS_BELOW_TGT_LOAD}    ${DL_SLOTS_ARTIFICIAL_LOAD}    ${DL_PRB_ARTIFICIAL_LOAD}    ${TRS_SLOTS}
    ...     ${AVE_NUMBER_OF_SA_RRC}    ${AVE_NUMBER_OF_NSA_USERS}

    @{counter_value} =  Create List
    FOR    ${counter}    IN    @{pi_list}
    ${actual_pm_values}
    ...    Get PM counter value modified    pm_files_location=${OUTPUT_DIR}/PMC/gnb_pm_counters
    ...    pi_id=${counter}      moc=${moc}
    ${actual_pm_values}   convert to integer    ${actual_pm_values}
    log to console    counter-${counter}-value-${actual_pm_values}
    Append To List    ${counter_value}    ${actual_pm_values}
    END
    log to console    counter_value-@{counter_value}

    ${load}    Evaluate    @{counter_value}[8]/@{counter_value}[7]
    ${NumofSAUE}     Evaluate    @{counter_value}[10]/${mea_cycle}
    ${NumofSAUE}     convert to integer    ${NumofSAUE}
    log to console   Number of SA UE-${NumofSAUE}

    ${NumofNSAUE}    Evaluate    @{counter_value}[11]/${mea_cycle}
    ${NumofNSAUE}     convert to integer    ${NumofNSAUE}
    log to console   Number of NSA UE-${NumofNSAUE}

    Run Keyword If   ${scenario}==1  Part one verification  ${load}   ${actualtargetload}    ${targetload}
    ...    ${counter_value}   ${NumofSAUE}   ${NumofNSAUE}
    Run Keyword If   ${scenario}!=1  Part two verification   ${load}   ${actualtargetload}    ${targetload}  ${counter_value}
    ...    ${NumofSAUE}   ${NumofNSAUE}    ${SA_UE}    ${NSA_UE}

Part one verification
    [Arguments]  ${load}   ${actualtargetload}    ${targetload}  ${counter_value}   ${NumofSAUE}   ${NumofNSAUE}
    should Be True     ${load} > ${actualtargetload}
    should Be True     ${load} < ${targetload}
    Should Be Equal     ${counter_value}[0]     ${0}
    Should Be Equal     ${counter_value}[3]     ${0}
    Should Be Equal     ${counter_value}[4]     ${0}
    Should Be Equal     ${counter_value}[5]     ${0}
    Should Be Equal     ${counter_value}[6]     ${0}
    Should Be Equal     ${NumofSAUE}    ${0}
    Should Be Equal     ${NumofNSAUE}    ${0}

Part two verification
    [Arguments]  ${load}   ${actualtargetload}    ${targetload}  ${counter_value}   ${NumofSAUE}   ${NumofNSAUE}    ${SA_UE}    ${NSA_UE}
     Should Be True     ${load} < ${actualtargetload}
    Should Be True     ${load} < ${targetload}
    Should Be True     ${counter_value}[0] > ${0}
    Should Be True     ${counter_value}[3] > ${0}
    Should Be True     ${counter_value}[4] > ${0}
    Should Be True     ${counter_value}[5] > ${0}
    Should Be True     ${counter_value}[6] >= ${0}
    Should Be Equal     ${NumofSAUE}     ${SA_UE}
    Should Be Equal     ${NumofNSAUE}    ${NSA_UE}
