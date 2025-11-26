import { Controller } from "@hotwired/stimulus";

// Keeps tag mode (any/all) in sync with tags[] param
export default class extends Controller {
  static targets = ["any", "all", "tags"];

  toggle(event) {
    const selectedMode = event.target.value; // "any_tags" or "all_tags"

    // Clear any stale param by renaming the tags select input
    if (selectedMode === "any_tags") {
      this.tagsTarget.name = "filter[any_tags][]";
    } else if (selectedMode === "all_tags") {
      this.tagsTarget.name = "filter[all_tags][]";
    }
  }
}
