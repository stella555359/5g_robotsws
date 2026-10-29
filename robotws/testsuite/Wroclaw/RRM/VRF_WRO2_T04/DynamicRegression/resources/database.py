import random

field_info = {
    'n25, n2': {
        '5': 19338,
        '15': 10229
    },
    'n41': {
        '100': 27377,
        '80': 5684,
        '60': 2256
    },
    'n66': {
        '5': 104,
        '10': 105          # brak info do sprawdzenia w PCS
    },
    'n71': {
        '5': 30000,
        '10': 42249,
        '15': 34665,
        '20': 42249,
    }
}


def random_bandwidth(band):
    result = random.choices(list(field_info[band].keys()), weights=field_info[band].values())[0]
    print(f"Selected banwidth for band {band}: {result}")
    return result
