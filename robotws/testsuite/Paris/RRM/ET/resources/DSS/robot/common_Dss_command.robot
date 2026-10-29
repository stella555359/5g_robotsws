*** Settings ***
Documentation     [PURPOSE] Set of keywords used for feature FDD DSS tests cases
...                         using only ute_wtssim library
...               http://doc.ute.nsn-rdnet.net/packages/ute_wtssim/interfaces/ute_wtssim.html
...
...               Automation author           : christophe.samson@nokia.com
...               Automation contact          : christophe.samson@nokia.com
...               Creation Date               : 11-May-2021
...               Modified Date               : 11-May-2021
...               Last Modified by            : christophe.samson@nokia.com

Library         taf.transport.ssh    WITH NAME    ssh
Library         ute_wtssim


*** Keywords ***
Check wts in active state
    [Documentation]    [PRIVATE]    check that wts is in state active
    [Arguments]                 ${alias}=EPCSIM
    Log To Console    \n***check if wts in active state with alias=${alias}***
    Wait Until Keyword Succeeds    5 min    20 sec    Check wts state   alias=${alias}
    Log To Console    ***check if wts in active state ended

Check wts state
    [Documentation]    [PRIVATE]    check that wts is in state active
    [Arguments]                 ${alias}=EPCSIM
    wts.execute egate command and wait for data
    ...    cmd=sim_state_disp
    ...    pass_regexp=The state is ACTIVE   alias=${alias}

Wait wts state ACTIVE Using ute wtssim
    [Documentation]    [PRIVATE]    wait wts state ACTIVE
    [Arguments]                 ${alias}=EPCSIM
    Wait Until Keyword Succeeds    1 min    20 sec    Check wts state Using ute wtssim   alias=${alias}

Check wts state Using ute wtssim
    [Documentation]    [PRIVATE]    check that wts is in state active
    [Arguments]                 ${alias}=EPCSIM
    ute_wtssim.execute egate command and wait for data
    ...    cmd=sim_state_disp
    ...    pass_regexp=The state is ACTIVE   alias=${alias}

Wait Xp link Up
    [Documentation]    [PRIVATE]    wait Xp link up
    [Arguments]                 ${alias}=EPCSIM
    Wait Until Keyword Succeeds    2 min    20 sec    Xp link setup Up   alias=${alias}

Xp link Setup Up
    [Arguments]          ${timeout}=20       ${alias}=EPCSIM
    Log to console  \n***Activate eNBSim with XpAp interface [eNBId=${Param.Context.eNBId} and gNBId=${Param.Context.gNBId}] with alias=${alias}***
    wts.execute egate command    cmd=enb_xp_param id=${Param.Context.eNBId} ignore_xp=off xp_listening_socket=on    alias=${alias}
    wts.execute egate command    cmd=enb_xp_param id=${Param.Context.eNBId} xp_peers=${Param.Context.gNBId}    alias=${alias}
    ${output}=    wts.execute egate command and wait for data    cmd=enb_xp_link_up enb=${Param.Context.eNBId} target=${Param.Context.gNBId}
    ...                                            pass_regexp=(XpAP Link .* is up|Xp Link is already active)   timeout=${timeout}  alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}    XpAP Link .* is up   partial_match=${TRUE}
    Log to Console    ${output}
    ${output}         Get Lines Matching Regexp    ${output}    Xp Link is already active   partial_match=${TRUE}
    Log to Console    ${output}
    # wts.execute egate command and wait for data    cmd=enb_xp_link_up enb=${Param.Context.eNBId} target=${Param.Context.gNBId}
    # ...                                                pass_regexp=XpAP Link .* is up   timeout=${timeout}  alias=${alias}
    # sometimes the link falls, and come back again after 4-5 seconds, so we add a sleep here
    Traced sleep    10s
    Log to console  \n***Activate eNBSim with XpAp interface completed ***

Xp link Setup
    [Arguments]                 ${alias}=EPCSIM
    Log to console  \n***Activate eNBSim with XpAp interface [eNBId=${Param.Context.eNBId} and gNBId=${Param.Context.gNBId}] with alias=${alias}***
    wts.execute egate command    cmd=enb_xp_param id=${Param.Context.eNBId} ignore_xp=off xp_listening_socket=on    alias=${alias}
    wts.execute egate command    cmd=enb_xp_param id=${Param.Context.eNBId} xp_peers=${Param.Context.gNBId}    alias=${alias}
    wts.execute egate command and wait for data    cmd=enb_xp_link_up enb=${Param.Context.eNBId} target=${Param.Context.gNBId}
    ...                                                   pass_regexp=XpAP Link .* is up   timeout=120  alias=${alias}
    # sometimes the link falls, and come back again after 4-5 seconds, so we add a sleep here
    Traced sleep    10s
    Log to console  \n***Activate eNBSim with XpAp interface completed ***

