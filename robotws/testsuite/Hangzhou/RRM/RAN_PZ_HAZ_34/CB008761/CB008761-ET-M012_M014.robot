*** Settings ***
Documentation
...    author:  dandan.chen@nokia-sbell.com
...    contact: dandan.chen@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/7cells_3T4F_8pipes_N41_2N78_2N71_2N66
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R2    tl-CLOUD_5G_I_BOO_AP_LOO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
@{FAULTS_EXCLUDED_CHECKING}    7305    7107    7304    7308
@{PARAMS_IN_SWCONFIG}
...    0x590072=2
...    0x58057a=4
...    0x580580=3145728
...    0x890003=0
...    0x1002B = 0x17FB    # ERadCcs_AaTraceSwConfId1 - (API_NRTAIML_DATA_PUSH_IND_MSG)
...    0x1005A = 1      # ERadCcs_AaTraceTracingMode (Message trace is printed in all nodes)
...    0x100CE = 0      # ERadCcs_AaTraceRestrictToOwnDomain (Trace all messages)
...    0x1002A = 2      # ERadCcs_AaTraceSwConfUsed (AaTrace enabled in swconfig-only mode. Cannot be reconfigured by external tools)
...    0x890073=0
#...    0x9D0000=5

${ue_capa_6cc}    SEPARATOR=
...    FFA0F200475F7A6B5F8382086000D0017700400404820F990406902600C7FFE000503E0300C07012A1F851BF30342A08A5965440D00BDFF98
...    1C81B7FFDBFFEDFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3FE3FFDBFFEDFFF6FFFB7FFDBFFEDFFF6FFFA8C026FF3FF6FF3FF16A00028015
...    B300078003300078000150FC41DF981A150452CB2A206805EFFCC0E40DBFFEDFFF6FFFB7FFDBFFEDFFF6FFF9FFFE9FFF7C7E7E1FF1FFEDFFF
...    6FFFB7FFDBFFEDFFF6FFFB7FFD460137F9FFB7F9FF8B50001400AD98003C00198003C0000A87E26EFCC0D0A82296595103402F7FE607206DF
...    FF6FFFB7FFDBFFEDFFF6FFFB7FFCFFFF4FFFBE3F3F0FF8FFF6FFFB7FFDBFFEDFFF6FFFB7FFDBFFEA3009BFCFFDBFCFFC5A8000A0056CC001E
...    000CC001E0000541F0637E606854114B2CA881A017BFF3039036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBFFEDF
...    FF6FFFB7FFDBFFEDFFF51804DFE7FEDFE7FE2D40005002B66000F00066000F00002A0F88DBF30342A08A5965440D00B5FF981C81B7FFDBFFE
...    DFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3FE3FFBBFFEDFFF6FFFB7FFDBFFEDFFF518026FF3FF6FF3FF16A00028015B3000780033000780
...    00008A2F13400389A001C28000E20800710400388C000000ADF8000000010389A000007F80000000A2F060003882001C41000E23000713400
...    389A000008ADF80000000513850001C41000E23000713400303800032B27800050062026C046174002F02409F81FEBDB813F03FD7B7027E07
...    FAF6E041C0FF5ED8090418C631FBFFFFF0BC00F800F000C0705807800703F09801E001806BB82C02C00380D77058058007020010000000800
...    4000000DE00C88000001644000002A00B066F2A68064F000029659427800054B2CA1200004A5965490000352CB2A01A8345D2A8AA557541AE
...    80650100400804010020100400804008010100200404008010008020065010020040400801010020040400801010040080401002004802005
...    00200600400C01002801000168250

@{ue_6CC_expect_regexp}
...    pcid:51, scellIdx:0] configure_0_1
...    pcid:51, scellIdx:0] configure_1_1
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    pcid:60, scellIdx:3] configure_1_1
...    pcid:62, scellIdx:4] configure_1_1
...    pcid:63, scellIdx:5] configure_1_1

${ue_id}    1
${j}    1
${otherCC_UEid}    81
${SA_Capa_UE_TF_N77_N71}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4DD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607FFFF82E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C00000000000000000040
...    E1E027FFC00001FFF0000017000038006B0F13400388C0000042C0BC1C46000014160205E0E268000090B010200E0234028809901045D0008
...    C070A244D8E7C38103600002044D80000001C0C631FA0B800F000A070500703009401C0018090010180F82400800000004000008020000000
...    100000200800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C0100001400
...    80000B004002048120080000C0339535953582958195833582B594B5933580B581B58095811583B40D04000025949010000196525040000A5
...    94941000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B96525040003
...    259490100003165240334AA2E955552AABA55154162A82C55068AA531549A2A80C55028AA4D5541E285805E02540A05028140A05028140A05
...    028140A05028140A05000A08080600C02004008404008020100C018402004008080600C02018030404030060100C018402004008080600C02
...    004008804030060100C018040300608080100402004011004008010100200404030060100C018040080120080100202018030080600C02018
...    030080100200100200C002018030D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

