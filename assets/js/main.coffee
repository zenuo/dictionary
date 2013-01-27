"use strict"

class Dictionary

  set: (@raw) ->
    @

  get: ->
    @raw

  reset: ->
    @data = @raw
    @

  filter: (filters...) ->
    _results = {}
    for filter in filters
      _results[filter] = @raw[filter] if @raw[filter]?
    @data = _results
    @

  bullhorn: """<i class="icon-volume-up"></i>"""
  setBullhorn: (@bullhorn) ->
    @

  toHtml: (json = @data, type = false) ->
    switch type
      when false
        out = ""
        tag = false
      when "labels"
        out = """<span class="#{type}"#{if json.title? then " title=\"#{json.title}\"" else ""}">#{json.text}"""
        tag = "span"
      else
        switch json.type
          when "text", "phonetic"
            out = """<div class="#{type}"><span class="#{json.type}">#{json.text}</span>"""
            tag = "div"
          when "url"
            out = json.text
            tag = false
          when "sound"
            out = """<a class="sound" href="#{json.text}" target="_blank">#{@bullhorn}</a>"""
            tag = false
          else
            out = """<div class="#{type} #{json.type}">"""
            tag = "div"
    for key, object of json
      if object instanceof Array
        for value in object
          out += @toHtml value, key
    out += "</#{tag}>" if tag
    out

  constructor: (@raw = {}) ->
    @reset()

class MP3Player

  play: (url) ->
    if @native
      audio = document.createElement "audio"
      audio.src = url
      audio.play()
    else
      if !@player?
        player = document.createElement "div"
        player.style.position = "fixed"
        player.style.top = 0
        player.style.right = 0
        @player = document.body.appendChild player
      @player.removeChild @flash if @flash?
      @flash = document.createElement "embed"
      @flash.src = "//ssl.gstatic.com/dictionary/static/sounds/0/SoundApp.swf"
      @flash.type = "application/x-shockwave-flash"
      @flash.width = "1"
      @flash.height = "1"
      @flash.setAttribute "flashvars", "sound_name=" + encodeURI url
      @flash.setAttribute "wmode", "transparent"
      @player.appendChild @flash
      if window.opera
        @flash.style.display = "none"
        @flash.style.display = "block"
    return

  constructor: ->
    test = document.createElement "audio"
    @native = test? and test.canPlayType and test.canPlayType("audio/mpeg") isnt ""

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
      $.ajax
        url: "https://www.google.com/dictionary/json"
        dataType: "jsonp",
        data:
          q: @query,
          sl: @language,
          tl: @language,
          restrict: "pr,de,sy"
        success: (data) =>
          @onData(data) if nonce is @nonce
    return

  onData: (data)->
    console.log "onData"
    console.log data
    return

  onLoad: ->
    console.log "onLoad"
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
    webDefinitions: false

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

player = new MP3Player()

loading = new Loading()

dictionary = new Delegate

  language: settings.language

  onLoad: ->

  onChangeLanguage: ->
    settings.language = @language
    $("#language").val(@language) if $("#language").val() isnt @language
    return

  onSubmit: ->
    $("#query").val @query
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
    $("#dictionary").html new Dictionary(data).filter("synonyms", "primaries", "webDefinitions").toHtml()
    $("#dictionary>.synonyms>.terms>.text")[0].innerHTML = $("#dictionary>.primaries>.terms>.text")[0].innerHTML if $("#dictionary>.synonyms>.terms>.text")[0]? and $("#dictionary>.primaries>.terms>.text")[0]?
    $("#dictionary a.sound").click (event) ->
      event.preventDefault()
      player.play $(@).attr "href"
      return
    $("#dictionary .synonyms>.related>.terms>span.text").click ->
      dictionary.submit $(@).text()
      return
    $("#dictionary>.webDefinitions a").each ->
      nextlink = $(@).parent().next(".meaning").children "a"
      $(@).hide() if $(@).text() is nextlink.text()
      return
    $("#dictionary .synonyms>.related").hide() if !settings.options.synonyms
    $("#dictionary .example").hide() if !settings.options.examples
    $("#dictionary .webDefinitions").hide() if !settings.options.webDefinitions
    $("#dictionary").show()
    loading.stop()
    return

$(document).ready ->

  for key, value of dictionary.languages
    option = new Option value, key
    option.selected = true if key is dictionary.language
    document.getElementById("language").add option, null

  for option, status of settings.options
    $("#"+option).addClass "active" if status

  window.onhashchange() if location.hash

  $("#language").change ->
    dictionary.changeLanguage $(@).val()

  $("#toggle-options").click ->
    $("#options-wrapper").toggle()

  $("#synonyms").click ->
    settings.options.synonyms = !settings.options.synonyms
    $(".synonyms>.related").toggle()

  $("#examples").click ->
    settings.options.examples = !settings.options.examples
    $(".example").toggle()

  $("#webDefinitions").click ->
    settings.options.webDefinitions = !settings.options.webDefinitions
    $(".webDefinitions").toggle()

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
        url: "http://" + dictionary.language.substr(0, 2) + ".wiktionary.org/w/api.php"
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
