*** Settings ***
Documentation                          Suite description

Library     taf.sbts.oam.coam.admin                WITH NAME    coam
Library     String
Library     OperatingSystem
Library     DateTime
Library     XML
Library     Collections
Library         taf.collectors.core         WITH NAME       core
Library         taf.collectors.tcpdump      WITH NAME       tcpdump
Library     ./csvanalyzer.py



*** Variables ***

${target_dir}        /home/ute/Projects/tcpdump_log


*** Keyword ***
Get File Size
    [Arguments]   ${file_path}
#    csn.connect to
#    ...               hostname=${tl.test_pc.default_ssh_connection_details.addr}
#    ...               username=${tl.test_pc.default_ssh_connection_details.username}
#    ...               password=${tl.test_pc.default_ssh_connection_details.password}
#    ...               alias=UTE_CON
#    ${file_info}   csn.Execute   command=ls -la ${file_path}   connection=UTE_CON
#   Set Suite Variable      ${file_size}    ${file_info.split()[4]}

    ${file_info}   run   command=cat ${file_path}|wc -l
    Set Suite Variable      ${file_size}    ${file_info.replace('\n','').strip()}


    [Return]   ${file_size}


Convert wireshark To CSV for 772
    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
    ${csv_title}    Set Variable
    #${title}    Set Variable    -o ntrstr.port:49148 -o ntrstr.defragment:TRUE
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}

Convert tcpdump file to CSV for 772 NSA
    [Arguments]    ${filter}     ${bip_files}   ${csv_file}
    @{csv_title_list1}    Create List     x2ap.SgNBAdditionRequest_element  nr-rrc.longDRX_Cycle
    ...   nr-rrc.rrcReconfigurationComplete_element    x2ap.SgNBReconfigurationComplete_element
    ...   x2ap.success_SgNBReconfComp_element     x2ap.SgNBReleaseRequest_element   x2ap.SgNBModificationConfirm_element
    ...   nr-rrc.rrcReconfigurationComplete_element   x2ap.successfulOutcome_element   x2ap.SgNBModificationRequired_element
    ...   nr-rrc.RRCReconfiguration_element     x2ap.SNStatusTransfer_element    x2ap.E_RABs_SubjectToStatusTransfer_Item_element
    ...   x2ap.e_RAB_ID     x2ap.SgNBAdditionRequestAcknowledge_element    x2ap.E_RABs_Admitted_ToBeAdded_SgNBAddReqAck_Item_element
    ...   x2ap.SgNBReleaseRequestAcknowledge_element     x2ap.UEContextRelease_element
    ...   f1ap.UEContextSetupResponse_element   nr-rrc.drb_Identity    f1ap.UEContextModificationResponse_element
    ...   f1ap.UEContextReleaseComplete_element   f1ap.criticality
    ...   x2ap.SgNBReleaseRequired_element      x2ap.SgNBReleaseConfirm_element
    Convert wireshark To CSV for 772    bip_file=${bip_files}
    ...    output_file=${csv_file}    filter=${filter}    csv_title_list=${csv_title_list1}

Convert tcpdump file to CSV for 772
    [Arguments]    ${filter}     ${bip_files}   ${csv_file}
    @{csv_title_list1}    Create List     ngap.InitialUEMessage_element  ngap.RRCEstablishmentCause
    ...   ngap.DownlinkNASTransport_element    ngap.procedureCode     nr-rrc.longDRX_Cycle   nr-rrc.shortDRX_Cycle
    ...   ngap.UplinkNASTransport_element      ngap.UERadioCapabilityInfoIndication_element
    ...   ngap.InitialContextSetupRequest_element    ngap.InitialContextSetupResponse_element
    ...   ngap.successfulOutcome_element   ngap.PDUSessionResourceSetupRequest_element  ngap.PDUSessionResourceSetupResponse_element
    ...   ngap.PDUSessionResourceReleaseCommand_element    ngap.nas    ngap.UEContextReleaseComplete_element
    ...   ngap.PDUSessionResourceReleaseResponse_element   ngap.UEContextReleaseCommand_element   ngap.criticality
    ...   f1ap.UEContextSetupResponse_element   nr-rrc.drb_Identity    f1ap.UEContextModificationResponse_element
    ...   f1ap.UEContextReleaseComplete_element   f1ap.criticality
    Convert wireshark To CSV for 772    bip_file=${bip_files}
    ...    output_file=${csv_file}    filter=${filter}    csv_title_list=${csv_title_list1}


