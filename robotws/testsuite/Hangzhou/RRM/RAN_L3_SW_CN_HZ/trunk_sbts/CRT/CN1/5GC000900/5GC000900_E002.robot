*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_FDD    SBTS00    team-SG02    owner-yige.g.zhang
...    CLOUD_5G_I_BOO_AP_LOO    CRT    release-SBTS22R1
...    STATE_CONFIGURED    RAN_5G

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{ET_E002}

@{ET_E002}
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-2:cellDepType=SA
...    delete:MRBTS-1/NRBTS-1/NRCELL-2:configuredEpsTac
...    MRBTS-1/NRBTS-1/NRCELL-3:cellDepType=NSA
...    delete:MRBTS-1/NRBTS-1/NRCELL-3:trackingAreaDN
...    MRBTS-1/NRBTS-1/NRCELL-4:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-11:cellDepType=SA
...    delete:MRBTS-1/NRBTS-1/NRCELL-11:configuredEpsTac
...    MRBTS-1/NRBTS-1/NRCELL-12:cellDepType=NSA
...    delete:MRBTS-1/NRBTS-1/NRCELL-12:trackingAreaDN

...    MRBTS-1/NRBTS-1:tmpActFeat1=1
...    MRBTS-1/NRBTS-1/SNSSAI-2:sd=13714342
...    MRBTS-1/NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-2:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/TRACKINGAREA-300:fiveGsTac=100
...    MRBTS-1/NRBTS-1/TRACKINGAREA-300:trackingAreaId=300
...    MRBTS-1/NRBTS-1/TRACKINGAREA-300:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2

@{LOCK_CELLS_PARAMTER}
...    NRCELL-1:administrativeState=Locked
...    NRCELL-2:administrativeState=Locked
...    NRCELL-3:administrativeState=Locked
...    NRCELL-4:administrativeState=Locked
...    NRCELL-11:administrativeState=Locked
...    NRCELL-12:administrativeState=Locked
@{UNLOCK_CELLS_PARAMTER}
...    NRCELL-1:administrativeState=Unlocked
...    NRCELL-2:administrativeState=Unlocked
...    NRCELL-3:administrativeState=Unlocked
...    NRCELL-4:administrativeState=Unlocked
...    NRCELL-11:administrativeState=Unlocked
...    NRCELL-12:administrativeState=Unlocked
${ue_nr_capabilities}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC1184341020E90186D6C98AB1A1CF88E
...    3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702A0D883AC1184341020F1018656C98AB121CFB027C471E31238
...    F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50B
...    0381C3C17003FF001C00FFC000B000E0571F11B582308682041F280C2AB64C55850E7C471E300000000000000000000000009FFF000007FFC00
...    0002C003801EF0F1340038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010B02B0F13400388C000
...    0042C0AC5C46000E208007104000028581587850001C4D00000C160562E2680071040038500000102C0AC5C4D000E23000711800001058158B8
...    50001C41000E230000020B02B170A0003882001C41000004160562E26800710400388C0000082C0AC5C28000E23000711800001058158B89A00
...    1C46000E140000040B02B0F11800388C00000C2C0803808D00A2026C041074BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C289
...    13639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF8112040
...    81B1CF810A040D8E7C00170F18C6318C6318C6318C61E8260078005038280381803A01C0018090010180F824008000000040000080200000001
...    00000200800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C0100001400800
...    00B004002048120080000C0339535953582958195833582B594B5933580B581B58095811583B40D04000025949410000196525040000A594901
...    000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B965250400032594901
...    00003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28282F012A05028140A05028140A05028140A05028
...    140A0502800304040300601002004202004010080600C20100200404030060100C018202018030080600C201002004040300601002004402018
...    030080600C0201803040400802010020086A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${ue_eutra_capabilities}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A0003882000000
...    2C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001C04180
...    9A26002E41E24E8913639F0E24E8913639F0E24E8913639F0E24E8913639F0E24E8912639F469D1224498E7D127448931CF8300820000804040
...    08020100C01840001008080100202018030C0002010100C01804030060100C018400010080801004020040100000000

@{PARAMS_Cell1_SA}
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:configuredEpsTac

@{PARAMS_Cell2_NSA}
...    MRBTS-1/NRBTS-1/NRCELL-2:cellDepType=NSA
...    delete:MRBTS-1/NRBTS-1/NRCELL-2:trackingAreaDN
...    MRBTS-1/NRBTS-1/NRCELL-2:configuredEpsTac=777

