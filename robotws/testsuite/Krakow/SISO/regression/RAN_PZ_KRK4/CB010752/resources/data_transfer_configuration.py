from robot.libraries.BuiltIn import BuiltIn

attenuator = BuiltIn().get_variable_value('${tl.attenuator[0]}')

attenuator_ports = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]

NR_apn = "5gsakrk"
LTE_apn = "5gsakrk"

# config A:

NRCELL_331_id = "1231765835"
NRCELL_331_tput_duration = "60s"
NRCELL_331_dl_throughput = "400 Mbits/sec"
NRCELL_331_ul_throughput = "36 Mbits/sec"
NRCELL_331_max_deviation = "60%"
NRCELL_331_attenuation_list = [110, 110, 110, 110, 30, 30, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110]

NRCELL_110_id = "1231765614"
NRCELL_110_tput_duration = "60s"
NRCELL_110_dl_throughput = "105 Mbits/sec"
NRCELL_110_ul_throughput = "36 Mbits/sec"
NRCELL_110_max_deviation = "60%"
NRCELL_110_attenuation_list = [30, 30, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110]

NRCELL_10_id = "1231765514"
NRCELL_10_tput_duration = "60s"
NRCELL_10_dl_throughput = "210 Mbits/sec"
NRCELL_10_ul_throughput = "56 Mbits/sec"
NRCELL_10_max_deviation = "60%"
NRCELL_10_attenuation_list = [110, 110, 30, 30, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110]

# config B:

NRCELL_188_id = "1231765692"
NRCELL_188_tput_duration = "60s"
NRCELL_188_dl_throughput = "210 Mbits/sec"
NRCELL_188_ul_throughput = "108 Mbits/sec"
NRCELL_188_max_deviation = "60%"
NRCELL_188_attenuation_list = [110, 110, 30, 30, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110]

NRCELL_190_id = "1231765696"
NRCELL_190_tput_duration = "60s"
NRCELL_190_dl_throughput = "210 Mbits/sec"
NRCELL_190_ul_throughput = "108 Mbits/sec"
NRCELL_190_max_deviation = "60%"
NRCELL_190_attenuation_list = [110, 110, 110, 110, 110, 110, 30, 30, 110, 110, 110, 110, 110, 110, 110, 110]

LNCEL_15_id = "19246351"
LNCEL_15_tput_duration = "60s"
LNCEL_15_dl_throughput = "192 Mbits/sec"
LNCEL_15_ul_throughput = "70 Mbits/sec"
LNCEL_15_max_deviation = "60%"
LNCEL_15_attenuation_list = [110, 110, 110, 110, 110, 110, 110, 110, 30, 30, 110, 110, 110, 110, 110, 110]

LNCEL_26_id = "19246362"
LNCEL_26_tput_duration = "90s"
LNCEL_26_dl_throughput = "192 Mbits/sec"
LNCEL_26_ul_throughput = "70 Mbits/sec"
LNCEL_26_max_deviation = "60%"
LNCEL_26_attenuation_list = [30, 30, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110]

# config C:

NRCELL_11_id = "1231765515"
NRCELL_11_tput_duration = "60s"
NRCELL_11_dl_throughput = "360 Mbits/sec"
NRCELL_11_ul_throughput = "50 Mbits/sec"
NRCELL_11_max_deviation = "60%"
NRCELL_11_attenuation_list = [110, 110, 110, 110, 30, 30, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110]

NRCELL_13_id = "1231765517"
NRCELL_13_tput_duration = "60s"
NRCELL_13_dl_throughput = "360 Mbits/sec"
NRCELL_13_ul_throughput = "50 Mbits/sec"
NRCELL_13_max_deviation = "60%"
NRCELL_13_attenuation_list = [110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 30, 30, 110, 110]

LNCEL_202_id = "19246538"
LNCEL_202_tput_duration = "60s"
LNCEL_202_dl_throughput = "192 Mbits/sec"
LNCEL_202_ul_throughput = "70 Mbits/sec"
LNCEL_202_max_deviation = "60%"
LNCEL_202_attenuation_list = [110, 110, 110, 110, 110, 110, 30, 30, 110, 110, 110, 110, 110, 110, 110, 110]

LNCEL_204_id = "19246540"
LNCEL_204_tput_duration = "90s"
LNCEL_204_dl_throughput = "148 Mbits/sec"
LNCEL_204_ul_throughput = "36 Mbits/sec"
LNCEL_204_max_deviation = "60%"
LNCEL_204_attenuation_list = [110, 110, 30, 30, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110]

ue_index = "1"

