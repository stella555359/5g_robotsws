*** Settings ***
Documentation   This is a keyword file for CB013024
...             Team: 'MN RAN RD VRF ULM4'
...             Author: Shruthi Shivaprasad
#-------------------------------------------------------------------------------------------------------------

Resource        ../../resources/Common/reporting.robot
Resource        ../../resources/Common/tcpdump.robot
Library         OperatingSystem
Library         taf.config.wts        WITH NAME    wts_conf

*** Variables ***

${WIRESHARK_RUNNING}     false

${SA_CAPAB_2CC_ori}    SEPARATOR=${EMPTY}
...                    E9A09000575F5A13160003C6200005824C5C00670F434009B20C39F30C7942C0E098140188E02F71B0A303582308682041D2
...                    13000DAD931563439F11C7A067D813E31238F21CFA8E7CC31E50B0381C3C17003FF001C0017C001F00000381506C41D608C2
...                    1A08107884C0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000F800001C0AA3626EB
...                    04050D012CB28989800616C10109070E238F11C7A067D813EF1C39061C00103278F82B800FF800E003FE000F10000EDC0002
...                    00000001C0002000000000A836236B04610D04083C42600195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09
...                    FFF000007FFC000007C00000E0541B063582308682041E213000CAD931562439F11C7B027C62471E439F51CF9863CA160703
...                    8784FFF800003FFE000003E00000702A8D899AC1184341020E909800616C98AA221CF88E3C471E819F604F8C73E618F28581
...                    C0E1E0B801FF800E007FE000F800001C002507850001846000005815078500018410000858100B011A014404D80830062026
...                    12A00001B01428913639F0E14489B1CF860070218C1E84E0003C00281C1401C0C02500700060240040603E09002000000010
...                    000020080000000400000802000008010000060080000400400002802001004010040000300200001C010008000000200002
...                    001000012008000030040000500200002C01000812048020000300CE54DE545654D6545652D6525650D650564CD64C5606D6
...                    02DE54D0381000009652404000065949410000296524040000E594901000049652404000165949010000696524040001E594
...                    941000089652404000265949410000A96524040002E5949010000C96524040000C5949010000D965950374AA2E955552A8AA
...                    55554A62A94D55288AA515549A2A93555038AA05154062E95551300024006814000210101401C040880008080A00E0204400
...                    0D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A1C96A510000210
${SA_CAPAB_2CC}    SEPARATOR=${EMPTY}
...                    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E02F71B0A303582308682041D211
...                    001B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE0038002F8003A00000E0541B10758230868
...                    2041E21100195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F60000007400001C0AA3626EB040
...                    50D012CB28988800C2D8202120E1C471E238F40CFB027DE38720C38002064F1F057001FF001C007FC001C20003B700008000
...                    0000700008000000002A0D88DAC1184341020F108800CAD931562439F11C7B027C62471E439F51CF9863CA1607038784FFF8
...                    00003FFE000003A00000E0541B063582308682041E21100195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09
...                    FFF000007FFC000007400001C0AA36266B04610D04083A4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F
...                    05C00FFC007003FF0007400001C002507830001C28000000160541E1400061040002160402C04680510136020C01880983A8
...                    0006C050A244D8E7C3851226C73E1801C086307A118001E00140E0A00E0601280380030120020301F0480100000000800001
...                    0040000000200000401000004008000030040000200200001401000802008020000180100000E00800400000010000100080
...                    0009004000018020000280100001600800409024010000180672A6F2A2B2A6B2A2B296B292B286B282B266B262B036B016F2
...                    A681C0800004B29202000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA4A080
...                    0044B29202000132CA4A0800054B29202000172CA480800064B29202000062CA48080006CB2CA81BA55174AAAA954552AAAA
...                    53154A6AA9445528AAA4D1549AAA81C55028AA03174AAA878004800D0280004202040058080A00E10101401C04088001AA1F
...                    000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414392D4A20000420

