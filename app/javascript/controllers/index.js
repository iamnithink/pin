import { application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-loading"

const context = require.context("./", true, /_controller\.js$/)
application.load(definitionsFromContext(context))

