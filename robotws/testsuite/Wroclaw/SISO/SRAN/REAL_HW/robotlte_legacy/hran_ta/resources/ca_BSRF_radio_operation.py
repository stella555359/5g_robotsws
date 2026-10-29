"""
:modified:16.08.2022

:author: Mateusz Kawka
:maintainer: Mateusz Kawka
:contact: mateusz.kawka@nokia.com
"""
from robot.api.deco import keyword
from robot.api import logger
from tabulate import tabulate
from collections import OrderedDict
import re
import paramiko
import warnings

warnings.filterwarnings(action="ignore", message="unclosed")

ROBOT_AUTO_KEYWORDS = False

AIRSCALE_MODULES = ['ASIA', 'ASIB', 'ASIL', 'ASIM']

RADIO_MODULES = {
    '5_1_4T4R_1NAHKA_1BAND': ['AHEB', 'AHED', 'AHCF', 'AHIB', 'AHGB', 'AHPB'],
    '5_1_6T6R_2NAHKA_1BAND': ['ARDA', 'ARCA', 'ARDB', 'ARGA', 'AREA'],
    '5_1_4T4R_2NAHKA_2BAND': ['AHPDA', 'AHFIG', 'AHLOA', 'AHPCA', 'AHFIB', 'AHBCC', 'AHEGB', 'AHEGC', 'AHLBA', 'AHBCA'],
    '5_1_2T4R_1NAHKA_1BAND': ['AHEC', 'AHDB'],
    '5_1_2T4R_1NAHKA_2BAND': ['AHEGA'],
    '5_1_2T4R_1NAHKA_3BAND': ['AHPCDB'],
    '5_1_4T4R_1NAHKA_3BAND': ['AHPMDA'],
    '6_1_8T8R_2MADE_1BAND': ['AZQP', 'AZHL'],
    '6_2_4T4R_1MADE_2BAND': ['AHFII']
}

ANTENNA_MAPPING = {
    '5_1_4T4R_1NAHKA_1BAND': {'TX': [1, 2, 3, 4], 'RX': [1, 2, 3, 4]},
    '5_1_6T6R_2NAHKA_1BAND': {'TX': ([1, 2, 3, 4], [5, 6]), 'RX': ([1, 2, 3, 4], [5, 6])},
    '5_1_4T4R_2NAHKA_2BAND': {'TX': ([1, 2], [3, 4]), 'RX': ([1, 2], [3, 4])},
    '5_1_2T4R_1NAHKA_1BAND': {'TX': [1, 3], 'RX': [1, 2, 3, 4]},
    '5_1_2T4R_1NAHKA_2BAND': {'TX': [1, 3], 'RX': [1, 2, 3, 4]},
    '5_1_2T4R_1NAHKA_3BAND': {'TX': [1, 3], 'RX': [1, 2, 3, 4]},
    '5_1_4T4R_1NAHKA_3BAND': {'TX': [1, 2, 3, 4], 'RX': [1, 2, 3, 4]},
    '6_1_8T8R_2MADE_1BAND': {'TX': ([1, 2, 3, 4], [5, 6, 7, 8]), 'RX': ([1, 2, 3, 4], [5, 6, 7, 8])},
    '6_2_4T4R_1MADE_2BAND': {'TX': [1, 2, 3, 4], 'RX': [1, 2, 3, 4]}
}

CUSTOM_MAPPING = {
    'AHPMDA': {'TXRX': {'FRMON':
                        {'1NAHKA': {'ant1': [1, 2], 'ant2': [3], 'ant3': [4, 5], 'ant4': [6]}},
                        'DAPD':
                        {'1NAHKA': {'ant1': ['1a', '1b'], 'ant2': ['2a'], 'ant3': ['3a', '3b'], 'ant4': ['4a']}}}}}

hostname = '192.168.255.1'
username = 'toor4nsn'
password = 'oZPS0POrRieRtu'

RMOD_PASSWORDS = {'AZQP': ['rfsw', '5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ='],
                  'AHFII': ['rfsw', '0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA='],
                  'AEHC': ['rfsw', 'bdS%ztWG3v7%SjreCVA79wTPb'],
                  'AAFB': [username, password],
                  'AAIB': [username, password]}


