*** Settings ***
Documentation
...   author: shangyu.xu@nokia-sbell.com
...   contact: shangyu.xu@nokia-sbell.com
...   Description:
...    Deprecated case removed by civen.chen

#Suite Setup       #AiC Common Suite Setup
#Suite Teardown    #AiC Common Suite Teardown
#
#Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Resource     Resources/CB009444-keyword.robot
#Variables    Resources/CB009444_TestCase_Parameters.py
#Force Tags      CRT_TRUNK
#
#*** Variables ***
#${exp_dl_tp}    1200
#${data_send_dl}    13400M
#${exp_ul_tp}    160
#${data_send_ul}    180M
#${scf_path}    ${commissionings_path}HGZ/7_5_UTE5G401T2062
#${MODIFY_CU_SCF_CB009444_01}     SCF_TL2062_CB009444_CU.xml
#${MODIFY_DU_SCF_CB009444_01}     SCF_TL2062_CB009444_DU.xml
#${UE_TYPE}    ${tl.ues[0].capabilities[1]}
#@{du_counter_id_list}   M55303C12001   M55303C11001  M55303C16001   M55303C15001
#        ...             M55300C00028   M55300C01028   M55300C02028   M55300C03028
#
#
#*** Test Cases ***
##[1]CB009444-I_01_FDD_cell_setup_SA_20MHZ
#[1]CB010411-C_02_5GC000938_Random_Access_procedure_with_PRACH_format1_NSA
#    [Tags]
#    [Setup]    Create Logs Folder For Test Case
#    [Teardown]
#    [Documentation]
#    DU SCF Modification and Commission
#    ...     scf_file_path=${scf_path}/${MODIFY_DU_SCF_CB009444_01}    scf_parameters_list=${MODIFY_SCF_CB009444_DU_01}
#    CU Full Commission Fix Error    path_of_commission_file=${scf_path}/${MODIFY_CU_SCF_CB009444_01}
#    wait until keyword succeeds   900  30   OAM Precondition Cell Should Be Onair
