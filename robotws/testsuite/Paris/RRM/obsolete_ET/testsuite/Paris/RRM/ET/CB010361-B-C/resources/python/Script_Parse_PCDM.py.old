import os
import re
import openpyxl
import subprocess
import sys

##########################################################################################
# 1. Function to create Template_protocol_v1.xlsx with feature as argument CB010361_B, CB010361_C
##########################################################################################


def create_excel_file(feature_ID):
    # Define the data for each feature_ID
    data_CB010361_B_HI_UL_FR1_FDD_SA = [
        ["protocol_name", "protocol_description", "Feature"],
        [
            "DuVendorExtensionRecordDataType: ulRbHighRlcMeasRecord",
            "numOfRlcSduRx",
            "CB010361-B",
        ],
        [
            "DuVendorExtensionRecordDataType: ulRbHighRlcMeasRecord",
            "sumOfRlcSduRxBytes",
            "CB010361-B",
        ],
    ]
    data_CB010361_B_HI_DL_FR1_FDD_NSA = [
        ["protocol_name", "protocol_description", "Feature"],
        [
            "DuVendorExtensionRecordDataType: dlRbHighRlcMeasRecord",
            "numOfRlcSduTx",
            "CB010361-B",
        ],
        [
            "DuVendorExtensionRecordDataType: dlRbHighRlcMeasRecord",
            "sumOfRlcSduTxBytes",
            "CB010361-B",
        ],
    ]
    data_CB010361_B_LO_DL_FR1_FDD_SA_CA = [
        ["protocol_name", "protocol_description", "Feature"],
        [
            "DuVendorExtensionRecordDataType: dlRbRlcMeasRecord",
            "numOfRlcPduTx",
            "CB010361-B",
        ],
        [
            "DuVendorExtensionRecordDataType: dlRbRlcMeasRecord",
            "numOfReTx",
            "CB010361-B",
        ],
        [
            "DuVendorExtensionRecordDataType: caSCellDlRbRlcMeasRecord",
            "numOfRlcPduTx",
            "CB010361-B",
        ],
        [
            "DuVendorExtensionRecordDataType: caSCellDlRbRlcMeasRecord",
            "numOfReTx",
            "CB010361-B",
        ],
        [
            "DuVendorExtensionRecordDataType: caSCellUlRbRlcMeasRecord",
            "numOfRlcPduRx",
            "CB010361-B",
        ],
        [
            "DuVendorExtensionRecordDataType: caSCellUlRbRlcMeasRecord",
            "numOfReTx",
            "CB010361-B",
        ],
    ]
    data_CB010361_B_LO_UL_FR1_FDD_NSA_CA = [
        ["protocol_name", "protocol_description", "Feature"],
        [
            "DuVendorExtensionRecordDataType: ulRbRlcMeasRecord",
            "numOfRlcPduRx",
            "CB010361-B",
        ],
        [
            "DuVendorExtensionRecordDataType: ulRbRlcMeasRecord",
            "numOfReTx",
            "CB010361-B",
        ],
    ]
    data_CB010361_C = [
        ["protocol_name", "protocol_description", "Feature"],
        [
            "CuUpVendorExtensionRecordDataType: dlRbPdcpMeasRecord",
            "numOfPdcpSduTx",
            "CB010361-C",
        ],
        [
            "CuUpVendorExtensionRecordDataType: dlRbPdcpMeasRecord",
            "numOfPdcpSduTxDiscarded",
            "CB010361-C",
        ],
        [
            "CuUpVendorExtensionRecordDataType: ulRbPdcpMeasRecord",
            "numOfPdcpSduRx",
            "CB010361-C",
        ],
        [
            "CuUpVendorExtensionRecordDataType: ulRbPdcpMeasRecord",
            "numOfPdcpSduRxDiscarded",
            "CB010361-C",
        ],
    ]
    # Select the data based on the feature_ID argument
    if feature_ID == "data_CB010361_B_HI_UL_FR1_FDD_SA":
        data = data_CB010361_B_HI_UL_FR1_FDD_SA
    elif feature_ID == "data_CB010361_B_HI_DL_FR1_FDD_NSA":
        data = data_CB010361_B_HI_DL_FR1_FDD_NSA
    elif feature_ID == "data_CB010361_B_LO_DL_FR1_FDD_SA_CA":
        data = data_CB010361_B_LO_DL_FR1_FDD_SA_CA
    elif feature_ID == "data_CB010361_B_LO_UL_FR1_FDD_NSA_CA":
        data = data_CB010361_B_LO_UL_FR1_FDD_NSA_CA
    elif feature_ID == "CB010361_C":
        data = data_CB010361_C
    else:
        print("Invalid feature_ID specified. Please use 'CB010361_B' or 'CB010361_C'.")
        return

    # Create a new Excel file
    workbook = openpyxl.Workbook()
    sheet = workbook.active
    sheet.title = "protocol"

    # Write the data to the sheet
    for row in data:
        sheet.append(row)

    # Save the file
    workbook.save("Template_protocol_v1.xlsx")
    print(
        f"File 'Template_protocol_v1.xlsx' created successfully with data from {feature_ID}."
    )


