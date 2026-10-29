*** Settings ***
Documentation
...  author: Philippe Maron
...  corrections and changes made by Jakub Migdalek for regression in UTE Wroclaw
...  contact: philippe.maron@nokia.com and jakub.migdalek@nokia.com
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001348/resources/resources.robot

Resource                    ./resources/5GC002060keysFDD.robot
Library                     BuiltIn
Library                     OperatingSystem
Library                     Collections
Library                     String
Library                     ute_ue
Library                     SSHLibrary                  WITH NAME    robssh
Library                     taf.transport.ssh           WITH NAME    ssh
Library                     taf.sbts.oam.coam.admin      WITH NAME    coam
Library                     taf.collectors.core         WITH NAME    core
Library                     taf.collectors.tcpdump      WITH NAME    tcpdump
Variables                   taf/rfrl/utilities/parsers/check_cap.py
Library                     check_cap.CapPacket         WITH NAME    cap
Variables                   ./resources/5GC002060paramsFDD.yaml
Variables                   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002060/resources/FGCR8144paramsFDD.yaml
Resource                    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot
Library                     testsuite/Wroclaw/RRM/resources/rrm_fixture.py
Resource                    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot


*** Variables ***
${ip_addr}          ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${Log_directory}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002060/resources


*** Keywords ***
[1]5GC002060_A_2_NSA-classical-cmw-FDD_StaticCall_DrxLongCycle160_LowBurstyDLTraffic_Counters
    [Documentation]     This test case verify the latency added by feature 5GC002060-A in case DLC160 used
    ...                 First the gNB is configure with feature deactivated and network is verified
    ...                 checking that no packet lost in a 120 packets ping, the average latency is saved to verify
    ...                 the introduced latency is no more than expected
    ...                 Then a DLC160 configuration is used and activated, a UE is attached and a verification is done
    ...                 on the used parameters.
    ...                 A 120 ping is then launch and no packets should be lost,.the average latency should be less
    ...                 equal to the latency without drx activated plus the drx cyle (160 in this case)

    [Tags]              # QC_440073
    get and validate scf file    SCF_basic.xml
    log                     5GC002060_A_2_NSA_classical_cmw_FDD_StaticCall_DrxLongCycle160_LowBurstyDLTraffic
    ${cells_id}             Get list of all cells
    log                     liste des cellules
    log                     ${cells_id}     formatter=repr
    ${cellgrps_id}          Get list of all cellsgroup
    log                     liste des cells groupes
    log                     ${cellgrps_id}     formatter=repr
    Set edrx parameters     DRXOFF      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values    SCF_DRXOFF.xml
    log                     validation of SCF_DRXOFF is ${Validationresult}
    scf uploading and commissioning     SCF_DRXOFF.xml
    Run Keyword and Ignore Error    Detach Ue  UE_1
    5GC002060keysFDD.Pcap collection
    sleep  5s
    Attach Ue   UE_1
    sleep  5s
    5GC002060keysFDD.Pcap log downlad
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    ${pingres}=             Do DL ping      ${UE_IP}  numberofping=120    intervalofpings=1
    ${linelostping}=        Get lines containing String     ${pingres}          packet loss
    Verify no ping lost     pingreport=${linelostping}
    ${linertt}=             Get lines containing String     ${pingres}          min/avg/max/mdev
    ${refrtt}=              Get average rtt                 pingreport=${linertt}
    Detach Ue  UE_1
    sleep                   10s
    Set edrx parameters     DLC160      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values    SCF_DLC160.xml
    log                     validation of SCF_DLC160 is ${Validationresult}
    scf uploading and commissioning         SCF_DLC160.xml      tcpdumpguard=${true}
    5GC002060keysFDD.Wait for next pm period                 guardtime=60                before=${true}
    Set Board Name
    Attach UE and Verify DRx parameters     DLC160
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    ${pingres}=             Do DL ping      ${UE_IP}  numberofping=120    intervalofpings=1
    ${linelostping}=        Get lines containing String     ${pingres}          packet loss
    Verify no ping lost     pingreport=${linelostping}
    ${linertt}=             Get lines containing String     ${pingres}          min/avg/max/mdev
    ${checkrtt}=            Get average rtt                 pingreport=${linertt}
    Verify latency          ${refrtt}                       ${checkrtt}      DLC160
    Get last pm counter file and expand it
    Check 2060 PM counters                  EDRXCONFIG=DLC160
    Detach Ue  UE_1


