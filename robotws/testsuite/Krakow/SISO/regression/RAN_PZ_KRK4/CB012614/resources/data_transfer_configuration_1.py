from robot.libraries.BuiltIn import BuiltIn
from testsuite.Krakow.SISO.regression.RAN_PZ_KRK4.CB012614.resources.delta import generate_lte_qrxlevmin_delta

attenuator_0 = BuiltIn().get_variable_value('${tl.attenuator[0]}')
attenuator_1 = BuiltIn().get_variable_value('${tl.attenuator[1]}')

attenuator_0_ports = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
attenuator_1_ports = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]

LNCEL_1_id = "19247105"
LNCEL_1_tput_duration = "300s"
LNCEL_1_dl_throughput = "185 Mbits/sec"
LNCEL_1_ul_throughput = "31 Mbits/sec"
LNCEL_1_max_deviation = "45%"
LNCEL_1_attenuation_0_list = [63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63]
LNCEL_1_attenuation_1_list = [30, 30, 30, 30, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110]
LNCEL_1_delta = generate_lte_qrxlevmin_delta(attach_cell_id=1, number_of_cells=8)

LNCEL_2_id = "19247106"
LNCEL_2_tput_duration = "300s"
LNCEL_2_dl_throughput = "185 Mbits/sec"
LNCEL_2_ul_throughput = "31 Mbits/sec"
LNCEL_2_max_deviation = "45%"
LNCEL_2_attenuation_0_list = [63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63]
LNCEL_2_attenuation_1_list = [30, 30, 30, 30, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110]
LNCEL_2_delta = generate_lte_qrxlevmin_delta(attach_cell_id=2, number_of_cells=8)

LNCEL_3_id = "19247107"
LNCEL_3_tput_duration = "300s"
LNCEL_3_dl_throughput = "185 Mbits/sec"
LNCEL_3_ul_throughput = "31 Mbits/sec"
LNCEL_3_max_deviation = "45%"
LNCEL_3_attenuation_0_list = [63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63]
LNCEL_3_attenuation_1_list = [110, 110, 110, 110, 30, 30, 30, 30, 110, 110, 110, 110, 110, 110, 110, 110]
LNCEL_3_delta = generate_lte_qrxlevmin_delta(attach_cell_id=3, number_of_cells=8)


LNCEL_4_id = "19247108"
LNCEL_4_tput_duration = "300s"
LNCEL_4_dl_throughput = "185 Mbits/sec"
LNCEL_4_ul_throughput = "31 Mbits/sec"
LNCEL_4_max_deviation = "45%"
LNCEL_4_attenuation_0_list = [63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63]
LNCEL_4_attenuation_1_list = [110, 110, 110, 110, 30, 30, 30, 30, 110, 110, 110, 110, 110, 110, 110, 110]
LNCEL_4_delta = generate_lte_qrxlevmin_delta(attach_cell_id=4, number_of_cells=8)

LNCEL_5_id = "19247105"
LNCEL_5_tput_duration = "300s"
LNCEL_5_dl_throughput = "185 Mbits/sec"
LNCEL_5_ul_throughput = "31 Mbits/sec"
LNCEL_5_max_deviation = "45%"
LNCEL_5_attenuation_0_list = [30, 30, 30, 30, 63, 63, 63, 63, 63, 63, 63, 63]
LNCEL_5_attenuation_1_list = [110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110]
LNCEL_5_delta = generate_lte_qrxlevmin_delta(attach_cell_id=5, number_of_cells=8)

LNCEL_6_id = "19247106"
LNCEL_6_tput_duration = "300s"
LNCEL_6_dl_throughput = "185 Mbits/sec"
LNCEL_6_ul_throughput = "31 Mbits/sec"
LNCEL_6_max_deviation = "45%"
LNCEL_6_attenuation_0_list = [30, 30, 30, 30, 63, 63, 63, 63, 63, 63, 63, 63]
LNCEL_6_attenuation_1_list = [110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110]
LNCEL_6_delta = generate_lte_qrxlevmin_delta(attach_cell_id=6, number_of_cells=8)

