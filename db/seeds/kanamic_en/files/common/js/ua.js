// JavaScript Document

$(function() {
  var prefix = "";

  var $dir = $("script")[1];
  $dir = $($dir)
    .attr("src")
    .split("/");

  for (var i = 0; $dir[i].indexOf("common") == -1; i++) {
    prefix += "../";
  }

  var agent = navigator.userAgent;
  //===================================androidの時=========================
  if (agent.search(/Android/) != -1) {
    $("html").addClass("android");
  }
  //===================================スマホの時=========================
  if (
    agent.search(/iPhone/) != -1 ||
    agent.search(/iPod/) != -1 ||
    agent.search(/Android/) != -1
  ) {
    $("link[href$='common/css/style.css']").attr(
      "href",
      prefix + "common/css/sp.css"
    );
    //スマホのときは資料請求のフロートボタンを表示しない
    $("script[src$='common/js/float-button.js']").remove();
    $("div.float-button").remove();
    $("script[src$='common/js/float-button2.js']").remove();
    $("div.float-button2").remove();
    var script = document.createElement("script");
    script.setAttribute("type", "text/javascript");
    script.setAttribute("src", prefix + "common/js/sp_init.js");
    document.getElementsByTagName("head")[0].appendChild(script);
    // link

    /*
		var link = '<link rel="stylesheet" href="/common/css/sp.css">';
		$('meta:last').after(link);
		*/
    var viewport = '<meta name="viewport" content="width=640">';
    $("meta:last").after(viewport);

    //===================================PCユーザー,ipadの時=========================
  } else {
    var script = document.createElement("script");
    script.setAttribute("type", "text/javascript");
    script.setAttribute("src", prefix + "common/js/init.js");
    document.getElementsByTagName("head")[0].appendChild(script);
    var viewport = '<meta name="viewport" content="width=1100">';
    $("meta:last").after(viewport);
    if (agent.search(/iPad/) != -1) {
      $("body").addClass("ipad");
    }
    //cssChange("/common/css/style.css")
    //Company Overview、トピックス、採用、イベントでは資料請求のフロートボタンを表示しない
    if (
      document.URL.match("company/") ||
      document.URL.match("topics/") ||
      document.URL.match("recruit/") ||
      document.URL.match("event/")
    ) {
      $("script[src$='common/js/float-button.js']").remove();
      $("div.float-button").remove();
    }
  }
});

function cssChange(file) {
  var link = document.createElement("link");
  with (link) {
    href = file;
    type = "text/css";
    rel = "stylesheet";
  }
  var head = document.getElementsByTagName("head");
  head.item(0).appendChild(link);
}
