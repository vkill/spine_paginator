Spine  = @Spine or require('spine')

###

Usage

see https://github.com/vkill/spine_paginator/blob/master/examples/spine_pagination.coffee

###


class Spine.PaginationController extends Spine.Controller

  constructor: ->
    @page ||= 1
    @pagination ||= null

    @model ||= null
    @perPage ||= 10
    @paginateEvent ||= "paginate"

    super

    if typeof(@model.page) isnt 'function'
      throw new Error("not found page function for model")

    @model.bind @paginateEvent, @render
  
  refresh: ->
    @page = 1
    @load()

  toPage: (page)->
    @page = page
    @load()

  load: ->
    @pagination = @model.page(@page, {perPage: @perPage})
    @model.trigger(@paginateEvent)

  render: =>
    if @pagination.records.length > 0
      @html @templateHtml()
    else
      @html @templateHtmlDataEmpty()

  # 
  # custom
  # 
  events:
    'click a[data-page]': 'clickPage'
  

  clickPage: (e)->
    e.preventDefault()

    page = @getPageFromE(e)
    return unless page?
    @toPage(page)
  
  getPageFromE: (e) ->
    $node = $(e.target)
    return null if $node.parent('.disabled, .active').length > 0
    _page = $node.data('page')

    page = null
    switch _page
      when 'first'
        page = @pagination.firstPage()
      when 'prev'
        page = @pagination.currentPage() - 1
      when 'next'
        page = @pagination.currentPage() + 1
      when 'last'
        page = @pagination.lastPage()
      when 'gap'
        page = null
      else
        page = _page
    page
  
  templateHtmlDataEmpty: =>
    ""
  
  templateHtml: ->
    locals = @pagination.locals

    div = $("<div class='pagination pagination-small pull-right'></div>")
    ul = $("<ul></ul>")

    firstLi = $("<li><a href='javascript:void(0);' data-page='first'>first</a></li>").addClass(if locals.hasFirst then '' else 'disabled')
    prevLi = $("<li><a href='javascript:void(0);' data-page='prev'>prev</a></li>").addClass(if locals.hasPrev then '' else 'disabled')
    nextLi = $("<li><a href='javascript:void(0);' data-page='next'>next</a></li>").addClass(if locals.hasNext then '' else 'disabled')
    lastLi = $("<li><a href='javascript:void(0);' data-page='last'>last</a></li>").addClass(if locals.hasLast then '' else 'disabled')

    ul.append(firstLi).append(prevLi)
    for page in locals.pages
      if page.gap
        pageLi = $("<li class='disabled'><a href='javascript:void(0);' data-page='gap'>...</a></li>")
      else
        pageLi = $("<li><a href='javascript:void(0);'' data-page='#{page.number}'>#{page.number}</a></li>").addClass(if page.current then 'active' else '')
      ul.append(pageLi)
    ul.append(nextLi).append(lastLi)

    div.append(ul)