@keyword(name='Get Antenna Lines For RU')
def get_antenna_lines_for_ru(product_name, direction, type_of_ant='physical'):
    """
    Get Antenna Lines For RU

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    .. warning::
    Supported radio types are:
    Radio5.1, Radio6.1 (Scorpio) and Radio6.2 (Zodiac) added to RADIO_MODULES and ANTENNA_MAPPING

    | **Full description:**

    KW returns antenna mapping for given product name and direction.
    Product name must be declared in RADIO_MODULES.
    Direction is TX or RX.
    Type of antenna lines:
    -> physical - returns antenna lines from ANTENNA_MAPPING without conversion, e.g. TXs AHFIG
    Dictionary: ([1, 2], [3, 4])
    Return: {'1NAHKA': [1, 2], '2NAHKA': [3, 4]}
    -> virtual - returns converted antenna lines for DAPD, e.g. TXs ARGA:
    Dictionary: ([1, 2, 3, 4], [5, 6])
    Return: {'1NAHKA': [1a, 2a, 3a, 4a], '2NAHKA': [5a, 6a]}
    -> frmon - returns converted antenna lines for FRMON, e.g. TXs AHPCDB
    Dictionary: [1, 3]
    Return: {'1NAHKA': [1,2,3,7,8,9]}

    **Input Parameters:**

    +------------------+------+---------------------------------------+
    | Input Parameters | Man. | Description                           |
    +==================+======+=======================================+
    | product_name     | Yes  | RU product name                       |
    +------------------+------+---------------------------------------+
    | direction        | Yes  | TX or RX                              |
    +------------------+------+---------------------------------------+
    | type_of_ant      | Yes  | physical, virtual or frmon            |
    +------------------+------+---------------------------------------+

    **Example:**

    .. code-block:: robotframework

    ${tx_ant_lines}=  Get Antenna Lines For RU  AZQP  TX  virtual

    | **Return value:**
    | Dictionary with tx or rx antenna lines.
    """

    mapping = None
    ru_group = None
    ant_mapping = {}

    direction = direction.upper()
    if type_of_ant not in ['physical', 'virtual', 'frmon']:
        raise ValueError("Unknown argument type_of_ant={0}".format(type_of_ant))

    if (product_name in CUSTOM_MAPPING) and (type_of_ant == 'frmon' or type_of_ant == 'virtual'):
        return get_custom_antenna_mapping(product_name, type_of_ant, direction)

    for ru_class, ru_list in RADIO_MODULES.items():
        if product_name in ru_list:
            ru_group = ru_class
            txrx_mapping = ANTENNA_MAPPING[ru_group]
            if direction == 'TX':
                mapping = txrx_mapping['TX']
            elif direction == 'RX':
                mapping = txrx_mapping['RX']

    if mapping:
        print("Found mapping for {0}s {1} -> {2}".format(direction, product_name, mapping))
    else:
        raise ValueError("Unsupported Radio Unit -> {0}\nAdd new Radio Unit to RADIO_MODULES and ANTENNA_MAPPING"
                         .format(product_name))

    if type_of_ant == 'frmon':
        if '1NAHKA' in ru_group or '1MADE' in ru_group:
            mapping = frmon_get_virtual_antenna_lines_for_ru(ru_group, mapping)
        elif '2MADE' in ru_group or '2NAHKA' in ru_group:
            mapping_1_soc = frmon_get_virtual_antenna_lines_for_ru(ru_group, mapping[0])
            mapping_2_soc = frmon_get_virtual_antenna_lines_for_ru(ru_group, mapping[1])
            mapping = (mapping_1_soc, mapping_2_soc)
    elif type_of_ant == 'virtual':
        if '1NAHKA' in ru_group or '1MADE' in ru_group:
            mapping = dapd_get_virtual_antenna_lines_for_ru(ru_group, mapping)
        elif '2MADE' in ru_group or '2NAHKA' in ru_group:
            mapping_1_soc = dapd_get_virtual_antenna_lines_for_ru(ru_group, mapping[0])
            mapping_2_soc = dapd_get_virtual_antenna_lines_for_ru(ru_group, mapping[1])
            mapping = (mapping_1_soc, mapping_2_soc)

    if '2NAHKA' in ru_group:
        print("2NAHKA")
        ant_mapping['1NAHKA'] = mapping[0]
        ant_mapping['2NAHKA'] = mapping[1]
    elif '2MADE' in ru_group:
        ant_mapping['1MADE'] = mapping[0]
        ant_mapping['2MADE'] = mapping[1]
    elif '1NAHKA' in ru_group:
        ant_mapping['1NAHKA'] = mapping
    elif '1MADE' in ru_group:
        ant_mapping['1MADE'] = mapping
    else:
        ant_mapping = mapping

    print(ant_mapping)
    return ant_mapping


@keyword(name='Get RU Family')
def get_ru_family(product_name):
    """
    Get RU family

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    .. warning::
    Supported radio types are:
    Radio5.1, Radio6.1 (Scorpio) and Radio6.2 (Zodiac) added to RADIO_MODULES and ANTENNA_MAPPING

    | **Full description:**

    **Input Parameters:**

    +------------------+------+---------------------------------------+
    | Input Parameters | Man. | Description                           |
    +==================+======+=======================================+
    | product_name     | Yes  | RU product name                       |
    +------------------+------+---------------------------------------+

    **Example:**

    .. code-block:: robotframework

    ${tx_ant_lines}=  Get RU Family  AZQP

    | **Return value:**
    | String with name of RU family.
    """

    ru_family = ([k for k, v in RADIO_MODULES.items() if product_name in v])[0][0:3].replace('_', '.')

    return ru_family


@keyword(name='Get Bands Number')
def get_bands_number(product_name):
    """
    Get Band Number

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    .. warning::
    Supported radio types are:
    Radio5.1, Radio6.1 (Scorpio) and Radio6.2 (Zodiac) added to RADIO_MODULES and ANTENNA_MAPPING

    | **Full description:**

    **Input Parameters:**

    +------------------+------+---------------------------------------+
    | Input Parameters | Man. | Description                           |
    +==================+======+=======================================+
    | product_name     | Yes  | RU product name                       |
    +------------------+------+---------------------------------------+

    **Example:**

    .. code-block:: robotframework

    ${bands_number}=  Get Bands Number  AZQP

    | **Return value:**
    | String with number of bands.
    """

    ru_class = next((ru_class for ru_class, ru_list in RADIO_MODULES.items() if product_name in ru_list), None)
    ru_group_split = ru_class.split('_')
    band_number = re.findall(r'\d+', ru_group_split[-1])[0]

    return band_number


