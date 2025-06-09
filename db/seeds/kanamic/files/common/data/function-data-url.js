$.ajaxSetup({ cache: false });//キャッシュを使用しない

			$(function () {
				$.ajax({
					// url: "test.json", //取得元のURLまたはディレクトリを記載
					url: "https://xs139481.xsrv.jp/demo/htdocs_2019/common/data/jisseki.json", //取得元のURLまたはディレクトリを記載
					type: 'GET',
					cache: false,
  					dataType: 'json',

					success: function (data) {

							// 導入地域数
							$(".area-box").html(data[0].area + '地域');//〇〇地域

							// 健康経営優良法人リンク
							$(".url-yuryo").html(' <a href=" ' +  data[0].urlyuryo + ' "> ');//

							// <a href="../topics/press-release/2024/press-release0312.html"></a>

						
						},
					error: function () {
						$(".area-box").html("[更新中です]");
						$(".urlyuryo").html("[更新中です]");
					}

					
				});
			});
