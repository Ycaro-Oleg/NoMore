import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "label", "stopBtn"]
  static values = {
    duration: { type: Number, default: 1500 },
    breakDuration: { type: Number, default: 300 },
    activeSession: String,
    stopUrl: String
  }

  connect() {
    this.remaining = this.durationValue
    this.running = false
    this.onBreak = false

    if (this.activeSessionValue) {
      this.running = true
      this.tick()
    }
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval)
  }

  start() {
    this.remaining = this.onBreak ? this.breakDurationValue : this.durationValue
    this.running = true
    this.tick()
  }

  stop() {
    this.running = false
    if (this.interval) clearInterval(this.interval)
    this.onBreak = false
    this.remaining = this.durationValue
    this.updateDisplay()
    this.updateLabel("Session ended")
  }

  tick() {
    if (this.interval) clearInterval(this.interval)

    this.updateDisplay()
    this.updateLabel(this.onBreak ? "Break time" : "Stay focused. No distractions.")

    this.interval = setInterval(() => {
      this.remaining--

      if (this.remaining <= 0) {
        clearInterval(this.interval)

        if (this.onBreak) {
          this.onBreak = false
          this.remaining = this.durationValue
          this.updateDisplay()
          this.updateLabel("Break over. Ready for another round?")
        } else {
          this.onBreak = true
          this.remaining = this.breakDurationValue
          this.updateLabel("Work session done! Take a break.")
          this.tick()
        }
        return
      }

      this.updateDisplay()
    }, 1000)
  }

  updateDisplay() {
    const minutes = Math.floor(this.remaining / 60)
    const seconds = this.remaining % 60
    const display = `${String(minutes).padStart(2, "0")}:${String(seconds).padStart(2, "0")}`

    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = display
    }
  }

  updateLabel(text) {
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = text
    }
  }
}
