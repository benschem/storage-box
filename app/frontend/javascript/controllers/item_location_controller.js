import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["roomSelectWrapper", "roomSelect"];

  toggle(event) {
    const boxSelected = event.target.value !== "";

    if (boxSelected) {
      this.roomSelectWrapperTarget.classList.add("hidden");
      this.roomSelectTarget.selectedIndex = 0;
    } else {
      this.roomSelectWrapperTarget.classList.remove("hidden");
    }
  }
}