@keyword(name='DAPD Print Tx Power Table')
def dapd_print_tx_power_table(power_dict, product_name, radio_ip):
    """
    DAPD Print Tx Power Table

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    .. warning::
    Supported radio types are:
    Radio5.1, Radio6.1 (Scorpio) and Radio6.2 (Zodiac) added to RADIO_MODULES and ANTENNA_MAPPING

    | **Full description:**
    KW for print table with TX power measured in DAPD.
    Power is printed per antenna line.
    In case of power per carrier check "Print Carriers Power Table"

    **Input Parameters:**

    +------------------+------+---------------------------------------+
    | Input Parameters | Man. | Description                           |
    +==================+======+=======================================+
    | power_dict       | Yes  | Dictionary with power                 |
    +------------------+------+---------------------------------------+
    | product_name     | Yes  | RU product name                       |
    +------------------+------+---------------------------------------+
    | radio_ip         | Yes  | IP address for RU (only for print )   |
    +------------------+------+---------------------------------------+

    **Example:**

    .. code-block:: robotframework

    DAPD Print TX Power Table  ${dict_with_power}  AHFIG  172.16.9.130

    """

    values_count = len([x for x in power_dict.values() if x != 'OFF'])
    if values_count != 0:
        new_tb = tabulate(power_dict.items(), headers=["TX", "Power"], tablefmt="fancy_grid")
        logger.info(new_tb, also_console=True)
    else:
        logger.info("No power on any TX antenna line for {}, radio ip: {}".
                    format(product_name, radio_ip), also_console=True)


def dapd_get_virtual_antenna_lines_for_ru(ru_group, ant_mapping):
    """
    def returns virtual antenna mapping for dapd

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com
    """

    band = ru_group.split('_')[-1]
    band = re.findall(r'\d+', band)[0]
    print("Number of bands for RU: {0}".format(band))

    virtual_ant_mapping = []
    for ant in ant_mapping:
        if band == '1':
            ant = str(ant) + 'a'
            virtual_ant_mapping.append(ant)
        elif band == '2':
            ant1 = str(ant) + 'a'
            ant2 = str(ant) + 'b'
            virtual_ant_mapping.extend([ant1, ant2])
        elif band == '3':
            ant1 = str(ant) + 'a'
            ant2 = str(ant) + 'b'
            ant3 = str(ant) + 'c'
            virtual_ant_mapping.extend([ant1, ant2, ant3])

    print("Virtual mapping for DAPD:{0}".format(virtual_ant_mapping))
    return virtual_ant_mapping


@keyword(name='FRMON Print Carriers Data Table')
def frmon_print_carriers_data_table(carrier_dict):
    """
    FRMON Print Carriers Data Table

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    .. warning::
    Supported radio types are:
    Radio5.1, Radio6.1 (Scorpio) and Radio6.2 (Zodiac) added to RADIO_MODULES and ANTENNA_MAPPING

    | **Full description:**
    KW for print table with TX or RX carriers data returned from frmon.
    Data is printed per carriers.

    **Input Parameters:**

    +------------------+------+---------------------------------------+
    | Input Parameters | Man. | Description                           |
    +==================+======+=======================================+
    | carriers_dict    | Yes  | Dictionary with carriers data         |
    +------------------+------+---------------------------------------+


    **Example:**

    .. code-block:: robotframework

    FRMON Print Carriers Data Table  ${dict_with_carriers_data}

    """
    flat_carriers_dict = {}
    for k, v in carrier_dict.items():
        for carrier, data in v.items():
            flat_carriers_dict[carrier] = data

    d = OrderedDict(sorted(flat_carriers_dict.items()))
    print(d)

    new_tb = tabulate(d.items(), headers=["Carrier", "Data"], tablefmt="fancy_grid")
    logger.info(new_tb, also_console=True)


@keyword(name='FRMON Print Carriers Power Table')
def frmon_print_carriers_power_table(power_dict, product_name, radio_ip, direction):
    """
    FRMON Print Carriers Power Table

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    .. warning::
    Supported radio types are: Radio5.1 and Radio6.1 added to dictionaries

    | **Full description:**
    KW for print table with TX or RX carriers power measured in frmon.
    Power is printed per carriers.

    **Input Parameters:**

    +------------------+------+---------------------------------------+
    | Input Parameters | Man. | Description                           |
    +==================+======+=======================================+
    | power_dict       | Yes  | Dictionary with power                 |
    +------------------+------+---------------------------------------+
    | product_name     | Yes  | RU product name                       |
    +------------------+------+---------------------------------------+
    | radio_ip         | Yes  | IP address for RU (only for print )   |
    +------------------+------+---------------------------------------+
    | direction        | Yes  | TX or RX                              |
    +------------------+------+---------------------------------------+

    **Example:**

    .. code-block:: robotframework

    FRMON Print Carriers Power Table  ${dict_with_power}  AHFIG  172.16.9.130  TX
    """
    direction = direction.upper()
    flat_carriers_dict = {}
    for k, v in power_dict.items():
        for carrier, power in v.items():
            flat_carriers_dict[carrier] = power

    d = OrderedDict(sorted(flat_carriers_dict.items()))
    print(d)

    values_count = len([x for x in d.values() if x != 'OFF'])
    if values_count != 0:
        new_tb = tabulate(d.items(),
                          headers=[direction + " carrier", "Power"], tablefmt="fancy_grid")
        logger.info(new_tb, also_console=True)
    else:
        logger.info("No power on any {0} carrier for {1}, radio ip: {2}".
                    format(direction, product_name, radio_ip), also_console=True)


