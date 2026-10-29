import re


def getPDSCH(egateOutput: str = ""):
    Pattern = r"CellIndex+\-+\d+\s+\d+\.\d+\s+Mbps+\s+\d+\.+\d+\s+Mbps\s+\d+\.+\d+\s+Mbps\s+(\d+\.+\d+)\s+Mbps/gm"
    try:
        lines = egateOutput.split("\n")
        for line in lines:
            cellIndex = re.search(Pattern, line)
            if cellIndex is not None:
                print(cellIndex.group(0))
                print(cellIndex.group(1)+" Mbps")
                if cellIndex.group(1) != 0.0:
                    return 1
                else:
                    return 0

    except Exception as e:
        print(f"Something went wrong. Please check if Evenlis populated correctly in egate console. error here is {e}")
    return 1
