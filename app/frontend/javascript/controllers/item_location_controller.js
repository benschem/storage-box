import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["roomSelectWrapper", "boxSelectWrapper", "roomSelect", "boxSelect"];

  toggleBox(event) {
    const noBoxSelected = event.target.value == "";

    if (noBoxSelected) {
      this.roomSelectWrapperTarget.classList.remove("hidden");
      this.boxSelectWrapperTarget.classList.add("hidden");
      this.roomSelectTarget.selectedIndex = 0;
    }
  }
  toggleRoom(event) {
    const noRoomSelected = event.target.value == "";

    if (noRoomSelected) {
      this.roomSelectWrapperTarget.classList.add("hidden");
      this.boxSelectWrapperTarget.classList.remove("hidden");
      this.boxSelectTarget.selectedIndex = 0;
    }
  }
}
