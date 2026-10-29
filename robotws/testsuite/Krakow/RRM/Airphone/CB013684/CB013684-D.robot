*** Settings ***
Documentation
...        maintainer:   Lukasz Kordula
...        contact:      lukasz.kordula@nokia.com
...        authors:      Karol Rybak, Lukasz Kordula
...        description:  Test Cases for CB013684-D

Resource    ./resources/CB013684_KW.robot
Library      ./resources/CB013684_resources.py         WITH NAME    local_resources

Suite Setup  Prepare suite environment  egate_config=${lua_cfg_file}  scfc=${scfc}  x2=True
#Suite Setup    Custom Suite Setup    # For manual run with already active egate
Suite Teardown  Clean suite environment

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_LO_AP_LO

*** Variables ***
${lua_cfg_file}=  ${CONF_DIR}/basic_setup.cfg
${scfc}=  ${CONF_DIR}/scfc_D.xml
${MO_ID}    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
@{counters_to_check}    M55306C00001    M55306C00002    M55306C00003    M55306C00004    M55306C00005    M55306C00006
...    M55306C00007    M55306C00008    M55306C00009    M55306C00010    M55306C00011    M55306C00012    M55306C00013
...    M55306C00014    M55306C00015    M55306C00016    M55306C00017    M55306C00018    M55306C00019    M55306C00020
...    M55306C00021    M55306C00022    M55306C00023    M55306C00024    M55306C00025    M55306C00026    M55306C00027
...    M55306C00028    M55306C00029    M55306C00030    M55306C00031    M55306C00032    M55306C00033    M55306C00034
...    M55306C00035    M55306C00036    M55306C00037    M55306C00038    M55306C00039    M55306C00040    M55306C00041
...    M55306C00042    M55306C00043    M55306C00044    M55306C00045    M55306C00046    M55306C00047    M55306C00048
...    M55306C00049    M55306C00050    M55306C00051    M55306C00052    M55306C00053    M55306C00054    M55306C00055
...    M55306C00056    M55306C00057    M55306C00058    M55306C00059    M55306C00060    M55306C00061    M55306C00062
...    M55306C00063    M55306C00064

*** Test Cases ***
CB013684_D_CFRA_reattempt
    Wait For Next Full Pm Interval

    Attach UE SA  ue_id_first=1    num_of_ues=1
    Activate missed rach testmodel  ue_id_first=1    num_of_ues=1
    Send meas A3

    ${pm_counters}=  Wait for next pm interval and get counters
    ${CFRA_COMP_SSBPM}  ta5g_pm_counters.get_pm_counter_value   M55202C00002   PLMN-PLMN/SSBPM-0   ${pm_counters}
    Should be Equal  ${CFRA_COMP_SSBPM}[1]   ${1}
    Log to Console    CFRA_COMP_SSBPM -->${CFRA_COMP_SSBPM}[1]

    ${CFRA_ATT_DED_PRMBL_SSBPM}  ta5g_pm_counters.get_pm_counter_value   M55202C00001   PLMN-PLMN/SSBPM-0   ${pm_counters}
    Should be Equal  ${CFRA_ATT_DED_PRMBL_SSBPM}[1]   ${6}
    Log to Console    CFRA_ATT_DED_PRMBL_SSBPM -->${CFRA_ATT_DED_PRMBL_SSBPM}[1]

    Detach UE SA  ue_id_first=1    num_of_ues=1
    [Teardown]    Custom Test Teardown    delta=${false}

CB013684_D_SA_CBRA_success_rate_counter_retransmission_unsuccesful
    Wait For Next Full Pm Interval

    Activate msg3 retx testmodel  ue_id_first=2    num_of_ues=1
    Attach UE SA  ue_id_first=2    num_of_ues=1

    ${pm_counters}=  Wait for next pm interval and get counters
    Log to Console    Values of RA_ATT_CONT_A_PRMBL_SSB_00 - RA_ATT_CONT_A_PRMBL_SSB_63:
    ${c_sum}    Get sum of counters    ${pm_counters}    ${MO_ID}     @{counters_to_check}
    ${SSB_00_val}    ta5g_pm_counters.get_pm_counter_value    counter=M55306C00001    localmoid=${MO_ID}    filepath=${pm_counters}
    run keyword and continue on failure    local_resources.check_if_greater_or_equal    ${SSB_00_val}[0]    ${2}    name=RA_ATT_SSB_00
    run keyword and continue on failure    local_resources.check_if_greater_or_equal    ${c_sum}    ${2}    name=RA_COMP_CONT_A_PRMBL
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55306C10006    4           RA_CBRA_UL_GRANT_MSG3_RETX
    ...    M55306C10004    1           RA_CBRA_MSG3_RECV_DECODE_FAIL
    ...    local_moid=${MO_ID}
    ...    file_path=${pm_counters}

    Detach UE SA  ue_id_first=2    num_of_ues=1
    [Teardown]    Custom Test Teardown    delta=${false}
