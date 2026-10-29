*** Settings ***
Documentation   This is a keyword file for CB013954
...             Team: 'MN RAN RD VRF ULM4'
...             Author: Anja Becher
#-------------------------------------------------------------------------------------------------------------

Resource        ../../resources/Common/reporting.robot
Resource        ../../resources/Common/tcpdump.robot
Library         OperatingSystem
Library         taf.config.wts        WITH NAME    wts_conf

*** Variables ***

${WIRESHARK_RUNNING}     false


${SA_CAPAB_5CC}        SEPARATOR=${EMPTY}
...                    F5E03C0047D4FFBEFFFFBAF0A40003C170101E0935F3FFFB7C00B004D9E71FF9863CA160106E0601F8E01945F06FFE6F
...                    28EF215FFFFFF96596884400416CCB6C06FCFBFFFEBFFF7CFB3FFFFE014FFD3FF28BE237FCDE51DE42BFFFFFF2CB2D10
...                    880082D996D80DF9F7FFFD7FFEF9F67FFFFC049FFA7FE517C4CFF9BCA2082FFFFFFCB2CB20220020B665B6037FFDFFFF
...                    5FFFBE7D9FFFFF0097FE5FF945F09FFE6F28EF105FFFFFF96596404400416CCB6C06FCFBFFFEBFFF7CFB3FFFFE022FFC
...                    BFF01513836001C46000E26000713000384E000001FE7E0000000002401B808D013202640271D40002201891A040DFE7
...                    DB00A0233FFFE000230003E00281C140180C426006000783A0070500603000020000300900180F80B648000005648000
...                    01164800002164800003164800004164800005002B262B012B266B2A6B2A6B06280AC8000009652464000044B2923200
...                    00425949190000312CA48C8000209652464000144B29200AA4D154066A934552A9AA553541A6878013802F92701E49C0
...                    792501E4940792501E49C00000080200801008020040200400808010020200C0180800520C40

${SA_CAPAB_5CC_ori}    SEPARATOR=${EMPTY}
...                    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E02F71B0A30358230868204
...                    1D211001B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE0038002F8003A00000E0541B10
...                    7582308682041E21100195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F60000007400001
...                    C0AA3626EB04610D04083A4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0007
...                    400001C0A836236B04610D04083C4220032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FF
...                    F800000E80000381506C18D608C21A08107884400656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FF
...                    C00001FFF000001D00000702A8D899AC1184341020E908800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C
...                    3C17003FF001C00FFC001D0000070059E1E26800710400000858081507850001C46000002160561E2300071040000185
...                    81587850001C41000002160561E26800711800000858158B88C001C41000E208000050B02B17134003882001C2800000
...                    8160562E26800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B1713400
...                    3882001C46000004160562E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160
...                    563E1400070A0003830001C4100000E160563E140007060003882001C46000010160563E1400070A0003830001C46000
...                    00E160563E1400070A0003882001C4600000E160564E1400070A0003898001C41000E230000090B02B270A0003850001
...                    C4C000E0C0007118000048581593850001C28000E2600071180038820000242C0AC9C28000E140007130003882001C18
...                    000012160402C04680510136020C01880983A800404242D0A244D8E7C3851226C73E1C28913639F0E14489B1CF870A24
...                    4D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E0
...                    44810206C73E044810206C73E0428103639F0214081B1CF810A040D8E7C0850206C73E0428103639F0214081B1CF810A
...                    040D8E7C0850206C73E007C586318C6318C6318C6318C6318C637A118001E00140E0A00E0601280380030120020301F0
...                    4801000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000E0
...                    08004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056
...                    B296B266B016B036B012B022B07681A0800004B29202000032CA480800014B29202000072CA480800024B292020000B2
...                    CA480800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA480800064B29202000062CA48
...                    0669545D2A8AA55174AA2A82C55058AA0D154A62A93455018AA051549A2A83C50F002F012A05028140A05028140A0502
...                    8140A05028140A0502800484040300601002004202004010080600C20100200404030060100C018202018030080600C2
...                    01002004040300601002004402018030080600C020180304040080201002008602004008080100202018030080600C30
...                    100200404030060100C018040300620080100202004008080B01202018030080600C3543E00020406080C0E1416181A2
...                    022242628303236383A3E424A4C4E5052545A5E828705A

