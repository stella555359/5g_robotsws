*** Settings ***
Documentation    ...
#Documentation     author: bizhou contact: biao.zhou@nokia-sbell.com
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Update WTS Config File For MultiDRB
#...               AND    Suite Setup Start WTS And Check OnAir
#...               AND    NSA L3 Call and Collect Sherpa logs
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CRT    RAN_5G_TDD
#...               FR1    Owner_q19370    PRI-High    RAN_5G
#...               SBTS00    SBTS23R1    SBTS22R4    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#Test Timeout      25 minutes
#
#Library           OperatingSystem
#Library           Process
#Library           String
#Library           Collections
#Library           DateTime
#Resource          ./AirPhone_common_resource_UTE_CR.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}            ${CURDIR}/config
#${DELTA_FILE}          Delta_Conf_5GC001808_NSA_multiDRBs.json
#${LOCAL_WTS_DIR}       ${CURDIR}/config/NSA_multiDRBs
#${LOCAL_WTS_CFG}       basic_fullstack_sansa_call_tdd_cmwv_nsa_multidrb.cfg
#${UE_ID}               11
#${PROFILE_ID}          1
#${GNB_ID}              2
#${BEARER_ID}           2
#@{LOG_NAME_LIST}       btslog    snapshot
#${COUNT}               0
##${multi_drbs_basic_file_path}    ${CURDIR}/config/NSA_multiDRBs
#${uzzy_matching_variable}    Received
#
#*** Test Cases ***
#5GC001808-ET-K001-Verify BearInfo is valid on msg LoCtrl_DlBufferStatusInd of L2LO Sherpa log in NSA mode
#    [Documentation]    The purpose of this case is to check the LoCtrl_DlBufferStatusInd period is 5ms
#    [Timeout]    23 min
#    Read csv file    RlcFlows
#    ${Time_list}    Get Time list according to TEXT from RlcFlows csv file    TEXT    TIME    ${uzzy_matching_variable}    None
#    ${period_list}   Get LoCtrl_DlBufferStatusInd period    ${Time_list}
#    Set Suite Variable    ${period}    5
#    ${period_int}    Evaluate    int(${period})
#    Should contain    ${period_list}    ${period_int}
#
#5GC001808-ET-K003-Verify updates of SDU BearInfo is valid on msg LoCtrl_DlBufferStatusInd of DU-L2LO_SDU_DL_Periodic Sherpa log in NSA mode
#    [Documentation]    The purpose of this case is to check the LoCtrl_DlBufferStatusInd period is 5ms
#    [Timeout]    23 min
#    Read csv file    RlcFlows
#    ${Time_list}    Get Time list according to TEXT from RlcFlows csv file    TEXT    TIME    ${uzzy_matching_variable}    None
#    ${Drbs_number_in_aslot}    Get the dumplicates number of the Time_list    ${Time_list}
#    Set Suite Variable    ${drbs}    2
#    ${drbs_int}    Evaluate    int(${drbs})
#    Should contain    ${Drbs_number_in_aslot}    ${drbs_int}
#
#*** Keywords ***
#Update WTS Config File For MultiDRB
#    Load Wts Cfg    ${WTS_DIR}/${WTS_CFG}
#	Modify    enb_param id=1    endc_capable_qci=all
#	Insert    set_bearer id=3 ue=11 qci=8 pdn=1 preprovisioned=on filter=2 precedence=2    after    set_bearer id=2
#	Save Wts Cfg    ${WTS_DIR}/${WTS_CFG}
#
#NSA L3 Call and Collect Sherpa logs
#    Config and get All L2stream logs including attach and traffic    "NSA_multi_DRBs"     #///need to modify arguments for various L3CALL
#    Makesure UTEVM Sherpa tool can work
#    Convert Pcap To Sherpa Csv    ${SUITE_LOG_DIRECTORY}
#
#Get Time list according to TEXT from RlcFlows csv file
#    [Arguments]    ${column1}    ${column2}    ${filter_variable}    ${filter_variable2}
#    ${aim_column}    get_all_values_column2_from_uzzy_matching_column1    ${column1}    ${column2}    ${filter_variable}    ${filter_variable2}
#    [Return]    ${aim_column}
#
#Get LoCtrl_DlBufferStatusInd period
#    [Arguments]    ${Time_list}
#    ${period_list}    create list
#    ${filter_variable}    remove dumplicates list    ${Time_list}
#    ${len}    BuiltIn.Get Length    ${filter_variable}
#    FOR    ${item}    IN    @{filter_variable}
#         ${index}    Get Index From List    ${filter_variable}    ${item}
#         Exit For Loop If    ${index} == ${len}-1
#         ${step_size}    Subtract Time From Time    ${filter_variable[${index}+1]}    ${filter_variable[${index}]}
#         ${step_size_result}    Evaluate    int(${step_size}*1000)
#         append to list    ${period_list}    ${step_size_result}
#    END
#    [Return]    ${period_list}
#
#Get the dumplicates number of the Time_list
#    [Arguments]    ${Time_list}
#    ${drbs_number_list}    create list
#    ${drbs_number_list}    count_dumplicates_list_get_count_list    ${Time_list}
#    [Return]    ${drbs_number_list}
