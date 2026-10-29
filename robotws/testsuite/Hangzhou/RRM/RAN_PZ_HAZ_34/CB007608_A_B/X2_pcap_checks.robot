*** Settings ***
Documentation   Contains some keywords to check X2 pcap during NSA call
...             Giangiacomo Guglielmini
#-------------------------------------------------------------------------------------------------------------------------[150 characters]
#Resource    ../../../../resources/sites/Ulm/Common/tcpdump.robot
Resource    Resources/testline.robot
Library         ute_tshark

*** Variables ***



*** Keywords ***

Check number of SgNBAdditionRequest equal
    [Documentation]   check number of SgNBAdditionRequest is equal to num_instances
    [Arguments]    ${num_instances}     ${enb_id}=0
    log to console     Check number of SgNBAdditionRequest
    ${target_dir}=    testline.Get Testcase Log Directory
    ${output}    ute_tshark.read pcap    packet_filter=x2ap.procedureCode == 27    output_type=pdml
    ...   pcap_file_path=${target_dir}/enb${enb_id}_s1x2_tcpdump/enb${enb_id}_s1x2_tcpdump.pcap
     ${SgNBAdditionRequest}  Get Element count  ${output}
     ...    .//field[@name='x2ap.SgNBAdditionRequest_element']
    log to console    detected SgNBAdditionRequestAcknowledge ${SgNBAdditionRequest}
    should be equal  ${SgNBAdditionRequest}   ${num_instances}

Check QCIs in SgNBAdditionRequest
    [Documentation]   check QCIs in SgNBAdditionRequest are equal to target_qci_list
    [Arguments]    ${target_qci_list}    ${enb_id}=0
    log to console    Check QCIs in SgNBAdditionRequest
    ${target_dir}=    testline.Get Testcase Log Directory
    ${output}    ute_tshark.read pcap    packet_filter=x2ap.procedureCode == 27    output_type=pdml
    ...   pcap_file_path=${target_dir}/enb${enb_id}_s1x2_tcpdump/enb${enb_id}_s1x2_tcpdump.pcap
    ${qcis}    get elements    ${output}    .//field[@name='x2ap.SgNBAdditionRequest_element']//field[@name='x2ap.qCI']
    @{established_qcis}   create list
    FOR  ${i}  IN   @{qcis}
        ${qci}  Get element attribute  ${i}  show
        Append To List   ${established_qcis}   ${qci}
    END
    log to console   list of established qcis ${established_qcis}
    log to console   target qcis list ${target_qci_list}
    remove duplicates   ${established_qcis}
    Sort List   ${established_qcis}
    Sort List   ${target_qci_list}
    Lists Should Be Equal   ${established_qcis}    ${target_qci_list}


Check number of successful SgNBAdditionRequestAcknowledge equal
    [Documentation]   check number of successful SgNBAdditionRequestAcknowledge is equal to num_instances
    [Arguments]    ${num_instances}     ${enb_id}=0
    log to console     Check number of successful SgNBAdditionRequestAcknowledge
    ${target_dir}=    testline.Get Testcase Log Directory
    ${output}    ute_tshark.read pcap    packet_filter=x2ap.procedureCode == 27    output_type=pdml
    ...   pcap_file_path=${target_dir}/enb${enb_id}_s1x2_tcpdump/enb${enb_id}_s1x2_tcpdump.pcap
     ${SgNBAdditionRequestAcknowledge}  Get Element count  ${output}
     ...  .//field[@showname='successfulOutcome']//field[@showname='SgNBAdditionRequestAcknowledge']
    log to console    detected SgNBAdditionRequestAcknowledge ${SgNBAdditionRequestAcknowledge}
    should be equal  ${SgNBAdditionRequestAcknowledge}     ${num_instances}

