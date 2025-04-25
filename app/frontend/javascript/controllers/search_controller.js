import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "house", "room", "box"];
  static values = {
    allRooms: Array,
    allBoxes: Array,
  };

  connect() {
    this.timeout = null;
  }

  submit() {
    clearTimeout(this.timeout);

    // Only submit the form after 300ms of idle typing
    this.timeout = setTimeout(() => {
      // Using Turbo requestSubmit() for seamless submission without a full reload
      this.formTarget.requestSubmit();
    }, 300);
  }

  updateRoomsAndBoxes() {
    const houseId = this.houseTarget.value;

    const rooms = this.allRoomsValue.filter((room) => room.house_id == houseId);
    this._updateSelect(this.roomTarget, rooms, "All rooms");

    const boxes = this.allBoxesValue.filter((box) => box.house_id == houseId);
    this._updateSelect(this.boxTarget, boxes, "All boxes");
  }

  updateBoxes() {
    const roomId = this.roomTarget.value;
    const boxes = this.allBoxesValue.filter((box) => box.room_id == roomId);
    this._updateSelect(this.boxTarget, boxes, "All boxes");
  }

  submit() {
    this.formTarget.requestSubmit();
  }

  _updateSelect(select, items, promptText) {
    select.innerHTML = "";
    const prompt = document.createElement("option");
    prompt.value = "";
    prompt.textContent = promptText;
    select.appendChild(prompt);

    items.forEach((item) => {
      const option = document.createElement("option");
      option.value = item.id;
      option.textContent = item.name || item.number;
      select.appendChild(option);
    });
  }
}
