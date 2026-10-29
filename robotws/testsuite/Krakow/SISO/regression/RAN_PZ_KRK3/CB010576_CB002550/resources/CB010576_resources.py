"""
:copyright: Nokia Networks
:authors:
    Wojciech Dudek, wojciech.1.dudek@nokia.com
    Patryk Wojcik,  patryk.wojcik@nokia.com
:maintainers:
    Wojciech Dudek, wojciech.1.dudek@nokia.com
    Patryk Wojcik,  patryk.wojcik@nokia.com

"""
import datetime
import logging
from taf.rfrl.utilities import tl_config
from taf.sbts.oam.coam.admin import admin


admin_cli = admin()
dist_name = "MRBTS-{}/MNL-1/MNLENT-1/SECADM-1".format(tl_config.get_bts_instance_id())
compliance_Code_list = ['0', 'SFF_8472_REV_9_3', 'SFF_8472_REV_9_5', 'SFF_8472_REV_10_2', 'SFF_8472_REV_10_4',
                        'SFF_8472_REV_11_0', 'SFF_8472_REV_11_3', 'SFF_8472_REV_11_4', 'SFF_8472_REV_12_3',
                        'SFF_8636_REV_2_7', 'UNKNOWN', 'N/A']

vendor_list = ['FINISAR CORP', 'FINISAR CORP.', 'FINISARCORP.', 'SOURCEPHOTONICS', 'WTD', 'NOKIA']
txPower_list = ['None', 'N/A', '4', '3', '2', '1', '-8', '-']


def get_information_about_sfp_links():
    """
    Get information about sfp links.
    Function get full info about sfp links and also is checking if source or destination
    was used for smod, bbmod and rmod.
    +------------------+---------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                              |
    +==================+=========+============+============+============+============+============+============+
    | ${links}  ${SMOD}  ${BBMOD}  ${RMOD}    Get information about sfp links                                  |
    +------------------+---------+------------+------------+------------+------------+------------+------------+
    :return:            links, smod_dict, bbmod_dict, rmod_dict
    """
    credentials = tl_config.get_web_credentials_for_du(bts_id=0, du_id=0)
    admin_cli.connect_to(username=credentials['username'], password=credentials['password'])
    links = admin_cli.get_sfp_links()
    connected = links['connected']
    num_of_links = len(connected)
    bbmod_dict, smod_dict, rmod_dict = {}, {}, {}
    for idx in range(0, num_of_links):
        for route in ['source', 'destination']:
            if 'SMOD' in connected[idx][route]:
                smod_dict[idx] = route
            if 'BBMOD' in connected[idx][route]:
                bbmod_dict[idx] = route
            if 'RMOD' in connected[idx][route]:
                rmod_dict[idx] = route
    admin_cli.teardown()
    return links, smod_dict, bbmod_dict, rmod_dict


