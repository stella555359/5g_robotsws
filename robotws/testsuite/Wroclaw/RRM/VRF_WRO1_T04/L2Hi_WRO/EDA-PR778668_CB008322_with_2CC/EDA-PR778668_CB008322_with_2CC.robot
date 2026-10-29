*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     taf.sbts.oam.coam.admin    WITH NAME   COAM
Library     testsuite.Wroclaw.RRM.VRF_WRO1_T04.resources.Tokens

Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    release: 25R2

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s
${TRAFFIC_DURATION_BEFORE_PSCELL_SEC}=   20s
${ARTIFACTORY_ROTTA}    https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local
${download_path}    ${ARTIFACTORY_ROTTA}/waczynsk/BSR/BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001.zip
${BSR_FILENAME}    BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001.zip
${PR778668_ue_capa}        SEPARATOR=
...    FFA0F3FF47C5FFE6B5FBF830A60003C005DC0100101A083E60101240BC018FFFC000A00110007C0601808050180E0054371377E6068
...    778452CB2A2088017BFF3039036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7EBDF1F9F87FC7FFB7FFDBFFEDFFF6FFFB7FFDBFFEDFFF
...    518037F9FFB7F9FF8D500005002B66000F00066000F000000941E268007134000001DBFF0000000A07134208009DBFF000000000202
...    68DA000360285122E07FAF6E045C0FF5ED80E043183F7FFFFE1F8007C00780060382C03C00381F84C00F000C035FC16016001C06BF8
...    2C02C00381000800000040020000007F0024400180000000002801CA9A0013C18000000000296595003CAA9A1F001F801E10022007C
...    012006596540108080100202004008004008010B41280

*** Keywords ***
EDA-PR778668_CB008322_with_2CC
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    This case will verify: Verify no WB TAS SRS configured on SCell for TDD+FDD DL+UL CA
    ...    [Configuration]:
    ...    Cell id=1 gnb=2 pci=17:1 tac=200 tdd_cell=on band=n78 nr_arfcn=636666:636666 gscn=7880 chBw=40MHz sCellOperationalMode=dlOnly
    ...    Cell id=2 gnb=2 pci=17:2 tac=200 tdd_cell=on band=n78 nr_arfcn=628334:628334 gscn=7794 chBw=40MHz sCellOperationalMode=dlAndUl
    ...    Cell id=11 gnb=3 pci=20:0 tac=200 tdd_cell=off band=n71 nr_arfcn=134980:127180 gscn=1589 chBw=20MHz sCellOperationalMode=dlAndUl
    ...    2.Test Case Steps:
    ...         a. SA UE1 attach to CELL2 and setup PDU.
    ...         b. UE1 send full DL and UL traffic.
    ...         c. A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD for UE1.
    ...         g. UE1 stop full DL and UL traffic.
    ...    3. Expected Results:
    ...         Step a: UE1 is configured with Subband 4 1port tas srs resource and 1 1port codebook srs.
    ...                 Codebook resource is not reusing with the first tas srs resource.
    ...         Step b: UE1 is reconfigured with 4 1port Wideband tas srs resource is allocated on pcell.
    ...                 codebook srs is not reusing with its first wideband tas srs resource.
    ...         Step c: UE1 is configured with TDD cell-1 as DL only scell and FDD Cell-11 as DL&UL Scell.
    ...                 UE1 psrs is not configured on scells, pcell srs resouces are not changed.
    ...         Step g: UE1 Subband codebook srs resource should keep as not changed. tas srs is not able to allocate.
    ...                 scell is still activated.

    Change ue location to cell 2
    Change default ue capabilities
    Register Ue With Default Pdu Session
    Start Udp Traffic 450Mbps In DL And 150Mbps In UL
    Send A1 measurement to trigger scell addition
    Check Data Traffic


Start Udp Traffic 450Mbps In DL And 150Mbps In UL
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=3
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=150
    Sleep    ${TRAFFIC_DURATION_BEFORE_PSCELL_SEC}

Prepare interfaces for virtual nodes
   Prepare Sa Test Environement
   Start Vm Ethernet Interface    if_name=eth3:ng2    ip_with_mask=10.0.1.102/24
   Start Vm Ethernet Interface    if_name=eth3:ng3    ip_with_mask=10.0.1.103/24
   Start Vm Ethernet Interface    if_name=eth3:ng4    ip_with_mask=10.0.1.104/24
   Start Vm Ethernet Interface    if_name=eth3:ng5    ip_with_mask=10.0.1.105/24
   Start Vm Ethernet Interface    if_name=eth3:ng6    ip_with_mask=10.0.1.106/24

Get and Update BSR File
     [Arguments]  ${download_path}=${download_path}    ${bsr_file_path}=${OUTPUTDIR}/${BSR_FILENAME}
     ${token}=   get_ca_ute_artifactory_token
     Run  sudo wget -d --header='Authorization:Bearer ${token}' ${download_path} -O ${bsr_file_path}
     COAM.setup admin
     ${ret}     COAM.Update Software      ${bsr_file_path}
     COAM.teardown admin

Change ue location to cell 2
    Execute Egate Command And Wait For Data    cmd=ue_change_location id=1 cell=2 enb=2

Change default ue capabilities
    Execute Egate Command And Wait For Data    cmd=ue_param id=1 ue_nr_capabilities=${PR778668_ue_capa}

Send A1 measurement to trigger scell addition
    Execute Egate Command And Wait For Data    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=115 srsrq_nr=40

Check Data Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 scell=0-7 type=pdsch
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=1
    ...    expected_throughput=450    unit=mbps    margin=0.2    direction=dl
    Verify That Traffic Is Scheduled On All SCells In Group

Verify That Traffic Is Scheduled On All SCells In Group
    [Arguments]    ${ue_id}=1    ${cell_index_min}=0    ${cell_index_max}=1    ${type}=pdsch     ${num_of_cells}=2
    Execute Egate Command And Wait For Data
        ...          cmd=ue_stats_nr id=${ue_id} type=${type} scell=${cell_index_min}-${cell_index_max}
        ...          pass_regexp=(CellIndex-[${cell_index_min}-${cell_index_max}][\\s][\\s][1-9].*\\n){${num_of_cells}}