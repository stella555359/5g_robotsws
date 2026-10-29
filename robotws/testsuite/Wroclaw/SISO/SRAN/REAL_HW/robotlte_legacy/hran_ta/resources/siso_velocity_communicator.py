"""
:modified: 07.05.2024

:author: Przemyslaw Kempa
:maintainer: Przemyslaw Kempa
:contact: przemyslaw.kempa@nokia.com
"""

from robot.api.deco import keyword
from robot.api import logger
from velocity_communicator import velocityclient
import re
import warnings
import yaml

warnings.filterwarnings(action="ignore", message="unclosed")
ROBOT_AUTO_KEYWORDS = False

velocity_address = "https://velocity.wroclaw.nsn-rdnet.net/"
username = "wrranpz4"
passwrd = "Ut3pa5s#1be1"
veloclient = velocityclient.VelocityRestClient(velocity_address, username, passwrd)


@keyword(name='Velocity Get Device Name With Serial From Reservation')
def velocity_get_device_name_with_serial_from_reservation(reservation_id):
    """
    Get Device Name With Serial From Velocity Reservation

    | **Author:** przemyslaw.kempa@nokia.com
    | **Maintainers:** przemyslaw.kempa@nokia.com

    | **Full description:**

    KW get reservation yaml and return dictionary device name with serialnumber

    **Input Parameters:**

    +------------------+------+---------------------------------------+
    | Input Parameters | Man. | Description                           |
    +==================+======+=======================================+
    | reservation_id   | Yes  | id Velocity reservation               |
    +------------------+------+---------------------------------------+

    **Example:**

    .. code-block:: robotframework

    ${hw}=  Velocity Get Device Name With Serial From Reservation  f3adfc4b-c268-426e-a476-dad7e23f45ea

    | **Return value:**
    | Dictionary device name with serialnumber

     **Example:**

     {'ABIO-326351': 'L1204209897',
     'ABIO-326359': 'L1215008523',
     'ABIP-326285': 'L1231800024',
     'AHEGA-325221': 'K9181423222',
     'AHFII-325467': 'BL2222N4089',
     'AHPMDA-325199': 'K9190901111',
     'AMIA-326009': 'GG215297292',
     'AREA-325326': 'EA203457019',
     'ASIM-326071': 'L1223408475',
     'LongFiber_10-327218': None,
     'VMPC-327344': None}
    """
    reservation = veloclient.get_reservation_yaml(reservation_id)
    reservation_yaml = yaml.safe_load(reservation)
    hardware = {}
    for item in reservation_yaml['topology_template']['node_templates']:
        if reservation_yaml['topology_template']['node_templates'][item]['type'][21:] == "Device":
            device = reservation_yaml['topology_template']['node_templates'][item]['properties']['name']
            serialNumber = None
            property_groups = \
                reservation_yaml['topology_template']['node_templates'][item]['properties']['property_groups']
            for property_group in property_groups:
                if property_group['name'].lower() == "identification":
                    group = property_group['group']
                    for item2 in group:
                        if item2['name'][0:6].lower() == "serial":
                            serialNumber = item2['value']
            hardware[device] = serialNumber
    return hardware


@keyword(name='Velocity Get Connection Between Devices From Reservation')
def velocity_get_connection_between_devices_from_reservation(reservation_id):
    """
    Get Connection Between Devices From Velocity Reservation

    | **Author:** przemyslaw.kempa@nokia.com
    | **Maintainers:** przemyslaw.kempa@nokia.com

    | **Full description:**

    KW get reservation yaml and return dictionary with connection between devices

    **Input Parameters:**

    +------------------+------+---------------------------------------+
    | Input Parameters | Man. | Description                           |
    +==================+======+=======================================+
    | reservation_id   | Yes  | id Velocity reservation               |
    +------------------+------+---------------------------------------+

    **Example:**

    .. code-block:: robotframework

    ${hw}=  Velocity Get Connection Between Devices From Reservation  f3adfc4b-c268-426e-a476-dad7e23f45ea

    | **Return value:**
    | with connection between devices

     **Example:**

     {'ABIO-326351_RF1': 'LongFiber_10-327218_OPT1',
     'ABIO-326359_RF1': 'FHFB-325057_OPT1',
     'ABIP-326285_RF_1': 'AREA-325326_OPT1',
     'ABIP-326285_RF_2': 'AREA-325326_OPT2',
     'ABIP-326285_RF_3': 'AHFII-325467_OPT1',
     'AHEGA-325410_OPT2': 'AHPMDA-325203_OPT1',
     'AHPMDA-325199_OPT2': 'AHEGA-325410_OPT1',
     'AMIA-326009_B4': 'ABIO-326359_BackPlaneInterface',
     'AMIA-326009_B5': 'ABIO-326351_BackPlaneInterface',
     'AREA-325326_OPT3': 'AHPMDA-325199_OPT1',
     'FHFB-325057_OPT2': 'FHFB-325058_OPT1'}

    """

    reservation = veloclient.get_reservation_yaml(reservation_id)
    reservation_yaml = yaml.safe_load(reservation)
    connections = {}
    for item in reservation_yaml['topology_template']['node_templates']:
        if reservation_yaml['topology_template']['node_templates'][item]['type'][21:] == "TypedLink":
            typed_link_id = reservation_yaml['topology_template']['node_templates'][item]['properties']['id']
            connect_from = reservation_yaml['topology_template']['node_templates'][item]['requirements'][0]['from']
            connect_to = reservation_yaml['topology_template']['node_templates'][item]['requirements'][1]['to']
            connect_from_port = \
                reservation_yaml['topology_template']['node_templates'][connect_from]['properties']['name']
            connect_from_device_id = \
                reservation_yaml['topology_template']['node_templates'][connect_from]['requirements'][0]['device']
            connect_from_device_name = \
                reservation_yaml['topology_template']['node_templates'][connect_from_device_id]['properties']['name']
            connect_to_port = reservation_yaml['topology_template']['node_templates'][connect_to]['properties']['name']
            connect_to_device_id = \
                reservation_yaml['topology_template']['node_templates'][connect_to]['requirements'][0]['device']
            connect_to_device_name = \
                reservation_yaml['topology_template']['node_templates'][connect_to_device_id]['properties']['name']
            device_connect_from = connect_from_device_name + "_" + connect_from_port
            device_connect_to = connect_to_device_name + "_" + connect_to_port
            connections[device_connect_from] = device_connect_to
    return connections