Check 772 X2AP Msg
    [Arguments]    ${bip_file}    ${csv_file2}    ${csv_file3}   ${csv_file4}   ${csv_file5}    ${csv_file6}   ${csv_file7}
    ...     ${csv_file8}    ${csv_file9}    ${csv_file10}
    #Create Directory   ${target_dir}

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SgNBAdditionRequest_element&&nr-rrc.longDRX_Cycle == 0)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file2}
    Get and Check tcpdumpfile
    ...    item=nr-rrc.longDRX_Cycle
    ...    value=0
    ...    CSV_FILE=${csv_file2}
    ${file_size}=    Get File Size    file_path=${csv_file2}
    should be true  ${file_size} > 1


    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(nr-rrc.rrcReconfigurationComplete_element&&x2ap.SgNBReconfigurationComplete_element&&x2ap.success_SgNBReconfComp_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file3}
    ${file_size}=    Get File Size    file_path=${csv_file3}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SgNBReleaseRequest_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file4}
    ${file_size}=    Get File Size    file_path=${csv_file4}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SgNBModificationConfirm_element&&nr-rrc.rrcReconfigurationComplete_element&&x2ap.successfulOutcome_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file5}
    ${file_size}=    Get File Size    file_path=${csv_file5}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SgNBModificationRequired_element&&nr-rrc.RRCReconfiguration_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file6}
    ${file_size}=    Get File Size    file_path=${csv_file6}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SNStatusTransfer_element&&x2ap.E_RABs_SubjectToStatusTransfer_Item_element&&x2ap.e_RAB_ID == 5)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file7}
    Get and Check tcpdumpfile
    ...    item=x2ap.e_RAB_ID
    ...    value=5
    ...    CSV_FILE=${csv_file7}
    ${file_size}=    Get File Size    file_path=${csv_file7}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SgNBAdditionRequestAcknowledge_element&&nr-rrc.drb_Identity ==4&&nr-rrc.RRCReconfiguration_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file8}
    Get and Check tcpdumpfile
    ...    item=nr-rrc.drb_Identity
    ...    value=4,4
    ...    CSV_FILE=${csv_file8}
    ${file_size}=    Get File Size    file_path=${csv_file8}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SgNBReleaseRequestAcknowledge_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file9}
    ${file_size}=    Get File Size    file_path=${csv_file9}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.UEContextRelease_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file10}
    ${file_size}=    Get File Size    file_path=${csv_file10}
    should be true  ${file_size} > 1

    #Run   rm -rf ${target_dir}/*