[1]5GC002060_A_12_NSA-classical-cmw-FDD_StaticCall_DrxLongCycle640_LowBurstyDLTraffic_Counters
     [Documentation]     This test case verify the counters associated with DRx feature M55308C11001 and M55308C11002.
    ...                 First the gNB is configure DLC 640 configuration, then the the beginig of next reporting period
    ...                 is waited
    ...                 A UE is attached and it is pinged every 5 second for a little more than the test duration
    ...                 to maintained it connected
    ...                 At the end of the ping, the last pm counter file is retrived and the counters are checked.
    ...                 In case M55308C11001 is 0, M55308C11002 should be 0 (cells where there is no UE)
    ...                 In case M55308C11001 is not 0, the ration  M55308C11002 / M55308C11001 is verify to be in
    ...                 correct range
    ...                 At least one counter M55308C11001 should be not equal to 0

    [Tags]              # QC_464576
    get and validate scf file    SCF_basic.xml
    log                     5GC002060_A_32_SA_classical_cmw_FDD_MSC_StaticCall_DrxLongCycle640_Counters
    Run Keyword And Ignore Error  Check adb devices
    ${cells_id}             Get list of all cells
    log                     liste des cellules
    log                     ${cells_id}     formatter=repr
    ${cellgrps_id}          Get list of all cellsgroup
    log                     liste des cells groupes
    log                     ${cellgrps_id}     formatter=repr
    Set edrx parameters     DLC640      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values    SCF_DLC640.xml
    log                     validation of SCF_DLC640 is ${Validationresult}
    scf uploading and commissioning         SCF_DLC640.xml      tcpdumpguard=${true}
    5GC002060keysFDD.Wait for next pm period                 guardtime=60                before=${true}
    Set Board Name
    Run Keyword and Ignore Error    Detach Ue  UE_1
    Attach UE and Verify DRx parameters     DLC640
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    ${pingres}=             Do DL ping      ${UE_IP}  numberofping=195    intervalofpings=5
    ${linelostping}=        Get lines containing String     ${pingres}          packet loss
    Verify no ping lost     pingreport=${linelostping}
    Get last pm counter file and expand it
    Check 2060 PM counters                  EDRXCONFIG=DLC640
    Detach Ue  UE_1


[1]5GC002060_A_7_NSA-classical-cmw-FDD_StaticCall_DrxLongCycle320_LowBurstyDLTraffic_Counters
    [Documentation]     This test case verify the counters associated with DRx feature M55308C11001 and M55308C11002.
    ...                 First the gNB is configure DLC 320 configuration, then the the beginig of next reporting period
    ...                 is waited
    ...                 A UE is attached and it is pinged every 5 second for a little more than the test duration
    ...                 to maintained it connected
    ...                 At the end of the ping, the last pm counter file is retrived and the counters are checked.
    ...                 In case M55308C11001 is 0, M55308C11002 should be 0 (cells where there is no UE)
    ...                 In case M55308C11001 is not 0, the ration  M55308C11002 / M55308C11001 is verify to be in
    ...                 correct range
    ...                 At least one counter M55308C11001 should be not equal to 0

    [Tags]              # QC_440082
    get and validate scf file    SCF_basic.xml
    log                     5GC002060_A_11_NSA_classical_cmw_FDD_MSC_StaticCall_DrxLongCycle320_Counters
    Run Keyword And Ignore Error  Check adb devices
    ${cells_id}             Get list of all cells
    log                     liste des cellules
    log                     ${cells_id}     formatter=repr
    ${cellgrps_id}          Get list of all cellsgroup
    log                     liste des cells groupes
    log                     ${cellgrps_id}     formatter=repr
    Set edrx parameters     DLC320      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values    SCF_DLC320.xml
    log                     validation of SCF_DLC320 is ${Validationresult}
    scf uploading and commissioning         SCF_DLC320.xml      tcpdumpguard=${true}
    5GC002060keysFDD.Wait for next pm period                 guardtime=60                before=${true}
    Set Board Name
    Run Keyword and Ignore Error    Detach Ue  UE_1
    Attach UE and Verify DRx parameters     DLC320
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    ${pingres}=             Do DL ping      ${UE_IP}    numberofping=195    intervalofpings=5
    ${linelostping}=        Get lines containing String     ${pingres}          packet loss
    Verify no ping lost     pingreport=${linelostping}
    Get last pm counter file and expand it
    Check 2060 PM counters                  EDRXCONFIG=DLC320
    Detach Ue  UE_1



