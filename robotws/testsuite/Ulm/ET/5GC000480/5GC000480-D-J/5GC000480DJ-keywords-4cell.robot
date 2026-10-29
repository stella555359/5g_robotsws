** Settings ***
Documentation   This is a keyword file for 5GC000480-D, part keywords for 4 cell test
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


*** Keywords ***

update iphy file
    [Documentation]    [PRIVATE]    update iphy file
    ...       :Autor: Sylvia Schneider
    Log To Console    update iphy file
    ${ACU_alias}    Connect to Airphone Common Unit
    ssh.Execute    cp /ffs/run/simmode/new_iphy.xml /ffs/run/simmode/new_iphy_orig.xml    connection=${ACU_alias}
    ssh.Download File    /rom/simmode/new_iphy.xml    ${resultBaseDir}/new_iphy.xml    connection=${ACU_alias}

    ${contents}    Get File    ${resultBaseDir}/new_iphy.xml
    ${tmp1}    Split String   ${contents}      <RE>

    ${AEQE_new1}    Set Variable   ${tmp1}[1]
    ${AEQE_new1}    Replace String  ${AEQE_new1}    <serialno>6Q182502974</serialno>   <serialno>6Q182502976</serialno>
    ${AEQE_new1}    Replace String  ${AEQE_new1}    <physicalId>1.1</physicalId>       <physicalId>1.7</physicalId>
    ${AEQE_new1}    Replace String  ${AEQE_new1}    <cell>2.1</cell>                   <cell>2.3</cell>
    ${AEQE_new1}    Replace String  ${AEQE_new1}    <phy_cell_id>50</phy_cell_id>      <phy_cell_id>52</phy_cell_id>
    ${AEQE_new1}    Replace String  ${AEQE_new1}    <serialno>AP01RU01</serialno>      <serialno>AP01RU03</serialno>

    ${AEQE_new2}    Set Variable   ${tmp1}[1]
    ${AEQE_new2}    Replace String  ${AEQE_new2}    <serialno>6Q182502974</serialno>   <serialno>6Q182502977</serialno>
    ${AEQE_new2}    Replace String  ${AEQE_new2}    <physicalId>1.1</physicalId>       <physicalId>1.8</physicalId>
    ${AEQE_new2}    Replace String  ${AEQE_new2}    <cell>2.1</cell>                   <cell>2.4</cell>
    ${AEQE_new2}    Replace String  ${AEQE_new2}    <phy_cell_id>50</phy_cell_id>      <phy_cell_id>53</phy_cell_id>
    ${AEQE_new2}    Replace String  ${AEQE_new2}    <serialno>AP01RU01</serialno>      <serialno>AP01RU04</serialno>

    ${cont_new}    Catenate   SEPARATOR=    ${tmp1}[0]    <RE>
    ${cont_new}    Catenate   SEPARATOR=    ${cont_new}   ${tmp1}[1]
    ${cont_new}    Catenate   SEPARATOR=    ${cont_new}   <RE>
    ${cont_new}    Catenate   SEPARATOR=    ${cont_new}   ${tmp1}[2]
    ${cont_new}    Catenate   SEPARATOR=    ${cont_new}   <RE>
    ${cont_new}    Catenate   SEPARATOR=    ${cont_new}   ${AEQE_new1}
    ${cont_new}    Catenate   SEPARATOR=    ${cont_new}   <RE>
    ${cont_new}    Catenate   SEPARATOR=    ${cont_new}   ${AEQE_new2}
    ${cont_new}    Catenate   SEPARATOR=    ${cont_new}   <RE>
    ${cont_new}    Catenate   SEPARATOR=    ${cont_new}   ${tmp1}[5]
    ${cont_new}    Catenate   SEPARATOR=    ${cont_new}   <RE>
    ${cont_new}    Catenate   SEPARATOR=    ${cont_new}   ${tmp1}[6]

    ${cont_new}    Replace String Using Regexp          ${cont_new}         GSCN>.*<\/GSCN>   GSCN>7916<\/GSCN>  count=4

    Create File    ${resultBaseDir}/new_iphy_upd.xml    ${cont_new}
    ssh.Upload File       ${resultBaseDir}/new_iphy_upd.xml    /rom/simmode/new_iphy.xml   connection=${ACU_alias}


