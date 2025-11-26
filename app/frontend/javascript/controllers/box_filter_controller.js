import { Controller } from "@hotwired/stimulus";

// When the unboxed checkbox is checked, disable the box select
export default class extends Controller {
  static targets = ["unboxed", "boxed", "boxes"];

  toggleUnboxed(event) {
    if (event.target.checked) {
      // Disable the box select and uncheck boxed
      this.boxesTarget.disabled = true;
      this.boxesTarget.classList.add("opacity-50", "pointer-events-none");
      this.boxedTarget.checked = false;
      this.boxesTarget.value = "";
    } else {
      this.boxesTarget.disabled = false;
      this.boxesTarget.classList.remove("opacity-50", "pointer-events-none");
    }
  }

  toggleBoxed(event) {
    if (event.target.checked) {
      // Ensure unboxed is off
      this.unboxedTarget.checked = false;
      this.boxesTarget.disabled = false;
      this.boxesTarget.classList.remove("opacity-50", "pointer-events-none");
    }
  }

  selectBox(event) {
    if (this.boxesTarget.value) {
      // If user selects a box, force boxed=true and unboxed=false
      this.boxedTarget.checked = true;
      this.unboxedTarget.checked = false;
      this.boxesTarget.disabled = false;
      this.boxesTarget.classList.remove("opacity-50", "pointer-events-none");
    }
  }
}