[1]5GC002060_A_1_NSA-classical-cmw-FDD_Feature_Activation
    [Documentation]     This test case verify the activation of feature 5GC002060-A in case 160mS used
    ...                 First the gNB is configure with feature deactivated and network is verified
    ...                 checking that no packet lost in a 120 packets ping
    ...                 Then, a bad configuration using 160 mS DLC is tried, relation errors should be raised
    ...                 when validating
    ...                 Then a good configuration is used and activated, a UE is attached and a verification is done
    ...                 on the used parameters.
    ...                 A 120 ping is then launch and no packets should be lost.

    [Tags]              # QC_440072
    get and validate scf file    SCF_basic.xml
    log                     5GC002060_A_1_NSA_classical_cmw_FDD_Feature_Activation
    ${cells_id}             Get list of all cells
    log                     liste des cellules
    log                     ${cells_id}     formatter=repr
    ${cellgrps_id}          Get list of all cellsgroup
    log                     liste des cells groupes
    log                     ${cellgrps_id}     formatter=repr
    Set edrx parameters     DRXOFF      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values    SCF_DRXOFF.xml
    log                     validation of SCF_DRXOFF is ${Validationresult}
    log to console    validation of scf
    log to console    uploading and commissioning scf
    Run Keyword and Ignore Error    Detach Ue  UE_1
    5GC002060keysFDD.Pcap collection
    Attach Ue   UE_1
    5GC002060keysFDD.Pcap log downlad
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    Log to console          ${UE_IP}
    sleep                   3s
    ${pingres}=             Do DL ping     ${UE_IP}   numberofping=120    intervalofpings=1
    ${linelostping}=        Get lines containing String     ${pingres}          packet loss
    Verify no ping lost     pingreport=${linelostping}
    Detach Ue  UE_1
    sleep                   10s
    Set edrx parameters     DLC160N     ${cells_id}     ${cellgrps_id}
    log to console          start validating with pdl error
    ${Validationresult}     validate modified values with pdl error             SCF_DLC160N.xml
    log to console          validation of SCF_DLC160N is ${Validationresult}
    Set edrx parameters     DLC160      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values    SCF_DLC160.xml
    log to console          validation of SCF_DLC160 is ${Validationresult}
    scf uploading and commissioning         SCF_DLC160.xml      tcpdumpguard=${true}
    Set Board Name
    Attach UE and Verify DRx parameters     DLC160
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    Log to console          ${UE_IP}
    ${pingres}=             Do DL ping      ${UE_IP}   numberofping=120    intervalofpings=1
    ${linelostping}=        Get lines containing String     ${pingres}          packet loss
    Verify no ping lost     pingreport=${linelostping}
    Detach Ue  UE_1

[1]5GC002060_A_11_NSA-classical-cmw-FDD_MSC_StaticCall_DrxLongCycle320_Counters
    [Documentation]     This test case verify the counters associated with DRx feature M55308C11001 and M55308C11002.
    ...                 First the gNB is configure DLC 320 configuration, then the the beginig of next reporting period
    ...                 is waited
    ...                 A UE is attached and it is pinged every 5 second for a little more than the test duration
    ...                 to maintained it connected
    ...                 At the end of the ping, the last pm counter file is retrived and the counters are checked.
    ...                 In case M55308C11001 is 0, M55308C11002 should be 0 (cells where there is no UE)
    ...                 In case M55308C11001 is not 0, the ration  M55308C11002 / M55308C11001 is verify to be in
    ...                 correct range
    ...                 At least one counter M55308C11001 should be not equal to 0

    [Tags]              # QC_440082
    get and validate scf file    SCF_basic.xml
    log                     5GC002060_A_11_NSA_classical_cmw_FDD_MSC_StaticCall_DrxLongCycle320_Counters
    ${cells_id}             Get list of all cells
    log                     liste des cellules
    log                     ${cells_id}     formatter=repr
    ${cellgrps_id}          Get list of all cellsgroup
    log                     liste des cells groupes
    log                     ${cellgrps_id}     formatter=repr
    Set edrx parameters     DLC320      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values    SCF_DLC320.xml
    log                     validation of SCF_DLC320 is ${Validationresult}
    scf uploading and commissioning         SCF_DLC320.xml      tcpdumpguard=${true}
    5GC002060keysFDD.Wait for next pm period                 guardtime=60                before=${true}
    Set Board Name
    Run Keyword and Ignore Error    Detach Ue  UE_1
    Attach UE and Verify DRx parameters     DLC320
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    Log to console          ${UE_IP}
    ${pingres}=             Do DL ping      ${UE_IP}    numberofping=195    intervalofpings=5
    ${linelostping}=        Get lines containing String     ${pingres}          packet loss
    Verify no ping lost     pingreport=${linelostping}
    Get last pm counter file and expand it
    Check 2060 PM counters                  EDRXCONFIG=DLC320
    Detach Ue  UE_1


