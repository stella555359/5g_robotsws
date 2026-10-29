from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from collections import defaultdict
from robot.api import logger


def collect_sfp_monitoring_data():
    with AdminSession() as admin:
        return admin.get_sfp_data()


def collect_rmods_data():
    with AdminSession() as admin:
        return admin.get_parameters_for_all('RMOD')


def match_rmod_by_serial_number(rmods_data, serial_number):
    return next(rmod for rmod in rmods_data if rmod['serialNumber'] == serial_number)


def validate_sfp_monitoring(rmod_type):
    verification_results = {
        'sfp_count_match': False,
        'source_destination_valid': True,
        'rmod_count_match': True,
        'optical_power_valid': True,
        'sfp_labels_match': True,
        'errors': []
    }

    rmod_count = 0
    actual_sfp_count = 0
    rmods_data = [rmod for rmod in collect_rmods_data() if rmod['productName'] == rmod_type]
    sfp_data = collect_sfp_monitoring_data()
    number_of_rmods = len(rmods_data)
    rmods = set()
    expected_sfp_count = len([label for rmod in rmods_data for label in rmod['connectorLabels'] if 'OPT_IF' in label])
    logger.info(f"Expected SFP count: {expected_sfp_count}", also_console=True)

    sfp_rmods_data = defaultdict(list)

    for entry in sfp_data['connected']:
        if rmod_type not in entry['source']['productName']:
            continue
        rmods.add(entry['source']['serialNumber'])
        sfp_rmods_data[entry['source']['serialNumber']].append(entry['source']['type'])
        logger.info(entry['source']['type'], also_console=True)
        logger.info(entry['source']['serialNumber'], also_console=True)
        logger.info(entry['source']['productCode'], also_console=True)
        logger.info(entry['source']['productName'], also_console=True)

        if not all(key in entry['source'] for key in ['serialNumber', 'productCode']):
            verification_results['source_destination_valid'] = False
            verification_results['errors'].append(f"Missing required info about product entry['source']['productName']")

        if 'connector' in entry['source'] and 'sfp' in entry['source']['connector']:
            sfp = entry['source']['connector']['sfp']
            tx_power = sfp.get('opticalTxPower', '[0]')
            rx_power = sfp.get('opticalRxPower', '[0]')

            try:
                tx_value = float(tx_power.strip('[]'))
                rx_value = float(rx_power.strip('[]'))

                if tx_value <= 0 or rx_value <= 0:
                    verification_results['optical_power_valid'] = False
                    verification_results['errors'].append(
                        f"Invalid optical power values in SFP {actual_sfp_count}")
            except ValueError:
                verification_results['optical_power_valid'] = False
                verification_results['errors'].append(f"Invalid optical power format in SFP {actual_sfp_count}")

    logger.info(actual_sfp_count)
    verification_results['sfp_count_match'] = sum(len(opts) for opts in sfp_rmods_data.values()) == expected_sfp_count
    if not verification_results['sfp_count_match']:
        verification_results['errors'].append(f"Expected {expected_sfp_count} SFPs, found {actual_sfp_count}")

    check_all_labels = [any(label in opt for opt in sfp_rmods_data[rmod['serialNumber']])
                        for rmod in rmods_data for label in rmod['connectorLabels'] if 'OPT_IF' in label]

    if not all(check_all_labels):
        verification_results['sfp_labels_match'] = False
        verification_results['errors'].append(
            f"Expected all labels for every RMODs")

    if len(rmods) != int(number_of_rmods):
        verification_results['rmod_count_match'] = False
        verification_results['errors'].append(
            f"Expected {number_of_rmods} {rmod_type} RMODs, found {rmod_count}")

    logger.info(sfp_rmods_data, also_console=True)
    logger.info("Verification Results:", also_console=True)
    logger.info(f"SFP Count Match: {verification_results['sfp_count_match']}", also_console=True)
    logger.info(f"SFP Labels Match: {verification_results['sfp_labels_match']}", also_console=True)
    logger.info(f"Source/Destination Valid: {verification_results['source_destination_valid']}", also_console=True)
    logger.info(f"RMOD Count Match: {verification_results['rmod_count_match']}", also_console=True)
    logger.info(f"Optical Power Valid: {verification_results['optical_power_valid']}", also_console=True)
    if verification_results['errors']:
        logger.info("\nErrors found:", also_console=True)
        for error in verification_results['errors']:
            logger.info(f"- {error}", also_console=True)
        raise RuntimeError('Errors detected')

    return verification_results