Attach UE11 on eNB 2 cell 1 and handover to gNB 2 cell 2
    [Documentation]    [PRIVATE]    Attach UE11 on gNB 2 cell 1 and handover to gNB 2 cell 2
    ...       :Autor: Sylvia Schneider
    start wireshark trace
    Log To Console    \nAttach UE11 to LTE
    Attach UE to LTE    ue_id=11
    Sleep    2s
    Log To Console    Trigger SgNB Addition to gNB 2 cell 1
    Send Egate Command And Verify Output
    ...    cmd=ue_dc_enb_start ue=11 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    pass_regexp=Proxy .eNB 2 cell 1. reported successful RA
    Sleep    2s
    Log To Console    Trigger Handover to gNB 2 cell 2
    Send Egate Command And Verify Output
    ...    cmd=ue_measurement_send_nr event=A3 srsrp_nr=50 phycell_id=51 nrsrp_nr=80 phycell_id=52 nrsrp_nr=70 meas_id=1 id=11
    ...    pass_regexp=Proxy .eNB 2 cell 2. reported successful RA
    Sleep    2s
    stop wireshark trace     part=UE11
    Sleep    2s


Attach UE12 on eNB 2 cell 1 and handover to gNB 2 cell 3
    [Documentation]    [PRIVATE]    Attach UE12 on gNB 2 cell 1 and handover to gNB 2 cell 3
    ...       :Autor: Sylvia Schneider
    start wireshark trace
    Log To Console    \nAttach UE12 to LTE
    Attach UE to LTE    ue_id=12
    Sleep    2s
    Log To Console    Trigger SgNB Addition to gNB 2 cell 1
    Send Egate Command And Verify Output
    ...    cmd=ue_dc_enb_start ue=12 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    pass_regexp=Proxy .eNB 2 cell 1. reported successful RA
    Sleep    2s
    Log To Console    Trigger Handover to gNB 2 cell 3
    Send Egate Command And Verify Output
    ...    cmd=ue_measurement_send_nr event=A3 srsrp_nr=50 phycell_id=51 nrsrp_nr=80 phycell_id=52 nrsrp_nr=70 meas_id=1 id=12
    ...    pass_regexp=Proxy .eNB 2 cell 3. reported successful RA
    Sleep    2s
    stop wireshark trace     part=UE12
    Sleep    2s


Attach UE13 on eNB 3 cell 1 and handover to gNB 2 cell 4
    [Documentation]    [PRIVATE]    Attach UE13 on gNB 3 cell 1 and handover to gNB 2 cell 4
    ...       :Autor: Sylvia Schneider
    start wireshark trace
    Log To Console    \nAttach UE13 to LTE
    Attach UE to LTE    ue_id=13
    Sleep    2s
    Log To Console    Trigger SgNB Addition to gNB 3 cell 1
    Send Egate Command And Verify Output
    ...    cmd=ue_dc_enb_start ue=13 target_gnb=3 target_cells=1 bearer=2 type=split_scg
    ...    pass_regexp=Proxy .eNB 3 cell 1. reported successful RA
    Sleep    2s
    Log To Console    Trigger Handover to gNB 2 cell 4
    ${cmd}   Set Variable
    ...    ue_measurement_send_nr event=A3 srsrp_nr=50 phycell_id=51 nrsrp_nr=80 phycell_id=52 nrsrp_nr=70 phycell_id=53 nrsrp_nr=65 meas_id=1 id=13
    ${output_egate}   ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=Proxy .eNB 2 cell 4. reported successful RA
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_UE13.txt    ${output_egate}
    Sleep    2s
    stop wireshark trace     part=UE13


verify string present in egate log Inter Sgnb Handover is successful
    [Documentation]    [PRIVATE]    verify string present
    ...       :Autor: Sylvia Schneider
    ${contents}    Get File           ${resultDir}/egate_log_UE13.txt
    Log To Console       check that "Inter Sgnb Handover is successful" present in UE13 egate log
    Run Keyword and Continue on Failure    Should Contain     ${contents}      Inter Sgnb Handover is successful


