*** Settings ***
Documentation
...    | Author:       | Martin and Michele                                                  |
...    | Editor:       | Masiar Makkinejad                                                   |
...    | Team:         | CSV Ulm                                                             |
...    | Contact:      |   I_MN_RAN_RD_VRF_ULM_CSV@internal.nsn.com                          |
...    | Description:  | This KW will perform a full Commissioning to load the gNB SCF. |

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    ../../resources/syve_testline.robot
Resource    ../../resources/scf_info.robot
Resource    ../../../resources/Common/git_handling.robot
Resource    ../resources/commonKeywords.robot
Resource    testsuite/Ulm/resources/Common/commissioning.robot

Suite Setup     commonKeywords.Prepare TL
Suite Teardown  commonKeywords.Save all Logs and Teardown TL


*** Test Cases ***
Full Commissioning of Default SCF
    [Documentation]   This keywords performs validation and commissioning of the initialSCFs matching the currently running SW release on all nodes
    ...   of the testline.
    ...   | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com> |
    [Tags]     Full_Commissioning_of_Default_SCF

    #${enb_count}=  Set Variable If   ${tl.enbs != None}   ${tl.enbs.__len__()}   ${0}
    #${gnb_count}=  Set variable If   ${tl.gnbs != None}   ${tl.gnbs.__len__()}   ${0}

    FOR   ${tl_node}   IN   @{PRIMARY_TL_NODES_LIST}
        builtin.Log to console    ${\n}Saving and validating the currently running SCF of node '${tl_node}' ...
        ${node_type}=   builtin.Set Variable    ${{ $tl_node.split('-')[0].lower() }}
        ${node_id}=   builtin.Set Variable    ${{ int($tl_node.split('-')[1]) }}
        scf_info.Collect and Validate the Current SCF file   node_id=${node_id}   node_type=${node_type}

        builtin.Log to console   ${\n}Commissioning the initial SCF matching the current SW release on node '${tl_node}' ...
        builtin.Run Keyword   syve_testline.Load initial ${node_type} scf for CCRT   ${node_id}
    END