@keyword(name='FRMON Convert To Physical Antennas')
def frmon_convert_to_physical_antennas(power_dictionary, product_name, direction):
    """
    FRMON Convert To Physical Antennas

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    .. warning::
    Supported radio types are: Radio5.1 and Radio6.1 added to dictionaries

    | **Full description:**
    KW for convert dictionary with carriers power/data in FRMON mapping
    to physical antenna lines.

    **Input Parameters:**

    +------------------+------+---------------------------------------+
    | Input Parameters | Man. | Description                           |
    +==================+======+=======================================+
    | power_dict       | Yes  | Dictionary with power from FRMON      |
    +------------------+------+---------------------------------------+
    | product_name     | Yes  | RU product name                       |
    +------------------+------+---------------------------------------+
    | direction        | Yes  | TX or RX                              |
    +------------------+------+---------------------------------------+

    **Example:**

    .. code-block:: robotframework

    FRMON Convert To Physical Antennas  ${dict_with_power}  172.16.9.130  TX
    """
    direction = direction.upper()
    band_number = int(get_bands_number(product_name))
    mapping = None

    if product_name in CUSTOM_MAPPING:
        return frmon_custom_convert_to_physical_antennas(power_dictionary, product_name, direction)

    for ru_class, ru_list in RADIO_MODULES.items():
        if product_name in ru_list:
            ru_group = ru_class
            txrx_mapping = ANTENNA_MAPPING[ru_group]
            if direction == 'TX':
                mapping = txrx_mapping['TX']
            elif direction == 'RX':
                mapping = txrx_mapping['RX']
            else:
                raise ValueError("Unsupported direction: {0}".format(direction))

    if isinstance(mapping, tuple):
        mapping = [item for sublist in mapping for item in sublist]

    temp_dict = dict.fromkeys(mapping)
    final_dict = {}
    band_delta = int(band_number) - 1

    for k in temp_dict.keys():
        first_tx_for_ant = (k * int(band_number)) - band_delta
        last_tx_for_ant = k * int(band_number)
        temp_list = []
        for i in range(first_tx_for_ant, last_tx_for_ant + 1):
            temp_list.append(power_dictionary['ant' + str(i)])
            flat_dict = {k: v for d in temp_list for k, v in d.items()}
            final_dict['ant' + str(k)] = flat_dict

    print(final_dict)
    return final_dict


@keyword(name='FRMON Get Carriers List')
def frmon_get_carriers_list(cmd_output):
    """
    FRMON Get Carriers List

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    .. warning::
    Supported radio types are: Radio5.1 and Radio6.1 added to dictionaries

    | **Full description:**
    KW for extract carriers name list from frmon output.
    FRMON command to get output e.g.:

    1) $'/ant1_ru get tx_carrier_ids' | frmonShellClient localhost 2000
    2) $'/ant1_ru get rx_carrier_ids' | frmonShellClient localhost 2000

    Above commands return all tx/rx carriers on virtual antenna lines

    **Input Parameters:**

    +------------------+------+---------------------------------------+
    | Input Parameters | Man. | Description                           |
    +==================+======+=======================================+
    | cmd_output       | Yes  | Output from FRMON command             |
    +------------------+------+---------------------------------------+

    **Example:**

    .. code-block:: robotframework

    FRMON Get Carriers List   ${cmd_output}
    """
    carriers_list = re.findall(r'(?<=")\S*(?=")', cmd_output)
    carriers_list = [carrier for carrier in carriers_list if carrier.startswith(("N", "L", "W", "G"))]

    print(carriers_list)
    return carriers_list


@keyword(name='FRMON Get Carriers Data Dictionary')
def frmon_get_carriers_data_dictionary(cmd_output, data_dict):
    """
    FRMON Get Carriers Data Dictionary

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    .. warning::
    Supported radio types are: Radio5.1 and Radio6.1 added to dictionaries

    | **Full description:**
    KW for extract carriers data from frmon output.
    KW returns dictionary where antenna is key, carriers with data is value.
    FRMON command to get output e.g.:

    1) $'/ant1_ru action read_config' | frmonShellClient localhost 2000

    Above command return power for all carriers on virtual antenna lines

    **Input Parameters:**

    +------------------+------+---------------------------------------+
    | Input Parameters | Man. | Description                           |
    +==================+======+=======================================+
    | cmd_output       | Yes  | Output from FRMON command             |
    +------------------+------+---------------------------------------+
    | data_dict       | Yes  | Dictionary to set carriers power      |
    +------------------+------+---------------------------------------+

    **Example:**

    .. code-block:: robotframework

    FRMON Get Carriers Data Dictionary   ${cmd_output}  ${data_dict}
    """
    cmd_output = cmd_output.splitlines()
    cmd_output = [i for i in cmd_output if i.startswith('ret')]
    for line in cmd_output:
        print(line)
        antenna = re.findall(r'ant\d+', line)[0]
        carrier = re.findall(r'(?<=")\S*(?=")', line)[0]
        data_dict[antenna][carrier] = {}
        try:
            cell_type = re.findall(r'(?<=read_config )".*"', line)[0][1]
            if cell_type == 'N':
                cell_type = 'NR'
            elif cell_type == 'L':
                cell_type = 'LTE'
            elif cell_type == 'W':
                cell_type = 'WCDMA'
            else:
                cell_type = 'GSM'
        except Exception:
            cell_type = 'N/A'
        try:
            frequency = re.findall(r'(?<=FREQUENCY )\d+', line)[0]
            frequency = float(frequency) / 1000
            print(frequency)
        except Exception:
            frequency = 'N/A'
        try:
            bandwidth = re.findall(r'(?<=BANDWIDTH )\d+', line)[0]
        except Exception:
            bandwidth = 'N/A'
        try:
            state = re.findall(r'(?<=STATE )\w+', line)[0]
        except Exception:
            state = 'N/A'

        data_dict[antenna][carrier]['bandwidth'] = bandwidth
        data_dict[antenna][carrier]['frequency'] = frequency
        data_dict[antenna][carrier]['type'] = cell_type
        data_dict[antenna][carrier]['state'] = state

    for i in data_dict.items():
        print(i)

    return data_dict