${SA_Capa_UE_TFF_N77_N71_N66}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4DD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607FFFF82E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C00000000000000000040
...    E1E027FFC00001FFF0000017000038008B17134003882001C460000041605E0E2080000A0B0102F071180000505808178389A0000242C0408
...    03808D00A20264041174002D0244810206C73E1C081B000010206C00004089B00000090418C631E82E003C00281C1401C0C02500700060240
...    040603E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C0100080000
...    00200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560
...    ED0341000009652404000065949410000296525040000E594901000049652404000165949010000696524040001E594901000089652404000
...    265949010000A96524040002E5949410000C96524040000C594900CD2A8BA55554AAAE95455058AA0B1541A2A94C55268AA031540A2A93555
...    078A160178095028140A05028140A05028140A05028140A050281400282020180300801002101002008040300610080100202018030080600
...    C10100C018040300610080100202018030080100220100C01804030060100C018202004010080100440100200404008010100C01804030060
...    1002004802004008080600C02018030080600C020040080040080300080600C3543E00020406080C0E1416181A2022242628303236383A3E4
...    24A4C4E5052545A5E828305A0
${SA_Capa_UE_TTTF_N77_N41_N41_N71}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4DD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607FFFF82E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C00000000000000000040
...    E1E027FFC00001FFF0000017000038008B1F13400388C001C4D000E1400000B0B02F070A00000485808178388C0000282C040BC1C4D000012
...    16020401C046805101320208BA0017812340810206CF7E3C089B1CF870206C00004089B0000004820C6318F417001E00140E0A00E06012803
...    80030120020301F04801000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000E00
...    8004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B016B036B0
...    12B022B07681A0800004B29202000032CA4A0800014B29282000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B
...    29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669545D2AAAA55574AA2A82C55058AA0D154A62A93455018AA0
...    51549AAA83C50B00BC04A8140A05028140A05028140A05028140A05028140A001610100C018040080108080100402018030804008010100C0
...    18040300608080600C02018030804008010100C018040080110080600C02018030080600C101002008040080220080100202004008080600C
...    02018030080100240100200404030060100C0180403006010020040020040180040300618080100202018030080100202004008D50F800081
...    0182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${SA_Capa_UE_TTFF_N77_N41_N71_N66}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4DD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607FFFF82E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C00000000000000000040
...    E1E027FFC00001FFF000001700003800AB1F0A0003882001C46000E2680000B0B02F070A0000048580817838820000282C040BC1C46000014
...    160205E0E268000090B010200E0234028809901045D000E40B1A0408103639F1E044D8E7C38103600002040D80000811360000002C146318C
...    607A0B800F000A070500703009401C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A
...    008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C033953595358295
...    8195833582B594B5933580B581B58095811583B40D04000025949010000196525040000A59494100003965240400012594901000059652404
...    0001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AA2E955552AABA55154
...    162A82C55068AA531549A2A80C55028AA4D5541E285805E02540A05028140A05028140A05028140A05028140A05000B08080600C020040084
...    04008020100C018402004008080600C02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402
...    004011004008010100200404030060100C018040080120080100202018030080600C02018030080100200100200C002018030C04008010100
...    C0180403006010020046A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B4
${SA_Capa_UE_TTTFF_N77_N41_N41_N71_N66}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4DD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607FFFF82E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C0000000000000000007F
...    FFE027FFC00001FFF000001700003800AB27134003850001C41000E230007134000038585DE0E140000090B0102F071040000505808178388
...    C0000282C040BC1C4D00001216020401C046805101320208BA001D8164408102040D9EFCB8113639F0E040D800008103600002044D8000000
...    5828C6318C0F417001E00140E0A00E0601280380030120020301F048010000000080000100400000002000004010000040080000300400002
...    00200001401000802008020000180100000E008004000000100001000800009004000018020000280100001600800409024010000180672A6
...    B2A6B052B032B066B056B296B266B016B036B012B022B07681A0800004B29202000032CA4A0800014B29282000072CA480800024B29202000
...    0B2CA480800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669545D2AAAA5
...    5574AA2A82C55058AA0D154A62A93455018AA051549AAA83C50B00BC04A8140A05028140A05028140A05028140A05028140A001410100C018
...    040080108080100402018030804008010100C018040300608080600C02018030804008010100C018040080110080600C02018030080600C10
...    1002008040080220080100202004008080600C02018030080100240100200404030060100C018040300601002004002004018004030061AA1
...    F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

