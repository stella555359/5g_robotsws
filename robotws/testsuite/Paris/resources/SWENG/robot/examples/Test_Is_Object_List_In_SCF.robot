*** Settings ***
Documentation          A test checking the existence of an objects list in a SCF file

Library                             OperatingSystem
Resource                            ../Setup.robot
Resource                            ../Oam.robot
#Library                             ../../python/MultiScf.py            WITH NAME    multiScf

Suite Setup                         Suite setup         listBackupFiles=${FD_ALL}
...                                                     keepAllUeDataInCfgFile=${True}

*** Test Cases ***
is_object_list_in_scf Usage

    Examples of Check               scf_type=Vdu
    Run Keyword if                  ${isAic}            Examples of Check      scf_type=Vcu

*** Keywords ***
Examples of Check
    [Arguments]                     ${scf_type}=Vdu
    Dated Log                       START
    # First : Get the SCF
    ${scf_file}                     run keyword if      "${scf_type}" == "Vdu"
    ...                                                 OAM Get SCF File
    ...                                                     dir=${LOG_PATH}
    ...                                                     file=SCF_VDU.xml
    ...                                                     oam=${GNB_DU.oam}
    ...                                         ELSE
    ...                                                 OAM Get SCF File
    ...                                                     dir=${LOG_PATH}
    ...                                                     file=SCF_VCU.xml
    ...                                                     oam=${GNB_CU.oam}

    # Second Step: Load the SCF file
    Dated Log                       Load the ${scf_type} SCF
    run keyword if                  "${scf_type}" == "Vdu"
    ...                                                 multiScf.load scf       scf_path=${scf_file}
    ...         ELSE                                    multiScf.load scf       second_scf_path=${scf_file}

    # Test the existence of one dist_name object AS DONE BEFORE i.e. with "is_object_in_scf" service:
    Dated Log New Line              is MRBTS-1/NRBTS-1/NRULCLPC_PROFILE-0 object in ${scf_type} SCF ?
    ${reponse}                      multiScf.is_object_in_scf
    ...                                 scope=both
    ...                                 aicListEntity=${scf_type}
    ...                                 dist_name=MRBTS-1/NRBTS-1/NRULCLPC_PROFILE-0
    Dated Log                       ==> the "is_object_in_scf()" response is: ${reponse}

    # Test the existence of an objects list containing only one dist_name object (vdu object):
    ${my_dist_name_list} =          Create List         MRBTS-1/NRBTS-1/NRULCLPC_PROFILE-0
    Dated Log New Line              Is the following dist_names list in the ${scf_type} SCF ?
    Dated Log                       ${my_dist_name_list}
    ${reponse}                      multiScf.is_object_list_in_scf
    ...                                 scope=both
    ...                                 aicListEntity=${scf_type}
    ...                                 dist_name_list=${my_dist_name_list}
    Dated Log                       ==> the "is_object_list_in_scf()" response is: ${reponse}

    # Test the existence of an objects list containing only one dist_name object (vcu objetc):
    ${my_dist_name_list} =          Create List         MRBTS-1/MNL-1/MNLENT-1/PMMNL-1
    Dated Log New Line              Is the following dist_names list in the ${scf_type} SCF ?
    Dated Log                       ${my_dist_name_list}
    ${reponse}                      multiScf.is_object_list_in_scf
    ...                                 scope=both
    ...                                 aicListEntity=${scf_type}
    ...                                 dist_name_list=${my_dist_name_list}
    Dated Log                       ==> the "is_object_list_in_scf()" response is: ${reponse}

    # Test the existence of an objects list containing severals really existing dist_name object:
    ${my_dist_name_list} =          Create List         MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1
    ...                                                 MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2
    ...                                                 MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3
    ...                                                 MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4
    Dated Log New Line              Is the following dist_names list in the ${scf_type} SCF ?
    Dated Log                       ${my_dist_name_list}
    ${reponse}                      multiScf.is_object_list_in_scf
    ...                                 scope=both
    ...                                 aicListEntity=${scf_type}
    ...                                 dist_name_list=${my_dist_name_list}
    Dated Log                       ==> the "is_object_list_in_scf()" response is: ${reponse}

    # Test the existence of an objects list containing severals existing and non-existing dist_name object:
    ${my_dist_name_list} =          Create List         MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1
    ...                                                 MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-22
    ...                                                 MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3
    ...                                                 MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-44
    Dated Log New Line              Is the following dist_names list in the ${scf_type} SCF ?
    Dated Log                       ${my_dist_name_list}
    ${reponse}                      multiScf.is_object_list_in_scf
    ...                                 scope=both
    ...                                 aicListEntity=${scf_type}
    ...                                 dist_name_list=${my_dist_name_list}
    Dated Log                       ==> the "is_object_list_in_scf()" response is: ${reponse}

    # Test the existence of an objects list containing severals really existing dist_name object:
    ${my_dist_name_list} =          Create List         MRBTS-1/TNLSVC-1/TNL-3/IPNO-1/IPIF-1
    ...                                                 MRBTS-1/TNLSVC-1/TNL-3/IPNO-1/IPIF-2
    ...                                                 MRBTS-1/TNLSVC-1/TNL-3/IPNO-1/IPIF-3
    ...                                                 MRBTS-1/TNLSVC-1/TNL-3/IPNO-1/IPIF-4
    Dated Log New Line              Is the following dist_names list in the ${scf_type} SCF ?
    Dated Log                       ${my_dist_name_list}
    ${reponse}                      multiScf.is_object_list_in_scf
    ...                                 scope=both
    ...                                 aicListEntity=${scf_type}
    ...                                 dist_name_list=${my_dist_name_list}
    Dated Log                       ==> the "is_object_list_in_scf()" response is: ${reponse}