Check number of successful SgNBReconfigurationComplete equal
    [Documentation]   check number of successful SgNBReconfigurationComplete is equal to num_instances
    ...               It fails if unsuccessfull  SgNBReconfigurationComplete occurrs
    [Arguments]    ${num_instances}      ${enb_id}=0
    log to console     Check number of successful SgNBReconfigurationComplete
    ${target_dir}=    testline.Get Testcase Log Directory
    ${output}    ute_tshark.read pcap    packet_filter=x2ap.procedureCode == 28    output_type=pdml
    ...   pcap_file_path=${target_dir}/enb${enb_id}_s1x2_tcpdump/enb${enb_id}_s1x2_tcpdump.pcap
    ${reconfigCompleteList}    get elements    ${output}
    ...         .//field[@name='x2ap.SgNBReconfigurationComplete_element']//field[@name='x2ap.ResponseInformationSgNBReconfComp']
    log to console    reconfigCompleteList ${reconfigCompleteList}
    FOR  ${reconfigMessage}  IN   @{reconfigCompleteList}
           ${showname}  get element attribute  ${reconfigMessage}  showname
           Should Contain  ${showname}   success-SgNBReconfComp
    END
    ${numSuccessReconfigurationComplete}      get element count    ${output}
    ...      .//field[@name='x2ap.SgNBReconfigurationComplete_element']//field[@name='x2ap.ResponseInformationSgNBReconfComp']
    should be equal  ${numSuccessReconfigurationComplete}  ${num_instances}


Check number of SgNBModificationRequest addition equal
    [Documentation]   check number of SgNBModificationRequest to add DRBs is equal to num_instances
    [Arguments]    ${num_instances}      ${enb_id}=0
    log to console     Check number of SgNBModificationRequest addition
    ${target_dir}=    testline.Get Testcase Log Directory
    ${output}    ute_tshark.read pcap    packet_filter=x2ap.procedureCode == 29    output_type=pdml
    ...   pcap_file_path=${target_dir}/enb${enb_id}_s1x2_tcpdump/enb${enb_id}_s1x2_tcpdump.pcap
    ${SgNBModificationRequest}    get element count   ${output}
    ...  .//field[@name='x2ap.SgNBModificationRequest_element']//field[@name='x2ap.e_RABs_ToBeAdded']
    log to console   detected SgNBModificationRequest for DRB addition ${SgNBModificationRequest}
    should be equal  ${SgNBModificationRequest}  ${num_instances}

Check number of SgNBModificationRequest deletion equal
    [Documentation]   check number of SgNBModificationRequest to del DRBs is equal to num_instances
    [Arguments]    ${num_instances}      ${enb_id}=0
    log to console     Check number of SgNBModificationRequest deletion
    ${target_dir}=    testline.Get Testcase Log Directory
    ${output}    ute_tshark.read pcap    packet_filter=x2ap.procedureCode == 29    output_type=pdml
    ...   pcap_file_path=${target_dir}/enb${enb_id}_s1x2_tcpdump/enb${enb_id}_s1x2_tcpdump.pcap
    ${tobereleased}    get element count    ${output}
    ...  .//field[@name='x2ap.SgNBModificationRequest_element']//field[@name='x2ap.e_RABs_ToBeReleased']
    log to console   detected SgNBModificationRequest for DRB deletion ${tobereleased}
    should be equal  ${tobereleased}   ${num_instances}



