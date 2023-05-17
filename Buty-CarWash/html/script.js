var app = new Vue({
   el: "#app",
   data: {
      display: false,
   },
   computed: {
      select: function () {
         return () => {
            const activePackage = document.querySelector(".package.active");
            const packageValue = activePackage.getAttribute("data-value");

            $.post(
               `https://${GetParentResourceName()}/wash`,
               JSON.stringify({ type: packageValue })
            );
            app.display = false;
            $.post(
               `https://${GetParentResourceName()}/exit`,
               JSON.stringify({})
            );
         };
      },
   },
});

window.addEventListener("message", (event) => {
   var v = event.data;
   switch (v.type) {
      case "ui":
         app.display = v.status;
         break;
   }
});

document.onkeyup = function (data) {
   if (data.which == 27) {
      $.post(`https://${GetParentResourceName()}/exit`, JSON.stringify({}));
      app.display = false;
      return;
   }
};

const slider = document.querySelector(".slider-inner");
const description = document.querySelector(".description");
const percentage = document.querySelector(".percentage");
const packages = document.querySelectorAll(".package");

var selectedIndex;
const leftValue = 210;

packages.forEach((package, index) => {
   if (package.classList.contains("active")) selectedIndex = index;
});

const changeDescription = () => {
   description.innerHTML = packages[selectedIndex].children[6].innerHTML;
   percentage.innerHTML = packages[selectedIndex].children[7].innerHTML;
};
changeDescription();

const onLeftClick = () => {
   if (selectedIndex == 0) {
      slider.style.left = "-" + (packages.length - 2) * leftValue + "px";
      packages[selectedIndex].classList.remove("active");
      packages[packages.length - 1].classList.add("active");
      selectedIndex = packages.length - 1;
      changeDescription();
      return;
   }
   if (selectedIndex == 1) {
      slider.style.left = leftValue + "px";
      packages[selectedIndex].classList.remove("active");
      packages[selectedIndex - 1].classList.add("active");
      selectedIndex = selectedIndex - 1;
      changeDescription();
      return;
   }
   slider.style.left = "-" + (selectedIndex - 2) * leftValue + "px";
   packages[selectedIndex].classList.remove("active");
   packages[selectedIndex - 1].classList.add("active");
   selectedIndex = selectedIndex - 1;
   changeDescription();
};

const onRightClick = () => {
   if (selectedIndex == packages.length - 1) {
      slider.style.left = leftValue + "px";
      packages[selectedIndex].classList.remove("active");
      packages[0].classList.add("active");
      selectedIndex = 0;
      changeDescription();
      return;
   }
   if (selectedIndex + 1 == packages.length) return;
   slider.style.left = "-" + selectedIndex * leftValue + "px";
   packages[selectedIndex].classList.remove("active");
   packages[selectedIndex + 1].classList.add("active");

   selectedIndex = selectedIndex + 1;
   changeDescription();
};
