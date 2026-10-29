import telnetlib
import time

# Command list
read_all = b'raa\r\n'
read_att = b'ra'
cr = b'\r\n'
set_att = b'sa'


def check_attenuator(ip, port=3001):
    att = telnetlib.Telnet(ip, port)
    time.sleep(1)
    value = att.read_very_eager().rstrip()
    att.close()
    return value


# Function for 5G 3RF case generates dictionary containing dictionary in which in outter dictionary key contain
# sorted attenuator indexes and value is sub dictionary containing attenuation:port values.
# PRE: Function requires properly filled tl.attenuation structure from __init__.py, attenuation_key key for witch
# are generated groupped attenuations (eg. attenuation_rf1 -> for this case all other ports omitting these for
# rf1 will be surpressed) and suppress parameter with has default value Fale and if it is set to True cause that
# all attenuations will be set to 90 (good for suppressing attenuation after test).
# POST: Function will generate grouped_attenuation dictionary for chosen key that allow to set attenuation with
# less number of attenuator connections.
def generate_grouped_attenuation(tl_attenuation, attenuation_key, suppress=False):
    attenuation_index = tl_attenuation["attenuation_index"]
    grouped_attenuation = {}
    print(f"Generating for the key: {attenuation_key}")
    for key, index in sorted(attenuation_index.items(), key=lambda item: item[1]):
        current_attenuation_key = f"attenuation_{key}"
        print(f"Processing: {current_attenuation_key} with attenuator index: {index}")
        if index not in grouped_attenuation:
            grouped_attenuation[index] = {}
        for k in tl_attenuation[current_attenuation_key]:
            if current_attenuation_key == attenuation_key and suppress is False:
                grouped_attenuation[index][k] = tl_attenuation[current_attenuation_key][k]
                print(f"Added {k}: {tl_attenuation[current_attenuation_key][k]} to the grouped_attenuation[{index}]")
            else:
                grouped_attenuation[index][k] = 90
                print(f"Added {k}: 90 to the grouped_attenuation[{index}]")
    return grouped_attenuation


# Function generates reduced attenuation_index dictionary from tl.attenuation in __init__.py containing only
# first key containing particular attenuator index. This information can be used to check active attenuators
# (unique attenuators have unique indexes).
# PRE: Function require correctly filled attenuation_index dictionary from __init__.py
# POST: Function will generate reduced dictionary containing only keys with
# first occurence of particular attenuator index.
def reduce_attenuation_index(attenuation_index):
    unique_indexes = set()
    reduced_attenuation_index = {}
    for rf, atten_index in attenuation_index.items():
        print(f"Processing key: {rf} with attenuator index value: {atten_index}")
        if atten_index not in unique_indexes:
            unique_indexes.add(atten_index)
            reduced_attenuation_index[rf] = atten_index
            print(f"Added {rf}:{atten_index} to the reduced_attenuation_index")
    return reduced_attenuation_index
