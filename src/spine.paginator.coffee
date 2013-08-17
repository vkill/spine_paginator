
###
  Usage

  data = ({name: String.fromCharCode(num)} for num in ['a'.charCodeAt(0)..'z'.charCodeAt(0)])
  pagination = new Paginator(data, 2, {perPage: 3})
  pagination.records
  pagination.locals
  pagination.buttons
###

class Paginator
  @DEFAULT_PER_PAGE = 25
  @MAX_PER_PAGE = null
  @WINDOW = 4
  @OUTER_WINDOW = 0
  @LEFT = 0
  @RIGHT = 0

  @PAGE_TEXTS =
    first: 'first'
    prev: 'prev'
    current: 'current'
    next: 'next'
    last: 'last'
    gap: 'gap'
  
  constructor: (records, @_page, options={}) ->
    records = [records] unless isArray(records)
    @originalRecords = records
    @totalCount = @originalRecords.length

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
    isWasTruncated: last == @constructor.PAGE_TEXTS['gap']
  
  curPage: ->
    currentPage = @currentPage()
    firstPage = @firstPage()
    lastPage = @lastPage()
    @buildPage(currentPage, null, currentPage, firstPage, lastPage)

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
        last = @constructor.PAGE_TEXTS['gap']
      _pages.push result
    _pages

  buildButtonsAndLocals: ->
    _buttons = []
    _locals = {}

    curPage = @curPage()
    pages = @pages()

    unless curPage.isFirst
      _buttons.push(@constructor.PAGE_TEXTS['first'])
      _locals.hasFirst = true
    else
      _locals.hasFirst = false

    unless curPage.isFirst
      _buttons.push(@constructor.PAGE_TEXTS['prev'])
      _locals.hasPrev = true
    else
      _locals.hasPrev = false
    
    _locals.pages = []
    for page in pages
      if page.isLeftOuter or page.isRightOuter or page.isInsideWindow
        if page.isCurrent
          _buttons.push(@constructor.PAGE_TEXTS['current'])
          _locals.pages.push({number: page.number, current: true})
        else
          _buttons.push(page.number)
          _locals.pages.push({number: page.number, current: false})
        
      else if !page.isWasTruncated
        _buttons.push(@constructor.PAGE_TEXTS['gap'])
        _locals.pages.push({number: page.number, gap: true})

    unless curPage.isLast
      _buttons.push(@constructor.PAGE_TEXTS['next'])
      _locals.hasNext = true
    else
      _locals.hasNext = false

    unless curPage.isLast
      _buttons.push(@constructor.PAGE_TEXTS['last'])
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

isArray = (value) ->
  Object::toString.call(value) is '[object Array]'

Paginator.isArray = isArray

if @MyPaginatorName?
  @[@MyPaginatorName] = Paginator
else
  @['Paginator'] = Paginator


if @Spine?
  ###
  # Spine Usage

  App = {}

  class App.User extends Spine.Model
    @configure 'User', 'name' 
    @extend Spine.Model.Paginator

  data = ({name: String.fromCharCode(num)} for num in ['a'.charCodeAt(0)..'z'.charCodeAt(0)])

  App.User.refresh(data)
  pagination = App.User.page(2).per(5) #or App.User.page(2, {perPage: 5})
  pagination.records
  pagination.locals
  pagination.buttons
  App.User.PAGINATION = pagination

  ### 
  Paginator.SpineModelExtend =
    page: (n, options={})-> new Paginator(@_perPaginateRecords(), n, options)

    # private
    _perPaginateRecords: -> @all()

  Spine  = @Spine
  Spine.Paginator = Paginator

  Spine.Model.Paginator =
    extended: ->
      @extend Paginator.SpineModelExtend
  





