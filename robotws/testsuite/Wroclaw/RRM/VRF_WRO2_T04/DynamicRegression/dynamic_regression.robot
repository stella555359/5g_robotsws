*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Library       ute_admin
#Library       ute_ue
#Library       SSHLibrary
#Library       ../../../resources/rrm_fixture.py
#Library       ../../../resources/webui/interface.py
#Library       ../../../resources/etws_cmas/counters.py
#Library       ../../../resources/attenuator_keywords.py
#Library      ./delta_keywords.py
#Library      ./pcap_verifiers.py
Library      ./resources/dynamic_regression.py
Resource     ./resources/keywords.robot
#Library      ta5g_commissioning
#Library       ta5g_cell_operations
#
#Variables      ./att_settings_ca.py
#Variables    ./ca_variables.py

*** Variables ***
${CA_UE}=     UE_1


*** Keywords ***
#AHFIB_5MHz
#    Change Chbw    101    5
#    Attach UE To Pcell    ${CA_UE}
#    Start DL Traffic For Ue    dl_tput=44Mbits/sec    protocol=tcp
#    Verify DL Tput For Ue
#    [Teardown]    Detach Ue    ${CA_UE}
#
#AHFIB_10MHz
#    Change Chbw    101    10
#    Attach UE To Pcell    ${CA_UE}
#    Start DL Traffic For Ue    dl_tput=100Mbits/sec    protocol=tcp
#    Verify DL Tput For Ue
#    [Teardown]    Detach Ue    ${CA_UE}
#
#AHFIB_15MHz
#    Change Chbw    101    15
#    Attach UE To Pcell    ${CA_UE}
#    Start DL Traffic For Ue    dl_tput=150Mbits/sec    protocol=tcp
#    Verify DL Tput For Ue
#    [Teardown]    Detach Ue    ${CA_UE}
#
#AHFIB_20MHz
#    Change Chbw    101    20
#    Attach UE To Pcell    ${CA_UE}
#    Start DL Traffic For Ue    dl_tput=210Mbits/sec    protocol=tcp
#    Verify DL Tput For Ue
#    [Teardown]    Detach Ue    ${CA_UE}
#
#AHLOA_5MHz
#    Change Chbw    100    5
#    Attach UE To Pcell    ${CA_UE}
#    Start DL Traffic For Ue    dl_tput=44Mbits/sec    protocol=tcp
#    Verify DL Tput For Ue
#    [Teardown]    Detach Ue    ${CA_UE}
#
#AHLOA_10MHz
#    Change Chbw    100    10
#    Attach UE To Pcell    ${CA_UE}
#    Start DL Traffic For Ue    dl_tput=100Mbits/sec    protocol=tcp
#    Verify DL Tput For Ue
#    [Teardown]    Detach Ue    ${CA_UE}
#
#AHLOA_15MHz
#    Change Chbw    100    15
#    Attach UE To Pcell    ${CA_UE}
#    Start DL Traffic For Ue    dl_tput=150Mbits/sec    protocol=tcp
#    Verify DL Tput For Ue
#    [Teardown]    Detach Ue    ${CA_UE}
#
#AHLOA_20MHz
#    Change Chbw    100    20
#    Attach UE To Pcell    ${CA_UE}
#    Start DL Traffic For Ue    dl_tput=210Mbits/sec    protocol=tcp
#    Verify DL Tput For Ue
#    [Teardown]    Detach Ue    ${CA_UE}
#

AEHC_40MHz
    Change Chbw    103    40
    Attach UE To Pcell    ${CA_UE}
    Start DL Traffic For Ue    dl_tput=210Mbits/sec    protocol=tcp
    Verify DL Tput For Ue
    [Teardown]    Detach Ue    ${CA_UE}

AEHC_50MHz
    Change Chbw    103    50
    Attach UE To Pcell    ${CA_UE}
    Start DL Traffic For Ue    dl_tput=210Mbits/sec    protocol=tcp
    Verify DL Tput For Ue
    [Teardown]    Detach Ue    ${CA_UE}

AEHC_60MHz
    Change Chbw    103    60
    Attach UE To Pcell    ${CA_UE}
    Start DL Traffic For Ue    dl_tput=210Mbits/sec    protocol=tcp
    Verify DL Tput For Ue
    [Teardown]    Detach Ue    ${CA_UE}

AEHC_80MHz
    Change Chbw    103    80
    Attach UE To Pcell    ${CA_UE}
    Start DL Traffic For Ue    dl_tput=210Mbits/sec    protocol=tcp
    Verify DL Tput For Ue
    [Teardown]    Detach Ue    ${CA_UE}

AEHC_100MHz
    Change Chbw    103    100
    Attach UE To Pcell    ${CA_UE}
    Start DL Traffic For Ue    dl_tput=210Mbits/sec    protocol=tcp
    Verify DL Tput For Ue
    [Teardown]    Detach Ue    ${CA_UE}
