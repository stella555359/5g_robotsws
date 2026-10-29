

def calculate_arfcn_pta(arfcn, arfcn_raster, scs_common, nrb):
    scs_common_value = int(scs_common)
    parenthesized_expression = (nrb // 2) * 12 + 6 * (nrb % 2)
    calculated = int(arfcn) - (parenthesized_expression * scs_common_value) // int(arfcn_raster)
    return calculated


# Example usage
arfcn = 123456
arfcn_raster = 15
scs_common = 30
nrb = 100

arfcn_pta = calculate_arfcn_pta(arfcn, arfcn_raster, scs_common, nrb)
print(f"ARFCN PtA: {arfcn_pta}")
