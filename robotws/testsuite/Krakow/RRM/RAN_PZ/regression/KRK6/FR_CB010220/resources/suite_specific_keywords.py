"""
:author: Michal Jonczyk    Monika Myśliwiec   Szymon Mastalski   Mateusz Potoniec
:contact: michal.jonczyk@nokia.com    monika.mysliwiec@nokia.com    szymon.mastalski@nokia.com
          mateusz.potoniec@nokia.com
"""

from robot.api import logger
from robot.api.deco import keyword

from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter


@keyword()
def check_counters(counters_list: list, allowed_zero_value_counters_list: list, dist_name: str = None) -> bool:
    """
    Gets counters form BTS, reads its last value and checks if counter is in
    allowed zero value counters list when it has value equals to 0.

    :param counters_list: list of counter names to check.
    :param allowed_zero_value_counters_list: list of counter names that can have 0 value.
    :param dist_name: specific path for which counters should be verified

    :return: False if counter can't be found, last value can't be read or counter has not allowed 0 value.
             If everything is all right keyword returns True
    """

    gnb_pm_counter = GnbPmCounter()
    logger.debug('Counters to check list: {}'.format(counters_list))
    logger.debug('Counters with allowed 0 value list: {}'.format(allowed_zero_value_counters_list))

    counters_with_values = dict()
    for counter in counters_list:
        try:
            if dist_name:
                counter_for_all_dist_names = gnb_pm_counter.get_counter(counter)
                dist_name_path = dist_name.split('/')
                d1 = counter_for_all_dist_names
                for key in dist_name_path:
                    d2 = d1[key]
                    d1 = d2
                    logger.debug('{d1}'.format(d1=d1))
                counter_data = gnb_pm_counter.extract_counter_data_from_response(d1, counter)
            else:
                counter_data = gnb_pm_counter.extract_counter_data_from_response(
                    gnb_pm_counter.get_counter(counter), counter)

            counter_timestamps = counter_data[0]["timestamps"]
            counter_last_value = counter_timestamps[0][list(counter_timestamps[0].keys())[-1]]

            logger.debug('Counter {counter_name}: has value: {counter_value}'.format(
                counter_name=counter, counter_value=counter_last_value))

        except (IndexError, ValueError, TypeError) as e:
            logger.error('Problem with getting counter or value of counter named: {counter_name}'.format(
                counter_name=counter))
            logger.error('Exception that did occur: {exception}'.format(exception=e))
            return False

        if counter_last_value == 0 and counter not in allowed_zero_value_counters_list:
            logger.error('Counter {counter_name}: has not allowed 0 value'.format(counter_name=counter))
            return False

        counters_with_values[counter] = counter_last_value
        logger.debug('Counter {counter_name}: have been found, and has a proper value: {counter_value}'.format(
            counter_name=counter, counter_value=counter_last_value))

    for counter, value in counters_with_values.items():
        logger.debug('Counter {counter_name}: has value: {counter_value}'.format(
            counter_name=counter, counter_value=value))

    return True
