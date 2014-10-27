"use strict"

Key = "AIzaSyDqVYORLCUXxSv7zneerIgC2UYMnxvPeqQ" # Google Drive

class Dictionary

  createElement: (tag, attributes, children) ->
    element = document.createElement tag
    element.setAttribute name, value for name, value of attributes
    if children instanceof Array
      element.appendChild child for child in children
    else if "[object String]" is Object.prototype.toString.call children
      element.innerHTML += children
    element

  createTextNode: (text) ->
    document.createTextNode text

  toHTMLElement: ->
    result = @createElement "div"
    for group in @data
      result.appendChild @createElement "div", {
        class: "displayName"
        "data-type": group.dataType
      }, group.groupResult.displayName

      result.appendChild @createElement "div", {
        class: "dictionary"
        "data-word": group.dictionary.word
        "data-dictionary-type": group.dictionary.dictionaryType
      }, do (definitionsData = group.dictionary.definitionData) =>
        definitions = []
        for definitionData in definitionsData
          definitions.push @createElement "div", {
            class: "definition"
          }, do =>
            definition = []
            for i in ["pos", "phoneticText"]
              if definitionData[i]
                definition.push @createElement "span", {
                  class: i
                }, definitionData[i]
                definition.push @createTextNode " "
            if definitionData.wordForms
              definition.push @createElement "ul", {
                class: "wordForms"
              }, do (wordFormsData = definitionData.wordForms) =>
                wordForms = []
                for wordFormData in wordFormsData
                  wordForms.push @createElement "li", {
                    class: "wordForm"
                  }, [(@createElement "span", {
                        class: "word"
                      }, wordFormData.word),
                      (@createTextNode " "),
                      (@createElement "span", {
                        class: "form"
                      }, wordFormData.form)]
                wordForms
            if definitionData.meanings
              definition.push @createElement "ol", {
                class: "meanings"
              }, do (meaningsData = definitionData.meanings) =>
                meanings = []
                for meaningData in meaningsData
                  meaning = @createElement "li", {
                    class: "meaning"
                  }
                  if meaningData.meaning
                    meaning.appendChild @createElement "div", {
                      class: "meaning"
                    }, meaningData.meaning
                  if meaningData.examples
                    meaning.appendChild @createElement "ul", {
                      class: "examples"
                    }, do (examplesData = meaningData.examples) =>
                      examples = []
                      for exampleData in examplesData
                        examples.push @createElement "li", {
                          class: "example"
                        }, exampleData
                      examples
                  if meaningData.submeanings
                    meaning.appendChild @createElement "ol", {
                      class: "submeanings"
                    }, do (submeaningsData = meaningData.submeanings) =>
                      submeanings = []
                      for submeaningData in submeaningsData
                        submeaning = @createElement "li", {
                          class: "submeaning"
                        }
                        if submeaningData.meaning
                          submeaning.appendChild @createElement "div", {
                            class: "submeaning"
                          }, submeaningData.meaning
                        if submeaningData.examples
                          submeaning.appendChild @createElement "ul", {
                            class: "examples"
                          }, do (examplesData = submeaningData.examples) =>
                            examples = []
                            for exampleData in examplesData
                              examples.push @createElement "li", {
                                class: "example"
                              }, exampleData
                            examples
                        submeanings.push submeaning
                      submeanings
                  if meaningData.synonyms
                    meaning.appendChild @createElement "ul", {
                      class: "synonyms"
                    }, do (synonymsData = meaningData.synonyms) =>
                      synonyms = []
                      for synonymData in synonymsData
                        synonyms.push @createElement "li", {
                          class: "synonym"
                        }, [ @createElement "a", {
                          class: "synonym"
                        }, synonymData.nym ]
                      synonyms
                  meanings.push meaning
                meanings
            definition
        definitions
    result

  constructor: (@data = {}) ->

class Loading

  start: ->
    clearInterval @Interval if @Interval?
    @Interval = setInterval @load, 250
    $("#loading").show()
    @

  load: ->
    active = $("#loading").find(".icon-circle")
    next = active.next()
    next = $($("#loading").find("i")[0]) if !next.length
    active.toggleClass("icon-circle").toggleClass("icon-circle-blank")
    next.toggleClass("icon-circle").toggleClass("icon-circle-blank")
    return

  stop: ->
    $("#loading").hide()
    clearInterval @Interval
    @

