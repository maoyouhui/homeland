class AddWechatToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :wechat, :string
  end
end
