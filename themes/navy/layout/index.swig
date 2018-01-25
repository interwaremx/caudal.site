<header id="banner" class="wrapper">
  <div class="inner">
    <h2 id="banner-title">{{ page.subtitle }}</h2>
    <div id="banner-start">
      <span id="banner-start-option">{{ __('index.get_started') }}</span><a id="banner-start-link" href="docs/"><i class="fa fa-arrow-right"></i></a>
      <span id="banner-start-option">{{ __('index.api_reference') }}</span><a id="banner-start-link" href="api/"><i class="fa fa-arrow-right"></i></a>
    </div>

    <div id="banner-share">{{ partial('partial/share') }}</div>

  </div>
</header>
<div id="content-wrap">
  <div class="wrapper">
    <div class="inner">
      {{ page.content }}

      <div id="intro-get-started-wrap">
        <a href="docs/" id="intro-get-started-link">{{ __('index.get_started') }}</a>
      </div>
    </div>
  </div>
</div>
