# Pin npm packages by running ./bin/importmap

pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "marked", to: "https://cdn.jsdelivr.net/npm/marked@12/marked.min.js", preload: false
pin "application"
pin_all_from "app/javascript/controllers", under: "controllers"
