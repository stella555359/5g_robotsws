*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for CB008806-A

Resource    ../../resources/SQD65/sqd65_keywords.robot
Resource    ../../resources/SQD65/sqd65_commissioning.robot
Resource    CB008806-A-B9-B10-B11_Commissioning.robot

Library     taf.config.wts    WITH NAME     wts_conf

*** Variables ***

${TEST_MODE}                auto
${EGATE_CONSOLE_LOG}        /opt/iphy/latest/egate_console.log
${UE_CAPA_FDD_TDD}          SEPARATOR=
...                         ue_nr_capabilities=E980D000574D5A13160003C0A02C1262C003387A0609B20C39F30C7942C0E098040623809D46C28C0D608C21A081074804596
...                         C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B8002F800E000BE000280381507C41D608C21A081078804496C98AA091C790E7C639F30C7942C
...                         0E070F027F4000001FD0000000500702A0F88DAC1184301020E0021AB04C55040E3C873E31CF9863C13F8000000FE0000000280381D46C4DC0D608C2
...                         1A081074804596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B8002F800E000BE000280380144C043741D03741D005281C41040000100541C
...                         1401C41000002120542E2080061040C2080008200AC3C4D000E2080000309023070A02000207187850001828000287587850001C4600000C120541E2
...                         30007104000038581587850001C4D000010100EA0701000004840100901060144046809B0010143982A04ED8E7C3853A76C73E1C49D3A76C73E1C29D
...                         3B639F0E044D8E7C3851226C73E1C29D3F03FD7B70A74FC0FF5EDC28913639F0E04ED8E7C3F40A00F840300C0600A00C0480080C07C2A00400000002
...                         00000401000000008000010040000100200000C010000080080000500400200802008000060040000300200001C0100000E008004000000100001000
...                         80040300C010000120080000A00400005802001014050040020000E0080040C01C0100001A0080000E9250020781E5C9280003CB9250060781E0781E
...                         5C9280203C0F03CB92500C0781E0781E0781E079724A0100F03C0F03C0F2E4940381E0781E0781E0781E079704A0000F2E4940001E9C9280103C0F4E
...                         4940101E0781E9C1280003D392500E0781E0781E0781E0781E9C9280303C0F03C0F4E4940001E1C9280703C0F03C0F03C0F03C0F0E4940081E078724
...                         A00C0F03C0F03C382500007860872A6B2A6B052B032B066B036B296B266B016B012B022B056B286B236B076B748C84A0782000012CA4A080000CB292
...                         02000052CA4A080001CB29202000092CA48080002CB292820000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000
...                         192CA4A080006CB292020081C074B292820001D2CA4A07A955552A8BA55574AA2A82C5503AAA0D154A62A93455018AA051549AAA91D55078AAED4321
...                         2809940A880402010180C06030080402010080406030180C060300804020300804020100804020100804020100804020100804020012001028018202
...                         004000080800C20101001804040000101000020200C020080800C00101C00C20200C0180801000101006010040400608080800C02020030404018030
...                         100600C0020440500
${UE_CAPA_FDD_FDD}          SEPARATOR=
...                         ue_nr_capabilities=F5A03C0047D4FFBEFFFFBAF094000782E0203C126BE7FFF6F8016009B3CE3FF30C7942C020DC0C03F1C0128BE20FFCDE51DE4
...                         2BE0821F2CA4B10780105B29BA01893EB1079127C245116F9F8053FF4FFCA2F809FF37944215F0410F96525883C0082D94DD00C49F5883C893E12288
...                         B7CFC029FFA7FE02A0F104003808000001FE7E0000000000FC4100083E0200040320001100C48D0206C93E01FFFF0000D8007C005038280301884C00
...                         C000F07400E0A00C06000040000601200301F00AC9000000AC90000022C9000004002606D602D606D008100000965250400006594941000029652500
...                         940EAA80D5503AA1A005400BC9380F24E03C9280000101002004040100208
${UE_CAPA_TDD_FDD}          SEPARATOR=
...                         ue_nr_capabilities=E9801000074F5A130200020940004824C5800260D42C013601873E618F28581C130180623807506C4DD608C21A08107CA0F00
...                         2CB64C550D0E7C471E819F604F8C73E618F28581C0E1E0B80027800E0009E000C80000E0541F107582308682041F283C0092D931541439F11C78C73E
...                         618F28581C0E1E04FE0000003F8000000320000381D06C28C0D608C21A08107CA0F002CB64C550D0E7C471E819F604F8C73E618F28581C0E1E0B8002
...                         5800E00096000C80000E0541F013582308682041F283C0092D931541439F11C78C73E618F28581C0E1E04FE0000003F8000000320000380061071340
...                         00002C1C04080002020EA0F134003808000008240809004010250540AC1B83E07D1BB00A06500042038113639F0E14E9DB1CF870183FF0600E06318F
...                         D06C003800281C140180C02400700C0500503E050020000000100000200800002004000018020000100100000A008000060040000380200002001000
...                         0120080000A02995379535819581B582958335933594B591B5809581140C04000025949410000196525040000A594941000039652404000125949010
...                         000596524040001A59490100007965240400014594901000089652404000265949010000A96524040002E594900B52AABA555540EAA82C55068AA551
...                         74AA2A93455298AA47154062A81450D003A01540A070381C0E05028140E0700020008010020010020042020040080803006

