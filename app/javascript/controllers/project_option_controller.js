import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["existingSection", "newSection"]

  connect() {
    this.toggleSections()
  }

  toggle(event) {
    this.toggleSections()
  }

  toggleSections() {
    const existingRadio = this.element.querySelector('input[value="existing"]')
    const newRadio = this.element.querySelector('input[value="new"]')
    
    if (existingRadio.checked) {
      this.existingSectionTarget.classList.remove('hidden')
      this.newSectionTarget.classList.add('hidden')
    } else if (newRadio.checked) {
      this.existingSectionTarget.classList.add('hidden')
      this.newSectionTarget.classList.remove('hidden')
    }
  }
}