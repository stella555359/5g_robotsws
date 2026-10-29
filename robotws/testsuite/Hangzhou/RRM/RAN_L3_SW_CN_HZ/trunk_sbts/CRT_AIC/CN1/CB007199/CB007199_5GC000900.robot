*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    master_vDU    RAN_5G    RAN_Aic    CIT    CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    RAN_5G_TDD    vDUCNF00

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/1du/2cell
${NSA_UE_ID}    31
${SA_UE_ID}    1

${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC11
...    84341020E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00
...    05800702A0D883AC1184341020F1018656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6
...    000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50
...    B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD931562439F11C7B027C62471E4
...    39F51CF9863CA1607038784FFF800003FFE0000016001C00F78789A001C4100000216020541E1400071180
...    0000858158788C001C41000006160561E14000710400000858158789A001C46000002160562E2300071040
...    038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800711800388C0000
...    082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C460000041
...    60562E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C046
...    8051013602083A5D83E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF
...    870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D
...    8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C01D00E000C0
...    480080C07C120040000000200000401000000008000010040000100200000C010000080080000500400200
...    80200800006004000038020010000000400004002000024010000060080000A00400005802001024090040
...    0006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282
...    000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004C
...    B29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A8345
...    5298AA4D154062A8145526AAA0F1414178095028140A05028140A05028140A05028140A050281400182020
...    180300801002101002008040300610080100202018030080600C10100C0180403006100801002020180300
...    80100220100C01804030060100C01820200401008010043543E00020406080C0E1416181A2022242628303
...    236383A3E424A4C4E5052545A5E828305A

###counter
${SAMPLES_CELL_AVAIL}    M55601C00002   #number of samples when the cell is available
@{PM_Counters_Check_900}
...    NRCELL-1:NCAV:${SAMPLES_CELL_AVAIL}>0


*** Test Cases ***
5GCSW-CP-CIT006_Verify_Cloud_NSA_And_SA_TDD_cmWave_L3_call_setup_on_NSA_And_SA_cell_is_successful
    [Documentation]
    ...    1. The purpose of this test case is to check SA UE L3 call and NSA L3 call can be concurrently successful
    ...    2. Test Case Steps:
    ...         a. make a NSA UE L3 call
    ...         b. make a SA UE L3 call
    ...    3. Expected Results:
    ...         Step a: NSA UE attach successfully and traffic should be OK
    ...         Step b: SA UE attach successfully and traffic should be OK
    ...         check counter M55601C00002>0
    [Tags]    QC_190149
    Clear Counter Files Cu Aic
    Start To Capture Wireshark Log Aic    NSA_SA_UE_attach
    Repeated NSA and SA L3 Call    repeat_times=5
    Check WireShark Log Aic    a2a_ini_file=${CURDIR}/a2a_900/a2a_UE_attach.ini    name=NSA_SA_UE_attach
    Check Counters Cu Aic    ${PM_Counters_Check_900}

*** Keywords ***
Modify Cfg Aic
    Update Cfg Aic    ue_param id=${SA_UE_ID} ue_nr_capabilities=${SA_Capa_perUE_Full}

NSA UE Attach and Traffic
    [Arguments]    ${ue_id}=11    ${cmd_regexp}=UE IS ACTIVE    ${cmd_endc_regexp}=reported successful RA
    Execute Egate Command    ue_attach id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    ${cmd_endc_regexp}
    traffic should be ok    ue_id=${ue_id}    type=NSA

SA UE Attach and Traffic
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${gw_id}=1    ${nwslice}=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table
    traffic should be ok    ue_id=${ue_id}    type=SA

Repeated NSA and SA L3 Call
    [Arguments]    ${repeat_times}=5
    FOR    ${times}    IN RANGE    0    ${repeat_times}
        NSA UE Attach and Traffic    ue_id=${NSA_UE_ID}
        SA UE Attach and Traffic    ue_id=${SA_UE_ID}
        Release Ues  ue_type=all
        sleep    5s
	END
