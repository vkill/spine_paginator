// spine.paginator.js
// version: 1.0.0
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
  
  see https://github.com/vkill/spine_paginator/blob/master/examples/spine_pagination.coffee
  */


  Spine.PaginationController = (function(_super) {
    __extends(PaginationController, _super);

    function PaginationController() {
      this.templateHtmlDataEmpty = __bind(this.templateHtmlDataEmpty, this);
      this.render = __bind(this.render, this);      this.page || (this.page = 1);
      this.pagination || (this.pagination = null);
      this.model || (this.model = null);
      this.perPage || (this.perPage = 10);
      this.paginateEvent || (this.paginateEvent = "paginate");
      PaginationController.__super__.constructor.apply(this, arguments);
      if (typeof this.model.page !== 'function') {
        throw new Error("not found page function for model");
      }
      this.model.bind(this.paginateEvent, this.render);
    }

    PaginationController.prototype.refresh = function() {
      this.page = 1;
      return this.load();
    };

    PaginationController.prototype.toPage = function(page) {
      this.page = page;
      return this.load();
    };

    PaginationController.prototype.load = function() {
      this.pagination = this.model.page(this.page, {
        perPage: this.perPage
      });
      return this.model.trigger(this.paginateEvent);
    };

    PaginationController.prototype.render = function() {
      if (this.pagination.records.length > 0) {
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
      return this.toPage(page);
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
          page = this.pagination.firstPage();
          break;
        case 'prev':
          page = this.pagination.currentPage() - 1;
          break;
        case 'next':
          page = this.pagination.currentPage() + 1;
          break;
        case 'last':
          page = this.pagination.lastPage();
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
      var div, firstLi, lastLi, locals, nextLi, page, pageLi, prevLi, ul, _i, _len, _ref;

      locals = this.pagination.locals;
      div = $("<div class='pagination pagination-small pull-right'></div>");
      ul = $("<ul></ul>");
      firstLi = $("<li><a href='javascript:void(0);' data-page='first'>first</a></li>").addClass(locals.hasFirst ? '' : 'disabled');
      prevLi = $("<li><a href='javascript:void(0);' data-page='prev'>prev</a></li>").addClass(locals.hasPrev ? '' : 'disabled');
      nextLi = $("<li><a href='javascript:void(0);' data-page='next'>next</a></li>").addClass(locals.hasNext ? '' : 'disabled');
      lastLi = $("<li><a href='javascript:void(0);' data-page='last'>last</a></li>").addClass(locals.hasLast ? '' : 'disabled');
      ul.append(firstLi).append(prevLi);
      _ref = locals.pages;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        page = _ref[_i];
        if (page.gap) {
          pageLi = $("<li class='disabled'><a href='javascript:void(0);' data-page='gap'>...</a></li>");
        } else {
          pageLi = $("<li><a href='javascript:void(0);'' data-page='" + page.number + "'>" + page.number + "</a></li>").addClass(page.current ? 'active' : '');
        }
        ul.append(pageLi);
      }
      ul.append(nextLi).append(lastLi);
      return div.append(ul);
    };

    return PaginationController;

  })(Spine.Controller);

}).call(this);
