
module SpinePaginator
  class Railtie < ::Rails::Railtie
  
    initializer "sprockets.spine_paginator", after: "append_asset_paths", group: :all do |app|
      next unless app.config.assets.enabled
      path = File.expand_path("../../../dist", __FILE__)
      app.config.assets.paths << path unless app.config.assets.paths.include?(path)
    end

  end
end
