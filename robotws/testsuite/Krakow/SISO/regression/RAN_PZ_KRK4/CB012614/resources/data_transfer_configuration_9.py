from robot.libraries.BuiltIn import BuiltIn

attenuator_0 = BuiltIn().get_variable_value('${tl.attenuator[0]}')
attenuator_1 = BuiltIn().get_variable_value('${tl.attenuator[1]}')

attenuator_0_ports = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
attenuator_1_ports = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]

NRCELL_1_id = "1231814657"
NRCELL_1_tput_duration = "60s"
NRCELL_1_dl_throughput = "1500 Mbits/sec"
NRCELL_1_ul_throughput = "1000 Mbits/sec"
NRCELL_1_max_deviation = "100%"
NRCELL_1_attenuation_0_list = [63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63]
NRCELL_1_attenuation_1_list = [20, 20, 20, 20, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110]

NRCELL_2_id = "1231814658"
NRCELL_2_tput_duration = "60s"
NRCELL_2_dl_throughput = "1500 Mbits/sec"
NRCELL_2_ul_throughput = "1000 Mbits/sec"
NRCELL_2_max_deviation = "100%"
NRCELL_2_attenuation_0_list = [63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63]
NRCELL_2_attenuation_1_list = [110, 110, 110, 110, 20, 20, 20, 20, 110, 110, 110, 110, 110, 110, 110, 110]

NRCELL_3_id = "1231814659"
NRCELL_3_tput_duration = "60s"
NRCELL_3_dl_throughput = "1500 Mbits/sec"
NRCELL_3_ul_throughput = "1000 Mbits/sec"
NRCELL_3_max_deviation = "100%"
NRCELL_3_attenuation_0_list = [63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63]
NRCELL_3_attenuation_1_list = [110, 110, 110, 110, 110, 110, 110, 110,  20, 20, 20, 20, 110, 110, 110, 110]

LNCEL_1_id = "19247105"
LNCEL_1_tput_duration = "60s"
LNCEL_1_dl_throughput = "1500 Mbits/sec"
LNCEL_1_ul_throughput = "1000 Mbits/sec"
LNCEL_1_max_deviation = "100%"
LNCEL_1_attenuation_0_list = [63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63]
LNCEL_1_attenuation_1_list = [110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 20, 20, 20, 20]

LNCEL_2_id = "19247106"
LNCEL_2_tput_duration = "60s"
LNCEL_2_dl_throughput = "1500 Mbits/sec"
LNCEL_2_ul_throughput = "1000 Mbits/sec"
LNCEL_2_max_deviation = "100%"
LNCEL_2_attenuation_0_list = [20, 20, 20, 20, 63, 63, 63, 63, 63, 63, 63, 63]
LNCEL_2_attenuation_1_list = [110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110]

LNCEL_3_id = "19247107"
LNCEL_3_tput_duration = "60s"
LNCEL_3_dl_throughput = "1500 Mbits/sec"
LNCEL_3_ul_throughput = "1000 Mbits/sec"
LNCEL_3_max_deviation = "100%"
LNCEL_3_attenuation_0_list = [63, 63, 63, 63, 20, 20, 20, 20, 63, 63, 63, 63]
LNCEL_3_attenuation_1_list = [110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110]

LNCEL_4_id = "19247108"
LNCEL_4_tput_duration = "60s"
LNCEL_4_dl_throughput = "1500 Mbits/sec"
LNCEL_4_ul_throughput = "1000 Mbits/sec"
LNCEL_4_max_deviation = "100%"
LNCEL_4_attenuation_0_list = [63, 63, 63, 63, 63, 63, 63, 63,  20, 20, 20, 20]
LNCEL_4_attenuation_1_list = [110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110]

