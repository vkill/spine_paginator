// spine.paginator.js
// version: 0.1.0
// author: vkill
// license: MIT
(function() {
  var Extend, Model, Paginator, Spine;

  Spine = this.Spine || require('spine');

  Model = Spine.Model;

  Paginator = (function() {
    Paginator.DEFAULT_PER_PAGE = 25;

    Paginator.MAX_PER_PAGE = null;

    Paginator.WINDOW = 4;

    Paginator.OUTER_WINDOW = 0;

    Paginator.LEFT = 0;

    Paginator.RIGHT = 0;

    function Paginator(records, _page, options) {
      var outer_window;

      this._page = _page;
      if (options == null) {
        options = {};
      }
      this._page = parseInt(this._page);
      if (isNaN(this._page) || this._page <= 0) {
        this._page = 1;
      }
      this._originalPage = this._page;
      this.perPage = options.perPage || this.constructor.DEFAULT_PER_PAGE;
      this.perPage = parseInt(this.perPage);
      if (isNaN(this.perPage) || this.perPage <= 0) {
        this.perPage = this.constructor.DEFAULT_PER_PAGE;
      }
      this.maxPerPage = options.maxPerPage || this.constructor.MAX_PER_PAGE;
      this.window = options.window || options.inner_window || this.constructor.WINDOW;
      outer_window = options.outer_window || this.constructor.OUTER_WINDOW;
      this.left = options.left || this.constructor.LEFT;
      if (this.left === 0) {
        this.left = outer_window;
      }
      this.right = options.right || this.constructor.RIGHT;
      if (this.right === 0) {
        this.right = outer_window;
      }
      this.originalRecords = this.cloneArray(records);
      this.totalCount = this.originalRecords.length;
      this.skipbuildButtonsAndLocals = options.skipbuildButtonsAndLocals;
      this.records = [];
      this.buttons = [];
      this.locals = {};
      this.per();
    }

    Paginator.prototype.per = function(num) {
      var fromN, n, toN;

      n = parseInt(num);
      if (!isNaN(n) && n > 0) {
        this.perPage = n;
        this._page = this._originalPage;
      }
      fromN = this.offsetValue();
      toN = fromN + this.limitValue();
      this.records = this.originalRecords.slice(fromN, toN);
      if (this.skipbuildButtonsAndLocals == null) {
        this.buildButtonsAndLocals();
      }
      return this;
    };

    Paginator.prototype.totalPages = function() {
      return Math.ceil(this.totalCount / this.limitValue());
    };

    Paginator.prototype.currentPage = function() {
      if (this.limitValue() == null) {
        return this.firstPage();
      }
      return (this.offsetValue() / this.limitValue()) + 1;
    };

    Paginator.prototype.firstPage = function() {
      return 1;
    };

    Paginator.prototype.isFirstPage = function() {
      return this.currentPage() === this.firstPage();
    };

    Paginator.prototype.lastPage = function() {
      return this.totalPages();
    };

    Paginator.prototype.isLastPage = function() {
      return this.currentPage() >= this.lastPage();
    };

    Paginator.prototype.pages = function() {
      var currentPage, firstPage, last, lastPage, page, result, _i, _pages;

      currentPage = this.currentPage();
      firstPage = this.firstPage();
      lastPage = this.lastPage();
      _pages = [];
      last = null;
      for (page = _i = firstPage; firstPage <= lastPage ? _i <= lastPage : _i >= lastPage; page = firstPage <= lastPage ? ++_i : --_i) {
        result = this.buildPage(page, last, currentPage, firstPage, lastPage);
        if (result.isLeftOuter || result.isRightOuter || result.isInsideWindow) {
          last = null;
        } else {
          last = 'gap';
        }
        _pages.push(result);
      }
      return _pages;
    };

    Paginator.prototype.curPage = function() {
      var currentPage, firstPage, lastPage;

      currentPage = this.currentPage();
      firstPage = this.firstPage();
      lastPage = this.lastPage();
      return this.buildPage(currentPage, null, currentPage, firstPage, lastPage);
    };

    Paginator.prototype.limitValue = function() {
      if (this.perPage > this.totalCount) {
        this.perPage = this.totalCount;
      }
      if ((this.maxPerPage != null) && this.perPage > this.maxPerPage) {
        this.perPage = this.maxPerPage;
      }
      return this.perPage;
    };

    Paginator.prototype.offsetValue = function() {
      var totalPages;

      totalPages = this.totalPages();
      if (this._page > totalPages) {
        this._page = totalPages;
      }
      return (this._page - 1) * this.limitValue();
    };

    Paginator.prototype.buildPage = function(page, last, currentPage, firstPage, lastPage) {
      return {
        number: page,
        isCurrent: page === currentPage,
        isFirst: page === firstPage,
        isLast: page === lastPage,
        isPrev: page === (currentPage - 1),
        isNext: page === (currentPage + 1),
        isLeftOuter: page <= this.left,
        isRightOuter: (lastPage - page) < this.right,
        isInsideWindow: Math.abs(currentPage - page) <= this.window,
        isWasTruncated: last === 'gap'
      };
    };

    Paginator.prototype.buildButtonsAndLocals = function() {
      var curPage, page, pages, _buttons, _i, _len, _locals;

      _buttons = [];
      _locals = {};
      curPage = this.curPage();
      pages = this.pages();
      if (!curPage.isFirst) {
        _buttons.push('first');
        _locals.hasFirst = true;
      } else {
        _locals.hasFirst = false;
      }
      if (!curPage.isFirst) {
        _buttons.push('prev');
        _locals.hasPrev = true;
      } else {
        _locals.hasPrev = false;
      }
      _locals.pages = [];
      for (_i = 0, _len = pages.length; _i < _len; _i++) {
        page = pages[_i];
        if (page.isLeftOuter || page.isRightOuter || page.isInsideWindow) {
          if (page.isCurrent) {
            _buttons.push('current');
            _locals.pages.push({
              number: page.number,
              current: true
            });
          } else {
            _buttons.push(page.number);
            _locals.pages.push({
              number: page.number,
              current: false
            });
          }
        } else if (!page.isWasTruncated) {
          _buttons.push('gap');
          _locals.pages.push({
            number: page.number,
            gap: true
          });
        }
      }
      if (!curPage.isLast) {
        _buttons.push('next');
        _locals.hasNext = true;
      } else {
        _locals.hasNext = false;
      }
      if (!curPage.isLast) {
        _buttons.push('last');
        _locals.hasLast = true;
      } else {
        _locals.hasLast = false;
      }
      _locals.first = this.firstPage();
      _locals.current = this.currentPage();
      _locals.last = this.lastPage();
      _locals.numStart = this.records.length === 0 ? 0 : this.offsetValue() + 1;
      _locals.numEnd = this.offsetValue() + this.records.length;
      _locals.numTotal = this.totalCount;
      this.buttons = _buttons;
      return this.locals = _locals;
    };

    Paginator.prototype.cloneArray = function(array) {
      var value, _i, _len, _results;

      _results = [];
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        value = array[_i];
        _results.push(value.clone());
      }
      return _results;
    };

    return Paginator;

  })();

  Extend = {
    _perPaginateRecords: function() {
      return this.records;
    },
    page: function(n, options) {
      if (options == null) {
        options = {};
      }
      return new Paginator(this._perPaginateRecords(), n, options);
    }
  };

  Model.Paginator = {
    extended: function() {
      return this.extend(Extend);
    }
  };

  Spine.Paginator = Paginator;

}).call(this);
