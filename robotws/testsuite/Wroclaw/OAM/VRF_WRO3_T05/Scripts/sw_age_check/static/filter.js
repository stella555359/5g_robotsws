document.addEventListener('DOMContentLoaded', function () {
    const table = document.querySelector('table');
    if (!table) return;
    const allRows = Array.from(table.querySelectorAll('tr')).slice(1);
    const filterBar = document.getElementById('filter-bar');

    // Create Node filter UI (options will be populated based on Group later)
    const nodeSelect = document.createElement('select');
    nodeSelect.id = 'nodeFilter';
    const nodeTh = document.getElementById('node-th');
    if (nodeTh) {
        const nodeLabel = document.createElement('label');
        nodeLabel.textContent = 'Node: ';
        nodeLabel.htmlFor = 'nodeFilter';
        nodeLabel.style.marginRight = '0.5em';
        nodeTh.appendChild(nodeLabel);
        nodeTh.appendChild(nodeSelect);
    }

    // Create Role filter UI (options will be populated based on Group later)
    const roleSelect = document.createElement('select');
    roleSelect.id = 'roleFilter';
    const roleTh = document.getElementById('role-th');
    if (roleTh) {
        const roleLabel = document.createElement('label');
        roleLabel.textContent = 'Role: ';
        roleLabel.htmlFor = 'roleFilter';
        roleLabel.style.marginRight = '0.5em';
        roleTh.appendChild(roleLabel);
        roleTh.appendChild(roleSelect);
    }

    // Helper: get rows for a given group selection
    function rowsForGroup(groupValue) {
        return allRows.filter(row => (groupValue === 'All' || row.dataset.group === groupValue));
    }

    // Helper: rebuild options for a select based on values (excludes 'All', added automatically)
    function buildOptionsForSelect(select, values, storageKey) {
        const savedValue = localStorage.getItem(storageKey);
        // Reset options
        while (select.firstChild) select.removeChild(select.firstChild);
        const allOpt = document.createElement('option');
        allOpt.value = 'All';
        allOpt.textContent = 'All';
        select.appendChild(allOpt);
        values.forEach(v => {
            const opt = document.createElement('option');
            opt.value = v;
            opt.textContent = v;
            select.appendChild(opt);
        });
        const allowed = new Set(['All', ...values]);
        const target = (savedValue && allowed.has(savedValue)) ? savedValue : 'All';
        select.value = target;
        localStorage.setItem(storageKey, target);
    }

    // Group filter - place in filter bar (top-left corner)
    const groupValues = Array.from(new Set(allRows.map(row => row.dataset.group))).filter(Boolean).sort();
    let groupSelect = null;
    if (groupValues.length > 0) {
        const values = ['All', ...groupValues];
        groupSelect = document.createElement('select');
        groupSelect.id = 'groupFilter';
        values.forEach(group => {
            const opt = document.createElement('option');
            opt.value = group;
            opt.textContent = group;
            groupSelect.appendChild(opt);
        });

        if (filterBar) {
            const groupContainer = document.createElement('div');
            groupContainer.className = 'filter-group';

            const groupLabel = document.createElement('label');
            groupLabel.textContent = 'Group: ';
            groupLabel.htmlFor = 'groupFilter';

            groupContainer.appendChild(groupLabel);
            groupContainer.appendChild(groupSelect);
            filterBar.appendChild(groupContainer);
        }

        // Restore group selection from localStorage
        const savedGroupFilter = localStorage.getItem('groupFilter');
        if (savedGroupFilter && (savedGroupFilter === 'All' || groupValues.includes(savedGroupFilter))) {
            groupSelect.value = savedGroupFilter;
        }

        // On group change, rebuild Node and Role options and apply filters
        groupSelect.addEventListener('change', function () {
            localStorage.setItem('groupFilter', groupSelect.value);
            rebuildNodeRoleOptions();
            applyFilters();
        });
    }

    // Restore other filters from localStorage (used as preferred defaults during option build)
    const savedNodeFilter = localStorage.getItem('nodeFilter');
    const savedRoleFilter = localStorage.getItem('roleFilter');

    // Build Node and Role options based on current Group selection
    function rebuildNodeRoleOptions() {
        const currentGroup = groupSelect ? groupSelect.value : 'All';
        const rows = rowsForGroup(currentGroup);
        const nodes = Array.from(new Set(rows.map(row => row.cells[0]?.textContent).filter(Boolean))).sort();
        const roles = Array.from(new Set(rows.map(row => row.cells[1]?.textContent).filter(Boolean))).sort();
        buildOptionsForSelect(nodeSelect, nodes, 'nodeFilter');
        buildOptionsForSelect(roleSelect, roles, 'roleFilter');
    }

    // Attach change listeners for node/role (store and filter)
    nodeSelect.addEventListener('change', function () {
        localStorage.setItem('nodeFilter', nodeSelect.value);
        applyFilters();
    });
    roleSelect.addEventListener('change', function () {
        localStorage.setItem('roleFilter', roleSelect.value);
        applyFilters();
    });

    // Initial options build honoring saved filters
    // Temporarily set saved values so buildOptionsForSelect can pick them up
    if (savedNodeFilter) localStorage.setItem('nodeFilter', savedNodeFilter);
    if (savedRoleFilter) localStorage.setItem('roleFilter', savedRoleFilter);
    rebuildNodeRoleOptions();

    // Combined filter logic (includes group)
    function applyFilters() {
        const nodeValue = nodeSelect.value || 'All';
        const roleValue = roleSelect.value || 'All';
        const groupValue = groupSelect ? (groupSelect.value || 'All') : 'All';
        allRows.forEach(row => {
            const nodeMatch = (nodeValue === 'All' || row.cells[0].textContent === nodeValue);
            const roleMatch = (roleValue === 'All' || row.cells[1].textContent === roleValue);
            const groupMatch = (groupValue === 'All' || row.dataset.group === groupValue);
            row.style.display = (nodeMatch && roleMatch && groupMatch) ? '' : 'none';
        });
    }

    // Ensure the "Error" column is visible in the table
    const errorTh = document.createElement('th');
    errorTh.textContent = 'Error';
    const headerRow = table.querySelector('tr');
    if (headerRow) {
        headerRow.appendChild(errorTh);
    }

    // Add a style to the "Error" column for better visibility
    const errorColumnIndex = Array.from(headerRow.children).findIndex(th => th.textContent === 'Error');
    if (errorColumnIndex !== -1) {
        allRows.forEach(row => {
            const errorCell = row.children[errorColumnIndex];
            if (errorCell) {
                errorCell.style.backgroundColor = errorCell.textContent ? '#ffcccc' : '#ccffcc';
            }
        });
    }

    // Apply filters on page load after restoring saved values
    applyFilters();
});
