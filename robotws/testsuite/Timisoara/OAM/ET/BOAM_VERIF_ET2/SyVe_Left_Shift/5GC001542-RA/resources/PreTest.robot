*** Settings ***
Resource    ../../resources/pretest_posttest.robot

*** Keywords ***
1542-RA Suite Preconditions
    Suite Preconditions
    load_scf_file
    Make suite variable $ {mrbtsId} and $ {btsName}
#    connect_to_lss_server_ipv4
    connect to du
    Assure TRBLCADM object exists

1542-RA Suite Postconditions
    Suite Postconditions

1542-RA Test Preconditions
    Test Preconditions

1542-RA Test Postconditions
    Test Postconditions