prepare counters and expected values strong cell
    [Documentation]    [PRIVATE]    prepare counters and expected values strong cell
    ...       :Autor: Sylvia Schneider
    Set Test Variable    @{M55114C00001}          SGNB_NSA_ADMISSION_REQ          2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00002}          SGNB_NSA_ADMISSION_SUCC         2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00003}          SGNB_NSA_NGBR_DRB_REQ           2    NRCELL-1   RACCU
    Set Test Variable    @{M55114C00004}          SGNB_NSA_NGBR_DRB_SUCC          2    NRCELL-1   RACCU
    Set Test Variable    @{M55115C00002_cell1}    SGNB_DU_NSA_ADMISSION_REQ       2    NRCELL-1   RACDU
    Set Test Variable    @{M55115C00003_cell1}    SGNB_DU_NSA_ADMISSION_SUCC      2    NRCELL-1   RACDU

    Set Test Variable    @{M55114C00016_cell2}    SGNB_NSA_HO_ADMISSION_REQ       3    NRCELL-2   RACCU
    Set Test Variable    @{M55114C00017_cell2}    SGNB_NSA_NGBR_DRB_HO_REQ        3    NRCELL-2   RACCU
    Set Test Variable    @{M55114C00018_cell2}    SGNB_NSA_HO_ADMISSION_SUCC      1    NRCELL-2   RACCU
    Set Test Variable    @{M55114C00019_cell2}    SGNB_NSA_NGBR_DRB_HO_SUCC       1    NRCELL-2   RACCU
    Set Test Variable    @{M55115C00002_cell2}    SGNB_DU_NSA_ADMISSION_REQ       1    NRCELL-2   RACDU
    Set Test Variable    @{M55115C00003_cell2}    SGNB_DU_NSA_ADMISSION_SUCC      1    NRCELL-2   RACDU

    Set Test Variable    @{M55114C00016_cell3}    SGNB_NSA_HO_ADMISSION_REQ       0    NRCELL-3   RACCU
    Set Test Variable    @{M55114C00017_cell3}    SGNB_NSA_NGBR_DRB_HO_REQ        0    NRCELL-3   RACCU
    Set Test Variable    @{M55114C00018_cell3}    SGNB_NSA_HO_ADMISSION_SUCC      1    NRCELL-3   RACCU
    Set Test Variable    @{M55114C00019_cell3}    SGNB_NSA_NGBR_DRB_HO_SUCC       1    NRCELL-3   RACCU
    Set Test Variable    @{M55115C00002_cell3}    SGNB_DU_NSA_ADMISSION_REQ       1    NRCELL-3   RACDU
    Set Test Variable    @{M55115C00003_cell3}    SGNB_DU_NSA_ADMISSION_SUCC      1    NRCELL-3   RACDU

    Set Test Variable    @{M55114C00016_cell4}    SGNB_NSA_HO_ADMISSION_REQ       0    NRCELL-4   RACCU
    Set Test Variable    @{M55114C00017_cell4}    SGNB_NSA_NGBR_DRB_HO_REQ        0    NRCELL-4   RACCU
    Set Test Variable    @{M55114C00018_cell4}    SGNB_NSA_HO_ADMISSION_SUCC      1    NRCELL-4   RACCU
    Set Test Variable    @{M55114C00019_cell4}    SGNB_NSA_NGBR_DRB_HO_SUCC       1    NRCELL-4   RACCU
    Set Test Variable    @{M55115C00002_cell4}    SGNB_DU_NSA_ADMISSION_REQ       1    NRCELL-4   RACDU
    Set Test Variable    @{M55115C00003_cell4}    SGNB_DU_NSA_ADMISSION_SUCC      1    NRCELL-4   RACDU


collect pm file and verify counter values strong cell
    [Documentation]    [PRIVATE]    collect pm file and verify counter values strong cell
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    Verify counter values strong cell


Verify counter values strong cell
    [Documentation]    [PRIVATE]    Verify counter values strong cell: all cells
    ...       :Autor: Sylvia Schneider
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}

    Log To Console    \ncounters for cell NRCELL-1 are verified
    &{dict_cell1}   Create Dictionary     M55114C00001    ${M55114C00001}    M55114C00002    ${M55114C00002}
    ...                                   M55114C00003    ${M55114C00003}    M55114C00004    ${M55114C00004}
    ...                                   M55115C00002    ${M55115C00002_cell1}    M55115C00003    ${M55115C00003_cell1}
    Log Dictionary    ${dict_cell1}
    @{dict_keys}    Get Dictionary Keys    ${dict_cell1}

    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict_cell1}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END

    FOR    ${cell_no}    IN    2   3   4
         Verify counters for cell 2 3 4      ${parsed_xml}   ${cell_no}
    END


Verify counters for cell 2 3 4
    [Documentation]    [PRIVATE]    Verify counter values strong cell: cells 2 and 3 and 4
    ...       :Autor: Sylvia Schneider
    [Arguments]         ${parsed_xml}   ${cell_no}
    Log To Console    \ncounters for cell NRCELL-${cell_no} are verified
    &{dict_cell234}   Create Dictionary     M55114C00016    ${M55114C00016_cell${cell_no}}
    ...                                     M55114C00017    ${M55114C00017_cell${cell_no}}
    ...                                     M55114C00018    ${M55114C00018_cell${cell_no}}
    ...                                     M55114C00019    ${M55114C00019_cell${cell_no}}
    ...                                     M55115C00002    ${M55115C00002_cell${cell_no}}
    ...                                     M55115C00003    ${M55115C00003_cell${cell_no}}
    Log Dictionary    ${dict_cell234}
    @{dict_keys}    Get Dictionary Keys    ${dict_cell234}

    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict_cell234}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