${SA_Capa_UE_TTFFF_77_N41_N71_N66_N66}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4DD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607FFFF82E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C00000000000000000040
...    E1E027FFC00001FFF000001700003800AB270A0003882001C41000E2300071340000405817838500000242C040BC1C41000014160205E0E23
...    00000A0B0102F0713400004858081007011A014404C80822E80076059102040810365AF1E044D8E7C38103600002040D80000811360000001
...    60A318C6303D05C0078005038280381804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C01000008
...    008000050040020080200800006004000038020010000000400004002000024010000060080000A004000058020010240900400006019CA9A
...    CA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA48080000CB29282000052CA4A080001CB29202000092CA4808000
...    2CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55174AAAA95
...    55D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142C02F012A05028140A05028140A05028140A05028140A050280050404030060
...    1002004202004010080600C20100200404030060100C018202018030080600C201002004040300601002004402018030080600C0201803040
...    40080201002008802004008080100202018030080600C02004009004008010100C01804030060100C018040080100080100600100C0186A87
...    C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008761/test_data/SBTS00/SCellActivationTrainingConfiguration.json

${sed_hour_cmd}    SEPARATOR=
...    cd /rom/ml_data/bundle/SCellActivation_*/SCellActivation/;
...    sed -i -E 's/"hours": [0-9]+,/"hours": 0,/g' SCellActivationTrainingConfiguration.json

${sed_minute_cmd}    SEPARATOR=
...    cd /rom/ml_data/bundle/SCellActivation_*/SCellActivation/;
...    sed -i -E ' /"initialPeriod"/,/\}/ s/"minutes": [0-9]+/"minutes": 20/;
...    /"accuracyCheckPeriod"/,/\}/ s/"minutes": [0-9]+/"minutes": 20/;
...    /"trainingPeriod"/,/\}/ s/"minutes": [0-9]+/"minutes": 40/' SCellActivationTrainingConfiguration.json

@{UE1_TF_expect_regexp}
...    pcid:60, scellIdx:1

@{UE2_TFF_expect_regexp}
...    pcid:60, scellIdx:1
...    scellIdx:2

@{UE3_TTTF_expect_regexp}
...    scellIdx:1
...    scellIdx:2
...    scellIdx:3

@{UE4_TTFF_expect_regexp}
...    scellIdx:1
...    scellIdx:2
...    scellIdx:3

@{UE5_TTTFF_expect_regexp}
...    scellIdx:1
...    scellIdx:2
...    scellIdx:3
...    scellIdx:4

@{UE6_TTFFF_expect_regexp}
...    scellIdx:1
...    scellIdx:2
...    scellIdx:3
...    scellIdx:4

@{UE7_FT_expect_regexp}
...    scellIdx:1

@{UE8_FFT_expect_regexp}
...    scellIdx:1
...    scellIdx:2

@{UE9_FFTT_expect_regexp}
...    scellIdx:1
...    scellIdx:2
...    scellIdx:3

@{UE10_FFFTT_expect_regexp}
...    scellIdx:1
...    scellIdx:2
...    scellIdx:3
...    scellIdx:4

@{UE11_FFFTTT_expect_regexp}
...    scellIdx:1
...    scellIdx:2
...    scellIdx:3
...    scellIdx:4
...    scellIdx:5

&{CELLS_CARRIER_FREQ}
...     1=504990
...     3=637920
...     11=127450
...     13=424090
...     14=427970

