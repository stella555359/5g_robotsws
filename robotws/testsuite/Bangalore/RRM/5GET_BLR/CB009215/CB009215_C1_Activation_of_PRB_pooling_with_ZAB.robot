*** Settings ***
#Force Tags      CLOUD_5G_I_LO_AP_LOOO    OPTION_RELATED_ARTIFACTS_5G   VARIANT_SANSA_FS_CPRI_CMWV_FDD
#...             SBTS00   CONFIGURED   5G_RAN   RAN_5G   RAN_5G_FDD   5G_RAN_FDD   CRT

Documentation    :copyright: Nokia
...              :authors: Geetha K R
...              :contact: geetha.k_r@nokia.com
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/Common_Keywords.robot
Resource         ./resources/CB009215_keyword.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource	     ../resources/robot/TTI.robot
Library          ./resources/check_cell_expected_prballocation.py
Library          taf.sw.scout    WITH NAME     scout

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_B1_B3_4_cell_2AMF.lua
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${epc_log_path}    /tmp/
${BTS_ADDRESS}    192.168.255.1
${configuration_directory}    ${LOG_PATH}
${maxNumLayerPrbL1Sp_DL}    636
${maxNumStreamPrbL1Sp_DL}    636
${maxNumLayerPrbL1Sp_UL}    318
${maxNumStreamPrbL1Sp_UL}    636
${maxNumWbStreamPrbL1Sp}     424
${SCFC}=               ${CURDIR}/config/SCF/CB009215_C1_4Cell_A4_20Mhz_SCF_GMC.xml
${AP_XML}=             ${CURDIR}/config/SCF/CB009215_C1_4Cell_A4_20Mhz_GMC_iphy.xml
${r&d_parameter}     0x58012d=3;0x580758=1;0x580690=1;0x58057a=4;0x58057c=0x7800;0x58057e=0x100;0x580117=1
@{PhysCellID}      50    51    52    53
@{L1SP1cellsIDs}    50    52
@{L1SP2cellsIDs}    51    53
@{Exp_SLIV}     67    54    # These SLIVs are with last Symbol muted

*** Keywords ***
Run CB009215_C1_Activation_of_PRB_pooling_with_Zero-Allocation_symbol_Bypass_ZAB_functionality
    [Documentation]    this user scenario describes the prb allocation among subpools for different demand with inter
    ...                pooling enabled with load-based-algorithm
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    ${TTI_log_dir}     Collect TTI Traces      dir_name=cell_idle     sleep_time=7
    FOR     ${cellid}    IN    @{PhysCellID}
        ${UL_Check}    Verify Expected PRB Allocation in UL    ${TTI_log_dir}[ttitrace]      ${cellid}    36    106    79
        ${DL_Check}    Verify Expected PRB Allocation in DL    ${TTI_log_dir}[ttitrace]      ${cellid}    48    106    79
    END
    Start Log    btslog
    Register and trigger 1 gbr and 1 nongbr UE to each cell
    sleep    10s
    ${TTI_log_dir}     Collect TTI Traces      dir_name=lowdata_in_both_SPs     sleep_time=1
    FOR     ${cellid}    IN    @{PhysCellID}
        ${UL_Check}    Run Keyword and Ignore Error    Verify Expected PRB Allocation in UL     ${TTI_log_dir}[ttitrace]
        ...      ${cellid}    36    106    79
        ${DL_Check}    Run Keyword and Ignore Error    Verify Expected PRB Allocation in DL    ${TTI_log_dir}[ttitrace]
        ...      ${cellid}    48    106    79
    END
    Stop Log    btslog    test_scenario=lowdata_in_allcells

    Start Log    btslog
    Register and trigger 2 gbr and 3 nongbr UE to SP1 cells
    Stop Log    btslog    test_scenario=high_data_in_l1sp1
    sleep    10s
    ${TTI_log_dir}     Collect TTI Traces      dir_name=ZAB_enabled_L1SP1     sleep_time=0.5
    FOR     ${cellid}    IN    @{L1SP1cellsIDs}
        ${UL_Check}    Verify Expected PRB Allocation in UL     ${TTI_log_dir}[ttitrace]      ${cellid}    36    106    106
        ${DL_Check}    Verify Expected PRB Allocation in Dl    ${TTI_log_dir}[ttitrace]      ${cellid}    48    106    106
    END
    #sherpa collection and validation when SP1 loaded high
    Deregister SP1 cells
    ${ZAB_cells}  ${NOZAB_cells}   Validate ZAB privilege granted    ${TTI_log_dir}[ttitrace]
    FOR  ${i}  IN  @{ZAB_cells}
        List Should Contain Value   ${L1SP1cellsIDs}    ${i}
    END
