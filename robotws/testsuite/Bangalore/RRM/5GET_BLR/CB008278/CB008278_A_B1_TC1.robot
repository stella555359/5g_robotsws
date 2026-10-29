*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED
#...             CONFIGS_Bangalore/RRM/ET/CB008278/8278_A_B1_TC1.yaml

Resource         ../CB007145/resources/common/CB007145_Resource.robot
Resource         ../resources/robot/common_log_collection.robot
Library          ta5g_pm_counters

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Prepare TL with all config files
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...             author:            Manasa
...             maintainer:        manasa.shankarappa@nokia.com
...
...             INTRODUCTION:     NSA data call on 10MHZ TDD with CB006878 enable and disable
...             TEST SET NAME:    CB008278-A Basic 10 MHz support for CHILE AEHC
...             TESTING SPLIT:    Refer CB008278 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008278 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_18760



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_10MHz.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${nsa_ue_id1}      ${11}
${nsa_ue_id2}      ${12}

${SCFC}     SCF_8278_A_B1_TC1.xml
${AP_XML}   ${CURDIR}/config/IPHY_8278_A_B1_TC1.xml

${delta_file_name}   srsUePeriodicity.json

*** Test Cases ***
[1]CB008278_A#B1_TC1_10MHz_AEHC_NSA_Call_With_UL_And_DL_Peak_Throughput
    [Tags]   QC_301659
    set test variable      ${LOG_PATH}
    Wait Until Keyword Succeeds    20x    10s    Check MIB_SIB status of GNB cell    ${1}
    Wait Until Keyword Succeeds    20x    10s    Check MIB_SIB status of GNB cell    ${2}
    X2AP Link Should be UP
#   Added counter M55601C01002 check for change in srsueperiodicity leads to cell lock and unlock.
#   This technical forum discussion improvement
    Wait until the next Measurement Period starts
    Perform SCF Delta Commissioning with ${delta_file_name}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55601C01002  1  NR_CELL_PLAN_UNAVAIL_CHNG_TO
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${1}
    ...  file_path=${pm_counter_file}
       Verify Any Counters In File
    ...  M55601C01002  1  NR_CELL_PLAN_UNAVAIL_CHNG_TO
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${2}
    ...  file_path=${pm_counter_file}
    log to console   "UE attach trigerring now"
#    #Step 1. Attach NSA UE-11 on cell-1 6878 disable , UE-12 on cell-2 6878 enables
    MultiUE Attach for NSA on diff cell   ${nsa_ue_id1}    ${nsa_ue_id2}
    MultiUE DL Traffic Start for NSA    ${nsa_ue_id1}    ${nsa_ue_id2}    mbps    150    id=2    trf_id=1
    MultiUE UL Traffic Start for NSA    ${nsa_ue_id1}    ${nsa_ue_id2}    mbps    50    id=2    trf_id=1
    sleep   60s
    MultiUE Validate UL Traffic For NSA     ${nsa_ue_id1}     ${nsa_ue_id1}     2       5
    MultiUE Validate UL Traffic For NSA     ${nsa_ue_id2}     ${nsa_ue_id2}     2       6
    MultiUE Validate DL Traffic For NSA     ${nsa_ue_id1}     ${nsa_ue_id2}     2       115
    Validate UL Traffic For NSA between UEs     ${nsa_ue_id1}     ${nsa_ue_id2}   2
    MultiUE DL Traffic Stop for NSA    ${nsa_ue_id1}    ${nsa_ue_id2}    2    1
    MultiUE UL Traffic Stop for NSA    ${nsa_ue_id1}    ${nsa_ue_id2}    2    1
    MultiUE Detach for NSA    ${nsa_ue_id1}    ${nsa_ue_id2}
    [Teardown]  Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Validate UL Traffic For NSA between UEs
    [Arguments]    ${ue_id_1}    ${ue_id_2}     ${Bearer_ID}
    wtsrunner.bearer_stats  ue=${ue_id_1}   id=${Bearer_ID}   dir=ul
    ${bearer_stat_ul_1}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    ${avg_bearer_stat_ul_1}=   Get Regexp Matches    ${bearer_stat_ul_1}    Average data rate +(\\d+)    1
    wtsrunner.bearer_stats  ue=${ue_id_2}   id=${Bearer_ID}   dir=ul
    ${bearer_stat_ul_2}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    ${avg_bearer_stat_ul_2}=   Get Regexp Matches    ${bearer_stat_ul_2}    Average data rate +(\\d+)    1
    ${result}         Evaluate    ${avg_bearer_stat_ul_2} > ${avg_bearer_stat_ul_1}
    Run Keyword if    ${result}
    ...     Log Many    ${ue_id_2} with 6878 enable data throughput is greater than ${ue_id_1} with 6878 disable
    ...     Else
    ...     Log Many    ${ue_id_2} with 6878 enable data throughput is not greater than ${ue_id_1} with 6878 disable
    Run Keyword and Continue on Failure     Should Be True    ${result}


MultiUE Attach for NSA on diff cell
    [Arguments]    ${start_ue_id}    ${stop_ue_id}
    ${cell_id}     Set Variable    1
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    LTE Attach should be Successful    ${ue_id}
    UE Attach should be Successful on cell   ${ue_id}    ${cell_id}
    ${cell_id}     Evaluate     ${cell_id} + 1
    END


UE Attach should be Successful on cell
    [Arguments]    ${NSA_UE_ID}        ${Target_Cells}
    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Target_Cells}    ue=${NSA_UE_ID}
    ...                         bearer=${Bearer_ID}    type=split_scg
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
    [Return]      ${output}