def check_if_static_data_sfp_qsfp_have_a_valid_value_for_ports_for_smod(links, smod):
    """
    Check if static data for sfp/qsfp have a valid value for ports for smod
    +------------------+---------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                              |
    +==================+=========+============+============+============+============+============+============+
    |     Check if static data SFP QSFP have a valid value for ports for SMOD  ${links}     ${SMOD}            |
    +------------------+---------+------------+------------+------------+------------+------------+------------+
    :param links:    full data about sfp links
    :param smod:     dict of routes for given ports for smod
    """
    for port in list(smod.keys()):
        route = smod[port]
        sfp_qsfp_manufacturer_date = links["notConnected"][port]["details"]["staticParameters"]["dateCode"][route]
        current_year = datetime.datetime.now().year
        assert int(str(current_year)[2:]) >= int(sfp_qsfp_manufacturer_date[0:2]) > 14
        compliance_code = links["notConnected"][port]["details"]["hardwareParameters"]["complianceCode"][route]
        assert compliance_code in compliance_Code_list
        vendor = links["notConnected"][port]["details"]["hardwareParameters"]["vendor"][route]
        assert vendor in vendor_list
        vendor_part_number = links["notConnected"][port]["details"]["hardwareParameters"]["vendorPartNumber"][route]
        vendor_revision = links["notConnected"][port]["details"]["hardwareParameters"]["vendorRevision"][route]
        serial_number = links["notConnected"][port]["details"]["hardwareParameters"]["serialNumber"][route]
        connector_type = links["notConnected"][port]["details"]["hardwareParameters"]['connectorType'][route]
        wave_length = links["notConnected"][port]["details"]["staticParameters"]['waveLength'][route]
        transmission_rate = links["notConnected"][port]["details"]["staticParameters"]['transmissionRate'][route]
        credentials = tl_config.get_web_credentials_for_du(bts_id=0, du_id=0)
        admin_cli.connect_to(username=credentials['username'], password=credentials['password'])
        physical_port = admin_cli.get_parameters(links['notConnected'][port][route], 'physicalPort', timeout=20)
        physical_port = physical_port['physicalPort']
        admin_cli.teardown()
        list_of_parameters = [vendor_part_number, vendor_revision, serial_number, connector_type, wave_length,
                              transmission_rate, physical_port]
        logging.info(f'[vendor_part_number, vendor_revision, serial_number, connector_type, wave_length, '
                     f'transmission_rate, physical_port]={list_of_parameters}')
        for elem in list_of_parameters:
            assert elem != ''
            assert elem != 'N/A'


def check_if_qsfp_or_sfp(links, bbmod):
    """
    Checks physical port and return RF1/RF2/RF3/RF4
    +------------------+---------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                              |
    +==================+=========+============+============+============+============+============+============+
    |     ${physicalPort}    Check if QSFP or SFP  ${links}    ${BBMOD}                                        |
    +------------------+---------+------------+------------+------------+------------+------------+------------+
    :param links:    full data about sfp links
    :param bbmod:    dict of routes for given ports for bbmod
    :return:         RF1/RF2/RF3/RF4
    """
    bbmod_keys = list(bbmod.keys())
    credentials = tl_config.get_web_credentials_for_du(bts_id=0, du_id=0)
    admin_cli.connect_to(username=credentials['username'], password=credentials['password'])
    for port in bbmod_keys:
        route = bbmod[port]
        physical_port = admin_cli.get_parameters(links['connected'][port][route], 'physicalPort', timeout=20)
        logging.info(f'physical_port{port}={physical_port}')
    admin_cli.teardown()
    return physical_port['physicalPort']


def check_if_tx_parameters_have_a_valid_value_for_ports_for_bbmod(links, bbmod, physicalPort):
    """
    Check if Tx parameters have a valid value for ports for BBMOD
    +------------------+---------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                              |
    +==================+=========+============+============+============+============+============+============+
    | Check if Tx parameters have a valid value for ports for BBMOD    ${links}    ${BBMOD}    ${physicalPort} |
    +------------------+---------+------------+------------+------------+------------+------------+------------+
    :param links:         full data about sfp links
    :param bbmod:         dict of routes for given ports for bbmod
    :param physicalPort:  physical port (RF1/RF2/RF3/RF4)
    """
    bbmod_keys = list(bbmod.keys())
    for port in bbmod_keys:
        route = bbmod[port]
        tx_power_high_alarm_threshold = (
            links)["connected"][port]["details"]["thresholds"]["txPowerHighAlarmThreshold"][route]
        tx_power_low_alarm_threshold = (
            links)["connected"][port]["details"]["thresholds"]["txPowerLowAlarmThreshold"][route]
        tx_power_high_warn_threshold = (
            links)["connected"][port]["details"]["thresholds"]["txPowerHighWarnThreshold"][route]
        tx_power_low_warn_threshold = (
            links)["connected"][port]["details"]["thresholds"]["txPowerLowWarnThreshold"][route]
        elems = [tx_power_high_alarm_threshold, tx_power_low_alarm_threshold, tx_power_high_warn_threshold,
                 tx_power_low_warn_threshold]
        logging.info(f'txPowerHighAlarmThreshold={tx_power_high_alarm_threshold}')
        logging.info(f'txPowerLowAlarmThreshold={tx_power_low_alarm_threshold}')
        logging.info(f'txPowerHighWarnThreshold={tx_power_high_warn_threshold}')
        logging.info(f'txPowerLowWarnThreshold={tx_power_low_warn_threshold}')
        for iter in elems:
            if physicalPort == 'Q_RF1' or physicalPort == 'Q_RF2':
                assert iter in txPower_list, f'{iter} not in txPower_list'
            else:
                assert -100 <= int(iter) <= 100, f'{iter} not in expected range'


