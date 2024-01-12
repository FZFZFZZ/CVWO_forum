Rails.application.config.react.server_renderer_extensions = ["jsx", "js", "tsx", "ts"]
Rails.application.config.react.jsx_transformer_class = React::JSX::DEFAULT_TRANSFORMER
Rails.application.config.react.jsx_transform_options = {
  optional: ["es7.classProperties"]
}
Rails.application.config.react.use_webpacker = true