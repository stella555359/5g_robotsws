*** Settings ***
Documentation
...    | [5G24R3]      | Data_Volumes_and_Throughput   |
...    | Test case:    | Simple Data Tranfer                                                             |
...    | UEs:          | Using QUALCOMM SDX75, SDX70, SDX60.                                    |
...    | Author:       | Michele                                                                |
...    | Team:         | Ulm SQD64                                                              |
...    | Contact:      | I_PZ_ULM_SQD_64@internal.nsn.com                                       |
...    | Description:  | Keywords for E2E DT                                                  |

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.ue
Library    ute_tshark
Library    String
Library    Collections

Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Resource    ../../../resources/Common/git_handling.robot
Resource    ../../../resources/Common/testline.robot
Resource    ../../../resources/Common/snapshot.robot
Resource    ../../../resources/Common/gnb.robot

Resource    ../../resources/syve_testline.robot
Resource    ../../resources/UEs_handler.robot
Resource    ../../resources/scf_info.robot

Resource    ../resources/commonKeywords.robot
Variables   qc_mapping.yaml
Resource    ANR_XMESH_Keywords.robot

Suite Setup     Prepare TL for Data Transfer Testing
Suite Teardown  Save all Logs and Teardown TL for Data Transfer Testing



*** Variables ***

${RP_CA}                  VRF_RRM
${RP_ORGANIZATION}        VRF_ULM_T03
${RP_LOCATION}            VRF_ULM
${DT_DL}                  DT_DL
${DT_UL}                  DT_UL
${TCP_DL_RATE}            550
${TCP_UL_RATE}            155
${qc_domain}              MN_RAN

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Test Cases ***

TC01_ANR-XMESH_Verification_of_X2_tunnel_establishment_and_deletion_with_same_IPSEC_template_4G
    [Documentation]
    ...  | Test case:    | Automatic X2 Mesh Connectivity with IPSEC in NSA Mode Inter Freq HO |
    ...  | UEs:          | Using S24 U                                   |
    [Setup]    commonKeywords.Setup Test Scenario for Data Transfer Testing
    [Tags]     ANR_Inter_Freq_HO_4G
    Logging to console and setting bts distnames
    ${NRRU_TL0}=      Set variable if
    ...      '${bts0_distName}' == 'MRBTS-452111'       0
    Set suite variable     ${NRRU_TL0}
    Log To Console      TL1 is ${bts1_distName}
    ${NRRU_TL1}=    Set variable if
    ...      '${bts1_distName}' == 'MRBTS-452121'       0
    Set Suite Variable  ${NRRU_TL1}
    IF    '${bts0_distName}' == 'MRBTS-452111'
        @{LNCEL_TL0_to_block_list} =    Create list         MRBTS-452111/NRBTS-402111/NRCELL-111
        Set suite variable     @{LNCEL_TL0_to_block_list}
    END
    IF    '${bts1_distName}' == 'MRBTS-452121'
        @{LNCEL_TL1_to_block_list} =    Create list         MRBTS-452121/NRBTS-402121/NRCELL-111
                                        ...                 MRBTS-452121/LNBTS-452121/LNCEL-21
        Set suite variable     @{LNCEL_TL1_to_block_list}
    END
    Set QC object
    Attenuate cells and set ipref3 traffic
    Attenaution configuration for source and target cells
    Run Keyword And Continue On Failure   Verify SECPOL Object Creation
    Stop data transfer and detach UE
    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation
    ...    dt_name=TCP_${DT_UL}_${FirstUE}
    ...    tput=${TCP_UL_RATE} Mbits/sec
    ...    deviation=20%
    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation
    ...    dt_name=TCP_${DT_DL}_${FirstUE}
    ...    tput=${TCP_DL_RATE} Mbits/sec
    ...    deviation=10%

    [Teardown]    Run keywords
    ...     Test Scenario Teardown for ANR
    ...     AND
    ...    syve_testline.CCRT Test Cases Teardown    node_type=SRAN


