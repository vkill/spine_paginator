(function() {
  var App, Ctrl, Spine, User, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.App = App = {};

  Spine = this.Spine;

  App.User = (function(_super) {
    __extends(User, _super);

    function User() {
      _ref = User.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    User.configure('User', 'name');

    User.extend(Spine.Model.Paginator);

    return User;

  })(Spine.Model);

  User = App.User;

  App.UsersCtrl || (App.UsersCtrl = {});

  Ctrl = App.UsersCtrl;

  Ctrl.IndexPagination = (function(_super) {
    __extends(IndexPagination, _super);

    function IndexPagination() {
      this.model = User;
      this.perPage = 5;
      this.paginateEvent = "paginate";
      IndexPagination.__super__.constructor.apply(this, arguments);
    }

    return IndexPagination;

  })(Spine.PaginationController);

  Ctrl.IndexTbody = (function(_super) {
    __extends(IndexTbody, _super);

    function IndexTbody() {
      this.templateHtml = __bind(this.templateHtml, this);
      this.render = __bind(this.render, this);      IndexTbody.__super__.constructor.apply(this, arguments);
      User.bind(this.owner.pagination.paginateEvent, this.render);
    }

    IndexTbody.prototype.render = function() {
      return this.html(this.templateHtml());
    };

    IndexTbody.prototype.templateHtml = function() {
      var collection, source;

      collection = this.owner.pagination.pagination.records;
      source = "{{#each collection}}\n  <tr data-id={{this.id}}>\n    <td>{{this.id}}</td>\n    <td>{{this.name}}</td>\n  </tr>\n{{/each}}";
      return Handlebars.compile(source)({
        collection: collection
      });
    };

    return IndexTbody;

  })(Spine.Controller);

  Ctrl.Index = (function(_super) {
    __extends(Index, _super);

    function Index() {
      this.refreshPagination = __bind(this.refreshPagination, this);      Index.__super__.constructor.apply(this, arguments);
      this.pagination = new Ctrl.IndexPagination({
        el: this.$('#pagination'),
        owner: this
      });
      this.tbody = new Ctrl.IndexTbody({
        el: this.$('tbody'),
        owner: this
      });
      User.bind('refresh', this.refreshPagination);
    }

    Index.prototype.refreshPagination = function() {
      return this.pagination.refresh();
    };

    return Index;

  })(Spine.Controller);

  $(document).ready(function() {
    var data, num;

    App.UsersCtrl.index = new App.UsersCtrl.Index({
      el: '#users'
    });
    data = (function() {
      var _i, _ref1, _ref2, _results;

      _results = [];
      for (num = _i = _ref1 = 'A'.charCodeAt(0), _ref2 = 'z'.charCodeAt(0); _ref1 <= _ref2 ? _i <= _ref2 : _i >= _ref2; num = _ref1 <= _ref2 ? ++_i : --_i) {
        _results.push({
          name: String.fromCharCode(num)
        });
      }
      return _results;
    })();
    return App.User.refresh(data);
  });

}).call(this);
