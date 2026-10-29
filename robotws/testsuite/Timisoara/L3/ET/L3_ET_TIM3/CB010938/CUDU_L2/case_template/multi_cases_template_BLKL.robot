*** Settings ***
Documentation     Resource for ET env
## Please put this file to ../../CB006086 to excute
Suite Setup       Run Keywords    Suite Setup For Common Setting    #iphy_file=${iphy_file}
...               AND    Suite Setup Copy WTS Config Files From QT
# Suite Setup     Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF_602}    iphy_file=${IPHY_FILE_602}    swconfig_param=${SWCONFIG_PARAM}
# Suite Setup     Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCFC_601}    iphy_file=${IPHY_XML_601}    swconfig_param=${SWCONFIG_PARAM}
# ...             AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_601}
Suite Teardown    Common Suite Teardown    debug
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown    debug
Resource        ../../CUDU_L2/common_setup_teardown.robot
# Resource          Resource/keyword.robot
Force Tags        CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD

*** Variables ***
@{LOG_NAME_LIST}                  ${empty}
@{LOG_NAME_SUITE_SETUP}           ${empty}
@{LOG_NAME_SUITE_TEARDOWN}        ${empty}
${SCF_PATH}                       ${CURDIR}/Config
${WTS_DIR}                        /opt/wts/latest
${EGATE_FILE}                     /opt/iphy/latest/egate_console.log
${WTS_LOCAL}                      ${CURDIR}/Resources/wts
${UE_ID}                          1
${PROFILE_ID}                     1
${SWCONFIG_PARAM}                 0x590021=0
${DELTA_FILE}                     Delta_conf.json
${RECOV_FILE}                     Delta_recov.json
#CB006086_ET_001
${UE_NR_CAP_2PORTS_1LAYER_FDD}    E1201000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C45008
...                               0A61000A0F88DAC31B47498A823F96525CA01105B260901831E31FF9863CA16070387808
...                               9C0270000841808DC9A1F00E41000000A41000002A41000004A494000069807C0DBCA9BC
...                               0CADD200A0800004B29282000032CA4A0800014B29282000072CA4A0800024B292920000
...                               AA5949405D039BA553740E66954CD2A98AECC0107801A0100800000080
#CB006086_ET_002
${SRB3_CONF}                      Delta_conf_srb3.json
${SRB3_RECOV}                     Delta_recov_srb3.json
@{UE_NR_CAPABILITIES_PATT}        ue_nr_capabilities=[0-9a-zA-Z]+    ue_eutra_nr_capabilities=[0-9a-zA-Z]+
${UE_NR_CAP_FDD}                  E1201000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C45008
...                               0A61000A0F88DAC31B47498A823F96595CA01105B260901831E31FF9863CA16070387808
...                               9C0270000841808DC9A1F00E41000000A41000002A41000004A494000069807C0DBCA9BC
...                               0CADD200A0800004B2CA82000032CB2A0800014B2CA82000072CB2A0800024B2CA920000
...                               AA5965405D03BBA557740EE6955CD2AB8AEDC0107801A0100800000080
${UE_EUTRA_NR_CAP_FDD}            A10181102C0C0388C000000888160641C460000024400401C0463002100008040401803080008020200C0180
@{UE_NR_CAPABILITIES_VAL}         ue_nr_capabilities=${UE_NR_CAP_FDD}    ue_eutra_nr_capabilities=${UE_EUTRA_NR_CAP_FDD}
@{CIPHER_OLD_PARAMS}              eia=null\\+snow3g\\+aes eea=null
@{CIPHER_NEW_PARAMS}              nia=aes nea=aes
#CB006086_ET_003
${GNB_ID}                         2
${CELL_ID}                        1
${BEARER_ID}                      2

*** Test Cases ***
CB006086_ET_001
    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${DELTA_FILE}
    ...    AND    Suite Setup Start WTS And Check OnAir
    ...    AND    Get Default Ue Capabilities
    ${UE_ID}=    Set Variable If    "${gnbcutype}"=="SANSA"    11    ${UE_ID}
    Set Suite Variable    ${UE_ID}    ${UE_ID}
    ${UE_NR_CAP_2PORTS_1LAYER_FDD}    String.Replace String    ${UE_NR_CAP_2PORTS_1LAYER_FDD}    ${SPACE}    ${EMPTY}
    NSA NR UE Param Set    ${UE_ID}    ${UE_NR_CAP_2PORTS_1LAYER_FDD}
    NSA LTE Attach    ${UE_ID}    #${PROFILE_ID}
    [Teardown]    Test Teardown Recover Env    mode=debug    scf_file=${RECOV_FILE}

