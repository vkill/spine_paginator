window.App = App = {}

Spine = @Spine

class App.User extends Spine.Model
  @configure 'User', 'name' 
  @extend Spine.Model.Paginator


User = App.User
App.UsersCtrl ||= {}
Ctrl = App.UsersCtrl

class Ctrl.IndexPagination extends Spine.PaginationController
  @MODEL = User
  @PER_PAGES = [5, 10, 20, 30]
  @PAGINATE_EVENT = "paginate"

class Ctrl.IndexTbody extends Spine.Controller
  constructor: ->
    super
    User.bind Ctrl.IndexPagination.PAGINATE_EVENT, @render
  
  render: =>
    @html @templateHtml()
   
  templateHtml: =>
    collection = Ctrl.IndexPagination.PAGINATION.records
    source = """
      {{#each collection}}
        <tr data-id={{this.id}}>
          <td>{{this.id}}</td>
          <td>{{this.name}}</td>
        </tr>
      {{/each}}
    """
    Handlebars.compile(source)({collection: collection})

class Ctrl.Index extends Spine.Controller
  constructor: ->
    super
    @tbody = new Ctrl.IndexTbody
      el: @$('tbody')
    @pagination = new Ctrl.IndexPagination
      el: @$('#pagination')
    User.bind 'refresh', @refreshPagination
    
  refreshPagination: ->
    Ctrl.IndexPagination.refresh()


$(document).ready ->
  App.UsersCtrl.index = new App.UsersCtrl.Index
    el: '#users'

  data = ({name: String.fromCharCode(num)} for num in ['A'.charCodeAt(0)..'z'.charCodeAt(0)])
  App.User.refresh(data)
