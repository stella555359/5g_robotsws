*** Settings ***
Documentation
...    This file contains general keywords used for testing Feature CB008828.

*** Keywords ***
Configure Additional Slices In Cfg
    wts.Load Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD}
    wts.Insert    sim_param_set EXTENDED_NWSLICE_TEST_MODE=on    before    set_nwslice id=1
    wts.Insert    ${ADDL_25_SLICES_ON_PLMN}    after    sim_param_set
    wts.Insert    ${ADDL_25_SLICES_ON_GNBSIM}    after    sim_param_set
    wts.Save Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD}

Enable Actslicenumext
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Slice_extension/delta_enable_actSliceNumExt.json

Enable 25 Snssai Objects
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Slice_extension/delta_enable_25_Snssai.json
