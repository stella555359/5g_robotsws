from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from itertools import zip_longest


def add_list_entries(mail):
    res = [sum((i)) for i in zip_longest(*mail, fillvalue=0)]
    print(res)
    return res


def merge_dictionaries(data1, data2):
    data1.update(data2)
    print(data1)
    return data1


def sum_of_list_entries(list):
    total = sum(list)
    print(total)
    return total


def string_to_list(kpi_string):
    kpi_new_list = kpi_string.split(',')
    print(kpi_new_list)
    return kpi_new_list


def find_string_between(file_path, start_str, end_str):
    status = False
    with open(file_path, 'r') as file:
        content = file.read()
        start_str = 'entry='+start_str
        start_idx = content.find(start_str)
        end_idx = content.find(end_str, start_idx + len(start_str))
        if start_idx != -1 and end_idx != -1:
            status = True
    print(status)
    return status


def NR_5056d(counter_list, counter_value_list):
    """
    KPI Calculation for NR_5056d
    Date Modified: 24/03/2025
    BY: Anjana
    """
    counter_dict = dict(zip(counter_list, counter_value_list))
    summed_data = {key: sum(values) for key, values in counter_dict.items()}
    output = ((100 * ((summed_data["M55302C00000"] + summed_data["M55302C00001"] + summed_data["M55302C00002"]
               + summed_data["M55302C00003"] + summed_data["M55302C00004"] + summed_data["M55302C00005"]
               + summed_data["M55302C00006"] + summed_data["M55302C00007"] + summed_data["M55302C00008"]
               + summed_data["M55302C00009"] + summed_data["M55302C00010"] + summed_data["M55302C00011"]
               + summed_data["M55302C00012"] + summed_data["M55302C00013"] + summed_data["M55302C00014"]
               + summed_data["M55302C00015"] + summed_data["M55302C00016"] + summed_data["M55302C00017"]
               + summed_data["M55302C00018"] + summed_data["M55302C00019"] + summed_data["M55302C00020"]
               + summed_data["M55302C00021"] + summed_data["M55302C00022"] + summed_data["M55302C00023"]
               + summed_data["M55302C00024"] + summed_data["M55302C00025"] + summed_data["M55302C00026"]
               + summed_data["M55302C00027"] + summed_data["M55302C00028"] + summed_data["M55302C06000"]
               + summed_data["M55302C06001"] + summed_data["M55302C06002"] + summed_data["M55302C06003"]
               + summed_data["M55302C06004"] + summed_data["M55302C06005"] + summed_data["M55302C06006"]
               + summed_data["M55302C06007"] + summed_data["M55302C06008"] + summed_data["M55302C06009"]
               + summed_data["M55302C06010"] + summed_data["M55302C06011"] + summed_data["M55302C06012"]
               + summed_data["M55302C06013"] + summed_data["M55302C06014"] + summed_data["M55302C06015"]
               + summed_data["M55302C06016"] + summed_data["M55302C06017"] + summed_data["M55302C06018"]
               + summed_data["M55302C06019"] + summed_data["M55302C06020"] + summed_data["M55302C06021"]
               + summed_data["M55302C06022"] + summed_data["M55302C06023"] + summed_data["M55302C06024"]
               + summed_data["M55302C06025"] + summed_data["M55302C06026"] + summed_data["M55302C06027"]
               + summed_data["M55302C11000"] + summed_data["M55302C11001"] + summed_data["M55302C11002"]
               + summed_data["M55302C11003"] + summed_data["M55302C11004"] + summed_data["M55302C11005"]
               + summed_data["M55302C11006"] + summed_data["M55302C11007"] + summed_data["M55302C11008"]
               + summed_data["M55302C11009"] + summed_data["M55302C11010"] + summed_data["M55302C11011"]
               + summed_data["M55302C11012"] + summed_data["M55302C11013"] + summed_data["M55302C11014"]
               + summed_data["M55302C11015"] + summed_data["M55302C11016"] + summed_data["M55302C11017"]
               + summed_data["M55302C11018"] + summed_data["M55302C11019"] + summed_data["M55302C11020"]
               + summed_data["M55302C11021"] + summed_data["M55302C11022"] + summed_data["M55302C11023"]
               + summed_data["M55302C11024"] + summed_data["M55302C11025"] + summed_data["M55302C11026"]
               + summed_data["M55302C11027"] + summed_data["M55367C01000"] + summed_data["M55367C01001"]
               + summed_data["M55367C01002"] + summed_data["M55367C01003"] + summed_data["M55367C01004"]
               + summed_data["M55367C01005"] + summed_data["M55367C01006"] + summed_data["M55367C01007"]
               + summed_data["M55367C01008"] + summed_data["M55367C01009"] + summed_data["M55367C01010"]
               + summed_data["M55367C01011"] + summed_data["M55367C01012"] + summed_data["M55367C01013"]
               + summed_data["M55367C01014"] + summed_data["M55367C01015"] + summed_data["M55367C01016"]
               + summed_data["M55367C01017"] + summed_data["M55367C01018"] + summed_data["M55367C01019"]
               + summed_data["M55367C01020"] + summed_data["M55367C01021"] + summed_data["M55367C01022"]
               + summed_data["M55367C01023"] + summed_data["M55367C01024"] + summed_data["M55367C01025"]
               + summed_data["M55367C01026"] + summed_data["M55367C01027"] + summed_data["M55367C01028"]
               + summed_data["M55370C00007"] + summed_data["M55370C00013"])
               - ((summed_data["M55302C04000"]
                   + summed_data["M55302C04001"] + summed_data["M55302C04002"] + summed_data["M55302C04003"]
                   + summed_data["M55302C04004"] + summed_data["M55302C04005"] + summed_data["M55302C04006"]
                   + summed_data["M55302C04007"] + summed_data["M55302C04008"] + summed_data["M55302C04009"]
                   + summed_data["M55302C04010"] + summed_data["M55302C04011"] + summed_data["M55302C04012"]
                   + summed_data["M55302C04013"] + summed_data["M55302C04014"] + summed_data["M55302C04015"]
                   + summed_data["M55302C04016"] + summed_data["M55302C04017"] + summed_data["M55302C04018"]
                   + summed_data["M55302C04019"] + summed_data["M55302C04020"] + summed_data["M55302C04021"]
                   + summed_data["M55302C04022"] + summed_data["M55302C04023"] + summed_data["M55302C04024"]
                   + summed_data["M55302C04025"] + summed_data["M55302C04026"] + summed_data["M55302C04027"]
                   + summed_data["M55302C04028"] + summed_data["M55302C08000"] + summed_data["M55302C08001"]
                   + summed_data["M55302C08002"] + summed_data["M55302C08003"] + summed_data["M55302C08004"]
                   + summed_data["M55302C08005"] + summed_data["M55302C08006"] + summed_data["M55302C08007"]
                   + summed_data["M55302C08008"] + summed_data["M55302C08009"] + summed_data["M55302C08010"]
                   + summed_data["M55302C08011"] + summed_data["M55302C08012"] + summed_data["M55302C08013"]
                   + summed_data["M55302C08014"] + summed_data["M55302C08015"] + summed_data["M55302C08016"]
                   + summed_data["M55302C08017"] + summed_data["M55302C08018"] + summed_data["M55302C08019"]
                   + summed_data["M55302C08020"] + summed_data["M55302C08021"] + summed_data["M55302C08022"]
                   + summed_data["M55302C08023"] + summed_data["M55302C08024"] + summed_data["M55302C08025"]
                   + summed_data["M55302C08026"] + summed_data["M55302C08027"] + summed_data["M55302C13000"]
                   + summed_data["M55302C13001"] + summed_data["M55302C13002"] + summed_data["M55302C13003"]
                   + summed_data["M55302C13004"] + summed_data["M55302C13005"] + summed_data["M55302C13006"]
                   + summed_data["M55302C13007"] + summed_data["M55302C13008"] + summed_data["M55302C13009"]
                   + summed_data["M55302C13010"] + summed_data["M55302C13011"] + summed_data["M55302C13012"]
                   + summed_data["M55302C13013"] + summed_data["M55302C13014"] + summed_data["M55302C13015"]
                   + summed_data["M55302C13016"] + summed_data["M55302C13017"] + summed_data["M55302C13018"]
                   + summed_data["M55302C13019"] + summed_data["M55302C13020"] + summed_data["M55302C13021"]
                   + summed_data["M55302C13022"] + summed_data["M55302C13023"] + summed_data["M55302C13024"]
                   + summed_data["M55302C13025"] + summed_data["M55302C13026"] + summed_data["M55302C13027"]
                   + summed_data["M55367C02000"] + summed_data["M55367C02001"] + summed_data["M55367C02002"]
                   + summed_data["M55367C02003"] + summed_data["M55367C02004"] + summed_data["M55367C02005"]
                   + summed_data["M55367C02006"] + summed_data["M55367C02007"] + summed_data["M55367C02008"]
                   + summed_data["M55367C02009"] + summed_data["M55367C02010"] + summed_data["M55367C02011"]
                   + summed_data["M55367C02012"] + summed_data["M55367C02013"] + summed_data["M55367C02014"]
                   + summed_data["M55367C02015"] + summed_data["M55367C02016"] + summed_data["M55367C02017"]
                   + summed_data["M55367C02018"] + summed_data["M55367C02019"] + summed_data["M55367C02020"]
                   + summed_data["M55367C02021"] + summed_data["M55367C02022"] + summed_data["M55367C02023"]
                   + summed_data["M55367C02024"] + summed_data["M55367C02025"] + summed_data["M55367C02026"]
                   + summed_data["M55367C02027"] + summed_data["M55367C02028"] + summed_data["M55370C00009"]
                   + summed_data["M55370C00015"]))))) / ((summed_data["M55302C00000"] + summed_data["M55302C00001"]
                                                          + summed_data["M55302C00002"] + summed_data["M55302C00003"]
                                                          + summed_data["M55302C00004"] + summed_data["M55302C00005"]
                                                          + summed_data["M55302C00006"] + summed_data["M55302C00007"]
                                                          + summed_data["M55302C00008"] + summed_data["M55302C00009"]
                                                          + summed_data["M55302C00010"] + summed_data["M55302C00011"]
                                                          + summed_data["M55302C00012"] + summed_data["M55302C00013"]
                                                          + summed_data["M55302C00014"] + summed_data["M55302C00015"]
                                                          + summed_data["M55302C00016"] + summed_data["M55302C00017"]
                                                          + summed_data["M55302C00018"] + summed_data["M55302C00019"]
                                                          + summed_data["M55302C00020"] + summed_data["M55302C00021"]
                                                          + summed_data["M55302C00022"] + summed_data["M55302C00023"]
                                                          + summed_data["M55302C00024"] + summed_data["M55302C00025"]
                                                          + summed_data["M55302C00026"] + summed_data["M55302C00027"]
                                                          + summed_data["M55302C00028"] + summed_data["M55302C06000"]
                                                          + summed_data["M55302C06001"] + summed_data["M55302C06002"]
                                                          + summed_data["M55302C06003"] + summed_data["M55302C06004"]
                                                          + summed_data["M55302C06005"] + summed_data["M55302C06006"]
                                                          + summed_data["M55302C06007"] + summed_data["M55302C06008"]
                                                          + summed_data["M55302C06009"] + summed_data["M55302C06010"]
                                                          + summed_data["M55302C06011"]
                                                          + summed_data["M55302C06012"] + summed_data["M55302C06013"]
                                                          + summed_data["M55302C06014"]
                                                          + summed_data["M55302C06015"] + summed_data["M55302C06016"]
                                                          + summed_data["M55302C06017"]
                                                          + summed_data["M55302C06018"] + summed_data["M55302C06019"]
                                                          + summed_data["M55302C06020"]
                                                          + summed_data["M55302C06021"] + summed_data["M55302C06022"]
                                                          + summed_data["M55302C06023"] + summed_data["M55302C06024"]
                                                          + summed_data["M55302C06025"] + summed_data["M55302C06026"]
                                                          + summed_data["M55302C06027"] + summed_data["M55302C11000"]
                                                          + summed_data["M55302C11001"]
                                                          + summed_data["M55302C11002"] + summed_data["M55302C11003"]
                                                          + summed_data["M55302C11004"]
                                                          + summed_data["M55302C11005"] + summed_data["M55302C11006"]
                                                          + summed_data["M55302C11007"]
                                                          + summed_data["M55302C11008"] + summed_data["M55302C11009"]
                                                          + summed_data["M55302C11010"]
                                                          + summed_data["M55302C11011"] + summed_data["M55302C11012"]
                                                          + summed_data["M55302C11013"]
                                                          + summed_data["M55302C11014"] + summed_data["M55302C11015"]
                                                          + summed_data["M55302C11016"] + summed_data["M55302C11017"]
                                                          + summed_data["M55302C11018"] + summed_data["M55302C11019"]
                                                          + summed_data["M55302C11020"] + summed_data["M55302C11021"]
                                                          + summed_data["M55302C11022"] + summed_data["M55302C11023"]
                                                          + summed_data["M55302C11024"] + summed_data["M55302C11025"]
                                                          + summed_data["M55302C11026"] + summed_data["M55302C11027"]
                                                          + summed_data["M55367C01000"] + summed_data["M55367C01001"]
                                                          + summed_data["M55367C01002"] + summed_data["M55367C01003"]
                                                          + summed_data["M55367C01004"] + summed_data["M55367C01005"]
                                                          + summed_data["M55367C01006"] + summed_data["M55367C01007"]
                                                          + summed_data["M55367C01008"] + summed_data["M55367C01009"]
                                                          + summed_data["M55367C01010"] + summed_data["M55367C01011"]
                                                          + summed_data["M55367C01012"] + summed_data["M55367C01013"]
                                                          + summed_data["M55367C01014"] + summed_data["M55367C01015"]
                                                          + summed_data["M55367C01016"] + summed_data["M55367C01017"]
                                                          + summed_data["M55367C01018"] + summed_data["M55367C01019"]
                                                          + summed_data["M55367C01020"] + summed_data["M55367C01021"]
                                                          + summed_data["M55367C01022"] + summed_data["M55367C01023"]
                                                          + summed_data["M55367C01024"] + summed_data["M55367C01025"]
                                                          + summed_data["M55367C01026"] + summed_data["M55367C01027"]
                                                          + summed_data["M55367C01028"] + summed_data["M55370C00007"]
                                                          + summed_data["M55370C00013"]))
    print(output)
    return output


