module Users
  class UserProfileImageUpdater

    attr_reader :user, :image

    def initialize(user, image)
      @user = user
      @image = image
    end

    def call
      delete_previous_image if user.profile_image.present?
      Attached::ResourceFile.transaction do
        stored_file = GoogleStorage.new(user, image, 'image').perform(image.original_filename)
        attached_image = Attached::Image.create(name: image.original_filename, url: stored_file.public_url)
        Attached::ResourceFile.create(attached: attached_image, owner: user, kind: 'profile_image')
      end
      user.reload
    end

    def delete_previous_image
      user.file.destroy
    end
  end
end
