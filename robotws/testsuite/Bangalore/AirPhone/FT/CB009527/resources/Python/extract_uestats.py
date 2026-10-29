import re


def extract_numeric_value_from_log(file_path):
    # Regular expression to extract the numeric value (Assuming values are in Mbps or Kbps)
    pattern = r"(\d+(\.\d+)?)\s*(Mbps|Kbps)\s*$"
    # Read the log file
    with open(file_path, 'r') as file:
        data = file.read()
    # Split the data by lines and process each line
    lines = data.split('\n')
    for line in lines:
        match = re.search(pattern, line.strip())
        if match:
            # Convert the numeric part into a float, then truncate it to an integer
            numeric_value = int(float(match.group(1)))  # Convert to float first, then truncate to int
            print(f"Numeric value: {numeric_value} Mbps")
            return numeric_value  # Return the numeric value after truncation
    return None  # Return None if no match found