def NR_5054b(counter_list, counter_value_list):
    """
    KPI Calculation for NR_5054b
    Date Modified: 24/03/2025
    BY: Anjana
    """
    counter_dict = dict(zip(counter_list, counter_value_list))
    counter_sum_dict = {key: sum(values) for key, values in counter_dict.items()}
    counter_group_a = ["M55300C000", "M55300C040", "M55366C010"]
    counter_group_b = ["M55300C010", "M55300C050"]
    total_a = sum_group(counter_group_a, counter_sum_dict, 28)
    total_b = sum_group(counter_group_b, counter_sum_dict, 28)
    if total_a == 0:
        raise ValueError("Total A is zero. Ensure group_a_prefixes match the keys in summed_data.")
    output = 100 * (total_a - total_b) / total_a
    print(output)
    return output


def sum_group(counter_group, sum_dict, range_index):
    """
    Author: anjana.kulkarni@nokia.com
    Date Modified: 20/03/2025

    Sums up values from a dictionary for keys generated using a list of prefixes
    and a range of suffixes.

    Args:
        counter_group (list): A list of string prefixes to generate keys.
        sum_dict (dict): A dictionary containing keys and their respective values.
        range_index (int): The range of suffixes to append to prefixes (from 0 to range_index - 1).

    Returns:
        int: The total sum of values corresponding to the generated keys.

    Example:
        counter_group = ["M55302C"]
        sum_dict = {"M55302C00": 10, "M55302C01": 20, "M55302C02": 30}
        range_index = 3

        total = sum_group(counter_group, sum_dict, range_index)
        print(total)  # Output: 60
    """
    group_total = 0
    for prefix in counter_group:
        for suffix in range(range_index):
            sum = f"{prefix}{suffix:02}"  # Generate key with prefix and two-digit suffixif sum in sum_dict
            if sum in sum_dict:
                group_total += sum_dict[sum]  # Add value from dictionaryelse:
            else:
                print(f"Key not found: {sum}")  # Print missing key for debuggingreturn group_total
    return group_total