[1]5GC002060_A_2_NSA-classical-cmw-FDD_StaticCall_DrxLongCycle160_LowBurstyDLTraffic
    [Documentation]     This test case verify the latency added by feature 5GC002060-A in case DLC160 used
    ...                 First the gNB is configure with feature deactivated and network is verified
    ...                 checking that no packet lost in a 120 packets ping, the average latency is saved to verify
    ...                 the introduced latency is no more than expected
    ...                 Then a DLC160 configuration is used and activated, a UE is attached and a verification is done
    ...                 on the used parameters.
    ...                 A 120 ping is then launch and no packets should be lost,.the average latency should be less
    ...                 equal to the latency without drx activated plus the drx cyle (160 in this case)

    [Tags]              # QC_440073
    get and validate scf file    SCF_basic.xml
    log                     5GC002060_A_2_NSA_classical_cmw_FDD_StaticCall_DrxLongCycle160_LowBurstyDLTraffic
    ${cells_id}             Get list of all cells
    log                     liste des cellules
    log                     ${cells_id}     formatter=repr
    ${cellgrps_id}          Get list of all cellsgroup
    log                     liste des cells groupes
    log                     ${cellgrps_id}     formatter=repr
    Set edrx parameters     DRXOFF      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values    SCF_DRXOFF.xml
    log                     validation of SCF_DRXOFF is ${Validationresult}
    scf uploading and commissioning     SCF_DRXOFF.xml
    Run Keyword and Ignore Error    Detach Ue  UE_1
    5GC002060keysFDD.Pcap collection
    Attach Ue   UE_1
    5GC002060keysFDD.Pcap log downlad
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    Log to console          ${UE_IP}
    sleep                   10s
    ${pingres}=             Do DL ping      ${UE_IP}  numberofping=120    intervalofpings=1
    ${linelostping}=        Get lines containing String     ${pingres}          packet loss
    Verify no ping lost     pingreport=${linelostping}
    ${linertt}=             Get lines containing String     ${pingres}          min/avg/max/mdev
    ${refrtt}=              Get average rtt                 pingreport=${linertt}
    Detach Ue  UE_1
    sleep                   10s
    Set edrx parameters     DLC160      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values    SCF_DLC160.xml
    log                     validation of SCF_DLC160 is ${Validationresult}
    scf uploading and commissioning         SCF_DLC160.xml      tcpdumpguard=${true}
    Set Board Name
    Attach UE and Verify DRx parameters     DLC160
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    Log to console          ${UE_IP}
    ${pingres}=             Do DL ping      ${UE_IP}  numberofping=120    intervalofpings=1
    ${linelostping}=        Get lines containing String     ${pingres}          packet loss
    Verify no ping lost     pingreport=${linelostping}
    ${linertt}=             Get lines containing String     ${pingres}          min/avg/max/mdev
    ${checkrtt}=            Get average rtt                 pingreport=${linertt}
    Verify latency          ${refrtt}                       ${checkrtt}      DLC160
    Detach Ue  UE_1