create_excel_file(sys.argv[2])

##########################################################################################
# 2. Function to Convert_PCAP_file_to_PDML_with_filter
##########################################################################################
# Define the command to run
my_wireshark_file = sys.argv[1]
TCE_PORT = 49148
command = (
    r'"/usr/bin/tshark" -r {} -Y "nsetapx" -T pdml '
    r"-o ntrstr.defragment:TRUE -o ntrstr.port:{} > nsetapx.pdml".format(
        my_wireshark_file, TCE_PORT
    )
)

# Run the command using subprocess
subprocess.run(command, shell=True)

# Print a success message
print("Command executed successfully. Output saved to nsetapx.pdml")


##########################################################################################
# 3. Function to parse the trace file
##########################################################################################
def parse_trace(file_path):
    data = []
    with open(file_path, "r") as f:
        start = False
        col01 = ""  # Initialize col01 outside of the loop to avoid UnboundLocalError
        col02 = ""  # Initialize col02 outside of the loop to avoid UnboundLocalError
        # Compile a regex pattern to match the protocol names dynamically
        protocol_pattern = re.compile(r'<field name="([^"]+)" showname="([^"]+)"')
        for line in f:
            # Check for the start of a new protocol block
            protocol_match = protocol_pattern.search(line.strip())
            if protocol_match:
                protocol_name = protocol_match.group(1)
                # Check if the protocol name starts with 'nsetapx.'
                if protocol_name.startswith("nsetapx."):
                    start = True
                    if "nsetapx.DuVendorExtensionRecordDataType" in line:
                        col01 = "nsetapx.DuVendorExtensionRecordDataType"
                        showname_txt = line.split('showname="')[1]
                        showname = showname_txt.split('"')[0]
                        col02 = showname
                    if "nsetapx.CuVendorExtensionRecordDataType" in line:
                        col01 = "nsetapx.CuVendorExtensionRecordDataType"
                        showname_txt = line.split('showname="')[1]
                        showname = showname_txt.split('"')[0]
                        col02 = showname
                    if "nsetapx.CuUpVendorExtensionRecordDataType" in line:
                        col01 = "nsetapx.CuUpVendorExtensionRecordDataType"
                        showname_txt = line.split('showname="')[1]
                        showname = showname_txt.split('"')[0]
                        col02 = showname
            if start:
                # Check for field lines within the protocol block
                if "<field" in line and 'name="' in line:
                    field_txt = line.split('name="')[1]
                    field_name = field_txt.split('"')[0]
                    # Secure the check for 'showname' and 'value' attributes
                    showname = ""
                    value = ""
                    if 'showname="' in line:
                        showname_txt = line.split('showname="')[1]
                        showname = showname_txt.split('"')[0]
                    if 'value="' in line:
                        value_txt = line.split('value="')[1]
                        value = value_txt.split('"')[0]
                    # Append the formatted data as per the user's request
                    data.append(
                        f"{col01}---{col02}---{field_name}---{showname}---{value}"
                    )
            # Check for the end of the protocol block
            if "</field>" in line and "nsetapx" in line and start:
                start = False
    return data


# Get the current working directory
SCRIPTDIR = os.getcwd()
print("Current directory:", SCRIPTDIR)

# Define the path to the input file
txtfile = os.path.join(SCRIPTDIR, "nsetapx.pdml")
print("Processing", txtfile, "...\n")

# Parse the trace file
parsed_data = parse_trace(txtfile)

# Write the results to a file
output_file = os.path.join(SCRIPTDIR, "parsed_results.txt")
with open(output_file, "w") as file:
    for line in parsed_data:
        file.write(line + "\n")

# Print a success message
print("The results are saved in 'parsed_results.txt'.\n")

##########################################################################################
# 4. Function to check in parsed_results.txt protocol found or not and write txt files
##########################################################################################

wb_tamplate_xlsx = openpyxl.load_workbook("Template_protocol_v1.xlsx")
protocol_Sheet = wb_tamplate_xlsx["protocol"]
i = 0
protocol_key_list = [[], []]

