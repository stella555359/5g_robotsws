*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks

Resource    resources/CB008933-common_keywords.robot
Library     resources/counters_verifiers.py

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB010471/2_AWEUA_4_cells_SANSA_TDD.xml.yaml

Suite Setup     Run Keywords
...             Run setup
...     AND     Enable internal mirroring for alias  gNB2

Suite Teardown    Run Suite Teardown

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_4c_n257_TDD_SANSA.lua
${SCFC}=                  ${CURDIR}/../../../../../custom-config/Krakow/CB008933/scfc_2_AWEUA_4_cells_SANSA_TDD.xml
${AP_XML}=                ${CURDIR}/../../../../../custom-config/Krakow/CB008933/iphy_2_AWEUA_4_cells_SANSA_TDD.xml
${SKIP_COUNTERS}=         ${FALSE}
${rtpm}=                  ${FALSE}

*** Test Cases ***
CB008933 Setup env
    [Tags]    setup
    no operation
CB008933 NSA counters
    [Tags]    test
#    [Setup]  Prepare test environment CB008933

   start collecting counters

    Attach UE16 to simulated eNB1 CELL-1
    Attach UE17 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE16 with NRCELL_3 on gNB2
    Trigger SgnbAddition procedure for UE17 with NRCELL_3 on gNB2

    Run 5Mbps UL and DL traffic on split bearer for UE16 and wait 30 seconds
    Run 5Mbps UL and DL traffic on split bearer for UE17 and wait 30 seconds

    Stop 5Mbps UL and DL traffic on split bearer for UE16
    Stop 5Mbps UL and DL traffic on split bearer for UE17

    UE16 detach
    UE17 detach

    Attach UE1 to gNB2 CELL1 with ICS during PDU session setup
    Attach UE2 to gNB2 CELL1 with ICS during PDU session setup

    Run 5Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 30 seconds
    Run 5Mbps UL and DL traffic on UE2 PDU1 QFI1 and wait 30 seconds

    Stop 5Mbps UL and DL traffic on UE1 PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE2 PDU1 QFI1

    Trigger UE1 to send deregister request
    Trigger UE2 to send deregister request

    Wait until aggreagted PM counters file is ready and saved

    Check Counter with error M55353C01001 UL_RLC_TIME_UE_TPUT_PMQAP for NRCELL-1 is in range 70000-90000 on pmqap-1 profile    #OK
    Check Counter with error M55352C00001 DL_PDCP_TIME_UE_TPUT_PMQAP for NRCELL-1 is in range 13000-15000 on pmqap-1 profile    #OK
    Check Counter with error M55352C01001 DL_PDCP_VOL_UE_TPUT_PMQAP for NRCELL-1 is in range 270000-290000 on pmqap-1 profile    #OK
    Check Counter with error M55352C02002 UL_PDCP_SDU_LOST_CU_PMQAP for NRCELL-1 has value 0 on pmqap-1 profile
#    #---------------------------------------------------------------------------------------------
    Check Counter with error M55160C00001 AVE_NUMBER_OF_NSA_USERS_PMQAP for NRCELL-1 has value 600 on pmqap-1 profile    #OK
    Check Counter with error M55160C00002 AVE_NUM_NSA_USERS_DENOM_PMQAP for NRCELL-1 has value 300 on pmqap-1 profile    #OK
    Check Counter with error M55160C00003 PEAK_NUMBER_OF_NSA_USERS_PMQAP for NRCELL-1 has value 2 on pmqap-1 profile    #OK
    Check Counter with error M55161C00001 AVE_NUMBER_OF_SA_RRC_PMQAP for NRCELL-1 has value 600 on pmqap-1 profile    #OK
    Check Counter with error M55161C00002 AVE_NUMB_OF_SA_RRC_DENOM_PMQAP for NRCELL-1 has value 300 on pmqap-1 profile    #OK
    Check Counter with error M55161C00003 PEAK_NUMB_OF_SA_RRC_USER_PMQAP for NRCELL-1 has value 2 on pmqap-1 profile    #OK
    Check Counter with error M55162C00001 NX2CC_RAB_REL_ATT_MENB_PMQAP for NRCELL-1 has value 2 on pmqap-1 profile    #OK
    Check Counter with error M55162C00002 NX2CC_RAB_REL_NORM_MENB_PMQAP for NRCELL-1 has value 0 on pmqap-1 profile
    Check Counter with error M55162C00003 NX2CC_RAB_REL_ABNOR_MENB_PMQAP for NRCELL-1 has value 2 on pmqap-1 profile    #OK
    Check Counter with error M55162C00004 NX2CC_RAB_REL_ATT_SGNB_PMQAP for NRCELL-1 has value 0 on pmqap-1 profile
    Check Counter with error M55162C00005 NX2CC_RAB_REL_NORM_SGNB_PMQAP for NRCELL-1 has value 0 on pmqap-1 profile
    Check Counter with error M55162C00006 NX2CC_RAB_REL_ABNOR_SGNB_PMQAP for NRCELL-1 has value 0 on pmqap-1 profile
    Check Counter with error M55162C00007 NX2CC_RAB_SETUP_ATT_PMQAP for NRCELL-1 has value 2 on pmqap-1 profile    #OK
    Check Counter with error M55162C00008 NX2CC_RAB_SETUP_ACK_PMQAP for NRCELL-1 has value 2 on pmqap-1 profile    #OK
    Check Counter with error M55162C00009 NX2CC_RAB_SETUP_SN_PMQAP for NRCELL-1 has value 2 on pmqap-1 profile    #OK
    Check Counter with error M55163C00001 NG_FLOW_SETUP_ATT_TOT_PMQAP for NRCELL-1 has value 2 on pmqap-1 profile    #OK
    Check Counter with error M55163C00002 NG_FLOW_SETUP_SUCC_PMQAP for NRCELL-1 has value 2 on pmqap-1 profile    #OK
    Check Counter with error M55163C00003 NG_FLOW_REL_PMQAP for NRCELL-1 has value 2 on pmqap-1 profile    #OK
    Check Counter with error M55163C00004 NG_FLOW_REL_NORMAL_PMQAP for NRCELL-1 has value 2 on pmqap-1 profile    #OK
