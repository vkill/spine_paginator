Spine  = @Spine or require('spine')

###
App = {}

class App.User extends Spine.Model
  @configure 'User', 'name' 
  @extend Spine.Model.Paginator


User = App.User
App.UsersCtrl ||= {}
Ctrl = App.UsersCtrl

Ctrl.IndexPagination extends Spine.PaginationController
  @MODEL = User
  @PER_PAGES = [10, 20, 30, 40]
  @PAGINATE_EVENT = "paginate"

Ctrl.IndexTbody extends Spine.Controller
  constructor: ->
    super
    User.bind Ctrl.IndexPagination.PAGINATE_EVENT, @render
  
  render: =>
    collection = Ctrl.IndexPagination.PAGINATION.records
    @html ""

Ctrl.Index extends Spine.Controller
  constructor: ->
    super
    @tbody = new Ctrl.IndexTbody
      el: @$('tbody')
    @pagination = new Ctrl.IndexPagination
      el: @$('#pagination')
    User.bind 'refresh', @refreshPagination
    
  @refreshPagination ->
    Ctrl.IndexPagination.refresh()


data = ({name: String.fromCharCode(num)} for num in ['a'.charCodeAt(0)..'z'.charCodeAt(0)])
App.User.refresh(data)

###


class Spine.PaginationController extends Spine.Controller

  @MODEL = null
  @PER_PAGES = [10, 20, 30, 40]
  @PAGINATE_EVENT = "paginate"
  
  @PAGE = 1
  @PER_PAGE = null
  @PAGINATION = null

  constructor: ->
    super
    throw new Error("please defined class variable MODEL") unless @constructor.MODEL?
    @constructor.PER_PAGE = @constructor.PER_PAGES[0]
    throw new Error("please defined class variable PER_PAGES") unless @constructor.PER_PAGE?
    @constructor.MODEL.bind @constructor.PAGINATE_EVENT, @render
  
  @refresh: ->
    @PAGE = 1
    @load()

  @toPage: (page)->
    @PAGE = page
    @load()

  @load: ->
    pagination = @MODEL.page(@PAGE, {perPage: @PER_PAGE})
    @PAGINATION = pagination
    @MODEL.trigger(@PAGINATE_EVENT)


  render: =>
    pagination = @constructor.PAGINATION
    if pagination.records.length > 0
      @html @templateHtml()(pagination.locals)
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
    @constructor.toPage(page)
  
  getPageFromE: (e) ->
    $node = $(e.target)
    return null if $node.parent('.disabled, .active').length > 0
    _page = $node.data('page')

    page = null
    switch _page
      when 'first'
        page = @constructor.PAGINATION.firstPage()
      when 'prev'
        page = @constructor.PAGINATION.currentPage() - 1
      when 'next'
        page = @constructor.PAGINATION.currentPage() + 1
      when 'last'
        page = @constructor.PAGINATION.lastPage()
      when 'gap'
        page = null
      else
        page = _page
    page
  
  templateHtmlDataEmpty: =>
    ""

  templateHtml: ->
    source = """
      <div class="pagination pagination-small pull-right">
        <ul>
          <li {{#unless hasFirst}}class="disabled"{{/unless}}>
            <a href="javascript:void(0);" data-page="first">first</a>
          </li>
          <li {{#unless hasPrev}}class="disabled"{{/unless}}>
            <a href="javascript:void(0);" data-page="prev">prev</a>
          </li>
          {{#each pages}}
            {{#if this.gap}}
              <li class="disabled">
                <a href="javascript:void(0);" data-page='gap'>...</a>
              </li>
            {{else}}
              <li {{#if this.current}}class="active"{{/if}}>
                <a href="javascript:void(0);" data-page={{this.number}}>{{this.number}}</a>
              </li>
            {{/if}}
          {{/each}}
          <li {{#unless hasNext}}class="disabled"{{/unless}}>
            <a href='javascript:void(0);' data-page="next">next</a>
          </li>
          <li {{#unless hasLast}}class="disabled"{{/unless}}>
            <a href='javascript:void(0);' data-page="last">last</a>
          </li>
        </ul>
      </div>
    """
    Handlebars.compile(source)
