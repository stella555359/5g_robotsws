*** Settings ***
Documentation
...   Test suite for testing feature CB012148
...   author: Wioleta Święs, Ewelina Kiełbasa
...   contact: wioleta.swies@nokia.com, ewelina.kielbasa@nokia.com

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/enb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
#Resource    taf/rfrl/procedures/SISO/General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot.robot
Resource    testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/keywords.robot
Library     ute_ue
Library     testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    sg7keywords
Library     Collections

*** Keywords ***
Check data transfer via Quectel
    [Documentation]    Keyword used to verify throughput (both DL and UL) using Quectel UE.
    ...                Requires useage `Require UE` with same ue_alias before call this KW.
    ...                Intended to be used multiple times within single test case.
    ...                Please define variables such as:
    ...                 - UE_DEFAULT_ALIAS_NAME
    ...                 - DATA_TRANSFER_DEFAULT_DURATION
    ...                 - DEFAULT_PACKET_SIZE
    ...                 - DEFAULT_PROTOCOL
    ...                 - DEFAULT_DEVIATION
    ...                on your Suite/Test level once as this Keyword will automatically loads these as defaults arguments.
    ...                Otherwise pass it normally - expicitly giving each argument desired value.

    [Arguments]    ${throughput_DL}
    ...            ${throughput_UL}
    ...            ${parallel_streams_DL}=1
    ...            ${parallel_streams_UL}=1
    ...            ${ue_alias}=${UE_DEFAULT_ALIAS_NAME}
    ...            ${ue_capabilities}=QUECTEL_UE
    ...            ${duration}=${DATA_TRANSFER_DEFAULT_DURATION}
    ...            ${packet}=${DEFAULT_PACKET_SIZE}
    ...            ${protocol}=${DEFAULT_PROTOCOL}
    ...            ${deviation}=${DEFAULT_DEVIATION}
    ...            ${linux_congestion}=reno
    ...            ${log_throughput}=${False}

    ute_ue.Require UE    ${ue_alias}    capabilities=${ue_capabilities}
    ute_ue.Attach UE    ${ue_alias}
    Sleep    10sec

    ute_ue.Get UE Info    ${ue_alias}    ALL
    Check DL and UL data transfer with Quectel    throughput_DL=${throughput_DL}
    ...                                           throughput_UL=${throughput_UL}
    ...                                           parallel_streams_DL=${parallel_streams_DL}
    ...                                           parallel_streams_UL=${parallel_streams_UL}
    ...                                           ue_alias=${ue_alias}
    ...                                           duration=${duration}
    ...                                           packet=${packet}
    ...                                           protocol=${protocol}
    ...                                           deviation=${deviation}
    ...                                           linux_congestion=${linux_congestion}
    ...                                           log_throughput=${log_throughput}

    [Teardown]    Run keywords    ute_ue.Detach UE    ${ue_alias}    AND
    ...           Run Keyword And Ignore Error    ute_ue.Stop Using UE    ${ue_alias}


Check L3 Call On Cells
    [Arguments]
    ...    ${throughput_DL}
    ...    ${throughput_UL}
    ...    ${parallel_streams_DL}=1
    ...    ${parallel_streams_UL}=1
    ...    ${ue_alias}=${UE_DEFAULT_ALIAS_NAME}
    ...    ${ue_capabilities}=QUECTEL_UE
    ...    ${duration}=${DATA_TRANSFER_DEFAULT_DURATION}
    ...    ${packet}=${DEFAULT_PACKET_SIZE}
    ...    ${protocol}=${DEFAULT_PROTOCOL}
    ...    ${deviation}=${DEFAULT_DEVIATION}
    ...    ${linux_congestion}=reno
    ...    ${log_throughput}=${False}

    @{cells}    gnbcell.Get All Global Cell Ids
    ute_ue.Require UE    ${ue_alias}    capabilities=${ue_capabilities}
    FOR  ${cell}  IN  @{cells}
        sg7keywords.Toggle Cells Barred State  rat=nr  expected_cell_id=${cell}  to_be_barred=${False}
        Check connectivity and data transfer with Quectel on desired PCI
        ...                                           desired_pci=${cell}
        ...                                           throughput_DL=${throughput_DL}
        ...                                           throughput_UL=${throughput_UL}
        ...                                           parallel_streams_DL=${parallel_streams_DL}
        ...                                           parallel_streams_UL=${parallel_streams_UL}
        ...                                           ue_alias=${ue_alias}
        ...                                           duration=${duration}
        ...                                           packet=${packet}
        ...                                           protocol=${protocol}
        ...                                           deviation=${deviation}
        ...                                           linux_congestion=${linux_congestion}
        ...                                           log_throughput=${log_throughput}

    END
    [Teardown]    Run Keywords   Run Keyword And Ignore Error    ute_ue.Stop Using UE    ${ue_alias}    AND
    ...           sg7keywords.Toggle Cells Barred State  rat=nr  to_be_barred=${False}


Load and Activate SCF and Wait for OnAir
    [Arguments]    ${SCF_GNB}    ${SCF_ASIR}    ${SCF_USED}=2
    ${SCF_GNB_PATH}    sg7keywords.Get Default Scf Path     file_name=${SCF_GNB}
    ${SCF_ASIR_PATH}    sg7keywords.Get Default Scf Path    file_name=${SCF_ASIR}

    Perform Bts Full Commissioning    scf_file=${SCF_GNB_PATH}
    ...                               timeout=400
    Perform Full Commissioning On Gnb Asir Hub     scf_path=${SCF_ASIR_PATH}
    Sleep    60s
    gnbcell.Wait For All Cells To Be Onair    timeout=360
    Set Suite Variable    ${SCF_USED}