data_transfer_configuration_A = [
    {
        "attenuator": attenuator,
        "attenuator_ports": attenuator_ports,
        "attenuator_values": NRCELL_331_attenuation_list,
        "apn": NR_apn,
        "cell_id": NRCELL_331_id,
        "ue_index": ue_index,
        "duration": NRCELL_331_tput_duration,
        "dl_throughput": NRCELL_331_dl_throughput,
        "ul_throughput": NRCELL_331_ul_throughput,
        "max_deviation": NRCELL_331_max_deviation,
    },
    {
        "attenuator": attenuator,
        "attenuator_ports": attenuator_ports,
        "attenuator_values": NRCELL_110_attenuation_list,
        "apn": NR_apn,
        "cell_id": NRCELL_110_id,
        "ue_index": ue_index,
        "duration": NRCELL_110_tput_duration,
        "dl_throughput": NRCELL_110_dl_throughput,
        "ul_throughput": NRCELL_110_ul_throughput,
        "max_deviation": NRCELL_110_max_deviation,
    },
    {
        "attenuator": attenuator,
        "attenuator_ports": attenuator_ports,
        "attenuator_values": NRCELL_10_attenuation_list,
        "apn": NR_apn,
        "cell_id": NRCELL_10_id,
        "ue_index": ue_index,
        "duration": NRCELL_10_tput_duration,
        "dl_throughput": NRCELL_10_dl_throughput,
        "ul_throughput": NRCELL_10_ul_throughput,
        "max_deviation": NRCELL_10_max_deviation,
    }
]

data_transfer_configuration_B = [
    {
        "attenuator": attenuator,
        "attenuator_ports": attenuator_ports,
        "attenuator_values": NRCELL_188_attenuation_list,
        "apn": NR_apn,
        "cell_id": NRCELL_188_id,
        "ue_index": ue_index,
        "duration": NRCELL_188_tput_duration,
        "dl_throughput": NRCELL_188_dl_throughput,
        "ul_throughput": NRCELL_188_ul_throughput,
        "max_deviation": NRCELL_188_max_deviation,
    },
    {
        "attenuator": attenuator,
        "attenuator_ports": attenuator_ports,
        "attenuator_values": NRCELL_190_attenuation_list,
        "apn": NR_apn,
        "cell_id": NRCELL_190_id,
        "ue_index": ue_index,
        "duration": NRCELL_190_tput_duration,
        "dl_throughput": NRCELL_190_dl_throughput,
        "ul_throughput": NRCELL_190_ul_throughput,
        "max_deviation": NRCELL_190_max_deviation,
    },
    {
        "attenuator": attenuator,
        "attenuator_ports": attenuator_ports,
        "attenuator_values": LNCEL_15_attenuation_list,
        "apn": LTE_apn,
        "cell_id": LNCEL_15_id,
        "ue_index": ue_index,
        "duration": LNCEL_15_tput_duration,
        "dl_throughput": LNCEL_15_dl_throughput,
        "ul_throughput": LNCEL_15_ul_throughput,
        "max_deviation": LNCEL_15_max_deviation,
    },
    {
        "attenuator": attenuator,
        "attenuator_ports": attenuator_ports,
        "attenuator_values": LNCEL_26_attenuation_list,
        "apn": LTE_apn,
        "cell_id": LNCEL_26_id,
        "ue_index": ue_index,
        "duration": LNCEL_26_tput_duration,
        "dl_throughput": LNCEL_26_dl_throughput,
        "ul_throughput": LNCEL_26_ul_throughput,
        "max_deviation": LNCEL_26_max_deviation,
    }
]

data_transfer_configuration_C = [
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
        "attenuator_values": NRCELL_13_attenuation_list,
        "apn": NR_apn,
        "cell_id": NRCELL_13_id,
        "ue_index": ue_index,
        "duration": NRCELL_13_tput_duration,
        "dl_throughput": NRCELL_13_dl_throughput,
        "ul_throughput": NRCELL_13_ul_throughput,
        "max_deviation": NRCELL_13_max_deviation,
    },
    {
        "attenuator": attenuator,
        "attenuator_ports": attenuator_ports,
        "attenuator_values": LNCEL_202_attenuation_list,
        "apn": LTE_apn,
        "cell_id": LNCEL_202_id,
        "ue_index": ue_index,
        "duration": LNCEL_202_tput_duration,
        "dl_throughput": LNCEL_202_dl_throughput,
        "ul_throughput": LNCEL_202_ul_throughput,
        "max_deviation": LNCEL_202_max_deviation,
    },
    {
        "attenuator": attenuator,
        "attenuator_ports": attenuator_ports,
        "attenuator_values": LNCEL_204_attenuation_list,
        "apn": LTE_apn,
        "cell_id": LNCEL_204_id,
        "ue_index": ue_index,
        "duration": LNCEL_204_tput_duration,
        "dl_throughput": LNCEL_204_dl_throughput,
        "ul_throughput": LNCEL_204_ul_throughput,
        "max_deviation": LNCEL_204_max_deviation,
    }
]