Check 772 X2AP Msg for A 15
    [Arguments]    ${bip_file}   ${csv_file1}   ${csv_file2}    ${csv_file3}   ${csv_file4}
    ...  ${csv_file5}    ${csv_file6}   ${csv_file7}
    ...     ${csv_file8}    ${csv_file9}
    #Create Directory   ${target_dir}

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SgNBAdditionRequest_element&&nr-rrc.longDRX_Cycle == 0)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file1}
    Get and Check tcpdumpfile
    ...    item=nr-rrc.longDRX_Cycle
    ...    value=0
    ...    CSV_FILE=${csv_file1}
    ${file_size}=    Get File Size    file_path=${csv_file1}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SgNBAdditionRequestAcknowledge_element&&nr-rrc.drb_Identity ==4&&nr-rrc.RRCReconfiguration_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file2}
    Get and Check tcpdumpfile
    ...    item=nr-rrc.drb_Identity
    ...    value=4,4
    ...    CSV_FILE=${csv_file2}
    ${file_size}=    Get File Size    file_path=${csv_file2}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(nr-rrc.rrcReconfigurationComplete_element&&x2ap.SgNBReconfigurationComplete_element&&x2ap.success_SgNBReconfComp_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file3}
    ${file_size}=    Get File Size    file_path=${csv_file3}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SNStatusTransfer_element&&x2ap.E_RABs_SubjectToStatusTransfer_Item_element&&x2ap.e_RAB_ID == 5)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file4}
    Get and Check tcpdumpfile
    ...    item=x2ap.e_RAB_ID
    ...    value=5
    ...    CSV_FILE=${csv_file4}
    ${file_size}=    Get File Size    file_path=${csv_file4}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SgNBModificationRequired_element&&nr-rrc.RRCReconfiguration_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file5}
    ${file_size}=    Get File Size    file_path=${csv_file5}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SgNBModificationConfirm_element&&nr-rrc.rrcReconfigurationComplete_element&&x2ap.successfulOutcome_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file6}
    ${file_size}=    Get File Size    file_path=${csv_file6}
    should be true  ${file_size} > 1


    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SgNBReleaseRequired_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file7}
    ${file_size}=    Get File Size    file_path=${csv_file7}
    Run Keyword And Ignore Error    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SgNBReleaseConfirm_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file8}
    ${file_size}=    Get File Size    file_path=${csv_file8}
    Run Keyword And Ignore Error    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.UEContextRelease_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file9}
    ${file_size}=    Get File Size    file_path=${csv_file9}
    should be true  ${file_size} > 1

    #Run   rm -rf ${target_dir}/*

Check 772 X2AP Msg for F 21
    [Arguments]    ${bip_file}   ${csv_file1}   ${csv_file2}    ${csv_file3}   ${csv_file4}
    ...   ${csv_file7}    ${csv_file8}    ${csv_file9}
    #Create Directory   ${target_dir}

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SgNBAdditionRequest_element&&nr-rrc.longDRX_Cycle == 0)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file1}
    Get and Check tcpdumpfile
    ...    item=nr-rrc.longDRX_Cycle
    ...    value=0
    ...    CSV_FILE=${csv_file1}
    ${file_size}=    Get File Size    file_path=${csv_file1}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SgNBAdditionRequestAcknowledge_element&&nr-rrc.drb_Identity ==4&&nr-rrc.RRCReconfiguration_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file2}
    Get and Check tcpdumpfile
    ...    item=nr-rrc.drb_Identity
    ...    value=4,4
    ...    CSV_FILE=${csv_file2}
    ${file_size}=    Get File Size    file_path=${csv_file2}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(nr-rrc.rrcReconfigurationComplete_element&&x2ap.SgNBReconfigurationComplete_element&&x2ap.success_SgNBReconfComp_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file3}
    ${file_size}=    Get File Size    file_path=${csv_file3}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SNStatusTransfer_element&&x2ap.E_RABs_SubjectToStatusTransfer_Item_element&&x2ap.e_RAB_ID == 5)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file4}
    Get and Check tcpdumpfile
    ...    item=x2ap.e_RAB_ID
    ...    value=5
    ...    CSV_FILE=${csv_file4}
    ${file_size}=    Get File Size    file_path=${csv_file4}
    should be true  ${file_size} > 1

#    Convert tcpdump file to CSV for 772 NSA
#    ...  filter=(x2ap.SgNBModificationRequired_element&&nr-rrc.RRCReconfiguration_element)
#    ...  bip_files=${bip_file}
#    ...  csv_file=${csv_file5}
#    ${file_size}=    Get File Size    file_path=${csv_file5}
#    should be true  ${file_size} > 1
#    Convert tcpdump file to CSV for 772 NSA
#    ...  filter=(x2ap.SgNBModificationRequest_element)
#    ...  bip_files=${bip_file}
#    ...  csv_file=${csv_file5}
#    ${file_size}=    Get File Size    file_path=${csv_file5}
#    should be true  ${file_size} > 1


    #x2ap.SgNBModificationRequestAcknowledge_element

