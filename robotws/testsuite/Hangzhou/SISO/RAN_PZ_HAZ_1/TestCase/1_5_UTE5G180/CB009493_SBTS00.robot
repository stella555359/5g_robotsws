*** Settings ***
#Force Tags
Documentation    Suite description
...    Author:        wei.ren@nokia-sbell.com
...    Maintainer:    weren

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/affa.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_model.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/variables.robot
Variables   ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${peak1}    "660":[120,20],"661":[120,20],"662":[120,20],"663":[120,20],"664":[120,20],"665":[120,20]
${peak2}    "666":[120,20],"667":[120,20],"668":[120,20],"669":[120,20],"670":[120,20],"671":[120,20]
${peak3}    "170":[140,20],"171":[140,20],"172":[140,20],"173":[140,20],"174":[140,20],"175":[140,20]
${peak4}    "176":[70,20],"177":[70,20],"178":[70,20],"179":[140,20],"180":[140,20],"181":[140,20]
${peak5}    "182":[70,20],"183":[70,20],"184":[70,20],"185":[70,20]
&{CB009493_G3_ABIP_ASIM_AREA_AHEGC_AHHB}    HW_ID=ABIP   site_mode=5G    ONAIR_TIME=20 min
...	  peak_rate_config={${peak1},${peak2},${peak3},${peak4},${peak5}}
${peak6}    "660":[120,20],"661":[120,20],"662":[120,20],"663":[120,20],"666":[120,20],"669":[120,20]
${peak7}    "664":[200,20],"672":[200,20],"673":[200,20],"674":[200,20],"675":[200,20],"676":[200,20]
${peak8}    "677":[200,20],"678":[200,20],"679":[200,20],"680":[200,20],"682":[200,20],"683":[200,20]
&{CB009014_ABIP_ASIM_AREA_AHEGC_AHHB}    HW_ID=ABIP   site_mode=5G    ONAIR_TIME=20 min
...	  peak_rate_config={${peak6},${peak7},${peak8}}
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
#${ru_password_user}=    KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=
${INIT_CONFIG_ID}     CB009493_G3_ABIP_ASIM_AREA_AHEGC_AHHB
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitPartialReset    NgGnbInitFullReset
#&{ADDITIONAL_FLAGS}      37039=0x10041=5|0x10040=1|0x1003F=1|0x9D0001=1|0x9D0002=1|0x9D000A=1|0x10077=1|0x100b7=1|0x10079=300000|412=1|0x1001E=1

*** Test Cases ***
#[1][1] Common_SiSo_State Management_Cell_Block_Unblock
 #   [Tags]    QC_654365   QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Cell_Block    config_id=CB009493_G3_ABIP_ASIM_AREA_AHEGC_AHHB
   # Cell Block And Unblock All      required_cells=668
    #[Teardown]    Testcase Basic Postcondition

[1][1] Common_SiSo_Recovery_RF_Module_Reset
    [Tags]    QC_33150   QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF_Reset    config_id=CB009493_G3_ABIP_ASIM_AREA_AHEGC_AHHB
    SISO_Recovery RF module reset    required_cells=660    required_power_rfs=EA223852838
    [Teardown]    Testcase Basic Postcondition

#[1] Manual_SiSo_SM_LTE_RAT_reset_for_concurrent
#   [Tags]    QC_654368    QCD_MN_RAN    QCP_RAN_ST
#   [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm    config_id=CB009493_G3_ABIP_ASIM_AREA_AHEGC_AHHB
#   ${cell_info}   Get Cell Info With PCI    ${ALL_CELL_LIST}    185
#   ${required_cell}    Create List    ${cell_info}
#   RAT reset and make L3call    rat_type=LTE    required_cells=${required_cell}
#   [Teardown]    Testcase Basic Postcondition

