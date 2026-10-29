*** Settings ***
Documentation    Common variables for 920 feature

*** Variables ***
${RU_1_SERIAL_NUM}               ${tl.gnbs[0].dus[0].rus[0].serial_number}
${RU_TYPE}                       ${tl.gnbs[0].dus[0].rus[0].radio_type.value}
${SCF_DEFAULT_FILE_PATH}          /opt/ute/scf/SCF_SG4_TL${tl.gnbs[0].instance_id}_4T2R.xml
${SWCONFIG_DEFAULT_FILE_PATH}     /opt/ute/swconfig/swconfig_SG4_TL${tl.gnbs[0].instance_id}.txt
${LUA_SCRIPT_PATH}               /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
${DL_PORT}                       ${tl.ues[0].iperf_details.port}
${UL_PORT}                       ${tl.ues[0].iperf_details.ssh_connection_details.port}

# alias
${ASIK_MASTER_ALIAS}             ASIK Master
${ASIK_SLAVE_ALIAS}              ASIK Slave
${ENB_ALIAS}                     enblte
${GNB_COAM_ALIAS}                GNB_OAM
${ABIL_ALIAS}                    ABIL Loner_1
@{RUS_ALIAS}                     RU_1    RU_2
${PDL_CHECKING}                  ${False}
${TSHARK_PATH}                   /usr/bin/tshark

#expected percentage of given theoretical throuput
${EXP_TPUT_PERCENTAGE}           0.95
