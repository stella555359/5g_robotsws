*** Settings ***
Documentation
...    Author:  yanqingli
...    Contact: yanqing.li@nokia-sbell.com
...    Feature: CB008369
...    Release: 25R3

Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../../resources/common_resources.robot

Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}
${scf_72e_72a_mixed_file}      CB008369_ABIP_AVQL_AVQC_NRTDD_Mixed_72a_72e_4xNRCELL.xml

&{bts_PA_dict}    10386=&{PA_dict_10386}    11148=&{PA_dict_11148}
&{PA_dict_10386}    ip=10.108.241.5     init_value=1:10;2:10;3:10;4:10    target_value=1:60;2:60;3:60;4:60
...    rank_2to1_value=1:60;2:60;3:60;4:120
&{PA_dict_11148}    ip=10.108.241.44    init_value=1:35;3:35;5:35;7:35     target_value=1:85;3:85;5:85;7:85
...    rank_2to1_value=1:60;4:60;7:60;10:120

*** Test Cases ***
Robustness_TC31_CB008369_NR_FR1_TDD_eCPRI_ABIP_Two_Cell_Online_Deletion_Addition
    [Tags]    ABIP    SMAwave    CB008369    72e    Trunk    QL3    TC31    Robustness
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB008369/${scf_72e_72a_mixed_file}
    Repeat Keyword    2 times    cell deletion addition and L3 call

*** Keywords ***
cell deletion addition and L3 call
    perform delta scf recommission    ${SCFC_path}/CB008369/Delta_delete.json
    perform delta scf recommission    ${SCFC_path}/CB008369/Delta_add.json
    SMAwave L3 call    cell_id=1    dl_tput=450M    ul_tput=40M    dl_deviation=20%    rat=5G    band=78    specific_UE_index=UE_1    duration=60
    SMAwave L3 call    cell_id=2    dl_tput=300M    ul_tput=28M    dl_deviation=20%    rat=5G    band=78    specific_UE_index=UE_2    duration=60