[1]5GC002060_A_12_NSA-classical-cmw-FDD_StaticCall_DrxLongCycle640_LowBurstyDLTraffic
    [Documentation]     This test case verify the latency added by feature 5GC002060-A in case DLC640 used
    ...                 First the gNB is configure with feature deactivated and network is verified
    ...                 checking that no packet lost in a 120 packets ping, the average latency is saved to verify
    ...                 the introduced latency is no more than expected
    ...                 Then a DLC640 configuration is used and activated, a UE is attached and a verification is done
    ...                 on the used parameters.
    ...                 A 120 ping is then launch and no packets should be lost,.the average latency should be less
     ...                equal to the latency without drx activated plus the drx cyle (640 in this case)

    [Tags]              # QC_440083
    get and validate scf file    SCF_basic.xml
    log                     5GC002060_A_12_NSA_classical_cmw_FDD_StaticCall_DrxLongCycle640_LowBurstyDLTraffic
    ${cells_id}             Get list of all cells
    log                     liste des cellules
    log                     ${cells_id}     formatter=repr
    ${cellgrps_id}          Get list of all cellsgroup
    log                     liste des cells groupes
    log                     ${cellgrps_id}     formatter=repr
    Set edrx parameters     DRXOFF      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values    SCF_DRXOFF.xml
    log                     validation of SCF_DRXOFF is ${Validationresult}
    scf uploading and commissioning     SCF_DRXOFF.xml
    Run Keyword and Ignore Error    Detach Ue  UE_1
    5GC002060keysFDD.Pcap collection
    Attach Ue   UE_1
    5GC002060keysFDD.Pcap log downlad
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    Log to console          ${UE_IP}
    sleep                   10s
    ${pingres}=             Do DL ping      ${UE_IP}   numberofping=120    intervalofpings=1
    ${linelostping}=        Get lines containing String     ${pingres}          packet loss
    Verify no ping lost     pingreport=${linelostping}
    ${linertt}=             Get lines containing String     ${pingres}          min/avg/max/mdev
    ${refrtt}=              Get average rtt                 pingreport=${linertt}
    Detach Ue  UE_1
    sleep                   10s
    Set edrx parameters     DLC640      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values    SCF_DLC640.xml
    log                     validation of SCF_DLC640 is ${Validationresult}
    scf uploading and commissioning         SCF_DLC640.xml      tcpdumpguard=${true}
    Set Board Name
    Attach UE and Verify DRx parameters     DLC640
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    Log to console          ${UE_IP}
    ${pingres}=             Do DL ping      ${UE_IP}   numberofping=120    intervalofpings=1
    ${linelostping}=        Get lines containing String     ${pingres}          packet loss
    Verify no ping lost     pingreport=${linelostping}
    ${linertt}=             Get lines containing String     ${pingres}          min/avg/max/mdev
    ${checkrtt}=            Get average rtt                 pingreport=${linertt}
    Verify latency          ${refrtt}                       ${checkrtt}      DLC640
    Detach Ue  UE_1


[1]5GC002060_A_7_NSA-classical-cmw-FDD_StaticCall_DrxLongCycle320_LowBurstyDLTraffic
    [Documentation]     This test case verify the latency added by feature 5GC002060-A in case DLC320 used
    ...                 First the gNB is configure with feature deactivated and network is verified
    ...                 checking that no packet lost in a 120 packets ping, the average latency is saved to verify
    ...                 the introduced latency is no more than expected
    ...                 Then a DLC320 configuration is used and activated, a UE is attached and a verification is done
    ...                 on the used parameters.
    ...                 A 120 ping is then launch and no packets should be lost,.the average latency should be less
    ...                 equal to the latency without drx activated plus the drx cyle (320 in this case)

    [Tags]              # QC_440078
    get and validate scf file    SCF_basic.xml
    log                     5GC002060_A_7_NSA_classical_cmw_FDD_StaticCall_DrxLongCycle320_LowBurstyDLTraffic
    ${cells_id}             Get list of all cells
    log                     liste des cellules
    log                     ${cells_id}     formatter=repr
    ${cellgrps_id}          Get list of all cellsgroup
    log                     liste des cells groupes
    log                     ${cellgrps_id}     formatter=repr
    Set edrx parameters     DRXOFF      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values    SCF_DRXOFF.xml
    log                     validation of SCF_DRXOFF is ${Validationresult}
    scf uploading and commissioning     SCF_DRXOFF.xml
    Run Keyword and Ignore Error    Detach Ue  UE_1
    5GC002060keysFDD.Pcap collection
    Attach Ue   UE_1
    5GC002060keysFDD.Pcap log downlad
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    Log to console          ${UE_IP}
    sleep                   10s
    ${pingres}=             Do DL ping      ${UE_IP}   numberofping=120    intervalofpings=1
    ${linelostping}=        Get lines containing String     ${pingres}          packet loss
    Verify no ping lost     pingreport=${linelostping}
    ${linertt}=             Get lines containing String     ${pingres}          min/avg/max/mdev
    ${refrtt}=              Get average rtt                 pingreport=${linertt}
    Detach Ue  UE_1
    sleep                   10s
    Set edrx parameters     DLC320      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values    SCF_DLC320.xml
    log                     validation of SCF_DLC320 is ${Validationresult}
    scf uploading and commissioning         SCF_DLC320.xml      tcpdumpguard=${true}
    Set Board Name
    Attach UE and Verify DRx parameters     DLC320
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    Log to console          ${UE_IP}
    ${pingres}=             Do DL ping      ${UE_IP}   numberofping=120    intervalofpings=1
    ${linelostping}=        Get lines containing String     ${pingres}          packet loss
    Verify no ping lost     pingreport=${linelostping}
    ${linertt}=             Get lines containing String     ${pingres}          min/avg/max/mdev
    ${checkrtt}=            Get average rtt                 pingreport=${linertt}
    Verify latency          ${refrtt}                       ${checkrtt}      DLC320
    Detach Ue  UE_1


