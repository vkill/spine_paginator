window.App = App = {}

Spine = @Spine

class App.User extends Spine.Model
  @configure 'User', 'name' 
  @extend Spine.Model.Paginator


User = App.User
App.UsersCtrl ||= {}
Ctrl = App.UsersCtrl

class Ctrl.IndexPagination extends Spine.PaginationController
  constructor: ->
    @model = User
    @perPage = 5
    @paginateEvent = "paginate"
    super

  # templateHtml: ->
  #   htmlSource = """
  #     <div class='pagination pagination-small pull-right'>
  #       <ul>
  #         <li {{#unless hasFirst}}class='disabled'{{/unless}}>
  #           <a href='javascript:void(0);' data-page='first'>first</a>
  #         </li>
  #         <li {{#unless hasPrev}}class='disabled'{{/unless}}>
  #           <a href='javascript:void(0);' data-page='prev'>prev</a>
  #         </li>
  #         {{#each pages}}
  #           {{#if this.gap}}
  #             <li class='disabled'>
  #               <a href='javascript:void(0);' data-page='gap'>...</a>
  #             </li>
  #           {{else}}
  #             <li {{#if this.current}}class='active'{{/if}}>
  #               <a href='javascript:void(0);' data-page='{{this.number}}'>{{this.number}}</a>
  #             </li>
  #           {{/if}}
  #         {{/each}}
  #         <li {{#unless hasNext}}class='disabled'{{/unless}}>
  #           <a href='javascript:void(0);' data-page='next'>next</a>
  #         </li>
  #         <li {{#unless hasLast}}class='disabled'{{/unless}}>
  #           <a href='javascript:void(0);' data-page='last'>last</a>
  #         </li>
  #       </ul>
  #     </div>
  #   """
  #   Handlebars.compile(htmlSource)(@pagination.locals)

class Ctrl.IndexTbody extends Spine.Controller
  constructor: ->
    super
    User.bind @owner.pagination.paginateEvent, @render
  
  render: =>
    @html @templateHtml()
   
  templateHtml: =>
    collection = @owner.pagination.pagination.records
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

    @pagination = new Ctrl.IndexPagination
      el: @$('#pagination')
      owner: @

    @tbody = new Ctrl.IndexTbody
      el: @$('tbody')
      owner: @

    User.bind 'refresh', @refreshPagination
    
  refreshPagination: =>
    @pagination.refresh()


$(document).ready ->
  App.UsersCtrl.index = new App.UsersCtrl.Index
    el: '#users'

  data = ({name: String.fromCharCode(num)} for num in ['A'.charCodeAt(0)..'z'.charCodeAt(0)])
  App.User.refresh(data)
