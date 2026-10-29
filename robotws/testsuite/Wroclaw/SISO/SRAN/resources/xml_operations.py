from robot.api.deco import keyword
import re


@keyword(name='Extract Target Values')
def extract_target_values(xml_content, regex):
    """
    Extracts target values from XML content using a regular expression.

    This function searches for a pattern defined by the provided regular expression
    within the given XML content. If a match is found, it returns the first captured
    group. If no match is found, it returns None.

    Args:
        xml_content (str): The XML content to search within.
        regex (str): The regular expression pattern to search for.

    Returns:
        str or None: The first captured group if a match is found, otherwise None.

    Example:
        >>> xml_content = '<root><target>Value</target></root>'
        >>> regex = r'<target>(.*?)</target>'
        >>> extract_target_values(xml_content, regex)
        'Value'
    """

    match = re.search(regex, xml_content, re.DOTALL)
    if match:
        return match.group(1)
    return None