${GNB_NUM}                  1
${CELL_NUM}                 6

*** Keywords ***

Perform Precondition of Test Scenario
    IF    '${PREV_TEST_STATUS}'=='FAIL'    Bring Airphone TL onair
    Start Logging     pmcounter_enabled=${FALSE}

Perform Postconditions of Test Scenario
    IF    '${TEST_STATUS}'=='FAIL'         Collect AP Sos Report and Snapshots
    UE Deregister
    Stop Logging

Prepare TL
    Sqd65 Common Setup
    Enable CP debug log level online
    Commissioning
    Bring Airphone TL onair

Bring Airphone TL onair
    FOR  ${_}    IN RANGE  1  3
        ${status}=  Run Keyword And Return Status  Run Keywords
        ...  Bring up WTS
        ...  AND  Wait until all gNBs to be onair state
        ...  AND  Verify Airphone Cell Setup completed
        IF  ${status}   RETURN
        Bring Airphone TL in State for Cell Setup
    END
    Fail  AP TL onair failed

Bring up WTS
    Kill WTS Services
    Start WTS for Airphone
    Config WTS for Airphone    pass_regexp=SimMode is ready now  timeout=300

Bring Airphone TL in State for Cell Setup
    Kill WTS Services
    Run Keyword and Ignore Error   Run  sudo ip link delete tunUPF
    Reset Airphone Testline
    Wait For Minimum Required State For Cell Setup for all gNBs

Verify Airphone Cell Setup completed
    FOR    ${cell}    IN RANGE    1  ${CELL_NUM}+1
       Wait Until Keyword Succeeds    1 min    20 sec  Check Airphone Cell Setup  ${cell}
    END

Check Airphone Cell Setup
    [Arguments]                ${cell_id}=1
    Send Egate Command and verify output           set_log flush
    ${find}=     Grep File  ${EGATE_CONSOLE_LOG}   Cell Setup completed for ?CELL_ID:${cell_id}?
    IF  "${find}" == "${EMPTY}"        Fail  Airphone Cell Setup not found : ${cell_id}

Verify A1 Measurement is configured for CA
    [Arguments]  ${ue_id}=1
    ${hysteresis}=     Set Variable  hysteresis: ${a1MeasSCellAddSsbRsrp.a1HysteresisSCellAddSsbRsrp}
    ${threshold}=      Set Variable  Threshold: RSRP ${a1MeasSCellAddSsbRsrp.a1ThresholdSCellAddSsbRsrpFDD}
    ${timeToTrigger}=  Set Variable  TimeToTrigger: 320 ms

    Send Egate Command and verify output    cmd=ue_meas_cfg_disp id=${ue_id}
    ...                                     pass_regexp=Type: event, ${hysteresis}, ${timeToTrigger}, ReportOnLeave: false, EventA1: ${threshold}
    Sleep  1

Verify A1 Measurement is configured on TDD-SCell
    [Arguments]  ${ue_id}=1
    Send Egate Command and verify output    cmd=ue_meas_cfg_disp id=${ue_id}
    ...                              pass_regexp=Type: event, hysteresis: 0, TimeToTrigger: 480 ms, ReportOnLeave: false, EventA1: Threshold: RSRQ 30
    Sleep  1

