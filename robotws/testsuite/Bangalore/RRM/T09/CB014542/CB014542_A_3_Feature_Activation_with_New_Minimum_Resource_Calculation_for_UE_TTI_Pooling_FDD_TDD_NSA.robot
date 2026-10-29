*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LOOO    VARIANT_SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_1
...             CRT    SBTS00   223580

Documentation    :copyright: Nokia
...              :author: Ganesha, Shekher
...              :contact:
...         This Case is Belongs to CB014542  A Split, D Split

Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Resource         ../../../resources/robot/BBpooling_MuMIMO.robot
Resource         ../../../resources/robot/Common_Keywords.robot
Resource         ../../../resources/robot/common_log_collection.robot
Library          validation.py

Library    taf.transport.ssh  WITH NAME  ssh
Library      taf.sbts.oam.coam.admin

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_RJIO.lua
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID1}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${TRF_ID}    1
${Q_O_ADD1}    1
${epc_log_path}    /tmp/
${r&d_parameter}    0x5808BF=1;0x5808BE=1;0x5808C1=10;0x5808C2=90;0x5808C8=2;0x5808c0=4;0x58057c=32783;0x58057a=4
${TDD_L1_DL}   30
${TDD_L1_UL}   40
${FDD_L1_DL}   22
${FDD_L1_UL}   20
&{Split_A_TDD_dl}    50=10    51=10    52=10
&{Split_A_FDD_dl}    53=8     54=7     55=7
&{Split_A_TDD_ul}    50=12    51=16     52=12
&{Split_A_FDD_ul}    53=7     54=7      55=6
@{pysical_cell_ids1}    50     51    52    53    54    55
${BSR_SW_FILE}     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001.zip
${sib_radiated_pattern}		systemInformationBlockType
${BTS_ADDRESS}    192.168.255.129
${BTS_PORT}       443
${USE_SSL}        True
*** Test Cases ***
[1][1.0] CB014542_A_3_Feature_Activation_with_New_Minimum_Resource_Calculation_for_UE_TTI_Pooling_FDD_NSA
    [Tags]     TC01    SPLIT-A   SPLIT_D
    [Setup]    Run Keywords    Run Keyword and Ignore error  Suite setup from scratch
    ...    AND     Get and Update BSR SW via gitlab   ${BSR_SW_FILE}
    ...    AND     Update GNB R&D Parameter    ${LOG_PATH}   ${r&d_parameter}
    ...    AND     Start Log    btslog
    #...    AND     Download and upload modified vendor file
    ...    AND     Reboot gNB System Module from Console and check Airscale is ready
    ...    AND     Load CFG and verify cell status    ${wts_cfg_file}  	1    6
    ...    AND     Check gNB Bulid
    ${setup}    Stop Log    btslog    test_scenario=cell_setup
    Validate R&D Parameter in SYSLOG     ${setup}
    Register Ues and Send Low data    1    240
#    Run Keyword And Continue On Failure    Collect TTI and Validate UE Allocation     ${LOG_PATH}   equal_load    ${Split_A_TDD_dl}
#    ...    ${Split_A_TDD_Ul}  ${Split_A_FDD_dl}   ${Split_A_FDD_Ul}  ${TDD_L1_DL}  ${FDD_L1_DL}   ${TDD_L1_UL}   ${FDD_L1_UL}
    Send High data
    sleep    10s     reason=wait for data to stable
    Run Keyword And Continue On Failure    Collect TTI and Validate UE Allocation     ${LOG_PATH}   high_load    ${Split_A_TDD_dl}
    ...   ${Split_A_TDD_Ul}   ${Split_A_FDD_dl}   ${Split_A_FDD_Ul}  ${TDD_L1_DL}  ${FDD_L1_DL}   ${TDD_L1_UL}   ${FDD_L1_UL}
    Stop log    snapshot  test_scenario=snapshot
    [Teardown]   Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Send High data
    ${UELIST}    Create List     1    41   81    121    161    201
    FOR    ${ue_id}    IN   @{UELIST}
        wts_sim_keywords.MultiUE Trigger DL Bursty Data Traffic for SA   ${ue_id}    ${ue_id}+10   mbps   5
        wts_sim_keywords.MultiUE Trigger UL Bursty Data Traffic for SA   ${ue_id}    ${ue_id}+10   mbps   5
        FOR  ${UE}  IN RANGE   ${ue_id}+11   ${ue_id}+30
            wts_sim_keywords.Trigger DL Data Traffic for SA   ue_id=${UE}    Traffic_rate=mbps     dl_rate=10
            wts_sim_keywords.Trigger UL Data Traffic for SA   ue_id=${UE}    Traffic_rate=mbps     ul_rate=10
        END
        FOR  ${UE}  IN RANGE   ${ue_id}+30   ${ue_id}+40
            wts_sim_keywords.Trigger DL Traffic for SA   ue_id=${UE}    Traffic_rate=mbps     dl_rate=5    qfi_id=2
            wts_sim_keywords.Trigger UL Traffic for SA   ue_id=${UE}    Traffic_rate=mbps     ul_rate=5    qfi_id=2
        END
    END