Check number of SgNBModificationRequest due to radio reasons is equal
    [Documentation]   check number of SgNBModificationRequest due to radio reasons is equal
    [Arguments]    ${num_instances}    ${enb_id}=0
    log to console   Check number of SgNBModificationRequest due to radio reasons is equal
    ${target_dir}=    testline.Get Testcase Log Directory
    ${output}    ute_tshark.read pcap    packet_filter=x2ap.procedureCode == 29    output_type=pdml
    ...   pcap_file_path=${target_dir}/enb${enb_id}_s1x2_tcpdump/enb${enb_id}_s1x2_tcpdump.pcap
    ${SgNBModificationRequestList}    get elements    ${output}
    ...  .//field[@name='x2ap.SgNBModificationRequest_element']//field[@name='x2ap.radioNetwork']
    @{reasons_list}       create list
    FOR  ${SgNBModificationRequest}  IN   @{SgNBModificationRequestList}
           ${reason}  get element attribute  ${SgNBModificationRequest}  showname
           Append To List   ${reasons_list}   ${reason}
    END
    ${numOfRR}   Get Match Count    ${reasons_list}    radioNetwork: action-desirable-for-radio-reasons (31)
    log to console   number of releases due to radio reasons ${numOfRR}
    should be true  ${numOfRR} == ${num_instances}


Check number of SgNBModificationRequest due to radio reasons is one or more
    [Documentation]   check number of SgNBModificationRequest due to radio reasons is one or more
    [Arguments]       ${enb_id}=0
    log to console   Check number of SgNBModificationRequest due to radio reasons is one or more
    ${target_dir}=    testline.Get Testcase Log Directory
    ${output}    ute_tshark.read pcap    packet_filter=x2ap.procedureCode == 29    output_type=pdml
    ...   pcap_file_path=${target_dir}/enb${enb_id}_s1x2_tcpdump/enb${enb_id}_s1x2_tcpdump.pcap
    ${SgNBModificationRequestList}    get elements    ${output}
    ...  .//field[@name='x2ap.SgNBModificationRequest_element']//field[@name='x2ap.radioNetwork']
    @{reasons_list}       create list
    FOR  ${SgNBModificationRequest}  IN   @{SgNBModificationRequestList}
           ${reason}  get element attribute  ${SgNBModificationRequest}  showname
           Append To List   ${reasons_list}   ${reason}
    END
    ${numOfRR}   Get Match Count    ${reasons_list}    radioNetwork: action-desirable-for-radio-reasons (31)
    log to console   number of releases due to radio reasons ${numOfRR}
    should be true  ${numOfRR} > 0

Check number of SgNBModificationRequest due to radio reasons is zero
    [Documentation]   check that no SgNBModificationRequest due to radio reasons has been sent
    [Arguments]    ${enb_id}=0
    log to console   Check number of SgNBModificationRequest due to radio reasons is zero
    ${target_dir}=    testline.Get Testcase Log Directory
    ${output}    ute_tshark.read pcap    packet_filter=x2ap.procedureCode == 29    output_type=pdml
    ...   pcap_file_path=${target_dir}/enb${enb_id}_s1x2_tcpdump/enb${enb_id}_s1x2_tcpdump.pcap
    ${SgNBModificationRequestList}    get elements    ${output}
    ...  .//field[@name='x2ap.SgNBModificationRequest_element']//field[@name='x2ap.radioNetwork']
    @{reasons_list}       create list
    FOR  ${SgNBModificationRequest}  IN   @{SgNBModificationRequestList}
           ${reason}  get element attribute  ${SgNBModificationRequest}  showname
           Append To List   ${reasons_list}   ${reason}
           should not contain  ${reason}   action-desirable-for-radio-reasons
    END
    ${numOfRR}   Get Match Count    ${reasons_list}    radioNetwork: action-desirable-for-radio-reasons (31)
    log to console   number of releases due to radio reasons ${numOfRR}
    should be true  ${numOfRR} == 0


Check number of successful SgNBModificationRequestAcknowledge equal
    [Documentation]   check number of succesfull SgNBModificationRequestAcknowledge is equal to num_instances
    [Arguments]    ${num_instances}      ${enb_id}=0
    log to console     Check number of successful SgNBModificationRequestAcknowledge
    ${target_dir}=    testline.Get Testcase Log Directory
    ${output}    ute_tshark.read pcap    packet_filter=x2ap.procedureCode == 29    output_type=pdml
    ...   pcap_file_path=${target_dir}/enb${enb_id}_s1x2_tcpdump/enb${enb_id}_s1x2_tcpdump.pcap
    ${SgNBModificationRequestAcknowledge}  Get Element count  ${output}
    ...  .//field[@showname='successfulOutcome']//field[@showname='SgNBModificationRequestAcknowledge']
    log to console    detected SgNBModificationRequestAcknowledge ${SgNBModificationRequestAcknowledge}
    should be equal  ${SgNBModificationRequestAcknowledge}  ${num_instances}