${SA_CAPAB_4CC}        SEPARATOR=${EMPTY}
...                    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C04EE3614606B04610D0408
...                    3A41E006D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE000C80000E0541B107
...                    582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000C80000E0
...                    551B137582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640
...                    000702A0D88DAC1184341020F10780195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC0
...                    0000640000702A0D831AC1184341020F10780195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000
...                    007FFC0000064000070049E1E26800710400000858081507850001C46000002160561E23000710400001858158785000
...                    1C41000002160561E26800711800000858158B88C001C41000E208000050B02B17134003882001C28000008160562E26
...                    800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46
...                    000004160562E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160563E140007
...                    0A0003830001C4100000E160563E140007060003882001C46000010160563E1400070A0003830001C4600000E160563E
...                    1400070A0003882001C4600000E160402404680510136020C018194006E84A14489B1CF870A244D8E7C3851226C73E1C
...                    28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7
...                    C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E0428103639F0214081B1CF810A040D8E7C000D890C631
...                    8C6318C6318C6318C60F41B000F000A070500703009401C0018090010180F82400800000004000008020000000100000
...                    200800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000
...                    C010000140080000B004002048120080000C0339535953582958195833582B594B5933580B581B58095811583B40D040
...                    00025949010000196524040000A594901000039652404000125949010000596524040001A59490100007965240400022
...                    5949010000996524040002A5949010000B96524040003259490100003165240334AA2E954552A8BA55154162A82C5506
...                    8AA531549A2A80C55028AA4D1541E286802F012A05028140A05028140A05028140A05028140A05028004040403006010
...                    02004202004010080600C20100200404030060100C018202018030080600C20100200404030060100200440201803008
...                    0600C020180304040080201002008602004008080100202018030080600C30100200404030060100C01804030061AA1F
...                    000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414382D0

${tl.core.dir_path}    /opt/iphy/latest

@{IP_LIST_eth3_add}    10.0.1.3  10.0.1.4  10.0.1.5  10.0.1.6  10.0.1.140  10.0.1.141  10.0.1.200  10.0.1.201
...                    10.0.1.12  10.0.1.121  10.0.1.131  10.0.1.133  10.0.1.134  10.0.1.135  10.0.1.136   10.0.1.137
@{IP_LIST_eth4_add}    10.0.2.90


*** Keywords ***

Check All Radio Units Online
    [Documentation]    [PRIVATE]   check that all radio units are online
    ...     :Autor: Shruthi Shivaprasad
    Log To Console    Waiting until all RUs are online
    ${oam_alias}    connect.Setup OAM Http Session    node_type=gnb  node_id=${0}
    Wait Until Keyword Succeeds
    ...    10min   20sec
    ...    Verify All Radios Are Online    connection=${oam_alias}
    Log To Console    RUs ready
    [Teardown]     connect.Teardown OAM Http Session    node_type=gnb  node_id=${0}


Get Version Mcc Mnc From GNB SCF
    [Documentation]    [PRIVATE]    get values from SCF for update commissioning
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]    ${current_SCF_gnb}
    ${parsed_SCF}    Parse XML    ${current_SCF_gnb}
    ${version}    Get Element Attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="${bts_distName}"]
    Set To Dictionary    ${SCF}   version   ${version}
    Log To Console    variable SCF.version contains ${SCF.version}
    ${MNL_version}    Get Element Attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="MRBTS-1/MNL-1"]
    Set To Dictionary    ${SCF}   MNL_version   ${MNL_version}
    Log To Console    variable SCF.MNL_version contains ${SCF.MNL_version}
    ${NRPMRNL_version}    Get Element Attribute    ${parsed_SCF}    version     xpath=.//managedObject[@class="com.nokia.srbts.nrbts:NRPMRNL"]
    Set To Dictionary    ${SCF}   NRPMRNL_version   ${NRPMRNL_version}
    Log To Console    variable SCF.NRPMRNL_version contains ${SCF.NRPMRNL_version}
    ${NRPMRNL_distName}    Get Element Attribute    ${parsed_SCF}    distName     xpath=.//managedObject[@class="com.nokia.srbts.nrbts:NRPMRNL"]
    Set To Dictionary    ${SCF}   NRPMRNL_distName   ${NRPMRNL_distName}
    Log To Console    variable SCF.NRPMRNL_distName contains ${SCF.NRPMRNL_distName}
    ${mcc}    Get Element Text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mcc"]
    Set To Dictionary    ${SCF}   mcc   ${mcc}
    Log To Console    variable SCF.mcc contains ${SCF.mcc}
    ${mnc}    Get Element Text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mnc"]
    Set To Dictionary    ${SCF}   mnc   ${mnc}
    Log To Console    variable SCF.mnc contains ${SCF.mnc}
    ${mnclenght}    Get Element Text    ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mncLength"]
    Set Suite Variable   ${mnclenght}
    Log To Console    set suite variable mnclenght_SCF to value: ${mnclenght}


Start Wireshark Trace
    [Documentation]    [PRIVATE]    Start Wireshark Trace
    ...       :Autor: Shruthi Shivaprasad
    tcpdump.Start Tcpdump On TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    Sleep     1s
    Set Suite Variable      ${WIRESHARK_RUNNING}    true

Start Wireshark Trace GNB
    [Documentation]    [PRIVATE]    Start Wireshark Trace
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    wireshark on GNB started
    tcpdump.Start Tcpdump On GNB Common Unit
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    Sleep     1s
    Set Suite Variable      ${WIRESHARK_RUNNING}    true

