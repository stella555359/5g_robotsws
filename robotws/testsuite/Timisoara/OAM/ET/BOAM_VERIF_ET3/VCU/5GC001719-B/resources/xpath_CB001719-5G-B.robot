*** Variables ***

${userSettings}         //*[@id="user-settings"]/button/span[2]

${signOut}              //*[contains(text(),'Sign out')]

${lockbutton}           xpath=//ui-webem-lock-button[@buttontitle="Lock Xn link(s)"]

${unlockbutton}         xpath=//ui-webem-lock-open-button[@buttontitle="Unlock Xn link(s)"]

${emptylist}            //*[contains(text(),'None of elements match the operation')]

${cancelbutton}         //*[contains(text(),'Cancel')]

${okbutton}             //*[contains(text(),'OK')]

${xnlink1}              //*[contains(text(),'XNLINK-0, 1 / NRADJGNB-0')]

${filter1}              XNLINK-0, 1 / NRADJGNB-0

${xnlink2}              //*[contains(text(),'XNLINK-2 / NRADJGNB-1')]

${filter2}              XNLINK-2 / NRADJGNB-1

${filtertab}             //*[@id="filter-input-field-tree-chips"]

${statuspopup}           //*[@id="toast-container"]