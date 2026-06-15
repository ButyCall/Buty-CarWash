const app = document.querySelector('#app');
const slider = document.querySelector('.slider-inner');
const description = document.querySelector('.description');
const percentage = document.querySelector('.percentage');
const packages = document.querySelectorAll('.package');
const buyButton = document.querySelector('#buy-service');

let selectedIndex = 0;
const leftValue = 210;

packages.forEach((item, index) => {
    if (item.classList.contains('active')) {
        selectedIndex = index;
    }
});

function showUI(state) {
    app.style.display = state ? 'block' : 'none';
}

function changeDescription() {
    const currentPackage = packages[selectedIndex];
    if (!currentPackage) return;

    const packageDescription = currentPackage.querySelector('.package-description');
    const packagePercentage = currentPackage.querySelector('.package-percentage');

    description.innerHTML = packageDescription ? packageDescription.innerHTML : '';
    percentage.innerHTML = packagePercentage ? packagePercentage.innerHTML : '';
}

function setActivePackage(index) {
    if (!packages[selectedIndex] || !packages[index]) return;

    packages[selectedIndex].classList.remove('active');
    selectedIndex = index;
    packages[selectedIndex].classList.add('active');

    changeDescription();
}

function onLeftClick() {
    if (selectedIndex === 0) {
        slider.style.left = `-${(packages.length - 2) * leftValue}px`;
        setActivePackage(packages.length - 1);
        return;
    }

    if (selectedIndex === 1) {
        slider.style.left = `${leftValue}px`;
        setActivePackage(selectedIndex - 1);
        return;
    }

    slider.style.left = `-${(selectedIndex - 2) * leftValue}px`;
    setActivePackage(selectedIndex - 1);
}

function onRightClick() {
    if (selectedIndex === packages.length - 1) {
        slider.style.left = `${leftValue}px`;
        setActivePackage(0);
        return;
    }

    slider.style.left = `-${selectedIndex * leftValue}px`;
    setActivePackage(selectedIndex + 1);
}

buyButton.addEventListener('click', function () {
    const activePackage = document.querySelector('.package.active');
    if (!activePackage) return;

    const packageValue = activePackage.getAttribute('data-value');

    $.post(`https://${GetParentResourceName()}/wash`, JSON.stringify({
        type: packageValue
    }));

    showUI(false);

    $.post(`https://${GetParentResourceName()}/exit`, JSON.stringify({}));
});

window.addEventListener('message', function (event) {
    const data = event.data || {};

    if (data.type === 'ui') {
        showUI(data.status === true);
    }
});

document.onkeyup = function (data) {
    if (data.which === 27) {
        showUI(false);
        $.post(`https://${GetParentResourceName()}/exit`, JSON.stringify({}));
    }
};

changeDescription();