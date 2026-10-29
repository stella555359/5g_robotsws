*** Settings ***
Documentation     author: Zhu jianhua
...               contact: jianhua.1.zhu@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC001840

*** Variables ***
${UPDATE_FILE_PATH}    /opt/ute/tmp
#${CFGFILE_PATH}    /home/ute/TAF/cfgfile/1840
#TL14 RU1
${PB_5GRU_IP}     ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}    ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
#TL14 RU2
${PB_5GRU_2_IP}    ${tl.gnbs[0].dus[0].rus[1].pdu_port.pdu.addr}
${PB_5GRU_2_PORT}    ${tl.gnbs[0].dus[0].rus[1].pdu_port.port_no}
#TL14 RU3
${PB_5GRU_2_IP}    ${tl.gnbs[0].dus[0].rus[2].pdu_port.pdu.addr}
${PB_5GRU_2_PORT}    ${tl.gnbs[0].dus[0].rus[2].pdu_port.port_no}

*** Keywords ***
#---------------------gNB basic operation-------------------------------------------------------------------------------
Power.Reset5G_RU
    facom.PowerOnOff    pdu_ip=${PB_5GRU_1_IP}    Port_Number=${PB_5GRU_1_PORT}    Action=power_off
    facom.PowerOnOff    pdu_ip=${PB_5GRU_1_IP}    Port_Number=${PB_5GRU_1_PORT}    Action=power_on

Power.Reset5G_RU2
    facom.PowerOnOff    pdu_ip=${PB_5GRU_2_IP}    Port_Number=${PB_5GRU_2_PORT}    Action=power_off
    facom.PowerOnOff    pdu_ip=${PB_5GRU_2_IP}    Port_Number=${PB_5GRU_2_PORT}    Action=power_on

Power.Reset5G_RU3
    facom.PowerOnOff    pdu_ip=${PB_5GRU_3_IP}    Port_Number=${PB_5GRU_3_PORT}    Action=power_off
    facom.PowerOnOff    pdu_ip=${PB_5GRU_3_IP}    Port_Number=${PB_5GRU_3_PORT}    Action=power_on

Power.ResetgNB
    facom.PowerOnOff    pdu_ip=${PB_ASIK_IP}    Port_Number=${PB_ASIK_PORT}     Action=power_off
    facom.PowerOnOff    pdu_ip=${PB_ASIK_IP}    Port_Number=${PB_ASIK_PORT}     Action=power_on