@{PARAMS_Cell3_BOTH}
...    MRBTS-1/NRBTS-1/NRCELL-3:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-3:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200

@{PARAMS_Cell4_NSA}
...    MRBTS-1/NRBTS-1/NRCELL-4:cellDepType=NSA
...    delete:MRBTS-1/NRBTS-1/NRCELL-4:trackingAreaDN

@{PARAMS_Cell11_BOTH}
...    MRBTS-1/NRBTS-1/NRCELL-11:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-11:configuredEpsTac=777

@{PARAMS_Cell12_SA}
...    MRBTS-1/NRBTS-1/NRCELL-12:cellDepType=SA
...    delete:MRBTS-1/NRBTS-1/NRCELL-12:configuredEpsTac
...    MRBTS-1/NRBTS-1/NRCELL-12:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200

@{PARAMS_Cells_changes_Both}
...    @{PARAMS_Cell1_BOTH_2}
...    @{PARAMS_Cell2_BOTH_2}
...    @{PARAMS_Cell3_BOTH_2}
...    @{PARAMS_Cell4_BOTH_2}
...    @{PARAMS_Cell11_BOTH_2}
...    @{PARAMS_Cell12_BOTH_2}

@{PARAMS_Cell1_BOTH_2}
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-1:configuredEpsTac=777
...    MRBTS-1/NRBTS-1/NRCELL-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200

@{PARAMS_Cell2_BOTH_2}
...    MRBTS-1/NRBTS-1/NRCELL-2:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-2:configuredEpsTac=777
...    MRBTS-1/NRBTS-1/NRCELL-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200

@{PARAMS_Cell3_BOTH_2}
...    MRBTS-1/NRBTS-1/NRCELL-3:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-3:configuredEpsTac=777
...    MRBTS-1/NRBTS-1/NRCELL-3:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200

@{PARAMS_Cell4_BOTH_2}
...    MRBTS-1/NRBTS-1/NRCELL-4:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-4:configuredEpsTac=777
...    MRBTS-1/NRBTS-1/NRCELL-4:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200

@{PARAMS_Cell11_BOTH_2}
...    MRBTS-1/NRBTS-1/NRCELL-11:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-11:configuredEpsTac=777
...    MRBTS-1/NRBTS-1/NRCELL-11:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300

@{PARAMS_Cell12_BOTH_2}
...    MRBTS-1/NRBTS-1/NRCELL-12:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-12:configuredEpsTac=777
...    MRBTS-1/NRBTS-1/NRCELL-12:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200

*** Test Cases ***
5GC000900_ET002_Verify_Classical_Both_TDD_cmWave_one_by_one_cell_reconfigure_and_trackingAreaDN_Change
    [Documentation]
    ...    1.Purpose
    ...      This case is to verify the cell setup when cell is configured for both (SA and NSA) access.
    ...    2. Test Case Steps:
    ...    Step 1. UEs attach successful,cell1 both, cell2 SA, cell3 NSA, cell4 both, cell5 SA, cell6 NSA
    ...         2. Lock cells, form cell1 both->SA,cell2 SA->NSA,cell3 NSA->both,cell4 both->NSA,cell5 SA->both. cell6 NSA->SA
    ...         3. unlock cells
    ...         4. UEs attach successful, cell1 SA, cell2 NSA, cell3 both, cell4 NSA, cell5 both, cell6 SA
    ...         5. Lock cells, from cell1 SA->both,cell2 NSA->both,cell3 both->both,cell4 NSA->both,cell5 change trackingarea,cell6 SA->both
    ...         6. unlock cells
    ...         7. UEs attach successful, cell1 both, cell2 both, cell3 both, cell4 both, cell5 both, cell6 both
    [Tags]    QC_86991    AP_REG
    UEs attach to 6 cells
    lock cell and update Celldeptype
    Unlock Cells
    UEs attach to 6 cells again
    lock cell and update Celldeptype to both
    Unlock Cells
    wait cells on air
    UEs attach to 6 cells with both cell
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F_2N78_2N41_N66_N71

sa ue attach successful
    [Arguments]    ${id}    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Register
    ...    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${id} pdu=${pdu} nwslice=${nwslice} gw=${id}    ${cmd_pdu_regexp}

