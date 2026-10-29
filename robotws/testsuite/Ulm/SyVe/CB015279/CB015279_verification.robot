*** Settings ***
Documentation   Verification for feature CB015279_A_CA_capability_dedicated_mobility_parameters_NSA \n
...             Team: OO_MI_MN_RAN_RD_VRF_ULM_4_53245007_GMS \n
...             Author: Antje Jooss
...             Email:  OO_MI_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com \n
# ----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    String
Library    XML  use_lxml=True
Library    taf.hw.rf_attenuator               WITH NAME    attenuator
Library    ute_tshark


Resource    ../resources/sqd63/verification.robot
Resource    ../resources/carrier_aggregation_verification.robot


*** Keywords ***
Convert PCAP2PDML
    [Documentation]    Convert tracing file from pcap to pdml
    [Arguments]    ${tcp_file}
    ute_tshark.Read Pcap And Save To File    output_type=pdml  pcap_file_path=${resultTestDir}/${tcp_file}.pcap
    ...    filename=${resultTestDir}/${tcp_file}.pdml
    Set Test Variable    ${pcap_file}    ${resultTestDir}/${tcp_file}.pcap
    Set Test Variable    ${pdml_file}    ${resultTestDir}/${tcp_file}.pdml


Verification For CB015279_A_RE_TC03
    [Arguments]    ${tcp_files}
    @{tcp_file_list}  String.Split String  ${tcp_files}  ,

    FOR  ${tcp_file_elem}  IN  @{tcp_file_list}
        CB015279_verification.Convert PCAP2PDML    tcp_file=${tcp_file_elem}
    END

    Verification For CB015279_A_RE_TC03 Part1
    Verification For CB015279_A_RE_TC03 Part2
    Verification For CB015279_A_RE_TC03 Part3


Verification For CB015279_A_RE_TC03 Part1
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB015279_A_RE_TC03_Part1.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=66,71
    ...    physCellId=${physCellIdSourceSCell1},${physCellIdSourceScell2}


Verification For CB015279_A_RE_TC03 Part2
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB015279_A_RE_TC03_Part2.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=66,71
    ...    physCellId=${physCellIdSourceSCell1},${physCellIdSourceScell2}


Verification For CB015279_A_RE_TC03 Part3
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB015279_A_RE_TC03_Part3.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=66,71
    ...    physCellId=${physCellIdSourceSCell1},${physCellIdSourceScell2}


Verification For CB015279_A_RE_TC05
    [Arguments]    ${tcp_files}
    @{tcp_file_list}  String.Split String  ${tcp_files}  ,

    FOR  ${tcp_file_elem}  IN  @{tcp_file_list}
        CB015279_verification.Convert PCAP2PDML    tcp_file=${tcp_file_elem}
    END

    Verification For CB015279_A_RE_TC05 Part1
    Verification For CB015279_A_RE_TC05 Part2
    Verification For CB015279_A_RE_TC05 Part3


Verification For CB015279_A_RE_TC05 Part1
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB015279_A_RE_TC05_Part1.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=66,71
    ...    physCellId=${physCellIdSourceSCell1},${physCellIdSourceScell2}


Verification For CB015279_A_RE_TC05 Part2
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB015279_A_RE_TC05_Part2.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=66,71
    ...    physCellId=${physCellIdSourceSCell1},${physCellIdSourceScell2}


Verification For CB015279_A_RE_TC05 Part3
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB015279_A_RE_TC05_Part3.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=66,71
    ...    physCellId=${physCellIdSourceSCell1},${physCellIdSourceScell2}


Verification For CB015279_A_RE_TC07
    [Arguments]    ${tcp_files}
    @{tcp_file_list}  String.Split String  ${tcp_files}  ,

    FOR  ${tcp_file_elem}  IN  @{tcp_file_list}
        CB015279_verification.Convert PCAP2PDML    tcp_file=${tcp_file_elem}
    END

    Verification For CB015279_A_RE_TC07 Part1
    Verification For CB015279_A_RE_TC07 Part2
    Verification For CB015279_A_RE_TC07 Part3


Verification For CB015279_A_RE_TC07 Part1
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB015279_A_RE_TC07_Part1.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=66,71
    ...    physCellId=${physCellIdSourceSCell1},${physCellIdSourceScell2}


Verification For CB015279_A_RE_TC07 Part2
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB015279_A_RE_TC07_Part2.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=66,71
    ...    physCellId=${physCellIdSourceSCell1},${physCellIdSourceScell2}


Verification For CB015279_A_RE_TC07 Part3
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB015279_A_RE_TC07_Part3.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=66,71
    ...    physCellId=${physCellIdSourceSCell1},${physCellIdSourceScell2}