@keyword(name='FRMON Get Carriers Power Dictionary')
def frmon_get_carriers_power_dictionary(cmd_output, power_dict):
    """
    FRMON Get Carriers Power Dictionary

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    .. warning::
    Supported radio types are: Radio5.1 and Radio6.1 added to dictionaries

    | **Full description:**
    KW for extract carriers power from frmon output.
    KW returns dictionary where carriers is key, power is value.
    FRMON command to get output e.g.:

    1) $'/ant1_ru action measure_power' | frmonShellClient localhost 2000

    Above command return power for all carriers on virtual antenna lines

    **Input Parameters:**

    +------------------+------+---------------------------------------+
    | Input Parameters | Man. | Description                           |
    +==================+======+=======================================+
    | cmd_output       | Yes  | Output from FRMON command             |
    +------------------+------+---------------------------------------+
    | power_dict       | Yes  | Dictionary to set carriers power      |
    +------------------+------+---------------------------------------+

    **Example:**

    .. code-block:: robotframework

    FRMON Get Carriers Power Dictionary   ${cmd_output}  ${carriers_list}
    """

    cmd_output = cmd_output.splitlines()
    cmd_output = [i for i in cmd_output if i.startswith('ret')]
    for line in cmd_output:
        print(line)
        antenna = re.findall(r'ant\d+', line)[0]
        carrier = re.findall(r'(?<=")\S*(?=")', line)[0]
        try:
            power = float(re.findall(r'[-]?\d+[.]\d+', line)[0])
        except Exception:
            power = 'OFF'

        power_dict[antenna][carrier] = power

    for i in power_dict.items():
        print(i)

    return power_dict


@keyword(name='FRMON Set Carriers Map Command')
def frmon_set_carriers_map_command(list_of_ants, direction):
    """
    FRMON Set Carriers Map Command

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    .. warning::
    Supported radio types are: Radio5.1 and Radio6.1 added to dictionaries

    | **Full description:**
    KW creates command for frmon
    Command contains creating AntennaPath and getting tx or rx carriers ids for AntennaPath
    KW returns string with command

    **Input Parameters:**

    +------------------+------+---------------------------------------+
    | Input Parameters | Man. | Description                           |
    +==================+======+=======================================+
    | list_of_ants     | Yes  | List of RU antenna lines              |
    +------------------+------+---------------------------------------+
    | direction        | Yes  | Tx or Rx                              |
    +------------------+------+---------------------------------------+

    **Example:**

    .. code-block:: robotframework

    FRMON Set Carriers Map Command   [1,2,3,4]  TX
    """
    first_ant_num = list_of_ants[0]
    last_ant_num = list_of_ants[-1]

    cmd_a = [
        "/ action create AntennaPath /ant{num}_radio_operation /rf/ant{num}".format(num=num)
        for num in range(first_ant_num, last_ant_num + 1)
    ]
    cmd_b = [
        "/ant{num}_radio_operation get {trx}_carrier_ids".format(num=num, trx=direction)
        for num in range(first_ant_num, last_ant_num + 1)
    ]

    logger.debug(cmd_a, cmd_b)
    return "\n".join(cmd_a + cmd_b)


@keyword(name='FRMON Set Carriers Power Command')
def frmon_set_carriers_power_command(raw_output):
    """
    FRMON Set Carriers Power Command

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    .. warning::
    Supported radio types are: Radio5.1 and Radio6.1 added to dictionaries

    | **Full description:**
    KW creates command for frmon
    Command contains creating action measure_power for carriers from output
    KW returns string with command

    **Input Parameters:**

    +------------------+------+-------------------------------------------------------------+
    | Input Parameters | Man. | Description                                                 |
    +==================+======+=============================================================+
    | raw_output       | Yes  | Output from creating AntennaPath and getting carriers ids   |
    +------------------+------+-------------------------------------------------------------+

    **Example:**

    .. code-block:: robotframework

    FRMON Set Carriers Power Command   ${raw_output}
    """

    otp = raw_output.splitlines()

    carrier_with_power = list(filter(lambda x: '.TX' in x or '.RX' in x, otp))

    cmds_list = []
    for i in carrier_with_power:
        ant = re.findall(r'ant\d+', i)[0]
        print(i)
        print(ant)
        carriers = frmon_get_carriers_list(i)
        for carrier in carriers:
            cmd = '/{ant}_radio_operation action measure_power "{carrier}"'.format(ant=ant, carrier=carrier)
            cmds_list.append(cmd)

    logger.debug(cmds_list)
    return "\n".join(cmds_list)


