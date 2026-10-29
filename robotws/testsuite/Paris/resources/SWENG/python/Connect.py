import Hosts
import StringTool
from collections import OrderedDict

# HOST connection to EPCSIM. It is created at minima, then updated at Suite Setup time
HOST_EPCSIM = Hosts.Host(alias="EPCSIM", isSudo=True)


# =================================================================================================
# GNB_DU, GNB_CU, AP_DU, AP_CU global variables are now built dynamically thru dynamic discovery
# mechanism. Due to that, they are defined as global variables in robot part (Suite Setup)
# So, here are functions to access to them in python part
# =================================================================================================
def AP_DU():
    return StringTool.getRobotVar("AP_DU")


def AP_CU():
    return StringTool.getRobotVar("AP_CU")


def TGNB_DU(index=0):
    return StringTool.getRobotVar("TGNB_DU[{}]".format(index))


def TGNB_CU(index=0):
    return StringTool.getRobotVar("TGNB_CU[{}]".format(index))


# Dictionary to store multiple Host objects. use on multiple wts (virtual machines)
# but can be used on a single wts (virtual machine) as well.
DicHOSTSwts = {}


def initialize_hosts(nbVMwts):
    """
    Initializes multiple Host instances based on the number of virtual machines (${nbVMwts}).
    :param nbVMwts: Number of virtual machines to create.
    This is a specific version for MWTS (Multi WTS -Wireless Test System-) entities.
    """
    global DicHOSTSwts
    DicHOSTSwts = OrderedDict()  # Use OrderedDict to ensure order
    for i in range(nbVMwts):
        alias = f"VMwts_{i+1}"
        DicHOSTSwts[alias] = Hosts.Host(alias=alias, isSudo=True)
    print(f"DEBUG: DicHOSTSwts initialized: {DicHOSTSwts}")


def get_host(alias):
    """
    Returns the Host object corresponding to the given alias.
    """
    return DicHOSTSwts.get(alias, None)


def remove_host(alias):
    """
    Removes a Host object from the dictionary.
    """
    if alias in DicHOSTSwts:
        del DicHOSTSwts[alias]
    else:
        raise ValueError(f"Host with alias '{alias}' does not exist.")


def add_host_to_dictionary(alias, host_object):
    """
    Adds a Host object to the DicHOSTSwts dictionary, ensuring it is always added in the last position.

    :param alias: The alias of the Host object to add.
    :param host_object: The Host object to add to the dictionary.
    """
    global DicHOSTSwts

    # Remove the alias if it already exists to reinsert it at the end
    if alias in DicHOSTSwts:
        DicHOSTSwts.pop(alias)

    # Add the Host object to the dictionary in the last position
    DicHOSTSwts[alias] = host_object

    print(f"DEBUG: Added host '{alias}' to DicHOSTSwts in the last position: {DicHOSTSwts}")


def get_alias_by_index(index):
    """
    Retrieves the alias of a host based on its index in the DicHOSTSwts dictionary.
    """
    if index < 0 or index >= len(DicHOSTSwts):
        raise IndexError(f"Index {index} out of range. The dictionary contains {len(DicHOSTSwts)} elements.")
    # Use the order of keys in OrderedDict
    keys = list(DicHOSTSwts.keys())
    return keys[index]


def update_host_and_alias_by_index(index, new_host_object, new_host_alias):
    """
    Updates a Host object and its alias in the DicHOSTSwts dictionary while preserving the original order.
    :param index: Index of the Host object in the dictionary.
    :param new_host_object: New Host object to insert.
    :param new_host_alias: New alias to associate with the Host object.
    """
    global DicHOSTSwts
    if index < 0 or index >= len(DicHOSTSwts):
        raise IndexError(f"Index {index} out of range. The dictionary contains {len(DicHOSTSwts)} elements.")

    # Convert the dictionary keys into an ordered list
    keys = list(DicHOSTSwts.keys())
    old_alias = keys[index]

    # Create a temporary copy of the OrderedDict
    temp_dict = OrderedDict()

    # Iterate through the keys and rebuild the dictionary, inserting the new element at the correct position
    for i, key in enumerate(keys):
        if i == index:
            # Insert the new alias and object at the original position
            temp_dict[new_host_alias] = new_host_object
        elif key != old_alias:
            # Keep the other elements
            temp_dict[key] = DicHOSTSwts[key]

    # Replace DicHOSTSwts with the temporary dictionary
    DicHOSTSwts = temp_dict

    print(f"DEBUG: Updated host at index {index} with alias '{new_host_alias}' and object {new_host_object}")
