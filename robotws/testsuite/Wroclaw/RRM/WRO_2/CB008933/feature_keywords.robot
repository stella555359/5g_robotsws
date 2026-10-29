*** Settings ***
Library      nrpmqap_counter_checker/feautere_keywords.py
Library      ta5g_pm_counters
Library      ute_wtssim
Library      ta5g_ue_mobility
Library      ta5g_throughput
Resource     ../keywords/tshark_verifying.robot

Documentation    :copyright: Nokia
...              :authors: Mikolaj Kasian
...              :maintainer: 'Mikolaj Kasian'
...              :contact: mikolaj.kasian@nokia.com

*** Variables ***
${NSA_UE_1}=                          151
${SA_UE_1}=                           51
${SANSA_CELL_ID}=                     3

*** Keywords ***
Steps 1-2: Attach UE1 in NSA mode
    Attach UE To Enb    ue_id=${NSA_UE_1}    optional_parameters=profile=1
    Establish DC    ue_id=${NSA_UE_1}    target_cells=${SANSA_CELL_ID}

Steps 3: Start UL and DL traffic for UE1
    Start Data Traffic    ues=${NSA_UE_1}    bearer_id=2    direction=both    throughput=50mbps
    Sleep    11s    reason=Stabilize trafic

Steps 4: Trigger UE1 DC Release due to SgNB user inactivity timer
    Stop Data Traffic    ues=${NSA_UE_1}
    Sleep    35    reason=Wait For Dual Connectivity Release By Gnb Due To User Inactivity
    Verify Ngap Messages      packet_filter=x2ap.SgNBReleaseRequired_element && x2ap.radioNetwork == 42    continue_on_failure=${False}

Steps 5: Trigger SqNB Addition procedure for UE1
    Establish DC    ue_id=${NSA_UE_1}    target_cells=${SANSA_CELL_ID}

Steps 6: Trigger UE1 DC Release due to MeNB user inactivity timer
    Execute Egate Command And Wait For Data
    ...     cmd=enb_ue_dc_release ue=${NSA_UE_1} by=enb cause=RN_user_inactivity
    ...     timeout=60
    ...     pass_regexp=Bearer-type change from SCG-split to MCG is successful
    Verify Ngap Messages      packet_filter=x2ap.SgNBReleaseRequest_element && x2ap.radioNetwork == 42    continue_on_failure=${False}

Steps 7: Trigger SqNB Addition procedure for UE1
    Establish DC    ue_id=${NSA_UE_1}    target_cells=${SANSA_CELL_ID}

Steps 8: Trigger DC Release Due To Transport Resource Unavailable
    Execute Egate Command And Wait For Data
    ...     cmd=enb_ue_dc_release ue=${NSA_UE_1} by=enb bearer=2 cause=TRANSPORT_transport_resource_unavailable
    ...     timeout=60
    ...     pass_regexp=Bearer-type change from SCG-split to MCG is successful
    Verify Ngap Messages      packet_filter=x2ap.SgNBReleaseRequest_element && x2ap.transport == 0    continue_on_failure=${False}

Steps 9: Detach UE1
    Detach UE    ue_id=${NSA_UE_1}

Steps 10: Register UE2 in SA mode
    Attach UE And Establish PDU Session    ue_id=${SA_UE_1}    cell_id=${SANSA_CELL_ID}    enb_id=2    pdu_id=3    gw_id=1

Steps 11: Start UL and DL traffic for UE2
    Start Data Traffic    ues=${NSA_UE_1}    bearer_id=2    direction=both    throughput=50mbps
    Sleep    11s    reason=Stabilize trafic

Steps 12: Stop traffic and release UE2
    Stop Data Traffic    ues=${SA_UE_1}
    Deregister UE    ue_id=${SA_UE_1}

