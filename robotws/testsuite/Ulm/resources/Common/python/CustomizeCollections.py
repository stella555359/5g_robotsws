import natsort
import collections
from robot.api import logger


class CustomizeCollections:
    """
    Provides keywords to manipulate collections for Robot Framework.
    """

    def sort_collection_naturally(self, collection):
        """
        Sorts a list or the keys of a dictionary naturally, based on the
        numeric postfix after the last hyphen in the string elements/keys.

        This function uses the `natsort` library for natural sorting.

        Args:
            collection (list or dict): The list or dictionary to be sorted.
                                         Robot Framework automatically converts its lists (@{}) and
                                         dictionaries (&{}) into Python lists and dictionaries.

        Returns:
            list or dict: The sorted list, or a new dictionary with sorted keys.

        Raises:
            TypeError: If the input type is neither a list nor a dictionary.

        Examples of usage in Robot Framework:
        | @{original_list}=    Create List
        | ...   /MRBTS-1/NRBTS-1/NRCELL-1
        | ...   /MRBTS-1/NRBTS-1/NRCELL-4
        | ...   /MRBTS-1/NRBTS-1/NRCELL-3
        | ...   /MRBTS-1/NRBTS-1/NRCELL-2
        | ${sorted_list}=      Sort Collection Naturally    ${original_list}
        | # Result: ['/MRBTS-1/NRBTS-1/NRCELL-1', '/MRBTS-1/NRBTS-1/NRCELL-2',
        | #            '/MRBTS-1/NRBTS-1/NRCELL-3', '/MRBTS-1/NRBTS-1/NRCELL-4']
        |
        | &{original_dict}=    Create Dictionary
        | ...                  /MRBTS-1/NRBTS-1/NRCELL-1=status_1
        | ...                  /MRBTS-1/NRBTS-1/NRCELL-4=status_4
        | ...                  /MRBTS-1/NRBTS-1/NRCELL-3=status_3
        | ...                  /MRBTS-1/NRBTS-1/NRCELL-2=status_2
        | ${sorted_dict}=      Sort Collection Naturally    ${original_dict}
        | # Result: A new dictionary with naturally sorted keys based on the numeric postfix.
        | #         e.g. {'/MRBTS-1/NRBTS-1/NRCELL-1': 'status_1',
        | #               '/MRBTS-1/NRBTS-1/NRCELL-2': 'status_2',
        | #               '/MRBTS-1/NRBTS-1/NRCELL-3': 'status_3',
        | #               '/MRBTS-1/NRBTS-1/NRCELL-4': 'status_4'}
        |
        | # !!! ATTENTION !!! If you want to iterate over the sorted keys in robot afterwards
        | #                   by 'Get Dictionary Keys' use that KW with option 'sort_keys=${False}'.
        | #                   Otherwise 'Get Dictionary Keys' will return keys in alphabetic order!
        |
        """
        # The key function extracts the part after the last hyphen for natural sorting.
        # This aligns with the explicit documentation "The sort is based on the number postfix after the last hyphen."
        def _key_func(x):
            return x.split('-')[-1]

        if isinstance(collection, dict):
            # Retrieve dictionary keys and sort them naturally using natsort and the specified key function.
            sorted_keys = natsort.natsorted(collection.keys(), key=_key_func)
            # Rebuild the dictionary with sorted keys.
            # In Python 3.7+, dictionary insertion order is guaranteed.
            new_dict = {key: collection[key] for key in sorted_keys}
            formatted_log_string = "Naturally Sorted Dictionary: {" + \
                                   ", ".join(f"'{k}': {v}" for k, v in new_dict.items()) + \
                                   "}"
            logger.debug(formatted_log_string)
            return new_dict
        elif isinstance(collection, list):
            # Sort the list directly using natsort and the specified key function.
            return natsort.natsorted(collection, key=_key_func)
        else:
            raise TypeError("Unsupported collection type. Expected a list or a dictionary.")
