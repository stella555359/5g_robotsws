*** Settings ***

Documentation
...    Author: jun.6.ma
...    Contact: jun.6.ma@nokia-sbell@nokia-sbell.com
...    This is a robot scripts for CB006139-SR CRT Testing

Force Tags
...      TRUNK             #Tag Item
...      CA_RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM     #Organization
...      TA_LEVEL_22                 #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout           6h

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Resource    ../../../Resources/Classical/RRM_Common_Resource.robot
Resource    ../../../T02/Common_Case/common_resource_new.robot
Library     taf.sw.scout    WITH NAME    scout
Library     SSHLibrary
Library     Collections

*** Variables ***

${TestLine_Name}          10_5_UTESRAN028T36955
${SELECTED_SW_VERSION}    SBTS00_ENB_9999_241016_000001
&{UE_INFO}                R3CRC011CQD=350166285465436    RFCNC0RNFJH=353158260231187
${serials}                R3CRC011CQD
${host}    10.56.201.215
${usrname}      toor4nsn
${pwd}      oZPS0POrRieRtu
${UE_IMSI}      262030020033450
${SCF_Path}     /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL36955/Regression/config/
${SCF_Name}     CB006139-CD-B3_OK.xml    #SCF_CB006139-CH-B1andB2.xml

*** Test Cases ***
CB006139_CH_01_B1_Stepwise_SCell_addition_interaction_with_SCell_swap_and_A1_measurement_based_PCell_switch
    [Tags]    QC_235160    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...     Author: jun.6.ma@nokia-sbell.com
    ...     this is the case run in BTS37548, for case CB006139_CH_01_B1
    [Setup]    Common Test Setup For RRM
    Initialize_PA_Signal
    log to console      \n >>> PA is initialled to max value 60, special value 93 cannot be set...

    SCF_Config_activate     SCF_CB006139-CH-B1andB2.xml
    sleep    300s
    Check_CellandSite_Status
    log to console      \n >>> Site is on-air with this case's SCF

    #set PA value for case execution
    Set Initialize PA Value    pa_port=211,220,19,28,83,92;    pa_value=0;
    log to console      \n >>> PA is set to the values for this case's execution

    #block cells
    BTS Operation   operation=cell_block    product_type=gnb    bts_index=0     distname_id=NRCELL-301   need_verify=True
    BTS Operation   operation=cell_block    product_type=gnb    bts_index=0     distname_id=NRCELL-311   need_verify=True
    BTS Operation   operation=cell_block    product_type=gnb    bts_index=0     distname_id=NRCELL-302   need_verify=True
    BTS Operation   operation=cell_block    product_type=gnb    bts_index=0     distname_id=NRCELL-303   need_verify=True
    BTS Operation   operation=cell_block    product_type=gnb    bts_index=0     distname_id=NRCELL-313   need_verify=True
    sleep   10s

    #log to console      \n >>> UE detached \n >>> Start to attach UE
    #UE_Attach
    #log to console      \n >>> Start to do UDP DL
    #UPD_DL_Start

    Set Initialize PA Value    pa_port=211,220;    pa_value=22;
    sleep   30s
    Set Initialize PA Value    pa_port=19,28;    pa_value=60;
    Parameter_Update
    sleep   30s
    Set Initialize PA Value    pa_port=19,28;    pa_value=0;
    sleep   30s
    Set Initialize PA Value    pa_port=211,220;    pa_value=0;
    sleep   30s
    Set Initialize PA Value    pa_port=147,156,137,130;    pa_value=0;
    sleep   30s
    Set Initialize PA Value    pa_port=147,156;    pa_value=15;
    sleep   30s

    #log to console      \n >>> to Stop UDP DL
    #UPD_DL_Stop
    #sleep   5s
    #UE_Detach
    log to console      \n >>> Start to collect Snapshot

    Collect Coam Snapshot    name=CB006139_CH_01_B1
    log to console      \n >>> Snapshot collected... Case END
    [Teardown]    Teardown_for_OAM