Download and upload modified vendor file
    Download Vendor File From GNB    ${LOG_PATH}
    ${xml}=    OperatingSystem.Get File    ${LOG_PATH}/vendor_lte.xml
    ${out}=    String.Replace String    ${xml}    name="actScheUePoolingEnh">false</p>   name="actScheUePoolingEnh">true</p>
    OperatingSystem.Create File    ${LOG_PATH}/vendor_lte.xml    ${out}
    Upload Modified Vendor File And Trigger Full Commissioning    ${LOG_PATH}

Load config file check cell status
    Configure eth3 IP
    Load Lua File   ${wts_cfg_file}
    Verify_sib_for_Cell    1    6

Verify_sib_for_Cell
    [Arguments]		${start_cell} 	${end_cell}		${enb_id}=2
    FOR     ${i}    IN RANGE    ${start_cell}   ${end_cell}+1
    ${sib_disp_cmd}		SET VARIABLE	enb_cell_ib_disp cell=${i} enb=${enb_id} type=sib1
    ute_wtssim.Execute Egate Command And Wait For Data      ${sib_disp_cmd}     pass_regexp=${sib_radiated_pattern}
    ...     timeout=10s
    END

Load Lua File
	[Arguments]             ${wts_cfg_file}
    Log To Console    Starting WTS...
    Run Keyword And Ignore Error     wts_sim_keywords.Clean edaemon and egate
    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${wts_cfg_file}
    ute_wtssim.Setup Edaemon    edaemon_port=${EDAEMON_PORT}    tool_dir=${WTS_DIR}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=${EGATE_PORT}    tool_dir=${WTS_DIR}
    ute_wtssim.Start Egate Process
    ${verify_pattern}       SET VARIABLE    (eNB 1 cell 1\: SystemInformationBlockType2 updated)
    ute_wtssim.Execute Egate Command And Wait For Data    cfg file\=${wts_cfg_file}   pass_regexp=${verify_pattern}   timeout=20s
    Sleep   10s

Register Ues and Send Low data
    [Arguments]     ${Start_ue}    ${End_ue}
    FOR    ${ue_id}    IN RANGE    ${Start_ue}   ${End_ue}+1
    wts_sim_keywords.UE Register should be Successful And Fetch RNTI    ${ue_id}    gw_id=${ue_id}
    wts_sim_keywords.Trigger DL Data Traffic for SA   ue_id=${ue_id}    Traffic_rate=kbps     dl_rate=1000
    END
    ${UELIST}    Create List     31    71   111    151    191    231
    FOR    ${ue_id}    IN   @{UELIST}
        FOR  ${UE}  IN RANGE   ${ue_id}   ${ue_id}+10
            wts_sim_keywords.UE PDU Modfication should be Successful    ${UE}    pdu_id=1    qosflows_to_add=4
        END
    END

Update GNB R&D Parameter
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   admin.Setup admin    bts_host=${BTS_ADDRESS}   bts_port=${BTS_PORT}   use_ssl=${USE_SSL}   name=swc
   admin.download_software_config    ${LOG_PATH}/swconfig_gnb.txt   connection=swc
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   ssh.connect_to    hostname=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    alias=OAM-conn
   ssh.upload_file    local_path=${LOG_PATH}/swconfig_gnb.txt     remote_path=/ffs/run/swconfig.txt    connection=OAM-conn
   ssh.send_command     command=crasign /ffs/run/swconfig.txt   connection=OAM-conn
   ssh.send_command     command=craverify /ffs/run/swconfig.txt*    connection=OAM-conn
   ssh.disconnect   connection=OAM-conn

