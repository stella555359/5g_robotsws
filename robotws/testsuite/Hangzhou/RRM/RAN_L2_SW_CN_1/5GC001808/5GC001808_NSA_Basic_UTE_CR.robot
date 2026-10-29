*** Settings ***
Documentation    ...
#Documentation     author: bizhou contact: biao.zhou@nokia-sbell.com
#Suite Setup       Run Keywords    Suite Setup Update GNB
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#...               AND    NSA L3 Call and Collect Sherpa logs
#Suite Teardown    Common Suite Teardown 2
#Force Tags        master_classicalbts_all    STATE_CONFIGURED    CRT
#...               RAN_5G_TDD    FR1    Owner_q19370    PRI-High
#...               RAN_5G    SBTS00    SBTS23R1    SBTS22R4    CLOUD_5G_I_BN_AP_KL_SANSA_FS_CPRI_CMWV_FDD
#Test Timeout      25 minutes
#
#Library           OperatingSystem
#Library           Process
#Library           String
#Library           Collections
#Library           DateTime
#Resource          ./../5GC001808/AirPhone_common_resource_UTE_CR.robot
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
#5GC001808-ET-L002-Verify load information in msg CPU load measurement of DU_L2HI Sherpa log
#    [Tags]    Owner_bizhou
#    Read csv file    ControlFlows
#    Check 0x4a msg of L2HIDU in ControlFlows csv file
#
#5GC001808-ET-M002-Verify the K2 value in DU-L2PS_Periodic_UL msg of L2PS Sherpa log
#    [Tags]    Owner_bizhou
#    Read csv file    micro__Scg
#    Check K2 values in Scg csv file
#
#5GC001808-ET-I001-Verify the length of SINR in UlData_PucchReceiveRespPs msg of L2PS Sherpa log should be extended with 2 bits from s9 to s11
#    [Documentation]    The purpose of this case is to check the sinr of the UL_pucchreceiveResPs
#    [Tags]    Owner_bizhou
#    [Timeout]    23 min
#    Read csv file    l1l2Trace
#    ${aim_column}    Get aimcolumn according to filter condition from l1l2Trace csv    MSGID    TEXT    Ul PucchReceiveRespPs    None
#    ${aim_sinLayer0}    Get aimlist according to keyword from aimcolumn    sinLayer0=(-*\\d*.\\d*)dB    ${aim_column}
#    ${aim_sinLayer1}    Get aimlist according to keyword from aimcolumn    sinLayer1=(-*\\d*.\\d*)dB    ${aim_column}
#    Check sinLayer0 in aimresult    ${aim_sinLayer0}
#    Check sinLayer1 in aimresult    ${aim_sinLayer1}
#
#*** Keywords ***
#NSA L3 Call and Collect Sherpa logs
#    Config and get All L2stream logs including attach and traffic    "NSA_basic_L3CALL"     #///need to modify arguments for various L3CALL
#    Makesure UTEVM Sherpa tool can work
#    Convert Pcap To Sherpa Csv    ${SUITE_LOG_DIRECTORY}
#
#Check 0x4a msg of L2HIDU in ControlFlows csv file
#    ${result}    SherpaCsvReader.check all values for column    MSGID    UlDl DU:CpuMeasurment(0x4a)
#    Should Be True    ${result}    0x4a report msg is not found in L2HI-DU
#
#Check K2 values in Scg csv file
#    ${result}    SherpaCsvReader.check_csv_column_match_all    k2    (\\d\\s){16}
#    Should Be True    ${result}
#    Log to Console    \t k2 value is with correct format
#    ${k2_result}    SherpaCsvReader.get_all_values_column    k2    None
#    Log to Console    \t k2 value is decoded with: ${k2_result}
#
#Get aimcolumn according to filter condition from l1l2Trace csv
#    [Arguments]    ${column2}    ${column1}    ${filter_variable}    ${filter_variable2}
#    ${aim_column}    get_all_values_column2_from_column1    ${column2}    ${column1}    ${filter_variable}    ${filter_variable2}
#    [Return]    ${aim_column}
#
#Get aimlist according to keyword from aimcolumn
#    [Arguments]    ${keyword}    ${aim_column}
#    ${aim_list}    create list
#    FOR    ${item}    IN    @{aim_column}
#         ${result_1}    ${result_2}    should match regexp    ${item}    ${keyword}
#         append to list    ${aim_list}    ${result_2}
#    END
#    [Return]    ${aim_list}
#
#Check sinLayer0 in aimresult
#    [Arguments]    ${aim_result}
#    ${SinLayer0}    create list
#    FOR    ${item}    IN    @{aim_result}
#         Run Key Word If    ${item}<-102.4 or ${item}>102.3    append to list    ${SinLayer0}    ${item}
#    END
#    ${result}    ${error}    Run Keyword and ignore error    should not be empty    ${SinLayer0}
#    should contain    ${result}    FAIL
#
#Check sinLayer1 in aimresult
#    [Arguments]    ${aim_result}
#    ${SinLayer1}    create list
#    FOR    ${item}    IN    @{aim_result}
#         Run Key Word If    ${item}<-102.4 or ${item}>102.3    append to list    ${SinLayer1}    ${item}
#    END
#    ${result}    ${error}    Run Keyword and ignore error    should not be empty    ${SinLayer1}
#    should contain    ${result}    FAIL