Verify A1 Measurement is configured on FDD-SCell
    [Arguments]  ${ue_id}=1
    Send Egate Command and verify output    cmd=ue_meas_cfg_disp id=${ue_id}
    ...                              pass_regexp=Type: event, hysteresis: 0, TimeToTrigger: 480 ms, ReportOnLeave: false, EventA1: Threshold: RSRQ 30
    Sleep  1

Verify A2 Measurement is configured on TDD-PCell
    [Arguments]  ${ue_id}=1
    Send Egate Command and verify output    cmd=ue_meas_cfg_disp id=${ue_id}
    ...                              pass_regexp=Type: event, hysteresis: 0, TimeToTrigger: 480 ms, ReportOnLeave: false, EventA2: Threshold: RSRQ 10
    Sleep  1

Verify A1 Measurement is NOT configured on TDD-SCell
    [Arguments]  ${ue_id}=1
    Verify Measurement ID is absent   event_type=A1  ue_id=${ue_id}  carrier_freq=${TDD_SCELL.ssbFrequency}

Verify A1 Measurement is NOT configured on FDD-SCell
    [Arguments]  ${ue_id}=1
    Verify Measurement ID is absent  event_type=A1   ue_id=${ue_id}  carrier_freq=${FDD_SCELL.ssbFrequency}

Verify A2 Measurement is NOT configured on TDD-PCell
    [Arguments]  ${ue_id}=1
    Verify Measurement ID is absent   event_type=A2  ue_id=${ue_id}   carrier_freq=${TDD_PCELL.ssbFrequency}

FDD-SCell addition
    [Arguments]  ${ue_id}=1
    Send NR Measurement Report  event=A1  meas_values=srsrp_nr=11  ue_id=${ue_id}  carrier_freq=${FDD_PCELL.ssbFrequency}
    Sleep   2

TDD-SCell addition
    [Arguments]  ${ue_id}=1
    Send NR Measurement Report  event=A1  meas_values=srsrp_nr=21  ue_id=${ue_id}  carrier_freq=${FDD_PCELL.ssbFrequency}
    Sleep   2

FDD-SCell addition to TDD-PCell
    [Arguments]  ${ue_id}=1
    Send NR Measurement Report  event=A1  meas_values=srsrp_nr=31  ue_id=${ue_id}  carrier_freq=${TDD_PCELL.ssbFrequency}
    Sleep   2

FDD-PCell change to FDD-SCell
    [Arguments]  ${ue_id}=1
    Send NR Measurement Report  event=A1  meas_values=scell=1  ue_id=${ue_id}  carrier_freq=${FDD_SCELL.ssbFrequency}
    ...                         pass_regexp=Intra-eNB handover from EXT_ENB-2.${FDD_PCELL.lcrId} to EXT_ENB-2.${FDD_SCELL.lcrId} performed
    Sleep   2

TDD-PCell change to FDD-SCell
    [Arguments]  ${ue_id}=1
    Send NR Measurement Report  event=A2  meas_values=srsrq_nr=11 srsrp_nr=11 scell=1 scell_rsrp=12 scell_rsrq=12  ue_id=${ue_id}
    ...                         carrier_freq=${TDD_PCELL.ssbFrequency}
    ...                         pass_regexp=Intra-eNB handover from EXT_ENB-2.${TDD_PCELL.lcrId} to EXT_ENB-2.${FDD_SCELL.lcrId} performed
    Sleep   2

FDD-PCell change to TDD-SCell
    [Arguments]  ${ue_id}=1
    Send NR Measurement Report  event=A1  meas_values=scell=1  ue_id=${ue_id}  carrier_freq=${TDD_SCELL.ssbFrequency}
    ...                         pass_regexp=Intra-eNB handover from EXT_ENB-2.${FDD_PCELL.lcrId} to EXT_ENB-2.${TDD_SCELL.lcrId} performed
    Sleep   2

Enable PCell change to TDD-SCell
    PCell change                dist_name=MRBTS-1/NRBTS-1/NRCELL-${FDD_PCELL.lcrId}/NRREL-${NRREL_ID}         value=allowed