${SA_CAPAB_3CC}    SEPARATOR=${EMPTY}
...                    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E02771B0A303582308682041D21
...                    1001B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE0038002F8003A00000E0541B1075823086
...                    82041E21100195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F60000007400001C0AA3626EB04
...                    610D04083A4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0007400001C0A836236B
...                    04610D04083C4220032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000E80000381506C
...                    18D608C21A08107884400656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000001D00000700
...                    49E1E26800710400000858081507850001C46000002160561E230007104000018581587850001C41000002160561E2680071
...                    1800000858158B850001C41000E0C0000050B02B17130003850001C41000008160562E26800711800388C0000082C0AC5C28
...                    000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000711800388C0000
...                    082C0AC5C28000E23000706000002058158788C001C46000006160562E1400070A000383000001C2C0AC5C28000E0C000710
...                    400004058158B850001C28000E230000070B02B170A0003882001C4600000E160402404680510136020C0181D4001BA12851
...                    226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28103639F022408103639F02240810363
...                    9F022408103639F022408103639F022408103639F022408103639F022408103639F0214081B1CF810A040D8E7C0850206C73
...                    E0428103639F0003624318C6318C6318C6318C63183D08C000F000A070500703009401C0018090010180F824008000000040
...                    00008020000000100000200800002004000018020000100100000A008004010040100000C008000070040020000000800008
...                    0040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B5933580B581B580958
...                    11583B40D04000025949010000196524040000A594901000039652404000125949010000596524040001A594901000079652
...                    404000225949010000996524040002A5949010000B96524040003259490100003165240334AA2E954552A8BA55154162A82C
...                    55068AA531549A2A80C55028AA4D1541E28780178095028140A05028140A05028140A05028140A0502814002020201803008
...                    01002101002008040300610080100202018030080600C10100C018040300610080600C02004008080600C201002004040300
...                    60100C018202004010080100420100200404008010100C018402004008080600C02018030D50F80008101820303850586068
...                    80889098A0C0C8D8E0E8F909293139414951697A0A1C1680

${EUTRA_Samsung_S23}   SEPARATOR=${EMPTY}
...                    a107c3083602009049230711800004d10080a0106c04012092460e2300000922f8980802410e14040006022e102227fe36020
...                    0904385000182800028117081113fe1b010048218280388c00001c08b848889920d808020104821c460000104441a01068240
...                    918388c00001288040500834020d0481230711800002117c48041a08070a0200018117081113ff1a01068201c28000c140000
...                    008b840889ff0d00834100c1401c46000002045c24444c906804100834100e23000002220100040180b08211a020c02880310
...                    1184c20b086469d3a74ed8e7c38d3a74e9db1cf871274e85b1cf871a74e853b639f0e34e9d3a76c73e1c69d3a74ed8e7c38d3
...                    a74e9db1cf871a74e9d3b639f0e24e9d0b639f0e34e9d0a76c73e1c69d3a74ed8e7c38d3a74e9db1cf86110c8745c010e8b80
...                    04024600020000008020200400808010003000100000040101002000040100218000800000200000080202008010800040000
...                    01004040180118000800000500800040002008010c0004010001000040080101002000400020080008000200c008c00040100
...                    01000040080001004008600020080008000002000080200430001004000a0000008000401002

${SA_CAPAB_2CC_TMO}    SEPARATOR=${EMPTY}
...                    E9A09000575F5A13160003C6A00002C1262E003387A1A004D9061CF9863CA160704C0A00C47017B8D85181AC1184341020E909
...                    8006D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0011800000702A0D883AC1184341
...                    020F109800656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD80000023000000E0551B137582028
...                    680965944C4C0030B608084838711C788E3D033EC09F78E1C830E0008193C7C15C007FC007001FF0008880001DB80004000000
...                    0380004000000001506C46D608C21A08107884C0032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000
...                    FFF8000011800000702A0D831AC1184341020F109800656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00
...                    001FFF0000023000000E0551B133582308682041D213000C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003F
...                    F001C00FFC0023000000E001283C18000E140000000B02A0F0A000308200010B020160234028809B010600C404C29400000D80
...                    A14489B1CF870A244D8E7C3003810C60F42F000078005038280381804A00E000C0480080C07C12004000000020000040100000
...                    0008000010040000100200000C0100000800800005004002008020080000600400003802001000000040000400200002401000
...                    0060080000A004000058020010240900400006019CA9BCA8ACA9ACA8ACA5ACA4ACA1ACA0AC99AC98AC0DAC05BCA9A070200001
...                    2CA48080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29282000112CA4808000
...                    4CB29282000152CA48080005CB29202000192CA480800018B292020001B2CB2A06E9545D2AAAA55154AAAA94C5529AAA51154
...                    A2AA9345526AAA071540A2A80C5D2AAA2E0001200340A00010808100160200400840405007010220006A87C0004080C10181C28
...                    2C30344044484C5060646C70747C8494989CA0A4A8B4BD050E4B5288000108

${tl.core.dir_path}    /opt/iphy/latest

@{IP_LIST_eth3_add}    10.0.1.3   10.0.1.140  10.0.1.141
@{IP_LIST_eth4_add}    10.0.2.90


