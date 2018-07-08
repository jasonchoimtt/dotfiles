function updateCollapses() {
    for (const label of document.querySelectorAll('.collapse > .label')) {
        if (label.dataset.initialized) continue;

        const main = label.nextElementSibling;

        label.addEventListener('click', () => {
            const shown = main.style.display === 'none';
            if (shown) {
                main.style.display = 'block';
                label.innerHTML = label.innerHTML.replace('[+]', '[-]');
            } else {
                main.style.display = 'none';
                label.innerHTML = label.innerHTML.replace('[-]', '[+]');
            }
        });

        main.style.display = 'none';
        label.dataset.initialized = true;
    }
}


document.documentElement.addEventListener('update', () => {
    updateCollapses();
    console.log('Filter script updated.');
});

document.head.insertAdjacentHTML('beforeend', `
    <style>
        .collapse .main {
            display: none;
            border-left: 1px solid blue; border-right: 1px solid blue;
            margin-left: -8px; margin-right: -8px;
            padding-left: 8px; padding-right: 8px;
        }
        .collapse .label {
            cursor: pointer;
        }
    </style>
`);
