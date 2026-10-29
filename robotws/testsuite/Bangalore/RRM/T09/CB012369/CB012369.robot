*** Settings ***
Force Tags        CLOUD_5G_I_LOO_AP_LOOO    VARIANVARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
...               5G_RAN     SBTS00    CONFIGURED


Documentation
...
...  AUTHOR          :   mary.thomas@nokia.com
...  MAINTAINER      :   mary.thomas@nokia.com
...  INTRODUCTION    :   CB012369-SR ARP-based DSCP marking
...  TEST SET NAME   :   CB012369_NSA_SA_call
...  REFERENCES      :   CB012369-CFAM


Resource         ../CB012369/resources/CB012369_resource.robot

*** Variables ***
${wts_cfg_file}       ${CURDIR}/config/egate_TMOUS.cfg
${WTS_DIR}            /opt/iphy/latest
&{WTS}                Ip=127.0.0.1        Username=ute         Connection=Wts
${gw_ID}           1
${trf_id}          1
${QFI_ID}          1
${UE_ID}           1
${start_ueid}      1
${end_ueid}        2
${nwslice_ID}      1
${Pdu_session_ID}  1
${exp_dscp}        12
${NSA_UE_ID_1}     0
${NSA_UE_ID_51}    51

*** Test Cases ***

[1]CB012369-B_B01_TC18_DSCP marking during SgNB addition and modification_NSA
    [Documentation]    This scenario covers online modification of feature and NSA and SA L3 call with DSCP validation.
    ...   Three UEs are tested on single TDD cell - 2 SA and 1 NSA
    [Tags]     TC01
    [Setup]    Run keywords      Suite setup from scratch
    ...                 AND      Check gNB Bulid
    ...                 AND      5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Conf_scf.json
    ...                 AND      Load CFG and verify cell status   ${wts_cfg_file}    1    2
    ${LOG_PATH}  Set Variable  ${LOG_PATH}/${TEST_NAME}
    log to console   Suite setup successful ...
    Attach UE and validate DSCP value    ${start_ueid}  ${NSA_UE_ID_1}   ${exp_dscp}
    5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_DSCPPR.json
    Attach UE and validate DSCP value    ${end_ueid}   ${NSA_UE_ID_51}    44
    sleep    30s
    Validate DL and UL data transfer    ${start_ueid}    ${end_ueid}    ${NSA_UE_ID_51}
    wts_sim_keywords.MultiUE Deregister should be Successful    ${start_ueid}     ${end_ueid}
    NSA UE Detach should be Successful    ${NSA_UE_ID_51}
    [Teardown]   Run Keyword   wts_sim_keywords.Clean edaemon and egate

