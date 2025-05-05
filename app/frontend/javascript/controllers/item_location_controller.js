import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["radioButton", "roomSelectWrapper", "boxSelectWrapper", "roomSelectInput", "boxSelectInput"];

  toggle() {
    const selected = this.radioButtonTargets.find((radio) => radio.checked);
    if (!selected) return;

    const isInBox = selected.value === "true";

    this.#toggleBoxInput();
    this.boxSelectInputTarget.disabled = !isInBox;

    this.#toggleRoomInput();
    this.roomSelectInputTarget.disabled = isInBox;
  }

  #toggleBoxInput() {
    this.#toggleInputClasses(this.boxSelectInputTarget);
    this.#toggleWrapperClasses(this.boxSelectWrapperTarget);
  }

  #toggleRoomInput() {
    this.#toggleInputClasses(this.roomSelectInputTarget);
    this.#toggleWrapperClasses(this.roomSelectWrapperTarget);
  }

  #toggleWrapperClasses(wrapper) {
    wrapper.classList.toggle("hidden");
  }

  #toggleInputClasses(input) {
    input.classList.toggle("hidden");
  }
}
