*** Settings ***
Resource        ../resources/NPS/SWENG/robot/Connect.robot
Library          ../resources/NPS/SWENG/python_libs/luashark_tools.py
Library           luashark_tools.analyzer       WITH NAME       analyze
Resource     ../resources/robot/common_log_collection.robot
Library     OperatingSystem
Suite Setup     Initiate Dcap
*** Variables ***
${log_path}    /home/ute/
${TS1}          stop1
${TS2}          stop2
${TS3}          stop3
${TS4}          Btssys
${TS5}          Btstti1
${TS6}          Btstti2
${TS7}          Snap1
${TS8}          Snap2
${TS9}          Ipcap1
${TS10}          Ipcap2
${TS11}          Ipcap3


@{Component1}   L2PS   L2LO   L2HIPDCP   L2HIRLC
@{Component2}   L2PS

#Suite Setup    Initiate Dcap

*** Test Cases ***
Test
    [Setup]    DCAP Connect To gNB    
    BuiltIn.Log  Test with cell as argument
    ${Nrcell}   Create List   NRCELL_1
    ### Bip eg1 ###
    Start Log Via DCAP  bip  Bip_monitoring_time=4  CellId=${Nrcell}
    sleep    5s
    ${getpath}  Stop Log Via DCAP  bip  test_scenario=${TS1}
    log to console  ${getpath}
    ### Bip eg2 ###
    Start Log Via DCAP  bip                            ## default "Bip_monitoring_time" is 5s
    sleep    5s
    ${getpath}  Stop Log Via DCAP  bip  test_scenario=${TS2}
    log to console  ${getpath}
    ### Bip eg3 ###
    Start Log Via DCAP  bip  Bip_monitoring_time=5     ## default all Cells are monitored.
    sleep    5s
    ${getpath}  Stop Log Via DCAP  bip  test_scenario=${TS3}
    log to console  ${getpath}
    ### Syslog ###
    Start Log Via DCAP  btslog
    sleep    5s
    ${getpath1}  Stop Log Via DCAP  btslog  test_scenario=${TS4}
    log to console  ${getpath1}
    ### L2comp eg1 ###
    Start Log Via DCAP  ttitrace  component=${Component1}    CellId=${Nrcell}
    sleep    5s
    ${getpath1}  Stop Log Via DCAP  ttitrace  test_scenario=${TS5}
    log to console  ${getpath1}
    ### L2comp eg2 ###
    Start Log Via DCAP  ttitrace  component=${Component2}
    sleep    5s
    ${getpath1}  Stop Log Via DCAP  ttitrace  test_scenario=${TS6}
    log to console  ${getpath1}
    ### Snapshot eg1 ###
    ${getpath1}  Stop Log Via DCAP  snapshot  test_scenario=${TS7}
    log to console  ${getpath1}
    ### Snapshot eg2 ###
    ${getpath1}  Stop Log Via DCAP  snapshot  test_scenario=${TS8}  CellId=${Nrcell}
    log to console  ${getpath1}
    ### Ipcapture eg1 ###
    Start Log Via DCAP  ipcapture                       ## default ${capturepoint}i s A and ${uplane_iface}=False
    sleep    5s
    ${getpath}  Stop Log Via DCAP  ipcapture  test_scenario=${TS9}
    log to console  ${getpath}
    ### Ipcapture eg2 ###
    Start Log Via DCAP  ipcapture   capturepoint=B      ## default uplane interface is not captured
    sleep    5s
    ${getpath}  Stop Log Via DCAP  ipcapture  test_scenario=${TS10}
    log to console  ${getpath}
    ### Ipcapture eg3 ###
    Start Log Via DCAP  ipcapture   capturepoint=B      uplane_iface=True
    sleep    5s
    ${getpath}  Stop Log Via DCAP  ipcapture  test_scenario=${TS11}
    log to console  ${getpath}
    [Teardown]     DCAP Disconnect To gNB