@keyword(name='Velocity Get Reservation Yaml')
def velocity_get_reservation_yaml(reservation_id):
    """
    Get Reservation Yaml From Velocity

    | **Author:** przemyslaw.kempa@nokia.com
    | **Maintainers:** przemyslaw.kempa@nokia.com

    | **Full description:**

    KW get reservation yaml as dictionary

    **Input Parameters:**

    +------------------+------+---------------------------------------+
    | Input Parameters | Man. | Description                           |
    +==================+======+=======================================+
    | reservation_id   | Yes  | id Velocity reservation               |
    +------------------+------+---------------------------------------+

    **Example:**

    .. code-block:: robotframework

    ${hw}=  Velocity Get Reservation Yaml  f3adfc4b-c268-426e-a476-dad7e23f45ea

    | **Return value:**
    | dictionary with all information about velocity reservation

    """
    reservation = veloclient.get_reservation_yaml(reservation_id)
    reservation_yaml = yaml.safe_load(reservation)
    return reservation_yaml


@keyword(name='Velocity Create Connection Between Devices')
def velocity_create_connection_between_devices(reservation_id, first_device_name, first_port_name, sec_device_name,
                                               sec_port_name, cabel_type="Opt"):
    """
    Create connection link between two devices.

    | **Author:** przemyslaw.kempa@nokia.com
    | **Maintainers:** przemyslaw.kempa@nokia.com

    | **Full description:**

    KW create connection link between two devices.
    Accepted cabel_type values: Coax, Opt, Gen, RP3, Eth (default cabel_type="Opt")


    **Input Parameters:**

    +-------------------+------+---------------------------------------+
    | Input Parameters  | Man. | Description                           |
    +===================+======+=======================================+
    | reservation_id    | Yes  | id Velocity reservation               |
    +-------------------+------+---------------------------------------+
    | first_device_name | Yes  | Name of the first device              |
    +-------------------+------+---------------------------------------+
    | first_port_name   | Yes  | Name of the port in first device      |
    +-------------------+------+---------------------------------------+
    | sec_device_name   | Yes  | Name of the second device             |
    +-------------------+------+---------------------------------------+
    | sec_port_name     | Yes  | Name of the port in second device     |
    +-------------------+------+---------------------------------------+
    | cabel_type        | No   | Type of the link                      |
    +-------------------+------+---------------------------------------+

    **Example:**

    .. code-block:: robotframework

    ${hw}=  Velocity Create Connection Between Devices
            f3adfc4b-c268-426e-a476-dad7e23f45ea  ABIP-326285  RF_1  AREA-325326  OPT1

    """
    veloclient.create_connection_between_devices(reservation_id, first_device_name, first_port_name, sec_device_name,
                                                 sec_port_name, cabel_type)


@keyword(name='Velocity Delete Connection Between Devices')
def velocity_delete_connection_between_devices(reservation_id, first_device_name, first_port_name, sec_device_name,
                                               sec_port_name):
    """
    Delete connection link between two devices.

    | **Author:** przemyslaw.kempa@nokia.com
    | **Maintainers:** przemyslaw.kempa@nokia.com

    | **Full description:**

    KW delete connection link between two devices.

    **Input Parameters:**

    +-------------------+------+---------------------------------------+
    | Input Parameters  | Man. | Description                           |
    +===================+======+=======================================+
    | reservation_id    | Yes  | id Velocity reservation               |
    +-------------------+------+---------------------------------------+
    | first_device_name | Yes  | Name of the first device              |
    +-------------------+------+---------------------------------------+
    | first_port_name   | Yes  | Name of the port in first device      |
    +-------------------+------+---------------------------------------+
    | sec_device_name   | Yes  | Name of the second device             |
    +-------------------+------+---------------------------------------+
    | sec_port_name     | Yes  | Name of the port in second device     |
    +-------------------+------+---------------------------------------+

    **Example:**

    .. code-block:: robotframework

    ${hw}=  Velocity Delete Connection Between Devices
            f3adfc4b-c268-426e-a476-dad7e23f45ea  ABIP-326285  RF_1  AREA-325326  OPT1

    """
    veloclient.delete_connection_between_devices(reservation_id, first_device_name, first_port_name, sec_device_name,
                                                 sec_port_name)


# reservation_id="f3adfc4b-c268-426e-a476-dad7e23f45ea"
# hw = velocity_get_device_name_with_serial_from_reservation(reservation_id)
# con = velocity_get_optical_connection_between_devices_from_reservation(reservation_id)
# print(hw, con)