@keyword(name='FRMON Set Carriers Data Command')
def frmon_set_carriers_data_command(raw_output):
    """
    FRMON Set Carriers Data Command

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    .. warning::
    Supported radio types are: Radio5.1 and Radio6.1 added to dictionaries

    | **Full description:**
    KW creates command for frmon
    Command contains creating action read_config for carriers from output
    KW returns string with command

    **Input Parameters:**

    +------------------+------+-------------------------------------------------------------+
    | Input Parameters | Man. | Description                                                 |
    +==================+======+=============================================================+
    | raw_output       | Yes  | Output from creating AntennaPath and getting carriers ids   |
    +------------------+------+-------------------------------------------------------------+

    **Example:**

    .. code-block:: robotframework

    FRMON Set Carriers Data Command   ${raw_output}
    """

    otp = raw_output.splitlines()

    carrier_with_power = list(filter(lambda x: '.TX' in x or '.RX' in x, otp))

    cmds_list = []
    for i in carrier_with_power:
        ant = re.findall(r'ant\d+', i)[0]
        print(i)
        print(ant)
        carriers = frmon_get_carriers_list(i)
        for carrier in carriers:
            cmd = '/{ant}_radio_operation action read_config "{carrier}"'.format(ant=ant, carrier=carrier)
            cmds_list.append(cmd)

    logger.debug(cmds_list)
    return "\n".join(cmds_list)


def frmon_get_virtual_antenna_lines_for_ru(ru_group, ant_mapping):
    ru_group_split = ru_group.split('_')
    band = re.findall(r'\d+', ru_group_split[-1])[0]
    print("Antenna mapping from global RU dict: {0}".format(ant_mapping))
    band_delta = int(band) - 1

    virtual_numeric_ant_mapping = []
    for ant in ant_mapping:
        first_tx_for_ant = (ant * int(band)) - band_delta
        last_tx_for_ant = ant * int(band)
        for i in range(first_tx_for_ant, last_tx_for_ant + 1):
            virtual_numeric_ant_mapping.append(i)

    print("Numeric mapping for FRMON:{0}".format(virtual_numeric_ant_mapping))
    return virtual_numeric_ant_mapping


def frmon_custom_convert_to_physical_antennas(power_dictionary, product_name, direction):
    """
     def returns converted dict for custom antenna mapping RUs to physical antennas

     | **Author:** mateusz.kawka@nokia.com
     | **Maintainers:** mateusz.kawka@nokia.com
     """
    converted_dict = {}
    print("Custom {0} mapping for {1}".format(direction, product_name))
    ru_mapping = CUSTOM_MAPPING.get(product_name)
    for direct, mapping in ru_mapping.items():
        if direction in direct:
            ru_mapping = mapping.get('FRMON')
            for soc, ant_maps in ru_mapping.items():
                for ant, virtual_ant in ant_maps.items():
                    converted_dict[ant] = {}
                    for v_ant in virtual_ant:
                        carrier_power = power_dictionary.get('ant' + str(v_ant))
                        try:
                            carrier = carrier_power.keys()[0]
                            power = carrier_power.values()[0]
                            converted_dict[ant][carrier] = power
                        except IndexError:
                            pass

    print(converted_dict)
    return converted_dict


def get_custom_antenna_mapping(product_name, type_of_ant, direction):
    """
     def returns custom antenna mapping

     | **Author:** mateusz.kawka@nokia.com
     | **Maintainers:** mateusz.kawka@nokia.com
     """
    ru_mapping = CUSTOM_MAPPING.get(product_name)
    for direct, mapping in ru_mapping.items():
        if direction in direct:
            if type_of_ant.lower() == 'frmon':
                ru_mapping = mapping.get('FRMON')
            else:
                ru_mapping = mapping.get('DAPD')
        else:
            raise ValueError("CUSTOM_MAPPING doesn't contain {0} carriers mapping !".format(direction))

    temp_dict = {}
    for nahka, mapping in ru_mapping.items():
        maps = list(mapping.values())
        maps = [item for sublist in maps for item in sublist]
        temp_dict[nahka] = maps

    print(temp_dict)
    return temp_dict


@keyword(name='Get RU IPs')
def get_ru_ips(print_table=True):
    """
    Get RU IPs

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    | **Full description:**
    KW for getting dictionary with RU IPs
    KW returns dictionary where main key is 192.168.255.1 and 192.168.255.7.
    Keys contains nested dictionaries as values with RU serial number and IP.

    **Input Parameters:**

    +------------------+------+------------------------------------------------+
    | Input Parameters | Man. | Description                                    |
    +==================+======+================================================+
    | print_table      | No   | Print table with IPs to console, default True  |
    +------------------+------+------------------------------------------------+

    **Example:**

    .. code-block:: robotframework

    Get RU IPs  print_table=False
    """

    frips_command = 'cat /rom/config/FRIps.txt'

    rmod_ips = {'192.168.255.1': {},
                '192.168.255.7': {}}

    ssh = ssh_connect_to_enb()

    stdin, stdout, stderr = ssh.exec_command(frips_command)
    frips_output_1 = stdout.readlines()

    for rmod in frips_output_1:
        serial_number = rmod.split(';')[3]
        ip = rmod.split(';')[2]
        if ip != '0.0.0.0':
            rmod_ips[hostname][serial_number] = ip

    hostname_2 = set_second_core_hostname(ssh)
    second_host_ping_rc = get_ping_status_for_second_core(ssh, hostname_2)

    if second_host_ping_rc is 0:
        print("Found host on {0} !".format(hostname_2))
        ssh_2 = set_ssh_tunnel_to_second_core(ssh, hostname, hostname_2)
        stdin, stdout, stderr = ssh_2.exec_command(frips_command)
        frips_output_2 = stdout.readlines()

        for rmod in frips_output_2:
            serial_number = rmod.split(';')[3]
            ip = rmod.split(';')[2]
            if ip != '0.0.0.0':
                rmod_ips['192.168.255.7'][serial_number] = ip
    else:
        print("Not found host on {0}".format(hostname_2))

    for smod, ips_dict in zip(rmod_ips.keys(), rmod_ips.values()):
        new_tb = tabulate(ips_dict.items(),
                          headers=[smod + "\n\nSerial number", "\n\nIP"], tablefmt="fancy_grid")
        logger.info(new_tb, also_console=print_table)

    ssh.close()

    try:
        ssh_2.close()
    except Exception:
        print("No ssh channel to {0} to close !".format(hostname_2))

    return rmod_ips