def check_if_temperature_parameters_have_a_valid_value_for_ports_for_smod(links, smod):
    """
    Check if temperature parameters have a valid value for ports for SMOD
    +------------------+---------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                              |
    +==================+=========+============+============+============+============+============+============+
    | Check if temperature parameters have a valid value for ports for SMOD   ${links}    ${SMOD}              |
    +------------------+---------+------------+------------+------------+------------+------------+------------+
    :param links:   full data about sfp links
    :param smod:    dict of routes for given ports for bbmod
    """
    smod_keys = list(smod.keys())
    for port in smod_keys:
        route = smod[port]
        temperature_low_alarm_threshold = (
            links)["notConnected"][port]["details"]["thresholds"]["temperatureLowAlarmThreshold"][route]
        temperature_high_alarm_threshold = (
            links)["notConnected"][port]["details"]["thresholds"]["temperatureHighAlarmThreshold"][route]
        logging.info(f'temperatureLowAlarmThreshold={temperature_low_alarm_threshold}')
        logging.info(f'temperatureHighAlarmThreshold={temperature_high_alarm_threshold}')
        assert -128 <= temperature_low_alarm_threshold <= 128, (f'temperature_low_alarm_threshold='
                                                                f'{temperature_low_alarm_threshold}')
        assert -128 <= temperature_high_alarm_threshold <= 128, (f'temperatureHighAlarmThreshold='
                                                                 f'{temperature_high_alarm_threshold}')


def check_if_static_parameters_have_a_valid_value_for_ports(links, rmod):
    """
    Check if static parameters have a valid value for ports
    +------------------+---------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                              |
    +==================+=========+============+============+============+============+============+============+
    | Check if static parameters have a valid value for ports    ${links}    ${RMOD}                           |
    +------------------+---------+------------+------------+------------+------------+------------+------------+
    :param links:         full data about sfp links
    :param smod:          dict of routes for given ports for bbmod
    """
    rmod_keys = list(rmod.keys())
    for port in rmod_keys:
        route = rmod[port]
        rx_power_high_alarm_threshold = (
            links)["connected"][port]["details"]["thresholds"]["rxPowerHighAlarmThreshold"][route]
        rx_power_low_alarm_threshold = (
            links)["connected"][port]["details"]["thresholds"]["rxPowerLowAlarmThreshold"][route]
        rx_power_high_warn_threshold = (
            links)["connected"][port]["details"]["thresholds"]["rxPowerHighWarnThreshold"][route]
        rx_power_low_warn_threshold = (
            links)["connected"][port]["details"]["thresholds"]["rxPowerLowWarnThreshold"][route]
        assert -100 <= int(
            rx_power_high_alarm_threshold) <= 100, f'rx_power_high_alarm_threshold={rx_power_high_alarm_threshold}'
        assert -100 <= int(
            rx_power_low_alarm_threshold) <= 100, f'rx_power_low_alarm_threshold={rx_power_low_alarm_threshold}'
        assert -100 <= int(
            rx_power_high_warn_threshold) <= 100, f'rx_power_high_warn_threshold={rx_power_high_warn_threshold}'
        assert -100 <= int(
            rx_power_low_warn_threshold) <= 100, f'rx_power_low_warn_threshold={rx_power_low_warn_threshold}'