*** Test Cases ***
CB008761-ET-M012_M014
    [Documentation]
    ...    1. This user scenario describes activation of CB008761 feature.
    ...    3. Test Case Steps:
    ...           a. site all cell setup, lock/unlock all TDD cell, check mlTrainingState state
    ...           b. disable/enable feature flag, check mlTrainingState state
    ...           c. preparework and wait trained success
    ...           d. check counter after trained for pcell TDD
    ...           e. check counter after trained for pcell FDD
    ...           f. check counter for 6CC 3T3F with covbasedA1 and A2release
    ...           g. check counter for 6CC 3T3F with covbasedA1 after flag disable
    ...    4. Expected Results:
    ...           a. mlTrainingState state set to Training when at least one TDD cell setup
    ...           b. mlTrainingState state set to Training when feature enable
    ...           c. set mlTrainingStartTime and wait training success
    ...           d. pcell TDD UE, counter as expected
    ...           e. pcell FDD UE, counter as expected
    ...           f. 6CC 3T3F with covbasedA1 and A2release, counter as expected
    ...           g. 6CC 3T3F with covbasedA1 after flag disable, counter as expected
    [Tags]    QC_362171    CA_LABEL-3T3F(2_100M_TDD_n78+60M_TDD_n41+1_20M_FDD_n66+1_10M_FDD_n66+10M_FDD_n71)
    online modify flag and check state
    preparework and wait trained success
    check counter after trained for pcell TDD
    check counter after trained for pcell FDD
    check counter for 6CC 3T3F with covbasedA1 and A2release
    check counter for 6CC 3T3F with covbasedA1 after flag disable

*** Keywords ***
preparework and wait trained success
    preparework for training
    Get mlstate    expect_state=Training    expect_inference=unavailable
    Delta Commission Parameters    ${PARAMS_actMLScellAct_disable}
    wait until keyword succeeds    200    10s    Cells Should Be Onair    check_sib=${True}    timeout=600
    Get mlstate    expect_state=Idle    expect_inference=unavailable
    Delta Commission Parameters    ${PARAMS_actMLScellAct_enable}
    wait until keyword succeeds    200    10s    Cells Should Be Onair    check_sib=${True}    timeout=600
    Get mlstate    expect_state=Training    expect_inference=unavailable
    log to console    wait for state to be trained
    Delta Commission Parameters    ${PARAMS_blind}
    wait until keyword succeeds    200    10s    Cells Should Be Onair    check_sib=${True}    timeout=600
    Clear Counter Files
    Make CA call and show traffic
    wait until keyword succeeds    9200    600s    Get mlstate    expect_state=Trained    expect_inference=available
    log to console    Current expect_state: Trained
    Release ues    ue_type=all
    Check Counters    ${PM_Counters_Check_N1}

online modify flag and check state
    Get mlstate    expect_state=Training    expect_inference=unavailable
    Lock all TDD cell
    Get mlstate    expect_state=Idle    expect_inference=unavailable
    Unlock all TDD cell
    Get mlstate    expect_state=Training    expect_inference=unavailable
    Delta Commission Parameters    ${PARAMS_actMLScellAct_disable}
    wait until keyword succeeds    200    10s    Cells Should Be Onair    check_sib=${True}    timeout=600
    Get mlstate    expect_state=Idle    expect_inference=unavailable
    Delta Commission Parameters    ${PARAMS_actMLScellAct_enable}
    wait until keyword succeeds    200    10s    Cells Should Be Onair    check_sib=${True}    timeout=600
    Get mlstate    expect_state=Training    expect_inference=unavailable

check counter after trained for pcell TDD
    log to console    check counter after trained for pcell TDD
    Delta Commission Parameters    ${PARAMS_blind}
    wait until keyword succeeds    200    10s    Cells Should Be Onair    check_sib=${True}    timeout=600
    Clear Counter Files
    UE 6CC 3T3F    send_large_traffic=True    bufferbase=True
    Release ues    ue_type=all
    Check Counters    ${PM_Counters_Check_one_6CC}
    Clear Counter Files
    UE1 TF CA check    send_large_traffic=True
    Release ues    ue_type=all
    UE2 TFF CA check    send_large_traffic=True
    Release ues    ue_type=all
    UE3 TTTF CA check    send_large_traffic=True    bufferbase=True
    Release ues    ue_type=all
    Check Counters    ${PM_Counters_Check_TF_TFF_TTTF}
    Clear Counter Files
    UE4 TTFF CA check    send_large_traffic=True    bufferbase=True
    Release ues    ue_type=all
    UE5 TTTFF CA check    send_large_traffic=True    bufferbase=True
    Release ues    ue_type=all
    UE6 TTFFF CA check    send_large_traffic=True    bufferbase=True
    Release ues    ue_type=all
    Check Counters    ${PM_Counters_Check_TTFF_TTTFF_TTFFF}

check counter after trained for pcell FDD
    log to console    check counter after trained for pcell FDD
    Clear Counter Files
    UE7 FT CA check    send_large_traffic=True
    Release ues    ue_type=all
    UE8 FFT CA check    send_large_traffic=True
    Release ues    ue_type=all
    UE9 FFTT CA check    send_large_traffic=True
    Release ues    ue_type=all
    UE10 FFFTT CA check    send_large_traffic=True
    Release ues    ue_type=all
    UE11 FFFTTT CA check    send_large_traffic=True
    Release ues    ue_type=all
    Check Counters    ${PM_Counters_Check_FDD}

