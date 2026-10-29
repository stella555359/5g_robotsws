*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Malgorzata Konior <malgorzata.konior@nokia.com>
...      == MAINTAINER ==
...       - Malgorzata Konior <malgorzata.konior@nokia.com>

Resource     ../../../resources/Robot/common_settings.robot
Resource     ../../resources/yaml_config_paths.robot
Library      ../../resources/python/mock_stop_egate.py
Library      alarms_verifiers.py
Library      taf.ul.ue.sim.env_setup
Library      taf.ul.hanging_resources.listener  ${False}

*** Variables ***
&{cell_gscn}=  1=640608  2=633312  3=648000

*** Keywords ***
Run Setup
    Log To Console    Setup started
    ${run_update}    get variable value      ${configure}    "True"   # do not ever change that line!
    Run Keyword if  ${run_update} != ${False}
    ...    Prepare TL with config files

    Setup egate  egate_port=20000  alias=default
    Setup devices aliases
    Reliable emss setup         bts_id=1

Setup devices aliases
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1
    Create cells alias     alias=NRCELL    cells_type=wts_5g

Prepare TL with config files
     Log To Console    Configure ENV with SCFC/AP.xml/LUA
     Add gNB configuration    scfc=${SCFC}
     Add simulator    sim_type=airphone    config=${AP_XML}
     Add 5GC    config=${LUA_CFG}    edaemon_ports=10000
     Configure environment    rmod_detection_timeout=420s
     Log To Console    After Configure ENV

Enable CB010378 and CB010507 features
    Create new plan
    Edit planned object attributes    NRBTS-1    actExt2N77Support=True
    Edit planned object attributes    NRCELL-1   actLegExt2N77Coexist=True
    Apply planned changes

    Wait For Object Attribute Value
    ...     object_name=NRCELL-1
    ...     attribute_name=operationalState
    ...     value=enabled
    ...     timeout=300

Disable CB010378 and CB010507 features
    Create new plan
    Edit planned object attributes    NRBTS-1    actExt2N77Support=False
    Edit planned object attributes    NRCELL-1   actLegExt2N77Coexist=False
    Apply planned changes

Check no NRCELL related errors in ADMIN
    Log to console  Checking Cell related alarms
    Wait until keyword succeeds  60 sec  10 sec
    ...    Verify that 7516 alarm with Incorrect Cell Parameter Configuration fault was not raised
    Sleep  1

Verify that 7516 alarm with Incorrect Cell Parameter Configuration fault was not raised
    ${result}  Verify that alarm 7516 with Incorrect cell parameter configuration fault is not active
    Pass Execution If  '${result}'=='True'  Alarm 7516 was not found
    Fail  Alarm 7516 found

Prepare SIBs check in NRCELL-${nrcell_id:\d+}
    EXPECT FLOW[timeout=300]: NRCELL_2_${nrcell_id} NR-RRC SIB1
    EXPECT FLOW[timeout=300]: NRCELL_2_${nrcell_id} NR-RRC SystemInformation

Verify SIBs are present in NRCELL-${nrcell_id:\d+}
    PASS FLOW[timeout=300]: NRCELL_2_${nrcell_id} NR-RRC SIB1
    PASS FLOW[timeout=300]: NRCELL_2_${nrcell_id} NR-RRC SystemInformation

Verify NRCELL-${nrcell_id:\d+} SIB1 does not contain additionalSpectrumEmission
    ${flow_alias_rrc}=     Get Flow Name
    ...     SIB1
    ...     device=NRCELL_2_${nrcell_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     servingCellConfigCommon contains (
    ...         nr-NS-PmaxList is not present
    ...     )
    ...     message_alias=SIB1
    ...     flow_alias=${flow_alias_rrc}

Verify NRCELL-${nrcell_id:\d+} SIB2 does not contain additionalSpectrumEmission
    ${flow_alias_rrc}=     Get Flow Name
    ...     SystemInformation
    ...     device=NRCELL_2_${nrcell_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     sib2 contains (
    ...             intraFreqCellReselectionInfo contains (
    ...         nr-NS-PmaxList is not present
    ...     ))
    ...     message_alias=SystemInformation
    ...     flow_alias=${flow_alias_rrc}