#    Convert tcpdump file to CSV for 772 NSA
#    ...  filter=(x2ap.SgNBModificationConfirm_element&&nr-rrc.rrcReconfigurationComplete_element&&x2ap.successfulOutcome_element)
#    ...  bip_files=${bip_file}
#    ...  csv_file=${csv_file6}
#    ${file_size}=    Get File Size    file_path=${csv_file6}
#    should be true  ${file_size} > 1
#    Convert tcpdump file to CSV for 772 NSA
#    ...  filter=(x2ap.SgNBModificationRequestAcknowledge_element)
#    ...  bip_files=${bip_file}
#    ...  csv_file=${csv_file6}
#    ${file_size}=    Get File Size    file_path=${csv_file6}
#    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SgNBReleaseRequired_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file7}
    ${file_size}=    Get File Size    file_path=${csv_file7}
    Run Keyword And Ignore Error    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.SgNBReleaseConfirm_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file8}
    ${file_size}=    Get File Size    file_path=${csv_file8}
    Run Keyword And Ignore Error    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(x2ap.UEContextRelease_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file9}
    ${file_size}=    Get File Size    file_path=${csv_file9}
    should be true  ${file_size} > 1



Check 772 NGAP Msg
    [Arguments]    ${bip_file}    ${csv_file2}    ${csv_file3}   ${csv_file4}   ${csv_file5}    ${csv_file6}   ${csv_file7}
    ...     ${csv_file8}    ${csv_file9}   ${csv_file10}   ${csv_file11}    ${csv_file12}   ${csv_file13}
    #Create Directory   ${target_dir}
    Convert tcpdump file to CSV for 772
    ...  filter=(ngap.InitialUEMessage_element&&ngap.RRCEstablishmentCause == 3)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file2}
    Get and Check tcpdumpfile
    ...    item=ngap.RRCEstablishmentCause
    ...    value=3
    ...    CSV_FILE=${csv_file2}
    ${file_size}=    Get File Size    file_path=${csv_file2}
    should be true  ${file_size} > 1


    Convert tcpdump file to CSV for 772
    ...  filter=(ngap.DownlinkNASTransport_element&&ngap.procedureCode == 4)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file3}
    Get and Check tcpdumpfile
    ...    item=ngap.procedureCode
    ...    value=4
    ...    CSV_FILE=${csv_file3}
    ${file_size}=    Get File Size    file_path=${csv_file3}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772
    ...  filter=(ngap.UplinkNASTransport_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file4}
    ${file_size}=    Get File Size    file_path=${csv_file4}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772
    ...  filter=(ngap.UERadioCapabilityInfoIndication_element&&nr-rrc.longDRX_Cycle == 0&&nr-rrc.shortDRX_Cycle == 0)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file5}
    Get and Check tcpdumpfile
    ...    item=nr-rrc.longDRX_Cycle
    ...    value=0
    ...    CSV_FILE=${csv_file5}
    Get and Check tcpdumpfile
    ...    item=nr-rrc.shortDRX_Cycle
    ...    value=0
    ...    CSV_FILE=${csv_file5}
    ${file_size}=    Get File Size    file_path=${csv_file5}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772
    ...  filter=(ngap.InitialContextSetupRequest_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file6}
    ${file_size}=    Get File Size    file_path=${csv_file6}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772
    ...  filter=(ngap.InitialContextSetupResponse_element&&ngap.successfulOutcome_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file7}
    ${file_size}=   Get File Size    file_path=${csv_file7}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772
    ...  filter=(ngap.PDUSessionResourceSetupRequest_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file8}
    ${file_size}=    Get File Size    file_path=${csv_file8}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772
    ...  filter=(ngap.PDUSessionResourceSetupResponse_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file9}
    ${file_size}=    Get File Size    file_path=${csv_file9}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772
    ...  filter=(ngap.PDUSessionResourceReleaseCommand_element&&ngap.nas == 0)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file10}
    Get and Check tcpdumpfile
    ...    item=ngap.nas
    ...    value=0
    ...    CSV_FILE=${csv_file10}
    ${file_size}=    Get File Size    file_path=${csv_file10}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772
    ...  filter=(ngap.PDUSessionResourceReleaseResponse_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file11}
    ${file_size}=    Get File Size    file_path=${csv_file11}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772
    ...  filter=(ngap.UEContextReleaseCommand_element&&ngap.nas == 2)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file12}
    Get and Check tcpdumpfile
    ...    item=ngap.nas
    ...    value=2
    ...    CSV_FILE=${csv_file12}
    ${file_size}=   Get File Size    file_path=${csv_file12}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772
    ...  filter=(ngap.UEContextReleaseComplete_element&&ngap.criticality == 0)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file13}
    Get and Check tcpdumpfile
    ...    item=ngap.criticality
    ...    value=0
    ...    CSV_FILE=${csv_file13}
    ${file_size}=   Get File Size    file_path=${csv_file13}
    should be true  ${file_size} > 1

    #Run   rm -rf ${target_dir}/*