check counter for 6CC 3T3F with covbasedA1 and A2release
    log to console    check counter for 6CC 3T3F with covbasedA1 and A2release
    Delta Commission Parameters    ${PARAMS_covBasedA1}
    wait until keyword succeeds    200    10s    Cells Should Be Onair    check_sib=${True}    timeout=600
    UE 6CC 3T3F covBasedA1 and A2release

check counter for 6CC 3T3F with covbasedA1 after flag disable
    log to console    check counter for 6CC 3T3F with covbasedA1 after flag disable
    Delta Commission Parameters    ${PARAMS_actMLScellAct_disable}
    wait until keyword succeeds    200    10s    Cells Should Be Onair    check_sib=${True}    timeout=600
    Get mlstate    expect_state=Idle    expect_inference=unavailable
    6CC 3T3F with covbasedA1 after flag disable

6CC 3T3F with covbasedA1 after flag disable
    [Arguments]    ${ue_id}=81    ${target_cell}=2    ${pdu_id}=1
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${ue_capa_6cc}
    Clear Counter Files
    Execute Egate Command    ue_change_location id=${ue_id} cell=${target_cell} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1
    ...    pass_regexp=Initial Context Setup Successful
    ${meas_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    event_type=A1    carrierfreq=641952
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=100
    ...    pass_regexp=${ue_6CC_expect_regexp}    timeout=20s
    Traffic Send For UE    ue_id=${ue_id}    send_large_traffic=True    bufferbase=True
    Check Counters    ${PM_Counters_Check_3T3F_covbase_flagdisable}
    Release ues    ue_type=all

UE7 FT CA check
    [Arguments]    ${send_large_traffic}=False
    ${msg}    SA CA UE Setup PDU Session    ue_id=30    cell_id=11    UE_Capabilities=${SA_Capa_UE_TF_N77_N71}
    ...    expect_passlog=${UE7_FT_expect_regexp}
    Traffic Send    ue_id=30    send_large_traffic=${send_large_traffic}    CC_num=2

UE8 FFT CA check
    [Arguments]    ${send_large_traffic}=False
    ${msg}    SA CA UE Setup PDU Session    ue_id=29    cell_id=11    UE_Capabilities=${SA_Capa_UE_TFF_N77_N71_N66}
    ...    expect_passlog=${UE8_FFT_expect_regexp}
    Traffic Send    ue_id=29    send_large_traffic=${send_large_traffic}    CC_num=3

UE9 FFTT CA check
    [Arguments]    ${send_large_traffic}=False
    ${msg}    SA CA UE Setup PDU Session    ue_id=28    cell_id=11    UE_Capabilities=${SA_Capa_UE_TTFF_N77_N41_N71_N66}
    ...    expect_passlog=${UE9_FFTT_expect_regexp}
    Traffic Send    ue_id=28    send_large_traffic=${send_large_traffic}    CC_num=4

UE10 FFFTT CA check
    [Arguments]    ${send_large_traffic}=False
    ${msg}    SA CA UE Setup PDU Session    ue_id=27    cell_id=11    UE_Capabilities=${SA_Capa_UE_TTFFF_77_N41_N71_N66_N66}
    ...    expect_passlog=${UE10_FFFTT_expect_regexp}
    Traffic Send    ue_id=27    send_large_traffic=${send_large_traffic}    CC_num=4    bufferbase=True

UE11 FFFTTT CA check
    [Arguments]    ${send_large_traffic}=False
    ${msg}    SA CA UE Setup PDU Session    ue_id=26    cell_id=11    UE_Capabilities=${ue_capa_6cc}
    ...    expect_passlog=${UE11_FFFTTT_expect_regexp}
    Traffic Send    ue_id=26    send_large_traffic=${send_large_traffic}    CC_num=5    bufferbase=True

preparework for training
    Execute Cmd On Pc  sudo timedatectl set-timezone Etc/UTC
#    Execute Cmd On Pc  scp ${file} toor4nsn@192.168.255.1:/tmp/
#    execute cmd on bts  mv /tmp/SCellActivationTrainingConfiguration.json /rom/ml_data/bundle/SCellActivation_*/SCellActivation/
    execute cmd on bts    ${sed_hour_cmd}
    execute cmd on bts    ${sed_minute_cmd}
    execute cmd on bts    cd /rom/ml_data/bundle/SCellActivation_*/SCellActivation/;cat SCellActivationTrainingConfiguration.json
    ${time}=    Get Time    format=%H:%M
    log to console    Current time: ${time}
    ${hour}=    Evaluate    int(str("${time}").split(":")[0].split(" ")[1])
    ${minute}=    Evaluate    int(str("${time}").split(":")[1])
    log to console    Current hour: ${hour}, Current minute: ${minute}
    ${set_hour1}=    Evaluate    ${hour}+1
    ${set_hour2}=    Evaluate    ${hour}+2
    Run Keyword If    ${minute} >= 30    Delta Commission Parameters
    ...    MNL-1/MNLENT-1/FEATCADM-1/MLCADM-1:mlTrainingParams:mlTrainingStartTime=${set_hour2}
    Run Keyword If    ${minute} < 30    Delta Commission Parameters
    ...    MNL-1/MNLENT-1/FEATCADM-1/MLCADM-1:mlTrainingParams:mlTrainingStartTime=${set_hour1}
    sleep    240s
    Execute Egate Command    re
    admin.reset_site    connection=${BTS1_ALIAS}
    sleep    300s
    Execute Egate Command    cfg file=/opt/wts/latest/wts.cfg
    wait until keyword succeeds    1200    60s    Cells Should Be Onair    check_sib=${True}    timeout=1600
    Execute Egate Command    enb_x2_link_up enb=1 target=2
    sleep    10s
    Execute Egate Command    debug_log level=4

Make CA call and show traffic
    Setup 6CC UEs
    Setup other CC UE
    sleep    60s
    Show each UE traffic pdsch

Lock all TDD cell
    lock NRCell1
    lock NRCell2
    lock NRCell3

Unlock all TDD cell
    Unlock NRCell1
    Unlock NRCell2
    Unlock NRCell3
    Cells Should Be Onair    check_sib=${True}    timeout=600

Get mlstate
    [Arguments]    ${expect_state}=Training    ${expect_inference}=unavailable
    ${mlTrainingState}    Get Scf Parameter Value    NRDU-1:mlScellActParamSet1:mlTrainingState
    Should Be Equal    ${mlTrainingState}    ${expect_state}
    ${mlinferencestate-1}    Get Scf Parameter Value    NRCELL-1:mlScellActParamSet2:mlInferenceState
    Should Be Equal    ${mlinferencestate-1}    ${expect_inference}
    ${mlinferencestate-2}    Get Scf Parameter Value    NRCELL-2:mlScellActParamSet2:mlInferenceState
    Should Be Equal    ${mlinferencestate-2}    ${expect_inference}
    ${mlinferencestate-3}    Get Scf Parameter Value    NRCELL-3:mlScellActParamSet2:mlInferenceState
    Should Be Equal    ${mlinferencestate-3}    ${expect_inference}

Setup 6CC UEs
    FOR    ${ue_id}    IN RANGE    ${ue_id}    ${ue_id}+2
      UE 6CC 3T3F    ${ue_id}
    END

UE 6CC 3T3F
    [Arguments]    ${UE_ID}=81    ${send_large_traffic}=False    ${target_cell}=2    ${bufferbase}=False
    Set UE Capability    ue_id=${UE_ID}    UE_Capabilities=${ue_capa_6cc}
    SA UE attach Scell Addition blindly   ue_id=${UE_ID}    cell_id=${target_cell}
    Traffic Send For UE    ue_id=${UE_ID}    send_large_traffic=${send_large_traffic}    bufferbase=${bufferbase}

UE 6CC 3T3F covBasedA1 and A2release
    [Arguments]    ${ue_id}=81    ${target_cell}=2    ${pdu_id}=1
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${ue_capa_6cc}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${target_cell} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1
    ...    pass_regexp=Initial Context Setup Successful
    FOR    ${I}    IN RANGE    1    2
      covbaseA1 scell and ulscell active and A2release
    END
    Release ues    ue_type=all

covbaseA1 scell and ulscell active and A2release
    [Arguments]    ${ue_id}=81    ${send_large_traffic}=True    ${pdu_id}=1    ${pass_regexp}=${ue_6CC_expect_regexp}
    Clear Counter Files
    ${meas_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    event_type=A1    carrierfreq=641952
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=100
    ...    pass_regexp=${pass_regexp}    timeout=20s
    Traffic Send For UE    ue_id=${ue_id}    send_large_traffic=${send_large_traffic}    bufferbase=True
    Check Counters    ${PM_Counters_Check_3T3F_covbase}
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id}
    sleep    10s
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Clear Counter Files
    Traffic Send For UE    ue_id=${ue_id}    send_large_traffic=${send_large_traffic}    bufferbase=True
    Check Counters    ${PM_Counters_Check_3T3F_covbase}
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id}
    sleep    10s
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Clear Counter Files
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=100    UE ${ue_id}: UDP UL
    sleep    10s
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    Throughput
    sleep    10s
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id}
    Check Counters    ${PM_Counters_Check_UL_scell}
    Release Scell    scell_index=1    scell_id=1
    sleep    7s
    Release Scell    scell_index=2    scell_id=3
    sleep    7s
    Release Scell    scell_index=3    scell_id=11
    sleep    7s
    Release Scell    scell_index=4    scell_id=13
    sleep    7s
    Release Scell    scell_index=5    scell_id=14
    sleep    7s

