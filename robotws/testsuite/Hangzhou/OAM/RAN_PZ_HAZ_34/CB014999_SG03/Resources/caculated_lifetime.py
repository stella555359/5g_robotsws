def caculate_lifetime_sums(
    filename,
    antenna_count=64,
    carrier_type='NR_5G_TDD',
    carrier_center_freq='3549990000',
    carrier_bandwidth='100000000'
):
    results = {}
    with open(filename, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    i = 0
    while i < len(lines):
        if lines[i].strip() == 'Item type: rtwp_histogram':
            item_id_line = lines[i+1].strip()
            if item_id_line.startswith('Item id:'):
                item_id = item_id_line.replace('Item id:', '').strip()
                for n in range(1, antenna_count + 1):
                    target_id = f'{carrier_type}_{carrier_center_freq}_{carrier_bandwidth}_antenna{n}a'
                    if item_id == target_id:
                        lifetime_line = lines[i+18].strip()
                        if lifetime_line.startswith('LIFETIME:'):
                            numbers = [int(x) for x in lifetime_line.replace('LIFETIME:', '').split()]
                            results[item_id] = sum(numbers)
                        break
            i += 19
        else:
            i += 1
    values = list(results.values())
    if len(values) == antenna_count and all(v == values[0] for v in values):
        return values[0]
    else:
        return results
