import math
from robot.api import logger
from tput_counters import (
    DIST_EST_TPUT_COUNTERS,
)

tput_range = [
    (0, 1),
    (1, 10),
    (10, 20),
    (20, 50),
    (50, 100),
    (100, 500),
    (500, 1000),
    (1000, 2000),
    (2000, 3000),
    (3000, 4000),
    (4000, 5000),
    (5000, math.inf),
]


def validate_counter_values(counter_values, avg_tput):
    measured_counter = find_counter(avg_tput)
    sum_counters = sum_all_counters_values(counter_values)
    assert sum_counters != 0, "NO TPUT from counters"
    errors_list = []
    for i in range(len(DIST_EST_TPUT_COUNTERS)):
        val = counter_values["M55323C120" + str(i + 1).zfill(2)]
        if "M55323C120" + str(i + 1).zfill(2) == measured_counter:
            if val < (0.8 * sum_counters):
                logger.info(
                    "  {} counter value NOK, percentage value of the sum of all counters {}%".format(
                        measured_counter, round((val / sum_counters) * 100, 1)
                    ),
                    also_console=True,
                )
                errors_list.append("{} NOK for avg tput: {}".format("M55323C120" + str(i + 1).zfill(2), avg_tput))
            else:
                logger.info(
                    "  {} counter value OK".format(
                        "M55323C120" + str(i + 1).zfill(2)), also_console=True
                )
        else:
            if val > (0.8 * sum_counters):
                logger.info(
                    "  {} counter value NOK, percentage value of the sum of all counters {}%".format(
                        "M55323C120" + str(i + 1).zfill(2),
                        round((val / sum_counters) * 100, 1),
                    ),
                    also_console=True,
                )
                errors_list.append("{} NOK for avg tput: {}".format("M55323C120" + str(i + 1).zfill(2), avg_tput))
            else:
                logger.info(
                    "  {} counter value OK".format(
                        "M55323C120" + str(i + 1).zfill(2)), also_console=True
                )
    assert len(errors_list) == 0, errors_list


def find_counter(avg_tput):
    counter_postfix = 0
    for beginning, end in tput_range:
        counter_postfix += 1
        if beginning < float(avg_tput) <= end:
            logger.info(
                "\n Average tput: {}Mbit/s is in range {} so counter {} should be increased".format(
                    avg_tput,
                    (beginning, end),
                    "M55323C120" + str(counter_postfix).zfill(2),
                ),
                also_console=True,
            )
            return "M55323C120" + str(counter_postfix).zfill(2)
    return None


def sum_all_counters_values(counter_values):
    counters_sum = 0
    for i in range(len(DIST_EST_TPUT_COUNTERS)):
        value = counter_values["M55323C120" + str(i + 1).zfill(2)]
        counters_sum = counters_sum + value
    return counters_sum