Check number of SgNBReleaseRequired due to user-inactivity is zero
    [Documentation]   check that no SgNBReleaseRequired due to user-inactivity has been sent
    [Arguments]    ${enb_id}=0
    log to console   Check number of SgNBReleaseRequired due to user-inactivity
    ${target_dir}=    testline.Get Testcase Log Directory
    ${output}    ute_tshark.read pcap    packet_filter=x2ap.procedureCode == 32    output_type=pdml
    ...   pcap_file_path=${target_dir}/enb${enb_id}_s1x2_tcpdump/enb${enb_id}_s1x2_tcpdump.pcap
    ${SgNBReleaseList}    get elements    ${output}
    ...  .//field[@name='x2ap.SgNBReleaseRequired_element']//field[@name='x2ap.radioNetwork']
    @{reasons_list}       create list
    FOR  ${i}  IN   @{SgNBReleaseList}
       ${reason}  Get element attribute  ${i}  showname
       Append To List   ${reasons_list}   ${reason}
    END
    ${numOfUserInactivity}   Get Match Count    ${reasons_list}    radioNetwork: user-inactivity (42)
    log to console   number of releases due to user-inactivity ${numOfUserInactivity}
    should be true  ${numOfUserInactivity} == 0





Check number of SgNBReleaseRequired due to UE-lost is zero
    [Documentation]   check that no SgNBReleaseRequired due to UE-lost has been sent
    [Arguments]    ${enb_id}=0
    log to console   Check number of SgNBReleaseRequired due to UE-lost
    ${target_dir}=    testline.Get Testcase Log Directory
    ${output}    ute_tshark.read pcap    packet_filter=x2ap.procedureCode == 32    output_type=pdml
    ...   pcap_file_path=${target_dir}/enb${enb_id}_s1x2_tcpdump/enb${enb_id}_s1x2_tcpdump.pcap
    ${SgNBReleaseList}    get elements    ${output}
    ...  .//field[@name='x2ap.SgNBReleaseRequired_element']//field[@name='x2ap.radioNetwork']
    @{reasons_list}       create list
    FOR  ${i}  IN   @{SgNBReleaseList}
       ${reason}  Get element attribute  ${i}  showname
       Append To List   ${reasons_list}   ${reason}
    END
    ${numOfUeLost}   Get Match Count    ${reasons_list}    radioNetwork: radio-connection-with-UE-lost (43)
    log to console   number of releases due to radio-connection-with-UE-lost ${numOfUeLost}
    should be true  ${numOfUeLost} == 0

Check number of successful SgNBReleaseConfirm is one or more
    [Documentation]   check number of successfull SgNBReleaseConfirm is bigger than 0
    [Arguments]    ${enb_id}=0
    log to console    Check number of successful SgNBReleaseConfirm is one or more
    ${target_dir}=    testline.Get Testcase Log Directory
    ${output}    ute_tshark.read pcap    packet_filter=x2ap.procedureCode == 32    output_type=pdml
    ...   pcap_file_path=${target_dir}/enb${enb_id}_s1x2_tcpdump/enb${enb_id}_s1x2_tcpdump.pcap
    ${SgNBReleaseConfirm}  Get Element count  ${output}
    ...  .//field[@showname='successfulOutcome']//field[@showname='SgNBReleaseConfirm']
    log to console   detected SgNBReleaseConfirm ${SgNBReleaseConfirm}
    should be true  ${SgNBReleaseConfirm} > ${0}