nsa ue attach successful
    [Arguments]    ${id}    ${target_cells}=1    ${cmd_regexp}=reported successful RA
    Execute Egate Command    ue_attach id=${id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg    ${cmd_regexp}

nsa ue attach successful again
    [Arguments]    ${id}    ${target_cells}=1    ${cmd_regexp}=reported successful RA
    Execute Egate Command    ue_dc_enb_start ue=${id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg    ${cmd_regexp}

NSA UE attach to SA cell failed
    [Arguments]    ${id}    ${cell_id}     ${cmd_regexp}=Dual connectivity trigger failure!
    execute_egate_command    ue_attach id=${id}    UE IS ACTIVE    timeout=20s
    execute_egate_command    ue_dc_enb_start ue=${id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg    ${cmd_regexp}

SA UE attach to NSA cell failed
    [Arguments]    ${id}    ${cmd_regexp}=MIB or SIB1 not recieved
    execute_egate_command    ue_register id=${id}    ${cmd_regexp}

SA UE attach fail again
    [Arguments]    ${id}    ${cmd_regexp}=Kssb.* is invalid
    execute_egate_command    ue_register id=${id}    ${cmd_regexp}

NSA UE attach fail again
    [Arguments]    ${id}    ${cell_id}    ${cmd_regexp}=Dual connectivity trigger failure!
    execute_egate_command     ue_dc_enb_start ue=${id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg

Modify Cfg
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=81-85 amf=1
    Update Cfg    ue_param id=31 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_capabilities}
    Update Cfg    ue_param id=32 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_capabilities}
    Update Cfg    ue_param id=33 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_capabilities}
    Update Cfg    ue_param id=34 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_capabilities}
    Update Cfg    ue_param id=35 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_capabilities}
    Update Cfg    ue_param id=36 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_capabilities}

lock cell and update Celldeptype
    Lock Cells
    Delta Commission Parameters    ${PARAMS_Cell1_SA}
    Delta Commission Parameters    ${PARAMS_Cell2_NSA}
    Delta Commission Parameters    ${PARAMS_Cell3_BOTH}
    Delta Commission Parameters    ${PARAMS_Cell4_NSA}
    Delta Commission Parameters    ${PARAMS_Cell11_BOTH}
    Delta Commission Parameters    ${PARAMS_Cell12_SA}

Lock Cells
    Delta Commission Parameters    ${LOCK_CELLS_PARAMTER}
    Cell Should Be Locked    1
    Cell Should Be Locked    2
    Cell Should Be Locked    3
    Cell Should Be Locked    4
    Cell Should Be Locked    11
    Cell Should Be Locked    12

Unlock Cells
    Delta Commission Parameters    ${UNLOCK_CELLS_PARAMTER}
    Cell Should Be Unlocked    1
    Cell Should Be Unlocked    2
    Cell Should Be Unlocked    3
    Cell Should Be Unlocked    4
    Cell Should Be Unlocked    11
    Cell Should Be Unlocked    12
    sleep    60s      # wait the NSA cell on air

lock cell and update Celldeptype to both
    Lock Cells
    Delta Commission Parameters    ${PARAMS_Cells_changes_Both}

UEs attach to 6 cells
   nsa ue attach successful    31    1
   sa ue attach successful    81    1    1
   NSA UE attach to SA cell failed    32    2
   sa ue attach successful    82    2    1
   nsa ue attach successful    33    3
   SA UE attach to NSA cell failed    83
   nsa ue attach successful    34    4
   sa ue attach successful    84    4    1
   NSA UE attach to SA cell failed    35    11
   sa ue attach successful    85    5    1
   nsa ue attach successful    36    12
   SA UE attach to NSA cell failed    86

UEs attach to 6 cells again
    NSA UE attach fail again    31    1
    sa ue attach successful    81    1    1
    nsa ue attach successful again    32    2
    SA UE attach fail again    82
    nsa ue attach successful again    33    3
    sa ue attach successful    83    3    1
    nsa ue attach successful again    34    4
    SA UE attach fail again    84
    nsa ue attach successful again    35    11
    sa ue attach successful    85    5    1
    NSA UE attach fail again    36    12
    sa ue attach successful    86    6    1

wait cells on air
    wait until keyword succeeds    16 min    10 sec    cells should be on air

UEs attach to 6 cells with both cell
   nsa ue attach successful again    31    1
   sa ue attach successful    81    1    1
   nsa ue attach successful again    32    2
   sa ue attach successful    82    2    1
   nsa ue attach successful again    33    3
   sa ue attach successful    83    3    1
   nsa ue attach successful again    34    4
   sa ue attach successful    84    4    1
   nsa ue attach successful again     35    11
   sa ue attach successful    85    11    2
   nsa ue attach successful again    36    12
   sa ue attach successful    86    12    1