Steps 13: Verify Pm Counters Are Increased In Specific NRPMQAP
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    ${result}=    verify counters list increased

        ...    M55352C00001        3-22,42-60,64       >0            DL_PDCP_TIME_UE_TPUT_PMQAP
        ...    M55352C01001        3-22,42-60,64       >0            DL_PDCP_VOL_UE_TPUT_PMQAP

        ...    M55353C00001        3-22,42-60,64       >0            UL_RLC_VOL_UE_TPUT_PMQAP
        ...    M55353C01001        3-22,42-60,64       >0            UL_RLC_TIME_UE_TPUT_PMQAP

        ...    M55158C00009        4-23,45-64          >0            DL_RLC_SDU_PMQAP

        ...    M55356C00000        4-23,45-64          >0            ACC_UE_DL_DRB_DATA_PMQAP
        ...    M55356C00001        4-23,45-64          >0            ACC_UE_UL_DRB_DATA_PMQAP
        ...    M55356C00002        4-23,45-64          >0            MAX_UE_DL_DRB_DATA_PMQAP
        ...    M55356C00003        4-23,45-64          >0            MAX_UE_UL_DRB_DATA_PMQAP
        ...    M55363C00001        4-23,45-64          >0            DL_PRB_USED_DATA_PMQAP
        ...    M55363C00002        4-23,45-64          >0            UL_PRB_USED_DATA_PMQAP
        ...    M55363C00003        4-23,45-64          >0            DL_PRB_UTIL_SLOT_MAX_PMQAP
        ...    M55363C00004        4-23,45-64          >0            UL_PRB_UTIL_SLOT_MAX_PMQAP

        ...    M55160C00001        1-64                >0            AVE_NUMBER_OF_NSA_USERS_PMQAP
        ...    M55160C00002        1-64               ==300          AVE_NUM_NSA_USERS_DENOM_PMQAP
        ...    M55160C00003        1-64                >0            PEAK_NUMBER_OF_NSA_USERS_PMQAP
        ...    M55161C00001        1-64                >0            AVE_NUMBER_OF_SA_RRC_PMQAP
        ...    M55161C00002        1-64               ==300          AVE_NUMB_OF_SA_RRC_DENOM_PMQAP
        ...    M55161C00003        1-64                >0            PEAK_NUMB_OF_SA_RRC_USER_PMQAP

        ...    M55162C00001        1-64                >0            NX2CC_RAB_REL_ATT_MENB_PMQAP
        ...    M55162C00002        1-64                >0            NX2CC_RAB_REL_NORM_MENB_PMQAP
        ...    M55162C00003        1-64                >0            NX2CC_RAB_REL_ABNOR_MENB_PMQAP
        ...    M55162C00004        1-64                >0            NX2CC_RAB_REL_ATT_SGNB_PMQAP
        ...    M55162C00005        1-64                >0            NX2CC_RAB_REL_NORM_SGNB_PMQAP
        ...    M55162C00007        1-64                >0            NX2CC_RAB_SETUP_ATT_PMQAP
        ...    M55162C00008        1-64                >0            NX2CC_RAB_SETUP_ACK_PMQAP
        ...    M55162C00009        1-64                >0            NX2CC_RAB_SETUP_SN_PMQAP
        ...    M55163C00001        1-64                >0            NG_FLOW_SETUP_ATT_TOT_PMQAP
        ...    M55163C00002        1-64                >0            NG_FLOW_SETUP_SUCC_PMQAP
        ...    M55163C00003        1-64                >0            NG_FLOW_REL_PMQAP
        ...    M55163C00004        1-64                >0            NG_FLOW_REL_NORMAL_PMQAP

        ...    M55193C00001        1-64                >0            NG_FLOW_REL_NORMAL_PMQAP
        ...    pm_counter_file=${pm_counter_file}
        ...    cell_id=${SANSA_CELL_ID}

    Run Keyword If   not ${result}
        ...    Fail    msg=*HTML*<p style="color:red; font-size:16px; font-weight: bold;">Counters verification failed. Please check table </p>

Configure simulated interfaces
    With Simulated Network Interface    name=eth3:GNB_S1U    ip=10.0.1.112/24
    With Simulated Network Interface    name=eth3:ENB_X2U    ip=10.0.1.135/24
    With Simulated Network Interface    name=eth3:SGW_S1U    ip=10.0.1.133/24
    With Simulated Network Interface    name=eth3:SGW_S11    ip=10.0.1.134/24
    With Simulated Network Interface    name=eth3:MME1_S1    ip=10.0.1.131/24
    With Simulated Network Interface    name=eth3:ENB1_S1    ip=10.0.1.136/24
    With Simulated Network Interface    name=eth3:ENB1_X2    ip=10.0.1.137/24

Establish DC
    [Arguments]    ${ue_id}    ${target_cells}    ${target_gnb}=2    ${bearer}=2
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=${target_gnb}    target_cells=${target_cells}    bearer=${bearer}    dc_type=split_scg
    ...                             timeout=30    pass_regexp=Proxy \\(eNB ${target_gnb} cell ${target_cells}\\) reported successful RA
