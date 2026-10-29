"""
:modified:  26.03.2025
"""
from robot.api.deco import keyword
import re
from robot.api import logger

ROBOT_AUTO_KEYWORDS = False


@keyword('Check Structure Match')
def check_structure_match(info_keys, info_template):
    """
    Compares `info_keys` with `info_template` after removing brackets [x]/[number].
    Used to check black box structure/functions.

    Args:
        info_keys (list): The list of keys to be checked.
        info_template (list): The list of template keys to check against.

    Returns:
        bool: True if all items matched successfully, False otherwise.
        str: A message indicating if duplicate values are found in `info_keys`.

    Raises:
        Warning: If duplicate values are found in `info_keys`.
        Warning: If a key in `info_keys` does not match any key in `info_template`.

    Example:
        >>> info_keys = ['name[1]', 'age[2]', 'location']
        >>> info_template = ['name', 'age', 'location']
        >>> check_info_structure_match(info_keys, info_template)
        True

    Author: szymon.przybylak@nokia.com
    Maintainer: szymon.przybylak@nokia.com
    """

    # Function to remove [x] or [number] from a string
    def clean_item(item):
        return re.sub(r"\[\w+\]|\[\d+\]", "", item).strip()  # Remove [x] and [123] and trim spaces

    # Check for duplicates in info_keys
    if len(info_keys) != len(set(info_keys)):
        logger.warn("? Warning: Duplicate values found in info_keys!")
        return "Duplicate values found in info_keys!"
    logger.info(f"No duplicate values found in info_keys.")

    # Clean both lists (keys and template)
    cleaned_keys = [clean_item(item) for item in info_keys]
    cleaned_template = [clean_item(item) for item in info_template]

    logger.info(f"Cleaned info_keys: {cleaned_keys}")
    logger.info(f"Info_template: {cleaned_template}")

    # Check if all keys exist in the template
    for key in cleaned_keys:
        if key not in cleaned_template:
            logger.warn(f"? FAIL: No match found for '{key}' in template!")
            return f"No match found for '{key}' in template!"

    logger.info("All items matched successfully.")
    return True