CB006139_CH_02_B2_Stepwise_SCell_addition_when_A6_measurement_configuration_is_active
    [Tags]    QC_235159    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...     Author: jun.6.ma@nokia-sbell.com
    ...     this is the case run in BTS37548, for case CB006139_CH_02_B2
    [Setup]    Common Test Setup For RRM
    Initialize_PA_Signal
    log to console      \n >>> PA is initialled to max value 60, special value 93 cannot be set...

    SCF_Config_activate     SCF_CB006139-CH-B1andB2.xml
    sleep    300s
    Check_CellandSite_Status
    log to console      \n >>> Site is on-air with this case's SCF

    #set PA value for case execution
    Set Initialize PA Value    pa_port=211,220,19,28,83,92;    pa_value=0;
    log to console      \n >>> PA is set to the values for this case's execution

    #block cells
    BTS Operation   operation=cell_block    product_type=gnb    bts_index=0     distname_id=NRCELL-301     need_verify=True
    BTS Operation   operation=cell_block    product_type=gnb    bts_index=0     distname_id=NRCELL-311     need_verify=True
    BTS Operation   operation=cell_block    product_type=gnb    bts_index=0     distname_id=NRCELL-302     need_verify=True
    BTS Operation   operation=cell_block    product_type=gnb    bts_index=0     distname_id=NRCELL-303     need_verify=True
    BTS Operation   operation=cell_block    product_type=gnb    bts_index=0     distname_id=NRCELL-313     need_verify=True
    sleep   10s

    #log to console      \n >>> UE detached \n >>> Start to attach UE
    #UE_Attach
    #log to console      \n >>> Start to do UDP DL
    #UPD_DL_Start

    Set Initialize PA Value    pa_port=211,220;    pa_value=22;
    sleep   30s
    Set Initialize PA Value    pa_port=19,28;    pa_value=60;
    Parameter_Update
    sleep   30s
    Set Initialize PA Value    pa_port=19,28;    pa_value=0;
    sleep   30s
    Set Initialize PA Value    pa_port=211,220;    pa_value=0;
    sleep   30s
    Set Initialize PA Value    pa_port=147,156,137,130;    pa_value=0;
    sleep   30s
    Set Initialize PA Value    pa_port=211,220;    pa_value=22;
    sleep   30s
    Set Initialize PA Value    pa_port=83,92;    pa_value=60;
    sleep   30s
    Set Initialize PA Value    pa_port=211,220;    pa_value=0;
    sleep   30s

    #log to console      \n >>> to Stop UDP DL
    #UPD_DL_Stop
    #sleep   5s
    #UE_Detach

    log to console      \n >>> Start to collect Snapshot
    Collect Coam Snapshot    name=CB006139_CH_02_B2
    log to console      \n >>> Snapshot collected... Case END
    [Teardown]    Teardown_for_OAM

CB006139_CD_03_B3_gNB_adds_FDD_and_TDD_SCells_during_one-shot_SCell_addition
    [Tags]    QC_235141    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...     Author: jun.6.ma@nokia-sbell.com
    ...     this is the case run in BTS37548, for case CB006139_CD_03_B3
    [Setup]    Common Test Setup For RRM
    Initialize_PA_Signal
    log to console      \n >>> PA is initialled to max value 60, special value 93 cannot be set...

    SCF_Config_activate     CB006139-CD-B3_OK.xml
    sleep    300s
    Check_CellandSite_Status
    log to console      \n >>> Site is on-air with this case's SCF

    #block cells
    BTS Operation   operation=cell_block    product_type=gnb    bts_index=0     distname_id=NRCELL-23      need_verify=True
    BTS Operation   operation=cell_block    product_type=gnb    bts_index=0     distname_id=NRCELL-232     need_verify=True
    BTS Operation   operation=cell_block    product_type=gnb    bts_index=0     distname_id=NRCELL-301     need_verify=True
    BTS Operation   operation=cell_block    product_type=gnb    bts_index=0     distname_id=NRCELL-311     need_verify=True
    BTS Operation   operation=cell_block    product_type=gnb    bts_index=0     distname_id=NRCELL-313     need_verify=True
    BTS Operation   operation=cell_block    product_type=gnb    bts_index=0     distname_id=NRCELL-303     need_verify=True
    sleep   10s

    #set PA value for case execution
    Set Initialize PA Value    pa_port=211,220;    pa_value=0;
    sleep   30s
    log to console      \n >>> PA is set to the values for this case's execution

    #log to console      \n >>> UE detached \n >>> Start to attach UE
    #UE_Attach
    #sleep       30s

    Set Initialize PA Value    pa_port=211,220;    pa_value=25;
    sleep   30s
    Set Initialize PA Value    pa_port=19,28,193,202;    pa_value=0;
    sleep   30s
    log to console      \n >>> scell configured

    #log to console      \n >>> Start to do UDP DL, scells added
    #UPD_DL_Start

    Set Initialize PA Value    pa_port=211,220;    pa_value=25;
    sleep   30s
    Set Initialize PA Value    pa_port=193,202;    pa_value=60;
    sleep   30s
    Set Initialize PA Value    pa_port=83,92;    pa_value=0;
    sleep   30s
    Parameter_Update_212
    sleep   30s

    Set Initialize PA Value    pa_port=211,220;    pa_value=0;
    sleep   30s

    #log to console      \n >>> to Stop UDP DL
    #UPD_DL_Stop
    #sleep   5s
    #UE_Detach
    log to console      \n >>> Start to collect Snapshot

    Collect Coam Snapshot    name=CB006139_CD_03_B3
    log to console      \n >>> Snapshot collected... Case END
    [Teardown]    Teardown_for_OAM

