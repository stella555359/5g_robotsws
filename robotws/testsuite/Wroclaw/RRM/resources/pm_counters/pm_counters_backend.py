def extract_last_values_from_pi_dict(pi_dict, counters_count, sum_of_batches=1):
    sum_of_batches = int(sum_of_batches)
    result_dict = {}
    pi_dict = [entry for entry in pi_dict if list(list(entry.values())[0].values())[0] != {}]
    result_dict[list(list(pi_dict[0].values())[0].keys())[0]] = {}
    for date_entry in pi_dict[-1 * sum_of_batches * counters_count:]:
        try:
            for cell_id, counter_val in list(list(date_entry.values())[0].values())[0].items():
                try:
                    result_dict[list(list(date_entry.values())[0].keys())[0]][cell_id.split('-')[-1]] += \
                        float(counter_val)
                except KeyError:
                    result_dict[list(list(date_entry.values())[0].keys())[0]][cell_id.split('-')[-1]] = \
                        float(counter_val)
        except KeyError:
            result_dict[list(list(date_entry.values())[0].keys())[0]] = \
                {k.split('-')[-1]: float(v) for (k, v) in list(list(date_entry.values())[0].values())[0].items()}
    return result_dict


def resolve_oam_type_name(name):
    name = str(name)
    if 'mz' in name.lower() or 'mega' in name.lower():
        return 'mzoam'
    elif 'coam' in name.lower() or 'common' in name.lower():
        return 'coam'
    return None