row_max_keywords = len(protocol_Sheet["A"])
for i in range(2, row_max_keywords + 1):
    col_protocol_name = protocol_Sheet.cell(row=i, column=1).value
    col_protocol_description = protocol_Sheet.cell(row=i, column=2).value
    protocol_key_list[0].append(col_protocol_name)
    protocol_key_list[1].append(col_protocol_description)


def check_protocol(protocol_key_list):
    input_file = "parsed_results.txt"  # Path to input file
    tmp_file_protocol_found = "tmp_file_protocol_found.txt"
    tmp_file_protocol_not_found = "tmp_file_protocol_not_found.txt"

    # Open the temporary file for writing
    with open(tmp_file_protocol_found, "w") as tmp_input_file:
        print(f"Processing {input_file} to check protocol found or not ...\n")

        # Open the input file for reading
        with open(input_file, "r") as f:
            lines = f.readlines()

        # Initialize a list to keep track of unmatched protocols
        unmatched_protocols = []

        # Check each pair of protocol keys
        for i in range(len(protocol_key_list[0])):
            protocol_found = False
            for line in lines:
                if protocol_key_list[0][i] in line and protocol_key_list[1][i] in line:
                    # Split the line and check the value after the dynamic key
                    parts = line.split("---")
                    for part in parts:
                        if protocol_key_list[1][i] in part:
                            split_part = part.split(": ")
                            if len(split_part) > 1:
                                try:
                                    value = int(split_part[1])
                                    if value > 0 or (
                                        protocol_key_list[1][i] == "numOfPdcpSduRxDiscarded" and value >= 0
                                    ) or (
                                        protocol_key_list[1][i] == "numOfReTx"
                                        and protocol_key_list[0][i]
                                        == "DuVendorExtensionRecordDataType: caSCellUlRbRlcMeasRecord"
                                        and value >= 0
                                    ):
                                        txt = line.strip()  # Remove newline characters from the end of the line
                                        tmp_input_file.write(txt + "---Yes\n")
                                        protocol_found = True
                                        break
                                except ValueError:
                                    # Handle the case where the value is not an integer
                                    pass  # Do nothing when a ValueError occurs
            if not protocol_found:
                # If the protocol was not found, add it to the list of unmatched protocols
                unmatched_protocols.append(f"{protocol_key_list[0][i]}---{protocol_key_list[1][i]}")

    # If there are unmatched protocols, print them
    with open(tmp_file_protocol_not_found, "w") as tmp_file_protocol_not_found:
        if unmatched_protocols:
            print("The following protocols are not in the input file:")
            for protocol in unmatched_protocols:
                print(protocol)
                # Write the protocol and "---No" to the file
                tmp_file_protocol_not_found.write(protocol + "---No\n")


check_protocol(protocol_key_list)

##########################################################################################
# 5. Function to write date to excel file
##########################################################################################


# Function to read the input file and split it into lines and columns
def read_input_file(file_path, delimiter):
    with open(file_path, "r") as file:  # Opens the file in read mode
        lines = file.readlines()  # Reads all the lines from the file
    data = [
        line.strip().split(delimiter) for line in lines
    ]  # Splits each line into columns using the delimiter
    return data  # Returns the data as a list of lists


# Function to write data to an Excel file with a header
def write_to_excel(data, output_file):
    workbook = openpyxl.Workbook()  # Create a new Excel workbook
    sheet = workbook.create_sheet("data")  # Create a new sheet named 'data'

    # Remove default sheet if it's not the active one
    for sheetname in workbook.sheetnames:
        if sheetname != "data":
            workbook.remove(workbook[sheetname])

    # Add the header in the first row
    headers = [
        "protocol_name",
        "protocol_description",
        "field_name",
        "showname",
        "value",
        "protocol_found",
    ]
    sheet.append(headers)  # Append the headers to the first row

    # Write the data starting from the second row
    for row in data:  # Iterate over each row of data
        sheet.append(row)  # Append the row to the sheet

    workbook.save(output_file)  # Save the Excel workbook


# Main function to run the script
def data_to_Excel():
    input_file = "tmp_file_protocol_found.txt"  # Path to input file
    output_file = "parsed_results.xlsx"  # Path to output Excel file
    delimiter = "---"  # Column separator

    data = read_input_file(input_file, delimiter)  # Reads the data from the input file
    write_to_excel(data, output_file)  # Writes the data to the Excel file
    print(
        f"\nData has been successfully written to {output_file}"
    )


data_to_Excel()
