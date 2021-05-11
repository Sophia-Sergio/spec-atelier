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
        google_storage = GoogleStorage.new(user, image, 'image')
        google_storage.remove(image.original_filename)
        stored_file = google_storage.upload(image.original_filename)
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
