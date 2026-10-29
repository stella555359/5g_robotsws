*** Variables ***

${performanceButton}    //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...                    webem-page-navigation-menu/ui-webem-side-bar-menu/
...                     div/div/div[1]/a[4]/i

${dates_table}  xpath=//*[@id="pmTable"]/div/div/div[1]/div[2]/table/tbody/tr[@class='ng-star-inserted']
${valuestabel}  xpath=//*[@id="pmTable"]/div/div/div[2]/div[2]/table/tbody/tr[@class='ng-star-inserted']
${erasebutton}  xpath=/html/body/p-dynamicdialog/div/div/div/oam-pm-select-counters-modal/div[1]/div/div[2]/
...             div[2]/div[1]/div[2]/ui-webem-button[1]/p-button/button

${counter}   xpath=/html/body/p-dynamicdialog/div/div/div/oam-pm-select-counters-modal/div[1]/div/div[1]/
...          div[2]/ui-webem-panel-split/as-split/div[1]/div/div/oam-network-profile-column/div/div[2]/
...          oam-selection-tree/div/tree-root/tree-viewport/div/div/tree-node-collection/div/tree-node/
...          div/tree-node-children/div/tree-node-collection/div/tree-node[3]/div/tree-node-wrapper/div/
...          div/div/tree-node-content
