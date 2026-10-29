def get_throughput_limit_bits_with_deviation(speed, deviation=0.2):
    if int(speed) == 0:
        raise AssertionError('ERROR: Throughput Value is 0')
    speed_in_bits = int(speed) * 1000000
    speed_limit = speed_in_bits - int(speed_in_bits * deviation)
    return speed_limit


def check_data_rate_scheduling_weight_ratio(scheduling_weight_to_throughput):
    for initial_scheduling_weight, initial_throughput in scheduling_weight_to_throughput.items():
        for next_scheduling_weight, next_throughput in scheduling_weight_to_throughput.items():
            ratio_of_scheduling_weight = float(next_scheduling_weight)/float(initial_scheduling_weight)
            ratio_of_throughput = float(next_throughput)/float(initial_throughput)
            status = (ratio_of_scheduling_weight * (1 - 0.2)) <= ratio_of_throughput <= \
                     (ratio_of_scheduling_weight * (1 + 0.2))
            if not status:
                return status
            else:
                continue
    return status
