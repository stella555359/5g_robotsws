from robot.api import logger


def get_last_counters_values(counters):
    """
    Returns a dictionary containing the last value for each counter.

    Args:
        counters (dict): A dictionary where keys are counter names and values are dictionaries of timestamps and values.

    Returns:
        dict: A dictionary containing the last value for each counter.
    """
    last_counters = {}
    for counter, timestamps_and_values in counters.items():
        last_value = sorted(timestamps_and_values, reverse=True)[0]
        last_counters[counter] = timestamps_and_values[last_value]
    return last_counters


def get_sum_of_counters_last_two__values(counters):
    """
    Use to assure test value collection even if counter already return to zero.

    Returns a dictionary containing the sum of the last two values for each counter.

    Args:
        counters (dict): A dictionary where keys are counter names and values are dictionaries of timestamps and values.

    Returns:
        dict: A dictionary containing the sum of the last two values for each counter.
    """
    counter_value_dict = {}
    for counter, timestamps_and_values in counters.items():
        if len(timestamps_and_values) > 1:
            last_timestamp = sorted(timestamps_and_values, reverse=True)[0]
            penultimate_timestamp = sorted(timestamps_and_values, reverse=True)[1]
            last_value = timestamps_and_values[last_timestamp]
            penultimate_value = timestamps_and_values[penultimate_timestamp]
            values_summation = int(last_value) + int(penultimate_value)
            counter_value_dict[counter] = values_summation
        else:
            last_timestamp = sorted(timestamps_and_values, reverse=True)[0]
            counter_value_dict[counter] = timestamps_and_values[last_timestamp]
    return counter_value_dict


def check_counters_are_zero(counters):
    """
    Asserts that all counters in the given dictionary are zero.

    Args:
        counters (dict): A dictionary where keys are counter names and values are counter values.

    Raises:
        AssertionError: If any counter value is not zero.
    """
    logger.info(counters, html=True)
    for counter, value in counters.items():
        assert value == 0, 'Counter value is not 0! | {}={}'.format(counter, value)


def check_counters_are_greater_than_zero(counters):
    """
    Asserts that all counters in the given dictionary are greater than zero.

    Args:
        counters (dict): A dictionary where keys are counter names and values are counter values.

    Raises:
        AssertionError: If any counter value is not greater than zero.
    """
    for counter, value in counters.items():
        assert value > 0, 'Counter value is 0! | {}={}'.format(counter, value)


def check_counters_are_greater_than_number(counters, number):
    """
    Asserts that all counters in the given dictionary are greater than the given number.

    Args:
        counters (dict): A dictionary where keys are counter names and values are counter values.
        number (int): The number to compare against.

    Raises:
        AssertionError: If any counter value is not less than the given number.
    """
    for counter, value in counters.items():
        assert int(value) > int(number), f"Counter value is not greater than {number}! | {counter}={value}"


def check_counters_are_less_than_number(counters, number):
    """
    Asserts that all counters in the given dictionary are less than the given number.

    Args:
        counters (dict): A dictionary where keys are counter names and values are counter values.
        number (int): The number to compare against.

    Raises:
        AssertionError: If any counter value is not less than the given number.
    """
    for counter, value in counters.items():
        assert int(value) <= int(number), f"Counter value is not greater than {number}! | {counter}={value}"


def extract_value_from_counter(single_counter_value: dict) -> str:
    """Extracts the value from a dictionary containing a single key-value pair.

    Ex: {'M12312': 15} -> returns 15

    Args:
        single_counter_value (dict): A dictionary containing a single key-value pair representing a counter value.

    Returns:
        str: The value associated with the key in the input dictionary.
    """
    value = list(single_counter_value.values())[0]
    return value


def compare_counters_ratio(counter_1: dict, counter_2: dict, variance: float = 0.1):
    """
    Compares the ratio of two counter values and asserts that it is less than or equal to the specified maximum ratio.

        Args:
            counter_1 (dict): A dictionary containing a single key-value pair representing the first counter value.
            counter_2 (dict): A dictionary containing a single key-value pair representing the second counter value.
            max_ratio (float, optional): The maximum allowed ratio between the two counter values. Defaults to 0.1.

        Raises:
            AssertionError: If the ratio between the two counter values is greater than the specified maximum ratio.
        """
    c1_value = list(counter_1.values())[0]
    c2_value = list(counter_2.values())[0]

    ratio = c2_value / c1_value
    max_ratio = 1 + variance
    min_ratio = 1 - variance
    assert min_ratio <= ratio <= max_ratio, f"Ratio between {c1_value} and {c2_value} is greater than {variance}!"
