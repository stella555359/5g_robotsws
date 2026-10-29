*** Settings ***
#Resource    ./Resources/CB011016_common_keywords.robot
#Variables    ./Resources/CB011016_variables.py
#
Documentation
...   author: xiaodan.li
...   contact: xiaodan.li@nokia-sbell.com
...   squad group: SG_03
...   Feature CB011016

#Suite Setup    Run Keywords    Common Suite Setup for COAM    AND
#...               Common Case TestLine Setup for CB011016
#
#Suite Teardown    Run Keywords
#...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
#...               Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#
#*** Variables ***
#${golden_scf_name_gnb0_005}    7326_784_SCF_CB011016.xml
#${golden_scf_name}    7326_784_SCF
#${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
#${scf_path}    /opt/workspace/CRT/Master/SCF_file/
#${bts_host}    ${tl.gnbs[${0}].cu.oam_ssh_connection_details.addr}
#
#*** Test Cases ***
#[1]CB011016-5G_005_Activate_Load-Based_Reduced_TX_Path_Power_Saving_interworking_with_cell_switch_off
#    [Documentation]    CB011016 and 5GC00431 can be enabled together in Micro-Cell, Operator should separate the cells
#    ...                with purpose of cell switch off and TX switch off within different PSG. The operation for activate
#    ...                both of them align with CB008392 design.
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_005}
#    sleep    40s
#    Get EnergySavingState    status=reducedEnergySaving    cell_index=${3}
#    Wait until keyword succeeds    6 min    10s    Get EnergySavingState    status=energySaving    cell_index=${31}
#    [Teardown]    run keywords
#    ...    Case recover 005    AND
#    ...    Common Case Teardown for COAM    gnb_list=${gnb_list}
#
#[1]CB010683-A_TC4_PSG parameters modification at cell level
#    [Documentation]    This case is to verify online modification of lbpsCellSOMethod for cells which are using extended
#    ...                configuration. As a result, each cell in power group is switched to notEnergySaving state and new
#    ...                lbpsCellSOMethod is applied for next energy saving actions.
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Online modify NIDD on gnb    gnb_index=${0}    Delete_Mo_Online=${DELETE_MO_ONLINE_GNB1_10683}
#    ...    Add_Mo_Online=${ADD_MO_ONLINE_GNB1_10683}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_10683}
#    sleep    40s
#    Get EnergySavingState    status=reducedEnergySaving    cell_index=${3}
#    Wait until keyword succeeds    6 min    10s    Get EnergySavingState    status=energySaving    cell_index=${31}
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_10683_1}
#    sleep    40s
#    Get EnergySavingState    status=notEnergySaving    cell_index=${3}
#    Get EnergySavingState    status=reducedEnergySaving    cell_index=${31}
#    Wait until keyword succeeds    6 min    10s    Get EnergySavingState    status=energySaving    cell_index=${3}
#    [Teardown]    run keywords
#    ...    Case recover 10683    AND
#    ...    Common Case Teardown for COAM    gnb_list=${gnb_list}
#
#*** Keywords ***
#Common Case TestLine Setup for CB011016
#    Common Case TestLine Setup with singe BTS    gnb_index=${0}    ModifySCF_Beforecommission=True
#    ...    golden_scf_name=${golden_scf_name_gnb0_005}    ListParamterToModify=${LIST_TO_MODIFY_GNB1}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_005}    scf_path=${scf_path}
#    Wait until keyword succeeds    20 min    20s
#    ...    Check the cells status on air    bts_host=${bts_host${gnb_index}}   connection=gnb${gnb_index}
#
#Case recover 005
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_005_Recover}
#
#Case recover 10683
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_10683_Recover}