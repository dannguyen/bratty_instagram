module BrattyPack
  module Routes
    autoload :Base, 'app/routes/base'
    autoload :Facebook, 'app/routes/facebook'
    autoload :Instagram, 'app/routes/instagram'
    autoload :Twitter, 'app/routes/twitter'
    autoload :Youtube, 'app/routes/youtube'
  end

  autoload :PresentableDataThing, 'app/data/data_thing'
  autoload :DataPresenter, 'app/data/data_presenter'
end
