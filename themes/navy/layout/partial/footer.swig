<footer id="footer" class="wrapper">
  <div class="inner">
    <div id="footer-copyright">
      &copy; {{ moment(Date.now()).year() }} <a href="{{ config.author_url }}" target="_blank">{{ config.author }}</a><br>
      Documentation licensed under <a href="http://creativecommons.org/licenses/by/4.0/" target="_blank">CC BY 4.0</a>.
    </div>
    <div id="footer-sponsors">
    <p>Sponsored by</p>
    <a href="{{ config.author_url }}"><img style="height: 60px" src="http://www.interware.com.mx/images/logo/logoIW.svg"/></a>            
    </div>
    <div id="footer-links">
      <a href="https://twitter.com/{{ config.twitter }}" class="footer-link" target="_blank"><i class="fa fa-twitter"></i></a>
      <a href="https://github.com/{{ config.github }}" class="footer-link" target="_blank"><i class="fa fa-github-alt"></i></a>
    </div>
  </div>
</footer>