Wait Xp link Up Using ute wtssim
    [Documentation]    [PRIVATE]    wait Xp link up
    [Arguments]                 ${alias}=EPCSIM
    Wait Until Keyword Succeeds    2 min    20 sec    Xp link setup Up Using ute wtssim   alias=${alias}

Xp link Setup Up Using ute wtssim
    [Arguments]          ${timeout}=20       ${alias}=EPCSIM
    Log to console  \n***Activate eNBSim with XpAp interface [eNBId=${Param.Context.eNBId} and gNBId=${Param.Context.gNBId}] with alias=${alias}***
    ute_wtssim.execute egate command    cmd=enb_xp_param id=${Param.Context.eNBId} ignore_xp=off xp_listening_socket=on    alias=${alias}
    ute_wtssim.execute egate command    cmd=enb_xp_param id=${Param.Context.eNBId} xp_peers=${Param.Context.gNBId}    alias=${alias}
    ${output}=    ute_wtssim.execute egate command and wait for data    cmd=enb_xp_link_up enb=${Param.Context.eNBId} target=${Param.Context.gNBId}
    ...                                            pass_regexp=(XpAP Link .* is up|Xp Link is already active)   timeout=${timeout}  alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}    XpAP Link .* is up   partial_match=${TRUE}
    Log to Console    ${output}
    ${output}         Get Lines Matching Regexp    ${output}    Xp Link is already active   partial_match=${TRUE}
    Log to Console    ${output}
    # wts.execute egate command and wait for data    cmd=enb_xp_link_up enb=${Param.Context.eNBId} target=${Param.Context.gNBId}
    # ...                                                pass_regexp=XpAP Link .* is up   timeout=${timeout}  alias=${alias}
    # sometimes the link falls, and come back again after 4-5 seconds, so we add a sleep here
    Traced sleep    10s
    Log to console  \n***Activate eNBSim with XpAp interface completed ***

X2Ap link Setup
    [Arguments]                 ${alias}=EPCSIM
    Log to console  \n***Activate eNBSim with X2Ap interface [eNBId=${Param.Context.eNBId} and gNBId=${Param.Context.gNBId}] with alias=${alias}***

    wts.execute egate command and wait for data    cmd=enb_x2_link_up enb=${Param.Context.eNBId} target=${Param.Context.gNBId}
    ...                                                     pass_regexp=X2AP Link .* is up    timeout=60   alias=${alias}
    # sometimes the link falls, and come back again after 4-5 seconds, so we add a sleep here
    Traced sleep    10s
    Log to console  \n***Activate eNBSim with X2AP interface completed ***

X2Ap link Setup Using ute wtssim
    [Arguments]                 ${alias}=EPCSIM
    Log to console  \n***Activate eNBSim with X2Ap interface [eNBId=${Param.Context.eNBId} and gNBId=${Param.Context.gNBId}] with alias=${alias}***

    ute_wtssim.execute egate command and wait for data    cmd=enb_x2_link_up enb=${Param.Context.eNBId} target=${Param.Context.gNBId}
    ...                                                     pass_regexp=X2AP Link .* is up    timeout=60   alias=${alias}
    # sometimes the link falls, and come back again after 4-5 seconds, so we add a sleep here
    Traced sleep    10s
    Log to console  \n***Activate eNBSim with X2AP interface completed ***

Set LTE NR DSS Mode
    [Documentation]    This keyword is for setting LTE NR DSS MODE [DSS Phase2].
    [Arguments]                 ${alias}=EPCSIM
    Log To Console   \n***Set LTE NR DSS Mode... with alias=${alias}***
    ute_wtssim.Execute Egate Command    enb_cell_param id\=1 enb\=${Param.seq.eNBId} lte_nr_dss_mode\=DL_CRS_TDM_UL_FDM antenna_ports_num\=2
    ...                                                alias=${alias}

DSS DL Cell Resource Allocation
    [Arguments]     ${dl_allocated_normal_subframes}=0011101110-0111101110-0011101110-0111101110-0011101110-0111101110-0011101110-0111101110
    ...             ${alias}=default
    sleep   5
    ${msg}    Catenate    DSS DL Cell Resource Allocation with allocation_start_time=immediate and
    ...                    dl_allocated_normal_subframes=${dl_allocated_normal_subframes} with alias=${alias}
    Dated Log New Line      ${msg}
    ${pattern}     Set Variable        Received DSS DL Subframe Resource Allocation Response
    ${cmd}    Catenate      enb_dss_resource_allocation enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=DL
    ...                         allocation_start_time=immediate dl_allocated_normal_subframes=${dl_allocated_normal_subframes}
    # ute_wtssim.execute egate command    cmd=${cmd}     alias=${alias}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=5     alias=${alias}
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}

    log to console  \n***DSS DL Cell Resource Allocation completed***

