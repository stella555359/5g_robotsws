*** Settings ***
Documentation    Suite description
...    Author:    Wu Amy;Sheng Haoyun-Lyle;Zhou Qiang;Lou Xingxin;Ding Lisa;Wu Nick
...    Maintainer:    Wu Amy;Sheng Haoyun-Lyle;Zhou Qiang;Lou Xingxin;Ding Lisa;Wu Nick

Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot
Resource    ../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Variables   ./env.py

*** Variables ***
${related_paras}    [{"dist_name":"xxxx","para_name":"xxxx","para_value":"xxx"}]
${parameters}    [{"dist_name":"xxxx","para_name":"full name not abbr","para_value":"xxx","require_reset":"site_reset"},
...    {"dist_name":"xxxx","para_name":"xxxx","para_value":"xxx","related_paras":${related_paras},
...    "require_reset":"rat_reset"},{"dist_name":"xxxx","para_name":"xxxx","para_value":"xxx","require_reset":"online"}]

#FOR UUF KPI
${INIT_SW_VERSION}    {'11193': 'SBTS22R2_ENB_0000_001771_000001'}
${TARGET_SW_VERSION}    {'11193': 'SBTS22R4_ENB_0000_000094_000000'}
${MIDDLE_SW_VERSION}   {'11193': 'SBTS22R3_ENB_0000_002023_000000'}
${RB_TO_TARGET}    YES    #YES|NO Rollback to UUF target build to run other cases
#${YAFT}    NO
${PKG_TYPE}    Normal
${loop}    ${5}
${SA_OR_NSA}
${TDD_OR_FDD}    FDD
${RU}    3FXED+3FRPA+3FZNI+3FRHF+3FRGT
${HW_ID}    3FSMF+4FBBC+2FBBA+3FXED+3FRPA+3FZNI+3FRHF+3FRGT
${TOP50}                             True    #True: reporting result to scout
${GLO_SCOUT_TESTLINE_NAME}    1_5_UTE5G073
#${GLO_PERFORM_SAVE_LOG}              FAIL    # possible settings: FAIL, ALWAYS, NONE
${uptime}    00:17:06.463300

${parameters1}    [{'dist_name':'MRBTS-10059/EQM-1/HWTOP-1/CABLINK-1','para_name':'linkSpeed',
...    'para_value':'Cpri7','reset_tag':'site_reset'}]

${parameters2}    [{'dist_name':'MRBTS-10059/EQM-1/HWTOP-1/CABLINK-1','para_name':'linkSpeed',
...    'para_value':'Auto','reset_tag':'site_reset'}]

*** Test Cases ***
[1.0] OAM_KPI_L3call
    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=5G_CB007409_UHIE_3_Cell
    OAM KPI L3Call
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Calculate KPI_16
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=5880
    Cell Lock And Unlock KPI_16
    [Teardown]    Testcase Basic Postcondition

[1][1.0] RFM Reset KPI51
    [Setup]    Testcase Basic Precondition    case_name=rf_reset_kpi
    RFM Reset KPI51
    [Teardown]    Testcase Basic Postcondition

SISO Delta Commissioning Kpi
    [Setup]    Testcase Basic Precondition    case_name=Recommissioning
    FOR    ${num}    IN RANGE    ${3}
        Delta Commissioning Kpi For SISO3    ${parameters1}
        Delta Commissioning Kpi For SISO3    ${parameters2}
    END
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_Recovery_BTS SiteReset
    [Tags]    QC_248333    QCD_MN_RAN    QCP_RAN_ST
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    [Setup]    Testcase Basic Precondition    case_name=siteResetRemoveHwBin    config_id=5G_BTS11193
    Reset With Remove HWBIN KPI1
    [Teardown]    Testcase KPI postcondition    CaseType=RESET


[1][1.1] General_SiSo_Auto_Automatic_RAT_SW_upgrade
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    [Tags]    QC_300822    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase UUF Precondition    case_name=UUF_kpi    config_id=5G_BTS11193
    SW Upgrade And RollBack KPI2    L3Call=YES  # L3Call=YES|NO  #default is NO
    [Teardown]    Testcase KPI postcondition

[1][1.0] BBMOD_Reset_KPI5
    [Setup]    Testcase Basic Precondition    case_name=BBMOD_Reset
    BBMOD Reset KPI5    test_loops=${10}
    [Teardown]    Testcase Basic Postcondition

# ${MIDDLE_SW_VERSION}
# ${loop}    ${5}
[1][1.1] General_SiSo_Auto_Automatic_RAT_SW_upgrade_Stability
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    [Tags]    QC_300822    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase UUF Precondition    case_name=UUF_kpi    config_id=5G_BTS11193
    SW Upgrade And RollBack KPI2    recover=NO
    FOR    ${i}    IN RANGE    ${1}    ${loop}
        SW Upgrade And RollBack KPI2    rollback=NO    target_builds=${MIDDLE_SW_VERSION}
        ${index}    Evaluate    ${i} + 1
        Run Keyword IF    "${index}"!="${loop}"    SW Upgrade And RollBack KPI2    recover=NO
        Run Keyword IF    "${index}"=="${loop}"    SW Upgrade And RollBack KPI2    recover=YES
    END
    [Teardown]    Testcase KPI postcondition