#[1] Manual_SiSo_SM_NR_RAT_reset_for_concurrent
#    [Tags]    QC_654367    QCD_MN_RAN    QCP_RAN_ST
#    [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm    config_id=CB009493_G3_ABIP_ASIM_AREA_AHEGC_AHHB
#    ${cell_info}   Get Cell Info With PCI    ${ALL_CELL_LIST}    664
#    ${required_cell}    Create List    ${cell_info}
#    RAT reset and make L3call    rat_type=NR    required_cells=${required_cell}
#    [Teardown]    Testcase Basic Postcondition

[1][1] Common_SiSo_Call_Throughput_Measurements_UDP
    [Tags]    QC_33152  QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Tput    config_id=CB009493_G3_ABIP_ASIM_AREA_AHEGC_AHHB
    test_fv.Data Transfer    required_cells=170:176:179
    [Teardown]    Testcase Basic Postcondition

[1][1] General_SiSo_Online_Cell_Addition_Deletion
    [Setup]    Testcase Basic Precondition    case_name=cell_add_delete    config_id=CB009493_G3_ABIP_ASIM_AREA_AHEGC_AHHB
    [Tags]    QC_33151   QCD_MN_RAN   QCP_RAN_VRF
    General SISO Online Cell Addition Deletion    addition_deletion_cell=661:664    required_cells=670      repetition=1
    [Teardown]    Testcase Basic Postcondition

[1] Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Tags]    QC_33148    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    ...    config_id=CB009493_G3_ABIP_ASIM_AREA_AHEGC_AHHB
    Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Teardown]    Testcase Basic Postcondition


[1][1.0] Common_SiSo_State Management_Cell block_Then_RF reset_Then_Cell unblock
    [Tags]    QC_33146    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=CB009493_G3_ABIP_ASIM_AREA_AHEGC_AHHB
    Cell Block And Unblock All with rfreset    required_cells=660:668
    [Teardown]    Testcase Basic Postcondition


[1][1.0] Common_SiSo_State Management_Cell Block&unblock_Then_RF Lock&Unlock
    [Tags]    QC_33147    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=CB009014_ABIP_ASIM_AREA_AHEGC_AHHB
    Cell Block And Unblock All    required_cells=672:680
    Append To List    ${GLO_ADMIN_ALLOWED_ALARM}    Cell blocked
    Ru lock And Unlock All    required_cells=672:680
    [Teardown]    Testcase Basic Postcondition

#[2][1] Common_SiSo_State Management_Cell_Block_Unblock
 #   [Tags]    QC_654378   QCD_MN_RAN   QCP_RAN_ST
  #  [Setup]    Testcase Basic Precondition    case_name=Cell_Block    config_id=CB009014_ABIP_ASIM_AREA_AHEGC_AHHB
   # Modify vendor parameters of CB012528    bts_id=37039
    #Run Keyword And Ignore Error    Get And Check Reset Counter For All BTS Node
    #Cell Block And Unblock All      required_cells=675
    #[Teardown]    Testcase Basic Postcondition

[2][1] Common_SiSo_Recovery_RF_Module_Reset
    [Tags]    QC_33153   QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF_Reset    config_id=CB009014_ABIP_ASIM_AREA_AHEGC_AHHB
    Modify vendor parameters of CB012528    bts_id=37039
    Run Keyword And Ignore Error    Get And Check Reset Counter For All BTS Node
    SISO_Recovery RF module reset    required_cells=672    required_power_rfs=K9220611845
    [Teardown]    Testcase Basic Postcondition

[2][1] Manual_SiSo_SM_NR_RAT_reset_for_concurrent
    [Tags]    QC_33149    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm    config_id=CB009014_ABIP_ASIM_AREA_AHEGC_AHHB
    Modify vendor parameters of CB012528    bts_id=37039
    Run Keyword And Ignore Error    Get And Check Reset Counter For All BTS Node
    RAT reset from WebEm For NR testline        required_cells=680
    #${cell_info}   Get Cell Info With PCI    ${ALL_CELL_LIST}    680
    #${required_cell}    Create List    ${cell_info}
    #RAT reset and make L3call    rat_type=NR    required_cells=${required_cell}
    [Teardown]    Testcase Basic Postcondition