verify wireshark strong cell
    [Documentation]    [PRIVATE]    verify wireshark strong cell
    ...       :Autor: Sylvia Schneider
    Set Test Variable     ${UE11_SgNBModReq_physCellId51}      (x2ap.procedureCode == 30) && (nr-rrc.physCellId == 51)
    Set Test Variable     ${UE12_SgNBModReq_physCellId52}      (x2ap.procedureCode == 30) && (nr-rrc.physCellId == 52)
    Set Test Variable     ${SgNBModConfirm_succ}               (x2ap.procedureCode == 30) && (x2ap.X2AP_PDU == 1)
    Set Test Variable     ${UE13_SgNBAddReqAck_physCellId53}   (x2ap.procedureCode == 27) && (nr-rrc.physCellId == 53) && (x2ap.X2AP_PDU == 1)
    Set Test Variable     ${SgNBChangeConfirm_succ}            (x2ap.procedureCode == 34) && (x2ap.X2AP_PDU == 1)
    FOR    ${ue_id}   ${physCellId}   IN
    ...    11         51
    ...    12         52
           verify UE11 UE12 wireshark    ue_id=${ue_id}   physCellId=${physCellId}
    END
    verify UE13 wireshark


verify UE11 UE12 wireshark
    [Documentation]    [PRIVATE]    verify wireshark for UE11 and UE12
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${ue_id}   ${physCellId}
    Log To Console    \nverify wireshark from UE${ue_id}
    Log To Console    verify 1 SgNBModificationRequired message with physCellId=${physCellId} present
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/partUE${ue_id}/SgNBModReq_physCellId${physCellId}.xml
    ...   packet_filter=${UE${ue_id}_SgNBModReq_physCellId${physCellId}}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/partUE${ue_id}/wireshark.pcap
    teardown tshark
    Check 1 message present
    ...   xml_file=${resultDir}/partUE${ue_id}/SgNBModReq_physCellId${physCellId}.xml
    ...   error_message=Wrong number of SgNBModificationRequired message with physCellId=${physCellId}

    Log To Console    verify 1 successful SgNBModificationConfirm message present
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/partUE${ue_id}/SgNBModConfirm.xml
    ...   packet_filter=${SgNBModConfirm_succ}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/partUE${ue_id}/wireshark.pcap
    teardown tshark
    Check 1 message present
    ...   xml_file=${resultDir}/partUE${ue_id}/SgNBModConfirm.xml
    ...   error_message=Wrong number of successful SgNBModificationConfirm message


verify UE13 wireshark
    [Documentation]    [PRIVATE]    verify wireshark for UE13
    ...       :Autor: Sylvia Schneider
    Log To Console    \nverify wireshark from UE13
    Log To Console    verify 1 SgNBAdditionRequestAck message with physCellId=53 present
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/partUE13/SgNBAddReqAck_physCellId53.xml
    ...   packet_filter=${UE13_SgNBAddReqAck_physCellId53}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/partUE13/wireshark.pcap
    teardown tshark
    Check 1 message present
    ...   xml_file=${resultDir}/partUE13/SgNBAddReqAck_physCellId53.xml
    ...   error_message=Wrong number of SgNBAdditionRequestAck message with physCellId=53

    Log To Console    verify 1 successful SgNBChangeConfirm message present
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/partUE13/SgNBChangeConfirm.xml
    ...   packet_filter=${SgNBChangeConfirm_succ}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/partUE13/wireshark.pcap
    teardown tshark
    Check 1 message present
    ...   xml_file=${resultDir}/partUE13/SgNBChangeConfirm.xml
    ...   error_message=Wrong number of successful SgNBChangeConfirm message


Check 1 message present
     [Documentation]    [PRIVATE]    verify wireshark that only 1 message present in filtered file
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${xml_file}    ${error_message}
    ${pdml_xml}    parse xml    ${xml_file}
    ${number_of_messages}   Get Element Count    ${pdml_xml}    xpath=.//field[@name="frame.number"]
    Run Keyword And Continue On Failure
    ...     Should Be Equal As Integers   1   ${number_of_messages}
    ...     ${error_message}