#    Validate Slot_3_6_8 Muting enabled for Zab cells    ${TTI_log_dir}[ttitrace]      ${Exp_SLIV}    ${ZAB_cells}
    #Lists Should Be Equal   ${ZAB_cells}   ${L1SP1cellsIDs}
    Verify PM Counter for l1sp1    M55308C10005      M55308C10005

    Start Log    btslog
    Register and trigger 2 gbr and 3 nongbr UE to SP2 cells
    Stop Log    btslog    test_scenario=high_data_in_l1sp2
    sleep    10s
    ${TTI_log_dir}     Collect TTI Traces      dir_name=ZAB_enabled_L1SP2     sleep_time=0.5
    FOR     ${cellid}    IN    @{L1SP2cellsIDs}
        ${UL_Check}    Verify Expected PRB Allocation in UL     ${TTI_log_dir}[ttitrace]      ${cellid}    36    106    106
        ${DL_Check}    Verify Expected PRB Allocation in DL     ${TTI_log_dir}[ttitrace]      ${cellid}    48    106    106
    END
    #sherpa collection and validation when SP2 loaded high
    ${ZAB_cells}  ${NOZAB_cells}   Validate ZAB privilege granted    ${TTI_log_dir}[ttitrace]
    FOR  ${i}  IN  @{ZAB_cells}
        List Should Contain Value   ${L1SP2cellsIDs}    ${i}
    END
#    Validate Slot_3_6_8 Muting enabled for Zab cells    ${TTI_log_dir}[ttitrace]      ${Exp_SLIV}    ${ZAB_cells}
    #Lists Should Be Equal   ${ZAB_cells}   ${L1SP2cellsIDs}
    Verify PM Counter for l1sp2    M55308C10005      M55308C10005


    Start Log    btslog
    Register and trigger 2 gbr and 3 nongbr UE to SP1 cells
    Stop Log    btslog    test_scenario=Equal_data_in_both_SPs
    sleep    30s
    ${TTI_log_dir}    Run Keyword and Ignore Error     Collect TTI Traces      dir_name=Equal_data_in_both_SPs     sleep_time=0.5
    #FOR     ${cellid}    IN    @{PhysCellID}
        #${UL_Check}    Verify Expected PRB Allocation in UL     ${TTI_log_dir}[ttitrace]      ${cellid}    36    106    79
        #${DL_Check}    Verify Expected PRB Allocation in DL     ${TTI_log_dir}[ttitrace]      ${cellid}    48    106    79
    #END
    Verify if available PRBs is less than PRB used
    Verify PRB_AVAIL_PDSCH_BB_POOL counter    27825000
    #sherpa collection and validation when both SP loaded equally
    #${ZAB_cells}  ${NOZAB_cells}   Validate ZAB privilege granted    ${TTI_log_dir}[ttitrace]
    #Lists Should Be Equal   ${ZAB_cells}   ${PhysCellID}

