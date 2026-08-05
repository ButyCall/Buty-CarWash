"use strict";

const app = document.getElementById("app");
const buyServiceButton = document.getElementById("buy-service");
const progressElement = document.getElementById("buty-progress");
const progressFill = progressElement.querySelector(".buty-progress-fill");
const progressText = document.getElementById("buty-progress-text");
const progressLines = progressElement.querySelectorAll(".line");

let progressAnimation = null;
let progressHideTimer = null;

function startProgress(text = "Loading...", time = 3000, options = {}) {
  const parsedDuration = Number(time);

  const duration =
    Number.isFinite(parsedDuration) && parsedDuration >= 0
      ? parsedDuration
      : 3000;

  const progressColor =
    typeof options.color === "string" ? options.color : "#00C1FF";

  const progressBackground =
    typeof options.background === "string" ? options.background : progressColor;

  if (progressAnimation) {
    progressAnimation.cancel();
    progressAnimation = null;
  }

  if (progressHideTimer) {
    clearTimeout(progressHideTimer);
    progressHideTimer = null;
  }

  progressText.textContent = String(text || "Loading...");
  progressFill.style.background = progressBackground;

  progressLines.forEach((line) => {
    line.style.background = progressColor;
  });

  progressElement.classList.add("is-visible");
  progressElement.setAttribute("aria-hidden", "false");

  progressAnimation = progressFill.animate(
    [
      {
        transform: "scaleX(0)",
      },
      {
        transform: "scaleX(1)",
      },
    ],
    {
      duration,
      easing: "linear",
      fill: "forwards",
    },
  );

  progressAnimation.onfinish = () => {
    progressHideTimer = setTimeout(() => {
      progressElement.classList.remove("is-visible");
      progressElement.setAttribute("aria-hidden", "true");

      progressFill.style.transform = "scaleX(0)";

      progressAnimation = null;
      progressHideTimer = null;
    }, 400);
  };
}

function setDisplay(visible) {
  const shouldShow = visible === true;

  app.classList.toggle("is-visible", shouldShow);
  app.setAttribute("aria-hidden", String(!shouldShow));
}

function updatePackagePrices(prices) {
  if (!prices) return;

  document
    .querySelectorAll(".package[data-value]")
    .forEach((packageElement) => {
      const packageId = Number(packageElement.getAttribute("data-value"));
      const priceElement = packageElement.querySelector(".price span");

      if (!packageId || !priceElement) return;

      const configuredPrice = Array.isArray(prices)
        ? prices[packageId - 1]
        : (prices[packageId] ?? prices[String(packageId)]);

      const numericPrice = Number(configuredPrice);

      if (!Number.isFinite(numericPrice)) return;

      priceElement.textContent = `$${numericPrice.toLocaleString("en-US")}`;
    });
}

function closeUi() {
  setDisplay(false);

  $.post(`https://${GetParentResourceName()}/exit`, JSON.stringify({}));
}

function select() {
  const activePackage = document.querySelector(".package.active");

  if (!activePackage) return;

  const packageValue = activePackage.getAttribute("data-value");

  $.post(
    `https://${GetParentResourceName()}/wash`,
    JSON.stringify({
      type: packageValue,
    }),
  );

  closeUi();
}

window.addEventListener('message', function (event) {
    const data = event.data || {};

    if (data.type === 'ui') {
        updatePackagePrices(data.prices);
        setDisplay(data.status);
        return;
    }

    if (data.type === 'progress') {
        startProgress(
            data.text,
            data.time,
            data.options || {}
        );
    }
});

document.addEventListener("keyup", function (event) {
  if (event.key === "Escape" && app.classList.contains("is-visible")) {
    closeUi();
  }
});

buyServiceButton.addEventListener("click", select);

buyServiceButton.addEventListener("keyup", function (event) {
  if (event.key === "Enter" || event.key === " ") {
    event.preventDefault();
    select();
  }
});

const slider = document.querySelector(".slider-inner");
const description = document.querySelector(".description");
const percentage = document.querySelector(".percentage");
const packages = document.querySelectorAll(".package");

let selectedIndex = 0;
const leftValue = 210;

packages.forEach((item, index) => {
  if (item.classList.contains("active")) {
    selectedIndex = index;
  }
});

function changeDescription() {
  const currentPackage = packages[selectedIndex];

  if (!currentPackage) return;

  const packageDescription = currentPackage.querySelector(
    ".package-description",
  );
  const packagePercentage = currentPackage.querySelector(".package-percentage");

  description.innerHTML = packageDescription
    ? packageDescription.innerHTML
    : "";

  percentage.innerHTML = packagePercentage ? packagePercentage.innerHTML : "";
}

function setActivePackage(index) {
  packages[selectedIndex].classList.remove("active");

  selectedIndex = index;

  packages[selectedIndex].classList.add("active");

  changeDescription();
}

function updateSliderPosition(direction) {
  if (direction === "left") {
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
    return;
  }

  if (direction === "right") {
    if (selectedIndex === packages.length - 1) {
      slider.style.left = `${leftValue}px`;
      setActivePackage(0);
      return;
    }

    slider.style.left = `-${selectedIndex * leftValue}px`;
    setActivePackage(selectedIndex + 1);
  }
}

function onLeftClick() {
  updateSliderPosition("left");
}

function onRightClick() {
  updateSliderPosition("right");
}

changeDescription();
