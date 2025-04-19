import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["sidebar", "content", "hamburgerIcon", "closeIcon"];

  toggle() {
    this.sidebarTarget.classList.toggle("opacity-100");
    this.sidebarTarget.classList.toggle("hidden");

    if (window.screen.width < 450) {
      this.contentTarget.classList.toggle("blur-xs");
      this.contentTarget.classList.toggle("max-h-[91vh]");
      this.contentTarget.classList.toggle("overflow-y-hidden");
    }

    this.hamburgerIconTarget.classList.toggle("hidden");
    this.closeIconTarget.classList.toggle("hidden");
  }
}