Collect TTI and Validate UE Allocation
    [Arguments]   ${LOG_PATH}   ${filename}   ${Expected_TDD_dl}  ${Expected_TDD_ul}
    ...    ${Expected_FDD_dl}  ${Expected_FDD_ul}    ${TDD_L1_DL}   ${FDD_L1_DL}   ${TDD_L1_UL}   ${FDD_L1_UL}
    Start Log      ttitrace
	Sleep    1s
    ${tti}    Stop Log       ttitrace   test_scenario=${filename}
#    OperatingSystem.Run    mv ${tti}[ttitrace]/tcpdump_ttitrace.pcap ${tti}[ttitrace]/large.pcap
#    OperatingSystem.Run   tcpdump -r ${tti}[ttitrace]/large.pcap -w ${tti}[ttitrace]/tcpdump_ttitrace.pcap -C 5
    Common TTI PCAP to CSV Converter    ${filename}
    Log to console   ${LOG_PATH}
    ${Status}  Check_maxNumPdschUes     ${tti}[ttitrace]/output_dl_formated.csv   ${Expected_TDD_dl}   ${TDD_L1_DL}
	Run Keyword If   ${Status} != ${True}   Fail   Check the UE allocation and L1 Capacity
    ${Status_UL}  Check_maxNumPuschUes     ${tti}[ttitrace]/output_ul_formated.csv   ${Expected_TDD_ul}   ${TDD_L1_UL}
	Run Keyword If   ${Status_UL} != ${True}   Fail   Check the UE allocation and L1 Capacity

    ${Status}  Check_maxNumPdschUes     ${tti}[ttitrace]/output_dl_formated.csv   ${Expected_FDD_dl}    ${FDD_L1_DL}
	Run Keyword If   ${Status} != ${True}  Fail   Check the UE allocation and L1 Capacity
    ${Status_UL}  Check_maxNumPuschUes     ${tti}[ttitrace]/output_ul_formated.csv   ${Expected_FDD_Ul}    ${FDD_L1_UL}
	Run Keyword If   ${Status_UL} != ${True}   Fail   Check the UE allocation and L1 Capacity

Validate R&D Parameter in SYSLOG
    [Arguments]    ${path}
    ${status} =   run    command=sudo cat ${path}[btslog]/gnb_syslog.log | grep "ScheUePoolingEnhAlgRadParams"
    Should Not Be Empty    ${status}
    Should Contain    ${status}    rdScheUePoolingMinResourceDL: 1
    Should Contain    ${status}    rdScheUePoolingMinResourceUL: 1
    Should Contain    ${status}    scheUePoolingOverAllocFactor: 0.10
    Should Contain    ${status}    scheUePoolingGracefulAllocFactor: 0.90
    Should Contain    ${status}    scheUePoolingTypicalUeSlotUsage: 4.00
    Should Contain    ${status}    scheUePoolingTypicalUeSlotUsageFdd: 2.00
    ${DL_Stats} =   run    command=sudo cat ${path}[btslog]/gnb_syslog.log | grep "\\[ DL \\] minNumOfPxschResource" | head -n 2
    ${UL_Stats} =   run    command=sudo cat ${path}[btslog]/gnb_syslog.log | grep "\\[ UL \\] minNumOfPxschResource" | head -n 2
    Should Contain   ${DL_Stats}    minNumOfPxschResource:1.00
    Should not Contain   ${DL_Stats}    maxNumOfPxschResource:0.00
    Should Contain   ${UL_Stats}    minNumOfPxschResource:1.00
    Should not Contain   ${UL_Stats}    maxNumOfPxschResource:0.00
    ${featurePram} =   run    command=sudo cat ${path}[btslog]/gnb_syslog.log | grep "actScheUePooling"
    Should Contain    ${featurePram}     actScheUePoolingEnh":true

Common TTI PCAP to CSV Converter
    [Arguments]    ${ttitrace_path}
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
    ${tti_file_size}    Get File Size    ${tti_path}/tcpdump_ttitrace.pcap
    Run Keyword If  ${tti_file_size} <= 30000000
    ...   Decode TTI Trace    ${ttitrace_path}
    ...   ELSE
    ...   Run Keywords    Decode TTI Trace For Large File Size    ${ttitrace_path}  dl
    ...   AND    Decode TTI Trace For Large File Size    ${ttitrace_path}  ul

Decode TTI Trace For Large File Size
    [Arguments]    ${ttitrace_path}  ${dir}
    Dated Log                        converting large ttitrace pcap to csv
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
    run     tcpdump -r ${tti_path}/tcpdump_ttitrace.pcap -w ${tti_path}/tti_split.pcap -C 10
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
