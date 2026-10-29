*** Settings ***
Documentation        A test suite with a single test for testing SCF manipulation

Library                             OperatingSystem
Resource                            ../Setup.robot
Resource                            ../Oam.robot
#Library                             ../../python/MultiScf.py            WITH NAME    multiScf

Suite Setup                         Suite setup         listBackupFiles=${FD_ALL}
...                                                     keepAllUeDataInCfgFile=${True}

*** Test Cases ***
SCF Usage

    Examples of using SCF VDU
    Run Keyword if                  ${isAic}            Examples of using SCF VCU

*** Keywords ***
Examples of using SCF VDU
    Dated Log                       START
    # First step: get the VDU SCF - This is to be done for classical BTS Classic and VRAN BTS
    ${vdu_scf_file}                 OAM Get SCF File
    ...                                 dir=${LOG_PATH}
    ...                                 file=SCF_VDU.xml
    ...                                 oam=${GNB_DU.oam}
    Set Suite Variable              ${vdu_scf_file}

    # Second Step: Play with VDU multiScf services
    # Read Version via the MRBTS Managed Object:
    Dated Log                       Load the VDU SCF then get the version
    multiScf.load scf               scf_path=${vdu_scf_file}
    ${toto}                         multiScf.get mo attribute
    ...                                 scope=both
    ...                                 aicListEntity=Vdu
    ...                                 dn=MRBTS-1
    ...                                 attrib=version
    Dated Log                       ==> response is: ${toto}

    # Test the existence of a Managed Object:
    Dated Log                       is MRBTS-1/MNL-1/AMGR-1/LUAC-1 object in vDU SCF ?
    ${toto}                         multiScf.is_object_in_scf
    ...                                 scope=both
    ...                                 aicListEntity=Vdu
    ...                                 dist_name=MRBTS-1/MNL-1/AMGR-1/LUAC-1
    Dated Log                       ==> response is: ${toto}

    # Check a non existing parameter:
    Dated Log                       is MRBTS-1/MNL-1/AMGR-1/LUAC-2 object defined in vDU SCF ?
    ${toto}                         Run keyword and ignore error
    ...                             multiScf.is_object_in_scf
    ...                                 scope=both
    ...                                 aicListEntity=Vdu
    ...                                 dist_name=MRBTS-1/MNL-1/AMGR-1/LUAC-2
    Dated Log                       ==> response is: ${toto}

    # Modify an existing parameter:
    Dated Log                       Modify MRBTS name in vDU SCF
    # multiScf.modify_scf_element     scope=both
    ${toto}                         multiScf.modify_scf_element
    ...                                 scope=both
    ...                                 aicListEntity=Vdu
    ...                                 value=TEST2535
    ...                                 dist_name=MRBTS-1
    ...                                 p_name=btsName
    Dated Log                       ==> response is: ${toto}

    # As VDU SCF was modified, we save it
    Dated Log                       Save the vDU SCF
    ${toto}                         multiScf.save_scf
    ...                                 file_path=${LOG_PATH}/SCF_VDU_modified.xml
    ...                                 second_file_path=${None}
    Dated Log                       ==> response is: ${toto}


Examples of using SCF VCU
    Dated Log                       START
    # This KW,works only with VRAN BTS
    return from keyword if          ${isAic}==${False}              message=Works only on VRAN BTS

    # First step: get the VCU SCF
    ${vcu_scf_file}                 OAM Get SCF File
    ...                                 dir=${LOG_PATH}
    ...                                 file=SCF_VCU.xml
    ...                                 oam=${GNB_CU.oam}
    Set Suite Variable              ${vcu_scf_file}

    # Second Step: Play with VCU multiScf services
    # Read Version via the MRBTS Managed Object:
    Dated Log                       Load VCU SCF then read the version
    multiScf.load scf               second_scf_path=${vcu_scf_file}
    ${toto}                         multiScf.get mo attribute
    ...                                 scope=both
    ...                                 aicListEntity=Vcu
    ...                                 dn=MRBTS-1
    ...                                 attrib=version
    Dated Log                       ==> response is: ${toto}

    # Test the existence of a Managed Object:
    Dated Log                       is MRBTS-1/MNL-1/AMGR-1/LUAC-1 object in vCU SCF ?
    ${toto}                         multiScf.is_object_in_scf
    ...                                 scope=both
    ...                                 aicListEntity=Vcu
    ...                                 dist_name=MRBTS-1/MNL-1/AMGR-1/LUAC-1
    Dated Log                       ==> response is: ${toto}

    # Check a non existing parameter:
    Dated Log                       is MRBTS-1/MNL-1/AMGR-1/LUAC-2 object defined in vCU SCF ?
    ${toto}                         Run keyword and ignore error
    ...                             multiScf.is_object_in_scf
    ...                                 scope=both
    ...                                 aicListEntity=Vcu
    ...                                 dist_name=MRBTS-1/MNL-1/AMGR-1/LUAC-2
    Dated Log                       ==> response is: ${toto}

    # Modify an existing parameter:
    Dated Log                       Modify MRBTS name in vCU SCF
    multiScf.modify_scf_element     scope=both
    ...                             aicListEntity=Vcu
    ...                             value=TEST2535
    ...                             dist_name=MRBTS-1
    ...                             p_name=btsName

    # As VCU SCF was modified, we save it:
    Dated Log                       Save the vCU SCF
    multiScf.save scf               file_path=${None}
    ...                             second_file_path=${LOG_PATH}/SCF_VCU_modified.xml