Release Scell
    [Arguments]    ${scell_index}    ${scell_id}    ${ue_id}=81
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     ${scell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A2
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_index} scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=sCellToReleaseList

CSI_RI_PHR_CQI_change
    [Arguments]    ${UE_ID}=81    ${profile_id}=1   ${cqi}=15   ${ri}=1    ${cri}=2    ${li}=2    ${pmi}=2    ${phr-st}=-23
    ${cmd1}    catenate    csi_override_testmode_nr profile_id=${profile_id} cqi_mode=fixed cqi=${cqi} ri_mode=fixed ri=${ri}
    ...    pmi_mode=fixed cri_mode=fixed cri=${cri} li_mode=fixed li=${li} pmi=${pmi}
    Execute Egate Command    ${cmd1}
    Execute Egate Command    ue_testmode_set_nr id=${UE_ID} testmode=csi_override action=activate profile_id=${profile_id}
    ${cmd2}    catenate    phr_override_testmode_nr profile_id=${${profile_id}+1} phr_start=${phr-st} phr_min=-23 phr_max=40
    ...    phr_step_size=-63 phr_period=1 pc_max=33 phr_mode=Fixed
    Execute Egate Command    ${cmd2}
    Execute Egate Command    ue_testmode_set_nr id=${UE_ID} testmode=phr_override action=activate profile_id=${${profile_id}+1} scell=0

