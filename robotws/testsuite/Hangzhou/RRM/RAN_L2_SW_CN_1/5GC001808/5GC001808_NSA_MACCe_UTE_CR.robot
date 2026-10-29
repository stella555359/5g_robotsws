*** Settings ***
Documentation    ...
#Documentation     author: bizhou contact: biao.zhou@nokia-sbell.com
#Suite Setup       Run Keywords    Suite Setup Update GNB
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#...               AND    NSA L3 Call and Collect Sherpa logs
#Suite Teardown    Common Suite Teardown 2
#Force Tags        master_classicalbts_all    STATE_CONFIGURED    CRT    RAN_5G_TDD
#...               FR1    Owner_q19370    PRI-High    RAN_5G
#...               SBTS00    SBTS23R1    SBTS22R4    CN1_SQ    CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD
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
#${UE_ID}               11
#${PROFILE_ID}          1
#${GNB_ID}              2
#${BEARER_ID}           2
#@{LOG_NAME_LIST}       btslog    snapshot
#${COUNT}               0
#
#*** Test Cases ***
#5GC001808-ET-T001-Verify the number of MACSDU should be extended to 60 in DU-L2LO_PDU_UL on NSA mode
#    [Documentation]    The purpose of this case is to check the elements extend from 29 to 60
#    [Timeout]    23 min
#    Read csv file    ControlFlows
#    ${SEQ_list}    Get SEQ list according to Ul LO:MacCE msg from ControlFlows csv file    MSGID    SEQ    Ul LO:MacCE    None
#    Read csv file    RlcFlows
#    ${DRBs_number_list}    Get DRBs_number list according to SEQ list from RlcFlows csv file    SEQ    Mode UL    ${SEQ_list}    AM/18?
#    Check the number of MACSDU extended from 29 to 60    ${DRBs_number_list}
#
#*** Keywords ***
#NSA L3 Call and Collect Sherpa logs
#    Config and get All L2stream logs including attach and traffic    "NSA_MODIFY_TBSIZE"     #///need to modify arguments for various L3CALL
#    Makesure UTEVM Sherpa tool can work
#    Convert Pcap To Sherpa Csv    ${SUITE_LOG_DIRECTORY}
#
#Check 0x3b msg of L2HICU in ControlFlows csv file
#    ${result}    SherpaCsvReader.check all values for column    MSGID    UlDl CU v2:Measurment(0x3b)
#    Run Keyword If    '${result}' == 'True'    Log To Console    \n 0x3b report msg is found in L2HI-CU \n
#    ...    ELSE    Log To Console    \n 0x3b report msg is not found in L2HI-CU \n
#
#Get SEQ list according to Ul LO:MacCE msg from ControlFlows csv file
#    [Arguments]    ${column1}    ${column2}    ${filter_variable}    ${filter_variable2}
#    ${aim_column}    get_all_values_column2_from_column1    ${column1}    ${column2}    ${filter_variable}    ${filter_variable2}
#    [Return]    ${aim_column}
#
#Get DRBs_number list according to SEQ list from RlcFlows csv file
#    [Arguments]    ${column1}    ${column2}    ${filter_variable}    ${filter_variable2}
#    ${aim_column}    create list
#    ${filter_variable1}    remove dumplicates list    ${filter_variable}
#    FOR    ${item}    IN    @{filter_variable1}
#         ${aim_column1}    get_all_values_column2_from_column1    ${column1}    ${column2}    ${item}    ${filter_variable2}
#         ${count}    count_dumplicates_list    ${aim_column1}
#         ${count}    Set Variable If    "${count}"=="None"    0    ${count}
#         append to list    ${aim_column}    ${count}
#    END
#    [Return]    ${aim_column}
#
#Check the number of MACSDU extended from 29 to 60
#    [Arguments]    ${DRBs_number_list}
#    ${DRBs_number_extend}    create list
#    FOR    ${item}    IN    @{DRBs_number_list}
#        Run Key Word if    ${item}>30    append to list    ${DRBs_number_extend}    ${item}
#    END
#    ${result}    ${error}    should not be empty    ${DRBs_number_extend}
