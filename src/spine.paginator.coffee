Spine  = @Spine or require('spine')
Model  = Spine.Model

class Paginator
  @DEFAULT_PER_PAGE = 25
  @MAX_PER_PAGE = null
  @WINDOW = 4
  @OUTER_WINDOW = 0
  @LEFT = 0
  @RIGHT = 0
  
  constructor: (records, @_page, options={}) ->
    @_page = parseInt(@_page)
    @_page = 1 if isNaN(@_page) or @_page <= 0

    @_originalPage = @_page

    @perPage = options.perPage || @constructor.DEFAULT_PER_PAGE
    @perPage = parseInt(@perPage)
    @perPage = @constructor.DEFAULT_PER_PAGE if isNaN(@perPage) or @perPage <= 0

    @maxPerPage = options.maxPerPage || @constructor.MAX_PER_PAGE
    
    @window = options.window || options.inner_window || @constructor.WINDOW
    outer_window = options.outer_window || @constructor.OUTER_WINDOW
    @left = options.left || @constructor.LEFT
    @left = outer_window if @left == 0  
    @right = options.right || @constructor.RIGHT
    @right = outer_window if @right == 0

    @originalRecords = @cloneArray(records)
    @totalCount = @originalRecords.length

    @skipbuildButtonsAndLocals = options.skipbuildButtonsAndLocals

    @records = []
    @buttons = []
    @locals = {}
    
    @per()

  
  per: (num)->
    n = parseInt(num)
    if !isNaN(n) and n > 0
      @perPage = n
      # when perPage changed, reset @_page
      @_page = @_originalPage

    fromN = @offsetValue()
    toN = fromN + @limitValue()
    
    @records = @originalRecords.slice(fromN, toN)

    @buildButtonsAndLocals() unless @skipbuildButtonsAndLocals?
    @
 
  totalPages: ->
    Math.ceil(@totalCount / @limitValue())

  currentPage: -> 
    return @firstPage() unless @limitValue()?
    (@offsetValue() / @limitValue()) + 1
  
  firstPage: -> 1

  isFirstPage: -> @currentPage() == @firstPage()

  lastPage: -> @totalPages()

  isLastPage: -> @currentPage() >= @lastPage()


  pages: ->
    currentPage = @currentPage()
    firstPage = @firstPage()
    lastPage = @lastPage()

    _pages = []
    last = null
    for page in [firstPage..lastPage]
      result = @buildPage(page, last, currentPage, firstPage, lastPage)
      if result.isLeftOuter or result.isRightOuter or result.isInsideWindow
        last = null
      else
        last = 'gap'
      _pages.push result
    _pages

  curPage: ->
    currentPage = @currentPage()
    firstPage = @firstPage()
    lastPage = @lastPage()
    @buildPage(currentPage, null, currentPage, firstPage, lastPage)

  
  # private

  limitValue: ->
    @perPage = @totalCount if @perPage > @totalCount
    @perPage = @maxPerPage if @maxPerPage? and @perPage > @maxPerPage
    @perPage

  offsetValue: ->
    totalPages = @totalPages()
    @_page = totalPages if @_page > totalPages
    (@_page - 1) * @limitValue()

  buildPage: (page, last, currentPage, firstPage, lastPage) ->
    number: page
    isCurrent: page == currentPage
    isFirst: page == firstPage
    isLast: page == lastPage
    isPrev: page == (currentPage - 1)
    isNext: page == (currentPage + 1)
    isLeftOuter: page <= @left
    isRightOuter: (lastPage - page) < @right
    isInsideWindow: Math.abs(currentPage - page) <= @window
    isWasTruncated: last == 'gap'

  buildButtonsAndLocals: ->
    _buttons = []
    _locals = {}

    curPage = @curPage()
    pages = @pages()

    unless curPage.isFirst
      _buttons.push('first')
      _locals.hasFirst = true
    else
      _locals.hasFirst = false

    unless curPage.isFirst
      _buttons.push('prev')
      _locals.hasPrev = true
    else
      _locals.hasPrev = false
    
    _locals.pages = []
    for page in pages
      if page.isLeftOuter or page.isRightOuter or page.isInsideWindow
        if page.isCurrent
          _buttons.push('current')
          _locals.pages.push({number: page.number, current: true})
        else
          _buttons.push(page.number)
          _locals.pages.push({number: page.number, current: false})
        
      else if !page.isWasTruncated
        _buttons.push('gap')
        _locals.pages.push({number: page.number, gap: true})

    unless curPage.isLast
      _buttons.push('next')
      _locals.hasNext = true
    else
      _locals.hasNext = false

    unless curPage.isLast
      _buttons.push('last')
      _locals.hasLast = true
    else
      _locals.hasLast = false

    _locals.first = @firstPage()
    _locals.current = @currentPage()
    _locals.last = @lastPage()

    _locals.numStart = if @records.length == 0 then 0 else @offsetValue() + 1
    _locals.numEnd = @offsetValue() + @records.length
    _locals.numTotal = @totalCount

    @buttons = _buttons
    @locals = _locals

  cloneArray: (array) ->
    (value.clone() for value in array)

Extend =
  _perPaginateRecords: -> @records
  page: (n, options={})-> new Paginator(@_perPaginateRecords(), n, options)
  
Model.Paginator =
  extended: ->
    @extend Extend

Spine.Paginator = Paginator

# Usage
# 
# class App.MyModel extends Spine.Model
#   @extend Spine.Model.Paginator
# 
# App.MyModel.fetch()
# pagination = App.MyModel.page(6).per(10)
# pagination.locals
# 

