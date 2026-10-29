*** Settings ***
Library     taf.sbts.oam.coam.admin   WITH NAME   cli
Library     XML    use_lxml=True
Library     taf.transport.ssh    WITH NAME    ssh
Library     OperatingSystem
Library     DateTime
Library     XML    use_lxml=True
Library     taf.collectors.btslog    WITH NAME   btslog
Library     taf.collectors.core    WITH NAME    core
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME    trs_ssh
Library     taf.hw.pdu    WITH NAME    pdu
Library     String
Library     BuiltIn
Library     Collections
Library     ute_admin
Library     Process
Library     ../resources/ONAP_keywords.py


*** Variables ***
${gNB_IP_MPLANE_LOCAL}=    192.168.255.1
${gNB_MPLANE_IF_PORT}     443
${ssh_alias}=   default
${hostname}=    192.168.255.1
${username}=    toor4nsn
${password}=    oZPS0POrRieRtu
${ssh_alias}=   default
${get_current_PMs}=                   ls -l /data/onapusers/measurements | tail -n 1
