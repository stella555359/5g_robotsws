import subprocess


def get_global_cell_id_and_nr_cell_identity(data: dict) -> list:
    result = []
    for _, value in data.items():
        for cell_key, cell_value in value.items():
            result.append([cell_key.split('-')[1], cell_value['NRCELL_R']['parameters']['nrCellIdentity']])
    print(result)
    return result


def check_nrdeactivationindication(pdml_file_path: str) -> bool:
    """
    expected part in pdml:
    <field name="x2ap.nrDeactivationIndication" showname="nrDeactivationIndication: deactivated (0)..."
    """
    result = False
    lines = subprocess.check_output(f"cat {pdml_file_path} | grep x2ap.nrDeactivationIndication", shell=True)
    lines = lines.decode("UTF-8")

    for line in lines.split("\n"):
        if len(line) == 0:
            continue

        if "nrDeactivationIndication: deactivated" in line:
            result = True
            break

    return result


def check_nrcellidentifier(pdml_file_path: str, cell: str) -> bool:
    """
    Check if given cell identifier is the same as identifier from pdml file
    """
    result = False
    lines = subprocess.check_output(f"cat {pdml_file_path} | grep nRcellIdentifier", shell=True).decode("UTF-8")

    for line in lines.split("\n"):
        if len(line) == 0:
            continue

        if f"decimal value {cell}" in line:
            result = True
            break

    return result
