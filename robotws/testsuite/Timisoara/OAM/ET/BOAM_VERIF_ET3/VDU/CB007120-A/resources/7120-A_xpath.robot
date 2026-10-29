*** Variables ***

${CONFIGURATION_MANAGEMENT}  xpath=//*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...                          webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[5]
${INPUT_FILTERS}             xpath=//*[@id="filter-input-field-plans-tree"]
${OKDELETE}                  xpath=//*[@id="webem-parameter-editor-menu-dialog"]/div/div/div[3]/button[2]
${REMOVE_OBJECT}             xpath=//*[@id="webem-parameter-editor-remove-object-overlay-button"]
${PLUS}                      xpath=//*[@id="webem-parameter-editor-add-object-overlay-button"]/i
${INPUT_SYSREQ}              xpath=//*[@id="webem-pe-add-object-classname-dropdown"]/div/div[3]/div[1]/div/input
${MENUDROPDOWN}              xpath=//*[@id="parameter-value/swResetLevel"]/div/span/configuration-shared-input/div/
...                          span[1]/p-dropdown/div/span
${OK_REMOVE_OBJ}             xpath=//*[@id="webem-parameter-editor-menu-dialog"]/div/div/div[3]/button[2]
${OK_PLUS}                   xpath=//*[@id="webem-pe-add-object-ok-button"]/button/span
${SWRESETREQ}                xpath=//*[@id="webem-pe-add-object-classname-dropdown"]/div/div[3]/div[2]/ul/
...                          p-dropdownitem/li/span
${RESETTOTESTLEVEL}          xpath=/html/body/div[3]/div/ul/p-dropdownitem[2]/li/span
${DELETEPLAN}                xpath=//*[@id="webem-parameter-editor-menu-delete-plan-button"]/button/span[2]

${STATUS}                     //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...                           webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[2]


${RADIOMODULES}              xpath=//*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...                             ui-webem-panel-split/as-split/div[2]/div/div/vdu-radio-modules-status/div/
...                            status-shared-operations-view/div[2]/status-shared-tile-grid/div/span/ui-webem-rmod


${CELLS}                     xpath=//*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...                          ui-webem-panel-split/as-split/div[2]/div/div/vdu-cells-status/div/
...                          status-shared-operations-view/div[2]/status-shared-tile-grid/div/
...                          span/ui-webem-vdu-cell-tile
${CHECKBOX1}                xpath=//*[@id="force-plan-activation-despite-reset"]/div/div[2]
${CHECKBOX2}                xpath=//*[@id="force-plan-activation-despite-cell-locking"]/div/div[2]
${WEBEM_HOME}               xpath=//*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...                         webem-page-header/button/div
${RESETVDU}                //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...                        ui-webem-panel-split/as-split/div[2]/div/div/vdu-dashboard/dashboard-container/div/
...                        ngx-gridster/div/ngx-gridster-item[4]/div/div[1]/vdu-dashboard-vdu-operations-widget/
...                        ui-webem-rich-panel/ui-webem-panel/div/div[2]/div/div/div[1]/div[2]/
...                        vdu-dashboard-reset-vdu-button
${OKRESET}                  xpath=//*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...                         ui-webem-panel-split/as-split/div[2]/div/div/vdu-dashboard/p-confirmdialog/div/
...                         div/div[3]/button[2]
${CREATE_PLAN1234}          xpath=//*[@id="webem-root"]/div/div/webem-single-column-layout-with-actions-bar/
...                         webem-page-layout/div/ui-webem-panel-split/as-split/div[2]/div/div/parameter-editor-layout/
...                         ui-webem-panel-split/as-split/div[2]/configuration-plans-tree-panel/div/div/
...                         configuration-plans-configurator/div/tree-root/tree-viewport/div/div/tree-node-collection/
...                         div/tree-node/div/tree-node-children/div/tree-node-collection/div/tree-node/div/
...                         tree-node-children/div/tree-node-collection/div/tree-node/div/tree-node-children/div/
...                         tree-node-collection/div/tree-node/div/tree-node-wrapper/div/div/div[1]
