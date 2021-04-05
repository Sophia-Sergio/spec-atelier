module CallableCommand

  def self.included(*)
    raise "#{name} debe ser extendido"
  end

  def call(*args, &block)
    # TODO: cambiar a *args, **kwargs cuando migremos a ruby 2.7/3.0
    new(*args, &block).call
  end
end