def NR_5056b(counter_list, counter_value_list):
    """
    KPI Calculation for NR_5056b
    """
    counter_dict = dict(zip(counter_list, counter_value_list))
    counter_sum_dict = {key: sum(values) for key, values in counter_dict.items()}
    counter_group_a = ["M55302C000", "M55302C060", "M55302C110"]
    counter_group_b = ["M55302C040", "M55302C080", "M55302C130"]
    total_a = sum_group(counter_group_a, counter_sum_dict, 28)
    total_b = sum_group(counter_group_b, counter_sum_dict, 28)
    if total_a == 0:
        raise ValueError("Total A is zero. Ensure group_a_prefixes match the keys in summed_data.")
    output = 100 * (total_a - total_b) / total_a
    print(output)
    return output


def NR_5054a(counter_list, counter_value_list):
    """
    KPI Calculation for NR_5054a
    """
    counter_dict = dict(zip(counter_list, counter_value_list))
    counter_sum_dict = {key: sum(values) for key, values in counter_dict.items()}
    counter_group_a = ["M55300C000", "M55300C040"]
    counter_group_b = ["M55300C010", "M55300C050"]
    total_a = sum_group(counter_group_a, counter_sum_dict, 28)
    total_b = sum_group(counter_group_b, counter_sum_dict, 28)
    if total_a == 0:
        raise ValueError("Total A is zero. Ensure group_a_prefixes match the keys in summed_data.")
    output = 100 * (total_a - total_b) / total_a
    print(output)
    return output