[1]5GC002060_A_39_NSA_StaticCall_DrxLongCycle80_Activation
    [Documentation]     This test case verify the activation of feature 5GC002060-A in case 80mS used
    ...                 First the gNB is configure with feature deactivated and network is verified
    ...                 checking that no packet lost in a 120 packets ping
    ...                 Then, a bad configuration using 80 mS DLC is tried, relation errors should be raised
    ...                 when validating
    ...                 Then a good configuration is used and activated, a UE is attached and a verification is done
    ...                 on the used parameters.
    ...                 A 120 ping is then launch and no packets should be lost.

    [Tags]              # QC_474953
    get and validate scf file    SCF_basic.xml
    log                     5GC002060_A_39_NSA_StaticCall_DrxLongCycle80_Activation
    ${cells_id}             Get list of all cells
    log                     liste des cellules
    log                     ${cells_id}     formatter=repr
    ${cellgrps_id}          Get list of all cellsgroup
    log                     liste des cells groupes
    log                     ${cellgrps_id}     formatter=repr
    Set edrx parameters     DRXOFF      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values    SCF_DRXOFF.xml
    log                     validation of SCF_DRXOFF is ${Validationresult}
    scf uploading and commissioning     SCF_DRXOFF.xml
    Run Keyword and Ignore Error    Detach Ue  UE_1
    5GC002060keysFDD.Pcap collection
    Attach Ue   UE_1
    5GC002060keysFDD.Pcap log downlad
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    Log to console          ${UE_IP}
    sleep                   10s
    ${pingres}=             Do DL ping      ${UE_IP}   numberofping=120    intervalofpings=1
    ${linelostping}=        Get lines containing String     ${pingres}          packet loss
    Verify no ping lost     pingreport=${linelostping}
    Detach Ue  UE_1
    sleep                   10s
    Set edrx parameters     DLC80N     ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values with pdl error             SCF_DLC80N.xml
    log                     validation of SCF_DLC80N is ${Validationresult}
    Set edrx parameters     DLC80      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values    SCF_DLC80.xml
    log                     validation of SCF_DLC80 is ${Validationresult}
    scf uploading and commissioning         SCF_DLC80.xml      tcpdumpguard=${true}
    Set Board Name
    Attach UE and Verify DRx parameters     DLC80
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    Log to console          ${UE_IP}
    ${pingres}=             Do DL ping      ${UE_IP}   numberofping=120    intervalofpings=1
    ${linelostping}=        Get lines containing String     ${pingres}          packet loss
    Verify no ping lost     pingreport=${linelostping}
    Detach Ue  UE_1


5GC002060_A_32_SA_classical_cmw_FDD_MSC_StaticCall_DrxLongCycle640_Counters
    [Documentation]     This test case verify the counters associated with DRx feature M55308C11001 and M55308C11002.
    ...                 First the gNB is configure DLC 640 configuration, then the the beginig of next reporting period
    ...                 is waited
    ...                 A UE is attached and it is pinged every 5 second for a little more than the test duration
    ...                 to maintained it connected
    ...                 At the end of the ping, the last pm counter file is retrived and the counters are checked.
    ...                 In case M55308C11001 is 0, M55308C11002 should be 0 (cells where there is no UE)
    ...                 In case M55308C11001 is not 0, the ration  M55308C11002 / M55308C11001 is verify to be in
    ...                 correct range
    ...                 At least one counter M55308C11001 should be not equal to 0

    [Tags]              # QC_464576
    get and validate scf file    SCF_basic.xml
    log                     5GC002060_A_32_SA_classical_cmw_FDD_MSC_StaticCall_DrxLongCycle640_Counters
    ${cells_id}             Get list of all cells
    log                     liste des cellules
    log                     ${cells_id}     formatter=repr
    ${cellgrps_id}          Get list of all cellsgroup
    log                     liste des cells groupes
    log                     ${cellgrps_id}     formatter=repr
    Set edrx parameters     DLC640      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values    SCF_DLC640.xml
    log                     validation of SCF_DLC640 is ${Validationresult}
    scf uploading and commissioning         SCF_DLC640.xml      tcpdumpguard=${true}
    5GC002060keysFDD.Wait for next pm period                 guardtime=60                before=${true}
    Set Board Name
    Run Keyword and Ignore Error    Detach Ue  UE_1
    Attach UE and Verify DRx parameters     DLC640
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    Log to console          ${UE_IP}
    ${pingres}=             Do DL ping      ${UE_IP}  numberofping=195    intervalofpings=5
    ${linelostping}=        Get lines containing String     ${pingres}          packet loss
    Verify no ping lost     pingreport=${linelostping}
    Get last pm counter file and expand it
    Check 2060 PM counters                  EDRXCONFIG=DLC640
    Detach Ue  UE_1


