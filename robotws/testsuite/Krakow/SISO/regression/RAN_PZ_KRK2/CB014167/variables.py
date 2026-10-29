from robot.libraries.BuiltIn import BuiltIn

BLACKBOX_VERSION = {"SBTS26R1": "BlackBox ver: 5.1",
                    "SBTS26R2": "BlackBox ver: 5.6",
                    "SBTS26R3": "BlackBox ver: 5.8"
                    }
COMMAND_VERSION = "cat /mnt/runtime/BBOX5"
COMMAND_SFP = "awk '/Item id: FronthaulProtocol/{flag=0} /Item type: SFP_info/{flag=1} flag' /mnt/runtime/BBOX5"
hist_cmd_awk = "awk '/Item type: Optical_lvl_signal/ {f=1; next} /Item type: POST_results/"
COMMAND_HIST = hist_cmd_awk + "&& f {print; f=0} f' /mnt/runtime/BBOX5"
reset_cmd_awk = "awk -v b=15 '/Item type: BtsAlarmHistory/{f=1;next} {buf[NR]=$0} f && /--/"
COMMAND_RESET = reset_cmd_awk + " && !d{for(i=NR-b;i<=NR;i++) if(i>=0) print buf[i]; d=1}' /mnt/runtime/BBOX5"

tl = BuiltIn().get_variable_value('${tl}')
BTS_ID = tl.gnbs[0].global_bts_id
DU_ID = tl.gnbs[0].global_bts_id
GNB_IP = tl.gnbs[0].cu.oam_ssh_connection_details.addr
PASSWORD_GNB = tl.gnbs[0].cu.oam_ssh_connection_details.password
USER_GNB = tl.gnbs[0].cu.oam_ssh_connection_details.username
location_aehc = tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].rus[0]
location_ahfig = tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[1].rus[1]
location_ahloa = tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[1].rus[0]

RU_PASS = [{
    "name": "aehc",
    "id": "1",
    "sn": location_aehc.serial_number,
    "user": location_aehc.default_ssh_connection_details.username,
    "password": location_aehc.default_ssh_connection_details.password,
    "console_prompt": "$"
}]