Setup other CC UE
    UE1 TF CA check
    UE2 TFF CA check
    UE3 TTTF CA check
    UE4 TTFF CA check
    UE5 TTTFF CA check
    UE6 TTFFF CA check

UE1 TF CA check
    [Arguments]    ${send_large_traffic}=False
    ${msg}    SA CA UE Setup PDU Session    ue_id=81    cell_id=2    UE_Capabilities=${SA_Capa_UE_TF_N77_N71}
    ...    expect_passlog=${UE1_TF_expect_regexp}
    Traffic Send    ue_id=81    send_large_traffic=${send_large_traffic}    CC_num=2

UE2 TFF CA check
    [Arguments]    ${send_large_traffic}=False
    ${msg}    SA CA UE Setup PDU Session    ue_id=82    cell_id=2    UE_Capabilities=${SA_Capa_UE_TFF_N77_N71_N66}
    ...    expect_passlog=${UE2_TFF_expect_regexp}
    Traffic Send    ue_id=82    send_large_traffic=${send_large_traffic}    CC_num=3

UE3 TTTF CA check
    [Arguments]    ${send_large_traffic}=False    ${bufferbase}=False
    ${msg}    SA CA UE Setup PDU Session    ue_id=83    cell_id=2    UE_Capabilities=${SA_Capa_UE_TTTF_N77_N41_N41_N71}
    ...    expect_passlog=${UE3_TTTF_expect_regexp}
    Traffic Send    ue_id=83    send_large_traffic=${send_large_traffic}    CC_num=4    bufferbase=${bufferbase}

UE4 TTFF CA check
    [Arguments]    ${send_large_traffic}=False    ${bufferbase}=False
    ${msg}    SA CA UE Setup PDU Session    ue_id=84    cell_id=2    UE_Capabilities=${SA_Capa_UE_TTFF_N77_N41_N71_N66}
    ...    expect_passlog=${UE4_TTFF_expect_regexp}
    Traffic Send    ue_id=84    send_large_traffic=${send_large_traffic}    CC_num=4    bufferbase=${bufferbase}

