*** Settings ***
Resource    ../resources/5G_SW_WRO_Keywords.robot
Resource    ../resourcesULM/ttitrace.robot
Library     ../resourcesULM/python/ttitrace.py         WITH NAME  tti_streammode
Library     csvAnalyzer.py


Library    ta5g_enb
Library    ta5g_delta
Library    ta5g_file_system
Library    ta5g_ue_measurements
Library    taf.collectors.l2stream3                 WITH NAME  ttitraces


*** Variables ***
${custom-scf8246}          ${CURDIR}/../resources/custom-config/2_CELLS_SA_HR_DRB_TDD/SCF_CB008246.xml
${custom-scf8246_Q1}          ${CURDIR}/../resources/custom-config/2_CELLS_SA_HR_DRB_TDD/CB008246_Q1_BOO_LOO_N77_N257.xml
${custom-iphy}         ${CURDIR}/../resources/custom-config/2_CELLS_SA_HR_DRB_TDD/new_iphy_H.xml
${custom-iphy_Q1}         ${CURDIR}/../resources/custom-config/2_CELLS_SA_HR_DRB_TDD/iphy_n77_n257.xml
${64qamLowSe}=         nr-rrc.mcs_Table == 1
${DynBetaOffset}=      nr-rrc.mcs_Table == 1&&nr-rrc.betaOffsetACK_Index1==9&&nr-rrc.betaOffsetACK_Index2==6&&
...                    nr-rrc.betaOffsetACK_Index3==3&&nr-rrc.betaOffsetCSI_Part1_Index1==11&&nr-rrc.betaOffsetCSI_Part1_Index2==6
${HR_UL}=         itf_L2Log_Du_Ps_Events_UlFdSchedData_UlFdSchedData_t.laMode == 0x01
${HR_DL}=         itf_L2Log_Du_Ps_Events_DlFdSchedData_DlFdSchedData_t.laMode == 0x01
${QAM64LOWSE}=    QAM64LOWSE
${A4}=            nr-rrc.eventId

*** Keywords ***
Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:AMF2_NG_ADDR   ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:AMF3_NG_ADDR   ip_with_mask=10.0.1.4/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:AMF2_NG_ADDR   ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface    if_name=eth3:AMF3_NG_ADDR   ip_with_mask=10.0.1.4/24

Update Requested RnD flags in SW config file
    @{A_rd_params}=  create list  0x890057=0 # rdActNrDualConnectivity
    Update SW Config file on System Module  param_list=${A_rd_params}
    Set suite variable    ${force_reboot}    ${true}

Attach UE and verify tcpdump
    [Arguments]  ${ue}    ${packet_filter}     ${cell_id}    ${number_of_messages}
    Attach Ue    ue_id=${ue}
    Establish Pdu Session With Traffic   ue_id=${ue}    pdu_id=${ue}    gw_id=${ue}     throughput=3mbps
    Verify Tcpdump Log    packet_filter=${packet_filter}      number_of_messages=${number_of_messages}
    Deregister Ue Without Confirmation    ue_id=${ue}

Verify tcpdump
    [Arguments]  ${ue}    ${packet_filter}     ${cell_id}    ${number_of_messages}
#    Attach Ue    ue_id=${ue}
#    Establish Pdu Session With Traffic   ue_id=${ue}    pdu_id=${ue}    gw_id=${ue}     throughput=3mbps
    Verify Tcpdump Log    packet_filter=${packet_filter}      number_of_messages=${number_of_messages}
#    Deregister Ue Without Confirmation    ue_id=${ue}

Check msg in TTI logs
    [Arguments]    ${mesage1}    ${mesage2}    ${nrmsg1}=4000    ${nrmsg2}=4000
    ...            ${csv_path}=${OUTPUT_DIR}/${TEST_NAME}/tshark/tti_dl_and_ul.csv
#    ...            ${csv_path}=/home/ute/results/tti_dl_and_ul.csv
	${counter1}    ${counter2}		Parse_Csv_File_For_Message 	 ${mesage1}    ${mesage2}   ${csv_path}
	[return]    ${counter1}    ${counter2}
	Should Be True		${counter1} > ${nrmsg1}    ${counter2} > ${nrmsg2}

Check msg in TTI logs for 1 cycle
    [Arguments]    ${mesage1}    ${mesage2}    ${nrmsg1}=1500    ${nrmsg2}=1500
    ...            ${csv_path}=${OUTPUT_DIR}/${TEST_NAME}/tshark/tti_dl_and_ul.csv
#    ...            ${csv_path}=/home/ute/results/tti_dl_and_ul.csv
	${counter1}    ${counter2}		Parse_Csv_File_For_Message 	 ${mesage1}    ${mesage2}   ${csv_path}
	[return]    ${counter1}    ${counter2}
	Should Be True		${counter1} > ${nrmsg1}    ${counter2} > ${nrmsg2}
