*** Variables ***
@{TC_1_expected_cells_without_alarm} =  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-2
...  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-1
@{TC_1_expected_rmods_without_alarm} =  MRBTS-${tl.gnbs[0].global_bts_id}/EQM-1/APEQM-1/ASIRMOD-1
...  MRBTS-${tl.gnbs[0].global_bts_id}/EQM-1/APEQM-1/ASIRMOD-2
@{TC_6_expected_cells_with_alarm} =  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-2
...  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-1
@{TC_6_not_expected_cells_with_alarm} =  @{EMPTY}
