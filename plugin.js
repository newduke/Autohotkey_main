javascript:(function(e,a,g,h,f,c,b,d){if(!(f=e.jQuery)||g>f.fn.jquery||h(f)){c=a.createElement("script");c.type="text/javascript";c.src="http://ajax.googleapis.com/ajax/libs/jquery/"+g+"/jquery.min.js";c.onload=c.onreadystatechange=function(){if(!b&&(!(d=this.readyState)||d=="loaded"||d=="complete")){h((f=e.jQuery).noConflict(1),b=1);f(c).remove()}};a.documentElement.childNodes[0].appendChild(c)}})(window,document,"1.3.2",function($,L){$("a>img").each(function(i,l){$("<img src=" + $(l).parent().attr("href") + ">").appendTo($("body"))})/* YOUR JQUERY CODE GOES HERE */});

(function(){var jQueryVersion="1";var a=document.createElement("script");a.src="//ajax.googleapis.com/ajax/libs/jquery/"+version+"/jquery.js";a.type="text/javascript";document.getElementsByTagName("head")[0].appendChild(a);})()

var jq = document.createElement('script');
jq.src = "//ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js";
document.getElementsByTagName('head')[0].appendChild(jq);

jQuery.noConflict();$=jQuery

$("a>img").each(function(i,l){$("<img src=" + $(l).parent().attr("href") + ">").appendTo($("body"))})