Check 772 F1AP Msg
    [Arguments]    ${bip_file}    ${csv_file1}  ${csv_file2}    ${csv_file3}
    #Create Directory   ${target_dir}
    Convert tcpdump file to CSV for 772
    ...  filter=(f1ap.UEContextSetupResponse_element&&nr-rrc.drb_Identity == 4)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file1}
    Get and Check tcpdumpfile
    ...    item=nr-rrc.drb_Identity
    ...    value=4
    ...    CSV_FILE=${csv_file1}
    ${file_size}=    Get File Size    file_path=${csv_file1}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772
    ...  filter=(f1ap.UEContextModificationResponse_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file2}
    ${file_size}=    Get File Size    file_path=${csv_file2}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772
    ...  filter=(f1ap.UEContextReleaseComplete_element&&f1ap.criticality == 0)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file3}
    Get and Check tcpdumpfile
    ...    item=f1ap.criticality
    ...    value=0
    ...    CSV_FILE=${csv_file3}
    ${file_size}=    Get File Size    file_path=${csv_file3}
    should be true  ${file_size} > 1

    #Run   rm -rf ${target_dir}/*

Check 772 F1AP Msg NSA
    [Arguments]    ${bip_file}    ${csv_file1}  ${csv_file2}    ${csv_file3}
    #Create Directory   ${target_dir}
    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(f1ap.UEContextSetupResponse_element&&nr-rrc.drb_Identity == 4)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file1}
    Get and Check tcpdumpfile
    ...    item=nr-rrc.drb_Identity
    ...    value=4
    ...    CSV_FILE=${csv_file1}
    ${file_size}=    Get File Size    file_path=${csv_file1}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(f1ap.UEContextModificationResponse_element)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file2}
    ${file_size}=    Get File Size    file_path=${csv_file2}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 772 NSA
    ...  filter=(f1ap.UEContextReleaseComplete_element&&f1ap.criticality == 0)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file3}
    Get and Check tcpdumpfile
    ...    item=f1ap.criticality
    ...    value=0
    ...    CSV_FILE=${csv_file3}
    ${file_size}=    Get File Size    file_path=${csv_file3}
    should be true  ${file_size} > 1

    #Run   rm -rf ${target_dir}/*


Get and Check tcpdumpfile
   [Arguments]    ${item}    ${value}   ${CSV_FILE}
   Verify Special Item Value Exist New
   ...      file_path=${CSV_FILE}
   ...      item=${item}
   ...      item_value=${value}


Verify Special Item Value Exist New
    [Arguments]    ${file_path}    ${item}    ${item_value}
    ${special_item_value_list}    get_the_special_item_value    ${file_path}    ${item}
    #List Should Contain Value    ${special_item_value_list}    ${item_value}
    ${status}  Run Keyword And Return Status  List Should Contain Value    ${special_item_value_list}    ${item_value}
    run keyword if  not ${status}  Should Contain Any  ${special_item_value_list}[0]    ${item_value}  0
