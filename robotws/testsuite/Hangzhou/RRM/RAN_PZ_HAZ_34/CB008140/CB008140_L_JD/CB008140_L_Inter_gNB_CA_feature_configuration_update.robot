#*** Settings ***
#Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
#Variables    ./Resources/CB008140_L_variables.py
#
#Documentation
#...   author: xiaodan.li
#...   contact: xiaodan.li@nokia-sbell.com
#...   squad group: SG_03
#...   Feature CB008140-L
#
#Suite Setup    Run Keywords
#...                            Common Suite Setup for COAM    AND
#...                            Adjust gNB_RU Attenuation
#
#Suite Teardown    Run Keywords
#...               Common Suite Teardown for COAM    gnb_list=${gnb_list_L006}    AND
#...               Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#*** Variables ***
#${golden_scf_name_gnb0}    Configuration_scf_GNB1_CB008140.xml
#${golden_scf_name_gnb1}    Configuration_scf_GNB2_CB008140.xml
#${golden_scf_name_gnb2}    Configuration_scf_GNB3_CB008140.xml
#${golden_scf_name_gnb3}    Configuration_scf_GNB4_CB008140.xml
#${filename_L006_gnb0}    log_name_L_0006_gNB1.pcap
#${filename1_L006_gnb0}    log1_name_L_0006_gNB1.pcap
#${filename2_L006_gnb0}    log2_name_L_0006_gNB1.pcap
#${filename3_L006_gnb0}    log3_name_L_0006_gNB1.pcap
#${filename3_L006_gnb0_ET}    log3_name_L_0006_gNB1_ET.pcap
#${filename_L006_gnb3}    log_name_L_0006_gNB4.pcap
#${filename1_L006_gnb3}    log1_name_L_0006_gNB4.pcap
#${filename_L008_gnb0}    log_name_L_0008_gNB1.pcap
#${filename1_L008_gnb0}    log1_name_L_0008_gNB1.pcap
#${filename2_L008_gnb0}    log2_name_L_0008_gNB1.pcap
#${filename3_L008_gnb0}    log3_name_L_0008_gNB1.pcap
#${filename4_L008_gnb0}    log4_name_L_0008_gNB1.pcap
#${filename_L011_gnb0}    log_name_L_011_gNB1.pcap
#${filename1_L011_gnb0}    log1_name_L_011_gNB1.pcap
#${filename2_L011_gnb0}    log2_name_L_011_gNB1.pcap
#${filename_L012_gnb0}    log_name_L_012_gNB1.pcap
#${filename1_L012_gnb0}    log1_name_L_012_gNB1.pcap
#${filename2_L012_gnb0}    log2_name_L_012_gNB1.pcap
#${filename3_L012_gnb0}    log3_name_L_012_gNB1.pcap
#${filename_L013_gnb0}    log_name_L_013_gNB1.pcap
#${filename1_L013_gnb0}    log1_name_L_013_gNB1.pcap
#${filename2_L013_gnb0}    log2_name_L_013_gNB1.pcap
#${filename3_L013_gnb0}    log3_name_L_013_gNB1.pcap
#${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
#@{gnb_ips}    ${bts_host0}    ${bts_host1}
#@{scell_index_list_L011}    ${1}
#@{extgnb_index_list_L011}    ${3}
#@{scell1_index_list_L008}    ${1}
#@{scell11_index_list_L008}    ${11}
#@{scell3_index_list_L008}    ${3}
#@{scell31_index_list_L008}    ${31}
#@{extgnb3_index_list_L008}    ${2}
#@{extgnb4_index_list_L008}    ${3}
#@{scell_index_list_L012}    ${2}
#@{extgnb_index_list_L012}    ${0}
#@{scell_index_list_L006_cell31}    ${31}
#@{extgnb_index_list_L006_gnb4}    ${3}
#@{scell_index_list_L006_cell1}    ${1}
#@{extgnb_index_list_L006_gnb0}    ${0}
#@{extgnb_index_list_L006_gnb4_3cc}    ${3}    ${3}
#@{scell_index_list_L006_3cc}    ${1}    ${31}
#@{filename_L006}    filename_L006_gnb    filename1_L006_gnb    filename2_L006_gnb    filename3_L006_gnb
#...    filename_L006_gnb3    filename1_L006_gnb3
#@{filename_L008}    filename_L008_gnb    filename1_L008_gnb    filename2_L008_gnb    filename3_L008_gnb
#@{filename_L011}    filename_L011_gnb    filename1_L011_gnb    filename2_L011_gnb
#@{filename_L012}    filename_L012_gnb    filename1_L012_gnb    filename2_L012_gnb    filename3_L012_gnb
#...    filename_L013_gnb    filename1_L013_gnb    filename2_L013_gnb    filename3_L013_gnb
#@{sd_Locked}    ${11259375}    ${11259375}
#@{sd_Unlocked}    ${11259375}    ${13714341}    ${11259375}    ${13714341}
#@{gnb_list_L006}    ${0}    ${3}
#@{gnb_list_L006_gnb4}    ${3}
#@{gnb_list_L008}    ${0}    ${2}    ${3}
#@{gnb_list_L011}    ${0}    ${3}
#${scf_path}    /opt/workspace/SCF/
#@{gnb_ips_L006}    ${bts_host0}    ${bts_host3}
#@{gnb_ips_L008}    ${bts_host0}    ${bts_host2}    ${bts_host3}
#${Send_Tput_DL_F_F_T}    2500M
#${expected_tput_dl_F}    397
#${expected_tput_dl_T}    1450
#@{enb_cell1_L006_38711}    372    375    376
#@{enb_cell1_L006_38611}    362    365    366
#@{enb_cell1_L006_38511}    352    555    356
#
#
#*** Test Cases ***
#[1]CB008140-5G-L_006_Online_modification_of_actInterGnbCa_from_disabled_to_DLOnly_with_blind_scell_addition
#    [Documentation]    This user scenario verifies gNB’s behavior to support the online modification of FAF actInterGnbCa
#    ...    from ‘disabled’ to ‘DLOnly’.
#    [Tags]     classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup for L006
#    MultiUE.Prepare UE
#    ### step1 primer actInterGnbCa from disabled to DLOnly
#    Log to console    \n*** step1 primer actInterGnbCa from disabled to DLOnly ***
#    Case step1 primer actInterGnbCa from disabled to DLOnly
#    ### Add ET PR754845 checkpoint onlie closed actInterGnbCa and add new NRREL and open actInterGnbCa
#    Log to console    \n*** step2 Add ET PR onlie closed actInterGnbCa and add new NRREL and open actInterGnbCa ***
#    Case step2 Add ET PR onlie closed actInterGnbCa and add new NRREL and open actInterGnbCa
#    ### Step 3 exter actInterGnbCa from disabled to DLOnly
#    Log to console    \n*** Step 3 exter actInterGnbCa from disabled to DLOnly ***
#    Case step 3 exter actInterGnbCa from disabled to DLOnly
#    Hanging resource test    gnb_ips=@{gnb_ips_L006}    gnb_list=@{gnb_list_L006}
#    [Teardown]    run keywords
#    ...    Case Teardown    filename=${filename_L006}    gnb_list=${gnb_list_L006}    AND
#    ...    Common Case Teardown for L006    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#[1]CB008140-5G-L_008_Addition_of_new_ext_ca_Rel_instance_in_prime-gNB
#    [Documentation]    This user scenario verifies gNB’s behavior to support addition of ext_ca_Rel instance.
#    [Tags]     classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup for L008
#    # online enable 8140 feature about xn, xp, xgu, NRREL, actInterGnbCa
#    Online Enable CB008140 for L008
#    MultiUE.Prepare UE
#    ## attach tp cell2-1, not add the scell3-3
#    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}
#    Capture the attach detach event    filename=${filename_L008_gnb0}
#    ### online modify NRCELL2-NRREL1 sCellAdditionMethod and sCellOperationalMode
#    Online modify NIDD on gnb    gnb_index=${0}    Add_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_L008}
#    ### attach tp cell2-1, add the scell3-3
#    Capture the attach detach event    filename=${filename1_L008_gnb0}
#    ### attach to cell1-1, add the scell3-11
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    Capture the attach detach event    filename=${filename2_L008_gnb0}
#    ## online modify NRCELL1-NRREL1 to scell3-31, and attach cell1-1 and add the scell3-31
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_L008_1}
#    Capture the attach detach event    filename=${filename3_L008_gnb0}
#    ### online modify NRCELL1-NRREL1 to gnb4 scell4-1, and attach cell1-1 and add the scell4-1
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_L008_2}
#    Capture the attach detach event    filename=${filename4_L008_gnb0}
#    comment    check the wireshark log
#    Check wireshark log for L008
#    Hanging resource test    gnb_ips=@{gnb_ips_L008}    gnb_list=@{gnb_list_L008}
#    [Teardown]    run keywords
#    ...    Case Teardown    filename=${filename_L008}     gnb_list=${gnb_list_L006}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#[1]CB008140-5G-L_011_Online_modification_of_slicing_administrativeState
#    [Documentation]    This user scenario describes the not-activation of the event A6 measurement on a UE configured
#    ...    with ext-SCell.
#    [Tags]     classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup for L011
##    MultiUE.Mtu Power
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    Capture the attach detach event    filename=${filename_L011_gnb0}
#    #### tigger gnb2 SNSSAI1 Locked
#    Online modify and capture the attach detach event
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_L011}    filename=${filename1_L011_gnb0}
#    ...    gnb_index=${3}    gnb_index_capture=${0}
#    #### tigger gnb2 SNSSAI1 Unlocked
#    Online modify and capture the attach detach event
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_L011_1}    filename=${filename2_L011_gnb0}
#    ...    gnb_index=${3}    gnb_index_capture=${0}
#    comment    check the wireshark log
#    Check wireshark log for L011
#    Hanging resource test    gnb_ips=@{gnb_ips_L006}    gnb_list=@{gnb_list_L006}
#    [Teardown]    run keywords
#    ...    Case Teardown    filename=${filename_L011}     gnb_list=${gnb_list_L006}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#[1]CB008140-5G-L_012_Online_modification_of_weight_for_SCell_selection_in_prime-gNB
#    [Documentation]    This user scenario verifies gNB’s behavior to support online modification of below parameters:
#    ...    NRBTS/weightForIgnbCaSelection and NRBTS/NRADJGNB/weightForIgnbCaSelection
#    ...    add CB008140-5G-L_013 check point
#    [Tags]     classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup for L012
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    ## tigger select to gnb4
#    Online modify and capture the attach detach event
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_L012}    filename=${filename_L012_gnb0}
#    ...    gnb_index=${0}
#    ### tigger select to gnb1
#    Online modify and capture the attach detach event
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_L012_1}    filename=${filename1_L012_gnb0}
#    ...    gnb_index=${0}
#    # modify the sCellAdditionMethod to covBasedA1, gnb4 has a2MeasSCellRelSsbRsrp
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_L012_2}
#    ...    Add_Para_Online=${PARAMETERS_TO_ONLINE_ADD_GNB1_L012}
#    Online modify NIDD on gnb    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_L012_2}
#    ...    Add_Para_Online=${PARAMETERS_TO_ONLINE_ADD_GNB4_L012}
#    # tigger select to gnb2 cell4-1, and A2 release scell, and again attach select to gnb1 cell1-2 with A1
#    Trigger attach with A1 and scell release with A2 and attach again with A1
#    ...    logname=${filename2_L012_gnb0}   logname1=${filename3_L012_gnb0}
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_L012_1}
#    ### Add L013 checkpoint
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_L013}
#    Online modify NIDD on gnb    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_L013}
#    ### tigger select to gnb2 cell4-1
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb4_cell1_value=${10}
#    Capture the attach detach event    filename=${filename_L013_gnb0}
#    ### tigger select to gnb1 cell1-2
#    Online modify NIDD on gnb    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_L013_1}
#    Capture the attach detach event    filename=${filename1_L013_gnb0}
#    ## tigger select to gnb2 cell4-1, and A2 release scell
#    Online modify NIDD on gnb    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_L013}
#    Trigger attach with A1 and scell release with A2 and attach again with A1
#    ...    logname=${filename2_L013_gnb0}    logname1=${filename3_L013_gnb0}
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_L013_1}
#    ...    modify_gnb_index=${3}
#
#    comment    check the wireshark log
#    Check wireshark log for L012    logname=${filename_L012_gnb0}    logname1=${filename1_L012_gnb0}
#    ...    logname2=${filename2_L012_gnb0}    logname3=${filename3_L012_gnb0}
#    Check wireshark log for L012    logname=${filename_L013_gnb0}    logname1=${filename1_L013_gnb0}
#    ...    logname2=${filename2_L013_gnb0}    logname3=${filename3_L013_gnb0}
#    ...    UEContextModificationResponse_nums=${2}
#    Hanging resource test    gnb_ips=@{gnb_ips_L006}    gnb_list=@{gnb_list_L006}
#    [Teardown]    run keywords
#    ...    Case Teardown    filename=${filename_L012}     gnb_list=${gnb_list_L006}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#*** Keywords ***
#Common Case TestLine Setup for L006
#    @{scf_list}    Create List
#    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${0}
#    ...    golden_scf_name=${golden_scf_name_gnb0}    MOsToAdd=${MOS_ADD_GNB1_L006}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_L006}    ListToAdd=${LIST_TO_ADD_GNB1_L006}
#    Append to List    ${scf_list}    ${scf_gnb1}
#    ${scf_gnb4}    Only Modify SCF before Perform Commission    gnb_index=${3}
#    ...    golden_scf_name=${golden_scf_name_gnb3}    MOsToAdd=${MOS_ADD_GNB4_L006}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB4_L006}    ListToAdd=${LIST_TO_ADD_GNB4_L006}
#    Append to List    ${scf_list}    ${scf_gnb4}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list_L006}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list_L006}
#    FOR    ${cell}    IN    @{enb_cell1_L006_${gnb_instance0}}
#        Connect and Modify the parameter on enblte
#        ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${cell}
#        ...    parameter=administrativeState     value=locked
#    END
#
#Common Case Teardown for L006
#    Online modify NIDD on gnb    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_MODIFY_GNB4_L006_UNLOCK}
#    FOR    ${cell}    IN    @{enb_cell1_L006_${gnb_instance0}}
#        Connect and Modify the parameter on enblte
#        ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${cell}
#        ...    parameter=administrativeState     value=unlocked
#    END
#
#Common Case TestLine Setup for L008
#    @{scf_list}    Create List
#    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${0}
#    ...    golden_scf_name=${golden_scf_name_gnb0}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB1_L008_NO_8140}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_L008_NO_8140}
#    Append to List    ${scf_list}    ${scf_gnb1}
#    ${scf_gnb3}    Only Modify SCF before Perform Commission    gnb_index=${2}
#    ...    golden_scf_name=${golden_scf_name_gnb2}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB3_L008_NO_8140}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB3_L008_NO_8140}
#    Append to List    ${scf_list}    ${scf_gnb3}
#    ${scf_gnb4}    Only Modify SCF before Perform Commission    gnb_index=${3}
#    ...    golden_scf_name=${golden_scf_name_gnb3}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB4_L008_NO_8140}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB4_L008_NO_8140}
#    Append to List    ${scf_list}    ${scf_gnb4}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list_L008}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list_L008}
#
#Online Enable CB008140 for L008
#    ${release}    Get sagnb release
#    Run keyword If    '${release}'=='SBTS23R3_ENB_0000'
#    ...    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_L008_8140}
#    ...    Add_Para_Online=${LIST_TO_ADD_GNB1_L008_8140}    Add_Mo_Online=${MO_TO_ONLINE_ADD_GNB1_L008_8140_SBTS23R3_ENB_0000}
#    ...    ELSE    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_L008_8140}
#    ...    Add_Para_Online=${LIST_TO_ADD_GNB1_L008_8140}    Add_Mo_Online=${MO_TO_ONLINE_ADD_GNB1_L008_8140}
#    Online modify NIDD on gnb    gnb_index=${2}    Add_Mo_Online=${MO_TO_ONLINE_ADD_GNB3_L008_8140}
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB3_L008_8140}
#    ...    Add_Para_Online=${LIST_TO_ADD_GNB3_L008_8140}
#    Online modify NIDD on gnb    gnb_index=${3}    Add_Mo_Online=${MO_TO_ONLINE_ADD_GNB4_L008_8140}
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_L008_8140}
#    ...    Add_Para_Online=${LIST_TO_ADD_GNB4_L008_8140}
#
#Common Case TestLine Setup for L011
#    @{scf_list}    Create List
#    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${0}
#    ...    golden_scf_name=${golden_scf_name_gnb0}    MOsToAdd=${MOS_ADD_GNB1_L011}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_L011}    ParameterToDelete=${LIST_TO_DELETE_GNB1_L011}
#    ...    ListParamterToModify=${LIST_TO_MODIFY_GNB1_L011}    ListToAdd=${LIST_TO_ADD_GNB1_L011}
#    Append to List    ${scf_list}    ${scf_gnb1}
#    ${scf_gnb4}    Only Modify SCF before Perform Commission    gnb_index=${3}
#    ...    golden_scf_name=${golden_scf_name_gnb3}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB4_L011}    ParameterToDelete=${LIST_TO_DELETE_GNB4_L011}
#    ...    ListToAdd=${LIST_TO_ADD_GNB4_L011}
#    Append to List    ${scf_list}    ${scf_gnb4}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list_L011}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list_L011}
#
#Common Case TestLine Setup for L012
#    @{scf_list}    Create List
#    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${0}
#    ...    golden_scf_name=${golden_scf_name_gnb0}    MOsToAdd=${MOS_ADD_GNB1_L012}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_L012}    ListToAdd=${LIST_TO_ADD_GNB1_L012}
#    Append to List    ${scf_list}    ${scf_gnb1}
#    Append to List    ${scf_list}    ${scf_path}${golden_scf_name_gnb3}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list_L011}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list_L011}
#
#Case step1 primer actInterGnbCa from disabled to DLOnly
#    ### primer-8140 closed, tigger not select to cell1-1-cell4-1(blind)
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    Online modify and capture the attach detach event
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_L006_1}    filename=${filename_L006_gnb0}
#    ...    gnb_index=${0}
#    ### check attach not to pcell1-1 and scell4-1
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${filename_L006_gnb0}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_L011}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_L006_gnb4}    CA_OK=False
#    ...    UEContextModificationResponse_nums=${3}
#
#    ### primer-8140 closed, tigger not select to cell1-2-cell4-2(basedA1)
#    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}
#    Start capture gNB log on master    filename=${filename1_L006_gnb0}    gNB_index=${0}
#    MultiUE.Attach
#    sleep    5s
#    Stop and download the Logs    filename=${filename1_L006_gnb0}   gNB_index=${0}
#    ### check attach not to pcell1-2 and scell4-2
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${filename1_L006_gnb0}
#    ...    pcell_index=${2}    scell_index_list=${scell_index_list_L006_cell31}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_L006_gnb4}    CA_OK=False
#    ...    UEContextModificationResponse_nums=${3}
#
#    ###    online open 8140 feature ,always not selet to cell1-2-cell4-2(basedA1)
#    Start capture gNB log on master    filename=${filename2_L006_gnb0}    gNB_index=${0}
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_L006_3}
#    sleep    5s
#    Stop and download the Logs    filename=${filename2_L006_gnb0}   gNB_index=${0}
#    MultiUE.Detach
#    ### check attach not to pcell1-2 and scell4-2
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${filename2_L006_gnb0}
#    ...    pcell_index=${2}    scell_index_list=${scell_index_list_L006_cell31}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_L006_gnb4}    CA_OK=False
#    ...    UEContextModificationResponse_nums=${3}
#
#    ### tigger select to cell1-1-cell4-1 OK
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    Start capture gNB log on master    filename=${filename3_L006_gnb0}    gNB_index=${0}
#    MultiUE.Attach
#    sleep    5s
#    Stop and download the Logs    filename=${filename3_L006_gnb0}   gNB_index=${0}
#    MultiUE.Detach
#    ### check attach to pcell1-1 and scell4-1
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${filename3_L006_gnb0}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_L011}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_L006_gnb4}
#    ...    UEContextModificationResponse_nums=${3}
#
#Case step2 Add ET PR onlie closed actInterGnbCa and add new NRREL and open actInterGnbCa
#    ##online primer and exter closed 8140
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_MODIFY_GNB1_L006_NO_8140}
#    Online modify NIDD on gnb    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_MODIFY_GNB4_L006_NO_8140}
#    ##online add scell4-22 to cell1-1
#    Online modify NIDD on gnb    gnb_index=${0}    Add_Mo_Online=${MO_TO_ONLINE_ADD_GNB1_L006}
#    ##online primer and exter open 8140
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_MODIFY_GNB1_L006_8140}
#    Online modify NIDD on gnb    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_MODIFY_GNB4_L006_8140}
#    #lock exter other cell
#    Modify Parameters for Cases    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_MODIFY_GNB4_L006_LOCK}
#    Wait Until Keyword Succeeds    20 min    30 sec    Cell Should Be Lock or Unlock    gnb_index=${3}    cell_idx=${3}
#    ...    cell_group_idx=${3}
#    ## check 3cc OK, select cell1-1-scell4-2-scell4-21
#    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}
#    Start capture gNB log on master    filename=${filename3_L006_gnb0_ET}    gNB_index=${0}
#    MultiUE.Attach
#    sleep    5s
#    Stop and download the Logs    filename=${filename3_L006_gnb0_ET}   gNB_index=${0}
#    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}    gnb4_cell1_value=${0}    gnb4_cell3_value=${0}
#    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_F_F_T}    duration=1200
#    Check 3CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell1=${expected_tput_dl_F}
#    ...    tput_dl_scell2=${expected_tput_dl_T}    scellid2=31    scellid1=1    pcellid=2    gnb_prime=${0}    gnb_external=${3}
#    MultiUE.Stop DL Traffic
#    MultiUE.Detach
#    ### check attach to pcell4-1 and scell3-1
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${filename3_L006_gnb0_ET}
#    ...    pcell_index=${2}    scell_index_list=${scell_index_list_L006_3cc}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_L006_gnb4_3cc}
#    ...    UEContextModificationResponse_nums=${2}
#    [Teardown]    Online modify NIDD on gnb    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_MODIFY_GNB4_L006_UNLOCK}
#
#
#Case step 3 exter actInterGnbCa from disabled to DLOnly
#    ### delete gnb _NRREL and close 8140
#    Online modify NIDD on gnb    gnb_index=${0}    Delete_Mo_Online=${MO_TO_DELETE_GNB1_L006}
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_L006_4}
#    ### tigger not select to cell4-1-cell1-1
#    Online modify NIDD on gnb    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_L006_1}
#    Adjust gNB_RU Attenuation    gnb4_cell1_value=${40}
#    Start capture multi gNB log    filename=filename_L006_gnb    gnb_list=${gnb_list_L006_gnb4}
#    MultiUE.Attach
#    sleep    5s
#    Stop capture multi gNB log    filename=filename_L006_gnb    gnb_list=${gnb_list_L006_gnb4}
#    ### check attach not to pcell4-1 and scell1-1
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${filename_L006_gnb3}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_L006_cell1}
#    ...    Primegnb_index=${3}    extgnb_index_list=${extgnb_index_list_L006_gnb0}    CA_OK=False
#    ...    UEContextModificationResponse_nums=${3}
#    ###    open 8140 feature
#    Start capture multi gNB log    filename=filename1_L006_gnb    gnb_list=${gnb_list_L006_gnb4}
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_L006_3}
#    ### tigger select to cell4-1-cell1-1
#    Adjust gNB_RU Attenuation    gnb4_cell1_value=${0}
#    sleep    5s
#    Stop capture multi gNB log    filename=filename1_L006_gnb    gnb_list=${gnb_list_L006_gnb4}
#    MultiUE.Detach
#    ### check attach to pcell4-1 and scell3-1
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${filename1_L006_gnb3}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_L006_cell1}
#    ...    Primegnb_index=${3}    extgnb_index_list=${extgnb_index_list_L006_gnb0}
#    ...    UEContextModificationResponse_nums=${1}
#
#
#Check wireshark log for L011
#    ### check attach ok
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${filename_L011_gnb0}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_L011}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_L011}
#    ...    UEContextModificationResponse_nums=${2}
#
#    ### check SNSSAI is update, and attach fail
#    Check NGRANNodeConfigurationUpdate about SNSSAI    logname=${filename1_L011_gnb0}    sd_expected=${sd_Locked}
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${filename1_L011_gnb0}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_L011}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_L011}    CA_OK=False
#
#    ### check SNSSAI is update, and attach ok
#    Check NGRANNodeConfigurationUpdate about SNSSAI    logname=${filename2_L011_gnb0}    sd_expected=${sd_Unlocked}
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${filename2_L011_gnb0}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_L011}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_L011}
#    ...    UEContextModificationResponse_nums=${2}
#
#Check wireshark log for L008
#    ### check attach cell1-2, not add scell3-3
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${filename_L008_gnb0}
#    ...    pcell_index=${2}    scell_index_list=${scell3_index_list_L008}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb3_index_list_L008}
#    ...    UEContextModificationResponse_nums=${3}    CA_OK=False
#    ### check attach cell1-2, add scell3-3
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${filename1_L008_gnb0}
#    ...    pcell_index=${2}    scell_index_list=${scell3_index_list_L008}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb3_index_list_L008}
#    ...    UEContextModificationResponse_nums=${3}
#    ### check attach cell1-1, add scell3-11
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${filename2_L008_gnb0}
#    ...    pcell_index=${1}    scell_index_list=${scell11_index_list_L008}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb3_index_list_L008}
#    ...    UEContextModificationResponse_nums=${3}
#    ### check attach cell1-1, add scell3-31
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${filename3_L008_gnb0}
#    ...    pcell_index=${1}    scell_index_list=${scell31_index_list_L008}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb3_index_list_L008}
#    ...    UEContextModificationResponse_nums=${3}
#    ### check attach cell1-1, add scell4-1
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${filename4_L008_gnb0}
#    ...    pcell_index=${1}    scell_index_list=${scell1_index_list_L008}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb4_index_list_L008}
#    ...    UEContextModificationResponse_nums=${3}
#
#
#Check wireshark log for L012
#    [Arguments]    ${logname}    ${logname1}    ${logname2}    ${logname3}
#    ...    ${UEContextModificationResponse_nums}=${3}
#    ### check attach to scell4-1
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_L011}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_L011}
#    ...    UEContextModificationResponse_nums=${UEContextModificationResponse_nums}
#    ### check attach to scell1-2
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname1}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_L012}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_L012}
#    ...    UEContextModificationResponse_nums=${UEContextModificationResponse_nums}
#    ### check attach to scell4-1 by basedA1
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname2}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_L011}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_L011}
#    ...    UEContextModificationResponse_nums=${3}
#    ### check trigger A2 scell release
#    Check Scell release with A2 measurement    logname=${logname2}
#    ### check attach to scell1-2 by basedA1
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname3}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_L012}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_L012}
#    ...    UEContextModificationResponse_nums=${2}
#
#
#Check NGRANNodeConfigurationUpdate about SNSSAI
#    [Arguments]    ${logname}    ${sd_expected}
#    ...    ${message_filter}=nokiaxnap.procedureCode == 18 and nokiaxnap.XnAP_PDU == 0
#    ...    ${xpath}=.//nokiaxnap.sd
#    Log    check IgNBCAModificationRequest message
#    ${SNSSAI_sd}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
#    ${sd_list}    Create List
#    FOR    ${sd}    IN    @{SNSSAI_sd}
#        ${sd_string}    Remove String    ${sd}    :
#        ${sd_num}    Convert To Integer    ${sd_string}    16
#        Append to List    ${sd_list}    ${sd_num}
#    END
#    Lists Should Be Equal    ${sd_list}    ${sd_expected}
#
#Online modify and capture the attach detach event
#    [Arguments]    ${filename}    ${Modify_Para_Online}='NULL'    ${Add_Para_Online}='NULL'    ${Add_Mo_Online}='NULL'
#    ...    ${gnb_index}=${0}   ${gnb_index_capture}=${0}
#    Start capture gNB log on master    filename=${filename}    gNB_index=${gnb_index_capture}
#    Online modify NIDD on gnb    gnb_index=${gnb_index}    Modify_Para_Online=${Modify_Para_Online}
#    ...    Add_Para_Online=${Add_Para_Online}    Add_Mo_Online=${Add_Mo_Online}
#    sleep    10s
#    MultiUE.Attach
#    sleep    5s
#    MultiUE.Detach
#    Stop and download the Logs    filename=${filename}   gNB_index=${gnb_index_capture}
#
#Capture the attach detach event
#    [Arguments]    ${filename}    ${gnb_index}=${0}
#    Start capture gNB log on master    filename=${filename}    gNB_index=${gnb_index}
#    MultiUE.Attach
#    sleep    5s
#    MultiUE.Detach
#    Stop and download the Logs    filename=${filename}   gNB_index=${gnb_index}
#
#Check Scell release with A2 measurement
#    [Arguments]    ${logname}
#    Get cell id multignb
#    ...    lcrid_pcell=${1}    scell_index_list=${scell_index_list_L011}
#    ...    PrimegNB_index=${0}    extgnb_index_list=${extgnb_index_list_L011}
#    Check IgNBCAUeContextModificationRequest message has scell ToBeRemoved    logname=${logname}
#    ...    release_cell=${extcell_id[0]}
#    Check IgNBCAUeContextModificationResponse message has scell ToBeRemoved    logname=${logname}    scelllcird=1
#    Check IgNBCAReleaseRequest message on PrimegNB    logname=${logname}
#    Check IgNBCAReleaseRequestAcknowledge message on PrimegNB    logname=${logname}
#
#Trigger attach with A1 and scell release with A2 and attach again with A1
#    [Arguments]    ${logname}    ${logname1}    ${Modify_Para_Online}    ${modify_gnb_index}=${0}    ${gnb_index}=${0}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb4_cell1_value=${10}
#    Start capture gNB log on master    filename=${logname}    gNB_index=${gnb_index}
#    MultiUE.Attach
#    #### triiger the A2 release scell
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${30}    gnb4_cell1_value=${50}
#    sleep    5s
#    Stop and download the Logs    filename=${logname}   gNB_index=${gnb_index}
#    #### tigger select to gnb1
#    Online modify NIDD on gnb    gnb_index=${modify_gnb_index}    Modify_Para_Online=${Modify_Para_Online}
#    Start capture gNB log on master    filename=${logname1}    gNB_index=${gnb_index}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    sleep    5s
#    Stop and download the Logs    filename=${logname1}   gNB_index=${gnb_index}
#    MultiUE.Detach
#
#Multi attach detach and select cell
#    [Arguments]    ${logname}    ${logname1}    ${logname2}
#    ...    ${gnb1_cell1_value}=${0}    ${gnb1_cell2_value}=${0}    ${gnb4_cell1_value}=${50}
#    ### tigger not select to cell1-1-cell2-1
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${gnb1_cell1_value}
#    Online modify and capture the attach detach event
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_L006_1}    filename=${logname}
#    ...    gnb_index=${0}
#    ### tigger not select to cell2-1-cell3-1
#    Adjust gNB_RU Attenuation    gnb1_cell2_value=${gnb1_cell2_value}
#    Online modify and capture the attach detach event
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_L006_2}    filename=${logname1}
#    ...    gnb_index=${0}
#    ### tigger not select to cell2-1-cell3-1
#    Adjust gNB_RU Attenuation    gnb4_cell1_value=${gnb4_cell1_value}
#    Online modify and capture the attach detach event
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_L006_1}    filename=${logname2}
#    ...    gnb_index=${3}