document.getElementById("menu").addEventListener(
  "click",
  () => {
    var menuDropdown = document.getElementById("menu-dropdown")
    var isHidden = menuDropdown.hidden

    menuDropdown.hidden = !isHidden
  },
  false
)
