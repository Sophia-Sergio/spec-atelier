class ApplicationDecorator < Draper::Decorator

  def self.new_keys(*args)
    args.present? ? define_singleton_method(:new_keys) { args } : []
  end

  def as_json(options = {})
    options[:decorated_methods]
    render = super(model.as_json(options))
    render.merge(new_atributtes)
  end

  def new_atributtes
    self.class.new_keys.each_with_object({}) do |key, hash|
      hash[key] = self.send(key)
    end
  end
end
