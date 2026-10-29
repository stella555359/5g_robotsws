*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../../DevKr/resources/yaml_config_paths.robot

*** Keywords ***
Set UE IDLE timers on gNB: drbInactivityTimerSA=${drbTimer:\d+} srbInactivityTimerSA=${srbTimer:\d+}
    ${actual}=    Get object attributes    NRBTS-1    drbInactivityTimerSA   enb_id=1
    IF   ${actual}!=${drbTimer}
    ...  Edit object attributes
    ...     object_name=NRBTS-1
    ...     drbInactivityTimerSA=${drbTimer}
    ...     bts_id=1

    ${actual}=    Get object attributes    NRBTS-1    srbInactivityTimerSA   enb_id=1
    IF   ${actual}!=${srbTimer}
    ...  Edit object attributes
    ...     object_name=NRBTS-1
    ...     srbInactivityTimerSA=${srbTimer}
    ...     bts_id=1

#    Set         drbInactivityTimerSA       ${drbTimer}
#    Set         srbInactivityTimerSA       ${srbTimer}
#    Configure       ${SA_srb_drb_inactivity_yaml_path}      bts_id=1

Restore default gNB radio bearer inactivity timers
    Log to console  Setting default inactivity timers...
    Set UE IDLE timers on gNB: drbInactivityTimerSA=600 srbInactivityTimerSA=600