Register and trigger 1 gbr and 1 nongbr UE to each cell
    Register and trigger Multiple GBR biDir UE Traffic in a Cell    Start_UE=1    End_UE=1    DL_Rate=5    UL_Rate=5
    Register and trigger Multiple GBR biDir UE Traffic in a Cell    Start_UE=11    End_UE=11    DL_Rate=5    UL_Rate=5
    Register and trigger Multiple GBR biDir UE Traffic in a Cell    Start_UE=21    End_UE=21    DL_Rate=5    UL_Rate=5
    Register and trigger Multiple GBR biDir UE Traffic in a Cell    Start_UE=31    End_UE=31    DL_Rate=5    UL_Rate=5

    Register and trigger Multiple NonGBR biDir UE Traffic in a Cell    Start_UE=2    End_UE=2    DL_Rate=20    UL_Rate=10
    Register and trigger Multiple NonGBR biDir UE Traffic in a Cell    Start_UE=12    End_UE=12    DL_Rate=20    UL_Rate=10
    Register and trigger Multiple NonGBR biDir UE Traffic in a Cell    Start_UE=22    End_UE=22    DL_Rate=20    UL_Rate=10
    Register and trigger Multiple NonGBR biDir UE Traffic in a Cell    Start_UE=32    End_UE=32    DL_Rate=20    UL_Rate=10

Register and trigger 2 gbr and 3 nongbr UE to SP1 cells
    Register and trigger Multiple GBR biDir UE Traffic in a Cell    Start_UE=3    End_UE=4    DL_Rate=10    UL_Rate=10
    Register and trigger Multiple NonGBR biDir UE Traffic in a Cell    Start_UE=5    End_UE=7    DL_Rate=150    UL_Rate=100
    Register and trigger Multiple GBR biDir UE Traffic in a Cell    Start_UE=23    End_UE=24    DL_Rate=10    UL_Rate=10
    Register and trigger Multiple NonGBR biDir UE Traffic in a Cell    Start_UE=25    End_UE=27    DL_Rate=150    UL_Rate=100

Register and trigger 2 gbr and 3 nongbr UE to SP2 cells
    Register and trigger Multiple GBR biDir UE Traffic in a Cell    Start_UE=13    End_UE=14    DL_Rate=10    UL_Rate=10
    Register and trigger Multiple NonGBR biDir UE Traffic in a Cell    Start_UE=15    End_UE=17    DL_Rate=150    UL_Rate=100
    Register and trigger Multiple GBR biDir UE Traffic in a Cell    Start_UE=33    End_UE=34    DL_Rate=10    UL_Rate=10
    Register and trigger Multiple NonGBR biDir UE Traffic in a Cell    Start_UE=35    End_UE=37    DL_Rate=150    UL_Rate=100

Deregister SP1 cells
    MultiUE Deregister should be Successful    3    7
    MultiUE Deregister should be Successful    23    27


Verify if available PRBs is less than PRB used
     [Documentation]    PRB available should be less than PRB used
     log to console     Verify if the available PRB is less than used PRB
     sleep   300
     ${counter1_dl}           Get Counter Value With Admin          M55308C10005
     ${counter2_dl}           Get Counter Value With Admin          M55308C10001
     Should Be True      ${counter1_dl}>=${counter2_dl}


Collect TTI Traces
    [Arguments]    ${dir_name}     ${sleep_time}
    Start Log      ttitrace
	Sleep    ${sleep_time}s
    ${tti_log_path}    Stop Log      ttitrace   test_scenario=${dir_name}
    log to console   ${dir_name}
    log to console   ${tti_log_path}
	Decode TTI Trace    ${dir_name}
	[Return]    ${tti_log_path}

Verify Expected PRB Allocation in UL
    [Arguments]   ${csv_file_path}      ${cellid}    ${minallocprb}    ${maxallocprb}    ${expected_prb}
    log to console   verify Expected prb allocation in ul...
    ${Result}   check_cell_expected_prballocation.check_ulexpectedprb      ${csv_file_path}/output_ul_formated.csv
    ...     ${cellid}      ${minallocprb}
    ...     ${maxallocprb}    ${expected_prb}
    run keyword and continue on failure     should be true     ${Result}
    [Return]   ${Result}

Verify Expected PRB Allocation in DL
    [Arguments]   ${csv_file_path}      ${cellid}    ${minallocprb}    ${maxallocprb}    ${expected_prb}
    log to console   verify Expected prb allocation in dl...
    ${Result}   check_cell_expected_prballocation.check_dlexpectedprb      ${csv_file_path}/output_dl_formated.csv
    ...     ${cellid}      ${minallocprb}
    ...     ${maxallocprb}    ${expected_prb}
    run keyword and continue on failure     should be true     ${Result}
    [Return]   ${Result}