data_transfer_configuration_9 = [
    {
        "attenuators": [
            {
                "attenuator": attenuator_0,
                "attenuator_ports": attenuator_0_ports,
                "attenuator_values": NRCELL_1_attenuation_0_list
            },
            {
                "attenuator": attenuator_1,
                "attenuator_ports": attenuator_1_ports,
                "attenuator_values": NRCELL_1_attenuation_1_list
            }],
        "cell_id": NRCELL_1_id,
        "duration": NRCELL_1_tput_duration,
        "dl_throughput": NRCELL_1_dl_throughput,
        "ul_throughput": NRCELL_1_ul_throughput,
        "max_deviation": NRCELL_1_max_deviation,
        "delta": None,
    },
    {
        "attenuators": [
            {
                "attenuator": attenuator_0,
                "attenuator_ports": attenuator_0_ports,
                "attenuator_values": NRCELL_2_attenuation_0_list
            },
            {
                "attenuator": attenuator_1,
                "attenuator_ports": attenuator_1_ports,
                "attenuator_values": NRCELL_2_attenuation_1_list
            }],
        "cell_id": NRCELL_2_id,
        "duration": NRCELL_2_tput_duration,
        "dl_throughput": NRCELL_2_dl_throughput,
        "ul_throughput": NRCELL_2_ul_throughput,
        "max_deviation": NRCELL_2_max_deviation,
        "delta": None,
    },
    {
        "attenuators": [
            {
                "attenuator": attenuator_0,
                "attenuator_ports": attenuator_0_ports,
                "attenuator_values": NRCELL_3_attenuation_0_list
            },
            {
                "attenuator": attenuator_1,
                "attenuator_ports": attenuator_1_ports,
                "attenuator_values": NRCELL_3_attenuation_1_list
            }],
        "cell_id": NRCELL_3_id,
        "duration": NRCELL_3_tput_duration,
        "dl_throughput": NRCELL_3_dl_throughput,
        "ul_throughput": NRCELL_3_ul_throughput,
        "max_deviation": NRCELL_3_max_deviation,
        "delta": None,
    },
    {
        "attenuators": [
            {
                "attenuator": attenuator_0,
                "attenuator_ports": attenuator_0_ports,
                "attenuator_values": LNCEL_1_attenuation_0_list
            },
            {
                "attenuator": attenuator_1,
                "attenuator_ports": attenuator_1_ports,
                "attenuator_values": LNCEL_1_attenuation_1_list
            }],
        "cell_id": LNCEL_1_id,
        "duration": LNCEL_1_tput_duration,
        "dl_throughput": LNCEL_1_dl_throughput,
        "ul_throughput": LNCEL_1_ul_throughput,
        "max_deviation": LNCEL_1_max_deviation,
        "delta": None,
    },
    {
        "attenuators": [
            {
                "attenuator": attenuator_0,
                "attenuator_ports": attenuator_0_ports,
                "attenuator_values": LNCEL_2_attenuation_0_list
            },
            {
                "attenuator": attenuator_1,
                "attenuator_ports": attenuator_1_ports,
                "attenuator_values": LNCEL_2_attenuation_1_list
            }],
        "cell_id": LNCEL_2_id,
        "duration": LNCEL_2_tput_duration,
        "dl_throughput": LNCEL_2_dl_throughput,
        "ul_throughput": LNCEL_2_ul_throughput,
        "max_deviation": LNCEL_2_max_deviation,
        "delta": None,
    },
    {
        "attenuators": [
            {
                "attenuator": attenuator_0,
                "attenuator_ports": attenuator_0_ports,
                "attenuator_values": LNCEL_3_attenuation_0_list
            },
            {
                "attenuator": attenuator_1,
                "attenuator_ports": attenuator_1_ports,
                "attenuator_values": LNCEL_3_attenuation_1_list
            }],
        "cell_id": LNCEL_3_id,
        "duration": LNCEL_3_tput_duration,
        "dl_throughput": LNCEL_3_dl_throughput,
        "ul_throughput": LNCEL_3_ul_throughput,
        "max_deviation": LNCEL_3_max_deviation,
        "delta": None,
    },
    {
        "attenuators": [
            {
                "attenuator": attenuator_0,
                "attenuator_ports": attenuator_0_ports,
                "attenuator_values": LNCEL_4_attenuation_0_list
            },
            {
                "attenuator": attenuator_1,
                "attenuator_ports": attenuator_1_ports,
                "attenuator_values": LNCEL_4_attenuation_1_list
            }],
        "cell_id": LNCEL_4_id,
        "duration": LNCEL_4_tput_duration,
        "dl_throughput": LNCEL_4_dl_throughput,
        "ul_throughput": LNCEL_4_ul_throughput,
        "max_deviation": LNCEL_4_max_deviation,
        "delta": None,
    },
]