UE5 TTTFF CA check
    [Arguments]    ${send_large_traffic}=False    ${bufferbase}=False
    ${msg}    SA CA UE Setup PDU Session    ue_id=85    cell_id=2    UE_Capabilities=${SA_Capa_UE_TTTFF_N77_N41_N41_N71_N66}
    ...    expect_passlog=${UE5_TTTFF_expect_regexp}
    Traffic Send    ue_id=85    send_large_traffic=${send_large_traffic}    CC_num=5    bufferbase=${bufferbase}

UE6 TTFFF CA check
    [Arguments]    ${send_large_traffic}=False    ${bufferbase}=False
    ${msg}    SA CA UE Setup PDU Session    ue_id=86    cell_id=2    UE_Capabilities=${SA_Capa_UE_TTFFF_77_N41_N71_N66_N66}
    ...    expect_passlog=${UE6_TTFFF_expect_regexp}
    Traffic Send    ue_id=86    send_large_traffic=${send_large_traffic}    CC_num=5    bufferbase=${bufferbase}

SA CA UE Setup PDU Session
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${wait_timer}=1    ${cell_id}=1    ${UE_Capabilities}=none
    ...    ${expect_passlog}=QoS Routing Table
    [Return]    ${msg}
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${UE_Capabilities}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered    sleep_time=${wait_timer}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    ${msg}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${expect_passlog}
    ...    sleep_time=${wait_timer}

Traffic Send
    [Arguments]    ${ue_id}=81    ${send_large_traffic}=False    ${CC_num}=5    ${bufferbase}=False
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=50    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=9 mbps=3    UE ${ue_id}: UDP UL
    Run Keyword If    ${send_large_traffic}==True    Send More traffic    ue_id=${ue_id}    bufferbase=${bufferbase}
    Run Keyword If    ${send_large_traffic}==True    Wait traffic is as expected    ue_id=${ue_id}    CC_num=${CC_num}

Send More traffic
    [Arguments]    ${ue_id}=81    ${bufferbase}=False
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=10 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=9 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=8 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=7 mbps=150    UE ${ue_id}: UDP DL
    sleep    10s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=6 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=5 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Run Keyword If    ${bufferbase}==True    Send More traffic for bufferbase mode    ue_id=${ue_id}

Send More traffic for bufferbase mode
    [Arguments]    ${ue_id}=81
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=11 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=12 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=13 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=14 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=15 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s

Set UE Capability
    [Arguments]    ${ue_id}=1    ${UE_Capabilities}=${ue_capa}    ${wait_timer}=0.5
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}    sleep_time=${wait_timer}

Traffic Send For UE
    [Arguments]    ${ue_id}=1    ${send_large_traffic}=False    ${bufferbase}=False
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=10    UE ${ue_id}: UDP UL
    Run Keyword If    ${send_large_traffic}==True    Send More traffic    bufferbase=${bufferbase}
    Run Keyword If    ${send_large_traffic}==True    Wait traffic is as expected    ue_id=${ue_id}

Wait traffic is as expected
    [Arguments]    ${ue_id}=1    ${CC_num}=6
    wait until keyword succeeds    600    10s    Check Traffic    ue_id=${ue_id}    Tput_dl=220    CC_num=${CC_num}

SA UE attach Scell Addition blindly
    [Arguments]    ${ue_id}=1    ${cell_id}=2    ${pdu_id}=1    ${pass_regexp}=${ue_6CC_expect_regexp}
    ...    ${ue_capa_6cc}=${ue_capa_6cc}
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${ue_capa_6cc}
    sleep    2s
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    sleep    2s
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    sleep    2s
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    sleep    2s
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1    pass_regexp=${pass_regexp}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}    timeout=600

Check Traffic
    [Arguments]    ${ue_id}=1    ${Tput_dl}=150    ${CC_num}=5
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    Throughput
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    ${alldl_tput}    set variable    0
    FOR    ${scellid}    IN RANGE    0    ${CC_num}
        ${scellid}=    convert to string    ${scellid}
        ${ue_id}=    convert to string    ${ue_id}
        ${cell_tput}    Get Scell Throughput    ${ue_id}    ${scellid}
        ${alldl_tput}    Evaluate    ${alldl_tput}+${cell_tput}
    END
    Should Be True    ${alldl_tput}/1000 > ${Tput_dl}

Get Scell Throughput
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0

Show each UE traffic pdsch
    FOR    ${j}    IN RANGE    ${j}    ${j}+2
      Execute Egate Command    ue_stats_nr id=${j} scell=0-7 type=pdsch    Throughput
    END
    FOR    ${otherCC_UEid}    IN RANGE    81    87
      Execute Egate Command    ue_stats_nr id=${otherCC_UEid} scell=0-7 type=pdsch    Throughput
    END


