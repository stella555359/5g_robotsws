*** Settings ***
Documentation
...   feature keywords

Library       ute_admin
Library       ute_ue
Library       SSHLibrary
Library       ../../../resources/rrm_fixture.py
Library       ../../../resources/webui/interface.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library    taf.sbts.oam.coam.admin  WITH NAME   admin
Library       ute_admin_infomodel
Library      taf.sbts.oam.coam.admin  WITH NAME    coam
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ue_keywords.robot
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py
#Variables    ./vars.py
Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC002640/resources/variables_2640.py
#Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC002640/resources/keywords_mtk.robot

*** Variables ***
@{COUNTERS}   M55138C03001  M55138C03002  M55139C03001  M55139C03002  M55118C09503  M55118C09502  M55118C09501  M55118C10504
#@{6733_COUNTERS}    M55139C01004  M55118C00031
@{6733_COUNTERS}    M55139C01501    M55139C01502
@{OH_COUNTERS}    M55118C10514  M55118C10513  M55118C07507
@{2CC_COUNTERS}    M55139C01004  M55139C01003

*** Keywords ***
Perform commissioning
    Log to console  Performing 5934 commissioning
    coam.connect to  name=gNB
    coam.perform commissioning  50898  testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB005934/resources/5934_auto.xml
    ...                         ${True}  ${True}  600  gNB
    BuiltIn.Sleep   10m

#Check counters initial values
#    FOR   ${counter}   IN   @{COUNTERS}
#        ${temp}   get pm counter value   ${counter}
#        Set test variable   ${${counter}}   ${temp}
#    END



6733 4CC Attach
    ute_ue.Attach UE    UE_5
#    Set Attenuation  0dB  ${ATTENUATOR['AHFIG_1']['ports']}  confirm=${TRUE}
    BuiltIn.Sleep   10s
    Log to console     Start Tput   console=yes
    Start data transfer    UE_5_DL    UE_5   dl   600s   1200 Mbits/sec   protocol=udp
    BuiltIn.Sleep   3s
    Stop data transfer    UE_5_DL
    #Initialise Attenuator

Overheating Attach
    Set Attenuation For Cell With Id   10   0dB
    Log to console     Attach 1CC UE   console=yes
    Attach Ue                        MediaTekUe    15
    Set Attenuation For Cell With Id   60   0dB
    Log to console     Start Tput on N25    console=yes
    Start DL Traffic For Ue    MediaTekUe    7000Mbits/sec    duration=1600s
#    BuiltIn.Sleep   10s

6733 Counters
    &{counters_values}=     Get Scell Add Counter Values    ${2CC_COUNTERS}
#    Run Keyword And Continue On Failure
#    ...    Counter Incremented Successfully    M55139C01004    cell_id=10    counter_dict=counters_values    operator=>=
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55139C01004    cell_id=212    counter_dict=counters_values    operator=>=
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55139C01003    cell_id=212    counter_dict=counters_values    operator=>=

Overheating Counters
    &{counters_values}=     Get Scell Add Counter Values    ${OH_COUNTERS}
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55118C10513    cell_id=10    counter_dict=counters_values    operator=>=
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55118C10514    cell_id=10    counter_dict=counters_values    operator=>=
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55118C07507    cell_id=10    counter_dict=counters_values    operator=>=

Gradually Increase Attenuation For cell
    [Arguments]    ${cell_id}    ${init_value}=0    ${max_value}=90
    Initialise Attenuator
    Gradually Increase Attenuation    port=${ATTENUATOR['NRCELL_${cell_id}']['ports']}    step=2    interval=1
    ...    init_value=${init_value}
    ...    max_value=${max_value}

Set cellAggrLevel
    Log to console     Changing cellAggrLevel to ${value}  console=yes
    [Arguments]    ${parameter}    ${value}
    admin.Setup admin    10.42.85.20    443    Nemuadmin    nemuuser    True    5000
    @{values}    Create List    ${value}
    admin.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-55131/NRBTS-55131/NRDRB-14
    ...    parameter=${parameter}
    ...    operation=update
    ...    value=${values}
    ...    skip_parameter_relation_errors=True
    admin.Teardown admin

CellAggr Teardown
    Set cellAggrLevel   cellAggrLevel   FR1 CA eligible

Attenuate All Ports
    Initialise Attenuator
    FOR    ${index}    ${att}    IN ENUMERATE    @{tl.attenuators}
        Log To Console    Clearing attenuation on attenuator ${index+1}
        Set Attenuation  90dB  confirm=${TRUE}    attenuator_id=${index+1}
    END

trigger Overheating Assistance command from UE
    [Documentation]   AT+EGMC=1,"NR_OVERHEATING",1,1,2,,,,,1,1,,,
    [Arguments]
    ...    ${on_off}=${1}    ${DL}=${0}
    Overheating    alias=MediaTekUe
    ...    oh_op=${on_off}
    ...    cc_dl=${DL}
    ...    cc_ul=${1}
    ...    bw_fr1_dl=${None}
    ...    bw_fr1_ul=${None}
    ...    bw_fr2_dl=${None}
    ...    bw_fr2_ul=${None}
    ...    mimo_fr1_dl=${1}
    ...    mimo_fr2_dl=${1}
    ...    mimo_fr1_ul=${None}
    ...    mimo_fr2_ul=${None}