*** Keywords ***

Check All Radio Units Online
    [Documentation]    [PRIVATE]   check that all radio units are online
    ...     :Autor: Shruthi Shivaprasad
    Log To Console    Waiting until all RUs are online
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    wait until keyword succeeds
    ...    10min   20sec
    ...    Verify All Radios are Online    connection=${oam_alias}
    Log to console    RUs ready
    [Teardown]     connect.Teardown OAM http session    node_type=gnb  node_id=${0}


Get Version Mcc Mnc From gNB SCF
    [Documentation]    [PRIVATE]    get values from SCF for update commissioning
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]    ${current_SCF_gnb}
    ${parsed_SCF}    parse XML    ${current_SCF_gnb}
    ${version}    get element attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="${bts_distName}"]
    Set To Dictionary    ${SCF}   version   ${version}
    Log To Console    variable SCF.version contains ${SCF.version}
    ${MNL_version}    get element attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="MRBTS-1/MNL-1"]
    Set To Dictionary    ${SCF}   MNL_version   ${MNL_version}
    Log To Console    variable SCF.MNL_version contains ${SCF.MNL_version}
    ${NRPMRNL_version}    get element attribute    ${parsed_SCF}    version     xpath=.//managedObject[@class="com.nokia.srbts.nrbts:NRPMRNL"]
    Set To Dictionary    ${SCF}   NRPMRNL_version   ${NRPMRNL_version}
    Log To Console    variable SCF.NRPMRNL_version contains ${SCF.NRPMRNL_version}
    ${NRPMRNL_distName}    get element attribute    ${parsed_SCF}    distName     xpath=.//managedObject[@class="com.nokia.srbts.nrbts:NRPMRNL"]
    Set To Dictionary    ${SCF}   NRPMRNL_distName   ${NRPMRNL_distName}
    Log To Console    variable SCF.NRPMRNL_distName contains ${SCF.NRPMRNL_distName}
    ${mcc}    get element text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mcc"]
    Set To Dictionary    ${SCF}   mcc   ${mcc}
    Log To Console    variable SCF.mcc contains ${SCF.mcc}
    ${mnc}    get element text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mnc"]
    Set To Dictionary    ${SCF}   mnc   ${mnc}
    Log To Console    variable SCF.mnc contains ${SCF.mnc}
    ${mnclenght}    get element text    ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mncLength"]
    set suite variable   ${mnclenght}
    Log To Console    set suite variable mnclenght_SCF to value: ${mnclenght}



Start Wireshark Trace
    [Documentation]    [PRIVATE]    Start Wireshark Trace
    ...       :Autor: Shruthi Shivaprasad
    tcpdump.Start Tcpdump on TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    sleep     1s
    Set suite variable      ${WIRESHARK_RUNNING}    true

Start Wireshark Trace gNB
    [Documentation]    [PRIVATE]    Start Wireshark Trace
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    wireshark on GNB started
    tcpdump.Start Tcpdump on gNB Common Unit
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    sleep     1s
    Set suite variable      ${WIRESHARK_RUNNING}    true

Stop Wireshark Trace
    [Documentation]    [PRIVATE]    Stop Wireshark Trace
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${WIRESHARK_RUNNING}'=='false'   RETURN
    sleep     2s
    ${tcpdump_file}    tcpdump.Stop Tcpdump on TestPc
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    sleep     2s
    OperatingSystem.Move File    ${tcpdump_file}    ${wireshark_store}
    Set suite variable      ${WIRESHARK_RUNNING}    false

Stop Wireshark Trace gNB
    [Documentation]    [PRIVATE]    Stop Wireshark Trace
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${WIRESHARK_RUNNING}'=='false'   RETURN
    sleep     2s
    ${tcpdump_file}    tcpdump.Stop Tcpdump on gNB Common Unit
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    sleep     2s
    Log To Console    wireshark on GNB stopped
    OperatingSystem.Move File    ${tcpdump_file}    ${wireshark_store}
    Set suite variable      ${WIRESHARK_RUNNING}    false

Perform Preconditions of Test Scenario CB013024
    [Documentation]    [PRIVATE]    preconditions for CB013024
    ...       :Autor: Shruthi Shivaprasad
    Create a Test Scenario Folder


