import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form"];

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
}
