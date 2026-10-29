from robot.libraries.BuiltIn import BuiltIn

attenuator = BuiltIn().get_variable_value('${tl.attenuator[0]}')

attenuator_ports = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]

NR_apn = "5gbothkrk"
LTE_apn = "5gbothkrk"

NRCELL_12_id = "1230798860"
NRCELL_12_tput_duration = "60"
NRCELL_12_dl_throughput = "1500M"
NRCELL_12_ul_throughput = "90M"
NRCELL_12_max_deviation = "20%"
NRCELL_12_attenuation_list = [30, 30, 30, 30, 110, 110, 110, 110, 110, 110, 110, 110]

NRCELL_17_id = "1230913553"
NRCELL_17_tput_duration = "30"
NRCELL_17_dl_throughput = "200M"
NRCELL_17_ul_throughput = "110M"
NRCELL_17_max_deviation = "20%"
NRCELL_17_attenuation_list = [110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 30, 30]


NRCELL_11_id = "1230798859"
NRCELL_11_tput_duration = "60"
NRCELL_11_dl_throughput = "1500M"
NRCELL_11_ul_throughput = "90M"
NRCELL_11_max_deviation = "20%"
NRCELL_11_attenuation_list = [30, 30, 30, 30, 110, 110, 110, 110, 110, 110, 110, 110]


LNCEL_22_id = "19238422"
LNCEL_22_tput_duration = "30"
LNCEL_22_dl_throughput = "100M"
LNCEL_22_ul_throughput = "30M"
LNCEL_22_max_deviation = "20%"
LNCEL_22_attenuation_list = [110, 110, 110, 110, 110, 110, 30, 30, 110, 110, 110, 110]


LNCEL_11_id = "19238411"
LNCEL_11_tput_duration = "30"
LNCEL_11_dl_throughput = "100M"
LNCEL_11_ul_throughput = "30M"
LNCEL_11_max_deviation = "20%"
LNCEL_11_attenuation_list = [110, 110, 110, 110, 110, 110, 30, 30, 110, 110, 110, 110]

ue_index = "1"

site_reset_data_transfer_configuration = [
    {
        "attenuator": attenuator,
        "attenuator_ports": attenuator_ports,
        "attenuator_values": NRCELL_12_attenuation_list,
        "apn": NR_apn,
        "cell_id": NRCELL_12_id,
        "ue_index": ue_index,
        "duration": NRCELL_12_tput_duration,
        "dl_throughput": NRCELL_12_dl_throughput,
        "ul_throughput": NRCELL_12_ul_throughput,
        "max_deviation": NRCELL_12_max_deviation,
    },
    {
        "attenuator": attenuator,
        "attenuator_ports": attenuator_ports,
        "attenuator_values": NRCELL_17_attenuation_list,
        "apn": NR_apn,
        "cell_id": NRCELL_17_id,
        "ue_index": ue_index,
        "duration": NRCELL_17_tput_duration,
        "dl_throughput": NRCELL_17_dl_throughput,
        "ul_throughput": NRCELL_17_ul_throughput,
        "max_deviation": NRCELL_17_max_deviation,
    },
    {
        "attenuator": attenuator,
        "attenuator_ports": attenuator_ports,
        "attenuator_values": LNCEL_22_attenuation_list,
        "apn": LTE_apn,
        "cell_id": LNCEL_22_id,
        "ue_index": ue_index,
        "duration": LNCEL_22_tput_duration,
        "dl_throughput": LNCEL_22_dl_throughput,
        "ul_throughput": LNCEL_22_ul_throughput,
        "max_deviation": LNCEL_22_max_deviation,
    },
]

radio_module_power_reset_data_transfer_configuration = [
    {
        "attenuator": attenuator,
        "attenuator_ports": attenuator_ports,
        "attenuator_values": NRCELL_11_attenuation_list,
        "apn": NR_apn,
        "cell_id": NRCELL_11_id,
        "ue_index": ue_index,
        "duration": NRCELL_11_tput_duration,
        "dl_throughput": NRCELL_11_dl_throughput,
        "ul_throughput": NRCELL_11_ul_throughput,
        "max_deviation": NRCELL_11_max_deviation,
    },
    {
        "attenuator": attenuator,
        "attenuator_ports": attenuator_ports,
        "attenuator_values": NRCELL_17_attenuation_list,
        "apn": NR_apn,
        "cell_id": NRCELL_17_id,
        "ue_index": ue_index,
        "duration": NRCELL_17_tput_duration,
        "dl_throughput": NRCELL_17_dl_throughput,
        "ul_throughput": NRCELL_17_ul_throughput,
        "max_deviation": NRCELL_17_max_deviation,
    },
    {
        "attenuator": attenuator,
        "attenuator_ports": attenuator_ports,
        "attenuator_values": LNCEL_11_attenuation_list,
        "apn": LTE_apn,
        "cell_id": LNCEL_11_id,
        "ue_index": ue_index,
        "duration": LNCEL_11_tput_duration,
        "dl_throughput": LNCEL_11_dl_throughput,
        "ul_throughput": LNCEL_11_ul_throughput,
        "max_deviation": LNCEL_11_max_deviation,
    },
]
