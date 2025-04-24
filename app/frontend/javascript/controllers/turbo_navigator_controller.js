import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    url: String,
    frame: String,
  };

  visit() {
    if (this.hasUrlValue) {
      if (this.hasFrameValue && window.Turbo) {
        const frame = document.getElementById(this.frameValue);
        if (frame) {
          frame.src = this.urlValue;
        } else {
          window.Turbo.visit(this.urlValue);
        }
      } else {
        window.Turbo.visit(this.urlValue);
      }
    }
  }
}
