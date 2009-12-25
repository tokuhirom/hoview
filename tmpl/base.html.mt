<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title><?= block title => '' ?>tokuhirom's memo</title>
    <meta http-equiv="Content-Style-Type" content="text/css" />  
    <meta http-equiv="Content-Script-Type" content="text/javascript" />  
    <link rel="alternate" type="application/rss+xml" title="RSS" href="http://64p.org/memo/index.rss">
    <link href="/static/refresh/style.css" rel="stylesheet" type="text/css" media="screen" />
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.2.6/jquery.min.js" type="text/javascript"></script>
</head>
<body>
<div id="wrapper">
	<div id="header">
		<div id="logo">
            <h1>tokuhirom's memo</h1>
        </div>
		<div id="menu">
			<ul>
				<li><a href="/">Home</a></li>
				<li><a href="/memo/" class="active">Blog</a></li>
			</ul>
		</div>
    </div>
	<div id="page">
		<div id="page-bgtop">
			<div id="page-bgbtm">
				<div id="content">
					<div class="post">
                        <?= block content => '' ?>
                    </div>
                </div> <!-- /#content -->

				<div id="sidebar">
				<div id="sidebar-bgtop">
				<div id="sidebar-bgbtm">
                    <div id="menuContainer">
                        now loading
                    </div>
                </div>
                </div>
                </div>
            </div>
        </div>
    </div>
    <script>
        $(function () {
            $("#menuContainer").load("/memo/menu.html");
        });
    </script>
</body>
</html>
