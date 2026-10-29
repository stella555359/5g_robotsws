*** Settings ***
Documentation    Suite description
...    Author:        xingqiang.wu@nokia-sbell.com,qiang_1_zhou@nokia-sbell.com,lisa.ding@nokia-sbell.com
...    Maintainer:    Author,I_EXT_MN_P_LTE_V_SISO_HANGZHOU_GMS
Library     SSHLibrary
Library  OperatingSystem
Library  ute_fsmaccess



*** Keywords ***
Restart SAS Simulator
    OperatingSystem.Run     sh testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/resources/SASSim/stop.sh
    Copy_SAS_Simulator_Files
    Start Process    python testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/resources/SASSim/SAS_Sim_persistent.py&    shell=True



Copy_SAS_Simulator_Files
    SSHLibrary.Open Connection    ${BTS_HOST}    timeout=10
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${out}    SSHLibrary.Write    ls /rom/etc/sas/cbrsRootCACertificate.pem
    ${out}    SSHLibrary.Read Until    >
    ${ret}    Run Keyword And Return Status    Should Match Regexp    ${out}    .*No such file or directory
    Return From Keyword If    not ${ret}
    Run Keyword And Ignore Error    SSHLibrary.Write    mkdir /rom/etc/sas
    SSHLibrary.Read Until    >
    SSHLibrary.Close Connection
    ${dictory}    Set Variable    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/resources/SASSim
    Setup Enb Fsm Access
    Put Enb File    ${dictory}/nokia04.cert    /rom/etc/sas/cbrsVendorCertChain.pem
    Put Enb File    ${dictory}/nokia04.key    /rom/etc/sas/cbrsPrivKey.pem.crk
    Put Enb File    ${dictory}/ca.cert    /rom/etc/sas/cbrsRootCACertificate.pem
    Teardown Enb Fsm Access
    SSHLibrary.Open Connection    ${BTS_HOST}    timeout=10
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Write    cd /rom/etc/sas
    SSHLibrary.Read Until    >
    SSHLibrary.Write    openssl x509 -noout -hash -in cbrsRootCACertificate.pem
    SSHLibrary.Read Until    aaae4089
    SSHLibrary.Write    ln -s /rom/etc/sas/cbrsRootCACertificate.pem /rom/etc/sas/aaae4089.0
    SSHLibrary.Read Until    >
    SSHLibrary.Write    chown btssw:btssw /rom/etc/sas/ -R
    SSHLibrary.Read Until    >
    SSHLibrary.Write    reboot
    SSHLibrary.Read Until    >
    Sleep    180
    [Teardown]    SSHLibrary.Close Connection