[1]5GC002060_A_6_NSA-classical-cmw-FDD_MSC_StaticCall_DrxLongCycle160_Counters
    [Documentation]     This test case verify the counters associated with DRx feature M55308C11001 and M55308C11002.
    ...                 First the gNB is configure DLC 160 configuration, then the the beginig of next reporting period
    ...                is waited
    ...                 A UE is attached and it is pinged every 5 second for a little more than the test duration
    ...                 to maintained it connected
    ...                 At the end of the ping, the last pm counter file is retrived and the counters are checked.
    ...                 In case M55308C11001 is 0, M55308C11002 should be 0 (cells where there is no UE)
    ...                 In case M55308C11001 is not 0, the ration  M55308C11002 / M55308C11001 is verify to be in
    ...                correct range
    ...                 At least one counter M55308C11001 should be not equal to 0

    [Tags]              # QC_440077
    get and validate scf file    SCF_basic.xml
    log                     5GC002060_A_6_NSA_classical_cmw_FDD_MSC_StaticCall_DrxLongCycle160_Counters
    ${cells_id}             Get list of all cells
    log                     liste des cellules
    log                     ${cells_id}     formatter=repr
    ${cellgrps_id}          Get list of all cellsgroup
    log                     liste des cells groupes
    log                     ${cellgrps_id}     formatter=repr
    Set edrx parameters     DLC160      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values    SCF_DLC160.xml
    log                     validation of SCF_DLC160 is ${Validationresult}
    scf uploading and commissioning         SCF_DLC160.xml      tcpdumpguard=${true}
    5GC002060keysFDD.Wait for next pm period                 guardtime=60                before=${true}
    Set Board Name
    Run Keyword and Ignore Error    Detach Ue  UE_1
    Attach UE and Verify DRx parameters     DLC160
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    Log to console          ${UE_IP}
    ${pingres}=             Do DL ping      ${UE_IP}   numberofping=195    intervalofpings=5
    ${linelostping}=        Get lines containing String     ${pingres}          packet loss
    Verify no ping lost     pingreport=${linelostping}
    Get last pm counter file and expand it
    Check 2060 PM counters                  EDRXCONFIG=DLC160
    Detach Ue  UE_1


[1]5GC002060_A_36_NSA_classical-cmw-FDD_Feature_Activation DLC 640mS
    [Documentation]     This test case verify the activation of feature 5GC002060-A in case 640mS used
    ...                 First the gNB is configure with feature deactivated and network is verified
    ...                 checking that no packet lost in a 120 packets ping
    ...                 Then, a bad configuration using 640mS DLC is tried, relation errors should be raised
    ...                 when validating
    ...                 Then a good configuration is used and activated, a UE is attached and a verification is done
    ...                 on the used parameters.
    ...                 A 120 ping is then launch and no packets should be lost.
    get and validate scf file    SCF_basic.xml
    [Tags]              # QC_463932
    log                     5GC002060_A_36_NSA_classical_cmw_FDD_Feature_Activation DLC 640mS
    ${cells_id}             Get list of all cells
    log                     liste des cellules
    log                     ${cells_id}     formatter=repr
    ${cellgrps_id}          Get list of all cellsgroup
    log                     liste des cells groupes
    log                     ${cellgrps_id}     formatter=repr
    Set edrx parameters     DRXOFF      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values                    SCF_DRXOFF.xml
    log                     validation of SCF_DRXOFF is ${Validationresult}
    scf uploading and commissioning     SCF_DRXOFF.xml
    Run Keyword and Ignore Error    Detach Ue  UE_1
    5GC002060keysFDD.Pcap collection
    Attach Ue   UE_1
    5GC002060keysFDD.Pcap log downlad
    sleep
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    ${pingres}=             Do DL ping      ${UE_IP}   numberofping=120    intervalofpings=1
    ${linelostping}=        Get lines containing String     ${pingres}      packet loss
    Verify no ping lost     pingreport=${linelostping}
    Detach Ue  UE_1
    sleep                   10s
    Set edrx parameters     DLC640N     ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values with pdl error         SCF_DLC640N.xml
    log                     validation of SCF_DLC640N is ${Validationresult}
    Set edrx parameters     DLC640      ${cells_id}     ${cellgrps_id}
    ${Validationresult}     validate modified values    SCF_DLC640.xml
    log                     validation of SCF_DLC640 is ${Validationresult}
    scf uploading and commissioning     SCF_DLC640.xml      tcpdumpguard=${true}
    Set Board Name
    Attach UE and Verify DRx parameters     DLC640
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    Log to console          ${UE_IP}
    ${pingres}=             Do DL ping      ${UE_IP}   numberofping=120    intervalofpings=1
    ${linelostping}=        Get lines containing String     ${pingres}      packet loss
    Verify no ping lost     pingreport=${linelostping}
    Detach Ue  UE_1