@keyword(name='Get Software Version From ENB')
def get_software_version_from_enb():
    """
    Get Software Version From Enb

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    | **Full description:**
    KW for getting active software release from Enb
    KW returns string with software release.

    **Example:**

    .. code-block:: robotframework

    ${release}  Get Software Version From Enb

    """

    ssh = ssh_connect_to_enb()

    ftp = ssh.open_sftp()
    files = ftp.listdir('/ffs/run')
    result = [i for i in files if i.startswith('TargetBD') and i.endswith('.xml')][0]
    release = result.split('_', 2)[1]

    ssh.close()

    print(release)
    return release


@keyword(name='Get AirScale BBMOD Mapping')
def get_airscale_bbmod_mapping(print_table=True):
    """
    Get AirScale BBMOD Mapping

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    | **Full description:**
    KW for getting bbmod mapping for AirScale module
    KW returns dictionary where keys is/are AirScale modules with serial numbers.
    Values are BBMODs with serial numbers.

    **Input Parameters:**

    +------------------+------+------------------------------------------------+
    | Input Parameters | Man. | Description                                    |
    +==================+======+================================================+
    | print_table      | No   | Print table with IPs to console, default True  |
    +------------------+------+------------------------------------------------+

     **Example:**

    .. code-block:: robotframework

    Get AirScale BBMOD Mapping  print_table=False
    """

    bbmod_sn = {}

    ssh = ssh_connect_to_enb()
    m_smod_id_sn = get_modules_data(ssh)
    print(m_smod_id_sn)
    bbmod_sn[m_smod_id_sn] = []

    for i in range(1, 4):
        try:
            ssh_bbmod = set_ssh_tunnel_to_second_core(ssh, hostname, 'fsp{0}s0icom'.format(i))
            m_module_id_sn = get_modules_data(ssh_bbmod)
            ssh_bbmod.close()
            bbmod_sn[m_smod_id_sn].append(m_module_id_sn)
            print("fsp{0}s0icom with BBMOD: {1}".format(i, m_module_id_sn))
        except Exception:
            print('No BBMOD for fsp{0}s0icom'.format(i))

    hostname_2 = set_second_core_hostname(ssh)
    second_host_ping_rc = get_ping_status_for_second_core(ssh, hostname_2)

    if second_host_ping_rc is 0:
        print("Found host on {0} !".format(hostname_2))
        ssh_2 = set_ssh_tunnel_to_second_core(ssh, hostname, hostname_2)
        s_smod_id_sn = get_modules_data(ssh_2)
        bbmod_sn[s_smod_id_sn] = []
        for i in range(4, 7):
            try:
                ssh_bbmod = set_ssh_tunnel_to_second_core(ssh_2, hostname_2, 'fsp{0}s0icom'.format(i))
                s_module_id_sn = get_modules_data(ssh_bbmod)
                ssh_bbmod.close()
                bbmod_sn[s_smod_id_sn].append(s_module_id_sn)
                print("fsp{0}s0icom with BBMOD: {1}".format(i, s_module_id_sn))
            except Exception:
                print('No BBMOD for fsp{0}s0icom'.format(i))

    for key, value in zip(bbmod_sn.keys(), bbmod_sn.values()):
        print(key, value)

    new_tb = tabulate(bbmod_sn.items(),
                      headers=["SMOD", "BBMOD SN"], tablefmt="fancy_grid")
    logger.info(new_tb, also_console=print_table)

    ssh.close()
    try:
        ssh_2.close()
    except Exception:
        print("No ssh channel to {0} to close !".format(hostname_2))

    return bbmod_sn


def get_modules_data(ssh):
    """
    Def returns module name with serial number

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    """
    module_sn_cmd = 'sysinfo 2>/dev/null | grep -m 1 MODULE_SN'
    module_id_cmd = 'sysinfo 2>/dev/null | grep -m 1 MODULE_ID'

    stdin_sn, stdout_sn, stderr_sn = ssh.exec_command(module_sn_cmd)
    stdin_id, stdout_id, stderr_id = ssh.exec_command(module_id_cmd)
    try:
        module_sn = re.findall(r'(?<=\')(.*?)(?=\')', str(stdout_sn.read()))[0]
        module_id = re.findall(r'(?<=\')(.*?)(?=\')', str(stdout_id.read()))[0]
    except Exception:
        module_sn = 'Unknown'
        module_id = 'Unknown'

    return module_id + ' ' + module_sn


def ssh_connect_to_enb():
    """
    Def setting ssh connection to ENB and returns ssh session

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    """
    module_id_cmd = 'cat /proc/device-tree/module-identity/unit-id'

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname=hostname, username=username, password=password)

    stdin, stdout, stderr = ssh.exec_command(module_id_cmd)
    module_id = stdout.read().decode()
    print("Master SMOD: {0}".format(module_id))

    return ssh


