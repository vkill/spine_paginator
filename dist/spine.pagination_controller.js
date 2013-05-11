// spine.paginator.js
// version: 0.1.1
// author: vkill
// license: MIT
(function() {
  var Spine,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Spine = this.Spine || require('spine');

  /*
  
  Usage
  
  see https://github.com/vkill/spine_paginator/examples/spine_pagination.coffee
  */


  Spine.PaginationController = (function(_super) {
    __extends(PaginationController, _super);

    PaginationController.MODEL = null;

    PaginationController.PER_PAGES = [10, 20, 30, 40];

    PaginationController.PAGINATE_EVENT = "paginate";

    PaginationController.PAGE = 1;

    PaginationController.PER_PAGE = null;

    PaginationController.PAGINATION = null;

    function PaginationController() {
      this.templateHtmlDataEmpty = __bind(this.templateHtmlDataEmpty, this);
      this.render = __bind(this.render, this);      PaginationController.__super__.constructor.apply(this, arguments);
      if (this.constructor.MODEL == null) {
        throw new Error("please defined class variable MODEL");
      }
      this.constructor.PER_PAGE = this.constructor.PER_PAGES[0];
      if (this.constructor.PER_PAGE == null) {
        throw new Error("please defined class variable PER_PAGES");
      }
      this.constructor.MODEL.bind(this.constructor.PAGINATE_EVENT, this.render);
    }

    PaginationController.refresh = function() {
      this.PAGE = 1;
      return this.load();
    };

    PaginationController.toPage = function(page) {
      this.PAGE = page;
      return this.load();
    };

    PaginationController.load = function() {
      var pagination;

      pagination = this.MODEL.page(this.PAGE, {
        perPage: this.PER_PAGE
      });
      this.PAGINATION = pagination;
      return this.MODEL.trigger(this.PAGINATE_EVENT);
    };

    PaginationController.prototype.render = function() {
      var pagination;

      pagination = this.constructor.PAGINATION;
      if (pagination.records.length > 0) {
        return this.html(this.templateHtml());
      } else {
        return this.html(this.templateHtmlDataEmpty());
      }
    };

    PaginationController.prototype.events = {
      'click a[data-page]': 'clickPage'
    };

    PaginationController.prototype.clickPage = function(e) {
      var page;

      e.preventDefault();
      page = this.getPageFromE(e);
      if (page == null) {
        return;
      }
      return this.constructor.toPage(page);
    };

    PaginationController.prototype.getPageFromE = function(e) {
      var $node, page, _page;

      $node = $(e.target);
      if ($node.parent('.disabled, .active').length > 0) {
        return null;
      }
      _page = $node.data('page');
      page = null;
      switch (_page) {
        case 'first':
          page = this.constructor.PAGINATION.firstPage();
          break;
        case 'prev':
          page = this.constructor.PAGINATION.currentPage() - 1;
          break;
        case 'next':
          page = this.constructor.PAGINATION.currentPage() + 1;
          break;
        case 'last':
          page = this.constructor.PAGINATION.lastPage();
          break;
        case 'gap':
          page = null;
          break;
        default:
          page = _page;
      }
      return page;
    };

    PaginationController.prototype.templateHtmlDataEmpty = function() {
      return "";
    };

    PaginationController.prototype.templateHtml = function() {
      var pagination, source;

      pagination = this.constructor.PAGINATION;
      source = "<div class=\"pagination pagination-small pull-right\">\n  <ul>\n    <li {{#unless hasFirst}}class=\"disabled\"{{/unless}}>\n      <a href=\"javascript:void(0);\" data-page=\"first\">first</a>\n    </li>\n    <li {{#unless hasPrev}}class=\"disabled\"{{/unless}}>\n      <a href=\"javascript:void(0);\" data-page=\"prev\">prev</a>\n    </li>\n    {{#each pages}}\n      {{#if this.gap}}\n        <li class=\"disabled\">\n          <a href=\"javascript:void(0);\" data-page='gap'>...</a>\n        </li>\n      {{else}}\n        <li {{#if this.current}}class=\"active\"{{/if}}>\n          <a href=\"javascript:void(0);\" data-page={{this.number}}>{{this.number}}</a>\n        </li>\n      {{/if}}\n    {{/each}}\n    <li {{#unless hasNext}}class=\"disabled\"{{/unless}}>\n      <a href='javascript:void(0);' data-page=\"next\">next</a>\n    </li>\n    <li {{#unless hasLast}}class=\"disabled\"{{/unless}}>\n      <a href='javascript:void(0);' data-page=\"last\">last</a>\n    </li>\n  </ul>\n</div>";
      return Handlebars.compile(source)(pagination.locals);
    };

    return PaginationController;

  })(Spine.Controller);

}).call(this);
