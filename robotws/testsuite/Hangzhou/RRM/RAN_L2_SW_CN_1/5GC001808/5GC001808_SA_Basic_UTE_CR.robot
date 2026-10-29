*** Settings ***
Documentation    ...
#Documentation     author: alicchen contact: alice.1.chen@nokia-sbell.com
#Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=${RD_PARAM}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#...               AND    SA L3 Call and Collect Sherpa logs
#Suite Teardown    Common Suite Teardown 2
#Force Tags        RAN_5G_TDD    FR1
#...               Owner_alicchen    PRI-High    CRT    RAN_5G
#...               SBTS00    SBTS23R1    SBTS22R4    CLOUD_5G_I_BN_AP_KL_SANSA_FS_CPRI_CMWV_FDD
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
#&{GNB_ASIK}            ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
#${RD_PARAM}            0x570010=1
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${BEARER_ID}           2
#@{LOG_NAME_LIST}       btslog    snapshot
#${COUNT}               0
#
#*** Test Cases ***
#5GC001808-ET-E001-Verify the CuUeID is sent from CPRT to L2HIDu by HiUserDu_BearerSetupReq msg on SA mode
#    [Tags]    Owner_q19370
#    Read csv file    ControlFlows
#    Check value of UECuId should be equal from 0x60 of L2HICU and ox41 of L2HIDU
#
#5GC001808-ET-H001-Verify Paging info is valid on event 22 PsSqpl_PcchDataSendReq of L2PS Sherpa log
#    [Documentation]    The purpose of this case is to check Paging info is valid on event 22 PsSqpl_PcchDataSendReq of L2PS Sherpa log
#    [Tags]    Owner_alicchen
#    [Timeout]    23 min
#    Read csv file    l1l2Trace
#    ${result}    SherpaCsvReader.check all values for column    MSGID    Dl PcchDataSendReq(22)
#    Should Be True    ${result}    event 22 is not reported in l1l2Trace csv file
#
#5GC001808-ET-O004-Verify DL control information of PduSessionErrorInd in CU-L2HI_CTRL_MSG
#    [Documentation]    The purpose of this case is to verify load information of L2HI Sherpa log
#    ...    -- 0x3b: L2HI-CU
#    ...    -- 0x4a: L2HI-DU
#    [Tags]    Owner_q19370
#    [Timeout]    23 min
#    Read csv file    ControlFlows
#    Check 0x63 msg of L2HICU in ControlFlows csv file
#
#CNI_57017_ET_0003_Verify_PDCCH_And_PDSCH_With_SIB1_Reported_By_Sherpa_On_SA_Call
#    [Tags]    Owner_q19370
#    Read Csv File    l1l2Trace
#    Check Event 30 For PDSCH And PDCCH In L1l2Trace Csv File    0xffff
#
#*** Keywords ***
#SA L3 Call and Collect Sherpa logs
#    Config and get All L2stream logs including attach and traffic    "SA_basic_L3CALL"     #///need to modify arguments for various L3CALL
#    Makesure UTEVM Sherpa tool can work
#    Convert Pcap To Sherpa Csv    ${SUITE_LOG_DIRECTORY}
#
#Check value of UECuId should be equal from 0x60 of L2HICU and ox41 of L2HIDU
#    ${du_result}    SherpaCsvReader.get_all_values_column2_from_column1    MSGID    UEIdCU    UlDl DU:SetupRequest(0x41)    \\d
#    ${cu_result}    SherpaCsvReader.get_all_values_column2_from_column1    MSGID    UEIdCU    UlDl CU v4:BearerSetupParam(0x60)    \\d
#    Should Contain    ${du_result}    @{cu_result}[0]
#
#Check 0x63 msg of L2HICU in ControlFlows csv file
#    ${result}    SherpaCsvReader.check all values for column    MSGID    UlDl CU v4:SessionError(0x63)
#    Should Be True    ${result}    0x63 report msg is not found in L2HI-CU
#
#Check Event 30 For PDSCH And PDCCH In L1l2Trace Csv File
#    [Arguments]    ${rnti_id}
#    ${result}    SherpaCsvReader.Get All Values Column2 From Column1    RNTI    MSGID    ${rnti_id}    Dl PdschSendReq\\(30\\)
#    Should Not Be Empty    ${result}    Event30 with ${rnti_id} is not reported in l1l2Trace
#    ${sfn_results_1}    SherpaCsvReader.Get All Values Column2 From Column1    MSGID    AIR TTI    Dl PdschSendReq(30)    None
#    ${sfn_1}    Set Variable    ${sfn_results_1}[0]
#    ${sfn_results_2}    SherpaCsvReader.Get All Values Column2 From Column1    MSGID    AIR TTI    Dl PdcchSendReq(29)    None
#    ${sfn_2}    Set Variable    ${sfn_results_2}[0]
#    Should Be Equal    ${sfn_1}    ${sfn_2}
#
