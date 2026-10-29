from ta5g_pm_counters.counters_checker.counters_fetchers import FileCountersFetcher


def get_last_counters_from_file(counters_list, file_path, local_moid):
    """
    This function, for given counters list, fetches last their values from given file.
    :param counters_list: List of counters to check.
    :param file_path: Path to file with all counters values.
    :param local_moid: Path inside file to counters MO.
    :returns: List of last counters values.
    """

    file_counters_fetcher = FileCountersFetcher(file_path, local_moid)

    data = []
    for counter_id in counters_list:
        data.append({'counter_id': counter_id, 'name': counter_id})

    last_counters_values = file_counters_fetcher.get_last_counters_values(data)
    return last_counters_values
