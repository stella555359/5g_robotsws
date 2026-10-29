*** Settings ***
Documentation
...   author: Karolina Pawlik
...   contact: karolina.pawlik.ext@nokia.com

Resource    testsuite/Wroclaw/RRM/resources/connections.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/keywords_2534.py
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Library     taf.collectors.btslog  WITH NAME   btslog
Library     taf.transport.ssh      WITH NAME   csn
Library     taf.converters.pcaptopdml    WITH NAME    pcaptopdml



*** Keywords ***

Start BTSlog
    [Arguments]                 ${name}=btslog
    btslog.Create btslog collector
    ...                         name=${name}
    ...                         log_dir=/tmp/btslog2
    btslog.Setup collectors     names=${name}
    btslog.Start collectors     names=${name}
    btslog.Set suite alias      btslog


Stop BTSlog
    [Arguments]                     ${name}=btslog
    btslog.Stop collectors          names=${name}
    btslog.Collect collectors       names=${name}
    btslog.Teardown collectors      names=${name}
    Remove tmp btslog dir