TC02_ANR-XMESH_Verification_of_Xn_tunnel_establishment_and_deletion_with_same_IPSEC_template_5G
    [Documentation]
    ...  | Test case:    | Automatic Xn Mesh Connectivity with IPSEC in SA Mode Inter Freq HO |
    ...  | UEs:          | Using S24 U                                   |
    [Setup]    commonKeywords.Setup Test Scenario for Data Transfer Testing
    [Tags]     ANR_SA_Inter_Freq_HO_5G
    Logging to console and setting bts distnames
    ${NRRU_TL0}=      Set variable if
    ...      '${bts0_distName}' == 'MRBTS-452111'       0
    Set suite variable     ${NRRU_TL0}
    Log To Console      TL1 is ${bts1_distName}
    ${NRRU_TL1}=    Set variable if
    ...      '${bts1_distName}' == 'MRBTS-452121'      6
    Set Suite Variable  ${NRRU_TL1}

    IF    '${bts0_distName}' == 'MRBTS-452111'
        @{LNCEL_TL0_to_block_list} =    Create list         MRBTS-452111/LNBTS-452111/LNCEL-21
        Set suite variable     @{LNCEL_TL0_to_block_list}
    END
    IF    '${bts1_distName}' == 'MRBTS-452121'
        @{LNCEL_TL1_to_block_list} =    Create list         MRBTS-452121/LNBTS-452121/LNCEL-31
                                        ...                 MRBTS-452121/LNBTS-452121/LNCEL-21
        Set suite variable     @{LNCEL_TL1_to_block_list}
    END

    Set QC object
    Attenuate cells and set ipref3 traffic
    Attenaution configuration for source and target cells
    Run Keyword And Continue On Failure   Verify SECPOL Object Creation
    Stop data transfer and detach UE

    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation
    ...    dt_name=TCP_${DT_UL}_${FirstUE}
    ...    tput=${TCP_UL_RATE} Mbits/sec
    ...    deviation=20%
    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation
    ...    dt_name=TCP_${DT_DL}_${FirstUE}
    ...    tput=${TCP_DL_RATE} Mbits/sec
    ...    deviation=10%

    [Teardown]    Run keywords
    ...     Test Scenario Teardown for ANR
    ...     AND
    ...    syve_testline.CCRT Test Cases Teardown    node_type=SRAN


TC03_ANR-XMESH_Verification of X2 tunnel establishment and deletion with same IPSEC template_NSA
    [Documentation]
    ...  | Test case:    | Automatic X2 Mesh Connectivity with IPSEC in SA Mode Inter Freq HO |
    ...  | UEs:          | Using S24 U                                   |
    [Setup]    commonKeywords.Setup Test Scenario for Data Transfer Testing
    [Tags]     ANR_NSA_SA_Inter_Freq_HO
    Logging to console and setting bts distnames
    ${NRRU_TL0}=      Set variable if
    ...      '${bts0_distName}' == 'MRBTS-452111'       0
    Set suite variable     ${NRRU_TL0}
    Log To Console      TL1 is ${bts1_distName}
    ${NRRU_TL1}=    Set variable if
    ...      '${bts0_distName}' == 'MRBTS-452111'      6
    Set Suite Variable  ${NRRU_TL1}

    IF    '${bts0_distName}' == 'MRBTS-452111'
        @{LNCEL_TL0_to_block_list} =    Create list         MRBTS-452111/NRBTS-402111/NRCELL-111
        Set suite variable     @{LNCEL_TL0_to_block_list}
    END
    IF    '${bts1_distName}' == 'MRBTS-452121'
        @{LNCEL_TL1_to_block_list} =    Create list         MRBTS-452121/LNBTS-452121/LNCEL-31
                                        ...                 MRBTS-452121/LNBTS-452121/LNCEL-21
        Set suite variable     @{LNCEL_TL1_to_block_list}
    END

    Set QC object
    Attenuate cells and set ipref3 traffic
    Attenaution configuration for source and target cells
    Run Keyword And Continue On Failure   Verify SECPOL Object Creation
    Stop data transfer and detach UE

    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation
    ...    dt_name=TCP_${DT_UL}_${FirstUE}
    ...    tput=${TCP_UL_RATE} Mbits/sec
    ...    deviation=20%
    Run Keyword And Warn On Failure
    ...    taf.ue.Verify Average Throughput With Deviation
    ...    dt_name=TCP_${DT_DL}_${FirstUE}
    ...    tput=${TCP_DL_RATE} Mbits/sec
    ...    deviation=10%

    [Teardown]    Run keywords
    ...     Test Scenario Teardown for ANR
    ...     AND
    ...    syve_testline.CCRT Test Cases Teardown    node_type=SRAN
