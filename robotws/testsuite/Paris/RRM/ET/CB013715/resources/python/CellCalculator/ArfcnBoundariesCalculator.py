import math


def select_arfcn_scs_guard_band_minus1(nRb, scsSsPbch):
    if scsSsPbch != 240:
        return 0
    if nRb == 66:
        return 22
    if nRb == 132:
        return 46
    if nRb == 264:
        return 95
    return 0


def assert_arfcn_raster(arfcnRaster):
    assert arfcnRaster != 0


def calculate_max_cell_arfcn(arfcnDl, arfcnRaster, nRb, scsCommon):
    assert_arfcn_raster(arfcnRaster)
    return calculate_max_cell_arfcn_algorithm(arfcnDl, arfcnRaster, nRb, scsCommon)


def calculate_max_cell_arfcn_prb_blank(arfcnRaster, scsCommon, nbrOfBlankedPRBsHighEdgeDL, maxCellArfcn):
    return maxCellArfcn - (nbrOfBlankedPRBsHighEdgeDL * 12 * scsCommon // arfcnRaster)


def calculate_min_sc_ss_pbch_arfcn_add_gb(absoluteFrequencySSB, scsSsPbch, arfcnRaster, nRb):
    assert_arfcn_raster(arfcnRaster)
    gscnArfcn = absoluteFrequencySSB
    tmp = gscnArfcn - (120 * scsSsPbch // arfcnRaster)
    return tmp - select_arfcn_scs_guard_band_minus1(nRb, scsSsPbch)


def calculate_max_sc_ss_pbch_arfcn_add_gb(absoluteFrequencySSB, scsSsPbch, arfcnRaster, nRb):
    assert_arfcn_raster(arfcnRaster)
    gscnArfcn = absoluteFrequencySSB
    return gscnArfcn + (119 * scsSsPbch // arfcnRaster) + select_arfcn_scs_guard_band_minus1(nRb, scsSsPbch)


def calculate_min_coreset_arfcn(arfcnDl, absoluteFrequencySSB, arfcnRaster, nRb, scsCommon, scsSsPbch, coresetOffset):
    assert_arfcn_raster(arfcnRaster)
    gscnArfcn = absoluteFrequencySSB
    fraction = 6.0 * scsCommon * (nRb % 2) / arfcnRaster
    firstExpression = arfcnDl - fraction
    bigBracketPart1 = math.ceil((firstExpression - gscnArfcn) * arfcnRaster / (12.0 * scsCommon))
    bigBracketPart2 = 10.0 * scsSsPbch / scsCommon
    bigBracket = bigBracketPart1 + bigBracketPart2 + coresetOffset
    wholeSubtrahend = bigBracket * 12 * scsCommon / arfcnRaster
    return int(firstExpression - wholeSubtrahend)


def calculate_max_coreset_arfcn(minCoresetArfcn, coresetSize, scsCommon, arfcnRaster):
    assert_arfcn_raster(arfcnRaster)
    return minCoresetArfcn + (coresetSize * 12 * scsCommon // arfcnRaster)


def calculate_min_bwp_arfcn(cellArfcn, nrb, crbStartDl, scsCommon, arfcnRaster):
    firstComponent = cellArfcn
    firstExpression = (nrb // 2) * 12
    secondExpression = 6 * (nrb % 2)
    secondComponentMultiplier = (crbStartDl * 12) - firstExpression - secondExpression
    secondComponent = secondComponentMultiplier * (scsCommon // arfcnRaster)
    minBwpArfcn = firstComponent + secondComponent
    return minBwpArfcn


def calculate_min_bwp_arfcns(cellArfcn, bwpProfiles, nrb, scsCommon, arfcnRaster):
    minBwpArfcns = []
    for bwpProfile in bwpProfiles:
        minBwpArfcn = {
            'nrArfcn': calculate_min_bwp_arfcn(cellArfcn, nrb, bwpProfile.get_dl_prb_start(0), scsCommon, arfcnRaster),
            'type': bwpProfile.type
        }
        minBwpArfcns.append(minBwpArfcn)
    return minBwpArfcns


def calculate_max_bwp_arfcn(minBwpArfcn, crbSizeDl, scsCommon, arfcnRaster):
    return minBwpArfcn + (12 * crbSizeDl * (scsCommon // arfcnRaster))


def calculate_max_bwp_arfcns(minBwpArfcns, bwpProfiles, nrb, scsCommon, arfcnRaster):
    assert len(minBwpArfcns) == len(bwpProfiles)
    maxBwpArfcns = []
    for profileIdx in range(len(bwpProfiles)):
        maxBwpArfcn = {
            'nrArfcn': calculate_max_bwp_arfcn(
                minBwpArfcns[profileIdx]['nrArfcn'],
                bwpProfiles[profileIdx].get_dl_prb_size(nrb, nrb).value,
                scsCommon,
                arfcnRaster
            ),
            'type': bwpProfiles[profileIdx].type
        }
        maxBwpArfcns.append(maxBwpArfcn)
    return maxBwpArfcns
