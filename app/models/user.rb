class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_attached_file :avatar,
                    styles: { large: "600x600>", medium: "300x300>", thumb: "150x150#" },
                    url: "/assets/:style/:attachment/:style.:extension"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  has_many :user_conversations
  has_many :conversations, through: :user_conversations
  has_many :messages
  has_many :connections
  has_many :connected_users, through: :connections
  has_many :useraudiofiles
  has_many :boardposts
  has_many :dragonflymedia
  has_many :locations

  # validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  def full_name
    first_name + " " + last_name
  end

  def self.create_with_omniauth(auth)

    user = find_or_create_by(uid: auth['uid'], provider:  auth['provider'])
    user.email = "#{auth['uid']}@#{auth['provider']}.com"
    user.password = auth['uid']
    user.name = auth['info']['name']
    if User.exists?(user)
      user
    else
      user.save!
      user
    end
  end

  def unread_messages
    unreads = []
    self.user_conversations.each do |uc|
      uc.unread_messages.each do |message|
        unreads << message
      end
    end
    return unreads
  end

  def find_convo(user)
    self.conversations.each do |convo|
      if convo.other_user(self) == user
        return convo
      end
    end
    nil
  end

  def has_convo?(user)
    self.conversations.each do |convo|
      if convo.other_user(self) == user
        return true
      end
    end
    false
  end

end
