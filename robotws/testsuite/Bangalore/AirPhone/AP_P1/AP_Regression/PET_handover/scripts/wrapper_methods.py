from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from itertools import zip_longest
import re
import glob
import os
import xml.etree.ElementTree as ET
from datetime import datetime
import shutil
from taf.sbts.oam.coam.admin import admin
import functools
from retrying import retry
from taf.transport.ssh.exceptions import ConnectFailedError
import time

admin = admin()


def gnb_admin_connection(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        try:
            admin.connect_to()
            return func(*args, **kwargs)
        finally:
            admin.teardown()
    return wrapper


def add_list_entries(list):
    """
    This method takes the list as an input which is a list of list.
    Adds the entries w.r.t its position and returns the sum.
    """
    int_nested = [[int(item) for item in sublist] for sublist in list]
    res = [sum((i)) for i in zip_longest(*int_nested, fillvalue=0)]
    print(res)
    return res


def merge_dictionaries(dict1, dict2):
    """
    This method merges both the input dictionaries which are passed.
    The resultant is also a dictionary
    """
    dict1.update(dict2)
    print(dict1)
    return dict1


def sum_of_list_entries(list):
    """
    This method takes the list as an input which is a list.
    Adds the entries w.r.t its position and returns the sum.
    """
    total = sum(list)
    print(total)
    return total


def NR_5056d(counter_list, counter_value_list, duration):
    """
    KPI Calculation for NR_5056d
    Date Modified: 24/03/2025
    BY: Anjana
    """
    summed_data = convert_lists_to_dictionary(counter_list, counter_value_list)
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


def NR_5054b(counter_list, counter_value_list, duration):
    """
    KPI Calculation for NR_5054b
    Date Modified: 24/03/2025
    BY: Anjana
    """
    summed_data = convert_lists_to_dictionary(counter_list, counter_value_list)
    counter_group_a = ["M55300C000", "M55300C040", "M55366C010"]
    counter_group_b = ["M55300C010", "M55300C050", "M55366C020"]
    total_a = sum_group(counter_group_a, summed_data, 28)
    total_b = sum_group(counter_group_b, summed_data, 28)
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


def NR_5056b(counter_list, counter_value_list, duration):
    """
    KPI Calculation for NR_5056b
    """
    summed_data = convert_lists_to_dictionary(counter_list, counter_value_list)
    counter_group_a = ["M55302C000", "M55302C060", "M55302C110"]
    counter_group_b = ["M55302C040", "M55302C080", "M55302C130"]
    total_a = sum_group(counter_group_a, summed_data, 28)
    total_b = sum_group(counter_group_b, summed_data, 28)
    if total_a == 0:
        raise ValueError("Total A is zero. Ensure group_a_prefixes match the keys in summed_data.")
    output = 100 * (total_a - total_b) / total_a
    print(output)
    return output


def NR_5094a(counter_list, counter_value_list, duration):
    """
    KPI Calculation for NR_5094a
    BY: Rahul
    """
    summed_data = convert_lists_to_dictionary(counter_list, counter_value_list)
    output = 8 * (
        summed_data["M55319C12001"] + summed_data["M55319C12002"] + summed_data["M55319C12003"]
        + summed_data["M55319C12004"] + summed_data["M55319C12005"] + summed_data["M55319C12006"]
        + summed_data["M55319C12007"] + summed_data["M55319C12008"] + summed_data["M55319C12009"]
        + summed_data["M55319C12010"] + summed_data["M55319C12011"] + summed_data["M55319C12012"]
        + summed_data["M55319C12013"] + summed_data["M55319C12014"] + summed_data["M55319C12015"]
        + summed_data["M55319C12016"] + summed_data["M55319C12017"] + summed_data["M55319C12018"]
        + summed_data["M55319C12019"] + summed_data["M55319C12020"]
    ) / (1000 * summed_data["M55319C00001"])

    print(output)
    return output


def NR_5095a(counter_list, counter_value_list, duration):
    """
    KPI Calculation for NR_5095a
    BY: Rahul
    """
    summed_data = convert_lists_to_dictionary(counter_list, counter_value_list)
    output = 8 * (
        summed_data["M55319C16001"] + summed_data["M55319C16002"] + summed_data["M55319C16003"]
        + summed_data["M55319C16004"] + summed_data["M55319C16005"] + summed_data["M55319C16006"]
        + summed_data["M55319C16007"] + summed_data["M55319C16008"] + summed_data["M55319C16009"]
        + summed_data["M55319C16010"] + summed_data["M55319C16011"] + summed_data["M55319C16012"]
        + summed_data["M55319C16013"] + summed_data["M55319C16014"] + summed_data["M55319C16015"]
        + summed_data["M55319C16016"] + summed_data["M55319C16017"] + summed_data["M55319C16018"]
        + summed_data["M55319C16019"] + summed_data["M55319C16020"]
    ) / (1000 * summed_data["M55319C00001"])

    print(output)
    return output


def NR_5128c(counter_list, counter_value_list, duration):
    """
    KPI Calculation for NR_5128c
    Date Modified: 30/04/2025
    BY: Rahul
    """
    summed_data = convert_lists_to_dictionary(counter_list, counter_value_list)
    output = (summed_data["M55138C00008"])
    output = (output)/(duration * 60)
    print(output)
    return output


def NR_5054a(counter_list, counter_value_list, duration):
    """
    KPI Calculation for NR_5054a
    """
    summed_data = convert_lists_to_dictionary(counter_list, counter_value_list)
    counter_group_a = ["M55300C000", "M55300C040"]
    counter_group_b = ["M55300C010", "M55300C050"]
    total_a = sum_group(counter_group_a, summed_data, 28)
    total_b = sum_group(counter_group_b, summed_data, 28)
    if total_a == 0:
        raise ValueError("Total A is zero. Ensure group_a_prefixes match the keys in summed_data.")
    output = 100 * (total_a - total_b) / total_a
    print(output)
    return output


def NR_2193c(counter_list, counter_value_list, duration):
    """
    KPI Calculation for NR_2193c
    Date Modified: 25/03/2025
    BY: Anjana
    """
    summed_data = convert_lists_to_dictionary(counter_list, counter_value_list)
    output = sum(summed_data.get(key, 0) for key in counter_list)
    output = (output)/(duration * 60)
    print(output)
    return output


def NR_2153d(counter_list, counter_value_list, duration):
    """
    KPI Calculation for NR_2153d
    Date Modified: 25/03/2025
    BY: Anjana
    """
    summed_data = convert_lists_to_dictionary(counter_list, counter_value_list)
    output = sum(summed_data.get(key, 0) for key in counter_list)
    output = (output)/(duration * 60)
    print(output)
    return output


def NR_1400c(counter_list, counter_value_list, duration):
    """
    KPI Calculation for NR_1400c
    Date Modified: 25/03/2025
    BY: Anjana
    """
    summed_data = convert_lists_to_dictionary(counter_list, counter_value_list)
    output = sum(summed_data.get(key, 0) for key in counter_list)
    output = (output)/(duration * 60)
    print(output)
    return output


def NR_1401b(counter_list, counter_value_list, duration):
    """
    KPI Calculation for NR_1401b
    Date Modified: 25/03/2025
    BY: Anjana
    """
    summed_data = convert_lists_to_dictionary(counter_list, counter_value_list)
    output = (summed_data["M55125C02504"])
    output = (output)/(duration * 60)
    print(output)
    return output


def NR_1402c(counter_list, counter_value_list, duration):
    """
    KPI Calculation for NR_1402c
    Date Modified: 25/03/2025
    BY: Anjana
    """
    summed_data = convert_lists_to_dictionary(counter_list, counter_value_list)
    output = sum(summed_data.get(key, 0) for key in counter_list)
    output = (output)/(duration * 60)
    print(output)
    return output


def NR_1403d(counter_list, counter_value_list, duration):
    """
    KPI Calculation for NR_1403d
    Date Modified: 25/03/2025
    BY: Anjana
    """
    summed_data = convert_lists_to_dictionary(counter_list, counter_value_list)
    output = sum(summed_data.get(key, 0) for key in counter_list)
    output = (output)/(duration * 60)
    print(output)
    return output


def NR_592a(counter_list, counter_value_list, duration):
    """
    KPI Calculation for NR_592a
    Date Modified: 25/03/2025
    BY: Anjana
    """
    summed_data = convert_lists_to_dictionary(counter_list, counter_value_list)
    output = (summed_data["M55119C01501"])
    output = (output)/(duration * 60)
    print(output)
    return output


def convert_lists_to_dictionary(counter_list, counter_value_list):
    new_dict = dict(zip(counter_list, counter_value_list))
    summed_data = {key: sum(values) for key, values in new_dict.items()}
    return summed_data


def get_nr_tput(cell_stats_nr, dir="DL"):
    """
    Parses NR throughput (DL or UL) per cell from stats text.
    dir: 'dl' for Downlink, 'ul' for Uplink
    Returns a dict: {cell_id: tput_kbps}
    """
    result = {}
    for line in cell_stats_nr.splitlines():
        match = re.match(r'^\s*(\d+)\s+[\d.]+\s+kbps\s+([\d.]+)\s+kbps\s+([\d.]+)\s+kbps\s+([\d.]+)\s+kbps', line)
        if match:
            cid = int(match.group(1))
            if dir == "UL":
                tput_kbps = float(match.group(2))
            elif dir == "DL":
                tput_kbps = float(match.group(4))
            else:
                raise ValueError("Invalid throughput direction: use 'DL' or 'UL'")
            result[cid] = tput_kbps
    return result


def NR_5513(counter_list, counter_value_list, duration):
    """
    Pairing Ration Calculation
    By : Anjana
    """
    summed_data = convert_lists_to_dictionary(counter_list, counter_value_list)
    numerator = (
        1 * summed_data["M55308C34001"] + 2 * (summed_data["M55308C34002"] + summed_data["M55308C34005"])
        + 3 * (summed_data["M55308C34003"] + summed_data["M55308C34006"]) +
        + 4 * (summed_data["M55308C34004"] + summed_data["M55308C34007"]) + 5 * summed_data["M55308C34008"]
        + 6 * summed_data["M55308C34009"]
        + 7 * summed_data["M55308C34010"] + 8 * summed_data["M55308C34011"] + 9 * summed_data["M55308C34016"]
        + 10 * summed_data["M55308C34017"] + 11 * summed_data["M55308C34018"] + 12 * summed_data["M55308C34019"]
        + 13 * summed_data["M55308C34020"] + 14 * summed_data["M55308C34021"] + 15 * summed_data["M55308C34022"]
        + 16 * summed_data["M55308C34023"]
    )
    denominator = (
        summed_data["M55308C34001"] + summed_data["M55308C34002"] + summed_data["M55308C34003"]
        + summed_data["M55308C34004"] + summed_data["M55308C34005"] + summed_data["M55308C34006"]
        + summed_data["M55308C34007"] + summed_data["M55308C34008"] + summed_data["M55308C34009"]
        + summed_data["M55308C34010"] + summed_data["M55308C34011"] + summed_data["M55308C34016"]
        + summed_data["M55308C34017"] + summed_data["M55308C34018"] + summed_data["M55308C34019"]
        + summed_data["M55308C34020"] + summed_data["M55308C34021"] + summed_data["M55308C34022"]
        + summed_data["M55308C34023"]
    )
    output = numerator / denominator / 16
    print(output)
    return output


def calculate_formula(exp, a, b):
    """
    Expression calculation. Where exp is the expression passed, a and b are the args that are to be
    calculated
    By : Anjana
    """
    formatted_expression = exp.format(a=a, b=b)
    print(formatted_expression)
    result = eval(formatted_expression)
    print(result)
    return result


def find_string_between_multiple_files(folder_path, filename_pattern, start_str, end_str):
    """
    Find the detach string from multiple egate_console files
    By : Anjana
    """
    file_paths = glob.glob(os.path.join(folder_path, filename_pattern))
    found = False
    start_token = 'entry=' + start_str
    for file_path in file_paths:
        with open(file_path, 'r') as f:
            content = f.read()

        entry_idx = content.find(start_token)
        if entry_idx == -1:
            continue  # Skip if entry point not found

        # Slice content from entry point onward
        sliced_content = content[entry_idx + len(start_token):]

        # Search for target string only in sliced content
        target_idx = sliced_content.find(end_str)
        if target_idx != -1:
            found = True
    print(found)
    return found


def download_update_and_upload_vendor_file_to_gnb(vendor_filepath='/home/ute'):
    """
    Downloads, Modifies and uploads the vendor file
    By : Anjana
    """
    original_vendor_filepath = os.path.join(vendor_filepath, 'vendor_original.xml')
    modified_vendor_filepath = os.path.join(vendor_filepath, 'vendor_modified.xml')
    print('downloading the vendor file')
    get_vendor_file(original_vendor_filepath)
    print('updating the vendor file')
    shutil.copyfile(original_vendor_filepath, modified_vendor_filepath)
    update_vendor_file(modified_vendor_filepath,
                       {'xEc': '14'})
    upload_vendor_file(modified_vendor_filepath)


@gnb_admin_connection
def get_vendor_file(download_filepath):
    """
    Gets the vendor file via TAF call
    By : Anjana
    """
    vendor_download_response = admin.download_vendor_file(download_filepath)
    print("vendor_download_response:", vendor_download_response)


@gnb_admin_connection
def update_vendor_file(file_path, param_updates):
    """
    Parses the vendor file and modifies the required param
    By : Anjana
    """
    # Parse the XML file
    ns = "raml21.xsd"
    ET.register_namespace('', ns)
    tree = ET.parse(file_path)
    root = tree.getroot()
    # Find and update the parameters
    path = "{ns}cmData//{ns}managedObject[@class='NRBTS']//{ns}p[@name='{name}']"
    for param in param_updates.keys():
        param_list = tree.find(path.format(ns="{" + ns + "}", name=param))
        print("Before update the value at the xml file for {} : {}".format(param, param_list.text))
        param_list.text = param_updates[param]
        print("New value updated at the xml file for {} : {}".format(param, param_list.text))
    # Write the updated XML back to the file
    tree.write(file_path)


@gnb_admin_connection
def upload_vendor_file(modified_vendor_filepath, scf_path="/home/ute/", scf_timeout=60):
    """
    Uploads the vendor file, post modification to gNB
    By : Anjana
    """
    build_id = os.environ.get("BUILD_NUMBER", "0")
    scf_file_name = f"scf_{build_id}.xml"
    scf_dir_path = admin.get_current_scf_file(local_dir_path=scf_path,
                                              file_name=scf_file_name,
                                              timeout=scf_timeout)
    for _ in range(10):
        try:
            print('uploading the vendor file')
            vendor_output = admin.set_vendor_file(modified_vendor_filepath)
            print(f"Vendor file upload output: {vendor_output}")
            time.sleep(180)
            commision_output = admin.perform_commissioning(scf_file=scf_dir_path,
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True, timeout=300)
            print(f"Full commissioning output {commision_output}")
            return
        except Exception as e:
            print(f"ADMIN API Commissioning failed due to {repr(e)}")
            time.sleep(60)
    raise CommisioningFailure("Commisioning Failed")


def NR_5504b(counter_list, counter_value_list, duration):
    """
    KPI Calculation for NR_5056d
    BY: kushal.j
    """
    summed_data = convert_lists_to_dictionary(counter_list, counter_value_list)
    one = (
        1 * summed_data["M55308C35001"] + 2 * summed_data["M55308C35002"] + summed_data["M55308C35003"]
        + 3 * summed_data["M55308C35004"] + 4 * summed_data["M55308C35005"] + 5 * summed_data["M55308C36009"]
        + 6 * summed_data["M55308C36010"] + 7 * summed_data["M55308C36011"] + 8 * summed_data["M55308C36012"])
    two = ((
        summed_data["M55308C35001"] + summed_data["M55308C35002"] + summed_data["M55308C35003"]
        + summed_data["M55308C35004"] + summed_data["M55308C35005"] + summed_data["M55308C36009"]
        + summed_data["M55308C36010"] + summed_data["M55308C36011"] + summed_data["M55308C36012"]))
    output = one / two
    print(output)
    return output


def NR_5513b(counter_list, counter_value_list, duration):
    """
    KPI Calculation for NR_5056d
    BY: kushal.j
    """
    summed_data = convert_lists_to_dictionary(counter_list, counter_value_list)
    output1 = (
        1 * summed_data["M55308C34001"] + 2 * (summed_data["M55308C34002"] + summed_data["M55308C34005"])
        + 3 * (summed_data["M55308C34003"] + summed_data["M55308C34006"])
        + 4 * (summed_data["M55308C34004"] + summed_data["M55308C34007"]) + 5 * summed_data["M55308C34008"]
        + 6 * summed_data["M55308C34009"]
        + 7 * summed_data["M55308C34010"] + 8 * summed_data["M55308C34011"] + 9 * summed_data["M55308C34016"]
        + 10 * summed_data["M55308C34017"] + 11 * summed_data["M55308C34018"] + 12 * summed_data["M55308C34019"]
        + 13 * summed_data["M55308C34020"] + 14 * summed_data["M55308C34021"] + 15 * summed_data["M55308C34022"]
        + 16 * summed_data["M55308C34023"])
    output2 = (
        summed_data["M55308C34001"] + summed_data["M55308C34002"]
        + summed_data["M55308C34003"] + summed_data["M55308C34004"] + summed_data["M55308C34005"]
        + summed_data["M55308C34006"] + summed_data["M55308C34007"] + summed_data["M55308C34008"]
        + summed_data["M55308C34009"] + summed_data["M55308C34010"] + summed_data["M55308C34011"]
        + summed_data["M55308C34016"] + summed_data["M55308C34017"] + summed_data["M55308C34018"]
        + summed_data["M55308C34019"] + summed_data["M55308C34020"] + summed_data["M55308C34021"]
        + summed_data["M55308C34022"] + summed_data["M55308C34023"])
    output = output1 / output2
    print(output)
    return output