*** Keywords ***
Wait For GPS Self Check
    ${status}    Run Keyword And Return Status    Check Alarm Is Appear    37039    faultId=regex"4405|4420"
    Return From Keyword If    not ${status}
    ${status}    Wait For Complete
    Should Be True    ${status}

Wait For Complete
    FOR    ${i}    IN RANGE    ${20}
        ${gps_info}    coam.get_gps_status    connection=${CASE_NAME}_37039
        ${selfSurveyStatus}    Set Variable    ${gps_info["gnsse"][0]["parameters"]["selfSurveyStatus"]}
        Return From Keyword If    "${selfSurveyStatus}"=="Completed"    ${True}
        sleep    10 min
    END
    ${gps_info}    coam.get_gps_status    connection=${CASE_NAME}_37039
    ${selfSurveyStatus}    Set Variable    ${gps_info["gnsse"][0]["parameters"]["selfSurveyStatus"]}
    ${gnsse_distname}    Set Variable    ${gps_info["gnsse"][0]["id"]["internal"]}
    Run Keyword If    "${selfSurveyStatus}"=="In progress 99%"    coam.reset unit    ${gnsse_distname}    connection=${CASE_NAME}_37039
    sleep    5 min
    FOR    ${i}    IN RANGE    ${20}
        ${gps_info}    coam.get_gps_status    connection=${CASE_NAME}_37039
        ${selfSurveyStatus}    Set Variable    ${gps_info["gnsse"][0]["parameters"]["selfSurveyStatus"]}
        Return From Keyword If    "${selfSurveyStatus}"=="Completed"    ${True}
        sleep    10 min
    END
    Return From Keyword    ${False}

Testcase Precondition With GPS Check
    [Arguments]    ${case_name}    ${config_id}=${EMPTY}    ${force_recommission}=${False}
    Close Multi Node Process
    Set Test Variable    ${CASE_NAME}    ${case_name}
    Set TC Dir Path
    Create Nodes Parameters Init    ${config_id}    force=False
    Update Qc Id Tag
    Run Keyword If    "${${CURRENT_CONFIG_ID}.site_mode}"!="4G"    Run Keyword And Ignore Error
    ...    Get Resource Usage Setup    aashell_name=aashell
    Logging Multinode Start    ${TEST_LOGS_DIR_PATH}/setup
    ${out_SAS_SIM_config}    Run Keyword And Return Status    Variable Should Exist    ${tl_config.SAS_SIM}
    ${out_need_SAS_SIM}    Set Variable If     ${out_SAS_SIM_config}      ${tl_config.SAS_SIM}    False
    Run Keyword If     "${out_need_SAS_SIM}"=="True"    Run Keywords    Restart SAS Simulator
    ...    AND    Sleep    2 min
    Log Dictionary    ${NODE_CFG}
    Change Testline Configuration    ${config_id}    force_recommission=${force_recommission}
    ${status}    Run Keyword If    "${NOT_COMMISSIONED}"=="True"    Run Keyword And Return Status    Verify All Cells OnAir
    ${status}    Run Keyword And Return Status    Run Keyword If    "${NOT_COMMISSIONED}"=="True" and "${status}" == "False"
    ...    Reset BTS Until Onair    timeout=${ONAIR_TIME}
    ...    ELSE IF    "${NOT_COMMISSIONED}"=="False"    Run Keywords    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
    ...    AND    Check Default Value Of Parameter
    Run Keyword If    not ${status}    Run Keywords    Wait For GPS Self Check
    ...    AND    Check All Cells OnAir
    Check Multinode Without Unexpect Alarm
    [Teardown]    Run Keyword If    "${KEYWORD STATUS}"=="PASS"    Run Keywords
    ...    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}/setup/
    ...    AND    Logging Multinode Start
    ...    AND    Logging Gnb Admin Start
    ...    AND    Get And Check Reset Counter For All BTS Node

