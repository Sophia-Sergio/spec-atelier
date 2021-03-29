class AddClientsToUsers < ActiveRecord::Migration[6.0]
  PAUL_CLIENTS = %w[Soleco Andreu Berzilon].freeze

  def change
    clients = Client.where(name: PAUL_CLIENTS)
    user = User.find_by(email: 'paul.berzilon@gmail.com')
    clients.each {|client| UserClient.create(client: client, user: user) }
  end
end
