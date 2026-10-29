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
${RKE_usr}=             ute
${RKE_password}=        Ut3pa5s#84b6

${CUSTOM_BTS_NAME}=     bts&^@test
${CUSTOM_CELL_NAME}=    @test_cell!
${gNB_IP_MPLANE_LOCAL}=    192.168.255.1
${gNB_MPLANE_IF_PORT}     443
${ssh_alias}=   default
${hostname}=    192.168.255.1
${username}=    toor4nsn
${password}=    oZPS0POrRieRtu
${ssh_alias}=   default
${rke_alias}=    rke
${get_current_PMs}=                   ls -l /data/onapusers/measurements | tail -n 1
${get_ves_id}=                        kubectl get pods -n onap | grep -m 1 -i dep-dcae-ves | awk '{print $1;}'
${get_datafile_collector_id}=         kubectl get pods -n onap | grep -m 1 -i datafile | awk '{print $1;}'
${get_pmm_collector_id}=              kubectl get pods -n onap | grep -m 1 -i pm-mapper | awk '{print $1;}'
${delta_file}=    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/resources/ready_delta.json
