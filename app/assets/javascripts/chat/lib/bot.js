this.Chat_Bot = (function () {
  function Chat_Bot(el, url) {
    this.$el = $(el);
    this.url = url;
    this.inProgress = false;
    this.render();
  }

  Chat_Bot.prototype.render = function () {
    var _this = this;
    _this.$el.on("keypress", '.chat-text', function (ev) {
      if ((ev.which && ev.which === SS.KEY_ENTER) || (ev.keyCode && ev.keyCode === SS.KEY_ENTER)) {
        _this.sendChatRequest($(this));
      }
    });
    _this.$el.on("click", '.chat-button', function () {
      _this.sendChatRequest($(this));
    });
    _this.$el.on("click", '.chat-items', function (ev) {
      var $target = $(ev.target);
      if ($target.hasClass('chat-suggest')) {
        _this.sendChatRequest($(this), { text: $target.text(), value: $target.data("value"), clickSuggest: true });
        return false;
      } else if ($target.hasClass('chat-success')) {
        _this.sendFeedback($target, 'success');
        return false;
      } else if ($target.hasClass('chat-retry')) {
        _this.sendFeedback($target, 'retry');
        return false;
      }
    });
    _this.$el.on("click", '.chat-dismiss', function () {
      _this.$el.trigger("ss:chatClose");
    });
  };

  Chat_Bot.prototype.fetchFirstMessagenAndSuggestions = function () {
    var _this = this;

    if (_this.inProgress) {
      return;
    }

    _this.inProgress = true;

    $.ajax({
      type: "GET",
      url: _this.url,
      cache: false,
      success: function (res, _status) {
        _this.renderChatResponse(res);
      },
      error: function (_xhr, _status, _error) {
      },
      complete: function(_xhr, _status) {
        _this.inProgress = false;
      }
    });
  };

  Chat_Bot.prototype.sendChatRequest = function ($el, options) {
    var _this = this;
    if (_this.inProgress) {
      return;
    }

    _this.inProgress = true;

    var $chatText = _this.$el.find('.chat-text');

    var text, value;
    if (options) {
      text = options.text;
      value = options.value ? options.value : text;
    }
    if (!text) {
      text = $chatText.val();
      value = text;
      $chatText.val('');
    }
    if (!text) {
      return false;
    }

    var $chatItems = _this.$el.find('.chat-items');
    $chatItems.append($('<div class="chat-item user"></div>').append(text));
    $chatItems.append($('<div class="chat-item in-progress">' + SS.loading + '</div>'));
    $chatItems.animate({ scrollTop: $chatItems[0].scrollHeight });
    $.ajax({
      type: "GET",
      url: _this.url,
      cache: false,
      data: {
        text: text,
        value: value,
        click_suggest: options && options.clickSuggest
      },
      success: function (res, _status) {
        $chatItems.find(".in-progress").remove();
        _this.renderChatResponse(res);
      },
      error: function (_xhr, _status, _error) {
        $chatItems.find(".in-progress").remove();
      },
      complete: function(_xhr, _status) {
        $chatItems.find(".in-progress").remove();
        _this.inProgress = false;
      }
    });
  };

  Chat_Bot.prototype.renderChatResponse = function (res) {
    var _this = this;
    var $chatItems = _this.$el.find('.chat-items');

    var result = res;
    if (typeof res === 'string' || res instanceof String) {
      result = $.parseJSON(res);
    }

    $.each(result.results, function (i, r) {
      if (!r.response) {
        return;
      }

      var siteSearchParagraph;
      if (r.siteSearchUrl) {
        var siteSearchLink = $('<a />', { href: r.siteSearchUrl, target: "_blank", rel: "noopener" }).append(result.siteSearchText);
        siteSearchParagraph = $('<p />', { class: "search-result-btn" }).append(siteSearchLink);
      } else {
        siteSearchParagraph = '';
      }

      if (r.suggests) {
        $chatItems.append($('<div class="chat-item sys"></div>').append(r.response).append(siteSearchParagraph));
        r.suggests.forEach(function (suggest) {
          var chatSuggest = $('<a class="chat-suggest"></a>').attr('href', _this.url).attr('data-value', suggest.value).append(suggest.text);
          $chatItems.append($('<div class="chat-item suggest"></div>').append(chatSuggest));
        });
      } else if (r.question) {
        var chatSuccess = $('<button name="button" type="button" class="chat-success" data-id="' + r.id + '"></button>').append(result.chatSuccess);
        var chatRetry = $('<button name="button" type="button" class="chat-retry" data-id="' + r.id + '"></button>').append(result.chatRetry);
        var chatFinish = $('<div class="chat-finish"></div>').append(r.question).append(chatSuccess).append(chatRetry);
        $chatItems.append($('<div class="chat-item sys"></div>').append(r.response).append(siteSearchParagraph).append(chatFinish));
      } else {
        $chatItems.append($('<div class="chat-item sys"></div>').append(r.response).append(siteSearchParagraph));
      }
    });

    $chatItems.animate({ scrollTop: $chatItems[0].scrollHeight });
  };

  Chat_Bot.prototype.sendFeedback = function ($el, question) {
    var _this = this;
    if (_this.inProgress) {
      return;
    }

    _this.inProgress = true;

    $.ajax({
      type: "GET",
      url: _this.url,
      cache: false,
      data: {
        intent_id: $el.data('id'),
        question: question || 'success'
      },
      success: function (res, _status) {
        _this.renderFeedback(res);
      },
      error: function (_xhr, _status, _error) {
      },
      complete: function(_xhr, _status) {
        _this.inProgress = false;
      }
    });
  };

  Chat_Bot.prototype.renderFeedback = function (res) {
    var _this = this;

    var result = res;
    if (typeof res === 'string' || res instanceof String) {
      result = $.parseJSON(res);
    }

    var $chatItems = _this.$el.find('.chat-items');

    $.each(result.results, function (i, r) {
      if (!r.response) {
        return;
      }

      $chatItems.append($('<div class="chat-item sys"></div>').append(r.response));
    });

    $chatItems.animate({ scrollTop: $chatItems[0].scrollHeight });
    setTimeout(_this.fetchFirstMessagenAndSuggestions.bind(_this), 1000)
  };

  return Chat_Bot;

})();