LNCEL_7_id = "19247107"
LNCEL_7_tput_duration = "300s"
LNCEL_7_dl_throughput = "185 Mbits/sec"
LNCEL_7_ul_throughput = "31 Mbits/sec"
LNCEL_7_max_deviation = "45%"
LNCEL_7_attenuation_0_list = [63, 63, 63, 63, 30, 30, 30, 30, 63, 63, 63, 63]
LNCEL_7_attenuation_1_list = [110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110]
LNCEL_7_delta = generate_lte_qrxlevmin_delta(attach_cell_id=7, number_of_cells=8)

LNCEL_8_id = "19247108"
LNCEL_8_tput_duration = "300s"
LNCEL_8_dl_throughput = "185 Mbits/sec"
LNCEL_8_ul_throughput = "31 Mbits/sec"
LNCEL_8_max_deviation = "45%"
LNCEL_8_attenuation_0_list = [63, 63, 63, 63, 30, 30, 30, 30, 63, 63, 63, 63]
LNCEL_8_attenuation_1_list = [110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110]
LNCEL_8_delta = generate_lte_qrxlevmin_delta(attach_cell_id=8, number_of_cells=8)

data_transfer_configuration_1 = [
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
        "delta": LNCEL_1_delta,
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
        "delta": LNCEL_2_delta,
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
        "delta": LNCEL_3_delta,
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
        "delta": LNCEL_4_delta,
    },
    {
        "attenuators": [
            {
                "attenuator": attenuator_0,
                "attenuator_ports": attenuator_0_ports,
                "attenuator_values": LNCEL_5_attenuation_0_list
            },
            {
                "attenuator": attenuator_1,
                "attenuator_ports": attenuator_1_ports,
                "attenuator_values": LNCEL_5_attenuation_1_list
            }],
        "cell_id": LNCEL_5_id,
        "duration": LNCEL_5_tput_duration,
        "dl_throughput": LNCEL_5_dl_throughput,
        "ul_throughput": LNCEL_5_ul_throughput,
        "max_deviation": LNCEL_5_max_deviation,
        "delta": LNCEL_5_delta,
    },
    {
        "attenuators": [
            {
                "attenuator": attenuator_0,
                "attenuator_ports": attenuator_0_ports,
                "attenuator_values": LNCEL_6_attenuation_0_list
            },
            {
                "attenuator": attenuator_1,
                "attenuator_ports": attenuator_1_ports,
                "attenuator_values": LNCEL_6_attenuation_1_list
            }],
        "cell_id": LNCEL_6_id,
        "duration": LNCEL_6_tput_duration,
        "dl_throughput": LNCEL_6_dl_throughput,
        "ul_throughput": LNCEL_6_ul_throughput,
        "max_deviation": LNCEL_6_max_deviation,
        "delta": LNCEL_6_delta,
    },
    {
        "attenuators": [
            {
                "attenuator": attenuator_0,
                "attenuator_ports": attenuator_0_ports,
                "attenuator_values": LNCEL_7_attenuation_0_list
            },
            {
                "attenuator": attenuator_1,
                "attenuator_ports": attenuator_1_ports,
                "attenuator_values": LNCEL_7_attenuation_1_list
            }],
        "cell_id": LNCEL_7_id,
        "duration": LNCEL_7_tput_duration,
        "dl_throughput": LNCEL_7_dl_throughput,
        "ul_throughput": LNCEL_7_ul_throughput,
        "max_deviation": LNCEL_7_max_deviation,
        "delta": LNCEL_7_delta,
    },
    {
        "attenuators": [
            {
                "attenuator": attenuator_0,
                "attenuator_ports": attenuator_0_ports,
                "attenuator_values": LNCEL_8_attenuation_0_list
            },
            {
                "attenuator": attenuator_1,
                "attenuator_ports": attenuator_1_ports,
                "attenuator_values": LNCEL_8_attenuation_1_list
            }],
        "cell_id": LNCEL_8_id,
        "duration": LNCEL_8_tput_duration,
        "dl_throughput": LNCEL_8_dl_throughput,
        "ul_throughput": LNCEL_8_ul_throughput,
        "max_deviation": LNCEL_8_max_deviation,
        "delta": LNCEL_8_delta,
    },
]
