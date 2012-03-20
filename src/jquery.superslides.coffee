###
  Superslides 0.1
  Fullscreen slideshow plugin for jQuery
  by Nic Aitch
  http://nicinabox.com
###

$ = jQuery
$.fn.superslides = (options) ->
  options = $.extend
    delay: 5000
    play: false
    slide_speed: 'normal'
    slide_easing: 'linear'
    nav_class: 'slides-navigation'
    adjust_slides_size_callback: ->
    adjust_image_size_callback: ->
    animate_callback: ->
  , options

  $this = $(this).children('ul')
  $children = $this.children()
  $nav = $(".#{options.nav_class}")
  width = window.innerWidth || document.body.clientWidth
  height = window.innerHeight || document.body.clientHeight
  current = 0
  size = $children.length
  prev = 0
  next = 0
  first_load = true
  interval = 0
  
  start = () ->
    animate 0, options.animate_callback
    if options.play      
      interval = setInterval ->
        direction = (if first_load then 0 else "next")
        animate direction, options.animate_callback
      , options.delay
        
  stop = () ->
    clearInterval interval

  adjust_image_size = ($el, callback) ->
    # TODO: Fix height/width calculation
    
    $img        = $('img', $el)
    img_width   = $img.width()
    img_height  = $img.height()
    
    $img.removeAttr('width').removeAttr('height')
    
    if height < img_height
      $img.css
        top: -(img_height - height)/2

    if width < img_width
      $img.css
        left: -(img_width - width)/2

    callback()
        
  adjust_slides_size = ($el, callback) ->
    $el.each (i) ->
      $(this).width(width).height(height).css
        left: width
      adjust_image_size $(this), options.adjust_image_size_callback

    callback()
    
  move_slide = (source, target) ->
    $children.eq(source).insertAfter($children.eq(target))
    $children = $this.children()

  animate = (direction, callback) ->
    first_load = false
    prev = current
    switch direction
      when 'next'
        position = width*2
        direction = -width*2
        next = current + 1
        next = 0 if size == next
      when 'prev'
        position = 0
        direction = 0
        next = current - 1
        next = size-1 if next == -1
      else
        prev = -1
        next = direction

    current = next
    $children.removeClass('current').eq(current).addClass('current')

    $children.eq(current).css
      left: position
      display: 'block'

    $this.animate
      left: -position
    , options.slide_speed
    , options.slide_easing
    , ->
      # after animation reset control position
      $this.css
        left: -width

      # reset and show next
      $children.eq(next).css
        left: width
        zIndex: 2

      # reset previous slide
      $children.eq(prev).css
        left: width
        display: 'none'
        zIndex: 0

      callback()

  this.each ->
    $this.width(width*size)
    $container = $this.parent()
    
    # set css for slides
    $children.css
      position: 'absolute'
      top: 0
      left: width
      zIndex: 0
      display: 'none'
		
		# set css for control div
    $this.css
      position: 'relative'
      width: width * 3
      height: height
      left: -width

    adjust_slides_size $children, options.adjust_slides_size_callback
    start()
		
    $(window).resize (e) ->
      width = window.innerWidth || document.body.clientWidth
      height = window.innerHeight || document.body.clientHeight
      adjust_slides_size $children, options.adjust_slides_size_callback
      $this.width(width*size).css
        left: -width*current

    $('a', $nav).click (e) ->
      e.preventDefault()
      stop()
      if $(this).hasClass('next')
        animate 'next', options.animate_callback
      else
        animate 'prev', options.animate_callback
