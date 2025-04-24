import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form"];

  connect() {
    console.log("connected to sort");
  }

  submit() {
    console.log("hello from sort#submit");

    // Using Turbo requestSubmit() for seamless submission without a full reload
    this.formTarget.requestSubmit();
  }
}
