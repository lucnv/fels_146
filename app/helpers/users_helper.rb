module UsersHelper
  def gravatar_for user, option = {}
    gravatar_id = Digest::MD5::hexdigest user.email.downcase
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    size = option[:size] || Settings.avatar_size_default
    image_tag gravatar_url, alt: user.name, width: size, height: size,
      class: "gravatar"
  end
end