CB006086_ET_002
    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${SRB3_CONF}    swconfig_param=${SWCONFIG_PARAM}
    ...    AND    Modify UE Capabilities In CFG    ${WTS_DIR}/${wts_cfg}    ${ue_nr_capabilities_patt}    ${ue_nr_capabilities_val}
    ...    AND    Modify Text File    ${WTS_DIR}/${wts_cfg}    ${cipher_old_params}    ${cipher_new_params}
    ...    AND    Suite Setup Start WTS And Check OnAir
    ...    AND    Get Default Ue Capabilities
    ${UE_ID}=    Set Variable If    "${gnbcutype}"=="SANSA"    11    ${UE_ID}
    Set Suite Variable    ${UE_ID}    ${UE_ID}
    NSA LTE Attach    ${UE_ID}    #${PROFILE_ID}
    Add Scell Range To NSA
    [Teardown]    Test Teardown Recover Env    mode=debug    scf_file=${SRB3_RECOV}    GNB_swconfig_file=${gnb_swconfig_test_bak_file}

CB006086_ET_003
    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${DELTA_FILE}    swconfig_param=${SWCONFIG_PARAM}
    ...    AND    Suite Setup Start WTS And Check OnAir
    ...    AND    Get Default Ue Capabilities
    ${UE_ID}=    Set Variable If    "${gnbcutype}"=="SANSA"    11    ${UE_ID}
    Set Suite Variable    ${UE_ID}    ${UE_ID}
    NSA LTE Attach    ${UE_ID}    #${PROFILE_ID}
    Add Scell Range To NSA
    NSA 5G Attach    ${UE_ID}    ${gnb_id}    ${cell_id}    ${BEARER_ID}
    [Teardown]    Test Teardown Recover Env    mode=debug    scf_file=${RECOV_FILE}    GNB_swconfig_file=${gnb_swconfig_test_bak_file}
# TC1
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${scf_file}    vendor_change_list=${vendor_change_list}
#    ...    iphy_file=${iphy_file}    swconfig_param=${SWCONFIG_PARAM}    swconfig_param_AP=${swconfig_param_ap}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=$
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    SA Multi UE Attach With Scell Blind Addition    ${3cc_ue_list}    ${3cc_scell_physicalid_list}    3
#    SA Multi UE Start DL And UL Traffic    ${3cc_ue_list}    ${dl_data}    ${ul_data}
#    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}    vendor_file=${vendor_test_bak_file}
#    ...    iphy_file=${iphy_test_bak_file}    GNB_swconfig_file=${gnb_swconfig_test_bak_file}    AP_swconfig_file}=${ap_swconfig_test_bak_file}
*** Keywords ***
Get Default Ue Capabilities
    [Documentation]    This keyword is to get default ue_nr_capabilities and ue_eutra_nr_capabilities values.
    ...    And set the value as suite variables ${default_nr_capabilities} and ${default_eutra_nr_capabilities}.
    ...
    ...    Examples:
    ...    | Get Default Ue Capabilities |
    ...    | Log To Console | ${default_nr_capabilities} |
    ...    | Log To Console | ${default_eutra_nr_capabilities} |
    ...
    ${nr_capabilities_reg}    Set Variable    ue_nr_capabilities\=([0-9A-Za-z]+)
    ${eutra_nr_capabilities_reg}    Set Variable    ue_eutra_nr_capabilities\=([0-9A-Za-z]+)
    ${content}    OperatingSystem.Get File    ${wts_dir}/${wts_cfg}
    ${nr_capabilities}    String.Get Regexp Matches    ${content}    ${nr_capabilities_reg}    1
    Should Not Be Empty    ${nr_capabilities}
    ${eutra_nr_capabilities}    String.Get Regexp Matches    ${content}    ${eutra_nr_capabilities_reg}    1
    Should Not Be Empty    ${eutra_nr_capabilities}
    Set Suite Variable    ${default_nr_capabilities}    ${nr_capabilities[0]}
    Set Suite Variable    ${default_eutra_nr_capabilities}    ${eutra_nr_capabilities[0]}

NSA NR UE Param Set
    [Arguments]    ${ue_id}    ${ue_nr_cap}
    [Documentation]    This keyword is used to set UE NR capability before NSA L3 Call on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | ue_nr_cap | Yes | ue_nr_cap |
    ...    Example:
    ...    | NSA NR UE Param Set | 1 | 01000000010800040004D100018000000BC00000000000008A8000100000000010010AAC |
    Log To Console    set UE NR capability...
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_param id\=${ue_id} ue_nr_capabilities\=${ue_nr_cap}
    Log To Console    set_UE_NR_capability_is_ok
    Sleep    3s    reason=wait ue set nr capability is stable

Add Scell Range To NSA
    Log To Console    add scell range to NSA...
    ute_wtssim.Execute Egate Command
    ...    cmd=enb_endc_param id=1 serving_cell_index_range_scg=5:31
