class User
  module OmniauthCallbacks
    extend ActiveSupport::Concern

    module ClassMethods
      %w(github wechat).each do |provider|
        define_method "find_or_create_for_#{provider}" do |response|
          uid = response["uid"].to_s
          data = response["info"]

          if (user = Authorization.find_by(provider: provider, uid: uid).try(:user))
            user
          else
            user = User.new_from_provider_data(provider, uid, data)

            if user.save(validate: false)
              Authorization.find_or_create_by(provider: provider, uid: uid, user_id: user.id)
              return user
            else
              Rails.logger.warn("User.create_from_hash 失败，#{user.errors.inspect}")
              return nil
            end
          end
        end
      end

      def new_from_provider_data(provider, uid, data)
        User.new do |user|


          if provider == "github"
            user.email =
                if data["email"].present? && !User.where(email: data["email"]).exists?
                  data["email"]
                else
                  "#{provider}+#{uid}@example.com"
                end

            user.name = data["name"]
            user.login = Homeland::Username.sanitize(data["nickname"])
            user.github = data["nickname"]


            if user.login.blank?
              user.login = "u#{Time.now.to_i}"
            end

            if User.where(login: user.login).exists?
              user.login = "#{user.github}-github" # TODO: possibly duplicated user login here. What should we do?
            end

            user.password = Devise.friendly_token[0, 20]
            user.location = data["location"]
            user.tagline  = data["description"]

          elsif provider == "wechat"
            user.email =
                if data["email"].present? && !User.where(email: data["email"]).exists?
                  data["email"]
                else
                  "#{provider}+#{uid}@example.com"
                end
            user.name = data["nickname"]
            user.wechat = data["nickname"]

            # 处理login的逻辑
            # 微信用户名到login的处理方式
            # 1. 去除所有emoji。2. 所有中文全部换成汉语拼音 3. 其他非字母字符都换成下划线 sanitize
            login_name = data["nickname"]
            if login_name.is_a? String
              login_name = Homeland::Username.strip_emoji(login_name)
              login_name = Pinyin.t(login_name, splitter: '')
              user.login = Homeland::Username.sanitize(login_name)
            else
              user.login = ""
            end

            if user.login.blank?
              user.login = "u#{Time.now.to_i}"
            end

            if User.where(login: user.login).exists?
              user.login = "#{user.wechat}-wechat" # TODO: possibly duplicated user login here. What should we do?
            end
            
            user.password = Devise.friendly_token[0, 20]
            user.location = data["city"]
          end
        end
      end
    end
  end
end