def set_second_core_hostname(ssh_session):
    """
     Def returns hostname for second smod
     If fct-4a alias is found in /etc/hosts - fct-4a hostname is set
     else 192.168.255.7

     | **Author:** mateusz.kawka@nokia.com
     | **Maintainers:** mateusz.kawka@nokia.com

     """
    hosts_ips_cmd = 'cat /etc/hosts'

    stdin, stdout, stderr = ssh_session.exec_command(hosts_ips_cmd)
    hosts = stdout.read().decode()
    hostname_2 = 'fct-4a' if 'fct-4a' in hosts else '192.168.255.7'

    return hostname_2


def get_ping_status_for_second_core(ssh_session, hostname_2):
    """
    Def returns return code from ping to second smod

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    """
    stdin, stdout, stderr = ssh_session.exec_command("ping -c 1 " + hostname_2)
    second_host_ping_rc = stdout.channel.recv_exit_status()
    print("RC for ping cmd to second host is {0}".format(second_host_ping_rc))

    return second_host_ping_rc


def set_ssh_tunnel_to_second_core(ssh_session, hostname, hostname_2):
    """
    Def for setting ssh tunnel to second core
    Returns session to second core

    | **Author:** mateusz.kawka@nokia.com
    | **Maintainers:** mateusz.kawka@nokia.com

    """
    smod_2 = ssh_session.get_transport()
    dest_addr = (hostname_2, 22)
    local_addr = (hostname, 22)
    smod_2_channel = smod_2.open_channel("direct-tcpip", dest_addr, local_addr)
    ssh_2 = paramiko.SSHClient()
    ssh_2.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh_2.connect(hostname=hostname_2, username=username, password=password, sock=smod_2_channel)

    return ssh_2


# for further development

def find_connection_to_rmod(ru_serial_number):
    frips_command = 'cat /rom/config/FRIps.txt'

    ssh = ssh_connect_to_enb()
    stdin, stdout, stderr = ssh.exec_command(frips_command)
    frips_output_1 = stdout.readlines()

    rmod_ip = check_if_rmod_in_frips(frips_output_1, ru_serial_number)
    if rmod_ip is not None:
        print("Found RMOD {0} -> {1}".format(ru_serial_number, rmod_ip))
        return ssh, rmod_ip

    else:
        hostname_2 = set_second_core_hostname(ssh)
        hostname_2_ping_rc = get_ping_status_for_second_core(ssh, hostname_2)
        # stdin, stdout, stderr = ssh.exec_command(module_id_cmd)
        # module_id = stdout.read().decode()
        if hostname_2_ping_rc == 0:
            ssh_2 = set_ssh_tunnel_to_second_core(ssh, hostname_2)
            stdin, stdout, stderr = ssh_2.exec_command(frips_command)
            frips_output_2 = stdout.readlines()
            rmod_ip = check_if_rmod_in_frips(frips_output_2, ru_serial_number)
            if rmod_ip is not None:
                return ssh_2, rmod_ip
            else:
                raise Exception("Cannot find RU serial number with proper IP on any SMOD")


def get_carriers_tx_power(rmod_sn):
    module_id_cmd = 'cat /proc/device-tree/module-identity/unit-id'

    ssh, rmod_ip = find_connection_to_rmod(rmod_sn)
    print(rmod_ip)

    stdin, stdout, stderr = ssh.exec_command(module_id_cmd)
    module_id = stdout.read().replace('\x00', '').decode()
    if module_id in AIRSCALE_MODULES:
        print(AIRSCALE_MODULES)
        jump_to_lxc_container(ssh, rmod_ip)


def jump_to_lxc_container(ssh_session, ip):
    lxc_ls_command = 'lxc-ls'
    stdin, stdout, stderr = ssh_session.exec_command(lxc_ls_command)
    lxc_output = stdout.read().decode()
    lxc_container = re.findall(r'0x[1|2]018', lxc_output)[0]
    print(lxc_container)
    stdin, stdout, stderr = ssh_session.exec_command(
        'lxc-attach -n {0} ssh root@{1};exit'.format(lxc_container, ip))
    conn = stdout.read()
    print(conn)


def check_if_rmod_in_frips(cmd_output, ru_serial_number):
    for rmod in cmd_output:
        serial_number = rmod.split(';')[3]
        ip = rmod.split(';')[2]
        print('Serial number {0}: {1} '.format(serial_number, ip))
        if ru_serial_number == serial_number and ip != '0.0.0.0':
            return ip

    return


# For def testing:

# get_ru_family('AZQP')
# get_antenna_lines_for_ru(type_of_ant='virtual', product_name='AHFII', direction='TX')
# get_custom_antenna_mapping('AHPMDA', 'DAPD', 'RX')
# frmon_get_virtual_antenna_lines_for_ru('5_1_4T4R_2NAHKA_2BAND', [5, 6])
# print_carriers_power_table(fake, 'AHFIG', '192.168.101.1', 'TX')
# frmon_extract_carriers_power(string, carriers)
# dapd_get_virtual_antenna_lines_for_ru('5_1_2T4R_2NAHKA_3BAND', ([1, 2, 3, 4], [5, 6]))
# convert_frmon_to_physical_antennas(dictio, 'AHPMDA', 'TX')
# get_ru_ips()
# get_software_version_from_enb()
# prepare_frmon_power_command(output)
# get_carriers_power_dictionary_from_frmon(otp, power_diction)
# print_tx_power_table(power_dictio, 'ARDA', '192.168.101.1')
# ssh_connect_to_enb()
# find_connection_to_rmod('6Q182525822')
# find_connection_to_rmod('EA191771360')
# get_carriers_tx_power('6Q182525822')
# get_airscale_bbmod_mapping()