Perform Postconditions of Test Scenario CB013024
    [Documentation]    [PRIVATE]    postconditions for CB013024
    ...       :Autor: Shruthi Shivaprasad
    Run Keyword And Continue On Failure   Set SCOUT TC ID for Reporting
    Run Keyword And Continue On Failure   Stop Wireshark Trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    Run Keyword And Continue On Failure   end dcap tracing and collect traces
    Run Keyword And Continue On Failure   Teardown Egate Connection for Airphone
    Run Keyword And Continue On Failure   Teardown Edaemon Connection for Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    Collect snapshot and sos report data     ${resultDir}


Suite Teardown CB013024
    [Documentation]    [PRIVATE]    suite teardown for CB013024
    ...       :Autor: Shruthi Shivaprasad
    Run Keyword And Continue On Failure   Stop Wireshark Trace      wireshark_store=${resultBaseDir}/wireshark_suite_teardown.pcap
    IF    '${SUITE STATUS}'=='FAIL' and '${LOGS_COLLECTED}'=='False'    Collect snapshot and sos report data   ${resultBaseDir}
    Reload Stored WTS Config

Prepare WTS config for TC1
    [Documentation]    Basic setup cfg file will be updated based on CB013024 TC1
    ...       :Autor: Anja Becher

    wts_conf.load_wts_cfg   file_path=${P_ORIG_WTS_CONFIG}

    wts_conf.modify   set_ue simulated id=8     modification=cell=6
    wts_conf.delete   set SA_Capa_2CC=${SA_CAPAB_2CC_ori}
    wts_conf.insert   set SA_Capa_2CC=${SA_CAPAB_2CC}  after  set SA_Capa_3CC=${SA_CAPAB_3CC}

    wts_conf.save_wts_cfg   file_path=${tl.core.dir_path}/basic_setup.cfg
    wts_conf.save_wts_cfg   file_path=${resultDir}/basic_setup_25_41.cfg


Prepare WTS config for TMO
    [Documentation]    Basic setup cfg file will be updated based on CB013024 TC1
    ...       :Autor: Anja Becher

    wts_conf.load_wts_cfg   file_path=${P_ORIG_WTS_CONFIG}

    wts_conf.modify   set_ue simulated id=8     modification=cell=8
    wts_conf.modify   set_nwslice id=1     modification=ue=1,8,21,51,81
    wts_conf.modify   set_nwslice id=8     modification=ue=28,58,88
    wts_conf.modify   ue_param id=8     modification=ue_nr_capabilities=$SA_Capa_2CC
    wts_conf.insert   set SA_Capa_2CC=${SA_CAPAB_2CC_TMO}  after  set EUTRA_Samsung_S23=${EUTRA_Samsung_S23}

    wts_conf.save_wts_cfg   file_path=${tl.core.dir_path}/basic_setup.cfg
    wts_conf.save_wts_cfg   file_path=${resultDir}/basic_setup_25_41_TMO.cfg


Add NRREL MOC to NRCELL
    [Arguments]    ${cell_id}   ${moc_id}   ${lcrId}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-${cell_id}/NRREL-${moc_id}
    ${mo_version}=            scf.get_mo_attribute  dist_name=${distName_NRREL1}     attribute=version
    Set Object    class_name=NRREL    dist_name=${dist_name}   version=${mo_version}
    FOR   ${p_name}                            ${value}      IN
    ...   gNbId                                 1
    ...   gNbIdLength                           24
    ...   lcrId                                 ${lcrId}
    ...   sCellAdditionMethod                   blind
    ...   sCellOperationalMode                  dlOnly
    ...   cellIndividualSsbRsrpOffset           0dB
    ...   cellIndividualSsbRsrqOffset           0dB
    ...   handoverAllowedSA                     allowed
    ...   handoverAllowedSARedCap               forbidden
    ...   isRplCellForPSCell                    false
    ...   nrDcAllowed                           false
    ...   removeNotAllowed                      true
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    Set New List                    dist_name=${dist_name}          list_name=gnbPlmn
    ${gnbPlmn_dict}                 Create dictionary               mcc                             310
    ...                                                             mnc                             260
    ...                                                             mncLength                       3
    scf.add_item_to_list            dist_name=${dist_name}          list_name=gnbPlmn               elements=${gnbPlmn_dict}


Configure additional IP addresses on WTS host
    [Documentation]    Configure additional IP addresses not configured in ute_workarounds
    FOR    ${ip}    IN    @{IP_LIST_eth3_add}
        ute_workarounds.Configure IP on VM    ip=${ip}    interface=eth3
    END
    FOR    ${ip}    IN    @{IP_LIST_eth4_add}
        ute_workarounds.Configure IP on VM    ip=${ip}    interface=eth4
    END
