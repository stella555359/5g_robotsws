from robot.libraries.BuiltIn import BuiltIn

attenuator_0 = BuiltIn().get_variable_value('${tl.attenuator[0]}')
attenuator_1 = BuiltIn().get_variable_value('${tl.attenuator[1]}')

attenuator_0_ports = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
attenuator_1_ports = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]

NRCELL_2_id = "1231814658"
NRCELL_2_tput_duration = "60s"
NRCELL_2_dl_throughput = "270 Mbits/sec"
NRCELL_2_ul_throughput = "30 Mbits/sec"
NRCELL_2_max_deviation = "50%"
NRCELL_2_attenuation_0_list = [63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63]
NRCELL_2_attenuation_1_list = [110, 110, 110, 110, 110, 110, 110, 110,  20, 20, 20, 20, 110, 110, 110, 110]

data_transfer_configuration_4 = [
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
    }
]