Stop Wireshark Trace
    [Documentation]    [PRIVATE]    Stop Wireshark Trace
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${WIRESHARK_RUNNING}'=='false'   RETURN
    Sleep     2s
    ${tcpdump_file}    tcpdump.Stop Tcpdump On TestPc
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    Sleep     2s
    OperatingSystem.Move File    ${tcpdump_file}    ${wireshark_store}
    Set Suite Variable      ${WIRESHARK_RUNNING}    false

Stop Wireshark Trace GNB
    [Documentation]    [PRIVATE]    Stop Wireshark Trace
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${WIRESHARK_RUNNING}'=='false'   RETURN
    Sleep     2s
    ${tcpdump_file}    tcpdump.Stop Tcpdump On GNB Common Unit
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    Sleep     2s
    Log To Console    wireshark on GNB stopped
    OperatingSystem.Move File    ${tcpdump_file}    ${wireshark_store}
    Set Suite Variable      ${WIRESHARK_RUNNING}    false

Perform Preconditions Of Test Scenario CB013954
    [Documentation]    [PRIVATE]    preconditions for CB013954
    ...       :Autor: Shruthi Shivaprasad
    Create A Test Scenario Folder


Perform Postconditions Of Test Scenario CB013954
    [Documentation]    [PRIVATE]    postconditions for CB013954
    ...       :Autor: Shruthi Shivaprasad
    Run Keyword And Continue On Failure   reporting.Set SCOUT TC ID For Reporting
    Run Keyword And Continue On Failure   Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    Run Keyword And Continue On Failure   keywords-tracing.End Dcap Tracing And Collect Traces
    Run Keyword And Continue On Failure   wts_ue.Teardown Egate Connection For Airphone
    Run Keyword And Continue On Failure   wts_ue.Teardown Edaemon Connection For Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    keywordbook-480.Collect Snapshot And Sos Report Data     ${resultDir}


Suite Teardown CB013954
    [Documentation]    [PRIVATE]    suite teardown for CB013954
    ...       :Autor: Shruthi Shivaprasad
    Run Keyword And Continue On Failure   CB013954-keywords.Stop Wireshark Trace      wireshark_store=${resultBaseDir}/wireshark_suite_teardown.pcap
    IF    '${SUITE STATUS}'=='FAIL' and '${LOGS_COLLECTED}'=='False'    Collect Snapshot And Sos Report Data   ${resultBaseDir}
    wts_ue.Reload Stored WTS Config


Prepare WTS Config
    [Documentation]    Basic setup cfg file will be updated based on CB013954 TC1
    ...       :Autor: Anja Becher

    wts_conf.Load Wts Cfg   file_path=${P_ORIG_WTS_CONFIG}

    wts_conf.Modify   set_ue simulated id=1     modification=cell=7
    wts_conf.Modify   set_ue simulated id=2     modification=cell=7

    wts_conf.Modify   set_cell id=3     modification=nr_arfcn=650000:650000
    wts_conf.Modify   set_cell id=3     modification=gscn=8020

    wts_conf.Insert   set_cell id=7   after  set_cell id=6
    wts_conf.Modify   set_cell id=7     modification=gnb=2
    wts_conf.Modify   set_cell id=7     modification=nr_arfcn=470000:470000
    wts_conf.Modify   set_cell id=7     modification=gscn=5878
    wts_conf.Modify   set_cell id=7     modification=eci=0x000021f
    wts_conf.Modify   set_cell id=7     modification=pci=18:2
    wts_conf.Modify   set_cell id=7     modification=tac=200
    wts_conf.Modify   set_cell id=7     modification=proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    wts_conf.Modify   set_cell id=7     modification=nrci=0x07
    wts_conf.Modify   set_cell id=7     modification=tdd_cell=on
    wts_conf.Modify   set_cell id=7     modification=mandatory_for_activation=off

    wts_conf.Delete   set SA_Capa_5CC=${SA_CAPAB_5CC_ori}
    wts_conf.Insert   set SA_Capa_5CC=${SA_CAPAB_5CC}  after  set SA_Capa_4CC=${SA_CAPAB_4CC}

    wts_conf.Save Wts Cfg   file_path=${tl.core.dir_path}/basic_setup.cfg
    wts_conf.Save Wts Cfg   file_path=${resultBaseDir}/basic_setup_n40_n71.cfg


Configure Additional IP Addresses On WTS Host
    [Documentation]    Configure additional IP addresses not configured in ute_workarounds
    FOR    ${ip}    IN    @{IP_LIST_eth3_add}
        ute_workarounds.Configure IP On VM    ip=${ip}    interface=eth3
    END
    FOR    ${ip}    IN    @{IP_LIST_eth4_add}
        ute_workarounds.Configure IP On VM    ip=${ip}    interface=eth4
    END