Enbaled PCell change to FDD-SCell
    [Arguments]   ${pcell}
    PCell change                dist_name=MRBTS-1/NRBTS-1/NRCELL-${pcell}/NRREL-${NRREL_ID}                   value=allowed

Disable PCell change to TDD-SCell
    PCell change                dist_name=MRBTS-1/NRBTS-1/NRCELL-${FDD_PCELL.lcrId}/NRREL-${NRREL_ID}         value=forbidden

Disable PCell change to FDD-SCell
    [Arguments]   ${pcell}
    PCell change                dist_name=MRBTS-1/NRBTS-1/NRCELL-${pcell}/NRREL-${NRREL_ID}                   value=forbidden

PCell change
    [Arguments]   ${dist_name}  ${value}
    connect.Setup OAM HTTP Session
    Update SCF parameter        dist_name=${dist_name}     parameter=handoverAllowedSA   value=${value}

Register UE on FDD-PCell
    [Arguments]  ${ue_id}=1  ${ue_nr_capabilities}=${UE_CAPA_FDD_TDD}
    Send Egate Command and verify output       cmd=ue_param id=${ue_id} ${ue_nr_capabilities}  fail_regexp=[Ee]rror
    Register UE                                ue_id=${ue_id}  cell_id=${FDD_PCELL.lcrId}

Register UE on TDD-PCell
    [Arguments]  ${ue_id}=1
    Send Egate Command and verify output       cmd=ue_param id=${ue_id} ${UE_CAPA_TDD_FDD}  fail_regexp=[Ee]rror
    Register UE                                ue_id=${ue_id}  cell_id=${TDD_PCELL.lcrId}

Register UE
    [Arguments]  ${ue_id}=1  ${cell_id}=1
    Send Egate Command and verify output       cmd=ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    ...                                        pass_regexp=(location updated to eNB-2 cell ${cell_id})|(already there)
    Send Egate Command and verify output       cmd=ue_param id=${ue_id}
    ...                                        pass_regexp=No configured error case rules for RRC Reconfiguration
    Set Traffic Type                           ue_id=${ue_id}  pdu_id=1  trf_type=internal
    UE Register                                ue_id=${ue_id}
    UE PDU Session Setup                       ue_id=${ue_id}
    Start data traffic in egate                ue_id=${ue_id}  pdu=1  direction=dl

Enable CP debug log level online
    ${aashell_alias}=    Setup Aashell Session
    FOR  ${param_value}  IN
    ...  0x1003F 1
    ...  0x10040 1
    ...  0x10041 5
    ...  0x66001b 1
    ...  0x890001 1
    ...  0x890002 1
    ...  0x890003 1
    ...  0x890004 1
    ...  0x890005 1
    ...  0x890006 1
       taf.ccs.aashell.Execute aashell command   name=${aashell_alias}   command=rad -mwp ${param_value}
    END
    Teardown Aashell Session

Apply Config for B10
    ${scf_file}=               Load current SCF
    Config PCell Switch        cell_id=${FDD_SCELL.lcrId}
    scf.modify_scf_element     dist_name=NRBTS-1/NRCELL-${FDD_SCELL.lcrId}    p_name=csiReportPeriodicity       value=slots160
    ...                        list_name=periodicCsiAcquisition
    Set Element                dist_name=NRBTS-1/NRCELL-${FDD_SCELL.lcrId}    p_name=actCsiMeasEthFlowControl   value=CSIMeasBasedAllUe

    Set Element                dist_name=NRBTS-1/NRCELL-1/NRREL-${NRREL_ID}   p_name=lcrId                      value=${FDD_SCELL.lcrId}
    Set Element                dist_name=NRBTS-1/NRCELL-1/NRREL-${NRREL_ID}   p_name=handoverAllowedSA          value=allowed

    Set Element                NRBTS-1/NRCELL-1/NRHOIF-1                      p_name=ssbFrequency               value=${FDD_SCELL.ssbFrequency}
    Set Element                NRBTS-1/NRCELL-1/NRHOIF-1                      p_name=freqBandIndicatorNR        value=${FDD_SCELL.freqBandIndicatorNR}
    Set Element                NRBTS-1/NRCELL-1/NRHOIF-1                      p_name=ifhoSsbScs                 value=15KHz
    Apply Delta SCF            ${scf_file}  scf_B10