class Delegate

  language: "en"

  languages:
    "zh-hans": "Chinese (Simplified)"
    "zh-hant": "Chinese (Traditional)"
    "cs": "Czech"
    "nl": "Dutch"
    "en": "English"
    "fr": "French"
    "de": "German"
    "it": "Italian"
    "ko": "Korean"
    "pt": "Portuguese"
    "ru": "Russian"
    "es": "Spanish"

  onChangeLanguage: ->
    console.log "onChangeLanguage"
    console.log @language
    return
  changeLanguage: (language) ->
    if language of @languages
      @language = language
      @onChangeLanguage()
    @

  onSubmit: ->
    console.log "onSubmit"
    console.log @query
    return
  submit: (@query) ->
    if @onSubmit()
      nonce = ++@nonce
      clearTimeout(@timeout) if @timeout
      @timeout = setTimeout =>
        @onError("Timeout")
      , 3000
      $.ajax
        url: "//www.googleapis.com/scribe/v1/research"
        dataType: "jsonp"
        data:
          key: Key
          dataset: "dictionary"
          dictionaryLanguage: @language
          query: @query
        success: (json) =>
          clearTimeout(@timeout) if nonce is @nonce and @timeout
          @onData(json.data) if nonce is @nonce and json.responseHandled is true
    return

  onData: (data)->
    console.log "onData"
    console.log data
    return

  onLoad: ->
    console.log "onLoad"
    return

  onError: (error) ->
    console.log "onError"
    console.log error
    return

  constructor: (options) ->
    @nonce = 0
    for key, value of options
      @[key] = value
    @onLoad()

# Start

if localStorage?
  settings = localStorage.getItem "dictionary.settings"
  window.onunload = ->
    localStorage.setItem "dictionary.settings", JSON.stringify settings
    return

settings = if settings? then JSON.parse settings else
  language: "en"
  options:
    examples: true
    synonyms: true

title = document.title

separator = "."

window.onhashchange = ->
  hash = decodeURIComponent location.hash.substr 1
  index = hash.lastIndexOf separator
  if index is -1
    dictionary.submit hash if dictionary.query isnt hash
  else
    currentLanguage = dictionary.language
    language = hash.substr index + 1
    query = hash.substr 0, index
    dictionary.changeLanguage language if currentLanguage isnt language
    dictionary.submit query if dictionary.query isnt query or dictionary.language isnt currentLanguage
  return

loading = new Loading()

dictionary = new Delegate

  language: settings.language

  onLoad: ->

  onChangeLanguage: ->
    settings.language = @language
    $("#language").val(@language) if $("#language").val() isnt @language
    return

  onSubmit: ->
    $("#query").blur().val @query
    location.href = "#" + @query + separator + @language
    if @query is ""
      $("#dictionary").hide()
      document.title = title
      $("header").fadeIn "slow"
      false
    else
      $("header").hide()
      $("#dictionary").empty()
      loading.start()
      document.title = @query + " « " + @languages[@language]
      true

  onData: (data) ->
    $("#dictionary").empty().append new Dictionary(data).toHTMLElement()
    $("#dictionary a.synonym").click (event) ->
      dictionary.submit $(@).text()
      return
    for option, value of settings.options
      $("#dictionary ul.#{option}").hide() if value is false
    $("#dictionary").show()
    loading.stop()
    return

  onError: (error) ->
    ###
    $("#dictionary").hide().html("""
    404. <span style="color: gray;">That's an error.</span><br>
    <br>
    Google is doing evil.<br>
    <span style="color: gray;">That's all I know.</span>
    """).fadeIn()
    ###
    return

$(document).ready ->

  for key, value of dictionary.languages
    option = new Option value, key
    option.selected = true if key is dictionary.language
    document.getElementById("language").add option, null

  window.onhashchange() if location.hash

  $("#language").change ->
    dictionary.changeLanguage $(@).val()
    return

  for option, status of settings.options
    $("##{option}").addClass "active" if status
    do (option) ->
      $("##{option}").click ->
        settings.options[option] = !settings.options[option]
        $("#dictionary ul.#{option}").toggle()
        return

  $("#toggle-options").click ->
    $("#options-wrapper").toggle()
    return

  nonce = 0
  lastSubmitNonce = nonce
  $("#submit").submit (event) ->
    event.preventDefault()
    dictionary.submit $("#query").val()
    lastSubmitNonce = nonce++

  lastAjaxACRequestNonce = nonce
  $("#query").typeahead
    source: (query, process) ->
      ajaxACRequestNonce = nonce++
      lastAjaxACRequestNonce = ajaxACRequestNonce
      $.ajax
        url: "//" + dictionary.language.substr(0, 2) + ".wiktionary.org/w/api.php"
        dataType: "jsonp"
        data:
          search: query
          action: "opensearch"
        success: (data) =>
          if lastSubmitNonce < ajaxACRequestNonce and ajaxACRequestNonce is lastAjaxACRequestNonce
              process data[1]
              @$menu.find(".active").removeClass("active")
            else
              process []
            return
      return
    updater: (item) ->
      if item?
        dictionary.submit item
        item
      else
        dictionary.submit @$element.val()
        @$element.val()

  return