DSS UL Cell Resource Allocation
    [Arguments]                 ${StartPrb}=4     ${ULNbrOfPrb}=0x00000023      ${alias}=default

    sleep   5

    ${StartPrb}       toDecimalStr     ${StartPrb}
    ${ULNbrOfPrb_decimal}              toDecimalStr     ${ULNbrOfPrb}

    ${msg}    Catenate     DSS UL Cell Resource Allocation with StartPrb=${StartPrb} and
    ...                        NbrOfPRB=${ULNbrOfPrb_decimal} with alias=${alias}
    Dated Log New Line     ${msg}
    ${pattern}     Set Variable        Received EN DSS UL Subcarrier Resource Allocation Response
    ${cmd}    Catenate    enb_dss_resource_allocation enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=UL
    ...                     allocation_start_time=immediate ul_allocated_prb_list=${StartPrb},${ULNbrOfPrb_decimal}
    # ute_wtssim.execute egate command    cmd=${cmd}   alias=${alias}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=5     alias=${alias}
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}

    log to console  \n***DSS UL Cell Resource Allocation completed***

# Param variable is visible under the test suite because of Init Sequence
# Need to call Init Sequence first
# ex :
#   Init Sequence          ${testParam}
#   DSS_CRM_Cell_Setup     alias=TC1

DSS_CRM_Cell_Setup
    [Arguments]        ${alias}=default
    [Documentation]    to achieve DSS 5g CRM Cell SetUp used for DSS Ph2

    Log to console  \n***DSS ${Param.Context.DSS_Phase} CRM CellSetup BW=${Param.seq.bandwidth} with alias=${alias}***

    ute_wtssim.execute egate command    cmd=enb_dss_param id=${Param.Context.eNBId} feature_flag=on message_sets=V1,DMS2    alias=${alias}
    sleep   2
    ute_wtssim.execute egate command    cmd=enb_cell_param enb=${Param.Context.eNBId} id=1 lte_nr_dss_mode=DL_CRS_TDM_UL_FDM    alias=${alias}
    sleep   2
    # Cell-1.1 for ENB and Cell-2.1 for GNB
    ute_wtssim.execute egate command    cmd=enb_dss_configure_partnership enb=${Param.Context.eNBId} cell=1 dss_peer=${Param.Context.gNBId}:1
    ...                                                                    alias=${alias}
    sleep   2

    ${cmd}    Catenate    enb_crm_cell_resource_reservation enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1
    ...         assigned_dl_minimum_share_to_nr=15 assigned_dl_maximum_share_to_nr=70 assigned_dl_minimum_share_to_lte=15
    ...         assigned_dl_maximum_share_to_lte=70 assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70
    ute_wtssim.execute egate command      cmd=${cmd}    alias=${alias}

    # to simulate the EN DSS UL QoS LOAD INDICATION Timer = 80ms sent into DL coord rsp
    ${cmd}    Catenate    enb_crm_param id=${Param.Context.eNBId} ul_qos_load_meas_timer=${Param.seq.qos_load_meas_timer}
    ...                                                           dl_qos_load_meas_timer=${Param.seq.qos_load_meas_timer}
    Dated Log New Line       ${cmd}
    ute_wtssim.execute egate command      cmd=${cmd}      alias=${alias}

    # increase the sleeping time betwenn cell resource resernation and dss estab partnership
    # sometimes, the XP dont came up at the first time !!!
    # 19:55:06.872 19:55:06.871 [37;41mACR[0m: ENB-1: Failed to connect to ENB-2 over SCTP: 9 -
    #  ...       system connect() error. errno=99 (Cannot assign requested address)
    # 19:55:06.872 19:55:06.871 [37;41mACR[0m: ENB-1: Failed to connect to GNB-2 (10.0.1.111:32742[0]) over SCTP

    sleep    30
    # ute_wtssim.execute egate command    cmd=enb_dss_establish_partnership enb=1 cell=1 tgt_enb=2 tgt_cell=1     alias=${alias}
    ${pattern}    Set Variable    EN DSS UL Cell Subcarrier Resource Coordination success on remote NE
    ${cmd}      Catenate       enb_dss_establish_partnership enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=30     alias=${alias}
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}

    sleep   10

    common_Dss_command.DSS DL Cell Resource Allocation    ${Param.seq.dl_allocated_normal_subframes}    ${alias}

    # Param variable is visible under the test suite
    common_Dss_command.DSS UL Cell Resource Allocation     ${Param.scfFile.nrcell.msg1FrequencyStart}     ${Param.seq.ULNbrOfPrb}     ${alias}

    sleep    10

    log to console  \n***DSS CRM CELLSETUP BW=${Param.seq.bandwidth} completed***
