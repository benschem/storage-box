import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["roomSelectWrapper", "boxSelectWrapper", "roomSelect", "boxSelect"];

  toggleBox(event) {
    const noBoxSelected = event.target.value == "";

    if (noBoxSelected) {
      this.boxSelectTarget.disabled = true;
      this.boxSelectTarget.classList.remove("bg-slate-200", "dark:bg-slate-800");
      this.boxSelectTarget.classList.add("bg-slate-50", "dark:bg-slate-900");
      this.boxSelectWrapperTarget.classList.remove("text-slate-950", "dark:text-slate-100");
      this.boxSelectWrapperTarget.classList.add("text-slate-200", "dark:text-slate-800");

      this.roomSelectTarget.disabled = false;
      this.roomSelectTarget.selectedIndex = 0;
      this.roomSelectTarget.classList.remove("bg-slate-50", "dark:bg-slate-900");
      this.roomSelectTarget.classList.add("bg-slate-200", "dark:bg-slate-800");
      this.roomSelectWrapperTarget.classList.remove("text-slate-200", "dark:text-slate-800");
      this.roomSelectWrapperTarget.classList.add("text-slate-950", "dark:text-slate-100");
    }
  }

  toggleRoom(event) {
    const noRoomSelected = event.target.value == "";

    if (noRoomSelected) {
      this.roomSelectTarget.disabled = true;
      this.roomSelectTarget.classList.remove("bg-slate-200", "dark:bg-slate-800");
      this.roomSelectTarget.classList.add("bg-slate-50", "dark:bg-slate-900");
      this.roomSelectWrapperTarget.classList.remove("text-slate-950", "dark:text-slate-100");
      this.roomSelectWrapperTarget.classList.add("text-slate-200", "dark:text-slate-800");

      this.boxSelectTarget.disabled = false;
      this.boxSelectTarget.selectedIndex = 0;
      this.boxSelectTarget.classList.remove("bg-slate-50", "dark:bg-slate-900");
      this.boxSelectTarget.classList.add("bg-slate-200", "dark:bg-slate-800");
      this.boxSelectWrapperTarget.classList.remove("text-slate-200", "dark:text-slate-800");
      this.boxSelectWrapperTarget.classList.add("text-slate-950", "dark:text-slate-100");
    }
  }

  changeRoomToBoxRoom() {
    // const room = this.boxSelectTarget.value; // Box.find(this.boxSelectTarget.value) would need fetch
    // console.log(`Room: ${room}`);
    // this.roomSelectTarget.value = room
  }
}