[1][1.0] 5GC002060_A_3_FGCR8144_NSA_TMO
    [Documentation]     This test case verify the FGCR-8144 using a TMO described user scenario
    ...                 First the gNB is configure with the feature
    ...                 A UE is then Attach and the following actions are done 20 times in a loop
    ...                 Do a ping sequence of 20 pings first ping may have an induced latency that should be less than
    ...                 two times the DRx long cycle (one onduration cycle could be missed), the following  shouldn't
    ...                 Wait 2 mn
    ...                 At the end of the loop, the average latency upon the first ping should be comprised
    ...                 in a defined range

    [Tags]              # QC_584889
    get and validate scf file    SCF_basic.xml
    Run Keyword And Ignore Error  Check adb devices
    log                     5GC002060_A_3_FGCR8144_NSA_TMO
    ${cells_id}             Get list of all cells
    log                     Listing cells
    log                     ${cells_id}     formatter=repr
    ${cellgrps_id}          Get list of all cellsgroup
    log                     Listing cell groups
    log                     ${cellgrps_id}     formatter=repr
    ${edrxcfg}      Get From Dictionary         ${paramsFGCR8144}      NSA_20B
    log             ${edrxcfg}\n                formatter=repr
    Set branches params     ${edrxcfg}  cells_id=@{cells_id}    cellgrps_id=@{cellgrps_id}
    ${Validationresult}     validate modified values    SCF_FGCR8144_NSA_21A.xml
    log                     validation of SCF_FGCR8144_NSA_21A is ${Validationresult}
    scf uploading and commissioning     SCF_FGCR8144_NSA_21A.xml
    sleep                   20s
    5GC002060keysFDD.Pcap collection
    Sleep  10s
    ####### GET UE IP #########
    Attach Ue   UE_1
    Sleep  10s
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    5GC002060keysFDD.Pcap log downlad
    Log to console  ${UE_IP}
    ${gmaxnormPing}     Set variable    0.0
    ${avglatency}       Set variable    0.0
    FOR     ${idx}      IN RANGE    1   21
        # ${tocheck}      Do FGCR8144 UL ping sequence    127.0.0.1   Iswindow=${false}
        ${tocheck}      Do FGCR8144 UL ping sequence    ${UE_IP}
        ${mnorping}     ${seqlat}       Analyse FGCR8144 ping sequence      ${tocheck}      WaitLatency=160
        ${gmaxnormPing}=    Set Variable If     ${gmaxnormPing} < ${mnorping}
        ...                 ${mnorping}
        ...                 ${gmaxnormPing}
        ${avglatency}=      Evaluate    ${avglatency} + ${seqlat}
        sleep               120 s
    END
    ${avglatency}=      Evaluate    ${avglatency} / 20.0
    ${pdiff}=           Evaluate        ${avglatency} - ${gmaxnormPing}
    ${latencydict}      Get From Dictionary     ${edrxcfg}            LATENCY
    log                 ${latencydict}\n        formatter=repr
    ${maxlat}           Get From Dictionary     ${latencydict}        maxlatency
    Should be true      ${pdiff} <= ${maxlat}
    [Teardown]    Detach UE    UE_1