#    #---------------------------------------------------------------------------------------------
    Check Counter with error M55356C00000 ACC_UE_DL_DRB_DATA_PMQAP for NRCELL-1 is in range 60000-80000 on pmqap-1 profile    #OK
    Check Counter with error M55356C00001 ACC_UE_UL_DRB_DATA_PMQAP for NRCELL-1 is in range 160000-180000 on pmqap-1 profile    #OK
    Check Counter with error M55356C00002 MAX_UE_DL_DRB_DATA_PMQAP for NRCELL-1 has value 2 on pmqap-1 profile    #OK
    Check Counter with error M55356C00003 MAX_UE_UL_DRB_DATA_PMQAP for NRCELL-1 has value 2 on pmqap-1 profile    #OK
    Check Counter with error M55363C00001 DL_PRB_USED_DATA_PMQAP for NRCELL-1 is in range 80000-1200000 on pmqap-1 profile    #OK
    Check Counter with error M55363C00002 UL_PRB_USED_DATA_PMQAP for NRCELL-1 is in range 200000-2500000 on pmqap-1 profile    #KO
    Check Counter with error M55363C00003 DL_PRB_UTIL_SLOT_MAX_PMQAP for NRCELL-1 has value 40 on pmqap-1 profile    #OK WHY?
    Check Counter with error M55363C00004 UL_PRB_UTIL_SLOT_MAX_PMQAP for NRCELL-1 has value 100 on pmqap-1 profile    #OK WHY?

#    [Teardown]  Cleanup after test CB008933


*** Keywords ***
#Check Counter ${counter} ${name} for ${object} has value ${value} on pmqap-${pmqap} profile
#    verify_if_latest_pm_counter_has_exact_value    ${counter}    ${value}    PLMN-PLMN/MRBTS-1/NRBTS-1/${object}    ${PM_COUNTERS}    ${pmqap}

Check Counter with error ${counter} ${name} for ${object} has value ${value} on pmqap-${pmqap} profile
    Run keyword and ignore error    verify_if_latest_pm_counter_has_exact_value
    ...     ${counter}
    ...     ${value}
    ...     PLMN-PLMN/MRBTS-1/NRBTS-1/${object}
    ...     ${PM_COUNTERS}
    ...     ${pmqap}

UE${ue_id} detach
    Execute egate command  cmd=ue_detach id=${ue_id}

#Check Counter ${counter} ${name} for ${object} is in range ${low:\d+}-${high:\d+} on pmqap-${pmqap} profile
#    verify_that_pm_counter_is_in_range    ${counter}    PLMN-PLMN/MRBTS-1/NRBTS-1/${object}    ${PM_COUNTERS}   ${low}    ${high}    ${pmqap}

Check Counter with error ${counter} ${name} for ${object} is in range ${low:\d+}-${high:\d+} on pmqap-${pmqap} profile
    Run keyword and ignore error    verify_that_pm_counter_is_in_range
    ...     ${counter}
    ...     PLMN-PLMN/MRBTS-1/NRBTS-1/${object}
    ...     ${PM_COUNTERS}
    ...     ${low}
    ...     ${high}
    ...     ${pmqap}
