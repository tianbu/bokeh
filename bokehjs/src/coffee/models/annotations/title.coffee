TextAnnotation = require "./text_annotation"
p = require "../../core/properties"

class TitleView extends TextAnnotation.View
  initialize: (options) ->
    super(options)

    # Use side_panel heuristics to determine unset text props
    ctx = @plot_view.canvas_view.ctx
    @model.panel.apply_label_text_heuristics(ctx, 'justified')
    @mset('text_baseline', ctx.textBaseline)
    @mset('text_align', @mget('title_alignment'))

  _get_computed_location: () ->
    switch @model.panel.side
      when 'left'
        vx = 0
        vy = @_get_text_location(@mget('title_alignment'), 'height') + @mget('title_padding')
      when 'right'
        vx = @canvas.get('right') - 1 #fudge factor due to error in text height measurement
        vy = @canvas.get('height') - @_get_text_location(@mget('title_alignment'), 'height') + @mget('title_padding')
      when 'above'
        vx = @_get_text_location(@mget('title_alignment'), 'width') + @mget('title_padding')
        vy = @canvas.get('top') - 1 #fudge factor due to error in text height measurement
      when 'below'
        vx = @_get_text_location(@mget('title_alignment'), 'width') + @mget('title_padding')
        vy = 0

    sx = @canvas.vx_to_sx(vx)
    sy = @canvas.vy_to_sy(vy)
    return [sx, sy]

  _get_text_location: (alignment, canvas_dimension) ->
    switch alignment
      when 'left'
        text_location = 0
      when 'center'
        text_location = @canvas.get(canvas_dimension)/2
      when 'right'
        text_location = @canvas.get(canvas_dimension)
    return text_location

  render: () ->
    angle = @model.panel.get_label_angle_heuristic('parallel')
    [sx, sy] = @_get_computed_location()
    ctx = @plot_view.canvas_view.ctx

    if @mget('render_mode') == 'canvas'
      @_canvas_text(ctx, @mget('text'), sx, sy, angle)
    else
      @_css_text(ctx, @mget('text'), sx, sy, angle)

  _get_size: () ->
    ctx = @plot_view.canvas_view.ctx
    @visuals.text.set_value(ctx)
    return ctx.measureText(@mget('text')).ascent

class Title extends TextAnnotation.Model
  default_view: TitleView

  type: 'Title'

  @mixins ['text', 'line:border_', 'fill:background_']

  @define {
      text:             [ p.String,                      ]
      title_alignment:  [ p.TextAlign,   'center'        ]
      title_padding:    [ p.Number,      0               ]
      render_mode:      [ p.RenderMode,  'canvas'        ]
    }

  @override {
    background_fill_color: null
    border_line_color: null
  }

module.exports =
  Model: Title
  View: TitleView
