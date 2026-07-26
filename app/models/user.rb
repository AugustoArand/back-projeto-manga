class User < ApplicationRecord
  has_secure_password
  has_many :user_sessions,     dependent: :destroy
  has_many :favorites,         dependent: :destroy
  has_many :reading_histories, dependent: :destroy

  XP_PER_LEVEL = 1000
  TRIAL_DAYS   = 15

  before_save :downcase_email

  validates :email,    presence: true,
                       uniqueness: { case_sensitive: false },
                       format: { with: URI::MailTo::EMAIL_REGEXP, message: "inválido" }

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       length: { minimum: 3, maximum: 30 },
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: "só letras, números e _" }

  validates :name,     presence: true, length: { minimum: 2, maximum: 60 }
  validates :password, length: { minimum: 6 }, if: :password_digest_changed?

  def as_api_json
    {
      id:              id,
      name:            name,
      username:        "@#{username}",
      email:           email,
      vip:             vip,
      level:           level,
      xp:              xp,
      xp_needed:       xp_to_next_level,
      avatar_color:    avatar_color,
      initials:        name.split.map(&:first).first(2).join.upcase,
      member_since:    created_at.year,
      trial_ends_at:   trial_ends_at.iso8601,
      trial_days_left: trial_days_left
    }
  end

  def add_xp!(amount)
    self.xp += amount
    while self.xp >= XP_PER_LEVEL
      self.xp    -= XP_PER_LEVEL
      self.level += 1
    end
    save!
  end

  # ── Teste grátis / assinatura ──
  # `vip` (pagamento confirmado) sempre libera acesso, independente do teste.
  def trial_ends_at
    created_at + TRIAL_DAYS.days
  end

  def trial_active?
    Time.current < trial_ends_at
  end

  def access_active?
    vip? || trial_active?
  end

  def trial_days_left
    return 0 if vip?
    ((trial_ends_at - Time.current) / 1.day).ceil.clamp(0, TRIAL_DAYS)
  end

  private

  def xp_to_next_level
    XP_PER_LEVEL
  end

  def downcase_email
    self.email = email.downcase
  end
end