*** Keywords ***
SCF_Config_activate
    [Arguments]    ${SCF_Name}
    ${out}   Parameter Operation    operation=full_commission   product_type=gnb
    ...                             scf_path=${SCF_Path}${SCF_Name}
    Log To Console    \n >>> Full commission result: ${out} with ${SCF_Name}
Initialize_PA_Signal
    SetInitializePAValue    pa_port=1-256;    pa_value=60;

Check_CellandSite_Status
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=SITE_ONAIR+CELL_ONAIR
UE_Attach
    Traffic Uebox Operation    attach    ue_imsi=${UE_IMSI}     forced=${True}
UE_Detach
    Traffic Uebox Operation    detach    ue_imsi=${UE_IMSI}
UPD_DL_Start
    Traffic Uebox Operation    start dl traffic  ue_imsi=${UE_IMSI}
    ...     remote_hostname=10.56.202.186   remote_username=ute    remote_password=UTE.debian12   #the pwd of this 186 vm is changed to this new one
    ...     IperfOptions=-u -i1 -l1400 -p50001 -b800M -t120 -c 172.252.50.188
UPD_DL_Stop
    Traffic Uebox Operation    stop dl traffic  ue_imsi=${UE_IMSI}
    ...     remote_hostname=10.56.202.186   remote_username=ute    remote_password=UTE.debian12
Parameter_Update
    @{para_list}      Create List     maxNumOfSCellAlloc
    @{mo_list}        Create List     MRBTS-37548/NRBTS-37548/NRCELL-22
    @{value_list}     Create List     0
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
    Log To Console    \n >>> Paramter update result: ${out}
Parameter_Update_212
    @{para_list}      Create List     maxNumOfSCellAlloc
    @{mo_list}        Create List     MRBTS-37548/NRBTS-37548/NRCELL-212
    @{value_list}     Create List     32
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
    Log To Console    \n >>> Paramter update result: ${out}
Teardown_for_OAM
    Get SCF Internal Id By Scout    no_ute=False
    #Common Test Teardown For RRM
UEBOX_Reset
    Traffic Uebox Operation    exec at cmd  ue_imsi=262030020033450    atcmd=AT+CFUN=1,1
    sleep   30s
UEBOX_Detach
    Traffic Uebox Operation    exec at cmd  ue_imsi=262030020033450    atcmd=at+cfun=0
    sleep   10s
UEBOX_Attach
    Traffic Uebox Operation    exec at cmd  ue_imsi=262030020033450    atcmd=at+cfun=1
    ${output-ueip}      Traffic Uebox Operation    exec at cmd  ue_imsi=262030020033450    atcmd=AT+CGPADDR
    log to console      \n >>>>>> ${output-ueip}
UEBOX_DL_Traffic
    AT Operation    start_traffic    IperfOptions=-u -i 1 -t 300 -b 600M -p 50001  direction=dl
    ...  remote_hostname=10.108.237.194    remote_username=ute    remote_password=Ut3pa5s#ff97