*** Settings ***
Documentation
...    Authors: Kamil Ostrzolek, Kinga Starczan, Aleksandra Radziejewska, Maria Podkalicka
...    Contact: kamil.ostrzolek@nokia.com, kinga.starczan@nokia.com, aleksandra.radziejewska@nokia.com, maria.podkalicka@nokia.com
...    This feature has been introduced to cover SFP and QSFP monitoring that is mainly used for troubleshooting
...    purposes or on new installation in case of SFP/QSFP optical interface problem between (a) Radio Units and BB
...    capacity (b) CU & DU (c) Radio Units. The diagnostics information gives a very good indication of the fibre link
...    quality between (a) radio and RAU (b) CU & DU. This feature supports all types of: SFP/SFP+/SFP28/QSFP which is
...    used by Nokia.

Library    BuiltIn
Library    Collections
Library    OperatingSystem
Library    DateTime
Library    XML    use_lxml=True
Library    taf.gnb.oam.coam.admin   WITH NAME   admin
Library    taf.transport.ssh    WITH NAME    ssh
Resource   taf/rfrl/bts/robot/logs_collecting.robot
Resource   resources/5GC002550_ASOD_CommonKeywords.robot
Resource   resources/Basic_Keywords.robot
Resource   resources/ConnectivityKeywords.robot

Force Tags    CA_5G_TRS    QCD_MN_5G    QCP_5G    STATE_GNB_NOT_COMMISSIONED
...   PY36
    ...       CLOUD_5G_ASOD_AEUD
    ...       CRT__WITH__5G_RAN_TDD__WITH__master_cloudbts_cuoam_int
    ...       CRT__WITH__5G_RAN_TDD__WITH__20Bb1_cloudbts

Suite Setup      Run Keywords
...              Prepare Setup   ${scf_path_branch}  ${scf_path_DU}    AND
...              ADMIN connection    AND
...              Create Directory    ${OUTPUT_DIR}/${SUITE_NAME}    AND
...              Setup Logs Collectors

Suite Teardown     Run Keywords
...                ADMIN disconnection  AND
...                Teardown Logs Collectors

*** Variables ***
@{compliance_Code_list}  0  SFF_8472_REV_9_3  SFF_8472_REV_9_5  SFF_8472_REV_10_2  SFF_8472_REV_10_4  SFF_8472_REV_11_0
...    SFF_8472_REV_11_3  SFF_8472_REV_11_4  SFF_8472_REV_12_3    SFF_8636_REV_2_7    UNKNOWN    N/A
@{maxTransmissionRate_list}    0    ${None}    ${0}
@{vendor_list}    FINISAR CORP    FINISAR CORP.    SOURCEPHOTONICS    WTD    NOKIA
@{transmissionDistance_list}    None    N/A
@{txPower_list}    None    N/A    ${None}    -
${scf_path_branch}    ${CURDIR}/../../../../../../../commissionings/Krakow/7_7_UTE5GCLOUDT467/SCF_CU_IPv4_20B.xml
${scf_path_DU}        ${CURDIR}/../../../../../../../commissionings/Krakow/7_7_UTE5GCLOUDT467/SCF_DU_ASOD_20B.xml

*** Test Cases ***
[1]5GC002550-D-a-Initiate_SFP_Monitoring_from_WebEM_for_ASIx(dynamic_data)
    Wait until keyword succeeds    3x    120s    Initiate_SFP_QSFP_monitoring(invocation_of_the_diagnostic)_for_CPRI-N_SMOD(dynamic_data)

[1]5GC002550-D-a-Initiate_SFP_Monitoring_from_WebEM_for_ASIx(static_data- Rx_parameters)
    ${links}    ${SMOD}=    Get SMOD SFP links
    Check if static parameters have a valid value for ports for SMOD    ${links}    ${SMOD}

[1]5GC002550-D-a-Initiate_SFP_Monitoring_from_WemEM_for_ASIx(static_data-SFP_parameters)
    ${links}    ${SMOD}=    Get SMOD SFP links
    Check if static data SFP QSFP have a valid value for ports for SMOD  ${links}     ${SMOD}

[1]5GC002550-D-a-Initiate_SFP_Monitoring_from_WemEM_for_ASIx(static_data-Tx_parameters)
    ${links}    ${SMOD}=    Get SMOD SFP links
    Check if Tx parameters have a valid value for ports for SMOD    ${links}     ${SMOD}

[1]5GC002550-D-a-Initiate_SFP_Monitoring_from_WemEM_for_ASIx(static_data-Temperature_parameters)
    ${links}    ${SMOD}=    Get SMOD SFP links
    Check if temperature parameters have a valid value for ports for SMOD   ${links}    ${SMOD}

[1]5GC002550-D-j-Retrieve_periodic_SFP_QSFP_Snapshot_data
    Wait Until Keyword Succeeds    40x    120s    Check quantity of RD files on BTS
    ${parsed_files}=    Get snapshot and return parsed RD files
    ${BBMOD_SFP_dict}=    Get BBMODs info
    Set suite variable    ${measurementType}    SFPBM
    Check counters from SFP monitoring- file iteration    ${parsed_files}    ${BBMOD_SFP_dict}    ${measurementType}
    ${RMOD_SFP_dict}=    Get RMODs info
    Set suite variable    ${measurementType}    SFPRM
    Check counters from SFP monitoring- file iteration    ${parsed_files}    ${RMOD_SFP_dict}    ${measurementType}

[1]5GC002550-D-i-Dynamic_SFP_Parameters_saved_into_PM_counters_for_RU
    Wait Until Keyword Succeeds    40x    120s    Check quantity of RD files on BTS
    ${parsed_files}=    Get snapshot and return parsed RD files
    ${RMOD_SFP_dict}=    Get RMODs info
    Set suite variable    ${measurementType}    SFPRM
    Check counters from SFP monitoring- file iteration    ${parsed_files}    ${RMOD_SFP_dict}    ${measurementType}

[1]5GC002550-D-c-Dynamic_SFP_Parameters_saved_into_PM_counters_for_ASIx
    Wait Until Keyword Succeeds    40x    120s    Check quantity of RD files on BTS
    ${parsed_files}=    Get snapshot and return parsed RD files
    ${SMOD_SFP_dict}=    Get SMODs info
    Set suite variable    ${measurementType}    SFPSM
    Check counters from SFP monitoring- file iteration    ${parsed_files}    ${SMOD_SFP_dict}    ${measurementType}
