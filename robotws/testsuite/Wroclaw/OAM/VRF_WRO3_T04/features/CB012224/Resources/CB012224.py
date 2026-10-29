import re


def replace_commas_in_brackets(json_string, replacement):
    # Regular expression to match commas inside square brackets
    pattern = r'\[(.*?)\]'

    # Function to replace commas within square brackets
    def replace_commas(match):
        # Extract the text inside the square brackets
        content = match.group(1)
        # Replace commas with the specified replacement character
        replaced_content = content.replace(',', replacement)
        # Return the content with brackets
        return f'[{replaced_content}]'

    # Substitute commas within brackets using the defined function
    result = re.sub(pattern, replace_commas, json_string)

    return result


def get_list_of_params_for_topp_object():
    params_list = [
        {"parameterName": "acceptedClockClass", "value": ["6"], "operation": "update"},
        {"parameterName": "syncMessageRate", "value": "RATE_64", "operation": "update"},
        {"parameterName": "topMasterList", "value":
            [{"masterIpAddr": "10.11.12.13",
              "maximumNetworkTimingError": "0",
              "phaseErrorComp": "0",
              "topMasterId": "1"}],
         "operation": "update"},
        {"parameterName": "topStandardProfile", "value": "Telecom2008", "operation": "update"},
        {"parameterName": "tuningProfile", "value": "Normal", "operation": "update"}]
    return params_list
