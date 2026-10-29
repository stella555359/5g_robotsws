from robot.api import logger


class PmUtils:
    def __init__(self):
        pass

    @staticmethod
    def get_last_counters_values(counters):
        last_counters = {}
        for counter, timestamps_and_values in counters.items():
            last_value = sorted(timestamps_and_values, reverse=True)[0]
            last_counters[counter] = timestamps_and_values[last_value]
        return last_counters

    @staticmethod
    def get_sum_of_counters_last_two__values(counters):
        """Use to assure test value collection even if counter already return to zero."""
        counter_value_dict = {}
        for counter, timestamps_and_values in counters.items():
            if len(timestamps_and_values) > 1:
                last_timestamp = sorted(timestamps_and_values, reverse=True)[0]
                penultimate_timestamp = sorted(timestamps_and_values, reverse=True)[1]
                last_value = timestamps_and_values[last_timestamp]
                penultimate_value = timestamps_and_values[penultimate_timestamp]
                values_summation = int(last_value)+int(penultimate_value)
                counter_value_dict[counter] = values_summation
            else:
                last_timestamp = sorted(timestamps_and_values, reverse=True)[0]
                counter_value_dict[counter] = timestamps_and_values[last_timestamp]
        return counter_value_dict

    @staticmethod
    def check_counters_are_zero(counters):
        logger.info(counters, html=True)
        for counter, value in counters.items():
            assert value == 0, 'Counter value is not 0! | {}={}'.format(counter, value)

    @staticmethod
    def check_counters_are_greater_than_zero(counters):
        for counter, value in counters.items():
            assert value > 0, 'Counter value is 0! | {}={}'.format(counter, value)

    @staticmethod
    def check_counters_are_greater_than_number(counters, number):
        for counter, value in counters.items():
            assert value < number, "Counter value is lower than {} !".format(number)

    @staticmethod
    def check_counters_are_less_than_number(counters, number):
        for counter, value in counters.items():
            assert value > number, "Counter value is greater than {} !".format(number)

    @staticmethod
    def check_counters_are_zero_and_return(counters):
        logger.info(counters, html=True)
        result = [x for x in counters.values() if x == 0]
        if len(result) == len(counters.values()):
            return True
        return False

    @staticmethod
    def check_counters_are_greater_than_zero_and_return(counters):
        logger.info(counters, html=True)
        result = [x for x in counters.values() if x > 0]
        if len(result) == len(counters.values()):
            return True
        return False

    @staticmethod
    def create_list_of_counters(counters):
        list_of_counters = counters.split(',')
        return list_of_counters
